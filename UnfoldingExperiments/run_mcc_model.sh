#!/bin/bash

let "m=$3*1024*1024"
ulimit -v $m

CMD=$(echo $1 | sed -e "s/SLURM_ARRAY_TASK_ID/$i/g")
OUT=$(echo $2 | sed -e "s/SLURM_ARRAY_TASK_ID/$i/g")

echo "$CMD &> $OUT" 
timeout ${4}m /usr/bin/time -f "@@@%e,%M@@@" $CMD &> $OUT

exit 0
