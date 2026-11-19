CC      = gcc
CFLAGS  = -O2 -Wall
LDFLAGS = -pthread

TARGETS = approach_1 approach_2 approach_3

.PHONY: all run plot clean distclean

all: $(TARGETS)

approach_1: approach_1.c
	$(CC) $(CFLAGS) -o $@ $<

approach_2: approach_2.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

approach_3: approach_3.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

run: all
	bash run.sh

plot:
	python3 plot.py

clean:
	rm -f $(TARGETS)

distclean: clean
	rm -f result_*.csv summary.csv *.png
