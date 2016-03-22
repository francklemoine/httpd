#!/bin/bash

set -e

MAXSERVER=9

# set SERVER and ADMIN arrays
for (( i=1; i<=${MAXSERVER}; i++ )); do
	if [[ -v SERVERNAME${i} ]]; then
		fullsvr="SERVERNAME${i}"
	 	SERVERNAME_ARRAY[${i}]=${!fullsvr}
	fi

	if [[ -v SERVERADMIN${i} ]]; then
		fulladm="SERVERADMIN${i}"
	 	SERVERADMIN_ARRAY[${i}]=${!fulladm}
	fi
done

# one server at least must be defined
if [[ -z "${SERVERNAME_ARRAY[*]}" ]]; then
	echo >&2 'Notice: undefined variable(s) SERVERNAME1..9! - skipping ...'
	exit 1
fi

# one admin at least must be defined
if [[ -z "${SERVERADMIN_ARRAY[*]}" ]]; then
	echo >&2 'Notice: undefined variable(s) SERVERADMIN1..9! - skipping ...'
	exit 1
fi


for (( i=1; i<=${MAXSERVER}; i++ )); do
	find $HTTPD_PREFIX/conf/extra \
		-maxdepth 1 \
		-type f -name "*.conf" \
		-exec sed -i -e "s/___SERVERNAME${i}___/${SERVERNAME_ARRAY[${i}]}/g" -e "s/___SERVERADMIN${i}___/${SERVERADMIN_ARRAY[${i}]}/g" {} \;


	find $HTTPD_PREFIX/conf-enabled \
		-maxdepth 1 \
		-type f -name "*.conf" \
		-exec sed -i -e "s/___SERVERNAME${i}___/${SERVERNAME_ARRAY[${i}]}/g" -e "s/___SERVERADMIN${i}___/${SERVERADMIN_ARRAY[${i}]}/g" {} \;
done


if [ ! -f /firstrun ]; then
	# Echo quickstart guide to logs
	echo
	echo '================================================================================='
	for (( i=1; i<=${MAXSERVER}; i++ )); do
		[[ -v SERVERNAME_ARRAY[${i}] ]] && echo "Your ${SERVERNAME_ARRAY[${i}]} httpd server container is now ready to use!"
	done
	echo '================================================================================='
	echo
fi

echo -e 'Running httpd...\n'

# Used as identifier for first-run-only stuff
touch /firstrun

exec "$@"

