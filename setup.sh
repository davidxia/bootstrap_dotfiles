#!/usr/bin/env bash
#
# bash -c "$(curl -fsSL https://raw.github.com/davidxia/bootstrap_dotfiles/master/setup.sh)"
#
#
# Aptitude packages:
# autojump - fast directory navigation
# build-essential - for GCC, GNU Make, etc.
# curl - obviously
# exuberant-ctags - for Vim Tagbar
# git - obviously
# tmux - terminal multiplexer
# vim-nox - Vim compiled with support for scripting with Perl, Python, Ruby, and Tcl
# zsh - best shell evar
#
#
# Homebrew packages:
#
#
#
# Pip packges:
# ipython -
# virtualenv -


aptitude="aptitude"
squeezePkgs="build-essential cmake curl exuberant-ctags git tmux vim-nox zsh"
precisePkgs="autojump build-essential cmake curl exuberant-ctags git tmux vim-nox zsh"
brews="ack autojump cmake cmatrix cowsay ctags fortune ifstat libevent libmpdclient mercurial netcat tor wget xz"


scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function cecho() {
    case "${2}" in
        red) code=31;;
        green) code=32;;
        yellow) code=33;;
        blue) code=34;;
        purple) code=35;;
        cyan) code=36;;
        white) code=37;;
        *) code=1;;
    esac
    printf "\n\e[0;${code}m${1}\e[0m\n"
}


function notify() {
    cecho "${1}" cyan
    sleep 1
}


function ask() {
    cecho "${1}" yellow
}


function pause() {
    read -p "$*"
}


function error() {
    cecho "${1}" red
    sleep 1
}


function die() {
    cecho "Error: ${1}" red
    exit 1
}


function backup() {
    for arg in "$@"; do
        if [ -e ${arg} -o -h ${arg} ]; then
            notify "Backing up existing ${arg} to ${arg}.bak"
            rm -fr ${arg}.bak && mv ${arg} ${arg}.bak
        fi
        sleep 1
    done
}


function askYesNo() {
    ask "Do you want to ${1} ${2}?"
    select ynq in "yes" "no" "quit"; do
        case ${ynq} in
            yes) shouldInstall=true; break;;
            no) shouldInstall=false; break;;
            quit) exit;;
        esac
    done
}


function aptInstall() {
    case "${1}" in
        precise) aptPkgs="${precisePkgs}";;
        squeeze) aptPkgs="${squeezePkgs}";;
        *) ;;
    esac

    askYesNo "install" "aptitude packages: ${aptPkgs}"
    if ${shouldInstall}; then
        ask "We'll need your password:"
        sudo ${aptitude} install ${aptPkgs}

        if [ "${1}" == "precise" ]; then
            notify "Downloading the patched Monaco font for zsh's powerline theme"
            mkdir ~/.fonts && git clone https://github.com/scotu/ubuntu-mono-powerline.git ~/.fonts/
        fi
    fi

    configureAutojump
}


function installHomebrew() {
    if [ ! -x /usr/local/bin/brew ]; then
        askYesNo "install" "Homebrew"
        if ${shouldInstall}; then
            printf "\n"
            printf "\e[0;32m"'    __  __                     __                     '"\e[0m\n"
            printf "\e[0;32m"'   / / / /___  ____ ___  ___  / /_  ________ _      __'"\e[0m\n"
            printf "\e[0;32m"'  / /_/ / __ \/ __ `__ \/ _ \/ __ \/ ___/ _ \ | /| / /'"\e[0m\n"
            printf "\e[0;32m"' / __  / /_/ / / / / / /  __/ /_/ / /  /  __/ |/ |/ / '"\e[0m\n"
            printf "\e[0;32m"'/_/ /_/\____/_/ /_/ /_/\___/_.___/_/   \___/|__/|__/  '"\e[0m\n\n"

            notify "Installing Homebrew"
            ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
        fi
    else
        notify "Updating Homebrew and formulae"
        brew update
    fi
}


function installBrews() {
    if brewLoc="$(which brew)" && [ ! -z "${brewLoc}" ]; then
        installedBrews=$(brew list)
        missingBrews=""

        # Create string of missing Homebrew formulae
        for formula in ${brews}; do
            test "${installedBrews#*$formula}" == "${installedBrews}" && ${missingBrews}="${missingBrews} ${formula}"
        done

        if [ ! "${missingBrews}" == "" ]; then
            askYesNo "install" "Homebrew packages: ${missingBrews}"
            if ${shouldInstall}; then
                brew install ${missingBrews}
            fi
        fi

        configureAutojump
    else
        error "${brewLoc} is not executable"
    fi
}


function configureZsh() {
    askYesNo "install" "oh-my-zsh"
    if ${shouldInstall}; then
        notify "Installing oh-my-zsh!"
        bash -c "$(curl -fsSL https://github.com/davidxia/oh-my-zsh/raw/master/tools/install.sh)"
    fi
}


function configureTmux() {
    askYesNo "configure" "tmux"
    if ${shouldInstall}; then
        printf "\n"
        printf "\e[0;32m"'   __                                       '"\e[0m\n"
        printf "\e[0;32m"'  /  |                                      '"\e[0m\n"
        printf "\e[0;32m"' _$$ |_    _____  ____   __    __  __    __ '"\e[0m\n"
        printf "\e[0;32m"'/ $$   |  /     \/    \ /  |  /  |/  \  /  |'"\e[0m\n"
        printf "\e[0;32m"'$$$$$$/   $$$$$$ $$$$  |$$ |  $$ |$$  \/$$/ '"\e[0m\n"
        printf "\e[0;32m"'  $$ | __ $$ | $$ | $$ |$$ |  $$ | $$  $$<  '"\e[0m\n"
        printf "\e[0;32m"'  $$ |/  |$$ | $$ | $$ |$$ \__$$ | /$$$$  \ '"\e[0m\n"
        printf "\e[0;32m"'  $$  $$/ $$ | $$ | $$ |$$    $$/ /$$/ $$  |'"\e[0m\n"
        printf "\e[0;32m"'   $$$$/  $$/  $$/  $$/  $$$$$$/  $$/   $$/ '"\e[0m\n\n"

        backup ~/.tmux.conf ~/.tmux-conf
        notify "Cloning David Xia's tmux conf and symlinking ~/.tmux.conf -> ~/.tmux-conf/tmux.conf"
        git clone https://github.com/davidxia/tmux-conf.git ~/.tmux-conf && \
            ln -s ~/.tmux-conf/tmux.conf ~/.tmux.conf
    fi
}


function installTmuxPowerline() {
    askYesNo "install" "tmux powerline"
    if ${shouldInstall}; then
        backup ~/.tmux-powerline && \
            git clone https://github.com/davidxia/tmux-powerline.git ~/.tmux-powerline && \
            ~/.tmux-powerline/./generate_rc.sh && mv ~/.tmux-powerlinerc.default ~/.tmux-powerlinerc
        pause "Your default tmux-powerlinerc is at ~/.tmux-powerlinerc. Edit it accordingly. \
            See https://github.com/davidxia/tmux-powerline."
    fi
}


function installTmuxPowerlineSegs() {
    if [ -d ~/.tmux-powerline ]; then
        askYesNo "install" "davidxia tmux-powerline theme"
        if ${shouldInstall}; then
            cd ~ && wget https://gist.github.com/davidxia/5271741/raw/ab29576b80154b95d07e45471a1b6a6a4bd2246b/davidxia.sh --output-document=.tmux-powerline/themes/davidxia.sh
        fi

        askYesNo "install" "tmux-mem-cpu-load"
        if ${shouldInstall} && cmake_loc="$(which cmake)" && [ ! -z "${cmake_loc}" ]; then
            rm -fr /tmp/tmux-mem-cpu-load && git clone https://github.com/thewtex/tmux-mem-cpu-load.git /tmp/tmux-mem-cpu-load && \
                cd /tmp/tmux-mem-cpu-load && cmake . && make && sudo make install && \
                rm -fr /tmp/tmux-mem-cpu-load
        fi
    fi
}


function configureVim() {
    askYesNo "configure" "vim"
    if ${shouldInstall}; then
        backup ~/.vim ~/.vimrc

        notify "Cloning David Xia's Vim config and symlinking ~/.vimrc -> ~/.vim/vimrc"
        git clone https://github.com/davidxia/vim-config.git ~/.vim && \
            cd ~/.vim && git submodule update --init bundle/vundle && cd ~ && \
            vim -u ~/.vim/bundles.vim +BundleInstall +qall && ln -s ~/.vim/vimrc ~/.vimrc
    fi
}


function configureGit() {
    askYesNo "configure" "git"
    if ${shouldInstall}; then
        printf "\n"
        printf "\e[0;32m"'        _ _   '"\e[0m\n"
        printf "\e[0;32m"'       (_) |  '"\e[0m\n"
        printf "\e[0;32m"'   __ _ _| |_ '"\e[0m\n"
        printf "\e[0;32m"'  / _` | | __|'"\e[0m\n"
        printf "\e[0;32m"' | (_| | | |_ '"\e[0m\n"
        printf "\e[0;32m"'  \__, |_|\__|'"\e[0m\n"
        printf "\e[0;32m"'   __/ |      '"\e[0m\n"
        printf "\e[0;32m"'  |___/       '"\e[0m\n\n"

        backup ~/.git-config ~/.gitconfig ~/.gitignore_global

        notify "Cloning David Xia's git-config"
        notify "Symlinking ~/.gitconfig -> ~/.git-config/gitconfig"
        notify "Symlinking ~/.gitignore_global -> ~/.git-config/gitignore_global"

        git clone https://github.com/davidxia/git-config.git ~/.git-config && \
            ln -s ~/.git-config/gitconfig ~/.gitconfig && \
            ln -s ~/.git-config/gitignore_global ~/.gitignore_global

        ask "Setting up git config\nWhat's your name?"
        read git_name
        git config --global user.name "${git_name}"
        ask "What's your email?"
        read git_email
        git config --global user.email "${git_email}"
        git config --list
        pause "Here's your global git config. You can edit this later anytime. Press [Enter] key to continue."
    fi
}


function configureAutojump() {
    askYesNo "configure" "autojump"
    if ${shouldInstall}; then
        notify "Configuring autojump"
        if [ "$(uname -s)" == "Darwin" ]; then
            echo "[ -f $(brew --prefix)/etc/autojump ] && . $(brew --prefix)/etc/autojump" \
                > ~/.oh-my-zsh/custom/autojump.zsh
        fi
    fi
}


function installPip() {
    if ! pip_loc="$(which pip)" || [ -z "${pip_loc}" ]; then
        askYesNo "install" "python distribute and pip"
        if ${shouldInstall}; then
            printf "\n"
            printf "\e[0;32m"'        _       '"\e[0m\n"
            printf "\e[0;32m"'       (_)      '"\e[0m\n"
            printf "\e[0;32m"'  _ __  _ _ __  '"\e[0m\n"
            printf "\e[0;32m"' | |_ \| | |_ \ '"\e[0m\n"
            printf "\e[0;32m"' | |_) | | |_) |'"\e[0m\n"
            printf "\e[0;32m"' | .__/|_| .__/ '"\e[0m\n"
            printf "\e[0;32m"' | |     | |    '"\e[0m\n"
            printf "\e[0;32m"' |_|     |_|    '"\e[0m\n\n"

            notify "Installing python distribute and pip"
            cd ~ && curl http://python-distribute.org/distribute_setup.py | sudo python && \
                curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | sudo python
        fi
    fi
}


function installPipPkgs() {
    pipPkgs="ipython virtualenv virtualenvwrapper"

    askYesNo "install" "pip packages: ${pipPkgs}"
    if ${shouldInstall}; then
        if pipLoc="$(which pip)" && [ ! -z "${pipLoc}" ]; then
            notify "Installing pip packages: ${pipPkgs}"
            sudo pip install ${pipPkgs}
        fi
    fi

    configureVirtualenvwrapper
}


function configureVirtualenvwrapper() {
    askYesNo "configure" "virtualenvwrapper"
    if ${shouldInstall}; then
        notify "Configuring virtualenvwrapper"
        if [ "$(uname -s)" == "Darwin" ]; then
            echo "[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh" \
                > ~/.oh-my-zsh/custom/virtualenvwrapper.zsh
        fi
    fi
}


# Debian-based distributions
if [ -e /usr/bin/lsb_release ]; then
    distro=$(/usr/bin/lsb_release --codename --short)

    if [ "${distro}" != "precise" -a "${distro}" != "squeeze" ]; then
        die "unsupported distribution: ${distro}"
    fi

    aptInstall "${distro}"
fi;


# Mac OS X
[ "$(uname -s)" == "Darwin" ] && installHomebrew && installBrews


configureZsh
configureTmux
installTmuxPowerline
installTmuxPowerlineSegs
configureVim
configureGit
installPip
installPipPkgs
