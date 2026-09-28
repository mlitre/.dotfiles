# pomodoro (carried over). Needs `timer` (AUR) and optionally lolcat.
typeset -A pomo_options
pomo_options=(work 50 pbreak 5)

pomodoro() {
  local kind=${1:-work}
  local mins=${pomo_options[$kind]}
  [[ -z $mins ]] && { echo "usage: pomodoro {work|pbreak}"; return 1; }
  command -v timer >/dev/null || { echo "install 'timer' (AUR) first"; return 1; }
  local say=cat; command -v lolcat >/dev/null && say=lolcat
  echo "$kind" | $say
  timer "${mins}m"
  echo "$kind session done" | $say
}
alias work='pomodoro work'
alias pbreak='pomodoro pbreak'   # was `break`, which shadows a shell keyword

# Make a directory and cd into it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Turn directories into btrfs subvolumes so /home snapshots skip them.
# Contents are reflink-copied (instant, no extra space); the original is
# removed only once the file counts match.
nosnap() {
  local d tmp before after
  for d in "$@"; do
    d=${d:A}
    if [[ -d $d && $(stat -c %i "$d") == 256 ]]; then
      print "already a subvolume: $d"; continue
    fi
    if [[ ! -e $d ]]; then
      btrfs subvolume create "$d" >/dev/null && print "created $d"; continue
    fi
    tmp="$d.nosnap-$$"
    mv -- "$d" "$tmp" || return 1
    if ! btrfs subvolume create "$d" >/dev/null; then
      mv -- "$tmp" "$d"; return 1
    fi
    chmod --reference="$tmp" "$d"
    before=$(find "$tmp" | wc -l)
    if cp -a --reflink=always -- "$tmp/." "$d/" && after=$(find "$d" | wc -l) && (( before == after )); then
      rm -rf -- "$tmp"; print "converted $d ($after entries)"
    else
      print -u2 "nosnap: copy mismatch for $d; original kept at $tmp"; return 1
    fi
  done
}
