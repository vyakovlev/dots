if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent lazy yes

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 20
HIST_STAMPS="dd.mm.yyyy"
plugins=(ansible brew direnv docker docker-compose fzf git helm k9s kubectl kubectx ssh-agent uv)

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -r ~/work.sh ]]; then
  # define protected vars
  source ~/work.sh
fi

##### custom OS settings
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  eval `dircolors ~/.dircolors/linux`
  alias ls='ls --color=auto'
  alias ll='ls -al --color=auto'
  alias lt='ls --color=auto -ltrh'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  HB_PATHS="/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-indent/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-indent/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/gawk/libexec/gnubin:/opt/homebrew/bin/python3:/opt/homebrew/opt/socket_vmnet/bin:/opt/homebrew/opt/bc/bin:/opt/homebrew/opt/libpq/bin"
  export PATH="$HB_PATHS:$PATH"
  export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  if [ -d "${USER}/mws/bin" ]; then
    export PATH="${PATH}:${USER}/mws/bin"
  fi
  if [ -f /opt/homebrew/bin/terraform ]; then
    complete -o nospace -C /opt/homebrew/bin/terraform terraform
  fi
  eval $(gdircolors ~/.dircolors/dircolors.ansi-dark)
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
  alias ss='lsof -Pi -n -Ts'  # make ss-like output on macos
  alias ll='gls -al --color=auto'
  alias ls='gls --color=auto'
  alias lt='gls --color=auto -ltrh'
fi
##### end custom OS settings


##### exports
export EDITOR=vim
export K9S_CONFIG_DIR="${USER}/k9s"
export KUBE_EDITOR=vim
export LANG=en_US.UTF-8
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
##### end exports


##### misc
autoload -U +X bashcompinit && bashcompinit

if which minikube >/dev/null 2>&1; then
  source =(minikube completion zsh)
fi

if which k9s >/dev/null 2>&1; then
  source =(k9s completion zsh)
fi

if which fzf >/dev/null 2>&1; then
  source =(fzf --zsh)
fi
##### end misc


##### functions
function get_main(){
  # gets a master branch from master or main
  git branch --list master main | grep -Eo 'm[a-z]+'
}

funtion clean_switch(){
  # returns to master branch and cleans orphan / obsolete branches after a MR has been passed
  local main_branch="$(git branch --list master main | grep -Eo 'm[a-z]+')"
  git checkout "${main_branch}"
  git pull
  git remote update origin --prune
  git remote prune origin
  git branch --merged | grep -vP "${main_branch}" | xargs git branch -d
}

function make_mr(){
  # creates a MR on gitlab: source branch should be deleted, auto-assign to my colleagues
  local extra=$1
  # run with --force to force-push
  git push ${extra} -o merge_request.create -o merge_request.should_remove_source_branch \
    -o merge_request.description="/assign_reviewer  @teldekov @msyakuni @glysov @dodanil2 @botanik @vamishnin @kisarin"
}

function gen_passwd(){
  # generates a simple random password
  python3 -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
}

function set_proxy(){
  # sets proxy for console utilities to either default or passed as argument
  # run examples:
  # set_proxy
  # set_proxy http://localhost:3128
  local p="$1"
  local proxy="socks://127.0.0.1:10808"
  [[ $p =~ :// ]] && proxy="$p"
  echo "Setting proxy to ${proxy}"
  export http_proxy=${proxy} \
      HTTP_PROXY=${proxy} \
      https_proxy=${proxy} \
      HTTPS_PROXY=${proxy}
}

function tmux_send_all(){
  # sends a command to all tmux panes (e.g. git pull or source ~/.zshrc)
  # example: tmux_send_all source ~/.zshrc
  tmux list-panes -a | cut -d' ' -f1 | cut -d: -f1,2 | xargs -I PANE tmux send-keys -t PANE "$*" ENTER
}

function glall(){
  # gl (git pull alias from oh-my-zsh) + all (everywhere for faster typing)
  # updates code in all panes that are in git projects (cwd has .git)
  tmux_send_all "bash -c 'echo Pulling code if a git project; [[ -d .git ]] && git pull'"
}
###### end functions


##### aliases
alias less='less -iR'  # always ignore case & show colored output
alias m='minikube'
alias t='tmux a -t'  # easy attach to a tmux session, autocompletion works
alias tmp='cd ~/projects/personnal/tmp'  # my default tmp dir
alias vy='cd ~/projects/vyakovlev'  # my default user dir
##### end aliases

# allows to run commands on setting load without raising p10k errors
typeset -aU precmd_functions
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
