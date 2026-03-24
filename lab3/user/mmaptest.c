#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/memlayout.h"
#include "user/user.h"
#include "kernel/riscv.h"
#include "kernel/fcntl.h"

int
main(void)
{
  char *p;
  int fd;
  char buf[32];

  unlink("mmapfile");

  fd = open("mmapfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf("open failed\n");
    exit(1);
  }

  if(write(fd, "hello", 5) != 5){
    printf("write failed\n");
    exit(1);
  }
  close(fd);

  fd = open("mmapfile", O_RDWR);
  if(fd < 0){
    printf("reopen failed\n");
    exit(1);
  }

  p = sbrk(PGSIZE);
  if(p == (char*)-1){
    printf("sbrk failed\n");
    exit(1);
  }

  if(mmap((uint64)p, 1, PROT_READ | PROT_WRITE | PROT_PROP, fd) != 0){
    printf("mmap failed\n");
    exit(1);
  }

  printf("before write: %c %c %c %c %c\n", p[0], p[1], p[2], p[3], p[4]);

  // modify memory
  p[0] = 'H';
  p[1] = 'E';
  p[2] = 'L';
  p[3] = 'L';
  p[4] = 'O';

  printf("after memory write: %c %c %c %c %c\n", p[0], p[1], p[2], p[3], p[4]);

  // sync to file
  if(msync(fd) < 0){
    printf("msync failed\n");
    exit(1);
  }

  close(fd);

  fd = open("mmapfile", O_RDONLY);
  if(fd < 0){
    printf("open verify failed\n");
    exit(1);
  }

  memset(buf, 0, sizeof(buf));
  if(read(fd, buf, 5) != 5){
    printf("read verify failed\n");
    exit(1);
  }

  printf("file after msync: %c %c %c %c %c\n",
         buf[0], buf[1], buf[2], buf[3], buf[4]);

  if(buf[0] != 'H' || buf[1] != 'E' ||
     buf[2] != 'L' || buf[3] != 'L' || buf[4] != 'O'){
    printf("ERROR: msync did not write back\n");
    exit(1);
  }

  close(fd);
  exit(0);
}
