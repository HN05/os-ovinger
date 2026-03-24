#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"
#include "kernel/fcntl.h"
#include "user/user.h"

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
check5(char *p, char a, char b, char c, char d, char e, char *msg)
{
  if(p[0] != a || p[1] != b || p[2] != c || p[3] != d || p[4] != e){
    printf("FAIL: %s got [%c %c %c %c %c]\n", msg, p[0], p[1], p[2], p[3], p[4]);
    exit(1);
  }
}

static void
show5(char *tag, char *p)
{
  printf("%s: %c %c %c %c %c\n", tag, p[0], p[1], p[2], p[3], p[4]);
}

static char*
alloc_pages(int npages, char *msg)
{
  char *p = sbrk(npages * PGSIZE);
  check(p != (char*)-1, msg);
  memset(p, 0, npages * PGSIZE);
  return p;
}

static void
make_file3(char *name)
{
  int fd;
  char *buf = alloc_pages(NPAGES, "sbrk make_file3");

  unlink(name);
  fd = open(name, O_CREATE | O_RDWR);
  check(fd >= 0, "open create make_file3");

  put5(buf + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o');
  put5(buf + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd');
  put5(buf + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e');

  check(write(fd, buf, NPAGES * PGSIZE) == NPAGES * PGSIZE, "write make_file3");
  close(fd);
}

static void
make_short_file(char *name)
{
  int fd;
  char *buf = alloc_pages(1, "sbrk make_short_file");

  unlink(name);
  fd = open(name, O_CREATE | O_RDWR);
  check(fd >= 0, "open create make_short_file");

  memset(buf, 0, PGSIZE);
  put5(buf, 's', 'h', 'o', 'r', 't');
  check(write(fd, buf, 5) == 5, "write short file");
  close(fd);
}

static void
read_file_n(char *name, char *buf, int n)
{
  int fd = open(name, O_RDONLY);
  check(fd >= 0, "open read_file_n");
  memset(buf, 0, n);
  check(read(fd, buf, n) == n, "read read_file_n");
  close(fd);
}

static void
test_file_load_and_msync(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_file_load_and_msync map");
  char *buf = alloc_pages(NPAGES, "sbrk test_file_load_and_msync buf");
  int fd;

  make_file3("mmap_a");

  fd = open("mmap_a", O_RDWR);
  check(fd >= 0, "open mmap_a rdwr");

  check(mmap((uint64)map, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap file load");

  show5("file-load page0", map + 0 * PGSIZE);
  show5("file-load page1", map + 1 * PGSIZE);
  show5("file-load page2", map + 2 * PGSIZE);

  check5(map + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "file load page0");
  check5(map + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd', "file load page1");
  check5(map + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e', "file load page2");

  put5(map + 0 * PGSIZE, 'H', 'E', 'L', 'L', 'O');
  put5(map + 1 * PGSIZE, 'W', 'O', 'R', 'L', 'D');
  put5(map + 2 * PGSIZE, 'A', 'B', 'C', 'D', 'E');

  check(msync(fd) >= 0, "msync file load");
  close(fd);

  read_file_n("mmap_a", buf, NPAGES * PGSIZE);
  check5(buf + 0 * PGSIZE, 'H', 'E', 'L', 'L', 'O', "file verify page0");
  check5(buf + 1 * PGSIZE, 'W', 'O', 'R', 'L', 'D', "file verify page1");
  check5(buf + 2 * PGSIZE, 'A', 'B', 'C', 'D', 'E', "file verify page2");

  printf("ok: file load + msync\n");
}

static void
test_populate_file_mapping(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_populate_file_mapping map");
  int fd;

  make_file3("mmap_pop");

  fd = open("mmap_pop", O_RDWR);
  check(fd >= 0, "open mmap_pop rdwr");

  check(mmap((uint64)map, NPAGES,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_POPULATE,
             fd) == 0,
        "mmap populate");

  check5(map + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "populate page0");
  check5(map + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd', "populate page1");
  check5(map + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e', "populate page2");

  close(fd);
  printf("ok: populate file mapping\n");
}

static void
test_unprop(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_unprop map");
  char *buf = alloc_pages(NPAGES, "sbrk test_unprop buf");
  int fd;

  make_file3("mmap_b");

  fd = open("mmap_b", O_RDWR);
  check(fd >= 0, "open mmap_b rdwr");

  check(mmap((uint64)map, NPAGES, PROT_READ | PROT_WRITE | PROT_UNPROP, fd) == 0,
        "mmap unprop");

  put5(map + 0 * PGSIZE, 'N', 'O', 'S', 'Y', 'N');
  put5(map + 1 * PGSIZE, 'K', 'E', 'E', 'P', '?');
  put5(map + 2 * PGSIZE, 'L', 'O', 'C', 'A', 'L');

  check(msync(fd) >= 0, "msync unprop");
  close(fd);

  read_file_n("mmap_b", buf, NPAGES * PGSIZE);
  check5(buf + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "unprop page0");
  check5(buf + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd', "unprop page1");
  check5(buf + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e', "unprop page2");

  printf("ok: unprop\n");
}

static void
test_unprop_then_fork(void)
{
  char *p = alloc_pages(1, "sbrk test_unprop_then_fork");
  int fd, pid, status;

  make_file3("mmap_unprop_fork");

  fd = open("mmap_unprop_fork", O_RDWR);
  check(fd >= 0, "open mmap_unprop_fork");

  check(mmap((uint64)p, 1, PROT_READ | PROT_WRITE | PROT_UNPROP, fd) == 0,
        "mmap unprop fork");
  p[0] = 'u';
  p[1] = 'n';
  p[2] = 'p';
  p[3] = 'r';
  p[4] = 'p';
  close(fd);

  pid = fork();
  check(pid >= 0, "fork after unprop");

  if(pid == 0){
    p[0] = 'c';
    p[1] = 'h';
    p[2] = 'i';
    p[3] = 'l';
    p[4] = 'd';
    exit(0);
  }

  wait(&status);
  printf("ok: unprop then fork\n");
}

static void
test_anon_shared(void)
{
  char *p = alloc_pages(1, "sbrk test_anon_shared");
  int pid, status;

  p[0] = 'p';
  p[1] = 'a';
  p[2] = 'r';
  p[3] = 'e';
  p[4] = 'n';

  check(mmap((uint64)p, 1, PROT_READ | PROT_WRITE | PROT_SHARE, -1) == 0,
        "mmap anon shared");

  pid = fork();
  check(pid >= 0, "fork anon shared");

  if(pid == 0){
    p[0] = 'c';
    p[1] = 'h';
    p[2] = 'i';
    p[3] = 'l';
    p[4] = 'd';
    exit(0);
  }

  wait(&status);
  check5(p, 'c', 'h', 'i', 'l', 'd', "anon shared result");
  printf("ok: anon shared fork\n");
}

static void
test_anon_private(void)
{
  char *p = alloc_pages(1, "sbrk test_anon_private");
  int pid, status;

  p[0] = 'p';
  p[1] = 'r';
  p[2] = 'i';
  p[3] = 'v';
  p[4] = '0';

  check(mmap((uint64)p, 1, PROT_READ | PROT_WRITE, -1) == 0,
        "mmap anon private");

  pid = fork();
  check(pid >= 0, "fork anon private");

  if(pid == 0){
    p[0] = 'c';
    p[1] = 'o';
    p[2] = 'w';
    p[3] = '!';
    p[4] = '!';
    exit(0);
  }

  wait(&status);
  check5(p, 'p', 'r', 'i', 'v', '0', "anon private result");
  printf("ok: anon private fork\n");
}

static void
test_shared_file_fork_after_touch(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_shared_file_fork_after_touch map");
  char *buf = alloc_pages(NPAGES, "sbrk test_shared_file_fork_after_touch buf");
  int fd, pid, status;

  make_file3("mmap_c");

  fd = open("mmap_c", O_RDWR);
  check(fd >= 0, "open mmap_c rdwr");

  check(mmap((uint64)map, NPAGES,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_SHARE,
             fd) == 0,
        "mmap shared file after touch");

  check5(map + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "pre-fork touch page0");
  check5(map + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd', "pre-fork touch page1");
  check5(map + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e', "pre-fork touch page2");

  pid = fork();
  check(pid >= 0, "fork shared file after touch");

  if(pid == 0){
    put5(map + 0 * PGSIZE, 'C', 'H', 'I', 'L', 'D');
    put5(map + 1 * PGSIZE, 'S', 'H', 'A', 'R', 'E');
    put5(map + 2 * PGSIZE, 'E', 'X', 'I', 'T', '!');
    exit(0);
  }

  wait(&status);

  check5(map + 0 * PGSIZE, 'C', 'H', 'I', 'L', 'D', "shared file mem page0");
  check5(map + 1 * PGSIZE, 'S', 'H', 'A', 'R', 'E', "shared file mem page1");
  check5(map + 2 * PGSIZE, 'E', 'X', 'I', 'T', '!', "shared file mem page2");

  close(fd);
  read_file_n("mmap_c", buf, NPAGES * PGSIZE);
  check5(buf + 0 * PGSIZE, 'C', 'H', 'I', 'L', 'D', "shared file disk page0");
  check5(buf + 1 * PGSIZE, 'S', 'H', 'A', 'R', 'E', "shared file disk page1");
  check5(buf + 2 * PGSIZE, 'E', 'X', 'I', 'T', '!', "shared file disk page2");

  printf("ok: shared file fork after touch\n");
}

static void
test_shared_file_fork_lazy(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_shared_file_fork_lazy map");
  int fd, pid, status;

  make_file3("mmap_d");

  fd = open("mmap_d", O_RDWR);
  check(fd >= 0, "open mmap_d rdwr");

  check(mmap((uint64)map, NPAGES,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_SHARE,
             fd) == 0,
        "mmap shared file lazy");

  printf("before lazy shared-file fork\n");
  pid = fork();
  check(pid >= 0, "fork shared file lazy");

  if(pid == 0){
    put5(map + 0 * PGSIZE, 'L', 'A', 'Z', 'Y', '1');
    put5(map + 1 * PGSIZE, 'L', 'A', 'Z', 'Y', '2');
    put5(map + 2 * PGSIZE, 'L', 'A', 'Z', 'Y', '3');
    exit(0);
  }

  wait(&status);

  check5(map + 0 * PGSIZE, 'L', 'A', 'Z', 'Y', '1', "lazy shared mem page0");
  check5(map + 1 * PGSIZE, 'L', 'A', 'Z', 'Y', '2', "lazy shared mem page1");
  check5(map + 2 * PGSIZE, 'L', 'A', 'Z', 'Y', '3', "lazy shared mem page2");

  close(fd);
  printf("ok: shared file fork lazy\n");
}

static void
test_populate_then_fork_lazy(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_populate_then_fork_lazy map");
  int fd, pid, status;

  make_file3("mmap_pop_fork");

  fd = open("mmap_pop_fork", O_RDWR);
  check(fd >= 0, "open mmap_pop_fork");

  check(mmap((uint64)map, NPAGES,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_SHARE | PROT_POPULATE,
             fd) == 0,
        "mmap populate fork");

  pid = fork();
  check(pid >= 0, "fork populate");

  if(pid == 0){
    put5(map + 0 * PGSIZE, 'P', 'O', 'P', '0', '1');
    put5(map + 1 * PGSIZE, 'P', 'O', 'P', '0', '2');
    put5(map + 2 * PGSIZE, 'P', 'O', 'P', '0', '3');
    exit(0);
  }

  wait(&status);
  check5(map + 0 * PGSIZE, 'P', 'O', 'P', '0', '1', "populate fork page0");
  check5(map + 1 * PGSIZE, 'P', 'O', 'P', '0', '2', "populate fork page1");
  check5(map + 2 * PGSIZE, 'P', 'O', 'P', '0', '3', "populate fork page2");
  close(fd);

  printf("ok: populate then fork\n");
}

static void
test_close_after_mmap_touch(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_close_after_mmap_touch map");
  int fd;

  make_file3("mmap_close");

  fd = open("mmap_close", O_RDWR);
  check(fd >= 0, "open mmap_close");

  check(mmap((uint64)map, NPAGES,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_POPULATE,
             fd) == 0,
        "mmap close test");
  close(fd);

  check5(map + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "close touch page0");
  check5(map + 1 * PGSIZE, 'w', 'o', 'r', 'l', 'd', "close touch page1");
  check5(map + 2 * PGSIZE, 'a', 'b', 'c', 'd', 'e', "close touch page2");

  printf("ok: close after mmap touch\n");
}

static void
test_remap_same_region_protocols(void)
{
  char *map = alloc_pages(NPAGES, "sbrk test_remap_same_region_protocols map");
  int fd;

  make_file3("mmap_proto");

  fd = open("mmap_proto", O_RDWR);
  check(fd >= 0, "open mmap_proto");

  check(mmap((uint64)map, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap proto rw");
  check5(map + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "proto first load");

  check(mmap((uint64)map, NPAGES, PROT_READ | PROT_PROP | PROT_POPULATE, fd) == 0,
        "mmap proto readonly populate");
  check5(map + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "proto remap preserve");

  close(fd);
  printf("ok: remap same region protocols\n");
}

static void
test_short_file_mapping(void)
{
  char *map = alloc_pages(1, "sbrk test_short_file_mapping map");
  int fd;

  make_short_file("mmap_short");

  fd = open("mmap_short", O_RDWR);
  check(fd >= 0, "open mmap_short");

  check(mmap((uint64)map, 1,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_POPULATE,
             fd) == 0,
        "mmap short file");

  check5(map, 's', 'h', 'o', 'r', 't', "short file bytes");
  close(fd);

  printf("ok: short file mapping\n");
}

static void
test_remap_same_file_twice(void)
{
  char *a = alloc_pages(NPAGES, "sbrk test_remap_same_file_twice a");
  char *b = alloc_pages(NPAGES, "sbrk test_remap_same_file_twice b");
  int fd;

  make_file3("mmap_e");

  fd = open("mmap_e", O_RDWR);
  check(fd >= 0, "open mmap_e rdwr");

  check(mmap((uint64)a, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap remap a");
  check(mmap((uint64)b, NPAGES, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap remap b");

  check5(a + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "remap a page0");
  check5(b + 0 * PGSIZE, 'h', 'e', 'l', 'l', 'o', "remap b page0");

  close(fd);
  printf("ok: remap same file twice\n");
}

int
main(void)
{
  test_file_load_and_msync();
  test_populate_file_mapping();
  test_unprop();
  test_unprop_then_fork();
  test_anon_shared();
  test_anon_private();
  test_shared_file_fork_after_touch();
  test_shared_file_fork_lazy();
  test_populate_then_fork_lazy();
  test_close_after_mmap_touch();
  test_remap_same_region_protocols();
  test_short_file_mapping();
  test_remap_same_file_twice();

  printf("all mmap tests passed\n");
  exit(0);
}
