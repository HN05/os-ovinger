//
// Support functions for system calls that involve file descriptors.
//

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "stat.h"
#include "proc.h"

struct devsw devsw[NDEV];
struct {
  struct spinlock lock;
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
  initlock(&ftable.lock, "ftable");
}

// Allocate a file structure.
struct file*
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
  f->ref++;
  release(&ftable.lock);
  return f;
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
    return;
  }
  ff = *f;
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if(ff.type == FD_PIPE){
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
  struct proc *p = myproc();
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    ilock(f->ip);
    stati(f->ip, &st);
    iunlock(f->ip);
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
      return -1;
    return 0;
  }
  return -1;
}

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
  int r = 0;

  if(f->readable == 0)
    return -1;

  if(f->type == FD_PIPE){
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    ilock(f->ip);
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
  } else {
    panic("fileread");
  }

  return r;
}

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    return -1;

  if(f->type == FD_PIPE){
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    // write a few blocks at a time to avoid exceeding
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r != n1){
        // error from writei
        break;
      }
      i += r;
    }
    ret = (i == n ? n : -1);
  } else {
    panic("filewrite");
  }

  return ret;
}

int is_writeback(uint64 va) {
  pte_t *pte = walk(myproc()->pagetable, va, 0);
  if (!(*pte & PTE_V)) {
    for (int fd = 0; fd < NOFILE; fd++) {
      writeback *wb = &myproc()->wb[fd];
      if (wb->flags & WB_VALID && !(wb->flags & WB_READ)) {
        if (wb->start <= va && va < PGROUNDDOWN(wb->start + wb->npages*PGSIZE)) {
          return fd;
        }
      }
    } 
  }
  return -1;
}

// load page for that va
int msync_read(int fd, uint64 va) {
  struct writeback *wb = &myproc()->wb[fd];
  struct file *file = myproc()->ofile[fd];

  int bef = file->off;
  file->off = wb->offset;

  pagetable_t table = myproc()->pagetable;
  pte_t *pte = walk(table, va, 0);
  *pte |= PTE_V;
  if (va < PGROUNDDOWN(wb->start + PGSIZE)) {
    // first page
    fileread(file, wb->start, PGROUNDDOWN(wb->start+PGSIZE) - wb->start);
  } else {
    file->off += PGROUNDDOWN(va) - wb->start;
    fileread(file, PGROUNDDOWN(va), PGSIZE);
  }
  *pte &= ~PTE_D;

  file->off = bef;
  return 0;
}

int msync(int fd) {
  writeback *wb = &myproc()->wb[fd];
  if (!(wb->flags & WB_VALID)) {
    return 1;
  }

  struct file *file = myproc()->ofile[fd];
  if (!file) {
    return 2;
  }
  
  // should not propogate
  if (!(wb->flags & WB_PROP)) {
    wb->flags = 0;
    return 0;
  }

  // writeback

  int bef = file->off;
  file->off = wb->offset;

  uint64 va = wb->start;

  // first page
  pagetable_t table = myproc()->pagetable;
  pte_t *pte = walk(table, va, 0);
  if (*pte & PTE_D && *pte & PTE_V) {
    filewrite(file, va, PGROUNDDOWN(va+PGSIZE) - va);
    *pte &= ~PTE_D; 
  } else {
    file->off += PGROUNDUP(va) - va;
  }

  for (va = PGROUNDDOWN(va+PGSIZE); va < PGROUNDDOWN(wb->start + wb->npages*PGSIZE); va += PGSIZE)
  {
    pte_t *pte = walk(table, va, 0);
    if (*pte & PTE_D && *pte & PTE_V) {
       filewrite(file, va, PGSIZE);
       *pte &= ~PTE_D; 
    } else {
      file->off += PGSIZE;
    }
  }

  file->off = bef;
  return 0;
}
