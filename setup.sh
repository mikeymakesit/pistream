#!/bin/bash


NGINXCONF="/etc/nginx/nginx.conf"
NGINXSERVICE="/lib/systemd/system/nginx.service"


# Quit if not running as root
if (( $EUID != 0 )); then
    echo -e '\e[1mYou MUST run this setup script as root\e[0m'
    exit 1
else
    echo -e '\e[1mInstalling livestream setup\e[0m'
fi


# LIVESTREAM
if [ ! -d /root/bin ]; then
    mkdir /root/bin
fi
cp -f livestream/livestream.sh /root/bin/
chmod 0500 /root/bin/livestream.sh


# NGINX
echo -e '\e[1mUpdating package list\e[0m'
apt-get update

echo -e '\e[1mInstalling nginx, libnginx-mod-rtmp, and ffmpeg\e[0m'
apt install -y nginx libnginx-mod-rtmp ffmpeg

read -p 'Enter Twitch stream key: ' twitchkey
if [ -z $twitchkey ]; then
    echo -e '\e[1mYou did not enter a stream key, so quitting.  Bye!\e[0m'
    exit 1
fi

echo -e '\e[1mInstalling new nginx.conf\e[0m'
if [ -f $NGINXCONF ]; then
    echo -e '\e[1mBacking up existing nginx.conf to nginx.conf.orig\e[0m'
    mv $NGINXCONF $NGINXCONF.orig
fi
sed "s/MY_STREAM_KEY/$twitchkey/" nginx/nginx.conf > $NGINXCONF

# Enable nginx service
cp -f nginx/nginx.service $NGINXSERVICE


# LIVESTREAM SERVICE
echo -e '\e[1mInstalling stream service\e[0m'
cp -f livestream/livestream.service /etc/systemd/system/


# SERVICES
systemctl daemon-reload
systemctl enable nginx
systemctl enable livestream


# DONE
echo -e '\e[1mFINISHED with install\e[0m'
read -p 'Do you want to reboot now? [y/n]: ' do_reboot
if [ $do_reboot = 'y' ]; then
    echo -e '\e[1mRebooting now!\e[0m'
    reboot
fi

exit 0
