#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "proc.h"
#include "mmap.h"

#define MMAP_END(start, npages) (PGROUNDDOWN((start) + (npages) * PGSIZE))

int mfile_lookup(uint64 va) {
  vm_area *mfiles = myproc()->mfiles;
  for (int fd = 0; fd < NOFILE; fd++) {
    vm_area *mfile = &mfiles[fd];
    if (mfile->flags & VMA_VALID) {
      if (mfile->start <= va && va < MMAP_END(mfile->start, mfile->npages)) {
        return fd;
      }
    }
  } 
  return -1; // no vma found
}

static int vma_init(vm_area **mout, struct file **fout, pagetable_t *tout, int fd, int checkread) {
  struct proc *p = myproc();
  vm_area *mfile = &p->mfiles[fd];
  if (!(mfile->flags & VMA_VALID)) {
    return 1;
  }
  if (mfile->flags & VMA_READ && checkread) {
    return 2;
  }
  struct file *file = p->ofile[fd];
  if (!file) {
    return 3;
  }
  
  *mout = mfile;
  *fout = file;
  *tout = p->pagetable;
  
  return 0;
}


static void page_in(uint64 va, struct file *file, pagetable_t table) {
  pte_t *pte = walk(table, va, 0);
  if (!(*pte & PTE_V)) {
     *pte |= PTE_V;
     fileread(file, va, PAGE_LEFT(va));
     *pte &= ~PTE_D; 
  } else {
    file->off += PAGE_LEFT(va);
  }
}

static void page_out(uint64 va, struct file *file, pagetable_t table) {
  pte_t *pte = walk(table, va, 0);
  if (*pte & PTE_D && *pte & PTE_V) {
     filewrite(file, va, PAGE_LEFT(va));
     *pte &= ~PTE_D; 
  } else {
    file->off += PAGE_LEFT(va);
  }
}

int pop_vma_single(int fd, uint64 va) {
  vm_area *mfile;
  struct file *file;
  pagetable_t table;
  int status = vma_init(&mfile, &file, &table, fd, 1);
  if (status != 0) {
    return status;
  }

  int bef = file->off;
  file->off = mfile->offset;


  if (va < MMAP_END(mfile->start, 1)) {
    // first page
    page_in(mfile->start, file, table);
  } else {
    file->off += PGROUNDDOWN(va) - mfile->start;
    page_in(PGROUNDDOWN(va), file, table);
  }

  file->off = bef;
  return 0;
}


int pop_vma(int fd) {
  vm_area *mfile;
  struct file *file;
  pagetable_t table;
  int status = vma_init(&mfile, &file, &table, fd, 1);
  if (status != 0) {
    return status;
  }

  int bef = file->off;
  file->off = mfile->offset;

  for (uint64 va = mfile->start; va < MMAP_END(mfile->start, mfile->npages); va += PGSIZE)
  {
    page_in(va, file, table);
  }

  file->off = bef;
  mfile->flags |= VMA_READ;
  return 0;
}

int msync(int fd) {
  vm_area *mfile;
  struct file *file;
  pagetable_t table;
  int status = vma_init(&mfile, &file, &table, fd, 1);
  if (status != 0) {
    return status;
  }
  
  // should not propogate
  if (!(mfile->flags & VMA_PROP)) {
    return 0;
  }

  // writeback

  int bef = file->off;
  file->off = mfile->offset;

  for (uint64 va = mfile->start; va < MMAP_END(mfile->start, mfile->npages); va += PGSIZE)
  {
    page_out(va, file, table);
  }

  file->off = bef;
  return 0;
}

int mmap(uint64 vaddr, int npages, pagetable_t pagetable, int protocol, int lazy)
{
  for (uint64 va = vaddr; va < MMAP_END(vaddr, npages); va += PGSIZE)
  {
    pte_t *pte = walk(pagetable, va, 0);
    if (pte == 0) {
      return 1;
    }
    if (!(*pte & PTE_V)) {
      int fd = mfile_lookup(va);
      if (fd != -1) {
        int status = pop_vma_single(fd, va);
        if (status != 0) {
          return 14;
        }
      } else {
        return 13;
      }
    }

    if (*pte & PTE_COW && (protocol & PROT_SHARE && protocol & PROT_WRITE)) {
      cow_triggered(pte);
    }

    uint flags = PTE_FLAGS(*pte);

    // unset dirty bit
    flags &= ~PTE_D;

    if (lazy) {
      if (!(flags & PTE_R && flags & PTE_W)) {
        return 5; // cant map file to non read/write mem
      }
      flags &= ~PTE_V;
    }

    if (protocol & PROT_SHARE) {
      flags |= PTE_S;
    }

    if (protocol & PROT_READ) {
      if (!(flags & PTE_R)) {
        return 2; // can't make non readable page into readable
      }
    } else {
      flags &= ~PTE_R; // make non readable
    }

    if (protocol & PROT_WRITE) {
      if (!(flags & PTE_W)) {
        return 3; // can't make non writeable page into writable
      }
    } else {
      flags &= ~PTE_W; // make non writable
    }

    if (protocol & PROT_EXEC) {
      if (!(flags & PTE_X)) {
        return 4; // can't make non exec page into exec
      }
    } else {
      flags &= ~PTE_X; // make non exec
    }

    *pte = PA2PTE(PTE2PA(*pte)) | flags;
  }
  return 0;
}
