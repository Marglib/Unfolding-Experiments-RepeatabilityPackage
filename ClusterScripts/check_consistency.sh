#!/bin/bash

properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability LTLCardinality LTLFireability)
for p in ${properties[@]} ; do
    for f in $2 $3 ; do 
	    grep FORM output/$1/$f/*.$p* | grep -oP '(?<=FORMULA ).*(?= TECHNIQUES)' | sort | uniq > answers/$1.$f.$p
    done 

    LEFT=$(comm -13 answers/$1.${2}.$p answers/$1.${3}.$p | grep -oP '.*(?= (TRUE|FALSE))')
    RIGHT=$(comm -23 answers/$1.${2}.$p answers/$1.${3}.$p | grep -oP '.*(?= (TRUE|FALSE))')
    echo "DIFFERENCES IN $p : "

    comm -12 <(echo "$LEFT" | sort) <(echo "$RIGHT" | sort)
    C1=$(cat answers/$1.${2}.$p | wc -l) > p1.txt
    C2=$(cat answers/$1.${3}.$p | wc -l) > p2.txt
    echo "$1.${2}.$p -> $C1"
    echo "$1.${3}.$p -> $C2" 
done
