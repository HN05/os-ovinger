
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
   8:	87aa                	mv	a5,a0
   a:	fcf42e23          	sw	a5,-36(s0)
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
   e:	a091                	j	52 <cat+0x52>
    if (write(1, buf, n) != n) {
  10:	fec42783          	lw	a5,-20(s0)
  14:	863e                	mv	a2,a5
  16:	00001597          	auipc	a1,0x1
  1a:	00a58593          	addi	a1,a1,10 # 1020 <buf>
  1e:	4505                	li	a0,1
  20:	00000097          	auipc	ra,0x0
  24:	62c080e7          	jalr	1580(ra) # 64c <write>
  28:	87aa                	mv	a5,a0
  2a:	873e                	mv	a4,a5
  2c:	fec42783          	lw	a5,-20(s0)
  30:	2781                	sext.w	a5,a5
  32:	02e78063          	beq	a5,a4,52 <cat+0x52>
      fprintf(2, "cat: write error\n");
  36:	00001597          	auipc	a1,0x1
  3a:	e7a58593          	addi	a1,a1,-390 # eb0 <malloc+0x14a>
  3e:	4509                	li	a0,2
  40:	00001097          	auipc	ra,0x1
  44:	adc080e7          	jalr	-1316(ra) # b1c <fprintf>
      exit(1);
  48:	4505                	li	a0,1
  4a:	00000097          	auipc	ra,0x0
  4e:	5e2080e7          	jalr	1506(ra) # 62c <exit>
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  52:	fdc42783          	lw	a5,-36(s0)
  56:	20000613          	li	a2,512
  5a:	00001597          	auipc	a1,0x1
  5e:	fc658593          	addi	a1,a1,-58 # 1020 <buf>
  62:	853e                	mv	a0,a5
  64:	00000097          	auipc	ra,0x0
  68:	5e0080e7          	jalr	1504(ra) # 644 <read>
  6c:	87aa                	mv	a5,a0
  6e:	fef42623          	sw	a5,-20(s0)
  72:	fec42783          	lw	a5,-20(s0)
  76:	2781                	sext.w	a5,a5
  78:	f8f04ce3          	bgtz	a5,10 <cat+0x10>
    }
  }
  if(n < 0){
  7c:	fec42783          	lw	a5,-20(s0)
  80:	2781                	sext.w	a5,a5
  82:	0207d063          	bgez	a5,a2 <cat+0xa2>
    fprintf(2, "cat: read error\n");
  86:	00001597          	auipc	a1,0x1
  8a:	e4258593          	addi	a1,a1,-446 # ec8 <malloc+0x162>
  8e:	4509                	li	a0,2
  90:	00001097          	auipc	ra,0x1
  94:	a8c080e7          	jalr	-1396(ra) # b1c <fprintf>
    exit(1);
  98:	4505                	li	a0,1
  9a:	00000097          	auipc	ra,0x0
  9e:	592080e7          	jalr	1426(ra) # 62c <exit>
  }
}
  a2:	0001                	nop
  a4:	70a2                	ld	ra,40(sp)
  a6:	7402                	ld	s0,32(sp)
  a8:	6145                	addi	sp,sp,48
  aa:	8082                	ret

00000000000000ac <main>:

int
main(int argc, char *argv[])
{
  ac:	7179                	addi	sp,sp,-48
  ae:	f406                	sd	ra,40(sp)
  b0:	f022                	sd	s0,32(sp)
  b2:	1800                	addi	s0,sp,48
  b4:	87aa                	mv	a5,a0
  b6:	fcb43823          	sd	a1,-48(s0)
  ba:	fcf42e23          	sw	a5,-36(s0)
  int fd, i;

  if(argc <= 1){
  be:	fdc42783          	lw	a5,-36(s0)
  c2:	0007871b          	sext.w	a4,a5
  c6:	4785                	li	a5,1
  c8:	00e7cc63          	blt	a5,a4,e0 <main+0x34>
    cat(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	f32080e7          	jalr	-206(ra) # 0 <cat>
    exit(0);
  d6:	4501                	li	a0,0
  d8:	00000097          	auipc	ra,0x0
  dc:	554080e7          	jalr	1364(ra) # 62c <exit>
  }

  for(i = 1; i < argc; i++){
  e0:	4785                	li	a5,1
  e2:	fef42623          	sw	a5,-20(s0)
  e6:	a8bd                	j	164 <main+0xb8>
    if((fd = open(argv[i], 0)) < 0){
  e8:	fec42783          	lw	a5,-20(s0)
  ec:	078e                	slli	a5,a5,0x3
  ee:	fd043703          	ld	a4,-48(s0)
  f2:	97ba                	add	a5,a5,a4
  f4:	639c                	ld	a5,0(a5)
  f6:	4581                	li	a1,0
  f8:	853e                	mv	a0,a5
  fa:	00000097          	auipc	ra,0x0
  fe:	572080e7          	jalr	1394(ra) # 66c <open>
 102:	87aa                	mv	a5,a0
 104:	fef42423          	sw	a5,-24(s0)
 108:	fe842783          	lw	a5,-24(s0)
 10c:	2781                	sext.w	a5,a5
 10e:	0207d863          	bgez	a5,13e <main+0x92>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
 112:	fec42783          	lw	a5,-20(s0)
 116:	078e                	slli	a5,a5,0x3
 118:	fd043703          	ld	a4,-48(s0)
 11c:	97ba                	add	a5,a5,a4
 11e:	639c                	ld	a5,0(a5)
 120:	863e                	mv	a2,a5
 122:	00001597          	auipc	a1,0x1
 126:	dbe58593          	addi	a1,a1,-578 # ee0 <malloc+0x17a>
 12a:	4509                	li	a0,2
 12c:	00001097          	auipc	ra,0x1
 130:	9f0080e7          	jalr	-1552(ra) # b1c <fprintf>
      exit(1);
 134:	4505                	li	a0,1
 136:	00000097          	auipc	ra,0x0
 13a:	4f6080e7          	jalr	1270(ra) # 62c <exit>
    }
    cat(fd);
 13e:	fe842783          	lw	a5,-24(s0)
 142:	853e                	mv	a0,a5
 144:	00000097          	auipc	ra,0x0
 148:	ebc080e7          	jalr	-324(ra) # 0 <cat>
    close(fd);
 14c:	fe842783          	lw	a5,-24(s0)
 150:	853e                	mv	a0,a5
 152:	00000097          	auipc	ra,0x0
 156:	502080e7          	jalr	1282(ra) # 654 <close>
  for(i = 1; i < argc; i++){
 15a:	fec42783          	lw	a5,-20(s0)
 15e:	2785                	addiw	a5,a5,1
 160:	fef42623          	sw	a5,-20(s0)
 164:	fec42783          	lw	a5,-20(s0)
 168:	873e                	mv	a4,a5
 16a:	fdc42783          	lw	a5,-36(s0)
 16e:	2701                	sext.w	a4,a4
 170:	2781                	sext.w	a5,a5
 172:	f6f74be3          	blt	a4,a5,e8 <main+0x3c>
  }
  exit(0);
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	4b4080e7          	jalr	1204(ra) # 62c <exit>

0000000000000180 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 180:	1141                	addi	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	addi	s0,sp,16
  extern int main();
  main();
 188:	00000097          	auipc	ra,0x0
 18c:	f24080e7          	jalr	-220(ra) # ac <main>
  exit(0);
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	49a080e7          	jalr	1178(ra) # 62c <exit>

000000000000019a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 19a:	7179                	addi	sp,sp,-48
 19c:	f422                	sd	s0,40(sp)
 19e:	1800                	addi	s0,sp,48
 1a0:	fca43c23          	sd	a0,-40(s0)
 1a4:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
 1a8:	fd843783          	ld	a5,-40(s0)
 1ac:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
 1b0:	0001                	nop
 1b2:	fd043703          	ld	a4,-48(s0)
 1b6:	00170793          	addi	a5,a4,1
 1ba:	fcf43823          	sd	a5,-48(s0)
 1be:	fd843783          	ld	a5,-40(s0)
 1c2:	00178693          	addi	a3,a5,1
 1c6:	fcd43c23          	sd	a3,-40(s0)
 1ca:	00074703          	lbu	a4,0(a4)
 1ce:	00e78023          	sb	a4,0(a5)
 1d2:	0007c783          	lbu	a5,0(a5)
 1d6:	fff1                	bnez	a5,1b2 <strcpy+0x18>
    ;
  return os;
 1d8:	fe843783          	ld	a5,-24(s0)
}
 1dc:	853e                	mv	a0,a5
 1de:	7422                	ld	s0,40(sp)
 1e0:	6145                	addi	sp,sp,48
 1e2:	8082                	ret

00000000000001e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e4:	1101                	addi	sp,sp,-32
 1e6:	ec22                	sd	s0,24(sp)
 1e8:	1000                	addi	s0,sp,32
 1ea:	fea43423          	sd	a0,-24(s0)
 1ee:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 1f2:	a819                	j	208 <strcmp+0x24>
    p++, q++;
 1f4:	fe843783          	ld	a5,-24(s0)
 1f8:	0785                	addi	a5,a5,1
 1fa:	fef43423          	sd	a5,-24(s0)
 1fe:	fe043783          	ld	a5,-32(s0)
 202:	0785                	addi	a5,a5,1
 204:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 208:	fe843783          	ld	a5,-24(s0)
 20c:	0007c783          	lbu	a5,0(a5)
 210:	cb99                	beqz	a5,226 <strcmp+0x42>
 212:	fe843783          	ld	a5,-24(s0)
 216:	0007c703          	lbu	a4,0(a5)
 21a:	fe043783          	ld	a5,-32(s0)
 21e:	0007c783          	lbu	a5,0(a5)
 222:	fcf709e3          	beq	a4,a5,1f4 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 226:	fe843783          	ld	a5,-24(s0)
 22a:	0007c783          	lbu	a5,0(a5)
 22e:	0007871b          	sext.w	a4,a5
 232:	fe043783          	ld	a5,-32(s0)
 236:	0007c783          	lbu	a5,0(a5)
 23a:	2781                	sext.w	a5,a5
 23c:	40f707bb          	subw	a5,a4,a5
 240:	2781                	sext.w	a5,a5
}
 242:	853e                	mv	a0,a5
 244:	6462                	ld	s0,24(sp)
 246:	6105                	addi	sp,sp,32
 248:	8082                	ret

000000000000024a <strlen>:

uint
strlen(const char *s)
{
 24a:	7179                	addi	sp,sp,-48
 24c:	f422                	sd	s0,40(sp)
 24e:	1800                	addi	s0,sp,48
 250:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 254:	fe042623          	sw	zero,-20(s0)
 258:	a031                	j	264 <strlen+0x1a>
 25a:	fec42783          	lw	a5,-20(s0)
 25e:	2785                	addiw	a5,a5,1
 260:	fef42623          	sw	a5,-20(s0)
 264:	fec42783          	lw	a5,-20(s0)
 268:	fd843703          	ld	a4,-40(s0)
 26c:	97ba                	add	a5,a5,a4
 26e:	0007c783          	lbu	a5,0(a5)
 272:	f7e5                	bnez	a5,25a <strlen+0x10>
    ;
  return n;
 274:	fec42783          	lw	a5,-20(s0)
}
 278:	853e                	mv	a0,a5
 27a:	7422                	ld	s0,40(sp)
 27c:	6145                	addi	sp,sp,48
 27e:	8082                	ret

0000000000000280 <memset>:

void*
memset(void *dst, int c, uint n)
{
 280:	7179                	addi	sp,sp,-48
 282:	f422                	sd	s0,40(sp)
 284:	1800                	addi	s0,sp,48
 286:	fca43c23          	sd	a0,-40(s0)
 28a:	87ae                	mv	a5,a1
 28c:	8732                	mv	a4,a2
 28e:	fcf42a23          	sw	a5,-44(s0)
 292:	87ba                	mv	a5,a4
 294:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 298:	fd843783          	ld	a5,-40(s0)
 29c:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 2a0:	fe042623          	sw	zero,-20(s0)
 2a4:	a00d                	j	2c6 <memset+0x46>
    cdst[i] = c;
 2a6:	fec42783          	lw	a5,-20(s0)
 2aa:	fe043703          	ld	a4,-32(s0)
 2ae:	97ba                	add	a5,a5,a4
 2b0:	fd442703          	lw	a4,-44(s0)
 2b4:	0ff77713          	zext.b	a4,a4
 2b8:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 2bc:	fec42783          	lw	a5,-20(s0)
 2c0:	2785                	addiw	a5,a5,1
 2c2:	fef42623          	sw	a5,-20(s0)
 2c6:	fec42703          	lw	a4,-20(s0)
 2ca:	fd042783          	lw	a5,-48(s0)
 2ce:	2781                	sext.w	a5,a5
 2d0:	fcf76be3          	bltu	a4,a5,2a6 <memset+0x26>
  }
  return dst;
 2d4:	fd843783          	ld	a5,-40(s0)
}
 2d8:	853e                	mv	a0,a5
 2da:	7422                	ld	s0,40(sp)
 2dc:	6145                	addi	sp,sp,48
 2de:	8082                	ret

00000000000002e0 <strchr>:

char*
strchr(const char *s, char c)
{
 2e0:	1101                	addi	sp,sp,-32
 2e2:	ec22                	sd	s0,24(sp)
 2e4:	1000                	addi	s0,sp,32
 2e6:	fea43423          	sd	a0,-24(s0)
 2ea:	87ae                	mv	a5,a1
 2ec:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 2f0:	a01d                	j	316 <strchr+0x36>
    if(*s == c)
 2f2:	fe843783          	ld	a5,-24(s0)
 2f6:	0007c703          	lbu	a4,0(a5)
 2fa:	fe744783          	lbu	a5,-25(s0)
 2fe:	0ff7f793          	zext.b	a5,a5
 302:	00e79563          	bne	a5,a4,30c <strchr+0x2c>
      return (char*)s;
 306:	fe843783          	ld	a5,-24(s0)
 30a:	a821                	j	322 <strchr+0x42>
  for(; *s; s++)
 30c:	fe843783          	ld	a5,-24(s0)
 310:	0785                	addi	a5,a5,1
 312:	fef43423          	sd	a5,-24(s0)
 316:	fe843783          	ld	a5,-24(s0)
 31a:	0007c783          	lbu	a5,0(a5)
 31e:	fbf1                	bnez	a5,2f2 <strchr+0x12>
  return 0;
 320:	4781                	li	a5,0
}
 322:	853e                	mv	a0,a5
 324:	6462                	ld	s0,24(sp)
 326:	6105                	addi	sp,sp,32
 328:	8082                	ret

000000000000032a <gets>:

char*
gets(char *buf, int max)
{
 32a:	7179                	addi	sp,sp,-48
 32c:	f406                	sd	ra,40(sp)
 32e:	f022                	sd	s0,32(sp)
 330:	1800                	addi	s0,sp,48
 332:	fca43c23          	sd	a0,-40(s0)
 336:	87ae                	mv	a5,a1
 338:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33c:	fe042623          	sw	zero,-20(s0)
 340:	a8a1                	j	398 <gets+0x6e>
    cc = read(0, &c, 1);
 342:	fe740793          	addi	a5,s0,-25
 346:	4605                	li	a2,1
 348:	85be                	mv	a1,a5
 34a:	4501                	li	a0,0
 34c:	00000097          	auipc	ra,0x0
 350:	2f8080e7          	jalr	760(ra) # 644 <read>
 354:	87aa                	mv	a5,a0
 356:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 35a:	fe842783          	lw	a5,-24(s0)
 35e:	2781                	sext.w	a5,a5
 360:	04f05763          	blez	a5,3ae <gets+0x84>
      break;
    buf[i++] = c;
 364:	fec42783          	lw	a5,-20(s0)
 368:	0017871b          	addiw	a4,a5,1
 36c:	fee42623          	sw	a4,-20(s0)
 370:	873e                	mv	a4,a5
 372:	fd843783          	ld	a5,-40(s0)
 376:	97ba                	add	a5,a5,a4
 378:	fe744703          	lbu	a4,-25(s0)
 37c:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 380:	fe744783          	lbu	a5,-25(s0)
 384:	873e                	mv	a4,a5
 386:	47a9                	li	a5,10
 388:	02f70463          	beq	a4,a5,3b0 <gets+0x86>
 38c:	fe744783          	lbu	a5,-25(s0)
 390:	873e                	mv	a4,a5
 392:	47b5                	li	a5,13
 394:	00f70e63          	beq	a4,a5,3b0 <gets+0x86>
  for(i=0; i+1 < max; ){
 398:	fec42783          	lw	a5,-20(s0)
 39c:	2785                	addiw	a5,a5,1
 39e:	0007871b          	sext.w	a4,a5
 3a2:	fd442783          	lw	a5,-44(s0)
 3a6:	2781                	sext.w	a5,a5
 3a8:	f8f74de3          	blt	a4,a5,342 <gets+0x18>
 3ac:	a011                	j	3b0 <gets+0x86>
      break;
 3ae:	0001                	nop
      break;
  }
  buf[i] = '\0';
 3b0:	fec42783          	lw	a5,-20(s0)
 3b4:	fd843703          	ld	a4,-40(s0)
 3b8:	97ba                	add	a5,a5,a4
 3ba:	00078023          	sb	zero,0(a5)
  return buf;
 3be:	fd843783          	ld	a5,-40(s0)
}
 3c2:	853e                	mv	a0,a5
 3c4:	70a2                	ld	ra,40(sp)
 3c6:	7402                	ld	s0,32(sp)
 3c8:	6145                	addi	sp,sp,48
 3ca:	8082                	ret

00000000000003cc <stat>:

int
stat(const char *n, struct stat *st)
{
 3cc:	7179                	addi	sp,sp,-48
 3ce:	f406                	sd	ra,40(sp)
 3d0:	f022                	sd	s0,32(sp)
 3d2:	1800                	addi	s0,sp,48
 3d4:	fca43c23          	sd	a0,-40(s0)
 3d8:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3dc:	4581                	li	a1,0
 3de:	fd843503          	ld	a0,-40(s0)
 3e2:	00000097          	auipc	ra,0x0
 3e6:	28a080e7          	jalr	650(ra) # 66c <open>
 3ea:	87aa                	mv	a5,a0
 3ec:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 3f0:	fec42783          	lw	a5,-20(s0)
 3f4:	2781                	sext.w	a5,a5
 3f6:	0007d463          	bgez	a5,3fe <stat+0x32>
    return -1;
 3fa:	57fd                	li	a5,-1
 3fc:	a035                	j	428 <stat+0x5c>
  r = fstat(fd, st);
 3fe:	fec42783          	lw	a5,-20(s0)
 402:	fd043583          	ld	a1,-48(s0)
 406:	853e                	mv	a0,a5
 408:	00000097          	auipc	ra,0x0
 40c:	27c080e7          	jalr	636(ra) # 684 <fstat>
 410:	87aa                	mv	a5,a0
 412:	fef42423          	sw	a5,-24(s0)
  close(fd);
 416:	fec42783          	lw	a5,-20(s0)
 41a:	853e                	mv	a0,a5
 41c:	00000097          	auipc	ra,0x0
 420:	238080e7          	jalr	568(ra) # 654 <close>
  return r;
 424:	fe842783          	lw	a5,-24(s0)
}
 428:	853e                	mv	a0,a5
 42a:	70a2                	ld	ra,40(sp)
 42c:	7402                	ld	s0,32(sp)
 42e:	6145                	addi	sp,sp,48
 430:	8082                	ret

0000000000000432 <atoi>:

int
atoi(const char *s)
{
 432:	7179                	addi	sp,sp,-48
 434:	f422                	sd	s0,40(sp)
 436:	1800                	addi	s0,sp,48
 438:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 43c:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 440:	a81d                	j	476 <atoi+0x44>
    n = n*10 + *s++ - '0';
 442:	fec42783          	lw	a5,-20(s0)
 446:	873e                	mv	a4,a5
 448:	87ba                	mv	a5,a4
 44a:	0027979b          	slliw	a5,a5,0x2
 44e:	9fb9                	addw	a5,a5,a4
 450:	0017979b          	slliw	a5,a5,0x1
 454:	0007871b          	sext.w	a4,a5
 458:	fd843783          	ld	a5,-40(s0)
 45c:	00178693          	addi	a3,a5,1
 460:	fcd43c23          	sd	a3,-40(s0)
 464:	0007c783          	lbu	a5,0(a5)
 468:	2781                	sext.w	a5,a5
 46a:	9fb9                	addw	a5,a5,a4
 46c:	2781                	sext.w	a5,a5
 46e:	fd07879b          	addiw	a5,a5,-48
 472:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 476:	fd843783          	ld	a5,-40(s0)
 47a:	0007c783          	lbu	a5,0(a5)
 47e:	873e                	mv	a4,a5
 480:	02f00793          	li	a5,47
 484:	00e7fb63          	bgeu	a5,a4,49a <atoi+0x68>
 488:	fd843783          	ld	a5,-40(s0)
 48c:	0007c783          	lbu	a5,0(a5)
 490:	873e                	mv	a4,a5
 492:	03900793          	li	a5,57
 496:	fae7f6e3          	bgeu	a5,a4,442 <atoi+0x10>
  return n;
 49a:	fec42783          	lw	a5,-20(s0)
}
 49e:	853e                	mv	a0,a5
 4a0:	7422                	ld	s0,40(sp)
 4a2:	6145                	addi	sp,sp,48
 4a4:	8082                	ret

00000000000004a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a6:	7139                	addi	sp,sp,-64
 4a8:	fc22                	sd	s0,56(sp)
 4aa:	0080                	addi	s0,sp,64
 4ac:	fca43c23          	sd	a0,-40(s0)
 4b0:	fcb43823          	sd	a1,-48(s0)
 4b4:	87b2                	mv	a5,a2
 4b6:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 4ba:	fd843783          	ld	a5,-40(s0)
 4be:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 4c2:	fd043783          	ld	a5,-48(s0)
 4c6:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 4ca:	fe043703          	ld	a4,-32(s0)
 4ce:	fe843783          	ld	a5,-24(s0)
 4d2:	02e7fc63          	bgeu	a5,a4,50a <memmove+0x64>
    while(n-- > 0)
 4d6:	a00d                	j	4f8 <memmove+0x52>
      *dst++ = *src++;
 4d8:	fe043703          	ld	a4,-32(s0)
 4dc:	00170793          	addi	a5,a4,1
 4e0:	fef43023          	sd	a5,-32(s0)
 4e4:	fe843783          	ld	a5,-24(s0)
 4e8:	00178693          	addi	a3,a5,1
 4ec:	fed43423          	sd	a3,-24(s0)
 4f0:	00074703          	lbu	a4,0(a4)
 4f4:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 4f8:	fcc42783          	lw	a5,-52(s0)
 4fc:	fff7871b          	addiw	a4,a5,-1
 500:	fce42623          	sw	a4,-52(s0)
 504:	fcf04ae3          	bgtz	a5,4d8 <memmove+0x32>
 508:	a891                	j	55c <memmove+0xb6>
  } else {
    dst += n;
 50a:	fcc42783          	lw	a5,-52(s0)
 50e:	fe843703          	ld	a4,-24(s0)
 512:	97ba                	add	a5,a5,a4
 514:	fef43423          	sd	a5,-24(s0)
    src += n;
 518:	fcc42783          	lw	a5,-52(s0)
 51c:	fe043703          	ld	a4,-32(s0)
 520:	97ba                	add	a5,a5,a4
 522:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 526:	a01d                	j	54c <memmove+0xa6>
      *--dst = *--src;
 528:	fe043783          	ld	a5,-32(s0)
 52c:	17fd                	addi	a5,a5,-1
 52e:	fef43023          	sd	a5,-32(s0)
 532:	fe843783          	ld	a5,-24(s0)
 536:	17fd                	addi	a5,a5,-1
 538:	fef43423          	sd	a5,-24(s0)
 53c:	fe043783          	ld	a5,-32(s0)
 540:	0007c703          	lbu	a4,0(a5)
 544:	fe843783          	ld	a5,-24(s0)
 548:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 54c:	fcc42783          	lw	a5,-52(s0)
 550:	fff7871b          	addiw	a4,a5,-1
 554:	fce42623          	sw	a4,-52(s0)
 558:	fcf048e3          	bgtz	a5,528 <memmove+0x82>
  }
  return vdst;
 55c:	fd843783          	ld	a5,-40(s0)
}
 560:	853e                	mv	a0,a5
 562:	7462                	ld	s0,56(sp)
 564:	6121                	addi	sp,sp,64
 566:	8082                	ret

0000000000000568 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 568:	7139                	addi	sp,sp,-64
 56a:	fc22                	sd	s0,56(sp)
 56c:	0080                	addi	s0,sp,64
 56e:	fca43c23          	sd	a0,-40(s0)
 572:	fcb43823          	sd	a1,-48(s0)
 576:	87b2                	mv	a5,a2
 578:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 57c:	fd843783          	ld	a5,-40(s0)
 580:	fef43423          	sd	a5,-24(s0)
 584:	fd043783          	ld	a5,-48(s0)
 588:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 58c:	a0a1                	j	5d4 <memcmp+0x6c>
    if (*p1 != *p2) {
 58e:	fe843783          	ld	a5,-24(s0)
 592:	0007c703          	lbu	a4,0(a5)
 596:	fe043783          	ld	a5,-32(s0)
 59a:	0007c783          	lbu	a5,0(a5)
 59e:	02f70163          	beq	a4,a5,5c0 <memcmp+0x58>
      return *p1 - *p2;
 5a2:	fe843783          	ld	a5,-24(s0)
 5a6:	0007c783          	lbu	a5,0(a5)
 5aa:	0007871b          	sext.w	a4,a5
 5ae:	fe043783          	ld	a5,-32(s0)
 5b2:	0007c783          	lbu	a5,0(a5)
 5b6:	2781                	sext.w	a5,a5
 5b8:	40f707bb          	subw	a5,a4,a5
 5bc:	2781                	sext.w	a5,a5
 5be:	a01d                	j	5e4 <memcmp+0x7c>
    }
    p1++;
 5c0:	fe843783          	ld	a5,-24(s0)
 5c4:	0785                	addi	a5,a5,1
 5c6:	fef43423          	sd	a5,-24(s0)
    p2++;
 5ca:	fe043783          	ld	a5,-32(s0)
 5ce:	0785                	addi	a5,a5,1
 5d0:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 5d4:	fcc42783          	lw	a5,-52(s0)
 5d8:	fff7871b          	addiw	a4,a5,-1
 5dc:	fce42623          	sw	a4,-52(s0)
 5e0:	f7dd                	bnez	a5,58e <memcmp+0x26>
  }
  return 0;
 5e2:	4781                	li	a5,0
}
 5e4:	853e                	mv	a0,a5
 5e6:	7462                	ld	s0,56(sp)
 5e8:	6121                	addi	sp,sp,64
 5ea:	8082                	ret

00000000000005ec <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5ec:	7179                	addi	sp,sp,-48
 5ee:	f406                	sd	ra,40(sp)
 5f0:	f022                	sd	s0,32(sp)
 5f2:	1800                	addi	s0,sp,48
 5f4:	fea43423          	sd	a0,-24(s0)
 5f8:	feb43023          	sd	a1,-32(s0)
 5fc:	87b2                	mv	a5,a2
 5fe:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 602:	fdc42783          	lw	a5,-36(s0)
 606:	863e                	mv	a2,a5
 608:	fe043583          	ld	a1,-32(s0)
 60c:	fe843503          	ld	a0,-24(s0)
 610:	00000097          	auipc	ra,0x0
 614:	e96080e7          	jalr	-362(ra) # 4a6 <memmove>
 618:	87aa                	mv	a5,a0
}
 61a:	853e                	mv	a0,a5
 61c:	70a2                	ld	ra,40(sp)
 61e:	7402                	ld	s0,32(sp)
 620:	6145                	addi	sp,sp,48
 622:	8082                	ret

0000000000000624 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 624:	4885                	li	a7,1
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <exit>:
.global exit
exit:
 li a7, SYS_exit
 62c:	4889                	li	a7,2
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <wait>:
.global wait
wait:
 li a7, SYS_wait
 634:	488d                	li	a7,3
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 63c:	4891                	li	a7,4
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <read>:
.global read
read:
 li a7, SYS_read
 644:	4895                	li	a7,5
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <write>:
.global write
write:
 li a7, SYS_write
 64c:	48c1                	li	a7,16
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <close>:
.global close
close:
 li a7, SYS_close
 654:	48d5                	li	a7,21
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <kill>:
.global kill
kill:
 li a7, SYS_kill
 65c:	4899                	li	a7,6
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <exec>:
.global exec
exec:
 li a7, SYS_exec
 664:	489d                	li	a7,7
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <open>:
.global open
open:
 li a7, SYS_open
 66c:	48bd                	li	a7,15
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 674:	48c5                	li	a7,17
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 67c:	48c9                	li	a7,18
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 684:	48a1                	li	a7,8
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <link>:
.global link
link:
 li a7, SYS_link
 68c:	48cd                	li	a7,19
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 694:	48d1                	li	a7,20
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 69c:	48a5                	li	a7,9
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6a4:	48a9                	li	a7,10
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6ac:	48ad                	li	a7,11
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6b4:	48b1                	li	a7,12
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6bc:	48b5                	li	a7,13
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6c4:	48b9                	li	a7,14
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <hello>:
.global hello
hello:
 li a7, SYS_hello
 6cc:	48d9                	li	a7,22
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <ps>:
.global ps
ps:
 li a7, SYS_ps
 6d4:	48e1                	li	a7,24
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 6dc:	48dd                	li	a7,23
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 6e4:	48e5                	li	a7,25
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6ec:	1101                	addi	sp,sp,-32
 6ee:	ec06                	sd	ra,24(sp)
 6f0:	e822                	sd	s0,16(sp)
 6f2:	1000                	addi	s0,sp,32
 6f4:	87aa                	mv	a5,a0
 6f6:	872e                	mv	a4,a1
 6f8:	fef42623          	sw	a5,-20(s0)
 6fc:	87ba                	mv	a5,a4
 6fe:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 702:	feb40713          	addi	a4,s0,-21
 706:	fec42783          	lw	a5,-20(s0)
 70a:	4605                	li	a2,1
 70c:	85ba                	mv	a1,a4
 70e:	853e                	mv	a0,a5
 710:	00000097          	auipc	ra,0x0
 714:	f3c080e7          	jalr	-196(ra) # 64c <write>
}
 718:	0001                	nop
 71a:	60e2                	ld	ra,24(sp)
 71c:	6442                	ld	s0,16(sp)
 71e:	6105                	addi	sp,sp,32
 720:	8082                	ret

0000000000000722 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 722:	7139                	addi	sp,sp,-64
 724:	fc06                	sd	ra,56(sp)
 726:	f822                	sd	s0,48(sp)
 728:	0080                	addi	s0,sp,64
 72a:	87aa                	mv	a5,a0
 72c:	8736                	mv	a4,a3
 72e:	fcf42623          	sw	a5,-52(s0)
 732:	87ae                	mv	a5,a1
 734:	fcf42423          	sw	a5,-56(s0)
 738:	87b2                	mv	a5,a2
 73a:	fcf42223          	sw	a5,-60(s0)
 73e:	87ba                	mv	a5,a4
 740:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 744:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 748:	fc042783          	lw	a5,-64(s0)
 74c:	2781                	sext.w	a5,a5
 74e:	c38d                	beqz	a5,770 <printint+0x4e>
 750:	fc842783          	lw	a5,-56(s0)
 754:	2781                	sext.w	a5,a5
 756:	0007dd63          	bgez	a5,770 <printint+0x4e>
    neg = 1;
 75a:	4785                	li	a5,1
 75c:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 760:	fc842783          	lw	a5,-56(s0)
 764:	40f007bb          	negw	a5,a5
 768:	2781                	sext.w	a5,a5
 76a:	fef42223          	sw	a5,-28(s0)
 76e:	a029                	j	778 <printint+0x56>
  } else {
    x = xx;
 770:	fc842783          	lw	a5,-56(s0)
 774:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 778:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 77c:	fc442783          	lw	a5,-60(s0)
 780:	fe442703          	lw	a4,-28(s0)
 784:	02f777bb          	remuw	a5,a4,a5
 788:	0007861b          	sext.w	a2,a5
 78c:	fec42783          	lw	a5,-20(s0)
 790:	0017871b          	addiw	a4,a5,1
 794:	fee42623          	sw	a4,-20(s0)
 798:	00001697          	auipc	a3,0x1
 79c:	86868693          	addi	a3,a3,-1944 # 1000 <digits>
 7a0:	02061713          	slli	a4,a2,0x20
 7a4:	9301                	srli	a4,a4,0x20
 7a6:	9736                	add	a4,a4,a3
 7a8:	00074703          	lbu	a4,0(a4)
 7ac:	17c1                	addi	a5,a5,-16
 7ae:	97a2                	add	a5,a5,s0
 7b0:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 7b4:	fc442783          	lw	a5,-60(s0)
 7b8:	fe442703          	lw	a4,-28(s0)
 7bc:	02f757bb          	divuw	a5,a4,a5
 7c0:	fef42223          	sw	a5,-28(s0)
 7c4:	fe442783          	lw	a5,-28(s0)
 7c8:	2781                	sext.w	a5,a5
 7ca:	fbcd                	bnez	a5,77c <printint+0x5a>
  if(neg)
 7cc:	fe842783          	lw	a5,-24(s0)
 7d0:	2781                	sext.w	a5,a5
 7d2:	cf85                	beqz	a5,80a <printint+0xe8>
    buf[i++] = '-';
 7d4:	fec42783          	lw	a5,-20(s0)
 7d8:	0017871b          	addiw	a4,a5,1
 7dc:	fee42623          	sw	a4,-20(s0)
 7e0:	17c1                	addi	a5,a5,-16
 7e2:	97a2                	add	a5,a5,s0
 7e4:	02d00713          	li	a4,45
 7e8:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 7ec:	a839                	j	80a <printint+0xe8>
    putc(fd, buf[i]);
 7ee:	fec42783          	lw	a5,-20(s0)
 7f2:	17c1                	addi	a5,a5,-16
 7f4:	97a2                	add	a5,a5,s0
 7f6:	fe07c703          	lbu	a4,-32(a5)
 7fa:	fcc42783          	lw	a5,-52(s0)
 7fe:	85ba                	mv	a1,a4
 800:	853e                	mv	a0,a5
 802:	00000097          	auipc	ra,0x0
 806:	eea080e7          	jalr	-278(ra) # 6ec <putc>
  while(--i >= 0)
 80a:	fec42783          	lw	a5,-20(s0)
 80e:	37fd                	addiw	a5,a5,-1
 810:	fef42623          	sw	a5,-20(s0)
 814:	fec42783          	lw	a5,-20(s0)
 818:	2781                	sext.w	a5,a5
 81a:	fc07dae3          	bgez	a5,7ee <printint+0xcc>
}
 81e:	0001                	nop
 820:	0001                	nop
 822:	70e2                	ld	ra,56(sp)
 824:	7442                	ld	s0,48(sp)
 826:	6121                	addi	sp,sp,64
 828:	8082                	ret

000000000000082a <printptr>:

static void
printptr(int fd, uint64 x) {
 82a:	7179                	addi	sp,sp,-48
 82c:	f406                	sd	ra,40(sp)
 82e:	f022                	sd	s0,32(sp)
 830:	1800                	addi	s0,sp,48
 832:	87aa                	mv	a5,a0
 834:	fcb43823          	sd	a1,-48(s0)
 838:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 83c:	fdc42783          	lw	a5,-36(s0)
 840:	03000593          	li	a1,48
 844:	853e                	mv	a0,a5
 846:	00000097          	auipc	ra,0x0
 84a:	ea6080e7          	jalr	-346(ra) # 6ec <putc>
  putc(fd, 'x');
 84e:	fdc42783          	lw	a5,-36(s0)
 852:	07800593          	li	a1,120
 856:	853e                	mv	a0,a5
 858:	00000097          	auipc	ra,0x0
 85c:	e94080e7          	jalr	-364(ra) # 6ec <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 860:	fe042623          	sw	zero,-20(s0)
 864:	a82d                	j	89e <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 866:	fd043783          	ld	a5,-48(s0)
 86a:	93f1                	srli	a5,a5,0x3c
 86c:	00000717          	auipc	a4,0x0
 870:	79470713          	addi	a4,a4,1940 # 1000 <digits>
 874:	97ba                	add	a5,a5,a4
 876:	0007c703          	lbu	a4,0(a5)
 87a:	fdc42783          	lw	a5,-36(s0)
 87e:	85ba                	mv	a1,a4
 880:	853e                	mv	a0,a5
 882:	00000097          	auipc	ra,0x0
 886:	e6a080e7          	jalr	-406(ra) # 6ec <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 88a:	fec42783          	lw	a5,-20(s0)
 88e:	2785                	addiw	a5,a5,1
 890:	fef42623          	sw	a5,-20(s0)
 894:	fd043783          	ld	a5,-48(s0)
 898:	0792                	slli	a5,a5,0x4
 89a:	fcf43823          	sd	a5,-48(s0)
 89e:	fec42783          	lw	a5,-20(s0)
 8a2:	873e                	mv	a4,a5
 8a4:	47bd                	li	a5,15
 8a6:	fce7f0e3          	bgeu	a5,a4,866 <printptr+0x3c>
}
 8aa:	0001                	nop
 8ac:	0001                	nop
 8ae:	70a2                	ld	ra,40(sp)
 8b0:	7402                	ld	s0,32(sp)
 8b2:	6145                	addi	sp,sp,48
 8b4:	8082                	ret

00000000000008b6 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8b6:	715d                	addi	sp,sp,-80
 8b8:	e486                	sd	ra,72(sp)
 8ba:	e0a2                	sd	s0,64(sp)
 8bc:	0880                	addi	s0,sp,80
 8be:	87aa                	mv	a5,a0
 8c0:	fcb43023          	sd	a1,-64(s0)
 8c4:	fac43c23          	sd	a2,-72(s0)
 8c8:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 8cc:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 8d0:	fe042223          	sw	zero,-28(s0)
 8d4:	a42d                	j	afe <vprintf+0x248>
    c = fmt[i] & 0xff;
 8d6:	fe442783          	lw	a5,-28(s0)
 8da:	fc043703          	ld	a4,-64(s0)
 8de:	97ba                	add	a5,a5,a4
 8e0:	0007c783          	lbu	a5,0(a5)
 8e4:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 8e8:	fe042783          	lw	a5,-32(s0)
 8ec:	2781                	sext.w	a5,a5
 8ee:	eb9d                	bnez	a5,924 <vprintf+0x6e>
      if(c == '%'){
 8f0:	fdc42783          	lw	a5,-36(s0)
 8f4:	0007871b          	sext.w	a4,a5
 8f8:	02500793          	li	a5,37
 8fc:	00f71763          	bne	a4,a5,90a <vprintf+0x54>
        state = '%';
 900:	02500793          	li	a5,37
 904:	fef42023          	sw	a5,-32(s0)
 908:	a2f5                	j	af4 <vprintf+0x23e>
      } else {
        putc(fd, c);
 90a:	fdc42783          	lw	a5,-36(s0)
 90e:	0ff7f713          	zext.b	a4,a5
 912:	fcc42783          	lw	a5,-52(s0)
 916:	85ba                	mv	a1,a4
 918:	853e                	mv	a0,a5
 91a:	00000097          	auipc	ra,0x0
 91e:	dd2080e7          	jalr	-558(ra) # 6ec <putc>
 922:	aac9                	j	af4 <vprintf+0x23e>
      }
    } else if(state == '%'){
 924:	fe042783          	lw	a5,-32(s0)
 928:	0007871b          	sext.w	a4,a5
 92c:	02500793          	li	a5,37
 930:	1cf71263          	bne	a4,a5,af4 <vprintf+0x23e>
      if(c == 'd'){
 934:	fdc42783          	lw	a5,-36(s0)
 938:	0007871b          	sext.w	a4,a5
 93c:	06400793          	li	a5,100
 940:	02f71463          	bne	a4,a5,968 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 944:	fb843783          	ld	a5,-72(s0)
 948:	00878713          	addi	a4,a5,8
 94c:	fae43c23          	sd	a4,-72(s0)
 950:	4398                	lw	a4,0(a5)
 952:	fcc42783          	lw	a5,-52(s0)
 956:	4685                	li	a3,1
 958:	4629                	li	a2,10
 95a:	85ba                	mv	a1,a4
 95c:	853e                	mv	a0,a5
 95e:	00000097          	auipc	ra,0x0
 962:	dc4080e7          	jalr	-572(ra) # 722 <printint>
 966:	a269                	j	af0 <vprintf+0x23a>
      } else if(c == 'l') {
 968:	fdc42783          	lw	a5,-36(s0)
 96c:	0007871b          	sext.w	a4,a5
 970:	06c00793          	li	a5,108
 974:	02f71663          	bne	a4,a5,9a0 <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 978:	fb843783          	ld	a5,-72(s0)
 97c:	00878713          	addi	a4,a5,8
 980:	fae43c23          	sd	a4,-72(s0)
 984:	639c                	ld	a5,0(a5)
 986:	0007871b          	sext.w	a4,a5
 98a:	fcc42783          	lw	a5,-52(s0)
 98e:	4681                	li	a3,0
 990:	4629                	li	a2,10
 992:	85ba                	mv	a1,a4
 994:	853e                	mv	a0,a5
 996:	00000097          	auipc	ra,0x0
 99a:	d8c080e7          	jalr	-628(ra) # 722 <printint>
 99e:	aa89                	j	af0 <vprintf+0x23a>
      } else if(c == 'x') {
 9a0:	fdc42783          	lw	a5,-36(s0)
 9a4:	0007871b          	sext.w	a4,a5
 9a8:	07800793          	li	a5,120
 9ac:	02f71463          	bne	a4,a5,9d4 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 9b0:	fb843783          	ld	a5,-72(s0)
 9b4:	00878713          	addi	a4,a5,8
 9b8:	fae43c23          	sd	a4,-72(s0)
 9bc:	4398                	lw	a4,0(a5)
 9be:	fcc42783          	lw	a5,-52(s0)
 9c2:	4681                	li	a3,0
 9c4:	4641                	li	a2,16
 9c6:	85ba                	mv	a1,a4
 9c8:	853e                	mv	a0,a5
 9ca:	00000097          	auipc	ra,0x0
 9ce:	d58080e7          	jalr	-680(ra) # 722 <printint>
 9d2:	aa39                	j	af0 <vprintf+0x23a>
      } else if(c == 'p') {
 9d4:	fdc42783          	lw	a5,-36(s0)
 9d8:	0007871b          	sext.w	a4,a5
 9dc:	07000793          	li	a5,112
 9e0:	02f71263          	bne	a4,a5,a04 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 9e4:	fb843783          	ld	a5,-72(s0)
 9e8:	00878713          	addi	a4,a5,8
 9ec:	fae43c23          	sd	a4,-72(s0)
 9f0:	6398                	ld	a4,0(a5)
 9f2:	fcc42783          	lw	a5,-52(s0)
 9f6:	85ba                	mv	a1,a4
 9f8:	853e                	mv	a0,a5
 9fa:	00000097          	auipc	ra,0x0
 9fe:	e30080e7          	jalr	-464(ra) # 82a <printptr>
 a02:	a0fd                	j	af0 <vprintf+0x23a>
      } else if(c == 's'){
 a04:	fdc42783          	lw	a5,-36(s0)
 a08:	0007871b          	sext.w	a4,a5
 a0c:	07300793          	li	a5,115
 a10:	04f71c63          	bne	a4,a5,a68 <vprintf+0x1b2>
        s = va_arg(ap, char*);
 a14:	fb843783          	ld	a5,-72(s0)
 a18:	00878713          	addi	a4,a5,8
 a1c:	fae43c23          	sd	a4,-72(s0)
 a20:	639c                	ld	a5,0(a5)
 a22:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 a26:	fe843783          	ld	a5,-24(s0)
 a2a:	eb8d                	bnez	a5,a5c <vprintf+0x1a6>
          s = "(null)";
 a2c:	00000797          	auipc	a5,0x0
 a30:	4cc78793          	addi	a5,a5,1228 # ef8 <malloc+0x192>
 a34:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 a38:	a015                	j	a5c <vprintf+0x1a6>
          putc(fd, *s);
 a3a:	fe843783          	ld	a5,-24(s0)
 a3e:	0007c703          	lbu	a4,0(a5)
 a42:	fcc42783          	lw	a5,-52(s0)
 a46:	85ba                	mv	a1,a4
 a48:	853e                	mv	a0,a5
 a4a:	00000097          	auipc	ra,0x0
 a4e:	ca2080e7          	jalr	-862(ra) # 6ec <putc>
          s++;
 a52:	fe843783          	ld	a5,-24(s0)
 a56:	0785                	addi	a5,a5,1
 a58:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 a5c:	fe843783          	ld	a5,-24(s0)
 a60:	0007c783          	lbu	a5,0(a5)
 a64:	fbf9                	bnez	a5,a3a <vprintf+0x184>
 a66:	a069                	j	af0 <vprintf+0x23a>
        }
      } else if(c == 'c'){
 a68:	fdc42783          	lw	a5,-36(s0)
 a6c:	0007871b          	sext.w	a4,a5
 a70:	06300793          	li	a5,99
 a74:	02f71463          	bne	a4,a5,a9c <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 a78:	fb843783          	ld	a5,-72(s0)
 a7c:	00878713          	addi	a4,a5,8
 a80:	fae43c23          	sd	a4,-72(s0)
 a84:	439c                	lw	a5,0(a5)
 a86:	0ff7f713          	zext.b	a4,a5
 a8a:	fcc42783          	lw	a5,-52(s0)
 a8e:	85ba                	mv	a1,a4
 a90:	853e                	mv	a0,a5
 a92:	00000097          	auipc	ra,0x0
 a96:	c5a080e7          	jalr	-934(ra) # 6ec <putc>
 a9a:	a899                	j	af0 <vprintf+0x23a>
      } else if(c == '%'){
 a9c:	fdc42783          	lw	a5,-36(s0)
 aa0:	0007871b          	sext.w	a4,a5
 aa4:	02500793          	li	a5,37
 aa8:	00f71f63          	bne	a4,a5,ac6 <vprintf+0x210>
        putc(fd, c);
 aac:	fdc42783          	lw	a5,-36(s0)
 ab0:	0ff7f713          	zext.b	a4,a5
 ab4:	fcc42783          	lw	a5,-52(s0)
 ab8:	85ba                	mv	a1,a4
 aba:	853e                	mv	a0,a5
 abc:	00000097          	auipc	ra,0x0
 ac0:	c30080e7          	jalr	-976(ra) # 6ec <putc>
 ac4:	a035                	j	af0 <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 ac6:	fcc42783          	lw	a5,-52(s0)
 aca:	02500593          	li	a1,37
 ace:	853e                	mv	a0,a5
 ad0:	00000097          	auipc	ra,0x0
 ad4:	c1c080e7          	jalr	-996(ra) # 6ec <putc>
        putc(fd, c);
 ad8:	fdc42783          	lw	a5,-36(s0)
 adc:	0ff7f713          	zext.b	a4,a5
 ae0:	fcc42783          	lw	a5,-52(s0)
 ae4:	85ba                	mv	a1,a4
 ae6:	853e                	mv	a0,a5
 ae8:	00000097          	auipc	ra,0x0
 aec:	c04080e7          	jalr	-1020(ra) # 6ec <putc>
      }
      state = 0;
 af0:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 af4:	fe442783          	lw	a5,-28(s0)
 af8:	2785                	addiw	a5,a5,1
 afa:	fef42223          	sw	a5,-28(s0)
 afe:	fe442783          	lw	a5,-28(s0)
 b02:	fc043703          	ld	a4,-64(s0)
 b06:	97ba                	add	a5,a5,a4
 b08:	0007c783          	lbu	a5,0(a5)
 b0c:	dc0795e3          	bnez	a5,8d6 <vprintf+0x20>
    }
  }
}
 b10:	0001                	nop
 b12:	0001                	nop
 b14:	60a6                	ld	ra,72(sp)
 b16:	6406                	ld	s0,64(sp)
 b18:	6161                	addi	sp,sp,80
 b1a:	8082                	ret

0000000000000b1c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b1c:	7159                	addi	sp,sp,-112
 b1e:	fc06                	sd	ra,56(sp)
 b20:	f822                	sd	s0,48(sp)
 b22:	0080                	addi	s0,sp,64
 b24:	fcb43823          	sd	a1,-48(s0)
 b28:	e010                	sd	a2,0(s0)
 b2a:	e414                	sd	a3,8(s0)
 b2c:	e818                	sd	a4,16(s0)
 b2e:	ec1c                	sd	a5,24(s0)
 b30:	03043023          	sd	a6,32(s0)
 b34:	03143423          	sd	a7,40(s0)
 b38:	87aa                	mv	a5,a0
 b3a:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 b3e:	03040793          	addi	a5,s0,48
 b42:	fcf43423          	sd	a5,-56(s0)
 b46:	fc843783          	ld	a5,-56(s0)
 b4a:	fd078793          	addi	a5,a5,-48
 b4e:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 b52:	fe843703          	ld	a4,-24(s0)
 b56:	fdc42783          	lw	a5,-36(s0)
 b5a:	863a                	mv	a2,a4
 b5c:	fd043583          	ld	a1,-48(s0)
 b60:	853e                	mv	a0,a5
 b62:	00000097          	auipc	ra,0x0
 b66:	d54080e7          	jalr	-684(ra) # 8b6 <vprintf>
}
 b6a:	0001                	nop
 b6c:	70e2                	ld	ra,56(sp)
 b6e:	7442                	ld	s0,48(sp)
 b70:	6165                	addi	sp,sp,112
 b72:	8082                	ret

0000000000000b74 <printf>:

void
printf(const char *fmt, ...)
{
 b74:	7159                	addi	sp,sp,-112
 b76:	f406                	sd	ra,40(sp)
 b78:	f022                	sd	s0,32(sp)
 b7a:	1800                	addi	s0,sp,48
 b7c:	fca43c23          	sd	a0,-40(s0)
 b80:	e40c                	sd	a1,8(s0)
 b82:	e810                	sd	a2,16(s0)
 b84:	ec14                	sd	a3,24(s0)
 b86:	f018                	sd	a4,32(s0)
 b88:	f41c                	sd	a5,40(s0)
 b8a:	03043823          	sd	a6,48(s0)
 b8e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b92:	04040793          	addi	a5,s0,64
 b96:	fcf43823          	sd	a5,-48(s0)
 b9a:	fd043783          	ld	a5,-48(s0)
 b9e:	fc878793          	addi	a5,a5,-56
 ba2:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 ba6:	fe843783          	ld	a5,-24(s0)
 baa:	863e                	mv	a2,a5
 bac:	fd843583          	ld	a1,-40(s0)
 bb0:	4505                	li	a0,1
 bb2:	00000097          	auipc	ra,0x0
 bb6:	d04080e7          	jalr	-764(ra) # 8b6 <vprintf>
}
 bba:	0001                	nop
 bbc:	70a2                	ld	ra,40(sp)
 bbe:	7402                	ld	s0,32(sp)
 bc0:	6165                	addi	sp,sp,112
 bc2:	8082                	ret

0000000000000bc4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bc4:	7179                	addi	sp,sp,-48
 bc6:	f422                	sd	s0,40(sp)
 bc8:	1800                	addi	s0,sp,48
 bca:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bce:	fd843783          	ld	a5,-40(s0)
 bd2:	17c1                	addi	a5,a5,-16
 bd4:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bd8:	00000797          	auipc	a5,0x0
 bdc:	65878793          	addi	a5,a5,1624 # 1230 <freep>
 be0:	639c                	ld	a5,0(a5)
 be2:	fef43423          	sd	a5,-24(s0)
 be6:	a815                	j	c1a <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 be8:	fe843783          	ld	a5,-24(s0)
 bec:	639c                	ld	a5,0(a5)
 bee:	fe843703          	ld	a4,-24(s0)
 bf2:	00f76f63          	bltu	a4,a5,c10 <free+0x4c>
 bf6:	fe043703          	ld	a4,-32(s0)
 bfa:	fe843783          	ld	a5,-24(s0)
 bfe:	02e7eb63          	bltu	a5,a4,c34 <free+0x70>
 c02:	fe843783          	ld	a5,-24(s0)
 c06:	639c                	ld	a5,0(a5)
 c08:	fe043703          	ld	a4,-32(s0)
 c0c:	02f76463          	bltu	a4,a5,c34 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c10:	fe843783          	ld	a5,-24(s0)
 c14:	639c                	ld	a5,0(a5)
 c16:	fef43423          	sd	a5,-24(s0)
 c1a:	fe043703          	ld	a4,-32(s0)
 c1e:	fe843783          	ld	a5,-24(s0)
 c22:	fce7f3e3          	bgeu	a5,a4,be8 <free+0x24>
 c26:	fe843783          	ld	a5,-24(s0)
 c2a:	639c                	ld	a5,0(a5)
 c2c:	fe043703          	ld	a4,-32(s0)
 c30:	faf77ce3          	bgeu	a4,a5,be8 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 c34:	fe043783          	ld	a5,-32(s0)
 c38:	479c                	lw	a5,8(a5)
 c3a:	1782                	slli	a5,a5,0x20
 c3c:	9381                	srli	a5,a5,0x20
 c3e:	0792                	slli	a5,a5,0x4
 c40:	fe043703          	ld	a4,-32(s0)
 c44:	973e                	add	a4,a4,a5
 c46:	fe843783          	ld	a5,-24(s0)
 c4a:	639c                	ld	a5,0(a5)
 c4c:	02f71763          	bne	a4,a5,c7a <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 c50:	fe043783          	ld	a5,-32(s0)
 c54:	4798                	lw	a4,8(a5)
 c56:	fe843783          	ld	a5,-24(s0)
 c5a:	639c                	ld	a5,0(a5)
 c5c:	479c                	lw	a5,8(a5)
 c5e:	9fb9                	addw	a5,a5,a4
 c60:	0007871b          	sext.w	a4,a5
 c64:	fe043783          	ld	a5,-32(s0)
 c68:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 c6a:	fe843783          	ld	a5,-24(s0)
 c6e:	639c                	ld	a5,0(a5)
 c70:	6398                	ld	a4,0(a5)
 c72:	fe043783          	ld	a5,-32(s0)
 c76:	e398                	sd	a4,0(a5)
 c78:	a039                	j	c86 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 c7a:	fe843783          	ld	a5,-24(s0)
 c7e:	6398                	ld	a4,0(a5)
 c80:	fe043783          	ld	a5,-32(s0)
 c84:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 c86:	fe843783          	ld	a5,-24(s0)
 c8a:	479c                	lw	a5,8(a5)
 c8c:	1782                	slli	a5,a5,0x20
 c8e:	9381                	srli	a5,a5,0x20
 c90:	0792                	slli	a5,a5,0x4
 c92:	fe843703          	ld	a4,-24(s0)
 c96:	97ba                	add	a5,a5,a4
 c98:	fe043703          	ld	a4,-32(s0)
 c9c:	02f71563          	bne	a4,a5,cc6 <free+0x102>
    p->s.size += bp->s.size;
 ca0:	fe843783          	ld	a5,-24(s0)
 ca4:	4798                	lw	a4,8(a5)
 ca6:	fe043783          	ld	a5,-32(s0)
 caa:	479c                	lw	a5,8(a5)
 cac:	9fb9                	addw	a5,a5,a4
 cae:	0007871b          	sext.w	a4,a5
 cb2:	fe843783          	ld	a5,-24(s0)
 cb6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cb8:	fe043783          	ld	a5,-32(s0)
 cbc:	6398                	ld	a4,0(a5)
 cbe:	fe843783          	ld	a5,-24(s0)
 cc2:	e398                	sd	a4,0(a5)
 cc4:	a031                	j	cd0 <free+0x10c>
  } else
    p->s.ptr = bp;
 cc6:	fe843783          	ld	a5,-24(s0)
 cca:	fe043703          	ld	a4,-32(s0)
 cce:	e398                	sd	a4,0(a5)
  freep = p;
 cd0:	00000797          	auipc	a5,0x0
 cd4:	56078793          	addi	a5,a5,1376 # 1230 <freep>
 cd8:	fe843703          	ld	a4,-24(s0)
 cdc:	e398                	sd	a4,0(a5)
}
 cde:	0001                	nop
 ce0:	7422                	ld	s0,40(sp)
 ce2:	6145                	addi	sp,sp,48
 ce4:	8082                	ret

0000000000000ce6 <morecore>:

static Header*
morecore(uint nu)
{
 ce6:	7179                	addi	sp,sp,-48
 ce8:	f406                	sd	ra,40(sp)
 cea:	f022                	sd	s0,32(sp)
 cec:	1800                	addi	s0,sp,48
 cee:	87aa                	mv	a5,a0
 cf0:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 cf4:	fdc42783          	lw	a5,-36(s0)
 cf8:	0007871b          	sext.w	a4,a5
 cfc:	6785                	lui	a5,0x1
 cfe:	00f77563          	bgeu	a4,a5,d08 <morecore+0x22>
    nu = 4096;
 d02:	6785                	lui	a5,0x1
 d04:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 d08:	fdc42783          	lw	a5,-36(s0)
 d0c:	0047979b          	slliw	a5,a5,0x4
 d10:	2781                	sext.w	a5,a5
 d12:	2781                	sext.w	a5,a5
 d14:	853e                	mv	a0,a5
 d16:	00000097          	auipc	ra,0x0
 d1a:	99e080e7          	jalr	-1634(ra) # 6b4 <sbrk>
 d1e:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 d22:	fe843703          	ld	a4,-24(s0)
 d26:	57fd                	li	a5,-1
 d28:	00f71463          	bne	a4,a5,d30 <morecore+0x4a>
    return 0;
 d2c:	4781                	li	a5,0
 d2e:	a03d                	j	d5c <morecore+0x76>
  hp = (Header*)p;
 d30:	fe843783          	ld	a5,-24(s0)
 d34:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 d38:	fe043783          	ld	a5,-32(s0)
 d3c:	fdc42703          	lw	a4,-36(s0)
 d40:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 d42:	fe043783          	ld	a5,-32(s0)
 d46:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 d48:	853e                	mv	a0,a5
 d4a:	00000097          	auipc	ra,0x0
 d4e:	e7a080e7          	jalr	-390(ra) # bc4 <free>
  return freep;
 d52:	00000797          	auipc	a5,0x0
 d56:	4de78793          	addi	a5,a5,1246 # 1230 <freep>
 d5a:	639c                	ld	a5,0(a5)
}
 d5c:	853e                	mv	a0,a5
 d5e:	70a2                	ld	ra,40(sp)
 d60:	7402                	ld	s0,32(sp)
 d62:	6145                	addi	sp,sp,48
 d64:	8082                	ret

0000000000000d66 <malloc>:

void*
malloc(uint nbytes)
{
 d66:	7139                	addi	sp,sp,-64
 d68:	fc06                	sd	ra,56(sp)
 d6a:	f822                	sd	s0,48(sp)
 d6c:	0080                	addi	s0,sp,64
 d6e:	87aa                	mv	a5,a0
 d70:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d74:	fcc46783          	lwu	a5,-52(s0)
 d78:	07bd                	addi	a5,a5,15
 d7a:	8391                	srli	a5,a5,0x4
 d7c:	2781                	sext.w	a5,a5
 d7e:	2785                	addiw	a5,a5,1
 d80:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 d84:	00000797          	auipc	a5,0x0
 d88:	4ac78793          	addi	a5,a5,1196 # 1230 <freep>
 d8c:	639c                	ld	a5,0(a5)
 d8e:	fef43023          	sd	a5,-32(s0)
 d92:	fe043783          	ld	a5,-32(s0)
 d96:	ef95                	bnez	a5,dd2 <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 d98:	00000797          	auipc	a5,0x0
 d9c:	48878793          	addi	a5,a5,1160 # 1220 <base>
 da0:	fef43023          	sd	a5,-32(s0)
 da4:	00000797          	auipc	a5,0x0
 da8:	48c78793          	addi	a5,a5,1164 # 1230 <freep>
 dac:	fe043703          	ld	a4,-32(s0)
 db0:	e398                	sd	a4,0(a5)
 db2:	00000797          	auipc	a5,0x0
 db6:	47e78793          	addi	a5,a5,1150 # 1230 <freep>
 dba:	6398                	ld	a4,0(a5)
 dbc:	00000797          	auipc	a5,0x0
 dc0:	46478793          	addi	a5,a5,1124 # 1220 <base>
 dc4:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 dc6:	00000797          	auipc	a5,0x0
 dca:	45a78793          	addi	a5,a5,1114 # 1220 <base>
 dce:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dd2:	fe043783          	ld	a5,-32(s0)
 dd6:	639c                	ld	a5,0(a5)
 dd8:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 ddc:	fe843783          	ld	a5,-24(s0)
 de0:	4798                	lw	a4,8(a5)
 de2:	fdc42783          	lw	a5,-36(s0)
 de6:	2781                	sext.w	a5,a5
 de8:	06f76763          	bltu	a4,a5,e56 <malloc+0xf0>
      if(p->s.size == nunits)
 dec:	fe843783          	ld	a5,-24(s0)
 df0:	4798                	lw	a4,8(a5)
 df2:	fdc42783          	lw	a5,-36(s0)
 df6:	2781                	sext.w	a5,a5
 df8:	00e79963          	bne	a5,a4,e0a <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 dfc:	fe843783          	ld	a5,-24(s0)
 e00:	6398                	ld	a4,0(a5)
 e02:	fe043783          	ld	a5,-32(s0)
 e06:	e398                	sd	a4,0(a5)
 e08:	a825                	j	e40 <malloc+0xda>
      else {
        p->s.size -= nunits;
 e0a:	fe843783          	ld	a5,-24(s0)
 e0e:	479c                	lw	a5,8(a5)
 e10:	fdc42703          	lw	a4,-36(s0)
 e14:	9f99                	subw	a5,a5,a4
 e16:	0007871b          	sext.w	a4,a5
 e1a:	fe843783          	ld	a5,-24(s0)
 e1e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e20:	fe843783          	ld	a5,-24(s0)
 e24:	479c                	lw	a5,8(a5)
 e26:	1782                	slli	a5,a5,0x20
 e28:	9381                	srli	a5,a5,0x20
 e2a:	0792                	slli	a5,a5,0x4
 e2c:	fe843703          	ld	a4,-24(s0)
 e30:	97ba                	add	a5,a5,a4
 e32:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 e36:	fe843783          	ld	a5,-24(s0)
 e3a:	fdc42703          	lw	a4,-36(s0)
 e3e:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 e40:	00000797          	auipc	a5,0x0
 e44:	3f078793          	addi	a5,a5,1008 # 1230 <freep>
 e48:	fe043703          	ld	a4,-32(s0)
 e4c:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 e4e:	fe843783          	ld	a5,-24(s0)
 e52:	07c1                	addi	a5,a5,16
 e54:	a091                	j	e98 <malloc+0x132>
    }
    if(p == freep)
 e56:	00000797          	auipc	a5,0x0
 e5a:	3da78793          	addi	a5,a5,986 # 1230 <freep>
 e5e:	639c                	ld	a5,0(a5)
 e60:	fe843703          	ld	a4,-24(s0)
 e64:	02f71063          	bne	a4,a5,e84 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 e68:	fdc42783          	lw	a5,-36(s0)
 e6c:	853e                	mv	a0,a5
 e6e:	00000097          	auipc	ra,0x0
 e72:	e78080e7          	jalr	-392(ra) # ce6 <morecore>
 e76:	fea43423          	sd	a0,-24(s0)
 e7a:	fe843783          	ld	a5,-24(s0)
 e7e:	e399                	bnez	a5,e84 <malloc+0x11e>
        return 0;
 e80:	4781                	li	a5,0
 e82:	a819                	j	e98 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e84:	fe843783          	ld	a5,-24(s0)
 e88:	fef43023          	sd	a5,-32(s0)
 e8c:	fe843783          	ld	a5,-24(s0)
 e90:	639c                	ld	a5,0(a5)
 e92:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 e96:	b799                	j	ddc <malloc+0x76>
  }
}
 e98:	853e                	mv	a0,a5
 e9a:	70e2                	ld	ra,56(sp)
 e9c:	7442                	ld	s0,48(sp)
 e9e:	6121                	addi	sp,sp,64
 ea0:	8082                	ret
