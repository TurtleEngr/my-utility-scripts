<div>
    <hr/>
</div>

# NAME section-count

SHORT-DESCRIPTION

# SYNOPSIS

        section-count -f FileName [-h] [-H pStyle] [-l] [-v] [-x] [-T pTest]

# DESCRIPTION

Output the word count for each of an org-mode file. The counts are
cumulitive for heading levels one to four.

The heading levels will be reordered to be after the headings under
them.

# OPTIONS

- **-f FileName**

    Name of the the org file to be processed. Required option.

- **-h**

    Output this "long" usage help. See "-H long"

- **-H pStyle**

    pStyle is used to select the type of help and how it is formatted.

    Styles:

        short|usage - Output short usage help as text.
        long|text   - Output long usage help as text.
        man         - Output long usage help as a man page.
        html        - Output long usage help as html.
        md          - Output long usage help as markdown.

- **-l**

    Send log messages to syslog. Default is to just send output to stderr.

- **-v**

    Currently there is no verbose text.

    Verbose output. Default is is only output (or log) messages with
    level "warning" and higher.

    \-v - output "notice" and higher.

    \-vv - output "info" and higher.

- **-x**

    Currently there is no debug output.

    Set the gpDebug level. Add 1 for each -x.
    Or you can set gpDebug before running the script.

    See: fLog and fLog2 (Internal documentation)

- **-T "pTest"**

    Run the unit test functions in this script.

    "**-T all**" will run all of the functions that begin with "test".

    "**-T list**" will list all of the test functions.

    "**-T com**" will run all the tests for bash-com.inc

    Otherwise, "**pTest**" should match the test function names separated
    with spaces (between quotes).

    For more help, use the "-H int" option.

    For more details about shunit2 (or shunit2.1), see
    shunit2/shunit2-manual.html [Source](https://github.com/kward/shunit2)

    shunit2.1 has a minor change that defaults to the no-color option.

## Globals

These are globals that may affect how the script runs. Just about all
of these globals that begin with "gp" can be set and exported before
the script is run. That way you can set your own defaults, by putting
them in your ~/.bashrc or ~/.bash\_profile files.

The the "common" CLI flags will override the initial variable settings.

- **Tmp**

    This is the top directory where tmp files will be put.

    Default: /tmp/$USER/section-count/

    if gpDebug is 0, temp files will usually include the PID.

- **gpLog**

    If set to 0, log messages will only be sent to stderr.

    If set to 1, log messages will be sent to stderr and syslog.

    See -l, fLog and fErr for details

    Default: 0

- **gpFacility**

    Log messages sent to syslog will be sent to the "facility" specified
    by by gpFacility.

    "user" log messages will be sent to /var/log/user.log, or
    /var/log/syslog, or /var/log/messages.log

    See: fLog

    Default: user

    Allowed facility names:

        local0 through local7 - local system facilities
        user - misc scripts, generic user-level messages
        auth - security/authorization messages
        authpriv - security/authorization messages (private)
        cron - clock daemon (cron and at)
        daemon - system daemons without separate facility value
        ftp - ftp daemon
        kern - kernel  messages  (these  can't be generated from user processes)
        lpr - line printer subsystem
        mail - mail subsystem
        news - USENET news subsystem
        syslog - messages generated internally by syslogd(8)
        uucp - UUCP subsystem

    These are some suggested uses for the localN facilities:

        local0 - system or application configuration
        local1 - application processes
        local2 - web site errors
        local3 - web site access
        local4 - backend processes
        local5 - publishing
        local6 - available
        local7 - available

- **gpVerbose**

    If set to 0, only log message at "warning" level and above will be output.

    If set to 1, all non-debug messages will be output.

    See -v, fLog

    Default: 0

- **gpDebug**

    If set to 0, all "debug" and "debug-N" level messages will be skipped.

    If not 0, all "debug" level messages will be output.

    Or if "debug-N" level is used, then if gpDebug is <= N, then the
    log message will be output, otherwise it is skipped.

    See -x

# RETURN VALUE

\[What the program or function returns if successful.\]

# ERRORS

Fatal Error: no options

Fatal Error: no -f

Fatal Error: File not readable

Many error messages may describe where the error is located, with the
following log message format:

    Program: PID NNNN: Message [LINE](ErrNo)

# ENVIRONMENT

See Globals section for details.

HOME, USER, Tmp, gpLog, gpFacility, gpVerbose, gpDebug

# SEE ALSO

shunit2.1
bash-com.inc
bash-com.test

# CAVEATS

## To Do

Put tmp files in $Tmp.

# BUGS

Because of a defect, the -T option will only work if the script is in
the ~/bin directory.

Workaround: put a symlink in ~/bin to this script. Then call the
script from ~/bin.

# HISTORY

GPLv2 (c) Copyright 2024

$Revision: 1.2 $ $Date: 2024/08/17 19:57:20 $ GMT
