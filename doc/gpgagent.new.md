# NAME

sshagent - setup the ssh agent process

# SYNOPSIS

    . sshagent [-h] [-s] [-k] [-t TTL] [-T TTL] [key ...]

    cgAgentOwner - user name. Default: $USER

# DESCRIPTION

Using ssh-agent is a lot more secure than using a passwordless ssh
key. If you use passwordless keys, you are following a very bad
pattern, which could lead to large security issues.

This sshagent script is a wrapper for ssh-agent and ssh-add to make it
easier to setup and use a ssh-agent. It only starts an agent process
if one isn't already running, and it saves the PID env. var. values
for use by scripts.

See the EXAMPLES section for how to use this script.

If an agent is found, then the env. var. are set, the keys are added,
then listed.  If an agent is not found, all other agents are killed,
and a new agent is initialized, the keys are added, and the
env. var. are set.

If -s is used (no keys) and an agent is running, then env. vars. are
set to use the agent. If an agent is not running, then the agent
related env. vars. are unset. -s is commonly used in cron job scripts.

If -k is used (no keys), then all ssh-agent will be killed.

If cgAgentOwner env. is set, then that will be used instead of $USER,
to find the sshagent.env file.  This is only useful for scripts that
are run with the "root" user. This is only useful with the -s option,
after agent is started as a regular user.

If any Errors messages are output, that means he script has done
nothing. Correct the error and try again.

# OPTIONS

- **-h**

    Output full help.

- **-s**

    Set env. var. to use an already running agent, and list the keys.
    If an agent is not running an Error message will be output.

- **-k**

    Kill all agents owned by the current cgAgentOwner, i.e. $USER.

- **-t TTL**

    Set the time to live for the keys on the agent. Each time a key is
    used the TTL is reset to the specified number of seconds.

    TTL Values: Y, M, W, D, H, \[0-9\]\*

    if a number of sec is defined, it needs to be between 60 to 31536000
    (one min to one year)

    (other allowed values: y, year, Year, m, month, Month, etc.)

- **-T TTL**

    Set maximum time to live for the keys on the agent, even if a key
    is used.

    TTL Values: same as -t option

- **key ...**

    Start a new ssh-agent if one is not running. Add one or more keys to
    the agent.

    If a key is not found, the script will try prepending the key with
    "$HOME/.ssh/". If that is not found, the script will stop with an
    error.

# ERRORS

## Env and option Errors

    Error: sshagent is not 'sourced' [LINENO]
    Error: No options were found [LINENO]"
    Error: Unknown option: OPTARG [LINENO]
    Error: Missing USER env. var. [LINENO]
    Error: Missing HOME env. var. [LINENO]
    Error: Missing program: PROG [LINENO]

## Directory Errors

    Error: HOME dir is not writable [LINENO]

This could be caused by cgAgentOwner being set to an unknown user.

    Error: $cgEnvDir is not writable or is missing [LINENO]

This could be caused by cgAgentOwner being set to a user that has no
~/.ssh/ dir.

    Error: with chown [LINENO]
    Error: with chmod [LINENO]

The attempt to change the owner and permissions on the cgEnvDir
failed. The dir and files should ONLY have "user" read/write
permissions.

    Error: Not found: KEY [LINENO]

A KEY was not found, even after prepending with "$HOME/.ssh/"

## -s Errors

    Error: agent is not running [LINENO]
    Error: not found: $cgEnvFile [LINENO]

## -t or -T Errors

    Error: $pTime is not in range. See option -t in usage [LINENO]
    Error: $pTime is invalid. See option -t in usage [LINENO]

## Key add errors or warnings

    Error: cgAgentOwner override cannot be used to add keys [LINENO]
    Warning: KEY has no password!!! [LINENO]

# EXAMPLES

The first time you login to your computer, run this to authenticate
your ssh keys for the agent. Do not put this in your profile. You only
need to do this after a computer is first started or rebooted.

        . sshagent ~/.ssh/id.home ~/.ssh/id.work

You ran sshagent to create an agent, but you forgot to "source" the
script so that the SSH\_\* env. are not set.  Just repeat the command,
with a ". " at the front.

You can run sshagent any time to add more keys.

In a profile script add this line. That way when you start a new
terminal it will use any keys from the agent. This can also be
put in a script if it needs the keys saved on the agent.

    . sshagent -s

In a script run by the 'root' user:

    export $cgAgentOwner=george
    . sshagent -s

Add another key to a running agent:

    sshagent ~/.ssh/id_foo_dsa

List agent and added keys:

    sshagent -l

Kill all your agents. This would be a good practice if you don't want
your keys "active" on the computer.

    sshagent -k

# ENVIRONMENT

    cgAgentOwner - user name. Default: $USER
    SSH_AGENT_PID - set by ssh-agent
    SSH_AUTH_SOCK - set by ssh-agent
    HOME - set by OS. The usual default: /home/$USER
    USER - set by OS

# FILES

    /home/$cgAgentOwner/.ssh/.sshagent.env

# SEE ALSO

    ssh-agent, ssh-add

# NOTES

DO NOT use passwordless keys for ssh or gpg!  The ONLY exception might
be for a production server that might be rebooted, and no one would be
around to authenticate the keys. If you do use passwordless keys, then
make sure the keys are ONLY used on production, the permissions
prevent copying the keys, and the keys are "managed". I.e. the keys
are not in any non-production user account, and they are regularly
rotated.

# CAVEATS

When ssh-agent is active it will send each of the keys to a ssh
command, until one works. This could cause problems. For example what
if you have a rate limit of only 3 login attempts over a one minute
period.  If the "correct" key is not one of the first 3 on the agent,
then ssh will always fail.

The weird coding style of using functions, gErr, and returns is done to
avoid using "exit," which would exit the active process (terminal).

# RESTRICTIONS

sshagent only works well with bash.

# HISTORY

$Revision: 1.63 $
