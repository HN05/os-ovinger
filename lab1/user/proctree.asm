
user/_proctree:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
   8:	87aa                	mv	a5,a0
   a:	feb43023          	sd	a1,-32(s0)
   e:	fef42623          	sw	a5,-20(s0)
	proctree();
  12:	00000097          	auipc	ra,0x0
  16:	578080e7          	jalr	1400(ra) # 58a <proctree>
	return 0;
  1a:	4781                	li	a5,0
}
  1c:	853e                	mv	a0,a5
  1e:	60e2                	ld	ra,24(sp)
  20:	6442                	ld	s0,16(sp)
  22:	6105                	addi	sp,sp,32
  24:	8082                	ret

0000000000000026 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  26:	1141                	addi	sp,sp,-16
  28:	e406                	sd	ra,8(sp)
  2a:	e022                	sd	s0,0(sp)
  2c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  2e:	00000097          	auipc	ra,0x0
  32:	fd2080e7          	jalr	-46(ra) # 0 <main>
  exit(0);
  36:	4501                	li	a0,0
  38:	00000097          	auipc	ra,0x0
  3c:	49a080e7          	jalr	1178(ra) # 4d2 <exit>

0000000000000040 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  40:	7179                	addi	sp,sp,-48
  42:	f422                	sd	s0,40(sp)
  44:	1800                	addi	s0,sp,48
  46:	fca43c23          	sd	a0,-40(s0)
  4a:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  4e:	fd843783          	ld	a5,-40(s0)
  52:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  56:	0001                	nop
  58:	fd043703          	ld	a4,-48(s0)
  5c:	00170793          	addi	a5,a4,1
  60:	fcf43823          	sd	a5,-48(s0)
  64:	fd843783          	ld	a5,-40(s0)
  68:	00178693          	addi	a3,a5,1
  6c:	fcd43c23          	sd	a3,-40(s0)
  70:	00074703          	lbu	a4,0(a4)
  74:	00e78023          	sb	a4,0(a5)
  78:	0007c783          	lbu	a5,0(a5)
  7c:	fff1                	bnez	a5,58 <strcpy+0x18>
    ;
  return os;
  7e:	fe843783          	ld	a5,-24(s0)
}
  82:	853e                	mv	a0,a5
  84:	7422                	ld	s0,40(sp)
  86:	6145                	addi	sp,sp,48
  88:	8082                	ret

000000000000008a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8a:	1101                	addi	sp,sp,-32
  8c:	ec22                	sd	s0,24(sp)
  8e:	1000                	addi	s0,sp,32
  90:	fea43423          	sd	a0,-24(s0)
  94:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
  98:	a819                	j	ae <strcmp+0x24>
    p++, q++;
  9a:	fe843783          	ld	a5,-24(s0)
  9e:	0785                	addi	a5,a5,1
  a0:	fef43423          	sd	a5,-24(s0)
  a4:	fe043783          	ld	a5,-32(s0)
  a8:	0785                	addi	a5,a5,1
  aa:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
  ae:	fe843783          	ld	a5,-24(s0)
  b2:	0007c783          	lbu	a5,0(a5)
  b6:	cb99                	beqz	a5,cc <strcmp+0x42>
  b8:	fe843783          	ld	a5,-24(s0)
  bc:	0007c703          	lbu	a4,0(a5)
  c0:	fe043783          	ld	a5,-32(s0)
  c4:	0007c783          	lbu	a5,0(a5)
  c8:	fcf709e3          	beq	a4,a5,9a <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
  cc:	fe843783          	ld	a5,-24(s0)
  d0:	0007c783          	lbu	a5,0(a5)
  d4:	0007871b          	sext.w	a4,a5
  d8:	fe043783          	ld	a5,-32(s0)
  dc:	0007c783          	lbu	a5,0(a5)
  e0:	2781                	sext.w	a5,a5
  e2:	40f707bb          	subw	a5,a4,a5
  e6:	2781                	sext.w	a5,a5
}
  e8:	853e                	mv	a0,a5
  ea:	6462                	ld	s0,24(sp)
  ec:	6105                	addi	sp,sp,32
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	7179                	addi	sp,sp,-48
  f2:	f422                	sd	s0,40(sp)
  f4:	1800                	addi	s0,sp,48
  f6:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
  fa:	fe042623          	sw	zero,-20(s0)
  fe:	a031                	j	10a <strlen+0x1a>
 100:	fec42783          	lw	a5,-20(s0)
 104:	2785                	addiw	a5,a5,1
 106:	fef42623          	sw	a5,-20(s0)
 10a:	fec42783          	lw	a5,-20(s0)
 10e:	fd843703          	ld	a4,-40(s0)
 112:	97ba                	add	a5,a5,a4
 114:	0007c783          	lbu	a5,0(a5)
 118:	f7e5                	bnez	a5,100 <strlen+0x10>
    ;
  return n;
 11a:	fec42783          	lw	a5,-20(s0)
}
 11e:	853e                	mv	a0,a5
 120:	7422                	ld	s0,40(sp)
 122:	6145                	addi	sp,sp,48
 124:	8082                	ret

0000000000000126 <memset>:

void*
memset(void *dst, int c, uint n)
{
 126:	7179                	addi	sp,sp,-48
 128:	f422                	sd	s0,40(sp)
 12a:	1800                	addi	s0,sp,48
 12c:	fca43c23          	sd	a0,-40(s0)
 130:	87ae                	mv	a5,a1
 132:	8732                	mv	a4,a2
 134:	fcf42a23          	sw	a5,-44(s0)
 138:	87ba                	mv	a5,a4
 13a:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 13e:	fd843783          	ld	a5,-40(s0)
 142:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 146:	fe042623          	sw	zero,-20(s0)
 14a:	a00d                	j	16c <memset+0x46>
    cdst[i] = c;
 14c:	fec42783          	lw	a5,-20(s0)
 150:	fe043703          	ld	a4,-32(s0)
 154:	97ba                	add	a5,a5,a4
 156:	fd442703          	lw	a4,-44(s0)
 15a:	0ff77713          	zext.b	a4,a4
 15e:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 162:	fec42783          	lw	a5,-20(s0)
 166:	2785                	addiw	a5,a5,1
 168:	fef42623          	sw	a5,-20(s0)
 16c:	fec42703          	lw	a4,-20(s0)
 170:	fd042783          	lw	a5,-48(s0)
 174:	2781                	sext.w	a5,a5
 176:	fcf76be3          	bltu	a4,a5,14c <memset+0x26>
  }
  return dst;
 17a:	fd843783          	ld	a5,-40(s0)
}
 17e:	853e                	mv	a0,a5
 180:	7422                	ld	s0,40(sp)
 182:	6145                	addi	sp,sp,48
 184:	8082                	ret

0000000000000186 <strchr>:

char*
strchr(const char *s, char c)
{
 186:	1101                	addi	sp,sp,-32
 188:	ec22                	sd	s0,24(sp)
 18a:	1000                	addi	s0,sp,32
 18c:	fea43423          	sd	a0,-24(s0)
 190:	87ae                	mv	a5,a1
 192:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 196:	a01d                	j	1bc <strchr+0x36>
    if(*s == c)
 198:	fe843783          	ld	a5,-24(s0)
 19c:	0007c703          	lbu	a4,0(a5)
 1a0:	fe744783          	lbu	a5,-25(s0)
 1a4:	0ff7f793          	zext.b	a5,a5
 1a8:	00e79563          	bne	a5,a4,1b2 <strchr+0x2c>
      return (char*)s;
 1ac:	fe843783          	ld	a5,-24(s0)
 1b0:	a821                	j	1c8 <strchr+0x42>
  for(; *s; s++)
 1b2:	fe843783          	ld	a5,-24(s0)
 1b6:	0785                	addi	a5,a5,1
 1b8:	fef43423          	sd	a5,-24(s0)
 1bc:	fe843783          	ld	a5,-24(s0)
 1c0:	0007c783          	lbu	a5,0(a5)
 1c4:	fbf1                	bnez	a5,198 <strchr+0x12>
  return 0;
 1c6:	4781                	li	a5,0
}
 1c8:	853e                	mv	a0,a5
 1ca:	6462                	ld	s0,24(sp)
 1cc:	6105                	addi	sp,sp,32
 1ce:	8082                	ret

00000000000001d0 <gets>:

char*
gets(char *buf, int max)
{
 1d0:	7179                	addi	sp,sp,-48
 1d2:	f406                	sd	ra,40(sp)
 1d4:	f022                	sd	s0,32(sp)
 1d6:	1800                	addi	s0,sp,48
 1d8:	fca43c23          	sd	a0,-40(s0)
 1dc:	87ae                	mv	a5,a1
 1de:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e2:	fe042623          	sw	zero,-20(s0)
 1e6:	a8a1                	j	23e <gets+0x6e>
    cc = read(0, &c, 1);
 1e8:	fe740793          	addi	a5,s0,-25
 1ec:	4605                	li	a2,1
 1ee:	85be                	mv	a1,a5
 1f0:	4501                	li	a0,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	2f8080e7          	jalr	760(ra) # 4ea <read>
 1fa:	87aa                	mv	a5,a0
 1fc:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 200:	fe842783          	lw	a5,-24(s0)
 204:	2781                	sext.w	a5,a5
 206:	04f05763          	blez	a5,254 <gets+0x84>
      break;
    buf[i++] = c;
 20a:	fec42783          	lw	a5,-20(s0)
 20e:	0017871b          	addiw	a4,a5,1
 212:	fee42623          	sw	a4,-20(s0)
 216:	873e                	mv	a4,a5
 218:	fd843783          	ld	a5,-40(s0)
 21c:	97ba                	add	a5,a5,a4
 21e:	fe744703          	lbu	a4,-25(s0)
 222:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 226:	fe744783          	lbu	a5,-25(s0)
 22a:	873e                	mv	a4,a5
 22c:	47a9                	li	a5,10
 22e:	02f70463          	beq	a4,a5,256 <gets+0x86>
 232:	fe744783          	lbu	a5,-25(s0)
 236:	873e                	mv	a4,a5
 238:	47b5                	li	a5,13
 23a:	00f70e63          	beq	a4,a5,256 <gets+0x86>
  for(i=0; i+1 < max; ){
 23e:	fec42783          	lw	a5,-20(s0)
 242:	2785                	addiw	a5,a5,1
 244:	0007871b          	sext.w	a4,a5
 248:	fd442783          	lw	a5,-44(s0)
 24c:	2781                	sext.w	a5,a5
 24e:	f8f74de3          	blt	a4,a5,1e8 <gets+0x18>
 252:	a011                	j	256 <gets+0x86>
      break;
 254:	0001                	nop
      break;
  }
  buf[i] = '\0';
 256:	fec42783          	lw	a5,-20(s0)
 25a:	fd843703          	ld	a4,-40(s0)
 25e:	97ba                	add	a5,a5,a4
 260:	00078023          	sb	zero,0(a5)
  return buf;
 264:	fd843783          	ld	a5,-40(s0)
}
 268:	853e                	mv	a0,a5
 26a:	70a2                	ld	ra,40(sp)
 26c:	7402                	ld	s0,32(sp)
 26e:	6145                	addi	sp,sp,48
 270:	8082                	ret

0000000000000272 <stat>:

int
stat(const char *n, struct stat *st)
{
 272:	7179                	addi	sp,sp,-48
 274:	f406                	sd	ra,40(sp)
 276:	f022                	sd	s0,32(sp)
 278:	1800                	addi	s0,sp,48
 27a:	fca43c23          	sd	a0,-40(s0)
 27e:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 282:	4581                	li	a1,0
 284:	fd843503          	ld	a0,-40(s0)
 288:	00000097          	auipc	ra,0x0
 28c:	28a080e7          	jalr	650(ra) # 512 <open>
 290:	87aa                	mv	a5,a0
 292:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 296:	fec42783          	lw	a5,-20(s0)
 29a:	2781                	sext.w	a5,a5
 29c:	0007d463          	bgez	a5,2a4 <stat+0x32>
    return -1;
 2a0:	57fd                	li	a5,-1
 2a2:	a035                	j	2ce <stat+0x5c>
  r = fstat(fd, st);
 2a4:	fec42783          	lw	a5,-20(s0)
 2a8:	fd043583          	ld	a1,-48(s0)
 2ac:	853e                	mv	a0,a5
 2ae:	00000097          	auipc	ra,0x0
 2b2:	27c080e7          	jalr	636(ra) # 52a <fstat>
 2b6:	87aa                	mv	a5,a0
 2b8:	fef42423          	sw	a5,-24(s0)
  close(fd);
 2bc:	fec42783          	lw	a5,-20(s0)
 2c0:	853e                	mv	a0,a5
 2c2:	00000097          	auipc	ra,0x0
 2c6:	238080e7          	jalr	568(ra) # 4fa <close>
  return r;
 2ca:	fe842783          	lw	a5,-24(s0)
}
 2ce:	853e                	mv	a0,a5
 2d0:	70a2                	ld	ra,40(sp)
 2d2:	7402                	ld	s0,32(sp)
 2d4:	6145                	addi	sp,sp,48
 2d6:	8082                	ret

00000000000002d8 <atoi>:

int
atoi(const char *s)
{
 2d8:	7179                	addi	sp,sp,-48
 2da:	f422                	sd	s0,40(sp)
 2dc:	1800                	addi	s0,sp,48
 2de:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 2e2:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 2e6:	a81d                	j	31c <atoi+0x44>
    n = n*10 + *s++ - '0';
 2e8:	fec42783          	lw	a5,-20(s0)
 2ec:	873e                	mv	a4,a5
 2ee:	87ba                	mv	a5,a4
 2f0:	0027979b          	slliw	a5,a5,0x2
 2f4:	9fb9                	addw	a5,a5,a4
 2f6:	0017979b          	slliw	a5,a5,0x1
 2fa:	0007871b          	sext.w	a4,a5
 2fe:	fd843783          	ld	a5,-40(s0)
 302:	00178693          	addi	a3,a5,1
 306:	fcd43c23          	sd	a3,-40(s0)
 30a:	0007c783          	lbu	a5,0(a5)
 30e:	2781                	sext.w	a5,a5
 310:	9fb9                	addw	a5,a5,a4
 312:	2781                	sext.w	a5,a5
 314:	fd07879b          	addiw	a5,a5,-48
 318:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 31c:	fd843783          	ld	a5,-40(s0)
 320:	0007c783          	lbu	a5,0(a5)
 324:	873e                	mv	a4,a5
 326:	02f00793          	li	a5,47
 32a:	00e7fb63          	bgeu	a5,a4,340 <atoi+0x68>
 32e:	fd843783          	ld	a5,-40(s0)
 332:	0007c783          	lbu	a5,0(a5)
 336:	873e                	mv	a4,a5
 338:	03900793          	li	a5,57
 33c:	fae7f6e3          	bgeu	a5,a4,2e8 <atoi+0x10>
  return n;
 340:	fec42783          	lw	a5,-20(s0)
}
 344:	853e                	mv	a0,a5
 346:	7422                	ld	s0,40(sp)
 348:	6145                	addi	sp,sp,48
 34a:	8082                	ret

000000000000034c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 34c:	7139                	addi	sp,sp,-64
 34e:	fc22                	sd	s0,56(sp)
 350:	0080                	addi	s0,sp,64
 352:	fca43c23          	sd	a0,-40(s0)
 356:	fcb43823          	sd	a1,-48(s0)
 35a:	87b2                	mv	a5,a2
 35c:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 360:	fd843783          	ld	a5,-40(s0)
 364:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 368:	fd043783          	ld	a5,-48(s0)
 36c:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 370:	fe043703          	ld	a4,-32(s0)
 374:	fe843783          	ld	a5,-24(s0)
 378:	02e7fc63          	bgeu	a5,a4,3b0 <memmove+0x64>
    while(n-- > 0)
 37c:	a00d                	j	39e <memmove+0x52>
      *dst++ = *src++;
 37e:	fe043703          	ld	a4,-32(s0)
 382:	00170793          	addi	a5,a4,1
 386:	fef43023          	sd	a5,-32(s0)
 38a:	fe843783          	ld	a5,-24(s0)
 38e:	00178693          	addi	a3,a5,1
 392:	fed43423          	sd	a3,-24(s0)
 396:	00074703          	lbu	a4,0(a4)
 39a:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 39e:	fcc42783          	lw	a5,-52(s0)
 3a2:	fff7871b          	addiw	a4,a5,-1
 3a6:	fce42623          	sw	a4,-52(s0)
 3aa:	fcf04ae3          	bgtz	a5,37e <memmove+0x32>
 3ae:	a891                	j	402 <memmove+0xb6>
  } else {
    dst += n;
 3b0:	fcc42783          	lw	a5,-52(s0)
 3b4:	fe843703          	ld	a4,-24(s0)
 3b8:	97ba                	add	a5,a5,a4
 3ba:	fef43423          	sd	a5,-24(s0)
    src += n;
 3be:	fcc42783          	lw	a5,-52(s0)
 3c2:	fe043703          	ld	a4,-32(s0)
 3c6:	97ba                	add	a5,a5,a4
 3c8:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 3cc:	a01d                	j	3f2 <memmove+0xa6>
      *--dst = *--src;
 3ce:	fe043783          	ld	a5,-32(s0)
 3d2:	17fd                	addi	a5,a5,-1
 3d4:	fef43023          	sd	a5,-32(s0)
 3d8:	fe843783          	ld	a5,-24(s0)
 3dc:	17fd                	addi	a5,a5,-1
 3de:	fef43423          	sd	a5,-24(s0)
 3e2:	fe043783          	ld	a5,-32(s0)
 3e6:	0007c703          	lbu	a4,0(a5)
 3ea:	fe843783          	ld	a5,-24(s0)
 3ee:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 3f2:	fcc42783          	lw	a5,-52(s0)
 3f6:	fff7871b          	addiw	a4,a5,-1
 3fa:	fce42623          	sw	a4,-52(s0)
 3fe:	fcf048e3          	bgtz	a5,3ce <memmove+0x82>
  }
  return vdst;
 402:	fd843783          	ld	a5,-40(s0)
}
 406:	853e                	mv	a0,a5
 408:	7462                	ld	s0,56(sp)
 40a:	6121                	addi	sp,sp,64
 40c:	8082                	ret

000000000000040e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40e:	7139                	addi	sp,sp,-64
 410:	fc22                	sd	s0,56(sp)
 412:	0080                	addi	s0,sp,64
 414:	fca43c23          	sd	a0,-40(s0)
 418:	fcb43823          	sd	a1,-48(s0)
 41c:	87b2                	mv	a5,a2
 41e:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 422:	fd843783          	ld	a5,-40(s0)
 426:	fef43423          	sd	a5,-24(s0)
 42a:	fd043783          	ld	a5,-48(s0)
 42e:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 432:	a0a1                	j	47a <memcmp+0x6c>
    if (*p1 != *p2) {
 434:	fe843783          	ld	a5,-24(s0)
 438:	0007c703          	lbu	a4,0(a5)
 43c:	fe043783          	ld	a5,-32(s0)
 440:	0007c783          	lbu	a5,0(a5)
 444:	02f70163          	beq	a4,a5,466 <memcmp+0x58>
      return *p1 - *p2;
 448:	fe843783          	ld	a5,-24(s0)
 44c:	0007c783          	lbu	a5,0(a5)
 450:	0007871b          	sext.w	a4,a5
 454:	fe043783          	ld	a5,-32(s0)
 458:	0007c783          	lbu	a5,0(a5)
 45c:	2781                	sext.w	a5,a5
 45e:	40f707bb          	subw	a5,a4,a5
 462:	2781                	sext.w	a5,a5
 464:	a01d                	j	48a <memcmp+0x7c>
    }
    p1++;
 466:	fe843783          	ld	a5,-24(s0)
 46a:	0785                	addi	a5,a5,1
 46c:	fef43423          	sd	a5,-24(s0)
    p2++;
 470:	fe043783          	ld	a5,-32(s0)
 474:	0785                	addi	a5,a5,1
 476:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 47a:	fcc42783          	lw	a5,-52(s0)
 47e:	fff7871b          	addiw	a4,a5,-1
 482:	fce42623          	sw	a4,-52(s0)
 486:	f7dd                	bnez	a5,434 <memcmp+0x26>
  }
  return 0;
 488:	4781                	li	a5,0
}
 48a:	853e                	mv	a0,a5
 48c:	7462                	ld	s0,56(sp)
 48e:	6121                	addi	sp,sp,64
 490:	8082                	ret

0000000000000492 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 492:	7179                	addi	sp,sp,-48
 494:	f406                	sd	ra,40(sp)
 496:	f022                	sd	s0,32(sp)
 498:	1800                	addi	s0,sp,48
 49a:	fea43423          	sd	a0,-24(s0)
 49e:	feb43023          	sd	a1,-32(s0)
 4a2:	87b2                	mv	a5,a2
 4a4:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 4a8:	fdc42783          	lw	a5,-36(s0)
 4ac:	863e                	mv	a2,a5
 4ae:	fe043583          	ld	a1,-32(s0)
 4b2:	fe843503          	ld	a0,-24(s0)
 4b6:	00000097          	auipc	ra,0x0
 4ba:	e96080e7          	jalr	-362(ra) # 34c <memmove>
 4be:	87aa                	mv	a5,a0
}
 4c0:	853e                	mv	a0,a5
 4c2:	70a2                	ld	ra,40(sp)
 4c4:	7402                	ld	s0,32(sp)
 4c6:	6145                	addi	sp,sp,48
 4c8:	8082                	ret

00000000000004ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ca:	4885                	li	a7,1
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4d2:	4889                	li	a7,2
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <wait>:
.global wait
wait:
 li a7, SYS_wait
 4da:	488d                	li	a7,3
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4e2:	4891                	li	a7,4
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <read>:
.global read
read:
 li a7, SYS_read
 4ea:	4895                	li	a7,5
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <write>:
.global write
write:
 li a7, SYS_write
 4f2:	48c1                	li	a7,16
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <close>:
.global close
close:
 li a7, SYS_close
 4fa:	48d5                	li	a7,21
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <kill>:
.global kill
kill:
 li a7, SYS_kill
 502:	4899                	li	a7,6
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <exec>:
.global exec
exec:
 li a7, SYS_exec
 50a:	489d                	li	a7,7
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <open>:
.global open
open:
 li a7, SYS_open
 512:	48bd                	li	a7,15
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 51a:	48c5                	li	a7,17
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 522:	48c9                	li	a7,18
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 52a:	48a1                	li	a7,8
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <link>:
.global link
link:
 li a7, SYS_link
 532:	48cd                	li	a7,19
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 53a:	48d1                	li	a7,20
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 542:	48a5                	li	a7,9
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <dup>:
.global dup
dup:
 li a7, SYS_dup
 54a:	48a9                	li	a7,10
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 552:	48ad                	li	a7,11
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 55a:	48b1                	li	a7,12
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 562:	48b5                	li	a7,13
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 56a:	48b9                	li	a7,14
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <hello>:
.global hello
hello:
 li a7, SYS_hello
 572:	48d9                	li	a7,22
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <ps>:
.global ps
ps:
 li a7, SYS_ps
 57a:	48e1                	li	a7,24
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 582:	48dd                	li	a7,23
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 58a:	48e5                	li	a7,25
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 592:	1101                	addi	sp,sp,-32
 594:	ec06                	sd	ra,24(sp)
 596:	e822                	sd	s0,16(sp)
 598:	1000                	addi	s0,sp,32
 59a:	87aa                	mv	a5,a0
 59c:	872e                	mv	a4,a1
 59e:	fef42623          	sw	a5,-20(s0)
 5a2:	87ba                	mv	a5,a4
 5a4:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 5a8:	feb40713          	addi	a4,s0,-21
 5ac:	fec42783          	lw	a5,-20(s0)
 5b0:	4605                	li	a2,1
 5b2:	85ba                	mv	a1,a4
 5b4:	853e                	mv	a0,a5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	f3c080e7          	jalr	-196(ra) # 4f2 <write>
}
 5be:	0001                	nop
 5c0:	60e2                	ld	ra,24(sp)
 5c2:	6442                	ld	s0,16(sp)
 5c4:	6105                	addi	sp,sp,32
 5c6:	8082                	ret

00000000000005c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c8:	7139                	addi	sp,sp,-64
 5ca:	fc06                	sd	ra,56(sp)
 5cc:	f822                	sd	s0,48(sp)
 5ce:	0080                	addi	s0,sp,64
 5d0:	87aa                	mv	a5,a0
 5d2:	8736                	mv	a4,a3
 5d4:	fcf42623          	sw	a5,-52(s0)
 5d8:	87ae                	mv	a5,a1
 5da:	fcf42423          	sw	a5,-56(s0)
 5de:	87b2                	mv	a5,a2
 5e0:	fcf42223          	sw	a5,-60(s0)
 5e4:	87ba                	mv	a5,a4
 5e6:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ea:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 5ee:	fc042783          	lw	a5,-64(s0)
 5f2:	2781                	sext.w	a5,a5
 5f4:	c38d                	beqz	a5,616 <printint+0x4e>
 5f6:	fc842783          	lw	a5,-56(s0)
 5fa:	2781                	sext.w	a5,a5
 5fc:	0007dd63          	bgez	a5,616 <printint+0x4e>
    neg = 1;
 600:	4785                	li	a5,1
 602:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 606:	fc842783          	lw	a5,-56(s0)
 60a:	40f007bb          	negw	a5,a5
 60e:	2781                	sext.w	a5,a5
 610:	fef42223          	sw	a5,-28(s0)
 614:	a029                	j	61e <printint+0x56>
  } else {
    x = xx;
 616:	fc842783          	lw	a5,-56(s0)
 61a:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 61e:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 622:	fc442783          	lw	a5,-60(s0)
 626:	fe442703          	lw	a4,-28(s0)
 62a:	02f777bb          	remuw	a5,a4,a5
 62e:	0007861b          	sext.w	a2,a5
 632:	fec42783          	lw	a5,-20(s0)
 636:	0017871b          	addiw	a4,a5,1
 63a:	fee42623          	sw	a4,-20(s0)
 63e:	00001697          	auipc	a3,0x1
 642:	9c268693          	addi	a3,a3,-1598 # 1000 <digits>
 646:	02061713          	slli	a4,a2,0x20
 64a:	9301                	srli	a4,a4,0x20
 64c:	9736                	add	a4,a4,a3
 64e:	00074703          	lbu	a4,0(a4)
 652:	17c1                	addi	a5,a5,-16
 654:	97a2                	add	a5,a5,s0
 656:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 65a:	fc442783          	lw	a5,-60(s0)
 65e:	fe442703          	lw	a4,-28(s0)
 662:	02f757bb          	divuw	a5,a4,a5
 666:	fef42223          	sw	a5,-28(s0)
 66a:	fe442783          	lw	a5,-28(s0)
 66e:	2781                	sext.w	a5,a5
 670:	fbcd                	bnez	a5,622 <printint+0x5a>
  if(neg)
 672:	fe842783          	lw	a5,-24(s0)
 676:	2781                	sext.w	a5,a5
 678:	cf85                	beqz	a5,6b0 <printint+0xe8>
    buf[i++] = '-';
 67a:	fec42783          	lw	a5,-20(s0)
 67e:	0017871b          	addiw	a4,a5,1
 682:	fee42623          	sw	a4,-20(s0)
 686:	17c1                	addi	a5,a5,-16
 688:	97a2                	add	a5,a5,s0
 68a:	02d00713          	li	a4,45
 68e:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 692:	a839                	j	6b0 <printint+0xe8>
    putc(fd, buf[i]);
 694:	fec42783          	lw	a5,-20(s0)
 698:	17c1                	addi	a5,a5,-16
 69a:	97a2                	add	a5,a5,s0
 69c:	fe07c703          	lbu	a4,-32(a5)
 6a0:	fcc42783          	lw	a5,-52(s0)
 6a4:	85ba                	mv	a1,a4
 6a6:	853e                	mv	a0,a5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	eea080e7          	jalr	-278(ra) # 592 <putc>
  while(--i >= 0)
 6b0:	fec42783          	lw	a5,-20(s0)
 6b4:	37fd                	addiw	a5,a5,-1
 6b6:	fef42623          	sw	a5,-20(s0)
 6ba:	fec42783          	lw	a5,-20(s0)
 6be:	2781                	sext.w	a5,a5
 6c0:	fc07dae3          	bgez	a5,694 <printint+0xcc>
}
 6c4:	0001                	nop
 6c6:	0001                	nop
 6c8:	70e2                	ld	ra,56(sp)
 6ca:	7442                	ld	s0,48(sp)
 6cc:	6121                	addi	sp,sp,64
 6ce:	8082                	ret

00000000000006d0 <printptr>:

static void
printptr(int fd, uint64 x) {
 6d0:	7179                	addi	sp,sp,-48
 6d2:	f406                	sd	ra,40(sp)
 6d4:	f022                	sd	s0,32(sp)
 6d6:	1800                	addi	s0,sp,48
 6d8:	87aa                	mv	a5,a0
 6da:	fcb43823          	sd	a1,-48(s0)
 6de:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 6e2:	fdc42783          	lw	a5,-36(s0)
 6e6:	03000593          	li	a1,48
 6ea:	853e                	mv	a0,a5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	ea6080e7          	jalr	-346(ra) # 592 <putc>
  putc(fd, 'x');
 6f4:	fdc42783          	lw	a5,-36(s0)
 6f8:	07800593          	li	a1,120
 6fc:	853e                	mv	a0,a5
 6fe:	00000097          	auipc	ra,0x0
 702:	e94080e7          	jalr	-364(ra) # 592 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 706:	fe042623          	sw	zero,-20(s0)
 70a:	a82d                	j	744 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70c:	fd043783          	ld	a5,-48(s0)
 710:	93f1                	srli	a5,a5,0x3c
 712:	00001717          	auipc	a4,0x1
 716:	8ee70713          	addi	a4,a4,-1810 # 1000 <digits>
 71a:	97ba                	add	a5,a5,a4
 71c:	0007c703          	lbu	a4,0(a5)
 720:	fdc42783          	lw	a5,-36(s0)
 724:	85ba                	mv	a1,a4
 726:	853e                	mv	a0,a5
 728:	00000097          	auipc	ra,0x0
 72c:	e6a080e7          	jalr	-406(ra) # 592 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 730:	fec42783          	lw	a5,-20(s0)
 734:	2785                	addiw	a5,a5,1
 736:	fef42623          	sw	a5,-20(s0)
 73a:	fd043783          	ld	a5,-48(s0)
 73e:	0792                	slli	a5,a5,0x4
 740:	fcf43823          	sd	a5,-48(s0)
 744:	fec42783          	lw	a5,-20(s0)
 748:	873e                	mv	a4,a5
 74a:	47bd                	li	a5,15
 74c:	fce7f0e3          	bgeu	a5,a4,70c <printptr+0x3c>
}
 750:	0001                	nop
 752:	0001                	nop
 754:	70a2                	ld	ra,40(sp)
 756:	7402                	ld	s0,32(sp)
 758:	6145                	addi	sp,sp,48
 75a:	8082                	ret

000000000000075c <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 75c:	715d                	addi	sp,sp,-80
 75e:	e486                	sd	ra,72(sp)
 760:	e0a2                	sd	s0,64(sp)
 762:	0880                	addi	s0,sp,80
 764:	87aa                	mv	a5,a0
 766:	fcb43023          	sd	a1,-64(s0)
 76a:	fac43c23          	sd	a2,-72(s0)
 76e:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 772:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 776:	fe042223          	sw	zero,-28(s0)
 77a:	a42d                	j	9a4 <vprintf+0x248>
    c = fmt[i] & 0xff;
 77c:	fe442783          	lw	a5,-28(s0)
 780:	fc043703          	ld	a4,-64(s0)
 784:	97ba                	add	a5,a5,a4
 786:	0007c783          	lbu	a5,0(a5)
 78a:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 78e:	fe042783          	lw	a5,-32(s0)
 792:	2781                	sext.w	a5,a5
 794:	eb9d                	bnez	a5,7ca <vprintf+0x6e>
      if(c == '%'){
 796:	fdc42783          	lw	a5,-36(s0)
 79a:	0007871b          	sext.w	a4,a5
 79e:	02500793          	li	a5,37
 7a2:	00f71763          	bne	a4,a5,7b0 <vprintf+0x54>
        state = '%';
 7a6:	02500793          	li	a5,37
 7aa:	fef42023          	sw	a5,-32(s0)
 7ae:	a2f5                	j	99a <vprintf+0x23e>
      } else {
        putc(fd, c);
 7b0:	fdc42783          	lw	a5,-36(s0)
 7b4:	0ff7f713          	zext.b	a4,a5
 7b8:	fcc42783          	lw	a5,-52(s0)
 7bc:	85ba                	mv	a1,a4
 7be:	853e                	mv	a0,a5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	dd2080e7          	jalr	-558(ra) # 592 <putc>
 7c8:	aac9                	j	99a <vprintf+0x23e>
      }
    } else if(state == '%'){
 7ca:	fe042783          	lw	a5,-32(s0)
 7ce:	0007871b          	sext.w	a4,a5
 7d2:	02500793          	li	a5,37
 7d6:	1cf71263          	bne	a4,a5,99a <vprintf+0x23e>
      if(c == 'd'){
 7da:	fdc42783          	lw	a5,-36(s0)
 7de:	0007871b          	sext.w	a4,a5
 7e2:	06400793          	li	a5,100
 7e6:	02f71463          	bne	a4,a5,80e <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 7ea:	fb843783          	ld	a5,-72(s0)
 7ee:	00878713          	addi	a4,a5,8
 7f2:	fae43c23          	sd	a4,-72(s0)
 7f6:	4398                	lw	a4,0(a5)
 7f8:	fcc42783          	lw	a5,-52(s0)
 7fc:	4685                	li	a3,1
 7fe:	4629                	li	a2,10
 800:	85ba                	mv	a1,a4
 802:	853e                	mv	a0,a5
 804:	00000097          	auipc	ra,0x0
 808:	dc4080e7          	jalr	-572(ra) # 5c8 <printint>
 80c:	a269                	j	996 <vprintf+0x23a>
      } else if(c == 'l') {
 80e:	fdc42783          	lw	a5,-36(s0)
 812:	0007871b          	sext.w	a4,a5
 816:	06c00793          	li	a5,108
 81a:	02f71663          	bne	a4,a5,846 <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 81e:	fb843783          	ld	a5,-72(s0)
 822:	00878713          	addi	a4,a5,8
 826:	fae43c23          	sd	a4,-72(s0)
 82a:	639c                	ld	a5,0(a5)
 82c:	0007871b          	sext.w	a4,a5
 830:	fcc42783          	lw	a5,-52(s0)
 834:	4681                	li	a3,0
 836:	4629                	li	a2,10
 838:	85ba                	mv	a1,a4
 83a:	853e                	mv	a0,a5
 83c:	00000097          	auipc	ra,0x0
 840:	d8c080e7          	jalr	-628(ra) # 5c8 <printint>
 844:	aa89                	j	996 <vprintf+0x23a>
      } else if(c == 'x') {
 846:	fdc42783          	lw	a5,-36(s0)
 84a:	0007871b          	sext.w	a4,a5
 84e:	07800793          	li	a5,120
 852:	02f71463          	bne	a4,a5,87a <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 856:	fb843783          	ld	a5,-72(s0)
 85a:	00878713          	addi	a4,a5,8
 85e:	fae43c23          	sd	a4,-72(s0)
 862:	4398                	lw	a4,0(a5)
 864:	fcc42783          	lw	a5,-52(s0)
 868:	4681                	li	a3,0
 86a:	4641                	li	a2,16
 86c:	85ba                	mv	a1,a4
 86e:	853e                	mv	a0,a5
 870:	00000097          	auipc	ra,0x0
 874:	d58080e7          	jalr	-680(ra) # 5c8 <printint>
 878:	aa39                	j	996 <vprintf+0x23a>
      } else if(c == 'p') {
 87a:	fdc42783          	lw	a5,-36(s0)
 87e:	0007871b          	sext.w	a4,a5
 882:	07000793          	li	a5,112
 886:	02f71263          	bne	a4,a5,8aa <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 88a:	fb843783          	ld	a5,-72(s0)
 88e:	00878713          	addi	a4,a5,8
 892:	fae43c23          	sd	a4,-72(s0)
 896:	6398                	ld	a4,0(a5)
 898:	fcc42783          	lw	a5,-52(s0)
 89c:	85ba                	mv	a1,a4
 89e:	853e                	mv	a0,a5
 8a0:	00000097          	auipc	ra,0x0
 8a4:	e30080e7          	jalr	-464(ra) # 6d0 <printptr>
 8a8:	a0fd                	j	996 <vprintf+0x23a>
      } else if(c == 's'){
 8aa:	fdc42783          	lw	a5,-36(s0)
 8ae:	0007871b          	sext.w	a4,a5
 8b2:	07300793          	li	a5,115
 8b6:	04f71c63          	bne	a4,a5,90e <vprintf+0x1b2>
        s = va_arg(ap, char*);
 8ba:	fb843783          	ld	a5,-72(s0)
 8be:	00878713          	addi	a4,a5,8
 8c2:	fae43c23          	sd	a4,-72(s0)
 8c6:	639c                	ld	a5,0(a5)
 8c8:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 8cc:	fe843783          	ld	a5,-24(s0)
 8d0:	eb8d                	bnez	a5,902 <vprintf+0x1a6>
          s = "(null)";
 8d2:	00000797          	auipc	a5,0x0
 8d6:	47e78793          	addi	a5,a5,1150 # d50 <malloc+0x144>
 8da:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 8de:	a015                	j	902 <vprintf+0x1a6>
          putc(fd, *s);
 8e0:	fe843783          	ld	a5,-24(s0)
 8e4:	0007c703          	lbu	a4,0(a5)
 8e8:	fcc42783          	lw	a5,-52(s0)
 8ec:	85ba                	mv	a1,a4
 8ee:	853e                	mv	a0,a5
 8f0:	00000097          	auipc	ra,0x0
 8f4:	ca2080e7          	jalr	-862(ra) # 592 <putc>
          s++;
 8f8:	fe843783          	ld	a5,-24(s0)
 8fc:	0785                	addi	a5,a5,1
 8fe:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 902:	fe843783          	ld	a5,-24(s0)
 906:	0007c783          	lbu	a5,0(a5)
 90a:	fbf9                	bnez	a5,8e0 <vprintf+0x184>
 90c:	a069                	j	996 <vprintf+0x23a>
        }
      } else if(c == 'c'){
 90e:	fdc42783          	lw	a5,-36(s0)
 912:	0007871b          	sext.w	a4,a5
 916:	06300793          	li	a5,99
 91a:	02f71463          	bne	a4,a5,942 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 91e:	fb843783          	ld	a5,-72(s0)
 922:	00878713          	addi	a4,a5,8
 926:	fae43c23          	sd	a4,-72(s0)
 92a:	439c                	lw	a5,0(a5)
 92c:	0ff7f713          	zext.b	a4,a5
 930:	fcc42783          	lw	a5,-52(s0)
 934:	85ba                	mv	a1,a4
 936:	853e                	mv	a0,a5
 938:	00000097          	auipc	ra,0x0
 93c:	c5a080e7          	jalr	-934(ra) # 592 <putc>
 940:	a899                	j	996 <vprintf+0x23a>
      } else if(c == '%'){
 942:	fdc42783          	lw	a5,-36(s0)
 946:	0007871b          	sext.w	a4,a5
 94a:	02500793          	li	a5,37
 94e:	00f71f63          	bne	a4,a5,96c <vprintf+0x210>
        putc(fd, c);
 952:	fdc42783          	lw	a5,-36(s0)
 956:	0ff7f713          	zext.b	a4,a5
 95a:	fcc42783          	lw	a5,-52(s0)
 95e:	85ba                	mv	a1,a4
 960:	853e                	mv	a0,a5
 962:	00000097          	auipc	ra,0x0
 966:	c30080e7          	jalr	-976(ra) # 592 <putc>
 96a:	a035                	j	996 <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 96c:	fcc42783          	lw	a5,-52(s0)
 970:	02500593          	li	a1,37
 974:	853e                	mv	a0,a5
 976:	00000097          	auipc	ra,0x0
 97a:	c1c080e7          	jalr	-996(ra) # 592 <putc>
        putc(fd, c);
 97e:	fdc42783          	lw	a5,-36(s0)
 982:	0ff7f713          	zext.b	a4,a5
 986:	fcc42783          	lw	a5,-52(s0)
 98a:	85ba                	mv	a1,a4
 98c:	853e                	mv	a0,a5
 98e:	00000097          	auipc	ra,0x0
 992:	c04080e7          	jalr	-1020(ra) # 592 <putc>
      }
      state = 0;
 996:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 99a:	fe442783          	lw	a5,-28(s0)
 99e:	2785                	addiw	a5,a5,1
 9a0:	fef42223          	sw	a5,-28(s0)
 9a4:	fe442783          	lw	a5,-28(s0)
 9a8:	fc043703          	ld	a4,-64(s0)
 9ac:	97ba                	add	a5,a5,a4
 9ae:	0007c783          	lbu	a5,0(a5)
 9b2:	dc0795e3          	bnez	a5,77c <vprintf+0x20>
    }
  }
}
 9b6:	0001                	nop
 9b8:	0001                	nop
 9ba:	60a6                	ld	ra,72(sp)
 9bc:	6406                	ld	s0,64(sp)
 9be:	6161                	addi	sp,sp,80
 9c0:	8082                	ret

00000000000009c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9c2:	7159                	addi	sp,sp,-112
 9c4:	fc06                	sd	ra,56(sp)
 9c6:	f822                	sd	s0,48(sp)
 9c8:	0080                	addi	s0,sp,64
 9ca:	fcb43823          	sd	a1,-48(s0)
 9ce:	e010                	sd	a2,0(s0)
 9d0:	e414                	sd	a3,8(s0)
 9d2:	e818                	sd	a4,16(s0)
 9d4:	ec1c                	sd	a5,24(s0)
 9d6:	03043023          	sd	a6,32(s0)
 9da:	03143423          	sd	a7,40(s0)
 9de:	87aa                	mv	a5,a0
 9e0:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 9e4:	03040793          	addi	a5,s0,48
 9e8:	fcf43423          	sd	a5,-56(s0)
 9ec:	fc843783          	ld	a5,-56(s0)
 9f0:	fd078793          	addi	a5,a5,-48
 9f4:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 9f8:	fe843703          	ld	a4,-24(s0)
 9fc:	fdc42783          	lw	a5,-36(s0)
 a00:	863a                	mv	a2,a4
 a02:	fd043583          	ld	a1,-48(s0)
 a06:	853e                	mv	a0,a5
 a08:	00000097          	auipc	ra,0x0
 a0c:	d54080e7          	jalr	-684(ra) # 75c <vprintf>
}
 a10:	0001                	nop
 a12:	70e2                	ld	ra,56(sp)
 a14:	7442                	ld	s0,48(sp)
 a16:	6165                	addi	sp,sp,112
 a18:	8082                	ret

0000000000000a1a <printf>:

void
printf(const char *fmt, ...)
{
 a1a:	7159                	addi	sp,sp,-112
 a1c:	f406                	sd	ra,40(sp)
 a1e:	f022                	sd	s0,32(sp)
 a20:	1800                	addi	s0,sp,48
 a22:	fca43c23          	sd	a0,-40(s0)
 a26:	e40c                	sd	a1,8(s0)
 a28:	e810                	sd	a2,16(s0)
 a2a:	ec14                	sd	a3,24(s0)
 a2c:	f018                	sd	a4,32(s0)
 a2e:	f41c                	sd	a5,40(s0)
 a30:	03043823          	sd	a6,48(s0)
 a34:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a38:	04040793          	addi	a5,s0,64
 a3c:	fcf43823          	sd	a5,-48(s0)
 a40:	fd043783          	ld	a5,-48(s0)
 a44:	fc878793          	addi	a5,a5,-56
 a48:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 a4c:	fe843783          	ld	a5,-24(s0)
 a50:	863e                	mv	a2,a5
 a52:	fd843583          	ld	a1,-40(s0)
 a56:	4505                	li	a0,1
 a58:	00000097          	auipc	ra,0x0
 a5c:	d04080e7          	jalr	-764(ra) # 75c <vprintf>
}
 a60:	0001                	nop
 a62:	70a2                	ld	ra,40(sp)
 a64:	7402                	ld	s0,32(sp)
 a66:	6165                	addi	sp,sp,112
 a68:	8082                	ret

0000000000000a6a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a6a:	7179                	addi	sp,sp,-48
 a6c:	f422                	sd	s0,40(sp)
 a6e:	1800                	addi	s0,sp,48
 a70:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a74:	fd843783          	ld	a5,-40(s0)
 a78:	17c1                	addi	a5,a5,-16
 a7a:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a7e:	00000797          	auipc	a5,0x0
 a82:	5b278793          	addi	a5,a5,1458 # 1030 <freep>
 a86:	639c                	ld	a5,0(a5)
 a88:	fef43423          	sd	a5,-24(s0)
 a8c:	a815                	j	ac0 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a8e:	fe843783          	ld	a5,-24(s0)
 a92:	639c                	ld	a5,0(a5)
 a94:	fe843703          	ld	a4,-24(s0)
 a98:	00f76f63          	bltu	a4,a5,ab6 <free+0x4c>
 a9c:	fe043703          	ld	a4,-32(s0)
 aa0:	fe843783          	ld	a5,-24(s0)
 aa4:	02e7eb63          	bltu	a5,a4,ada <free+0x70>
 aa8:	fe843783          	ld	a5,-24(s0)
 aac:	639c                	ld	a5,0(a5)
 aae:	fe043703          	ld	a4,-32(s0)
 ab2:	02f76463          	bltu	a4,a5,ada <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab6:	fe843783          	ld	a5,-24(s0)
 aba:	639c                	ld	a5,0(a5)
 abc:	fef43423          	sd	a5,-24(s0)
 ac0:	fe043703          	ld	a4,-32(s0)
 ac4:	fe843783          	ld	a5,-24(s0)
 ac8:	fce7f3e3          	bgeu	a5,a4,a8e <free+0x24>
 acc:	fe843783          	ld	a5,-24(s0)
 ad0:	639c                	ld	a5,0(a5)
 ad2:	fe043703          	ld	a4,-32(s0)
 ad6:	faf77ce3          	bgeu	a4,a5,a8e <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 ada:	fe043783          	ld	a5,-32(s0)
 ade:	479c                	lw	a5,8(a5)
 ae0:	1782                	slli	a5,a5,0x20
 ae2:	9381                	srli	a5,a5,0x20
 ae4:	0792                	slli	a5,a5,0x4
 ae6:	fe043703          	ld	a4,-32(s0)
 aea:	973e                	add	a4,a4,a5
 aec:	fe843783          	ld	a5,-24(s0)
 af0:	639c                	ld	a5,0(a5)
 af2:	02f71763          	bne	a4,a5,b20 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 af6:	fe043783          	ld	a5,-32(s0)
 afa:	4798                	lw	a4,8(a5)
 afc:	fe843783          	ld	a5,-24(s0)
 b00:	639c                	ld	a5,0(a5)
 b02:	479c                	lw	a5,8(a5)
 b04:	9fb9                	addw	a5,a5,a4
 b06:	0007871b          	sext.w	a4,a5
 b0a:	fe043783          	ld	a5,-32(s0)
 b0e:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 b10:	fe843783          	ld	a5,-24(s0)
 b14:	639c                	ld	a5,0(a5)
 b16:	6398                	ld	a4,0(a5)
 b18:	fe043783          	ld	a5,-32(s0)
 b1c:	e398                	sd	a4,0(a5)
 b1e:	a039                	j	b2c <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 b20:	fe843783          	ld	a5,-24(s0)
 b24:	6398                	ld	a4,0(a5)
 b26:	fe043783          	ld	a5,-32(s0)
 b2a:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 b2c:	fe843783          	ld	a5,-24(s0)
 b30:	479c                	lw	a5,8(a5)
 b32:	1782                	slli	a5,a5,0x20
 b34:	9381                	srli	a5,a5,0x20
 b36:	0792                	slli	a5,a5,0x4
 b38:	fe843703          	ld	a4,-24(s0)
 b3c:	97ba                	add	a5,a5,a4
 b3e:	fe043703          	ld	a4,-32(s0)
 b42:	02f71563          	bne	a4,a5,b6c <free+0x102>
    p->s.size += bp->s.size;
 b46:	fe843783          	ld	a5,-24(s0)
 b4a:	4798                	lw	a4,8(a5)
 b4c:	fe043783          	ld	a5,-32(s0)
 b50:	479c                	lw	a5,8(a5)
 b52:	9fb9                	addw	a5,a5,a4
 b54:	0007871b          	sext.w	a4,a5
 b58:	fe843783          	ld	a5,-24(s0)
 b5c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b5e:	fe043783          	ld	a5,-32(s0)
 b62:	6398                	ld	a4,0(a5)
 b64:	fe843783          	ld	a5,-24(s0)
 b68:	e398                	sd	a4,0(a5)
 b6a:	a031                	j	b76 <free+0x10c>
  } else
    p->s.ptr = bp;
 b6c:	fe843783          	ld	a5,-24(s0)
 b70:	fe043703          	ld	a4,-32(s0)
 b74:	e398                	sd	a4,0(a5)
  freep = p;
 b76:	00000797          	auipc	a5,0x0
 b7a:	4ba78793          	addi	a5,a5,1210 # 1030 <freep>
 b7e:	fe843703          	ld	a4,-24(s0)
 b82:	e398                	sd	a4,0(a5)
}
 b84:	0001                	nop
 b86:	7422                	ld	s0,40(sp)
 b88:	6145                	addi	sp,sp,48
 b8a:	8082                	ret

0000000000000b8c <morecore>:

static Header*
morecore(uint nu)
{
 b8c:	7179                	addi	sp,sp,-48
 b8e:	f406                	sd	ra,40(sp)
 b90:	f022                	sd	s0,32(sp)
 b92:	1800                	addi	s0,sp,48
 b94:	87aa                	mv	a5,a0
 b96:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 b9a:	fdc42783          	lw	a5,-36(s0)
 b9e:	0007871b          	sext.w	a4,a5
 ba2:	6785                	lui	a5,0x1
 ba4:	00f77563          	bgeu	a4,a5,bae <morecore+0x22>
    nu = 4096;
 ba8:	6785                	lui	a5,0x1
 baa:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 bae:	fdc42783          	lw	a5,-36(s0)
 bb2:	0047979b          	slliw	a5,a5,0x4
 bb6:	2781                	sext.w	a5,a5
 bb8:	2781                	sext.w	a5,a5
 bba:	853e                	mv	a0,a5
 bbc:	00000097          	auipc	ra,0x0
 bc0:	99e080e7          	jalr	-1634(ra) # 55a <sbrk>
 bc4:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 bc8:	fe843703          	ld	a4,-24(s0)
 bcc:	57fd                	li	a5,-1
 bce:	00f71463          	bne	a4,a5,bd6 <morecore+0x4a>
    return 0;
 bd2:	4781                	li	a5,0
 bd4:	a03d                	j	c02 <morecore+0x76>
  hp = (Header*)p;
 bd6:	fe843783          	ld	a5,-24(s0)
 bda:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 bde:	fe043783          	ld	a5,-32(s0)
 be2:	fdc42703          	lw	a4,-36(s0)
 be6:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 be8:	fe043783          	ld	a5,-32(s0)
 bec:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 bee:	853e                	mv	a0,a5
 bf0:	00000097          	auipc	ra,0x0
 bf4:	e7a080e7          	jalr	-390(ra) # a6a <free>
  return freep;
 bf8:	00000797          	auipc	a5,0x0
 bfc:	43878793          	addi	a5,a5,1080 # 1030 <freep>
 c00:	639c                	ld	a5,0(a5)
}
 c02:	853e                	mv	a0,a5
 c04:	70a2                	ld	ra,40(sp)
 c06:	7402                	ld	s0,32(sp)
 c08:	6145                	addi	sp,sp,48
 c0a:	8082                	ret

0000000000000c0c <malloc>:

void*
malloc(uint nbytes)
{
 c0c:	7139                	addi	sp,sp,-64
 c0e:	fc06                	sd	ra,56(sp)
 c10:	f822                	sd	s0,48(sp)
 c12:	0080                	addi	s0,sp,64
 c14:	87aa                	mv	a5,a0
 c16:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c1a:	fcc46783          	lwu	a5,-52(s0)
 c1e:	07bd                	addi	a5,a5,15
 c20:	8391                	srli	a5,a5,0x4
 c22:	2781                	sext.w	a5,a5
 c24:	2785                	addiw	a5,a5,1
 c26:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 c2a:	00000797          	auipc	a5,0x0
 c2e:	40678793          	addi	a5,a5,1030 # 1030 <freep>
 c32:	639c                	ld	a5,0(a5)
 c34:	fef43023          	sd	a5,-32(s0)
 c38:	fe043783          	ld	a5,-32(s0)
 c3c:	ef95                	bnez	a5,c78 <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 c3e:	00000797          	auipc	a5,0x0
 c42:	3e278793          	addi	a5,a5,994 # 1020 <base>
 c46:	fef43023          	sd	a5,-32(s0)
 c4a:	00000797          	auipc	a5,0x0
 c4e:	3e678793          	addi	a5,a5,998 # 1030 <freep>
 c52:	fe043703          	ld	a4,-32(s0)
 c56:	e398                	sd	a4,0(a5)
 c58:	00000797          	auipc	a5,0x0
 c5c:	3d878793          	addi	a5,a5,984 # 1030 <freep>
 c60:	6398                	ld	a4,0(a5)
 c62:	00000797          	auipc	a5,0x0
 c66:	3be78793          	addi	a5,a5,958 # 1020 <base>
 c6a:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 c6c:	00000797          	auipc	a5,0x0
 c70:	3b478793          	addi	a5,a5,948 # 1020 <base>
 c74:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c78:	fe043783          	ld	a5,-32(s0)
 c7c:	639c                	ld	a5,0(a5)
 c7e:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 c82:	fe843783          	ld	a5,-24(s0)
 c86:	4798                	lw	a4,8(a5)
 c88:	fdc42783          	lw	a5,-36(s0)
 c8c:	2781                	sext.w	a5,a5
 c8e:	06f76763          	bltu	a4,a5,cfc <malloc+0xf0>
      if(p->s.size == nunits)
 c92:	fe843783          	ld	a5,-24(s0)
 c96:	4798                	lw	a4,8(a5)
 c98:	fdc42783          	lw	a5,-36(s0)
 c9c:	2781                	sext.w	a5,a5
 c9e:	00e79963          	bne	a5,a4,cb0 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 ca2:	fe843783          	ld	a5,-24(s0)
 ca6:	6398                	ld	a4,0(a5)
 ca8:	fe043783          	ld	a5,-32(s0)
 cac:	e398                	sd	a4,0(a5)
 cae:	a825                	j	ce6 <malloc+0xda>
      else {
        p->s.size -= nunits;
 cb0:	fe843783          	ld	a5,-24(s0)
 cb4:	479c                	lw	a5,8(a5)
 cb6:	fdc42703          	lw	a4,-36(s0)
 cba:	9f99                	subw	a5,a5,a4
 cbc:	0007871b          	sext.w	a4,a5
 cc0:	fe843783          	ld	a5,-24(s0)
 cc4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cc6:	fe843783          	ld	a5,-24(s0)
 cca:	479c                	lw	a5,8(a5)
 ccc:	1782                	slli	a5,a5,0x20
 cce:	9381                	srli	a5,a5,0x20
 cd0:	0792                	slli	a5,a5,0x4
 cd2:	fe843703          	ld	a4,-24(s0)
 cd6:	97ba                	add	a5,a5,a4
 cd8:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 cdc:	fe843783          	ld	a5,-24(s0)
 ce0:	fdc42703          	lw	a4,-36(s0)
 ce4:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 ce6:	00000797          	auipc	a5,0x0
 cea:	34a78793          	addi	a5,a5,842 # 1030 <freep>
 cee:	fe043703          	ld	a4,-32(s0)
 cf2:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 cf4:	fe843783          	ld	a5,-24(s0)
 cf8:	07c1                	addi	a5,a5,16
 cfa:	a091                	j	d3e <malloc+0x132>
    }
    if(p == freep)
 cfc:	00000797          	auipc	a5,0x0
 d00:	33478793          	addi	a5,a5,820 # 1030 <freep>
 d04:	639c                	ld	a5,0(a5)
 d06:	fe843703          	ld	a4,-24(s0)
 d0a:	02f71063          	bne	a4,a5,d2a <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 d0e:	fdc42783          	lw	a5,-36(s0)
 d12:	853e                	mv	a0,a5
 d14:	00000097          	auipc	ra,0x0
 d18:	e78080e7          	jalr	-392(ra) # b8c <morecore>
 d1c:	fea43423          	sd	a0,-24(s0)
 d20:	fe843783          	ld	a5,-24(s0)
 d24:	e399                	bnez	a5,d2a <malloc+0x11e>
        return 0;
 d26:	4781                	li	a5,0
 d28:	a819                	j	d3e <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d2a:	fe843783          	ld	a5,-24(s0)
 d2e:	fef43023          	sd	a5,-32(s0)
 d32:	fe843783          	ld	a5,-24(s0)
 d36:	639c                	ld	a5,0(a5)
 d38:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 d3c:	b799                	j	c82 <malloc+0x76>
  }
}
 d3e:	853e                	mv	a0,a5
 d40:	70e2                	ld	ra,56(sp)
 d42:	7442                	ld	s0,48(sp)
 d44:	6121                	addi	sp,sp,64
 d46:	8082                	ret
