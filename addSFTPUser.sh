#!/bin/bash

USER=$1
EXPIRATION=$2
RANDOMPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8`

if [ "$1" = "-h" ] ;
	then echo "Usage: $0 USERNAME {days_to_expire}" && exit 1 ;
	else 
		if [ -z $1 ] ;
		then echo "Usage: $0 {username} {days_to_expire}" && exit 1 ;
		else echo "Adding user $USER"
		fi
fi

if [[ $2 =~ ^[0-9]+$ ]] && [[ $2 -gt 0 ]]; 
	then ACTUALEXPIRE=$2 && echo "Account will Expire after $ACTUALEXPIRE days" ;
	else ACTUALEXPIRE=30 && echo "Account will Expire after the default of 30 days" ;
fi

function makeHomeDir {
mkdir /home/$USER
mkdir /home/$USER/incoming
mkdir /home/$USER/outgoing
}

function addUser {
useradd -M -d /incoming -g sftp -c "SFTP Only - $USER" -s /sbin/nologin $USER
}

function fixPerms {
chown root:root /home/$USER
chmod 755 /home/$USER
chmod 700 /home/$USER/incoming
chmod 500 /home/$USER/outgoing
chown $USER:sftp /home/$USER/incoming /home/$USER/outgoing
}

function setPassword {
echo $RANDOMPW | passwd $USER --stdin
}

function setExpire {
EXPIREDATE=`date --date="+$ACTUALEXPIRE days"`
chage -E "$EXPIREDATE" $USER
}

function summary {
echo ""
echo "The User $USER with the password $RANDOMPW has SFTP access to ftp.services.ecetera.com.au for the next $ACTUALEXPIRE days"
echo ""
echo "The account will Expire on $EXPIREDATE"
echo ""
echo "To connect use # sftp $USER@ftp.services.ecetera.com.au"
echo ""
}

#Execute Functions
makeHomeDir
addUser
fixPerms
setPassword
setExpire
summary
