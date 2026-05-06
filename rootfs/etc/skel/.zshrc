unsetopt PROMPT_SP

export ZSH="$HOME"/.oh-my-zsh
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ZSH_THEME="agnoster"
AGNOSTER_DIR_BG=green

plugins=(git)

if [ -f "$ZSH"/oh-my-zsh.sh ]; then
    source "$ZSH"/oh-my-zsh.sh
fi
