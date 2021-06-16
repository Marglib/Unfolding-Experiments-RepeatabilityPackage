#!/bin/bash

if [[ -z "$2" ]] ; then
        echo "Missing folder"
        exit
fi

if [[ -z "$1" ]] ; then
        echo "Missing binary"
        exit
fi

BIN="$1";
N=1
F=$(basename ${2})
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

BINDIR="output/$F/its-tools"
mkdir -p $BINDIR
for t in ${properties[@]} ; do
   for i in $(ls $F ) ; do
      let "M=$N*60" ;
      unfoldedmodel="$F/$i/model.sr.pnml"
      unfoldedquery="$F/$i/$t.sr.xml"
      sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G" ./run_its_model.sh "$BIN -pnfolder $F/$i -examination $t --unfold" "$BINDIR/$i-$t" $M $TO $unfoldedmodel $unfoldedquery 
   done
done
