if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode disabled  # disable automatic updates
HIST_STAMPS="dd.mm.yyyy"
plugins=(git ansible brew docker docker-compose helm k9s kubectl kubectx fzf)

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


##### custom OS settings
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  eval `dircolors ~/.dircolors`
elif [[ "$OSTYPE" == "darwin"* ]]; then
  HB_PATHS="/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-indent/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-indent/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/gawk/libexec/gnubin:/opt/homebrew/bin/python3:/opt/homebrew/opt/socket_vmnet/bin:/opt/homebrew/opt/bc/bin:/opt/homebrew/opt/libpq/bin"
  export PATH="$HB_PATHS:$PATH"
  export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  export GOPRIVATE=git.dev.cloud.mts.ru,git.mws-team.ru
  export GOPROXY=https://nexus.mws-team.ru/repository/golang-internal/
  export GONOPROXY=none
  export GOSUMDB="sum.golang.org https://nexus.mws-team.ru/repository/golang-sumdb/"
  export GONOSUMDB=git.dev.cloud.mts.ru/*,git.mws-team.ru/*
  if [ -d "${USER}/mws/bin" ]; then
    export PATH="${PATH}:${USER}/mws/bin"
  fi
  if [ -f "${USER}/mws/completion/devscan_completion.zsh.inc" ]; then
    source "${USER}/mws/completion/devscan_completion.zsh.inc"
  fi
  if [ -f /opt/homebrew/bin/terraform ]; then
    complete -o nospace -C /opt/homebrew/bin/terraform terraform
  fi
  eval $(gdircolors ~/.dircolors/dircolors.ansi-dark)
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
  alias sdf='cd ~/projects/git.mws-team.ru/infra/sdf'
  alias ss='lsof -Pi -n -Ts'
fi
##### end custom OS settings


##### exports
export EDITOR=vim
export K9S_CONFIG_DIR="${USER}/k9s"
export KUBE_EDITOR=vim
export LANG=en_US.UTF-8
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
##### end exports


autoload -U +X bashcompinit && bashcompinit
source =(minikube completion zsh)
source <(fzf --zsh)


##### functions
function get_main(){
  git branch --list master main | grep -Eo 'm[a-z]+'
}

funtion clean_switch(){
  local main_branch="$(git branch --list master main | grep -Eo 'm[a-z]+')"
  git checkout "${main_branch}"
  git pull
  git remote update origin --prune
  git remote prune origin
  git branch --merged | grep -vP "${main_branch}" | xargs git branch -d
}

function make_mr(){
  local extra=$1
  # run with --force to force-push
  git push ${extra} -o merge_request.create -o merge_request.should_remove_source_branch \
    -o merge_request.description="/assign_reviewer  @teldekov @msyakuni @glysov @dodanil2 @botanik @vamishnin @kisarin"
}

function gen_passwd(){
  python3 -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
}
###### end functions


##### aliases
alias less='less -iR'
alias ll='ls -al'
alias ls='gls --color=auto'
alias m='minikube'
alias t='tmux a -t'
alias tmp='cd ~/projects/personnal/tmp'
##### end aliases
