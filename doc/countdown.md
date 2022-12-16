# NAME

counter - manage a count up or count down timer for OBS

# SYNOPSIS

           countdown [-m Min | -s Sec | -E Time [-S Time]] [-i Sec] [-F Format]
                   [-f File] [-h] [-H Style] [-l] [-v] [-x] [-T "TestList"]

           Format: S|M|H
           Style: usage, long, man, html, md, int, int-html, int-md
    

# DESCRIPTION

Use -m and -s to set the duration for the timer. Or use -E to set the
end time. -E time is assumed to be in the future, or a time greater
than -S.

Only one version of counter can write to File. So there is a check to
see if a counter is already running for the specified file. If yes,
then that counter process is killed, and the File will be used by the
new counter.  This is done so that a counter can be run in the
background.

# OPTIONS

- **-m Min**

    Number of minutes. Default: 0

- **-s Sec**

    Number of seconds. Default: 60

- **-E Time**

    Set the hour, minute time from now. The counter's duration will be set
    to number of min:sec until that time. The hour HH must use 24 hour time,
    or add AM/PM to the time. The Time can be any time that is a valid input
    to the "date" command (i.e. the --date option).

    Setting -E will override any -m and -s settings.

    If there is no -S start time, then the counter will end at exactly at
    the -E time.

    See Example section.

- **-S Time**

    The start time of the -E calculation can be defined. The default is "now".

    If -S is given, then the number of seconds between -S and -E
    date/times will be use to set the -s option (-m will be 0). Then that
    will be used to define an internal end time, and the counter will
    count down to that time.

    See Example section.

- **-i Sec**

    Interval in seconds. Default: 1

- **-F Format**

    Format for the counter. Default: M

        S - SS
        M - MM:SS
        H - HH:MM:SS

- **-f File**

    File location for the counter. Default: /tmp/counter.tmp

- **-h**

    Output this "long" usage help. See "-H long"

- **-H Style**

    Style is used to select the type of help and how it is formatted.

    Styles:

            short|usage - Output short usage help as text.
            long|text   - Output long usage help as text.
            man         - Output long usage help as a man page.
            html        - Output long usage help as html.
            md          - Output long usage help as markdown.
            int         - Also output internal documentation as text.
            int-html    - Also output internal documentation as html.
            int-md      - Also output internal documentation as markdown.

- **-l**

    Send log messages to syslog. Default is to just send output to stderr.

- **-v**

    Verbose output. Default is is only output (or log) messages with
    level "warning" and higher.

    \-v - output "notice" and higher.

    \-vv - output "info" and higher.

- **-x**

    Set the gpDebug level. Add 1 for each -x.
    Or you can set gpDebug before running the script.

    See: fLog and fLog2 (Internal documentation)

- **-T "TestList"**

    Run the unit test functions in this script.

    If TestList is "all", then all of the functions that begin with "test"
    will be run. Otherwise "Test" should match the test function names
    separated with spaces.

    If TestList is "com", then $cBin/bash-com.test will be run to test the
    bash-com.inc functions.

    For more details about shunit2 (or shunit2.1), see
    shunit2/shunit2-manual.html
    [Source](https://github.com/kward/shunit2)

    See shunit2, shunit2.1, bash-com.inc, and global: gpUnitDebug

    Also for more help, use the "-H int" option.

# RETURN VALUE

# ERRORS

Fatal Error: Bad arguments.

Warnings: Another counter was running, it will be stopped.

# EXAMPLES

To use countdown, point OBS text to read from the counter file
/tmp/counter.tmp or from the file specified with the -f option.

Countdown timer for 2min 13sec. File /tmp/counter.tmp will be use for
time remaining.

        countdown -m 2 -s 13

Start a counter in background for 15 min. The start 
a replacement countdown time for 2 min, before the first one
finishes.  When the second countdown starts, any running countdowns using file
/tmp/counter.tmp will die, before the other countdown starts.

        countdown -m 15 -s 0 &
        sleep 60
        countdown -m 2 -s 0 &

If you need to have two countdowns running at the same time, use two
different countdown files.

        countdown -m 15 -s 0 -f /tmp/counter1.tmp &
        countdown -m 2  -s 0 -f /tmp/counter2.tmp &

Start countdown timer to end at 2pm.

        countdown -E 2pm
        countdown -E 14:00

Note: if -S is not set, and the current time is past 2pm, then the
end time will be "tomorrow 2pm"

Start countdown timer to end at 11am on 2020-12-06.

        countdown -E '2020-12-06 11am'

Countdown timer. The duration is calculated between the two times
specified.  To test what dates values are allowed, use the "date
\--date='time'" command.

        countdown -S '2020-12-06 11am - 7min - 62sec' -E '2020-12-06 11am'

Get documentation in different formats:

        countdown -H html >countdown.html
        countdown -H int-html >countdown-internal.html

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

$Revision: 1.6 $ GMT 
