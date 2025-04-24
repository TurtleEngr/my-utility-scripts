#!/usr/bin/env bash
set -u

# ========================================
# Config

export cMin=${cMin:-16}
export cMax=${cMax:-95}
export cMinSay=${cMinSay:-"The battery is below ${cMin}%. Plug it in."}
export cMaxSay=${cMaxSay:-"The battery is above ${cMax}%. Unplug it."}
export cSay=${cSay:-/usr/local/bin/say}

# If run once a min for 24 hours 1440 vals/day
# If run once every 5 min for 24 hours 288 vals/day
export cPlotVal=288

export Tmp=${Tmp:-~/tmp}

export cLogFile=${cLogFile:-$Tmp/bat-level.log}
export cInFile=${cInFile:-$Tmp/bat-level-in.tmp}
export cOutFile=${cOutFile:-$Tmp/bat-level-out.tmp}

export cConf=~/.config/bat-level-rc
if [[ -f $cConf ]]; then
    . $cConf
else
    cat <<EOF >$cConf
cMin=${cMin}
cMax=${cMax}
cMinSay="${cMinSay}"
cMaxSay="${cMaxSay}"
cSay=/usr/local/bin/say
cPlotVal=288
Tmp=${Tmp:-~/tmp}
cLogFile=${cLogFile}
cInFile=${cInFile}
cOutFile=${cOutFile}
EOF
    chmod a+rx $cConf
fi

# ========================================
# Functions

# --------------------------------
fUsage() {
    cat <<\EOF
bat-level.sh - Report battery levels
Usage
    bat-level.sh [-s] [-f] [-l] [-c] [-p] [-h]
Options
    -s short report
    -f full report
    -l log values to $cLogFile
    -c output crontab file line needed to run once every 5 min.
       Adjust as needed.
    -p plot the values in $cLogFile
    -h this help
Config
    ~/.config/bat-level-rc - remove to reset to defaults
EOF
    if [[ -r $cConf ]]; then
        cat $cConf
    fi
    exit 1
} # fUsage

# --------------------------------
fFull() {
    inxi -Bx
} # fFull

# --------------------------------
fShort() {
    tL=$(cat /sys/class/power_supply/BAT0/capacity)
    echo "$tL%"
} # fShort

# --------------------------------
fLog() {
    # Save time, battery %, status
    tD=$('date' '+%s')
    tL=$(cat /sys/class/power_supply/BAT0/capacity)
    tS=$(cat /sys/class/power_supply/BAT0/status)
    echo $tD $tL  >>$cLogFile
    
    # Trim file
    tCur=$(wc -l < $cLogFile)
    if [[ $tCur -gt $cPlotVal ]]; then
        tDel=$((tCur - cPlotVal))
        sed -i "1,${tDel}d" $cLogFile
    fi
    
    # Give one warning to plug-in or unplug
    tPlugIn=0
    tUnplug=0
    if [[ -f $cInFile ]]; then
        tPlugIn=1
    fi
    if [[ -f $cOutFile ]]; then
        tUnplug=1
    fi
    if [[ $tL -le $cMin && "$tS" = "Discharging" && $tPlugIn -eq 0 ]]; then
        wall "$HOSTNAME's battery is at $tL%. Plug it in."
        touch $cInFile
        rm $cOutFile >/dev/null 2>&1
        if [[ -x $cSay ]]; then
            $cSay "$HOSTNAME's battery is low."
        fi
    fi
    if [[ $tL -ge $cMax && "$tS" = "Charging" && $tUnplug -eq 0 ]]; then
        wall "$HOSTNAME's Battery is at $tL%. Unplug it."
        touch $cOutFile
        rm $cInFile >/dev/null 2>&1
        if [[ -x $cSay ]]; then
            $cSay "$HOSTNAME's battery is at $tL%."
        fi
    fi
    if [[ $tL -gt $cMin && $tL -lt $cMax ]]; then
        rm $cInFile $cOutFile >/dev/null 2>&1
    fi
} # fLog

# --------------------------------
fCron() {
    echo "# Min Hour day month week cmd"
    # Run every 5 min
    echo "   */5 * * * * $HOME/bin/bat-level.sh -l"
} # fCron

# --------------------------------
fPlot() {
    # For png file output, remove this scring "##png"

    # Convert absolute sec to be minutes from the first time in the file
    tFirst=$(head -n 1 $cLogFile)
    tFirst=${tFirst% *}
#    tLast=$(tail -n 1 $cLogFile)
#    tLast=${tLast% *}
    while read tS tV; do
        tS=$((tS - tFirst))
        tS=$((tS / 60))
        echo $tS $tV
    done <$cLogFile >/var/tmp/bat-level.tmp

    cat  <<EOF >/var/tmp/bat-level.plot
set term x11 size 1000, 400
set title 'Battery Level'
set xlabel 'Minutes'
set ylabel 'Percent'
set yr [0:100]
set ytic 10
set xtic 240
set mxtics 4
set grid xtic ytics mxtics
#plot '/var/tmp/bat-level.tmp' with linespoint
##png set term png
##png set output '/var/tmp/bat-level.png'
#plot '/var/tmp/bat-level.tmp' with lines lw 3
plot '/var/tmp/bat-level.tmp' with steps lw 3
EOF

    gnuplot -p /var/tmp/bat-level.plot
    ##png gnuplot /var/tmp/bat-level.plot
    ##png eog /var/tmp/bat-level.png
} # fPlot

# ========================================
# Main

if [[ ! -d Tmp ]]; then
    mkdir -p $Tmp
fi

# -------------------
# Get Args Section

if [[ $# -eq 0 ]]; then
    fShort
    fLog
    echo
    fUsage
fi

while getopts :cflsph tArg; do
    case $tArg in
        # Script arguments
        c) fCron ;;
        f) fFull ;;
        l) fLog ;;
        p) fPlot ;;
        s) fShort ;;
        # Common arguments
        h)
            fUsage
            ;;
        # Problem arguments
        :) echo "Value required for option: -$OPTARG"
           exit 1
        ;;
        \?) echo "Unknown option: $OPTARG"
            exit 1
        ;;
    esac
done
((--OPTIND))
shift $OPTIND
if [[ $# -ne 0 ]]; then
    echo "Unknown option: $*"
    exit 1
fi

exit 0
