if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# Set the directory for zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  gh repo clone zdharma-continuum/zinit "$ZINIT_HOME"
fi

# Source/Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting

# Custom completions
fpath=("$ZDOTDIR/completion/" $fpath)
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

fpath+="$HOME/.zsh/zen"
autoload -Uz promptinit
promptinit
prompt zen

# Aliases
alias c="clear"
alias q="exit"
alias pubg="flutter pub get"
alias gst="git status"
alias enrc="cd $HOME/.config/nvim/ && nvim ."
alias dy="dig +short @dns.toys"
alias vnv="source .venv/bin/activate"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

# PATH modifications
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/fvm/default/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
export PATH="$PATH:$HOME/.docker/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/fvm/default/bin/cache/dart-sdk/bin"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# Env vars
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export EDITOR=nvim
export FLUTTER_ROOT="$HOME/fvm/default/bin"
export DOTFILES="$HOME/dots"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export HOMEBREW_NO_AUTO_UPDATE="true"

# Custom commands
function gssh {
  readonly instance=${1:?"Instance name is required"}
  gcloud compute ssh $instance --tunnel-through-iap
}

# gcloud CLI
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Opts
unsetopt beep
bindkey -v
bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -s '^f' 'tmux-sessionizer\n'
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
