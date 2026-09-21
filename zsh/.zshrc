# ~/.zshrc — oh-my-zsh, gentoo theme, kept deliberately small.
# Machine/work-specific lines go in ~/.config/zsh/local.zsh (git-ignored).

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gentoo"
DISABLE_AUTO_UPDATE="true"          # pacman/bootstrap owns updates
zstyle ':omz:update' mode disabled

# fzf and zoxide ship as oh-my-zsh plugins; autosuggestions/syntax-highlighting
# come from pacman and are sourced below (no clone into $ZSH_CUSTOM needed).
plugins=(git fzf zoxide)

[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

for p in /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
         /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [ -r "$p" ] && source "$p"
done
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Environment
export EDITOR=nvim VISUAL=nvim
export TERMINAL=ghostty BROWSER=firefox
export GPG_TTY=$TTY
typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin" $path)
[ -r "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
export CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache   # every worktree build shares the cache
export DOTFILES="$HOME/.dotfiles"
command -v mise >/dev/null && eval "$(mise activate zsh)"

# History
HISTSIZE=50000; SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY

for f in "$HOME/.config/zsh/aliases.zsh" "$HOME/.config/zsh/functions.zsh" "$HOME/.config/zsh/local.zsh"; do
  [ -r "$f" ] && source "$f"
done

# Omarchy-style greeting, only for a fresh interactive top-level shell
if [[ -o interactive && $SHLVL -le 2 && -z $NVIM && -z $DOT_NO_FETCH ]] && command -v fastfetch >/dev/null; then
  fastfetch
fi
