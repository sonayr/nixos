#!/bin/bash
# Install Home Brew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install  brew apps
# xargs brew install < ./brew.txt

STOW_PACKAGES=("nvim" "zsh" "scripts" "LSP" "tmux" "iterm" "aerospace")
for folder in ${STOW_PACKAGES[@]}; do
    echo "stowing package $folder"
    stow -t $HOME -D $folder
    stow -t $HOME $folder
done
