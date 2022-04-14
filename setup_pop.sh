#!/usr/bin/env bash

export platform=`cat /proc/cpuinfo | grep vendor_id | sort | uniq | cut -d ":" -f 2 | sed 's/^[ \t]*//'`

echo PLATFORM: $platform

if [ $platform == "AuthenticAMD" ]; then

echo "Fixing backlight for AMD"
#sudo kernelstub -a amdgpu.backlight=0
#sudo kernelstub -a mem_sleep_default=deep
#sudo kernelstub -a rcutree.rcu_idle_gp_delay=1
fi
sudo kernelstub -p

sleep 10

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y --allow-downgrades
sudo apt-get install -y ca-certificates gnupg apt-transport-https samba-client cifs-utils software-properties-common gnupg-agent nfs-common keepassxc vim byobu htop mc git tig wireguard wireguard-tools wireguard-dkms dconf-editor dconf-cli openvpn network-manager-openvpn-gnome fish steam libsdl2-dev thunderbird gimp librtmp-dev neofetch powertop wavemon xserver-xorg-input-synaptics openssh-server libsdl2-2.0-0 libsdl2-dev libsdl2-image-2.0-0 libsdl2-image-dev ssh podman gnome-mahjongg

sudo ln -s /usr/lib/x86_64-linux-gnu/librtmp.so.1 /usr/lib/x86_64-linux-gnu/librtmp.so.0

sudo ldconfig

mkdir -p ~/.local/bin

# Google Chrome
if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update -y && sudo apt-get install -y google-chrome-stable
fi

# KVM
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager ssh-askpass-gnome
sudo adduser gary libvirt

# Terraform
TFVER=1.0.6
if [ ! -f /usr/local/bin/terraform ]; then
cd /tmp && wget https://releases.hashicorp.com/terraform/$TFVER/terraform_${TFVER}_linux_amd64.zip && unzip terraform_${TFVER}_linux_amd64.zip && sudo mv /tmp/terraform /usr/local/bin && rm terraform_*.zip
fi

# Gcloud SDK
if [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]; then
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update -y && sudo apt-get install -y google-cloud-sdk kubectl
fi

# Golang
GOVER=1.17.1
if [ ! -d "/usr/local/go" ]; then
cd /tmp && wget https://golang.org/dl/go${GOVER}.linux-amd64.tar.gz && tar xvzf go${GOVER}.linux-amd64.tar.gz && rm go${GOVER}.linux-amd64.tar.gz* && sudo mv ./go /usr/local/
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
fi

flatpak install -y flathub spotify slack app/org.videolan.VLC/x86_64/stable remmina app/io.github.Hexchat/x86_64/stable org.gnome.DejaDup com.obsproject.Studio cheese

# syndaemon -i 1.0 -K -t -d

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 '["<super>1"]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 '["<super>2"]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 '["<super>3"]'
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 '["<super>4"]'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 '["<Shift><Super>exclam"]'

