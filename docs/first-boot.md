# First boot checklist (CachyOS Hyprland + Noctalia edition)

Do this once on the freshly installed laptop, in order.

1. Log in through the greeter as normal so the edition's defaults are in place.
2. `git clone https://github.com/mlitre/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles`
3. `./bootstrap.sh -n install` — read the dry run. Then `./bootstrap.sh install`.
4. Edit the three seeded per-machine files (they are git-ignored):
   - `~/.config/hypr/config/local.lua` — pre-filled for the MD272XP; only the connector name (`DP-1` vs `HDMI-A-1`) and the laptop panel scale may need changing (`hyprctl monitors`).
   - `~/.config/git/local` — email and GPG `signingkey` (`gpg --list-secret-keys --keyid-format long`).
   - `~/.config/zsh/local.zsh` — anything machine- or work-specific.
5. GPU is the Radeon 780M iGPU: nothing to do in `uwsm/env`.
6. Log out, log back in (uwsm re-reads `env`; Hyprland reloads `hyprland.lua`).
7. Noctalia, `Super+Z` (migration 0001 already set Kanagawa + smart bar auto-hide and rendered templates):
   - Idle / lock → disable automatic lock and screen-off (you lock manually with `Super+L`).
   - Templates → confirm ghostty, btop, gtk3/4, qt are ticked; the nvim/fuzzel user templates are on automatically.
   - Optionally `./bootstrap.sh snapshot-noctalia` afterwards and commit the snapshot.
7b. Drop a few wallpapers into `~/.dotfiles/wallpapers/kanagawa/`, then `dot theme kanagawa`. Try `Super+Alt+Space`.
7c. Docker: log out/in once for the `docker` group to apply; `mise` is activated in zsh, run `mise use -g node@lts` if you need Node for tooling.
8. Run `herdr` once in Ghostty; `onboarding = false` is preset so it opens straight into a workspace. `prefix+?` lists keys.
9. `nvim`, `:LazyExtras` to confirm clangd/cmake/rust are active, `:checkhealth`.
10. `./bootstrap.sh doctor` — everything `ok`.

Before wiping: the current disk is 97 % full on a 929 GiB btrfs root — copy `~/.ssh`, `~/.gnupg`, Obsidian vault, and any local-only repos off first; the CachyOS installer will not preserve them.

Import your GPG key first (`gpg --import`), otherwise the first commit fails to sign.
