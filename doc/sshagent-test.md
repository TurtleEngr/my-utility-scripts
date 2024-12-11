<div>
    <hr/>
</div>

# NAME sshagent-test

Test the sshagent script.

# SYNOPSIS

    sshagent-test -T all
    sshagent-test -T list
    sshagent-test [-h] [-H pStyle] [-T pTest]

# DESCRIPTION

This script is used to test the sshagent script. See the Notes section
for how to set it up and the dependent scipts.

# OPTIONS

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

- **-T "pTest"**

    "**-T all**" will run all of the functions that begin with "test".

    "**-T list**" will list all of the test functions.

    Otherwise, **pTest** should be a space separated list of test function
    names, between the quotes.

# ENVIRONMENT

HOME, USER

# SEE ALSO

ssh-agent, ssh, ssh-askpass, shunit2.1, shellcheck

# NOTES

- For more details about shunit2 (or shunit2.1), see
shunit2/shunit2-manual.html [Source](https://github.com/kward/shunit2)

    shunit2.1 has a minor change to fix up colors when background is not black.

- The latest versions of sshagent, sshagent-test, and shunit2.1 can be
found at:
[github TurtleEngr](https://github.com/TurtleEngr/my-utility-scripts/tree/main/bin)
- sshagent-test will kill all of your running ssh-agent processes before
and after running.
- sshagent-test requires a non X11 /bin/ssh-askpass

    Create this substitute:

        cat <<EOF >~/bin/ssh-askpass
        #!/bin/bash
        read -t 5 -p "ssh password? "
        echo $REPLY
        EOF
        chmod a+rx,go-w ~/bin/ssh-askpass

    You can replace the system's ssh-askpass, or you can change your path
    so it finds ssh-askpass in your bin dir.

    - 1. Replace the system's ssh-askpass. As root:

            sudo -s
            mv -i /usr/bin/ssh-askpass /usr/bin/ssh-askpass.sav
            cp /home/$SUDO_USER/bin/ssh-askpass /usr/bin
            chmod a+rx,go-w /usr/bin/ssh-askpass
            exit

    - 2. Change your path so ~/bin is look in first:

            ed ~/.bash_profile
            PATH=$HOME/bin:$PATH

        If you still get the ssh-askass popup, you'll need to use option 1, or
        you can give the test key's password 'foobar' at every prompt.

# AUTHOR

TurtleEngr

# HISTORY

$Revision: 1.15 $ $Date: 2024/11/22 20:28:41 $ GMT
