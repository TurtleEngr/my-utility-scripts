(c) Copyright 2001 by Bruce Rafnel

# NAME

trans.pl.pl - Translate text with Bablefish.

# SYNOPSIS

        trans.pl [-to] [-round] -language LANGUAGE {-help}

# DESCRIPTION

If -language is not specified, then output short usage help and the
list of available languages.

If -to is not specified, then the translation will be from LANGUAGE to
English.

# OPTIONS

- **-t\*o**

    Convert from English to LANGUAGE.

    If this option is not specified, then the input will be converted from
    LANGUAGE to English.

- **-r\*ound**

    With the option, English text will be converted to the specified
    LANGUAGE, then text will be converted back to English.  If the meaning
    of the text mostly survives this "round-trip", then it is likely that
    the LANGUAGE text will be understood.

- **-l\*anguage LANGUAGE**

    Specify the source or target language.

# RETURN VALUE

# ERRORS

# EXAMPLES

# ENVIRONMENT

# SEE ALSO

WWW::Babelfish

# NOTES

# CAVEATS

# DIAGNOSTICS

# BUGS

# RESTRICTIONS

# AUTHOR

Bruce Rafnel

# HISTORY

(c) Copyright 2001 by Bruce Rafnel

$Revision: 1.7 $
