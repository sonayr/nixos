{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "wd" ];
      theme = "cloud";
    };

    shellAliases = {
      python = "python3";
      pip = "pip3";
    };

    initExtra = ''
      # User configuration
      bindkey "[D" backward-word
      bindkey "[C" forward-word

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      addToPath() {
          if [[ "$PATH" != *"$1"* ]]; then
              export PATH=$PATH:$1
          fi
      }

      addToPath "$HOME/.local/bin"
      addToPath "/usr/local/bin"
      addToPath "$(go env GOPATH)/bin"
      addToPath "/Users/ryano/.opencode/bin"

      function addWT (){
          split=(''${(@s:/:)1})
          newpath=''${split[-1]} 
          git fetch
          git worktree add -B $1 $newpath
          tmux new-window -n $newpath -c $(realpath $newpath)
          tmux send-keys 'git pull origin master && clear' c-M
      }

      function removeWT (){
          GIT_DIR=$(git rev-parse --git-dir)
          GIT_COMMON_DIR=$(git rev-parse --git-common-dir)

          if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ]; then
            echo "Current directory is a Git worktree."
          else
            echo "Current directory is the main Git repository or not a worktree."
            return 0;
          fi
          DIR=$(basename "$(pwd)") 
          TMUX_WIN=$(tmux display-message -F '#W' -p)

          git worktree remove . -f

          if [ "$DIR" = "$TMUX_WIN" ]; then
              tmux kill-window
          fi
      }
    '';
  };
}