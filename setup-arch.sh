#!/usr/bin/env bash
echo Installing arch with desktop environment: $1
sudo systemctl enable --now NetworkManager
sleep 2 
sudo pacman-key --populate
sudo pacman -Suy --noconfirm

mkdir -p /tmp/aur

function aurinst {
	echo Installing aur package $1
	if [ -d /tmp/aur/$1 ]; then
		rm -rf /tmp/aur/$1
	fi
	cd /tmp/aur && git clone https://aur.archlinux.org/$1.git && cd $1 && makepkg -sic --noconfirm --needed
	rm -rf /tmp/aur/$1 
}

# Install Xorg and hardware drivers
sudo pacman -S --noconfirm --needed xorg xorg-xinit nvidia nvidia-settings bluez wpa_supplicant tlp dmidecode xdg-utils xterm intltool
# install system services
sudo pacman -S --noconfirm --needed wireguard-tools acpi_call samba tlp dnsmasq openresolv nss-mdns cups cups-pdf pipewire pipewire-jack pipewire-alsa pipewire-pulse openssh ufw openvpn networkmanager-openvpn libxcrypt-compat
# install tooling
sudo pacman -S --noconfirm --needed wget sudo neofetch mc htop flatpak wireguard-tools rsync curl 
# install basic applications
echo Installing base applications...
sudo pacman -S --noconfirm --needed firefox thunderbird ttf-liberation ttf-dejavu libreoffice gimp dnsutils mpv handbrake irssi cmus deepin-music cmus
sleep 4

PLATFORM=$(sudo dmidecode -s system-manufacturer)

sudo touch /etc/polkit-1/rules.d/49-allow-passwordless-printer-admin.rules
sudo bash -c 'cat << EOF > /etc/polkit-1/rules.d/49-allow-passwordless-printer-admin.rules
polkit.addRule(function(action, subject) { 
    if (action.id == "org.opensuse.cupspkhelper.mechanism.all-edit" && 
        subject.isInGroup("wheel")){ 
        return polkit.Result.YES; 
    } 
});
EOF'


echo Platform: $PLATFORM
if [ "$PLATFORM" == "QEMU" ]; then
	sudo pacman -S --noconfirm --needed spice-vdagent
	sudo systemctl enable spice-vdagentd
fi

# install development and user tools
sudo pacman -S --noconfirm --needed git tig byobu libxss python-setuptools mesa-demos yelp-tools check meson gobject-introspection glxinfo python-dbus qemu virt-manager virt-viewer vde2 edk2-ovmf bridge-utils openbsd-netcat python-dbusmock rust docker go terminator
aurinst libfirmware-manager

sudo usermod -aG docker $USER
sudo usermod -aG libvirt $USER
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now cups.socket
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now dnsmasq.service
sudo systemctl enable --now ebtables.service
sudo systemctl enable --now libvirtd.service
sudo systemctl enable --now sshd.service
sudo systemctl enable --now ufw.service

if [ "$1" == "gnome" ]; then 
  echo "Installing GNOME"
  sudo pacman -Suy --noconfirm --needed gnome-shell gnome-backgrounds gnome-color-manager gnome-disk-utility gnome-font-viewer gnome-menus gnome-remote-desktop gnome-screenshot gnome-shell-extensions gnome-software gnome-system-monitor gnome-connections gnome-user-share mutter nautilus orca xdg-user-dirs-gtk simple-scan gnome-calculator gnome-contacts rhythmbox gnome-themes-extra gnome-shell-extension-appindicator gnome-tweaks gnome-calendar deja-dup gnome-terminal system-config-printer ttf-roboto-mono ttf-roboto ttf-fira-sans ttf-fira-mono modemmanager nautilus-image-converter nautilus-sendto nautilus-share gnome-shell-extension-gtile gnome-icon-theme-extras dconf-editor eog remmina cheese libsass parallel sassc gtk-engine-murrine
  aurinst ttf-roboto-slab
  aurinst libfirmware-manager-git
  aurinst pop-icon-theme-git
  aurinst pop-gtk-theme-git
  aurinst pop-fonts
  aurinst pop-theme
  aurinst gnome-control-center-system76
  aurinst gnome-shell-extension-no-overview
  aurinst gnome-shell-extension-dash-to-dock
  aurinst gnome-shell-extension-pop-shell-git
  gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
  gsettings set org.gnome.desktop.interface enable-hot-corners false
  gsettings set org.gnome.desktop.interface icon-theme 'Pop'
  gsettings set org.gnome.desktop.interface clock-show-seconds true
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.desktop.interface font-name "Fira Sans Book 10"
  gsettings set org.gnome.desktop.interface monospace-font-name "Fira Mono Regular 11"
  gsettings set org.gnome.desktop.interface document-font-name "Roboto Slab Regular 11"
  sudo systemctl enable gdm.service
  gnome-extensions enable no-overview@fthx
  gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
  gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
  gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
  gnome-extensions enable dash-to-dock@micxgx.gmail.com
  gsettings set org.gnome.shell disable-user-extensions false
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
  gsettings set org.gnome.shell.extensions.user-theme name 'Pop'
fi

if [ "$1" == "kde" ]; then
  echo "INSTALLING KDE"
  sudo pacman -S --noconfirm --needed sddm plasma-desktop konsole dolphin dolphin-plugins baloo kmix kate kcalc kdeconnect kmail kompare krdc krfb kwalletmanager okular partitionmanager spectacle bluedevil plasma-workspace-wallpapers kscreen bluedevil powerdevil
  sudo systemctl enable sddm.service
fi

if [ "$1" == "i3" ]; then
  echo "INSTALLING i3"
  sudo pacman -S --noconfirm --needed i3-wm i3lock i3status
fi

sudo flatpak install -y flathub \
	spotify \
	slack \
	app/org.videolan.VLC/x86_64/stable \
	app/io.github.Hexchat/x86_64/stable \
	com.obsproject.Studio \
	com.valvesoftware.Steam


sudo chown gary:gary /tmp/aur
aurinst google-chrome
aurinst sublime-text-4 
aurinst google-cloud-sdk
if [ "$2" == "Y" ]; then
  aurinst optimus-manager
  aurinst gdm-prime
  sudo systemctl enable gdm
  sudo systemctl enable --now optimus-manager
fi
