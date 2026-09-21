#!/usr/bin/env bash
# Enable docker, set Noctalia to the Kanagawa palette with smart bar auto-hide,
# seed the theme state and render templates for the first time.
set -euo pipefail
if command -v docker >/dev/null && ! systemctl is-enabled --quiet docker 2>/dev/null; then
    sudo systemctl enable --now docker.service
    id -nG "$USER" | grep -qw docker || sudo usermod -aG docker "$USER"
fi
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles" "$HOME/Pictures/Screenshots" "$HOME/Videos/Recordings"
[[ -f "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme" ]] || echo kanagawa >"${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme"
if command -v noctalia >/dev/null && pgrep -x noctalia >/dev/null 2>&1; then
    noctalia msg color-scheme-set builtin Kanagawa || true
    noctalia msg bar-auto-hide-set smart || true
    noctalia msg templates-apply || true
fi
