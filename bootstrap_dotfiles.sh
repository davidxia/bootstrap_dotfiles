#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/davidxia/bootstrap_dotfiles/master/bootstrap_dotfiles.sh)"

# Debian package dependencies:
# build-essential - for GCC, GNU Make, etc.
# curl - obviously
# exuberant-ctags - for Vim Tagbar
# git - obviously
# tmux - obviously
# vim-nox - Vim with python and ruby support
# zsh - obviously

# PIP dependencies:
# distribute, pip
# ipython, virtualenv


BREWS="ack autojump cmatrix ctags homebrew/dupes/vim wget"
DEB_PKGS="autojump build-essential curl exuberant-ctags git tmux vim-nox zsh"
LUCID_PKGS="build-essential curl exuberant-ctags git-core zsh"
PIP_PKGS="ipython virtualenv virtualenvwrapper"
SUDO="sudo"


function die {
    echo "Error: $1"
    exit 1
}


function echo_with_color {
    case $2 in
        blue)
            echo -e "\033[0;34m$1\033[0m"
            ;;
        *)
            echo -e $1
            ;;
    esac
}


function install_apt_pkgs {
    echo "Installing aptitude packages: "

    DISTRO=$(lsb_release --codename --short)
    case ${DISTRO} in
        squeeze)
            APTITUDE="aptitude -t squeeze-backports"
            PKGS=${DEB_PKGS}
            ;;
        precise)
            APTITUDE="aptitude"

            # personal system, make /usr/local personal and bypass sudo
            SUDO=""
            sudo mv /usr/local /usr/local.orig
            sudo mkdir /usr/local
            sudo chown $(whoami):$(groups | awk '{print $1}') /usr/local
            PKGS=${DEB_PKGS}
            ;;
        lucid)
            APTITUDE="aptitude"
            PKGS=${LUCID_PKGS}
            ;;
        *)
            die "unsupported distribution: ${DISTRO}"
            ;;
    esac

    echo -e "${PKGS}\n"
    sudo ${APTITUDE} install ${PKGS}

    # custom fonts for vim-powerline
    if [ "${DISTRO}" = "precise" ]; then
        mkdir -p .fonts
        cd .fonts
        git clone https://github.com/scotu/ubuntu-mono-powerline.git
        cd ..
    fi
}


function install_homebrew {
    echo_with_color "Checking if homebrew is already installed..." "blue"
    if [ -x /usr/local/bin/brew ]; then
        echo_with_color "Homebrew is already installed, skipping installation\n" "blue"
    else
        echo_with_color "Installing homebrew\n" "blue"
        ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
    fi
}


function install_brew_pkgs {
    echo_with_color "Installing homebrew packages: ${BREWS}\n" "blue"
    [ -x /usr/local/bin/brew ] && brew tap homebrew/dupes && brew install ${BREWS}
}


function configure_zsh {
    echo_with_color "Making zsh default shell and cloning David Xia's oh-my-zsh\n" "blue"
    curl -L https://github.com/davidxia/oh-my-zsh/raw/master/tools/install.sh | sh
    /bin/zsh && source ~/.zshrc
}


function configure_vim {
    echo_with_color "Checking if ~/.vim exists..." "blue"
    if [ -d ~/.vim ]; then
        echo_with_color "~/.vim directory already exists. Moving to ~/.vim.bak" "blue"
        rm -fr ~/.vim.bak && mv ~/.vim ~/.vim.bak
    fi
    echo_with_color "Cloning David Xia's vim-config and installing Vundle as submodule\n" "blue"
    git clone https://github.com/davidxia/vim-config.git ~/.vim
    cd ~/.vim && git submodule update --init bundle/vundle && cd ~
    vim -u bundles.vim +BundleInstall +q

    echo_with_color "\nChecking if ~/.vimrc exists..." "blue"
    if [ -e ~/.vimrc ]; then
        echo_with_color "~/.vimrc already exists. Moving to ~/.vimrc.bak" "blue"
        rm -fr ~/.vim.bak && mv ~/.vimrc ~/.vimrc.bak
    fi
    echo_with_color "Creating symlink ~/.vimrc -> ~/.vim/vimrc\n" "blue"
    ln -s ~/.vim/vimrc ~/.vimrc
}


function configure_git {
    echo_with_color "Checking if ~/.git-config exists..." "blue"
    if [ -d ~/.git-config ]; then
        echo_with_color "~/.git-config directory already exists. Moving to ~/.git-config.bak" "blue"
        rm -fr ~/.git-config.bak && mv ~/.git-config ~/.git-config.bak
    fi
    echo_with_color "Cloning David Xia's git-config\n" "blue"
    git clone https://github.com/davidxia/git-config.git ~/.git-config

    echo_with_color "\nChecking if ~/.gitconfig exists..." "blue"
    if [ -e ~/.gitconfig ]; then
        echo_with_color "~/.gitconfig already exists. Moving to ~/.gitconfig.bak" "blue"
        rm -fr ~/.gitconfig.bak && mv ~/.gitconfig ~/.gitconfig.bak
    fi
    echo_with_color "Creating symlink ~/.gitconfig -> ~/.git-config/gitconfig\n" "blue"
    ln -s ~/.git-config/gitconfig ~/.gitconfig

    echo_with_color "Checking if ~/.gitignore_global exists..." "blue"
    if [ -e ~/.gitignore_global ]; then
        echo_with_color "~/.gitignore_global already exists. Moving to ~/.gitignore_global.bak" "blue"
        mv ~/.gitignore_global ~/.gitignore_global.bak
    fi
    echo_with_color "Creating symlink ~/.gitignore_global -> ~/.git-config/gitignore_global\n" "blue"
    ln -s ~/.git-config/gitignore_global ~/.gitignore_global
}


function configure_autojump {
    echo_with_color "\nConfiguring autojump" "blue"
    echo "if [ -f $(brew --prefix)/etc/autojump ]; then
              . $(brew --prefix)/etc/autojump
          fi" > ~/.oh-my-zsh/custom/autojump.zsh
}


function install_pip {
    echo_with_color "\nInstalling python distribute and pip" "blue"
    curl http://python-distribute.org/distribute_setup.py | ${SUDO} python
    curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | ${SUDO} python
}


function install_pip_packages {
    echo_with_color "\nInstalling pip packages: ${PIP_PKGS}" "blue"
    ${SUDO} pip install ${PIP_PKGS}
}


function configure_virtualenvwrapper {
    echo_with_color "\nConfiguring virtualenvwrapper" "blue"
    echo "source /usr/local/bin/virtualenvwrapper.sh" > ~/.oh-my-zsh/custom/virtualenvwrapper.zsh
}


[ -f /usr/bin/lsb_release ] && install_apt_pkgs

[ "$(uname -s)" == "Darwin" ] && install_homebrew
[ -x /usr/local/bin/brew ] && install_brew_pkgs

configure_vim
configure_git
configure_autojump
configure_zsh
install_pip
install_pip_packages
configure_virtualenvwrapper
