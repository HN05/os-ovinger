
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
   a:	87aa                	mv	a5,a0
   c:	fcb43023          	sd	a1,-64(s0)
  10:	fcf42623          	sw	a5,-52(s0)
  int i;

  for(i = 1; i < argc; i++){
  14:	4785                	li	a5,1
  16:	fcf42e23          	sw	a5,-36(s0)
  1a:	a051                	j	9e <main+0x9e>
    write(1, argv[i], strlen(argv[i]));
  1c:	fdc42783          	lw	a5,-36(s0)
  20:	078e                	slli	a5,a5,0x3
  22:	fc043703          	ld	a4,-64(s0)
  26:	97ba                	add	a5,a5,a4
  28:	6384                	ld	s1,0(a5)
  2a:	fdc42783          	lw	a5,-36(s0)
  2e:	078e                	slli	a5,a5,0x3
  30:	fc043703          	ld	a4,-64(s0)
  34:	97ba                	add	a5,a5,a4
  36:	639c                	ld	a5,0(a5)
  38:	853e                	mv	a0,a5
  3a:	00000097          	auipc	ra,0x0
  3e:	14a080e7          	jalr	330(ra) # 184 <strlen>
  42:	87aa                	mv	a5,a0
  44:	2781                	sext.w	a5,a5
  46:	2781                	sext.w	a5,a5
  48:	863e                	mv	a2,a5
  4a:	85a6                	mv	a1,s1
  4c:	4505                	li	a0,1
  4e:	00000097          	auipc	ra,0x0
  52:	538080e7          	jalr	1336(ra) # 586 <write>
    if(i + 1 < argc){
  56:	fdc42783          	lw	a5,-36(s0)
  5a:	2785                	addiw	a5,a5,1
  5c:	0007871b          	sext.w	a4,a5
  60:	fcc42783          	lw	a5,-52(s0)
  64:	2781                	sext.w	a5,a5
  66:	00f75d63          	bge	a4,a5,80 <main+0x80>
      write(1, " ", 1);
  6a:	4605                	li	a2,1
  6c:	00001597          	auipc	a1,0x1
  70:	d7458593          	addi	a1,a1,-652 # de0 <malloc+0x140>
  74:	4505                	li	a0,1
  76:	00000097          	auipc	ra,0x0
  7a:	510080e7          	jalr	1296(ra) # 586 <write>
  7e:	a819                	j	94 <main+0x94>
    } else {
      write(1, "\n", 1);
  80:	4605                	li	a2,1
  82:	00001597          	auipc	a1,0x1
  86:	d6658593          	addi	a1,a1,-666 # de8 <malloc+0x148>
  8a:	4505                	li	a0,1
  8c:	00000097          	auipc	ra,0x0
  90:	4fa080e7          	jalr	1274(ra) # 586 <write>
  for(i = 1; i < argc; i++){
  94:	fdc42783          	lw	a5,-36(s0)
  98:	2785                	addiw	a5,a5,1
  9a:	fcf42e23          	sw	a5,-36(s0)
  9e:	fdc42783          	lw	a5,-36(s0)
  a2:	873e                	mv	a4,a5
  a4:	fcc42783          	lw	a5,-52(s0)
  a8:	2701                	sext.w	a4,a4
  aa:	2781                	sext.w	a5,a5
  ac:	f6f748e3          	blt	a4,a5,1c <main+0x1c>
    }
  }
  exit(0);
  b0:	4501                	li	a0,0
  b2:	00000097          	auipc	ra,0x0
  b6:	4b4080e7          	jalr	1204(ra) # 566 <exit>

00000000000000ba <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e406                	sd	ra,8(sp)
  be:	e022                	sd	s0,0(sp)
  c0:	0800                	addi	s0,sp,16
  extern int main();
  main();
  c2:	00000097          	auipc	ra,0x0
  c6:	f3e080e7          	jalr	-194(ra) # 0 <main>
  exit(0);
  ca:	4501                	li	a0,0
  cc:	00000097          	auipc	ra,0x0
  d0:	49a080e7          	jalr	1178(ra) # 566 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	7179                	addi	sp,sp,-48
  d6:	f422                	sd	s0,40(sp)
  d8:	1800                	addi	s0,sp,48
  da:	fca43c23          	sd	a0,-40(s0)
  de:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  e2:	fd843783          	ld	a5,-40(s0)
  e6:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  ea:	0001                	nop
  ec:	fd043703          	ld	a4,-48(s0)
  f0:	00170793          	addi	a5,a4,1
  f4:	fcf43823          	sd	a5,-48(s0)
  f8:	fd843783          	ld	a5,-40(s0)
  fc:	00178693          	addi	a3,a5,1
 100:	fcd43c23          	sd	a3,-40(s0)
 104:	00074703          	lbu	a4,0(a4)
 108:	00e78023          	sb	a4,0(a5)
 10c:	0007c783          	lbu	a5,0(a5)
 110:	fff1                	bnez	a5,ec <strcpy+0x18>
    ;
  return os;
 112:	fe843783          	ld	a5,-24(s0)
}
 116:	853e                	mv	a0,a5
 118:	7422                	ld	s0,40(sp)
 11a:	6145                	addi	sp,sp,48
 11c:	8082                	ret

000000000000011e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11e:	1101                	addi	sp,sp,-32
 120:	ec22                	sd	s0,24(sp)
 122:	1000                	addi	s0,sp,32
 124:	fea43423          	sd	a0,-24(s0)
 128:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 12c:	a819                	j	142 <strcmp+0x24>
    p++, q++;
 12e:	fe843783          	ld	a5,-24(s0)
 132:	0785                	addi	a5,a5,1
 134:	fef43423          	sd	a5,-24(s0)
 138:	fe043783          	ld	a5,-32(s0)
 13c:	0785                	addi	a5,a5,1
 13e:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 142:	fe843783          	ld	a5,-24(s0)
 146:	0007c783          	lbu	a5,0(a5)
 14a:	cb99                	beqz	a5,160 <strcmp+0x42>
 14c:	fe843783          	ld	a5,-24(s0)
 150:	0007c703          	lbu	a4,0(a5)
 154:	fe043783          	ld	a5,-32(s0)
 158:	0007c783          	lbu	a5,0(a5)
 15c:	fcf709e3          	beq	a4,a5,12e <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 160:	fe843783          	ld	a5,-24(s0)
 164:	0007c783          	lbu	a5,0(a5)
 168:	0007871b          	sext.w	a4,a5
 16c:	fe043783          	ld	a5,-32(s0)
 170:	0007c783          	lbu	a5,0(a5)
 174:	2781                	sext.w	a5,a5
 176:	40f707bb          	subw	a5,a4,a5
 17a:	2781                	sext.w	a5,a5
}
 17c:	853e                	mv	a0,a5
 17e:	6462                	ld	s0,24(sp)
 180:	6105                	addi	sp,sp,32
 182:	8082                	ret

0000000000000184 <strlen>:

uint
strlen(const char *s)
{
 184:	7179                	addi	sp,sp,-48
 186:	f422                	sd	s0,40(sp)
 188:	1800                	addi	s0,sp,48
 18a:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 18e:	fe042623          	sw	zero,-20(s0)
 192:	a031                	j	19e <strlen+0x1a>
 194:	fec42783          	lw	a5,-20(s0)
 198:	2785                	addiw	a5,a5,1
 19a:	fef42623          	sw	a5,-20(s0)
 19e:	fec42783          	lw	a5,-20(s0)
 1a2:	fd843703          	ld	a4,-40(s0)
 1a6:	97ba                	add	a5,a5,a4
 1a8:	0007c783          	lbu	a5,0(a5)
 1ac:	f7e5                	bnez	a5,194 <strlen+0x10>
    ;
  return n;
 1ae:	fec42783          	lw	a5,-20(s0)
}
 1b2:	853e                	mv	a0,a5
 1b4:	7422                	ld	s0,40(sp)
 1b6:	6145                	addi	sp,sp,48
 1b8:	8082                	ret

00000000000001ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ba:	7179                	addi	sp,sp,-48
 1bc:	f422                	sd	s0,40(sp)
 1be:	1800                	addi	s0,sp,48
 1c0:	fca43c23          	sd	a0,-40(s0)
 1c4:	87ae                	mv	a5,a1
 1c6:	8732                	mv	a4,a2
 1c8:	fcf42a23          	sw	a5,-44(s0)
 1cc:	87ba                	mv	a5,a4
 1ce:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 1d2:	fd843783          	ld	a5,-40(s0)
 1d6:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 1da:	fe042623          	sw	zero,-20(s0)
 1de:	a00d                	j	200 <memset+0x46>
    cdst[i] = c;
 1e0:	fec42783          	lw	a5,-20(s0)
 1e4:	fe043703          	ld	a4,-32(s0)
 1e8:	97ba                	add	a5,a5,a4
 1ea:	fd442703          	lw	a4,-44(s0)
 1ee:	0ff77713          	zext.b	a4,a4
 1f2:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 1f6:	fec42783          	lw	a5,-20(s0)
 1fa:	2785                	addiw	a5,a5,1
 1fc:	fef42623          	sw	a5,-20(s0)
 200:	fec42703          	lw	a4,-20(s0)
 204:	fd042783          	lw	a5,-48(s0)
 208:	2781                	sext.w	a5,a5
 20a:	fcf76be3          	bltu	a4,a5,1e0 <memset+0x26>
  }
  return dst;
 20e:	fd843783          	ld	a5,-40(s0)
}
 212:	853e                	mv	a0,a5
 214:	7422                	ld	s0,40(sp)
 216:	6145                	addi	sp,sp,48
 218:	8082                	ret

000000000000021a <strchr>:

char*
strchr(const char *s, char c)
{
 21a:	1101                	addi	sp,sp,-32
 21c:	ec22                	sd	s0,24(sp)
 21e:	1000                	addi	s0,sp,32
 220:	fea43423          	sd	a0,-24(s0)
 224:	87ae                	mv	a5,a1
 226:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 22a:	a01d                	j	250 <strchr+0x36>
    if(*s == c)
 22c:	fe843783          	ld	a5,-24(s0)
 230:	0007c703          	lbu	a4,0(a5)
 234:	fe744783          	lbu	a5,-25(s0)
 238:	0ff7f793          	zext.b	a5,a5
 23c:	00e79563          	bne	a5,a4,246 <strchr+0x2c>
      return (char*)s;
 240:	fe843783          	ld	a5,-24(s0)
 244:	a821                	j	25c <strchr+0x42>
  for(; *s; s++)
 246:	fe843783          	ld	a5,-24(s0)
 24a:	0785                	addi	a5,a5,1
 24c:	fef43423          	sd	a5,-24(s0)
 250:	fe843783          	ld	a5,-24(s0)
 254:	0007c783          	lbu	a5,0(a5)
 258:	fbf1                	bnez	a5,22c <strchr+0x12>
  return 0;
 25a:	4781                	li	a5,0
}
 25c:	853e                	mv	a0,a5
 25e:	6462                	ld	s0,24(sp)
 260:	6105                	addi	sp,sp,32
 262:	8082                	ret

0000000000000264 <gets>:

char*
gets(char *buf, int max)
{
 264:	7179                	addi	sp,sp,-48
 266:	f406                	sd	ra,40(sp)
 268:	f022                	sd	s0,32(sp)
 26a:	1800                	addi	s0,sp,48
 26c:	fca43c23          	sd	a0,-40(s0)
 270:	87ae                	mv	a5,a1
 272:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 276:	fe042623          	sw	zero,-20(s0)
 27a:	a8a1                	j	2d2 <gets+0x6e>
    cc = read(0, &c, 1);
 27c:	fe740793          	addi	a5,s0,-25
 280:	4605                	li	a2,1
 282:	85be                	mv	a1,a5
 284:	4501                	li	a0,0
 286:	00000097          	auipc	ra,0x0
 28a:	2f8080e7          	jalr	760(ra) # 57e <read>
 28e:	87aa                	mv	a5,a0
 290:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 294:	fe842783          	lw	a5,-24(s0)
 298:	2781                	sext.w	a5,a5
 29a:	04f05763          	blez	a5,2e8 <gets+0x84>
      break;
    buf[i++] = c;
 29e:	fec42783          	lw	a5,-20(s0)
 2a2:	0017871b          	addiw	a4,a5,1
 2a6:	fee42623          	sw	a4,-20(s0)
 2aa:	873e                	mv	a4,a5
 2ac:	fd843783          	ld	a5,-40(s0)
 2b0:	97ba                	add	a5,a5,a4
 2b2:	fe744703          	lbu	a4,-25(s0)
 2b6:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 2ba:	fe744783          	lbu	a5,-25(s0)
 2be:	873e                	mv	a4,a5
 2c0:	47a9                	li	a5,10
 2c2:	02f70463          	beq	a4,a5,2ea <gets+0x86>
 2c6:	fe744783          	lbu	a5,-25(s0)
 2ca:	873e                	mv	a4,a5
 2cc:	47b5                	li	a5,13
 2ce:	00f70e63          	beq	a4,a5,2ea <gets+0x86>
  for(i=0; i+1 < max; ){
 2d2:	fec42783          	lw	a5,-20(s0)
 2d6:	2785                	addiw	a5,a5,1
 2d8:	0007871b          	sext.w	a4,a5
 2dc:	fd442783          	lw	a5,-44(s0)
 2e0:	2781                	sext.w	a5,a5
 2e2:	f8f74de3          	blt	a4,a5,27c <gets+0x18>
 2e6:	a011                	j	2ea <gets+0x86>
      break;
 2e8:	0001                	nop
      break;
  }
  buf[i] = '\0';
 2ea:	fec42783          	lw	a5,-20(s0)
 2ee:	fd843703          	ld	a4,-40(s0)
 2f2:	97ba                	add	a5,a5,a4
 2f4:	00078023          	sb	zero,0(a5)
  return buf;
 2f8:	fd843783          	ld	a5,-40(s0)
}
 2fc:	853e                	mv	a0,a5
 2fe:	70a2                	ld	ra,40(sp)
 300:	7402                	ld	s0,32(sp)
 302:	6145                	addi	sp,sp,48
 304:	8082                	ret

0000000000000306 <stat>:

int
stat(const char *n, struct stat *st)
{
 306:	7179                	addi	sp,sp,-48
 308:	f406                	sd	ra,40(sp)
 30a:	f022                	sd	s0,32(sp)
 30c:	1800                	addi	s0,sp,48
 30e:	fca43c23          	sd	a0,-40(s0)
 312:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 316:	4581                	li	a1,0
 318:	fd843503          	ld	a0,-40(s0)
 31c:	00000097          	auipc	ra,0x0
 320:	28a080e7          	jalr	650(ra) # 5a6 <open>
 324:	87aa                	mv	a5,a0
 326:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 32a:	fec42783          	lw	a5,-20(s0)
 32e:	2781                	sext.w	a5,a5
 330:	0007d463          	bgez	a5,338 <stat+0x32>
    return -1;
 334:	57fd                	li	a5,-1
 336:	a035                	j	362 <stat+0x5c>
  r = fstat(fd, st);
 338:	fec42783          	lw	a5,-20(s0)
 33c:	fd043583          	ld	a1,-48(s0)
 340:	853e                	mv	a0,a5
 342:	00000097          	auipc	ra,0x0
 346:	27c080e7          	jalr	636(ra) # 5be <fstat>
 34a:	87aa                	mv	a5,a0
 34c:	fef42423          	sw	a5,-24(s0)
  close(fd);
 350:	fec42783          	lw	a5,-20(s0)
 354:	853e                	mv	a0,a5
 356:	00000097          	auipc	ra,0x0
 35a:	238080e7          	jalr	568(ra) # 58e <close>
  return r;
 35e:	fe842783          	lw	a5,-24(s0)
}
 362:	853e                	mv	a0,a5
 364:	70a2                	ld	ra,40(sp)
 366:	7402                	ld	s0,32(sp)
 368:	6145                	addi	sp,sp,48
 36a:	8082                	ret

000000000000036c <atoi>:

int
atoi(const char *s)
{
 36c:	7179                	addi	sp,sp,-48
 36e:	f422                	sd	s0,40(sp)
 370:	1800                	addi	s0,sp,48
 372:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 376:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 37a:	a81d                	j	3b0 <atoi+0x44>
    n = n*10 + *s++ - '0';
 37c:	fec42783          	lw	a5,-20(s0)
 380:	873e                	mv	a4,a5
 382:	87ba                	mv	a5,a4
 384:	0027979b          	slliw	a5,a5,0x2
 388:	9fb9                	addw	a5,a5,a4
 38a:	0017979b          	slliw	a5,a5,0x1
 38e:	0007871b          	sext.w	a4,a5
 392:	fd843783          	ld	a5,-40(s0)
 396:	00178693          	addi	a3,a5,1
 39a:	fcd43c23          	sd	a3,-40(s0)
 39e:	0007c783          	lbu	a5,0(a5)
 3a2:	2781                	sext.w	a5,a5
 3a4:	9fb9                	addw	a5,a5,a4
 3a6:	2781                	sext.w	a5,a5
 3a8:	fd07879b          	addiw	a5,a5,-48
 3ac:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 3b0:	fd843783          	ld	a5,-40(s0)
 3b4:	0007c783          	lbu	a5,0(a5)
 3b8:	873e                	mv	a4,a5
 3ba:	02f00793          	li	a5,47
 3be:	00e7fb63          	bgeu	a5,a4,3d4 <atoi+0x68>
 3c2:	fd843783          	ld	a5,-40(s0)
 3c6:	0007c783          	lbu	a5,0(a5)
 3ca:	873e                	mv	a4,a5
 3cc:	03900793          	li	a5,57
 3d0:	fae7f6e3          	bgeu	a5,a4,37c <atoi+0x10>
  return n;
 3d4:	fec42783          	lw	a5,-20(s0)
}
 3d8:	853e                	mv	a0,a5
 3da:	7422                	ld	s0,40(sp)
 3dc:	6145                	addi	sp,sp,48
 3de:	8082                	ret

00000000000003e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3e0:	7139                	addi	sp,sp,-64
 3e2:	fc22                	sd	s0,56(sp)
 3e4:	0080                	addi	s0,sp,64
 3e6:	fca43c23          	sd	a0,-40(s0)
 3ea:	fcb43823          	sd	a1,-48(s0)
 3ee:	87b2                	mv	a5,a2
 3f0:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 3f4:	fd843783          	ld	a5,-40(s0)
 3f8:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 3fc:	fd043783          	ld	a5,-48(s0)
 400:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 404:	fe043703          	ld	a4,-32(s0)
 408:	fe843783          	ld	a5,-24(s0)
 40c:	02e7fc63          	bgeu	a5,a4,444 <memmove+0x64>
    while(n-- > 0)
 410:	a00d                	j	432 <memmove+0x52>
      *dst++ = *src++;
 412:	fe043703          	ld	a4,-32(s0)
 416:	00170793          	addi	a5,a4,1
 41a:	fef43023          	sd	a5,-32(s0)
 41e:	fe843783          	ld	a5,-24(s0)
 422:	00178693          	addi	a3,a5,1
 426:	fed43423          	sd	a3,-24(s0)
 42a:	00074703          	lbu	a4,0(a4)
 42e:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 432:	fcc42783          	lw	a5,-52(s0)
 436:	fff7871b          	addiw	a4,a5,-1
 43a:	fce42623          	sw	a4,-52(s0)
 43e:	fcf04ae3          	bgtz	a5,412 <memmove+0x32>
 442:	a891                	j	496 <memmove+0xb6>
  } else {
    dst += n;
 444:	fcc42783          	lw	a5,-52(s0)
 448:	fe843703          	ld	a4,-24(s0)
 44c:	97ba                	add	a5,a5,a4
 44e:	fef43423          	sd	a5,-24(s0)
    src += n;
 452:	fcc42783          	lw	a5,-52(s0)
 456:	fe043703          	ld	a4,-32(s0)
 45a:	97ba                	add	a5,a5,a4
 45c:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 460:	a01d                	j	486 <memmove+0xa6>
      *--dst = *--src;
 462:	fe043783          	ld	a5,-32(s0)
 466:	17fd                	addi	a5,a5,-1
 468:	fef43023          	sd	a5,-32(s0)
 46c:	fe843783          	ld	a5,-24(s0)
 470:	17fd                	addi	a5,a5,-1
 472:	fef43423          	sd	a5,-24(s0)
 476:	fe043783          	ld	a5,-32(s0)
 47a:	0007c703          	lbu	a4,0(a5)
 47e:	fe843783          	ld	a5,-24(s0)
 482:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 486:	fcc42783          	lw	a5,-52(s0)
 48a:	fff7871b          	addiw	a4,a5,-1
 48e:	fce42623          	sw	a4,-52(s0)
 492:	fcf048e3          	bgtz	a5,462 <memmove+0x82>
  }
  return vdst;
 496:	fd843783          	ld	a5,-40(s0)
}
 49a:	853e                	mv	a0,a5
 49c:	7462                	ld	s0,56(sp)
 49e:	6121                	addi	sp,sp,64
 4a0:	8082                	ret

00000000000004a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a2:	7139                	addi	sp,sp,-64
 4a4:	fc22                	sd	s0,56(sp)
 4a6:	0080                	addi	s0,sp,64
 4a8:	fca43c23          	sd	a0,-40(s0)
 4ac:	fcb43823          	sd	a1,-48(s0)
 4b0:	87b2                	mv	a5,a2
 4b2:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 4b6:	fd843783          	ld	a5,-40(s0)
 4ba:	fef43423          	sd	a5,-24(s0)
 4be:	fd043783          	ld	a5,-48(s0)
 4c2:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 4c6:	a0a1                	j	50e <memcmp+0x6c>
    if (*p1 != *p2) {
 4c8:	fe843783          	ld	a5,-24(s0)
 4cc:	0007c703          	lbu	a4,0(a5)
 4d0:	fe043783          	ld	a5,-32(s0)
 4d4:	0007c783          	lbu	a5,0(a5)
 4d8:	02f70163          	beq	a4,a5,4fa <memcmp+0x58>
      return *p1 - *p2;
 4dc:	fe843783          	ld	a5,-24(s0)
 4e0:	0007c783          	lbu	a5,0(a5)
 4e4:	0007871b          	sext.w	a4,a5
 4e8:	fe043783          	ld	a5,-32(s0)
 4ec:	0007c783          	lbu	a5,0(a5)
 4f0:	2781                	sext.w	a5,a5
 4f2:	40f707bb          	subw	a5,a4,a5
 4f6:	2781                	sext.w	a5,a5
 4f8:	a01d                	j	51e <memcmp+0x7c>
    }
    p1++;
 4fa:	fe843783          	ld	a5,-24(s0)
 4fe:	0785                	addi	a5,a5,1
 500:	fef43423          	sd	a5,-24(s0)
    p2++;
 504:	fe043783          	ld	a5,-32(s0)
 508:	0785                	addi	a5,a5,1
 50a:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 50e:	fcc42783          	lw	a5,-52(s0)
 512:	fff7871b          	addiw	a4,a5,-1
 516:	fce42623          	sw	a4,-52(s0)
 51a:	f7dd                	bnez	a5,4c8 <memcmp+0x26>
  }
  return 0;
 51c:	4781                	li	a5,0
}
 51e:	853e                	mv	a0,a5
 520:	7462                	ld	s0,56(sp)
 522:	6121                	addi	sp,sp,64
 524:	8082                	ret

0000000000000526 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 526:	7179                	addi	sp,sp,-48
 528:	f406                	sd	ra,40(sp)
 52a:	f022                	sd	s0,32(sp)
 52c:	1800                	addi	s0,sp,48
 52e:	fea43423          	sd	a0,-24(s0)
 532:	feb43023          	sd	a1,-32(s0)
 536:	87b2                	mv	a5,a2
 538:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 53c:	fdc42783          	lw	a5,-36(s0)
 540:	863e                	mv	a2,a5
 542:	fe043583          	ld	a1,-32(s0)
 546:	fe843503          	ld	a0,-24(s0)
 54a:	00000097          	auipc	ra,0x0
 54e:	e96080e7          	jalr	-362(ra) # 3e0 <memmove>
 552:	87aa                	mv	a5,a0
}
 554:	853e                	mv	a0,a5
 556:	70a2                	ld	ra,40(sp)
 558:	7402                	ld	s0,32(sp)
 55a:	6145                	addi	sp,sp,48
 55c:	8082                	ret

000000000000055e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 55e:	4885                	li	a7,1
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <exit>:
.global exit
exit:
 li a7, SYS_exit
 566:	4889                	li	a7,2
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <wait>:
.global wait
wait:
 li a7, SYS_wait
 56e:	488d                	li	a7,3
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 576:	4891                	li	a7,4
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <read>:
.global read
read:
 li a7, SYS_read
 57e:	4895                	li	a7,5
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <write>:
.global write
write:
 li a7, SYS_write
 586:	48c1                	li	a7,16
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <close>:
.global close
close:
 li a7, SYS_close
 58e:	48d5                	li	a7,21
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <kill>:
.global kill
kill:
 li a7, SYS_kill
 596:	4899                	li	a7,6
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <exec>:
.global exec
exec:
 li a7, SYS_exec
 59e:	489d                	li	a7,7
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <open>:
.global open
open:
 li a7, SYS_open
 5a6:	48bd                	li	a7,15
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5ae:	48c5                	li	a7,17
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5b6:	48c9                	li	a7,18
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5be:	48a1                	li	a7,8
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <link>:
.global link
link:
 li a7, SYS_link
 5c6:	48cd                	li	a7,19
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ce:	48d1                	li	a7,20
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5d6:	48a5                	li	a7,9
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <dup>:
.global dup
dup:
 li a7, SYS_dup
 5de:	48a9                	li	a7,10
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5e6:	48ad                	li	a7,11
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5ee:	48b1                	li	a7,12
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5f6:	48b5                	li	a7,13
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5fe:	48b9                	li	a7,14
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <hello>:
.global hello
hello:
 li a7, SYS_hello
 606:	48d9                	li	a7,22
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <ps>:
.global ps
ps:
 li a7, SYS_ps
 60e:	48e1                	li	a7,24
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 616:	48dd                	li	a7,23
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 61e:	48e5                	li	a7,25
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 626:	1101                	addi	sp,sp,-32
 628:	ec06                	sd	ra,24(sp)
 62a:	e822                	sd	s0,16(sp)
 62c:	1000                	addi	s0,sp,32
 62e:	87aa                	mv	a5,a0
 630:	872e                	mv	a4,a1
 632:	fef42623          	sw	a5,-20(s0)
 636:	87ba                	mv	a5,a4
 638:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 63c:	feb40713          	addi	a4,s0,-21
 640:	fec42783          	lw	a5,-20(s0)
 644:	4605                	li	a2,1
 646:	85ba                	mv	a1,a4
 648:	853e                	mv	a0,a5
 64a:	00000097          	auipc	ra,0x0
 64e:	f3c080e7          	jalr	-196(ra) # 586 <write>
}
 652:	0001                	nop
 654:	60e2                	ld	ra,24(sp)
 656:	6442                	ld	s0,16(sp)
 658:	6105                	addi	sp,sp,32
 65a:	8082                	ret

000000000000065c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 65c:	7139                	addi	sp,sp,-64
 65e:	fc06                	sd	ra,56(sp)
 660:	f822                	sd	s0,48(sp)
 662:	0080                	addi	s0,sp,64
 664:	87aa                	mv	a5,a0
 666:	8736                	mv	a4,a3
 668:	fcf42623          	sw	a5,-52(s0)
 66c:	87ae                	mv	a5,a1
 66e:	fcf42423          	sw	a5,-56(s0)
 672:	87b2                	mv	a5,a2
 674:	fcf42223          	sw	a5,-60(s0)
 678:	87ba                	mv	a5,a4
 67a:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 67e:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 682:	fc042783          	lw	a5,-64(s0)
 686:	2781                	sext.w	a5,a5
 688:	c38d                	beqz	a5,6aa <printint+0x4e>
 68a:	fc842783          	lw	a5,-56(s0)
 68e:	2781                	sext.w	a5,a5
 690:	0007dd63          	bgez	a5,6aa <printint+0x4e>
    neg = 1;
 694:	4785                	li	a5,1
 696:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 69a:	fc842783          	lw	a5,-56(s0)
 69e:	40f007bb          	negw	a5,a5
 6a2:	2781                	sext.w	a5,a5
 6a4:	fef42223          	sw	a5,-28(s0)
 6a8:	a029                	j	6b2 <printint+0x56>
  } else {
    x = xx;
 6aa:	fc842783          	lw	a5,-56(s0)
 6ae:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 6b2:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 6b6:	fc442783          	lw	a5,-60(s0)
 6ba:	fe442703          	lw	a4,-28(s0)
 6be:	02f777bb          	remuw	a5,a4,a5
 6c2:	0007861b          	sext.w	a2,a5
 6c6:	fec42783          	lw	a5,-20(s0)
 6ca:	0017871b          	addiw	a4,a5,1
 6ce:	fee42623          	sw	a4,-20(s0)
 6d2:	00001697          	auipc	a3,0x1
 6d6:	92e68693          	addi	a3,a3,-1746 # 1000 <digits>
 6da:	02061713          	slli	a4,a2,0x20
 6de:	9301                	srli	a4,a4,0x20
 6e0:	9736                	add	a4,a4,a3
 6e2:	00074703          	lbu	a4,0(a4)
 6e6:	17c1                	addi	a5,a5,-16
 6e8:	97a2                	add	a5,a5,s0
 6ea:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 6ee:	fc442783          	lw	a5,-60(s0)
 6f2:	fe442703          	lw	a4,-28(s0)
 6f6:	02f757bb          	divuw	a5,a4,a5
 6fa:	fef42223          	sw	a5,-28(s0)
 6fe:	fe442783          	lw	a5,-28(s0)
 702:	2781                	sext.w	a5,a5
 704:	fbcd                	bnez	a5,6b6 <printint+0x5a>
  if(neg)
 706:	fe842783          	lw	a5,-24(s0)
 70a:	2781                	sext.w	a5,a5
 70c:	cf85                	beqz	a5,744 <printint+0xe8>
    buf[i++] = '-';
 70e:	fec42783          	lw	a5,-20(s0)
 712:	0017871b          	addiw	a4,a5,1
 716:	fee42623          	sw	a4,-20(s0)
 71a:	17c1                	addi	a5,a5,-16
 71c:	97a2                	add	a5,a5,s0
 71e:	02d00713          	li	a4,45
 722:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 726:	a839                	j	744 <printint+0xe8>
    putc(fd, buf[i]);
 728:	fec42783          	lw	a5,-20(s0)
 72c:	17c1                	addi	a5,a5,-16
 72e:	97a2                	add	a5,a5,s0
 730:	fe07c703          	lbu	a4,-32(a5)
 734:	fcc42783          	lw	a5,-52(s0)
 738:	85ba                	mv	a1,a4
 73a:	853e                	mv	a0,a5
 73c:	00000097          	auipc	ra,0x0
 740:	eea080e7          	jalr	-278(ra) # 626 <putc>
  while(--i >= 0)
 744:	fec42783          	lw	a5,-20(s0)
 748:	37fd                	addiw	a5,a5,-1
 74a:	fef42623          	sw	a5,-20(s0)
 74e:	fec42783          	lw	a5,-20(s0)
 752:	2781                	sext.w	a5,a5
 754:	fc07dae3          	bgez	a5,728 <printint+0xcc>
}
 758:	0001                	nop
 75a:	0001                	nop
 75c:	70e2                	ld	ra,56(sp)
 75e:	7442                	ld	s0,48(sp)
 760:	6121                	addi	sp,sp,64
 762:	8082                	ret

0000000000000764 <printptr>:

static void
printptr(int fd, uint64 x) {
 764:	7179                	addi	sp,sp,-48
 766:	f406                	sd	ra,40(sp)
 768:	f022                	sd	s0,32(sp)
 76a:	1800                	addi	s0,sp,48
 76c:	87aa                	mv	a5,a0
 76e:	fcb43823          	sd	a1,-48(s0)
 772:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 776:	fdc42783          	lw	a5,-36(s0)
 77a:	03000593          	li	a1,48
 77e:	853e                	mv	a0,a5
 780:	00000097          	auipc	ra,0x0
 784:	ea6080e7          	jalr	-346(ra) # 626 <putc>
  putc(fd, 'x');
 788:	fdc42783          	lw	a5,-36(s0)
 78c:	07800593          	li	a1,120
 790:	853e                	mv	a0,a5
 792:	00000097          	auipc	ra,0x0
 796:	e94080e7          	jalr	-364(ra) # 626 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79a:	fe042623          	sw	zero,-20(s0)
 79e:	a82d                	j	7d8 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a0:	fd043783          	ld	a5,-48(s0)
 7a4:	93f1                	srli	a5,a5,0x3c
 7a6:	00001717          	auipc	a4,0x1
 7aa:	85a70713          	addi	a4,a4,-1958 # 1000 <digits>
 7ae:	97ba                	add	a5,a5,a4
 7b0:	0007c703          	lbu	a4,0(a5)
 7b4:	fdc42783          	lw	a5,-36(s0)
 7b8:	85ba                	mv	a1,a4
 7ba:	853e                	mv	a0,a5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e6a080e7          	jalr	-406(ra) # 626 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7c4:	fec42783          	lw	a5,-20(s0)
 7c8:	2785                	addiw	a5,a5,1
 7ca:	fef42623          	sw	a5,-20(s0)
 7ce:	fd043783          	ld	a5,-48(s0)
 7d2:	0792                	slli	a5,a5,0x4
 7d4:	fcf43823          	sd	a5,-48(s0)
 7d8:	fec42783          	lw	a5,-20(s0)
 7dc:	873e                	mv	a4,a5
 7de:	47bd                	li	a5,15
 7e0:	fce7f0e3          	bgeu	a5,a4,7a0 <printptr+0x3c>
}
 7e4:	0001                	nop
 7e6:	0001                	nop
 7e8:	70a2                	ld	ra,40(sp)
 7ea:	7402                	ld	s0,32(sp)
 7ec:	6145                	addi	sp,sp,48
 7ee:	8082                	ret

00000000000007f0 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7f0:	715d                	addi	sp,sp,-80
 7f2:	e486                	sd	ra,72(sp)
 7f4:	e0a2                	sd	s0,64(sp)
 7f6:	0880                	addi	s0,sp,80
 7f8:	87aa                	mv	a5,a0
 7fa:	fcb43023          	sd	a1,-64(s0)
 7fe:	fac43c23          	sd	a2,-72(s0)
 802:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 806:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 80a:	fe042223          	sw	zero,-28(s0)
 80e:	a42d                	j	a38 <vprintf+0x248>
    c = fmt[i] & 0xff;
 810:	fe442783          	lw	a5,-28(s0)
 814:	fc043703          	ld	a4,-64(s0)
 818:	97ba                	add	a5,a5,a4
 81a:	0007c783          	lbu	a5,0(a5)
 81e:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 822:	fe042783          	lw	a5,-32(s0)
 826:	2781                	sext.w	a5,a5
 828:	eb9d                	bnez	a5,85e <vprintf+0x6e>
      if(c == '%'){
 82a:	fdc42783          	lw	a5,-36(s0)
 82e:	0007871b          	sext.w	a4,a5
 832:	02500793          	li	a5,37
 836:	00f71763          	bne	a4,a5,844 <vprintf+0x54>
        state = '%';
 83a:	02500793          	li	a5,37
 83e:	fef42023          	sw	a5,-32(s0)
 842:	a2f5                	j	a2e <vprintf+0x23e>
      } else {
        putc(fd, c);
 844:	fdc42783          	lw	a5,-36(s0)
 848:	0ff7f713          	zext.b	a4,a5
 84c:	fcc42783          	lw	a5,-52(s0)
 850:	85ba                	mv	a1,a4
 852:	853e                	mv	a0,a5
 854:	00000097          	auipc	ra,0x0
 858:	dd2080e7          	jalr	-558(ra) # 626 <putc>
 85c:	aac9                	j	a2e <vprintf+0x23e>
      }
    } else if(state == '%'){
 85e:	fe042783          	lw	a5,-32(s0)
 862:	0007871b          	sext.w	a4,a5
 866:	02500793          	li	a5,37
 86a:	1cf71263          	bne	a4,a5,a2e <vprintf+0x23e>
      if(c == 'd'){
 86e:	fdc42783          	lw	a5,-36(s0)
 872:	0007871b          	sext.w	a4,a5
 876:	06400793          	li	a5,100
 87a:	02f71463          	bne	a4,a5,8a2 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 87e:	fb843783          	ld	a5,-72(s0)
 882:	00878713          	addi	a4,a5,8
 886:	fae43c23          	sd	a4,-72(s0)
 88a:	4398                	lw	a4,0(a5)
 88c:	fcc42783          	lw	a5,-52(s0)
 890:	4685                	li	a3,1
 892:	4629                	li	a2,10
 894:	85ba                	mv	a1,a4
 896:	853e                	mv	a0,a5
 898:	00000097          	auipc	ra,0x0
 89c:	dc4080e7          	jalr	-572(ra) # 65c <printint>
 8a0:	a269                	j	a2a <vprintf+0x23a>
      } else if(c == 'l') {
 8a2:	fdc42783          	lw	a5,-36(s0)
 8a6:	0007871b          	sext.w	a4,a5
 8aa:	06c00793          	li	a5,108
 8ae:	02f71663          	bne	a4,a5,8da <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b2:	fb843783          	ld	a5,-72(s0)
 8b6:	00878713          	addi	a4,a5,8
 8ba:	fae43c23          	sd	a4,-72(s0)
 8be:	639c                	ld	a5,0(a5)
 8c0:	0007871b          	sext.w	a4,a5
 8c4:	fcc42783          	lw	a5,-52(s0)
 8c8:	4681                	li	a3,0
 8ca:	4629                	li	a2,10
 8cc:	85ba                	mv	a1,a4
 8ce:	853e                	mv	a0,a5
 8d0:	00000097          	auipc	ra,0x0
 8d4:	d8c080e7          	jalr	-628(ra) # 65c <printint>
 8d8:	aa89                	j	a2a <vprintf+0x23a>
      } else if(c == 'x') {
 8da:	fdc42783          	lw	a5,-36(s0)
 8de:	0007871b          	sext.w	a4,a5
 8e2:	07800793          	li	a5,120
 8e6:	02f71463          	bne	a4,a5,90e <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 8ea:	fb843783          	ld	a5,-72(s0)
 8ee:	00878713          	addi	a4,a5,8
 8f2:	fae43c23          	sd	a4,-72(s0)
 8f6:	4398                	lw	a4,0(a5)
 8f8:	fcc42783          	lw	a5,-52(s0)
 8fc:	4681                	li	a3,0
 8fe:	4641                	li	a2,16
 900:	85ba                	mv	a1,a4
 902:	853e                	mv	a0,a5
 904:	00000097          	auipc	ra,0x0
 908:	d58080e7          	jalr	-680(ra) # 65c <printint>
 90c:	aa39                	j	a2a <vprintf+0x23a>
      } else if(c == 'p') {
 90e:	fdc42783          	lw	a5,-36(s0)
 912:	0007871b          	sext.w	a4,a5
 916:	07000793          	li	a5,112
 91a:	02f71263          	bne	a4,a5,93e <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 91e:	fb843783          	ld	a5,-72(s0)
 922:	00878713          	addi	a4,a5,8
 926:	fae43c23          	sd	a4,-72(s0)
 92a:	6398                	ld	a4,0(a5)
 92c:	fcc42783          	lw	a5,-52(s0)
 930:	85ba                	mv	a1,a4
 932:	853e                	mv	a0,a5
 934:	00000097          	auipc	ra,0x0
 938:	e30080e7          	jalr	-464(ra) # 764 <printptr>
 93c:	a0fd                	j	a2a <vprintf+0x23a>
      } else if(c == 's'){
 93e:	fdc42783          	lw	a5,-36(s0)
 942:	0007871b          	sext.w	a4,a5
 946:	07300793          	li	a5,115
 94a:	04f71c63          	bne	a4,a5,9a2 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 94e:	fb843783          	ld	a5,-72(s0)
 952:	00878713          	addi	a4,a5,8
 956:	fae43c23          	sd	a4,-72(s0)
 95a:	639c                	ld	a5,0(a5)
 95c:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 960:	fe843783          	ld	a5,-24(s0)
 964:	eb8d                	bnez	a5,996 <vprintf+0x1a6>
          s = "(null)";
 966:	00000797          	auipc	a5,0x0
 96a:	48a78793          	addi	a5,a5,1162 # df0 <malloc+0x150>
 96e:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 972:	a015                	j	996 <vprintf+0x1a6>
          putc(fd, *s);
 974:	fe843783          	ld	a5,-24(s0)
 978:	0007c703          	lbu	a4,0(a5)
 97c:	fcc42783          	lw	a5,-52(s0)
 980:	85ba                	mv	a1,a4
 982:	853e                	mv	a0,a5
 984:	00000097          	auipc	ra,0x0
 988:	ca2080e7          	jalr	-862(ra) # 626 <putc>
          s++;
 98c:	fe843783          	ld	a5,-24(s0)
 990:	0785                	addi	a5,a5,1
 992:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 996:	fe843783          	ld	a5,-24(s0)
 99a:	0007c783          	lbu	a5,0(a5)
 99e:	fbf9                	bnez	a5,974 <vprintf+0x184>
 9a0:	a069                	j	a2a <vprintf+0x23a>
        }
      } else if(c == 'c'){
 9a2:	fdc42783          	lw	a5,-36(s0)
 9a6:	0007871b          	sext.w	a4,a5
 9aa:	06300793          	li	a5,99
 9ae:	02f71463          	bne	a4,a5,9d6 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 9b2:	fb843783          	ld	a5,-72(s0)
 9b6:	00878713          	addi	a4,a5,8
 9ba:	fae43c23          	sd	a4,-72(s0)
 9be:	439c                	lw	a5,0(a5)
 9c0:	0ff7f713          	zext.b	a4,a5
 9c4:	fcc42783          	lw	a5,-52(s0)
 9c8:	85ba                	mv	a1,a4
 9ca:	853e                	mv	a0,a5
 9cc:	00000097          	auipc	ra,0x0
 9d0:	c5a080e7          	jalr	-934(ra) # 626 <putc>
 9d4:	a899                	j	a2a <vprintf+0x23a>
      } else if(c == '%'){
 9d6:	fdc42783          	lw	a5,-36(s0)
 9da:	0007871b          	sext.w	a4,a5
 9de:	02500793          	li	a5,37
 9e2:	00f71f63          	bne	a4,a5,a00 <vprintf+0x210>
        putc(fd, c);
 9e6:	fdc42783          	lw	a5,-36(s0)
 9ea:	0ff7f713          	zext.b	a4,a5
 9ee:	fcc42783          	lw	a5,-52(s0)
 9f2:	85ba                	mv	a1,a4
 9f4:	853e                	mv	a0,a5
 9f6:	00000097          	auipc	ra,0x0
 9fa:	c30080e7          	jalr	-976(ra) # 626 <putc>
 9fe:	a035                	j	a2a <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a00:	fcc42783          	lw	a5,-52(s0)
 a04:	02500593          	li	a1,37
 a08:	853e                	mv	a0,a5
 a0a:	00000097          	auipc	ra,0x0
 a0e:	c1c080e7          	jalr	-996(ra) # 626 <putc>
        putc(fd, c);
 a12:	fdc42783          	lw	a5,-36(s0)
 a16:	0ff7f713          	zext.b	a4,a5
 a1a:	fcc42783          	lw	a5,-52(s0)
 a1e:	85ba                	mv	a1,a4
 a20:	853e                	mv	a0,a5
 a22:	00000097          	auipc	ra,0x0
 a26:	c04080e7          	jalr	-1020(ra) # 626 <putc>
      }
      state = 0;
 a2a:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 a2e:	fe442783          	lw	a5,-28(s0)
 a32:	2785                	addiw	a5,a5,1
 a34:	fef42223          	sw	a5,-28(s0)
 a38:	fe442783          	lw	a5,-28(s0)
 a3c:	fc043703          	ld	a4,-64(s0)
 a40:	97ba                	add	a5,a5,a4
 a42:	0007c783          	lbu	a5,0(a5)
 a46:	dc0795e3          	bnez	a5,810 <vprintf+0x20>
    }
  }
}
 a4a:	0001                	nop
 a4c:	0001                	nop
 a4e:	60a6                	ld	ra,72(sp)
 a50:	6406                	ld	s0,64(sp)
 a52:	6161                	addi	sp,sp,80
 a54:	8082                	ret

0000000000000a56 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a56:	7159                	addi	sp,sp,-112
 a58:	fc06                	sd	ra,56(sp)
 a5a:	f822                	sd	s0,48(sp)
 a5c:	0080                	addi	s0,sp,64
 a5e:	fcb43823          	sd	a1,-48(s0)
 a62:	e010                	sd	a2,0(s0)
 a64:	e414                	sd	a3,8(s0)
 a66:	e818                	sd	a4,16(s0)
 a68:	ec1c                	sd	a5,24(s0)
 a6a:	03043023          	sd	a6,32(s0)
 a6e:	03143423          	sd	a7,40(s0)
 a72:	87aa                	mv	a5,a0
 a74:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 a78:	03040793          	addi	a5,s0,48
 a7c:	fcf43423          	sd	a5,-56(s0)
 a80:	fc843783          	ld	a5,-56(s0)
 a84:	fd078793          	addi	a5,a5,-48
 a88:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 a8c:	fe843703          	ld	a4,-24(s0)
 a90:	fdc42783          	lw	a5,-36(s0)
 a94:	863a                	mv	a2,a4
 a96:	fd043583          	ld	a1,-48(s0)
 a9a:	853e                	mv	a0,a5
 a9c:	00000097          	auipc	ra,0x0
 aa0:	d54080e7          	jalr	-684(ra) # 7f0 <vprintf>
}
 aa4:	0001                	nop
 aa6:	70e2                	ld	ra,56(sp)
 aa8:	7442                	ld	s0,48(sp)
 aaa:	6165                	addi	sp,sp,112
 aac:	8082                	ret

0000000000000aae <printf>:

void
printf(const char *fmt, ...)
{
 aae:	7159                	addi	sp,sp,-112
 ab0:	f406                	sd	ra,40(sp)
 ab2:	f022                	sd	s0,32(sp)
 ab4:	1800                	addi	s0,sp,48
 ab6:	fca43c23          	sd	a0,-40(s0)
 aba:	e40c                	sd	a1,8(s0)
 abc:	e810                	sd	a2,16(s0)
 abe:	ec14                	sd	a3,24(s0)
 ac0:	f018                	sd	a4,32(s0)
 ac2:	f41c                	sd	a5,40(s0)
 ac4:	03043823          	sd	a6,48(s0)
 ac8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 acc:	04040793          	addi	a5,s0,64
 ad0:	fcf43823          	sd	a5,-48(s0)
 ad4:	fd043783          	ld	a5,-48(s0)
 ad8:	fc878793          	addi	a5,a5,-56
 adc:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 ae0:	fe843783          	ld	a5,-24(s0)
 ae4:	863e                	mv	a2,a5
 ae6:	fd843583          	ld	a1,-40(s0)
 aea:	4505                	li	a0,1
 aec:	00000097          	auipc	ra,0x0
 af0:	d04080e7          	jalr	-764(ra) # 7f0 <vprintf>
}
 af4:	0001                	nop
 af6:	70a2                	ld	ra,40(sp)
 af8:	7402                	ld	s0,32(sp)
 afa:	6165                	addi	sp,sp,112
 afc:	8082                	ret

0000000000000afe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 afe:	7179                	addi	sp,sp,-48
 b00:	f422                	sd	s0,40(sp)
 b02:	1800                	addi	s0,sp,48
 b04:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b08:	fd843783          	ld	a5,-40(s0)
 b0c:	17c1                	addi	a5,a5,-16
 b0e:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b12:	00000797          	auipc	a5,0x0
 b16:	51e78793          	addi	a5,a5,1310 # 1030 <freep>
 b1a:	639c                	ld	a5,0(a5)
 b1c:	fef43423          	sd	a5,-24(s0)
 b20:	a815                	j	b54 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b22:	fe843783          	ld	a5,-24(s0)
 b26:	639c                	ld	a5,0(a5)
 b28:	fe843703          	ld	a4,-24(s0)
 b2c:	00f76f63          	bltu	a4,a5,b4a <free+0x4c>
 b30:	fe043703          	ld	a4,-32(s0)
 b34:	fe843783          	ld	a5,-24(s0)
 b38:	02e7eb63          	bltu	a5,a4,b6e <free+0x70>
 b3c:	fe843783          	ld	a5,-24(s0)
 b40:	639c                	ld	a5,0(a5)
 b42:	fe043703          	ld	a4,-32(s0)
 b46:	02f76463          	bltu	a4,a5,b6e <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b4a:	fe843783          	ld	a5,-24(s0)
 b4e:	639c                	ld	a5,0(a5)
 b50:	fef43423          	sd	a5,-24(s0)
 b54:	fe043703          	ld	a4,-32(s0)
 b58:	fe843783          	ld	a5,-24(s0)
 b5c:	fce7f3e3          	bgeu	a5,a4,b22 <free+0x24>
 b60:	fe843783          	ld	a5,-24(s0)
 b64:	639c                	ld	a5,0(a5)
 b66:	fe043703          	ld	a4,-32(s0)
 b6a:	faf77ce3          	bgeu	a4,a5,b22 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b6e:	fe043783          	ld	a5,-32(s0)
 b72:	479c                	lw	a5,8(a5)
 b74:	1782                	slli	a5,a5,0x20
 b76:	9381                	srli	a5,a5,0x20
 b78:	0792                	slli	a5,a5,0x4
 b7a:	fe043703          	ld	a4,-32(s0)
 b7e:	973e                	add	a4,a4,a5
 b80:	fe843783          	ld	a5,-24(s0)
 b84:	639c                	ld	a5,0(a5)
 b86:	02f71763          	bne	a4,a5,bb4 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 b8a:	fe043783          	ld	a5,-32(s0)
 b8e:	4798                	lw	a4,8(a5)
 b90:	fe843783          	ld	a5,-24(s0)
 b94:	639c                	ld	a5,0(a5)
 b96:	479c                	lw	a5,8(a5)
 b98:	9fb9                	addw	a5,a5,a4
 b9a:	0007871b          	sext.w	a4,a5
 b9e:	fe043783          	ld	a5,-32(s0)
 ba2:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 ba4:	fe843783          	ld	a5,-24(s0)
 ba8:	639c                	ld	a5,0(a5)
 baa:	6398                	ld	a4,0(a5)
 bac:	fe043783          	ld	a5,-32(s0)
 bb0:	e398                	sd	a4,0(a5)
 bb2:	a039                	j	bc0 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 bb4:	fe843783          	ld	a5,-24(s0)
 bb8:	6398                	ld	a4,0(a5)
 bba:	fe043783          	ld	a5,-32(s0)
 bbe:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 bc0:	fe843783          	ld	a5,-24(s0)
 bc4:	479c                	lw	a5,8(a5)
 bc6:	1782                	slli	a5,a5,0x20
 bc8:	9381                	srli	a5,a5,0x20
 bca:	0792                	slli	a5,a5,0x4
 bcc:	fe843703          	ld	a4,-24(s0)
 bd0:	97ba                	add	a5,a5,a4
 bd2:	fe043703          	ld	a4,-32(s0)
 bd6:	02f71563          	bne	a4,a5,c00 <free+0x102>
    p->s.size += bp->s.size;
 bda:	fe843783          	ld	a5,-24(s0)
 bde:	4798                	lw	a4,8(a5)
 be0:	fe043783          	ld	a5,-32(s0)
 be4:	479c                	lw	a5,8(a5)
 be6:	9fb9                	addw	a5,a5,a4
 be8:	0007871b          	sext.w	a4,a5
 bec:	fe843783          	ld	a5,-24(s0)
 bf0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 bf2:	fe043783          	ld	a5,-32(s0)
 bf6:	6398                	ld	a4,0(a5)
 bf8:	fe843783          	ld	a5,-24(s0)
 bfc:	e398                	sd	a4,0(a5)
 bfe:	a031                	j	c0a <free+0x10c>
  } else
    p->s.ptr = bp;
 c00:	fe843783          	ld	a5,-24(s0)
 c04:	fe043703          	ld	a4,-32(s0)
 c08:	e398                	sd	a4,0(a5)
  freep = p;
 c0a:	00000797          	auipc	a5,0x0
 c0e:	42678793          	addi	a5,a5,1062 # 1030 <freep>
 c12:	fe843703          	ld	a4,-24(s0)
 c16:	e398                	sd	a4,0(a5)
}
 c18:	0001                	nop
 c1a:	7422                	ld	s0,40(sp)
 c1c:	6145                	addi	sp,sp,48
 c1e:	8082                	ret

0000000000000c20 <morecore>:

static Header*
morecore(uint nu)
{
 c20:	7179                	addi	sp,sp,-48
 c22:	f406                	sd	ra,40(sp)
 c24:	f022                	sd	s0,32(sp)
 c26:	1800                	addi	s0,sp,48
 c28:	87aa                	mv	a5,a0
 c2a:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 c2e:	fdc42783          	lw	a5,-36(s0)
 c32:	0007871b          	sext.w	a4,a5
 c36:	6785                	lui	a5,0x1
 c38:	00f77563          	bgeu	a4,a5,c42 <morecore+0x22>
    nu = 4096;
 c3c:	6785                	lui	a5,0x1
 c3e:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 c42:	fdc42783          	lw	a5,-36(s0)
 c46:	0047979b          	slliw	a5,a5,0x4
 c4a:	2781                	sext.w	a5,a5
 c4c:	2781                	sext.w	a5,a5
 c4e:	853e                	mv	a0,a5
 c50:	00000097          	auipc	ra,0x0
 c54:	99e080e7          	jalr	-1634(ra) # 5ee <sbrk>
 c58:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 c5c:	fe843703          	ld	a4,-24(s0)
 c60:	57fd                	li	a5,-1
 c62:	00f71463          	bne	a4,a5,c6a <morecore+0x4a>
    return 0;
 c66:	4781                	li	a5,0
 c68:	a03d                	j	c96 <morecore+0x76>
  hp = (Header*)p;
 c6a:	fe843783          	ld	a5,-24(s0)
 c6e:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 c72:	fe043783          	ld	a5,-32(s0)
 c76:	fdc42703          	lw	a4,-36(s0)
 c7a:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 c7c:	fe043783          	ld	a5,-32(s0)
 c80:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 c82:	853e                	mv	a0,a5
 c84:	00000097          	auipc	ra,0x0
 c88:	e7a080e7          	jalr	-390(ra) # afe <free>
  return freep;
 c8c:	00000797          	auipc	a5,0x0
 c90:	3a478793          	addi	a5,a5,932 # 1030 <freep>
 c94:	639c                	ld	a5,0(a5)
}
 c96:	853e                	mv	a0,a5
 c98:	70a2                	ld	ra,40(sp)
 c9a:	7402                	ld	s0,32(sp)
 c9c:	6145                	addi	sp,sp,48
 c9e:	8082                	ret

0000000000000ca0 <malloc>:

void*
malloc(uint nbytes)
{
 ca0:	7139                	addi	sp,sp,-64
 ca2:	fc06                	sd	ra,56(sp)
 ca4:	f822                	sd	s0,48(sp)
 ca6:	0080                	addi	s0,sp,64
 ca8:	87aa                	mv	a5,a0
 caa:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cae:	fcc46783          	lwu	a5,-52(s0)
 cb2:	07bd                	addi	a5,a5,15
 cb4:	8391                	srli	a5,a5,0x4
 cb6:	2781                	sext.w	a5,a5
 cb8:	2785                	addiw	a5,a5,1
 cba:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 cbe:	00000797          	auipc	a5,0x0
 cc2:	37278793          	addi	a5,a5,882 # 1030 <freep>
 cc6:	639c                	ld	a5,0(a5)
 cc8:	fef43023          	sd	a5,-32(s0)
 ccc:	fe043783          	ld	a5,-32(s0)
 cd0:	ef95                	bnez	a5,d0c <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 cd2:	00000797          	auipc	a5,0x0
 cd6:	34e78793          	addi	a5,a5,846 # 1020 <base>
 cda:	fef43023          	sd	a5,-32(s0)
 cde:	00000797          	auipc	a5,0x0
 ce2:	35278793          	addi	a5,a5,850 # 1030 <freep>
 ce6:	fe043703          	ld	a4,-32(s0)
 cea:	e398                	sd	a4,0(a5)
 cec:	00000797          	auipc	a5,0x0
 cf0:	34478793          	addi	a5,a5,836 # 1030 <freep>
 cf4:	6398                	ld	a4,0(a5)
 cf6:	00000797          	auipc	a5,0x0
 cfa:	32a78793          	addi	a5,a5,810 # 1020 <base>
 cfe:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 d00:	00000797          	auipc	a5,0x0
 d04:	32078793          	addi	a5,a5,800 # 1020 <base>
 d08:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d0c:	fe043783          	ld	a5,-32(s0)
 d10:	639c                	ld	a5,0(a5)
 d12:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 d16:	fe843783          	ld	a5,-24(s0)
 d1a:	4798                	lw	a4,8(a5)
 d1c:	fdc42783          	lw	a5,-36(s0)
 d20:	2781                	sext.w	a5,a5
 d22:	06f76763          	bltu	a4,a5,d90 <malloc+0xf0>
      if(p->s.size == nunits)
 d26:	fe843783          	ld	a5,-24(s0)
 d2a:	4798                	lw	a4,8(a5)
 d2c:	fdc42783          	lw	a5,-36(s0)
 d30:	2781                	sext.w	a5,a5
 d32:	00e79963          	bne	a5,a4,d44 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 d36:	fe843783          	ld	a5,-24(s0)
 d3a:	6398                	ld	a4,0(a5)
 d3c:	fe043783          	ld	a5,-32(s0)
 d40:	e398                	sd	a4,0(a5)
 d42:	a825                	j	d7a <malloc+0xda>
      else {
        p->s.size -= nunits;
 d44:	fe843783          	ld	a5,-24(s0)
 d48:	479c                	lw	a5,8(a5)
 d4a:	fdc42703          	lw	a4,-36(s0)
 d4e:	9f99                	subw	a5,a5,a4
 d50:	0007871b          	sext.w	a4,a5
 d54:	fe843783          	ld	a5,-24(s0)
 d58:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d5a:	fe843783          	ld	a5,-24(s0)
 d5e:	479c                	lw	a5,8(a5)
 d60:	1782                	slli	a5,a5,0x20
 d62:	9381                	srli	a5,a5,0x20
 d64:	0792                	slli	a5,a5,0x4
 d66:	fe843703          	ld	a4,-24(s0)
 d6a:	97ba                	add	a5,a5,a4
 d6c:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 d70:	fe843783          	ld	a5,-24(s0)
 d74:	fdc42703          	lw	a4,-36(s0)
 d78:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 d7a:	00000797          	auipc	a5,0x0
 d7e:	2b678793          	addi	a5,a5,694 # 1030 <freep>
 d82:	fe043703          	ld	a4,-32(s0)
 d86:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 d88:	fe843783          	ld	a5,-24(s0)
 d8c:	07c1                	addi	a5,a5,16
 d8e:	a091                	j	dd2 <malloc+0x132>
    }
    if(p == freep)
 d90:	00000797          	auipc	a5,0x0
 d94:	2a078793          	addi	a5,a5,672 # 1030 <freep>
 d98:	639c                	ld	a5,0(a5)
 d9a:	fe843703          	ld	a4,-24(s0)
 d9e:	02f71063          	bne	a4,a5,dbe <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 da2:	fdc42783          	lw	a5,-36(s0)
 da6:	853e                	mv	a0,a5
 da8:	00000097          	auipc	ra,0x0
 dac:	e78080e7          	jalr	-392(ra) # c20 <morecore>
 db0:	fea43423          	sd	a0,-24(s0)
 db4:	fe843783          	ld	a5,-24(s0)
 db8:	e399                	bnez	a5,dbe <malloc+0x11e>
        return 0;
 dba:	4781                	li	a5,0
 dbc:	a819                	j	dd2 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dbe:	fe843783          	ld	a5,-24(s0)
 dc2:	fef43023          	sd	a5,-32(s0)
 dc6:	fe843783          	ld	a5,-24(s0)
 dca:	639c                	ld	a5,0(a5)
 dcc:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 dd0:	b799                	j	d16 <malloc+0x76>
  }
}
 dd2:	853e                	mv	a0,a5
 dd4:	70e2                	ld	ra,56(sp)
 dd6:	7442                	ld	s0,48(sp)
 dd8:	6121                	addi	sp,sp,64
 dda:	8082                	ret
