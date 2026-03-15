
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dc010113          	addi	sp,sp,-576
   4:	22113c23          	sd	ra,568(sp)
   8:	22813823          	sd	s0,560(sp)
   c:	0480                	addi	s0,sp,576
   e:	87aa                	mv	a5,a0
  10:	dcb43023          	sd	a1,-576(s0)
  14:	dcf42623          	sw	a5,-564(s0)
  int fd, i;
  char path[] = "stressfs0";
  18:	00001797          	auipc	a5,0x1
  1c:	ec878793          	addi	a5,a5,-312 # ee0 <malloc+0x170>
  20:	6398                	ld	a4,0(a5)
  22:	fce43c23          	sd	a4,-40(s0)
  26:	0087d783          	lhu	a5,8(a5)
  2a:	fef41023          	sh	a5,-32(s0)
  char data[512];

  printf("stressfs starting\n");
  2e:	00001517          	auipc	a0,0x1
  32:	e8250513          	addi	a0,a0,-382 # eb0 <malloc+0x140>
  36:	00001097          	auipc	ra,0x1
  3a:	b48080e7          	jalr	-1208(ra) # b7e <printf>
  memset(data, 'a', sizeof(data));
  3e:	dd840793          	addi	a5,s0,-552
  42:	20000613          	li	a2,512
  46:	06100593          	li	a1,97
  4a:	853e                	mv	a0,a5
  4c:	00000097          	auipc	ra,0x0
  50:	23e080e7          	jalr	574(ra) # 28a <memset>

  for(i = 0; i < 4; i++)
  54:	fe042623          	sw	zero,-20(s0)
  58:	a829                	j	72 <main+0x72>
    if(fork() > 0)
  5a:	00000097          	auipc	ra,0x0
  5e:	5d4080e7          	jalr	1492(ra) # 62e <fork>
  62:	87aa                	mv	a5,a0
  64:	00f04f63          	bgtz	a5,82 <main+0x82>
  for(i = 0; i < 4; i++)
  68:	fec42783          	lw	a5,-20(s0)
  6c:	2785                	addiw	a5,a5,1
  6e:	fef42623          	sw	a5,-20(s0)
  72:	fec42783          	lw	a5,-20(s0)
  76:	0007871b          	sext.w	a4,a5
  7a:	478d                	li	a5,3
  7c:	fce7dfe3          	bge	a5,a4,5a <main+0x5a>
  80:	a011                	j	84 <main+0x84>
      break;
  82:	0001                	nop

  printf("write %d\n", i);
  84:	fec42783          	lw	a5,-20(s0)
  88:	85be                	mv	a1,a5
  8a:	00001517          	auipc	a0,0x1
  8e:	e3e50513          	addi	a0,a0,-450 # ec8 <malloc+0x158>
  92:	00001097          	auipc	ra,0x1
  96:	aec080e7          	jalr	-1300(ra) # b7e <printf>

  path[8] += i;
  9a:	fe044703          	lbu	a4,-32(s0)
  9e:	fec42783          	lw	a5,-20(s0)
  a2:	0ff7f793          	zext.b	a5,a5
  a6:	9fb9                	addw	a5,a5,a4
  a8:	0ff7f793          	zext.b	a5,a5
  ac:	fef40023          	sb	a5,-32(s0)
  fd = open(path, O_CREATE | O_RDWR);
  b0:	fd840793          	addi	a5,s0,-40
  b4:	20200593          	li	a1,514
  b8:	853e                	mv	a0,a5
  ba:	00000097          	auipc	ra,0x0
  be:	5bc080e7          	jalr	1468(ra) # 676 <open>
  c2:	87aa                	mv	a5,a0
  c4:	fef42423          	sw	a5,-24(s0)
  for(i = 0; i < 20; i++)
  c8:	fe042623          	sw	zero,-20(s0)
  cc:	a015                	j	f0 <main+0xf0>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  ce:	dd840713          	addi	a4,s0,-552
  d2:	fe842783          	lw	a5,-24(s0)
  d6:	20000613          	li	a2,512
  da:	85ba                	mv	a1,a4
  dc:	853e                	mv	a0,a5
  de:	00000097          	auipc	ra,0x0
  e2:	578080e7          	jalr	1400(ra) # 656 <write>
  for(i = 0; i < 20; i++)
  e6:	fec42783          	lw	a5,-20(s0)
  ea:	2785                	addiw	a5,a5,1
  ec:	fef42623          	sw	a5,-20(s0)
  f0:	fec42783          	lw	a5,-20(s0)
  f4:	0007871b          	sext.w	a4,a5
  f8:	47cd                	li	a5,19
  fa:	fce7dae3          	bge	a5,a4,ce <main+0xce>
  close(fd);
  fe:	fe842783          	lw	a5,-24(s0)
 102:	853e                	mv	a0,a5
 104:	00000097          	auipc	ra,0x0
 108:	55a080e7          	jalr	1370(ra) # 65e <close>

  printf("read\n");
 10c:	00001517          	auipc	a0,0x1
 110:	dcc50513          	addi	a0,a0,-564 # ed8 <malloc+0x168>
 114:	00001097          	auipc	ra,0x1
 118:	a6a080e7          	jalr	-1430(ra) # b7e <printf>

  fd = open(path, O_RDONLY);
 11c:	fd840793          	addi	a5,s0,-40
 120:	4581                	li	a1,0
 122:	853e                	mv	a0,a5
 124:	00000097          	auipc	ra,0x0
 128:	552080e7          	jalr	1362(ra) # 676 <open>
 12c:	87aa                	mv	a5,a0
 12e:	fef42423          	sw	a5,-24(s0)
  for (i = 0; i < 20; i++)
 132:	fe042623          	sw	zero,-20(s0)
 136:	a015                	j	15a <main+0x15a>
    read(fd, data, sizeof(data));
 138:	dd840713          	addi	a4,s0,-552
 13c:	fe842783          	lw	a5,-24(s0)
 140:	20000613          	li	a2,512
 144:	85ba                	mv	a1,a4
 146:	853e                	mv	a0,a5
 148:	00000097          	auipc	ra,0x0
 14c:	506080e7          	jalr	1286(ra) # 64e <read>
  for (i = 0; i < 20; i++)
 150:	fec42783          	lw	a5,-20(s0)
 154:	2785                	addiw	a5,a5,1
 156:	fef42623          	sw	a5,-20(s0)
 15a:	fec42783          	lw	a5,-20(s0)
 15e:	0007871b          	sext.w	a4,a5
 162:	47cd                	li	a5,19
 164:	fce7dae3          	bge	a5,a4,138 <main+0x138>
  close(fd);
 168:	fe842783          	lw	a5,-24(s0)
 16c:	853e                	mv	a0,a5
 16e:	00000097          	auipc	ra,0x0
 172:	4f0080e7          	jalr	1264(ra) # 65e <close>

  wait(0);
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	4c6080e7          	jalr	1222(ra) # 63e <wait>

  exit(0);
 180:	4501                	li	a0,0
 182:	00000097          	auipc	ra,0x0
 186:	4b4080e7          	jalr	1204(ra) # 636 <exit>

000000000000018a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e406                	sd	ra,8(sp)
 18e:	e022                	sd	s0,0(sp)
 190:	0800                	addi	s0,sp,16
  extern int main();
  main();
 192:	00000097          	auipc	ra,0x0
 196:	e6e080e7          	jalr	-402(ra) # 0 <main>
  exit(0);
 19a:	4501                	li	a0,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	49a080e7          	jalr	1178(ra) # 636 <exit>

00000000000001a4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1a4:	7179                	addi	sp,sp,-48
 1a6:	f422                	sd	s0,40(sp)
 1a8:	1800                	addi	s0,sp,48
 1aa:	fca43c23          	sd	a0,-40(s0)
 1ae:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
 1b2:	fd843783          	ld	a5,-40(s0)
 1b6:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
 1ba:	0001                	nop
 1bc:	fd043703          	ld	a4,-48(s0)
 1c0:	00170793          	addi	a5,a4,1
 1c4:	fcf43823          	sd	a5,-48(s0)
 1c8:	fd843783          	ld	a5,-40(s0)
 1cc:	00178693          	addi	a3,a5,1
 1d0:	fcd43c23          	sd	a3,-40(s0)
 1d4:	00074703          	lbu	a4,0(a4)
 1d8:	00e78023          	sb	a4,0(a5)
 1dc:	0007c783          	lbu	a5,0(a5)
 1e0:	fff1                	bnez	a5,1bc <strcpy+0x18>
    ;
  return os;
 1e2:	fe843783          	ld	a5,-24(s0)
}
 1e6:	853e                	mv	a0,a5
 1e8:	7422                	ld	s0,40(sp)
 1ea:	6145                	addi	sp,sp,48
 1ec:	8082                	ret

00000000000001ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ee:	1101                	addi	sp,sp,-32
 1f0:	ec22                	sd	s0,24(sp)
 1f2:	1000                	addi	s0,sp,32
 1f4:	fea43423          	sd	a0,-24(s0)
 1f8:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 1fc:	a819                	j	212 <strcmp+0x24>
    p++, q++;
 1fe:	fe843783          	ld	a5,-24(s0)
 202:	0785                	addi	a5,a5,1
 204:	fef43423          	sd	a5,-24(s0)
 208:	fe043783          	ld	a5,-32(s0)
 20c:	0785                	addi	a5,a5,1
 20e:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 212:	fe843783          	ld	a5,-24(s0)
 216:	0007c783          	lbu	a5,0(a5)
 21a:	cb99                	beqz	a5,230 <strcmp+0x42>
 21c:	fe843783          	ld	a5,-24(s0)
 220:	0007c703          	lbu	a4,0(a5)
 224:	fe043783          	ld	a5,-32(s0)
 228:	0007c783          	lbu	a5,0(a5)
 22c:	fcf709e3          	beq	a4,a5,1fe <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 230:	fe843783          	ld	a5,-24(s0)
 234:	0007c783          	lbu	a5,0(a5)
 238:	0007871b          	sext.w	a4,a5
 23c:	fe043783          	ld	a5,-32(s0)
 240:	0007c783          	lbu	a5,0(a5)
 244:	2781                	sext.w	a5,a5
 246:	40f707bb          	subw	a5,a4,a5
 24a:	2781                	sext.w	a5,a5
}
 24c:	853e                	mv	a0,a5
 24e:	6462                	ld	s0,24(sp)
 250:	6105                	addi	sp,sp,32
 252:	8082                	ret

0000000000000254 <strlen>:

uint
strlen(const char *s)
{
 254:	7179                	addi	sp,sp,-48
 256:	f422                	sd	s0,40(sp)
 258:	1800                	addi	s0,sp,48
 25a:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 25e:	fe042623          	sw	zero,-20(s0)
 262:	a031                	j	26e <strlen+0x1a>
 264:	fec42783          	lw	a5,-20(s0)
 268:	2785                	addiw	a5,a5,1
 26a:	fef42623          	sw	a5,-20(s0)
 26e:	fec42783          	lw	a5,-20(s0)
 272:	fd843703          	ld	a4,-40(s0)
 276:	97ba                	add	a5,a5,a4
 278:	0007c783          	lbu	a5,0(a5)
 27c:	f7e5                	bnez	a5,264 <strlen+0x10>
    ;
  return n;
 27e:	fec42783          	lw	a5,-20(s0)
}
 282:	853e                	mv	a0,a5
 284:	7422                	ld	s0,40(sp)
 286:	6145                	addi	sp,sp,48
 288:	8082                	ret

000000000000028a <memset>:

void*
memset(void *dst, int c, uint n)
{
 28a:	7179                	addi	sp,sp,-48
 28c:	f422                	sd	s0,40(sp)
 28e:	1800                	addi	s0,sp,48
 290:	fca43c23          	sd	a0,-40(s0)
 294:	87ae                	mv	a5,a1
 296:	8732                	mv	a4,a2
 298:	fcf42a23          	sw	a5,-44(s0)
 29c:	87ba                	mv	a5,a4
 29e:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 2a2:	fd843783          	ld	a5,-40(s0)
 2a6:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 2aa:	fe042623          	sw	zero,-20(s0)
 2ae:	a00d                	j	2d0 <memset+0x46>
    cdst[i] = c;
 2b0:	fec42783          	lw	a5,-20(s0)
 2b4:	fe043703          	ld	a4,-32(s0)
 2b8:	97ba                	add	a5,a5,a4
 2ba:	fd442703          	lw	a4,-44(s0)
 2be:	0ff77713          	zext.b	a4,a4
 2c2:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 2c6:	fec42783          	lw	a5,-20(s0)
 2ca:	2785                	addiw	a5,a5,1
 2cc:	fef42623          	sw	a5,-20(s0)
 2d0:	fec42703          	lw	a4,-20(s0)
 2d4:	fd042783          	lw	a5,-48(s0)
 2d8:	2781                	sext.w	a5,a5
 2da:	fcf76be3          	bltu	a4,a5,2b0 <memset+0x26>
  }
  return dst;
 2de:	fd843783          	ld	a5,-40(s0)
}
 2e2:	853e                	mv	a0,a5
 2e4:	7422                	ld	s0,40(sp)
 2e6:	6145                	addi	sp,sp,48
 2e8:	8082                	ret

00000000000002ea <strchr>:

char*
strchr(const char *s, char c)
{
 2ea:	1101                	addi	sp,sp,-32
 2ec:	ec22                	sd	s0,24(sp)
 2ee:	1000                	addi	s0,sp,32
 2f0:	fea43423          	sd	a0,-24(s0)
 2f4:	87ae                	mv	a5,a1
 2f6:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 2fa:	a01d                	j	320 <strchr+0x36>
    if(*s == c)
 2fc:	fe843783          	ld	a5,-24(s0)
 300:	0007c703          	lbu	a4,0(a5)
 304:	fe744783          	lbu	a5,-25(s0)
 308:	0ff7f793          	zext.b	a5,a5
 30c:	00e79563          	bne	a5,a4,316 <strchr+0x2c>
      return (char*)s;
 310:	fe843783          	ld	a5,-24(s0)
 314:	a821                	j	32c <strchr+0x42>
  for(; *s; s++)
 316:	fe843783          	ld	a5,-24(s0)
 31a:	0785                	addi	a5,a5,1
 31c:	fef43423          	sd	a5,-24(s0)
 320:	fe843783          	ld	a5,-24(s0)
 324:	0007c783          	lbu	a5,0(a5)
 328:	fbf1                	bnez	a5,2fc <strchr+0x12>
  return 0;
 32a:	4781                	li	a5,0
}
 32c:	853e                	mv	a0,a5
 32e:	6462                	ld	s0,24(sp)
 330:	6105                	addi	sp,sp,32
 332:	8082                	ret

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	7179                	addi	sp,sp,-48
 336:	f406                	sd	ra,40(sp)
 338:	f022                	sd	s0,32(sp)
 33a:	1800                	addi	s0,sp,48
 33c:	fca43c23          	sd	a0,-40(s0)
 340:	87ae                	mv	a5,a1
 342:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 346:	fe042623          	sw	zero,-20(s0)
 34a:	a8a1                	j	3a2 <gets+0x6e>
    cc = read(0, &c, 1);
 34c:	fe740793          	addi	a5,s0,-25
 350:	4605                	li	a2,1
 352:	85be                	mv	a1,a5
 354:	4501                	li	a0,0
 356:	00000097          	auipc	ra,0x0
 35a:	2f8080e7          	jalr	760(ra) # 64e <read>
 35e:	87aa                	mv	a5,a0
 360:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 364:	fe842783          	lw	a5,-24(s0)
 368:	2781                	sext.w	a5,a5
 36a:	04f05763          	blez	a5,3b8 <gets+0x84>
      break;
    buf[i++] = c;
 36e:	fec42783          	lw	a5,-20(s0)
 372:	0017871b          	addiw	a4,a5,1
 376:	fee42623          	sw	a4,-20(s0)
 37a:	873e                	mv	a4,a5
 37c:	fd843783          	ld	a5,-40(s0)
 380:	97ba                	add	a5,a5,a4
 382:	fe744703          	lbu	a4,-25(s0)
 386:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 38a:	fe744783          	lbu	a5,-25(s0)
 38e:	873e                	mv	a4,a5
 390:	47a9                	li	a5,10
 392:	02f70463          	beq	a4,a5,3ba <gets+0x86>
 396:	fe744783          	lbu	a5,-25(s0)
 39a:	873e                	mv	a4,a5
 39c:	47b5                	li	a5,13
 39e:	00f70e63          	beq	a4,a5,3ba <gets+0x86>
  for(i=0; i+1 < max; ){
 3a2:	fec42783          	lw	a5,-20(s0)
 3a6:	2785                	addiw	a5,a5,1
 3a8:	0007871b          	sext.w	a4,a5
 3ac:	fd442783          	lw	a5,-44(s0)
 3b0:	2781                	sext.w	a5,a5
 3b2:	f8f74de3          	blt	a4,a5,34c <gets+0x18>
 3b6:	a011                	j	3ba <gets+0x86>
      break;
 3b8:	0001                	nop
      break;
  }
  buf[i] = '\0';
 3ba:	fec42783          	lw	a5,-20(s0)
 3be:	fd843703          	ld	a4,-40(s0)
 3c2:	97ba                	add	a5,a5,a4
 3c4:	00078023          	sb	zero,0(a5)
  return buf;
 3c8:	fd843783          	ld	a5,-40(s0)
}
 3cc:	853e                	mv	a0,a5
 3ce:	70a2                	ld	ra,40(sp)
 3d0:	7402                	ld	s0,32(sp)
 3d2:	6145                	addi	sp,sp,48
 3d4:	8082                	ret

00000000000003d6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3d6:	7179                	addi	sp,sp,-48
 3d8:	f406                	sd	ra,40(sp)
 3da:	f022                	sd	s0,32(sp)
 3dc:	1800                	addi	s0,sp,48
 3de:	fca43c23          	sd	a0,-40(s0)
 3e2:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3e6:	4581                	li	a1,0
 3e8:	fd843503          	ld	a0,-40(s0)
 3ec:	00000097          	auipc	ra,0x0
 3f0:	28a080e7          	jalr	650(ra) # 676 <open>
 3f4:	87aa                	mv	a5,a0
 3f6:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 3fa:	fec42783          	lw	a5,-20(s0)
 3fe:	2781                	sext.w	a5,a5
 400:	0007d463          	bgez	a5,408 <stat+0x32>
    return -1;
 404:	57fd                	li	a5,-1
 406:	a035                	j	432 <stat+0x5c>
  r = fstat(fd, st);
 408:	fec42783          	lw	a5,-20(s0)
 40c:	fd043583          	ld	a1,-48(s0)
 410:	853e                	mv	a0,a5
 412:	00000097          	auipc	ra,0x0
 416:	27c080e7          	jalr	636(ra) # 68e <fstat>
 41a:	87aa                	mv	a5,a0
 41c:	fef42423          	sw	a5,-24(s0)
  close(fd);
 420:	fec42783          	lw	a5,-20(s0)
 424:	853e                	mv	a0,a5
 426:	00000097          	auipc	ra,0x0
 42a:	238080e7          	jalr	568(ra) # 65e <close>
  return r;
 42e:	fe842783          	lw	a5,-24(s0)
}
 432:	853e                	mv	a0,a5
 434:	70a2                	ld	ra,40(sp)
 436:	7402                	ld	s0,32(sp)
 438:	6145                	addi	sp,sp,48
 43a:	8082                	ret

000000000000043c <atoi>:

int
atoi(const char *s)
{
 43c:	7179                	addi	sp,sp,-48
 43e:	f422                	sd	s0,40(sp)
 440:	1800                	addi	s0,sp,48
 442:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 446:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 44a:	a81d                	j	480 <atoi+0x44>
    n = n*10 + *s++ - '0';
 44c:	fec42783          	lw	a5,-20(s0)
 450:	873e                	mv	a4,a5
 452:	87ba                	mv	a5,a4
 454:	0027979b          	slliw	a5,a5,0x2
 458:	9fb9                	addw	a5,a5,a4
 45a:	0017979b          	slliw	a5,a5,0x1
 45e:	0007871b          	sext.w	a4,a5
 462:	fd843783          	ld	a5,-40(s0)
 466:	00178693          	addi	a3,a5,1
 46a:	fcd43c23          	sd	a3,-40(s0)
 46e:	0007c783          	lbu	a5,0(a5)
 472:	2781                	sext.w	a5,a5
 474:	9fb9                	addw	a5,a5,a4
 476:	2781                	sext.w	a5,a5
 478:	fd07879b          	addiw	a5,a5,-48
 47c:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 480:	fd843783          	ld	a5,-40(s0)
 484:	0007c783          	lbu	a5,0(a5)
 488:	873e                	mv	a4,a5
 48a:	02f00793          	li	a5,47
 48e:	00e7fb63          	bgeu	a5,a4,4a4 <atoi+0x68>
 492:	fd843783          	ld	a5,-40(s0)
 496:	0007c783          	lbu	a5,0(a5)
 49a:	873e                	mv	a4,a5
 49c:	03900793          	li	a5,57
 4a0:	fae7f6e3          	bgeu	a5,a4,44c <atoi+0x10>
  return n;
 4a4:	fec42783          	lw	a5,-20(s0)
}
 4a8:	853e                	mv	a0,a5
 4aa:	7422                	ld	s0,40(sp)
 4ac:	6145                	addi	sp,sp,48
 4ae:	8082                	ret

00000000000004b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4b0:	7139                	addi	sp,sp,-64
 4b2:	fc22                	sd	s0,56(sp)
 4b4:	0080                	addi	s0,sp,64
 4b6:	fca43c23          	sd	a0,-40(s0)
 4ba:	fcb43823          	sd	a1,-48(s0)
 4be:	87b2                	mv	a5,a2
 4c0:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 4c4:	fd843783          	ld	a5,-40(s0)
 4c8:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 4cc:	fd043783          	ld	a5,-48(s0)
 4d0:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 4d4:	fe043703          	ld	a4,-32(s0)
 4d8:	fe843783          	ld	a5,-24(s0)
 4dc:	02e7fc63          	bgeu	a5,a4,514 <memmove+0x64>
    while(n-- > 0)
 4e0:	a00d                	j	502 <memmove+0x52>
      *dst++ = *src++;
 4e2:	fe043703          	ld	a4,-32(s0)
 4e6:	00170793          	addi	a5,a4,1
 4ea:	fef43023          	sd	a5,-32(s0)
 4ee:	fe843783          	ld	a5,-24(s0)
 4f2:	00178693          	addi	a3,a5,1
 4f6:	fed43423          	sd	a3,-24(s0)
 4fa:	00074703          	lbu	a4,0(a4)
 4fe:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 502:	fcc42783          	lw	a5,-52(s0)
 506:	fff7871b          	addiw	a4,a5,-1
 50a:	fce42623          	sw	a4,-52(s0)
 50e:	fcf04ae3          	bgtz	a5,4e2 <memmove+0x32>
 512:	a891                	j	566 <memmove+0xb6>
  } else {
    dst += n;
 514:	fcc42783          	lw	a5,-52(s0)
 518:	fe843703          	ld	a4,-24(s0)
 51c:	97ba                	add	a5,a5,a4
 51e:	fef43423          	sd	a5,-24(s0)
    src += n;
 522:	fcc42783          	lw	a5,-52(s0)
 526:	fe043703          	ld	a4,-32(s0)
 52a:	97ba                	add	a5,a5,a4
 52c:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 530:	a01d                	j	556 <memmove+0xa6>
      *--dst = *--src;
 532:	fe043783          	ld	a5,-32(s0)
 536:	17fd                	addi	a5,a5,-1
 538:	fef43023          	sd	a5,-32(s0)
 53c:	fe843783          	ld	a5,-24(s0)
 540:	17fd                	addi	a5,a5,-1
 542:	fef43423          	sd	a5,-24(s0)
 546:	fe043783          	ld	a5,-32(s0)
 54a:	0007c703          	lbu	a4,0(a5)
 54e:	fe843783          	ld	a5,-24(s0)
 552:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 556:	fcc42783          	lw	a5,-52(s0)
 55a:	fff7871b          	addiw	a4,a5,-1
 55e:	fce42623          	sw	a4,-52(s0)
 562:	fcf048e3          	bgtz	a5,532 <memmove+0x82>
  }
  return vdst;
 566:	fd843783          	ld	a5,-40(s0)
}
 56a:	853e                	mv	a0,a5
 56c:	7462                	ld	s0,56(sp)
 56e:	6121                	addi	sp,sp,64
 570:	8082                	ret

0000000000000572 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 572:	7139                	addi	sp,sp,-64
 574:	fc22                	sd	s0,56(sp)
 576:	0080                	addi	s0,sp,64
 578:	fca43c23          	sd	a0,-40(s0)
 57c:	fcb43823          	sd	a1,-48(s0)
 580:	87b2                	mv	a5,a2
 582:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 586:	fd843783          	ld	a5,-40(s0)
 58a:	fef43423          	sd	a5,-24(s0)
 58e:	fd043783          	ld	a5,-48(s0)
 592:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 596:	a0a1                	j	5de <memcmp+0x6c>
    if (*p1 != *p2) {
 598:	fe843783          	ld	a5,-24(s0)
 59c:	0007c703          	lbu	a4,0(a5)
 5a0:	fe043783          	ld	a5,-32(s0)
 5a4:	0007c783          	lbu	a5,0(a5)
 5a8:	02f70163          	beq	a4,a5,5ca <memcmp+0x58>
      return *p1 - *p2;
 5ac:	fe843783          	ld	a5,-24(s0)
 5b0:	0007c783          	lbu	a5,0(a5)
 5b4:	0007871b          	sext.w	a4,a5
 5b8:	fe043783          	ld	a5,-32(s0)
 5bc:	0007c783          	lbu	a5,0(a5)
 5c0:	2781                	sext.w	a5,a5
 5c2:	40f707bb          	subw	a5,a4,a5
 5c6:	2781                	sext.w	a5,a5
 5c8:	a01d                	j	5ee <memcmp+0x7c>
    }
    p1++;
 5ca:	fe843783          	ld	a5,-24(s0)
 5ce:	0785                	addi	a5,a5,1
 5d0:	fef43423          	sd	a5,-24(s0)
    p2++;
 5d4:	fe043783          	ld	a5,-32(s0)
 5d8:	0785                	addi	a5,a5,1
 5da:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 5de:	fcc42783          	lw	a5,-52(s0)
 5e2:	fff7871b          	addiw	a4,a5,-1
 5e6:	fce42623          	sw	a4,-52(s0)
 5ea:	f7dd                	bnez	a5,598 <memcmp+0x26>
  }
  return 0;
 5ec:	4781                	li	a5,0
}
 5ee:	853e                	mv	a0,a5
 5f0:	7462                	ld	s0,56(sp)
 5f2:	6121                	addi	sp,sp,64
 5f4:	8082                	ret

00000000000005f6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5f6:	7179                	addi	sp,sp,-48
 5f8:	f406                	sd	ra,40(sp)
 5fa:	f022                	sd	s0,32(sp)
 5fc:	1800                	addi	s0,sp,48
 5fe:	fea43423          	sd	a0,-24(s0)
 602:	feb43023          	sd	a1,-32(s0)
 606:	87b2                	mv	a5,a2
 608:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 60c:	fdc42783          	lw	a5,-36(s0)
 610:	863e                	mv	a2,a5
 612:	fe043583          	ld	a1,-32(s0)
 616:	fe843503          	ld	a0,-24(s0)
 61a:	00000097          	auipc	ra,0x0
 61e:	e96080e7          	jalr	-362(ra) # 4b0 <memmove>
 622:	87aa                	mv	a5,a0
}
 624:	853e                	mv	a0,a5
 626:	70a2                	ld	ra,40(sp)
 628:	7402                	ld	s0,32(sp)
 62a:	6145                	addi	sp,sp,48
 62c:	8082                	ret

000000000000062e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 62e:	4885                	li	a7,1
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <exit>:
.global exit
exit:
 li a7, SYS_exit
 636:	4889                	li	a7,2
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <wait>:
.global wait
wait:
 li a7, SYS_wait
 63e:	488d                	li	a7,3
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 646:	4891                	li	a7,4
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <read>:
.global read
read:
 li a7, SYS_read
 64e:	4895                	li	a7,5
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <write>:
.global write
write:
 li a7, SYS_write
 656:	48c1                	li	a7,16
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <close>:
.global close
close:
 li a7, SYS_close
 65e:	48d5                	li	a7,21
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <kill>:
.global kill
kill:
 li a7, SYS_kill
 666:	4899                	li	a7,6
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <exec>:
.global exec
exec:
 li a7, SYS_exec
 66e:	489d                	li	a7,7
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <open>:
.global open
open:
 li a7, SYS_open
 676:	48bd                	li	a7,15
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 67e:	48c5                	li	a7,17
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 686:	48c9                	li	a7,18
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 68e:	48a1                	li	a7,8
 ecall
 690:	00000073          	ecall
 ret
 694:	8082                	ret

0000000000000696 <link>:
.global link
link:
 li a7, SYS_link
 696:	48cd                	li	a7,19
 ecall
 698:	00000073          	ecall
 ret
 69c:	8082                	ret

000000000000069e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 69e:	48d1                	li	a7,20
 ecall
 6a0:	00000073          	ecall
 ret
 6a4:	8082                	ret

00000000000006a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6a6:	48a5                	li	a7,9
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 6ae:	48a9                	li	a7,10
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6b6:	48ad                	li	a7,11
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6be:	48b1                	li	a7,12
 ecall
 6c0:	00000073          	ecall
 ret
 6c4:	8082                	ret

00000000000006c6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6c6:	48b5                	li	a7,13
 ecall
 6c8:	00000073          	ecall
 ret
 6cc:	8082                	ret

00000000000006ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6ce:	48b9                	li	a7,14
 ecall
 6d0:	00000073          	ecall
 ret
 6d4:	8082                	ret

00000000000006d6 <hello>:
.global hello
hello:
 li a7, SYS_hello
 6d6:	48d9                	li	a7,22
 ecall
 6d8:	00000073          	ecall
 ret
 6dc:	8082                	ret

00000000000006de <ps>:
.global ps
ps:
 li a7, SYS_ps
 6de:	48e1                	li	a7,24
 ecall
 6e0:	00000073          	ecall
 ret
 6e4:	8082                	ret

00000000000006e6 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 6e6:	48dd                	li	a7,23
 ecall
 6e8:	00000073          	ecall
 ret
 6ec:	8082                	ret

00000000000006ee <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 6ee:	48e5                	li	a7,25
 ecall
 6f0:	00000073          	ecall
 ret
 6f4:	8082                	ret

00000000000006f6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6f6:	1101                	addi	sp,sp,-32
 6f8:	ec06                	sd	ra,24(sp)
 6fa:	e822                	sd	s0,16(sp)
 6fc:	1000                	addi	s0,sp,32
 6fe:	87aa                	mv	a5,a0
 700:	872e                	mv	a4,a1
 702:	fef42623          	sw	a5,-20(s0)
 706:	87ba                	mv	a5,a4
 708:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 70c:	feb40713          	addi	a4,s0,-21
 710:	fec42783          	lw	a5,-20(s0)
 714:	4605                	li	a2,1
 716:	85ba                	mv	a1,a4
 718:	853e                	mv	a0,a5
 71a:	00000097          	auipc	ra,0x0
 71e:	f3c080e7          	jalr	-196(ra) # 656 <write>
}
 722:	0001                	nop
 724:	60e2                	ld	ra,24(sp)
 726:	6442                	ld	s0,16(sp)
 728:	6105                	addi	sp,sp,32
 72a:	8082                	ret

000000000000072c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 72c:	7139                	addi	sp,sp,-64
 72e:	fc06                	sd	ra,56(sp)
 730:	f822                	sd	s0,48(sp)
 732:	0080                	addi	s0,sp,64
 734:	87aa                	mv	a5,a0
 736:	8736                	mv	a4,a3
 738:	fcf42623          	sw	a5,-52(s0)
 73c:	87ae                	mv	a5,a1
 73e:	fcf42423          	sw	a5,-56(s0)
 742:	87b2                	mv	a5,a2
 744:	fcf42223          	sw	a5,-60(s0)
 748:	87ba                	mv	a5,a4
 74a:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 74e:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 752:	fc042783          	lw	a5,-64(s0)
 756:	2781                	sext.w	a5,a5
 758:	c38d                	beqz	a5,77a <printint+0x4e>
 75a:	fc842783          	lw	a5,-56(s0)
 75e:	2781                	sext.w	a5,a5
 760:	0007dd63          	bgez	a5,77a <printint+0x4e>
    neg = 1;
 764:	4785                	li	a5,1
 766:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 76a:	fc842783          	lw	a5,-56(s0)
 76e:	40f007bb          	negw	a5,a5
 772:	2781                	sext.w	a5,a5
 774:	fef42223          	sw	a5,-28(s0)
 778:	a029                	j	782 <printint+0x56>
  } else {
    x = xx;
 77a:	fc842783          	lw	a5,-56(s0)
 77e:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 782:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 786:	fc442783          	lw	a5,-60(s0)
 78a:	fe442703          	lw	a4,-28(s0)
 78e:	02f777bb          	remuw	a5,a4,a5
 792:	0007861b          	sext.w	a2,a5
 796:	fec42783          	lw	a5,-20(s0)
 79a:	0017871b          	addiw	a4,a5,1
 79e:	fee42623          	sw	a4,-20(s0)
 7a2:	00001697          	auipc	a3,0x1
 7a6:	85e68693          	addi	a3,a3,-1954 # 1000 <digits>
 7aa:	02061713          	slli	a4,a2,0x20
 7ae:	9301                	srli	a4,a4,0x20
 7b0:	9736                	add	a4,a4,a3
 7b2:	00074703          	lbu	a4,0(a4)
 7b6:	17c1                	addi	a5,a5,-16
 7b8:	97a2                	add	a5,a5,s0
 7ba:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 7be:	fc442783          	lw	a5,-60(s0)
 7c2:	fe442703          	lw	a4,-28(s0)
 7c6:	02f757bb          	divuw	a5,a4,a5
 7ca:	fef42223          	sw	a5,-28(s0)
 7ce:	fe442783          	lw	a5,-28(s0)
 7d2:	2781                	sext.w	a5,a5
 7d4:	fbcd                	bnez	a5,786 <printint+0x5a>
  if(neg)
 7d6:	fe842783          	lw	a5,-24(s0)
 7da:	2781                	sext.w	a5,a5
 7dc:	cf85                	beqz	a5,814 <printint+0xe8>
    buf[i++] = '-';
 7de:	fec42783          	lw	a5,-20(s0)
 7e2:	0017871b          	addiw	a4,a5,1
 7e6:	fee42623          	sw	a4,-20(s0)
 7ea:	17c1                	addi	a5,a5,-16
 7ec:	97a2                	add	a5,a5,s0
 7ee:	02d00713          	li	a4,45
 7f2:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 7f6:	a839                	j	814 <printint+0xe8>
    putc(fd, buf[i]);
 7f8:	fec42783          	lw	a5,-20(s0)
 7fc:	17c1                	addi	a5,a5,-16
 7fe:	97a2                	add	a5,a5,s0
 800:	fe07c703          	lbu	a4,-32(a5)
 804:	fcc42783          	lw	a5,-52(s0)
 808:	85ba                	mv	a1,a4
 80a:	853e                	mv	a0,a5
 80c:	00000097          	auipc	ra,0x0
 810:	eea080e7          	jalr	-278(ra) # 6f6 <putc>
  while(--i >= 0)
 814:	fec42783          	lw	a5,-20(s0)
 818:	37fd                	addiw	a5,a5,-1
 81a:	fef42623          	sw	a5,-20(s0)
 81e:	fec42783          	lw	a5,-20(s0)
 822:	2781                	sext.w	a5,a5
 824:	fc07dae3          	bgez	a5,7f8 <printint+0xcc>
}
 828:	0001                	nop
 82a:	0001                	nop
 82c:	70e2                	ld	ra,56(sp)
 82e:	7442                	ld	s0,48(sp)
 830:	6121                	addi	sp,sp,64
 832:	8082                	ret

0000000000000834 <printptr>:

static void
printptr(int fd, uint64 x) {
 834:	7179                	addi	sp,sp,-48
 836:	f406                	sd	ra,40(sp)
 838:	f022                	sd	s0,32(sp)
 83a:	1800                	addi	s0,sp,48
 83c:	87aa                	mv	a5,a0
 83e:	fcb43823          	sd	a1,-48(s0)
 842:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 846:	fdc42783          	lw	a5,-36(s0)
 84a:	03000593          	li	a1,48
 84e:	853e                	mv	a0,a5
 850:	00000097          	auipc	ra,0x0
 854:	ea6080e7          	jalr	-346(ra) # 6f6 <putc>
  putc(fd, 'x');
 858:	fdc42783          	lw	a5,-36(s0)
 85c:	07800593          	li	a1,120
 860:	853e                	mv	a0,a5
 862:	00000097          	auipc	ra,0x0
 866:	e94080e7          	jalr	-364(ra) # 6f6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 86a:	fe042623          	sw	zero,-20(s0)
 86e:	a82d                	j	8a8 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 870:	fd043783          	ld	a5,-48(s0)
 874:	93f1                	srli	a5,a5,0x3c
 876:	00000717          	auipc	a4,0x0
 87a:	78a70713          	addi	a4,a4,1930 # 1000 <digits>
 87e:	97ba                	add	a5,a5,a4
 880:	0007c703          	lbu	a4,0(a5)
 884:	fdc42783          	lw	a5,-36(s0)
 888:	85ba                	mv	a1,a4
 88a:	853e                	mv	a0,a5
 88c:	00000097          	auipc	ra,0x0
 890:	e6a080e7          	jalr	-406(ra) # 6f6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 894:	fec42783          	lw	a5,-20(s0)
 898:	2785                	addiw	a5,a5,1
 89a:	fef42623          	sw	a5,-20(s0)
 89e:	fd043783          	ld	a5,-48(s0)
 8a2:	0792                	slli	a5,a5,0x4
 8a4:	fcf43823          	sd	a5,-48(s0)
 8a8:	fec42783          	lw	a5,-20(s0)
 8ac:	873e                	mv	a4,a5
 8ae:	47bd                	li	a5,15
 8b0:	fce7f0e3          	bgeu	a5,a4,870 <printptr+0x3c>
}
 8b4:	0001                	nop
 8b6:	0001                	nop
 8b8:	70a2                	ld	ra,40(sp)
 8ba:	7402                	ld	s0,32(sp)
 8bc:	6145                	addi	sp,sp,48
 8be:	8082                	ret

00000000000008c0 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8c0:	715d                	addi	sp,sp,-80
 8c2:	e486                	sd	ra,72(sp)
 8c4:	e0a2                	sd	s0,64(sp)
 8c6:	0880                	addi	s0,sp,80
 8c8:	87aa                	mv	a5,a0
 8ca:	fcb43023          	sd	a1,-64(s0)
 8ce:	fac43c23          	sd	a2,-72(s0)
 8d2:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 8d6:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 8da:	fe042223          	sw	zero,-28(s0)
 8de:	a42d                	j	b08 <vprintf+0x248>
    c = fmt[i] & 0xff;
 8e0:	fe442783          	lw	a5,-28(s0)
 8e4:	fc043703          	ld	a4,-64(s0)
 8e8:	97ba                	add	a5,a5,a4
 8ea:	0007c783          	lbu	a5,0(a5)
 8ee:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 8f2:	fe042783          	lw	a5,-32(s0)
 8f6:	2781                	sext.w	a5,a5
 8f8:	eb9d                	bnez	a5,92e <vprintf+0x6e>
      if(c == '%'){
 8fa:	fdc42783          	lw	a5,-36(s0)
 8fe:	0007871b          	sext.w	a4,a5
 902:	02500793          	li	a5,37
 906:	00f71763          	bne	a4,a5,914 <vprintf+0x54>
        state = '%';
 90a:	02500793          	li	a5,37
 90e:	fef42023          	sw	a5,-32(s0)
 912:	a2f5                	j	afe <vprintf+0x23e>
      } else {
        putc(fd, c);
 914:	fdc42783          	lw	a5,-36(s0)
 918:	0ff7f713          	zext.b	a4,a5
 91c:	fcc42783          	lw	a5,-52(s0)
 920:	85ba                	mv	a1,a4
 922:	853e                	mv	a0,a5
 924:	00000097          	auipc	ra,0x0
 928:	dd2080e7          	jalr	-558(ra) # 6f6 <putc>
 92c:	aac9                	j	afe <vprintf+0x23e>
      }
    } else if(state == '%'){
 92e:	fe042783          	lw	a5,-32(s0)
 932:	0007871b          	sext.w	a4,a5
 936:	02500793          	li	a5,37
 93a:	1cf71263          	bne	a4,a5,afe <vprintf+0x23e>
      if(c == 'd'){
 93e:	fdc42783          	lw	a5,-36(s0)
 942:	0007871b          	sext.w	a4,a5
 946:	06400793          	li	a5,100
 94a:	02f71463          	bne	a4,a5,972 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 94e:	fb843783          	ld	a5,-72(s0)
 952:	00878713          	addi	a4,a5,8
 956:	fae43c23          	sd	a4,-72(s0)
 95a:	4398                	lw	a4,0(a5)
 95c:	fcc42783          	lw	a5,-52(s0)
 960:	4685                	li	a3,1
 962:	4629                	li	a2,10
 964:	85ba                	mv	a1,a4
 966:	853e                	mv	a0,a5
 968:	00000097          	auipc	ra,0x0
 96c:	dc4080e7          	jalr	-572(ra) # 72c <printint>
 970:	a269                	j	afa <vprintf+0x23a>
      } else if(c == 'l') {
 972:	fdc42783          	lw	a5,-36(s0)
 976:	0007871b          	sext.w	a4,a5
 97a:	06c00793          	li	a5,108
 97e:	02f71663          	bne	a4,a5,9aa <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 982:	fb843783          	ld	a5,-72(s0)
 986:	00878713          	addi	a4,a5,8
 98a:	fae43c23          	sd	a4,-72(s0)
 98e:	639c                	ld	a5,0(a5)
 990:	0007871b          	sext.w	a4,a5
 994:	fcc42783          	lw	a5,-52(s0)
 998:	4681                	li	a3,0
 99a:	4629                	li	a2,10
 99c:	85ba                	mv	a1,a4
 99e:	853e                	mv	a0,a5
 9a0:	00000097          	auipc	ra,0x0
 9a4:	d8c080e7          	jalr	-628(ra) # 72c <printint>
 9a8:	aa89                	j	afa <vprintf+0x23a>
      } else if(c == 'x') {
 9aa:	fdc42783          	lw	a5,-36(s0)
 9ae:	0007871b          	sext.w	a4,a5
 9b2:	07800793          	li	a5,120
 9b6:	02f71463          	bne	a4,a5,9de <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 9ba:	fb843783          	ld	a5,-72(s0)
 9be:	00878713          	addi	a4,a5,8
 9c2:	fae43c23          	sd	a4,-72(s0)
 9c6:	4398                	lw	a4,0(a5)
 9c8:	fcc42783          	lw	a5,-52(s0)
 9cc:	4681                	li	a3,0
 9ce:	4641                	li	a2,16
 9d0:	85ba                	mv	a1,a4
 9d2:	853e                	mv	a0,a5
 9d4:	00000097          	auipc	ra,0x0
 9d8:	d58080e7          	jalr	-680(ra) # 72c <printint>
 9dc:	aa39                	j	afa <vprintf+0x23a>
      } else if(c == 'p') {
 9de:	fdc42783          	lw	a5,-36(s0)
 9e2:	0007871b          	sext.w	a4,a5
 9e6:	07000793          	li	a5,112
 9ea:	02f71263          	bne	a4,a5,a0e <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 9ee:	fb843783          	ld	a5,-72(s0)
 9f2:	00878713          	addi	a4,a5,8
 9f6:	fae43c23          	sd	a4,-72(s0)
 9fa:	6398                	ld	a4,0(a5)
 9fc:	fcc42783          	lw	a5,-52(s0)
 a00:	85ba                	mv	a1,a4
 a02:	853e                	mv	a0,a5
 a04:	00000097          	auipc	ra,0x0
 a08:	e30080e7          	jalr	-464(ra) # 834 <printptr>
 a0c:	a0fd                	j	afa <vprintf+0x23a>
      } else if(c == 's'){
 a0e:	fdc42783          	lw	a5,-36(s0)
 a12:	0007871b          	sext.w	a4,a5
 a16:	07300793          	li	a5,115
 a1a:	04f71c63          	bne	a4,a5,a72 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 a1e:	fb843783          	ld	a5,-72(s0)
 a22:	00878713          	addi	a4,a5,8
 a26:	fae43c23          	sd	a4,-72(s0)
 a2a:	639c                	ld	a5,0(a5)
 a2c:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 a30:	fe843783          	ld	a5,-24(s0)
 a34:	eb8d                	bnez	a5,a66 <vprintf+0x1a6>
          s = "(null)";
 a36:	00000797          	auipc	a5,0x0
 a3a:	4ba78793          	addi	a5,a5,1210 # ef0 <malloc+0x180>
 a3e:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 a42:	a015                	j	a66 <vprintf+0x1a6>
          putc(fd, *s);
 a44:	fe843783          	ld	a5,-24(s0)
 a48:	0007c703          	lbu	a4,0(a5)
 a4c:	fcc42783          	lw	a5,-52(s0)
 a50:	85ba                	mv	a1,a4
 a52:	853e                	mv	a0,a5
 a54:	00000097          	auipc	ra,0x0
 a58:	ca2080e7          	jalr	-862(ra) # 6f6 <putc>
          s++;
 a5c:	fe843783          	ld	a5,-24(s0)
 a60:	0785                	addi	a5,a5,1
 a62:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 a66:	fe843783          	ld	a5,-24(s0)
 a6a:	0007c783          	lbu	a5,0(a5)
 a6e:	fbf9                	bnez	a5,a44 <vprintf+0x184>
 a70:	a069                	j	afa <vprintf+0x23a>
        }
      } else if(c == 'c'){
 a72:	fdc42783          	lw	a5,-36(s0)
 a76:	0007871b          	sext.w	a4,a5
 a7a:	06300793          	li	a5,99
 a7e:	02f71463          	bne	a4,a5,aa6 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 a82:	fb843783          	ld	a5,-72(s0)
 a86:	00878713          	addi	a4,a5,8
 a8a:	fae43c23          	sd	a4,-72(s0)
 a8e:	439c                	lw	a5,0(a5)
 a90:	0ff7f713          	zext.b	a4,a5
 a94:	fcc42783          	lw	a5,-52(s0)
 a98:	85ba                	mv	a1,a4
 a9a:	853e                	mv	a0,a5
 a9c:	00000097          	auipc	ra,0x0
 aa0:	c5a080e7          	jalr	-934(ra) # 6f6 <putc>
 aa4:	a899                	j	afa <vprintf+0x23a>
      } else if(c == '%'){
 aa6:	fdc42783          	lw	a5,-36(s0)
 aaa:	0007871b          	sext.w	a4,a5
 aae:	02500793          	li	a5,37
 ab2:	00f71f63          	bne	a4,a5,ad0 <vprintf+0x210>
        putc(fd, c);
 ab6:	fdc42783          	lw	a5,-36(s0)
 aba:	0ff7f713          	zext.b	a4,a5
 abe:	fcc42783          	lw	a5,-52(s0)
 ac2:	85ba                	mv	a1,a4
 ac4:	853e                	mv	a0,a5
 ac6:	00000097          	auipc	ra,0x0
 aca:	c30080e7          	jalr	-976(ra) # 6f6 <putc>
 ace:	a035                	j	afa <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 ad0:	fcc42783          	lw	a5,-52(s0)
 ad4:	02500593          	li	a1,37
 ad8:	853e                	mv	a0,a5
 ada:	00000097          	auipc	ra,0x0
 ade:	c1c080e7          	jalr	-996(ra) # 6f6 <putc>
        putc(fd, c);
 ae2:	fdc42783          	lw	a5,-36(s0)
 ae6:	0ff7f713          	zext.b	a4,a5
 aea:	fcc42783          	lw	a5,-52(s0)
 aee:	85ba                	mv	a1,a4
 af0:	853e                	mv	a0,a5
 af2:	00000097          	auipc	ra,0x0
 af6:	c04080e7          	jalr	-1020(ra) # 6f6 <putc>
      }
      state = 0;
 afa:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 afe:	fe442783          	lw	a5,-28(s0)
 b02:	2785                	addiw	a5,a5,1
 b04:	fef42223          	sw	a5,-28(s0)
 b08:	fe442783          	lw	a5,-28(s0)
 b0c:	fc043703          	ld	a4,-64(s0)
 b10:	97ba                	add	a5,a5,a4
 b12:	0007c783          	lbu	a5,0(a5)
 b16:	dc0795e3          	bnez	a5,8e0 <vprintf+0x20>
    }
  }
}
 b1a:	0001                	nop
 b1c:	0001                	nop
 b1e:	60a6                	ld	ra,72(sp)
 b20:	6406                	ld	s0,64(sp)
 b22:	6161                	addi	sp,sp,80
 b24:	8082                	ret

0000000000000b26 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b26:	7159                	addi	sp,sp,-112
 b28:	fc06                	sd	ra,56(sp)
 b2a:	f822                	sd	s0,48(sp)
 b2c:	0080                	addi	s0,sp,64
 b2e:	fcb43823          	sd	a1,-48(s0)
 b32:	e010                	sd	a2,0(s0)
 b34:	e414                	sd	a3,8(s0)
 b36:	e818                	sd	a4,16(s0)
 b38:	ec1c                	sd	a5,24(s0)
 b3a:	03043023          	sd	a6,32(s0)
 b3e:	03143423          	sd	a7,40(s0)
 b42:	87aa                	mv	a5,a0
 b44:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 b48:	03040793          	addi	a5,s0,48
 b4c:	fcf43423          	sd	a5,-56(s0)
 b50:	fc843783          	ld	a5,-56(s0)
 b54:	fd078793          	addi	a5,a5,-48
 b58:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 b5c:	fe843703          	ld	a4,-24(s0)
 b60:	fdc42783          	lw	a5,-36(s0)
 b64:	863a                	mv	a2,a4
 b66:	fd043583          	ld	a1,-48(s0)
 b6a:	853e                	mv	a0,a5
 b6c:	00000097          	auipc	ra,0x0
 b70:	d54080e7          	jalr	-684(ra) # 8c0 <vprintf>
}
 b74:	0001                	nop
 b76:	70e2                	ld	ra,56(sp)
 b78:	7442                	ld	s0,48(sp)
 b7a:	6165                	addi	sp,sp,112
 b7c:	8082                	ret

0000000000000b7e <printf>:

void
printf(const char *fmt, ...)
{
 b7e:	7159                	addi	sp,sp,-112
 b80:	f406                	sd	ra,40(sp)
 b82:	f022                	sd	s0,32(sp)
 b84:	1800                	addi	s0,sp,48
 b86:	fca43c23          	sd	a0,-40(s0)
 b8a:	e40c                	sd	a1,8(s0)
 b8c:	e810                	sd	a2,16(s0)
 b8e:	ec14                	sd	a3,24(s0)
 b90:	f018                	sd	a4,32(s0)
 b92:	f41c                	sd	a5,40(s0)
 b94:	03043823          	sd	a6,48(s0)
 b98:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b9c:	04040793          	addi	a5,s0,64
 ba0:	fcf43823          	sd	a5,-48(s0)
 ba4:	fd043783          	ld	a5,-48(s0)
 ba8:	fc878793          	addi	a5,a5,-56
 bac:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 bb0:	fe843783          	ld	a5,-24(s0)
 bb4:	863e                	mv	a2,a5
 bb6:	fd843583          	ld	a1,-40(s0)
 bba:	4505                	li	a0,1
 bbc:	00000097          	auipc	ra,0x0
 bc0:	d04080e7          	jalr	-764(ra) # 8c0 <vprintf>
}
 bc4:	0001                	nop
 bc6:	70a2                	ld	ra,40(sp)
 bc8:	7402                	ld	s0,32(sp)
 bca:	6165                	addi	sp,sp,112
 bcc:	8082                	ret

0000000000000bce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bce:	7179                	addi	sp,sp,-48
 bd0:	f422                	sd	s0,40(sp)
 bd2:	1800                	addi	s0,sp,48
 bd4:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bd8:	fd843783          	ld	a5,-40(s0)
 bdc:	17c1                	addi	a5,a5,-16
 bde:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 be2:	00000797          	auipc	a5,0x0
 be6:	44e78793          	addi	a5,a5,1102 # 1030 <freep>
 bea:	639c                	ld	a5,0(a5)
 bec:	fef43423          	sd	a5,-24(s0)
 bf0:	a815                	j	c24 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bf2:	fe843783          	ld	a5,-24(s0)
 bf6:	639c                	ld	a5,0(a5)
 bf8:	fe843703          	ld	a4,-24(s0)
 bfc:	00f76f63          	bltu	a4,a5,c1a <free+0x4c>
 c00:	fe043703          	ld	a4,-32(s0)
 c04:	fe843783          	ld	a5,-24(s0)
 c08:	02e7eb63          	bltu	a5,a4,c3e <free+0x70>
 c0c:	fe843783          	ld	a5,-24(s0)
 c10:	639c                	ld	a5,0(a5)
 c12:	fe043703          	ld	a4,-32(s0)
 c16:	02f76463          	bltu	a4,a5,c3e <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c1a:	fe843783          	ld	a5,-24(s0)
 c1e:	639c                	ld	a5,0(a5)
 c20:	fef43423          	sd	a5,-24(s0)
 c24:	fe043703          	ld	a4,-32(s0)
 c28:	fe843783          	ld	a5,-24(s0)
 c2c:	fce7f3e3          	bgeu	a5,a4,bf2 <free+0x24>
 c30:	fe843783          	ld	a5,-24(s0)
 c34:	639c                	ld	a5,0(a5)
 c36:	fe043703          	ld	a4,-32(s0)
 c3a:	faf77ce3          	bgeu	a4,a5,bf2 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 c3e:	fe043783          	ld	a5,-32(s0)
 c42:	479c                	lw	a5,8(a5)
 c44:	1782                	slli	a5,a5,0x20
 c46:	9381                	srli	a5,a5,0x20
 c48:	0792                	slli	a5,a5,0x4
 c4a:	fe043703          	ld	a4,-32(s0)
 c4e:	973e                	add	a4,a4,a5
 c50:	fe843783          	ld	a5,-24(s0)
 c54:	639c                	ld	a5,0(a5)
 c56:	02f71763          	bne	a4,a5,c84 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 c5a:	fe043783          	ld	a5,-32(s0)
 c5e:	4798                	lw	a4,8(a5)
 c60:	fe843783          	ld	a5,-24(s0)
 c64:	639c                	ld	a5,0(a5)
 c66:	479c                	lw	a5,8(a5)
 c68:	9fb9                	addw	a5,a5,a4
 c6a:	0007871b          	sext.w	a4,a5
 c6e:	fe043783          	ld	a5,-32(s0)
 c72:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 c74:	fe843783          	ld	a5,-24(s0)
 c78:	639c                	ld	a5,0(a5)
 c7a:	6398                	ld	a4,0(a5)
 c7c:	fe043783          	ld	a5,-32(s0)
 c80:	e398                	sd	a4,0(a5)
 c82:	a039                	j	c90 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 c84:	fe843783          	ld	a5,-24(s0)
 c88:	6398                	ld	a4,0(a5)
 c8a:	fe043783          	ld	a5,-32(s0)
 c8e:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 c90:	fe843783          	ld	a5,-24(s0)
 c94:	479c                	lw	a5,8(a5)
 c96:	1782                	slli	a5,a5,0x20
 c98:	9381                	srli	a5,a5,0x20
 c9a:	0792                	slli	a5,a5,0x4
 c9c:	fe843703          	ld	a4,-24(s0)
 ca0:	97ba                	add	a5,a5,a4
 ca2:	fe043703          	ld	a4,-32(s0)
 ca6:	02f71563          	bne	a4,a5,cd0 <free+0x102>
    p->s.size += bp->s.size;
 caa:	fe843783          	ld	a5,-24(s0)
 cae:	4798                	lw	a4,8(a5)
 cb0:	fe043783          	ld	a5,-32(s0)
 cb4:	479c                	lw	a5,8(a5)
 cb6:	9fb9                	addw	a5,a5,a4
 cb8:	0007871b          	sext.w	a4,a5
 cbc:	fe843783          	ld	a5,-24(s0)
 cc0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cc2:	fe043783          	ld	a5,-32(s0)
 cc6:	6398                	ld	a4,0(a5)
 cc8:	fe843783          	ld	a5,-24(s0)
 ccc:	e398                	sd	a4,0(a5)
 cce:	a031                	j	cda <free+0x10c>
  } else
    p->s.ptr = bp;
 cd0:	fe843783          	ld	a5,-24(s0)
 cd4:	fe043703          	ld	a4,-32(s0)
 cd8:	e398                	sd	a4,0(a5)
  freep = p;
 cda:	00000797          	auipc	a5,0x0
 cde:	35678793          	addi	a5,a5,854 # 1030 <freep>
 ce2:	fe843703          	ld	a4,-24(s0)
 ce6:	e398                	sd	a4,0(a5)
}
 ce8:	0001                	nop
 cea:	7422                	ld	s0,40(sp)
 cec:	6145                	addi	sp,sp,48
 cee:	8082                	ret

0000000000000cf0 <morecore>:

static Header*
morecore(uint nu)
{
 cf0:	7179                	addi	sp,sp,-48
 cf2:	f406                	sd	ra,40(sp)
 cf4:	f022                	sd	s0,32(sp)
 cf6:	1800                	addi	s0,sp,48
 cf8:	87aa                	mv	a5,a0
 cfa:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 cfe:	fdc42783          	lw	a5,-36(s0)
 d02:	0007871b          	sext.w	a4,a5
 d06:	6785                	lui	a5,0x1
 d08:	00f77563          	bgeu	a4,a5,d12 <morecore+0x22>
    nu = 4096;
 d0c:	6785                	lui	a5,0x1
 d0e:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 d12:	fdc42783          	lw	a5,-36(s0)
 d16:	0047979b          	slliw	a5,a5,0x4
 d1a:	2781                	sext.w	a5,a5
 d1c:	2781                	sext.w	a5,a5
 d1e:	853e                	mv	a0,a5
 d20:	00000097          	auipc	ra,0x0
 d24:	99e080e7          	jalr	-1634(ra) # 6be <sbrk>
 d28:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 d2c:	fe843703          	ld	a4,-24(s0)
 d30:	57fd                	li	a5,-1
 d32:	00f71463          	bne	a4,a5,d3a <morecore+0x4a>
    return 0;
 d36:	4781                	li	a5,0
 d38:	a03d                	j	d66 <morecore+0x76>
  hp = (Header*)p;
 d3a:	fe843783          	ld	a5,-24(s0)
 d3e:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 d42:	fe043783          	ld	a5,-32(s0)
 d46:	fdc42703          	lw	a4,-36(s0)
 d4a:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 d4c:	fe043783          	ld	a5,-32(s0)
 d50:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 d52:	853e                	mv	a0,a5
 d54:	00000097          	auipc	ra,0x0
 d58:	e7a080e7          	jalr	-390(ra) # bce <free>
  return freep;
 d5c:	00000797          	auipc	a5,0x0
 d60:	2d478793          	addi	a5,a5,724 # 1030 <freep>
 d64:	639c                	ld	a5,0(a5)
}
 d66:	853e                	mv	a0,a5
 d68:	70a2                	ld	ra,40(sp)
 d6a:	7402                	ld	s0,32(sp)
 d6c:	6145                	addi	sp,sp,48
 d6e:	8082                	ret

0000000000000d70 <malloc>:

void*
malloc(uint nbytes)
{
 d70:	7139                	addi	sp,sp,-64
 d72:	fc06                	sd	ra,56(sp)
 d74:	f822                	sd	s0,48(sp)
 d76:	0080                	addi	s0,sp,64
 d78:	87aa                	mv	a5,a0
 d7a:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d7e:	fcc46783          	lwu	a5,-52(s0)
 d82:	07bd                	addi	a5,a5,15
 d84:	8391                	srli	a5,a5,0x4
 d86:	2781                	sext.w	a5,a5
 d88:	2785                	addiw	a5,a5,1
 d8a:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 d8e:	00000797          	auipc	a5,0x0
 d92:	2a278793          	addi	a5,a5,674 # 1030 <freep>
 d96:	639c                	ld	a5,0(a5)
 d98:	fef43023          	sd	a5,-32(s0)
 d9c:	fe043783          	ld	a5,-32(s0)
 da0:	ef95                	bnez	a5,ddc <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 da2:	00000797          	auipc	a5,0x0
 da6:	27e78793          	addi	a5,a5,638 # 1020 <base>
 daa:	fef43023          	sd	a5,-32(s0)
 dae:	00000797          	auipc	a5,0x0
 db2:	28278793          	addi	a5,a5,642 # 1030 <freep>
 db6:	fe043703          	ld	a4,-32(s0)
 dba:	e398                	sd	a4,0(a5)
 dbc:	00000797          	auipc	a5,0x0
 dc0:	27478793          	addi	a5,a5,628 # 1030 <freep>
 dc4:	6398                	ld	a4,0(a5)
 dc6:	00000797          	auipc	a5,0x0
 dca:	25a78793          	addi	a5,a5,602 # 1020 <base>
 dce:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 dd0:	00000797          	auipc	a5,0x0
 dd4:	25078793          	addi	a5,a5,592 # 1020 <base>
 dd8:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ddc:	fe043783          	ld	a5,-32(s0)
 de0:	639c                	ld	a5,0(a5)
 de2:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 de6:	fe843783          	ld	a5,-24(s0)
 dea:	4798                	lw	a4,8(a5)
 dec:	fdc42783          	lw	a5,-36(s0)
 df0:	2781                	sext.w	a5,a5
 df2:	06f76763          	bltu	a4,a5,e60 <malloc+0xf0>
      if(p->s.size == nunits)
 df6:	fe843783          	ld	a5,-24(s0)
 dfa:	4798                	lw	a4,8(a5)
 dfc:	fdc42783          	lw	a5,-36(s0)
 e00:	2781                	sext.w	a5,a5
 e02:	00e79963          	bne	a5,a4,e14 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 e06:	fe843783          	ld	a5,-24(s0)
 e0a:	6398                	ld	a4,0(a5)
 e0c:	fe043783          	ld	a5,-32(s0)
 e10:	e398                	sd	a4,0(a5)
 e12:	a825                	j	e4a <malloc+0xda>
      else {
        p->s.size -= nunits;
 e14:	fe843783          	ld	a5,-24(s0)
 e18:	479c                	lw	a5,8(a5)
 e1a:	fdc42703          	lw	a4,-36(s0)
 e1e:	9f99                	subw	a5,a5,a4
 e20:	0007871b          	sext.w	a4,a5
 e24:	fe843783          	ld	a5,-24(s0)
 e28:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e2a:	fe843783          	ld	a5,-24(s0)
 e2e:	479c                	lw	a5,8(a5)
 e30:	1782                	slli	a5,a5,0x20
 e32:	9381                	srli	a5,a5,0x20
 e34:	0792                	slli	a5,a5,0x4
 e36:	fe843703          	ld	a4,-24(s0)
 e3a:	97ba                	add	a5,a5,a4
 e3c:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 e40:	fe843783          	ld	a5,-24(s0)
 e44:	fdc42703          	lw	a4,-36(s0)
 e48:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 e4a:	00000797          	auipc	a5,0x0
 e4e:	1e678793          	addi	a5,a5,486 # 1030 <freep>
 e52:	fe043703          	ld	a4,-32(s0)
 e56:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 e58:	fe843783          	ld	a5,-24(s0)
 e5c:	07c1                	addi	a5,a5,16
 e5e:	a091                	j	ea2 <malloc+0x132>
    }
    if(p == freep)
 e60:	00000797          	auipc	a5,0x0
 e64:	1d078793          	addi	a5,a5,464 # 1030 <freep>
 e68:	639c                	ld	a5,0(a5)
 e6a:	fe843703          	ld	a4,-24(s0)
 e6e:	02f71063          	bne	a4,a5,e8e <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 e72:	fdc42783          	lw	a5,-36(s0)
 e76:	853e                	mv	a0,a5
 e78:	00000097          	auipc	ra,0x0
 e7c:	e78080e7          	jalr	-392(ra) # cf0 <morecore>
 e80:	fea43423          	sd	a0,-24(s0)
 e84:	fe843783          	ld	a5,-24(s0)
 e88:	e399                	bnez	a5,e8e <malloc+0x11e>
        return 0;
 e8a:	4781                	li	a5,0
 e8c:	a819                	j	ea2 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e8e:	fe843783          	ld	a5,-24(s0)
 e92:	fef43023          	sd	a5,-32(s0)
 e96:	fe843783          	ld	a5,-24(s0)
 e9a:	639c                	ld	a5,0(a5)
 e9c:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 ea0:	b799                	j	de6 <malloc+0x76>
  }
}
 ea2:	853e                	mv	a0,a5
 ea4:	70e2                	ld	ra,56(sp)
 ea6:	7442                	ld	s0,48(sp)
 ea8:	6121                	addi	sp,sp,64
 eaa:	8082                	ret
