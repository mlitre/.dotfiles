# Additions to Omarchy's functions ($OMARCHY_PATH/default/bash/fns).

# pomodoro. Needs `timer` (AUR) and optionally lolcat.
declare -A pomo_options=([work]=50 [pbreak]=5)

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
alias pbreak='pomodoro pbreak'   # `break` is a shell keyword

# Make a directory and cd into it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Turn directories into btrfs subvolumes so /home snapshots skip them.
# Contents are reflink-copied (instant, no extra space); the original is
# removed only once the file counts match.
nosnap() {
  local d tmp before after
  for d in "$@"; do
    d=$(realpath -m -- "$d")
    if [[ -d $d && $(stat -c %i "$d") == 256 ]]; then
      echo "already a subvolume: $d"; continue
    fi
    if [[ ! -e $d ]]; then
      btrfs subvolume create "$d" >/dev/null && echo "created $d"; continue
    fi
    tmp="$d.nosnap-$$"
    mv -- "$d" "$tmp" || return 1
    if ! btrfs subvolume create "$d" >/dev/null; then
      mv -- "$tmp" "$d"; return 1
    fi
    chmod --reference="$tmp" "$d"
    before=$(find "$tmp" | wc -l)
    if cp -a --reflink=always -- "$tmp/." "$d/" && after=$(find "$d" | wc -l) && (( before == after )); then
      rm -rf -- "$tmp"; echo "converted $d ($after entries)"
    else
      echo "nosnap: copy mismatch for $d; original kept at $tmp" >&2; return 1
    fi
  done
}

# everest MQTT broker: eclipse-mosquitto in podman, using the repo's mosquitto.conf
# (listener 1883 + websockets 9001, allow_anonymous). Replaces any existing container.
# Published on loopback only: the config allows anonymous clients.
EVEREST_MOSQUITTO_CONF="$HOME/Projects/everest-workspace/everest/applications/containers/mosquitto/mosquitto.conf"
mqtt-up() {
  podman rm -f mqtt >/dev/null 2>&1
  podman run -d --name mqtt -p 127.0.0.1:1883:1883 -p 127.0.0.1:9001:9001 \
    -v "$EVEREST_MOSQUITTO_CONF:/mosquitto/config/mosquitto.conf:ro" \
    docker.io/library/eclipse-mosquitto:2.0.18
}
