# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/ladmin/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="bira"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
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

#************Docker Aliases************************
alias ..='cd ..'
alias cd..='cd ..'
alias ls='ls -CFG'
alias ll='ls -lhA'
alias lg='ls -CAFG'
alias lsl='ls -lhFA | less'
alias cls='clear; ls -AFG;'
alias zshrc='vim ~/.zshrc'
alias zshrcR='. ~/.zshrc'
alias bashrc='vim ~/.bashrc'
alias bashrcR='. ~/.bashrc'
alias vimrc='vim ~/.vimrc'
alias tmuxconf='vim ~/.tmux.conf'
alias tmuxconfR='tmux source-file ~/.tmux.conf'

# Custom scripts
alias junk=junkFunc

#SSH Aliases
alias mbe='ssh mbe'
alias mars='ssh mars'
alias garage='ssh garage'
alias kitchen='ssh kitchen'

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

#************Docker Aliases************************
alias ctf='~/github/CTFDock/run'
alias ctfedit='vim ~/github/CTFDock/Dockerfile'
alias ctfbuild='vim ~/github/CTFDock/Dockerfile; cd ~/github/CTFDock/; ./build; cd -'

#************CD Aliases************************

#************Open Aliases************************
alias vlc='open /Applications/VLC.app'
alias g++="/usr/local/Cellar/gcc/6.2.0/bin/g++-6"
alias gcc="/usr/local/Cellar/gcc/6.2.0/bin/gcc-6"
alias calc="/Applications/Calculator.app/contents/MacOS/Calculator &"
