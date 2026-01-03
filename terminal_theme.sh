# Optimized git prompt - runs git commands once and caches results

# Single function that gathers all git info efficiently
_git_prompt_info() {
    # Quick check if we're in a git repo
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    [[ "$(realpath "$git_dir" 2>/dev/null)" == "/.git" ]] && return

    # Get branch and ahead/behind in one call
    local branch_info="$(git status -sb 2>/dev/null | head -1)"
    local branch="$(echo "$branch_info" | sed 's/^## //' | sed 's/\.\.\..*//')"

    # Parse ahead/behind from status -sb (shows [ahead N, behind M])
    local ahead=0 behind=0
    # Extract the bracketed part if it exists
    local bracket_content="$(echo "$branch_info" | sed -n 's/.*\[\(.*\)\].*/\1/p')"
    if [[ -n "$bracket_content" ]]; then
        # Parse ahead count
        if [[ "$bracket_content" =~ ahead[[:space:]]+([0-9]+) ]]; then
            ahead="${match[1]}"
        fi
        # Parse behind count
        if [[ "$bracket_content" =~ behind[[:space:]]+([0-9]+) ]]; then
            behind="${match[1]}"
        fi
    fi

    # Get all status counts in ONE git status call
    local status_output="$(git status --porcelain 2>/dev/null)"
    local staged=0 unstaged=0 untracked=0
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local x="${line:0:1}"
        local y="${line:1:1}"
        [[ "$x" == "?" ]] && ((untracked++)) && continue
        [[ "$x" != " " && "$x" != "?" ]] && ((staged++))
        [[ "$y" != " " && "$y" != "?" ]] && ((unstaged++))
    done <<< "$status_output"

    # Build output
    echo "($branch)[+${ahead}-${behind}|S:${staged}|W:${unstaged}|U:${untracked}]"
}

_parse_relative_path() {
    if [[ "$PWD" == "$HOME" ]]; then
        echo "~"
    elif git rev-parse --is-inside-work-tree &>/dev/null; then
        local repo_name="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")"
        local relative_path="$(git rev-parse --show-prefix 2>/dev/null)"
        [[ -n "$relative_path" ]] && relative_path="/${relative_path%/}"
        echo "${repo_name}${relative_path}"
    else
        echo "${PWD##*/}"
    fi
}

_parse_docker_status() {
    [[ -n "${CONTAINER_NAME[$SESSION]}" ]] && echo "🐋 {${CONTAINER_NAME[$SESSION]}}"
}

# Enable prompt substitution for command execution in PS1
setopt PROMPT_SUBST

PS1='${debian_chroot:+($debian_chroot)}%{%F{14}%}$(_parse_relative_path) %{%F{177}%}$(_git_prompt_info)%{%F{green}%B%} [$(hostname)]%{%f%b%}
%{%F{green}%}➜%{%f%} '

# 🗿💠😮‍💨➜⛏📷🃏🎰🎱🎉🔥🌌🏕🍫🍪🍩🕷🐌🐧🐾🦔🐋🐬🍩
