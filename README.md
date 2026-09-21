# .dotfiles

Martin's dotfiles for **CachyOS (Hyprland + Noctalia edition)**, deployed with GNU Stow.
Ghostty · herdr · zsh/oh-my-zsh · LazyVim (C++/CMake, Rust) · Kanagawa by default, with Omarchy-style
whole-desktop theme switching through Noctalia templates (`dot theme`).

## Fresh machine

```sh
git clone https://github.com/mlitre/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh -n install   # dry run, read it
./bootstrap.sh install      # packages, stow, oh-my-zsh, herdr, nvim plugins
```

Then follow [docs/first-boot.md](docs/first-boot.md) (monitor names, git identity, Noctalia colour scheme).

## Layout

Each top-level directory is a stow package that mirrors `$HOME`:

```
bin/.local/bin/dot                          # Super+Alt+Space menu, `dot theme`, screenshots, recording, install, update
ghostty/.config/ghostty/config              # colours come from Noctalia's generated theme
btop/  fuzzel/  fastfetch/                  # themed by Noctalia templates
noctalia/.config/noctalia/theme.toml        # our extra templates (nvim base16, fuzzel)
wallpapers/<theme>/                         # not stowed; `dot theme` picks from here
migrations/NNNN-*.sh                        # run once each by `bootstrap.sh update`
herdr/.config/herdr/config.toml
zsh/.zshrc  zsh/.config/zsh/{aliases,functions}.zsh  (+ local.zsh, git-ignored)
git/.gitconfig  git/.config/git/ignore  (+ local, git-ignored: email, signing key)
hypr/.config/hypr/hyprland.lua  hypr/.config/hypr/config/*.lua  (+ local.lua, git-ignored: monitors)
uwsm/.config/uwsm/env
noctalia/.config/noctalia/config.toml      # live settings.json is NOT tracked
nvim/.config/nvim/                          # LazyVim; lazy-lock.json is tracked
```

Packages that ship a `*.example` also carry a `.stow-local-ignore` so the example itself is never linked; the bootstrap copies it to the real (git-ignored) file on first run.

`hypr/`, `uwsm/` and `noctalia/` start as copies of the edition's `/etc/skel`; `./bootstrap.sh diff-skel` shows every intentional change so upstream updates stay easy to merge.

## Daily commands

| Task | Command |
| --- | --- |
| Re-link after `git pull` | `./bootstrap.sh stow` (or `restow` alias) |
| Add a package | `mkdir -p foo/.config/foo && mv ~/.config/foo/config foo/.config/foo/ && stow foo` |
| Remove everything | `./bootstrap.sh unstow` (restores `*.pre-stow` originals) |
| Update after `git pull` (with migrations) | `./bootstrap.sh update` or `dot update` |
| Switch theme everywhere | `dot theme kanagawa` / `Super+Ctrl+Shift+Space` |
| System menu | `Super+Alt+Space` |
| Health check | `./bootstrap.sh doctor` |
| Keep Noctalia UI choices | `./bootstrap.sh snapshot-noctalia` and commit `docs/noctalia-settings.snapshot.json` |

## Why things are the way they are

See [docs/decisions.md](docs/decisions.md).

## Keys added on top of the CachyOS defaults

| Key | Action |
| --- | --- |
| `Super+Alt+Space` | `dot menu` (theme, wallpaper, screenshot, record, install, update, power) |
| `Super+Ctrl+Shift+Space` | theme picker |
| `Super+Shift+Space` | toggle floating (was `Super+Alt+Space`) |
| `Super+Print` | region screenshot → satty annotate → clipboard |
| `Super+Shift+Print` | full screenshot |
| `Super+Shift+R` | start/stop region recording |
| `Super+O` / `Super+Shift+B` | Obsidian / Bitwarden |
