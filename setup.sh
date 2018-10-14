#!/usr/bin/env bash
DOTFILES_DIR="$(dirname "$PWD/$0")"
TO_HOME="$DOTFILES_DIR"/homefiles.txt

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master

! [ -d "$DOTFILES_DIR"/backups ] && mkdir $DOTFILES_DIR/backups
! [ -d ~/.vim ] && mkdir ~/.vim
! [ -d ~/.vim/undodir ] && mkdir ~/.vim/undodir

for fn in $(cat "$TO_HOME")
do
	[ -e ~/$fn ] && [  ~/"$fn" -ef $DOTFILES_DIR/$fn ] && echo "$fn is already linked to $DOTFILES_DIR/$fn, skipping..." && continue
	if confirm "Take the new $fn [y/N]?"; then
		[ -e ~/$fn ] && echo "\tMoving file to backups" && mv -iv ~/"$fn" "$DOTFILES_DIR"/backups/"$fn"."$(date +%s)"
		echo "\tInstalling new $fn" && ln -sfv "$DOTFILES_DIR/$fn" ~
	fi
done
echo "Finished, please remember to add the appropriate aliases to the existing .*rc files. For example, \"alias ~/.bash_aliases\" into ~/.bashrc"
