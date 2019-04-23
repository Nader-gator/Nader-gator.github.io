sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
if [ -e ~/.cfg ]; then
    echo "Move .cfg file somewhere safe and try again"
    exit 0
fi
which -s brew
if [[ $? != 0 ]] ; then
    echo -ne '\n' | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi
brew install ctags git neovim the_silver_searcher vim
git clone --bare https://github.com/Nader-gator/dotfiles.git $HOME/.cfg
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
if [ $? = 0 ]; then
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
echo 'for file in ~/.config-backup/.*
do rm -rf ~/${file##*/} > /dev/null 2>&1
done
cp -a ~/.config-backup/.* ~/ > /dev/null 2>&1
rm -rf ~/.config-backup
rm ~/uninstall.sh' >> ~/.config-backup/uninstall.sh
chmod +x ~/.config-backup/uninstall.sh
echo 'copying fonts'
mv ~/.MesloFonts.otf ~/Library/Fonts/MesloLGLDZRegularNerdFontComplete.otf
echo -e "\033[1;31m All done \033[0m"
