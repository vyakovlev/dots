# dots
List of my configs aka dots aka .something

Used on all my systems (macos/linux)

# initial setup
- install `zsh` and `tmux` with your favorite package manager, make sure `zsh` is your default shell - `chsh -s $(which zsh)`
- install oh-my-zsh with `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- install powerlevel10k (oh-my-zsh theme) with `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"`

# currently supported configs

### zsh
oh-my-zsh/power10k + completions + aliases + functions for both macos & linux

### vim
general settings to make development and editing easier

### tmux
use custom plugins, set vim keybindings, huge history, etc

### dircolors
set of nice dircolors for macos/linux

### vscode
keybinding, extensions, see [README](other/vscode/README.md)

### k9s
misc settings & plugins for k9s


# for MacOS only
[Karabiner-elements custom modifications](other/karabiner-elements/README.md)
