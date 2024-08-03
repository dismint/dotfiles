#if test -f ~/.bash_profile
#    source ~/.bash_profile; or true
#end

function fish_greeting
  echo (set_color "#8BA4B0")🙑  (set_color "#8A9A7B")dismint(set_color normal)
  echo (set_color "#8BA4B0")YW5uaWUgPDM=(set_color normal)
end

function ocamlrun
  set filename $argv[1]
  ocamlc -o $filename $filename.ml && ./$filename
end

# init / setup

eval (opam env)

zoxide init fish | source

# aliases

alias cd="z"

# tide configuration

# left prompt
set tide_left_prompt_items os pwd git newline character
# right prompt
set tide_right_prompt_items status time 
# character
set tide_character_color "#8A9A7B"
set tide_character_color_failure "#C4746E"
# os
set tide_os_color "#8BA4B0"
# pwd
set tide_pwd_color_dirs "#8EA4A2"
set tide_pwd_color_truncated_dirs "#A6A69C"
set tide_pwd_color_anchors "#7FB4CA"
# git
set tide_git_color_branch "#8A9A7B" 
set tide_git_color_staged "#87A987"
set tide_git_color_unstaged "#E6C384"
set tide_git_color_untracked "#C4746E"
# status
set tide_status_color "#8A9A7B"
set tide_status_color_failure "#C4746E"
# time
set tide_time_color "#8A9A7B"

# kanagawa-dragon color scheme

set foreground DCD7BA normal
set selection 2D4F67 brcyan
set comment 727169 brblack
set red C34043 red
set orange FF9E64 brred
set yellow C0A36E yellow
set green 76946A green
set purple 957FB8 magenta
set cyan 7AA89F cyan
set pink D27E99 brmagenta

set fish_color_normal $foreground
set fish_color_command $cyan
set fish_color_keyword $pink
set fish_color_quote $yellow
set fish_color_redirection $foreground
set fish_color_end $orange
set fish_color_error $red
set fish_color_param $purple
set fish_color_comment $comment
set fish_color_selection --background=$selection
set fish_color_search_match --background=$selection
set fish_color_operator $green
set fish_color_escape $pink
set fish_color_autosuggestion $comment

set fish_pager_color_progress $comment
set fish_pager_color_prefix $cyan
set fish_pager_color_completion $foreground
set fish_pager_color_description $comment

