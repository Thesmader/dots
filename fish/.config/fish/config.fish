# Fish shell configuration

# Disable greeting
set -g fish_greeting

# ============================================
# PATH modifications
# ============================================
# Homebrew
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/go/bin
fish_add_path /opt/homebrew/opt/openjdk@17/bin

# Android
fish_add_path $HOME/Library/Android/sdk/cmdline-tools/latest/bin
fish_add_path $HOME/Library/Android/sdk/platform-tools
fish_add_path $HOME/Library/Android/sdk/emulator

# Flutter / Dart
fish_add_path $HOME/fvm/default/bin
fish_add_path $HOME/fvm/default/bin/cache/dart-sdk/bin
fish_add_path $HOME/.pub-cache/bin

# Development tools
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.docker/bin

# VS Code
fish_add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# ============================================
# Environment variables
# ============================================
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
set -gx ANDROID_SDK_ROOT $ANDROID_HOME
set -gx EDITOR nvim
set -gx FLUTTER_ROOT "$HOME/fvm/default/bin"
set -gx DOTFILES "$HOME/dots"
set -gx JAVA_HOME "/opt/homebrew/opt/openjdk@17"
set -gx HOMEBREW_NO_AUTO_UPDATE true

# ============================================
# Abbreviations
# ============================================
abbr -a c clear
abbr -a q exit
abbr -a pubg "flutter pub get"
abbr -a gst "git status"
abbr -a enrc "cd $HOME/.config/nvim/ && nvim ."
abbr -a dy "dig +short @dns.toys"
abbr -a vnv "source .venv/bin/activate.fish"
abbr -a myip "dig +short myip.opendns.com @resolver1.opendns.com"

# ============================================
# Custom functions
# ============================================
function gssh
    if test (count $argv) -lt 1
        echo "Instance name is required"
        return 1
    end
    gcloud compute ssh $argv[1] --tunnel-through-iap
end

# ============================================
# Theme
# ============================================

source ~/.config/fish/themes/kanagawa.theme

# ============================================
# Key bindings (vi mode)
# ============================================
if status is-interactive
    fish_vi_key_bindings

    # Custom bindings
    bind -M insert \cy accept-autosuggestion
    bind -M insert \cp history-search-backward
    bind -M insert \cn history-search-forward
    bind -M insert \cf tmux-sessionizer
end

# ============================================
# History settings
# ============================================
set -gx HISTSIZE 1000
set -gx fish_history default

# ============================================
# Integrations
# ============================================

# fzf
if type -q fzf
    fzf --fish | source
end

# zoxide
if type -q zoxide
    zoxide init fish | source
end

# direnv
if type -q direnv
    direnv hook fish | source
end

# mise
if type -q mise
    mise activate fish | source
end

# ============================================
# Google Cloud SDK
# ============================================
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

# ============================================
# Homebrew shell environment
# ============================================
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# ============================================
# Macchina
# ============================================
if status is-interactive; and type -q macchina
    macchina
end

# ============================================
# Starship
# ============================================
starship init fish | source
