#!/usr/bin/env bash
#!/usr/bin/env zsh
# bcalc.sh -- shell maths wrapper
# v0.14.13  nov/2021  by mountaineerbr

#record file path (optional)
BCRECFILE="${BCRECFILE:-"$HOME/.bcalc_record.tsv"}"

#extensions file path (optional)
BCEXTFILE="${BCEXTFILE:-"$HOME/bin/bcalc_ext.bc"}"

#special variable for retrieval from record file
BCHOLD=res

#scale
BCSCALE=16

#max bc result line length
export BC_LINE_LENGTH=10000
#obs:set 0 to disable multiline results in newer bc versions

#word archors
WORDANCHOR='[^a-zA-Z0-9_]'

#script name
SN="${0##*/}"

#man page
HELP_LINES="NAME
	$SN -- shell maths wrapper


SYNOPSIS
	$SN  [-,.eftvz] [-NUM] EXPRESSION
	$SN  -n [INDEX] TEXT
	$SN  -r [NUM] [MAXWIDTH]
	$SN  [-eehrrRV]


DESCRIPTION
	$SN wraps shell calculator (bc) and Zshell maths evaluation
	and adds some useful features.

	Input EXPRESSION must be one line, multiline is transformed into one
	line. If no EXPRESSION is given and stdin is not free, reads stdin
	as input, otherwise prints last result from record file.

	If a historical record file is available, special variables can be
	replaced with results from former operations. Data in stored as tab
	separated values (tsv) at \`${BCRECFILE}'.
	Set -f to disable usage of record file.

	Special variables \`${BCHOLD}' or \`${BCHOLD}0' will be changed to the last result,
	however \`${BCHOLD}1' and so forth will be changed to the specified result
	index. The result index number is the same as line number in the re-
	cord file. Defaults special variable \`${BCHOLD}'. Check result index with
	options -rrv.

	Scale can be set with -NUM. User may set scale in bc via
	\`scale=NUM ; [EXPRESSION]' syntax, too. Scale of floating point
	numbers are dependent on user input for all operations except
	division in bc. Defaults scale is ${BCSCALE}.

	In zshell maths, floating point evaluation is performed automati-
	cally depending on user input. However note that \`3' is an integer
	while \`3.' is a floating point number. Zsh keeps an internal double-
	precision floating point representation (double C type) of numbers,
	hence expression \`3/4' evaluates to \`.75' rather than \`0'. However,
	in this script FORCE_FLOAT is set by defaults, just note that results
	will be converted back to the closest decimal notation from the in-
	ternal double-point.

	Option -n adds notes to record file entries. If the first positional
	argument after this option is an INDEX number, adds note to that
	entry, otherwise adds to the last record entry.

	Option -e loads bc mathlib and extension file or zshell mathfunc
	module. Set bc extensions file path in script head source code.

	Trailing zeroes will be trimmed unless extension option -e is set,
	in which case result is printed in raw format.


DECIMAL SEPARATOR AND THOUSANDS GROUPING
	Bc and Zshell maths only accept dot (.) as input decimal sepa-
	rator and that is defaults. Set option \`-.' for dot (.) as input
	decimal separator (and removal of all commas) or \`-,' to set it as
	(,) comma intead (and removal all dots). Beware that some bc
	and zsh functions may use comma as operators.

	Setting \`-..' means input and output decimal separators should be
	dots (.). Rather, setting \`-.,' means input decimal separator is
	a dot (.) but output should be printed with decimal separator as
	comma (,).

	Option -t prints output with thousands grouping. Beware shell-
	specific output length and scale limitations when using this option.


	Examples
	Option -,
		(input) 	    (internal) 	    (output)
		1.234.567,00 	--> 1234567.00 	--> 1234567,00

	Option -.,
		(input) 	    (internal) 	    (output)
		1,234,567.00 	--> 1234567.00 	--> 1234567,00


	Option -t
		(input) 	    (output)
		1234567.00 	--> 1,234,567.00


ENVIRONMENT
	BCHOLD
		Special variable name that will be changed to results from
		the record file index, defaults=\"$BCHOLD\".

	BCRECFILE
		Record (history) file path, defaults=\"$BCRECFILE\".

	BCEXTFILE
		Extensions file path for bc, defaults=\"$BCEXTFILE\".
	
	LC_NUMERIC
	LC_ALL
		Affects locale related numeric formats, such as thousands
		delimiter, decimal delimiter. Note that C/POSIX cannot
		effect thousand grouping.


SHELL INTERPRETERS
	This script code is compatible with Bash and Zshell maths.


BC STANDARD FUNCTIONS
	There are a few functions provided in bc enabled by defaults named
	user-defined and standard functions. They appear as \"name(parameters)\".
	The standard functions are:
	
	length ( expression )
	    The value of the length function is the number of significant
	    digits in the expression.

	read ( )
	    The read function (an extension) will read a number from the 
	    standard input, regardless of where the function occurs.
	    Beware, this can cause problems with the mixing of data and
	    program in the standard input. The best use for this function
	    is in a previously written program that needs input from the
	    user, but never allows program code to be input from the user.
	    The value of the read function is the number read from the
	    standard input using the current value of the variable ibase
	    for the conversion base. 

	scale ( expression )
	    The value of the scale function is the number of digits after
	    the decimal point in the expression. 

	sqrt ( expression )
	    The value of the sqrt function is the square root of the
	    expression. If the expression is negative, a run time error
	    is generated. 


	Mathlib scale defaults to 20 plus one uncertainty digit.


BC MATH LIBRARY
	Option -e will load bc builtin math library, which contain
	more functions, as well as external extensions.
	
	Be aware that the accuracy of indeed many a function written in
	bc is directly affected by the value of the scale variable. 

	Check \`man bc' and \`info bc' for detailed instructions on usage.
	Bc built-in math library defines the following functions:

		s (x)  Sine of x, x is in radians.
		c (x)  Cosine of x, x is in radians.
		a (x)  Arctangent of x, arctangent returns radians.
		l (x)  Natural logarithm of x.
		e (x)  Exponential function of raising e to the value x.
		j (n,x)
		       Bessel function of integer order n of x.


	The scientific extensions defaults to 100 digits.


BC EXTENSIONS
	Option -e will load further bc funtions after mathblib if the ex-
	tensions file is available at \`$BCEXTFILE'. This is a
	custom file and can contain further functions and constant def-
	initions such as Avogadro number, Planck constant, the proton rest
	mass, pi, as well as extra math functions such as \`ln(x)' (natural
	log) and \`log(x)' (base 10), please check references below.

	Comments in bc start with the characters \`/*' and end with the
	characters \`*/'. A single line comment	starts at a \`#' character
	and continues to the end of the line.


	References
	<http://x-bc.sourceforge.net/scientific_constants.bc>
	<http://x-bc.sourceforge.net/extensions.bc>
	<http://phodd.net/gnu-bc/>
	<http://www.pixelbeat.org/scripts/bc>
	<https://github.com/mountaineerbr/scripts>.


ZSHELL MATHFUNC MODULE
	Option -e will load \`zsh/mathfunc' module if available. Check
	\`man zshmodules' for the mathfunc module and \`man zshcontrib'
	for detailed explanation and mathematical function descriptions. 

	An arithmetic expression uses nearly the same syntax and associa-
	tivity of expressions as in C. In the native mode of operation, the
	following operators are supported (listed in decreasing order of
	precedence):

		 + - ! ~ ++ --
			unary plus/minus, logical NOT, complement, 
			{pre,post}{in,de}crement
		 << >>  bitwise shift left, right
		 &      bitwise AND
		 ^      bitwise XOR
		 |      bitwise OR
		 **     exponentiation
		 * / %  multiplication, division, modulus (remainder)
		 + -    addition, subtraction
		 < > <= >=
			comparison
		 == !=  equality and inequality
		 &&     logical AND
		 || ^^  logical OR, XOR
		 ? :    ternary operator
		 = += -= *= /= %= &= ^= |= <<= >>= &&= ||= ^^= **=
			assignment
		 ,      comma operator


	The following functions take a single floating point argument:
	acos, acosh,asin, asinh, atan, atanh, cbrt, ceil, cos, cosh, erf,
	erfc, exp, expm1, fabs, floor, gamma, j0, j1, lgamma, log, log10,
	log1p, log2, logb, sin,  sinh,  sqrt, tan, tanh, y0, y1. The atan
	function can optionally take a second argument, in which case it
	behaves like the C function atan2. The ilogb function takes a
	single floating point argument, but returns an integer.
	
	The functions min, max, and sum are defined in the zmathfunc
	autoloadable function, described in the section \`Mathematical
	Functions' in zshcontrib(1).


SHELL FUNCTIONS
	There is a useful function to use with bc.

		(I) 	function c() { bc -l <<< \"\$*\" ;}


	In zshell, it may be useful to use an alias and function to avoid
	quoting expression. A calculator function called zcalc is bundled
	with the shell. To load zcalc execute \`autoload -Uz zcalc'.

		(II) 	alias c='noglob calcMain'
			function calcMain() {
				setopt localoptions forcefloat
				typeset -F 2 exp
				exp=\"\$*\"
				print \"\$exp\"
			}
		
		(III) 	alias c='noglob zcalc -f -e'


WARRANTY
	This programme is licensed under GPLv3 and above. It is distrib-
	uted without support or bug corrections.

	Tested with GNU Bash 5.0 and ZSH 5.8. Requires GNU coreutils.

	If useful, please consider sending me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


BUGS
	Bash and Zsh have got decimal precision limits when printig results
	with thousands grouping (option -t). Scale should not exceed 20 dec-
	imal plates worth of length in bash and output should not exceed 16
	digits in Zsh.

	Multiline input not supported.


USAGE EXAMPLES
	(I)   Equation escaping

		$ $SN '(-20-20)/2'
		
		$ $SN \\(20*20\\)/2

		$ $SN -- -3+30


	      Zshell precommand noglob

		$ noglob $SN (20*20)/2


	(II)  Bc syntax to define reusable parameters within 
	      expression, note variables must be _lowercase_

		$ $SN 'a=8; dog=2; cat=dog; a/(cat+dog)'


		In Zsh, one can set environment variables to use them in equation

		$ export dog=2 cat=3
		$ $SN -z dog+cat

		
	(III) Setting scale to two decimal plates

		$ $SN -s2 1/3

		$ $SN -2 1/3
		
		$ echo 0.333333333 | $SN -2


	      Grouping thousands in result

		$ $SN -t 100000000


	      Bc read the following syntax in EXPRESSION for setting scale

		$ $SN 'scale=2; EXPRESSION'


	(IV)  Loading bc extensions

		$ $SN -e 'ln(0.3)'   #natural log function

		$ $SN -e 0.234*na    #na is Avogadro number


	(V)   Adding notes to record file entries (may need ecaping)

		$ $SN -n '<This is added to last entry; \$scape w||*ird ch&r& & >'
	
		$ $SN -n 3 This note is for record index 3.
		

OPTIONS
	Miscellaneous
	-z 	  Run script with zsh.
	-h 	  Print this help page.
	-v 	  Verbose output.
	-V 	  Print script version.
	
	Record File
	-f 	  Disable use of record file.
	-n [INDEX] TEXT
		  Add note to record INDEX or to last record entry.
	-r [NUM] [MAXWIDTH]
		  Print last NUM lines (def=10), set column MAXWIDTH (def=40).
	-rr 	  Print full record with line numbers.
	-R 	  Edit with \$VISUAL or \$EDITOR (def=vi).
	
	Extensions
	-e 	  Load bc extensions or zsh mathfunc when available.
	-ee 	  Print bc extension file when available.

	Input and Output Formatting
	-, 	  Set decimal separator of input/output as (,) comma.
	-. 	  Set decimal separator of input/output as (.) dot.
	-NUM 	  Scale (decimal plates).
	-t 	  Thousands grouping in result."


#functions
#calculators
calcf()
{
	local eq bceq
	eq="$1" bceq="scale=${OPTS:-$BCSCALE}; $eq / 1"
	[[ "${eq// }" ]] || return

	#zshell
	if ((ZSH_VERSION))
	then
		#mathfunc module
		((OPTE)) && zmodload zsh/mathfunc
		#set float numbers and scale
		setopt LOCAL_OPTIONS FORCE_FLOAT
		typeset -F "${OPTS:-$BCSCALE}" eq
		print "$eq"
	#bc
	else
		if ((OPTE))
		then
			#set mathlib and extensions file
			if [[ -e "$BCEXTFILE" ]]
			then set -- -l "$BCEXTFILE"
			#mathlib only
			else set -- -l ;((OPTV)) && echo "warning: bc mathlib only" >&2
			fi
		else set --
		fi
		bc "$@" <<<"$bceq"
	fi
}

#-n add note function
notef()
{
	local text num
	text="$*" text="${text//[$'\t\n']/ }"
	[[ "$text" =~ ^\ *[0-9]+\ * ]]
	num="${MATCH:-${BASH_REMATCH[0]}}" text="${text#$num}"
	[[ "$text" =~ ^\ * ]]
	sed -i -e "${num:-$} s/ *$/ ${text#${MATCH:-${BASH_REMATCH[0]}}}/ ;${num:-$} s/"$'\t'" */"$'\t'"/g" "$BCRECFILE"
}
#https://superuser.com/questions/781558/sed-insert-file-before-last-line
#http://www.yourownlinux.com/2015/04/sed-command-in-linux-append-and-insert-lines-to-file.html

#-eecc print extensions to user
opteef()
{
	#does bc extension file exist?
	if [[ -e "$BCEXTFILE" ]]
	then cat -- "$BCEXTFILE"
	#check whether zsh is running
	elif ((ZSH_VERSION))
	then print "$SN: warning: zsh -- check zsh/mathfunc" >&2 ;return 1
	else echo "$SN: err: bc extension file not available -- $BCEXTFILE" >&2 ;return 1
	fi
}

#print or edit record file
precff()
{
	local lines truncate
	((${1:-0})) && lines="$1"
	#edit record file
	if ((OPTP<0))
	then command "${VISUAL:-${EDITOR:-vi}}" -- "$BCRECFILE"
	#generate record file table
	elif ((OPTP==1))
	then 	((${2:-0}>10 && ${2:-600}<600)) && truncate="$2"
		nl -ba -- "$BCRECFILE" | tail -n"${lines:-10}" \
		| sed -r -e "s/([^\t]{0,${truncate:-40}})[^\t]*/\1/g" -e 's/^(([^\t]*\t){2})([^\t]*)\t/\1{ \3 }\t/' \
		| if command column --help &>/dev/null ;then column -ets$'\t' -NINDEX,RESULT,EXPRESSION,DATE,NOTE ;else column -ts$'\t' ;fi \
		| less -S
	#print entire record file
	elif ((OPTP))
	then nl -ba -- "$BCRECFILE"
	fi
}


#parse options
while getopts ,.0123456789efhlnorRtvVz- opt
do
	case $opt in
		#change input/output decimal separator
		,) 	OPTDEC=${OPTDEC:0:1}, ;;
		#change input/output decimal separator
		\.) 	OPTDEC=${OPTDEC:0:1}. ;;
		#scale
		[0-9]) 	OPTS="$OPTS$opt" ;;
		-) 	OPTS= ;;
		#load or print bc extensions
		e|l)
			if ((OPTE))
			then opteef ;exit
			else ((++OPTE))
			fi ;;
		#disable use record file
		f) 	unset BCRECFILE ;;
		#print help
		h) 	echo "$HELP_LINES" ;exit ;;
		#add note to record
		n) 	((++OPTN)) ;;
		#print record
		r) 	((++OPTP)) ;;
		#edit record
		R) 	OPTP=-100 ;;
		#thousand separator
		t|o) 	((++OPTT)) ;;
		#verbose
		v) 	((++OPTV)) ;;
		#print script version
		V)
			echo "${ZSH_VERSION:-BASH}  ${BASH_VERSION:-ZSH}" 
			grep -m1 '^\# v' "$0"
			exit ;;
		#try to run script with zsh
		z)
			if ((! ZSH_VERSION))
			then env zsh "$0" "$@" ;exit
			fi ;;
		#illegal option
		\?) 	exit 1 ;;
	esac
done
shift $((OPTIND -1))

#set equation. is it stdin input? (beware options)
EQ="$*" ;[[ ! -t 0 && $#+OPTN+OPTP -eq 0 ]] && EQ=$(</dev/stdin)
#copy original equation and remove ending ';', 'new lines' and 'tabs' from it
EQ_ORIG="$EQ" EQ="${EQ%;}" EQ="${EQ//[$'\t\n']/ }"

#retrieve special vars from record file?
if [[ -s "$BCRECFILE" ]]
then
	#opt fun
	#add note to record
	if ((OPTN))
	then notef "$*" ;exit
	#print or edit record file
	elif ((OPTP))
	then precff "$@" ;exit
	fi
	
	#get last result index
	LASTIND=$(wc -l <"$BCRECFILE")
	#change special variable to corresponding result or retrieve last result if $EQ is empty
	while [[ "${EQ:=$BCHOLD}" =~ (^|$WORDANCHOR)(${BCHOLD:-@%@%}[0-9]*)($WORDANCHOR|$) ]]
	do
		subeq="${MATCH:-${BASH_REMATCH[0]}}"
		eqvar="$subeq" eqvar="${eqvar#$WORDANCHOR}" eqvar="${eqvar%$WORDANCHOR}"
		eqind="${eqvar//[^0-9]}"
		aleft="${subeq%%$eqvar*}" aright="${subeq##*$eqvar}"
		((eqind)) || eqind=$LASTIND
		((eqind > LASTIND)) && { echo "err: invalid index reference -- $eqvar" >&2 ;exit 1 ;}
		recvar=$(awk "NR == $eqind { print \$1 }" "$BCRECFILE")

		[[ "${EQ// }" = "${eqvar:-@%@%}" ]] && SIMPLEVAREQ=1 LASTIND=$eqind
		EQ="${EQ//"$aleft$eqvar$aright"/$aleft$recvar$aright}" ;[[ "$EQ" ]] || exit
	done
	unset subeq eqvar eqind aright aleft recvar
elif ((OPTN+OPTP))
then echo "$SN: err -- record file not available" >&2 ;exit 1
fi

#-. dot is input decimal separator
if [[ "$OPTDEC" = .* ]]
then EQ="${EQ//,}"
#-, comma is input decimal separator
elif [[ "$OPTDEC" = ,* ]]
then EQ="${EQ//.}" EQ="${EQ//,/.}"
fi

#checks
#did input change?
[[ "$OPTV" && "$EQ" != "$EQ_ORIG" ]] && echo "input change -- $EQ" >&2
#multiple decimal separators: "1.2." "1,2," "1.2,3."  ",.,"  
if [[
	"$EQ" =~ [0-9]*[.][0-9]*[.] ||
	"$EQ" =~ [0-9]*[,][0-9]*[,] ||
	"$EQ" =~ [0-9]*[.][0-9]*[,][0-9]*[.] ||
	"$EQ" =~ [0-9]*[,][0-9]*[.][0-9]*[,] 
]]
then echo "warning: excess of decimal separators  -- $EQ" >&2
fi

#calculate expression result
RES=$(calcf "$EQ") || exit
[[ "$RES" ]] || exit

#print to record file? dont record duplicate results
#TSV fields: result, expression, date and note
timestamp=$(date -Iseconds)
recordout="$RES	$EQ	$timestamp	"
if [[ -e "$BCRECFILE" ]]
then
	IFS=$'\t' read -r lastres lasteq lastdate lastnote < <(tail -1 "$BCRECFILE") 
	if [[ ( "$RES" != "$lastres" || "$EQ" != "$lasteq" ) && "$SIMPLEVAREQ" -eq 0 ]]
	then echo "$recordout" >>"$BCRECFILE" ;LASTIND=$((LASTIND+1))
	fi
elif [[ "$BCRECFILE" ]]  #init tsv
then echo "$recordout" >>"$BCRECFILE"
fi
unset recordout lastres lasteq lastdate lastnote timestamp

#format and print result
#add thousand separator if opt -t is set
if ((OPTT))
then RES=$(printf "%'.*f\n" "${OPTS:-2}" "$RES")
#trim trailing zeroes, skip if any opt -ce is set
elif [[ -z "$OPTE$OPTS" ]]
then
	#bc hack
	if [[ "$BASH_VERSION" ]]
	then RES=$(bc <<<"define trunc(x){auto os;scale=${OPTS:-200};os=scale; for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc($RES)")
	#zsh
	else [[ "$RES" =~ [.]{,1}0{1,}$ ]] && RES="${RES%$MATCH}"
	fi
fi

#print special variable index, too?
((OPTV && LASTIND)) && RES+="	 #$LASTIND#"

#swap output decimal and thousands delimiters?
if [[ "$OPTDEC" = ?, ]]
then tr ., ,. <<<"$RES"
else echo "$RES"
fi
