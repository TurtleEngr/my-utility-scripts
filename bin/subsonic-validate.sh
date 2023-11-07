#!/usr/bin/env bash
set -u

# ========================================
# Functions

# --------------------------------
fUsage() {
    cat <<EOF
subsonic-validate - Validate Playlists
Usage
    subsonic-validate -r -f -x -u
Options
    -r - generate report.
         FileOut: ~/tmp/sv-play.txt     >PlayListFile (uniq)
         FileOut: ~/tmp/sv-report.txt   >CurDir/Track
    -f - find track, from files in report
         FileIn: ~/tmp/sv-report.txt    <CurDir/Track
         FileOut: ~/tmp/sv-found.sed
             Format: s;CurDir/Track;NewDir/Track;
             (Could be multiple matches.)
    -x - fix playlists
         FileIn: ~/tmp/sv-play.txt      <PlayListFile
         FileIn: ~/tmp/sv-fix.sed       <edited: ~/tmp/sv-found.sed)
    -u - rename the *_fixed playlists. Save backups in *_bak
EOF
    exit 1
} # fUsage

# --------------------------------
fCheck() {
    if [[ ! -d ~/tmp ]]; then
        mkdir ~/tmp
    fi
    if [[ ! -d $cgPlayListDir ]]; then
        echo "Error: Missing $cgPlayListDir"
        exit 1
    fi
    if [[ ! -d $cgMusicDir ]]; then
        echo "Error: Missing $cgMusicDir"
        echo 1
    fi
} # fCheck

# --------------------------------
fReport() {
    # -r
    # Input: $cgPlayListDir
    # Input: $cgMusicDir
    # Output: $cgFileReport
    if [[ -f $cgFileReport ]]; then
        read -p "Warning: Overrwrite $cgFileReport (y/n)? "
        if [[ "$REPLY" != "y" ]]; then
            exit 1
        fi
        rm $cgFileReport $cgFilePlay
    fi

    for p in $cgPlayListDir/*.m3u*; do
        for t in $(cat $p); do
            if [[ "$t" = "#EXTM3U" ]]; then
                continue
            fi
            if [[ ! -f $t ]]; then
                ##echo "Missing: $t"
                echo "$p" >>$cgFilePlay
                echo "$t" >>$cgFileReport
            fi
        done
    done
    sort -u $cgFilePlay >~/tmp/sv.tmp
    mv ~/tmp/sv.tmp $cgFilePlay
    sort -u $cgFileReport >~/tmp/sv.tmp
    mv ~/tmp/sv.tmp $cgFileReport

    echo
    wc -l $cgFilePlay $cgFileReport
    echo "Now run with -f"
} # fReport

# --------------------------------
fFind() {
    # -f
    # Input: $cgMusicDir
    # Input: $cgFileReport
    # Output: $cgFileFound
    if [[ ! -f $cgFileReport ]]; then
        echo "Error: Missing $cgFileReport Run with -r to create"
        exit 1
    fi
    if [[ -f  $cgFileFound ]]; then
        read -p "Warning: Overwrite $cgFileFound (y/n)? "
        if [[ "$REPLY" != "y" ]]; then
            exit 1
        fi
        rm $cgFileFound $cgFileNotFound
    fi

    while read tTrack; do
        echo -n '.'
        tTrack=$(echo $tTrack | tr -d ':')
        tFound=0
        for t in $(find $cgMusicDir/ -type f -name ${tTrack##*/}); do
            echo "s;$tTrack;$t;" >>$cgFileFound
            tFound=1
        done
        if [[ $tFound -eq 0 ]]; then
            echo "s;$tTrack;;" >>$cgFileNotFound
        fi
    done <$cgFileReport
    echo

    echo
    wc -l $cgFileReport $cgFileFound $cgFileNotFound
    echo "Now cp $cgFileFound $cgFileFix"
    echo "Manually cat $cgFileNotFound >>$cgFileFix"
    echo "Run with -x"
} # fFind

# --------------------------------
fFix() {
    # -x
    # Input: $cgPlayListDir
    # Input: $cgFileReport (first arg)
    # Input: $cgFileFix
    # Output: [playlist]_fixed
    if [[ ! -f $cgFileReport ]]; then
        echo "Error: Missing $cgFileReport Run with -r to create"
        exit 1
    fi
    if [[ ! -f $cgFilePlay ]]; then
        echo "Error: Missing $cgFilePlay. Run -r"
        exit 1
    fi
    if [[ ! -f $cgFileFix ]]; then
        echo "Error: Missing $cgFileFix. Run -f then edit $cgFileFound"
        exit 1
    fi

    while read p; do
        echo "Fixing: $p"
        sed -f $cgFileFix <$p | rmnl >${p}_fixed
    done <$cgFilePlay
    
    echo
    echo 'If OK, rename the *_fixed files with -u'
    echo "Start Subsonic and rescan files for updated playlists."
} # fFix

# --------------------------------
fRename() {
    # -u
    if [[ ! -f $cgFilePlay ]]; then
        echo "Error: Missing $cgFilePlay. Run -r"
    fi

    while read p; do
        echo "Updating: $p"
        cp -f --backup=t $p ${p}_bak
        mv -f ${p}_fixed $p
    done <$cgFilePlay

    echo
    ls -l $cgPlayListDir
    echo "Fix ownership of files in $cgPlayListDir"
} # fRename

# ========================================
# Main

# -------------------
export cgPlayListDir=/data/subsonic/playlists
export cgMusicDir=/data/subsonic/music
export cgFilePlay=~/tmp/sv-play.txt
export cgFileReport=~/tmp/sv-report.txt
export cgFileFound=~/tmp/sv-found.sed
export cgFileNotFound=~/tmp/sv-not-found.sed
export cgFileFix=~/tmp/sv-fix.sed

# -------------------
# Get Args Section
if [ $# -eq 0 ]; then
    fUsage
fi

# n) gpHostName="$OPTARG" ;;

gpReport=0
gpFind=0
gpFix=0
gpRename=0
while getopts :frxuh tArg; do
    case $tArg in
        # Script arguments
        f) gpFind=1 ;;
        r) gpReport=1 ;;
        x) gpFix=1 ;;
        u) gpRename=1 ;;
        h) fUsage ;;
        # Problem arguments
        :) echo "Value required for option: -$OPTARG"
           exit 1
        ;;
        \?) echo "Unknown option: $OPTARG"
            exit 1
        ;;
    esac
done
((--OPTIND))
shift $OPTIND
if [ $# -ne 0 ]; then
    fUsage
fi

# --------------------
# Functional section

fCheck
if [[ $gpReport -ne 0 ]]; then
    fReport
fi
if [[ $gpFind -ne 0 ]]; then
    fFind
fi
if [[ $gpFix -ne 0 ]]; then
    fFix
fi
if [[ $gpRename -ne 0 ]]; then
    fRename
fi
