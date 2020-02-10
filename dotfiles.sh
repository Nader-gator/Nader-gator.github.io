#!/bin/bash
install_homebrew(){
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        *)          machine=UNKNOWN;;
    esac
    case $machine in
        Mac) echo "installing homebrew for mac";
            mkdir homebrew && \
            curl -L https://github.com/Homebrew/brew/tarball/master \
            | tar xz --strip 1 -C homebrew;;
        Linux) echo "installing homebrew for linux";
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)";
            test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)";
            test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)";
            test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile;
            echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile;;
    esac
    echo "homebrew installed!"
}

PCKG_MNGR=$1
if [ -x "$(command -v "$PCKG_MNGR")" ] ; then
    echo "$PCKG_MNGR was found"
else
    while true; do
        read -r -p "$PCKG_MNGR not found, do you want brew? (y/n)" yn
        case $yn in
            [Yy] ) install_homebrew;PCKG_MNGR=brew;break;;
            [Nn] ) echo "bye!";exit 1;;
            * ) echo "give me a real answer"
        esac
    done
fi

$PCKG_MNGR install ctags git neovim the_silver_searcher vim
git clone --bare https://github.com/Nader-gator/dotfiles.git "$HOME"/.cfg
config() {
   /usr/bin/git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" "$@"
}
mkdir -p .config-backup
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
if config checkout; then
  echo "Checked out config.";
  else
    echo -e "\033[1mBacking up pre-existing dot files."
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mkdir -p .config-backup/{}
    find .config-backup -type d -exec rmdir {} + 2>/dev/null
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    echo -e "\033[1mDone backing up"
fi;
echo -e "\033[1mChecking out config files"
config checkout
config config status.showUntrackedFiles no
touch .config-backup/uninstall.sh
echo "for file in ~/.config-backup/.*
do rm -rf ~/${file##*/} > /dev/null 2>&1
done
cp -a ~/.config-backup/.* ~/ > /dev/null 2>&1
rm -rf ~/.config-backup
rm ~/uninstall.sh' >> ~/.config-backup/uninstall.sh
chmod +x ~/.config-backup/uninstall.sh
echo 'copying fonts"
mv ~/.MesloFonts.otf ~/Library/Fonts/MesloLGLDZRegularNerdFontComplete.otf
echo -e "\033[1;31m All done \033[0m"
