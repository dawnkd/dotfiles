# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Your best friend of Git log graphs.
alias glog='git log --all --graph --pretty="format:%d %Cgreen%h%Creset %an - %s"'

# Terminal prompt helpers
# shorten a path in $1 to max of $2 characters, appending a "..."
shorten() {
    if [[ ${#1} -gt $2 ]]; then
        len=$((${#1}-$2))
        echo ${1:: -$len}
    else
        echo $1
    fi
}

get_reasonable_width() {
    w=$(tput cols)
    echo $(($w / 6))
}

# Terminal will show current Git branch when in a Git repo directory.
parse_git_branch() {
git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

split() {
IFS=$2 read -ra ADDR <<< $1
echo ${ADDR[$3]}
}

get_reasonable_path() {
p="$(dirs +0)"
if [[ $(get_reasonable_width) -lt ${#p} ]]; then
    # try to print current and parent dir
    shorter_p=".../"$(split $p / -2)"/"$(split $p / -1)
    if [[ ${#shorter_p} -lt $(get_reasonable_width) ]]; then
        echo $shorter_p
    else
        # try to print current dir
        shorter_p=".../"$(split $p / -1)
        if [[ $(get_reasonable_width) -lt ${#shorter_p} ]]; then
            # if path is still too long, shorten it more
            shorter_p="$(shorten $shorter_p $(($(get_reasonable_width) - 3)))..."
            if [[ ${#shorter_p} -lt 7 ]]; then
                # if path is shortened to just "......" don't print anything
                echo "..."
            else 
                echo $shorter_p
            fi
        else 
            echo ".../"$(split $p / -1)
        fi
    fi
else
    echo $p
fi
}

get_reasonable_git_branch() {
b="$(parse_git_branch)"
if [[ $(get_reasonable_width) -lt ${#b} ]]; then
    echo $(shorten $(split $b / -1) 7)
else
    echo $b
fi
}

get_reasonable_user_host() {
u=$(whoami)
h=$(hostname)
length=$((${#u} + ${#h} + 1))
if [[ $(get_reasonable_width) -lt $length ]]; then
    echo "...@... "
else
    echo $u@$h
fi
}

function virtualenv_info(){
    # Get Virtual Env
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        venv="${VIRTUAL_ENV##*/}"
        if [[ $(get_reasonable_width) -lt $((${#venv} * 2)) ]]; then
            width=$(($(get_reasonable_width) / 4))
            venv="$(shorten $venv $width)..."
        fi
    else
        # In case you don't have one activated
        venv=''
    fi
    [[ -n "$venv" ]] && echo "($venv) "
}

# disable the default virtualenv prompt change
export VIRTUAL_ENV_DISABLE_PROMPT=1

VENV="\$(virtualenv_info)";
# the '...' are for irrelevant info here.

# print full PS1 if nothing was shortened
ps1() {
    v=$(virtualenv_info)
    u=$(whoami)
    h=$(hostname)
    p=$(dirs +0)
    g=$(parse_git_branch)
    out="\e[33m$v\e[32;1m$u@$h: \e[34m$p\e[0m \e[91m$g\e[00m$ "
    echo -e $out
}

prompt='\e[33m$(virtualenv_info)\e[32;1m$(get_reasonable_user_host): \e[34m$(get_reasonable_path)\e[0m \[\e[91m\]$(get_reasonable_git_branch)\[\e[00m\]$ '
PS1=$prompt
 
# Useful after squashing several commits. Updates the current commit's timestamp to NOW.
alias commitnow='git commit --amend --no-edit --date "$(date)"'
 
# Occasionally, WSL will lose its connection to Windows. This will prevent that from
# happening by fixing the interop port everytime you open a new WSL TTY.
fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}
fix_wsl2_interop
alias win="cd /mnt/c/Users/david.dawnkaski"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# set DISPLAY variable to the IP automatically assigned to WSL2
# export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0

# sudo /etc/init.d/dbus start &> /dev/null

# THIS NEEDS TO BE WHATEVER WINDOWS WSL DISTRO IS NAMED
DOCKER_DISTRO=$WSL_DISTRO_NAME
DOCKER_DIR=/mnt/wsl/shared-docker
DOCKER_SOCK="$DOCKER_DIR/docker.sock"
export DOCKER_HOST="unix://$DOCKER_SOCK"

# if grep -q "microsoft" /proc/version > /dev/null 2>&1; then
#     if service docker status 2>&1 | grep -q "is not running"; then
#         wsl.exe --distribution "${WSL_DISTRO_NAME}" --user root \
#             --exec /usr/sbin/service docker start > /dev/null 2>&1
#     fi
# fi

if [ ! -S "$DOCKER_SOCK" ]; then
    mkdir -pm o=,ug=rwx "$DOCKER_DIR"
    chgrp docker "$DOCKER_DIR"
    wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
fi

re() {
PS1=$prompt
}

check_terminal_size() {
if [[ $COLUMNS != $previous_columns ]]; then
   re
fi
previous_lines=$LINES
previous_columns=$COLUMNS
}
trap 'check_terminal_size' WINCH

chom() {
    setfacl -R -d -m m::rx $1
    chmod -R g+s $1
}

# alias ui="cd ~/workspace/kronos/kronos-ui"
# alias api="cd ~/workspace/kronos/kronos-api"
alias pipenv="python3 -m pipenv"

export PATH=$PATH:/mnt/c/Program\ Files/Git/bin
export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:$(go env GOPATH)/bin"

export DISPLAY=:0

if [[ -z "$XDG_RUNTIME_DIR" ]]; then
  export XDG_RUNTIME_DIR=/run/user/$UID
  if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    export XDG_RUNTIME_DIR=/tmp/$USER-runtime
    if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
      mkdir -m 0700 "$XDG_RUNTIME_DIR"
    fi
  fi
fi

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

alias dps="docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}'"

export NVM_DIR="/home/yourusername/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

eval "$(oh-my-posh init bash --config ~/.david.omp.yaml)"
function set_poshcontext() {
    export POSH=$(date)
    export COLS=$(tput cols)
    export R_COLS=$(get_reasonable_width)
    export USER_HOST=$(get_reasonable_user_host)
    export GIT_BRANCH=$(get_reasonable_git_branch)
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
. "$HOME/.cargo/env"
