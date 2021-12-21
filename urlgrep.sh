#!/usr/bin/env bash
# urlgrep.sh -- grep full-text urls
# v0.20.5  oct/2021  by mountaineerbr

# Pipe URLs via stdin. Grep takes all positional parameters.
# Usage: urlgrep.sh [GREP_OPTION..] 
# Examp: echo https://distrowatch.com/ | urlgrep.sh -i linux
# Tip  : set `--color=always' to enable colours

#max simultaneous jobs
JOBMAX=4

#user agent
USERAGENT="user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) \
AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36"

#colours
[[ -t 1 && " $* " = *\ --colo?(u)r=always\ * ]] \
&& C1='\e[1;37;44m' C2='\e[1;34;47m' EC='\e[00m'

#check for grep errors
grep "$@" <<<\  ;(($?<2)) || exit 2

#loop through links
while read -r URL
do
	#remove carriage returns and increment counter
	URL="${URL//$'\r'}" N=$((N+1))
	#job control (bash)
	while JOBS=($(jobs -p)) ;((${#JOBS[@]} > JOBMAX)) ;do sleep 0.1 ;done
	#feedback
	printf "${C2}%d${EC}\r" "$N" >&2

	#async jobs, buffer output
	{
	RESULT=$(
		# CURL/WGET
		curl -sL \
			-b emptycookie \
			--insecure \
			--compressed \
			--header "$USERAGENT" \
			--retry 2 \
			--connect-timeout 240 \
			--max-time 240 \
			"$URL" |
		# MARKUP FILTER
		w3m -dump -T text/html |
		# GREP COMMAND
		grep "$@"
	) && printf "%s\n${C1}>>>%s${EC}\n\n" "$RESULT" "$URL"
	} &
done
wait


## Resources

## Wget
#{ wget -q -O- --no-check-certificate --header="$USERAGENT" -e robots=off --tries=2 --connect-timeout=240 --timeout=240 "$REPLY" ;}

## Markup filters
#{ elinks -force-html -dump -no-references ;}
#{ links -force-html -dump ;}
#{ lynx -force_html -dump -nolist ;}
#{ sed 's/<[^>]*>//g' ;}
#{ sed '/</{ :loop ;s/<[^<]*>//g ;/</{ N ;b loop } }' ;}
