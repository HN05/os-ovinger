
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
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
    fprintf(2, "Usage: mkdir files...\n");
  20:	00001597          	auipc	a1,0x1
  24:	db058593          	addi	a1,a1,-592 # dd0 <malloc+0x13e>
  28:	4509                	li	a0,2
  2a:	00001097          	auipc	ra,0x1
  2e:	a1e080e7          	jalr	-1506(ra) # a48 <fprintf>
    exit(1);
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	524080e7          	jalr	1316(ra) # 558 <exit>
  }

  for(i = 1; i < argc; i++){
  3c:	4785                	li	a5,1
  3e:	fef42623          	sw	a5,-20(s0)
  42:	a0b9                	j	90 <main+0x90>
    if(mkdir(argv[i]) < 0){
  44:	fec42783          	lw	a5,-20(s0)
  48:	078e                	slli	a5,a5,0x3
  4a:	fd043703          	ld	a4,-48(s0)
  4e:	97ba                	add	a5,a5,a4
  50:	639c                	ld	a5,0(a5)
  52:	853e                	mv	a0,a5
  54:	00000097          	auipc	ra,0x0
  58:	56c080e7          	jalr	1388(ra) # 5c0 <mkdir>
  5c:	87aa                	mv	a5,a0
  5e:	0207d463          	bgez	a5,86 <main+0x86>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  62:	fec42783          	lw	a5,-20(s0)
  66:	078e                	slli	a5,a5,0x3
  68:	fd043703          	ld	a4,-48(s0)
  6c:	97ba                	add	a5,a5,a4
  6e:	639c                	ld	a5,0(a5)
  70:	863e                	mv	a2,a5
  72:	00001597          	auipc	a1,0x1
  76:	d7658593          	addi	a1,a1,-650 # de8 <malloc+0x156>
  7a:	4509                	li	a0,2
  7c:	00001097          	auipc	ra,0x1
  80:	9cc080e7          	jalr	-1588(ra) # a48 <fprintf>
      break;
  84:	a839                	j	a2 <main+0xa2>
  for(i = 1; i < argc; i++){
  86:	fec42783          	lw	a5,-20(s0)
  8a:	2785                	addiw	a5,a5,1
  8c:	fef42623          	sw	a5,-20(s0)
  90:	fec42783          	lw	a5,-20(s0)
  94:	873e                	mv	a4,a5
  96:	fdc42783          	lw	a5,-36(s0)
  9a:	2701                	sext.w	a4,a4
  9c:	2781                	sext.w	a5,a5
  9e:	faf743e3          	blt	a4,a5,44 <main+0x44>
    }
  }

  exit(0);
  a2:	4501                	li	a0,0
  a4:	00000097          	auipc	ra,0x0
  a8:	4b4080e7          	jalr	1204(ra) # 558 <exit>

00000000000000ac <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e406                	sd	ra,8(sp)
  b0:	e022                	sd	s0,0(sp)
  b2:	0800                	addi	s0,sp,16
  extern int main();
  main();
  b4:	00000097          	auipc	ra,0x0
  b8:	f4c080e7          	jalr	-180(ra) # 0 <main>
  exit(0);
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	49a080e7          	jalr	1178(ra) # 558 <exit>

00000000000000c6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c6:	7179                	addi	sp,sp,-48
  c8:	f422                	sd	s0,40(sp)
  ca:	1800                	addi	s0,sp,48
  cc:	fca43c23          	sd	a0,-40(s0)
  d0:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  d4:	fd843783          	ld	a5,-40(s0)
  d8:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  dc:	0001                	nop
  de:	fd043703          	ld	a4,-48(s0)
  e2:	00170793          	addi	a5,a4,1
  e6:	fcf43823          	sd	a5,-48(s0)
  ea:	fd843783          	ld	a5,-40(s0)
  ee:	00178693          	addi	a3,a5,1
  f2:	fcd43c23          	sd	a3,-40(s0)
  f6:	00074703          	lbu	a4,0(a4)
  fa:	00e78023          	sb	a4,0(a5)
  fe:	0007c783          	lbu	a5,0(a5)
 102:	fff1                	bnez	a5,de <strcpy+0x18>
    ;
  return os;
 104:	fe843783          	ld	a5,-24(s0)
}
 108:	853e                	mv	a0,a5
 10a:	7422                	ld	s0,40(sp)
 10c:	6145                	addi	sp,sp,48
 10e:	8082                	ret

0000000000000110 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 110:	1101                	addi	sp,sp,-32
 112:	ec22                	sd	s0,24(sp)
 114:	1000                	addi	s0,sp,32
 116:	fea43423          	sd	a0,-24(s0)
 11a:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 11e:	a819                	j	134 <strcmp+0x24>
    p++, q++;
 120:	fe843783          	ld	a5,-24(s0)
 124:	0785                	addi	a5,a5,1
 126:	fef43423          	sd	a5,-24(s0)
 12a:	fe043783          	ld	a5,-32(s0)
 12e:	0785                	addi	a5,a5,1
 130:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 134:	fe843783          	ld	a5,-24(s0)
 138:	0007c783          	lbu	a5,0(a5)
 13c:	cb99                	beqz	a5,152 <strcmp+0x42>
 13e:	fe843783          	ld	a5,-24(s0)
 142:	0007c703          	lbu	a4,0(a5)
 146:	fe043783          	ld	a5,-32(s0)
 14a:	0007c783          	lbu	a5,0(a5)
 14e:	fcf709e3          	beq	a4,a5,120 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 152:	fe843783          	ld	a5,-24(s0)
 156:	0007c783          	lbu	a5,0(a5)
 15a:	0007871b          	sext.w	a4,a5
 15e:	fe043783          	ld	a5,-32(s0)
 162:	0007c783          	lbu	a5,0(a5)
 166:	2781                	sext.w	a5,a5
 168:	40f707bb          	subw	a5,a4,a5
 16c:	2781                	sext.w	a5,a5
}
 16e:	853e                	mv	a0,a5
 170:	6462                	ld	s0,24(sp)
 172:	6105                	addi	sp,sp,32
 174:	8082                	ret

0000000000000176 <strlen>:

uint
strlen(const char *s)
{
 176:	7179                	addi	sp,sp,-48
 178:	f422                	sd	s0,40(sp)
 17a:	1800                	addi	s0,sp,48
 17c:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 180:	fe042623          	sw	zero,-20(s0)
 184:	a031                	j	190 <strlen+0x1a>
 186:	fec42783          	lw	a5,-20(s0)
 18a:	2785                	addiw	a5,a5,1
 18c:	fef42623          	sw	a5,-20(s0)
 190:	fec42783          	lw	a5,-20(s0)
 194:	fd843703          	ld	a4,-40(s0)
 198:	97ba                	add	a5,a5,a4
 19a:	0007c783          	lbu	a5,0(a5)
 19e:	f7e5                	bnez	a5,186 <strlen+0x10>
    ;
  return n;
 1a0:	fec42783          	lw	a5,-20(s0)
}
 1a4:	853e                	mv	a0,a5
 1a6:	7422                	ld	s0,40(sp)
 1a8:	6145                	addi	sp,sp,48
 1aa:	8082                	ret

00000000000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	7179                	addi	sp,sp,-48
 1ae:	f422                	sd	s0,40(sp)
 1b0:	1800                	addi	s0,sp,48
 1b2:	fca43c23          	sd	a0,-40(s0)
 1b6:	87ae                	mv	a5,a1
 1b8:	8732                	mv	a4,a2
 1ba:	fcf42a23          	sw	a5,-44(s0)
 1be:	87ba                	mv	a5,a4
 1c0:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 1c4:	fd843783          	ld	a5,-40(s0)
 1c8:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 1cc:	fe042623          	sw	zero,-20(s0)
 1d0:	a00d                	j	1f2 <memset+0x46>
    cdst[i] = c;
 1d2:	fec42783          	lw	a5,-20(s0)
 1d6:	fe043703          	ld	a4,-32(s0)
 1da:	97ba                	add	a5,a5,a4
 1dc:	fd442703          	lw	a4,-44(s0)
 1e0:	0ff77713          	zext.b	a4,a4
 1e4:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 1e8:	fec42783          	lw	a5,-20(s0)
 1ec:	2785                	addiw	a5,a5,1
 1ee:	fef42623          	sw	a5,-20(s0)
 1f2:	fec42703          	lw	a4,-20(s0)
 1f6:	fd042783          	lw	a5,-48(s0)
 1fa:	2781                	sext.w	a5,a5
 1fc:	fcf76be3          	bltu	a4,a5,1d2 <memset+0x26>
  }
  return dst;
 200:	fd843783          	ld	a5,-40(s0)
}
 204:	853e                	mv	a0,a5
 206:	7422                	ld	s0,40(sp)
 208:	6145                	addi	sp,sp,48
 20a:	8082                	ret

000000000000020c <strchr>:

char*
strchr(const char *s, char c)
{
 20c:	1101                	addi	sp,sp,-32
 20e:	ec22                	sd	s0,24(sp)
 210:	1000                	addi	s0,sp,32
 212:	fea43423          	sd	a0,-24(s0)
 216:	87ae                	mv	a5,a1
 218:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 21c:	a01d                	j	242 <strchr+0x36>
    if(*s == c)
 21e:	fe843783          	ld	a5,-24(s0)
 222:	0007c703          	lbu	a4,0(a5)
 226:	fe744783          	lbu	a5,-25(s0)
 22a:	0ff7f793          	zext.b	a5,a5
 22e:	00e79563          	bne	a5,a4,238 <strchr+0x2c>
      return (char*)s;
 232:	fe843783          	ld	a5,-24(s0)
 236:	a821                	j	24e <strchr+0x42>
  for(; *s; s++)
 238:	fe843783          	ld	a5,-24(s0)
 23c:	0785                	addi	a5,a5,1
 23e:	fef43423          	sd	a5,-24(s0)
 242:	fe843783          	ld	a5,-24(s0)
 246:	0007c783          	lbu	a5,0(a5)
 24a:	fbf1                	bnez	a5,21e <strchr+0x12>
  return 0;
 24c:	4781                	li	a5,0
}
 24e:	853e                	mv	a0,a5
 250:	6462                	ld	s0,24(sp)
 252:	6105                	addi	sp,sp,32
 254:	8082                	ret

0000000000000256 <gets>:

char*
gets(char *buf, int max)
{
 256:	7179                	addi	sp,sp,-48
 258:	f406                	sd	ra,40(sp)
 25a:	f022                	sd	s0,32(sp)
 25c:	1800                	addi	s0,sp,48
 25e:	fca43c23          	sd	a0,-40(s0)
 262:	87ae                	mv	a5,a1
 264:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 268:	fe042623          	sw	zero,-20(s0)
 26c:	a8a1                	j	2c4 <gets+0x6e>
    cc = read(0, &c, 1);
 26e:	fe740793          	addi	a5,s0,-25
 272:	4605                	li	a2,1
 274:	85be                	mv	a1,a5
 276:	4501                	li	a0,0
 278:	00000097          	auipc	ra,0x0
 27c:	2f8080e7          	jalr	760(ra) # 570 <read>
 280:	87aa                	mv	a5,a0
 282:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 286:	fe842783          	lw	a5,-24(s0)
 28a:	2781                	sext.w	a5,a5
 28c:	04f05763          	blez	a5,2da <gets+0x84>
      break;
    buf[i++] = c;
 290:	fec42783          	lw	a5,-20(s0)
 294:	0017871b          	addiw	a4,a5,1
 298:	fee42623          	sw	a4,-20(s0)
 29c:	873e                	mv	a4,a5
 29e:	fd843783          	ld	a5,-40(s0)
 2a2:	97ba                	add	a5,a5,a4
 2a4:	fe744703          	lbu	a4,-25(s0)
 2a8:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 2ac:	fe744783          	lbu	a5,-25(s0)
 2b0:	873e                	mv	a4,a5
 2b2:	47a9                	li	a5,10
 2b4:	02f70463          	beq	a4,a5,2dc <gets+0x86>
 2b8:	fe744783          	lbu	a5,-25(s0)
 2bc:	873e                	mv	a4,a5
 2be:	47b5                	li	a5,13
 2c0:	00f70e63          	beq	a4,a5,2dc <gets+0x86>
  for(i=0; i+1 < max; ){
 2c4:	fec42783          	lw	a5,-20(s0)
 2c8:	2785                	addiw	a5,a5,1
 2ca:	0007871b          	sext.w	a4,a5
 2ce:	fd442783          	lw	a5,-44(s0)
 2d2:	2781                	sext.w	a5,a5
 2d4:	f8f74de3          	blt	a4,a5,26e <gets+0x18>
 2d8:	a011                	j	2dc <gets+0x86>
      break;
 2da:	0001                	nop
      break;
  }
  buf[i] = '\0';
 2dc:	fec42783          	lw	a5,-20(s0)
 2e0:	fd843703          	ld	a4,-40(s0)
 2e4:	97ba                	add	a5,a5,a4
 2e6:	00078023          	sb	zero,0(a5)
  return buf;
 2ea:	fd843783          	ld	a5,-40(s0)
}
 2ee:	853e                	mv	a0,a5
 2f0:	70a2                	ld	ra,40(sp)
 2f2:	7402                	ld	s0,32(sp)
 2f4:	6145                	addi	sp,sp,48
 2f6:	8082                	ret

00000000000002f8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2f8:	7179                	addi	sp,sp,-48
 2fa:	f406                	sd	ra,40(sp)
 2fc:	f022                	sd	s0,32(sp)
 2fe:	1800                	addi	s0,sp,48
 300:	fca43c23          	sd	a0,-40(s0)
 304:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 308:	4581                	li	a1,0
 30a:	fd843503          	ld	a0,-40(s0)
 30e:	00000097          	auipc	ra,0x0
 312:	28a080e7          	jalr	650(ra) # 598 <open>
 316:	87aa                	mv	a5,a0
 318:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 31c:	fec42783          	lw	a5,-20(s0)
 320:	2781                	sext.w	a5,a5
 322:	0007d463          	bgez	a5,32a <stat+0x32>
    return -1;
 326:	57fd                	li	a5,-1
 328:	a035                	j	354 <stat+0x5c>
  r = fstat(fd, st);
 32a:	fec42783          	lw	a5,-20(s0)
 32e:	fd043583          	ld	a1,-48(s0)
 332:	853e                	mv	a0,a5
 334:	00000097          	auipc	ra,0x0
 338:	27c080e7          	jalr	636(ra) # 5b0 <fstat>
 33c:	87aa                	mv	a5,a0
 33e:	fef42423          	sw	a5,-24(s0)
  close(fd);
 342:	fec42783          	lw	a5,-20(s0)
 346:	853e                	mv	a0,a5
 348:	00000097          	auipc	ra,0x0
 34c:	238080e7          	jalr	568(ra) # 580 <close>
  return r;
 350:	fe842783          	lw	a5,-24(s0)
}
 354:	853e                	mv	a0,a5
 356:	70a2                	ld	ra,40(sp)
 358:	7402                	ld	s0,32(sp)
 35a:	6145                	addi	sp,sp,48
 35c:	8082                	ret

000000000000035e <atoi>:

int
atoi(const char *s)
{
 35e:	7179                	addi	sp,sp,-48
 360:	f422                	sd	s0,40(sp)
 362:	1800                	addi	s0,sp,48
 364:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 368:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 36c:	a81d                	j	3a2 <atoi+0x44>
    n = n*10 + *s++ - '0';
 36e:	fec42783          	lw	a5,-20(s0)
 372:	873e                	mv	a4,a5
 374:	87ba                	mv	a5,a4
 376:	0027979b          	slliw	a5,a5,0x2
 37a:	9fb9                	addw	a5,a5,a4
 37c:	0017979b          	slliw	a5,a5,0x1
 380:	0007871b          	sext.w	a4,a5
 384:	fd843783          	ld	a5,-40(s0)
 388:	00178693          	addi	a3,a5,1
 38c:	fcd43c23          	sd	a3,-40(s0)
 390:	0007c783          	lbu	a5,0(a5)
 394:	2781                	sext.w	a5,a5
 396:	9fb9                	addw	a5,a5,a4
 398:	2781                	sext.w	a5,a5
 39a:	fd07879b          	addiw	a5,a5,-48
 39e:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 3a2:	fd843783          	ld	a5,-40(s0)
 3a6:	0007c783          	lbu	a5,0(a5)
 3aa:	873e                	mv	a4,a5
 3ac:	02f00793          	li	a5,47
 3b0:	00e7fb63          	bgeu	a5,a4,3c6 <atoi+0x68>
 3b4:	fd843783          	ld	a5,-40(s0)
 3b8:	0007c783          	lbu	a5,0(a5)
 3bc:	873e                	mv	a4,a5
 3be:	03900793          	li	a5,57
 3c2:	fae7f6e3          	bgeu	a5,a4,36e <atoi+0x10>
  return n;
 3c6:	fec42783          	lw	a5,-20(s0)
}
 3ca:	853e                	mv	a0,a5
 3cc:	7422                	ld	s0,40(sp)
 3ce:	6145                	addi	sp,sp,48
 3d0:	8082                	ret

00000000000003d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d2:	7139                	addi	sp,sp,-64
 3d4:	fc22                	sd	s0,56(sp)
 3d6:	0080                	addi	s0,sp,64
 3d8:	fca43c23          	sd	a0,-40(s0)
 3dc:	fcb43823          	sd	a1,-48(s0)
 3e0:	87b2                	mv	a5,a2
 3e2:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 3e6:	fd843783          	ld	a5,-40(s0)
 3ea:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 3ee:	fd043783          	ld	a5,-48(s0)
 3f2:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 3f6:	fe043703          	ld	a4,-32(s0)
 3fa:	fe843783          	ld	a5,-24(s0)
 3fe:	02e7fc63          	bgeu	a5,a4,436 <memmove+0x64>
    while(n-- > 0)
 402:	a00d                	j	424 <memmove+0x52>
      *dst++ = *src++;
 404:	fe043703          	ld	a4,-32(s0)
 408:	00170793          	addi	a5,a4,1
 40c:	fef43023          	sd	a5,-32(s0)
 410:	fe843783          	ld	a5,-24(s0)
 414:	00178693          	addi	a3,a5,1
 418:	fed43423          	sd	a3,-24(s0)
 41c:	00074703          	lbu	a4,0(a4)
 420:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 424:	fcc42783          	lw	a5,-52(s0)
 428:	fff7871b          	addiw	a4,a5,-1
 42c:	fce42623          	sw	a4,-52(s0)
 430:	fcf04ae3          	bgtz	a5,404 <memmove+0x32>
 434:	a891                	j	488 <memmove+0xb6>
  } else {
    dst += n;
 436:	fcc42783          	lw	a5,-52(s0)
 43a:	fe843703          	ld	a4,-24(s0)
 43e:	97ba                	add	a5,a5,a4
 440:	fef43423          	sd	a5,-24(s0)
    src += n;
 444:	fcc42783          	lw	a5,-52(s0)
 448:	fe043703          	ld	a4,-32(s0)
 44c:	97ba                	add	a5,a5,a4
 44e:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 452:	a01d                	j	478 <memmove+0xa6>
      *--dst = *--src;
 454:	fe043783          	ld	a5,-32(s0)
 458:	17fd                	addi	a5,a5,-1
 45a:	fef43023          	sd	a5,-32(s0)
 45e:	fe843783          	ld	a5,-24(s0)
 462:	17fd                	addi	a5,a5,-1
 464:	fef43423          	sd	a5,-24(s0)
 468:	fe043783          	ld	a5,-32(s0)
 46c:	0007c703          	lbu	a4,0(a5)
 470:	fe843783          	ld	a5,-24(s0)
 474:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 478:	fcc42783          	lw	a5,-52(s0)
 47c:	fff7871b          	addiw	a4,a5,-1
 480:	fce42623          	sw	a4,-52(s0)
 484:	fcf048e3          	bgtz	a5,454 <memmove+0x82>
  }
  return vdst;
 488:	fd843783          	ld	a5,-40(s0)
}
 48c:	853e                	mv	a0,a5
 48e:	7462                	ld	s0,56(sp)
 490:	6121                	addi	sp,sp,64
 492:	8082                	ret

0000000000000494 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 494:	7139                	addi	sp,sp,-64
 496:	fc22                	sd	s0,56(sp)
 498:	0080                	addi	s0,sp,64
 49a:	fca43c23          	sd	a0,-40(s0)
 49e:	fcb43823          	sd	a1,-48(s0)
 4a2:	87b2                	mv	a5,a2
 4a4:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 4a8:	fd843783          	ld	a5,-40(s0)
 4ac:	fef43423          	sd	a5,-24(s0)
 4b0:	fd043783          	ld	a5,-48(s0)
 4b4:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 4b8:	a0a1                	j	500 <memcmp+0x6c>
    if (*p1 != *p2) {
 4ba:	fe843783          	ld	a5,-24(s0)
 4be:	0007c703          	lbu	a4,0(a5)
 4c2:	fe043783          	ld	a5,-32(s0)
 4c6:	0007c783          	lbu	a5,0(a5)
 4ca:	02f70163          	beq	a4,a5,4ec <memcmp+0x58>
      return *p1 - *p2;
 4ce:	fe843783          	ld	a5,-24(s0)
 4d2:	0007c783          	lbu	a5,0(a5)
 4d6:	0007871b          	sext.w	a4,a5
 4da:	fe043783          	ld	a5,-32(s0)
 4de:	0007c783          	lbu	a5,0(a5)
 4e2:	2781                	sext.w	a5,a5
 4e4:	40f707bb          	subw	a5,a4,a5
 4e8:	2781                	sext.w	a5,a5
 4ea:	a01d                	j	510 <memcmp+0x7c>
    }
    p1++;
 4ec:	fe843783          	ld	a5,-24(s0)
 4f0:	0785                	addi	a5,a5,1
 4f2:	fef43423          	sd	a5,-24(s0)
    p2++;
 4f6:	fe043783          	ld	a5,-32(s0)
 4fa:	0785                	addi	a5,a5,1
 4fc:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 500:	fcc42783          	lw	a5,-52(s0)
 504:	fff7871b          	addiw	a4,a5,-1
 508:	fce42623          	sw	a4,-52(s0)
 50c:	f7dd                	bnez	a5,4ba <memcmp+0x26>
  }
  return 0;
 50e:	4781                	li	a5,0
}
 510:	853e                	mv	a0,a5
 512:	7462                	ld	s0,56(sp)
 514:	6121                	addi	sp,sp,64
 516:	8082                	ret

0000000000000518 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 518:	7179                	addi	sp,sp,-48
 51a:	f406                	sd	ra,40(sp)
 51c:	f022                	sd	s0,32(sp)
 51e:	1800                	addi	s0,sp,48
 520:	fea43423          	sd	a0,-24(s0)
 524:	feb43023          	sd	a1,-32(s0)
 528:	87b2                	mv	a5,a2
 52a:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 52e:	fdc42783          	lw	a5,-36(s0)
 532:	863e                	mv	a2,a5
 534:	fe043583          	ld	a1,-32(s0)
 538:	fe843503          	ld	a0,-24(s0)
 53c:	00000097          	auipc	ra,0x0
 540:	e96080e7          	jalr	-362(ra) # 3d2 <memmove>
 544:	87aa                	mv	a5,a0
}
 546:	853e                	mv	a0,a5
 548:	70a2                	ld	ra,40(sp)
 54a:	7402                	ld	s0,32(sp)
 54c:	6145                	addi	sp,sp,48
 54e:	8082                	ret

0000000000000550 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 550:	4885                	li	a7,1
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <exit>:
.global exit
exit:
 li a7, SYS_exit
 558:	4889                	li	a7,2
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <wait>:
.global wait
wait:
 li a7, SYS_wait
 560:	488d                	li	a7,3
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 568:	4891                	li	a7,4
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <read>:
.global read
read:
 li a7, SYS_read
 570:	4895                	li	a7,5
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <write>:
.global write
write:
 li a7, SYS_write
 578:	48c1                	li	a7,16
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <close>:
.global close
close:
 li a7, SYS_close
 580:	48d5                	li	a7,21
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <kill>:
.global kill
kill:
 li a7, SYS_kill
 588:	4899                	li	a7,6
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <exec>:
.global exec
exec:
 li a7, SYS_exec
 590:	489d                	li	a7,7
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <open>:
.global open
open:
 li a7, SYS_open
 598:	48bd                	li	a7,15
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5a0:	48c5                	li	a7,17
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5a8:	48c9                	li	a7,18
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5b0:	48a1                	li	a7,8
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <link>:
.global link
link:
 li a7, SYS_link
 5b8:	48cd                	li	a7,19
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5c0:	48d1                	li	a7,20
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5c8:	48a5                	li	a7,9
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5d0:	48a9                	li	a7,10
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5d8:	48ad                	li	a7,11
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5e0:	48b1                	li	a7,12
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5e8:	48b5                	li	a7,13
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5f0:	48b9                	li	a7,14
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <hello>:
.global hello
hello:
 li a7, SYS_hello
 5f8:	48d9                	li	a7,22
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <ps>:
.global ps
ps:
 li a7, SYS_ps
 600:	48e1                	li	a7,24
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 608:	48dd                	li	a7,23
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 610:	48e5                	li	a7,25
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 618:	1101                	addi	sp,sp,-32
 61a:	ec06                	sd	ra,24(sp)
 61c:	e822                	sd	s0,16(sp)
 61e:	1000                	addi	s0,sp,32
 620:	87aa                	mv	a5,a0
 622:	872e                	mv	a4,a1
 624:	fef42623          	sw	a5,-20(s0)
 628:	87ba                	mv	a5,a4
 62a:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 62e:	feb40713          	addi	a4,s0,-21
 632:	fec42783          	lw	a5,-20(s0)
 636:	4605                	li	a2,1
 638:	85ba                	mv	a1,a4
 63a:	853e                	mv	a0,a5
 63c:	00000097          	auipc	ra,0x0
 640:	f3c080e7          	jalr	-196(ra) # 578 <write>
}
 644:	0001                	nop
 646:	60e2                	ld	ra,24(sp)
 648:	6442                	ld	s0,16(sp)
 64a:	6105                	addi	sp,sp,32
 64c:	8082                	ret

000000000000064e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 64e:	7139                	addi	sp,sp,-64
 650:	fc06                	sd	ra,56(sp)
 652:	f822                	sd	s0,48(sp)
 654:	0080                	addi	s0,sp,64
 656:	87aa                	mv	a5,a0
 658:	8736                	mv	a4,a3
 65a:	fcf42623          	sw	a5,-52(s0)
 65e:	87ae                	mv	a5,a1
 660:	fcf42423          	sw	a5,-56(s0)
 664:	87b2                	mv	a5,a2
 666:	fcf42223          	sw	a5,-60(s0)
 66a:	87ba                	mv	a5,a4
 66c:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 670:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 674:	fc042783          	lw	a5,-64(s0)
 678:	2781                	sext.w	a5,a5
 67a:	c38d                	beqz	a5,69c <printint+0x4e>
 67c:	fc842783          	lw	a5,-56(s0)
 680:	2781                	sext.w	a5,a5
 682:	0007dd63          	bgez	a5,69c <printint+0x4e>
    neg = 1;
 686:	4785                	li	a5,1
 688:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 68c:	fc842783          	lw	a5,-56(s0)
 690:	40f007bb          	negw	a5,a5
 694:	2781                	sext.w	a5,a5
 696:	fef42223          	sw	a5,-28(s0)
 69a:	a029                	j	6a4 <printint+0x56>
  } else {
    x = xx;
 69c:	fc842783          	lw	a5,-56(s0)
 6a0:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 6a4:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 6a8:	fc442783          	lw	a5,-60(s0)
 6ac:	fe442703          	lw	a4,-28(s0)
 6b0:	02f777bb          	remuw	a5,a4,a5
 6b4:	0007861b          	sext.w	a2,a5
 6b8:	fec42783          	lw	a5,-20(s0)
 6bc:	0017871b          	addiw	a4,a5,1
 6c0:	fee42623          	sw	a4,-20(s0)
 6c4:	00001697          	auipc	a3,0x1
 6c8:	93c68693          	addi	a3,a3,-1732 # 1000 <digits>
 6cc:	02061713          	slli	a4,a2,0x20
 6d0:	9301                	srli	a4,a4,0x20
 6d2:	9736                	add	a4,a4,a3
 6d4:	00074703          	lbu	a4,0(a4)
 6d8:	17c1                	addi	a5,a5,-16
 6da:	97a2                	add	a5,a5,s0
 6dc:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 6e0:	fc442783          	lw	a5,-60(s0)
 6e4:	fe442703          	lw	a4,-28(s0)
 6e8:	02f757bb          	divuw	a5,a4,a5
 6ec:	fef42223          	sw	a5,-28(s0)
 6f0:	fe442783          	lw	a5,-28(s0)
 6f4:	2781                	sext.w	a5,a5
 6f6:	fbcd                	bnez	a5,6a8 <printint+0x5a>
  if(neg)
 6f8:	fe842783          	lw	a5,-24(s0)
 6fc:	2781                	sext.w	a5,a5
 6fe:	cf85                	beqz	a5,736 <printint+0xe8>
    buf[i++] = '-';
 700:	fec42783          	lw	a5,-20(s0)
 704:	0017871b          	addiw	a4,a5,1
 708:	fee42623          	sw	a4,-20(s0)
 70c:	17c1                	addi	a5,a5,-16
 70e:	97a2                	add	a5,a5,s0
 710:	02d00713          	li	a4,45
 714:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 718:	a839                	j	736 <printint+0xe8>
    putc(fd, buf[i]);
 71a:	fec42783          	lw	a5,-20(s0)
 71e:	17c1                	addi	a5,a5,-16
 720:	97a2                	add	a5,a5,s0
 722:	fe07c703          	lbu	a4,-32(a5)
 726:	fcc42783          	lw	a5,-52(s0)
 72a:	85ba                	mv	a1,a4
 72c:	853e                	mv	a0,a5
 72e:	00000097          	auipc	ra,0x0
 732:	eea080e7          	jalr	-278(ra) # 618 <putc>
  while(--i >= 0)
 736:	fec42783          	lw	a5,-20(s0)
 73a:	37fd                	addiw	a5,a5,-1
 73c:	fef42623          	sw	a5,-20(s0)
 740:	fec42783          	lw	a5,-20(s0)
 744:	2781                	sext.w	a5,a5
 746:	fc07dae3          	bgez	a5,71a <printint+0xcc>
}
 74a:	0001                	nop
 74c:	0001                	nop
 74e:	70e2                	ld	ra,56(sp)
 750:	7442                	ld	s0,48(sp)
 752:	6121                	addi	sp,sp,64
 754:	8082                	ret

0000000000000756 <printptr>:

static void
printptr(int fd, uint64 x) {
 756:	7179                	addi	sp,sp,-48
 758:	f406                	sd	ra,40(sp)
 75a:	f022                	sd	s0,32(sp)
 75c:	1800                	addi	s0,sp,48
 75e:	87aa                	mv	a5,a0
 760:	fcb43823          	sd	a1,-48(s0)
 764:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 768:	fdc42783          	lw	a5,-36(s0)
 76c:	03000593          	li	a1,48
 770:	853e                	mv	a0,a5
 772:	00000097          	auipc	ra,0x0
 776:	ea6080e7          	jalr	-346(ra) # 618 <putc>
  putc(fd, 'x');
 77a:	fdc42783          	lw	a5,-36(s0)
 77e:	07800593          	li	a1,120
 782:	853e                	mv	a0,a5
 784:	00000097          	auipc	ra,0x0
 788:	e94080e7          	jalr	-364(ra) # 618 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 78c:	fe042623          	sw	zero,-20(s0)
 790:	a82d                	j	7ca <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 792:	fd043783          	ld	a5,-48(s0)
 796:	93f1                	srli	a5,a5,0x3c
 798:	00001717          	auipc	a4,0x1
 79c:	86870713          	addi	a4,a4,-1944 # 1000 <digits>
 7a0:	97ba                	add	a5,a5,a4
 7a2:	0007c703          	lbu	a4,0(a5)
 7a6:	fdc42783          	lw	a5,-36(s0)
 7aa:	85ba                	mv	a1,a4
 7ac:	853e                	mv	a0,a5
 7ae:	00000097          	auipc	ra,0x0
 7b2:	e6a080e7          	jalr	-406(ra) # 618 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b6:	fec42783          	lw	a5,-20(s0)
 7ba:	2785                	addiw	a5,a5,1
 7bc:	fef42623          	sw	a5,-20(s0)
 7c0:	fd043783          	ld	a5,-48(s0)
 7c4:	0792                	slli	a5,a5,0x4
 7c6:	fcf43823          	sd	a5,-48(s0)
 7ca:	fec42783          	lw	a5,-20(s0)
 7ce:	873e                	mv	a4,a5
 7d0:	47bd                	li	a5,15
 7d2:	fce7f0e3          	bgeu	a5,a4,792 <printptr+0x3c>
}
 7d6:	0001                	nop
 7d8:	0001                	nop
 7da:	70a2                	ld	ra,40(sp)
 7dc:	7402                	ld	s0,32(sp)
 7de:	6145                	addi	sp,sp,48
 7e0:	8082                	ret

00000000000007e2 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7e2:	715d                	addi	sp,sp,-80
 7e4:	e486                	sd	ra,72(sp)
 7e6:	e0a2                	sd	s0,64(sp)
 7e8:	0880                	addi	s0,sp,80
 7ea:	87aa                	mv	a5,a0
 7ec:	fcb43023          	sd	a1,-64(s0)
 7f0:	fac43c23          	sd	a2,-72(s0)
 7f4:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 7f8:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 7fc:	fe042223          	sw	zero,-28(s0)
 800:	a42d                	j	a2a <vprintf+0x248>
    c = fmt[i] & 0xff;
 802:	fe442783          	lw	a5,-28(s0)
 806:	fc043703          	ld	a4,-64(s0)
 80a:	97ba                	add	a5,a5,a4
 80c:	0007c783          	lbu	a5,0(a5)
 810:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 814:	fe042783          	lw	a5,-32(s0)
 818:	2781                	sext.w	a5,a5
 81a:	eb9d                	bnez	a5,850 <vprintf+0x6e>
      if(c == '%'){
 81c:	fdc42783          	lw	a5,-36(s0)
 820:	0007871b          	sext.w	a4,a5
 824:	02500793          	li	a5,37
 828:	00f71763          	bne	a4,a5,836 <vprintf+0x54>
        state = '%';
 82c:	02500793          	li	a5,37
 830:	fef42023          	sw	a5,-32(s0)
 834:	a2f5                	j	a20 <vprintf+0x23e>
      } else {
        putc(fd, c);
 836:	fdc42783          	lw	a5,-36(s0)
 83a:	0ff7f713          	zext.b	a4,a5
 83e:	fcc42783          	lw	a5,-52(s0)
 842:	85ba                	mv	a1,a4
 844:	853e                	mv	a0,a5
 846:	00000097          	auipc	ra,0x0
 84a:	dd2080e7          	jalr	-558(ra) # 618 <putc>
 84e:	aac9                	j	a20 <vprintf+0x23e>
      }
    } else if(state == '%'){
 850:	fe042783          	lw	a5,-32(s0)
 854:	0007871b          	sext.w	a4,a5
 858:	02500793          	li	a5,37
 85c:	1cf71263          	bne	a4,a5,a20 <vprintf+0x23e>
      if(c == 'd'){
 860:	fdc42783          	lw	a5,-36(s0)
 864:	0007871b          	sext.w	a4,a5
 868:	06400793          	li	a5,100
 86c:	02f71463          	bne	a4,a5,894 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 870:	fb843783          	ld	a5,-72(s0)
 874:	00878713          	addi	a4,a5,8
 878:	fae43c23          	sd	a4,-72(s0)
 87c:	4398                	lw	a4,0(a5)
 87e:	fcc42783          	lw	a5,-52(s0)
 882:	4685                	li	a3,1
 884:	4629                	li	a2,10
 886:	85ba                	mv	a1,a4
 888:	853e                	mv	a0,a5
 88a:	00000097          	auipc	ra,0x0
 88e:	dc4080e7          	jalr	-572(ra) # 64e <printint>
 892:	a269                	j	a1c <vprintf+0x23a>
      } else if(c == 'l') {
 894:	fdc42783          	lw	a5,-36(s0)
 898:	0007871b          	sext.w	a4,a5
 89c:	06c00793          	li	a5,108
 8a0:	02f71663          	bne	a4,a5,8cc <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8a4:	fb843783          	ld	a5,-72(s0)
 8a8:	00878713          	addi	a4,a5,8
 8ac:	fae43c23          	sd	a4,-72(s0)
 8b0:	639c                	ld	a5,0(a5)
 8b2:	0007871b          	sext.w	a4,a5
 8b6:	fcc42783          	lw	a5,-52(s0)
 8ba:	4681                	li	a3,0
 8bc:	4629                	li	a2,10
 8be:	85ba                	mv	a1,a4
 8c0:	853e                	mv	a0,a5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	d8c080e7          	jalr	-628(ra) # 64e <printint>
 8ca:	aa89                	j	a1c <vprintf+0x23a>
      } else if(c == 'x') {
 8cc:	fdc42783          	lw	a5,-36(s0)
 8d0:	0007871b          	sext.w	a4,a5
 8d4:	07800793          	li	a5,120
 8d8:	02f71463          	bne	a4,a5,900 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 8dc:	fb843783          	ld	a5,-72(s0)
 8e0:	00878713          	addi	a4,a5,8
 8e4:	fae43c23          	sd	a4,-72(s0)
 8e8:	4398                	lw	a4,0(a5)
 8ea:	fcc42783          	lw	a5,-52(s0)
 8ee:	4681                	li	a3,0
 8f0:	4641                	li	a2,16
 8f2:	85ba                	mv	a1,a4
 8f4:	853e                	mv	a0,a5
 8f6:	00000097          	auipc	ra,0x0
 8fa:	d58080e7          	jalr	-680(ra) # 64e <printint>
 8fe:	aa39                	j	a1c <vprintf+0x23a>
      } else if(c == 'p') {
 900:	fdc42783          	lw	a5,-36(s0)
 904:	0007871b          	sext.w	a4,a5
 908:	07000793          	li	a5,112
 90c:	02f71263          	bne	a4,a5,930 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 910:	fb843783          	ld	a5,-72(s0)
 914:	00878713          	addi	a4,a5,8
 918:	fae43c23          	sd	a4,-72(s0)
 91c:	6398                	ld	a4,0(a5)
 91e:	fcc42783          	lw	a5,-52(s0)
 922:	85ba                	mv	a1,a4
 924:	853e                	mv	a0,a5
 926:	00000097          	auipc	ra,0x0
 92a:	e30080e7          	jalr	-464(ra) # 756 <printptr>
 92e:	a0fd                	j	a1c <vprintf+0x23a>
      } else if(c == 's'){
 930:	fdc42783          	lw	a5,-36(s0)
 934:	0007871b          	sext.w	a4,a5
 938:	07300793          	li	a5,115
 93c:	04f71c63          	bne	a4,a5,994 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 940:	fb843783          	ld	a5,-72(s0)
 944:	00878713          	addi	a4,a5,8
 948:	fae43c23          	sd	a4,-72(s0)
 94c:	639c                	ld	a5,0(a5)
 94e:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 952:	fe843783          	ld	a5,-24(s0)
 956:	eb8d                	bnez	a5,988 <vprintf+0x1a6>
          s = "(null)";
 958:	00000797          	auipc	a5,0x0
 95c:	4b078793          	addi	a5,a5,1200 # e08 <malloc+0x176>
 960:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 964:	a015                	j	988 <vprintf+0x1a6>
          putc(fd, *s);
 966:	fe843783          	ld	a5,-24(s0)
 96a:	0007c703          	lbu	a4,0(a5)
 96e:	fcc42783          	lw	a5,-52(s0)
 972:	85ba                	mv	a1,a4
 974:	853e                	mv	a0,a5
 976:	00000097          	auipc	ra,0x0
 97a:	ca2080e7          	jalr	-862(ra) # 618 <putc>
          s++;
 97e:	fe843783          	ld	a5,-24(s0)
 982:	0785                	addi	a5,a5,1
 984:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 988:	fe843783          	ld	a5,-24(s0)
 98c:	0007c783          	lbu	a5,0(a5)
 990:	fbf9                	bnez	a5,966 <vprintf+0x184>
 992:	a069                	j	a1c <vprintf+0x23a>
        }
      } else if(c == 'c'){
 994:	fdc42783          	lw	a5,-36(s0)
 998:	0007871b          	sext.w	a4,a5
 99c:	06300793          	li	a5,99
 9a0:	02f71463          	bne	a4,a5,9c8 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 9a4:	fb843783          	ld	a5,-72(s0)
 9a8:	00878713          	addi	a4,a5,8
 9ac:	fae43c23          	sd	a4,-72(s0)
 9b0:	439c                	lw	a5,0(a5)
 9b2:	0ff7f713          	zext.b	a4,a5
 9b6:	fcc42783          	lw	a5,-52(s0)
 9ba:	85ba                	mv	a1,a4
 9bc:	853e                	mv	a0,a5
 9be:	00000097          	auipc	ra,0x0
 9c2:	c5a080e7          	jalr	-934(ra) # 618 <putc>
 9c6:	a899                	j	a1c <vprintf+0x23a>
      } else if(c == '%'){
 9c8:	fdc42783          	lw	a5,-36(s0)
 9cc:	0007871b          	sext.w	a4,a5
 9d0:	02500793          	li	a5,37
 9d4:	00f71f63          	bne	a4,a5,9f2 <vprintf+0x210>
        putc(fd, c);
 9d8:	fdc42783          	lw	a5,-36(s0)
 9dc:	0ff7f713          	zext.b	a4,a5
 9e0:	fcc42783          	lw	a5,-52(s0)
 9e4:	85ba                	mv	a1,a4
 9e6:	853e                	mv	a0,a5
 9e8:	00000097          	auipc	ra,0x0
 9ec:	c30080e7          	jalr	-976(ra) # 618 <putc>
 9f0:	a035                	j	a1c <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9f2:	fcc42783          	lw	a5,-52(s0)
 9f6:	02500593          	li	a1,37
 9fa:	853e                	mv	a0,a5
 9fc:	00000097          	auipc	ra,0x0
 a00:	c1c080e7          	jalr	-996(ra) # 618 <putc>
        putc(fd, c);
 a04:	fdc42783          	lw	a5,-36(s0)
 a08:	0ff7f713          	zext.b	a4,a5
 a0c:	fcc42783          	lw	a5,-52(s0)
 a10:	85ba                	mv	a1,a4
 a12:	853e                	mv	a0,a5
 a14:	00000097          	auipc	ra,0x0
 a18:	c04080e7          	jalr	-1020(ra) # 618 <putc>
      }
      state = 0;
 a1c:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 a20:	fe442783          	lw	a5,-28(s0)
 a24:	2785                	addiw	a5,a5,1
 a26:	fef42223          	sw	a5,-28(s0)
 a2a:	fe442783          	lw	a5,-28(s0)
 a2e:	fc043703          	ld	a4,-64(s0)
 a32:	97ba                	add	a5,a5,a4
 a34:	0007c783          	lbu	a5,0(a5)
 a38:	dc0795e3          	bnez	a5,802 <vprintf+0x20>
    }
  }
}
 a3c:	0001                	nop
 a3e:	0001                	nop
 a40:	60a6                	ld	ra,72(sp)
 a42:	6406                	ld	s0,64(sp)
 a44:	6161                	addi	sp,sp,80
 a46:	8082                	ret

0000000000000a48 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a48:	7159                	addi	sp,sp,-112
 a4a:	fc06                	sd	ra,56(sp)
 a4c:	f822                	sd	s0,48(sp)
 a4e:	0080                	addi	s0,sp,64
 a50:	fcb43823          	sd	a1,-48(s0)
 a54:	e010                	sd	a2,0(s0)
 a56:	e414                	sd	a3,8(s0)
 a58:	e818                	sd	a4,16(s0)
 a5a:	ec1c                	sd	a5,24(s0)
 a5c:	03043023          	sd	a6,32(s0)
 a60:	03143423          	sd	a7,40(s0)
 a64:	87aa                	mv	a5,a0
 a66:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 a6a:	03040793          	addi	a5,s0,48
 a6e:	fcf43423          	sd	a5,-56(s0)
 a72:	fc843783          	ld	a5,-56(s0)
 a76:	fd078793          	addi	a5,a5,-48
 a7a:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 a7e:	fe843703          	ld	a4,-24(s0)
 a82:	fdc42783          	lw	a5,-36(s0)
 a86:	863a                	mv	a2,a4
 a88:	fd043583          	ld	a1,-48(s0)
 a8c:	853e                	mv	a0,a5
 a8e:	00000097          	auipc	ra,0x0
 a92:	d54080e7          	jalr	-684(ra) # 7e2 <vprintf>
}
 a96:	0001                	nop
 a98:	70e2                	ld	ra,56(sp)
 a9a:	7442                	ld	s0,48(sp)
 a9c:	6165                	addi	sp,sp,112
 a9e:	8082                	ret

0000000000000aa0 <printf>:

void
printf(const char *fmt, ...)
{
 aa0:	7159                	addi	sp,sp,-112
 aa2:	f406                	sd	ra,40(sp)
 aa4:	f022                	sd	s0,32(sp)
 aa6:	1800                	addi	s0,sp,48
 aa8:	fca43c23          	sd	a0,-40(s0)
 aac:	e40c                	sd	a1,8(s0)
 aae:	e810                	sd	a2,16(s0)
 ab0:	ec14                	sd	a3,24(s0)
 ab2:	f018                	sd	a4,32(s0)
 ab4:	f41c                	sd	a5,40(s0)
 ab6:	03043823          	sd	a6,48(s0)
 aba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 abe:	04040793          	addi	a5,s0,64
 ac2:	fcf43823          	sd	a5,-48(s0)
 ac6:	fd043783          	ld	a5,-48(s0)
 aca:	fc878793          	addi	a5,a5,-56
 ace:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 ad2:	fe843783          	ld	a5,-24(s0)
 ad6:	863e                	mv	a2,a5
 ad8:	fd843583          	ld	a1,-40(s0)
 adc:	4505                	li	a0,1
 ade:	00000097          	auipc	ra,0x0
 ae2:	d04080e7          	jalr	-764(ra) # 7e2 <vprintf>
}
 ae6:	0001                	nop
 ae8:	70a2                	ld	ra,40(sp)
 aea:	7402                	ld	s0,32(sp)
 aec:	6165                	addi	sp,sp,112
 aee:	8082                	ret

0000000000000af0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 af0:	7179                	addi	sp,sp,-48
 af2:	f422                	sd	s0,40(sp)
 af4:	1800                	addi	s0,sp,48
 af6:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 afa:	fd843783          	ld	a5,-40(s0)
 afe:	17c1                	addi	a5,a5,-16
 b00:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b04:	00000797          	auipc	a5,0x0
 b08:	52c78793          	addi	a5,a5,1324 # 1030 <freep>
 b0c:	639c                	ld	a5,0(a5)
 b0e:	fef43423          	sd	a5,-24(s0)
 b12:	a815                	j	b46 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b14:	fe843783          	ld	a5,-24(s0)
 b18:	639c                	ld	a5,0(a5)
 b1a:	fe843703          	ld	a4,-24(s0)
 b1e:	00f76f63          	bltu	a4,a5,b3c <free+0x4c>
 b22:	fe043703          	ld	a4,-32(s0)
 b26:	fe843783          	ld	a5,-24(s0)
 b2a:	02e7eb63          	bltu	a5,a4,b60 <free+0x70>
 b2e:	fe843783          	ld	a5,-24(s0)
 b32:	639c                	ld	a5,0(a5)
 b34:	fe043703          	ld	a4,-32(s0)
 b38:	02f76463          	bltu	a4,a5,b60 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b3c:	fe843783          	ld	a5,-24(s0)
 b40:	639c                	ld	a5,0(a5)
 b42:	fef43423          	sd	a5,-24(s0)
 b46:	fe043703          	ld	a4,-32(s0)
 b4a:	fe843783          	ld	a5,-24(s0)
 b4e:	fce7f3e3          	bgeu	a5,a4,b14 <free+0x24>
 b52:	fe843783          	ld	a5,-24(s0)
 b56:	639c                	ld	a5,0(a5)
 b58:	fe043703          	ld	a4,-32(s0)
 b5c:	faf77ce3          	bgeu	a4,a5,b14 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b60:	fe043783          	ld	a5,-32(s0)
 b64:	479c                	lw	a5,8(a5)
 b66:	1782                	slli	a5,a5,0x20
 b68:	9381                	srli	a5,a5,0x20
 b6a:	0792                	slli	a5,a5,0x4
 b6c:	fe043703          	ld	a4,-32(s0)
 b70:	973e                	add	a4,a4,a5
 b72:	fe843783          	ld	a5,-24(s0)
 b76:	639c                	ld	a5,0(a5)
 b78:	02f71763          	bne	a4,a5,ba6 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 b7c:	fe043783          	ld	a5,-32(s0)
 b80:	4798                	lw	a4,8(a5)
 b82:	fe843783          	ld	a5,-24(s0)
 b86:	639c                	ld	a5,0(a5)
 b88:	479c                	lw	a5,8(a5)
 b8a:	9fb9                	addw	a5,a5,a4
 b8c:	0007871b          	sext.w	a4,a5
 b90:	fe043783          	ld	a5,-32(s0)
 b94:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 b96:	fe843783          	ld	a5,-24(s0)
 b9a:	639c                	ld	a5,0(a5)
 b9c:	6398                	ld	a4,0(a5)
 b9e:	fe043783          	ld	a5,-32(s0)
 ba2:	e398                	sd	a4,0(a5)
 ba4:	a039                	j	bb2 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 ba6:	fe843783          	ld	a5,-24(s0)
 baa:	6398                	ld	a4,0(a5)
 bac:	fe043783          	ld	a5,-32(s0)
 bb0:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 bb2:	fe843783          	ld	a5,-24(s0)
 bb6:	479c                	lw	a5,8(a5)
 bb8:	1782                	slli	a5,a5,0x20
 bba:	9381                	srli	a5,a5,0x20
 bbc:	0792                	slli	a5,a5,0x4
 bbe:	fe843703          	ld	a4,-24(s0)
 bc2:	97ba                	add	a5,a5,a4
 bc4:	fe043703          	ld	a4,-32(s0)
 bc8:	02f71563          	bne	a4,a5,bf2 <free+0x102>
    p->s.size += bp->s.size;
 bcc:	fe843783          	ld	a5,-24(s0)
 bd0:	4798                	lw	a4,8(a5)
 bd2:	fe043783          	ld	a5,-32(s0)
 bd6:	479c                	lw	a5,8(a5)
 bd8:	9fb9                	addw	a5,a5,a4
 bda:	0007871b          	sext.w	a4,a5
 bde:	fe843783          	ld	a5,-24(s0)
 be2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 be4:	fe043783          	ld	a5,-32(s0)
 be8:	6398                	ld	a4,0(a5)
 bea:	fe843783          	ld	a5,-24(s0)
 bee:	e398                	sd	a4,0(a5)
 bf0:	a031                	j	bfc <free+0x10c>
  } else
    p->s.ptr = bp;
 bf2:	fe843783          	ld	a5,-24(s0)
 bf6:	fe043703          	ld	a4,-32(s0)
 bfa:	e398                	sd	a4,0(a5)
  freep = p;
 bfc:	00000797          	auipc	a5,0x0
 c00:	43478793          	addi	a5,a5,1076 # 1030 <freep>
 c04:	fe843703          	ld	a4,-24(s0)
 c08:	e398                	sd	a4,0(a5)
}
 c0a:	0001                	nop
 c0c:	7422                	ld	s0,40(sp)
 c0e:	6145                	addi	sp,sp,48
 c10:	8082                	ret

0000000000000c12 <morecore>:

static Header*
morecore(uint nu)
{
 c12:	7179                	addi	sp,sp,-48
 c14:	f406                	sd	ra,40(sp)
 c16:	f022                	sd	s0,32(sp)
 c18:	1800                	addi	s0,sp,48
 c1a:	87aa                	mv	a5,a0
 c1c:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 c20:	fdc42783          	lw	a5,-36(s0)
 c24:	0007871b          	sext.w	a4,a5
 c28:	6785                	lui	a5,0x1
 c2a:	00f77563          	bgeu	a4,a5,c34 <morecore+0x22>
    nu = 4096;
 c2e:	6785                	lui	a5,0x1
 c30:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 c34:	fdc42783          	lw	a5,-36(s0)
 c38:	0047979b          	slliw	a5,a5,0x4
 c3c:	2781                	sext.w	a5,a5
 c3e:	2781                	sext.w	a5,a5
 c40:	853e                	mv	a0,a5
 c42:	00000097          	auipc	ra,0x0
 c46:	99e080e7          	jalr	-1634(ra) # 5e0 <sbrk>
 c4a:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 c4e:	fe843703          	ld	a4,-24(s0)
 c52:	57fd                	li	a5,-1
 c54:	00f71463          	bne	a4,a5,c5c <morecore+0x4a>
    return 0;
 c58:	4781                	li	a5,0
 c5a:	a03d                	j	c88 <morecore+0x76>
  hp = (Header*)p;
 c5c:	fe843783          	ld	a5,-24(s0)
 c60:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 c64:	fe043783          	ld	a5,-32(s0)
 c68:	fdc42703          	lw	a4,-36(s0)
 c6c:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 c6e:	fe043783          	ld	a5,-32(s0)
 c72:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 c74:	853e                	mv	a0,a5
 c76:	00000097          	auipc	ra,0x0
 c7a:	e7a080e7          	jalr	-390(ra) # af0 <free>
  return freep;
 c7e:	00000797          	auipc	a5,0x0
 c82:	3b278793          	addi	a5,a5,946 # 1030 <freep>
 c86:	639c                	ld	a5,0(a5)
}
 c88:	853e                	mv	a0,a5
 c8a:	70a2                	ld	ra,40(sp)
 c8c:	7402                	ld	s0,32(sp)
 c8e:	6145                	addi	sp,sp,48
 c90:	8082                	ret

0000000000000c92 <malloc>:

void*
malloc(uint nbytes)
{
 c92:	7139                	addi	sp,sp,-64
 c94:	fc06                	sd	ra,56(sp)
 c96:	f822                	sd	s0,48(sp)
 c98:	0080                	addi	s0,sp,64
 c9a:	87aa                	mv	a5,a0
 c9c:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ca0:	fcc46783          	lwu	a5,-52(s0)
 ca4:	07bd                	addi	a5,a5,15
 ca6:	8391                	srli	a5,a5,0x4
 ca8:	2781                	sext.w	a5,a5
 caa:	2785                	addiw	a5,a5,1
 cac:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 cb0:	00000797          	auipc	a5,0x0
 cb4:	38078793          	addi	a5,a5,896 # 1030 <freep>
 cb8:	639c                	ld	a5,0(a5)
 cba:	fef43023          	sd	a5,-32(s0)
 cbe:	fe043783          	ld	a5,-32(s0)
 cc2:	ef95                	bnez	a5,cfe <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 cc4:	00000797          	auipc	a5,0x0
 cc8:	35c78793          	addi	a5,a5,860 # 1020 <base>
 ccc:	fef43023          	sd	a5,-32(s0)
 cd0:	00000797          	auipc	a5,0x0
 cd4:	36078793          	addi	a5,a5,864 # 1030 <freep>
 cd8:	fe043703          	ld	a4,-32(s0)
 cdc:	e398                	sd	a4,0(a5)
 cde:	00000797          	auipc	a5,0x0
 ce2:	35278793          	addi	a5,a5,850 # 1030 <freep>
 ce6:	6398                	ld	a4,0(a5)
 ce8:	00000797          	auipc	a5,0x0
 cec:	33878793          	addi	a5,a5,824 # 1020 <base>
 cf0:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 cf2:	00000797          	auipc	a5,0x0
 cf6:	32e78793          	addi	a5,a5,814 # 1020 <base>
 cfa:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cfe:	fe043783          	ld	a5,-32(s0)
 d02:	639c                	ld	a5,0(a5)
 d04:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 d08:	fe843783          	ld	a5,-24(s0)
 d0c:	4798                	lw	a4,8(a5)
 d0e:	fdc42783          	lw	a5,-36(s0)
 d12:	2781                	sext.w	a5,a5
 d14:	06f76763          	bltu	a4,a5,d82 <malloc+0xf0>
      if(p->s.size == nunits)
 d18:	fe843783          	ld	a5,-24(s0)
 d1c:	4798                	lw	a4,8(a5)
 d1e:	fdc42783          	lw	a5,-36(s0)
 d22:	2781                	sext.w	a5,a5
 d24:	00e79963          	bne	a5,a4,d36 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 d28:	fe843783          	ld	a5,-24(s0)
 d2c:	6398                	ld	a4,0(a5)
 d2e:	fe043783          	ld	a5,-32(s0)
 d32:	e398                	sd	a4,0(a5)
 d34:	a825                	j	d6c <malloc+0xda>
      else {
        p->s.size -= nunits;
 d36:	fe843783          	ld	a5,-24(s0)
 d3a:	479c                	lw	a5,8(a5)
 d3c:	fdc42703          	lw	a4,-36(s0)
 d40:	9f99                	subw	a5,a5,a4
 d42:	0007871b          	sext.w	a4,a5
 d46:	fe843783          	ld	a5,-24(s0)
 d4a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d4c:	fe843783          	ld	a5,-24(s0)
 d50:	479c                	lw	a5,8(a5)
 d52:	1782                	slli	a5,a5,0x20
 d54:	9381                	srli	a5,a5,0x20
 d56:	0792                	slli	a5,a5,0x4
 d58:	fe843703          	ld	a4,-24(s0)
 d5c:	97ba                	add	a5,a5,a4
 d5e:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 d62:	fe843783          	ld	a5,-24(s0)
 d66:	fdc42703          	lw	a4,-36(s0)
 d6a:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 d6c:	00000797          	auipc	a5,0x0
 d70:	2c478793          	addi	a5,a5,708 # 1030 <freep>
 d74:	fe043703          	ld	a4,-32(s0)
 d78:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 d7a:	fe843783          	ld	a5,-24(s0)
 d7e:	07c1                	addi	a5,a5,16
 d80:	a091                	j	dc4 <malloc+0x132>
    }
    if(p == freep)
 d82:	00000797          	auipc	a5,0x0
 d86:	2ae78793          	addi	a5,a5,686 # 1030 <freep>
 d8a:	639c                	ld	a5,0(a5)
 d8c:	fe843703          	ld	a4,-24(s0)
 d90:	02f71063          	bne	a4,a5,db0 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 d94:	fdc42783          	lw	a5,-36(s0)
 d98:	853e                	mv	a0,a5
 d9a:	00000097          	auipc	ra,0x0
 d9e:	e78080e7          	jalr	-392(ra) # c12 <morecore>
 da2:	fea43423          	sd	a0,-24(s0)
 da6:	fe843783          	ld	a5,-24(s0)
 daa:	e399                	bnez	a5,db0 <malloc+0x11e>
        return 0;
 dac:	4781                	li	a5,0
 dae:	a819                	j	dc4 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 db0:	fe843783          	ld	a5,-24(s0)
 db4:	fef43023          	sd	a5,-32(s0)
 db8:	fe843783          	ld	a5,-24(s0)
 dbc:	639c                	ld	a5,0(a5)
 dbe:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 dc2:	b799                	j	d08 <malloc+0x76>
  }
}
 dc4:	853e                	mv	a0,a5
 dc6:	70e2                	ld	ra,56(sp)
 dc8:	7442                	ld	s0,48(sp)
 dca:	6121                	addi	sp,sp,64
 dcc:	8082                	ret
