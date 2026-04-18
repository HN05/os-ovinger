#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user.h"
#include <stddef.h>
#include "uthread.h"
#define LIB_PREFIX "[UTHREAD]: "
#define ulog() printf("%s%s\n", LIB_PREFIX, __FUNCTION__)

// all threads start executing here
static void tentry()
{
    struct thread *thread = tpool[thread_index];

    // run the func
    void *ret = thread->func(thread->arg);
    
    thread->res = ret;

    thread->state = EXITED;
    tsched();

    // all finished
    int *result = tpool[0]->res;
    exit(*result);
}

void tsched()
{
    struct thread *oldt = tpool[thread_index];

    int next = -1;
    for (int i = 1; i <= MAX_THREADS; i++) {
        int index = (i + thread_index) % MAX_THREADS;
        if (tpool[index] && tpool[index]->state == RUNNABLE) {
            next = index;
            break;
        }
    }

    if (next == -1) {
        return;
    }

    if (next == thread_index) {
        return;
    }

    struct thread *nextt = tpool[next];

    thread_index = next;
    tswtch(&oldt->tcontext, &nextt->tcontext);

    // TODO: Implement a userspace round robin scheduler that switches to the next thread
}

void tcreate(struct thread **thread, struct thread_attr *attr, void *(*func)(void *arg), void *arg)
{
    // find location
    int tid = -1;
    for (int i = 0; i < MAX_THREADS; i++) {
        if (tpool[i] && tpool[i]->state != UNUSED) continue;
        tid = i;
        break;
    }
    if (tid == -1) return;

    struct thread *cthread = tpool[tid]; 
    if (!cthread) {
        cthread = malloc(sizeof *cthread);
        tpool[tid] = cthread;
        if (!cthread) return;
    }

    uint32 stacksize = PGSIZE;
    cthread->res_size = 0;
    if (attr) {
        if (attr->res_size) {
            cthread->res_size = attr->res_size;
        }
        if (attr->stacksize) {
            stacksize = attr->stacksize;
        }
    }

    uint64 stack = (uint64) malloc(stacksize); 
    if (!stack) {
        return;
    }

    cthread->tid = tid;
    cthread->tcontext.sp = stack + stacksize;
    cthread->tcontext.ra = (uint64) &tentry;

    cthread->func = func;
    cthread->arg = arg;
    cthread->state = RUNNABLE;

    *thread = cthread;
    
    // TODO: Create a new process and add it as runnable, such that it starts running
    // once the scheduler schedules it the next time
}

int tjoin(int tid, void *status, uint size)
{
    while (tpool[tid]->state != EXITED) {
        tyield();
    }
    if (status && size) {
        uint amount = tpool[tid]->res_size > size ? size : tpool[tid]->res_size;
        memcpy(status, tpool[tid]->res, amount);
    }

    return 0;
}

void tyield()
{
    tpool[thread_index]->state = RUNNABLE;
    tsched();
}

uint8 twhoami()
{
    return thread_index;
}
