#!/bin/bash


mkdir -p "output/$1-stats"
for f in $(ls output/$1 ) ; do
        #echo "Gathering stats for $f"

        nameclean="$(grep "Running its-tools with arguments" output/$1/$f -a | grep -oP '(?<=/).*(?=, -examination)')"

        #exam="$(grep "Running its-tools with arguments" output/$1/$f -a | grep -oP '(?<=-examination, ).*(?=, --unfold)')"
        name="$nameclean"

        places="$(grep -Eo "with [1-9][0-9]* places" output/$1/$f -a | grep -Eo [1-9][0-9]*)"
        rmplaces="$(grep -Eo "removed [1-9][0-9]* places" output/$1/$f -a | grep -Eo [1-9][0-9]*)"

        if [[ ! -z ${rmplaces} ]] ; then
                psum=0
                for i in $rmplaces ; do
                        ((psum+=i))
                done
                endplaces=$((places-psum))
        else
                endplaces=$((places))
        fi

        transitions="$(grep -Eo "and [1-9][0-9]* transitions " output/$1/$f -a | grep -Eo [1-9][0-9]*)"
        rmtransitions="$(grep -Eo "and [1-9][0-9]* transitions\." output/$1/$f -a | grep -Eo [1-9][0-9]*)"

        if [[ ! -z ${rmtransitions} ]] ; then
                tsum=0
                for i in $rmtransitions ; do
                        ((tsum+=i))
                done
                endtransitions=$((transitions-tsum))
        else
                endtransitions=$((transitions))
        fi
        unfoldingtime="$(grep -Eo "arcs in [1-9][0-9]* ms" output/$1/$f -a | grep -Eo [1-9][0-9]*)"
        reductiontime="$(grep -Eo "places in [1-9][0-9]* ms" output/$1/$f -a | grep -Eo [1-9][0-9]*)"

        if [ ! -z "${places}" ]; then
                endtransitions=$((transitions-tsum))
                fulltime=0

                if [ -z "${reductiontime}" ]; then
                        fulltime=$((unfoldingtime))
                else
                        fulltime=$((unfoldingtime+reductiontime))
                fi
                echo "$name,$places,$psum,$endplaces,$transitions,$tsum,$endtransitions,$unfoldingtime,$reductiontime,$fulltime" > output/$1-stats/$f
        fi
done
