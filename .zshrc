export PATH=$HOME/bin:$HOME/go/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="lambda"

zstyle ':omz:update' mode auto # update automatically without asking
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="mm/dd/yyyy"
unsetopt correct_all # stops auto correction

plugins=(
    fzf-tab
    git
    golang
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    dirhistory
)

source $ZSH/oh-my-zsh.sh
export MCFLY_FUZZY=true && eval "$(mcfly init zsh)" 
[[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"
eval "$(zoxide init zsh)"
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --group-directories-first'
alias cat='bat'

# for fzf-tab
autoload -U compinit; compinit
source ~/.oh-my-zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
