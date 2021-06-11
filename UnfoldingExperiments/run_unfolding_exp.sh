#!/bin/bash

if [[ -z "$1" ]] ; then
        echo "Missing test-folder"
        exit
fi

#Cleaning previous results
rm -rf "output"

N=1
F=$(basename ${1})
TO=5
let "M=$N*15" ;
let "m=$M*1024*1024"
ulimit -v $m

if [[ ! -z "$2" ]] ; then
        TO="$2"
fi

if [[ ! -d "../$F" ]] ; then
        echo "$F is not a folder"
        exit
fi

echo "Running A+B on $F with a timeout of $TO minutes for each net"


ODIR="output/A+B-unfolding-stdout"
BINDIR="output/A+B-unfolding-stats"
mkdir -p $ODIR
mkdir -p $BINDIR

for i in $(ls ../$F ) ; do
    timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/optimize-unfolding-272 -n -x 1 ../$F/$i/model.pnml ../$F/$i/ReachabilityCardinality.xml --output-stats output/A+B-unfolding-stats  --noverify &> $ODIR/$i
done 

python3 read_AB_results.py --binary output/A+B-unfolding-stats --output A+B-unfolding-results

#----------------------------------------------

echo "Running MCC on $F with a timeout of $TO minutes for each net"

BINDIR="output/mcc-linux"
mkdir -p $BINDIR
for i in $(ls ../$F ) ; do
    timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/mcc hlnet -i ../$F/$i/model.pnml --stats &> $BINDIR/$i 
done

python3 read_mcc_results.py

#----------------------------------------------

echo "Running ITS on $F with a timeout of $TO minutes for each net"

BINDIR="output/its-tools"
mkdir -p $BINDIR
for i in $(ls ../$F ) ; do 
    timeout ${TO}m /usr/bin/time -f @@@%e,%M@@@ ../binaries/ITS-Tools/its-tools -pnfolder ../$F/$i -examination ReachabilityCardinality --unfold &> $BINDIR/$i 
    rm "../$F/$i/model.sr.pnml"
    rm "../$F/$i/ReachabilityCardinality.sr.xml"
done

./get_its_stats.sh its-tools
python3 read_its_results.py

#----------------------------------------------

echo "Running Spike on $F with a timeout of $TO minutes for each net"

BINDIR="output/spike"
mkdir -p $BINDIR
for i in $(ls ../$F ) ; do
    timeout ${TO}m /usr/bin/time -f @@@%e,%M@@@ ../binaries/spike-1.6.0rc1-linux64 load -f=../$F/$i/model.pnml unfold &> $BINDIR/$i 
done

./get_spike_stats.sh spike
python3 read_spike_trunk_results.py --binary output/spike-stats --output spike-unfolding-results

rm -rf "logs"

#----------------------------------------------

echo "Running A on $F with a timeout of $TO minutes for each net"

ODIR="output/A-unfolding-stdout"
BINDIR="output/A-unfolding-stats"
mkdir -p $ODIR
mkdir -p $BINDIR

for i in $(ls ../$F ) ; do
    timeout ${TO}m /usr/bin/time -f "@@@%e,%M@@@" ../binaries/optimize-unfolding-272 -n -x 1 ../$F/$i/model.pnml ../$F/$i/ReachabilityCardinality.xml --output-stats $BINDIR --noverify --disable-cfp &> $ODIR/$i 
done 

python3 read_AB_results.py --binary output/A-unfolding-stats --output A-unfolding-results


#----------------------------------------------

echo "Running B on $F with a timeout of $TO minutes for each net"

ODIR="output/B-unfolding-stdout"
BINDIR="output/B-unfolding-stats"
mkdir -p $ODIR
mkdir -p $BINDIR

for i in $(ls ../$F ) ; do
    timeout ${TO}m /usr/bin/time -f @@@%e,%M@@@ ../binaries/optimize-unfolding-272 -n -x 1 ../$F/$i/model.pnml ../$F/$i/ReachabilityCardinality.xml --output-stats $BINDIR --noverify --disable-partitioning &> $ODIR/$i 
done 

python3 read_AB_results.py --binary output/B-unfolding-stats --output B-unfolding-results

#----------------------------------------------

echo "Running trunk-226 on $F with a timeout of $TO minutes for each net"

ODIR="output/trunk-226"
mkdir -p $ODIR

for i in $(ls ../$F ) ; do
    timeout ${TO}m /usr/bin/time -f @@@%e,%M@@@ ../binaries/trunk-226 -x 1 ../$F/$i/model.pnml ../$F/$i/ReachabilityCardinality.xml &> $ODIR/$i 
done 

./get_trunk_stats.sh trunk-226
python3 read_spike_trunk_results.py --binary output/trunk-226-stats --output Spike-unfolding-results

#----------------------------------------------

echo "Creating cactus plots from results"

python3 ../cactus_plot.py -f ../results -d -s -n 200 -o ../results/sizegraph.png
python3 ../cactus_plot.py -f ../results -d -t -w -p ../results/timegraph.png

