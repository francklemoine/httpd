#!/bin/bash

set -e

: ${SERVERNAME:=none}
: ${SERVERADMIN:=none}

if [[ ${SERVERNAME} = 'none' ]]; then
	echo >&2 'Notice: undefined variable SERVERNAME! - skipping ...'
	exit 1
fi

if [[ ${SERVERADMIN} = 'none' ]]; then
	echo >&2 'Notice: undefined variable SERVERADMIN! - skipping ...'
	exit 1
fi


[ -f "${HTTPD_PREFIX}/conf/extra/httpd-vhosts.conf" ] && \
    sed -i -e "s/__SERVERNAME__/${SERVERNAME}/" -e "s/__SERVERADMIN__/${SERVERADMIN}/" ${HTTPD_PREFIX}/conf/extra/httpd-vhosts.conf


find $HTTPD_PREFIX/conf-enabled \
    -maxdepth 1 \
    -type f -name "*.conf" \
    -exec sed -i -e "s/__SERVERNAME__/${SERVERNAME}/" -e "s/__SERVERADMIN__/${SERVERADMIN}/" {} \;


if [ ! -f /firstrun ]; then
	# Echo quickstart guide to logs
	echo
	echo '================================================================================='
	echo "Your ${SERVERNAME} httpd server container is now ready to use!"
	echo '================================================================================='
	echo
fi

echo -e 'Running httpd...\n'

# Used as identifier for first-run-only stuff
touch /firstrun

exec "$@"

