#/bin/bash

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

BREWS="ack autojump cmatrix ctags wget"
DEB_PKGS="autojump build-essential curl exuberant-ctags git tmux vim-nox zsh"
LUCID_PKGS="build-essential curl exuberant-ctags git-core zsh"
PIP_PKGS="ipython virtualenv"

die() {
    echo "Error: $1"
    exit 1
}

aptitude() {
    echo "Installing aptitude packages: "

    DISTRO=$(lsb_release --codename --short)
    case ${DISTRO} in
        squeeze)
            APTITUDE="aptitude -t squeeze-backports"
            SUDO="sudo"
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
    if [[ "${DISTRO}" == "precise" ]]; then
        mkdir -p .fonts
        cd .fonts
        git clone https://github.com/scotu/ubuntu-mono-powerline.git
        cd ..
    fi
}

install_homebrew() {
    echo -e "Checking if homebrew is already installed..."
    if [[ -x /usr/local/bin/brew ]];
    then
        echo -e "Homebrew is already installed, skipping installation\n"
    else
        echo -e "Installing homebrew\n"
        ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
    fi
}

install_brew_pkgs() {
    echo -e "Installing homebrew packages: ${BREWS}\n"
    [[ -x /usr/local/bin/brew ]] && brew tap homebrew/dupes && brew install ${BREWS}
}

ohmyzsh() {
    echo -e "Making zsh default shell and cloning David Xia's oh-my-zsh\n"
    chsh -s /bin/zsh
    curl -L https://github.com/davidxia/oh-my-zsh/raw/master/tools/install.sh | sh
}

vimconfig() {
    echo -e "Cloning David Xia's vim-config and installing Vundle\n"
    git clone https://github.com/davidxia/vim-config.git ~/.vim
    # Vundle
    cd ~/.vim && git submodule update --init bundle/vundle
    vim +BundleInstall +qall
    ln -s ~/.vim/vimrc ~/.vimrc
}

gitconfig() {
    echo -e "Cloning David Xia's git-config\n"
    git clone https://github.com/davidxia/git-config.git ~/.git-config
    ln -s ~/.git-config/gitconfig ~/.gitconfig
    ln -s ~/.git-config/gitignore_global ~/.gitignore_global
}

# pip() {
# # PIP packages
# curl http://python-distribute.org/distribute_setup.py | ${SUDO} python
# curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | ${SUDO} python
# ${SUDO} pip install ${PIP_PKGS}
# }

[[ -f /usr/bin/lsb_release ]] && aptitude
# [[ "$(uname -s)" == "Darwin" ]] && install_homebrew && install_brew_pkgs
# ohmyzsh
# vimconfig
gitconfig
# pip

cd ${cwd}
