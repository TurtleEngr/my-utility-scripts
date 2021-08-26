# SCRIPTNAME Internal Documentation

## Template Use

\* Copy template.sh to your script file.

\* Globally replace SCRIPTNAME to the name of your script file.

\* Update the getopts in the Get Args Section

\* Loop: document args (with POD), add tests, add validate function

\* Loop: add function tests, add functions

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

To avoid a lot of rework or and manual rollbacks, put-off _writes_ that
cannot undone. Do as much as possible to make sure the script will be able
to complete write operations.

For example, **do not do this:** collect information, transform it,
write it to a DB, then start the next process on another
server. Whoops, that server cannot be accessed! Gee, why didn't you
verify all the connections you will need, before committing to the
DB?!  Even if you did check the connection could fail after the check,
so maybe write to a tmp DB, then when all is OK, update the master DB
with the tmp DB changes.

Where ever possible make your scripts "re-entrant". Connections can
fail at anytime and scripts can be killed at anytime; How it any
important work continued or work reverted?

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
    cVer - current version

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
See fInternalDoc() for how this is used.

Also TDD (Test Driven Development) should make refactoring easy,
because the tests are also embedded in the script.

## Unit Test Functions

### oneTimeSetuUp

Currently this records all of the script's expected initial global
variable settings, defined in fSetGlobals. If different, adjust the
tests as needed.

### oneTimeSetuUp

Before each test runs, this restores all of the script's initial
global variable settings,

### testInitialConfig

Verify all of the global variables are correctly defined.

### testLog

Test fLog and fLog2.

### testSysLog

Test fLog and fLog2, and verify messages are in a syslog file.

### testErrorLog

Test fError and fError2.

### testCleanUp

Test fCleanUp. Verify the tmp files are removed.

### testUsage

Test fUsage. Verify the different output styles work.

### testComFunctions

Just verify these functions exist.

### testScriptFunctions

This is just a starting point for creating script functionality tests.

## Common Script Functions

### fCleanUp

Called when script ends (see trap) to remove temporary files.
Except if gpDebug != 0, then tmp files are not removed.

### fInternalDoc

This function collects all of the "pod-internal" documentation.

### fUsage pStyle

This function selects the type of help output. See -h and -H options.

### fFmtLog pLevel "pMsg" pLine pErr

This function formats and outputs a consistent log message output.
See: fLog, fLog2, fError, and fError2.

### fLog pLevel "pMsg" \[$LINENO\] \[pErr\] \[extra text...\]

pLevel - emerg alert crit err warning notice info debug debug-N

See Globals: gpLog, gpFacility, gpVerbose, gpDebug

#### fLog Examples:

    fLog notice "Just testing" $LINENO 8 "added to msg"
    fLog debug "Output only if $gpDebug>0" $LINENO
    fLog debug-3 "Output only if $gpDebug>0 and $gpDebug<=3" $LINENO
    

### fError "pMsg" \[$LINENO\] \[pErr\]

This will call: fLog crit "pMsg" pLine pErr

Then it will call "fUsage short", which will exit after fCleanUp.

### fLog2 -m pMsg \[-p pLevel\] \[-l $LINENO\] \[-e pErr\] \[extra...\]

This is like fLog, but the arguments can be in any order.

See fLog. See also global gpFacility

### fError2 -m pMsg \[-l $LINENO\] \[-e pErr\]

This will call: fLog2 -p crit -m "pMsg" -l pLine -e pErr

Then it will call "fUsage short", which will exit after fCleanUp.

### fCheckDeps "pRequired List" "pOptional List"

Check for required and optional programs or scripts used by this script.
If any required programs are missing, exit the script.

### fSetComGlobals

Set initial values for all of the globals use by this script. The ones
that begin with "gp" can usually be overridden by setting them before
the script is run.

## Script Functions

### fSetGlobals

Set initial values for all of the globals use by this script. The ones
that begin with "gp" can usually be overridden by setting them before
the script is run.

### fValidateHostName

Exit if missing.
