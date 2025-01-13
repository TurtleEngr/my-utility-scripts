<div>
    <hr/>
</div>

# NAME $cName

Replace "systemctl" calls with "service" calls.

# SYNOPSIS

    $cName pCmd pService [-h] [-H pStyle]

# DESCRIPTION

For systems like mx linx where "systemd" is not enabled, replace
"systemctl" calls with calls to sysv "service" call.

In general:
  systemctl pCmd pService
    calls:
  service pService pCmd

# OPTIONS

- **-pCmd**

    This option is required.  Only these commands will work: start, stop,
    status, restart, reload, reset, force-reload

- **-pService**

    See the scripts in /etc/init.d/ for the service scripts that will work
    with this.

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

# EXAMPLES

    systemctl status ssh

will call:

    service ssh status

PATH

Copy this to a directory that is specified in PATH, before the
directory that has systemctl. Or just replace systemctl with this
script.

Why not systemd? Because in the opinion of many, sysv init is simpler
and has a smaller security expousure than systemd. For those who don't
agree, too bad. Linux is all about freedom of choice; people can
choose the services and apps they like.

# HISTORY

GPLv2 (c) Copyright
