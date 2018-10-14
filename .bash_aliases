source ~/.localbashrc
#************Custom Functions************************
cdClearList(){
	cd "$@" ;
	clear;
	ls -CFG;
}

#************Custom Misc Aliases************************
alias ls='ls -CFG'
alias ll='ls -lhA'
alias lg='ls -CAFG'
alias lsl='ls -lhFA | less'
alias cls='clear; ls -AFG;'
alias bashrc='vim ~/.bashrc'
alias bashrcR='. ~/.bashrc'
alias vimrc='vim ~/.vimrc'
alias tmuxconf='vim ~/.tmux.conf'
alias tmuxconfR='tmux source-file ~/.tmux.conf'

#Custom scripts
alias cdls=cdClearList


#************Docker Aliases************************
alias ctf='~/github/CTFDock/run'
alias ctfedit='vim ~/github/CTFDock/Dockerfile'
alias ctfbuild='vim ~/github/CTFDock/Dockerfile; cd ~/github/CTFDock/; ./build; cd -'

#************CD Aliases************************

#************Open Aliases************************

#************Typo Aliases************************
alias sl='ls'
alias ..='cd ..'
alias cd..='cd ..'

#************Exporting to Path*********************

#************Exporting Variables*******************
#export TERM=xterm

