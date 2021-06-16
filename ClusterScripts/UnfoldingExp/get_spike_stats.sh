#!/bin/bash


mkdir -p "answers/$1"

for f in $(ls output/MCC2020-COL/$1 ) ; do
        echo "Gathering stats for $f"

	places="$(grep -Eo "\|P\|=[1-9][0-9]*" output/MCC2020-COL/$1/$f | grep -Eo [1-9][0-9]*)"
	transitions="$(grep -Eo "\|T\|=[1-9][0-9]*" output/MCC2020-COL/$1/$f | grep -Eo [1-9][0-9]*)"
	arcs="$(grep -Eo "\|A\|=[1-9][0-9]*" output/MCC2020-COL/$1/$f | grep -Eo [1-9][0-9]*)"

     	seconds="$(grep -Eo "[0-9]+\.[0-9]+sec" output/MCC2020-COL/$1/$f | grep -Eo "[0-9]+\.[0-9]+")"
	minutes="$(grep -Eo "[0-9]+m" output/MCC2020-COL/$1/$f | grep -Eo "[0-9]+")"

        if [ ! -z "${places}" ]; then
		mininsecs=$((minutes*60))
		unfoldingtime=$(echo "$mininsecs + $seconds" | bc)

		echo "$f,$places,$transitions,$arcs,$unfoldingtime"
                echo "$f,$places,$transitions,$arcs,$unfoldingtime" > answers/$1/$f
        fi
done

