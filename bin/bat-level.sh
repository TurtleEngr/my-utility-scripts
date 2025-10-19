#!/usr/bin/env bash
set -u
export cCache cConf cInFile cLogFile cMax cMaxSay cMin cMinSay
export cOutFile cPlotHours cPlotHeight cPlotWidth cPlotVal cSay

# ========================================
# Functions

# --------------------------------
fUsage() {
    cat <<EOF
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

CronTab
    */10 * * * * $HOME/bin/bat-level.sh -l

    If run once a min for 24 hours 1440 cPlotVal/day
    If run once every 5 min for 24 hours 288 cPlotVal/day
    If run once every 10 min for 24 hours 144 cPlotVal/day

Config
    $cCache - location of the log files
    $cConf - remove to reset to defaults
EOF
    if [[ -r $cConf ]]; then
        cat $cConf
    fi
    exit 1
} # fUsage

# --------------------------------
fConfig() {
    # Defaults

    cMin=16
    cMax=95
    cMinSay="The battery is below ${cMin}%. Plug it in."
    cMaxSay="The battery is above ${cMax}%. Unplug it."
    cSay=/usr/local/bin/say
    if [ ! -x $cSay ]; then
        cSay=~/bin/say
    fi

    cPlotHours=24
    cPlotVal=300
    cPlotWidth=700
    cPlotHeight=400

    cCache=~/.cache/bat-level
    if [ ! -d $cCache ]; then
        mkdir -p $cCache
    fi
    cLogFile=$cCache/bat-level.log
    cInFile=$cCache/bat-level-in.tmp
    cOutFile=$cCache/bat-level-out.tmp

    # Config for this computer
    cConf=~/.config/bat-level-rc
    if [[ -f $cConf ]]; then
        . $cConf
    else
        cat <<EOF >$cConf
cMin=${cMin}
cMax=${cMax}
cMinSay="${cMinSay}"
cMaxSay="${cMaxSay}"
cSay=${cSay}
cPlotHours=${cPlotHours}
cPlotVal=${cPlotVal}
cPlotWidth=${cPlotWidth}
cPlotHeight=${cPlotHeight}
cCache=${cCache}
cLogFile=${cLogFile}
cInFile=${cInFile}
cOutFile=${cOutFile}
EOF
        chmod a+rx $cConf
    fi

    if [ ! -x ]; then
        cSay=/dev/null
    fi
} # fConfig

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
    export tFirst tS tHours
    # For png file output, remove the string "##png"

    # Convert absolute sec to be hours from the first time in the file
    tFirst=$('date' '+%s' --date="now - $cPlotHours hours")
    
    while read tS tV; do
        if [ $tS -lt $tFirst ]; then
            # Only plot times for last $cPlotHours
            continue
        fi
        tS=$(echo "2 k $tS $tFirst - 3600.0 / f" | dc)
        echo $tS $tV
    done <$cLogFile >$cCache/bat-level.tmp

    cat  <<EOF >$cCache/bat-level.plot
set term x11 size $cPlotWidth, $cPlotHeight
set title 'Battery Level'
set xlabel 'Hours'
set ylabel 'Percent'
set yr [0:100]
set ytic 10
set xr [0:$cPlotHours]
set xtic 2
set mxtics 2
set grid xtic ytics mxtics
##png set term png
##png set output '$cCache/bat-level.png'
plot '$cCache/bat-level.tmp' with lines lw 3
#plot '$cCache/bat-level.tmp' with steps lw 3
#plot '$cCache/bat-level.tmp' with linespoint lw 3
EOF

    gnuplot -p $cCache/bat-level.plot
    ##png gnuplot $cCache/bat-level.plot
    ##png eog $cCache/bat-level.png
} # fPlot

# ========================================
# Main

fConfig

# -------------------
# Get Args Section

if [[ $# -eq 0 ]]; then
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
        h) fUsage ;;
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
