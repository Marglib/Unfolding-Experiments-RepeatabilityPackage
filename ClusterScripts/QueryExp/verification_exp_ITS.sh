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

ODIR="output/$F/its-$BIN-DFS"
mkdir -p $ODIR
for t in ${properties[@]} ; do
    for i in $(ls $F ) ; do
        let "M=$N*15" ;
	unzippedmodel="temp/$t/$F/$i/model.sr.pnml"
        unzippedquery="temp/$t/$F/$i/$t.sr.xml"
        sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G"  ./run_its_queries.sh "$BIN -s DFS -n -x SLURM_ARRAY_TASK_ID $unzippedmodel $unzippedquery" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}"  $M $TO $F $i $t
    done
done

properties=(LTLFireability LTLCardinality)

for t in ${properties[@]} ; do
    for i in $(ls $F ) ; do
        let "M=$N*15" ;
	unzippedmodel="temp/$t/$F/$i/model.sr.pnml"
        unzippedquery="temp/$t/$F/$i/$t.sr.xml"
        sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G"  ./run_its_queries.sh "$BIN -s DFS -ltl -n -x SLURM_ARRAY_TASK_ID $unzippedmodel $unzippedquery" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}"  $M $TO $F $i $t
    done
done


