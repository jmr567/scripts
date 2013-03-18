
TTL=3600
SERVER="1.1.1.1"
#SERVER="blah.blah.com.au"
ZONE="blah.blah.com.au"
#RZONE="15.16.172.in-addr.arpa"
#HOSTNAME=`/bin/hostname -s`
HOSTNAME="ftp"
DOMAIN="blah.blah.com.au"
#CNAME="ftp.blah.ecetera.com.au"
KEYFILE=/etc/pki/dnssec-keys/Kblah
IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
#IP=`/sbin/ip addr list eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f 1`
#RIP="144.15.16.172"
BINDUTILS=`rpm -q bind-utils`

#Make sure bing-utils is installed
function checkpackages {
if [ "$BINDUTILS" != "0" ] ;
then yum install -q -y bind-utils ;
fi
}

#Forward Lookup
function forward {
nsupdate -v -k $KEYFILE > /dev/null << EOF
server $SERVER
zone $ZONE
update delete $HOSTNAME.$DOMAIN. A
update add $HOSTNAME.$DOMAIN. $TTL A $IP
send
EOF

if [ "$?" = "0" ] ;
then echo "DNS record $HOSTNAME.$DOMAIN. IN A $IP added"
else echo "DNS update failed"
fi
}


#CNAMEs
function cname {
nsupdate -v -k $KEYFILE > /dev/null << EOF
server $SERVER
zone $ZONE
update delete $CNAME. CNAME
update add $CNAME. $TTL CNAME $HOSTNAME.$DOMAIN.
send
EOF
}

#Reverse Lookup
function reverse {
nsupdate -v -k $KEYFILE > /dev/null << EOF
server $SERVER
zone $RZONE
update delete $RIP.in-addr.arpa CNAME
update add $RIP.in-addr.arpa $TTL PTR $HOSTNAME.$DOMAIN.
send
EOF
}

# Run functions
checkpackages
forward
#cname
#reverse

