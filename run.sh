gcc -O2 -Wall -o approach_1 approach_1.c

echo "nPoints,pi,time" > result_1.csv
for i in 1 2 3 4 5; do
    ./approach_1 100000000 >> result_1.csv
done
cat result_1.csv
echo

gcc -O2 -Wall -pthread -o approach_2 approach_2.c

echo "threads,nPoints,pi,time" > result_2.csv
for t in 1 2 4 8 16 32 64 128; do
    for i in 1 2 3 4 5; do
        ./approach_2 $t 100000000 >> result_2.csv
    done
done
cat result_2.csv
