# .dotfiles

Martin's dotfiles for [Omarchy](https://omarchy.org/) (Arch + Hyprland), deployed with GNU Stow.
Omarchy owns the desktop; this repo layers personal overrides on top of it and keeps the portable
tools: zsh/oh-my-zsh with powerlevel10k, git, LazyVim (C++/CMake, Rust), Ghostty and herdr. Colors follow the Omarchy
theme switcher everywhere.

## Fresh machine

Install Omarchy first, then:

```sh
git clone git@github.com:mlitre/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sudo pacman -S --needed stow zsh zsh-autosuggestions zsh-syntax-highlighting
omarchy-install-terminal ghostty
git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone --depth 1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# per-machine files (git-ignored), then edit them
cp git/.config/git/local.example git/.config/git/local          # email, GPG signing key
cp zsh/.config/zsh/local.zsh.example zsh/.config/zsh/local.zsh
cp ghostty/.config/ghostty/config.example ~/.config/ghostty/config

# Omarchy ships its own versions of these; move them aside before the first stow
mv ~/.config/nvim ~/.config/nvim.omarchy
for f in hyprland input bindings looknfeel; do mv ~/.config/hypr/$f.lua ~/.config/hypr/$f.lua.omarchy; done

stow ghostty herdr zsh git nvim omarchy
sudo chsh -s /usr/bin/zsh "$USER"
```

Then reapply the [live Omarchy settings](#live-omarchy-settings) below.

## Layout

Each top-level directory is a stow package that mirrors `$HOME`. `.stowrc` sets `--no-folding`,
so stow links files, never whole directories, and Omarchy can keep its own files beside ours.

| Package | What |
| --- | --- |
| `omarchy/.config/hypr/` | `hyprland.lua` (Omarchy's entry point plus `require("hypr.windows")`), and overrides loaded after Omarchy's defaults: `input.lua`, `windows.lua`, `bindings.lua`, `looknfeel.lua` |
| `omarchy/.config/omarchy/bar/scripts/cpu` | CPU and memory readout for the bar |
| `ghostty/.config/ghostty/personal` | font, keys, opacity; loaded after the Omarchy theme so it wins |
| `nvim/.config/nvim/` | LazyVim. `lua/plugins/theme.lua` links to Omarchy's current theme and hot-reloads on theme switch |
| `zsh/` | `.zshrc`, `.p10k.zsh` (prompt layout), `.config/zsh/{aliases,functions}.zsh` (+ `local.zsh`, git-ignored) |
| `git/` | `.gitconfig`, global ignore, the sign-off hook (+ `local`, git-ignored: email, signing key) |
| `herdr/` | herdr config |
| `legacy/` | the previous CachyOS + Noctalia desktop (hypr, noctalia, fuzzel, uwsm, `dot`, bootstrap). Not stowed; kept for reference |

Packages that ship a `*.example` also carry a `.stow-local-ignore`, so the example is never linked.

## Not stowed, on purpose

Some files are rewritten in place by the tool that owns them. A stowed symlink there gets
replaced with a plain file and silently stops tracking the repo, so these stay live files:

| File | Rewritten by | How it's handled |
| --- | --- | --- |
| `~/.config/ghostty/config` | Omarchy's text-size tool (`sed -i` on `font-size`) | copied from `config.example`; holds only `font-size` and includes the theme, then `personal` |
| `~/.config/omarchy/shell.json` | bar gestures, `omarchy bar ...` | edited live, see below |
| `~/.config/omarchy/shell.toml` | Omarchy's text-size tool | edited live, see below |
| `~/.config/hypr/monitors.lua` | Omarchy's monitor scaling | left to Omarchy |
| `~/.config/btop/btop.conf` | btop, on every exit | edited live, see below |
| `~/.p10k.zsh` | `p10k configure` | stowed; after reconfiguring, check it is still a link (`restow` if not) |

## Live Omarchy settings

Reapply these by hand on a new machine or after `omarchy refresh shell`:

- **CPU and memory in the bar**: in `~/.config/omarchy/shell.json`, add after
  `omarchy.workspaces` in `bar.layout.left`:

  ```json
  { "id": "cpu", "type": "command", "exec": "~/.config/omarchy/bar/scripts/cpu", "interval": 3, "tooltip": "CPU and memory", "onClick": "omarchy-launch-or-focus-tui btop" }
  ```

- **Taller bar**: in `~/.config/omarchy/shell.toml`:

  ```toml
  [bar]
  size-horizontal = 32
  ```

- **Daily snapshots of `/home`, 14 kept**:

  ```sh
  sudo snapper -c home create-config /home
  sudo snapper -c home set-config TIMELINE_CREATE=yes TIMELINE_CLEANUP=yes \
    TIMELINE_LIMIT_HOURLY=0 TIMELINE_LIMIT_DAILY=14 TIMELINE_LIMIT_WEEKLY=0 \
    TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_QUARTERLY=0 TIMELINE_LIMIT_YEARLY=0 \
    ALLOW_USERS="$USER" SYNC_ACL=yes
  sudo mkdir -p /etc/systemd/system/snapper-timeline.timer.d
  printf '[Timer]\nOnCalendar=\nOnCalendar=daily\nPersistent=true\n' |
    sudo tee /etc/systemd/system/snapper-timeline.timer.d/daily.conf
  sudo systemctl daemon-reload && sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
  ```

- **btop**: in `~/.config/btop/btop.conf`, `theme_background = false`, `update_ms = 1500`,
  `proc_per_core = true`.

## Keys on top of Omarchy's

See everything with `omarchy menu keybindings --print` (or `Super+K`).

| Key | Action |
| --- | --- |
| `Super+Q` | close window (Omarchy's `Super+W` still works) |
| `Super+L` | lock (was Omarchy's workspace layout toggle) |
| `Super+Shift+L` | toggle workspace layout |

## Daily commands

| Task | Command |
| --- | --- |
| Re-link after `git pull` | `restow` |
| Switch theme everywhere | `theme <name>` (`omarchy theme set`) or `Super+Ctrl+Shift+Space` |
| Check Hyprland config | `hyprctl reload && hyprctl configerrors` |
| Reload terminals | `omarchy restart terminal` |

## Git

Commits are GPG-signed (key in `git/.config/git/local`) and signed off by
`git/.config/git/hooks/prepare-commit-msg`. The hook is registered as a config-based hook
(`[hook "signoff"]` in `.gitconfig`), so it runs alongside each repo's own hooks instead of
replacing them the way `core.hooksPath` would.

Don't rebase or check out old commits inside `~/.dotfiles`: it is the live source for every
stowed file, so an in-place history walk leaves dangling links under `~/.config` while it runs.
Rewrite history in a separate worktree instead.
