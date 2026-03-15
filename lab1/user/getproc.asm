
user/_getproc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
   8:	87aa                	mv	a5,a0
   a:	fcb43823          	sd	a1,-48(s0)
   e:	fcf42e23          	sw	a5,-36(s0)
	int info[2]; 
	int exitStatus = getproc(info);
  12:	fe040793          	addi	a5,s0,-32
  16:	853e                	mv	a0,a5
  18:	00000097          	auipc	ra,0x0
  1c:	5a0080e7          	jalr	1440(ra) # 5b8 <getproc>
  20:	87aa                	mv	a5,a0
  22:	fef42623          	sw	a5,-20(s0)
	if (exitStatus != 0) {
  26:	fec42783          	lw	a5,-20(s0)
  2a:	2781                	sext.w	a5,a5
  2c:	c781                	beqz	a5,34 <main+0x34>
		return exitStatus;
  2e:	fec42783          	lw	a5,-20(s0)
  32:	a005                	j	52 <main+0x52>
	}
	printf("pid: %d, state: %d\n", info[0], info[1]);
  34:	fe042783          	lw	a5,-32(s0)
  38:	fe442703          	lw	a4,-28(s0)
  3c:	863a                	mv	a2,a4
  3e:	85be                	mv	a1,a5
  40:	00001517          	auipc	a0,0x1
  44:	d4050513          	addi	a0,a0,-704 # d80 <malloc+0x13e>
  48:	00001097          	auipc	ra,0x1
  4c:	a08080e7          	jalr	-1528(ra) # a50 <printf>
	return 0;
  50:	4781                	li	a5,0
}
  52:	853e                	mv	a0,a5
  54:	70a2                	ld	ra,40(sp)
  56:	7402                	ld	s0,32(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret

000000000000005c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e406                	sd	ra,8(sp)
  60:	e022                	sd	s0,0(sp)
  62:	0800                	addi	s0,sp,16
  extern int main();
  main();
  64:	00000097          	auipc	ra,0x0
  68:	f9c080e7          	jalr	-100(ra) # 0 <main>
  exit(0);
  6c:	4501                	li	a0,0
  6e:	00000097          	auipc	ra,0x0
  72:	49a080e7          	jalr	1178(ra) # 508 <exit>

0000000000000076 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  76:	7179                	addi	sp,sp,-48
  78:	f422                	sd	s0,40(sp)
  7a:	1800                	addi	s0,sp,48
  7c:	fca43c23          	sd	a0,-40(s0)
  80:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
  84:	fd843783          	ld	a5,-40(s0)
  88:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
  8c:	0001                	nop
  8e:	fd043703          	ld	a4,-48(s0)
  92:	00170793          	addi	a5,a4,1
  96:	fcf43823          	sd	a5,-48(s0)
  9a:	fd843783          	ld	a5,-40(s0)
  9e:	00178693          	addi	a3,a5,1
  a2:	fcd43c23          	sd	a3,-40(s0)
  a6:	00074703          	lbu	a4,0(a4)
  aa:	00e78023          	sb	a4,0(a5)
  ae:	0007c783          	lbu	a5,0(a5)
  b2:	fff1                	bnez	a5,8e <strcpy+0x18>
    ;
  return os;
  b4:	fe843783          	ld	a5,-24(s0)
}
  b8:	853e                	mv	a0,a5
  ba:	7422                	ld	s0,40(sp)
  bc:	6145                	addi	sp,sp,48
  be:	8082                	ret

00000000000000c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec22                	sd	s0,24(sp)
  c4:	1000                	addi	s0,sp,32
  c6:	fea43423          	sd	a0,-24(s0)
  ca:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
  ce:	a819                	j	e4 <strcmp+0x24>
    p++, q++;
  d0:	fe843783          	ld	a5,-24(s0)
  d4:	0785                	addi	a5,a5,1
  d6:	fef43423          	sd	a5,-24(s0)
  da:	fe043783          	ld	a5,-32(s0)
  de:	0785                	addi	a5,a5,1
  e0:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
  e4:	fe843783          	ld	a5,-24(s0)
  e8:	0007c783          	lbu	a5,0(a5)
  ec:	cb99                	beqz	a5,102 <strcmp+0x42>
  ee:	fe843783          	ld	a5,-24(s0)
  f2:	0007c703          	lbu	a4,0(a5)
  f6:	fe043783          	ld	a5,-32(s0)
  fa:	0007c783          	lbu	a5,0(a5)
  fe:	fcf709e3          	beq	a4,a5,d0 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 102:	fe843783          	ld	a5,-24(s0)
 106:	0007c783          	lbu	a5,0(a5)
 10a:	0007871b          	sext.w	a4,a5
 10e:	fe043783          	ld	a5,-32(s0)
 112:	0007c783          	lbu	a5,0(a5)
 116:	2781                	sext.w	a5,a5
 118:	40f707bb          	subw	a5,a4,a5
 11c:	2781                	sext.w	a5,a5
}
 11e:	853e                	mv	a0,a5
 120:	6462                	ld	s0,24(sp)
 122:	6105                	addi	sp,sp,32
 124:	8082                	ret

0000000000000126 <strlen>:

uint
strlen(const char *s)
{
 126:	7179                	addi	sp,sp,-48
 128:	f422                	sd	s0,40(sp)
 12a:	1800                	addi	s0,sp,48
 12c:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 130:	fe042623          	sw	zero,-20(s0)
 134:	a031                	j	140 <strlen+0x1a>
 136:	fec42783          	lw	a5,-20(s0)
 13a:	2785                	addiw	a5,a5,1
 13c:	fef42623          	sw	a5,-20(s0)
 140:	fec42783          	lw	a5,-20(s0)
 144:	fd843703          	ld	a4,-40(s0)
 148:	97ba                	add	a5,a5,a4
 14a:	0007c783          	lbu	a5,0(a5)
 14e:	f7e5                	bnez	a5,136 <strlen+0x10>
    ;
  return n;
 150:	fec42783          	lw	a5,-20(s0)
}
 154:	853e                	mv	a0,a5
 156:	7422                	ld	s0,40(sp)
 158:	6145                	addi	sp,sp,48
 15a:	8082                	ret

000000000000015c <memset>:

void*
memset(void *dst, int c, uint n)
{
 15c:	7179                	addi	sp,sp,-48
 15e:	f422                	sd	s0,40(sp)
 160:	1800                	addi	s0,sp,48
 162:	fca43c23          	sd	a0,-40(s0)
 166:	87ae                	mv	a5,a1
 168:	8732                	mv	a4,a2
 16a:	fcf42a23          	sw	a5,-44(s0)
 16e:	87ba                	mv	a5,a4
 170:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 174:	fd843783          	ld	a5,-40(s0)
 178:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 17c:	fe042623          	sw	zero,-20(s0)
 180:	a00d                	j	1a2 <memset+0x46>
    cdst[i] = c;
 182:	fec42783          	lw	a5,-20(s0)
 186:	fe043703          	ld	a4,-32(s0)
 18a:	97ba                	add	a5,a5,a4
 18c:	fd442703          	lw	a4,-44(s0)
 190:	0ff77713          	zext.b	a4,a4
 194:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 198:	fec42783          	lw	a5,-20(s0)
 19c:	2785                	addiw	a5,a5,1
 19e:	fef42623          	sw	a5,-20(s0)
 1a2:	fec42703          	lw	a4,-20(s0)
 1a6:	fd042783          	lw	a5,-48(s0)
 1aa:	2781                	sext.w	a5,a5
 1ac:	fcf76be3          	bltu	a4,a5,182 <memset+0x26>
  }
  return dst;
 1b0:	fd843783          	ld	a5,-40(s0)
}
 1b4:	853e                	mv	a0,a5
 1b6:	7422                	ld	s0,40(sp)
 1b8:	6145                	addi	sp,sp,48
 1ba:	8082                	ret

00000000000001bc <strchr>:

char*
strchr(const char *s, char c)
{
 1bc:	1101                	addi	sp,sp,-32
 1be:	ec22                	sd	s0,24(sp)
 1c0:	1000                	addi	s0,sp,32
 1c2:	fea43423          	sd	a0,-24(s0)
 1c6:	87ae                	mv	a5,a1
 1c8:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 1cc:	a01d                	j	1f2 <strchr+0x36>
    if(*s == c)
 1ce:	fe843783          	ld	a5,-24(s0)
 1d2:	0007c703          	lbu	a4,0(a5)
 1d6:	fe744783          	lbu	a5,-25(s0)
 1da:	0ff7f793          	zext.b	a5,a5
 1de:	00e79563          	bne	a5,a4,1e8 <strchr+0x2c>
      return (char*)s;
 1e2:	fe843783          	ld	a5,-24(s0)
 1e6:	a821                	j	1fe <strchr+0x42>
  for(; *s; s++)
 1e8:	fe843783          	ld	a5,-24(s0)
 1ec:	0785                	addi	a5,a5,1
 1ee:	fef43423          	sd	a5,-24(s0)
 1f2:	fe843783          	ld	a5,-24(s0)
 1f6:	0007c783          	lbu	a5,0(a5)
 1fa:	fbf1                	bnez	a5,1ce <strchr+0x12>
  return 0;
 1fc:	4781                	li	a5,0
}
 1fe:	853e                	mv	a0,a5
 200:	6462                	ld	s0,24(sp)
 202:	6105                	addi	sp,sp,32
 204:	8082                	ret

0000000000000206 <gets>:

char*
gets(char *buf, int max)
{
 206:	7179                	addi	sp,sp,-48
 208:	f406                	sd	ra,40(sp)
 20a:	f022                	sd	s0,32(sp)
 20c:	1800                	addi	s0,sp,48
 20e:	fca43c23          	sd	a0,-40(s0)
 212:	87ae                	mv	a5,a1
 214:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 218:	fe042623          	sw	zero,-20(s0)
 21c:	a8a1                	j	274 <gets+0x6e>
    cc = read(0, &c, 1);
 21e:	fe740793          	addi	a5,s0,-25
 222:	4605                	li	a2,1
 224:	85be                	mv	a1,a5
 226:	4501                	li	a0,0
 228:	00000097          	auipc	ra,0x0
 22c:	2f8080e7          	jalr	760(ra) # 520 <read>
 230:	87aa                	mv	a5,a0
 232:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 236:	fe842783          	lw	a5,-24(s0)
 23a:	2781                	sext.w	a5,a5
 23c:	04f05763          	blez	a5,28a <gets+0x84>
      break;
    buf[i++] = c;
 240:	fec42783          	lw	a5,-20(s0)
 244:	0017871b          	addiw	a4,a5,1
 248:	fee42623          	sw	a4,-20(s0)
 24c:	873e                	mv	a4,a5
 24e:	fd843783          	ld	a5,-40(s0)
 252:	97ba                	add	a5,a5,a4
 254:	fe744703          	lbu	a4,-25(s0)
 258:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 25c:	fe744783          	lbu	a5,-25(s0)
 260:	873e                	mv	a4,a5
 262:	47a9                	li	a5,10
 264:	02f70463          	beq	a4,a5,28c <gets+0x86>
 268:	fe744783          	lbu	a5,-25(s0)
 26c:	873e                	mv	a4,a5
 26e:	47b5                	li	a5,13
 270:	00f70e63          	beq	a4,a5,28c <gets+0x86>
  for(i=0; i+1 < max; ){
 274:	fec42783          	lw	a5,-20(s0)
 278:	2785                	addiw	a5,a5,1
 27a:	0007871b          	sext.w	a4,a5
 27e:	fd442783          	lw	a5,-44(s0)
 282:	2781                	sext.w	a5,a5
 284:	f8f74de3          	blt	a4,a5,21e <gets+0x18>
 288:	a011                	j	28c <gets+0x86>
      break;
 28a:	0001                	nop
      break;
  }
  buf[i] = '\0';
 28c:	fec42783          	lw	a5,-20(s0)
 290:	fd843703          	ld	a4,-40(s0)
 294:	97ba                	add	a5,a5,a4
 296:	00078023          	sb	zero,0(a5)
  return buf;
 29a:	fd843783          	ld	a5,-40(s0)
}
 29e:	853e                	mv	a0,a5
 2a0:	70a2                	ld	ra,40(sp)
 2a2:	7402                	ld	s0,32(sp)
 2a4:	6145                	addi	sp,sp,48
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	7179                	addi	sp,sp,-48
 2aa:	f406                	sd	ra,40(sp)
 2ac:	f022                	sd	s0,32(sp)
 2ae:	1800                	addi	s0,sp,48
 2b0:	fca43c23          	sd	a0,-40(s0)
 2b4:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	fd843503          	ld	a0,-40(s0)
 2be:	00000097          	auipc	ra,0x0
 2c2:	28a080e7          	jalr	650(ra) # 548 <open>
 2c6:	87aa                	mv	a5,a0
 2c8:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 2cc:	fec42783          	lw	a5,-20(s0)
 2d0:	2781                	sext.w	a5,a5
 2d2:	0007d463          	bgez	a5,2da <stat+0x32>
    return -1;
 2d6:	57fd                	li	a5,-1
 2d8:	a035                	j	304 <stat+0x5c>
  r = fstat(fd, st);
 2da:	fec42783          	lw	a5,-20(s0)
 2de:	fd043583          	ld	a1,-48(s0)
 2e2:	853e                	mv	a0,a5
 2e4:	00000097          	auipc	ra,0x0
 2e8:	27c080e7          	jalr	636(ra) # 560 <fstat>
 2ec:	87aa                	mv	a5,a0
 2ee:	fef42423          	sw	a5,-24(s0)
  close(fd);
 2f2:	fec42783          	lw	a5,-20(s0)
 2f6:	853e                	mv	a0,a5
 2f8:	00000097          	auipc	ra,0x0
 2fc:	238080e7          	jalr	568(ra) # 530 <close>
  return r;
 300:	fe842783          	lw	a5,-24(s0)
}
 304:	853e                	mv	a0,a5
 306:	70a2                	ld	ra,40(sp)
 308:	7402                	ld	s0,32(sp)
 30a:	6145                	addi	sp,sp,48
 30c:	8082                	ret

000000000000030e <atoi>:

int
atoi(const char *s)
{
 30e:	7179                	addi	sp,sp,-48
 310:	f422                	sd	s0,40(sp)
 312:	1800                	addi	s0,sp,48
 314:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 318:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 31c:	a81d                	j	352 <atoi+0x44>
    n = n*10 + *s++ - '0';
 31e:	fec42783          	lw	a5,-20(s0)
 322:	873e                	mv	a4,a5
 324:	87ba                	mv	a5,a4
 326:	0027979b          	slliw	a5,a5,0x2
 32a:	9fb9                	addw	a5,a5,a4
 32c:	0017979b          	slliw	a5,a5,0x1
 330:	0007871b          	sext.w	a4,a5
 334:	fd843783          	ld	a5,-40(s0)
 338:	00178693          	addi	a3,a5,1
 33c:	fcd43c23          	sd	a3,-40(s0)
 340:	0007c783          	lbu	a5,0(a5)
 344:	2781                	sext.w	a5,a5
 346:	9fb9                	addw	a5,a5,a4
 348:	2781                	sext.w	a5,a5
 34a:	fd07879b          	addiw	a5,a5,-48
 34e:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 352:	fd843783          	ld	a5,-40(s0)
 356:	0007c783          	lbu	a5,0(a5)
 35a:	873e                	mv	a4,a5
 35c:	02f00793          	li	a5,47
 360:	00e7fb63          	bgeu	a5,a4,376 <atoi+0x68>
 364:	fd843783          	ld	a5,-40(s0)
 368:	0007c783          	lbu	a5,0(a5)
 36c:	873e                	mv	a4,a5
 36e:	03900793          	li	a5,57
 372:	fae7f6e3          	bgeu	a5,a4,31e <atoi+0x10>
  return n;
 376:	fec42783          	lw	a5,-20(s0)
}
 37a:	853e                	mv	a0,a5
 37c:	7422                	ld	s0,40(sp)
 37e:	6145                	addi	sp,sp,48
 380:	8082                	ret

0000000000000382 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 382:	7139                	addi	sp,sp,-64
 384:	fc22                	sd	s0,56(sp)
 386:	0080                	addi	s0,sp,64
 388:	fca43c23          	sd	a0,-40(s0)
 38c:	fcb43823          	sd	a1,-48(s0)
 390:	87b2                	mv	a5,a2
 392:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 396:	fd843783          	ld	a5,-40(s0)
 39a:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 39e:	fd043783          	ld	a5,-48(s0)
 3a2:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 3a6:	fe043703          	ld	a4,-32(s0)
 3aa:	fe843783          	ld	a5,-24(s0)
 3ae:	02e7fc63          	bgeu	a5,a4,3e6 <memmove+0x64>
    while(n-- > 0)
 3b2:	a00d                	j	3d4 <memmove+0x52>
      *dst++ = *src++;
 3b4:	fe043703          	ld	a4,-32(s0)
 3b8:	00170793          	addi	a5,a4,1
 3bc:	fef43023          	sd	a5,-32(s0)
 3c0:	fe843783          	ld	a5,-24(s0)
 3c4:	00178693          	addi	a3,a5,1
 3c8:	fed43423          	sd	a3,-24(s0)
 3cc:	00074703          	lbu	a4,0(a4)
 3d0:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 3d4:	fcc42783          	lw	a5,-52(s0)
 3d8:	fff7871b          	addiw	a4,a5,-1
 3dc:	fce42623          	sw	a4,-52(s0)
 3e0:	fcf04ae3          	bgtz	a5,3b4 <memmove+0x32>
 3e4:	a891                	j	438 <memmove+0xb6>
  } else {
    dst += n;
 3e6:	fcc42783          	lw	a5,-52(s0)
 3ea:	fe843703          	ld	a4,-24(s0)
 3ee:	97ba                	add	a5,a5,a4
 3f0:	fef43423          	sd	a5,-24(s0)
    src += n;
 3f4:	fcc42783          	lw	a5,-52(s0)
 3f8:	fe043703          	ld	a4,-32(s0)
 3fc:	97ba                	add	a5,a5,a4
 3fe:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 402:	a01d                	j	428 <memmove+0xa6>
      *--dst = *--src;
 404:	fe043783          	ld	a5,-32(s0)
 408:	17fd                	addi	a5,a5,-1
 40a:	fef43023          	sd	a5,-32(s0)
 40e:	fe843783          	ld	a5,-24(s0)
 412:	17fd                	addi	a5,a5,-1
 414:	fef43423          	sd	a5,-24(s0)
 418:	fe043783          	ld	a5,-32(s0)
 41c:	0007c703          	lbu	a4,0(a5)
 420:	fe843783          	ld	a5,-24(s0)
 424:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 428:	fcc42783          	lw	a5,-52(s0)
 42c:	fff7871b          	addiw	a4,a5,-1
 430:	fce42623          	sw	a4,-52(s0)
 434:	fcf048e3          	bgtz	a5,404 <memmove+0x82>
  }
  return vdst;
 438:	fd843783          	ld	a5,-40(s0)
}
 43c:	853e                	mv	a0,a5
 43e:	7462                	ld	s0,56(sp)
 440:	6121                	addi	sp,sp,64
 442:	8082                	ret

0000000000000444 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 444:	7139                	addi	sp,sp,-64
 446:	fc22                	sd	s0,56(sp)
 448:	0080                	addi	s0,sp,64
 44a:	fca43c23          	sd	a0,-40(s0)
 44e:	fcb43823          	sd	a1,-48(s0)
 452:	87b2                	mv	a5,a2
 454:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 458:	fd843783          	ld	a5,-40(s0)
 45c:	fef43423          	sd	a5,-24(s0)
 460:	fd043783          	ld	a5,-48(s0)
 464:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 468:	a0a1                	j	4b0 <memcmp+0x6c>
    if (*p1 != *p2) {
 46a:	fe843783          	ld	a5,-24(s0)
 46e:	0007c703          	lbu	a4,0(a5)
 472:	fe043783          	ld	a5,-32(s0)
 476:	0007c783          	lbu	a5,0(a5)
 47a:	02f70163          	beq	a4,a5,49c <memcmp+0x58>
      return *p1 - *p2;
 47e:	fe843783          	ld	a5,-24(s0)
 482:	0007c783          	lbu	a5,0(a5)
 486:	0007871b          	sext.w	a4,a5
 48a:	fe043783          	ld	a5,-32(s0)
 48e:	0007c783          	lbu	a5,0(a5)
 492:	2781                	sext.w	a5,a5
 494:	40f707bb          	subw	a5,a4,a5
 498:	2781                	sext.w	a5,a5
 49a:	a01d                	j	4c0 <memcmp+0x7c>
    }
    p1++;
 49c:	fe843783          	ld	a5,-24(s0)
 4a0:	0785                	addi	a5,a5,1
 4a2:	fef43423          	sd	a5,-24(s0)
    p2++;
 4a6:	fe043783          	ld	a5,-32(s0)
 4aa:	0785                	addi	a5,a5,1
 4ac:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 4b0:	fcc42783          	lw	a5,-52(s0)
 4b4:	fff7871b          	addiw	a4,a5,-1
 4b8:	fce42623          	sw	a4,-52(s0)
 4bc:	f7dd                	bnez	a5,46a <memcmp+0x26>
  }
  return 0;
 4be:	4781                	li	a5,0
}
 4c0:	853e                	mv	a0,a5
 4c2:	7462                	ld	s0,56(sp)
 4c4:	6121                	addi	sp,sp,64
 4c6:	8082                	ret

00000000000004c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4c8:	7179                	addi	sp,sp,-48
 4ca:	f406                	sd	ra,40(sp)
 4cc:	f022                	sd	s0,32(sp)
 4ce:	1800                	addi	s0,sp,48
 4d0:	fea43423          	sd	a0,-24(s0)
 4d4:	feb43023          	sd	a1,-32(s0)
 4d8:	87b2                	mv	a5,a2
 4da:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 4de:	fdc42783          	lw	a5,-36(s0)
 4e2:	863e                	mv	a2,a5
 4e4:	fe043583          	ld	a1,-32(s0)
 4e8:	fe843503          	ld	a0,-24(s0)
 4ec:	00000097          	auipc	ra,0x0
 4f0:	e96080e7          	jalr	-362(ra) # 382 <memmove>
 4f4:	87aa                	mv	a5,a0
}
 4f6:	853e                	mv	a0,a5
 4f8:	70a2                	ld	ra,40(sp)
 4fa:	7402                	ld	s0,32(sp)
 4fc:	6145                	addi	sp,sp,48
 4fe:	8082                	ret

0000000000000500 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 500:	4885                	li	a7,1
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <exit>:
.global exit
exit:
 li a7, SYS_exit
 508:	4889                	li	a7,2
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <wait>:
.global wait
wait:
 li a7, SYS_wait
 510:	488d                	li	a7,3
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 518:	4891                	li	a7,4
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <read>:
.global read
read:
 li a7, SYS_read
 520:	4895                	li	a7,5
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <write>:
.global write
write:
 li a7, SYS_write
 528:	48c1                	li	a7,16
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <close>:
.global close
close:
 li a7, SYS_close
 530:	48d5                	li	a7,21
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <kill>:
.global kill
kill:
 li a7, SYS_kill
 538:	4899                	li	a7,6
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <exec>:
.global exec
exec:
 li a7, SYS_exec
 540:	489d                	li	a7,7
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <open>:
.global open
open:
 li a7, SYS_open
 548:	48bd                	li	a7,15
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 550:	48c5                	li	a7,17
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 558:	48c9                	li	a7,18
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 560:	48a1                	li	a7,8
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <link>:
.global link
link:
 li a7, SYS_link
 568:	48cd                	li	a7,19
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 570:	48d1                	li	a7,20
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 578:	48a5                	li	a7,9
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <dup>:
.global dup
dup:
 li a7, SYS_dup
 580:	48a9                	li	a7,10
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 588:	48ad                	li	a7,11
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 590:	48b1                	li	a7,12
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 598:	48b5                	li	a7,13
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5a0:	48b9                	li	a7,14
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <hello>:
.global hello
hello:
 li a7, SYS_hello
 5a8:	48d9                	li	a7,22
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <ps>:
.global ps
ps:
 li a7, SYS_ps
 5b0:	48e1                	li	a7,24
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 5b8:	48dd                	li	a7,23
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 5c0:	48e5                	li	a7,25
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5c8:	1101                	addi	sp,sp,-32
 5ca:	ec06                	sd	ra,24(sp)
 5cc:	e822                	sd	s0,16(sp)
 5ce:	1000                	addi	s0,sp,32
 5d0:	87aa                	mv	a5,a0
 5d2:	872e                	mv	a4,a1
 5d4:	fef42623          	sw	a5,-20(s0)
 5d8:	87ba                	mv	a5,a4
 5da:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 5de:	feb40713          	addi	a4,s0,-21
 5e2:	fec42783          	lw	a5,-20(s0)
 5e6:	4605                	li	a2,1
 5e8:	85ba                	mv	a1,a4
 5ea:	853e                	mv	a0,a5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	f3c080e7          	jalr	-196(ra) # 528 <write>
}
 5f4:	0001                	nop
 5f6:	60e2                	ld	ra,24(sp)
 5f8:	6442                	ld	s0,16(sp)
 5fa:	6105                	addi	sp,sp,32
 5fc:	8082                	ret

00000000000005fe <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5fe:	7139                	addi	sp,sp,-64
 600:	fc06                	sd	ra,56(sp)
 602:	f822                	sd	s0,48(sp)
 604:	0080                	addi	s0,sp,64
 606:	87aa                	mv	a5,a0
 608:	8736                	mv	a4,a3
 60a:	fcf42623          	sw	a5,-52(s0)
 60e:	87ae                	mv	a5,a1
 610:	fcf42423          	sw	a5,-56(s0)
 614:	87b2                	mv	a5,a2
 616:	fcf42223          	sw	a5,-60(s0)
 61a:	87ba                	mv	a5,a4
 61c:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 620:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 624:	fc042783          	lw	a5,-64(s0)
 628:	2781                	sext.w	a5,a5
 62a:	c38d                	beqz	a5,64c <printint+0x4e>
 62c:	fc842783          	lw	a5,-56(s0)
 630:	2781                	sext.w	a5,a5
 632:	0007dd63          	bgez	a5,64c <printint+0x4e>
    neg = 1;
 636:	4785                	li	a5,1
 638:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 63c:	fc842783          	lw	a5,-56(s0)
 640:	40f007bb          	negw	a5,a5
 644:	2781                	sext.w	a5,a5
 646:	fef42223          	sw	a5,-28(s0)
 64a:	a029                	j	654 <printint+0x56>
  } else {
    x = xx;
 64c:	fc842783          	lw	a5,-56(s0)
 650:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 654:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 658:	fc442783          	lw	a5,-60(s0)
 65c:	fe442703          	lw	a4,-28(s0)
 660:	02f777bb          	remuw	a5,a4,a5
 664:	0007861b          	sext.w	a2,a5
 668:	fec42783          	lw	a5,-20(s0)
 66c:	0017871b          	addiw	a4,a5,1
 670:	fee42623          	sw	a4,-20(s0)
 674:	00001697          	auipc	a3,0x1
 678:	98c68693          	addi	a3,a3,-1652 # 1000 <digits>
 67c:	02061713          	slli	a4,a2,0x20
 680:	9301                	srli	a4,a4,0x20
 682:	9736                	add	a4,a4,a3
 684:	00074703          	lbu	a4,0(a4)
 688:	17c1                	addi	a5,a5,-16
 68a:	97a2                	add	a5,a5,s0
 68c:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 690:	fc442783          	lw	a5,-60(s0)
 694:	fe442703          	lw	a4,-28(s0)
 698:	02f757bb          	divuw	a5,a4,a5
 69c:	fef42223          	sw	a5,-28(s0)
 6a0:	fe442783          	lw	a5,-28(s0)
 6a4:	2781                	sext.w	a5,a5
 6a6:	fbcd                	bnez	a5,658 <printint+0x5a>
  if(neg)
 6a8:	fe842783          	lw	a5,-24(s0)
 6ac:	2781                	sext.w	a5,a5
 6ae:	cf85                	beqz	a5,6e6 <printint+0xe8>
    buf[i++] = '-';
 6b0:	fec42783          	lw	a5,-20(s0)
 6b4:	0017871b          	addiw	a4,a5,1
 6b8:	fee42623          	sw	a4,-20(s0)
 6bc:	17c1                	addi	a5,a5,-16
 6be:	97a2                	add	a5,a5,s0
 6c0:	02d00713          	li	a4,45
 6c4:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 6c8:	a839                	j	6e6 <printint+0xe8>
    putc(fd, buf[i]);
 6ca:	fec42783          	lw	a5,-20(s0)
 6ce:	17c1                	addi	a5,a5,-16
 6d0:	97a2                	add	a5,a5,s0
 6d2:	fe07c703          	lbu	a4,-32(a5)
 6d6:	fcc42783          	lw	a5,-52(s0)
 6da:	85ba                	mv	a1,a4
 6dc:	853e                	mv	a0,a5
 6de:	00000097          	auipc	ra,0x0
 6e2:	eea080e7          	jalr	-278(ra) # 5c8 <putc>
  while(--i >= 0)
 6e6:	fec42783          	lw	a5,-20(s0)
 6ea:	37fd                	addiw	a5,a5,-1
 6ec:	fef42623          	sw	a5,-20(s0)
 6f0:	fec42783          	lw	a5,-20(s0)
 6f4:	2781                	sext.w	a5,a5
 6f6:	fc07dae3          	bgez	a5,6ca <printint+0xcc>
}
 6fa:	0001                	nop
 6fc:	0001                	nop
 6fe:	70e2                	ld	ra,56(sp)
 700:	7442                	ld	s0,48(sp)
 702:	6121                	addi	sp,sp,64
 704:	8082                	ret

0000000000000706 <printptr>:

static void
printptr(int fd, uint64 x) {
 706:	7179                	addi	sp,sp,-48
 708:	f406                	sd	ra,40(sp)
 70a:	f022                	sd	s0,32(sp)
 70c:	1800                	addi	s0,sp,48
 70e:	87aa                	mv	a5,a0
 710:	fcb43823          	sd	a1,-48(s0)
 714:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 718:	fdc42783          	lw	a5,-36(s0)
 71c:	03000593          	li	a1,48
 720:	853e                	mv	a0,a5
 722:	00000097          	auipc	ra,0x0
 726:	ea6080e7          	jalr	-346(ra) # 5c8 <putc>
  putc(fd, 'x');
 72a:	fdc42783          	lw	a5,-36(s0)
 72e:	07800593          	li	a1,120
 732:	853e                	mv	a0,a5
 734:	00000097          	auipc	ra,0x0
 738:	e94080e7          	jalr	-364(ra) # 5c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73c:	fe042623          	sw	zero,-20(s0)
 740:	a82d                	j	77a <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 742:	fd043783          	ld	a5,-48(s0)
 746:	93f1                	srli	a5,a5,0x3c
 748:	00001717          	auipc	a4,0x1
 74c:	8b870713          	addi	a4,a4,-1864 # 1000 <digits>
 750:	97ba                	add	a5,a5,a4
 752:	0007c703          	lbu	a4,0(a5)
 756:	fdc42783          	lw	a5,-36(s0)
 75a:	85ba                	mv	a1,a4
 75c:	853e                	mv	a0,a5
 75e:	00000097          	auipc	ra,0x0
 762:	e6a080e7          	jalr	-406(ra) # 5c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 766:	fec42783          	lw	a5,-20(s0)
 76a:	2785                	addiw	a5,a5,1
 76c:	fef42623          	sw	a5,-20(s0)
 770:	fd043783          	ld	a5,-48(s0)
 774:	0792                	slli	a5,a5,0x4
 776:	fcf43823          	sd	a5,-48(s0)
 77a:	fec42783          	lw	a5,-20(s0)
 77e:	873e                	mv	a4,a5
 780:	47bd                	li	a5,15
 782:	fce7f0e3          	bgeu	a5,a4,742 <printptr+0x3c>
}
 786:	0001                	nop
 788:	0001                	nop
 78a:	70a2                	ld	ra,40(sp)
 78c:	7402                	ld	s0,32(sp)
 78e:	6145                	addi	sp,sp,48
 790:	8082                	ret

0000000000000792 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 792:	715d                	addi	sp,sp,-80
 794:	e486                	sd	ra,72(sp)
 796:	e0a2                	sd	s0,64(sp)
 798:	0880                	addi	s0,sp,80
 79a:	87aa                	mv	a5,a0
 79c:	fcb43023          	sd	a1,-64(s0)
 7a0:	fac43c23          	sd	a2,-72(s0)
 7a4:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 7a8:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 7ac:	fe042223          	sw	zero,-28(s0)
 7b0:	a42d                	j	9da <vprintf+0x248>
    c = fmt[i] & 0xff;
 7b2:	fe442783          	lw	a5,-28(s0)
 7b6:	fc043703          	ld	a4,-64(s0)
 7ba:	97ba                	add	a5,a5,a4
 7bc:	0007c783          	lbu	a5,0(a5)
 7c0:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 7c4:	fe042783          	lw	a5,-32(s0)
 7c8:	2781                	sext.w	a5,a5
 7ca:	eb9d                	bnez	a5,800 <vprintf+0x6e>
      if(c == '%'){
 7cc:	fdc42783          	lw	a5,-36(s0)
 7d0:	0007871b          	sext.w	a4,a5
 7d4:	02500793          	li	a5,37
 7d8:	00f71763          	bne	a4,a5,7e6 <vprintf+0x54>
        state = '%';
 7dc:	02500793          	li	a5,37
 7e0:	fef42023          	sw	a5,-32(s0)
 7e4:	a2f5                	j	9d0 <vprintf+0x23e>
      } else {
        putc(fd, c);
 7e6:	fdc42783          	lw	a5,-36(s0)
 7ea:	0ff7f713          	zext.b	a4,a5
 7ee:	fcc42783          	lw	a5,-52(s0)
 7f2:	85ba                	mv	a1,a4
 7f4:	853e                	mv	a0,a5
 7f6:	00000097          	auipc	ra,0x0
 7fa:	dd2080e7          	jalr	-558(ra) # 5c8 <putc>
 7fe:	aac9                	j	9d0 <vprintf+0x23e>
      }
    } else if(state == '%'){
 800:	fe042783          	lw	a5,-32(s0)
 804:	0007871b          	sext.w	a4,a5
 808:	02500793          	li	a5,37
 80c:	1cf71263          	bne	a4,a5,9d0 <vprintf+0x23e>
      if(c == 'd'){
 810:	fdc42783          	lw	a5,-36(s0)
 814:	0007871b          	sext.w	a4,a5
 818:	06400793          	li	a5,100
 81c:	02f71463          	bne	a4,a5,844 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 820:	fb843783          	ld	a5,-72(s0)
 824:	00878713          	addi	a4,a5,8
 828:	fae43c23          	sd	a4,-72(s0)
 82c:	4398                	lw	a4,0(a5)
 82e:	fcc42783          	lw	a5,-52(s0)
 832:	4685                	li	a3,1
 834:	4629                	li	a2,10
 836:	85ba                	mv	a1,a4
 838:	853e                	mv	a0,a5
 83a:	00000097          	auipc	ra,0x0
 83e:	dc4080e7          	jalr	-572(ra) # 5fe <printint>
 842:	a269                	j	9cc <vprintf+0x23a>
      } else if(c == 'l') {
 844:	fdc42783          	lw	a5,-36(s0)
 848:	0007871b          	sext.w	a4,a5
 84c:	06c00793          	li	a5,108
 850:	02f71663          	bne	a4,a5,87c <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 854:	fb843783          	ld	a5,-72(s0)
 858:	00878713          	addi	a4,a5,8
 85c:	fae43c23          	sd	a4,-72(s0)
 860:	639c                	ld	a5,0(a5)
 862:	0007871b          	sext.w	a4,a5
 866:	fcc42783          	lw	a5,-52(s0)
 86a:	4681                	li	a3,0
 86c:	4629                	li	a2,10
 86e:	85ba                	mv	a1,a4
 870:	853e                	mv	a0,a5
 872:	00000097          	auipc	ra,0x0
 876:	d8c080e7          	jalr	-628(ra) # 5fe <printint>
 87a:	aa89                	j	9cc <vprintf+0x23a>
      } else if(c == 'x') {
 87c:	fdc42783          	lw	a5,-36(s0)
 880:	0007871b          	sext.w	a4,a5
 884:	07800793          	li	a5,120
 888:	02f71463          	bne	a4,a5,8b0 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 88c:	fb843783          	ld	a5,-72(s0)
 890:	00878713          	addi	a4,a5,8
 894:	fae43c23          	sd	a4,-72(s0)
 898:	4398                	lw	a4,0(a5)
 89a:	fcc42783          	lw	a5,-52(s0)
 89e:	4681                	li	a3,0
 8a0:	4641                	li	a2,16
 8a2:	85ba                	mv	a1,a4
 8a4:	853e                	mv	a0,a5
 8a6:	00000097          	auipc	ra,0x0
 8aa:	d58080e7          	jalr	-680(ra) # 5fe <printint>
 8ae:	aa39                	j	9cc <vprintf+0x23a>
      } else if(c == 'p') {
 8b0:	fdc42783          	lw	a5,-36(s0)
 8b4:	0007871b          	sext.w	a4,a5
 8b8:	07000793          	li	a5,112
 8bc:	02f71263          	bne	a4,a5,8e0 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 8c0:	fb843783          	ld	a5,-72(s0)
 8c4:	00878713          	addi	a4,a5,8
 8c8:	fae43c23          	sd	a4,-72(s0)
 8cc:	6398                	ld	a4,0(a5)
 8ce:	fcc42783          	lw	a5,-52(s0)
 8d2:	85ba                	mv	a1,a4
 8d4:	853e                	mv	a0,a5
 8d6:	00000097          	auipc	ra,0x0
 8da:	e30080e7          	jalr	-464(ra) # 706 <printptr>
 8de:	a0fd                	j	9cc <vprintf+0x23a>
      } else if(c == 's'){
 8e0:	fdc42783          	lw	a5,-36(s0)
 8e4:	0007871b          	sext.w	a4,a5
 8e8:	07300793          	li	a5,115
 8ec:	04f71c63          	bne	a4,a5,944 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 8f0:	fb843783          	ld	a5,-72(s0)
 8f4:	00878713          	addi	a4,a5,8
 8f8:	fae43c23          	sd	a4,-72(s0)
 8fc:	639c                	ld	a5,0(a5)
 8fe:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 902:	fe843783          	ld	a5,-24(s0)
 906:	eb8d                	bnez	a5,938 <vprintf+0x1a6>
          s = "(null)";
 908:	00000797          	auipc	a5,0x0
 90c:	49078793          	addi	a5,a5,1168 # d98 <malloc+0x156>
 910:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 914:	a015                	j	938 <vprintf+0x1a6>
          putc(fd, *s);
 916:	fe843783          	ld	a5,-24(s0)
 91a:	0007c703          	lbu	a4,0(a5)
 91e:	fcc42783          	lw	a5,-52(s0)
 922:	85ba                	mv	a1,a4
 924:	853e                	mv	a0,a5
 926:	00000097          	auipc	ra,0x0
 92a:	ca2080e7          	jalr	-862(ra) # 5c8 <putc>
          s++;
 92e:	fe843783          	ld	a5,-24(s0)
 932:	0785                	addi	a5,a5,1
 934:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 938:	fe843783          	ld	a5,-24(s0)
 93c:	0007c783          	lbu	a5,0(a5)
 940:	fbf9                	bnez	a5,916 <vprintf+0x184>
 942:	a069                	j	9cc <vprintf+0x23a>
        }
      } else if(c == 'c'){
 944:	fdc42783          	lw	a5,-36(s0)
 948:	0007871b          	sext.w	a4,a5
 94c:	06300793          	li	a5,99
 950:	02f71463          	bne	a4,a5,978 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 954:	fb843783          	ld	a5,-72(s0)
 958:	00878713          	addi	a4,a5,8
 95c:	fae43c23          	sd	a4,-72(s0)
 960:	439c                	lw	a5,0(a5)
 962:	0ff7f713          	zext.b	a4,a5
 966:	fcc42783          	lw	a5,-52(s0)
 96a:	85ba                	mv	a1,a4
 96c:	853e                	mv	a0,a5
 96e:	00000097          	auipc	ra,0x0
 972:	c5a080e7          	jalr	-934(ra) # 5c8 <putc>
 976:	a899                	j	9cc <vprintf+0x23a>
      } else if(c == '%'){
 978:	fdc42783          	lw	a5,-36(s0)
 97c:	0007871b          	sext.w	a4,a5
 980:	02500793          	li	a5,37
 984:	00f71f63          	bne	a4,a5,9a2 <vprintf+0x210>
        putc(fd, c);
 988:	fdc42783          	lw	a5,-36(s0)
 98c:	0ff7f713          	zext.b	a4,a5
 990:	fcc42783          	lw	a5,-52(s0)
 994:	85ba                	mv	a1,a4
 996:	853e                	mv	a0,a5
 998:	00000097          	auipc	ra,0x0
 99c:	c30080e7          	jalr	-976(ra) # 5c8 <putc>
 9a0:	a035                	j	9cc <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9a2:	fcc42783          	lw	a5,-52(s0)
 9a6:	02500593          	li	a1,37
 9aa:	853e                	mv	a0,a5
 9ac:	00000097          	auipc	ra,0x0
 9b0:	c1c080e7          	jalr	-996(ra) # 5c8 <putc>
        putc(fd, c);
 9b4:	fdc42783          	lw	a5,-36(s0)
 9b8:	0ff7f713          	zext.b	a4,a5
 9bc:	fcc42783          	lw	a5,-52(s0)
 9c0:	85ba                	mv	a1,a4
 9c2:	853e                	mv	a0,a5
 9c4:	00000097          	auipc	ra,0x0
 9c8:	c04080e7          	jalr	-1020(ra) # 5c8 <putc>
      }
      state = 0;
 9cc:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 9d0:	fe442783          	lw	a5,-28(s0)
 9d4:	2785                	addiw	a5,a5,1
 9d6:	fef42223          	sw	a5,-28(s0)
 9da:	fe442783          	lw	a5,-28(s0)
 9de:	fc043703          	ld	a4,-64(s0)
 9e2:	97ba                	add	a5,a5,a4
 9e4:	0007c783          	lbu	a5,0(a5)
 9e8:	dc0795e3          	bnez	a5,7b2 <vprintf+0x20>
    }
  }
}
 9ec:	0001                	nop
 9ee:	0001                	nop
 9f0:	60a6                	ld	ra,72(sp)
 9f2:	6406                	ld	s0,64(sp)
 9f4:	6161                	addi	sp,sp,80
 9f6:	8082                	ret

00000000000009f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9f8:	7159                	addi	sp,sp,-112
 9fa:	fc06                	sd	ra,56(sp)
 9fc:	f822                	sd	s0,48(sp)
 9fe:	0080                	addi	s0,sp,64
 a00:	fcb43823          	sd	a1,-48(s0)
 a04:	e010                	sd	a2,0(s0)
 a06:	e414                	sd	a3,8(s0)
 a08:	e818                	sd	a4,16(s0)
 a0a:	ec1c                	sd	a5,24(s0)
 a0c:	03043023          	sd	a6,32(s0)
 a10:	03143423          	sd	a7,40(s0)
 a14:	87aa                	mv	a5,a0
 a16:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 a1a:	03040793          	addi	a5,s0,48
 a1e:	fcf43423          	sd	a5,-56(s0)
 a22:	fc843783          	ld	a5,-56(s0)
 a26:	fd078793          	addi	a5,a5,-48
 a2a:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 a2e:	fe843703          	ld	a4,-24(s0)
 a32:	fdc42783          	lw	a5,-36(s0)
 a36:	863a                	mv	a2,a4
 a38:	fd043583          	ld	a1,-48(s0)
 a3c:	853e                	mv	a0,a5
 a3e:	00000097          	auipc	ra,0x0
 a42:	d54080e7          	jalr	-684(ra) # 792 <vprintf>
}
 a46:	0001                	nop
 a48:	70e2                	ld	ra,56(sp)
 a4a:	7442                	ld	s0,48(sp)
 a4c:	6165                	addi	sp,sp,112
 a4e:	8082                	ret

0000000000000a50 <printf>:

void
printf(const char *fmt, ...)
{
 a50:	7159                	addi	sp,sp,-112
 a52:	f406                	sd	ra,40(sp)
 a54:	f022                	sd	s0,32(sp)
 a56:	1800                	addi	s0,sp,48
 a58:	fca43c23          	sd	a0,-40(s0)
 a5c:	e40c                	sd	a1,8(s0)
 a5e:	e810                	sd	a2,16(s0)
 a60:	ec14                	sd	a3,24(s0)
 a62:	f018                	sd	a4,32(s0)
 a64:	f41c                	sd	a5,40(s0)
 a66:	03043823          	sd	a6,48(s0)
 a6a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a6e:	04040793          	addi	a5,s0,64
 a72:	fcf43823          	sd	a5,-48(s0)
 a76:	fd043783          	ld	a5,-48(s0)
 a7a:	fc878793          	addi	a5,a5,-56
 a7e:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 a82:	fe843783          	ld	a5,-24(s0)
 a86:	863e                	mv	a2,a5
 a88:	fd843583          	ld	a1,-40(s0)
 a8c:	4505                	li	a0,1
 a8e:	00000097          	auipc	ra,0x0
 a92:	d04080e7          	jalr	-764(ra) # 792 <vprintf>
}
 a96:	0001                	nop
 a98:	70a2                	ld	ra,40(sp)
 a9a:	7402                	ld	s0,32(sp)
 a9c:	6165                	addi	sp,sp,112
 a9e:	8082                	ret

0000000000000aa0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aa0:	7179                	addi	sp,sp,-48
 aa2:	f422                	sd	s0,40(sp)
 aa4:	1800                	addi	s0,sp,48
 aa6:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aaa:	fd843783          	ld	a5,-40(s0)
 aae:	17c1                	addi	a5,a5,-16
 ab0:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab4:	00000797          	auipc	a5,0x0
 ab8:	57c78793          	addi	a5,a5,1404 # 1030 <freep>
 abc:	639c                	ld	a5,0(a5)
 abe:	fef43423          	sd	a5,-24(s0)
 ac2:	a815                	j	af6 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ac4:	fe843783          	ld	a5,-24(s0)
 ac8:	639c                	ld	a5,0(a5)
 aca:	fe843703          	ld	a4,-24(s0)
 ace:	00f76f63          	bltu	a4,a5,aec <free+0x4c>
 ad2:	fe043703          	ld	a4,-32(s0)
 ad6:	fe843783          	ld	a5,-24(s0)
 ada:	02e7eb63          	bltu	a5,a4,b10 <free+0x70>
 ade:	fe843783          	ld	a5,-24(s0)
 ae2:	639c                	ld	a5,0(a5)
 ae4:	fe043703          	ld	a4,-32(s0)
 ae8:	02f76463          	bltu	a4,a5,b10 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aec:	fe843783          	ld	a5,-24(s0)
 af0:	639c                	ld	a5,0(a5)
 af2:	fef43423          	sd	a5,-24(s0)
 af6:	fe043703          	ld	a4,-32(s0)
 afa:	fe843783          	ld	a5,-24(s0)
 afe:	fce7f3e3          	bgeu	a5,a4,ac4 <free+0x24>
 b02:	fe843783          	ld	a5,-24(s0)
 b06:	639c                	ld	a5,0(a5)
 b08:	fe043703          	ld	a4,-32(s0)
 b0c:	faf77ce3          	bgeu	a4,a5,ac4 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b10:	fe043783          	ld	a5,-32(s0)
 b14:	479c                	lw	a5,8(a5)
 b16:	1782                	slli	a5,a5,0x20
 b18:	9381                	srli	a5,a5,0x20
 b1a:	0792                	slli	a5,a5,0x4
 b1c:	fe043703          	ld	a4,-32(s0)
 b20:	973e                	add	a4,a4,a5
 b22:	fe843783          	ld	a5,-24(s0)
 b26:	639c                	ld	a5,0(a5)
 b28:	02f71763          	bne	a4,a5,b56 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 b2c:	fe043783          	ld	a5,-32(s0)
 b30:	4798                	lw	a4,8(a5)
 b32:	fe843783          	ld	a5,-24(s0)
 b36:	639c                	ld	a5,0(a5)
 b38:	479c                	lw	a5,8(a5)
 b3a:	9fb9                	addw	a5,a5,a4
 b3c:	0007871b          	sext.w	a4,a5
 b40:	fe043783          	ld	a5,-32(s0)
 b44:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 b46:	fe843783          	ld	a5,-24(s0)
 b4a:	639c                	ld	a5,0(a5)
 b4c:	6398                	ld	a4,0(a5)
 b4e:	fe043783          	ld	a5,-32(s0)
 b52:	e398                	sd	a4,0(a5)
 b54:	a039                	j	b62 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 b56:	fe843783          	ld	a5,-24(s0)
 b5a:	6398                	ld	a4,0(a5)
 b5c:	fe043783          	ld	a5,-32(s0)
 b60:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 b62:	fe843783          	ld	a5,-24(s0)
 b66:	479c                	lw	a5,8(a5)
 b68:	1782                	slli	a5,a5,0x20
 b6a:	9381                	srli	a5,a5,0x20
 b6c:	0792                	slli	a5,a5,0x4
 b6e:	fe843703          	ld	a4,-24(s0)
 b72:	97ba                	add	a5,a5,a4
 b74:	fe043703          	ld	a4,-32(s0)
 b78:	02f71563          	bne	a4,a5,ba2 <free+0x102>
    p->s.size += bp->s.size;
 b7c:	fe843783          	ld	a5,-24(s0)
 b80:	4798                	lw	a4,8(a5)
 b82:	fe043783          	ld	a5,-32(s0)
 b86:	479c                	lw	a5,8(a5)
 b88:	9fb9                	addw	a5,a5,a4
 b8a:	0007871b          	sext.w	a4,a5
 b8e:	fe843783          	ld	a5,-24(s0)
 b92:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b94:	fe043783          	ld	a5,-32(s0)
 b98:	6398                	ld	a4,0(a5)
 b9a:	fe843783          	ld	a5,-24(s0)
 b9e:	e398                	sd	a4,0(a5)
 ba0:	a031                	j	bac <free+0x10c>
  } else
    p->s.ptr = bp;
 ba2:	fe843783          	ld	a5,-24(s0)
 ba6:	fe043703          	ld	a4,-32(s0)
 baa:	e398                	sd	a4,0(a5)
  freep = p;
 bac:	00000797          	auipc	a5,0x0
 bb0:	48478793          	addi	a5,a5,1156 # 1030 <freep>
 bb4:	fe843703          	ld	a4,-24(s0)
 bb8:	e398                	sd	a4,0(a5)
}
 bba:	0001                	nop
 bbc:	7422                	ld	s0,40(sp)
 bbe:	6145                	addi	sp,sp,48
 bc0:	8082                	ret

0000000000000bc2 <morecore>:

static Header*
morecore(uint nu)
{
 bc2:	7179                	addi	sp,sp,-48
 bc4:	f406                	sd	ra,40(sp)
 bc6:	f022                	sd	s0,32(sp)
 bc8:	1800                	addi	s0,sp,48
 bca:	87aa                	mv	a5,a0
 bcc:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 bd0:	fdc42783          	lw	a5,-36(s0)
 bd4:	0007871b          	sext.w	a4,a5
 bd8:	6785                	lui	a5,0x1
 bda:	00f77563          	bgeu	a4,a5,be4 <morecore+0x22>
    nu = 4096;
 bde:	6785                	lui	a5,0x1
 be0:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 be4:	fdc42783          	lw	a5,-36(s0)
 be8:	0047979b          	slliw	a5,a5,0x4
 bec:	2781                	sext.w	a5,a5
 bee:	2781                	sext.w	a5,a5
 bf0:	853e                	mv	a0,a5
 bf2:	00000097          	auipc	ra,0x0
 bf6:	99e080e7          	jalr	-1634(ra) # 590 <sbrk>
 bfa:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 bfe:	fe843703          	ld	a4,-24(s0)
 c02:	57fd                	li	a5,-1
 c04:	00f71463          	bne	a4,a5,c0c <morecore+0x4a>
    return 0;
 c08:	4781                	li	a5,0
 c0a:	a03d                	j	c38 <morecore+0x76>
  hp = (Header*)p;
 c0c:	fe843783          	ld	a5,-24(s0)
 c10:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 c14:	fe043783          	ld	a5,-32(s0)
 c18:	fdc42703          	lw	a4,-36(s0)
 c1c:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 c1e:	fe043783          	ld	a5,-32(s0)
 c22:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 c24:	853e                	mv	a0,a5
 c26:	00000097          	auipc	ra,0x0
 c2a:	e7a080e7          	jalr	-390(ra) # aa0 <free>
  return freep;
 c2e:	00000797          	auipc	a5,0x0
 c32:	40278793          	addi	a5,a5,1026 # 1030 <freep>
 c36:	639c                	ld	a5,0(a5)
}
 c38:	853e                	mv	a0,a5
 c3a:	70a2                	ld	ra,40(sp)
 c3c:	7402                	ld	s0,32(sp)
 c3e:	6145                	addi	sp,sp,48
 c40:	8082                	ret

0000000000000c42 <malloc>:

void*
malloc(uint nbytes)
{
 c42:	7139                	addi	sp,sp,-64
 c44:	fc06                	sd	ra,56(sp)
 c46:	f822                	sd	s0,48(sp)
 c48:	0080                	addi	s0,sp,64
 c4a:	87aa                	mv	a5,a0
 c4c:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c50:	fcc46783          	lwu	a5,-52(s0)
 c54:	07bd                	addi	a5,a5,15
 c56:	8391                	srli	a5,a5,0x4
 c58:	2781                	sext.w	a5,a5
 c5a:	2785                	addiw	a5,a5,1
 c5c:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 c60:	00000797          	auipc	a5,0x0
 c64:	3d078793          	addi	a5,a5,976 # 1030 <freep>
 c68:	639c                	ld	a5,0(a5)
 c6a:	fef43023          	sd	a5,-32(s0)
 c6e:	fe043783          	ld	a5,-32(s0)
 c72:	ef95                	bnez	a5,cae <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 c74:	00000797          	auipc	a5,0x0
 c78:	3ac78793          	addi	a5,a5,940 # 1020 <base>
 c7c:	fef43023          	sd	a5,-32(s0)
 c80:	00000797          	auipc	a5,0x0
 c84:	3b078793          	addi	a5,a5,944 # 1030 <freep>
 c88:	fe043703          	ld	a4,-32(s0)
 c8c:	e398                	sd	a4,0(a5)
 c8e:	00000797          	auipc	a5,0x0
 c92:	3a278793          	addi	a5,a5,930 # 1030 <freep>
 c96:	6398                	ld	a4,0(a5)
 c98:	00000797          	auipc	a5,0x0
 c9c:	38878793          	addi	a5,a5,904 # 1020 <base>
 ca0:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 ca2:	00000797          	auipc	a5,0x0
 ca6:	37e78793          	addi	a5,a5,894 # 1020 <base>
 caa:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cae:	fe043783          	ld	a5,-32(s0)
 cb2:	639c                	ld	a5,0(a5)
 cb4:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 cb8:	fe843783          	ld	a5,-24(s0)
 cbc:	4798                	lw	a4,8(a5)
 cbe:	fdc42783          	lw	a5,-36(s0)
 cc2:	2781                	sext.w	a5,a5
 cc4:	06f76763          	bltu	a4,a5,d32 <malloc+0xf0>
      if(p->s.size == nunits)
 cc8:	fe843783          	ld	a5,-24(s0)
 ccc:	4798                	lw	a4,8(a5)
 cce:	fdc42783          	lw	a5,-36(s0)
 cd2:	2781                	sext.w	a5,a5
 cd4:	00e79963          	bne	a5,a4,ce6 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 cd8:	fe843783          	ld	a5,-24(s0)
 cdc:	6398                	ld	a4,0(a5)
 cde:	fe043783          	ld	a5,-32(s0)
 ce2:	e398                	sd	a4,0(a5)
 ce4:	a825                	j	d1c <malloc+0xda>
      else {
        p->s.size -= nunits;
 ce6:	fe843783          	ld	a5,-24(s0)
 cea:	479c                	lw	a5,8(a5)
 cec:	fdc42703          	lw	a4,-36(s0)
 cf0:	9f99                	subw	a5,a5,a4
 cf2:	0007871b          	sext.w	a4,a5
 cf6:	fe843783          	ld	a5,-24(s0)
 cfa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cfc:	fe843783          	ld	a5,-24(s0)
 d00:	479c                	lw	a5,8(a5)
 d02:	1782                	slli	a5,a5,0x20
 d04:	9381                	srli	a5,a5,0x20
 d06:	0792                	slli	a5,a5,0x4
 d08:	fe843703          	ld	a4,-24(s0)
 d0c:	97ba                	add	a5,a5,a4
 d0e:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 d12:	fe843783          	ld	a5,-24(s0)
 d16:	fdc42703          	lw	a4,-36(s0)
 d1a:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 d1c:	00000797          	auipc	a5,0x0
 d20:	31478793          	addi	a5,a5,788 # 1030 <freep>
 d24:	fe043703          	ld	a4,-32(s0)
 d28:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 d2a:	fe843783          	ld	a5,-24(s0)
 d2e:	07c1                	addi	a5,a5,16
 d30:	a091                	j	d74 <malloc+0x132>
    }
    if(p == freep)
 d32:	00000797          	auipc	a5,0x0
 d36:	2fe78793          	addi	a5,a5,766 # 1030 <freep>
 d3a:	639c                	ld	a5,0(a5)
 d3c:	fe843703          	ld	a4,-24(s0)
 d40:	02f71063          	bne	a4,a5,d60 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 d44:	fdc42783          	lw	a5,-36(s0)
 d48:	853e                	mv	a0,a5
 d4a:	00000097          	auipc	ra,0x0
 d4e:	e78080e7          	jalr	-392(ra) # bc2 <morecore>
 d52:	fea43423          	sd	a0,-24(s0)
 d56:	fe843783          	ld	a5,-24(s0)
 d5a:	e399                	bnez	a5,d60 <malloc+0x11e>
        return 0;
 d5c:	4781                	li	a5,0
 d5e:	a819                	j	d74 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d60:	fe843783          	ld	a5,-24(s0)
 d64:	fef43023          	sd	a5,-32(s0)
 d68:	fe843783          	ld	a5,-24(s0)
 d6c:	639c                	ld	a5,0(a5)
 d6e:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 d72:	b799                	j	cb8 <malloc+0x76>
  }
}
 d74:	853e                	mv	a0,a5
 d76:	70e2                	ld	ra,56(sp)
 d78:	7442                	ld	s0,48(sp)
 d7a:	6121                	addi	sp,sp,64
 d7c:	8082                	ret
