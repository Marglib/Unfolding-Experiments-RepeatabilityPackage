#!/bin/bash

mkdir -p "output/$1-stats"

for f in $(ls output/$1 ) ; do
	places="$(grep -Eo "\|P\|=[1-9][0-9]*" output/$1/$f | grep -Eo [1-9][0-9]*)"
	transitions="$(grep -Eo "\|T\|=[1-9][0-9]*" output/$1/$f | grep -Eo [1-9][0-9]*)"
	arcs="$(grep -Eo "\|A\|=[1-9][0-9]*" output/$1/$f | grep -Eo [1-9][0-9]*)"

	seconds="$(grep -Eo "[0-9]+\.[0-9]+sec" output/$1/$f | grep -Eo "[0-9]+\.[0-9]+")"
	minutes="$(grep -Eo "[0-9]+m" output/$1/$f | grep -Eo "[0-9]+")"

        if [ ! -z "${places}" ]; then
			mininsecs=$((minutes*60))
			unfoldingtime=$(echo "$mininsecs + $seconds" | bc)

			echo "$f,$places,$transitions,$arcs,$unfoldingtime" > output/$1-stats/$f
        fi
done

