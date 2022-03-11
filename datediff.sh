#!/usr/bin/env bash
# datediff.sh - Calculate time ranges between dates (was `ddate.sh')
# v0.16.11  mar/2022  mountaineerbr  GPLv3+
shopt -s extglob

HELP="NAME
	${0##*/} - Calculate time ranges between dates


SYNOPSIS
	${0##*/} [-NUM] [-RruVVvvv] [-f\"FMT\"] \"DATE1\" \"DATE2\" [UNIT]
	${0##*/} -l [-v] YEAR
	${0##*/} -h


DESCRIPTION
	Calculate time ranges between DATE1 and DATE2.

	Input DATE strings must be ISO-8601 \`%Y-%m-%dT%H:%M:%S' if using
	\`BSD date' unless option \`-f FMT' is set to a new input time
	format. \`GNU date' accepts mostly free format human readable date
	strings. If \`date' is not available then input must be in ISO-8601
	format.

	If DATE is not set, defaults to \`now'. To flag DATE as UNIX time,
	prepend an at sign \`@' to it or set option -r. Stdin input sup-
	ports one DATE string per line or two ISO-8601 DATES separated by
	space in a single line. Input is processed in a best effort basis.

	Output RANGES section displays calculated ranges in different units
	of time (years or months or weeks or days or hours or minutes or
	seconds alone). It also displays a compound time range with all
	the above units into consideration to each other.

	Single unit time ranges can be displayed in table format (-V) and
	scale set with -NUM where NUM is an integer. When last positional
	parameter UNIT is exactly one of \`y', \`mo', \`w', \`d', \`h',
	\`m' or \`s', a single UNIT range is printed.

	Output DATE section prints two dates in ISO-8601 format or, if
	option -R is set, RFC-5322 format.

	Option -l checks if YEAR is leap and exits with 0 if true. Set
	option -v to decrease verbose and modify output layout. Gregorian
	calendar is assumed. No leap seconds.

	Timezone is read from environment \$TZ by the \`date' programme.
	Timezone features are only available with GNU or BSD \`date'.


ENVIRONMENT
	TZ 	Sets timezone name, read by \`date' programme; internally
		and for debugging UTC0 is always set.


REFINEMENT RULES
	Some date ranges can be calculated in various forms for the
	\`compound time range' display. We decided to mimic hroptatyr's
	\`datediff' refinement rules as often as possible but may do
	differently (however correctly).

	Script error rate is estimated to be lower than one percent after
	extensive testing with selected and corner-case sample dates.
	Check script source code for details.


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
	$ echo 2000 | ${0##*/} -l

	Time ranges
	$ ${0##*/} 2020-01-03T14:30:10 2020-12-24T00:00:00
	$ ${0##*/} 0921-04-12 1999-01-31
	$ echo 1970-01-01 2000-02-02 | ${0##*/} 

	#Single unit time ranges
	$ ${0##*/} 2022-03-01T00:00:00 2022-03-01T10:10:10 m  #(m)ins
	$ ${0##*/} '10 years ago'  mo                         #(mo)nths
	$ ${0##*/} 1970-01-01  2000-02-02  y                  #(y)ears

	\`GNU date' wrapping
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

	\`BSD date' wrapping
	$ ${0##*/} -f'%m/%d/%Y' 6/28/2019  9/04/1970 
	$ ${0##*/} -r 1561243015 1592865415
	$ ${0##*/}  200002280910.33  0003290010.00
	$ ${0##*/} -- '-v +1d' '-v -28d'


OPTIONS
	-[0-9] 	Set scale for single unit ranges.
	-ddd 	Debugging modes.
	-f FMT 	Input time format string; only with BSD \`date'.
	-h 	Print this help page.
	-l YEAR	Check if YEAR is leap year; YEAR format: YYYY.
	-R 	Print human time in RFC-5322 format (verbose).
	-r, -@ 	Input DATES are UNIX times.
	-u 	Print in local time (mind environment \$TZ).
	-VV 	Set table layout display of single unit ranges.
	-vvv 	Less verbose."

#WHAT TO EXPECT FROM VERBOSE AND DEGUB FLAGS
#VERBOSE
#no verbose option, print date1 and date2 in results, as well as unix times when available.
#toggle verbose with option -v.
#verbose less than 3 (-v and -vv): run `date' and `bc'; print single unit ranges.
#verbose less than 2 and more than 2 (-v and -vvv): print compound range.
#DEBUGGING
#debug one disables verbose mode switches, so most code is run.
#debug one or two (-d, -dd): set UTC=0.
#debug two or more (-dd): set exit signal from debug test against `datediff' and `date' unix time.
#debug three or more (-ddd): does not set UTC=0.

#TESTING RESULTS
#Testing script: <https://pastebin.com/mPvBDd2q>
#Hroptatyr's `man datediff' says ``refinement rules'' cover over 99% cases.
#Calculated `datediff' error rate is at least .00311 (0.3%) of total tested dates (compound range).
#Results differ from `datediff' in .006275 (0,6%) of all tested dates in script version v0.16.8 (compound range).
#All differences occur with ``end-of-month vs. start-of-month'' dates, such as days `29, 30 or 31' of one date against days `1, 2 or 3' of the other date.
#Different results from `datediff' in compound range are not necessarily errors in all cases and may be considered correct albeit with different refinements. This seem to be the case for most, if not all, further differences obtained in testing results.
#No errors were found in range (seconds) calculation and thus single-unit results should all be correct.

#NOTES
##Time zone / Offset support
#dbplunkett: <https://stackoverflow.com/questions/38641982/converting-date-between-timezones-swift>
#Time zone talk is a complicated business, leave it for `date' programme!
#could only support case statement for UTC/UTC0 and GMT to set TZ=+00:00;
#-00:00 and +24:00 are valid and should equal to +00:00;
#how to care for environment $TZ and input date string with timezone?
#support up to `seconds' for time zone adjustment; POSIX time does not account for leap seconds;
#POSIX defines time zone by the $TZ variable which takes a different form from ISO8601 standards;
#we should not bother to support offsets, std (standard) or dst (daylight saving time) in timezones;
#see: <https://www.iana.org/time-zones>
#may be easier to support OFFSET instead of TIME ZONE, see distinction:
#<https://stackoverflow.com/questions/3010035/converting-a-utc-time-to-a-local-time-zone-in-java>
#America/Sao_Paulo is a timezone ID, not a name. `Pacific Standard Time' is a tz name
#interesting case: -- -220-01-03 -0220-01-01


YEAR_MONTH_DAYS=(31 28 31 30 31 30 31 31 30 31 30 31)
TIME_ISO8601_FMT='%Y-%m-%dT%H:%M:%S%z'
#TIME_RFC5322_FMT='%a, %d %b %Y %H:%M:%S %z'
#TIME_CUSTOM_FMT='%d/%b/%Y %H:%M:%S'
#`BSD date' input time format defaults:
INPUT_FMT="${TIME_ISO8601_FMT:0:17}"  #%Y-%m-%dT%H:%M:%S - no timezone

# Choose between GNU or BSD date
# datefun.sh [-u|-R|-v[val]|-I[fmt]] [YYY-MM-DD|@UNIX] [+OUTPUT_FORMAT]
# datefun.sh [-u|-R|-v[val]|-I[fmt]]
#
# By defaults, input should be UNIX time (append @) or ISO8601 format.
# Option -I `fmt' may be `date', `hours', `minutes' or `seconds'.
# Setting environment TZ=UTC0 is equivalent to -u. 
datefun()
{
	local options unix_input input_fmt
	input_fmt="${INPUT_FMT:-$TIME_ISO8601_FMT}"
	[[ $1 = -[RIv]* ]] && options="$1" && shift

	if ((BSDDATE))
	then
		[[ ! $1 ]] && set --
		if [[ $1 = +([0-9])?(.[0-9][0-9]) ]]  #try BSD default fmt [[[[[cc]yy]mm]dd]HH]MM[.ss]
		then 	"${DATE_CMD[@]}" ${options} -j "$@" && return
		elif [[ $1 = +([0-9])-+([0-9])-+([0-9]) && ! $OPTF ]]  #try short ISO8601 (no time)
		then 	"${DATE_CMD[@]}" ${options} -j -f "${TIME_ISO8601_FMT:0:8}" "$@" && return
		fi
		[[ ${1:-+} != @(+|@|-f)* ]] && set -- -f"${input_fmt}" "$@"
		[[ $1 = @* ]] && set -- "-r${1#@}" "${@:2}"
		"${DATE_CMD[@]}" ${options} -j "$@"
	else
		[[ ${1:-+} != @(+|-d)* ]] && set -- -d"${unix_input}${1}" "${@:2}"
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
	local month year
	month="$1" year="$2"
	if (( month == 2 && !(year % 4) && ( year % 100 || !(year % 400) ) ))
	then 	echo 29
	else 	echo ${YEAR_MONTH_DAYS[month-1]}
	fi
}

#check how many days in a year; print number of days of a year.
#year_days()
#{
#	local month year
# 	month="$1" year="$2"
#	if (( !(year % 4) && ( year % 100 || !(year % 400) ) ))
#	then 	echo 366
#	else 	echo 365 ;false
#	fi
#}

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
	year=${1#+} year=${year##*(0)}
	if 	[[ $year = ?(-)+([0-9]) ]] ||
		{ 	[[ $year =~ ^-?[0-9]{1,4} ]] && year=${BASH_REMATCH[0]} ;}
	then
		if (( !(year % 4) && ( year % 100 || !(year % 400) ) ))
		then 	((OPTVERBOSE)) || echo "leap year -- $year" ;return 0
		else 	((OPTVERBOSE)) || echo "not leap year -- $year"
		fi
	else 	echo "${0##*/}: err  -- year must be in the format YYYY" >&2
	fi
	return 1
}
#https://stackoverflow.com/questions/32196629/my-shell-script-for-checking-leap-year-is-showing-error

#datediff fun
mainf()
{
	local date1_iso8601 date2_iso8601 unix1 unix2 inputA inputB range neg_sign date_buf yearA monthA dayA hourA minA secA tzA yearB monthB dayB hourB minB secB tzB ret years_between y_test leapcount daycount_leap_years daycount_years fullmonth_days fullmonth_days_save monthcount month_test date1_month_max_day date2_month_max_day date3_month_max_day date1_year_days_adj d_left y mo w d h m s range_single_w range_single_d range_single_h range_single_m range_print sh ddout dd y_dd mo_dd w_dd d_dd h_dd m_dd s_dd d_left_save range_single_y range_single_mo d_sum unix1_pr unix2_pr date1_iso8601_pr date2_iso8601_pr range_check var n r SS SSS

	#get dates in unix time
	(($# == 1)) && set -- '' "$1"

	#if command `date' is available, get unix times from input string
	if 	unix1=$(TZ=UTC0 datefun "${1:-+%s}" ${1:++%s}) &&
		unix2=$(TZ=UTC0 datefun "${2:-+%s}" ${2:++%s})
	then
		date1_iso8601=$(TZ=UTC0 datefun -Iseconds @"$unix1")
		date2_iso8601=$(TZ=UTC0 datefun -Iseconds @"$unix2")
		if [[ $OPTRR && ${TZ^^} = ?(+|-)@(UTC-0|UTC0|UTC|0*(0)) ]]
		then	date1_iso8601_pr=$(TZ=UTC0 datefun -R @"$unix1")
			date2_iso8601_pr=$(TZ=UTC0 datefun -R @"$unix2")
		elif [[ ${TZ^^} != ?(+|-)@(UTC-0|UTC0|UTC|0*(0)) ]]
		then 	unix1_pr=$(datefun "${1:-+%s}" ${1:++%s})
			unix2_pr=$(datefun "${2:-+%s}" ${2:++%s})
			date1_iso8601_pr=$(datefun ${OPTRR:--Iseconds} @"$unix1_pr")
			date2_iso8601_pr=$(datefun ${OPTRR:--Iseconds} @"$unix2_pr")
		fi

		#sort dates
		if ((unix1 > unix2))
		then 	neg_sign=-
			date_buf="$unix1" unix1="$unix2" unix2="$date_buf"
			date_buf="$unix1_pr" unix1_pr="$unix2_pr" unix2_pr="$date_buf"
			date_buf="$date1_iso8601" date1_iso8601="$date2_iso8601" date2_iso8601="$date_buf"
			date_buf="$date1_iso8601_pr" date1_iso8601_pr="$date2_iso8601_pr" date2_iso8601_pr="$date_buf"
		fi
	else 	unset unix1 unix2
	fi
		
	#load ISO8601 dates from `date' or user input
	inputA="${date1_iso8601:-$1}"
	inputB="${date2_iso8601:-$2}"
	IFS="${IFS}Tt/.:+-" read yearA monthA dayA hourA minA secA tzA <<<"${inputA#[+-]}"
	IFS="${IFS}Tt/.:+-" read yearB monthB dayB hourB minB secB tzB <<<"${inputB#[+-]}"
	#trim leading zeroes, requires bash extended globbing
	for var in yearA monthA dayA hourA minA secA  yearB monthB dayB hourB minB secB  #tzA tzB
	do 	eval "$var=\"${!var##*(0)}\""
	done
	[[ $inputA = -* ]] && yearA=-$yearA ;[[ $inputB = -* ]] && yearB=-$yearB  #year<0

	#sort dates if unix times were not generated by `date' previously
	if [[ ! $unix2 ]] &&
		(( 	(yearA>yearB)
			|| ( (yearA==yearB) && (monthA>monthB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA>dayB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA>hourB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA>minB) )
			|| ( (yearA==yearB) && (monthA==monthB) && (dayA==dayB) && (hourA==hourB) && (minA==minB) && (secA>secB) )
		))
	then 	#swap dates
		neg_sign=-
		set -- "$2" "$1" "${@:3}"
		IFS="${IFS}Tt/.:+-" read yearA monthA dayA hourA minA secA tzA <<<"${inputA#[+-]}"
		IFS="${IFS}Tt/.:+-" read yearB monthB dayB hourB minB secB tzB <<<"${inputB#[+-]}"
		for var in yearA monthA dayA hourA minA secA  yearB monthB dayB hourB minB secB  #tzA tzB
		do 	eval "$var=\"${!var##*(0)}\""
		done
		[[ $inputB = -* ]] && yearA=-$yearA ;[[ $inputA = -* ]] && yearB=-$yearB
	fi
	#check input validity
	[[ ${yearA:?user input required}${yearB:?user input required} = +([0-9 -]) ]] || return 2
	{ ((monthA>12 || monthB>12 || hourA>24 || hourB>24 || minA>60 || minB>60 || secA>60 || secB>60 || (dayA>$(month_maxday $monthA $yearA) ) || (dayB>$(month_maxday $monthB $yearB) ) )) ;} 2>/dev/null && { echo "err: illegal user input" >&2 ;return 2 ;}
	[[ ! $unix2$OPTVERBOSE && $tzA$tzB ]] && echo "warning: time zone supported only by \`date' package!" >&2


	##Count leap years and sum leap and non leap years days,
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
	#if [[ $unix2 ]]  #prefer `date' unix times for range if available?
	#then 	((range = unix2-unix1))
	#else
		((d_sum = (  (d_left_save) + (fullmonth_days + daycount_years + daycount_leap_years)  ) ))
		((range = (d_sum * 3600 * 24) + (h * 3600) + (m * 60) + s))
	#fi

	#single unit time ranges when `bc' is available (ensure `bc' is available)
	if { 	((!OPTT||OPTTy)) && range_single_y=$(bc <<<"scale=${SCL}; ${years_between:-0} + ( (${range:-0} - ( (${daycount_years:-0} + ${daycount_leap_years:-0}) * 3600 * 24) ) / (${date1_year_days_adj:-0} * 3600 * 24) )")
		} || ((OPTT||OPTVERBOSE<3))
	then
		((!OPTT||OPTTmo)) && range_single_mo=$(bc <<<"scale=${SCL}; ${monthcount:-0} + ( (${range:-0} - (${fullmonth_days_save:-0} * 3600 * 24) ) / (${date1_month_max_day:-0} * 3600 * 24) )")
		((!OPTT||OPTTw)) && range_single_w=$(bc <<<"scale=${SCL}; ${range:-0} / 604800")
		((!OPTT||OPTTd)) && range_single_d=$(bc <<<"scale=${SCL}; ${range:-0} / 86400")
		((!OPTT||OPTTh)) && range_single_h=$(bc <<<"scale=${SCL}; ${range:-0} / 3600")
		((!OPTT||OPTTm)) && range_single_m=$(bc <<<"scale=${SCL}; ${range:-0} / 60")

		#print layout of single units
		if ((! OPTLAYOUT || OPTT))
		then 	#layout one
			prHelpf $range_single_y && range_print="$range_single_y year$SS"
			prHelpf $range_single_mo && range_print+=" || $range_single_mo month$SS"
			prHelpf $range_single_w && range_print+=" || $range_single_w week$SS"
			prHelpf $range_single_d && range_print+=" || $range_single_d day$SS"
			prHelpf $range_single_h && range_print+=" || $range_single_h hour$SS"
			prHelpf $range_single_m && range_print+=" || $range_single_m min$SS"
			prHelpf $range ;((!OPTT||OPTTs)) && range_print+=" || $range sec$SS"
			range_print="${range_print:-$range sec$SS}"
			range_print="${range_print# || }"
		else 	#layout two
			for r in ${#range_single_y} ${#range_single_mo} ${#range_single_w} \
				${#range_single_d} ${#range_single_h} ${#range_single_m} $((${#range}+SCL+1))
			do ((r>n && (n=r) ))
			done
			prHelpf $range_single_y && prSpacef $n ${#range_single_y} \
				&& range_print=Year$SS$'\t'$SSS$range_single_y
			prHelpf $range_single_mo && prSpacef $n ${#range_single_mo} \
				&& range_print+=$'\n'Month$SS$'\t'$SSS$range_single_mo
			prHelpf $range_single_w && prSpacef $n ${#range_single_w} \
				&& range_print+=$'\n'Week$SS$'\t'$SSS$range_single_w
			prHelpf $range_single_d && prSpacef $n ${#range_single_d} \
				&& range_print+=$'\n'Day$SS$'\t'$SSS$range_single_d
			prHelpf $range_single_h && prSpacef $n ${#range_single_h} \
				&& range_print+=$'\n'Hour$SS$'\t'$SSS$range_single_h
			prHelpf $range_single_m && prSpacef $n ${#range_single_m} \
				&& range_print+=$'\n'Min$SS$'\t'$SSS$range_single_m
			prHelpf $range ;prSpacef $n $((${#range}+SCL+1))
			range_print+=$'\n'Sec$SS$'\t'$SSS$range
			range_print="${range_print#[$IFS]}"
			((OPTLAYOUT>1)) && range_print="${range_print// ./0.}"
			#https://www.themathdoctors.org/should-we-put-zero-before-a-decimal-point/
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
	then 	printf '%s\n%s  %s\n%s  %s\n' DATES "${date1_iso8601_pr:-${date1_iso8601:-$1}}" "${unix1_pr:-$unix1}" "${date2_iso8601_pr:-${date2_iso8601:-$2}}" "${unix2_pr:-$unix2}"
		printf '%s\n' RANGES
	fi
	((OPTVERBOSE<3)) && printf '%s\n' "$range_print"
	((OPTVERBOSE<2 || OPTVERBOSE>2)) && printf '%dY %02dM %02dW %02dD  %02dH %02dM %02dS\n' "${sh[@]}"

	return ${ret:-0}
}

#check compound range result against `datediff' and unix ranges against `date'.
#info: re-add this code to mainf() loop directly for massive testing (runs faster).
debugf()
{
		#check compound time range against `date' and DATE against `datediff'
		date1_iso8601="${date1_iso8601:-$1}"  date2_iso8601="${date2_iso8601:-$2}"
		ddout=$(datediff -f'%Y %m %w %d  %H %M %S' "${date1_iso8601:0:19}" "${date2_iso8601:0:19}") || ret=255
		read y_dd mo_dd w_dd d_dd  h_dd m_dd s_dd <<<"$ddout"
		dd=($y_dd $mo_dd $w_dd $d_dd  $h_dd $m_dd $s_dd)
		if [[ $unix2 ]]
		then 	range_check=$((unix2-unix1))
		else 	((ret+=254))
		fi

		{ 	[[ $range = "${range_check:-$range}" ]] &&
			[[ ${sh[*]} = "${dd[*]}" ]]
		} || { 	echo -ne "\033[2K" >&2
			echo "sh=${sh[*]}"$'\t'"dd=${dd[*]}"$'\t'"${date1_iso8601:0:19} ${date2_iso8601:0:19}"$'\t'"${range:-unavail} ${range_check:-unavail}" 
			ret=${ret:-1}
		}
		((DEBUG>1)) && exit ${ret:-0}  #!#
}

#check if floating number input is plural, set return signal and $SS to ``s''.
#usage: prHelpf 1.2
prHelpf()
{
	local val valx int dec
	SS=  val=${1#-} val=${val#0} valx=${val//[0.]} int=${val%.*}
	[[ $val = *.* ]] && dec=${val#*.} dec=${dec//0}
	((valx)) || return
	(( int>1 || ( (int==1) && (dec) ) )) && SS=s
	return 0
}

#set remaining spaces to $SSS
#usage: prSpacef 10 6
prSpacef()
{
	local x z
	SSS=  x=$((${1:?error}-${2:-0}))
	for ((z=0;z<x;++z))
	do 	SSS+=' '
	done
	return 0
}


## Parse options
while getopts 0123456789df:hlRr@uVv opt
do 	case $opt in
		[0-9]) 	SCL="$SCL$opt"
			;;
		d) 	((++DEBUG))
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
		R) 	OPTRR=-R
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
((DEBUG)) && unset OPTVERBOSE
if ((DEBUG<3 && !OPTU))
then 	TZ=UTC0  #LC_ALL=C
fi
export TZ
SCL="${SCL:-3}"  #scale

#stdin input
globoptt='@(y|mo|w|d|h|m|s)'
[[ ${1,,} = *([$IFS])$globoptt*([$IFS]) ]] && opt="$1" && shift  #single-unit pos arg option
if [[ $# -eq 0 && ! -t 0 ]]
then 	sep='Tt/.:+-'
	globdate='?(+|-)+([0-9])[/.-]@(1[0-2]|?(0)[1-9])[/.-]@(3[01]|?(0)[1-9]|[12][0-9])'
	globtime='@(2[0-3]|?([01])[0-9]):?([0-5])[0-9]?(:?([0-5])[0-9])?(?(+|-)@(2[0-3]|?([01])[0-9])?(:?([0-5])[0-9])?(:?([0-5])[0-9]))'
	globtest="*([$IFS])@($globdate?(+([$sep])$globtime)|$globtime)*([$IFS])@($globdate?(+([$sep])$globtime)|$globtime)?(+([$IFS])$globoptt)*([$IFS])"  #glob for two ISO8601 dates and possibly pos arg option for single unit range
	#https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch04s07.html
	while IFS= read -r || [[ $REPLY ]]
	do 	[[ ${REPLY//[$IFS]} ]] || continue
		if ((!$#))
		then 	set -- "$REPLY" ;((OPTL)) && break
			#check if arg contains TWO ISO8601 dates and break
			if REPLY=($1) ;[[ ${#REPLY[@]} -eq 2 && \ ${1,,} = @(*[$IFS]$globoptt|$globtest) ]]
			then 	set -- $1 ;break
			fi
		else 	set -- "$1" "$REPLY"
			if REPLY=($2) ;[[ ${#REPLY[@]} -eq 2 && \ ${2,,} = @(*[$IFS]$globoptt|$globtest) ]]
			then 	set -- "$1" $2
			fi ;break
		fi
	done ;unset sep globdate globtime globtest REPLY
	[[ ${1,,}\  = $globoptt[$IFS]* ]] && { 	set -- $1 "${@:2:2}" ;opt=$1 ;shift ;}
fi ;unset globoptt
[[ $opt ]] && set -- "$@" $opt ;unset opt  #set single-unit option as last pos arg

#whitespace trimming
if (($#>1))
then 	set -- "${1##*([$IFS])}" "${2##*([$IFS])}" "${@:3}"
 	set -- "${1%%*([$IFS])}" "${2%%*([$IFS])}" "${@:3}"
elif (($#))
then 	set -- "${1##*([$IFS])}" ;set -- "${1%%*([$IFS])}"
fi

#-r, unix times
if ((OPTR))
then 	if (($#>1))
	then 	set -- @"${1#@}" @"${2#@}" "${@:3}"
	elif (($#))
	then 	set -- @"${1#@}"
	fi
fi

#print a single time unit?
opt="${@: -1}" opt="${opt,,}"
if [[ ${opt// } =~ ^(y|mo|w|d|h|m|s)$ ]]
then 	OPTT=1 OPTVERBOSE=2
	eval "OPTT${BASH_REMATCH[1]}=1"
	set -- "${@:1:$#-1}"
fi ;unset opt

if ((OPTL))
then 	#leap year check
	isleap "$@"
else 	#datediff fun
	mainf "$@"
fi
