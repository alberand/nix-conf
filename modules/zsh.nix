{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "robbyrussell";
    };
    autosuggestion.enable = true;
    plugins = [];
    history = {
      ignoreDups = true;
      save = 50000;
      share = true;
      size = 50000;
    };

    initExtra = ''
      # Uncomment the following line to enable command auto-correction.
      ENABLE_CORRECTION="true"

      # Uncomment the following line to display red dots whilst waiting for completion.
      COMPLETION_WAITING_DOTS="true"

      # Without this zsh will echo entered command
      DISABLE_AUTO_TITLE="true"

      # Uncomment the following line if you want to change the command execution time
      # stamp shown in the history command output.
      # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
      HIST_STAMPS="dd.mm.yyyy"

      # Locale
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8
      export LANGUAGE=en_US.UTF-8

      # Fix slow tab completion for git
      __git_files () {
          _wanted files expl 'local files' _files
      }

      # Include secrets
      if [ $(hostname) = "thinky" ]; then
        if [ -f ~/.secrets/.sh.secrets ]; then
            . ~/.secrets/.sh.secrets
        else
            echo "[Warning] Can not find secrets. Will not be able to connect"
        fi
      fi

      with_passwords(){
          pwds=`gpg  --no-tty -qd ~/.secrets/email-passwords.sh.gpg`
          eval "$pwds"
          $@
      }

      # PDF Reader
      function pdfreader(){
        zathura "$1" >/dev/null 2>&1 &
      }

      # Image viewver
      function show_image(){
        feh "$1" >/dev/null 2>&1 &
      }

      # ex - archive extractor
      # usage: ex <file>
      function ex() {
          if [ -f $1 ] ; then
          case $1 in
              *.tar.bz2) tar xjf $1 ;;
              *.tar.gz) tar xzf $1 ;;
              *.tar.xz) tar xf $1 ;;
              *.bz2) bunzip2 $1 ;;
              *.rar) unrar x $1 ;;
              *.gz) gunzip $1 ;;
              *.tar) tar xf $1 ;;
              *.tbz2) tar xjf $1 ;;
              *.tgz) tar xzf $1 ;;
              *.zip) unzip $1 ;;
              *.Z) uncompress $1;;
              *.7z) 7z x $1 ;;
              *) echo "'$1' cannot be extracted via ex()" ;;
          esac
          else
              echo "'$1' is not a valid file"
          fi
      }

      # pack - archive packager
      # usage: pack <file_1> <file_2> ...
      function pack() {
          bad=0

          for var in "$@"
          do
              # If argument is file or directory.
              if ! $( [ -f "$var" ] || [ -d "$var" ] ) ; then
                  echo "'$var' is not a valid file or directory."
                  bad=1
              fi
          done

          # If all entities are valid pack it.
          echo "Packed files:"
          if [ $bad -eq 0 ] ; then
              name=$(echo "$1" | cut -d'.' -f1)
              tar -cvzf "$name".tar "$@"
          fi
      }


      export TERM=screen-256color
      export VISUAL="nvim"
      export EDITOR="nvim"
      # Minicom colors
      export MINICOM="-m -c on"
      # Editor for cscope (by default it's vi)
      export CSCOPE_EDITOR=nvim
      # FZF with fd (make it possible to ignore files)
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"

      alias vim="nvim"
      alias cal='cal -m | grep --color -EC6 "\b$(date +%e | sed "s/ //g")"'
      # Better zooming when feh is opened
      alias feh="feh --auto-zoom --scale-down"
      # Decrypt password for email apps
      alias mutt="with_passwords mutt"
      alias neomutt="with_passwords neomutt"
      alias mbsync="with_passwords mbsync"
      # Who thought that it's cool to use number in cli?
      alias bb=b4
      alias vimdiff="nvim -d"
      alias pdf=pdfreader
      alias img=show_image

      if [ -f ~/.shrc.local ]; then
          . ~/.shrc.local
      fi

      # Run Sway on tty0 automatically
      if [[ "$(tty)" == /dev/tty1 ]]; then
          exec sway
      fi
    '';
  };
}
