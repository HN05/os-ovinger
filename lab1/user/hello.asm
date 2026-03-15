
user/_hello:     file format elf64-littleriscv


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
	if (argc > 1) {
  12:	fec42783          	lw	a5,-20(s0)
  16:	0007871b          	sext.w	a4,a5
  1a:	4785                	li	a5,1
  1c:	02e7d163          	bge	a5,a4,3e <main+0x3e>
		printf("Hello %s, nice to meet you!\n", argv[1]);
  20:	fe043783          	ld	a5,-32(s0)
  24:	07a1                	addi	a5,a5,8
  26:	639c                	ld	a5,0(a5)
  28:	85be                	mv	a1,a5
  2a:	00001517          	auipc	a0,0x1
  2e:	d5650513          	addi	a0,a0,-682 # d80 <malloc+0x140>
  32:	00001097          	auipc	ra,0x1
  36:	a1c080e7          	jalr	-1508(ra) # a4e <printf>
		return 0;
  3a:	4781                	li	a5,0
  3c:	a811                	j	50 <main+0x50>
	}

	printf("Hello World\n");
  3e:	00001517          	auipc	a0,0x1
  42:	d6250513          	addi	a0,a0,-670 # da0 <malloc+0x160>
  46:	00001097          	auipc	ra,0x1
  4a:	a08080e7          	jalr	-1528(ra) # a4e <printf>
	return 0;
  4e:	4781                	li	a5,0
}
  50:	853e                	mv	a0,a5
  52:	60e2                	ld	ra,24(sp)
  54:	6442                	ld	s0,16(sp)
  56:	6105                	addi	sp,sp,32
  58:	8082                	ret

000000000000005a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e406                	sd	ra,8(sp)
  5e:	e022                	sd	s0,0(sp)
  60:	0800                	addi	s0,sp,16
  extern int main();
  main();
  62:	00000097          	auipc	ra,0x0
  66:	f9e080e7          	jalr	-98(ra) # 0 <main>
  exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	49a080e7          	jalr	1178(ra) # 506 <exit>

0000000000000074 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  74:	7179                	addi	sp,sp,-48
  76:	f422                	sd	s0,40(sp)
  78:	1800                	addi	s0,sp,48
  7a:	fca43c23          	sd	a0,-40(s0)
  7e:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  82:	fd843783          	ld	a5,-40(s0)
  86:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  8a:	0001                	nop
  8c:	fd043703          	ld	a4,-48(s0)
  90:	00170793          	addi	a5,a4,1
  94:	fcf43823          	sd	a5,-48(s0)
  98:	fd843783          	ld	a5,-40(s0)
  9c:	00178693          	addi	a3,a5,1
  a0:	fcd43c23          	sd	a3,-40(s0)
  a4:	00074703          	lbu	a4,0(a4)
  a8:	00e78023          	sb	a4,0(a5)
  ac:	0007c783          	lbu	a5,0(a5)
  b0:	fff1                	bnez	a5,8c <strcpy+0x18>
    ;
  return os;
  b2:	fe843783          	ld	a5,-24(s0)
}
  b6:	853e                	mv	a0,a5
  b8:	7422                	ld	s0,40(sp)
  ba:	6145                	addi	sp,sp,48
  bc:	8082                	ret

00000000000000be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  be:	1101                	addi	sp,sp,-32
  c0:	ec22                	sd	s0,24(sp)
  c2:	1000                	addi	s0,sp,32
  c4:	fea43423          	sd	a0,-24(s0)
  c8:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
  cc:	a819                	j	e2 <strcmp+0x24>
    p++, q++;
  ce:	fe843783          	ld	a5,-24(s0)
  d2:	0785                	addi	a5,a5,1
  d4:	fef43423          	sd	a5,-24(s0)
  d8:	fe043783          	ld	a5,-32(s0)
  dc:	0785                	addi	a5,a5,1
  de:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
  e2:	fe843783          	ld	a5,-24(s0)
  e6:	0007c783          	lbu	a5,0(a5)
  ea:	cb99                	beqz	a5,100 <strcmp+0x42>
  ec:	fe843783          	ld	a5,-24(s0)
  f0:	0007c703          	lbu	a4,0(a5)
  f4:	fe043783          	ld	a5,-32(s0)
  f8:	0007c783          	lbu	a5,0(a5)
  fc:	fcf709e3          	beq	a4,a5,ce <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 100:	fe843783          	ld	a5,-24(s0)
 104:	0007c783          	lbu	a5,0(a5)
 108:	0007871b          	sext.w	a4,a5
 10c:	fe043783          	ld	a5,-32(s0)
 110:	0007c783          	lbu	a5,0(a5)
 114:	2781                	sext.w	a5,a5
 116:	40f707bb          	subw	a5,a4,a5
 11a:	2781                	sext.w	a5,a5
}
 11c:	853e                	mv	a0,a5
 11e:	6462                	ld	s0,24(sp)
 120:	6105                	addi	sp,sp,32
 122:	8082                	ret

0000000000000124 <strlen>:

uint
strlen(const char *s)
{
 124:	7179                	addi	sp,sp,-48
 126:	f422                	sd	s0,40(sp)
 128:	1800                	addi	s0,sp,48
 12a:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 12e:	fe042623          	sw	zero,-20(s0)
 132:	a031                	j	13e <strlen+0x1a>
 134:	fec42783          	lw	a5,-20(s0)
 138:	2785                	addiw	a5,a5,1
 13a:	fef42623          	sw	a5,-20(s0)
 13e:	fec42783          	lw	a5,-20(s0)
 142:	fd843703          	ld	a4,-40(s0)
 146:	97ba                	add	a5,a5,a4
 148:	0007c783          	lbu	a5,0(a5)
 14c:	f7e5                	bnez	a5,134 <strlen+0x10>
    ;
  return n;
 14e:	fec42783          	lw	a5,-20(s0)
}
 152:	853e                	mv	a0,a5
 154:	7422                	ld	s0,40(sp)
 156:	6145                	addi	sp,sp,48
 158:	8082                	ret

000000000000015a <memset>:

void*
memset(void *dst, int c, uint n)
{
 15a:	7179                	addi	sp,sp,-48
 15c:	f422                	sd	s0,40(sp)
 15e:	1800                	addi	s0,sp,48
 160:	fca43c23          	sd	a0,-40(s0)
 164:	87ae                	mv	a5,a1
 166:	8732                	mv	a4,a2
 168:	fcf42a23          	sw	a5,-44(s0)
 16c:	87ba                	mv	a5,a4
 16e:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 172:	fd843783          	ld	a5,-40(s0)
 176:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 17a:	fe042623          	sw	zero,-20(s0)
 17e:	a00d                	j	1a0 <memset+0x46>
    cdst[i] = c;
 180:	fec42783          	lw	a5,-20(s0)
 184:	fe043703          	ld	a4,-32(s0)
 188:	97ba                	add	a5,a5,a4
 18a:	fd442703          	lw	a4,-44(s0)
 18e:	0ff77713          	zext.b	a4,a4
 192:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 196:	fec42783          	lw	a5,-20(s0)
 19a:	2785                	addiw	a5,a5,1
 19c:	fef42623          	sw	a5,-20(s0)
 1a0:	fec42703          	lw	a4,-20(s0)
 1a4:	fd042783          	lw	a5,-48(s0)
 1a8:	2781                	sext.w	a5,a5
 1aa:	fcf76be3          	bltu	a4,a5,180 <memset+0x26>
  }
  return dst;
 1ae:	fd843783          	ld	a5,-40(s0)
}
 1b2:	853e                	mv	a0,a5
 1b4:	7422                	ld	s0,40(sp)
 1b6:	6145                	addi	sp,sp,48
 1b8:	8082                	ret

00000000000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	1101                	addi	sp,sp,-32
 1bc:	ec22                	sd	s0,24(sp)
 1be:	1000                	addi	s0,sp,32
 1c0:	fea43423          	sd	a0,-24(s0)
 1c4:	87ae                	mv	a5,a1
 1c6:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 1ca:	a01d                	j	1f0 <strchr+0x36>
    if(*s == c)
 1cc:	fe843783          	ld	a5,-24(s0)
 1d0:	0007c703          	lbu	a4,0(a5)
 1d4:	fe744783          	lbu	a5,-25(s0)
 1d8:	0ff7f793          	zext.b	a5,a5
 1dc:	00e79563          	bne	a5,a4,1e6 <strchr+0x2c>
      return (char*)s;
 1e0:	fe843783          	ld	a5,-24(s0)
 1e4:	a821                	j	1fc <strchr+0x42>
  for(; *s; s++)
 1e6:	fe843783          	ld	a5,-24(s0)
 1ea:	0785                	addi	a5,a5,1
 1ec:	fef43423          	sd	a5,-24(s0)
 1f0:	fe843783          	ld	a5,-24(s0)
 1f4:	0007c783          	lbu	a5,0(a5)
 1f8:	fbf1                	bnez	a5,1cc <strchr+0x12>
  return 0;
 1fa:	4781                	li	a5,0
}
 1fc:	853e                	mv	a0,a5
 1fe:	6462                	ld	s0,24(sp)
 200:	6105                	addi	sp,sp,32
 202:	8082                	ret

0000000000000204 <gets>:

char*
gets(char *buf, int max)
{
 204:	7179                	addi	sp,sp,-48
 206:	f406                	sd	ra,40(sp)
 208:	f022                	sd	s0,32(sp)
 20a:	1800                	addi	s0,sp,48
 20c:	fca43c23          	sd	a0,-40(s0)
 210:	87ae                	mv	a5,a1
 212:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 216:	fe042623          	sw	zero,-20(s0)
 21a:	a8a1                	j	272 <gets+0x6e>
    cc = read(0, &c, 1);
 21c:	fe740793          	addi	a5,s0,-25
 220:	4605                	li	a2,1
 222:	85be                	mv	a1,a5
 224:	4501                	li	a0,0
 226:	00000097          	auipc	ra,0x0
 22a:	2f8080e7          	jalr	760(ra) # 51e <read>
 22e:	87aa                	mv	a5,a0
 230:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 234:	fe842783          	lw	a5,-24(s0)
 238:	2781                	sext.w	a5,a5
 23a:	04f05763          	blez	a5,288 <gets+0x84>
      break;
    buf[i++] = c;
 23e:	fec42783          	lw	a5,-20(s0)
 242:	0017871b          	addiw	a4,a5,1
 246:	fee42623          	sw	a4,-20(s0)
 24a:	873e                	mv	a4,a5
 24c:	fd843783          	ld	a5,-40(s0)
 250:	97ba                	add	a5,a5,a4
 252:	fe744703          	lbu	a4,-25(s0)
 256:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 25a:	fe744783          	lbu	a5,-25(s0)
 25e:	873e                	mv	a4,a5
 260:	47a9                	li	a5,10
 262:	02f70463          	beq	a4,a5,28a <gets+0x86>
 266:	fe744783          	lbu	a5,-25(s0)
 26a:	873e                	mv	a4,a5
 26c:	47b5                	li	a5,13
 26e:	00f70e63          	beq	a4,a5,28a <gets+0x86>
  for(i=0; i+1 < max; ){
 272:	fec42783          	lw	a5,-20(s0)
 276:	2785                	addiw	a5,a5,1
 278:	0007871b          	sext.w	a4,a5
 27c:	fd442783          	lw	a5,-44(s0)
 280:	2781                	sext.w	a5,a5
 282:	f8f74de3          	blt	a4,a5,21c <gets+0x18>
 286:	a011                	j	28a <gets+0x86>
      break;
 288:	0001                	nop
      break;
  }
  buf[i] = '\0';
 28a:	fec42783          	lw	a5,-20(s0)
 28e:	fd843703          	ld	a4,-40(s0)
 292:	97ba                	add	a5,a5,a4
 294:	00078023          	sb	zero,0(a5)
  return buf;
 298:	fd843783          	ld	a5,-40(s0)
}
 29c:	853e                	mv	a0,a5
 29e:	70a2                	ld	ra,40(sp)
 2a0:	7402                	ld	s0,32(sp)
 2a2:	6145                	addi	sp,sp,48
 2a4:	8082                	ret

00000000000002a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a6:	7179                	addi	sp,sp,-48
 2a8:	f406                	sd	ra,40(sp)
 2aa:	f022                	sd	s0,32(sp)
 2ac:	1800                	addi	s0,sp,48
 2ae:	fca43c23          	sd	a0,-40(s0)
 2b2:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	fd843503          	ld	a0,-40(s0)
 2bc:	00000097          	auipc	ra,0x0
 2c0:	28a080e7          	jalr	650(ra) # 546 <open>
 2c4:	87aa                	mv	a5,a0
 2c6:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 2ca:	fec42783          	lw	a5,-20(s0)
 2ce:	2781                	sext.w	a5,a5
 2d0:	0007d463          	bgez	a5,2d8 <stat+0x32>
    return -1;
 2d4:	57fd                	li	a5,-1
 2d6:	a035                	j	302 <stat+0x5c>
  r = fstat(fd, st);
 2d8:	fec42783          	lw	a5,-20(s0)
 2dc:	fd043583          	ld	a1,-48(s0)
 2e0:	853e                	mv	a0,a5
 2e2:	00000097          	auipc	ra,0x0
 2e6:	27c080e7          	jalr	636(ra) # 55e <fstat>
 2ea:	87aa                	mv	a5,a0
 2ec:	fef42423          	sw	a5,-24(s0)
  close(fd);
 2f0:	fec42783          	lw	a5,-20(s0)
 2f4:	853e                	mv	a0,a5
 2f6:	00000097          	auipc	ra,0x0
 2fa:	238080e7          	jalr	568(ra) # 52e <close>
  return r;
 2fe:	fe842783          	lw	a5,-24(s0)
}
 302:	853e                	mv	a0,a5
 304:	70a2                	ld	ra,40(sp)
 306:	7402                	ld	s0,32(sp)
 308:	6145                	addi	sp,sp,48
 30a:	8082                	ret

000000000000030c <atoi>:

int
atoi(const char *s)
{
 30c:	7179                	addi	sp,sp,-48
 30e:	f422                	sd	s0,40(sp)
 310:	1800                	addi	s0,sp,48
 312:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 316:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 31a:	a81d                	j	350 <atoi+0x44>
    n = n*10 + *s++ - '0';
 31c:	fec42783          	lw	a5,-20(s0)
 320:	873e                	mv	a4,a5
 322:	87ba                	mv	a5,a4
 324:	0027979b          	slliw	a5,a5,0x2
 328:	9fb9                	addw	a5,a5,a4
 32a:	0017979b          	slliw	a5,a5,0x1
 32e:	0007871b          	sext.w	a4,a5
 332:	fd843783          	ld	a5,-40(s0)
 336:	00178693          	addi	a3,a5,1
 33a:	fcd43c23          	sd	a3,-40(s0)
 33e:	0007c783          	lbu	a5,0(a5)
 342:	2781                	sext.w	a5,a5
 344:	9fb9                	addw	a5,a5,a4
 346:	2781                	sext.w	a5,a5
 348:	fd07879b          	addiw	a5,a5,-48
 34c:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 350:	fd843783          	ld	a5,-40(s0)
 354:	0007c783          	lbu	a5,0(a5)
 358:	873e                	mv	a4,a5
 35a:	02f00793          	li	a5,47
 35e:	00e7fb63          	bgeu	a5,a4,374 <atoi+0x68>
 362:	fd843783          	ld	a5,-40(s0)
 366:	0007c783          	lbu	a5,0(a5)
 36a:	873e                	mv	a4,a5
 36c:	03900793          	li	a5,57
 370:	fae7f6e3          	bgeu	a5,a4,31c <atoi+0x10>
  return n;
 374:	fec42783          	lw	a5,-20(s0)
}
 378:	853e                	mv	a0,a5
 37a:	7422                	ld	s0,40(sp)
 37c:	6145                	addi	sp,sp,48
 37e:	8082                	ret

0000000000000380 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 380:	7139                	addi	sp,sp,-64
 382:	fc22                	sd	s0,56(sp)
 384:	0080                	addi	s0,sp,64
 386:	fca43c23          	sd	a0,-40(s0)
 38a:	fcb43823          	sd	a1,-48(s0)
 38e:	87b2                	mv	a5,a2
 390:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 394:	fd843783          	ld	a5,-40(s0)
 398:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 39c:	fd043783          	ld	a5,-48(s0)
 3a0:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 3a4:	fe043703          	ld	a4,-32(s0)
 3a8:	fe843783          	ld	a5,-24(s0)
 3ac:	02e7fc63          	bgeu	a5,a4,3e4 <memmove+0x64>
    while(n-- > 0)
 3b0:	a00d                	j	3d2 <memmove+0x52>
      *dst++ = *src++;
 3b2:	fe043703          	ld	a4,-32(s0)
 3b6:	00170793          	addi	a5,a4,1
 3ba:	fef43023          	sd	a5,-32(s0)
 3be:	fe843783          	ld	a5,-24(s0)
 3c2:	00178693          	addi	a3,a5,1
 3c6:	fed43423          	sd	a3,-24(s0)
 3ca:	00074703          	lbu	a4,0(a4)
 3ce:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 3d2:	fcc42783          	lw	a5,-52(s0)
 3d6:	fff7871b          	addiw	a4,a5,-1
 3da:	fce42623          	sw	a4,-52(s0)
 3de:	fcf04ae3          	bgtz	a5,3b2 <memmove+0x32>
 3e2:	a891                	j	436 <memmove+0xb6>
  } else {
    dst += n;
 3e4:	fcc42783          	lw	a5,-52(s0)
 3e8:	fe843703          	ld	a4,-24(s0)
 3ec:	97ba                	add	a5,a5,a4
 3ee:	fef43423          	sd	a5,-24(s0)
    src += n;
 3f2:	fcc42783          	lw	a5,-52(s0)
 3f6:	fe043703          	ld	a4,-32(s0)
 3fa:	97ba                	add	a5,a5,a4
 3fc:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 400:	a01d                	j	426 <memmove+0xa6>
      *--dst = *--src;
 402:	fe043783          	ld	a5,-32(s0)
 406:	17fd                	addi	a5,a5,-1
 408:	fef43023          	sd	a5,-32(s0)
 40c:	fe843783          	ld	a5,-24(s0)
 410:	17fd                	addi	a5,a5,-1
 412:	fef43423          	sd	a5,-24(s0)
 416:	fe043783          	ld	a5,-32(s0)
 41a:	0007c703          	lbu	a4,0(a5)
 41e:	fe843783          	ld	a5,-24(s0)
 422:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 426:	fcc42783          	lw	a5,-52(s0)
 42a:	fff7871b          	addiw	a4,a5,-1
 42e:	fce42623          	sw	a4,-52(s0)
 432:	fcf048e3          	bgtz	a5,402 <memmove+0x82>
  }
  return vdst;
 436:	fd843783          	ld	a5,-40(s0)
}
 43a:	853e                	mv	a0,a5
 43c:	7462                	ld	s0,56(sp)
 43e:	6121                	addi	sp,sp,64
 440:	8082                	ret

0000000000000442 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 442:	7139                	addi	sp,sp,-64
 444:	fc22                	sd	s0,56(sp)
 446:	0080                	addi	s0,sp,64
 448:	fca43c23          	sd	a0,-40(s0)
 44c:	fcb43823          	sd	a1,-48(s0)
 450:	87b2                	mv	a5,a2
 452:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 456:	fd843783          	ld	a5,-40(s0)
 45a:	fef43423          	sd	a5,-24(s0)
 45e:	fd043783          	ld	a5,-48(s0)
 462:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 466:	a0a1                	j	4ae <memcmp+0x6c>
    if (*p1 != *p2) {
 468:	fe843783          	ld	a5,-24(s0)
 46c:	0007c703          	lbu	a4,0(a5)
 470:	fe043783          	ld	a5,-32(s0)
 474:	0007c783          	lbu	a5,0(a5)
 478:	02f70163          	beq	a4,a5,49a <memcmp+0x58>
      return *p1 - *p2;
 47c:	fe843783          	ld	a5,-24(s0)
 480:	0007c783          	lbu	a5,0(a5)
 484:	0007871b          	sext.w	a4,a5
 488:	fe043783          	ld	a5,-32(s0)
 48c:	0007c783          	lbu	a5,0(a5)
 490:	2781                	sext.w	a5,a5
 492:	40f707bb          	subw	a5,a4,a5
 496:	2781                	sext.w	a5,a5
 498:	a01d                	j	4be <memcmp+0x7c>
    }
    p1++;
 49a:	fe843783          	ld	a5,-24(s0)
 49e:	0785                	addi	a5,a5,1
 4a0:	fef43423          	sd	a5,-24(s0)
    p2++;
 4a4:	fe043783          	ld	a5,-32(s0)
 4a8:	0785                	addi	a5,a5,1
 4aa:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 4ae:	fcc42783          	lw	a5,-52(s0)
 4b2:	fff7871b          	addiw	a4,a5,-1
 4b6:	fce42623          	sw	a4,-52(s0)
 4ba:	f7dd                	bnez	a5,468 <memcmp+0x26>
  }
  return 0;
 4bc:	4781                	li	a5,0
}
 4be:	853e                	mv	a0,a5
 4c0:	7462                	ld	s0,56(sp)
 4c2:	6121                	addi	sp,sp,64
 4c4:	8082                	ret

00000000000004c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4c6:	7179                	addi	sp,sp,-48
 4c8:	f406                	sd	ra,40(sp)
 4ca:	f022                	sd	s0,32(sp)
 4cc:	1800                	addi	s0,sp,48
 4ce:	fea43423          	sd	a0,-24(s0)
 4d2:	feb43023          	sd	a1,-32(s0)
 4d6:	87b2                	mv	a5,a2
 4d8:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 4dc:	fdc42783          	lw	a5,-36(s0)
 4e0:	863e                	mv	a2,a5
 4e2:	fe043583          	ld	a1,-32(s0)
 4e6:	fe843503          	ld	a0,-24(s0)
 4ea:	00000097          	auipc	ra,0x0
 4ee:	e96080e7          	jalr	-362(ra) # 380 <memmove>
 4f2:	87aa                	mv	a5,a0
}
 4f4:	853e                	mv	a0,a5
 4f6:	70a2                	ld	ra,40(sp)
 4f8:	7402                	ld	s0,32(sp)
 4fa:	6145                	addi	sp,sp,48
 4fc:	8082                	ret

00000000000004fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4fe:	4885                	li	a7,1
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <exit>:
.global exit
exit:
 li a7, SYS_exit
 506:	4889                	li	a7,2
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <wait>:
.global wait
wait:
 li a7, SYS_wait
 50e:	488d                	li	a7,3
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 516:	4891                	li	a7,4
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <read>:
.global read
read:
 li a7, SYS_read
 51e:	4895                	li	a7,5
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <write>:
.global write
write:
 li a7, SYS_write
 526:	48c1                	li	a7,16
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <close>:
.global close
close:
 li a7, SYS_close
 52e:	48d5                	li	a7,21
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <kill>:
.global kill
kill:
 li a7, SYS_kill
 536:	4899                	li	a7,6
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <exec>:
.global exec
exec:
 li a7, SYS_exec
 53e:	489d                	li	a7,7
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <open>:
.global open
open:
 li a7, SYS_open
 546:	48bd                	li	a7,15
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 54e:	48c5                	li	a7,17
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 556:	48c9                	li	a7,18
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 55e:	48a1                	li	a7,8
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <link>:
.global link
link:
 li a7, SYS_link
 566:	48cd                	li	a7,19
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 56e:	48d1                	li	a7,20
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 576:	48a5                	li	a7,9
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <dup>:
.global dup
dup:
 li a7, SYS_dup
 57e:	48a9                	li	a7,10
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 586:	48ad                	li	a7,11
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 58e:	48b1                	li	a7,12
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 596:	48b5                	li	a7,13
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 59e:	48b9                	li	a7,14
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <hello>:
.global hello
hello:
 li a7, SYS_hello
 5a6:	48d9                	li	a7,22
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <ps>:
.global ps
ps:
 li a7, SYS_ps
 5ae:	48e1                	li	a7,24
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 5b6:	48dd                	li	a7,23
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 5be:	48e5                	li	a7,25
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5c6:	1101                	addi	sp,sp,-32
 5c8:	ec06                	sd	ra,24(sp)
 5ca:	e822                	sd	s0,16(sp)
 5cc:	1000                	addi	s0,sp,32
 5ce:	87aa                	mv	a5,a0
 5d0:	872e                	mv	a4,a1
 5d2:	fef42623          	sw	a5,-20(s0)
 5d6:	87ba                	mv	a5,a4
 5d8:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 5dc:	feb40713          	addi	a4,s0,-21
 5e0:	fec42783          	lw	a5,-20(s0)
 5e4:	4605                	li	a2,1
 5e6:	85ba                	mv	a1,a4
 5e8:	853e                	mv	a0,a5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	f3c080e7          	jalr	-196(ra) # 526 <write>
}
 5f2:	0001                	nop
 5f4:	60e2                	ld	ra,24(sp)
 5f6:	6442                	ld	s0,16(sp)
 5f8:	6105                	addi	sp,sp,32
 5fa:	8082                	ret

00000000000005fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5fc:	7139                	addi	sp,sp,-64
 5fe:	fc06                	sd	ra,56(sp)
 600:	f822                	sd	s0,48(sp)
 602:	0080                	addi	s0,sp,64
 604:	87aa                	mv	a5,a0
 606:	8736                	mv	a4,a3
 608:	fcf42623          	sw	a5,-52(s0)
 60c:	87ae                	mv	a5,a1
 60e:	fcf42423          	sw	a5,-56(s0)
 612:	87b2                	mv	a5,a2
 614:	fcf42223          	sw	a5,-60(s0)
 618:	87ba                	mv	a5,a4
 61a:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 61e:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 622:	fc042783          	lw	a5,-64(s0)
 626:	2781                	sext.w	a5,a5
 628:	c38d                	beqz	a5,64a <printint+0x4e>
 62a:	fc842783          	lw	a5,-56(s0)
 62e:	2781                	sext.w	a5,a5
 630:	0007dd63          	bgez	a5,64a <printint+0x4e>
    neg = 1;
 634:	4785                	li	a5,1
 636:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 63a:	fc842783          	lw	a5,-56(s0)
 63e:	40f007bb          	negw	a5,a5
 642:	2781                	sext.w	a5,a5
 644:	fef42223          	sw	a5,-28(s0)
 648:	a029                	j	652 <printint+0x56>
  } else {
    x = xx;
 64a:	fc842783          	lw	a5,-56(s0)
 64e:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 652:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 656:	fc442783          	lw	a5,-60(s0)
 65a:	fe442703          	lw	a4,-28(s0)
 65e:	02f777bb          	remuw	a5,a4,a5
 662:	0007861b          	sext.w	a2,a5
 666:	fec42783          	lw	a5,-20(s0)
 66a:	0017871b          	addiw	a4,a5,1
 66e:	fee42623          	sw	a4,-20(s0)
 672:	00001697          	auipc	a3,0x1
 676:	98e68693          	addi	a3,a3,-1650 # 1000 <digits>
 67a:	02061713          	slli	a4,a2,0x20
 67e:	9301                	srli	a4,a4,0x20
 680:	9736                	add	a4,a4,a3
 682:	00074703          	lbu	a4,0(a4)
 686:	17c1                	addi	a5,a5,-16
 688:	97a2                	add	a5,a5,s0
 68a:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 68e:	fc442783          	lw	a5,-60(s0)
 692:	fe442703          	lw	a4,-28(s0)
 696:	02f757bb          	divuw	a5,a4,a5
 69a:	fef42223          	sw	a5,-28(s0)
 69e:	fe442783          	lw	a5,-28(s0)
 6a2:	2781                	sext.w	a5,a5
 6a4:	fbcd                	bnez	a5,656 <printint+0x5a>
  if(neg)
 6a6:	fe842783          	lw	a5,-24(s0)
 6aa:	2781                	sext.w	a5,a5
 6ac:	cf85                	beqz	a5,6e4 <printint+0xe8>
    buf[i++] = '-';
 6ae:	fec42783          	lw	a5,-20(s0)
 6b2:	0017871b          	addiw	a4,a5,1
 6b6:	fee42623          	sw	a4,-20(s0)
 6ba:	17c1                	addi	a5,a5,-16
 6bc:	97a2                	add	a5,a5,s0
 6be:	02d00713          	li	a4,45
 6c2:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 6c6:	a839                	j	6e4 <printint+0xe8>
    putc(fd, buf[i]);
 6c8:	fec42783          	lw	a5,-20(s0)
 6cc:	17c1                	addi	a5,a5,-16
 6ce:	97a2                	add	a5,a5,s0
 6d0:	fe07c703          	lbu	a4,-32(a5)
 6d4:	fcc42783          	lw	a5,-52(s0)
 6d8:	85ba                	mv	a1,a4
 6da:	853e                	mv	a0,a5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	eea080e7          	jalr	-278(ra) # 5c6 <putc>
  while(--i >= 0)
 6e4:	fec42783          	lw	a5,-20(s0)
 6e8:	37fd                	addiw	a5,a5,-1
 6ea:	fef42623          	sw	a5,-20(s0)
 6ee:	fec42783          	lw	a5,-20(s0)
 6f2:	2781                	sext.w	a5,a5
 6f4:	fc07dae3          	bgez	a5,6c8 <printint+0xcc>
}
 6f8:	0001                	nop
 6fa:	0001                	nop
 6fc:	70e2                	ld	ra,56(sp)
 6fe:	7442                	ld	s0,48(sp)
 700:	6121                	addi	sp,sp,64
 702:	8082                	ret

0000000000000704 <printptr>:

static void
printptr(int fd, uint64 x) {
 704:	7179                	addi	sp,sp,-48
 706:	f406                	sd	ra,40(sp)
 708:	f022                	sd	s0,32(sp)
 70a:	1800                	addi	s0,sp,48
 70c:	87aa                	mv	a5,a0
 70e:	fcb43823          	sd	a1,-48(s0)
 712:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 716:	fdc42783          	lw	a5,-36(s0)
 71a:	03000593          	li	a1,48
 71e:	853e                	mv	a0,a5
 720:	00000097          	auipc	ra,0x0
 724:	ea6080e7          	jalr	-346(ra) # 5c6 <putc>
  putc(fd, 'x');
 728:	fdc42783          	lw	a5,-36(s0)
 72c:	07800593          	li	a1,120
 730:	853e                	mv	a0,a5
 732:	00000097          	auipc	ra,0x0
 736:	e94080e7          	jalr	-364(ra) # 5c6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73a:	fe042623          	sw	zero,-20(s0)
 73e:	a82d                	j	778 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 740:	fd043783          	ld	a5,-48(s0)
 744:	93f1                	srli	a5,a5,0x3c
 746:	00001717          	auipc	a4,0x1
 74a:	8ba70713          	addi	a4,a4,-1862 # 1000 <digits>
 74e:	97ba                	add	a5,a5,a4
 750:	0007c703          	lbu	a4,0(a5)
 754:	fdc42783          	lw	a5,-36(s0)
 758:	85ba                	mv	a1,a4
 75a:	853e                	mv	a0,a5
 75c:	00000097          	auipc	ra,0x0
 760:	e6a080e7          	jalr	-406(ra) # 5c6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 764:	fec42783          	lw	a5,-20(s0)
 768:	2785                	addiw	a5,a5,1
 76a:	fef42623          	sw	a5,-20(s0)
 76e:	fd043783          	ld	a5,-48(s0)
 772:	0792                	slli	a5,a5,0x4
 774:	fcf43823          	sd	a5,-48(s0)
 778:	fec42783          	lw	a5,-20(s0)
 77c:	873e                	mv	a4,a5
 77e:	47bd                	li	a5,15
 780:	fce7f0e3          	bgeu	a5,a4,740 <printptr+0x3c>
}
 784:	0001                	nop
 786:	0001                	nop
 788:	70a2                	ld	ra,40(sp)
 78a:	7402                	ld	s0,32(sp)
 78c:	6145                	addi	sp,sp,48
 78e:	8082                	ret

0000000000000790 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 790:	715d                	addi	sp,sp,-80
 792:	e486                	sd	ra,72(sp)
 794:	e0a2                	sd	s0,64(sp)
 796:	0880                	addi	s0,sp,80
 798:	87aa                	mv	a5,a0
 79a:	fcb43023          	sd	a1,-64(s0)
 79e:	fac43c23          	sd	a2,-72(s0)
 7a2:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 7a6:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 7aa:	fe042223          	sw	zero,-28(s0)
 7ae:	a42d                	j	9d8 <vprintf+0x248>
    c = fmt[i] & 0xff;
 7b0:	fe442783          	lw	a5,-28(s0)
 7b4:	fc043703          	ld	a4,-64(s0)
 7b8:	97ba                	add	a5,a5,a4
 7ba:	0007c783          	lbu	a5,0(a5)
 7be:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 7c2:	fe042783          	lw	a5,-32(s0)
 7c6:	2781                	sext.w	a5,a5
 7c8:	eb9d                	bnez	a5,7fe <vprintf+0x6e>
      if(c == '%'){
 7ca:	fdc42783          	lw	a5,-36(s0)
 7ce:	0007871b          	sext.w	a4,a5
 7d2:	02500793          	li	a5,37
 7d6:	00f71763          	bne	a4,a5,7e4 <vprintf+0x54>
        state = '%';
 7da:	02500793          	li	a5,37
 7de:	fef42023          	sw	a5,-32(s0)
 7e2:	a2f5                	j	9ce <vprintf+0x23e>
      } else {
        putc(fd, c);
 7e4:	fdc42783          	lw	a5,-36(s0)
 7e8:	0ff7f713          	zext.b	a4,a5
 7ec:	fcc42783          	lw	a5,-52(s0)
 7f0:	85ba                	mv	a1,a4
 7f2:	853e                	mv	a0,a5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	dd2080e7          	jalr	-558(ra) # 5c6 <putc>
 7fc:	aac9                	j	9ce <vprintf+0x23e>
      }
    } else if(state == '%'){
 7fe:	fe042783          	lw	a5,-32(s0)
 802:	0007871b          	sext.w	a4,a5
 806:	02500793          	li	a5,37
 80a:	1cf71263          	bne	a4,a5,9ce <vprintf+0x23e>
      if(c == 'd'){
 80e:	fdc42783          	lw	a5,-36(s0)
 812:	0007871b          	sext.w	a4,a5
 816:	06400793          	li	a5,100
 81a:	02f71463          	bne	a4,a5,842 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 81e:	fb843783          	ld	a5,-72(s0)
 822:	00878713          	addi	a4,a5,8
 826:	fae43c23          	sd	a4,-72(s0)
 82a:	4398                	lw	a4,0(a5)
 82c:	fcc42783          	lw	a5,-52(s0)
 830:	4685                	li	a3,1
 832:	4629                	li	a2,10
 834:	85ba                	mv	a1,a4
 836:	853e                	mv	a0,a5
 838:	00000097          	auipc	ra,0x0
 83c:	dc4080e7          	jalr	-572(ra) # 5fc <printint>
 840:	a269                	j	9ca <vprintf+0x23a>
      } else if(c == 'l') {
 842:	fdc42783          	lw	a5,-36(s0)
 846:	0007871b          	sext.w	a4,a5
 84a:	06c00793          	li	a5,108
 84e:	02f71663          	bne	a4,a5,87a <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 852:	fb843783          	ld	a5,-72(s0)
 856:	00878713          	addi	a4,a5,8
 85a:	fae43c23          	sd	a4,-72(s0)
 85e:	639c                	ld	a5,0(a5)
 860:	0007871b          	sext.w	a4,a5
 864:	fcc42783          	lw	a5,-52(s0)
 868:	4681                	li	a3,0
 86a:	4629                	li	a2,10
 86c:	85ba                	mv	a1,a4
 86e:	853e                	mv	a0,a5
 870:	00000097          	auipc	ra,0x0
 874:	d8c080e7          	jalr	-628(ra) # 5fc <printint>
 878:	aa89                	j	9ca <vprintf+0x23a>
      } else if(c == 'x') {
 87a:	fdc42783          	lw	a5,-36(s0)
 87e:	0007871b          	sext.w	a4,a5
 882:	07800793          	li	a5,120
 886:	02f71463          	bne	a4,a5,8ae <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 88a:	fb843783          	ld	a5,-72(s0)
 88e:	00878713          	addi	a4,a5,8
 892:	fae43c23          	sd	a4,-72(s0)
 896:	4398                	lw	a4,0(a5)
 898:	fcc42783          	lw	a5,-52(s0)
 89c:	4681                	li	a3,0
 89e:	4641                	li	a2,16
 8a0:	85ba                	mv	a1,a4
 8a2:	853e                	mv	a0,a5
 8a4:	00000097          	auipc	ra,0x0
 8a8:	d58080e7          	jalr	-680(ra) # 5fc <printint>
 8ac:	aa39                	j	9ca <vprintf+0x23a>
      } else if(c == 'p') {
 8ae:	fdc42783          	lw	a5,-36(s0)
 8b2:	0007871b          	sext.w	a4,a5
 8b6:	07000793          	li	a5,112
 8ba:	02f71263          	bne	a4,a5,8de <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 8be:	fb843783          	ld	a5,-72(s0)
 8c2:	00878713          	addi	a4,a5,8
 8c6:	fae43c23          	sd	a4,-72(s0)
 8ca:	6398                	ld	a4,0(a5)
 8cc:	fcc42783          	lw	a5,-52(s0)
 8d0:	85ba                	mv	a1,a4
 8d2:	853e                	mv	a0,a5
 8d4:	00000097          	auipc	ra,0x0
 8d8:	e30080e7          	jalr	-464(ra) # 704 <printptr>
 8dc:	a0fd                	j	9ca <vprintf+0x23a>
      } else if(c == 's'){
 8de:	fdc42783          	lw	a5,-36(s0)
 8e2:	0007871b          	sext.w	a4,a5
 8e6:	07300793          	li	a5,115
 8ea:	04f71c63          	bne	a4,a5,942 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 8ee:	fb843783          	ld	a5,-72(s0)
 8f2:	00878713          	addi	a4,a5,8
 8f6:	fae43c23          	sd	a4,-72(s0)
 8fa:	639c                	ld	a5,0(a5)
 8fc:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 900:	fe843783          	ld	a5,-24(s0)
 904:	eb8d                	bnez	a5,936 <vprintf+0x1a6>
          s = "(null)";
 906:	00000797          	auipc	a5,0x0
 90a:	4aa78793          	addi	a5,a5,1194 # db0 <malloc+0x170>
 90e:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 912:	a015                	j	936 <vprintf+0x1a6>
          putc(fd, *s);
 914:	fe843783          	ld	a5,-24(s0)
 918:	0007c703          	lbu	a4,0(a5)
 91c:	fcc42783          	lw	a5,-52(s0)
 920:	85ba                	mv	a1,a4
 922:	853e                	mv	a0,a5
 924:	00000097          	auipc	ra,0x0
 928:	ca2080e7          	jalr	-862(ra) # 5c6 <putc>
          s++;
 92c:	fe843783          	ld	a5,-24(s0)
 930:	0785                	addi	a5,a5,1
 932:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 936:	fe843783          	ld	a5,-24(s0)
 93a:	0007c783          	lbu	a5,0(a5)
 93e:	fbf9                	bnez	a5,914 <vprintf+0x184>
 940:	a069                	j	9ca <vprintf+0x23a>
        }
      } else if(c == 'c'){
 942:	fdc42783          	lw	a5,-36(s0)
 946:	0007871b          	sext.w	a4,a5
 94a:	06300793          	li	a5,99
 94e:	02f71463          	bne	a4,a5,976 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 952:	fb843783          	ld	a5,-72(s0)
 956:	00878713          	addi	a4,a5,8
 95a:	fae43c23          	sd	a4,-72(s0)
 95e:	439c                	lw	a5,0(a5)
 960:	0ff7f713          	zext.b	a4,a5
 964:	fcc42783          	lw	a5,-52(s0)
 968:	85ba                	mv	a1,a4
 96a:	853e                	mv	a0,a5
 96c:	00000097          	auipc	ra,0x0
 970:	c5a080e7          	jalr	-934(ra) # 5c6 <putc>
 974:	a899                	j	9ca <vprintf+0x23a>
      } else if(c == '%'){
 976:	fdc42783          	lw	a5,-36(s0)
 97a:	0007871b          	sext.w	a4,a5
 97e:	02500793          	li	a5,37
 982:	00f71f63          	bne	a4,a5,9a0 <vprintf+0x210>
        putc(fd, c);
 986:	fdc42783          	lw	a5,-36(s0)
 98a:	0ff7f713          	zext.b	a4,a5
 98e:	fcc42783          	lw	a5,-52(s0)
 992:	85ba                	mv	a1,a4
 994:	853e                	mv	a0,a5
 996:	00000097          	auipc	ra,0x0
 99a:	c30080e7          	jalr	-976(ra) # 5c6 <putc>
 99e:	a035                	j	9ca <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9a0:	fcc42783          	lw	a5,-52(s0)
 9a4:	02500593          	li	a1,37
 9a8:	853e                	mv	a0,a5
 9aa:	00000097          	auipc	ra,0x0
 9ae:	c1c080e7          	jalr	-996(ra) # 5c6 <putc>
        putc(fd, c);
 9b2:	fdc42783          	lw	a5,-36(s0)
 9b6:	0ff7f713          	zext.b	a4,a5
 9ba:	fcc42783          	lw	a5,-52(s0)
 9be:	85ba                	mv	a1,a4
 9c0:	853e                	mv	a0,a5
 9c2:	00000097          	auipc	ra,0x0
 9c6:	c04080e7          	jalr	-1020(ra) # 5c6 <putc>
      }
      state = 0;
 9ca:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 9ce:	fe442783          	lw	a5,-28(s0)
 9d2:	2785                	addiw	a5,a5,1
 9d4:	fef42223          	sw	a5,-28(s0)
 9d8:	fe442783          	lw	a5,-28(s0)
 9dc:	fc043703          	ld	a4,-64(s0)
 9e0:	97ba                	add	a5,a5,a4
 9e2:	0007c783          	lbu	a5,0(a5)
 9e6:	dc0795e3          	bnez	a5,7b0 <vprintf+0x20>
    }
  }
}
 9ea:	0001                	nop
 9ec:	0001                	nop
 9ee:	60a6                	ld	ra,72(sp)
 9f0:	6406                	ld	s0,64(sp)
 9f2:	6161                	addi	sp,sp,80
 9f4:	8082                	ret

00000000000009f6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9f6:	7159                	addi	sp,sp,-112
 9f8:	fc06                	sd	ra,56(sp)
 9fa:	f822                	sd	s0,48(sp)
 9fc:	0080                	addi	s0,sp,64
 9fe:	fcb43823          	sd	a1,-48(s0)
 a02:	e010                	sd	a2,0(s0)
 a04:	e414                	sd	a3,8(s0)
 a06:	e818                	sd	a4,16(s0)
 a08:	ec1c                	sd	a5,24(s0)
 a0a:	03043023          	sd	a6,32(s0)
 a0e:	03143423          	sd	a7,40(s0)
 a12:	87aa                	mv	a5,a0
 a14:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 a18:	03040793          	addi	a5,s0,48
 a1c:	fcf43423          	sd	a5,-56(s0)
 a20:	fc843783          	ld	a5,-56(s0)
 a24:	fd078793          	addi	a5,a5,-48
 a28:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 a2c:	fe843703          	ld	a4,-24(s0)
 a30:	fdc42783          	lw	a5,-36(s0)
 a34:	863a                	mv	a2,a4
 a36:	fd043583          	ld	a1,-48(s0)
 a3a:	853e                	mv	a0,a5
 a3c:	00000097          	auipc	ra,0x0
 a40:	d54080e7          	jalr	-684(ra) # 790 <vprintf>
}
 a44:	0001                	nop
 a46:	70e2                	ld	ra,56(sp)
 a48:	7442                	ld	s0,48(sp)
 a4a:	6165                	addi	sp,sp,112
 a4c:	8082                	ret

0000000000000a4e <printf>:

void
printf(const char *fmt, ...)
{
 a4e:	7159                	addi	sp,sp,-112
 a50:	f406                	sd	ra,40(sp)
 a52:	f022                	sd	s0,32(sp)
 a54:	1800                	addi	s0,sp,48
 a56:	fca43c23          	sd	a0,-40(s0)
 a5a:	e40c                	sd	a1,8(s0)
 a5c:	e810                	sd	a2,16(s0)
 a5e:	ec14                	sd	a3,24(s0)
 a60:	f018                	sd	a4,32(s0)
 a62:	f41c                	sd	a5,40(s0)
 a64:	03043823          	sd	a6,48(s0)
 a68:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a6c:	04040793          	addi	a5,s0,64
 a70:	fcf43823          	sd	a5,-48(s0)
 a74:	fd043783          	ld	a5,-48(s0)
 a78:	fc878793          	addi	a5,a5,-56
 a7c:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 a80:	fe843783          	ld	a5,-24(s0)
 a84:	863e                	mv	a2,a5
 a86:	fd843583          	ld	a1,-40(s0)
 a8a:	4505                	li	a0,1
 a8c:	00000097          	auipc	ra,0x0
 a90:	d04080e7          	jalr	-764(ra) # 790 <vprintf>
}
 a94:	0001                	nop
 a96:	70a2                	ld	ra,40(sp)
 a98:	7402                	ld	s0,32(sp)
 a9a:	6165                	addi	sp,sp,112
 a9c:	8082                	ret

0000000000000a9e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a9e:	7179                	addi	sp,sp,-48
 aa0:	f422                	sd	s0,40(sp)
 aa2:	1800                	addi	s0,sp,48
 aa4:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aa8:	fd843783          	ld	a5,-40(s0)
 aac:	17c1                	addi	a5,a5,-16
 aae:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab2:	00000797          	auipc	a5,0x0
 ab6:	57e78793          	addi	a5,a5,1406 # 1030 <freep>
 aba:	639c                	ld	a5,0(a5)
 abc:	fef43423          	sd	a5,-24(s0)
 ac0:	a815                	j	af4 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ac2:	fe843783          	ld	a5,-24(s0)
 ac6:	639c                	ld	a5,0(a5)
 ac8:	fe843703          	ld	a4,-24(s0)
 acc:	00f76f63          	bltu	a4,a5,aea <free+0x4c>
 ad0:	fe043703          	ld	a4,-32(s0)
 ad4:	fe843783          	ld	a5,-24(s0)
 ad8:	02e7eb63          	bltu	a5,a4,b0e <free+0x70>
 adc:	fe843783          	ld	a5,-24(s0)
 ae0:	639c                	ld	a5,0(a5)
 ae2:	fe043703          	ld	a4,-32(s0)
 ae6:	02f76463          	bltu	a4,a5,b0e <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aea:	fe843783          	ld	a5,-24(s0)
 aee:	639c                	ld	a5,0(a5)
 af0:	fef43423          	sd	a5,-24(s0)
 af4:	fe043703          	ld	a4,-32(s0)
 af8:	fe843783          	ld	a5,-24(s0)
 afc:	fce7f3e3          	bgeu	a5,a4,ac2 <free+0x24>
 b00:	fe843783          	ld	a5,-24(s0)
 b04:	639c                	ld	a5,0(a5)
 b06:	fe043703          	ld	a4,-32(s0)
 b0a:	faf77ce3          	bgeu	a4,a5,ac2 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b0e:	fe043783          	ld	a5,-32(s0)
 b12:	479c                	lw	a5,8(a5)
 b14:	1782                	slli	a5,a5,0x20
 b16:	9381                	srli	a5,a5,0x20
 b18:	0792                	slli	a5,a5,0x4
 b1a:	fe043703          	ld	a4,-32(s0)
 b1e:	973e                	add	a4,a4,a5
 b20:	fe843783          	ld	a5,-24(s0)
 b24:	639c                	ld	a5,0(a5)
 b26:	02f71763          	bne	a4,a5,b54 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 b2a:	fe043783          	ld	a5,-32(s0)
 b2e:	4798                	lw	a4,8(a5)
 b30:	fe843783          	ld	a5,-24(s0)
 b34:	639c                	ld	a5,0(a5)
 b36:	479c                	lw	a5,8(a5)
 b38:	9fb9                	addw	a5,a5,a4
 b3a:	0007871b          	sext.w	a4,a5
 b3e:	fe043783          	ld	a5,-32(s0)
 b42:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 b44:	fe843783          	ld	a5,-24(s0)
 b48:	639c                	ld	a5,0(a5)
 b4a:	6398                	ld	a4,0(a5)
 b4c:	fe043783          	ld	a5,-32(s0)
 b50:	e398                	sd	a4,0(a5)
 b52:	a039                	j	b60 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 b54:	fe843783          	ld	a5,-24(s0)
 b58:	6398                	ld	a4,0(a5)
 b5a:	fe043783          	ld	a5,-32(s0)
 b5e:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 b60:	fe843783          	ld	a5,-24(s0)
 b64:	479c                	lw	a5,8(a5)
 b66:	1782                	slli	a5,a5,0x20
 b68:	9381                	srli	a5,a5,0x20
 b6a:	0792                	slli	a5,a5,0x4
 b6c:	fe843703          	ld	a4,-24(s0)
 b70:	97ba                	add	a5,a5,a4
 b72:	fe043703          	ld	a4,-32(s0)
 b76:	02f71563          	bne	a4,a5,ba0 <free+0x102>
    p->s.size += bp->s.size;
 b7a:	fe843783          	ld	a5,-24(s0)
 b7e:	4798                	lw	a4,8(a5)
 b80:	fe043783          	ld	a5,-32(s0)
 b84:	479c                	lw	a5,8(a5)
 b86:	9fb9                	addw	a5,a5,a4
 b88:	0007871b          	sext.w	a4,a5
 b8c:	fe843783          	ld	a5,-24(s0)
 b90:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b92:	fe043783          	ld	a5,-32(s0)
 b96:	6398                	ld	a4,0(a5)
 b98:	fe843783          	ld	a5,-24(s0)
 b9c:	e398                	sd	a4,0(a5)
 b9e:	a031                	j	baa <free+0x10c>
  } else
    p->s.ptr = bp;
 ba0:	fe843783          	ld	a5,-24(s0)
 ba4:	fe043703          	ld	a4,-32(s0)
 ba8:	e398                	sd	a4,0(a5)
  freep = p;
 baa:	00000797          	auipc	a5,0x0
 bae:	48678793          	addi	a5,a5,1158 # 1030 <freep>
 bb2:	fe843703          	ld	a4,-24(s0)
 bb6:	e398                	sd	a4,0(a5)
}
 bb8:	0001                	nop
 bba:	7422                	ld	s0,40(sp)
 bbc:	6145                	addi	sp,sp,48
 bbe:	8082                	ret

0000000000000bc0 <morecore>:

static Header*
morecore(uint nu)
{
 bc0:	7179                	addi	sp,sp,-48
 bc2:	f406                	sd	ra,40(sp)
 bc4:	f022                	sd	s0,32(sp)
 bc6:	1800                	addi	s0,sp,48
 bc8:	87aa                	mv	a5,a0
 bca:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 bce:	fdc42783          	lw	a5,-36(s0)
 bd2:	0007871b          	sext.w	a4,a5
 bd6:	6785                	lui	a5,0x1
 bd8:	00f77563          	bgeu	a4,a5,be2 <morecore+0x22>
    nu = 4096;
 bdc:	6785                	lui	a5,0x1
 bde:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 be2:	fdc42783          	lw	a5,-36(s0)
 be6:	0047979b          	slliw	a5,a5,0x4
 bea:	2781                	sext.w	a5,a5
 bec:	2781                	sext.w	a5,a5
 bee:	853e                	mv	a0,a5
 bf0:	00000097          	auipc	ra,0x0
 bf4:	99e080e7          	jalr	-1634(ra) # 58e <sbrk>
 bf8:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 bfc:	fe843703          	ld	a4,-24(s0)
 c00:	57fd                	li	a5,-1
 c02:	00f71463          	bne	a4,a5,c0a <morecore+0x4a>
    return 0;
 c06:	4781                	li	a5,0
 c08:	a03d                	j	c36 <morecore+0x76>
  hp = (Header*)p;
 c0a:	fe843783          	ld	a5,-24(s0)
 c0e:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 c12:	fe043783          	ld	a5,-32(s0)
 c16:	fdc42703          	lw	a4,-36(s0)
 c1a:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 c1c:	fe043783          	ld	a5,-32(s0)
 c20:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 c22:	853e                	mv	a0,a5
 c24:	00000097          	auipc	ra,0x0
 c28:	e7a080e7          	jalr	-390(ra) # a9e <free>
  return freep;
 c2c:	00000797          	auipc	a5,0x0
 c30:	40478793          	addi	a5,a5,1028 # 1030 <freep>
 c34:	639c                	ld	a5,0(a5)
}
 c36:	853e                	mv	a0,a5
 c38:	70a2                	ld	ra,40(sp)
 c3a:	7402                	ld	s0,32(sp)
 c3c:	6145                	addi	sp,sp,48
 c3e:	8082                	ret

0000000000000c40 <malloc>:

void*
malloc(uint nbytes)
{
 c40:	7139                	addi	sp,sp,-64
 c42:	fc06                	sd	ra,56(sp)
 c44:	f822                	sd	s0,48(sp)
 c46:	0080                	addi	s0,sp,64
 c48:	87aa                	mv	a5,a0
 c4a:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c4e:	fcc46783          	lwu	a5,-52(s0)
 c52:	07bd                	addi	a5,a5,15
 c54:	8391                	srli	a5,a5,0x4
 c56:	2781                	sext.w	a5,a5
 c58:	2785                	addiw	a5,a5,1
 c5a:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 c5e:	00000797          	auipc	a5,0x0
 c62:	3d278793          	addi	a5,a5,978 # 1030 <freep>
 c66:	639c                	ld	a5,0(a5)
 c68:	fef43023          	sd	a5,-32(s0)
 c6c:	fe043783          	ld	a5,-32(s0)
 c70:	ef95                	bnez	a5,cac <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 c72:	00000797          	auipc	a5,0x0
 c76:	3ae78793          	addi	a5,a5,942 # 1020 <base>
 c7a:	fef43023          	sd	a5,-32(s0)
 c7e:	00000797          	auipc	a5,0x0
 c82:	3b278793          	addi	a5,a5,946 # 1030 <freep>
 c86:	fe043703          	ld	a4,-32(s0)
 c8a:	e398                	sd	a4,0(a5)
 c8c:	00000797          	auipc	a5,0x0
 c90:	3a478793          	addi	a5,a5,932 # 1030 <freep>
 c94:	6398                	ld	a4,0(a5)
 c96:	00000797          	auipc	a5,0x0
 c9a:	38a78793          	addi	a5,a5,906 # 1020 <base>
 c9e:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 ca0:	00000797          	auipc	a5,0x0
 ca4:	38078793          	addi	a5,a5,896 # 1020 <base>
 ca8:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cac:	fe043783          	ld	a5,-32(s0)
 cb0:	639c                	ld	a5,0(a5)
 cb2:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 cb6:	fe843783          	ld	a5,-24(s0)
 cba:	4798                	lw	a4,8(a5)
 cbc:	fdc42783          	lw	a5,-36(s0)
 cc0:	2781                	sext.w	a5,a5
 cc2:	06f76763          	bltu	a4,a5,d30 <malloc+0xf0>
      if(p->s.size == nunits)
 cc6:	fe843783          	ld	a5,-24(s0)
 cca:	4798                	lw	a4,8(a5)
 ccc:	fdc42783          	lw	a5,-36(s0)
 cd0:	2781                	sext.w	a5,a5
 cd2:	00e79963          	bne	a5,a4,ce4 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 cd6:	fe843783          	ld	a5,-24(s0)
 cda:	6398                	ld	a4,0(a5)
 cdc:	fe043783          	ld	a5,-32(s0)
 ce0:	e398                	sd	a4,0(a5)
 ce2:	a825                	j	d1a <malloc+0xda>
      else {
        p->s.size -= nunits;
 ce4:	fe843783          	ld	a5,-24(s0)
 ce8:	479c                	lw	a5,8(a5)
 cea:	fdc42703          	lw	a4,-36(s0)
 cee:	9f99                	subw	a5,a5,a4
 cf0:	0007871b          	sext.w	a4,a5
 cf4:	fe843783          	ld	a5,-24(s0)
 cf8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cfa:	fe843783          	ld	a5,-24(s0)
 cfe:	479c                	lw	a5,8(a5)
 d00:	1782                	slli	a5,a5,0x20
 d02:	9381                	srli	a5,a5,0x20
 d04:	0792                	slli	a5,a5,0x4
 d06:	fe843703          	ld	a4,-24(s0)
 d0a:	97ba                	add	a5,a5,a4
 d0c:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 d10:	fe843783          	ld	a5,-24(s0)
 d14:	fdc42703          	lw	a4,-36(s0)
 d18:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 d1a:	00000797          	auipc	a5,0x0
 d1e:	31678793          	addi	a5,a5,790 # 1030 <freep>
 d22:	fe043703          	ld	a4,-32(s0)
 d26:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 d28:	fe843783          	ld	a5,-24(s0)
 d2c:	07c1                	addi	a5,a5,16
 d2e:	a091                	j	d72 <malloc+0x132>
    }
    if(p == freep)
 d30:	00000797          	auipc	a5,0x0
 d34:	30078793          	addi	a5,a5,768 # 1030 <freep>
 d38:	639c                	ld	a5,0(a5)
 d3a:	fe843703          	ld	a4,-24(s0)
 d3e:	02f71063          	bne	a4,a5,d5e <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 d42:	fdc42783          	lw	a5,-36(s0)
 d46:	853e                	mv	a0,a5
 d48:	00000097          	auipc	ra,0x0
 d4c:	e78080e7          	jalr	-392(ra) # bc0 <morecore>
 d50:	fea43423          	sd	a0,-24(s0)
 d54:	fe843783          	ld	a5,-24(s0)
 d58:	e399                	bnez	a5,d5e <malloc+0x11e>
        return 0;
 d5a:	4781                	li	a5,0
 d5c:	a819                	j	d72 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d5e:	fe843783          	ld	a5,-24(s0)
 d62:	fef43023          	sd	a5,-32(s0)
 d66:	fe843783          	ld	a5,-24(s0)
 d6a:	639c                	ld	a5,0(a5)
 d6c:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 d70:	b799                	j	cb6 <malloc+0x76>
  }
}
 d72:	853e                	mv	a0,a5
 d74:	70e2                	ld	ra,56(sp)
 d76:	7442                	ld	s0,48(sp)
 d78:	6121                	addi	sp,sp,64
 d7a:	8082                	ret
