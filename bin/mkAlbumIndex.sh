#!/bin/bash

if [ -f index.html ]; then
    echo "index.html already exists"
    exit
fi

tTitle=$PWD
tTitle=${tTitle##*/}

# --------------
cat <<EOF >index.html
<html>
<head>
<title>
$tTitle
</title>
</head>
<body>
<!--
\$Header\$
-->
<h1>$tTitle</h1>

<dl>

EOF

# --------------
for i in $(find * -prune -type f); do
    case $i in
        *_t.jpg | *_t.gif | *_t.png)
            continue
            ;;
        index.html)
            continue
            ;;
        *.jpg | *.gif | *.png)
            te=${i#*.}
            tb=${i%.*}
            tn=${tb}_t.$te
            if [ -f $tn ]; then
                t="<img src=\"$tn\">"
                f=$i
            else
                t=$i
                f=""
            fi
            tSize=$(identify $i | awk '{ print "[" $3, $6 "]"}')
            # pict0353.jpg JPEG 1013x689 DirectClass 8-bit 178kb
            f="$f $tSize"
            ;;
        *)
            $t=$i
            tSize=$(du -k $i | awk '{ print "[" $1 "]"}')
            f="[${f}kb]"
            ;;
    esac
    cat <<EOF >>index.html
<dt> <a href="$i"> $t </a> $f <dd>
<!-- Replace with description -->
<p>

EOF
done

# --------------
cat <<EOF >>index.html
</dl>

<hr>
Last updated: \$Date\$
</body>
</html>
EOF
