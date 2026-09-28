# Decisions (interview 2026-09-17/18)

| Area | Decision | Consequence in repo |
| --- | --- | --- |
| OS / DE | CachyOS Hyprland edition with Noctalia | `hypr/`, `uwsm/`, `noctalia/` mirror `/etc/skel`; `bootstrap.sh diff-skel` shows the divergence |
| Keybinds | CachyOS/Noctalia defaults | `binds.lua` untouched |
| Hardware | XMG EVO (M24): Ryzen 7 8845HS, Radeon 780M iGPU, 60 GB RAM, 1 TB btrfs; dock monitor MSI MD272XP 1920x1080@60 | no NVIDIA env; `local.lua.example` pre-filled with the dock monitor; `doctor` still checks `/sys/module/nvidia` for other machines |
| Monitors | laptop + one dock monitor | `config/local.lua` (git-ignored) with `MONITORS` table; workspaces 4-6 go to `MONITOR2` |
| Keyboard | US QWERTY | `kb_layout = "us"` in `inputs.lua` |
| Terminal | Ghostty | `ghostty/`; `TERMINAL=ghostty` in `variables.lua` and `uwsm/env`; skel regex fixed for class `com.mitchellh.ghostty` |
| Multiplexer | herdr, tmux dropped | `herdr/`, no `tmux/`; no vim-tmux-navigator |
| Shell | zsh + oh-my-zsh, gentoo theme, plus autosuggestions, syntax-highlighting, fzf, zoxide, eza, bat | `zsh/`; Arch plugin paths sourced directly |
| Editor | LazyVim; C++/CMake + Rust; port existing keymaps | `nvim/` with clangd/cmake/rust extras, telescope picker, harpoon2; keymaps moved off LazyVim prefixes are listed at the top of `keymaps.lua` |
| IDE | none graphical; no Qt or qompoter work planned | no Qt packages, no qompoter completion |
| Claude Code | not managed here | nothing under `~/.claude`; wai/the-library stay separate |
| Git | one identity, GPG signing | `git/.gitconfig` + git-ignored `~/.config/git/local` for email/key |
| Browser | Firefox | `BROWSER=firefox` |
| Theme | Kanagawa default, Omarchy-style hot-switching | `dot theme` sets the Noctalia palette, re-renders templates (Ghostty, btop, GTK/Qt, fuzzel, nvim base16), picks a wallpaper from `wallpapers/<theme>/`, SIGUSR1s nvim. kanagawa.nvim is used for Kanagawa, base16 otherwise; herdr theme `terminal` follows Ghostty |
| Font | JetBrainsMono Nerd Font 12pt (as on the current Sway setup) | `ttf-jetbrains-mono-nerd`; Ghostty and fuzzel at size 12 |
| Idle / lid | nothing automatic | Noctalia idle disabled in UI; no hypridle |
| Omarchy layer (interview 2026-09-18) | system menu, theme switching, curated apps, migrations | `bin/dot`, `migrations/`, `bootstrap.sh update` |
| Apps | Bitwarden, Obsidian (Neovim for Markdown), Spotify, LocalSend, Docker + lazydocker, mise, fastfetch | package list; `Super+O`, `Super+Shift+B`; docker enabled by migration 0001 |
| Web apps | none | browser tabs |
| Bar | auto-hide only when fullscreen | `noctalia msg bar-auto-hide-set smart` in migration 0001 |
| Screenshots / recording | Super+Print region+satty, Super+Shift+R wf-recorder | `dot screenshot`, `dot record` |
| Wallpapers | curated per theme, in repo | `wallpapers/<theme>/`, not stowed |
| Discoverability | fastfetch on new shell; `dot keys` lists binds | zshrc, `dot` |

Removed from the old repo: `i3/`, `picom/`, `alacritty/`, `tmux/`, the packer-based `nvim/`, `nvim/dev`.

Previous system: openSUSE Tumbleweed + Sway 1.12 + Ghostty 1.3 — already Wayland, so clipboard/terminal habits transfer as-is.
