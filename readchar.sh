#!/usr/bin/env bash
# read user input, check for invalid chars and compose a string
# by mountaineerbr

#https://www.vivaolinux.com.br/topico/Shell-Script/Interrompendo-um-loop-while/?pagina=1
#https://www.unix.com/unix-for-dummies-questions-and-answers/130800-how-test-backspace.html
#ascii table: https://www.physics.udel.edu/~watson/scen103/ascii.html

while true
do
	#visual feedback
	printf "\r\033[2KInput: %s" "${string:-(empty)}" >&2

	#user input, read one char at a time
	read -r -n 1

	#choose what to do with char
	if
		#check for backspace literal code
		#printf %x "'$REPLY"  #returns '7f'
		code="$( printf %d "'$REPLY" )"
		((code==127||code==8))
	then
		#if $string is not empty, remove last char
		(( ${#string} )) &&
			string="${string:0:$(( ${#string} - 1 ))}"
	elif
		#check for illegal chars (arbitrary)
		[[ "$REPLY" = [^a-zA-Z0-9\ ._-] ]]
	then
		printf "\r\033[2KIllegal char -- %s" "$REPLY" >&2
		sleep 0.5
	elif
		#if $REPLY is empty (Enter = Newline)
		[[ -z "$REPLY" ]]
	then
		break
	else
		#compose input string
		string="$string$REPLY"
	fi
done

#print final string
echo -e "\aFinal: $string"

