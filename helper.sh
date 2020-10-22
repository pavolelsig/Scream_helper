#!/bin/bash


THE_USER=`logname`

#Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

#This script should only run if scream-master is present
if [ -a scream-master ]
	then 
		echo "Continuing with scream installation"
	else
		echo "Scream-master not found in this directory. Please move scream-master into this directory and try again."
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
cp audio.sh /usr/bin/scream_audio.sh

#Installing required packages

DISTRO=`cat /etc/*release | grep DISTRIB_ID | cut -d '=' -f 2`
FEDORA=`cat /etc/*release |  head -n 1 | cut -d ' ' -f 1`

if [ "$DISTRO" == "Ubuntu" ] || [ "$DISTRO" == "Pop" ] || [ "$DISTRO" == "LinuxMint" ]
	then
apt install libpulse-dev make cmake libasound2-dev -y
elif [ "$DISTRO" == "ManjaroLinux" ]
	then
pacman -Syu cmake make base-devel
elif [ "$FEDORA" == "Fedora" ]
	then
dnf install cmake make gcc pulseaudio-libs-devel alsa-lib-devel libpcap-devel
	else
echo "This script does not support your current distribution. Only Ubuntu, PopOS, Manjaro, and Mint are supported!"
echo "You can still install Looking Glass manually!"
	exit
fi

#Compiling scream receiver
cd scream-master/Receivers/unix/

mkdir build

cd build

cmake ..

make

#Moving files to their expected locations
mv scream /usr/bin/scream

chmod +x /usr/bin/scream


chmod +x /usr/bin/scream_audio.sh


#In Fedora Scream is normally blocked by the firewall - opening up a port
if [ "$FEDORA" == "Fedora" ]
then
firewall-cmd --permanent --zone=libvirt --add-port=4010/udp
fi

