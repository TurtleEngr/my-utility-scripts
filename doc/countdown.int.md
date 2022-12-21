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

$Revision: 1.1 $ GMT 

# count Internal Documentation

### fUsage pStyle

This function selects the type of help output. See -h and -H options.

## Script Global Variables

### setUp

This is run before each test function.

### setUp

This is run before each test function.

## Unit Test Functions

### fUDebug "pMsg"

If gpUnitDebug is not 0, then echo $pMsg.

If 

### testLockCounterFile

Test getting lock dir. Multiple tests are in this function, because
the order matters for this tests.

gpVerbose is set in some places, so that the fLog messages will be
output.

## Script Functions

### fCleanUp

Calls fComCleanUp.

### fSetGlobals

Calls fComSetGlobals to set globals used by bash-com.inc.

Set initial values for all of the other globals use by this
script. The ones that begin with "gp" can usually be overridden by
setting them before the script is run.

### fSetGlobals pMin pMax pNum

### fValidArgs E-pEnd m-pMin s-pSec

### fValidStartEnd s-pStart e-pEnd

### fValidDir pFile

### fLockCounterFile pLockDir pFile

### fGetCount pEndTime

The aguments are not validated, because it is expected they were
validated before this function is called.

### fOutput pSec pFmt pFile

### fSetEndTime S-pStart E-pEnd m-pMin s-pSec

### fRunCounter pEndTime pFile pFmt pInt

### fRunTests

Run unit tests for this script.

Note: if the system is "busy" the test times could be off by one
second. Either wait for the system to not be busy, or implement a
"mockDate" function to make the times constent for the tests.

<div>
    <hr/>
</div>

# bash-com.inc Internal Documentation

## Template Use

### Configuration

    * Copy template.sh to your script file.
    * Your script, bash-com.inc, and bash-com.test need to be in the same directory.
    * Globally replace SCRIPTNAME with the name of your script file.
    * Update the getopts in the "Get Args Section". Add your script's options.
    * Loop: document (with POD), add tests, add validate functions
    * Loop: add unit test function, add functions, test

### Block Organization

    * Configuration - exit if errors
    * Get Args - exit if errors
    * Verify external progs - exit if errors
    * Run tests - if gpTest is set
    * Validate Args - exit if errors
    * Verify connections work - exit if errors
    * Read-only functional work - exit if errors
    * Write functional work - now you are committed! Try to keep going if errors
    * Output results and/or launch next process

To avoid a lot of rework and manual rollbacks, put-off _writes_ that
cannot undone. Do as much as possible to make sure the script will be able
to complete write operations.

For example, **do not do this:** collect information, transform it,
write it to a DB, then start the next process on another server.
Whoops, that server cannot be accessed, so the DB update is not valid!
Gee, why didn't you verify all the connections you will need, before
committing to the DB?!  Even if you did check, the connection could
have failed after the check, so maybe write to a tmp DB, then when all
is OK, then update the master DB with the tmp DB changes.

Where ever possible make your scripts "re-entrant". Connections can
fail at anytime and scripts can be killed at anytime; How can any
important work be continued or work rolled-back? Planing for
"failures" is NOT planning to fail; it is what a professional engineer
does to design in quality.

### Variable Naming Convention

Prefix codes are used to show the **"scope"** of variables:

    gVar - global variable (may even be external to the script)
    pVar - a function parameter I<local>
    gpVar - global parameter, i.e. may be defined external to the script
    cVar - global constant (set once)
    tVar - temporary variable (usually I<local> to a function)
    fFun - function

All UPPERCASE variables are _only_ used when they are required by other
programs or scripts.

If you have exported variables that are shared across scritps, then
this convention can be extended by using prefixes that are related to
where the variables are set.

### Global Variables

For more help, see the Globals section in fUsage.

    gpLog - -l
    gpVerbose - -v, -vv
    gpDebug - -x, -xx, ...
    gpTest - -t
    Tmp - personal tmp directory.  Usually set to: /tmp/$USER
    cTmpF - tmp file prefix.  Includes $$ to make it unique
    cTmp1 - a temp file with a pattern that fCleanUp will remove
    gErr - error code (0 = no error)
    cName - script's name taken from $0
    cCurDir - current directory
    cBin - directory where the script is executing from
    cVer - current version. For example, if using CVS:
           # shellcheck disable=SC2016
           cVer='$Revision: 1.1 $'

### Documentation Format

POD is use to format the script's documentation. Sure MarkDown could
have been used, but it didn't exist 20 years ago. POD text can be
output as text, man, html, pdf, texi, just usage, and even MarkDown

Help for POD can be found at:
[perlpod - the Plain Old Documentation format](https://perldoc.perl.org/perlpod)

The documentation is embedded in the script so that it is more likely
to be updated. Separate doc files seem to _always_ drift from the
code. Feel free to delete any documentation, if the code is clear
enough.  BUT _clean up your code_ so that the code _really_ is
clear.

The internal documentation uses POD commands that begin with "=internal-".
See fComInternalDoc() for how this is used.

Also TDD (Test Driven Development) should make refactoring easy,
because the tests are often embedded in the script. See template.sh
for how.

## Common Script Functions

### fComSetGlobals

Set initial values for all of the globals use by this script. The ones
that begin with "gp" can usually be overridden by setting them before
the script is run.

### fCleanUp

Called when script ends (see trap) to remove temporary files.
Except if gpDebug != 0, then tmp files are not removed.

### fComCheckDeps "pRequired List" "pOptional List"

Check for required and optional programs or scripts used by this script.
If any required programs are missing, exit the script.

### fComInternalDoc \[-a\]

This function collects all of the "internal-pod" documentation from
stdin and it outputs to stdout.

If -a option is givein, then ALL pod documentation is output.

### fComUsage -f pFileList -s pStyle \[-t pTitle\] \[-i\] \[-a\]

- **-f pFileList** - list of file names
- **-s pStyle** - output style

        short|usage - usage only (does not work with -i or -a)
        man         - all, man format (does not work with -i or -a)
        long|text   - all text format
        html        - all, html format (see -t)
        md          - all, markdown format

- **-t** - title for HTML style
- **-i** - internal doc only (see fComInternalDoc)
- **-a** - all docs: user and internal (see fComInternalDoc)

### fFmtLog pLevel "pMsg" pLine pErr

This function formats and outputs a consistent log message output.
See: fLog, fLog2, fError, and fError2.

### fLog pLevel "pMsg" \[$LINENO\] \[pErr\]

pLevel - emerg alert crit err warning notice info debug debug-N

See Globals: gpLog, gpFacility, gpVerbose, gpDebug

#### fLog Examples:

    fLog warning "Missing awk" $LINENO 8
    fLog notice "Output only if -v" $LINENO 8
    fLog info "Output only if -vv" $LINENO 8
    fLog debug "Output only if $gpDebug > 0" $LINENO
    fLog debug-3 "Output only if $gpDebug > 0 and $gpDebug <= 3" $LINENO
    

### fError "pMsg" \[$LINENO\] \[pErr\]

This will call: fLog crit "pMsg" pLine pErr

Then it will call "fUsage short", which will exit after fCleanUp.

### fLog2 -m pMsg \[-p pLevel\] \[-l $LINENO\] \[-e pErr\]

This is like fLog, but the arguments can be in any order.

See fLog. See also global gpFacility

### fError2 -m pMsg \[-l $LINENO\] \[-e pErr\] \[-i\]

This will call: fLog2 -p crit -m "pMsg" -l pLine -e pErr

If no -i, then "fUsage short", will be called.

### fTimeoutFunction pSec "pCmd \[args...\]"

Algorithm idea came from:

https://stackoverflow.com/questions/9954794/execute-a-shell-function-with-timeout

# bash-com.test

## bash-com.test Usage

# NAME

bash-com.test - test the bash-com.inc functions

# SYNOPSIS

        bash-com.test [testName,testName,...]

# DESCRIPTION

shunit2.1 is used to run the unit tests. If no test function names are
listed, then all of the test functions will be run.

# RETURN VALUE

0 - if OK

# ERRORS

Look for the assert errors.

# EXAMPLES

# ENVIRONMENT

# FILES

# SEE ALSO

shunit2.1

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

# RESTRICTIONS

# AUTHOR

# HISTORY

$Revision: 1.1 $ $Date: 2022/12/20 01:57:33 $ GMT 

## Test bash-com.inc

### oneTimeSetuUp

Currently this records all of the script's expected initial global
variable settings, defined in fComSetGlobals. If different, adjust the
tests as needed.

Calls:

    $cBin/bash-com.inc
    fComSetGlobals

### setUp

Before each test runs, this restores all of the script's initial
global variable settings,

### testInitialConfig

Verify all of the global variables are correctly defined. Look for
"ADJUST" comment for tests that might need to be changed for your
script.

### testLog

Test fLog and fLog2.

### testSysLog

Test fLog and fLog2, and verify messages are in a syslog file.

### testErrorLog

Test fError and fError2.

### testComCleanUp

Test fComCleanUp. Verify the tmp files are removed.

### testComUsage

Test fComUsage. Verify the different output styles work.

### testComFunctions

Just verify these functions exist and run.

Calls:

    fComCheckDeps
    fComSetGlobals

### fComRunTests

Run unit tests for the common functions.