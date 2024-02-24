
#include "pthreadLocks.h"

static int is_initialized = 0;
static pthread_mutex_t mutex;

// return value:
// -1: error
//  0: initialized
int pthread_locks_init(void) {
    int ret = pthread_mutex_init(&mutex, NULL);
    if (ret < 0) perror("init pthread_mutex_init");
    else is_initialized = 1;
    return ret;
}

// return value:
// -1: error
//  0: initialized
int pthread_locks_deinit(void) {
    is_initialized = 0;
    int ret = pthread_mutex_destroy(&mutex);
    if (ret < 0) perror("init pthread_locks_deinit");
    return ret;
}

// return value:
// -1: error
//  0: locked
int pthread_locks_lock(void) {
    if (!is_initialized) return -1;
    int ret = pthread_mutex_lock(&mutex);
    if (ret < 0) perror("pthread_mutex_lock");
    return ret;
}

// return value:
// -1: error
//  0: locked
//  1: busy
int pthread_locks_trylock(void) {
    if (!is_initialized) return -1;
    int ret = pthread_mutex_trylock(&mutex);
    if (ret < 0) {
        if (errno == EBUSY) return 1;
        perror("pthread_mutex_trylock");
    }
    return ret;
}

// return value:
// -1: error
//  0: unlocked
int pthread_locks_unlock(void) {
    if (!is_initialized) return -1;
    int ret = pthread_mutex_unlock(&mutex);
    if (ret < 0) perror("pthread_mutex_unlock");
    return ret;
}
