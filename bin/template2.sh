#!/bin/bash 
# public_html/template/template2.sh

# Prefix codes (show the "scope" of variables):
# gVar - global variable (may even be external to the script)
# pVar - parameter (function parameter)
# gpVar - global parameter, script option, or defined external to script
# cVar - global constant (set once)
# tVar - temporary variable (local to a function)
# fFun - function

# Commonally used global variables:
# gpDebug - toggle (-x)
# gpVerbose - toggle (-v)
# Tmp - personal tmp directory.  Usually set to: /tmp/$USER
# cTmpF - tmp file prefix.  Includes $Tmp and $$ to make it unique
# gErr - error code (0 = no error)
# cVer - current version
# cName - script's name
# cBin - directory where the script is executing from
# cCurDir - current directory

# --------------------------------
function fCleanUp
{
	trap - 1 2 3 4 5 6 7 8 10 11 12 13 14 15
	# Called when script ends (see trap) to remove temporary files,
	# if not in debug mode.
	if [ ${gpDebug:-0} -eq 0 -a -n "$cTmpF" ]; then
		'rm' -f ${cTmpF}[1-9]*.tmp 2>/dev/null
	fi
	fLog -p notice -m "Done" -l $LINENO -e 9901
	exit ${gErr:-1}
} # fCleanUp


# --------------------------------
function fUsage
{
	# Print usage help for this script, using pod2text.
	pod2text $0

	if [ $# -ne 0 ]; then
		# Don't exit if an arg is passed
		return
	fi
	gErr=1
	fCleanUp
	exit 1
	cat <<EOF >/dev/null
=pod

=head1 NAME

SCRIPTNAME - DESCRIPTION

=head1 SYNOPSIS

	SCRIPTNAME [-o Value] [-h]] [-v]] [-x] 

=head1 DESCRIPTION

[What does the script do?]

=head1 OPTIONS

=over 4

=item B<-h>

This help

=item B<-v>

Verbose output.  And send to stderr.

=item B<-x>

Debug mode.  Don't log to syslog.

=back

=head1 RETURN VALUE

[What the program or function returns if successful.]

=head1 ERRORS

Fatal Error:

Warning:

Many error messages may describe where the error is located, with the
following log message format:

 Program: PID NNNN: Message [LINE](ErrNo)

=head1 EXAMPLES

=head1 ENVIRONMENT

 $HOME
 $USER
 $Tmp

=head1 FILES

=head1 SEE ALSO

"git config"

=head1 NOTES

To test:

 ./template2.sh -s
     should see summary text
 ./template2.sh -h
     should see full help text
 ./template2.sh -e
     should see an error message, and in log: TEST fError
 ./template2.sh -l
     should see a log message, in log: TEST fLog
 ./template2.sh -vl
     should see a log message, in log and stdout: TEST fLog
 ./template2.sh -vxl
     should see a log message, only to stdout: TEST fLog
 ./template2.sh -t fConfSet
     setup various ~/tmp/template2/*.conf files with initial values
 ./template2.sh -t fConfGet
     get the values from the various conf files, and validate
 ./template2.sh -t fConfPrompt
     test prompt.  Select the one suggested, for validate tests


=head1 CAVEATS

[Things to take special care with; sometimes called WARNINGS.]

=head1 DIAGNOSTICS

[All possible messages the program can print out--and what they mean.]

=head1 BUGS

[Things that are broken or just don't work quite right.]

=head1 RESTRICTIONS

[Bugs you don't plan to fix :-)]

=head1 AUTHOR

NAME

=head1 HISTORY

(c) Copyright 2015 by COMPANY

1.0

=cut
EOF
} # fUsage

# --------------------------------
function fTestTemplate
{
	local OPTIND
	local tArg

	export PS3="Run which test (run fConfSet first)? "
	echo
	select tTest in fConfSet fConfGet fConfPromptStr fConfPromptList fConfPromptStrList fConfPromptYN fLog fError Summary HELP QUIT; do
		case $tTest in
			fConfSet)
				break
			;;
			fConfGet)
				break
			;;
			fConfPromptStr)
				break
			;;
			fConfPromptList)
				break
			;;
			fConfPromptStrList)
				break
			;;
			fConfPromptYN)
				break
			;;
			fLog)
				fLog "TEST fLog: from fTestTemplate" -l $LINENO -e 34
				exit 1
			;;
			fError)
				fError -m "TEST fError" -l $LINENO -e 33
			;;
			Summary)
				fSummary noexit
				fSummary
			;;
			HELP)
				fUsage
				break
			;;
			QUIT)
				fCleanUp
				break
			;;
			*)
				fCleanUp
				break
			;;
		esac
	done

	tDir=~/tmp/template2
	mkdir -p $tDir
	case $tTest in

		fConfSet)
			echo "Run fConfSet"
			rm $tDir/[abc].conf 2>/dev/null
			fConfSet -f $tDir/a.conf -c test1 -s foo -n var1 avar1value
			fConfSet -f $tDir/a.conf -c test1 -s foo -n var2 "avar2valueA|avar2valueB"
			fConfSet -f $tDir/a.conf -c test1 -s foo -n var3 avar3value
			fConfSet -f $tDir/a.conf -c test1 -s foo -n varX varXvalue
			fConfSet -f $tDir/a.conf -c test1 -s foo -n var4 0
	
			fConfSet -f $tDir/b.conf -c test1 -s foo -n var1 bvar1value
			fConfSet -f $tDir/b.conf -c test1 -s foo -n var2 "bvar2valueA|bvar2valueB|bvar2valueC|bvar2valueA"
			fConfSet -f $tDir/b.conf -c test1 -s foo -n var4 0
	
			fConfSet -f $tDir/c.conf -c test1 -s foo -n var1 cvar1value
			fConfSet -f $tDir/c.conf -c test1 -s foo -n varX varXvalue
			fConfSet -f $tDir/c.conf -c test1 -s foo -n var4 1
	
			echo "Look at the contents of $tDir/[abc].conf"
	     	;;

     		fConfGet)
			echo "Run fConfGet"
			# ---------
			fConfGet -c test1 -s foo -n var1 -f $tDir/a.conf
			if [ "$gLastGet" != "avar1value" ]; then echo Error1 x${gLastGet}x; fi

			# ---------
			fConfGet -c test1 -s foo -n var2 -f $tDir/a.conf
			if [ "$gLastGet" != "avar2valueA|avar2valueB" ]; then echo Error2 x${gLastGet}x; fi

			# ---------
			fConfGet -c test1 -s foo -n var1 -f $tDir/b.conf
			if [ "$gLastGet" != "bvar1value" ]; then echo Error3 x${gLastGet}x; fi

			# ---------
			fConfGet -c test1 -s foo -n varnone -f $tDir/b.conf
			if [ -n "$gLastGet" ]; then echo Error4 x${gLastGet}x; fi

			# ---------
			fConfGet -c test1 -s foo -n var1 -f $tDir/c.conf
			if [ "$gLastGet" != "cvar1value" ]; then echo Error5 x${gLastGet}x; fi

			# ---------
			fConfGet -c test1 -s foo -n var2 -f c:$tDir/c.conf -f b:$tDir/b.conf -f a:$tDir/a.conf
			if [ "$gLastGet" != "b:bvar2valueA|bvar2valueB|bvar2valueC|bvar2valueA" ]; then echo Error6 x${gLastGet}x; fi

			# ---------
			fConfGet -m -c test1 -s foo -n var1 $tDir/a.conf $tDir/b.conf $tDir/c.conf
			if [ "$gLastGet" != "avar1value bvar1value cvar1value" ]; then echo Error7 x${gLastGet}x; fi

			# ---------
			fConfGet -m -c test1 -s foo -n var1 a:$tDir/a.conf b:$tDir/b.conf c:$tDir/c.conf
			if [ "$gLastGet" != "a:avar1value b:bvar1value c:cvar1value" ]; then echo Error8 x${gLastGet}x; fi

			# ---------
			fConfGet -m -u -c test1 -s foo -n varX a:$tDir/a.conf b:$tDir/b.conf c:$tDir/c.conf
			if [ "$gLastGet" != "a:varXvalue" ]; then echo Error9 x${gLastGet}x; fi

			# ---------
			echo "If no Error output, then OK"
		;;

     		fConfPromptStr)
			echo "Run fConfPromptStr"
			gConfHelp="
Help text.
Example."
			# ---------
			fConfPromptStr -p "Select last: " -eqh -c test1 -s foo -n var2 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			if [ "$gLastPrompt" != "last:avar2valueA|avar2valueB" ]; then echo Error10 x${gLastPrompt}x; fi

			# ---------
			fConfPromptStr -p "Select default: " -eqh -c test1 -s foo -n var1 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			if [ "$gLastPrompt" != "default:bvar1value" ]; then echo Error11 x${gLastPrompt}x; fi

			# ---------
			fConfPromptStr -p "Select sys: " -eqh -c test1 -s foo -n var1 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			if [ "$gLastPrompt" != "sys:cvar1value" ]; then echo Error12 x${gLastPrompt}x; fi

			# ---------
			echo
			echo "If no Error output, then OK"
		;;

		fConfPromptList)
			echo "Test fConfPromptList"
	
			# ---------
			fConfPromptList -p "Select 3,5,2,3,1:" -eqh -c test1 -s foo -n var2 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			if [ "$gLastPrompt" != "bvar2valueA|bvar2valueC|avar2valueB" ]; then echo Error13 x${gLastPrompt}x; fi

			# ---------
			echo
			echo "If no Error output, then OK"
		;;

		fConfPromptStrList)
			# ---------
			echo "Test fConfPromptStrList"

			# ---------
			fConfPromptStrList -p "Select default:" -eqh -c test1 -s foo -n var2 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			#if [ "$gLastPrompt" != "default:bvar2valueA|bvar2valueB|bvar2valueC|bvar2valueA" ]; then echo Error14 x${gLastPrompt}x; fi

			# ---------
			fConfPromptStrList -p "Select LIST, then 3,4,1:" -eqh -c test1 -s foo -n var2 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			if [ "$gLastPrompt" != "avar2valueB|bvar2valueA" ]; then echo Error14 x${gLastPrompt}x; fi

			# ---------
			echo
			echo "If no Error output, then OK"
		;;

		fConfPromptYN)
			# ---------
			# echo "Test fConfPromptYN"

			# ---------
			fConfPromptYN -p "Select 2:" -eqh -c test1 -s foo -n var4 last:$tDir/a.conf default:$tDir/b.conf sys:$tDir/c.conf
			if [ "$gLastPrompt" != "sys:1" ]; then echo Error15 x${gLastPrompt}x; fi
	
			# ---------
			echo
			echo "If no Error output, then OK"
		;;

		*)
			fError -m "Unknown option: $gpT" -l $LINENO -e 50
		;;
	esac

} # fTestTemplate

# ====================================================
# Main

# -------------------
# Set current directory location in PWD and cCurDir, because with cron
# jobs PWD is not set.
if [ -z "$PWD" ]; then
	export PWD=$(pwd)
fi
export cCurDir=$PWD

# -------------------
# Set name of this script
# Note: this does not work if the script is executed with '.'
export cName=${0##*/}

# -------------------
# Define the location of the script
if [ $0 = ${0%/*} ]; then
	cBin=$(which $cName)
	cBin=${cBin%/*}
else
	cBin=${0%/*}
fi
cd $cBin
export cBin=$PWD
cd $cCurDir

# -------------------
# Setup log variables
export gpDebug=${gpDebug:-0}
export gpVerbose=""
export gErr=0
export gLogFacility="user"

# -------------------
# Define the version number for this script
export cVer='$Revision: 1.1 $'
cVer=${cVer#*' '}
cVer=${cVer%' '*}

# -------------------
# Setup a temporary directory for each user.
Tmp=${Tmp:-"/tmp/$USER/$cName"}
if [ ! -d $Tmp ]; then
	mkdir -p $Tmp 2>/dev/null
	if [ ! -d $Tmp ]; then
		fError -m "Could not find directory $Tmp (\$Tmp)." -l $LINENO -e 9902
	fi
fi

# -------------------
trap fCleanUp 1 2 3 4 5 6 7 8 10 11 12 13 14 15

# -------------------
# Configuration
export gConfCategory=${gConfSection:-user}
export gConfSection
export gLastGet
export gLastPrompt
export gConfHelp=""

. $cBin/com-bash-lib.inc

# -------------------
# Get Options Section
export gpA=0
export gpL=""
export gpFileList=""
while getopts hal:vx tArg; do
	case $tArg in
		h)	fUsage;;
		a)	gpA=1;;
		l)	gpL="$OPTARG";;
		v)	gpVerbose="-s";;
		+v)	gpVerbose="";;
		x)	gpDebug=1;;
		+x)	gpDebug=0;;
		:)	fError -m "Value required for option: $OPTARG" -l $LINENO -e 9903;;
		\?)	fError -m "Unknown option: $OPTARG" -l $LINENO -e 9904;;
	esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
	gpFileList="$*"
fi

# -------------------
# Define temporary file names used by this script.  The variables for
# the file names can be any name, but the file name pattern should be:
# "${cTmpF}[0-9]*.tmp"
if [ $gpDebug -eq 0 ]; then
	export cTmpF=${Tmp}/work_${$}_
else
	export cTmpF=${Tmp}/work_
	rm -f ${cTmpF}*.tmp 2>/dev/null
fi
export cTmp1=${cTmpF}1.tmp
export cTmp2=${cTmpF}2.tmp

# -------------------
# Print dump of variables
if [ $gpDebug -ne 0 ]; then
	for i in \
		PWD \
		cBin \
		cCurDir \
		cName \
		cVer \
		gpDebug \
		gpVerbose \
		gErr \
		Tmp \
		cTmp1 \
		cTmp2 \
	; do
		tMsg=$(eval echo -e "$i=\$$i")
		fLog -p debug -m "$tMsg" -e 9905
	done
fi

# -------------------
# Validate Options Section

# -------------------
# Functional Section

fTestTemplate

# -------------------
# Cleanup Section
fCleanUp
