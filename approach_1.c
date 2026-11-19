#include <stdio.h>
#include <stdlib.h>
#include <time.h>

double rand_unit(unsigned int *seed) {
    return 2.0 * rand_r(seed) / RAND_MAX - 1.0;
}

int main(int argc, char *argv[]) {
    long long nPoints = (argc > 1) ? atoll(argv[1]) : 10000000LL;

    unsigned int seed = 12345;
    long long inside = 0;
    struct timespec start, end;

    clock_gettime(CLOCK_MONOTONIC, &start);
    for (long long i = 0; i < nPoints; i++) {
        double x = rand_unit(&seed);
        double y = rand_unit(&seed);
        if (x * x + y * y <= 1.0) inside++;
    }
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    double result = 4.0 * inside / nPoints;

    printf("%lld,%.6f,%.6f\n", nPoints, result, elapsed);
    return 0;
}