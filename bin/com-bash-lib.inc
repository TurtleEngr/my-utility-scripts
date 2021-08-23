
# pub-fun.inc

# --------------------------------
function fSummary
{
	# Print summary help for this script, using pod2text.
	pod2usage $0

	if [ $# -ne 0 ]; then
		# Don't exit if an arg is passed
		return
	fi
	gErr=1
	fCleanUp
	exit 1
} # fSummary

# --------------------------------
function fError
{
	# Usage:
	#     fError pMsg [-m pMsg] [-l pLine] [-e pErr]
	# Print the error message.  Then call fCleanUp, and exit

	local pMsg=""
	local pLine=""
	local pErr=1
	local OPTIND
	local tArg

	while getopts m:l:e: tArg; do
		case $tArg in
			m)	pMsg="${OPTARG}";;
			l)	pLine="${OPTARG}";;
			e)
				pErr="${OPTARG}"
				gErr="${OPTARG}"
			;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pMsg="$pMsg $*"
	fi
	
	fLog -p crit -m "$pMsg" -l $pLine -e $pErr -s
	fSummary
	fCleanUp
	exit 1
} # fError

# ------------------
function fLog
{
	# Usage:
	#    fLog pMsg [-m pMsg] [-p pLevel] [-l pLine] [-e pErr] [-s]
	# Args
	#    -m pMsg
	#    -p pLevel - emerg alert crit err warning notice info debug
	#    -l pLine - usually: -l $LINENO
	#    -e pErr - will also set gErr
	#    -s - stderr output (also set with gpVerbose)
	# Config:
	#    gLogFacility=user
	#	user - misc scripts
	# 	local0 - system or application configuration
	# 	local1 - application processes
	# 	local2 - web site errors
	# 	local3 - web site access
	# 	local4 - backend processes
	# 	local5 - publishing
	# 	local6 - available
	# 	local7 - available

	export gLogFacility=${gLogFacility:-user}
	local pLevel="info"
	local pMsg=""
	local pLine=""
	local pErr=""
	local pStdErr=""
	local OPTIND
	local tArg
	local tFmt

	while getopts m:p:l:e:s tArg; do
		case $tArg in
			m)	pMsg="${OPTARG}";;
			l)	pLine="${OPTARG}";;
			p)	pLevel="${OPTARG}";;
			e)
				pErr="${OPTARG}"
				gErr="${OPTARG}"
			;;
			s)	pStdErr="-s"
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pMsg="$pMsg $*"
	fi

	tFmt=""
	if [ -n "$pLine" ]; then
		tFmt="${tFmt}[$pLine]"
	fi
	if [ -n "$pErr" ]; then
		tFmt="${tFmt}($pErr)"
	fi

	if [ $gpDebug -ne 0 ]; then
		echo "${cName} $pLevel: $pMsg $tFmt" 1>&2
		return
	fi

	logger $gpVerbose $pStdErr -i -t $cName -p ${gLogFacility}.${pLevel} "$pLevel: $pMsg $tFmt"
} # fLog

# --------------------------------
function fConfSet
{
	# Set the value to pName in the git pConfig file
	# Usage:
	#    fConfSet [-c pCategory] [-s pSection] -n pName -f pConf "pValue"
	# Args:
	#    -c pCategory - Override gConfCategory (no dots in name)
	#    -s pSection - Override gConfSection (can be blank) (no dots in name)
	#    -n pName - ini variable name including section (no dots in name)
	#    -f pConf - ShortName:FullPath, or just FullPath
	#    pValue - all the rest of line will be the value
	# Description
	#    The variable pName will be added to the git config file
        #    pConf, and put in pCategory, and if provided with section
        #    pSection.
	#    Spaces in the values will be replaced with '|'.  That is
        #    so selections by the fConfPrompt functions are easy.

	export gConfCategory=${gConfSection:-user}
	export gConfSection
	
	local pCategory="$gConfCategory"
	if [ -n "$gConfSection" ]; then
		local pSection=".$gConfSection"
	else
		local pSection=""
	fi
	local pName=""
	local pConf=""

	local OPTIND
	local tArg
	local tPath

	while getopts c:s:n:f: tArg; do
		case $tArg in
			c)	pCategory="${OPTARG}";;
			s)	pSection=".${OPTARG}";;
			n)	pName="${OPTARG}";;
			f)	pConf="${OPTARG}";;
			:)	fError -m "fConfSet missing value for: $tArg" -l $LINENO -e 9801;;
			\?)	fError -m "fConfSet unknown option: $tArg" -l $LINENO -e 9802;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pValue="$(echo $* | tr ' ' '|')"
	fi

	# Required parms (quit if missing?)
	#pCategory
	#pName
	#pConf
	# TBD
	
	tPath=${pConf#*:}
	tPathDir=${pConf%/*}
	if [ ! -w "$tPathDir" ]; then
		fError -m "fConfGet cannot find or write to: $tPathDir" -l $LINENO -e 9803
	fi

	git config -f $tPath ${pCategory}${pSection}.${pName} "$pValue"
} # fConfSet

# --------------------------------
function fConfGet
{
	# Get value of a pName from the listed git config files.
	# Usage:
	#    fConfGet -c pCategory [-s pSection] -n pName [-m] [-u] [-f pConf]* pConf*
	# Args:
	#    pCategory - Override gConfCategory (no dots in name)
	#    pSection - Override gConfSection (can be blank) (no dots in name)
	#    pName - ini variable name including section (no dots in name)
	#    -m - get all values from all pConf files, rather than the first one
	#    -u - only add new values
	#    -f pConf - ShortName:FullPath (zero or more -f options)
	#    pConf - zero or more config files.  Add -f list
	#
	# Return:
	#    gLastGet
	#
	# pConf file format:
	# [$pCategory $pSection]
	#         $pName = VALUE
	# [$pCategory]
	#         $pName = VALUE

	export gConfCategory=${gConfSection:-user}
	export gConfSection
	export gLastGet
	
	local pConf=""
	local pMany=0
	local pUnique=0
	local pCategory="$gConfCategory"
	if [ -n "$gConfSection" ]; then
		local pSection=".$gConfSection"
	else
		local pSection=""
	fi
	local pName=""

	local OPTIND
	local tArg
	local c
	local tLast
	local tShort
	local tPath

	while getopts c:s:n:f:mu tArg; do
		case $tArg in
			c)	pCategory="${OPTARG}";;
			s)	pSection=".${OPTARG}";;
			n)	pName="${OPTARG}";;
			f)	pConf="$pConf ${OPTARG}";;
			m)	pMany=1;;
			u)	pUnique=1;;
			:)	fError -m "fConfGet missing value for: $tArg" -l $LINENO -e 9804;;
			\?)	fError -m "fConfGet unknown option: $tArg" -l $LINENO -e 9805;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pConf="$pConf $*"
	fi

	# Required parms (quit if missing?)
	#pCategory
	#pName
	#pConf
	# TBD
	
	tLast=""
	gLastGet=""
	for c in $pConf; do
		tShort=${c%:*}
		if [ "$tShort" = "$c" ]; then
			tPath=$c
			tShort=""
		else
			tPath=${c#*:}
			tShort="${tShort}:"
		fi
		tLast=$(git config -f $tPath --get ${pCategory}${pSection}.${pName})
		if [ -n "$tLast" ]; then
			if [ $pMany -eq 0 ]; then
				gLastGet=${tShort}${tLast}
				break
			else
				if [ $pUnique -eq 0 ]; then
					gLastGet="$gLastGet ${tShort}${tLast}"
				else
					if [ "$gLastGet" = "${gLastGet#*[ :]$tLast}" ]; then
						gLastGet="$gLastGet ${tShort}${tLast}"
					fi
				fi
			fi
		fi
	done
	# Defect in Cygwin Bash, ## doesn't remove multiple blanks
	gLastGet="${gLastGet## }"
	gLastGet="${gLastGet## }"
	gLastGet="${gLastGet## }"
	gLastGet="${gLastGet%% }"
	gLastGet="${gLastGet%% }"
	gLastGet="${gLastGet%% }"
} # fConfGet

# --------------------------------
function fConfPromptStr
{

	# Select one string value from pName list from the list of
	# git config files.
	#
	# Usage:
	#    fConfPromptStr -p "pPrompt" [-e]  [-o "pOther"] [-h] \
	#        -c pCategory [-s pSection] -n pName [-f pConf]* pConf* 
	# Args:
	#    -p pPrompt
	#    -e - can have Empty value
	#    -o pOther - other options
	#    -h - help can be found in var gConfHelp variable
	#    -c pCategory - Override gConfCategory (no dots in name)
	#    -s pSection - Override gConfSection (can be blank) (no dots in name)
	#    -n pName - ini variable name including section (no dots in name)
	#    -f pConf - ShortName:FullPath (zero or more -f options)
	#    pConf - zero or more config files.  Add -f list
	#
	# Return:
	#    gLastPrompt

	export gConfCategory=${gConfSection:-user}
	export gConfSection
	export gLastPrompt=""
	
	local pConf=""
	local pPromp="Select? "
	local pEmpty=""
	local pOther=""
	local pHelp=""
	local pQuit=""
	local pCategory="$gConfCategory"
	if [ -n "$gConfSection" ]; then
		local pSection=".$gConfSection"
	else
		local pSection=""
	fi
	local pName=""

	local OPTIND
	local tArg
	local c
	local i
	local tLast
	local tShort
	local tPath
	local tList=""
	local tStr=""
	local tValue=""

	while getopts c:s:n:f:p:eo:hq tArg; do
		case $tArg in
			c)	pCategory="${OPTARG}";;
			s)	pSection="-s ${OPTARG}";;
			n)	pName="${OPTARG}";;
			f)	pConf="$pConf ${OPTARG}";;
			p)	pPrompt="${OPTARG}";;
			e)	pEmpty="NONE";;
			o)	pOther="${OPTARG}";;
			h)	pHelp="HELP";;
			q)	pQuit="QUIT";;
			:)	fError -m "fConfPromptStr missing value for: $tArg" -l $LINENO -e 9808;;
			\?)	fError -m "fConfPromptStr unknown option: $tArg" -l $LINENO -e 9809;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pConf="$pConf $*"
	fi

	# Required parms (quit if missing?)
	#pCategory
	#pName
	#pConf
	# TBD
	
	fConfGet -m -u -c $pCategory $pSection -n $pName $pConf
	tLast="$gLastGet"

	export PS3="$pPrompt "
	echo
	select tValue in $tLast $pOther $pEmpty $pHelp $pQuit; do
		case $tValue in
			QUIT)	fCleanUp;;
			HELP)
				echo
				echo -n "$gConfHelp"
				echo
				if [ -n "$pQuit" ]; then
				     	echo "QUIT - exit now and do nothing"
				fi
				if [ -n "$pEmpty" ]; then
					echo "NONE - set the value to nothing"
				fi
				if [ -n "$tList" ]; then
					echo "LIST - select inividual values"
				fi
				if [ -n "$tStr" ]; then
					echo "STRING - select from list of values"
				fi
				echo
			;;
			NONE)
				tValue=""
				break
			;;
			*)	break;;
		esac
	done

	gLastPrompt="$tValue"
} # fConfPromptStr

# --------------------------------
function fConfPromptStrList
{
	# Select one string value from pName list from the list of
	# git config files. Or if LIST is selected, the build up a new
	# string list from single values.
	#	
	# Usage:
	#    fConfPromptStrList -p "pPrompt" [-e]  [-o "pOther"] [-h] \
	#        -c pCategory [-s pSection] -n pName [-f pConf]* pConf* 
	# Args:
	#    -p pPrompt
	#    -e - can have Empty value
	#    -o pOther - other options
	#    -h - help can be found in var gConfHelp variable
	#    -c pCategory - Override gConfCategory (no dots in name)
	#    -s pSection - Override gConfSection (can be blank)(no dots in name)
	#    -n pName - ini variable name including section (no dots in name)
	#    -f pConf - ShortName:FullPath (zero or more -f options)
	#    pConf - zero or more config files.  Add -f list
	#
	# Return:
	#    gLastPrompt

	local pParm=""
	local pPrompt=""
	local OPTIND
	local tArg

	while getopts c:s:n:f:p:ehq tArg; do
		case $tArg in
			c)	pParm="$pParm -c ${OPTARG}";;
			s)	pParm="$pParm -s ${OPTARG}";;
			n)	pParm="$pParm -n ${OPTARG}";;
			f)	pParm="$pParm -f ${OPTARG}";;
			p)	pPrompt="${OPTARG}";;
			e)	pParm="$pParm -e";;
			h)	pParm="$pParm -h";;
			q)	pParm="$pParm -q";;
			:)	fError -m "fConfPromptStrList missing value for: $tArg" -l $LINENO -e 9806;;
			\?)	fError -m "fConfPromptStrList unknown option: $tArg" -l $LINENO -e 9807;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pParm="$pParm $*"
	fi

	fConfPromptStr -o LIST -p "$pPrompt" $pParm
	if [ "$gLastPrompt" = "LIST" ]; then
		fConfPromptList -p "$pPrompt" $pParm
	fi
} # fConfPromptStrList

# --------------------------------
function fConfPromptList
{
	# Select one value from pName list from the list of git
        # config files, and add it to the list of previously selected
        # names.
	#
	# Usage:
	#    fConfPromptList -p "pPrompt" [-e] [-o "pOther"] [-h] \
	#    		 -c pCategory [-s pSection] -n pName [-f pConf]* pConf* 
	# Args:
	#    -p pPrompt
	#    -e - can have Empty value
	#    -o pOther - other options
	#    -h - help can be found in var gConfHelp variable
	#    -c pCategory - Override gConfCategory (no dots in name)
	#    -s pSection - Override gConfSection (can be blank)(no dots in name)
	#    -n pName - ini variable name including section (no dots in name)
	#    -f pConf - [ShortName:]FullPath (zero or more -f options)
	#    pConf - zero or more config files.  Add -f list
	#
	# Return:
	#    gLastPrompt

	export gConfCategory=${gConfSection:-user}
	export gConfSection
	export gLastPrompt=""
	
	local pConf=""
	local pPromp="Select? "
	local pEmpty=""
	local pOther=""
	local pHelp=""
	local pQuit=""
	local pCategory="$gConfCategory"
	if [ -n "$gConfSection" ]; then
		local pSection=".$gConfSection"
	else
		local pSection=""
	fi
	local pName=""

	local OPTIND
	local tArg
	local c
	local i
	local tLast
	local tShort
	local tPath
	local tList=""
	local tStr=""
	local tValue=""

	while getopts c:s:n:f:p:eho:q tArg; do
		case $tArg in
			c)	pCategory="${OPTARG}";;
			s)	pSection="-s ${OPTARG}";;
			n)	pName="${OPTARG}";;
			f)	pConf="$pConf ${OPTARG}";;
			p)	pPrompt="${OPTARG}";;
			e)	pEmpty="CLEAR";;
			o)	pOther="${OPTARG}";;
			h)	pHelp="HELP";;
			q)	pQuit="QUIT";;
			:)	fError -m "fConfPromptList missing value for: $tArg" -l $LINENO -e 9810;;
			\?)	fError -m "fConfPromptList unknown option: $tArg" -l $LINENO -e 9811;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pConf="$pConf $*"
	fi

	# Required parms (quit if missing?)
	#pCategory
	#pName
	#pConf
	# TBD
	
	fConfGet -m -u -c $pCategory $pSection -n $pName $pConf

	# Prepare
	for i in $gLastGet; do
		tLast="$tLast $(echo ${i#*:} | tr '|' ' ')"
	done
	tLast=$(echo $tLast | tr ' ' '\n' | sort -u)

	export PS3="$pPrompt "
	echo
	select tValue in DONE $tLast $pOther $pEmpty $pHelp $pQuit; do
		case $tValue in
			CLEAR)	gLastPrompt="";;
			QUIT)	fCleanUp;;
			HELP)
				echo
				echo -n "$gConfHelp"
				echo
				if [ -n "$pEmpty" ]; then
					echo "NONE - set the value to nothing"
				fi
				if [ -n "$pQuit" ]; then
				     	echo "QUIT - exit now and do nothing"
				fi
				echo
			;;
			DONE)	break;;
			*)
				if [ "${gLastPrompt#*|$tValue}" = "$gLastPrompt" ]; then
					gLastPrompt="${gLastPrompt}|$tValue"
				fi
			;;
		esac
		echo Current value: ${gLastPrompt#|}
		echo
	done

	gLastPrompt="${gLastPrompt##|}"
	gLastPrompt="${gLastPrompt##|}"
} # fConfPromptList

# --------------------------------
function fConfPromptYN
{
	# Select one value from pName list from the list of git config files.
	#
	# Usage:
	#    fConfPrompt -p "pPrompt" [-e] [-o "pOther"] [-h] \
	#        -c pCategory [-s pSection] -n pName [-f pConf]* pConf* 
	# Args:
	#    -p pPrompt
	#    -e - can have Empty value
	#    -o pOther - other options
	#    -h - help can be found in var gConfHelp variable
	#    -c pCategory - Override gConfCategory (no dots in name)
	#    -s pSection - Override gConfSection (can be blank) (no dots in name)
	#    -n pName - ini variable name including section (no dots in name)
	#    -f pConf - ShortName:FullPath (zero or more -f options)
	#    pConf - zero or more config files.  Add -f list
	#
	# Return:
	#    gLastPrompt

	export gConfCategory=${gConfSection:-user}
	export gConfSection
	export gLastPrompt
	
	local pConf=""
	local pPromp="Select? "
	local pEmpty=""
	local pOther=""
	local pHelp=""
	local pQuit=""
	local pCategory="$gConfCategory"
	if [ -n "$gConfSection" ]; then
		local pSection=".$gConfSection"
	else
		local pSection=""
	fi
	local pName=""

	local OPTIND
	local tArg
	local c
	local i
	local tLast
	local tShort
	local tPath
	local tList=""
	local tStr=""
	local tValue=""

	while getopts c:s:n:f:p:eho:q tArg; do
		case $tArg in
			c)	pCategory="${OPTARG}";;
			s)	pSection="-s ${OPTARG}";;
			n)	pName="${OPTARG}";;
			f)	pConf="$pConf ${OPTARG}";;
			p)	pPrompt="${OPTARG}";;
			e)	pEmpty="NONE";;
			o)	pOther="${OPTARG}";;
			h)	pHelp="HELP";;
			q)	pQuit="QUIT";;
			:)	fError -m "fConfPromptYN missing value for: $tArg" -l $LINENO -e 9812;;
			\?)	fError -m "fConfPromptYN unknown option: $tArg" -l $LINENO -e 9813;;
		esac
	done
	shift $((OPTIND-1))
	if [ $# -ne 0 ]; then
		pConf="$pConf $*"
	fi

	# Required parms (quit if missing?)
	#pCategory
	#pName
	#pConf
	# TBD
	
	fConfGet -m -u -c $pCategory $pSection -n $pName $pConf

	# Prepare
	tLast=""
	for i in $gLastGet; do
		if [ "${i#*[01]}" != "$i" ]; then
			tLast="$tLast $i"
		else
			fLog -m "$pName=$i, is not 0 or 1" -p warning -e 9814
		fi
	done

	export PS3="$pPrompt "
	echo
	select tValue in $tLast $pOther $pEmpty $pHelp $pQuit; do
		case $tValue in
			QUIT)	fCleanUp;;
			HELP)
				echo
				echo -n "$gConfHelp"
				echo
				if [ -n "$pEmpty" ]; then
					echo "NONE - set the value to nothing"
				fi
				if [ -n "$pQuit" ]; then
				     	echo "QUIT - exit now and do nothing"
				fi
				echo
			;;
			NONE)	tValue=""
				break
			;;
			*)	break;;
		esac
	done

	gLastPrompt="$tValue"
} # fConfPromptYN
