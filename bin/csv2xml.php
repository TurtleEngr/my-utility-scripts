<?php
/* * * * * * * * * * * * * * * * * * * * * * * * * * * *
csv2xml.php

=pod

=head1 NAME

csv2xml.php - test script

=head1 SYNOPSIS

 export libEnv="$HOME/bin/lib/base.lib.inc"

 /opt/php/bin/php csv2xml -i InFile -o OutFile
	[-n] [-v] [-d] [-h]

=head1 DESCRIPTION

=head1 OPTIONS

=head1 RETURN VALUE

=head1 ERRORS

=head1 EXAMPLES

=head1 ENVIRONMENT

=head1 FILES

=head1 SEE ALSO

=head1 NOTES

=head1 CAVEATS

=head1 DIAGNOSTICS

=head1 BUGS

=head1 RESTRICTIONS

=head1 AUTHOR

TrustedID

=head1 HISTORY

$URL$

 $Date: 2023/05/21 01:34:42 $
 $Revision: 1.3 $

=cut

* * * * * * * * * * * * * * * * * * * * * * * * * * * */

# -----------------------------
function fCsv2Raw($pInFile, $pOutFile) {
    /*
Parse the csv $pInFile, and convert it to an XML file: $pOutFile

The first record is the header record.  It is parsed to generate the
field names (tHead[]).
*/

    $hInFile = fopen($pInFile, "r");
    $hOutFile = fopen($pOutFile, "w");

    fwrite($hOutFile, "<?xml version=\"1.0\"?>\n");
    fwrite($hOutFile, "<raw-input>\n");

    $tFirst = 1;
    while (($tLine = fgetcsv($hInFile)) !== FALSE) {
        if ($tFirst) {
            # Parse the csv file header record
            $tFirst = 0;
            $tHead = $tLine;
            $tSize = count($tHead);
            for ($i = 0; $i < $tSize; ++$i) {
                $tHead[$i] = strtolower($tHead[$i]);
                $tHead[$i] = preg_replace('/^"?\s*/',
                    '', $tHead[$i]);
                $tHead[$i] = preg_replace('/\s*"?$/',
                    '', $tHead[$i]);
                $tHead[$i] = preg_replace('/ +/', '-',
                    $tHead[$i]);
            }
            continue;
        }

        # Process the file records
        fwrite($hOutFile, "  <record>\n");
        $tSize = count($tLine);
        for ($i = 0; $i < $tSize; ++$i) {
            $tLine[$i] = preg_replace('/^"?\s*/', '', $tLine[$i]);
            $tLine[$i] = preg_replace('/\s*"?$/', '', $tLine[$i]);
            if ($tLine[$i] == '') {
                # Skip empty field
                continue;
            }
            fwrite($hOutFile, "    <" . $tHead[$i] . ">");
            fwrite($hOutFile, $tLine[$i]);
            fwrite($hOutFile, "</" . $tHead[$i] . ">\n");
        }
        fwrite($hOutFile, "  </record>\n");
    }

    fwrite($hOutFile, "</raw-input>\n");
} # fCsv2Raw

# =====================================================
# Validate the boot-strap env. var.

if ($argc < 2) {
    system("pod2text $argv[0]");
    exit(1);
}

$libEnv = getenv('libEnv');
if ($libEnv == '') {
    $libEnv = getenv('HOME') . "/bin/lib/base.lib.inc";
}

# -----------------------------
# Includes
require_once $libEnv;

# Check for minimum required config vars. (ones that may not show up
# in later error handling).
if (isset($_CONFIG['DIR']['LIB']) === false) {
    die("Fatal Error: _CONFIG['DIR']['LIB'] var. is not defined! [99939]");
}
if (isset($_CONFIG['NAGIOS_DOMAIN']) === false) {
    die("Fatal Error: _CONFIG['DIR']['LIB'] var. is not defined! [99940]");
}
if (isset($_CONFIG['SYSLOG_IDENT']) === false) {
    die("Fatal Error: _CONFIG['DIR']['LIB'] var. is not defined! [99941]");
}
if (isset($_CONFIG['SYSLOG_FACILITY']) === false) {
    die("Fatal Error: _CONFIG['DIR']['LIB'] var. is not defined! [99942]");
}

# Setup error handling and logging
require_once $_CONFIG['DIR']['LIB'] . "/monitor.inc";
log_open($_CONFIG['SYSLOG_IDENT'], $_CONFIG['SYSLOG_FACILITY']);
set_error_handler('mgmt_php_exceptions', E_ALL);

# This is set to turn on the 'throw' code in lower level functions.
$cgMgmtException = 1;

try {
    require_once($_CONFIG['DIR']['LIB'] .
        "/scripts_common_functions.php");
}
catch (Exception $tE) {
    $gErr = 'critical';
    log_exception($gErr, $tE, 1);
    die("Could not load all the requires");
}

# -----------------------------
# Init vars.
$cgScriptName = basename(__FILE__, ".php");
$gDomain = $_CONFIG['NAGIOS_DOMAIN'];
$cgServiceName = $gDomain . "-$cgScriptName";
$gErr = 'ok';

# -----------------------------
# Get Options

$gpInFile = "";
$gpOutFile = "";

$tOpt = getopt("i:o:ndvh");

if (isset($tOpt['i'])) {
    $gpInFile = $tOpt['i'];
} else {
    $gpHelp = 1;
}

if (isset($tOpt['o'])) {
    $gpOutFile = $tOpt['o'];
} else {
    $gpHelp = 1;
}

$gpNoExec = isset($tOpt['n']);
$gpDebug = isset($tOpt['d']);
$gpContinue = isset($tOpt['c']);
$gpVerbose = isset($tOpt['v']);
$gpHelp = isset($tOpt['h']);

##if ($gpDebug) {
log_msg(99903, 'info', " gpInFile=$gpInFile\n gpOutFile=$gpOutFile\n gpNoExec=$gpNoExec\n gpDebug=$gpDebug\n gpVerbose=$gpVerbose\n gpHelp=$gpHelp\n", __FILE__, __LINE__);
##}

if ($gpHelp) {
    system("pod2text $argv[0]");
    exit(1);
}

# ==============================
# Start processing

/*
Overall try wrapper for validate/read sections.  The script will exit
with any errors thrown (or re-thrown) at this level.
*/
try {
    # -----------------------------
    # Validate options

    # -----------------------------
    /* Get all resources (open all file (verify read/write), open all DB
	connections needed, and verify read/write access to DBs).  Die if there
	is any problem.
	*/

    # $gpInFile = "input.sample.csv";
    # $gpOutFile = "sample.xml";

    is_readable2($gpInFile, 99901);
    is_writable2(".", 99902);

    # -----------------------------
    /* Start read-only functional section.
	*/

} # End validate/read section try
catch (Exception $tE) {
    log_exception($gErr, $tE, 1);
    exit;
}

if ($gpNoExec) {
    log_msg(99911, 'warn', 'Exiting before the write section.',
        __FILE__, __LINE__);
    exit;
}

# ==============================
/* Start the "write" section.
*/

try {
    fCsv2Raw($gpInFile, $gpOutFile);
} # End write try section
catch (MgmtException $tE) {
    $gErr = 'crit';
    log_exception($gErr, $tE, 1);
    exit;
}
catch (Exception $tE) {
    $gErr = 'crit';
    log_exception($gErr, $tE, 1);
    exit;
}


# -----------------------------
# Final status for the script: OK, Warning, Error

log_close();

?>
