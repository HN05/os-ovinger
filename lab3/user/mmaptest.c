#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/memlayout.h"
#include "user/user.h"
#include "kernel/riscv.h"
#include "kernel/fcntl.h"

static void
check(int cond, char *msg)
{
  if(!cond){
    printf("FAIL: %s\n", msg);
    exit(1);
  }
}

static void
show5(char *tag, char *p)
{
  printf("%s: %c %c %c %c %c\n", tag, p[0], p[1], p[2], p[3], p[4]);
}

int
main(void)
{
  char *p, *buf;
  int fd, pid, status;

  buf = sbrk(2 * PGSIZE);
  check(buf != (char*)-1, "sbrk buf");

  p = sbrk(2 * PGSIZE);
  check(p != (char*)-1, "sbrk p");

  unlink("mmapfile");

  fd = open("mmapfile", O_CREATE | O_RDWR);
  check(fd >= 0, "open create");

  memset(buf, 0, 2 * PGSIZE);
  buf[0] = 'h';
  buf[1] = 'e';
  buf[2] = 'l';
  buf[3] = 'l';
  buf[4] = 'o';

  buf[PGSIZE + 0] = 'w';
  buf[PGSIZE + 1] = 'o';
  buf[PGSIZE + 2] = 'r';
  buf[PGSIZE + 3] = 'l';
  buf[PGSIZE + 4] = 'd';

  check(write(fd, buf, 2 * PGSIZE) == 2 * PGSIZE, "initial 2-page write");
  close(fd);

  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "reopen rdwr");

  memset(p, 0, 2 * PGSIZE);
  check(mmap((uint64)p, 2, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "mmap 2 pages");

  show5("page0 after mmap", p);
  show5("page1 after mmap", p + PGSIZE);

  check(p[0] == 'h', "page0[0]");
  check(p[1] == 'e', "page0[1]");
  check(p[2] == 'l', "page0[2]");
  check(p[3] == 'l', "page0[3]");
  check(p[4] == 'o', "page0[4]");

  check(p[PGSIZE + 0] == 'w', "page1[0]");
  check(p[PGSIZE + 1] == 'o', "page1[1]");
  check(p[PGSIZE + 2] == 'r', "page1[2]");
  check(p[PGSIZE + 3] == 'l', "page1[3]");
  check(p[PGSIZE + 4] == 'd', "page1[4]");

  p[0] = 'H';
  p[1] = 'E';
  p[2] = 'L';
  p[3] = 'L';
  p[4] = 'O';

  p[PGSIZE + 0] = 'W';
  p[PGSIZE + 1] = 'O';
  p[PGSIZE + 2] = 'R';
  p[PGSIZE + 3] = 'L';
  p[PGSIZE + 4] = 'D';

  check(msync(fd) >= 0, "msync after first write");
  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "reopen readonly");

  memset(buf, 0, 2 * PGSIZE);
  check(read(fd, buf, 2 * PGSIZE) == 2 * PGSIZE, "read back full file");

  show5("file page0 after msync", buf);
  show5("file page1 after msync", buf + PGSIZE);

  check(buf[0] == 'H', "file page0[0]");
  check(buf[1] == 'E', "file page0[1]");
  check(buf[2] == 'L', "file page0[2]");
  check(buf[3] == 'L', "file page0[3]");
  check(buf[4] == 'O', "file page0[4]");

  check(buf[PGSIZE + 0] == 'W', "file page1[0]");
  check(buf[PGSIZE + 1] == 'O', "file page1[1]");
  check(buf[PGSIZE + 2] == 'R', "file page1[2]");
  check(buf[PGSIZE + 3] == 'L', "file page1[3]");
  check(buf[PGSIZE + 4] == 'D', "file page1[4]");

  close(fd);

  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "reopen rdwr second time");

  check(mmap((uint64)p, 2, PROT_READ | PROT_WRITE | PROT_PROP, fd) == 0,
        "remap 2 pages");

  p[1] = 'a';
  p[PGSIZE + 2] = 'x';

  check(msync(fd) >= 0, "msync after partial write");
  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "final reopen readonly");

  memset(buf, 0, 2 * PGSIZE);
  check(read(fd, buf, 2 * PGSIZE) == 2 * PGSIZE, "final read back");

  show5("final file page0", buf);
  show5("final file page1", buf + PGSIZE);

  check(buf[0] == 'H', "final page0[0]");
  check(buf[1] == 'a', "final page0[1]");
  check(buf[2] == 'L', "final page0[2]");
  check(buf[3] == 'L', "final page0[3]");
  check(buf[4] == 'O', "final page0[4]");

  check(buf[PGSIZE + 0] == 'W', "final page1[0]");
  check(buf[PGSIZE + 1] == 'O', "final page1[1]");
  check(buf[PGSIZE + 2] == 'x', "final page1[2]");
  check(buf[PGSIZE + 3] == 'L', "final page1[3]");
  check(buf[PGSIZE + 4] == 'D', "final page1[4]");

  close(fd);

  fd = open("mmapfile", O_RDWR);
  check(fd >= 0, "open for exit-writeback");

  check(mmap((uint64)p, 2,
             PROT_READ | PROT_WRITE | PROT_PROP | PROT_SHARE,
             fd) == 0,
        "mmap before fork");

  pid = fork();
  check(pid >= 0, "fork");

  if(pid == 0){
    p[0] = 'B';
    p[1] = 'Y';
    p[2] = 'E';
    p[3] = '!';
    p[4] = '!';

    p[PGSIZE + 0] = 'L';
    p[PGSIZE + 1] = 'A';
    p[PGSIZE + 2] = 'T';
    p[PGSIZE + 3] = 'E';
    p[PGSIZE + 4] = 'R';

    exit(0);
  }

  wait(&status);

  show5("parent page0 after child exit", p);
  show5("parent page1 after child exit", p + PGSIZE);

  check(p[0] == 'B', "shared page0[0]");
  check(p[1] == 'Y', "shared page0[1]");
  check(p[2] == 'E', "shared page0[2]");
  check(p[3] == '!', "shared page0[3]");
  check(p[4] == '!', "shared page0[4]");

  check(p[PGSIZE + 0] == 'L', "shared page1[0]");
  check(p[PGSIZE + 1] == 'A', "shared page1[1]");
  check(p[PGSIZE + 2] == 'T', "shared page1[2]");
  check(p[PGSIZE + 3] == 'E', "shared page1[3]");
  check(p[PGSIZE + 4] == 'R', "shared page1[4]");

  close(fd);

  fd = open("mmapfile", O_RDONLY);
  check(fd >= 0, "open verify after child exit");

  memset(buf, 0, 2 * PGSIZE);
  check(read(fd, buf, 2 * PGSIZE) == 2 * PGSIZE, "read after child exit");

  show5("file page0 after child exit", buf);
  show5("file page1 after child exit", buf + PGSIZE);

  check(buf[0] == 'B', "exit file page0[0]");
  check(buf[1] == 'Y', "exit file page0[1]");
  check(buf[2] == 'E', "exit file page0[2]");
  check(buf[3] == '!', "exit file page0[3]");
  check(buf[4] == '!', "exit file page0[4]");

  check(buf[PGSIZE + 0] == 'L', "exit file page1[0]");
  check(buf[PGSIZE + 1] == 'A', "exit file page1[1]");
  check(buf[PGSIZE + 2] == 'T', "exit file page1[2]");
  check(buf[PGSIZE + 3] == 'E', "exit file page1[3]");
  check(buf[PGSIZE + 4] == 'R', "exit file page1[4]");

  close(fd);

  printf("mmap/msync/exit-writeback/shared-fork test passed\n");
  exit(0);
}
