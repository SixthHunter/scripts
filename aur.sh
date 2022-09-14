#!/bin/env bash
# aur.sh - list aur packges
# v0.1.1  sep/2022  by mountaineerbr  GPLv3+

#chrome on windows 10
UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'

HELP="${0##*/} - list aur packages

	${0##*/} PKG_NAME [SEARCH_BY] [SORT_BY]
	${0##*/} -p PKG_NAME
	${0##*/} [.|..|'']


	List, sort and print PKGBUILD of  AUR packages.

	Package info scraping can be set. Operator \`.' prints a list with
	all AUR packages, \`..' prints package metadata (json) and empty
	string scrapes too (slow).

	Keys for SEARCH_BY and SORT_BY are as follows:

		nd 	 name/description
		n 	 name
		b 	 pkg base
		N 	 exact name
		B 	 exact pkg base
		k 	 keywords
		m 	 maintainer
		c 	 co-maintainer
		M 	 maintainer/co-maintainer
		s 	 submitter
		v	 votes          #sort only
		p 	 popularity     #sort only
		l 	 last modified  #sort only


OPTIONS
	-h 	This help page.
	-p 	Print package PKGBUILD."


optnf()
{
	case "${1}" in
		nd) 	echo ${2} name/description;;
		n) 	echo ${2} name;;
		b) 	echo ${2} pkg base;;
		N) 	echo ${2} exact name;;
		B) 	echo ${2} exact pkg base;;
		k) 	echo ${2} keywords;;
		m) 	echo ${2} maintainer;;
		c) 	echo ${2} co-maintainer;;
		M) 	echo ${2} maintainer/co-maintainer;;
		s) 	echo ${2} submitter;;
		v)	echo ${2} votes;;          #sort only
		p) 	echo ${2} popularity;;     #sort only
		l) 	echo ${2} last modified;;  #sort only
		'') 	;;
		*) 	return 1;;
	esac
}

#get function
getf()
{
	curl --compressed --insecure -Lb non-existing -H "$UAG" -H 'Referer: https://aur.archlinux.org/packages/' "$@"
}

#aurf helpers
#process aur page
aur_procf()
{
	local n buf REPLY
	sed -n  -e 's/&gt;/>/g ;s/&lt;/</g ;s/&amp;/\&/g ;s/&nbsp;/ /g ;s/&quot;/"/g' \
		-e "s/&#39;/'/g" -e 's/.*<tr\>.*/<p>--------<\/p>\n&/' -e 's/<td>/&@/' \
		-e 's/^\s*//' -e '/<tbody>/,/<\/tbody>/ p' \
	| sed -e 's/<[^>]*>//g' -e '/^\s*$/d' \
	| while ((++n)) ;read
		do 	if [[ $REPLY = --* ]]
			then 	echo "$buf" ;buf= n= 
			else 	buf="${buf:+$buf$'\t'}""${REPLY#@}"
			fi
		done
}
#aur_getf [query] [search_by] [sort_by] [output_start]
aur_getf()
{
	getf "https://aur.archlinux.org/packages?O=${4:-0}&SeB=${2:-n}&K=${1}&outdated=&SB=${3:-n}&SO=d&PP=${pagepkg:-250}&submit=Go"
}
#O   = start of output
#SB  = Sort By:   n - name, v - votes, p - popularity, m - maintainer, l = last modified
#SeB = Search By: n - name, nd - name/description, N - exact name, k - keywords, m - maintainer, s - submitter

#simple aur search
aurf()
{
	local page info pagepkg n
	pagepkg=250  #pkgs per page
	n=1

	page=$(aur_getf "${@:1:3}") || return
	[[ $PKGOPT ]] && { 	echo "$page" ;return ;}
	info=($(sed -n -E -e 's/.*\<([0-9]+) [Pp]ackages [Ff]ound.*/\1/ p' -e 's/.*[Pp]age ([0-9]+) of ([0-9]+).*/\1 \2/ p' <<<"$page"))
	
	fun()
	{
		echo "$page"
		for ((p=pagepkg;p<info[0];p+=pagepkg))    #((p=${info[1]};p<${info[2]};++p))
		do 	echo "page: $((n+1))/${info[2]}    pkgs: ${info[0]}    query: ${QUERY}" >&2
			aur_getf "${@:1:3}" $((++n))
			((OPTSCRAPE)) && sleep 0.6
		done
	}
	if [[ -t 1 ]] && ((!OPTSCRAPE))
	then 	fun | aur_procf | column -s$'\t' -et -NNAME,VERSION,VOTES,POP,DESC,MAINTAINER -RVOTES,POP | less -S
	else 	fun | aur_procf 
	fi
	echo "packages_: ${info[0]:-0}    query: ${QUERY}" >&2
}
#<p>
#    922 packages found.
#        Page 1 of 4.
#   </p>

#get package build
pkgbf()
{
	local url urlb page
	url=https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD
	urlb=https://aur.archlinux.org/packages

	if page=$(getf "$url?h=${1}")
		[[ $page =~ \<div\ class=[\'\"]error[\'\"]\>[Ii]nvalid\ [Bb]ranch: ]]
	then 	if 	[[ $(PKGOPT=1 aurf "$1" n p) =~ \<\a\ href=\"/packages/([^\"/]*)\"\> ]] &&
			[[ $(getf "$urlb/${BASH_REMATCH[1]}") =~ \<\a\ href=\"/pkgbase/([^\"/]*)\"\> ]]
		then 	echo "match: ${BASH_REMATCH[1]}"
			page=$(getf "$url?h=${BASH_REMATCH[1]}")
		else 	return 2
		fi
	fi
	echo "$page"
}

aur_pkgf()
{
	local pkgs url
	if [[ $1 = .. ]]
	then 	url=https://aur.archlinux.org/packages-meta-ext-v1.json.gz
		if command -v jq &>/dev/null
		then 	getf "$url" | jq .
		else 	getf "$url"
		fi
	else 	pkgs=$(getf https://aur.archlinux.org/packages.gz)
		echo "$pkgs"$'\n'"packages_: $(wc -l <<<"$pkgs")"
	fi
}


#parse opts
while getopts aph c
do 	case $c in
		a) 	: compatibility with ala.sh ;;
		h) 	echo "$HELP" ;exit ;;
		p) 	OPTP=1 ;;
		?) 	exit ;;
	esac
done ; unset c
shift $((OPTIND -1))

#set pos args
if [[ ! $1 && ${1+x} ]]
then 	OPTSCRAPE=1
elif [[ $1 = . || $1 = .. ]]
then 	OPTSCRAPE=2
elif [[ ! $1 ]]
then 	echo package name required >&2
	exit 2
fi

if var=$(optnf "${@:$#-1:1}" search_by: && optnf "${@:$#}" sort_by__:)
then 	echo "$var" ;var=("${@:1:$#-2}")
	set -- "${var[*]}" "${@:$#-1:1}" "${@:$#}"
elif optnf "${@:$#}" search_by:
then 	var=("${@:1:$#-1}")
	set -- "${var[*]}" "${@:$#}"
else 	set -- "$*"
fi ;unset var

QUERY="${1:-scrape}"

set -- "${1// /%20}" "${@:2}"

#fun
if ((OPTSCRAPE>1))
then 	aur_pkgf "$@"
elif ((OPTP))
then 	pkgbf "$@"
else 	aurf "$@"
fi

