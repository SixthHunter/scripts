#!/usr/bin/env bash
# ddate.sh - Calculate time ranges between dates
# v0.15.9  jan/2022  mountaineerbr  GPLv3+
shopt -s extglob
	# DEVELOPMENT OF THIS SCRIPT HAS BEEN HALTED BECAUSE
	# THE DEVELOPER DOES NOT KNOW WHAT IS GOING ON ANYMORE!
	# SEE BUGS, REFINEMENT RULES AND CODE COMMENTS.

HELP="NAME
	${0##*/} - Calculate time ranges between dates


SYNOPSIS
	${0##*/} [-NUM] [-Ru] [-f\"INPUT_FMT\"] \"DATE1\" \"DATE2\" 
	${0##*/} -l [-v] YEAR
	${0##*/} -h


	#*#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#
	*#*#**#*#**#*#**#*#** EXPERIMENTAL SCRIPT **#*#**#*#**#*#**#*#*
	#*#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#*#**#


DESCRIPTION
	Calculate time ranges between DATE1 and DATE2.

	The output DATE section contains the two dates in ISO-8601 format
	or RFC-5322 if option -R is set.

	The RAGES section contains the calculated range displayed in dif-
	ferent units of time with a floating point, that is years or
	months or weeks or days or hours or minutes or seconds alone.
	
	It also displays a compound range with all the above range units
	into consideration.

	DATE strings must be ISO-8601 \`%Y-%m-%dT%H:%M:%S' if using FreeBSD
	\`date' or set an input time format with option \`-f FMT'. On the
	other hand, GNU \`date' accepts mostly free format human readable
	date strings. If \`date' is not available, input must be in ISO-8601
	format.

	If a DATE is not set, defaults to \`now'. To flag any DATE as UNIX
	time, prepend an at sign \`@' to it.

	Timezone set by environment \$TZ will be read by the \`date' pro-
	gramme, however calculations are performed internally with UTC0
	always. Timezone is not supported if \`date' is not available.

	Option -l checks if YEAR is leap and exits with 0 if that is.
	Set option -v to disable leap year checking verbose output.

	Gregorian calendar is assumed. No leap seconds.


ENVIRONMENT
	TZ 	Sets timezone name, read by \`date' programme; internally
		and for debugging UTC0 is always set.


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
	--Lost


BUGS
	Testing reveals about 2% error rate of the compound range, special-
	ly with dates in February and/or different times between dates, when
	compared to the output of \`datediff'. This is manily due to incon-
	sistent refinement rules in this script. Testing was limited, thus
	we cannot more precisely determine error types (and their fix) nor
	generalise error rate.

	This script needs a well defined methodology of refining rules
	for the compound calculation range. Currently, refinement rules
	are poorly understood by this developer..

	Please check \`datediff' from \`dateutils' suite for a stable
	solution.


EXAMPLES

	Leap year check
	$ ${0##*/} -l 2000

	GNU \`date' wrapping
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

	FreeBSD \`date' wrapping
	$ ${0##*/} 2020-01-03T14:30:10 2020-12-24T00:00:00
	$ ${0##*/} 0021-04-12 1999-01-31
	$ ${0##*/} -f'%m/%d/%Y' 6/28/2019 1Aug
	$ ${0##*/} @1561243015 @1592865415


OPTIONS
	-[0-9] 	Set scale for single unit ranges.
	-d 	Debugging, check results against \`datediff', dump
		debug info if exit greater than zero.
	-f FMT 	Input time format string; only with BSD \`date'.
	-h 	Print this help page.
	-l YEAR	Check if YEAR is leap year; YEAR format is YYYY.
	-u 	Print in local time.
	-R 	Print human time in RFC-5322 format. 
	-v 	Less verbose."
#note: `man datediff' says ``refinement rules'' cover over 99% cases.
#see:  comments and answer from dbplunkett:
#<https://stackoverflow.com/questions/38641982/converting-date-between-timezones-swift>


#DAYYEAR=146097/400
YEAR_MONTH_DAYS=(31 28 31 30 31 30 31 31 30 31 30 31)
#TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'
TIME_ISO8601_FMT='%Y-%m-%dT%H:%M:%S%z'
TIME_CUSTOM_FMT='%d/%b/%Y %H:%M:%S'
#FreeBSD `date' input time format defaults
INPUT_FMT="${TIME_ISO8601_FMT:0:17}"  #%Y-%m-%dT%H:%M:%S

#custom `date' command, is BSD-like date?
#DATE_CMD=( )  BSDDATE=0

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
		[[ "${1:-+}" != @(+|@|-f)* ]] && set -- -f"${input_fmt}" "$@"
		[[ "$1" = @* ]] && set -- "-r${1#@}" "${@:2}"
		"${DATE_CMD[@]}" ${options} -j "$@"
	else
		[[ "${1:-+}" != @(+|-d)* ]] && set -- -d"${unix_input}${1}" "${@:2}"
		"${DATE_CMD[@]}" ${options} "$@"
	fi
}
#
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
#check how many days in a year
#print number of days of a year
year_days()
{
	local month="$1" year="$2"
	if (( !(year % 4) && ( year % 100 || !(year % 400) ) ))
	then 	echo 366
	else 	echo 365 ;false
	fi
}
#below, leap years only if date1's month is before or at feb,
#or if date2's month is after feb
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

#is leap year?
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
	local date1_iso8601 date2_iso8601 unix1 unix2 range neg_sign date_buf_unix date_buf yearA monthA dayA hourA minA secA tzA yearB monthB dayB hourB minB secB tzB ret years_between y_test leapcount daycount_between_leap_years daycount_between_years fullmonth_days monthcount month_test date1_month_max_day date2_month_max_day date3_month_max_day d_left y mo w d h m s range_single_w range_single_d range_single_h range_single_m range_print sh shs ddout dd dds y_dd mo_dd w_dd d_dd h_dd m_dd s_dd d_save h_save m_save s_save d_left_save range_single_y_days_left range_single_mo_days_left range_single_y_days_left_range range_single_mo_days_left_range range_single_y range_single_mo d_sum var date_buf_unix_tz date_buf_tz date1_iso8601_tz date2_iso8601_tz unix1_tz unix2_tz range_check
	#get dates in unix time
	(($# == 1)) && set -- '' "$1"

	#if command `date' is available, get unix times from input string
	if unix1=$(TZ=UTC0 datefun "${1:-+%s}" ${1:++%s}) &&
		unix2=$(TZ=UTC0 datefun "${2:-+%s}" ${2:++%s})
	then
		date1_iso8601=$(TZ=UTC0 datefun -Iseconds @"$unix1")
		date2_iso8601=$(TZ=UTC0 datefun -Iseconds @"$unix2")
		if [[ "${TZ^^}" != @(UTC0|UTC) ]]
		then 	unix1_tz=$(datefun "${1:-+%s}" ${1:++%s})
			unix2_tz=$(datefun "${2:-+%s}" ${2:++%s})
			date1_iso8601_tz=$(datefun ${OPTR:--Iseconds} @"$unix1_tz")
			date2_iso8601_tz=$(datefun ${OPTR:--Iseconds} @"$unix2_tz")
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
	#Time zone talk is a complicated business and we should not bother about supporting it..
	#may support a case statement for UTC/UTC0 and GMT, which should be substituted for +00:00;
	#-00:00 and +24:00 are valid and should equal to +00:00;
	#must decide what to do with environment $TZ, how to interpret input date string with a timezone?
	#support up to `seconds' for time zone adjustment;
	#POSIX time does not account for leap seconds;
	#POSIX defines time zone by the $TZ variable which takes a different form from ISO8601 standards;
	#we should not bother to support offsets or, std (standard) or dst (daylight saving time) in timezones;
	#IPC#see: <https://www.iana.org/time-zones>
	#we may support OFFSET instead of TIME ZONE, see distinction:
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
	if [[ -z "$unix1$unix2" ]] &&
		((
			(yearA>yearB)
			|| ( (yearA==yearB) && (monthA>monthB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA>dayB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA>hourB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA>minB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA==minB) && (secA>secB) )
		))
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
	[[ "${yearA:?user input required}" && "${yearB:?user input required}" && "$yearA$dayA$yearB$dayB" = +([0-9 ]) ]] || return 2
	((monthA>12 || monthB>12 || dayA>31 || dayB>31 || hourA>24 || hourB>24 || minA>60 || minB>60 || secA>60 || secB>60)) && { echo "err: illegal user input" >&2 ;return 2 ;}


	##Count leap years and sum leap and non leap years days,
	##needs to add a condition in the for test when yearA==yearB!
	for ((y_test=(yearA+1);y_test<yearB;++y_test))
	do 	(( !(y_test % 4) && (y_test % 100 || !(y_test % 400) ) )) && ((++leapcount))
		((++years_between))
		((monthcount += 12))
	done
	##count days in non and leap years
	(( daycount_between_leap_years = (366 * leapcount) ))
	(( daycount_between_years = (365 * (years_between - leapcount) ) ))


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

	#need some info about input dates and their context..
	date3_month_max_day=$(month_maxday "$((monthB-1))" "$yearB")
	date2_month_max_day=$(month_maxday "$monthB" "$yearB")
	date1_month_max_day=$(month_maxday "$monthA" "$yearA")
	date1_year_days=$(year_days "$monthA" "$yearA")
	date2_year_days=$(year_days "$monthB" "$yearB")
	date1_year_days_adj=$(year_days_adj date1 "$monthA" "$yearA")
	#date2_year_days_adj=$(year_days_adj date2 "$monthB" "$yearB")


	#set years and months
	(( y = years_between ))
	(( mo = ( monthcount - ( (years_between) ? (years_between * 12) : 0) ) ))


	#days left
	if [[ $yearA$monthA = $yearB$monthB ]]
	then 	#same month
		((d_left = ( dayB - dayA ) ))
	else 	#months are different
		((d_left = (date1_month_max_day-dayA) , d_left += dayB ))
	fi


	if [[ "${yearA:-0}${monthA:-0}${dayA:-0}" = "${yearB:-0}${monthB:-0}${dayB:-0}" ]]
	then 	#same day
		((h = hourB-hourA  ))
		((m = minB-minA  ))
		((s = secB-secA  ))

		#negative hours?
		if ((h<0))
		then 	if ((d_left))
			then 	((--d_left , h+=24))
			fi
		fi
		#negative minutes?
		if ((m<0))
		then 	if ((h))
			then 	((--h , m+=60))
			else 	((--d_left , h+=23 , m+=60))
			fi
		fi
		#negative seconds?
		if ((s<0))
		then 	if ((m))
			then 	((--m , s+=60))
			elif ((h))
			then 	((--h , m+=59 , s+=60))
			elif ((d_left))
			then 	((--d_left , h+=23 , m+=59 , s+=60))
			fi
		fi
	else 	#dates are different
		((h = 23-hourA , h += hourB))
		((m = 59-minA , m += minB))
		((s = 60-secA , s += secB))

		((m += s/60 , s %= 60))
		((h += m/60 , m %= 60))

		if ((h>=24))
		then 	((h %= 24))
		elif ((h+m+s))
		then 	((d_left -= 1))
		fi
	fi
	(( d_left_save = d_left ))  #save result for later
	#so far so good...


	#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
	#*#*#*#*#*#*#*#*#*#*#*# REFINEMENT RULES #*#*#*#*#*#*#*#*#*#*#*#
	#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
	#we actually need a `theoretical method' for refinement instead
	#of the `bug fixing' rules below. new rules may cause regression!
	if (( d_left >= date1_month_max_day ))
	then 	(( mo += d_left / date1_month_max_day ))
		(( d_left %= date1_month_max_day ))
	fi

	if ((monthA<monthB && dayA>dayB)) ||
		((monthB<=2 && dayA>dayB)) ||
		((monthA==monthB && dayA>dayB))
	then
		((d_left += date3_month_max_day - date1_month_max_day ))

	elif ((monthA>monthB && dayA>dayB)) ||
		((date1_month_max_day==31 && date2_month_max_day==31 && dayA==dayB && ( (hourA*3600)+(minA*60)+secA ) > ( (hourB*3600)+(minB*60)+secB ) )) ||
		((monthA==2 && date1_month_max_day==29 && dayB==1 && (h+m+s) )) ||
		((monthA==2 && date1_month_max_day==29 && dayA==2 && dayB==31 )) ||
		((yearA<=yearB && monthA==2 && dayA==2 && dayB==2 )) ||
		((monthA==2 && dayA==dayB && ( (hourA*3600)+(minA*60)+secA ) > ( (hourB*3600)+(minB*60)+secB ) )) ||
		#following conditions are probably not very good
		((dayA==1 && dayB==31 && monthA==2 && monthA<monthB && date1_year_days==366 && date2_year_days==366 )) ||
		((dayA==1 && dayB==31 && monthA==2 && date1_year_days==366 && (h+m+s) )) #<May be too broad a condition! Beware!
	then
		((d_left -= date1_month_max_day - date3_month_max_day ))
	fi
	#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
	#I believe most of the errors I got from testing this script some
	#months ago were due to DATES in February and when TIMES are not
	#identical in both DATES. I only tested  January and February
	#as DATE1.. I should try and check if March and April (as DATE1)
	#generate as many errors as February (maybe up to 4%) or are less
	#problematic as January (less than 1% error rate)...


	#set weeks and days
	(( w = d_left / 7))
	(( d = d_left % 7 ))
	

	#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
	#*#*#*#*#*#*#*#*#*#*# MORE REFINEMENT RULES #*#*#*#*#*#*#*#*#*#*
	#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
	if ((
		(monthA==2 && dayA<=2 && dayB>=29) ||
		(yearA<yearB && monthA>monthB && dayA==1 && dayB==31) ||
		(dayA==1 && dayB==31 && date1_month_max_day==30 && date2_month_max_day==31)
	)) &&
	((
		!w && mo &&
		(dayB-dayA>=28 || dayA-dayB>=28) &&
		( (dayA<date3_month_max_day) || (dayA>date3_month_max_day) ) 
	))
	then 
		if ((mo))
		then 	(( w += (date2_month_max_day/7) , --mo))
			
		elif ((y))
		then 	((--y , mo+=12))
			(( w += (date2_month_max_day/7) , --mo))
			
		fi

		if ((dayA==1 && dayB==31))
		then
			
			if ((monthA==4 || monthA==6 || monthA==9 || monthA==11))
			then 	((d += 2))
			elif ((monthA<monthB))
			then 	(( d += (date2_month_max_day%7 - 3) ))
			fi
		elif ((dayA==1 && dayB==30))
		then
			if ((monthA=2))
			then 	(( d += (date2_month_max_day%7) - 2))
			elif ((monthA>=monthB))
			then 	(( d += (date2_month_max_day%7) - 3))
			fi
		else
			if ((monthA>monthB))
			then 	(( d += (date2_month_max_day%7) - 3))
			fi
		fi
	fi
	
	#negative days
	if ((d<0))
	then
		if ((w))
		then
			((--w , d += 7))
		elif ((mo))
		then
			((--mo , w += date3_month_max_day/7))
			(( d += ( (date3_month_max_day%7) + (date1_month_max_day-dayA) + dayB + ( 
				(date1_year_days==366 || date2_year_days==366) ? 0 :
					(h+m+s) ? 1 :
					0 
			) ) ))
		elif ((y))
		then
			((--y , mo += 11 , w += date3_month_max_day/7))
			(( d += ( (date3_month_max_day%7) + (date1_month_max_day-dayA) + dayB + ( 
				(date1_year_days==366 || date2_year_days==366) ? 0 :
					(h+m+s) ? 1 :
					0 
			) ) ))
		fi
		#?#((d<0 && (d=0) ))
	fi
	#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*


	(( y += mo / 12 , mo %= 12 ))


	#total sum of full days
	((d_sum = (  d_left_save + (fullmonth_days + daycount_between_years + daycount_between_leap_years)  ) ))
	#total range in seconds
	((range = (d_sum * 3600 * 24) + (h * 3600) + (m * 60) + s))
	#OBS# The code seems to count the number os seconds just fine!

	#following is required for single unit range calculation
	#calculate time ranges by single units, if bc is available
	if
		range_single_y=$(bc <<<"scale=$SCL; $years_between +( ($range - (($daycount_between_years + $daycount_between_leap_years) * 3600 * 24) ) / ($date1_year_days_adj * 3600 * 24) )" )
	then
		range_single_mo=$(bc <<<"scale=$SCL; $monthcount + ( ( ($d_left_save * 3600 * 24) + ($h * 3600) + ($m * 60) + $s) / ($date1_month_max_day * 3600 * 24) )" )
		range_single_w=$(bc <<<"scale=$SCL; $range / 604800")
		range_single_d=$(bc <<<"scale=$SCL; $range / 86400")
		range_single_h=$(bc <<<"scale=$SCL; $range / 3600")
		range_single_m=$(bc <<<"scale=$SCL; $range / 60")

		#set print ranges
		[[ ${range_single_y:-0} != 0 ]] && range_print="$range_single_y years"
		[[ ${range_single_mo:-0} != 0 ]] && range_print="$range_print${range_print:+" || "}$range_single_mo months"
		[[ ${range_single_w:-0} != 0 ]] && range_print="$range_print${range_print:+" || "}$range_single_w weeks"
		[[ ${range_single_d:-0} != 0 ]] && range_print="$range_print${range_print:+" || "}$range_single_d days"
		[[ ${range_single_h:-0} != 0 ]] && range_print="$range_print${range_print:+" || "}$range_single_h hours"
		[[ ${range_single_m:-0} != 0 ]] && range_print="$range_print${range_print:+" || "}$range_single_m mins"
		range_print="$range_print${range_print:+" || "}$range secs"
	fi 	2>/dev/null


	#set printing array with shell results
	sh=("$y" "$mo" "$w" "$d"  "$h" "$m" "$s")
	
	#DEBUG
	#Check output of calculated `compound time range' against `datediff'.
	#Date ranges (in seconds) are calculated in two ways and checked against each other.
	#We can also check if results for the `single unit time ranges' match against `datediff'.
	if ((DEBUG))
	then
		date1_iso8601="${date1_iso8601:-$1}"  date2_iso8601="${date2_iso8601:-$2}"
		#generate datediff output
		ddout=$(datediff -f'%Y %m %w %d  %H %M %S' "${date1_iso8601:0:19}" "${date2_iso8601:0:19}") || ret=255
		read y_dd mo_dd w_dd d_dd  h_dd m_dd s_dd <<<"$ddout"
		dd=($y_dd $mo_dd $w_dd $d_dd  $h_dd $m_dd $s_dd)

		#checksums for equivalent dates with different refinements
		#shs=$(( ( (y*336)+(mo*28)+(w*7)+d * 3600 * 24) + (h*3600) + (m*60) + s))
		#dds=$(( ( (y_dd*336)+(mo_dd*28)+(w_dd*7)+d_dd * 3600 * 24) + (h_dd*3600) + (m_dd*60) + s_dd))

		#check TIME results
		((range == unix2-unix1)) &&
		{
			#check DATE against `datediff'
			#[[ "$shs" = "$dds" ]] ||
			[[ "${sh[*]}" = "${dd[*]}" ]] ||
			[[ "${dd[@]:2:2}" = *[6-9]\ +([0-9]) ]]    #datediff ?bad date ranges?
		} ||
		{
			ret=${ret:-1}
			range_check=$((unix2-unix1))
			echo -ne "\033[2K" >&2
			echo "sh=${sh[*]}"$'\t'"dd=${dd[*]}"$'\t'"${range:-unavail} ${range_check:-unavail}"$'\t'"$date1_iso8601 $date2_iso8601"
		}
		((DEBUG>1)) && return $ret
	fi

	#suggestion: reswap dates and add negative sign to ranges if $neg_sign is set?
	
	#print results
	printf 'DATES\n%s  %s\n%s  %s\n' "${date1_iso8601_tz:-${date1_iso8601:-$1}}" "${unix1_tz:-$unix1}" "${date2_iso8601_tz:-${date2_iso8601:-$2}}" "${unix2_tz:-$unix2}"
	printf 'RANGES\n%s\n' "$range_print"
	printf '%dY %02dM %02dW %02dD  %02dH %02dM %02dS\n' "${sh[@]}"

	return $ret
}


## Parse options
while getopts 0123456789df:hlRuv opt
do 	case $opt in
		[0-9]) 	SCL="$SCL$opt"
			;;
		d) 	((++DEBUG))
			;;
		f) 	INPUT_FMT="$OPTARG" OPTF=1  #input format string for BSD `date'
			;;
		h) 	echo "$HELP"
			exit
			;;
		l) 	OPTL=1
			;;
		R) 	OPTR=-R
			;;
		u) 	OPTU=1
			;;
		v) 	OPTVERBOSE=1
			;;
		\?) 	exit 1
			;;
	esac
done
shift $((OPTIND -1)); unset opt

#set proper environment!
if ((DEBUG<2 && !OPTU))
then 	TZ=UTC0  #LC_ALL=C
fi
export TZ

#scale
SCL="${SCL:-3}"

if ((OPTL))
then 	#check leap year
	isleap "$@"
else 	#main datediff fun
	mainf "$@"
fi

