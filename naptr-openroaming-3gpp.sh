#! /bin/bash

# 2023/5/29
# NAPTR/SRV lookup script for OpenRoaming with 3GPP realm conversion.
# Ref. "WBA OpenRoaming - The Framework to Support WBA's Wi-Fi Federation"
#   Version 3.0.0
# This script tries first a modified realm
#   wlan.mncXXX.mccYYY.pub.3gppnetwork.org , 
# and tries the original 
#   wlan.mncXXX.mccYYY.3gppnetwork.org
# if the first attempt has failed.

# Example script!
# This script looks up radsec srv records in DNS for the one
# realm given as argument, and creates a server template based
# on that. It currently ignores weight markers, but does sort
# servers on priority marker, lowest number first.
# For host command this is column 5, for dig it is column 1.

usage() {
    echo "Usage: ${0} <realm>"
    exit 1
}

test -n "${1}" || usage

#REALM="${1}"
DIGCMD=$(command -v dig)
HOSTCMD=$(command -v host)
PRINTCMD=$(command -v printf)

validate_host() {
         echo ${@} | tr -d '\n\t\r' | grep -E '^[_0-9a-zA-Z][-._0-9a-zA-Z]*$'
}

validate_port() {
         echo ${@} | tr -d '\n\t\r' | grep -E '^[0-9]+$'
}

dig_it_srv() {
    ${DIGCMD} +short srv $SRV_HOST | sort -n -k1 |
    while read line; do
        set $line ; PORT=$(validate_port $3) ; HOST=$(validate_host $4)
        if [ -n "${HOST}" ] && [ -n "${PORT}" ]; then
            $PRINTCMD "\thost ${HOST%.}:${PORT}\n"
        fi
    done
}

dig_it_naptr() {
    ${DIGCMD} +short naptr ${REALM} | grep aaa+auth:radius.tls.tcp | sort -n -k1 |
    while read line; do
        set $line ; TYPE=$3 ; HOST=$(validate_host $6)
        if ( [ "$TYPE" = "\"s\"" ] || [ "$TYPE" = "\"S\"" ] ) && [ -n "${HOST}" ]; then
            SRV_HOST=${HOST%.}
            dig_it_srv
        fi
    done
}

host_it_srv() {
    ${HOSTCMD} -t srv $SRV_HOST | sort -n -k5 |
    while read line; do
        set $line ; PORT=$(validate_port $7) ; HOST=$(validate_host $8) 
        if [ -n "${HOST}" ] && [ -n "${PORT}" ]; then
            $PRINTCMD "\thost ${HOST%.}:${PORT}\n"
        fi
    done
}

host_it_naptr() {
    ${HOSTCMD} -t naptr ${REALM} | grep aaa+auth:radius.tls.tcp | sort -n -k5 |
    while read line; do
        set $line ; TYPE=$7 ; HOST=$(validate_host ${10})
        if ( [ "$TYPE" = "\"s\"" ] || [ "$TYPE" = "\"S\"" ] ) && [ -n "${HOST}" ]; then
            SRV_HOST=${HOST%.}
            host_it_srv
        fi
    done
}

REALM_0=$(validate_host ${1})
if [[ "$REALM_0" =~ "3gppnetwork" ]]; then
    IS3GPP=true
    REALM=${REALM_0/3gppnetwork/pub.3gppnetwork}
else
    IS3GPP=false
    REALM=${REALM_0}
fi
if [ -z "${REALM}" ]; then
    echo "Error: realm \"${1}\" failed validation"
    usage
fi

if [ -x "${DIGCMD}" ]; then
    SERVERS=$(dig_it_naptr)
    if [ -z "${SERVERS}" ] && $IS3GPP ; then
        REALM=${REALM_0}
        SERVERS=$(dig_it_naptr)
    fi
elif [ -x "${HOSTCMD}" ]; then
    SERVERS=$(host_it_naptr)
    if [ -z "${SERVERS}" ] && $IS3GPP ; then
        REALM=${REALM_0}
        SERVERS=$(host_it_naptr)
    fi
else
    echo "${0} requires either \"dig\" or \"host\" command."
    exit 1
fi

if [ -n "${SERVERS}" ]; then
    $PRINTCMD "server dynamic_radsec.${REALM_0} {\n${SERVERS}\n\ttype TLS\n}\n"
    exit 0
fi

exit 10				# No server found.
