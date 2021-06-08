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
let "M=$N*15" ;

if [[ ! -z "$4" ]] ; then
        TO="$4"
fi

if [[ ! -f "binaries/$BIN" ]] ; then
        echo "$BIN is not a file"
        exit
fi

if [[ ! -d "../$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running $BIN on $F with a timeout of $TO minutes"

if [[$3 = "A+B"]] ; then
    properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability)

    ODIR="output/$BIN-unfolding-stdout"
    BINDIR="output/$BIN-unfolding-stats"
    mkdir -p $ODIR
    mkdir -p $BINDIR

    for t in ${properties[@]} ; do
        for i in $(ls ../$F ) ; do
            unfoldednet="$F/$i/$i-tp-unfolded.pnml"
            unfoldedquery="$F/$i/$t-tp-unfolded.xml"
            CMD=$(./run_model.sh "../binaries/optimize-unfolding-268 -n -x 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 ../$F/$i/model.pnml ../$F/$i/${t}.xml --write-simplified $unfoldedquery --write-reduced $unfoldednet --output-stats $BINDIR --noverify -q 0 -r 0" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}"  $M $TO $unfoldednet $unfoldedquery)
            echo "$CMD"
        done 
    done

    LTLproperties=(LTLCardinality LTLFireability)

    for t in ${LTLproperties[@]} ; do
        for i in $(ls ../$F ) ; do
            unfoldednet="$F/$i/$i-tp-unfolded.pnml"
            unfoldedquery="$F/$i/$t-tp-unfolded.xml"
            CMD=$(./run_model.sh "binaries/$BIN -n -ltl -x 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 ../$F/$i/model.pnml ../$F/$i/${t}.xml --write-simplified $unfoldedquery --write-reduced $unfoldednet --output-stats $BINDIR --noverify -q 0 -r 0" "$ODIR/${i}.QSLURM_ARRAY_TASK_ID.${t}"  $M $TO $unfoldednet $unfoldedquery)
            echo "$CMD"
        done
    done