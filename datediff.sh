#!/usr/bin/env bash
# datediff.sh - Calculate time ranges between dates (was `ddate.sh')
# v0.19  jun/2022  mountaineerbr  GPLv3+
shopt -s extglob  #bash2.05b+

HELP="NAME
	${0##*/} - Calculate time ranges between dates


SYNOPSIS
	${0##*/} [-NUM] [-RruVVvvv] [-f\"FMT\"] \"DATE1\" \"DATE2\" [UNIT]
	${0##*/} -l [-v] YEAR
	${0##*/} -h


DESCRIPTION
	Calculate time intervals between DATE1 and DATE2 or check for leap
	years. The \`date' programme is run to process dates if available.

	\`GNU date' accepts mostly free format human readable date strings.
	Input DATE strings must be ISO-8601 \`%Y-%m-%dT%H:%M:%S' if using
	\`FreeBSD date' unless option \`-f FMT' is set to a new input time
	format. If \`date' programme is not available then input must be
	ISO-8601 formatted.

	If DATE is not set, defaults to \`now'. To flag DATE as UNIX time,
	prepend an at sign \`@' to it or set option -r. Stdin input sup-
	ports one DATE string per line (max two lines) or two ISO-8601
	DATES separated by space in a single line. Input is processed in
	a best effort basis.

	Output INTERVALS section displays calculated ranges in different
	units of time (years or months or weeks or days or hours or min-
	utes or seconds alone). It also displays a compound time range
	with all the above units into consideration to each other.

	Single UNIT time periods can be displayed in table format (-V)
	and their scale set with -NUM where NUM is an integer. When last
	positional parameter UNIT is exactly one of \`y', \`mo', \`w', \`d',
	\`h', \`m' or \`s', only a single UNIT range is printed.

	Output DATE section prints two dates in ISO-8601 format or, if
	option -R is set, RFC-5322 format (when \`date' is available).

	Option -u sets Coordinated Universal Time (UTC) for calculations.

	Option -l checks if YEAR is leap. Set option -v to decrease ver-
	bose and modify output layout. ISO-8601 system assumes proleptic
	Gregorian calendar, year zero and no leap seconds.

	ISO-8601 DATE offset is supported throughout this script. When
	environment \$TZ is a positive or negative decimal number, it is
	interpreted as offset. Variable \$TZ with timezone name or ID
	(e.g. America/Sao_Paulo) is supported by GNU \`date' programme.

	This script uses Bash arithmetics to perform most time range cal-
	culations, as long as input is a valid ISO-8601 date format.


ENVIRONMENT
	TZ 	Offset time. POSIX time zone definition by the \$TZ vari-
		able takes a different form from ISO-8601 standards, so
		that UTC-03 is equivalent to setting \$TZ=UTC+03. Only
		GNU \`date' programme can parse timezone names and IDS.


REFINEMENT RULES
	Some date intervals can be calculated in more than one way depend-
	ing on the logic used in the \`compound time range' display. We
	decided to mimic hroptatyr's \`datediff' refinement rules as often
	as possible.

	Script error rate is estimated to be lower than one percent after
	extensive testing with selected and corner-case sample dates and
	times. Check script source code for details.


SEE ALSO
	\`Datediff' from \`dateutils', by Hroptatyr.
	<www.fresse.org/dateutils/>

	\`Units' from GNU.
	<https://www.gnu.org/software/units/>

	Do calendrical savants use calculation to answer date questions?
	A functional magnetic resonance imaging study, Cowan and Frith, 2009.
	<https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2677581/#!po=21.1864>

	Calendrical calculation, Dershowitz and Reingold, 1990
	<http://www.cs.tau.ac.il/~nachum/papers/cc-paper.pdf>
	<https://books.google.com.br/books?id=DPbx0-qgXu0C>

	How many days are in a year? Manning, 1997.
	<https://pumas.nasa.gov/files/04_21_97_1.pdf>

	Iana Time zone database
	<https://www.iana.org/time-zones>

	Fun with Date Arithmetic (see replies)
	<https://linuxcommando.blogspot.com/2009/11/fun-with-date-arithmetic.html>

	Tip: Division is but subtractions and multiplication but additions.
	--Lost reference


WARRANTY
	Licensed under the GNU General Public License 3 or better. This
	software is distributed without support or bug corrections.

	Bash2.05b+ is required. \`Bc' is required for single-unit calcula-
	tions. FreeBSD12+ or GNU \`date' is optionally required.

	Please consider sending me a nickle!
		=) 	bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr

EXAMPLES
	Leap year check
	$ ${0##*/} -l 2000
	$ ${0##*/} -l {1980..2000}
	$ echo 2000 | ${0##*/} -l

	#Single unit time periods
	$ ${0##*/} 2022-03-01T00:00:00 2022-03-01T10:10:10 m  #(m)ins
	$ ${0##*/} '10 years ago'  mo                         #(mo)nths
	$ ${0##*/} 1970-01-01  2000-02-02  y                  #(y)ears

	Time intervals
	$ ${0##*/} 2020-01-03T14:30:10 2020-12-24T00:00:00
	$ ${0##*/} 0921-04-12 1999-01-31
	$ echo 1970-01-01 2000-02-02 | ${0##*/} 
	$ TZ=UTC+3 ${0##*/}  2020-01-03T14:30:10-06  2021-12-30T21:00:10-03:20

	\`GNU date' warping
	$ ${0##*/} 'next monday'
	$ ${0##*/} 2019/6/28  1Aug
	$ ${0##*/} '5min 34seconds'
	$ ${0##*/} 1aug1990-9month now
	$ ${0##*/} -- -2week-3day
	$ ${0##*/} -- \"today + 1day\" @1952292365
	$ ${0##*/} -2 -- '1hour ago 30min ago'
	$ ${0##*/}  today00:00  '12 May 2020 14:50:50'
	$ ${0##*/} '2020-01-01 - 6months' 2020-01-01
	$ ${0##*/} '05 jan 2005' 'now - 43years -13 days'
	$ ${0##*/} @1561243015 @1592865415

	\`BSD date' warping
	$ ${0##*/} -f'%m/%d/%Y' 6/28/2019  9/04/1970 
	$ ${0##*/} -r 1561243015 1592865415
	$ ${0##*/}  200002280910.33  0003290010.00
	$ ${0##*/} -- '-v +2d' '-v -3w'


OPTIONS
	-[0-9] 	Set scale for single unit intervals.
	-D 	Debug, unset package \`date' warping.
	-dd 	Debug, perform checks (check source for info).
	-f FMT 	Input time format string (only with BSD \`date').
	-h 	Print this help page.
	-l YEAR	Check if YEAR is leap year (YEAR format is YYYY).
	-R 	Print human time in RFC-5322 format (verbose).
	-r, -@ 	Input DATES are UNIX times.
	-u 	Set or print UTC time instead of local time.
	-VV 	Table layout display of single unit intervals.
	-vvv 	Less verbose."

#OPTION DETAILS
#VERBOSE
#no verbose option, print date1 and date2 in results, as well as unix times when available.
#verbose (-v and -vv): run `date' and `bc'; print single unit intervals.
#verbose (-v and -vvv): print compound range.
#
#DEBUGGING -D
#disable `date' programme warping.
#
#DEBUGGING -dd
#debug sets TZ=UTC and disables verbose mode switches, so most code is run.
#debug (-d): check results against `datediff' and `date', print only when results differ.
#debug (-dd): set exit code and exit.


#TESTING RESULTS
#MAIN TESTING SCRIPT: <https://pastebin.com/27RjhjCH>.
#Hroptatyr's `man datediff' says ``refinement rules'' cover over 99% cases.
#Calculated `datediff' error rate is at least .00311 (0.3%) of total tested dates (compound range).
#Results differ from `datediff' in .006275 (0,6%) of all tested dates in script version v0.16.8 (compound range).
#All differences occur with ``end-of-month vs. start-of-month'' dates, such as days `29, 30 or 31' of one date against days `1, 2 or 3' of the other date.
#Different results from `datediff' in compound range are not necessarily errors in all cases and may be considered correct albeit with different refinements. This seem to be the case for most, if not all, differences obtained in testing results.
#No errors were found in range (seconds) calculation, thus single-unit results should all be correct.
#
#OFFSET TESTING SCRIPT: <https://pastebin.com/BvH6PDjC>
#note `datediff' offset ranges between -14h and +14h.
#all offset-aware date results passed checking against `datediff'.
#
#This script was tested with Bash 5.1 and Bash2.05b.

#NOTES
##Time zone / Offset support
#dbplunkett: <https://stackoverflow.com/questions/38641982/converting-date-between-timezones-swift>
#time zone talk is a complicated business, leave it for `date' programme!
#-00:00 and +24:00 are valid and should equal to +00:00;
#support up to `seconds' for time zone adjustment; POSIX time does not
#account for leap seconds; POSIX time zone definition by the $TZ variable
#takes a different form from ISO8601 standards; environment $TZ applies to both dates;
#it is easier to support OFFSET instead of TIME ZONE; should not support
#STD (standard) or DST (daylight saving time) in timezones, only offsets;
# America/Sao_Paulo is a TIMEZONE ID, not NAME; `Pacific Standard Time' is a tz name.
#<https://stackoverflow.com/questions/3010035/converting-a-utc-time-to-a-local-time-zone-in-java>
#<https://www.iana.org/time-zones>, <https://www.w3.org/TR/NOTE-datetime>
#<https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html>
#A year zero does not exist in the Anno Domini (AD) calendar year system
#commonly used to number years in the Gregorian calendar (nor in its
#predecessor, the Julian calendar); in this system, the year 1 BC is
#followed directly by year AD 1. However, there is a year zero in both
#the astronomical year numbering system (where it coincides with the
#Julian year 1 BC), and the ISO 8601:2004 system, the interchange standard
#for all calendar numbering systems (where year zero coincides with the
#Gregorian year 1 BC). In Proleptic Gregorian calendar, year 0000 is leap.
#<https://docs.julialang.org/en/v1/stdlib/Dates/>


#globs
SEP='Tt/.:+-'
GLOBOPT='@(y|mo|w|d|h|m|s|Y|MO|W|D|H|M|S)'
GLOBUTC='*(+|-)@([Uu][Tt][Cc]|[Uu][Cc][Tt]|[Gg][Mm][Tt]|Z|z)'  #see bug ``*?(exp)'' in bash2.05b extglob
GLOBDATE='?(+|-)+([0-9])[/.-]@(1[0-2]|?(0)[1-9])[/.-]@(3[01]|?(0)[1-9]|[12][0-9])'
GLOBTIME='@(2[0-4]|?([01])[0-9]):?([0-5])[0-9]?(:?([0-5])[0-9])?(?(+|-)@(2[0-4]|?([01])[0-9])?(:?([0-5])[0-9])?(:?([0-5])[0-9]))'
#https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch04s07.html

YEAR_MONTH_DAYS=(31 28 31 30 31 30 31 31 30 31 30 31)
TIME_ISO8601_FMT='%Y-%m-%dT%H:%M:%S%z'
#TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'
#`BSD date' input time format defaults:
INPUT_FMT="${TIME_ISO8601_FMT:0:17}"  #%Y-%m-%dT%H:%M:%S - no timezone


# Choose between GNU or BSD date
# datefun.sh [-u|-R|-v[val]|-I[fmt]] [YYY-MM-DD|@UNIX] [+OUTPUT_FORMAT]
# datefun.sh [-u|-R|-v[val]|-I[fmt]]
# By defaults, input should be UNIX time (append @) or ISO8601 format.
# Option -I `fmt' may be `date', `hours', `minutes' or `seconds' (added in FreeBSD12.0).
# Setting environment TZ=UTC is equivalent to -u. 
datefun()
{
	local options unix_input input_fmt globtest ar chars start
	input_fmt="${INPUT_FMT:-$TIME_ISO8601_FMT}"
	[[ $1 = -[RIv]* ]] && options="$1" && shift

	if ((BSDDATE))
	then 	globtest="*([$IFS])@($GLOBDATE?([$SEP])?(+([$SEP])$GLOBTIME)|$GLOBTIME)?([$SEP])*([$IFS])"
		[[ ! $1 ]] && set --
		if [[ $1 = +([0-9])?(.[0-9][0-9]) && ! $OPTF ]]  #default fmt [[[[[cc]yy]mm]dd]HH]MM[.ss]
		then 	"${DATE_CMD}" ${options} -j "$@" && return
		elif [[ $1 = $globtest && ! $OPTF ]]  #ISO8601 variable length
		then 	ar=(${1//[$SEP]/ })
			[[ ${1//[$IFS]} = +([0-9])[:]* ]] && start=9 || start=0
			((chars=(${#ar[@]}*2)+(${#ar[@]}-1) ))
			"${DATE_CMD}" ${options} -j -f "${TIME_ISO8601_FMT:start:chars}" "$@" && return
		fi
		[[ ${1:-+%} != @(+%|@|-f)* ]] && set -- -f"${input_fmt}" "$@"
		[[ $1 = @* ]] && set -- "-r${1#@}" "${@:2}"
		"${DATE_CMD}" ${options} -j "$@"
	else
		[[ ${1:-+%} != @(+%|-d)* ]] && set -- -d"${unix_input}${1}" "${@:2}"
		"${DATE_CMD}" ${options} "$@"
	fi
}
#test for BSD or GNU date
if DATE_CMD=date; ! date --version
then 	if gdate --version
	then 	DATE_CMD=gdate
	elif command -v date
	then 	BSDDATE=1
	else 	DATE_CMD=false
	fi
fi >/dev/null 2>&1

#print the maximum number of days of a given month
#usage: month_maxday [MONTH] [YEAR]
#MONTH range 1-12; YEAR cannot be nought.
month_maxday()
{
	local month year
	month="$1" year="$2"
	if (( month == 2 && !(year % 4) && ( year % 100 || !(year % 400) ) ))
	then 	echo 29
	else 	echo ${YEAR_MONTH_DAYS[month-1]}
	fi
}

#year days, leap years only if date1's month is before or at feb.
year_days_adj()
{
	local month year
	month="$1" year="$2"
	if (( month <= 2 && !(year % 4) && ( year % 100 || !(year % 400) ) ))
	then 	echo 366
	else 	echo 365
	fi
}

#check for leap year
isleap()
{
	local year
	if ((year=${1//[!+-]}10#${1//[+-]})) ;[[ $year ]]
	then
		if (( !(year % 4) && ( year % 100 || !(year % 400) ) ))
		then 	((OPTVERBOSE)) || printf 'leap year -- %04d\n' $year ;return 0
		else 	((OPTVERBOSE)) || printf 'not leap year -- %04d\n' $year
		fi
	else 	echo "err: year must be in the format YYYY" >&2
	fi
	return $((++RET))
}
#https://stackoverflow.com/questions/32196629/my-shell-script-for-checking-leap-year-is-showing-error

#datediff fun
mainf()
{
	local date1_iso8601 date2_iso8601 unix1 unix2 inputA inputB range neg_range date_buf yearA monthA dayA hourA minA secA tzA neg_tzA tzAh tzAm tzAs yearB monthB dayB hourB minB secB tzB neg_tzB tzBh tzBm tzBs ret years_between y_test leapcount daycount_leap_years daycount_years fullmonth_days fullmonth_days_save monthcount month_test month_tgt date1_month_max_day date2_month_max_day date3_month_max_day date1_year_days_adj d_left y mo w d h m s range_y range_mo range_w range_d range_h range_m range_print sh d_left_save d_sum date1_iso8601_pr date2_iso8601_pr yearAtz monthAtz dayAtz hourAtz minAtz secAtz yearBtz monthBtz dayBtz hourBtz minBtz secBtz yearAprtz monthAprtz dayAprtz hourAprtz minAprtz secAprtz yearBprtz monthBprtz dayBprtz hourBprtz minBprtz secBprtz range_check now badges varname var ok ar n p q r v SS SSS TZh TZm TZs TZ_neg TZ_pos

	(($# == 1)) && set -- '' "$1"

	#unix times from input string (when `date' package is available)
	if 	unix1=$(datefun "${1:-+%s}" ${1:++%s}) &&
		unix2=$(datefun "${2:-+%s}" ${2:++%s})
	then 	{
		date1_iso8601=$(datefun -Iseconds @"$unix1")
		date2_iso8601=$(datefun -Iseconds @"$unix2")
		if [[ ! $OPTVERBOSE && $OPTRR ]]
		then 	date1_iso8601_pr=$(datefun -R @"$unix1")
			date2_iso8601_pr=$(datefun -R @"$unix2")
		fi
		}  2>/dev/null  #avoid printing errs from FreeBSD<12 `date'

		#sort dates
		if ((unix1 > unix2))
		then 	neg_range=-1
			pairSwapf unix1 date1_iso8601 date1_iso8601_pr
			set -- "$2" "$1" "${@:3}"
		fi
	else 	unset unix1 unix2
	fi
	
	#set default date -- AD
	[[ ! $1 || ! $2 ]] && now=$(datefun -Iseconds  2>/dev/null) || now=1970-01-01T00:00:00
	[[ ! $1 ]] && set -- "${now:0:19}" "${@:2}"
	[[ ! $2 ]] && set -- "$1" "${now:0:19}" "${@:3}"

	#load ISO8601 dates from `date' or user input
	inputA="${date1_iso8601:-$1}"
	inputB="${date2_iso8601:-$2}"
	IFS="${IFS}${SEP}" read yearA monthA dayA hourA minA secA  tzA <<<"${inputA##*(+|-)}"
	IFS="${IFS}${SEP}" read yearB monthB dayB hourB minB secB  tzB <<<"${inputB##*(+|-)}"
	IFS="${IFS}${SEP/[Tt]}" read tzAh tzAm tzAs  var <<<"${tzA##?($GLOBUTC?(+|-)|[+-])}"
	IFS="${IFS}${SEP/[Tt]}" read tzBh tzBm tzBs  var <<<"${tzB##?($GLOBUTC?(+|-)|[+-])}"
	IFS="${IFS}${SEP/[Tt]}" read TZh TZm TZs  var <<<"${TZ##?($GLOBUTC?(+|-)|[+-])}"

	#negative years
	[[ $inputA = -?* ]] && yearA=-$yearA
	[[ $inputB = -?* ]] && yearB=-$yearB
	monthA=${monthA:-1} monthB=${monthB:-1} dayA=${dayA:-1} dayB=${dayB:-1}
	#
	#iso8601 date string offset
	[[ ${inputA%"${tzA##?($GLOBUTC?(+|-)|[+-])}"} = *?- ]] && neg_tzA=-1 || neg_tzA=+1
	[[ ${inputB%"${tzB##?($GLOBUTC?(+|-)|[+-])}"} = *?- ]] && neg_tzB=-1 || neg_tzB=+1
	((tzAh==0 && tzAm==0 && tzAs==0)) && neg_tzA=+1
	((tzBh==0 && tzBm==0 && tzBs==0)) && neg_tzB=+1
	#
	#environment $TZ
	[[ ${TZ##*$GLOBUTC} = -?* ]] && TZ_neg=-1 || TZ_neg=+1
	((TZh==0 && TZm==0 && TZs==0)) && TZ_neg=+1
	[[ $TZh$TZm$TZs = *([0-9+-]) ]] || unset TZh TZm TZs  #TZ  #$TZ will be unset later

	#set parameters as decimal
	for varname in yearA monthA dayA hourA minA secA  \
		yearB monthB dayB hourB minB secB  \
		tzAh tzAm tzAs  tzBh tzBm tzBs  TZh TZm TZs
	do 	eval "[[ \${$varname} = *[A-Za-z_]* ]] && continue"  #avoid printing errs
		eval "(($varname=\${$varname//[!+-]}10#0\${$varname#[+-]}))"
	done  #https://www.oasys.net/fragments/leading-zeros-in-bash/

	#24h and input leap second support (these $*tz parameters will be zeroed later)
	((hourA==24)) && (( (neg_tzA>0 ? (tzAh-=hourA-23) : (tzAh+=hourA-23) ) , (hourA-=hourA-23) ))
	((hourB==24)) && (( (neg_tzB>0 ? (tzBh-=hourB-23) : (tzBh+=hourB-23) ) , (hourB-=hourB-23) ))
	 ((minA==60)) && (( (neg_tzA>0 ?  (tzAm-=minA-59) :  (tzAm+=minA-59) ) ,   (minA-=minA-59) ))
	 ((minB==60)) && (( (neg_tzB>0 ?  (tzBm-=minB-59) :  (tzBm+=minB-59) ) ,   (minB-=minB-59) ))
	 ((secA==60)) && (( (neg_tzA>0 ?  (tzAs-=secA-59) :  (tzAs+=secA-59) ) ,   (secA-=secA-59) ))
	 ((secB==60)) && (( (neg_tzB>0 ?  (tzBs-=secB-59) :  (tzBs+=secB-59) ) ,   (secB-=secB-59) ))

	#check input validity
	date1_month_max_day=$(month_maxday "$monthA" "$yearA")
	date2_month_max_day=$(month_maxday "$monthB" "$yearB")
	if ! (( (yearA||yearA==0) && (yearB||yearB==0) && monthA && monthB && dayA && dayB)) ||
		((
			monthA>12 || monthB>12 || dayA>date1_month_max_day || dayB>date2_month_max_day
			|| hourA>23 || hourB>23 || minA>59 || minB>59 || secA>59 || secB>59
		))
	then 	echo "err: illegal user input" >&2 ;return 2
	fi

	#offset and $TZ support
	if [[ ! $unix2 ]] && ((tzAh||tzAm||tzAs||tzBh||tzBm||tzBs||TZh||TZm||TZs))
	then 	#check validity
		if ((tzAh>24||tzBh>24||tzAm>60||tzBm>60||tzAs>60||tzBs>60))
		then 	echo "warning: illegal offsets" >&2
			unset tzA tzB  tzAh tzAm tzAs  tzBh tzBm tzBs
		fi
		if ((TZh>23||TZm>59||TZs>59))
		then 	echo "warning: illegal environment \$TZ" >&2
			unset TZh TZm TZs  TZ
		fi 	#offset specs:
		#<https://www.w3.org/TR/NOTE-datetime>
		#<https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html>

		#environment $TZ support  #only for printing
		if ((!OPTVERBOSE)) && ((TZh||TZm||TZs))
		then 	((hourAprtz-=(TZh*TZ_neg) , minAprtz-=(TZm*TZ_neg) , secAprtz-=(TZs*TZ_neg) ))
			((hourBprtz-=(TZh*TZ_neg) , minBprtz-=(TZm*TZ_neg) , secBprtz-=(TZs*TZ_neg) ))
		else 	unset TZh TZm TZs  TZ
		fi

		#convert dates to UTC for internal range calculations
		((tzAh||tzAm||tzAs)) && var="A" || var=
		((tzBh||tzBm||tzBs)) && var="$var B"
		((TZh||TZm||TZs)) && var="$var A.pr B.pr"
		for v in $var  #A B  A.pr B.pr
		do
			[[ $v = ?.* ]] && p=${v#*.} v=${v%.*}  || p=

			#secAtz secBtz  secAprtz secBprtz
			((sec${v}${p}tz=sec${v}-(tz${v}s*neg_tz${v}) ))  #neg_tzA neg_tzB
			if ((sec${v}${p}tz<0))
			then 	((sec${v}${p}tz+=60 , --min${v}${p}tz))
			elif ((sec${v}${p}tz>59))
			then 	((sec${v}${p}tz%=60 , ++min${v}${p}tz))
			fi

			#minAtz minBtz  minAprtz minBprtz
			((min${v}${p}tz+=min${v}-(tz${v}m*neg_tz${v}) ))
			if ((min${v}${p}tz<0))
			then 	((min${v}${p}tz+=60 , --hour${v}${p}tz))
			elif ((min${v}${p}tz>59))
			then 	((min${v}${p}tz%=60 , ++hour${v}${p}tz))
			fi
			
			#hourAtz hourBtz  hourAprtz hourBprtz
			((hour${v}${p}tz+=hour${v}-(tz${v}h*neg_tz${v}) ))
			if ((hour${v}${p}tz<0))
			then 	((hour${v}${p}tz+=24 , --day${v}${p}tz))
			elif ((hour${v}${p}tz>23))
			then 	((hour${v}${p}tz%=24 , ++day${v}${p}tz))
			fi

			#dayAtz dayBtz  dayAprtz dayBprtz
			((day${v}${p}tz+=day${v}))
			if ((day${v}${p}tz<1))
			then 	var=$(month_maxday "$((month${v}==1 ? 12 : month${v}-1))" "$((year${v}))")
				((day${v}${p}tz+=var))
				if ((month${v}>1))
				then 	((--month${v}${p}tz))
				else 	((month${v}${p}tz-=month${v}))
				fi
			elif var=$(month_maxday "$((month${v}))" "$((year${v}))")
				((day${v}${p}tz>var))
			then 	((++month${v}${p}tz))
				((day${v}${p}tz%=var))
			fi
			
			#monthAtz monthBtz  monthAprtz monthBprtz
			((month${v}${p}tz+=month${v}))
			if ((month${v}${p}tz<1))
			then 	((--year${v}${p}tz))
				((month${v}${p}tz+=12))
			elif ((month${v}${p}tz>12))
			then 	((++year${v}${p}tz))
				((month${v}${p}tz%=12))
			fi

			((year${v}${p}tz+=year${v}))  #yearAtz yearBtz  yearAprtz yearBprtz
		done
		#modulus as (a%b + b)%b to avoid negative remainder.
		#however, that is not really necessary for our use
		#case and prevents this loop turning more unreadable.
		#<https://www.geeksforgeeks.org/modulus-on-negative-numbers/>

		if [[ $yearAtz ]]
		then 	(( 	yearA=yearAtz , monthA=monthAtz , dayA=dayAtz,
				hourA=hourAtz , minA=minAtz , secA=secAtz ,
				tzAh=0 , tzAm=0 , tzAs=0
			))
		fi
		if [[ $yearBtz ]]
		then 	(( 	yearB=yearBtz , monthB=monthBtz , dayB=dayBtz,
				hourB=hourBtz , minB=minBtz , secB=secBtz ,
				tzBh=0 , tzBm=0 , tzBs=0
			))
		fi

		((TZ_neg<0)) && TZ_pos=+1 || TZ_pos=-1
		if [[ $yearAprtz ]]
		then 	date1_iso8601_pr=$(printf \
				%04d-%02d-%02dT%02d:%02d:%02d%s%02d:%02d:%02d\\n \
				"$yearAprtz" "$monthAprtz" "${dayAprtz}" \
				"${hourAprtz}" "${minAprtz}" "${secAprtz}" \
				"${TZ_pos%1}" "$TZh" "$TZm" "$TZs")
		fi
		if [[ $yearBprtz ]]
		then 	date2_iso8601_pr=$(printf \
				%04d-%02d-%02dT%02d:%02d:%02d%s%02d:%02d:%02d\\n \
				"$yearBprtz" "$monthBprtz" "${dayBprtz}" \
				"${hourBprtz}" "${minBprtz}" "${secBprtz}" \
				"${TZ_pos%1}" "$TZh" "$TZm" "$TZs")
		fi

	elif [[ ! $unix2$OPTVERBOSE && $tzA$tzB$TZ = *+([A-Za-z_])* ]]
	then 	#echo "warning: input DATE or \$TZ contains timezone ID or name. Support requires package \`date'" >&2
		unset tzA tzB  tzAh tzBh tzAm  tzBm tzAs tzBs  TZh TZm TZs  TZ
	else 	unset tzA tzB  tzAh tzBh tzAm  tzBm tzAs tzBs  TZh TZm TZs  TZ
	fi  #``Offset is *from* UTC''. Environment $TZ applies to both DATES.


	#sort dates (if no `date' package)
	if [[ ! $unix2 ]] && ((
		(yearA>yearB)
		|| ( (yearA==yearB) && (monthA>monthB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA>dayB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA>hourB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA>minB) )
		|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA==minB) && (secA>secB) )
	))
	then 	neg_range=-1
		pairSwapf inputA yearA monthA dayA hourA minA secA \
			yearAtz monthAtz dayAtz hourAtz minAtz secAtz \
			tzA tzAh tzAm tzAs neg_tzA \
			date1_iso8601_pr  #date1_iso8601 unix1
		set -- "$2" "$1" "${@:3}"
	fi
	#`$secXprtz' vars are not needed any longer, so leave them alone.


	##Count leap years and sum leap and non leap years days,
	for ((y_test=(yearA+1);y_test<yearB;++y_test))
	do
		#((y_test==0)) && continue  #ISO8601 counts year zero, proleptic gregorian/julian do not
		(( !(y_test % 4) && (y_test % 100 || !(y_test % 400) ) )) && ((++leapcount))
		((++years_between))
		((monthcount += 12))
	done
	##count days in non and leap years
	(( daycount_leap_years = (366 * leapcount) ))
	(( daycount_years = (365 * (years_between - leapcount) ) ))

	#date2 days so far this year (this month)
	#days in prior months `this' year
	((month_tgt = (yearA==yearB ? monthA : 0) ))
	for ((month_test=(monthB-1);month_test>month_tgt;--month_test))
	do
		if (( (month_test == 2) && !(yearB % 4) && (yearB % 100 || !(yearB % 400) ) ))
		then 	(( fullmonth_days += 29 ))
		else 	(( fullmonth_days += ${YEAR_MONTH_DAYS[month_test-1]} ))
		fi
		((++monthcount))
	done

	#date1 days until end of `that' year
	#days in prior months `that' year
	((yearA==yearB)) ||
	for ((month_test=(monthA+1);month_test<13;++month_test))
	do
		if (( (month_test == 2) && !(yearA % 4) && (yearA % 100 || !(yearA % 400) ) ))
		then 	(( fullmonth_days += 29 ))
		else 	(( fullmonth_days += ${YEAR_MONTH_DAYS[month_test-1]} ))
		fi
		((++monthcount))
	done
	((fullmonth_days_save = fullmonth_days))

	#some info about input dates and their context..
	date3_month_max_day=$(month_maxday "$((monthB==1 ? 12 : monthB-1))" "$yearB")
	#date1_month_max_day=$(month_maxday "$monthA" "$yearA") #this should already be set by now!
	date1_year_days_adj=$(year_days_adj "$monthA" "$yearA")


	#set years and months
	(( y = years_between ))
	(( mo = (  monthcount - ( (years_between) ? (years_between * 12) : 0)  ) ))

	#days left
	if ((yearA==yearB && monthA==monthB))
	then 	
		((d_left = (dayB - dayA) ))
		((d_left_save = d_left))
	elif ((dayA<dayB))
	then
		((++mo))
		((fullmonth_days += date1_month_max_day))
		((d_left = (dayB - dayA) ))
		((d_left_save = d_left))
	elif ((dayA>dayB))
	then 	#refinement rules (or hacks)
		((d_left = ( (date3_month_max_day>=dayA) ? (date3_month_max_day-dayA) : (date1_month_max_day-dayA) ) + dayB ))
		((d_left_save = (date1_month_max_day-dayA) + dayB ))
		if ((dayA>date3_month_max_day && date3_month_max_day<date1_month_max_day && dayB>1))
		then 
			((dayB>=dayA-date3_month_max_day)) &&  ##addon2 -- prevents negative days
			((d_left -= date1_month_max_day-date3_month_max_day))
			((d_left==0 && ( (24-hourA)+hourB<24 || ( (24-hourA)+hourB==24 && (60-minA)+minB<60 ) || ( (24-hourA)+hourB==24 && (60-minA)+minB==60 && (60-secA)+secB<60 ) ) && (++d_left) ))  ##addon3 -- prevents breaking down a full month
			if ((d_left < 0))
			then 	if ((w))
				then 	((--w , d_left+=7))
				elif ((mo))
				then 	((--mo , w=date3_month_max_day/7 , d_left+=date3_month_max_day%7))
				elif ((y))
				then  	((--y , mo+=11 , w=date3_month_max_day/7 , d_left+=date3_month_max_day%7))
				fi
			fi
		elif ((dayA>date3_month_max_day))  #dayB==1
		then
			((d_left = (date1_month_max_day - dayA + date3_month_max_day + dayB) ))
			((w = d_left/7 , d_left%=7))
			if ((mo))
			then 	((--mo))
			elif ((y))
			then  	((--y , mo+=11))
			fi
		fi
	else 	#`dayA' equals `dayB'
		((++mo))
		((fullmonth_days += date1_month_max_day))
		#((d_left_save = d_left))  #set to 0
	fi


	((h += (24-hourA)+hourB))
	if ((h && h<24))
	then 	if ((d_left))
		then 	((--d_left , ++ok))
		elif ((mo))
		then 	((--mo , d_left+=date3_month_max_day-1 , ++ok))
		elif ((y))
		then  	((--y , mo+=11 , d_left+=date3_month_max_day-1 , ++ok))
		fi
	fi
	((h %= 24))

	((m += (60-minA)+minB))
	if ((m && m<60))
	then 	if ((h))
		then 	((--h))
		elif ((d_left))
		then 	((--d_left , h+=23 , ++ok))
		elif ((mo))
		then 	((--mo , d_left+=date3_month_max_day-1 , h+=23 , ++ok))
		elif ((y))
		then  	((--y , mo+=11 , d_left+=date3_month_max_day-1 , h+=23 , ++ok))
		fi
	fi
	((m %= 60))
	
	((s = (60-secA)+secB))
	if ((s && s<60))
	then 	if ((m))
		then 	((--m))
		elif ((h))
		then 	((--h , m+=59))
		elif ((d_left))
		then  	((--d_left , h+=23 , m+=59 , ++ok))
		elif ((mo))
		then 	((--mo , d_left+=date3_month_max_day-1 , h+=23 , m+=59 , ++ok))
		elif ((y))
		then  	((--y , mo+=11 , d_left+=date3_month_max_day-1 , h+=23 , m+=59 , ++ok))
		fi
	fi
	((s %= 60))
	((ok && (--d_left_save) ))

	((m += s/60 , s %= 60))
	((h += m/60 , m %= 60))
	((d_left_save += h/24))
	((d_left += h/24 , h %= 24))
	((y += mo/12 , mo %= 12))
	((w += d_left/7))
	((d = d_left%7))


	#total sum of full days
	#{ range = unix2-unix1 }
	((d_sum = (  (d_left_save) + (fullmonth_days + daycount_years + daycount_leap_years)  ) ))
	((range = (d_sum * 3600 * 24) + (h * 3600) + (m * 60) + s))

	#generate unix times?
	((GETUNIX)) && { 	echo $range ; unset GETUNIX ;return ${ret:1} ;}
	if [[ ! $unix2 ]]
	then 	badges="$badges#"
		if ((
			(yearA>1970 ? yearA-1970 : 1970-yearA)
			> (yearB>1970 ? yearB-1970 : 1970-yearB)
		))
		then 	var=$yearB-$monthB-${dayB}T$hourB:$minB:$secB  varname=B #utc times
		else 	var=$yearA-$monthA-${dayA}T$hourA:$minA:$secA  varname=A
		fi

		var=$(GETUNIX=1 DATE_CMD=false OPTVERBOSE=1 OPTRR= TZ=  \
			mainf 1970-01-01T00:00:00 $var ) || ((ret+=$?))

		((year${varname}<1970)) && ((var*=-1))
		if [[ $varname = B ]]
		then 	((unix2=var , unix1=unix2-range))
		else 	((unix1=var , unix2=unix1+range))
		fi
	fi

	#single unit time ranges (when `bc' is available)
	if { 	(( (!OPTT&&OPTVERBOSE<3)||OPTTy)) &&
		range_y=$(bc <<<"scale=${SCL}; ${years_between:-0} + ( (${range:-0} - ( (${daycount_years:-0} + ${daycount_leap_years:-0}) * 3600 * 24) ) / (${date1_year_days_adj:-0} * 3600 * 24) )")
		} || ((OPTT))
	then
		((!OPTT||OPTTmo)) && range_mo=$(bc <<<"scale=${SCL}; ${monthcount:-0} + ( (${range:-0} - (${fullmonth_days_save:-0} * 3600 * 24) ) / (${date1_month_max_day:-0} * 3600 * 24) )")
		((!OPTT||OPTTw)) && range_w=$(bc <<<"scale=${SCL}; ${range:-0} / 604800")
		((!OPTT||OPTTd)) && range_d=$(bc <<<"scale=${SCL}; ${range:-0} / 86400")
		((!OPTT||OPTTh)) && range_h=$(bc <<<"scale=${SCL}; ${range:-0} / 3600")
		((!OPTT||OPTTm)) && range_m=$(bc <<<"scale=${SCL}; ${range:-0} / 60")

		#choose layout of single units
		if ((! OPTLAYOUT || OPTT))
		then 	#layout one
			prHelpf $range_y && range_print="$range_y year$SS"
			prHelpf $range_mo && range_print="$range_print | $range_mo month$SS"
			prHelpf $range_w && range_print="$range_print | $range_w week$SS"
			prHelpf $range_d && range_print="$range_print | $range_d day$SS"
			prHelpf $range_h && range_print="$range_print | $range_h hour$SS"
			prHelpf $range_m && range_print="$range_print | $range_m min$SS"
			prHelpf $range  ;((!OPTT||OPTTs)) && range_print="$range_print | $range sec$SS"
			range_print="${range_print# | }"
		else 	#layout two
			for r in ${#range_y} ${#range_mo} ${#range_w} ${#range_d} ${#range_h} ${#range_m} $((${#range}+SCL+1))
			do ((r>n && (n=r) ))
			done
			prHelpf $range_y $n && range_print=Year$SS$'\t'$SSS$range_y
			prHelpf $range_mo $n && range_print="$range_print"$'\n'Month$SS$'\t'$SSS$range_mo
			prHelpf $range_w $n && range_print="$range_print"$'\n'Week$SS$'\t'$SSS$range_w
			prHelpf $range_d $n && range_print="$range_print"$'\n'Day$SS$'\t'$SSS$range_d
			prHelpf $range_h $n && range_print="$range_print"$'\n'Hour$SS$'\t'$SSS$range_h
			prHelpf $range_m $n && range_print="$range_print"$'\n'Min$SS$'\t'$SSS$range_m
			prHelpf $range $((n - (SCL>0 ? (SCL+1) : 0) ))
			range_print="$range_print"$'\n'Sec$SS$'\t'$SSS$range
			range_print="${range_print#[$IFS]}"
			#https://www.themathdoctors.org/should-we-put-zero-before-a-decimal-point/
			((OPTLAYOUT>1)) && { 	p= q=. ;for ((p=0;p<SCL;++p)) ;do q="${q}0" ;done
				range_print="${range_print// ./0.}" range_print="${range_print}${q}"
			}
		fi
	fi  #2>/dev/null

	#set printing array with shell results
	sh=("$y" "$mo" "$w" "$d"  "$h" "$m" "$s")
	((y<0||mo<0||w<0||d<0||h<0||m<0||s<0)) && ret=${ret:-1}  #negative unit error
	
	# Debugging
	if ((DEBUG))
	then
		#!#
		debugf "$@"
	fi
	
	#print results
	if ((!OPTVERBOSE))
	then 	if [[ ! $date1_iso8601_pr$date1_iso8601 ]] 
		then	date1_iso8601=$(printf \
				%04d-%02d-%02dT%02d:%02d:%02d%s%02d:%02d:%02d\\n \
				"$yearA" "$monthA" "$dayA"  \
				"$hourA" "$minA" "$secA"  \
				"${neg_tzA%1}" "$tzAh" "$tzAm" "$tzAs")
			date1_iso8601=${date1_iso8601%%*(:00)}
		else 	date1_iso8601_pr=${date1_iso8601_pr%%*(:00)}  #remove excess zeroes
		fi
		if [[ ! $date2_iso8601_pr$date2_iso8601 ]] 
		then	date2_iso8601=$(printf \
				%04d-%02d-%02dT%02d:%02d:%02d%s%02d:%02d:%02d\\n \
				"$yearB" "$monthB" "$dayB"  \
				"$hourB" "$minB" "$secB"  \
				"${neg_tzB%1}" "$tzBh" "$tzBm" "$tzBs")
			date2_iso8601=${date2_iso8601%%*(:00)}
		else 	date2_iso8601_pr=${date2_iso8601_pr%%*(:00)}
		fi

		printf '%s%s\n%s%s%s\n%s%s%s\n%s\n'  \
			DATES "${badges}${neg_range%1}"  \
			"${date1_iso8601_pr:-${date1_iso8601:-$inputA}}" ''${unix1:+$'\t'} "$unix1"  \
			"${date2_iso8601_pr:-${date2_iso8601:-$inputB}}" ''${unix2:+$'\t'} "$unix2"  \
			INTERVALS
	fi
	((OPTVERBOSE<3)) && printf '%s\n' "${range_print:-$range secs}"
	((OPTVERBOSE<2 || OPTVERBOSE>2)) && printf '%dY %02dM %02dW %02dD  %02dh %02dm %02ds\n' "${sh[@]}"

	return ${ret:-0}
}

#execute result checks against `datediff' and `date'
debugf()
{
		local iA iB tA tB dd ddout y_dd mo_dd w_dd d_dd h_dd m_dd s_dd range_check unix1t unix2t checkA_pr checkB_pr  checkA_utc checkB_utc date_cmd_save
		date_cmd_save=$DATE_CMD  DATE_CMD=date
		TZ=UTC${TZ##*$GLOBUTC}

		#fix original input strings
		iB="${inputB:0:25}" iA="${inputA:0:25}"
		((${#iB}==10)) && iB=${iB}T00:00:00
		((${#iA}==10)) && iA=${iA}T00:00:00
		((${#iB}==19)) && iB="${iB}+00:00"
		((${#iA}==19)) && iA="${iA}+00:00"
		iB=${iB/-00:00/+00:00} iA=${iA/-00:00/+00:00}

		#utc time strings
		tB=$(printf \
			%04d-%02d-%02dT%02d:%02d:%02d%s%02d:%02d\\n \
			"$yearB" "$monthB" "$dayB"  \
			"$hourB" "$minB" "$secB"  \
			"${neg_tzB%1}" $tzBh $tzBm)
		tA=$(printf \
			%04d-%02d-%02dT%02d:%02d:%02d%s%02d:%02d\\n \
			"$yearA" "$monthA" "$dayA"  \
			"$hourA" "$minA" "$secA"  \
			"${neg_tzA%1}" $tzAh $tzAm)
		tB=${tB:0:25} tA=${tA:0:25}
		tB=${tB/-00:00/+00:00} tA=${tA/-00:00/+00:00}

		if [[ $date_cmd_save = false ]]
		then
			if ((TZs)) || [[ $TZ = *:*:*:* ]]
			then 	echo "warning: \`datediff' cannot take offset with seconds" >&2
				((ret+=230))
			fi

			if ((TZh||TZm))
			then 	checkB_pr=$(datefun -Iseconds $iB)
				checkA_pr=$(datefun -Iseconds $iA)
			else 	checkB_pr=$date2_iso8601_pr checkA_pr=$date1_iso8601_pr
			fi

			checkB_utc=$(TZ=UTC datefun -Iseconds $iB)
			checkA_utc=$(TZ=UTC datefun -Iseconds $iA)
			#`date' iso offset must not exceed minute precision [+-]XX:XX !

			#check generated unix times against `date'
			unix2t=$(datefun "$iB" +%s)
 			unix1t=$(datefun "$iA" +%s)
			range_check=$((unix2t-unix1t))
		fi

		#compound range check against `datediff'
		#`datediff' offset range is between -14h and +14h!
		ddout=$(datediff -f'%Y %m %w %d  %H %M %S' "$iA" "$iB") || ((ret+=250))
		read y_dd mo_dd w_dd d_dd  h_dd m_dd s_dd <<<"$ddout"
		dd=(${y_dd#-} $mo_dd $w_dd $d_dd  $h_dd $m_dd $s_dd)

		DATE_CMD=$date_cmd_save
		{
			[[ ${date2_iso8601_pr:0:25} = $checkB_pr ]] &&
			[[ ${date1_iso8601_pr:0:25} = $checkA_pr ]] &&
			
			[[ $tB = ${checkB_utc:-$tB} ]] &&
			[[ $tA = ${checkA_utc:-$tA} ]] &&
			
			[[ $unix1 = ${unix1t:-$unix1} && $unix2 = ${unix2t:-$unix2} ]] &&
		 	[[ $range = "${range_check:-$range}" ]] &&
			
			[[ ${sh[*]} = "${dd[*]:-${sh[*]}}" ]]
		} || { 	echo -ne "\033[2K" >&2
			echo "\
sh=${sh[*]} dd=${dd[*]} | "\
"$iA $iB | "\
"${range:-unavail} ${range_check:-unavail} | "\
"${date1_iso8601_pr:0:25} $checkA_pr | "\
"${date2_iso8601_pr:0:25} $checkB_pr | "\
"$tB $checkB_utc | "\
"$tA $checkA_utc | "\
"${date_cmd_save%date}"

			((ret+=1))
		}

		#((DEBUG>1)) && return ${ret:-0}  #!# 
		((DEBUG>1)) && exit ${ret:-0}  #!# 
		return 0
}

#swap $varA/$varB or $var1/$var2 values
pairSwapf()
{
	local varname buf p q
	for varname
	do 	[[ $varname = *A* ]] &&  p=A q=B  ||  p=1 q=2
		eval "buf=\"\$$varname\""
		eval "$varname=\"\$${varname/$p/$q}\" ${varname/$p/$q}=\"\$buf\""
	done
}

#printing helper
#(A). check if floating point in $1 is `>0', set return signal and $SS to `s' when `>1.0'.
#usage: prHelpf 1.23
#(B). set padding of $1 length until [max] chars and set $SSS.
#usage: prHelpf 1.23  [max]
prHelpf()
{
	local val valx int dec  x z
	
	#(B)
	if (($#>1))
	then 	SSS=  x=$(( ${2} - ${#1} ))
		for ((z=0;z<x;++z))
		do 	SSS="$SSS "
		done
	fi

	#(A)
	SS=  val=${1#-} val=${val#0} valx=${val//[0.]} int=${val%.*}
	[[ $val = *.* ]] && dec=${val#*.} dec=${dec//0}
	[[ $1 && $OPTT ]] || ((valx)) || return
	(( int>1 || ( (int==1) && (dec) ) )) && SS=s
	return 0
}


## Parse options
while getopts 0123456790Ddf:hlRr@uVv opt
do 	case $opt in
		[0-9]) 	SCL="$SCL$opt"
			;;
		d) 	((++DEBUG))
			;;
		D) 	DATE_CMD=false  #disable `date' command warping
			;;
		f) 	INPUT_FMT="$OPTARG" OPTF=1  #input format string for `BSD date'
			;;
		h) 	while read
			do 	[[ "$REPLY" = \#\ v* ]] && echo "$REPLY" && break
			done <"$0"
			echo "$HELP" ;exit
			;;
		l) 	OPTL=1
			;;
		R) 	OPTRR=1
			;;
		r|@) 	OPTR=1
			;;
		u) 	OPTU=1
			;;
		V) 	((++OPTLAYOUT))
			;;
		v) 	((++OPTVERBOSE))
			;;
		\?) 	exit 1
			;;
	esac
done
shift $((OPTIND -1)); unset opt

#set proper environment!
SCL="${SCL:-3}"  #scale defaults
((OPTU)) && TZ=UTC  #set UTC time zone
export TZ

#stdin input
[[ ${1//[$IFS]} = $GLOBOPT ]] && opt="$1" && shift
if [[ $# -eq 0 && ! -t 0 ]]
then
	globtest="*([$IFS])@($GLOBDATE?(+([$SEP])$GLOBTIME)|$GLOBTIME)*([$IFS])@($GLOBDATE?(+([$SEP])$GLOBTIME)|$GLOBTIME)?(+([$IFS])$GLOBOPT)*([$IFS])"  #glob for two ISO8601 dates and possibly pos arg option for single unit range
	while IFS= read -r || [[ $REPLY ]]
	do 	ar=($REPLY) ;((${#ar[@]})) || continue
		if ((!$#))
		then 	set -- "$REPLY" ;((OPTL)) && break
			#check if arg contains TWO ISO8601 dates and break
			if [[ (${#ar[@]} -eq 3 || ${#ar[@]} -eq 2) && \ $REPLY = @(*[$IFS]$GLOBOPT*|$globtest) ]]
			then 	set -- $REPLY  ;[[ $1 = $GLOBOPT ]] || break
			fi
		else 	if [[ ${#ar[@]} -eq 2 && \ $REPLY = @(*[$IFS]$GLOBOPT|$globtest) ]]
			then 	set -- "$@" $REPLY
			else 	set -- "$@" "$REPLY"
			fi ;break
		fi
	done ;unset ar globtest REPLY
	[[ ${1//[$IFS]} = $GLOBOPT ]] && opt="$1" && shift
fi
[[ $opt ]] && set -- "$@" "$opt"

#print single time unit?
opt="${opt:-${@: -1}}" opt="${opt//[$IFS]}"
if [[ $opt = $GLOBOPT ]]
then 	OPTT=1 OPTVERBOSE=2 OPTLAYOUT=
	case $opt in
		[yY]) 	OPTTy=1;;
		[mM][oO]) 	OPTTmo=1;;
		[wW]) 	OPTTw=1;;
		[dD]) 	OPTTd=1;;
		[hH]) 	OPTTh=1;;
		[mM]) 	OPTTm=1;;
		[sS]) 	OPTTs=1;;
	esac ;set -- "${@:1:$#-1}"
fi ;unset opt
#caveat: `gnu date' understands `-d[a-z]', do `-d[a-z]0' to pass.
[[ $1 = [a-zA-Z] || $2 = [a-zA-Z] ]] && { 	echo "err: illegal user input" >&2 ;exit 2 ;} 

#whitespace trimming
if (($#>1))
then 	set -- "${1#"${1%%[!$IFS]*}"}" "${2#"${2%%[!$IFS]*}"}" "${@:3}"
	set -- "${1%"${1##*[!$IFS]}"}" "${2%"${2##*[!$IFS]}"}" "${@:3}"
elif (($#))
then 	set -- "${1#"${1%%[!$IFS]*}"}" ;set -- "${1%"${1##*[!$IFS]}"}"
fi

#-r, unix times
if ((OPTR && $#>1))
then 	set -- @"${1#@}" @"${2#@}" "${@:3}"
elif ((OPTR && $#))
then 	set -- @"${1#@}"
fi

if ((OPTL))
then 	#leap year check
	for year in $*
	do 	isleap $year
	done
else 	#datediff fun
	mainf "$@"
fi
