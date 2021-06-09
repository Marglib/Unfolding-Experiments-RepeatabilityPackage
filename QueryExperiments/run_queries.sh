#!/bin/bash

TO=5
let "M=1*15" ;
let "m=$M*1024*1024"
ulimit -v $m

unfoldednet=$1
unfoldedquery=$2
i=$3
t=$4
BINDIR=$5

for j in $(seq 1 16) ; do
    if [[ "$t" == "LTLCardinality" || "$t" == "LTLFireability" ]]; then
        timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/trunk-238 -ltl -s DFS -n -x $j $unfoldednet $unfoldedquery &> $BINDIR/$i.$t.$j
    else
        timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/trunk-238 -s DFS -n -x $j $unfoldednet $unfoldedquery &> $BINDIR/$i.$t.$j
    fi
done