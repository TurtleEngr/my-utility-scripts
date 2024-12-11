<div>
    <hr/>
</div>

# NAME say

say - using the festival service, say the text

# SYNOPSIS

    say [-r] [-c Count] [-t Sec] [-h] [-v] [-f File] [TEXT]

# DESCRIPTION

Say the TEXT with the "festival" program. Or if -f, say the text
in the File.

If the -r option is given it will repeat saying the TEXT. See the -r
option for more details.

If words are mispronounced, you can define substitutions in file
"~/.festival.say". See the FILES section.

You can change the festival voice. See file ~/.festivalrc in the FILES
section.

# OPTIONS

- **-r**

    If set, repeat the TEXT every -t sec for -c times. See the defaults
    for -t and -c.

- **-c Count**

    If -r, the number of times to repeat. Default: 5

- **-t Sec**

    If -r, the number seconds between each repeat. Default: 10

- **-f File**

    Say the text in the File. The -c, -r, and -t options will have no
    effect on the file's text.

- **-v**

    Turn on verbose option.

- **-h**

    Output this "long" usage help. If no option, then only the short
    synopsis help will be output.

# EXAMPLES

Say "the job is done". Repeat every 5 seconds then stop after 3 times.

    say -rv -t 5 -c 3 job is done

A fun use is to call 'say' to notify you with status messages. This
will free you up from always looking at your display. (If you are in
an open office, you'll want to use your headphones.) For example: you
are copying some very large files to another system.

    for i in *; do
        say -v copying file $i
        scp $i user@example.com:Documents
    done
    say -rv all the files have been copied

# FILES

- ~/.festival.say

    This file contains a list of word substitutions. The words should be
    all lowercase. However if you want to override any substitutions
    defined in /usr/local/etc/festival.say, make the first letter of the
    MatchText uppercase.

    It is best to use '-' rather than spaces in the replacemet-text, so
    that later rules won't replace the changed text.

    Format:

        MatchText/replacement-text

    A sed script will be generated to do the substitutions. See the file:
    ~/.cache/say/say.sed

    For example:

        brigitte/bridge-eat
        monday/mun-day
        mon/mun-day
        tue/tues-day
        foobar/snae-foo
        wtf/what-the-fork

        # Blank lines are ignored.
        # Lines beginning with # are ignored.
        # Lines that don't have exactly 2 argument separated with a '/'
        #   will be ignored.

- /usr/local/etc/festival.say

    This is a system wide word substitution file. The fromat is the same
    as the user's ~/.festival.say file.

- ~/.festivalrc

        ; Local config file for festival
        ; For global config, edit: /usr/share/festival/siteinit.scm

        ; Uncomment the desired voice
        ;;(voice_cmu_us_slt_arctic_hts)
        ;;(voice_don_diphone)
        ;;(voice_en1_mbrola)
        ;;(voice_kal_diphone)
        ;;(voice_ked_diphone)
        ;;(voice_rab_diphone)
        (voice_us1_mbrola)
        ;;(voice_us2_mbrola)
        ;;(voice_us3_mbrola)

- ~/.cache/say/say.sed

    Temporay file with all replacement words.

# SEE ALSO

## Packages

festival, festival-doc

## Voice Packages

festvox-en1, festvox-kallpc16k, festvox-kdlpc16k, festvox-rablpc16k,
festvox-us-slt-hts, festvox-us1, festvox-us2, festvox-us3

# BUGS

## Fix 1 for 'say' not working as root

This worked for me on mxlinux.

If you run "say" as root and it does not work, and you get an error
something like this:

    ALSA lib pcm_dmix.c:1075:(snd_pcm_dmix_open) unable to open slave aplay:

Then you can probably fix this by creating file /etc/modprobe.d/default.conf
And putting this in the file. Then reboot.

    options snd_hda_intel index=1

Source: https://forums.debian.net/viewtopic.php?t=123902
Or archived at: https://archive.ph/2ylth

## Fix 2 for 'say' not working as root

This worked for me on Ubuntu 18.04.6 LTS. The 'say' script implements
this fix.

    if [[ "$USER" = "root" ]]; then
        export XDG_RUNTIME_DIR=/run/user/$SUDO_UID
    fi

Source: https://unix.stackexchange.com/questions/231941/cant-run-aplay-as-root
Or archived at: https://archive.ph/wip/sVgg7

# HISTORY

    GPLv3 (c) Copyright 2023
    $Revision: 1.11 $ $Date: 2024/11/22 16:42:44 $ GMT
