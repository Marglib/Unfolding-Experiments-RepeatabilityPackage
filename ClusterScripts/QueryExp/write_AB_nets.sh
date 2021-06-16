#!/bin/bash

if [[ -z "$2" ]] ; then
        echo "Missing test-folder"
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

if [[ ! -z "$3" ]] ; then
        TO="$3"
fi

if [[ ! -f "$BIN" ]] ; then
        echo "$BIN is not a file"
        exit
fi

if [[ ! -d "$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running $BIN on $F with a timeout of $TO minutes"

properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability)
LTLproperties=(LTLCardinality LTLFireability)

ODIR="output/$F/$BIN-A+B"
BINDIR="$BIN-A+B"
mkdir -p $ODIR
for t in ${properties[@]} ; do
    for i in $(ls $F ) ; do
        let "M=$N*60" ;
	unfoldednet="$F/$i/$i-tp-unfolded.pnml"
	unfoldedquery="$F/$i/$t-tp-unfolded.xml"
        sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G" ./run_AB_model.sh "$BIN -n -x 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 $F/$i/model.pnml $F/$i/${t}.xml --write-unfolded-queries $unfoldedquery --write-reduced $unfoldednet --noverify -q 0 -r 0"  $M $TO $unfoldednet $unfoldedquery
    done
done

for t in ${LTLproperties[@]} ; do
    for i in $(ls $F ) ; do
        let "M=$N*60" ;
	unfoldednet="$F/$i/$i-tp-unfolded.pnml"
	unfoldedquery="$F/$i/$t-tp-unfolded.xml"
        sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G" ./run_AB_model.sh "$BIN -ltl -n -x 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 $F/$i/model.pnml $F/$i/${t}.xml --write-unfolded-queries $unfoldedquery --write-reduced $unfoldednet --noverify -q 0 -r 0"  $M $TO $unfoldednet $unfoldedquery
    done
done
