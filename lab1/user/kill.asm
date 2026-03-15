
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
   8:	87aa                	mv	a5,a0
   a:	fcb43823          	sd	a1,-48(s0)
   e:	fcf42e23          	sw	a5,-36(s0)
  int i;

  if(argc < 2){
  12:	fdc42783          	lw	a5,-36(s0)
  16:	0007871b          	sext.w	a4,a5
  1a:	4785                	li	a5,1
  1c:	02e7c063          	blt	a5,a4,3c <main+0x3c>
    fprintf(2, "usage: kill pid...\n");
  20:	00001597          	auipc	a1,0x1
  24:	d9058593          	addi	a1,a1,-624 # db0 <malloc+0x13c>
  28:	4509                	li	a0,2
  2a:	00001097          	auipc	ra,0x1
  2e:	a00080e7          	jalr	-1536(ra) # a2a <fprintf>
    exit(1);
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	506080e7          	jalr	1286(ra) # 53a <exit>
  }
  for(i=1; i<argc; i++)
  3c:	4785                	li	a5,1
  3e:	fef42623          	sw	a5,-20(s0)
  42:	a805                	j	72 <main+0x72>
    kill(atoi(argv[i]));
  44:	fec42783          	lw	a5,-20(s0)
  48:	078e                	slli	a5,a5,0x3
  4a:	fd043703          	ld	a4,-48(s0)
  4e:	97ba                	add	a5,a5,a4
  50:	639c                	ld	a5,0(a5)
  52:	853e                	mv	a0,a5
  54:	00000097          	auipc	ra,0x0
  58:	2ec080e7          	jalr	748(ra) # 340 <atoi>
  5c:	87aa                	mv	a5,a0
  5e:	853e                	mv	a0,a5
  60:	00000097          	auipc	ra,0x0
  64:	50a080e7          	jalr	1290(ra) # 56a <kill>
  for(i=1; i<argc; i++)
  68:	fec42783          	lw	a5,-20(s0)
  6c:	2785                	addiw	a5,a5,1
  6e:	fef42623          	sw	a5,-20(s0)
  72:	fec42783          	lw	a5,-20(s0)
  76:	873e                	mv	a4,a5
  78:	fdc42783          	lw	a5,-36(s0)
  7c:	2701                	sext.w	a4,a4
  7e:	2781                	sext.w	a5,a5
  80:	fcf742e3          	blt	a4,a5,44 <main+0x44>
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	4b4080e7          	jalr	1204(ra) # 53a <exit>

000000000000008e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  extern int main();
  main();
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <main>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	49a080e7          	jalr	1178(ra) # 53a <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	7179                	addi	sp,sp,-48
  aa:	f422                	sd	s0,40(sp)
  ac:	1800                	addi	s0,sp,48
  ae:	fca43c23          	sd	a0,-40(s0)
  b2:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  b6:	fd843783          	ld	a5,-40(s0)
  ba:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  be:	0001                	nop
  c0:	fd043703          	ld	a4,-48(s0)
  c4:	00170793          	addi	a5,a4,1
  c8:	fcf43823          	sd	a5,-48(s0)
  cc:	fd843783          	ld	a5,-40(s0)
  d0:	00178693          	addi	a3,a5,1
  d4:	fcd43c23          	sd	a3,-40(s0)
  d8:	00074703          	lbu	a4,0(a4)
  dc:	00e78023          	sb	a4,0(a5)
  e0:	0007c783          	lbu	a5,0(a5)
  e4:	fff1                	bnez	a5,c0 <strcpy+0x18>
    ;
  return os;
  e6:	fe843783          	ld	a5,-24(s0)
}
  ea:	853e                	mv	a0,a5
  ec:	7422                	ld	s0,40(sp)
  ee:	6145                	addi	sp,sp,48
  f0:	8082                	ret

00000000000000f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f2:	1101                	addi	sp,sp,-32
  f4:	ec22                	sd	s0,24(sp)
  f6:	1000                	addi	s0,sp,32
  f8:	fea43423          	sd	a0,-24(s0)
  fc:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 100:	a819                	j	116 <strcmp+0x24>
    p++, q++;
 102:	fe843783          	ld	a5,-24(s0)
 106:	0785                	addi	a5,a5,1
 108:	fef43423          	sd	a5,-24(s0)
 10c:	fe043783          	ld	a5,-32(s0)
 110:	0785                	addi	a5,a5,1
 112:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 116:	fe843783          	ld	a5,-24(s0)
 11a:	0007c783          	lbu	a5,0(a5)
 11e:	cb99                	beqz	a5,134 <strcmp+0x42>
 120:	fe843783          	ld	a5,-24(s0)
 124:	0007c703          	lbu	a4,0(a5)
 128:	fe043783          	ld	a5,-32(s0)
 12c:	0007c783          	lbu	a5,0(a5)
 130:	fcf709e3          	beq	a4,a5,102 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 134:	fe843783          	ld	a5,-24(s0)
 138:	0007c783          	lbu	a5,0(a5)
 13c:	0007871b          	sext.w	a4,a5
 140:	fe043783          	ld	a5,-32(s0)
 144:	0007c783          	lbu	a5,0(a5)
 148:	2781                	sext.w	a5,a5
 14a:	40f707bb          	subw	a5,a4,a5
 14e:	2781                	sext.w	a5,a5
}
 150:	853e                	mv	a0,a5
 152:	6462                	ld	s0,24(sp)
 154:	6105                	addi	sp,sp,32
 156:	8082                	ret

0000000000000158 <strlen>:

uint
strlen(const char *s)
{
 158:	7179                	addi	sp,sp,-48
 15a:	f422                	sd	s0,40(sp)
 15c:	1800                	addi	s0,sp,48
 15e:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 162:	fe042623          	sw	zero,-20(s0)
 166:	a031                	j	172 <strlen+0x1a>
 168:	fec42783          	lw	a5,-20(s0)
 16c:	2785                	addiw	a5,a5,1
 16e:	fef42623          	sw	a5,-20(s0)
 172:	fec42783          	lw	a5,-20(s0)
 176:	fd843703          	ld	a4,-40(s0)
 17a:	97ba                	add	a5,a5,a4
 17c:	0007c783          	lbu	a5,0(a5)
 180:	f7e5                	bnez	a5,168 <strlen+0x10>
    ;
  return n;
 182:	fec42783          	lw	a5,-20(s0)
}
 186:	853e                	mv	a0,a5
 188:	7422                	ld	s0,40(sp)
 18a:	6145                	addi	sp,sp,48
 18c:	8082                	ret

000000000000018e <memset>:

void*
memset(void *dst, int c, uint n)
{
 18e:	7179                	addi	sp,sp,-48
 190:	f422                	sd	s0,40(sp)
 192:	1800                	addi	s0,sp,48
 194:	fca43c23          	sd	a0,-40(s0)
 198:	87ae                	mv	a5,a1
 19a:	8732                	mv	a4,a2
 19c:	fcf42a23          	sw	a5,-44(s0)
 1a0:	87ba                	mv	a5,a4
 1a2:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 1a6:	fd843783          	ld	a5,-40(s0)
 1aa:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 1ae:	fe042623          	sw	zero,-20(s0)
 1b2:	a00d                	j	1d4 <memset+0x46>
    cdst[i] = c;
 1b4:	fec42783          	lw	a5,-20(s0)
 1b8:	fe043703          	ld	a4,-32(s0)
 1bc:	97ba                	add	a5,a5,a4
 1be:	fd442703          	lw	a4,-44(s0)
 1c2:	0ff77713          	zext.b	a4,a4
 1c6:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 1ca:	fec42783          	lw	a5,-20(s0)
 1ce:	2785                	addiw	a5,a5,1
 1d0:	fef42623          	sw	a5,-20(s0)
 1d4:	fec42703          	lw	a4,-20(s0)
 1d8:	fd042783          	lw	a5,-48(s0)
 1dc:	2781                	sext.w	a5,a5
 1de:	fcf76be3          	bltu	a4,a5,1b4 <memset+0x26>
  }
  return dst;
 1e2:	fd843783          	ld	a5,-40(s0)
}
 1e6:	853e                	mv	a0,a5
 1e8:	7422                	ld	s0,40(sp)
 1ea:	6145                	addi	sp,sp,48
 1ec:	8082                	ret

00000000000001ee <strchr>:

char*
strchr(const char *s, char c)
{
 1ee:	1101                	addi	sp,sp,-32
 1f0:	ec22                	sd	s0,24(sp)
 1f2:	1000                	addi	s0,sp,32
 1f4:	fea43423          	sd	a0,-24(s0)
 1f8:	87ae                	mv	a5,a1
 1fa:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 1fe:	a01d                	j	224 <strchr+0x36>
    if(*s == c)
 200:	fe843783          	ld	a5,-24(s0)
 204:	0007c703          	lbu	a4,0(a5)
 208:	fe744783          	lbu	a5,-25(s0)
 20c:	0ff7f793          	zext.b	a5,a5
 210:	00e79563          	bne	a5,a4,21a <strchr+0x2c>
      return (char*)s;
 214:	fe843783          	ld	a5,-24(s0)
 218:	a821                	j	230 <strchr+0x42>
  for(; *s; s++)
 21a:	fe843783          	ld	a5,-24(s0)
 21e:	0785                	addi	a5,a5,1
 220:	fef43423          	sd	a5,-24(s0)
 224:	fe843783          	ld	a5,-24(s0)
 228:	0007c783          	lbu	a5,0(a5)
 22c:	fbf1                	bnez	a5,200 <strchr+0x12>
  return 0;
 22e:	4781                	li	a5,0
}
 230:	853e                	mv	a0,a5
 232:	6462                	ld	s0,24(sp)
 234:	6105                	addi	sp,sp,32
 236:	8082                	ret

0000000000000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	7179                	addi	sp,sp,-48
 23a:	f406                	sd	ra,40(sp)
 23c:	f022                	sd	s0,32(sp)
 23e:	1800                	addi	s0,sp,48
 240:	fca43c23          	sd	a0,-40(s0)
 244:	87ae                	mv	a5,a1
 246:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24a:	fe042623          	sw	zero,-20(s0)
 24e:	a8a1                	j	2a6 <gets+0x6e>
    cc = read(0, &c, 1);
 250:	fe740793          	addi	a5,s0,-25
 254:	4605                	li	a2,1
 256:	85be                	mv	a1,a5
 258:	4501                	li	a0,0
 25a:	00000097          	auipc	ra,0x0
 25e:	2f8080e7          	jalr	760(ra) # 552 <read>
 262:	87aa                	mv	a5,a0
 264:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 268:	fe842783          	lw	a5,-24(s0)
 26c:	2781                	sext.w	a5,a5
 26e:	04f05763          	blez	a5,2bc <gets+0x84>
      break;
    buf[i++] = c;
 272:	fec42783          	lw	a5,-20(s0)
 276:	0017871b          	addiw	a4,a5,1
 27a:	fee42623          	sw	a4,-20(s0)
 27e:	873e                	mv	a4,a5
 280:	fd843783          	ld	a5,-40(s0)
 284:	97ba                	add	a5,a5,a4
 286:	fe744703          	lbu	a4,-25(s0)
 28a:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 28e:	fe744783          	lbu	a5,-25(s0)
 292:	873e                	mv	a4,a5
 294:	47a9                	li	a5,10
 296:	02f70463          	beq	a4,a5,2be <gets+0x86>
 29a:	fe744783          	lbu	a5,-25(s0)
 29e:	873e                	mv	a4,a5
 2a0:	47b5                	li	a5,13
 2a2:	00f70e63          	beq	a4,a5,2be <gets+0x86>
  for(i=0; i+1 < max; ){
 2a6:	fec42783          	lw	a5,-20(s0)
 2aa:	2785                	addiw	a5,a5,1
 2ac:	0007871b          	sext.w	a4,a5
 2b0:	fd442783          	lw	a5,-44(s0)
 2b4:	2781                	sext.w	a5,a5
 2b6:	f8f74de3          	blt	a4,a5,250 <gets+0x18>
 2ba:	a011                	j	2be <gets+0x86>
      break;
 2bc:	0001                	nop
      break;
  }
  buf[i] = '\0';
 2be:	fec42783          	lw	a5,-20(s0)
 2c2:	fd843703          	ld	a4,-40(s0)
 2c6:	97ba                	add	a5,a5,a4
 2c8:	00078023          	sb	zero,0(a5)
  return buf;
 2cc:	fd843783          	ld	a5,-40(s0)
}
 2d0:	853e                	mv	a0,a5
 2d2:	70a2                	ld	ra,40(sp)
 2d4:	7402                	ld	s0,32(sp)
 2d6:	6145                	addi	sp,sp,48
 2d8:	8082                	ret

00000000000002da <stat>:

int
stat(const char *n, struct stat *st)
{
 2da:	7179                	addi	sp,sp,-48
 2dc:	f406                	sd	ra,40(sp)
 2de:	f022                	sd	s0,32(sp)
 2e0:	1800                	addi	s0,sp,48
 2e2:	fca43c23          	sd	a0,-40(s0)
 2e6:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ea:	4581                	li	a1,0
 2ec:	fd843503          	ld	a0,-40(s0)
 2f0:	00000097          	auipc	ra,0x0
 2f4:	28a080e7          	jalr	650(ra) # 57a <open>
 2f8:	87aa                	mv	a5,a0
 2fa:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 2fe:	fec42783          	lw	a5,-20(s0)
 302:	2781                	sext.w	a5,a5
 304:	0007d463          	bgez	a5,30c <stat+0x32>
    return -1;
 308:	57fd                	li	a5,-1
 30a:	a035                	j	336 <stat+0x5c>
  r = fstat(fd, st);
 30c:	fec42783          	lw	a5,-20(s0)
 310:	fd043583          	ld	a1,-48(s0)
 314:	853e                	mv	a0,a5
 316:	00000097          	auipc	ra,0x0
 31a:	27c080e7          	jalr	636(ra) # 592 <fstat>
 31e:	87aa                	mv	a5,a0
 320:	fef42423          	sw	a5,-24(s0)
  close(fd);
 324:	fec42783          	lw	a5,-20(s0)
 328:	853e                	mv	a0,a5
 32a:	00000097          	auipc	ra,0x0
 32e:	238080e7          	jalr	568(ra) # 562 <close>
  return r;
 332:	fe842783          	lw	a5,-24(s0)
}
 336:	853e                	mv	a0,a5
 338:	70a2                	ld	ra,40(sp)
 33a:	7402                	ld	s0,32(sp)
 33c:	6145                	addi	sp,sp,48
 33e:	8082                	ret

0000000000000340 <atoi>:

int
atoi(const char *s)
{
 340:	7179                	addi	sp,sp,-48
 342:	f422                	sd	s0,40(sp)
 344:	1800                	addi	s0,sp,48
 346:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 34a:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 34e:	a81d                	j	384 <atoi+0x44>
    n = n*10 + *s++ - '0';
 350:	fec42783          	lw	a5,-20(s0)
 354:	873e                	mv	a4,a5
 356:	87ba                	mv	a5,a4
 358:	0027979b          	slliw	a5,a5,0x2
 35c:	9fb9                	addw	a5,a5,a4
 35e:	0017979b          	slliw	a5,a5,0x1
 362:	0007871b          	sext.w	a4,a5
 366:	fd843783          	ld	a5,-40(s0)
 36a:	00178693          	addi	a3,a5,1
 36e:	fcd43c23          	sd	a3,-40(s0)
 372:	0007c783          	lbu	a5,0(a5)
 376:	2781                	sext.w	a5,a5
 378:	9fb9                	addw	a5,a5,a4
 37a:	2781                	sext.w	a5,a5
 37c:	fd07879b          	addiw	a5,a5,-48
 380:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 384:	fd843783          	ld	a5,-40(s0)
 388:	0007c783          	lbu	a5,0(a5)
 38c:	873e                	mv	a4,a5
 38e:	02f00793          	li	a5,47
 392:	00e7fb63          	bgeu	a5,a4,3a8 <atoi+0x68>
 396:	fd843783          	ld	a5,-40(s0)
 39a:	0007c783          	lbu	a5,0(a5)
 39e:	873e                	mv	a4,a5
 3a0:	03900793          	li	a5,57
 3a4:	fae7f6e3          	bgeu	a5,a4,350 <atoi+0x10>
  return n;
 3a8:	fec42783          	lw	a5,-20(s0)
}
 3ac:	853e                	mv	a0,a5
 3ae:	7422                	ld	s0,40(sp)
 3b0:	6145                	addi	sp,sp,48
 3b2:	8082                	ret

00000000000003b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	7139                	addi	sp,sp,-64
 3b6:	fc22                	sd	s0,56(sp)
 3b8:	0080                	addi	s0,sp,64
 3ba:	fca43c23          	sd	a0,-40(s0)
 3be:	fcb43823          	sd	a1,-48(s0)
 3c2:	87b2                	mv	a5,a2
 3c4:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 3c8:	fd843783          	ld	a5,-40(s0)
 3cc:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 3d0:	fd043783          	ld	a5,-48(s0)
 3d4:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 3d8:	fe043703          	ld	a4,-32(s0)
 3dc:	fe843783          	ld	a5,-24(s0)
 3e0:	02e7fc63          	bgeu	a5,a4,418 <memmove+0x64>
    while(n-- > 0)
 3e4:	a00d                	j	406 <memmove+0x52>
      *dst++ = *src++;
 3e6:	fe043703          	ld	a4,-32(s0)
 3ea:	00170793          	addi	a5,a4,1
 3ee:	fef43023          	sd	a5,-32(s0)
 3f2:	fe843783          	ld	a5,-24(s0)
 3f6:	00178693          	addi	a3,a5,1
 3fa:	fed43423          	sd	a3,-24(s0)
 3fe:	00074703          	lbu	a4,0(a4)
 402:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 406:	fcc42783          	lw	a5,-52(s0)
 40a:	fff7871b          	addiw	a4,a5,-1
 40e:	fce42623          	sw	a4,-52(s0)
 412:	fcf04ae3          	bgtz	a5,3e6 <memmove+0x32>
 416:	a891                	j	46a <memmove+0xb6>
  } else {
    dst += n;
 418:	fcc42783          	lw	a5,-52(s0)
 41c:	fe843703          	ld	a4,-24(s0)
 420:	97ba                	add	a5,a5,a4
 422:	fef43423          	sd	a5,-24(s0)
    src += n;
 426:	fcc42783          	lw	a5,-52(s0)
 42a:	fe043703          	ld	a4,-32(s0)
 42e:	97ba                	add	a5,a5,a4
 430:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 434:	a01d                	j	45a <memmove+0xa6>
      *--dst = *--src;
 436:	fe043783          	ld	a5,-32(s0)
 43a:	17fd                	addi	a5,a5,-1
 43c:	fef43023          	sd	a5,-32(s0)
 440:	fe843783          	ld	a5,-24(s0)
 444:	17fd                	addi	a5,a5,-1
 446:	fef43423          	sd	a5,-24(s0)
 44a:	fe043783          	ld	a5,-32(s0)
 44e:	0007c703          	lbu	a4,0(a5)
 452:	fe843783          	ld	a5,-24(s0)
 456:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 45a:	fcc42783          	lw	a5,-52(s0)
 45e:	fff7871b          	addiw	a4,a5,-1
 462:	fce42623          	sw	a4,-52(s0)
 466:	fcf048e3          	bgtz	a5,436 <memmove+0x82>
  }
  return vdst;
 46a:	fd843783          	ld	a5,-40(s0)
}
 46e:	853e                	mv	a0,a5
 470:	7462                	ld	s0,56(sp)
 472:	6121                	addi	sp,sp,64
 474:	8082                	ret

0000000000000476 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 476:	7139                	addi	sp,sp,-64
 478:	fc22                	sd	s0,56(sp)
 47a:	0080                	addi	s0,sp,64
 47c:	fca43c23          	sd	a0,-40(s0)
 480:	fcb43823          	sd	a1,-48(s0)
 484:	87b2                	mv	a5,a2
 486:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 48a:	fd843783          	ld	a5,-40(s0)
 48e:	fef43423          	sd	a5,-24(s0)
 492:	fd043783          	ld	a5,-48(s0)
 496:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 49a:	a0a1                	j	4e2 <memcmp+0x6c>
    if (*p1 != *p2) {
 49c:	fe843783          	ld	a5,-24(s0)
 4a0:	0007c703          	lbu	a4,0(a5)
 4a4:	fe043783          	ld	a5,-32(s0)
 4a8:	0007c783          	lbu	a5,0(a5)
 4ac:	02f70163          	beq	a4,a5,4ce <memcmp+0x58>
      return *p1 - *p2;
 4b0:	fe843783          	ld	a5,-24(s0)
 4b4:	0007c783          	lbu	a5,0(a5)
 4b8:	0007871b          	sext.w	a4,a5
 4bc:	fe043783          	ld	a5,-32(s0)
 4c0:	0007c783          	lbu	a5,0(a5)
 4c4:	2781                	sext.w	a5,a5
 4c6:	40f707bb          	subw	a5,a4,a5
 4ca:	2781                	sext.w	a5,a5
 4cc:	a01d                	j	4f2 <memcmp+0x7c>
    }
    p1++;
 4ce:	fe843783          	ld	a5,-24(s0)
 4d2:	0785                	addi	a5,a5,1
 4d4:	fef43423          	sd	a5,-24(s0)
    p2++;
 4d8:	fe043783          	ld	a5,-32(s0)
 4dc:	0785                	addi	a5,a5,1
 4de:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 4e2:	fcc42783          	lw	a5,-52(s0)
 4e6:	fff7871b          	addiw	a4,a5,-1
 4ea:	fce42623          	sw	a4,-52(s0)
 4ee:	f7dd                	bnez	a5,49c <memcmp+0x26>
  }
  return 0;
 4f0:	4781                	li	a5,0
}
 4f2:	853e                	mv	a0,a5
 4f4:	7462                	ld	s0,56(sp)
 4f6:	6121                	addi	sp,sp,64
 4f8:	8082                	ret

00000000000004fa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4fa:	7179                	addi	sp,sp,-48
 4fc:	f406                	sd	ra,40(sp)
 4fe:	f022                	sd	s0,32(sp)
 500:	1800                	addi	s0,sp,48
 502:	fea43423          	sd	a0,-24(s0)
 506:	feb43023          	sd	a1,-32(s0)
 50a:	87b2                	mv	a5,a2
 50c:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 510:	fdc42783          	lw	a5,-36(s0)
 514:	863e                	mv	a2,a5
 516:	fe043583          	ld	a1,-32(s0)
 51a:	fe843503          	ld	a0,-24(s0)
 51e:	00000097          	auipc	ra,0x0
 522:	e96080e7          	jalr	-362(ra) # 3b4 <memmove>
 526:	87aa                	mv	a5,a0
}
 528:	853e                	mv	a0,a5
 52a:	70a2                	ld	ra,40(sp)
 52c:	7402                	ld	s0,32(sp)
 52e:	6145                	addi	sp,sp,48
 530:	8082                	ret

0000000000000532 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 532:	4885                	li	a7,1
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <exit>:
.global exit
exit:
 li a7, SYS_exit
 53a:	4889                	li	a7,2
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <wait>:
.global wait
wait:
 li a7, SYS_wait
 542:	488d                	li	a7,3
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 54a:	4891                	li	a7,4
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <read>:
.global read
read:
 li a7, SYS_read
 552:	4895                	li	a7,5
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <write>:
.global write
write:
 li a7, SYS_write
 55a:	48c1                	li	a7,16
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <close>:
.global close
close:
 li a7, SYS_close
 562:	48d5                	li	a7,21
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <kill>:
.global kill
kill:
 li a7, SYS_kill
 56a:	4899                	li	a7,6
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <exec>:
.global exec
exec:
 li a7, SYS_exec
 572:	489d                	li	a7,7
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <open>:
.global open
open:
 li a7, SYS_open
 57a:	48bd                	li	a7,15
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 582:	48c5                	li	a7,17
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 58a:	48c9                	li	a7,18
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 592:	48a1                	li	a7,8
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <link>:
.global link
link:
 li a7, SYS_link
 59a:	48cd                	li	a7,19
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5a2:	48d1                	li	a7,20
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5aa:	48a5                	li	a7,9
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5b2:	48a9                	li	a7,10
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5ba:	48ad                	li	a7,11
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5c2:	48b1                	li	a7,12
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5ca:	48b5                	li	a7,13
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5d2:	48b9                	li	a7,14
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <hello>:
.global hello
hello:
 li a7, SYS_hello
 5da:	48d9                	li	a7,22
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 5e2:	48e1                	li	a7,24
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 5ea:	48dd                	li	a7,23
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 5f2:	48e5                	li	a7,25
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5fa:	1101                	addi	sp,sp,-32
 5fc:	ec06                	sd	ra,24(sp)
 5fe:	e822                	sd	s0,16(sp)
 600:	1000                	addi	s0,sp,32
 602:	87aa                	mv	a5,a0
 604:	872e                	mv	a4,a1
 606:	fef42623          	sw	a5,-20(s0)
 60a:	87ba                	mv	a5,a4
 60c:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 610:	feb40713          	addi	a4,s0,-21
 614:	fec42783          	lw	a5,-20(s0)
 618:	4605                	li	a2,1
 61a:	85ba                	mv	a1,a4
 61c:	853e                	mv	a0,a5
 61e:	00000097          	auipc	ra,0x0
 622:	f3c080e7          	jalr	-196(ra) # 55a <write>
}
 626:	0001                	nop
 628:	60e2                	ld	ra,24(sp)
 62a:	6442                	ld	s0,16(sp)
 62c:	6105                	addi	sp,sp,32
 62e:	8082                	ret

0000000000000630 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 630:	7139                	addi	sp,sp,-64
 632:	fc06                	sd	ra,56(sp)
 634:	f822                	sd	s0,48(sp)
 636:	0080                	addi	s0,sp,64
 638:	87aa                	mv	a5,a0
 63a:	8736                	mv	a4,a3
 63c:	fcf42623          	sw	a5,-52(s0)
 640:	87ae                	mv	a5,a1
 642:	fcf42423          	sw	a5,-56(s0)
 646:	87b2                	mv	a5,a2
 648:	fcf42223          	sw	a5,-60(s0)
 64c:	87ba                	mv	a5,a4
 64e:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 652:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 656:	fc042783          	lw	a5,-64(s0)
 65a:	2781                	sext.w	a5,a5
 65c:	c38d                	beqz	a5,67e <printint+0x4e>
 65e:	fc842783          	lw	a5,-56(s0)
 662:	2781                	sext.w	a5,a5
 664:	0007dd63          	bgez	a5,67e <printint+0x4e>
    neg = 1;
 668:	4785                	li	a5,1
 66a:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 66e:	fc842783          	lw	a5,-56(s0)
 672:	40f007bb          	negw	a5,a5
 676:	2781                	sext.w	a5,a5
 678:	fef42223          	sw	a5,-28(s0)
 67c:	a029                	j	686 <printint+0x56>
  } else {
    x = xx;
 67e:	fc842783          	lw	a5,-56(s0)
 682:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 686:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 68a:	fc442783          	lw	a5,-60(s0)
 68e:	fe442703          	lw	a4,-28(s0)
 692:	02f777bb          	remuw	a5,a4,a5
 696:	0007861b          	sext.w	a2,a5
 69a:	fec42783          	lw	a5,-20(s0)
 69e:	0017871b          	addiw	a4,a5,1
 6a2:	fee42623          	sw	a4,-20(s0)
 6a6:	00001697          	auipc	a3,0x1
 6aa:	95a68693          	addi	a3,a3,-1702 # 1000 <digits>
 6ae:	02061713          	slli	a4,a2,0x20
 6b2:	9301                	srli	a4,a4,0x20
 6b4:	9736                	add	a4,a4,a3
 6b6:	00074703          	lbu	a4,0(a4)
 6ba:	17c1                	addi	a5,a5,-16
 6bc:	97a2                	add	a5,a5,s0
 6be:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 6c2:	fc442783          	lw	a5,-60(s0)
 6c6:	fe442703          	lw	a4,-28(s0)
 6ca:	02f757bb          	divuw	a5,a4,a5
 6ce:	fef42223          	sw	a5,-28(s0)
 6d2:	fe442783          	lw	a5,-28(s0)
 6d6:	2781                	sext.w	a5,a5
 6d8:	fbcd                	bnez	a5,68a <printint+0x5a>
  if(neg)
 6da:	fe842783          	lw	a5,-24(s0)
 6de:	2781                	sext.w	a5,a5
 6e0:	cf85                	beqz	a5,718 <printint+0xe8>
    buf[i++] = '-';
 6e2:	fec42783          	lw	a5,-20(s0)
 6e6:	0017871b          	addiw	a4,a5,1
 6ea:	fee42623          	sw	a4,-20(s0)
 6ee:	17c1                	addi	a5,a5,-16
 6f0:	97a2                	add	a5,a5,s0
 6f2:	02d00713          	li	a4,45
 6f6:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 6fa:	a839                	j	718 <printint+0xe8>
    putc(fd, buf[i]);
 6fc:	fec42783          	lw	a5,-20(s0)
 700:	17c1                	addi	a5,a5,-16
 702:	97a2                	add	a5,a5,s0
 704:	fe07c703          	lbu	a4,-32(a5)
 708:	fcc42783          	lw	a5,-52(s0)
 70c:	85ba                	mv	a1,a4
 70e:	853e                	mv	a0,a5
 710:	00000097          	auipc	ra,0x0
 714:	eea080e7          	jalr	-278(ra) # 5fa <putc>
  while(--i >= 0)
 718:	fec42783          	lw	a5,-20(s0)
 71c:	37fd                	addiw	a5,a5,-1
 71e:	fef42623          	sw	a5,-20(s0)
 722:	fec42783          	lw	a5,-20(s0)
 726:	2781                	sext.w	a5,a5
 728:	fc07dae3          	bgez	a5,6fc <printint+0xcc>
}
 72c:	0001                	nop
 72e:	0001                	nop
 730:	70e2                	ld	ra,56(sp)
 732:	7442                	ld	s0,48(sp)
 734:	6121                	addi	sp,sp,64
 736:	8082                	ret

0000000000000738 <printptr>:

static void
printptr(int fd, uint64 x) {
 738:	7179                	addi	sp,sp,-48
 73a:	f406                	sd	ra,40(sp)
 73c:	f022                	sd	s0,32(sp)
 73e:	1800                	addi	s0,sp,48
 740:	87aa                	mv	a5,a0
 742:	fcb43823          	sd	a1,-48(s0)
 746:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 74a:	fdc42783          	lw	a5,-36(s0)
 74e:	03000593          	li	a1,48
 752:	853e                	mv	a0,a5
 754:	00000097          	auipc	ra,0x0
 758:	ea6080e7          	jalr	-346(ra) # 5fa <putc>
  putc(fd, 'x');
 75c:	fdc42783          	lw	a5,-36(s0)
 760:	07800593          	li	a1,120
 764:	853e                	mv	a0,a5
 766:	00000097          	auipc	ra,0x0
 76a:	e94080e7          	jalr	-364(ra) # 5fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 76e:	fe042623          	sw	zero,-20(s0)
 772:	a82d                	j	7ac <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 774:	fd043783          	ld	a5,-48(s0)
 778:	93f1                	srli	a5,a5,0x3c
 77a:	00001717          	auipc	a4,0x1
 77e:	88670713          	addi	a4,a4,-1914 # 1000 <digits>
 782:	97ba                	add	a5,a5,a4
 784:	0007c703          	lbu	a4,0(a5)
 788:	fdc42783          	lw	a5,-36(s0)
 78c:	85ba                	mv	a1,a4
 78e:	853e                	mv	a0,a5
 790:	00000097          	auipc	ra,0x0
 794:	e6a080e7          	jalr	-406(ra) # 5fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 798:	fec42783          	lw	a5,-20(s0)
 79c:	2785                	addiw	a5,a5,1
 79e:	fef42623          	sw	a5,-20(s0)
 7a2:	fd043783          	ld	a5,-48(s0)
 7a6:	0792                	slli	a5,a5,0x4
 7a8:	fcf43823          	sd	a5,-48(s0)
 7ac:	fec42783          	lw	a5,-20(s0)
 7b0:	873e                	mv	a4,a5
 7b2:	47bd                	li	a5,15
 7b4:	fce7f0e3          	bgeu	a5,a4,774 <printptr+0x3c>
}
 7b8:	0001                	nop
 7ba:	0001                	nop
 7bc:	70a2                	ld	ra,40(sp)
 7be:	7402                	ld	s0,32(sp)
 7c0:	6145                	addi	sp,sp,48
 7c2:	8082                	ret

00000000000007c4 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7c4:	715d                	addi	sp,sp,-80
 7c6:	e486                	sd	ra,72(sp)
 7c8:	e0a2                	sd	s0,64(sp)
 7ca:	0880                	addi	s0,sp,80
 7cc:	87aa                	mv	a5,a0
 7ce:	fcb43023          	sd	a1,-64(s0)
 7d2:	fac43c23          	sd	a2,-72(s0)
 7d6:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 7da:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 7de:	fe042223          	sw	zero,-28(s0)
 7e2:	a42d                	j	a0c <vprintf+0x248>
    c = fmt[i] & 0xff;
 7e4:	fe442783          	lw	a5,-28(s0)
 7e8:	fc043703          	ld	a4,-64(s0)
 7ec:	97ba                	add	a5,a5,a4
 7ee:	0007c783          	lbu	a5,0(a5)
 7f2:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 7f6:	fe042783          	lw	a5,-32(s0)
 7fa:	2781                	sext.w	a5,a5
 7fc:	eb9d                	bnez	a5,832 <vprintf+0x6e>
      if(c == '%'){
 7fe:	fdc42783          	lw	a5,-36(s0)
 802:	0007871b          	sext.w	a4,a5
 806:	02500793          	li	a5,37
 80a:	00f71763          	bne	a4,a5,818 <vprintf+0x54>
        state = '%';
 80e:	02500793          	li	a5,37
 812:	fef42023          	sw	a5,-32(s0)
 816:	a2f5                	j	a02 <vprintf+0x23e>
      } else {
        putc(fd, c);
 818:	fdc42783          	lw	a5,-36(s0)
 81c:	0ff7f713          	zext.b	a4,a5
 820:	fcc42783          	lw	a5,-52(s0)
 824:	85ba                	mv	a1,a4
 826:	853e                	mv	a0,a5
 828:	00000097          	auipc	ra,0x0
 82c:	dd2080e7          	jalr	-558(ra) # 5fa <putc>
 830:	aac9                	j	a02 <vprintf+0x23e>
      }
    } else if(state == '%'){
 832:	fe042783          	lw	a5,-32(s0)
 836:	0007871b          	sext.w	a4,a5
 83a:	02500793          	li	a5,37
 83e:	1cf71263          	bne	a4,a5,a02 <vprintf+0x23e>
      if(c == 'd'){
 842:	fdc42783          	lw	a5,-36(s0)
 846:	0007871b          	sext.w	a4,a5
 84a:	06400793          	li	a5,100
 84e:	02f71463          	bne	a4,a5,876 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 852:	fb843783          	ld	a5,-72(s0)
 856:	00878713          	addi	a4,a5,8
 85a:	fae43c23          	sd	a4,-72(s0)
 85e:	4398                	lw	a4,0(a5)
 860:	fcc42783          	lw	a5,-52(s0)
 864:	4685                	li	a3,1
 866:	4629                	li	a2,10
 868:	85ba                	mv	a1,a4
 86a:	853e                	mv	a0,a5
 86c:	00000097          	auipc	ra,0x0
 870:	dc4080e7          	jalr	-572(ra) # 630 <printint>
 874:	a269                	j	9fe <vprintf+0x23a>
      } else if(c == 'l') {
 876:	fdc42783          	lw	a5,-36(s0)
 87a:	0007871b          	sext.w	a4,a5
 87e:	06c00793          	li	a5,108
 882:	02f71663          	bne	a4,a5,8ae <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 886:	fb843783          	ld	a5,-72(s0)
 88a:	00878713          	addi	a4,a5,8
 88e:	fae43c23          	sd	a4,-72(s0)
 892:	639c                	ld	a5,0(a5)
 894:	0007871b          	sext.w	a4,a5
 898:	fcc42783          	lw	a5,-52(s0)
 89c:	4681                	li	a3,0
 89e:	4629                	li	a2,10
 8a0:	85ba                	mv	a1,a4
 8a2:	853e                	mv	a0,a5
 8a4:	00000097          	auipc	ra,0x0
 8a8:	d8c080e7          	jalr	-628(ra) # 630 <printint>
 8ac:	aa89                	j	9fe <vprintf+0x23a>
      } else if(c == 'x') {
 8ae:	fdc42783          	lw	a5,-36(s0)
 8b2:	0007871b          	sext.w	a4,a5
 8b6:	07800793          	li	a5,120
 8ba:	02f71463          	bne	a4,a5,8e2 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 8be:	fb843783          	ld	a5,-72(s0)
 8c2:	00878713          	addi	a4,a5,8
 8c6:	fae43c23          	sd	a4,-72(s0)
 8ca:	4398                	lw	a4,0(a5)
 8cc:	fcc42783          	lw	a5,-52(s0)
 8d0:	4681                	li	a3,0
 8d2:	4641                	li	a2,16
 8d4:	85ba                	mv	a1,a4
 8d6:	853e                	mv	a0,a5
 8d8:	00000097          	auipc	ra,0x0
 8dc:	d58080e7          	jalr	-680(ra) # 630 <printint>
 8e0:	aa39                	j	9fe <vprintf+0x23a>
      } else if(c == 'p') {
 8e2:	fdc42783          	lw	a5,-36(s0)
 8e6:	0007871b          	sext.w	a4,a5
 8ea:	07000793          	li	a5,112
 8ee:	02f71263          	bne	a4,a5,912 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 8f2:	fb843783          	ld	a5,-72(s0)
 8f6:	00878713          	addi	a4,a5,8
 8fa:	fae43c23          	sd	a4,-72(s0)
 8fe:	6398                	ld	a4,0(a5)
 900:	fcc42783          	lw	a5,-52(s0)
 904:	85ba                	mv	a1,a4
 906:	853e                	mv	a0,a5
 908:	00000097          	auipc	ra,0x0
 90c:	e30080e7          	jalr	-464(ra) # 738 <printptr>
 910:	a0fd                	j	9fe <vprintf+0x23a>
      } else if(c == 's'){
 912:	fdc42783          	lw	a5,-36(s0)
 916:	0007871b          	sext.w	a4,a5
 91a:	07300793          	li	a5,115
 91e:	04f71c63          	bne	a4,a5,976 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 922:	fb843783          	ld	a5,-72(s0)
 926:	00878713          	addi	a4,a5,8
 92a:	fae43c23          	sd	a4,-72(s0)
 92e:	639c                	ld	a5,0(a5)
 930:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 934:	fe843783          	ld	a5,-24(s0)
 938:	eb8d                	bnez	a5,96a <vprintf+0x1a6>
          s = "(null)";
 93a:	00000797          	auipc	a5,0x0
 93e:	48e78793          	addi	a5,a5,1166 # dc8 <malloc+0x154>
 942:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 946:	a015                	j	96a <vprintf+0x1a6>
          putc(fd, *s);
 948:	fe843783          	ld	a5,-24(s0)
 94c:	0007c703          	lbu	a4,0(a5)
 950:	fcc42783          	lw	a5,-52(s0)
 954:	85ba                	mv	a1,a4
 956:	853e                	mv	a0,a5
 958:	00000097          	auipc	ra,0x0
 95c:	ca2080e7          	jalr	-862(ra) # 5fa <putc>
          s++;
 960:	fe843783          	ld	a5,-24(s0)
 964:	0785                	addi	a5,a5,1
 966:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 96a:	fe843783          	ld	a5,-24(s0)
 96e:	0007c783          	lbu	a5,0(a5)
 972:	fbf9                	bnez	a5,948 <vprintf+0x184>
 974:	a069                	j	9fe <vprintf+0x23a>
        }
      } else if(c == 'c'){
 976:	fdc42783          	lw	a5,-36(s0)
 97a:	0007871b          	sext.w	a4,a5
 97e:	06300793          	li	a5,99
 982:	02f71463          	bne	a4,a5,9aa <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 986:	fb843783          	ld	a5,-72(s0)
 98a:	00878713          	addi	a4,a5,8
 98e:	fae43c23          	sd	a4,-72(s0)
 992:	439c                	lw	a5,0(a5)
 994:	0ff7f713          	zext.b	a4,a5
 998:	fcc42783          	lw	a5,-52(s0)
 99c:	85ba                	mv	a1,a4
 99e:	853e                	mv	a0,a5
 9a0:	00000097          	auipc	ra,0x0
 9a4:	c5a080e7          	jalr	-934(ra) # 5fa <putc>
 9a8:	a899                	j	9fe <vprintf+0x23a>
      } else if(c == '%'){
 9aa:	fdc42783          	lw	a5,-36(s0)
 9ae:	0007871b          	sext.w	a4,a5
 9b2:	02500793          	li	a5,37
 9b6:	00f71f63          	bne	a4,a5,9d4 <vprintf+0x210>
        putc(fd, c);
 9ba:	fdc42783          	lw	a5,-36(s0)
 9be:	0ff7f713          	zext.b	a4,a5
 9c2:	fcc42783          	lw	a5,-52(s0)
 9c6:	85ba                	mv	a1,a4
 9c8:	853e                	mv	a0,a5
 9ca:	00000097          	auipc	ra,0x0
 9ce:	c30080e7          	jalr	-976(ra) # 5fa <putc>
 9d2:	a035                	j	9fe <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9d4:	fcc42783          	lw	a5,-52(s0)
 9d8:	02500593          	li	a1,37
 9dc:	853e                	mv	a0,a5
 9de:	00000097          	auipc	ra,0x0
 9e2:	c1c080e7          	jalr	-996(ra) # 5fa <putc>
        putc(fd, c);
 9e6:	fdc42783          	lw	a5,-36(s0)
 9ea:	0ff7f713          	zext.b	a4,a5
 9ee:	fcc42783          	lw	a5,-52(s0)
 9f2:	85ba                	mv	a1,a4
 9f4:	853e                	mv	a0,a5
 9f6:	00000097          	auipc	ra,0x0
 9fa:	c04080e7          	jalr	-1020(ra) # 5fa <putc>
      }
      state = 0;
 9fe:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 a02:	fe442783          	lw	a5,-28(s0)
 a06:	2785                	addiw	a5,a5,1
 a08:	fef42223          	sw	a5,-28(s0)
 a0c:	fe442783          	lw	a5,-28(s0)
 a10:	fc043703          	ld	a4,-64(s0)
 a14:	97ba                	add	a5,a5,a4
 a16:	0007c783          	lbu	a5,0(a5)
 a1a:	dc0795e3          	bnez	a5,7e4 <vprintf+0x20>
    }
  }
}
 a1e:	0001                	nop
 a20:	0001                	nop
 a22:	60a6                	ld	ra,72(sp)
 a24:	6406                	ld	s0,64(sp)
 a26:	6161                	addi	sp,sp,80
 a28:	8082                	ret

0000000000000a2a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a2a:	7159                	addi	sp,sp,-112
 a2c:	fc06                	sd	ra,56(sp)
 a2e:	f822                	sd	s0,48(sp)
 a30:	0080                	addi	s0,sp,64
 a32:	fcb43823          	sd	a1,-48(s0)
 a36:	e010                	sd	a2,0(s0)
 a38:	e414                	sd	a3,8(s0)
 a3a:	e818                	sd	a4,16(s0)
 a3c:	ec1c                	sd	a5,24(s0)
 a3e:	03043023          	sd	a6,32(s0)
 a42:	03143423          	sd	a7,40(s0)
 a46:	87aa                	mv	a5,a0
 a48:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 a4c:	03040793          	addi	a5,s0,48
 a50:	fcf43423          	sd	a5,-56(s0)
 a54:	fc843783          	ld	a5,-56(s0)
 a58:	fd078793          	addi	a5,a5,-48
 a5c:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 a60:	fe843703          	ld	a4,-24(s0)
 a64:	fdc42783          	lw	a5,-36(s0)
 a68:	863a                	mv	a2,a4
 a6a:	fd043583          	ld	a1,-48(s0)
 a6e:	853e                	mv	a0,a5
 a70:	00000097          	auipc	ra,0x0
 a74:	d54080e7          	jalr	-684(ra) # 7c4 <vprintf>
}
 a78:	0001                	nop
 a7a:	70e2                	ld	ra,56(sp)
 a7c:	7442                	ld	s0,48(sp)
 a7e:	6165                	addi	sp,sp,112
 a80:	8082                	ret

0000000000000a82 <printf>:

void
printf(const char *fmt, ...)
{
 a82:	7159                	addi	sp,sp,-112
 a84:	f406                	sd	ra,40(sp)
 a86:	f022                	sd	s0,32(sp)
 a88:	1800                	addi	s0,sp,48
 a8a:	fca43c23          	sd	a0,-40(s0)
 a8e:	e40c                	sd	a1,8(s0)
 a90:	e810                	sd	a2,16(s0)
 a92:	ec14                	sd	a3,24(s0)
 a94:	f018                	sd	a4,32(s0)
 a96:	f41c                	sd	a5,40(s0)
 a98:	03043823          	sd	a6,48(s0)
 a9c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aa0:	04040793          	addi	a5,s0,64
 aa4:	fcf43823          	sd	a5,-48(s0)
 aa8:	fd043783          	ld	a5,-48(s0)
 aac:	fc878793          	addi	a5,a5,-56
 ab0:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 ab4:	fe843783          	ld	a5,-24(s0)
 ab8:	863e                	mv	a2,a5
 aba:	fd843583          	ld	a1,-40(s0)
 abe:	4505                	li	a0,1
 ac0:	00000097          	auipc	ra,0x0
 ac4:	d04080e7          	jalr	-764(ra) # 7c4 <vprintf>
}
 ac8:	0001                	nop
 aca:	70a2                	ld	ra,40(sp)
 acc:	7402                	ld	s0,32(sp)
 ace:	6165                	addi	sp,sp,112
 ad0:	8082                	ret

0000000000000ad2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ad2:	7179                	addi	sp,sp,-48
 ad4:	f422                	sd	s0,40(sp)
 ad6:	1800                	addi	s0,sp,48
 ad8:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 adc:	fd843783          	ld	a5,-40(s0)
 ae0:	17c1                	addi	a5,a5,-16
 ae2:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae6:	00000797          	auipc	a5,0x0
 aea:	54a78793          	addi	a5,a5,1354 # 1030 <freep>
 aee:	639c                	ld	a5,0(a5)
 af0:	fef43423          	sd	a5,-24(s0)
 af4:	a815                	j	b28 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af6:	fe843783          	ld	a5,-24(s0)
 afa:	639c                	ld	a5,0(a5)
 afc:	fe843703          	ld	a4,-24(s0)
 b00:	00f76f63          	bltu	a4,a5,b1e <free+0x4c>
 b04:	fe043703          	ld	a4,-32(s0)
 b08:	fe843783          	ld	a5,-24(s0)
 b0c:	02e7eb63          	bltu	a5,a4,b42 <free+0x70>
 b10:	fe843783          	ld	a5,-24(s0)
 b14:	639c                	ld	a5,0(a5)
 b16:	fe043703          	ld	a4,-32(s0)
 b1a:	02f76463          	bltu	a4,a5,b42 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b1e:	fe843783          	ld	a5,-24(s0)
 b22:	639c                	ld	a5,0(a5)
 b24:	fef43423          	sd	a5,-24(s0)
 b28:	fe043703          	ld	a4,-32(s0)
 b2c:	fe843783          	ld	a5,-24(s0)
 b30:	fce7f3e3          	bgeu	a5,a4,af6 <free+0x24>
 b34:	fe843783          	ld	a5,-24(s0)
 b38:	639c                	ld	a5,0(a5)
 b3a:	fe043703          	ld	a4,-32(s0)
 b3e:	faf77ce3          	bgeu	a4,a5,af6 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b42:	fe043783          	ld	a5,-32(s0)
 b46:	479c                	lw	a5,8(a5)
 b48:	1782                	slli	a5,a5,0x20
 b4a:	9381                	srli	a5,a5,0x20
 b4c:	0792                	slli	a5,a5,0x4
 b4e:	fe043703          	ld	a4,-32(s0)
 b52:	973e                	add	a4,a4,a5
 b54:	fe843783          	ld	a5,-24(s0)
 b58:	639c                	ld	a5,0(a5)
 b5a:	02f71763          	bne	a4,a5,b88 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 b5e:	fe043783          	ld	a5,-32(s0)
 b62:	4798                	lw	a4,8(a5)
 b64:	fe843783          	ld	a5,-24(s0)
 b68:	639c                	ld	a5,0(a5)
 b6a:	479c                	lw	a5,8(a5)
 b6c:	9fb9                	addw	a5,a5,a4
 b6e:	0007871b          	sext.w	a4,a5
 b72:	fe043783          	ld	a5,-32(s0)
 b76:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 b78:	fe843783          	ld	a5,-24(s0)
 b7c:	639c                	ld	a5,0(a5)
 b7e:	6398                	ld	a4,0(a5)
 b80:	fe043783          	ld	a5,-32(s0)
 b84:	e398                	sd	a4,0(a5)
 b86:	a039                	j	b94 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 b88:	fe843783          	ld	a5,-24(s0)
 b8c:	6398                	ld	a4,0(a5)
 b8e:	fe043783          	ld	a5,-32(s0)
 b92:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 b94:	fe843783          	ld	a5,-24(s0)
 b98:	479c                	lw	a5,8(a5)
 b9a:	1782                	slli	a5,a5,0x20
 b9c:	9381                	srli	a5,a5,0x20
 b9e:	0792                	slli	a5,a5,0x4
 ba0:	fe843703          	ld	a4,-24(s0)
 ba4:	97ba                	add	a5,a5,a4
 ba6:	fe043703          	ld	a4,-32(s0)
 baa:	02f71563          	bne	a4,a5,bd4 <free+0x102>
    p->s.size += bp->s.size;
 bae:	fe843783          	ld	a5,-24(s0)
 bb2:	4798                	lw	a4,8(a5)
 bb4:	fe043783          	ld	a5,-32(s0)
 bb8:	479c                	lw	a5,8(a5)
 bba:	9fb9                	addw	a5,a5,a4
 bbc:	0007871b          	sext.w	a4,a5
 bc0:	fe843783          	ld	a5,-24(s0)
 bc4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 bc6:	fe043783          	ld	a5,-32(s0)
 bca:	6398                	ld	a4,0(a5)
 bcc:	fe843783          	ld	a5,-24(s0)
 bd0:	e398                	sd	a4,0(a5)
 bd2:	a031                	j	bde <free+0x10c>
  } else
    p->s.ptr = bp;
 bd4:	fe843783          	ld	a5,-24(s0)
 bd8:	fe043703          	ld	a4,-32(s0)
 bdc:	e398                	sd	a4,0(a5)
  freep = p;
 bde:	00000797          	auipc	a5,0x0
 be2:	45278793          	addi	a5,a5,1106 # 1030 <freep>
 be6:	fe843703          	ld	a4,-24(s0)
 bea:	e398                	sd	a4,0(a5)
}
 bec:	0001                	nop
 bee:	7422                	ld	s0,40(sp)
 bf0:	6145                	addi	sp,sp,48
 bf2:	8082                	ret

0000000000000bf4 <morecore>:

static Header*
morecore(uint nu)
{
 bf4:	7179                	addi	sp,sp,-48
 bf6:	f406                	sd	ra,40(sp)
 bf8:	f022                	sd	s0,32(sp)
 bfa:	1800                	addi	s0,sp,48
 bfc:	87aa                	mv	a5,a0
 bfe:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 c02:	fdc42783          	lw	a5,-36(s0)
 c06:	0007871b          	sext.w	a4,a5
 c0a:	6785                	lui	a5,0x1
 c0c:	00f77563          	bgeu	a4,a5,c16 <morecore+0x22>
    nu = 4096;
 c10:	6785                	lui	a5,0x1
 c12:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 c16:	fdc42783          	lw	a5,-36(s0)
 c1a:	0047979b          	slliw	a5,a5,0x4
 c1e:	2781                	sext.w	a5,a5
 c20:	2781                	sext.w	a5,a5
 c22:	853e                	mv	a0,a5
 c24:	00000097          	auipc	ra,0x0
 c28:	99e080e7          	jalr	-1634(ra) # 5c2 <sbrk>
 c2c:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 c30:	fe843703          	ld	a4,-24(s0)
 c34:	57fd                	li	a5,-1
 c36:	00f71463          	bne	a4,a5,c3e <morecore+0x4a>
    return 0;
 c3a:	4781                	li	a5,0
 c3c:	a03d                	j	c6a <morecore+0x76>
  hp = (Header*)p;
 c3e:	fe843783          	ld	a5,-24(s0)
 c42:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 c46:	fe043783          	ld	a5,-32(s0)
 c4a:	fdc42703          	lw	a4,-36(s0)
 c4e:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 c50:	fe043783          	ld	a5,-32(s0)
 c54:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 c56:	853e                	mv	a0,a5
 c58:	00000097          	auipc	ra,0x0
 c5c:	e7a080e7          	jalr	-390(ra) # ad2 <free>
  return freep;
 c60:	00000797          	auipc	a5,0x0
 c64:	3d078793          	addi	a5,a5,976 # 1030 <freep>
 c68:	639c                	ld	a5,0(a5)
}
 c6a:	853e                	mv	a0,a5
 c6c:	70a2                	ld	ra,40(sp)
 c6e:	7402                	ld	s0,32(sp)
 c70:	6145                	addi	sp,sp,48
 c72:	8082                	ret

0000000000000c74 <malloc>:

void*
malloc(uint nbytes)
{
 c74:	7139                	addi	sp,sp,-64
 c76:	fc06                	sd	ra,56(sp)
 c78:	f822                	sd	s0,48(sp)
 c7a:	0080                	addi	s0,sp,64
 c7c:	87aa                	mv	a5,a0
 c7e:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c82:	fcc46783          	lwu	a5,-52(s0)
 c86:	07bd                	addi	a5,a5,15
 c88:	8391                	srli	a5,a5,0x4
 c8a:	2781                	sext.w	a5,a5
 c8c:	2785                	addiw	a5,a5,1
 c8e:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 c92:	00000797          	auipc	a5,0x0
 c96:	39e78793          	addi	a5,a5,926 # 1030 <freep>
 c9a:	639c                	ld	a5,0(a5)
 c9c:	fef43023          	sd	a5,-32(s0)
 ca0:	fe043783          	ld	a5,-32(s0)
 ca4:	ef95                	bnez	a5,ce0 <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 ca6:	00000797          	auipc	a5,0x0
 caa:	37a78793          	addi	a5,a5,890 # 1020 <base>
 cae:	fef43023          	sd	a5,-32(s0)
 cb2:	00000797          	auipc	a5,0x0
 cb6:	37e78793          	addi	a5,a5,894 # 1030 <freep>
 cba:	fe043703          	ld	a4,-32(s0)
 cbe:	e398                	sd	a4,0(a5)
 cc0:	00000797          	auipc	a5,0x0
 cc4:	37078793          	addi	a5,a5,880 # 1030 <freep>
 cc8:	6398                	ld	a4,0(a5)
 cca:	00000797          	auipc	a5,0x0
 cce:	35678793          	addi	a5,a5,854 # 1020 <base>
 cd2:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 cd4:	00000797          	auipc	a5,0x0
 cd8:	34c78793          	addi	a5,a5,844 # 1020 <base>
 cdc:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ce0:	fe043783          	ld	a5,-32(s0)
 ce4:	639c                	ld	a5,0(a5)
 ce6:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 cea:	fe843783          	ld	a5,-24(s0)
 cee:	4798                	lw	a4,8(a5)
 cf0:	fdc42783          	lw	a5,-36(s0)
 cf4:	2781                	sext.w	a5,a5
 cf6:	06f76763          	bltu	a4,a5,d64 <malloc+0xf0>
      if(p->s.size == nunits)
 cfa:	fe843783          	ld	a5,-24(s0)
 cfe:	4798                	lw	a4,8(a5)
 d00:	fdc42783          	lw	a5,-36(s0)
 d04:	2781                	sext.w	a5,a5
 d06:	00e79963          	bne	a5,a4,d18 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 d0a:	fe843783          	ld	a5,-24(s0)
 d0e:	6398                	ld	a4,0(a5)
 d10:	fe043783          	ld	a5,-32(s0)
 d14:	e398                	sd	a4,0(a5)
 d16:	a825                	j	d4e <malloc+0xda>
      else {
        p->s.size -= nunits;
 d18:	fe843783          	ld	a5,-24(s0)
 d1c:	479c                	lw	a5,8(a5)
 d1e:	fdc42703          	lw	a4,-36(s0)
 d22:	9f99                	subw	a5,a5,a4
 d24:	0007871b          	sext.w	a4,a5
 d28:	fe843783          	ld	a5,-24(s0)
 d2c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d2e:	fe843783          	ld	a5,-24(s0)
 d32:	479c                	lw	a5,8(a5)
 d34:	1782                	slli	a5,a5,0x20
 d36:	9381                	srli	a5,a5,0x20
 d38:	0792                	slli	a5,a5,0x4
 d3a:	fe843703          	ld	a4,-24(s0)
 d3e:	97ba                	add	a5,a5,a4
 d40:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 d44:	fe843783          	ld	a5,-24(s0)
 d48:	fdc42703          	lw	a4,-36(s0)
 d4c:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 d4e:	00000797          	auipc	a5,0x0
 d52:	2e278793          	addi	a5,a5,738 # 1030 <freep>
 d56:	fe043703          	ld	a4,-32(s0)
 d5a:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 d5c:	fe843783          	ld	a5,-24(s0)
 d60:	07c1                	addi	a5,a5,16
 d62:	a091                	j	da6 <malloc+0x132>
    }
    if(p == freep)
 d64:	00000797          	auipc	a5,0x0
 d68:	2cc78793          	addi	a5,a5,716 # 1030 <freep>
 d6c:	639c                	ld	a5,0(a5)
 d6e:	fe843703          	ld	a4,-24(s0)
 d72:	02f71063          	bne	a4,a5,d92 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 d76:	fdc42783          	lw	a5,-36(s0)
 d7a:	853e                	mv	a0,a5
 d7c:	00000097          	auipc	ra,0x0
 d80:	e78080e7          	jalr	-392(ra) # bf4 <morecore>
 d84:	fea43423          	sd	a0,-24(s0)
 d88:	fe843783          	ld	a5,-24(s0)
 d8c:	e399                	bnez	a5,d92 <malloc+0x11e>
        return 0;
 d8e:	4781                	li	a5,0
 d90:	a819                	j	da6 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d92:	fe843783          	ld	a5,-24(s0)
 d96:	fef43023          	sd	a5,-32(s0)
 d9a:	fe843783          	ld	a5,-24(s0)
 d9e:	639c                	ld	a5,0(a5)
 da0:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 da4:	b799                	j	cea <malloc+0x76>
  }
}
 da6:	853e                	mv	a0,a5
 da8:	70e2                	ld	ra,56(sp)
 daa:	7442                	ld	s0,48(sp)
 dac:	6121                	addi	sp,sp,64
 dae:	8082                	ret
