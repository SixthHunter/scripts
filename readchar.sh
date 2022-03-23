#!/bin/bash
# read user input, check for invalid chars and compose a string
# by mountaineerbr

#references
#original post:
#https://www.vivaolinux.com.br/topico/Shell-Script/Interrompendo-um-loop-while/?pagina=1
#help:
#https://www.unix.com/unix-for-dummies-questions-and-answers/130800-how-test-backspace.html

#if used as shell function, set:
#local clrline code string REPLY

#clear line code
clrline='\033[2K'

while true
do
	#visual feedback
	printf "\r${clrline}Input: %s" "${string:-(empty)}" >&2

	#user input, read one char at a time
	read -r -n 1

	#choose what to do with char
	if
		#check for backspace literal code
		#printf %x "'$REPLY"  #returns '7f'
		code="$( printf %d "'$REPLY" )"
		(( code == 127 ))
	then
		#if $string is not empty, remove last char
		(( ${#string} )) &&
			string="${string:0:$(( ${#string} - 1 ))}"
	elif
		#check for illegal chars (arbitrary)
		[[ "$REPLY" = [^a-zA-Z0-9\ ._-] ]]
	then
		printf "\r${clrline}Illegal char -- %s" "$REPLY" >&2
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

