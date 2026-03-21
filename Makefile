DOTS := $(HOME)/dots
PACKAGES := fish zsh nvim git ghostty aerospace tmux starship direnv jj gh claude ssh

.PHONY: all brew stow unstow defaults fish tmux nvim help

all: brew stow defaults fish tmux nvim ## Run full setup

brew: ## Install/update Homebrew packages
	brew bundle --file=$(DOTS)/Brewfile

stow: ## Symlink all dotfiles
	@cd $(DOTS) && for pkg in $(PACKAGES); do \
		stow -v --target=$(HOME) $$pkg; \
	done

unstow: ## Remove all dotfile symlinks
	@cd $(DOTS) && for pkg in $(PACKAGES); do \
		stow -v -D --target=$(HOME) $$pkg; \
	done

defaults: ## Apply macOS system defaults
	defaults write com.apple.dock autohide -bool true
	defaults write com.apple.dock show-recents -bool false
	defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
	defaults write com.apple.finder ShowStatusBar -bool true
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	defaults write com.apple.menuextra.clock Show24Hour -bool false
	defaults write com.apple.menuextra.clock ShowAMPM -bool true
	defaults write NSGlobalDomain KeyRepeat -int 2
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	killall Dock Finder 2>/dev/null || true

fish: ## Install fisher + plugins
	fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher update"

tmux: ## Install TPM + plugins
	@if [ ! -d "$(HOME)/.config/tmux/plugins/tpm" ]; then \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.config/tmux/plugins/tpm; \
	fi
	$(HOME)/.config/tmux/plugins/tpm/bin/install_plugins || true

nvim: ## Install Neovim plugins (headless)
	nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
