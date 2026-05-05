export ZSH="$HOME"/.oh-my-zsh

ZSH_THEME="agnoster"
AGNOSTER_DIR_BG=green

plugins=(git)

if [ -f "$ZSH"/oh-my-zsh.sh ]; then
    source "$ZSH"/oh-my-zsh.sh
fi
