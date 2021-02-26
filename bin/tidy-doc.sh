#!/bin/bash
pIn=$1
pOut=$2

tidy -b -q -latin1 $pIn >o.tmp
tidy-doc-fix-ch.pl <o.tmp >$pOut
# rm o.tmp
