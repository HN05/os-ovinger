
user/_mmaptest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:


// written by chatgpt
int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  char *shared;
  int pid;

  printf("mapping shared page\n");
   8:	00001517          	auipc	a0,0x1
   c:	94850513          	addi	a0,a0,-1720 # 950 <malloc+0x108>
  10:	00000097          	auipc	ra,0x0
  14:	780080e7          	jalr	1920(ra) # 790 <printf>

  shared = sbrk(PGSIZE);
  18:	6505                	lui	a0,0x1
  1a:	00000097          	auipc	ra,0x0
  1e:	466080e7          	jalr	1126(ra) # 480 <sbrk>
  if(shared == (char*)-1){
  22:	57fd                	li	a5,-1
  24:	0af50c63          	beq	a0,a5,dc <main+0xdc>
  28:	e426                	sd	s1,8(sp)
  2a:	84aa                	mv	s1,a0
    printf("sbrk failed\n");
    exit(1);
  }

  shared[0] = 42;
  2c:	02a00793          	li	a5,42
  30:	00f50023          	sb	a5,0(a0) # 1000 <digits+0x518>

  if(mmap((uint64)shared, 1, PROT_READ | PROT_WRITE) == (uint64)-1){
  34:	460d                	li	a2,3
  36:	4585                	li	a1,1
  38:	00000097          	auipc	ra,0x0
  3c:	488080e7          	jalr	1160(ra) # 4c0 <mmap>
  40:	57fd                	li	a5,-1
  42:	0af50b63          	beq	a0,a5,f8 <main+0xf8>
    printf("mmap failed\n");
    exit(1);
  }

  pid = fork();
  46:	00000097          	auipc	ra,0x0
  4a:	3aa080e7          	jalr	938(ra) # 3f0 <fork>

  if(pid == 0){
  4e:	ed79                	bnez	a0,12c <main+0x12c>
    sleep(10);
  50:	4529                	li	a0,10
  52:	00000097          	auipc	ra,0x0
  56:	436080e7          	jalr	1078(ra) # 488 <sleep>

    printf("child read: %d\n", shared[0]);
  5a:	0004c583          	lbu	a1,0(s1)
  5e:	00001517          	auipc	a0,0x1
  62:	92a50513          	addi	a0,a0,-1750 # 988 <malloc+0x140>
  66:	00000097          	auipc	ra,0x0
  6a:	72a080e7          	jalr	1834(ra) # 790 <printf>

    shared[0] = 99;
  6e:	06300793          	li	a5,99
  72:	00f48023          	sb	a5,0(s1)
    printf("child wrote 99\n");
  76:	00001517          	auipc	a0,0x1
  7a:	92250513          	addi	a0,a0,-1758 # 998 <malloc+0x150>
  7e:	00000097          	auipc	ra,0x0
  82:	712080e7          	jalr	1810(ra) # 790 <printf>

    if(mmap((uint64)shared, 1, PROT_READ) == (uint64)-1){
  86:	4605                	li	a2,1
  88:	4585                	li	a1,1
  8a:	8526                	mv	a0,s1
  8c:	00000097          	auipc	ra,0x0
  90:	434080e7          	jalr	1076(ra) # 4c0 <mmap>
  94:	57fd                	li	a5,-1
  96:	06f50e63          	beq	a0,a5,112 <main+0x112>
      printf("child failed to restrict perms\n");
      exit(1);
    }

    printf("child restricted page to read-only\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	92e50513          	addi	a0,a0,-1746 # 9c8 <malloc+0x180>
  a2:	00000097          	auipc	ra,0x0
  a6:	6ee080e7          	jalr	1774(ra) # 790 <printf>

    printf("child attempting illegal write (should die)\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	94650513          	addi	a0,a0,-1722 # 9f0 <malloc+0x1a8>
  b2:	00000097          	auipc	ra,0x0
  b6:	6de080e7          	jalr	1758(ra) # 790 <printf>
    shared[0] = 55;
  ba:	03700793          	li	a5,55
  be:	00f48023          	sb	a5,0(s1)

    printf("ERROR: child survived illegal write\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	95e50513          	addi	a0,a0,-1698 # a20 <malloc+0x1d8>
  ca:	00000097          	auipc	ra,0x0
  ce:	6c6080e7          	jalr	1734(ra) # 790 <printf>
    exit(1);
  d2:	4505                	li	a0,1
  d4:	00000097          	auipc	ra,0x0
  d8:	324080e7          	jalr	804(ra) # 3f8 <exit>
  dc:	e426                	sd	s1,8(sp)
    printf("sbrk failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	88a50513          	addi	a0,a0,-1910 # 968 <malloc+0x120>
  e6:	00000097          	auipc	ra,0x0
  ea:	6aa080e7          	jalr	1706(ra) # 790 <printf>
    exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	308080e7          	jalr	776(ra) # 3f8 <exit>
    printf("mmap failed\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	88050513          	addi	a0,a0,-1920 # 978 <malloc+0x130>
 100:	00000097          	auipc	ra,0x0
 104:	690080e7          	jalr	1680(ra) # 790 <printf>
    exit(1);
 108:	4505                	li	a0,1
 10a:	00000097          	auipc	ra,0x0
 10e:	2ee080e7          	jalr	750(ra) # 3f8 <exit>
      printf("child failed to restrict perms\n");
 112:	00001517          	auipc	a0,0x1
 116:	89650513          	addi	a0,a0,-1898 # 9a8 <malloc+0x160>
 11a:	00000097          	auipc	ra,0x0
 11e:	676080e7          	jalr	1654(ra) # 790 <printf>
      exit(1);
 122:	4505                	li	a0,1
 124:	00000097          	auipc	ra,0x0
 128:	2d4080e7          	jalr	724(ra) # 3f8 <exit>
  }

  sleep(20);
 12c:	4551                	li	a0,20
 12e:	00000097          	auipc	ra,0x0
 132:	35a080e7          	jalr	858(ra) # 488 <sleep>

  printf("parent sees after child write: %d\n", shared[0]);
 136:	0004c583          	lbu	a1,0(s1)
 13a:	00001517          	auipc	a0,0x1
 13e:	90e50513          	addi	a0,a0,-1778 # a48 <malloc+0x200>
 142:	00000097          	auipc	ra,0x0
 146:	64e080e7          	jalr	1614(ra) # 790 <printf>

  wait(0);
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	2b4080e7          	jalr	692(ra) # 400 <wait>

  printf("parent still sees: %d\n", shared[0]);
 154:	0004c583          	lbu	a1,0(s1)
 158:	00001517          	auipc	a0,0x1
 15c:	91850513          	addi	a0,a0,-1768 # a70 <malloc+0x228>
 160:	00000097          	auipc	ra,0x0
 164:	630080e7          	jalr	1584(ra) # 790 <printf>

  exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	28e080e7          	jalr	654(ra) # 3f8 <exit>

0000000000000172 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 172:	1141                	addi	sp,sp,-16
 174:	e406                	sd	ra,8(sp)
 176:	e022                	sd	s0,0(sp)
 178:	0800                	addi	s0,sp,16
  extern int main();
  main();
 17a:	00000097          	auipc	ra,0x0
 17e:	e86080e7          	jalr	-378(ra) # 0 <main>
  exit(0);
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	274080e7          	jalr	628(ra) # 3f8 <exit>

000000000000018c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 192:	87aa                	mv	a5,a0
 194:	0585                	addi	a1,a1,1
 196:	0785                	addi	a5,a5,1
 198:	fff5c703          	lbu	a4,-1(a1)
 19c:	fee78fa3          	sb	a4,-1(a5)
 1a0:	fb75                	bnez	a4,194 <strcpy+0x8>
    ;
  return os;
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret

00000000000001a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cb91                	beqz	a5,1c6 <strcmp+0x1e>
 1b4:	0005c703          	lbu	a4,0(a1)
 1b8:	00f71763          	bne	a4,a5,1c6 <strcmp+0x1e>
    p++, q++;
 1bc:	0505                	addi	a0,a0,1
 1be:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	fbe5                	bnez	a5,1b4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c6:	0005c503          	lbu	a0,0(a1)
}
 1ca:	40a7853b          	subw	a0,a5,a0
 1ce:	6422                	ld	s0,8(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret

00000000000001d4 <strlen>:

uint
strlen(const char *s)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1da:	00054783          	lbu	a5,0(a0)
 1de:	cf91                	beqz	a5,1fa <strlen+0x26>
 1e0:	0505                	addi	a0,a0,1
 1e2:	87aa                	mv	a5,a0
 1e4:	86be                	mv	a3,a5
 1e6:	0785                	addi	a5,a5,1
 1e8:	fff7c703          	lbu	a4,-1(a5)
 1ec:	ff65                	bnez	a4,1e4 <strlen+0x10>
 1ee:	40a6853b          	subw	a0,a3,a0
 1f2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  for(n = 0; s[n]; n++)
 1fa:	4501                	li	a0,0
 1fc:	bfe5                	j	1f4 <strlen+0x20>

00000000000001fe <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 204:	ca19                	beqz	a2,21a <memset+0x1c>
 206:	87aa                	mv	a5,a0
 208:	1602                	slli	a2,a2,0x20
 20a:	9201                	srli	a2,a2,0x20
 20c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 210:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 214:	0785                	addi	a5,a5,1
 216:	fee79de3          	bne	a5,a4,210 <memset+0x12>
  }
  return dst;
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret

0000000000000220 <strchr>:

char*
strchr(const char *s, char c)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  for(; *s; s++)
 226:	00054783          	lbu	a5,0(a0)
 22a:	cb99                	beqz	a5,240 <strchr+0x20>
    if(*s == c)
 22c:	00f58763          	beq	a1,a5,23a <strchr+0x1a>
  for(; *s; s++)
 230:	0505                	addi	a0,a0,1
 232:	00054783          	lbu	a5,0(a0)
 236:	fbfd                	bnez	a5,22c <strchr+0xc>
      return (char*)s;
  return 0;
 238:	4501                	li	a0,0
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
  return 0;
 240:	4501                	li	a0,0
 242:	bfe5                	j	23a <strchr+0x1a>

0000000000000244 <gets>:

char*
gets(char *buf, int max)
{
 244:	711d                	addi	sp,sp,-96
 246:	ec86                	sd	ra,88(sp)
 248:	e8a2                	sd	s0,80(sp)
 24a:	e4a6                	sd	s1,72(sp)
 24c:	e0ca                	sd	s2,64(sp)
 24e:	fc4e                	sd	s3,56(sp)
 250:	f852                	sd	s4,48(sp)
 252:	f456                	sd	s5,40(sp)
 254:	f05a                	sd	s6,32(sp)
 256:	ec5e                	sd	s7,24(sp)
 258:	1080                	addi	s0,sp,96
 25a:	8baa                	mv	s7,a0
 25c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25e:	892a                	mv	s2,a0
 260:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 262:	4aa9                	li	s5,10
 264:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 266:	89a6                	mv	s3,s1
 268:	2485                	addiw	s1,s1,1
 26a:	0344d863          	bge	s1,s4,29a <gets+0x56>
    cc = read(0, &c, 1);
 26e:	4605                	li	a2,1
 270:	faf40593          	addi	a1,s0,-81
 274:	4501                	li	a0,0
 276:	00000097          	auipc	ra,0x0
 27a:	19a080e7          	jalr	410(ra) # 410 <read>
    if(cc < 1)
 27e:	00a05e63          	blez	a0,29a <gets+0x56>
    buf[i++] = c;
 282:	faf44783          	lbu	a5,-81(s0)
 286:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 28a:	01578763          	beq	a5,s5,298 <gets+0x54>
 28e:	0905                	addi	s2,s2,1
 290:	fd679be3          	bne	a5,s6,266 <gets+0x22>
    buf[i++] = c;
 294:	89a6                	mv	s3,s1
 296:	a011                	j	29a <gets+0x56>
 298:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 29a:	99de                	add	s3,s3,s7
 29c:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a0:	855e                	mv	a0,s7
 2a2:	60e6                	ld	ra,88(sp)
 2a4:	6446                	ld	s0,80(sp)
 2a6:	64a6                	ld	s1,72(sp)
 2a8:	6906                	ld	s2,64(sp)
 2aa:	79e2                	ld	s3,56(sp)
 2ac:	7a42                	ld	s4,48(sp)
 2ae:	7aa2                	ld	s5,40(sp)
 2b0:	7b02                	ld	s6,32(sp)
 2b2:	6be2                	ld	s7,24(sp)
 2b4:	6125                	addi	sp,sp,96
 2b6:	8082                	ret

00000000000002b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b8:	1101                	addi	sp,sp,-32
 2ba:	ec06                	sd	ra,24(sp)
 2bc:	e822                	sd	s0,16(sp)
 2be:	e04a                	sd	s2,0(sp)
 2c0:	1000                	addi	s0,sp,32
 2c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c4:	4581                	li	a1,0
 2c6:	00000097          	auipc	ra,0x0
 2ca:	172080e7          	jalr	370(ra) # 438 <open>
  if(fd < 0)
 2ce:	02054663          	bltz	a0,2fa <stat+0x42>
 2d2:	e426                	sd	s1,8(sp)
 2d4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d6:	85ca                	mv	a1,s2
 2d8:	00000097          	auipc	ra,0x0
 2dc:	178080e7          	jalr	376(ra) # 450 <fstat>
 2e0:	892a                	mv	s2,a0
  close(fd);
 2e2:	8526                	mv	a0,s1
 2e4:	00000097          	auipc	ra,0x0
 2e8:	13c080e7          	jalr	316(ra) # 420 <close>
  return r;
 2ec:	64a2                	ld	s1,8(sp)
}
 2ee:	854a                	mv	a0,s2
 2f0:	60e2                	ld	ra,24(sp)
 2f2:	6442                	ld	s0,16(sp)
 2f4:	6902                	ld	s2,0(sp)
 2f6:	6105                	addi	sp,sp,32
 2f8:	8082                	ret
    return -1;
 2fa:	597d                	li	s2,-1
 2fc:	bfcd                	j	2ee <stat+0x36>

00000000000002fe <atoi>:

int
atoi(const char *s)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e422                	sd	s0,8(sp)
 302:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 304:	00054683          	lbu	a3,0(a0)
 308:	fd06879b          	addiw	a5,a3,-48
 30c:	0ff7f793          	zext.b	a5,a5
 310:	4625                	li	a2,9
 312:	02f66863          	bltu	a2,a5,342 <atoi+0x44>
 316:	872a                	mv	a4,a0
  n = 0;
 318:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 31a:	0705                	addi	a4,a4,1
 31c:	0025179b          	slliw	a5,a0,0x2
 320:	9fa9                	addw	a5,a5,a0
 322:	0017979b          	slliw	a5,a5,0x1
 326:	9fb5                	addw	a5,a5,a3
 328:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 32c:	00074683          	lbu	a3,0(a4)
 330:	fd06879b          	addiw	a5,a3,-48
 334:	0ff7f793          	zext.b	a5,a5
 338:	fef671e3          	bgeu	a2,a5,31a <atoi+0x1c>
  return n;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  n = 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <atoi+0x3e>

0000000000000346 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 34c:	02b57463          	bgeu	a0,a1,374 <memmove+0x2e>
    while(n-- > 0)
 350:	00c05f63          	blez	a2,36e <memmove+0x28>
 354:	1602                	slli	a2,a2,0x20
 356:	9201                	srli	a2,a2,0x20
 358:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 35c:	872a                	mv	a4,a0
      *dst++ = *src++;
 35e:	0585                	addi	a1,a1,1
 360:	0705                	addi	a4,a4,1
 362:	fff5c683          	lbu	a3,-1(a1)
 366:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 36a:	fef71ae3          	bne	a4,a5,35e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36e:	6422                	ld	s0,8(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret
    dst += n;
 374:	00c50733          	add	a4,a0,a2
    src += n;
 378:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 37a:	fec05ae3          	blez	a2,36e <memmove+0x28>
 37e:	fff6079b          	addiw	a5,a2,-1
 382:	1782                	slli	a5,a5,0x20
 384:	9381                	srli	a5,a5,0x20
 386:	fff7c793          	not	a5,a5
 38a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 38c:	15fd                	addi	a1,a1,-1
 38e:	177d                	addi	a4,a4,-1
 390:	0005c683          	lbu	a3,0(a1)
 394:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 398:	fee79ae3          	bne	a5,a4,38c <memmove+0x46>
 39c:	bfc9                	j	36e <memmove+0x28>

000000000000039e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a4:	ca05                	beqz	a2,3d4 <memcmp+0x36>
 3a6:	fff6069b          	addiw	a3,a2,-1
 3aa:	1682                	slli	a3,a3,0x20
 3ac:	9281                	srli	a3,a3,0x20
 3ae:	0685                	addi	a3,a3,1
 3b0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b2:	00054783          	lbu	a5,0(a0)
 3b6:	0005c703          	lbu	a4,0(a1)
 3ba:	00e79863          	bne	a5,a4,3ca <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3be:	0505                	addi	a0,a0,1
    p2++;
 3c0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c2:	fed518e3          	bne	a0,a3,3b2 <memcmp+0x14>
  }
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	a019                	j	3ce <memcmp+0x30>
      return *p1 - *p2;
 3ca:	40e7853b          	subw	a0,a5,a4
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret
  return 0;
 3d4:	4501                	li	a0,0
 3d6:	bfe5                	j	3ce <memcmp+0x30>

00000000000003d8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e406                	sd	ra,8(sp)
 3dc:	e022                	sd	s0,0(sp)
 3de:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e0:	00000097          	auipc	ra,0x0
 3e4:	f66080e7          	jalr	-154(ra) # 346 <memmove>
}
 3e8:	60a2                	ld	ra,8(sp)
 3ea:	6402                	ld	s0,0(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret

00000000000003f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f0:	4885                	li	a7,1
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f8:	4889                	li	a7,2
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <wait>:
.global wait
wait:
 li a7, SYS_wait
 400:	488d                	li	a7,3
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 408:	4891                	li	a7,4
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <read>:
.global read
read:
 li a7, SYS_read
 410:	4895                	li	a7,5
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <write>:
.global write
write:
 li a7, SYS_write
 418:	48c1                	li	a7,16
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <close>:
.global close
close:
 li a7, SYS_close
 420:	48d5                	li	a7,21
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <kill>:
.global kill
kill:
 li a7, SYS_kill
 428:	4899                	li	a7,6
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exec>:
.global exec
exec:
 li a7, SYS_exec
 430:	489d                	li	a7,7
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <open>:
.global open
open:
 li a7, SYS_open
 438:	48bd                	li	a7,15
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 440:	48c5                	li	a7,17
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 448:	48c9                	li	a7,18
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 450:	48a1                	li	a7,8
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <link>:
.global link
link:
 li a7, SYS_link
 458:	48cd                	li	a7,19
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 460:	48d1                	li	a7,20
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 468:	48a5                	li	a7,9
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <dup>:
.global dup
dup:
 li a7, SYS_dup
 470:	48a9                	li	a7,10
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 478:	48ad                	li	a7,11
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 480:	48b1                	li	a7,12
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 488:	48b5                	li	a7,13
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 490:	48b9                	li	a7,14
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <ps>:
.global ps
ps:
 li a7, SYS_ps
 498:	48d9                	li	a7,22
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 4a0:	48dd                	li	a7,23
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 4a8:	48e1                	li	a7,24
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 4b0:	48e9                	li	a7,26
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 4b8:	48e5                	li	a7,25
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 4c0:	48ed                	li	a7,27
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c8:	1101                	addi	sp,sp,-32
 4ca:	ec06                	sd	ra,24(sp)
 4cc:	e822                	sd	s0,16(sp)
 4ce:	1000                	addi	s0,sp,32
 4d0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d4:	4605                	li	a2,1
 4d6:	fef40593          	addi	a1,s0,-17
 4da:	00000097          	auipc	ra,0x0
 4de:	f3e080e7          	jalr	-194(ra) # 418 <write>
}
 4e2:	60e2                	ld	ra,24(sp)
 4e4:	6442                	ld	s0,16(sp)
 4e6:	6105                	addi	sp,sp,32
 4e8:	8082                	ret

00000000000004ea <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ea:	7139                	addi	sp,sp,-64
 4ec:	fc06                	sd	ra,56(sp)
 4ee:	f822                	sd	s0,48(sp)
 4f0:	f426                	sd	s1,40(sp)
 4f2:	0080                	addi	s0,sp,64
 4f4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f6:	c299                	beqz	a3,4fc <printint+0x12>
 4f8:	0805cb63          	bltz	a1,58e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4fc:	2581                	sext.w	a1,a1
  neg = 0;
 4fe:	4881                	li	a7,0
 500:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 504:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 506:	2601                	sext.w	a2,a2
 508:	00000517          	auipc	a0,0x0
 50c:	5e050513          	addi	a0,a0,1504 # ae8 <digits>
 510:	883a                	mv	a6,a4
 512:	2705                	addiw	a4,a4,1
 514:	02c5f7bb          	remuw	a5,a1,a2
 518:	1782                	slli	a5,a5,0x20
 51a:	9381                	srli	a5,a5,0x20
 51c:	97aa                	add	a5,a5,a0
 51e:	0007c783          	lbu	a5,0(a5)
 522:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 526:	0005879b          	sext.w	a5,a1
 52a:	02c5d5bb          	divuw	a1,a1,a2
 52e:	0685                	addi	a3,a3,1
 530:	fec7f0e3          	bgeu	a5,a2,510 <printint+0x26>
  if(neg)
 534:	00088c63          	beqz	a7,54c <printint+0x62>
    buf[i++] = '-';
 538:	fd070793          	addi	a5,a4,-48
 53c:	00878733          	add	a4,a5,s0
 540:	02d00793          	li	a5,45
 544:	fef70823          	sb	a5,-16(a4)
 548:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 54c:	02e05c63          	blez	a4,584 <printint+0x9a>
 550:	f04a                	sd	s2,32(sp)
 552:	ec4e                	sd	s3,24(sp)
 554:	fc040793          	addi	a5,s0,-64
 558:	00e78933          	add	s2,a5,a4
 55c:	fff78993          	addi	s3,a5,-1
 560:	99ba                	add	s3,s3,a4
 562:	377d                	addiw	a4,a4,-1
 564:	1702                	slli	a4,a4,0x20
 566:	9301                	srli	a4,a4,0x20
 568:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56c:	fff94583          	lbu	a1,-1(s2)
 570:	8526                	mv	a0,s1
 572:	00000097          	auipc	ra,0x0
 576:	f56080e7          	jalr	-170(ra) # 4c8 <putc>
  while(--i >= 0)
 57a:	197d                	addi	s2,s2,-1
 57c:	ff3918e3          	bne	s2,s3,56c <printint+0x82>
 580:	7902                	ld	s2,32(sp)
 582:	69e2                	ld	s3,24(sp)
}
 584:	70e2                	ld	ra,56(sp)
 586:	7442                	ld	s0,48(sp)
 588:	74a2                	ld	s1,40(sp)
 58a:	6121                	addi	sp,sp,64
 58c:	8082                	ret
    x = -xx;
 58e:	40b005bb          	negw	a1,a1
    neg = 1;
 592:	4885                	li	a7,1
    x = -xx;
 594:	b7b5                	j	500 <printint+0x16>

0000000000000596 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 596:	715d                	addi	sp,sp,-80
 598:	e486                	sd	ra,72(sp)
 59a:	e0a2                	sd	s0,64(sp)
 59c:	f84a                	sd	s2,48(sp)
 59e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a0:	0005c903          	lbu	s2,0(a1)
 5a4:	1a090a63          	beqz	s2,758 <vprintf+0x1c2>
 5a8:	fc26                	sd	s1,56(sp)
 5aa:	f44e                	sd	s3,40(sp)
 5ac:	f052                	sd	s4,32(sp)
 5ae:	ec56                	sd	s5,24(sp)
 5b0:	e85a                	sd	s6,16(sp)
 5b2:	e45e                	sd	s7,8(sp)
 5b4:	8aaa                	mv	s5,a0
 5b6:	8bb2                	mv	s7,a2
 5b8:	00158493          	addi	s1,a1,1
  state = 0;
 5bc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5be:	02500a13          	li	s4,37
 5c2:	4b55                	li	s6,21
 5c4:	a839                	j	5e2 <vprintf+0x4c>
        putc(fd, c);
 5c6:	85ca                	mv	a1,s2
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	efe080e7          	jalr	-258(ra) # 4c8 <putc>
 5d2:	a019                	j	5d8 <vprintf+0x42>
    } else if(state == '%'){
 5d4:	01498d63          	beq	s3,s4,5ee <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5d8:	0485                	addi	s1,s1,1
 5da:	fff4c903          	lbu	s2,-1(s1)
 5de:	16090763          	beqz	s2,74c <vprintf+0x1b6>
    if(state == 0){
 5e2:	fe0999e3          	bnez	s3,5d4 <vprintf+0x3e>
      if(c == '%'){
 5e6:	ff4910e3          	bne	s2,s4,5c6 <vprintf+0x30>
        state = '%';
 5ea:	89d2                	mv	s3,s4
 5ec:	b7f5                	j	5d8 <vprintf+0x42>
      if(c == 'd'){
 5ee:	13490463          	beq	s2,s4,716 <vprintf+0x180>
 5f2:	f9d9079b          	addiw	a5,s2,-99
 5f6:	0ff7f793          	zext.b	a5,a5
 5fa:	12fb6763          	bltu	s6,a5,728 <vprintf+0x192>
 5fe:	f9d9079b          	addiw	a5,s2,-99
 602:	0ff7f713          	zext.b	a4,a5
 606:	12eb6163          	bltu	s6,a4,728 <vprintf+0x192>
 60a:	00271793          	slli	a5,a4,0x2
 60e:	00000717          	auipc	a4,0x0
 612:	48270713          	addi	a4,a4,1154 # a90 <malloc+0x248>
 616:	97ba                	add	a5,a5,a4
 618:	439c                	lw	a5,0(a5)
 61a:	97ba                	add	a5,a5,a4
 61c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 61e:	008b8913          	addi	s2,s7,8
 622:	4685                	li	a3,1
 624:	4629                	li	a2,10
 626:	000ba583          	lw	a1,0(s7)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	ebe080e7          	jalr	-322(ra) # 4ea <printint>
 634:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 636:	4981                	li	s3,0
 638:	b745                	j	5d8 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4629                	li	a2,10
 642:	000ba583          	lw	a1,0(s7)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	ea2080e7          	jalr	-350(ra) # 4ea <printint>
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	b751                	j	5d8 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 656:	008b8913          	addi	s2,s7,8
 65a:	4681                	li	a3,0
 65c:	4641                	li	a2,16
 65e:	000ba583          	lw	a1,0(s7)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e86080e7          	jalr	-378(ra) # 4ea <printint>
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	b7a5                	j	5d8 <vprintf+0x42>
 672:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 674:	008b8c13          	addi	s8,s7,8
 678:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 67c:	03000593          	li	a1,48
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e46080e7          	jalr	-442(ra) # 4c8 <putc>
  putc(fd, 'x');
 68a:	07800593          	li	a1,120
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e38080e7          	jalr	-456(ra) # 4c8 <putc>
 698:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69a:	00000b97          	auipc	s7,0x0
 69e:	44eb8b93          	addi	s7,s7,1102 # ae8 <digits>
 6a2:	03c9d793          	srli	a5,s3,0x3c
 6a6:	97de                	add	a5,a5,s7
 6a8:	0007c583          	lbu	a1,0(a5)
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	e1a080e7          	jalr	-486(ra) # 4c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b6:	0992                	slli	s3,s3,0x4
 6b8:	397d                	addiw	s2,s2,-1
 6ba:	fe0914e3          	bnez	s2,6a2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6be:	8be2                	mv	s7,s8
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	6c02                	ld	s8,0(sp)
 6c4:	bf11                	j	5d8 <vprintf+0x42>
        s = va_arg(ap, char*);
 6c6:	008b8993          	addi	s3,s7,8
 6ca:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6ce:	02090163          	beqz	s2,6f0 <vprintf+0x15a>
        while(*s != 0){
 6d2:	00094583          	lbu	a1,0(s2)
 6d6:	c9a5                	beqz	a1,746 <vprintf+0x1b0>
          putc(fd, *s);
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	dee080e7          	jalr	-530(ra) # 4c8 <putc>
          s++;
 6e2:	0905                	addi	s2,s2,1
        while(*s != 0){
 6e4:	00094583          	lbu	a1,0(s2)
 6e8:	f9e5                	bnez	a1,6d8 <vprintf+0x142>
        s = va_arg(ap, char*);
 6ea:	8bce                	mv	s7,s3
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b5ed                	j	5d8 <vprintf+0x42>
          s = "(null)";
 6f0:	00000917          	auipc	s2,0x0
 6f4:	39890913          	addi	s2,s2,920 # a88 <malloc+0x240>
        while(*s != 0){
 6f8:	02800593          	li	a1,40
 6fc:	bff1                	j	6d8 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6fe:	008b8913          	addi	s2,s7,8
 702:	000bc583          	lbu	a1,0(s7)
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	dc0080e7          	jalr	-576(ra) # 4c8 <putc>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	b5d1                	j	5d8 <vprintf+0x42>
        putc(fd, c);
 716:	02500593          	li	a1,37
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	dac080e7          	jalr	-596(ra) # 4c8 <putc>
      state = 0;
 724:	4981                	li	s3,0
 726:	bd4d                	j	5d8 <vprintf+0x42>
        putc(fd, '%');
 728:	02500593          	li	a1,37
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	d9a080e7          	jalr	-614(ra) # 4c8 <putc>
        putc(fd, c);
 736:	85ca                	mv	a1,s2
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	d8e080e7          	jalr	-626(ra) # 4c8 <putc>
      state = 0;
 742:	4981                	li	s3,0
 744:	bd51                	j	5d8 <vprintf+0x42>
        s = va_arg(ap, char*);
 746:	8bce                	mv	s7,s3
      state = 0;
 748:	4981                	li	s3,0
 74a:	b579                	j	5d8 <vprintf+0x42>
 74c:	74e2                	ld	s1,56(sp)
 74e:	79a2                	ld	s3,40(sp)
 750:	7a02                	ld	s4,32(sp)
 752:	6ae2                	ld	s5,24(sp)
 754:	6b42                	ld	s6,16(sp)
 756:	6ba2                	ld	s7,8(sp)
    }
  }
}
 758:	60a6                	ld	ra,72(sp)
 75a:	6406                	ld	s0,64(sp)
 75c:	7942                	ld	s2,48(sp)
 75e:	6161                	addi	sp,sp,80
 760:	8082                	ret

0000000000000762 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 762:	715d                	addi	sp,sp,-80
 764:	ec06                	sd	ra,24(sp)
 766:	e822                	sd	s0,16(sp)
 768:	1000                	addi	s0,sp,32
 76a:	e010                	sd	a2,0(s0)
 76c:	e414                	sd	a3,8(s0)
 76e:	e818                	sd	a4,16(s0)
 770:	ec1c                	sd	a5,24(s0)
 772:	03043023          	sd	a6,32(s0)
 776:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 77a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 77e:	8622                	mv	a2,s0
 780:	00000097          	auipc	ra,0x0
 784:	e16080e7          	jalr	-490(ra) # 596 <vprintf>
}
 788:	60e2                	ld	ra,24(sp)
 78a:	6442                	ld	s0,16(sp)
 78c:	6161                	addi	sp,sp,80
 78e:	8082                	ret

0000000000000790 <printf>:

void
printf(const char *fmt, ...)
{
 790:	711d                	addi	sp,sp,-96
 792:	ec06                	sd	ra,24(sp)
 794:	e822                	sd	s0,16(sp)
 796:	1000                	addi	s0,sp,32
 798:	e40c                	sd	a1,8(s0)
 79a:	e810                	sd	a2,16(s0)
 79c:	ec14                	sd	a3,24(s0)
 79e:	f018                	sd	a4,32(s0)
 7a0:	f41c                	sd	a5,40(s0)
 7a2:	03043823          	sd	a6,48(s0)
 7a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7aa:	00840613          	addi	a2,s0,8
 7ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b2:	85aa                	mv	a1,a0
 7b4:	4505                	li	a0,1
 7b6:	00000097          	auipc	ra,0x0
 7ba:	de0080e7          	jalr	-544(ra) # 596 <vprintf>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6125                	addi	sp,sp,96
 7c4:	8082                	ret

00000000000007c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c6:	1141                	addi	sp,sp,-16
 7c8:	e422                	sd	s0,8(sp)
 7ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7cc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d0:	00001797          	auipc	a5,0x1
 7d4:	c107b783          	ld	a5,-1008(a5) # 13e0 <freep>
 7d8:	a02d                	j	802 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7da:	4618                	lw	a4,8(a2)
 7dc:	9f2d                	addw	a4,a4,a1
 7de:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e2:	6398                	ld	a4,0(a5)
 7e4:	6310                	ld	a2,0(a4)
 7e6:	a83d                	j	824 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e8:	ff852703          	lw	a4,-8(a0)
 7ec:	9f31                	addw	a4,a4,a2
 7ee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f0:	ff053683          	ld	a3,-16(a0)
 7f4:	a091                	j	838 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e7e463          	bltu	a5,a4,800 <free+0x3a>
 7fc:	00e6ea63          	bltu	a3,a4,810 <free+0x4a>
{
 800:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	fed7fae3          	bgeu	a5,a3,7f6 <free+0x30>
 806:	6398                	ld	a4,0(a5)
 808:	00e6e463          	bltu	a3,a4,810 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	fee7eae3          	bltu	a5,a4,800 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 810:	ff852583          	lw	a1,-8(a0)
 814:	6390                	ld	a2,0(a5)
 816:	02059813          	slli	a6,a1,0x20
 81a:	01c85713          	srli	a4,a6,0x1c
 81e:	9736                	add	a4,a4,a3
 820:	fae60de3          	beq	a2,a4,7da <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 824:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 828:	4790                	lw	a2,8(a5)
 82a:	02061593          	slli	a1,a2,0x20
 82e:	01c5d713          	srli	a4,a1,0x1c
 832:	973e                	add	a4,a4,a5
 834:	fae68ae3          	beq	a3,a4,7e8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 838:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83a:	00001717          	auipc	a4,0x1
 83e:	baf73323          	sd	a5,-1114(a4) # 13e0 <freep>
}
 842:	6422                	ld	s0,8(sp)
 844:	0141                	addi	sp,sp,16
 846:	8082                	ret

0000000000000848 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 848:	7139                	addi	sp,sp,-64
 84a:	fc06                	sd	ra,56(sp)
 84c:	f822                	sd	s0,48(sp)
 84e:	f426                	sd	s1,40(sp)
 850:	ec4e                	sd	s3,24(sp)
 852:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 854:	02051493          	slli	s1,a0,0x20
 858:	9081                	srli	s1,s1,0x20
 85a:	04bd                	addi	s1,s1,15
 85c:	8091                	srli	s1,s1,0x4
 85e:	0014899b          	addiw	s3,s1,1
 862:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 864:	00001517          	auipc	a0,0x1
 868:	b7c53503          	ld	a0,-1156(a0) # 13e0 <freep>
 86c:	c915                	beqz	a0,8a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	08977e63          	bgeu	a4,s1,90e <malloc+0xc6>
 876:	f04a                	sd	s2,32(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 87e:	8a4e                	mv	s4,s3
 880:	0009871b          	sext.w	a4,s3
 884:	6685                	lui	a3,0x1
 886:	00d77363          	bgeu	a4,a3,88c <malloc+0x44>
 88a:	6a05                	lui	s4,0x1
 88c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 890:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 894:	00001917          	auipc	s2,0x1
 898:	b4c90913          	addi	s2,s2,-1204 # 13e0 <freep>
  if(p == (char*)-1)
 89c:	5afd                	li	s5,-1
 89e:	a091                	j	8e2 <malloc+0x9a>
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a8:	00001797          	auipc	a5,0x1
 8ac:	b4878793          	addi	a5,a5,-1208 # 13f0 <base>
 8b0:	00001717          	auipc	a4,0x1
 8b4:	b2f73823          	sd	a5,-1232(a4) # 13e0 <freep>
 8b8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ba:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8be:	b7c1                	j	87e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8c0:	6398                	ld	a4,0(a5)
 8c2:	e118                	sd	a4,0(a0)
 8c4:	a08d                	j	926 <malloc+0xde>
  hp->s.size = nu;
 8c6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ca:	0541                	addi	a0,a0,16
 8cc:	00000097          	auipc	ra,0x0
 8d0:	efa080e7          	jalr	-262(ra) # 7c6 <free>
  return freep;
 8d4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d8:	c13d                	beqz	a0,93e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	02977463          	bgeu	a4,s1,906 <malloc+0xbe>
    if(p == freep)
 8e2:	00093703          	ld	a4,0(s2)
 8e6:	853e                	mv	a0,a5
 8e8:	fef719e3          	bne	a4,a5,8da <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 8ec:	8552                	mv	a0,s4
 8ee:	00000097          	auipc	ra,0x0
 8f2:	b92080e7          	jalr	-1134(ra) # 480 <sbrk>
  if(p == (char*)-1)
 8f6:	fd5518e3          	bne	a0,s5,8c6 <malloc+0x7e>
        return 0;
 8fa:	4501                	li	a0,0
 8fc:	7902                	ld	s2,32(sp)
 8fe:	6a42                	ld	s4,16(sp)
 900:	6aa2                	ld	s5,8(sp)
 902:	6b02                	ld	s6,0(sp)
 904:	a03d                	j	932 <malloc+0xea>
 906:	7902                	ld	s2,32(sp)
 908:	6a42                	ld	s4,16(sp)
 90a:	6aa2                	ld	s5,8(sp)
 90c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 90e:	fae489e3          	beq	s1,a4,8c0 <malloc+0x78>
        p->s.size -= nunits;
 912:	4137073b          	subw	a4,a4,s3
 916:	c798                	sw	a4,8(a5)
        p += p->s.size;
 918:	02071693          	slli	a3,a4,0x20
 91c:	01c6d713          	srli	a4,a3,0x1c
 920:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 922:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 926:	00001717          	auipc	a4,0x1
 92a:	aaa73d23          	sd	a0,-1350(a4) # 13e0 <freep>
      return (void*)(p + 1);
 92e:	01078513          	addi	a0,a5,16
  }
}
 932:	70e2                	ld	ra,56(sp)
 934:	7442                	ld	s0,48(sp)
 936:	74a2                	ld	s1,40(sp)
 938:	69e2                	ld	s3,24(sp)
 93a:	6121                	addi	sp,sp,64
 93c:	8082                	ret
 93e:	7902                	ld	s2,32(sp)
 940:	6a42                	ld	s4,16(sp)
 942:	6aa2                	ld	s5,8(sp)
 944:	6b02                	ld	s6,0(sp)
 946:	b7f5                	j	932 <malloc+0xea>
