#!/usr/bin/env bash
# ala.sh -- arch linux archive explorer, search and download
# v0.15.9  jan/2022  by castaway

#defaults
#script name
SN="${0##*/}"

#default DATE or special repo
DEFALADATE=last

#calculate size of the following repos
DEFCALCREPOS=( core extra community multilib )
#CALCREPOS=( community community-staging community-testing core extra gnome-unstable kde-unstable multilib multilib-staging multilib-testing staging testing )

##default ala server
#official ala archieve
URL=https://archive.archlinux.org/packages
URL2=https://archive.archlinux.org/repos
URL3=https://archive.archlinux.org/iso

##arkena archieve servers -- use option -2
#good alternative archive url but often is down for short while:
BURL=http://archlinux.arkena.net/archive/packages
BURL2=http://archlinux.arkena.net/archive/repos
BURL3=http://archlinux.arkena.net/archive/iso

#mirror server, this is not an archival server
MURLDEF=http://archlinux.c3sl.ufpr.br
#MURLDEF=http://ftp.gwdg.de/pub/linux/archlinux/

#misc servers (experimental)
#repo date from 07/2017; also has fewer packages
#URL=http://archive.virtapi.org/packages
#URL2=http://archive.virtapi.org/repos

#chinese archive URL (only for some pkgs):
#URL=https://repo.archlinuxcn.org/x86_64
#URL2=

#historical repo? hosted by ftp.nluug.nl:
#http://ftp.vim.org/ftp/os/Linux/distr/archlinux
#historical archive for very old arch isos:
#http://skyward.fr/mirror/archlinux/archive/iso

#cache directory
#defaults=/tmp/ala.sh.cache
CACHEDIR="${TMPDIR:-/tmp}/$SN".tmp

#do not change the following
#LC_NUMERIC=en_US.UTF-8
LC_NUMERIC=C
AUTOREPOS=( core extra community )
VALIDREPOS='pool|sources|community|community-staging|community-testing|core|extra|gnome-unstable|kde-unstable|multilib|multilib-staging|multilib-testing|staging|testing'
MONTHSF='january|february|march|april|may|june|july|august|september|october|november|december'
MONTHS='jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec'
MONTHSN='fourth|fifth|sixth|seventh|eighth|ninth|tenth|eleventh|twelfth'
WEEKDAYSF='sunday|monday|tuesday|wednesday|thursday|friday|saturday'
WEEKDAYS='sun|mon|tues?|wed|wednes|thur?s?|fri|sat'
TIMEUNITS='hours?|days?|weeks?|months?|years?|ago|next|hence|this|first' #last
export LC_NUMERIC

#sed html filtering
WBROWSERDEF=(sed -e 's/<[^>]*>//g' -e 's/\&gt;/>/g ;s/\&lt;/</g ;s/&nbsp;/ /g' -e 's/\r//g')

#user agent
#chrome on windows 10
UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'

#script name
SN="${0##*/}"

# Help
HELP="NAME
	$SN -- Arch Linux Archive Explorer


SYNOPSIS
	$SN  [-2p]        ['.'|'/'|a-z|PKGNAME|URLPATH]
	$SN  [-2d]        [DATE] [REPO] [[i686|x86_64] '..']
	$SN  [-2d] [-cc]  [DATE] [REPOS]
	$SN  [-2d] -i     [DATE|URLPATH]
	$SN  [-2d] [-kK]  [PKGNAME|'*'|'.'] [DATE] [REPOS] [i686|x86_64]
	$SN  [-2d] -u     [DATES]
	$SN  -nn          [NUM]
	$SN  -hov

	
	The Arch Linux Archives (aka ALA) stores official repository
	snapshots, iso images and bootstrap tarballs accross time.
	You can use it to downgrade one package to a previous version
	or to find a previous version of an ISO image.

	This script is an ALA explorer. If no argument is given, list
	alphabetic index of package names;  if argument is a dot  \`.' ,
	list all available ALA packages (same as option -a); if a for-
	ward slash \`/' is given, list repos by year. If input is package
	name, the script will list all its package versions, see usage
	example (1).

	Relative URLPATHS can be used to navigate downwards levels. An
	autocomplete operator \`..' to print packages of a repo is avail-
	able, see usage (4 and 5). When using \`..', specifying arch
	\`i686' or \`x86_64' as a positional argument should be valid.

	To disable date auto correction in case of a wrong modification
	to user input, use option -d.

	If the script tries to interpret a PKGNAME as DATE, try seting
	option -p.

	Option -l updates disc cache data and can be set with all options
	that fetch data. This avoids flooding the server with \`mostly'
	static data requests (however special repos change often). Note
	cached data is updated automatically if older than 24 hours, cache
	dir=$CACHEDIR .

	The oficial <archive.archlinux.org> archive was started at end
	of august 2013.


DESCRIPTION
	To navigate ALA, the user can simply run the script with no ar-
	guments. An alphabetic index will be presented. To navigate one
	level down, run the script with one index letter. Next, the user
	will be presented with the packages starting with the chosen
	index letter. Go one level down by running the script with the
	name of the package without the package version numbering.

	Repositories are organised by DATE and assume the numerical for-
	mat YYYY/MM/DD. There are some special date repos named \`last',
	\`week' and \`month'. The week and month special repos are just
	snapshots of mondays and the first day of the month, respective-
	ly. Navigate downwards levels by typing in correct relative path
	elements as arguments for the script. Use \`..' after DATE or a
	special repo to print packages under x86_64 subfolder, see usage
	example number (4). If no repo is set, print  packages from ${AUTOREPOS[*]} .

	The script will try to set the url format for a given DATE, such
	as 20200101, \`2 days ago' or '01 jan 2020'.

	To navigate into specific subrepos/subfolders, use a relative
	url path such as DATE/REPO in which REPO is one listed under a
	DATE, such as: core, extra, community, community-staging,
	community-testing, gnome-unstable, kde-unstable, multilib,
	multilib-staging, multilib-testing, staging and testing.

	To list all packages at ALA and their versions, use option -a or
	operator \`.' with no further positional arguments. To calculate
	the size of repositories (core, extra, etc) of a specific DATE
	use option -c. Default repos to option -c are ${DEFCALCREPOS[*]} .
	Some other repos can be included in the sum function, check the
	script source code, section defaults. Pass twice to get data
	from repo.db.tar.gz files of repos instead from repo html pages.

	Option -k dumps package information of a repo database .db file
	from a given DATE or special repo.  This option requires a pack-
	age name as argument. The option argument will be matched by all
	pkg names starting with that string. Set -k\* or -k. to dump
	information of all pkgs.  A DATE or REPO as positional argument
	is optional. Set -K to dump information of files created by the
	package as well. See usage example (6) and (7).
	
	Option -i will list all ISO repos if no argument is given. DATE
	format used in the ISO repos is normally YYY.MM.DD but older ISO
	repo names vary. In that case, use a valid URLPATH to explore.

	Option -u (or -s) will check lastupdate and lastsync files from
	given DATES. The lastupdate file contains a timestamp of the last
	time any package from any repo (core, extra, etc) was updated.
	On the other hand, servers may check for updates often and update
	their lastsync file even if there is no package change.

	Some settings may be changed at the script head source code,
	section defaults. 


ENVIRONMENT
	\$ALADATE
		Set with repo date, such as special repos last, week,
		month or any valid date such as 2020/01/01.
		Defaults to $DEFALADATE .

	\$CALCREPOS
		Set with REPO names separated by space. It is used in
		option -c to calculate repo sizes. It may be easier to
		just pass multiple REPO names to option -c for the calc-
		ulation. See usage example (3). Defaults to ${DEFCALCREPOS[*]} .

	\$MURL
		Experimental. Not all functions will work.
		Set with mirror-only repository address such as
		$MURLDEF .
		Defaults is unset.


MISCELLANEOUS
	It is possible to sync to any specific repo to use a snapshot
	Arch and sync less frequently. For example, try adding some of
	the following lines to your mirrorlist at /etc/pacman.d/mirrorlist
	to sync to a specific repo and have a fallback:

		Server = https://archive.archlinux.org/repos/month/\$repo/os/\$arch
		Server = http://archlinux.arkena.net/archive/repos/month/\$repo/os/\$arch

		Server = https://archive.archlinux.org/repos/2020/07/01/\$repo/os/\$arch
		Server = https://archive.archlinux.org/repos/2020/07/02/\$repo/os/\$arch
	

	To download an entire snapshot repo with wget, see usage example (8).
	Alternatively, check package powerpill from AUR. For a python script
	to download packages from ALA, check agetpkg from AUR.
	
	More information about ALA at
	<wiki.archlinux.org/index.php/Arch_Linux_Archive>.

	
WARRANTY
	Licensed under the GNU Public License v3 or better. Distributed
	without support or bug corrections.

	This script needs the latest Bash and cURL to work properly.
	Option -nn may need a cli webbrowser such as elinks, lynx or w3m
	to print news text properly.

	If you found this programme interesting, please consider
	giving me a nickle!  =)
  
		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES

	(1) List items in ALA:
		
		$ $SN . 	  #all packages
		$ $SN / 	  #all repos, upmost view
		$ $SN f 	  #packages by index letter
		$ $SN firefox  #packages by exact name


	(2) Calculate repo sizes from specific date or of a special
	    repo; defaults repos calculated are ${AUTOREPOS[*]} :
	
		$ $SN -c 2020/01/01
		

	    Here, we want to calculate sizes of only extra and
	    community  repos from the special date repo last
		
	    	$ $SN -c last extra community


	(3) Navigate downwards levels and autocomplete path of a
	    sup-repo with \`..' . Grouped command lines returns
	    are equivalent here:
	    
	    	$ $SN 2020/01/01/core..
	    	$ $SN 2020/01/01/core/os/x86_64/
	
		$ $SN last/community..
	    	$ $SN last/community/os/x86_64/


	(4) Print repo packages from a DATE, when no repo is given,
	    default repos accessed are ( ${AUTOREPOS[*]} ):
		
		$ $SN 2020/01/01..
		
		$ $SN -- -1week-2days ..
	
	(5) Detailed information of package grep at the week special
	    repository. Set the \`core' repo or defaults to ${AUTOREPOS[*]} .

		$ $SN -k grep week
		$ $SN -k grep week core


		Dump information of all packages starting with firefox
		in extra and community repos of $DEFALADATE:

		$ $SN -k firefox community extra
		$ $SN -k 'firefox-[0-9]' extra


	(6) Get detailed information of all packages of a REPO (core)
	    from an old DATE (extracts data from core.db):

		$ $SN -k. 20160601/core x86_64


		Tip: set -K to dump more info of packages:

		$ $SN -K. 20140601/core
		$ $SN -2k. yesterday extra


	(7) Download an entire repository from given DATE or from a
	    special repo, use Wget. Note that the trailing slash in
	    x86_64/ is required. You may also consider using the -c
	    (--continue) option:
 		
		$ wget -r -np -e robots=off 'https://archive.archlinux.org/repos/2020/01/02/core/os/x86_64/'


	(8) Check which packages differ between two dates:
	
		$ vimdiff <($SN last.. | sort) <($SN month.. | sort)
		
		$ vimdiff <($SN 2020/07/01 core.. ) <($SN 2020/07/13 core ..)

		$ $SN 2020/07/13 .. | grep -vf <($SN 2020/07/01 ..)
	

	(9) Print only packages that are unique (different) between
	     two dates; note that different versions of the same package
	     will be printed. If the package does not change at all,
	     it shall not appear in the list.

		$ { $SN core.. ;$SN last week core.. ;} | sort | uniq -u

		Output from the command above will be sorted; for a better
		organised list (keep different versions of packages under
		their parent date):

		$ { $SN core.. ;$SN last week core.. ;} | nl | sort -k2 | uniq -f1 -u | sort -n | cut -f2


OPTIONS
	Miscellaneous
	-2 	   Set Arkena's archive server.
	-3 	   Set custom mirror server (see environment \$MURL).
	-d 	   Disable auto correction, auto complete and date translation.
	-h 	   Show this help page.
	-l 	   Update disc cache file immediately.
	-p 	   Disambiguation if first pos arg is \`PKGNAME', not \`DATE'.
	-v 	   Show script version.
	Extra Functions
	-n 	   Arch Linux news feed.
	-nn [NUM]  Arch Linux news feed alternative, fetch NUM news.
	-o 	   List unofficial user repos (from Arch Wiki).
	Functions
	-a 	   List all packages and versions from server.
	-c  [DATE] [REPOS]
		   Calculate REPOS sizes from DATE; file sizes from webpage;
		   defaults DATE=$DEFALADATE, REPOS=( ${AUTOREPOS[*]} ).
	-cc [DATE] [REPOS]
		   Same as -c but file sizes are from db.tar.gz.
	-i  DATE   Use the ISO archives.
	-k  PKGNAME [DATE] [REPOS] [i686|x86_64]
		   Dump information of packages; defaults DATE=$DEFALADATE ,
		   REPOS=( ${AUTOREPOS[*]} ).
	-K  PKGNAME [DATE] [REPOS] [i686|x86_64]
		   Same as -k but dumps more info.
	-u, -s [DATES] 
		   Print update and sync times of a DATE repo."

#pkgs with similar fuctionalities, however they are not ala explorers:
#ref: powerpill: https://bbs.archlinux.org/viewtopic.php?id=110136
#ref: agetpkg: https://github.com/seblu/agetpkg

#cache files
#wrapper around curl/wget commands
cachef()
{
	local opt url fname fpath ret
	opt=$1 url="${@: -1}"
	fname="${url/https:\/\/archive.archlinux.org\/}".cache
	fname="${fname//[\/:]/.}" fname="${fname//../.}" fname="${fname//../.}"
	fpath="$CACHEDIR/$fname"

	case $opt in
	0) app=("${YOURAPP[@]}") ;;
	2) app=("${YOURAPP2[@]}") ;;
	3) app=("${YOURAPP3[@]}") ;;
	esac
	
	if [[ ! -s "$fpath" || "$OPTL" -gt 0 || $(find "$fpath" -mtime +1) ]]
	then 	"${app[@]}" "$url" | tee -- "$fpath" ;ret="${PIPESTATUS[0]}"
		grep --color=always -qi -e '404 Not Found' "$fpath" && {
			rm -- "$fpath" 2>/dev/null ;ret=1
		}
	else 	cat -- "$fpath" ;ret=$?
		echo "CACHE: <$fpath>" >&2
	fi

	return ${ret:-0}
}


#consolidate path
consolidatepf()
{
	local p="$1" p_test=

	#remove extra blank spaces
	while 	p_test="$p"
		p="${p//\/.\//\/}" 	#replace /./ with /
		p="${p//\/\//\/}" 	#replace // with /
		p="${p//  / }" 		#remove extra spaces
		[[ "$p_test" != "$p" ]]
	do :
	done

	#re-add a first double slash if url contains any of the following
	[[ "${p// }" = @(https|http|ftp|file|telnet|gopher|mailto|about|wais):* ]] \
		&& p="${p/\//\/\/}"

	#replace spaces with slash
	p="${p// /\/}"

	echo "$p"
}

#check and set cli browser
checkwbrowserf()
{
	local extraflag

	#try and choose terminal browser to process html
	if command -v w3m
	then 	WBROWSER=( w3m -dump -T text/html )
	#don't remove reference links?
	elif command -v lynx
	then 	(( FEEDOPT )) || extraflag=( -nolist )
		WBROWSER=( lynx -force_html -stdin -dump "${extraflag[@]}" )
	#don't remove reference links?
	elif command -v elinks
	then 	(( FEEDOPT )) || extraflag=( -no-references ) 
		WBROWSER=( elinks -dump "${extraflag[@]}" )
	else 	WBROWSER=( "${WBROWSERDEF[@]}" )
		return 1
	fi &>/dev/null

	return 0
}


#functions

#get unix time from user input
#print error msg only if DATE is not human or unix time
dateunixfhelper()
{
	local str str2 seprm fmt

	#out-time format
	fmt=+%s
	#chars to remove
	seprm='[ /._-]*'

	#set string
	str="$*"
	#try this new separator
	sep="$sep"

	#defaults
	if date -d"$str" "$fmt"
	then return 0
	#some unusual date input formats
	elif str2=$(sed -En "s:([0-9]{1,4})(${seprm})([a-zA-Z]{3,}|[0-9]{1,2})(${seprm})([0-9]{1,4}):\1${sep}\3${sep}\5:p" <<<"$str") \
		&& [[ -n "$str2" ]] && date -d"$str2" "$fmt"
	then return 0
	elif str2=$(sed -En "s:([0-9]{1,4})(${seprm})([a-zA-Z]{3,}|[0-9]{1,2})(${seprm})([0-9]{1,4}):\5${sep}\3${sep}\1:p" <<<"$str") \
		&& [[ -n "$str2" ]] && date -d"$str2" "$fmt"
	then return 0
	fi
	
	return 1
}
#check DATE format validity
checkdatef() { 
	local datestr unix sepout sep unix unixmin unixmax
	local STRING

	#-p first arg is a package name
	if (( PKGOPT ))
	then
		return 1
	#-d disable date checking?
	#is calling date repos explicitly with '/'?
	elif (( NOCKOPT )) || [[ "$*" = / ]]
	then
		echo "$@"
		return 0
	fi

	#rm extra chars froma rgs
	set -- "${@#[./]}"
	set -- "${@%[./]}"

	#iso option -i?
	if (( ISOOPT ))
	then
		#save to count chars
		STRING="$*"

		#invalid dates -- print all iso repo dates
		#has user arg? only two chars is definitely not date
		if (( ${#STRING} <= 2 ))
		then
			[[ -n "$*" ]] && printf '%s: warning: invalid -- %s\n' "$SN" "$*" >&2

			echo \/ 
			return 0
		#exception url
		elif [[ "$*" = 0.[0-9] ]] ||
			[[ "$*" =~ ^20[0-2][0-9]\.[0-9]{2}\.?(1|[0-9]{2}|-Linuxtag2007)?$ ]]
		then
			echo "$@"
			return 0
		fi
		#else, try to interpret date string as is

	#only one letter is not date
	elif [[ "$*" = [a-z] ]]
	then
		return 1
	#not a date format
	elif (( ( ${#1} + ${#2} ) < 3 ))
	then
		return 1
	#date repos -- is a good format, complex urls or special repo?
	elif [[ ! "${*,,}" =~ ($MONTHS).? ]] && [[ "${*,,}" = */[a-z]* || "${*,,}" = @(last|week|month) ]]
	then
		echo "$@"
		return 0
	#possible formats
	#complete format
	elif [[ "$*" =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]
	then
		true
	#more correct formats, unset auto-completion
	elif [[ "$*" =~ [0-9]{4}/[0-9]{2}$ ]] ||
		[[ "$*" =~ ^[0-9]{4}$ ]]
	then
		unset AUTOC
		echo "$@"
		return 0
	fi
	#else, maybe user input is right?
	#try to process further

	#try these separators
	for sep in \  \/ \-
	do  unix=$(dateunixfhelper "$@" 2>/dev/null) && break
	done
	
	#is $unix set and is that positive value?
	if (( unix ))
	then
		if 
			#out-of-range?
			unixmin=1072922400
			unixmax=$( date --date=1day +%s )
			(( unix < unixmin )) ||
			(( unix > unixmax ))
		then
			printf '%s: err -- DATE out of range\n' "$SN" >&2
			exit 1
		elif
			#convert back from unix time in the right format
			(( ISOOPT )) && sepout=. || sepout=/
			datestr=$(date -d@"$unix" +%Y${sepout}%m${sepout}%d) &&
			[[ -n "$datestr" ]]
		then
			echo "$datestr"
			return 0 
		fi
	fi
	
	return 1
}

#-c calculate repo sizes
calcf() {
	local arg date i
	local URLADD PAGE PROC SIZESUM PKGS SIGPKGS PKGSUM SIGPKGSUM TSSUM SIZES SSUM

	#test if there is any user repo name input
	#is calling REPOS directly? forgot DATE info?
	if [[ -z "$1" || "$1" =~ ^/?($VALIDREPOS) ]]; then
		set -- "$DEFALADATE" "$@"
	fi
	
	#remove all /
	
	#check DATE format
	#get DATE result from checkdatef
	if date=$(checkdatef "${1//\// }" 2>/dev/null)
	then 	set -- "${date:-$1}" "${@:2}"
	#get DATE result from checkdatef
	elif date=$(checkdatef "${@:1:3}")
	then 	set -- "${date:-${@:1:3}}" "${@:4}"
	else 	printf '%s: invalid DATE -- %s\n' "$SN" "$*" >&2
		exit 1
	fi

	#user set repos to calculate with opt -c?
	if [[ -n "${CALCREPOS[*]}" ]]; then
		#or set an *array* with user opt
		CALCREPOS=( ${CALCREPOS[@]} )
	else
		#if user set REPOS as positional args
		for arg in "$@"
		do 	[[ "$arg" =~ ^/?($VALIDREPOS) ]] && CALCREPOS+=("$arg")
		done

		#or use defaults
		[[ -n "${CALCREPOS[*]}" ]] || CALCREPOS=("${DEFCALCREPOS[@]}")
	fi
	
	#consolidate path (probably not needed here yet)
	URLADD=$(consolidatepf "$URL2/$1")

	#how to get data?
	#from html pages
	if ((COPT==1))
	then
		#header
		printf '%s\n' 'Arch Linux Archive'
		printf '<%s>\n' "$URLADD"
		
		#calc sizes of repos
		for i in "${CALCREPOS[@]}"
		do 	printf 'wait \r' >&2

			#get repo list
			PAGE=$( cachef 3 "$URLADD/$i/os/x86_64/" )
			
			#calc size in the 4th column
			PROC=( $(
				#try to print only the sizes column
				"${WBROWSERDEF[@]}" <<<"$PAGE" |
					awk "{ print \$NF }" | 
					sed -e 's/\r//g ;s/-//g ;/^[[:space:]]*$/d' \
					-e 's/K/*1000/ ;s/M/*1000000/g ;s/G/*1000000000/g ;/[^0-9*]/ d'
			) )

			#sum sizes
			SIZESUM=$( bc <<<"(${PROC[@]/%/+}0)/1000000" ) #bytes to Kb

			#calc stats
			PKGS=$(grep -Ec '\.pkg\.tar\.(gz|xz|zst)"' <<<"$PAGE")
			SIGPKGS=$(grep -Ec '\.pkg\.tar\.(gz|xz|zst)\.sig"' <<<"$PAGE")

			#arrange repo name to print
			i="${i:0:11}"
			printf '%s    \t%5dMB  %5d pkgs  %5d sigs\n' "${i^^}" "$SIZESUM" "$PKGS" "$SIGPKGS"
			
			#grand total sums for next iteration
			PKGSUM=$((PKGSUM+PKGS))
			SIGPKGSUM=$((SIGPKGSUM+SIGPKGS))
			TSSUM=$((TSSUM+SIZESUM))
		done

		#total
		printf 'TOTAL   \t%5dGB  %5d pkgs  %5d sigs\n' "$( bc <<<"$TSSUM/1000" )" "$PKGSUM" "$SIGPKGSUM"
	
	#the following alternative method uses
	#db.tar.gz files from each repo
	else
		#header
		printf '%s\n' 'Arch Linux Archive'
		printf '%s\n' 'Sigs are ignored'
		printf '<%s/*/repo.db.tar.gz>\n' "$URLADD"

		for i in "${CALCREPOS[@]}"; do
			printf 'wait\r' >&2

			#get repo list
			SIZES=( $( {
				cachef 3 "$URLADD/$i/os/x86_64/${i}.db.tar.gz" |
					tar --extract --wildcards -Ozf - '*/desc' |
					sed -n '/%CSIZE%/{n;p}'
			} ) )
			#bsdtar -xf - -O '*/desc'
			
			#sum sizes
			SSUM=$( bc <<<"(${SIZES[@]/%/+}0)/1000000" ) #bytes to Kb

			#arrange repo name to print
			i="${i:0:11}"
			printf '%s    \t%5dMB  %5d pkgs\n' "${i^^}" "$SSUM" "${#SIZES[@]}"
			
			#grand total sums for next iteration
			PKGSUM=$((${#SIZES[@]}+PKGSUM))
			TSSUM=$((TSSUM+SSUM))
		done

		#total
		printf 'TOTAL   \t%5dGB  %5d pkgs\n' "$( bc <<<"$TSSUM/1000" )" "$PKGSUM"
	fi
}

#-k: pkg dump
#$INFOOPTARG will come with a pkg name or a star *
infodumpf() {
	local arg date COMPLETE LASTARG LASTARGX REPOS TGLOB PIPES CURL TAR URLADD


	#check for pkg tar or bsdtar
	if ! command -v tar &>/dev/null
	then 	printf '%s: err -- pkg tar is required\n' "$SN" >&2 ;return 1
	fi
	
	#remove autocomplete operator
	if [[ "$*" = *..* ]]
	then 	set -- "${@//../ }"
	fi

	#is calling repos directly?
	if [[ "$INFOOPTARG" =~ ^/?($VALIDREPOS) ]]
	then
		#is $OPT3 set (experimental)?
		if [[ "$OPT3" ]]
		then 	set -- "$@" "$INFOOPTARG"
		else 	set -- "$DEFALADATE" "$INFOOPTARG" "$@"
		fi
		INFOOPTARG='*'
	fi

	#change glob '.' to '*'
	[[ "$INFOOPTARG" = . ]] && INFOOPTARG='*'

	#test if there is any user repo name input
	#is calling REPOS directly? forgot DATE info?
	if [[ -z "${1// }" || "$1" =~ ^/?($VALIDREPOS) ]]
	then 	set -- "$DEFALADATE" "$@"
	fi
	
	#remove all /
	set --  ${@//\// }
	#get last args
	pos=1
	for arg in "${@:2}"
	do 	lastarghelperf || continue
		#get repo and downwards path
		LASTARGX=( "${@:$pos}" )
		#remove positional args from $pos onwards
		set -- "${@:1:$((pos-1))}"
		break
	done

	#check DATE format
	if date=$( checkdatef "$@" 2>/dev/null )
	then 	set -- "${date:-$@}"
	else 	printf '%s: invalid: DATE -- %s\n' "$SN" "$*" >&2
		exit 1
	fi

	#user set repos
	#if user set REPOS as positional args
	for arg in "${LASTARGX[@]}"
	do 	((counter++))
		[[ "$arg" =~ ^/?($VALIDREPOS) ]] && REPOS+=("$arg")
	done
	[[ -z "${REPOS[*]}" ]] && REPOS=("${AUTOREPOS[@]}")

	#complete path
	#check date for autocomplete
	#no i686 after 2017/11/17
	if [[ "${LASTARGX[*]}" = *i686* ]] || {
		[[ ! "$date" =~ /?(last|week|month)/? ]] &&
		(( $(date -d "$date" +%s) < 1510711200 ))
	} 2>/dev/null
	then
		COMPLETE=os/i686
	fi
	[[ -z "$COMPLETE" || "${LASTARGX[*]}" = *x86_64* ]] && COMPLETE=os/x86_64/

	#asynchronous loop
	for REPO in "${REPOS[@]}"; do
		{
			#consolidate path
			if ((INFOOPT==1))
			then 	URLADD="$URL2/$*/$REPO/$COMPLETE/${REPO}.db.tar.gz"
				TGLOB=( "${INFOOPTARG}*/desc" )
			else 	URLADD="$URL2/$*/$REPO/$COMPLETE/${REPO}.files.tar.gz"
				TGLOB=( "${INFOOPTARG}*/files" "${INFOOPTARG}*/desc" )
			fi

			#consolidate path
			URLADD=$(consolidatepf "$URLADD")
		
			#get database and extract
			cachef 2 -o - "$URLADD" |
				tar --extract --wildcards -Ozf - "${TGLOB[@]}" |
				sed 's/^%FILENAME%$/--------\n\n&/' |
				tac
				#bsdtar -xf - -O "${TGLOB[@]}"
		
			#errors
			PIPES=( "${PIPESTATUS[@]}" )
			CURL="${PIPES[0]}"
			TAR="${PIPES[1]}"
			if (( TAR > 0 || CURL > 0 )) && ((TAR-130))
			then 	echo "$SN: info -- not found at <$URLADD>" >&2
			else 	echo
				echo "query___: $INFOOPTARG"
				echo "database: <$URLADD>"
				#echo "repo: $date/$repo"
			fi
		} &
	done

	#wait for subprocesses
	wait
}
#option '-o -' will not affect wget in a bad fashion for this

#get last args, helper func
lastarghelperf() {

	(( ++pos ))
	[[ -n "$LAST" ]] && (( ++LAST ))
	arg="${arg,,}"
	arg="${arg//[,:-]}"
	{
		[[ "$arg" =~ ^[0-9/]+
		|| "$arg" =~ (pm|am)$
		|| "$arg" =~ ^($MONTHSF)$
		|| "$arg" =~ ^($MONTHS).?$
		|| "$arg" =~ ^($MONTHSN)$ ]] ||
		{ [[ "$arg" =~ ^last$ ]] && (( ++LAST )) ;} ||
		[[ "$arg" =~ ^(week|month)$
		|| "$arg" =~ ^($WEEKDAYSF)\ ?,?$
		|| "$arg" =~ ^($WEEKDAYS)\ ?,?$
		|| "$arg" =~ ^($TIMEUNITS)$ ]]
	} && return 1
	(( LAST - 2 )) || (( --pos ))
	return 0
}
#process html page helper
pagepf() {
	local BUFFER PKGS SIGPKGS

	#test response for 'pkg-not-found'
	if grep -Fiq -e '404 Not Found' <<< "$LIST"; then
		#printf '%s: err: not found -- <%s>\n' "$SN" "$URLADD" >&2
		printf '%s: not found -- %s\n' "$SN" "$URLADD" >&2
		return 1
	fi

	#processs list page
	BUFFER=$( "${WBROWSER[@]}" <<<"$LIST" | sed -e '/^[[:space:]]*$/d' )

	#calc stats
	PKGS=$(grep -Ec '\.pkg\.tar\.(gz|xz|zst)"' <<<"$LIST")
	SIGPKGS=$(grep -Ec '\.pkg\.tar\.(gz|xz|zst)\.sig"' <<<"$LIST")

	#print
	echo "$BUFFER" | sort -V
	[[ "$PKGS$SIGPKGS" != 00 ]] &&
		printf 'Pkgs: %d  Sigs: %d\n' "$PKGS" "$SIGPKGS"
	printf '<%s>\n' "$URLADD"
}
#- search pkg (default opt)
searchf() {
	local arg date pos URLADD COMPLETE LAST LASTARG LASTARGX LIST

	# '..' operator to autocomplete downwards path?
	if [[ "$*" = *..* ]]
	then 	set -- "${@//../ }"
		AUTOC=1
	fi
	
	#is calling (sub)repos or subfolders directly? forgot DATE info?
	[[ "$1" =~ ^/?($VALIDREPOS) ]] && set -- "$DEFALADATE" "$@"
	
	#remove all /
	[[ "$1" != / ]] && set --  ${@//\// }

	#get last args
	pos=1
	for arg in "${@:2}"
	do 	lastarghelperf || continue
		#get repo and downwards path
		LASTARGX=( "${@:$pos}" )
		LASTARG="${LASTARGX[*]}"
		LASTARG="${LASTARG// /\/}"
		#remove positional args from $pos onwards
		set -- "${@:1:$((pos-1))}"
		break
	done

	#test if input is DATE
	if date=$( checkdatef "${@}" )
	then
		#get DATE from checkdatef
		set -- "${date:-$*}"

		#set URLs
		#autocomplete mini system
		if [[ -z "$ISOOPT" ]] && (( AUTOC )); then
			#check date for autocomplete
			[[ "$LASTARG" = */os* ]] || COMPLETE=os

			if [[ "$LASTARG" = *i686* ]]; then
				LASTARG="${LASTARG/i686}"
				COMPLETE=$COMPLETE/i686 
			elif [[ "$LASTARG" = *x86_64* ]]; then
				LASTARG="${LASTARG/x86_64}"
				COMPLETE=$COMPLETE/x86_64
			else
				#no i686 arch after 2017/11/15
				if [[ "$*" = @(last|week|month) || "${*//[^0-9]}" > 20171114 || "$OPT3" ]]; then
					COMPLETE=$COMPLETE/x86_64/
				else
					COMPLETE=$COMPLETE/
				fi
			fi
	
			#community/ and sources/ support only after 2019/01/01
			if [[ "$LASTARG" = @(pool|sources) ]] && 
				[[ "$*" = @(last|week|month) || "${*//[^0-9]}" > 20181231 || "$OPT3" ]]
			then
				#asynchronous loop
				for COMPLETE in /community/ /packages/
				do 	{
						#set url
						URLADD="$URL2/${*}/$LASTARG/$COMPLETE"
						#consolidate path
						URLADD=$(consolidatepf "$URLADD")

						#get data
						LIST=$( cachef 2 "$URLADD" )
	
						#process page
						pagepf
					} &
				done

				#wait for subprocesses
				wait
				exit
			#if no valid repo is detected,
			#auto load defaults repos
			elif [[ ! "$LASTARG" =~ (${VALIDREPOS}) ]]
			then
				#asynchronous loop
				for LASTARG in "${AUTOREPOS[@]}"
				do 	{
						#set url
						URLADD="$URL2/${*}/$LASTARG/$COMPLETE"
						#consolidate path
						URLADD=$(consolidatepf "$URLADD")

						#get data
						LIST=$( cachef 2 "$URLADD" )
	
						#process page
						pagepf  #obs: will not get exit code from subshell
					} &
				done

				#wait for subprocesses
				wait
				exit
			fi
		fi
	
		#set url
		URLADD="$URL2/${*}/$LASTARG/$COMPLETE"
	#test if input is an index letter and set URLs
	elif (( ${#1} == 1 )); then
		#get data and set url
		URLADD="$URL/$1/"
	else
		#set date url
		if [[ "$*" =~ ^[0-9\ /]+$ ]]
		then 	URLADD="$URL2/$*/"
		#if pkg name has version number, try to rm it
		elif [[ "$1" = *[a-z]* ]]
		then 	set -- "${1//-[0-9]*.*}"
			#get data and set url
			URLADD="$URL/${1:0:1}/$1/"
		else 	URLADD="$URL/${*}/"
			#return 1
		fi
	fi
	
	if (( ISOOPT ))
	then 	URLADD="$URL3/${*}/$LASTARG"
	fi
	
	#consolidate path
	URLADD=$(consolidatepf "$URLADD")

	#get page
	LIST=$(cachef 2 "$URLADD")

	#process page
	pagepf
}

#-u -s check last sync opt
lupf() {
	local date dt fmt URLADD TIME

	#if no repo is given, use defaults
	(($#)) || set -- "$DEFALADATE"
	
	#get timestamps for each user argument
	for dt in "$@"
	do
		#test if input is DATE
		#and get DATE from checkdatef
		date=$(checkdatef "$dt") && dt="${date:-$dt}"

		#last update and last sync
		for file in lastupdate lastsync
		do
			#timestamp format
			fmt='%s  %FT%T%Z'
			
			#consolidate path
			URLADD="$URL2/$dt/$file"
			URLADD=$(consolidatepf "$URLADD")
			
			TIME=$(cachef 2 "$URLADD")
			date -d@"$TIME" +"$fmt" 2>/dev/null ||
				sed 's/<[^>]*>//g' <<<"$TIME" >&2
			
			printf '<%s>\n' "$URLADD"
		done
	done
}

#-a list all pkgs from the server
allf() {
	local APKGS UNXZ
	
	#check for pkg unx
	if ! command -v unxz &>/dev/null
	then 	printf '%s: err -- pkg unxz is required\n' "$SN" >&2 ;return 1
	fi

	#get the special .all
	APKGS=$(cachef 0 "$URL/.all/index.0.xz" | unxz)
	UNXZ="${PIPESTATUS[0]}"  #$PIPESTATUS changes every new cmd
	echo >&2

	#error from unxz
	if (( UNXZ > 0 ))
	then 	echo '%s: err: bad xz file' "$SN" >&2 ;return $UNXZ
	fi
	
	#print list and stats
	echo "$APKGS" | sort -V
	echo "Pkgs: $(wc -l <<<"$APKGS")"
	echo "<$URL/.all>"
}

#-n arch news feed
#this is a hack and does not process rss feed very well anymore
feedf() {
	local NEWSPAGE SIGNAL

	#get feed and process
	NEWSPAGE=$(cachef 2 --header "$UAG" 'http://www.archlinux.org/feeds/news/')

	#check for error
	SIGNAL="$?"
	(( SIGNAL > 0 )) && exit $SIGNAL
	
	#process
	NEWSPAGE=$(sed -e ':a;N;$!ba;s/\n/ /g' -e 's/&gt;/ç/g ; s/&nbsp;//g ; s/;code/&\\n/g' \
		-e 's/&lt;\/aç/£/g ; s/href\=\"/§/g ; s/<title>/\n---\n\n :: \\e[01;31m/g' \
		-e 's/<\/title>/\\e[00m ::\n/g ; s/<link>/ [ \\e[01;36m/g' \
		-e 's/<\/link>/\\e[00m ]/g ; s/<description>/\\n\\e[00;37m/g' \
		-e 's/<\/description>/\\e[00m\\n\\n/g ; s/&lt;pç/\n/g' \
		-e 's/&lt;bç\|&lt;strongç/\\e[01;30m/g ; s/&lt;\/bç\|&lt;\/strongç/\\e[00;37m/g' \
		-e 's/&lt;a[^§]*§\([^\"]*\)\"[^ç]*ç\([^£]*\)[^£]*£/\\e[01;32m\2\\e[00;37m \\e[01;34m[ \\e[01;35m\1\\e[00;37m\\e[01;34m ]\\e[00;37m/g' \
		-e 's/&lt;liç/\n \\e[01;34m*\\e[00;37m /g' \
		-e 's/&lt;[^ç]*ç//g ; s/[ç£§]//g ; s/&amp;amp;/\&/g' \
		-e 's/&amp;gt;/>/g ; s/&amp;lt;/</g' \
		-e 's/<[^>]*>/ /g' <<< "$NEWSPAGE")

	#pretty-print
	echo -e "$NEWSPAGE" | sed 's/[^ ]\s*::[^\n]/&\n ::/g' | tac -b -s '---' 
}
#https://bbs.archlinux.org/viewtopic.php?id=30155

#-nn arch news feed alternative
feedfb()
{
	local l articles counter perpage pnum p page links links2 
	
	#defaults
	articles=6 
	perpage=50

	#n of articles to print
	if [[ "$1" = [mM][aA][xX]* ]]
	then 	articles=50
	elif [[ "$1" =~ ^[0-9]+$ ]]
	then 	articles="$1"
	fi

	#get page and links
	pnum=$(( ( articles / perpage ) + 1 ))
	(( articles % perpage )) || (( pnum-- ))
	
	#get all pages
	for ((p=1 ;p<=pnum ;p++))
	do 	page="$page
		$(cachef 2 --header "$UAG" "https://www.archlinux.org/news/?page=$p" 2>/dev/null)"
	done

	#grep only links
	links2=$("${WBROWSERDEF[@]}" <<<"$page" | sed -En '/^\s*<a href=/ s/.*"(\/[^"]+)".*/\1/p')

	#check
	if [[ -z "${links2// }" ]]
	then echo "$SN: script function error" >&2 ;exit 1
	fi
	
	#get NUM links and invert order to print
	#to terminal (more recent is last)
	while read
	do 	(( counter++ ))
		links=( $REPLY ${links[@]} )
		(( counter == articles )) && break
	done <<<"$links2"

	#set cli webbrowser
	checkwbrowserf
	
	#process links
	for l in "${links[@]}"
	do
		#add url prefix
		l="https://www.archlinux.org$l"

		#print simple feedback to stderr
		[[ -t 1 ]] || printf '>>>%s/%s\r' "$counter" "$articles" >&2

		cachef 3 --header "$UAG" "$l" |
			sed -n '/itemprop="headline/,/id="footer/ p' |
			"${WBROWSER[@]}"

		#print uri and separator
		printf '\n\n%s\n========\n' "$l"

		(( counter-- ))
		#try to be a bit nice to the server
		#sleep 0.2
	done
}

#-o list of unofficial user repos
userrepof() { 
	local REPOLIST SIGNAL

	#get list
	REPOLIST=$(cachef 2 'https://wiki.archlinux.org/index.php/Unofficial_user_repositories')

	#check for error
	SIGNAL="$?"
	((SIGNAL > 0)) && exit $SIGNAL
	
	#list and stats
	REPOLIST=$(awk '/^Server =/ { print $3 }' <<<"$REPOLIST")
	echo "$REPOLIST"
	echo "Repos: $(wc -l <<<"$REPOLIST")"
	echo "<https://wiki.archlinux.org/index.php/Unofficial_user_repositories>"
} 
#https://www.linuxsecrets.com/archlinux-wiki/wiki.archlinux.org/index.php/Unofficial_user_repositories.html
#https://wiki.archlinux.org/index.php/Unofficial_user_repositories


#parse options
while getopts :23acdhik:K:lnopsuv opt
do
	case $opt in
		3) #user a mirror server, *not* and archieval server
			OPT3=1
			;;
		2) #try arkena archives, a good alternative archive url
		      #but is down for short while
			URL="$BURL"
			URL2="$BURL2"
			URL3="$BURL3"
			;;
		a) #list all pkgs
			ALLOPT=1
			;;
		c) #calculate repo sizes
			((++COPT))
			;;
		d) #disable date checking and autocorrection
			NOCKOPT=1
			;;
		h) #help
			echo "$HELP"
			exit
			;;
		i) #iso archives
			ISOOPT=1
			;;
		k) #pkg detailed info, also see ':'
			INFOOPT=1
			INFOOPTARG="${OPTARG:-\*}"
			;;
		K) #pkg more detailed info, also see ':'
			INFOOPT=2
			INFOOPTARG="${OPTARG:-\*}"
			;;
		l) #update local cache data
			OPTL=1
			;;
		n) #arch linux news
			((++FEEDOPT))
			;;
		o) #list user repositories
			USERREPOOPT=1
			;;
		p) #set first argument as a package name
			PKGOPT=1
			;;
		u|s) #check last update/sync time of a repo
			LUPOPT=1
			;;
		v) #version of Script
			grep -m1 '# v' "$0"
			exit
			;;
		:) #pkg detailed info
			#probably forgot ARG to opt -K
			[[ "${@:$((OPTIND-1)):1}" = -K ]] && INFOOPT=2 || INFOOPT=1
			INFOOPTARG='*'
			;;
		\?)
			printf '%s: invalid option -- -%s\n' "$SN" "$OPTARG" >&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))
unset opt

#check for pkgs
if command -v curl &>/dev/null; then
	YOURAPP=( curl --compressed -Lb nilcookie )
	YOURAPP2=( "${YOURAPP[@]}" -\# )
	YOURAPP3=( "${YOURAPP[@]}" -s )
elif command -v wget &>/dev/null; then
	YOURAPP=( wget -O- )
	YOURAPP2=( "${YOURAPP[@]}" -q --show-progress )
	YOURAPP3=( "${YOURAPP[@]}" -q )
else
	printf '%s: warning -- curl or wget is required\n' "$SN" >&2
	exit 1
fi

#make a cache directory
[[ -d "$CACHEDIR" ]] || mkdir -- "$CACHEDIR" || exit

#-3 set mirror url or defaults
MURL="${MURL:-$MURLDEF}"
#set the default html filter
WBROWSER=( "${WBROWSERDEF[@]}" )

#use a mirror address instead of archieve?
if [[ "$OPT3" ]]
then
	#disable date checking and autocorrection
	URL2="${MURL%/}"
	NOCKOPT=1
	
	#as this is a mirror address only, DATE must be empty or '.'
	#empty args will be removed later on with reexpanding $@
	set -- . "$@"

	#set cli webbrowser
	checkwbrowserf
fi

#default repo/date?
#user set environment variable $ALADATE ?
[[ -n $ALADATE ]] && DEFALADATE=$ALADATE

#call opt functions
#news feed
if (( FEEDOPT == 1 ))
then 	feedf
elif (( FEEDOPT > 1 ))
then 	feedfb "$@"
#user repositories
elif (( USERREPOOPT ))
then 	userrepof
#list repo all pkgs
elif (( ALLOPT )) || [[ "$OPT3$ISOOPT$1" = . ]]
then 	allf
#last update and sync timestamps
elif (( LUPOPT ))
then 	lupf "${@}"
#calc repo sizes
elif (( COPT ))
then
	#there is no need to calc ``iso'' repo sizes
	if (( ISOOPT ))
	then 	printf '%s: err -- refused\n' "$SN" >&2 ;exit 1
	else 	calcf "${@}"
	fi
#-k dump pkg info only
#also automatically set if last arg matches .db
elif ((INFOOPT))
then 	infodumpf "$@"
#default opt
else
	#parse operator 
	[[ "$*" = .. ]] && set -- "$DEFALADATE" "$@"
	
	#set args for opt functions
	#check repo sizes opt -c
	(( COPT )) && set -- "${@:1:3}"

	#search for package/DATE/repo
	searchf	"${@}"
fi
