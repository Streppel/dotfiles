# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH=$HOME/go/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
    web-search
    copyfile
    dirhistory
)

source $ZSH/oh-my-zsh.sh

## exports ##

export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
export MCFLY_FUZZY=true && eval "$(mcfly init zsh)" 

## aliases ##
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

## asdf
. /opt/asdf-vm/asdf.sh

source /home/natans/.config/broot/launcher/bash/br
