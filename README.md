# dots

Dotfiles and machine setup automation for macOS (Apple Silicon).

## Quick Start

On a fresh Mac, run this single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/Thesmader/dots/main/bootstrap.sh)
```

That's it. The script installs Xcode CLT, clones this repo, and handles everything through to Neovim plugins.

Alternatively, if you want to set up `.env.migration` first:

```bash
xcode-select --install  # wait for it to finish
git clone https://github.com/Thesmader/dots.git ~/dots
cd ~/dots
cp .env.migration.template .env.migration
# fill in .env.migration with paths to GPG keys, SSH keys, Raycast export
./bootstrap.sh
```

## What's Inside

### Stow Packages

Each top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/) package. Running `stow <package>` from `~/dots` creates symlinks in `$HOME` that mirror the package's internal structure.

For example, `stow fish` links `fish/.config/fish/config.fish` → `~/.config/fish/config.fish`.

| Package      | What it configures                                                                                                                                                                                                                             |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aerospace/` | [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling window manager — alt-key workspace bindings, vi-style focus/move, service mode for layout resets                                                                                  |
| `claude/`    | Claude Code — global instructions (`CLAUDE.md`), settings, custom slash commands (`/plan`, `/generate`, `/resolve-pr-comments`), installed skills                                                                                              |
| `direnv/`    | [direnv](https://direnv.net/) — hides env diff output                                                                                                                                                                                          |
| `fish/`      | [Fish shell](https://fishshell.com/) — vi mode, abbreviations, fzf/zoxide/direnv/mise integrations, Kanagawa color theme, starship prompt                                                                                                      |
| `gh/`        | [GitHub CLI](https://cli.github.com/) — HTTPS protocol, `co` alias for `pr checkout`                                                                                                                                                           |
| `ghostty/`   | [Ghostty](https://ghostty.org/) terminal — Kanagawa Wave theme, JetBrainsMono Nerd Font, 14pt, background blur, option-as-alt                                                                                                                  |
| `git/`       | Git — conditional includes for work (`~/dev/work/`) and personal (`~/dev/personal/`) with separate GPG signing keys, nvim as merge tool, auto-prune on fetch                                                                                   |
| `jj/`        | [Jujutsu](https://github.com/jj-vcs/jj) version control                                                                                                                                                                                        |
| `nvim/`      | [Neovim](https://neovim.io/) — lazy.nvim plugin manager, LSP (mason), blink.cmp, fzf-lua, DAP debugging, Flutter/Dart support via flutter-tools + FVM, treesitter with textobjects, gitsigns, neogit, conform formatting, oldworld colorscheme |
| `ssh/`       | SSH — clean config template (OrbStack/Colima will auto-add their includes on install)                                                                                                                                                          |
| `starship/`  | [Starship](https://starship.rs/) prompt — minimal format with directory, git branch/status, command duration, python venv                                                                                                                      |
| `tmux/`      | [tmux](https://github.com/tmux/tmux) — Ctrl-A prefix, vi copy mode, base-index 1, two themes (Kanagawa Wave active, cyberdream-dark available), TPM plugin manager                                                                             |
| `zsh/`       | Zsh — zinit plugin manager, zsh-autosuggestions, fzf-tab, vi mode, same keybindings as fish, p10k (Pure style), mise integration                                                                                                               |

### Brewfile

All packages managed by Homebrew, organized by category:

- **CLI tools**: bat, btop, fd, fzf, gh, git, jj, jq, lazygit, lazydocker, ripgrep (as grep dep), television, tldr, tmux, zoxide, etc.
- **Version management**: [mise](https://mise.jdx.dev/) (node, go), [fvm](https://fvm.app/) (flutter), [uv](https://github.com/astral-sh/uv) (python)
- **Casks**: Ghostty, AeroSpace, Raycast, OrbStack, Arc, Firefox, Chrome, VS Code, Discord, WhatsApp, and more
- **Fonts**: JetBrains Mono Nerd Font
- **Mac App Store**: Xcode, Transporter (via `mas`)

### Makefile

Re-run individual parts of the setup without the full bootstrap:

```bash
make help       # show all targets
make brew       # install/update Homebrew packages
make stow       # symlink all dotfiles
make unstow     # remove all dotfile symlinks
make defaults   # apply macOS system preferences
make fish       # install fisher + plugins
make tmux       # install TPM + plugins
make nvim       # install Neovim plugins (headless)
make all        # run everything above
```

## Bootstrap Script Flow

The `bootstrap.sh` script runs these steps in order:

1. **Xcode Command Line Tools** — installs if missing, pauses until complete
2. **Homebrew** — installs if missing
3. **`brew bundle`** — installs all formulae, casks, fonts, and App Store apps from `Brewfile`
4. **Stow** — symlinks all dotfile packages into `$HOME`
5. **Default shell → Fish** — adds Fish to `/etc/shells` and sets it via `chsh`
6. **mise** — installs Node LTS and latest Go globally
7. **FVM** — installs Flutter stable and sets it as global
8. **Android SDK** — installs platform-tools, build-tools, and Android 35 to `~/Library/Android/sdk`
9. **macOS defaults** — dock autohide, Finder column view + status bar + extensions, clock AM/PM, fast key repeat
10. **Touch ID for sudo** — adds `pam_tid.so` to `/etc/pam.d/sudo_local`
11. **Directories** — creates `~/notes`, `~/screenshots`, `~/dev/work`, `~/dev/personal`
12. **⏸ Pause** — prompts you to import GPG keys, SSH keys, and login to `gh`
13. **Fisher** — installs Fish plugin manager and plugins from `fish_plugins`
14. **TPM** — clones tmux plugin manager and installs plugins
15. **Neovim** — runs headless `Lazy sync` to install all plugins
16. **⏸ Pause** — prompts you to import Raycast settings

## Before You Migrate

Back up these items to Bitwarden (or another secure location) from your old machine:

### GPG Keys

```bash
# Export private keys
gpg --export-secret-keys --armor 23DD47AE58514C18 > personal-gpg.key
gpg --export-secret-keys --armor 05324CEB5785CB37 > work-gpg.key

# On the new machine
gpg --import personal-gpg.key
gpg --import work-gpg.key
```

### SSH Keys

Copy `~/.ssh/id_*` files to the new machine. Then:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
```

### Raycast

On old machine: Raycast → Settings → Advanced → Export.
On new machine: same path, Import.

## Git Configuration

Git uses [conditional includes](https://git-scm.com/docs/git-config#_conditional_includes) to switch between work and personal identities:

- Repos cloned into `~/dev/work/` → uses `~/.gitconfig_work` (work email + GPG key)
- Repos cloned into `~/dev/personal/` → uses `~/.gitconfig_personal` (personal email + GPG key)
- Everything else uses the default in `~/.gitconfig`

## Shell Setup

**Fish** is the default interactive shell. **Zsh** is retained as a secondary shell (some tools and scripts expect it).

Both shells share:

- Vi keybindings (`^y` accept suggestion, `^p`/`^n` history search, `^f` tmux-sessionizer)
- Same abbreviations/aliases (`c`, `q`, `pubg`, `gst`, `dy`, `vnv`, `myip`)
- fzf, zoxide, and mise integrations
- Starship prompt (fish) / Zen prompt + p10k (zsh)

## Adding New Configs

To track a new tool's config:

```bash
# 1. Create the stow package structure
mkdir -p ~/dots/newtool/.config/newtool

# 2. Move the config in
mv ~/.config/newtool/config.toml ~/dots/newtool/.config/newtool/

# 3. Stow it (creates the symlink back)
cd ~/dots && stow newtool

# 4. Add "newtool" to the PACKAGES list in bootstrap.sh and Makefile
```

For files that live directly in `$HOME` (like `.gitconfig`):

```bash
mkdir -p ~/dots/newtool
mv ~/.some-config ~/dots/newtool/.some-config
cd ~/dots && stow newtool
```
