{ pkgs, ... }:

{
	programs.tmux = {
		enable = true;
		clock24 = true;
		extraConfig = ''
# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Switch panes using Alt-arrow without prefix
bind l select-pane -L
bind h select-pane -R
bind k select-pane -U
bind j select-pane -D
		'';
	};
}
