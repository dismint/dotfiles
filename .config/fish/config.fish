# | 🙑  dismint
# | YW5uaWUgPDM=

function fish_greeting
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

function simg
    if test (count $argv) -eq 0
        echo "needs filename"
        return 1
    end
    set filename $argv[1]

    wl-paste -t image/png > $filename.png
end

# make somethign similar to the above function but it takes in an argument 

function starship_transient_prompt_func
  starship module character
end
function starship_transient_rprompt_func
  starship module time
end

starship init fish | source
enable_transience

zoxide init fish | source

alias ls eza
alias lsa "eza -a"

set -gx BROWSER google-chrome-stable

alias cd z
