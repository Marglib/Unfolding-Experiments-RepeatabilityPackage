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

if [[ ! -f "binaries/$BIN" ]] ; then
        echo "$BIN is not a file"
        exit
fi

if [[ ! -d "$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running $BIN on $F with a timeout of $TO minutes"

for i in $(ls $F ) ; do
   let "M=$N*15" ;
   outfilename="$F/$i/$i-mcc-unfolded"
   ./run_mcc_model.sh "binaries/$BIN pnml -i ./$F/$i/model.pnml -o $outfilename" "$F/$i/$i-dict" $M $TO $outfilename.pnml
done

