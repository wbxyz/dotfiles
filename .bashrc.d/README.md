## Setup
After cloning this repo, add a symlink for this directory:

```bash
ln -s $HOME/github/wbxyz/dotfiles/.bashrc.d $HOME/.bashrc.d
```

Then source all the files in base `.bashrc`:

```bash
# Custom aliases
if [ -d "$HOME/.bashrc.d" ]; then
    for script in "$HOME/.bashrc.d/"*.sh; do
        if [ -f "$script" ] && [ -r "$script" ]; then
            . "$script"
        fi
    done
fi
```

Alternatively, you could source only the specific files you care about.
