# Additions to Omarchy's aliases ($OMARCHY_PATH/default/bash/aliases).

# git
alias gstatus='git fetch && git status'
alias gcheckout='git fetch && git checkout'
alias lg='lazygit'

# CMake / Rust
alias cmb='cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug && cmake --build build'
alias ccc='ln -sf build/compile_commands.json .'
alias cb='cargo build' cr='cargo run' ct='cargo test' ccl='cargo clippy --all-targets'

# dotfiles / desktop
alias dots='cd ~/.dotfiles'
alias dots-install='~/.dotfiles/install.sh'
alias lzd='lazydocker'
alias theme='omarchy theme set'

# everest MQTT broker
alias mqtt-down='podman rm -f mqtt'
alias mqtt-log='podman logs -f mqtt'
