#!/bin/bash
# $Id: crypt.sh,v 1.29 2021/10/26 19:26:09 bruce Exp $

function fGetKey()
{
    if [ -n "$tPass" ]; then
        return
    fi
    if [ -n "$DISPLAY" -a -x /usr/libexec/openssh/gnome-ssh-askpass ]; then
        export tPass=$(/usr/libexec/openssh/gnome-ssh-askpass)
    else
        read -p 'Password: ' tPass
        export tPass
    fi
}

# Config
tMe=brafnel@napster.com
tDecryptIn=~/a.decrypt.in
tDecryptOut=~/doc/a.decrypted.out
tEncryptIn=~/doc/a.encrypt.in
tLog=~/doc/a.log
tEncryptOut=~/a.encrypted.out
tKeyIn=~/a.key.in
tKeyOut=~/a.key.out
tProblem=~/doc/a.problem
tTmp=~/tmp

# Init
tExec=0
export tPass=''
rm $tLog/current.log 2>/dev/null
for i in \
    $tDecryptIn \
    $tDecryptOut \
    $tEncryptIn \
    $tEncryptOut \
    $tKeyIn \
    $tKeyOut \
    $tLog \
    $tProblem \
    $tTmp; do
    if [ ! -d $i ]; then
        mkdir -p $i
    fi
done

# Import key files
for i in $tKeyIn/*; do
    if [ ! -f "$i" ]; then
        continue
    fi
    echo "==================="
    echo "Processing keys in: $i"
    tExec=1
    gpg --import $i
    if [ $? -ne 0 ]; then
        echo "$i was not imported."
        mv $i $tProblem
    else
        mv $i $tKeyOut
    fi
done

# Decrypt files
for i in $tDecryptIn/*; do
    if [ ! -f "$i" ]; then
        continue
    fi
    tOut=${i%.pgp}
    tOut=${tOut##*/}
    tOut=$tDecryptOut/${tOut%.asc}.txt
    if [ ! -f $tOut ]; then
        echo "==========="
        echo "Decrypting: $i to $tOut"
        echo "Decrypted: ${i##*/} to ${tOut##*/}" >>$tLog/current.log
        fGetKey
        tExec=1
        echo $tPass | gpg --passphrase-fd 0 --output $tOut --decrypt $i
        if [ $? -ne 0 ]; then
            mv $i $tProblem
        fi
    fi
done

# Ecrypt files (recipients: one per line, end with blank line)
# Defect: Only encrypts test files.
for i in $tEncryptIn/*; do
    if [ ! -f "$i" ]; then
        continue
    fi
    tOut=$tEncryptOut/${i##*/}.asc
    if [ ! -f $tOut ]; then
        tTo="--recipient $tMe"
        $tToList='$tMe'
        while read tLine; do
            if [ -z "$tLine" ]; then
                break
            fi
            tLine=${tLine%>*}
            tLine=${tLine#*<}
            tLine=${tLine##* }
            tLine=${tLine%% *}
            tTo="$tTo --recipient $tLine"
            tToList="$tToList, $tLine"
        done <$i
        echo "==========="
        echo "Encrypting: $i, to: $tToList"
        echo "Encrypted: ${i##*/}, to: $tToList" >>$tLog/current.log
        tExec=1
        awk 'NF == 0 {ns=1; next} ns == 0 {next} {print $0}' <$i | gpg --output $tOut $tTo --encrypt
        if [ $? -ne 0 ]; then
            mv $i $tProblem
        fi
    fi
done
if [ $tExec -ne 0 ]; then
    echo ""
    echo "======================================"
    echo "Summary:"
    cat $tLog/current.log
    read -p "Press return to continue "
fi
