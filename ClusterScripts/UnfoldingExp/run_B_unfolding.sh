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
TO=5

if [[ ! -z "$3" ]] ; then
        TO="$3'"
fi

if [[ ! -f "binaries/$BIN" ]] ; then
        echo "$BIN is not a file"
        exit
fi

if [[ ! -d "$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running $BIN on $F with a timeout of $TO minutes"

for S in DFS ; do

ODIR="output/$F/$BIN-A"
BINDIR="$BIN-A"
mkdir -p $ODIR
mkdir -p $BINDIR
for i in $(ls $F ) ; do
        let "M=$N*15" ;
        sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G" ./run_model.sh "$BIN -s $S -n -x 1 ./$F/$i/model.pnml ./$F/$i/ReachabilityCardinality.xml --output-stats $BINDIR --noverify --disable-partitioning" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}" $M $TO
done
done


