#!/usr/bin/env bash
# run.sh — chạy toàn bộ thí nghiệm Lab 3 rồi vẽ đồ thị (Claude soạn)
# Cách dùng:  ./run.sh [N] [RUNS]
#   N    : số điểm mỗi lần chạy (mặc định 10^8)
#   RUNS : số lần chạy mỗi cấu hình (mặc định 5, đề yêu cầu >= 5)
set -e                                   # gặp lỗi là dừng ngay

N=${1:-100000000}
RUNS=${2:-5}
THREADS="1 2 4 8 16 32 64 128"
KS="1 10 100 1000 10000 100000"
CORES=$(nproc)
K_THREADS=$CORES                         # thí nghiệm 6.1: số thread = số core

cd "$(dirname "$0")"                     # luôn chạy trong thư mục chứa script

# ---- 0. Biên dịch ----
make -s all

# ---- Ghi lại cấu hình máy (đề: "document parameters") ----
{
    echo "date      : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "cpu       : $(lscpu | grep 'Model name' | sed 's/.*: *//')"
    echo "cores     : $CORES"
    echo "N         : $N"
    echo "runs      : $RUNS"
    echo "threads   : $THREADS"
    echo "k values  : $KS (threads = $K_THREADS)"
} > machine_info.txt
cat machine_info.txt
echo

# ---- 1. Approach 1: single thread ----
echo "[1/4] Approach 1 (single thread)"
echo "nPoints,pi,time" > result_1.csv
for i in $(seq $RUNS); do
    ./approach_1 $N >> result_1.csv
done

# ---- 2. Approach 2: local accumulation ----
echo "[2/4] Approach 2 (local accumulation)"
echo "threads,nPoints,pi,time" > result_2.csv
for t in $THREADS; do
    echo "      threads = $t"
    for i in $(seq $RUNS); do
        ./approach_2 $t $N >> result_2.csv
    done
done

# ---- 3. Approach 3: shared variable + mutex (k = 1) ----
echo "[3/4] Approach 3 (mutex, k = 1)"
echo "threads,nPoints,pi,time" > result_3.csv
for t in $THREADS; do
    echo "      threads = $t"
    for i in $(seq $RUNS); do
        ./approach_3 $t $N >> result_3.csv
    done
done

# ---- 4. Thí nghiệm 6.1: tần suất đồng bộ ----
echo "[4/4] Synchronization frequency (threads = $K_THREADS)"
echo "k,threads,nPoints,pi,time" > result_3_k.csv
for k in $KS; do
    echo "      k = $k"
    for i in $(seq $RUNS); do
        echo "$k,$(./approach_3 $K_THREADS $N $k)" >> result_3_k.csv
    done
done

# ---- 5. Vẽ đồ thị ----
echo
python3 plot.py
