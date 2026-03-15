
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	0080                	addi	s0,sp,64
   8:	87aa                	mv	a5,a0
   a:	fcb43023          	sd	a1,-64(s0)
   e:	fcf42623          	sw	a5,-52(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  12:	fe042023          	sw	zero,-32(s0)
  16:	fe042783          	lw	a5,-32(s0)
  1a:	fef42223          	sw	a5,-28(s0)
  1e:	fe442783          	lw	a5,-28(s0)
  22:	fef42423          	sw	a5,-24(s0)
  inword = 0;
  26:	fc042e23          	sw	zero,-36(s0)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2a:	a861                	j	c2 <wc+0xc2>
    for(i=0; i<n; i++){
  2c:	fe042623          	sw	zero,-20(s0)
  30:	a041                	j	b0 <wc+0xb0>
      c++;
  32:	fe042783          	lw	a5,-32(s0)
  36:	2785                	addiw	a5,a5,1
  38:	fef42023          	sw	a5,-32(s0)
      if(buf[i] == '\n')
  3c:	00001717          	auipc	a4,0x1
  40:	fe470713          	addi	a4,a4,-28 # 1020 <buf>
  44:	fec42783          	lw	a5,-20(s0)
  48:	97ba                	add	a5,a5,a4
  4a:	0007c783          	lbu	a5,0(a5)
  4e:	873e                	mv	a4,a5
  50:	47a9                	li	a5,10
  52:	00f71763          	bne	a4,a5,60 <wc+0x60>
        l++;
  56:	fe842783          	lw	a5,-24(s0)
  5a:	2785                	addiw	a5,a5,1
  5c:	fef42423          	sw	a5,-24(s0)
      if(strchr(" \r\t\n\v", buf[i]))
  60:	00001717          	auipc	a4,0x1
  64:	fc070713          	addi	a4,a4,-64 # 1020 <buf>
  68:	fec42783          	lw	a5,-20(s0)
  6c:	97ba                	add	a5,a5,a4
  6e:	0007c783          	lbu	a5,0(a5)
  72:	85be                	mv	a1,a5
  74:	00001517          	auipc	a0,0x1
  78:	edc50513          	addi	a0,a0,-292 # f50 <malloc+0x144>
  7c:	00000097          	auipc	ra,0x0
  80:	30a080e7          	jalr	778(ra) # 386 <strchr>
  84:	87aa                	mv	a5,a0
  86:	c781                	beqz	a5,8e <wc+0x8e>
        inword = 0;
  88:	fc042e23          	sw	zero,-36(s0)
  8c:	a829                	j	a6 <wc+0xa6>
      else if(!inword){
  8e:	fdc42783          	lw	a5,-36(s0)
  92:	2781                	sext.w	a5,a5
  94:	eb89                	bnez	a5,a6 <wc+0xa6>
        w++;
  96:	fe442783          	lw	a5,-28(s0)
  9a:	2785                	addiw	a5,a5,1
  9c:	fef42223          	sw	a5,-28(s0)
        inword = 1;
  a0:	4785                	li	a5,1
  a2:	fcf42e23          	sw	a5,-36(s0)
    for(i=0; i<n; i++){
  a6:	fec42783          	lw	a5,-20(s0)
  aa:	2785                	addiw	a5,a5,1
  ac:	fef42623          	sw	a5,-20(s0)
  b0:	fec42783          	lw	a5,-20(s0)
  b4:	873e                	mv	a4,a5
  b6:	fd842783          	lw	a5,-40(s0)
  ba:	2701                	sext.w	a4,a4
  bc:	2781                	sext.w	a5,a5
  be:	f6f74ae3          	blt	a4,a5,32 <wc+0x32>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  c2:	fcc42783          	lw	a5,-52(s0)
  c6:	20000613          	li	a2,512
  ca:	00001597          	auipc	a1,0x1
  ce:	f5658593          	addi	a1,a1,-170 # 1020 <buf>
  d2:	853e                	mv	a0,a5
  d4:	00000097          	auipc	ra,0x0
  d8:	616080e7          	jalr	1558(ra) # 6ea <read>
  dc:	87aa                	mv	a5,a0
  de:	fcf42c23          	sw	a5,-40(s0)
  e2:	fd842783          	lw	a5,-40(s0)
  e6:	2781                	sext.w	a5,a5
  e8:	f4f042e3          	bgtz	a5,2c <wc+0x2c>
      }
    }
  }
  if(n < 0){
  ec:	fd842783          	lw	a5,-40(s0)
  f0:	2781                	sext.w	a5,a5
  f2:	0007df63          	bgez	a5,110 <wc+0x110>
    printf("wc: read error\n");
  f6:	00001517          	auipc	a0,0x1
  fa:	e6250513          	addi	a0,a0,-414 # f58 <malloc+0x14c>
  fe:	00001097          	auipc	ra,0x1
 102:	b1c080e7          	jalr	-1252(ra) # c1a <printf>
    exit(1);
 106:	4505                	li	a0,1
 108:	00000097          	auipc	ra,0x0
 10c:	5ca080e7          	jalr	1482(ra) # 6d2 <exit>
  }
  printf("%d %d %d %s\n", l, w, c, name);
 110:	fe042683          	lw	a3,-32(s0)
 114:	fe442603          	lw	a2,-28(s0)
 118:	fe842783          	lw	a5,-24(s0)
 11c:	fc043703          	ld	a4,-64(s0)
 120:	85be                	mv	a1,a5
 122:	00001517          	auipc	a0,0x1
 126:	e4650513          	addi	a0,a0,-442 # f68 <malloc+0x15c>
 12a:	00001097          	auipc	ra,0x1
 12e:	af0080e7          	jalr	-1296(ra) # c1a <printf>
}
 132:	0001                	nop
 134:	70e2                	ld	ra,56(sp)
 136:	7442                	ld	s0,48(sp)
 138:	6121                	addi	sp,sp,64
 13a:	8082                	ret

000000000000013c <main>:

int
main(int argc, char *argv[])
{
 13c:	7179                	addi	sp,sp,-48
 13e:	f406                	sd	ra,40(sp)
 140:	f022                	sd	s0,32(sp)
 142:	1800                	addi	s0,sp,48
 144:	87aa                	mv	a5,a0
 146:	fcb43823          	sd	a1,-48(s0)
 14a:	fcf42e23          	sw	a5,-36(s0)
  int fd, i;

  if(argc <= 1){
 14e:	fdc42783          	lw	a5,-36(s0)
 152:	0007871b          	sext.w	a4,a5
 156:	4785                	li	a5,1
 158:	02e7c063          	blt	a5,a4,178 <main+0x3c>
    wc(0, "");
 15c:	00001597          	auipc	a1,0x1
 160:	e1c58593          	addi	a1,a1,-484 # f78 <malloc+0x16c>
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	e9a080e7          	jalr	-358(ra) # 0 <wc>
    exit(0);
 16e:	4501                	li	a0,0
 170:	00000097          	auipc	ra,0x0
 174:	562080e7          	jalr	1378(ra) # 6d2 <exit>
  }

  for(i = 1; i < argc; i++){
 178:	4785                	li	a5,1
 17a:	fef42623          	sw	a5,-20(s0)
 17e:	a071                	j	20a <main+0xce>
    if((fd = open(argv[i], 0)) < 0){
 180:	fec42783          	lw	a5,-20(s0)
 184:	078e                	slli	a5,a5,0x3
 186:	fd043703          	ld	a4,-48(s0)
 18a:	97ba                	add	a5,a5,a4
 18c:	639c                	ld	a5,0(a5)
 18e:	4581                	li	a1,0
 190:	853e                	mv	a0,a5
 192:	00000097          	auipc	ra,0x0
 196:	580080e7          	jalr	1408(ra) # 712 <open>
 19a:	87aa                	mv	a5,a0
 19c:	fef42423          	sw	a5,-24(s0)
 1a0:	fe842783          	lw	a5,-24(s0)
 1a4:	2781                	sext.w	a5,a5
 1a6:	0207d763          	bgez	a5,1d4 <main+0x98>
      printf("wc: cannot open %s\n", argv[i]);
 1aa:	fec42783          	lw	a5,-20(s0)
 1ae:	078e                	slli	a5,a5,0x3
 1b0:	fd043703          	ld	a4,-48(s0)
 1b4:	97ba                	add	a5,a5,a4
 1b6:	639c                	ld	a5,0(a5)
 1b8:	85be                	mv	a1,a5
 1ba:	00001517          	auipc	a0,0x1
 1be:	dc650513          	addi	a0,a0,-570 # f80 <malloc+0x174>
 1c2:	00001097          	auipc	ra,0x1
 1c6:	a58080e7          	jalr	-1448(ra) # c1a <printf>
      exit(1);
 1ca:	4505                	li	a0,1
 1cc:	00000097          	auipc	ra,0x0
 1d0:	506080e7          	jalr	1286(ra) # 6d2 <exit>
    }
    wc(fd, argv[i]);
 1d4:	fec42783          	lw	a5,-20(s0)
 1d8:	078e                	slli	a5,a5,0x3
 1da:	fd043703          	ld	a4,-48(s0)
 1de:	97ba                	add	a5,a5,a4
 1e0:	6398                	ld	a4,0(a5)
 1e2:	fe842783          	lw	a5,-24(s0)
 1e6:	85ba                	mv	a1,a4
 1e8:	853e                	mv	a0,a5
 1ea:	00000097          	auipc	ra,0x0
 1ee:	e16080e7          	jalr	-490(ra) # 0 <wc>
    close(fd);
 1f2:	fe842783          	lw	a5,-24(s0)
 1f6:	853e                	mv	a0,a5
 1f8:	00000097          	auipc	ra,0x0
 1fc:	502080e7          	jalr	1282(ra) # 6fa <close>
  for(i = 1; i < argc; i++){
 200:	fec42783          	lw	a5,-20(s0)
 204:	2785                	addiw	a5,a5,1
 206:	fef42623          	sw	a5,-20(s0)
 20a:	fec42783          	lw	a5,-20(s0)
 20e:	873e                	mv	a4,a5
 210:	fdc42783          	lw	a5,-36(s0)
 214:	2701                	sext.w	a4,a4
 216:	2781                	sext.w	a5,a5
 218:	f6f744e3          	blt	a4,a5,180 <main+0x44>
  }
  exit(0);
 21c:	4501                	li	a0,0
 21e:	00000097          	auipc	ra,0x0
 222:	4b4080e7          	jalr	1204(ra) # 6d2 <exit>

0000000000000226 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 226:	1141                	addi	sp,sp,-16
 228:	e406                	sd	ra,8(sp)
 22a:	e022                	sd	s0,0(sp)
 22c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 22e:	00000097          	auipc	ra,0x0
 232:	f0e080e7          	jalr	-242(ra) # 13c <main>
  exit(0);
 236:	4501                	li	a0,0
 238:	00000097          	auipc	ra,0x0
 23c:	49a080e7          	jalr	1178(ra) # 6d2 <exit>

0000000000000240 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 240:	7179                	addi	sp,sp,-48
 242:	f422                	sd	s0,40(sp)
 244:	1800                	addi	s0,sp,48
 246:	fca43c23          	sd	a0,-40(s0)
 24a:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
 24e:	fd843783          	ld	a5,-40(s0)
 252:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
 256:	0001                	nop
 258:	fd043703          	ld	a4,-48(s0)
 25c:	00170793          	addi	a5,a4,1
 260:	fcf43823          	sd	a5,-48(s0)
 264:	fd843783          	ld	a5,-40(s0)
 268:	00178693          	addi	a3,a5,1
 26c:	fcd43c23          	sd	a3,-40(s0)
 270:	00074703          	lbu	a4,0(a4)
 274:	00e78023          	sb	a4,0(a5)
 278:	0007c783          	lbu	a5,0(a5)
 27c:	fff1                	bnez	a5,258 <strcpy+0x18>
    ;
  return os;
 27e:	fe843783          	ld	a5,-24(s0)
}
 282:	853e                	mv	a0,a5
 284:	7422                	ld	s0,40(sp)
 286:	6145                	addi	sp,sp,48
 288:	8082                	ret

000000000000028a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28a:	1101                	addi	sp,sp,-32
 28c:	ec22                	sd	s0,24(sp)
 28e:	1000                	addi	s0,sp,32
 290:	fea43423          	sd	a0,-24(s0)
 294:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
 298:	a819                	j	2ae <strcmp+0x24>
    p++, q++;
 29a:	fe843783          	ld	a5,-24(s0)
 29e:	0785                	addi	a5,a5,1
 2a0:	fef43423          	sd	a5,-24(s0)
 2a4:	fe043783          	ld	a5,-32(s0)
 2a8:	0785                	addi	a5,a5,1
 2aa:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
 2ae:	fe843783          	ld	a5,-24(s0)
 2b2:	0007c783          	lbu	a5,0(a5)
 2b6:	cb99                	beqz	a5,2cc <strcmp+0x42>
 2b8:	fe843783          	ld	a5,-24(s0)
 2bc:	0007c703          	lbu	a4,0(a5)
 2c0:	fe043783          	ld	a5,-32(s0)
 2c4:	0007c783          	lbu	a5,0(a5)
 2c8:	fcf709e3          	beq	a4,a5,29a <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
 2cc:	fe843783          	ld	a5,-24(s0)
 2d0:	0007c783          	lbu	a5,0(a5)
 2d4:	0007871b          	sext.w	a4,a5
 2d8:	fe043783          	ld	a5,-32(s0)
 2dc:	0007c783          	lbu	a5,0(a5)
 2e0:	2781                	sext.w	a5,a5
 2e2:	40f707bb          	subw	a5,a4,a5
 2e6:	2781                	sext.w	a5,a5
}
 2e8:	853e                	mv	a0,a5
 2ea:	6462                	ld	s0,24(sp)
 2ec:	6105                	addi	sp,sp,32
 2ee:	8082                	ret

00000000000002f0 <strlen>:

uint
strlen(const char *s)
{
 2f0:	7179                	addi	sp,sp,-48
 2f2:	f422                	sd	s0,40(sp)
 2f4:	1800                	addi	s0,sp,48
 2f6:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
 2fa:	fe042623          	sw	zero,-20(s0)
 2fe:	a031                	j	30a <strlen+0x1a>
 300:	fec42783          	lw	a5,-20(s0)
 304:	2785                	addiw	a5,a5,1
 306:	fef42623          	sw	a5,-20(s0)
 30a:	fec42783          	lw	a5,-20(s0)
 30e:	fd843703          	ld	a4,-40(s0)
 312:	97ba                	add	a5,a5,a4
 314:	0007c783          	lbu	a5,0(a5)
 318:	f7e5                	bnez	a5,300 <strlen+0x10>
    ;
  return n;
 31a:	fec42783          	lw	a5,-20(s0)
}
 31e:	853e                	mv	a0,a5
 320:	7422                	ld	s0,40(sp)
 322:	6145                	addi	sp,sp,48
 324:	8082                	ret

0000000000000326 <memset>:

void*
memset(void *dst, int c, uint n)
{
 326:	7179                	addi	sp,sp,-48
 328:	f422                	sd	s0,40(sp)
 32a:	1800                	addi	s0,sp,48
 32c:	fca43c23          	sd	a0,-40(s0)
 330:	87ae                	mv	a5,a1
 332:	8732                	mv	a4,a2
 334:	fcf42a23          	sw	a5,-44(s0)
 338:	87ba                	mv	a5,a4
 33a:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
 33e:	fd843783          	ld	a5,-40(s0)
 342:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
 346:	fe042623          	sw	zero,-20(s0)
 34a:	a00d                	j	36c <memset+0x46>
    cdst[i] = c;
 34c:	fec42783          	lw	a5,-20(s0)
 350:	fe043703          	ld	a4,-32(s0)
 354:	97ba                	add	a5,a5,a4
 356:	fd442703          	lw	a4,-44(s0)
 35a:	0ff77713          	zext.b	a4,a4
 35e:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
 362:	fec42783          	lw	a5,-20(s0)
 366:	2785                	addiw	a5,a5,1
 368:	fef42623          	sw	a5,-20(s0)
 36c:	fec42703          	lw	a4,-20(s0)
 370:	fd042783          	lw	a5,-48(s0)
 374:	2781                	sext.w	a5,a5
 376:	fcf76be3          	bltu	a4,a5,34c <memset+0x26>
  }
  return dst;
 37a:	fd843783          	ld	a5,-40(s0)
}
 37e:	853e                	mv	a0,a5
 380:	7422                	ld	s0,40(sp)
 382:	6145                	addi	sp,sp,48
 384:	8082                	ret

0000000000000386 <strchr>:

char*
strchr(const char *s, char c)
{
 386:	1101                	addi	sp,sp,-32
 388:	ec22                	sd	s0,24(sp)
 38a:	1000                	addi	s0,sp,32
 38c:	fea43423          	sd	a0,-24(s0)
 390:	87ae                	mv	a5,a1
 392:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
 396:	a01d                	j	3bc <strchr+0x36>
    if(*s == c)
 398:	fe843783          	ld	a5,-24(s0)
 39c:	0007c703          	lbu	a4,0(a5)
 3a0:	fe744783          	lbu	a5,-25(s0)
 3a4:	0ff7f793          	zext.b	a5,a5
 3a8:	00e79563          	bne	a5,a4,3b2 <strchr+0x2c>
      return (char*)s;
 3ac:	fe843783          	ld	a5,-24(s0)
 3b0:	a821                	j	3c8 <strchr+0x42>
  for(; *s; s++)
 3b2:	fe843783          	ld	a5,-24(s0)
 3b6:	0785                	addi	a5,a5,1
 3b8:	fef43423          	sd	a5,-24(s0)
 3bc:	fe843783          	ld	a5,-24(s0)
 3c0:	0007c783          	lbu	a5,0(a5)
 3c4:	fbf1                	bnez	a5,398 <strchr+0x12>
  return 0;
 3c6:	4781                	li	a5,0
}
 3c8:	853e                	mv	a0,a5
 3ca:	6462                	ld	s0,24(sp)
 3cc:	6105                	addi	sp,sp,32
 3ce:	8082                	ret

00000000000003d0 <gets>:

char*
gets(char *buf, int max)
{
 3d0:	7179                	addi	sp,sp,-48
 3d2:	f406                	sd	ra,40(sp)
 3d4:	f022                	sd	s0,32(sp)
 3d6:	1800                	addi	s0,sp,48
 3d8:	fca43c23          	sd	a0,-40(s0)
 3dc:	87ae                	mv	a5,a1
 3de:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e2:	fe042623          	sw	zero,-20(s0)
 3e6:	a8a1                	j	43e <gets+0x6e>
    cc = read(0, &c, 1);
 3e8:	fe740793          	addi	a5,s0,-25
 3ec:	4605                	li	a2,1
 3ee:	85be                	mv	a1,a5
 3f0:	4501                	li	a0,0
 3f2:	00000097          	auipc	ra,0x0
 3f6:	2f8080e7          	jalr	760(ra) # 6ea <read>
 3fa:	87aa                	mv	a5,a0
 3fc:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
 400:	fe842783          	lw	a5,-24(s0)
 404:	2781                	sext.w	a5,a5
 406:	04f05763          	blez	a5,454 <gets+0x84>
      break;
    buf[i++] = c;
 40a:	fec42783          	lw	a5,-20(s0)
 40e:	0017871b          	addiw	a4,a5,1
 412:	fee42623          	sw	a4,-20(s0)
 416:	873e                	mv	a4,a5
 418:	fd843783          	ld	a5,-40(s0)
 41c:	97ba                	add	a5,a5,a4
 41e:	fe744703          	lbu	a4,-25(s0)
 422:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
 426:	fe744783          	lbu	a5,-25(s0)
 42a:	873e                	mv	a4,a5
 42c:	47a9                	li	a5,10
 42e:	02f70463          	beq	a4,a5,456 <gets+0x86>
 432:	fe744783          	lbu	a5,-25(s0)
 436:	873e                	mv	a4,a5
 438:	47b5                	li	a5,13
 43a:	00f70e63          	beq	a4,a5,456 <gets+0x86>
  for(i=0; i+1 < max; ){
 43e:	fec42783          	lw	a5,-20(s0)
 442:	2785                	addiw	a5,a5,1
 444:	0007871b          	sext.w	a4,a5
 448:	fd442783          	lw	a5,-44(s0)
 44c:	2781                	sext.w	a5,a5
 44e:	f8f74de3          	blt	a4,a5,3e8 <gets+0x18>
 452:	a011                	j	456 <gets+0x86>
      break;
 454:	0001                	nop
      break;
  }
  buf[i] = '\0';
 456:	fec42783          	lw	a5,-20(s0)
 45a:	fd843703          	ld	a4,-40(s0)
 45e:	97ba                	add	a5,a5,a4
 460:	00078023          	sb	zero,0(a5)
  return buf;
 464:	fd843783          	ld	a5,-40(s0)
}
 468:	853e                	mv	a0,a5
 46a:	70a2                	ld	ra,40(sp)
 46c:	7402                	ld	s0,32(sp)
 46e:	6145                	addi	sp,sp,48
 470:	8082                	ret

0000000000000472 <stat>:

int
stat(const char *n, struct stat *st)
{
 472:	7179                	addi	sp,sp,-48
 474:	f406                	sd	ra,40(sp)
 476:	f022                	sd	s0,32(sp)
 478:	1800                	addi	s0,sp,48
 47a:	fca43c23          	sd	a0,-40(s0)
 47e:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 482:	4581                	li	a1,0
 484:	fd843503          	ld	a0,-40(s0)
 488:	00000097          	auipc	ra,0x0
 48c:	28a080e7          	jalr	650(ra) # 712 <open>
 490:	87aa                	mv	a5,a0
 492:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
 496:	fec42783          	lw	a5,-20(s0)
 49a:	2781                	sext.w	a5,a5
 49c:	0007d463          	bgez	a5,4a4 <stat+0x32>
    return -1;
 4a0:	57fd                	li	a5,-1
 4a2:	a035                	j	4ce <stat+0x5c>
  r = fstat(fd, st);
 4a4:	fec42783          	lw	a5,-20(s0)
 4a8:	fd043583          	ld	a1,-48(s0)
 4ac:	853e                	mv	a0,a5
 4ae:	00000097          	auipc	ra,0x0
 4b2:	27c080e7          	jalr	636(ra) # 72a <fstat>
 4b6:	87aa                	mv	a5,a0
 4b8:	fef42423          	sw	a5,-24(s0)
  close(fd);
 4bc:	fec42783          	lw	a5,-20(s0)
 4c0:	853e                	mv	a0,a5
 4c2:	00000097          	auipc	ra,0x0
 4c6:	238080e7          	jalr	568(ra) # 6fa <close>
  return r;
 4ca:	fe842783          	lw	a5,-24(s0)
}
 4ce:	853e                	mv	a0,a5
 4d0:	70a2                	ld	ra,40(sp)
 4d2:	7402                	ld	s0,32(sp)
 4d4:	6145                	addi	sp,sp,48
 4d6:	8082                	ret

00000000000004d8 <atoi>:

int
atoi(const char *s)
{
 4d8:	7179                	addi	sp,sp,-48
 4da:	f422                	sd	s0,40(sp)
 4dc:	1800                	addi	s0,sp,48
 4de:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
 4e2:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
 4e6:	a81d                	j	51c <atoi+0x44>
    n = n*10 + *s++ - '0';
 4e8:	fec42783          	lw	a5,-20(s0)
 4ec:	873e                	mv	a4,a5
 4ee:	87ba                	mv	a5,a4
 4f0:	0027979b          	slliw	a5,a5,0x2
 4f4:	9fb9                	addw	a5,a5,a4
 4f6:	0017979b          	slliw	a5,a5,0x1
 4fa:	0007871b          	sext.w	a4,a5
 4fe:	fd843783          	ld	a5,-40(s0)
 502:	00178693          	addi	a3,a5,1
 506:	fcd43c23          	sd	a3,-40(s0)
 50a:	0007c783          	lbu	a5,0(a5)
 50e:	2781                	sext.w	a5,a5
 510:	9fb9                	addw	a5,a5,a4
 512:	2781                	sext.w	a5,a5
 514:	fd07879b          	addiw	a5,a5,-48
 518:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
 51c:	fd843783          	ld	a5,-40(s0)
 520:	0007c783          	lbu	a5,0(a5)
 524:	873e                	mv	a4,a5
 526:	02f00793          	li	a5,47
 52a:	00e7fb63          	bgeu	a5,a4,540 <atoi+0x68>
 52e:	fd843783          	ld	a5,-40(s0)
 532:	0007c783          	lbu	a5,0(a5)
 536:	873e                	mv	a4,a5
 538:	03900793          	li	a5,57
 53c:	fae7f6e3          	bgeu	a5,a4,4e8 <atoi+0x10>
  return n;
 540:	fec42783          	lw	a5,-20(s0)
}
 544:	853e                	mv	a0,a5
 546:	7422                	ld	s0,40(sp)
 548:	6145                	addi	sp,sp,48
 54a:	8082                	ret

000000000000054c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 54c:	7139                	addi	sp,sp,-64
 54e:	fc22                	sd	s0,56(sp)
 550:	0080                	addi	s0,sp,64
 552:	fca43c23          	sd	a0,-40(s0)
 556:	fcb43823          	sd	a1,-48(s0)
 55a:	87b2                	mv	a5,a2
 55c:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
 560:	fd843783          	ld	a5,-40(s0)
 564:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
 568:	fd043783          	ld	a5,-48(s0)
 56c:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
 570:	fe043703          	ld	a4,-32(s0)
 574:	fe843783          	ld	a5,-24(s0)
 578:	02e7fc63          	bgeu	a5,a4,5b0 <memmove+0x64>
    while(n-- > 0)
 57c:	a00d                	j	59e <memmove+0x52>
      *dst++ = *src++;
 57e:	fe043703          	ld	a4,-32(s0)
 582:	00170793          	addi	a5,a4,1
 586:	fef43023          	sd	a5,-32(s0)
 58a:	fe843783          	ld	a5,-24(s0)
 58e:	00178693          	addi	a3,a5,1
 592:	fed43423          	sd	a3,-24(s0)
 596:	00074703          	lbu	a4,0(a4)
 59a:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 59e:	fcc42783          	lw	a5,-52(s0)
 5a2:	fff7871b          	addiw	a4,a5,-1
 5a6:	fce42623          	sw	a4,-52(s0)
 5aa:	fcf04ae3          	bgtz	a5,57e <memmove+0x32>
 5ae:	a891                	j	602 <memmove+0xb6>
  } else {
    dst += n;
 5b0:	fcc42783          	lw	a5,-52(s0)
 5b4:	fe843703          	ld	a4,-24(s0)
 5b8:	97ba                	add	a5,a5,a4
 5ba:	fef43423          	sd	a5,-24(s0)
    src += n;
 5be:	fcc42783          	lw	a5,-52(s0)
 5c2:	fe043703          	ld	a4,-32(s0)
 5c6:	97ba                	add	a5,a5,a4
 5c8:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
 5cc:	a01d                	j	5f2 <memmove+0xa6>
      *--dst = *--src;
 5ce:	fe043783          	ld	a5,-32(s0)
 5d2:	17fd                	addi	a5,a5,-1
 5d4:	fef43023          	sd	a5,-32(s0)
 5d8:	fe843783          	ld	a5,-24(s0)
 5dc:	17fd                	addi	a5,a5,-1
 5de:	fef43423          	sd	a5,-24(s0)
 5e2:	fe043783          	ld	a5,-32(s0)
 5e6:	0007c703          	lbu	a4,0(a5)
 5ea:	fe843783          	ld	a5,-24(s0)
 5ee:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
 5f2:	fcc42783          	lw	a5,-52(s0)
 5f6:	fff7871b          	addiw	a4,a5,-1
 5fa:	fce42623          	sw	a4,-52(s0)
 5fe:	fcf048e3          	bgtz	a5,5ce <memmove+0x82>
  }
  return vdst;
 602:	fd843783          	ld	a5,-40(s0)
}
 606:	853e                	mv	a0,a5
 608:	7462                	ld	s0,56(sp)
 60a:	6121                	addi	sp,sp,64
 60c:	8082                	ret

000000000000060e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 60e:	7139                	addi	sp,sp,-64
 610:	fc22                	sd	s0,56(sp)
 612:	0080                	addi	s0,sp,64
 614:	fca43c23          	sd	a0,-40(s0)
 618:	fcb43823          	sd	a1,-48(s0)
 61c:	87b2                	mv	a5,a2
 61e:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
 622:	fd843783          	ld	a5,-40(s0)
 626:	fef43423          	sd	a5,-24(s0)
 62a:	fd043783          	ld	a5,-48(s0)
 62e:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 632:	a0a1                	j	67a <memcmp+0x6c>
    if (*p1 != *p2) {
 634:	fe843783          	ld	a5,-24(s0)
 638:	0007c703          	lbu	a4,0(a5)
 63c:	fe043783          	ld	a5,-32(s0)
 640:	0007c783          	lbu	a5,0(a5)
 644:	02f70163          	beq	a4,a5,666 <memcmp+0x58>
      return *p1 - *p2;
 648:	fe843783          	ld	a5,-24(s0)
 64c:	0007c783          	lbu	a5,0(a5)
 650:	0007871b          	sext.w	a4,a5
 654:	fe043783          	ld	a5,-32(s0)
 658:	0007c783          	lbu	a5,0(a5)
 65c:	2781                	sext.w	a5,a5
 65e:	40f707bb          	subw	a5,a4,a5
 662:	2781                	sext.w	a5,a5
 664:	a01d                	j	68a <memcmp+0x7c>
    }
    p1++;
 666:	fe843783          	ld	a5,-24(s0)
 66a:	0785                	addi	a5,a5,1
 66c:	fef43423          	sd	a5,-24(s0)
    p2++;
 670:	fe043783          	ld	a5,-32(s0)
 674:	0785                	addi	a5,a5,1
 676:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
 67a:	fcc42783          	lw	a5,-52(s0)
 67e:	fff7871b          	addiw	a4,a5,-1
 682:	fce42623          	sw	a4,-52(s0)
 686:	f7dd                	bnez	a5,634 <memcmp+0x26>
  }
  return 0;
 688:	4781                	li	a5,0
}
 68a:	853e                	mv	a0,a5
 68c:	7462                	ld	s0,56(sp)
 68e:	6121                	addi	sp,sp,64
 690:	8082                	ret

0000000000000692 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 692:	7179                	addi	sp,sp,-48
 694:	f406                	sd	ra,40(sp)
 696:	f022                	sd	s0,32(sp)
 698:	1800                	addi	s0,sp,48
 69a:	fea43423          	sd	a0,-24(s0)
 69e:	feb43023          	sd	a1,-32(s0)
 6a2:	87b2                	mv	a5,a2
 6a4:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
 6a8:	fdc42783          	lw	a5,-36(s0)
 6ac:	863e                	mv	a2,a5
 6ae:	fe043583          	ld	a1,-32(s0)
 6b2:	fe843503          	ld	a0,-24(s0)
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e96080e7          	jalr	-362(ra) # 54c <memmove>
 6be:	87aa                	mv	a5,a0
}
 6c0:	853e                	mv	a0,a5
 6c2:	70a2                	ld	ra,40(sp)
 6c4:	7402                	ld	s0,32(sp)
 6c6:	6145                	addi	sp,sp,48
 6c8:	8082                	ret

00000000000006ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6ca:	4885                	li	a7,1
 ecall
 6cc:	00000073          	ecall
 ret
 6d0:	8082                	ret

00000000000006d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6d2:	4889                	li	a7,2
 ecall
 6d4:	00000073          	ecall
 ret
 6d8:	8082                	ret

00000000000006da <wait>:
.global wait
wait:
 li a7, SYS_wait
 6da:	488d                	li	a7,3
 ecall
 6dc:	00000073          	ecall
 ret
 6e0:	8082                	ret

00000000000006e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6e2:	4891                	li	a7,4
 ecall
 6e4:	00000073          	ecall
 ret
 6e8:	8082                	ret

00000000000006ea <read>:
.global read
read:
 li a7, SYS_read
 6ea:	4895                	li	a7,5
 ecall
 6ec:	00000073          	ecall
 ret
 6f0:	8082                	ret

00000000000006f2 <write>:
.global write
write:
 li a7, SYS_write
 6f2:	48c1                	li	a7,16
 ecall
 6f4:	00000073          	ecall
 ret
 6f8:	8082                	ret

00000000000006fa <close>:
.global close
close:
 li a7, SYS_close
 6fa:	48d5                	li	a7,21
 ecall
 6fc:	00000073          	ecall
 ret
 700:	8082                	ret

0000000000000702 <kill>:
.global kill
kill:
 li a7, SYS_kill
 702:	4899                	li	a7,6
 ecall
 704:	00000073          	ecall
 ret
 708:	8082                	ret

000000000000070a <exec>:
.global exec
exec:
 li a7, SYS_exec
 70a:	489d                	li	a7,7
 ecall
 70c:	00000073          	ecall
 ret
 710:	8082                	ret

0000000000000712 <open>:
.global open
open:
 li a7, SYS_open
 712:	48bd                	li	a7,15
 ecall
 714:	00000073          	ecall
 ret
 718:	8082                	ret

000000000000071a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 71a:	48c5                	li	a7,17
 ecall
 71c:	00000073          	ecall
 ret
 720:	8082                	ret

0000000000000722 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 722:	48c9                	li	a7,18
 ecall
 724:	00000073          	ecall
 ret
 728:	8082                	ret

000000000000072a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 72a:	48a1                	li	a7,8
 ecall
 72c:	00000073          	ecall
 ret
 730:	8082                	ret

0000000000000732 <link>:
.global link
link:
 li a7, SYS_link
 732:	48cd                	li	a7,19
 ecall
 734:	00000073          	ecall
 ret
 738:	8082                	ret

000000000000073a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 73a:	48d1                	li	a7,20
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 742:	48a5                	li	a7,9
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <dup>:
.global dup
dup:
 li a7, SYS_dup
 74a:	48a9                	li	a7,10
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 752:	48ad                	li	a7,11
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 75a:	48b1                	li	a7,12
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 762:	48b5                	li	a7,13
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 76a:	48b9                	li	a7,14
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <hello>:
.global hello
hello:
 li a7, SYS_hello
 772:	48d9                	li	a7,22
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <ps>:
.global ps
ps:
 li a7, SYS_ps
 77a:	48e1                	li	a7,24
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
 782:	48dd                	li	a7,23
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
 78a:	48e5                	li	a7,25
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 792:	1101                	addi	sp,sp,-32
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	87aa                	mv	a5,a0
 79c:	872e                	mv	a4,a1
 79e:	fef42623          	sw	a5,-20(s0)
 7a2:	87ba                	mv	a5,a4
 7a4:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
 7a8:	feb40713          	addi	a4,s0,-21
 7ac:	fec42783          	lw	a5,-20(s0)
 7b0:	4605                	li	a2,1
 7b2:	85ba                	mv	a1,a4
 7b4:	853e                	mv	a0,a5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	f3c080e7          	jalr	-196(ra) # 6f2 <write>
}
 7be:	0001                	nop
 7c0:	60e2                	ld	ra,24(sp)
 7c2:	6442                	ld	s0,16(sp)
 7c4:	6105                	addi	sp,sp,32
 7c6:	8082                	ret

00000000000007c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7c8:	7139                	addi	sp,sp,-64
 7ca:	fc06                	sd	ra,56(sp)
 7cc:	f822                	sd	s0,48(sp)
 7ce:	0080                	addi	s0,sp,64
 7d0:	87aa                	mv	a5,a0
 7d2:	8736                	mv	a4,a3
 7d4:	fcf42623          	sw	a5,-52(s0)
 7d8:	87ae                	mv	a5,a1
 7da:	fcf42423          	sw	a5,-56(s0)
 7de:	87b2                	mv	a5,a2
 7e0:	fcf42223          	sw	a5,-60(s0)
 7e4:	87ba                	mv	a5,a4
 7e6:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7ea:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
 7ee:	fc042783          	lw	a5,-64(s0)
 7f2:	2781                	sext.w	a5,a5
 7f4:	c38d                	beqz	a5,816 <printint+0x4e>
 7f6:	fc842783          	lw	a5,-56(s0)
 7fa:	2781                	sext.w	a5,a5
 7fc:	0007dd63          	bgez	a5,816 <printint+0x4e>
    neg = 1;
 800:	4785                	li	a5,1
 802:	fef42423          	sw	a5,-24(s0)
    x = -xx;
 806:	fc842783          	lw	a5,-56(s0)
 80a:	40f007bb          	negw	a5,a5
 80e:	2781                	sext.w	a5,a5
 810:	fef42223          	sw	a5,-28(s0)
 814:	a029                	j	81e <printint+0x56>
  } else {
    x = xx;
 816:	fc842783          	lw	a5,-56(s0)
 81a:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
 81e:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
 822:	fc442783          	lw	a5,-60(s0)
 826:	fe442703          	lw	a4,-28(s0)
 82a:	02f777bb          	remuw	a5,a4,a5
 82e:	0007861b          	sext.w	a2,a5
 832:	fec42783          	lw	a5,-20(s0)
 836:	0017871b          	addiw	a4,a5,1
 83a:	fee42623          	sw	a4,-20(s0)
 83e:	00000697          	auipc	a3,0x0
 842:	7c268693          	addi	a3,a3,1986 # 1000 <digits>
 846:	02061713          	slli	a4,a2,0x20
 84a:	9301                	srli	a4,a4,0x20
 84c:	9736                	add	a4,a4,a3
 84e:	00074703          	lbu	a4,0(a4)
 852:	17c1                	addi	a5,a5,-16
 854:	97a2                	add	a5,a5,s0
 856:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
 85a:	fc442783          	lw	a5,-60(s0)
 85e:	fe442703          	lw	a4,-28(s0)
 862:	02f757bb          	divuw	a5,a4,a5
 866:	fef42223          	sw	a5,-28(s0)
 86a:	fe442783          	lw	a5,-28(s0)
 86e:	2781                	sext.w	a5,a5
 870:	fbcd                	bnez	a5,822 <printint+0x5a>
  if(neg)
 872:	fe842783          	lw	a5,-24(s0)
 876:	2781                	sext.w	a5,a5
 878:	cf85                	beqz	a5,8b0 <printint+0xe8>
    buf[i++] = '-';
 87a:	fec42783          	lw	a5,-20(s0)
 87e:	0017871b          	addiw	a4,a5,1
 882:	fee42623          	sw	a4,-20(s0)
 886:	17c1                	addi	a5,a5,-16
 888:	97a2                	add	a5,a5,s0
 88a:	02d00713          	li	a4,45
 88e:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
 892:	a839                	j	8b0 <printint+0xe8>
    putc(fd, buf[i]);
 894:	fec42783          	lw	a5,-20(s0)
 898:	17c1                	addi	a5,a5,-16
 89a:	97a2                	add	a5,a5,s0
 89c:	fe07c703          	lbu	a4,-32(a5)
 8a0:	fcc42783          	lw	a5,-52(s0)
 8a4:	85ba                	mv	a1,a4
 8a6:	853e                	mv	a0,a5
 8a8:	00000097          	auipc	ra,0x0
 8ac:	eea080e7          	jalr	-278(ra) # 792 <putc>
  while(--i >= 0)
 8b0:	fec42783          	lw	a5,-20(s0)
 8b4:	37fd                	addiw	a5,a5,-1
 8b6:	fef42623          	sw	a5,-20(s0)
 8ba:	fec42783          	lw	a5,-20(s0)
 8be:	2781                	sext.w	a5,a5
 8c0:	fc07dae3          	bgez	a5,894 <printint+0xcc>
}
 8c4:	0001                	nop
 8c6:	0001                	nop
 8c8:	70e2                	ld	ra,56(sp)
 8ca:	7442                	ld	s0,48(sp)
 8cc:	6121                	addi	sp,sp,64
 8ce:	8082                	ret

00000000000008d0 <printptr>:

static void
printptr(int fd, uint64 x) {
 8d0:	7179                	addi	sp,sp,-48
 8d2:	f406                	sd	ra,40(sp)
 8d4:	f022                	sd	s0,32(sp)
 8d6:	1800                	addi	s0,sp,48
 8d8:	87aa                	mv	a5,a0
 8da:	fcb43823          	sd	a1,-48(s0)
 8de:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
 8e2:	fdc42783          	lw	a5,-36(s0)
 8e6:	03000593          	li	a1,48
 8ea:	853e                	mv	a0,a5
 8ec:	00000097          	auipc	ra,0x0
 8f0:	ea6080e7          	jalr	-346(ra) # 792 <putc>
  putc(fd, 'x');
 8f4:	fdc42783          	lw	a5,-36(s0)
 8f8:	07800593          	li	a1,120
 8fc:	853e                	mv	a0,a5
 8fe:	00000097          	auipc	ra,0x0
 902:	e94080e7          	jalr	-364(ra) # 792 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 906:	fe042623          	sw	zero,-20(s0)
 90a:	a82d                	j	944 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 90c:	fd043783          	ld	a5,-48(s0)
 910:	93f1                	srli	a5,a5,0x3c
 912:	00000717          	auipc	a4,0x0
 916:	6ee70713          	addi	a4,a4,1774 # 1000 <digits>
 91a:	97ba                	add	a5,a5,a4
 91c:	0007c703          	lbu	a4,0(a5)
 920:	fdc42783          	lw	a5,-36(s0)
 924:	85ba                	mv	a1,a4
 926:	853e                	mv	a0,a5
 928:	00000097          	auipc	ra,0x0
 92c:	e6a080e7          	jalr	-406(ra) # 792 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 930:	fec42783          	lw	a5,-20(s0)
 934:	2785                	addiw	a5,a5,1
 936:	fef42623          	sw	a5,-20(s0)
 93a:	fd043783          	ld	a5,-48(s0)
 93e:	0792                	slli	a5,a5,0x4
 940:	fcf43823          	sd	a5,-48(s0)
 944:	fec42783          	lw	a5,-20(s0)
 948:	873e                	mv	a4,a5
 94a:	47bd                	li	a5,15
 94c:	fce7f0e3          	bgeu	a5,a4,90c <printptr+0x3c>
}
 950:	0001                	nop
 952:	0001                	nop
 954:	70a2                	ld	ra,40(sp)
 956:	7402                	ld	s0,32(sp)
 958:	6145                	addi	sp,sp,48
 95a:	8082                	ret

000000000000095c <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 95c:	715d                	addi	sp,sp,-80
 95e:	e486                	sd	ra,72(sp)
 960:	e0a2                	sd	s0,64(sp)
 962:	0880                	addi	s0,sp,80
 964:	87aa                	mv	a5,a0
 966:	fcb43023          	sd	a1,-64(s0)
 96a:	fac43c23          	sd	a2,-72(s0)
 96e:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
 972:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 976:	fe042223          	sw	zero,-28(s0)
 97a:	a42d                	j	ba4 <vprintf+0x248>
    c = fmt[i] & 0xff;
 97c:	fe442783          	lw	a5,-28(s0)
 980:	fc043703          	ld	a4,-64(s0)
 984:	97ba                	add	a5,a5,a4
 986:	0007c783          	lbu	a5,0(a5)
 98a:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
 98e:	fe042783          	lw	a5,-32(s0)
 992:	2781                	sext.w	a5,a5
 994:	eb9d                	bnez	a5,9ca <vprintf+0x6e>
      if(c == '%'){
 996:	fdc42783          	lw	a5,-36(s0)
 99a:	0007871b          	sext.w	a4,a5
 99e:	02500793          	li	a5,37
 9a2:	00f71763          	bne	a4,a5,9b0 <vprintf+0x54>
        state = '%';
 9a6:	02500793          	li	a5,37
 9aa:	fef42023          	sw	a5,-32(s0)
 9ae:	a2f5                	j	b9a <vprintf+0x23e>
      } else {
        putc(fd, c);
 9b0:	fdc42783          	lw	a5,-36(s0)
 9b4:	0ff7f713          	zext.b	a4,a5
 9b8:	fcc42783          	lw	a5,-52(s0)
 9bc:	85ba                	mv	a1,a4
 9be:	853e                	mv	a0,a5
 9c0:	00000097          	auipc	ra,0x0
 9c4:	dd2080e7          	jalr	-558(ra) # 792 <putc>
 9c8:	aac9                	j	b9a <vprintf+0x23e>
      }
    } else if(state == '%'){
 9ca:	fe042783          	lw	a5,-32(s0)
 9ce:	0007871b          	sext.w	a4,a5
 9d2:	02500793          	li	a5,37
 9d6:	1cf71263          	bne	a4,a5,b9a <vprintf+0x23e>
      if(c == 'd'){
 9da:	fdc42783          	lw	a5,-36(s0)
 9de:	0007871b          	sext.w	a4,a5
 9e2:	06400793          	li	a5,100
 9e6:	02f71463          	bne	a4,a5,a0e <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
 9ea:	fb843783          	ld	a5,-72(s0)
 9ee:	00878713          	addi	a4,a5,8
 9f2:	fae43c23          	sd	a4,-72(s0)
 9f6:	4398                	lw	a4,0(a5)
 9f8:	fcc42783          	lw	a5,-52(s0)
 9fc:	4685                	li	a3,1
 9fe:	4629                	li	a2,10
 a00:	85ba                	mv	a1,a4
 a02:	853e                	mv	a0,a5
 a04:	00000097          	auipc	ra,0x0
 a08:	dc4080e7          	jalr	-572(ra) # 7c8 <printint>
 a0c:	a269                	j	b96 <vprintf+0x23a>
      } else if(c == 'l') {
 a0e:	fdc42783          	lw	a5,-36(s0)
 a12:	0007871b          	sext.w	a4,a5
 a16:	06c00793          	li	a5,108
 a1a:	02f71663          	bne	a4,a5,a46 <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a1e:	fb843783          	ld	a5,-72(s0)
 a22:	00878713          	addi	a4,a5,8
 a26:	fae43c23          	sd	a4,-72(s0)
 a2a:	639c                	ld	a5,0(a5)
 a2c:	0007871b          	sext.w	a4,a5
 a30:	fcc42783          	lw	a5,-52(s0)
 a34:	4681                	li	a3,0
 a36:	4629                	li	a2,10
 a38:	85ba                	mv	a1,a4
 a3a:	853e                	mv	a0,a5
 a3c:	00000097          	auipc	ra,0x0
 a40:	d8c080e7          	jalr	-628(ra) # 7c8 <printint>
 a44:	aa89                	j	b96 <vprintf+0x23a>
      } else if(c == 'x') {
 a46:	fdc42783          	lw	a5,-36(s0)
 a4a:	0007871b          	sext.w	a4,a5
 a4e:	07800793          	li	a5,120
 a52:	02f71463          	bne	a4,a5,a7a <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
 a56:	fb843783          	ld	a5,-72(s0)
 a5a:	00878713          	addi	a4,a5,8
 a5e:	fae43c23          	sd	a4,-72(s0)
 a62:	4398                	lw	a4,0(a5)
 a64:	fcc42783          	lw	a5,-52(s0)
 a68:	4681                	li	a3,0
 a6a:	4641                	li	a2,16
 a6c:	85ba                	mv	a1,a4
 a6e:	853e                	mv	a0,a5
 a70:	00000097          	auipc	ra,0x0
 a74:	d58080e7          	jalr	-680(ra) # 7c8 <printint>
 a78:	aa39                	j	b96 <vprintf+0x23a>
      } else if(c == 'p') {
 a7a:	fdc42783          	lw	a5,-36(s0)
 a7e:	0007871b          	sext.w	a4,a5
 a82:	07000793          	li	a5,112
 a86:	02f71263          	bne	a4,a5,aaa <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
 a8a:	fb843783          	ld	a5,-72(s0)
 a8e:	00878713          	addi	a4,a5,8
 a92:	fae43c23          	sd	a4,-72(s0)
 a96:	6398                	ld	a4,0(a5)
 a98:	fcc42783          	lw	a5,-52(s0)
 a9c:	85ba                	mv	a1,a4
 a9e:	853e                	mv	a0,a5
 aa0:	00000097          	auipc	ra,0x0
 aa4:	e30080e7          	jalr	-464(ra) # 8d0 <printptr>
 aa8:	a0fd                	j	b96 <vprintf+0x23a>
      } else if(c == 's'){
 aaa:	fdc42783          	lw	a5,-36(s0)
 aae:	0007871b          	sext.w	a4,a5
 ab2:	07300793          	li	a5,115
 ab6:	04f71c63          	bne	a4,a5,b0e <vprintf+0x1b2>
        s = va_arg(ap, char*);
 aba:	fb843783          	ld	a5,-72(s0)
 abe:	00878713          	addi	a4,a5,8
 ac2:	fae43c23          	sd	a4,-72(s0)
 ac6:	639c                	ld	a5,0(a5)
 ac8:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
 acc:	fe843783          	ld	a5,-24(s0)
 ad0:	eb8d                	bnez	a5,b02 <vprintf+0x1a6>
          s = "(null)";
 ad2:	00000797          	auipc	a5,0x0
 ad6:	4c678793          	addi	a5,a5,1222 # f98 <malloc+0x18c>
 ada:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 ade:	a015                	j	b02 <vprintf+0x1a6>
          putc(fd, *s);
 ae0:	fe843783          	ld	a5,-24(s0)
 ae4:	0007c703          	lbu	a4,0(a5)
 ae8:	fcc42783          	lw	a5,-52(s0)
 aec:	85ba                	mv	a1,a4
 aee:	853e                	mv	a0,a5
 af0:	00000097          	auipc	ra,0x0
 af4:	ca2080e7          	jalr	-862(ra) # 792 <putc>
          s++;
 af8:	fe843783          	ld	a5,-24(s0)
 afc:	0785                	addi	a5,a5,1
 afe:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
 b02:	fe843783          	ld	a5,-24(s0)
 b06:	0007c783          	lbu	a5,0(a5)
 b0a:	fbf9                	bnez	a5,ae0 <vprintf+0x184>
 b0c:	a069                	j	b96 <vprintf+0x23a>
        }
      } else if(c == 'c'){
 b0e:	fdc42783          	lw	a5,-36(s0)
 b12:	0007871b          	sext.w	a4,a5
 b16:	06300793          	li	a5,99
 b1a:	02f71463          	bne	a4,a5,b42 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
 b1e:	fb843783          	ld	a5,-72(s0)
 b22:	00878713          	addi	a4,a5,8
 b26:	fae43c23          	sd	a4,-72(s0)
 b2a:	439c                	lw	a5,0(a5)
 b2c:	0ff7f713          	zext.b	a4,a5
 b30:	fcc42783          	lw	a5,-52(s0)
 b34:	85ba                	mv	a1,a4
 b36:	853e                	mv	a0,a5
 b38:	00000097          	auipc	ra,0x0
 b3c:	c5a080e7          	jalr	-934(ra) # 792 <putc>
 b40:	a899                	j	b96 <vprintf+0x23a>
      } else if(c == '%'){
 b42:	fdc42783          	lw	a5,-36(s0)
 b46:	0007871b          	sext.w	a4,a5
 b4a:	02500793          	li	a5,37
 b4e:	00f71f63          	bne	a4,a5,b6c <vprintf+0x210>
        putc(fd, c);
 b52:	fdc42783          	lw	a5,-36(s0)
 b56:	0ff7f713          	zext.b	a4,a5
 b5a:	fcc42783          	lw	a5,-52(s0)
 b5e:	85ba                	mv	a1,a4
 b60:	853e                	mv	a0,a5
 b62:	00000097          	auipc	ra,0x0
 b66:	c30080e7          	jalr	-976(ra) # 792 <putc>
 b6a:	a035                	j	b96 <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b6c:	fcc42783          	lw	a5,-52(s0)
 b70:	02500593          	li	a1,37
 b74:	853e                	mv	a0,a5
 b76:	00000097          	auipc	ra,0x0
 b7a:	c1c080e7          	jalr	-996(ra) # 792 <putc>
        putc(fd, c);
 b7e:	fdc42783          	lw	a5,-36(s0)
 b82:	0ff7f713          	zext.b	a4,a5
 b86:	fcc42783          	lw	a5,-52(s0)
 b8a:	85ba                	mv	a1,a4
 b8c:	853e                	mv	a0,a5
 b8e:	00000097          	auipc	ra,0x0
 b92:	c04080e7          	jalr	-1020(ra) # 792 <putc>
      }
      state = 0;
 b96:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
 b9a:	fe442783          	lw	a5,-28(s0)
 b9e:	2785                	addiw	a5,a5,1
 ba0:	fef42223          	sw	a5,-28(s0)
 ba4:	fe442783          	lw	a5,-28(s0)
 ba8:	fc043703          	ld	a4,-64(s0)
 bac:	97ba                	add	a5,a5,a4
 bae:	0007c783          	lbu	a5,0(a5)
 bb2:	dc0795e3          	bnez	a5,97c <vprintf+0x20>
    }
  }
}
 bb6:	0001                	nop
 bb8:	0001                	nop
 bba:	60a6                	ld	ra,72(sp)
 bbc:	6406                	ld	s0,64(sp)
 bbe:	6161                	addi	sp,sp,80
 bc0:	8082                	ret

0000000000000bc2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 bc2:	7159                	addi	sp,sp,-112
 bc4:	fc06                	sd	ra,56(sp)
 bc6:	f822                	sd	s0,48(sp)
 bc8:	0080                	addi	s0,sp,64
 bca:	fcb43823          	sd	a1,-48(s0)
 bce:	e010                	sd	a2,0(s0)
 bd0:	e414                	sd	a3,8(s0)
 bd2:	e818                	sd	a4,16(s0)
 bd4:	ec1c                	sd	a5,24(s0)
 bd6:	03043023          	sd	a6,32(s0)
 bda:	03143423          	sd	a7,40(s0)
 bde:	87aa                	mv	a5,a0
 be0:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
 be4:	03040793          	addi	a5,s0,48
 be8:	fcf43423          	sd	a5,-56(s0)
 bec:	fc843783          	ld	a5,-56(s0)
 bf0:	fd078793          	addi	a5,a5,-48
 bf4:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
 bf8:	fe843703          	ld	a4,-24(s0)
 bfc:	fdc42783          	lw	a5,-36(s0)
 c00:	863a                	mv	a2,a4
 c02:	fd043583          	ld	a1,-48(s0)
 c06:	853e                	mv	a0,a5
 c08:	00000097          	auipc	ra,0x0
 c0c:	d54080e7          	jalr	-684(ra) # 95c <vprintf>
}
 c10:	0001                	nop
 c12:	70e2                	ld	ra,56(sp)
 c14:	7442                	ld	s0,48(sp)
 c16:	6165                	addi	sp,sp,112
 c18:	8082                	ret

0000000000000c1a <printf>:

void
printf(const char *fmt, ...)
{
 c1a:	7159                	addi	sp,sp,-112
 c1c:	f406                	sd	ra,40(sp)
 c1e:	f022                	sd	s0,32(sp)
 c20:	1800                	addi	s0,sp,48
 c22:	fca43c23          	sd	a0,-40(s0)
 c26:	e40c                	sd	a1,8(s0)
 c28:	e810                	sd	a2,16(s0)
 c2a:	ec14                	sd	a3,24(s0)
 c2c:	f018                	sd	a4,32(s0)
 c2e:	f41c                	sd	a5,40(s0)
 c30:	03043823          	sd	a6,48(s0)
 c34:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c38:	04040793          	addi	a5,s0,64
 c3c:	fcf43823          	sd	a5,-48(s0)
 c40:	fd043783          	ld	a5,-48(s0)
 c44:	fc878793          	addi	a5,a5,-56
 c48:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
 c4c:	fe843783          	ld	a5,-24(s0)
 c50:	863e                	mv	a2,a5
 c52:	fd843583          	ld	a1,-40(s0)
 c56:	4505                	li	a0,1
 c58:	00000097          	auipc	ra,0x0
 c5c:	d04080e7          	jalr	-764(ra) # 95c <vprintf>
}
 c60:	0001                	nop
 c62:	70a2                	ld	ra,40(sp)
 c64:	7402                	ld	s0,32(sp)
 c66:	6165                	addi	sp,sp,112
 c68:	8082                	ret

0000000000000c6a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c6a:	7179                	addi	sp,sp,-48
 c6c:	f422                	sd	s0,40(sp)
 c6e:	1800                	addi	s0,sp,48
 c70:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c74:	fd843783          	ld	a5,-40(s0)
 c78:	17c1                	addi	a5,a5,-16
 c7a:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c7e:	00000797          	auipc	a5,0x0
 c82:	5b278793          	addi	a5,a5,1458 # 1230 <freep>
 c86:	639c                	ld	a5,0(a5)
 c88:	fef43423          	sd	a5,-24(s0)
 c8c:	a815                	j	cc0 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c8e:	fe843783          	ld	a5,-24(s0)
 c92:	639c                	ld	a5,0(a5)
 c94:	fe843703          	ld	a4,-24(s0)
 c98:	00f76f63          	bltu	a4,a5,cb6 <free+0x4c>
 c9c:	fe043703          	ld	a4,-32(s0)
 ca0:	fe843783          	ld	a5,-24(s0)
 ca4:	02e7eb63          	bltu	a5,a4,cda <free+0x70>
 ca8:	fe843783          	ld	a5,-24(s0)
 cac:	639c                	ld	a5,0(a5)
 cae:	fe043703          	ld	a4,-32(s0)
 cb2:	02f76463          	bltu	a4,a5,cda <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cb6:	fe843783          	ld	a5,-24(s0)
 cba:	639c                	ld	a5,0(a5)
 cbc:	fef43423          	sd	a5,-24(s0)
 cc0:	fe043703          	ld	a4,-32(s0)
 cc4:	fe843783          	ld	a5,-24(s0)
 cc8:	fce7f3e3          	bgeu	a5,a4,c8e <free+0x24>
 ccc:	fe843783          	ld	a5,-24(s0)
 cd0:	639c                	ld	a5,0(a5)
 cd2:	fe043703          	ld	a4,-32(s0)
 cd6:	faf77ce3          	bgeu	a4,a5,c8e <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
 cda:	fe043783          	ld	a5,-32(s0)
 cde:	479c                	lw	a5,8(a5)
 ce0:	1782                	slli	a5,a5,0x20
 ce2:	9381                	srli	a5,a5,0x20
 ce4:	0792                	slli	a5,a5,0x4
 ce6:	fe043703          	ld	a4,-32(s0)
 cea:	973e                	add	a4,a4,a5
 cec:	fe843783          	ld	a5,-24(s0)
 cf0:	639c                	ld	a5,0(a5)
 cf2:	02f71763          	bne	a4,a5,d20 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
 cf6:	fe043783          	ld	a5,-32(s0)
 cfa:	4798                	lw	a4,8(a5)
 cfc:	fe843783          	ld	a5,-24(s0)
 d00:	639c                	ld	a5,0(a5)
 d02:	479c                	lw	a5,8(a5)
 d04:	9fb9                	addw	a5,a5,a4
 d06:	0007871b          	sext.w	a4,a5
 d0a:	fe043783          	ld	a5,-32(s0)
 d0e:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
 d10:	fe843783          	ld	a5,-24(s0)
 d14:	639c                	ld	a5,0(a5)
 d16:	6398                	ld	a4,0(a5)
 d18:	fe043783          	ld	a5,-32(s0)
 d1c:	e398                	sd	a4,0(a5)
 d1e:	a039                	j	d2c <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
 d20:	fe843783          	ld	a5,-24(s0)
 d24:	6398                	ld	a4,0(a5)
 d26:	fe043783          	ld	a5,-32(s0)
 d2a:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
 d2c:	fe843783          	ld	a5,-24(s0)
 d30:	479c                	lw	a5,8(a5)
 d32:	1782                	slli	a5,a5,0x20
 d34:	9381                	srli	a5,a5,0x20
 d36:	0792                	slli	a5,a5,0x4
 d38:	fe843703          	ld	a4,-24(s0)
 d3c:	97ba                	add	a5,a5,a4
 d3e:	fe043703          	ld	a4,-32(s0)
 d42:	02f71563          	bne	a4,a5,d6c <free+0x102>
    p->s.size += bp->s.size;
 d46:	fe843783          	ld	a5,-24(s0)
 d4a:	4798                	lw	a4,8(a5)
 d4c:	fe043783          	ld	a5,-32(s0)
 d50:	479c                	lw	a5,8(a5)
 d52:	9fb9                	addw	a5,a5,a4
 d54:	0007871b          	sext.w	a4,a5
 d58:	fe843783          	ld	a5,-24(s0)
 d5c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 d5e:	fe043783          	ld	a5,-32(s0)
 d62:	6398                	ld	a4,0(a5)
 d64:	fe843783          	ld	a5,-24(s0)
 d68:	e398                	sd	a4,0(a5)
 d6a:	a031                	j	d76 <free+0x10c>
  } else
    p->s.ptr = bp;
 d6c:	fe843783          	ld	a5,-24(s0)
 d70:	fe043703          	ld	a4,-32(s0)
 d74:	e398                	sd	a4,0(a5)
  freep = p;
 d76:	00000797          	auipc	a5,0x0
 d7a:	4ba78793          	addi	a5,a5,1210 # 1230 <freep>
 d7e:	fe843703          	ld	a4,-24(s0)
 d82:	e398                	sd	a4,0(a5)
}
 d84:	0001                	nop
 d86:	7422                	ld	s0,40(sp)
 d88:	6145                	addi	sp,sp,48
 d8a:	8082                	ret

0000000000000d8c <morecore>:

static Header*
morecore(uint nu)
{
 d8c:	7179                	addi	sp,sp,-48
 d8e:	f406                	sd	ra,40(sp)
 d90:	f022                	sd	s0,32(sp)
 d92:	1800                	addi	s0,sp,48
 d94:	87aa                	mv	a5,a0
 d96:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
 d9a:	fdc42783          	lw	a5,-36(s0)
 d9e:	0007871b          	sext.w	a4,a5
 da2:	6785                	lui	a5,0x1
 da4:	00f77563          	bgeu	a4,a5,dae <morecore+0x22>
    nu = 4096;
 da8:	6785                	lui	a5,0x1
 daa:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
 dae:	fdc42783          	lw	a5,-36(s0)
 db2:	0047979b          	slliw	a5,a5,0x4
 db6:	2781                	sext.w	a5,a5
 db8:	2781                	sext.w	a5,a5
 dba:	853e                	mv	a0,a5
 dbc:	00000097          	auipc	ra,0x0
 dc0:	99e080e7          	jalr	-1634(ra) # 75a <sbrk>
 dc4:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
 dc8:	fe843703          	ld	a4,-24(s0)
 dcc:	57fd                	li	a5,-1
 dce:	00f71463          	bne	a4,a5,dd6 <morecore+0x4a>
    return 0;
 dd2:	4781                	li	a5,0
 dd4:	a03d                	j	e02 <morecore+0x76>
  hp = (Header*)p;
 dd6:	fe843783          	ld	a5,-24(s0)
 dda:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
 dde:	fe043783          	ld	a5,-32(s0)
 de2:	fdc42703          	lw	a4,-36(s0)
 de6:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
 de8:	fe043783          	ld	a5,-32(s0)
 dec:	07c1                	addi	a5,a5,16 # 1010 <digits+0x10>
 dee:	853e                	mv	a0,a5
 df0:	00000097          	auipc	ra,0x0
 df4:	e7a080e7          	jalr	-390(ra) # c6a <free>
  return freep;
 df8:	00000797          	auipc	a5,0x0
 dfc:	43878793          	addi	a5,a5,1080 # 1230 <freep>
 e00:	639c                	ld	a5,0(a5)
}
 e02:	853e                	mv	a0,a5
 e04:	70a2                	ld	ra,40(sp)
 e06:	7402                	ld	s0,32(sp)
 e08:	6145                	addi	sp,sp,48
 e0a:	8082                	ret

0000000000000e0c <malloc>:

void*
malloc(uint nbytes)
{
 e0c:	7139                	addi	sp,sp,-64
 e0e:	fc06                	sd	ra,56(sp)
 e10:	f822                	sd	s0,48(sp)
 e12:	0080                	addi	s0,sp,64
 e14:	87aa                	mv	a5,a0
 e16:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e1a:	fcc46783          	lwu	a5,-52(s0)
 e1e:	07bd                	addi	a5,a5,15
 e20:	8391                	srli	a5,a5,0x4
 e22:	2781                	sext.w	a5,a5
 e24:	2785                	addiw	a5,a5,1
 e26:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
 e2a:	00000797          	auipc	a5,0x0
 e2e:	40678793          	addi	a5,a5,1030 # 1230 <freep>
 e32:	639c                	ld	a5,0(a5)
 e34:	fef43023          	sd	a5,-32(s0)
 e38:	fe043783          	ld	a5,-32(s0)
 e3c:	ef95                	bnez	a5,e78 <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
 e3e:	00000797          	auipc	a5,0x0
 e42:	3e278793          	addi	a5,a5,994 # 1220 <base>
 e46:	fef43023          	sd	a5,-32(s0)
 e4a:	00000797          	auipc	a5,0x0
 e4e:	3e678793          	addi	a5,a5,998 # 1230 <freep>
 e52:	fe043703          	ld	a4,-32(s0)
 e56:	e398                	sd	a4,0(a5)
 e58:	00000797          	auipc	a5,0x0
 e5c:	3d878793          	addi	a5,a5,984 # 1230 <freep>
 e60:	6398                	ld	a4,0(a5)
 e62:	00000797          	auipc	a5,0x0
 e66:	3be78793          	addi	a5,a5,958 # 1220 <base>
 e6a:	e398                	sd	a4,0(a5)
    base.s.size = 0;
 e6c:	00000797          	auipc	a5,0x0
 e70:	3b478793          	addi	a5,a5,948 # 1220 <base>
 e74:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e78:	fe043783          	ld	a5,-32(s0)
 e7c:	639c                	ld	a5,0(a5)
 e7e:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 e82:	fe843783          	ld	a5,-24(s0)
 e86:	4798                	lw	a4,8(a5)
 e88:	fdc42783          	lw	a5,-36(s0)
 e8c:	2781                	sext.w	a5,a5
 e8e:	06f76763          	bltu	a4,a5,efc <malloc+0xf0>
      if(p->s.size == nunits)
 e92:	fe843783          	ld	a5,-24(s0)
 e96:	4798                	lw	a4,8(a5)
 e98:	fdc42783          	lw	a5,-36(s0)
 e9c:	2781                	sext.w	a5,a5
 e9e:	00e79963          	bne	a5,a4,eb0 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
 ea2:	fe843783          	ld	a5,-24(s0)
 ea6:	6398                	ld	a4,0(a5)
 ea8:	fe043783          	ld	a5,-32(s0)
 eac:	e398                	sd	a4,0(a5)
 eae:	a825                	j	ee6 <malloc+0xda>
      else {
        p->s.size -= nunits;
 eb0:	fe843783          	ld	a5,-24(s0)
 eb4:	479c                	lw	a5,8(a5)
 eb6:	fdc42703          	lw	a4,-36(s0)
 eba:	9f99                	subw	a5,a5,a4
 ebc:	0007871b          	sext.w	a4,a5
 ec0:	fe843783          	ld	a5,-24(s0)
 ec4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ec6:	fe843783          	ld	a5,-24(s0)
 eca:	479c                	lw	a5,8(a5)
 ecc:	1782                	slli	a5,a5,0x20
 ece:	9381                	srli	a5,a5,0x20
 ed0:	0792                	slli	a5,a5,0x4
 ed2:	fe843703          	ld	a4,-24(s0)
 ed6:	97ba                	add	a5,a5,a4
 ed8:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
 edc:	fe843783          	ld	a5,-24(s0)
 ee0:	fdc42703          	lw	a4,-36(s0)
 ee4:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
 ee6:	00000797          	auipc	a5,0x0
 eea:	34a78793          	addi	a5,a5,842 # 1230 <freep>
 eee:	fe043703          	ld	a4,-32(s0)
 ef2:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
 ef4:	fe843783          	ld	a5,-24(s0)
 ef8:	07c1                	addi	a5,a5,16
 efa:	a091                	j	f3e <malloc+0x132>
    }
    if(p == freep)
 efc:	00000797          	auipc	a5,0x0
 f00:	33478793          	addi	a5,a5,820 # 1230 <freep>
 f04:	639c                	ld	a5,0(a5)
 f06:	fe843703          	ld	a4,-24(s0)
 f0a:	02f71063          	bne	a4,a5,f2a <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
 f0e:	fdc42783          	lw	a5,-36(s0)
 f12:	853e                	mv	a0,a5
 f14:	00000097          	auipc	ra,0x0
 f18:	e78080e7          	jalr	-392(ra) # d8c <morecore>
 f1c:	fea43423          	sd	a0,-24(s0)
 f20:	fe843783          	ld	a5,-24(s0)
 f24:	e399                	bnez	a5,f2a <malloc+0x11e>
        return 0;
 f26:	4781                	li	a5,0
 f28:	a819                	j	f3e <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f2a:	fe843783          	ld	a5,-24(s0)
 f2e:	fef43023          	sd	a5,-32(s0)
 f32:	fe843783          	ld	a5,-24(s0)
 f36:	639c                	ld	a5,0(a5)
 f38:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
 f3c:	b799                	j	e82 <malloc+0x76>
  }
}
 f3e:	853e                	mv	a0,a5
 f40:	70e2                	ld	ra,56(sp)
 f42:	7442                	ld	s0,48(sp)
 f44:	6121                	addi	sp,sp,64
 f46:	8082                	ret
