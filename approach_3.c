#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

#define MAX_N 10000000000ULL
#define MAX_THREADS 1024
#define BASE_SEED 12345U

struct task {
    unsigned long long count;
    unsigned long long k;
    unsigned int seed;
};

static unsigned long long g_inside = 0;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

double rand_unit(unsigned int *seed) {
    return 2.0 * rand_r(seed) / RAND_MAX - 1.0;
}

void *shared_count(void *arg){
    struct task *t = (struct task *) arg;
    unsigned int seed = t->seed;
    const unsigned long long count = t->count, k = t->k;
    unsigned long long i, pending = 0, cnt = k;
    double x, y;

    for (i = 0; i < count; i++) {
        x = rand_unit(&seed);
        y = rand_unit(&seed);
        if (x * x + y * y <= 1.0)
            pending++;
        if (--cnt == 0) {
            cnt = k;
            if (pending) {
                pthread_mutex_lock(&g_lock);
                g_inside += pending;
                pthread_mutex_unlock(&g_lock);
                pending = 0;
            }
        }
    }
    if (pending) {
        pthread_mutex_lock(&g_lock);
        g_inside += pending;
        pthread_mutex_unlock(&g_lock);
    }
    return NULL;
}

static void usage(const char *prog) {
    fprintf(stderr, "Usage: %s <num-threads> <n> [k]   (1 <= num-threads <= %d, 1 <= n <= %llu, k >= 1)\n",
            prog, MAX_THREADS, MAX_N);
}

int main(int argc, char *argv[]){
    char *end1, *end2, *end3;
    unsigned long long threads, n, k = 1;
    int p, i, created;
    pthread_t tid[MAX_THREADS];
    struct task tasks[MAX_THREADS];
    struct timespec start, stop;
    double elapsed, pi;

    if ((argc != 3 && argc != 4) || argv[1][0] < '0' || argv[1][0] > '9' || argv[2][0] < '0' || argv[2][0] > '9') {
        usage(argv[0]);
        return 1;
    }
    threads = strtoull(argv[1], &end1, 10);
    n = strtoull(argv[2], &end2, 10);
    if (argc == 4) {
        if (argv[3][0] < '0' || argv[3][0] > '9') {
            usage(argv[0]);
            return 1;
        }
        k = strtoull(argv[3], &end3, 10);
        if (*end3 != '\0' || k < 1) {
            usage(argv[0]);
            return 1;
        }
    }
    if (*end1 != '\0' || *end2 != '\0' || threads < 1 || threads > MAX_THREADS || n < 1 || n > MAX_N) {
        usage(argv[0]);
        return 1;
    }
    p = (int) threads;

    clock_gettime(CLOCK_MONOTONIC, &start);

    created = 0;
    for (i = 0; i < p; i++) {
        tasks[i].count = (i + 1) * n / p - i * n / p;
        tasks[i].k = k;
        tasks[i].seed = BASE_SEED + i;
        if (pthread_create(&tid[i], NULL, shared_count, &tasks[i]) != 0) {
            fprintf(stderr, "pthread_create failed\n");
            break;
        }
        created++;
    }

    for (i = 0; i < created; i++)
        pthread_join(tid[i], NULL);

    clock_gettime(CLOCK_MONOTONIC, &stop);

    if (created != p)
        return 1;

    elapsed = (stop.tv_sec - start.tv_sec) + (stop.tv_nsec - start.tv_nsec) / 1e9;
    pi = 4.0 * g_inside / n;

    printf("%d,%llu,%.6f,%.6f\n", p, n, pi, elapsed);
    return 0;
}
