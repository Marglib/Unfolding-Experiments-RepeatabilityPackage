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

ODIR="output/$F/$BIN"
BINDIR="$BIN-combined"
mkdir -p $ODIR
mkdir -p $BINDIR
for t in Reachability{Cardinality,Fireability} ; do
    for i in $(ls $F ) ; do
        let "M=$N*60" ;
        echo "binaries/$BIN  -n -x SLURM_ARRAY_TASK_ID ./$F/$i/model.pnml ./$F/$i/${t}.xml --output-stats $BINDIR" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}"  $M $TO

        sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G" ./run_tests.sh "binaries/$BIN  -n -x SLURM_ARRAY_TASK_ID ./$F/$i/model.pnml ./$F/$i/${t}.xml --output-stats $BINDIR" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}"  $M $TO
    done
done


