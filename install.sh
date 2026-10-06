#!/bin/bash
# Layer these dotfiles over Omarchy.
#
#   install.sh           stow the packages, then everything --ensure does
#   install.sh --ensure  re-add include lines, templates, nvim extras and the
#                        bar entries in omarchy/bar.json; report
#                        stow links that turned into plain files. Never stows.
#                        Runs from Omarchy's post-update and post-boot hooks.
#
# Omarchy owns every file it seeds into $HOME. This repo only adds files of its
# own, and each tool's Omarchy entry point gets one include line pointing at them.

set -uo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PACKAGES=(bash git nvim ghostty herdr starship omarchy)
mode=${1:-full}
changes=()
problems=()

# Insert $line into $file unless present: after the last line matching
# $anchor (an awk regex), or at the end when there is no anchor or no match.
ensure_line() {
  local file=$1 line=$2 anchor=${3:-}
  [[ -f $file ]] || return 0
  grep -qxF -- "$line" "$file" && return 0
  if [[ -L $file ]]; then
    problems+=("$file is a symlink; not editing it")
    return 0
  fi
  local tmp
  tmp=$(mktemp)
  # ENVIRON, not -v: -v would process the backslashes in the regex.
  if ! LINE=$line ANCHOR=$anchor awk '
    NR == FNR { if (ENVIRON["ANCHOR"] != "" && $0 ~ ENVIRON["ANCHOR"]) last = FNR; next }
    { print }
    FNR == last { print ENVIRON["LINE"]; done = 1 }
    END { if (!done) print ENVIRON["LINE"] }
  ' "$file" "$file" >"$tmp" || (($(wc -l <"$tmp") <= $(wc -l <"$file"))); then
    rm -f "$tmp"
    problems+=("could not add include to $file")
    return 0
  fi
  cat "$tmp" >"$file"   # write in place: keeps the file's inode and mode
  rm -f "$tmp"
  changes+=("added include to ${file/#$HOME/\~}")
}

ensure_includes() {
  ensure_line ~/.bashrc '[[ -r ~/.config/bash/init.bash ]] && source ~/.config/bash/init.bash # dotfiles'
  ensure_line ~/.config/hypr/hyprland.lua 'require("hypr.personal") -- dotfiles' '^require\("hypr\.'
  ensure_line ~/.config/ghostty/config 'config-file = personal'
  ensure_line ~/.config/nvim/lua/config/options.lua 'require("personal.options") -- dotfiles'
  ensure_line ~/.config/nvim/lua/config/keymaps.lua 'require("personal.keymaps") -- dotfiles'
}

# Files that a tool rewrites in place are copied, never linked.
ensure_templates() {
  local src dst
  for src in "$DOTFILES"/templates/applications/*.desktop; do
    [[ -f $src ]] || continue
    dst=~/.local/share/applications/${src##*/}
    [[ -e $dst ]] && continue
    mkdir -p "${dst%/*}"
    cp "$src" "$dst"
    changes+=("copied ${dst/#$HOME/\~}")
  done
}

# LazyVim rewrites lazyvim.json itself, so extras are merged in, never removed.
ensure_nvim_extras() {
  local json=~/.config/nvim/lazyvim.json list=$DOTFILES/nvim/extras.txt
  [[ -d ~/.config/nvim && -r $list ]] || return 0
  command -v jq >/dev/null || { problems+=("jq missing; nvim extras not merged"); return 0; }
  [[ -f $json ]] || echo '{"extras": []}' >"$json"
  local merged
  merged=$(jq --argjson add "$(grep -v '^\s*\(#\|$\)' "$list" | jq -R . | jq -s .)" \
    '.extras = ((.extras // []) + $add | unique)' "$json")
  if [[ $merged != "$(jq . "$json")" ]]; then
    printf '%s\n' "$merged" >"$json"
    changes+=("merged nvim extras into lazyvim.json")
  fi
}

# The shell rewrites shell.json itself and a refresh resets it to Omarchy's
# default. Each omarchy/bar.json entry is inserted when its id is missing, and
# applied over an entry still equal to Omarchy's default; an entry changed
# since is left alone. Plugins are reported, never cloned: a new upstream
# commit is unreviewed code.
ensure_bar() {
  local json=~/.config/omarchy/shell.json spec=$DOTFILES/omarchy/bar.json
  local defaults=${OMARCHY_PATH:-/usr/share/omarchy}/config/omarchy/shell.json
  [[ -f $json && -r $spec ]] || return 0
  command -v jq >/dev/null || { problems+=("jq missing; bar not checked"); return 0; }
  local id url installed=() merged
  while IFS=$'\t' read -r id url; do
    if [[ -d ~/.config/omarchy/plugins/$id ]]; then
      installed+=("$id")
    else
      problems+=("bar plugin $id missing; review it, then: omarchy plugin add $url --enable")
    fi
  done < <(jq -r '.[] | select(.plugin) | [.entry.id, .plugin] | @tsv' "$spec")
  if ! merged=$(jq --slurpfile spec "$spec" --slurpfile defaults "$defaults" \
    --argjson installed "$(printf '%s\n' "${installed[@]}" | jq -R 'select(. != "")' | jq -s .)" '
    def stock($id): [$defaults[0].bar.layout[]?[]? | select(.id == $id)][0];
    reduce ($spec[0][] | select((.plugin | not) or (.entry.id | IN($installed[])))) as $w (.;
      $w.entry.id as $id | stock($id) as $stock |
      if any(.bar.layout[]?[]?; .id == $id) then
        .bar.layout |= map_values(map(
          if .id == $id and $stock != null and . == $stock then $stock * $w.entry else . end))
      else
        .bar.layout[$w.section] = ((.bar.layout[$w.section] // []) as $l
          | ([$l | to_entries[] | select(.value.id == $w.after) | .key][0] // ($l | length - 1)) as $i
          | $l[:$i + 1] + [$w.entry] + $l[$i + 1:])
      end)' "$json"); then
    problems+=("could not apply omarchy/bar.json to $json")
    return 0
  fi
  if [[ $merged != "$(jq . "$json")" ]]; then
    printf '%s\n' "$merged" >"$json"   # in place: keeps the inode and mode
    changes+=("restored bar entries from omarchy/bar.json")
  fi
}

check_links() {
  local out
  out=$(stow -n -d "$DOTFILES" -t ~ "${PACKAGES[@]}" 2>&1 | grep -E 'existing target|cannot stow' || true)
  [[ -n $out ]] && problems+=("stow conflicts (a link became a plain file?):"$'\n'"$out")
}

report() {
  local msg
  if ((${#changes[@]})); then
    msg=$(printf '%s\n' "${changes[@]}")
    echo "$msg"
    [[ $mode == --ensure ]] && command -v notify-send >/dev/null && notify-send "dotfiles" "$msg"
  fi
  if ((${#problems[@]})); then
    msg=$(printf '%s\n' "${problems[@]}")
    echo "$msg" >&2
    command -v notify-send >/dev/null && notify-send -u critical "dotfiles" "$msg"
    return 1
  fi
}

case $mode in
  full) stow -d "$DOTFILES" -t ~ "${PACKAGES[@]}" || exit 1 ;;
  --ensure) ;;
  *) echo "usage: install.sh [--ensure]" >&2; exit 2 ;;
esac

ensure_includes
ensure_templates
ensure_nvim_extras
ensure_bar
check_links
report
