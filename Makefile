# Makefile — Lab 3: Monte Carlo pi (Claude soạn)
CC      = gcc
CFLAGS  = -O2 -Wall
LDFLAGS = -pthread

TARGETS = approach_1 approach_2 approach_3

.PHONY: all run plot clean distclean

# make        -> biên dịch cả 3 chương trình
all: $(TARGETS)

approach_1: approach_1.c
	$(CC) $(CFLAGS) -o $@ $<

approach_2: approach_2.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

approach_3: approach_3.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

# make run    -> biên dịch + chạy toàn bộ benchmark + vẽ đồ thị
run: all
	bash run.sh

# make plot   -> chỉ vẽ lại đồ thị từ các file CSV đã có
plot:
	python3 plot.py

# make clean  -> xóa file thực thi
clean:
	rm -f $(TARGETS)

# make distclean -> xóa cả file thực thi, số liệu và đồ thị
distclean: clean
	rm -f result_*.csv summary.csv *.png
