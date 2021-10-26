#!/bin/bash

if [ $# -le 1 ]; then
    cat <<EOF 1>&2
Usage:
	setpath.sh cur-path dir...

Given one or more "dir" names, if the dir exists, and it is not in the
cur-path string, it will be appended with a ':' separator.

Example:
	PATH=\$(setpath.sh \$PATH /opt/eclipse /opt/setup)
EOF
    exit 1
fi

# Add ':' to make pattern matching easier
pCurPath=":$1:"
shift
for p in $*; do
    if [ "${p#/}" = "$p" ]; then
        # dirs must start with /
        continue
    fi
    if [ ! -d $p ]; then
        # dir doesn't exist
        continue
    fi
    tNew=${pCurPath##*:$p}
    tNew=${pCurPath%%$p:*}
    if [ "$tNew" = "$pCurPath" ]; then
        # dir is not alread in pCurPath
        pCurPath=${pCurPath}$p:
    fi
done

# Remove the extra ':'
pCurPath=${pCurPath#:}
pCurPath=${pCurPath%:}

echo $pCurPath
exit 0
