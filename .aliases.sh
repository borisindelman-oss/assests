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

alias acr='make acr-login'

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
                                                                                                                                  
