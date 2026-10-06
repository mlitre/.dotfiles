# Personal bash layer, sourced at the end of Omarchy's ~/.bashrc by the line
# install.sh keeps there. Omarchy's aliases, functions and tool init are
# already loaded at this point; only additions and overrides belong here.

export EDITOR=nvim VISUAL=nvim SUDO_EDITOR=nvim
export TERMINAL=ghostty BROWSER=$HOME/.local/lib/chromium-profiles/work/chromium
export GPG_TTY=$(tty)
export CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache   # every worktree build shares the cache
export DOTFILES="$HOME/.dotfiles"

for d in "$HOME/.cargo/bin" "$HOME/bin"; do
  case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH" ;; esac
done
export PATH

for f in ~/.config/bash/{aliases,functions,local}.bash; do
  [[ -r $f ]] && source "$f"
done

# Greeting, only for a fresh top-level shell
if [[ $SHLVL -le 2 && -z $NVIM && -z $DOT_NO_FETCH ]] && command -v fastfetch >/dev/null; then
  fastfetch
fi
