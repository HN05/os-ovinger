
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase5>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase5()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
    int pid[3];

    printf("\n----- Test case 5 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	e4450513          	addi	a0,a0,-444 # e50 <malloc+0x108>
  14:	00001097          	auipc	ra,0x1
  18:	c7c080e7          	jalr	-900(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	e5450513          	addi	a0,a0,-428 # e70 <malloc+0x128>
  24:	00001097          	auipc	ra,0x1
  28:	c6c080e7          	jalr	-916(ra) # c90 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	994080e7          	jalr	-1644(ra) # 9c0 <pfreepages>

    for (int i = 0; i < 3; ++i)
  34:	fd040493          	addi	s1,s0,-48
  38:	fdc40913          	addi	s2,s0,-36
    {
        if ((pid[i] = fork()) == 0)
  3c:	00001097          	auipc	ra,0x1
  40:	8bc080e7          	jalr	-1860(ra) # 8f8 <fork>
  44:	c088                	sw	a0,0(s1)
  46:	c531                	beqz	a0,92 <testcase5+0x92>
            // PARENT
            break;
        }
    }

    sleep(100);
  48:	06400513          	li	a0,100
  4c:	00001097          	auipc	ra,0x1
  50:	944080e7          	jalr	-1724(ra) # 990 <sleep>
  54:	448d                	li	s1,3

    for (int i = 0; i < 3; ++i)
    {
        int _pid = wait(0);
  56:	4501                	li	a0,0
  58:	00001097          	auipc	ra,0x1
  5c:	8b0080e7          	jalr	-1872(ra) # 908 <wait>
        for (int j = 0; j < 3; ++j)
        {
            if (pid[j] == _pid)
  60:	fd042783          	lw	a5,-48(s0)
  64:	02a78b63          	beq	a5,a0,9a <testcase5+0x9a>
  68:	fd442783          	lw	a5,-44(s0)
  6c:	02a78763          	beq	a5,a0,9a <testcase5+0x9a>
  70:	fd842783          	lw	a5,-40(s0)
  74:	02a78363          	beq	a5,a0,9a <testcase5+0x9a>
            {
                break;
            }
            if (j == 2)
            {
                printf("wait() error!");
  78:	00001517          	auipc	a0,0x1
  7c:	e0850513          	addi	a0,a0,-504 # e80 <malloc+0x138>
  80:	00001097          	auipc	ra,0x1
  84:	c10080e7          	jalr	-1008(ra) # c90 <printf>
                exit(1);
  88:	4505                	li	a0,1
  8a:	00001097          	auipc	ra,0x1
  8e:	876080e7          	jalr	-1930(ra) # 900 <exit>
    for (int i = 0; i < 3; ++i)
  92:	0491                	addi	s1,s1,4
  94:	fb2494e3          	bne	s1,s2,3c <testcase5+0x3c>
  98:	bf45                	j	48 <testcase5+0x48>
    for (int i = 0; i < 3; ++i)
  9a:	34fd                	addiw	s1,s1,-1
  9c:	fccd                	bnez	s1,56 <testcase5+0x56>
            }
        }
    }

    printf("[prnt] v7 --> ");
  9e:	00001517          	auipc	a0,0x1
  a2:	df250513          	addi	a0,a0,-526 # e90 <malloc+0x148>
  a6:	00001097          	auipc	ra,0x1
  aa:	bea080e7          	jalr	-1046(ra) # c90 <printf>
    print_free_frame_cnt();
  ae:	00001097          	auipc	ra,0x1
  b2:	912080e7          	jalr	-1774(ra) # 9c0 <pfreepages>
}
  b6:	70a2                	ld	ra,40(sp)
  b8:	7402                	ld	s0,32(sp)
  ba:	64e2                	ld	s1,24(sp)
  bc:	6942                	ld	s2,16(sp)
  be:	6145                	addi	sp,sp,48
  c0:	8082                	ret

00000000000000c2 <testcase4>:

void testcase4()
{
  c2:	1101                	addi	sp,sp,-32
  c4:	ec06                	sd	ra,24(sp)
  c6:	e822                	sd	s0,16(sp)
  c8:	e426                	sd	s1,8(sp)
  ca:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	dd450513          	addi	a0,a0,-556 # ea0 <malloc+0x158>
  d4:	00001097          	auipc	ra,0x1
  d8:	bbc080e7          	jalr	-1092(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
  dc:	00001517          	auipc	a0,0x1
  e0:	d9450513          	addi	a0,a0,-620 # e70 <malloc+0x128>
  e4:	00001097          	auipc	ra,0x1
  e8:	bac080e7          	jalr	-1108(ra) # c90 <printf>
    print_free_frame_cnt();
  ec:	00001097          	auipc	ra,0x1
  f0:	8d4080e7          	jalr	-1836(ra) # 9c0 <pfreepages>

    if ((pid = fork()) == 0)
  f4:	00001097          	auipc	ra,0x1
  f8:	804080e7          	jalr	-2044(ra) # 8f8 <fork>
  fc:	c171                	beqz	a0,1c0 <testcase4+0xfe>
  fe:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 100:	00001517          	auipc	a0,0x1
 104:	ed050513          	addi	a0,a0,-304 # fd0 <malloc+0x288>
 108:	00001097          	auipc	ra,0x1
 10c:	b88080e7          	jalr	-1144(ra) # c90 <printf>
        print_free_frame_cnt();
 110:	00001097          	auipc	ra,0x1
 114:	8b0080e7          	jalr	-1872(ra) # 9c0 <pfreepages>

        global_array[0] = 111;
 118:	06f00793          	li	a5,111
 11c:	00002717          	auipc	a4,0x2
 120:	3cf72a23          	sw	a5,980(a4) # 24f0 <global_array>
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 124:	06f00593          	li	a1,111
 128:	00001517          	auipc	a0,0x1
 12c:	eb850513          	addi	a0,a0,-328 # fe0 <malloc+0x298>
 130:	00001097          	auipc	ra,0x1
 134:	b60080e7          	jalr	-1184(ra) # c90 <printf>

        printf("[prnt] v3 --> ");
 138:	00001517          	auipc	a0,0x1
 13c:	ef050513          	addi	a0,a0,-272 # 1028 <malloc+0x2e0>
 140:	00001097          	auipc	ra,0x1
 144:	b50080e7          	jalr	-1200(ra) # c90 <printf>
        print_free_frame_cnt();
 148:	00001097          	auipc	ra,0x1
 14c:	878080e7          	jalr	-1928(ra) # 9c0 <pfreepages>
    }

    if (wait(0) != pid)
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	7b6080e7          	jalr	1974(ra) # 908 <wait>
 15a:	16951263          	bne	a0,s1,2be <testcase4+0x1fc>
    {
        printf("wait() error!");
        exit(1);
    }
    printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 15e:	00002497          	auipc	s1,0x2
 162:	39248493          	addi	s1,s1,914 # 24f0 <global_array>
 166:	00001097          	auipc	ra,0x1
 16a:	81a080e7          	jalr	-2022(ra) # 980 <getpid>
 16e:	85aa                	mv	a1,a0
 170:	8526                	mv	a0,s1
 172:	00001097          	auipc	ra,0x1
 176:	846080e7          	jalr	-1978(ra) # 9b8 <va2pa>
 17a:	85aa                	mv	a1,a0
 17c:	00001517          	auipc	a0,0x1
 180:	ebc50513          	addi	a0,a0,-324 # 1038 <malloc+0x2f0>
 184:	00001097          	auipc	ra,0x1
 188:	b0c080e7          	jalr	-1268(ra) # c90 <printf>

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
 18c:	408c                	lw	a1,0(s1)
 18e:	00001517          	auipc	a0,0x1
 192:	ec250513          	addi	a0,a0,-318 # 1050 <malloc+0x308>
 196:	00001097          	auipc	ra,0x1
 19a:	afa080e7          	jalr	-1286(ra) # c90 <printf>

    printf("[prnt] v7 --> ");
 19e:	00001517          	auipc	a0,0x1
 1a2:	cf250513          	addi	a0,a0,-782 # e90 <malloc+0x148>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	aea080e7          	jalr	-1302(ra) # c90 <printf>
    print_free_frame_cnt();
 1ae:	00001097          	auipc	ra,0x1
 1b2:	812080e7          	jalr	-2030(ra) # 9c0 <pfreepages>
}
 1b6:	60e2                	ld	ra,24(sp)
 1b8:	6442                	ld	s0,16(sp)
 1ba:	64a2                	ld	s1,8(sp)
 1bc:	6105                	addi	sp,sp,32
 1be:	8082                	ret
        sleep(50);
 1c0:	03200513          	li	a0,50
 1c4:	00000097          	auipc	ra,0x0
 1c8:	7cc080e7          	jalr	1996(ra) # 990 <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 1cc:	00002497          	auipc	s1,0x2
 1d0:	32448493          	addi	s1,s1,804 # 24f0 <global_array>
 1d4:	00000097          	auipc	ra,0x0
 1d8:	7ac080e7          	jalr	1964(ra) # 980 <getpid>
 1dc:	85aa                	mv	a1,a0
 1de:	8526                	mv	a0,s1
 1e0:	00000097          	auipc	ra,0x0
 1e4:	7d8080e7          	jalr	2008(ra) # 9b8 <va2pa>
 1e8:	85aa                	mv	a1,a0
 1ea:	00001517          	auipc	a0,0x1
 1ee:	cd650513          	addi	a0,a0,-810 # ec0 <malloc+0x178>
 1f2:	00001097          	auipc	ra,0x1
 1f6:	a9e080e7          	jalr	-1378(ra) # c90 <printf>
        printf("[chld] v4 --> ");
 1fa:	00001517          	auipc	a0,0x1
 1fe:	cde50513          	addi	a0,a0,-802 # ed8 <malloc+0x190>
 202:	00001097          	auipc	ra,0x1
 206:	a8e080e7          	jalr	-1394(ra) # c90 <printf>
        print_free_frame_cnt();
 20a:	00000097          	auipc	ra,0x0
 20e:	7b6080e7          	jalr	1974(ra) # 9c0 <pfreepages>
        global_array[0] = 222;
 212:	0de00793          	li	a5,222
 216:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 218:	0de00593          	li	a1,222
 21c:	00001517          	auipc	a0,0x1
 220:	ccc50513          	addi	a0,a0,-820 # ee8 <malloc+0x1a0>
 224:	00001097          	auipc	ra,0x1
 228:	a6c080e7          	jalr	-1428(ra) # c90 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 22c:	00000097          	auipc	ra,0x0
 230:	754080e7          	jalr	1876(ra) # 980 <getpid>
 234:	85aa                	mv	a1,a0
 236:	8526                	mv	a0,s1
 238:	00000097          	auipc	ra,0x0
 23c:	780080e7          	jalr	1920(ra) # 9b8 <va2pa>
 240:	85aa                	mv	a1,a0
 242:	00001517          	auipc	a0,0x1
 246:	cee50513          	addi	a0,a0,-786 # f30 <malloc+0x1e8>
 24a:	00001097          	auipc	ra,0x1
 24e:	a46080e7          	jalr	-1466(ra) # c90 <printf>
        printf("[chld] v5 --> ");
 252:	00001517          	auipc	a0,0x1
 256:	cf650513          	addi	a0,a0,-778 # f48 <malloc+0x200>
 25a:	00001097          	auipc	ra,0x1
 25e:	a36080e7          	jalr	-1482(ra) # c90 <printf>
        print_free_frame_cnt();
 262:	00000097          	auipc	ra,0x0
 266:	75e080e7          	jalr	1886(ra) # 9c0 <pfreepages>
        global_array[2047] = 333;
 26a:	14d00793          	li	a5,333
 26e:	00004717          	auipc	a4,0x4
 272:	26f72f23          	sw	a5,638(a4) # 44ec <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 276:	14d00593          	li	a1,333
 27a:	00001517          	auipc	a0,0x1
 27e:	cde50513          	addi	a0,a0,-802 # f58 <malloc+0x210>
 282:	00001097          	auipc	ra,0x1
 286:	a0e080e7          	jalr	-1522(ra) # c90 <printf>
        printf("[chld] v6 --> ");
 28a:	00001517          	auipc	a0,0x1
 28e:	d1650513          	addi	a0,a0,-746 # fa0 <malloc+0x258>
 292:	00001097          	auipc	ra,0x1
 296:	9fe080e7          	jalr	-1538(ra) # c90 <printf>
        print_free_frame_cnt();
 29a:	00000097          	auipc	ra,0x0
 29e:	726080e7          	jalr	1830(ra) # 9c0 <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 2a2:	408c                	lw	a1,0(s1)
 2a4:	00001517          	auipc	a0,0x1
 2a8:	d0c50513          	addi	a0,a0,-756 # fb0 <malloc+0x268>
 2ac:	00001097          	auipc	ra,0x1
 2b0:	9e4080e7          	jalr	-1564(ra) # c90 <printf>
        exit(0);
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	64a080e7          	jalr	1610(ra) # 900 <exit>
        printf("wait() error!");
 2be:	00001517          	auipc	a0,0x1
 2c2:	bc250513          	addi	a0,a0,-1086 # e80 <malloc+0x138>
 2c6:	00001097          	auipc	ra,0x1
 2ca:	9ca080e7          	jalr	-1590(ra) # c90 <printf>
        exit(1);
 2ce:	4505                	li	a0,1
 2d0:	00000097          	auipc	ra,0x0
 2d4:	630080e7          	jalr	1584(ra) # 900 <exit>

00000000000002d8 <testcase3>:

void testcase3()
{
 2d8:	1101                	addi	sp,sp,-32
 2da:	ec06                	sd	ra,24(sp)
 2dc:	e822                	sd	s0,16(sp)
 2de:	e426                	sd	s1,8(sp)
 2e0:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 2e2:	00001517          	auipc	a0,0x1
 2e6:	d8e50513          	addi	a0,a0,-626 # 1070 <malloc+0x328>
 2ea:	00001097          	auipc	ra,0x1
 2ee:	9a6080e7          	jalr	-1626(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
 2f2:	00001517          	auipc	a0,0x1
 2f6:	b7e50513          	addi	a0,a0,-1154 # e70 <malloc+0x128>
 2fa:	00001097          	auipc	ra,0x1
 2fe:	996080e7          	jalr	-1642(ra) # c90 <printf>
    print_free_frame_cnt();
 302:	00000097          	auipc	ra,0x0
 306:	6be080e7          	jalr	1726(ra) # 9c0 <pfreepages>

    if ((pid = fork()) == 0)
 30a:	00000097          	auipc	ra,0x0
 30e:	5ee080e7          	jalr	1518(ra) # 8f8 <fork>
 312:	cd35                	beqz	a0,38e <testcase3+0xb6>
 314:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 316:	00001517          	auipc	a0,0x1
 31a:	cba50513          	addi	a0,a0,-838 # fd0 <malloc+0x288>
 31e:	00001097          	auipc	ra,0x1
 322:	972080e7          	jalr	-1678(ra) # c90 <printf>
        print_free_frame_cnt();
 326:	00000097          	auipc	ra,0x0
 32a:	69a080e7          	jalr	1690(ra) # 9c0 <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 32e:	00002597          	auipc	a1,0x2
 332:	1b25a583          	lw	a1,434(a1) # 24e0 <global_var>
 336:	00001517          	auipc	a0,0x1
 33a:	d8a50513          	addi	a0,a0,-630 # 10c0 <malloc+0x378>
 33e:	00001097          	auipc	ra,0x1
 342:	952080e7          	jalr	-1710(ra) # c90 <printf>

        printf("[prnt] v3 --> ");
 346:	00001517          	auipc	a0,0x1
 34a:	ce250513          	addi	a0,a0,-798 # 1028 <malloc+0x2e0>
 34e:	00001097          	auipc	ra,0x1
 352:	942080e7          	jalr	-1726(ra) # c90 <printf>
        print_free_frame_cnt();
 356:	00000097          	auipc	ra,0x0
 35a:	66a080e7          	jalr	1642(ra) # 9c0 <pfreepages>
    }

    if (wait(0) != pid)
 35e:	4501                	li	a0,0
 360:	00000097          	auipc	ra,0x0
 364:	5a8080e7          	jalr	1448(ra) # 908 <wait>
 368:	08951663          	bne	a0,s1,3f4 <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 36c:	00001517          	auipc	a0,0x1
 370:	d7c50513          	addi	a0,a0,-644 # 10e8 <malloc+0x3a0>
 374:	00001097          	auipc	ra,0x1
 378:	91c080e7          	jalr	-1764(ra) # c90 <printf>
    print_free_frame_cnt();
 37c:	00000097          	auipc	ra,0x0
 380:	644080e7          	jalr	1604(ra) # 9c0 <pfreepages>
}
 384:	60e2                	ld	ra,24(sp)
 386:	6442                	ld	s0,16(sp)
 388:	64a2                	ld	s1,8(sp)
 38a:	6105                	addi	sp,sp,32
 38c:	8082                	ret
        sleep(50);
 38e:	03200513          	li	a0,50
 392:	00000097          	auipc	ra,0x0
 396:	5fe080e7          	jalr	1534(ra) # 990 <sleep>
        printf("[chld] v4 --> ");
 39a:	00001517          	auipc	a0,0x1
 39e:	b3e50513          	addi	a0,a0,-1218 # ed8 <malloc+0x190>
 3a2:	00001097          	auipc	ra,0x1
 3a6:	8ee080e7          	jalr	-1810(ra) # c90 <printf>
        print_free_frame_cnt();
 3aa:	00000097          	auipc	ra,0x0
 3ae:	616080e7          	jalr	1558(ra) # 9c0 <pfreepages>
        global_var = 100;
 3b2:	06400793          	li	a5,100
 3b6:	00002717          	auipc	a4,0x2
 3ba:	12f72523          	sw	a5,298(a4) # 24e0 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 3be:	06400593          	li	a1,100
 3c2:	00001517          	auipc	a0,0x1
 3c6:	cce50513          	addi	a0,a0,-818 # 1090 <malloc+0x348>
 3ca:	00001097          	auipc	ra,0x1
 3ce:	8c6080e7          	jalr	-1850(ra) # c90 <printf>
        printf("[chld] v5 --> ");
 3d2:	00001517          	auipc	a0,0x1
 3d6:	b7650513          	addi	a0,a0,-1162 # f48 <malloc+0x200>
 3da:	00001097          	auipc	ra,0x1
 3de:	8b6080e7          	jalr	-1866(ra) # c90 <printf>
        print_free_frame_cnt();
 3e2:	00000097          	auipc	ra,0x0
 3e6:	5de080e7          	jalr	1502(ra) # 9c0 <pfreepages>
        exit(0);
 3ea:	4501                	li	a0,0
 3ec:	00000097          	auipc	ra,0x0
 3f0:	514080e7          	jalr	1300(ra) # 900 <exit>
        printf("wait() error!");
 3f4:	00001517          	auipc	a0,0x1
 3f8:	a8c50513          	addi	a0,a0,-1396 # e80 <malloc+0x138>
 3fc:	00001097          	auipc	ra,0x1
 400:	894080e7          	jalr	-1900(ra) # c90 <printf>
        exit(1);
 404:	4505                	li	a0,1
 406:	00000097          	auipc	ra,0x0
 40a:	4fa080e7          	jalr	1274(ra) # 900 <exit>

000000000000040e <testcase2>:

void testcase2()
{
 40e:	1101                	addi	sp,sp,-32
 410:	ec06                	sd	ra,24(sp)
 412:	e822                	sd	s0,16(sp)
 414:	e426                	sd	s1,8(sp)
 416:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 418:	00001517          	auipc	a0,0x1
 41c:	ce050513          	addi	a0,a0,-800 # 10f8 <malloc+0x3b0>
 420:	00001097          	auipc	ra,0x1
 424:	870080e7          	jalr	-1936(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
 428:	00001517          	auipc	a0,0x1
 42c:	a4850513          	addi	a0,a0,-1464 # e70 <malloc+0x128>
 430:	00001097          	auipc	ra,0x1
 434:	860080e7          	jalr	-1952(ra) # c90 <printf>
    print_free_frame_cnt();
 438:	00000097          	auipc	ra,0x0
 43c:	588080e7          	jalr	1416(ra) # 9c0 <pfreepages>

    if ((pid = fork()) == 0)
 440:	00000097          	auipc	ra,0x0
 444:	4b8080e7          	jalr	1208(ra) # 8f8 <fork>
 448:	c531                	beqz	a0,494 <testcase2+0x86>
 44a:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 44c:	00001517          	auipc	a0,0x1
 450:	b8450513          	addi	a0,a0,-1148 # fd0 <malloc+0x288>
 454:	00001097          	auipc	ra,0x1
 458:	83c080e7          	jalr	-1988(ra) # c90 <printf>
        print_free_frame_cnt();
 45c:	00000097          	auipc	ra,0x0
 460:	564080e7          	jalr	1380(ra) # 9c0 <pfreepages>
    }

    if (wait(0) != pid)
 464:	4501                	li	a0,0
 466:	00000097          	auipc	ra,0x0
 46a:	4a2080e7          	jalr	1186(ra) # 908 <wait>
 46e:	08951263          	bne	a0,s1,4f2 <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 472:	00001517          	auipc	a0,0x1
 476:	cde50513          	addi	a0,a0,-802 # 1150 <malloc+0x408>
 47a:	00001097          	auipc	ra,0x1
 47e:	816080e7          	jalr	-2026(ra) # c90 <printf>
    print_free_frame_cnt();
 482:	00000097          	auipc	ra,0x0
 486:	53e080e7          	jalr	1342(ra) # 9c0 <pfreepages>
}
 48a:	60e2                	ld	ra,24(sp)
 48c:	6442                	ld	s0,16(sp)
 48e:	64a2                	ld	s1,8(sp)
 490:	6105                	addi	sp,sp,32
 492:	8082                	ret
        sleep(50);
 494:	03200513          	li	a0,50
 498:	00000097          	auipc	ra,0x0
 49c:	4f8080e7          	jalr	1272(ra) # 990 <sleep>
        printf("[chld] v3 --> ");
 4a0:	00001517          	auipc	a0,0x1
 4a4:	c7850513          	addi	a0,a0,-904 # 1118 <malloc+0x3d0>
 4a8:	00000097          	auipc	ra,0x0
 4ac:	7e8080e7          	jalr	2024(ra) # c90 <printf>
        print_free_frame_cnt();
 4b0:	00000097          	auipc	ra,0x0
 4b4:	510080e7          	jalr	1296(ra) # 9c0 <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 4b8:	00002597          	auipc	a1,0x2
 4bc:	0285a583          	lw	a1,40(a1) # 24e0 <global_var>
 4c0:	00001517          	auipc	a0,0x1
 4c4:	c6850513          	addi	a0,a0,-920 # 1128 <malloc+0x3e0>
 4c8:	00000097          	auipc	ra,0x0
 4cc:	7c8080e7          	jalr	1992(ra) # c90 <printf>
        printf("[chld] v4 --> ");
 4d0:	00001517          	auipc	a0,0x1
 4d4:	a0850513          	addi	a0,a0,-1528 # ed8 <malloc+0x190>
 4d8:	00000097          	auipc	ra,0x0
 4dc:	7b8080e7          	jalr	1976(ra) # c90 <printf>
        print_free_frame_cnt();
 4e0:	00000097          	auipc	ra,0x0
 4e4:	4e0080e7          	jalr	1248(ra) # 9c0 <pfreepages>
        exit(0);
 4e8:	4501                	li	a0,0
 4ea:	00000097          	auipc	ra,0x0
 4ee:	416080e7          	jalr	1046(ra) # 900 <exit>
        printf("wait() error!");
 4f2:	00001517          	auipc	a0,0x1
 4f6:	98e50513          	addi	a0,a0,-1650 # e80 <malloc+0x138>
 4fa:	00000097          	auipc	ra,0x0
 4fe:	796080e7          	jalr	1942(ra) # c90 <printf>
        exit(1);
 502:	4505                	li	a0,1
 504:	00000097          	auipc	ra,0x0
 508:	3fc080e7          	jalr	1020(ra) # 900 <exit>

000000000000050c <testcase1>:

void testcase1()
{
 50c:	1101                	addi	sp,sp,-32
 50e:	ec06                	sd	ra,24(sp)
 510:	e822                	sd	s0,16(sp)
 512:	e426                	sd	s1,8(sp)
 514:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 516:	00001517          	auipc	a0,0x1
 51a:	c4a50513          	addi	a0,a0,-950 # 1160 <malloc+0x418>
 51e:	00000097          	auipc	ra,0x0
 522:	772080e7          	jalr	1906(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
 526:	00001517          	auipc	a0,0x1
 52a:	94a50513          	addi	a0,a0,-1718 # e70 <malloc+0x128>
 52e:	00000097          	auipc	ra,0x0
 532:	762080e7          	jalr	1890(ra) # c90 <printf>
    print_free_frame_cnt();
 536:	00000097          	auipc	ra,0x0
 53a:	48a080e7          	jalr	1162(ra) # 9c0 <pfreepages>

    if ((pid = fork()) == 0)
 53e:	00000097          	auipc	ra,0x0
 542:	3ba080e7          	jalr	954(ra) # 8f8 <fork>
 546:	c531                	beqz	a0,592 <testcase1+0x86>
 548:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 54a:	00001517          	auipc	a0,0x1
 54e:	ade50513          	addi	a0,a0,-1314 # 1028 <malloc+0x2e0>
 552:	00000097          	auipc	ra,0x0
 556:	73e080e7          	jalr	1854(ra) # c90 <printf>
        print_free_frame_cnt();
 55a:	00000097          	auipc	ra,0x0
 55e:	466080e7          	jalr	1126(ra) # 9c0 <pfreepages>
    }

    if (wait(0) != pid)
 562:	4501                	li	a0,0
 564:	00000097          	auipc	ra,0x0
 568:	3a4080e7          	jalr	932(ra) # 908 <wait>
 56c:	04951a63          	bne	a0,s1,5c0 <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 570:	00001517          	auipc	a0,0x1
 574:	c2050513          	addi	a0,a0,-992 # 1190 <malloc+0x448>
 578:	00000097          	auipc	ra,0x0
 57c:	718080e7          	jalr	1816(ra) # c90 <printf>
    print_free_frame_cnt();
 580:	00000097          	auipc	ra,0x0
 584:	440080e7          	jalr	1088(ra) # 9c0 <pfreepages>
}
 588:	60e2                	ld	ra,24(sp)
 58a:	6442                	ld	s0,16(sp)
 58c:	64a2                	ld	s1,8(sp)
 58e:	6105                	addi	sp,sp,32
 590:	8082                	ret
        sleep(50);
 592:	03200513          	li	a0,50
 596:	00000097          	auipc	ra,0x0
 59a:	3fa080e7          	jalr	1018(ra) # 990 <sleep>
        printf("[chld] v2 --> ");
 59e:	00001517          	auipc	a0,0x1
 5a2:	be250513          	addi	a0,a0,-1054 # 1180 <malloc+0x438>
 5a6:	00000097          	auipc	ra,0x0
 5aa:	6ea080e7          	jalr	1770(ra) # c90 <printf>
        print_free_frame_cnt();
 5ae:	00000097          	auipc	ra,0x0
 5b2:	412080e7          	jalr	1042(ra) # 9c0 <pfreepages>
        exit(0);
 5b6:	4501                	li	a0,0
 5b8:	00000097          	auipc	ra,0x0
 5bc:	348080e7          	jalr	840(ra) # 900 <exit>
        printf("wait() error!");
 5c0:	00001517          	auipc	a0,0x1
 5c4:	8c050513          	addi	a0,a0,-1856 # e80 <malloc+0x138>
 5c8:	00000097          	auipc	ra,0x0
 5cc:	6c8080e7          	jalr	1736(ra) # c90 <printf>
        exit(1);
 5d0:	4505                	li	a0,1
 5d2:	00000097          	auipc	ra,0x0
 5d6:	32e080e7          	jalr	814(ra) # 900 <exit>

00000000000005da <main>:

int main(int argc, char *argv[])
{
 5da:	1101                	addi	sp,sp,-32
 5dc:	ec06                	sd	ra,24(sp)
 5de:	e822                	sd	s0,16(sp)
 5e0:	e426                	sd	s1,8(sp)
 5e2:	1000                	addi	s0,sp,32
    if (argc < 2)
 5e4:	4785                	li	a5,1
 5e6:	02a7d963          	bge	a5,a0,618 <main+0x3e>
 5ea:	84ae                	mv	s1,a1
    {
        printf("Usage: cowtest test_id\n");
        exit(-1);
    }
    switch (atoi(argv[1]))
 5ec:	6588                	ld	a0,8(a1)
 5ee:	00000097          	auipc	ra,0x0
 5f2:	218080e7          	jalr	536(ra) # 806 <atoi>
 5f6:	478d                	li	a5,3
 5f8:	06f50063          	beq	a0,a5,658 <main+0x7e>
 5fc:	02a7cb63          	blt	a5,a0,632 <main+0x58>
 600:	4785                	li	a5,1
 602:	04f50163          	beq	a0,a5,644 <main+0x6a>
 606:	4789                	li	a5,2
 608:	04f51e63          	bne	a0,a5,664 <main+0x8a>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 60c:	00000097          	auipc	ra,0x0
 610:	e02080e7          	jalr	-510(ra) # 40e <testcase2>

    default:
        printf("Error: No test with index %s\n", argv[1]);
        return 1;
    }
    return 0;
 614:	4501                	li	a0,0
        break;
 616:	a825                	j	64e <main+0x74>
        printf("Usage: cowtest test_id\n");
 618:	00001517          	auipc	a0,0x1
 61c:	b8850513          	addi	a0,a0,-1144 # 11a0 <malloc+0x458>
 620:	00000097          	auipc	ra,0x0
 624:	670080e7          	jalr	1648(ra) # c90 <printf>
        exit(-1);
 628:	557d                	li	a0,-1
 62a:	00000097          	auipc	ra,0x0
 62e:	2d6080e7          	jalr	726(ra) # 900 <exit>
    switch (atoi(argv[1]))
 632:	4791                	li	a5,4
 634:	02f51863          	bne	a0,a5,664 <main+0x8a>
        testcase4();
 638:	00000097          	auipc	ra,0x0
 63c:	a8a080e7          	jalr	-1398(ra) # c2 <testcase4>
    return 0;
 640:	4501                	li	a0,0
        break;
 642:	a031                	j	64e <main+0x74>
        testcase1();
 644:	00000097          	auipc	ra,0x0
 648:	ec8080e7          	jalr	-312(ra) # 50c <testcase1>
    return 0;
 64c:	4501                	li	a0,0
}
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	64a2                	ld	s1,8(sp)
 654:	6105                	addi	sp,sp,32
 656:	8082                	ret
        testcase3();
 658:	00000097          	auipc	ra,0x0
 65c:	c80080e7          	jalr	-896(ra) # 2d8 <testcase3>
    return 0;
 660:	4501                	li	a0,0
        break;
 662:	b7f5                	j	64e <main+0x74>
        printf("Error: No test with index %s\n", argv[1]);
 664:	648c                	ld	a1,8(s1)
 666:	00001517          	auipc	a0,0x1
 66a:	b5250513          	addi	a0,a0,-1198 # 11b8 <malloc+0x470>
 66e:	00000097          	auipc	ra,0x0
 672:	622080e7          	jalr	1570(ra) # c90 <printf>
        return 1;
 676:	4505                	li	a0,1
 678:	bfd9                	j	64e <main+0x74>

000000000000067a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 67a:	1141                	addi	sp,sp,-16
 67c:	e406                	sd	ra,8(sp)
 67e:	e022                	sd	s0,0(sp)
 680:	0800                	addi	s0,sp,16
  extern int main();
  main();
 682:	00000097          	auipc	ra,0x0
 686:	f58080e7          	jalr	-168(ra) # 5da <main>
  exit(0);
 68a:	4501                	li	a0,0
 68c:	00000097          	auipc	ra,0x0
 690:	274080e7          	jalr	628(ra) # 900 <exit>

0000000000000694 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 694:	1141                	addi	sp,sp,-16
 696:	e422                	sd	s0,8(sp)
 698:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 69a:	87aa                	mv	a5,a0
 69c:	0585                	addi	a1,a1,1
 69e:	0785                	addi	a5,a5,1
 6a0:	fff5c703          	lbu	a4,-1(a1)
 6a4:	fee78fa3          	sb	a4,-1(a5)
 6a8:	fb75                	bnez	a4,69c <strcpy+0x8>
    ;
  return os;
}
 6aa:	6422                	ld	s0,8(sp)
 6ac:	0141                	addi	sp,sp,16
 6ae:	8082                	ret

00000000000006b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6b0:	1141                	addi	sp,sp,-16
 6b2:	e422                	sd	s0,8(sp)
 6b4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6b6:	00054783          	lbu	a5,0(a0)
 6ba:	cb91                	beqz	a5,6ce <strcmp+0x1e>
 6bc:	0005c703          	lbu	a4,0(a1)
 6c0:	00f71763          	bne	a4,a5,6ce <strcmp+0x1e>
    p++, q++;
 6c4:	0505                	addi	a0,a0,1
 6c6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6c8:	00054783          	lbu	a5,0(a0)
 6cc:	fbe5                	bnez	a5,6bc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6ce:	0005c503          	lbu	a0,0(a1)
}
 6d2:	40a7853b          	subw	a0,a5,a0
 6d6:	6422                	ld	s0,8(sp)
 6d8:	0141                	addi	sp,sp,16
 6da:	8082                	ret

00000000000006dc <strlen>:

uint
strlen(const char *s)
{
 6dc:	1141                	addi	sp,sp,-16
 6de:	e422                	sd	s0,8(sp)
 6e0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6e2:	00054783          	lbu	a5,0(a0)
 6e6:	cf91                	beqz	a5,702 <strlen+0x26>
 6e8:	0505                	addi	a0,a0,1
 6ea:	87aa                	mv	a5,a0
 6ec:	86be                	mv	a3,a5
 6ee:	0785                	addi	a5,a5,1
 6f0:	fff7c703          	lbu	a4,-1(a5)
 6f4:	ff65                	bnez	a4,6ec <strlen+0x10>
 6f6:	40a6853b          	subw	a0,a3,a0
 6fa:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 6fc:	6422                	ld	s0,8(sp)
 6fe:	0141                	addi	sp,sp,16
 700:	8082                	ret
  for(n = 0; s[n]; n++)
 702:	4501                	li	a0,0
 704:	bfe5                	j	6fc <strlen+0x20>

0000000000000706 <memset>:

void*
memset(void *dst, int c, uint n)
{
 706:	1141                	addi	sp,sp,-16
 708:	e422                	sd	s0,8(sp)
 70a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 70c:	ca19                	beqz	a2,722 <memset+0x1c>
 70e:	87aa                	mv	a5,a0
 710:	1602                	slli	a2,a2,0x20
 712:	9201                	srli	a2,a2,0x20
 714:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 718:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 71c:	0785                	addi	a5,a5,1
 71e:	fee79de3          	bne	a5,a4,718 <memset+0x12>
  }
  return dst;
}
 722:	6422                	ld	s0,8(sp)
 724:	0141                	addi	sp,sp,16
 726:	8082                	ret

0000000000000728 <strchr>:

char*
strchr(const char *s, char c)
{
 728:	1141                	addi	sp,sp,-16
 72a:	e422                	sd	s0,8(sp)
 72c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 72e:	00054783          	lbu	a5,0(a0)
 732:	cb99                	beqz	a5,748 <strchr+0x20>
    if(*s == c)
 734:	00f58763          	beq	a1,a5,742 <strchr+0x1a>
  for(; *s; s++)
 738:	0505                	addi	a0,a0,1
 73a:	00054783          	lbu	a5,0(a0)
 73e:	fbfd                	bnez	a5,734 <strchr+0xc>
      return (char*)s;
  return 0;
 740:	4501                	li	a0,0
}
 742:	6422                	ld	s0,8(sp)
 744:	0141                	addi	sp,sp,16
 746:	8082                	ret
  return 0;
 748:	4501                	li	a0,0
 74a:	bfe5                	j	742 <strchr+0x1a>

000000000000074c <gets>:

char*
gets(char *buf, int max)
{
 74c:	711d                	addi	sp,sp,-96
 74e:	ec86                	sd	ra,88(sp)
 750:	e8a2                	sd	s0,80(sp)
 752:	e4a6                	sd	s1,72(sp)
 754:	e0ca                	sd	s2,64(sp)
 756:	fc4e                	sd	s3,56(sp)
 758:	f852                	sd	s4,48(sp)
 75a:	f456                	sd	s5,40(sp)
 75c:	f05a                	sd	s6,32(sp)
 75e:	ec5e                	sd	s7,24(sp)
 760:	1080                	addi	s0,sp,96
 762:	8baa                	mv	s7,a0
 764:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 766:	892a                	mv	s2,a0
 768:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 76a:	4aa9                	li	s5,10
 76c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 76e:	89a6                	mv	s3,s1
 770:	2485                	addiw	s1,s1,1
 772:	0344d863          	bge	s1,s4,7a2 <gets+0x56>
    cc = read(0, &c, 1);
 776:	4605                	li	a2,1
 778:	faf40593          	addi	a1,s0,-81
 77c:	4501                	li	a0,0
 77e:	00000097          	auipc	ra,0x0
 782:	19a080e7          	jalr	410(ra) # 918 <read>
    if(cc < 1)
 786:	00a05e63          	blez	a0,7a2 <gets+0x56>
    buf[i++] = c;
 78a:	faf44783          	lbu	a5,-81(s0)
 78e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 792:	01578763          	beq	a5,s5,7a0 <gets+0x54>
 796:	0905                	addi	s2,s2,1
 798:	fd679be3          	bne	a5,s6,76e <gets+0x22>
    buf[i++] = c;
 79c:	89a6                	mv	s3,s1
 79e:	a011                	j	7a2 <gets+0x56>
 7a0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7a2:	99de                	add	s3,s3,s7
 7a4:	00098023          	sb	zero,0(s3)
  return buf;
}
 7a8:	855e                	mv	a0,s7
 7aa:	60e6                	ld	ra,88(sp)
 7ac:	6446                	ld	s0,80(sp)
 7ae:	64a6                	ld	s1,72(sp)
 7b0:	6906                	ld	s2,64(sp)
 7b2:	79e2                	ld	s3,56(sp)
 7b4:	7a42                	ld	s4,48(sp)
 7b6:	7aa2                	ld	s5,40(sp)
 7b8:	7b02                	ld	s6,32(sp)
 7ba:	6be2                	ld	s7,24(sp)
 7bc:	6125                	addi	sp,sp,96
 7be:	8082                	ret

00000000000007c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 7c0:	1101                	addi	sp,sp,-32
 7c2:	ec06                	sd	ra,24(sp)
 7c4:	e822                	sd	s0,16(sp)
 7c6:	e04a                	sd	s2,0(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7cc:	4581                	li	a1,0
 7ce:	00000097          	auipc	ra,0x0
 7d2:	172080e7          	jalr	370(ra) # 940 <open>
  if(fd < 0)
 7d6:	02054663          	bltz	a0,802 <stat+0x42>
 7da:	e426                	sd	s1,8(sp)
 7dc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7de:	85ca                	mv	a1,s2
 7e0:	00000097          	auipc	ra,0x0
 7e4:	178080e7          	jalr	376(ra) # 958 <fstat>
 7e8:	892a                	mv	s2,a0
  close(fd);
 7ea:	8526                	mv	a0,s1
 7ec:	00000097          	auipc	ra,0x0
 7f0:	13c080e7          	jalr	316(ra) # 928 <close>
  return r;
 7f4:	64a2                	ld	s1,8(sp)
}
 7f6:	854a                	mv	a0,s2
 7f8:	60e2                	ld	ra,24(sp)
 7fa:	6442                	ld	s0,16(sp)
 7fc:	6902                	ld	s2,0(sp)
 7fe:	6105                	addi	sp,sp,32
 800:	8082                	ret
    return -1;
 802:	597d                	li	s2,-1
 804:	bfcd                	j	7f6 <stat+0x36>

0000000000000806 <atoi>:

int
atoi(const char *s)
{
 806:	1141                	addi	sp,sp,-16
 808:	e422                	sd	s0,8(sp)
 80a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 80c:	00054683          	lbu	a3,0(a0)
 810:	fd06879b          	addiw	a5,a3,-48
 814:	0ff7f793          	zext.b	a5,a5
 818:	4625                	li	a2,9
 81a:	02f66863          	bltu	a2,a5,84a <atoi+0x44>
 81e:	872a                	mv	a4,a0
  n = 0;
 820:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 822:	0705                	addi	a4,a4,1
 824:	0025179b          	slliw	a5,a0,0x2
 828:	9fa9                	addw	a5,a5,a0
 82a:	0017979b          	slliw	a5,a5,0x1
 82e:	9fb5                	addw	a5,a5,a3
 830:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 834:	00074683          	lbu	a3,0(a4)
 838:	fd06879b          	addiw	a5,a3,-48
 83c:	0ff7f793          	zext.b	a5,a5
 840:	fef671e3          	bgeu	a2,a5,822 <atoi+0x1c>
  return n;
}
 844:	6422                	ld	s0,8(sp)
 846:	0141                	addi	sp,sp,16
 848:	8082                	ret
  n = 0;
 84a:	4501                	li	a0,0
 84c:	bfe5                	j	844 <atoi+0x3e>

000000000000084e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 84e:	1141                	addi	sp,sp,-16
 850:	e422                	sd	s0,8(sp)
 852:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 854:	02b57463          	bgeu	a0,a1,87c <memmove+0x2e>
    while(n-- > 0)
 858:	00c05f63          	blez	a2,876 <memmove+0x28>
 85c:	1602                	slli	a2,a2,0x20
 85e:	9201                	srli	a2,a2,0x20
 860:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 864:	872a                	mv	a4,a0
      *dst++ = *src++;
 866:	0585                	addi	a1,a1,1
 868:	0705                	addi	a4,a4,1
 86a:	fff5c683          	lbu	a3,-1(a1)
 86e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 872:	fef71ae3          	bne	a4,a5,866 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 876:	6422                	ld	s0,8(sp)
 878:	0141                	addi	sp,sp,16
 87a:	8082                	ret
    dst += n;
 87c:	00c50733          	add	a4,a0,a2
    src += n;
 880:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 882:	fec05ae3          	blez	a2,876 <memmove+0x28>
 886:	fff6079b          	addiw	a5,a2,-1
 88a:	1782                	slli	a5,a5,0x20
 88c:	9381                	srli	a5,a5,0x20
 88e:	fff7c793          	not	a5,a5
 892:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 894:	15fd                	addi	a1,a1,-1
 896:	177d                	addi	a4,a4,-1
 898:	0005c683          	lbu	a3,0(a1)
 89c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8a0:	fee79ae3          	bne	a5,a4,894 <memmove+0x46>
 8a4:	bfc9                	j	876 <memmove+0x28>

00000000000008a6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8a6:	1141                	addi	sp,sp,-16
 8a8:	e422                	sd	s0,8(sp)
 8aa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8ac:	ca05                	beqz	a2,8dc <memcmp+0x36>
 8ae:	fff6069b          	addiw	a3,a2,-1
 8b2:	1682                	slli	a3,a3,0x20
 8b4:	9281                	srli	a3,a3,0x20
 8b6:	0685                	addi	a3,a3,1
 8b8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8ba:	00054783          	lbu	a5,0(a0)
 8be:	0005c703          	lbu	a4,0(a1)
 8c2:	00e79863          	bne	a5,a4,8d2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8c6:	0505                	addi	a0,a0,1
    p2++;
 8c8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8ca:	fed518e3          	bne	a0,a3,8ba <memcmp+0x14>
  }
  return 0;
 8ce:	4501                	li	a0,0
 8d0:	a019                	j	8d6 <memcmp+0x30>
      return *p1 - *p2;
 8d2:	40e7853b          	subw	a0,a5,a4
}
 8d6:	6422                	ld	s0,8(sp)
 8d8:	0141                	addi	sp,sp,16
 8da:	8082                	ret
  return 0;
 8dc:	4501                	li	a0,0
 8de:	bfe5                	j	8d6 <memcmp+0x30>

00000000000008e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8e0:	1141                	addi	sp,sp,-16
 8e2:	e406                	sd	ra,8(sp)
 8e4:	e022                	sd	s0,0(sp)
 8e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 8e8:	00000097          	auipc	ra,0x0
 8ec:	f66080e7          	jalr	-154(ra) # 84e <memmove>
}
 8f0:	60a2                	ld	ra,8(sp)
 8f2:	6402                	ld	s0,0(sp)
 8f4:	0141                	addi	sp,sp,16
 8f6:	8082                	ret

00000000000008f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 8f8:	4885                	li	a7,1
 ecall
 8fa:	00000073          	ecall
 ret
 8fe:	8082                	ret

0000000000000900 <exit>:
.global exit
exit:
 li a7, SYS_exit
 900:	4889                	li	a7,2
 ecall
 902:	00000073          	ecall
 ret
 906:	8082                	ret

0000000000000908 <wait>:
.global wait
wait:
 li a7, SYS_wait
 908:	488d                	li	a7,3
 ecall
 90a:	00000073          	ecall
 ret
 90e:	8082                	ret

0000000000000910 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 910:	4891                	li	a7,4
 ecall
 912:	00000073          	ecall
 ret
 916:	8082                	ret

0000000000000918 <read>:
.global read
read:
 li a7, SYS_read
 918:	4895                	li	a7,5
 ecall
 91a:	00000073          	ecall
 ret
 91e:	8082                	ret

0000000000000920 <write>:
.global write
write:
 li a7, SYS_write
 920:	48c1                	li	a7,16
 ecall
 922:	00000073          	ecall
 ret
 926:	8082                	ret

0000000000000928 <close>:
.global close
close:
 li a7, SYS_close
 928:	48d5                	li	a7,21
 ecall
 92a:	00000073          	ecall
 ret
 92e:	8082                	ret

0000000000000930 <kill>:
.global kill
kill:
 li a7, SYS_kill
 930:	4899                	li	a7,6
 ecall
 932:	00000073          	ecall
 ret
 936:	8082                	ret

0000000000000938 <exec>:
.global exec
exec:
 li a7, SYS_exec
 938:	489d                	li	a7,7
 ecall
 93a:	00000073          	ecall
 ret
 93e:	8082                	ret

0000000000000940 <open>:
.global open
open:
 li a7, SYS_open
 940:	48bd                	li	a7,15
 ecall
 942:	00000073          	ecall
 ret
 946:	8082                	ret

0000000000000948 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 948:	48c5                	li	a7,17
 ecall
 94a:	00000073          	ecall
 ret
 94e:	8082                	ret

0000000000000950 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 950:	48c9                	li	a7,18
 ecall
 952:	00000073          	ecall
 ret
 956:	8082                	ret

0000000000000958 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 958:	48a1                	li	a7,8
 ecall
 95a:	00000073          	ecall
 ret
 95e:	8082                	ret

0000000000000960 <link>:
.global link
link:
 li a7, SYS_link
 960:	48cd                	li	a7,19
 ecall
 962:	00000073          	ecall
 ret
 966:	8082                	ret

0000000000000968 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 968:	48d1                	li	a7,20
 ecall
 96a:	00000073          	ecall
 ret
 96e:	8082                	ret

0000000000000970 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 970:	48a5                	li	a7,9
 ecall
 972:	00000073          	ecall
 ret
 976:	8082                	ret

0000000000000978 <dup>:
.global dup
dup:
 li a7, SYS_dup
 978:	48a9                	li	a7,10
 ecall
 97a:	00000073          	ecall
 ret
 97e:	8082                	ret

0000000000000980 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 980:	48ad                	li	a7,11
 ecall
 982:	00000073          	ecall
 ret
 986:	8082                	ret

0000000000000988 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 988:	48b1                	li	a7,12
 ecall
 98a:	00000073          	ecall
 ret
 98e:	8082                	ret

0000000000000990 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 990:	48b5                	li	a7,13
 ecall
 992:	00000073          	ecall
 ret
 996:	8082                	ret

0000000000000998 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 998:	48b9                	li	a7,14
 ecall
 99a:	00000073          	ecall
 ret
 99e:	8082                	ret

00000000000009a0 <ps>:
.global ps
ps:
 li a7, SYS_ps
 9a0:	48d9                	li	a7,22
 ecall
 9a2:	00000073          	ecall
 ret
 9a6:	8082                	ret

00000000000009a8 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 9a8:	48dd                	li	a7,23
 ecall
 9aa:	00000073          	ecall
 ret
 9ae:	8082                	ret

00000000000009b0 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 9b0:	48e1                	li	a7,24
 ecall
 9b2:	00000073          	ecall
 ret
 9b6:	8082                	ret

00000000000009b8 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 9b8:	48e9                	li	a7,26
 ecall
 9ba:	00000073          	ecall
 ret
 9be:	8082                	ret

00000000000009c0 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 9c0:	48e5                	li	a7,25
 ecall
 9c2:	00000073          	ecall
 ret
 9c6:	8082                	ret

00000000000009c8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9c8:	1101                	addi	sp,sp,-32
 9ca:	ec06                	sd	ra,24(sp)
 9cc:	e822                	sd	s0,16(sp)
 9ce:	1000                	addi	s0,sp,32
 9d0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9d4:	4605                	li	a2,1
 9d6:	fef40593          	addi	a1,s0,-17
 9da:	00000097          	auipc	ra,0x0
 9de:	f46080e7          	jalr	-186(ra) # 920 <write>
}
 9e2:	60e2                	ld	ra,24(sp)
 9e4:	6442                	ld	s0,16(sp)
 9e6:	6105                	addi	sp,sp,32
 9e8:	8082                	ret

00000000000009ea <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9ea:	7139                	addi	sp,sp,-64
 9ec:	fc06                	sd	ra,56(sp)
 9ee:	f822                	sd	s0,48(sp)
 9f0:	f426                	sd	s1,40(sp)
 9f2:	0080                	addi	s0,sp,64
 9f4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 9f6:	c299                	beqz	a3,9fc <printint+0x12>
 9f8:	0805cb63          	bltz	a1,a8e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 9fc:	2581                	sext.w	a1,a1
  neg = 0;
 9fe:	4881                	li	a7,0
 a00:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a04:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a06:	2601                	sext.w	a2,a2
 a08:	00001517          	auipc	a0,0x1
 a0c:	83050513          	addi	a0,a0,-2000 # 1238 <digits>
 a10:	883a                	mv	a6,a4
 a12:	2705                	addiw	a4,a4,1
 a14:	02c5f7bb          	remuw	a5,a1,a2
 a18:	1782                	slli	a5,a5,0x20
 a1a:	9381                	srli	a5,a5,0x20
 a1c:	97aa                	add	a5,a5,a0
 a1e:	0007c783          	lbu	a5,0(a5)
 a22:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a26:	0005879b          	sext.w	a5,a1
 a2a:	02c5d5bb          	divuw	a1,a1,a2
 a2e:	0685                	addi	a3,a3,1
 a30:	fec7f0e3          	bgeu	a5,a2,a10 <printint+0x26>
  if(neg)
 a34:	00088c63          	beqz	a7,a4c <printint+0x62>
    buf[i++] = '-';
 a38:	fd070793          	addi	a5,a4,-48
 a3c:	00878733          	add	a4,a5,s0
 a40:	02d00793          	li	a5,45
 a44:	fef70823          	sb	a5,-16(a4)
 a48:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a4c:	02e05c63          	blez	a4,a84 <printint+0x9a>
 a50:	f04a                	sd	s2,32(sp)
 a52:	ec4e                	sd	s3,24(sp)
 a54:	fc040793          	addi	a5,s0,-64
 a58:	00e78933          	add	s2,a5,a4
 a5c:	fff78993          	addi	s3,a5,-1
 a60:	99ba                	add	s3,s3,a4
 a62:	377d                	addiw	a4,a4,-1
 a64:	1702                	slli	a4,a4,0x20
 a66:	9301                	srli	a4,a4,0x20
 a68:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a6c:	fff94583          	lbu	a1,-1(s2)
 a70:	8526                	mv	a0,s1
 a72:	00000097          	auipc	ra,0x0
 a76:	f56080e7          	jalr	-170(ra) # 9c8 <putc>
  while(--i >= 0)
 a7a:	197d                	addi	s2,s2,-1
 a7c:	ff3918e3          	bne	s2,s3,a6c <printint+0x82>
 a80:	7902                	ld	s2,32(sp)
 a82:	69e2                	ld	s3,24(sp)
}
 a84:	70e2                	ld	ra,56(sp)
 a86:	7442                	ld	s0,48(sp)
 a88:	74a2                	ld	s1,40(sp)
 a8a:	6121                	addi	sp,sp,64
 a8c:	8082                	ret
    x = -xx;
 a8e:	40b005bb          	negw	a1,a1
    neg = 1;
 a92:	4885                	li	a7,1
    x = -xx;
 a94:	b7b5                	j	a00 <printint+0x16>

0000000000000a96 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a96:	715d                	addi	sp,sp,-80
 a98:	e486                	sd	ra,72(sp)
 a9a:	e0a2                	sd	s0,64(sp)
 a9c:	f84a                	sd	s2,48(sp)
 a9e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 aa0:	0005c903          	lbu	s2,0(a1)
 aa4:	1a090a63          	beqz	s2,c58 <vprintf+0x1c2>
 aa8:	fc26                	sd	s1,56(sp)
 aaa:	f44e                	sd	s3,40(sp)
 aac:	f052                	sd	s4,32(sp)
 aae:	ec56                	sd	s5,24(sp)
 ab0:	e85a                	sd	s6,16(sp)
 ab2:	e45e                	sd	s7,8(sp)
 ab4:	8aaa                	mv	s5,a0
 ab6:	8bb2                	mv	s7,a2
 ab8:	00158493          	addi	s1,a1,1
  state = 0;
 abc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 abe:	02500a13          	li	s4,37
 ac2:	4b55                	li	s6,21
 ac4:	a839                	j	ae2 <vprintf+0x4c>
        putc(fd, c);
 ac6:	85ca                	mv	a1,s2
 ac8:	8556                	mv	a0,s5
 aca:	00000097          	auipc	ra,0x0
 ace:	efe080e7          	jalr	-258(ra) # 9c8 <putc>
 ad2:	a019                	j	ad8 <vprintf+0x42>
    } else if(state == '%'){
 ad4:	01498d63          	beq	s3,s4,aee <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 ad8:	0485                	addi	s1,s1,1
 ada:	fff4c903          	lbu	s2,-1(s1)
 ade:	16090763          	beqz	s2,c4c <vprintf+0x1b6>
    if(state == 0){
 ae2:	fe0999e3          	bnez	s3,ad4 <vprintf+0x3e>
      if(c == '%'){
 ae6:	ff4910e3          	bne	s2,s4,ac6 <vprintf+0x30>
        state = '%';
 aea:	89d2                	mv	s3,s4
 aec:	b7f5                	j	ad8 <vprintf+0x42>
      if(c == 'd'){
 aee:	13490463          	beq	s2,s4,c16 <vprintf+0x180>
 af2:	f9d9079b          	addiw	a5,s2,-99
 af6:	0ff7f793          	zext.b	a5,a5
 afa:	12fb6763          	bltu	s6,a5,c28 <vprintf+0x192>
 afe:	f9d9079b          	addiw	a5,s2,-99
 b02:	0ff7f713          	zext.b	a4,a5
 b06:	12eb6163          	bltu	s6,a4,c28 <vprintf+0x192>
 b0a:	00271793          	slli	a5,a4,0x2
 b0e:	00000717          	auipc	a4,0x0
 b12:	6d270713          	addi	a4,a4,1746 # 11e0 <malloc+0x498>
 b16:	97ba                	add	a5,a5,a4
 b18:	439c                	lw	a5,0(a5)
 b1a:	97ba                	add	a5,a5,a4
 b1c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 b1e:	008b8913          	addi	s2,s7,8
 b22:	4685                	li	a3,1
 b24:	4629                	li	a2,10
 b26:	000ba583          	lw	a1,0(s7)
 b2a:	8556                	mv	a0,s5
 b2c:	00000097          	auipc	ra,0x0
 b30:	ebe080e7          	jalr	-322(ra) # 9ea <printint>
 b34:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 b36:	4981                	li	s3,0
 b38:	b745                	j	ad8 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b3a:	008b8913          	addi	s2,s7,8
 b3e:	4681                	li	a3,0
 b40:	4629                	li	a2,10
 b42:	000ba583          	lw	a1,0(s7)
 b46:	8556                	mv	a0,s5
 b48:	00000097          	auipc	ra,0x0
 b4c:	ea2080e7          	jalr	-350(ra) # 9ea <printint>
 b50:	8bca                	mv	s7,s2
      state = 0;
 b52:	4981                	li	s3,0
 b54:	b751                	j	ad8 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 b56:	008b8913          	addi	s2,s7,8
 b5a:	4681                	li	a3,0
 b5c:	4641                	li	a2,16
 b5e:	000ba583          	lw	a1,0(s7)
 b62:	8556                	mv	a0,s5
 b64:	00000097          	auipc	ra,0x0
 b68:	e86080e7          	jalr	-378(ra) # 9ea <printint>
 b6c:	8bca                	mv	s7,s2
      state = 0;
 b6e:	4981                	li	s3,0
 b70:	b7a5                	j	ad8 <vprintf+0x42>
 b72:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 b74:	008b8c13          	addi	s8,s7,8
 b78:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b7c:	03000593          	li	a1,48
 b80:	8556                	mv	a0,s5
 b82:	00000097          	auipc	ra,0x0
 b86:	e46080e7          	jalr	-442(ra) # 9c8 <putc>
  putc(fd, 'x');
 b8a:	07800593          	li	a1,120
 b8e:	8556                	mv	a0,s5
 b90:	00000097          	auipc	ra,0x0
 b94:	e38080e7          	jalr	-456(ra) # 9c8 <putc>
 b98:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b9a:	00000b97          	auipc	s7,0x0
 b9e:	69eb8b93          	addi	s7,s7,1694 # 1238 <digits>
 ba2:	03c9d793          	srli	a5,s3,0x3c
 ba6:	97de                	add	a5,a5,s7
 ba8:	0007c583          	lbu	a1,0(a5)
 bac:	8556                	mv	a0,s5
 bae:	00000097          	auipc	ra,0x0
 bb2:	e1a080e7          	jalr	-486(ra) # 9c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bb6:	0992                	slli	s3,s3,0x4
 bb8:	397d                	addiw	s2,s2,-1
 bba:	fe0914e3          	bnez	s2,ba2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 bbe:	8be2                	mv	s7,s8
      state = 0;
 bc0:	4981                	li	s3,0
 bc2:	6c02                	ld	s8,0(sp)
 bc4:	bf11                	j	ad8 <vprintf+0x42>
        s = va_arg(ap, char*);
 bc6:	008b8993          	addi	s3,s7,8
 bca:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 bce:	02090163          	beqz	s2,bf0 <vprintf+0x15a>
        while(*s != 0){
 bd2:	00094583          	lbu	a1,0(s2)
 bd6:	c9a5                	beqz	a1,c46 <vprintf+0x1b0>
          putc(fd, *s);
 bd8:	8556                	mv	a0,s5
 bda:	00000097          	auipc	ra,0x0
 bde:	dee080e7          	jalr	-530(ra) # 9c8 <putc>
          s++;
 be2:	0905                	addi	s2,s2,1
        while(*s != 0){
 be4:	00094583          	lbu	a1,0(s2)
 be8:	f9e5                	bnez	a1,bd8 <vprintf+0x142>
        s = va_arg(ap, char*);
 bea:	8bce                	mv	s7,s3
      state = 0;
 bec:	4981                	li	s3,0
 bee:	b5ed                	j	ad8 <vprintf+0x42>
          s = "(null)";
 bf0:	00000917          	auipc	s2,0x0
 bf4:	5e890913          	addi	s2,s2,1512 # 11d8 <malloc+0x490>
        while(*s != 0){
 bf8:	02800593          	li	a1,40
 bfc:	bff1                	j	bd8 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 bfe:	008b8913          	addi	s2,s7,8
 c02:	000bc583          	lbu	a1,0(s7)
 c06:	8556                	mv	a0,s5
 c08:	00000097          	auipc	ra,0x0
 c0c:	dc0080e7          	jalr	-576(ra) # 9c8 <putc>
 c10:	8bca                	mv	s7,s2
      state = 0;
 c12:	4981                	li	s3,0
 c14:	b5d1                	j	ad8 <vprintf+0x42>
        putc(fd, c);
 c16:	02500593          	li	a1,37
 c1a:	8556                	mv	a0,s5
 c1c:	00000097          	auipc	ra,0x0
 c20:	dac080e7          	jalr	-596(ra) # 9c8 <putc>
      state = 0;
 c24:	4981                	li	s3,0
 c26:	bd4d                	j	ad8 <vprintf+0x42>
        putc(fd, '%');
 c28:	02500593          	li	a1,37
 c2c:	8556                	mv	a0,s5
 c2e:	00000097          	auipc	ra,0x0
 c32:	d9a080e7          	jalr	-614(ra) # 9c8 <putc>
        putc(fd, c);
 c36:	85ca                	mv	a1,s2
 c38:	8556                	mv	a0,s5
 c3a:	00000097          	auipc	ra,0x0
 c3e:	d8e080e7          	jalr	-626(ra) # 9c8 <putc>
      state = 0;
 c42:	4981                	li	s3,0
 c44:	bd51                	j	ad8 <vprintf+0x42>
        s = va_arg(ap, char*);
 c46:	8bce                	mv	s7,s3
      state = 0;
 c48:	4981                	li	s3,0
 c4a:	b579                	j	ad8 <vprintf+0x42>
 c4c:	74e2                	ld	s1,56(sp)
 c4e:	79a2                	ld	s3,40(sp)
 c50:	7a02                	ld	s4,32(sp)
 c52:	6ae2                	ld	s5,24(sp)
 c54:	6b42                	ld	s6,16(sp)
 c56:	6ba2                	ld	s7,8(sp)
    }
  }
}
 c58:	60a6                	ld	ra,72(sp)
 c5a:	6406                	ld	s0,64(sp)
 c5c:	7942                	ld	s2,48(sp)
 c5e:	6161                	addi	sp,sp,80
 c60:	8082                	ret

0000000000000c62 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c62:	715d                	addi	sp,sp,-80
 c64:	ec06                	sd	ra,24(sp)
 c66:	e822                	sd	s0,16(sp)
 c68:	1000                	addi	s0,sp,32
 c6a:	e010                	sd	a2,0(s0)
 c6c:	e414                	sd	a3,8(s0)
 c6e:	e818                	sd	a4,16(s0)
 c70:	ec1c                	sd	a5,24(s0)
 c72:	03043023          	sd	a6,32(s0)
 c76:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c7a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c7e:	8622                	mv	a2,s0
 c80:	00000097          	auipc	ra,0x0
 c84:	e16080e7          	jalr	-490(ra) # a96 <vprintf>
}
 c88:	60e2                	ld	ra,24(sp)
 c8a:	6442                	ld	s0,16(sp)
 c8c:	6161                	addi	sp,sp,80
 c8e:	8082                	ret

0000000000000c90 <printf>:

void
printf(const char *fmt, ...)
{
 c90:	711d                	addi	sp,sp,-96
 c92:	ec06                	sd	ra,24(sp)
 c94:	e822                	sd	s0,16(sp)
 c96:	1000                	addi	s0,sp,32
 c98:	e40c                	sd	a1,8(s0)
 c9a:	e810                	sd	a2,16(s0)
 c9c:	ec14                	sd	a3,24(s0)
 c9e:	f018                	sd	a4,32(s0)
 ca0:	f41c                	sd	a5,40(s0)
 ca2:	03043823          	sd	a6,48(s0)
 ca6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 caa:	00840613          	addi	a2,s0,8
 cae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cb2:	85aa                	mv	a1,a0
 cb4:	4505                	li	a0,1
 cb6:	00000097          	auipc	ra,0x0
 cba:	de0080e7          	jalr	-544(ra) # a96 <vprintf>
}
 cbe:	60e2                	ld	ra,24(sp)
 cc0:	6442                	ld	s0,16(sp)
 cc2:	6125                	addi	sp,sp,96
 cc4:	8082                	ret

0000000000000cc6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cc6:	1141                	addi	sp,sp,-16
 cc8:	e422                	sd	s0,8(sp)
 cca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ccc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cd0:	00002797          	auipc	a5,0x2
 cd4:	8187b783          	ld	a5,-2024(a5) # 24e8 <freep>
 cd8:	a02d                	j	d02 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cda:	4618                	lw	a4,8(a2)
 cdc:	9f2d                	addw	a4,a4,a1
 cde:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ce2:	6398                	ld	a4,0(a5)
 ce4:	6310                	ld	a2,0(a4)
 ce6:	a83d                	j	d24 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ce8:	ff852703          	lw	a4,-8(a0)
 cec:	9f31                	addw	a4,a4,a2
 cee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cf0:	ff053683          	ld	a3,-16(a0)
 cf4:	a091                	j	d38 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cf6:	6398                	ld	a4,0(a5)
 cf8:	00e7e463          	bltu	a5,a4,d00 <free+0x3a>
 cfc:	00e6ea63          	bltu	a3,a4,d10 <free+0x4a>
{
 d00:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d02:	fed7fae3          	bgeu	a5,a3,cf6 <free+0x30>
 d06:	6398                	ld	a4,0(a5)
 d08:	00e6e463          	bltu	a3,a4,d10 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d0c:	fee7eae3          	bltu	a5,a4,d00 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d10:	ff852583          	lw	a1,-8(a0)
 d14:	6390                	ld	a2,0(a5)
 d16:	02059813          	slli	a6,a1,0x20
 d1a:	01c85713          	srli	a4,a6,0x1c
 d1e:	9736                	add	a4,a4,a3
 d20:	fae60de3          	beq	a2,a4,cda <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d24:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d28:	4790                	lw	a2,8(a5)
 d2a:	02061593          	slli	a1,a2,0x20
 d2e:	01c5d713          	srli	a4,a1,0x1c
 d32:	973e                	add	a4,a4,a5
 d34:	fae68ae3          	beq	a3,a4,ce8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 d38:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d3a:	00001717          	auipc	a4,0x1
 d3e:	7af73723          	sd	a5,1966(a4) # 24e8 <freep>
}
 d42:	6422                	ld	s0,8(sp)
 d44:	0141                	addi	sp,sp,16
 d46:	8082                	ret

0000000000000d48 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d48:	7139                	addi	sp,sp,-64
 d4a:	fc06                	sd	ra,56(sp)
 d4c:	f822                	sd	s0,48(sp)
 d4e:	f426                	sd	s1,40(sp)
 d50:	ec4e                	sd	s3,24(sp)
 d52:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d54:	02051493          	slli	s1,a0,0x20
 d58:	9081                	srli	s1,s1,0x20
 d5a:	04bd                	addi	s1,s1,15
 d5c:	8091                	srli	s1,s1,0x4
 d5e:	0014899b          	addiw	s3,s1,1
 d62:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d64:	00001517          	auipc	a0,0x1
 d68:	78453503          	ld	a0,1924(a0) # 24e8 <freep>
 d6c:	c915                	beqz	a0,da0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d6e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d70:	4798                	lw	a4,8(a5)
 d72:	08977e63          	bgeu	a4,s1,e0e <malloc+0xc6>
 d76:	f04a                	sd	s2,32(sp)
 d78:	e852                	sd	s4,16(sp)
 d7a:	e456                	sd	s5,8(sp)
 d7c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 d7e:	8a4e                	mv	s4,s3
 d80:	0009871b          	sext.w	a4,s3
 d84:	6685                	lui	a3,0x1
 d86:	00d77363          	bgeu	a4,a3,d8c <malloc+0x44>
 d8a:	6a05                	lui	s4,0x1
 d8c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d90:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d94:	00001917          	auipc	s2,0x1
 d98:	75490913          	addi	s2,s2,1876 # 24e8 <freep>
  if(p == (char*)-1)
 d9c:	5afd                	li	s5,-1
 d9e:	a091                	j	de2 <malloc+0x9a>
 da0:	f04a                	sd	s2,32(sp)
 da2:	e852                	sd	s4,16(sp)
 da4:	e456                	sd	s5,8(sp)
 da6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 da8:	04001797          	auipc	a5,0x4001
 dac:	74878793          	addi	a5,a5,1864 # 40024f0 <base>
 db0:	00001717          	auipc	a4,0x1
 db4:	72f73c23          	sd	a5,1848(a4) # 24e8 <freep>
 db8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dba:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dbe:	b7c1                	j	d7e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 dc0:	6398                	ld	a4,0(a5)
 dc2:	e118                	sd	a4,0(a0)
 dc4:	a08d                	j	e26 <malloc+0xde>
  hp->s.size = nu;
 dc6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 dca:	0541                	addi	a0,a0,16
 dcc:	00000097          	auipc	ra,0x0
 dd0:	efa080e7          	jalr	-262(ra) # cc6 <free>
  return freep;
 dd4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 dd8:	c13d                	beqz	a0,e3e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dda:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ddc:	4798                	lw	a4,8(a5)
 dde:	02977463          	bgeu	a4,s1,e06 <malloc+0xbe>
    if(p == freep)
 de2:	00093703          	ld	a4,0(s2)
 de6:	853e                	mv	a0,a5
 de8:	fef719e3          	bne	a4,a5,dda <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 dec:	8552                	mv	a0,s4
 dee:	00000097          	auipc	ra,0x0
 df2:	b9a080e7          	jalr	-1126(ra) # 988 <sbrk>
  if(p == (char*)-1)
 df6:	fd5518e3          	bne	a0,s5,dc6 <malloc+0x7e>
        return 0;
 dfa:	4501                	li	a0,0
 dfc:	7902                	ld	s2,32(sp)
 dfe:	6a42                	ld	s4,16(sp)
 e00:	6aa2                	ld	s5,8(sp)
 e02:	6b02                	ld	s6,0(sp)
 e04:	a03d                	j	e32 <malloc+0xea>
 e06:	7902                	ld	s2,32(sp)
 e08:	6a42                	ld	s4,16(sp)
 e0a:	6aa2                	ld	s5,8(sp)
 e0c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 e0e:	fae489e3          	beq	s1,a4,dc0 <malloc+0x78>
        p->s.size -= nunits;
 e12:	4137073b          	subw	a4,a4,s3
 e16:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e18:	02071693          	slli	a3,a4,0x20
 e1c:	01c6d713          	srli	a4,a3,0x1c
 e20:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e22:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e26:	00001717          	auipc	a4,0x1
 e2a:	6ca73123          	sd	a0,1730(a4) # 24e8 <freep>
      return (void*)(p + 1);
 e2e:	01078513          	addi	a0,a5,16
  }
}
 e32:	70e2                	ld	ra,56(sp)
 e34:	7442                	ld	s0,48(sp)
 e36:	74a2                	ld	s1,40(sp)
 e38:	69e2                	ld	s3,24(sp)
 e3a:	6121                	addi	sp,sp,64
 e3c:	8082                	ret
 e3e:	7902                	ld	s2,32(sp)
 e40:	6a42                	ld	s4,16(sp)
 e42:	6aa2                	ld	s5,8(sp)
 e44:	6b02                	ld	s6,0(sp)
 e46:	b7f5                	j	e32 <malloc+0xea>
