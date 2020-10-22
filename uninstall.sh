#!/bin/bash

if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi


#Remove Scream Audio if present

if [ -a /usr/bin/scream ]
	then 
	rm /usr/bin/scream
fi


if [ -a /usr/bin/scream_audio.sh ]
	then 
	rm /usr/bin/scream_audio.sh
fi


if [ -a /home/$LOGNAME/.config/autostart/audio.sh.desktop ]
	then 
	rm /home/$LOGNAME/.config/autostart/audio.sh.desktop
fi

