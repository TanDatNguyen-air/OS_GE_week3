#!/usr/bin/env bash
N=${1:-100000000}
RUNS=${2:-5}
THREADS="1 2 4 8 16 32 64 128"
KS="1 10 100 1000 10000 100000"
CORES=$(nproc)
K_THREADS=$CORES                         
cd "$(dirname "$0")"                     

make -s all


echo "Approach 1 (single thread)"
echo "nPoints,pi,time" > result_1.csv
for i in $(seq $RUNS); do
    ./approach_1 $N >> result_1.csv
done

echo "Approach 2 (local accumulation)"
echo "threads,nPoints,pi,time" > result_2.csv
for t in $THREADS; do
    echo "      threads = $t"
    for i in $(seq $RUNS); do
        ./approach_2 $t $N >> result_2.csv
    done
done

echo "Approach 3 (mutex, k = 1)"
echo "threads,nPoints,pi,time" > result_3.csv
for t in $THREADS; do
    echo "      threads = $t"
    for i in $(seq $RUNS); do
        ./approach_3 $t $N >> result_3.csv
    done
done

echo "Synchronization frequency (threads = $K_THREADS)"
echo "k,threads,nPoints,pi,time" > result_3_k.csv
for k in $KS; do
    echo "      k = $k"
    for i in $(seq $RUNS); do
        echo "$k,$(./approach_3 $K_THREADS $N $k)" >> result_3_k.csv
    done
done

echo
python3 plot.py
