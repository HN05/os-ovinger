#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/memlayout.h"
#include "user/user.h"
#include "kernel/riscv.h"
#include "kernel/fcntl.h"

#define NPAGES 3

static void
check(int cond, char *msg)
{
  if(!cond){
    printf("FAIL: %s\n", msg);
    exit(1);
  }
}

static void
put5(char *dst, char a, char b, char c, char d, char e)
{
  dst[0] = a;
  dst[1] = b;
  dst[2] = c;
  dst[3] = d;
  dst[4] = e;
}

static void
show5(char *tag, char *p)
{
  printf("%s: %c %c %c %c %c\n", tag, p[0], p[1], p[2], p[3], p[4]);
}

static void
check5(char *p, char a, char b, char c, char d, char e, char *msg)
{
  if(p[0] != a || p[1] != b || p[2] != c || p[3] != d || p[4] != e){
    printf("FAIL: %s got [%c %c %c %c %c]\n", msg, p[0], p[1], p[2], p[3], p[4]);
    exit(1);
  }
}

int
main(void)
{
  char *buf, *map1, *map2, *anon1, *anon2;
  int fd, devfd, pid, status;
  int i;

  buf = sbrk(NPAGES * PGSIZE);
  check(buf != (char*)-1, "sbrk buf");

  map1 = sbrk(NPAGES * PGSIZE);
  check(map1 != (char*)-1, "sbrk map1");

  map2 = sbrk(NPAGES * PGSIZE);
  check(map2 != (char*)-1, "sbrk map2");

  anon1 = sbrk(PGSIZE);
  check(anon1 != (char*)-1, "sbrk anon1");

  anon2 = sbrk(PGSIZE);
  check(anon2 != (char*)-1, "sbrk anon2");

  unlink("mmapfile");

  //
  // Build 3-page file.
  //
  fd = open("mmapfile", O_CREATE | O_RDWR);
  check(fd >= 0, "open create");

  memset(buf, 0, NPAGES * PGSIZE);
  put5(buf + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o');
  put5(buf + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd');
  put5(buf + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e');

  check(write(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "initial write");
  close(fd);

  //
  // First mapping.
  //
  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "open rdwr first");

  memset(map1, 0, NPAGES * PGSIZE);
  check(mmap((uint64)map1, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap first");

  show5("map1 page0 after first mmap", map1 + 0 * PGSIZE);
  show5("map1 page1 after first mmap", map1 + 1 * PGSIZE);
  show5("map1 page2 after first mmap", map1 + 2 * PGSIZE);

  check5(map1 + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "first load page0");
  check5(map1 + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd', "first load page1");
  check5(map1 + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e', "first load page2");

  put5(map1 + 0 * PGSIZE, 'H', 'E', 'L', 'L', 'O');
  put5(map1 + 1 * PGSIZE, 'W', 'O', 'R', 'L', 'D');
  put5(map1 + 2 * PGSIZE, 'A', 'B', 'C', 'D', 'E');

  check(msync(fd) >= 0, "msync first");
  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "open verify first");
  memset(buf, 0, NPAGES * PGSIZE);
  check(read(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "read verify first");
  close(fd);

  show5("file page0 after first msync", buf + 0 * PGSIZE);
  show5("file page1 after first msync", buf + 1 * PGSIZE);
  show5("file page2 after first msync", buf + 2 * PGSIZE);

  check5(buf + 0 * PGSIZE, 'H', 'E', 'L', 'L', 'O', "verify first page0");
  check5(buf + 1 * PGSIZE, 'W', 'O', 'R', 'L', 'D', "verify first page1");
  check5(buf + 2 * PGSIZE, 'A', 'B', 'C', 'D', 'E', "verify first page2");

  //
  // Partial changes.
  //
  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "open rdwr second");
  memset(map1, 0, NPAGES * PGSIZE);

  check(mmap((uint64)map1, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap second same region");

  map1[0 * PGSIZE + 1] = 'a';
  map1[1 * PGSIZE + 2] = 'x';
  map1[2 * PGSIZE + 4] = '!';

  check(msync(fd) >= 0, "msync partial");
  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "open verify partial");
  memset(buf, 0, NPAGES * PGSIZE);
  check(read(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "read verify partial");
  close(fd);

  show5("file page0 after partial msync", buf + 0 * PGSIZE);
  show5("file page1 after partial msync", buf + 1 * PGSIZE);
  show5("file page2 after partial msync", buf + 2 * PGSIZE);

  check5(buf + 0 * PGSIZE, 'H', 'a', 'L', 'L', 'O', "partial verify page0");
  check5(buf + 1 * PGSIZE, 'W', 'O', 'x', 'L', 'D', "partial verify page1");
  check5(buf + 2 * PGSIZE, 'A', 'B', 'C', 'D', '!', "partial verify page2");

  //
  // Fresh remap into different region.
  //
  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "open rdwr third");
  memset(map2, 0, NPAGES * PGSIZE);

  check(mmap((uint64)map2, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap into second region");

  show5("map2 page0 after fresh mmap", map2 + 0 * PGSIZE);
  show5("map2 page1 after fresh mmap", map2 + 1 * PGSIZE);
  show5("map2 page2 after fresh mmap", map2 + 2 * PGSIZE);

  check5(map2 + 0 * PGSIZE, 'H', 'a', 'L', 'L', 'O', "fresh reload page0");
  check5(map2 + 1 * PGSIZE, 'W', 'O', 'x', 'L', 'D', "fresh reload page1");
  check5(map2 + 2 * PGSIZE, 'A', 'B', 'C', 'D', '!', "fresh reload page2");

  //
  // Repeated msync.
  //
  for(i = 0; i < 3; i++){
    map2[0 * PGSIZE + i] = '0' + i;
    map2[1 * PGSIZE + i] = '3' + i;
    map2[2 * PGSIZE + i] = '6' + i;
    check(msync(fd) >= 0, "repeated msync");
  }
  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "open verify repeated");
  memset(buf, 0, NPAGES * PGSIZE);
  check(read(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "read verify repeated");
  close(fd);

  show5("file page0 after repeated msync", buf + 0 * PGSIZE);
  show5("file page1 after repeated msync", buf + 1 * PGSIZE);
  show5("file page2 after repeated msync", buf + 2 * PGSIZE);

  check5(buf + 0 * PGSIZE, '0', '1', '2', 'L', 'O', "repeated verify page0");
  check5(buf + 1 * PGSIZE, '3', '4', '5', 'L', 'D', "repeated verify page1");
  check5(buf + 2 * PGSIZE, '6', '7', '8', 'D', '!', "repeated verify page2");

  //
  // PROT_UNPROP: disable propagation, then verify file does not change.
  //
  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "open for unprop");

  check(mmap((uint64)map2, NPAGES, PROT_READ | PROT_WRITE | PROT_UNPROP, fd) == 0,
        "mmap unprop");

  put5(map2 + 0 * PGSIZE, 'N', 'O', 'S', 'Y', 'N');
  put5(map2 + 1 * PGSIZE, 'K', 'E', 'E', 'P', '?');
  put5(map2 + 2 * PGSIZE, 'L', 'O', 'C', 'A', 'L');

  if(msync(fd) == 0){
    printf("note: msync after unprop succeeded; expecting file to stay unchanged\n");
  }

  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "open verify unprop");
  memset(buf, 0, NPAGES * PGSIZE);
  check(read(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "read verify unprop");
  close(fd);

  show5("file page0 after unprop", buf + 0 * PGSIZE);
  show5("file page1 after unprop", buf + 1 * PGSIZE);
  show5("file page2 after unprop", buf + 2 * PGSIZE);

  check5(buf + 0 * PGSIZE, '0', '1', '2', 'L', 'O', "unprop verify page0");
  check5(buf + 1 * PGSIZE, '3', '4', '5', 'L', 'D', "unprop verify page1");
  check5(buf + 2 * PGSIZE, '6', '7', '8', 'D', '!', "unprop verify page2");

  //
  // Anonymous shared mapping: fd = -1.
  //
  memset(anon1, 0, PGSIZE);
  anon1[0] = 'p';
  anon1[1] = 'a';
  anon1[2] = 'r';
  anon1[3] = 'e';
  anon1[4] = 'n';
  anon1[5] = 't';

  check(mmap((uint64)anon1, 1, PROT_READ | PROT_WRITE | PROT_SHARE, -1) == 0,
        "anon shared mmap");

  pid = fork();
  check(pid >= 0, "fork anon shared");

  if(pid == 0){
    anon1[0] = 'c';
    anon1[1] = 'h';
    anon1[2] = 'i';
    anon1[3] = 'l';
    anon1[4] = 'd';
    exit(0);
  }

  wait(&status);
  printf("anon shared after child: %c %c %c %c %c\n",
         anon1[0], anon1[1], anon1[2], anon1[3], anon1[4]);
  check(anon1[0] == 'c', "anon shared[0]");
  check(anon1[1] == 'h', "anon shared[1]");
  check(anon1[2] == 'i', "anon shared[2]");
  check(anon1[3] == 'l', "anon shared[3]");
  check(anon1[4] == 'd', "anon shared[4]");

  //
  // Anonymous non-shared mapping: should stay COW/private across fork.
  //
  memset(anon2, 0, PGSIZE);
  anon2[0] = 'p';
  anon2[1] = 'r';
  anon2[2] = 'i';
  anon2[3] = 'v';
  anon2[4] = '0';

  check(mmap((uint64)anon2, 1, PROT_READ | PROT_WRITE, -1) == 0,
        "anon private mmap");

  pid = fork();
  check(pid >= 0, "fork anon private");

  if(pid == 0){
    anon2[0] = 'c';
    anon2[1] = 'o';
    anon2[2] = 'w';
    anon2[3] = '!';
    anon2[4] = '!';
    exit(0);
  }

  wait(&status);
  printf("anon private after child: %c %c %c %c %c\n",
         anon2[0], anon2[1], anon2[2], anon2[3], anon2[4]);
  check(anon2[0] == 'p', "anon private[0]");
  check(anon2[1] == 'r', "anon private[1]");
  check(anon2[2] == 'i', "anon private[2]");
  check(anon2[3] == 'v', "anon private[3]");
  check(anon2[4] == '0', "anon private[4]");

  //
  // Shared fork + exit writeback for file-backed mapping.
  //
  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "open for shared fork");

  check(mmap((uint64)map1, NPAGES,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_SHARE,
             fd) == 0,
        "mmap shared before fork");

  pid = fork();
  check(pid >= 0, "fork file shared");

  if(pid == 0){
    put5(map1 + 0 * PGSIZE, 'C', 'H', 'I', 'L', 'D');
    put5(map1 + 1 * PGSIZE, 'S', 'H', 'A', 'R', 'E');
    put5(map1 + 2 * PGSIZE, 'E', 'X', 'I', 'T', '!');
    exit(0);
  }

  wait(&status);

  show5("parent page0 after child exit", map1 + 0 * PGSIZE);
  show5("parent page1 after child exit", map1 + 1 * PGSIZE);
  show5("parent page2 after child exit", map1 + 2 * PGSIZE);

  check5(map1 + 0 * PGSIZE, 'C', 'H', 'I', 'L', 'D', "shared parent page0");
  check5(map1 + 1 * PGSIZE, 'S', 'H', 'A', 'R', 'E', "shared parent page1");
  check5(map1 + 2 * PGSIZE, 'E', 'X', 'I', 'T', '!', "shared parent page2");

  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "open verify child exit");
  memset(buf, 0, NPAGES * PGSIZE);
  check(read(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "read verify child exit");
  close(fd);

  show5("file page0 after child exit", buf + 0 * PGSIZE);
  show5("file page1 after child exit", buf + 1 * PGSIZE);
  show5("file page2 after child exit", buf + 2 * PGSIZE);

  check5(buf + 0 * PGSIZE, 'C', 'H', 'I', 'L', 'D', "exit verify page0");
  check5(buf + 1 * PGSIZE, 'S', 'H', 'A', 'R', 'E', "exit verify page1");
  check5(buf + 2 * PGSIZE, 'E', 'X', 'I', 'T', '!', "exit verify page2");

  //
  // Device-backed / non-regular-file test.
  // "console" is a device in xv6. Whether mmap should support it is up to your kernel.
  // This test accepts either:
  //   - graceful failure, or
  //   - success without crashing the kernel.
  //
  devfd = open("console", O_RDWR);
  if(devfd >= 0){
    memset(map2, 0, NPAGES * PGSIZE);
    status = mmap((uint64)map2, 1, PROT_READ | PROT_WRITE, devfd);
    printf("device mmap(console) returned %d\n", status);
    close(devfd);
  } else {
    printf("note: could not open console for device mmap test\n");
  }

  printf("expanded mmap/msync/shared/exit/unprop/anon/device test passed\n");
  exit(0);
}
