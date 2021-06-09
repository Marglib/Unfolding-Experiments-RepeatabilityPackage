#!/bin/bash

if [[ -z "$1" ]] ; then
        echo "Missing test-folder"
        exit
fi

#Cleaning previous results
rm -rf "output"
rm -rf "answers"

N=1
F=$(basename ${1})
TO=60
TOVerify=5
let "M=$N*60" ;
let "m=$M*1024*1024"
ulimit -v $m

if [[ ! -d "../$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running unfolding and verification for A+B on folder $F"

properties=(ReachabilityCardinality ReachabilityFireability CTLCardinality CTLFireability LTLCardinality LTLFireability)

ODIR="output/A+B-unfolding-stdout"
BINDIR="output/A+B-verify-stdout"
mkdir -p $ODIR
mkdir -p $BINDIR

for t in ${properties[@]} ; do
	for i in $(ls ../$F ) ; do
		unfoldednet="../$F/$i/$i-tp-unfolded.pnml"
		unfoldedquery="../$F/$i/$t-tp-unfolded.xml"
		if [[ "$t" == "LTLCardinality" || "$t" == "LTLFireability" ]]; then
			timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/optimize-unfolding-272 -ltl -n -x 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 ../$F/$i/model.pnml ../$F/$i/${t}.xml --write-unfolded-queries $unfoldedquery --write-reduced $unfoldednet --noverify -q 0 -r 0 &> $ODIR/$i
		else
			timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/optimize-unfolding-272 -n -x 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 ../$F/$i/model.pnml ../$F/$i/${t}.xml --write-unfolded-queries $unfoldedquery --write-reduced $unfoldednet --noverify -q 0 -r 0 &> $ODIR/$i
		fi

		./run_queries.sh $unfoldednet $unfoldedquery $i $t $BINDIR

		if [[ ! "$2" == "Savemodels" ]]; then
			rm $unfoldednet
			rm $unfoldedquery
		else
			zip -m -j $unfoldednet.zip $unfoldednet
			zip -m -j $unfoldedquery.zip $unfoldedquery
		fi
	done 
done

./gather_answers.sh A+B-verify-stdout

#----------------------------------------------

echo "Running unfolding and verification for MCC on folder $F"

BINDIR="output/MCC-verify-stdout"
mkdir -p $BINDIR

for i in $(ls ../$F ) ; do
	unfoldednet="../$F/$i/$i-mcc-unfolded"
    timeout ${TO}m ../binaries/mcc pnml -i ../$F/$i/model.pnml -o $unfoldednet &> ../$F/$i/$i-dict 
	
	for t in ${properties[@]} ; do
		unfoldedquery=../$F/$i/${t}-mcc-unfolded.xml
		timeout ${TO}m python3 QueryUnfolder.py -u ../$F/$i/$i-dict -q ../$F/$i/${t}.xml -o $unfoldedquery

		./run_queries.sh $unfoldednet.pnml $unfoldedquery $i $t $BINDIR

		if [[ ! "$2" == "Savemodels" ]]; then
			rm $unfoldedquery
		else
			zip -m -j $unfoldedquery.zip $unfoldedquery
		fi
	done
	if [[ ! "$2" == "Savemodels" ]]; then
		rm $unfoldednet.pnml
		rm ../$F/$i/$i-dict 
	else
		zip -m -j $unfoldednet.pnml.zip $unfoldednet.pnml
		zip -m -j ../$F/$i/$i-dict.zip ../$F/$i/$i-dict 
	fi
done

./gather_answers.sh MCC-verify-stdout

#----------------------------------------------

echo "Running ITS on $F with a timeout of $TO minutes for each net"

ODIR="output/ITS-unfolding-stdout"
BINDIR="output/ITS-verify-stdout"
mkdir -p $ODIR
mkdir -p $BINDIR

for t in ${properties[@]} ; do
	for i in $(ls ../$F ) ; do
		unfoldednet="../$F/$i/model.sr.pnml"
     	unfoldedquery="../$F/$i/$t.sr.xml"
		timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/ITS-Tools/its-tools -pnfolder ../$F/$i -examination $t --unfold &> $ODIR/$i
		
		./run_queries.sh $unfoldednet $unfoldedquery $i $t $BINDIR

		if [[ ! "$2" == "Savemodels" ]]; then
			rm $unfoldednet
			rm $unfoldedquery
		else
			zip -m -j $unfoldednet.zip $unfoldednet
			zip -m -j $unfoldedquery.zip $unfoldedquery
		fi
	done 
done

./gather_answers.sh ITS-verify-stdout

#----------------------------------------------

echo "---------------------------------"
echo "FINAL STATS:"
echo "---------------------------------"

echo "ReachabilityCardinality:"
AB=$(cat answers/A+B-verify-stdout.ReachabilityCardinality | wc -l)
ITS=$(cat answers/ITS-verify-stdout.ReachabilityCardinality | wc -l)
MCC=$(cat answers/MCC-verify-stdout.ReachabilityCardinality | wc -l)
echo "A+B: $AB"
echo "ITS: $ITS"
echo "MCC: $MCC"

echo "ReachabilityFireability:"
AB=$(cat answers/A+B-verify-stdout.ReachabilityFireability | wc -l)
ITS=$(cat answers/ITS-verify-stdout.ReachabilityFireability | wc -l)
MCC=$(cat answers/MCC-verify-stdout.ReachabilityFireability | wc -l)
echo "A+B: $AB"
echo "ITS: $ITS"
echo "MCC: $MCC"

echo "CTLCardinality:"
AB=$(cat answers/A+B-verify-stdout.CTLCardinality | wc -l)
ITS=$(cat answers/ITS-verify-stdout.CTLCardinality | wc -l)
MCC=$(cat answers/MCC-verify-stdout.CTLCardinality | wc -l)
echo "A+B: $AB"
echo "ITS: $ITS"
echo "MCC: $MCC"

echo "CTLFireability:"
AB=$(cat answers/A+B-verify-stdout.CTLFireability | wc -l)
ITS=$(cat answers/ITS-verify-stdout.CTLFireability | wc -l)
MCC=$(cat answers/MCC-verify-stdout.CTLFireability | wc -l)
echo "A+B: $AB"
echo "ITS: $ITS"
echo "MCC: $MCC"

echo "LTLCardinality:"
AB=$(cat answers/A+B-verify-stdout.LTLCardinality | wc -l)
ITS=$(cat answers/ITS-verify-stdout.LTLCardinality | wc -l)
MCC=$(cat answers/MCC-verify-stdout.LTLCardinality | wc -l)
echo "A+B: $AB"
echo "ITS: $ITS"
echo "MCC: $MCC"

echo "LTLFireability:"
AB=$(cat answers/A+B-verify-stdout.LTLFireability | wc -l)
ITS=$(cat answers/ITS-verify-stdout.LTLFireability | wc -l)
MCC=$(cat answers/MCC-verify-stdout.LTLFireability | wc -l)
echo "A+B: $AB"
echo "ITS: $ITS"
echo "MCC: $MCC"

echo "---------------------------------"

echo "The full results can be seen in the answers folder"


