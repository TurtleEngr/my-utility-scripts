#!/bin/bash
# Needs the apg program.
# Generate 10 5x5 password tokens (similar to Microsoft).
# Remove confusing chars.

apg -a 1 -n 10 -m 25 -x 25 -M Nl -E0o1ilqp |
    perl -e '
while (<>) {
        s/(.....)(.....)(.....)(.....)(.....)/$1-$2-$3-$4-$5/;
        print;
}
'
