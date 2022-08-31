#!/bin/bash


THE_USER=`logname`

#Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi


SCREAM_SOURCE=$(find . -maxdepth 1 -type d -iname '*scream*' -print -quit)

#This script should only run if scream source folder is present
if [ -d "$SCREAM_SOURCE" ]
	then 
		echo "Continuing with scream installation"
	else
		echo "Scream source folder not found in this directory. Please move scream source folder into this directory and try again."
		exit
fi

#Create autostart directory if not already present
#This will be used by gnome to start scream on machine startup
if ! [ -a /home/$THE_USER/.config/autostart ]
	then 
	mkdir /home/$THE_USER/.config/autostart
fi


chmod +x uninstall.sh

chown $THE_USER /home/$THE_USER/.config/autostart

cp audio.sh.desktop /home/$THE_USER/.config/autostart/

chown $THE_USER /home/$THE_USER/.config/autostart/audio.sh.desktop

#This will be used to autostart scream and can be edited if different parameters are used
cp scream-audio /usr/bin/scream-audio

#This will be used to retrieve all bridge devices on this computer, 
# save them to /etc/scream/devices, 
# and use found devices for scream later
cp scream-reconfigure /usr/bin/scream-reconfigure

#Installing required packages

DISTRO=`cat /etc/*release | grep DISTRIB_ID | cut -d '=' -f 2`
FEDORA=`cat /etc/*release |  head -n 1 | cut -d ' ' -f 1`

if [ "$DISTRO" == "Ubuntu" ] || [ "$DISTRO" == "Pop" ] || [ "$DISTRO" == "LinuxMint" ]
	then
apt install libpulse-dev make cmake screen libasound2-dev  -y
elif [ "$DISTRO" == "ManjaroLinux" ] || [ "$DISTRO" == "Arch" ]
	then
pacman -Syu cmake make base-devel screen
elif [ "$FEDORA" == "Fedora" ]
	then
dnf install cmake make gcc screen pulseaudio-libs-devel alsa-lib-devel libpcap-devel
	else
echo "This script does not support your current distribution. Only Ubuntu, PopOS, Manjaro, Arch and Mint are supported!"
echo "You can still install Looking Glass manually!"
	exit
fi

#Compiling scream receiver
cd $SCREAM_SOURCE/Receivers/unix/

mkdir build

cd build

cmake ..

make

#Moving files to their expected locations
mv scream /usr/bin/scream

#Adding permissions to run copied files
chmod +x /usr/bin/scream
chmod +x /usr/bin/scream-audio
chmod +x /usr/bin/scream-reconfigure

#Detecting and saving bridge devices for scream to use.
#If you want to specify them manually,
# edit /etc/scream/devices to change list of devices for scream to use
scream-reconfigure

#In Fedora Scream is normally blocked by the firewall - opening up a port
if [ "$FEDORA" == "Fedora" ]
then
firewall-cmd --permanent --zone=libvirt --add-port=4010/udp
fi

