#!/bin/bash
# configuration-dev/service/aws_boot/src/usr/local/sbin/getmanifest.sh

# --------------------
function fUsage {
	cat <<EOF

Usage
	getmanifest.sh [File]

The system's manifest will be output to File.
If no File is specified, it will be output to /var/log/server-manifest.xml
If $gExcludeTag file exists, then tags, listed in that file,
will not be output.
All tags that are outputted can be found at: $gTagList

EOF
	exit 1
} # fUsage

# --------------------
function fCmd {
	# Input:
	# 	$1 - tag
	# 	$2 - command
	#	$3 - file (optional)
	# Output:
	#	stdout, stderr
	local pTag=$1
	local pCmd=$2
	local pFile=$3

	local tProg=$(echo $pCmd | awk '{print $1}')
	local tCmd=$(echo "$pCmd" | sed '
		s/&/\&amp;/g
		s/"/\&quot;/g
		s/</\&lt;/g
		s/>/\&gt;/g
	' | sed "
		s/'/\&apos;/g
	")

	if [ $gCheckExclude -ne 0 ]; then
		if grep -q $pTag $gExcludeTag; then
			echo "Skipping: $pTag $pCmd"
			return
		fi
	fi
	echo "$pTag" >>$gTagTmp

	echo '' >>$gOut
	echo '  <!-- ******************** -->' >>$gOut
	echo "  <$pTag cmd=\"$tCmd\">" >>$gOut

	if ! which $tProg >/dev/null 2>&1; then
		echo "Error: command $tProg not found ($pTag)" >>$gOut
		echo "  </$pTag>" >>$gOut
		return
	fi

	if [ -n "$pFile" ]; then
		if [ ! -r "$pFile" ]; then
			echo "Error: file $pFile not found, or not readable ($pTag)" >>$gOut
			echo "  </$pTag>" >>$gOut
			return
		fi
	fi

 	bash -c "$pCmd 2>&1" | sed '
		s/&/\&amp;/g
		s/"/\&quot;/g
		s/</\&lt;/g
		s/>/\&gt;/g
	    ' | sed "
		s/'/\&apos;/g
	" >>$gOut
	echo "  </$pTag>" >>$gOut
} # fCmd

# --------------------
function fCommonInfo {
	echo "  <script ver=\"$cVer\">$0</script>" >>$gOut
	echo '  <Id>getmanifest.sh</Id>' >>$gOut

	fCmd hostname hostname
	fCmd IP "dig \$(hostname) | grep \"^\$(hostname)\" | awk '{print \$5}'"

	if [ -d /CVS ]; then
		fCmd ServerCVSROOT 'cat /CVS/Root'
		fCmd ServerRepository 'cat /CVS/Repository' /CVS/Repository
	fi

	fCmd cpu 'uname -m'
} # fCommonInfo

# --------------------
function fSunOS {
	fCmd OSRel 'cat /etc/release'
	fCmd KernelModules 'modinfo'
	fCmd Patches 'patchadd -p'
	fCmd pkginfo 'pkginfo|sort'
	fCmd LongPkgInfo 'pkginfo -l'
} # fSunOS

# --------------------
function fApps {
	if [ -d /projects ]; then
		fCmd Project 'find /projects/* -prune -type d' /projects
	fi

	if [ -e /usr/sbin/httpd ]; then
		fCmd ApacheVer '/usr/sbin/httpd -v'
		fCmd ApacheInfo '/usr/sbin/httpd -V'
	fi

	if [ -e /usr/sbin/apache2 ]; then
		fCmd ApacheVer '/usr/sbin/apache2 -v'
		fCmd ApacheInfo '/usr/sbin/apache2 -V'
	fi

	if [ -e /usr/bin/php ]; then
		fCmd PHPVer 'php -v'
		fCmd PHPMod 'php -m'
		fCmd PHPInfo 'php -i'
	fi

	if [ -d /opt/php/bin ]; then
		fCmd PHPVer '/opt/php/bin/php -v'
		fCmd PHPMod '/opt/php/bin/php -m'
		fCmd PHPInfo '/opt/php/bin/php -i'
	fi
} # fApps

# --------------------
function fOSRel {
	if [ -e /etc/debian_version ]; then
		fCmd OSRel 'cat /etc/debian_version' /etc/debian_version
		fCmd UpdateSources 'cat /etc/apt/sources.list | egrep -v "^#|^$"' /etc/apt/sources.list
		for i in /etc/apt/sources.list.d/*.list; do
		fCmd Update "cat $i | egrep -v '^#|^$'" $i
		done
	fi

	if [ -e /etc/redhat-release ]; then
		fCmd OSRel 'cat /etc/redhat-release' /etc/redhat-release
		for i in /etc/yum.repos.d/*.repo; do
		fCmd Update "cat $i | egrep -v '^#|^$'" $i
		done
	fi

	if [ -e /etc/SuSE-release ]; then
		fCmd OSRel 'cat /etc/SuSE-release' /etc/SuSE-release
		for i in /etc/zypp/repos.d/*.repo; do
		fCmd Update "cat $i | egrep -v '^#|^$'" $i
		done
	fi
} # fOSRel

# --------------------
function fPkgList {
	if [ -d /etc/yum.repos.d ]; then
		fCmd PkgList 'rpm -qa | sort -i'
		for i in $(rpm -qa | sort -i); do
		fCmd PkgInfo "rpm -qi $i"
		done
		for i in $(rpm -qa | sort -i); do
		fCmd PkgFiles "rpm -ql $i"
		done
	fi

	if which dpkg >/dev/null 2>&1; then
		fCmd PkgList 'dpkg -l'
		fCmd PkgInfo "dpkg -i \$(dpkg -l | grep \"^ii \" | awk '{print \$2}')"
	fi

	if [ -d /etc/zypp ]; then
		fCmd PkgList 'rpm -qa | sort -i'
		for i in $(rpm -qa | sort -i); do
		fCmd PkgInfo "rpm -qi $i"
		done
		for i in $(rpm -qa | sort -i); do
		fCmd PkgFiles "rpm -ql $i"
		done
	fi
} # fPkgList

# --------------------
function fLinuxCommon {
	fCmd SerialNum '/usr/sbin/dmidecode | egrep -i "serial number" | head -n 1'
	fCmd Manufacturer '/usr/sbin/dmidecode | egrep -i "manufacturer" | head -n 1'
	fCmd Product '/usr/sbin/dmidecode | egrep -i "product" | head -n 1'
	fCmd NumCPU 'grep processor /proc/cpuinfo | wc -l' /proc/cpuinfo
	fCmd CPUModel 'egrep "model[^ ].*:" /proc/cpuinfo | head' /proc/cpuinfo
	fCmd CPUModelName 'grep "model name" /proc/cpuinfo | head' /proc/cpuinfo
	fCmd CPUSpeed 'grep "cpu MHz" /proc/cpuinfo | head' /proc/cpuinfo
	fCmd RAM 'grep "MemTotal" /proc/meminfo' /proc/meminfo

	fCmd Partition 'cat /proc/partitions' /proc/partitions
	fCmd Mount 'cat /proc/mounts' /proc/mounts
	fCmd DiskSize 'df -m'

	fCmd OSName 'cat /etc/issue.net' /etc/issue.net
	fCmd Network '/sbin/ifconfig | egrep "eth|inet addr" | grep -v 127.0.0.1'
	fCmd KernelVer 'uname -r'
	fCmd KernelMod 'cat /proc/modules' /proc/modules

	fCmd AllBIOS '/usr/sbin/dmidecode'
	fCmd Users 'cat /etc/passwd | sort -i'
	fCmd Groups 'cat /etc/group | sort -i'
	fCmd FSTab 'cat /etc/fstab'
} # fLinuxCommon

# --------------------
function fLinux {
	fLinuxCommon
	fApps
	fOSRel
	fPkgList
} # fLinux

# ============================================
export cVer=3.2
export cOS=$(uname -s)
export gOut
export gTagTmp=/tmp/getmanifext-tag.tmp
export gTagList=/tmp/getmanifext-tag.txt
export gExcludeTag=/tmp/getmanifext-exclude.txt
export gCheckExclude=0

# --------------------
# Get options

if [ $# -eq 0 ]; then
	#gOut="$(hostname).xml"
	#gOut="/tmp/server-manifest.xml"
	#gOut="server-manifest.xml"
	gOut="/var/log/server-manifest.xml"
else
	if [ "x$1" = "x-h" ]; then
		fUsage
	fi
	gOut=$1
fi

# --------------------
# Validations

if [ "$(whoami)" != "root" ]; then
	echo "Error: not root user"
	exit 1
fi

touch $gOut $gOut.gz
if [ $? -ne 0 ]; then
	echo "Error: can not write to file: $gOut or $gOut.gz"
	exit 1
fi
if [ ! -w $gOut -o ! -w $gOut.gz ]; then
	echo "Error: can not write to file: $gOut or $gOut.gz"
	exit 1
fi

for i in bash sed awk; do
	if ! which $i >/dev/null 2>&1; then
		echo "Error: can not find $i"
		exit 1
	fi
done
echo >$gTagTmp

if [ -r $gExcludeTag ]; then
	gCheckExclude=1
fi

# --------------------
echo '<?xml version="1.0"?>' >$gOut
echo '<server>' >>$gOut
fCommonInfo
case $cOS in
	SunOS)	fSunOS;;
	Linux)	fLinux;;
esac
echo "</server>" >>$gOut

gzip -f $gOut

sort -uf <$gTagTmp >$gTagList
chmod a+rw $gTagList
rm $gTagTmp

echo
echo "Manifest was written to $gOut.gz"
echo "Tags outputted can be found at: $gTagList"
echo "Create $gExcludeTag to exclude tags, and run again."
