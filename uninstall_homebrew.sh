#!/bin/bash

function abort {
    # Echo error message in red
    echo -e "\033[0;34m$1\033[0m\n"
    exit 1
}


echo_with_color() {
    case $2 in
        blue)
            echo -e "\033[0;34m$1\033[0m"
            ;;
        *)
            echo -e $1
            ;;
    esac
}


/usr/bin/which -s git || abort "brew install git first!"

if [[ -x /usr/local/bin/brew ]]; then
    BREW_PREFIX=`brew --prefix`
else
    BREW_PREFIX="/usr/local"
fi

cd ${BREW_PREFIX}

[[ -d ${BREW_PREFIX}/.git ]] && git checkout master && git ls-files -z | pbcopy

echo_with_color "\nRemoving ${BREW_PREFIX}/Cellar..." "blue"
rm -rf Cellar 2> /dev/null
[[ -x /usr/local/bin/brew ]] && brew prune

echo_with_color "\nRemoving Homebrew formulae..." "blue"
[[ -f "$(pbpaste | xargs -0 echo)" ]] && pbpaste | xargs -0 rm

echo_with_color "\nRemoving Library/Homebrew Library/Aliases Library/Formula Library/Contributions Library/LinkedKegs Library/Taps" "blue"
rm -fr Library/Homebrew Library/Aliases Library/Formula Library/Contributions Library/LinkedKegs Library/Taps 2> /dev/null

echo_with_color "\nRemoving bin Library share/man/man1 if they are empty" "blue"
rmdir -p bin Library share/man/man1 2> /dev/null

echo_with_color "\nRemoving ${BREW_PREFIX}/.git and ${BREW_PREFIX}/bin/brew" "blue"
rm -fr .git bin/brew 2> /dev/null

echo_with_color "\nRemoving ~/Library/Caches/Homebrew, ~/Library/Logs/Homebrew, /Library/Caches/Homebrew" "blue"
rm -rf ~/Library/Caches/Homebrew ~/Library/Logs/Homebrew /Library/Caches/Homebrew 2> /dev/null

echo_with_color "Homebrew uninstalled!" "blue"
=======
#!/usr/bin/env bash
#
# Uninstalls Homebrew


function cecho() {
    case ${2} in
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
    sleep 2
}


function die() {
    cecho "Error: ${1}" red
    exit 1
}


/usr/bin/which -s git || die "brew install git first!"

if [ -x /usr/local/bin/brew ]; then
    brewPrefix=$(brew --prefix)
else
    die "I don't know where Homebrew is installed!"
fi

cd ${brewPrefix}

[ -d ${brewPrefix}/.git ] && git checkout master && git ls-files -z | pbcopy

notify "Removing ${brewPrefix}/Cellar..."
rm -rf Cellar 2> /dev/null
[ -x /usr/local/bin/brew ] && brew prune

notify "Removing Homebrew formulae..."
[ -f "$(pbpaste | xargs -0 echo)" ] && pbpaste | xargs -0 rm

notify "Removing Library/Homebrew Library/Aliases Library/Formula Library/Contributions Library/LinkedKegs Library/Taps"
rm -fr Library/Homebrew Library/Aliases Library/Formula Library/Contributions Library/LinkedKegs Library/Taps 2> /dev/null

notify "Removing bin Library share/man/man1 if they are empty"
rmdir -p bin Library share/man/man1 2> /dev/null

notify "Removing ${brewPrefix}/.git and ${brewPrefix}/bin/brew"
rm -fr .git bin/brew 2> /dev/null

notify "Removing ~/Library/Caches/Homebrew, ~/Library/Logs/Homebrew, /Library/Caches/Homebrew"
rm -rf ~/Library/Caches/Homebrew ~/Library/Logs/Homebrew /Library/Caches/Homebrew 2> /dev/null

notify "Homebrew uninstalled!"
