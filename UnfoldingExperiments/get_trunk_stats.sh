#!/bin/bash

mkdir -p "output/$1-stats"

for f in $(ls output/$1 ) ; do
    places="$(grep "Size of unfolded net:" output/$1/$f -a | grep -oP '(?<=: ).*(?= places)')"
	transitions="$(grep "Size of unfolded net:" output/$1/$f -a | grep -oP '(?<=places, ).*(?= transitions)')"
    arcs="$(grep "Size of unfolded net:" output/$1/$f -a | grep -oP '(?<=:and ).*(?= arcs)')"
    unfoldingtime="$(grep "Unfolded in " output/$1/$f -a | grep -oP '(?<=in ).*(?= seconds)')"

	if [ ! -z "${places}" ]; then
		echo "$f,$places,$transitions,$arcs,$unfoldingtime" > output/$1-stats/$f
	fi
done

