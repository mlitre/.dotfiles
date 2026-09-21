#!/usr/bin/env bash
# bootstrap.sh — deploy these dotfiles on CachyOS (Hyprland + Noctalia edition).
#
#   ./bootstrap.sh [-n] install        packages -> move skel aside -> stow -> tools
#   ./bootstrap.sh [-n] stow           (re)link every package
#   ./bootstrap.sh [-n] unstow         remove all links, restore *.pre-stow originals
#   ./bootstrap.sh      diff-skel      show how hypr/ diverges from /etc/skel
#   ./bootstrap.sh      snapshot-noctalia  copy Noctalia's live settings into docs/
#   ./bootstrap.sh      update         git pull, run pending migrations/, restow, re-render themes
#   ./bootstrap.sh      doctor         check tools, links, GPU, fonts
#
# -n = dry run: prints what would happen, changes nothing.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(bin ghostty herdr zsh git hypr uwsm noctalia nvim btop fuzzel fastfetch)
MIG_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/migrations"
SKEL=/etc/skel/.config
DRY=0

log()  { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33mwarn:\e[0m %s\n' "$*" >&2; }
die()  { printf '\e[1;31merror:\e[0m %s\n' "$*" >&2; exit 1; }
run()  { if [[ $DRY -eq 1 ]]; then printf '  \e[2m$ %s\e[0m\n' "$*"; else "$@"; fi; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing '$1' — $2"; }

# ---------------------------------------------------------------- packages
install_packages() {
    need pacman "this script targets Arch/CachyOS"
    local pkgs
    pkgs=$(grep -vE '^\s*(#|$)' "$DOTFILES/pkglist-pacman.txt")
    log "pacman: $(wc -w <<<"$pkgs") packages"
    # shellcheck disable=SC2086
    run sudo pacman -S --needed --noconfirm $pkgs

    if command -v paru >/dev/null 2>&1; then
        local aur
        aur=$(grep -vE '^\s*(#|$)' "$DOTFILES/pkglist-aur.txt" || true)
        if [[ -n $aur ]]; then
            log "paru: $aur"
            # shellcheck disable=SC2086
            run paru -S --needed --noconfirm $aur
        fi
    else
        warn "paru not found; skipping AUR list ($(tr '\n' ' ' <"$DOTFILES/pkglist-aur.txt" | sed 's/#[^ ]*//g'))"
    fi

    if ! command -v rust-analyzer >/dev/null 2>&1 && command -v rustup >/dev/null 2>&1; then
        log "rustup: stable toolchain + rust-analyzer + clippy"
        run rustup default stable
        run rustup component add rust-analyzer clippy rustfmt
    fi
}

install_tools() {
    if [[ ! -d $HOME/.oh-my-zsh ]]; then
        log "oh-my-zsh"
        run git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
    if ! command -v herdr >/dev/null 2>&1; then
        log "herdr (upstream installer -> ~/.local/bin)"
        run bash -c 'curl -fsSL https://herdr.dev/install.sh | sh'
    fi
    if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
        log "default shell -> zsh"
        run chsh -s "$(command -v zsh)"
    fi
    if command -v nvim >/dev/null 2>&1 && [[ $DRY -eq 0 ]]; then
        log "nvim: syncing plugins (first run takes a minute)"
        nvim --headless "+Lazy! sync" +qa || warn "Lazy sync reported errors; open nvim and run :Lazy"
    fi
}

# ---------------------------------------------------------------- stow
# Move anything at a target path that stow would refuse to overwrite.
preserve_targets() {
    local pkg="$1" rel target
    while IFS= read -r -d '' f; do
        rel="${f#"$DOTFILES/$pkg/"}"
        target="$HOME/$rel"
        if [[ -e $target && ! -L $target ]]; then
            log "preserving $target -> ${target}.pre-stow"
            run mv "$target" "${target}.pre-stow"
        elif [[ -L $target && $(readlink -f "$target") != "$DOTFILES"/* ]]; then
            log "replacing foreign symlink $target"
            run mv "$target" "${target}.pre-stow"
        fi
    done < <(find "$DOTFILES/$pkg" -type f -not -name '*.example' -print0)
}

do_stow() {
    need stow "pacman -S stow"
    run mkdir -p "$HOME/.config" "$HOME/.local/bin"
    for pkg in "${PACKAGES[@]}"; do
        [[ -d $DOTFILES/$pkg ]] || die "package dir missing: $pkg"
        preserve_targets "$pkg"
    done
    local flags=(-R --no-folding -d "$DOTFILES" -t "$HOME")
    [[ $DRY -eq 1 ]] && flags+=(-n)
    log "stow ${PACKAGES[*]}"
    stow "${flags[@]}" "${PACKAGES[@]}"
    seed_local_files
}

seed_local_files() {
    local ex
    for ex in "$DOTFILES"/hypr/.config/hypr/config/local.lua.example \
              "$DOTFILES"/zsh/.config/zsh/local.zsh.example \
              "$DOTFILES"/git/.config/git/local.example; do
        local real="${ex%.example}"
        local target="$HOME/${real#"$DOTFILES"/*/}"
        if [[ ! -e $real && ! -e $target ]]; then
            log "seeding $target from example — EDIT IT"
            run cp "$ex" "$real"     # lands inside the repo, git-ignored, then stowed
        fi
    done
    if [[ $DRY -eq 0 ]]; then stow -R --no-folding -d "$DOTFILES" -t "$HOME" hypr zsh git >/dev/null; fi
}

do_unstow() {
    need stow "pacman -S stow"
    log "unstow ${PACKAGES[*]}"
    local flags=(-D -d "$DOTFILES" -t "$HOME")
    [[ $DRY -eq 1 ]] && flags+=(-n)
    stow "${flags[@]}" "${PACKAGES[@]}"
    while IFS= read -r -d '' f; do
        log "restoring ${f%.pre-stow}"
        run mv "$f" "${f%.pre-stow}"
    done < <(find "$HOME/.config" "$HOME" -maxdepth 3 -name '*.pre-stow' -print0 2>/dev/null)
}

# ---------------------------------------------------------------- update + migrations
run_migrations() {
    mkdir -p "$(dirname "$MIG_STATE")"; touch "$MIG_STATE"
    local m name
    for m in "$DOTFILES"/migrations/*.sh; do
        [[ -f $m ]] || continue
        name=$(basename "$m")
        grep -qxF "$name" "$MIG_STATE" && continue
        log "migration $name"
        if [[ $DRY -eq 1 ]]; then continue; fi
        bash "$m" && echo "$name" >>"$MIG_STATE"
    done
}

do_update() {
    need git "pacman -S git"
    log "git pull"
    run git -C "$DOTFILES" pull --rebase --autostash
    do_stow
    run_migrations
    if [[ $DRY -eq 0 ]] && command -v noctalia >/dev/null && pgrep -x noctalia >/dev/null 2>&1; then
        noctalia msg templates-apply >/dev/null 2>&1 || true
    fi
    if [[ $DRY -eq 0 ]] && command -v nvim >/dev/null; then
        nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "Lazy sync reported errors"
    fi
    log "updated"
}

# ---------------------------------------------------------------- misc
diff_skel() {
    [[ -d $SKEL/hypr ]] || die "$SKEL/hypr not found — not the CachyOS Hyprland edition?"
    diff -ru --exclude='local.lua*' "$SKEL/hypr" "$DOTFILES/hypr/.config/hypr" || true
    diff -u "$SKEL/uwsm/env" "$DOTFILES/uwsm/.config/uwsm/env" || true
    diff -u "$SKEL/noctalia/config.toml" "$DOTFILES/noctalia/.config/noctalia/config.toml" || true
}

snapshot_noctalia() {
    local src="$HOME/.config/noctalia/settings.json" dst="$DOTFILES/docs/noctalia-settings.snapshot.json"
    [[ -f $src ]] || die "$src not found"
    run cp "$src" "$dst"
    log "snapshot -> docs/noctalia-settings.snapshot.json (commit it if you want it kept)"
}

gpu_hint() {
    if [[ -d /sys/module/nvidia ]]; then
        warn "NVIDIA module loaded: uncomment the NVIDIA block in ~/.config/uwsm/env"
    elif [[ -d /sys/module/amdgpu || -d /sys/module/i915 || -d /sys/module/xe ]]; then
        log "GPU: Intel/AMD — no extra env needed"
    else
        warn "GPU module not detected; check 'lspci | grep -i vga'"
    fi
}

doctor() {
    local t
    for t in stow zsh git ghostty nvim herdr rg fd fzf zoxide eza bat wl-copy clangd rust-analyzer gpg dot fuzzel grim slurp satty wf-recorder fastfetch ccache mise docker; do
        if command -v "$t" >/dev/null 2>&1; then printf '  ok   %s\n' "$t"; else printf '  MISS %s\n' "$t"; fi
    done
    # grep -q exits on first match, which SIGPIPEs fc-list; under pipefail that
    # fails the whole pipeline and the font reads as missing when it is installed.
    # Drop -q so grep drains stdin and fc-list exits 0.
    fc-list | grep -i 'JetBrainsMono Nerd' >/dev/null && echo '  ok   JetBrainsMono Nerd Font' || echo '  MISS JetBrainsMono Nerd Font'
    gpu_hint
    [[ -L $HOME/.config ]] && warn "HOME/.config is a symlink: folding happened; run unstow, then stow again"
    for pkg in "${PACKAGES[@]}"; do
        local sample
        # .stow-local-ignore is stow's own control file and is never linked, so
        # picking it as the probe makes a correctly-stowed package read as missing.
        sample=$(find "$DOTFILES/$pkg" -type f -not -name '*.example' \
                      -not -name '.stow-local-ignore' | head -1)
        sample="$HOME/${sample#"$DOTFILES/$pkg/"}"
        [[ -L $sample ]] && printf '  ok   %s linked\n' "$pkg" || printf '  MISS %s not linked (%s)\n' "$pkg" "$sample"
    done
    [[ -f $HOME/.config/git/local ]] && grep -q 'you@example.com' "$HOME/.config/git/local" && warn "edit ~/.config/git/local (email, signingkey)"
    [[ -f $HOME/.config/hypr/config/local.lua ]] && grep -q 'DP-3' "$HOME/.config/hypr/config/local.lua" && warn "edit ~/.config/hypr/config/local.lua with your monitor names (hyprctl monitors)"
    [[ -f $HOME/.config/ghostty/themes/noctalia ]] || warn "Noctalia has not rendered the Ghostty theme yet: noctalia msg templates-apply"
    [[ -f $HOME/.config/nvim/lua/noctalia.lua ]] || warn "Neovim base16 palette not rendered yet (only needed for non-Kanagawa themes)"
    printf '  theme: %s\n' "$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme" 2>/dev/null || echo unset)"
}

# ---------------------------------------------------------------- main
[[ ${1:-} == -n ]] && { DRY=1; shift; }
case "${1:-help}" in
    install)  install_packages; do_stow; install_tools; run_migrations; gpu_hint; log "done — log out and back in, then run: $0 doctor" ;;
    update)   do_update ;;
    stow)     do_stow ;;
    unstow)   do_unstow ;;
    diff-skel) diff_skel ;;
    snapshot-noctalia) snapshot_noctalia ;;
    doctor)   doctor ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
esac
