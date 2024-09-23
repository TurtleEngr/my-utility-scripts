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
           cVer='$Revision: 1.6 $'

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
