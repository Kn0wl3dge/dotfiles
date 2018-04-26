#!/bin/sh
set -e


log(){
    echo "$(date) [+] $1" | tee -a ~/installation.log
}

warning(){
    echo "$(date) [!] $1" | tee -a ~/installation.log
}

alias zin="sudo zypper in -yl"
alias zup="sudo zypper dup -yl"
alias zal="sudo zypper al"

log "Starting installation"

log "Setting hostname"
sudo hostnamectl hostname wks-kn0wledge

log "Updating system"
zup

log "Setting up user rights"
sudo usermod -aG users $USER

log "Locking useless dependencies"
zal patterns-sway pulseaudio alsa pulseaudio-setup

log "Installing wayland graphical environment"
zin\
    swaybg sway waybar swayidle swaylock lxsession xdg-desktop-portal-wlr\
    pipewire pipewire-alsa pipewire-pulseaudio pulseaudio-utils thunar thunar-plugin-archive\
    brightnessctl powertop NetworkManager-connection-editor NetworkManager-tui

log "Installing development tools"
zin\
    git zsh podman flatpak buildah wget curl neovim file-roller unzip tree man
zin -t pattern devel_C_C++ devel_python3

log "Installing theme assets"
zin\
    breeze5-cursors fontawesome-fonts

log "Installing fonts"
zin -t pattern fonts

log "Configuring flatpak for the current user"
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
log "Installing desktop applications"
flatpak install --user -y \
    com.github.tchx84.Flatseal\
    com.yubico.yubioath com.vscodium.codium\
    org.keepassxc.KeePassXC com.brave.Browser\
    org.signal.Signal com.discordapp.Discord

log "Setting up powertop"
sudo systemctl enable powertop
sudo systemctl start powertop

log "Installing kernel sound driver"
sudo cp ./etc/modprobe.d/alsa.conf /etc/modprobe.d/
sudo mkinitrd

log "Setting up udev rules"
sudo cp ./etc/udev/rules.d/* /etc/udev/rules.d/

log "Preparing home directory"
mkdir ~/Downloads
mkdir ~/Pictures
mkdir ~/bin
mkdir ~/Desktop
mkdir ~/Documents

log "Setting up dotfiles"
ln -s $(pwd)/.config ~
ln -s $(pwd)/.themes ~
ln -s $(pwd)/git/.gitconfig ~

log "Setting up wallpapers"
sudo cp ./wallpaper.png /usr/share/wallpapers/wallpaper.png
sudo cp ./lock-wallpaper.png /usr/share/wallpapers/lock-wallpaper.png

log "Configure subuids and subgid to support rootless podman"
sudo usermod --add-subuids 10000-65536 $USER
sudo usermod --add-subgid 10000-65536 $USER

log "Installing oh-my-zsh"
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
echo ". ~/.config/bash/config.sh" >> ~/.zshrc
cp ~/.config/bash/startup.sh .zprofile
cp ~/.config/bash/startup.sh .profile

log "Please reboot to finish the installation"
