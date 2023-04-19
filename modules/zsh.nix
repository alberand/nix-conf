{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    enableAutosuggestions = true;
    plugins = [ ];

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

# User configuration
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:$PATH"

if [ -f ~/.shrc.local ]; then
    . ~/.shrc.local
fi

# Run Xorg on tty0 automatically
# if [ -z "\$\{DISPLAY\}" ] && [ "\$\{XDG_VTNR\}" -eq 1 ]; then
if [[ "$(tty)" == /dev/tty1 ]]; then
    exec sway
fi
    '';
  };
}
