# New System Setup

Steps for setting up fresh new system (docker container, droplet, whatever). This assumes the OS was just created, you've logged in as root and you're in `/root/`.

TODO: make this a script, and make some sections of it optional.

1. `apt update`
2. `apt dist-upgrade`
3. `NEW_USER=<your username>`
4. `user-add -m $NEW_USER`
5. `passwd $NEW_USER`
6. `usermod -aG sudo $NEW_USER`
7. `mkdir /home/$NEW_USER/.ssh && chown $NEW_USER /home/$NEW_USER/.ssh`
8. `cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys && chown $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh/authorized_keys`
9. `echo "AllowUsers $NEW_USER" >> /etc/ssh/sshd_config` optionally remove the allow root login setting
10. `chsh $NEW_USER`
11. `su $NEW_USER`
12. `cd ~`
13. `sudo apt install tmux git htop`
14. `mkdir github`
15. `mkdir github/burtonwilliamt`
16. `cd github/burtonwilliamt/`
17. `git clone https://github.com/burtonwilliamt/dotfiles.git`
18. `cd dotfiles`
19. `chmod +x ./setup.sh`
20. `./setup.sh`
21. `cd ~`
