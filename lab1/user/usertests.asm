
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <r_sp>:
  return (x & SSTATUS_SIE) != 0;
}

static inline uint64
r_sp()
{
       0:	1101                	addi	sp,sp,-32
       2:	ec22                	sd	s0,24(sp)
       4:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
       6:	878a                	mv	a5,sp
       8:	fef43423          	sd	a5,-24(s0)
  return x;
       c:	fe843783          	ld	a5,-24(s0)
}
      10:	853e                	mv	a0,a5
      12:	6462                	ld	s0,24(sp)
      14:	6105                	addi	sp,sp,32
      16:	8082                	ret

0000000000000018 <copyin>:

// what if you pass ridiculous pointers to system calls
// that read user memory with copyin?
void
copyin(char *s)
{
      18:	715d                	addi	sp,sp,-80
      1a:	e486                	sd	ra,72(sp)
      1c:	e0a2                	sd	s0,64(sp)
      1e:	0880                	addi	s0,sp,80
      20:	faa43c23          	sd	a0,-72(s0)
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
      24:	4785                	li	a5,1
      26:	07fe                	slli	a5,a5,0x1f
      28:	fcf43423          	sd	a5,-56(s0)
      2c:	57fd                	li	a5,-1
      2e:	fcf43823          	sd	a5,-48(s0)

  for(int ai = 0; ai < 2; ai++){
      32:	fe042623          	sw	zero,-20(s0)
      36:	aa79                	j	1d4 <copyin+0x1bc>
    uint64 addr = addrs[ai];
      38:	fec42783          	lw	a5,-20(s0)
      3c:	078e                	slli	a5,a5,0x3
      3e:	17c1                	addi	a5,a5,-16
      40:	97a2                	add	a5,a5,s0
      42:	fd87b783          	ld	a5,-40(a5)
      46:	fef43023          	sd	a5,-32(s0)
    
    int fd = open("copyin1", O_CREATE|O_WRONLY);
      4a:	20100593          	li	a1,513
      4e:	00008517          	auipc	a0,0x8
      52:	0d250513          	addi	a0,a0,210 # 8120 <malloc+0x13e>
      56:	00008097          	auipc	ra,0x8
      5a:	892080e7          	jalr	-1902(ra) # 78e8 <open>
      5e:	87aa                	mv	a5,a0
      60:	fcf42e23          	sw	a5,-36(s0)
    if(fd < 0){
      64:	fdc42783          	lw	a5,-36(s0)
      68:	2781                	sext.w	a5,a5
      6a:	0007df63          	bgez	a5,88 <copyin+0x70>
      printf("open(copyin1) failed\n");
      6e:	00008517          	auipc	a0,0x8
      72:	0ba50513          	addi	a0,a0,186 # 8128 <malloc+0x146>
      76:	00008097          	auipc	ra,0x8
      7a:	d7a080e7          	jalr	-646(ra) # 7df0 <printf>
      exit(1);
      7e:	4505                	li	a0,1
      80:	00008097          	auipc	ra,0x8
      84:	828080e7          	jalr	-2008(ra) # 78a8 <exit>
    }
    int n = write(fd, (void*)addr, 8192);
      88:	fe043703          	ld	a4,-32(s0)
      8c:	fdc42783          	lw	a5,-36(s0)
      90:	6609                	lui	a2,0x2
      92:	85ba                	mv	a1,a4
      94:	853e                	mv	a0,a5
      96:	00008097          	auipc	ra,0x8
      9a:	832080e7          	jalr	-1998(ra) # 78c8 <write>
      9e:	87aa                	mv	a5,a0
      a0:	fcf42c23          	sw	a5,-40(s0)
    if(n >= 0){
      a4:	fd842783          	lw	a5,-40(s0)
      a8:	2781                	sext.w	a5,a5
      aa:	0207c463          	bltz	a5,d2 <copyin+0xba>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
      ae:	fd842783          	lw	a5,-40(s0)
      b2:	863e                	mv	a2,a5
      b4:	fe043583          	ld	a1,-32(s0)
      b8:	00008517          	auipc	a0,0x8
      bc:	08850513          	addi	a0,a0,136 # 8140 <malloc+0x15e>
      c0:	00008097          	auipc	ra,0x8
      c4:	d30080e7          	jalr	-720(ra) # 7df0 <printf>
      exit(1);
      c8:	4505                	li	a0,1
      ca:	00007097          	auipc	ra,0x7
      ce:	7de080e7          	jalr	2014(ra) # 78a8 <exit>
    }
    close(fd);
      d2:	fdc42783          	lw	a5,-36(s0)
      d6:	853e                	mv	a0,a5
      d8:	00007097          	auipc	ra,0x7
      dc:	7f8080e7          	jalr	2040(ra) # 78d0 <close>
    unlink("copyin1");
      e0:	00008517          	auipc	a0,0x8
      e4:	04050513          	addi	a0,a0,64 # 8120 <malloc+0x13e>
      e8:	00008097          	auipc	ra,0x8
      ec:	810080e7          	jalr	-2032(ra) # 78f8 <unlink>
    
    n = write(1, (char*)addr, 8192);
      f0:	fe043783          	ld	a5,-32(s0)
      f4:	6609                	lui	a2,0x2
      f6:	85be                	mv	a1,a5
      f8:	4505                	li	a0,1
      fa:	00007097          	auipc	ra,0x7
      fe:	7ce080e7          	jalr	1998(ra) # 78c8 <write>
     102:	87aa                	mv	a5,a0
     104:	fcf42c23          	sw	a5,-40(s0)
    if(n > 0){
     108:	fd842783          	lw	a5,-40(s0)
     10c:	2781                	sext.w	a5,a5
     10e:	02f05463          	blez	a5,136 <copyin+0x11e>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     112:	fd842783          	lw	a5,-40(s0)
     116:	863e                	mv	a2,a5
     118:	fe043583          	ld	a1,-32(s0)
     11c:	00008517          	auipc	a0,0x8
     120:	05450513          	addi	a0,a0,84 # 8170 <malloc+0x18e>
     124:	00008097          	auipc	ra,0x8
     128:	ccc080e7          	jalr	-820(ra) # 7df0 <printf>
      exit(1);
     12c:	4505                	li	a0,1
     12e:	00007097          	auipc	ra,0x7
     132:	77a080e7          	jalr	1914(ra) # 78a8 <exit>
    }
    
    int fds[2];
    if(pipe(fds) < 0){
     136:	fc040793          	addi	a5,s0,-64
     13a:	853e                	mv	a0,a5
     13c:	00007097          	auipc	ra,0x7
     140:	77c080e7          	jalr	1916(ra) # 78b8 <pipe>
     144:	87aa                	mv	a5,a0
     146:	0007df63          	bgez	a5,164 <copyin+0x14c>
      printf("pipe() failed\n");
     14a:	00008517          	auipc	a0,0x8
     14e:	05650513          	addi	a0,a0,86 # 81a0 <malloc+0x1be>
     152:	00008097          	auipc	ra,0x8
     156:	c9e080e7          	jalr	-866(ra) # 7df0 <printf>
      exit(1);
     15a:	4505                	li	a0,1
     15c:	00007097          	auipc	ra,0x7
     160:	74c080e7          	jalr	1868(ra) # 78a8 <exit>
    }
    n = write(fds[1], (char*)addr, 8192);
     164:	fc442783          	lw	a5,-60(s0)
     168:	fe043703          	ld	a4,-32(s0)
     16c:	6609                	lui	a2,0x2
     16e:	85ba                	mv	a1,a4
     170:	853e                	mv	a0,a5
     172:	00007097          	auipc	ra,0x7
     176:	756080e7          	jalr	1878(ra) # 78c8 <write>
     17a:	87aa                	mv	a5,a0
     17c:	fcf42c23          	sw	a5,-40(s0)
    if(n > 0){
     180:	fd842783          	lw	a5,-40(s0)
     184:	2781                	sext.w	a5,a5
     186:	02f05463          	blez	a5,1ae <copyin+0x196>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     18a:	fd842783          	lw	a5,-40(s0)
     18e:	863e                	mv	a2,a5
     190:	fe043583          	ld	a1,-32(s0)
     194:	00008517          	auipc	a0,0x8
     198:	01c50513          	addi	a0,a0,28 # 81b0 <malloc+0x1ce>
     19c:	00008097          	auipc	ra,0x8
     1a0:	c54080e7          	jalr	-940(ra) # 7df0 <printf>
      exit(1);
     1a4:	4505                	li	a0,1
     1a6:	00007097          	auipc	ra,0x7
     1aa:	702080e7          	jalr	1794(ra) # 78a8 <exit>
    }
    close(fds[0]);
     1ae:	fc042783          	lw	a5,-64(s0)
     1b2:	853e                	mv	a0,a5
     1b4:	00007097          	auipc	ra,0x7
     1b8:	71c080e7          	jalr	1820(ra) # 78d0 <close>
    close(fds[1]);
     1bc:	fc442783          	lw	a5,-60(s0)
     1c0:	853e                	mv	a0,a5
     1c2:	00007097          	auipc	ra,0x7
     1c6:	70e080e7          	jalr	1806(ra) # 78d0 <close>
  for(int ai = 0; ai < 2; ai++){
     1ca:	fec42783          	lw	a5,-20(s0)
     1ce:	2785                	addiw	a5,a5,1
     1d0:	fef42623          	sw	a5,-20(s0)
     1d4:	fec42783          	lw	a5,-20(s0)
     1d8:	0007871b          	sext.w	a4,a5
     1dc:	4785                	li	a5,1
     1de:	e4e7dde3          	bge	a5,a4,38 <copyin+0x20>
  }
}
     1e2:	0001                	nop
     1e4:	0001                	nop
     1e6:	60a6                	ld	ra,72(sp)
     1e8:	6406                	ld	s0,64(sp)
     1ea:	6161                	addi	sp,sp,80
     1ec:	8082                	ret

00000000000001ee <copyout>:

// what if you pass ridiculous pointers to system calls
// that write user memory with copyout?
void
copyout(char *s)
{
     1ee:	715d                	addi	sp,sp,-80
     1f0:	e486                	sd	ra,72(sp)
     1f2:	e0a2                	sd	s0,64(sp)
     1f4:	0880                	addi	s0,sp,80
     1f6:	faa43c23          	sd	a0,-72(s0)
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     1fa:	4785                	li	a5,1
     1fc:	07fe                	slli	a5,a5,0x1f
     1fe:	fcf43423          	sd	a5,-56(s0)
     202:	57fd                	li	a5,-1
     204:	fcf43823          	sd	a5,-48(s0)

  for(int ai = 0; ai < 2; ai++){
     208:	fe042623          	sw	zero,-20(s0)
     20c:	a271                	j	398 <copyout+0x1aa>
    uint64 addr = addrs[ai];
     20e:	fec42783          	lw	a5,-20(s0)
     212:	078e                	slli	a5,a5,0x3
     214:	17c1                	addi	a5,a5,-16
     216:	97a2                	add	a5,a5,s0
     218:	fd87b783          	ld	a5,-40(a5)
     21c:	fef43023          	sd	a5,-32(s0)

    int fd = open("README", 0);
     220:	4581                	li	a1,0
     222:	00008517          	auipc	a0,0x8
     226:	fbe50513          	addi	a0,a0,-66 # 81e0 <malloc+0x1fe>
     22a:	00007097          	auipc	ra,0x7
     22e:	6be080e7          	jalr	1726(ra) # 78e8 <open>
     232:	87aa                	mv	a5,a0
     234:	fcf42e23          	sw	a5,-36(s0)
    if(fd < 0){
     238:	fdc42783          	lw	a5,-36(s0)
     23c:	2781                	sext.w	a5,a5
     23e:	0007df63          	bgez	a5,25c <copyout+0x6e>
      printf("open(README) failed\n");
     242:	00008517          	auipc	a0,0x8
     246:	fa650513          	addi	a0,a0,-90 # 81e8 <malloc+0x206>
     24a:	00008097          	auipc	ra,0x8
     24e:	ba6080e7          	jalr	-1114(ra) # 7df0 <printf>
      exit(1);
     252:	4505                	li	a0,1
     254:	00007097          	auipc	ra,0x7
     258:	654080e7          	jalr	1620(ra) # 78a8 <exit>
    }
    int n = read(fd, (void*)addr, 8192);
     25c:	fe043703          	ld	a4,-32(s0)
     260:	fdc42783          	lw	a5,-36(s0)
     264:	6609                	lui	a2,0x2
     266:	85ba                	mv	a1,a4
     268:	853e                	mv	a0,a5
     26a:	00007097          	auipc	ra,0x7
     26e:	656080e7          	jalr	1622(ra) # 78c0 <read>
     272:	87aa                	mv	a5,a0
     274:	fcf42c23          	sw	a5,-40(s0)
    if(n > 0){
     278:	fd842783          	lw	a5,-40(s0)
     27c:	2781                	sext.w	a5,a5
     27e:	02f05463          	blez	a5,2a6 <copyout+0xb8>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     282:	fd842783          	lw	a5,-40(s0)
     286:	863e                	mv	a2,a5
     288:	fe043583          	ld	a1,-32(s0)
     28c:	00008517          	auipc	a0,0x8
     290:	f7450513          	addi	a0,a0,-140 # 8200 <malloc+0x21e>
     294:	00008097          	auipc	ra,0x8
     298:	b5c080e7          	jalr	-1188(ra) # 7df0 <printf>
      exit(1);
     29c:	4505                	li	a0,1
     29e:	00007097          	auipc	ra,0x7
     2a2:	60a080e7          	jalr	1546(ra) # 78a8 <exit>
    }
    close(fd);
     2a6:	fdc42783          	lw	a5,-36(s0)
     2aa:	853e                	mv	a0,a5
     2ac:	00007097          	auipc	ra,0x7
     2b0:	624080e7          	jalr	1572(ra) # 78d0 <close>

    int fds[2];
    if(pipe(fds) < 0){
     2b4:	fc040793          	addi	a5,s0,-64
     2b8:	853e                	mv	a0,a5
     2ba:	00007097          	auipc	ra,0x7
     2be:	5fe080e7          	jalr	1534(ra) # 78b8 <pipe>
     2c2:	87aa                	mv	a5,a0
     2c4:	0007df63          	bgez	a5,2e2 <copyout+0xf4>
      printf("pipe() failed\n");
     2c8:	00008517          	auipc	a0,0x8
     2cc:	ed850513          	addi	a0,a0,-296 # 81a0 <malloc+0x1be>
     2d0:	00008097          	auipc	ra,0x8
     2d4:	b20080e7          	jalr	-1248(ra) # 7df0 <printf>
      exit(1);
     2d8:	4505                	li	a0,1
     2da:	00007097          	auipc	ra,0x7
     2de:	5ce080e7          	jalr	1486(ra) # 78a8 <exit>
    }
    n = write(fds[1], "x", 1);
     2e2:	fc442783          	lw	a5,-60(s0)
     2e6:	4605                	li	a2,1
     2e8:	00008597          	auipc	a1,0x8
     2ec:	f4858593          	addi	a1,a1,-184 # 8230 <malloc+0x24e>
     2f0:	853e                	mv	a0,a5
     2f2:	00007097          	auipc	ra,0x7
     2f6:	5d6080e7          	jalr	1494(ra) # 78c8 <write>
     2fa:	87aa                	mv	a5,a0
     2fc:	fcf42c23          	sw	a5,-40(s0)
    if(n != 1){
     300:	fd842783          	lw	a5,-40(s0)
     304:	0007871b          	sext.w	a4,a5
     308:	4785                	li	a5,1
     30a:	00f70f63          	beq	a4,a5,328 <copyout+0x13a>
      printf("pipe write failed\n");
     30e:	00008517          	auipc	a0,0x8
     312:	f2a50513          	addi	a0,a0,-214 # 8238 <malloc+0x256>
     316:	00008097          	auipc	ra,0x8
     31a:	ada080e7          	jalr	-1318(ra) # 7df0 <printf>
      exit(1);
     31e:	4505                	li	a0,1
     320:	00007097          	auipc	ra,0x7
     324:	588080e7          	jalr	1416(ra) # 78a8 <exit>
    }
    n = read(fds[0], (void*)addr, 8192);
     328:	fc042783          	lw	a5,-64(s0)
     32c:	fe043703          	ld	a4,-32(s0)
     330:	6609                	lui	a2,0x2
     332:	85ba                	mv	a1,a4
     334:	853e                	mv	a0,a5
     336:	00007097          	auipc	ra,0x7
     33a:	58a080e7          	jalr	1418(ra) # 78c0 <read>
     33e:	87aa                	mv	a5,a0
     340:	fcf42c23          	sw	a5,-40(s0)
    if(n > 0){
     344:	fd842783          	lw	a5,-40(s0)
     348:	2781                	sext.w	a5,a5
     34a:	02f05463          	blez	a5,372 <copyout+0x184>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     34e:	fd842783          	lw	a5,-40(s0)
     352:	863e                	mv	a2,a5
     354:	fe043583          	ld	a1,-32(s0)
     358:	00008517          	auipc	a0,0x8
     35c:	ef850513          	addi	a0,a0,-264 # 8250 <malloc+0x26e>
     360:	00008097          	auipc	ra,0x8
     364:	a90080e7          	jalr	-1392(ra) # 7df0 <printf>
      exit(1);
     368:	4505                	li	a0,1
     36a:	00007097          	auipc	ra,0x7
     36e:	53e080e7          	jalr	1342(ra) # 78a8 <exit>
    }
    close(fds[0]);
     372:	fc042783          	lw	a5,-64(s0)
     376:	853e                	mv	a0,a5
     378:	00007097          	auipc	ra,0x7
     37c:	558080e7          	jalr	1368(ra) # 78d0 <close>
    close(fds[1]);
     380:	fc442783          	lw	a5,-60(s0)
     384:	853e                	mv	a0,a5
     386:	00007097          	auipc	ra,0x7
     38a:	54a080e7          	jalr	1354(ra) # 78d0 <close>
  for(int ai = 0; ai < 2; ai++){
     38e:	fec42783          	lw	a5,-20(s0)
     392:	2785                	addiw	a5,a5,1
     394:	fef42623          	sw	a5,-20(s0)
     398:	fec42783          	lw	a5,-20(s0)
     39c:	0007871b          	sext.w	a4,a5
     3a0:	4785                	li	a5,1
     3a2:	e6e7d6e3          	bge	a5,a4,20e <copyout+0x20>
  }
}
     3a6:	0001                	nop
     3a8:	0001                	nop
     3aa:	60a6                	ld	ra,72(sp)
     3ac:	6406                	ld	s0,64(sp)
     3ae:	6161                	addi	sp,sp,80
     3b0:	8082                	ret

00000000000003b2 <copyinstr1>:

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
     3b2:	715d                	addi	sp,sp,-80
     3b4:	e486                	sd	ra,72(sp)
     3b6:	e0a2                	sd	s0,64(sp)
     3b8:	0880                	addi	s0,sp,80
     3ba:	faa43c23          	sd	a0,-72(s0)
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     3be:	4785                	li	a5,1
     3c0:	07fe                	slli	a5,a5,0x1f
     3c2:	fcf43423          	sd	a5,-56(s0)
     3c6:	57fd                	li	a5,-1
     3c8:	fcf43823          	sd	a5,-48(s0)

  for(int ai = 0; ai < 2; ai++){
     3cc:	fe042623          	sw	zero,-20(s0)
     3d0:	a095                	j	434 <copyinstr1+0x82>
    uint64 addr = addrs[ai];
     3d2:	fec42783          	lw	a5,-20(s0)
     3d6:	078e                	slli	a5,a5,0x3
     3d8:	17c1                	addi	a5,a5,-16
     3da:	97a2                	add	a5,a5,s0
     3dc:	fd87b783          	ld	a5,-40(a5)
     3e0:	fef43023          	sd	a5,-32(s0)

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     3e4:	fe043783          	ld	a5,-32(s0)
     3e8:	20100593          	li	a1,513
     3ec:	853e                	mv	a0,a5
     3ee:	00007097          	auipc	ra,0x7
     3f2:	4fa080e7          	jalr	1274(ra) # 78e8 <open>
     3f6:	87aa                	mv	a5,a0
     3f8:	fcf42e23          	sw	a5,-36(s0)
    if(fd >= 0){
     3fc:	fdc42783          	lw	a5,-36(s0)
     400:	2781                	sext.w	a5,a5
     402:	0207c463          	bltz	a5,42a <copyinstr1+0x78>
      printf("open(%p) returned %d, not -1\n", addr, fd);
     406:	fdc42783          	lw	a5,-36(s0)
     40a:	863e                	mv	a2,a5
     40c:	fe043583          	ld	a1,-32(s0)
     410:	00008517          	auipc	a0,0x8
     414:	e7050513          	addi	a0,a0,-400 # 8280 <malloc+0x29e>
     418:	00008097          	auipc	ra,0x8
     41c:	9d8080e7          	jalr	-1576(ra) # 7df0 <printf>
      exit(1);
     420:	4505                	li	a0,1
     422:	00007097          	auipc	ra,0x7
     426:	486080e7          	jalr	1158(ra) # 78a8 <exit>
  for(int ai = 0; ai < 2; ai++){
     42a:	fec42783          	lw	a5,-20(s0)
     42e:	2785                	addiw	a5,a5,1
     430:	fef42623          	sw	a5,-20(s0)
     434:	fec42783          	lw	a5,-20(s0)
     438:	0007871b          	sext.w	a4,a5
     43c:	4785                	li	a5,1
     43e:	f8e7dae3          	bge	a5,a4,3d2 <copyinstr1+0x20>
    }
  }
}
     442:	0001                	nop
     444:	0001                	nop
     446:	60a6                	ld	ra,72(sp)
     448:	6406                	ld	s0,64(sp)
     44a:	6161                	addi	sp,sp,80
     44c:	8082                	ret

000000000000044e <copyinstr2>:
// what if a string system call argument is exactly the size
// of the kernel buffer it is copied into, so that the null
// would fall just beyond the end of the kernel buffer?
void
copyinstr2(char *s)
{
     44e:	7151                	addi	sp,sp,-240
     450:	f586                	sd	ra,232(sp)
     452:	f1a2                	sd	s0,224(sp)
     454:	1980                	addi	s0,sp,240
     456:	f0a43c23          	sd	a0,-232(s0)
  char b[MAXPATH+1];

  for(int i = 0; i < MAXPATH; i++)
     45a:	fe042623          	sw	zero,-20(s0)
     45e:	a831                	j	47a <copyinstr2+0x2c>
    b[i] = 'x';
     460:	fec42783          	lw	a5,-20(s0)
     464:	17c1                	addi	a5,a5,-16
     466:	97a2                	add	a5,a5,s0
     468:	07800713          	li	a4,120
     46c:	f6e78423          	sb	a4,-152(a5)
  for(int i = 0; i < MAXPATH; i++)
     470:	fec42783          	lw	a5,-20(s0)
     474:	2785                	addiw	a5,a5,1
     476:	fef42623          	sw	a5,-20(s0)
     47a:	fec42783          	lw	a5,-20(s0)
     47e:	0007871b          	sext.w	a4,a5
     482:	07f00793          	li	a5,127
     486:	fce7dde3          	bge	a5,a4,460 <copyinstr2+0x12>
  b[MAXPATH] = '\0';
     48a:	fc040c23          	sb	zero,-40(s0)
  
  int ret = unlink(b);
     48e:	f5840793          	addi	a5,s0,-168
     492:	853e                	mv	a0,a5
     494:	00007097          	auipc	ra,0x7
     498:	464080e7          	jalr	1124(ra) # 78f8 <unlink>
     49c:	87aa                	mv	a5,a0
     49e:	fef42223          	sw	a5,-28(s0)
  if(ret != -1){
     4a2:	fe442783          	lw	a5,-28(s0)
     4a6:	0007871b          	sext.w	a4,a5
     4aa:	57fd                	li	a5,-1
     4ac:	02f70563          	beq	a4,a5,4d6 <copyinstr2+0x88>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
     4b0:	fe442703          	lw	a4,-28(s0)
     4b4:	f5840793          	addi	a5,s0,-168
     4b8:	863a                	mv	a2,a4
     4ba:	85be                	mv	a1,a5
     4bc:	00008517          	auipc	a0,0x8
     4c0:	de450513          	addi	a0,a0,-540 # 82a0 <malloc+0x2be>
     4c4:	00008097          	auipc	ra,0x8
     4c8:	92c080e7          	jalr	-1748(ra) # 7df0 <printf>
    exit(1);
     4cc:	4505                	li	a0,1
     4ce:	00007097          	auipc	ra,0x7
     4d2:	3da080e7          	jalr	986(ra) # 78a8 <exit>
  }

  int fd = open(b, O_CREATE | O_WRONLY);
     4d6:	f5840793          	addi	a5,s0,-168
     4da:	20100593          	li	a1,513
     4de:	853e                	mv	a0,a5
     4e0:	00007097          	auipc	ra,0x7
     4e4:	408080e7          	jalr	1032(ra) # 78e8 <open>
     4e8:	87aa                	mv	a5,a0
     4ea:	fef42023          	sw	a5,-32(s0)
  if(fd != -1){
     4ee:	fe042783          	lw	a5,-32(s0)
     4f2:	0007871b          	sext.w	a4,a5
     4f6:	57fd                	li	a5,-1
     4f8:	02f70563          	beq	a4,a5,522 <copyinstr2+0xd4>
    printf("open(%s) returned %d, not -1\n", b, fd);
     4fc:	fe042703          	lw	a4,-32(s0)
     500:	f5840793          	addi	a5,s0,-168
     504:	863a                	mv	a2,a4
     506:	85be                	mv	a1,a5
     508:	00008517          	auipc	a0,0x8
     50c:	db850513          	addi	a0,a0,-584 # 82c0 <malloc+0x2de>
     510:	00008097          	auipc	ra,0x8
     514:	8e0080e7          	jalr	-1824(ra) # 7df0 <printf>
    exit(1);
     518:	4505                	li	a0,1
     51a:	00007097          	auipc	ra,0x7
     51e:	38e080e7          	jalr	910(ra) # 78a8 <exit>
  }

  ret = link(b, b);
     522:	f5840713          	addi	a4,s0,-168
     526:	f5840793          	addi	a5,s0,-168
     52a:	85ba                	mv	a1,a4
     52c:	853e                	mv	a0,a5
     52e:	00007097          	auipc	ra,0x7
     532:	3da080e7          	jalr	986(ra) # 7908 <link>
     536:	87aa                	mv	a5,a0
     538:	fef42223          	sw	a5,-28(s0)
  if(ret != -1){
     53c:	fe442783          	lw	a5,-28(s0)
     540:	0007871b          	sext.w	a4,a5
     544:	57fd                	li	a5,-1
     546:	02f70763          	beq	a4,a5,574 <copyinstr2+0x126>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
     54a:	fe442683          	lw	a3,-28(s0)
     54e:	f5840713          	addi	a4,s0,-168
     552:	f5840793          	addi	a5,s0,-168
     556:	863a                	mv	a2,a4
     558:	85be                	mv	a1,a5
     55a:	00008517          	auipc	a0,0x8
     55e:	d8650513          	addi	a0,a0,-634 # 82e0 <malloc+0x2fe>
     562:	00008097          	auipc	ra,0x8
     566:	88e080e7          	jalr	-1906(ra) # 7df0 <printf>
    exit(1);
     56a:	4505                	li	a0,1
     56c:	00007097          	auipc	ra,0x7
     570:	33c080e7          	jalr	828(ra) # 78a8 <exit>
  }

  char *args[] = { "xx", 0 };
     574:	00008797          	auipc	a5,0x8
     578:	d9478793          	addi	a5,a5,-620 # 8308 <malloc+0x326>
     57c:	f4f43423          	sd	a5,-184(s0)
     580:	f4043823          	sd	zero,-176(s0)
  ret = exec(b, args);
     584:	f4840713          	addi	a4,s0,-184
     588:	f5840793          	addi	a5,s0,-168
     58c:	85ba                	mv	a1,a4
     58e:	853e                	mv	a0,a5
     590:	00007097          	auipc	ra,0x7
     594:	350080e7          	jalr	848(ra) # 78e0 <exec>
     598:	87aa                	mv	a5,a0
     59a:	fef42223          	sw	a5,-28(s0)
  if(ret != -1){
     59e:	fe442783          	lw	a5,-28(s0)
     5a2:	0007871b          	sext.w	a4,a5
     5a6:	57fd                	li	a5,-1
     5a8:	02f70563          	beq	a4,a5,5d2 <copyinstr2+0x184>
    printf("exec(%s) returned %d, not -1\n", b, fd);
     5ac:	fe042703          	lw	a4,-32(s0)
     5b0:	f5840793          	addi	a5,s0,-168
     5b4:	863a                	mv	a2,a4
     5b6:	85be                	mv	a1,a5
     5b8:	00008517          	auipc	a0,0x8
     5bc:	d5850513          	addi	a0,a0,-680 # 8310 <malloc+0x32e>
     5c0:	00008097          	auipc	ra,0x8
     5c4:	830080e7          	jalr	-2000(ra) # 7df0 <printf>
    exit(1);
     5c8:	4505                	li	a0,1
     5ca:	00007097          	auipc	ra,0x7
     5ce:	2de080e7          	jalr	734(ra) # 78a8 <exit>
  }

  int pid = fork();
     5d2:	00007097          	auipc	ra,0x7
     5d6:	2ce080e7          	jalr	718(ra) # 78a0 <fork>
     5da:	87aa                	mv	a5,a0
     5dc:	fcf42e23          	sw	a5,-36(s0)
  if(pid < 0){
     5e0:	fdc42783          	lw	a5,-36(s0)
     5e4:	2781                	sext.w	a5,a5
     5e6:	0007df63          	bgez	a5,604 <copyinstr2+0x1b6>
    printf("fork failed\n");
     5ea:	00008517          	auipc	a0,0x8
     5ee:	d4650513          	addi	a0,a0,-698 # 8330 <malloc+0x34e>
     5f2:	00007097          	auipc	ra,0x7
     5f6:	7fe080e7          	jalr	2046(ra) # 7df0 <printf>
    exit(1);
     5fa:	4505                	li	a0,1
     5fc:	00007097          	auipc	ra,0x7
     600:	2ac080e7          	jalr	684(ra) # 78a8 <exit>
  }
  if(pid == 0){
     604:	fdc42783          	lw	a5,-36(s0)
     608:	2781                	sext.w	a5,a5
     60a:	efd5                	bnez	a5,6c6 <copyinstr2+0x278>
    static char big[PGSIZE+1];
    for(int i = 0; i < PGSIZE; i++)
     60c:	fe042423          	sw	zero,-24(s0)
     610:	a00d                	j	632 <copyinstr2+0x1e4>
      big[i] = 'x';
     612:	00010717          	auipc	a4,0x10
     616:	56e70713          	addi	a4,a4,1390 # 10b80 <big.0>
     61a:	fe842783          	lw	a5,-24(s0)
     61e:	97ba                	add	a5,a5,a4
     620:	07800713          	li	a4,120
     624:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
     628:	fe842783          	lw	a5,-24(s0)
     62c:	2785                	addiw	a5,a5,1
     62e:	fef42423          	sw	a5,-24(s0)
     632:	fe842783          	lw	a5,-24(s0)
     636:	0007871b          	sext.w	a4,a5
     63a:	6785                	lui	a5,0x1
     63c:	fcf74be3          	blt	a4,a5,612 <copyinstr2+0x1c4>
    big[PGSIZE] = '\0';
     640:	00010717          	auipc	a4,0x10
     644:	54070713          	addi	a4,a4,1344 # 10b80 <big.0>
     648:	6785                	lui	a5,0x1
     64a:	97ba                	add	a5,a5,a4
     64c:	00078023          	sb	zero,0(a5) # 1000 <truncate3+0x1b2>
    char *args2[] = { big, big, big, 0 };
     650:	00008797          	auipc	a5,0x8
     654:	d5078793          	addi	a5,a5,-688 # 83a0 <malloc+0x3be>
     658:	6390                	ld	a2,0(a5)
     65a:	6794                	ld	a3,8(a5)
     65c:	6b98                	ld	a4,16(a5)
     65e:	6f9c                	ld	a5,24(a5)
     660:	f2c43023          	sd	a2,-224(s0)
     664:	f2d43423          	sd	a3,-216(s0)
     668:	f2e43823          	sd	a4,-208(s0)
     66c:	f2f43c23          	sd	a5,-200(s0)
    ret = exec("echo", args2);
     670:	f2040793          	addi	a5,s0,-224
     674:	85be                	mv	a1,a5
     676:	00008517          	auipc	a0,0x8
     67a:	cca50513          	addi	a0,a0,-822 # 8340 <malloc+0x35e>
     67e:	00007097          	auipc	ra,0x7
     682:	262080e7          	jalr	610(ra) # 78e0 <exec>
     686:	87aa                	mv	a5,a0
     688:	fef42223          	sw	a5,-28(s0)
    if(ret != -1){
     68c:	fe442783          	lw	a5,-28(s0)
     690:	0007871b          	sext.w	a4,a5
     694:	57fd                	li	a5,-1
     696:	02f70263          	beq	a4,a5,6ba <copyinstr2+0x26c>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
     69a:	fe042783          	lw	a5,-32(s0)
     69e:	85be                	mv	a1,a5
     6a0:	00008517          	auipc	a0,0x8
     6a4:	ca850513          	addi	a0,a0,-856 # 8348 <malloc+0x366>
     6a8:	00007097          	auipc	ra,0x7
     6ac:	748080e7          	jalr	1864(ra) # 7df0 <printf>
      exit(1);
     6b0:	4505                	li	a0,1
     6b2:	00007097          	auipc	ra,0x7
     6b6:	1f6080e7          	jalr	502(ra) # 78a8 <exit>
    }
    exit(747); // OK
     6ba:	2eb00513          	li	a0,747
     6be:	00007097          	auipc	ra,0x7
     6c2:	1ea080e7          	jalr	490(ra) # 78a8 <exit>
  }

  int st = 0;
     6c6:	f4042223          	sw	zero,-188(s0)
  wait(&st);
     6ca:	f4440793          	addi	a5,s0,-188
     6ce:	853e                	mv	a0,a5
     6d0:	00007097          	auipc	ra,0x7
     6d4:	1e0080e7          	jalr	480(ra) # 78b0 <wait>
  if(st != 747){
     6d8:	f4442783          	lw	a5,-188(s0)
     6dc:	873e                	mv	a4,a5
     6de:	2eb00793          	li	a5,747
     6e2:	00f70f63          	beq	a4,a5,700 <copyinstr2+0x2b2>
    printf("exec(echo, BIG) succeeded, should have failed\n");
     6e6:	00008517          	auipc	a0,0x8
     6ea:	c8a50513          	addi	a0,a0,-886 # 8370 <malloc+0x38e>
     6ee:	00007097          	auipc	ra,0x7
     6f2:	702080e7          	jalr	1794(ra) # 7df0 <printf>
    exit(1);
     6f6:	4505                	li	a0,1
     6f8:	00007097          	auipc	ra,0x7
     6fc:	1b0080e7          	jalr	432(ra) # 78a8 <exit>
  }
}
     700:	0001                	nop
     702:	70ae                	ld	ra,232(sp)
     704:	740e                	ld	s0,224(sp)
     706:	616d                	addi	sp,sp,240
     708:	8082                	ret

000000000000070a <copyinstr3>:

// what if a string argument crosses over the end of last user page?
void
copyinstr3(char *s)
{
     70a:	715d                	addi	sp,sp,-80
     70c:	e486                	sd	ra,72(sp)
     70e:	e0a2                	sd	s0,64(sp)
     710:	0880                	addi	s0,sp,80
     712:	faa43c23          	sd	a0,-72(s0)
  sbrk(8192);
     716:	6509                	lui	a0,0x2
     718:	00007097          	auipc	ra,0x7
     71c:	218080e7          	jalr	536(ra) # 7930 <sbrk>
  uint64 top = (uint64) sbrk(0);
     720:	4501                	li	a0,0
     722:	00007097          	auipc	ra,0x7
     726:	20e080e7          	jalr	526(ra) # 7930 <sbrk>
     72a:	87aa                	mv	a5,a0
     72c:	fef43423          	sd	a5,-24(s0)
  if((top % PGSIZE) != 0){
     730:	fe843703          	ld	a4,-24(s0)
     734:	6785                	lui	a5,0x1
     736:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
     738:	8ff9                	and	a5,a5,a4
     73a:	c39d                	beqz	a5,760 <copyinstr3+0x56>
    sbrk(PGSIZE - (top % PGSIZE));
     73c:	fe843783          	ld	a5,-24(s0)
     740:	2781                	sext.w	a5,a5
     742:	873e                	mv	a4,a5
     744:	6785                	lui	a5,0x1
     746:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
     748:	8ff9                	and	a5,a5,a4
     74a:	2781                	sext.w	a5,a5
     74c:	6705                	lui	a4,0x1
     74e:	40f707bb          	subw	a5,a4,a5
     752:	2781                	sext.w	a5,a5
     754:	2781                	sext.w	a5,a5
     756:	853e                	mv	a0,a5
     758:	00007097          	auipc	ra,0x7
     75c:	1d8080e7          	jalr	472(ra) # 7930 <sbrk>
  }
  top = (uint64) sbrk(0);
     760:	4501                	li	a0,0
     762:	00007097          	auipc	ra,0x7
     766:	1ce080e7          	jalr	462(ra) # 7930 <sbrk>
     76a:	87aa                	mv	a5,a0
     76c:	fef43423          	sd	a5,-24(s0)
  if(top % PGSIZE){
     770:	fe843703          	ld	a4,-24(s0)
     774:	6785                	lui	a5,0x1
     776:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
     778:	8ff9                	and	a5,a5,a4
     77a:	cf91                	beqz	a5,796 <copyinstr3+0x8c>
    printf("oops\n");
     77c:	00008517          	auipc	a0,0x8
     780:	c4450513          	addi	a0,a0,-956 # 83c0 <malloc+0x3de>
     784:	00007097          	auipc	ra,0x7
     788:	66c080e7          	jalr	1644(ra) # 7df0 <printf>
    exit(1);
     78c:	4505                	li	a0,1
     78e:	00007097          	auipc	ra,0x7
     792:	11a080e7          	jalr	282(ra) # 78a8 <exit>
  }

  char *b = (char *) (top - 1);
     796:	fe843783          	ld	a5,-24(s0)
     79a:	17fd                	addi	a5,a5,-1
     79c:	fef43023          	sd	a5,-32(s0)
  *b = 'x';
     7a0:	fe043783          	ld	a5,-32(s0)
     7a4:	07800713          	li	a4,120
     7a8:	00e78023          	sb	a4,0(a5)

  int ret = unlink(b);
     7ac:	fe043503          	ld	a0,-32(s0)
     7b0:	00007097          	auipc	ra,0x7
     7b4:	148080e7          	jalr	328(ra) # 78f8 <unlink>
     7b8:	87aa                	mv	a5,a0
     7ba:	fcf42e23          	sw	a5,-36(s0)
  if(ret != -1){
     7be:	fdc42783          	lw	a5,-36(s0)
     7c2:	0007871b          	sext.w	a4,a5
     7c6:	57fd                	li	a5,-1
     7c8:	02f70463          	beq	a4,a5,7f0 <copyinstr3+0xe6>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
     7cc:	fdc42783          	lw	a5,-36(s0)
     7d0:	863e                	mv	a2,a5
     7d2:	fe043583          	ld	a1,-32(s0)
     7d6:	00008517          	auipc	a0,0x8
     7da:	aca50513          	addi	a0,a0,-1334 # 82a0 <malloc+0x2be>
     7de:	00007097          	auipc	ra,0x7
     7e2:	612080e7          	jalr	1554(ra) # 7df0 <printf>
    exit(1);
     7e6:	4505                	li	a0,1
     7e8:	00007097          	auipc	ra,0x7
     7ec:	0c0080e7          	jalr	192(ra) # 78a8 <exit>
  }

  int fd = open(b, O_CREATE | O_WRONLY);
     7f0:	20100593          	li	a1,513
     7f4:	fe043503          	ld	a0,-32(s0)
     7f8:	00007097          	auipc	ra,0x7
     7fc:	0f0080e7          	jalr	240(ra) # 78e8 <open>
     800:	87aa                	mv	a5,a0
     802:	fcf42c23          	sw	a5,-40(s0)
  if(fd != -1){
     806:	fd842783          	lw	a5,-40(s0)
     80a:	0007871b          	sext.w	a4,a5
     80e:	57fd                	li	a5,-1
     810:	02f70463          	beq	a4,a5,838 <copyinstr3+0x12e>
    printf("open(%s) returned %d, not -1\n", b, fd);
     814:	fd842783          	lw	a5,-40(s0)
     818:	863e                	mv	a2,a5
     81a:	fe043583          	ld	a1,-32(s0)
     81e:	00008517          	auipc	a0,0x8
     822:	aa250513          	addi	a0,a0,-1374 # 82c0 <malloc+0x2de>
     826:	00007097          	auipc	ra,0x7
     82a:	5ca080e7          	jalr	1482(ra) # 7df0 <printf>
    exit(1);
     82e:	4505                	li	a0,1
     830:	00007097          	auipc	ra,0x7
     834:	078080e7          	jalr	120(ra) # 78a8 <exit>
  }

  ret = link(b, b);
     838:	fe043583          	ld	a1,-32(s0)
     83c:	fe043503          	ld	a0,-32(s0)
     840:	00007097          	auipc	ra,0x7
     844:	0c8080e7          	jalr	200(ra) # 7908 <link>
     848:	87aa                	mv	a5,a0
     84a:	fcf42e23          	sw	a5,-36(s0)
  if(ret != -1){
     84e:	fdc42783          	lw	a5,-36(s0)
     852:	0007871b          	sext.w	a4,a5
     856:	57fd                	li	a5,-1
     858:	02f70663          	beq	a4,a5,884 <copyinstr3+0x17a>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
     85c:	fdc42783          	lw	a5,-36(s0)
     860:	86be                	mv	a3,a5
     862:	fe043603          	ld	a2,-32(s0)
     866:	fe043583          	ld	a1,-32(s0)
     86a:	00008517          	auipc	a0,0x8
     86e:	a7650513          	addi	a0,a0,-1418 # 82e0 <malloc+0x2fe>
     872:	00007097          	auipc	ra,0x7
     876:	57e080e7          	jalr	1406(ra) # 7df0 <printf>
    exit(1);
     87a:	4505                	li	a0,1
     87c:	00007097          	auipc	ra,0x7
     880:	02c080e7          	jalr	44(ra) # 78a8 <exit>
  }

  char *args[] = { "xx", 0 };
     884:	00008797          	auipc	a5,0x8
     888:	a8478793          	addi	a5,a5,-1404 # 8308 <malloc+0x326>
     88c:	fcf43423          	sd	a5,-56(s0)
     890:	fc043823          	sd	zero,-48(s0)
  ret = exec(b, args);
     894:	fc840793          	addi	a5,s0,-56
     898:	85be                	mv	a1,a5
     89a:	fe043503          	ld	a0,-32(s0)
     89e:	00007097          	auipc	ra,0x7
     8a2:	042080e7          	jalr	66(ra) # 78e0 <exec>
     8a6:	87aa                	mv	a5,a0
     8a8:	fcf42e23          	sw	a5,-36(s0)
  if(ret != -1){
     8ac:	fdc42783          	lw	a5,-36(s0)
     8b0:	0007871b          	sext.w	a4,a5
     8b4:	57fd                	li	a5,-1
     8b6:	02f70463          	beq	a4,a5,8de <copyinstr3+0x1d4>
    printf("exec(%s) returned %d, not -1\n", b, fd);
     8ba:	fd842783          	lw	a5,-40(s0)
     8be:	863e                	mv	a2,a5
     8c0:	fe043583          	ld	a1,-32(s0)
     8c4:	00008517          	auipc	a0,0x8
     8c8:	a4c50513          	addi	a0,a0,-1460 # 8310 <malloc+0x32e>
     8cc:	00007097          	auipc	ra,0x7
     8d0:	524080e7          	jalr	1316(ra) # 7df0 <printf>
    exit(1);
     8d4:	4505                	li	a0,1
     8d6:	00007097          	auipc	ra,0x7
     8da:	fd2080e7          	jalr	-46(ra) # 78a8 <exit>
  }
}
     8de:	0001                	nop
     8e0:	60a6                	ld	ra,72(sp)
     8e2:	6406                	ld	s0,64(sp)
     8e4:	6161                	addi	sp,sp,80
     8e6:	8082                	ret

00000000000008e8 <rwsbrk>:

// See if the kernel refuses to read/write user memory that the
// application doesn't have anymore, because it returned it.
void
rwsbrk()
{
     8e8:	1101                	addi	sp,sp,-32
     8ea:	ec06                	sd	ra,24(sp)
     8ec:	e822                	sd	s0,16(sp)
     8ee:	1000                	addi	s0,sp,32
  int fd, n;
  
  uint64 a = (uint64) sbrk(8192);
     8f0:	6509                	lui	a0,0x2
     8f2:	00007097          	auipc	ra,0x7
     8f6:	03e080e7          	jalr	62(ra) # 7930 <sbrk>
     8fa:	87aa                	mv	a5,a0
     8fc:	fef43423          	sd	a5,-24(s0)

  if(a == 0xffffffffffffffffLL) {
     900:	fe843703          	ld	a4,-24(s0)
     904:	57fd                	li	a5,-1
     906:	00f71f63          	bne	a4,a5,924 <rwsbrk+0x3c>
    printf("sbrk(rwsbrk) failed\n");
     90a:	00008517          	auipc	a0,0x8
     90e:	abe50513          	addi	a0,a0,-1346 # 83c8 <malloc+0x3e6>
     912:	00007097          	auipc	ra,0x7
     916:	4de080e7          	jalr	1246(ra) # 7df0 <printf>
    exit(1);
     91a:	4505                	li	a0,1
     91c:	00007097          	auipc	ra,0x7
     920:	f8c080e7          	jalr	-116(ra) # 78a8 <exit>
  }
  
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
     924:	7579                	lui	a0,0xffffe
     926:	00007097          	auipc	ra,0x7
     92a:	00a080e7          	jalr	10(ra) # 7930 <sbrk>
     92e:	872a                	mv	a4,a0
     930:	57fd                	li	a5,-1
     932:	00f71f63          	bne	a4,a5,950 <rwsbrk+0x68>
    printf("sbrk(rwsbrk) shrink failed\n");
     936:	00008517          	auipc	a0,0x8
     93a:	aaa50513          	addi	a0,a0,-1366 # 83e0 <malloc+0x3fe>
     93e:	00007097          	auipc	ra,0x7
     942:	4b2080e7          	jalr	1202(ra) # 7df0 <printf>
    exit(1);
     946:	4505                	li	a0,1
     948:	00007097          	auipc	ra,0x7
     94c:	f60080e7          	jalr	-160(ra) # 78a8 <exit>
  }

  fd = open("rwsbrk", O_CREATE|O_WRONLY);
     950:	20100593          	li	a1,513
     954:	00008517          	auipc	a0,0x8
     958:	aac50513          	addi	a0,a0,-1364 # 8400 <malloc+0x41e>
     95c:	00007097          	auipc	ra,0x7
     960:	f8c080e7          	jalr	-116(ra) # 78e8 <open>
     964:	87aa                	mv	a5,a0
     966:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
     96a:	fe442783          	lw	a5,-28(s0)
     96e:	2781                	sext.w	a5,a5
     970:	0007df63          	bgez	a5,98e <rwsbrk+0xa6>
    printf("open(rwsbrk) failed\n");
     974:	00008517          	auipc	a0,0x8
     978:	a9450513          	addi	a0,a0,-1388 # 8408 <malloc+0x426>
     97c:	00007097          	auipc	ra,0x7
     980:	474080e7          	jalr	1140(ra) # 7df0 <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00007097          	auipc	ra,0x7
     98a:	f22080e7          	jalr	-222(ra) # 78a8 <exit>
  }
  n = write(fd, (void*)(a+4096), 1024);
     98e:	fe843703          	ld	a4,-24(s0)
     992:	6785                	lui	a5,0x1
     994:	97ba                	add	a5,a5,a4
     996:	873e                	mv	a4,a5
     998:	fe442783          	lw	a5,-28(s0)
     99c:	40000613          	li	a2,1024
     9a0:	85ba                	mv	a1,a4
     9a2:	853e                	mv	a0,a5
     9a4:	00007097          	auipc	ra,0x7
     9a8:	f24080e7          	jalr	-220(ra) # 78c8 <write>
     9ac:	87aa                	mv	a5,a0
     9ae:	fef42023          	sw	a5,-32(s0)
  if(n >= 0){
     9b2:	fe042783          	lw	a5,-32(s0)
     9b6:	2781                	sext.w	a5,a5
     9b8:	0207c763          	bltz	a5,9e6 <rwsbrk+0xfe>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
     9bc:	fe843703          	ld	a4,-24(s0)
     9c0:	6785                	lui	a5,0x1
     9c2:	97ba                	add	a5,a5,a4
     9c4:	fe042703          	lw	a4,-32(s0)
     9c8:	863a                	mv	a2,a4
     9ca:	85be                	mv	a1,a5
     9cc:	00008517          	auipc	a0,0x8
     9d0:	a5450513          	addi	a0,a0,-1452 # 8420 <malloc+0x43e>
     9d4:	00007097          	auipc	ra,0x7
     9d8:	41c080e7          	jalr	1052(ra) # 7df0 <printf>
    exit(1);
     9dc:	4505                	li	a0,1
     9de:	00007097          	auipc	ra,0x7
     9e2:	eca080e7          	jalr	-310(ra) # 78a8 <exit>
  }
  close(fd);
     9e6:	fe442783          	lw	a5,-28(s0)
     9ea:	853e                	mv	a0,a5
     9ec:	00007097          	auipc	ra,0x7
     9f0:	ee4080e7          	jalr	-284(ra) # 78d0 <close>
  unlink("rwsbrk");
     9f4:	00008517          	auipc	a0,0x8
     9f8:	a0c50513          	addi	a0,a0,-1524 # 8400 <malloc+0x41e>
     9fc:	00007097          	auipc	ra,0x7
     a00:	efc080e7          	jalr	-260(ra) # 78f8 <unlink>

  fd = open("README", O_RDONLY);
     a04:	4581                	li	a1,0
     a06:	00007517          	auipc	a0,0x7
     a0a:	7da50513          	addi	a0,a0,2010 # 81e0 <malloc+0x1fe>
     a0e:	00007097          	auipc	ra,0x7
     a12:	eda080e7          	jalr	-294(ra) # 78e8 <open>
     a16:	87aa                	mv	a5,a0
     a18:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
     a1c:	fe442783          	lw	a5,-28(s0)
     a20:	2781                	sext.w	a5,a5
     a22:	0007df63          	bgez	a5,a40 <rwsbrk+0x158>
    printf("open(rwsbrk) failed\n");
     a26:	00008517          	auipc	a0,0x8
     a2a:	9e250513          	addi	a0,a0,-1566 # 8408 <malloc+0x426>
     a2e:	00007097          	auipc	ra,0x7
     a32:	3c2080e7          	jalr	962(ra) # 7df0 <printf>
    exit(1);
     a36:	4505                	li	a0,1
     a38:	00007097          	auipc	ra,0x7
     a3c:	e70080e7          	jalr	-400(ra) # 78a8 <exit>
  }
  n = read(fd, (void*)(a+4096), 10);
     a40:	fe843703          	ld	a4,-24(s0)
     a44:	6785                	lui	a5,0x1
     a46:	97ba                	add	a5,a5,a4
     a48:	873e                	mv	a4,a5
     a4a:	fe442783          	lw	a5,-28(s0)
     a4e:	4629                	li	a2,10
     a50:	85ba                	mv	a1,a4
     a52:	853e                	mv	a0,a5
     a54:	00007097          	auipc	ra,0x7
     a58:	e6c080e7          	jalr	-404(ra) # 78c0 <read>
     a5c:	87aa                	mv	a5,a0
     a5e:	fef42023          	sw	a5,-32(s0)
  if(n >= 0){
     a62:	fe042783          	lw	a5,-32(s0)
     a66:	2781                	sext.w	a5,a5
     a68:	0207c763          	bltz	a5,a96 <rwsbrk+0x1ae>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
     a6c:	fe843703          	ld	a4,-24(s0)
     a70:	6785                	lui	a5,0x1
     a72:	97ba                	add	a5,a5,a4
     a74:	fe042703          	lw	a4,-32(s0)
     a78:	863a                	mv	a2,a4
     a7a:	85be                	mv	a1,a5
     a7c:	00008517          	auipc	a0,0x8
     a80:	9d450513          	addi	a0,a0,-1580 # 8450 <malloc+0x46e>
     a84:	00007097          	auipc	ra,0x7
     a88:	36c080e7          	jalr	876(ra) # 7df0 <printf>
    exit(1);
     a8c:	4505                	li	a0,1
     a8e:	00007097          	auipc	ra,0x7
     a92:	e1a080e7          	jalr	-486(ra) # 78a8 <exit>
  }
  close(fd);
     a96:	fe442783          	lw	a5,-28(s0)
     a9a:	853e                	mv	a0,a5
     a9c:	00007097          	auipc	ra,0x7
     aa0:	e34080e7          	jalr	-460(ra) # 78d0 <close>
  
  exit(0);
     aa4:	4501                	li	a0,0
     aa6:	00007097          	auipc	ra,0x7
     aaa:	e02080e7          	jalr	-510(ra) # 78a8 <exit>

0000000000000aae <truncate1>:
}

// test O_TRUNC.
void
truncate1(char *s)
{
     aae:	715d                	addi	sp,sp,-80
     ab0:	e486                	sd	ra,72(sp)
     ab2:	e0a2                	sd	s0,64(sp)
     ab4:	0880                	addi	s0,sp,80
     ab6:	faa43c23          	sd	a0,-72(s0)
  char buf[32];
  
  unlink("truncfile");
     aba:	00008517          	auipc	a0,0x8
     abe:	9be50513          	addi	a0,a0,-1602 # 8478 <malloc+0x496>
     ac2:	00007097          	auipc	ra,0x7
     ac6:	e36080e7          	jalr	-458(ra) # 78f8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     aca:	60100593          	li	a1,1537
     ace:	00008517          	auipc	a0,0x8
     ad2:	9aa50513          	addi	a0,a0,-1622 # 8478 <malloc+0x496>
     ad6:	00007097          	auipc	ra,0x7
     ada:	e12080e7          	jalr	-494(ra) # 78e8 <open>
     ade:	87aa                	mv	a5,a0
     ae0:	fef42623          	sw	a5,-20(s0)
  write(fd1, "abcd", 4);
     ae4:	fec42783          	lw	a5,-20(s0)
     ae8:	4611                	li	a2,4
     aea:	00008597          	auipc	a1,0x8
     aee:	99e58593          	addi	a1,a1,-1634 # 8488 <malloc+0x4a6>
     af2:	853e                	mv	a0,a5
     af4:	00007097          	auipc	ra,0x7
     af8:	dd4080e7          	jalr	-556(ra) # 78c8 <write>
  close(fd1);
     afc:	fec42783          	lw	a5,-20(s0)
     b00:	853e                	mv	a0,a5
     b02:	00007097          	auipc	ra,0x7
     b06:	dce080e7          	jalr	-562(ra) # 78d0 <close>

  int fd2 = open("truncfile", O_RDONLY);
     b0a:	4581                	li	a1,0
     b0c:	00008517          	auipc	a0,0x8
     b10:	96c50513          	addi	a0,a0,-1684 # 8478 <malloc+0x496>
     b14:	00007097          	auipc	ra,0x7
     b18:	dd4080e7          	jalr	-556(ra) # 78e8 <open>
     b1c:	87aa                	mv	a5,a0
     b1e:	fef42423          	sw	a5,-24(s0)
  int n = read(fd2, buf, sizeof(buf));
     b22:	fc040713          	addi	a4,s0,-64
     b26:	fe842783          	lw	a5,-24(s0)
     b2a:	02000613          	li	a2,32
     b2e:	85ba                	mv	a1,a4
     b30:	853e                	mv	a0,a5
     b32:	00007097          	auipc	ra,0x7
     b36:	d8e080e7          	jalr	-626(ra) # 78c0 <read>
     b3a:	87aa                	mv	a5,a0
     b3c:	fef42223          	sw	a5,-28(s0)
  if(n != 4){
     b40:	fe442783          	lw	a5,-28(s0)
     b44:	0007871b          	sext.w	a4,a5
     b48:	4791                	li	a5,4
     b4a:	02f70463          	beq	a4,a5,b72 <truncate1+0xc4>
    printf("%s: read %d bytes, wanted 4\n", s, n);
     b4e:	fe442783          	lw	a5,-28(s0)
     b52:	863e                	mv	a2,a5
     b54:	fb843583          	ld	a1,-72(s0)
     b58:	00008517          	auipc	a0,0x8
     b5c:	93850513          	addi	a0,a0,-1736 # 8490 <malloc+0x4ae>
     b60:	00007097          	auipc	ra,0x7
     b64:	290080e7          	jalr	656(ra) # 7df0 <printf>
    exit(1);
     b68:	4505                	li	a0,1
     b6a:	00007097          	auipc	ra,0x7
     b6e:	d3e080e7          	jalr	-706(ra) # 78a8 <exit>
  }

  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     b72:	40100593          	li	a1,1025
     b76:	00008517          	auipc	a0,0x8
     b7a:	90250513          	addi	a0,a0,-1790 # 8478 <malloc+0x496>
     b7e:	00007097          	auipc	ra,0x7
     b82:	d6a080e7          	jalr	-662(ra) # 78e8 <open>
     b86:	87aa                	mv	a5,a0
     b88:	fef42623          	sw	a5,-20(s0)

  int fd3 = open("truncfile", O_RDONLY);
     b8c:	4581                	li	a1,0
     b8e:	00008517          	auipc	a0,0x8
     b92:	8ea50513          	addi	a0,a0,-1814 # 8478 <malloc+0x496>
     b96:	00007097          	auipc	ra,0x7
     b9a:	d52080e7          	jalr	-686(ra) # 78e8 <open>
     b9e:	87aa                	mv	a5,a0
     ba0:	fef42023          	sw	a5,-32(s0)
  n = read(fd3, buf, sizeof(buf));
     ba4:	fc040713          	addi	a4,s0,-64
     ba8:	fe042783          	lw	a5,-32(s0)
     bac:	02000613          	li	a2,32
     bb0:	85ba                	mv	a1,a4
     bb2:	853e                	mv	a0,a5
     bb4:	00007097          	auipc	ra,0x7
     bb8:	d0c080e7          	jalr	-756(ra) # 78c0 <read>
     bbc:	87aa                	mv	a5,a0
     bbe:	fef42223          	sw	a5,-28(s0)
  if(n != 0){
     bc2:	fe442783          	lw	a5,-28(s0)
     bc6:	2781                	sext.w	a5,a5
     bc8:	cf95                	beqz	a5,c04 <truncate1+0x156>
    printf("aaa fd3=%d\n", fd3);
     bca:	fe042783          	lw	a5,-32(s0)
     bce:	85be                	mv	a1,a5
     bd0:	00008517          	auipc	a0,0x8
     bd4:	8e050513          	addi	a0,a0,-1824 # 84b0 <malloc+0x4ce>
     bd8:	00007097          	auipc	ra,0x7
     bdc:	218080e7          	jalr	536(ra) # 7df0 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     be0:	fe442783          	lw	a5,-28(s0)
     be4:	863e                	mv	a2,a5
     be6:	fb843583          	ld	a1,-72(s0)
     bea:	00008517          	auipc	a0,0x8
     bee:	8d650513          	addi	a0,a0,-1834 # 84c0 <malloc+0x4de>
     bf2:	00007097          	auipc	ra,0x7
     bf6:	1fe080e7          	jalr	510(ra) # 7df0 <printf>
    exit(1);
     bfa:	4505                	li	a0,1
     bfc:	00007097          	auipc	ra,0x7
     c00:	cac080e7          	jalr	-852(ra) # 78a8 <exit>
  }

  n = read(fd2, buf, sizeof(buf));
     c04:	fc040713          	addi	a4,s0,-64
     c08:	fe842783          	lw	a5,-24(s0)
     c0c:	02000613          	li	a2,32
     c10:	85ba                	mv	a1,a4
     c12:	853e                	mv	a0,a5
     c14:	00007097          	auipc	ra,0x7
     c18:	cac080e7          	jalr	-852(ra) # 78c0 <read>
     c1c:	87aa                	mv	a5,a0
     c1e:	fef42223          	sw	a5,-28(s0)
  if(n != 0){
     c22:	fe442783          	lw	a5,-28(s0)
     c26:	2781                	sext.w	a5,a5
     c28:	cf95                	beqz	a5,c64 <truncate1+0x1b6>
    printf("bbb fd2=%d\n", fd2);
     c2a:	fe842783          	lw	a5,-24(s0)
     c2e:	85be                	mv	a1,a5
     c30:	00008517          	auipc	a0,0x8
     c34:	8b050513          	addi	a0,a0,-1872 # 84e0 <malloc+0x4fe>
     c38:	00007097          	auipc	ra,0x7
     c3c:	1b8080e7          	jalr	440(ra) # 7df0 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     c40:	fe442783          	lw	a5,-28(s0)
     c44:	863e                	mv	a2,a5
     c46:	fb843583          	ld	a1,-72(s0)
     c4a:	00008517          	auipc	a0,0x8
     c4e:	87650513          	addi	a0,a0,-1930 # 84c0 <malloc+0x4de>
     c52:	00007097          	auipc	ra,0x7
     c56:	19e080e7          	jalr	414(ra) # 7df0 <printf>
    exit(1);
     c5a:	4505                	li	a0,1
     c5c:	00007097          	auipc	ra,0x7
     c60:	c4c080e7          	jalr	-948(ra) # 78a8 <exit>
  }
  
  write(fd1, "abcdef", 6);
     c64:	fec42783          	lw	a5,-20(s0)
     c68:	4619                	li	a2,6
     c6a:	00008597          	auipc	a1,0x8
     c6e:	88658593          	addi	a1,a1,-1914 # 84f0 <malloc+0x50e>
     c72:	853e                	mv	a0,a5
     c74:	00007097          	auipc	ra,0x7
     c78:	c54080e7          	jalr	-940(ra) # 78c8 <write>

  n = read(fd3, buf, sizeof(buf));
     c7c:	fc040713          	addi	a4,s0,-64
     c80:	fe042783          	lw	a5,-32(s0)
     c84:	02000613          	li	a2,32
     c88:	85ba                	mv	a1,a4
     c8a:	853e                	mv	a0,a5
     c8c:	00007097          	auipc	ra,0x7
     c90:	c34080e7          	jalr	-972(ra) # 78c0 <read>
     c94:	87aa                	mv	a5,a0
     c96:	fef42223          	sw	a5,-28(s0)
  if(n != 6){
     c9a:	fe442783          	lw	a5,-28(s0)
     c9e:	0007871b          	sext.w	a4,a5
     ca2:	4799                	li	a5,6
     ca4:	02f70463          	beq	a4,a5,ccc <truncate1+0x21e>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     ca8:	fe442783          	lw	a5,-28(s0)
     cac:	863e                	mv	a2,a5
     cae:	fb843583          	ld	a1,-72(s0)
     cb2:	00008517          	auipc	a0,0x8
     cb6:	84650513          	addi	a0,a0,-1978 # 84f8 <malloc+0x516>
     cba:	00007097          	auipc	ra,0x7
     cbe:	136080e7          	jalr	310(ra) # 7df0 <printf>
    exit(1);
     cc2:	4505                	li	a0,1
     cc4:	00007097          	auipc	ra,0x7
     cc8:	be4080e7          	jalr	-1052(ra) # 78a8 <exit>
  }

  n = read(fd2, buf, sizeof(buf));
     ccc:	fc040713          	addi	a4,s0,-64
     cd0:	fe842783          	lw	a5,-24(s0)
     cd4:	02000613          	li	a2,32
     cd8:	85ba                	mv	a1,a4
     cda:	853e                	mv	a0,a5
     cdc:	00007097          	auipc	ra,0x7
     ce0:	be4080e7          	jalr	-1052(ra) # 78c0 <read>
     ce4:	87aa                	mv	a5,a0
     ce6:	fef42223          	sw	a5,-28(s0)
  if(n != 2){
     cea:	fe442783          	lw	a5,-28(s0)
     cee:	0007871b          	sext.w	a4,a5
     cf2:	4789                	li	a5,2
     cf4:	02f70463          	beq	a4,a5,d1c <truncate1+0x26e>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     cf8:	fe442783          	lw	a5,-28(s0)
     cfc:	863e                	mv	a2,a5
     cfe:	fb843583          	ld	a1,-72(s0)
     d02:	00008517          	auipc	a0,0x8
     d06:	81650513          	addi	a0,a0,-2026 # 8518 <malloc+0x536>
     d0a:	00007097          	auipc	ra,0x7
     d0e:	0e6080e7          	jalr	230(ra) # 7df0 <printf>
    exit(1);
     d12:	4505                	li	a0,1
     d14:	00007097          	auipc	ra,0x7
     d18:	b94080e7          	jalr	-1132(ra) # 78a8 <exit>
  }

  unlink("truncfile");
     d1c:	00007517          	auipc	a0,0x7
     d20:	75c50513          	addi	a0,a0,1884 # 8478 <malloc+0x496>
     d24:	00007097          	auipc	ra,0x7
     d28:	bd4080e7          	jalr	-1068(ra) # 78f8 <unlink>

  close(fd1);
     d2c:	fec42783          	lw	a5,-20(s0)
     d30:	853e                	mv	a0,a5
     d32:	00007097          	auipc	ra,0x7
     d36:	b9e080e7          	jalr	-1122(ra) # 78d0 <close>
  close(fd2);
     d3a:	fe842783          	lw	a5,-24(s0)
     d3e:	853e                	mv	a0,a5
     d40:	00007097          	auipc	ra,0x7
     d44:	b90080e7          	jalr	-1136(ra) # 78d0 <close>
  close(fd3);
     d48:	fe042783          	lw	a5,-32(s0)
     d4c:	853e                	mv	a0,a5
     d4e:	00007097          	auipc	ra,0x7
     d52:	b82080e7          	jalr	-1150(ra) # 78d0 <close>
}
     d56:	0001                	nop
     d58:	60a6                	ld	ra,72(sp)
     d5a:	6406                	ld	s0,64(sp)
     d5c:	6161                	addi	sp,sp,80
     d5e:	8082                	ret

0000000000000d60 <truncate2>:
// this causes a write at an offset beyond the end of the file.
// such writes fail on xv6 (unlike POSIX) but at least
// they don't crash.
void
truncate2(char *s)
{
     d60:	7179                	addi	sp,sp,-48
     d62:	f406                	sd	ra,40(sp)
     d64:	f022                	sd	s0,32(sp)
     d66:	1800                	addi	s0,sp,48
     d68:	fca43c23          	sd	a0,-40(s0)
  unlink("truncfile");
     d6c:	00007517          	auipc	a0,0x7
     d70:	70c50513          	addi	a0,a0,1804 # 8478 <malloc+0x496>
     d74:	00007097          	auipc	ra,0x7
     d78:	b84080e7          	jalr	-1148(ra) # 78f8 <unlink>

  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     d7c:	60100593          	li	a1,1537
     d80:	00007517          	auipc	a0,0x7
     d84:	6f850513          	addi	a0,a0,1784 # 8478 <malloc+0x496>
     d88:	00007097          	auipc	ra,0x7
     d8c:	b60080e7          	jalr	-1184(ra) # 78e8 <open>
     d90:	87aa                	mv	a5,a0
     d92:	fef42623          	sw	a5,-20(s0)
  write(fd1, "abcd", 4);
     d96:	fec42783          	lw	a5,-20(s0)
     d9a:	4611                	li	a2,4
     d9c:	00007597          	auipc	a1,0x7
     da0:	6ec58593          	addi	a1,a1,1772 # 8488 <malloc+0x4a6>
     da4:	853e                	mv	a0,a5
     da6:	00007097          	auipc	ra,0x7
     daa:	b22080e7          	jalr	-1246(ra) # 78c8 <write>

  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     dae:	40100593          	li	a1,1025
     db2:	00007517          	auipc	a0,0x7
     db6:	6c650513          	addi	a0,a0,1734 # 8478 <malloc+0x496>
     dba:	00007097          	auipc	ra,0x7
     dbe:	b2e080e7          	jalr	-1234(ra) # 78e8 <open>
     dc2:	87aa                	mv	a5,a0
     dc4:	fef42423          	sw	a5,-24(s0)

  int n = write(fd1, "x", 1);
     dc8:	fec42783          	lw	a5,-20(s0)
     dcc:	4605                	li	a2,1
     dce:	00007597          	auipc	a1,0x7
     dd2:	46258593          	addi	a1,a1,1122 # 8230 <malloc+0x24e>
     dd6:	853e                	mv	a0,a5
     dd8:	00007097          	auipc	ra,0x7
     ddc:	af0080e7          	jalr	-1296(ra) # 78c8 <write>
     de0:	87aa                	mv	a5,a0
     de2:	fef42223          	sw	a5,-28(s0)
  if(n != -1){
     de6:	fe442783          	lw	a5,-28(s0)
     dea:	0007871b          	sext.w	a4,a5
     dee:	57fd                	li	a5,-1
     df0:	02f70463          	beq	a4,a5,e18 <truncate2+0xb8>
    printf("%s: write returned %d, expected -1\n", s, n);
     df4:	fe442783          	lw	a5,-28(s0)
     df8:	863e                	mv	a2,a5
     dfa:	fd843583          	ld	a1,-40(s0)
     dfe:	00007517          	auipc	a0,0x7
     e02:	73a50513          	addi	a0,a0,1850 # 8538 <malloc+0x556>
     e06:	00007097          	auipc	ra,0x7
     e0a:	fea080e7          	jalr	-22(ra) # 7df0 <printf>
    exit(1);
     e0e:	4505                	li	a0,1
     e10:	00007097          	auipc	ra,0x7
     e14:	a98080e7          	jalr	-1384(ra) # 78a8 <exit>
  }

  unlink("truncfile");
     e18:	00007517          	auipc	a0,0x7
     e1c:	66050513          	addi	a0,a0,1632 # 8478 <malloc+0x496>
     e20:	00007097          	auipc	ra,0x7
     e24:	ad8080e7          	jalr	-1320(ra) # 78f8 <unlink>
  close(fd1);
     e28:	fec42783          	lw	a5,-20(s0)
     e2c:	853e                	mv	a0,a5
     e2e:	00007097          	auipc	ra,0x7
     e32:	aa2080e7          	jalr	-1374(ra) # 78d0 <close>
  close(fd2);
     e36:	fe842783          	lw	a5,-24(s0)
     e3a:	853e                	mv	a0,a5
     e3c:	00007097          	auipc	ra,0x7
     e40:	a94080e7          	jalr	-1388(ra) # 78d0 <close>
}
     e44:	0001                	nop
     e46:	70a2                	ld	ra,40(sp)
     e48:	7402                	ld	s0,32(sp)
     e4a:	6145                	addi	sp,sp,48
     e4c:	8082                	ret

0000000000000e4e <truncate3>:

void
truncate3(char *s)
{
     e4e:	711d                	addi	sp,sp,-96
     e50:	ec86                	sd	ra,88(sp)
     e52:	e8a2                	sd	s0,80(sp)
     e54:	1080                	addi	s0,sp,96
     e56:	faa43423          	sd	a0,-88(s0)
  int pid, xstatus;

  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
     e5a:	60100593          	li	a1,1537
     e5e:	00007517          	auipc	a0,0x7
     e62:	61a50513          	addi	a0,a0,1562 # 8478 <malloc+0x496>
     e66:	00007097          	auipc	ra,0x7
     e6a:	a82080e7          	jalr	-1406(ra) # 78e8 <open>
     e6e:	87aa                	mv	a5,a0
     e70:	853e                	mv	a0,a5
     e72:	00007097          	auipc	ra,0x7
     e76:	a5e080e7          	jalr	-1442(ra) # 78d0 <close>
  
  pid = fork();
     e7a:	00007097          	auipc	ra,0x7
     e7e:	a26080e7          	jalr	-1498(ra) # 78a0 <fork>
     e82:	87aa                	mv	a5,a0
     e84:	fef42223          	sw	a5,-28(s0)
  if(pid < 0){
     e88:	fe442783          	lw	a5,-28(s0)
     e8c:	2781                	sext.w	a5,a5
     e8e:	0207d163          	bgez	a5,eb0 <truncate3+0x62>
    printf("%s: fork failed\n", s);
     e92:	fa843583          	ld	a1,-88(s0)
     e96:	00007517          	auipc	a0,0x7
     e9a:	6ca50513          	addi	a0,a0,1738 # 8560 <malloc+0x57e>
     e9e:	00007097          	auipc	ra,0x7
     ea2:	f52080e7          	jalr	-174(ra) # 7df0 <printf>
    exit(1);
     ea6:	4505                	li	a0,1
     ea8:	00007097          	auipc	ra,0x7
     eac:	a00080e7          	jalr	-1536(ra) # 78a8 <exit>
  }

  if(pid == 0){
     eb0:	fe442783          	lw	a5,-28(s0)
     eb4:	2781                	sext.w	a5,a5
     eb6:	10079563          	bnez	a5,fc0 <truncate3+0x172>
    for(int i = 0; i < 100; i++){
     eba:	fe042623          	sw	zero,-20(s0)
     ebe:	a0e5                	j	fa6 <truncate3+0x158>
      char buf[32];
      int fd = open("truncfile", O_WRONLY);
     ec0:	4585                	li	a1,1
     ec2:	00007517          	auipc	a0,0x7
     ec6:	5b650513          	addi	a0,a0,1462 # 8478 <malloc+0x496>
     eca:	00007097          	auipc	ra,0x7
     ece:	a1e080e7          	jalr	-1506(ra) # 78e8 <open>
     ed2:	87aa                	mv	a5,a0
     ed4:	fcf42c23          	sw	a5,-40(s0)
      if(fd < 0){
     ed8:	fd842783          	lw	a5,-40(s0)
     edc:	2781                	sext.w	a5,a5
     ede:	0207d163          	bgez	a5,f00 <truncate3+0xb2>
        printf("%s: open failed\n", s);
     ee2:	fa843583          	ld	a1,-88(s0)
     ee6:	00007517          	auipc	a0,0x7
     eea:	69250513          	addi	a0,a0,1682 # 8578 <malloc+0x596>
     eee:	00007097          	auipc	ra,0x7
     ef2:	f02080e7          	jalr	-254(ra) # 7df0 <printf>
        exit(1);
     ef6:	4505                	li	a0,1
     ef8:	00007097          	auipc	ra,0x7
     efc:	9b0080e7          	jalr	-1616(ra) # 78a8 <exit>
      }
      int n = write(fd, "1234567890", 10);
     f00:	fd842783          	lw	a5,-40(s0)
     f04:	4629                	li	a2,10
     f06:	00007597          	auipc	a1,0x7
     f0a:	68a58593          	addi	a1,a1,1674 # 8590 <malloc+0x5ae>
     f0e:	853e                	mv	a0,a5
     f10:	00007097          	auipc	ra,0x7
     f14:	9b8080e7          	jalr	-1608(ra) # 78c8 <write>
     f18:	87aa                	mv	a5,a0
     f1a:	fcf42a23          	sw	a5,-44(s0)
      if(n != 10){
     f1e:	fd442783          	lw	a5,-44(s0)
     f22:	0007871b          	sext.w	a4,a5
     f26:	47a9                	li	a5,10
     f28:	02f70463          	beq	a4,a5,f50 <truncate3+0x102>
        printf("%s: write got %d, expected 10\n", s, n);
     f2c:	fd442783          	lw	a5,-44(s0)
     f30:	863e                	mv	a2,a5
     f32:	fa843583          	ld	a1,-88(s0)
     f36:	00007517          	auipc	a0,0x7
     f3a:	66a50513          	addi	a0,a0,1642 # 85a0 <malloc+0x5be>
     f3e:	00007097          	auipc	ra,0x7
     f42:	eb2080e7          	jalr	-334(ra) # 7df0 <printf>
        exit(1);
     f46:	4505                	li	a0,1
     f48:	00007097          	auipc	ra,0x7
     f4c:	960080e7          	jalr	-1696(ra) # 78a8 <exit>
      }
      close(fd);
     f50:	fd842783          	lw	a5,-40(s0)
     f54:	853e                	mv	a0,a5
     f56:	00007097          	auipc	ra,0x7
     f5a:	97a080e7          	jalr	-1670(ra) # 78d0 <close>
      fd = open("truncfile", O_RDONLY);
     f5e:	4581                	li	a1,0
     f60:	00007517          	auipc	a0,0x7
     f64:	51850513          	addi	a0,a0,1304 # 8478 <malloc+0x496>
     f68:	00007097          	auipc	ra,0x7
     f6c:	980080e7          	jalr	-1664(ra) # 78e8 <open>
     f70:	87aa                	mv	a5,a0
     f72:	fcf42c23          	sw	a5,-40(s0)
      read(fd, buf, sizeof(buf));
     f76:	fb040713          	addi	a4,s0,-80
     f7a:	fd842783          	lw	a5,-40(s0)
     f7e:	02000613          	li	a2,32
     f82:	85ba                	mv	a1,a4
     f84:	853e                	mv	a0,a5
     f86:	00007097          	auipc	ra,0x7
     f8a:	93a080e7          	jalr	-1734(ra) # 78c0 <read>
      close(fd);
     f8e:	fd842783          	lw	a5,-40(s0)
     f92:	853e                	mv	a0,a5
     f94:	00007097          	auipc	ra,0x7
     f98:	93c080e7          	jalr	-1732(ra) # 78d0 <close>
    for(int i = 0; i < 100; i++){
     f9c:	fec42783          	lw	a5,-20(s0)
     fa0:	2785                	addiw	a5,a5,1 # 1001 <truncate3+0x1b3>
     fa2:	fef42623          	sw	a5,-20(s0)
     fa6:	fec42783          	lw	a5,-20(s0)
     faa:	0007871b          	sext.w	a4,a5
     fae:	06300793          	li	a5,99
     fb2:	f0e7d7e3          	bge	a5,a4,ec0 <truncate3+0x72>
    }
    exit(0);
     fb6:	4501                	li	a0,0
     fb8:	00007097          	auipc	ra,0x7
     fbc:	8f0080e7          	jalr	-1808(ra) # 78a8 <exit>
  }

  for(int i = 0; i < 150; i++){
     fc0:	fe042423          	sw	zero,-24(s0)
     fc4:	a075                	j	1070 <truncate3+0x222>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     fc6:	60100593          	li	a1,1537
     fca:	00007517          	auipc	a0,0x7
     fce:	4ae50513          	addi	a0,a0,1198 # 8478 <malloc+0x496>
     fd2:	00007097          	auipc	ra,0x7
     fd6:	916080e7          	jalr	-1770(ra) # 78e8 <open>
     fda:	87aa                	mv	a5,a0
     fdc:	fef42023          	sw	a5,-32(s0)
    if(fd < 0){
     fe0:	fe042783          	lw	a5,-32(s0)
     fe4:	2781                	sext.w	a5,a5
     fe6:	0207d163          	bgez	a5,1008 <truncate3+0x1ba>
      printf("%s: open failed\n", s);
     fea:	fa843583          	ld	a1,-88(s0)
     fee:	00007517          	auipc	a0,0x7
     ff2:	58a50513          	addi	a0,a0,1418 # 8578 <malloc+0x596>
     ff6:	00007097          	auipc	ra,0x7
     ffa:	dfa080e7          	jalr	-518(ra) # 7df0 <printf>
      exit(1);
     ffe:	4505                	li	a0,1
    1000:	00007097          	auipc	ra,0x7
    1004:	8a8080e7          	jalr	-1880(ra) # 78a8 <exit>
    }
    int n = write(fd, "xxx", 3);
    1008:	fe042783          	lw	a5,-32(s0)
    100c:	460d                	li	a2,3
    100e:	00007597          	auipc	a1,0x7
    1012:	5b258593          	addi	a1,a1,1458 # 85c0 <malloc+0x5de>
    1016:	853e                	mv	a0,a5
    1018:	00007097          	auipc	ra,0x7
    101c:	8b0080e7          	jalr	-1872(ra) # 78c8 <write>
    1020:	87aa                	mv	a5,a0
    1022:	fcf42e23          	sw	a5,-36(s0)
    if(n != 3){
    1026:	fdc42783          	lw	a5,-36(s0)
    102a:	0007871b          	sext.w	a4,a5
    102e:	478d                	li	a5,3
    1030:	02f70463          	beq	a4,a5,1058 <truncate3+0x20a>
      printf("%s: write got %d, expected 3\n", s, n);
    1034:	fdc42783          	lw	a5,-36(s0)
    1038:	863e                	mv	a2,a5
    103a:	fa843583          	ld	a1,-88(s0)
    103e:	00007517          	auipc	a0,0x7
    1042:	58a50513          	addi	a0,a0,1418 # 85c8 <malloc+0x5e6>
    1046:	00007097          	auipc	ra,0x7
    104a:	daa080e7          	jalr	-598(ra) # 7df0 <printf>
      exit(1);
    104e:	4505                	li	a0,1
    1050:	00007097          	auipc	ra,0x7
    1054:	858080e7          	jalr	-1960(ra) # 78a8 <exit>
    }
    close(fd);
    1058:	fe042783          	lw	a5,-32(s0)
    105c:	853e                	mv	a0,a5
    105e:	00007097          	auipc	ra,0x7
    1062:	872080e7          	jalr	-1934(ra) # 78d0 <close>
  for(int i = 0; i < 150; i++){
    1066:	fe842783          	lw	a5,-24(s0)
    106a:	2785                	addiw	a5,a5,1
    106c:	fef42423          	sw	a5,-24(s0)
    1070:	fe842783          	lw	a5,-24(s0)
    1074:	0007871b          	sext.w	a4,a5
    1078:	09500793          	li	a5,149
    107c:	f4e7d5e3          	bge	a5,a4,fc6 <truncate3+0x178>
  }

  wait(&xstatus);
    1080:	fd040793          	addi	a5,s0,-48
    1084:	853e                	mv	a0,a5
    1086:	00007097          	auipc	ra,0x7
    108a:	82a080e7          	jalr	-2006(ra) # 78b0 <wait>
  unlink("truncfile");
    108e:	00007517          	auipc	a0,0x7
    1092:	3ea50513          	addi	a0,a0,1002 # 8478 <malloc+0x496>
    1096:	00007097          	auipc	ra,0x7
    109a:	862080e7          	jalr	-1950(ra) # 78f8 <unlink>
  exit(xstatus);
    109e:	fd042783          	lw	a5,-48(s0)
    10a2:	853e                	mv	a0,a5
    10a4:	00007097          	auipc	ra,0x7
    10a8:	804080e7          	jalr	-2044(ra) # 78a8 <exit>

00000000000010ac <iputtest>:
  

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(char *s)
{
    10ac:	1101                	addi	sp,sp,-32
    10ae:	ec06                	sd	ra,24(sp)
    10b0:	e822                	sd	s0,16(sp)
    10b2:	1000                	addi	s0,sp,32
    10b4:	fea43423          	sd	a0,-24(s0)
  if(mkdir("iputdir") < 0){
    10b8:	00007517          	auipc	a0,0x7
    10bc:	53050513          	addi	a0,a0,1328 # 85e8 <malloc+0x606>
    10c0:	00007097          	auipc	ra,0x7
    10c4:	850080e7          	jalr	-1968(ra) # 7910 <mkdir>
    10c8:	87aa                	mv	a5,a0
    10ca:	0207d163          	bgez	a5,10ec <iputtest+0x40>
    printf("%s: mkdir failed\n", s);
    10ce:	fe843583          	ld	a1,-24(s0)
    10d2:	00007517          	auipc	a0,0x7
    10d6:	51e50513          	addi	a0,a0,1310 # 85f0 <malloc+0x60e>
    10da:	00007097          	auipc	ra,0x7
    10de:	d16080e7          	jalr	-746(ra) # 7df0 <printf>
    exit(1);
    10e2:	4505                	li	a0,1
    10e4:	00006097          	auipc	ra,0x6
    10e8:	7c4080e7          	jalr	1988(ra) # 78a8 <exit>
  }
  if(chdir("iputdir") < 0){
    10ec:	00007517          	auipc	a0,0x7
    10f0:	4fc50513          	addi	a0,a0,1276 # 85e8 <malloc+0x606>
    10f4:	00007097          	auipc	ra,0x7
    10f8:	824080e7          	jalr	-2012(ra) # 7918 <chdir>
    10fc:	87aa                	mv	a5,a0
    10fe:	0207d163          	bgez	a5,1120 <iputtest+0x74>
    printf("%s: chdir iputdir failed\n", s);
    1102:	fe843583          	ld	a1,-24(s0)
    1106:	00007517          	auipc	a0,0x7
    110a:	50250513          	addi	a0,a0,1282 # 8608 <malloc+0x626>
    110e:	00007097          	auipc	ra,0x7
    1112:	ce2080e7          	jalr	-798(ra) # 7df0 <printf>
    exit(1);
    1116:	4505                	li	a0,1
    1118:	00006097          	auipc	ra,0x6
    111c:	790080e7          	jalr	1936(ra) # 78a8 <exit>
  }
  if(unlink("../iputdir") < 0){
    1120:	00007517          	auipc	a0,0x7
    1124:	50850513          	addi	a0,a0,1288 # 8628 <malloc+0x646>
    1128:	00006097          	auipc	ra,0x6
    112c:	7d0080e7          	jalr	2000(ra) # 78f8 <unlink>
    1130:	87aa                	mv	a5,a0
    1132:	0207d163          	bgez	a5,1154 <iputtest+0xa8>
    printf("%s: unlink ../iputdir failed\n", s);
    1136:	fe843583          	ld	a1,-24(s0)
    113a:	00007517          	auipc	a0,0x7
    113e:	4fe50513          	addi	a0,a0,1278 # 8638 <malloc+0x656>
    1142:	00007097          	auipc	ra,0x7
    1146:	cae080e7          	jalr	-850(ra) # 7df0 <printf>
    exit(1);
    114a:	4505                	li	a0,1
    114c:	00006097          	auipc	ra,0x6
    1150:	75c080e7          	jalr	1884(ra) # 78a8 <exit>
  }
  if(chdir("/") < 0){
    1154:	00007517          	auipc	a0,0x7
    1158:	50450513          	addi	a0,a0,1284 # 8658 <malloc+0x676>
    115c:	00006097          	auipc	ra,0x6
    1160:	7bc080e7          	jalr	1980(ra) # 7918 <chdir>
    1164:	87aa                	mv	a5,a0
    1166:	0207d163          	bgez	a5,1188 <iputtest+0xdc>
    printf("%s: chdir / failed\n", s);
    116a:	fe843583          	ld	a1,-24(s0)
    116e:	00007517          	auipc	a0,0x7
    1172:	4f250513          	addi	a0,a0,1266 # 8660 <malloc+0x67e>
    1176:	00007097          	auipc	ra,0x7
    117a:	c7a080e7          	jalr	-902(ra) # 7df0 <printf>
    exit(1);
    117e:	4505                	li	a0,1
    1180:	00006097          	auipc	ra,0x6
    1184:	728080e7          	jalr	1832(ra) # 78a8 <exit>
  }
}
    1188:	0001                	nop
    118a:	60e2                	ld	ra,24(sp)
    118c:	6442                	ld	s0,16(sp)
    118e:	6105                	addi	sp,sp,32
    1190:	8082                	ret

0000000000001192 <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(char *s)
{
    1192:	7179                	addi	sp,sp,-48
    1194:	f406                	sd	ra,40(sp)
    1196:	f022                	sd	s0,32(sp)
    1198:	1800                	addi	s0,sp,48
    119a:	fca43c23          	sd	a0,-40(s0)
  int pid, xstatus;

  pid = fork();
    119e:	00006097          	auipc	ra,0x6
    11a2:	702080e7          	jalr	1794(ra) # 78a0 <fork>
    11a6:	87aa                	mv	a5,a0
    11a8:	fef42623          	sw	a5,-20(s0)
  if(pid < 0){
    11ac:	fec42783          	lw	a5,-20(s0)
    11b0:	2781                	sext.w	a5,a5
    11b2:	0207d163          	bgez	a5,11d4 <exitiputtest+0x42>
    printf("%s: fork failed\n", s);
    11b6:	fd843583          	ld	a1,-40(s0)
    11ba:	00007517          	auipc	a0,0x7
    11be:	3a650513          	addi	a0,a0,934 # 8560 <malloc+0x57e>
    11c2:	00007097          	auipc	ra,0x7
    11c6:	c2e080e7          	jalr	-978(ra) # 7df0 <printf>
    exit(1);
    11ca:	4505                	li	a0,1
    11cc:	00006097          	auipc	ra,0x6
    11d0:	6dc080e7          	jalr	1756(ra) # 78a8 <exit>
  }
  if(pid == 0){
    11d4:	fec42783          	lw	a5,-20(s0)
    11d8:	2781                	sext.w	a5,a5
    11da:	e7c5                	bnez	a5,1282 <exitiputtest+0xf0>
    if(mkdir("iputdir") < 0){
    11dc:	00007517          	auipc	a0,0x7
    11e0:	40c50513          	addi	a0,a0,1036 # 85e8 <malloc+0x606>
    11e4:	00006097          	auipc	ra,0x6
    11e8:	72c080e7          	jalr	1836(ra) # 7910 <mkdir>
    11ec:	87aa                	mv	a5,a0
    11ee:	0207d163          	bgez	a5,1210 <exitiputtest+0x7e>
      printf("%s: mkdir failed\n", s);
    11f2:	fd843583          	ld	a1,-40(s0)
    11f6:	00007517          	auipc	a0,0x7
    11fa:	3fa50513          	addi	a0,a0,1018 # 85f0 <malloc+0x60e>
    11fe:	00007097          	auipc	ra,0x7
    1202:	bf2080e7          	jalr	-1038(ra) # 7df0 <printf>
      exit(1);
    1206:	4505                	li	a0,1
    1208:	00006097          	auipc	ra,0x6
    120c:	6a0080e7          	jalr	1696(ra) # 78a8 <exit>
    }
    if(chdir("iputdir") < 0){
    1210:	00007517          	auipc	a0,0x7
    1214:	3d850513          	addi	a0,a0,984 # 85e8 <malloc+0x606>
    1218:	00006097          	auipc	ra,0x6
    121c:	700080e7          	jalr	1792(ra) # 7918 <chdir>
    1220:	87aa                	mv	a5,a0
    1222:	0207d163          	bgez	a5,1244 <exitiputtest+0xb2>
      printf("%s: child chdir failed\n", s);
    1226:	fd843583          	ld	a1,-40(s0)
    122a:	00007517          	auipc	a0,0x7
    122e:	44e50513          	addi	a0,a0,1102 # 8678 <malloc+0x696>
    1232:	00007097          	auipc	ra,0x7
    1236:	bbe080e7          	jalr	-1090(ra) # 7df0 <printf>
      exit(1);
    123a:	4505                	li	a0,1
    123c:	00006097          	auipc	ra,0x6
    1240:	66c080e7          	jalr	1644(ra) # 78a8 <exit>
    }
    if(unlink("../iputdir") < 0){
    1244:	00007517          	auipc	a0,0x7
    1248:	3e450513          	addi	a0,a0,996 # 8628 <malloc+0x646>
    124c:	00006097          	auipc	ra,0x6
    1250:	6ac080e7          	jalr	1708(ra) # 78f8 <unlink>
    1254:	87aa                	mv	a5,a0
    1256:	0207d163          	bgez	a5,1278 <exitiputtest+0xe6>
      printf("%s: unlink ../iputdir failed\n", s);
    125a:	fd843583          	ld	a1,-40(s0)
    125e:	00007517          	auipc	a0,0x7
    1262:	3da50513          	addi	a0,a0,986 # 8638 <malloc+0x656>
    1266:	00007097          	auipc	ra,0x7
    126a:	b8a080e7          	jalr	-1142(ra) # 7df0 <printf>
      exit(1);
    126e:	4505                	li	a0,1
    1270:	00006097          	auipc	ra,0x6
    1274:	638080e7          	jalr	1592(ra) # 78a8 <exit>
    }
    exit(0);
    1278:	4501                	li	a0,0
    127a:	00006097          	auipc	ra,0x6
    127e:	62e080e7          	jalr	1582(ra) # 78a8 <exit>
  }
  wait(&xstatus);
    1282:	fe840793          	addi	a5,s0,-24
    1286:	853e                	mv	a0,a5
    1288:	00006097          	auipc	ra,0x6
    128c:	628080e7          	jalr	1576(ra) # 78b0 <wait>
  exit(xstatus);
    1290:	fe842783          	lw	a5,-24(s0)
    1294:	853e                	mv	a0,a5
    1296:	00006097          	auipc	ra,0x6
    129a:	612080e7          	jalr	1554(ra) # 78a8 <exit>

000000000000129e <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(char *s)
{
    129e:	7179                	addi	sp,sp,-48
    12a0:	f406                	sd	ra,40(sp)
    12a2:	f022                	sd	s0,32(sp)
    12a4:	1800                	addi	s0,sp,48
    12a6:	fca43c23          	sd	a0,-40(s0)
  int pid, xstatus;

  if(mkdir("oidir") < 0){
    12aa:	00007517          	auipc	a0,0x7
    12ae:	3e650513          	addi	a0,a0,998 # 8690 <malloc+0x6ae>
    12b2:	00006097          	auipc	ra,0x6
    12b6:	65e080e7          	jalr	1630(ra) # 7910 <mkdir>
    12ba:	87aa                	mv	a5,a0
    12bc:	0207d163          	bgez	a5,12de <openiputtest+0x40>
    printf("%s: mkdir oidir failed\n", s);
    12c0:	fd843583          	ld	a1,-40(s0)
    12c4:	00007517          	auipc	a0,0x7
    12c8:	3d450513          	addi	a0,a0,980 # 8698 <malloc+0x6b6>
    12cc:	00007097          	auipc	ra,0x7
    12d0:	b24080e7          	jalr	-1244(ra) # 7df0 <printf>
    exit(1);
    12d4:	4505                	li	a0,1
    12d6:	00006097          	auipc	ra,0x6
    12da:	5d2080e7          	jalr	1490(ra) # 78a8 <exit>
  }
  pid = fork();
    12de:	00006097          	auipc	ra,0x6
    12e2:	5c2080e7          	jalr	1474(ra) # 78a0 <fork>
    12e6:	87aa                	mv	a5,a0
    12e8:	fef42623          	sw	a5,-20(s0)
  if(pid < 0){
    12ec:	fec42783          	lw	a5,-20(s0)
    12f0:	2781                	sext.w	a5,a5
    12f2:	0207d163          	bgez	a5,1314 <openiputtest+0x76>
    printf("%s: fork failed\n", s);
    12f6:	fd843583          	ld	a1,-40(s0)
    12fa:	00007517          	auipc	a0,0x7
    12fe:	26650513          	addi	a0,a0,614 # 8560 <malloc+0x57e>
    1302:	00007097          	auipc	ra,0x7
    1306:	aee080e7          	jalr	-1298(ra) # 7df0 <printf>
    exit(1);
    130a:	4505                	li	a0,1
    130c:	00006097          	auipc	ra,0x6
    1310:	59c080e7          	jalr	1436(ra) # 78a8 <exit>
  }
  if(pid == 0){
    1314:	fec42783          	lw	a5,-20(s0)
    1318:	2781                	sext.w	a5,a5
    131a:	e7b1                	bnez	a5,1366 <openiputtest+0xc8>
    int fd = open("oidir", O_RDWR);
    131c:	4589                	li	a1,2
    131e:	00007517          	auipc	a0,0x7
    1322:	37250513          	addi	a0,a0,882 # 8690 <malloc+0x6ae>
    1326:	00006097          	auipc	ra,0x6
    132a:	5c2080e7          	jalr	1474(ra) # 78e8 <open>
    132e:	87aa                	mv	a5,a0
    1330:	fef42423          	sw	a5,-24(s0)
    if(fd >= 0){
    1334:	fe842783          	lw	a5,-24(s0)
    1338:	2781                	sext.w	a5,a5
    133a:	0207c163          	bltz	a5,135c <openiputtest+0xbe>
      printf("%s: open directory for write succeeded\n", s);
    133e:	fd843583          	ld	a1,-40(s0)
    1342:	00007517          	auipc	a0,0x7
    1346:	36e50513          	addi	a0,a0,878 # 86b0 <malloc+0x6ce>
    134a:	00007097          	auipc	ra,0x7
    134e:	aa6080e7          	jalr	-1370(ra) # 7df0 <printf>
      exit(1);
    1352:	4505                	li	a0,1
    1354:	00006097          	auipc	ra,0x6
    1358:	554080e7          	jalr	1364(ra) # 78a8 <exit>
    }
    exit(0);
    135c:	4501                	li	a0,0
    135e:	00006097          	auipc	ra,0x6
    1362:	54a080e7          	jalr	1354(ra) # 78a8 <exit>
  }
  sleep(1);
    1366:	4505                	li	a0,1
    1368:	00006097          	auipc	ra,0x6
    136c:	5d0080e7          	jalr	1488(ra) # 7938 <sleep>
  if(unlink("oidir") != 0){
    1370:	00007517          	auipc	a0,0x7
    1374:	32050513          	addi	a0,a0,800 # 8690 <malloc+0x6ae>
    1378:	00006097          	auipc	ra,0x6
    137c:	580080e7          	jalr	1408(ra) # 78f8 <unlink>
    1380:	87aa                	mv	a5,a0
    1382:	c385                	beqz	a5,13a2 <openiputtest+0x104>
    printf("%s: unlink failed\n", s);
    1384:	fd843583          	ld	a1,-40(s0)
    1388:	00007517          	auipc	a0,0x7
    138c:	35050513          	addi	a0,a0,848 # 86d8 <malloc+0x6f6>
    1390:	00007097          	auipc	ra,0x7
    1394:	a60080e7          	jalr	-1440(ra) # 7df0 <printf>
    exit(1);
    1398:	4505                	li	a0,1
    139a:	00006097          	auipc	ra,0x6
    139e:	50e080e7          	jalr	1294(ra) # 78a8 <exit>
  }
  wait(&xstatus);
    13a2:	fe440793          	addi	a5,s0,-28
    13a6:	853e                	mv	a0,a5
    13a8:	00006097          	auipc	ra,0x6
    13ac:	508080e7          	jalr	1288(ra) # 78b0 <wait>
  exit(xstatus);
    13b0:	fe442783          	lw	a5,-28(s0)
    13b4:	853e                	mv	a0,a5
    13b6:	00006097          	auipc	ra,0x6
    13ba:	4f2080e7          	jalr	1266(ra) # 78a8 <exit>

00000000000013be <opentest>:

// simple file system tests

void
opentest(char *s)
{
    13be:	7179                	addi	sp,sp,-48
    13c0:	f406                	sd	ra,40(sp)
    13c2:	f022                	sd	s0,32(sp)
    13c4:	1800                	addi	s0,sp,48
    13c6:	fca43c23          	sd	a0,-40(s0)
  int fd;

  fd = open("echo", 0);
    13ca:	4581                	li	a1,0
    13cc:	00007517          	auipc	a0,0x7
    13d0:	f7450513          	addi	a0,a0,-140 # 8340 <malloc+0x35e>
    13d4:	00006097          	auipc	ra,0x6
    13d8:	514080e7          	jalr	1300(ra) # 78e8 <open>
    13dc:	87aa                	mv	a5,a0
    13de:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    13e2:	fec42783          	lw	a5,-20(s0)
    13e6:	2781                	sext.w	a5,a5
    13e8:	0207d163          	bgez	a5,140a <opentest+0x4c>
    printf("%s: open echo failed!\n", s);
    13ec:	fd843583          	ld	a1,-40(s0)
    13f0:	00007517          	auipc	a0,0x7
    13f4:	30050513          	addi	a0,a0,768 # 86f0 <malloc+0x70e>
    13f8:	00007097          	auipc	ra,0x7
    13fc:	9f8080e7          	jalr	-1544(ra) # 7df0 <printf>
    exit(1);
    1400:	4505                	li	a0,1
    1402:	00006097          	auipc	ra,0x6
    1406:	4a6080e7          	jalr	1190(ra) # 78a8 <exit>
  }
  close(fd);
    140a:	fec42783          	lw	a5,-20(s0)
    140e:	853e                	mv	a0,a5
    1410:	00006097          	auipc	ra,0x6
    1414:	4c0080e7          	jalr	1216(ra) # 78d0 <close>
  fd = open("doesnotexist", 0);
    1418:	4581                	li	a1,0
    141a:	00007517          	auipc	a0,0x7
    141e:	2ee50513          	addi	a0,a0,750 # 8708 <malloc+0x726>
    1422:	00006097          	auipc	ra,0x6
    1426:	4c6080e7          	jalr	1222(ra) # 78e8 <open>
    142a:	87aa                	mv	a5,a0
    142c:	fef42623          	sw	a5,-20(s0)
  if(fd >= 0){
    1430:	fec42783          	lw	a5,-20(s0)
    1434:	2781                	sext.w	a5,a5
    1436:	0207c163          	bltz	a5,1458 <opentest+0x9a>
    printf("%s: open doesnotexist succeeded!\n", s);
    143a:	fd843583          	ld	a1,-40(s0)
    143e:	00007517          	auipc	a0,0x7
    1442:	2da50513          	addi	a0,a0,730 # 8718 <malloc+0x736>
    1446:	00007097          	auipc	ra,0x7
    144a:	9aa080e7          	jalr	-1622(ra) # 7df0 <printf>
    exit(1);
    144e:	4505                	li	a0,1
    1450:	00006097          	auipc	ra,0x6
    1454:	458080e7          	jalr	1112(ra) # 78a8 <exit>
  }
}
    1458:	0001                	nop
    145a:	70a2                	ld	ra,40(sp)
    145c:	7402                	ld	s0,32(sp)
    145e:	6145                	addi	sp,sp,48
    1460:	8082                	ret

0000000000001462 <writetest>:

void
writetest(char *s)
{
    1462:	7179                	addi	sp,sp,-48
    1464:	f406                	sd	ra,40(sp)
    1466:	f022                	sd	s0,32(sp)
    1468:	1800                	addi	s0,sp,48
    146a:	fca43c23          	sd	a0,-40(s0)
  int fd;
  int i;
  enum { N=100, SZ=10 };
  
  fd = open("small", O_CREATE|O_RDWR);
    146e:	20200593          	li	a1,514
    1472:	00007517          	auipc	a0,0x7
    1476:	2ce50513          	addi	a0,a0,718 # 8740 <malloc+0x75e>
    147a:	00006097          	auipc	ra,0x6
    147e:	46e080e7          	jalr	1134(ra) # 78e8 <open>
    1482:	87aa                	mv	a5,a0
    1484:	fef42423          	sw	a5,-24(s0)
  if(fd < 0){
    1488:	fe842783          	lw	a5,-24(s0)
    148c:	2781                	sext.w	a5,a5
    148e:	0207d163          	bgez	a5,14b0 <writetest+0x4e>
    printf("%s: error: creat small failed!\n", s);
    1492:	fd843583          	ld	a1,-40(s0)
    1496:	00007517          	auipc	a0,0x7
    149a:	2b250513          	addi	a0,a0,690 # 8748 <malloc+0x766>
    149e:	00007097          	auipc	ra,0x7
    14a2:	952080e7          	jalr	-1710(ra) # 7df0 <printf>
    exit(1);
    14a6:	4505                	li	a0,1
    14a8:	00006097          	auipc	ra,0x6
    14ac:	400080e7          	jalr	1024(ra) # 78a8 <exit>
  }
  for(i = 0; i < N; i++){
    14b0:	fe042623          	sw	zero,-20(s0)
    14b4:	a861                	j	154c <writetest+0xea>
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    14b6:	fe842783          	lw	a5,-24(s0)
    14ba:	4629                	li	a2,10
    14bc:	00007597          	auipc	a1,0x7
    14c0:	2ac58593          	addi	a1,a1,684 # 8768 <malloc+0x786>
    14c4:	853e                	mv	a0,a5
    14c6:	00006097          	auipc	ra,0x6
    14ca:	402080e7          	jalr	1026(ra) # 78c8 <write>
    14ce:	87aa                	mv	a5,a0
    14d0:	873e                	mv	a4,a5
    14d2:	47a9                	li	a5,10
    14d4:	02f70463          	beq	a4,a5,14fc <writetest+0x9a>
      printf("%s: error: write aa %d new file failed\n", s, i);
    14d8:	fec42783          	lw	a5,-20(s0)
    14dc:	863e                	mv	a2,a5
    14de:	fd843583          	ld	a1,-40(s0)
    14e2:	00007517          	auipc	a0,0x7
    14e6:	29650513          	addi	a0,a0,662 # 8778 <malloc+0x796>
    14ea:	00007097          	auipc	ra,0x7
    14ee:	906080e7          	jalr	-1786(ra) # 7df0 <printf>
      exit(1);
    14f2:	4505                	li	a0,1
    14f4:	00006097          	auipc	ra,0x6
    14f8:	3b4080e7          	jalr	948(ra) # 78a8 <exit>
    }
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    14fc:	fe842783          	lw	a5,-24(s0)
    1500:	4629                	li	a2,10
    1502:	00007597          	auipc	a1,0x7
    1506:	29e58593          	addi	a1,a1,670 # 87a0 <malloc+0x7be>
    150a:	853e                	mv	a0,a5
    150c:	00006097          	auipc	ra,0x6
    1510:	3bc080e7          	jalr	956(ra) # 78c8 <write>
    1514:	87aa                	mv	a5,a0
    1516:	873e                	mv	a4,a5
    1518:	47a9                	li	a5,10
    151a:	02f70463          	beq	a4,a5,1542 <writetest+0xe0>
      printf("%s: error: write bb %d new file failed\n", s, i);
    151e:	fec42783          	lw	a5,-20(s0)
    1522:	863e                	mv	a2,a5
    1524:	fd843583          	ld	a1,-40(s0)
    1528:	00007517          	auipc	a0,0x7
    152c:	28850513          	addi	a0,a0,648 # 87b0 <malloc+0x7ce>
    1530:	00007097          	auipc	ra,0x7
    1534:	8c0080e7          	jalr	-1856(ra) # 7df0 <printf>
      exit(1);
    1538:	4505                	li	a0,1
    153a:	00006097          	auipc	ra,0x6
    153e:	36e080e7          	jalr	878(ra) # 78a8 <exit>
  for(i = 0; i < N; i++){
    1542:	fec42783          	lw	a5,-20(s0)
    1546:	2785                	addiw	a5,a5,1
    1548:	fef42623          	sw	a5,-20(s0)
    154c:	fec42783          	lw	a5,-20(s0)
    1550:	0007871b          	sext.w	a4,a5
    1554:	06300793          	li	a5,99
    1558:	f4e7dfe3          	bge	a5,a4,14b6 <writetest+0x54>
    }
  }
  close(fd);
    155c:	fe842783          	lw	a5,-24(s0)
    1560:	853e                	mv	a0,a5
    1562:	00006097          	auipc	ra,0x6
    1566:	36e080e7          	jalr	878(ra) # 78d0 <close>
  fd = open("small", O_RDONLY);
    156a:	4581                	li	a1,0
    156c:	00007517          	auipc	a0,0x7
    1570:	1d450513          	addi	a0,a0,468 # 8740 <malloc+0x75e>
    1574:	00006097          	auipc	ra,0x6
    1578:	374080e7          	jalr	884(ra) # 78e8 <open>
    157c:	87aa                	mv	a5,a0
    157e:	fef42423          	sw	a5,-24(s0)
  if(fd < 0){
    1582:	fe842783          	lw	a5,-24(s0)
    1586:	2781                	sext.w	a5,a5
    1588:	0207d163          	bgez	a5,15aa <writetest+0x148>
    printf("%s: error: open small failed!\n", s);
    158c:	fd843583          	ld	a1,-40(s0)
    1590:	00007517          	auipc	a0,0x7
    1594:	24850513          	addi	a0,a0,584 # 87d8 <malloc+0x7f6>
    1598:	00007097          	auipc	ra,0x7
    159c:	858080e7          	jalr	-1960(ra) # 7df0 <printf>
    exit(1);
    15a0:	4505                	li	a0,1
    15a2:	00006097          	auipc	ra,0x6
    15a6:	306080e7          	jalr	774(ra) # 78a8 <exit>
  }
  i = read(fd, buf, N*SZ*2);
    15aa:	fe842783          	lw	a5,-24(s0)
    15ae:	7d000613          	li	a2,2000
    15b2:	0000a597          	auipc	a1,0xa
    15b6:	ebe58593          	addi	a1,a1,-322 # b470 <buf>
    15ba:	853e                	mv	a0,a5
    15bc:	00006097          	auipc	ra,0x6
    15c0:	304080e7          	jalr	772(ra) # 78c0 <read>
    15c4:	87aa                	mv	a5,a0
    15c6:	fef42623          	sw	a5,-20(s0)
  if(i != N*SZ*2){
    15ca:	fec42783          	lw	a5,-20(s0)
    15ce:	0007871b          	sext.w	a4,a5
    15d2:	7d000793          	li	a5,2000
    15d6:	02f70163          	beq	a4,a5,15f8 <writetest+0x196>
    printf("%s: read failed\n", s);
    15da:	fd843583          	ld	a1,-40(s0)
    15de:	00007517          	auipc	a0,0x7
    15e2:	21a50513          	addi	a0,a0,538 # 87f8 <malloc+0x816>
    15e6:	00007097          	auipc	ra,0x7
    15ea:	80a080e7          	jalr	-2038(ra) # 7df0 <printf>
    exit(1);
    15ee:	4505                	li	a0,1
    15f0:	00006097          	auipc	ra,0x6
    15f4:	2b8080e7          	jalr	696(ra) # 78a8 <exit>
  }
  close(fd);
    15f8:	fe842783          	lw	a5,-24(s0)
    15fc:	853e                	mv	a0,a5
    15fe:	00006097          	auipc	ra,0x6
    1602:	2d2080e7          	jalr	722(ra) # 78d0 <close>

  if(unlink("small") < 0){
    1606:	00007517          	auipc	a0,0x7
    160a:	13a50513          	addi	a0,a0,314 # 8740 <malloc+0x75e>
    160e:	00006097          	auipc	ra,0x6
    1612:	2ea080e7          	jalr	746(ra) # 78f8 <unlink>
    1616:	87aa                	mv	a5,a0
    1618:	0207d163          	bgez	a5,163a <writetest+0x1d8>
    printf("%s: unlink small failed\n", s);
    161c:	fd843583          	ld	a1,-40(s0)
    1620:	00007517          	auipc	a0,0x7
    1624:	1f050513          	addi	a0,a0,496 # 8810 <malloc+0x82e>
    1628:	00006097          	auipc	ra,0x6
    162c:	7c8080e7          	jalr	1992(ra) # 7df0 <printf>
    exit(1);
    1630:	4505                	li	a0,1
    1632:	00006097          	auipc	ra,0x6
    1636:	276080e7          	jalr	630(ra) # 78a8 <exit>
  }
}
    163a:	0001                	nop
    163c:	70a2                	ld	ra,40(sp)
    163e:	7402                	ld	s0,32(sp)
    1640:	6145                	addi	sp,sp,48
    1642:	8082                	ret

0000000000001644 <writebig>:

void
writebig(char *s)
{
    1644:	7179                	addi	sp,sp,-48
    1646:	f406                	sd	ra,40(sp)
    1648:	f022                	sd	s0,32(sp)
    164a:	1800                	addi	s0,sp,48
    164c:	fca43c23          	sd	a0,-40(s0)
  int i, fd, n;

  fd = open("big", O_CREATE|O_RDWR);
    1650:	20200593          	li	a1,514
    1654:	00007517          	auipc	a0,0x7
    1658:	1dc50513          	addi	a0,a0,476 # 8830 <malloc+0x84e>
    165c:	00006097          	auipc	ra,0x6
    1660:	28c080e7          	jalr	652(ra) # 78e8 <open>
    1664:	87aa                	mv	a5,a0
    1666:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
    166a:	fe442783          	lw	a5,-28(s0)
    166e:	2781                	sext.w	a5,a5
    1670:	0207d163          	bgez	a5,1692 <writebig+0x4e>
    printf("%s: error: creat big failed!\n", s);
    1674:	fd843583          	ld	a1,-40(s0)
    1678:	00007517          	auipc	a0,0x7
    167c:	1c050513          	addi	a0,a0,448 # 8838 <malloc+0x856>
    1680:	00006097          	auipc	ra,0x6
    1684:	770080e7          	jalr	1904(ra) # 7df0 <printf>
    exit(1);
    1688:	4505                	li	a0,1
    168a:	00006097          	auipc	ra,0x6
    168e:	21e080e7          	jalr	542(ra) # 78a8 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
    1692:	fe042623          	sw	zero,-20(s0)
    1696:	a095                	j	16fa <writebig+0xb6>
    ((int*)buf)[0] = i;
    1698:	0000a797          	auipc	a5,0xa
    169c:	dd878793          	addi	a5,a5,-552 # b470 <buf>
    16a0:	fec42703          	lw	a4,-20(s0)
    16a4:	c398                	sw	a4,0(a5)
    if(write(fd, buf, BSIZE) != BSIZE){
    16a6:	fe442783          	lw	a5,-28(s0)
    16aa:	40000613          	li	a2,1024
    16ae:	0000a597          	auipc	a1,0xa
    16b2:	dc258593          	addi	a1,a1,-574 # b470 <buf>
    16b6:	853e                	mv	a0,a5
    16b8:	00006097          	auipc	ra,0x6
    16bc:	210080e7          	jalr	528(ra) # 78c8 <write>
    16c0:	87aa                	mv	a5,a0
    16c2:	873e                	mv	a4,a5
    16c4:	40000793          	li	a5,1024
    16c8:	02f70463          	beq	a4,a5,16f0 <writebig+0xac>
      printf("%s: error: write big file failed\n", s, i);
    16cc:	fec42783          	lw	a5,-20(s0)
    16d0:	863e                	mv	a2,a5
    16d2:	fd843583          	ld	a1,-40(s0)
    16d6:	00007517          	auipc	a0,0x7
    16da:	18250513          	addi	a0,a0,386 # 8858 <malloc+0x876>
    16de:	00006097          	auipc	ra,0x6
    16e2:	712080e7          	jalr	1810(ra) # 7df0 <printf>
      exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00006097          	auipc	ra,0x6
    16ec:	1c0080e7          	jalr	448(ra) # 78a8 <exit>
  for(i = 0; i < MAXFILE; i++){
    16f0:	fec42783          	lw	a5,-20(s0)
    16f4:	2785                	addiw	a5,a5,1
    16f6:	fef42623          	sw	a5,-20(s0)
    16fa:	fec42783          	lw	a5,-20(s0)
    16fe:	873e                	mv	a4,a5
    1700:	10b00793          	li	a5,267
    1704:	f8e7fae3          	bgeu	a5,a4,1698 <writebig+0x54>
    }
  }

  close(fd);
    1708:	fe442783          	lw	a5,-28(s0)
    170c:	853e                	mv	a0,a5
    170e:	00006097          	auipc	ra,0x6
    1712:	1c2080e7          	jalr	450(ra) # 78d0 <close>

  fd = open("big", O_RDONLY);
    1716:	4581                	li	a1,0
    1718:	00007517          	auipc	a0,0x7
    171c:	11850513          	addi	a0,a0,280 # 8830 <malloc+0x84e>
    1720:	00006097          	auipc	ra,0x6
    1724:	1c8080e7          	jalr	456(ra) # 78e8 <open>
    1728:	87aa                	mv	a5,a0
    172a:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
    172e:	fe442783          	lw	a5,-28(s0)
    1732:	2781                	sext.w	a5,a5
    1734:	0207d163          	bgez	a5,1756 <writebig+0x112>
    printf("%s: error: open big failed!\n", s);
    1738:	fd843583          	ld	a1,-40(s0)
    173c:	00007517          	auipc	a0,0x7
    1740:	14450513          	addi	a0,a0,324 # 8880 <malloc+0x89e>
    1744:	00006097          	auipc	ra,0x6
    1748:	6ac080e7          	jalr	1708(ra) # 7df0 <printf>
    exit(1);
    174c:	4505                	li	a0,1
    174e:	00006097          	auipc	ra,0x6
    1752:	15a080e7          	jalr	346(ra) # 78a8 <exit>
  }

  n = 0;
    1756:	fe042423          	sw	zero,-24(s0)
  for(;;){
    i = read(fd, buf, BSIZE);
    175a:	fe442783          	lw	a5,-28(s0)
    175e:	40000613          	li	a2,1024
    1762:	0000a597          	auipc	a1,0xa
    1766:	d0e58593          	addi	a1,a1,-754 # b470 <buf>
    176a:	853e                	mv	a0,a5
    176c:	00006097          	auipc	ra,0x6
    1770:	154080e7          	jalr	340(ra) # 78c0 <read>
    1774:	87aa                	mv	a5,a0
    1776:	fef42623          	sw	a5,-20(s0)
    if(i == 0){
    177a:	fec42783          	lw	a5,-20(s0)
    177e:	2781                	sext.w	a5,a5
    1780:	eb9d                	bnez	a5,17b6 <writebig+0x172>
      if(n == MAXFILE - 1){
    1782:	fe842783          	lw	a5,-24(s0)
    1786:	0007871b          	sext.w	a4,a5
    178a:	10b00793          	li	a5,267
    178e:	0af71663          	bne	a4,a5,183a <writebig+0x1f6>
        printf("%s: read only %d blocks from big", s, n);
    1792:	fe842783          	lw	a5,-24(s0)
    1796:	863e                	mv	a2,a5
    1798:	fd843583          	ld	a1,-40(s0)
    179c:	00007517          	auipc	a0,0x7
    17a0:	10450513          	addi	a0,a0,260 # 88a0 <malloc+0x8be>
    17a4:	00006097          	auipc	ra,0x6
    17a8:	64c080e7          	jalr	1612(ra) # 7df0 <printf>
        exit(1);
    17ac:	4505                	li	a0,1
    17ae:	00006097          	auipc	ra,0x6
    17b2:	0fa080e7          	jalr	250(ra) # 78a8 <exit>
      }
      break;
    } else if(i != BSIZE){
    17b6:	fec42783          	lw	a5,-20(s0)
    17ba:	0007871b          	sext.w	a4,a5
    17be:	40000793          	li	a5,1024
    17c2:	02f70463          	beq	a4,a5,17ea <writebig+0x1a6>
      printf("%s: read failed %d\n", s, i);
    17c6:	fec42783          	lw	a5,-20(s0)
    17ca:	863e                	mv	a2,a5
    17cc:	fd843583          	ld	a1,-40(s0)
    17d0:	00007517          	auipc	a0,0x7
    17d4:	0f850513          	addi	a0,a0,248 # 88c8 <malloc+0x8e6>
    17d8:	00006097          	auipc	ra,0x6
    17dc:	618080e7          	jalr	1560(ra) # 7df0 <printf>
      exit(1);
    17e0:	4505                	li	a0,1
    17e2:	00006097          	auipc	ra,0x6
    17e6:	0c6080e7          	jalr	198(ra) # 78a8 <exit>
    }
    if(((int*)buf)[0] != n){
    17ea:	0000a797          	auipc	a5,0xa
    17ee:	c8678793          	addi	a5,a5,-890 # b470 <buf>
    17f2:	4398                	lw	a4,0(a5)
    17f4:	fe842783          	lw	a5,-24(s0)
    17f8:	2781                	sext.w	a5,a5
    17fa:	02e78a63          	beq	a5,a4,182e <writebig+0x1ea>
      printf("%s: read content of block %d is %d\n", s,
             n, ((int*)buf)[0]);
    17fe:	0000a797          	auipc	a5,0xa
    1802:	c7278793          	addi	a5,a5,-910 # b470 <buf>
      printf("%s: read content of block %d is %d\n", s,
    1806:	4398                	lw	a4,0(a5)
    1808:	fe842783          	lw	a5,-24(s0)
    180c:	86ba                	mv	a3,a4
    180e:	863e                	mv	a2,a5
    1810:	fd843583          	ld	a1,-40(s0)
    1814:	00007517          	auipc	a0,0x7
    1818:	0cc50513          	addi	a0,a0,204 # 88e0 <malloc+0x8fe>
    181c:	00006097          	auipc	ra,0x6
    1820:	5d4080e7          	jalr	1492(ra) # 7df0 <printf>
      exit(1);
    1824:	4505                	li	a0,1
    1826:	00006097          	auipc	ra,0x6
    182a:	082080e7          	jalr	130(ra) # 78a8 <exit>
    }
    n++;
    182e:	fe842783          	lw	a5,-24(s0)
    1832:	2785                	addiw	a5,a5,1
    1834:	fef42423          	sw	a5,-24(s0)
    i = read(fd, buf, BSIZE);
    1838:	b70d                	j	175a <writebig+0x116>
      break;
    183a:	0001                	nop
  }
  close(fd);
    183c:	fe442783          	lw	a5,-28(s0)
    1840:	853e                	mv	a0,a5
    1842:	00006097          	auipc	ra,0x6
    1846:	08e080e7          	jalr	142(ra) # 78d0 <close>
  if(unlink("big") < 0){
    184a:	00007517          	auipc	a0,0x7
    184e:	fe650513          	addi	a0,a0,-26 # 8830 <malloc+0x84e>
    1852:	00006097          	auipc	ra,0x6
    1856:	0a6080e7          	jalr	166(ra) # 78f8 <unlink>
    185a:	87aa                	mv	a5,a0
    185c:	0207d163          	bgez	a5,187e <writebig+0x23a>
    printf("%s: unlink big failed\n", s);
    1860:	fd843583          	ld	a1,-40(s0)
    1864:	00007517          	auipc	a0,0x7
    1868:	0a450513          	addi	a0,a0,164 # 8908 <malloc+0x926>
    186c:	00006097          	auipc	ra,0x6
    1870:	584080e7          	jalr	1412(ra) # 7df0 <printf>
    exit(1);
    1874:	4505                	li	a0,1
    1876:	00006097          	auipc	ra,0x6
    187a:	032080e7          	jalr	50(ra) # 78a8 <exit>
  }
}
    187e:	0001                	nop
    1880:	70a2                	ld	ra,40(sp)
    1882:	7402                	ld	s0,32(sp)
    1884:	6145                	addi	sp,sp,48
    1886:	8082                	ret

0000000000001888 <createtest>:

// many creates, followed by unlink test
void
createtest(char *s)
{
    1888:	7179                	addi	sp,sp,-48
    188a:	f406                	sd	ra,40(sp)
    188c:	f022                	sd	s0,32(sp)
    188e:	1800                	addi	s0,sp,48
    1890:	fca43c23          	sd	a0,-40(s0)
  int i, fd;
  enum { N=52 };

  char name[3];
  name[0] = 'a';
    1894:	06100793          	li	a5,97
    1898:	fef40023          	sb	a5,-32(s0)
  name[2] = '\0';
    189c:	fe040123          	sb	zero,-30(s0)
  for(i = 0; i < N; i++){
    18a0:	fe042623          	sw	zero,-20(s0)
    18a4:	a099                	j	18ea <createtest+0x62>
    name[1] = '0' + i;
    18a6:	fec42783          	lw	a5,-20(s0)
    18aa:	0ff7f793          	zext.b	a5,a5
    18ae:	0307879b          	addiw	a5,a5,48
    18b2:	0ff7f793          	zext.b	a5,a5
    18b6:	fef400a3          	sb	a5,-31(s0)
    fd = open(name, O_CREATE|O_RDWR);
    18ba:	fe040793          	addi	a5,s0,-32
    18be:	20200593          	li	a1,514
    18c2:	853e                	mv	a0,a5
    18c4:	00006097          	auipc	ra,0x6
    18c8:	024080e7          	jalr	36(ra) # 78e8 <open>
    18cc:	87aa                	mv	a5,a0
    18ce:	fef42423          	sw	a5,-24(s0)
    close(fd);
    18d2:	fe842783          	lw	a5,-24(s0)
    18d6:	853e                	mv	a0,a5
    18d8:	00006097          	auipc	ra,0x6
    18dc:	ff8080e7          	jalr	-8(ra) # 78d0 <close>
  for(i = 0; i < N; i++){
    18e0:	fec42783          	lw	a5,-20(s0)
    18e4:	2785                	addiw	a5,a5,1
    18e6:	fef42623          	sw	a5,-20(s0)
    18ea:	fec42783          	lw	a5,-20(s0)
    18ee:	0007871b          	sext.w	a4,a5
    18f2:	03300793          	li	a5,51
    18f6:	fae7d8e3          	bge	a5,a4,18a6 <createtest+0x1e>
  }
  name[0] = 'a';
    18fa:	06100793          	li	a5,97
    18fe:	fef40023          	sb	a5,-32(s0)
  name[2] = '\0';
    1902:	fe040123          	sb	zero,-30(s0)
  for(i = 0; i < N; i++){
    1906:	fe042623          	sw	zero,-20(s0)
    190a:	a03d                	j	1938 <createtest+0xb0>
    name[1] = '0' + i;
    190c:	fec42783          	lw	a5,-20(s0)
    1910:	0ff7f793          	zext.b	a5,a5
    1914:	0307879b          	addiw	a5,a5,48
    1918:	0ff7f793          	zext.b	a5,a5
    191c:	fef400a3          	sb	a5,-31(s0)
    unlink(name);
    1920:	fe040793          	addi	a5,s0,-32
    1924:	853e                	mv	a0,a5
    1926:	00006097          	auipc	ra,0x6
    192a:	fd2080e7          	jalr	-46(ra) # 78f8 <unlink>
  for(i = 0; i < N; i++){
    192e:	fec42783          	lw	a5,-20(s0)
    1932:	2785                	addiw	a5,a5,1
    1934:	fef42623          	sw	a5,-20(s0)
    1938:	fec42783          	lw	a5,-20(s0)
    193c:	0007871b          	sext.w	a4,a5
    1940:	03300793          	li	a5,51
    1944:	fce7d4e3          	bge	a5,a4,190c <createtest+0x84>
  }
}
    1948:	0001                	nop
    194a:	0001                	nop
    194c:	70a2                	ld	ra,40(sp)
    194e:	7402                	ld	s0,32(sp)
    1950:	6145                	addi	sp,sp,48
    1952:	8082                	ret

0000000000001954 <dirtest>:

void dirtest(char *s)
{
    1954:	1101                	addi	sp,sp,-32
    1956:	ec06                	sd	ra,24(sp)
    1958:	e822                	sd	s0,16(sp)
    195a:	1000                	addi	s0,sp,32
    195c:	fea43423          	sd	a0,-24(s0)
  if(mkdir("dir0") < 0){
    1960:	00007517          	auipc	a0,0x7
    1964:	fc050513          	addi	a0,a0,-64 # 8920 <malloc+0x93e>
    1968:	00006097          	auipc	ra,0x6
    196c:	fa8080e7          	jalr	-88(ra) # 7910 <mkdir>
    1970:	87aa                	mv	a5,a0
    1972:	0207d163          	bgez	a5,1994 <dirtest+0x40>
    printf("%s: mkdir failed\n", s);
    1976:	fe843583          	ld	a1,-24(s0)
    197a:	00007517          	auipc	a0,0x7
    197e:	c7650513          	addi	a0,a0,-906 # 85f0 <malloc+0x60e>
    1982:	00006097          	auipc	ra,0x6
    1986:	46e080e7          	jalr	1134(ra) # 7df0 <printf>
    exit(1);
    198a:	4505                	li	a0,1
    198c:	00006097          	auipc	ra,0x6
    1990:	f1c080e7          	jalr	-228(ra) # 78a8 <exit>
  }

  if(chdir("dir0") < 0){
    1994:	00007517          	auipc	a0,0x7
    1998:	f8c50513          	addi	a0,a0,-116 # 8920 <malloc+0x93e>
    199c:	00006097          	auipc	ra,0x6
    19a0:	f7c080e7          	jalr	-132(ra) # 7918 <chdir>
    19a4:	87aa                	mv	a5,a0
    19a6:	0207d163          	bgez	a5,19c8 <dirtest+0x74>
    printf("%s: chdir dir0 failed\n", s);
    19aa:	fe843583          	ld	a1,-24(s0)
    19ae:	00007517          	auipc	a0,0x7
    19b2:	f7a50513          	addi	a0,a0,-134 # 8928 <malloc+0x946>
    19b6:	00006097          	auipc	ra,0x6
    19ba:	43a080e7          	jalr	1082(ra) # 7df0 <printf>
    exit(1);
    19be:	4505                	li	a0,1
    19c0:	00006097          	auipc	ra,0x6
    19c4:	ee8080e7          	jalr	-280(ra) # 78a8 <exit>
  }

  if(chdir("..") < 0){
    19c8:	00007517          	auipc	a0,0x7
    19cc:	f7850513          	addi	a0,a0,-136 # 8940 <malloc+0x95e>
    19d0:	00006097          	auipc	ra,0x6
    19d4:	f48080e7          	jalr	-184(ra) # 7918 <chdir>
    19d8:	87aa                	mv	a5,a0
    19da:	0207d163          	bgez	a5,19fc <dirtest+0xa8>
    printf("%s: chdir .. failed\n", s);
    19de:	fe843583          	ld	a1,-24(s0)
    19e2:	00007517          	auipc	a0,0x7
    19e6:	f6650513          	addi	a0,a0,-154 # 8948 <malloc+0x966>
    19ea:	00006097          	auipc	ra,0x6
    19ee:	406080e7          	jalr	1030(ra) # 7df0 <printf>
    exit(1);
    19f2:	4505                	li	a0,1
    19f4:	00006097          	auipc	ra,0x6
    19f8:	eb4080e7          	jalr	-332(ra) # 78a8 <exit>
  }

  if(unlink("dir0") < 0){
    19fc:	00007517          	auipc	a0,0x7
    1a00:	f2450513          	addi	a0,a0,-220 # 8920 <malloc+0x93e>
    1a04:	00006097          	auipc	ra,0x6
    1a08:	ef4080e7          	jalr	-268(ra) # 78f8 <unlink>
    1a0c:	87aa                	mv	a5,a0
    1a0e:	0207d163          	bgez	a5,1a30 <dirtest+0xdc>
    printf("%s: unlink dir0 failed\n", s);
    1a12:	fe843583          	ld	a1,-24(s0)
    1a16:	00007517          	auipc	a0,0x7
    1a1a:	f4a50513          	addi	a0,a0,-182 # 8960 <malloc+0x97e>
    1a1e:	00006097          	auipc	ra,0x6
    1a22:	3d2080e7          	jalr	978(ra) # 7df0 <printf>
    exit(1);
    1a26:	4505                	li	a0,1
    1a28:	00006097          	auipc	ra,0x6
    1a2c:	e80080e7          	jalr	-384(ra) # 78a8 <exit>
  }
}
    1a30:	0001                	nop
    1a32:	60e2                	ld	ra,24(sp)
    1a34:	6442                	ld	s0,16(sp)
    1a36:	6105                	addi	sp,sp,32
    1a38:	8082                	ret

0000000000001a3a <exectest>:

void
exectest(char *s)
{
    1a3a:	715d                	addi	sp,sp,-80
    1a3c:	e486                	sd	ra,72(sp)
    1a3e:	e0a2                	sd	s0,64(sp)
    1a40:	0880                	addi	s0,sp,80
    1a42:	faa43c23          	sd	a0,-72(s0)
  int fd, xstatus, pid;
  char *echoargv[] = { "echo", "OK", 0 };
    1a46:	00007797          	auipc	a5,0x7
    1a4a:	8fa78793          	addi	a5,a5,-1798 # 8340 <malloc+0x35e>
    1a4e:	fcf43423          	sd	a5,-56(s0)
    1a52:	00007797          	auipc	a5,0x7
    1a56:	f2678793          	addi	a5,a5,-218 # 8978 <malloc+0x996>
    1a5a:	fcf43823          	sd	a5,-48(s0)
    1a5e:	fc043c23          	sd	zero,-40(s0)
  char buf[3];

  unlink("echo-ok");
    1a62:	00007517          	auipc	a0,0x7
    1a66:	f1e50513          	addi	a0,a0,-226 # 8980 <malloc+0x99e>
    1a6a:	00006097          	auipc	ra,0x6
    1a6e:	e8e080e7          	jalr	-370(ra) # 78f8 <unlink>
  pid = fork();
    1a72:	00006097          	auipc	ra,0x6
    1a76:	e2e080e7          	jalr	-466(ra) # 78a0 <fork>
    1a7a:	87aa                	mv	a5,a0
    1a7c:	fef42623          	sw	a5,-20(s0)
  if(pid < 0) {
    1a80:	fec42783          	lw	a5,-20(s0)
    1a84:	2781                	sext.w	a5,a5
    1a86:	0207d163          	bgez	a5,1aa8 <exectest+0x6e>
     printf("%s: fork failed\n", s);
    1a8a:	fb843583          	ld	a1,-72(s0)
    1a8e:	00007517          	auipc	a0,0x7
    1a92:	ad250513          	addi	a0,a0,-1326 # 8560 <malloc+0x57e>
    1a96:	00006097          	auipc	ra,0x6
    1a9a:	35a080e7          	jalr	858(ra) # 7df0 <printf>
     exit(1);
    1a9e:	4505                	li	a0,1
    1aa0:	00006097          	auipc	ra,0x6
    1aa4:	e08080e7          	jalr	-504(ra) # 78a8 <exit>
  }
  if(pid == 0) {
    1aa8:	fec42783          	lw	a5,-20(s0)
    1aac:	2781                	sext.w	a5,a5
    1aae:	ebd5                	bnez	a5,1b62 <exectest+0x128>
    close(1);
    1ab0:	4505                	li	a0,1
    1ab2:	00006097          	auipc	ra,0x6
    1ab6:	e1e080e7          	jalr	-482(ra) # 78d0 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1aba:	20100593          	li	a1,513
    1abe:	00007517          	auipc	a0,0x7
    1ac2:	ec250513          	addi	a0,a0,-318 # 8980 <malloc+0x99e>
    1ac6:	00006097          	auipc	ra,0x6
    1aca:	e22080e7          	jalr	-478(ra) # 78e8 <open>
    1ace:	87aa                	mv	a5,a0
    1ad0:	fef42423          	sw	a5,-24(s0)
    if(fd < 0) {
    1ad4:	fe842783          	lw	a5,-24(s0)
    1ad8:	2781                	sext.w	a5,a5
    1ada:	0207d163          	bgez	a5,1afc <exectest+0xc2>
      printf("%s: create failed\n", s);
    1ade:	fb843583          	ld	a1,-72(s0)
    1ae2:	00007517          	auipc	a0,0x7
    1ae6:	ea650513          	addi	a0,a0,-346 # 8988 <malloc+0x9a6>
    1aea:	00006097          	auipc	ra,0x6
    1aee:	306080e7          	jalr	774(ra) # 7df0 <printf>
      exit(1);
    1af2:	4505                	li	a0,1
    1af4:	00006097          	auipc	ra,0x6
    1af8:	db4080e7          	jalr	-588(ra) # 78a8 <exit>
    }
    if(fd != 1) {
    1afc:	fe842783          	lw	a5,-24(s0)
    1b00:	0007871b          	sext.w	a4,a5
    1b04:	4785                	li	a5,1
    1b06:	02f70163          	beq	a4,a5,1b28 <exectest+0xee>
      printf("%s: wrong fd\n", s);
    1b0a:	fb843583          	ld	a1,-72(s0)
    1b0e:	00007517          	auipc	a0,0x7
    1b12:	e9250513          	addi	a0,a0,-366 # 89a0 <malloc+0x9be>
    1b16:	00006097          	auipc	ra,0x6
    1b1a:	2da080e7          	jalr	730(ra) # 7df0 <printf>
      exit(1);
    1b1e:	4505                	li	a0,1
    1b20:	00006097          	auipc	ra,0x6
    1b24:	d88080e7          	jalr	-632(ra) # 78a8 <exit>
    }
    if(exec("echo", echoargv) < 0){
    1b28:	fc840793          	addi	a5,s0,-56
    1b2c:	85be                	mv	a1,a5
    1b2e:	00007517          	auipc	a0,0x7
    1b32:	81250513          	addi	a0,a0,-2030 # 8340 <malloc+0x35e>
    1b36:	00006097          	auipc	ra,0x6
    1b3a:	daa080e7          	jalr	-598(ra) # 78e0 <exec>
    1b3e:	87aa                	mv	a5,a0
    1b40:	0207d163          	bgez	a5,1b62 <exectest+0x128>
      printf("%s: exec echo failed\n", s);
    1b44:	fb843583          	ld	a1,-72(s0)
    1b48:	00007517          	auipc	a0,0x7
    1b4c:	e6850513          	addi	a0,a0,-408 # 89b0 <malloc+0x9ce>
    1b50:	00006097          	auipc	ra,0x6
    1b54:	2a0080e7          	jalr	672(ra) # 7df0 <printf>
      exit(1);
    1b58:	4505                	li	a0,1
    1b5a:	00006097          	auipc	ra,0x6
    1b5e:	d4e080e7          	jalr	-690(ra) # 78a8 <exit>
    }
    // won't get to here
  }
  if (wait(&xstatus) != pid) {
    1b62:	fe440793          	addi	a5,s0,-28
    1b66:	853e                	mv	a0,a5
    1b68:	00006097          	auipc	ra,0x6
    1b6c:	d48080e7          	jalr	-696(ra) # 78b0 <wait>
    1b70:	87aa                	mv	a5,a0
    1b72:	873e                	mv	a4,a5
    1b74:	fec42783          	lw	a5,-20(s0)
    1b78:	2781                	sext.w	a5,a5
    1b7a:	00e78c63          	beq	a5,a4,1b92 <exectest+0x158>
    printf("%s: wait failed!\n", s);
    1b7e:	fb843583          	ld	a1,-72(s0)
    1b82:	00007517          	auipc	a0,0x7
    1b86:	e4650513          	addi	a0,a0,-442 # 89c8 <malloc+0x9e6>
    1b8a:	00006097          	auipc	ra,0x6
    1b8e:	266080e7          	jalr	614(ra) # 7df0 <printf>
  }
  if(xstatus != 0)
    1b92:	fe442783          	lw	a5,-28(s0)
    1b96:	cb81                	beqz	a5,1ba6 <exectest+0x16c>
    exit(xstatus);
    1b98:	fe442783          	lw	a5,-28(s0)
    1b9c:	853e                	mv	a0,a5
    1b9e:	00006097          	auipc	ra,0x6
    1ba2:	d0a080e7          	jalr	-758(ra) # 78a8 <exit>

  fd = open("echo-ok", O_RDONLY);
    1ba6:	4581                	li	a1,0
    1ba8:	00007517          	auipc	a0,0x7
    1bac:	dd850513          	addi	a0,a0,-552 # 8980 <malloc+0x99e>
    1bb0:	00006097          	auipc	ra,0x6
    1bb4:	d38080e7          	jalr	-712(ra) # 78e8 <open>
    1bb8:	87aa                	mv	a5,a0
    1bba:	fef42423          	sw	a5,-24(s0)
  if(fd < 0) {
    1bbe:	fe842783          	lw	a5,-24(s0)
    1bc2:	2781                	sext.w	a5,a5
    1bc4:	0207d163          	bgez	a5,1be6 <exectest+0x1ac>
    printf("%s: open failed\n", s);
    1bc8:	fb843583          	ld	a1,-72(s0)
    1bcc:	00007517          	auipc	a0,0x7
    1bd0:	9ac50513          	addi	a0,a0,-1620 # 8578 <malloc+0x596>
    1bd4:	00006097          	auipc	ra,0x6
    1bd8:	21c080e7          	jalr	540(ra) # 7df0 <printf>
    exit(1);
    1bdc:	4505                	li	a0,1
    1bde:	00006097          	auipc	ra,0x6
    1be2:	cca080e7          	jalr	-822(ra) # 78a8 <exit>
  }
  if (read(fd, buf, 2) != 2) {
    1be6:	fc040713          	addi	a4,s0,-64
    1bea:	fe842783          	lw	a5,-24(s0)
    1bee:	4609                	li	a2,2
    1bf0:	85ba                	mv	a1,a4
    1bf2:	853e                	mv	a0,a5
    1bf4:	00006097          	auipc	ra,0x6
    1bf8:	ccc080e7          	jalr	-820(ra) # 78c0 <read>
    1bfc:	87aa                	mv	a5,a0
    1bfe:	873e                	mv	a4,a5
    1c00:	4789                	li	a5,2
    1c02:	02f70163          	beq	a4,a5,1c24 <exectest+0x1ea>
    printf("%s: read failed\n", s);
    1c06:	fb843583          	ld	a1,-72(s0)
    1c0a:	00007517          	auipc	a0,0x7
    1c0e:	bee50513          	addi	a0,a0,-1042 # 87f8 <malloc+0x816>
    1c12:	00006097          	auipc	ra,0x6
    1c16:	1de080e7          	jalr	478(ra) # 7df0 <printf>
    exit(1);
    1c1a:	4505                	li	a0,1
    1c1c:	00006097          	auipc	ra,0x6
    1c20:	c8c080e7          	jalr	-884(ra) # 78a8 <exit>
  }
  unlink("echo-ok");
    1c24:	00007517          	auipc	a0,0x7
    1c28:	d5c50513          	addi	a0,a0,-676 # 8980 <malloc+0x99e>
    1c2c:	00006097          	auipc	ra,0x6
    1c30:	ccc080e7          	jalr	-820(ra) # 78f8 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1c34:	fc044783          	lbu	a5,-64(s0)
    1c38:	873e                	mv	a4,a5
    1c3a:	04f00793          	li	a5,79
    1c3e:	00f71e63          	bne	a4,a5,1c5a <exectest+0x220>
    1c42:	fc144783          	lbu	a5,-63(s0)
    1c46:	873e                	mv	a4,a5
    1c48:	04b00793          	li	a5,75
    1c4c:	00f71763          	bne	a4,a5,1c5a <exectest+0x220>
    exit(0);
    1c50:	4501                	li	a0,0
    1c52:	00006097          	auipc	ra,0x6
    1c56:	c56080e7          	jalr	-938(ra) # 78a8 <exit>
  else {
    printf("%s: wrong output\n", s);
    1c5a:	fb843583          	ld	a1,-72(s0)
    1c5e:	00007517          	auipc	a0,0x7
    1c62:	d8250513          	addi	a0,a0,-638 # 89e0 <malloc+0x9fe>
    1c66:	00006097          	auipc	ra,0x6
    1c6a:	18a080e7          	jalr	394(ra) # 7df0 <printf>
    exit(1);
    1c6e:	4505                	li	a0,1
    1c70:	00006097          	auipc	ra,0x6
    1c74:	c38080e7          	jalr	-968(ra) # 78a8 <exit>

0000000000001c78 <pipe1>:

// simple fork and pipe read/write

void
pipe1(char *s)
{
    1c78:	715d                	addi	sp,sp,-80
    1c7a:	e486                	sd	ra,72(sp)
    1c7c:	e0a2                	sd	s0,64(sp)
    1c7e:	0880                	addi	s0,sp,80
    1c80:	faa43c23          	sd	a0,-72(s0)
  int fds[2], pid, xstatus;
  int seq, i, n, cc, total;
  enum { N=5, SZ=1033 };
  
  if(pipe(fds) != 0){
    1c84:	fd040793          	addi	a5,s0,-48
    1c88:	853e                	mv	a0,a5
    1c8a:	00006097          	auipc	ra,0x6
    1c8e:	c2e080e7          	jalr	-978(ra) # 78b8 <pipe>
    1c92:	87aa                	mv	a5,a0
    1c94:	c385                	beqz	a5,1cb4 <pipe1+0x3c>
    printf("%s: pipe() failed\n", s);
    1c96:	fb843583          	ld	a1,-72(s0)
    1c9a:	00007517          	auipc	a0,0x7
    1c9e:	d5e50513          	addi	a0,a0,-674 # 89f8 <malloc+0xa16>
    1ca2:	00006097          	auipc	ra,0x6
    1ca6:	14e080e7          	jalr	334(ra) # 7df0 <printf>
    exit(1);
    1caa:	4505                	li	a0,1
    1cac:	00006097          	auipc	ra,0x6
    1cb0:	bfc080e7          	jalr	-1028(ra) # 78a8 <exit>
  }
  pid = fork();
    1cb4:	00006097          	auipc	ra,0x6
    1cb8:	bec080e7          	jalr	-1044(ra) # 78a0 <fork>
    1cbc:	87aa                	mv	a5,a0
    1cbe:	fcf42c23          	sw	a5,-40(s0)
  seq = 0;
    1cc2:	fe042623          	sw	zero,-20(s0)
  if(pid == 0){
    1cc6:	fd842783          	lw	a5,-40(s0)
    1cca:	2781                	sext.w	a5,a5
    1ccc:	efdd                	bnez	a5,1d8a <pipe1+0x112>
    close(fds[0]);
    1cce:	fd042783          	lw	a5,-48(s0)
    1cd2:	853e                	mv	a0,a5
    1cd4:	00006097          	auipc	ra,0x6
    1cd8:	bfc080e7          	jalr	-1028(ra) # 78d0 <close>
    for(n = 0; n < N; n++){
    1cdc:	fe042223          	sw	zero,-28(s0)
    1ce0:	a849                	j	1d72 <pipe1+0xfa>
      for(i = 0; i < SZ; i++)
    1ce2:	fe042423          	sw	zero,-24(s0)
    1ce6:	a03d                	j	1d14 <pipe1+0x9c>
        buf[i] = seq++;
    1ce8:	fec42783          	lw	a5,-20(s0)
    1cec:	0017871b          	addiw	a4,a5,1
    1cf0:	fee42623          	sw	a4,-20(s0)
    1cf4:	0ff7f713          	zext.b	a4,a5
    1cf8:	00009697          	auipc	a3,0x9
    1cfc:	77868693          	addi	a3,a3,1912 # b470 <buf>
    1d00:	fe842783          	lw	a5,-24(s0)
    1d04:	97b6                	add	a5,a5,a3
    1d06:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1d0a:	fe842783          	lw	a5,-24(s0)
    1d0e:	2785                	addiw	a5,a5,1
    1d10:	fef42423          	sw	a5,-24(s0)
    1d14:	fe842783          	lw	a5,-24(s0)
    1d18:	0007871b          	sext.w	a4,a5
    1d1c:	40800793          	li	a5,1032
    1d20:	fce7d4e3          	bge	a5,a4,1ce8 <pipe1+0x70>
      if(write(fds[1], buf, SZ) != SZ){
    1d24:	fd442783          	lw	a5,-44(s0)
    1d28:	40900613          	li	a2,1033
    1d2c:	00009597          	auipc	a1,0x9
    1d30:	74458593          	addi	a1,a1,1860 # b470 <buf>
    1d34:	853e                	mv	a0,a5
    1d36:	00006097          	auipc	ra,0x6
    1d3a:	b92080e7          	jalr	-1134(ra) # 78c8 <write>
    1d3e:	87aa                	mv	a5,a0
    1d40:	873e                	mv	a4,a5
    1d42:	40900793          	li	a5,1033
    1d46:	02f70163          	beq	a4,a5,1d68 <pipe1+0xf0>
        printf("%s: pipe1 oops 1\n", s);
    1d4a:	fb843583          	ld	a1,-72(s0)
    1d4e:	00007517          	auipc	a0,0x7
    1d52:	cc250513          	addi	a0,a0,-830 # 8a10 <malloc+0xa2e>
    1d56:	00006097          	auipc	ra,0x6
    1d5a:	09a080e7          	jalr	154(ra) # 7df0 <printf>
        exit(1);
    1d5e:	4505                	li	a0,1
    1d60:	00006097          	auipc	ra,0x6
    1d64:	b48080e7          	jalr	-1208(ra) # 78a8 <exit>
    for(n = 0; n < N; n++){
    1d68:	fe442783          	lw	a5,-28(s0)
    1d6c:	2785                	addiw	a5,a5,1
    1d6e:	fef42223          	sw	a5,-28(s0)
    1d72:	fe442783          	lw	a5,-28(s0)
    1d76:	0007871b          	sext.w	a4,a5
    1d7a:	4791                	li	a5,4
    1d7c:	f6e7d3e3          	bge	a5,a4,1ce2 <pipe1+0x6a>
      }
    }
    exit(0);
    1d80:	4501                	li	a0,0
    1d82:	00006097          	auipc	ra,0x6
    1d86:	b26080e7          	jalr	-1242(ra) # 78a8 <exit>
  } else if(pid > 0){
    1d8a:	fd842783          	lw	a5,-40(s0)
    1d8e:	2781                	sext.w	a5,a5
    1d90:	12f05d63          	blez	a5,1eca <pipe1+0x252>
    close(fds[1]);
    1d94:	fd442783          	lw	a5,-44(s0)
    1d98:	853e                	mv	a0,a5
    1d9a:	00006097          	auipc	ra,0x6
    1d9e:	b36080e7          	jalr	-1226(ra) # 78d0 <close>
    total = 0;
    1da2:	fc042e23          	sw	zero,-36(s0)
    cc = 1;
    1da6:	4785                	li	a5,1
    1da8:	fef42023          	sw	a5,-32(s0)
    while((n = read(fds[0], buf, cc)) > 0){
    1dac:	a859                	j	1e42 <pipe1+0x1ca>
      for(i = 0; i < n; i++){
    1dae:	fe042423          	sw	zero,-24(s0)
    1db2:	a881                	j	1e02 <pipe1+0x18a>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1db4:	00009717          	auipc	a4,0x9
    1db8:	6bc70713          	addi	a4,a4,1724 # b470 <buf>
    1dbc:	fe842783          	lw	a5,-24(s0)
    1dc0:	97ba                	add	a5,a5,a4
    1dc2:	0007c783          	lbu	a5,0(a5)
    1dc6:	0007869b          	sext.w	a3,a5
    1dca:	fec42783          	lw	a5,-20(s0)
    1dce:	0017871b          	addiw	a4,a5,1
    1dd2:	fee42623          	sw	a4,-20(s0)
    1dd6:	0ff7f793          	zext.b	a5,a5
    1dda:	2781                	sext.w	a5,a5
    1ddc:	8736                	mv	a4,a3
    1dde:	00f70d63          	beq	a4,a5,1df8 <pipe1+0x180>
          printf("%s: pipe1 oops 2\n", s);
    1de2:	fb843583          	ld	a1,-72(s0)
    1de6:	00007517          	auipc	a0,0x7
    1dea:	c4250513          	addi	a0,a0,-958 # 8a28 <malloc+0xa46>
    1dee:	00006097          	auipc	ra,0x6
    1df2:	002080e7          	jalr	2(ra) # 7df0 <printf>
          return;
    1df6:	a8cd                	j	1ee8 <pipe1+0x270>
      for(i = 0; i < n; i++){
    1df8:	fe842783          	lw	a5,-24(s0)
    1dfc:	2785                	addiw	a5,a5,1
    1dfe:	fef42423          	sw	a5,-24(s0)
    1e02:	fe842783          	lw	a5,-24(s0)
    1e06:	873e                	mv	a4,a5
    1e08:	fe442783          	lw	a5,-28(s0)
    1e0c:	2701                	sext.w	a4,a4
    1e0e:	2781                	sext.w	a5,a5
    1e10:	faf742e3          	blt	a4,a5,1db4 <pipe1+0x13c>
        }
      }
      total += n;
    1e14:	fdc42783          	lw	a5,-36(s0)
    1e18:	873e                	mv	a4,a5
    1e1a:	fe442783          	lw	a5,-28(s0)
    1e1e:	9fb9                	addw	a5,a5,a4
    1e20:	fcf42e23          	sw	a5,-36(s0)
      cc = cc * 2;
    1e24:	fe042783          	lw	a5,-32(s0)
    1e28:	0017979b          	slliw	a5,a5,0x1
    1e2c:	fef42023          	sw	a5,-32(s0)
      if(cc > sizeof(buf))
    1e30:	fe042783          	lw	a5,-32(s0)
    1e34:	873e                	mv	a4,a5
    1e36:	678d                	lui	a5,0x3
    1e38:	00e7f563          	bgeu	a5,a4,1e42 <pipe1+0x1ca>
        cc = sizeof(buf);
    1e3c:	678d                	lui	a5,0x3
    1e3e:	fef42023          	sw	a5,-32(s0)
    while((n = read(fds[0], buf, cc)) > 0){
    1e42:	fd042783          	lw	a5,-48(s0)
    1e46:	fe042703          	lw	a4,-32(s0)
    1e4a:	863a                	mv	a2,a4
    1e4c:	00009597          	auipc	a1,0x9
    1e50:	62458593          	addi	a1,a1,1572 # b470 <buf>
    1e54:	853e                	mv	a0,a5
    1e56:	00006097          	auipc	ra,0x6
    1e5a:	a6a080e7          	jalr	-1430(ra) # 78c0 <read>
    1e5e:	87aa                	mv	a5,a0
    1e60:	fef42223          	sw	a5,-28(s0)
    1e64:	fe442783          	lw	a5,-28(s0)
    1e68:	2781                	sext.w	a5,a5
    1e6a:	f4f042e3          	bgtz	a5,1dae <pipe1+0x136>
    }
    if(total != N * SZ){
    1e6e:	fdc42783          	lw	a5,-36(s0)
    1e72:	0007871b          	sext.w	a4,a5
    1e76:	6785                	lui	a5,0x1
    1e78:	42d78793          	addi	a5,a5,1069 # 142d <opentest+0x6f>
    1e7c:	02f70263          	beq	a4,a5,1ea0 <pipe1+0x228>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1e80:	fdc42783          	lw	a5,-36(s0)
    1e84:	85be                	mv	a1,a5
    1e86:	00007517          	auipc	a0,0x7
    1e8a:	bba50513          	addi	a0,a0,-1094 # 8a40 <malloc+0xa5e>
    1e8e:	00006097          	auipc	ra,0x6
    1e92:	f62080e7          	jalr	-158(ra) # 7df0 <printf>
      exit(1);
    1e96:	4505                	li	a0,1
    1e98:	00006097          	auipc	ra,0x6
    1e9c:	a10080e7          	jalr	-1520(ra) # 78a8 <exit>
    }
    close(fds[0]);
    1ea0:	fd042783          	lw	a5,-48(s0)
    1ea4:	853e                	mv	a0,a5
    1ea6:	00006097          	auipc	ra,0x6
    1eaa:	a2a080e7          	jalr	-1494(ra) # 78d0 <close>
    wait(&xstatus);
    1eae:	fcc40793          	addi	a5,s0,-52
    1eb2:	853e                	mv	a0,a5
    1eb4:	00006097          	auipc	ra,0x6
    1eb8:	9fc080e7          	jalr	-1540(ra) # 78b0 <wait>
    exit(xstatus);
    1ebc:	fcc42783          	lw	a5,-52(s0)
    1ec0:	853e                	mv	a0,a5
    1ec2:	00006097          	auipc	ra,0x6
    1ec6:	9e6080e7          	jalr	-1562(ra) # 78a8 <exit>
  } else {
    printf("%s: fork() failed\n", s);
    1eca:	fb843583          	ld	a1,-72(s0)
    1ece:	00007517          	auipc	a0,0x7
    1ed2:	b9250513          	addi	a0,a0,-1134 # 8a60 <malloc+0xa7e>
    1ed6:	00006097          	auipc	ra,0x6
    1eda:	f1a080e7          	jalr	-230(ra) # 7df0 <printf>
    exit(1);
    1ede:	4505                	li	a0,1
    1ee0:	00006097          	auipc	ra,0x6
    1ee4:	9c8080e7          	jalr	-1592(ra) # 78a8 <exit>
  }
}
    1ee8:	60a6                	ld	ra,72(sp)
    1eea:	6406                	ld	s0,64(sp)
    1eec:	6161                	addi	sp,sp,80
    1eee:	8082                	ret

0000000000001ef0 <killstatus>:


// test if child is killed (status = -1)
void
killstatus(char *s)
{
    1ef0:	7179                	addi	sp,sp,-48
    1ef2:	f406                	sd	ra,40(sp)
    1ef4:	f022                	sd	s0,32(sp)
    1ef6:	1800                	addi	s0,sp,48
    1ef8:	fca43c23          	sd	a0,-40(s0)
  int xst;
  
  for(int i = 0; i < 100; i++){
    1efc:	fe042623          	sw	zero,-20(s0)
    1f00:	a055                	j	1fa4 <killstatus+0xb4>
    int pid1 = fork();
    1f02:	00006097          	auipc	ra,0x6
    1f06:	99e080e7          	jalr	-1634(ra) # 78a0 <fork>
    1f0a:	87aa                	mv	a5,a0
    1f0c:	fef42423          	sw	a5,-24(s0)
    if(pid1 < 0){
    1f10:	fe842783          	lw	a5,-24(s0)
    1f14:	2781                	sext.w	a5,a5
    1f16:	0207d163          	bgez	a5,1f38 <killstatus+0x48>
      printf("%s: fork failed\n", s);
    1f1a:	fd843583          	ld	a1,-40(s0)
    1f1e:	00006517          	auipc	a0,0x6
    1f22:	64250513          	addi	a0,a0,1602 # 8560 <malloc+0x57e>
    1f26:	00006097          	auipc	ra,0x6
    1f2a:	eca080e7          	jalr	-310(ra) # 7df0 <printf>
      exit(1);
    1f2e:	4505                	li	a0,1
    1f30:	00006097          	auipc	ra,0x6
    1f34:	978080e7          	jalr	-1672(ra) # 78a8 <exit>
    }
    if(pid1 == 0){
    1f38:	fe842783          	lw	a5,-24(s0)
    1f3c:	2781                	sext.w	a5,a5
    1f3e:	e791                	bnez	a5,1f4a <killstatus+0x5a>
      while(1) {
        getpid();
    1f40:	00006097          	auipc	ra,0x6
    1f44:	9e8080e7          	jalr	-1560(ra) # 7928 <getpid>
    1f48:	bfe5                	j	1f40 <killstatus+0x50>
      }
      exit(0);
    }
    sleep(1);
    1f4a:	4505                	li	a0,1
    1f4c:	00006097          	auipc	ra,0x6
    1f50:	9ec080e7          	jalr	-1556(ra) # 7938 <sleep>
    kill(pid1);
    1f54:	fe842783          	lw	a5,-24(s0)
    1f58:	853e                	mv	a0,a5
    1f5a:	00006097          	auipc	ra,0x6
    1f5e:	97e080e7          	jalr	-1666(ra) # 78d8 <kill>
    wait(&xst);
    1f62:	fe440793          	addi	a5,s0,-28
    1f66:	853e                	mv	a0,a5
    1f68:	00006097          	auipc	ra,0x6
    1f6c:	948080e7          	jalr	-1720(ra) # 78b0 <wait>
    if(xst != -1) {
    1f70:	fe442783          	lw	a5,-28(s0)
    1f74:	873e                	mv	a4,a5
    1f76:	57fd                	li	a5,-1
    1f78:	02f70163          	beq	a4,a5,1f9a <killstatus+0xaa>
       printf("%s: status should be -1\n", s);
    1f7c:	fd843583          	ld	a1,-40(s0)
    1f80:	00007517          	auipc	a0,0x7
    1f84:	af850513          	addi	a0,a0,-1288 # 8a78 <malloc+0xa96>
    1f88:	00006097          	auipc	ra,0x6
    1f8c:	e68080e7          	jalr	-408(ra) # 7df0 <printf>
       exit(1);
    1f90:	4505                	li	a0,1
    1f92:	00006097          	auipc	ra,0x6
    1f96:	916080e7          	jalr	-1770(ra) # 78a8 <exit>
  for(int i = 0; i < 100; i++){
    1f9a:	fec42783          	lw	a5,-20(s0)
    1f9e:	2785                	addiw	a5,a5,1
    1fa0:	fef42623          	sw	a5,-20(s0)
    1fa4:	fec42783          	lw	a5,-20(s0)
    1fa8:	0007871b          	sext.w	a4,a5
    1fac:	06300793          	li	a5,99
    1fb0:	f4e7d9e3          	bge	a5,a4,1f02 <killstatus+0x12>
    }
  }
  exit(0);
    1fb4:	4501                	li	a0,0
    1fb6:	00006097          	auipc	ra,0x6
    1fba:	8f2080e7          	jalr	-1806(ra) # 78a8 <exit>

0000000000001fbe <preempt>:
}

// meant to be run w/ at most two CPUs
void
preempt(char *s)
{
    1fbe:	7139                	addi	sp,sp,-64
    1fc0:	fc06                	sd	ra,56(sp)
    1fc2:	f822                	sd	s0,48(sp)
    1fc4:	0080                	addi	s0,sp,64
    1fc6:	fca43423          	sd	a0,-56(s0)
  int pid1, pid2, pid3;
  int pfds[2];

  pid1 = fork();
    1fca:	00006097          	auipc	ra,0x6
    1fce:	8d6080e7          	jalr	-1834(ra) # 78a0 <fork>
    1fd2:	87aa                	mv	a5,a0
    1fd4:	fef42623          	sw	a5,-20(s0)
  if(pid1 < 0) {
    1fd8:	fec42783          	lw	a5,-20(s0)
    1fdc:	2781                	sext.w	a5,a5
    1fde:	0207d163          	bgez	a5,2000 <preempt+0x42>
    printf("%s: fork failed", s);
    1fe2:	fc843583          	ld	a1,-56(s0)
    1fe6:	00007517          	auipc	a0,0x7
    1fea:	ab250513          	addi	a0,a0,-1358 # 8a98 <malloc+0xab6>
    1fee:	00006097          	auipc	ra,0x6
    1ff2:	e02080e7          	jalr	-510(ra) # 7df0 <printf>
    exit(1);
    1ff6:	4505                	li	a0,1
    1ff8:	00006097          	auipc	ra,0x6
    1ffc:	8b0080e7          	jalr	-1872(ra) # 78a8 <exit>
  }
  if(pid1 == 0)
    2000:	fec42783          	lw	a5,-20(s0)
    2004:	2781                	sext.w	a5,a5
    2006:	e391                	bnez	a5,200a <preempt+0x4c>
    for(;;)
    2008:	a001                	j	2008 <preempt+0x4a>
      ;

  pid2 = fork();
    200a:	00006097          	auipc	ra,0x6
    200e:	896080e7          	jalr	-1898(ra) # 78a0 <fork>
    2012:	87aa                	mv	a5,a0
    2014:	fef42423          	sw	a5,-24(s0)
  if(pid2 < 0) {
    2018:	fe842783          	lw	a5,-24(s0)
    201c:	2781                	sext.w	a5,a5
    201e:	0207d163          	bgez	a5,2040 <preempt+0x82>
    printf("%s: fork failed\n", s);
    2022:	fc843583          	ld	a1,-56(s0)
    2026:	00006517          	auipc	a0,0x6
    202a:	53a50513          	addi	a0,a0,1338 # 8560 <malloc+0x57e>
    202e:	00006097          	auipc	ra,0x6
    2032:	dc2080e7          	jalr	-574(ra) # 7df0 <printf>
    exit(1);
    2036:	4505                	li	a0,1
    2038:	00006097          	auipc	ra,0x6
    203c:	870080e7          	jalr	-1936(ra) # 78a8 <exit>
  }
  if(pid2 == 0)
    2040:	fe842783          	lw	a5,-24(s0)
    2044:	2781                	sext.w	a5,a5
    2046:	e391                	bnez	a5,204a <preempt+0x8c>
    for(;;)
    2048:	a001                	j	2048 <preempt+0x8a>
      ;

  pipe(pfds);
    204a:	fd840793          	addi	a5,s0,-40
    204e:	853e                	mv	a0,a5
    2050:	00006097          	auipc	ra,0x6
    2054:	868080e7          	jalr	-1944(ra) # 78b8 <pipe>
  pid3 = fork();
    2058:	00006097          	auipc	ra,0x6
    205c:	848080e7          	jalr	-1976(ra) # 78a0 <fork>
    2060:	87aa                	mv	a5,a0
    2062:	fef42223          	sw	a5,-28(s0)
  if(pid3 < 0) {
    2066:	fe442783          	lw	a5,-28(s0)
    206a:	2781                	sext.w	a5,a5
    206c:	0207d163          	bgez	a5,208e <preempt+0xd0>
     printf("%s: fork failed\n", s);
    2070:	fc843583          	ld	a1,-56(s0)
    2074:	00006517          	auipc	a0,0x6
    2078:	4ec50513          	addi	a0,a0,1260 # 8560 <malloc+0x57e>
    207c:	00006097          	auipc	ra,0x6
    2080:	d74080e7          	jalr	-652(ra) # 7df0 <printf>
     exit(1);
    2084:	4505                	li	a0,1
    2086:	00006097          	auipc	ra,0x6
    208a:	822080e7          	jalr	-2014(ra) # 78a8 <exit>
  }
  if(pid3 == 0){
    208e:	fe442783          	lw	a5,-28(s0)
    2092:	2781                	sext.w	a5,a5
    2094:	ebb9                	bnez	a5,20ea <preempt+0x12c>
    close(pfds[0]);
    2096:	fd842783          	lw	a5,-40(s0)
    209a:	853e                	mv	a0,a5
    209c:	00006097          	auipc	ra,0x6
    20a0:	834080e7          	jalr	-1996(ra) # 78d0 <close>
    if(write(pfds[1], "x", 1) != 1)
    20a4:	fdc42783          	lw	a5,-36(s0)
    20a8:	4605                	li	a2,1
    20aa:	00006597          	auipc	a1,0x6
    20ae:	18658593          	addi	a1,a1,390 # 8230 <malloc+0x24e>
    20b2:	853e                	mv	a0,a5
    20b4:	00006097          	auipc	ra,0x6
    20b8:	814080e7          	jalr	-2028(ra) # 78c8 <write>
    20bc:	87aa                	mv	a5,a0
    20be:	873e                	mv	a4,a5
    20c0:	4785                	li	a5,1
    20c2:	00f70c63          	beq	a4,a5,20da <preempt+0x11c>
      printf("%s: preempt write error", s);
    20c6:	fc843583          	ld	a1,-56(s0)
    20ca:	00007517          	auipc	a0,0x7
    20ce:	9de50513          	addi	a0,a0,-1570 # 8aa8 <malloc+0xac6>
    20d2:	00006097          	auipc	ra,0x6
    20d6:	d1e080e7          	jalr	-738(ra) # 7df0 <printf>
    close(pfds[1]);
    20da:	fdc42783          	lw	a5,-36(s0)
    20de:	853e                	mv	a0,a5
    20e0:	00005097          	auipc	ra,0x5
    20e4:	7f0080e7          	jalr	2032(ra) # 78d0 <close>
    for(;;)
    20e8:	a001                	j	20e8 <preempt+0x12a>
      ;
  }

  close(pfds[1]);
    20ea:	fdc42783          	lw	a5,-36(s0)
    20ee:	853e                	mv	a0,a5
    20f0:	00005097          	auipc	ra,0x5
    20f4:	7e0080e7          	jalr	2016(ra) # 78d0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    20f8:	fd842783          	lw	a5,-40(s0)
    20fc:	660d                	lui	a2,0x3
    20fe:	00009597          	auipc	a1,0x9
    2102:	37258593          	addi	a1,a1,882 # b470 <buf>
    2106:	853e                	mv	a0,a5
    2108:	00005097          	auipc	ra,0x5
    210c:	7b8080e7          	jalr	1976(ra) # 78c0 <read>
    2110:	87aa                	mv	a5,a0
    2112:	873e                	mv	a4,a5
    2114:	4785                	li	a5,1
    2116:	00f70d63          	beq	a4,a5,2130 <preempt+0x172>
    printf("%s: preempt read error", s);
    211a:	fc843583          	ld	a1,-56(s0)
    211e:	00007517          	auipc	a0,0x7
    2122:	9a250513          	addi	a0,a0,-1630 # 8ac0 <malloc+0xade>
    2126:	00006097          	auipc	ra,0x6
    212a:	cca080e7          	jalr	-822(ra) # 7df0 <printf>
    212e:	a8a5                	j	21a6 <preempt+0x1e8>
    return;
  }
  close(pfds[0]);
    2130:	fd842783          	lw	a5,-40(s0)
    2134:	853e                	mv	a0,a5
    2136:	00005097          	auipc	ra,0x5
    213a:	79a080e7          	jalr	1946(ra) # 78d0 <close>
  printf("kill... ");
    213e:	00007517          	auipc	a0,0x7
    2142:	99a50513          	addi	a0,a0,-1638 # 8ad8 <malloc+0xaf6>
    2146:	00006097          	auipc	ra,0x6
    214a:	caa080e7          	jalr	-854(ra) # 7df0 <printf>
  kill(pid1);
    214e:	fec42783          	lw	a5,-20(s0)
    2152:	853e                	mv	a0,a5
    2154:	00005097          	auipc	ra,0x5
    2158:	784080e7          	jalr	1924(ra) # 78d8 <kill>
  kill(pid2);
    215c:	fe842783          	lw	a5,-24(s0)
    2160:	853e                	mv	a0,a5
    2162:	00005097          	auipc	ra,0x5
    2166:	776080e7          	jalr	1910(ra) # 78d8 <kill>
  kill(pid3);
    216a:	fe442783          	lw	a5,-28(s0)
    216e:	853e                	mv	a0,a5
    2170:	00005097          	auipc	ra,0x5
    2174:	768080e7          	jalr	1896(ra) # 78d8 <kill>
  printf("wait... ");
    2178:	00007517          	auipc	a0,0x7
    217c:	97050513          	addi	a0,a0,-1680 # 8ae8 <malloc+0xb06>
    2180:	00006097          	auipc	ra,0x6
    2184:	c70080e7          	jalr	-912(ra) # 7df0 <printf>
  wait(0);
    2188:	4501                	li	a0,0
    218a:	00005097          	auipc	ra,0x5
    218e:	726080e7          	jalr	1830(ra) # 78b0 <wait>
  wait(0);
    2192:	4501                	li	a0,0
    2194:	00005097          	auipc	ra,0x5
    2198:	71c080e7          	jalr	1820(ra) # 78b0 <wait>
  wait(0);
    219c:	4501                	li	a0,0
    219e:	00005097          	auipc	ra,0x5
    21a2:	712080e7          	jalr	1810(ra) # 78b0 <wait>
}
    21a6:	70e2                	ld	ra,56(sp)
    21a8:	7442                	ld	s0,48(sp)
    21aa:	6121                	addi	sp,sp,64
    21ac:	8082                	ret

00000000000021ae <exitwait>:

// try to find any races between exit and wait
void
exitwait(char *s)
{
    21ae:	7179                	addi	sp,sp,-48
    21b0:	f406                	sd	ra,40(sp)
    21b2:	f022                	sd	s0,32(sp)
    21b4:	1800                	addi	s0,sp,48
    21b6:	fca43c23          	sd	a0,-40(s0)
  int i, pid;

  for(i = 0; i < 100; i++){
    21ba:	fe042623          	sw	zero,-20(s0)
    21be:	a87d                	j	227c <exitwait+0xce>
    pid = fork();
    21c0:	00005097          	auipc	ra,0x5
    21c4:	6e0080e7          	jalr	1760(ra) # 78a0 <fork>
    21c8:	87aa                	mv	a5,a0
    21ca:	fef42423          	sw	a5,-24(s0)
    if(pid < 0){
    21ce:	fe842783          	lw	a5,-24(s0)
    21d2:	2781                	sext.w	a5,a5
    21d4:	0207d163          	bgez	a5,21f6 <exitwait+0x48>
      printf("%s: fork failed\n", s);
    21d8:	fd843583          	ld	a1,-40(s0)
    21dc:	00006517          	auipc	a0,0x6
    21e0:	38450513          	addi	a0,a0,900 # 8560 <malloc+0x57e>
    21e4:	00006097          	auipc	ra,0x6
    21e8:	c0c080e7          	jalr	-1012(ra) # 7df0 <printf>
      exit(1);
    21ec:	4505                	li	a0,1
    21ee:	00005097          	auipc	ra,0x5
    21f2:	6ba080e7          	jalr	1722(ra) # 78a8 <exit>
    }
    if(pid){
    21f6:	fe842783          	lw	a5,-24(s0)
    21fa:	2781                	sext.w	a5,a5
    21fc:	c7a5                	beqz	a5,2264 <exitwait+0xb6>
      int xstate;
      if(wait(&xstate) != pid){
    21fe:	fe440793          	addi	a5,s0,-28
    2202:	853e                	mv	a0,a5
    2204:	00005097          	auipc	ra,0x5
    2208:	6ac080e7          	jalr	1708(ra) # 78b0 <wait>
    220c:	87aa                	mv	a5,a0
    220e:	873e                	mv	a4,a5
    2210:	fe842783          	lw	a5,-24(s0)
    2214:	2781                	sext.w	a5,a5
    2216:	02e78163          	beq	a5,a4,2238 <exitwait+0x8a>
        printf("%s: wait wrong pid\n", s);
    221a:	fd843583          	ld	a1,-40(s0)
    221e:	00007517          	auipc	a0,0x7
    2222:	8da50513          	addi	a0,a0,-1830 # 8af8 <malloc+0xb16>
    2226:	00006097          	auipc	ra,0x6
    222a:	bca080e7          	jalr	-1078(ra) # 7df0 <printf>
        exit(1);
    222e:	4505                	li	a0,1
    2230:	00005097          	auipc	ra,0x5
    2234:	678080e7          	jalr	1656(ra) # 78a8 <exit>
      }
      if(i != xstate) {
    2238:	fe442703          	lw	a4,-28(s0)
    223c:	fec42783          	lw	a5,-20(s0)
    2240:	2781                	sext.w	a5,a5
    2242:	02e78863          	beq	a5,a4,2272 <exitwait+0xc4>
        printf("%s: wait wrong exit status\n", s);
    2246:	fd843583          	ld	a1,-40(s0)
    224a:	00007517          	auipc	a0,0x7
    224e:	8c650513          	addi	a0,a0,-1850 # 8b10 <malloc+0xb2e>
    2252:	00006097          	auipc	ra,0x6
    2256:	b9e080e7          	jalr	-1122(ra) # 7df0 <printf>
        exit(1);
    225a:	4505                	li	a0,1
    225c:	00005097          	auipc	ra,0x5
    2260:	64c080e7          	jalr	1612(ra) # 78a8 <exit>
      }
    } else {
      exit(i);
    2264:	fec42783          	lw	a5,-20(s0)
    2268:	853e                	mv	a0,a5
    226a:	00005097          	auipc	ra,0x5
    226e:	63e080e7          	jalr	1598(ra) # 78a8 <exit>
  for(i = 0; i < 100; i++){
    2272:	fec42783          	lw	a5,-20(s0)
    2276:	2785                	addiw	a5,a5,1
    2278:	fef42623          	sw	a5,-20(s0)
    227c:	fec42783          	lw	a5,-20(s0)
    2280:	0007871b          	sext.w	a4,a5
    2284:	06300793          	li	a5,99
    2288:	f2e7dce3          	bge	a5,a4,21c0 <exitwait+0x12>
    }
  }
}
    228c:	0001                	nop
    228e:	0001                	nop
    2290:	70a2                	ld	ra,40(sp)
    2292:	7402                	ld	s0,32(sp)
    2294:	6145                	addi	sp,sp,48
    2296:	8082                	ret

0000000000002298 <reparent>:
// try to find races in the reparenting
// code that handles a parent exiting
// when it still has live children.
void
reparent(char *s)
{
    2298:	7179                	addi	sp,sp,-48
    229a:	f406                	sd	ra,40(sp)
    229c:	f022                	sd	s0,32(sp)
    229e:	1800                	addi	s0,sp,48
    22a0:	fca43c23          	sd	a0,-40(s0)
  int master_pid = getpid();
    22a4:	00005097          	auipc	ra,0x5
    22a8:	684080e7          	jalr	1668(ra) # 7928 <getpid>
    22ac:	87aa                	mv	a5,a0
    22ae:	fef42423          	sw	a5,-24(s0)
  for(int i = 0; i < 200; i++){
    22b2:	fe042623          	sw	zero,-20(s0)
    22b6:	a86d                	j	2370 <reparent+0xd8>
    int pid = fork();
    22b8:	00005097          	auipc	ra,0x5
    22bc:	5e8080e7          	jalr	1512(ra) # 78a0 <fork>
    22c0:	87aa                	mv	a5,a0
    22c2:	fef42223          	sw	a5,-28(s0)
    if(pid < 0){
    22c6:	fe442783          	lw	a5,-28(s0)
    22ca:	2781                	sext.w	a5,a5
    22cc:	0207d163          	bgez	a5,22ee <reparent+0x56>
      printf("%s: fork failed\n", s);
    22d0:	fd843583          	ld	a1,-40(s0)
    22d4:	00006517          	auipc	a0,0x6
    22d8:	28c50513          	addi	a0,a0,652 # 8560 <malloc+0x57e>
    22dc:	00006097          	auipc	ra,0x6
    22e0:	b14080e7          	jalr	-1260(ra) # 7df0 <printf>
      exit(1);
    22e4:	4505                	li	a0,1
    22e6:	00005097          	auipc	ra,0x5
    22ea:	5c2080e7          	jalr	1474(ra) # 78a8 <exit>
    }
    if(pid){
    22ee:	fe442783          	lw	a5,-28(s0)
    22f2:	2781                	sext.w	a5,a5
    22f4:	cf85                	beqz	a5,232c <reparent+0x94>
      if(wait(0) != pid){
    22f6:	4501                	li	a0,0
    22f8:	00005097          	auipc	ra,0x5
    22fc:	5b8080e7          	jalr	1464(ra) # 78b0 <wait>
    2300:	87aa                	mv	a5,a0
    2302:	873e                	mv	a4,a5
    2304:	fe442783          	lw	a5,-28(s0)
    2308:	2781                	sext.w	a5,a5
    230a:	04e78e63          	beq	a5,a4,2366 <reparent+0xce>
        printf("%s: wait wrong pid\n", s);
    230e:	fd843583          	ld	a1,-40(s0)
    2312:	00006517          	auipc	a0,0x6
    2316:	7e650513          	addi	a0,a0,2022 # 8af8 <malloc+0xb16>
    231a:	00006097          	auipc	ra,0x6
    231e:	ad6080e7          	jalr	-1322(ra) # 7df0 <printf>
        exit(1);
    2322:	4505                	li	a0,1
    2324:	00005097          	auipc	ra,0x5
    2328:	584080e7          	jalr	1412(ra) # 78a8 <exit>
      }
    } else {
      int pid2 = fork();
    232c:	00005097          	auipc	ra,0x5
    2330:	574080e7          	jalr	1396(ra) # 78a0 <fork>
    2334:	87aa                	mv	a5,a0
    2336:	fef42023          	sw	a5,-32(s0)
      if(pid2 < 0){
    233a:	fe042783          	lw	a5,-32(s0)
    233e:	2781                	sext.w	a5,a5
    2340:	0007de63          	bgez	a5,235c <reparent+0xc4>
        kill(master_pid);
    2344:	fe842783          	lw	a5,-24(s0)
    2348:	853e                	mv	a0,a5
    234a:	00005097          	auipc	ra,0x5
    234e:	58e080e7          	jalr	1422(ra) # 78d8 <kill>
        exit(1);
    2352:	4505                	li	a0,1
    2354:	00005097          	auipc	ra,0x5
    2358:	554080e7          	jalr	1364(ra) # 78a8 <exit>
      }
      exit(0);
    235c:	4501                	li	a0,0
    235e:	00005097          	auipc	ra,0x5
    2362:	54a080e7          	jalr	1354(ra) # 78a8 <exit>
  for(int i = 0; i < 200; i++){
    2366:	fec42783          	lw	a5,-20(s0)
    236a:	2785                	addiw	a5,a5,1
    236c:	fef42623          	sw	a5,-20(s0)
    2370:	fec42783          	lw	a5,-20(s0)
    2374:	0007871b          	sext.w	a4,a5
    2378:	0c700793          	li	a5,199
    237c:	f2e7dee3          	bge	a5,a4,22b8 <reparent+0x20>
    }
  }
  exit(0);
    2380:	4501                	li	a0,0
    2382:	00005097          	auipc	ra,0x5
    2386:	526080e7          	jalr	1318(ra) # 78a8 <exit>

000000000000238a <twochildren>:
}

// what if two children exit() at the same time?
void
twochildren(char *s)
{
    238a:	7179                	addi	sp,sp,-48
    238c:	f406                	sd	ra,40(sp)
    238e:	f022                	sd	s0,32(sp)
    2390:	1800                	addi	s0,sp,48
    2392:	fca43c23          	sd	a0,-40(s0)
  for(int i = 0; i < 1000; i++){
    2396:	fe042623          	sw	zero,-20(s0)
    239a:	a845                	j	244a <twochildren+0xc0>
    int pid1 = fork();
    239c:	00005097          	auipc	ra,0x5
    23a0:	504080e7          	jalr	1284(ra) # 78a0 <fork>
    23a4:	87aa                	mv	a5,a0
    23a6:	fef42423          	sw	a5,-24(s0)
    if(pid1 < 0){
    23aa:	fe842783          	lw	a5,-24(s0)
    23ae:	2781                	sext.w	a5,a5
    23b0:	0207d163          	bgez	a5,23d2 <twochildren+0x48>
      printf("%s: fork failed\n", s);
    23b4:	fd843583          	ld	a1,-40(s0)
    23b8:	00006517          	auipc	a0,0x6
    23bc:	1a850513          	addi	a0,a0,424 # 8560 <malloc+0x57e>
    23c0:	00006097          	auipc	ra,0x6
    23c4:	a30080e7          	jalr	-1488(ra) # 7df0 <printf>
      exit(1);
    23c8:	4505                	li	a0,1
    23ca:	00005097          	auipc	ra,0x5
    23ce:	4de080e7          	jalr	1246(ra) # 78a8 <exit>
    }
    if(pid1 == 0){
    23d2:	fe842783          	lw	a5,-24(s0)
    23d6:	2781                	sext.w	a5,a5
    23d8:	e791                	bnez	a5,23e4 <twochildren+0x5a>
      exit(0);
    23da:	4501                	li	a0,0
    23dc:	00005097          	auipc	ra,0x5
    23e0:	4cc080e7          	jalr	1228(ra) # 78a8 <exit>
    } else {
      int pid2 = fork();
    23e4:	00005097          	auipc	ra,0x5
    23e8:	4bc080e7          	jalr	1212(ra) # 78a0 <fork>
    23ec:	87aa                	mv	a5,a0
    23ee:	fef42223          	sw	a5,-28(s0)
      if(pid2 < 0){
    23f2:	fe442783          	lw	a5,-28(s0)
    23f6:	2781                	sext.w	a5,a5
    23f8:	0207d163          	bgez	a5,241a <twochildren+0x90>
        printf("%s: fork failed\n", s);
    23fc:	fd843583          	ld	a1,-40(s0)
    2400:	00006517          	auipc	a0,0x6
    2404:	16050513          	addi	a0,a0,352 # 8560 <malloc+0x57e>
    2408:	00006097          	auipc	ra,0x6
    240c:	9e8080e7          	jalr	-1560(ra) # 7df0 <printf>
        exit(1);
    2410:	4505                	li	a0,1
    2412:	00005097          	auipc	ra,0x5
    2416:	496080e7          	jalr	1174(ra) # 78a8 <exit>
      }
      if(pid2 == 0){
    241a:	fe442783          	lw	a5,-28(s0)
    241e:	2781                	sext.w	a5,a5
    2420:	e791                	bnez	a5,242c <twochildren+0xa2>
        exit(0);
    2422:	4501                	li	a0,0
    2424:	00005097          	auipc	ra,0x5
    2428:	484080e7          	jalr	1156(ra) # 78a8 <exit>
      } else {
        wait(0);
    242c:	4501                	li	a0,0
    242e:	00005097          	auipc	ra,0x5
    2432:	482080e7          	jalr	1154(ra) # 78b0 <wait>
        wait(0);
    2436:	4501                	li	a0,0
    2438:	00005097          	auipc	ra,0x5
    243c:	478080e7          	jalr	1144(ra) # 78b0 <wait>
  for(int i = 0; i < 1000; i++){
    2440:	fec42783          	lw	a5,-20(s0)
    2444:	2785                	addiw	a5,a5,1
    2446:	fef42623          	sw	a5,-20(s0)
    244a:	fec42783          	lw	a5,-20(s0)
    244e:	0007871b          	sext.w	a4,a5
    2452:	3e700793          	li	a5,999
    2456:	f4e7d3e3          	bge	a5,a4,239c <twochildren+0x12>
      }
    }
  }
}
    245a:	0001                	nop
    245c:	0001                	nop
    245e:	70a2                	ld	ra,40(sp)
    2460:	7402                	ld	s0,32(sp)
    2462:	6145                	addi	sp,sp,48
    2464:	8082                	ret

0000000000002466 <forkfork>:

// concurrent forks to try to expose locking bugs.
void
forkfork(char *s)
{
    2466:	7139                	addi	sp,sp,-64
    2468:	fc06                	sd	ra,56(sp)
    246a:	f822                	sd	s0,48(sp)
    246c:	0080                	addi	s0,sp,64
    246e:	fca43423          	sd	a0,-56(s0)
  enum { N=2 };
  
  for(int i = 0; i < N; i++){
    2472:	fe042623          	sw	zero,-20(s0)
    2476:	a84d                	j	2528 <forkfork+0xc2>
    int pid = fork();
    2478:	00005097          	auipc	ra,0x5
    247c:	428080e7          	jalr	1064(ra) # 78a0 <fork>
    2480:	87aa                	mv	a5,a0
    2482:	fef42023          	sw	a5,-32(s0)
    if(pid < 0){
    2486:	fe042783          	lw	a5,-32(s0)
    248a:	2781                	sext.w	a5,a5
    248c:	0207d163          	bgez	a5,24ae <forkfork+0x48>
      printf("%s: fork failed", s);
    2490:	fc843583          	ld	a1,-56(s0)
    2494:	00006517          	auipc	a0,0x6
    2498:	60450513          	addi	a0,a0,1540 # 8a98 <malloc+0xab6>
    249c:	00006097          	auipc	ra,0x6
    24a0:	954080e7          	jalr	-1708(ra) # 7df0 <printf>
      exit(1);
    24a4:	4505                	li	a0,1
    24a6:	00005097          	auipc	ra,0x5
    24aa:	402080e7          	jalr	1026(ra) # 78a8 <exit>
    }
    if(pid == 0){
    24ae:	fe042783          	lw	a5,-32(s0)
    24b2:	2781                	sext.w	a5,a5
    24b4:	e7ad                	bnez	a5,251e <forkfork+0xb8>
      for(int j = 0; j < 200; j++){
    24b6:	fe042423          	sw	zero,-24(s0)
    24ba:	a0a9                	j	2504 <forkfork+0x9e>
        int pid1 = fork();
    24bc:	00005097          	auipc	ra,0x5
    24c0:	3e4080e7          	jalr	996(ra) # 78a0 <fork>
    24c4:	87aa                	mv	a5,a0
    24c6:	fcf42e23          	sw	a5,-36(s0)
        if(pid1 < 0){
    24ca:	fdc42783          	lw	a5,-36(s0)
    24ce:	2781                	sext.w	a5,a5
    24d0:	0007d763          	bgez	a5,24de <forkfork+0x78>
          exit(1);
    24d4:	4505                	li	a0,1
    24d6:	00005097          	auipc	ra,0x5
    24da:	3d2080e7          	jalr	978(ra) # 78a8 <exit>
        }
        if(pid1 == 0){
    24de:	fdc42783          	lw	a5,-36(s0)
    24e2:	2781                	sext.w	a5,a5
    24e4:	e791                	bnez	a5,24f0 <forkfork+0x8a>
          exit(0);
    24e6:	4501                	li	a0,0
    24e8:	00005097          	auipc	ra,0x5
    24ec:	3c0080e7          	jalr	960(ra) # 78a8 <exit>
        }
        wait(0);
    24f0:	4501                	li	a0,0
    24f2:	00005097          	auipc	ra,0x5
    24f6:	3be080e7          	jalr	958(ra) # 78b0 <wait>
      for(int j = 0; j < 200; j++){
    24fa:	fe842783          	lw	a5,-24(s0)
    24fe:	2785                	addiw	a5,a5,1
    2500:	fef42423          	sw	a5,-24(s0)
    2504:	fe842783          	lw	a5,-24(s0)
    2508:	0007871b          	sext.w	a4,a5
    250c:	0c700793          	li	a5,199
    2510:	fae7d6e3          	bge	a5,a4,24bc <forkfork+0x56>
      }
      exit(0);
    2514:	4501                	li	a0,0
    2516:	00005097          	auipc	ra,0x5
    251a:	392080e7          	jalr	914(ra) # 78a8 <exit>
  for(int i = 0; i < N; i++){
    251e:	fec42783          	lw	a5,-20(s0)
    2522:	2785                	addiw	a5,a5,1
    2524:	fef42623          	sw	a5,-20(s0)
    2528:	fec42783          	lw	a5,-20(s0)
    252c:	0007871b          	sext.w	a4,a5
    2530:	4785                	li	a5,1
    2532:	f4e7d3e3          	bge	a5,a4,2478 <forkfork+0x12>
    }
  }

  int xstatus;
  for(int i = 0; i < N; i++){
    2536:	fe042223          	sw	zero,-28(s0)
    253a:	a83d                	j	2578 <forkfork+0x112>
    wait(&xstatus);
    253c:	fd840793          	addi	a5,s0,-40
    2540:	853e                	mv	a0,a5
    2542:	00005097          	auipc	ra,0x5
    2546:	36e080e7          	jalr	878(ra) # 78b0 <wait>
    if(xstatus != 0) {
    254a:	fd842783          	lw	a5,-40(s0)
    254e:	c385                	beqz	a5,256e <forkfork+0x108>
      printf("%s: fork in child failed", s);
    2550:	fc843583          	ld	a1,-56(s0)
    2554:	00006517          	auipc	a0,0x6
    2558:	5dc50513          	addi	a0,a0,1500 # 8b30 <malloc+0xb4e>
    255c:	00006097          	auipc	ra,0x6
    2560:	894080e7          	jalr	-1900(ra) # 7df0 <printf>
      exit(1);
    2564:	4505                	li	a0,1
    2566:	00005097          	auipc	ra,0x5
    256a:	342080e7          	jalr	834(ra) # 78a8 <exit>
  for(int i = 0; i < N; i++){
    256e:	fe442783          	lw	a5,-28(s0)
    2572:	2785                	addiw	a5,a5,1
    2574:	fef42223          	sw	a5,-28(s0)
    2578:	fe442783          	lw	a5,-28(s0)
    257c:	0007871b          	sext.w	a4,a5
    2580:	4785                	li	a5,1
    2582:	fae7dde3          	bge	a5,a4,253c <forkfork+0xd6>
    }
  }
}
    2586:	0001                	nop
    2588:	0001                	nop
    258a:	70e2                	ld	ra,56(sp)
    258c:	7442                	ld	s0,48(sp)
    258e:	6121                	addi	sp,sp,64
    2590:	8082                	ret

0000000000002592 <forkforkfork>:

void
forkforkfork(char *s)
{
    2592:	7179                	addi	sp,sp,-48
    2594:	f406                	sd	ra,40(sp)
    2596:	f022                	sd	s0,32(sp)
    2598:	1800                	addi	s0,sp,48
    259a:	fca43c23          	sd	a0,-40(s0)
  unlink("stopforking");
    259e:	00006517          	auipc	a0,0x6
    25a2:	5b250513          	addi	a0,a0,1458 # 8b50 <malloc+0xb6e>
    25a6:	00005097          	auipc	ra,0x5
    25aa:	352080e7          	jalr	850(ra) # 78f8 <unlink>

  int pid = fork();
    25ae:	00005097          	auipc	ra,0x5
    25b2:	2f2080e7          	jalr	754(ra) # 78a0 <fork>
    25b6:	87aa                	mv	a5,a0
    25b8:	fef42623          	sw	a5,-20(s0)
  if(pid < 0){
    25bc:	fec42783          	lw	a5,-20(s0)
    25c0:	2781                	sext.w	a5,a5
    25c2:	0207d163          	bgez	a5,25e4 <forkforkfork+0x52>
    printf("%s: fork failed", s);
    25c6:	fd843583          	ld	a1,-40(s0)
    25ca:	00006517          	auipc	a0,0x6
    25ce:	4ce50513          	addi	a0,a0,1230 # 8a98 <malloc+0xab6>
    25d2:	00006097          	auipc	ra,0x6
    25d6:	81e080e7          	jalr	-2018(ra) # 7df0 <printf>
    exit(1);
    25da:	4505                	li	a0,1
    25dc:	00005097          	auipc	ra,0x5
    25e0:	2cc080e7          	jalr	716(ra) # 78a8 <exit>
  }
  if(pid == 0){
    25e4:	fec42783          	lw	a5,-20(s0)
    25e8:	2781                	sext.w	a5,a5
    25ea:	efb9                	bnez	a5,2648 <forkforkfork+0xb6>
    while(1){
      int fd = open("stopforking", 0);
    25ec:	4581                	li	a1,0
    25ee:	00006517          	auipc	a0,0x6
    25f2:	56250513          	addi	a0,a0,1378 # 8b50 <malloc+0xb6e>
    25f6:	00005097          	auipc	ra,0x5
    25fa:	2f2080e7          	jalr	754(ra) # 78e8 <open>
    25fe:	87aa                	mv	a5,a0
    2600:	fef42423          	sw	a5,-24(s0)
      if(fd >= 0){
    2604:	fe842783          	lw	a5,-24(s0)
    2608:	2781                	sext.w	a5,a5
    260a:	0007c763          	bltz	a5,2618 <forkforkfork+0x86>
        exit(0);
    260e:	4501                	li	a0,0
    2610:	00005097          	auipc	ra,0x5
    2614:	298080e7          	jalr	664(ra) # 78a8 <exit>
      }
      if(fork() < 0){
    2618:	00005097          	auipc	ra,0x5
    261c:	288080e7          	jalr	648(ra) # 78a0 <fork>
    2620:	87aa                	mv	a5,a0
    2622:	fc07d5e3          	bgez	a5,25ec <forkforkfork+0x5a>
        close(open("stopforking", O_CREATE|O_RDWR));
    2626:	20200593          	li	a1,514
    262a:	00006517          	auipc	a0,0x6
    262e:	52650513          	addi	a0,a0,1318 # 8b50 <malloc+0xb6e>
    2632:	00005097          	auipc	ra,0x5
    2636:	2b6080e7          	jalr	694(ra) # 78e8 <open>
    263a:	87aa                	mv	a5,a0
    263c:	853e                	mv	a0,a5
    263e:	00005097          	auipc	ra,0x5
    2642:	292080e7          	jalr	658(ra) # 78d0 <close>
    while(1){
    2646:	b75d                	j	25ec <forkforkfork+0x5a>
    }

    exit(0);
  }

  sleep(20); // two seconds
    2648:	4551                	li	a0,20
    264a:	00005097          	auipc	ra,0x5
    264e:	2ee080e7          	jalr	750(ra) # 7938 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    2652:	20200593          	li	a1,514
    2656:	00006517          	auipc	a0,0x6
    265a:	4fa50513          	addi	a0,a0,1274 # 8b50 <malloc+0xb6e>
    265e:	00005097          	auipc	ra,0x5
    2662:	28a080e7          	jalr	650(ra) # 78e8 <open>
    2666:	87aa                	mv	a5,a0
    2668:	853e                	mv	a0,a5
    266a:	00005097          	auipc	ra,0x5
    266e:	266080e7          	jalr	614(ra) # 78d0 <close>
  wait(0);
    2672:	4501                	li	a0,0
    2674:	00005097          	auipc	ra,0x5
    2678:	23c080e7          	jalr	572(ra) # 78b0 <wait>
  sleep(10); // one second
    267c:	4529                	li	a0,10
    267e:	00005097          	auipc	ra,0x5
    2682:	2ba080e7          	jalr	698(ra) # 7938 <sleep>
}
    2686:	0001                	nop
    2688:	70a2                	ld	ra,40(sp)
    268a:	7402                	ld	s0,32(sp)
    268c:	6145                	addi	sp,sp,48
    268e:	8082                	ret

0000000000002690 <reparent2>:
// deadlocks against init's wait()? also used to trigger a "panic:
// release" due to exit() releasing a different p->parent->lock than
// it acquired.
void
reparent2(char *s)
{
    2690:	7179                	addi	sp,sp,-48
    2692:	f406                	sd	ra,40(sp)
    2694:	f022                	sd	s0,32(sp)
    2696:	1800                	addi	s0,sp,48
    2698:	fca43c23          	sd	a0,-40(s0)
  for(int i = 0; i < 800; i++){
    269c:	fe042623          	sw	zero,-20(s0)
    26a0:	a0ad                	j	270a <reparent2+0x7a>
    int pid1 = fork();
    26a2:	00005097          	auipc	ra,0x5
    26a6:	1fe080e7          	jalr	510(ra) # 78a0 <fork>
    26aa:	87aa                	mv	a5,a0
    26ac:	fef42423          	sw	a5,-24(s0)
    if(pid1 < 0){
    26b0:	fe842783          	lw	a5,-24(s0)
    26b4:	2781                	sext.w	a5,a5
    26b6:	0007df63          	bgez	a5,26d4 <reparent2+0x44>
      printf("fork failed\n");
    26ba:	00006517          	auipc	a0,0x6
    26be:	c7650513          	addi	a0,a0,-906 # 8330 <malloc+0x34e>
    26c2:	00005097          	auipc	ra,0x5
    26c6:	72e080e7          	jalr	1838(ra) # 7df0 <printf>
      exit(1);
    26ca:	4505                	li	a0,1
    26cc:	00005097          	auipc	ra,0x5
    26d0:	1dc080e7          	jalr	476(ra) # 78a8 <exit>
    }
    if(pid1 == 0){
    26d4:	fe842783          	lw	a5,-24(s0)
    26d8:	2781                	sext.w	a5,a5
    26da:	ef91                	bnez	a5,26f6 <reparent2+0x66>
      fork();
    26dc:	00005097          	auipc	ra,0x5
    26e0:	1c4080e7          	jalr	452(ra) # 78a0 <fork>
      fork();
    26e4:	00005097          	auipc	ra,0x5
    26e8:	1bc080e7          	jalr	444(ra) # 78a0 <fork>
      exit(0);
    26ec:	4501                	li	a0,0
    26ee:	00005097          	auipc	ra,0x5
    26f2:	1ba080e7          	jalr	442(ra) # 78a8 <exit>
    }
    wait(0);
    26f6:	4501                	li	a0,0
    26f8:	00005097          	auipc	ra,0x5
    26fc:	1b8080e7          	jalr	440(ra) # 78b0 <wait>
  for(int i = 0; i < 800; i++){
    2700:	fec42783          	lw	a5,-20(s0)
    2704:	2785                	addiw	a5,a5,1
    2706:	fef42623          	sw	a5,-20(s0)
    270a:	fec42783          	lw	a5,-20(s0)
    270e:	0007871b          	sext.w	a4,a5
    2712:	31f00793          	li	a5,799
    2716:	f8e7d6e3          	bge	a5,a4,26a2 <reparent2+0x12>
  }

  exit(0);
    271a:	4501                	li	a0,0
    271c:	00005097          	auipc	ra,0x5
    2720:	18c080e7          	jalr	396(ra) # 78a8 <exit>

0000000000002724 <mem>:
}

// allocate all mem, free it, and allocate again
void
mem(char *s)
{
    2724:	7139                	addi	sp,sp,-64
    2726:	fc06                	sd	ra,56(sp)
    2728:	f822                	sd	s0,48(sp)
    272a:	0080                	addi	s0,sp,64
    272c:	fca43423          	sd	a0,-56(s0)
  void *m1, *m2;
  int pid;

  if((pid = fork()) == 0){
    2730:	00005097          	auipc	ra,0x5
    2734:	170080e7          	jalr	368(ra) # 78a0 <fork>
    2738:	87aa                	mv	a5,a0
    273a:	fef42223          	sw	a5,-28(s0)
    273e:	fe442783          	lw	a5,-28(s0)
    2742:	2781                	sext.w	a5,a5
    2744:	e3c5                	bnez	a5,27e4 <mem+0xc0>
    m1 = 0;
    2746:	fe043423          	sd	zero,-24(s0)
    while((m2 = malloc(10001)) != 0){
    274a:	a811                	j	275e <mem+0x3a>
      *(char**)m2 = m1;
    274c:	fd843783          	ld	a5,-40(s0)
    2750:	fe843703          	ld	a4,-24(s0)
    2754:	e398                	sd	a4,0(a5)
      m1 = m2;
    2756:	fd843783          	ld	a5,-40(s0)
    275a:	fef43423          	sd	a5,-24(s0)
    while((m2 = malloc(10001)) != 0){
    275e:	6789                	lui	a5,0x2
    2760:	71178513          	addi	a0,a5,1809 # 2711 <reparent2+0x81>
    2764:	00006097          	auipc	ra,0x6
    2768:	87e080e7          	jalr	-1922(ra) # 7fe2 <malloc>
    276c:	fca43c23          	sd	a0,-40(s0)
    2770:	fd843783          	ld	a5,-40(s0)
    2774:	ffe1                	bnez	a5,274c <mem+0x28>
    }
    while(m1){
    2776:	a005                	j	2796 <mem+0x72>
      m2 = *(char**)m1;
    2778:	fe843783          	ld	a5,-24(s0)
    277c:	639c                	ld	a5,0(a5)
    277e:	fcf43c23          	sd	a5,-40(s0)
      free(m1);
    2782:	fe843503          	ld	a0,-24(s0)
    2786:	00005097          	auipc	ra,0x5
    278a:	6ba080e7          	jalr	1722(ra) # 7e40 <free>
      m1 = m2;
    278e:	fd843783          	ld	a5,-40(s0)
    2792:	fef43423          	sd	a5,-24(s0)
    while(m1){
    2796:	fe843783          	ld	a5,-24(s0)
    279a:	fff9                	bnez	a5,2778 <mem+0x54>
    }
    m1 = malloc(1024*20);
    279c:	6515                	lui	a0,0x5
    279e:	00006097          	auipc	ra,0x6
    27a2:	844080e7          	jalr	-1980(ra) # 7fe2 <malloc>
    27a6:	fea43423          	sd	a0,-24(s0)
    if(m1 == 0){
    27aa:	fe843783          	ld	a5,-24(s0)
    27ae:	e385                	bnez	a5,27ce <mem+0xaa>
      printf("couldn't allocate mem?!!\n", s);
    27b0:	fc843583          	ld	a1,-56(s0)
    27b4:	00006517          	auipc	a0,0x6
    27b8:	3ac50513          	addi	a0,a0,940 # 8b60 <malloc+0xb7e>
    27bc:	00005097          	auipc	ra,0x5
    27c0:	634080e7          	jalr	1588(ra) # 7df0 <printf>
      exit(1);
    27c4:	4505                	li	a0,1
    27c6:	00005097          	auipc	ra,0x5
    27ca:	0e2080e7          	jalr	226(ra) # 78a8 <exit>
    }
    free(m1);
    27ce:	fe843503          	ld	a0,-24(s0)
    27d2:	00005097          	auipc	ra,0x5
    27d6:	66e080e7          	jalr	1646(ra) # 7e40 <free>
    exit(0);
    27da:	4501                	li	a0,0
    27dc:	00005097          	auipc	ra,0x5
    27e0:	0cc080e7          	jalr	204(ra) # 78a8 <exit>
  } else {
    int xstatus;
    wait(&xstatus);
    27e4:	fd440793          	addi	a5,s0,-44
    27e8:	853e                	mv	a0,a5
    27ea:	00005097          	auipc	ra,0x5
    27ee:	0c6080e7          	jalr	198(ra) # 78b0 <wait>
    if(xstatus == -1){
    27f2:	fd442783          	lw	a5,-44(s0)
    27f6:	873e                	mv	a4,a5
    27f8:	57fd                	li	a5,-1
    27fa:	00f71763          	bne	a4,a5,2808 <mem+0xe4>
      // probably page fault, so might be lazy lab,
      // so OK.
      exit(0);
    27fe:	4501                	li	a0,0
    2800:	00005097          	auipc	ra,0x5
    2804:	0a8080e7          	jalr	168(ra) # 78a8 <exit>
    }
    exit(xstatus);
    2808:	fd442783          	lw	a5,-44(s0)
    280c:	853e                	mv	a0,a5
    280e:	00005097          	auipc	ra,0x5
    2812:	09a080e7          	jalr	154(ra) # 78a8 <exit>

0000000000002816 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(char *s)
{
    2816:	715d                	addi	sp,sp,-80
    2818:	e486                	sd	ra,72(sp)
    281a:	e0a2                	sd	s0,64(sp)
    281c:	0880                	addi	s0,sp,80
    281e:	faa43c23          	sd	a0,-72(s0)
  int fd, pid, i, n, nc, np;
  enum { N = 1000, SZ=10};
  char buf[SZ];

  unlink("sharedfd");
    2822:	00006517          	auipc	a0,0x6
    2826:	35e50513          	addi	a0,a0,862 # 8b80 <malloc+0xb9e>
    282a:	00005097          	auipc	ra,0x5
    282e:	0ce080e7          	jalr	206(ra) # 78f8 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    2832:	20200593          	li	a1,514
    2836:	00006517          	auipc	a0,0x6
    283a:	34a50513          	addi	a0,a0,842 # 8b80 <malloc+0xb9e>
    283e:	00005097          	auipc	ra,0x5
    2842:	0aa080e7          	jalr	170(ra) # 78e8 <open>
    2846:	87aa                	mv	a5,a0
    2848:	fef42023          	sw	a5,-32(s0)
  if(fd < 0){
    284c:	fe042783          	lw	a5,-32(s0)
    2850:	2781                	sext.w	a5,a5
    2852:	0207d163          	bgez	a5,2874 <sharedfd+0x5e>
    printf("%s: cannot open sharedfd for writing", s);
    2856:	fb843583          	ld	a1,-72(s0)
    285a:	00006517          	auipc	a0,0x6
    285e:	33650513          	addi	a0,a0,822 # 8b90 <malloc+0xbae>
    2862:	00005097          	auipc	ra,0x5
    2866:	58e080e7          	jalr	1422(ra) # 7df0 <printf>
    exit(1);
    286a:	4505                	li	a0,1
    286c:	00005097          	auipc	ra,0x5
    2870:	03c080e7          	jalr	60(ra) # 78a8 <exit>
  }
  pid = fork();
    2874:	00005097          	auipc	ra,0x5
    2878:	02c080e7          	jalr	44(ra) # 78a0 <fork>
    287c:	87aa                	mv	a5,a0
    287e:	fcf42e23          	sw	a5,-36(s0)
  memset(buf, pid==0?'c':'p', sizeof(buf));
    2882:	fdc42783          	lw	a5,-36(s0)
    2886:	2781                	sext.w	a5,a5
    2888:	e781                	bnez	a5,2890 <sharedfd+0x7a>
    288a:	06300793          	li	a5,99
    288e:	a019                	j	2894 <sharedfd+0x7e>
    2890:	07000793          	li	a5,112
    2894:	fc840713          	addi	a4,s0,-56
    2898:	4629                	li	a2,10
    289a:	85be                	mv	a1,a5
    289c:	853a                	mv	a0,a4
    289e:	00005097          	auipc	ra,0x5
    28a2:	c5e080e7          	jalr	-930(ra) # 74fc <memset>
  for(i = 0; i < N; i++){
    28a6:	fe042623          	sw	zero,-20(s0)
    28aa:	a0a9                	j	28f4 <sharedfd+0xde>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    28ac:	fc840713          	addi	a4,s0,-56
    28b0:	fe042783          	lw	a5,-32(s0)
    28b4:	4629                	li	a2,10
    28b6:	85ba                	mv	a1,a4
    28b8:	853e                	mv	a0,a5
    28ba:	00005097          	auipc	ra,0x5
    28be:	00e080e7          	jalr	14(ra) # 78c8 <write>
    28c2:	87aa                	mv	a5,a0
    28c4:	873e                	mv	a4,a5
    28c6:	47a9                	li	a5,10
    28c8:	02f70163          	beq	a4,a5,28ea <sharedfd+0xd4>
      printf("%s: write sharedfd failed\n", s);
    28cc:	fb843583          	ld	a1,-72(s0)
    28d0:	00006517          	auipc	a0,0x6
    28d4:	2e850513          	addi	a0,a0,744 # 8bb8 <malloc+0xbd6>
    28d8:	00005097          	auipc	ra,0x5
    28dc:	518080e7          	jalr	1304(ra) # 7df0 <printf>
      exit(1);
    28e0:	4505                	li	a0,1
    28e2:	00005097          	auipc	ra,0x5
    28e6:	fc6080e7          	jalr	-58(ra) # 78a8 <exit>
  for(i = 0; i < N; i++){
    28ea:	fec42783          	lw	a5,-20(s0)
    28ee:	2785                	addiw	a5,a5,1
    28f0:	fef42623          	sw	a5,-20(s0)
    28f4:	fec42783          	lw	a5,-20(s0)
    28f8:	0007871b          	sext.w	a4,a5
    28fc:	3e700793          	li	a5,999
    2900:	fae7d6e3          	bge	a5,a4,28ac <sharedfd+0x96>
    }
  }
  if(pid == 0) {
    2904:	fdc42783          	lw	a5,-36(s0)
    2908:	2781                	sext.w	a5,a5
    290a:	e791                	bnez	a5,2916 <sharedfd+0x100>
    exit(0);
    290c:	4501                	li	a0,0
    290e:	00005097          	auipc	ra,0x5
    2912:	f9a080e7          	jalr	-102(ra) # 78a8 <exit>
  } else {
    int xstatus;
    wait(&xstatus);
    2916:	fc440793          	addi	a5,s0,-60
    291a:	853e                	mv	a0,a5
    291c:	00005097          	auipc	ra,0x5
    2920:	f94080e7          	jalr	-108(ra) # 78b0 <wait>
    if(xstatus != 0)
    2924:	fc442783          	lw	a5,-60(s0)
    2928:	cb81                	beqz	a5,2938 <sharedfd+0x122>
      exit(xstatus);
    292a:	fc442783          	lw	a5,-60(s0)
    292e:	853e                	mv	a0,a5
    2930:	00005097          	auipc	ra,0x5
    2934:	f78080e7          	jalr	-136(ra) # 78a8 <exit>
  }
  
  close(fd);
    2938:	fe042783          	lw	a5,-32(s0)
    293c:	853e                	mv	a0,a5
    293e:	00005097          	auipc	ra,0x5
    2942:	f92080e7          	jalr	-110(ra) # 78d0 <close>
  fd = open("sharedfd", 0);
    2946:	4581                	li	a1,0
    2948:	00006517          	auipc	a0,0x6
    294c:	23850513          	addi	a0,a0,568 # 8b80 <malloc+0xb9e>
    2950:	00005097          	auipc	ra,0x5
    2954:	f98080e7          	jalr	-104(ra) # 78e8 <open>
    2958:	87aa                	mv	a5,a0
    295a:	fef42023          	sw	a5,-32(s0)
  if(fd < 0){
    295e:	fe042783          	lw	a5,-32(s0)
    2962:	2781                	sext.w	a5,a5
    2964:	0207d163          	bgez	a5,2986 <sharedfd+0x170>
    printf("%s: cannot open sharedfd for reading\n", s);
    2968:	fb843583          	ld	a1,-72(s0)
    296c:	00006517          	auipc	a0,0x6
    2970:	26c50513          	addi	a0,a0,620 # 8bd8 <malloc+0xbf6>
    2974:	00005097          	auipc	ra,0x5
    2978:	47c080e7          	jalr	1148(ra) # 7df0 <printf>
    exit(1);
    297c:	4505                	li	a0,1
    297e:	00005097          	auipc	ra,0x5
    2982:	f2a080e7          	jalr	-214(ra) # 78a8 <exit>
  }
  nc = np = 0;
    2986:	fe042223          	sw	zero,-28(s0)
    298a:	fe442783          	lw	a5,-28(s0)
    298e:	fef42423          	sw	a5,-24(s0)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    2992:	a8b9                	j	29f0 <sharedfd+0x1da>
    for(i = 0; i < sizeof(buf); i++){
    2994:	fe042623          	sw	zero,-20(s0)
    2998:	a0b1                	j	29e4 <sharedfd+0x1ce>
      if(buf[i] == 'c')
    299a:	fec42783          	lw	a5,-20(s0)
    299e:	17c1                	addi	a5,a5,-16
    29a0:	97a2                	add	a5,a5,s0
    29a2:	fd87c783          	lbu	a5,-40(a5)
    29a6:	873e                	mv	a4,a5
    29a8:	06300793          	li	a5,99
    29ac:	00f71763          	bne	a4,a5,29ba <sharedfd+0x1a4>
        nc++;
    29b0:	fe842783          	lw	a5,-24(s0)
    29b4:	2785                	addiw	a5,a5,1
    29b6:	fef42423          	sw	a5,-24(s0)
      if(buf[i] == 'p')
    29ba:	fec42783          	lw	a5,-20(s0)
    29be:	17c1                	addi	a5,a5,-16
    29c0:	97a2                	add	a5,a5,s0
    29c2:	fd87c783          	lbu	a5,-40(a5)
    29c6:	873e                	mv	a4,a5
    29c8:	07000793          	li	a5,112
    29cc:	00f71763          	bne	a4,a5,29da <sharedfd+0x1c4>
        np++;
    29d0:	fe442783          	lw	a5,-28(s0)
    29d4:	2785                	addiw	a5,a5,1
    29d6:	fef42223          	sw	a5,-28(s0)
    for(i = 0; i < sizeof(buf); i++){
    29da:	fec42783          	lw	a5,-20(s0)
    29de:	2785                	addiw	a5,a5,1
    29e0:	fef42623          	sw	a5,-20(s0)
    29e4:	fec42783          	lw	a5,-20(s0)
    29e8:	873e                	mv	a4,a5
    29ea:	47a5                	li	a5,9
    29ec:	fae7f7e3          	bgeu	a5,a4,299a <sharedfd+0x184>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    29f0:	fc840713          	addi	a4,s0,-56
    29f4:	fe042783          	lw	a5,-32(s0)
    29f8:	4629                	li	a2,10
    29fa:	85ba                	mv	a1,a4
    29fc:	853e                	mv	a0,a5
    29fe:	00005097          	auipc	ra,0x5
    2a02:	ec2080e7          	jalr	-318(ra) # 78c0 <read>
    2a06:	87aa                	mv	a5,a0
    2a08:	fcf42c23          	sw	a5,-40(s0)
    2a0c:	fd842783          	lw	a5,-40(s0)
    2a10:	2781                	sext.w	a5,a5
    2a12:	f8f041e3          	bgtz	a5,2994 <sharedfd+0x17e>
    }
  }
  close(fd);
    2a16:	fe042783          	lw	a5,-32(s0)
    2a1a:	853e                	mv	a0,a5
    2a1c:	00005097          	auipc	ra,0x5
    2a20:	eb4080e7          	jalr	-332(ra) # 78d0 <close>
  unlink("sharedfd");
    2a24:	00006517          	auipc	a0,0x6
    2a28:	15c50513          	addi	a0,a0,348 # 8b80 <malloc+0xb9e>
    2a2c:	00005097          	auipc	ra,0x5
    2a30:	ecc080e7          	jalr	-308(ra) # 78f8 <unlink>
  if(nc == N*SZ && np == N*SZ){
    2a34:	fe842783          	lw	a5,-24(s0)
    2a38:	0007871b          	sext.w	a4,a5
    2a3c:	6789                	lui	a5,0x2
    2a3e:	71078793          	addi	a5,a5,1808 # 2710 <reparent2+0x80>
    2a42:	02f71063          	bne	a4,a5,2a62 <sharedfd+0x24c>
    2a46:	fe442783          	lw	a5,-28(s0)
    2a4a:	0007871b          	sext.w	a4,a5
    2a4e:	6789                	lui	a5,0x2
    2a50:	71078793          	addi	a5,a5,1808 # 2710 <reparent2+0x80>
    2a54:	00f71763          	bne	a4,a5,2a62 <sharedfd+0x24c>
    exit(0);
    2a58:	4501                	li	a0,0
    2a5a:	00005097          	auipc	ra,0x5
    2a5e:	e4e080e7          	jalr	-434(ra) # 78a8 <exit>
  } else {
    printf("%s: nc/np test fails\n", s);
    2a62:	fb843583          	ld	a1,-72(s0)
    2a66:	00006517          	auipc	a0,0x6
    2a6a:	19a50513          	addi	a0,a0,410 # 8c00 <malloc+0xc1e>
    2a6e:	00005097          	auipc	ra,0x5
    2a72:	382080e7          	jalr	898(ra) # 7df0 <printf>
    exit(1);
    2a76:	4505                	li	a0,1
    2a78:	00005097          	auipc	ra,0x5
    2a7c:	e30080e7          	jalr	-464(ra) # 78a8 <exit>

0000000000002a80 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(char *s)
{
    2a80:	7159                	addi	sp,sp,-112
    2a82:	f486                	sd	ra,104(sp)
    2a84:	f0a2                	sd	s0,96(sp)
    2a86:	1880                	addi	s0,sp,112
    2a88:	f8a43c23          	sd	a0,-104(s0)
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    2a8c:	00006797          	auipc	a5,0x6
    2a90:	1fc78793          	addi	a5,a5,508 # 8c88 <malloc+0xca6>
    2a94:	6390                	ld	a2,0(a5)
    2a96:	6794                	ld	a3,8(a5)
    2a98:	6b98                	ld	a4,16(a5)
    2a9a:	6f9c                	ld	a5,24(a5)
    2a9c:	fac43423          	sd	a2,-88(s0)
    2aa0:	fad43823          	sd	a3,-80(s0)
    2aa4:	fae43c23          	sd	a4,-72(s0)
    2aa8:	fcf43023          	sd	a5,-64(s0)
  char *fname;
  enum { N=12, NCHILD=4, SZ=500 };
  
  for(pi = 0; pi < NCHILD; pi++){
    2aac:	fe042023          	sw	zero,-32(s0)
    2ab0:	aa3d                	j	2bee <fourfiles+0x16e>
    fname = names[pi];
    2ab2:	fe042783          	lw	a5,-32(s0)
    2ab6:	078e                	slli	a5,a5,0x3
    2ab8:	17c1                	addi	a5,a5,-16
    2aba:	97a2                	add	a5,a5,s0
    2abc:	fb87b783          	ld	a5,-72(a5)
    2ac0:	fcf43c23          	sd	a5,-40(s0)
    unlink(fname);
    2ac4:	fd843503          	ld	a0,-40(s0)
    2ac8:	00005097          	auipc	ra,0x5
    2acc:	e30080e7          	jalr	-464(ra) # 78f8 <unlink>

    pid = fork();
    2ad0:	00005097          	auipc	ra,0x5
    2ad4:	dd0080e7          	jalr	-560(ra) # 78a0 <fork>
    2ad8:	87aa                	mv	a5,a0
    2ada:	fcf42623          	sw	a5,-52(s0)
    if(pid < 0){
    2ade:	fcc42783          	lw	a5,-52(s0)
    2ae2:	2781                	sext.w	a5,a5
    2ae4:	0207d163          	bgez	a5,2b06 <fourfiles+0x86>
      printf("fork failed\n", s);
    2ae8:	f9843583          	ld	a1,-104(s0)
    2aec:	00006517          	auipc	a0,0x6
    2af0:	84450513          	addi	a0,a0,-1980 # 8330 <malloc+0x34e>
    2af4:	00005097          	auipc	ra,0x5
    2af8:	2fc080e7          	jalr	764(ra) # 7df0 <printf>
      exit(1);
    2afc:	4505                	li	a0,1
    2afe:	00005097          	auipc	ra,0x5
    2b02:	daa080e7          	jalr	-598(ra) # 78a8 <exit>
    }

    if(pid == 0){
    2b06:	fcc42783          	lw	a5,-52(s0)
    2b0a:	2781                	sext.w	a5,a5
    2b0c:	efe1                	bnez	a5,2be4 <fourfiles+0x164>
      fd = open(fname, O_CREATE | O_RDWR);
    2b0e:	20200593          	li	a1,514
    2b12:	fd843503          	ld	a0,-40(s0)
    2b16:	00005097          	auipc	ra,0x5
    2b1a:	dd2080e7          	jalr	-558(ra) # 78e8 <open>
    2b1e:	87aa                	mv	a5,a0
    2b20:	fcf42a23          	sw	a5,-44(s0)
      if(fd < 0){
    2b24:	fd442783          	lw	a5,-44(s0)
    2b28:	2781                	sext.w	a5,a5
    2b2a:	0207d163          	bgez	a5,2b4c <fourfiles+0xcc>
        printf("create failed\n", s);
    2b2e:	f9843583          	ld	a1,-104(s0)
    2b32:	00006517          	auipc	a0,0x6
    2b36:	0e650513          	addi	a0,a0,230 # 8c18 <malloc+0xc36>
    2b3a:	00005097          	auipc	ra,0x5
    2b3e:	2b6080e7          	jalr	694(ra) # 7df0 <printf>
        exit(1);
    2b42:	4505                	li	a0,1
    2b44:	00005097          	auipc	ra,0x5
    2b48:	d64080e7          	jalr	-668(ra) # 78a8 <exit>
      }

      memset(buf, '0'+pi, SZ);
    2b4c:	fe042783          	lw	a5,-32(s0)
    2b50:	0307879b          	addiw	a5,a5,48
    2b54:	2781                	sext.w	a5,a5
    2b56:	1f400613          	li	a2,500
    2b5a:	85be                	mv	a1,a5
    2b5c:	00009517          	auipc	a0,0x9
    2b60:	91450513          	addi	a0,a0,-1772 # b470 <buf>
    2b64:	00005097          	auipc	ra,0x5
    2b68:	998080e7          	jalr	-1640(ra) # 74fc <memset>
      for(i = 0; i < N; i++){
    2b6c:	fe042623          	sw	zero,-20(s0)
    2b70:	a8b1                	j	2bcc <fourfiles+0x14c>
        if((n = write(fd, buf, SZ)) != SZ){
    2b72:	fd442783          	lw	a5,-44(s0)
    2b76:	1f400613          	li	a2,500
    2b7a:	00009597          	auipc	a1,0x9
    2b7e:	8f658593          	addi	a1,a1,-1802 # b470 <buf>
    2b82:	853e                	mv	a0,a5
    2b84:	00005097          	auipc	ra,0x5
    2b88:	d44080e7          	jalr	-700(ra) # 78c8 <write>
    2b8c:	87aa                	mv	a5,a0
    2b8e:	fcf42823          	sw	a5,-48(s0)
    2b92:	fd042783          	lw	a5,-48(s0)
    2b96:	0007871b          	sext.w	a4,a5
    2b9a:	1f400793          	li	a5,500
    2b9e:	02f70263          	beq	a4,a5,2bc2 <fourfiles+0x142>
          printf("write failed %d\n", n);
    2ba2:	fd042783          	lw	a5,-48(s0)
    2ba6:	85be                	mv	a1,a5
    2ba8:	00006517          	auipc	a0,0x6
    2bac:	08050513          	addi	a0,a0,128 # 8c28 <malloc+0xc46>
    2bb0:	00005097          	auipc	ra,0x5
    2bb4:	240080e7          	jalr	576(ra) # 7df0 <printf>
          exit(1);
    2bb8:	4505                	li	a0,1
    2bba:	00005097          	auipc	ra,0x5
    2bbe:	cee080e7          	jalr	-786(ra) # 78a8 <exit>
      for(i = 0; i < N; i++){
    2bc2:	fec42783          	lw	a5,-20(s0)
    2bc6:	2785                	addiw	a5,a5,1
    2bc8:	fef42623          	sw	a5,-20(s0)
    2bcc:	fec42783          	lw	a5,-20(s0)
    2bd0:	0007871b          	sext.w	a4,a5
    2bd4:	47ad                	li	a5,11
    2bd6:	f8e7dee3          	bge	a5,a4,2b72 <fourfiles+0xf2>
        }
      }
      exit(0);
    2bda:	4501                	li	a0,0
    2bdc:	00005097          	auipc	ra,0x5
    2be0:	ccc080e7          	jalr	-820(ra) # 78a8 <exit>
  for(pi = 0; pi < NCHILD; pi++){
    2be4:	fe042783          	lw	a5,-32(s0)
    2be8:	2785                	addiw	a5,a5,1
    2bea:	fef42023          	sw	a5,-32(s0)
    2bee:	fe042783          	lw	a5,-32(s0)
    2bf2:	0007871b          	sext.w	a4,a5
    2bf6:	478d                	li	a5,3
    2bf8:	eae7dde3          	bge	a5,a4,2ab2 <fourfiles+0x32>
    }
  }

  int xstatus;
  for(pi = 0; pi < NCHILD; pi++){
    2bfc:	fe042023          	sw	zero,-32(s0)
    2c00:	a03d                	j	2c2e <fourfiles+0x1ae>
    wait(&xstatus);
    2c02:	fa440793          	addi	a5,s0,-92
    2c06:	853e                	mv	a0,a5
    2c08:	00005097          	auipc	ra,0x5
    2c0c:	ca8080e7          	jalr	-856(ra) # 78b0 <wait>
    if(xstatus != 0)
    2c10:	fa442783          	lw	a5,-92(s0)
    2c14:	cb81                	beqz	a5,2c24 <fourfiles+0x1a4>
      exit(xstatus);
    2c16:	fa442783          	lw	a5,-92(s0)
    2c1a:	853e                	mv	a0,a5
    2c1c:	00005097          	auipc	ra,0x5
    2c20:	c8c080e7          	jalr	-884(ra) # 78a8 <exit>
  for(pi = 0; pi < NCHILD; pi++){
    2c24:	fe042783          	lw	a5,-32(s0)
    2c28:	2785                	addiw	a5,a5,1
    2c2a:	fef42023          	sw	a5,-32(s0)
    2c2e:	fe042783          	lw	a5,-32(s0)
    2c32:	0007871b          	sext.w	a4,a5
    2c36:	478d                	li	a5,3
    2c38:	fce7d5e3          	bge	a5,a4,2c02 <fourfiles+0x182>
  }

  for(i = 0; i < NCHILD; i++){
    2c3c:	fe042623          	sw	zero,-20(s0)
    2c40:	a205                	j	2d60 <fourfiles+0x2e0>
    fname = names[i];
    2c42:	fec42783          	lw	a5,-20(s0)
    2c46:	078e                	slli	a5,a5,0x3
    2c48:	17c1                	addi	a5,a5,-16
    2c4a:	97a2                	add	a5,a5,s0
    2c4c:	fb87b783          	ld	a5,-72(a5)
    2c50:	fcf43c23          	sd	a5,-40(s0)
    fd = open(fname, 0);
    2c54:	4581                	li	a1,0
    2c56:	fd843503          	ld	a0,-40(s0)
    2c5a:	00005097          	auipc	ra,0x5
    2c5e:	c8e080e7          	jalr	-882(ra) # 78e8 <open>
    2c62:	87aa                	mv	a5,a0
    2c64:	fcf42a23          	sw	a5,-44(s0)
    total = 0;
    2c68:	fe042223          	sw	zero,-28(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2c6c:	a89d                	j	2ce2 <fourfiles+0x262>
      for(j = 0; j < n; j++){
    2c6e:	fe042423          	sw	zero,-24(s0)
    2c72:	a0b9                	j	2cc0 <fourfiles+0x240>
        if(buf[j] != '0'+i){
    2c74:	00008717          	auipc	a4,0x8
    2c78:	7fc70713          	addi	a4,a4,2044 # b470 <buf>
    2c7c:	fe842783          	lw	a5,-24(s0)
    2c80:	97ba                	add	a5,a5,a4
    2c82:	0007c783          	lbu	a5,0(a5)
    2c86:	0007871b          	sext.w	a4,a5
    2c8a:	fec42783          	lw	a5,-20(s0)
    2c8e:	0307879b          	addiw	a5,a5,48
    2c92:	2781                	sext.w	a5,a5
    2c94:	02f70163          	beq	a4,a5,2cb6 <fourfiles+0x236>
          printf("wrong char\n", s);
    2c98:	f9843583          	ld	a1,-104(s0)
    2c9c:	00006517          	auipc	a0,0x6
    2ca0:	fa450513          	addi	a0,a0,-92 # 8c40 <malloc+0xc5e>
    2ca4:	00005097          	auipc	ra,0x5
    2ca8:	14c080e7          	jalr	332(ra) # 7df0 <printf>
          exit(1);
    2cac:	4505                	li	a0,1
    2cae:	00005097          	auipc	ra,0x5
    2cb2:	bfa080e7          	jalr	-1030(ra) # 78a8 <exit>
      for(j = 0; j < n; j++){
    2cb6:	fe842783          	lw	a5,-24(s0)
    2cba:	2785                	addiw	a5,a5,1
    2cbc:	fef42423          	sw	a5,-24(s0)
    2cc0:	fe842783          	lw	a5,-24(s0)
    2cc4:	873e                	mv	a4,a5
    2cc6:	fd042783          	lw	a5,-48(s0)
    2cca:	2701                	sext.w	a4,a4
    2ccc:	2781                	sext.w	a5,a5
    2cce:	faf743e3          	blt	a4,a5,2c74 <fourfiles+0x1f4>
        }
      }
      total += n;
    2cd2:	fe442783          	lw	a5,-28(s0)
    2cd6:	873e                	mv	a4,a5
    2cd8:	fd042783          	lw	a5,-48(s0)
    2cdc:	9fb9                	addw	a5,a5,a4
    2cde:	fef42223          	sw	a5,-28(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2ce2:	fd442783          	lw	a5,-44(s0)
    2ce6:	660d                	lui	a2,0x3
    2ce8:	00008597          	auipc	a1,0x8
    2cec:	78858593          	addi	a1,a1,1928 # b470 <buf>
    2cf0:	853e                	mv	a0,a5
    2cf2:	00005097          	auipc	ra,0x5
    2cf6:	bce080e7          	jalr	-1074(ra) # 78c0 <read>
    2cfa:	87aa                	mv	a5,a0
    2cfc:	fcf42823          	sw	a5,-48(s0)
    2d00:	fd042783          	lw	a5,-48(s0)
    2d04:	2781                	sext.w	a5,a5
    2d06:	f6f044e3          	bgtz	a5,2c6e <fourfiles+0x1ee>
    }
    close(fd);
    2d0a:	fd442783          	lw	a5,-44(s0)
    2d0e:	853e                	mv	a0,a5
    2d10:	00005097          	auipc	ra,0x5
    2d14:	bc0080e7          	jalr	-1088(ra) # 78d0 <close>
    if(total != N*SZ){
    2d18:	fe442783          	lw	a5,-28(s0)
    2d1c:	0007871b          	sext.w	a4,a5
    2d20:	6785                	lui	a5,0x1
    2d22:	77078793          	addi	a5,a5,1904 # 1770 <writebig+0x12c>
    2d26:	02f70263          	beq	a4,a5,2d4a <fourfiles+0x2ca>
      printf("wrong length %d\n", total);
    2d2a:	fe442783          	lw	a5,-28(s0)
    2d2e:	85be                	mv	a1,a5
    2d30:	00006517          	auipc	a0,0x6
    2d34:	f2050513          	addi	a0,a0,-224 # 8c50 <malloc+0xc6e>
    2d38:	00005097          	auipc	ra,0x5
    2d3c:	0b8080e7          	jalr	184(ra) # 7df0 <printf>
      exit(1);
    2d40:	4505                	li	a0,1
    2d42:	00005097          	auipc	ra,0x5
    2d46:	b66080e7          	jalr	-1178(ra) # 78a8 <exit>
    }
    unlink(fname);
    2d4a:	fd843503          	ld	a0,-40(s0)
    2d4e:	00005097          	auipc	ra,0x5
    2d52:	baa080e7          	jalr	-1110(ra) # 78f8 <unlink>
  for(i = 0; i < NCHILD; i++){
    2d56:	fec42783          	lw	a5,-20(s0)
    2d5a:	2785                	addiw	a5,a5,1
    2d5c:	fef42623          	sw	a5,-20(s0)
    2d60:	fec42783          	lw	a5,-20(s0)
    2d64:	0007871b          	sext.w	a4,a5
    2d68:	478d                	li	a5,3
    2d6a:	ece7dce3          	bge	a5,a4,2c42 <fourfiles+0x1c2>
  }
}
    2d6e:	0001                	nop
    2d70:	0001                	nop
    2d72:	70a6                	ld	ra,104(sp)
    2d74:	7406                	ld	s0,96(sp)
    2d76:	6165                	addi	sp,sp,112
    2d78:	8082                	ret

0000000000002d7a <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(char *s)
{
    2d7a:	711d                	addi	sp,sp,-96
    2d7c:	ec86                	sd	ra,88(sp)
    2d7e:	e8a2                	sd	s0,80(sp)
    2d80:	1080                	addi	s0,sp,96
    2d82:	faa43423          	sd	a0,-88(s0)
  enum { N = 20, NCHILD=4 };
  int pid, i, fd, pi;
  char name[32];

  for(pi = 0; pi < NCHILD; pi++){
    2d86:	fe042423          	sw	zero,-24(s0)
    2d8a:	aa91                	j	2ede <createdelete+0x164>
    pid = fork();
    2d8c:	00005097          	auipc	ra,0x5
    2d90:	b14080e7          	jalr	-1260(ra) # 78a0 <fork>
    2d94:	87aa                	mv	a5,a0
    2d96:	fef42023          	sw	a5,-32(s0)
    if(pid < 0){
    2d9a:	fe042783          	lw	a5,-32(s0)
    2d9e:	2781                	sext.w	a5,a5
    2da0:	0207d163          	bgez	a5,2dc2 <createdelete+0x48>
      printf("fork failed\n", s);
    2da4:	fa843583          	ld	a1,-88(s0)
    2da8:	00005517          	auipc	a0,0x5
    2dac:	58850513          	addi	a0,a0,1416 # 8330 <malloc+0x34e>
    2db0:	00005097          	auipc	ra,0x5
    2db4:	040080e7          	jalr	64(ra) # 7df0 <printf>
      exit(1);
    2db8:	4505                	li	a0,1
    2dba:	00005097          	auipc	ra,0x5
    2dbe:	aee080e7          	jalr	-1298(ra) # 78a8 <exit>
    }

    if(pid == 0){
    2dc2:	fe042783          	lw	a5,-32(s0)
    2dc6:	2781                	sext.w	a5,a5
    2dc8:	10079663          	bnez	a5,2ed4 <createdelete+0x15a>
      name[0] = 'p' + pi;
    2dcc:	fe842783          	lw	a5,-24(s0)
    2dd0:	0ff7f793          	zext.b	a5,a5
    2dd4:	0707879b          	addiw	a5,a5,112
    2dd8:	0ff7f793          	zext.b	a5,a5
    2ddc:	fcf40023          	sb	a5,-64(s0)
      name[2] = '\0';
    2de0:	fc040123          	sb	zero,-62(s0)
      for(i = 0; i < N; i++){
    2de4:	fe042623          	sw	zero,-20(s0)
    2de8:	a8d1                	j	2ebc <createdelete+0x142>
        name[1] = '0' + i;
    2dea:	fec42783          	lw	a5,-20(s0)
    2dee:	0ff7f793          	zext.b	a5,a5
    2df2:	0307879b          	addiw	a5,a5,48
    2df6:	0ff7f793          	zext.b	a5,a5
    2dfa:	fcf400a3          	sb	a5,-63(s0)
        fd = open(name, O_CREATE | O_RDWR);
    2dfe:	fc040793          	addi	a5,s0,-64
    2e02:	20200593          	li	a1,514
    2e06:	853e                	mv	a0,a5
    2e08:	00005097          	auipc	ra,0x5
    2e0c:	ae0080e7          	jalr	-1312(ra) # 78e8 <open>
    2e10:	87aa                	mv	a5,a0
    2e12:	fef42223          	sw	a5,-28(s0)
        if(fd < 0){
    2e16:	fe442783          	lw	a5,-28(s0)
    2e1a:	2781                	sext.w	a5,a5
    2e1c:	0207d163          	bgez	a5,2e3e <createdelete+0xc4>
          printf("%s: create failed\n", s);
    2e20:	fa843583          	ld	a1,-88(s0)
    2e24:	00006517          	auipc	a0,0x6
    2e28:	b6450513          	addi	a0,a0,-1180 # 8988 <malloc+0x9a6>
    2e2c:	00005097          	auipc	ra,0x5
    2e30:	fc4080e7          	jalr	-60(ra) # 7df0 <printf>
          exit(1);
    2e34:	4505                	li	a0,1
    2e36:	00005097          	auipc	ra,0x5
    2e3a:	a72080e7          	jalr	-1422(ra) # 78a8 <exit>
        }
        close(fd);
    2e3e:	fe442783          	lw	a5,-28(s0)
    2e42:	853e                	mv	a0,a5
    2e44:	00005097          	auipc	ra,0x5
    2e48:	a8c080e7          	jalr	-1396(ra) # 78d0 <close>
        if(i > 0 && (i % 2 ) == 0){
    2e4c:	fec42783          	lw	a5,-20(s0)
    2e50:	2781                	sext.w	a5,a5
    2e52:	06f05063          	blez	a5,2eb2 <createdelete+0x138>
    2e56:	fec42783          	lw	a5,-20(s0)
    2e5a:	8b85                	andi	a5,a5,1
    2e5c:	2781                	sext.w	a5,a5
    2e5e:	ebb1                	bnez	a5,2eb2 <createdelete+0x138>
          name[1] = '0' + (i / 2);
    2e60:	fec42783          	lw	a5,-20(s0)
    2e64:	01f7d71b          	srliw	a4,a5,0x1f
    2e68:	9fb9                	addw	a5,a5,a4
    2e6a:	4017d79b          	sraiw	a5,a5,0x1
    2e6e:	2781                	sext.w	a5,a5
    2e70:	0ff7f793          	zext.b	a5,a5
    2e74:	0307879b          	addiw	a5,a5,48
    2e78:	0ff7f793          	zext.b	a5,a5
    2e7c:	fcf400a3          	sb	a5,-63(s0)
          if(unlink(name) < 0){
    2e80:	fc040793          	addi	a5,s0,-64
    2e84:	853e                	mv	a0,a5
    2e86:	00005097          	auipc	ra,0x5
    2e8a:	a72080e7          	jalr	-1422(ra) # 78f8 <unlink>
    2e8e:	87aa                	mv	a5,a0
    2e90:	0207d163          	bgez	a5,2eb2 <createdelete+0x138>
            printf("%s: unlink failed\n", s);
    2e94:	fa843583          	ld	a1,-88(s0)
    2e98:	00006517          	auipc	a0,0x6
    2e9c:	84050513          	addi	a0,a0,-1984 # 86d8 <malloc+0x6f6>
    2ea0:	00005097          	auipc	ra,0x5
    2ea4:	f50080e7          	jalr	-176(ra) # 7df0 <printf>
            exit(1);
    2ea8:	4505                	li	a0,1
    2eaa:	00005097          	auipc	ra,0x5
    2eae:	9fe080e7          	jalr	-1538(ra) # 78a8 <exit>
      for(i = 0; i < N; i++){
    2eb2:	fec42783          	lw	a5,-20(s0)
    2eb6:	2785                	addiw	a5,a5,1
    2eb8:	fef42623          	sw	a5,-20(s0)
    2ebc:	fec42783          	lw	a5,-20(s0)
    2ec0:	0007871b          	sext.w	a4,a5
    2ec4:	47cd                	li	a5,19
    2ec6:	f2e7d2e3          	bge	a5,a4,2dea <createdelete+0x70>
          }
        }
      }
      exit(0);
    2eca:	4501                	li	a0,0
    2ecc:	00005097          	auipc	ra,0x5
    2ed0:	9dc080e7          	jalr	-1572(ra) # 78a8 <exit>
  for(pi = 0; pi < NCHILD; pi++){
    2ed4:	fe842783          	lw	a5,-24(s0)
    2ed8:	2785                	addiw	a5,a5,1
    2eda:	fef42423          	sw	a5,-24(s0)
    2ede:	fe842783          	lw	a5,-24(s0)
    2ee2:	0007871b          	sext.w	a4,a5
    2ee6:	478d                	li	a5,3
    2ee8:	eae7d2e3          	bge	a5,a4,2d8c <createdelete+0x12>
    }
  }

  int xstatus;
  for(pi = 0; pi < NCHILD; pi++){
    2eec:	fe042423          	sw	zero,-24(s0)
    2ef0:	a02d                	j	2f1a <createdelete+0x1a0>
    wait(&xstatus);
    2ef2:	fbc40793          	addi	a5,s0,-68
    2ef6:	853e                	mv	a0,a5
    2ef8:	00005097          	auipc	ra,0x5
    2efc:	9b8080e7          	jalr	-1608(ra) # 78b0 <wait>
    if(xstatus != 0)
    2f00:	fbc42783          	lw	a5,-68(s0)
    2f04:	c791                	beqz	a5,2f10 <createdelete+0x196>
      exit(1);
    2f06:	4505                	li	a0,1
    2f08:	00005097          	auipc	ra,0x5
    2f0c:	9a0080e7          	jalr	-1632(ra) # 78a8 <exit>
  for(pi = 0; pi < NCHILD; pi++){
    2f10:	fe842783          	lw	a5,-24(s0)
    2f14:	2785                	addiw	a5,a5,1
    2f16:	fef42423          	sw	a5,-24(s0)
    2f1a:	fe842783          	lw	a5,-24(s0)
    2f1e:	0007871b          	sext.w	a4,a5
    2f22:	478d                	li	a5,3
    2f24:	fce7d7e3          	bge	a5,a4,2ef2 <createdelete+0x178>
  }

  name[0] = name[1] = name[2] = 0;
    2f28:	fc040123          	sb	zero,-62(s0)
    2f2c:	fc244783          	lbu	a5,-62(s0)
    2f30:	fcf400a3          	sb	a5,-63(s0)
    2f34:	fc144783          	lbu	a5,-63(s0)
    2f38:	fcf40023          	sb	a5,-64(s0)
  for(i = 0; i < N; i++){
    2f3c:	fe042623          	sw	zero,-20(s0)
    2f40:	a229                	j	304a <createdelete+0x2d0>
    for(pi = 0; pi < NCHILD; pi++){
    2f42:	fe042423          	sw	zero,-24(s0)
    2f46:	a0f5                	j	3032 <createdelete+0x2b8>
      name[0] = 'p' + pi;
    2f48:	fe842783          	lw	a5,-24(s0)
    2f4c:	0ff7f793          	zext.b	a5,a5
    2f50:	0707879b          	addiw	a5,a5,112
    2f54:	0ff7f793          	zext.b	a5,a5
    2f58:	fcf40023          	sb	a5,-64(s0)
      name[1] = '0' + i;
    2f5c:	fec42783          	lw	a5,-20(s0)
    2f60:	0ff7f793          	zext.b	a5,a5
    2f64:	0307879b          	addiw	a5,a5,48
    2f68:	0ff7f793          	zext.b	a5,a5
    2f6c:	fcf400a3          	sb	a5,-63(s0)
      fd = open(name, 0);
    2f70:	fc040793          	addi	a5,s0,-64
    2f74:	4581                	li	a1,0
    2f76:	853e                	mv	a0,a5
    2f78:	00005097          	auipc	ra,0x5
    2f7c:	970080e7          	jalr	-1680(ra) # 78e8 <open>
    2f80:	87aa                	mv	a5,a0
    2f82:	fef42223          	sw	a5,-28(s0)
      if((i == 0 || i >= N/2) && fd < 0){
    2f86:	fec42783          	lw	a5,-20(s0)
    2f8a:	2781                	sext.w	a5,a5
    2f8c:	cb81                	beqz	a5,2f9c <createdelete+0x222>
    2f8e:	fec42783          	lw	a5,-20(s0)
    2f92:	0007871b          	sext.w	a4,a5
    2f96:	47a5                	li	a5,9
    2f98:	02e7d963          	bge	a5,a4,2fca <createdelete+0x250>
    2f9c:	fe442783          	lw	a5,-28(s0)
    2fa0:	2781                	sext.w	a5,a5
    2fa2:	0207d463          	bgez	a5,2fca <createdelete+0x250>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    2fa6:	fc040793          	addi	a5,s0,-64
    2faa:	863e                	mv	a2,a5
    2fac:	fa843583          	ld	a1,-88(s0)
    2fb0:	00006517          	auipc	a0,0x6
    2fb4:	cf850513          	addi	a0,a0,-776 # 8ca8 <malloc+0xcc6>
    2fb8:	00005097          	auipc	ra,0x5
    2fbc:	e38080e7          	jalr	-456(ra) # 7df0 <printf>
        exit(1);
    2fc0:	4505                	li	a0,1
    2fc2:	00005097          	auipc	ra,0x5
    2fc6:	8e6080e7          	jalr	-1818(ra) # 78a8 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    2fca:	fec42783          	lw	a5,-20(s0)
    2fce:	2781                	sext.w	a5,a5
    2fd0:	04f05063          	blez	a5,3010 <createdelete+0x296>
    2fd4:	fec42783          	lw	a5,-20(s0)
    2fd8:	0007871b          	sext.w	a4,a5
    2fdc:	47a5                	li	a5,9
    2fde:	02e7c963          	blt	a5,a4,3010 <createdelete+0x296>
    2fe2:	fe442783          	lw	a5,-28(s0)
    2fe6:	2781                	sext.w	a5,a5
    2fe8:	0207c463          	bltz	a5,3010 <createdelete+0x296>
        printf("%s: oops createdelete %s did exist\n", s, name);
    2fec:	fc040793          	addi	a5,s0,-64
    2ff0:	863e                	mv	a2,a5
    2ff2:	fa843583          	ld	a1,-88(s0)
    2ff6:	00006517          	auipc	a0,0x6
    2ffa:	cda50513          	addi	a0,a0,-806 # 8cd0 <malloc+0xcee>
    2ffe:	00005097          	auipc	ra,0x5
    3002:	df2080e7          	jalr	-526(ra) # 7df0 <printf>
        exit(1);
    3006:	4505                	li	a0,1
    3008:	00005097          	auipc	ra,0x5
    300c:	8a0080e7          	jalr	-1888(ra) # 78a8 <exit>
      }
      if(fd >= 0)
    3010:	fe442783          	lw	a5,-28(s0)
    3014:	2781                	sext.w	a5,a5
    3016:	0007c963          	bltz	a5,3028 <createdelete+0x2ae>
        close(fd);
    301a:	fe442783          	lw	a5,-28(s0)
    301e:	853e                	mv	a0,a5
    3020:	00005097          	auipc	ra,0x5
    3024:	8b0080e7          	jalr	-1872(ra) # 78d0 <close>
    for(pi = 0; pi < NCHILD; pi++){
    3028:	fe842783          	lw	a5,-24(s0)
    302c:	2785                	addiw	a5,a5,1
    302e:	fef42423          	sw	a5,-24(s0)
    3032:	fe842783          	lw	a5,-24(s0)
    3036:	0007871b          	sext.w	a4,a5
    303a:	478d                	li	a5,3
    303c:	f0e7d6e3          	bge	a5,a4,2f48 <createdelete+0x1ce>
  for(i = 0; i < N; i++){
    3040:	fec42783          	lw	a5,-20(s0)
    3044:	2785                	addiw	a5,a5,1
    3046:	fef42623          	sw	a5,-20(s0)
    304a:	fec42783          	lw	a5,-20(s0)
    304e:	0007871b          	sext.w	a4,a5
    3052:	47cd                	li	a5,19
    3054:	eee7d7e3          	bge	a5,a4,2f42 <createdelete+0x1c8>
    }
  }

  for(i = 0; i < N; i++){
    3058:	fe042623          	sw	zero,-20(s0)
    305c:	a085                	j	30bc <createdelete+0x342>
    for(pi = 0; pi < NCHILD; pi++){
    305e:	fe042423          	sw	zero,-24(s0)
    3062:	a089                	j	30a4 <createdelete+0x32a>
      name[0] = 'p' + i;
    3064:	fec42783          	lw	a5,-20(s0)
    3068:	0ff7f793          	zext.b	a5,a5
    306c:	0707879b          	addiw	a5,a5,112
    3070:	0ff7f793          	zext.b	a5,a5
    3074:	fcf40023          	sb	a5,-64(s0)
      name[1] = '0' + i;
    3078:	fec42783          	lw	a5,-20(s0)
    307c:	0ff7f793          	zext.b	a5,a5
    3080:	0307879b          	addiw	a5,a5,48
    3084:	0ff7f793          	zext.b	a5,a5
    3088:	fcf400a3          	sb	a5,-63(s0)
      unlink(name);
    308c:	fc040793          	addi	a5,s0,-64
    3090:	853e                	mv	a0,a5
    3092:	00005097          	auipc	ra,0x5
    3096:	866080e7          	jalr	-1946(ra) # 78f8 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    309a:	fe842783          	lw	a5,-24(s0)
    309e:	2785                	addiw	a5,a5,1
    30a0:	fef42423          	sw	a5,-24(s0)
    30a4:	fe842783          	lw	a5,-24(s0)
    30a8:	0007871b          	sext.w	a4,a5
    30ac:	478d                	li	a5,3
    30ae:	fae7dbe3          	bge	a5,a4,3064 <createdelete+0x2ea>
  for(i = 0; i < N; i++){
    30b2:	fec42783          	lw	a5,-20(s0)
    30b6:	2785                	addiw	a5,a5,1
    30b8:	fef42623          	sw	a5,-20(s0)
    30bc:	fec42783          	lw	a5,-20(s0)
    30c0:	0007871b          	sext.w	a4,a5
    30c4:	47cd                	li	a5,19
    30c6:	f8e7dce3          	bge	a5,a4,305e <createdelete+0x2e4>
    }
  }
}
    30ca:	0001                	nop
    30cc:	0001                	nop
    30ce:	60e6                	ld	ra,88(sp)
    30d0:	6446                	ld	s0,80(sp)
    30d2:	6125                	addi	sp,sp,96
    30d4:	8082                	ret

00000000000030d6 <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(char *s)
{
    30d6:	7179                	addi	sp,sp,-48
    30d8:	f406                	sd	ra,40(sp)
    30da:	f022                	sd	s0,32(sp)
    30dc:	1800                	addi	s0,sp,48
    30de:	fca43c23          	sd	a0,-40(s0)
  enum { SZ = 5 };
  int fd, fd1;

  fd = open("unlinkread", O_CREATE | O_RDWR);
    30e2:	20200593          	li	a1,514
    30e6:	00006517          	auipc	a0,0x6
    30ea:	c1250513          	addi	a0,a0,-1006 # 8cf8 <malloc+0xd16>
    30ee:	00004097          	auipc	ra,0x4
    30f2:	7fa080e7          	jalr	2042(ra) # 78e8 <open>
    30f6:	87aa                	mv	a5,a0
    30f8:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    30fc:	fec42783          	lw	a5,-20(s0)
    3100:	2781                	sext.w	a5,a5
    3102:	0207d163          	bgez	a5,3124 <unlinkread+0x4e>
    printf("%s: create unlinkread failed\n", s);
    3106:	fd843583          	ld	a1,-40(s0)
    310a:	00006517          	auipc	a0,0x6
    310e:	bfe50513          	addi	a0,a0,-1026 # 8d08 <malloc+0xd26>
    3112:	00005097          	auipc	ra,0x5
    3116:	cde080e7          	jalr	-802(ra) # 7df0 <printf>
    exit(1);
    311a:	4505                	li	a0,1
    311c:	00004097          	auipc	ra,0x4
    3120:	78c080e7          	jalr	1932(ra) # 78a8 <exit>
  }
  write(fd, "hello", SZ);
    3124:	fec42783          	lw	a5,-20(s0)
    3128:	4615                	li	a2,5
    312a:	00006597          	auipc	a1,0x6
    312e:	bfe58593          	addi	a1,a1,-1026 # 8d28 <malloc+0xd46>
    3132:	853e                	mv	a0,a5
    3134:	00004097          	auipc	ra,0x4
    3138:	794080e7          	jalr	1940(ra) # 78c8 <write>
  close(fd);
    313c:	fec42783          	lw	a5,-20(s0)
    3140:	853e                	mv	a0,a5
    3142:	00004097          	auipc	ra,0x4
    3146:	78e080e7          	jalr	1934(ra) # 78d0 <close>

  fd = open("unlinkread", O_RDWR);
    314a:	4589                	li	a1,2
    314c:	00006517          	auipc	a0,0x6
    3150:	bac50513          	addi	a0,a0,-1108 # 8cf8 <malloc+0xd16>
    3154:	00004097          	auipc	ra,0x4
    3158:	794080e7          	jalr	1940(ra) # 78e8 <open>
    315c:	87aa                	mv	a5,a0
    315e:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    3162:	fec42783          	lw	a5,-20(s0)
    3166:	2781                	sext.w	a5,a5
    3168:	0207d163          	bgez	a5,318a <unlinkread+0xb4>
    printf("%s: open unlinkread failed\n", s);
    316c:	fd843583          	ld	a1,-40(s0)
    3170:	00006517          	auipc	a0,0x6
    3174:	bc050513          	addi	a0,a0,-1088 # 8d30 <malloc+0xd4e>
    3178:	00005097          	auipc	ra,0x5
    317c:	c78080e7          	jalr	-904(ra) # 7df0 <printf>
    exit(1);
    3180:	4505                	li	a0,1
    3182:	00004097          	auipc	ra,0x4
    3186:	726080e7          	jalr	1830(ra) # 78a8 <exit>
  }
  if(unlink("unlinkread") != 0){
    318a:	00006517          	auipc	a0,0x6
    318e:	b6e50513          	addi	a0,a0,-1170 # 8cf8 <malloc+0xd16>
    3192:	00004097          	auipc	ra,0x4
    3196:	766080e7          	jalr	1894(ra) # 78f8 <unlink>
    319a:	87aa                	mv	a5,a0
    319c:	c385                	beqz	a5,31bc <unlinkread+0xe6>
    printf("%s: unlink unlinkread failed\n", s);
    319e:	fd843583          	ld	a1,-40(s0)
    31a2:	00006517          	auipc	a0,0x6
    31a6:	bae50513          	addi	a0,a0,-1106 # 8d50 <malloc+0xd6e>
    31aa:	00005097          	auipc	ra,0x5
    31ae:	c46080e7          	jalr	-954(ra) # 7df0 <printf>
    exit(1);
    31b2:	4505                	li	a0,1
    31b4:	00004097          	auipc	ra,0x4
    31b8:	6f4080e7          	jalr	1780(ra) # 78a8 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    31bc:	20200593          	li	a1,514
    31c0:	00006517          	auipc	a0,0x6
    31c4:	b3850513          	addi	a0,a0,-1224 # 8cf8 <malloc+0xd16>
    31c8:	00004097          	auipc	ra,0x4
    31cc:	720080e7          	jalr	1824(ra) # 78e8 <open>
    31d0:	87aa                	mv	a5,a0
    31d2:	fef42423          	sw	a5,-24(s0)
  write(fd1, "yyy", 3);
    31d6:	fe842783          	lw	a5,-24(s0)
    31da:	460d                	li	a2,3
    31dc:	00006597          	auipc	a1,0x6
    31e0:	b9458593          	addi	a1,a1,-1132 # 8d70 <malloc+0xd8e>
    31e4:	853e                	mv	a0,a5
    31e6:	00004097          	auipc	ra,0x4
    31ea:	6e2080e7          	jalr	1762(ra) # 78c8 <write>
  close(fd1);
    31ee:	fe842783          	lw	a5,-24(s0)
    31f2:	853e                	mv	a0,a5
    31f4:	00004097          	auipc	ra,0x4
    31f8:	6dc080e7          	jalr	1756(ra) # 78d0 <close>

  if(read(fd, buf, sizeof(buf)) != SZ){
    31fc:	fec42783          	lw	a5,-20(s0)
    3200:	660d                	lui	a2,0x3
    3202:	00008597          	auipc	a1,0x8
    3206:	26e58593          	addi	a1,a1,622 # b470 <buf>
    320a:	853e                	mv	a0,a5
    320c:	00004097          	auipc	ra,0x4
    3210:	6b4080e7          	jalr	1716(ra) # 78c0 <read>
    3214:	87aa                	mv	a5,a0
    3216:	873e                	mv	a4,a5
    3218:	4795                	li	a5,5
    321a:	02f70163          	beq	a4,a5,323c <unlinkread+0x166>
    printf("%s: unlinkread read failed", s);
    321e:	fd843583          	ld	a1,-40(s0)
    3222:	00006517          	auipc	a0,0x6
    3226:	b5650513          	addi	a0,a0,-1194 # 8d78 <malloc+0xd96>
    322a:	00005097          	auipc	ra,0x5
    322e:	bc6080e7          	jalr	-1082(ra) # 7df0 <printf>
    exit(1);
    3232:	4505                	li	a0,1
    3234:	00004097          	auipc	ra,0x4
    3238:	674080e7          	jalr	1652(ra) # 78a8 <exit>
  }
  if(buf[0] != 'h'){
    323c:	00008797          	auipc	a5,0x8
    3240:	23478793          	addi	a5,a5,564 # b470 <buf>
    3244:	0007c783          	lbu	a5,0(a5)
    3248:	873e                	mv	a4,a5
    324a:	06800793          	li	a5,104
    324e:	02f70163          	beq	a4,a5,3270 <unlinkread+0x19a>
    printf("%s: unlinkread wrong data\n", s);
    3252:	fd843583          	ld	a1,-40(s0)
    3256:	00006517          	auipc	a0,0x6
    325a:	b4250513          	addi	a0,a0,-1214 # 8d98 <malloc+0xdb6>
    325e:	00005097          	auipc	ra,0x5
    3262:	b92080e7          	jalr	-1134(ra) # 7df0 <printf>
    exit(1);
    3266:	4505                	li	a0,1
    3268:	00004097          	auipc	ra,0x4
    326c:	640080e7          	jalr	1600(ra) # 78a8 <exit>
  }
  if(write(fd, buf, 10) != 10){
    3270:	fec42783          	lw	a5,-20(s0)
    3274:	4629                	li	a2,10
    3276:	00008597          	auipc	a1,0x8
    327a:	1fa58593          	addi	a1,a1,506 # b470 <buf>
    327e:	853e                	mv	a0,a5
    3280:	00004097          	auipc	ra,0x4
    3284:	648080e7          	jalr	1608(ra) # 78c8 <write>
    3288:	87aa                	mv	a5,a0
    328a:	873e                	mv	a4,a5
    328c:	47a9                	li	a5,10
    328e:	02f70163          	beq	a4,a5,32b0 <unlinkread+0x1da>
    printf("%s: unlinkread write failed\n", s);
    3292:	fd843583          	ld	a1,-40(s0)
    3296:	00006517          	auipc	a0,0x6
    329a:	b2250513          	addi	a0,a0,-1246 # 8db8 <malloc+0xdd6>
    329e:	00005097          	auipc	ra,0x5
    32a2:	b52080e7          	jalr	-1198(ra) # 7df0 <printf>
    exit(1);
    32a6:	4505                	li	a0,1
    32a8:	00004097          	auipc	ra,0x4
    32ac:	600080e7          	jalr	1536(ra) # 78a8 <exit>
  }
  close(fd);
    32b0:	fec42783          	lw	a5,-20(s0)
    32b4:	853e                	mv	a0,a5
    32b6:	00004097          	auipc	ra,0x4
    32ba:	61a080e7          	jalr	1562(ra) # 78d0 <close>
  unlink("unlinkread");
    32be:	00006517          	auipc	a0,0x6
    32c2:	a3a50513          	addi	a0,a0,-1478 # 8cf8 <malloc+0xd16>
    32c6:	00004097          	auipc	ra,0x4
    32ca:	632080e7          	jalr	1586(ra) # 78f8 <unlink>
}
    32ce:	0001                	nop
    32d0:	70a2                	ld	ra,40(sp)
    32d2:	7402                	ld	s0,32(sp)
    32d4:	6145                	addi	sp,sp,48
    32d6:	8082                	ret

00000000000032d8 <linktest>:

void
linktest(char *s)
{
    32d8:	7179                	addi	sp,sp,-48
    32da:	f406                	sd	ra,40(sp)
    32dc:	f022                	sd	s0,32(sp)
    32de:	1800                	addi	s0,sp,48
    32e0:	fca43c23          	sd	a0,-40(s0)
  enum { SZ = 5 };
  int fd;

  unlink("lf1");
    32e4:	00006517          	auipc	a0,0x6
    32e8:	af450513          	addi	a0,a0,-1292 # 8dd8 <malloc+0xdf6>
    32ec:	00004097          	auipc	ra,0x4
    32f0:	60c080e7          	jalr	1548(ra) # 78f8 <unlink>
  unlink("lf2");
    32f4:	00006517          	auipc	a0,0x6
    32f8:	aec50513          	addi	a0,a0,-1300 # 8de0 <malloc+0xdfe>
    32fc:	00004097          	auipc	ra,0x4
    3300:	5fc080e7          	jalr	1532(ra) # 78f8 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    3304:	20200593          	li	a1,514
    3308:	00006517          	auipc	a0,0x6
    330c:	ad050513          	addi	a0,a0,-1328 # 8dd8 <malloc+0xdf6>
    3310:	00004097          	auipc	ra,0x4
    3314:	5d8080e7          	jalr	1496(ra) # 78e8 <open>
    3318:	87aa                	mv	a5,a0
    331a:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    331e:	fec42783          	lw	a5,-20(s0)
    3322:	2781                	sext.w	a5,a5
    3324:	0207d163          	bgez	a5,3346 <linktest+0x6e>
    printf("%s: create lf1 failed\n", s);
    3328:	fd843583          	ld	a1,-40(s0)
    332c:	00006517          	auipc	a0,0x6
    3330:	abc50513          	addi	a0,a0,-1348 # 8de8 <malloc+0xe06>
    3334:	00005097          	auipc	ra,0x5
    3338:	abc080e7          	jalr	-1348(ra) # 7df0 <printf>
    exit(1);
    333c:	4505                	li	a0,1
    333e:	00004097          	auipc	ra,0x4
    3342:	56a080e7          	jalr	1386(ra) # 78a8 <exit>
  }
  if(write(fd, "hello", SZ) != SZ){
    3346:	fec42783          	lw	a5,-20(s0)
    334a:	4615                	li	a2,5
    334c:	00006597          	auipc	a1,0x6
    3350:	9dc58593          	addi	a1,a1,-1572 # 8d28 <malloc+0xd46>
    3354:	853e                	mv	a0,a5
    3356:	00004097          	auipc	ra,0x4
    335a:	572080e7          	jalr	1394(ra) # 78c8 <write>
    335e:	87aa                	mv	a5,a0
    3360:	873e                	mv	a4,a5
    3362:	4795                	li	a5,5
    3364:	02f70163          	beq	a4,a5,3386 <linktest+0xae>
    printf("%s: write lf1 failed\n", s);
    3368:	fd843583          	ld	a1,-40(s0)
    336c:	00006517          	auipc	a0,0x6
    3370:	a9450513          	addi	a0,a0,-1388 # 8e00 <malloc+0xe1e>
    3374:	00005097          	auipc	ra,0x5
    3378:	a7c080e7          	jalr	-1412(ra) # 7df0 <printf>
    exit(1);
    337c:	4505                	li	a0,1
    337e:	00004097          	auipc	ra,0x4
    3382:	52a080e7          	jalr	1322(ra) # 78a8 <exit>
  }
  close(fd);
    3386:	fec42783          	lw	a5,-20(s0)
    338a:	853e                	mv	a0,a5
    338c:	00004097          	auipc	ra,0x4
    3390:	544080e7          	jalr	1348(ra) # 78d0 <close>

  if(link("lf1", "lf2") < 0){
    3394:	00006597          	auipc	a1,0x6
    3398:	a4c58593          	addi	a1,a1,-1460 # 8de0 <malloc+0xdfe>
    339c:	00006517          	auipc	a0,0x6
    33a0:	a3c50513          	addi	a0,a0,-1476 # 8dd8 <malloc+0xdf6>
    33a4:	00004097          	auipc	ra,0x4
    33a8:	564080e7          	jalr	1380(ra) # 7908 <link>
    33ac:	87aa                	mv	a5,a0
    33ae:	0207d163          	bgez	a5,33d0 <linktest+0xf8>
    printf("%s: link lf1 lf2 failed\n", s);
    33b2:	fd843583          	ld	a1,-40(s0)
    33b6:	00006517          	auipc	a0,0x6
    33ba:	a6250513          	addi	a0,a0,-1438 # 8e18 <malloc+0xe36>
    33be:	00005097          	auipc	ra,0x5
    33c2:	a32080e7          	jalr	-1486(ra) # 7df0 <printf>
    exit(1);
    33c6:	4505                	li	a0,1
    33c8:	00004097          	auipc	ra,0x4
    33cc:	4e0080e7          	jalr	1248(ra) # 78a8 <exit>
  }
  unlink("lf1");
    33d0:	00006517          	auipc	a0,0x6
    33d4:	a0850513          	addi	a0,a0,-1528 # 8dd8 <malloc+0xdf6>
    33d8:	00004097          	auipc	ra,0x4
    33dc:	520080e7          	jalr	1312(ra) # 78f8 <unlink>

  if(open("lf1", 0) >= 0){
    33e0:	4581                	li	a1,0
    33e2:	00006517          	auipc	a0,0x6
    33e6:	9f650513          	addi	a0,a0,-1546 # 8dd8 <malloc+0xdf6>
    33ea:	00004097          	auipc	ra,0x4
    33ee:	4fe080e7          	jalr	1278(ra) # 78e8 <open>
    33f2:	87aa                	mv	a5,a0
    33f4:	0207c163          	bltz	a5,3416 <linktest+0x13e>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    33f8:	fd843583          	ld	a1,-40(s0)
    33fc:	00006517          	auipc	a0,0x6
    3400:	a3c50513          	addi	a0,a0,-1476 # 8e38 <malloc+0xe56>
    3404:	00005097          	auipc	ra,0x5
    3408:	9ec080e7          	jalr	-1556(ra) # 7df0 <printf>
    exit(1);
    340c:	4505                	li	a0,1
    340e:	00004097          	auipc	ra,0x4
    3412:	49a080e7          	jalr	1178(ra) # 78a8 <exit>
  }

  fd = open("lf2", 0);
    3416:	4581                	li	a1,0
    3418:	00006517          	auipc	a0,0x6
    341c:	9c850513          	addi	a0,a0,-1592 # 8de0 <malloc+0xdfe>
    3420:	00004097          	auipc	ra,0x4
    3424:	4c8080e7          	jalr	1224(ra) # 78e8 <open>
    3428:	87aa                	mv	a5,a0
    342a:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    342e:	fec42783          	lw	a5,-20(s0)
    3432:	2781                	sext.w	a5,a5
    3434:	0207d163          	bgez	a5,3456 <linktest+0x17e>
    printf("%s: open lf2 failed\n", s);
    3438:	fd843583          	ld	a1,-40(s0)
    343c:	00006517          	auipc	a0,0x6
    3440:	a2c50513          	addi	a0,a0,-1492 # 8e68 <malloc+0xe86>
    3444:	00005097          	auipc	ra,0x5
    3448:	9ac080e7          	jalr	-1620(ra) # 7df0 <printf>
    exit(1);
    344c:	4505                	li	a0,1
    344e:	00004097          	auipc	ra,0x4
    3452:	45a080e7          	jalr	1114(ra) # 78a8 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != SZ){
    3456:	fec42783          	lw	a5,-20(s0)
    345a:	660d                	lui	a2,0x3
    345c:	00008597          	auipc	a1,0x8
    3460:	01458593          	addi	a1,a1,20 # b470 <buf>
    3464:	853e                	mv	a0,a5
    3466:	00004097          	auipc	ra,0x4
    346a:	45a080e7          	jalr	1114(ra) # 78c0 <read>
    346e:	87aa                	mv	a5,a0
    3470:	873e                	mv	a4,a5
    3472:	4795                	li	a5,5
    3474:	02f70163          	beq	a4,a5,3496 <linktest+0x1be>
    printf("%s: read lf2 failed\n", s);
    3478:	fd843583          	ld	a1,-40(s0)
    347c:	00006517          	auipc	a0,0x6
    3480:	a0450513          	addi	a0,a0,-1532 # 8e80 <malloc+0xe9e>
    3484:	00005097          	auipc	ra,0x5
    3488:	96c080e7          	jalr	-1684(ra) # 7df0 <printf>
    exit(1);
    348c:	4505                	li	a0,1
    348e:	00004097          	auipc	ra,0x4
    3492:	41a080e7          	jalr	1050(ra) # 78a8 <exit>
  }
  close(fd);
    3496:	fec42783          	lw	a5,-20(s0)
    349a:	853e                	mv	a0,a5
    349c:	00004097          	auipc	ra,0x4
    34a0:	434080e7          	jalr	1076(ra) # 78d0 <close>

  if(link("lf2", "lf2") >= 0){
    34a4:	00006597          	auipc	a1,0x6
    34a8:	93c58593          	addi	a1,a1,-1732 # 8de0 <malloc+0xdfe>
    34ac:	00006517          	auipc	a0,0x6
    34b0:	93450513          	addi	a0,a0,-1740 # 8de0 <malloc+0xdfe>
    34b4:	00004097          	auipc	ra,0x4
    34b8:	454080e7          	jalr	1108(ra) # 7908 <link>
    34bc:	87aa                	mv	a5,a0
    34be:	0207c163          	bltz	a5,34e0 <linktest+0x208>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    34c2:	fd843583          	ld	a1,-40(s0)
    34c6:	00006517          	auipc	a0,0x6
    34ca:	9d250513          	addi	a0,a0,-1582 # 8e98 <malloc+0xeb6>
    34ce:	00005097          	auipc	ra,0x5
    34d2:	922080e7          	jalr	-1758(ra) # 7df0 <printf>
    exit(1);
    34d6:	4505                	li	a0,1
    34d8:	00004097          	auipc	ra,0x4
    34dc:	3d0080e7          	jalr	976(ra) # 78a8 <exit>
  }

  unlink("lf2");
    34e0:	00006517          	auipc	a0,0x6
    34e4:	90050513          	addi	a0,a0,-1792 # 8de0 <malloc+0xdfe>
    34e8:	00004097          	auipc	ra,0x4
    34ec:	410080e7          	jalr	1040(ra) # 78f8 <unlink>
  if(link("lf2", "lf1") >= 0){
    34f0:	00006597          	auipc	a1,0x6
    34f4:	8e858593          	addi	a1,a1,-1816 # 8dd8 <malloc+0xdf6>
    34f8:	00006517          	auipc	a0,0x6
    34fc:	8e850513          	addi	a0,a0,-1816 # 8de0 <malloc+0xdfe>
    3500:	00004097          	auipc	ra,0x4
    3504:	408080e7          	jalr	1032(ra) # 7908 <link>
    3508:	87aa                	mv	a5,a0
    350a:	0207c163          	bltz	a5,352c <linktest+0x254>
    printf("%s: link non-existent succeeded! oops\n", s);
    350e:	fd843583          	ld	a1,-40(s0)
    3512:	00006517          	auipc	a0,0x6
    3516:	9ae50513          	addi	a0,a0,-1618 # 8ec0 <malloc+0xede>
    351a:	00005097          	auipc	ra,0x5
    351e:	8d6080e7          	jalr	-1834(ra) # 7df0 <printf>
    exit(1);
    3522:	4505                	li	a0,1
    3524:	00004097          	auipc	ra,0x4
    3528:	384080e7          	jalr	900(ra) # 78a8 <exit>
  }

  if(link(".", "lf1") >= 0){
    352c:	00006597          	auipc	a1,0x6
    3530:	8ac58593          	addi	a1,a1,-1876 # 8dd8 <malloc+0xdf6>
    3534:	00006517          	auipc	a0,0x6
    3538:	9b450513          	addi	a0,a0,-1612 # 8ee8 <malloc+0xf06>
    353c:	00004097          	auipc	ra,0x4
    3540:	3cc080e7          	jalr	972(ra) # 7908 <link>
    3544:	87aa                	mv	a5,a0
    3546:	0207c163          	bltz	a5,3568 <linktest+0x290>
    printf("%s: link . lf1 succeeded! oops\n", s);
    354a:	fd843583          	ld	a1,-40(s0)
    354e:	00006517          	auipc	a0,0x6
    3552:	9a250513          	addi	a0,a0,-1630 # 8ef0 <malloc+0xf0e>
    3556:	00005097          	auipc	ra,0x5
    355a:	89a080e7          	jalr	-1894(ra) # 7df0 <printf>
    exit(1);
    355e:	4505                	li	a0,1
    3560:	00004097          	auipc	ra,0x4
    3564:	348080e7          	jalr	840(ra) # 78a8 <exit>
  }
}
    3568:	0001                	nop
    356a:	70a2                	ld	ra,40(sp)
    356c:	7402                	ld	s0,32(sp)
    356e:	6145                	addi	sp,sp,48
    3570:	8082                	ret

0000000000003572 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(char *s)
{
    3572:	7119                	addi	sp,sp,-128
    3574:	fc86                	sd	ra,120(sp)
    3576:	f8a2                	sd	s0,112(sp)
    3578:	0100                	addi	s0,sp,128
    357a:	f8a43423          	sd	a0,-120(s0)
  struct {
    ushort inum;
    char name[DIRSIZ];
  } de;

  file[0] = 'C';
    357e:	04300793          	li	a5,67
    3582:	fcf40c23          	sb	a5,-40(s0)
  file[2] = '\0';
    3586:	fc040d23          	sb	zero,-38(s0)
  for(i = 0; i < N; i++){
    358a:	fe042623          	sw	zero,-20(s0)
    358e:	a225                	j	36b6 <concreate+0x144>
    file[1] = '0' + i;
    3590:	fec42783          	lw	a5,-20(s0)
    3594:	0ff7f793          	zext.b	a5,a5
    3598:	0307879b          	addiw	a5,a5,48
    359c:	0ff7f793          	zext.b	a5,a5
    35a0:	fcf40ca3          	sb	a5,-39(s0)
    unlink(file);
    35a4:	fd840793          	addi	a5,s0,-40
    35a8:	853e                	mv	a0,a5
    35aa:	00004097          	auipc	ra,0x4
    35ae:	34e080e7          	jalr	846(ra) # 78f8 <unlink>
    pid = fork();
    35b2:	00004097          	auipc	ra,0x4
    35b6:	2ee080e7          	jalr	750(ra) # 78a0 <fork>
    35ba:	87aa                	mv	a5,a0
    35bc:	fef42023          	sw	a5,-32(s0)
    if(pid && (i % 3) == 1){
    35c0:	fe042783          	lw	a5,-32(s0)
    35c4:	2781                	sext.w	a5,a5
    35c6:	cb85                	beqz	a5,35f6 <concreate+0x84>
    35c8:	fec42783          	lw	a5,-20(s0)
    35cc:	873e                	mv	a4,a5
    35ce:	478d                	li	a5,3
    35d0:	02f767bb          	remw	a5,a4,a5
    35d4:	2781                	sext.w	a5,a5
    35d6:	873e                	mv	a4,a5
    35d8:	4785                	li	a5,1
    35da:	00f71e63          	bne	a4,a5,35f6 <concreate+0x84>
      link("C0", file);
    35de:	fd840793          	addi	a5,s0,-40
    35e2:	85be                	mv	a1,a5
    35e4:	00006517          	auipc	a0,0x6
    35e8:	92c50513          	addi	a0,a0,-1748 # 8f10 <malloc+0xf2e>
    35ec:	00004097          	auipc	ra,0x4
    35f0:	31c080e7          	jalr	796(ra) # 7908 <link>
    35f4:	a061                	j	367c <concreate+0x10a>
    } else if(pid == 0 && (i % 5) == 1){
    35f6:	fe042783          	lw	a5,-32(s0)
    35fa:	2781                	sext.w	a5,a5
    35fc:	eb85                	bnez	a5,362c <concreate+0xba>
    35fe:	fec42783          	lw	a5,-20(s0)
    3602:	873e                	mv	a4,a5
    3604:	4795                	li	a5,5
    3606:	02f767bb          	remw	a5,a4,a5
    360a:	2781                	sext.w	a5,a5
    360c:	873e                	mv	a4,a5
    360e:	4785                	li	a5,1
    3610:	00f71e63          	bne	a4,a5,362c <concreate+0xba>
      link("C0", file);
    3614:	fd840793          	addi	a5,s0,-40
    3618:	85be                	mv	a1,a5
    361a:	00006517          	auipc	a0,0x6
    361e:	8f650513          	addi	a0,a0,-1802 # 8f10 <malloc+0xf2e>
    3622:	00004097          	auipc	ra,0x4
    3626:	2e6080e7          	jalr	742(ra) # 7908 <link>
    362a:	a889                	j	367c <concreate+0x10a>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    362c:	fd840793          	addi	a5,s0,-40
    3630:	20200593          	li	a1,514
    3634:	853e                	mv	a0,a5
    3636:	00004097          	auipc	ra,0x4
    363a:	2b2080e7          	jalr	690(ra) # 78e8 <open>
    363e:	87aa                	mv	a5,a0
    3640:	fef42223          	sw	a5,-28(s0)
      if(fd < 0){
    3644:	fe442783          	lw	a5,-28(s0)
    3648:	2781                	sext.w	a5,a5
    364a:	0207d263          	bgez	a5,366e <concreate+0xfc>
        printf("concreate create %s failed\n", file);
    364e:	fd840793          	addi	a5,s0,-40
    3652:	85be                	mv	a1,a5
    3654:	00006517          	auipc	a0,0x6
    3658:	8c450513          	addi	a0,a0,-1852 # 8f18 <malloc+0xf36>
    365c:	00004097          	auipc	ra,0x4
    3660:	794080e7          	jalr	1940(ra) # 7df0 <printf>
        exit(1);
    3664:	4505                	li	a0,1
    3666:	00004097          	auipc	ra,0x4
    366a:	242080e7          	jalr	578(ra) # 78a8 <exit>
      }
      close(fd);
    366e:	fe442783          	lw	a5,-28(s0)
    3672:	853e                	mv	a0,a5
    3674:	00004097          	auipc	ra,0x4
    3678:	25c080e7          	jalr	604(ra) # 78d0 <close>
    }
    if(pid == 0) {
    367c:	fe042783          	lw	a5,-32(s0)
    3680:	2781                	sext.w	a5,a5
    3682:	e791                	bnez	a5,368e <concreate+0x11c>
      exit(0);
    3684:	4501                	li	a0,0
    3686:	00004097          	auipc	ra,0x4
    368a:	222080e7          	jalr	546(ra) # 78a8 <exit>
    } else {
      int xstatus;
      wait(&xstatus);
    368e:	f9c40793          	addi	a5,s0,-100
    3692:	853e                	mv	a0,a5
    3694:	00004097          	auipc	ra,0x4
    3698:	21c080e7          	jalr	540(ra) # 78b0 <wait>
      if(xstatus != 0)
    369c:	f9c42783          	lw	a5,-100(s0)
    36a0:	c791                	beqz	a5,36ac <concreate+0x13a>
        exit(1);
    36a2:	4505                	li	a0,1
    36a4:	00004097          	auipc	ra,0x4
    36a8:	204080e7          	jalr	516(ra) # 78a8 <exit>
  for(i = 0; i < N; i++){
    36ac:	fec42783          	lw	a5,-20(s0)
    36b0:	2785                	addiw	a5,a5,1
    36b2:	fef42623          	sw	a5,-20(s0)
    36b6:	fec42783          	lw	a5,-20(s0)
    36ba:	0007871b          	sext.w	a4,a5
    36be:	02700793          	li	a5,39
    36c2:	ece7d7e3          	bge	a5,a4,3590 <concreate+0x1e>
    }
  }

  memset(fa, 0, sizeof(fa));
    36c6:	fb040793          	addi	a5,s0,-80
    36ca:	02800613          	li	a2,40
    36ce:	4581                	li	a1,0
    36d0:	853e                	mv	a0,a5
    36d2:	00004097          	auipc	ra,0x4
    36d6:	e2a080e7          	jalr	-470(ra) # 74fc <memset>
  fd = open(".", 0);
    36da:	4581                	li	a1,0
    36dc:	00006517          	auipc	a0,0x6
    36e0:	80c50513          	addi	a0,a0,-2036 # 8ee8 <malloc+0xf06>
    36e4:	00004097          	auipc	ra,0x4
    36e8:	204080e7          	jalr	516(ra) # 78e8 <open>
    36ec:	87aa                	mv	a5,a0
    36ee:	fef42223          	sw	a5,-28(s0)
  n = 0;
    36f2:	fe042423          	sw	zero,-24(s0)
  while(read(fd, &de, sizeof(de)) > 0){
    36f6:	a85d                	j	37ac <concreate+0x23a>
    if(de.inum == 0)
    36f8:	fa045783          	lhu	a5,-96(s0)
    36fc:	e391                	bnez	a5,3700 <concreate+0x18e>
      continue;
    36fe:	a07d                	j	37ac <concreate+0x23a>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3700:	fa244783          	lbu	a5,-94(s0)
    3704:	873e                	mv	a4,a5
    3706:	04300793          	li	a5,67
    370a:	0af71163          	bne	a4,a5,37ac <concreate+0x23a>
    370e:	fa444783          	lbu	a5,-92(s0)
    3712:	efc9                	bnez	a5,37ac <concreate+0x23a>
      i = de.name[1] - '0';
    3714:	fa344783          	lbu	a5,-93(s0)
    3718:	2781                	sext.w	a5,a5
    371a:	fd07879b          	addiw	a5,a5,-48
    371e:	fef42623          	sw	a5,-20(s0)
      if(i < 0 || i >= sizeof(fa)){
    3722:	fec42783          	lw	a5,-20(s0)
    3726:	2781                	sext.w	a5,a5
    3728:	0007c963          	bltz	a5,373a <concreate+0x1c8>
    372c:	fec42783          	lw	a5,-20(s0)
    3730:	873e                	mv	a4,a5
    3732:	02700793          	li	a5,39
    3736:	02e7f563          	bgeu	a5,a4,3760 <concreate+0x1ee>
        printf("%s: concreate weird file %s\n", s, de.name);
    373a:	fa040793          	addi	a5,s0,-96
    373e:	0789                	addi	a5,a5,2
    3740:	863e                	mv	a2,a5
    3742:	f8843583          	ld	a1,-120(s0)
    3746:	00005517          	auipc	a0,0x5
    374a:	7f250513          	addi	a0,a0,2034 # 8f38 <malloc+0xf56>
    374e:	00004097          	auipc	ra,0x4
    3752:	6a2080e7          	jalr	1698(ra) # 7df0 <printf>
        exit(1);
    3756:	4505                	li	a0,1
    3758:	00004097          	auipc	ra,0x4
    375c:	150080e7          	jalr	336(ra) # 78a8 <exit>
      }
      if(fa[i]){
    3760:	fec42783          	lw	a5,-20(s0)
    3764:	17c1                	addi	a5,a5,-16
    3766:	97a2                	add	a5,a5,s0
    3768:	fc07c783          	lbu	a5,-64(a5)
    376c:	c785                	beqz	a5,3794 <concreate+0x222>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    376e:	fa040793          	addi	a5,s0,-96
    3772:	0789                	addi	a5,a5,2
    3774:	863e                	mv	a2,a5
    3776:	f8843583          	ld	a1,-120(s0)
    377a:	00005517          	auipc	a0,0x5
    377e:	7de50513          	addi	a0,a0,2014 # 8f58 <malloc+0xf76>
    3782:	00004097          	auipc	ra,0x4
    3786:	66e080e7          	jalr	1646(ra) # 7df0 <printf>
        exit(1);
    378a:	4505                	li	a0,1
    378c:	00004097          	auipc	ra,0x4
    3790:	11c080e7          	jalr	284(ra) # 78a8 <exit>
      }
      fa[i] = 1;
    3794:	fec42783          	lw	a5,-20(s0)
    3798:	17c1                	addi	a5,a5,-16
    379a:	97a2                	add	a5,a5,s0
    379c:	4705                	li	a4,1
    379e:	fce78023          	sb	a4,-64(a5)
      n++;
    37a2:	fe842783          	lw	a5,-24(s0)
    37a6:	2785                	addiw	a5,a5,1
    37a8:	fef42423          	sw	a5,-24(s0)
  while(read(fd, &de, sizeof(de)) > 0){
    37ac:	fa040713          	addi	a4,s0,-96
    37b0:	fe442783          	lw	a5,-28(s0)
    37b4:	4641                	li	a2,16
    37b6:	85ba                	mv	a1,a4
    37b8:	853e                	mv	a0,a5
    37ba:	00004097          	auipc	ra,0x4
    37be:	106080e7          	jalr	262(ra) # 78c0 <read>
    37c2:	87aa                	mv	a5,a0
    37c4:	f2f04ae3          	bgtz	a5,36f8 <concreate+0x186>
    }
  }
  close(fd);
    37c8:	fe442783          	lw	a5,-28(s0)
    37cc:	853e                	mv	a0,a5
    37ce:	00004097          	auipc	ra,0x4
    37d2:	102080e7          	jalr	258(ra) # 78d0 <close>

  if(n != N){
    37d6:	fe842783          	lw	a5,-24(s0)
    37da:	0007871b          	sext.w	a4,a5
    37de:	02800793          	li	a5,40
    37e2:	02f70163          	beq	a4,a5,3804 <concreate+0x292>
    printf("%s: concreate not enough files in directory listing\n", s);
    37e6:	f8843583          	ld	a1,-120(s0)
    37ea:	00005517          	auipc	a0,0x5
    37ee:	79650513          	addi	a0,a0,1942 # 8f80 <malloc+0xf9e>
    37f2:	00004097          	auipc	ra,0x4
    37f6:	5fe080e7          	jalr	1534(ra) # 7df0 <printf>
    exit(1);
    37fa:	4505                	li	a0,1
    37fc:	00004097          	auipc	ra,0x4
    3800:	0ac080e7          	jalr	172(ra) # 78a8 <exit>
  }

  for(i = 0; i < N; i++){
    3804:	fe042623          	sw	zero,-20(s0)
    3808:	a25d                	j	39ae <concreate+0x43c>
    file[1] = '0' + i;
    380a:	fec42783          	lw	a5,-20(s0)
    380e:	0ff7f793          	zext.b	a5,a5
    3812:	0307879b          	addiw	a5,a5,48
    3816:	0ff7f793          	zext.b	a5,a5
    381a:	fcf40ca3          	sb	a5,-39(s0)
    pid = fork();
    381e:	00004097          	auipc	ra,0x4
    3822:	082080e7          	jalr	130(ra) # 78a0 <fork>
    3826:	87aa                	mv	a5,a0
    3828:	fef42023          	sw	a5,-32(s0)
    if(pid < 0){
    382c:	fe042783          	lw	a5,-32(s0)
    3830:	2781                	sext.w	a5,a5
    3832:	0207d163          	bgez	a5,3854 <concreate+0x2e2>
      printf("%s: fork failed\n", s);
    3836:	f8843583          	ld	a1,-120(s0)
    383a:	00005517          	auipc	a0,0x5
    383e:	d2650513          	addi	a0,a0,-730 # 8560 <malloc+0x57e>
    3842:	00004097          	auipc	ra,0x4
    3846:	5ae080e7          	jalr	1454(ra) # 7df0 <printf>
      exit(1);
    384a:	4505                	li	a0,1
    384c:	00004097          	auipc	ra,0x4
    3850:	05c080e7          	jalr	92(ra) # 78a8 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    3854:	fec42783          	lw	a5,-20(s0)
    3858:	873e                	mv	a4,a5
    385a:	478d                	li	a5,3
    385c:	02f767bb          	remw	a5,a4,a5
    3860:	2781                	sext.w	a5,a5
    3862:	e789                	bnez	a5,386c <concreate+0x2fa>
    3864:	fe042783          	lw	a5,-32(s0)
    3868:	2781                	sext.w	a5,a5
    386a:	c385                	beqz	a5,388a <concreate+0x318>
       ((i % 3) == 1 && pid != 0)){
    386c:	fec42783          	lw	a5,-20(s0)
    3870:	873e                	mv	a4,a5
    3872:	478d                	li	a5,3
    3874:	02f767bb          	remw	a5,a4,a5
    3878:	2781                	sext.w	a5,a5
    if(((i % 3) == 0 && pid == 0) ||
    387a:	873e                	mv	a4,a5
    387c:	4785                	li	a5,1
    387e:	0af71b63          	bne	a4,a5,3934 <concreate+0x3c2>
       ((i % 3) == 1 && pid != 0)){
    3882:	fe042783          	lw	a5,-32(s0)
    3886:	2781                	sext.w	a5,a5
    3888:	c7d5                	beqz	a5,3934 <concreate+0x3c2>
      close(open(file, 0));
    388a:	fd840793          	addi	a5,s0,-40
    388e:	4581                	li	a1,0
    3890:	853e                	mv	a0,a5
    3892:	00004097          	auipc	ra,0x4
    3896:	056080e7          	jalr	86(ra) # 78e8 <open>
    389a:	87aa                	mv	a5,a0
    389c:	853e                	mv	a0,a5
    389e:	00004097          	auipc	ra,0x4
    38a2:	032080e7          	jalr	50(ra) # 78d0 <close>
      close(open(file, 0));
    38a6:	fd840793          	addi	a5,s0,-40
    38aa:	4581                	li	a1,0
    38ac:	853e                	mv	a0,a5
    38ae:	00004097          	auipc	ra,0x4
    38b2:	03a080e7          	jalr	58(ra) # 78e8 <open>
    38b6:	87aa                	mv	a5,a0
    38b8:	853e                	mv	a0,a5
    38ba:	00004097          	auipc	ra,0x4
    38be:	016080e7          	jalr	22(ra) # 78d0 <close>
      close(open(file, 0));
    38c2:	fd840793          	addi	a5,s0,-40
    38c6:	4581                	li	a1,0
    38c8:	853e                	mv	a0,a5
    38ca:	00004097          	auipc	ra,0x4
    38ce:	01e080e7          	jalr	30(ra) # 78e8 <open>
    38d2:	87aa                	mv	a5,a0
    38d4:	853e                	mv	a0,a5
    38d6:	00004097          	auipc	ra,0x4
    38da:	ffa080e7          	jalr	-6(ra) # 78d0 <close>
      close(open(file, 0));
    38de:	fd840793          	addi	a5,s0,-40
    38e2:	4581                	li	a1,0
    38e4:	853e                	mv	a0,a5
    38e6:	00004097          	auipc	ra,0x4
    38ea:	002080e7          	jalr	2(ra) # 78e8 <open>
    38ee:	87aa                	mv	a5,a0
    38f0:	853e                	mv	a0,a5
    38f2:	00004097          	auipc	ra,0x4
    38f6:	fde080e7          	jalr	-34(ra) # 78d0 <close>
      close(open(file, 0));
    38fa:	fd840793          	addi	a5,s0,-40
    38fe:	4581                	li	a1,0
    3900:	853e                	mv	a0,a5
    3902:	00004097          	auipc	ra,0x4
    3906:	fe6080e7          	jalr	-26(ra) # 78e8 <open>
    390a:	87aa                	mv	a5,a0
    390c:	853e                	mv	a0,a5
    390e:	00004097          	auipc	ra,0x4
    3912:	fc2080e7          	jalr	-62(ra) # 78d0 <close>
      close(open(file, 0));
    3916:	fd840793          	addi	a5,s0,-40
    391a:	4581                	li	a1,0
    391c:	853e                	mv	a0,a5
    391e:	00004097          	auipc	ra,0x4
    3922:	fca080e7          	jalr	-54(ra) # 78e8 <open>
    3926:	87aa                	mv	a5,a0
    3928:	853e                	mv	a0,a5
    392a:	00004097          	auipc	ra,0x4
    392e:	fa6080e7          	jalr	-90(ra) # 78d0 <close>
    3932:	a899                	j	3988 <concreate+0x416>
    } else {
      unlink(file);
    3934:	fd840793          	addi	a5,s0,-40
    3938:	853e                	mv	a0,a5
    393a:	00004097          	auipc	ra,0x4
    393e:	fbe080e7          	jalr	-66(ra) # 78f8 <unlink>
      unlink(file);
    3942:	fd840793          	addi	a5,s0,-40
    3946:	853e                	mv	a0,a5
    3948:	00004097          	auipc	ra,0x4
    394c:	fb0080e7          	jalr	-80(ra) # 78f8 <unlink>
      unlink(file);
    3950:	fd840793          	addi	a5,s0,-40
    3954:	853e                	mv	a0,a5
    3956:	00004097          	auipc	ra,0x4
    395a:	fa2080e7          	jalr	-94(ra) # 78f8 <unlink>
      unlink(file);
    395e:	fd840793          	addi	a5,s0,-40
    3962:	853e                	mv	a0,a5
    3964:	00004097          	auipc	ra,0x4
    3968:	f94080e7          	jalr	-108(ra) # 78f8 <unlink>
      unlink(file);
    396c:	fd840793          	addi	a5,s0,-40
    3970:	853e                	mv	a0,a5
    3972:	00004097          	auipc	ra,0x4
    3976:	f86080e7          	jalr	-122(ra) # 78f8 <unlink>
      unlink(file);
    397a:	fd840793          	addi	a5,s0,-40
    397e:	853e                	mv	a0,a5
    3980:	00004097          	auipc	ra,0x4
    3984:	f78080e7          	jalr	-136(ra) # 78f8 <unlink>
    }
    if(pid == 0)
    3988:	fe042783          	lw	a5,-32(s0)
    398c:	2781                	sext.w	a5,a5
    398e:	e791                	bnez	a5,399a <concreate+0x428>
      exit(0);
    3990:	4501                	li	a0,0
    3992:	00004097          	auipc	ra,0x4
    3996:	f16080e7          	jalr	-234(ra) # 78a8 <exit>
    else
      wait(0);
    399a:	4501                	li	a0,0
    399c:	00004097          	auipc	ra,0x4
    39a0:	f14080e7          	jalr	-236(ra) # 78b0 <wait>
  for(i = 0; i < N; i++){
    39a4:	fec42783          	lw	a5,-20(s0)
    39a8:	2785                	addiw	a5,a5,1
    39aa:	fef42623          	sw	a5,-20(s0)
    39ae:	fec42783          	lw	a5,-20(s0)
    39b2:	0007871b          	sext.w	a4,a5
    39b6:	02700793          	li	a5,39
    39ba:	e4e7d8e3          	bge	a5,a4,380a <concreate+0x298>
  }
}
    39be:	0001                	nop
    39c0:	0001                	nop
    39c2:	70e6                	ld	ra,120(sp)
    39c4:	7446                	ld	s0,112(sp)
    39c6:	6109                	addi	sp,sp,128
    39c8:	8082                	ret

00000000000039ca <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink(char *s)
{
    39ca:	7179                	addi	sp,sp,-48
    39cc:	f406                	sd	ra,40(sp)
    39ce:	f022                	sd	s0,32(sp)
    39d0:	1800                	addi	s0,sp,48
    39d2:	fca43c23          	sd	a0,-40(s0)
  int pid, i;

  unlink("x");
    39d6:	00005517          	auipc	a0,0x5
    39da:	85a50513          	addi	a0,a0,-1958 # 8230 <malloc+0x24e>
    39de:	00004097          	auipc	ra,0x4
    39e2:	f1a080e7          	jalr	-230(ra) # 78f8 <unlink>
  pid = fork();
    39e6:	00004097          	auipc	ra,0x4
    39ea:	eba080e7          	jalr	-326(ra) # 78a0 <fork>
    39ee:	87aa                	mv	a5,a0
    39f0:	fef42223          	sw	a5,-28(s0)
  if(pid < 0){
    39f4:	fe442783          	lw	a5,-28(s0)
    39f8:	2781                	sext.w	a5,a5
    39fa:	0207d163          	bgez	a5,3a1c <linkunlink+0x52>
    printf("%s: fork failed\n", s);
    39fe:	fd843583          	ld	a1,-40(s0)
    3a02:	00005517          	auipc	a0,0x5
    3a06:	b5e50513          	addi	a0,a0,-1186 # 8560 <malloc+0x57e>
    3a0a:	00004097          	auipc	ra,0x4
    3a0e:	3e6080e7          	jalr	998(ra) # 7df0 <printf>
    exit(1);
    3a12:	4505                	li	a0,1
    3a14:	00004097          	auipc	ra,0x4
    3a18:	e94080e7          	jalr	-364(ra) # 78a8 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    3a1c:	fe442783          	lw	a5,-28(s0)
    3a20:	2781                	sext.w	a5,a5
    3a22:	c399                	beqz	a5,3a28 <linkunlink+0x5e>
    3a24:	4785                	li	a5,1
    3a26:	a019                	j	3a2c <linkunlink+0x62>
    3a28:	06100793          	li	a5,97
    3a2c:	fef42423          	sw	a5,-24(s0)
  for(i = 0; i < 100; i++){
    3a30:	fe042623          	sw	zero,-20(s0)
    3a34:	a045                	j	3ad4 <linkunlink+0x10a>
    x = x * 1103515245 + 12345;
    3a36:	fe842783          	lw	a5,-24(s0)
    3a3a:	873e                	mv	a4,a5
    3a3c:	41c657b7          	lui	a5,0x41c65
    3a40:	e6d7879b          	addiw	a5,a5,-403 # 41c64e6d <freep+0x41c531d5>
    3a44:	02f707bb          	mulw	a5,a4,a5
    3a48:	0007871b          	sext.w	a4,a5
    3a4c:	678d                	lui	a5,0x3
    3a4e:	0397879b          	addiw	a5,a5,57 # 3039 <createdelete+0x2bf>
    3a52:	9fb9                	addw	a5,a5,a4
    3a54:	fef42423          	sw	a5,-24(s0)
    if((x % 3) == 0){
    3a58:	fe842783          	lw	a5,-24(s0)
    3a5c:	873e                	mv	a4,a5
    3a5e:	478d                	li	a5,3
    3a60:	02f777bb          	remuw	a5,a4,a5
    3a64:	2781                	sext.w	a5,a5
    3a66:	e395                	bnez	a5,3a8a <linkunlink+0xc0>
      close(open("x", O_RDWR | O_CREATE));
    3a68:	20200593          	li	a1,514
    3a6c:	00004517          	auipc	a0,0x4
    3a70:	7c450513          	addi	a0,a0,1988 # 8230 <malloc+0x24e>
    3a74:	00004097          	auipc	ra,0x4
    3a78:	e74080e7          	jalr	-396(ra) # 78e8 <open>
    3a7c:	87aa                	mv	a5,a0
    3a7e:	853e                	mv	a0,a5
    3a80:	00004097          	auipc	ra,0x4
    3a84:	e50080e7          	jalr	-432(ra) # 78d0 <close>
    3a88:	a089                	j	3aca <linkunlink+0x100>
    } else if((x % 3) == 1){
    3a8a:	fe842783          	lw	a5,-24(s0)
    3a8e:	873e                	mv	a4,a5
    3a90:	478d                	li	a5,3
    3a92:	02f777bb          	remuw	a5,a4,a5
    3a96:	2781                	sext.w	a5,a5
    3a98:	873e                	mv	a4,a5
    3a9a:	4785                	li	a5,1
    3a9c:	00f71f63          	bne	a4,a5,3aba <linkunlink+0xf0>
      link("cat", "x");
    3aa0:	00004597          	auipc	a1,0x4
    3aa4:	79058593          	addi	a1,a1,1936 # 8230 <malloc+0x24e>
    3aa8:	00005517          	auipc	a0,0x5
    3aac:	51050513          	addi	a0,a0,1296 # 8fb8 <malloc+0xfd6>
    3ab0:	00004097          	auipc	ra,0x4
    3ab4:	e58080e7          	jalr	-424(ra) # 7908 <link>
    3ab8:	a809                	j	3aca <linkunlink+0x100>
    } else {
      unlink("x");
    3aba:	00004517          	auipc	a0,0x4
    3abe:	77650513          	addi	a0,a0,1910 # 8230 <malloc+0x24e>
    3ac2:	00004097          	auipc	ra,0x4
    3ac6:	e36080e7          	jalr	-458(ra) # 78f8 <unlink>
  for(i = 0; i < 100; i++){
    3aca:	fec42783          	lw	a5,-20(s0)
    3ace:	2785                	addiw	a5,a5,1
    3ad0:	fef42623          	sw	a5,-20(s0)
    3ad4:	fec42783          	lw	a5,-20(s0)
    3ad8:	0007871b          	sext.w	a4,a5
    3adc:	06300793          	li	a5,99
    3ae0:	f4e7dbe3          	bge	a5,a4,3a36 <linkunlink+0x6c>
    }
  }

  if(pid)
    3ae4:	fe442783          	lw	a5,-28(s0)
    3ae8:	2781                	sext.w	a5,a5
    3aea:	c799                	beqz	a5,3af8 <linkunlink+0x12e>
    wait(0);
    3aec:	4501                	li	a0,0
    3aee:	00004097          	auipc	ra,0x4
    3af2:	dc2080e7          	jalr	-574(ra) # 78b0 <wait>
  else
    exit(0);
}
    3af6:	a031                	j	3b02 <linkunlink+0x138>
    exit(0);
    3af8:	4501                	li	a0,0
    3afa:	00004097          	auipc	ra,0x4
    3afe:	dae080e7          	jalr	-594(ra) # 78a8 <exit>
}
    3b02:	70a2                	ld	ra,40(sp)
    3b04:	7402                	ld	s0,32(sp)
    3b06:	6145                	addi	sp,sp,48
    3b08:	8082                	ret

0000000000003b0a <subdir>:


void
subdir(char *s)
{
    3b0a:	7179                	addi	sp,sp,-48
    3b0c:	f406                	sd	ra,40(sp)
    3b0e:	f022                	sd	s0,32(sp)
    3b10:	1800                	addi	s0,sp,48
    3b12:	fca43c23          	sd	a0,-40(s0)
  int fd, cc;

  unlink("ff");
    3b16:	00005517          	auipc	a0,0x5
    3b1a:	4aa50513          	addi	a0,a0,1194 # 8fc0 <malloc+0xfde>
    3b1e:	00004097          	auipc	ra,0x4
    3b22:	dda080e7          	jalr	-550(ra) # 78f8 <unlink>
  if(mkdir("dd") != 0){
    3b26:	00005517          	auipc	a0,0x5
    3b2a:	4a250513          	addi	a0,a0,1186 # 8fc8 <malloc+0xfe6>
    3b2e:	00004097          	auipc	ra,0x4
    3b32:	de2080e7          	jalr	-542(ra) # 7910 <mkdir>
    3b36:	87aa                	mv	a5,a0
    3b38:	c385                	beqz	a5,3b58 <subdir+0x4e>
    printf("%s: mkdir dd failed\n", s);
    3b3a:	fd843583          	ld	a1,-40(s0)
    3b3e:	00005517          	auipc	a0,0x5
    3b42:	49250513          	addi	a0,a0,1170 # 8fd0 <malloc+0xfee>
    3b46:	00004097          	auipc	ra,0x4
    3b4a:	2aa080e7          	jalr	682(ra) # 7df0 <printf>
    exit(1);
    3b4e:	4505                	li	a0,1
    3b50:	00004097          	auipc	ra,0x4
    3b54:	d58080e7          	jalr	-680(ra) # 78a8 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    3b58:	20200593          	li	a1,514
    3b5c:	00005517          	auipc	a0,0x5
    3b60:	48c50513          	addi	a0,a0,1164 # 8fe8 <malloc+0x1006>
    3b64:	00004097          	auipc	ra,0x4
    3b68:	d84080e7          	jalr	-636(ra) # 78e8 <open>
    3b6c:	87aa                	mv	a5,a0
    3b6e:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    3b72:	fec42783          	lw	a5,-20(s0)
    3b76:	2781                	sext.w	a5,a5
    3b78:	0207d163          	bgez	a5,3b9a <subdir+0x90>
    printf("%s: create dd/ff failed\n", s);
    3b7c:	fd843583          	ld	a1,-40(s0)
    3b80:	00005517          	auipc	a0,0x5
    3b84:	47050513          	addi	a0,a0,1136 # 8ff0 <malloc+0x100e>
    3b88:	00004097          	auipc	ra,0x4
    3b8c:	268080e7          	jalr	616(ra) # 7df0 <printf>
    exit(1);
    3b90:	4505                	li	a0,1
    3b92:	00004097          	auipc	ra,0x4
    3b96:	d16080e7          	jalr	-746(ra) # 78a8 <exit>
  }
  write(fd, "ff", 2);
    3b9a:	fec42783          	lw	a5,-20(s0)
    3b9e:	4609                	li	a2,2
    3ba0:	00005597          	auipc	a1,0x5
    3ba4:	42058593          	addi	a1,a1,1056 # 8fc0 <malloc+0xfde>
    3ba8:	853e                	mv	a0,a5
    3baa:	00004097          	auipc	ra,0x4
    3bae:	d1e080e7          	jalr	-738(ra) # 78c8 <write>
  close(fd);
    3bb2:	fec42783          	lw	a5,-20(s0)
    3bb6:	853e                	mv	a0,a5
    3bb8:	00004097          	auipc	ra,0x4
    3bbc:	d18080e7          	jalr	-744(ra) # 78d0 <close>

  if(unlink("dd") >= 0){
    3bc0:	00005517          	auipc	a0,0x5
    3bc4:	40850513          	addi	a0,a0,1032 # 8fc8 <malloc+0xfe6>
    3bc8:	00004097          	auipc	ra,0x4
    3bcc:	d30080e7          	jalr	-720(ra) # 78f8 <unlink>
    3bd0:	87aa                	mv	a5,a0
    3bd2:	0207c163          	bltz	a5,3bf4 <subdir+0xea>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3bd6:	fd843583          	ld	a1,-40(s0)
    3bda:	00005517          	auipc	a0,0x5
    3bde:	43650513          	addi	a0,a0,1078 # 9010 <malloc+0x102e>
    3be2:	00004097          	auipc	ra,0x4
    3be6:	20e080e7          	jalr	526(ra) # 7df0 <printf>
    exit(1);
    3bea:	4505                	li	a0,1
    3bec:	00004097          	auipc	ra,0x4
    3bf0:	cbc080e7          	jalr	-836(ra) # 78a8 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    3bf4:	00005517          	auipc	a0,0x5
    3bf8:	44c50513          	addi	a0,a0,1100 # 9040 <malloc+0x105e>
    3bfc:	00004097          	auipc	ra,0x4
    3c00:	d14080e7          	jalr	-748(ra) # 7910 <mkdir>
    3c04:	87aa                	mv	a5,a0
    3c06:	c385                	beqz	a5,3c26 <subdir+0x11c>
    printf("subdir mkdir dd/dd failed\n", s);
    3c08:	fd843583          	ld	a1,-40(s0)
    3c0c:	00005517          	auipc	a0,0x5
    3c10:	43c50513          	addi	a0,a0,1084 # 9048 <malloc+0x1066>
    3c14:	00004097          	auipc	ra,0x4
    3c18:	1dc080e7          	jalr	476(ra) # 7df0 <printf>
    exit(1);
    3c1c:	4505                	li	a0,1
    3c1e:	00004097          	auipc	ra,0x4
    3c22:	c8a080e7          	jalr	-886(ra) # 78a8 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3c26:	20200593          	li	a1,514
    3c2a:	00005517          	auipc	a0,0x5
    3c2e:	43e50513          	addi	a0,a0,1086 # 9068 <malloc+0x1086>
    3c32:	00004097          	auipc	ra,0x4
    3c36:	cb6080e7          	jalr	-842(ra) # 78e8 <open>
    3c3a:	87aa                	mv	a5,a0
    3c3c:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    3c40:	fec42783          	lw	a5,-20(s0)
    3c44:	2781                	sext.w	a5,a5
    3c46:	0207d163          	bgez	a5,3c68 <subdir+0x15e>
    printf("%s: create dd/dd/ff failed\n", s);
    3c4a:	fd843583          	ld	a1,-40(s0)
    3c4e:	00005517          	auipc	a0,0x5
    3c52:	42a50513          	addi	a0,a0,1066 # 9078 <malloc+0x1096>
    3c56:	00004097          	auipc	ra,0x4
    3c5a:	19a080e7          	jalr	410(ra) # 7df0 <printf>
    exit(1);
    3c5e:	4505                	li	a0,1
    3c60:	00004097          	auipc	ra,0x4
    3c64:	c48080e7          	jalr	-952(ra) # 78a8 <exit>
  }
  write(fd, "FF", 2);
    3c68:	fec42783          	lw	a5,-20(s0)
    3c6c:	4609                	li	a2,2
    3c6e:	00005597          	auipc	a1,0x5
    3c72:	42a58593          	addi	a1,a1,1066 # 9098 <malloc+0x10b6>
    3c76:	853e                	mv	a0,a5
    3c78:	00004097          	auipc	ra,0x4
    3c7c:	c50080e7          	jalr	-944(ra) # 78c8 <write>
  close(fd);
    3c80:	fec42783          	lw	a5,-20(s0)
    3c84:	853e                	mv	a0,a5
    3c86:	00004097          	auipc	ra,0x4
    3c8a:	c4a080e7          	jalr	-950(ra) # 78d0 <close>

  fd = open("dd/dd/../ff", 0);
    3c8e:	4581                	li	a1,0
    3c90:	00005517          	auipc	a0,0x5
    3c94:	41050513          	addi	a0,a0,1040 # 90a0 <malloc+0x10be>
    3c98:	00004097          	auipc	ra,0x4
    3c9c:	c50080e7          	jalr	-944(ra) # 78e8 <open>
    3ca0:	87aa                	mv	a5,a0
    3ca2:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    3ca6:	fec42783          	lw	a5,-20(s0)
    3caa:	2781                	sext.w	a5,a5
    3cac:	0207d163          	bgez	a5,3cce <subdir+0x1c4>
    printf("%s: open dd/dd/../ff failed\n", s);
    3cb0:	fd843583          	ld	a1,-40(s0)
    3cb4:	00005517          	auipc	a0,0x5
    3cb8:	3fc50513          	addi	a0,a0,1020 # 90b0 <malloc+0x10ce>
    3cbc:	00004097          	auipc	ra,0x4
    3cc0:	134080e7          	jalr	308(ra) # 7df0 <printf>
    exit(1);
    3cc4:	4505                	li	a0,1
    3cc6:	00004097          	auipc	ra,0x4
    3cca:	be2080e7          	jalr	-1054(ra) # 78a8 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    3cce:	fec42783          	lw	a5,-20(s0)
    3cd2:	660d                	lui	a2,0x3
    3cd4:	00007597          	auipc	a1,0x7
    3cd8:	79c58593          	addi	a1,a1,1948 # b470 <buf>
    3cdc:	853e                	mv	a0,a5
    3cde:	00004097          	auipc	ra,0x4
    3ce2:	be2080e7          	jalr	-1054(ra) # 78c0 <read>
    3ce6:	87aa                	mv	a5,a0
    3ce8:	fef42423          	sw	a5,-24(s0)
  if(cc != 2 || buf[0] != 'f'){
    3cec:	fe842783          	lw	a5,-24(s0)
    3cf0:	0007871b          	sext.w	a4,a5
    3cf4:	4789                	li	a5,2
    3cf6:	00f71d63          	bne	a4,a5,3d10 <subdir+0x206>
    3cfa:	00007797          	auipc	a5,0x7
    3cfe:	77678793          	addi	a5,a5,1910 # b470 <buf>
    3d02:	0007c783          	lbu	a5,0(a5)
    3d06:	873e                	mv	a4,a5
    3d08:	06600793          	li	a5,102
    3d0c:	02f70163          	beq	a4,a5,3d2e <subdir+0x224>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3d10:	fd843583          	ld	a1,-40(s0)
    3d14:	00005517          	auipc	a0,0x5
    3d18:	3bc50513          	addi	a0,a0,956 # 90d0 <malloc+0x10ee>
    3d1c:	00004097          	auipc	ra,0x4
    3d20:	0d4080e7          	jalr	212(ra) # 7df0 <printf>
    exit(1);
    3d24:	4505                	li	a0,1
    3d26:	00004097          	auipc	ra,0x4
    3d2a:	b82080e7          	jalr	-1150(ra) # 78a8 <exit>
  }
  close(fd);
    3d2e:	fec42783          	lw	a5,-20(s0)
    3d32:	853e                	mv	a0,a5
    3d34:	00004097          	auipc	ra,0x4
    3d38:	b9c080e7          	jalr	-1124(ra) # 78d0 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3d3c:	00005597          	auipc	a1,0x5
    3d40:	3b458593          	addi	a1,a1,948 # 90f0 <malloc+0x110e>
    3d44:	00005517          	auipc	a0,0x5
    3d48:	32450513          	addi	a0,a0,804 # 9068 <malloc+0x1086>
    3d4c:	00004097          	auipc	ra,0x4
    3d50:	bbc080e7          	jalr	-1092(ra) # 7908 <link>
    3d54:	87aa                	mv	a5,a0
    3d56:	c385                	beqz	a5,3d76 <subdir+0x26c>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3d58:	fd843583          	ld	a1,-40(s0)
    3d5c:	00005517          	auipc	a0,0x5
    3d60:	3a450513          	addi	a0,a0,932 # 9100 <malloc+0x111e>
    3d64:	00004097          	auipc	ra,0x4
    3d68:	08c080e7          	jalr	140(ra) # 7df0 <printf>
    exit(1);
    3d6c:	4505                	li	a0,1
    3d6e:	00004097          	auipc	ra,0x4
    3d72:	b3a080e7          	jalr	-1222(ra) # 78a8 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    3d76:	00005517          	auipc	a0,0x5
    3d7a:	2f250513          	addi	a0,a0,754 # 9068 <malloc+0x1086>
    3d7e:	00004097          	auipc	ra,0x4
    3d82:	b7a080e7          	jalr	-1158(ra) # 78f8 <unlink>
    3d86:	87aa                	mv	a5,a0
    3d88:	c385                	beqz	a5,3da8 <subdir+0x29e>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3d8a:	fd843583          	ld	a1,-40(s0)
    3d8e:	00005517          	auipc	a0,0x5
    3d92:	39a50513          	addi	a0,a0,922 # 9128 <malloc+0x1146>
    3d96:	00004097          	auipc	ra,0x4
    3d9a:	05a080e7          	jalr	90(ra) # 7df0 <printf>
    exit(1);
    3d9e:	4505                	li	a0,1
    3da0:	00004097          	auipc	ra,0x4
    3da4:	b08080e7          	jalr	-1272(ra) # 78a8 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3da8:	4581                	li	a1,0
    3daa:	00005517          	auipc	a0,0x5
    3dae:	2be50513          	addi	a0,a0,702 # 9068 <malloc+0x1086>
    3db2:	00004097          	auipc	ra,0x4
    3db6:	b36080e7          	jalr	-1226(ra) # 78e8 <open>
    3dba:	87aa                	mv	a5,a0
    3dbc:	0207c163          	bltz	a5,3dde <subdir+0x2d4>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3dc0:	fd843583          	ld	a1,-40(s0)
    3dc4:	00005517          	auipc	a0,0x5
    3dc8:	38450513          	addi	a0,a0,900 # 9148 <malloc+0x1166>
    3dcc:	00004097          	auipc	ra,0x4
    3dd0:	024080e7          	jalr	36(ra) # 7df0 <printf>
    exit(1);
    3dd4:	4505                	li	a0,1
    3dd6:	00004097          	auipc	ra,0x4
    3dda:	ad2080e7          	jalr	-1326(ra) # 78a8 <exit>
  }

  if(chdir("dd") != 0){
    3dde:	00005517          	auipc	a0,0x5
    3de2:	1ea50513          	addi	a0,a0,490 # 8fc8 <malloc+0xfe6>
    3de6:	00004097          	auipc	ra,0x4
    3dea:	b32080e7          	jalr	-1230(ra) # 7918 <chdir>
    3dee:	87aa                	mv	a5,a0
    3df0:	c385                	beqz	a5,3e10 <subdir+0x306>
    printf("%s: chdir dd failed\n", s);
    3df2:	fd843583          	ld	a1,-40(s0)
    3df6:	00005517          	auipc	a0,0x5
    3dfa:	37a50513          	addi	a0,a0,890 # 9170 <malloc+0x118e>
    3dfe:	00004097          	auipc	ra,0x4
    3e02:	ff2080e7          	jalr	-14(ra) # 7df0 <printf>
    exit(1);
    3e06:	4505                	li	a0,1
    3e08:	00004097          	auipc	ra,0x4
    3e0c:	aa0080e7          	jalr	-1376(ra) # 78a8 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    3e10:	00005517          	auipc	a0,0x5
    3e14:	37850513          	addi	a0,a0,888 # 9188 <malloc+0x11a6>
    3e18:	00004097          	auipc	ra,0x4
    3e1c:	b00080e7          	jalr	-1280(ra) # 7918 <chdir>
    3e20:	87aa                	mv	a5,a0
    3e22:	c385                	beqz	a5,3e42 <subdir+0x338>
    printf("%s: chdir dd/../../dd failed\n", s);
    3e24:	fd843583          	ld	a1,-40(s0)
    3e28:	00005517          	auipc	a0,0x5
    3e2c:	37050513          	addi	a0,a0,880 # 9198 <malloc+0x11b6>
    3e30:	00004097          	auipc	ra,0x4
    3e34:	fc0080e7          	jalr	-64(ra) # 7df0 <printf>
    exit(1);
    3e38:	4505                	li	a0,1
    3e3a:	00004097          	auipc	ra,0x4
    3e3e:	a6e080e7          	jalr	-1426(ra) # 78a8 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    3e42:	00005517          	auipc	a0,0x5
    3e46:	37650513          	addi	a0,a0,886 # 91b8 <malloc+0x11d6>
    3e4a:	00004097          	auipc	ra,0x4
    3e4e:	ace080e7          	jalr	-1330(ra) # 7918 <chdir>
    3e52:	87aa                	mv	a5,a0
    3e54:	c385                	beqz	a5,3e74 <subdir+0x36a>
    printf("chdir dd/../../dd failed\n", s);
    3e56:	fd843583          	ld	a1,-40(s0)
    3e5a:	00005517          	auipc	a0,0x5
    3e5e:	36e50513          	addi	a0,a0,878 # 91c8 <malloc+0x11e6>
    3e62:	00004097          	auipc	ra,0x4
    3e66:	f8e080e7          	jalr	-114(ra) # 7df0 <printf>
    exit(1);
    3e6a:	4505                	li	a0,1
    3e6c:	00004097          	auipc	ra,0x4
    3e70:	a3c080e7          	jalr	-1476(ra) # 78a8 <exit>
  }
  if(chdir("./..") != 0){
    3e74:	00005517          	auipc	a0,0x5
    3e78:	37450513          	addi	a0,a0,884 # 91e8 <malloc+0x1206>
    3e7c:	00004097          	auipc	ra,0x4
    3e80:	a9c080e7          	jalr	-1380(ra) # 7918 <chdir>
    3e84:	87aa                	mv	a5,a0
    3e86:	c385                	beqz	a5,3ea6 <subdir+0x39c>
    printf("%s: chdir ./.. failed\n", s);
    3e88:	fd843583          	ld	a1,-40(s0)
    3e8c:	00005517          	auipc	a0,0x5
    3e90:	36450513          	addi	a0,a0,868 # 91f0 <malloc+0x120e>
    3e94:	00004097          	auipc	ra,0x4
    3e98:	f5c080e7          	jalr	-164(ra) # 7df0 <printf>
    exit(1);
    3e9c:	4505                	li	a0,1
    3e9e:	00004097          	auipc	ra,0x4
    3ea2:	a0a080e7          	jalr	-1526(ra) # 78a8 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    3ea6:	4581                	li	a1,0
    3ea8:	00005517          	auipc	a0,0x5
    3eac:	24850513          	addi	a0,a0,584 # 90f0 <malloc+0x110e>
    3eb0:	00004097          	auipc	ra,0x4
    3eb4:	a38080e7          	jalr	-1480(ra) # 78e8 <open>
    3eb8:	87aa                	mv	a5,a0
    3eba:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    3ebe:	fec42783          	lw	a5,-20(s0)
    3ec2:	2781                	sext.w	a5,a5
    3ec4:	0207d163          	bgez	a5,3ee6 <subdir+0x3dc>
    printf("%s: open dd/dd/ffff failed\n", s);
    3ec8:	fd843583          	ld	a1,-40(s0)
    3ecc:	00005517          	auipc	a0,0x5
    3ed0:	33c50513          	addi	a0,a0,828 # 9208 <malloc+0x1226>
    3ed4:	00004097          	auipc	ra,0x4
    3ed8:	f1c080e7          	jalr	-228(ra) # 7df0 <printf>
    exit(1);
    3edc:	4505                	li	a0,1
    3ede:	00004097          	auipc	ra,0x4
    3ee2:	9ca080e7          	jalr	-1590(ra) # 78a8 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    3ee6:	fec42783          	lw	a5,-20(s0)
    3eea:	660d                	lui	a2,0x3
    3eec:	00007597          	auipc	a1,0x7
    3ef0:	58458593          	addi	a1,a1,1412 # b470 <buf>
    3ef4:	853e                	mv	a0,a5
    3ef6:	00004097          	auipc	ra,0x4
    3efa:	9ca080e7          	jalr	-1590(ra) # 78c0 <read>
    3efe:	87aa                	mv	a5,a0
    3f00:	873e                	mv	a4,a5
    3f02:	4789                	li	a5,2
    3f04:	02f70163          	beq	a4,a5,3f26 <subdir+0x41c>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3f08:	fd843583          	ld	a1,-40(s0)
    3f0c:	00005517          	auipc	a0,0x5
    3f10:	31c50513          	addi	a0,a0,796 # 9228 <malloc+0x1246>
    3f14:	00004097          	auipc	ra,0x4
    3f18:	edc080e7          	jalr	-292(ra) # 7df0 <printf>
    exit(1);
    3f1c:	4505                	li	a0,1
    3f1e:	00004097          	auipc	ra,0x4
    3f22:	98a080e7          	jalr	-1654(ra) # 78a8 <exit>
  }
  close(fd);
    3f26:	fec42783          	lw	a5,-20(s0)
    3f2a:	853e                	mv	a0,a5
    3f2c:	00004097          	auipc	ra,0x4
    3f30:	9a4080e7          	jalr	-1628(ra) # 78d0 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3f34:	4581                	li	a1,0
    3f36:	00005517          	auipc	a0,0x5
    3f3a:	13250513          	addi	a0,a0,306 # 9068 <malloc+0x1086>
    3f3e:	00004097          	auipc	ra,0x4
    3f42:	9aa080e7          	jalr	-1622(ra) # 78e8 <open>
    3f46:	87aa                	mv	a5,a0
    3f48:	0207c163          	bltz	a5,3f6a <subdir+0x460>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3f4c:	fd843583          	ld	a1,-40(s0)
    3f50:	00005517          	auipc	a0,0x5
    3f54:	2f850513          	addi	a0,a0,760 # 9248 <malloc+0x1266>
    3f58:	00004097          	auipc	ra,0x4
    3f5c:	e98080e7          	jalr	-360(ra) # 7df0 <printf>
    exit(1);
    3f60:	4505                	li	a0,1
    3f62:	00004097          	auipc	ra,0x4
    3f66:	946080e7          	jalr	-1722(ra) # 78a8 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3f6a:	20200593          	li	a1,514
    3f6e:	00005517          	auipc	a0,0x5
    3f72:	30a50513          	addi	a0,a0,778 # 9278 <malloc+0x1296>
    3f76:	00004097          	auipc	ra,0x4
    3f7a:	972080e7          	jalr	-1678(ra) # 78e8 <open>
    3f7e:	87aa                	mv	a5,a0
    3f80:	0207c163          	bltz	a5,3fa2 <subdir+0x498>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3f84:	fd843583          	ld	a1,-40(s0)
    3f88:	00005517          	auipc	a0,0x5
    3f8c:	30050513          	addi	a0,a0,768 # 9288 <malloc+0x12a6>
    3f90:	00004097          	auipc	ra,0x4
    3f94:	e60080e7          	jalr	-416(ra) # 7df0 <printf>
    exit(1);
    3f98:	4505                	li	a0,1
    3f9a:	00004097          	auipc	ra,0x4
    3f9e:	90e080e7          	jalr	-1778(ra) # 78a8 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3fa2:	20200593          	li	a1,514
    3fa6:	00005517          	auipc	a0,0x5
    3faa:	30250513          	addi	a0,a0,770 # 92a8 <malloc+0x12c6>
    3fae:	00004097          	auipc	ra,0x4
    3fb2:	93a080e7          	jalr	-1734(ra) # 78e8 <open>
    3fb6:	87aa                	mv	a5,a0
    3fb8:	0207c163          	bltz	a5,3fda <subdir+0x4d0>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3fbc:	fd843583          	ld	a1,-40(s0)
    3fc0:	00005517          	auipc	a0,0x5
    3fc4:	2f850513          	addi	a0,a0,760 # 92b8 <malloc+0x12d6>
    3fc8:	00004097          	auipc	ra,0x4
    3fcc:	e28080e7          	jalr	-472(ra) # 7df0 <printf>
    exit(1);
    3fd0:	4505                	li	a0,1
    3fd2:	00004097          	auipc	ra,0x4
    3fd6:	8d6080e7          	jalr	-1834(ra) # 78a8 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    3fda:	20000593          	li	a1,512
    3fde:	00005517          	auipc	a0,0x5
    3fe2:	fea50513          	addi	a0,a0,-22 # 8fc8 <malloc+0xfe6>
    3fe6:	00004097          	auipc	ra,0x4
    3fea:	902080e7          	jalr	-1790(ra) # 78e8 <open>
    3fee:	87aa                	mv	a5,a0
    3ff0:	0207c163          	bltz	a5,4012 <subdir+0x508>
    printf("%s: create dd succeeded!\n", s);
    3ff4:	fd843583          	ld	a1,-40(s0)
    3ff8:	00005517          	auipc	a0,0x5
    3ffc:	2e050513          	addi	a0,a0,736 # 92d8 <malloc+0x12f6>
    4000:	00004097          	auipc	ra,0x4
    4004:	df0080e7          	jalr	-528(ra) # 7df0 <printf>
    exit(1);
    4008:	4505                	li	a0,1
    400a:	00004097          	auipc	ra,0x4
    400e:	89e080e7          	jalr	-1890(ra) # 78a8 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    4012:	4589                	li	a1,2
    4014:	00005517          	auipc	a0,0x5
    4018:	fb450513          	addi	a0,a0,-76 # 8fc8 <malloc+0xfe6>
    401c:	00004097          	auipc	ra,0x4
    4020:	8cc080e7          	jalr	-1844(ra) # 78e8 <open>
    4024:	87aa                	mv	a5,a0
    4026:	0207c163          	bltz	a5,4048 <subdir+0x53e>
    printf("%s: open dd rdwr succeeded!\n", s);
    402a:	fd843583          	ld	a1,-40(s0)
    402e:	00005517          	auipc	a0,0x5
    4032:	2ca50513          	addi	a0,a0,714 # 92f8 <malloc+0x1316>
    4036:	00004097          	auipc	ra,0x4
    403a:	dba080e7          	jalr	-582(ra) # 7df0 <printf>
    exit(1);
    403e:	4505                	li	a0,1
    4040:	00004097          	auipc	ra,0x4
    4044:	868080e7          	jalr	-1944(ra) # 78a8 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    4048:	4585                	li	a1,1
    404a:	00005517          	auipc	a0,0x5
    404e:	f7e50513          	addi	a0,a0,-130 # 8fc8 <malloc+0xfe6>
    4052:	00004097          	auipc	ra,0x4
    4056:	896080e7          	jalr	-1898(ra) # 78e8 <open>
    405a:	87aa                	mv	a5,a0
    405c:	0207c163          	bltz	a5,407e <subdir+0x574>
    printf("%s: open dd wronly succeeded!\n", s);
    4060:	fd843583          	ld	a1,-40(s0)
    4064:	00005517          	auipc	a0,0x5
    4068:	2b450513          	addi	a0,a0,692 # 9318 <malloc+0x1336>
    406c:	00004097          	auipc	ra,0x4
    4070:	d84080e7          	jalr	-636(ra) # 7df0 <printf>
    exit(1);
    4074:	4505                	li	a0,1
    4076:	00004097          	auipc	ra,0x4
    407a:	832080e7          	jalr	-1998(ra) # 78a8 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    407e:	00005597          	auipc	a1,0x5
    4082:	2ba58593          	addi	a1,a1,698 # 9338 <malloc+0x1356>
    4086:	00005517          	auipc	a0,0x5
    408a:	1f250513          	addi	a0,a0,498 # 9278 <malloc+0x1296>
    408e:	00004097          	auipc	ra,0x4
    4092:	87a080e7          	jalr	-1926(ra) # 7908 <link>
    4096:	87aa                	mv	a5,a0
    4098:	e385                	bnez	a5,40b8 <subdir+0x5ae>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    409a:	fd843583          	ld	a1,-40(s0)
    409e:	00005517          	auipc	a0,0x5
    40a2:	2aa50513          	addi	a0,a0,682 # 9348 <malloc+0x1366>
    40a6:	00004097          	auipc	ra,0x4
    40aa:	d4a080e7          	jalr	-694(ra) # 7df0 <printf>
    exit(1);
    40ae:	4505                	li	a0,1
    40b0:	00003097          	auipc	ra,0x3
    40b4:	7f8080e7          	jalr	2040(ra) # 78a8 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    40b8:	00005597          	auipc	a1,0x5
    40bc:	28058593          	addi	a1,a1,640 # 9338 <malloc+0x1356>
    40c0:	00005517          	auipc	a0,0x5
    40c4:	1e850513          	addi	a0,a0,488 # 92a8 <malloc+0x12c6>
    40c8:	00004097          	auipc	ra,0x4
    40cc:	840080e7          	jalr	-1984(ra) # 7908 <link>
    40d0:	87aa                	mv	a5,a0
    40d2:	e385                	bnez	a5,40f2 <subdir+0x5e8>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    40d4:	fd843583          	ld	a1,-40(s0)
    40d8:	00005517          	auipc	a0,0x5
    40dc:	29850513          	addi	a0,a0,664 # 9370 <malloc+0x138e>
    40e0:	00004097          	auipc	ra,0x4
    40e4:	d10080e7          	jalr	-752(ra) # 7df0 <printf>
    exit(1);
    40e8:	4505                	li	a0,1
    40ea:	00003097          	auipc	ra,0x3
    40ee:	7be080e7          	jalr	1982(ra) # 78a8 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    40f2:	00005597          	auipc	a1,0x5
    40f6:	ffe58593          	addi	a1,a1,-2 # 90f0 <malloc+0x110e>
    40fa:	00005517          	auipc	a0,0x5
    40fe:	eee50513          	addi	a0,a0,-274 # 8fe8 <malloc+0x1006>
    4102:	00004097          	auipc	ra,0x4
    4106:	806080e7          	jalr	-2042(ra) # 7908 <link>
    410a:	87aa                	mv	a5,a0
    410c:	e385                	bnez	a5,412c <subdir+0x622>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    410e:	fd843583          	ld	a1,-40(s0)
    4112:	00005517          	auipc	a0,0x5
    4116:	28650513          	addi	a0,a0,646 # 9398 <malloc+0x13b6>
    411a:	00004097          	auipc	ra,0x4
    411e:	cd6080e7          	jalr	-810(ra) # 7df0 <printf>
    exit(1);
    4122:	4505                	li	a0,1
    4124:	00003097          	auipc	ra,0x3
    4128:	784080e7          	jalr	1924(ra) # 78a8 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    412c:	00005517          	auipc	a0,0x5
    4130:	14c50513          	addi	a0,a0,332 # 9278 <malloc+0x1296>
    4134:	00003097          	auipc	ra,0x3
    4138:	7dc080e7          	jalr	2012(ra) # 7910 <mkdir>
    413c:	87aa                	mv	a5,a0
    413e:	e385                	bnez	a5,415e <subdir+0x654>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    4140:	fd843583          	ld	a1,-40(s0)
    4144:	00005517          	auipc	a0,0x5
    4148:	27c50513          	addi	a0,a0,636 # 93c0 <malloc+0x13de>
    414c:	00004097          	auipc	ra,0x4
    4150:	ca4080e7          	jalr	-860(ra) # 7df0 <printf>
    exit(1);
    4154:	4505                	li	a0,1
    4156:	00003097          	auipc	ra,0x3
    415a:	752080e7          	jalr	1874(ra) # 78a8 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    415e:	00005517          	auipc	a0,0x5
    4162:	14a50513          	addi	a0,a0,330 # 92a8 <malloc+0x12c6>
    4166:	00003097          	auipc	ra,0x3
    416a:	7aa080e7          	jalr	1962(ra) # 7910 <mkdir>
    416e:	87aa                	mv	a5,a0
    4170:	e385                	bnez	a5,4190 <subdir+0x686>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    4172:	fd843583          	ld	a1,-40(s0)
    4176:	00005517          	auipc	a0,0x5
    417a:	26a50513          	addi	a0,a0,618 # 93e0 <malloc+0x13fe>
    417e:	00004097          	auipc	ra,0x4
    4182:	c72080e7          	jalr	-910(ra) # 7df0 <printf>
    exit(1);
    4186:	4505                	li	a0,1
    4188:	00003097          	auipc	ra,0x3
    418c:	720080e7          	jalr	1824(ra) # 78a8 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    4190:	00005517          	auipc	a0,0x5
    4194:	f6050513          	addi	a0,a0,-160 # 90f0 <malloc+0x110e>
    4198:	00003097          	auipc	ra,0x3
    419c:	778080e7          	jalr	1912(ra) # 7910 <mkdir>
    41a0:	87aa                	mv	a5,a0
    41a2:	e385                	bnez	a5,41c2 <subdir+0x6b8>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    41a4:	fd843583          	ld	a1,-40(s0)
    41a8:	00005517          	auipc	a0,0x5
    41ac:	25850513          	addi	a0,a0,600 # 9400 <malloc+0x141e>
    41b0:	00004097          	auipc	ra,0x4
    41b4:	c40080e7          	jalr	-960(ra) # 7df0 <printf>
    exit(1);
    41b8:	4505                	li	a0,1
    41ba:	00003097          	auipc	ra,0x3
    41be:	6ee080e7          	jalr	1774(ra) # 78a8 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    41c2:	00005517          	auipc	a0,0x5
    41c6:	0e650513          	addi	a0,a0,230 # 92a8 <malloc+0x12c6>
    41ca:	00003097          	auipc	ra,0x3
    41ce:	72e080e7          	jalr	1838(ra) # 78f8 <unlink>
    41d2:	87aa                	mv	a5,a0
    41d4:	e385                	bnez	a5,41f4 <subdir+0x6ea>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    41d6:	fd843583          	ld	a1,-40(s0)
    41da:	00005517          	auipc	a0,0x5
    41de:	24e50513          	addi	a0,a0,590 # 9428 <malloc+0x1446>
    41e2:	00004097          	auipc	ra,0x4
    41e6:	c0e080e7          	jalr	-1010(ra) # 7df0 <printf>
    exit(1);
    41ea:	4505                	li	a0,1
    41ec:	00003097          	auipc	ra,0x3
    41f0:	6bc080e7          	jalr	1724(ra) # 78a8 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    41f4:	00005517          	auipc	a0,0x5
    41f8:	08450513          	addi	a0,a0,132 # 9278 <malloc+0x1296>
    41fc:	00003097          	auipc	ra,0x3
    4200:	6fc080e7          	jalr	1788(ra) # 78f8 <unlink>
    4204:	87aa                	mv	a5,a0
    4206:	e385                	bnez	a5,4226 <subdir+0x71c>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    4208:	fd843583          	ld	a1,-40(s0)
    420c:	00005517          	auipc	a0,0x5
    4210:	23c50513          	addi	a0,a0,572 # 9448 <malloc+0x1466>
    4214:	00004097          	auipc	ra,0x4
    4218:	bdc080e7          	jalr	-1060(ra) # 7df0 <printf>
    exit(1);
    421c:	4505                	li	a0,1
    421e:	00003097          	auipc	ra,0x3
    4222:	68a080e7          	jalr	1674(ra) # 78a8 <exit>
  }
  if(chdir("dd/ff") == 0){
    4226:	00005517          	auipc	a0,0x5
    422a:	dc250513          	addi	a0,a0,-574 # 8fe8 <malloc+0x1006>
    422e:	00003097          	auipc	ra,0x3
    4232:	6ea080e7          	jalr	1770(ra) # 7918 <chdir>
    4236:	87aa                	mv	a5,a0
    4238:	e385                	bnez	a5,4258 <subdir+0x74e>
    printf("%s: chdir dd/ff succeeded!\n", s);
    423a:	fd843583          	ld	a1,-40(s0)
    423e:	00005517          	auipc	a0,0x5
    4242:	22a50513          	addi	a0,a0,554 # 9468 <malloc+0x1486>
    4246:	00004097          	auipc	ra,0x4
    424a:	baa080e7          	jalr	-1110(ra) # 7df0 <printf>
    exit(1);
    424e:	4505                	li	a0,1
    4250:	00003097          	auipc	ra,0x3
    4254:	658080e7          	jalr	1624(ra) # 78a8 <exit>
  }
  if(chdir("dd/xx") == 0){
    4258:	00005517          	auipc	a0,0x5
    425c:	23050513          	addi	a0,a0,560 # 9488 <malloc+0x14a6>
    4260:	00003097          	auipc	ra,0x3
    4264:	6b8080e7          	jalr	1720(ra) # 7918 <chdir>
    4268:	87aa                	mv	a5,a0
    426a:	e385                	bnez	a5,428a <subdir+0x780>
    printf("%s: chdir dd/xx succeeded!\n", s);
    426c:	fd843583          	ld	a1,-40(s0)
    4270:	00005517          	auipc	a0,0x5
    4274:	22050513          	addi	a0,a0,544 # 9490 <malloc+0x14ae>
    4278:	00004097          	auipc	ra,0x4
    427c:	b78080e7          	jalr	-1160(ra) # 7df0 <printf>
    exit(1);
    4280:	4505                	li	a0,1
    4282:	00003097          	auipc	ra,0x3
    4286:	626080e7          	jalr	1574(ra) # 78a8 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    428a:	00005517          	auipc	a0,0x5
    428e:	e6650513          	addi	a0,a0,-410 # 90f0 <malloc+0x110e>
    4292:	00003097          	auipc	ra,0x3
    4296:	666080e7          	jalr	1638(ra) # 78f8 <unlink>
    429a:	87aa                	mv	a5,a0
    429c:	c385                	beqz	a5,42bc <subdir+0x7b2>
    printf("%s: unlink dd/dd/ff failed\n", s);
    429e:	fd843583          	ld	a1,-40(s0)
    42a2:	00005517          	auipc	a0,0x5
    42a6:	e8650513          	addi	a0,a0,-378 # 9128 <malloc+0x1146>
    42aa:	00004097          	auipc	ra,0x4
    42ae:	b46080e7          	jalr	-1210(ra) # 7df0 <printf>
    exit(1);
    42b2:	4505                	li	a0,1
    42b4:	00003097          	auipc	ra,0x3
    42b8:	5f4080e7          	jalr	1524(ra) # 78a8 <exit>
  }
  if(unlink("dd/ff") != 0){
    42bc:	00005517          	auipc	a0,0x5
    42c0:	d2c50513          	addi	a0,a0,-724 # 8fe8 <malloc+0x1006>
    42c4:	00003097          	auipc	ra,0x3
    42c8:	634080e7          	jalr	1588(ra) # 78f8 <unlink>
    42cc:	87aa                	mv	a5,a0
    42ce:	c385                	beqz	a5,42ee <subdir+0x7e4>
    printf("%s: unlink dd/ff failed\n", s);
    42d0:	fd843583          	ld	a1,-40(s0)
    42d4:	00005517          	auipc	a0,0x5
    42d8:	1dc50513          	addi	a0,a0,476 # 94b0 <malloc+0x14ce>
    42dc:	00004097          	auipc	ra,0x4
    42e0:	b14080e7          	jalr	-1260(ra) # 7df0 <printf>
    exit(1);
    42e4:	4505                	li	a0,1
    42e6:	00003097          	auipc	ra,0x3
    42ea:	5c2080e7          	jalr	1474(ra) # 78a8 <exit>
  }
  if(unlink("dd") == 0){
    42ee:	00005517          	auipc	a0,0x5
    42f2:	cda50513          	addi	a0,a0,-806 # 8fc8 <malloc+0xfe6>
    42f6:	00003097          	auipc	ra,0x3
    42fa:	602080e7          	jalr	1538(ra) # 78f8 <unlink>
    42fe:	87aa                	mv	a5,a0
    4300:	e385                	bnez	a5,4320 <subdir+0x816>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    4302:	fd843583          	ld	a1,-40(s0)
    4306:	00005517          	auipc	a0,0x5
    430a:	1ca50513          	addi	a0,a0,458 # 94d0 <malloc+0x14ee>
    430e:	00004097          	auipc	ra,0x4
    4312:	ae2080e7          	jalr	-1310(ra) # 7df0 <printf>
    exit(1);
    4316:	4505                	li	a0,1
    4318:	00003097          	auipc	ra,0x3
    431c:	590080e7          	jalr	1424(ra) # 78a8 <exit>
  }
  if(unlink("dd/dd") < 0){
    4320:	00005517          	auipc	a0,0x5
    4324:	1d850513          	addi	a0,a0,472 # 94f8 <malloc+0x1516>
    4328:	00003097          	auipc	ra,0x3
    432c:	5d0080e7          	jalr	1488(ra) # 78f8 <unlink>
    4330:	87aa                	mv	a5,a0
    4332:	0207d163          	bgez	a5,4354 <subdir+0x84a>
    printf("%s: unlink dd/dd failed\n", s);
    4336:	fd843583          	ld	a1,-40(s0)
    433a:	00005517          	auipc	a0,0x5
    433e:	1c650513          	addi	a0,a0,454 # 9500 <malloc+0x151e>
    4342:	00004097          	auipc	ra,0x4
    4346:	aae080e7          	jalr	-1362(ra) # 7df0 <printf>
    exit(1);
    434a:	4505                	li	a0,1
    434c:	00003097          	auipc	ra,0x3
    4350:	55c080e7          	jalr	1372(ra) # 78a8 <exit>
  }
  if(unlink("dd") < 0){
    4354:	00005517          	auipc	a0,0x5
    4358:	c7450513          	addi	a0,a0,-908 # 8fc8 <malloc+0xfe6>
    435c:	00003097          	auipc	ra,0x3
    4360:	59c080e7          	jalr	1436(ra) # 78f8 <unlink>
    4364:	87aa                	mv	a5,a0
    4366:	0207d163          	bgez	a5,4388 <subdir+0x87e>
    printf("%s: unlink dd failed\n", s);
    436a:	fd843583          	ld	a1,-40(s0)
    436e:	00005517          	auipc	a0,0x5
    4372:	1b250513          	addi	a0,a0,434 # 9520 <malloc+0x153e>
    4376:	00004097          	auipc	ra,0x4
    437a:	a7a080e7          	jalr	-1414(ra) # 7df0 <printf>
    exit(1);
    437e:	4505                	li	a0,1
    4380:	00003097          	auipc	ra,0x3
    4384:	528080e7          	jalr	1320(ra) # 78a8 <exit>
  }
}
    4388:	0001                	nop
    438a:	70a2                	ld	ra,40(sp)
    438c:	7402                	ld	s0,32(sp)
    438e:	6145                	addi	sp,sp,48
    4390:	8082                	ret

0000000000004392 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(char *s)
{
    4392:	7179                	addi	sp,sp,-48
    4394:	f406                	sd	ra,40(sp)
    4396:	f022                	sd	s0,32(sp)
    4398:	1800                	addi	s0,sp,48
    439a:	fca43c23          	sd	a0,-40(s0)
  int fd, sz;

  unlink("bigwrite");
    439e:	00005517          	auipc	a0,0x5
    43a2:	19a50513          	addi	a0,a0,410 # 9538 <malloc+0x1556>
    43a6:	00003097          	auipc	ra,0x3
    43aa:	552080e7          	jalr	1362(ra) # 78f8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    43ae:	1f300793          	li	a5,499
    43b2:	fef42623          	sw	a5,-20(s0)
    43b6:	a0ed                	j	44a0 <bigwrite+0x10e>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    43b8:	20200593          	li	a1,514
    43bc:	00005517          	auipc	a0,0x5
    43c0:	17c50513          	addi	a0,a0,380 # 9538 <malloc+0x1556>
    43c4:	00003097          	auipc	ra,0x3
    43c8:	524080e7          	jalr	1316(ra) # 78e8 <open>
    43cc:	87aa                	mv	a5,a0
    43ce:	fef42223          	sw	a5,-28(s0)
    if(fd < 0){
    43d2:	fe442783          	lw	a5,-28(s0)
    43d6:	2781                	sext.w	a5,a5
    43d8:	0207d163          	bgez	a5,43fa <bigwrite+0x68>
      printf("%s: cannot create bigwrite\n", s);
    43dc:	fd843583          	ld	a1,-40(s0)
    43e0:	00005517          	auipc	a0,0x5
    43e4:	16850513          	addi	a0,a0,360 # 9548 <malloc+0x1566>
    43e8:	00004097          	auipc	ra,0x4
    43ec:	a08080e7          	jalr	-1528(ra) # 7df0 <printf>
      exit(1);
    43f0:	4505                	li	a0,1
    43f2:	00003097          	auipc	ra,0x3
    43f6:	4b6080e7          	jalr	1206(ra) # 78a8 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    43fa:	fe042423          	sw	zero,-24(s0)
    43fe:	a0ad                	j	4468 <bigwrite+0xd6>
      int cc = write(fd, buf, sz);
    4400:	fec42703          	lw	a4,-20(s0)
    4404:	fe442783          	lw	a5,-28(s0)
    4408:	863a                	mv	a2,a4
    440a:	00007597          	auipc	a1,0x7
    440e:	06658593          	addi	a1,a1,102 # b470 <buf>
    4412:	853e                	mv	a0,a5
    4414:	00003097          	auipc	ra,0x3
    4418:	4b4080e7          	jalr	1204(ra) # 78c8 <write>
    441c:	87aa                	mv	a5,a0
    441e:	fef42023          	sw	a5,-32(s0)
      if(cc != sz){
    4422:	fe042783          	lw	a5,-32(s0)
    4426:	873e                	mv	a4,a5
    4428:	fec42783          	lw	a5,-20(s0)
    442c:	2701                	sext.w	a4,a4
    442e:	2781                	sext.w	a5,a5
    4430:	02f70763          	beq	a4,a5,445e <bigwrite+0xcc>
        printf("%s: write(%d) ret %d\n", s, sz, cc);
    4434:	fe042703          	lw	a4,-32(s0)
    4438:	fec42783          	lw	a5,-20(s0)
    443c:	86ba                	mv	a3,a4
    443e:	863e                	mv	a2,a5
    4440:	fd843583          	ld	a1,-40(s0)
    4444:	00005517          	auipc	a0,0x5
    4448:	12450513          	addi	a0,a0,292 # 9568 <malloc+0x1586>
    444c:	00004097          	auipc	ra,0x4
    4450:	9a4080e7          	jalr	-1628(ra) # 7df0 <printf>
        exit(1);
    4454:	4505                	li	a0,1
    4456:	00003097          	auipc	ra,0x3
    445a:	452080e7          	jalr	1106(ra) # 78a8 <exit>
    for(i = 0; i < 2; i++){
    445e:	fe842783          	lw	a5,-24(s0)
    4462:	2785                	addiw	a5,a5,1
    4464:	fef42423          	sw	a5,-24(s0)
    4468:	fe842783          	lw	a5,-24(s0)
    446c:	0007871b          	sext.w	a4,a5
    4470:	4785                	li	a5,1
    4472:	f8e7d7e3          	bge	a5,a4,4400 <bigwrite+0x6e>
      }
    }
    close(fd);
    4476:	fe442783          	lw	a5,-28(s0)
    447a:	853e                	mv	a0,a5
    447c:	00003097          	auipc	ra,0x3
    4480:	454080e7          	jalr	1108(ra) # 78d0 <close>
    unlink("bigwrite");
    4484:	00005517          	auipc	a0,0x5
    4488:	0b450513          	addi	a0,a0,180 # 9538 <malloc+0x1556>
    448c:	00003097          	auipc	ra,0x3
    4490:	46c080e7          	jalr	1132(ra) # 78f8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
    4494:	fec42783          	lw	a5,-20(s0)
    4498:	1d77879b          	addiw	a5,a5,471
    449c:	fef42623          	sw	a5,-20(s0)
    44a0:	fec42783          	lw	a5,-20(s0)
    44a4:	0007871b          	sext.w	a4,a5
    44a8:	678d                	lui	a5,0x3
    44aa:	f0f747e3          	blt	a4,a5,43b8 <bigwrite+0x26>
  }
}
    44ae:	0001                	nop
    44b0:	0001                	nop
    44b2:	70a2                	ld	ra,40(sp)
    44b4:	7402                	ld	s0,32(sp)
    44b6:	6145                	addi	sp,sp,48
    44b8:	8082                	ret

00000000000044ba <bigfile>:


void
bigfile(char *s)
{
    44ba:	7179                	addi	sp,sp,-48
    44bc:	f406                	sd	ra,40(sp)
    44be:	f022                	sd	s0,32(sp)
    44c0:	1800                	addi	s0,sp,48
    44c2:	fca43c23          	sd	a0,-40(s0)
  enum { N = 20, SZ=600 };
  int fd, i, total, cc;

  unlink("bigfile.dat");
    44c6:	00005517          	auipc	a0,0x5
    44ca:	0ba50513          	addi	a0,a0,186 # 9580 <malloc+0x159e>
    44ce:	00003097          	auipc	ra,0x3
    44d2:	42a080e7          	jalr	1066(ra) # 78f8 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    44d6:	20200593          	li	a1,514
    44da:	00005517          	auipc	a0,0x5
    44de:	0a650513          	addi	a0,a0,166 # 9580 <malloc+0x159e>
    44e2:	00003097          	auipc	ra,0x3
    44e6:	406080e7          	jalr	1030(ra) # 78e8 <open>
    44ea:	87aa                	mv	a5,a0
    44ec:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
    44f0:	fe442783          	lw	a5,-28(s0)
    44f4:	2781                	sext.w	a5,a5
    44f6:	0207d163          	bgez	a5,4518 <bigfile+0x5e>
    printf("%s: cannot create bigfile", s);
    44fa:	fd843583          	ld	a1,-40(s0)
    44fe:	00005517          	auipc	a0,0x5
    4502:	09250513          	addi	a0,a0,146 # 9590 <malloc+0x15ae>
    4506:	00004097          	auipc	ra,0x4
    450a:	8ea080e7          	jalr	-1814(ra) # 7df0 <printf>
    exit(1);
    450e:	4505                	li	a0,1
    4510:	00003097          	auipc	ra,0x3
    4514:	398080e7          	jalr	920(ra) # 78a8 <exit>
  }
  for(i = 0; i < N; i++){
    4518:	fe042623          	sw	zero,-20(s0)
    451c:	a0ad                	j	4586 <bigfile+0xcc>
    memset(buf, i, SZ);
    451e:	fec42783          	lw	a5,-20(s0)
    4522:	25800613          	li	a2,600
    4526:	85be                	mv	a1,a5
    4528:	00007517          	auipc	a0,0x7
    452c:	f4850513          	addi	a0,a0,-184 # b470 <buf>
    4530:	00003097          	auipc	ra,0x3
    4534:	fcc080e7          	jalr	-52(ra) # 74fc <memset>
    if(write(fd, buf, SZ) != SZ){
    4538:	fe442783          	lw	a5,-28(s0)
    453c:	25800613          	li	a2,600
    4540:	00007597          	auipc	a1,0x7
    4544:	f3058593          	addi	a1,a1,-208 # b470 <buf>
    4548:	853e                	mv	a0,a5
    454a:	00003097          	auipc	ra,0x3
    454e:	37e080e7          	jalr	894(ra) # 78c8 <write>
    4552:	87aa                	mv	a5,a0
    4554:	873e                	mv	a4,a5
    4556:	25800793          	li	a5,600
    455a:	02f70163          	beq	a4,a5,457c <bigfile+0xc2>
      printf("%s: write bigfile failed\n", s);
    455e:	fd843583          	ld	a1,-40(s0)
    4562:	00005517          	auipc	a0,0x5
    4566:	04e50513          	addi	a0,a0,78 # 95b0 <malloc+0x15ce>
    456a:	00004097          	auipc	ra,0x4
    456e:	886080e7          	jalr	-1914(ra) # 7df0 <printf>
      exit(1);
    4572:	4505                	li	a0,1
    4574:	00003097          	auipc	ra,0x3
    4578:	334080e7          	jalr	820(ra) # 78a8 <exit>
  for(i = 0; i < N; i++){
    457c:	fec42783          	lw	a5,-20(s0)
    4580:	2785                	addiw	a5,a5,1 # 3001 <createdelete+0x287>
    4582:	fef42623          	sw	a5,-20(s0)
    4586:	fec42783          	lw	a5,-20(s0)
    458a:	0007871b          	sext.w	a4,a5
    458e:	47cd                	li	a5,19
    4590:	f8e7d7e3          	bge	a5,a4,451e <bigfile+0x64>
    }
  }
  close(fd);
    4594:	fe442783          	lw	a5,-28(s0)
    4598:	853e                	mv	a0,a5
    459a:	00003097          	auipc	ra,0x3
    459e:	336080e7          	jalr	822(ra) # 78d0 <close>

  fd = open("bigfile.dat", 0);
    45a2:	4581                	li	a1,0
    45a4:	00005517          	auipc	a0,0x5
    45a8:	fdc50513          	addi	a0,a0,-36 # 9580 <malloc+0x159e>
    45ac:	00003097          	auipc	ra,0x3
    45b0:	33c080e7          	jalr	828(ra) # 78e8 <open>
    45b4:	87aa                	mv	a5,a0
    45b6:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
    45ba:	fe442783          	lw	a5,-28(s0)
    45be:	2781                	sext.w	a5,a5
    45c0:	0207d163          	bgez	a5,45e2 <bigfile+0x128>
    printf("%s: cannot open bigfile\n", s);
    45c4:	fd843583          	ld	a1,-40(s0)
    45c8:	00005517          	auipc	a0,0x5
    45cc:	00850513          	addi	a0,a0,8 # 95d0 <malloc+0x15ee>
    45d0:	00004097          	auipc	ra,0x4
    45d4:	820080e7          	jalr	-2016(ra) # 7df0 <printf>
    exit(1);
    45d8:	4505                	li	a0,1
    45da:	00003097          	auipc	ra,0x3
    45de:	2ce080e7          	jalr	718(ra) # 78a8 <exit>
  }
  total = 0;
    45e2:	fe042423          	sw	zero,-24(s0)
  for(i = 0; ; i++){
    45e6:	fe042623          	sw	zero,-20(s0)
    cc = read(fd, buf, SZ/2);
    45ea:	fe442783          	lw	a5,-28(s0)
    45ee:	12c00613          	li	a2,300
    45f2:	00007597          	auipc	a1,0x7
    45f6:	e7e58593          	addi	a1,a1,-386 # b470 <buf>
    45fa:	853e                	mv	a0,a5
    45fc:	00003097          	auipc	ra,0x3
    4600:	2c4080e7          	jalr	708(ra) # 78c0 <read>
    4604:	87aa                	mv	a5,a0
    4606:	fef42023          	sw	a5,-32(s0)
    if(cc < 0){
    460a:	fe042783          	lw	a5,-32(s0)
    460e:	2781                	sext.w	a5,a5
    4610:	0207d163          	bgez	a5,4632 <bigfile+0x178>
      printf("%s: read bigfile failed\n", s);
    4614:	fd843583          	ld	a1,-40(s0)
    4618:	00005517          	auipc	a0,0x5
    461c:	fd850513          	addi	a0,a0,-40 # 95f0 <malloc+0x160e>
    4620:	00003097          	auipc	ra,0x3
    4624:	7d0080e7          	jalr	2000(ra) # 7df0 <printf>
      exit(1);
    4628:	4505                	li	a0,1
    462a:	00003097          	auipc	ra,0x3
    462e:	27e080e7          	jalr	638(ra) # 78a8 <exit>
    }
    if(cc == 0)
    4632:	fe042783          	lw	a5,-32(s0)
    4636:	2781                	sext.w	a5,a5
    4638:	cbdd                	beqz	a5,46ee <bigfile+0x234>
      break;
    if(cc != SZ/2){
    463a:	fe042783          	lw	a5,-32(s0)
    463e:	0007871b          	sext.w	a4,a5
    4642:	12c00793          	li	a5,300
    4646:	02f70163          	beq	a4,a5,4668 <bigfile+0x1ae>
      printf("%s: short read bigfile\n", s);
    464a:	fd843583          	ld	a1,-40(s0)
    464e:	00005517          	auipc	a0,0x5
    4652:	fc250513          	addi	a0,a0,-62 # 9610 <malloc+0x162e>
    4656:	00003097          	auipc	ra,0x3
    465a:	79a080e7          	jalr	1946(ra) # 7df0 <printf>
      exit(1);
    465e:	4505                	li	a0,1
    4660:	00003097          	auipc	ra,0x3
    4664:	248080e7          	jalr	584(ra) # 78a8 <exit>
    }
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4668:	00007797          	auipc	a5,0x7
    466c:	e0878793          	addi	a5,a5,-504 # b470 <buf>
    4670:	0007c783          	lbu	a5,0(a5)
    4674:	0007869b          	sext.w	a3,a5
    4678:	fec42783          	lw	a5,-20(s0)
    467c:	01f7d71b          	srliw	a4,a5,0x1f
    4680:	9fb9                	addw	a5,a5,a4
    4682:	4017d79b          	sraiw	a5,a5,0x1
    4686:	2781                	sext.w	a5,a5
    4688:	8736                	mv	a4,a3
    468a:	02f71563          	bne	a4,a5,46b4 <bigfile+0x1fa>
    468e:	00007797          	auipc	a5,0x7
    4692:	de278793          	addi	a5,a5,-542 # b470 <buf>
    4696:	12b7c783          	lbu	a5,299(a5)
    469a:	0007869b          	sext.w	a3,a5
    469e:	fec42783          	lw	a5,-20(s0)
    46a2:	01f7d71b          	srliw	a4,a5,0x1f
    46a6:	9fb9                	addw	a5,a5,a4
    46a8:	4017d79b          	sraiw	a5,a5,0x1
    46ac:	2781                	sext.w	a5,a5
    46ae:	8736                	mv	a4,a3
    46b0:	02f70163          	beq	a4,a5,46d2 <bigfile+0x218>
      printf("%s: read bigfile wrong data\n", s);
    46b4:	fd843583          	ld	a1,-40(s0)
    46b8:	00005517          	auipc	a0,0x5
    46bc:	f7050513          	addi	a0,a0,-144 # 9628 <malloc+0x1646>
    46c0:	00003097          	auipc	ra,0x3
    46c4:	730080e7          	jalr	1840(ra) # 7df0 <printf>
      exit(1);
    46c8:	4505                	li	a0,1
    46ca:	00003097          	auipc	ra,0x3
    46ce:	1de080e7          	jalr	478(ra) # 78a8 <exit>
    }
    total += cc;
    46d2:	fe842783          	lw	a5,-24(s0)
    46d6:	873e                	mv	a4,a5
    46d8:	fe042783          	lw	a5,-32(s0)
    46dc:	9fb9                	addw	a5,a5,a4
    46de:	fef42423          	sw	a5,-24(s0)
  for(i = 0; ; i++){
    46e2:	fec42783          	lw	a5,-20(s0)
    46e6:	2785                	addiw	a5,a5,1
    46e8:	fef42623          	sw	a5,-20(s0)
    cc = read(fd, buf, SZ/2);
    46ec:	bdfd                	j	45ea <bigfile+0x130>
      break;
    46ee:	0001                	nop
  }
  close(fd);
    46f0:	fe442783          	lw	a5,-28(s0)
    46f4:	853e                	mv	a0,a5
    46f6:	00003097          	auipc	ra,0x3
    46fa:	1da080e7          	jalr	474(ra) # 78d0 <close>
  if(total != N*SZ){
    46fe:	fe842783          	lw	a5,-24(s0)
    4702:	0007871b          	sext.w	a4,a5
    4706:	678d                	lui	a5,0x3
    4708:	ee078793          	addi	a5,a5,-288 # 2ee0 <createdelete+0x166>
    470c:	02f70163          	beq	a4,a5,472e <bigfile+0x274>
    printf("%s: read bigfile wrong total\n", s);
    4710:	fd843583          	ld	a1,-40(s0)
    4714:	00005517          	auipc	a0,0x5
    4718:	f3450513          	addi	a0,a0,-204 # 9648 <malloc+0x1666>
    471c:	00003097          	auipc	ra,0x3
    4720:	6d4080e7          	jalr	1748(ra) # 7df0 <printf>
    exit(1);
    4724:	4505                	li	a0,1
    4726:	00003097          	auipc	ra,0x3
    472a:	182080e7          	jalr	386(ra) # 78a8 <exit>
  }
  unlink("bigfile.dat");
    472e:	00005517          	auipc	a0,0x5
    4732:	e5250513          	addi	a0,a0,-430 # 9580 <malloc+0x159e>
    4736:	00003097          	auipc	ra,0x3
    473a:	1c2080e7          	jalr	450(ra) # 78f8 <unlink>
}
    473e:	0001                	nop
    4740:	70a2                	ld	ra,40(sp)
    4742:	7402                	ld	s0,32(sp)
    4744:	6145                	addi	sp,sp,48
    4746:	8082                	ret

0000000000004748 <fourteen>:

void
fourteen(char *s)
{
    4748:	7179                	addi	sp,sp,-48
    474a:	f406                	sd	ra,40(sp)
    474c:	f022                	sd	s0,32(sp)
    474e:	1800                	addi	s0,sp,48
    4750:	fca43c23          	sd	a0,-40(s0)
  int fd;

  // DIRSIZ is 14.

  if(mkdir("12345678901234") != 0){
    4754:	00005517          	auipc	a0,0x5
    4758:	f1450513          	addi	a0,a0,-236 # 9668 <malloc+0x1686>
    475c:	00003097          	auipc	ra,0x3
    4760:	1b4080e7          	jalr	436(ra) # 7910 <mkdir>
    4764:	87aa                	mv	a5,a0
    4766:	c385                	beqz	a5,4786 <fourteen+0x3e>
    printf("%s: mkdir 12345678901234 failed\n", s);
    4768:	fd843583          	ld	a1,-40(s0)
    476c:	00005517          	auipc	a0,0x5
    4770:	f0c50513          	addi	a0,a0,-244 # 9678 <malloc+0x1696>
    4774:	00003097          	auipc	ra,0x3
    4778:	67c080e7          	jalr	1660(ra) # 7df0 <printf>
    exit(1);
    477c:	4505                	li	a0,1
    477e:	00003097          	auipc	ra,0x3
    4782:	12a080e7          	jalr	298(ra) # 78a8 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    4786:	00005517          	auipc	a0,0x5
    478a:	f1a50513          	addi	a0,a0,-230 # 96a0 <malloc+0x16be>
    478e:	00003097          	auipc	ra,0x3
    4792:	182080e7          	jalr	386(ra) # 7910 <mkdir>
    4796:	87aa                	mv	a5,a0
    4798:	c385                	beqz	a5,47b8 <fourteen+0x70>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    479a:	fd843583          	ld	a1,-40(s0)
    479e:	00005517          	auipc	a0,0x5
    47a2:	f2250513          	addi	a0,a0,-222 # 96c0 <malloc+0x16de>
    47a6:	00003097          	auipc	ra,0x3
    47aa:	64a080e7          	jalr	1610(ra) # 7df0 <printf>
    exit(1);
    47ae:	4505                	li	a0,1
    47b0:	00003097          	auipc	ra,0x3
    47b4:	0f8080e7          	jalr	248(ra) # 78a8 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    47b8:	20000593          	li	a1,512
    47bc:	00005517          	auipc	a0,0x5
    47c0:	f3c50513          	addi	a0,a0,-196 # 96f8 <malloc+0x1716>
    47c4:	00003097          	auipc	ra,0x3
    47c8:	124080e7          	jalr	292(ra) # 78e8 <open>
    47cc:	87aa                	mv	a5,a0
    47ce:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    47d2:	fec42783          	lw	a5,-20(s0)
    47d6:	2781                	sext.w	a5,a5
    47d8:	0207d163          	bgez	a5,47fa <fourteen+0xb2>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    47dc:	fd843583          	ld	a1,-40(s0)
    47e0:	00005517          	auipc	a0,0x5
    47e4:	f4850513          	addi	a0,a0,-184 # 9728 <malloc+0x1746>
    47e8:	00003097          	auipc	ra,0x3
    47ec:	608080e7          	jalr	1544(ra) # 7df0 <printf>
    exit(1);
    47f0:	4505                	li	a0,1
    47f2:	00003097          	auipc	ra,0x3
    47f6:	0b6080e7          	jalr	182(ra) # 78a8 <exit>
  }
  close(fd);
    47fa:	fec42783          	lw	a5,-20(s0)
    47fe:	853e                	mv	a0,a5
    4800:	00003097          	auipc	ra,0x3
    4804:	0d0080e7          	jalr	208(ra) # 78d0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    4808:	4581                	li	a1,0
    480a:	00005517          	auipc	a0,0x5
    480e:	f6650513          	addi	a0,a0,-154 # 9770 <malloc+0x178e>
    4812:	00003097          	auipc	ra,0x3
    4816:	0d6080e7          	jalr	214(ra) # 78e8 <open>
    481a:	87aa                	mv	a5,a0
    481c:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    4820:	fec42783          	lw	a5,-20(s0)
    4824:	2781                	sext.w	a5,a5
    4826:	0207d163          	bgez	a5,4848 <fourteen+0x100>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    482a:	fd843583          	ld	a1,-40(s0)
    482e:	00005517          	auipc	a0,0x5
    4832:	f7250513          	addi	a0,a0,-142 # 97a0 <malloc+0x17be>
    4836:	00003097          	auipc	ra,0x3
    483a:	5ba080e7          	jalr	1466(ra) # 7df0 <printf>
    exit(1);
    483e:	4505                	li	a0,1
    4840:	00003097          	auipc	ra,0x3
    4844:	068080e7          	jalr	104(ra) # 78a8 <exit>
  }
  close(fd);
    4848:	fec42783          	lw	a5,-20(s0)
    484c:	853e                	mv	a0,a5
    484e:	00003097          	auipc	ra,0x3
    4852:	082080e7          	jalr	130(ra) # 78d0 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    4856:	00005517          	auipc	a0,0x5
    485a:	f8a50513          	addi	a0,a0,-118 # 97e0 <malloc+0x17fe>
    485e:	00003097          	auipc	ra,0x3
    4862:	0b2080e7          	jalr	178(ra) # 7910 <mkdir>
    4866:	87aa                	mv	a5,a0
    4868:	e385                	bnez	a5,4888 <fourteen+0x140>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    486a:	fd843583          	ld	a1,-40(s0)
    486e:	00005517          	auipc	a0,0x5
    4872:	f9250513          	addi	a0,a0,-110 # 9800 <malloc+0x181e>
    4876:	00003097          	auipc	ra,0x3
    487a:	57a080e7          	jalr	1402(ra) # 7df0 <printf>
    exit(1);
    487e:	4505                	li	a0,1
    4880:	00003097          	auipc	ra,0x3
    4884:	028080e7          	jalr	40(ra) # 78a8 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    4888:	00005517          	auipc	a0,0x5
    488c:	fb050513          	addi	a0,a0,-80 # 9838 <malloc+0x1856>
    4890:	00003097          	auipc	ra,0x3
    4894:	080080e7          	jalr	128(ra) # 7910 <mkdir>
    4898:	87aa                	mv	a5,a0
    489a:	e385                	bnez	a5,48ba <fourteen+0x172>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    489c:	fd843583          	ld	a1,-40(s0)
    48a0:	00005517          	auipc	a0,0x5
    48a4:	fb850513          	addi	a0,a0,-72 # 9858 <malloc+0x1876>
    48a8:	00003097          	auipc	ra,0x3
    48ac:	548080e7          	jalr	1352(ra) # 7df0 <printf>
    exit(1);
    48b0:	4505                	li	a0,1
    48b2:	00003097          	auipc	ra,0x3
    48b6:	ff6080e7          	jalr	-10(ra) # 78a8 <exit>
  }

  // clean up
  unlink("123456789012345/12345678901234");
    48ba:	00005517          	auipc	a0,0x5
    48be:	f7e50513          	addi	a0,a0,-130 # 9838 <malloc+0x1856>
    48c2:	00003097          	auipc	ra,0x3
    48c6:	036080e7          	jalr	54(ra) # 78f8 <unlink>
  unlink("12345678901234/12345678901234");
    48ca:	00005517          	auipc	a0,0x5
    48ce:	f1650513          	addi	a0,a0,-234 # 97e0 <malloc+0x17fe>
    48d2:	00003097          	auipc	ra,0x3
    48d6:	026080e7          	jalr	38(ra) # 78f8 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    48da:	00005517          	auipc	a0,0x5
    48de:	e9650513          	addi	a0,a0,-362 # 9770 <malloc+0x178e>
    48e2:	00003097          	auipc	ra,0x3
    48e6:	016080e7          	jalr	22(ra) # 78f8 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    48ea:	00005517          	auipc	a0,0x5
    48ee:	e0e50513          	addi	a0,a0,-498 # 96f8 <malloc+0x1716>
    48f2:	00003097          	auipc	ra,0x3
    48f6:	006080e7          	jalr	6(ra) # 78f8 <unlink>
  unlink("12345678901234/123456789012345");
    48fa:	00005517          	auipc	a0,0x5
    48fe:	da650513          	addi	a0,a0,-602 # 96a0 <malloc+0x16be>
    4902:	00003097          	auipc	ra,0x3
    4906:	ff6080e7          	jalr	-10(ra) # 78f8 <unlink>
  unlink("12345678901234");
    490a:	00005517          	auipc	a0,0x5
    490e:	d5e50513          	addi	a0,a0,-674 # 9668 <malloc+0x1686>
    4912:	00003097          	auipc	ra,0x3
    4916:	fe6080e7          	jalr	-26(ra) # 78f8 <unlink>
}
    491a:	0001                	nop
    491c:	70a2                	ld	ra,40(sp)
    491e:	7402                	ld	s0,32(sp)
    4920:	6145                	addi	sp,sp,48
    4922:	8082                	ret

0000000000004924 <rmdot>:

void
rmdot(char *s)
{
    4924:	1101                	addi	sp,sp,-32
    4926:	ec06                	sd	ra,24(sp)
    4928:	e822                	sd	s0,16(sp)
    492a:	1000                	addi	s0,sp,32
    492c:	fea43423          	sd	a0,-24(s0)
  if(mkdir("dots") != 0){
    4930:	00005517          	auipc	a0,0x5
    4934:	f6050513          	addi	a0,a0,-160 # 9890 <malloc+0x18ae>
    4938:	00003097          	auipc	ra,0x3
    493c:	fd8080e7          	jalr	-40(ra) # 7910 <mkdir>
    4940:	87aa                	mv	a5,a0
    4942:	c385                	beqz	a5,4962 <rmdot+0x3e>
    printf("%s: mkdir dots failed\n", s);
    4944:	fe843583          	ld	a1,-24(s0)
    4948:	00005517          	auipc	a0,0x5
    494c:	f5050513          	addi	a0,a0,-176 # 9898 <malloc+0x18b6>
    4950:	00003097          	auipc	ra,0x3
    4954:	4a0080e7          	jalr	1184(ra) # 7df0 <printf>
    exit(1);
    4958:	4505                	li	a0,1
    495a:	00003097          	auipc	ra,0x3
    495e:	f4e080e7          	jalr	-178(ra) # 78a8 <exit>
  }
  if(chdir("dots") != 0){
    4962:	00005517          	auipc	a0,0x5
    4966:	f2e50513          	addi	a0,a0,-210 # 9890 <malloc+0x18ae>
    496a:	00003097          	auipc	ra,0x3
    496e:	fae080e7          	jalr	-82(ra) # 7918 <chdir>
    4972:	87aa                	mv	a5,a0
    4974:	c385                	beqz	a5,4994 <rmdot+0x70>
    printf("%s: chdir dots failed\n", s);
    4976:	fe843583          	ld	a1,-24(s0)
    497a:	00005517          	auipc	a0,0x5
    497e:	f3650513          	addi	a0,a0,-202 # 98b0 <malloc+0x18ce>
    4982:	00003097          	auipc	ra,0x3
    4986:	46e080e7          	jalr	1134(ra) # 7df0 <printf>
    exit(1);
    498a:	4505                	li	a0,1
    498c:	00003097          	auipc	ra,0x3
    4990:	f1c080e7          	jalr	-228(ra) # 78a8 <exit>
  }
  if(unlink(".") == 0){
    4994:	00004517          	auipc	a0,0x4
    4998:	55450513          	addi	a0,a0,1364 # 8ee8 <malloc+0xf06>
    499c:	00003097          	auipc	ra,0x3
    49a0:	f5c080e7          	jalr	-164(ra) # 78f8 <unlink>
    49a4:	87aa                	mv	a5,a0
    49a6:	e385                	bnez	a5,49c6 <rmdot+0xa2>
    printf("%s: rm . worked!\n", s);
    49a8:	fe843583          	ld	a1,-24(s0)
    49ac:	00005517          	auipc	a0,0x5
    49b0:	f1c50513          	addi	a0,a0,-228 # 98c8 <malloc+0x18e6>
    49b4:	00003097          	auipc	ra,0x3
    49b8:	43c080e7          	jalr	1084(ra) # 7df0 <printf>
    exit(1);
    49bc:	4505                	li	a0,1
    49be:	00003097          	auipc	ra,0x3
    49c2:	eea080e7          	jalr	-278(ra) # 78a8 <exit>
  }
  if(unlink("..") == 0){
    49c6:	00004517          	auipc	a0,0x4
    49ca:	f7a50513          	addi	a0,a0,-134 # 8940 <malloc+0x95e>
    49ce:	00003097          	auipc	ra,0x3
    49d2:	f2a080e7          	jalr	-214(ra) # 78f8 <unlink>
    49d6:	87aa                	mv	a5,a0
    49d8:	e385                	bnez	a5,49f8 <rmdot+0xd4>
    printf("%s: rm .. worked!\n", s);
    49da:	fe843583          	ld	a1,-24(s0)
    49de:	00005517          	auipc	a0,0x5
    49e2:	f0250513          	addi	a0,a0,-254 # 98e0 <malloc+0x18fe>
    49e6:	00003097          	auipc	ra,0x3
    49ea:	40a080e7          	jalr	1034(ra) # 7df0 <printf>
    exit(1);
    49ee:	4505                	li	a0,1
    49f0:	00003097          	auipc	ra,0x3
    49f4:	eb8080e7          	jalr	-328(ra) # 78a8 <exit>
  }
  if(chdir("/") != 0){
    49f8:	00004517          	auipc	a0,0x4
    49fc:	c6050513          	addi	a0,a0,-928 # 8658 <malloc+0x676>
    4a00:	00003097          	auipc	ra,0x3
    4a04:	f18080e7          	jalr	-232(ra) # 7918 <chdir>
    4a08:	87aa                	mv	a5,a0
    4a0a:	c385                	beqz	a5,4a2a <rmdot+0x106>
    printf("%s: chdir / failed\n", s);
    4a0c:	fe843583          	ld	a1,-24(s0)
    4a10:	00004517          	auipc	a0,0x4
    4a14:	c5050513          	addi	a0,a0,-944 # 8660 <malloc+0x67e>
    4a18:	00003097          	auipc	ra,0x3
    4a1c:	3d8080e7          	jalr	984(ra) # 7df0 <printf>
    exit(1);
    4a20:	4505                	li	a0,1
    4a22:	00003097          	auipc	ra,0x3
    4a26:	e86080e7          	jalr	-378(ra) # 78a8 <exit>
  }
  if(unlink("dots/.") == 0){
    4a2a:	00005517          	auipc	a0,0x5
    4a2e:	ece50513          	addi	a0,a0,-306 # 98f8 <malloc+0x1916>
    4a32:	00003097          	auipc	ra,0x3
    4a36:	ec6080e7          	jalr	-314(ra) # 78f8 <unlink>
    4a3a:	87aa                	mv	a5,a0
    4a3c:	e385                	bnez	a5,4a5c <rmdot+0x138>
    printf("%s: unlink dots/. worked!\n", s);
    4a3e:	fe843583          	ld	a1,-24(s0)
    4a42:	00005517          	auipc	a0,0x5
    4a46:	ebe50513          	addi	a0,a0,-322 # 9900 <malloc+0x191e>
    4a4a:	00003097          	auipc	ra,0x3
    4a4e:	3a6080e7          	jalr	934(ra) # 7df0 <printf>
    exit(1);
    4a52:	4505                	li	a0,1
    4a54:	00003097          	auipc	ra,0x3
    4a58:	e54080e7          	jalr	-428(ra) # 78a8 <exit>
  }
  if(unlink("dots/..") == 0){
    4a5c:	00005517          	auipc	a0,0x5
    4a60:	ec450513          	addi	a0,a0,-316 # 9920 <malloc+0x193e>
    4a64:	00003097          	auipc	ra,0x3
    4a68:	e94080e7          	jalr	-364(ra) # 78f8 <unlink>
    4a6c:	87aa                	mv	a5,a0
    4a6e:	e385                	bnez	a5,4a8e <rmdot+0x16a>
    printf("%s: unlink dots/.. worked!\n", s);
    4a70:	fe843583          	ld	a1,-24(s0)
    4a74:	00005517          	auipc	a0,0x5
    4a78:	eb450513          	addi	a0,a0,-332 # 9928 <malloc+0x1946>
    4a7c:	00003097          	auipc	ra,0x3
    4a80:	374080e7          	jalr	884(ra) # 7df0 <printf>
    exit(1);
    4a84:	4505                	li	a0,1
    4a86:	00003097          	auipc	ra,0x3
    4a8a:	e22080e7          	jalr	-478(ra) # 78a8 <exit>
  }
  if(unlink("dots") != 0){
    4a8e:	00005517          	auipc	a0,0x5
    4a92:	e0250513          	addi	a0,a0,-510 # 9890 <malloc+0x18ae>
    4a96:	00003097          	auipc	ra,0x3
    4a9a:	e62080e7          	jalr	-414(ra) # 78f8 <unlink>
    4a9e:	87aa                	mv	a5,a0
    4aa0:	c385                	beqz	a5,4ac0 <rmdot+0x19c>
    printf("%s: unlink dots failed!\n", s);
    4aa2:	fe843583          	ld	a1,-24(s0)
    4aa6:	00005517          	auipc	a0,0x5
    4aaa:	ea250513          	addi	a0,a0,-350 # 9948 <malloc+0x1966>
    4aae:	00003097          	auipc	ra,0x3
    4ab2:	342080e7          	jalr	834(ra) # 7df0 <printf>
    exit(1);
    4ab6:	4505                	li	a0,1
    4ab8:	00003097          	auipc	ra,0x3
    4abc:	df0080e7          	jalr	-528(ra) # 78a8 <exit>
  }
}
    4ac0:	0001                	nop
    4ac2:	60e2                	ld	ra,24(sp)
    4ac4:	6442                	ld	s0,16(sp)
    4ac6:	6105                	addi	sp,sp,32
    4ac8:	8082                	ret

0000000000004aca <dirfile>:

void
dirfile(char *s)
{
    4aca:	7179                	addi	sp,sp,-48
    4acc:	f406                	sd	ra,40(sp)
    4ace:	f022                	sd	s0,32(sp)
    4ad0:	1800                	addi	s0,sp,48
    4ad2:	fca43c23          	sd	a0,-40(s0)
  int fd;

  fd = open("dirfile", O_CREATE);
    4ad6:	20000593          	li	a1,512
    4ada:	00005517          	auipc	a0,0x5
    4ade:	e8e50513          	addi	a0,a0,-370 # 9968 <malloc+0x1986>
    4ae2:	00003097          	auipc	ra,0x3
    4ae6:	e06080e7          	jalr	-506(ra) # 78e8 <open>
    4aea:	87aa                	mv	a5,a0
    4aec:	fef42623          	sw	a5,-20(s0)
  if(fd < 0){
    4af0:	fec42783          	lw	a5,-20(s0)
    4af4:	2781                	sext.w	a5,a5
    4af6:	0207d163          	bgez	a5,4b18 <dirfile+0x4e>
    printf("%s: create dirfile failed\n", s);
    4afa:	fd843583          	ld	a1,-40(s0)
    4afe:	00005517          	auipc	a0,0x5
    4b02:	e7250513          	addi	a0,a0,-398 # 9970 <malloc+0x198e>
    4b06:	00003097          	auipc	ra,0x3
    4b0a:	2ea080e7          	jalr	746(ra) # 7df0 <printf>
    exit(1);
    4b0e:	4505                	li	a0,1
    4b10:	00003097          	auipc	ra,0x3
    4b14:	d98080e7          	jalr	-616(ra) # 78a8 <exit>
  }
  close(fd);
    4b18:	fec42783          	lw	a5,-20(s0)
    4b1c:	853e                	mv	a0,a5
    4b1e:	00003097          	auipc	ra,0x3
    4b22:	db2080e7          	jalr	-590(ra) # 78d0 <close>
  if(chdir("dirfile") == 0){
    4b26:	00005517          	auipc	a0,0x5
    4b2a:	e4250513          	addi	a0,a0,-446 # 9968 <malloc+0x1986>
    4b2e:	00003097          	auipc	ra,0x3
    4b32:	dea080e7          	jalr	-534(ra) # 7918 <chdir>
    4b36:	87aa                	mv	a5,a0
    4b38:	e385                	bnez	a5,4b58 <dirfile+0x8e>
    printf("%s: chdir dirfile succeeded!\n", s);
    4b3a:	fd843583          	ld	a1,-40(s0)
    4b3e:	00005517          	auipc	a0,0x5
    4b42:	e5250513          	addi	a0,a0,-430 # 9990 <malloc+0x19ae>
    4b46:	00003097          	auipc	ra,0x3
    4b4a:	2aa080e7          	jalr	682(ra) # 7df0 <printf>
    exit(1);
    4b4e:	4505                	li	a0,1
    4b50:	00003097          	auipc	ra,0x3
    4b54:	d58080e7          	jalr	-680(ra) # 78a8 <exit>
  }
  fd = open("dirfile/xx", 0);
    4b58:	4581                	li	a1,0
    4b5a:	00005517          	auipc	a0,0x5
    4b5e:	e5650513          	addi	a0,a0,-426 # 99b0 <malloc+0x19ce>
    4b62:	00003097          	auipc	ra,0x3
    4b66:	d86080e7          	jalr	-634(ra) # 78e8 <open>
    4b6a:	87aa                	mv	a5,a0
    4b6c:	fef42623          	sw	a5,-20(s0)
  if(fd >= 0){
    4b70:	fec42783          	lw	a5,-20(s0)
    4b74:	2781                	sext.w	a5,a5
    4b76:	0207c163          	bltz	a5,4b98 <dirfile+0xce>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4b7a:	fd843583          	ld	a1,-40(s0)
    4b7e:	00005517          	auipc	a0,0x5
    4b82:	e4250513          	addi	a0,a0,-446 # 99c0 <malloc+0x19de>
    4b86:	00003097          	auipc	ra,0x3
    4b8a:	26a080e7          	jalr	618(ra) # 7df0 <printf>
    exit(1);
    4b8e:	4505                	li	a0,1
    4b90:	00003097          	auipc	ra,0x3
    4b94:	d18080e7          	jalr	-744(ra) # 78a8 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    4b98:	20000593          	li	a1,512
    4b9c:	00005517          	auipc	a0,0x5
    4ba0:	e1450513          	addi	a0,a0,-492 # 99b0 <malloc+0x19ce>
    4ba4:	00003097          	auipc	ra,0x3
    4ba8:	d44080e7          	jalr	-700(ra) # 78e8 <open>
    4bac:	87aa                	mv	a5,a0
    4bae:	fef42623          	sw	a5,-20(s0)
  if(fd >= 0){
    4bb2:	fec42783          	lw	a5,-20(s0)
    4bb6:	2781                	sext.w	a5,a5
    4bb8:	0207c163          	bltz	a5,4bda <dirfile+0x110>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4bbc:	fd843583          	ld	a1,-40(s0)
    4bc0:	00005517          	auipc	a0,0x5
    4bc4:	e0050513          	addi	a0,a0,-512 # 99c0 <malloc+0x19de>
    4bc8:	00003097          	auipc	ra,0x3
    4bcc:	228080e7          	jalr	552(ra) # 7df0 <printf>
    exit(1);
    4bd0:	4505                	li	a0,1
    4bd2:	00003097          	auipc	ra,0x3
    4bd6:	cd6080e7          	jalr	-810(ra) # 78a8 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    4bda:	00005517          	auipc	a0,0x5
    4bde:	dd650513          	addi	a0,a0,-554 # 99b0 <malloc+0x19ce>
    4be2:	00003097          	auipc	ra,0x3
    4be6:	d2e080e7          	jalr	-722(ra) # 7910 <mkdir>
    4bea:	87aa                	mv	a5,a0
    4bec:	e385                	bnez	a5,4c0c <dirfile+0x142>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4bee:	fd843583          	ld	a1,-40(s0)
    4bf2:	00005517          	auipc	a0,0x5
    4bf6:	df650513          	addi	a0,a0,-522 # 99e8 <malloc+0x1a06>
    4bfa:	00003097          	auipc	ra,0x3
    4bfe:	1f6080e7          	jalr	502(ra) # 7df0 <printf>
    exit(1);
    4c02:	4505                	li	a0,1
    4c04:	00003097          	auipc	ra,0x3
    4c08:	ca4080e7          	jalr	-860(ra) # 78a8 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    4c0c:	00005517          	auipc	a0,0x5
    4c10:	da450513          	addi	a0,a0,-604 # 99b0 <malloc+0x19ce>
    4c14:	00003097          	auipc	ra,0x3
    4c18:	ce4080e7          	jalr	-796(ra) # 78f8 <unlink>
    4c1c:	87aa                	mv	a5,a0
    4c1e:	e385                	bnez	a5,4c3e <dirfile+0x174>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4c20:	fd843583          	ld	a1,-40(s0)
    4c24:	00005517          	auipc	a0,0x5
    4c28:	dec50513          	addi	a0,a0,-532 # 9a10 <malloc+0x1a2e>
    4c2c:	00003097          	auipc	ra,0x3
    4c30:	1c4080e7          	jalr	452(ra) # 7df0 <printf>
    exit(1);
    4c34:	4505                	li	a0,1
    4c36:	00003097          	auipc	ra,0x3
    4c3a:	c72080e7          	jalr	-910(ra) # 78a8 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    4c3e:	00005597          	auipc	a1,0x5
    4c42:	d7258593          	addi	a1,a1,-654 # 99b0 <malloc+0x19ce>
    4c46:	00003517          	auipc	a0,0x3
    4c4a:	59a50513          	addi	a0,a0,1434 # 81e0 <malloc+0x1fe>
    4c4e:	00003097          	auipc	ra,0x3
    4c52:	cba080e7          	jalr	-838(ra) # 7908 <link>
    4c56:	87aa                	mv	a5,a0
    4c58:	e385                	bnez	a5,4c78 <dirfile+0x1ae>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    4c5a:	fd843583          	ld	a1,-40(s0)
    4c5e:	00005517          	auipc	a0,0x5
    4c62:	dda50513          	addi	a0,a0,-550 # 9a38 <malloc+0x1a56>
    4c66:	00003097          	auipc	ra,0x3
    4c6a:	18a080e7          	jalr	394(ra) # 7df0 <printf>
    exit(1);
    4c6e:	4505                	li	a0,1
    4c70:	00003097          	auipc	ra,0x3
    4c74:	c38080e7          	jalr	-968(ra) # 78a8 <exit>
  }
  if(unlink("dirfile") != 0){
    4c78:	00005517          	auipc	a0,0x5
    4c7c:	cf050513          	addi	a0,a0,-784 # 9968 <malloc+0x1986>
    4c80:	00003097          	auipc	ra,0x3
    4c84:	c78080e7          	jalr	-904(ra) # 78f8 <unlink>
    4c88:	87aa                	mv	a5,a0
    4c8a:	c385                	beqz	a5,4caa <dirfile+0x1e0>
    printf("%s: unlink dirfile failed!\n", s);
    4c8c:	fd843583          	ld	a1,-40(s0)
    4c90:	00005517          	auipc	a0,0x5
    4c94:	dd050513          	addi	a0,a0,-560 # 9a60 <malloc+0x1a7e>
    4c98:	00003097          	auipc	ra,0x3
    4c9c:	158080e7          	jalr	344(ra) # 7df0 <printf>
    exit(1);
    4ca0:	4505                	li	a0,1
    4ca2:	00003097          	auipc	ra,0x3
    4ca6:	c06080e7          	jalr	-1018(ra) # 78a8 <exit>
  }

  fd = open(".", O_RDWR);
    4caa:	4589                	li	a1,2
    4cac:	00004517          	auipc	a0,0x4
    4cb0:	23c50513          	addi	a0,a0,572 # 8ee8 <malloc+0xf06>
    4cb4:	00003097          	auipc	ra,0x3
    4cb8:	c34080e7          	jalr	-972(ra) # 78e8 <open>
    4cbc:	87aa                	mv	a5,a0
    4cbe:	fef42623          	sw	a5,-20(s0)
  if(fd >= 0){
    4cc2:	fec42783          	lw	a5,-20(s0)
    4cc6:	2781                	sext.w	a5,a5
    4cc8:	0207c163          	bltz	a5,4cea <dirfile+0x220>
    printf("%s: open . for writing succeeded!\n", s);
    4ccc:	fd843583          	ld	a1,-40(s0)
    4cd0:	00005517          	auipc	a0,0x5
    4cd4:	db050513          	addi	a0,a0,-592 # 9a80 <malloc+0x1a9e>
    4cd8:	00003097          	auipc	ra,0x3
    4cdc:	118080e7          	jalr	280(ra) # 7df0 <printf>
    exit(1);
    4ce0:	4505                	li	a0,1
    4ce2:	00003097          	auipc	ra,0x3
    4ce6:	bc6080e7          	jalr	-1082(ra) # 78a8 <exit>
  }
  fd = open(".", 0);
    4cea:	4581                	li	a1,0
    4cec:	00004517          	auipc	a0,0x4
    4cf0:	1fc50513          	addi	a0,a0,508 # 8ee8 <malloc+0xf06>
    4cf4:	00003097          	auipc	ra,0x3
    4cf8:	bf4080e7          	jalr	-1036(ra) # 78e8 <open>
    4cfc:	87aa                	mv	a5,a0
    4cfe:	fef42623          	sw	a5,-20(s0)
  if(write(fd, "x", 1) > 0){
    4d02:	fec42783          	lw	a5,-20(s0)
    4d06:	4605                	li	a2,1
    4d08:	00003597          	auipc	a1,0x3
    4d0c:	52858593          	addi	a1,a1,1320 # 8230 <malloc+0x24e>
    4d10:	853e                	mv	a0,a5
    4d12:	00003097          	auipc	ra,0x3
    4d16:	bb6080e7          	jalr	-1098(ra) # 78c8 <write>
    4d1a:	87aa                	mv	a5,a0
    4d1c:	02f05163          	blez	a5,4d3e <dirfile+0x274>
    printf("%s: write . succeeded!\n", s);
    4d20:	fd843583          	ld	a1,-40(s0)
    4d24:	00005517          	auipc	a0,0x5
    4d28:	d8450513          	addi	a0,a0,-636 # 9aa8 <malloc+0x1ac6>
    4d2c:	00003097          	auipc	ra,0x3
    4d30:	0c4080e7          	jalr	196(ra) # 7df0 <printf>
    exit(1);
    4d34:	4505                	li	a0,1
    4d36:	00003097          	auipc	ra,0x3
    4d3a:	b72080e7          	jalr	-1166(ra) # 78a8 <exit>
  }
  close(fd);
    4d3e:	fec42783          	lw	a5,-20(s0)
    4d42:	853e                	mv	a0,a5
    4d44:	00003097          	auipc	ra,0x3
    4d48:	b8c080e7          	jalr	-1140(ra) # 78d0 <close>
}
    4d4c:	0001                	nop
    4d4e:	70a2                	ld	ra,40(sp)
    4d50:	7402                	ld	s0,32(sp)
    4d52:	6145                	addi	sp,sp,48
    4d54:	8082                	ret

0000000000004d56 <iref>:

// test that iput() is called at the end of _namei().
// also tests empty file names.
void
iref(char *s)
{
    4d56:	7179                	addi	sp,sp,-48
    4d58:	f406                	sd	ra,40(sp)
    4d5a:	f022                	sd	s0,32(sp)
    4d5c:	1800                	addi	s0,sp,48
    4d5e:	fca43c23          	sd	a0,-40(s0)
  int i, fd;

  for(i = 0; i < NINODE + 1; i++){
    4d62:	fe042623          	sw	zero,-20(s0)
    4d66:	a231                	j	4e72 <iref+0x11c>
    if(mkdir("irefd") != 0){
    4d68:	00005517          	auipc	a0,0x5
    4d6c:	d5850513          	addi	a0,a0,-680 # 9ac0 <malloc+0x1ade>
    4d70:	00003097          	auipc	ra,0x3
    4d74:	ba0080e7          	jalr	-1120(ra) # 7910 <mkdir>
    4d78:	87aa                	mv	a5,a0
    4d7a:	c385                	beqz	a5,4d9a <iref+0x44>
      printf("%s: mkdir irefd failed\n", s);
    4d7c:	fd843583          	ld	a1,-40(s0)
    4d80:	00005517          	auipc	a0,0x5
    4d84:	d4850513          	addi	a0,a0,-696 # 9ac8 <malloc+0x1ae6>
    4d88:	00003097          	auipc	ra,0x3
    4d8c:	068080e7          	jalr	104(ra) # 7df0 <printf>
      exit(1);
    4d90:	4505                	li	a0,1
    4d92:	00003097          	auipc	ra,0x3
    4d96:	b16080e7          	jalr	-1258(ra) # 78a8 <exit>
    }
    if(chdir("irefd") != 0){
    4d9a:	00005517          	auipc	a0,0x5
    4d9e:	d2650513          	addi	a0,a0,-730 # 9ac0 <malloc+0x1ade>
    4da2:	00003097          	auipc	ra,0x3
    4da6:	b76080e7          	jalr	-1162(ra) # 7918 <chdir>
    4daa:	87aa                	mv	a5,a0
    4dac:	c385                	beqz	a5,4dcc <iref+0x76>
      printf("%s: chdir irefd failed\n", s);
    4dae:	fd843583          	ld	a1,-40(s0)
    4db2:	00005517          	auipc	a0,0x5
    4db6:	d2e50513          	addi	a0,a0,-722 # 9ae0 <malloc+0x1afe>
    4dba:	00003097          	auipc	ra,0x3
    4dbe:	036080e7          	jalr	54(ra) # 7df0 <printf>
      exit(1);
    4dc2:	4505                	li	a0,1
    4dc4:	00003097          	auipc	ra,0x3
    4dc8:	ae4080e7          	jalr	-1308(ra) # 78a8 <exit>
    }

    mkdir("");
    4dcc:	00005517          	auipc	a0,0x5
    4dd0:	d2c50513          	addi	a0,a0,-724 # 9af8 <malloc+0x1b16>
    4dd4:	00003097          	auipc	ra,0x3
    4dd8:	b3c080e7          	jalr	-1220(ra) # 7910 <mkdir>
    link("README", "");
    4ddc:	00005597          	auipc	a1,0x5
    4de0:	d1c58593          	addi	a1,a1,-740 # 9af8 <malloc+0x1b16>
    4de4:	00003517          	auipc	a0,0x3
    4de8:	3fc50513          	addi	a0,a0,1020 # 81e0 <malloc+0x1fe>
    4dec:	00003097          	auipc	ra,0x3
    4df0:	b1c080e7          	jalr	-1252(ra) # 7908 <link>
    fd = open("", O_CREATE);
    4df4:	20000593          	li	a1,512
    4df8:	00005517          	auipc	a0,0x5
    4dfc:	d0050513          	addi	a0,a0,-768 # 9af8 <malloc+0x1b16>
    4e00:	00003097          	auipc	ra,0x3
    4e04:	ae8080e7          	jalr	-1304(ra) # 78e8 <open>
    4e08:	87aa                	mv	a5,a0
    4e0a:	fef42423          	sw	a5,-24(s0)
    if(fd >= 0)
    4e0e:	fe842783          	lw	a5,-24(s0)
    4e12:	2781                	sext.w	a5,a5
    4e14:	0007c963          	bltz	a5,4e26 <iref+0xd0>
      close(fd);
    4e18:	fe842783          	lw	a5,-24(s0)
    4e1c:	853e                	mv	a0,a5
    4e1e:	00003097          	auipc	ra,0x3
    4e22:	ab2080e7          	jalr	-1358(ra) # 78d0 <close>
    fd = open("xx", O_CREATE);
    4e26:	20000593          	li	a1,512
    4e2a:	00003517          	auipc	a0,0x3
    4e2e:	4de50513          	addi	a0,a0,1246 # 8308 <malloc+0x326>
    4e32:	00003097          	auipc	ra,0x3
    4e36:	ab6080e7          	jalr	-1354(ra) # 78e8 <open>
    4e3a:	87aa                	mv	a5,a0
    4e3c:	fef42423          	sw	a5,-24(s0)
    if(fd >= 0)
    4e40:	fe842783          	lw	a5,-24(s0)
    4e44:	2781                	sext.w	a5,a5
    4e46:	0007c963          	bltz	a5,4e58 <iref+0x102>
      close(fd);
    4e4a:	fe842783          	lw	a5,-24(s0)
    4e4e:	853e                	mv	a0,a5
    4e50:	00003097          	auipc	ra,0x3
    4e54:	a80080e7          	jalr	-1408(ra) # 78d0 <close>
    unlink("xx");
    4e58:	00003517          	auipc	a0,0x3
    4e5c:	4b050513          	addi	a0,a0,1200 # 8308 <malloc+0x326>
    4e60:	00003097          	auipc	ra,0x3
    4e64:	a98080e7          	jalr	-1384(ra) # 78f8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4e68:	fec42783          	lw	a5,-20(s0)
    4e6c:	2785                	addiw	a5,a5,1
    4e6e:	fef42623          	sw	a5,-20(s0)
    4e72:	fec42783          	lw	a5,-20(s0)
    4e76:	0007871b          	sext.w	a4,a5
    4e7a:	03200793          	li	a5,50
    4e7e:	eee7d5e3          	bge	a5,a4,4d68 <iref+0x12>
  }

  // clean up
  for(i = 0; i < NINODE + 1; i++){
    4e82:	fe042623          	sw	zero,-20(s0)
    4e86:	a035                	j	4eb2 <iref+0x15c>
    chdir("..");
    4e88:	00004517          	auipc	a0,0x4
    4e8c:	ab850513          	addi	a0,a0,-1352 # 8940 <malloc+0x95e>
    4e90:	00003097          	auipc	ra,0x3
    4e94:	a88080e7          	jalr	-1400(ra) # 7918 <chdir>
    unlink("irefd");
    4e98:	00005517          	auipc	a0,0x5
    4e9c:	c2850513          	addi	a0,a0,-984 # 9ac0 <malloc+0x1ade>
    4ea0:	00003097          	auipc	ra,0x3
    4ea4:	a58080e7          	jalr	-1448(ra) # 78f8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4ea8:	fec42783          	lw	a5,-20(s0)
    4eac:	2785                	addiw	a5,a5,1
    4eae:	fef42623          	sw	a5,-20(s0)
    4eb2:	fec42783          	lw	a5,-20(s0)
    4eb6:	0007871b          	sext.w	a4,a5
    4eba:	03200793          	li	a5,50
    4ebe:	fce7d5e3          	bge	a5,a4,4e88 <iref+0x132>
  }

  chdir("/");
    4ec2:	00003517          	auipc	a0,0x3
    4ec6:	79650513          	addi	a0,a0,1942 # 8658 <malloc+0x676>
    4eca:	00003097          	auipc	ra,0x3
    4ece:	a4e080e7          	jalr	-1458(ra) # 7918 <chdir>
}
    4ed2:	0001                	nop
    4ed4:	70a2                	ld	ra,40(sp)
    4ed6:	7402                	ld	s0,32(sp)
    4ed8:	6145                	addi	sp,sp,48
    4eda:	8082                	ret

0000000000004edc <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(char *s)
{
    4edc:	7179                	addi	sp,sp,-48
    4ede:	f406                	sd	ra,40(sp)
    4ee0:	f022                	sd	s0,32(sp)
    4ee2:	1800                	addi	s0,sp,48
    4ee4:	fca43c23          	sd	a0,-40(s0)
  enum{ N = 1000 };
  int n, pid;

  for(n=0; n<N; n++){
    4ee8:	fe042623          	sw	zero,-20(s0)
    4eec:	a81d                	j	4f22 <forktest+0x46>
    pid = fork();
    4eee:	00003097          	auipc	ra,0x3
    4ef2:	9b2080e7          	jalr	-1614(ra) # 78a0 <fork>
    4ef6:	87aa                	mv	a5,a0
    4ef8:	fef42423          	sw	a5,-24(s0)
    if(pid < 0)
    4efc:	fe842783          	lw	a5,-24(s0)
    4f00:	2781                	sext.w	a5,a5
    4f02:	0207c963          	bltz	a5,4f34 <forktest+0x58>
      break;
    if(pid == 0)
    4f06:	fe842783          	lw	a5,-24(s0)
    4f0a:	2781                	sext.w	a5,a5
    4f0c:	e791                	bnez	a5,4f18 <forktest+0x3c>
      exit(0);
    4f0e:	4501                	li	a0,0
    4f10:	00003097          	auipc	ra,0x3
    4f14:	998080e7          	jalr	-1640(ra) # 78a8 <exit>
  for(n=0; n<N; n++){
    4f18:	fec42783          	lw	a5,-20(s0)
    4f1c:	2785                	addiw	a5,a5,1
    4f1e:	fef42623          	sw	a5,-20(s0)
    4f22:	fec42783          	lw	a5,-20(s0)
    4f26:	0007871b          	sext.w	a4,a5
    4f2a:	3e700793          	li	a5,999
    4f2e:	fce7d0e3          	bge	a5,a4,4eee <forktest+0x12>
    4f32:	a011                	j	4f36 <forktest+0x5a>
      break;
    4f34:	0001                	nop
  }

  if (n == 0) {
    4f36:	fec42783          	lw	a5,-20(s0)
    4f3a:	2781                	sext.w	a5,a5
    4f3c:	e385                	bnez	a5,4f5c <forktest+0x80>
    printf("%s: no fork at all!\n", s);
    4f3e:	fd843583          	ld	a1,-40(s0)
    4f42:	00005517          	auipc	a0,0x5
    4f46:	bbe50513          	addi	a0,a0,-1090 # 9b00 <malloc+0x1b1e>
    4f4a:	00003097          	auipc	ra,0x3
    4f4e:	ea6080e7          	jalr	-346(ra) # 7df0 <printf>
    exit(1);
    4f52:	4505                	li	a0,1
    4f54:	00003097          	auipc	ra,0x3
    4f58:	954080e7          	jalr	-1708(ra) # 78a8 <exit>
  }

  if(n == N){
    4f5c:	fec42783          	lw	a5,-20(s0)
    4f60:	0007871b          	sext.w	a4,a5
    4f64:	3e800793          	li	a5,1000
    4f68:	04f71d63          	bne	a4,a5,4fc2 <forktest+0xe6>
    printf("%s: fork claimed to work 1000 times!\n", s);
    4f6c:	fd843583          	ld	a1,-40(s0)
    4f70:	00005517          	auipc	a0,0x5
    4f74:	ba850513          	addi	a0,a0,-1112 # 9b18 <malloc+0x1b36>
    4f78:	00003097          	auipc	ra,0x3
    4f7c:	e78080e7          	jalr	-392(ra) # 7df0 <printf>
    exit(1);
    4f80:	4505                	li	a0,1
    4f82:	00003097          	auipc	ra,0x3
    4f86:	926080e7          	jalr	-1754(ra) # 78a8 <exit>
  }

  for(; n > 0; n--){
    if(wait(0) < 0){
    4f8a:	4501                	li	a0,0
    4f8c:	00003097          	auipc	ra,0x3
    4f90:	924080e7          	jalr	-1756(ra) # 78b0 <wait>
    4f94:	87aa                	mv	a5,a0
    4f96:	0207d163          	bgez	a5,4fb8 <forktest+0xdc>
      printf("%s: wait stopped early\n", s);
    4f9a:	fd843583          	ld	a1,-40(s0)
    4f9e:	00005517          	auipc	a0,0x5
    4fa2:	ba250513          	addi	a0,a0,-1118 # 9b40 <malloc+0x1b5e>
    4fa6:	00003097          	auipc	ra,0x3
    4faa:	e4a080e7          	jalr	-438(ra) # 7df0 <printf>
      exit(1);
    4fae:	4505                	li	a0,1
    4fb0:	00003097          	auipc	ra,0x3
    4fb4:	8f8080e7          	jalr	-1800(ra) # 78a8 <exit>
  for(; n > 0; n--){
    4fb8:	fec42783          	lw	a5,-20(s0)
    4fbc:	37fd                	addiw	a5,a5,-1
    4fbe:	fef42623          	sw	a5,-20(s0)
    4fc2:	fec42783          	lw	a5,-20(s0)
    4fc6:	2781                	sext.w	a5,a5
    4fc8:	fcf041e3          	bgtz	a5,4f8a <forktest+0xae>
    }
  }

  if(wait(0) != -1){
    4fcc:	4501                	li	a0,0
    4fce:	00003097          	auipc	ra,0x3
    4fd2:	8e2080e7          	jalr	-1822(ra) # 78b0 <wait>
    4fd6:	87aa                	mv	a5,a0
    4fd8:	873e                	mv	a4,a5
    4fda:	57fd                	li	a5,-1
    4fdc:	02f70163          	beq	a4,a5,4ffe <forktest+0x122>
    printf("%s: wait got too many\n", s);
    4fe0:	fd843583          	ld	a1,-40(s0)
    4fe4:	00005517          	auipc	a0,0x5
    4fe8:	b7450513          	addi	a0,a0,-1164 # 9b58 <malloc+0x1b76>
    4fec:	00003097          	auipc	ra,0x3
    4ff0:	e04080e7          	jalr	-508(ra) # 7df0 <printf>
    exit(1);
    4ff4:	4505                	li	a0,1
    4ff6:	00003097          	auipc	ra,0x3
    4ffa:	8b2080e7          	jalr	-1870(ra) # 78a8 <exit>
  }
}
    4ffe:	0001                	nop
    5000:	70a2                	ld	ra,40(sp)
    5002:	7402                	ld	s0,32(sp)
    5004:	6145                	addi	sp,sp,48
    5006:	8082                	ret

0000000000005008 <sbrkbasic>:

void
sbrkbasic(char *s)
{
    5008:	715d                	addi	sp,sp,-80
    500a:	e486                	sd	ra,72(sp)
    500c:	e0a2                	sd	s0,64(sp)
    500e:	0880                	addi	s0,sp,80
    5010:	faa43c23          	sd	a0,-72(s0)
  enum { TOOMUCH=1024*1024*1024};
  int i, pid, xstatus;
  char *c, *a, *b;

  // does sbrk() return the expected failure value?
  pid = fork();
    5014:	00003097          	auipc	ra,0x3
    5018:	88c080e7          	jalr	-1908(ra) # 78a0 <fork>
    501c:	87aa                	mv	a5,a0
    501e:	fcf42a23          	sw	a5,-44(s0)
  if(pid < 0){
    5022:	fd442783          	lw	a5,-44(s0)
    5026:	2781                	sext.w	a5,a5
    5028:	0007df63          	bgez	a5,5046 <sbrkbasic+0x3e>
    printf("fork failed in sbrkbasic\n");
    502c:	00005517          	auipc	a0,0x5
    5030:	b4450513          	addi	a0,a0,-1212 # 9b70 <malloc+0x1b8e>
    5034:	00003097          	auipc	ra,0x3
    5038:	dbc080e7          	jalr	-580(ra) # 7df0 <printf>
    exit(1);
    503c:	4505                	li	a0,1
    503e:	00003097          	auipc	ra,0x3
    5042:	86a080e7          	jalr	-1942(ra) # 78a8 <exit>
  }
  if(pid == 0){
    5046:	fd442783          	lw	a5,-44(s0)
    504a:	2781                	sext.w	a5,a5
    504c:	e3b5                	bnez	a5,50b0 <sbrkbasic+0xa8>
    a = sbrk(TOOMUCH);
    504e:	40000537          	lui	a0,0x40000
    5052:	00003097          	auipc	ra,0x3
    5056:	8de080e7          	jalr	-1826(ra) # 7930 <sbrk>
    505a:	fea43023          	sd	a0,-32(s0)
    if(a == (char*)0xffffffffffffffffL){
    505e:	fe043703          	ld	a4,-32(s0)
    5062:	57fd                	li	a5,-1
    5064:	00f71763          	bne	a4,a5,5072 <sbrkbasic+0x6a>
      // it's OK if this fails.
      exit(0);
    5068:	4501                	li	a0,0
    506a:	00003097          	auipc	ra,0x3
    506e:	83e080e7          	jalr	-1986(ra) # 78a8 <exit>
    }
    
    for(b = a; b < a+TOOMUCH; b += 4096){
    5072:	fe043783          	ld	a5,-32(s0)
    5076:	fcf43c23          	sd	a5,-40(s0)
    507a:	a829                	j	5094 <sbrkbasic+0x8c>
      *b = 99;
    507c:	fd843783          	ld	a5,-40(s0)
    5080:	06300713          	li	a4,99
    5084:	00e78023          	sb	a4,0(a5)
    for(b = a; b < a+TOOMUCH; b += 4096){
    5088:	fd843703          	ld	a4,-40(s0)
    508c:	6785                	lui	a5,0x1
    508e:	97ba                	add	a5,a5,a4
    5090:	fcf43c23          	sd	a5,-40(s0)
    5094:	fe043703          	ld	a4,-32(s0)
    5098:	400007b7          	lui	a5,0x40000
    509c:	97ba                	add	a5,a5,a4
    509e:	fd843703          	ld	a4,-40(s0)
    50a2:	fcf76de3          	bltu	a4,a5,507c <sbrkbasic+0x74>
    }
    
    // we should not get here! either sbrk(TOOMUCH)
    // should have failed, or (with lazy allocation)
    // a pagefault should have killed this process.
    exit(1);
    50a6:	4505                	li	a0,1
    50a8:	00003097          	auipc	ra,0x3
    50ac:	800080e7          	jalr	-2048(ra) # 78a8 <exit>
  }

  wait(&xstatus);
    50b0:	fc440793          	addi	a5,s0,-60
    50b4:	853e                	mv	a0,a5
    50b6:	00002097          	auipc	ra,0x2
    50ba:	7fa080e7          	jalr	2042(ra) # 78b0 <wait>
  if(xstatus == 1){
    50be:	fc442783          	lw	a5,-60(s0)
    50c2:	873e                	mv	a4,a5
    50c4:	4785                	li	a5,1
    50c6:	02f71163          	bne	a4,a5,50e8 <sbrkbasic+0xe0>
    printf("%s: too much memory allocated!\n", s);
    50ca:	fb843583          	ld	a1,-72(s0)
    50ce:	00005517          	auipc	a0,0x5
    50d2:	ac250513          	addi	a0,a0,-1342 # 9b90 <malloc+0x1bae>
    50d6:	00003097          	auipc	ra,0x3
    50da:	d1a080e7          	jalr	-742(ra) # 7df0 <printf>
    exit(1);
    50de:	4505                	li	a0,1
    50e0:	00002097          	auipc	ra,0x2
    50e4:	7c8080e7          	jalr	1992(ra) # 78a8 <exit>
  }

  // can one sbrk() less than a page?
  a = sbrk(0);
    50e8:	4501                	li	a0,0
    50ea:	00003097          	auipc	ra,0x3
    50ee:	846080e7          	jalr	-1978(ra) # 7930 <sbrk>
    50f2:	fea43023          	sd	a0,-32(s0)
  for(i = 0; i < 5000; i++){
    50f6:	fe042623          	sw	zero,-20(s0)
    50fa:	a09d                	j	5160 <sbrkbasic+0x158>
    b = sbrk(1);
    50fc:	4505                	li	a0,1
    50fe:	00003097          	auipc	ra,0x3
    5102:	832080e7          	jalr	-1998(ra) # 7930 <sbrk>
    5106:	fca43c23          	sd	a0,-40(s0)
    if(b != a){
    510a:	fd843703          	ld	a4,-40(s0)
    510e:	fe043783          	ld	a5,-32(s0)
    5112:	02f70863          	beq	a4,a5,5142 <sbrkbasic+0x13a>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    5116:	fec42783          	lw	a5,-20(s0)
    511a:	fd843703          	ld	a4,-40(s0)
    511e:	fe043683          	ld	a3,-32(s0)
    5122:	863e                	mv	a2,a5
    5124:	fb843583          	ld	a1,-72(s0)
    5128:	00005517          	auipc	a0,0x5
    512c:	a8850513          	addi	a0,a0,-1400 # 9bb0 <malloc+0x1bce>
    5130:	00003097          	auipc	ra,0x3
    5134:	cc0080e7          	jalr	-832(ra) # 7df0 <printf>
      exit(1);
    5138:	4505                	li	a0,1
    513a:	00002097          	auipc	ra,0x2
    513e:	76e080e7          	jalr	1902(ra) # 78a8 <exit>
    }
    *b = 1;
    5142:	fd843783          	ld	a5,-40(s0)
    5146:	4705                	li	a4,1
    5148:	00e78023          	sb	a4,0(a5) # 40000000 <freep+0x3ffee368>
    a = b + 1;
    514c:	fd843783          	ld	a5,-40(s0)
    5150:	0785                	addi	a5,a5,1
    5152:	fef43023          	sd	a5,-32(s0)
  for(i = 0; i < 5000; i++){
    5156:	fec42783          	lw	a5,-20(s0)
    515a:	2785                	addiw	a5,a5,1
    515c:	fef42623          	sw	a5,-20(s0)
    5160:	fec42783          	lw	a5,-20(s0)
    5164:	0007871b          	sext.w	a4,a5
    5168:	6785                	lui	a5,0x1
    516a:	38778793          	addi	a5,a5,903 # 1387 <openiputtest+0xe9>
    516e:	f8e7d7e3          	bge	a5,a4,50fc <sbrkbasic+0xf4>
  }
  pid = fork();
    5172:	00002097          	auipc	ra,0x2
    5176:	72e080e7          	jalr	1838(ra) # 78a0 <fork>
    517a:	87aa                	mv	a5,a0
    517c:	fcf42a23          	sw	a5,-44(s0)
  if(pid < 0){
    5180:	fd442783          	lw	a5,-44(s0)
    5184:	2781                	sext.w	a5,a5
    5186:	0207d163          	bgez	a5,51a8 <sbrkbasic+0x1a0>
    printf("%s: sbrk test fork failed\n", s);
    518a:	fb843583          	ld	a1,-72(s0)
    518e:	00005517          	auipc	a0,0x5
    5192:	a4250513          	addi	a0,a0,-1470 # 9bd0 <malloc+0x1bee>
    5196:	00003097          	auipc	ra,0x3
    519a:	c5a080e7          	jalr	-934(ra) # 7df0 <printf>
    exit(1);
    519e:	4505                	li	a0,1
    51a0:	00002097          	auipc	ra,0x2
    51a4:	708080e7          	jalr	1800(ra) # 78a8 <exit>
  }
  c = sbrk(1);
    51a8:	4505                	li	a0,1
    51aa:	00002097          	auipc	ra,0x2
    51ae:	786080e7          	jalr	1926(ra) # 7930 <sbrk>
    51b2:	fca43423          	sd	a0,-56(s0)
  c = sbrk(1);
    51b6:	4505                	li	a0,1
    51b8:	00002097          	auipc	ra,0x2
    51bc:	778080e7          	jalr	1912(ra) # 7930 <sbrk>
    51c0:	fca43423          	sd	a0,-56(s0)
  if(c != a + 1){
    51c4:	fe043783          	ld	a5,-32(s0)
    51c8:	0785                	addi	a5,a5,1
    51ca:	fc843703          	ld	a4,-56(s0)
    51ce:	02f70163          	beq	a4,a5,51f0 <sbrkbasic+0x1e8>
    printf("%s: sbrk test failed post-fork\n", s);
    51d2:	fb843583          	ld	a1,-72(s0)
    51d6:	00005517          	auipc	a0,0x5
    51da:	a1a50513          	addi	a0,a0,-1510 # 9bf0 <malloc+0x1c0e>
    51de:	00003097          	auipc	ra,0x3
    51e2:	c12080e7          	jalr	-1006(ra) # 7df0 <printf>
    exit(1);
    51e6:	4505                	li	a0,1
    51e8:	00002097          	auipc	ra,0x2
    51ec:	6c0080e7          	jalr	1728(ra) # 78a8 <exit>
  }
  if(pid == 0)
    51f0:	fd442783          	lw	a5,-44(s0)
    51f4:	2781                	sext.w	a5,a5
    51f6:	e791                	bnez	a5,5202 <sbrkbasic+0x1fa>
    exit(0);
    51f8:	4501                	li	a0,0
    51fa:	00002097          	auipc	ra,0x2
    51fe:	6ae080e7          	jalr	1710(ra) # 78a8 <exit>
  wait(&xstatus);
    5202:	fc440793          	addi	a5,s0,-60
    5206:	853e                	mv	a0,a5
    5208:	00002097          	auipc	ra,0x2
    520c:	6a8080e7          	jalr	1704(ra) # 78b0 <wait>
  exit(xstatus);
    5210:	fc442783          	lw	a5,-60(s0)
    5214:	853e                	mv	a0,a5
    5216:	00002097          	auipc	ra,0x2
    521a:	692080e7          	jalr	1682(ra) # 78a8 <exit>

000000000000521e <sbrkmuch>:
}

void
sbrkmuch(char *s)
{
    521e:	711d                	addi	sp,sp,-96
    5220:	ec86                	sd	ra,88(sp)
    5222:	e8a2                	sd	s0,80(sp)
    5224:	1080                	addi	s0,sp,96
    5226:	faa43423          	sd	a0,-88(s0)
  enum { BIG=100*1024*1024 };
  char *c, *oldbrk, *a, *lastaddr, *p;
  uint64 amt;

  oldbrk = sbrk(0);
    522a:	4501                	li	a0,0
    522c:	00002097          	auipc	ra,0x2
    5230:	704080e7          	jalr	1796(ra) # 7930 <sbrk>
    5234:	fea43023          	sd	a0,-32(s0)

  // can one grow address space to something big?
  a = sbrk(0);
    5238:	4501                	li	a0,0
    523a:	00002097          	auipc	ra,0x2
    523e:	6f6080e7          	jalr	1782(ra) # 7930 <sbrk>
    5242:	fca43c23          	sd	a0,-40(s0)
  amt = BIG - (uint64)a;
    5246:	fd843783          	ld	a5,-40(s0)
    524a:	06400737          	lui	a4,0x6400
    524e:	40f707b3          	sub	a5,a4,a5
    5252:	fcf43823          	sd	a5,-48(s0)
  p = sbrk(amt);
    5256:	fd043783          	ld	a5,-48(s0)
    525a:	2781                	sext.w	a5,a5
    525c:	853e                	mv	a0,a5
    525e:	00002097          	auipc	ra,0x2
    5262:	6d2080e7          	jalr	1746(ra) # 7930 <sbrk>
    5266:	fca43423          	sd	a0,-56(s0)
  if (p != a) {
    526a:	fc843703          	ld	a4,-56(s0)
    526e:	fd843783          	ld	a5,-40(s0)
    5272:	02f70163          	beq	a4,a5,5294 <sbrkmuch+0x76>
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    5276:	fa843583          	ld	a1,-88(s0)
    527a:	00005517          	auipc	a0,0x5
    527e:	99650513          	addi	a0,a0,-1642 # 9c10 <malloc+0x1c2e>
    5282:	00003097          	auipc	ra,0x3
    5286:	b6e080e7          	jalr	-1170(ra) # 7df0 <printf>
    exit(1);
    528a:	4505                	li	a0,1
    528c:	00002097          	auipc	ra,0x2
    5290:	61c080e7          	jalr	1564(ra) # 78a8 <exit>
  }

  // touch each page to make sure it exists.
  char *eee = sbrk(0);
    5294:	4501                	li	a0,0
    5296:	00002097          	auipc	ra,0x2
    529a:	69a080e7          	jalr	1690(ra) # 7930 <sbrk>
    529e:	fca43023          	sd	a0,-64(s0)
  for(char *pp = a; pp < eee; pp += 4096)
    52a2:	fd843783          	ld	a5,-40(s0)
    52a6:	fef43423          	sd	a5,-24(s0)
    52aa:	a821                	j	52c2 <sbrkmuch+0xa4>
    *pp = 1;
    52ac:	fe843783          	ld	a5,-24(s0)
    52b0:	4705                	li	a4,1
    52b2:	00e78023          	sb	a4,0(a5)
  for(char *pp = a; pp < eee; pp += 4096)
    52b6:	fe843703          	ld	a4,-24(s0)
    52ba:	6785                	lui	a5,0x1
    52bc:	97ba                	add	a5,a5,a4
    52be:	fef43423          	sd	a5,-24(s0)
    52c2:	fe843703          	ld	a4,-24(s0)
    52c6:	fc043783          	ld	a5,-64(s0)
    52ca:	fef761e3          	bltu	a4,a5,52ac <sbrkmuch+0x8e>

  lastaddr = (char*) (BIG-1);
    52ce:	064007b7          	lui	a5,0x6400
    52d2:	17fd                	addi	a5,a5,-1 # 63fffff <freep+0x63ee367>
    52d4:	faf43c23          	sd	a5,-72(s0)
  *lastaddr = 99;
    52d8:	fb843783          	ld	a5,-72(s0)
    52dc:	06300713          	li	a4,99
    52e0:	00e78023          	sb	a4,0(a5)

  // can one de-allocate?
  a = sbrk(0);
    52e4:	4501                	li	a0,0
    52e6:	00002097          	auipc	ra,0x2
    52ea:	64a080e7          	jalr	1610(ra) # 7930 <sbrk>
    52ee:	fca43c23          	sd	a0,-40(s0)
  c = sbrk(-PGSIZE);
    52f2:	757d                	lui	a0,0xfffff
    52f4:	00002097          	auipc	ra,0x2
    52f8:	63c080e7          	jalr	1596(ra) # 7930 <sbrk>
    52fc:	faa43823          	sd	a0,-80(s0)
  if(c == (char*)0xffffffffffffffffL){
    5300:	fb043703          	ld	a4,-80(s0)
    5304:	57fd                	li	a5,-1
    5306:	02f71163          	bne	a4,a5,5328 <sbrkmuch+0x10a>
    printf("%s: sbrk could not deallocate\n", s);
    530a:	fa843583          	ld	a1,-88(s0)
    530e:	00005517          	auipc	a0,0x5
    5312:	94a50513          	addi	a0,a0,-1718 # 9c58 <malloc+0x1c76>
    5316:	00003097          	auipc	ra,0x3
    531a:	ada080e7          	jalr	-1318(ra) # 7df0 <printf>
    exit(1);
    531e:	4505                	li	a0,1
    5320:	00002097          	auipc	ra,0x2
    5324:	588080e7          	jalr	1416(ra) # 78a8 <exit>
  }
  c = sbrk(0);
    5328:	4501                	li	a0,0
    532a:	00002097          	auipc	ra,0x2
    532e:	606080e7          	jalr	1542(ra) # 7930 <sbrk>
    5332:	faa43823          	sd	a0,-80(s0)
  if(c != a - PGSIZE){
    5336:	fd843703          	ld	a4,-40(s0)
    533a:	77fd                	lui	a5,0xfffff
    533c:	97ba                	add	a5,a5,a4
    533e:	fb043703          	ld	a4,-80(s0)
    5342:	02f70563          	beq	a4,a5,536c <sbrkmuch+0x14e>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    5346:	fb043683          	ld	a3,-80(s0)
    534a:	fd843603          	ld	a2,-40(s0)
    534e:	fa843583          	ld	a1,-88(s0)
    5352:	00005517          	auipc	a0,0x5
    5356:	92650513          	addi	a0,a0,-1754 # 9c78 <malloc+0x1c96>
    535a:	00003097          	auipc	ra,0x3
    535e:	a96080e7          	jalr	-1386(ra) # 7df0 <printf>
    exit(1);
    5362:	4505                	li	a0,1
    5364:	00002097          	auipc	ra,0x2
    5368:	544080e7          	jalr	1348(ra) # 78a8 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    536c:	4501                	li	a0,0
    536e:	00002097          	auipc	ra,0x2
    5372:	5c2080e7          	jalr	1474(ra) # 7930 <sbrk>
    5376:	fca43c23          	sd	a0,-40(s0)
  c = sbrk(PGSIZE);
    537a:	6505                	lui	a0,0x1
    537c:	00002097          	auipc	ra,0x2
    5380:	5b4080e7          	jalr	1460(ra) # 7930 <sbrk>
    5384:	faa43823          	sd	a0,-80(s0)
  if(c != a || sbrk(0) != a + PGSIZE){
    5388:	fb043703          	ld	a4,-80(s0)
    538c:	fd843783          	ld	a5,-40(s0)
    5390:	00f71e63          	bne	a4,a5,53ac <sbrkmuch+0x18e>
    5394:	4501                	li	a0,0
    5396:	00002097          	auipc	ra,0x2
    539a:	59a080e7          	jalr	1434(ra) # 7930 <sbrk>
    539e:	86aa                	mv	a3,a0
    53a0:	fd843703          	ld	a4,-40(s0)
    53a4:	6785                	lui	a5,0x1
    53a6:	97ba                	add	a5,a5,a4
    53a8:	02f68563          	beq	a3,a5,53d2 <sbrkmuch+0x1b4>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    53ac:	fb043683          	ld	a3,-80(s0)
    53b0:	fd843603          	ld	a2,-40(s0)
    53b4:	fa843583          	ld	a1,-88(s0)
    53b8:	00005517          	auipc	a0,0x5
    53bc:	90050513          	addi	a0,a0,-1792 # 9cb8 <malloc+0x1cd6>
    53c0:	00003097          	auipc	ra,0x3
    53c4:	a30080e7          	jalr	-1488(ra) # 7df0 <printf>
    exit(1);
    53c8:	4505                	li	a0,1
    53ca:	00002097          	auipc	ra,0x2
    53ce:	4de080e7          	jalr	1246(ra) # 78a8 <exit>
  }
  if(*lastaddr == 99){
    53d2:	fb843783          	ld	a5,-72(s0)
    53d6:	0007c783          	lbu	a5,0(a5) # 1000 <truncate3+0x1b2>
    53da:	873e                	mv	a4,a5
    53dc:	06300793          	li	a5,99
    53e0:	02f71163          	bne	a4,a5,5402 <sbrkmuch+0x1e4>
    // should be zero
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    53e4:	fa843583          	ld	a1,-88(s0)
    53e8:	00005517          	auipc	a0,0x5
    53ec:	90050513          	addi	a0,a0,-1792 # 9ce8 <malloc+0x1d06>
    53f0:	00003097          	auipc	ra,0x3
    53f4:	a00080e7          	jalr	-1536(ra) # 7df0 <printf>
    exit(1);
    53f8:	4505                	li	a0,1
    53fa:	00002097          	auipc	ra,0x2
    53fe:	4ae080e7          	jalr	1198(ra) # 78a8 <exit>
  }

  a = sbrk(0);
    5402:	4501                	li	a0,0
    5404:	00002097          	auipc	ra,0x2
    5408:	52c080e7          	jalr	1324(ra) # 7930 <sbrk>
    540c:	fca43c23          	sd	a0,-40(s0)
  c = sbrk(-(sbrk(0) - oldbrk));
    5410:	4501                	li	a0,0
    5412:	00002097          	auipc	ra,0x2
    5416:	51e080e7          	jalr	1310(ra) # 7930 <sbrk>
    541a:	872a                	mv	a4,a0
    541c:	fe043783          	ld	a5,-32(s0)
    5420:	8f99                	sub	a5,a5,a4
    5422:	2781                	sext.w	a5,a5
    5424:	853e                	mv	a0,a5
    5426:	00002097          	auipc	ra,0x2
    542a:	50a080e7          	jalr	1290(ra) # 7930 <sbrk>
    542e:	faa43823          	sd	a0,-80(s0)
  if(c != a){
    5432:	fb043703          	ld	a4,-80(s0)
    5436:	fd843783          	ld	a5,-40(s0)
    543a:	02f70563          	beq	a4,a5,5464 <sbrkmuch+0x246>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    543e:	fb043683          	ld	a3,-80(s0)
    5442:	fd843603          	ld	a2,-40(s0)
    5446:	fa843583          	ld	a1,-88(s0)
    544a:	00005517          	auipc	a0,0x5
    544e:	8d650513          	addi	a0,a0,-1834 # 9d20 <malloc+0x1d3e>
    5452:	00003097          	auipc	ra,0x3
    5456:	99e080e7          	jalr	-1634(ra) # 7df0 <printf>
    exit(1);
    545a:	4505                	li	a0,1
    545c:	00002097          	auipc	ra,0x2
    5460:	44c080e7          	jalr	1100(ra) # 78a8 <exit>
  }
}
    5464:	0001                	nop
    5466:	60e6                	ld	ra,88(sp)
    5468:	6446                	ld	s0,80(sp)
    546a:	6125                	addi	sp,sp,96
    546c:	8082                	ret

000000000000546e <kernmem>:

// can we read the kernel's memory?
void
kernmem(char *s)
{
    546e:	7179                	addi	sp,sp,-48
    5470:	f406                	sd	ra,40(sp)
    5472:	f022                	sd	s0,32(sp)
    5474:	1800                	addi	s0,sp,48
    5476:	fca43c23          	sd	a0,-40(s0)
  char *a;
  int pid;

  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    547a:	4785                	li	a5,1
    547c:	07fe                	slli	a5,a5,0x1f
    547e:	fef43423          	sd	a5,-24(s0)
    5482:	a04d                	j	5524 <kernmem+0xb6>
    pid = fork();
    5484:	00002097          	auipc	ra,0x2
    5488:	41c080e7          	jalr	1052(ra) # 78a0 <fork>
    548c:	87aa                	mv	a5,a0
    548e:	fef42223          	sw	a5,-28(s0)
    if(pid < 0){
    5492:	fe442783          	lw	a5,-28(s0)
    5496:	2781                	sext.w	a5,a5
    5498:	0207d163          	bgez	a5,54ba <kernmem+0x4c>
      printf("%s: fork failed\n", s);
    549c:	fd843583          	ld	a1,-40(s0)
    54a0:	00003517          	auipc	a0,0x3
    54a4:	0c050513          	addi	a0,a0,192 # 8560 <malloc+0x57e>
    54a8:	00003097          	auipc	ra,0x3
    54ac:	948080e7          	jalr	-1720(ra) # 7df0 <printf>
      exit(1);
    54b0:	4505                	li	a0,1
    54b2:	00002097          	auipc	ra,0x2
    54b6:	3f6080e7          	jalr	1014(ra) # 78a8 <exit>
    }
    if(pid == 0){
    54ba:	fe442783          	lw	a5,-28(s0)
    54be:	2781                	sext.w	a5,a5
    54c0:	eb85                	bnez	a5,54f0 <kernmem+0x82>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    54c2:	fe843783          	ld	a5,-24(s0)
    54c6:	0007c783          	lbu	a5,0(a5)
    54ca:	2781                	sext.w	a5,a5
    54cc:	86be                	mv	a3,a5
    54ce:	fe843603          	ld	a2,-24(s0)
    54d2:	fd843583          	ld	a1,-40(s0)
    54d6:	00005517          	auipc	a0,0x5
    54da:	87250513          	addi	a0,a0,-1934 # 9d48 <malloc+0x1d66>
    54de:	00003097          	auipc	ra,0x3
    54e2:	912080e7          	jalr	-1774(ra) # 7df0 <printf>
      exit(1);
    54e6:	4505                	li	a0,1
    54e8:	00002097          	auipc	ra,0x2
    54ec:	3c0080e7          	jalr	960(ra) # 78a8 <exit>
    }
    int xstatus;
    wait(&xstatus);
    54f0:	fe040793          	addi	a5,s0,-32
    54f4:	853e                	mv	a0,a5
    54f6:	00002097          	auipc	ra,0x2
    54fa:	3ba080e7          	jalr	954(ra) # 78b0 <wait>
    if(xstatus != -1)  // did kernel kill child?
    54fe:	fe042783          	lw	a5,-32(s0)
    5502:	873e                	mv	a4,a5
    5504:	57fd                	li	a5,-1
    5506:	00f70763          	beq	a4,a5,5514 <kernmem+0xa6>
      exit(1);
    550a:	4505                	li	a0,1
    550c:	00002097          	auipc	ra,0x2
    5510:	39c080e7          	jalr	924(ra) # 78a8 <exit>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    5514:	fe843703          	ld	a4,-24(s0)
    5518:	67b1                	lui	a5,0xc
    551a:	35078793          	addi	a5,a5,848 # c350 <buf+0xee0>
    551e:	97ba                	add	a5,a5,a4
    5520:	fef43423          	sd	a5,-24(s0)
    5524:	fe843703          	ld	a4,-24(s0)
    5528:	1003d7b7          	lui	a5,0x1003d
    552c:	078e                	slli	a5,a5,0x3
    552e:	47f78793          	addi	a5,a5,1151 # 1003d47f <freep+0x1002b7e7>
    5532:	f4e7f9e3          	bgeu	a5,a4,5484 <kernmem+0x16>
  }
}
    5536:	0001                	nop
    5538:	0001                	nop
    553a:	70a2                	ld	ra,40(sp)
    553c:	7402                	ld	s0,32(sp)
    553e:	6145                	addi	sp,sp,48
    5540:	8082                	ret

0000000000005542 <MAXVAplus>:

// user code should not be able to write to addresses above MAXVA.
void
MAXVAplus(char *s)
{
    5542:	7139                	addi	sp,sp,-64
    5544:	fc06                	sd	ra,56(sp)
    5546:	f822                	sd	s0,48(sp)
    5548:	0080                	addi	s0,sp,64
    554a:	fca43423          	sd	a0,-56(s0)
  volatile uint64 a = MAXVA;
    554e:	4785                	li	a5,1
    5550:	179a                	slli	a5,a5,0x26
    5552:	fef43023          	sd	a5,-32(s0)
  for( ; a != 0; a <<= 1){
    5556:	a045                	j	55f6 <MAXVAplus+0xb4>
    int pid;
    pid = fork();
    5558:	00002097          	auipc	ra,0x2
    555c:	348080e7          	jalr	840(ra) # 78a0 <fork>
    5560:	87aa                	mv	a5,a0
    5562:	fef42623          	sw	a5,-20(s0)
    if(pid < 0){
    5566:	fec42783          	lw	a5,-20(s0)
    556a:	2781                	sext.w	a5,a5
    556c:	0207d163          	bgez	a5,558e <MAXVAplus+0x4c>
      printf("%s: fork failed\n", s);
    5570:	fc843583          	ld	a1,-56(s0)
    5574:	00003517          	auipc	a0,0x3
    5578:	fec50513          	addi	a0,a0,-20 # 8560 <malloc+0x57e>
    557c:	00003097          	auipc	ra,0x3
    5580:	874080e7          	jalr	-1932(ra) # 7df0 <printf>
      exit(1);
    5584:	4505                	li	a0,1
    5586:	00002097          	auipc	ra,0x2
    558a:	322080e7          	jalr	802(ra) # 78a8 <exit>
    }
    if(pid == 0){
    558e:	fec42783          	lw	a5,-20(s0)
    5592:	2781                	sext.w	a5,a5
    5594:	eb95                	bnez	a5,55c8 <MAXVAplus+0x86>
      *(char*)a = 99;
    5596:	fe043783          	ld	a5,-32(s0)
    559a:	873e                	mv	a4,a5
    559c:	06300793          	li	a5,99
    55a0:	00f70023          	sb	a5,0(a4) # 6400000 <freep+0x63ee368>
      printf("%s: oops wrote %x\n", s, a);
    55a4:	fe043783          	ld	a5,-32(s0)
    55a8:	863e                	mv	a2,a5
    55aa:	fc843583          	ld	a1,-56(s0)
    55ae:	00004517          	auipc	a0,0x4
    55b2:	7ba50513          	addi	a0,a0,1978 # 9d68 <malloc+0x1d86>
    55b6:	00003097          	auipc	ra,0x3
    55ba:	83a080e7          	jalr	-1990(ra) # 7df0 <printf>
      exit(1);
    55be:	4505                	li	a0,1
    55c0:	00002097          	auipc	ra,0x2
    55c4:	2e8080e7          	jalr	744(ra) # 78a8 <exit>
    }
    int xstatus;
    wait(&xstatus);
    55c8:	fdc40793          	addi	a5,s0,-36
    55cc:	853e                	mv	a0,a5
    55ce:	00002097          	auipc	ra,0x2
    55d2:	2e2080e7          	jalr	738(ra) # 78b0 <wait>
    if(xstatus != -1)  // did kernel kill child?
    55d6:	fdc42783          	lw	a5,-36(s0)
    55da:	873e                	mv	a4,a5
    55dc:	57fd                	li	a5,-1
    55de:	00f70763          	beq	a4,a5,55ec <MAXVAplus+0xaa>
      exit(1);
    55e2:	4505                	li	a0,1
    55e4:	00002097          	auipc	ra,0x2
    55e8:	2c4080e7          	jalr	708(ra) # 78a8 <exit>
  for( ; a != 0; a <<= 1){
    55ec:	fe043783          	ld	a5,-32(s0)
    55f0:	0786                	slli	a5,a5,0x1
    55f2:	fef43023          	sd	a5,-32(s0)
    55f6:	fe043783          	ld	a5,-32(s0)
    55fa:	ffb9                	bnez	a5,5558 <MAXVAplus+0x16>
  }
}
    55fc:	0001                	nop
    55fe:	0001                	nop
    5600:	70e2                	ld	ra,56(sp)
    5602:	7442                	ld	s0,48(sp)
    5604:	6121                	addi	sp,sp,64
    5606:	8082                	ret

0000000000005608 <sbrkfail>:

// if we run the system out of memory, does it clean up the last
// failed allocation?
void
sbrkfail(char *s)
{
    5608:	7119                	addi	sp,sp,-128
    560a:	fc86                	sd	ra,120(sp)
    560c:	f8a2                	sd	s0,112(sp)
    560e:	0100                	addi	s0,sp,128
    5610:	f8a43423          	sd	a0,-120(s0)
  char scratch;
  char *c, *a;
  int pids[10];
  int pid;
 
  if(pipe(fds) != 0){
    5614:	fc040793          	addi	a5,s0,-64
    5618:	853e                	mv	a0,a5
    561a:	00002097          	auipc	ra,0x2
    561e:	29e080e7          	jalr	670(ra) # 78b8 <pipe>
    5622:	87aa                	mv	a5,a0
    5624:	c385                	beqz	a5,5644 <sbrkfail+0x3c>
    printf("%s: pipe() failed\n", s);
    5626:	f8843583          	ld	a1,-120(s0)
    562a:	00003517          	auipc	a0,0x3
    562e:	3ce50513          	addi	a0,a0,974 # 89f8 <malloc+0xa16>
    5632:	00002097          	auipc	ra,0x2
    5636:	7be080e7          	jalr	1982(ra) # 7df0 <printf>
    exit(1);
    563a:	4505                	li	a0,1
    563c:	00002097          	auipc	ra,0x2
    5640:	26c080e7          	jalr	620(ra) # 78a8 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    5644:	fe042623          	sw	zero,-20(s0)
    5648:	a075                	j	56f4 <sbrkfail+0xec>
    if((pids[i] = fork()) == 0){
    564a:	00002097          	auipc	ra,0x2
    564e:	256080e7          	jalr	598(ra) # 78a0 <fork>
    5652:	87aa                	mv	a5,a0
    5654:	873e                	mv	a4,a5
    5656:	fec42783          	lw	a5,-20(s0)
    565a:	078a                	slli	a5,a5,0x2
    565c:	17c1                	addi	a5,a5,-16
    565e:	97a2                	add	a5,a5,s0
    5660:	fae7a023          	sw	a4,-96(a5)
    5664:	fec42783          	lw	a5,-20(s0)
    5668:	078a                	slli	a5,a5,0x2
    566a:	17c1                	addi	a5,a5,-16
    566c:	97a2                	add	a5,a5,s0
    566e:	fa07a783          	lw	a5,-96(a5)
    5672:	e7b1                	bnez	a5,56be <sbrkfail+0xb6>
      // allocate a lot of memory
      sbrk(BIG - (uint64)sbrk(0));
    5674:	4501                	li	a0,0
    5676:	00002097          	auipc	ra,0x2
    567a:	2ba080e7          	jalr	698(ra) # 7930 <sbrk>
    567e:	87aa                	mv	a5,a0
    5680:	2781                	sext.w	a5,a5
    5682:	06400737          	lui	a4,0x6400
    5686:	40f707bb          	subw	a5,a4,a5
    568a:	2781                	sext.w	a5,a5
    568c:	2781                	sext.w	a5,a5
    568e:	853e                	mv	a0,a5
    5690:	00002097          	auipc	ra,0x2
    5694:	2a0080e7          	jalr	672(ra) # 7930 <sbrk>
      write(fds[1], "x", 1);
    5698:	fc442783          	lw	a5,-60(s0)
    569c:	4605                	li	a2,1
    569e:	00003597          	auipc	a1,0x3
    56a2:	b9258593          	addi	a1,a1,-1134 # 8230 <malloc+0x24e>
    56a6:	853e                	mv	a0,a5
    56a8:	00002097          	auipc	ra,0x2
    56ac:	220080e7          	jalr	544(ra) # 78c8 <write>
      // sit around until killed
      for(;;) sleep(1000);
    56b0:	3e800513          	li	a0,1000
    56b4:	00002097          	auipc	ra,0x2
    56b8:	284080e7          	jalr	644(ra) # 7938 <sleep>
    56bc:	bfd5                	j	56b0 <sbrkfail+0xa8>
    }
    if(pids[i] != -1)
    56be:	fec42783          	lw	a5,-20(s0)
    56c2:	078a                	slli	a5,a5,0x2
    56c4:	17c1                	addi	a5,a5,-16
    56c6:	97a2                	add	a5,a5,s0
    56c8:	fa07a783          	lw	a5,-96(a5)
    56cc:	873e                	mv	a4,a5
    56ce:	57fd                	li	a5,-1
    56d0:	00f70d63          	beq	a4,a5,56ea <sbrkfail+0xe2>
      read(fds[0], &scratch, 1);
    56d4:	fc042783          	lw	a5,-64(s0)
    56d8:	fbf40713          	addi	a4,s0,-65
    56dc:	4605                	li	a2,1
    56de:	85ba                	mv	a1,a4
    56e0:	853e                	mv	a0,a5
    56e2:	00002097          	auipc	ra,0x2
    56e6:	1de080e7          	jalr	478(ra) # 78c0 <read>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    56ea:	fec42783          	lw	a5,-20(s0)
    56ee:	2785                	addiw	a5,a5,1
    56f0:	fef42623          	sw	a5,-20(s0)
    56f4:	fec42783          	lw	a5,-20(s0)
    56f8:	873e                	mv	a4,a5
    56fa:	47a5                	li	a5,9
    56fc:	f4e7f7e3          	bgeu	a5,a4,564a <sbrkfail+0x42>
  }

  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(PGSIZE);
    5700:	6505                	lui	a0,0x1
    5702:	00002097          	auipc	ra,0x2
    5706:	22e080e7          	jalr	558(ra) # 7930 <sbrk>
    570a:	fea43023          	sd	a0,-32(s0)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    570e:	fe042623          	sw	zero,-20(s0)
    5712:	a0a1                	j	575a <sbrkfail+0x152>
    if(pids[i] == -1)
    5714:	fec42783          	lw	a5,-20(s0)
    5718:	078a                	slli	a5,a5,0x2
    571a:	17c1                	addi	a5,a5,-16
    571c:	97a2                	add	a5,a5,s0
    571e:	fa07a783          	lw	a5,-96(a5)
    5722:	873e                	mv	a4,a5
    5724:	57fd                	li	a5,-1
    5726:	02f70463          	beq	a4,a5,574e <sbrkfail+0x146>
      continue;
    kill(pids[i]);
    572a:	fec42783          	lw	a5,-20(s0)
    572e:	078a                	slli	a5,a5,0x2
    5730:	17c1                	addi	a5,a5,-16
    5732:	97a2                	add	a5,a5,s0
    5734:	fa07a783          	lw	a5,-96(a5)
    5738:	853e                	mv	a0,a5
    573a:	00002097          	auipc	ra,0x2
    573e:	19e080e7          	jalr	414(ra) # 78d8 <kill>
    wait(0);
    5742:	4501                	li	a0,0
    5744:	00002097          	auipc	ra,0x2
    5748:	16c080e7          	jalr	364(ra) # 78b0 <wait>
    574c:	a011                	j	5750 <sbrkfail+0x148>
      continue;
    574e:	0001                	nop
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    5750:	fec42783          	lw	a5,-20(s0)
    5754:	2785                	addiw	a5,a5,1
    5756:	fef42623          	sw	a5,-20(s0)
    575a:	fec42783          	lw	a5,-20(s0)
    575e:	873e                	mv	a4,a5
    5760:	47a5                	li	a5,9
    5762:	fae7f9e3          	bgeu	a5,a4,5714 <sbrkfail+0x10c>
  }
  if(c == (char*)0xffffffffffffffffL){
    5766:	fe043703          	ld	a4,-32(s0)
    576a:	57fd                	li	a5,-1
    576c:	02f71163          	bne	a4,a5,578e <sbrkfail+0x186>
    printf("%s: failed sbrk leaked memory\n", s);
    5770:	f8843583          	ld	a1,-120(s0)
    5774:	00004517          	auipc	a0,0x4
    5778:	60c50513          	addi	a0,a0,1548 # 9d80 <malloc+0x1d9e>
    577c:	00002097          	auipc	ra,0x2
    5780:	674080e7          	jalr	1652(ra) # 7df0 <printf>
    exit(1);
    5784:	4505                	li	a0,1
    5786:	00002097          	auipc	ra,0x2
    578a:	122080e7          	jalr	290(ra) # 78a8 <exit>
  }

  // test running fork with the above allocated page 
  pid = fork();
    578e:	00002097          	auipc	ra,0x2
    5792:	112080e7          	jalr	274(ra) # 78a0 <fork>
    5796:	87aa                	mv	a5,a0
    5798:	fcf42e23          	sw	a5,-36(s0)
  if(pid < 0){
    579c:	fdc42783          	lw	a5,-36(s0)
    57a0:	2781                	sext.w	a5,a5
    57a2:	0207d163          	bgez	a5,57c4 <sbrkfail+0x1bc>
    printf("%s: fork failed\n", s);
    57a6:	f8843583          	ld	a1,-120(s0)
    57aa:	00003517          	auipc	a0,0x3
    57ae:	db650513          	addi	a0,a0,-586 # 8560 <malloc+0x57e>
    57b2:	00002097          	auipc	ra,0x2
    57b6:	63e080e7          	jalr	1598(ra) # 7df0 <printf>
    exit(1);
    57ba:	4505                	li	a0,1
    57bc:	00002097          	auipc	ra,0x2
    57c0:	0ec080e7          	jalr	236(ra) # 78a8 <exit>
  }
  if(pid == 0){
    57c4:	fdc42783          	lw	a5,-36(s0)
    57c8:	2781                	sext.w	a5,a5
    57ca:	e3c9                	bnez	a5,584c <sbrkfail+0x244>
    // allocate a lot of memory.
    // this should produce a page fault,
    // and thus not complete.
    a = sbrk(0);
    57cc:	4501                	li	a0,0
    57ce:	00002097          	auipc	ra,0x2
    57d2:	162080e7          	jalr	354(ra) # 7930 <sbrk>
    57d6:	fca43823          	sd	a0,-48(s0)
    sbrk(10*BIG);
    57da:	3e800537          	lui	a0,0x3e800
    57de:	00002097          	auipc	ra,0x2
    57e2:	152080e7          	jalr	338(ra) # 7930 <sbrk>
    int n = 0;
    57e6:	fe042423          	sw	zero,-24(s0)
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    57ea:	fe042623          	sw	zero,-20(s0)
    57ee:	a02d                	j	5818 <sbrkfail+0x210>
      n += *(a+i);
    57f0:	fec42783          	lw	a5,-20(s0)
    57f4:	fd043703          	ld	a4,-48(s0)
    57f8:	97ba                	add	a5,a5,a4
    57fa:	0007c783          	lbu	a5,0(a5)
    57fe:	2781                	sext.w	a5,a5
    5800:	fe842703          	lw	a4,-24(s0)
    5804:	9fb9                	addw	a5,a5,a4
    5806:	fef42423          	sw	a5,-24(s0)
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    580a:	fec42783          	lw	a5,-20(s0)
    580e:	873e                	mv	a4,a5
    5810:	6785                	lui	a5,0x1
    5812:	9fb9                	addw	a5,a5,a4
    5814:	fef42623          	sw	a5,-20(s0)
    5818:	fec42783          	lw	a5,-20(s0)
    581c:	0007871b          	sext.w	a4,a5
    5820:	3e8007b7          	lui	a5,0x3e800
    5824:	fcf746e3          	blt	a4,a5,57f0 <sbrkfail+0x1e8>
    }
    // print n so the compiler doesn't optimize away
    // the for loop.
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    5828:	fe842783          	lw	a5,-24(s0)
    582c:	863e                	mv	a2,a5
    582e:	f8843583          	ld	a1,-120(s0)
    5832:	00004517          	auipc	a0,0x4
    5836:	56e50513          	addi	a0,a0,1390 # 9da0 <malloc+0x1dbe>
    583a:	00002097          	auipc	ra,0x2
    583e:	5b6080e7          	jalr	1462(ra) # 7df0 <printf>
    exit(1);
    5842:	4505                	li	a0,1
    5844:	00002097          	auipc	ra,0x2
    5848:	064080e7          	jalr	100(ra) # 78a8 <exit>
  }
  wait(&xstatus);
    584c:	fcc40793          	addi	a5,s0,-52
    5850:	853e                	mv	a0,a5
    5852:	00002097          	auipc	ra,0x2
    5856:	05e080e7          	jalr	94(ra) # 78b0 <wait>
  if(xstatus != -1 && xstatus != 2)
    585a:	fcc42783          	lw	a5,-52(s0)
    585e:	873e                	mv	a4,a5
    5860:	57fd                	li	a5,-1
    5862:	00f70d63          	beq	a4,a5,587c <sbrkfail+0x274>
    5866:	fcc42783          	lw	a5,-52(s0)
    586a:	873e                	mv	a4,a5
    586c:	4789                	li	a5,2
    586e:	00f70763          	beq	a4,a5,587c <sbrkfail+0x274>
    exit(1);
    5872:	4505                	li	a0,1
    5874:	00002097          	auipc	ra,0x2
    5878:	034080e7          	jalr	52(ra) # 78a8 <exit>
}
    587c:	0001                	nop
    587e:	70e6                	ld	ra,120(sp)
    5880:	7446                	ld	s0,112(sp)
    5882:	6109                	addi	sp,sp,128
    5884:	8082                	ret

0000000000005886 <sbrkarg>:

  
// test reads/writes from/to allocated memory
void
sbrkarg(char *s)
{
    5886:	7179                	addi	sp,sp,-48
    5888:	f406                	sd	ra,40(sp)
    588a:	f022                	sd	s0,32(sp)
    588c:	1800                	addi	s0,sp,48
    588e:	fca43c23          	sd	a0,-40(s0)
  char *a;
  int fd, n;

  a = sbrk(PGSIZE);
    5892:	6505                	lui	a0,0x1
    5894:	00002097          	auipc	ra,0x2
    5898:	09c080e7          	jalr	156(ra) # 7930 <sbrk>
    589c:	fea43423          	sd	a0,-24(s0)
  fd = open("sbrk", O_CREATE|O_WRONLY);
    58a0:	20100593          	li	a1,513
    58a4:	00004517          	auipc	a0,0x4
    58a8:	52c50513          	addi	a0,a0,1324 # 9dd0 <malloc+0x1dee>
    58ac:	00002097          	auipc	ra,0x2
    58b0:	03c080e7          	jalr	60(ra) # 78e8 <open>
    58b4:	87aa                	mv	a5,a0
    58b6:	fef42223          	sw	a5,-28(s0)
  unlink("sbrk");
    58ba:	00004517          	auipc	a0,0x4
    58be:	51650513          	addi	a0,a0,1302 # 9dd0 <malloc+0x1dee>
    58c2:	00002097          	auipc	ra,0x2
    58c6:	036080e7          	jalr	54(ra) # 78f8 <unlink>
  if(fd < 0)  {
    58ca:	fe442783          	lw	a5,-28(s0)
    58ce:	2781                	sext.w	a5,a5
    58d0:	0207d163          	bgez	a5,58f2 <sbrkarg+0x6c>
    printf("%s: open sbrk failed\n", s);
    58d4:	fd843583          	ld	a1,-40(s0)
    58d8:	00004517          	auipc	a0,0x4
    58dc:	50050513          	addi	a0,a0,1280 # 9dd8 <malloc+0x1df6>
    58e0:	00002097          	auipc	ra,0x2
    58e4:	510080e7          	jalr	1296(ra) # 7df0 <printf>
    exit(1);
    58e8:	4505                	li	a0,1
    58ea:	00002097          	auipc	ra,0x2
    58ee:	fbe080e7          	jalr	-66(ra) # 78a8 <exit>
  }
  if ((n = write(fd, a, PGSIZE)) < 0) {
    58f2:	fe442783          	lw	a5,-28(s0)
    58f6:	6605                	lui	a2,0x1
    58f8:	fe843583          	ld	a1,-24(s0)
    58fc:	853e                	mv	a0,a5
    58fe:	00002097          	auipc	ra,0x2
    5902:	fca080e7          	jalr	-54(ra) # 78c8 <write>
    5906:	87aa                	mv	a5,a0
    5908:	fef42023          	sw	a5,-32(s0)
    590c:	fe042783          	lw	a5,-32(s0)
    5910:	2781                	sext.w	a5,a5
    5912:	0207d163          	bgez	a5,5934 <sbrkarg+0xae>
    printf("%s: write sbrk failed\n", s);
    5916:	fd843583          	ld	a1,-40(s0)
    591a:	00004517          	auipc	a0,0x4
    591e:	4d650513          	addi	a0,a0,1238 # 9df0 <malloc+0x1e0e>
    5922:	00002097          	auipc	ra,0x2
    5926:	4ce080e7          	jalr	1230(ra) # 7df0 <printf>
    exit(1);
    592a:	4505                	li	a0,1
    592c:	00002097          	auipc	ra,0x2
    5930:	f7c080e7          	jalr	-132(ra) # 78a8 <exit>
  }
  close(fd);
    5934:	fe442783          	lw	a5,-28(s0)
    5938:	853e                	mv	a0,a5
    593a:	00002097          	auipc	ra,0x2
    593e:	f96080e7          	jalr	-106(ra) # 78d0 <close>

  // test writes to allocated memory
  a = sbrk(PGSIZE);
    5942:	6505                	lui	a0,0x1
    5944:	00002097          	auipc	ra,0x2
    5948:	fec080e7          	jalr	-20(ra) # 7930 <sbrk>
    594c:	fea43423          	sd	a0,-24(s0)
  if(pipe((int *) a) != 0){
    5950:	fe843503          	ld	a0,-24(s0)
    5954:	00002097          	auipc	ra,0x2
    5958:	f64080e7          	jalr	-156(ra) # 78b8 <pipe>
    595c:	87aa                	mv	a5,a0
    595e:	c385                	beqz	a5,597e <sbrkarg+0xf8>
    printf("%s: pipe() failed\n", s);
    5960:	fd843583          	ld	a1,-40(s0)
    5964:	00003517          	auipc	a0,0x3
    5968:	09450513          	addi	a0,a0,148 # 89f8 <malloc+0xa16>
    596c:	00002097          	auipc	ra,0x2
    5970:	484080e7          	jalr	1156(ra) # 7df0 <printf>
    exit(1);
    5974:	4505                	li	a0,1
    5976:	00002097          	auipc	ra,0x2
    597a:	f32080e7          	jalr	-206(ra) # 78a8 <exit>
  } 
}
    597e:	0001                	nop
    5980:	70a2                	ld	ra,40(sp)
    5982:	7402                	ld	s0,32(sp)
    5984:	6145                	addi	sp,sp,48
    5986:	8082                	ret

0000000000005988 <validatetest>:

void
validatetest(char *s)
{
    5988:	7179                	addi	sp,sp,-48
    598a:	f406                	sd	ra,40(sp)
    598c:	f022                	sd	s0,32(sp)
    598e:	1800                	addi	s0,sp,48
    5990:	fca43c23          	sd	a0,-40(s0)
  int hi;
  uint64 p;

  hi = 1100*1024;
    5994:	001137b7          	lui	a5,0x113
    5998:	fef42223          	sw	a5,-28(s0)
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    599c:	fe043423          	sd	zero,-24(s0)
    59a0:	a0b1                	j	59ec <validatetest+0x64>
    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    59a2:	fe843783          	ld	a5,-24(s0)
    59a6:	85be                	mv	a1,a5
    59a8:	00004517          	auipc	a0,0x4
    59ac:	46050513          	addi	a0,a0,1120 # 9e08 <malloc+0x1e26>
    59b0:	00002097          	auipc	ra,0x2
    59b4:	f58080e7          	jalr	-168(ra) # 7908 <link>
    59b8:	87aa                	mv	a5,a0
    59ba:	873e                	mv	a4,a5
    59bc:	57fd                	li	a5,-1
    59be:	02f70163          	beq	a4,a5,59e0 <validatetest+0x58>
      printf("%s: link should not succeed\n", s);
    59c2:	fd843583          	ld	a1,-40(s0)
    59c6:	00004517          	auipc	a0,0x4
    59ca:	45250513          	addi	a0,a0,1106 # 9e18 <malloc+0x1e36>
    59ce:	00002097          	auipc	ra,0x2
    59d2:	422080e7          	jalr	1058(ra) # 7df0 <printf>
      exit(1);
    59d6:	4505                	li	a0,1
    59d8:	00002097          	auipc	ra,0x2
    59dc:	ed0080e7          	jalr	-304(ra) # 78a8 <exit>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    59e0:	fe843703          	ld	a4,-24(s0)
    59e4:	6785                	lui	a5,0x1
    59e6:	97ba                	add	a5,a5,a4
    59e8:	fef43423          	sd	a5,-24(s0)
    59ec:	fe442783          	lw	a5,-28(s0)
    59f0:	1782                	slli	a5,a5,0x20
    59f2:	9381                	srli	a5,a5,0x20
    59f4:	fe843703          	ld	a4,-24(s0)
    59f8:	fae7f5e3          	bgeu	a5,a4,59a2 <validatetest+0x1a>
    }
  }
}
    59fc:	0001                	nop
    59fe:	0001                	nop
    5a00:	70a2                	ld	ra,40(sp)
    5a02:	7402                	ld	s0,32(sp)
    5a04:	6145                	addi	sp,sp,48
    5a06:	8082                	ret

0000000000005a08 <bsstest>:

// does uninitialized data start out zero?
char uninit[10000];
void
bsstest(char *s)
{
    5a08:	7179                	addi	sp,sp,-48
    5a0a:	f406                	sd	ra,40(sp)
    5a0c:	f022                	sd	s0,32(sp)
    5a0e:	1800                	addi	s0,sp,48
    5a10:	fca43c23          	sd	a0,-40(s0)
  int i;

  for(i = 0; i < sizeof(uninit); i++){
    5a14:	fe042623          	sw	zero,-20(s0)
    5a18:	a83d                	j	5a56 <bsstest+0x4e>
    if(uninit[i] != '\0'){
    5a1a:	00009717          	auipc	a4,0x9
    5a1e:	a5670713          	addi	a4,a4,-1450 # e470 <uninit>
    5a22:	fec42783          	lw	a5,-20(s0)
    5a26:	97ba                	add	a5,a5,a4
    5a28:	0007c783          	lbu	a5,0(a5) # 1000 <truncate3+0x1b2>
    5a2c:	c385                	beqz	a5,5a4c <bsstest+0x44>
      printf("%s: bss test failed\n", s);
    5a2e:	fd843583          	ld	a1,-40(s0)
    5a32:	00004517          	auipc	a0,0x4
    5a36:	40650513          	addi	a0,a0,1030 # 9e38 <malloc+0x1e56>
    5a3a:	00002097          	auipc	ra,0x2
    5a3e:	3b6080e7          	jalr	950(ra) # 7df0 <printf>
      exit(1);
    5a42:	4505                	li	a0,1
    5a44:	00002097          	auipc	ra,0x2
    5a48:	e64080e7          	jalr	-412(ra) # 78a8 <exit>
  for(i = 0; i < sizeof(uninit); i++){
    5a4c:	fec42783          	lw	a5,-20(s0)
    5a50:	2785                	addiw	a5,a5,1
    5a52:	fef42623          	sw	a5,-20(s0)
    5a56:	fec42783          	lw	a5,-20(s0)
    5a5a:	873e                	mv	a4,a5
    5a5c:	6789                	lui	a5,0x2
    5a5e:	70f78793          	addi	a5,a5,1807 # 270f <reparent2+0x7f>
    5a62:	fae7fce3          	bgeu	a5,a4,5a1a <bsstest+0x12>
    }
  }
}
    5a66:	0001                	nop
    5a68:	0001                	nop
    5a6a:	70a2                	ld	ra,40(sp)
    5a6c:	7402                	ld	s0,32(sp)
    5a6e:	6145                	addi	sp,sp,48
    5a70:	8082                	ret

0000000000005a72 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(char *s)
{
    5a72:	7179                	addi	sp,sp,-48
    5a74:	f406                	sd	ra,40(sp)
    5a76:	f022                	sd	s0,32(sp)
    5a78:	1800                	addi	s0,sp,48
    5a7a:	fca43c23          	sd	a0,-40(s0)
  int pid, fd, xstatus;

  unlink("bigarg-ok");
    5a7e:	00004517          	auipc	a0,0x4
    5a82:	3d250513          	addi	a0,a0,978 # 9e50 <malloc+0x1e6e>
    5a86:	00002097          	auipc	ra,0x2
    5a8a:	e72080e7          	jalr	-398(ra) # 78f8 <unlink>
  pid = fork();
    5a8e:	00002097          	auipc	ra,0x2
    5a92:	e12080e7          	jalr	-494(ra) # 78a0 <fork>
    5a96:	87aa                	mv	a5,a0
    5a98:	fef42423          	sw	a5,-24(s0)
  if(pid == 0){
    5a9c:	fe842783          	lw	a5,-24(s0)
    5aa0:	2781                	sext.w	a5,a5
    5aa2:	ebc1                	bnez	a5,5b32 <bigargtest+0xc0>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    5aa4:	fe042623          	sw	zero,-20(s0)
    5aa8:	a01d                	j	5ace <bigargtest+0x5c>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    5aaa:	0000c717          	auipc	a4,0xc
    5aae:	0de70713          	addi	a4,a4,222 # 11b88 <args.1>
    5ab2:	fec42783          	lw	a5,-20(s0)
    5ab6:	078e                	slli	a5,a5,0x3
    5ab8:	97ba                	add	a5,a5,a4
    5aba:	00004717          	auipc	a4,0x4
    5abe:	3a670713          	addi	a4,a4,934 # 9e60 <malloc+0x1e7e>
    5ac2:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    5ac4:	fec42783          	lw	a5,-20(s0)
    5ac8:	2785                	addiw	a5,a5,1
    5aca:	fef42623          	sw	a5,-20(s0)
    5ace:	fec42783          	lw	a5,-20(s0)
    5ad2:	0007871b          	sext.w	a4,a5
    5ad6:	47f9                	li	a5,30
    5ad8:	fce7d9e3          	bge	a5,a4,5aaa <bigargtest+0x38>
    args[MAXARG-1] = 0;
    5adc:	0000c797          	auipc	a5,0xc
    5ae0:	0ac78793          	addi	a5,a5,172 # 11b88 <args.1>
    5ae4:	0e07bc23          	sd	zero,248(a5)
    exec("echo", args);
    5ae8:	0000c597          	auipc	a1,0xc
    5aec:	0a058593          	addi	a1,a1,160 # 11b88 <args.1>
    5af0:	00003517          	auipc	a0,0x3
    5af4:	85050513          	addi	a0,a0,-1968 # 8340 <malloc+0x35e>
    5af8:	00002097          	auipc	ra,0x2
    5afc:	de8080e7          	jalr	-536(ra) # 78e0 <exec>
    fd = open("bigarg-ok", O_CREATE);
    5b00:	20000593          	li	a1,512
    5b04:	00004517          	auipc	a0,0x4
    5b08:	34c50513          	addi	a0,a0,844 # 9e50 <malloc+0x1e6e>
    5b0c:	00002097          	auipc	ra,0x2
    5b10:	ddc080e7          	jalr	-548(ra) # 78e8 <open>
    5b14:	87aa                	mv	a5,a0
    5b16:	fef42223          	sw	a5,-28(s0)
    close(fd);
    5b1a:	fe442783          	lw	a5,-28(s0)
    5b1e:	853e                	mv	a0,a5
    5b20:	00002097          	auipc	ra,0x2
    5b24:	db0080e7          	jalr	-592(ra) # 78d0 <close>
    exit(0);
    5b28:	4501                	li	a0,0
    5b2a:	00002097          	auipc	ra,0x2
    5b2e:	d7e080e7          	jalr	-642(ra) # 78a8 <exit>
  } else if(pid < 0){
    5b32:	fe842783          	lw	a5,-24(s0)
    5b36:	2781                	sext.w	a5,a5
    5b38:	0207d163          	bgez	a5,5b5a <bigargtest+0xe8>
    printf("%s: bigargtest: fork failed\n", s);
    5b3c:	fd843583          	ld	a1,-40(s0)
    5b40:	00004517          	auipc	a0,0x4
    5b44:	40050513          	addi	a0,a0,1024 # 9f40 <malloc+0x1f5e>
    5b48:	00002097          	auipc	ra,0x2
    5b4c:	2a8080e7          	jalr	680(ra) # 7df0 <printf>
    exit(1);
    5b50:	4505                	li	a0,1
    5b52:	00002097          	auipc	ra,0x2
    5b56:	d56080e7          	jalr	-682(ra) # 78a8 <exit>
  }
  
  wait(&xstatus);
    5b5a:	fe040793          	addi	a5,s0,-32
    5b5e:	853e                	mv	a0,a5
    5b60:	00002097          	auipc	ra,0x2
    5b64:	d50080e7          	jalr	-688(ra) # 78b0 <wait>
  if(xstatus != 0)
    5b68:	fe042783          	lw	a5,-32(s0)
    5b6c:	cb81                	beqz	a5,5b7c <bigargtest+0x10a>
    exit(xstatus);
    5b6e:	fe042783          	lw	a5,-32(s0)
    5b72:	853e                	mv	a0,a5
    5b74:	00002097          	auipc	ra,0x2
    5b78:	d34080e7          	jalr	-716(ra) # 78a8 <exit>
  fd = open("bigarg-ok", 0);
    5b7c:	4581                	li	a1,0
    5b7e:	00004517          	auipc	a0,0x4
    5b82:	2d250513          	addi	a0,a0,722 # 9e50 <malloc+0x1e6e>
    5b86:	00002097          	auipc	ra,0x2
    5b8a:	d62080e7          	jalr	-670(ra) # 78e8 <open>
    5b8e:	87aa                	mv	a5,a0
    5b90:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
    5b94:	fe442783          	lw	a5,-28(s0)
    5b98:	2781                	sext.w	a5,a5
    5b9a:	0207d163          	bgez	a5,5bbc <bigargtest+0x14a>
    printf("%s: bigarg test failed!\n", s);
    5b9e:	fd843583          	ld	a1,-40(s0)
    5ba2:	00004517          	auipc	a0,0x4
    5ba6:	3be50513          	addi	a0,a0,958 # 9f60 <malloc+0x1f7e>
    5baa:	00002097          	auipc	ra,0x2
    5bae:	246080e7          	jalr	582(ra) # 7df0 <printf>
    exit(1);
    5bb2:	4505                	li	a0,1
    5bb4:	00002097          	auipc	ra,0x2
    5bb8:	cf4080e7          	jalr	-780(ra) # 78a8 <exit>
  }
  close(fd);
    5bbc:	fe442783          	lw	a5,-28(s0)
    5bc0:	853e                	mv	a0,a5
    5bc2:	00002097          	auipc	ra,0x2
    5bc6:	d0e080e7          	jalr	-754(ra) # 78d0 <close>
}
    5bca:	0001                	nop
    5bcc:	70a2                	ld	ra,40(sp)
    5bce:	7402                	ld	s0,32(sp)
    5bd0:	6145                	addi	sp,sp,48
    5bd2:	8082                	ret

0000000000005bd4 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    5bd4:	7159                	addi	sp,sp,-112
    5bd6:	f486                	sd	ra,104(sp)
    5bd8:	f0a2                	sd	s0,96(sp)
    5bda:	1880                	addi	s0,sp,112
  int nfiles;
  int fsblocks = 0;
    5bdc:	fe042423          	sw	zero,-24(s0)

  printf("fsfull test\n");
    5be0:	00004517          	auipc	a0,0x4
    5be4:	3a050513          	addi	a0,a0,928 # 9f80 <malloc+0x1f9e>
    5be8:	00002097          	auipc	ra,0x2
    5bec:	208080e7          	jalr	520(ra) # 7df0 <printf>

  for(nfiles = 0; ; nfiles++){
    5bf0:	fe042623          	sw	zero,-20(s0)
    char name[64];
    name[0] = 'f';
    5bf4:	06600793          	li	a5,102
    5bf8:	f8f40c23          	sb	a5,-104(s0)
    name[1] = '0' + nfiles / 1000;
    5bfc:	fec42783          	lw	a5,-20(s0)
    5c00:	873e                	mv	a4,a5
    5c02:	3e800793          	li	a5,1000
    5c06:	02f747bb          	divw	a5,a4,a5
    5c0a:	2781                	sext.w	a5,a5
    5c0c:	0ff7f793          	zext.b	a5,a5
    5c10:	0307879b          	addiw	a5,a5,48
    5c14:	0ff7f793          	zext.b	a5,a5
    5c18:	f8f40ca3          	sb	a5,-103(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5c1c:	fec42783          	lw	a5,-20(s0)
    5c20:	873e                	mv	a4,a5
    5c22:	3e800793          	li	a5,1000
    5c26:	02f767bb          	remw	a5,a4,a5
    5c2a:	2781                	sext.w	a5,a5
    5c2c:	873e                	mv	a4,a5
    5c2e:	06400793          	li	a5,100
    5c32:	02f747bb          	divw	a5,a4,a5
    5c36:	2781                	sext.w	a5,a5
    5c38:	0ff7f793          	zext.b	a5,a5
    5c3c:	0307879b          	addiw	a5,a5,48
    5c40:	0ff7f793          	zext.b	a5,a5
    5c44:	f8f40d23          	sb	a5,-102(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5c48:	fec42783          	lw	a5,-20(s0)
    5c4c:	873e                	mv	a4,a5
    5c4e:	06400793          	li	a5,100
    5c52:	02f767bb          	remw	a5,a4,a5
    5c56:	2781                	sext.w	a5,a5
    5c58:	873e                	mv	a4,a5
    5c5a:	47a9                	li	a5,10
    5c5c:	02f747bb          	divw	a5,a4,a5
    5c60:	2781                	sext.w	a5,a5
    5c62:	0ff7f793          	zext.b	a5,a5
    5c66:	0307879b          	addiw	a5,a5,48
    5c6a:	0ff7f793          	zext.b	a5,a5
    5c6e:	f8f40da3          	sb	a5,-101(s0)
    name[4] = '0' + (nfiles % 10);
    5c72:	fec42783          	lw	a5,-20(s0)
    5c76:	873e                	mv	a4,a5
    5c78:	47a9                	li	a5,10
    5c7a:	02f767bb          	remw	a5,a4,a5
    5c7e:	2781                	sext.w	a5,a5
    5c80:	0ff7f793          	zext.b	a5,a5
    5c84:	0307879b          	addiw	a5,a5,48
    5c88:	0ff7f793          	zext.b	a5,a5
    5c8c:	f8f40e23          	sb	a5,-100(s0)
    name[5] = '\0';
    5c90:	f8040ea3          	sb	zero,-99(s0)
    printf("writing %s\n", name);
    5c94:	f9840793          	addi	a5,s0,-104
    5c98:	85be                	mv	a1,a5
    5c9a:	00004517          	auipc	a0,0x4
    5c9e:	2f650513          	addi	a0,a0,758 # 9f90 <malloc+0x1fae>
    5ca2:	00002097          	auipc	ra,0x2
    5ca6:	14e080e7          	jalr	334(ra) # 7df0 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    5caa:	f9840793          	addi	a5,s0,-104
    5cae:	20200593          	li	a1,514
    5cb2:	853e                	mv	a0,a5
    5cb4:	00002097          	auipc	ra,0x2
    5cb8:	c34080e7          	jalr	-972(ra) # 78e8 <open>
    5cbc:	87aa                	mv	a5,a0
    5cbe:	fef42023          	sw	a5,-32(s0)
    if(fd < 0){
    5cc2:	fe042783          	lw	a5,-32(s0)
    5cc6:	2781                	sext.w	a5,a5
    5cc8:	0007de63          	bgez	a5,5ce4 <fsfull+0x110>
      printf("open %s failed\n", name);
    5ccc:	f9840793          	addi	a5,s0,-104
    5cd0:	85be                	mv	a1,a5
    5cd2:	00004517          	auipc	a0,0x4
    5cd6:	2ce50513          	addi	a0,a0,718 # 9fa0 <malloc+0x1fbe>
    5cda:	00002097          	auipc	ra,0x2
    5cde:	116080e7          	jalr	278(ra) # 7df0 <printf>
      break;
    5ce2:	a079                	j	5d70 <fsfull+0x19c>
    }
    int total = 0;
    5ce4:	fe042223          	sw	zero,-28(s0)
    while(1){
      int cc = write(fd, buf, BSIZE);
    5ce8:	fe042783          	lw	a5,-32(s0)
    5cec:	40000613          	li	a2,1024
    5cf0:	00005597          	auipc	a1,0x5
    5cf4:	78058593          	addi	a1,a1,1920 # b470 <buf>
    5cf8:	853e                	mv	a0,a5
    5cfa:	00002097          	auipc	ra,0x2
    5cfe:	bce080e7          	jalr	-1074(ra) # 78c8 <write>
    5d02:	87aa                	mv	a5,a0
    5d04:	fcf42e23          	sw	a5,-36(s0)
      if(cc < BSIZE)
    5d08:	fdc42783          	lw	a5,-36(s0)
    5d0c:	0007871b          	sext.w	a4,a5
    5d10:	3ff00793          	li	a5,1023
    5d14:	02e7d063          	bge	a5,a4,5d34 <fsfull+0x160>
        break;
      total += cc;
    5d18:	fe442783          	lw	a5,-28(s0)
    5d1c:	873e                	mv	a4,a5
    5d1e:	fdc42783          	lw	a5,-36(s0)
    5d22:	9fb9                	addw	a5,a5,a4
    5d24:	fef42223          	sw	a5,-28(s0)
      fsblocks++;
    5d28:	fe842783          	lw	a5,-24(s0)
    5d2c:	2785                	addiw	a5,a5,1
    5d2e:	fef42423          	sw	a5,-24(s0)
    while(1){
    5d32:	bf5d                	j	5ce8 <fsfull+0x114>
        break;
    5d34:	0001                	nop
    }
    printf("wrote %d bytes\n", total);
    5d36:	fe442783          	lw	a5,-28(s0)
    5d3a:	85be                	mv	a1,a5
    5d3c:	00004517          	auipc	a0,0x4
    5d40:	27450513          	addi	a0,a0,628 # 9fb0 <malloc+0x1fce>
    5d44:	00002097          	auipc	ra,0x2
    5d48:	0ac080e7          	jalr	172(ra) # 7df0 <printf>
    close(fd);
    5d4c:	fe042783          	lw	a5,-32(s0)
    5d50:	853e                	mv	a0,a5
    5d52:	00002097          	auipc	ra,0x2
    5d56:	b7e080e7          	jalr	-1154(ra) # 78d0 <close>
    if(total == 0)
    5d5a:	fe442783          	lw	a5,-28(s0)
    5d5e:	2781                	sext.w	a5,a5
    5d60:	c799                	beqz	a5,5d6e <fsfull+0x19a>
  for(nfiles = 0; ; nfiles++){
    5d62:	fec42783          	lw	a5,-20(s0)
    5d66:	2785                	addiw	a5,a5,1
    5d68:	fef42623          	sw	a5,-20(s0)
    5d6c:	b561                	j	5bf4 <fsfull+0x20>
      break;
    5d6e:	0001                	nop
  }

  while(nfiles >= 0){
    5d70:	a86d                	j	5e2a <fsfull+0x256>
    char name[64];
    name[0] = 'f';
    5d72:	06600793          	li	a5,102
    5d76:	f8f40c23          	sb	a5,-104(s0)
    name[1] = '0' + nfiles / 1000;
    5d7a:	fec42783          	lw	a5,-20(s0)
    5d7e:	873e                	mv	a4,a5
    5d80:	3e800793          	li	a5,1000
    5d84:	02f747bb          	divw	a5,a4,a5
    5d88:	2781                	sext.w	a5,a5
    5d8a:	0ff7f793          	zext.b	a5,a5
    5d8e:	0307879b          	addiw	a5,a5,48
    5d92:	0ff7f793          	zext.b	a5,a5
    5d96:	f8f40ca3          	sb	a5,-103(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5d9a:	fec42783          	lw	a5,-20(s0)
    5d9e:	873e                	mv	a4,a5
    5da0:	3e800793          	li	a5,1000
    5da4:	02f767bb          	remw	a5,a4,a5
    5da8:	2781                	sext.w	a5,a5
    5daa:	873e                	mv	a4,a5
    5dac:	06400793          	li	a5,100
    5db0:	02f747bb          	divw	a5,a4,a5
    5db4:	2781                	sext.w	a5,a5
    5db6:	0ff7f793          	zext.b	a5,a5
    5dba:	0307879b          	addiw	a5,a5,48
    5dbe:	0ff7f793          	zext.b	a5,a5
    5dc2:	f8f40d23          	sb	a5,-102(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5dc6:	fec42783          	lw	a5,-20(s0)
    5dca:	873e                	mv	a4,a5
    5dcc:	06400793          	li	a5,100
    5dd0:	02f767bb          	remw	a5,a4,a5
    5dd4:	2781                	sext.w	a5,a5
    5dd6:	873e                	mv	a4,a5
    5dd8:	47a9                	li	a5,10
    5dda:	02f747bb          	divw	a5,a4,a5
    5dde:	2781                	sext.w	a5,a5
    5de0:	0ff7f793          	zext.b	a5,a5
    5de4:	0307879b          	addiw	a5,a5,48
    5de8:	0ff7f793          	zext.b	a5,a5
    5dec:	f8f40da3          	sb	a5,-101(s0)
    name[4] = '0' + (nfiles % 10);
    5df0:	fec42783          	lw	a5,-20(s0)
    5df4:	873e                	mv	a4,a5
    5df6:	47a9                	li	a5,10
    5df8:	02f767bb          	remw	a5,a4,a5
    5dfc:	2781                	sext.w	a5,a5
    5dfe:	0ff7f793          	zext.b	a5,a5
    5e02:	0307879b          	addiw	a5,a5,48
    5e06:	0ff7f793          	zext.b	a5,a5
    5e0a:	f8f40e23          	sb	a5,-100(s0)
    name[5] = '\0';
    5e0e:	f8040ea3          	sb	zero,-99(s0)
    unlink(name);
    5e12:	f9840793          	addi	a5,s0,-104
    5e16:	853e                	mv	a0,a5
    5e18:	00002097          	auipc	ra,0x2
    5e1c:	ae0080e7          	jalr	-1312(ra) # 78f8 <unlink>
    nfiles--;
    5e20:	fec42783          	lw	a5,-20(s0)
    5e24:	37fd                	addiw	a5,a5,-1
    5e26:	fef42623          	sw	a5,-20(s0)
  while(nfiles >= 0){
    5e2a:	fec42783          	lw	a5,-20(s0)
    5e2e:	2781                	sext.w	a5,a5
    5e30:	f407d1e3          	bgez	a5,5d72 <fsfull+0x19e>
  }

  printf("fsfull test finished\n");
    5e34:	00004517          	auipc	a0,0x4
    5e38:	18c50513          	addi	a0,a0,396 # 9fc0 <malloc+0x1fde>
    5e3c:	00002097          	auipc	ra,0x2
    5e40:	fb4080e7          	jalr	-76(ra) # 7df0 <printf>
}
    5e44:	0001                	nop
    5e46:	70a6                	ld	ra,104(sp)
    5e48:	7406                	ld	s0,96(sp)
    5e4a:	6165                	addi	sp,sp,112
    5e4c:	8082                	ret

0000000000005e4e <argptest>:

void argptest(char *s)
{
    5e4e:	7179                	addi	sp,sp,-48
    5e50:	f406                	sd	ra,40(sp)
    5e52:	f022                	sd	s0,32(sp)
    5e54:	1800                	addi	s0,sp,48
    5e56:	fca43c23          	sd	a0,-40(s0)
  int fd;
  fd = open("init", O_RDONLY);
    5e5a:	4581                	li	a1,0
    5e5c:	00004517          	auipc	a0,0x4
    5e60:	17c50513          	addi	a0,a0,380 # 9fd8 <malloc+0x1ff6>
    5e64:	00002097          	auipc	ra,0x2
    5e68:	a84080e7          	jalr	-1404(ra) # 78e8 <open>
    5e6c:	87aa                	mv	a5,a0
    5e6e:	fef42623          	sw	a5,-20(s0)
  if (fd < 0) {
    5e72:	fec42783          	lw	a5,-20(s0)
    5e76:	2781                	sext.w	a5,a5
    5e78:	0207d163          	bgez	a5,5e9a <argptest+0x4c>
    printf("%s: open failed\n", s);
    5e7c:	fd843583          	ld	a1,-40(s0)
    5e80:	00002517          	auipc	a0,0x2
    5e84:	6f850513          	addi	a0,a0,1784 # 8578 <malloc+0x596>
    5e88:	00002097          	auipc	ra,0x2
    5e8c:	f68080e7          	jalr	-152(ra) # 7df0 <printf>
    exit(1);
    5e90:	4505                	li	a0,1
    5e92:	00002097          	auipc	ra,0x2
    5e96:	a16080e7          	jalr	-1514(ra) # 78a8 <exit>
  }
  read(fd, sbrk(0) - 1, -1);
    5e9a:	4501                	li	a0,0
    5e9c:	00002097          	auipc	ra,0x2
    5ea0:	a94080e7          	jalr	-1388(ra) # 7930 <sbrk>
    5ea4:	87aa                	mv	a5,a0
    5ea6:	fff78713          	addi	a4,a5,-1
    5eaa:	fec42783          	lw	a5,-20(s0)
    5eae:	567d                	li	a2,-1
    5eb0:	85ba                	mv	a1,a4
    5eb2:	853e                	mv	a0,a5
    5eb4:	00002097          	auipc	ra,0x2
    5eb8:	a0c080e7          	jalr	-1524(ra) # 78c0 <read>
  close(fd);
    5ebc:	fec42783          	lw	a5,-20(s0)
    5ec0:	853e                	mv	a0,a5
    5ec2:	00002097          	auipc	ra,0x2
    5ec6:	a0e080e7          	jalr	-1522(ra) # 78d0 <close>
}
    5eca:	0001                	nop
    5ecc:	70a2                	ld	ra,40(sp)
    5ece:	7402                	ld	s0,32(sp)
    5ed0:	6145                	addi	sp,sp,48
    5ed2:	8082                	ret

0000000000005ed4 <stacktest>:

// check that there's an invalid page beneath
// the user stack, to catch stack overflow.
void
stacktest(char *s)
{
    5ed4:	7139                	addi	sp,sp,-64
    5ed6:	fc06                	sd	ra,56(sp)
    5ed8:	f822                	sd	s0,48(sp)
    5eda:	0080                	addi	s0,sp,64
    5edc:	fca43423          	sd	a0,-56(s0)
  int pid;
  int xstatus;
  
  pid = fork();
    5ee0:	00002097          	auipc	ra,0x2
    5ee4:	9c0080e7          	jalr	-1600(ra) # 78a0 <fork>
    5ee8:	87aa                	mv	a5,a0
    5eea:	fef42623          	sw	a5,-20(s0)
  if(pid == 0) {
    5eee:	fec42783          	lw	a5,-20(s0)
    5ef2:	2781                	sext.w	a5,a5
    5ef4:	e3b9                	bnez	a5,5f3a <stacktest+0x66>
    char *sp = (char *) r_sp();
    5ef6:	ffffa097          	auipc	ra,0xffffa
    5efa:	10a080e7          	jalr	266(ra) # 0 <r_sp>
    5efe:	87aa                	mv	a5,a0
    5f00:	fef43023          	sd	a5,-32(s0)
    sp -= PGSIZE;
    5f04:	fe043703          	ld	a4,-32(s0)
    5f08:	77fd                	lui	a5,0xfffff
    5f0a:	97ba                	add	a5,a5,a4
    5f0c:	fef43023          	sd	a5,-32(s0)
    // the *sp should cause a trap.
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    5f10:	fe043783          	ld	a5,-32(s0)
    5f14:	0007c783          	lbu	a5,0(a5) # fffffffffffff000 <freep+0xfffffffffffed368>
    5f18:	2781                	sext.w	a5,a5
    5f1a:	863e                	mv	a2,a5
    5f1c:	fc843583          	ld	a1,-56(s0)
    5f20:	00004517          	auipc	a0,0x4
    5f24:	0c050513          	addi	a0,a0,192 # 9fe0 <malloc+0x1ffe>
    5f28:	00002097          	auipc	ra,0x2
    5f2c:	ec8080e7          	jalr	-312(ra) # 7df0 <printf>
    exit(1);
    5f30:	4505                	li	a0,1
    5f32:	00002097          	auipc	ra,0x2
    5f36:	976080e7          	jalr	-1674(ra) # 78a8 <exit>
  } else if(pid < 0){
    5f3a:	fec42783          	lw	a5,-20(s0)
    5f3e:	2781                	sext.w	a5,a5
    5f40:	0207d163          	bgez	a5,5f62 <stacktest+0x8e>
    printf("%s: fork failed\n", s);
    5f44:	fc843583          	ld	a1,-56(s0)
    5f48:	00002517          	auipc	a0,0x2
    5f4c:	61850513          	addi	a0,a0,1560 # 8560 <malloc+0x57e>
    5f50:	00002097          	auipc	ra,0x2
    5f54:	ea0080e7          	jalr	-352(ra) # 7df0 <printf>
    exit(1);
    5f58:	4505                	li	a0,1
    5f5a:	00002097          	auipc	ra,0x2
    5f5e:	94e080e7          	jalr	-1714(ra) # 78a8 <exit>
  }
  wait(&xstatus);
    5f62:	fdc40793          	addi	a5,s0,-36
    5f66:	853e                	mv	a0,a5
    5f68:	00002097          	auipc	ra,0x2
    5f6c:	948080e7          	jalr	-1720(ra) # 78b0 <wait>
  if(xstatus == -1)  // kernel killed child?
    5f70:	fdc42783          	lw	a5,-36(s0)
    5f74:	873e                	mv	a4,a5
    5f76:	57fd                	li	a5,-1
    5f78:	00f71763          	bne	a4,a5,5f86 <stacktest+0xb2>
    exit(0);
    5f7c:	4501                	li	a0,0
    5f7e:	00002097          	auipc	ra,0x2
    5f82:	92a080e7          	jalr	-1750(ra) # 78a8 <exit>
  else
    exit(xstatus);
    5f86:	fdc42783          	lw	a5,-36(s0)
    5f8a:	853e                	mv	a0,a5
    5f8c:	00002097          	auipc	ra,0x2
    5f90:	91c080e7          	jalr	-1764(ra) # 78a8 <exit>

0000000000005f94 <textwrite>:
}

// check that writes to text segment fault
void
textwrite(char *s)
{
    5f94:	7139                	addi	sp,sp,-64
    5f96:	fc06                	sd	ra,56(sp)
    5f98:	f822                	sd	s0,48(sp)
    5f9a:	0080                	addi	s0,sp,64
    5f9c:	fca43423          	sd	a0,-56(s0)
  int pid;
  int xstatus;
  
  pid = fork();
    5fa0:	00002097          	auipc	ra,0x2
    5fa4:	900080e7          	jalr	-1792(ra) # 78a0 <fork>
    5fa8:	87aa                	mv	a5,a0
    5faa:	fef42623          	sw	a5,-20(s0)
  if(pid == 0) {
    5fae:	fec42783          	lw	a5,-20(s0)
    5fb2:	2781                	sext.w	a5,a5
    5fb4:	ef81                	bnez	a5,5fcc <textwrite+0x38>
    volatile int *addr = (int *) 0;
    5fb6:	fe043023          	sd	zero,-32(s0)
    *addr = 10;
    5fba:	fe043783          	ld	a5,-32(s0)
    5fbe:	4729                	li	a4,10
    5fc0:	c398                	sw	a4,0(a5)
    exit(1);
    5fc2:	4505                	li	a0,1
    5fc4:	00002097          	auipc	ra,0x2
    5fc8:	8e4080e7          	jalr	-1820(ra) # 78a8 <exit>
  } else if(pid < 0){
    5fcc:	fec42783          	lw	a5,-20(s0)
    5fd0:	2781                	sext.w	a5,a5
    5fd2:	0207d163          	bgez	a5,5ff4 <textwrite+0x60>
    printf("%s: fork failed\n", s);
    5fd6:	fc843583          	ld	a1,-56(s0)
    5fda:	00002517          	auipc	a0,0x2
    5fde:	58650513          	addi	a0,a0,1414 # 8560 <malloc+0x57e>
    5fe2:	00002097          	auipc	ra,0x2
    5fe6:	e0e080e7          	jalr	-498(ra) # 7df0 <printf>
    exit(1);
    5fea:	4505                	li	a0,1
    5fec:	00002097          	auipc	ra,0x2
    5ff0:	8bc080e7          	jalr	-1860(ra) # 78a8 <exit>
  }
  wait(&xstatus);
    5ff4:	fdc40793          	addi	a5,s0,-36
    5ff8:	853e                	mv	a0,a5
    5ffa:	00002097          	auipc	ra,0x2
    5ffe:	8b6080e7          	jalr	-1866(ra) # 78b0 <wait>
  if(xstatus == -1)  // kernel killed child?
    6002:	fdc42783          	lw	a5,-36(s0)
    6006:	873e                	mv	a4,a5
    6008:	57fd                	li	a5,-1
    600a:	00f71763          	bne	a4,a5,6018 <textwrite+0x84>
    exit(0);
    600e:	4501                	li	a0,0
    6010:	00002097          	auipc	ra,0x2
    6014:	898080e7          	jalr	-1896(ra) # 78a8 <exit>
  else
    exit(xstatus);
    6018:	fdc42783          	lw	a5,-36(s0)
    601c:	853e                	mv	a0,a5
    601e:	00002097          	auipc	ra,0x2
    6022:	88a080e7          	jalr	-1910(ra) # 78a8 <exit>

0000000000006026 <pgbug>:
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void *big = (void*) 0xeaeb0b5b00002f5e;
void
pgbug(char *s)
{
    6026:	7179                	addi	sp,sp,-48
    6028:	f406                	sd	ra,40(sp)
    602a:	f022                	sd	s0,32(sp)
    602c:	1800                	addi	s0,sp,48
    602e:	fca43c23          	sd	a0,-40(s0)
  char *argv[1];
  argv[0] = 0;
    6032:	fe043423          	sd	zero,-24(s0)
  exec(big, argv);
    6036:	00005797          	auipc	a5,0x5
    603a:	fca78793          	addi	a5,a5,-54 # b000 <big>
    603e:	639c                	ld	a5,0(a5)
    6040:	fe840713          	addi	a4,s0,-24
    6044:	85ba                	mv	a1,a4
    6046:	853e                	mv	a0,a5
    6048:	00002097          	auipc	ra,0x2
    604c:	898080e7          	jalr	-1896(ra) # 78e0 <exec>
  pipe(big);
    6050:	00005797          	auipc	a5,0x5
    6054:	fb078793          	addi	a5,a5,-80 # b000 <big>
    6058:	639c                	ld	a5,0(a5)
    605a:	853e                	mv	a0,a5
    605c:	00002097          	auipc	ra,0x2
    6060:	85c080e7          	jalr	-1956(ra) # 78b8 <pipe>

  exit(0);
    6064:	4501                	li	a0,0
    6066:	00002097          	auipc	ra,0x2
    606a:	842080e7          	jalr	-1982(ra) # 78a8 <exit>

000000000000606e <sbrkbugs>:
// regression test. does the kernel panic if a process sbrk()s its
// size to be less than a page, or zero, or reduces the break by an
// amount too small to cause a page to be freed?
void
sbrkbugs(char *s)
{
    606e:	7179                	addi	sp,sp,-48
    6070:	f406                	sd	ra,40(sp)
    6072:	f022                	sd	s0,32(sp)
    6074:	1800                	addi	s0,sp,48
    6076:	fca43c23          	sd	a0,-40(s0)
  int pid = fork();
    607a:	00002097          	auipc	ra,0x2
    607e:	826080e7          	jalr	-2010(ra) # 78a0 <fork>
    6082:	87aa                	mv	a5,a0
    6084:	fef42623          	sw	a5,-20(s0)
  if(pid < 0){
    6088:	fec42783          	lw	a5,-20(s0)
    608c:	2781                	sext.w	a5,a5
    608e:	0007df63          	bgez	a5,60ac <sbrkbugs+0x3e>
    printf("fork failed\n");
    6092:	00002517          	auipc	a0,0x2
    6096:	29e50513          	addi	a0,a0,670 # 8330 <malloc+0x34e>
    609a:	00002097          	auipc	ra,0x2
    609e:	d56080e7          	jalr	-682(ra) # 7df0 <printf>
    exit(1);
    60a2:	4505                	li	a0,1
    60a4:	00002097          	auipc	ra,0x2
    60a8:	804080e7          	jalr	-2044(ra) # 78a8 <exit>
  }
  if(pid == 0){
    60ac:	fec42783          	lw	a5,-20(s0)
    60b0:	2781                	sext.w	a5,a5
    60b2:	eb85                	bnez	a5,60e2 <sbrkbugs+0x74>
    int sz = (uint64) sbrk(0);
    60b4:	4501                	li	a0,0
    60b6:	00002097          	auipc	ra,0x2
    60ba:	87a080e7          	jalr	-1926(ra) # 7930 <sbrk>
    60be:	87aa                	mv	a5,a0
    60c0:	fef42223          	sw	a5,-28(s0)
    // free all user memory; there used to be a bug that
    // would not adjust p->sz correctly in this case,
    // causing exit() to panic.
    sbrk(-sz);
    60c4:	fe442783          	lw	a5,-28(s0)
    60c8:	40f007bb          	negw	a5,a5
    60cc:	2781                	sext.w	a5,a5
    60ce:	853e                	mv	a0,a5
    60d0:	00002097          	auipc	ra,0x2
    60d4:	860080e7          	jalr	-1952(ra) # 7930 <sbrk>
    // user page fault here.
    exit(0);
    60d8:	4501                	li	a0,0
    60da:	00001097          	auipc	ra,0x1
    60de:	7ce080e7          	jalr	1998(ra) # 78a8 <exit>
  }
  wait(0);
    60e2:	4501                	li	a0,0
    60e4:	00001097          	auipc	ra,0x1
    60e8:	7cc080e7          	jalr	1996(ra) # 78b0 <wait>

  pid = fork();
    60ec:	00001097          	auipc	ra,0x1
    60f0:	7b4080e7          	jalr	1972(ra) # 78a0 <fork>
    60f4:	87aa                	mv	a5,a0
    60f6:	fef42623          	sw	a5,-20(s0)
  if(pid < 0){
    60fa:	fec42783          	lw	a5,-20(s0)
    60fe:	2781                	sext.w	a5,a5
    6100:	0007df63          	bgez	a5,611e <sbrkbugs+0xb0>
    printf("fork failed\n");
    6104:	00002517          	auipc	a0,0x2
    6108:	22c50513          	addi	a0,a0,556 # 8330 <malloc+0x34e>
    610c:	00002097          	auipc	ra,0x2
    6110:	ce4080e7          	jalr	-796(ra) # 7df0 <printf>
    exit(1);
    6114:	4505                	li	a0,1
    6116:	00001097          	auipc	ra,0x1
    611a:	792080e7          	jalr	1938(ra) # 78a8 <exit>
  }
  if(pid == 0){
    611e:	fec42783          	lw	a5,-20(s0)
    6122:	2781                	sext.w	a5,a5
    6124:	eb95                	bnez	a5,6158 <sbrkbugs+0xea>
    int sz = (uint64) sbrk(0);
    6126:	4501                	li	a0,0
    6128:	00002097          	auipc	ra,0x2
    612c:	808080e7          	jalr	-2040(ra) # 7930 <sbrk>
    6130:	87aa                	mv	a5,a0
    6132:	fef42423          	sw	a5,-24(s0)
    // set the break to somewhere in the very first
    // page; there used to be a bug that would incorrectly
    // free the first page.
    sbrk(-(sz - 3500));
    6136:	6785                	lui	a5,0x1
    6138:	dac7879b          	addiw	a5,a5,-596 # dac <truncate2+0x4c>
    613c:	fe842703          	lw	a4,-24(s0)
    6140:	9f99                	subw	a5,a5,a4
    6142:	2781                	sext.w	a5,a5
    6144:	853e                	mv	a0,a5
    6146:	00001097          	auipc	ra,0x1
    614a:	7ea080e7          	jalr	2026(ra) # 7930 <sbrk>
    exit(0);
    614e:	4501                	li	a0,0
    6150:	00001097          	auipc	ra,0x1
    6154:	758080e7          	jalr	1880(ra) # 78a8 <exit>
  }
  wait(0);
    6158:	4501                	li	a0,0
    615a:	00001097          	auipc	ra,0x1
    615e:	756080e7          	jalr	1878(ra) # 78b0 <wait>

  pid = fork();
    6162:	00001097          	auipc	ra,0x1
    6166:	73e080e7          	jalr	1854(ra) # 78a0 <fork>
    616a:	87aa                	mv	a5,a0
    616c:	fef42623          	sw	a5,-20(s0)
  if(pid < 0){
    6170:	fec42783          	lw	a5,-20(s0)
    6174:	2781                	sext.w	a5,a5
    6176:	0007df63          	bgez	a5,6194 <sbrkbugs+0x126>
    printf("fork failed\n");
    617a:	00002517          	auipc	a0,0x2
    617e:	1b650513          	addi	a0,a0,438 # 8330 <malloc+0x34e>
    6182:	00002097          	auipc	ra,0x2
    6186:	c6e080e7          	jalr	-914(ra) # 7df0 <printf>
    exit(1);
    618a:	4505                	li	a0,1
    618c:	00001097          	auipc	ra,0x1
    6190:	71c080e7          	jalr	1820(ra) # 78a8 <exit>
  }
  if(pid == 0){
    6194:	fec42783          	lw	a5,-20(s0)
    6198:	2781                	sext.w	a5,a5
    619a:	ef95                	bnez	a5,61d6 <sbrkbugs+0x168>
    // set the break in the middle of a page.
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    619c:	4501                	li	a0,0
    619e:	00001097          	auipc	ra,0x1
    61a2:	792080e7          	jalr	1938(ra) # 7930 <sbrk>
    61a6:	87aa                	mv	a5,a0
    61a8:	2781                	sext.w	a5,a5
    61aa:	672d                	lui	a4,0xb
    61ac:	8007071b          	addiw	a4,a4,-2048 # a800 <malloc+0x281e>
    61b0:	40f707bb          	subw	a5,a4,a5
    61b4:	2781                	sext.w	a5,a5
    61b6:	2781                	sext.w	a5,a5
    61b8:	853e                	mv	a0,a5
    61ba:	00001097          	auipc	ra,0x1
    61be:	776080e7          	jalr	1910(ra) # 7930 <sbrk>

    // reduce the break a bit, but not enough to
    // cause a page to be freed. this used to cause
    // a panic.
    sbrk(-10);
    61c2:	5559                	li	a0,-10
    61c4:	00001097          	auipc	ra,0x1
    61c8:	76c080e7          	jalr	1900(ra) # 7930 <sbrk>

    exit(0);
    61cc:	4501                	li	a0,0
    61ce:	00001097          	auipc	ra,0x1
    61d2:	6da080e7          	jalr	1754(ra) # 78a8 <exit>
  }
  wait(0);
    61d6:	4501                	li	a0,0
    61d8:	00001097          	auipc	ra,0x1
    61dc:	6d8080e7          	jalr	1752(ra) # 78b0 <wait>

  exit(0);
    61e0:	4501                	li	a0,0
    61e2:	00001097          	auipc	ra,0x1
    61e6:	6c6080e7          	jalr	1734(ra) # 78a8 <exit>

00000000000061ea <sbrklast>:
// if process size was somewhat more than a page boundary, and then
// shrunk to be somewhat less than that page boundary, can the kernel
// still copyin() from addresses in the last page?
void
sbrklast(char *s)
{
    61ea:	7139                	addi	sp,sp,-64
    61ec:	fc06                	sd	ra,56(sp)
    61ee:	f822                	sd	s0,48(sp)
    61f0:	0080                	addi	s0,sp,64
    61f2:	fca43423          	sd	a0,-56(s0)
  uint64 top = (uint64) sbrk(0);
    61f6:	4501                	li	a0,0
    61f8:	00001097          	auipc	ra,0x1
    61fc:	738080e7          	jalr	1848(ra) # 7930 <sbrk>
    6200:	87aa                	mv	a5,a0
    6202:	fef43423          	sd	a5,-24(s0)
  if((top % 4096) != 0)
    6206:	fe843703          	ld	a4,-24(s0)
    620a:	6785                	lui	a5,0x1
    620c:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
    620e:	8ff9                	and	a5,a5,a4
    6210:	c39d                	beqz	a5,6236 <sbrklast+0x4c>
    sbrk(4096 - (top % 4096));
    6212:	fe843783          	ld	a5,-24(s0)
    6216:	2781                	sext.w	a5,a5
    6218:	873e                	mv	a4,a5
    621a:	6785                	lui	a5,0x1
    621c:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
    621e:	8ff9                	and	a5,a5,a4
    6220:	2781                	sext.w	a5,a5
    6222:	6705                	lui	a4,0x1
    6224:	40f707bb          	subw	a5,a4,a5
    6228:	2781                	sext.w	a5,a5
    622a:	2781                	sext.w	a5,a5
    622c:	853e                	mv	a0,a5
    622e:	00001097          	auipc	ra,0x1
    6232:	702080e7          	jalr	1794(ra) # 7930 <sbrk>
  sbrk(4096);
    6236:	6505                	lui	a0,0x1
    6238:	00001097          	auipc	ra,0x1
    623c:	6f8080e7          	jalr	1784(ra) # 7930 <sbrk>
  sbrk(10);
    6240:	4529                	li	a0,10
    6242:	00001097          	auipc	ra,0x1
    6246:	6ee080e7          	jalr	1774(ra) # 7930 <sbrk>
  sbrk(-20);
    624a:	5531                	li	a0,-20
    624c:	00001097          	auipc	ra,0x1
    6250:	6e4080e7          	jalr	1764(ra) # 7930 <sbrk>
  top = (uint64) sbrk(0);
    6254:	4501                	li	a0,0
    6256:	00001097          	auipc	ra,0x1
    625a:	6da080e7          	jalr	1754(ra) # 7930 <sbrk>
    625e:	87aa                	mv	a5,a0
    6260:	fef43423          	sd	a5,-24(s0)
  char *p = (char *) (top - 64);
    6264:	fe843783          	ld	a5,-24(s0)
    6268:	fc078793          	addi	a5,a5,-64
    626c:	fef43023          	sd	a5,-32(s0)
  p[0] = 'x';
    6270:	fe043783          	ld	a5,-32(s0)
    6274:	07800713          	li	a4,120
    6278:	00e78023          	sb	a4,0(a5)
  p[1] = '\0';
    627c:	fe043783          	ld	a5,-32(s0)
    6280:	0785                	addi	a5,a5,1
    6282:	00078023          	sb	zero,0(a5)
  int fd = open(p, O_RDWR|O_CREATE);
    6286:	20200593          	li	a1,514
    628a:	fe043503          	ld	a0,-32(s0)
    628e:	00001097          	auipc	ra,0x1
    6292:	65a080e7          	jalr	1626(ra) # 78e8 <open>
    6296:	87aa                	mv	a5,a0
    6298:	fcf42e23          	sw	a5,-36(s0)
  write(fd, p, 1);
    629c:	fdc42783          	lw	a5,-36(s0)
    62a0:	4605                	li	a2,1
    62a2:	fe043583          	ld	a1,-32(s0)
    62a6:	853e                	mv	a0,a5
    62a8:	00001097          	auipc	ra,0x1
    62ac:	620080e7          	jalr	1568(ra) # 78c8 <write>
  close(fd);
    62b0:	fdc42783          	lw	a5,-36(s0)
    62b4:	853e                	mv	a0,a5
    62b6:	00001097          	auipc	ra,0x1
    62ba:	61a080e7          	jalr	1562(ra) # 78d0 <close>
  fd = open(p, O_RDWR);
    62be:	4589                	li	a1,2
    62c0:	fe043503          	ld	a0,-32(s0)
    62c4:	00001097          	auipc	ra,0x1
    62c8:	624080e7          	jalr	1572(ra) # 78e8 <open>
    62cc:	87aa                	mv	a5,a0
    62ce:	fcf42e23          	sw	a5,-36(s0)
  p[0] = '\0';
    62d2:	fe043783          	ld	a5,-32(s0)
    62d6:	00078023          	sb	zero,0(a5)
  read(fd, p, 1);
    62da:	fdc42783          	lw	a5,-36(s0)
    62de:	4605                	li	a2,1
    62e0:	fe043583          	ld	a1,-32(s0)
    62e4:	853e                	mv	a0,a5
    62e6:	00001097          	auipc	ra,0x1
    62ea:	5da080e7          	jalr	1498(ra) # 78c0 <read>
  if(p[0] != 'x')
    62ee:	fe043783          	ld	a5,-32(s0)
    62f2:	0007c783          	lbu	a5,0(a5)
    62f6:	873e                	mv	a4,a5
    62f8:	07800793          	li	a5,120
    62fc:	00f70763          	beq	a4,a5,630a <sbrklast+0x120>
    exit(1);
    6300:	4505                	li	a0,1
    6302:	00001097          	auipc	ra,0x1
    6306:	5a6080e7          	jalr	1446(ra) # 78a8 <exit>
}
    630a:	0001                	nop
    630c:	70e2                	ld	ra,56(sp)
    630e:	7442                	ld	s0,48(sp)
    6310:	6121                	addi	sp,sp,64
    6312:	8082                	ret

0000000000006314 <sbrk8000>:

// does sbrk handle signed int32 wrap-around with
// negative arguments?
void
sbrk8000(char *s)
{
    6314:	7179                	addi	sp,sp,-48
    6316:	f406                	sd	ra,40(sp)
    6318:	f022                	sd	s0,32(sp)
    631a:	1800                	addi	s0,sp,48
    631c:	fca43c23          	sd	a0,-40(s0)
  sbrk(0x80000004);
    6320:	800007b7          	lui	a5,0x80000
    6324:	00478513          	addi	a0,a5,4 # ffffffff80000004 <freep+0xffffffff7ffee36c>
    6328:	00001097          	auipc	ra,0x1
    632c:	608080e7          	jalr	1544(ra) # 7930 <sbrk>
  volatile char *top = sbrk(0);
    6330:	4501                	li	a0,0
    6332:	00001097          	auipc	ra,0x1
    6336:	5fe080e7          	jalr	1534(ra) # 7930 <sbrk>
    633a:	fea43423          	sd	a0,-24(s0)
  *(top-1) = *(top-1) + 1;
    633e:	fe843783          	ld	a5,-24(s0)
    6342:	17fd                	addi	a5,a5,-1
    6344:	0007c783          	lbu	a5,0(a5)
    6348:	0ff7f713          	zext.b	a4,a5
    634c:	fe843783          	ld	a5,-24(s0)
    6350:	17fd                	addi	a5,a5,-1
    6352:	2705                	addiw	a4,a4,1 # 1001 <truncate3+0x1b3>
    6354:	0ff77713          	zext.b	a4,a4
    6358:	00e78023          	sb	a4,0(a5)
}
    635c:	0001                	nop
    635e:	70a2                	ld	ra,40(sp)
    6360:	7402                	ld	s0,32(sp)
    6362:	6145                	addi	sp,sp,48
    6364:	8082                	ret

0000000000006366 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    6366:	7139                	addi	sp,sp,-64
    6368:	fc06                	sd	ra,56(sp)
    636a:	f822                	sd	s0,48(sp)
    636c:	0080                	addi	s0,sp,64
    636e:	fca43423          	sd	a0,-56(s0)
  for(int i = 0; i < 50000; i++){
    6372:	fe042623          	sw	zero,-20(s0)
    6376:	a03d                	j	63a4 <badarg+0x3e>
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    6378:	57fd                	li	a5,-1
    637a:	9381                	srli	a5,a5,0x20
    637c:	fcf43c23          	sd	a5,-40(s0)
    argv[1] = 0;
    6380:	fe043023          	sd	zero,-32(s0)
    exec("echo", argv);
    6384:	fd840793          	addi	a5,s0,-40
    6388:	85be                	mv	a1,a5
    638a:	00002517          	auipc	a0,0x2
    638e:	fb650513          	addi	a0,a0,-74 # 8340 <malloc+0x35e>
    6392:	00001097          	auipc	ra,0x1
    6396:	54e080e7          	jalr	1358(ra) # 78e0 <exec>
  for(int i = 0; i < 50000; i++){
    639a:	fec42783          	lw	a5,-20(s0)
    639e:	2785                	addiw	a5,a5,1
    63a0:	fef42623          	sw	a5,-20(s0)
    63a4:	fec42783          	lw	a5,-20(s0)
    63a8:	0007871b          	sext.w	a4,a5
    63ac:	67b1                	lui	a5,0xc
    63ae:	34f78793          	addi	a5,a5,847 # c34f <buf+0xedf>
    63b2:	fce7d3e3          	bge	a5,a4,6378 <badarg+0x12>
  }
  
  exit(0);
    63b6:	4501                	li	a0,0
    63b8:	00001097          	auipc	ra,0x1
    63bc:	4f0080e7          	jalr	1264(ra) # 78a8 <exit>

00000000000063c0 <bigdir>:
//

// directory that uses indirect blocks
void
bigdir(char *s)
{
    63c0:	7139                	addi	sp,sp,-64
    63c2:	fc06                	sd	ra,56(sp)
    63c4:	f822                	sd	s0,48(sp)
    63c6:	0080                	addi	s0,sp,64
    63c8:	fca43423          	sd	a0,-56(s0)
  enum { N = 500 };
  int i, fd;
  char name[10];

  unlink("bd");
    63cc:	00004517          	auipc	a0,0x4
    63d0:	f2c50513          	addi	a0,a0,-212 # a2f8 <malloc+0x2316>
    63d4:	00001097          	auipc	ra,0x1
    63d8:	524080e7          	jalr	1316(ra) # 78f8 <unlink>

  fd = open("bd", O_CREATE);
    63dc:	20000593          	li	a1,512
    63e0:	00004517          	auipc	a0,0x4
    63e4:	f1850513          	addi	a0,a0,-232 # a2f8 <malloc+0x2316>
    63e8:	00001097          	auipc	ra,0x1
    63ec:	500080e7          	jalr	1280(ra) # 78e8 <open>
    63f0:	87aa                	mv	a5,a0
    63f2:	fef42423          	sw	a5,-24(s0)
  if(fd < 0){
    63f6:	fe842783          	lw	a5,-24(s0)
    63fa:	2781                	sext.w	a5,a5
    63fc:	0207d163          	bgez	a5,641e <bigdir+0x5e>
    printf("%s: bigdir create failed\n", s);
    6400:	fc843583          	ld	a1,-56(s0)
    6404:	00004517          	auipc	a0,0x4
    6408:	efc50513          	addi	a0,a0,-260 # a300 <malloc+0x231e>
    640c:	00002097          	auipc	ra,0x2
    6410:	9e4080e7          	jalr	-1564(ra) # 7df0 <printf>
    exit(1);
    6414:	4505                	li	a0,1
    6416:	00001097          	auipc	ra,0x1
    641a:	492080e7          	jalr	1170(ra) # 78a8 <exit>
  }
  close(fd);
    641e:	fe842783          	lw	a5,-24(s0)
    6422:	853e                	mv	a0,a5
    6424:	00001097          	auipc	ra,0x1
    6428:	4ac080e7          	jalr	1196(ra) # 78d0 <close>

  for(i = 0; i < N; i++){
    642c:	fe042623          	sw	zero,-20(s0)
    6430:	a055                	j	64d4 <bigdir+0x114>
    name[0] = 'x';
    6432:	07800793          	li	a5,120
    6436:	fcf40c23          	sb	a5,-40(s0)
    name[1] = '0' + (i / 64);
    643a:	fec42783          	lw	a5,-20(s0)
    643e:	41f7d71b          	sraiw	a4,a5,0x1f
    6442:	01a7571b          	srliw	a4,a4,0x1a
    6446:	9fb9                	addw	a5,a5,a4
    6448:	4067d79b          	sraiw	a5,a5,0x6
    644c:	2781                	sext.w	a5,a5
    644e:	0ff7f793          	zext.b	a5,a5
    6452:	0307879b          	addiw	a5,a5,48
    6456:	0ff7f793          	zext.b	a5,a5
    645a:	fcf40ca3          	sb	a5,-39(s0)
    name[2] = '0' + (i % 64);
    645e:	fec42783          	lw	a5,-20(s0)
    6462:	873e                	mv	a4,a5
    6464:	41f7579b          	sraiw	a5,a4,0x1f
    6468:	01a7d79b          	srliw	a5,a5,0x1a
    646c:	9f3d                	addw	a4,a4,a5
    646e:	03f77713          	andi	a4,a4,63
    6472:	40f707bb          	subw	a5,a4,a5
    6476:	2781                	sext.w	a5,a5
    6478:	0ff7f793          	zext.b	a5,a5
    647c:	0307879b          	addiw	a5,a5,48
    6480:	0ff7f793          	zext.b	a5,a5
    6484:	fcf40d23          	sb	a5,-38(s0)
    name[3] = '\0';
    6488:	fc040da3          	sb	zero,-37(s0)
    if(link("bd", name) != 0){
    648c:	fd840793          	addi	a5,s0,-40
    6490:	85be                	mv	a1,a5
    6492:	00004517          	auipc	a0,0x4
    6496:	e6650513          	addi	a0,a0,-410 # a2f8 <malloc+0x2316>
    649a:	00001097          	auipc	ra,0x1
    649e:	46e080e7          	jalr	1134(ra) # 7908 <link>
    64a2:	87aa                	mv	a5,a0
    64a4:	c39d                	beqz	a5,64ca <bigdir+0x10a>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    64a6:	fd840793          	addi	a5,s0,-40
    64aa:	863e                	mv	a2,a5
    64ac:	fc843583          	ld	a1,-56(s0)
    64b0:	00004517          	auipc	a0,0x4
    64b4:	e7050513          	addi	a0,a0,-400 # a320 <malloc+0x233e>
    64b8:	00002097          	auipc	ra,0x2
    64bc:	938080e7          	jalr	-1736(ra) # 7df0 <printf>
      exit(1);
    64c0:	4505                	li	a0,1
    64c2:	00001097          	auipc	ra,0x1
    64c6:	3e6080e7          	jalr	998(ra) # 78a8 <exit>
  for(i = 0; i < N; i++){
    64ca:	fec42783          	lw	a5,-20(s0)
    64ce:	2785                	addiw	a5,a5,1
    64d0:	fef42623          	sw	a5,-20(s0)
    64d4:	fec42783          	lw	a5,-20(s0)
    64d8:	0007871b          	sext.w	a4,a5
    64dc:	1f300793          	li	a5,499
    64e0:	f4e7d9e3          	bge	a5,a4,6432 <bigdir+0x72>
    }
  }

  unlink("bd");
    64e4:	00004517          	auipc	a0,0x4
    64e8:	e1450513          	addi	a0,a0,-492 # a2f8 <malloc+0x2316>
    64ec:	00001097          	auipc	ra,0x1
    64f0:	40c080e7          	jalr	1036(ra) # 78f8 <unlink>
  for(i = 0; i < N; i++){
    64f4:	fe042623          	sw	zero,-20(s0)
    64f8:	a859                	j	658e <bigdir+0x1ce>
    name[0] = 'x';
    64fa:	07800793          	li	a5,120
    64fe:	fcf40c23          	sb	a5,-40(s0)
    name[1] = '0' + (i / 64);
    6502:	fec42783          	lw	a5,-20(s0)
    6506:	41f7d71b          	sraiw	a4,a5,0x1f
    650a:	01a7571b          	srliw	a4,a4,0x1a
    650e:	9fb9                	addw	a5,a5,a4
    6510:	4067d79b          	sraiw	a5,a5,0x6
    6514:	2781                	sext.w	a5,a5
    6516:	0ff7f793          	zext.b	a5,a5
    651a:	0307879b          	addiw	a5,a5,48
    651e:	0ff7f793          	zext.b	a5,a5
    6522:	fcf40ca3          	sb	a5,-39(s0)
    name[2] = '0' + (i % 64);
    6526:	fec42783          	lw	a5,-20(s0)
    652a:	873e                	mv	a4,a5
    652c:	41f7579b          	sraiw	a5,a4,0x1f
    6530:	01a7d79b          	srliw	a5,a5,0x1a
    6534:	9f3d                	addw	a4,a4,a5
    6536:	03f77713          	andi	a4,a4,63
    653a:	40f707bb          	subw	a5,a4,a5
    653e:	2781                	sext.w	a5,a5
    6540:	0ff7f793          	zext.b	a5,a5
    6544:	0307879b          	addiw	a5,a5,48
    6548:	0ff7f793          	zext.b	a5,a5
    654c:	fcf40d23          	sb	a5,-38(s0)
    name[3] = '\0';
    6550:	fc040da3          	sb	zero,-37(s0)
    if(unlink(name) != 0){
    6554:	fd840793          	addi	a5,s0,-40
    6558:	853e                	mv	a0,a5
    655a:	00001097          	auipc	ra,0x1
    655e:	39e080e7          	jalr	926(ra) # 78f8 <unlink>
    6562:	87aa                	mv	a5,a0
    6564:	c385                	beqz	a5,6584 <bigdir+0x1c4>
      printf("%s: bigdir unlink failed", s);
    6566:	fc843583          	ld	a1,-56(s0)
    656a:	00004517          	auipc	a0,0x4
    656e:	dd650513          	addi	a0,a0,-554 # a340 <malloc+0x235e>
    6572:	00002097          	auipc	ra,0x2
    6576:	87e080e7          	jalr	-1922(ra) # 7df0 <printf>
      exit(1);
    657a:	4505                	li	a0,1
    657c:	00001097          	auipc	ra,0x1
    6580:	32c080e7          	jalr	812(ra) # 78a8 <exit>
  for(i = 0; i < N; i++){
    6584:	fec42783          	lw	a5,-20(s0)
    6588:	2785                	addiw	a5,a5,1
    658a:	fef42623          	sw	a5,-20(s0)
    658e:	fec42783          	lw	a5,-20(s0)
    6592:	0007871b          	sext.w	a4,a5
    6596:	1f300793          	li	a5,499
    659a:	f6e7d0e3          	bge	a5,a4,64fa <bigdir+0x13a>
    }
  }
}
    659e:	0001                	nop
    65a0:	0001                	nop
    65a2:	70e2                	ld	ra,56(sp)
    65a4:	7442                	ld	s0,48(sp)
    65a6:	6121                	addi	sp,sp,64
    65a8:	8082                	ret

00000000000065aa <manywrites>:

// concurrent writes to try to provoke deadlock in the virtio disk
// driver.
void
manywrites(char *s)
{
    65aa:	711d                	addi	sp,sp,-96
    65ac:	ec86                	sd	ra,88(sp)
    65ae:	e8a2                	sd	s0,80(sp)
    65b0:	1080                	addi	s0,sp,96
    65b2:	faa43423          	sd	a0,-88(s0)
  int nchildren = 4;
    65b6:	4791                	li	a5,4
    65b8:	fcf42e23          	sw	a5,-36(s0)
  int howmany = 30; // increase to look for deadlock
    65bc:	47f9                	li	a5,30
    65be:	fcf42c23          	sw	a5,-40(s0)
  
  for(int ci = 0; ci < nchildren; ci++){
    65c2:	fe042623          	sw	zero,-20(s0)
    65c6:	aa61                	j	675e <manywrites+0x1b4>
    int pid = fork();
    65c8:	00001097          	auipc	ra,0x1
    65cc:	2d8080e7          	jalr	728(ra) # 78a0 <fork>
    65d0:	87aa                	mv	a5,a0
    65d2:	fcf42a23          	sw	a5,-44(s0)
    if(pid < 0){
    65d6:	fd442783          	lw	a5,-44(s0)
    65da:	2781                	sext.w	a5,a5
    65dc:	0007df63          	bgez	a5,65fa <manywrites+0x50>
      printf("fork failed\n");
    65e0:	00002517          	auipc	a0,0x2
    65e4:	d5050513          	addi	a0,a0,-688 # 8330 <malloc+0x34e>
    65e8:	00002097          	auipc	ra,0x2
    65ec:	808080e7          	jalr	-2040(ra) # 7df0 <printf>
      exit(1);
    65f0:	4505                	li	a0,1
    65f2:	00001097          	auipc	ra,0x1
    65f6:	2b6080e7          	jalr	694(ra) # 78a8 <exit>
    }

    if(pid == 0){
    65fa:	fd442783          	lw	a5,-44(s0)
    65fe:	2781                	sext.w	a5,a5
    6600:	14079a63          	bnez	a5,6754 <manywrites+0x1aa>
      char name[3];
      name[0] = 'b';
    6604:	06200793          	li	a5,98
    6608:	fcf40023          	sb	a5,-64(s0)
      name[1] = 'a' + ci;
    660c:	fec42783          	lw	a5,-20(s0)
    6610:	0ff7f793          	zext.b	a5,a5
    6614:	0617879b          	addiw	a5,a5,97
    6618:	0ff7f793          	zext.b	a5,a5
    661c:	fcf400a3          	sb	a5,-63(s0)
      name[2] = '\0';
    6620:	fc040123          	sb	zero,-62(s0)
      unlink(name);
    6624:	fc040793          	addi	a5,s0,-64
    6628:	853e                	mv	a0,a5
    662a:	00001097          	auipc	ra,0x1
    662e:	2ce080e7          	jalr	718(ra) # 78f8 <unlink>
      
      for(int iters = 0; iters < howmany; iters++){
    6632:	fe042423          	sw	zero,-24(s0)
    6636:	a8d5                	j	672a <manywrites+0x180>
        for(int i = 0; i < ci+1; i++){
    6638:	fe042223          	sw	zero,-28(s0)
    663c:	a0d1                	j	6700 <manywrites+0x156>
          int fd = open(name, O_CREATE | O_RDWR);
    663e:	fc040793          	addi	a5,s0,-64
    6642:	20200593          	li	a1,514
    6646:	853e                	mv	a0,a5
    6648:	00001097          	auipc	ra,0x1
    664c:	2a0080e7          	jalr	672(ra) # 78e8 <open>
    6650:	87aa                	mv	a5,a0
    6652:	fcf42823          	sw	a5,-48(s0)
          if(fd < 0){
    6656:	fd042783          	lw	a5,-48(s0)
    665a:	2781                	sext.w	a5,a5
    665c:	0207d463          	bgez	a5,6684 <manywrites+0xda>
            printf("%s: cannot create %s\n", s, name);
    6660:	fc040793          	addi	a5,s0,-64
    6664:	863e                	mv	a2,a5
    6666:	fa843583          	ld	a1,-88(s0)
    666a:	00004517          	auipc	a0,0x4
    666e:	cf650513          	addi	a0,a0,-778 # a360 <malloc+0x237e>
    6672:	00001097          	auipc	ra,0x1
    6676:	77e080e7          	jalr	1918(ra) # 7df0 <printf>
            exit(1);
    667a:	4505                	li	a0,1
    667c:	00001097          	auipc	ra,0x1
    6680:	22c080e7          	jalr	556(ra) # 78a8 <exit>
          }
          int sz = sizeof(buf);
    6684:	678d                	lui	a5,0x3
    6686:	fcf42623          	sw	a5,-52(s0)
          int cc = write(fd, buf, sz);
    668a:	fcc42703          	lw	a4,-52(s0)
    668e:	fd042783          	lw	a5,-48(s0)
    6692:	863a                	mv	a2,a4
    6694:	00005597          	auipc	a1,0x5
    6698:	ddc58593          	addi	a1,a1,-548 # b470 <buf>
    669c:	853e                	mv	a0,a5
    669e:	00001097          	auipc	ra,0x1
    66a2:	22a080e7          	jalr	554(ra) # 78c8 <write>
    66a6:	87aa                	mv	a5,a0
    66a8:	fcf42423          	sw	a5,-56(s0)
          if(cc != sz){
    66ac:	fc842783          	lw	a5,-56(s0)
    66b0:	873e                	mv	a4,a5
    66b2:	fcc42783          	lw	a5,-52(s0)
    66b6:	2701                	sext.w	a4,a4
    66b8:	2781                	sext.w	a5,a5
    66ba:	02f70763          	beq	a4,a5,66e8 <manywrites+0x13e>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    66be:	fc842703          	lw	a4,-56(s0)
    66c2:	fcc42783          	lw	a5,-52(s0)
    66c6:	86ba                	mv	a3,a4
    66c8:	863e                	mv	a2,a5
    66ca:	fa843583          	ld	a1,-88(s0)
    66ce:	00003517          	auipc	a0,0x3
    66d2:	e9a50513          	addi	a0,a0,-358 # 9568 <malloc+0x1586>
    66d6:	00001097          	auipc	ra,0x1
    66da:	71a080e7          	jalr	1818(ra) # 7df0 <printf>
            exit(1);
    66de:	4505                	li	a0,1
    66e0:	00001097          	auipc	ra,0x1
    66e4:	1c8080e7          	jalr	456(ra) # 78a8 <exit>
          }
          close(fd);
    66e8:	fd042783          	lw	a5,-48(s0)
    66ec:	853e                	mv	a0,a5
    66ee:	00001097          	auipc	ra,0x1
    66f2:	1e2080e7          	jalr	482(ra) # 78d0 <close>
        for(int i = 0; i < ci+1; i++){
    66f6:	fe442783          	lw	a5,-28(s0)
    66fa:	2785                	addiw	a5,a5,1 # 3001 <createdelete+0x287>
    66fc:	fef42223          	sw	a5,-28(s0)
    6700:	fec42783          	lw	a5,-20(s0)
    6704:	873e                	mv	a4,a5
    6706:	fe442783          	lw	a5,-28(s0)
    670a:	2701                	sext.w	a4,a4
    670c:	2781                	sext.w	a5,a5
    670e:	f2f758e3          	bge	a4,a5,663e <manywrites+0x94>
        }
        unlink(name);
    6712:	fc040793          	addi	a5,s0,-64
    6716:	853e                	mv	a0,a5
    6718:	00001097          	auipc	ra,0x1
    671c:	1e0080e7          	jalr	480(ra) # 78f8 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    6720:	fe842783          	lw	a5,-24(s0)
    6724:	2785                	addiw	a5,a5,1
    6726:	fef42423          	sw	a5,-24(s0)
    672a:	fe842783          	lw	a5,-24(s0)
    672e:	873e                	mv	a4,a5
    6730:	fd842783          	lw	a5,-40(s0)
    6734:	2701                	sext.w	a4,a4
    6736:	2781                	sext.w	a5,a5
    6738:	f0f740e3          	blt	a4,a5,6638 <manywrites+0x8e>
      }

      unlink(name);
    673c:	fc040793          	addi	a5,s0,-64
    6740:	853e                	mv	a0,a5
    6742:	00001097          	auipc	ra,0x1
    6746:	1b6080e7          	jalr	438(ra) # 78f8 <unlink>
      exit(0);
    674a:	4501                	li	a0,0
    674c:	00001097          	auipc	ra,0x1
    6750:	15c080e7          	jalr	348(ra) # 78a8 <exit>
  for(int ci = 0; ci < nchildren; ci++){
    6754:	fec42783          	lw	a5,-20(s0)
    6758:	2785                	addiw	a5,a5,1
    675a:	fef42623          	sw	a5,-20(s0)
    675e:	fec42783          	lw	a5,-20(s0)
    6762:	873e                	mv	a4,a5
    6764:	fdc42783          	lw	a5,-36(s0)
    6768:	2701                	sext.w	a4,a4
    676a:	2781                	sext.w	a5,a5
    676c:	e4f74ee3          	blt	a4,a5,65c8 <manywrites+0x1e>
    }
  }

  for(int ci = 0; ci < nchildren; ci++){
    6770:	fe042023          	sw	zero,-32(s0)
    6774:	a80d                	j	67a6 <manywrites+0x1fc>
    int st = 0;
    6776:	fa042e23          	sw	zero,-68(s0)
    wait(&st);
    677a:	fbc40793          	addi	a5,s0,-68
    677e:	853e                	mv	a0,a5
    6780:	00001097          	auipc	ra,0x1
    6784:	130080e7          	jalr	304(ra) # 78b0 <wait>
    if(st != 0)
    6788:	fbc42783          	lw	a5,-68(s0)
    678c:	cb81                	beqz	a5,679c <manywrites+0x1f2>
      exit(st);
    678e:	fbc42783          	lw	a5,-68(s0)
    6792:	853e                	mv	a0,a5
    6794:	00001097          	auipc	ra,0x1
    6798:	114080e7          	jalr	276(ra) # 78a8 <exit>
  for(int ci = 0; ci < nchildren; ci++){
    679c:	fe042783          	lw	a5,-32(s0)
    67a0:	2785                	addiw	a5,a5,1
    67a2:	fef42023          	sw	a5,-32(s0)
    67a6:	fe042783          	lw	a5,-32(s0)
    67aa:	873e                	mv	a4,a5
    67ac:	fdc42783          	lw	a5,-36(s0)
    67b0:	2701                	sext.w	a4,a4
    67b2:	2781                	sext.w	a5,a5
    67b4:	fcf741e3          	blt	a4,a5,6776 <manywrites+0x1cc>
  }
  exit(0);
    67b8:	4501                	li	a0,0
    67ba:	00001097          	auipc	ra,0x1
    67be:	0ee080e7          	jalr	238(ra) # 78a8 <exit>

00000000000067c2 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
    67c2:	7179                	addi	sp,sp,-48
    67c4:	f406                	sd	ra,40(sp)
    67c6:	f022                	sd	s0,32(sp)
    67c8:	1800                	addi	s0,sp,48
    67ca:	fca43c23          	sd	a0,-40(s0)
  int assumed_free = 600;
    67ce:	25800793          	li	a5,600
    67d2:	fef42423          	sw	a5,-24(s0)
  
  unlink("junk");
    67d6:	00004517          	auipc	a0,0x4
    67da:	ba250513          	addi	a0,a0,-1118 # a378 <malloc+0x2396>
    67de:	00001097          	auipc	ra,0x1
    67e2:	11a080e7          	jalr	282(ra) # 78f8 <unlink>
  for(int i = 0; i < assumed_free; i++){
    67e6:	fe042623          	sw	zero,-20(s0)
    67ea:	a8bd                	j	6868 <badwrite+0xa6>
    int fd = open("junk", O_CREATE|O_WRONLY);
    67ec:	20100593          	li	a1,513
    67f0:	00004517          	auipc	a0,0x4
    67f4:	b8850513          	addi	a0,a0,-1144 # a378 <malloc+0x2396>
    67f8:	00001097          	auipc	ra,0x1
    67fc:	0f0080e7          	jalr	240(ra) # 78e8 <open>
    6800:	87aa                	mv	a5,a0
    6802:	fef42023          	sw	a5,-32(s0)
    if(fd < 0){
    6806:	fe042783          	lw	a5,-32(s0)
    680a:	2781                	sext.w	a5,a5
    680c:	0007df63          	bgez	a5,682a <badwrite+0x68>
      printf("open junk failed\n");
    6810:	00004517          	auipc	a0,0x4
    6814:	b7050513          	addi	a0,a0,-1168 # a380 <malloc+0x239e>
    6818:	00001097          	auipc	ra,0x1
    681c:	5d8080e7          	jalr	1496(ra) # 7df0 <printf>
      exit(1);
    6820:	4505                	li	a0,1
    6822:	00001097          	auipc	ra,0x1
    6826:	086080e7          	jalr	134(ra) # 78a8 <exit>
    }
    write(fd, (char*)0xffffffffffL, 1);
    682a:	fe042703          	lw	a4,-32(s0)
    682e:	4605                	li	a2,1
    6830:	57fd                	li	a5,-1
    6832:	0187d593          	srli	a1,a5,0x18
    6836:	853a                	mv	a0,a4
    6838:	00001097          	auipc	ra,0x1
    683c:	090080e7          	jalr	144(ra) # 78c8 <write>
    close(fd);
    6840:	fe042783          	lw	a5,-32(s0)
    6844:	853e                	mv	a0,a5
    6846:	00001097          	auipc	ra,0x1
    684a:	08a080e7          	jalr	138(ra) # 78d0 <close>
    unlink("junk");
    684e:	00004517          	auipc	a0,0x4
    6852:	b2a50513          	addi	a0,a0,-1238 # a378 <malloc+0x2396>
    6856:	00001097          	auipc	ra,0x1
    685a:	0a2080e7          	jalr	162(ra) # 78f8 <unlink>
  for(int i = 0; i < assumed_free; i++){
    685e:	fec42783          	lw	a5,-20(s0)
    6862:	2785                	addiw	a5,a5,1
    6864:	fef42623          	sw	a5,-20(s0)
    6868:	fec42783          	lw	a5,-20(s0)
    686c:	873e                	mv	a4,a5
    686e:	fe842783          	lw	a5,-24(s0)
    6872:	2701                	sext.w	a4,a4
    6874:	2781                	sext.w	a5,a5
    6876:	f6f74be3          	blt	a4,a5,67ec <badwrite+0x2a>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
    687a:	20100593          	li	a1,513
    687e:	00004517          	auipc	a0,0x4
    6882:	afa50513          	addi	a0,a0,-1286 # a378 <malloc+0x2396>
    6886:	00001097          	auipc	ra,0x1
    688a:	062080e7          	jalr	98(ra) # 78e8 <open>
    688e:	87aa                	mv	a5,a0
    6890:	fef42223          	sw	a5,-28(s0)
  if(fd < 0){
    6894:	fe442783          	lw	a5,-28(s0)
    6898:	2781                	sext.w	a5,a5
    689a:	0007df63          	bgez	a5,68b8 <badwrite+0xf6>
    printf("open junk failed\n");
    689e:	00004517          	auipc	a0,0x4
    68a2:	ae250513          	addi	a0,a0,-1310 # a380 <malloc+0x239e>
    68a6:	00001097          	auipc	ra,0x1
    68aa:	54a080e7          	jalr	1354(ra) # 7df0 <printf>
    exit(1);
    68ae:	4505                	li	a0,1
    68b0:	00001097          	auipc	ra,0x1
    68b4:	ff8080e7          	jalr	-8(ra) # 78a8 <exit>
  }
  if(write(fd, "x", 1) != 1){
    68b8:	fe442783          	lw	a5,-28(s0)
    68bc:	4605                	li	a2,1
    68be:	00002597          	auipc	a1,0x2
    68c2:	97258593          	addi	a1,a1,-1678 # 8230 <malloc+0x24e>
    68c6:	853e                	mv	a0,a5
    68c8:	00001097          	auipc	ra,0x1
    68cc:	000080e7          	jalr	ra # 78c8 <write>
    68d0:	87aa                	mv	a5,a0
    68d2:	873e                	mv	a4,a5
    68d4:	4785                	li	a5,1
    68d6:	00f70f63          	beq	a4,a5,68f4 <badwrite+0x132>
    printf("write failed\n");
    68da:	00004517          	auipc	a0,0x4
    68de:	abe50513          	addi	a0,a0,-1346 # a398 <malloc+0x23b6>
    68e2:	00001097          	auipc	ra,0x1
    68e6:	50e080e7          	jalr	1294(ra) # 7df0 <printf>
    exit(1);
    68ea:	4505                	li	a0,1
    68ec:	00001097          	auipc	ra,0x1
    68f0:	fbc080e7          	jalr	-68(ra) # 78a8 <exit>
  }
  close(fd);
    68f4:	fe442783          	lw	a5,-28(s0)
    68f8:	853e                	mv	a0,a5
    68fa:	00001097          	auipc	ra,0x1
    68fe:	fd6080e7          	jalr	-42(ra) # 78d0 <close>
  unlink("junk");
    6902:	00004517          	auipc	a0,0x4
    6906:	a7650513          	addi	a0,a0,-1418 # a378 <malloc+0x2396>
    690a:	00001097          	auipc	ra,0x1
    690e:	fee080e7          	jalr	-18(ra) # 78f8 <unlink>

  exit(0);
    6912:	4501                	li	a0,0
    6914:	00001097          	auipc	ra,0x1
    6918:	f94080e7          	jalr	-108(ra) # 78a8 <exit>

000000000000691c <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    691c:	715d                	addi	sp,sp,-80
    691e:	e486                	sd	ra,72(sp)
    6920:	e0a2                	sd	s0,64(sp)
    6922:	0880                	addi	s0,sp,80
    6924:	faa43c23          	sd	a0,-72(s0)
  for(int avail = 0; avail < 15; avail++){
    6928:	fe042623          	sw	zero,-20(s0)
    692c:	a8cd                	j	6a1e <execout+0x102>
    int pid = fork();
    692e:	00001097          	auipc	ra,0x1
    6932:	f72080e7          	jalr	-142(ra) # 78a0 <fork>
    6936:	87aa                	mv	a5,a0
    6938:	fef42223          	sw	a5,-28(s0)
    if(pid < 0){
    693c:	fe442783          	lw	a5,-28(s0)
    6940:	2781                	sext.w	a5,a5
    6942:	0007df63          	bgez	a5,6960 <execout+0x44>
      printf("fork failed\n");
    6946:	00002517          	auipc	a0,0x2
    694a:	9ea50513          	addi	a0,a0,-1558 # 8330 <malloc+0x34e>
    694e:	00001097          	auipc	ra,0x1
    6952:	4a2080e7          	jalr	1186(ra) # 7df0 <printf>
      exit(1);
    6956:	4505                	li	a0,1
    6958:	00001097          	auipc	ra,0x1
    695c:	f50080e7          	jalr	-176(ra) # 78a8 <exit>
    } else if(pid == 0){
    6960:	fe442783          	lw	a5,-28(s0)
    6964:	2781                	sext.w	a5,a5
    6966:	e3d5                	bnez	a5,6a0a <execout+0xee>
      // allocate all of memory.
      while(1){
        uint64 a = (uint64) sbrk(4096);
    6968:	6505                	lui	a0,0x1
    696a:	00001097          	auipc	ra,0x1
    696e:	fc6080e7          	jalr	-58(ra) # 7930 <sbrk>
    6972:	87aa                	mv	a5,a0
    6974:	fcf43c23          	sd	a5,-40(s0)
        if(a == 0xffffffffffffffffLL)
    6978:	fd843703          	ld	a4,-40(s0)
    697c:	57fd                	li	a5,-1
    697e:	00f70c63          	beq	a4,a5,6996 <execout+0x7a>
          break;
        *(char*)(a + 4096 - 1) = 1;
    6982:	fd843703          	ld	a4,-40(s0)
    6986:	6785                	lui	a5,0x1
    6988:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
    698a:	97ba                	add	a5,a5,a4
    698c:	873e                	mv	a4,a5
    698e:	4785                	li	a5,1
    6990:	00f70023          	sb	a5,0(a4)
      while(1){
    6994:	bfd1                	j	6968 <execout+0x4c>
          break;
    6996:	0001                	nop
      }

      // free a few pages, in order to let exec() make some
      // progress.
      for(int i = 0; i < avail; i++)
    6998:	fe042423          	sw	zero,-24(s0)
    699c:	a819                	j	69b2 <execout+0x96>
        sbrk(-4096);
    699e:	757d                	lui	a0,0xfffff
    69a0:	00001097          	auipc	ra,0x1
    69a4:	f90080e7          	jalr	-112(ra) # 7930 <sbrk>
      for(int i = 0; i < avail; i++)
    69a8:	fe842783          	lw	a5,-24(s0)
    69ac:	2785                	addiw	a5,a5,1
    69ae:	fef42423          	sw	a5,-24(s0)
    69b2:	fe842783          	lw	a5,-24(s0)
    69b6:	873e                	mv	a4,a5
    69b8:	fec42783          	lw	a5,-20(s0)
    69bc:	2701                	sext.w	a4,a4
    69be:	2781                	sext.w	a5,a5
    69c0:	fcf74fe3          	blt	a4,a5,699e <execout+0x82>
      
      close(1);
    69c4:	4505                	li	a0,1
    69c6:	00001097          	auipc	ra,0x1
    69ca:	f0a080e7          	jalr	-246(ra) # 78d0 <close>
      char *args[] = { "echo", "x", 0 };
    69ce:	00002797          	auipc	a5,0x2
    69d2:	97278793          	addi	a5,a5,-1678 # 8340 <malloc+0x35e>
    69d6:	fcf43023          	sd	a5,-64(s0)
    69da:	00002797          	auipc	a5,0x2
    69de:	85678793          	addi	a5,a5,-1962 # 8230 <malloc+0x24e>
    69e2:	fcf43423          	sd	a5,-56(s0)
    69e6:	fc043823          	sd	zero,-48(s0)
      exec("echo", args);
    69ea:	fc040793          	addi	a5,s0,-64
    69ee:	85be                	mv	a1,a5
    69f0:	00002517          	auipc	a0,0x2
    69f4:	95050513          	addi	a0,a0,-1712 # 8340 <malloc+0x35e>
    69f8:	00001097          	auipc	ra,0x1
    69fc:	ee8080e7          	jalr	-280(ra) # 78e0 <exec>
      exit(0);
    6a00:	4501                	li	a0,0
    6a02:	00001097          	auipc	ra,0x1
    6a06:	ea6080e7          	jalr	-346(ra) # 78a8 <exit>
    } else {
      wait((int*)0);
    6a0a:	4501                	li	a0,0
    6a0c:	00001097          	auipc	ra,0x1
    6a10:	ea4080e7          	jalr	-348(ra) # 78b0 <wait>
  for(int avail = 0; avail < 15; avail++){
    6a14:	fec42783          	lw	a5,-20(s0)
    6a18:	2785                	addiw	a5,a5,1
    6a1a:	fef42623          	sw	a5,-20(s0)
    6a1e:	fec42783          	lw	a5,-20(s0)
    6a22:	0007871b          	sext.w	a4,a5
    6a26:	47b9                	li	a5,14
    6a28:	f0e7d3e3          	bge	a5,a4,692e <execout+0x12>
    }
  }

  exit(0);
    6a2c:	4501                	li	a0,0
    6a2e:	00001097          	auipc	ra,0x1
    6a32:	e7a080e7          	jalr	-390(ra) # 78a8 <exit>

0000000000006a36 <diskfull>:
}

// can the kernel tolerate running out of disk space?
void
diskfull(char *s)
{
    6a36:	b9010113          	addi	sp,sp,-1136
    6a3a:	46113423          	sd	ra,1128(sp)
    6a3e:	46813023          	sd	s0,1120(sp)
    6a42:	47010413          	addi	s0,sp,1136
    6a46:	b8a43c23          	sd	a0,-1128(s0)
  int fi;
  int done = 0;
    6a4a:	fe042423          	sw	zero,-24(s0)

  unlink("diskfulldir");
    6a4e:	00004517          	auipc	a0,0x4
    6a52:	95a50513          	addi	a0,a0,-1702 # a3a8 <malloc+0x23c6>
    6a56:	00001097          	auipc	ra,0x1
    6a5a:	ea2080e7          	jalr	-350(ra) # 78f8 <unlink>
  
  for(fi = 0; done == 0; fi++){
    6a5e:	fe042623          	sw	zero,-20(s0)
    6a62:	a8d5                	j	6b56 <diskfull+0x120>
    char name[32];
    name[0] = 'b';
    6a64:	06200793          	li	a5,98
    6a68:	baf40423          	sb	a5,-1112(s0)
    name[1] = 'i';
    6a6c:	06900793          	li	a5,105
    6a70:	baf404a3          	sb	a5,-1111(s0)
    name[2] = 'g';
    6a74:	06700793          	li	a5,103
    6a78:	baf40523          	sb	a5,-1110(s0)
    name[3] = '0' + fi;
    6a7c:	fec42783          	lw	a5,-20(s0)
    6a80:	0ff7f793          	zext.b	a5,a5
    6a84:	0307879b          	addiw	a5,a5,48
    6a88:	0ff7f793          	zext.b	a5,a5
    6a8c:	baf405a3          	sb	a5,-1109(s0)
    name[4] = '\0';
    6a90:	ba040623          	sb	zero,-1108(s0)
    unlink(name);
    6a94:	ba840793          	addi	a5,s0,-1112
    6a98:	853e                	mv	a0,a5
    6a9a:	00001097          	auipc	ra,0x1
    6a9e:	e5e080e7          	jalr	-418(ra) # 78f8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    6aa2:	ba840793          	addi	a5,s0,-1112
    6aa6:	60200593          	li	a1,1538
    6aaa:	853e                	mv	a0,a5
    6aac:	00001097          	auipc	ra,0x1
    6ab0:	e3c080e7          	jalr	-452(ra) # 78e8 <open>
    6ab4:	87aa                	mv	a5,a0
    6ab6:	fcf42a23          	sw	a5,-44(s0)
    if(fd < 0){
    6aba:	fd442783          	lw	a5,-44(s0)
    6abe:	2781                	sext.w	a5,a5
    6ac0:	0207d363          	bgez	a5,6ae6 <diskfull+0xb0>
      // oops, ran out of inodes before running out of blocks.
      printf("%s: could not create file %s\n", s, name);
    6ac4:	ba840793          	addi	a5,s0,-1112
    6ac8:	863e                	mv	a2,a5
    6aca:	b9843583          	ld	a1,-1128(s0)
    6ace:	00004517          	auipc	a0,0x4
    6ad2:	8ea50513          	addi	a0,a0,-1814 # a3b8 <malloc+0x23d6>
    6ad6:	00001097          	auipc	ra,0x1
    6ada:	31a080e7          	jalr	794(ra) # 7df0 <printf>
      done = 1;
    6ade:	4785                	li	a5,1
    6ae0:	fef42423          	sw	a5,-24(s0)
    6ae4:	a8ad                	j	6b5e <diskfull+0x128>
      break;
    }
    for(int i = 0; i < MAXFILE; i++){
    6ae6:	fe042223          	sw	zero,-28(s0)
    6aea:	a099                	j	6b30 <diskfull+0xfa>
      char buf[BSIZE];
      if(write(fd, buf, BSIZE) != BSIZE){
    6aec:	bc840713          	addi	a4,s0,-1080
    6af0:	fd442783          	lw	a5,-44(s0)
    6af4:	40000613          	li	a2,1024
    6af8:	85ba                	mv	a1,a4
    6afa:	853e                	mv	a0,a5
    6afc:	00001097          	auipc	ra,0x1
    6b00:	dcc080e7          	jalr	-564(ra) # 78c8 <write>
    6b04:	87aa                	mv	a5,a0
    6b06:	873e                	mv	a4,a5
    6b08:	40000793          	li	a5,1024
    6b0c:	00f70d63          	beq	a4,a5,6b26 <diskfull+0xf0>
        done = 1;
    6b10:	4785                	li	a5,1
    6b12:	fef42423          	sw	a5,-24(s0)
        close(fd);
    6b16:	fd442783          	lw	a5,-44(s0)
    6b1a:	853e                	mv	a0,a5
    6b1c:	00001097          	auipc	ra,0x1
    6b20:	db4080e7          	jalr	-588(ra) # 78d0 <close>
    6b24:	a829                	j	6b3e <diskfull+0x108>
    for(int i = 0; i < MAXFILE; i++){
    6b26:	fe442783          	lw	a5,-28(s0)
    6b2a:	2785                	addiw	a5,a5,1
    6b2c:	fef42223          	sw	a5,-28(s0)
    6b30:	fe442783          	lw	a5,-28(s0)
    6b34:	873e                	mv	a4,a5
    6b36:	10b00793          	li	a5,267
    6b3a:	fae7f9e3          	bgeu	a5,a4,6aec <diskfull+0xb6>
        break;
      }
    }
    close(fd);
    6b3e:	fd442783          	lw	a5,-44(s0)
    6b42:	853e                	mv	a0,a5
    6b44:	00001097          	auipc	ra,0x1
    6b48:	d8c080e7          	jalr	-628(ra) # 78d0 <close>
  for(fi = 0; done == 0; fi++){
    6b4c:	fec42783          	lw	a5,-20(s0)
    6b50:	2785                	addiw	a5,a5,1
    6b52:	fef42623          	sw	a5,-20(s0)
    6b56:	fe842783          	lw	a5,-24(s0)
    6b5a:	2781                	sext.w	a5,a5
    6b5c:	d781                	beqz	a5,6a64 <diskfull+0x2e>

  // now that there are no free blocks, test that dirlink()
  // merely fails (doesn't panic) if it can't extend
  // directory content. one of these file creations
  // is expected to fail.
  int nzz = 128;
    6b5e:	08000793          	li	a5,128
    6b62:	fcf42823          	sw	a5,-48(s0)
  for(int i = 0; i < nzz; i++){
    6b66:	fe042023          	sw	zero,-32(s0)
    6b6a:	a06d                	j	6c14 <diskfull+0x1de>
    char name[32];
    name[0] = 'z';
    6b6c:	07a00793          	li	a5,122
    6b70:	bcf40423          	sb	a5,-1080(s0)
    name[1] = 'z';
    6b74:	07a00793          	li	a5,122
    6b78:	bcf404a3          	sb	a5,-1079(s0)
    name[2] = '0' + (i / 32);
    6b7c:	fe042783          	lw	a5,-32(s0)
    6b80:	41f7d71b          	sraiw	a4,a5,0x1f
    6b84:	01b7571b          	srliw	a4,a4,0x1b
    6b88:	9fb9                	addw	a5,a5,a4
    6b8a:	4057d79b          	sraiw	a5,a5,0x5
    6b8e:	2781                	sext.w	a5,a5
    6b90:	0ff7f793          	zext.b	a5,a5
    6b94:	0307879b          	addiw	a5,a5,48
    6b98:	0ff7f793          	zext.b	a5,a5
    6b9c:	bcf40523          	sb	a5,-1078(s0)
    name[3] = '0' + (i % 32);
    6ba0:	fe042783          	lw	a5,-32(s0)
    6ba4:	873e                	mv	a4,a5
    6ba6:	41f7579b          	sraiw	a5,a4,0x1f
    6baa:	01b7d79b          	srliw	a5,a5,0x1b
    6bae:	9f3d                	addw	a4,a4,a5
    6bb0:	8b7d                	andi	a4,a4,31
    6bb2:	40f707bb          	subw	a5,a4,a5
    6bb6:	2781                	sext.w	a5,a5
    6bb8:	0ff7f793          	zext.b	a5,a5
    6bbc:	0307879b          	addiw	a5,a5,48
    6bc0:	0ff7f793          	zext.b	a5,a5
    6bc4:	bcf405a3          	sb	a5,-1077(s0)
    name[4] = '\0';
    6bc8:	bc040623          	sb	zero,-1076(s0)
    unlink(name);
    6bcc:	bc840793          	addi	a5,s0,-1080
    6bd0:	853e                	mv	a0,a5
    6bd2:	00001097          	auipc	ra,0x1
    6bd6:	d26080e7          	jalr	-730(ra) # 78f8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    6bda:	bc840793          	addi	a5,s0,-1080
    6bde:	60200593          	li	a1,1538
    6be2:	853e                	mv	a0,a5
    6be4:	00001097          	auipc	ra,0x1
    6be8:	d04080e7          	jalr	-764(ra) # 78e8 <open>
    6bec:	87aa                	mv	a5,a0
    6bee:	fcf42623          	sw	a5,-52(s0)
    if(fd < 0)
    6bf2:	fcc42783          	lw	a5,-52(s0)
    6bf6:	2781                	sext.w	a5,a5
    6bf8:	0207c863          	bltz	a5,6c28 <diskfull+0x1f2>
      break;
    close(fd);
    6bfc:	fcc42783          	lw	a5,-52(s0)
    6c00:	853e                	mv	a0,a5
    6c02:	00001097          	auipc	ra,0x1
    6c06:	cce080e7          	jalr	-818(ra) # 78d0 <close>
  for(int i = 0; i < nzz; i++){
    6c0a:	fe042783          	lw	a5,-32(s0)
    6c0e:	2785                	addiw	a5,a5,1
    6c10:	fef42023          	sw	a5,-32(s0)
    6c14:	fe042783          	lw	a5,-32(s0)
    6c18:	873e                	mv	a4,a5
    6c1a:	fd042783          	lw	a5,-48(s0)
    6c1e:	2701                	sext.w	a4,a4
    6c20:	2781                	sext.w	a5,a5
    6c22:	f4f745e3          	blt	a4,a5,6b6c <diskfull+0x136>
    6c26:	a011                	j	6c2a <diskfull+0x1f4>
      break;
    6c28:	0001                	nop
  }

  // this mkdir() is expected to fail.
  if(mkdir("diskfulldir") == 0)
    6c2a:	00003517          	auipc	a0,0x3
    6c2e:	77e50513          	addi	a0,a0,1918 # a3a8 <malloc+0x23c6>
    6c32:	00001097          	auipc	ra,0x1
    6c36:	cde080e7          	jalr	-802(ra) # 7910 <mkdir>
    6c3a:	87aa                	mv	a5,a0
    6c3c:	eb89                	bnez	a5,6c4e <diskfull+0x218>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    6c3e:	00003517          	auipc	a0,0x3
    6c42:	79a50513          	addi	a0,a0,1946 # a3d8 <malloc+0x23f6>
    6c46:	00001097          	auipc	ra,0x1
    6c4a:	1aa080e7          	jalr	426(ra) # 7df0 <printf>

  unlink("diskfulldir");
    6c4e:	00003517          	auipc	a0,0x3
    6c52:	75a50513          	addi	a0,a0,1882 # a3a8 <malloc+0x23c6>
    6c56:	00001097          	auipc	ra,0x1
    6c5a:	ca2080e7          	jalr	-862(ra) # 78f8 <unlink>

  for(int i = 0; i < nzz; i++){
    6c5e:	fc042e23          	sw	zero,-36(s0)
    6c62:	a8ad                	j	6cdc <diskfull+0x2a6>
    char name[32];
    name[0] = 'z';
    6c64:	07a00793          	li	a5,122
    6c68:	bcf40423          	sb	a5,-1080(s0)
    name[1] = 'z';
    6c6c:	07a00793          	li	a5,122
    6c70:	bcf404a3          	sb	a5,-1079(s0)
    name[2] = '0' + (i / 32);
    6c74:	fdc42783          	lw	a5,-36(s0)
    6c78:	41f7d71b          	sraiw	a4,a5,0x1f
    6c7c:	01b7571b          	srliw	a4,a4,0x1b
    6c80:	9fb9                	addw	a5,a5,a4
    6c82:	4057d79b          	sraiw	a5,a5,0x5
    6c86:	2781                	sext.w	a5,a5
    6c88:	0ff7f793          	zext.b	a5,a5
    6c8c:	0307879b          	addiw	a5,a5,48
    6c90:	0ff7f793          	zext.b	a5,a5
    6c94:	bcf40523          	sb	a5,-1078(s0)
    name[3] = '0' + (i % 32);
    6c98:	fdc42783          	lw	a5,-36(s0)
    6c9c:	873e                	mv	a4,a5
    6c9e:	41f7579b          	sraiw	a5,a4,0x1f
    6ca2:	01b7d79b          	srliw	a5,a5,0x1b
    6ca6:	9f3d                	addw	a4,a4,a5
    6ca8:	8b7d                	andi	a4,a4,31
    6caa:	40f707bb          	subw	a5,a4,a5
    6cae:	2781                	sext.w	a5,a5
    6cb0:	0ff7f793          	zext.b	a5,a5
    6cb4:	0307879b          	addiw	a5,a5,48
    6cb8:	0ff7f793          	zext.b	a5,a5
    6cbc:	bcf405a3          	sb	a5,-1077(s0)
    name[4] = '\0';
    6cc0:	bc040623          	sb	zero,-1076(s0)
    unlink(name);
    6cc4:	bc840793          	addi	a5,s0,-1080
    6cc8:	853e                	mv	a0,a5
    6cca:	00001097          	auipc	ra,0x1
    6cce:	c2e080e7          	jalr	-978(ra) # 78f8 <unlink>
  for(int i = 0; i < nzz; i++){
    6cd2:	fdc42783          	lw	a5,-36(s0)
    6cd6:	2785                	addiw	a5,a5,1
    6cd8:	fcf42e23          	sw	a5,-36(s0)
    6cdc:	fdc42783          	lw	a5,-36(s0)
    6ce0:	873e                	mv	a4,a5
    6ce2:	fd042783          	lw	a5,-48(s0)
    6ce6:	2701                	sext.w	a4,a4
    6ce8:	2781                	sext.w	a5,a5
    6cea:	f6f74de3          	blt	a4,a5,6c64 <diskfull+0x22e>
  }

  for(int i = 0; i < fi; i++){
    6cee:	fc042c23          	sw	zero,-40(s0)
    6cf2:	a0a9                	j	6d3c <diskfull+0x306>
    char name[32];
    name[0] = 'b';
    6cf4:	06200793          	li	a5,98
    6cf8:	bcf40423          	sb	a5,-1080(s0)
    name[1] = 'i';
    6cfc:	06900793          	li	a5,105
    6d00:	bcf404a3          	sb	a5,-1079(s0)
    name[2] = 'g';
    6d04:	06700793          	li	a5,103
    6d08:	bcf40523          	sb	a5,-1078(s0)
    name[3] = '0' + i;
    6d0c:	fd842783          	lw	a5,-40(s0)
    6d10:	0ff7f793          	zext.b	a5,a5
    6d14:	0307879b          	addiw	a5,a5,48
    6d18:	0ff7f793          	zext.b	a5,a5
    6d1c:	bcf405a3          	sb	a5,-1077(s0)
    name[4] = '\0';
    6d20:	bc040623          	sb	zero,-1076(s0)
    unlink(name);
    6d24:	bc840793          	addi	a5,s0,-1080
    6d28:	853e                	mv	a0,a5
    6d2a:	00001097          	auipc	ra,0x1
    6d2e:	bce080e7          	jalr	-1074(ra) # 78f8 <unlink>
  for(int i = 0; i < fi; i++){
    6d32:	fd842783          	lw	a5,-40(s0)
    6d36:	2785                	addiw	a5,a5,1
    6d38:	fcf42c23          	sw	a5,-40(s0)
    6d3c:	fd842783          	lw	a5,-40(s0)
    6d40:	873e                	mv	a4,a5
    6d42:	fec42783          	lw	a5,-20(s0)
    6d46:	2701                	sext.w	a4,a4
    6d48:	2781                	sext.w	a5,a5
    6d4a:	faf745e3          	blt	a4,a5,6cf4 <diskfull+0x2be>
  }
}
    6d4e:	0001                	nop
    6d50:	0001                	nop
    6d52:	46813083          	ld	ra,1128(sp)
    6d56:	46013403          	ld	s0,1120(sp)
    6d5a:	47010113          	addi	sp,sp,1136
    6d5e:	8082                	ret

0000000000006d60 <outofinodes>:

void
outofinodes(char *s)
{
    6d60:	715d                	addi	sp,sp,-80
    6d62:	e486                	sd	ra,72(sp)
    6d64:	e0a2                	sd	s0,64(sp)
    6d66:	0880                	addi	s0,sp,80
    6d68:	faa43c23          	sd	a0,-72(s0)
  int nzz = 32*32;
    6d6c:	40000793          	li	a5,1024
    6d70:	fef42223          	sw	a5,-28(s0)
  for(int i = 0; i < nzz; i++){
    6d74:	fe042623          	sw	zero,-20(s0)
    6d78:	a06d                	j	6e22 <outofinodes+0xc2>
    char name[32];
    name[0] = 'z';
    6d7a:	07a00793          	li	a5,122
    6d7e:	fcf40023          	sb	a5,-64(s0)
    name[1] = 'z';
    6d82:	07a00793          	li	a5,122
    6d86:	fcf400a3          	sb	a5,-63(s0)
    name[2] = '0' + (i / 32);
    6d8a:	fec42783          	lw	a5,-20(s0)
    6d8e:	41f7d71b          	sraiw	a4,a5,0x1f
    6d92:	01b7571b          	srliw	a4,a4,0x1b
    6d96:	9fb9                	addw	a5,a5,a4
    6d98:	4057d79b          	sraiw	a5,a5,0x5
    6d9c:	2781                	sext.w	a5,a5
    6d9e:	0ff7f793          	zext.b	a5,a5
    6da2:	0307879b          	addiw	a5,a5,48
    6da6:	0ff7f793          	zext.b	a5,a5
    6daa:	fcf40123          	sb	a5,-62(s0)
    name[3] = '0' + (i % 32);
    6dae:	fec42783          	lw	a5,-20(s0)
    6db2:	873e                	mv	a4,a5
    6db4:	41f7579b          	sraiw	a5,a4,0x1f
    6db8:	01b7d79b          	srliw	a5,a5,0x1b
    6dbc:	9f3d                	addw	a4,a4,a5
    6dbe:	8b7d                	andi	a4,a4,31
    6dc0:	40f707bb          	subw	a5,a4,a5
    6dc4:	2781                	sext.w	a5,a5
    6dc6:	0ff7f793          	zext.b	a5,a5
    6dca:	0307879b          	addiw	a5,a5,48
    6dce:	0ff7f793          	zext.b	a5,a5
    6dd2:	fcf401a3          	sb	a5,-61(s0)
    name[4] = '\0';
    6dd6:	fc040223          	sb	zero,-60(s0)
    unlink(name);
    6dda:	fc040793          	addi	a5,s0,-64
    6dde:	853e                	mv	a0,a5
    6de0:	00001097          	auipc	ra,0x1
    6de4:	b18080e7          	jalr	-1256(ra) # 78f8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    6de8:	fc040793          	addi	a5,s0,-64
    6dec:	60200593          	li	a1,1538
    6df0:	853e                	mv	a0,a5
    6df2:	00001097          	auipc	ra,0x1
    6df6:	af6080e7          	jalr	-1290(ra) # 78e8 <open>
    6dfa:	87aa                	mv	a5,a0
    6dfc:	fef42023          	sw	a5,-32(s0)
    if(fd < 0){
    6e00:	fe042783          	lw	a5,-32(s0)
    6e04:	2781                	sext.w	a5,a5
    6e06:	0207c863          	bltz	a5,6e36 <outofinodes+0xd6>
      // failure is eventually expected.
      break;
    }
    close(fd);
    6e0a:	fe042783          	lw	a5,-32(s0)
    6e0e:	853e                	mv	a0,a5
    6e10:	00001097          	auipc	ra,0x1
    6e14:	ac0080e7          	jalr	-1344(ra) # 78d0 <close>
  for(int i = 0; i < nzz; i++){
    6e18:	fec42783          	lw	a5,-20(s0)
    6e1c:	2785                	addiw	a5,a5,1
    6e1e:	fef42623          	sw	a5,-20(s0)
    6e22:	fec42783          	lw	a5,-20(s0)
    6e26:	873e                	mv	a4,a5
    6e28:	fe442783          	lw	a5,-28(s0)
    6e2c:	2701                	sext.w	a4,a4
    6e2e:	2781                	sext.w	a5,a5
    6e30:	f4f745e3          	blt	a4,a5,6d7a <outofinodes+0x1a>
    6e34:	a011                	j	6e38 <outofinodes+0xd8>
      break;
    6e36:	0001                	nop
  }

  for(int i = 0; i < nzz; i++){
    6e38:	fe042423          	sw	zero,-24(s0)
    6e3c:	a8ad                	j	6eb6 <outofinodes+0x156>
    char name[32];
    name[0] = 'z';
    6e3e:	07a00793          	li	a5,122
    6e42:	fcf40023          	sb	a5,-64(s0)
    name[1] = 'z';
    6e46:	07a00793          	li	a5,122
    6e4a:	fcf400a3          	sb	a5,-63(s0)
    name[2] = '0' + (i / 32);
    6e4e:	fe842783          	lw	a5,-24(s0)
    6e52:	41f7d71b          	sraiw	a4,a5,0x1f
    6e56:	01b7571b          	srliw	a4,a4,0x1b
    6e5a:	9fb9                	addw	a5,a5,a4
    6e5c:	4057d79b          	sraiw	a5,a5,0x5
    6e60:	2781                	sext.w	a5,a5
    6e62:	0ff7f793          	zext.b	a5,a5
    6e66:	0307879b          	addiw	a5,a5,48
    6e6a:	0ff7f793          	zext.b	a5,a5
    6e6e:	fcf40123          	sb	a5,-62(s0)
    name[3] = '0' + (i % 32);
    6e72:	fe842783          	lw	a5,-24(s0)
    6e76:	873e                	mv	a4,a5
    6e78:	41f7579b          	sraiw	a5,a4,0x1f
    6e7c:	01b7d79b          	srliw	a5,a5,0x1b
    6e80:	9f3d                	addw	a4,a4,a5
    6e82:	8b7d                	andi	a4,a4,31
    6e84:	40f707bb          	subw	a5,a4,a5
    6e88:	2781                	sext.w	a5,a5
    6e8a:	0ff7f793          	zext.b	a5,a5
    6e8e:	0307879b          	addiw	a5,a5,48
    6e92:	0ff7f793          	zext.b	a5,a5
    6e96:	fcf401a3          	sb	a5,-61(s0)
    name[4] = '\0';
    6e9a:	fc040223          	sb	zero,-60(s0)
    unlink(name);
    6e9e:	fc040793          	addi	a5,s0,-64
    6ea2:	853e                	mv	a0,a5
    6ea4:	00001097          	auipc	ra,0x1
    6ea8:	a54080e7          	jalr	-1452(ra) # 78f8 <unlink>
  for(int i = 0; i < nzz; i++){
    6eac:	fe842783          	lw	a5,-24(s0)
    6eb0:	2785                	addiw	a5,a5,1
    6eb2:	fef42423          	sw	a5,-24(s0)
    6eb6:	fe842783          	lw	a5,-24(s0)
    6eba:	873e                	mv	a4,a5
    6ebc:	fe442783          	lw	a5,-28(s0)
    6ec0:	2701                	sext.w	a4,a4
    6ec2:	2781                	sext.w	a5,a5
    6ec4:	f6f74de3          	blt	a4,a5,6e3e <outofinodes+0xde>
  }
}
    6ec8:	0001                	nop
    6eca:	0001                	nop
    6ecc:	60a6                	ld	ra,72(sp)
    6ece:	6406                	ld	s0,64(sp)
    6ed0:	6161                	addi	sp,sp,80
    6ed2:	8082                	ret

0000000000006ed4 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    6ed4:	7179                	addi	sp,sp,-48
    6ed6:	f406                	sd	ra,40(sp)
    6ed8:	f022                	sd	s0,32(sp)
    6eda:	1800                	addi	s0,sp,48
    6edc:	fca43c23          	sd	a0,-40(s0)
    6ee0:	fcb43823          	sd	a1,-48(s0)
  int pid;
  int xstatus;

  printf("test %s: ", s);
    6ee4:	fd043583          	ld	a1,-48(s0)
    6ee8:	00003517          	auipc	a0,0x3
    6eec:	57050513          	addi	a0,a0,1392 # a458 <malloc+0x2476>
    6ef0:	00001097          	auipc	ra,0x1
    6ef4:	f00080e7          	jalr	-256(ra) # 7df0 <printf>
  if((pid = fork()) < 0) {
    6ef8:	00001097          	auipc	ra,0x1
    6efc:	9a8080e7          	jalr	-1624(ra) # 78a0 <fork>
    6f00:	87aa                	mv	a5,a0
    6f02:	fef42623          	sw	a5,-20(s0)
    6f06:	fec42783          	lw	a5,-20(s0)
    6f0a:	2781                	sext.w	a5,a5
    6f0c:	0007df63          	bgez	a5,6f2a <run+0x56>
    printf("runtest: fork error\n");
    6f10:	00003517          	auipc	a0,0x3
    6f14:	55850513          	addi	a0,a0,1368 # a468 <malloc+0x2486>
    6f18:	00001097          	auipc	ra,0x1
    6f1c:	ed8080e7          	jalr	-296(ra) # 7df0 <printf>
    exit(1);
    6f20:	4505                	li	a0,1
    6f22:	00001097          	auipc	ra,0x1
    6f26:	986080e7          	jalr	-1658(ra) # 78a8 <exit>
  }
  if(pid == 0) {
    6f2a:	fec42783          	lw	a5,-20(s0)
    6f2e:	2781                	sext.w	a5,a5
    6f30:	eb99                	bnez	a5,6f46 <run+0x72>
    f(s);
    6f32:	fd843783          	ld	a5,-40(s0)
    6f36:	fd043503          	ld	a0,-48(s0)
    6f3a:	9782                	jalr	a5
    exit(0);
    6f3c:	4501                	li	a0,0
    6f3e:	00001097          	auipc	ra,0x1
    6f42:	96a080e7          	jalr	-1686(ra) # 78a8 <exit>
  } else {
    wait(&xstatus);
    6f46:	fe840793          	addi	a5,s0,-24
    6f4a:	853e                	mv	a0,a5
    6f4c:	00001097          	auipc	ra,0x1
    6f50:	964080e7          	jalr	-1692(ra) # 78b0 <wait>
    if(xstatus != 0) 
    6f54:	fe842783          	lw	a5,-24(s0)
    6f58:	cb91                	beqz	a5,6f6c <run+0x98>
      printf("FAILED\n");
    6f5a:	00003517          	auipc	a0,0x3
    6f5e:	52650513          	addi	a0,a0,1318 # a480 <malloc+0x249e>
    6f62:	00001097          	auipc	ra,0x1
    6f66:	e8e080e7          	jalr	-370(ra) # 7df0 <printf>
    6f6a:	a809                	j	6f7c <run+0xa8>
    else
      printf("OK\n");
    6f6c:	00003517          	auipc	a0,0x3
    6f70:	51c50513          	addi	a0,a0,1308 # a488 <malloc+0x24a6>
    6f74:	00001097          	auipc	ra,0x1
    6f78:	e7c080e7          	jalr	-388(ra) # 7df0 <printf>
    return xstatus == 0;
    6f7c:	fe842783          	lw	a5,-24(s0)
    6f80:	0017b793          	seqz	a5,a5
    6f84:	0ff7f793          	zext.b	a5,a5
    6f88:	2781                	sext.w	a5,a5
  }
}
    6f8a:	853e                	mv	a0,a5
    6f8c:	70a2                	ld	ra,40(sp)
    6f8e:	7402                	ld	s0,32(sp)
    6f90:	6145                	addi	sp,sp,48
    6f92:	8082                	ret

0000000000006f94 <runtests>:

int
runtests(struct test *tests, char *justone) {
    6f94:	7179                	addi	sp,sp,-48
    6f96:	f406                	sd	ra,40(sp)
    6f98:	f022                	sd	s0,32(sp)
    6f9a:	1800                	addi	s0,sp,48
    6f9c:	fca43c23          	sd	a0,-40(s0)
    6fa0:	fcb43823          	sd	a1,-48(s0)
  for (struct test *t = tests; t->s != 0; t++) {
    6fa4:	fd843783          	ld	a5,-40(s0)
    6fa8:	fef43423          	sd	a5,-24(s0)
    6fac:	a8a9                	j	7006 <runtests+0x72>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    6fae:	fd043783          	ld	a5,-48(s0)
    6fb2:	cf89                	beqz	a5,6fcc <runtests+0x38>
    6fb4:	fe843783          	ld	a5,-24(s0)
    6fb8:	679c                	ld	a5,8(a5)
    6fba:	fd043583          	ld	a1,-48(s0)
    6fbe:	853e                	mv	a0,a5
    6fc0:	00000097          	auipc	ra,0x0
    6fc4:	4a0080e7          	jalr	1184(ra) # 7460 <strcmp>
    6fc8:	87aa                	mv	a5,a0
    6fca:	eb8d                	bnez	a5,6ffc <runtests+0x68>
      if(!run(t->f, t->s)){
    6fcc:	fe843783          	ld	a5,-24(s0)
    6fd0:	6398                	ld	a4,0(a5)
    6fd2:	fe843783          	ld	a5,-24(s0)
    6fd6:	679c                	ld	a5,8(a5)
    6fd8:	85be                	mv	a1,a5
    6fda:	853a                	mv	a0,a4
    6fdc:	00000097          	auipc	ra,0x0
    6fe0:	ef8080e7          	jalr	-264(ra) # 6ed4 <run>
    6fe4:	87aa                	mv	a5,a0
    6fe6:	eb99                	bnez	a5,6ffc <runtests+0x68>
        printf("SOME TESTS FAILED\n");
    6fe8:	00003517          	auipc	a0,0x3
    6fec:	4a850513          	addi	a0,a0,1192 # a490 <malloc+0x24ae>
    6ff0:	00001097          	auipc	ra,0x1
    6ff4:	e00080e7          	jalr	-512(ra) # 7df0 <printf>
        return 1;
    6ff8:	4785                	li	a5,1
    6ffa:	a819                	j	7010 <runtests+0x7c>
  for (struct test *t = tests; t->s != 0; t++) {
    6ffc:	fe843783          	ld	a5,-24(s0)
    7000:	07c1                	addi	a5,a5,16
    7002:	fef43423          	sd	a5,-24(s0)
    7006:	fe843783          	ld	a5,-24(s0)
    700a:	679c                	ld	a5,8(a5)
    700c:	f3cd                	bnez	a5,6fae <runtests+0x1a>
      }
    }
  }
  return 0;
    700e:	4781                	li	a5,0
}
    7010:	853e                	mv	a0,a5
    7012:	70a2                	ld	ra,40(sp)
    7014:	7402                	ld	s0,32(sp)
    7016:	6145                	addi	sp,sp,48
    7018:	8082                	ret

000000000000701a <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    701a:	7139                	addi	sp,sp,-64
    701c:	fc06                	sd	ra,56(sp)
    701e:	f822                	sd	s0,48(sp)
    7020:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    7022:	fd040793          	addi	a5,s0,-48
    7026:	853e                	mv	a0,a5
    7028:	00001097          	auipc	ra,0x1
    702c:	890080e7          	jalr	-1904(ra) # 78b8 <pipe>
    7030:	87aa                	mv	a5,a0
    7032:	0007df63          	bgez	a5,7050 <countfree+0x36>
    printf("pipe() failed in countfree()\n");
    7036:	00003517          	auipc	a0,0x3
    703a:	47250513          	addi	a0,a0,1138 # a4a8 <malloc+0x24c6>
    703e:	00001097          	auipc	ra,0x1
    7042:	db2080e7          	jalr	-590(ra) # 7df0 <printf>
    exit(1);
    7046:	4505                	li	a0,1
    7048:	00001097          	auipc	ra,0x1
    704c:	860080e7          	jalr	-1952(ra) # 78a8 <exit>
  }
  
  int pid = fork();
    7050:	00001097          	auipc	ra,0x1
    7054:	850080e7          	jalr	-1968(ra) # 78a0 <fork>
    7058:	87aa                	mv	a5,a0
    705a:	fef42423          	sw	a5,-24(s0)

  if(pid < 0){
    705e:	fe842783          	lw	a5,-24(s0)
    7062:	2781                	sext.w	a5,a5
    7064:	0007df63          	bgez	a5,7082 <countfree+0x68>
    printf("fork failed in countfree()\n");
    7068:	00003517          	auipc	a0,0x3
    706c:	46050513          	addi	a0,a0,1120 # a4c8 <malloc+0x24e6>
    7070:	00001097          	auipc	ra,0x1
    7074:	d80080e7          	jalr	-640(ra) # 7df0 <printf>
    exit(1);
    7078:	4505                	li	a0,1
    707a:	00001097          	auipc	ra,0x1
    707e:	82e080e7          	jalr	-2002(ra) # 78a8 <exit>
  }

  if(pid == 0){
    7082:	fe842783          	lw	a5,-24(s0)
    7086:	2781                	sext.w	a5,a5
    7088:	e3d1                	bnez	a5,710c <countfree+0xf2>
    close(fds[0]);
    708a:	fd042783          	lw	a5,-48(s0)
    708e:	853e                	mv	a0,a5
    7090:	00001097          	auipc	ra,0x1
    7094:	840080e7          	jalr	-1984(ra) # 78d0 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
    7098:	6505                	lui	a0,0x1
    709a:	00001097          	auipc	ra,0x1
    709e:	896080e7          	jalr	-1898(ra) # 7930 <sbrk>
    70a2:	87aa                	mv	a5,a0
    70a4:	fcf43c23          	sd	a5,-40(s0)
      if(a == 0xffffffffffffffff){
    70a8:	fd843703          	ld	a4,-40(s0)
    70ac:	57fd                	li	a5,-1
    70ae:	04f70963          	beq	a4,a5,7100 <countfree+0xe6>
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    70b2:	fd843703          	ld	a4,-40(s0)
    70b6:	6785                	lui	a5,0x1
    70b8:	17fd                	addi	a5,a5,-1 # fff <truncate3+0x1b1>
    70ba:	97ba                	add	a5,a5,a4
    70bc:	873e                	mv	a4,a5
    70be:	4785                	li	a5,1
    70c0:	00f70023          	sb	a5,0(a4)

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    70c4:	fd442783          	lw	a5,-44(s0)
    70c8:	4605                	li	a2,1
    70ca:	00001597          	auipc	a1,0x1
    70ce:	16658593          	addi	a1,a1,358 # 8230 <malloc+0x24e>
    70d2:	853e                	mv	a0,a5
    70d4:	00000097          	auipc	ra,0x0
    70d8:	7f4080e7          	jalr	2036(ra) # 78c8 <write>
    70dc:	87aa                	mv	a5,a0
    70de:	873e                	mv	a4,a5
    70e0:	4785                	li	a5,1
    70e2:	faf70be3          	beq	a4,a5,7098 <countfree+0x7e>
        printf("write() failed in countfree()\n");
    70e6:	00003517          	auipc	a0,0x3
    70ea:	40250513          	addi	a0,a0,1026 # a4e8 <malloc+0x2506>
    70ee:	00001097          	auipc	ra,0x1
    70f2:	d02080e7          	jalr	-766(ra) # 7df0 <printf>
        exit(1);
    70f6:	4505                	li	a0,1
    70f8:	00000097          	auipc	ra,0x0
    70fc:	7b0080e7          	jalr	1968(ra) # 78a8 <exit>
        break;
    7100:	0001                	nop
      }
    }

    exit(0);
    7102:	4501                	li	a0,0
    7104:	00000097          	auipc	ra,0x0
    7108:	7a4080e7          	jalr	1956(ra) # 78a8 <exit>
  }

  close(fds[1]);
    710c:	fd442783          	lw	a5,-44(s0)
    7110:	853e                	mv	a0,a5
    7112:	00000097          	auipc	ra,0x0
    7116:	7be080e7          	jalr	1982(ra) # 78d0 <close>

  int n = 0;
    711a:	fe042623          	sw	zero,-20(s0)
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    711e:	fd042783          	lw	a5,-48(s0)
    7122:	fcf40713          	addi	a4,s0,-49
    7126:	4605                	li	a2,1
    7128:	85ba                	mv	a1,a4
    712a:	853e                	mv	a0,a5
    712c:	00000097          	auipc	ra,0x0
    7130:	794080e7          	jalr	1940(ra) # 78c0 <read>
    7134:	87aa                	mv	a5,a0
    7136:	fef42223          	sw	a5,-28(s0)
    if(cc < 0){
    713a:	fe442783          	lw	a5,-28(s0)
    713e:	2781                	sext.w	a5,a5
    7140:	0007df63          	bgez	a5,715e <countfree+0x144>
      printf("read() failed in countfree()\n");
    7144:	00003517          	auipc	a0,0x3
    7148:	3c450513          	addi	a0,a0,964 # a508 <malloc+0x2526>
    714c:	00001097          	auipc	ra,0x1
    7150:	ca4080e7          	jalr	-860(ra) # 7df0 <printf>
      exit(1);
    7154:	4505                	li	a0,1
    7156:	00000097          	auipc	ra,0x0
    715a:	752080e7          	jalr	1874(ra) # 78a8 <exit>
    }
    if(cc == 0)
    715e:	fe442783          	lw	a5,-28(s0)
    7162:	2781                	sext.w	a5,a5
    7164:	e385                	bnez	a5,7184 <countfree+0x16a>
      break;
    n += 1;
  }

  close(fds[0]);
    7166:	fd042783          	lw	a5,-48(s0)
    716a:	853e                	mv	a0,a5
    716c:	00000097          	auipc	ra,0x0
    7170:	764080e7          	jalr	1892(ra) # 78d0 <close>
  wait((int*)0);
    7174:	4501                	li	a0,0
    7176:	00000097          	auipc	ra,0x0
    717a:	73a080e7          	jalr	1850(ra) # 78b0 <wait>
  
  return n;
    717e:	fec42783          	lw	a5,-20(s0)
    7182:	a039                	j	7190 <countfree+0x176>
    n += 1;
    7184:	fec42783          	lw	a5,-20(s0)
    7188:	2785                	addiw	a5,a5,1
    718a:	fef42623          	sw	a5,-20(s0)
  while(1){
    718e:	bf41                	j	711e <countfree+0x104>
}
    7190:	853e                	mv	a0,a5
    7192:	70e2                	ld	ra,56(sp)
    7194:	7442                	ld	s0,48(sp)
    7196:	6121                	addi	sp,sp,64
    7198:	8082                	ret

000000000000719a <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    719a:	7179                	addi	sp,sp,-48
    719c:	f406                	sd	ra,40(sp)
    719e:	f022                	sd	s0,32(sp)
    71a0:	1800                	addi	s0,sp,48
    71a2:	87aa                	mv	a5,a0
    71a4:	872e                	mv	a4,a1
    71a6:	fcc43823          	sd	a2,-48(s0)
    71aa:	fcf42e23          	sw	a5,-36(s0)
    71ae:	87ba                	mv	a5,a4
    71b0:	fcf42c23          	sw	a5,-40(s0)
  do {
    printf("usertests starting\n");
    71b4:	00003517          	auipc	a0,0x3
    71b8:	37450513          	addi	a0,a0,884 # a528 <malloc+0x2546>
    71bc:	00001097          	auipc	ra,0x1
    71c0:	c34080e7          	jalr	-972(ra) # 7df0 <printf>
    int free0 = countfree();
    71c4:	00000097          	auipc	ra,0x0
    71c8:	e56080e7          	jalr	-426(ra) # 701a <countfree>
    71cc:	87aa                	mv	a5,a0
    71ce:	fef42623          	sw	a5,-20(s0)
    int free1 = 0;
    71d2:	fe042423          	sw	zero,-24(s0)
    if (runtests(quicktests, justone)) {
    71d6:	fd043583          	ld	a1,-48(s0)
    71da:	00004517          	auipc	a0,0x4
    71de:	e3650513          	addi	a0,a0,-458 # b010 <quicktests>
    71e2:	00000097          	auipc	ra,0x0
    71e6:	db2080e7          	jalr	-590(ra) # 6f94 <runtests>
    71ea:	87aa                	mv	a5,a0
    71ec:	cb91                	beqz	a5,7200 <drivetests+0x66>
      if(continuous != 2) {
    71ee:	fd842783          	lw	a5,-40(s0)
    71f2:	0007871b          	sext.w	a4,a5
    71f6:	4789                	li	a5,2
    71f8:	00f70463          	beq	a4,a5,7200 <drivetests+0x66>
        return 1;
    71fc:	4785                	li	a5,1
    71fe:	a04d                	j	72a0 <drivetests+0x106>
      }
    }
    if(!quick) {
    7200:	fdc42783          	lw	a5,-36(s0)
    7204:	2781                	sext.w	a5,a5
    7206:	e3a9                	bnez	a5,7248 <drivetests+0xae>
      if (justone == 0)
    7208:	fd043783          	ld	a5,-48(s0)
    720c:	eb89                	bnez	a5,721e <drivetests+0x84>
        printf("usertests slow tests starting\n");
    720e:	00003517          	auipc	a0,0x3
    7212:	33250513          	addi	a0,a0,818 # a540 <malloc+0x255e>
    7216:	00001097          	auipc	ra,0x1
    721a:	bda080e7          	jalr	-1062(ra) # 7df0 <printf>
      if (runtests(slowtests, justone)) {
    721e:	fd043583          	ld	a1,-48(s0)
    7222:	00004517          	auipc	a0,0x4
    7226:	1be50513          	addi	a0,a0,446 # b3e0 <slowtests>
    722a:	00000097          	auipc	ra,0x0
    722e:	d6a080e7          	jalr	-662(ra) # 6f94 <runtests>
    7232:	87aa                	mv	a5,a0
    7234:	cb91                	beqz	a5,7248 <drivetests+0xae>
        if(continuous != 2) {
    7236:	fd842783          	lw	a5,-40(s0)
    723a:	0007871b          	sext.w	a4,a5
    723e:	4789                	li	a5,2
    7240:	00f70463          	beq	a4,a5,7248 <drivetests+0xae>
          return 1;
    7244:	4785                	li	a5,1
    7246:	a8a9                	j	72a0 <drivetests+0x106>
        }
      }
    }
    if((free1 = countfree()) < free0) {
    7248:	00000097          	auipc	ra,0x0
    724c:	dd2080e7          	jalr	-558(ra) # 701a <countfree>
    7250:	87aa                	mv	a5,a0
    7252:	fef42423          	sw	a5,-24(s0)
    7256:	fe842783          	lw	a5,-24(s0)
    725a:	873e                	mv	a4,a5
    725c:	fec42783          	lw	a5,-20(s0)
    7260:	2701                	sext.w	a4,a4
    7262:	2781                	sext.w	a5,a5
    7264:	02f75963          	bge	a4,a5,7296 <drivetests+0xfc>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    7268:	fec42703          	lw	a4,-20(s0)
    726c:	fe842783          	lw	a5,-24(s0)
    7270:	863a                	mv	a2,a4
    7272:	85be                	mv	a1,a5
    7274:	00003517          	auipc	a0,0x3
    7278:	2ec50513          	addi	a0,a0,748 # a560 <malloc+0x257e>
    727c:	00001097          	auipc	ra,0x1
    7280:	b74080e7          	jalr	-1164(ra) # 7df0 <printf>
      if(continuous != 2) {
    7284:	fd842783          	lw	a5,-40(s0)
    7288:	0007871b          	sext.w	a4,a5
    728c:	4789                	li	a5,2
    728e:	00f70463          	beq	a4,a5,7296 <drivetests+0xfc>
        return 1;
    7292:	4785                	li	a5,1
    7294:	a031                	j	72a0 <drivetests+0x106>
      }
    }
  } while(continuous);
    7296:	fd842783          	lw	a5,-40(s0)
    729a:	2781                	sext.w	a5,a5
    729c:	ff81                	bnez	a5,71b4 <drivetests+0x1a>
  return 0;
    729e:	4781                	li	a5,0
}
    72a0:	853e                	mv	a0,a5
    72a2:	70a2                	ld	ra,40(sp)
    72a4:	7402                	ld	s0,32(sp)
    72a6:	6145                	addi	sp,sp,48
    72a8:	8082                	ret

00000000000072aa <main>:

int
main(int argc, char *argv[])
{
    72aa:	7179                	addi	sp,sp,-48
    72ac:	f406                	sd	ra,40(sp)
    72ae:	f022                	sd	s0,32(sp)
    72b0:	1800                	addi	s0,sp,48
    72b2:	87aa                	mv	a5,a0
    72b4:	fcb43823          	sd	a1,-48(s0)
    72b8:	fcf42e23          	sw	a5,-36(s0)
  int continuous = 0;
    72bc:	fe042623          	sw	zero,-20(s0)
  int quick = 0;
    72c0:	fe042423          	sw	zero,-24(s0)
  char *justone = 0;
    72c4:	fe043023          	sd	zero,-32(s0)

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    72c8:	fdc42783          	lw	a5,-36(s0)
    72cc:	0007871b          	sext.w	a4,a5
    72d0:	4789                	li	a5,2
    72d2:	02f71563          	bne	a4,a5,72fc <main+0x52>
    72d6:	fd043783          	ld	a5,-48(s0)
    72da:	07a1                	addi	a5,a5,8
    72dc:	639c                	ld	a5,0(a5)
    72de:	00003597          	auipc	a1,0x3
    72e2:	2b258593          	addi	a1,a1,690 # a590 <malloc+0x25ae>
    72e6:	853e                	mv	a0,a5
    72e8:	00000097          	auipc	ra,0x0
    72ec:	178080e7          	jalr	376(ra) # 7460 <strcmp>
    72f0:	87aa                	mv	a5,a0
    72f2:	e789                	bnez	a5,72fc <main+0x52>
    quick = 1;
    72f4:	4785                	li	a5,1
    72f6:	fef42423          	sw	a5,-24(s0)
    72fa:	a0c9                	j	73bc <main+0x112>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    72fc:	fdc42783          	lw	a5,-36(s0)
    7300:	0007871b          	sext.w	a4,a5
    7304:	4789                	li	a5,2
    7306:	02f71563          	bne	a4,a5,7330 <main+0x86>
    730a:	fd043783          	ld	a5,-48(s0)
    730e:	07a1                	addi	a5,a5,8
    7310:	639c                	ld	a5,0(a5)
    7312:	00003597          	auipc	a1,0x3
    7316:	28658593          	addi	a1,a1,646 # a598 <malloc+0x25b6>
    731a:	853e                	mv	a0,a5
    731c:	00000097          	auipc	ra,0x0
    7320:	144080e7          	jalr	324(ra) # 7460 <strcmp>
    7324:	87aa                	mv	a5,a0
    7326:	e789                	bnez	a5,7330 <main+0x86>
    continuous = 1;
    7328:	4785                	li	a5,1
    732a:	fef42623          	sw	a5,-20(s0)
    732e:	a079                	j	73bc <main+0x112>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    7330:	fdc42783          	lw	a5,-36(s0)
    7334:	0007871b          	sext.w	a4,a5
    7338:	4789                	li	a5,2
    733a:	02f71563          	bne	a4,a5,7364 <main+0xba>
    733e:	fd043783          	ld	a5,-48(s0)
    7342:	07a1                	addi	a5,a5,8
    7344:	639c                	ld	a5,0(a5)
    7346:	00003597          	auipc	a1,0x3
    734a:	25a58593          	addi	a1,a1,602 # a5a0 <malloc+0x25be>
    734e:	853e                	mv	a0,a5
    7350:	00000097          	auipc	ra,0x0
    7354:	110080e7          	jalr	272(ra) # 7460 <strcmp>
    7358:	87aa                	mv	a5,a0
    735a:	e789                	bnez	a5,7364 <main+0xba>
    continuous = 2;
    735c:	4789                	li	a5,2
    735e:	fef42623          	sw	a5,-20(s0)
    7362:	a8a9                	j	73bc <main+0x112>
  } else if(argc == 2 && argv[1][0] != '-'){
    7364:	fdc42783          	lw	a5,-36(s0)
    7368:	0007871b          	sext.w	a4,a5
    736c:	4789                	li	a5,2
    736e:	02f71363          	bne	a4,a5,7394 <main+0xea>
    7372:	fd043783          	ld	a5,-48(s0)
    7376:	07a1                	addi	a5,a5,8
    7378:	639c                	ld	a5,0(a5)
    737a:	0007c783          	lbu	a5,0(a5)
    737e:	873e                	mv	a4,a5
    7380:	02d00793          	li	a5,45
    7384:	00f70863          	beq	a4,a5,7394 <main+0xea>
    justone = argv[1];
    7388:	fd043783          	ld	a5,-48(s0)
    738c:	679c                	ld	a5,8(a5)
    738e:	fef43023          	sd	a5,-32(s0)
    7392:	a02d                	j	73bc <main+0x112>
  } else if(argc > 1){
    7394:	fdc42783          	lw	a5,-36(s0)
    7398:	0007871b          	sext.w	a4,a5
    739c:	4785                	li	a5,1
    739e:	00e7df63          	bge	a5,a4,73bc <main+0x112>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    73a2:	00003517          	auipc	a0,0x3
    73a6:	20650513          	addi	a0,a0,518 # a5a8 <malloc+0x25c6>
    73aa:	00001097          	auipc	ra,0x1
    73ae:	a46080e7          	jalr	-1466(ra) # 7df0 <printf>
    exit(1);
    73b2:	4505                	li	a0,1
    73b4:	00000097          	auipc	ra,0x0
    73b8:	4f4080e7          	jalr	1268(ra) # 78a8 <exit>
  }
  if (drivetests(quick, continuous, justone)) {
    73bc:	fec42703          	lw	a4,-20(s0)
    73c0:	fe842783          	lw	a5,-24(s0)
    73c4:	fe043603          	ld	a2,-32(s0)
    73c8:	85ba                	mv	a1,a4
    73ca:	853e                	mv	a0,a5
    73cc:	00000097          	auipc	ra,0x0
    73d0:	dce080e7          	jalr	-562(ra) # 719a <drivetests>
    73d4:	87aa                	mv	a5,a0
    73d6:	c791                	beqz	a5,73e2 <main+0x138>
    exit(1);
    73d8:	4505                	li	a0,1
    73da:	00000097          	auipc	ra,0x0
    73de:	4ce080e7          	jalr	1230(ra) # 78a8 <exit>
  }
  printf("ALL TESTS PASSED\n");
    73e2:	00003517          	auipc	a0,0x3
    73e6:	1f650513          	addi	a0,a0,502 # a5d8 <malloc+0x25f6>
    73ea:	00001097          	auipc	ra,0x1
    73ee:	a06080e7          	jalr	-1530(ra) # 7df0 <printf>
  exit(0);
    73f2:	4501                	li	a0,0
    73f4:	00000097          	auipc	ra,0x0
    73f8:	4b4080e7          	jalr	1204(ra) # 78a8 <exit>

00000000000073fc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    73fc:	1141                	addi	sp,sp,-16
    73fe:	e406                	sd	ra,8(sp)
    7400:	e022                	sd	s0,0(sp)
    7402:	0800                	addi	s0,sp,16
  extern int main();
  main();
    7404:	00000097          	auipc	ra,0x0
    7408:	ea6080e7          	jalr	-346(ra) # 72aa <main>
  exit(0);
    740c:	4501                	li	a0,0
    740e:	00000097          	auipc	ra,0x0
    7412:	49a080e7          	jalr	1178(ra) # 78a8 <exit>

0000000000007416 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    7416:	7179                	addi	sp,sp,-48
    7418:	f422                	sd	s0,40(sp)
    741a:	1800                	addi	s0,sp,48
    741c:	fca43c23          	sd	a0,-40(s0)
    7420:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
    7424:	fd843783          	ld	a5,-40(s0)
    7428:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
    742c:	0001                	nop
    742e:	fd043703          	ld	a4,-48(s0)
    7432:	00170793          	addi	a5,a4,1
    7436:	fcf43823          	sd	a5,-48(s0)
    743a:	fd843783          	ld	a5,-40(s0)
    743e:	00178693          	addi	a3,a5,1
    7442:	fcd43c23          	sd	a3,-40(s0)
    7446:	00074703          	lbu	a4,0(a4)
    744a:	00e78023          	sb	a4,0(a5)
    744e:	0007c783          	lbu	a5,0(a5)
    7452:	fff1                	bnez	a5,742e <strcpy+0x18>
    ;
  return os;
    7454:	fe843783          	ld	a5,-24(s0)
}
    7458:	853e                	mv	a0,a5
    745a:	7422                	ld	s0,40(sp)
    745c:	6145                	addi	sp,sp,48
    745e:	8082                	ret

0000000000007460 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    7460:	1101                	addi	sp,sp,-32
    7462:	ec22                	sd	s0,24(sp)
    7464:	1000                	addi	s0,sp,32
    7466:	fea43423          	sd	a0,-24(s0)
    746a:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
    746e:	a819                	j	7484 <strcmp+0x24>
    p++, q++;
    7470:	fe843783          	ld	a5,-24(s0)
    7474:	0785                	addi	a5,a5,1
    7476:	fef43423          	sd	a5,-24(s0)
    747a:	fe043783          	ld	a5,-32(s0)
    747e:	0785                	addi	a5,a5,1
    7480:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
    7484:	fe843783          	ld	a5,-24(s0)
    7488:	0007c783          	lbu	a5,0(a5)
    748c:	cb99                	beqz	a5,74a2 <strcmp+0x42>
    748e:	fe843783          	ld	a5,-24(s0)
    7492:	0007c703          	lbu	a4,0(a5)
    7496:	fe043783          	ld	a5,-32(s0)
    749a:	0007c783          	lbu	a5,0(a5)
    749e:	fcf709e3          	beq	a4,a5,7470 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
    74a2:	fe843783          	ld	a5,-24(s0)
    74a6:	0007c783          	lbu	a5,0(a5)
    74aa:	0007871b          	sext.w	a4,a5
    74ae:	fe043783          	ld	a5,-32(s0)
    74b2:	0007c783          	lbu	a5,0(a5)
    74b6:	2781                	sext.w	a5,a5
    74b8:	40f707bb          	subw	a5,a4,a5
    74bc:	2781                	sext.w	a5,a5
}
    74be:	853e                	mv	a0,a5
    74c0:	6462                	ld	s0,24(sp)
    74c2:	6105                	addi	sp,sp,32
    74c4:	8082                	ret

00000000000074c6 <strlen>:

uint
strlen(const char *s)
{
    74c6:	7179                	addi	sp,sp,-48
    74c8:	f422                	sd	s0,40(sp)
    74ca:	1800                	addi	s0,sp,48
    74cc:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
    74d0:	fe042623          	sw	zero,-20(s0)
    74d4:	a031                	j	74e0 <strlen+0x1a>
    74d6:	fec42783          	lw	a5,-20(s0)
    74da:	2785                	addiw	a5,a5,1
    74dc:	fef42623          	sw	a5,-20(s0)
    74e0:	fec42783          	lw	a5,-20(s0)
    74e4:	fd843703          	ld	a4,-40(s0)
    74e8:	97ba                	add	a5,a5,a4
    74ea:	0007c783          	lbu	a5,0(a5)
    74ee:	f7e5                	bnez	a5,74d6 <strlen+0x10>
    ;
  return n;
    74f0:	fec42783          	lw	a5,-20(s0)
}
    74f4:	853e                	mv	a0,a5
    74f6:	7422                	ld	s0,40(sp)
    74f8:	6145                	addi	sp,sp,48
    74fa:	8082                	ret

00000000000074fc <memset>:

void*
memset(void *dst, int c, uint n)
{
    74fc:	7179                	addi	sp,sp,-48
    74fe:	f422                	sd	s0,40(sp)
    7500:	1800                	addi	s0,sp,48
    7502:	fca43c23          	sd	a0,-40(s0)
    7506:	87ae                	mv	a5,a1
    7508:	8732                	mv	a4,a2
    750a:	fcf42a23          	sw	a5,-44(s0)
    750e:	87ba                	mv	a5,a4
    7510:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
    7514:	fd843783          	ld	a5,-40(s0)
    7518:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
    751c:	fe042623          	sw	zero,-20(s0)
    7520:	a00d                	j	7542 <memset+0x46>
    cdst[i] = c;
    7522:	fec42783          	lw	a5,-20(s0)
    7526:	fe043703          	ld	a4,-32(s0)
    752a:	97ba                	add	a5,a5,a4
    752c:	fd442703          	lw	a4,-44(s0)
    7530:	0ff77713          	zext.b	a4,a4
    7534:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
    7538:	fec42783          	lw	a5,-20(s0)
    753c:	2785                	addiw	a5,a5,1
    753e:	fef42623          	sw	a5,-20(s0)
    7542:	fec42703          	lw	a4,-20(s0)
    7546:	fd042783          	lw	a5,-48(s0)
    754a:	2781                	sext.w	a5,a5
    754c:	fcf76be3          	bltu	a4,a5,7522 <memset+0x26>
  }
  return dst;
    7550:	fd843783          	ld	a5,-40(s0)
}
    7554:	853e                	mv	a0,a5
    7556:	7422                	ld	s0,40(sp)
    7558:	6145                	addi	sp,sp,48
    755a:	8082                	ret

000000000000755c <strchr>:

char*
strchr(const char *s, char c)
{
    755c:	1101                	addi	sp,sp,-32
    755e:	ec22                	sd	s0,24(sp)
    7560:	1000                	addi	s0,sp,32
    7562:	fea43423          	sd	a0,-24(s0)
    7566:	87ae                	mv	a5,a1
    7568:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
    756c:	a01d                	j	7592 <strchr+0x36>
    if(*s == c)
    756e:	fe843783          	ld	a5,-24(s0)
    7572:	0007c703          	lbu	a4,0(a5)
    7576:	fe744783          	lbu	a5,-25(s0)
    757a:	0ff7f793          	zext.b	a5,a5
    757e:	00e79563          	bne	a5,a4,7588 <strchr+0x2c>
      return (char*)s;
    7582:	fe843783          	ld	a5,-24(s0)
    7586:	a821                	j	759e <strchr+0x42>
  for(; *s; s++)
    7588:	fe843783          	ld	a5,-24(s0)
    758c:	0785                	addi	a5,a5,1
    758e:	fef43423          	sd	a5,-24(s0)
    7592:	fe843783          	ld	a5,-24(s0)
    7596:	0007c783          	lbu	a5,0(a5)
    759a:	fbf1                	bnez	a5,756e <strchr+0x12>
  return 0;
    759c:	4781                	li	a5,0
}
    759e:	853e                	mv	a0,a5
    75a0:	6462                	ld	s0,24(sp)
    75a2:	6105                	addi	sp,sp,32
    75a4:	8082                	ret

00000000000075a6 <gets>:

char*
gets(char *buf, int max)
{
    75a6:	7179                	addi	sp,sp,-48
    75a8:	f406                	sd	ra,40(sp)
    75aa:	f022                	sd	s0,32(sp)
    75ac:	1800                	addi	s0,sp,48
    75ae:	fca43c23          	sd	a0,-40(s0)
    75b2:	87ae                	mv	a5,a1
    75b4:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    75b8:	fe042623          	sw	zero,-20(s0)
    75bc:	a8a1                	j	7614 <gets+0x6e>
    cc = read(0, &c, 1);
    75be:	fe740793          	addi	a5,s0,-25
    75c2:	4605                	li	a2,1
    75c4:	85be                	mv	a1,a5
    75c6:	4501                	li	a0,0
    75c8:	00000097          	auipc	ra,0x0
    75cc:	2f8080e7          	jalr	760(ra) # 78c0 <read>
    75d0:	87aa                	mv	a5,a0
    75d2:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
    75d6:	fe842783          	lw	a5,-24(s0)
    75da:	2781                	sext.w	a5,a5
    75dc:	04f05763          	blez	a5,762a <gets+0x84>
      break;
    buf[i++] = c;
    75e0:	fec42783          	lw	a5,-20(s0)
    75e4:	0017871b          	addiw	a4,a5,1
    75e8:	fee42623          	sw	a4,-20(s0)
    75ec:	873e                	mv	a4,a5
    75ee:	fd843783          	ld	a5,-40(s0)
    75f2:	97ba                	add	a5,a5,a4
    75f4:	fe744703          	lbu	a4,-25(s0)
    75f8:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
    75fc:	fe744783          	lbu	a5,-25(s0)
    7600:	873e                	mv	a4,a5
    7602:	47a9                	li	a5,10
    7604:	02f70463          	beq	a4,a5,762c <gets+0x86>
    7608:	fe744783          	lbu	a5,-25(s0)
    760c:	873e                	mv	a4,a5
    760e:	47b5                	li	a5,13
    7610:	00f70e63          	beq	a4,a5,762c <gets+0x86>
  for(i=0; i+1 < max; ){
    7614:	fec42783          	lw	a5,-20(s0)
    7618:	2785                	addiw	a5,a5,1
    761a:	0007871b          	sext.w	a4,a5
    761e:	fd442783          	lw	a5,-44(s0)
    7622:	2781                	sext.w	a5,a5
    7624:	f8f74de3          	blt	a4,a5,75be <gets+0x18>
    7628:	a011                	j	762c <gets+0x86>
      break;
    762a:	0001                	nop
      break;
  }
  buf[i] = '\0';
    762c:	fec42783          	lw	a5,-20(s0)
    7630:	fd843703          	ld	a4,-40(s0)
    7634:	97ba                	add	a5,a5,a4
    7636:	00078023          	sb	zero,0(a5)
  return buf;
    763a:	fd843783          	ld	a5,-40(s0)
}
    763e:	853e                	mv	a0,a5
    7640:	70a2                	ld	ra,40(sp)
    7642:	7402                	ld	s0,32(sp)
    7644:	6145                	addi	sp,sp,48
    7646:	8082                	ret

0000000000007648 <stat>:

int
stat(const char *n, struct stat *st)
{
    7648:	7179                	addi	sp,sp,-48
    764a:	f406                	sd	ra,40(sp)
    764c:	f022                	sd	s0,32(sp)
    764e:	1800                	addi	s0,sp,48
    7650:	fca43c23          	sd	a0,-40(s0)
    7654:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    7658:	4581                	li	a1,0
    765a:	fd843503          	ld	a0,-40(s0)
    765e:	00000097          	auipc	ra,0x0
    7662:	28a080e7          	jalr	650(ra) # 78e8 <open>
    7666:	87aa                	mv	a5,a0
    7668:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
    766c:	fec42783          	lw	a5,-20(s0)
    7670:	2781                	sext.w	a5,a5
    7672:	0007d463          	bgez	a5,767a <stat+0x32>
    return -1;
    7676:	57fd                	li	a5,-1
    7678:	a035                	j	76a4 <stat+0x5c>
  r = fstat(fd, st);
    767a:	fec42783          	lw	a5,-20(s0)
    767e:	fd043583          	ld	a1,-48(s0)
    7682:	853e                	mv	a0,a5
    7684:	00000097          	auipc	ra,0x0
    7688:	27c080e7          	jalr	636(ra) # 7900 <fstat>
    768c:	87aa                	mv	a5,a0
    768e:	fef42423          	sw	a5,-24(s0)
  close(fd);
    7692:	fec42783          	lw	a5,-20(s0)
    7696:	853e                	mv	a0,a5
    7698:	00000097          	auipc	ra,0x0
    769c:	238080e7          	jalr	568(ra) # 78d0 <close>
  return r;
    76a0:	fe842783          	lw	a5,-24(s0)
}
    76a4:	853e                	mv	a0,a5
    76a6:	70a2                	ld	ra,40(sp)
    76a8:	7402                	ld	s0,32(sp)
    76aa:	6145                	addi	sp,sp,48
    76ac:	8082                	ret

00000000000076ae <atoi>:

int
atoi(const char *s)
{
    76ae:	7179                	addi	sp,sp,-48
    76b0:	f422                	sd	s0,40(sp)
    76b2:	1800                	addi	s0,sp,48
    76b4:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
    76b8:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
    76bc:	a81d                	j	76f2 <atoi+0x44>
    n = n*10 + *s++ - '0';
    76be:	fec42783          	lw	a5,-20(s0)
    76c2:	873e                	mv	a4,a5
    76c4:	87ba                	mv	a5,a4
    76c6:	0027979b          	slliw	a5,a5,0x2
    76ca:	9fb9                	addw	a5,a5,a4
    76cc:	0017979b          	slliw	a5,a5,0x1
    76d0:	0007871b          	sext.w	a4,a5
    76d4:	fd843783          	ld	a5,-40(s0)
    76d8:	00178693          	addi	a3,a5,1
    76dc:	fcd43c23          	sd	a3,-40(s0)
    76e0:	0007c783          	lbu	a5,0(a5)
    76e4:	2781                	sext.w	a5,a5
    76e6:	9fb9                	addw	a5,a5,a4
    76e8:	2781                	sext.w	a5,a5
    76ea:	fd07879b          	addiw	a5,a5,-48
    76ee:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
    76f2:	fd843783          	ld	a5,-40(s0)
    76f6:	0007c783          	lbu	a5,0(a5)
    76fa:	873e                	mv	a4,a5
    76fc:	02f00793          	li	a5,47
    7700:	00e7fb63          	bgeu	a5,a4,7716 <atoi+0x68>
    7704:	fd843783          	ld	a5,-40(s0)
    7708:	0007c783          	lbu	a5,0(a5)
    770c:	873e                	mv	a4,a5
    770e:	03900793          	li	a5,57
    7712:	fae7f6e3          	bgeu	a5,a4,76be <atoi+0x10>
  return n;
    7716:	fec42783          	lw	a5,-20(s0)
}
    771a:	853e                	mv	a0,a5
    771c:	7422                	ld	s0,40(sp)
    771e:	6145                	addi	sp,sp,48
    7720:	8082                	ret

0000000000007722 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    7722:	7139                	addi	sp,sp,-64
    7724:	fc22                	sd	s0,56(sp)
    7726:	0080                	addi	s0,sp,64
    7728:	fca43c23          	sd	a0,-40(s0)
    772c:	fcb43823          	sd	a1,-48(s0)
    7730:	87b2                	mv	a5,a2
    7732:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
    7736:	fd843783          	ld	a5,-40(s0)
    773a:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
    773e:	fd043783          	ld	a5,-48(s0)
    7742:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
    7746:	fe043703          	ld	a4,-32(s0)
    774a:	fe843783          	ld	a5,-24(s0)
    774e:	02e7fc63          	bgeu	a5,a4,7786 <memmove+0x64>
    while(n-- > 0)
    7752:	a00d                	j	7774 <memmove+0x52>
      *dst++ = *src++;
    7754:	fe043703          	ld	a4,-32(s0)
    7758:	00170793          	addi	a5,a4,1
    775c:	fef43023          	sd	a5,-32(s0)
    7760:	fe843783          	ld	a5,-24(s0)
    7764:	00178693          	addi	a3,a5,1
    7768:	fed43423          	sd	a3,-24(s0)
    776c:	00074703          	lbu	a4,0(a4)
    7770:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    7774:	fcc42783          	lw	a5,-52(s0)
    7778:	fff7871b          	addiw	a4,a5,-1
    777c:	fce42623          	sw	a4,-52(s0)
    7780:	fcf04ae3          	bgtz	a5,7754 <memmove+0x32>
    7784:	a891                	j	77d8 <memmove+0xb6>
  } else {
    dst += n;
    7786:	fcc42783          	lw	a5,-52(s0)
    778a:	fe843703          	ld	a4,-24(s0)
    778e:	97ba                	add	a5,a5,a4
    7790:	fef43423          	sd	a5,-24(s0)
    src += n;
    7794:	fcc42783          	lw	a5,-52(s0)
    7798:	fe043703          	ld	a4,-32(s0)
    779c:	97ba                	add	a5,a5,a4
    779e:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
    77a2:	a01d                	j	77c8 <memmove+0xa6>
      *--dst = *--src;
    77a4:	fe043783          	ld	a5,-32(s0)
    77a8:	17fd                	addi	a5,a5,-1
    77aa:	fef43023          	sd	a5,-32(s0)
    77ae:	fe843783          	ld	a5,-24(s0)
    77b2:	17fd                	addi	a5,a5,-1
    77b4:	fef43423          	sd	a5,-24(s0)
    77b8:	fe043783          	ld	a5,-32(s0)
    77bc:	0007c703          	lbu	a4,0(a5)
    77c0:	fe843783          	ld	a5,-24(s0)
    77c4:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    77c8:	fcc42783          	lw	a5,-52(s0)
    77cc:	fff7871b          	addiw	a4,a5,-1
    77d0:	fce42623          	sw	a4,-52(s0)
    77d4:	fcf048e3          	bgtz	a5,77a4 <memmove+0x82>
  }
  return vdst;
    77d8:	fd843783          	ld	a5,-40(s0)
}
    77dc:	853e                	mv	a0,a5
    77de:	7462                	ld	s0,56(sp)
    77e0:	6121                	addi	sp,sp,64
    77e2:	8082                	ret

00000000000077e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    77e4:	7139                	addi	sp,sp,-64
    77e6:	fc22                	sd	s0,56(sp)
    77e8:	0080                	addi	s0,sp,64
    77ea:	fca43c23          	sd	a0,-40(s0)
    77ee:	fcb43823          	sd	a1,-48(s0)
    77f2:	87b2                	mv	a5,a2
    77f4:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
    77f8:	fd843783          	ld	a5,-40(s0)
    77fc:	fef43423          	sd	a5,-24(s0)
    7800:	fd043783          	ld	a5,-48(s0)
    7804:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
    7808:	a0a1                	j	7850 <memcmp+0x6c>
    if (*p1 != *p2) {
    780a:	fe843783          	ld	a5,-24(s0)
    780e:	0007c703          	lbu	a4,0(a5)
    7812:	fe043783          	ld	a5,-32(s0)
    7816:	0007c783          	lbu	a5,0(a5)
    781a:	02f70163          	beq	a4,a5,783c <memcmp+0x58>
      return *p1 - *p2;
    781e:	fe843783          	ld	a5,-24(s0)
    7822:	0007c783          	lbu	a5,0(a5)
    7826:	0007871b          	sext.w	a4,a5
    782a:	fe043783          	ld	a5,-32(s0)
    782e:	0007c783          	lbu	a5,0(a5)
    7832:	2781                	sext.w	a5,a5
    7834:	40f707bb          	subw	a5,a4,a5
    7838:	2781                	sext.w	a5,a5
    783a:	a01d                	j	7860 <memcmp+0x7c>
    }
    p1++;
    783c:	fe843783          	ld	a5,-24(s0)
    7840:	0785                	addi	a5,a5,1
    7842:	fef43423          	sd	a5,-24(s0)
    p2++;
    7846:	fe043783          	ld	a5,-32(s0)
    784a:	0785                	addi	a5,a5,1
    784c:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
    7850:	fcc42783          	lw	a5,-52(s0)
    7854:	fff7871b          	addiw	a4,a5,-1
    7858:	fce42623          	sw	a4,-52(s0)
    785c:	f7dd                	bnez	a5,780a <memcmp+0x26>
  }
  return 0;
    785e:	4781                	li	a5,0
}
    7860:	853e                	mv	a0,a5
    7862:	7462                	ld	s0,56(sp)
    7864:	6121                	addi	sp,sp,64
    7866:	8082                	ret

0000000000007868 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    7868:	7179                	addi	sp,sp,-48
    786a:	f406                	sd	ra,40(sp)
    786c:	f022                	sd	s0,32(sp)
    786e:	1800                	addi	s0,sp,48
    7870:	fea43423          	sd	a0,-24(s0)
    7874:	feb43023          	sd	a1,-32(s0)
    7878:	87b2                	mv	a5,a2
    787a:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
    787e:	fdc42783          	lw	a5,-36(s0)
    7882:	863e                	mv	a2,a5
    7884:	fe043583          	ld	a1,-32(s0)
    7888:	fe843503          	ld	a0,-24(s0)
    788c:	00000097          	auipc	ra,0x0
    7890:	e96080e7          	jalr	-362(ra) # 7722 <memmove>
    7894:	87aa                	mv	a5,a0
}
    7896:	853e                	mv	a0,a5
    7898:	70a2                	ld	ra,40(sp)
    789a:	7402                	ld	s0,32(sp)
    789c:	6145                	addi	sp,sp,48
    789e:	8082                	ret

00000000000078a0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    78a0:	4885                	li	a7,1
 ecall
    78a2:	00000073          	ecall
 ret
    78a6:	8082                	ret

00000000000078a8 <exit>:
.global exit
exit:
 li a7, SYS_exit
    78a8:	4889                	li	a7,2
 ecall
    78aa:	00000073          	ecall
 ret
    78ae:	8082                	ret

00000000000078b0 <wait>:
.global wait
wait:
 li a7, SYS_wait
    78b0:	488d                	li	a7,3
 ecall
    78b2:	00000073          	ecall
 ret
    78b6:	8082                	ret

00000000000078b8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    78b8:	4891                	li	a7,4
 ecall
    78ba:	00000073          	ecall
 ret
    78be:	8082                	ret

00000000000078c0 <read>:
.global read
read:
 li a7, SYS_read
    78c0:	4895                	li	a7,5
 ecall
    78c2:	00000073          	ecall
 ret
    78c6:	8082                	ret

00000000000078c8 <write>:
.global write
write:
 li a7, SYS_write
    78c8:	48c1                	li	a7,16
 ecall
    78ca:	00000073          	ecall
 ret
    78ce:	8082                	ret

00000000000078d0 <close>:
.global close
close:
 li a7, SYS_close
    78d0:	48d5                	li	a7,21
 ecall
    78d2:	00000073          	ecall
 ret
    78d6:	8082                	ret

00000000000078d8 <kill>:
.global kill
kill:
 li a7, SYS_kill
    78d8:	4899                	li	a7,6
 ecall
    78da:	00000073          	ecall
 ret
    78de:	8082                	ret

00000000000078e0 <exec>:
.global exec
exec:
 li a7, SYS_exec
    78e0:	489d                	li	a7,7
 ecall
    78e2:	00000073          	ecall
 ret
    78e6:	8082                	ret

00000000000078e8 <open>:
.global open
open:
 li a7, SYS_open
    78e8:	48bd                	li	a7,15
 ecall
    78ea:	00000073          	ecall
 ret
    78ee:	8082                	ret

00000000000078f0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    78f0:	48c5                	li	a7,17
 ecall
    78f2:	00000073          	ecall
 ret
    78f6:	8082                	ret

00000000000078f8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    78f8:	48c9                	li	a7,18
 ecall
    78fa:	00000073          	ecall
 ret
    78fe:	8082                	ret

0000000000007900 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    7900:	48a1                	li	a7,8
 ecall
    7902:	00000073          	ecall
 ret
    7906:	8082                	ret

0000000000007908 <link>:
.global link
link:
 li a7, SYS_link
    7908:	48cd                	li	a7,19
 ecall
    790a:	00000073          	ecall
 ret
    790e:	8082                	ret

0000000000007910 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    7910:	48d1                	li	a7,20
 ecall
    7912:	00000073          	ecall
 ret
    7916:	8082                	ret

0000000000007918 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    7918:	48a5                	li	a7,9
 ecall
    791a:	00000073          	ecall
 ret
    791e:	8082                	ret

0000000000007920 <dup>:
.global dup
dup:
 li a7, SYS_dup
    7920:	48a9                	li	a7,10
 ecall
    7922:	00000073          	ecall
 ret
    7926:	8082                	ret

0000000000007928 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    7928:	48ad                	li	a7,11
 ecall
    792a:	00000073          	ecall
 ret
    792e:	8082                	ret

0000000000007930 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    7930:	48b1                	li	a7,12
 ecall
    7932:	00000073          	ecall
 ret
    7936:	8082                	ret

0000000000007938 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    7938:	48b5                	li	a7,13
 ecall
    793a:	00000073          	ecall
 ret
    793e:	8082                	ret

0000000000007940 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    7940:	48b9                	li	a7,14
 ecall
    7942:	00000073          	ecall
 ret
    7946:	8082                	ret

0000000000007948 <hello>:
.global hello
hello:
 li a7, SYS_hello
    7948:	48d9                	li	a7,22
 ecall
    794a:	00000073          	ecall
 ret
    794e:	8082                	ret

0000000000007950 <ps>:
.global ps
ps:
 li a7, SYS_ps
    7950:	48e1                	li	a7,24
 ecall
    7952:	00000073          	ecall
 ret
    7956:	8082                	ret

0000000000007958 <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
    7958:	48dd                	li	a7,23
 ecall
    795a:	00000073          	ecall
 ret
    795e:	8082                	ret

0000000000007960 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
    7960:	48e5                	li	a7,25
 ecall
    7962:	00000073          	ecall
 ret
    7966:	8082                	ret

0000000000007968 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    7968:	1101                	addi	sp,sp,-32
    796a:	ec06                	sd	ra,24(sp)
    796c:	e822                	sd	s0,16(sp)
    796e:	1000                	addi	s0,sp,32
    7970:	87aa                	mv	a5,a0
    7972:	872e                	mv	a4,a1
    7974:	fef42623          	sw	a5,-20(s0)
    7978:	87ba                	mv	a5,a4
    797a:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
    797e:	feb40713          	addi	a4,s0,-21
    7982:	fec42783          	lw	a5,-20(s0)
    7986:	4605                	li	a2,1
    7988:	85ba                	mv	a1,a4
    798a:	853e                	mv	a0,a5
    798c:	00000097          	auipc	ra,0x0
    7990:	f3c080e7          	jalr	-196(ra) # 78c8 <write>
}
    7994:	0001                	nop
    7996:	60e2                	ld	ra,24(sp)
    7998:	6442                	ld	s0,16(sp)
    799a:	6105                	addi	sp,sp,32
    799c:	8082                	ret

000000000000799e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    799e:	7139                	addi	sp,sp,-64
    79a0:	fc06                	sd	ra,56(sp)
    79a2:	f822                	sd	s0,48(sp)
    79a4:	0080                	addi	s0,sp,64
    79a6:	87aa                	mv	a5,a0
    79a8:	8736                	mv	a4,a3
    79aa:	fcf42623          	sw	a5,-52(s0)
    79ae:	87ae                	mv	a5,a1
    79b0:	fcf42423          	sw	a5,-56(s0)
    79b4:	87b2                	mv	a5,a2
    79b6:	fcf42223          	sw	a5,-60(s0)
    79ba:	87ba                	mv	a5,a4
    79bc:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    79c0:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
    79c4:	fc042783          	lw	a5,-64(s0)
    79c8:	2781                	sext.w	a5,a5
    79ca:	c38d                	beqz	a5,79ec <printint+0x4e>
    79cc:	fc842783          	lw	a5,-56(s0)
    79d0:	2781                	sext.w	a5,a5
    79d2:	0007dd63          	bgez	a5,79ec <printint+0x4e>
    neg = 1;
    79d6:	4785                	li	a5,1
    79d8:	fef42423          	sw	a5,-24(s0)
    x = -xx;
    79dc:	fc842783          	lw	a5,-56(s0)
    79e0:	40f007bb          	negw	a5,a5
    79e4:	2781                	sext.w	a5,a5
    79e6:	fef42223          	sw	a5,-28(s0)
    79ea:	a029                	j	79f4 <printint+0x56>
  } else {
    x = xx;
    79ec:	fc842783          	lw	a5,-56(s0)
    79f0:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
    79f4:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
    79f8:	fc442783          	lw	a5,-60(s0)
    79fc:	fe442703          	lw	a4,-28(s0)
    7a00:	02f777bb          	remuw	a5,a4,a5
    7a04:	0007861b          	sext.w	a2,a5
    7a08:	fec42783          	lw	a5,-20(s0)
    7a0c:	0017871b          	addiw	a4,a5,1
    7a10:	fee42623          	sw	a4,-20(s0)
    7a14:	00004697          	auipc	a3,0x4
    7a18:	a3c68693          	addi	a3,a3,-1476 # b450 <digits>
    7a1c:	02061713          	slli	a4,a2,0x20
    7a20:	9301                	srli	a4,a4,0x20
    7a22:	9736                	add	a4,a4,a3
    7a24:	00074703          	lbu	a4,0(a4)
    7a28:	17c1                	addi	a5,a5,-16
    7a2a:	97a2                	add	a5,a5,s0
    7a2c:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
    7a30:	fc442783          	lw	a5,-60(s0)
    7a34:	fe442703          	lw	a4,-28(s0)
    7a38:	02f757bb          	divuw	a5,a4,a5
    7a3c:	fef42223          	sw	a5,-28(s0)
    7a40:	fe442783          	lw	a5,-28(s0)
    7a44:	2781                	sext.w	a5,a5
    7a46:	fbcd                	bnez	a5,79f8 <printint+0x5a>
  if(neg)
    7a48:	fe842783          	lw	a5,-24(s0)
    7a4c:	2781                	sext.w	a5,a5
    7a4e:	cf85                	beqz	a5,7a86 <printint+0xe8>
    buf[i++] = '-';
    7a50:	fec42783          	lw	a5,-20(s0)
    7a54:	0017871b          	addiw	a4,a5,1
    7a58:	fee42623          	sw	a4,-20(s0)
    7a5c:	17c1                	addi	a5,a5,-16
    7a5e:	97a2                	add	a5,a5,s0
    7a60:	02d00713          	li	a4,45
    7a64:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
    7a68:	a839                	j	7a86 <printint+0xe8>
    putc(fd, buf[i]);
    7a6a:	fec42783          	lw	a5,-20(s0)
    7a6e:	17c1                	addi	a5,a5,-16
    7a70:	97a2                	add	a5,a5,s0
    7a72:	fe07c703          	lbu	a4,-32(a5)
    7a76:	fcc42783          	lw	a5,-52(s0)
    7a7a:	85ba                	mv	a1,a4
    7a7c:	853e                	mv	a0,a5
    7a7e:	00000097          	auipc	ra,0x0
    7a82:	eea080e7          	jalr	-278(ra) # 7968 <putc>
  while(--i >= 0)
    7a86:	fec42783          	lw	a5,-20(s0)
    7a8a:	37fd                	addiw	a5,a5,-1
    7a8c:	fef42623          	sw	a5,-20(s0)
    7a90:	fec42783          	lw	a5,-20(s0)
    7a94:	2781                	sext.w	a5,a5
    7a96:	fc07dae3          	bgez	a5,7a6a <printint+0xcc>
}
    7a9a:	0001                	nop
    7a9c:	0001                	nop
    7a9e:	70e2                	ld	ra,56(sp)
    7aa0:	7442                	ld	s0,48(sp)
    7aa2:	6121                	addi	sp,sp,64
    7aa4:	8082                	ret

0000000000007aa6 <printptr>:

static void
printptr(int fd, uint64 x) {
    7aa6:	7179                	addi	sp,sp,-48
    7aa8:	f406                	sd	ra,40(sp)
    7aaa:	f022                	sd	s0,32(sp)
    7aac:	1800                	addi	s0,sp,48
    7aae:	87aa                	mv	a5,a0
    7ab0:	fcb43823          	sd	a1,-48(s0)
    7ab4:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
    7ab8:	fdc42783          	lw	a5,-36(s0)
    7abc:	03000593          	li	a1,48
    7ac0:	853e                	mv	a0,a5
    7ac2:	00000097          	auipc	ra,0x0
    7ac6:	ea6080e7          	jalr	-346(ra) # 7968 <putc>
  putc(fd, 'x');
    7aca:	fdc42783          	lw	a5,-36(s0)
    7ace:	07800593          	li	a1,120
    7ad2:	853e                	mv	a0,a5
    7ad4:	00000097          	auipc	ra,0x0
    7ad8:	e94080e7          	jalr	-364(ra) # 7968 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    7adc:	fe042623          	sw	zero,-20(s0)
    7ae0:	a82d                	j	7b1a <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    7ae2:	fd043783          	ld	a5,-48(s0)
    7ae6:	93f1                	srli	a5,a5,0x3c
    7ae8:	00004717          	auipc	a4,0x4
    7aec:	96870713          	addi	a4,a4,-1688 # b450 <digits>
    7af0:	97ba                	add	a5,a5,a4
    7af2:	0007c703          	lbu	a4,0(a5)
    7af6:	fdc42783          	lw	a5,-36(s0)
    7afa:	85ba                	mv	a1,a4
    7afc:	853e                	mv	a0,a5
    7afe:	00000097          	auipc	ra,0x0
    7b02:	e6a080e7          	jalr	-406(ra) # 7968 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    7b06:	fec42783          	lw	a5,-20(s0)
    7b0a:	2785                	addiw	a5,a5,1
    7b0c:	fef42623          	sw	a5,-20(s0)
    7b10:	fd043783          	ld	a5,-48(s0)
    7b14:	0792                	slli	a5,a5,0x4
    7b16:	fcf43823          	sd	a5,-48(s0)
    7b1a:	fec42783          	lw	a5,-20(s0)
    7b1e:	873e                	mv	a4,a5
    7b20:	47bd                	li	a5,15
    7b22:	fce7f0e3          	bgeu	a5,a4,7ae2 <printptr+0x3c>
}
    7b26:	0001                	nop
    7b28:	0001                	nop
    7b2a:	70a2                	ld	ra,40(sp)
    7b2c:	7402                	ld	s0,32(sp)
    7b2e:	6145                	addi	sp,sp,48
    7b30:	8082                	ret

0000000000007b32 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    7b32:	715d                	addi	sp,sp,-80
    7b34:	e486                	sd	ra,72(sp)
    7b36:	e0a2                	sd	s0,64(sp)
    7b38:	0880                	addi	s0,sp,80
    7b3a:	87aa                	mv	a5,a0
    7b3c:	fcb43023          	sd	a1,-64(s0)
    7b40:	fac43c23          	sd	a2,-72(s0)
    7b44:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
    7b48:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
    7b4c:	fe042223          	sw	zero,-28(s0)
    7b50:	a42d                	j	7d7a <vprintf+0x248>
    c = fmt[i] & 0xff;
    7b52:	fe442783          	lw	a5,-28(s0)
    7b56:	fc043703          	ld	a4,-64(s0)
    7b5a:	97ba                	add	a5,a5,a4
    7b5c:	0007c783          	lbu	a5,0(a5)
    7b60:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
    7b64:	fe042783          	lw	a5,-32(s0)
    7b68:	2781                	sext.w	a5,a5
    7b6a:	eb9d                	bnez	a5,7ba0 <vprintf+0x6e>
      if(c == '%'){
    7b6c:	fdc42783          	lw	a5,-36(s0)
    7b70:	0007871b          	sext.w	a4,a5
    7b74:	02500793          	li	a5,37
    7b78:	00f71763          	bne	a4,a5,7b86 <vprintf+0x54>
        state = '%';
    7b7c:	02500793          	li	a5,37
    7b80:	fef42023          	sw	a5,-32(s0)
    7b84:	a2f5                	j	7d70 <vprintf+0x23e>
      } else {
        putc(fd, c);
    7b86:	fdc42783          	lw	a5,-36(s0)
    7b8a:	0ff7f713          	zext.b	a4,a5
    7b8e:	fcc42783          	lw	a5,-52(s0)
    7b92:	85ba                	mv	a1,a4
    7b94:	853e                	mv	a0,a5
    7b96:	00000097          	auipc	ra,0x0
    7b9a:	dd2080e7          	jalr	-558(ra) # 7968 <putc>
    7b9e:	aac9                	j	7d70 <vprintf+0x23e>
      }
    } else if(state == '%'){
    7ba0:	fe042783          	lw	a5,-32(s0)
    7ba4:	0007871b          	sext.w	a4,a5
    7ba8:	02500793          	li	a5,37
    7bac:	1cf71263          	bne	a4,a5,7d70 <vprintf+0x23e>
      if(c == 'd'){
    7bb0:	fdc42783          	lw	a5,-36(s0)
    7bb4:	0007871b          	sext.w	a4,a5
    7bb8:	06400793          	li	a5,100
    7bbc:	02f71463          	bne	a4,a5,7be4 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
    7bc0:	fb843783          	ld	a5,-72(s0)
    7bc4:	00878713          	addi	a4,a5,8
    7bc8:	fae43c23          	sd	a4,-72(s0)
    7bcc:	4398                	lw	a4,0(a5)
    7bce:	fcc42783          	lw	a5,-52(s0)
    7bd2:	4685                	li	a3,1
    7bd4:	4629                	li	a2,10
    7bd6:	85ba                	mv	a1,a4
    7bd8:	853e                	mv	a0,a5
    7bda:	00000097          	auipc	ra,0x0
    7bde:	dc4080e7          	jalr	-572(ra) # 799e <printint>
    7be2:	a269                	j	7d6c <vprintf+0x23a>
      } else if(c == 'l') {
    7be4:	fdc42783          	lw	a5,-36(s0)
    7be8:	0007871b          	sext.w	a4,a5
    7bec:	06c00793          	li	a5,108
    7bf0:	02f71663          	bne	a4,a5,7c1c <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
    7bf4:	fb843783          	ld	a5,-72(s0)
    7bf8:	00878713          	addi	a4,a5,8
    7bfc:	fae43c23          	sd	a4,-72(s0)
    7c00:	639c                	ld	a5,0(a5)
    7c02:	0007871b          	sext.w	a4,a5
    7c06:	fcc42783          	lw	a5,-52(s0)
    7c0a:	4681                	li	a3,0
    7c0c:	4629                	li	a2,10
    7c0e:	85ba                	mv	a1,a4
    7c10:	853e                	mv	a0,a5
    7c12:	00000097          	auipc	ra,0x0
    7c16:	d8c080e7          	jalr	-628(ra) # 799e <printint>
    7c1a:	aa89                	j	7d6c <vprintf+0x23a>
      } else if(c == 'x') {
    7c1c:	fdc42783          	lw	a5,-36(s0)
    7c20:	0007871b          	sext.w	a4,a5
    7c24:	07800793          	li	a5,120
    7c28:	02f71463          	bne	a4,a5,7c50 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
    7c2c:	fb843783          	ld	a5,-72(s0)
    7c30:	00878713          	addi	a4,a5,8
    7c34:	fae43c23          	sd	a4,-72(s0)
    7c38:	4398                	lw	a4,0(a5)
    7c3a:	fcc42783          	lw	a5,-52(s0)
    7c3e:	4681                	li	a3,0
    7c40:	4641                	li	a2,16
    7c42:	85ba                	mv	a1,a4
    7c44:	853e                	mv	a0,a5
    7c46:	00000097          	auipc	ra,0x0
    7c4a:	d58080e7          	jalr	-680(ra) # 799e <printint>
    7c4e:	aa39                	j	7d6c <vprintf+0x23a>
      } else if(c == 'p') {
    7c50:	fdc42783          	lw	a5,-36(s0)
    7c54:	0007871b          	sext.w	a4,a5
    7c58:	07000793          	li	a5,112
    7c5c:	02f71263          	bne	a4,a5,7c80 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
    7c60:	fb843783          	ld	a5,-72(s0)
    7c64:	00878713          	addi	a4,a5,8
    7c68:	fae43c23          	sd	a4,-72(s0)
    7c6c:	6398                	ld	a4,0(a5)
    7c6e:	fcc42783          	lw	a5,-52(s0)
    7c72:	85ba                	mv	a1,a4
    7c74:	853e                	mv	a0,a5
    7c76:	00000097          	auipc	ra,0x0
    7c7a:	e30080e7          	jalr	-464(ra) # 7aa6 <printptr>
    7c7e:	a0fd                	j	7d6c <vprintf+0x23a>
      } else if(c == 's'){
    7c80:	fdc42783          	lw	a5,-36(s0)
    7c84:	0007871b          	sext.w	a4,a5
    7c88:	07300793          	li	a5,115
    7c8c:	04f71c63          	bne	a4,a5,7ce4 <vprintf+0x1b2>
        s = va_arg(ap, char*);
    7c90:	fb843783          	ld	a5,-72(s0)
    7c94:	00878713          	addi	a4,a5,8
    7c98:	fae43c23          	sd	a4,-72(s0)
    7c9c:	639c                	ld	a5,0(a5)
    7c9e:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
    7ca2:	fe843783          	ld	a5,-24(s0)
    7ca6:	eb8d                	bnez	a5,7cd8 <vprintf+0x1a6>
          s = "(null)";
    7ca8:	00003797          	auipc	a5,0x3
    7cac:	94878793          	addi	a5,a5,-1720 # a5f0 <malloc+0x260e>
    7cb0:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
    7cb4:	a015                	j	7cd8 <vprintf+0x1a6>
          putc(fd, *s);
    7cb6:	fe843783          	ld	a5,-24(s0)
    7cba:	0007c703          	lbu	a4,0(a5)
    7cbe:	fcc42783          	lw	a5,-52(s0)
    7cc2:	85ba                	mv	a1,a4
    7cc4:	853e                	mv	a0,a5
    7cc6:	00000097          	auipc	ra,0x0
    7cca:	ca2080e7          	jalr	-862(ra) # 7968 <putc>
          s++;
    7cce:	fe843783          	ld	a5,-24(s0)
    7cd2:	0785                	addi	a5,a5,1
    7cd4:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
    7cd8:	fe843783          	ld	a5,-24(s0)
    7cdc:	0007c783          	lbu	a5,0(a5)
    7ce0:	fbf9                	bnez	a5,7cb6 <vprintf+0x184>
    7ce2:	a069                	j	7d6c <vprintf+0x23a>
        }
      } else if(c == 'c'){
    7ce4:	fdc42783          	lw	a5,-36(s0)
    7ce8:	0007871b          	sext.w	a4,a5
    7cec:	06300793          	li	a5,99
    7cf0:	02f71463          	bne	a4,a5,7d18 <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
    7cf4:	fb843783          	ld	a5,-72(s0)
    7cf8:	00878713          	addi	a4,a5,8
    7cfc:	fae43c23          	sd	a4,-72(s0)
    7d00:	439c                	lw	a5,0(a5)
    7d02:	0ff7f713          	zext.b	a4,a5
    7d06:	fcc42783          	lw	a5,-52(s0)
    7d0a:	85ba                	mv	a1,a4
    7d0c:	853e                	mv	a0,a5
    7d0e:	00000097          	auipc	ra,0x0
    7d12:	c5a080e7          	jalr	-934(ra) # 7968 <putc>
    7d16:	a899                	j	7d6c <vprintf+0x23a>
      } else if(c == '%'){
    7d18:	fdc42783          	lw	a5,-36(s0)
    7d1c:	0007871b          	sext.w	a4,a5
    7d20:	02500793          	li	a5,37
    7d24:	00f71f63          	bne	a4,a5,7d42 <vprintf+0x210>
        putc(fd, c);
    7d28:	fdc42783          	lw	a5,-36(s0)
    7d2c:	0ff7f713          	zext.b	a4,a5
    7d30:	fcc42783          	lw	a5,-52(s0)
    7d34:	85ba                	mv	a1,a4
    7d36:	853e                	mv	a0,a5
    7d38:	00000097          	auipc	ra,0x0
    7d3c:	c30080e7          	jalr	-976(ra) # 7968 <putc>
    7d40:	a035                	j	7d6c <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    7d42:	fcc42783          	lw	a5,-52(s0)
    7d46:	02500593          	li	a1,37
    7d4a:	853e                	mv	a0,a5
    7d4c:	00000097          	auipc	ra,0x0
    7d50:	c1c080e7          	jalr	-996(ra) # 7968 <putc>
        putc(fd, c);
    7d54:	fdc42783          	lw	a5,-36(s0)
    7d58:	0ff7f713          	zext.b	a4,a5
    7d5c:	fcc42783          	lw	a5,-52(s0)
    7d60:	85ba                	mv	a1,a4
    7d62:	853e                	mv	a0,a5
    7d64:	00000097          	auipc	ra,0x0
    7d68:	c04080e7          	jalr	-1020(ra) # 7968 <putc>
      }
      state = 0;
    7d6c:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
    7d70:	fe442783          	lw	a5,-28(s0)
    7d74:	2785                	addiw	a5,a5,1
    7d76:	fef42223          	sw	a5,-28(s0)
    7d7a:	fe442783          	lw	a5,-28(s0)
    7d7e:	fc043703          	ld	a4,-64(s0)
    7d82:	97ba                	add	a5,a5,a4
    7d84:	0007c783          	lbu	a5,0(a5)
    7d88:	dc0795e3          	bnez	a5,7b52 <vprintf+0x20>
    }
  }
}
    7d8c:	0001                	nop
    7d8e:	0001                	nop
    7d90:	60a6                	ld	ra,72(sp)
    7d92:	6406                	ld	s0,64(sp)
    7d94:	6161                	addi	sp,sp,80
    7d96:	8082                	ret

0000000000007d98 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    7d98:	7159                	addi	sp,sp,-112
    7d9a:	fc06                	sd	ra,56(sp)
    7d9c:	f822                	sd	s0,48(sp)
    7d9e:	0080                	addi	s0,sp,64
    7da0:	fcb43823          	sd	a1,-48(s0)
    7da4:	e010                	sd	a2,0(s0)
    7da6:	e414                	sd	a3,8(s0)
    7da8:	e818                	sd	a4,16(s0)
    7daa:	ec1c                	sd	a5,24(s0)
    7dac:	03043023          	sd	a6,32(s0)
    7db0:	03143423          	sd	a7,40(s0)
    7db4:	87aa                	mv	a5,a0
    7db6:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
    7dba:	03040793          	addi	a5,s0,48
    7dbe:	fcf43423          	sd	a5,-56(s0)
    7dc2:	fc843783          	ld	a5,-56(s0)
    7dc6:	fd078793          	addi	a5,a5,-48
    7dca:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
    7dce:	fe843703          	ld	a4,-24(s0)
    7dd2:	fdc42783          	lw	a5,-36(s0)
    7dd6:	863a                	mv	a2,a4
    7dd8:	fd043583          	ld	a1,-48(s0)
    7ddc:	853e                	mv	a0,a5
    7dde:	00000097          	auipc	ra,0x0
    7de2:	d54080e7          	jalr	-684(ra) # 7b32 <vprintf>
}
    7de6:	0001                	nop
    7de8:	70e2                	ld	ra,56(sp)
    7dea:	7442                	ld	s0,48(sp)
    7dec:	6165                	addi	sp,sp,112
    7dee:	8082                	ret

0000000000007df0 <printf>:

void
printf(const char *fmt, ...)
{
    7df0:	7159                	addi	sp,sp,-112
    7df2:	f406                	sd	ra,40(sp)
    7df4:	f022                	sd	s0,32(sp)
    7df6:	1800                	addi	s0,sp,48
    7df8:	fca43c23          	sd	a0,-40(s0)
    7dfc:	e40c                	sd	a1,8(s0)
    7dfe:	e810                	sd	a2,16(s0)
    7e00:	ec14                	sd	a3,24(s0)
    7e02:	f018                	sd	a4,32(s0)
    7e04:	f41c                	sd	a5,40(s0)
    7e06:	03043823          	sd	a6,48(s0)
    7e0a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    7e0e:	04040793          	addi	a5,s0,64
    7e12:	fcf43823          	sd	a5,-48(s0)
    7e16:	fd043783          	ld	a5,-48(s0)
    7e1a:	fc878793          	addi	a5,a5,-56
    7e1e:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
    7e22:	fe843783          	ld	a5,-24(s0)
    7e26:	863e                	mv	a2,a5
    7e28:	fd843583          	ld	a1,-40(s0)
    7e2c:	4505                	li	a0,1
    7e2e:	00000097          	auipc	ra,0x0
    7e32:	d04080e7          	jalr	-764(ra) # 7b32 <vprintf>
}
    7e36:	0001                	nop
    7e38:	70a2                	ld	ra,40(sp)
    7e3a:	7402                	ld	s0,32(sp)
    7e3c:	6165                	addi	sp,sp,112
    7e3e:	8082                	ret

0000000000007e40 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    7e40:	7179                	addi	sp,sp,-48
    7e42:	f422                	sd	s0,40(sp)
    7e44:	1800                	addi	s0,sp,48
    7e46:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
    7e4a:	fd843783          	ld	a5,-40(s0)
    7e4e:	17c1                	addi	a5,a5,-16
    7e50:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    7e54:	0000a797          	auipc	a5,0xa
    7e58:	e4478793          	addi	a5,a5,-444 # 11c98 <freep>
    7e5c:	639c                	ld	a5,0(a5)
    7e5e:	fef43423          	sd	a5,-24(s0)
    7e62:	a815                	j	7e96 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    7e64:	fe843783          	ld	a5,-24(s0)
    7e68:	639c                	ld	a5,0(a5)
    7e6a:	fe843703          	ld	a4,-24(s0)
    7e6e:	00f76f63          	bltu	a4,a5,7e8c <free+0x4c>
    7e72:	fe043703          	ld	a4,-32(s0)
    7e76:	fe843783          	ld	a5,-24(s0)
    7e7a:	02e7eb63          	bltu	a5,a4,7eb0 <free+0x70>
    7e7e:	fe843783          	ld	a5,-24(s0)
    7e82:	639c                	ld	a5,0(a5)
    7e84:	fe043703          	ld	a4,-32(s0)
    7e88:	02f76463          	bltu	a4,a5,7eb0 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    7e8c:	fe843783          	ld	a5,-24(s0)
    7e90:	639c                	ld	a5,0(a5)
    7e92:	fef43423          	sd	a5,-24(s0)
    7e96:	fe043703          	ld	a4,-32(s0)
    7e9a:	fe843783          	ld	a5,-24(s0)
    7e9e:	fce7f3e3          	bgeu	a5,a4,7e64 <free+0x24>
    7ea2:	fe843783          	ld	a5,-24(s0)
    7ea6:	639c                	ld	a5,0(a5)
    7ea8:	fe043703          	ld	a4,-32(s0)
    7eac:	faf77ce3          	bgeu	a4,a5,7e64 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
    7eb0:	fe043783          	ld	a5,-32(s0)
    7eb4:	479c                	lw	a5,8(a5)
    7eb6:	1782                	slli	a5,a5,0x20
    7eb8:	9381                	srli	a5,a5,0x20
    7eba:	0792                	slli	a5,a5,0x4
    7ebc:	fe043703          	ld	a4,-32(s0)
    7ec0:	973e                	add	a4,a4,a5
    7ec2:	fe843783          	ld	a5,-24(s0)
    7ec6:	639c                	ld	a5,0(a5)
    7ec8:	02f71763          	bne	a4,a5,7ef6 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
    7ecc:	fe043783          	ld	a5,-32(s0)
    7ed0:	4798                	lw	a4,8(a5)
    7ed2:	fe843783          	ld	a5,-24(s0)
    7ed6:	639c                	ld	a5,0(a5)
    7ed8:	479c                	lw	a5,8(a5)
    7eda:	9fb9                	addw	a5,a5,a4
    7edc:	0007871b          	sext.w	a4,a5
    7ee0:	fe043783          	ld	a5,-32(s0)
    7ee4:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
    7ee6:	fe843783          	ld	a5,-24(s0)
    7eea:	639c                	ld	a5,0(a5)
    7eec:	6398                	ld	a4,0(a5)
    7eee:	fe043783          	ld	a5,-32(s0)
    7ef2:	e398                	sd	a4,0(a5)
    7ef4:	a039                	j	7f02 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
    7ef6:	fe843783          	ld	a5,-24(s0)
    7efa:	6398                	ld	a4,0(a5)
    7efc:	fe043783          	ld	a5,-32(s0)
    7f00:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
    7f02:	fe843783          	ld	a5,-24(s0)
    7f06:	479c                	lw	a5,8(a5)
    7f08:	1782                	slli	a5,a5,0x20
    7f0a:	9381                	srli	a5,a5,0x20
    7f0c:	0792                	slli	a5,a5,0x4
    7f0e:	fe843703          	ld	a4,-24(s0)
    7f12:	97ba                	add	a5,a5,a4
    7f14:	fe043703          	ld	a4,-32(s0)
    7f18:	02f71563          	bne	a4,a5,7f42 <free+0x102>
    p->s.size += bp->s.size;
    7f1c:	fe843783          	ld	a5,-24(s0)
    7f20:	4798                	lw	a4,8(a5)
    7f22:	fe043783          	ld	a5,-32(s0)
    7f26:	479c                	lw	a5,8(a5)
    7f28:	9fb9                	addw	a5,a5,a4
    7f2a:	0007871b          	sext.w	a4,a5
    7f2e:	fe843783          	ld	a5,-24(s0)
    7f32:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    7f34:	fe043783          	ld	a5,-32(s0)
    7f38:	6398                	ld	a4,0(a5)
    7f3a:	fe843783          	ld	a5,-24(s0)
    7f3e:	e398                	sd	a4,0(a5)
    7f40:	a031                	j	7f4c <free+0x10c>
  } else
    p->s.ptr = bp;
    7f42:	fe843783          	ld	a5,-24(s0)
    7f46:	fe043703          	ld	a4,-32(s0)
    7f4a:	e398                	sd	a4,0(a5)
  freep = p;
    7f4c:	0000a797          	auipc	a5,0xa
    7f50:	d4c78793          	addi	a5,a5,-692 # 11c98 <freep>
    7f54:	fe843703          	ld	a4,-24(s0)
    7f58:	e398                	sd	a4,0(a5)
}
    7f5a:	0001                	nop
    7f5c:	7422                	ld	s0,40(sp)
    7f5e:	6145                	addi	sp,sp,48
    7f60:	8082                	ret

0000000000007f62 <morecore>:

static Header*
morecore(uint nu)
{
    7f62:	7179                	addi	sp,sp,-48
    7f64:	f406                	sd	ra,40(sp)
    7f66:	f022                	sd	s0,32(sp)
    7f68:	1800                	addi	s0,sp,48
    7f6a:	87aa                	mv	a5,a0
    7f6c:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
    7f70:	fdc42783          	lw	a5,-36(s0)
    7f74:	0007871b          	sext.w	a4,a5
    7f78:	6785                	lui	a5,0x1
    7f7a:	00f77563          	bgeu	a4,a5,7f84 <morecore+0x22>
    nu = 4096;
    7f7e:	6785                	lui	a5,0x1
    7f80:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
    7f84:	fdc42783          	lw	a5,-36(s0)
    7f88:	0047979b          	slliw	a5,a5,0x4
    7f8c:	2781                	sext.w	a5,a5
    7f8e:	2781                	sext.w	a5,a5
    7f90:	853e                	mv	a0,a5
    7f92:	00000097          	auipc	ra,0x0
    7f96:	99e080e7          	jalr	-1634(ra) # 7930 <sbrk>
    7f9a:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
    7f9e:	fe843703          	ld	a4,-24(s0)
    7fa2:	57fd                	li	a5,-1
    7fa4:	00f71463          	bne	a4,a5,7fac <morecore+0x4a>
    return 0;
    7fa8:	4781                	li	a5,0
    7faa:	a03d                	j	7fd8 <morecore+0x76>
  hp = (Header*)p;
    7fac:	fe843783          	ld	a5,-24(s0)
    7fb0:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
    7fb4:	fe043783          	ld	a5,-32(s0)
    7fb8:	fdc42703          	lw	a4,-36(s0)
    7fbc:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
    7fbe:	fe043783          	ld	a5,-32(s0)
    7fc2:	07c1                	addi	a5,a5,16 # 1010 <truncate3+0x1c2>
    7fc4:	853e                	mv	a0,a5
    7fc6:	00000097          	auipc	ra,0x0
    7fca:	e7a080e7          	jalr	-390(ra) # 7e40 <free>
  return freep;
    7fce:	0000a797          	auipc	a5,0xa
    7fd2:	cca78793          	addi	a5,a5,-822 # 11c98 <freep>
    7fd6:	639c                	ld	a5,0(a5)
}
    7fd8:	853e                	mv	a0,a5
    7fda:	70a2                	ld	ra,40(sp)
    7fdc:	7402                	ld	s0,32(sp)
    7fde:	6145                	addi	sp,sp,48
    7fe0:	8082                	ret

0000000000007fe2 <malloc>:

void*
malloc(uint nbytes)
{
    7fe2:	7139                	addi	sp,sp,-64
    7fe4:	fc06                	sd	ra,56(sp)
    7fe6:	f822                	sd	s0,48(sp)
    7fe8:	0080                	addi	s0,sp,64
    7fea:	87aa                	mv	a5,a0
    7fec:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    7ff0:	fcc46783          	lwu	a5,-52(s0)
    7ff4:	07bd                	addi	a5,a5,15
    7ff6:	8391                	srli	a5,a5,0x4
    7ff8:	2781                	sext.w	a5,a5
    7ffa:	2785                	addiw	a5,a5,1
    7ffc:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
    8000:	0000a797          	auipc	a5,0xa
    8004:	c9878793          	addi	a5,a5,-872 # 11c98 <freep>
    8008:	639c                	ld	a5,0(a5)
    800a:	fef43023          	sd	a5,-32(s0)
    800e:	fe043783          	ld	a5,-32(s0)
    8012:	ef95                	bnez	a5,804e <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
    8014:	0000a797          	auipc	a5,0xa
    8018:	c7478793          	addi	a5,a5,-908 # 11c88 <base>
    801c:	fef43023          	sd	a5,-32(s0)
    8020:	0000a797          	auipc	a5,0xa
    8024:	c7878793          	addi	a5,a5,-904 # 11c98 <freep>
    8028:	fe043703          	ld	a4,-32(s0)
    802c:	e398                	sd	a4,0(a5)
    802e:	0000a797          	auipc	a5,0xa
    8032:	c6a78793          	addi	a5,a5,-918 # 11c98 <freep>
    8036:	6398                	ld	a4,0(a5)
    8038:	0000a797          	auipc	a5,0xa
    803c:	c5078793          	addi	a5,a5,-944 # 11c88 <base>
    8040:	e398                	sd	a4,0(a5)
    base.s.size = 0;
    8042:	0000a797          	auipc	a5,0xa
    8046:	c4678793          	addi	a5,a5,-954 # 11c88 <base>
    804a:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    804e:	fe043783          	ld	a5,-32(s0)
    8052:	639c                	ld	a5,0(a5)
    8054:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
    8058:	fe843783          	ld	a5,-24(s0)
    805c:	4798                	lw	a4,8(a5)
    805e:	fdc42783          	lw	a5,-36(s0)
    8062:	2781                	sext.w	a5,a5
    8064:	06f76763          	bltu	a4,a5,80d2 <malloc+0xf0>
      if(p->s.size == nunits)
    8068:	fe843783          	ld	a5,-24(s0)
    806c:	4798                	lw	a4,8(a5)
    806e:	fdc42783          	lw	a5,-36(s0)
    8072:	2781                	sext.w	a5,a5
    8074:	00e79963          	bne	a5,a4,8086 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
    8078:	fe843783          	ld	a5,-24(s0)
    807c:	6398                	ld	a4,0(a5)
    807e:	fe043783          	ld	a5,-32(s0)
    8082:	e398                	sd	a4,0(a5)
    8084:	a825                	j	80bc <malloc+0xda>
      else {
        p->s.size -= nunits;
    8086:	fe843783          	ld	a5,-24(s0)
    808a:	479c                	lw	a5,8(a5)
    808c:	fdc42703          	lw	a4,-36(s0)
    8090:	9f99                	subw	a5,a5,a4
    8092:	0007871b          	sext.w	a4,a5
    8096:	fe843783          	ld	a5,-24(s0)
    809a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    809c:	fe843783          	ld	a5,-24(s0)
    80a0:	479c                	lw	a5,8(a5)
    80a2:	1782                	slli	a5,a5,0x20
    80a4:	9381                	srli	a5,a5,0x20
    80a6:	0792                	slli	a5,a5,0x4
    80a8:	fe843703          	ld	a4,-24(s0)
    80ac:	97ba                	add	a5,a5,a4
    80ae:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
    80b2:	fe843783          	ld	a5,-24(s0)
    80b6:	fdc42703          	lw	a4,-36(s0)
    80ba:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
    80bc:	0000a797          	auipc	a5,0xa
    80c0:	bdc78793          	addi	a5,a5,-1060 # 11c98 <freep>
    80c4:	fe043703          	ld	a4,-32(s0)
    80c8:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
    80ca:	fe843783          	ld	a5,-24(s0)
    80ce:	07c1                	addi	a5,a5,16
    80d0:	a091                	j	8114 <malloc+0x132>
    }
    if(p == freep)
    80d2:	0000a797          	auipc	a5,0xa
    80d6:	bc678793          	addi	a5,a5,-1082 # 11c98 <freep>
    80da:	639c                	ld	a5,0(a5)
    80dc:	fe843703          	ld	a4,-24(s0)
    80e0:	02f71063          	bne	a4,a5,8100 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
    80e4:	fdc42783          	lw	a5,-36(s0)
    80e8:	853e                	mv	a0,a5
    80ea:	00000097          	auipc	ra,0x0
    80ee:	e78080e7          	jalr	-392(ra) # 7f62 <morecore>
    80f2:	fea43423          	sd	a0,-24(s0)
    80f6:	fe843783          	ld	a5,-24(s0)
    80fa:	e399                	bnez	a5,8100 <malloc+0x11e>
        return 0;
    80fc:	4781                	li	a5,0
    80fe:	a819                	j	8114 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    8100:	fe843783          	ld	a5,-24(s0)
    8104:	fef43023          	sd	a5,-32(s0)
    8108:	fe843783          	ld	a5,-24(s0)
    810c:	639c                	ld	a5,0(a5)
    810e:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
    8112:	b799                	j	8058 <malloc+0x76>
  }
}
    8114:	853e                	mv	a0,a5
    8116:	70e2                	ld	ra,56(sp)
    8118:	7442                	ld	s0,48(sp)
    811a:	6121                	addi	sp,sp,64
    811c:	8082                	ret
