#!/bin/bash
# Help with the most common operations.

# ---------------------------------
function fChangeSecretKeyPassword
{
	echo "NA"
}

# ---------------------------------
function fExportAllPublicKeys
{
	tCmd="gpg --export --armor >export-all-pub-keys.asc"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fExportAllSecretKeys
{
	tCmd="gpg --export-secret-keys --armor >export-all-sec-keys.asc"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fGetKeyFromKeyserver
{
	echo -n "Search for: "
	read tName
	tCmd="gpg --keyserver hkp://subkeys.pgp.net --search-keys $tName"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fImportKeys
{
	tCmd="gpg --import <import.asc"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fListAllSecretKeys
{
	tCmd="gpg --list-secret-keys --with-colons | grep '^sec:'"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fListAllPublicKeys
{
	tCmd="gpg --list-public-keys --with-colons | grep '^pub:'"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fOutputMyPublicKeys
{
	tCmd="gpg --export --armor 'rafnelb@yahoo.com' >rafnelb.asc"
	echo "$tCmd"
	eval "$tCmd"
	tCmd="gpg --export --armor 'bruce@trustedid.com' >rafnelb.asc"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fRefreshKeys
{
	tCmd="gpg --keyserver hkp://subkeys.pgp.net --refresh-keys"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fRefreshWebOfTrust
{
	tCmd="gpg --update-trustdb"
	echo "$tCmd"
	eval "$tCmd"
}

# ---------------------------------
function fSignAFile
{
	echo "NA"
}

# ==========================================================

PS3="Select an option: "
select tOpt in \
	ARORT \
	change-secret-key-password \
	export-all-public-keys \
	export-all-secret-keys \
	get-key-from-keyserver \
	import-keys \
	list-all-secret-keys \
	list-all-public-keys \
	output-my-public-keys \
	refresh-keys \
	refresh-web-of-trust \
	sign-a-file \
    ; do
	case $tOpt in
		ABORT)	exit 1;;
	esac
	break
done

case $tOpt in
	change-secret-key-password)	fChangeSecretKeyPassword;;
	export-all-public-keys)		fExportAllPublicKeys;;
	get-key-from-keyserver)		fGetKeyFromKeyserver;;
	import-keys)			fImportKeys;;
	list-all-secret-keys)		fListAllSecretKeys;;
	list-all-public-keys)		fListAllPublicKeys;;
	output-my-public-keys)		fOutputMyPublicKeys;;
	refresh-keys)			fRefreshKeys;;
	refresh-web-of-trust)		fRefreshWebOfTrust;;
	sign-a-file)			fSignAFile;;
	*)				exit 1;;
esac

exit 0
