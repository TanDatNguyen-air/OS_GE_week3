#!/usr/bin/env bash
N=100000000
RUNS=5
THREADS="1 2 4 8 16 32 64 128"

gcc -O2 -Wall -o approach_1 approach_1.c || exit 1
gcc -O2 -Wall -pthread -o approach_2 approach_2.c || exit 1
gcc -O2 -Wall -pthread -o approach_3 approach_3.c || exit 1

echo "nPoints,pi,time" > result_1.csv
for i in $(seq $RUNS); do
    ./approach_1 $N >> result_1.csv
done
cat result_1.csv
echo

echo "threads,nPoints,pi,time" > result_2.csv
for t in $THREADS; do
    for i in $(seq $RUNS); do
        ./approach_2 $t $N >> result_2.csv
    done
done
cat result_2.csv
echo

echo "threads,nPoints,pi,time" > result_3.csv
for t in $THREADS; do
    for i in $(seq $RUNS); do
        ./approach_3 $t $N >> result_3.csv
    done
done
cat result_3.csv
echo

echo "k,threads,nPoints,pi,time" > result_3_k.csv
for k in 1 10 100 1000 10000 100000; do
    for i in $(seq $RUNS); do
        echo "$k,$(./approach_3 8 $N $k)" >> result_3_k.csv
    done
done
cat result_3_k.csv
