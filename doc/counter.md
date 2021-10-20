# NAME

counter - manage a count up or count down timer for OBS

# SYNOPSIS

        counter [-m Min | -s Sec | -t Time [-T Time]] [-u|-d] [-p] [-i Sec]
                [-f File] [-S "Start"] [-E "End"] [-h]

# DESCRIPTION

Use -m and -s to set the duration for the timer. Or use -t to set the
end time (which is assumed to be in the future, if -T is not defined)
and the duration will be calculated.

Use -u to define a count up timer. Use -d to define a count down timer.

Use -i to define the interval, in seconds.

Only one version of counter can write to File. So there is a check to
see is a counter is already running for the specified file. If yes,
then that counter process is killed, and the file will be used by the
new counter.  This is done so that a counter can be run in the
background. If put in the background, don't use the -p option.

# OPTIONS

- **-m Min**

    Number of minutes. Default: 0

- **-s Sec**

    Number of seconds. Default: 60

- **-t Time**

    Set the hour, minute time from now. The counter's duration will be set
    to number of min:sec until that time. The hour HH must use 24 hour time,
    or add AM/PM to the time.

    \-t will override -m and -s settings.

    See Example section.

- **-T Time**

    The start time of the -t calculation can be defined. The default is "now".

    See Example section.

- **-u**

    Start a 0 and count up until greater or equal to Min:Sec.

- **-d**

    Start a Min:Sec and count down until 0.

    Default.

- **-p**

    Pause at Start and prompt before starting.  Default: no pause.

- **-i Sec**

    Interval in sec. Default: 1

- **-f File**

    File location for the counter. Default: /tmp/counter.tmp

- **-S "Start"**

    Start text. Default: if -d: Min:Sec, if -u: 0:0

- **-E "End"**

    End text. Default: if -d: 0:00, if -u: Min:Sec

- **-h**

    This help.

# RETURN VALUE

# ERRORS

Fatal Error: Bad arguments.

Warnings: Another counter was running, it will be stopped.

# EXAMPLES

To use the counter, point OBS text to read from the counter file
/tmp/counter.tmp or from the file specified with the -f option.

Countdown timer for 2min 13sec. File /tmp/counter.tmp will be use for
time remaining.

        counter -m 2 -s 13

Countup timer for 2min 13sec, but wait for user to press Enter to
start it. And first display "Time until Program". At end, display
"Starting".

        counter -u -m 2 -s 13 -p -S "Time until Program" -E "Starting"

Start a counter in background for 15 min. The start 
a replacement counter time for 2 min, before the first one
finishes.  When the second counter starts, any running counters using file
/tmp/counter.tmp will die, before the other counter starts.

        counter -m 15 -s 0 &
        sleep 60
        counter -m 2 -s 0 &

If you need to have two counters running at the same time, use two
different counter files.

        counter -m 15 -s 0 -f /tmp/counter1.tmp &
        counter -m 2  -s 0 -f /tmp/counter2.tmp &

Start countdown timer to end at 11am.

        counter -t '2020-12-06 11am'

Countdown timer, duration is calculated between the two times
specified.  To test what dates values are allowed, use the "date
\--date='time'" command.

        counter -T '2020-12-06 11am - 7min - 62sec' -t '2020-12-06 11am'

# ENVIRONMENT

# FILES

    /tmp/counter.tmp

# SEE ALSO

date

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

# RESTRICTIONS

# AUTHOR

# HISTORY

$Revision: 1.2 $ GMT 
