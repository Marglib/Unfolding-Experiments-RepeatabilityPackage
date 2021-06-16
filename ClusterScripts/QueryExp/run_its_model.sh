#!/bin/bash
#SBATCH --time=17:00:00
#SBATCH --mail-type=FAIL
#SBATCH --partition=naples

let "m=$3*1024*1024"
ulimit -v $m

export JAVA_HOME=/nfs/home/student.aau.dk/abkr16/MCC/binaries/java-11-openjdk-amd64/
export PATH=$JAVA_HOME/bin:$PATH

CMD=$(echo $1 | sed -e "s/SLURM_ARRAY_TASK_ID/$i/g")
OUT=$(echo $2 | sed -e "s/SLURM_ARRAY_TASK_ID/$i/g")

echo "$CMD &> $OUT" 
timeout ${4}m /usr/bin/time -f "@@@%e,%M@@@" $CMD &> $OUT


zip -m $5.zip $5
zip -m $6.zip $6

exit 0

