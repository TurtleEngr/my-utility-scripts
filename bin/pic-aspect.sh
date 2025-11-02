#!/usr/bin/env bash
set -u

# ========================================
# Config

# Std
export cName=pic-aspect.sh

# Defaults
export cQuality='90%'
export gpInfo=0
export gpAspect=std
export gpMaxX=1920
export gpMaxY=0
export gpColor=black
export gpPlace=center
export gpForce=0
export gpVerbose=0

# ========================================
# Functions

# --------------------------------
fUsage() {
    local pStyle="${1:-usage}"
    local tProg=""

    case $pStyle in
        short | usage)
            tProg=pod2usage
            ;;
        long | text)
            tProg=pod2text
            ;;
        html)
            tProg="pod2html --title=$cName"
            ;;
        md)
            tProg=pod2markdown
            ;;
        man)
            tProg=pod2man
            ;;
        *)
            tProg=pod2text
            ;;
    esac

    # Default to pod2text if tProg does not exist
    if ! which ${tProg%% *} >/dev/null; then
        tProg=pod2text
    fi

    cat <<EOF >/tmp/$cName.pod
=pod

=for text ========================================

=for html <hr/>

=head1 NAME $cName

Change the aspect ratio of input image. Add boarders as needed.

=head1 SYNOPSIS

    $cName FILE.jpg... [-i] [-f] [-v] [-h] [-H pStyle]
        [-a pType] or [-A X:Y]
        [-x pMaxX] or [-y pMaxY]
        [-c pColor]
        [-p pPlace]

    pType = std, tv, wide,  cell, tall, narrow
    pPlace = center, left, right, top, bottom

=head1 DESCRIPTION

Change the aspect ratio of the listed files.

=head1 OPTIONS

=over 4

=item B<FILE.jpg...>

One or more input file names.

Output files will have '-fit" added to the input file name.  For
example FILE-fit.jpg

=item B<-i>

Information about the list of files. Uses jhead.

=item B<-f>

If not set, any output files will need be moved or removed.
If this is set, the output files will be overwritten.

=item B<-a pType>

=over 8

=item B<std> - 16:9  (default)

=item B<tv> - 4:3

=item B<wide> - 3:2

=item B<cell> - 9:16

=item B<tall> - 3:4

=item B<narrow> - 2:3

=back

=item B<-A X:Y>
Custom aspect ratio. Only one of -a or -A can be defined.

=item B<-x pMaxX>

Max X width. Given pMaxX and the aspect ratio, solve for Y.  Can only
have -x or -y not both (last one difined, wins).

Default: 1920

=item B<-y pMaxY>

Max Y height.  Given pMaxY and the aspect ratio, solve for X.  Can
only have -x or -y not both (last one difined, wins).

=item B<-c pColor>

Border color. Default: black

If using #RRGGBB code for the color, include it in quotes.

=item B<-p pPlace>

=over 8

=item B<center>
 (center)

=item B<left>
 (west)

=item B<right>
 (east)

=item B<top>
 (north)

=item B<bottom>
(south)

=back

=item B<-v>

Verbose.

=item B<-h>

Output this "long" usage help. See "-H long"

=item B<-H pStyle>

pStyle is used to select the type of help and how it is formatted.

Styles:

    short|usage - Output short usage help as text.
    long|text   - Output long usage help as text.
    man         - Output long usage help as a man page.
    html        - Output long usage help as html.
    md          - Output long usage help as markdown.

=back

=for comment =head2 Globals
=for comment =head1 RETURN VALUE
=for comment =head1 ERRORS
=for comment =head1 EXAMPLES
=for comment =head1 ENVIRONMENT
=for comment =head1 FILES

=head1 SEE ALSO

convert, jhead, pdf2jpg

=for comment =head1 NOTES
=for comment =head1 CAVEATS
=for comment =head1 DIAGNOSTICS
=for comment =head1 BUGS
=for comment =head1 RESTRICTIONS
=for comment =head1 AUTHOR

=head1 HISTORY

GPLv2 (c) Copyright

=cut
EOF
    # shellcheck disable=SC2002
    cat /tmp/$cName.pod | $tProg | less
    exit 1
} # fUsage

# --------------------------------
fValAspect() {
    local tX
    local tY
    
    case $gpAspect in
        std) gpAspect=16:9 ;;
        tv) gpAspect=4:3 ;;
        wide) gpAspect=3:2 ;;
        cell) gpAspect=9:16 ;;
        tall) gpAspect=3:4 ;;
        narrow) gpAspect=2:3 ;;
        *:*)
            tX=${gpAspect%%:*}
            tY=${gpAspect##*:}
            if [[ "$tX" = "$gpAspect" ]]; then
                echo "Error: Aspect $gpAspect is not valid [$LINENO]"
                fUsage usage
            fi
            ;;
        *)
            echo "Error: Invalid: -a $gpAspect [$LINENO]"
            fUsage usage
            ;;
    esac
} # fValAspect

# --------------------------------
fValPlace() {
    case $gpPlace in
        center) : ;;
        left) gpPlace=west ;;
        right) gpPlace=east ;;
        top) gpPlace=north ;;
        bottom) gpPlace=south ;;
        *)
            echo "Error: Invalid: -p $gpPlace [$LINENO]"
            fUsage usage
            ;;
    esac
} # fValPlace

# --------------------------------
fInfo() {
    for tIn in $gpList; do
        echo ''
        jhead $tIn
    done
} # fInfo

# --------------------------------
fCalcAspect() {
    # Given gpAspect, gpMaxX or gpMaxY calc the X Y values
    local tX
    local tY
    tX=${gpAspect%%:*}
    tY=${gpAspect##*:}
    if [[ "$tX" = "$gpAspect" ]]; then
        echo "Error: Aspect $gpAspect is not valid [$LINENO]"
        fUsage usage
    fi

    if [[ gpMaxX -ne 0 ]]; then
        # Solve for gpMaxY
        let gpMaxY=gpMaxX*tY/tX
    else
        # Solve for gpMaxX
        let gpMaxX=gpMaxY*tX/tY
    fi
} # fCalcAspect

# --------------------------------
fResize() {
    local tCall
    local t
    
    for tIn in $gpList; do
        echo -e "\nProcessing: $tIn"
        tOut=${tIn%.*}-fit.jpg
        tCall="convert $tIn \
            -quality $cQuality \
            -scale ${gpMaxX}x${gpMaxY} \
            -background $gpColor \
            -gravity $gpPlace \
            -extent ${gpMaxX}x${gpMaxY} $tOut"
        if [[ $gpVerbose -ne 0 ]]; then
            t=$(echo $tCall)
            echo -e "\t$t"
        fi
        $tCall
    done
} # fResize

# ========================================
# Main

# -------------------
# Get Args Section
if [[ $# -eq 0 ]]; then
    fUsage usage
fi

gpList=""
while getopts :ifa:A:x:y:c:p:vhH: tArg; do
    case $tArg in
        # Script arguments
        i) gpInfo=1 ;;
        f) gpForce=1 ;;
        a) gpAspect="$OPTARG" ;;
        A) gpAspect="$OPTARG" ;;
        x)
            gpMaxX="$OPTARG"
            gpMaxY=0
            ;;
        y)
            gpMaxY="$OPTARG"
            gpMaxX=0
            ;;
        c) gpColor="$OPTARG" ;;
        p) gpPlace="$OPTARG" ;;
        # Common arguments
        v) gpVerbose=1 ;;
        h) fUsage long ;;
        H) fUsage $OPTARG ;;
        # Problem arguments
        :)
            echo "Error: Value required for option: -$OPTARG [$LINENO]"
            fUsage usage
            ;;
        \?)
            echo "Error: Unknown option: $OPTARG [$LINENO]"
            fUsage usage
            ;;
    esac
done
((--OPTIND))
shift $OPTIND
if [[ $# -eq 0 ]]; then
    echo "Error: missing input files [$LINENO]"
else
    gpList="$*"
fi
while [[ $# -ne 0 ]]; do
    shift
done

# --------------------
# Validate section

gErr=0
for tIn in $gpList; do
    if [[ ! -f $tIn || ! -r $tIn ]]; then
        echo "Error: Could not find or read file: $tIn [$LINENO]"
        gErr=1
        continue
    fi
    if file $tIn | grep -qv ' image '; then
        echo "Error: $tIn is not an image file [$LINENO]"
        gErr=1
        continue
    fi
    
    tOut=${tIn%.*}-fit.jpg
    if [[ -e $tOut ]]; then
        if [[ $gpForce -eq 0 ]]; then
            echo "Error: $tOut exists [$LINENO]"
            gErr=1
            continue
        fi
    fi
done
if [[ $gErr -ne 0 ]]; then
    fUsage usage
    exit 1
fi

# --------------------
# Functional section

if [[ $gpInfo -ne 0 ]]; then
    fInfo
    exit
fi

fValAspect
fValPlace
fCalcAspect
fResize
