
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	7139                	addi	sp,sp,-64
       2:	fc22                	sd	s0,56(sp)
       4:	0080                	addi	s0,sp,64
       6:	fca43423          	sd	a0,-56(s0)
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       a:	fc843783          	ld	a5,-56(s0)
       e:	6398                	ld	a4,0(a5)
      10:	800007b7          	lui	a5,0x80000
      14:	ffe7c793          	xori	a5,a5,-2
      18:	02f777b3          	remu	a5,a4,a5
      1c:	0785                	addi	a5,a5,1 # ffffffff80000001 <freep+0xffffffff7fffdbd9>
      1e:	fef43423          	sd	a5,-24(s0)
    hi = x / 127773;
      22:	fe843703          	ld	a4,-24(s0)
      26:	67fd                	lui	a5,0x1f
      28:	31d78793          	addi	a5,a5,797 # 1f31d <freep+0x1cef5>
      2c:	02f747b3          	div	a5,a4,a5
      30:	fef43023          	sd	a5,-32(s0)
    lo = x % 127773;
      34:	fe843703          	ld	a4,-24(s0)
      38:	67fd                	lui	a5,0x1f
      3a:	31d78793          	addi	a5,a5,797 # 1f31d <freep+0x1cef5>
      3e:	02f767b3          	rem	a5,a4,a5
      42:	fcf43c23          	sd	a5,-40(s0)
    x = 16807 * lo - 2836 * hi;
      46:	fd843703          	ld	a4,-40(s0)
      4a:	6791                	lui	a5,0x4
      4c:	1a778793          	addi	a5,a5,423 # 41a7 <freep+0x1d7f>
      50:	02f70733          	mul	a4,a4,a5
      54:	fe043683          	ld	a3,-32(s0)
      58:	77fd                	lui	a5,0xfffff
      5a:	4ec78793          	addi	a5,a5,1260 # fffffffffffff4ec <freep+0xffffffffffffd0c4>
      5e:	02f687b3          	mul	a5,a3,a5
      62:	97ba                	add	a5,a5,a4
      64:	fef43423          	sd	a5,-24(s0)
    if (x < 0)
      68:	fe843783          	ld	a5,-24(s0)
      6c:	0007db63          	bgez	a5,82 <do_rand+0x82>
        x += 0x7fffffff;
      70:	fe843703          	ld	a4,-24(s0)
      74:	800007b7          	lui	a5,0x80000
      78:	fff7c793          	not	a5,a5
      7c:	97ba                	add	a5,a5,a4
      7e:	fef43423          	sd	a5,-24(s0)
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      82:	fe843783          	ld	a5,-24(s0)
      86:	17fd                	addi	a5,a5,-1 # ffffffff7fffffff <freep+0xffffffff7fffdbd7>
      88:	fef43423          	sd	a5,-24(s0)
    *ctx = x;
      8c:	fe843703          	ld	a4,-24(s0)
      90:	fc843783          	ld	a5,-56(s0)
      94:	e398                	sd	a4,0(a5)
    return (x);
      96:	fe843783          	ld	a5,-24(s0)
      9a:	2781                	sext.w	a5,a5
}
      9c:	853e                	mv	a0,a5
      9e:	7462                	ld	s0,56(sp)
      a0:	6121                	addi	sp,sp,64
      a2:	8082                	ret

00000000000000a4 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      a4:	1141                	addi	sp,sp,-16
      a6:	e406                	sd	ra,8(sp)
      a8:	e022                	sd	s0,0(sp)
      aa:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      ac:	00002517          	auipc	a0,0x2
      b0:	f5450513          	addi	a0,a0,-172 # 2000 <rand_next>
      b4:	00000097          	auipc	ra,0x0
      b8:	f4c080e7          	jalr	-180(ra) # 0 <do_rand>
      bc:	87aa                	mv	a5,a0
}
      be:	853e                	mv	a0,a5
      c0:	60a2                	ld	ra,8(sp)
      c2:	6402                	ld	s0,0(sp)
      c4:	0141                	addi	sp,sp,16
      c6:	8082                	ret

00000000000000c8 <go>:

void
go(int which_child)
{
      c8:	7155                	addi	sp,sp,-208
      ca:	e586                	sd	ra,200(sp)
      cc:	e1a2                	sd	s0,192(sp)
      ce:	0980                	addi	s0,sp,208
      d0:	87aa                	mv	a5,a0
      d2:	f2f42e23          	sw	a5,-196(s0)
  int fd = -1;
      d6:	57fd                	li	a5,-1
      d8:	fef42623          	sw	a5,-20(s0)
  static char buf[999];
  char *break0 = sbrk(0);
      dc:	4501                	li	a0,0
      de:	00001097          	auipc	ra,0x1
      e2:	358080e7          	jalr	856(ra) # 1436 <sbrk>
      e6:	fca43c23          	sd	a0,-40(s0)
  uint64 iters = 0;
      ea:	fe043023          	sd	zero,-32(s0)

  mkdir("grindir");
      ee:	00002517          	auipc	a0,0x2
      f2:	b4250513          	addi	a0,a0,-1214 # 1c30 <malloc+0x148>
      f6:	00001097          	auipc	ra,0x1
      fa:	320080e7          	jalr	800(ra) # 1416 <mkdir>
  if(chdir("grindir") != 0){
      fe:	00002517          	auipc	a0,0x2
     102:	b3250513          	addi	a0,a0,-1230 # 1c30 <malloc+0x148>
     106:	00001097          	auipc	ra,0x1
     10a:	318080e7          	jalr	792(ra) # 141e <chdir>
     10e:	87aa                	mv	a5,a0
     110:	cf91                	beqz	a5,12c <go+0x64>
    printf("grind: chdir grindir failed\n");
     112:	00002517          	auipc	a0,0x2
     116:	b2650513          	addi	a0,a0,-1242 # 1c38 <malloc+0x150>
     11a:	00001097          	auipc	ra,0x1
     11e:	7dc080e7          	jalr	2012(ra) # 18f6 <printf>
    exit(1);
     122:	4505                	li	a0,1
     124:	00001097          	auipc	ra,0x1
     128:	28a080e7          	jalr	650(ra) # 13ae <exit>
  }
  chdir("/");
     12c:	00002517          	auipc	a0,0x2
     130:	b2c50513          	addi	a0,a0,-1236 # 1c58 <malloc+0x170>
     134:	00001097          	auipc	ra,0x1
     138:	2ea080e7          	jalr	746(ra) # 141e <chdir>
  
  while(1){
    iters++;
     13c:	fe043783          	ld	a5,-32(s0)
     140:	0785                	addi	a5,a5,1
     142:	fef43023          	sd	a5,-32(s0)
    if((iters % 500) == 0)
     146:	fe043703          	ld	a4,-32(s0)
     14a:	1f400793          	li	a5,500
     14e:	02f777b3          	remu	a5,a4,a5
     152:	e78d                	bnez	a5,17c <go+0xb4>
      write(1, which_child?"B":"A", 1);
     154:	f3c42783          	lw	a5,-196(s0)
     158:	2781                	sext.w	a5,a5
     15a:	c791                	beqz	a5,166 <go+0x9e>
     15c:	00002797          	auipc	a5,0x2
     160:	b0478793          	addi	a5,a5,-1276 # 1c60 <malloc+0x178>
     164:	a029                	j	16e <go+0xa6>
     166:	00002797          	auipc	a5,0x2
     16a:	b0278793          	addi	a5,a5,-1278 # 1c68 <malloc+0x180>
     16e:	4605                	li	a2,1
     170:	85be                	mv	a1,a5
     172:	4505                	li	a0,1
     174:	00001097          	auipc	ra,0x1
     178:	25a080e7          	jalr	602(ra) # 13ce <write>
    int what = rand() % 23;
     17c:	00000097          	auipc	ra,0x0
     180:	f28080e7          	jalr	-216(ra) # a4 <rand>
     184:	87aa                	mv	a5,a0
     186:	873e                	mv	a4,a5
     188:	47dd                	li	a5,23
     18a:	02f767bb          	remw	a5,a4,a5
     18e:	fcf42a23          	sw	a5,-44(s0)
    if(what == 1){
     192:	fd442783          	lw	a5,-44(s0)
     196:	0007871b          	sext.w	a4,a5
     19a:	4785                	li	a5,1
     19c:	02f71363          	bne	a4,a5,1c2 <go+0xfa>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     1a0:	20200593          	li	a1,514
     1a4:	00002517          	auipc	a0,0x2
     1a8:	acc50513          	addi	a0,a0,-1332 # 1c70 <malloc+0x188>
     1ac:	00001097          	auipc	ra,0x1
     1b0:	242080e7          	jalr	578(ra) # 13ee <open>
     1b4:	87aa                	mv	a5,a0
     1b6:	853e                	mv	a0,a5
     1b8:	00001097          	auipc	ra,0x1
     1bc:	21e080e7          	jalr	542(ra) # 13d6 <close>
     1c0:	bfb5                	j	13c <go+0x74>
    } else if(what == 2){
     1c2:	fd442783          	lw	a5,-44(s0)
     1c6:	0007871b          	sext.w	a4,a5
     1ca:	4789                	li	a5,2
     1cc:	02f71363          	bne	a4,a5,1f2 <go+0x12a>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     1d0:	20200593          	li	a1,514
     1d4:	00002517          	auipc	a0,0x2
     1d8:	aac50513          	addi	a0,a0,-1364 # 1c80 <malloc+0x198>
     1dc:	00001097          	auipc	ra,0x1
     1e0:	212080e7          	jalr	530(ra) # 13ee <open>
     1e4:	87aa                	mv	a5,a0
     1e6:	853e                	mv	a0,a5
     1e8:	00001097          	auipc	ra,0x1
     1ec:	1ee080e7          	jalr	494(ra) # 13d6 <close>
     1f0:	b7b1                	j	13c <go+0x74>
    } else if(what == 3){
     1f2:	fd442783          	lw	a5,-44(s0)
     1f6:	0007871b          	sext.w	a4,a5
     1fa:	478d                	li	a5,3
     1fc:	00f71b63          	bne	a4,a5,212 <go+0x14a>
      unlink("grindir/../a");
     200:	00002517          	auipc	a0,0x2
     204:	a7050513          	addi	a0,a0,-1424 # 1c70 <malloc+0x188>
     208:	00001097          	auipc	ra,0x1
     20c:	1f6080e7          	jalr	502(ra) # 13fe <unlink>
     210:	b735                	j	13c <go+0x74>
    } else if(what == 4){
     212:	fd442783          	lw	a5,-44(s0)
     216:	0007871b          	sext.w	a4,a5
     21a:	4791                	li	a5,4
     21c:	04f71a63          	bne	a4,a5,270 <go+0x1a8>
      if(chdir("grindir") != 0){
     220:	00002517          	auipc	a0,0x2
     224:	a1050513          	addi	a0,a0,-1520 # 1c30 <malloc+0x148>
     228:	00001097          	auipc	ra,0x1
     22c:	1f6080e7          	jalr	502(ra) # 141e <chdir>
     230:	87aa                	mv	a5,a0
     232:	cf91                	beqz	a5,24e <go+0x186>
        printf("grind: chdir grindir failed\n");
     234:	00002517          	auipc	a0,0x2
     238:	a0450513          	addi	a0,a0,-1532 # 1c38 <malloc+0x150>
     23c:	00001097          	auipc	ra,0x1
     240:	6ba080e7          	jalr	1722(ra) # 18f6 <printf>
        exit(1);
     244:	4505                	li	a0,1
     246:	00001097          	auipc	ra,0x1
     24a:	168080e7          	jalr	360(ra) # 13ae <exit>
      }
      unlink("../b");
     24e:	00002517          	auipc	a0,0x2
     252:	a4a50513          	addi	a0,a0,-1462 # 1c98 <malloc+0x1b0>
     256:	00001097          	auipc	ra,0x1
     25a:	1a8080e7          	jalr	424(ra) # 13fe <unlink>
      chdir("/");
     25e:	00002517          	auipc	a0,0x2
     262:	9fa50513          	addi	a0,a0,-1542 # 1c58 <malloc+0x170>
     266:	00001097          	auipc	ra,0x1
     26a:	1b8080e7          	jalr	440(ra) # 141e <chdir>
     26e:	b5f9                	j	13c <go+0x74>
    } else if(what == 5){
     270:	fd442783          	lw	a5,-44(s0)
     274:	0007871b          	sext.w	a4,a5
     278:	4795                	li	a5,5
     27a:	02f71763          	bne	a4,a5,2a8 <go+0x1e0>
      close(fd);
     27e:	fec42783          	lw	a5,-20(s0)
     282:	853e                	mv	a0,a5
     284:	00001097          	auipc	ra,0x1
     288:	152080e7          	jalr	338(ra) # 13d6 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     28c:	20200593          	li	a1,514
     290:	00002517          	auipc	a0,0x2
     294:	a1050513          	addi	a0,a0,-1520 # 1ca0 <malloc+0x1b8>
     298:	00001097          	auipc	ra,0x1
     29c:	156080e7          	jalr	342(ra) # 13ee <open>
     2a0:	87aa                	mv	a5,a0
     2a2:	fef42623          	sw	a5,-20(s0)
     2a6:	bd59                	j	13c <go+0x74>
    } else if(what == 6){
     2a8:	fd442783          	lw	a5,-44(s0)
     2ac:	0007871b          	sext.w	a4,a5
     2b0:	4799                	li	a5,6
     2b2:	02f71763          	bne	a4,a5,2e0 <go+0x218>
      close(fd);
     2b6:	fec42783          	lw	a5,-20(s0)
     2ba:	853e                	mv	a0,a5
     2bc:	00001097          	auipc	ra,0x1
     2c0:	11a080e7          	jalr	282(ra) # 13d6 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     2c4:	20200593          	li	a1,514
     2c8:	00002517          	auipc	a0,0x2
     2cc:	9e850513          	addi	a0,a0,-1560 # 1cb0 <malloc+0x1c8>
     2d0:	00001097          	auipc	ra,0x1
     2d4:	11e080e7          	jalr	286(ra) # 13ee <open>
     2d8:	87aa                	mv	a5,a0
     2da:	fef42623          	sw	a5,-20(s0)
     2de:	bdb9                	j	13c <go+0x74>
    } else if(what == 7){
     2e0:	fd442783          	lw	a5,-44(s0)
     2e4:	0007871b          	sext.w	a4,a5
     2e8:	479d                	li	a5,7
     2ea:	02f71063          	bne	a4,a5,30a <go+0x242>
      write(fd, buf, sizeof(buf));
     2ee:	fec42783          	lw	a5,-20(s0)
     2f2:	3e700613          	li	a2,999
     2f6:	00002597          	auipc	a1,0x2
     2fa:	d3a58593          	addi	a1,a1,-710 # 2030 <buf.0>
     2fe:	853e                	mv	a0,a5
     300:	00001097          	auipc	ra,0x1
     304:	0ce080e7          	jalr	206(ra) # 13ce <write>
     308:	bd15                	j	13c <go+0x74>
    } else if(what == 8){
     30a:	fd442783          	lw	a5,-44(s0)
     30e:	0007871b          	sext.w	a4,a5
     312:	47a1                	li	a5,8
     314:	02f71063          	bne	a4,a5,334 <go+0x26c>
      read(fd, buf, sizeof(buf));
     318:	fec42783          	lw	a5,-20(s0)
     31c:	3e700613          	li	a2,999
     320:	00002597          	auipc	a1,0x2
     324:	d1058593          	addi	a1,a1,-752 # 2030 <buf.0>
     328:	853e                	mv	a0,a5
     32a:	00001097          	auipc	ra,0x1
     32e:	09c080e7          	jalr	156(ra) # 13c6 <read>
     332:	b529                	j	13c <go+0x74>
    } else if(what == 9){
     334:	fd442783          	lw	a5,-44(s0)
     338:	0007871b          	sext.w	a4,a5
     33c:	47a5                	li	a5,9
     33e:	04f71363          	bne	a4,a5,384 <go+0x2bc>
      mkdir("grindir/../a");
     342:	00002517          	auipc	a0,0x2
     346:	92e50513          	addi	a0,a0,-1746 # 1c70 <malloc+0x188>
     34a:	00001097          	auipc	ra,0x1
     34e:	0cc080e7          	jalr	204(ra) # 1416 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     352:	20200593          	li	a1,514
     356:	00002517          	auipc	a0,0x2
     35a:	97250513          	addi	a0,a0,-1678 # 1cc8 <malloc+0x1e0>
     35e:	00001097          	auipc	ra,0x1
     362:	090080e7          	jalr	144(ra) # 13ee <open>
     366:	87aa                	mv	a5,a0
     368:	853e                	mv	a0,a5
     36a:	00001097          	auipc	ra,0x1
     36e:	06c080e7          	jalr	108(ra) # 13d6 <close>
      unlink("a/a");
     372:	00002517          	auipc	a0,0x2
     376:	96650513          	addi	a0,a0,-1690 # 1cd8 <malloc+0x1f0>
     37a:	00001097          	auipc	ra,0x1
     37e:	084080e7          	jalr	132(ra) # 13fe <unlink>
     382:	bb6d                	j	13c <go+0x74>
    } else if(what == 10){
     384:	fd442783          	lw	a5,-44(s0)
     388:	0007871b          	sext.w	a4,a5
     38c:	47a9                	li	a5,10
     38e:	04f71363          	bne	a4,a5,3d4 <go+0x30c>
      mkdir("/../b");
     392:	00002517          	auipc	a0,0x2
     396:	94e50513          	addi	a0,a0,-1714 # 1ce0 <malloc+0x1f8>
     39a:	00001097          	auipc	ra,0x1
     39e:	07c080e7          	jalr	124(ra) # 1416 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     3a2:	20200593          	li	a1,514
     3a6:	00002517          	auipc	a0,0x2
     3aa:	94250513          	addi	a0,a0,-1726 # 1ce8 <malloc+0x200>
     3ae:	00001097          	auipc	ra,0x1
     3b2:	040080e7          	jalr	64(ra) # 13ee <open>
     3b6:	87aa                	mv	a5,a0
     3b8:	853e                	mv	a0,a5
     3ba:	00001097          	auipc	ra,0x1
     3be:	01c080e7          	jalr	28(ra) # 13d6 <close>
      unlink("b/b");
     3c2:	00002517          	auipc	a0,0x2
     3c6:	93650513          	addi	a0,a0,-1738 # 1cf8 <malloc+0x210>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	034080e7          	jalr	52(ra) # 13fe <unlink>
     3d2:	b3ad                	j	13c <go+0x74>
    } else if(what == 11){
     3d4:	fd442783          	lw	a5,-44(s0)
     3d8:	0007871b          	sext.w	a4,a5
     3dc:	47ad                	li	a5,11
     3de:	02f71763          	bne	a4,a5,40c <go+0x344>
      unlink("b");
     3e2:	00002517          	auipc	a0,0x2
     3e6:	91e50513          	addi	a0,a0,-1762 # 1d00 <malloc+0x218>
     3ea:	00001097          	auipc	ra,0x1
     3ee:	014080e7          	jalr	20(ra) # 13fe <unlink>
      link("../grindir/./../a", "../b");
     3f2:	00002597          	auipc	a1,0x2
     3f6:	8a658593          	addi	a1,a1,-1882 # 1c98 <malloc+0x1b0>
     3fa:	00002517          	auipc	a0,0x2
     3fe:	90e50513          	addi	a0,a0,-1778 # 1d08 <malloc+0x220>
     402:	00001097          	auipc	ra,0x1
     406:	00c080e7          	jalr	12(ra) # 140e <link>
     40a:	bb0d                	j	13c <go+0x74>
    } else if(what == 12){
     40c:	fd442783          	lw	a5,-44(s0)
     410:	0007871b          	sext.w	a4,a5
     414:	47b1                	li	a5,12
     416:	02f71763          	bne	a4,a5,444 <go+0x37c>
      unlink("../grindir/../a");
     41a:	00002517          	auipc	a0,0x2
     41e:	90650513          	addi	a0,a0,-1786 # 1d20 <malloc+0x238>
     422:	00001097          	auipc	ra,0x1
     426:	fdc080e7          	jalr	-36(ra) # 13fe <unlink>
      link(".././b", "/grindir/../a");
     42a:	00002597          	auipc	a1,0x2
     42e:	87658593          	addi	a1,a1,-1930 # 1ca0 <malloc+0x1b8>
     432:	00002517          	auipc	a0,0x2
     436:	8fe50513          	addi	a0,a0,-1794 # 1d30 <malloc+0x248>
     43a:	00001097          	auipc	ra,0x1
     43e:	fd4080e7          	jalr	-44(ra) # 140e <link>
     442:	b9ed                	j	13c <go+0x74>
    } else if(what == 13){
     444:	fd442783          	lw	a5,-44(s0)
     448:	0007871b          	sext.w	a4,a5
     44c:	47b5                	li	a5,13
     44e:	04f71a63          	bne	a4,a5,4a2 <go+0x3da>
      int pid = fork();
     452:	00001097          	auipc	ra,0x1
     456:	f54080e7          	jalr	-172(ra) # 13a6 <fork>
     45a:	87aa                	mv	a5,a0
     45c:	faf42823          	sw	a5,-80(s0)
      if(pid == 0){
     460:	fb042783          	lw	a5,-80(s0)
     464:	2781                	sext.w	a5,a5
     466:	e791                	bnez	a5,472 <go+0x3aa>
        exit(0);
     468:	4501                	li	a0,0
     46a:	00001097          	auipc	ra,0x1
     46e:	f44080e7          	jalr	-188(ra) # 13ae <exit>
      } else if(pid < 0){
     472:	fb042783          	lw	a5,-80(s0)
     476:	2781                	sext.w	a5,a5
     478:	0007df63          	bgez	a5,496 <go+0x3ce>
        printf("grind: fork failed\n");
     47c:	00002517          	auipc	a0,0x2
     480:	8bc50513          	addi	a0,a0,-1860 # 1d38 <malloc+0x250>
     484:	00001097          	auipc	ra,0x1
     488:	472080e7          	jalr	1138(ra) # 18f6 <printf>
        exit(1);
     48c:	4505                	li	a0,1
     48e:	00001097          	auipc	ra,0x1
     492:	f20080e7          	jalr	-224(ra) # 13ae <exit>
      }
      wait(0);
     496:	4501                	li	a0,0
     498:	00001097          	auipc	ra,0x1
     49c:	f1e080e7          	jalr	-226(ra) # 13b6 <wait>
     4a0:	b971                	j	13c <go+0x74>
    } else if(what == 14){
     4a2:	fd442783          	lw	a5,-44(s0)
     4a6:	0007871b          	sext.w	a4,a5
     4aa:	47b9                	li	a5,14
     4ac:	06f71263          	bne	a4,a5,510 <go+0x448>
      int pid = fork();
     4b0:	00001097          	auipc	ra,0x1
     4b4:	ef6080e7          	jalr	-266(ra) # 13a6 <fork>
     4b8:	87aa                	mv	a5,a0
     4ba:	faf42a23          	sw	a5,-76(s0)
      if(pid == 0){
     4be:	fb442783          	lw	a5,-76(s0)
     4c2:	2781                	sext.w	a5,a5
     4c4:	ef91                	bnez	a5,4e0 <go+0x418>
        fork();
     4c6:	00001097          	auipc	ra,0x1
     4ca:	ee0080e7          	jalr	-288(ra) # 13a6 <fork>
        fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	ed8080e7          	jalr	-296(ra) # 13a6 <fork>
        exit(0);
     4d6:	4501                	li	a0,0
     4d8:	00001097          	auipc	ra,0x1
     4dc:	ed6080e7          	jalr	-298(ra) # 13ae <exit>
      } else if(pid < 0){
     4e0:	fb442783          	lw	a5,-76(s0)
     4e4:	2781                	sext.w	a5,a5
     4e6:	0007df63          	bgez	a5,504 <go+0x43c>
        printf("grind: fork failed\n");
     4ea:	00002517          	auipc	a0,0x2
     4ee:	84e50513          	addi	a0,a0,-1970 # 1d38 <malloc+0x250>
     4f2:	00001097          	auipc	ra,0x1
     4f6:	404080e7          	jalr	1028(ra) # 18f6 <printf>
        exit(1);
     4fa:	4505                	li	a0,1
     4fc:	00001097          	auipc	ra,0x1
     500:	eb2080e7          	jalr	-334(ra) # 13ae <exit>
      }
      wait(0);
     504:	4501                	li	a0,0
     506:	00001097          	auipc	ra,0x1
     50a:	eb0080e7          	jalr	-336(ra) # 13b6 <wait>
     50e:	b13d                	j	13c <go+0x74>
    } else if(what == 15){
     510:	fd442783          	lw	a5,-44(s0)
     514:	0007871b          	sext.w	a4,a5
     518:	47bd                	li	a5,15
     51a:	00f71a63          	bne	a4,a5,52e <go+0x466>
      sbrk(6011);
     51e:	6785                	lui	a5,0x1
     520:	77b78513          	addi	a0,a5,1915 # 177b <vprintf+0x143>
     524:	00001097          	auipc	ra,0x1
     528:	f12080e7          	jalr	-238(ra) # 1436 <sbrk>
     52c:	b901                	j	13c <go+0x74>
    } else if(what == 16){
     52e:	fd442783          	lw	a5,-44(s0)
     532:	0007871b          	sext.w	a4,a5
     536:	47c1                	li	a5,16
     538:	02f71c63          	bne	a4,a5,570 <go+0x4a8>
      if(sbrk(0) > break0)
     53c:	4501                	li	a0,0
     53e:	00001097          	auipc	ra,0x1
     542:	ef8080e7          	jalr	-264(ra) # 1436 <sbrk>
     546:	872a                	mv	a4,a0
     548:	fd843783          	ld	a5,-40(s0)
     54c:	bee7f8e3          	bgeu	a5,a4,13c <go+0x74>
        sbrk(-(sbrk(0) - break0));
     550:	4501                	li	a0,0
     552:	00001097          	auipc	ra,0x1
     556:	ee4080e7          	jalr	-284(ra) # 1436 <sbrk>
     55a:	872a                	mv	a4,a0
     55c:	fd843783          	ld	a5,-40(s0)
     560:	8f99                	sub	a5,a5,a4
     562:	2781                	sext.w	a5,a5
     564:	853e                	mv	a0,a5
     566:	00001097          	auipc	ra,0x1
     56a:	ed0080e7          	jalr	-304(ra) # 1436 <sbrk>
     56e:	b6f9                	j	13c <go+0x74>
    } else if(what == 17){
     570:	fd442783          	lw	a5,-44(s0)
     574:	0007871b          	sext.w	a4,a5
     578:	47c5                	li	a5,17
     57a:	0af71863          	bne	a4,a5,62a <go+0x562>
      int pid = fork();
     57e:	00001097          	auipc	ra,0x1
     582:	e28080e7          	jalr	-472(ra) # 13a6 <fork>
     586:	87aa                	mv	a5,a0
     588:	faf42c23          	sw	a5,-72(s0)
      if(pid == 0){
     58c:	fb842783          	lw	a5,-72(s0)
     590:	2781                	sext.w	a5,a5
     592:	e795                	bnez	a5,5be <go+0x4f6>
        close(open("a", O_CREATE|O_RDWR));
     594:	20200593          	li	a1,514
     598:	00001517          	auipc	a0,0x1
     59c:	7b850513          	addi	a0,a0,1976 # 1d50 <malloc+0x268>
     5a0:	00001097          	auipc	ra,0x1
     5a4:	e4e080e7          	jalr	-434(ra) # 13ee <open>
     5a8:	87aa                	mv	a5,a0
     5aa:	853e                	mv	a0,a5
     5ac:	00001097          	auipc	ra,0x1
     5b0:	e2a080e7          	jalr	-470(ra) # 13d6 <close>
        exit(0);
     5b4:	4501                	li	a0,0
     5b6:	00001097          	auipc	ra,0x1
     5ba:	df8080e7          	jalr	-520(ra) # 13ae <exit>
      } else if(pid < 0){
     5be:	fb842783          	lw	a5,-72(s0)
     5c2:	2781                	sext.w	a5,a5
     5c4:	0007df63          	bgez	a5,5e2 <go+0x51a>
        printf("grind: fork failed\n");
     5c8:	00001517          	auipc	a0,0x1
     5cc:	77050513          	addi	a0,a0,1904 # 1d38 <malloc+0x250>
     5d0:	00001097          	auipc	ra,0x1
     5d4:	326080e7          	jalr	806(ra) # 18f6 <printf>
        exit(1);
     5d8:	4505                	li	a0,1
     5da:	00001097          	auipc	ra,0x1
     5de:	dd4080e7          	jalr	-556(ra) # 13ae <exit>
      }
      if(chdir("../grindir/..") != 0){
     5e2:	00001517          	auipc	a0,0x1
     5e6:	77650513          	addi	a0,a0,1910 # 1d58 <malloc+0x270>
     5ea:	00001097          	auipc	ra,0x1
     5ee:	e34080e7          	jalr	-460(ra) # 141e <chdir>
     5f2:	87aa                	mv	a5,a0
     5f4:	cf91                	beqz	a5,610 <go+0x548>
        printf("grind: chdir failed\n");
     5f6:	00001517          	auipc	a0,0x1
     5fa:	77250513          	addi	a0,a0,1906 # 1d68 <malloc+0x280>
     5fe:	00001097          	auipc	ra,0x1
     602:	2f8080e7          	jalr	760(ra) # 18f6 <printf>
        exit(1);
     606:	4505                	li	a0,1
     608:	00001097          	auipc	ra,0x1
     60c:	da6080e7          	jalr	-602(ra) # 13ae <exit>
      }
      kill(pid);
     610:	fb842783          	lw	a5,-72(s0)
     614:	853e                	mv	a0,a5
     616:	00001097          	auipc	ra,0x1
     61a:	dc8080e7          	jalr	-568(ra) # 13de <kill>
      wait(0);
     61e:	4501                	li	a0,0
     620:	00001097          	auipc	ra,0x1
     624:	d96080e7          	jalr	-618(ra) # 13b6 <wait>
     628:	be11                	j	13c <go+0x74>
    } else if(what == 18){
     62a:	fd442783          	lw	a5,-44(s0)
     62e:	0007871b          	sext.w	a4,a5
     632:	47c9                	li	a5,18
     634:	06f71463          	bne	a4,a5,69c <go+0x5d4>
      int pid = fork();
     638:	00001097          	auipc	ra,0x1
     63c:	d6e080e7          	jalr	-658(ra) # 13a6 <fork>
     640:	87aa                	mv	a5,a0
     642:	faf42e23          	sw	a5,-68(s0)
      if(pid == 0){
     646:	fbc42783          	lw	a5,-68(s0)
     64a:	2781                	sext.w	a5,a5
     64c:	e385                	bnez	a5,66c <go+0x5a4>
        kill(getpid());
     64e:	00001097          	auipc	ra,0x1
     652:	de0080e7          	jalr	-544(ra) # 142e <getpid>
     656:	87aa                	mv	a5,a0
     658:	853e                	mv	a0,a5
     65a:	00001097          	auipc	ra,0x1
     65e:	d84080e7          	jalr	-636(ra) # 13de <kill>
        exit(0);
     662:	4501                	li	a0,0
     664:	00001097          	auipc	ra,0x1
     668:	d4a080e7          	jalr	-694(ra) # 13ae <exit>
      } else if(pid < 0){
     66c:	fbc42783          	lw	a5,-68(s0)
     670:	2781                	sext.w	a5,a5
     672:	0007df63          	bgez	a5,690 <go+0x5c8>
        printf("grind: fork failed\n");
     676:	00001517          	auipc	a0,0x1
     67a:	6c250513          	addi	a0,a0,1730 # 1d38 <malloc+0x250>
     67e:	00001097          	auipc	ra,0x1
     682:	278080e7          	jalr	632(ra) # 18f6 <printf>
        exit(1);
     686:	4505                	li	a0,1
     688:	00001097          	auipc	ra,0x1
     68c:	d26080e7          	jalr	-730(ra) # 13ae <exit>
      }
      wait(0);
     690:	4501                	li	a0,0
     692:	00001097          	auipc	ra,0x1
     696:	d24080e7          	jalr	-732(ra) # 13b6 <wait>
     69a:	b44d                	j	13c <go+0x74>
    } else if(what == 19){
     69c:	fd442783          	lw	a5,-44(s0)
     6a0:	0007871b          	sext.w	a4,a5
     6a4:	47cd                	li	a5,19
     6a6:	10f71863          	bne	a4,a5,7b6 <go+0x6ee>
      int fds[2];
      if(pipe(fds) < 0){
     6aa:	fa840793          	addi	a5,s0,-88
     6ae:	853e                	mv	a0,a5
     6b0:	00001097          	auipc	ra,0x1
     6b4:	d0e080e7          	jalr	-754(ra) # 13be <pipe>
     6b8:	87aa                	mv	a5,a0
     6ba:	0007df63          	bgez	a5,6d8 <go+0x610>
        printf("grind: pipe failed\n");
     6be:	00001517          	auipc	a0,0x1
     6c2:	6c250513          	addi	a0,a0,1730 # 1d80 <malloc+0x298>
     6c6:	00001097          	auipc	ra,0x1
     6ca:	230080e7          	jalr	560(ra) # 18f6 <printf>
        exit(1);
     6ce:	4505                	li	a0,1
     6d0:	00001097          	auipc	ra,0x1
     6d4:	cde080e7          	jalr	-802(ra) # 13ae <exit>
      }
      int pid = fork();
     6d8:	00001097          	auipc	ra,0x1
     6dc:	cce080e7          	jalr	-818(ra) # 13a6 <fork>
     6e0:	87aa                	mv	a5,a0
     6e2:	fcf42023          	sw	a5,-64(s0)
      if(pid == 0){
     6e6:	fc042783          	lw	a5,-64(s0)
     6ea:	2781                	sext.w	a5,a5
     6ec:	efbd                	bnez	a5,76a <go+0x6a2>
        fork();
     6ee:	00001097          	auipc	ra,0x1
     6f2:	cb8080e7          	jalr	-840(ra) # 13a6 <fork>
        fork();
     6f6:	00001097          	auipc	ra,0x1
     6fa:	cb0080e7          	jalr	-848(ra) # 13a6 <fork>
        if(write(fds[1], "x", 1) != 1)
     6fe:	fac42783          	lw	a5,-84(s0)
     702:	4605                	li	a2,1
     704:	00001597          	auipc	a1,0x1
     708:	69458593          	addi	a1,a1,1684 # 1d98 <malloc+0x2b0>
     70c:	853e                	mv	a0,a5
     70e:	00001097          	auipc	ra,0x1
     712:	cc0080e7          	jalr	-832(ra) # 13ce <write>
     716:	87aa                	mv	a5,a0
     718:	873e                	mv	a4,a5
     71a:	4785                	li	a5,1
     71c:	00f70a63          	beq	a4,a5,730 <go+0x668>
          printf("grind: pipe write failed\n");
     720:	00001517          	auipc	a0,0x1
     724:	68050513          	addi	a0,a0,1664 # 1da0 <malloc+0x2b8>
     728:	00001097          	auipc	ra,0x1
     72c:	1ce080e7          	jalr	462(ra) # 18f6 <printf>
        char c;
        if(read(fds[0], &c, 1) != 1)
     730:	fa842783          	lw	a5,-88(s0)
     734:	fa740713          	addi	a4,s0,-89
     738:	4605                	li	a2,1
     73a:	85ba                	mv	a1,a4
     73c:	853e                	mv	a0,a5
     73e:	00001097          	auipc	ra,0x1
     742:	c88080e7          	jalr	-888(ra) # 13c6 <read>
     746:	87aa                	mv	a5,a0
     748:	873e                	mv	a4,a5
     74a:	4785                	li	a5,1
     74c:	00f70a63          	beq	a4,a5,760 <go+0x698>
          printf("grind: pipe read failed\n");
     750:	00001517          	auipc	a0,0x1
     754:	67050513          	addi	a0,a0,1648 # 1dc0 <malloc+0x2d8>
     758:	00001097          	auipc	ra,0x1
     75c:	19e080e7          	jalr	414(ra) # 18f6 <printf>
        exit(0);
     760:	4501                	li	a0,0
     762:	00001097          	auipc	ra,0x1
     766:	c4c080e7          	jalr	-948(ra) # 13ae <exit>
      } else if(pid < 0){
     76a:	fc042783          	lw	a5,-64(s0)
     76e:	2781                	sext.w	a5,a5
     770:	0007df63          	bgez	a5,78e <go+0x6c6>
        printf("grind: fork failed\n");
     774:	00001517          	auipc	a0,0x1
     778:	5c450513          	addi	a0,a0,1476 # 1d38 <malloc+0x250>
     77c:	00001097          	auipc	ra,0x1
     780:	17a080e7          	jalr	378(ra) # 18f6 <printf>
        exit(1);
     784:	4505                	li	a0,1
     786:	00001097          	auipc	ra,0x1
     78a:	c28080e7          	jalr	-984(ra) # 13ae <exit>
      }
      close(fds[0]);
     78e:	fa842783          	lw	a5,-88(s0)
     792:	853e                	mv	a0,a5
     794:	00001097          	auipc	ra,0x1
     798:	c42080e7          	jalr	-958(ra) # 13d6 <close>
      close(fds[1]);
     79c:	fac42783          	lw	a5,-84(s0)
     7a0:	853e                	mv	a0,a5
     7a2:	00001097          	auipc	ra,0x1
     7a6:	c34080e7          	jalr	-972(ra) # 13d6 <close>
      wait(0);
     7aa:	4501                	li	a0,0
     7ac:	00001097          	auipc	ra,0x1
     7b0:	c0a080e7          	jalr	-1014(ra) # 13b6 <wait>
     7b4:	b261                	j	13c <go+0x74>
    } else if(what == 20){
     7b6:	fd442783          	lw	a5,-44(s0)
     7ba:	0007871b          	sext.w	a4,a5
     7be:	47d1                	li	a5,20
     7c0:	0af71f63          	bne	a4,a5,87e <go+0x7b6>
      int pid = fork();
     7c4:	00001097          	auipc	ra,0x1
     7c8:	be2080e7          	jalr	-1054(ra) # 13a6 <fork>
     7cc:	87aa                	mv	a5,a0
     7ce:	fcf42223          	sw	a5,-60(s0)
      if(pid == 0){
     7d2:	fc442783          	lw	a5,-60(s0)
     7d6:	2781                	sext.w	a5,a5
     7d8:	ebbd                	bnez	a5,84e <go+0x786>
        unlink("a");
     7da:	00001517          	auipc	a0,0x1
     7de:	57650513          	addi	a0,a0,1398 # 1d50 <malloc+0x268>
     7e2:	00001097          	auipc	ra,0x1
     7e6:	c1c080e7          	jalr	-996(ra) # 13fe <unlink>
        mkdir("a");
     7ea:	00001517          	auipc	a0,0x1
     7ee:	56650513          	addi	a0,a0,1382 # 1d50 <malloc+0x268>
     7f2:	00001097          	auipc	ra,0x1
     7f6:	c24080e7          	jalr	-988(ra) # 1416 <mkdir>
        chdir("a");
     7fa:	00001517          	auipc	a0,0x1
     7fe:	55650513          	addi	a0,a0,1366 # 1d50 <malloc+0x268>
     802:	00001097          	auipc	ra,0x1
     806:	c1c080e7          	jalr	-996(ra) # 141e <chdir>
        unlink("../a");
     80a:	00001517          	auipc	a0,0x1
     80e:	5d650513          	addi	a0,a0,1494 # 1de0 <malloc+0x2f8>
     812:	00001097          	auipc	ra,0x1
     816:	bec080e7          	jalr	-1044(ra) # 13fe <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     81a:	20200593          	li	a1,514
     81e:	00001517          	auipc	a0,0x1
     822:	57a50513          	addi	a0,a0,1402 # 1d98 <malloc+0x2b0>
     826:	00001097          	auipc	ra,0x1
     82a:	bc8080e7          	jalr	-1080(ra) # 13ee <open>
     82e:	87aa                	mv	a5,a0
     830:	fef42623          	sw	a5,-20(s0)
        unlink("x");
     834:	00001517          	auipc	a0,0x1
     838:	56450513          	addi	a0,a0,1380 # 1d98 <malloc+0x2b0>
     83c:	00001097          	auipc	ra,0x1
     840:	bc2080e7          	jalr	-1086(ra) # 13fe <unlink>
        exit(0);
     844:	4501                	li	a0,0
     846:	00001097          	auipc	ra,0x1
     84a:	b68080e7          	jalr	-1176(ra) # 13ae <exit>
      } else if(pid < 0){
     84e:	fc442783          	lw	a5,-60(s0)
     852:	2781                	sext.w	a5,a5
     854:	0007df63          	bgez	a5,872 <go+0x7aa>
        printf("grind: fork failed\n");
     858:	00001517          	auipc	a0,0x1
     85c:	4e050513          	addi	a0,a0,1248 # 1d38 <malloc+0x250>
     860:	00001097          	auipc	ra,0x1
     864:	096080e7          	jalr	150(ra) # 18f6 <printf>
        exit(1);
     868:	4505                	li	a0,1
     86a:	00001097          	auipc	ra,0x1
     86e:	b44080e7          	jalr	-1212(ra) # 13ae <exit>
      }
      wait(0);
     872:	4501                	li	a0,0
     874:	00001097          	auipc	ra,0x1
     878:	b42080e7          	jalr	-1214(ra) # 13b6 <wait>
     87c:	b0c1                	j	13c <go+0x74>
    } else if(what == 21){
     87e:	fd442783          	lw	a5,-44(s0)
     882:	0007871b          	sext.w	a4,a5
     886:	47d5                	li	a5,21
     888:	12f71e63          	bne	a4,a5,9c4 <go+0x8fc>
      unlink("c");
     88c:	00001517          	auipc	a0,0x1
     890:	55c50513          	addi	a0,a0,1372 # 1de8 <malloc+0x300>
     894:	00001097          	auipc	ra,0x1
     898:	b6a080e7          	jalr	-1174(ra) # 13fe <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     89c:	20200593          	li	a1,514
     8a0:	00001517          	auipc	a0,0x1
     8a4:	54850513          	addi	a0,a0,1352 # 1de8 <malloc+0x300>
     8a8:	00001097          	auipc	ra,0x1
     8ac:	b46080e7          	jalr	-1210(ra) # 13ee <open>
     8b0:	87aa                	mv	a5,a0
     8b2:	fcf42423          	sw	a5,-56(s0)
      if(fd1 < 0){
     8b6:	fc842783          	lw	a5,-56(s0)
     8ba:	2781                	sext.w	a5,a5
     8bc:	0007df63          	bgez	a5,8da <go+0x812>
        printf("grind: create c failed\n");
     8c0:	00001517          	auipc	a0,0x1
     8c4:	53050513          	addi	a0,a0,1328 # 1df0 <malloc+0x308>
     8c8:	00001097          	auipc	ra,0x1
     8cc:	02e080e7          	jalr	46(ra) # 18f6 <printf>
        exit(1);
     8d0:	4505                	li	a0,1
     8d2:	00001097          	auipc	ra,0x1
     8d6:	adc080e7          	jalr	-1316(ra) # 13ae <exit>
      }
      if(write(fd1, "x", 1) != 1){
     8da:	fc842783          	lw	a5,-56(s0)
     8de:	4605                	li	a2,1
     8e0:	00001597          	auipc	a1,0x1
     8e4:	4b858593          	addi	a1,a1,1208 # 1d98 <malloc+0x2b0>
     8e8:	853e                	mv	a0,a5
     8ea:	00001097          	auipc	ra,0x1
     8ee:	ae4080e7          	jalr	-1308(ra) # 13ce <write>
     8f2:	87aa                	mv	a5,a0
     8f4:	873e                	mv	a4,a5
     8f6:	4785                	li	a5,1
     8f8:	00f70f63          	beq	a4,a5,916 <go+0x84e>
        printf("grind: write c failed\n");
     8fc:	00001517          	auipc	a0,0x1
     900:	50c50513          	addi	a0,a0,1292 # 1e08 <malloc+0x320>
     904:	00001097          	auipc	ra,0x1
     908:	ff2080e7          	jalr	-14(ra) # 18f6 <printf>
        exit(1);
     90c:	4505                	li	a0,1
     90e:	00001097          	auipc	ra,0x1
     912:	aa0080e7          	jalr	-1376(ra) # 13ae <exit>
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     916:	f8840713          	addi	a4,s0,-120
     91a:	fc842783          	lw	a5,-56(s0)
     91e:	85ba                	mv	a1,a4
     920:	853e                	mv	a0,a5
     922:	00001097          	auipc	ra,0x1
     926:	ae4080e7          	jalr	-1308(ra) # 1406 <fstat>
     92a:	87aa                	mv	a5,a0
     92c:	cf91                	beqz	a5,948 <go+0x880>
        printf("grind: fstat failed\n");
     92e:	00001517          	auipc	a0,0x1
     932:	4f250513          	addi	a0,a0,1266 # 1e20 <malloc+0x338>
     936:	00001097          	auipc	ra,0x1
     93a:	fc0080e7          	jalr	-64(ra) # 18f6 <printf>
        exit(1);
     93e:	4505                	li	a0,1
     940:	00001097          	auipc	ra,0x1
     944:	a6e080e7          	jalr	-1426(ra) # 13ae <exit>
      }
      if(st.size != 1){
     948:	f9843703          	ld	a4,-104(s0)
     94c:	4785                	li	a5,1
     94e:	02f70363          	beq	a4,a5,974 <go+0x8ac>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     952:	f9843783          	ld	a5,-104(s0)
     956:	2781                	sext.w	a5,a5
     958:	85be                	mv	a1,a5
     95a:	00001517          	auipc	a0,0x1
     95e:	4de50513          	addi	a0,a0,1246 # 1e38 <malloc+0x350>
     962:	00001097          	auipc	ra,0x1
     966:	f94080e7          	jalr	-108(ra) # 18f6 <printf>
        exit(1);
     96a:	4505                	li	a0,1
     96c:	00001097          	auipc	ra,0x1
     970:	a42080e7          	jalr	-1470(ra) # 13ae <exit>
      }
      if(st.ino > 200){
     974:	f8c42783          	lw	a5,-116(s0)
     978:	873e                	mv	a4,a5
     97a:	0c800793          	li	a5,200
     97e:	02e7f263          	bgeu	a5,a4,9a2 <go+0x8da>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     982:	f8c42783          	lw	a5,-116(s0)
     986:	85be                	mv	a1,a5
     988:	00001517          	auipc	a0,0x1
     98c:	4d850513          	addi	a0,a0,1240 # 1e60 <malloc+0x378>
     990:	00001097          	auipc	ra,0x1
     994:	f66080e7          	jalr	-154(ra) # 18f6 <printf>
        exit(1);
     998:	4505                	li	a0,1
     99a:	00001097          	auipc	ra,0x1
     99e:	a14080e7          	jalr	-1516(ra) # 13ae <exit>
      }
      close(fd1);
     9a2:	fc842783          	lw	a5,-56(s0)
     9a6:	853e                	mv	a0,a5
     9a8:	00001097          	auipc	ra,0x1
     9ac:	a2e080e7          	jalr	-1490(ra) # 13d6 <close>
      unlink("c");
     9b0:	00001517          	auipc	a0,0x1
     9b4:	43850513          	addi	a0,a0,1080 # 1de8 <malloc+0x300>
     9b8:	00001097          	auipc	ra,0x1
     9bc:	a46080e7          	jalr	-1466(ra) # 13fe <unlink>
     9c0:	f7cff06f          	j	13c <go+0x74>
    } else if(what == 22){
     9c4:	fd442783          	lw	a5,-44(s0)
     9c8:	0007871b          	sext.w	a4,a5
     9cc:	47d9                	li	a5,22
     9ce:	f6f71763          	bne	a4,a5,13c <go+0x74>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     9d2:	f8040793          	addi	a5,s0,-128
     9d6:	853e                	mv	a0,a5
     9d8:	00001097          	auipc	ra,0x1
     9dc:	9e6080e7          	jalr	-1562(ra) # 13be <pipe>
     9e0:	87aa                	mv	a5,a0
     9e2:	0207d063          	bgez	a5,a02 <go+0x93a>
        fprintf(2, "grind: pipe failed\n");
     9e6:	00001597          	auipc	a1,0x1
     9ea:	39a58593          	addi	a1,a1,922 # 1d80 <malloc+0x298>
     9ee:	4509                	li	a0,2
     9f0:	00001097          	auipc	ra,0x1
     9f4:	eae080e7          	jalr	-338(ra) # 189e <fprintf>
        exit(1);
     9f8:	4505                	li	a0,1
     9fa:	00001097          	auipc	ra,0x1
     9fe:	9b4080e7          	jalr	-1612(ra) # 13ae <exit>
      }
      if(pipe(bb) < 0){
     a02:	f7840793          	addi	a5,s0,-136
     a06:	853e                	mv	a0,a5
     a08:	00001097          	auipc	ra,0x1
     a0c:	9b6080e7          	jalr	-1610(ra) # 13be <pipe>
     a10:	87aa                	mv	a5,a0
     a12:	0207d063          	bgez	a5,a32 <go+0x96a>
        fprintf(2, "grind: pipe failed\n");
     a16:	00001597          	auipc	a1,0x1
     a1a:	36a58593          	addi	a1,a1,874 # 1d80 <malloc+0x298>
     a1e:	4509                	li	a0,2
     a20:	00001097          	auipc	ra,0x1
     a24:	e7e080e7          	jalr	-386(ra) # 189e <fprintf>
        exit(1);
     a28:	4505                	li	a0,1
     a2a:	00001097          	auipc	ra,0x1
     a2e:	984080e7          	jalr	-1660(ra) # 13ae <exit>
      }
      int pid1 = fork();
     a32:	00001097          	auipc	ra,0x1
     a36:	974080e7          	jalr	-1676(ra) # 13a6 <fork>
     a3a:	87aa                	mv	a5,a0
     a3c:	fcf42823          	sw	a5,-48(s0)
      if(pid1 == 0){
     a40:	fd042783          	lw	a5,-48(s0)
     a44:	2781                	sext.w	a5,a5
     a46:	e3f9                	bnez	a5,b0c <go+0xa44>
        close(bb[0]);
     a48:	f7842783          	lw	a5,-136(s0)
     a4c:	853e                	mv	a0,a5
     a4e:	00001097          	auipc	ra,0x1
     a52:	988080e7          	jalr	-1656(ra) # 13d6 <close>
        close(bb[1]);
     a56:	f7c42783          	lw	a5,-132(s0)
     a5a:	853e                	mv	a0,a5
     a5c:	00001097          	auipc	ra,0x1
     a60:	97a080e7          	jalr	-1670(ra) # 13d6 <close>
        close(aa[0]);
     a64:	f8042783          	lw	a5,-128(s0)
     a68:	853e                	mv	a0,a5
     a6a:	00001097          	auipc	ra,0x1
     a6e:	96c080e7          	jalr	-1684(ra) # 13d6 <close>
        close(1);
     a72:	4505                	li	a0,1
     a74:	00001097          	auipc	ra,0x1
     a78:	962080e7          	jalr	-1694(ra) # 13d6 <close>
        if(dup(aa[1]) != 1){
     a7c:	f8442783          	lw	a5,-124(s0)
     a80:	853e                	mv	a0,a5
     a82:	00001097          	auipc	ra,0x1
     a86:	9a4080e7          	jalr	-1628(ra) # 1426 <dup>
     a8a:	87aa                	mv	a5,a0
     a8c:	873e                	mv	a4,a5
     a8e:	4785                	li	a5,1
     a90:	02f70063          	beq	a4,a5,ab0 <go+0x9e8>
          fprintf(2, "grind: dup failed\n");
     a94:	00001597          	auipc	a1,0x1
     a98:	3f458593          	addi	a1,a1,1012 # 1e88 <malloc+0x3a0>
     a9c:	4509                	li	a0,2
     a9e:	00001097          	auipc	ra,0x1
     aa2:	e00080e7          	jalr	-512(ra) # 189e <fprintf>
          exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00001097          	auipc	ra,0x1
     aac:	906080e7          	jalr	-1786(ra) # 13ae <exit>
        }
        close(aa[1]);
     ab0:	f8442783          	lw	a5,-124(s0)
     ab4:	853e                	mv	a0,a5
     ab6:	00001097          	auipc	ra,0x1
     aba:	920080e7          	jalr	-1760(ra) # 13d6 <close>
        char *args[3] = { "echo", "hi", 0 };
     abe:	00001797          	auipc	a5,0x1
     ac2:	3e278793          	addi	a5,a5,994 # 1ea0 <malloc+0x3b8>
     ac6:	f4f43823          	sd	a5,-176(s0)
     aca:	00001797          	auipc	a5,0x1
     ace:	3de78793          	addi	a5,a5,990 # 1ea8 <malloc+0x3c0>
     ad2:	f4f43c23          	sd	a5,-168(s0)
     ad6:	f6043023          	sd	zero,-160(s0)
        exec("grindir/../echo", args);
     ada:	f5040793          	addi	a5,s0,-176
     ade:	85be                	mv	a1,a5
     ae0:	00001517          	auipc	a0,0x1
     ae4:	3d050513          	addi	a0,a0,976 # 1eb0 <malloc+0x3c8>
     ae8:	00001097          	auipc	ra,0x1
     aec:	8fe080e7          	jalr	-1794(ra) # 13e6 <exec>
        fprintf(2, "grind: echo: not found\n");
     af0:	00001597          	auipc	a1,0x1
     af4:	3d058593          	addi	a1,a1,976 # 1ec0 <malloc+0x3d8>
     af8:	4509                	li	a0,2
     afa:	00001097          	auipc	ra,0x1
     afe:	da4080e7          	jalr	-604(ra) # 189e <fprintf>
        exit(2);
     b02:	4509                	li	a0,2
     b04:	00001097          	auipc	ra,0x1
     b08:	8aa080e7          	jalr	-1878(ra) # 13ae <exit>
      } else if(pid1 < 0){
     b0c:	fd042783          	lw	a5,-48(s0)
     b10:	2781                	sext.w	a5,a5
     b12:	0207d063          	bgez	a5,b32 <go+0xa6a>
        fprintf(2, "grind: fork failed\n");
     b16:	00001597          	auipc	a1,0x1
     b1a:	22258593          	addi	a1,a1,546 # 1d38 <malloc+0x250>
     b1e:	4509                	li	a0,2
     b20:	00001097          	auipc	ra,0x1
     b24:	d7e080e7          	jalr	-642(ra) # 189e <fprintf>
        exit(3);
     b28:	450d                	li	a0,3
     b2a:	00001097          	auipc	ra,0x1
     b2e:	884080e7          	jalr	-1916(ra) # 13ae <exit>
      }
      int pid2 = fork();
     b32:	00001097          	auipc	ra,0x1
     b36:	874080e7          	jalr	-1932(ra) # 13a6 <fork>
     b3a:	87aa                	mv	a5,a0
     b3c:	fcf42623          	sw	a5,-52(s0)
      if(pid2 == 0){
     b40:	fcc42783          	lw	a5,-52(s0)
     b44:	2781                	sext.w	a5,a5
     b46:	ebed                	bnez	a5,c38 <go+0xb70>
        close(aa[1]);
     b48:	f8442783          	lw	a5,-124(s0)
     b4c:	853e                	mv	a0,a5
     b4e:	00001097          	auipc	ra,0x1
     b52:	888080e7          	jalr	-1912(ra) # 13d6 <close>
        close(bb[0]);
     b56:	f7842783          	lw	a5,-136(s0)
     b5a:	853e                	mv	a0,a5
     b5c:	00001097          	auipc	ra,0x1
     b60:	87a080e7          	jalr	-1926(ra) # 13d6 <close>
        close(0);
     b64:	4501                	li	a0,0
     b66:	00001097          	auipc	ra,0x1
     b6a:	870080e7          	jalr	-1936(ra) # 13d6 <close>
        if(dup(aa[0]) != 0){
     b6e:	f8042783          	lw	a5,-128(s0)
     b72:	853e                	mv	a0,a5
     b74:	00001097          	auipc	ra,0x1
     b78:	8b2080e7          	jalr	-1870(ra) # 1426 <dup>
     b7c:	87aa                	mv	a5,a0
     b7e:	cf99                	beqz	a5,b9c <go+0xad4>
          fprintf(2, "grind: dup failed\n");
     b80:	00001597          	auipc	a1,0x1
     b84:	30858593          	addi	a1,a1,776 # 1e88 <malloc+0x3a0>
     b88:	4509                	li	a0,2
     b8a:	00001097          	auipc	ra,0x1
     b8e:	d14080e7          	jalr	-748(ra) # 189e <fprintf>
          exit(4);
     b92:	4511                	li	a0,4
     b94:	00001097          	auipc	ra,0x1
     b98:	81a080e7          	jalr	-2022(ra) # 13ae <exit>
        }
        close(aa[0]);
     b9c:	f8042783          	lw	a5,-128(s0)
     ba0:	853e                	mv	a0,a5
     ba2:	00001097          	auipc	ra,0x1
     ba6:	834080e7          	jalr	-1996(ra) # 13d6 <close>
        close(1);
     baa:	4505                	li	a0,1
     bac:	00001097          	auipc	ra,0x1
     bb0:	82a080e7          	jalr	-2006(ra) # 13d6 <close>
        if(dup(bb[1]) != 1){
     bb4:	f7c42783          	lw	a5,-132(s0)
     bb8:	853e                	mv	a0,a5
     bba:	00001097          	auipc	ra,0x1
     bbe:	86c080e7          	jalr	-1940(ra) # 1426 <dup>
     bc2:	87aa                	mv	a5,a0
     bc4:	873e                	mv	a4,a5
     bc6:	4785                	li	a5,1
     bc8:	02f70063          	beq	a4,a5,be8 <go+0xb20>
          fprintf(2, "grind: dup failed\n");
     bcc:	00001597          	auipc	a1,0x1
     bd0:	2bc58593          	addi	a1,a1,700 # 1e88 <malloc+0x3a0>
     bd4:	4509                	li	a0,2
     bd6:	00001097          	auipc	ra,0x1
     bda:	cc8080e7          	jalr	-824(ra) # 189e <fprintf>
          exit(5);
     bde:	4515                	li	a0,5
     be0:	00000097          	auipc	ra,0x0
     be4:	7ce080e7          	jalr	1998(ra) # 13ae <exit>
        }
        close(bb[1]);
     be8:	f7c42783          	lw	a5,-132(s0)
     bec:	853e                	mv	a0,a5
     bee:	00000097          	auipc	ra,0x0
     bf2:	7e8080e7          	jalr	2024(ra) # 13d6 <close>
        char *args[2] = { "cat", 0 };
     bf6:	00001797          	auipc	a5,0x1
     bfa:	2e278793          	addi	a5,a5,738 # 1ed8 <malloc+0x3f0>
     bfe:	f4f43023          	sd	a5,-192(s0)
     c02:	f4043423          	sd	zero,-184(s0)
        exec("/cat", args);
     c06:	f4040793          	addi	a5,s0,-192
     c0a:	85be                	mv	a1,a5
     c0c:	00001517          	auipc	a0,0x1
     c10:	2d450513          	addi	a0,a0,724 # 1ee0 <malloc+0x3f8>
     c14:	00000097          	auipc	ra,0x0
     c18:	7d2080e7          	jalr	2002(ra) # 13e6 <exec>
        fprintf(2, "grind: cat: not found\n");
     c1c:	00001597          	auipc	a1,0x1
     c20:	2cc58593          	addi	a1,a1,716 # 1ee8 <malloc+0x400>
     c24:	4509                	li	a0,2
     c26:	00001097          	auipc	ra,0x1
     c2a:	c78080e7          	jalr	-904(ra) # 189e <fprintf>
        exit(6);
     c2e:	4519                	li	a0,6
     c30:	00000097          	auipc	ra,0x0
     c34:	77e080e7          	jalr	1918(ra) # 13ae <exit>
      } else if(pid2 < 0){
     c38:	fcc42783          	lw	a5,-52(s0)
     c3c:	2781                	sext.w	a5,a5
     c3e:	0207d063          	bgez	a5,c5e <go+0xb96>
        fprintf(2, "grind: fork failed\n");
     c42:	00001597          	auipc	a1,0x1
     c46:	0f658593          	addi	a1,a1,246 # 1d38 <malloc+0x250>
     c4a:	4509                	li	a0,2
     c4c:	00001097          	auipc	ra,0x1
     c50:	c52080e7          	jalr	-942(ra) # 189e <fprintf>
        exit(7);
     c54:	451d                	li	a0,7
     c56:	00000097          	auipc	ra,0x0
     c5a:	758080e7          	jalr	1880(ra) # 13ae <exit>
      }
      close(aa[0]);
     c5e:	f8042783          	lw	a5,-128(s0)
     c62:	853e                	mv	a0,a5
     c64:	00000097          	auipc	ra,0x0
     c68:	772080e7          	jalr	1906(ra) # 13d6 <close>
      close(aa[1]);
     c6c:	f8442783          	lw	a5,-124(s0)
     c70:	853e                	mv	a0,a5
     c72:	00000097          	auipc	ra,0x0
     c76:	764080e7          	jalr	1892(ra) # 13d6 <close>
      close(bb[1]);
     c7a:	f7c42783          	lw	a5,-132(s0)
     c7e:	853e                	mv	a0,a5
     c80:	00000097          	auipc	ra,0x0
     c84:	756080e7          	jalr	1878(ra) # 13d6 <close>
      char buf[4] = { 0, 0, 0, 0 };
     c88:	f6042823          	sw	zero,-144(s0)
      read(bb[0], buf+0, 1);
     c8c:	f7842783          	lw	a5,-136(s0)
     c90:	f7040713          	addi	a4,s0,-144
     c94:	4605                	li	a2,1
     c96:	85ba                	mv	a1,a4
     c98:	853e                	mv	a0,a5
     c9a:	00000097          	auipc	ra,0x0
     c9e:	72c080e7          	jalr	1836(ra) # 13c6 <read>
      read(bb[0], buf+1, 1);
     ca2:	f7842703          	lw	a4,-136(s0)
     ca6:	f7040793          	addi	a5,s0,-144
     caa:	0785                	addi	a5,a5,1
     cac:	4605                	li	a2,1
     cae:	85be                	mv	a1,a5
     cb0:	853a                	mv	a0,a4
     cb2:	00000097          	auipc	ra,0x0
     cb6:	714080e7          	jalr	1812(ra) # 13c6 <read>
      read(bb[0], buf+2, 1);
     cba:	f7842703          	lw	a4,-136(s0)
     cbe:	f7040793          	addi	a5,s0,-144
     cc2:	0789                	addi	a5,a5,2
     cc4:	4605                	li	a2,1
     cc6:	85be                	mv	a1,a5
     cc8:	853a                	mv	a0,a4
     cca:	00000097          	auipc	ra,0x0
     cce:	6fc080e7          	jalr	1788(ra) # 13c6 <read>
      close(bb[0]);
     cd2:	f7842783          	lw	a5,-136(s0)
     cd6:	853e                	mv	a0,a5
     cd8:	00000097          	auipc	ra,0x0
     cdc:	6fe080e7          	jalr	1790(ra) # 13d6 <close>
      int st1, st2;
      wait(&st1);
     ce0:	f6c40793          	addi	a5,s0,-148
     ce4:	853e                	mv	a0,a5
     ce6:	00000097          	auipc	ra,0x0
     cea:	6d0080e7          	jalr	1744(ra) # 13b6 <wait>
      wait(&st2);
     cee:	f6840793          	addi	a5,s0,-152
     cf2:	853e                	mv	a0,a5
     cf4:	00000097          	auipc	ra,0x0
     cf8:	6c2080e7          	jalr	1730(ra) # 13b6 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     cfc:	f6c42783          	lw	a5,-148(s0)
     d00:	e395                	bnez	a5,d24 <go+0xc5c>
     d02:	f6842783          	lw	a5,-152(s0)
     d06:	ef99                	bnez	a5,d24 <go+0xc5c>
     d08:	f7040793          	addi	a5,s0,-144
     d0c:	00001597          	auipc	a1,0x1
     d10:	1f458593          	addi	a1,a1,500 # 1f00 <malloc+0x418>
     d14:	853e                	mv	a0,a5
     d16:	00000097          	auipc	ra,0x0
     d1a:	250080e7          	jalr	592(ra) # f66 <strcmp>
     d1e:	87aa                	mv	a5,a0
     d20:	c0078e63          	beqz	a5,13c <go+0x74>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     d24:	f6c42783          	lw	a5,-148(s0)
     d28:	f6842703          	lw	a4,-152(s0)
     d2c:	f7040693          	addi	a3,s0,-144
     d30:	863a                	mv	a2,a4
     d32:	85be                	mv	a1,a5
     d34:	00001517          	auipc	a0,0x1
     d38:	1d450513          	addi	a0,a0,468 # 1f08 <malloc+0x420>
     d3c:	00001097          	auipc	ra,0x1
     d40:	bba080e7          	jalr	-1094(ra) # 18f6 <printf>
        exit(1);
     d44:	4505                	li	a0,1
     d46:	00000097          	auipc	ra,0x0
     d4a:	668080e7          	jalr	1640(ra) # 13ae <exit>

0000000000000d4e <iter>:
  }
}

void
iter()
{
     d4e:	1101                	addi	sp,sp,-32
     d50:	ec06                	sd	ra,24(sp)
     d52:	e822                	sd	s0,16(sp)
     d54:	1000                	addi	s0,sp,32
  unlink("a");
     d56:	00001517          	auipc	a0,0x1
     d5a:	ffa50513          	addi	a0,a0,-6 # 1d50 <malloc+0x268>
     d5e:	00000097          	auipc	ra,0x0
     d62:	6a0080e7          	jalr	1696(ra) # 13fe <unlink>
  unlink("b");
     d66:	00001517          	auipc	a0,0x1
     d6a:	f9a50513          	addi	a0,a0,-102 # 1d00 <malloc+0x218>
     d6e:	00000097          	auipc	ra,0x0
     d72:	690080e7          	jalr	1680(ra) # 13fe <unlink>
  
  int pid1 = fork();
     d76:	00000097          	auipc	ra,0x0
     d7a:	630080e7          	jalr	1584(ra) # 13a6 <fork>
     d7e:	87aa                	mv	a5,a0
     d80:	fef42623          	sw	a5,-20(s0)
  if(pid1 < 0){
     d84:	fec42783          	lw	a5,-20(s0)
     d88:	2781                	sext.w	a5,a5
     d8a:	0007df63          	bgez	a5,da8 <iter+0x5a>
    printf("grind: fork failed\n");
     d8e:	00001517          	auipc	a0,0x1
     d92:	faa50513          	addi	a0,a0,-86 # 1d38 <malloc+0x250>
     d96:	00001097          	auipc	ra,0x1
     d9a:	b60080e7          	jalr	-1184(ra) # 18f6 <printf>
    exit(1);
     d9e:	4505                	li	a0,1
     da0:	00000097          	auipc	ra,0x0
     da4:	60e080e7          	jalr	1550(ra) # 13ae <exit>
  }
  if(pid1 == 0){
     da8:	fec42783          	lw	a5,-20(s0)
     dac:	2781                	sext.w	a5,a5
     dae:	e79d                	bnez	a5,ddc <iter+0x8e>
    rand_next ^= 31;
     db0:	00001797          	auipc	a5,0x1
     db4:	25078793          	addi	a5,a5,592 # 2000 <rand_next>
     db8:	639c                	ld	a5,0(a5)
     dba:	01f7c713          	xori	a4,a5,31
     dbe:	00001797          	auipc	a5,0x1
     dc2:	24278793          	addi	a5,a5,578 # 2000 <rand_next>
     dc6:	e398                	sd	a4,0(a5)
    go(0);
     dc8:	4501                	li	a0,0
     dca:	fffff097          	auipc	ra,0xfffff
     dce:	2fe080e7          	jalr	766(ra) # c8 <go>
    exit(0);
     dd2:	4501                	li	a0,0
     dd4:	00000097          	auipc	ra,0x0
     dd8:	5da080e7          	jalr	1498(ra) # 13ae <exit>
  }

  int pid2 = fork();
     ddc:	00000097          	auipc	ra,0x0
     de0:	5ca080e7          	jalr	1482(ra) # 13a6 <fork>
     de4:	87aa                	mv	a5,a0
     de6:	fef42423          	sw	a5,-24(s0)
  if(pid2 < 0){
     dea:	fe842783          	lw	a5,-24(s0)
     dee:	2781                	sext.w	a5,a5
     df0:	0007df63          	bgez	a5,e0e <iter+0xc0>
    printf("grind: fork failed\n");
     df4:	00001517          	auipc	a0,0x1
     df8:	f4450513          	addi	a0,a0,-188 # 1d38 <malloc+0x250>
     dfc:	00001097          	auipc	ra,0x1
     e00:	afa080e7          	jalr	-1286(ra) # 18f6 <printf>
    exit(1);
     e04:	4505                	li	a0,1
     e06:	00000097          	auipc	ra,0x0
     e0a:	5a8080e7          	jalr	1448(ra) # 13ae <exit>
  }
  if(pid2 == 0){
     e0e:	fe842783          	lw	a5,-24(s0)
     e12:	2781                	sext.w	a5,a5
     e14:	eb8d                	bnez	a5,e46 <iter+0xf8>
    rand_next ^= 7177;
     e16:	00001797          	auipc	a5,0x1
     e1a:	1ea78793          	addi	a5,a5,490 # 2000 <rand_next>
     e1e:	6398                	ld	a4,0(a5)
     e20:	6789                	lui	a5,0x2
     e22:	c0978793          	addi	a5,a5,-1015 # 1c09 <malloc+0x121>
     e26:	8f3d                	xor	a4,a4,a5
     e28:	00001797          	auipc	a5,0x1
     e2c:	1d878793          	addi	a5,a5,472 # 2000 <rand_next>
     e30:	e398                	sd	a4,0(a5)
    go(1);
     e32:	4505                	li	a0,1
     e34:	fffff097          	auipc	ra,0xfffff
     e38:	294080e7          	jalr	660(ra) # c8 <go>
    exit(0);
     e3c:	4501                	li	a0,0
     e3e:	00000097          	auipc	ra,0x0
     e42:	570080e7          	jalr	1392(ra) # 13ae <exit>
  }

  int st1 = -1;
     e46:	57fd                	li	a5,-1
     e48:	fef42223          	sw	a5,-28(s0)
  wait(&st1);
     e4c:	fe440793          	addi	a5,s0,-28
     e50:	853e                	mv	a0,a5
     e52:	00000097          	auipc	ra,0x0
     e56:	564080e7          	jalr	1380(ra) # 13b6 <wait>
  if(st1 != 0){
     e5a:	fe442783          	lw	a5,-28(s0)
     e5e:	cf99                	beqz	a5,e7c <iter+0x12e>
    kill(pid1);
     e60:	fec42783          	lw	a5,-20(s0)
     e64:	853e                	mv	a0,a5
     e66:	00000097          	auipc	ra,0x0
     e6a:	578080e7          	jalr	1400(ra) # 13de <kill>
    kill(pid2);
     e6e:	fe842783          	lw	a5,-24(s0)
     e72:	853e                	mv	a0,a5
     e74:	00000097          	auipc	ra,0x0
     e78:	56a080e7          	jalr	1386(ra) # 13de <kill>
  }
  int st2 = -1;
     e7c:	57fd                	li	a5,-1
     e7e:	fef42023          	sw	a5,-32(s0)
  wait(&st2);
     e82:	fe040793          	addi	a5,s0,-32
     e86:	853e                	mv	a0,a5
     e88:	00000097          	auipc	ra,0x0
     e8c:	52e080e7          	jalr	1326(ra) # 13b6 <wait>

  exit(0);
     e90:	4501                	li	a0,0
     e92:	00000097          	auipc	ra,0x0
     e96:	51c080e7          	jalr	1308(ra) # 13ae <exit>

0000000000000e9a <main>:
}

int
main()
{
     e9a:	1101                	addi	sp,sp,-32
     e9c:	ec06                	sd	ra,24(sp)
     e9e:	e822                	sd	s0,16(sp)
     ea0:	1000                	addi	s0,sp,32
  while(1){
    int pid = fork();
     ea2:	00000097          	auipc	ra,0x0
     ea6:	504080e7          	jalr	1284(ra) # 13a6 <fork>
     eaa:	87aa                	mv	a5,a0
     eac:	fef42623          	sw	a5,-20(s0)
    if(pid == 0){
     eb0:	fec42783          	lw	a5,-20(s0)
     eb4:	2781                	sext.w	a5,a5
     eb6:	eb91                	bnez	a5,eca <main+0x30>
      iter();
     eb8:	00000097          	auipc	ra,0x0
     ebc:	e96080e7          	jalr	-362(ra) # d4e <iter>
      exit(0);
     ec0:	4501                	li	a0,0
     ec2:	00000097          	auipc	ra,0x0
     ec6:	4ec080e7          	jalr	1260(ra) # 13ae <exit>
    }
    if(pid > 0){
     eca:	fec42783          	lw	a5,-20(s0)
     ece:	2781                	sext.w	a5,a5
     ed0:	00f05763          	blez	a5,ede <main+0x44>
      wait(0);
     ed4:	4501                	li	a0,0
     ed6:	00000097          	auipc	ra,0x0
     eda:	4e0080e7          	jalr	1248(ra) # 13b6 <wait>
    }
    sleep(20);
     ede:	4551                	li	a0,20
     ee0:	00000097          	auipc	ra,0x0
     ee4:	55e080e7          	jalr	1374(ra) # 143e <sleep>
    rand_next += 1;
     ee8:	00001797          	auipc	a5,0x1
     eec:	11878793          	addi	a5,a5,280 # 2000 <rand_next>
     ef0:	639c                	ld	a5,0(a5)
     ef2:	00178713          	addi	a4,a5,1
     ef6:	00001797          	auipc	a5,0x1
     efa:	10a78793          	addi	a5,a5,266 # 2000 <rand_next>
     efe:	e398                	sd	a4,0(a5)
  while(1){
     f00:	b74d                	j	ea2 <main+0x8>

0000000000000f02 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     f02:	1141                	addi	sp,sp,-16
     f04:	e406                	sd	ra,8(sp)
     f06:	e022                	sd	s0,0(sp)
     f08:	0800                	addi	s0,sp,16
  extern int main();
  main();
     f0a:	00000097          	auipc	ra,0x0
     f0e:	f90080e7          	jalr	-112(ra) # e9a <main>
  exit(0);
     f12:	4501                	li	a0,0
     f14:	00000097          	auipc	ra,0x0
     f18:	49a080e7          	jalr	1178(ra) # 13ae <exit>

0000000000000f1c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     f1c:	7179                	addi	sp,sp,-48
     f1e:	f422                	sd	s0,40(sp)
     f20:	1800                	addi	s0,sp,48
     f22:	fca43c23          	sd	a0,-40(s0)
     f26:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
     f2a:	fd843783          	ld	a5,-40(s0)
     f2e:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
     f32:	0001                	nop
     f34:	fd043703          	ld	a4,-48(s0)
     f38:	00170793          	addi	a5,a4,1
     f3c:	fcf43823          	sd	a5,-48(s0)
     f40:	fd843783          	ld	a5,-40(s0)
     f44:	00178693          	addi	a3,a5,1
     f48:	fcd43c23          	sd	a3,-40(s0)
     f4c:	00074703          	lbu	a4,0(a4)
     f50:	00e78023          	sb	a4,0(a5)
     f54:	0007c783          	lbu	a5,0(a5)
     f58:	fff1                	bnez	a5,f34 <strcpy+0x18>
    ;
  return os;
     f5a:	fe843783          	ld	a5,-24(s0)
}
     f5e:	853e                	mv	a0,a5
     f60:	7422                	ld	s0,40(sp)
     f62:	6145                	addi	sp,sp,48
     f64:	8082                	ret

0000000000000f66 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     f66:	1101                	addi	sp,sp,-32
     f68:	ec22                	sd	s0,24(sp)
     f6a:	1000                	addi	s0,sp,32
     f6c:	fea43423          	sd	a0,-24(s0)
     f70:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
     f74:	a819                	j	f8a <strcmp+0x24>
    p++, q++;
     f76:	fe843783          	ld	a5,-24(s0)
     f7a:	0785                	addi	a5,a5,1
     f7c:	fef43423          	sd	a5,-24(s0)
     f80:	fe043783          	ld	a5,-32(s0)
     f84:	0785                	addi	a5,a5,1
     f86:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
     f8a:	fe843783          	ld	a5,-24(s0)
     f8e:	0007c783          	lbu	a5,0(a5)
     f92:	cb99                	beqz	a5,fa8 <strcmp+0x42>
     f94:	fe843783          	ld	a5,-24(s0)
     f98:	0007c703          	lbu	a4,0(a5)
     f9c:	fe043783          	ld	a5,-32(s0)
     fa0:	0007c783          	lbu	a5,0(a5)
     fa4:	fcf709e3          	beq	a4,a5,f76 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
     fa8:	fe843783          	ld	a5,-24(s0)
     fac:	0007c783          	lbu	a5,0(a5)
     fb0:	0007871b          	sext.w	a4,a5
     fb4:	fe043783          	ld	a5,-32(s0)
     fb8:	0007c783          	lbu	a5,0(a5)
     fbc:	2781                	sext.w	a5,a5
     fbe:	40f707bb          	subw	a5,a4,a5
     fc2:	2781                	sext.w	a5,a5
}
     fc4:	853e                	mv	a0,a5
     fc6:	6462                	ld	s0,24(sp)
     fc8:	6105                	addi	sp,sp,32
     fca:	8082                	ret

0000000000000fcc <strlen>:

uint
strlen(const char *s)
{
     fcc:	7179                	addi	sp,sp,-48
     fce:	f422                	sd	s0,40(sp)
     fd0:	1800                	addi	s0,sp,48
     fd2:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
     fd6:	fe042623          	sw	zero,-20(s0)
     fda:	a031                	j	fe6 <strlen+0x1a>
     fdc:	fec42783          	lw	a5,-20(s0)
     fe0:	2785                	addiw	a5,a5,1
     fe2:	fef42623          	sw	a5,-20(s0)
     fe6:	fec42783          	lw	a5,-20(s0)
     fea:	fd843703          	ld	a4,-40(s0)
     fee:	97ba                	add	a5,a5,a4
     ff0:	0007c783          	lbu	a5,0(a5)
     ff4:	f7e5                	bnez	a5,fdc <strlen+0x10>
    ;
  return n;
     ff6:	fec42783          	lw	a5,-20(s0)
}
     ffa:	853e                	mv	a0,a5
     ffc:	7422                	ld	s0,40(sp)
     ffe:	6145                	addi	sp,sp,48
    1000:	8082                	ret

0000000000001002 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1002:	7179                	addi	sp,sp,-48
    1004:	f422                	sd	s0,40(sp)
    1006:	1800                	addi	s0,sp,48
    1008:	fca43c23          	sd	a0,-40(s0)
    100c:	87ae                	mv	a5,a1
    100e:	8732                	mv	a4,a2
    1010:	fcf42a23          	sw	a5,-44(s0)
    1014:	87ba                	mv	a5,a4
    1016:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
    101a:	fd843783          	ld	a5,-40(s0)
    101e:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
    1022:	fe042623          	sw	zero,-20(s0)
    1026:	a00d                	j	1048 <memset+0x46>
    cdst[i] = c;
    1028:	fec42783          	lw	a5,-20(s0)
    102c:	fe043703          	ld	a4,-32(s0)
    1030:	97ba                	add	a5,a5,a4
    1032:	fd442703          	lw	a4,-44(s0)
    1036:	0ff77713          	zext.b	a4,a4
    103a:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
    103e:	fec42783          	lw	a5,-20(s0)
    1042:	2785                	addiw	a5,a5,1
    1044:	fef42623          	sw	a5,-20(s0)
    1048:	fec42703          	lw	a4,-20(s0)
    104c:	fd042783          	lw	a5,-48(s0)
    1050:	2781                	sext.w	a5,a5
    1052:	fcf76be3          	bltu	a4,a5,1028 <memset+0x26>
  }
  return dst;
    1056:	fd843783          	ld	a5,-40(s0)
}
    105a:	853e                	mv	a0,a5
    105c:	7422                	ld	s0,40(sp)
    105e:	6145                	addi	sp,sp,48
    1060:	8082                	ret

0000000000001062 <strchr>:

char*
strchr(const char *s, char c)
{
    1062:	1101                	addi	sp,sp,-32
    1064:	ec22                	sd	s0,24(sp)
    1066:	1000                	addi	s0,sp,32
    1068:	fea43423          	sd	a0,-24(s0)
    106c:	87ae                	mv	a5,a1
    106e:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
    1072:	a01d                	j	1098 <strchr+0x36>
    if(*s == c)
    1074:	fe843783          	ld	a5,-24(s0)
    1078:	0007c703          	lbu	a4,0(a5)
    107c:	fe744783          	lbu	a5,-25(s0)
    1080:	0ff7f793          	zext.b	a5,a5
    1084:	00e79563          	bne	a5,a4,108e <strchr+0x2c>
      return (char*)s;
    1088:	fe843783          	ld	a5,-24(s0)
    108c:	a821                	j	10a4 <strchr+0x42>
  for(; *s; s++)
    108e:	fe843783          	ld	a5,-24(s0)
    1092:	0785                	addi	a5,a5,1
    1094:	fef43423          	sd	a5,-24(s0)
    1098:	fe843783          	ld	a5,-24(s0)
    109c:	0007c783          	lbu	a5,0(a5)
    10a0:	fbf1                	bnez	a5,1074 <strchr+0x12>
  return 0;
    10a2:	4781                	li	a5,0
}
    10a4:	853e                	mv	a0,a5
    10a6:	6462                	ld	s0,24(sp)
    10a8:	6105                	addi	sp,sp,32
    10aa:	8082                	ret

00000000000010ac <gets>:

char*
gets(char *buf, int max)
{
    10ac:	7179                	addi	sp,sp,-48
    10ae:	f406                	sd	ra,40(sp)
    10b0:	f022                	sd	s0,32(sp)
    10b2:	1800                	addi	s0,sp,48
    10b4:	fca43c23          	sd	a0,-40(s0)
    10b8:	87ae                	mv	a5,a1
    10ba:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    10be:	fe042623          	sw	zero,-20(s0)
    10c2:	a8a1                	j	111a <gets+0x6e>
    cc = read(0, &c, 1);
    10c4:	fe740793          	addi	a5,s0,-25
    10c8:	4605                	li	a2,1
    10ca:	85be                	mv	a1,a5
    10cc:	4501                	li	a0,0
    10ce:	00000097          	auipc	ra,0x0
    10d2:	2f8080e7          	jalr	760(ra) # 13c6 <read>
    10d6:	87aa                	mv	a5,a0
    10d8:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
    10dc:	fe842783          	lw	a5,-24(s0)
    10e0:	2781                	sext.w	a5,a5
    10e2:	04f05763          	blez	a5,1130 <gets+0x84>
      break;
    buf[i++] = c;
    10e6:	fec42783          	lw	a5,-20(s0)
    10ea:	0017871b          	addiw	a4,a5,1
    10ee:	fee42623          	sw	a4,-20(s0)
    10f2:	873e                	mv	a4,a5
    10f4:	fd843783          	ld	a5,-40(s0)
    10f8:	97ba                	add	a5,a5,a4
    10fa:	fe744703          	lbu	a4,-25(s0)
    10fe:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
    1102:	fe744783          	lbu	a5,-25(s0)
    1106:	873e                	mv	a4,a5
    1108:	47a9                	li	a5,10
    110a:	02f70463          	beq	a4,a5,1132 <gets+0x86>
    110e:	fe744783          	lbu	a5,-25(s0)
    1112:	873e                	mv	a4,a5
    1114:	47b5                	li	a5,13
    1116:	00f70e63          	beq	a4,a5,1132 <gets+0x86>
  for(i=0; i+1 < max; ){
    111a:	fec42783          	lw	a5,-20(s0)
    111e:	2785                	addiw	a5,a5,1
    1120:	0007871b          	sext.w	a4,a5
    1124:	fd442783          	lw	a5,-44(s0)
    1128:	2781                	sext.w	a5,a5
    112a:	f8f74de3          	blt	a4,a5,10c4 <gets+0x18>
    112e:	a011                	j	1132 <gets+0x86>
      break;
    1130:	0001                	nop
      break;
  }
  buf[i] = '\0';
    1132:	fec42783          	lw	a5,-20(s0)
    1136:	fd843703          	ld	a4,-40(s0)
    113a:	97ba                	add	a5,a5,a4
    113c:	00078023          	sb	zero,0(a5)
  return buf;
    1140:	fd843783          	ld	a5,-40(s0)
}
    1144:	853e                	mv	a0,a5
    1146:	70a2                	ld	ra,40(sp)
    1148:	7402                	ld	s0,32(sp)
    114a:	6145                	addi	sp,sp,48
    114c:	8082                	ret

000000000000114e <stat>:

int
stat(const char *n, struct stat *st)
{
    114e:	7179                	addi	sp,sp,-48
    1150:	f406                	sd	ra,40(sp)
    1152:	f022                	sd	s0,32(sp)
    1154:	1800                	addi	s0,sp,48
    1156:	fca43c23          	sd	a0,-40(s0)
    115a:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    115e:	4581                	li	a1,0
    1160:	fd843503          	ld	a0,-40(s0)
    1164:	00000097          	auipc	ra,0x0
    1168:	28a080e7          	jalr	650(ra) # 13ee <open>
    116c:	87aa                	mv	a5,a0
    116e:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
    1172:	fec42783          	lw	a5,-20(s0)
    1176:	2781                	sext.w	a5,a5
    1178:	0007d463          	bgez	a5,1180 <stat+0x32>
    return -1;
    117c:	57fd                	li	a5,-1
    117e:	a035                	j	11aa <stat+0x5c>
  r = fstat(fd, st);
    1180:	fec42783          	lw	a5,-20(s0)
    1184:	fd043583          	ld	a1,-48(s0)
    1188:	853e                	mv	a0,a5
    118a:	00000097          	auipc	ra,0x0
    118e:	27c080e7          	jalr	636(ra) # 1406 <fstat>
    1192:	87aa                	mv	a5,a0
    1194:	fef42423          	sw	a5,-24(s0)
  close(fd);
    1198:	fec42783          	lw	a5,-20(s0)
    119c:	853e                	mv	a0,a5
    119e:	00000097          	auipc	ra,0x0
    11a2:	238080e7          	jalr	568(ra) # 13d6 <close>
  return r;
    11a6:	fe842783          	lw	a5,-24(s0)
}
    11aa:	853e                	mv	a0,a5
    11ac:	70a2                	ld	ra,40(sp)
    11ae:	7402                	ld	s0,32(sp)
    11b0:	6145                	addi	sp,sp,48
    11b2:	8082                	ret

00000000000011b4 <atoi>:

int
atoi(const char *s)
{
    11b4:	7179                	addi	sp,sp,-48
    11b6:	f422                	sd	s0,40(sp)
    11b8:	1800                	addi	s0,sp,48
    11ba:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
    11be:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
    11c2:	a81d                	j	11f8 <atoi+0x44>
    n = n*10 + *s++ - '0';
    11c4:	fec42783          	lw	a5,-20(s0)
    11c8:	873e                	mv	a4,a5
    11ca:	87ba                	mv	a5,a4
    11cc:	0027979b          	slliw	a5,a5,0x2
    11d0:	9fb9                	addw	a5,a5,a4
    11d2:	0017979b          	slliw	a5,a5,0x1
    11d6:	0007871b          	sext.w	a4,a5
    11da:	fd843783          	ld	a5,-40(s0)
    11de:	00178693          	addi	a3,a5,1
    11e2:	fcd43c23          	sd	a3,-40(s0)
    11e6:	0007c783          	lbu	a5,0(a5)
    11ea:	2781                	sext.w	a5,a5
    11ec:	9fb9                	addw	a5,a5,a4
    11ee:	2781                	sext.w	a5,a5
    11f0:	fd07879b          	addiw	a5,a5,-48
    11f4:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
    11f8:	fd843783          	ld	a5,-40(s0)
    11fc:	0007c783          	lbu	a5,0(a5)
    1200:	873e                	mv	a4,a5
    1202:	02f00793          	li	a5,47
    1206:	00e7fb63          	bgeu	a5,a4,121c <atoi+0x68>
    120a:	fd843783          	ld	a5,-40(s0)
    120e:	0007c783          	lbu	a5,0(a5)
    1212:	873e                	mv	a4,a5
    1214:	03900793          	li	a5,57
    1218:	fae7f6e3          	bgeu	a5,a4,11c4 <atoi+0x10>
  return n;
    121c:	fec42783          	lw	a5,-20(s0)
}
    1220:	853e                	mv	a0,a5
    1222:	7422                	ld	s0,40(sp)
    1224:	6145                	addi	sp,sp,48
    1226:	8082                	ret

0000000000001228 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    1228:	7139                	addi	sp,sp,-64
    122a:	fc22                	sd	s0,56(sp)
    122c:	0080                	addi	s0,sp,64
    122e:	fca43c23          	sd	a0,-40(s0)
    1232:	fcb43823          	sd	a1,-48(s0)
    1236:	87b2                	mv	a5,a2
    1238:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
    123c:	fd843783          	ld	a5,-40(s0)
    1240:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
    1244:	fd043783          	ld	a5,-48(s0)
    1248:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
    124c:	fe043703          	ld	a4,-32(s0)
    1250:	fe843783          	ld	a5,-24(s0)
    1254:	02e7fc63          	bgeu	a5,a4,128c <memmove+0x64>
    while(n-- > 0)
    1258:	a00d                	j	127a <memmove+0x52>
      *dst++ = *src++;
    125a:	fe043703          	ld	a4,-32(s0)
    125e:	00170793          	addi	a5,a4,1
    1262:	fef43023          	sd	a5,-32(s0)
    1266:	fe843783          	ld	a5,-24(s0)
    126a:	00178693          	addi	a3,a5,1
    126e:	fed43423          	sd	a3,-24(s0)
    1272:	00074703          	lbu	a4,0(a4)
    1276:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    127a:	fcc42783          	lw	a5,-52(s0)
    127e:	fff7871b          	addiw	a4,a5,-1
    1282:	fce42623          	sw	a4,-52(s0)
    1286:	fcf04ae3          	bgtz	a5,125a <memmove+0x32>
    128a:	a891                	j	12de <memmove+0xb6>
  } else {
    dst += n;
    128c:	fcc42783          	lw	a5,-52(s0)
    1290:	fe843703          	ld	a4,-24(s0)
    1294:	97ba                	add	a5,a5,a4
    1296:	fef43423          	sd	a5,-24(s0)
    src += n;
    129a:	fcc42783          	lw	a5,-52(s0)
    129e:	fe043703          	ld	a4,-32(s0)
    12a2:	97ba                	add	a5,a5,a4
    12a4:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
    12a8:	a01d                	j	12ce <memmove+0xa6>
      *--dst = *--src;
    12aa:	fe043783          	ld	a5,-32(s0)
    12ae:	17fd                	addi	a5,a5,-1
    12b0:	fef43023          	sd	a5,-32(s0)
    12b4:	fe843783          	ld	a5,-24(s0)
    12b8:	17fd                	addi	a5,a5,-1
    12ba:	fef43423          	sd	a5,-24(s0)
    12be:	fe043783          	ld	a5,-32(s0)
    12c2:	0007c703          	lbu	a4,0(a5)
    12c6:	fe843783          	ld	a5,-24(s0)
    12ca:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    12ce:	fcc42783          	lw	a5,-52(s0)
    12d2:	fff7871b          	addiw	a4,a5,-1
    12d6:	fce42623          	sw	a4,-52(s0)
    12da:	fcf048e3          	bgtz	a5,12aa <memmove+0x82>
  }
  return vdst;
    12de:	fd843783          	ld	a5,-40(s0)
}
    12e2:	853e                	mv	a0,a5
    12e4:	7462                	ld	s0,56(sp)
    12e6:	6121                	addi	sp,sp,64
    12e8:	8082                	ret

00000000000012ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    12ea:	7139                	addi	sp,sp,-64
    12ec:	fc22                	sd	s0,56(sp)
    12ee:	0080                	addi	s0,sp,64
    12f0:	fca43c23          	sd	a0,-40(s0)
    12f4:	fcb43823          	sd	a1,-48(s0)
    12f8:	87b2                	mv	a5,a2
    12fa:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
    12fe:	fd843783          	ld	a5,-40(s0)
    1302:	fef43423          	sd	a5,-24(s0)
    1306:	fd043783          	ld	a5,-48(s0)
    130a:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
    130e:	a0a1                	j	1356 <memcmp+0x6c>
    if (*p1 != *p2) {
    1310:	fe843783          	ld	a5,-24(s0)
    1314:	0007c703          	lbu	a4,0(a5)
    1318:	fe043783          	ld	a5,-32(s0)
    131c:	0007c783          	lbu	a5,0(a5)
    1320:	02f70163          	beq	a4,a5,1342 <memcmp+0x58>
      return *p1 - *p2;
    1324:	fe843783          	ld	a5,-24(s0)
    1328:	0007c783          	lbu	a5,0(a5)
    132c:	0007871b          	sext.w	a4,a5
    1330:	fe043783          	ld	a5,-32(s0)
    1334:	0007c783          	lbu	a5,0(a5)
    1338:	2781                	sext.w	a5,a5
    133a:	40f707bb          	subw	a5,a4,a5
    133e:	2781                	sext.w	a5,a5
    1340:	a01d                	j	1366 <memcmp+0x7c>
    }
    p1++;
    1342:	fe843783          	ld	a5,-24(s0)
    1346:	0785                	addi	a5,a5,1
    1348:	fef43423          	sd	a5,-24(s0)
    p2++;
    134c:	fe043783          	ld	a5,-32(s0)
    1350:	0785                	addi	a5,a5,1
    1352:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
    1356:	fcc42783          	lw	a5,-52(s0)
    135a:	fff7871b          	addiw	a4,a5,-1
    135e:	fce42623          	sw	a4,-52(s0)
    1362:	f7dd                	bnez	a5,1310 <memcmp+0x26>
  }
  return 0;
    1364:	4781                	li	a5,0
}
    1366:	853e                	mv	a0,a5
    1368:	7462                	ld	s0,56(sp)
    136a:	6121                	addi	sp,sp,64
    136c:	8082                	ret

000000000000136e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    136e:	7179                	addi	sp,sp,-48
    1370:	f406                	sd	ra,40(sp)
    1372:	f022                	sd	s0,32(sp)
    1374:	1800                	addi	s0,sp,48
    1376:	fea43423          	sd	a0,-24(s0)
    137a:	feb43023          	sd	a1,-32(s0)
    137e:	87b2                	mv	a5,a2
    1380:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
    1384:	fdc42783          	lw	a5,-36(s0)
    1388:	863e                	mv	a2,a5
    138a:	fe043583          	ld	a1,-32(s0)
    138e:	fe843503          	ld	a0,-24(s0)
    1392:	00000097          	auipc	ra,0x0
    1396:	e96080e7          	jalr	-362(ra) # 1228 <memmove>
    139a:	87aa                	mv	a5,a0
}
    139c:	853e                	mv	a0,a5
    139e:	70a2                	ld	ra,40(sp)
    13a0:	7402                	ld	s0,32(sp)
    13a2:	6145                	addi	sp,sp,48
    13a4:	8082                	ret

00000000000013a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    13a6:	4885                	li	a7,1
 ecall
    13a8:	00000073          	ecall
 ret
    13ac:	8082                	ret

00000000000013ae <exit>:
.global exit
exit:
 li a7, SYS_exit
    13ae:	4889                	li	a7,2
 ecall
    13b0:	00000073          	ecall
 ret
    13b4:	8082                	ret

00000000000013b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
    13b6:	488d                	li	a7,3
 ecall
    13b8:	00000073          	ecall
 ret
    13bc:	8082                	ret

00000000000013be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    13be:	4891                	li	a7,4
 ecall
    13c0:	00000073          	ecall
 ret
    13c4:	8082                	ret

00000000000013c6 <read>:
.global read
read:
 li a7, SYS_read
    13c6:	4895                	li	a7,5
 ecall
    13c8:	00000073          	ecall
 ret
    13cc:	8082                	ret

00000000000013ce <write>:
.global write
write:
 li a7, SYS_write
    13ce:	48c1                	li	a7,16
 ecall
    13d0:	00000073          	ecall
 ret
    13d4:	8082                	ret

00000000000013d6 <close>:
.global close
close:
 li a7, SYS_close
    13d6:	48d5                	li	a7,21
 ecall
    13d8:	00000073          	ecall
 ret
    13dc:	8082                	ret

00000000000013de <kill>:
.global kill
kill:
 li a7, SYS_kill
    13de:	4899                	li	a7,6
 ecall
    13e0:	00000073          	ecall
 ret
    13e4:	8082                	ret

00000000000013e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
    13e6:	489d                	li	a7,7
 ecall
    13e8:	00000073          	ecall
 ret
    13ec:	8082                	ret

00000000000013ee <open>:
.global open
open:
 li a7, SYS_open
    13ee:	48bd                	li	a7,15
 ecall
    13f0:	00000073          	ecall
 ret
    13f4:	8082                	ret

00000000000013f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    13f6:	48c5                	li	a7,17
 ecall
    13f8:	00000073          	ecall
 ret
    13fc:	8082                	ret

00000000000013fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    13fe:	48c9                	li	a7,18
 ecall
    1400:	00000073          	ecall
 ret
    1404:	8082                	ret

0000000000001406 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1406:	48a1                	li	a7,8
 ecall
    1408:	00000073          	ecall
 ret
    140c:	8082                	ret

000000000000140e <link>:
.global link
link:
 li a7, SYS_link
    140e:	48cd                	li	a7,19
 ecall
    1410:	00000073          	ecall
 ret
    1414:	8082                	ret

0000000000001416 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    1416:	48d1                	li	a7,20
 ecall
    1418:	00000073          	ecall
 ret
    141c:	8082                	ret

000000000000141e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    141e:	48a5                	li	a7,9
 ecall
    1420:	00000073          	ecall
 ret
    1424:	8082                	ret

0000000000001426 <dup>:
.global dup
dup:
 li a7, SYS_dup
    1426:	48a9                	li	a7,10
 ecall
    1428:	00000073          	ecall
 ret
    142c:	8082                	ret

000000000000142e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    142e:	48ad                	li	a7,11
 ecall
    1430:	00000073          	ecall
 ret
    1434:	8082                	ret

0000000000001436 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    1436:	48b1                	li	a7,12
 ecall
    1438:	00000073          	ecall
 ret
    143c:	8082                	ret

000000000000143e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    143e:	48b5                	li	a7,13
 ecall
    1440:	00000073          	ecall
 ret
    1444:	8082                	ret

0000000000001446 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    1446:	48b9                	li	a7,14
 ecall
    1448:	00000073          	ecall
 ret
    144c:	8082                	ret

000000000000144e <hello>:
.global hello
hello:
 li a7, SYS_hello
    144e:	48d9                	li	a7,22
 ecall
    1450:	00000073          	ecall
 ret
    1454:	8082                	ret

0000000000001456 <ps>:
.global ps
ps:
 li a7, SYS_ps
    1456:	48e1                	li	a7,24
 ecall
    1458:	00000073          	ecall
 ret
    145c:	8082                	ret

000000000000145e <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
    145e:	48dd                	li	a7,23
 ecall
    1460:	00000073          	ecall
 ret
    1464:	8082                	ret

0000000000001466 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
    1466:	48e5                	li	a7,25
 ecall
    1468:	00000073          	ecall
 ret
    146c:	8082                	ret

000000000000146e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    146e:	1101                	addi	sp,sp,-32
    1470:	ec06                	sd	ra,24(sp)
    1472:	e822                	sd	s0,16(sp)
    1474:	1000                	addi	s0,sp,32
    1476:	87aa                	mv	a5,a0
    1478:	872e                	mv	a4,a1
    147a:	fef42623          	sw	a5,-20(s0)
    147e:	87ba                	mv	a5,a4
    1480:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
    1484:	feb40713          	addi	a4,s0,-21
    1488:	fec42783          	lw	a5,-20(s0)
    148c:	4605                	li	a2,1
    148e:	85ba                	mv	a1,a4
    1490:	853e                	mv	a0,a5
    1492:	00000097          	auipc	ra,0x0
    1496:	f3c080e7          	jalr	-196(ra) # 13ce <write>
}
    149a:	0001                	nop
    149c:	60e2                	ld	ra,24(sp)
    149e:	6442                	ld	s0,16(sp)
    14a0:	6105                	addi	sp,sp,32
    14a2:	8082                	ret

00000000000014a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    14a4:	7139                	addi	sp,sp,-64
    14a6:	fc06                	sd	ra,56(sp)
    14a8:	f822                	sd	s0,48(sp)
    14aa:	0080                	addi	s0,sp,64
    14ac:	87aa                	mv	a5,a0
    14ae:	8736                	mv	a4,a3
    14b0:	fcf42623          	sw	a5,-52(s0)
    14b4:	87ae                	mv	a5,a1
    14b6:	fcf42423          	sw	a5,-56(s0)
    14ba:	87b2                	mv	a5,a2
    14bc:	fcf42223          	sw	a5,-60(s0)
    14c0:	87ba                	mv	a5,a4
    14c2:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    14c6:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
    14ca:	fc042783          	lw	a5,-64(s0)
    14ce:	2781                	sext.w	a5,a5
    14d0:	c38d                	beqz	a5,14f2 <printint+0x4e>
    14d2:	fc842783          	lw	a5,-56(s0)
    14d6:	2781                	sext.w	a5,a5
    14d8:	0007dd63          	bgez	a5,14f2 <printint+0x4e>
    neg = 1;
    14dc:	4785                	li	a5,1
    14de:	fef42423          	sw	a5,-24(s0)
    x = -xx;
    14e2:	fc842783          	lw	a5,-56(s0)
    14e6:	40f007bb          	negw	a5,a5
    14ea:	2781                	sext.w	a5,a5
    14ec:	fef42223          	sw	a5,-28(s0)
    14f0:	a029                	j	14fa <printint+0x56>
  } else {
    x = xx;
    14f2:	fc842783          	lw	a5,-56(s0)
    14f6:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
    14fa:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
    14fe:	fc442783          	lw	a5,-60(s0)
    1502:	fe442703          	lw	a4,-28(s0)
    1506:	02f777bb          	remuw	a5,a4,a5
    150a:	0007861b          	sext.w	a2,a5
    150e:	fec42783          	lw	a5,-20(s0)
    1512:	0017871b          	addiw	a4,a5,1
    1516:	fee42623          	sw	a4,-20(s0)
    151a:	00001697          	auipc	a3,0x1
    151e:	af668693          	addi	a3,a3,-1290 # 2010 <digits>
    1522:	02061713          	slli	a4,a2,0x20
    1526:	9301                	srli	a4,a4,0x20
    1528:	9736                	add	a4,a4,a3
    152a:	00074703          	lbu	a4,0(a4)
    152e:	17c1                	addi	a5,a5,-16
    1530:	97a2                	add	a5,a5,s0
    1532:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
    1536:	fc442783          	lw	a5,-60(s0)
    153a:	fe442703          	lw	a4,-28(s0)
    153e:	02f757bb          	divuw	a5,a4,a5
    1542:	fef42223          	sw	a5,-28(s0)
    1546:	fe442783          	lw	a5,-28(s0)
    154a:	2781                	sext.w	a5,a5
    154c:	fbcd                	bnez	a5,14fe <printint+0x5a>
  if(neg)
    154e:	fe842783          	lw	a5,-24(s0)
    1552:	2781                	sext.w	a5,a5
    1554:	cf85                	beqz	a5,158c <printint+0xe8>
    buf[i++] = '-';
    1556:	fec42783          	lw	a5,-20(s0)
    155a:	0017871b          	addiw	a4,a5,1
    155e:	fee42623          	sw	a4,-20(s0)
    1562:	17c1                	addi	a5,a5,-16
    1564:	97a2                	add	a5,a5,s0
    1566:	02d00713          	li	a4,45
    156a:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
    156e:	a839                	j	158c <printint+0xe8>
    putc(fd, buf[i]);
    1570:	fec42783          	lw	a5,-20(s0)
    1574:	17c1                	addi	a5,a5,-16
    1576:	97a2                	add	a5,a5,s0
    1578:	fe07c703          	lbu	a4,-32(a5)
    157c:	fcc42783          	lw	a5,-52(s0)
    1580:	85ba                	mv	a1,a4
    1582:	853e                	mv	a0,a5
    1584:	00000097          	auipc	ra,0x0
    1588:	eea080e7          	jalr	-278(ra) # 146e <putc>
  while(--i >= 0)
    158c:	fec42783          	lw	a5,-20(s0)
    1590:	37fd                	addiw	a5,a5,-1
    1592:	fef42623          	sw	a5,-20(s0)
    1596:	fec42783          	lw	a5,-20(s0)
    159a:	2781                	sext.w	a5,a5
    159c:	fc07dae3          	bgez	a5,1570 <printint+0xcc>
}
    15a0:	0001                	nop
    15a2:	0001                	nop
    15a4:	70e2                	ld	ra,56(sp)
    15a6:	7442                	ld	s0,48(sp)
    15a8:	6121                	addi	sp,sp,64
    15aa:	8082                	ret

00000000000015ac <printptr>:

static void
printptr(int fd, uint64 x) {
    15ac:	7179                	addi	sp,sp,-48
    15ae:	f406                	sd	ra,40(sp)
    15b0:	f022                	sd	s0,32(sp)
    15b2:	1800                	addi	s0,sp,48
    15b4:	87aa                	mv	a5,a0
    15b6:	fcb43823          	sd	a1,-48(s0)
    15ba:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
    15be:	fdc42783          	lw	a5,-36(s0)
    15c2:	03000593          	li	a1,48
    15c6:	853e                	mv	a0,a5
    15c8:	00000097          	auipc	ra,0x0
    15cc:	ea6080e7          	jalr	-346(ra) # 146e <putc>
  putc(fd, 'x');
    15d0:	fdc42783          	lw	a5,-36(s0)
    15d4:	07800593          	li	a1,120
    15d8:	853e                	mv	a0,a5
    15da:	00000097          	auipc	ra,0x0
    15de:	e94080e7          	jalr	-364(ra) # 146e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    15e2:	fe042623          	sw	zero,-20(s0)
    15e6:	a82d                	j	1620 <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    15e8:	fd043783          	ld	a5,-48(s0)
    15ec:	93f1                	srli	a5,a5,0x3c
    15ee:	00001717          	auipc	a4,0x1
    15f2:	a2270713          	addi	a4,a4,-1502 # 2010 <digits>
    15f6:	97ba                	add	a5,a5,a4
    15f8:	0007c703          	lbu	a4,0(a5)
    15fc:	fdc42783          	lw	a5,-36(s0)
    1600:	85ba                	mv	a1,a4
    1602:	853e                	mv	a0,a5
    1604:	00000097          	auipc	ra,0x0
    1608:	e6a080e7          	jalr	-406(ra) # 146e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    160c:	fec42783          	lw	a5,-20(s0)
    1610:	2785                	addiw	a5,a5,1
    1612:	fef42623          	sw	a5,-20(s0)
    1616:	fd043783          	ld	a5,-48(s0)
    161a:	0792                	slli	a5,a5,0x4
    161c:	fcf43823          	sd	a5,-48(s0)
    1620:	fec42783          	lw	a5,-20(s0)
    1624:	873e                	mv	a4,a5
    1626:	47bd                	li	a5,15
    1628:	fce7f0e3          	bgeu	a5,a4,15e8 <printptr+0x3c>
}
    162c:	0001                	nop
    162e:	0001                	nop
    1630:	70a2                	ld	ra,40(sp)
    1632:	7402                	ld	s0,32(sp)
    1634:	6145                	addi	sp,sp,48
    1636:	8082                	ret

0000000000001638 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1638:	715d                	addi	sp,sp,-80
    163a:	e486                	sd	ra,72(sp)
    163c:	e0a2                	sd	s0,64(sp)
    163e:	0880                	addi	s0,sp,80
    1640:	87aa                	mv	a5,a0
    1642:	fcb43023          	sd	a1,-64(s0)
    1646:	fac43c23          	sd	a2,-72(s0)
    164a:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
    164e:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
    1652:	fe042223          	sw	zero,-28(s0)
    1656:	a42d                	j	1880 <vprintf+0x248>
    c = fmt[i] & 0xff;
    1658:	fe442783          	lw	a5,-28(s0)
    165c:	fc043703          	ld	a4,-64(s0)
    1660:	97ba                	add	a5,a5,a4
    1662:	0007c783          	lbu	a5,0(a5)
    1666:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
    166a:	fe042783          	lw	a5,-32(s0)
    166e:	2781                	sext.w	a5,a5
    1670:	eb9d                	bnez	a5,16a6 <vprintf+0x6e>
      if(c == '%'){
    1672:	fdc42783          	lw	a5,-36(s0)
    1676:	0007871b          	sext.w	a4,a5
    167a:	02500793          	li	a5,37
    167e:	00f71763          	bne	a4,a5,168c <vprintf+0x54>
        state = '%';
    1682:	02500793          	li	a5,37
    1686:	fef42023          	sw	a5,-32(s0)
    168a:	a2f5                	j	1876 <vprintf+0x23e>
      } else {
        putc(fd, c);
    168c:	fdc42783          	lw	a5,-36(s0)
    1690:	0ff7f713          	zext.b	a4,a5
    1694:	fcc42783          	lw	a5,-52(s0)
    1698:	85ba                	mv	a1,a4
    169a:	853e                	mv	a0,a5
    169c:	00000097          	auipc	ra,0x0
    16a0:	dd2080e7          	jalr	-558(ra) # 146e <putc>
    16a4:	aac9                	j	1876 <vprintf+0x23e>
      }
    } else if(state == '%'){
    16a6:	fe042783          	lw	a5,-32(s0)
    16aa:	0007871b          	sext.w	a4,a5
    16ae:	02500793          	li	a5,37
    16b2:	1cf71263          	bne	a4,a5,1876 <vprintf+0x23e>
      if(c == 'd'){
    16b6:	fdc42783          	lw	a5,-36(s0)
    16ba:	0007871b          	sext.w	a4,a5
    16be:	06400793          	li	a5,100
    16c2:	02f71463          	bne	a4,a5,16ea <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
    16c6:	fb843783          	ld	a5,-72(s0)
    16ca:	00878713          	addi	a4,a5,8
    16ce:	fae43c23          	sd	a4,-72(s0)
    16d2:	4398                	lw	a4,0(a5)
    16d4:	fcc42783          	lw	a5,-52(s0)
    16d8:	4685                	li	a3,1
    16da:	4629                	li	a2,10
    16dc:	85ba                	mv	a1,a4
    16de:	853e                	mv	a0,a5
    16e0:	00000097          	auipc	ra,0x0
    16e4:	dc4080e7          	jalr	-572(ra) # 14a4 <printint>
    16e8:	a269                	j	1872 <vprintf+0x23a>
      } else if(c == 'l') {
    16ea:	fdc42783          	lw	a5,-36(s0)
    16ee:	0007871b          	sext.w	a4,a5
    16f2:	06c00793          	li	a5,108
    16f6:	02f71663          	bne	a4,a5,1722 <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
    16fa:	fb843783          	ld	a5,-72(s0)
    16fe:	00878713          	addi	a4,a5,8
    1702:	fae43c23          	sd	a4,-72(s0)
    1706:	639c                	ld	a5,0(a5)
    1708:	0007871b          	sext.w	a4,a5
    170c:	fcc42783          	lw	a5,-52(s0)
    1710:	4681                	li	a3,0
    1712:	4629                	li	a2,10
    1714:	85ba                	mv	a1,a4
    1716:	853e                	mv	a0,a5
    1718:	00000097          	auipc	ra,0x0
    171c:	d8c080e7          	jalr	-628(ra) # 14a4 <printint>
    1720:	aa89                	j	1872 <vprintf+0x23a>
      } else if(c == 'x') {
    1722:	fdc42783          	lw	a5,-36(s0)
    1726:	0007871b          	sext.w	a4,a5
    172a:	07800793          	li	a5,120
    172e:	02f71463          	bne	a4,a5,1756 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
    1732:	fb843783          	ld	a5,-72(s0)
    1736:	00878713          	addi	a4,a5,8
    173a:	fae43c23          	sd	a4,-72(s0)
    173e:	4398                	lw	a4,0(a5)
    1740:	fcc42783          	lw	a5,-52(s0)
    1744:	4681                	li	a3,0
    1746:	4641                	li	a2,16
    1748:	85ba                	mv	a1,a4
    174a:	853e                	mv	a0,a5
    174c:	00000097          	auipc	ra,0x0
    1750:	d58080e7          	jalr	-680(ra) # 14a4 <printint>
    1754:	aa39                	j	1872 <vprintf+0x23a>
      } else if(c == 'p') {
    1756:	fdc42783          	lw	a5,-36(s0)
    175a:	0007871b          	sext.w	a4,a5
    175e:	07000793          	li	a5,112
    1762:	02f71263          	bne	a4,a5,1786 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
    1766:	fb843783          	ld	a5,-72(s0)
    176a:	00878713          	addi	a4,a5,8
    176e:	fae43c23          	sd	a4,-72(s0)
    1772:	6398                	ld	a4,0(a5)
    1774:	fcc42783          	lw	a5,-52(s0)
    1778:	85ba                	mv	a1,a4
    177a:	853e                	mv	a0,a5
    177c:	00000097          	auipc	ra,0x0
    1780:	e30080e7          	jalr	-464(ra) # 15ac <printptr>
    1784:	a0fd                	j	1872 <vprintf+0x23a>
      } else if(c == 's'){
    1786:	fdc42783          	lw	a5,-36(s0)
    178a:	0007871b          	sext.w	a4,a5
    178e:	07300793          	li	a5,115
    1792:	04f71c63          	bne	a4,a5,17ea <vprintf+0x1b2>
        s = va_arg(ap, char*);
    1796:	fb843783          	ld	a5,-72(s0)
    179a:	00878713          	addi	a4,a5,8
    179e:	fae43c23          	sd	a4,-72(s0)
    17a2:	639c                	ld	a5,0(a5)
    17a4:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
    17a8:	fe843783          	ld	a5,-24(s0)
    17ac:	eb8d                	bnez	a5,17de <vprintf+0x1a6>
          s = "(null)";
    17ae:	00000797          	auipc	a5,0x0
    17b2:	78278793          	addi	a5,a5,1922 # 1f30 <malloc+0x448>
    17b6:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
    17ba:	a015                	j	17de <vprintf+0x1a6>
          putc(fd, *s);
    17bc:	fe843783          	ld	a5,-24(s0)
    17c0:	0007c703          	lbu	a4,0(a5)
    17c4:	fcc42783          	lw	a5,-52(s0)
    17c8:	85ba                	mv	a1,a4
    17ca:	853e                	mv	a0,a5
    17cc:	00000097          	auipc	ra,0x0
    17d0:	ca2080e7          	jalr	-862(ra) # 146e <putc>
          s++;
    17d4:	fe843783          	ld	a5,-24(s0)
    17d8:	0785                	addi	a5,a5,1
    17da:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
    17de:	fe843783          	ld	a5,-24(s0)
    17e2:	0007c783          	lbu	a5,0(a5)
    17e6:	fbf9                	bnez	a5,17bc <vprintf+0x184>
    17e8:	a069                	j	1872 <vprintf+0x23a>
        }
      } else if(c == 'c'){
    17ea:	fdc42783          	lw	a5,-36(s0)
    17ee:	0007871b          	sext.w	a4,a5
    17f2:	06300793          	li	a5,99
    17f6:	02f71463          	bne	a4,a5,181e <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
    17fa:	fb843783          	ld	a5,-72(s0)
    17fe:	00878713          	addi	a4,a5,8
    1802:	fae43c23          	sd	a4,-72(s0)
    1806:	439c                	lw	a5,0(a5)
    1808:	0ff7f713          	zext.b	a4,a5
    180c:	fcc42783          	lw	a5,-52(s0)
    1810:	85ba                	mv	a1,a4
    1812:	853e                	mv	a0,a5
    1814:	00000097          	auipc	ra,0x0
    1818:	c5a080e7          	jalr	-934(ra) # 146e <putc>
    181c:	a899                	j	1872 <vprintf+0x23a>
      } else if(c == '%'){
    181e:	fdc42783          	lw	a5,-36(s0)
    1822:	0007871b          	sext.w	a4,a5
    1826:	02500793          	li	a5,37
    182a:	00f71f63          	bne	a4,a5,1848 <vprintf+0x210>
        putc(fd, c);
    182e:	fdc42783          	lw	a5,-36(s0)
    1832:	0ff7f713          	zext.b	a4,a5
    1836:	fcc42783          	lw	a5,-52(s0)
    183a:	85ba                	mv	a1,a4
    183c:	853e                	mv	a0,a5
    183e:	00000097          	auipc	ra,0x0
    1842:	c30080e7          	jalr	-976(ra) # 146e <putc>
    1846:	a035                	j	1872 <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1848:	fcc42783          	lw	a5,-52(s0)
    184c:	02500593          	li	a1,37
    1850:	853e                	mv	a0,a5
    1852:	00000097          	auipc	ra,0x0
    1856:	c1c080e7          	jalr	-996(ra) # 146e <putc>
        putc(fd, c);
    185a:	fdc42783          	lw	a5,-36(s0)
    185e:	0ff7f713          	zext.b	a4,a5
    1862:	fcc42783          	lw	a5,-52(s0)
    1866:	85ba                	mv	a1,a4
    1868:	853e                	mv	a0,a5
    186a:	00000097          	auipc	ra,0x0
    186e:	c04080e7          	jalr	-1020(ra) # 146e <putc>
      }
      state = 0;
    1872:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
    1876:	fe442783          	lw	a5,-28(s0)
    187a:	2785                	addiw	a5,a5,1
    187c:	fef42223          	sw	a5,-28(s0)
    1880:	fe442783          	lw	a5,-28(s0)
    1884:	fc043703          	ld	a4,-64(s0)
    1888:	97ba                	add	a5,a5,a4
    188a:	0007c783          	lbu	a5,0(a5)
    188e:	dc0795e3          	bnez	a5,1658 <vprintf+0x20>
    }
  }
}
    1892:	0001                	nop
    1894:	0001                	nop
    1896:	60a6                	ld	ra,72(sp)
    1898:	6406                	ld	s0,64(sp)
    189a:	6161                	addi	sp,sp,80
    189c:	8082                	ret

000000000000189e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    189e:	7159                	addi	sp,sp,-112
    18a0:	fc06                	sd	ra,56(sp)
    18a2:	f822                	sd	s0,48(sp)
    18a4:	0080                	addi	s0,sp,64
    18a6:	fcb43823          	sd	a1,-48(s0)
    18aa:	e010                	sd	a2,0(s0)
    18ac:	e414                	sd	a3,8(s0)
    18ae:	e818                	sd	a4,16(s0)
    18b0:	ec1c                	sd	a5,24(s0)
    18b2:	03043023          	sd	a6,32(s0)
    18b6:	03143423          	sd	a7,40(s0)
    18ba:	87aa                	mv	a5,a0
    18bc:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
    18c0:	03040793          	addi	a5,s0,48
    18c4:	fcf43423          	sd	a5,-56(s0)
    18c8:	fc843783          	ld	a5,-56(s0)
    18cc:	fd078793          	addi	a5,a5,-48
    18d0:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
    18d4:	fe843703          	ld	a4,-24(s0)
    18d8:	fdc42783          	lw	a5,-36(s0)
    18dc:	863a                	mv	a2,a4
    18de:	fd043583          	ld	a1,-48(s0)
    18e2:	853e                	mv	a0,a5
    18e4:	00000097          	auipc	ra,0x0
    18e8:	d54080e7          	jalr	-684(ra) # 1638 <vprintf>
}
    18ec:	0001                	nop
    18ee:	70e2                	ld	ra,56(sp)
    18f0:	7442                	ld	s0,48(sp)
    18f2:	6165                	addi	sp,sp,112
    18f4:	8082                	ret

00000000000018f6 <printf>:

void
printf(const char *fmt, ...)
{
    18f6:	7159                	addi	sp,sp,-112
    18f8:	f406                	sd	ra,40(sp)
    18fa:	f022                	sd	s0,32(sp)
    18fc:	1800                	addi	s0,sp,48
    18fe:	fca43c23          	sd	a0,-40(s0)
    1902:	e40c                	sd	a1,8(s0)
    1904:	e810                	sd	a2,16(s0)
    1906:	ec14                	sd	a3,24(s0)
    1908:	f018                	sd	a4,32(s0)
    190a:	f41c                	sd	a5,40(s0)
    190c:	03043823          	sd	a6,48(s0)
    1910:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1914:	04040793          	addi	a5,s0,64
    1918:	fcf43823          	sd	a5,-48(s0)
    191c:	fd043783          	ld	a5,-48(s0)
    1920:	fc878793          	addi	a5,a5,-56
    1924:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
    1928:	fe843783          	ld	a5,-24(s0)
    192c:	863e                	mv	a2,a5
    192e:	fd843583          	ld	a1,-40(s0)
    1932:	4505                	li	a0,1
    1934:	00000097          	auipc	ra,0x0
    1938:	d04080e7          	jalr	-764(ra) # 1638 <vprintf>
}
    193c:	0001                	nop
    193e:	70a2                	ld	ra,40(sp)
    1940:	7402                	ld	s0,32(sp)
    1942:	6165                	addi	sp,sp,112
    1944:	8082                	ret

0000000000001946 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1946:	7179                	addi	sp,sp,-48
    1948:	f422                	sd	s0,40(sp)
    194a:	1800                	addi	s0,sp,48
    194c:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1950:	fd843783          	ld	a5,-40(s0)
    1954:	17c1                	addi	a5,a5,-16
    1956:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    195a:	00001797          	auipc	a5,0x1
    195e:	ace78793          	addi	a5,a5,-1330 # 2428 <freep>
    1962:	639c                	ld	a5,0(a5)
    1964:	fef43423          	sd	a5,-24(s0)
    1968:	a815                	j	199c <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    196a:	fe843783          	ld	a5,-24(s0)
    196e:	639c                	ld	a5,0(a5)
    1970:	fe843703          	ld	a4,-24(s0)
    1974:	00f76f63          	bltu	a4,a5,1992 <free+0x4c>
    1978:	fe043703          	ld	a4,-32(s0)
    197c:	fe843783          	ld	a5,-24(s0)
    1980:	02e7eb63          	bltu	a5,a4,19b6 <free+0x70>
    1984:	fe843783          	ld	a5,-24(s0)
    1988:	639c                	ld	a5,0(a5)
    198a:	fe043703          	ld	a4,-32(s0)
    198e:	02f76463          	bltu	a4,a5,19b6 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1992:	fe843783          	ld	a5,-24(s0)
    1996:	639c                	ld	a5,0(a5)
    1998:	fef43423          	sd	a5,-24(s0)
    199c:	fe043703          	ld	a4,-32(s0)
    19a0:	fe843783          	ld	a5,-24(s0)
    19a4:	fce7f3e3          	bgeu	a5,a4,196a <free+0x24>
    19a8:	fe843783          	ld	a5,-24(s0)
    19ac:	639c                	ld	a5,0(a5)
    19ae:	fe043703          	ld	a4,-32(s0)
    19b2:	faf77ce3          	bgeu	a4,a5,196a <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
    19b6:	fe043783          	ld	a5,-32(s0)
    19ba:	479c                	lw	a5,8(a5)
    19bc:	1782                	slli	a5,a5,0x20
    19be:	9381                	srli	a5,a5,0x20
    19c0:	0792                	slli	a5,a5,0x4
    19c2:	fe043703          	ld	a4,-32(s0)
    19c6:	973e                	add	a4,a4,a5
    19c8:	fe843783          	ld	a5,-24(s0)
    19cc:	639c                	ld	a5,0(a5)
    19ce:	02f71763          	bne	a4,a5,19fc <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
    19d2:	fe043783          	ld	a5,-32(s0)
    19d6:	4798                	lw	a4,8(a5)
    19d8:	fe843783          	ld	a5,-24(s0)
    19dc:	639c                	ld	a5,0(a5)
    19de:	479c                	lw	a5,8(a5)
    19e0:	9fb9                	addw	a5,a5,a4
    19e2:	0007871b          	sext.w	a4,a5
    19e6:	fe043783          	ld	a5,-32(s0)
    19ea:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
    19ec:	fe843783          	ld	a5,-24(s0)
    19f0:	639c                	ld	a5,0(a5)
    19f2:	6398                	ld	a4,0(a5)
    19f4:	fe043783          	ld	a5,-32(s0)
    19f8:	e398                	sd	a4,0(a5)
    19fa:	a039                	j	1a08 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
    19fc:	fe843783          	ld	a5,-24(s0)
    1a00:	6398                	ld	a4,0(a5)
    1a02:	fe043783          	ld	a5,-32(s0)
    1a06:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
    1a08:	fe843783          	ld	a5,-24(s0)
    1a0c:	479c                	lw	a5,8(a5)
    1a0e:	1782                	slli	a5,a5,0x20
    1a10:	9381                	srli	a5,a5,0x20
    1a12:	0792                	slli	a5,a5,0x4
    1a14:	fe843703          	ld	a4,-24(s0)
    1a18:	97ba                	add	a5,a5,a4
    1a1a:	fe043703          	ld	a4,-32(s0)
    1a1e:	02f71563          	bne	a4,a5,1a48 <free+0x102>
    p->s.size += bp->s.size;
    1a22:	fe843783          	ld	a5,-24(s0)
    1a26:	4798                	lw	a4,8(a5)
    1a28:	fe043783          	ld	a5,-32(s0)
    1a2c:	479c                	lw	a5,8(a5)
    1a2e:	9fb9                	addw	a5,a5,a4
    1a30:	0007871b          	sext.w	a4,a5
    1a34:	fe843783          	ld	a5,-24(s0)
    1a38:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1a3a:	fe043783          	ld	a5,-32(s0)
    1a3e:	6398                	ld	a4,0(a5)
    1a40:	fe843783          	ld	a5,-24(s0)
    1a44:	e398                	sd	a4,0(a5)
    1a46:	a031                	j	1a52 <free+0x10c>
  } else
    p->s.ptr = bp;
    1a48:	fe843783          	ld	a5,-24(s0)
    1a4c:	fe043703          	ld	a4,-32(s0)
    1a50:	e398                	sd	a4,0(a5)
  freep = p;
    1a52:	00001797          	auipc	a5,0x1
    1a56:	9d678793          	addi	a5,a5,-1578 # 2428 <freep>
    1a5a:	fe843703          	ld	a4,-24(s0)
    1a5e:	e398                	sd	a4,0(a5)
}
    1a60:	0001                	nop
    1a62:	7422                	ld	s0,40(sp)
    1a64:	6145                	addi	sp,sp,48
    1a66:	8082                	ret

0000000000001a68 <morecore>:

static Header*
morecore(uint nu)
{
    1a68:	7179                	addi	sp,sp,-48
    1a6a:	f406                	sd	ra,40(sp)
    1a6c:	f022                	sd	s0,32(sp)
    1a6e:	1800                	addi	s0,sp,48
    1a70:	87aa                	mv	a5,a0
    1a72:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
    1a76:	fdc42783          	lw	a5,-36(s0)
    1a7a:	0007871b          	sext.w	a4,a5
    1a7e:	6785                	lui	a5,0x1
    1a80:	00f77563          	bgeu	a4,a5,1a8a <morecore+0x22>
    nu = 4096;
    1a84:	6785                	lui	a5,0x1
    1a86:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
    1a8a:	fdc42783          	lw	a5,-36(s0)
    1a8e:	0047979b          	slliw	a5,a5,0x4
    1a92:	2781                	sext.w	a5,a5
    1a94:	2781                	sext.w	a5,a5
    1a96:	853e                	mv	a0,a5
    1a98:	00000097          	auipc	ra,0x0
    1a9c:	99e080e7          	jalr	-1634(ra) # 1436 <sbrk>
    1aa0:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
    1aa4:	fe843703          	ld	a4,-24(s0)
    1aa8:	57fd                	li	a5,-1
    1aaa:	00f71463          	bne	a4,a5,1ab2 <morecore+0x4a>
    return 0;
    1aae:	4781                	li	a5,0
    1ab0:	a03d                	j	1ade <morecore+0x76>
  hp = (Header*)p;
    1ab2:	fe843783          	ld	a5,-24(s0)
    1ab6:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
    1aba:	fe043783          	ld	a5,-32(s0)
    1abe:	fdc42703          	lw	a4,-36(s0)
    1ac2:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
    1ac4:	fe043783          	ld	a5,-32(s0)
    1ac8:	07c1                	addi	a5,a5,16 # 1010 <memset+0xe>
    1aca:	853e                	mv	a0,a5
    1acc:	00000097          	auipc	ra,0x0
    1ad0:	e7a080e7          	jalr	-390(ra) # 1946 <free>
  return freep;
    1ad4:	00001797          	auipc	a5,0x1
    1ad8:	95478793          	addi	a5,a5,-1708 # 2428 <freep>
    1adc:	639c                	ld	a5,0(a5)
}
    1ade:	853e                	mv	a0,a5
    1ae0:	70a2                	ld	ra,40(sp)
    1ae2:	7402                	ld	s0,32(sp)
    1ae4:	6145                	addi	sp,sp,48
    1ae6:	8082                	ret

0000000000001ae8 <malloc>:

void*
malloc(uint nbytes)
{
    1ae8:	7139                	addi	sp,sp,-64
    1aea:	fc06                	sd	ra,56(sp)
    1aec:	f822                	sd	s0,48(sp)
    1aee:	0080                	addi	s0,sp,64
    1af0:	87aa                	mv	a5,a0
    1af2:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1af6:	fcc46783          	lwu	a5,-52(s0)
    1afa:	07bd                	addi	a5,a5,15
    1afc:	8391                	srli	a5,a5,0x4
    1afe:	2781                	sext.w	a5,a5
    1b00:	2785                	addiw	a5,a5,1
    1b02:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
    1b06:	00001797          	auipc	a5,0x1
    1b0a:	92278793          	addi	a5,a5,-1758 # 2428 <freep>
    1b0e:	639c                	ld	a5,0(a5)
    1b10:	fef43023          	sd	a5,-32(s0)
    1b14:	fe043783          	ld	a5,-32(s0)
    1b18:	ef95                	bnez	a5,1b54 <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
    1b1a:	00001797          	auipc	a5,0x1
    1b1e:	8fe78793          	addi	a5,a5,-1794 # 2418 <base>
    1b22:	fef43023          	sd	a5,-32(s0)
    1b26:	00001797          	auipc	a5,0x1
    1b2a:	90278793          	addi	a5,a5,-1790 # 2428 <freep>
    1b2e:	fe043703          	ld	a4,-32(s0)
    1b32:	e398                	sd	a4,0(a5)
    1b34:	00001797          	auipc	a5,0x1
    1b38:	8f478793          	addi	a5,a5,-1804 # 2428 <freep>
    1b3c:	6398                	ld	a4,0(a5)
    1b3e:	00001797          	auipc	a5,0x1
    1b42:	8da78793          	addi	a5,a5,-1830 # 2418 <base>
    1b46:	e398                	sd	a4,0(a5)
    base.s.size = 0;
    1b48:	00001797          	auipc	a5,0x1
    1b4c:	8d078793          	addi	a5,a5,-1840 # 2418 <base>
    1b50:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1b54:	fe043783          	ld	a5,-32(s0)
    1b58:	639c                	ld	a5,0(a5)
    1b5a:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
    1b5e:	fe843783          	ld	a5,-24(s0)
    1b62:	4798                	lw	a4,8(a5)
    1b64:	fdc42783          	lw	a5,-36(s0)
    1b68:	2781                	sext.w	a5,a5
    1b6a:	06f76763          	bltu	a4,a5,1bd8 <malloc+0xf0>
      if(p->s.size == nunits)
    1b6e:	fe843783          	ld	a5,-24(s0)
    1b72:	4798                	lw	a4,8(a5)
    1b74:	fdc42783          	lw	a5,-36(s0)
    1b78:	2781                	sext.w	a5,a5
    1b7a:	00e79963          	bne	a5,a4,1b8c <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
    1b7e:	fe843783          	ld	a5,-24(s0)
    1b82:	6398                	ld	a4,0(a5)
    1b84:	fe043783          	ld	a5,-32(s0)
    1b88:	e398                	sd	a4,0(a5)
    1b8a:	a825                	j	1bc2 <malloc+0xda>
      else {
        p->s.size -= nunits;
    1b8c:	fe843783          	ld	a5,-24(s0)
    1b90:	479c                	lw	a5,8(a5)
    1b92:	fdc42703          	lw	a4,-36(s0)
    1b96:	9f99                	subw	a5,a5,a4
    1b98:	0007871b          	sext.w	a4,a5
    1b9c:	fe843783          	ld	a5,-24(s0)
    1ba0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1ba2:	fe843783          	ld	a5,-24(s0)
    1ba6:	479c                	lw	a5,8(a5)
    1ba8:	1782                	slli	a5,a5,0x20
    1baa:	9381                	srli	a5,a5,0x20
    1bac:	0792                	slli	a5,a5,0x4
    1bae:	fe843703          	ld	a4,-24(s0)
    1bb2:	97ba                	add	a5,a5,a4
    1bb4:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
    1bb8:	fe843783          	ld	a5,-24(s0)
    1bbc:	fdc42703          	lw	a4,-36(s0)
    1bc0:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
    1bc2:	00001797          	auipc	a5,0x1
    1bc6:	86678793          	addi	a5,a5,-1946 # 2428 <freep>
    1bca:	fe043703          	ld	a4,-32(s0)
    1bce:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
    1bd0:	fe843783          	ld	a5,-24(s0)
    1bd4:	07c1                	addi	a5,a5,16
    1bd6:	a091                	j	1c1a <malloc+0x132>
    }
    if(p == freep)
    1bd8:	00001797          	auipc	a5,0x1
    1bdc:	85078793          	addi	a5,a5,-1968 # 2428 <freep>
    1be0:	639c                	ld	a5,0(a5)
    1be2:	fe843703          	ld	a4,-24(s0)
    1be6:	02f71063          	bne	a4,a5,1c06 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
    1bea:	fdc42783          	lw	a5,-36(s0)
    1bee:	853e                	mv	a0,a5
    1bf0:	00000097          	auipc	ra,0x0
    1bf4:	e78080e7          	jalr	-392(ra) # 1a68 <morecore>
    1bf8:	fea43423          	sd	a0,-24(s0)
    1bfc:	fe843783          	ld	a5,-24(s0)
    1c00:	e399                	bnez	a5,1c06 <malloc+0x11e>
        return 0;
    1c02:	4781                	li	a5,0
    1c04:	a819                	j	1c1a <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1c06:	fe843783          	ld	a5,-24(s0)
    1c0a:	fef43023          	sd	a5,-32(s0)
    1c0e:	fe843783          	ld	a5,-24(s0)
    1c12:	639c                	ld	a5,0(a5)
    1c14:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
    1c18:	b799                	j	1b5e <malloc+0x76>
  }
}
    1c1a:	853e                	mv	a0,a5
    1c1c:	70e2                	ld	ra,56(sp)
    1c1e:	7442                	ld	s0,48(sp)
    1c20:	6121                	addi	sp,sp,64
    1c22:	8082                	ret
