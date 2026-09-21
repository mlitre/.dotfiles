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
