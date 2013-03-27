#!/bin/bash

USER=$1
EXPIRATION=$2
RANDOMPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8`

if [ "$1" = "-h" ] ;
	then echo "Usage: $0 USERNAME {days_to_expire}" && exit 1 ;
	else 
		if [ -z $1 ] ;
		then echo "Usage: $0 {username} {days_to_expire}" && exit 1 ;
		#else echo "Adding user $USER"
		else echo ""
		fi
fi

if [[ $2 =~ ^[0-9]+$ ]] && [[ $2 -gt 0 ]]; 
	then ACTUALEXPIRE=$2 #&& echo "Account will Expire after $ACTUALEXPIRE days" ;
	else ACTUALEXPIRE=30 #&& echo "Account will Expire after the default of 30 days" ;
fi

function checkUser {
grep $USER /etc/passwd > /dev/null
if [ $? = "0" ];
	then echo "User already exists, no action taken" && exit 1 ;
	else echo "" > /dev/null
fi
}

function makeHomeDir {
mkdir /home/$USER
mkdir /home/$USER/incoming
#mkdir /home/$USER/outgoing
}

function addUser {
useradd -M -d /incoming -g sftp -c "SFTP Only - $USER" -s /sbin/nologin $USER
}

function fixPerms {
chown root:root /home/$USER
chmod 755 /home/$USER
chmod 700 /home/$USER/incoming
#chmod 500 /home/$USER/outgoing
chown $USER:sftp /home/$USER/incoming #/home/$USER/outgoing
}

function setPassword {
echo $RANDOMPW | passwd $USER --stdin > /dev/null 
}

function setExpire {
EXPIREDATE=`date --date="+$ACTUALEXPIRE days"`
chage -E "$EXPIREDATE" $USER
}

function summary {
echo "<p>"
echo "The User<b> $USER </b>with the password<b> $RANDOMPW </b>has SFTP access to<b> ftp.services.ecetera.com.au </b>for the next<b> $ACTUALEXPIRE </b>days"
echo "</p>"
echo "<p>"
echo "The account will Expire on<b> $EXPIREDATE </b>"
echo "</p>"
echo "<p>"
echo "To connect use <b> # sftp $USER@ftp.services.ecetera.com.au </b>"
echo "</p>"
}

#Execute Functions
checkUser
makeHomeDir
addUser
fixPerms
setPassword
setExpire
summary
