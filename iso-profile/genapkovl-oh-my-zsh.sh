#!/bin/sh

TMPDIR=${1:-.}
HOME_DIR="$TMPDIR/home/matcha"

mkdir -p "$HOME_DIR"
if command -v git >/dev/null 2>&1; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME_DIR/.oh-my-zsh" 2>/dev/null || true

    chmod -R 755 "$HOME_DIR/.oh-my-zsh"
    chown -R 1000:1000 "$HOME_DIR/.oh-my-zsh" 2>/dev/null || true
fi
