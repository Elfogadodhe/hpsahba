#!/bin/bash
echo -e "This script sets up the symbolic link for the kernel module and updates/installs missing packages.\n"

#check if confirmed
read -r -p "Before you proceed with this script set up the PVE repositories and run apt-get dist-upgrade first, \
reboot the system if needed and purge old kernel versions.\nDo you wish to proceed? [y/N] " response
response=${response,,}  # convert to lowercase

if [[ ! "$response" =~ ^(y|yes|Y)$ ]]; then
    echo "Exiting script."
    exit 1  # Exit with a non-zero status indicating negative response
fi

#check if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#check if launched from right directory
if [[ $(pwd) != *"/contrib/dkms" ]]; then
	echo -e "you need to run this script from within the contrib/dkms directory!\n"
	echo "please cd and run this script again"
	exit
fi

#creating symlink
ln -s ~/hpsahba/kernel/5.18-patchset-v2 6.14-patchset-v2

echo "Blacklisting hpwdt..."
echo "blacklist hpwdt" > /etc/modprobe.d/blacklist-hp.conf
echo "/etc/modprobe.d/blacklist-hp.conf: "
cat /etc/modprobe.d/blacklist-hp.conf

echo "Updating initramfs, grub..."
update-initramfs -k all -u
proxmox-boot-tool refresh || update-grub

echo "Updating packages..."
apt update && apt full-upgrade -y && \
apt install -y cron curl dkms gcc git htop iotop open-iscsi pandoc postfix pv screen sdparm sudo wget && \
./install.sh
