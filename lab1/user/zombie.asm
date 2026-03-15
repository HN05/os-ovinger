
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	4c6080e7          	jalr	1222(ra) # 4ce <fork>
  10:	87aa                	mv	a5,a0
  12:	00f05763          	blez	a5,20 <main+0x20>
    sleep(5);  // Let child exit before parent.
  16:	4515                	li	a0,5
  18:	00000097          	auipc	ra,0x0
  1c:	54e080e7          	jalr	1358(ra) # 566 <sleep>
  exit(0);
  20:	4501                	li	a0,0
  22:	00000097          	auipc	ra,0x0
  26:	4b4080e7          	jalr	1204(ra) # 4d6 <exit>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	49a080e7          	jalr	1178(ra) # 4d6 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	7179                	addi	sp,sp,-48
  46:	f422                	sd	s0,40(sp)
  48:	1800                	addi	s0,sp,48
  4a:	fca43c23          	sd	a0,-40(s0)
  4e:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  52:	fd843783          	ld	a5,-40(s0)
  56:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  5a:	0001                	nop
  5c:	fd043703          	ld	a4,-48(s0)
  60:	00170793          	addi	a5,a4,1
  64:	fcf43823          	sd	a5,-48(s0)
  68:	fd843783          	ld	a5,-40(s0)
  6c:	00178693          	addi	a3,a5,1
  70:	fcd43c23          	sd	a3,-40(s0)
  74:	00074703          	lbu	a4,0(a4)
  78:	00e78023          	sb	a4,0(a5)
  7c:	0007c783          	lbu	a5,0(a5)
  80:	fff1                	bnez	a5,5c <strcpy+0x18>
    ;
  return os;
  82:	fe843783          	ld	a5,-24(s0)
}
  86:	853e                	mv	a0,a5
  88:	7422                	ld	s0,40(sp)
  8a:	6145                	addi	sp,sp,48
  8c:	8082                	ret

000000000000008e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8e:	1101                	addi	sp,sp,-32
  90:	ec22                	sd	s0,24(sp)
  92:	1000                	addi	s0,sp,32
  94:	fea43423          	sd	a0,-24(s0)
  98:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
  9c:	a819                	j	b2 <strcmp+0x24>
    p++, q++;
  9e:	fe843783          	ld	a5,-24(s0)
  a2:	0785                	addi	a5,a5,1
  a4:	fef43423          	sd	a5,-24(s0)
  a8:	fe043783          	ld	a5,-32(s0)
  ac:	0785                	addi	a5,a5,1
  ae:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
  b2:	fe843783          	ld	a5,-24(s0)
  b6:	0007c783          	lbu	a5,0(a5)
  ba:	cb99                	beqz	a5,d0 <strcmp+0x42>
  bc:	fe843783          	ld	a5,-24(s0)
  c0:	0007c703          	lbu	a4,0(a5)
  c4:	fe043783          	ld	a5,-32(s0)
  c8:	0007c783          	lbu	a5,0(a5)
  cc:	fcf709e3          	beq	a4,a5,9e <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
  d0:	fe843783          	ld	a5,-24(s0)
  d4:	0007c783          	lbu	a5,0(a5)
  d8:	0007871b          	sext.w	a4,a5
  dc:	fe043783          	ld	a5,-32(s0)
  e0:	0007c783          	lbu	a5,0(a5)
  e4:	2781                	sext.w	a5,a5
  e6:	40f707bb          	subw	a5,a4,a5
  ea:	2781                	sext.w	a5,a5
}
  ec:	853e                	mv	a0,a5
  ee:	6462                	ld	s0,24(sp)
  f0:	6105                	addi	sp,sp,32
  f2:	8082                	ret

00000000000000f4 <strlen>:

uint
strlen(const char *s)
{
  f4:	7179                	addi	sp,sp,-48
  f6:	f422                	sd	s0,40(sp)
  f8:	1800                	addi	s0,sp,48
  fa:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
  fe:	fe042623          	sw	zero,-20(s0)
 102:	a031                	j	10e <strlen+0x1a>
 104:	fec42783          	lw	a5,-20(s0)
 108:	2785                	addiw	a5,a5,1
 10a:	fef42623          	sw	a5,-20(s0)
 10e:	fec42783          	lw	a5,-20(s0)
 112:	fd843703          	ld	a4,-40(s0)
 116:	97ba                	add	a5,a5,a4
 118:	0007c783          	lbu	a5,0(a5)
 11c:	f7e5                	bnez	a5,104 <strlen+0x10>
    ;
  return n;
 11e:	fec42783          	lw	a5,-20(s0)
}
 122:	853e                	mv	a0,a5
 124:	7422                	ld	s0,40(sp)
 126:	6145                	addi	sp,sp,48
 128:	8082                	ret

000000000000012a <memset>:

void*
memset(void *dst, int c, uint n)
{
 12a:	7179                	addi	sp,sp,-48
 12c:	f422                	sd	s0,40(sp)
 12e:	1800                	addi	s0,sp,48
 130:	fca43c23          	sd	a0,-40(s0)
 134:	87ae                	mv	a5,a1
 136:	8732                	mv	a4,a2
 138:	fcf42a23          	sw	a5,-44(s0)
 13c:	87ba                	mv	a5,a4
 13e:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 142:	fd843783          	ld	a5,-40(s0)
 146:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 14a:	fe042623          	sw	zero,-20(s0)
 14e:	a00d                	j	170 <memset+0x46>
    cdst[i] = c;
 150:	fec42783          	lw	a5,-20(s0)
 154:	fe043703          	ld	a4,-32(s0)
 158:	97ba                	add	a5,a5,a4
 15a:	fd442703          	lw	a4,-44(s0)
 15e:	0ff77713          	zext.b	a4,a4
 162:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 166:	fec42783          	lw	a5,-20(s0)
 16a:	2785                	addiw	a5,a5,1
 16c:	fef42623          	sw	a5,-20(s0)
 170:	fec42703          	lw	a4,-20(s0)
 174:	fd042783          	lw	a5,-48(s0)
 178:	2781                	sext.w	a5,a5
 17a:	fcf76be3          	bltu	a4,a5,150 <memset+0x26>
  }
  return dst;
 17e:	fd843783          	ld	a5,-40(s0)
}
 182:	853e                	mv	a0,a5
 184:	7422                	ld	s0,40(sp)
 186:	6145                	addi	sp,sp,48
 188:	8082                	ret

000000000000018a <strchr>:

char*
strchr(const char *s, char c)
{
 18a:	1101                	addi	sp,sp,-32
 18c:	ec22                	sd	s0,24(sp)
 18e:	1000                	addi	s0,sp,32
 190:	fea43423          	sd	a0,-24(s0)
 194:	87ae                	mv	a5,a1
 196:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 19a:	a01d                	j	1c0 <strchr+0x36>
    if(*s == c)
 19c:	fe843783          	ld	a5,-24(s0)
 1a0:	0007c703          	lbu	a4,0(a5)
 1a4:	fe744783          	lbu	a5,-25(s0)
 1a8:	0ff7f793          	zext.b	a5,a5
 1ac:	00e79563          	bne	a5,a4,1b6 <strchr+0x2c>
      return (char*)s;
 1b0:	fe843783          	ld	a5,-24(s0)
 1b4:	a821                	j	1cc <strchr+0x42>
  for(; *s; s++)
 1b6:	fe843783          	ld	a5,-24(s0)
 1ba:	0785                	addi	a5,a5,1
 1bc:	fef43423          	sd	a5,-24(s0)
 1c0:	fe843783          	ld	a5,-24(s0)
 1c4:	0007c783          	lbu	a5,0(a5)
 1c8:	fbf1                	bnez	a5,19c <strchr+0x12>
  return 0;
 1ca:	4781                	li	a5,0
}
 1cc:	853e                	mv	a0,a5
 1ce:	6462                	ld	s0,24(sp)
 1d0:	6105                	addi	sp,sp,32
 1d2:	8082                	ret

00000000000001d4 <gets>:

char*
gets(char *buf, int max)
{
 1d4:	7179                	addi	sp,sp,-48
 1d6:	f406                	sd	ra,40(sp)
 1d8:	f022                	sd	s0,32(sp)
 1da:	1800                	addi	s0,sp,48
 1dc:	fca43c23          	sd	a0,-40(s0)
 1e0:	87ae                	mv	a5,a1
 1e2:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e6:	fe042623          	sw	zero,-20(s0)
 1ea:	a8a1                	j	242 <gets+0x6e>
    cc = read(0, &c, 1);
 1ec:	fe740793          	addi	a5,s0,-25
 1f0:	4605                	li	a2,1
 1f2:	85be                	mv	a1,a5
 1f4:	4501                	li	a0,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	2f8080e7          	jalr	760(ra) # 4ee <read>
 1fe:	87aa                	mv	a5,a0
 200:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 204:	fe842783          	lw	a5,-24(s0)
 208:	2781                	sext.w	a5,a5
 20a:	04f05763          	blez	a5,258 <gets+0x84>
      break;
    buf[i++] = c;
 20e:	fec42783          	lw	a5,-20(s0)
 212:	0017871b          	addiw	a4,a5,1
 216:	fee42623          	sw	a4,-20(s0)
 21a:	873e                	mv	a4,a5
 21c:	fd843783          	ld	a5,-40(s0)
 220:	97ba                	add	a5,a5,a4
 222:	fe744703          	lbu	a4,-25(s0)
 226:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 22a:	fe744783          	lbu	a5,-25(s0)
 22e:	873e                	mv	a4,a5
 230:	47a9                	li	a5,10
 232:	02f70463          	beq	a4,a5,25a <gets+0x86>
 236:	fe744783          	lbu	a5,-25(s0)
 23a:	873e                	mv	a4,a5
 23c:	47b5                	li	a5,13
 23e:	00f70e63          	beq	a4,a5,25a <gets+0x86>
  for(i=0; i+1 < max; ){
 242:	fec42783          	lw	a5,-20(s0)
 246:	2785                	addiw	a5,a5,1
 248:	0007871b          	sext.w	a4,a5
 24c:	fd442783          	lw	a5,-44(s0)
 250:	2781                	sext.w	a5,a5
 252:	f8f74de3          	blt	a4,a5,1ec <gets+0x18>
 256:	a011                	j	25a <gets+0x86>
      break;
 258:	0001                	nop
      break;
  }
  buf[i] = '\0';
 25a:	fec42783          	lw	a5,-20(s0)
 25e:	fd843703          	ld	a4,-40(s0)
 262:	97ba                	add	a5,a5,a4
 264:	00078023          	sb	zero,0(a5)
  return buf;
 268:	fd843783          	ld	a5,-40(s0)
}
 26c:	853e                	mv	a0,a5
 26e:	70a2                	ld	ra,40(sp)
 270:	7402                	ld	s0,32(sp)
 272:	6145                	addi	sp,sp,48
 274:	8082                	ret

0000000000000276 <stat>:

int
stat(const char *n, struct stat *st)
{
 276:	7179                	addi	sp,sp,-48
 278:	f406                	sd	ra,40(sp)
 27a:	f022                	sd	s0,32(sp)
 27c:	1800                	addi	s0,sp,48
 27e:	fca43c23          	sd	a0,-40(s0)
 282:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 286:	4581                	li	a1,0
 288:	fd843503          	ld	a0,-40(s0)
 28c:	00000097          	auipc	ra,0x0
 290:	28a080e7          	jalr	650(ra) # 516 <open>
 294:	87aa                	mv	a5,a0
 296:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 29a:	fec42783          	lw	a5,-20(s0)
 29e:	2781                	sext.w	a5,a5
 2a0:	0007d463          	bgez	a5,2a8 <stat+0x32>
    return -1;
 2a4:	57fd                	li	a5,-1
 2a6:	a035                	j	2d2 <stat+0x5c>
  r = fstat(fd, st);
 2a8:	fec42783          	lw	a5,-20(s0)
 2ac:	fd043583          	ld	a1,-48(s0)
 2b0:	853e                	mv	a0,a5
 2b2:	00000097          	auipc	ra,0x0
 2b6:	27c080e7          	jalr	636(ra) # 52e <fstat>
 2ba:	87aa                	mv	a5,a0
 2bc:	fef42423          	sw	a5,-24(s0)
  close(fd);
 2c0:	fec42783          	lw	a5,-20(s0)
 2c4:	853e                	mv	a0,a5
 2c6:	00000097          	auipc	ra,0x0
 2ca:	238080e7          	jalr	568(ra) # 4fe <close>
  return r;
 2ce:	fe842783          	lw	a5,-24(s0)
}
 2d2:	853e                	mv	a0,a5
 2d4:	70a2                	ld	ra,40(sp)
 2d6:	7402                	ld	s0,32(sp)
 2d8:	6145                	addi	sp,sp,48
 2da:	8082                	ret

00000000000002dc <atoi>:

int
atoi(const char *s)
{
 2dc:	7179                	addi	sp,sp,-48
 2de:	f422                	sd	s0,40(sp)
 2e0:	1800                	addi	s0,sp,48
 2e2:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 2e6:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 2ea:	a81d                	j	320 <atoi+0x44>
    n = n*10 + *s++ - '0';
 2ec:	fec42783          	lw	a5,-20(s0)
 2f0:	873e                	mv	a4,a5
 2f2:	87ba                	mv	a5,a4
 2f4:	0027979b          	slliw	a5,a5,0x2
 2f8:	9fb9                	addw	a5,a5,a4
 2fa:	0017979b          	slliw	a5,a5,0x1
 2fe:	0007871b          	sext.w	a4,a5
 302:	fd843783          	ld	a5,-40(s0)
 306:	00178693          	addi	a3,a5,1
 30a:	fcd43c23          	sd	a3,-40(s0)
 30e:	0007c783          	lbu	a5,0(a5)
 312:	2781                	sext.w	a5,a5
 314:	9fb9                	addw	a5,a5,a4
 316:	2781                	sext.w	a5,a5
 318:	fd07879b          	addiw	a5,a5,-48
 31c:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 320:	fd843783          	ld	a5,-40(s0)
 324:	0007c783          	lbu	a5,0(a5)
 328:	873e                	mv	a4,a5
 32a:	02f00793          	li	a5,47
 32e:	00e7fb63          	bgeu	a5,a4,344 <atoi+0x68>
 332:	fd843783          	ld	a5,-40(s0)
 336:	0007c783          	lbu	a5,0(a5)
 33a:	873e                	mv	a4,a5
 33c:	03900793          	li	a5,57
 340:	fae7f6e3          	bgeu	a5,a4,2ec <atoi+0x10>
  return n;
 344:	fec42783          	lw	a5,-20(s0)
}
 348:	853e                	mv	a0,a5
 34a:	7422                	ld	s0,40(sp)
 34c:	6145                	addi	sp,sp,48
 34e:	8082                	ret

0000000000000350 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 350:	7139                	addi	sp,sp,-64
 352:	fc22                	sd	s0,56(sp)
 354:	0080                	addi	s0,sp,64
 356:	fca43c23          	sd	a0,-40(s0)
 35a:	fcb43823          	sd	a1,-48(s0)
 35e:	87b2                	mv	a5,a2
 360:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 364:	fd843783          	ld	a5,-40(s0)
 368:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 36c:	fd043783          	ld	a5,-48(s0)
 370:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 374:	fe043703          	ld	a4,-32(s0)
 378:	fe843783          	ld	a5,-24(s0)
 37c:	02e7fc63          	bgeu	a5,a4,3b4 <memmove+0x64>
    while(n-- > 0)
 380:	a00d                	j	3a2 <memmove+0x52>
      *dst++ = *src++;
 382:	fe043703          	ld	a4,-32(s0)
 386:	00170793          	addi	a5,a4,1
 38a:	fef43023          	sd	a5,-32(s0)
 38e:	fe843783          	ld	a5,-24(s0)
 392:	00178693          	addi	a3,a5,1
 396:	fed43423          	sd	a3,-24(s0)
 39a:	00074703          	lbu	a4,0(a4)
 39e:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 3a2:	fcc42783          	lw	a5,-52(s0)
 3a6:	fff7871b          	addiw	a4,a5,-1
 3aa:	fce42623          	sw	a4,-52(s0)
 3ae:	fcf04ae3          	bgtz	a5,382 <memmove+0x32>
 3b2:	a891                	j	406 <memmove+0xb6>
  } else {
    dst += n;
 3b4:	fcc42783          	lw	a5,-52(s0)
 3b8:	fe843703          	ld	a4,-24(s0)
 3bc:	97ba                	add	a5,a5,a4
 3be:	fef43423          	sd	a5,-24(s0)
    src += n;
 3c2:	fcc42783          	lw	a5,-52(s0)
 3c6:	fe043703          	ld	a4,-32(s0)
 3ca:	97ba                	add	a5,a5,a4
 3cc:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 3d0:	a01d                	j	3f6 <memmove+0xa6>
      *--dst = *--src;
 3d2:	fe043783          	ld	a5,-32(s0)
 3d6:	17fd                	addi	a5,a5,-1
 3d8:	fef43023          	sd	a5,-32(s0)
 3dc:	fe843783          	ld	a5,-24(s0)
 3e0:	17fd                	addi	a5,a5,-1
 3e2:	fef43423          	sd	a5,-24(s0)
 3e6:	fe043783          	ld	a5,-32(s0)
 3ea:	0007c703          	lbu	a4,0(a5)
 3ee:	fe843783          	ld	a5,-24(s0)
 3f2:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 3f6:	fcc42783          	lw	a5,-52(s0)
 3fa:	fff7871b          	addiw	a4,a5,-1
 3fe:	fce42623          	sw	a4,-52(s0)
 402:	fcf048e3          	bgtz	a5,3d2 <memmove+0x82>
  }
  return vdst;
 406:	fd843783          	ld	a5,-40(s0)
}
 40a:	853e                	mv	a0,a5
 40c:	7462                	ld	s0,56(sp)
 40e:	6121                	addi	sp,sp,64
 410:	8082                	ret

0000000000000412 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 412:	7139                	addi	sp,sp,-64
 414:	fc22                	sd	s0,56(sp)
 416:	0080                	addi	s0,sp,64
 418:	fca43c23          	sd	a0,-40(s0)
 41c:	fcb43823          	sd	a1,-48(s0)
 420:	87b2                	mv	a5,a2
 422:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 426:	fd843783          	ld	a5,-40(s0)
 42a:	fef43423          	sd	a5,-24(s0)
 42e:	fd043783          	ld	a5,-48(s0)
 432:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 436:	a0a1                	j	47e <memcmp+0x6c>
    if (*p1 != *p2) {
 438:	fe843783          	ld	a5,-24(s0)
 43c:	0007c703          	lbu	a4,0(a5)
 440:	fe043783          	ld	a5,-32(s0)
 444:	0007c783          	lbu	a5,0(a5)
 448:	02f70163          	beq	a4,a5,46a <memcmp+0x58>
      return *p1 - *p2;
 44c:	fe843783          	ld	a5,-24(s0)
 450:	0007c783          	lbu	a5,0(a5)
 454:	0007871b          	sext.w	a4,a5
 458:	fe043783          	ld	a5,-32(s0)
 45c:	0007c783          	lbu	a5,0(a5)
 460:	2781                	sext.w	a5,a5
 462:	40f707bb          	subw	a5,a4,a5
 466:	2781                	sext.w	a5,a5
 468:	a01d                	j	48e <memcmp+0x7c>
    }
    p1++;
 46a:	fe843783          	ld	a5,-24(s0)
 46e:	0785                	addi	a5,a5,1
 470:	fef43423          	sd	a5,-24(s0)
    p2++;
 474:	fe043783          	ld	a5,-32(s0)
 478:	0785                	addi	a5,a5,1
 47a:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 47e:	fcc42783          	lw	a5,-52(s0)
 482:	fff7871b          	addiw	a4,a5,-1
 486:	fce42623          	sw	a4,-52(s0)
 48a:	f7dd                	bnez	a5,438 <memcmp+0x26>
  }
  return 0;
 48c:	4781                	li	a5,0
}
 48e:	853e                	mv	a0,a5
 490:	7462                	ld	s0,56(sp)
 492:	6121                	addi	sp,sp,64
 494:	8082                	ret

0000000000000496 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 496:	7179                	addi	sp,sp,-48
 498:	f406                	sd	ra,40(sp)
 49a:	f022                	sd	s0,32(sp)
 49c:	1800                	addi	s0,sp,48
 49e:	fea43423          	sd	a0,-24(s0)
 4a2:	feb43023          	sd	a1,-32(s0)
 4a6:	87b2                	mv	a5,a2
 4a8:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 4ac:	fdc42783          	lw	a5,-36(s0)
 4b0:	863e                	mv	a2,a5
 4b2:	fe043583          	ld	a1,-32(s0)
 4b6:	fe843503          	ld	a0,-24(s0)
 4ba:	00000097          	auipc	ra,0x0
 4be:	e96080e7          	jalr	-362(ra) # 350 <memmove>
 4c2:	87aa                	mv	a5,a0
}
 4c4:	853e                	mv	a0,a5
 4c6:	70a2                	ld	ra,40(sp)
 4c8:	7402                	ld	s0,32(sp)
 4ca:	6145                	addi	sp,sp,48
 4cc:	8082                	ret

00000000000004ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ce:	4885                	li	a7,1
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4d6:	4889                	li	a7,2
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <wait>:
.global wait
wait:
 li a7, SYS_wait
 4de:	488d                	li	a7,3
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4e6:	4891                	li	a7,4
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <read>:
.global read
read:
 li a7, SYS_read
 4ee:	4895                	li	a7,5
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <write>:
.global write
write:
 li a7, SYS_write
 4f6:	48c1                	li	a7,16
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <close>:
.global close
close:
 li a7, SYS_close
 4fe:	48d5                	li	a7,21
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <kill>:
.global kill
kill:
 li a7, SYS_kill
 506:	4899                	li	a7,6
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <exec>:
.global exec
exec:
 li a7, SYS_exec
 50e:	489d                	li	a7,7
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <open>:
.global open
open:
 li a7, SYS_open
 516:	48bd                	li	a7,15
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 51e:	48c5                	li	a7,17
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 526:	48c9                	li	a7,18
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 52e:	48a1                	li	a7,8
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <link>:
.global link
link:
 li a7, SYS_link
 536:	48cd                	li	a7,19
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 53e:	48d1                	li	a7,20
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 546:	48a5                	li	a7,9
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <dup>:
.global dup
dup:
 li a7, SYS_dup
 54e:	48a9                	li	a7,10
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 556:	48ad                	li	a7,11
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 55e:	48b1                	li	a7,12
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 566:	48b5                	li	a7,13
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 56e:	48b9                	li	a7,14
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <hello>:
.global hello
hello:
 li a7, SYS_hello
 576:	48d9                	li	a7,22
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <ps>:
.global ps
ps:
 li a7, SYS_ps
 57e:	48e1                	li	a7,24
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 586:	48dd                	li	a7,23
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 58e:	48e5                	li	a7,25
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 596:	1101                	addi	sp,sp,-32
 598:	ec06                	sd	ra,24(sp)
 59a:	e822                	sd	s0,16(sp)
 59c:	1000                	addi	s0,sp,32
 59e:	87aa                	mv	a5,a0
 5a0:	872e                	mv	a4,a1
 5a2:	fef42623          	sw	a5,-20(s0)
 5a6:	87ba                	mv	a5,a4
 5a8:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 5ac:	feb40713          	addi	a4,s0,-21
 5b0:	fec42783          	lw	a5,-20(s0)
 5b4:	4605                	li	a2,1
 5b6:	85ba                	mv	a1,a4
 5b8:	853e                	mv	a0,a5
 5ba:	00000097          	auipc	ra,0x0
 5be:	f3c080e7          	jalr	-196(ra) # 4f6 <write>
}
 5c2:	0001                	nop
 5c4:	60e2                	ld	ra,24(sp)
 5c6:	6442                	ld	s0,16(sp)
 5c8:	6105                	addi	sp,sp,32
 5ca:	8082                	ret

00000000000005cc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5cc:	7139                	addi	sp,sp,-64
 5ce:	fc06                	sd	ra,56(sp)
 5d0:	f822                	sd	s0,48(sp)
 5d2:	0080                	addi	s0,sp,64
 5d4:	87aa                	mv	a5,a0
 5d6:	8736                	mv	a4,a3
 5d8:	fcf42623          	sw	a5,-52(s0)
 5dc:	87ae                	mv	a5,a1
 5de:	fcf42423          	sw	a5,-56(s0)
 5e2:	87b2                	mv	a5,a2
 5e4:	fcf42223          	sw	a5,-60(s0)
 5e8:	87ba                	mv	a5,a4
 5ea:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ee:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 5f2:	fc042783          	lw	a5,-64(s0)
 5f6:	2781                	sext.w	a5,a5
 5f8:	c38d                	beqz	a5,61a <printint+0x4e>
 5fa:	fc842783          	lw	a5,-56(s0)
 5fe:	2781                	sext.w	a5,a5
 600:	0007dd63          	bgez	a5,61a <printint+0x4e>
    neg = 1;
 604:	4785                	li	a5,1
 606:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 60a:	fc842783          	lw	a5,-56(s0)
 60e:	40f007bb          	negw	a5,a5
 612:	2781                	sext.w	a5,a5
 614:	fef42223          	sw	a5,-28(s0)
 618:	a029                	j	622 <printint+0x56>
  } else {
    x = xx;
 61a:	fc842783          	lw	a5,-56(s0)
 61e:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 622:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 626:	fc442783          	lw	a5,-60(s0)
 62a:	fe442703          	lw	a4,-28(s0)
 62e:	02f777bb          	remuw	a5,a4,a5
 632:	0007861b          	sext.w	a2,a5
 636:	fec42783          	lw	a5,-20(s0)
 63a:	0017871b          	addiw	a4,a5,1
 63e:	fee42623          	sw	a4,-20(s0)
 642:	00001697          	auipc	a3,0x1
 646:	9be68693          	addi	a3,a3,-1602 # 1000 <digits>
 64a:	02061713          	slli	a4,a2,0x20
 64e:	9301                	srli	a4,a4,0x20
 650:	9736                	add	a4,a4,a3
 652:	00074703          	lbu	a4,0(a4)
 656:	17c1                	addi	a5,a5,-16
 658:	97a2                	add	a5,a5,s0
 65a:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 65e:	fc442783          	lw	a5,-60(s0)
 662:	fe442703          	lw	a4,-28(s0)
 666:	02f757bb          	divuw	a5,a4,a5
 66a:	fef42223          	sw	a5,-28(s0)
 66e:	fe442783          	lw	a5,-28(s0)
 672:	2781                	sext.w	a5,a5
 674:	fbcd                	bnez	a5,626 <printint+0x5a>
  if(neg)
 676:	fe842783          	lw	a5,-24(s0)
 67a:	2781                	sext.w	a5,a5
 67c:	cf85                	beqz	a5,6b4 <printint+0xe8>
    buf[i++] = '-';
 67e:	fec42783          	lw	a5,-20(s0)
 682:	0017871b          	addiw	a4,a5,1
 686:	fee42623          	sw	a4,-20(s0)
 68a:	17c1                	addi	a5,a5,-16
 68c:	97a2                	add	a5,a5,s0
 68e:	02d00713          	li	a4,45
 692:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 696:	a839                	j	6b4 <printint+0xe8>
    putc(fd, buf[i]);
 698:	fec42783          	lw	a5,-20(s0)
 69c:	17c1                	addi	a5,a5,-16
 69e:	97a2                	add	a5,a5,s0
 6a0:	fe07c703          	lbu	a4,-32(a5)
 6a4:	fcc42783          	lw	a5,-52(s0)
 6a8:	85ba                	mv	a1,a4
 6aa:	853e                	mv	a0,a5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	eea080e7          	jalr	-278(ra) # 596 <putc>
  while(--i >= 0)
 6b4:	fec42783          	lw	a5,-20(s0)
 6b8:	37fd                	addiw	a5,a5,-1
 6ba:	fef42623          	sw	a5,-20(s0)
 6be:	fec42783          	lw	a5,-20(s0)
 6c2:	2781                	sext.w	a5,a5
 6c4:	fc07dae3          	bgez	a5,698 <printint+0xcc>
}
 6c8:	0001                	nop
 6ca:	0001                	nop
 6cc:	70e2                	ld	ra,56(sp)
 6ce:	7442                	ld	s0,48(sp)
 6d0:	6121                	addi	sp,sp,64
 6d2:	8082                	ret

00000000000006d4 <printptr>:

static void
printptr(int fd, uint64 x) {
 6d4:	7179                	addi	sp,sp,-48
 6d6:	f406                	sd	ra,40(sp)
 6d8:	f022                	sd	s0,32(sp)
 6da:	1800                	addi	s0,sp,48
 6dc:	87aa                	mv	a5,a0
 6de:	fcb43823          	sd	a1,-48(s0)
 6e2:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 6e6:	fdc42783          	lw	a5,-36(s0)
 6ea:	03000593          	li	a1,48
 6ee:	853e                	mv	a0,a5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	ea6080e7          	jalr	-346(ra) # 596 <putc>
  putc(fd, 'x');
 6f8:	fdc42783          	lw	a5,-36(s0)
 6fc:	07800593          	li	a1,120
 700:	853e                	mv	a0,a5
 702:	00000097          	auipc	ra,0x0
 706:	e94080e7          	jalr	-364(ra) # 596 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70a:	fe042623          	sw	zero,-20(s0)
 70e:	a82d                	j	748 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 710:	fd043783          	ld	a5,-48(s0)
 714:	93f1                	srli	a5,a5,0x3c
 716:	00001717          	auipc	a4,0x1
 71a:	8ea70713          	addi	a4,a4,-1814 # 1000 <digits>
 71e:	97ba                	add	a5,a5,a4
 720:	0007c703          	lbu	a4,0(a5)
 724:	fdc42783          	lw	a5,-36(s0)
 728:	85ba                	mv	a1,a4
 72a:	853e                	mv	a0,a5
 72c:	00000097          	auipc	ra,0x0
 730:	e6a080e7          	jalr	-406(ra) # 596 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 734:	fec42783          	lw	a5,-20(s0)
 738:	2785                	addiw	a5,a5,1
 73a:	fef42623          	sw	a5,-20(s0)
 73e:	fd043783          	ld	a5,-48(s0)
 742:	0792                	slli	a5,a5,0x4
 744:	fcf43823          	sd	a5,-48(s0)
 748:	fec42783          	lw	a5,-20(s0)
 74c:	873e                	mv	a4,a5
 74e:	47bd                	li	a5,15
 750:	fce7f0e3          	bgeu	a5,a4,710 <printptr+0x3c>
}
 754:	0001                	nop
 756:	0001                	nop
 758:	70a2                	ld	ra,40(sp)
 75a:	7402                	ld	s0,32(sp)
 75c:	6145                	addi	sp,sp,48
 75e:	8082                	ret

0000000000000760 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 760:	715d                	addi	sp,sp,-80
 762:	e486                	sd	ra,72(sp)
 764:	e0a2                	sd	s0,64(sp)
 766:	0880                	addi	s0,sp,80
 768:	87aa                	mv	a5,a0
 76a:	fcb43023          	sd	a1,-64(s0)
 76e:	fac43c23          	sd	a2,-72(s0)
 772:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 776:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 77a:	fe042223          	sw	zero,-28(s0)
 77e:	a42d                	j	9a8 <vprintf+0x248>
    c = fmt[i] & 0xff;
 780:	fe442783          	lw	a5,-28(s0)
 784:	fc043703          	ld	a4,-64(s0)
 788:	97ba                	add	a5,a5,a4
 78a:	0007c783          	lbu	a5,0(a5)
 78e:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 792:	fe042783          	lw	a5,-32(s0)
 796:	2781                	sext.w	a5,a5
 798:	eb9d                	bnez	a5,7ce <vprintf+0x6e>
      if(c == '%'){
 79a:	fdc42783          	lw	a5,-36(s0)
 79e:	0007871b          	sext.w	a4,a5
 7a2:	02500793          	li	a5,37
 7a6:	00f71763          	bne	a4,a5,7b4 <vprintf+0x54>
        state = '%';
 7aa:	02500793          	li	a5,37
 7ae:	fef42023          	sw	a5,-32(s0)
 7b2:	a2f5                	j	99e <vprintf+0x23e>
      } else {
        putc(fd, c);
 7b4:	fdc42783          	lw	a5,-36(s0)
 7b8:	0ff7f713          	zext.b	a4,a5
 7bc:	fcc42783          	lw	a5,-52(s0)
 7c0:	85ba                	mv	a1,a4
 7c2:	853e                	mv	a0,a5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	dd2080e7          	jalr	-558(ra) # 596 <putc>
 7cc:	aac9                	j	99e <vprintf+0x23e>
      }
    } else if(state == '%'){
 7ce:	fe042783          	lw	a5,-32(s0)
 7d2:	0007871b          	sext.w	a4,a5
 7d6:	02500793          	li	a5,37
 7da:	1cf71263          	bne	a4,a5,99e <vprintf+0x23e>
      if(c == 'd'){
 7de:	fdc42783          	lw	a5,-36(s0)
 7e2:	0007871b          	sext.w	a4,a5
 7e6:	06400793          	li	a5,100
 7ea:	02f71463          	bne	a4,a5,812 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 7ee:	fb843783          	ld	a5,-72(s0)
 7f2:	00878713          	addi	a4,a5,8
 7f6:	fae43c23          	sd	a4,-72(s0)
 7fa:	4398                	lw	a4,0(a5)
 7fc:	fcc42783          	lw	a5,-52(s0)
 800:	4685                	li	a3,1
 802:	4629                	li	a2,10
 804:	85ba                	mv	a1,a4
 806:	853e                	mv	a0,a5
 808:	00000097          	auipc	ra,0x0
 80c:	dc4080e7          	jalr	-572(ra) # 5cc <printint>
 810:	a269                	j	99a <vprintf+0x23a>
      } else if(c == 'l') {
 812:	fdc42783          	lw	a5,-36(s0)
 816:	0007871b          	sext.w	a4,a5
 81a:	06c00793          	li	a5,108
 81e:	02f71663          	bne	a4,a5,84a <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 822:	fb843783          	ld	a5,-72(s0)
 826:	00878713          	addi	a4,a5,8
 82a:	fae43c23          	sd	a4,-72(s0)
 82e:	639c                	ld	a5,0(a5)
 830:	0007871b          	sext.w	a4,a5
 834:	fcc42783          	lw	a5,-52(s0)
 838:	4681                	li	a3,0
 83a:	4629                	li	a2,10
 83c:	85ba                	mv	a1,a4
 83e:	853e                	mv	a0,a5
 840:	00000097          	auipc	ra,0x0
 844:	d8c080e7          	jalr	-628(ra) # 5cc <printint>
 848:	aa89                	j	99a <vprintf+0x23a>
      } else if(c == 'x') {
 84a:	fdc42783          	lw	a5,-36(s0)
 84e:	0007871b          	sext.w	a4,a5
 852:	07800793          	li	a5,120
 856:	02f71463          	bne	a4,a5,87e <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 85a:	fb843783          	ld	a5,-72(s0)
 85e:	00878713          	addi	a4,a5,8
 862:	fae43c23          	sd	a4,-72(s0)
 866:	4398                	lw	a4,0(a5)
 868:	fcc42783          	lw	a5,-52(s0)
 86c:	4681                	li	a3,0
 86e:	4641                	li	a2,16
 870:	85ba                	mv	a1,a4
 872:	853e                	mv	a0,a5
 874:	00000097          	auipc	ra,0x0
 878:	d58080e7          	jalr	-680(ra) # 5cc <printint>
 87c:	aa39                	j	99a <vprintf+0x23a>
      } else if(c == 'p') {
 87e:	fdc42783          	lw	a5,-36(s0)
 882:	0007871b          	sext.w	a4,a5
 886:	07000793          	li	a5,112
 88a:	02f71263          	bne	a4,a5,8ae <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 88e:	fb843783          	ld	a5,-72(s0)
 892:	00878713          	addi	a4,a5,8
 896:	fae43c23          	sd	a4,-72(s0)
 89a:	6398                	ld	a4,0(a5)
 89c:	fcc42783          	lw	a5,-52(s0)
 8a0:	85ba                	mv	a1,a4
 8a2:	853e                	mv	a0,a5
 8a4:	00000097          	auipc	ra,0x0
 8a8:	e30080e7          	jalr	-464(ra) # 6d4 <printptr>
 8ac:	a0fd                	j	99a <vprintf+0x23a>
      } else if(c == 's'){
 8ae:	fdc42783          	lw	a5,-36(s0)
 8b2:	0007871b          	sext.w	a4,a5
 8b6:	07300793          	li	a5,115
 8ba:	04f71c63          	bne	a4,a5,912 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 8be:	fb843783          	ld	a5,-72(s0)
 8c2:	00878713          	addi	a4,a5,8
 8c6:	fae43c23          	sd	a4,-72(s0)
 8ca:	639c                	ld	a5,0(a5)
 8cc:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 8d0:	fe843783          	ld	a5,-24(s0)
 8d4:	eb8d                	bnez	a5,906 <vprintf+0x1a6>
          s = "(null)";
 8d6:	00000797          	auipc	a5,0x0
 8da:	47a78793          	addi	a5,a5,1146 # d50 <malloc+0x140>
 8de:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 8e2:	a015                	j	906 <vprintf+0x1a6>
          putc(fd, *s);
 8e4:	fe843783          	ld	a5,-24(s0)
 8e8:	0007c703          	lbu	a4,0(a5)
 8ec:	fcc42783          	lw	a5,-52(s0)
 8f0:	85ba                	mv	a1,a4
 8f2:	853e                	mv	a0,a5
 8f4:	00000097          	auipc	ra,0x0
 8f8:	ca2080e7          	jalr	-862(ra) # 596 <putc>
          s++;
 8fc:	fe843783          	ld	a5,-24(s0)
 900:	0785                	addi	a5,a5,1
 902:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 906:	fe843783          	ld	a5,-24(s0)
 90a:	0007c783          	lbu	a5,0(a5)
 90e:	fbf9                	bnez	a5,8e4 <vprintf+0x184>
 910:	a069                	j	99a <vprintf+0x23a>
        }
      } else if(c == 'c'){
 912:	fdc42783          	lw	a5,-36(s0)
 916:	0007871b          	sext.w	a4,a5
 91a:	06300793          	li	a5,99
 91e:	02f71463          	bne	a4,a5,946 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 922:	fb843783          	ld	a5,-72(s0)
 926:	00878713          	addi	a4,a5,8
 92a:	fae43c23          	sd	a4,-72(s0)
 92e:	439c                	lw	a5,0(a5)
 930:	0ff7f713          	zext.b	a4,a5
 934:	fcc42783          	lw	a5,-52(s0)
 938:	85ba                	mv	a1,a4
 93a:	853e                	mv	a0,a5
 93c:	00000097          	auipc	ra,0x0
 940:	c5a080e7          	jalr	-934(ra) # 596 <putc>
 944:	a899                	j	99a <vprintf+0x23a>
      } else if(c == '%'){
 946:	fdc42783          	lw	a5,-36(s0)
 94a:	0007871b          	sext.w	a4,a5
 94e:	02500793          	li	a5,37
 952:	00f71f63          	bne	a4,a5,970 <vprintf+0x210>
        putc(fd, c);
 956:	fdc42783          	lw	a5,-36(s0)
 95a:	0ff7f713          	zext.b	a4,a5
 95e:	fcc42783          	lw	a5,-52(s0)
 962:	85ba                	mv	a1,a4
 964:	853e                	mv	a0,a5
 966:	00000097          	auipc	ra,0x0
 96a:	c30080e7          	jalr	-976(ra) # 596 <putc>
 96e:	a035                	j	99a <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 970:	fcc42783          	lw	a5,-52(s0)
 974:	02500593          	li	a1,37
 978:	853e                	mv	a0,a5
 97a:	00000097          	auipc	ra,0x0
 97e:	c1c080e7          	jalr	-996(ra) # 596 <putc>
        putc(fd, c);
 982:	fdc42783          	lw	a5,-36(s0)
 986:	0ff7f713          	zext.b	a4,a5
 98a:	fcc42783          	lw	a5,-52(s0)
 98e:	85ba                	mv	a1,a4
 990:	853e                	mv	a0,a5
 992:	00000097          	auipc	ra,0x0
 996:	c04080e7          	jalr	-1020(ra) # 596 <putc>
      }
      state = 0;
 99a:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 99e:	fe442783          	lw	a5,-28(s0)
 9a2:	2785                	addiw	a5,a5,1
 9a4:	fef42223          	sw	a5,-28(s0)
 9a8:	fe442783          	lw	a5,-28(s0)
 9ac:	fc043703          	ld	a4,-64(s0)
 9b0:	97ba                	add	a5,a5,a4
 9b2:	0007c783          	lbu	a5,0(a5)
 9b6:	dc0795e3          	bnez	a5,780 <vprintf+0x20>
    }
  }
}
 9ba:	0001                	nop
 9bc:	0001                	nop
 9be:	60a6                	ld	ra,72(sp)
 9c0:	6406                	ld	s0,64(sp)
 9c2:	6161                	addi	sp,sp,80
 9c4:	8082                	ret

00000000000009c6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9c6:	7159                	addi	sp,sp,-112
 9c8:	fc06                	sd	ra,56(sp)
 9ca:	f822                	sd	s0,48(sp)
 9cc:	0080                	addi	s0,sp,64
 9ce:	fcb43823          	sd	a1,-48(s0)
 9d2:	e010                	sd	a2,0(s0)
 9d4:	e414                	sd	a3,8(s0)
 9d6:	e818                	sd	a4,16(s0)
 9d8:	ec1c                	sd	a5,24(s0)
 9da:	03043023          	sd	a6,32(s0)
 9de:	03143423          	sd	a7,40(s0)
 9e2:	87aa                	mv	a5,a0
 9e4:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 9e8:	03040793          	addi	a5,s0,48
 9ec:	fcf43423          	sd	a5,-56(s0)
 9f0:	fc843783          	ld	a5,-56(s0)
 9f4:	fd078793          	addi	a5,a5,-48
 9f8:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 9fc:	fe843703          	ld	a4,-24(s0)
 a00:	fdc42783          	lw	a5,-36(s0)
 a04:	863a                	mv	a2,a4
 a06:	fd043583          	ld	a1,-48(s0)
 a0a:	853e                	mv	a0,a5
 a0c:	00000097          	auipc	ra,0x0
 a10:	d54080e7          	jalr	-684(ra) # 760 <vprintf>
}
 a14:	0001                	nop
 a16:	70e2                	ld	ra,56(sp)
 a18:	7442                	ld	s0,48(sp)
 a1a:	6165                	addi	sp,sp,112
 a1c:	8082                	ret

0000000000000a1e <printf>:

void
printf(const char *fmt, ...)
{
 a1e:	7159                	addi	sp,sp,-112
 a20:	f406                	sd	ra,40(sp)
 a22:	f022                	sd	s0,32(sp)
 a24:	1800                	addi	s0,sp,48
 a26:	fca43c23          	sd	a0,-40(s0)
 a2a:	e40c                	sd	a1,8(s0)
 a2c:	e810                	sd	a2,16(s0)
 a2e:	ec14                	sd	a3,24(s0)
 a30:	f018                	sd	a4,32(s0)
 a32:	f41c                	sd	a5,40(s0)
 a34:	03043823          	sd	a6,48(s0)
 a38:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a3c:	04040793          	addi	a5,s0,64
 a40:	fcf43823          	sd	a5,-48(s0)
 a44:	fd043783          	ld	a5,-48(s0)
 a48:	fc878793          	addi	a5,a5,-56
 a4c:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 a50:	fe843783          	ld	a5,-24(s0)
 a54:	863e                	mv	a2,a5
 a56:	fd843583          	ld	a1,-40(s0)
 a5a:	4505                	li	a0,1
 a5c:	00000097          	auipc	ra,0x0
 a60:	d04080e7          	jalr	-764(ra) # 760 <vprintf>
}
 a64:	0001                	nop
 a66:	70a2                	ld	ra,40(sp)
 a68:	7402                	ld	s0,32(sp)
 a6a:	6165                	addi	sp,sp,112
 a6c:	8082                	ret

0000000000000a6e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a6e:	7179                	addi	sp,sp,-48
 a70:	f422                	sd	s0,40(sp)
 a72:	1800                	addi	s0,sp,48
 a74:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a78:	fd843783          	ld	a5,-40(s0)
 a7c:	17c1                	addi	a5,a5,-16
 a7e:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a82:	00000797          	auipc	a5,0x0
 a86:	5ae78793          	addi	a5,a5,1454 # 1030 <freep>
 a8a:	639c                	ld	a5,0(a5)
 a8c:	fef43423          	sd	a5,-24(s0)
 a90:	a815                	j	ac4 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a92:	fe843783          	ld	a5,-24(s0)
 a96:	639c                	ld	a5,0(a5)
 a98:	fe843703          	ld	a4,-24(s0)
 a9c:	00f76f63          	bltu	a4,a5,aba <free+0x4c>
 aa0:	fe043703          	ld	a4,-32(s0)
 aa4:	fe843783          	ld	a5,-24(s0)
 aa8:	02e7eb63          	bltu	a5,a4,ade <free+0x70>
 aac:	fe843783          	ld	a5,-24(s0)
 ab0:	639c                	ld	a5,0(a5)
 ab2:	fe043703          	ld	a4,-32(s0)
 ab6:	02f76463          	bltu	a4,a5,ade <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aba:	fe843783          	ld	a5,-24(s0)
 abe:	639c                	ld	a5,0(a5)
 ac0:	fef43423          	sd	a5,-24(s0)
 ac4:	fe043703          	ld	a4,-32(s0)
 ac8:	fe843783          	ld	a5,-24(s0)
 acc:	fce7f3e3          	bgeu	a5,a4,a92 <free+0x24>
 ad0:	fe843783          	ld	a5,-24(s0)
 ad4:	639c                	ld	a5,0(a5)
 ad6:	fe043703          	ld	a4,-32(s0)
 ada:	faf77ce3          	bgeu	a4,a5,a92 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 ade:	fe043783          	ld	a5,-32(s0)
 ae2:	479c                	lw	a5,8(a5)
 ae4:	1782                	slli	a5,a5,0x20
 ae6:	9381                	srli	a5,a5,0x20
 ae8:	0792                	slli	a5,a5,0x4
 aea:	fe043703          	ld	a4,-32(s0)
 aee:	973e                	add	a4,a4,a5
 af0:	fe843783          	ld	a5,-24(s0)
 af4:	639c                	ld	a5,0(a5)
 af6:	02f71763          	bne	a4,a5,b24 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 afa:	fe043783          	ld	a5,-32(s0)
 afe:	4798                	lw	a4,8(a5)
 b00:	fe843783          	ld	a5,-24(s0)
 b04:	639c                	ld	a5,0(a5)
 b06:	479c                	lw	a5,8(a5)
 b08:	9fb9                	addw	a5,a5,a4
 b0a:	0007871b          	sext.w	a4,a5
 b0e:	fe043783          	ld	a5,-32(s0)
 b12:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 b14:	fe843783          	ld	a5,-24(s0)
 b18:	639c                	ld	a5,0(a5)
 b1a:	6398                	ld	a4,0(a5)
 b1c:	fe043783          	ld	a5,-32(s0)
 b20:	e398                	sd	a4,0(a5)
 b22:	a039                	j	b30 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 b24:	fe843783          	ld	a5,-24(s0)
 b28:	6398                	ld	a4,0(a5)
 b2a:	fe043783          	ld	a5,-32(s0)
 b2e:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 b30:	fe843783          	ld	a5,-24(s0)
 b34:	479c                	lw	a5,8(a5)
 b36:	1782                	slli	a5,a5,0x20
 b38:	9381                	srli	a5,a5,0x20
 b3a:	0792                	slli	a5,a5,0x4
 b3c:	fe843703          	ld	a4,-24(s0)
 b40:	97ba                	add	a5,a5,a4
 b42:	fe043703          	ld	a4,-32(s0)
 b46:	02f71563          	bne	a4,a5,b70 <free+0x102>
    p->s.size += bp->s.size;
 b4a:	fe843783          	ld	a5,-24(s0)
 b4e:	4798                	lw	a4,8(a5)
 b50:	fe043783          	ld	a5,-32(s0)
 b54:	479c                	lw	a5,8(a5)
 b56:	9fb9                	addw	a5,a5,a4
 b58:	0007871b          	sext.w	a4,a5
 b5c:	fe843783          	ld	a5,-24(s0)
 b60:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b62:	fe043783          	ld	a5,-32(s0)
 b66:	6398                	ld	a4,0(a5)
 b68:	fe843783          	ld	a5,-24(s0)
 b6c:	e398                	sd	a4,0(a5)
 b6e:	a031                	j	b7a <free+0x10c>
  } else
    p->s.ptr = bp;
 b70:	fe843783          	ld	a5,-24(s0)
 b74:	fe043703          	ld	a4,-32(s0)
 b78:	e398                	sd	a4,0(a5)
  freep = p;
 b7a:	00000797          	auipc	a5,0x0
 b7e:	4b678793          	addi	a5,a5,1206 # 1030 <freep>
 b82:	fe843703          	ld	a4,-24(s0)
 b86:	e398                	sd	a4,0(a5)
}
 b88:	0001                	nop
 b8a:	7422                	ld	s0,40(sp)
 b8c:	6145                	addi	sp,sp,48
 b8e:	8082                	ret

0000000000000b90 <morecore>:

static Header*
morecore(uint nu)
{
 b90:	7179                	addi	sp,sp,-48
 b92:	f406                	sd	ra,40(sp)
 b94:	f022                	sd	s0,32(sp)
 b96:	1800                	addi	s0,sp,48
 b98:	87aa                	mv	a5,a0
 b9a:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 b9e:	fdc42783          	lw	a5,-36(s0)
 ba2:	0007871b          	sext.w	a4,a5
 ba6:	6785                	lui	a5,0x1
 ba8:	00f77563          	bgeu	a4,a5,bb2 <morecore+0x22>
    nu = 4096;
 bac:	6785                	lui	a5,0x1
 bae:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 bb2:	fdc42783          	lw	a5,-36(s0)
 bb6:	0047979b          	slliw	a5,a5,0x4
 bba:	2781                	sext.w	a5,a5
 bbc:	2781                	sext.w	a5,a5
 bbe:	853e                	mv	a0,a5
 bc0:	00000097          	auipc	ra,0x0
 bc4:	99e080e7          	jalr	-1634(ra) # 55e <sbrk>
 bc8:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 bcc:	fe843703          	ld	a4,-24(s0)
 bd0:	57fd                	li	a5,-1
 bd2:	00f71463          	bne	a4,a5,bda <morecore+0x4a>
    return 0;
 bd6:	4781                	li	a5,0
 bd8:	a03d                	j	c06 <morecore+0x76>
  hp = (Header*)p;
 bda:	fe843783          	ld	a5,-24(s0)
 bde:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 be2:	fe043783          	ld	a5,-32(s0)
 be6:	fdc42703          	lw	a4,-36(s0)
 bea:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 bec:	fe043783          	ld	a5,-32(s0)
 bf0:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 bf2:	853e                	mv	a0,a5
 bf4:	00000097          	auipc	ra,0x0
 bf8:	e7a080e7          	jalr	-390(ra) # a6e <free>
  return freep;
 bfc:	00000797          	auipc	a5,0x0
 c00:	43478793          	addi	a5,a5,1076 # 1030 <freep>
 c04:	639c                	ld	a5,0(a5)
}
 c06:	853e                	mv	a0,a5
 c08:	70a2                	ld	ra,40(sp)
 c0a:	7402                	ld	s0,32(sp)
 c0c:	6145                	addi	sp,sp,48
 c0e:	8082                	ret

0000000000000c10 <malloc>:

void*
malloc(uint nbytes)
{
 c10:	7139                	addi	sp,sp,-64
 c12:	fc06                	sd	ra,56(sp)
 c14:	f822                	sd	s0,48(sp)
 c16:	0080                	addi	s0,sp,64
 c18:	87aa                	mv	a5,a0
 c1a:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c1e:	fcc46783          	lwu	a5,-52(s0)
 c22:	07bd                	addi	a5,a5,15
 c24:	8391                	srli	a5,a5,0x4
 c26:	2781                	sext.w	a5,a5
 c28:	2785                	addiw	a5,a5,1
 c2a:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 c2e:	00000797          	auipc	a5,0x0
 c32:	40278793          	addi	a5,a5,1026 # 1030 <freep>
 c36:	639c                	ld	a5,0(a5)
 c38:	fef43023          	sd	a5,-32(s0)
 c3c:	fe043783          	ld	a5,-32(s0)
 c40:	ef95                	bnez	a5,c7c <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 c42:	00000797          	auipc	a5,0x0
 c46:	3de78793          	addi	a5,a5,990 # 1020 <base>
 c4a:	fef43023          	sd	a5,-32(s0)
 c4e:	00000797          	auipc	a5,0x0
 c52:	3e278793          	addi	a5,a5,994 # 1030 <freep>
 c56:	fe043703          	ld	a4,-32(s0)
 c5a:	e398                	sd	a4,0(a5)
 c5c:	00000797          	auipc	a5,0x0
 c60:	3d478793          	addi	a5,a5,980 # 1030 <freep>
 c64:	6398                	ld	a4,0(a5)
 c66:	00000797          	auipc	a5,0x0
 c6a:	3ba78793          	addi	a5,a5,954 # 1020 <base>
 c6e:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 c70:	00000797          	auipc	a5,0x0
 c74:	3b078793          	addi	a5,a5,944 # 1020 <base>
 c78:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c7c:	fe043783          	ld	a5,-32(s0)
 c80:	639c                	ld	a5,0(a5)
 c82:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 c86:	fe843783          	ld	a5,-24(s0)
 c8a:	4798                	lw	a4,8(a5)
 c8c:	fdc42783          	lw	a5,-36(s0)
 c90:	2781                	sext.w	a5,a5
 c92:	06f76763          	bltu	a4,a5,d00 <malloc+0xf0>
      if(p->s.size == nunits)
 c96:	fe843783          	ld	a5,-24(s0)
 c9a:	4798                	lw	a4,8(a5)
 c9c:	fdc42783          	lw	a5,-36(s0)
 ca0:	2781                	sext.w	a5,a5
 ca2:	00e79963          	bne	a5,a4,cb4 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 ca6:	fe843783          	ld	a5,-24(s0)
 caa:	6398                	ld	a4,0(a5)
 cac:	fe043783          	ld	a5,-32(s0)
 cb0:	e398                	sd	a4,0(a5)
 cb2:	a825                	j	cea <malloc+0xda>
      else {
        p->s.size -= nunits;
 cb4:	fe843783          	ld	a5,-24(s0)
 cb8:	479c                	lw	a5,8(a5)
 cba:	fdc42703          	lw	a4,-36(s0)
 cbe:	9f99                	subw	a5,a5,a4
 cc0:	0007871b          	sext.w	a4,a5
 cc4:	fe843783          	ld	a5,-24(s0)
 cc8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cca:	fe843783          	ld	a5,-24(s0)
 cce:	479c                	lw	a5,8(a5)
 cd0:	1782                	slli	a5,a5,0x20
 cd2:	9381                	srli	a5,a5,0x20
 cd4:	0792                	slli	a5,a5,0x4
 cd6:	fe843703          	ld	a4,-24(s0)
 cda:	97ba                	add	a5,a5,a4
 cdc:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 ce0:	fe843783          	ld	a5,-24(s0)
 ce4:	fdc42703          	lw	a4,-36(s0)
 ce8:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 cea:	00000797          	auipc	a5,0x0
 cee:	34678793          	addi	a5,a5,838 # 1030 <freep>
 cf2:	fe043703          	ld	a4,-32(s0)
 cf6:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 cf8:	fe843783          	ld	a5,-24(s0)
 cfc:	07c1                	addi	a5,a5,16
 cfe:	a091                	j	d42 <malloc+0x132>
    }
    if(p == freep)
 d00:	00000797          	auipc	a5,0x0
 d04:	33078793          	addi	a5,a5,816 # 1030 <freep>
 d08:	639c                	ld	a5,0(a5)
 d0a:	fe843703          	ld	a4,-24(s0)
 d0e:	02f71063          	bne	a4,a5,d2e <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 d12:	fdc42783          	lw	a5,-36(s0)
 d16:	853e                	mv	a0,a5
 d18:	00000097          	auipc	ra,0x0
 d1c:	e78080e7          	jalr	-392(ra) # b90 <morecore>
 d20:	fea43423          	sd	a0,-24(s0)
 d24:	fe843783          	ld	a5,-24(s0)
 d28:	e399                	bnez	a5,d2e <malloc+0x11e>
        return 0;
 d2a:	4781                	li	a5,0
 d2c:	a819                	j	d42 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d2e:	fe843783          	ld	a5,-24(s0)
 d32:	fef43023          	sd	a5,-32(s0)
 d36:	fe843783          	ld	a5,-24(s0)
 d3a:	639c                	ld	a5,0(a5)
 d3c:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 d40:	b799                	j	c86 <malloc+0x76>
  }
}
 d42:	853e                	mv	a0,a5
 d44:	70e2                	ld	ra,56(sp)
 d46:	7442                	ld	s0,48(sp)
 d48:	6121                	addi	sp,sp,64
 d4a:	8082                	ret
