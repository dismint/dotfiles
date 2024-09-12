# | 🙑  dismint
# | YW5uaWUgPDM=

function fish_greeting
end

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

alias cd z
