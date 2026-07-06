autoload -U colors && colors
setopt prompt_subst

function parse_git_status() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        echo " %B%F{red}(${branch}*)%b%f"
    else
        echo " %{$fg_bold[green]%}(${branch})%b%f"
    fi
}

local user_info="%B%F{red}[%{$fg_bold[green]%}@henntaiiz%B%F{red}@%{$fg_bold[white]%}termux%B%F{red}]"
local current_dir="%B%F{red}[%{$fg_bold[cyan]%}%(5~|%-1~/…/%2~|%4~)%B%F{red}]"
local git_info='$(parse_git_status)'
local status_arrow="%(?.%{$fg_bold[green]%}❯❯❯.%B%F{red}❯❯❯)"

PROMPT="
%B%F{red}╭─༺✧༻─${user_info}─${current_dir}${git_info}
%B%F{red}╰─༺✧༻─ ${status_arrow} %b%f"
