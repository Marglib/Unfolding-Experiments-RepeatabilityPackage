#!/bin/bash

if [[ -z "$1" ]] ; then
        echo "Missing folder"
        exit
fi


BIN="$1";
N=1
F=$(basename ${1})
TO=60

if [[ ! -z "$2" ]] ; then
        TO="$2"
fi

if [[ ! -d "$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running its-tools on $F with a timeout of $TO minutes"

properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability LTLCardinality LTLFireability)

BINDIR="output/its-tools"
mkdir -p $BINDIR
for t in ${properties[@]} ; do
   for i in $(ls $F ) ; do
      let "M=$N*15" ;
      unfoldedmodel="$F/$i/model.sr.pnml"
      unfoldedquery="$F/$i/$t.sr.xml"
      CMD=$(./run_model.sh "ITS-Tools/its-tools -pnfolder $F/$i -examination $t --unfold" "$BINDIR/$i-$t" $M $TO $unfoldedmodel $unfoldedquery)
      echo "$CMD"
   done
done

echo "./get_its_results.sh its-tools"
echo "python3 read_its_results.py"

