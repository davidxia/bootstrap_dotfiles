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
