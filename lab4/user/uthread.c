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
    struct thread *thread = threads[curtid];

    // run the func
    void *resbuf = thread->func(thread->arg);
    
    thread->res = resbuf;

    thread->state = EXITED;
    // wake all waiters
    for (int tid = 0; tid < NTHREADS; tid++) {
        if (threads[tid]->waiting_for == thread->tid) {
            threads[tid]->state = RUNNABLE;
            threads[tid]->waiting_for = -1;
        }
    }
    tsched();

    // all finished
    int *result = threads[0]->res;
    exit(*result);
}

// not tsched responsibility to set old to runnable
void tsched()
{
    int nextid = -1;
    for (int i = 1; i <= NTHREADS; i++) {
        int index = (i + curtid) % NTHREADS;
        if (threads[index] && threads[index]->state == RUNNABLE) {
            nextid = index;
            break;
        }
    }

    // all threads exited
    if (nextid == -1) return;

    struct thread *next = threads[nextid];
    next->state = RUNNING;

    // only currently running thread
    if (nextid == curtid) return;

    struct thread *oldt = threads[curtid];
    curtid = nextid;
    tswtch(&oldt->tcontext, &next->tcontext);
}

void tcreate(struct thread **thread, struct thread_attr *attr, void *(*func)(void *arg), void *arg)
{
    // find location
    int tid = -1;
    for (int i = 0; i < NTHREADS; i++) {
        if (threads[i] && threads[i]->state != UNUSED) continue;
        tid = i;
        break;
    }
    // no available slots
    if (tid == -1) return;

    struct thread *cthread = threads[tid]; 
    if (!cthread) {
        // no space allocated for thread
        cthread = malloc(sizeof *cthread);
        if (!cthread) return;
        threads[tid] = cthread;
    }

    // default vals
    uint32 stacksize = PGSIZE;
    cthread->res_size = 0;
    cthread->waiting_for = -1;

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
}

int tjoin(int tid, void *status, uint size)
{
    struct thread *wthread = threads[tid];
    if (wthread->state != EXITED) {
        threads[curtid]->state = SLEEPING;
        threads[curtid]->waiting_for = tid;
        tsched();
    }
    
    if (status && size) {
        // choose min of res_size and size
        uint safesize = wthread->res_size > size ? size : wthread->res_size;
        memcpy(status, wthread->res, safesize);
    }

    return 0;
}

void tyield()
{
    threads[curtid]->state = RUNNABLE;
    tsched();
}

uint8 twhoami()
{
    return curtid;
}
