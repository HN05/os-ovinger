#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/memlayout.h"
#include "user/user.h"
#include "kernel/riscv.h"


// written by chatgpt
int
main(void)
{
  char *shared;
  int pid;

  printf("mapping shared page\n");

  shared = sbrk(PGSIZE);
  if(shared == (char*)-1){
    printf("sbrk failed\n");
    exit(1);
  }

  shared[0] = 42;

  if(mmap((uint64)shared, 1, PROT_READ | PROT_WRITE) == (uint64)-1){
    printf("mmap failed\n");
    exit(1);
  }

  pid = fork();

  if(pid == 0){
    sleep(10);

    printf("child read: %d\n", shared[0]);

    shared[0] = 99;
    printf("child wrote 99\n");

    if(mmap((uint64)shared, 1, PROT_READ) == (uint64)-1){
      printf("child failed to restrict perms\n");
      exit(1);
    }

    printf("child restricted page to read-only\n");

    printf("child attempting illegal write (should die)\n");
    shared[0] = 55;

    printf("ERROR: child survived illegal write\n");
    exit(1);
  }

  sleep(20);

  printf("parent sees after child write: %d\n", shared[0]);

  wait(0);

  printf("parent still sees: %d\n", shared[0]);

  exit(0);
}
