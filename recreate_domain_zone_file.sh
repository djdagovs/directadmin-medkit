#!/bin/sh
#Based on http://help.directadmin.com/item.php?id=330

DA_USER=$1
DOMAIN=$2

[ -z "$DA_USER" ] && echo "Provide DA username" >&2 && exit 1
[ -z "$DOMAIN" ] && echo "Provide domain name" >&2 && exit 1

NAMED_DIR=/var/named
DA_USERS_DIR=/usr/local/directadmin/data/users
NS1=`grep ns1= /usr/local/directadmin/conf/directadmin.conf | cut -d= -f2`
NS2=`grep ns2= /usr/local/directadmin/conf/directadmin.conf | cut -d= -f2`

#rm ${NAMED_DIR}/${DOMAIN}.db


if [ ! -r "${NAMED_DIR}/${DOMAIN}.db" ]; then
	IP=`cat ${DA_USERS_DIR}/${DA_USER}/domains/${DOMAIN}.conf | grep ip= | cut -d= -f2`
	if [ "$IP" = "" ]; then
		IP=`cat ${DA_USERS_DIR}/${DA_USER}/user.conf | grep ip= | cut -d= -f2`
	fi

	echo "\$TTL 900"  >  ${NAMED_DIR}/${DOMAIN}.db
	echo "@         IN      SOA     ${NS1}.         hostmaster.${DOMAIN}. ("        >> ${NAMED_DIR}/${DOMAIN}.db
	echo "                            2010101901"                     >> ${NAMED_DIR}/${DOMAIN}.db
	echo "                            900"                          >> ${NAMED_DIR}/${DOMAIN}.db
	echo "                            3600"                           >> ${NAMED_DIR}/${DOMAIN}.db
	echo "                            1209600"                        >> ${NAMED_DIR}/${DOMAIN}.db
	echo "                            86400 )"                        >> ${NAMED_DIR}/${DOMAIN}.db
	echo ""                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo "${DOMAIN}.        900   IN              NS      ${NS1}."                >> ${NAMED_DIR}/${DOMAIN}.db
	echo "${DOMAIN}.        900   IN              NS      ${NS2}."                >> ${NAMED_DIR}/${DOMAIN}.db
	echo ""  >> ${NAMED_DIR}/${DOMAIN}.db
	echo "${DOMAIN}.        900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo "ftp               900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo "localhost         900   IN              A       127.0.0.1">> ${NAMED_DIR}/${DOMAIN}.db
	echo "mail              900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo "pop               900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo "smtp              900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo "www               900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	echo ""  >> ${NAMED_DIR}/${DOMAIN}.db
	echo "${DOMAIN}.        900   IN              MX      10 mail"  >> ${NAMED_DIR}/${DOMAIN}.db
	echo "${DOMAIN}.        900   IN              TXT     \"v=spf1 a mx ip4:${IP} ~all\""    >> ${NAMED_DIR}/${DOMAIN}.db

	echo ""  >> ${NAMED_DIR}/${DOMAIN}.db

	for SUB in `cat ${DA_USERS_DIR}/${DA_USER}/domains/${DOMAIN}.subdomains`; do
	{
	  echo "${SUB}              900   IN              A       ${IP}"                             >> ${NAMED_DIR}/${DOMAIN}.db
	}
	done;

	#chown bind:bind ${NAMED_DIR}/${DOMAIN}.db

	echo "Database created for $2"
fi
