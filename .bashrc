#************Custom Functions************************
junkFunc(){
  for item in "$@" ;
		do if [ -d "$item" ];#directory
		then
			#echo "Trashing: $item" ;
			mv -i "$item" ~/.Trash/;
		elif [ -f "$item" ];#file
		then
			#echo "Trashing: $item" ;
			mv -i "$item" ~/.Trash/;
		else
			echo "$item is an unknown filetype"
		fi
  done;
}


#************Custom Tool Aliases************************
alias ..='cd ..'
alias cd..='cd ..'
alias ls='ls -CFG'
alias ll='ls -lhA'
alias lg='ls -CAFG'
alias lsl='ls -lhFA | less'
alias cls='clear; ls -AFG;'
alias cdls='cd "$@"; cls;'
alias bashrc='vim ~/.bashrc'
alias bashrcR='. ~/.bashrc'
alias vimrc='vim ~/.vimrc'
alias tmuxconf='vim ~/.tmux.conf'
alias tmuxconfR='tmux source-file ~/.tmux.conf'

#Custom scripts
alias junk=junkFunc
#alias rm=junkFunc

#SSH Aliases
alias mbe='ssh'
alias mars='ssh'
alias garage='ssh'

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

#************CD Aliases************************
alias RCOS='cd /Users/ladmin/Documents/cs/RCOS'
alias PERS='cd /Users/ladmin/Dropbox/PersonalProjects'

#************Open Aliases************************
alias vlc='open /Applications/VLC.app'
alias g++="/usr/local/Cellar/gcc/6.2.0/bin/g++-6"
alias gcc="/usr/local/Cellar/gcc/6.2.0/bin/gcc-6"
alias calc="/Applications/Calculator.app/contents/MacOS/Calculator &"

#************Typo Aliases************************
alias sl='ls'
alias atom.='atom .'

#************Exporting to Path*********************
export PATH="/usr/local/bin:${PATH}"
export PATH="/usr/local/Cellar/gcc/6.2.0/bin:${PATH}"

#************Exporting RCOS stuff****************
PATH=$PATH:/Users/ladmin/Documents/cs/RCOS/omnetpp-5.0/bin

#************Exporting Variabels*******************
export TERM=xterm

