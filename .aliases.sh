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
alias gcm='git c'
alias merge_master='echo merging to `git config branch.master.remote`/master; git fetch `git config branch.master.remote` master; git merge `git config branch.master.remote`/master --no-edit' 
alias rebase_master='echo rebasing to `git config branch.master.remote`/master; git fetch `git config branch.master.remote` master; git merge --rebase `git config branch.master.remote`/master' 
alias dist2master='git rev-list --count `git rev-parse --abbrev-ref HEAD`..`git config branch.master.remote`/master' 
alias upstream='git push -u `git config branch.master.remote` `git rev-parse --abbrev-ref HEAD`' 
alias poop='git stash pop'
                                                                                                                                  
