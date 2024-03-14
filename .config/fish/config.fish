function fish_greeting
  # do nothing
end

function imgc
    if test (count $argv) -lt 1
        echo "USAGE: imgc <filename>"
        return 1
    end

    set filename $argv[1]
    wl-paste --type image/png | convert - $filename.png
    echo "RESULT: image saved as $filename".png
end


# init / setup

zoxide init fish | source

# aliases

alias cd="z"
alias ls="eza"

