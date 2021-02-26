#!/bin/bash

pFile=$1
tName=${pFile%.*}

cat <<EOF >$tName.html
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>$tName</title>
</head>
<body>
  <h1>$tName</h1>
  <pre>
EOF

cat $pFile >>$tName.html

cat <<\EOF >>$tName.html
  </pre>
  <hr />
  <p>$Source: /repo/local.cvs/per/bruce/bin/convert-txt2html.sh,v $</p>
  <p>$Revision: 1.1 $; $Date: 2020/07/09 04:08:59 $ GMT</p>
</body>
</html>
EOF
