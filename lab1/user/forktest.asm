
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
   8:	fea43423          	sd	a0,-24(s0)
  write(1, s, strlen(s));
   c:	fe843503          	ld	a0,-24(s0)
  10:	00000097          	auipc	ra,0x0
  14:	222080e7          	jalr	546(ra) # 232 <strlen>
  18:	87aa                	mv	a5,a0
  1a:	2781                	sext.w	a5,a5
  1c:	2781                	sext.w	a5,a5
  1e:	863e                	mv	a2,a5
  20:	fe843583          	ld	a1,-24(s0)
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	60e080e7          	jalr	1550(ra) # 634 <write>
}
  2e:	0001                	nop
  30:	60e2                	ld	ra,24(sp)
  32:	6442                	ld	s0,16(sp)
  34:	6105                	addi	sp,sp,32
  36:	8082                	ret

0000000000000038 <forktest>:

void
forktest(void)
{
  38:	1101                	addi	sp,sp,-32
  3a:	ec06                	sd	ra,24(sp)
  3c:	e822                	sd	s0,16(sp)
  3e:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  40:	00000517          	auipc	a0,0x0
  44:	69850513          	addi	a0,a0,1688 # 6d8 <proctree+0xc>
  48:	00000097          	auipc	ra,0x0
  4c:	fb8080e7          	jalr	-72(ra) # 0 <print>

  for(n=0; n<N; n++){
  50:	fe042623          	sw	zero,-20(s0)
  54:	a81d                	j	8a <forktest+0x52>
    pid = fork();
  56:	00000097          	auipc	ra,0x0
  5a:	5b6080e7          	jalr	1462(ra) # 60c <fork>
  5e:	87aa                	mv	a5,a0
  60:	fef42423          	sw	a5,-24(s0)
    if(pid < 0)
  64:	fe842783          	lw	a5,-24(s0)
  68:	2781                	sext.w	a5,a5
  6a:	0207c963          	bltz	a5,9c <forktest+0x64>
      break;
    if(pid == 0)
  6e:	fe842783          	lw	a5,-24(s0)
  72:	2781                	sext.w	a5,a5
  74:	e791                	bnez	a5,80 <forktest+0x48>
      exit(0);
  76:	4501                	li	a0,0
  78:	00000097          	auipc	ra,0x0
  7c:	59c080e7          	jalr	1436(ra) # 614 <exit>
  for(n=0; n<N; n++){
  80:	fec42783          	lw	a5,-20(s0)
  84:	2785                	addiw	a5,a5,1
  86:	fef42623          	sw	a5,-20(s0)
  8a:	fec42783          	lw	a5,-20(s0)
  8e:	0007871b          	sext.w	a4,a5
  92:	3e700793          	li	a5,999
  96:	fce7d0e3          	bge	a5,a4,56 <forktest+0x1e>
  9a:	a011                	j	9e <forktest+0x66>
      break;
  9c:	0001                	nop
  }

  if(n == N){
  9e:	fec42783          	lw	a5,-20(s0)
  a2:	0007871b          	sext.w	a4,a5
  a6:	3e800793          	li	a5,1000
  aa:	04f71963          	bne	a4,a5,fc <forktest+0xc4>
    print("fork claimed to work N times!\n");
  ae:	00000517          	auipc	a0,0x0
  b2:	63a50513          	addi	a0,a0,1594 # 6e8 <proctree+0x1c>
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <print>
    exit(1);
  be:	4505                	li	a0,1
  c0:	00000097          	auipc	ra,0x0
  c4:	554080e7          	jalr	1364(ra) # 614 <exit>
  }

  for(; n > 0; n--){
    if(wait(0) < 0){
  c8:	4501                	li	a0,0
  ca:	00000097          	auipc	ra,0x0
  ce:	552080e7          	jalr	1362(ra) # 61c <wait>
  d2:	87aa                	mv	a5,a0
  d4:	0007df63          	bgez	a5,f2 <forktest+0xba>
      print("wait stopped early\n");
  d8:	00000517          	auipc	a0,0x0
  dc:	63050513          	addi	a0,a0,1584 # 708 <proctree+0x3c>
  e0:	00000097          	auipc	ra,0x0
  e4:	f20080e7          	jalr	-224(ra) # 0 <print>
      exit(1);
  e8:	4505                	li	a0,1
  ea:	00000097          	auipc	ra,0x0
  ee:	52a080e7          	jalr	1322(ra) # 614 <exit>
  for(; n > 0; n--){
  f2:	fec42783          	lw	a5,-20(s0)
  f6:	37fd                	addiw	a5,a5,-1
  f8:	fef42623          	sw	a5,-20(s0)
  fc:	fec42783          	lw	a5,-20(s0)
 100:	2781                	sext.w	a5,a5
 102:	fcf043e3          	bgtz	a5,c8 <forktest+0x90>
    }
  }

  if(wait(0) != -1){
 106:	4501                	li	a0,0
 108:	00000097          	auipc	ra,0x0
 10c:	514080e7          	jalr	1300(ra) # 61c <wait>
 110:	87aa                	mv	a5,a0
 112:	873e                	mv	a4,a5
 114:	57fd                	li	a5,-1
 116:	00f70f63          	beq	a4,a5,134 <forktest+0xfc>
    print("wait got too many\n");
 11a:	00000517          	auipc	a0,0x0
 11e:	60650513          	addi	a0,a0,1542 # 720 <proctree+0x54>
 122:	00000097          	auipc	ra,0x0
 126:	ede080e7          	jalr	-290(ra) # 0 <print>
    exit(1);
 12a:	4505                	li	a0,1
 12c:	00000097          	auipc	ra,0x0
 130:	4e8080e7          	jalr	1256(ra) # 614 <exit>
  }

  print("fork test OK\n");
 134:	00000517          	auipc	a0,0x0
 138:	60450513          	addi	a0,a0,1540 # 738 <proctree+0x6c>
 13c:	00000097          	auipc	ra,0x0
 140:	ec4080e7          	jalr	-316(ra) # 0 <print>
}
 144:	0001                	nop
 146:	60e2                	ld	ra,24(sp)
 148:	6442                	ld	s0,16(sp)
 14a:	6105                	addi	sp,sp,32
 14c:	8082                	ret

000000000000014e <main>:

int
main(void)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e406                	sd	ra,8(sp)
 152:	e022                	sd	s0,0(sp)
 154:	0800                	addi	s0,sp,16
  forktest();
 156:	00000097          	auipc	ra,0x0
 15a:	ee2080e7          	jalr	-286(ra) # 38 <forktest>
  exit(0);
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	4b4080e7          	jalr	1204(ra) # 614 <exit>

0000000000000168 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 168:	1141                	addi	sp,sp,-16
 16a:	e406                	sd	ra,8(sp)
 16c:	e022                	sd	s0,0(sp)
 16e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 170:	00000097          	auipc	ra,0x0
 174:	fde080e7          	jalr	-34(ra) # 14e <main>
  exit(0);
 178:	4501                	li	a0,0
 17a:	00000097          	auipc	ra,0x0
 17e:	49a080e7          	jalr	1178(ra) # 614 <exit>

0000000000000182 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 182:	7179                	addi	sp,sp,-48
 184:	f422                	sd	s0,40(sp)
 186:	1800                	addi	s0,sp,48
 188:	fca43c23          	sd	a0,-40(s0)
 18c:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
 190:	fd843783          	ld	a5,-40(s0)
 194:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
 198:	0001                	nop
 19a:	fd043703          	ld	a4,-48(s0)
 19e:	00170793          	addi	a5,a4,1
 1a2:	fcf43823          	sd	a5,-48(s0)
 1a6:	fd843783          	ld	a5,-40(s0)
 1aa:	00178693          	addi	a3,a5,1
 1ae:	fcd43c23          	sd	a3,-40(s0)
 1b2:	00074703          	lbu	a4,0(a4)
 1b6:	00e78023          	sb	a4,0(a5)
 1ba:	0007c783          	lbu	a5,0(a5)
 1be:	fff1                	bnez	a5,19a <strcpy+0x18>
    ;
  return os;
 1c0:	fe843783          	ld	a5,-24(s0)
}
 1c4:	853e                	mv	a0,a5
 1c6:	7422                	ld	s0,40(sp)
 1c8:	6145                	addi	sp,sp,48
 1ca:	8082                	ret

00000000000001cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1cc:	1101                	addi	sp,sp,-32
 1ce:	ec22                	sd	s0,24(sp)
 1d0:	1000                	addi	s0,sp,32
 1d2:	fea43423          	sd	a0,-24(s0)
 1d6:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 1da:	a819                	j	1f0 <strcmp+0x24>
    p++, q++;
 1dc:	fe843783          	ld	a5,-24(s0)
 1e0:	0785                	addi	a5,a5,1
 1e2:	fef43423          	sd	a5,-24(s0)
 1e6:	fe043783          	ld	a5,-32(s0)
 1ea:	0785                	addi	a5,a5,1
 1ec:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 1f0:	fe843783          	ld	a5,-24(s0)
 1f4:	0007c783          	lbu	a5,0(a5)
 1f8:	cb99                	beqz	a5,20e <strcmp+0x42>
 1fa:	fe843783          	ld	a5,-24(s0)
 1fe:	0007c703          	lbu	a4,0(a5)
 202:	fe043783          	ld	a5,-32(s0)
 206:	0007c783          	lbu	a5,0(a5)
 20a:	fcf709e3          	beq	a4,a5,1dc <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 20e:	fe843783          	ld	a5,-24(s0)
 212:	0007c783          	lbu	a5,0(a5)
 216:	0007871b          	sext.w	a4,a5
 21a:	fe043783          	ld	a5,-32(s0)
 21e:	0007c783          	lbu	a5,0(a5)
 222:	2781                	sext.w	a5,a5
 224:	40f707bb          	subw	a5,a4,a5
 228:	2781                	sext.w	a5,a5
}
 22a:	853e                	mv	a0,a5
 22c:	6462                	ld	s0,24(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret

0000000000000232 <strlen>:

uint
strlen(const char *s)
{
 232:	7179                	addi	sp,sp,-48
 234:	f422                	sd	s0,40(sp)
 236:	1800                	addi	s0,sp,48
 238:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 23c:	fe042623          	sw	zero,-20(s0)
 240:	a031                	j	24c <strlen+0x1a>
 242:	fec42783          	lw	a5,-20(s0)
 246:	2785                	addiw	a5,a5,1
 248:	fef42623          	sw	a5,-20(s0)
 24c:	fec42783          	lw	a5,-20(s0)
 250:	fd843703          	ld	a4,-40(s0)
 254:	97ba                	add	a5,a5,a4
 256:	0007c783          	lbu	a5,0(a5)
 25a:	f7e5                	bnez	a5,242 <strlen+0x10>
    ;
  return n;
 25c:	fec42783          	lw	a5,-20(s0)
}
 260:	853e                	mv	a0,a5
 262:	7422                	ld	s0,40(sp)
 264:	6145                	addi	sp,sp,48
 266:	8082                	ret

0000000000000268 <memset>:

void*
memset(void *dst, int c, uint n)
{
 268:	7179                	addi	sp,sp,-48
 26a:	f422                	sd	s0,40(sp)
 26c:	1800                	addi	s0,sp,48
 26e:	fca43c23          	sd	a0,-40(s0)
 272:	87ae                	mv	a5,a1
 274:	8732                	mv	a4,a2
 276:	fcf42a23          	sw	a5,-44(s0)
 27a:	87ba                	mv	a5,a4
 27c:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 280:	fd843783          	ld	a5,-40(s0)
 284:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 288:	fe042623          	sw	zero,-20(s0)
 28c:	a00d                	j	2ae <memset+0x46>
    cdst[i] = c;
 28e:	fec42783          	lw	a5,-20(s0)
 292:	fe043703          	ld	a4,-32(s0)
 296:	97ba                	add	a5,a5,a4
 298:	fd442703          	lw	a4,-44(s0)
 29c:	0ff77713          	zext.b	a4,a4
 2a0:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 2a4:	fec42783          	lw	a5,-20(s0)
 2a8:	2785                	addiw	a5,a5,1
 2aa:	fef42623          	sw	a5,-20(s0)
 2ae:	fec42703          	lw	a4,-20(s0)
 2b2:	fd042783          	lw	a5,-48(s0)
 2b6:	2781                	sext.w	a5,a5
 2b8:	fcf76be3          	bltu	a4,a5,28e <memset+0x26>
  }
  return dst;
 2bc:	fd843783          	ld	a5,-40(s0)
}
 2c0:	853e                	mv	a0,a5
 2c2:	7422                	ld	s0,40(sp)
 2c4:	6145                	addi	sp,sp,48
 2c6:	8082                	ret

00000000000002c8 <strchr>:

char*
strchr(const char *s, char c)
{
 2c8:	1101                	addi	sp,sp,-32
 2ca:	ec22                	sd	s0,24(sp)
 2cc:	1000                	addi	s0,sp,32
 2ce:	fea43423          	sd	a0,-24(s0)
 2d2:	87ae                	mv	a5,a1
 2d4:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 2d8:	a01d                	j	2fe <strchr+0x36>
    if(*s == c)
 2da:	fe843783          	ld	a5,-24(s0)
 2de:	0007c703          	lbu	a4,0(a5)
 2e2:	fe744783          	lbu	a5,-25(s0)
 2e6:	0ff7f793          	zext.b	a5,a5
 2ea:	00e79563          	bne	a5,a4,2f4 <strchr+0x2c>
      return (char*)s;
 2ee:	fe843783          	ld	a5,-24(s0)
 2f2:	a821                	j	30a <strchr+0x42>
  for(; *s; s++)
 2f4:	fe843783          	ld	a5,-24(s0)
 2f8:	0785                	addi	a5,a5,1
 2fa:	fef43423          	sd	a5,-24(s0)
 2fe:	fe843783          	ld	a5,-24(s0)
 302:	0007c783          	lbu	a5,0(a5)
 306:	fbf1                	bnez	a5,2da <strchr+0x12>
  return 0;
 308:	4781                	li	a5,0
}
 30a:	853e                	mv	a0,a5
 30c:	6462                	ld	s0,24(sp)
 30e:	6105                	addi	sp,sp,32
 310:	8082                	ret

0000000000000312 <gets>:

char*
gets(char *buf, int max)
{
 312:	7179                	addi	sp,sp,-48
 314:	f406                	sd	ra,40(sp)
 316:	f022                	sd	s0,32(sp)
 318:	1800                	addi	s0,sp,48
 31a:	fca43c23          	sd	a0,-40(s0)
 31e:	87ae                	mv	a5,a1
 320:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 324:	fe042623          	sw	zero,-20(s0)
 328:	a8a1                	j	380 <gets+0x6e>
    cc = read(0, &c, 1);
 32a:	fe740793          	addi	a5,s0,-25
 32e:	4605                	li	a2,1
 330:	85be                	mv	a1,a5
 332:	4501                	li	a0,0
 334:	00000097          	auipc	ra,0x0
 338:	2f8080e7          	jalr	760(ra) # 62c <read>
 33c:	87aa                	mv	a5,a0
 33e:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 342:	fe842783          	lw	a5,-24(s0)
 346:	2781                	sext.w	a5,a5
 348:	04f05763          	blez	a5,396 <gets+0x84>
      break;
    buf[i++] = c;
 34c:	fec42783          	lw	a5,-20(s0)
 350:	0017871b          	addiw	a4,a5,1
 354:	fee42623          	sw	a4,-20(s0)
 358:	873e                	mv	a4,a5
 35a:	fd843783          	ld	a5,-40(s0)
 35e:	97ba                	add	a5,a5,a4
 360:	fe744703          	lbu	a4,-25(s0)
 364:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 368:	fe744783          	lbu	a5,-25(s0)
 36c:	873e                	mv	a4,a5
 36e:	47a9                	li	a5,10
 370:	02f70463          	beq	a4,a5,398 <gets+0x86>
 374:	fe744783          	lbu	a5,-25(s0)
 378:	873e                	mv	a4,a5
 37a:	47b5                	li	a5,13
 37c:	00f70e63          	beq	a4,a5,398 <gets+0x86>
  for(i=0; i+1 < max; ){
 380:	fec42783          	lw	a5,-20(s0)
 384:	2785                	addiw	a5,a5,1
 386:	0007871b          	sext.w	a4,a5
 38a:	fd442783          	lw	a5,-44(s0)
 38e:	2781                	sext.w	a5,a5
 390:	f8f74de3          	blt	a4,a5,32a <gets+0x18>
 394:	a011                	j	398 <gets+0x86>
      break;
 396:	0001                	nop
      break;
  }
  buf[i] = '\0';
 398:	fec42783          	lw	a5,-20(s0)
 39c:	fd843703          	ld	a4,-40(s0)
 3a0:	97ba                	add	a5,a5,a4
 3a2:	00078023          	sb	zero,0(a5)
  return buf;
 3a6:	fd843783          	ld	a5,-40(s0)
}
 3aa:	853e                	mv	a0,a5
 3ac:	70a2                	ld	ra,40(sp)
 3ae:	7402                	ld	s0,32(sp)
 3b0:	6145                	addi	sp,sp,48
 3b2:	8082                	ret

00000000000003b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3b4:	7179                	addi	sp,sp,-48
 3b6:	f406                	sd	ra,40(sp)
 3b8:	f022                	sd	s0,32(sp)
 3ba:	1800                	addi	s0,sp,48
 3bc:	fca43c23          	sd	a0,-40(s0)
 3c0:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c4:	4581                	li	a1,0
 3c6:	fd843503          	ld	a0,-40(s0)
 3ca:	00000097          	auipc	ra,0x0
 3ce:	28a080e7          	jalr	650(ra) # 654 <open>
 3d2:	87aa                	mv	a5,a0
 3d4:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 3d8:	fec42783          	lw	a5,-20(s0)
 3dc:	2781                	sext.w	a5,a5
 3de:	0007d463          	bgez	a5,3e6 <stat+0x32>
    return -1;
 3e2:	57fd                	li	a5,-1
 3e4:	a035                	j	410 <stat+0x5c>
  r = fstat(fd, st);
 3e6:	fec42783          	lw	a5,-20(s0)
 3ea:	fd043583          	ld	a1,-48(s0)
 3ee:	853e                	mv	a0,a5
 3f0:	00000097          	auipc	ra,0x0
 3f4:	27c080e7          	jalr	636(ra) # 66c <fstat>
 3f8:	87aa                	mv	a5,a0
 3fa:	fef42423          	sw	a5,-24(s0)
  close(fd);
 3fe:	fec42783          	lw	a5,-20(s0)
 402:	853e                	mv	a0,a5
 404:	00000097          	auipc	ra,0x0
 408:	238080e7          	jalr	568(ra) # 63c <close>
  return r;
 40c:	fe842783          	lw	a5,-24(s0)
}
 410:	853e                	mv	a0,a5
 412:	70a2                	ld	ra,40(sp)
 414:	7402                	ld	s0,32(sp)
 416:	6145                	addi	sp,sp,48
 418:	8082                	ret

000000000000041a <atoi>:

int
atoi(const char *s)
{
 41a:	7179                	addi	sp,sp,-48
 41c:	f422                	sd	s0,40(sp)
 41e:	1800                	addi	s0,sp,48
 420:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 424:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 428:	a81d                	j	45e <atoi+0x44>
    n = n*10 + *s++ - '0';
 42a:	fec42783          	lw	a5,-20(s0)
 42e:	873e                	mv	a4,a5
 430:	87ba                	mv	a5,a4
 432:	0027979b          	slliw	a5,a5,0x2
 436:	9fb9                	addw	a5,a5,a4
 438:	0017979b          	slliw	a5,a5,0x1
 43c:	0007871b          	sext.w	a4,a5
 440:	fd843783          	ld	a5,-40(s0)
 444:	00178693          	addi	a3,a5,1
 448:	fcd43c23          	sd	a3,-40(s0)
 44c:	0007c783          	lbu	a5,0(a5)
 450:	2781                	sext.w	a5,a5
 452:	9fb9                	addw	a5,a5,a4
 454:	2781                	sext.w	a5,a5
 456:	fd07879b          	addiw	a5,a5,-48
 45a:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 45e:	fd843783          	ld	a5,-40(s0)
 462:	0007c783          	lbu	a5,0(a5)
 466:	873e                	mv	a4,a5
 468:	02f00793          	li	a5,47
 46c:	00e7fb63          	bgeu	a5,a4,482 <atoi+0x68>
 470:	fd843783          	ld	a5,-40(s0)
 474:	0007c783          	lbu	a5,0(a5)
 478:	873e                	mv	a4,a5
 47a:	03900793          	li	a5,57
 47e:	fae7f6e3          	bgeu	a5,a4,42a <atoi+0x10>
  return n;
 482:	fec42783          	lw	a5,-20(s0)
}
 486:	853e                	mv	a0,a5
 488:	7422                	ld	s0,40(sp)
 48a:	6145                	addi	sp,sp,48
 48c:	8082                	ret

000000000000048e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 48e:	7139                	addi	sp,sp,-64
 490:	fc22                	sd	s0,56(sp)
 492:	0080                	addi	s0,sp,64
 494:	fca43c23          	sd	a0,-40(s0)
 498:	fcb43823          	sd	a1,-48(s0)
 49c:	87b2                	mv	a5,a2
 49e:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 4a2:	fd843783          	ld	a5,-40(s0)
 4a6:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 4aa:	fd043783          	ld	a5,-48(s0)
 4ae:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 4b2:	fe043703          	ld	a4,-32(s0)
 4b6:	fe843783          	ld	a5,-24(s0)
 4ba:	02e7fc63          	bgeu	a5,a4,4f2 <memmove+0x64>
    while(n-- > 0)
 4be:	a00d                	j	4e0 <memmove+0x52>
      *dst++ = *src++;
 4c0:	fe043703          	ld	a4,-32(s0)
 4c4:	00170793          	addi	a5,a4,1
 4c8:	fef43023          	sd	a5,-32(s0)
 4cc:	fe843783          	ld	a5,-24(s0)
 4d0:	00178693          	addi	a3,a5,1
 4d4:	fed43423          	sd	a3,-24(s0)
 4d8:	00074703          	lbu	a4,0(a4)
 4dc:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 4e0:	fcc42783          	lw	a5,-52(s0)
 4e4:	fff7871b          	addiw	a4,a5,-1
 4e8:	fce42623          	sw	a4,-52(s0)
 4ec:	fcf04ae3          	bgtz	a5,4c0 <memmove+0x32>
 4f0:	a891                	j	544 <memmove+0xb6>
  } else {
    dst += n;
 4f2:	fcc42783          	lw	a5,-52(s0)
 4f6:	fe843703          	ld	a4,-24(s0)
 4fa:	97ba                	add	a5,a5,a4
 4fc:	fef43423          	sd	a5,-24(s0)
    src += n;
 500:	fcc42783          	lw	a5,-52(s0)
 504:	fe043703          	ld	a4,-32(s0)
 508:	97ba                	add	a5,a5,a4
 50a:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 50e:	a01d                	j	534 <memmove+0xa6>
      *--dst = *--src;
 510:	fe043783          	ld	a5,-32(s0)
 514:	17fd                	addi	a5,a5,-1
 516:	fef43023          	sd	a5,-32(s0)
 51a:	fe843783          	ld	a5,-24(s0)
 51e:	17fd                	addi	a5,a5,-1
 520:	fef43423          	sd	a5,-24(s0)
 524:	fe043783          	ld	a5,-32(s0)
 528:	0007c703          	lbu	a4,0(a5)
 52c:	fe843783          	ld	a5,-24(s0)
 530:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 534:	fcc42783          	lw	a5,-52(s0)
 538:	fff7871b          	addiw	a4,a5,-1
 53c:	fce42623          	sw	a4,-52(s0)
 540:	fcf048e3          	bgtz	a5,510 <memmove+0x82>
  }
  return vdst;
 544:	fd843783          	ld	a5,-40(s0)
}
 548:	853e                	mv	a0,a5
 54a:	7462                	ld	s0,56(sp)
 54c:	6121                	addi	sp,sp,64
 54e:	8082                	ret

0000000000000550 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 550:	7139                	addi	sp,sp,-64
 552:	fc22                	sd	s0,56(sp)
 554:	0080                	addi	s0,sp,64
 556:	fca43c23          	sd	a0,-40(s0)
 55a:	fcb43823          	sd	a1,-48(s0)
 55e:	87b2                	mv	a5,a2
 560:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 564:	fd843783          	ld	a5,-40(s0)
 568:	fef43423          	sd	a5,-24(s0)
 56c:	fd043783          	ld	a5,-48(s0)
 570:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 574:	a0a1                	j	5bc <memcmp+0x6c>
    if (*p1 != *p2) {
 576:	fe843783          	ld	a5,-24(s0)
 57a:	0007c703          	lbu	a4,0(a5)
 57e:	fe043783          	ld	a5,-32(s0)
 582:	0007c783          	lbu	a5,0(a5)
 586:	02f70163          	beq	a4,a5,5a8 <memcmp+0x58>
      return *p1 - *p2;
 58a:	fe843783          	ld	a5,-24(s0)
 58e:	0007c783          	lbu	a5,0(a5)
 592:	0007871b          	sext.w	a4,a5
 596:	fe043783          	ld	a5,-32(s0)
 59a:	0007c783          	lbu	a5,0(a5)
 59e:	2781                	sext.w	a5,a5
 5a0:	40f707bb          	subw	a5,a4,a5
 5a4:	2781                	sext.w	a5,a5
 5a6:	a01d                	j	5cc <memcmp+0x7c>
    }
    p1++;
 5a8:	fe843783          	ld	a5,-24(s0)
 5ac:	0785                	addi	a5,a5,1
 5ae:	fef43423          	sd	a5,-24(s0)
    p2++;
 5b2:	fe043783          	ld	a5,-32(s0)
 5b6:	0785                	addi	a5,a5,1
 5b8:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 5bc:	fcc42783          	lw	a5,-52(s0)
 5c0:	fff7871b          	addiw	a4,a5,-1
 5c4:	fce42623          	sw	a4,-52(s0)
 5c8:	f7dd                	bnez	a5,576 <memcmp+0x26>
  }
  return 0;
 5ca:	4781                	li	a5,0
}
 5cc:	853e                	mv	a0,a5
 5ce:	7462                	ld	s0,56(sp)
 5d0:	6121                	addi	sp,sp,64
 5d2:	8082                	ret

00000000000005d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5d4:	7179                	addi	sp,sp,-48
 5d6:	f406                	sd	ra,40(sp)
 5d8:	f022                	sd	s0,32(sp)
 5da:	1800                	addi	s0,sp,48
 5dc:	fea43423          	sd	a0,-24(s0)
 5e0:	feb43023          	sd	a1,-32(s0)
 5e4:	87b2                	mv	a5,a2
 5e6:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 5ea:	fdc42783          	lw	a5,-36(s0)
 5ee:	863e                	mv	a2,a5
 5f0:	fe043583          	ld	a1,-32(s0)
 5f4:	fe843503          	ld	a0,-24(s0)
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e96080e7          	jalr	-362(ra) # 48e <memmove>
 600:	87aa                	mv	a5,a0
}
 602:	853e                	mv	a0,a5
 604:	70a2                	ld	ra,40(sp)
 606:	7402                	ld	s0,32(sp)
 608:	6145                	addi	sp,sp,48
 60a:	8082                	ret

000000000000060c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 60c:	4885                	li	a7,1
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <exit>:
.global exit
exit:
 li a7, SYS_exit
 614:	4889                	li	a7,2
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <wait>:
.global wait
wait:
 li a7, SYS_wait
 61c:	488d                	li	a7,3
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 624:	4891                	li	a7,4
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <read>:
.global read
read:
 li a7, SYS_read
 62c:	4895                	li	a7,5
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <write>:
.global write
write:
 li a7, SYS_write
 634:	48c1                	li	a7,16
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <close>:
.global close
close:
 li a7, SYS_close
 63c:	48d5                	li	a7,21
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <kill>:
.global kill
kill:
 li a7, SYS_kill
 644:	4899                	li	a7,6
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <exec>:
.global exec
exec:
 li a7, SYS_exec
 64c:	489d                	li	a7,7
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <open>:
.global open
open:
 li a7, SYS_open
 654:	48bd                	li	a7,15
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 65c:	48c5                	li	a7,17
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 664:	48c9                	li	a7,18
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 66c:	48a1                	li	a7,8
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <link>:
.global link
link:
 li a7, SYS_link
 674:	48cd                	li	a7,19
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 67c:	48d1                	li	a7,20
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 684:	48a5                	li	a7,9
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <dup>:
.global dup
dup:
 li a7, SYS_dup
 68c:	48a9                	li	a7,10
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 694:	48ad                	li	a7,11
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 69c:	48b1                	li	a7,12
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6a4:	48b5                	li	a7,13
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6ac:	48b9                	li	a7,14
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <hello>:
.global hello
hello:
 li a7, SYS_hello
 6b4:	48d9                	li	a7,22
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <ps>:
.global ps
ps:
 li a7, SYS_ps
 6bc:	48e1                	li	a7,24
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 6c4:	48dd                	li	a7,23
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 6cc:	48e5                	li	a7,25
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret
