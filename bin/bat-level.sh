#!/usr/bin/env bash
set -u

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
    -l log values to /var/tmp/bat-level.log
    -c output crontab file line needed to run once every 5 min. Adjust as needed.
    -p plot the values in /var/tmp/bat-level.log
    -h this help
EOF
    exit 1
} # fUsage

# --------------------------------
fFull() {
    inxi -Bx
    exit 0
} # fFull

# --------------------------------
fShort() {
    tL=$(cat /sys/class/power_supply/BAT0/capacity)
    echo "$tL%"
    exit 0
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
    if [[ $tCur -gt $cMaxVal ]]; then
        tDel=$((tCur - cMaxVal))
        sed -i "1,${tDel}d" $cLogFile
    fi
    
    # Warning
    if [[ $tL -le 25 && "$tS" = "Discharging" ]]; then
        wall "Battery is at $tL%. Plug it in."
    fi
    if [[ $tL -ge 85 && "$tS" = "Charging" ]]; then
        wall "Battery is at $tL%. Unplug it."
    fi
    exit 0
} # fLog

# --------------------------------
fCron() {
    echo "# Min Hour day month week cmd"
    # Run every 5 min
    echo "   */5 * * * * $HOME/bin/bat-level.sh -l"
    exit 0
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
    exit 0
} # fPlot

# ========================================
# Main

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fUsage
fi

# If run once a min for 24 hours 1440
# If run once every 5 min for 24 hours 288
export cMaxVal=288
export cLogFile=/var/tmp/bat-level.log

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
            exit 1
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
if [ $# -ne 0 ]; then
    gpList="$*"
fi
while [ $# -ne 0 ]; do
    shift
done

# --------------------
# Functional section
