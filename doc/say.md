<div>
    <hr/>
</div>

# NAME say

say - using the festival service, say the text

# SYNOPSIS

    say [-r] [-c Count] [-t Sec] [-h] [-v] TEXT

# DESCRIPTION

Say the TEXT with the "festival" program.

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

- **-v**

    Turn on verbose option.

- **-h**

    Output this "long" usage help. If no option, then only the short
    synopis help will be output.

# EXAMPLES

Say "the job is done". Repeat every 5 seconds then stop after 3 times.

    say -rv -t 5 -c 3 job is done

# FILES

- ~/.festival.say

    This file contains a list word substitutions. The words should be all
    lowercase.

    Format:

        match text/replacement text

    A sed script will be generated to do the substitutions. See the file:
    ~/.cache/say/say.sed

    For example:

        brigitte/bridge eat
        monday/mun day
        tue/tues day
        foo bar/snae foo

        # Lines beginning with # are ignored.
        # Blank lines are ignored.
        # Lines that don't have exactly 2 '/' separated argments on
        # the line, are ignored.

- ~/.festivalrc

        ; Local config file for festival
        ; For global config, edit: /usr/share/festival/siteinit.scm

        ; Uncomment the desired voice
        ;;(voice_rab_diphone)
        ;;(voice_don_diphone)
        ;;(voice_kal_diphone)
        ;;(voice_en1_mbrola)
        ;;(voice_ked_diphone)
        (voice_us1_mbrola)
        ;;(voice_us2_mbrola)
        ;;(voice_us3_mbrola)
        ;;(voice_cmu_us_slt_arctic_hts)

# SEE ALSO

## Packages

festival, festival-doc

## Voice Packages

festvox-en1, festvox-kallpc16k, festvox-kdlpc16k, festvox-rablpc16k,
festvox-us-slt-hts, festvox-us1, festvox-us2, festvox-us3

# HISTORY

    GPLv3 (c) Copyright 2023
    $Revision: 1.1 $ $Date: 2023/02/15 09:49:45 $ GMT
