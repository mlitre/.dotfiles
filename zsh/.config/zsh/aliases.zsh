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
alias cb='cargo build' cr='cargo run' ct='cargo test' cc='cargo clippy --all-targets'

# dotfiles
alias dots='cd ~/.dotfiles'
alias restow='~/.dotfiles/bootstrap.sh stow'

# docker / dotfiles menu
alias ld='lazydocker'
alias theme='dot theme'
