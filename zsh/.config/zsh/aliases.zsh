# Modern replacements, each guarded so a machine without them still works.
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l --group-directories-first --icons=auto --git'
  alias la='eza -la --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'
alias vim='nvim'
alias v='nvim'

# git (carried over)
alias gstatus='git fetch && git status'
alias gcheckout='git fetch && git checkout'
alias lg='lazygit'

# CMake / Rust shortcuts
alias cmb='cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug && cmake --build build'
alias ccc='ln -sf build/compile_commands.json .'
alias cb='cargo build' cr='cargo run' ct='cargo test' ccl='cargo clippy --all-targets'

# dotfiles
alias dots='cd ~/.dotfiles'
alias restow='stow -d ~/.dotfiles -t ~ -R zsh git nvim ghostty herdr omarchy'

# docker / omarchy
alias ld='lazydocker'
alias theme='omarchy theme set'

# everest MQTT broker: eclipse-mosquitto in podman, using the repo's mosquitto.conf
# (listener 1883 + websockets 9001, allow_anonymous). Replaces any existing container.
EVEREST_MOSQUITTO_CONF="$HOME/Projects/everest-workspace/everest/applications/containers/mosquitto/mosquitto.conf"
mqtt-up() {
  podman rm -f mqtt >/dev/null 2>&1
  podman run -d --name mqtt -p 1883:1883 -p 9001:9001 \
    -v "$EVEREST_MOSQUITTO_CONF:/mosquitto/config/mosquitto.conf:ro" \
    docker.io/library/eclipse-mosquitto:2.0.18
}
alias mqtt-down='podman rm -f mqtt'
alias mqtt-log='podman logs -f mqtt'
