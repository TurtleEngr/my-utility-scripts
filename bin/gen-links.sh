#!/bin/bash
# $Header: /repo/local.cvs/per/bruce/bin/gen-links.sh,v 1.5 2021/10/26 19:26:09 bruce Exp $

if [ $# -eq 0 ]; then
    cat <<\EOF2
Usage

# Define vars
export tLink tTitle tType tNumStar tBody tMyDate
# Optional
  tMyDate="YYYY-MM-DD"
tLink="https://..."
tTitle="Title"
tType="video, ted video, article, site, tool, book, podcast"
tNumStar=2
tBody=$(cat <<EOF
  text
EOF
)

gen-links.sh OutFile.tmp

# Now copy content of OutFile.tmp to your links.html file.
EOF2
    exit 1
fi

# =========================
export tOut=$1
export tLink="${tLink:-LINK}"
export tTitle="${tTitle:-TITLE}"
export tType="${tType:-video}"
export tNumStar=${tNumStar:-1}
export tBody=${tBody:-.}
tDate=""

sleep 1
if [ -z "$tMyDate" ]; then
    tDate="$(date +%F)"
else
    tDate=$(date -d "$tMyDate" +%F)
fi
tTime="$(date +%H-%M-%S)"
tDateId="ref-$(date -d $tDate +%F_$tTime)"

cat <<EOF >>$tOut

  <dt>
    <a
      name="${tDateId}"
      id="${tDateId}"
      href="#${tDateId}">
      $tDate
    </a> -
    <a
      href="$tLink" target="_blank">
      $tTitle
    </a> - $tType
EOF

for i in $(seq 1 $tNumStar); do
    cat <<EOF >>$tOut
    <img src="image/star2.jpg" alt="star"/>
EOF
done

cat <<EOF >>$tOut
    </dt>
    <dd><p>
    $tBody
    </p></dd>
EOF

echo "Generated: $tTitle"

tMyDate=""
tLink=""
tTitle=""
tType=""
tNumStar=1
tBody=""
