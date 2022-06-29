#!/bin/bash
# wf.sh  --  weather forecast (norway meteorological institute)
# v0.3.3  sep/2021  by mountaineerbr
# REQUIRES CURL, JQ AND GNUPLOT
#               __  ___                  
# _______ ____ / /_/ _ |_    _____ ___ __
#/ __/ _ `(_-</ __/ __ | |/|/ / _ `/ // /
#\__/\_,_/___/\__/_/ |_|__,__/\_,_/\_, / 
#                                 /___/  
#                        __       _                  ___     
#  __ _  ___  __ _____  / /____ _(_)__  ___ ___ ____/ _ )____
# /  ' \/ _ \/ // / _ \/ __/ _ `/ / _ \/ -_) -_) __/ _  / __/
#/_/_/_/\___/\_,_/_//_/\__/\_,_/_/_//_/\__/\__/_/ /____/_/   

#Open Cage api key for GPS coordinates
OPENCAGEKEY=54f6cb1814a4426484b8f28c0b6adbb6

#script name
SN="${0##*/}"

#user agent
#chrome on windows 10
UAG='user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36'

#help page
HELP="NAME
	$SN - Weather Forecast


SYNOPSIS
	$SN -ce [CITY NAME]
	$SN [-d DIRECTORY|-gg] [-le] [-m ALTITUDE] [CITY NAME|[LAT] [LON]]
	$SN -s [-m ALTITUDE] [\"CITY NAME\"|[LAT] [LON]] [DATE] [DAYS] [OFFSET]
	$SN [-khv]

	Get weather and sunrise data from Meteorologisk Institutt Norway.


DESCRIPTION
	Norway Institure of meteorology offers model data for weather
	forecast as well as statistics about sunrise times.

	Defaults function is to retrieve weather forecast information
	and plot to dumb terminal. Set -g to generate graphs and output
	to terminal and -gg to open graphs in X11 (gnuplot viewer).
	Optionally set -d\"DIRECTORY\" to save graph files to a directory
	instead.

	Option -k checks weather API status.

	Option -s retrives information about sunrise and related times.
	Note that \"CITY NAME\" must be the first positional parameter,
	use quotes if needed. Set further positional arguments to empty
	\"\" string, if needed. This is a very rough implementation!

	Option -c prints GPS coordinate information from Opencagedata API.

	Please update \$OPENCAGEKEY variable in the script head source
	code with a free active key from Open Cage.


SEE ALSO
	<https://api.met.no/>
	<https://api.met.no/weatherapi/documentation>
	<https://opencagedata.com/api>


WARRANTY
	Licensed under the GNU Public License v3 or better and is distrib-
	uted without support or bug corrections.
   	
	This script requires curl, jq and gnuplot to work properly.

	If you found this useful, please consider sending me a
	nickle!  =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


BUGS
	Option -s will not recognise city names with numbers, such as
	\"10 de Abril\", \"12th Street\" and \"Colonia 24 de Febrero\".
	Use actual geo coordinates for these rare location names instead.


OPTIONS
	-c CITY NAME
		Search GPS coordenates from Opencagedata.
	-d DIRECTORY
		Set directory for saving PNG graph images.
	-e 	Print raw JSON.
	-g 	Generate graphs and print to terminal.
	-gg	Open graphs in X11 instead of terminal.
	-k 	Check weather API status.
	-l 	Print local time.
	-m ALTITUDE
		Set altitude, height (integer, metres).
	-s [\"CITY NAME\"|[LAT] [LON]] [DATE] [DAYS] [OFFSET]
		Sunrise and related statuses, see also -m.
	-h 	Help page.
	-v 	Script version."


#add correctly approximate hours to x axis
nlcutf()
{
	tr \? 0 | tr -d 'msº%UVC' | awk "{print \$1,\$${1:-2}}"
}

#plot fun
#usage: plotf [TITLE] [XLABEL] [YLABEL]
plotf()
{
	gnuplot -p \
		-e 'set term dumb' \
		-e "set title \"$1\"; show title; set key off; set xlabel \"$2\"; set ylabel \"$3\"" \
		-e 'set xdata time' \
		-e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' \
		-e 'set format x "%b %d"' \
		-e 'plot "-" using 1:2 with linespoints linestyle 1'
}
#-g plot in X11 (gnuplot viewer)
plotx11f()
{
	gnuplot -p \
		-e "set title \"$1\"; show title; set key off; set xlabel \"$2\"; set ylabel \"$3\"" \
		-e 'set xdata time' \
		-e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' \
		-e 'set format x "%b %d"' \
		-e 'set grid' \
		-e 'plot "-" using 1:2 with linespoints linestyle 1'
}
#-gg plot to file
plottofilef()
{
	local tmpfile="${TMPDIR:-/tmp}/${0##*/}.${CITY:-${FORMATTED:-X}}.$1.png"
	gnuplot -p \
		-e "set terminal png size 800,600; set output \"$tmpfile\"" \
		-e "set title \"$1\"; show title; set key off; set xlabel \"$2\"; set ylabel \"$3\"" \
		-e 'set xdata time' \
		-e 'set timefmt "%Y-%m-%dT%H:%M:%S%Z"' \
		-e 'set format x "%b %d"' \
		-e 'plot "-" using 1:2 with linespoints linestyle 1' \
	&& echo "$tmpfile" >&2
}
#https://stackoverflow.com/questions/30315114/show-graph-on-display-and-save-it-to-file-simultaneously-in-gnuplot

#check weather api status
statusf()
{
	curl -L -H "$UAG" 'https://api.met.no/weatherapi/locationforecast/2.0/status' | jq -e
}

#retrieve coordinates by location name
gpshelperf()
{
	local query data coordenates ##CITY LAT LNG FORMATTED
	query="$*" CITY="$query"

	#check for non-empty $query
	if [[ -z "${query// }" ]]
	then return 1
	#check if arg is not coordinates
	elif ((OPTC==0)) && coordenates=( $(grep -Pom2 '(-?\d+([.]\d+)?)' <<<"$query") )
	then LAT=${coordenates[0]} LNG=${coordenates[1]} ;[[ "$LNG" ]] && return 0 || LAT= LNG=
	fi
	#https://stackoverflow.com/questions/3518504/regular-expression-for-matching-latitude-longitude-coordinates

	#MY FAVOURITE LOCATIONS
	#ADD BELOW YOU FAVORITE LOCATION BY NAME
	#LATITUDE (LAT), LONGITUDE (LNG) AND ALTITUDE (METRE)
	case "${query,,}" in
		new*york) LAT=40.7127281 LNG=-74.006015 METRE=10 ;;
		apucarana) LAT=-23.5525327 LNG=-51.4610764 METRE=840 ;;
		arapongas) LAT=-23.4152862 LNG=-51.4293961 METRE=816 ;;
		belo*horizonte) LAT=-19.9227318 LNG=-43.9450948 METRE=852 ;;
		bras[ií]lia) LAT=-15.7934036 LNG=-47.8823172 METRE=1172 ;;
		cascavel) LAT=-24.9554996 LNG=-53.4560544 METRE=781 ;;
		curitiba) LAT=-25.4295963 LNG=-49.2712724 METRE=935 ;;
		florian[óo]polis) LAT=-27.5973002 LNG=-48.5496098 METRE=0 ;;
		foz*do*igua[cç][uú]) LAT=-25.5401479 LNG=-54.5858139 METRE=164 ;;
		general*carneiro) LAT=-26.422982 LNG=-51.3146691 METRE=983 ;;
		gramado) LAT=-29.3924265 LNG=-50.912571 METRE=850 ;;
		guaratuba) LAT=-25.8806192 LNG=-48.5750905 METRE=0 ;; 
		londrina) LAT=-23.3112878 LNG=-51.1595023 METRE=610 ;;
		maring[áa]) LAT=-23.425269 LNG=-51.9382078 METRE=515 ;;
		s[ãa]o*paulo) LAT=-23.5506507 LNG=-46.6333824 METRE=760 ;;
	esac

	if [[ -z "$LAT" ]]
	then
		data=$(curl -sL -H "$UAG" "https://api.opencagedata.com/geocode/v1/json?q=${query// /%20}&key=$OPENCAGEKEY&no_annotations=1&language=en")

		#-c print coordinates only?
		if ((OPTC))
		then jq -r ".results[]|\"\(.confidence)\t\(.geometry.lat),\(.geometry.lng)\t\(.formatted)\"" <<<"$data" ;return
		#fun helper
		else
			LAT=$(jq -r '.results[0].geometry.lat' <<<"$data")
			LNG=$(jq -r '.results[0].geometry.lng' <<<"$data")
			FORMATTED=$(jq -r '.results[0].formatted //empty' <<<"$data")
		fi
	#-c print coordinates only from FAVOURITES?
	elif ((OPTC))
	then
		if ((OPTE))
		then echo "$data"
		else echo "$LAT $LNG $METRE $query"
		fi
	fi
	[[ -n "$LAT" && -n "$LNG" ]]
}

#meteorologisk institutt norway
mainf()
{
	local data meters query jqout
	query="$*"
	[[ "$METRE" ]] && meters="&altitude=$METRE"
	[[ "$OPTL" ]] && local="|strptime(\"%Y-%m-%dT%H:%M:%SZ\")|mktime|strflocaltime(\"%Y-%m-%dT%H:%M:%S%Z\")"
	[[ -z "${query// }" ]] && query='São Paulo'

	if ! gpshelperf "$query"
	then echo "$0: err: cannot get geo coordenates -- $query" >&2 ;exit 1
	fi

	#get data
	data=$(curl --compressed -L -X GET -H "$UAG" -H 'Accept: application/json' "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=${LAT}&lon=${LNG}${meters}")
	if ((OPTE))
	then echo "$data" ;return
	fi

	#jq '.properties.meta' <<< "$data" >&2  #concerns json field units
	jqout=$(jq -r ".properties.timeseries[] |
\"\(.time$local) \
\(.data.instant.details |
	\"\(.air_temperature // \"?\")ºC \
\(.relative_humidity // \"?\")% \
\(.dew_point_temperature // \"?\")ºC \
\(.fog_area_fraction // \"?\") \
\(.ultraviolet_index_clear_sky // \"?\")UV \
\(.air_pressure_at_sea_level // \"?\")hPa \
\(.wind_speed // \"?\")m/s \
\(.wind_from_direction // \"?\")º \
\(.cloud_area_fraction // \"?\")% \
\(.cloud_area_fraction_high // \"?\")% \
\(.cloud_area_fraction_medium // \"?\")% \
\(.cloud_area_fraction_low // \"?\")%\"
		) \
\(.data.next_1_hours.details |
	\"\(.precipitation_amount // \"?\")mm\") \
\(.data.next_6_hours.details |
	\"\(.precipitation_amount // \"?\")mm \
\(.air_temperature_max // \"?\")ºC \
\(.air_temperature_min // \"?\")ºC\")\"" <<<"$data")
#OBS: there should be more response fields in next_1_hours and 6_hours, according to
#the API scheme format. Those are available to only some geographical areas or
#perhaps those will be implemented later for more areas.
	
	#stats
	echo "Date,Temp,RelHumidity,DewPoint,FogArea,UVIndex,AirPressureAtSeaLevel,WindSpeed,WindDir,CloudAreaFraction,CloudHighFraction,CloudMediumFraction,CloudLowFraction,PrecipitationNext1h,PrecipitationNext6h,AirMaxNext6h,AirMinNext6h
Lat: $LAT  Lng: $LNG  ${METRE:+Meters: $METRE  }${FORMATTED:-${CITY:-$query}}"

	#print table
	column -et -NDate,Temp,RelHum,DewP,FogA,UV,AirPSea,WinSp,WinDir,ClArea,ClHigh,ClMed,ClLow,Rain1h,Rain6h,AirMax6h,AirMin6h <<<"$jqout"

	#print some gfxs?
	if ((OPTG))
	then
		nlcutf 3 <<<"$jqout" | plotf Humidity date % \
		&& nlcutf 8 <<<"$jqout" | plotf 'WindSpeed' date m/s \
		&& nlcutf 15 <<<"$jqout" | plotf 'Precipitation(6h)' date mm \
		&& nlcutf 2 <<<"$jqout" | plotf Temperature date ºC
	fi

	return 0
}

#usage: sunrise ["CITY NAME"|[LAT] [LON]] [DATE] [DAYS] [HEIGHT] [OFFSET]
#!#this function needs improvements
#!#OFFSET may be calculated AUTOMATICALLY!!, weather forecast does not use OFFSET either..
sunrisef()
{
	local arg lat lon date days height offset location n

	#use location name function if criteria met
	for arg
	do [[ "$arg" != *[0-9]* ]] && location="$location $arg" n=$((n+1)) || break
	done
	if [[ -n "$location" ]] && gpshelperf "$location"
	then set -- "" "" "${@:n+1}"
	elif ! { grep -Pq '(-?\d+([.]\d+)?)' <<<"$1" && grep -Pq '(-?\d+([.]\d+)?)' <<<"$2" ;}
	then echo "$0: err: cannot get geo coordenates -- $1 $2" >&2 ;exit 1;
	fi

	#set parameters
	[[ -n "$METRE" ]] && height="&height=$METRE"
	offset="${5:-$(date +%Z:00)}"
	[[ -n "$4" ]] && days="&days=$4"
	date=$(date -d${3:-now} +%Y-%m-%d)
	lat="${LAT:-$1}" lon="${LNG:-$2}"

	curl -L -H "$UAG" "https://api.met.no/weatherapi/sunrise/2.0/.json?lat=${lat}&lon=${lon}&date=${date}${days}${height}&offset=${offset}" | jq .
}


#parse options
while getopts cd:eghklm:sv c
do case $c in
	c) OPTC=1 ;;
	d) if [[ -d "$OPTARG" ]]
		then OPTG=2 TMPDIR="${OPTARG%/}" ;plotf() { plottofilef "$@" ;}
		else echo "err: must be directory -- $OPTARG" >&2 ;exit 1
		fi ;;
	e) OPTE=1 ;;
	g) ((OPTG)) && plotf() { plotx11f "$@" ;} ;((++OPTG)) ;;
	h) echo "$HELP"; exit 0 ;;
	k) OPTK=1 ;;  #api status
	l) OPTL=1 ;;  #local time
	m) METRE=$((OPTARG)) || exit ;;
	s) OPTS=1 ;;  #sunrise
	v) grep -m1 '^# v[0-9]' "$0" ;exit ;;
	\?) exit 1 ;;
   esac
done
shift $((OPTIND - 1))
unset c

#check for reuiqred pkgs
if ! command -v curl jq &>/dev/null
then echo "$0: packages cURL and JQ are required" >&2 ;exit 1
elif ((OPTG)) && ! command -v gnuplot &>/dev/null
then echo "$0: package gnuplot is optionally required" >&2 ;OPTG=
fi

#call opt fun
#-k check weather api status
if ((OPTK))
then statusf
#-s sunrise stats
elif ((OPTS))
then sunrisef "$@"
#-c gps helper
elif ((OPTC))
then gpshelperf "$@"
#main, weather fun
else mainf "$@"
fi

