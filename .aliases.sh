source ~/git/z/z.sh



set HISTSIZE=
set HISTFILESIZE=

alias bat='batcat --paging=never'

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"


alias ll='exa -1a'
alias l='exa -lah --git'
alias ls=exa
alias lt3='exa -lhT --level=3 --git'
alias lt='exa -lhT --level=2 --git'
alias lt4='exa -lhT --level=4 --git'

alias please='sudo'


# git shortcuts
alias g="git"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gss='git status -sb'
alias gs='git status'
alias g-='git checkout -'
alias gp='git push'
alias gcm='git checkout main'
alias merge_main='echo merging to `git config branch.main.remote`/main; git fetch `git config branch.main.remote` main; git merge `git config branch.main.remote`/main --no-edit'
alias rebase_main='echo rebasing to `git config branch.main.remote`/main; git fetch `git config branch.main.remote` main; git merge --rebase `git config branch.main.remote`/main'
alias dist2main='git rev-list --count `git rev-parse --abbrev-ref HEAD`..`git config branch.main.remote`/main'
alias upstream='git push -u `git config branch.main.remote` `git rev-parse --abbrev-ref HEAD`'
alias poop='git stash pop'

# Wayve
function wayvecli {
     bazel run --ui_event_filters=-info,-stdout,-stderr --noshow_progress //tools/wayvecli:wayvecli -- $@
}

alias acr='make acr-login'
alias pre_materialise='make acr-login; make -C /workspace/WayveCode/wayve/ai/si/materialisation publish-test'
train_parking() {
    if [ -z "$1" ]; then
        echo "Usage: train_parking <session_tag>"
        return 1
    fi
    mode="$1"
    session_tag="$2"
    cmd="bazel run //wayve/ai/si/cli:cli -- --no-verify --experiment parking --platform AKS --cluster dgx-h100 --num_nodes 4 --project parking --priority P1 +mode=$mode model.model.gear_direction_dropout_probability=0.1 --force --session_tag \"$session_tag\""
    echo "$cmd"
    eval $cmd
}

start_jupyter() {
    local token='moose-nugget-flame'
    local port=8888
    if curl --silent "http://localhost:${port}" | grep -qi 'login'; then
        echo "Jupyter is already running at http://localhost:${port}"
    else
        make acr-login
        bazel run //tools:jupyter_services -- --notebook-dir="$(pwd)" --NotebookApp.token="$token" --NotebookApp.password=''
    fi
}

alias claude-npm='npx @anthropic-ai/claude-code@latest'
alias codex-wayve='cd /workspace/WayveCode/ && bazel run //tools:codex -- --add-dir /home/borisindelman/git/assets/codex --cd /workspace/WayveCode/ --add-dir /home/borisindelman/git/vault --add-dir /workspace/WayveCode/ --add-dir /workspace/WayveCode/ /home/borisindelman/.codex --ask-for-approval on-failure --search '
alias codex-last='codex-wayve resume --last'
export CLAUDE_CONFIG_DIR=/workspace/WayveCode/.claude

# Wayve terminal logo (uv)
alias wayve-logo='cd /home/borisindelman/git/wayve_terminal_logo && uv run wayve-terminal-logo'
