// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

uint64 MAX_PAGES = 0;
uint64 FREE_PAGES = 0;


void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.
		

struct run
{
    struct run *next;
};

struct
{
    struct spinlock lock;
    struct run *freelist;
} kmem;

#define NPAGES ((PHYSTOP-KERNBASE)/PGSIZE)
struct spinlock refcountlock;
char refcount[NPAGES];

int
refindex(uint64 pa)
{
    if (pa < KERNBASE || pa >= PHYSTOP)
        panic("refindex");

    return (pa - KERNBASE) / PGSIZE;
}

void kinit()
{
    initlock(&kmem.lock, "kmem");
    initlock(&refcountlock, "refcount");
    freerange(end, (void *)PHYSTOP);
    MAX_PAGES = FREE_PAGES;
}

void freerange(void *pa_start, void *pa_end)
{
    char *p;
    p = (char *)PGROUNDUP((uint64)pa_start);
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    {
        kfree(p);
    }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    if (MAX_PAGES != 0)
        assert(FREE_PAGES < MAX_PAGES);
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
        panic("kfree");

    // decrement refcount

    int i = refindex((uint64) pa);

    acquire(&refcountlock);
    if (refcount[i] > 0) refcount[i]--;
    int empty = refcount[i] == 0;
    release(&refcountlock);

    if (!empty) return;

    // Remove page

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);

    r = (struct run *)pa;

    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    assert(FREE_PAGES > 0);
    struct run *r;

    acquire(&kmem.lock);
    r = kmem.freelist;
    if (r)
        kmem.freelist = r->next;
    release(&kmem.lock);

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    FREE_PAGES--;

    int i = refindex((uint64) r);
    acquire(&refcountlock);
    refcount[i] = 1;
    release(&refcountlock);

    return (void *)r;
}

void cow_triggered(pte_t *pte)
{
    uint64 pg = PTE2PA(*pte);

    int i = refindex(pg);

    // check if need to copy to new page
    acquire(&refcountlock);
    if (refcount[i] > 1) {
        refcount[i]--;
        release(&refcountlock);

        // get new page
        void* new = kalloc();
        if (new == 0)
        {
          panic("cow_triggered, out of mem");
        }

        // copy to new page
        memmove(new, (void*) pg, PGSIZE);

        uint flags = PTE_FLAGS(*pte);
        flags &= ~PTE_COW;
        flags |= PTE_W;

        // update pte
        *pte = PA2PTE(new) | flags;
    } else {
        release(&refcountlock);
        // make normal write
        *pte = (*pte & ~PTE_COW) | PTE_W;
    } 
    sfence_vma(); // flush tlb
}

void increfcount(uint64 pa) {
    acquire(&refcountlock);
    refcount[refindex(pa)]++;
    release(&refcountlock);
}
