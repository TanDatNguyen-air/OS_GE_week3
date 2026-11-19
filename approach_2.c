#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

#define MAX_N 10000000000ULL
#define MAX_THREADS 1024
#define BASE_SEED 12345U

struct task {
    unsigned long long count;
    unsigned int seed;
    unsigned long long partial;
};

double rand_unit(unsigned int *seed) {
    return 2.0 * rand_r(seed) / RAND_MAX - 1.0;
}

void *partial_count(void *arg){
    struct task *t = (struct task *) arg;
    unsigned int seed = t->seed;
    unsigned long long k, s = 0;
    double x, y;

    for (k = 0; k < t->count; k++) {
        x = rand_unit(&seed);
        y = rand_unit(&seed);
        if (x * x + y * y <= 1.0)
            s++;
    }
    t->partial = s;
    return NULL;
}

int main(int argc, char *argv[]){
    char *end1, *end2;
    unsigned long long threads, n, inside;
    int p, i, created;
    pthread_t tid[MAX_THREADS];
    struct task tasks[MAX_THREADS];
    struct timespec start, stop;
    double elapsed, pi;

    if (argc != 3 || argv[1][0] < '0' || argv[1][0] > '9' || argv[2][0] < '0' || argv[2][0] > '9') {
        fprintf(stderr, "Usage: %s <num-threads> <n>   (1 <= num-threads <= %d, 1 <= n <= %llu)\n",
                argv[0], MAX_THREADS, MAX_N);
        return 1;
    }
    threads = strtoull(argv[1], &end1, 10);
    n = strtoull(argv[2], &end2, 10);
    if (*end1 != '\0' || *end2 != '\0' || threads < 1 || threads > MAX_THREADS || n < 1 || n > MAX_N) {
        fprintf(stderr, "Usage: %s <num-threads> <n>   (1 <= num-threads <= %d, 1 <= n <= %llu)\n",
                argv[0], MAX_THREADS, MAX_N);
        return 1;
    }
    p = (int) threads;

    clock_gettime(CLOCK_MONOTONIC, &start);

    created = 0;
    for (i = 0; i < p; i++) {
        tasks[i].count = (i + 1) * n / p - i * n / p;
        tasks[i].seed = BASE_SEED + i;
        tasks[i].partial = 0;
        if (pthread_create(&tid[i], NULL, partial_count, &tasks[i]) != 0) {
            fprintf(stderr, "pthread_create failed\n");
            break;
        }
        created++;
    }

    inside = 0;
    for (i = 0; i < created; i++) {
        pthread_join(tid[i], NULL);
        inside += tasks[i].partial;
    }

    clock_gettime(CLOCK_MONOTONIC, &stop);

    if (created != p)
        return 1;

    elapsed = (stop.tv_sec - start.tv_sec) + (stop.tv_nsec - start.tv_nsec) / 1e9;
    pi = 4.0 * inside / n;

    printf("%d,%llu,%.6f,%.6f\n", p, n, pi, elapsed);
    return 0;
}
