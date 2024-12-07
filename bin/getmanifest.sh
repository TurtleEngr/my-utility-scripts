#!/bin/bash
# $Header: /repo/per-bruce.cvs/bin/getmanifest.sh,v 1.28 2024/11/26 21:23:08 bruce Exp $

# --------------------
fUsage() {
    local pStyle="$1"
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
        html)
            tProg=pod2html
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
    cat $cBin/$cName | $tProg | more
    exit 1
    
    cat <<\EOF >/dev/null
=pod

=for text ========================================

=for html <hr/>

=head1 NAME getmanifest.sh

Get a manifest of a system's hardware and software.

=head1 SYNOPSIS

    getmanifest.sh [-e ExcludeFile] [-n LogFile] [-h] [-H pStyle]

=head1 DESCRIPTION

The system's manifest will be output to LogFile. It must be run as
root user.

If no LogFile is specified, it will be output to
/var/log/server-manifest.xml

If ExcludeFile file exists, then tags, listed in that file, will not
be output. Default: /usr/local/etc/getmanifext-exclude.txt

All tags that are outputted with the last run can be found at:
/tmp/getmanifext-tag.txt

=head1 OPTIONS

=over 4

=item B<-e ExcludeFile>

If it exists, ExcludeFile contains a list of "tags" (one per line) to
not be put in LogFile. /tmp/getmanifext-tag.txt has the list of tags
output by the last run of getmanifest.sh.

To get the full list of tag names run

  getmanifest.sh with -e /dev/null -n /dev/null

If you want to always exclude some information from any run, then put
the tags in the default exclude file.

Default: /usr/local/etc/getmanifext-exclude.txt

=item B<-n LogFile>

Log file name and location. The file name should end with xml.

Default: /var/log/server-manifest.xml

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

=head1 RETURN VALUE

 0 - ran ok
 !0 - errors, did not run

=for comment =head1 ERRORS

=head1 EXAMPLES

=head2 ExcludeFile method 1

  getmanifest -n /dev/null -e /dev/null
  cp /tmp/getmanifext-tag.txt /usr/local/etc/getmanifext-exclude.txt

Edit /usr/local/etc/getmanifext-exclude.txt and remove the tags that
you want in your LogFile report. Then rerun getmanifest.sh with no
options and review /var/log/server-manifest.xml

=head2 ExcludeFile method 2

If you are filing a defect report, they often want information about
your system. It is easier to create a list of tags you want to
"include," so use this method.

  getmanifest -n /dev/null -e /dev/null
  cp /tmp/getmanifext-tag.txt /tmp/include-tag.txt

  # Remove the tags you don't want.
  edit /tmp/include-tag.txt
  
  # This removes duplicates so the include-tag.txt list will be in the
  # report.
  cat /tmp/getmanifext-tag.txt /tmp/include-tag.txt | \
    sort | uniq -u >/tmp/exclude-tag.txt
    
  getmanifest -e /tmp/exclude-tag.txt -n /tmp/manifext.xml 

Now you can include /tmp/manifext.xml with your defect report.

=for comment =head1 ENVIRONMENT

=head1 FILES

  /var/log/server-manifest.xml - default log file (-n)
  /usr/local/etc/getmanifext-exclude.txt - default exclude file (-e)
  /tmp/getmanifext-tag.txt - list of tags output

=for comment =head1 SEE ALSO

=head1 NOTES

What if you have added or removed packages? If you are on a Debian
based system, you can trigger getmanifest.sh to run with this
setup. Create these files, and once a day, getmanifest will run if apt
was run with install, remove, or upgrade.

=head2 /etc/apt/apt.conf.d/92getmanifest

  // Signal getmanifest.sh needs to be run. See /etc/cron.daily/getmanifest
  DPkg::Post-Invoke { "if [ -x /usr/local/bin/getmanifest.sh ]; then touch /var/cache/apt/getmanifest; fi"; };

=head2 /etc/cron.daily/getmanifest

  #!/bin/bash
  # /var/cache/apt/getnanifest signal file is set by:
  # /etc/apt/apt.conf.d/92getmanifest when apt-get is run.
  if [[ ! -f /var/cache/apt/getmanifest ]]; then
      exit 0
  fi
  /usr/local/bin/getmanifest.sh
  rm /var/cache/apt/getmanifest

=for comment =head1 CAVEATS

=for comment =head1 DIAGNOSTICS

=for comment =head1 BUGS

=for comment =head1 RESTRICTIONS

=for comment =head1 AUTHOR

=head1 HISTORY

GPLv2 (c) Copyright

$Revision: 1.28 $ $Date: 2024/11/26 21:23:08 $ GMT

=cut
EOF
    exit 1
} # fUsage

# --------------------
fCmd() {
    # Input:
    #   $1 - tag
    #   $2 - command
    #   $3 - file (optional)
    # Output:
    #   stdout, stderr
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
        if grep -q $pTag $pgExcludeFile; then
            echo "Skipping: $pTag $pCmd"
            return
        fi
    fi
    echo "$pTag" >>$gTagTmp

    echo '' >>$pgLogFile
    echo '  <!-- ******************** -->' >>$pgLogFile
    echo "  <$pTag cmd=\"$tCmd\">" >>$pgLogFile

    if ! which $tProg >/dev/null 2>&1; then
        echo "Error: command $tProg not found ($pTag)" >>$pgLogFile
        echo "  </$pTag>" >>$pgLogFile
        return
    fi

    if [ -n "$pFile" ]; then
        if [ ! -r "$pFile" ]; then
            echo "Error: file $pFile not found, or not readable ($pTag)" >>$pgLogFile
            echo "  </$pTag>" >>$pgLogFile
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
        " >>$pgLogFile
    echo "  </$pTag>" >>$pgLogFile
} # fCmd

# --------------------
fCommonInfo() {
    echo "  <script ver=\"$cVer\">$0</script>" >>$pgLogFile
    echo "  <date>$('date' +%F_%T_%a)</date>" >>$pgLogFile

    fCmd hostname hostname
    fCmd IP "dig \$(hostname) | grep \"^\$(hostname)\" | awk '{print \$5}'"

    if [ -d /CVS ]; then
        fCmd ServerCVSROOT 'cat /CVS/Root'
        fCmd ServerRepository 'cat /CVS/Repository' /CVS/Repository
    fi

    fCmd cpu 'uname -m'
} # fCommonInfo

# --------------------
fSunOS() {
    fCmd OSRel 'cat /etc/release'
    fCmd KernelModules 'modinfo'
    fCmd Patches 'patchadd -p'
    fCmd pkginfo 'pkginfo|sort'
    fCmd LongPkgInfo 'pkginfo -l'
} # fSunOS

# --------------------
fApps() {
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
    if [ -d /mnt ]; then
        fCmd Mnt 'lstree -L2 /mnt'
    fi
    if [ -d /opt ]; then
        fCmd Opt 'lstree -L1 /opt'
    fi
    if [ -d /usr/local/bin ]; then
        fCmd LocalBin 'lstree -L1 /usr/local/bin'
    fi
    if [ -d /projects ]; then
        fCmd Project 'find /projects/* -prune -type d' /projects
    fi
    if [ -d /site ]; then
        fCmd Sites 'lstree -L1 /site'
        fCmd Apache 'lstree -C -L2 /etc/apache2'
    fi
    if [ -d /etc/apache2/auth ]; then
        fCmd WebAuth 'lstree -C -L2 /etc/apache2/auth'
        for i in /etc/apache2/auth/*; do
            fCmd WebAuth "cat $i"
        done
    fi
    if [ -d /repo ]; then
        fCmd Repos 'lstree -L1 /repo'
        # RepoPub
        for i in /repo/git /repo/mirror.cvs /repo/site.cvs /repo/video.cvs; do
            fCmd RepoPub "lstree -L1 $i"
        done
        for i in /repo/local.cvs /repo/public.cvs /repo/qa.cvs /repo/work.cvs; do
            fCmd RepoPub "lstree -L2 $i | grep -v ',v'"
        done

        # RepoPri
        for i in /repo/sys.cvs; do
            fCmd RepoPri "lstree -L1 $i"
        done
        for i in /repo/per-*.cvs /repo/pri*.cvs; do
            fCmd RepoPri "lstree -L2 $i | grep -v ',v'"
        done
    fi
} # fApps

# --------------------
fOSRel() {
    if [ -e /etc/debian_version ]; then
        fCmd OSRel1 'cat /etc/debian_version' /etc/debian_version
        fCmd UpdateSources 'cat /etc/apt/sources.list | egrep -v "^#|^$"' /etc/apt/sources.list
        for i in /etc/apt/sources.list.d/*.list; do
            fCmd Update "cat $i | egrep -v '^#|^$'" $i
        done
    fi

    if [ -e /etc/redhat-release ]; then
        fCmd OSRel2 'cat /etc/redhat-release' /etc/redhat-release
        for i in /etc/yum.repos.d/*.repo; do
            fCmd Update "cat $i | egrep -v '^#|^$'" $i
        done
    fi

    if [ -e /etc/SuSE-release ]; then
        fCmd OSRel3 'cat /etc/SuSE-release' /etc/SuSE-release
        for i in /etc/zypp/repos.d/*.repo; do
            fCmd Update "cat $i | egrep -v '^#|^$'" $i
        done
    fi

    fCmd OSRel4 'cat /etc/issue.net' /etc/issue.net
    fCmd OSRel5 'cat /etc/issue' /etc/issue

    fCmd OSRelVer1 'cat /etc/os-release' /etc/os-release
    if [ -f /etc/lsb-release ]; then
        fCmd OSRelVer2 'cat /etc/lsb-release'
    fi

    if [ -e /etc/mx-version ]; then
        fCmd OSRelVer3 'cat /etc/mx-version' /etc/mx-version
    fi

    if which lsb_release >/dev/null 2>&1; then
        fCmd OSRelVer4 'lsb_release -a'
    fi
} # fOSRel

# --------------------
fPkgAppImage() {
    fCmd fPkgAppImage 'locate AppImage | grep "\.AppImage$"'
} # fPkgAppImage

# --------------------
fPkgFlatpak() {
    if [ ! -x /usr/bin/flatpak ]; then
        return
    fi

    fCmd fPkgFlatpakList 'flatpak list'
    fCmd fPkgFlatpakApp 'flatpak list --app'
} # fPkgFlatpak

# --------------------
fPkgList() {
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
        # Fix these, so they list the pkg name, then the desc
        ##        fCmd PkgInfo "dpkg -p \$(dpkg -l | grep \"^ii \" | awk '{print \$2}')"
        ##        fCmd PkgFiles "dpkg -L \$(dpkg -l | grep \"^ii \" | awk '{print \$2}')"
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
fPkgListVer() {
    #    if [ -d /etc/yum.repos.d ]; then
    #        fCmd PkgListVer 'rpm -qa | sort -i'
    #        for i in $(rpm -qa | sort -i); do
    #            fCmd PkgInfo "rpm -qi $i"
    #        done
    #        for i in $(rpm -qa | sort -i); do
    #            fCmd PkgFiles "rpm -ql $i"
    #        done
    #    fi

    if which dpkg >/dev/null 2>&1; then
        fCmd PkgListVer "dpkg -l | awk '{print \$2,\$3}'"
        # Fix these, so they list the pkg name, then the desc
        ##        fCmd PkgInfo "dpkg -p \$(dpkg -l | grep \"^ii \" | awk '{print \$2}')"
        ##        fCmd PkgFiles "dpkg -L \$(dpkg -l | grep \"^ii \" | awk '{print \$2}')"
    fi

    #    if [ -d /etc/zypp ]; then
    #        fCmd PkgListVer 'rpm -qa | sort -i'
    #        for i in $(rpm -qa | sort -i); do
    #            fCmd PkgInfo "rpm -qi $i"
    #        done
    #        for i in $(rpm -qa | sort -i); do
    #            fCmd PkgFiles "rpm -ql $i"
    #        done
    #    fi
} # fPkgListVer

# --------------------
fLinuxCommon() {
    fCmd SerialNum '/usr/sbin/dmidecode | egrep -i "serial number" | head -n 1'
    fCmd Manufacturer '/usr/sbin/dmidecode | egrep -i "manufacturer" | head -n 1'
    fCmd Product '/usr/sbin/dmidecode | egrep -i "product" | head -n 1'
    fCmd NumCPU 'grep processor /proc/cpuinfo | wc -l' /proc/cpuinfo
    fCmd CPUModel 'egrep "model[^ ].*:" /proc/cpuinfo | head' /proc/cpuinfo
    fCmd CPUModelName 'grep "model name" /proc/cpuinfo | head' /proc/cpuinfo
    fCmd CPUSpeed 'grep "cpu MHz" /proc/cpuinfo | head' /proc/cpuinfo
    fCmd RAM 'grep "MemTotal" /proc/meminfo' /proc/meminfo

    if which inxi &>/dev/null; then
        fCmd HwInfo1 'inxi -c 0 -F'
    fi
    if which lshw &>/dev/null; then
        fCmd HwInfo2 'lshw'
    fi
    if which hwinfo &>/dev/null; then
        fCmd HwInfo3 'hwinfo --short'
    fi

    fCmd Partition 'cat /proc/partitions' /proc/partitions
    fCmd Mount 'cat /proc/mounts' /proc/mounts
    fCmd DiskSize 'df -m'

    fCmd Network '/sbin/ifconfig | egrep "eth|inet addr" | grep -v 127.0.0.1'
    fCmd KernelVer 'uname -r'
    fCmd KernelMod 'cat /proc/modules' /proc/modules

    fCmd AllBIOS '/usr/sbin/dmidecode'
    fCmd Users 'cat /etc/passwd | sort -i'
    fCmd Groups 'cat /etc/group | sort -i'
    fCmd FSTab 'cat /etc/fstab'
} # fLinuxCommon

# --------------------
fLinux() {
    fLinuxCommon
    fApps
    fOSRel
    fPkgAppImage
    fPkgFlatpak
    fPkgListVer
    fPkgList
} # fLinux

# ============================================
# Main

export cName=getmanifest.sh
export cOS=$(uname -s)

export cVer='$Revision: 1.28 $'
cVer=${cVer#\$Revision: }
cVer=${cVer% \$}

cBin=${0%/*}
if [[ "$cBin" = "." ]]; then
    cBin=$PWD
fi
cd $cBin >/dev/null 2>&1
cBin=$PWD
cd - >/dev/null 2>&1

export gTagTmp=/tmp/getmanifext-tag.tmp
export gTagList=/tmp/getmanifext-tag.txt

# --------------------
# Get options

export pgLogFile="/var/log/server-manifest.xml"
export pgExcludeFile=/usr/local/etc/getmanifext-exclude.txt
export gCheckExclude=0

while getopts :n:e:hH: tArg; do
    case $tArg in
        # Script arguments
        e) pgExcludeFile="$OPTARG"
           gCheckExclude=1
           ;;
        n) pgLogFile="$OPTARG" ;;
        # Common arguments
        h)
            fUsage long
            ;;
        H)
            fUsage $OPTARG
            ;;
        # Problem arguments
        :) echo "Error: Value required for option: -$OPTARG"
           fUsage usage
        ;;
        \?) echo "Error: Unknown option: $OPTARG"
            fUsage usage
        ;;
    esac
done
((--OPTIND))
shift $OPTIND
if [ $# -ne 0 ]; then
    echo "Error: Unknown option: $*"
    fUsage usage
fi

# --------------------
# Validations

if [ "$USER" != "root" ]; then
    echo "Error: not root user"
    fUsage usage
fi

touch $pgLogFile
if [ $? -ne 0 ]; then
    echo "Error: can not write to file: $pgLogFile"
    fUsage usage
fi
if [ ! -w $pgLogFile ]; then
    echo "Error: can not write to file: $pgLogFile"
    fUsage usage
fi

for i in bash sed awk; do
    if ! which $i >/dev/null 2>&1; then
        echo "Error: can not find $i"
        fUsage usage
    fi
done
echo >$gTagTmp

if [ -r $pgExcludeFile ]; then
    gCheckExclude=1
fi

if [ ! -x /usr/local/lstree ]; then
    cp /home/bruce/bin/lstree /usr/local/bin
    chmod a+rx /usr/local/bin/lstree
fi

# ------------------------------------------------------------
echo '<?xml version="1.0"?>' >$pgLogFile
echo '<server>' >>$pgLogFile
fCommonInfo
case $cOS in
    SunOS) fSunOS ;;
    Linux) fLinux ;;
esac
echo "</server>" >>$pgLogFile

sort -uf <$gTagTmp >$gTagList
chmod a+r $pgLogFile $gTagList
rm $gTagTmp

echo
echo "Manifest was written to $pgLogFile"
echo "Tags outputted can be found at: $gTagList"
echo "Create $pgExcludeFile to exclude tags, and run again."
