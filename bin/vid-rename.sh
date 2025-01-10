#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/vid-rename.sh,v 1.6 2025/01/09 23:22:19 bruce Exp $

if [[ $# -eq 0 ]]; then
    cat <<EOF
Usage:
    vid-rename FILE...
        Rename all FILES with exif data.
    vid-rename DIR
        Rename all files with exif data in current DIR.
    vid-rename .
        Rename all files with exif data in current dir.
New name:
    %Y-%m-%d/%Y-%m-%d_%H%M%S_UTC.%e
EOF
    exit 1
fi

exiftool '-FileName<CreateDate' -d %Y-%m-%d/%Y-%m-%d_%H%M%S_UTC.%%e $*
exit $?
