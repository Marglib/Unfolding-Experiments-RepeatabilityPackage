#!/bin/bash

if [[ -z "$1" ]] ; then
        echo "Missing test model"
        exit
fi


N=1
F=$(basename ${1})
TO=60

if [[ ! -d "$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running python script on $F"

properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability LTLCardinality LTLFireability)

ODIR="output/$F/mcc-query-unfolding"
mkdir -p $ODIR

for t in ${properties[@]} ; do
    for i in $(ls $F ) ; do	   
	  let "M=$N*60" ;
	  unfoldedq=$F/$i/${t}-mcc-unfolded.xml
          sbatch --mail-user=$(whoami)  -n 1 -c $N --mem="${M}G" ./unfold_single_q.sh "python3 QueryUnfolder.py -u ./$F/$i/$i-dict -q ./$F/$i/${t}.xml -o $unfoldedq" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}" $M $TO $unfoldedq
    done
done


