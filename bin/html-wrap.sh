#!/bin/bash

tFile=$1
tName=$tFile
tName=${tName##*/}
tName=${tName%.*}

cat <<EOF
<html>
<head>
<title>
$tName
<title>
</head>
<style type="text/css">
<!--
body {
  margin-left: 2%;
  margin-right: 2%;
  font-family: Times, serif;
}
h1,h2,h3,h4 {
  font-family: Times, serif;
}
pre {
  font-size: 90%;
  line-height: 95%;
  font-family: Courier, sanserif;
}
ins {
	color: green;
}
del {
	color: red;
}
b {
	color: blue;
}
// -->
</style>
<body>
<h1>
$tName
</h1>

EOF

cat $tFile

cat <<EOF

<hr>
$tFile<br>
\$Revision\$ \$Date\$ GMT
</body>
</html>
EOF
