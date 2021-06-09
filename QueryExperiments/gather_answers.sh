#!/bin/bash

properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability LTLCardinality LTLFireability)

mkdir -p answers

for p in ${properties[@]} ; do
    for f in $1 ; do
        grep FORM output/$f/*.$p* | grep -oP '(?<=FORMULA ).*(?= TECHNIQUES)' | sort | uniq > answers/$1.$p
    done

    C1=$(cat answers/$1.$p | wc -l) > answers/$1.$p.wcl
    echo "Answered queries for $1.$p -> $C1"
done
