# | 🙑  dismint
# | YW5uaWUgPDM=

#  SECTION: yazi

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
    cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

#  SECTION: starship

function starship_transient_prompt_func
  starship module character
end
function starship_transient_rprompt_func
  starship module time
end

starship init fish | source
enable_transience

#  SECTION: eza

alias ls eza
alias lsa "eza -a"

#  SECTION: zoxide

zoxide init fish | source
alias cd z

#  SECTION: fzf

fzf --fish | source
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS
  --color=fg:-1,fg+:#8EA4A2,bg:-1,bg+:#393836
  --color=hl:#658594,hl+:#658594,info:#afaf87,marker:#b7d0ae
  --color=prompt:#658594,spinner:#8EA4A2,pointer:#C4B28A,header:#87afaf
  --color=border:#393836,label:#aeaeae,query:#d9d9d9
  --border=rounded --border-label= --preview-window=border-rounded --prompt='> '
  --marker='>' --pointer='◆' --separator='─' --scrollbar='│'"

#  SECTION: functions

function simg
    if test (count $argv) -eq 0
        echo "needs filename"
        return 1
    end
    set filename $argv[1]

    wl-paste -t image/png > $filename.png
end

function fish_greeting
end

function nixup
    sudo nixos-rebuild switch --flake /etc/nixos#dismint
end
function nixedit
    sudoedit /etc/nixos/flake.nix
end

#  SECTION: sets

set -gx BROWSER google-chrome-stable
set -gx EDITOR nvim

#  SECTION: theme

set --global fish_color_autosuggestion '#515c74'
set --global fish_color_cancel '#ff0000'
set --global fish_color_command '#84ab89'
set --global fish_color_comment '#5b606a'
set --global fish_color_end '#3e5587'
set --global fish_color_error '#ab8484'
set --global fish_color_escape '#ff0000'
set --global fish_color_history_current --bold
set --global fish_color_host '#ff0000'
set --global fish_color_operator '#84ab89'
set --global fish_color_option '#3e5587'
set --global fish_color_param '#3e5587'
set --global fish_color_quote '#3e5587'
set --global fish_color_redirection '#ff0000'
set --global fish_color_search_match '#ff0000'
set --global fish_color_selection '#ff0000' --bold --background=brblack
set --global fish_color_valid_path --underline
set --global fish_pager_color_completion normal
set --global fish_pager_color_description '#3e5587' -i
set --global fish_pager_color_prefix normal --bold --underline
set --global fish_pager_color_progress '--background=#3e5587' '#d3d9b2'
set --global fish_pager_color_selected_background -r
