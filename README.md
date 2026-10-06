# .dotfiles

Martin's dotfiles for [Omarchy](https://omarchy.org/) (Arch + Hyprland), deployed with GNU Stow.
The setup stays as close to stock Omarchy as possible: bash with Omarchy's aliases and
starship, Omarchy's LazyVim, Hyprland, Ghostty, herdr and git configs. This repo only adds
personal layers on top of them. Colors follow the Omarchy theme switcher everywhere.

## Fresh machine

Install Omarchy first, then:

```sh
git clone git@github.com:mlitre/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sudo pacman -S --needed stow jq
omarchy-install-terminal ghostty

# per-machine files (git-ignored), then edit them
cp git/.config/git/local.example git/.config/git/local          # email, GPG signing key
cp bash/.config/bash/local.bash.example bash/.config/bash/local.bash

./install.sh
```

Log out and back in (for `environment.d`), then reapply the
[live Omarchy settings](#live-omarchy-settings) below.

## Coexisting with Omarchy

Omarchy seeds files into `$HOME` (everything under `/etc/skel`) and its migrations patch
them in place during `omarchy update`; `omarchy reinstall` copies `/etc/skel` over them
again. A stow symlink in one of those spots either gets written through, overwriting the
repo, or replaced by a plain file and silently untracked. So:

1. **Omarchy owns every file it seeds.** They stay plain, stock files and are never stowed.
2. **This repo only adds files Omarchy never ships** (`hypr/personal/`, `nvim/lua/personal/`,
   `bash/*.bash`, `ghostty/personal`, `herdr/personal.toml`, ...).
3. **One include line per tool** in Omarchy's entry point loads them:

   | Omarchy file | Line |
   | --- | --- |
   | `~/.bashrc` | `source ~/.config/bash/init.bash` |
   | `~/.config/hypr/hyprland.lua` | `require("hypr.personal")` |
   | `~/.config/ghostty/config` | `config-file = personal` |
   | `~/.config/nvim/lua/config/options.lua`, `keymaps.lua` | `require("personal.options")`, `require("personal.keymaps")` |

   herdr has no include, so `HERDR_CONFIG_PATH` (set in `environment.d`) points it at
   `personal.toml`; starship likewise reads `personal.toml` via `STARSHIP_CONFIG`. git reads Omarchy's `~/.config/git/config` and then `~/.gitconfig`.

`install.sh` stows the packages and adds the include lines. `install.sh --ensure` only
re-adds what is missing (include lines, templates, nvim extras, the bar's CPU widget) and
reports stow links that became plain files; Omarchy's `post-update` and `post-boot` hooks run
it, so an update or reinstall that drops a line heals itself and sends a notification.

## Layout

Each top-level directory is a stow package that mirrors `$HOME`. `.stowrc` sets `--no-folding`,
so stow links files, never whole directories, and Omarchy keeps its own files beside ours.

| Package | What |
| --- | --- |
| `bash/` | `.config/bash/{init,aliases,functions}.bash` (+ `local.bash`, git-ignored) |
| `omarchy/.config/hypr/` | `personal.lua` and `personal/{input,bindings,looknfeel,windows}.lua` |
| `omarchy/.config/omarchy/` | the bar's CPU readout script, and the `--ensure` hooks |
| `omarchy/.local/lib/chromium-profiles/` | Chromium Work and Personal launchers, see [Browser](#browser) |
| `nvim/` | `lua/personal/{options,keymaps}.lua`, `lua/plugins/{cpp,rust,telescope,editor}.lua`; `extras.txt` (not stowed) lists the LazyVim extras merged into `lazyvim.json` |
| `ghostty/` | `personal`: font, keys, opacity |
| `herdr/` | `personal.toml` and its `environment.d` entry |
| `starship/` | `personal.toml`: the old p10k lean layout (two lines, status, duration and time on the right) |
| `git/` | `.gitconfig`, global ignore, the sign-off hook (+ `local`, git-ignored: email, signing key) |
| `templates/` | not stowed; copied by `install.sh` when missing (see below) |

The pre-vanilla setup (zsh/oh-my-zsh/p10k, the old CachyOS + Noctalia desktop) is in git
history at the `pre-vanilla-omarchy` tag.

## Not stowed, on purpose

Some files are rewritten in place by the tool that owns them, so they stay live files:

| File | Rewritten by | How it's handled |
| --- | --- | --- |
| `~/.local/share/applications/chromium-*.desktop` | `xdg-settings` (`MimeType=`) | copied from `templates/applications/` when missing |
| `~/.config/nvim/lazyvim.json` | LazyVim, `:LazyExtras` | extras from `nvim/extras.txt` merged in, never removed |
| `~/.config/nvim/lazy-lock.json` | lazy.nvim | not versioned |
| `~/.config/omarchy/shell.json` | bar gestures, `omarchy bar ...`, `omarchy refresh shell` | CPU widget added after the workspaces when missing |
| `~/.config/omarchy/shell.toml` | Omarchy's text-size tool | edited live, see below |
| `~/.config/hypr/monitors.lua` | Omarchy's monitor scaling | left to Omarchy |
| `~/.config/btop/btop.conf` | btop, on every exit | edited live, see below |
| `~/.config/mimeapps.list` | `xdg-settings`, `xdg-mime` | set by command, see [Browser](#browser) |

## Live Omarchy settings

Reapply these by hand on a new machine or after `omarchy refresh shell`:

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

## Browser

Chromium with two local profiles, no Google sign-in: **Work** (`Default`) and **Personal**
(`Personal`). They replace Firefox containers. Links from other apps, `$BROWSER` and
`xdg-open` always open in Work.

Each profile has a launcher at `~/.local/lib/chromium-profiles/<profile>/chromium`. It is
named `chromium` because `omarchy-launch-browser` keeps only the first word of the default
browser's `Exec=` and focuses windows by that name. Set the default once:

```sh
env -u BROWSER xdg-settings set default-web-browser chromium-work.desktop
for m in text/html application/xhtml+xml x-scheme-handler/http x-scheme-handler/https; do
  xdg-mime default chromium-work.desktop "$m"
done
```

Omarchy's generated webapps in `~/.local/share/applications` (YouTube, WhatsApp, Google
Maps/Photos/Messages/Contacts, X) get `--profile-directory=Personal` appended to `Exec=` by
hand; reinstalling a webapp drops it.

Both launchers pass `--no-default-browser-check`, because Chromium's "set as default" prompt
registers `chromium.desktop` and undoes the Work default. If links start opening in the wrong
profile, rerun the commands above.

Extensions, installed per profile from the Chrome Web Store:

| Both | Personal only |
| --- | --- |
| uBlock Origin Lite, Privacy Badger, Bitwarden | YouTube NonStop, The Camelizer, LeechBlock NG |

Omarchy's `chromium-flags.conf` force-loads Copy URL, yt-dlp and WhatsApp Slim into both.

## Keys on top of Omarchy's

See everything with `omarchy menu keybindings --print` (or `Super+K`).

| Key | Action |
| --- | --- |
| `Super+Q` | close window (Omarchy's `Super+W` still works) |
| `Super+L` | lock (was Omarchy's workspace layout toggle) |
| `Super+Shift+L` | toggle workspace layout |
| `Super+Shift+B` / `Return` | Chromium, Work profile (`Alt` for incognito) |
| `Super+Shift+Ctrl+B` / `Return` | Chromium, Personal profile |
| `Super+Shift+C` / `E` / `Alt+E` | Google Calendar, Gmail, new Gmail (Work) |
| `Super+Shift+Y`, `Alt+G`, `Ctrl+G`, `P`, `S`, `X` | YouTube, WhatsApp, Messages, Photos, Maps, X (Personal) |

## Daily commands

Omarchy's own aliases (`ff`, `eff`, `zd`/`cd`, `n`, `g`, `t`, ...) are in
`$OMARCHY_PATH/default/bash/aliases`; `bash/.config/bash/aliases.bash` only adds to them.


| Task | Command |
| --- | --- |
| Re-link after `git pull` | `dots-install` (`./install.sh`) |
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
