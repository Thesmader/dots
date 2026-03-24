#!/usr/bin/env bash
set -euo pipefail

DOTS="$HOME/dots"
REPO="https://github.com/Thesmader/dots.git"
ENV_FILE="$DOTS/.env.migration"

info() { printf "\033[1;34m=> %s\033[0m\n" "$1"; }
ok()   { printf "\033[1;32m✓  %s\033[0m\n" "$1"; }
warn() { printf "\033[1;33m!  %s\033[0m\n" "$1"; }
pause() { printf "\033[1;33m⏸  %s\033[0m\n" "$1"; read -rp "   Press Enter to continue..."; }

# ──────────────────────────────────────────────
# 0. Xcode Command Line Tools (needed for git)
# ──────────────────────────────────────────────
info "Checking Xcode CLT..."
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    pause "Xcode CLT is installing. Wait for it to finish, then press Enter"
fi
ok "Xcode CLT"

# ──────────────────────────────────────────────
# 0.1 Clone dotfiles repo if not present
# ──────────────────────────────────────────────
if [ ! -d "$DOTS" ]; then
    info "Cloning dotfiles repo..."
    git clone "$REPO" "$DOTS"
    ok "Dotfiles cloned"
fi
cd "$DOTS"

# ──────────────────────────────────────────────
# 0.2 Load migration env
# ──────────────────────────────────────────────
if [ -f "$ENV_FILE" ]; then
    info "Loading .env.migration..."
    set -a
    source "$ENV_FILE"
    set +a
    ok "Migration env loaded"
else
    warn "No .env.migration found — secrets will need manual setup"
    warn "Copy .env.migration.template to .env.migration and fill it in"
fi

# ──────────────────────────────────────────────
# 2. Homebrew
# ──────────────────────────────────────────────
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
ok "Homebrew"

# ──────────────────────────────────────────────
# 3. Brew bundle
# ──────────────────────────────────────────────
info "Installing packages from Brewfile..."
brew bundle --file="$DOTS/Brewfile"
ok "Brew bundle"

# ──────────────────────────────────────────────
# 4. Stow dotfiles
# ──────────────────────────────────────────────
info "Stowing dotfiles..."
cd "$DOTS"

PACKAGES=(
    fish
    zsh
    nvim
    git
    ghostty
    aerospace
    tmux
    starship
    direnv
    jj
    gh
    claude
    ssh
)

for pkg in "${PACKAGES[@]}"; do
    stow -v --target="$HOME" "$pkg"
done
ok "Dotfiles stowed"

# ──────────────────────────────────────────────
# 5. Default shell → Fish
# ──────────────────────────────────────────────
info "Setting Fish as default shell..."
FISH_PATH="/opt/homebrew/bin/fish"
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH"
fi
ok "Default shell set to Fish"

# ──────────────────────────────────────────────
# 6. mise — Node & Go
# ──────────────────────────────────────────────
info "Setting up mise (node, go)..."
eval "$(mise activate bash)"
mise use -g node@lts
mise use -g go@latest
ok "mise: node + go"

# ──────────────────────────────────────────────
# 7. Flutter via FVM
# ──────────────────────────────────────────────
info "Installing Flutter via FVM..."
fvm install stable
fvm global stable
ok "Flutter (stable via FVM)"

# ──────────────────────────────────────────────
# 8. Android SDK
# ──────────────────────────────────────────────
info "Setting up Android SDK..."
export ANDROID_HOME="$HOME/Library/Android/sdk"
mkdir -p "$ANDROID_HOME"
yes | sdkmanager --sdk_root="$ANDROID_HOME" "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator" 2>/dev/null || true
ok "Android SDK"

# ──────────────────────────────────────────────
# 9. macOS defaults
# ──────────────────────────────────────────────
info "Applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

# Finder
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Menu bar clock
defaults write com.apple.menuextra.clock Show24Hour -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

killall Dock Finder 2>/dev/null || true
ok "macOS defaults"

# ──────────────────────────────────────────────
# 10. Touch ID for sudo
# ──────────────────────────────────────────────
info "Enabling Touch ID for sudo..."
SUDO_PAM="/etc/pam.d/sudo_local"
if [ ! -f "$SUDO_PAM" ] || ! grep -q pam_tid "$SUDO_PAM"; then
    echo "auth       sufficient     pam_tid.so" | sudo tee "$SUDO_PAM" >/dev/null
fi
ok "Touch ID sudo"

# ──────────────────────────────────────────────
# 11. Create directories
# ──────────────────────────────────────────────
info "Creating directories..."
mkdir -p "$HOME/notes" "$HOME/screenshots" "$HOME/dev/work" "$HOME/dev/personal"
ok "Directories"

# ──────────────────────────────────────────────
# 12. Secrets (GPG + SSH)
# ──────────────────────────────────────────────
info "Setting up secrets..."

# GPG keys
if [ -n "${GPG_KEY_PERSONAL:-}" ] && [ -f "$GPG_KEY_PERSONAL" ]; then
    gpg --import "$GPG_KEY_PERSONAL"
    ok "GPG personal key imported"
else
    warn "GPG personal key not configured — set GPG_KEY_PERSONAL in .env.migration"
fi

if [ -n "${GPG_KEY_WORK:-}" ] && [ -f "$GPG_KEY_WORK" ]; then
    gpg --import "$GPG_KEY_WORK"
    ok "GPG work key imported"
else
    warn "GPG work key not configured — set GPG_KEY_WORK in .env.migration"
fi

# SSH keys
if [ -n "${SSH_KEYS_DIR:-}" ] && [ -d "$SSH_KEYS_DIR" ]; then
    mkdir -p "$HOME/.ssh"
    cp "$SSH_KEYS_DIR"/id_* "$HOME/.ssh/" 2>/dev/null || true
    cp "$SSH_KEYS_DIR"/*.pub "$HOME/.ssh/" 2>/dev/null || true
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME"/.ssh/id_* 2>/dev/null || true
    chmod 644 "$HOME"/.ssh/*.pub 2>/dev/null || true
    ok "SSH keys copied and permissions fixed"
else
    warn "SSH keys dir not configured — set SSH_KEYS_DIR in .env.migration"
fi

# GitHub CLI
if ! gh auth status &>/dev/null; then
    info "Logging into GitHub CLI..."
    gh auth login
fi
ok "GitHub CLI"

# ──────────────────────────────────────────────
# 13. Fish plugins (fisher)
# ──────────────────────────────────────────────
info "Installing Fish plugins via fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher update"
ok "Fisher plugins"

# ──────────────────────────────────────────────
# 14. Tmux plugins (TPM)
# ──────────────────────────────────────────────
info "Installing tmux plugins via TPM..."
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
"$TPM_DIR/bin/install_plugins" || true
ok "Tmux plugins"

# ──────────────────────────────────────────────
# 15. Neovim plugins
# ──────────────────────────────────────────────
info "Installing Neovim plugins (headless)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
ok "Neovim plugins"

# ──────────────────────────────────────────────
# 16. Raycast
# ──────────────────────────────────────────────
if [ -n "${RAYCAST_EXPORT:-}" ] && [ -f "$RAYCAST_EXPORT" ]; then
    info "Opening Raycast export for import..."
    open "$RAYCAST_EXPORT"
    pause "Raycast import dialog should be open. Complete it, then press Enter"
else
    pause "Import Raycast settings manually (Raycast > Settings > Advanced > Import)"
fi

echo ""
ok "Bootstrap complete! Restart your terminal."
