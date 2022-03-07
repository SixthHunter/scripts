#!/usr/bin/env bash
# datediff.sh - Calculate time ranges between dates (was `ddate.sh')
# v0.16.5  mar/2022  mountaineerbr  GPLv3+
shopt -s extglob

HELP="NAME
	${0##*/} - Calculate time ranges between dates


SYNOPSIS
	${0##*/} [-NUM] [-Rruvvv] [-f\"INPUT_FMT\"] \"DATE1\" \"DATE2\" 
	${0##*/} -l [-v] YEAR
	${0##*/} -h


DESCRIPTION
	Calculate time ranges between DATE1 and DATE2.

	Input DATE strings must be ISO-8601 \`%Y-%m-%dT%H:%M:%S' if using
	\`BSD date' unless option \`-f FMT' is set to a new input time
	format. \`GNU date' accepts mostly free format human readable date
	strings. If \`date' is not available, input must be in ISO-8601
	format.

	If a DATE is not set, defaults to \`now'. To flag DATE as UNIX
	time, prepend an at sign \`@' to it or set option -r (GNU or BSD
	\`date' required). Stdin DATE input is supported, one per line.

	Output DATE section prints two dates in ISO-8601 format or, if
	option -R is set, RFC-5322 format.

	Output RANGES section contains the calculated range displayed in
	different units of time with a floating point (years or months or
	weeks or days or hours or minutes or seconds alone).
	
	It also prints a compound time range with all the above range
	units into consideration to each other.

	Timezone set by environment \$TZ will be read by the \`date' pro-
	gramme, however calculations performed internally set UTC0 always.
	Timezone features are only available with GNU or BSD \`date'.

	Option -l checks if YEAR is leap and exits with 0 if that is true.
	Set option -v to disable leap year checking verbose output.

	Gregorian calendar is assumed. No leap seconds.


ENVIRONMENT
	TZ 	Sets timezone name, read by \`date' programme; internally
		and for debugging UTC0 is always set.


REFINEMENT RULES AND ERROR RATE
	Same date rages can be counted differently in the \`compound time
	range'. We decided to mimic hroptatyr's \`datediff' refinement
	rules as much as possible but differently in some cases.

	Script error rate is estimated to be much lower than one percent
	after extensive testing with selected and corner-case sample dates.


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


EXAMPLES
	Leap year check
	$ ${0##*/} -l 2000

	\`GNU date' wrapping
	$ ${0##*/} 'next monday'
	$ ${0##*/} 2019/6/28 1Aug
	$ ${0##*/} '5min 34seconds' seconds
	$ ${0##*/} 1aug1990-9month now
	$ ${0##*/} -- -2week-3day
	$ ${0##*/} -- \"today + 1day\" @1952292365
	$ ${0##*/} '10 years ago' months
	$ ${0##*/} '1hour ago 30min ago'
	$ ${0##*/} -2 -- today00:00 '12 May 2020 14:50:50' w
	$ ${0##*/} '2020-01-01 - 6months' 2020-01-01  months
	$ ${0##*/} '05 jan 2005' 'now - 43years -13 days' y

	\`BSD date' wrapping
	$ ${0##*/} 2020-01-03T14:30:10 2020-12-24T00:00:00
	$ ${0##*/} 0021-04-12 1999-01-31
	$ ${0##*/} -f'%m/%d/%Y' 6/28/2019 1Aug
	$ ${0##*/} @1561243015 @1592865415


OPTIONS
	-[0-9] 	Set scale for single unit ranges.
	-d 	Debugging, may set multiple times.
	-f FMT 	Input time format string; only with BSD \`date'.
	-h 	Print this help page.
	-l YEAR	Check if YEAR is leap year; YEAR format is YYYY.
	-R 	Print human time in RFC-5322 format. 
	-r 	Input DATES are UNIX times.
	-u 	Print in local time (mind environment \$TZ).
	-v 	Less verbose, may set multiple times."

#WHAT TO EXPECT FROM VERBOSE AND DEGUB FLAGS
#VERBOSE
#no verbose option, print date1 and date2 in results, as well as unix times, when available.
#toggle verbose with option -v.
#verbose less than 3 (-v and -vv): run `date' and `bc'; print single unit ranges.
#verbose less than 2 and more than 2 (-v and -vvv): print compound range.
#DEBUG
#debug one disables verbose mode switches, so most code is run.
#debug one or two (-d, -dd): set UTC=0.
#debug two or more (-dd): set exit signal from debug test against `datediff' and `date' unix time.
#debug three or more (-ddd): do not set UTC=0.

#notes
#hroptatyr's `man datediff' says ``refinement rules'' cover over 99% cases.
#dbplunkett: <https://stackoverflow.com/questions/38641982/converting-date-between-timezones-swift>


#DAYYEAR=146097/400
YEAR_MONTH_DAYS=(31 28 31 30 31 30 31 31 30 31 30 31)
#TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'
TIME_ISO8601_FMT='%Y-%m-%dT%H:%M:%S%z'
#TIME_CUSTOM_FMT='%d/%b/%Y %H:%M:%S'
#`BSD date' input time format defaults
INPUT_FMT="${TIME_ISO8601_FMT:0:17}"  #%Y-%m-%dT%H:%M:%S

#custom `date' command, is BSD-like date?
#DATE_CMD=( )  BSDDATE=0
#
# datefun vars
# Choose between GNU or BSD date
# datefun.sh [-u|-R|-v[val]|-I[fmt]] [YYY-MM-DD|@UNIX] [+OUTPUT_FORMAT]
# datefun.sh [-u|-R|-v[val]|-I[fmt]]
#
# By defaults, input should be UNIX time (append @) or ISO8601 format
# because of BSD date (or set $INPUT_FMT).
# Relative times are not supported, such as `-1d' and `last week'.
# Option -I `fmt' may be `date', `hours', `minutes' or `seconds'.
# Setting environment TZ=UTC0 is equivalent to -u. 
datefun()
{
	local options unix_input input_fmt
	input_fmt="${INPUT_FMT:-$TIME_ISO8601_FMT}"

	#check for options
	[[ "$1" = -[RIv]* ]] && options="$1" && shift

	#run date command
	if ((BSDDATE))
	then
		if [[ "$1" = +([0-9])?(.[0-9][0-9]) ]]  #BSD default fmt `[[[[[cc]yy]mm]dd]HH]MM[.ss]'
		then 	"${DATE_CMD[@]}" ${options} -j "$@" && return
		fi
		[[ "${1:-+}" != @(+|@|-f)* ]] && set -- -f"${input_fmt}" "$@"
		[[ "$1" = @* ]] && set -- "-r${1#@}" "${@:2}"
		"${DATE_CMD[@]}" ${options} -j "$@"
	else
		[[ "${1:-+}" != @(+|-d)* ]] && set -- -d"${unix_input}${1}" "${@:2}"
		"${DATE_CMD[@]}" ${options} "$@"
	fi
}
#test whether BSD or GNU date is available
if ((! ${#DATE_CMD[@]})) && DATE_CMD=(date) && ! date --version
then 	if gdate --version
	then 	DATE_CMD=(gdate)
	elif command -v date
	then 	BSDDATE=1
	else 	DATE_CMD=(false)
	fi
fi >/dev/null 2>&1

#print the maximum number of days of a given month
#usage: month_maxday [MONTH] [YEAR]
month_maxday()
{
	local month="$1" year="$2"
	if (( month == 2 && !(year % 4) && ( year % 100 || !(year % 400) ) ))
	then 	echo 29
	else 	echo ${YEAR_MONTH_DAYS[month-1]}
	fi
}

#check how many days in a year; print number of days of a year.
#year_days()
#{
#	local month="$1" year="$2"
#	if (( !(year % 4) && ( year % 100 || !(year % 400) ) ))
#	then 	echo 366
#	else 	echo 365 ;false
#	fi
#}

#year days, leap years only if date1's month is before or at feb,
#or if date2's month is after feb.
year_days_adj()
{
	local opt="$1" month="$2" year="$3"
	if [[ "$opt" = date1 ]]
	then 	if (( month <= 2 && !(year % 4) && ( year % 100 || !(year % 400) ) ))
		then 	echo 366
		else 	echo 365
		fi
	else 	if (( month > 2 && !(year % 4) && ( year % 100 || !(year % 400) ) ))
		then 	echo 366
		else 	echo 365
		fi
	fi
}

#check for leap year
isleap()
{
	local year="$1"
	if [[ "$year" = [0-9][0-9][0-9][0-9] || "$year" = -[0-9][0-9][0-9][0-9] ]]
	then
		if (( !(year % 4) && ( year % 100 || !(year % 400) ) ))
		then 	((OPTVERBOSE)) || echo "leap year -- $year" ;return 0
		else 	((OPTVERBOSE)) || echo "not leap year -- $year"
		fi
	else
		echo "${0##*/}: err  -- year must be in the format YYYY" >&2
	fi
	return 1
}
#https://stackoverflow.com/questions/32196629/my-shell-script-for-checking-leap-year-is-showing-error

#datediff fun
mainf()
{
	local date1_iso8601 date2_iso8601 unix1 unix2 range neg_sign date_buf_unix date_buf yearA monthA dayA hourA minA secA tzA yearB monthB dayB hourB minB secB tzB ret years_between y_test leapcount daycount_leap_years daycount_years fullmonth_days fullmonth_days_save monthcount month_test date1_month_max_day date2_month_max_day date3_month_max_day d_left y mo w d h m s range_single_w range_single_d range_single_h range_single_m range_print sh ddout dd y_dd mo_dd w_dd d_dd h_dd m_dd s_dd d_save h_save m_save s_save d_left_save range_single_y_days_left range_single_mo_days_left range_single_y_days_left_range range_single_mo_days_left_range range_single_y range_single_mo d_sum var date_buf_unix_tz date_buf_tz date1_iso8601_tz date2_iso8601_tz unix1_tz unix2_tz range_check SS

	#get dates in unix time
	(($# == 1)) && set -- '' "$1"

	#if command `date' is available, get unix times from input string
	if ((OPTVERBOSE<3 || DEBUG)) &&
		unix1=$(TZ=UTC0 datefun "${1:-+%s}" ${1:++%s}) &&
		unix2=$(TZ=UTC0 datefun "${2:-+%s}" ${2:++%s})
	then
		date1_iso8601=$(TZ=UTC0 datefun -Iseconds @"$unix1")
		date2_iso8601=$(TZ=UTC0 datefun -Iseconds @"$unix2")
		if [[ "${TZ^^}" != @(UTC0|UTC) ]]
		then 	unix1_tz=$(datefun "${1:-+%s}" ${1:++%s})
			unix2_tz=$(datefun "${2:-+%s}" ${2:++%s})
			date1_iso8601_tz=$(datefun ${OPTRR:--Iseconds} @"$unix1_tz")
			date2_iso8601_tz=$(datefun ${OPTRR:--Iseconds} @"$unix2_tz")
		fi

		#sort dates
		if ((unix1 > unix2))
		then
			neg_sign=-
			date_buf_unix="$unix1" date_buf="$date1_iso8601"
			date_buf_unix_tz="$unix1_tz" date_buf_tz="$date1_iso8601_tz"
			unix1="$unix2" unix2="$date_buf_unix"
			unix1_tz="$unix2_tz" unix2_tz="$date_buf_unix_tz"
			date1_iso8601="$date2_iso8601" date2_iso8601="$date_buf"
			date1_iso8601_tz="$date2_iso8601_tz" date2_iso8601_tz="$date_buf_tz"
		fi
	else
		unset unix1 unix2
		[[ "$tzA$tzB" ]] && echo "warning: time zone is not supported without \`date' package!" >&2
	fi
	##Time zone / offset support
	#Time zone talk is a complicated business and we should not bother (leave support for `date'!)
	#could support a case statement for UTC/UTC0 and GMT, which should be substituted for +00:00;
	#-00:00 and +24:00 are valid and should equal to +00:00;
	#must decide what to do with environment $TZ, how to interpret input date string with a timezone?
	#support up to `seconds' for time zone adjustment; POSIX time does not account for leap seconds;
	#POSIX defines time zone by the $TZ variable which takes a different form from ISO8601 standards;
	#we should not bother to support offsets or, std (standard) or dst (daylight saving time) in timezones;
	#see: <https://www.iana.org/time-zones>
	#may be easier to support OFFSET instead of TIME ZONE, see distinction:
	#<https://stackoverflow.com/questions/3010035/converting-a-utc-time-to-a-local-time-zone-in-java>
	#America/Sao_Paulo is a timezone ID, not a name. `Pacific Standard Time' is a tz name
		
	#load ISO8601 dates from `date' or user input
	IFS="${IFS}T/.:+-" read yearA monthA dayA hourA minA secA tzA <<<"${date1_iso8601:-${date1_iso8601_tz:-$1}}"
	IFS="${IFS}T/.:+-" read yearB monthB dayB hourB minB secB tzB <<<"${date2_iso8601:-${date2_iso8601_tz:-$2}}"
	#trim leading zeroes, requires bash extended globbing
	for var in yearA monthA dayA hourA minA secA  yearB monthB dayB hourB minB secB  #tzA tzB
	do 	eval "$var=${!var##*(0)}"
	done

	#sort dates if unix times were not generated by `date' previously
	if [[ -z "$unix2" ]] &&
		((
			(yearA>yearB)
			|| ( (yearA==yearB) && (monthA>monthB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA>dayB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA>hourB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA>minB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA==minB) && (secA>secB) )
		))
		#check date sorting, this should not work properly with negative years: (( ( (yearB*366*24*60*60)+(monthB*31*24*60*60)+(dayB*24*60*60)+(hourB*60*60)+(minB*60)+secB) >= ((yearA*366*24*60*60)+(monthA*31*24*60*60)+(dayA*24*60*60)+(hourA*60*60)+(minA*60)+secA) ))
	then
		#swap dates
		neg_sign=-
		set -- "$2" "$1" "${@:3}"
		IFS="${IFS}T/.:+-" read yearA monthA dayA hourA minA secA tzA <<<"$1"
		IFS="${IFS}T/.:+-" read yearB monthB dayB hourB minB secB tzB <<<"$2"
		for var in yearA monthA dayA hourA minA secA  yearB monthB dayB hourB minB secB  #tzA tzB
		do 	eval "$var=${!var##*(0)}"
		done
	fi
	#check input validity
	[[ "${yearA:?user input required}" && "${yearB:?user input required}" && "$yearA$dayA$yearB$dayB" = +([0-9 +-]) ]] || return 2
	((monthA>12 || monthB>12 || hourA>24 || hourB>24 || minA>60 || minB>60 || secA>60 || secB>60 || (dayA>$(month_maxday $monthA $yearA) ) || (dayB>$(month_maxday $monthB $yearB) ) )) && { echo "err: illegal user input" >&2 ;return 2 ;}


	##Count leap years and sum leap and non leap years days,
	##needs to add a condition in the for test when yearA==yearB!
	for ((y_test=(yearA+1);y_test<yearB;++y_test))
	do 	(( !(y_test % 4) && (y_test % 100 || !(y_test % 400) ) )) && ((++leapcount))
		((++years_between))
		((monthcount += 12))
	done
	##count days in non and leap years
	(( daycount_leap_years = (366 * leapcount) ))
	(( daycount_years = (365 * (years_between - leapcount) ) ))


	#date2 days so far this year (this month)
	#days in prior months `this' year
	for ((month_test=(monthB-1);month_test>( (yearA==yearB) ? monthA : 0);--month_test))
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
	for ((month_test=(monthA+1);month_test<( (yearA==yearB) ? monthB : 13);++month_test))
	do
		if (( (month_test == 2) && !(yearA % 4) && (yearA % 100 || !(yearA % 400) ) ))
		then 	(( fullmonth_days += 29 ))
		else 	(( fullmonth_days += ${YEAR_MONTH_DAYS[month_test-1]} ))
		fi
		((++monthcount))
	done
	((fullmonth_days_save = fullmonth_days))

	#need some info about input dates and their context..
	date3_month_max_day=$(month_maxday "$((monthB-1))" "$yearB")
	#date2_month_max_day=$(month_maxday "$monthB" "$yearB")
	date1_month_max_day=$(month_maxday "$monthA" "$yearA")
	#date1_year_days=$(year_days "$monthA" "$yearA")
	#date2_year_days=$(year_days "$monthB" "$yearB")
	date1_year_days_adj=$(year_days_adj date1 "$monthA" "$yearA")
	#date2_year_days_adj=$(year_days_adj date2 "$monthB" "$yearB")


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
	then
		#true refinement rules
		((d_left = ( (date3_month_max_day>=dayA) ? (date3_month_max_day-dayA) : (date1_month_max_day-dayA) ) + dayB ))
		((d_left_save = (date1_month_max_day-dayA) + dayB ))
		if ((date3_month_max_day<date1_month_max_day && (dayB>dayA || (dayA>date3_month_max_day && dayB>1) ) ))
		then 
			((d_left -= date1_month_max_day-date3_month_max_day))
			if ((d_left < 0))
			then 	if ((w))
				then 	((--w , d_left+=7))
				elif ((mo))
				then 	((--mo , w=date3_month_max_day/7 , d_left+=date3_month_max_day%7))
				elif ((y))
				then  	((--y , mo+=11 , w=date3_month_max_day/7 , d_left+=date3_month_max_day%7))
				fi
			fi
		elif ((date3_month_max_day<dayA))
		then 
			if ((mo))
			then 	((--mo))
			elif ((y))
			then  	((--y , mo+=11))
			fi
			((d_left = (date1_month_max_day - dayA + date3_month_max_day + dayB) ))
			((w = d_left/7 , d_left%=7))
		fi
	else
		#`dayA' equals `dayB'
		((++mo))
		((fullmonth_days += date1_month_max_day))
		#((d_left_save = d_left))  #set to 0
	fi


	((h += (24-hourA)+hourB))
	if ((h<24))
	then 	if ((!h))
		then 	:
		elif ((d_left))
		then 	((--d_left , ++ok))
		elif ((mo))
		then 	((--mo , d_left += date3_month_max_day-1 , ++ok))
		elif ((y))
		then  	((--y , mo += 11 , d_left += date3_month_max_day-1 , ++ok))
		fi
	else 	((h %= 24))
	fi

	((m += (60-minA)+minB))
	if ((m<60))
	then 	if ((!m))
		then 	:
		elif ((h))
		then 	((--h))
		elif ((d_left))
		then 	((--d_left , h += 23 , ++ok))
		elif ((mo))
		then 	((--mo , d_left += date3_month_max_day-1 , h += 23 , ++ok))
		elif ((y))
		then  	((--y , mo += 11 , d_left += date3_month_max_day-1 , h += 23 , ++ok))
		fi
	else 	((m %= 60))
	fi

	((s = (60-secA)+secB))
	if ((s<60))
	then 	if ((!s))
		then 	:
		elif ((m))
		then 	((--m))
		elif ((h))
		then 	((--h , m += 59))
		elif ((d_left))
		then  	((--d_left , h += 23 , m += 59 , ++ok))
		elif ((mo))
		then 	((--mo , d_left += date3_month_max_day-1 , h += 23 , m += 59 , ++ok))
		elif ((y))
		then  	((--y , mo += 11 , d_left += date3_month_max_day-1 , h += 23 , m += 59 , ++ok))
		fi
	else 	((s %= 60))
	fi
	((ok && (--d_left_save) ))

	((m += s/60 , s %= 60))
	((h += m/60 , m %= 60))
	((d_left_save += h/24))
	((d_left += h/24 , h %= 24))
	((y += mo/12 , mo %= 12))
	((w += d_left/7))
	((d = d_left%7))


	#total sum of full days
	((d_sum = (  (d_left_save) + (fullmonth_days + daycount_years + daycount_leap_years)  ) ))
	#if [[ $unix2 ]]  #prefer `date' unix times for range if available?
	#then 	((range = unix2-unix1))
	#else
		((range = (d_sum * 3600 * 24) + (h * 3600) + (m * 60) + s))
	#fi

	#calculate time ranges by single units, if bc is available
	if ((OPTVERBOSE<3 || DEBUG)) &&
		range_single_y=$(bc <<<"scale=${SCL:-4}; ${years_between:-0} + ( (${range:-0} - ( (${daycount_years:-0} + ${daycount_leap_years:-0}) * 3600 * 24) ) / (${date1_year_days_adj:-0} * 3600 * 24) )")
	then
		range_single_mo=$(bc <<<"scale=${SCL:-4}; ${monthcount:-0} + ( (${range:-0} - (${fullmonth_days_save:-0} * 3600 * 24) ) / (${date1_month_max_day:-0} * 3600 * 24) )")
		range_single_w=$(bc <<<"scale=${SCL:-4}; ${range:-0} / 604800")
		range_single_d=$(bc <<<"scale=${SCL:-4}; ${range:-0} / 86400")
		range_single_h=$(bc <<<"scale=${SCL:-4}; ${range:-0} / 3600")
		range_single_m=$(bc <<<"scale=${SCL:-4}; ${range:-0} / 60")

		pRHelper $range_single_y && range_print="$range_single_y year$SS"
		pRHelper $range_single_mo && range_print="$range_print${range_print:+" || "}$range_single_mo month$SS"
		pRHelper $range_single_w && range_print="$range_print${range_print:+" || "}$range_single_w week$SS"
		pRHelper $range_single_d && range_print="$range_print${range_print:+" || "}$range_single_d day$SS"
		pRHelper $range_single_h && range_print="$range_print${range_print:+" || "}$range_single_h hour$SS"
		pRHelper $range_single_m && range_print="$range_print${range_print:+" || "}$range_single_m min$SS"
		pRHelper $range ;range_print="$range_print${range_print:+" || "}$range sec$SS"
	fi  #2>/dev/null


	#set printing array with shell results
	sh=("$y" "$mo" "$w" "$d"  "$h" "$m" "$s")
	[[ "${sh[*]}" = *\ -[0-9]* ]] && ret=${ret:-1}  #negative unit error
	
	# Debugging
	if ((DEBUG))
	then 	date1_iso8601="${date1_iso8601:-$1}"  date2_iso8601="${date2_iso8601:-$2}"
		ddout=$(datediff -f'%Y %m %w %d  %H %M %S' "${date1_iso8601:0:19}" "${date2_iso8601:0:19}") || ret=255
		read y_dd mo_dd w_dd d_dd  h_dd m_dd s_dd <<<"$ddout"
		dd=($y_dd $mo_dd $w_dd $d_dd  $h_dd $m_dd $s_dd)
		[[ $unix2 ]] && range_check=$((unix2-unix1))

		{ 	#check compound time range against `date' and DATE against `datediff'
			[[ "$range" = "${range_check:-$range}" ]] &&
			[[ "${sh[*]}" = "${dd[*]}" ]]
		} ||
		{  	echo -ne "\033[2K" >&2
			echo "sh=${sh[*]}"$'\t'"dd=${dd[*]}"$'\t'"${date1_iso8601:0:19} ${date2_iso8601:0:19}"$'\t'"${range:-unavail} ${range_check:-unavail} $a" 
			ret=${ret:-1}
		}
		((DEBUG>1)) && return ${ret:-0}
	fi

	
	#print results
	if ((!OPTVERBOSE || DEBUG))
	then 	printf 'DATES\n%s  %s\n%s  %s\n' "${date1_iso8601_tz:-${date1_iso8601:-$1}}" "${unix1_tz:-$unix1}" "${date2_iso8601_tz:-${date2_iso8601:-$2}}" "${unix2_tz:-$unix2}"
		printf 'RANGES\n'
	fi
	((OPTVERBOSE<3 || DEBUG)) && printf '%s\n' "$range_print"
	((OPTVERBOSE<2 || OPTVERBOSE>2 || DEBUG)) && printf '%dY %02dM %02dW %02dD  %02dH %02dM %02dS\n' "${sh[@]}"

	return ${ret:-0}
}

#check if floating number input is plural, return signal and var SS to ``s''.
pRHelper()
{
	local val valx int dec
	SS= val=${1#-} val=${val#0} valx=${val//[0.]} int=${val%.*}
	[[ $val = *.* ]] && dec=${val#*.} dec=${dec//0}
	((valx)) || return
	(( int>1 || ( (int==1) && (dec) ) )) && SS=s
	return 0
}


## Parse options
while getopts 0123456789df:hlRr@uv opt
do 	case $opt in
		[0-9]) 	SCL="$SCL$opt"
			;;
		d) 	((++DEBUG))
			;;
		f) 	INPUT_FMT="$OPTARG"  #input format string for `BSD date'
			;;
		h) 	echo "$HELP" ;exit
			;;
		l) 	OPTL=1
			;;
		R) 	OPTRR=-R
			;;
		r|@) 	OPTR=1
			;;
		u) 	OPTU=1
			;;
		v) 	((++OPTVERBOSE))
			;;
		\?) 	exit 1
			;;
	esac
done
shift $((OPTIND -1)); unset opt

#set proper environment!
if ((DEBUG<3 && !OPTU))
then 	TZ=UTC0  #LC_ALL=C
fi
export TZ

#scale
SCL="${SCL:-3}"

#stdin input?
if [[ $# -eq 0 && ! -t 0 ]]
then 	IFS= read -r ;[[ $REPLY ]] && set -- "$REPLY"
	IFS= read -r ;[[ $REPLY ]] && set -- "$1" "$REPLY"
	unset REPLY
fi
#-r, unix times?
if ((OPTR))
then  set -- @"${1#@}" @"${2#@}" "${@:3}"
fi

if ((OPTL))
then 	#check for leap year
	isleap "$@"
else 	#main datediff fun
	mainf "$@"
fi
