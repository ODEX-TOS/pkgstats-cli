#!/usr/bin/env bash

pkgstatsver='2.4'
showonly=false
quiet=false
curloptions=(-q -s -S -L --retry 6 --connect-timeout 3 --max-time 5)

usage() {
	echo "usage: ${0} [option]"
	echo 'options:'
	echo '	-v	show the version of pkgstats'
	echo '	-d	enable debug mode'
	echo '	-h	show this help'
	echo '	-s	show what information would be sent'
	echo '		(but do not send anything)'
	echo '	-q	be quiet except on errors'
	echo ''
	echo 'pkgstats sends a list of all installed packages,'
	echo 'the architecture and the mirror you are using'
	echo 'to the Arch Linux project.'
	echo ''
	echo 'Statistics are available at https://pkgstats.archlinux.de/'
}

GREEN='\033[0;32m'
RED='\033[0;31m'
#ORANGE='\033[1;33m'
NC='\033[0m'
LOG_INFO="${GREEN}[INFO]${NC}"
#LOG_WARN="${ORANGE}[WARN]${NC}"
LOG_ERROR="${RED}[ERROR]${NC}"

log() {
	echo -e "$@"
}

while getopts 'vdhsq' parameter; do
	case ${parameter} in
		v)	echo "pkgstats, version ${pkgstatsver}"; exit 0;;
		d)	option="${option} --trace-ascii -";;
		s)	showonly=true;;
		q)	quiet=true;;
		*)	usage; exit 1;;
	esac
done

CONF="$HOME/.config/tos/general.conf"
# check to see if opt out is enabled
OPT_OUT="0"
[[ -f "$CONF" ]] && OPT_OUT="$(grep '^\s*pkg_opt_out=.*' $CONF | cut -d'=' -f2 | sed 's/\"//g')" 

if [[ "$OPT_OUT" == "1" ]]; then
        ${quiet} || log "$LOG_INFO" "You opted out of sending package data. Aborting now"
        exit 0
fi

${quiet} || log "$LOG_INFO" 'Collecting data...'
pkglist="$(mktemp --tmpdir pkglist.XXXXXX)"
trap 'rm -f "${pkglist}"' EXIT
pacman -Qq > "${pkglist}"
arch="$(uname -m)"
if [[ -f /proc/cpuinfo ]]; then
	if grep -qE '^flags\s*:.*\slm\s' /proc/cpuinfo; then
		cpuarch='x86_64'
	fi
else
	cpuarch=''
fi
mirror="$(pacman-conf --repo tos Server 2> /dev/null | head -1 | sed -E 's#(.*/)extra/os/.*#\1#;s#(.*://).*@#\1#')"

if ${showonly}; then
	log "$LOG_INFO" 'packages='
	cat  "${pkglist}"
	echo ''
	log "$LOG_INFO" "arch=${arch}"
	log "$LOG_INFO" "cpuarch=${cpuarch}"
	log "$LOG_INFO" "pkgstatsver=${pkgstatsver}"
	log "$LOG_INFO" "mirror=${mirror}"
	log "$LOG_INFO" "quiet=${quiet}"
else
	${quiet} || log "$LOG_INFO" 'Submitting data...'
	curl "${curloptions[@]}" \
        -H "User-Agent: pkgstats/${pkgstatsver}" \
		--data-urlencode "packages@${pkglist}" \
		--data-urlencode "arch=${arch}" \
		--data-urlencode "cpuarch=${cpuarch}" \
		--data-urlencode "mirror=${mirror}" \
		--data-urlencode "quiet=${quiet}" \
		'https://stats.odex.be/post' \
	|| log "$LOG_ERROR" 'Sorry, data could not be sent.' >&2
fi
