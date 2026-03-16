
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
  10:	e5450513          	addi	a0,a0,-428 # e60 <malloc+0x106>
  14:	00001097          	auipc	ra,0x1
  18:	c8e080e7          	jalr	-882(ra) # ca2 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	e6450513          	addi	a0,a0,-412 # e80 <malloc+0x126>
  24:	00001097          	auipc	ra,0x1
  28:	c7e080e7          	jalr	-898(ra) # ca2 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	9a6080e7          	jalr	-1626(ra) # 9d2 <pfreepages>

    for (int i = 0; i < 3; ++i)
  34:	fd040493          	addi	s1,s0,-48
  38:	fdc40913          	addi	s2,s0,-36
    {
        if ((pid[i] = fork()) == 0)
  3c:	00001097          	auipc	ra,0x1
  40:	8ce080e7          	jalr	-1842(ra) # 90a <fork>
  44:	c088                	sw	a0,0(s1)
  46:	c531                	beqz	a0,92 <testcase5+0x92>
            // PARENT
            break;
        }
    }

    sleep(100);
  48:	06400513          	li	a0,100
  4c:	00001097          	auipc	ra,0x1
  50:	956080e7          	jalr	-1706(ra) # 9a2 <sleep>
  54:	448d                	li	s1,3

    for (int i = 0; i < 3; ++i)
    {
        int _pid = wait(0);
  56:	4501                	li	a0,0
  58:	00001097          	auipc	ra,0x1
  5c:	8c2080e7          	jalr	-1854(ra) # 91a <wait>
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
  7c:	e1850513          	addi	a0,a0,-488 # e90 <malloc+0x136>
  80:	00001097          	auipc	ra,0x1
  84:	c22080e7          	jalr	-990(ra) # ca2 <printf>
                exit(1);
  88:	4505                	li	a0,1
  8a:	00001097          	auipc	ra,0x1
  8e:	888080e7          	jalr	-1912(ra) # 912 <exit>
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
  a2:	e0250513          	addi	a0,a0,-510 # ea0 <malloc+0x146>
  a6:	00001097          	auipc	ra,0x1
  aa:	bfc080e7          	jalr	-1028(ra) # ca2 <printf>
    print_free_frame_cnt();
  ae:	00001097          	auipc	ra,0x1
  b2:	924080e7          	jalr	-1756(ra) # 9d2 <pfreepages>
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
  ca:	e04a                	sd	s2,0(sp)
  cc:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	de250513          	addi	a0,a0,-542 # eb0 <malloc+0x156>
  d6:	00001097          	auipc	ra,0x1
  da:	bcc080e7          	jalr	-1076(ra) # ca2 <printf>
    printf("[prnt] v1 --> ");
  de:	00001517          	auipc	a0,0x1
  e2:	da250513          	addi	a0,a0,-606 # e80 <malloc+0x126>
  e6:	00001097          	auipc	ra,0x1
  ea:	bbc080e7          	jalr	-1092(ra) # ca2 <printf>
    print_free_frame_cnt();
  ee:	00001097          	auipc	ra,0x1
  f2:	8e4080e7          	jalr	-1820(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
  f6:	00001097          	auipc	ra,0x1
  fa:	814080e7          	jalr	-2028(ra) # 90a <fork>
  fe:	c971                	beqz	a0,1d2 <testcase4+0x110>
 100:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 102:	00001517          	auipc	a0,0x1
 106:	ede50513          	addi	a0,a0,-290 # fe0 <malloc+0x286>
 10a:	00001097          	auipc	ra,0x1
 10e:	b98080e7          	jalr	-1128(ra) # ca2 <printf>
        print_free_frame_cnt();
 112:	00001097          	auipc	ra,0x1
 116:	8c0080e7          	jalr	-1856(ra) # 9d2 <pfreepages>

        global_array[0] = 111;
 11a:	00002917          	auipc	s2,0x2
 11e:	3d690913          	addi	s2,s2,982 # 24f0 <global_array>
 122:	06f00793          	li	a5,111
 126:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 12a:	06f00593          	li	a1,111
 12e:	00001517          	auipc	a0,0x1
 132:	ec250513          	addi	a0,a0,-318 # ff0 <malloc+0x296>
 136:	00001097          	auipc	ra,0x1
 13a:	b6c080e7          	jalr	-1172(ra) # ca2 <printf>

        printf("[prnt] v3 --> ");
 13e:	00001517          	auipc	a0,0x1
 142:	efa50513          	addi	a0,a0,-262 # 1038 <malloc+0x2de>
 146:	00001097          	auipc	ra,0x1
 14a:	b5c080e7          	jalr	-1188(ra) # ca2 <printf>
        print_free_frame_cnt();
 14e:	00001097          	auipc	ra,0x1
 152:	884080e7          	jalr	-1916(ra) # 9d2 <pfreepages>
        sleep(100);
 156:	06400513          	li	a0,100
 15a:	00001097          	auipc	ra,0x1
 15e:	848080e7          	jalr	-1976(ra) # 9a2 <sleep>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 162:	00001097          	auipc	ra,0x1
 166:	830080e7          	jalr	-2000(ra) # 992 <getpid>
 16a:	85aa                	mv	a1,a0
 16c:	854a                	mv	a0,s2
 16e:	00001097          	auipc	ra,0x1
 172:	85c080e7          	jalr	-1956(ra) # 9ca <va2pa>
 176:	85aa                	mv	a1,a0
 178:	00001517          	auipc	a0,0x1
 17c:	ed050513          	addi	a0,a0,-304 # 1048 <malloc+0x2ee>
 180:	00001097          	auipc	ra,0x1
 184:	b22080e7          	jalr	-1246(ra) # ca2 <printf>
    }

    if (wait(0) != pid)
 188:	4501                	li	a0,0
 18a:	00000097          	auipc	ra,0x0
 18e:	790080e7          	jalr	1936(ra) # 91a <wait>
 192:	12951f63          	bne	a0,s1,2d0 <testcase4+0x20e>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
 196:	00002597          	auipc	a1,0x2
 19a:	35a5a583          	lw	a1,858(a1) # 24f0 <global_array>
 19e:	00001517          	auipc	a0,0x1
 1a2:	ec250513          	addi	a0,a0,-318 # 1060 <malloc+0x306>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	afc080e7          	jalr	-1284(ra) # ca2 <printf>

    printf("[prnt] v7 --> ");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	cf250513          	addi	a0,a0,-782 # ea0 <malloc+0x146>
 1b6:	00001097          	auipc	ra,0x1
 1ba:	aec080e7          	jalr	-1300(ra) # ca2 <printf>
    print_free_frame_cnt();
 1be:	00001097          	auipc	ra,0x1
 1c2:	814080e7          	jalr	-2028(ra) # 9d2 <pfreepages>
}
 1c6:	60e2                	ld	ra,24(sp)
 1c8:	6442                	ld	s0,16(sp)
 1ca:	64a2                	ld	s1,8(sp)
 1cc:	6902                	ld	s2,0(sp)
 1ce:	6105                	addi	sp,sp,32
 1d0:	8082                	ret
        sleep(50);
 1d2:	03200513          	li	a0,50
 1d6:	00000097          	auipc	ra,0x0
 1da:	7cc080e7          	jalr	1996(ra) # 9a2 <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 1de:	00002497          	auipc	s1,0x2
 1e2:	31248493          	addi	s1,s1,786 # 24f0 <global_array>
 1e6:	00000097          	auipc	ra,0x0
 1ea:	7ac080e7          	jalr	1964(ra) # 992 <getpid>
 1ee:	85aa                	mv	a1,a0
 1f0:	8526                	mv	a0,s1
 1f2:	00000097          	auipc	ra,0x0
 1f6:	7d8080e7          	jalr	2008(ra) # 9ca <va2pa>
 1fa:	85aa                	mv	a1,a0
 1fc:	00001517          	auipc	a0,0x1
 200:	cd450513          	addi	a0,a0,-812 # ed0 <malloc+0x176>
 204:	00001097          	auipc	ra,0x1
 208:	a9e080e7          	jalr	-1378(ra) # ca2 <printf>
        printf("[chld] v4 --> ");
 20c:	00001517          	auipc	a0,0x1
 210:	cdc50513          	addi	a0,a0,-804 # ee8 <malloc+0x18e>
 214:	00001097          	auipc	ra,0x1
 218:	a8e080e7          	jalr	-1394(ra) # ca2 <printf>
        print_free_frame_cnt();
 21c:	00000097          	auipc	ra,0x0
 220:	7b6080e7          	jalr	1974(ra) # 9d2 <pfreepages>
        global_array[0] = 222;
 224:	0de00793          	li	a5,222
 228:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 22a:	0de00593          	li	a1,222
 22e:	00001517          	auipc	a0,0x1
 232:	cca50513          	addi	a0,a0,-822 # ef8 <malloc+0x19e>
 236:	00001097          	auipc	ra,0x1
 23a:	a6c080e7          	jalr	-1428(ra) # ca2 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], getpid()));
 23e:	00000097          	auipc	ra,0x0
 242:	754080e7          	jalr	1876(ra) # 992 <getpid>
 246:	85aa                	mv	a1,a0
 248:	8526                	mv	a0,s1
 24a:	00000097          	auipc	ra,0x0
 24e:	780080e7          	jalr	1920(ra) # 9ca <va2pa>
 252:	85aa                	mv	a1,a0
 254:	00001517          	auipc	a0,0x1
 258:	cec50513          	addi	a0,a0,-788 # f40 <malloc+0x1e6>
 25c:	00001097          	auipc	ra,0x1
 260:	a46080e7          	jalr	-1466(ra) # ca2 <printf>
        printf("[chld] v5 --> ");
 264:	00001517          	auipc	a0,0x1
 268:	cf450513          	addi	a0,a0,-780 # f58 <malloc+0x1fe>
 26c:	00001097          	auipc	ra,0x1
 270:	a36080e7          	jalr	-1482(ra) # ca2 <printf>
        print_free_frame_cnt();
 274:	00000097          	auipc	ra,0x0
 278:	75e080e7          	jalr	1886(ra) # 9d2 <pfreepages>
        global_array[2047] = 333;
 27c:	14d00793          	li	a5,333
 280:	00004717          	auipc	a4,0x4
 284:	26f72623          	sw	a5,620(a4) # 44ec <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 288:	14d00593          	li	a1,333
 28c:	00001517          	auipc	a0,0x1
 290:	cdc50513          	addi	a0,a0,-804 # f68 <malloc+0x20e>
 294:	00001097          	auipc	ra,0x1
 298:	a0e080e7          	jalr	-1522(ra) # ca2 <printf>
        printf("[chld] v6 --> ");
 29c:	00001517          	auipc	a0,0x1
 2a0:	d1450513          	addi	a0,a0,-748 # fb0 <malloc+0x256>
 2a4:	00001097          	auipc	ra,0x1
 2a8:	9fe080e7          	jalr	-1538(ra) # ca2 <printf>
        print_free_frame_cnt();
 2ac:	00000097          	auipc	ra,0x0
 2b0:	726080e7          	jalr	1830(ra) # 9d2 <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 2b4:	408c                	lw	a1,0(s1)
 2b6:	00001517          	auipc	a0,0x1
 2ba:	d0a50513          	addi	a0,a0,-758 # fc0 <malloc+0x266>
 2be:	00001097          	auipc	ra,0x1
 2c2:	9e4080e7          	jalr	-1564(ra) # ca2 <printf>
        exit(0);
 2c6:	4501                	li	a0,0
 2c8:	00000097          	auipc	ra,0x0
 2cc:	64a080e7          	jalr	1610(ra) # 912 <exit>
        printf("wait() error!");
 2d0:	00001517          	auipc	a0,0x1
 2d4:	bc050513          	addi	a0,a0,-1088 # e90 <malloc+0x136>
 2d8:	00001097          	auipc	ra,0x1
 2dc:	9ca080e7          	jalr	-1590(ra) # ca2 <printf>
        exit(1);
 2e0:	4505                	li	a0,1
 2e2:	00000097          	auipc	ra,0x0
 2e6:	630080e7          	jalr	1584(ra) # 912 <exit>

00000000000002ea <testcase3>:

void testcase3()
{
 2ea:	1101                	addi	sp,sp,-32
 2ec:	ec06                	sd	ra,24(sp)
 2ee:	e822                	sd	s0,16(sp)
 2f0:	e426                	sd	s1,8(sp)
 2f2:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 2f4:	00001517          	auipc	a0,0x1
 2f8:	d8c50513          	addi	a0,a0,-628 # 1080 <malloc+0x326>
 2fc:	00001097          	auipc	ra,0x1
 300:	9a6080e7          	jalr	-1626(ra) # ca2 <printf>
    printf("[prnt] v1 --> ");
 304:	00001517          	auipc	a0,0x1
 308:	b7c50513          	addi	a0,a0,-1156 # e80 <malloc+0x126>
 30c:	00001097          	auipc	ra,0x1
 310:	996080e7          	jalr	-1642(ra) # ca2 <printf>
    print_free_frame_cnt();
 314:	00000097          	auipc	ra,0x0
 318:	6be080e7          	jalr	1726(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
 31c:	00000097          	auipc	ra,0x0
 320:	5ee080e7          	jalr	1518(ra) # 90a <fork>
 324:	cd35                	beqz	a0,3a0 <testcase3+0xb6>
 326:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 328:	00001517          	auipc	a0,0x1
 32c:	cb850513          	addi	a0,a0,-840 # fe0 <malloc+0x286>
 330:	00001097          	auipc	ra,0x1
 334:	972080e7          	jalr	-1678(ra) # ca2 <printf>
        print_free_frame_cnt();
 338:	00000097          	auipc	ra,0x0
 33c:	69a080e7          	jalr	1690(ra) # 9d2 <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 340:	00002597          	auipc	a1,0x2
 344:	1a05a583          	lw	a1,416(a1) # 24e0 <global_var>
 348:	00001517          	auipc	a0,0x1
 34c:	d8850513          	addi	a0,a0,-632 # 10d0 <malloc+0x376>
 350:	00001097          	auipc	ra,0x1
 354:	952080e7          	jalr	-1710(ra) # ca2 <printf>

        printf("[prnt] v3 --> ");
 358:	00001517          	auipc	a0,0x1
 35c:	ce050513          	addi	a0,a0,-800 # 1038 <malloc+0x2de>
 360:	00001097          	auipc	ra,0x1
 364:	942080e7          	jalr	-1726(ra) # ca2 <printf>
        print_free_frame_cnt();
 368:	00000097          	auipc	ra,0x0
 36c:	66a080e7          	jalr	1642(ra) # 9d2 <pfreepages>
    }

    if (wait(0) != pid)
 370:	4501                	li	a0,0
 372:	00000097          	auipc	ra,0x0
 376:	5a8080e7          	jalr	1448(ra) # 91a <wait>
 37a:	08951663          	bne	a0,s1,406 <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 37e:	00001517          	auipc	a0,0x1
 382:	d7a50513          	addi	a0,a0,-646 # 10f8 <malloc+0x39e>
 386:	00001097          	auipc	ra,0x1
 38a:	91c080e7          	jalr	-1764(ra) # ca2 <printf>
    print_free_frame_cnt();
 38e:	00000097          	auipc	ra,0x0
 392:	644080e7          	jalr	1604(ra) # 9d2 <pfreepages>
}
 396:	60e2                	ld	ra,24(sp)
 398:	6442                	ld	s0,16(sp)
 39a:	64a2                	ld	s1,8(sp)
 39c:	6105                	addi	sp,sp,32
 39e:	8082                	ret
        sleep(50);
 3a0:	03200513          	li	a0,50
 3a4:	00000097          	auipc	ra,0x0
 3a8:	5fe080e7          	jalr	1534(ra) # 9a2 <sleep>
        printf("[chld] v4 --> ");
 3ac:	00001517          	auipc	a0,0x1
 3b0:	b3c50513          	addi	a0,a0,-1220 # ee8 <malloc+0x18e>
 3b4:	00001097          	auipc	ra,0x1
 3b8:	8ee080e7          	jalr	-1810(ra) # ca2 <printf>
        print_free_frame_cnt();
 3bc:	00000097          	auipc	ra,0x0
 3c0:	616080e7          	jalr	1558(ra) # 9d2 <pfreepages>
        global_var = 100;
 3c4:	06400793          	li	a5,100
 3c8:	00002717          	auipc	a4,0x2
 3cc:	10f72c23          	sw	a5,280(a4) # 24e0 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 3d0:	06400593          	li	a1,100
 3d4:	00001517          	auipc	a0,0x1
 3d8:	ccc50513          	addi	a0,a0,-820 # 10a0 <malloc+0x346>
 3dc:	00001097          	auipc	ra,0x1
 3e0:	8c6080e7          	jalr	-1850(ra) # ca2 <printf>
        printf("[chld] v5 --> ");
 3e4:	00001517          	auipc	a0,0x1
 3e8:	b7450513          	addi	a0,a0,-1164 # f58 <malloc+0x1fe>
 3ec:	00001097          	auipc	ra,0x1
 3f0:	8b6080e7          	jalr	-1866(ra) # ca2 <printf>
        print_free_frame_cnt();
 3f4:	00000097          	auipc	ra,0x0
 3f8:	5de080e7          	jalr	1502(ra) # 9d2 <pfreepages>
        exit(0);
 3fc:	4501                	li	a0,0
 3fe:	00000097          	auipc	ra,0x0
 402:	514080e7          	jalr	1300(ra) # 912 <exit>
        printf("wait() error!");
 406:	00001517          	auipc	a0,0x1
 40a:	a8a50513          	addi	a0,a0,-1398 # e90 <malloc+0x136>
 40e:	00001097          	auipc	ra,0x1
 412:	894080e7          	jalr	-1900(ra) # ca2 <printf>
        exit(1);
 416:	4505                	li	a0,1
 418:	00000097          	auipc	ra,0x0
 41c:	4fa080e7          	jalr	1274(ra) # 912 <exit>

0000000000000420 <testcase2>:

void testcase2()
{
 420:	1101                	addi	sp,sp,-32
 422:	ec06                	sd	ra,24(sp)
 424:	e822                	sd	s0,16(sp)
 426:	e426                	sd	s1,8(sp)
 428:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 42a:	00001517          	auipc	a0,0x1
 42e:	cde50513          	addi	a0,a0,-802 # 1108 <malloc+0x3ae>
 432:	00001097          	auipc	ra,0x1
 436:	870080e7          	jalr	-1936(ra) # ca2 <printf>
    printf("[prnt] v1 --> ");
 43a:	00001517          	auipc	a0,0x1
 43e:	a4650513          	addi	a0,a0,-1466 # e80 <malloc+0x126>
 442:	00001097          	auipc	ra,0x1
 446:	860080e7          	jalr	-1952(ra) # ca2 <printf>
    print_free_frame_cnt();
 44a:	00000097          	auipc	ra,0x0
 44e:	588080e7          	jalr	1416(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
 452:	00000097          	auipc	ra,0x0
 456:	4b8080e7          	jalr	1208(ra) # 90a <fork>
 45a:	c531                	beqz	a0,4a6 <testcase2+0x86>
 45c:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 45e:	00001517          	auipc	a0,0x1
 462:	b8250513          	addi	a0,a0,-1150 # fe0 <malloc+0x286>
 466:	00001097          	auipc	ra,0x1
 46a:	83c080e7          	jalr	-1988(ra) # ca2 <printf>
        print_free_frame_cnt();
 46e:	00000097          	auipc	ra,0x0
 472:	564080e7          	jalr	1380(ra) # 9d2 <pfreepages>
    }

    if (wait(0) != pid)
 476:	4501                	li	a0,0
 478:	00000097          	auipc	ra,0x0
 47c:	4a2080e7          	jalr	1186(ra) # 91a <wait>
 480:	08951263          	bne	a0,s1,504 <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 484:	00001517          	auipc	a0,0x1
 488:	cdc50513          	addi	a0,a0,-804 # 1160 <malloc+0x406>
 48c:	00001097          	auipc	ra,0x1
 490:	816080e7          	jalr	-2026(ra) # ca2 <printf>
    print_free_frame_cnt();
 494:	00000097          	auipc	ra,0x0
 498:	53e080e7          	jalr	1342(ra) # 9d2 <pfreepages>
}
 49c:	60e2                	ld	ra,24(sp)
 49e:	6442                	ld	s0,16(sp)
 4a0:	64a2                	ld	s1,8(sp)
 4a2:	6105                	addi	sp,sp,32
 4a4:	8082                	ret
        sleep(50);
 4a6:	03200513          	li	a0,50
 4aa:	00000097          	auipc	ra,0x0
 4ae:	4f8080e7          	jalr	1272(ra) # 9a2 <sleep>
        printf("[chld] v3 --> ");
 4b2:	00001517          	auipc	a0,0x1
 4b6:	c7650513          	addi	a0,a0,-906 # 1128 <malloc+0x3ce>
 4ba:	00000097          	auipc	ra,0x0
 4be:	7e8080e7          	jalr	2024(ra) # ca2 <printf>
        print_free_frame_cnt();
 4c2:	00000097          	auipc	ra,0x0
 4c6:	510080e7          	jalr	1296(ra) # 9d2 <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 4ca:	00002597          	auipc	a1,0x2
 4ce:	0165a583          	lw	a1,22(a1) # 24e0 <global_var>
 4d2:	00001517          	auipc	a0,0x1
 4d6:	c6650513          	addi	a0,a0,-922 # 1138 <malloc+0x3de>
 4da:	00000097          	auipc	ra,0x0
 4de:	7c8080e7          	jalr	1992(ra) # ca2 <printf>
        printf("[chld] v4 --> ");
 4e2:	00001517          	auipc	a0,0x1
 4e6:	a0650513          	addi	a0,a0,-1530 # ee8 <malloc+0x18e>
 4ea:	00000097          	auipc	ra,0x0
 4ee:	7b8080e7          	jalr	1976(ra) # ca2 <printf>
        print_free_frame_cnt();
 4f2:	00000097          	auipc	ra,0x0
 4f6:	4e0080e7          	jalr	1248(ra) # 9d2 <pfreepages>
        exit(0);
 4fa:	4501                	li	a0,0
 4fc:	00000097          	auipc	ra,0x0
 500:	416080e7          	jalr	1046(ra) # 912 <exit>
        printf("wait() error!");
 504:	00001517          	auipc	a0,0x1
 508:	98c50513          	addi	a0,a0,-1652 # e90 <malloc+0x136>
 50c:	00000097          	auipc	ra,0x0
 510:	796080e7          	jalr	1942(ra) # ca2 <printf>
        exit(1);
 514:	4505                	li	a0,1
 516:	00000097          	auipc	ra,0x0
 51a:	3fc080e7          	jalr	1020(ra) # 912 <exit>

000000000000051e <testcase1>:

void testcase1()
{
 51e:	1101                	addi	sp,sp,-32
 520:	ec06                	sd	ra,24(sp)
 522:	e822                	sd	s0,16(sp)
 524:	e426                	sd	s1,8(sp)
 526:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 528:	00001517          	auipc	a0,0x1
 52c:	c4850513          	addi	a0,a0,-952 # 1170 <malloc+0x416>
 530:	00000097          	auipc	ra,0x0
 534:	772080e7          	jalr	1906(ra) # ca2 <printf>
    printf("[prnt] v1 --> ");
 538:	00001517          	auipc	a0,0x1
 53c:	94850513          	addi	a0,a0,-1720 # e80 <malloc+0x126>
 540:	00000097          	auipc	ra,0x0
 544:	762080e7          	jalr	1890(ra) # ca2 <printf>
    print_free_frame_cnt();
 548:	00000097          	auipc	ra,0x0
 54c:	48a080e7          	jalr	1162(ra) # 9d2 <pfreepages>

    if ((pid = fork()) == 0)
 550:	00000097          	auipc	ra,0x0
 554:	3ba080e7          	jalr	954(ra) # 90a <fork>
 558:	c531                	beqz	a0,5a4 <testcase1+0x86>
 55a:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 55c:	00001517          	auipc	a0,0x1
 560:	adc50513          	addi	a0,a0,-1316 # 1038 <malloc+0x2de>
 564:	00000097          	auipc	ra,0x0
 568:	73e080e7          	jalr	1854(ra) # ca2 <printf>
        print_free_frame_cnt();
 56c:	00000097          	auipc	ra,0x0
 570:	466080e7          	jalr	1126(ra) # 9d2 <pfreepages>
    }

    if (wait(0) != pid)
 574:	4501                	li	a0,0
 576:	00000097          	auipc	ra,0x0
 57a:	3a4080e7          	jalr	932(ra) # 91a <wait>
 57e:	04951a63          	bne	a0,s1,5d2 <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 582:	00001517          	auipc	a0,0x1
 586:	c1e50513          	addi	a0,a0,-994 # 11a0 <malloc+0x446>
 58a:	00000097          	auipc	ra,0x0
 58e:	718080e7          	jalr	1816(ra) # ca2 <printf>
    print_free_frame_cnt();
 592:	00000097          	auipc	ra,0x0
 596:	440080e7          	jalr	1088(ra) # 9d2 <pfreepages>
}
 59a:	60e2                	ld	ra,24(sp)
 59c:	6442                	ld	s0,16(sp)
 59e:	64a2                	ld	s1,8(sp)
 5a0:	6105                	addi	sp,sp,32
 5a2:	8082                	ret
        sleep(50);
 5a4:	03200513          	li	a0,50
 5a8:	00000097          	auipc	ra,0x0
 5ac:	3fa080e7          	jalr	1018(ra) # 9a2 <sleep>
        printf("[chld] v2 --> ");
 5b0:	00001517          	auipc	a0,0x1
 5b4:	be050513          	addi	a0,a0,-1056 # 1190 <malloc+0x436>
 5b8:	00000097          	auipc	ra,0x0
 5bc:	6ea080e7          	jalr	1770(ra) # ca2 <printf>
        print_free_frame_cnt();
 5c0:	00000097          	auipc	ra,0x0
 5c4:	412080e7          	jalr	1042(ra) # 9d2 <pfreepages>
        exit(0);
 5c8:	4501                	li	a0,0
 5ca:	00000097          	auipc	ra,0x0
 5ce:	348080e7          	jalr	840(ra) # 912 <exit>
        printf("wait() error!");
 5d2:	00001517          	auipc	a0,0x1
 5d6:	8be50513          	addi	a0,a0,-1858 # e90 <malloc+0x136>
 5da:	00000097          	auipc	ra,0x0
 5de:	6c8080e7          	jalr	1736(ra) # ca2 <printf>
        exit(1);
 5e2:	4505                	li	a0,1
 5e4:	00000097          	auipc	ra,0x0
 5e8:	32e080e7          	jalr	814(ra) # 912 <exit>

00000000000005ec <main>:

int main(int argc, char *argv[])
{
 5ec:	1101                	addi	sp,sp,-32
 5ee:	ec06                	sd	ra,24(sp)
 5f0:	e822                	sd	s0,16(sp)
 5f2:	e426                	sd	s1,8(sp)
 5f4:	1000                	addi	s0,sp,32
    if (argc < 2)
 5f6:	4785                	li	a5,1
 5f8:	02a7d963          	bge	a5,a0,62a <main+0x3e>
 5fc:	84ae                	mv	s1,a1
    {
        printf("Usage: cowtest test_id\n");
        exit(-1);
    }
    switch (atoi(argv[1]))
 5fe:	6588                	ld	a0,8(a1)
 600:	00000097          	auipc	ra,0x0
 604:	218080e7          	jalr	536(ra) # 818 <atoi>
 608:	478d                	li	a5,3
 60a:	06f50063          	beq	a0,a5,66a <main+0x7e>
 60e:	02a7cb63          	blt	a5,a0,644 <main+0x58>
 612:	4785                	li	a5,1
 614:	04f50163          	beq	a0,a5,656 <main+0x6a>
 618:	4789                	li	a5,2
 61a:	04f51e63          	bne	a0,a5,676 <main+0x8a>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 61e:	00000097          	auipc	ra,0x0
 622:	e02080e7          	jalr	-510(ra) # 420 <testcase2>

    default:
        printf("Error: No test with index %s\n", argv[1]);
        return 1;
    }
    return 0;
 626:	4501                	li	a0,0
        break;
 628:	a825                	j	660 <main+0x74>
        printf("Usage: cowtest test_id\n");
 62a:	00001517          	auipc	a0,0x1
 62e:	b8650513          	addi	a0,a0,-1146 # 11b0 <malloc+0x456>
 632:	00000097          	auipc	ra,0x0
 636:	670080e7          	jalr	1648(ra) # ca2 <printf>
        exit(-1);
 63a:	557d                	li	a0,-1
 63c:	00000097          	auipc	ra,0x0
 640:	2d6080e7          	jalr	726(ra) # 912 <exit>
    switch (atoi(argv[1]))
 644:	4791                	li	a5,4
 646:	02f51863          	bne	a0,a5,676 <main+0x8a>
        testcase4();
 64a:	00000097          	auipc	ra,0x0
 64e:	a78080e7          	jalr	-1416(ra) # c2 <testcase4>
    return 0;
 652:	4501                	li	a0,0
        break;
 654:	a031                	j	660 <main+0x74>
        testcase1();
 656:	00000097          	auipc	ra,0x0
 65a:	ec8080e7          	jalr	-312(ra) # 51e <testcase1>
    return 0;
 65e:	4501                	li	a0,0
}
 660:	60e2                	ld	ra,24(sp)
 662:	6442                	ld	s0,16(sp)
 664:	64a2                	ld	s1,8(sp)
 666:	6105                	addi	sp,sp,32
 668:	8082                	ret
        testcase3();
 66a:	00000097          	auipc	ra,0x0
 66e:	c80080e7          	jalr	-896(ra) # 2ea <testcase3>
    return 0;
 672:	4501                	li	a0,0
        break;
 674:	b7f5                	j	660 <main+0x74>
        printf("Error: No test with index %s\n", argv[1]);
 676:	648c                	ld	a1,8(s1)
 678:	00001517          	auipc	a0,0x1
 67c:	b5050513          	addi	a0,a0,-1200 # 11c8 <malloc+0x46e>
 680:	00000097          	auipc	ra,0x0
 684:	622080e7          	jalr	1570(ra) # ca2 <printf>
        return 1;
 688:	4505                	li	a0,1
 68a:	bfd9                	j	660 <main+0x74>

000000000000068c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 68c:	1141                	addi	sp,sp,-16
 68e:	e406                	sd	ra,8(sp)
 690:	e022                	sd	s0,0(sp)
 692:	0800                	addi	s0,sp,16
  extern int main();
  main();
 694:	00000097          	auipc	ra,0x0
 698:	f58080e7          	jalr	-168(ra) # 5ec <main>
  exit(0);
 69c:	4501                	li	a0,0
 69e:	00000097          	auipc	ra,0x0
 6a2:	274080e7          	jalr	628(ra) # 912 <exit>

00000000000006a6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 6a6:	1141                	addi	sp,sp,-16
 6a8:	e422                	sd	s0,8(sp)
 6aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6ac:	87aa                	mv	a5,a0
 6ae:	0585                	addi	a1,a1,1
 6b0:	0785                	addi	a5,a5,1
 6b2:	fff5c703          	lbu	a4,-1(a1)
 6b6:	fee78fa3          	sb	a4,-1(a5)
 6ba:	fb75                	bnez	a4,6ae <strcpy+0x8>
    ;
  return os;
}
 6bc:	6422                	ld	s0,8(sp)
 6be:	0141                	addi	sp,sp,16
 6c0:	8082                	ret

00000000000006c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6c2:	1141                	addi	sp,sp,-16
 6c4:	e422                	sd	s0,8(sp)
 6c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6c8:	00054783          	lbu	a5,0(a0)
 6cc:	cb91                	beqz	a5,6e0 <strcmp+0x1e>
 6ce:	0005c703          	lbu	a4,0(a1)
 6d2:	00f71763          	bne	a4,a5,6e0 <strcmp+0x1e>
    p++, q++;
 6d6:	0505                	addi	a0,a0,1
 6d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6da:	00054783          	lbu	a5,0(a0)
 6de:	fbe5                	bnez	a5,6ce <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6e0:	0005c503          	lbu	a0,0(a1)
}
 6e4:	40a7853b          	subw	a0,a5,a0
 6e8:	6422                	ld	s0,8(sp)
 6ea:	0141                	addi	sp,sp,16
 6ec:	8082                	ret

00000000000006ee <strlen>:

uint
strlen(const char *s)
{
 6ee:	1141                	addi	sp,sp,-16
 6f0:	e422                	sd	s0,8(sp)
 6f2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6f4:	00054783          	lbu	a5,0(a0)
 6f8:	cf91                	beqz	a5,714 <strlen+0x26>
 6fa:	0505                	addi	a0,a0,1
 6fc:	87aa                	mv	a5,a0
 6fe:	86be                	mv	a3,a5
 700:	0785                	addi	a5,a5,1
 702:	fff7c703          	lbu	a4,-1(a5)
 706:	ff65                	bnez	a4,6fe <strlen+0x10>
 708:	40a6853b          	subw	a0,a3,a0
 70c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 70e:	6422                	ld	s0,8(sp)
 710:	0141                	addi	sp,sp,16
 712:	8082                	ret
  for(n = 0; s[n]; n++)
 714:	4501                	li	a0,0
 716:	bfe5                	j	70e <strlen+0x20>

0000000000000718 <memset>:

void*
memset(void *dst, int c, uint n)
{
 718:	1141                	addi	sp,sp,-16
 71a:	e422                	sd	s0,8(sp)
 71c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 71e:	ca19                	beqz	a2,734 <memset+0x1c>
 720:	87aa                	mv	a5,a0
 722:	1602                	slli	a2,a2,0x20
 724:	9201                	srli	a2,a2,0x20
 726:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 72a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 72e:	0785                	addi	a5,a5,1
 730:	fee79de3          	bne	a5,a4,72a <memset+0x12>
  }
  return dst;
}
 734:	6422                	ld	s0,8(sp)
 736:	0141                	addi	sp,sp,16
 738:	8082                	ret

000000000000073a <strchr>:

char*
strchr(const char *s, char c)
{
 73a:	1141                	addi	sp,sp,-16
 73c:	e422                	sd	s0,8(sp)
 73e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 740:	00054783          	lbu	a5,0(a0)
 744:	cb99                	beqz	a5,75a <strchr+0x20>
    if(*s == c)
 746:	00f58763          	beq	a1,a5,754 <strchr+0x1a>
  for(; *s; s++)
 74a:	0505                	addi	a0,a0,1
 74c:	00054783          	lbu	a5,0(a0)
 750:	fbfd                	bnez	a5,746 <strchr+0xc>
      return (char*)s;
  return 0;
 752:	4501                	li	a0,0
}
 754:	6422                	ld	s0,8(sp)
 756:	0141                	addi	sp,sp,16
 758:	8082                	ret
  return 0;
 75a:	4501                	li	a0,0
 75c:	bfe5                	j	754 <strchr+0x1a>

000000000000075e <gets>:

char*
gets(char *buf, int max)
{
 75e:	711d                	addi	sp,sp,-96
 760:	ec86                	sd	ra,88(sp)
 762:	e8a2                	sd	s0,80(sp)
 764:	e4a6                	sd	s1,72(sp)
 766:	e0ca                	sd	s2,64(sp)
 768:	fc4e                	sd	s3,56(sp)
 76a:	f852                	sd	s4,48(sp)
 76c:	f456                	sd	s5,40(sp)
 76e:	f05a                	sd	s6,32(sp)
 770:	ec5e                	sd	s7,24(sp)
 772:	1080                	addi	s0,sp,96
 774:	8baa                	mv	s7,a0
 776:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 778:	892a                	mv	s2,a0
 77a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 77c:	4aa9                	li	s5,10
 77e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 780:	89a6                	mv	s3,s1
 782:	2485                	addiw	s1,s1,1
 784:	0344d863          	bge	s1,s4,7b4 <gets+0x56>
    cc = read(0, &c, 1);
 788:	4605                	li	a2,1
 78a:	faf40593          	addi	a1,s0,-81
 78e:	4501                	li	a0,0
 790:	00000097          	auipc	ra,0x0
 794:	19a080e7          	jalr	410(ra) # 92a <read>
    if(cc < 1)
 798:	00a05e63          	blez	a0,7b4 <gets+0x56>
    buf[i++] = c;
 79c:	faf44783          	lbu	a5,-81(s0)
 7a0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7a4:	01578763          	beq	a5,s5,7b2 <gets+0x54>
 7a8:	0905                	addi	s2,s2,1
 7aa:	fd679be3          	bne	a5,s6,780 <gets+0x22>
    buf[i++] = c;
 7ae:	89a6                	mv	s3,s1
 7b0:	a011                	j	7b4 <gets+0x56>
 7b2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7b4:	99de                	add	s3,s3,s7
 7b6:	00098023          	sb	zero,0(s3)
  return buf;
}
 7ba:	855e                	mv	a0,s7
 7bc:	60e6                	ld	ra,88(sp)
 7be:	6446                	ld	s0,80(sp)
 7c0:	64a6                	ld	s1,72(sp)
 7c2:	6906                	ld	s2,64(sp)
 7c4:	79e2                	ld	s3,56(sp)
 7c6:	7a42                	ld	s4,48(sp)
 7c8:	7aa2                	ld	s5,40(sp)
 7ca:	7b02                	ld	s6,32(sp)
 7cc:	6be2                	ld	s7,24(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <stat>:

int
stat(const char *n, struct stat *st)
{
 7d2:	1101                	addi	sp,sp,-32
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	e04a                	sd	s2,0(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7de:	4581                	li	a1,0
 7e0:	00000097          	auipc	ra,0x0
 7e4:	172080e7          	jalr	370(ra) # 952 <open>
  if(fd < 0)
 7e8:	02054663          	bltz	a0,814 <stat+0x42>
 7ec:	e426                	sd	s1,8(sp)
 7ee:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7f0:	85ca                	mv	a1,s2
 7f2:	00000097          	auipc	ra,0x0
 7f6:	178080e7          	jalr	376(ra) # 96a <fstat>
 7fa:	892a                	mv	s2,a0
  close(fd);
 7fc:	8526                	mv	a0,s1
 7fe:	00000097          	auipc	ra,0x0
 802:	13c080e7          	jalr	316(ra) # 93a <close>
  return r;
 806:	64a2                	ld	s1,8(sp)
}
 808:	854a                	mv	a0,s2
 80a:	60e2                	ld	ra,24(sp)
 80c:	6442                	ld	s0,16(sp)
 80e:	6902                	ld	s2,0(sp)
 810:	6105                	addi	sp,sp,32
 812:	8082                	ret
    return -1;
 814:	597d                	li	s2,-1
 816:	bfcd                	j	808 <stat+0x36>

0000000000000818 <atoi>:

int
atoi(const char *s)
{
 818:	1141                	addi	sp,sp,-16
 81a:	e422                	sd	s0,8(sp)
 81c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 81e:	00054683          	lbu	a3,0(a0)
 822:	fd06879b          	addiw	a5,a3,-48
 826:	0ff7f793          	zext.b	a5,a5
 82a:	4625                	li	a2,9
 82c:	02f66863          	bltu	a2,a5,85c <atoi+0x44>
 830:	872a                	mv	a4,a0
  n = 0;
 832:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 834:	0705                	addi	a4,a4,1
 836:	0025179b          	slliw	a5,a0,0x2
 83a:	9fa9                	addw	a5,a5,a0
 83c:	0017979b          	slliw	a5,a5,0x1
 840:	9fb5                	addw	a5,a5,a3
 842:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 846:	00074683          	lbu	a3,0(a4)
 84a:	fd06879b          	addiw	a5,a3,-48
 84e:	0ff7f793          	zext.b	a5,a5
 852:	fef671e3          	bgeu	a2,a5,834 <atoi+0x1c>
  return n;
}
 856:	6422                	ld	s0,8(sp)
 858:	0141                	addi	sp,sp,16
 85a:	8082                	ret
  n = 0;
 85c:	4501                	li	a0,0
 85e:	bfe5                	j	856 <atoi+0x3e>

0000000000000860 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 860:	1141                	addi	sp,sp,-16
 862:	e422                	sd	s0,8(sp)
 864:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 866:	02b57463          	bgeu	a0,a1,88e <memmove+0x2e>
    while(n-- > 0)
 86a:	00c05f63          	blez	a2,888 <memmove+0x28>
 86e:	1602                	slli	a2,a2,0x20
 870:	9201                	srli	a2,a2,0x20
 872:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 876:	872a                	mv	a4,a0
      *dst++ = *src++;
 878:	0585                	addi	a1,a1,1
 87a:	0705                	addi	a4,a4,1
 87c:	fff5c683          	lbu	a3,-1(a1)
 880:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 884:	fef71ae3          	bne	a4,a5,878 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 888:	6422                	ld	s0,8(sp)
 88a:	0141                	addi	sp,sp,16
 88c:	8082                	ret
    dst += n;
 88e:	00c50733          	add	a4,a0,a2
    src += n;
 892:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 894:	fec05ae3          	blez	a2,888 <memmove+0x28>
 898:	fff6079b          	addiw	a5,a2,-1
 89c:	1782                	slli	a5,a5,0x20
 89e:	9381                	srli	a5,a5,0x20
 8a0:	fff7c793          	not	a5,a5
 8a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8a6:	15fd                	addi	a1,a1,-1
 8a8:	177d                	addi	a4,a4,-1
 8aa:	0005c683          	lbu	a3,0(a1)
 8ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8b2:	fee79ae3          	bne	a5,a4,8a6 <memmove+0x46>
 8b6:	bfc9                	j	888 <memmove+0x28>

00000000000008b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8b8:	1141                	addi	sp,sp,-16
 8ba:	e422                	sd	s0,8(sp)
 8bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8be:	ca05                	beqz	a2,8ee <memcmp+0x36>
 8c0:	fff6069b          	addiw	a3,a2,-1
 8c4:	1682                	slli	a3,a3,0x20
 8c6:	9281                	srli	a3,a3,0x20
 8c8:	0685                	addi	a3,a3,1
 8ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8cc:	00054783          	lbu	a5,0(a0)
 8d0:	0005c703          	lbu	a4,0(a1)
 8d4:	00e79863          	bne	a5,a4,8e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8d8:	0505                	addi	a0,a0,1
    p2++;
 8da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8dc:	fed518e3          	bne	a0,a3,8cc <memcmp+0x14>
  }
  return 0;
 8e0:	4501                	li	a0,0
 8e2:	a019                	j	8e8 <memcmp+0x30>
      return *p1 - *p2;
 8e4:	40e7853b          	subw	a0,a5,a4
}
 8e8:	6422                	ld	s0,8(sp)
 8ea:	0141                	addi	sp,sp,16
 8ec:	8082                	ret
  return 0;
 8ee:	4501                	li	a0,0
 8f0:	bfe5                	j	8e8 <memcmp+0x30>

00000000000008f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8f2:	1141                	addi	sp,sp,-16
 8f4:	e406                	sd	ra,8(sp)
 8f6:	e022                	sd	s0,0(sp)
 8f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 8fa:	00000097          	auipc	ra,0x0
 8fe:	f66080e7          	jalr	-154(ra) # 860 <memmove>
}
 902:	60a2                	ld	ra,8(sp)
 904:	6402                	ld	s0,0(sp)
 906:	0141                	addi	sp,sp,16
 908:	8082                	ret

000000000000090a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 90a:	4885                	li	a7,1
 ecall
 90c:	00000073          	ecall
 ret
 910:	8082                	ret

0000000000000912 <exit>:
.global exit
exit:
 li a7, SYS_exit
 912:	4889                	li	a7,2
 ecall
 914:	00000073          	ecall
 ret
 918:	8082                	ret

000000000000091a <wait>:
.global wait
wait:
 li a7, SYS_wait
 91a:	488d                	li	a7,3
 ecall
 91c:	00000073          	ecall
 ret
 920:	8082                	ret

0000000000000922 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 922:	4891                	li	a7,4
 ecall
 924:	00000073          	ecall
 ret
 928:	8082                	ret

000000000000092a <read>:
.global read
read:
 li a7, SYS_read
 92a:	4895                	li	a7,5
 ecall
 92c:	00000073          	ecall
 ret
 930:	8082                	ret

0000000000000932 <write>:
.global write
write:
 li a7, SYS_write
 932:	48c1                	li	a7,16
 ecall
 934:	00000073          	ecall
 ret
 938:	8082                	ret

000000000000093a <close>:
.global close
close:
 li a7, SYS_close
 93a:	48d5                	li	a7,21
 ecall
 93c:	00000073          	ecall
 ret
 940:	8082                	ret

0000000000000942 <kill>:
.global kill
kill:
 li a7, SYS_kill
 942:	4899                	li	a7,6
 ecall
 944:	00000073          	ecall
 ret
 948:	8082                	ret

000000000000094a <exec>:
.global exec
exec:
 li a7, SYS_exec
 94a:	489d                	li	a7,7
 ecall
 94c:	00000073          	ecall
 ret
 950:	8082                	ret

0000000000000952 <open>:
.global open
open:
 li a7, SYS_open
 952:	48bd                	li	a7,15
 ecall
 954:	00000073          	ecall
 ret
 958:	8082                	ret

000000000000095a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 95a:	48c5                	li	a7,17
 ecall
 95c:	00000073          	ecall
 ret
 960:	8082                	ret

0000000000000962 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 962:	48c9                	li	a7,18
 ecall
 964:	00000073          	ecall
 ret
 968:	8082                	ret

000000000000096a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 96a:	48a1                	li	a7,8
 ecall
 96c:	00000073          	ecall
 ret
 970:	8082                	ret

0000000000000972 <link>:
.global link
link:
 li a7, SYS_link
 972:	48cd                	li	a7,19
 ecall
 974:	00000073          	ecall
 ret
 978:	8082                	ret

000000000000097a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 97a:	48d1                	li	a7,20
 ecall
 97c:	00000073          	ecall
 ret
 980:	8082                	ret

0000000000000982 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 982:	48a5                	li	a7,9
 ecall
 984:	00000073          	ecall
 ret
 988:	8082                	ret

000000000000098a <dup>:
.global dup
dup:
 li a7, SYS_dup
 98a:	48a9                	li	a7,10
 ecall
 98c:	00000073          	ecall
 ret
 990:	8082                	ret

0000000000000992 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 992:	48ad                	li	a7,11
 ecall
 994:	00000073          	ecall
 ret
 998:	8082                	ret

000000000000099a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 99a:	48b1                	li	a7,12
 ecall
 99c:	00000073          	ecall
 ret
 9a0:	8082                	ret

00000000000009a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9a2:	48b5                	li	a7,13
 ecall
 9a4:	00000073          	ecall
 ret
 9a8:	8082                	ret

00000000000009aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9aa:	48b9                	li	a7,14
 ecall
 9ac:	00000073          	ecall
 ret
 9b0:	8082                	ret

00000000000009b2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 9b2:	48d9                	li	a7,22
 ecall
 9b4:	00000073          	ecall
 ret
 9b8:	8082                	ret

00000000000009ba <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 9ba:	48dd                	li	a7,23
 ecall
 9bc:	00000073          	ecall
 ret
 9c0:	8082                	ret

00000000000009c2 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 9c2:	48e1                	li	a7,24
 ecall
 9c4:	00000073          	ecall
 ret
 9c8:	8082                	ret

00000000000009ca <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 9ca:	48e9                	li	a7,26
 ecall
 9cc:	00000073          	ecall
 ret
 9d0:	8082                	ret

00000000000009d2 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 9d2:	48e5                	li	a7,25
 ecall
 9d4:	00000073          	ecall
 ret
 9d8:	8082                	ret

00000000000009da <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9da:	1101                	addi	sp,sp,-32
 9dc:	ec06                	sd	ra,24(sp)
 9de:	e822                	sd	s0,16(sp)
 9e0:	1000                	addi	s0,sp,32
 9e2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9e6:	4605                	li	a2,1
 9e8:	fef40593          	addi	a1,s0,-17
 9ec:	00000097          	auipc	ra,0x0
 9f0:	f46080e7          	jalr	-186(ra) # 932 <write>
}
 9f4:	60e2                	ld	ra,24(sp)
 9f6:	6442                	ld	s0,16(sp)
 9f8:	6105                	addi	sp,sp,32
 9fa:	8082                	ret

00000000000009fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9fc:	7139                	addi	sp,sp,-64
 9fe:	fc06                	sd	ra,56(sp)
 a00:	f822                	sd	s0,48(sp)
 a02:	f426                	sd	s1,40(sp)
 a04:	0080                	addi	s0,sp,64
 a06:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a08:	c299                	beqz	a3,a0e <printint+0x12>
 a0a:	0805cb63          	bltz	a1,aa0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a0e:	2581                	sext.w	a1,a1
  neg = 0;
 a10:	4881                	li	a7,0
 a12:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a16:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a18:	2601                	sext.w	a2,a2
 a1a:	00001517          	auipc	a0,0x1
 a1e:	82e50513          	addi	a0,a0,-2002 # 1248 <digits>
 a22:	883a                	mv	a6,a4
 a24:	2705                	addiw	a4,a4,1
 a26:	02c5f7bb          	remuw	a5,a1,a2
 a2a:	1782                	slli	a5,a5,0x20
 a2c:	9381                	srli	a5,a5,0x20
 a2e:	97aa                	add	a5,a5,a0
 a30:	0007c783          	lbu	a5,0(a5)
 a34:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a38:	0005879b          	sext.w	a5,a1
 a3c:	02c5d5bb          	divuw	a1,a1,a2
 a40:	0685                	addi	a3,a3,1
 a42:	fec7f0e3          	bgeu	a5,a2,a22 <printint+0x26>
  if(neg)
 a46:	00088c63          	beqz	a7,a5e <printint+0x62>
    buf[i++] = '-';
 a4a:	fd070793          	addi	a5,a4,-48
 a4e:	00878733          	add	a4,a5,s0
 a52:	02d00793          	li	a5,45
 a56:	fef70823          	sb	a5,-16(a4)
 a5a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a5e:	02e05c63          	blez	a4,a96 <printint+0x9a>
 a62:	f04a                	sd	s2,32(sp)
 a64:	ec4e                	sd	s3,24(sp)
 a66:	fc040793          	addi	a5,s0,-64
 a6a:	00e78933          	add	s2,a5,a4
 a6e:	fff78993          	addi	s3,a5,-1
 a72:	99ba                	add	s3,s3,a4
 a74:	377d                	addiw	a4,a4,-1
 a76:	1702                	slli	a4,a4,0x20
 a78:	9301                	srli	a4,a4,0x20
 a7a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a7e:	fff94583          	lbu	a1,-1(s2)
 a82:	8526                	mv	a0,s1
 a84:	00000097          	auipc	ra,0x0
 a88:	f56080e7          	jalr	-170(ra) # 9da <putc>
  while(--i >= 0)
 a8c:	197d                	addi	s2,s2,-1
 a8e:	ff3918e3          	bne	s2,s3,a7e <printint+0x82>
 a92:	7902                	ld	s2,32(sp)
 a94:	69e2                	ld	s3,24(sp)
}
 a96:	70e2                	ld	ra,56(sp)
 a98:	7442                	ld	s0,48(sp)
 a9a:	74a2                	ld	s1,40(sp)
 a9c:	6121                	addi	sp,sp,64
 a9e:	8082                	ret
    x = -xx;
 aa0:	40b005bb          	negw	a1,a1
    neg = 1;
 aa4:	4885                	li	a7,1
    x = -xx;
 aa6:	b7b5                	j	a12 <printint+0x16>

0000000000000aa8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 aa8:	715d                	addi	sp,sp,-80
 aaa:	e486                	sd	ra,72(sp)
 aac:	e0a2                	sd	s0,64(sp)
 aae:	f84a                	sd	s2,48(sp)
 ab0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 ab2:	0005c903          	lbu	s2,0(a1)
 ab6:	1a090a63          	beqz	s2,c6a <vprintf+0x1c2>
 aba:	fc26                	sd	s1,56(sp)
 abc:	f44e                	sd	s3,40(sp)
 abe:	f052                	sd	s4,32(sp)
 ac0:	ec56                	sd	s5,24(sp)
 ac2:	e85a                	sd	s6,16(sp)
 ac4:	e45e                	sd	s7,8(sp)
 ac6:	8aaa                	mv	s5,a0
 ac8:	8bb2                	mv	s7,a2
 aca:	00158493          	addi	s1,a1,1
  state = 0;
 ace:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 ad0:	02500a13          	li	s4,37
 ad4:	4b55                	li	s6,21
 ad6:	a839                	j	af4 <vprintf+0x4c>
        putc(fd, c);
 ad8:	85ca                	mv	a1,s2
 ada:	8556                	mv	a0,s5
 adc:	00000097          	auipc	ra,0x0
 ae0:	efe080e7          	jalr	-258(ra) # 9da <putc>
 ae4:	a019                	j	aea <vprintf+0x42>
    } else if(state == '%'){
 ae6:	01498d63          	beq	s3,s4,b00 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 aea:	0485                	addi	s1,s1,1
 aec:	fff4c903          	lbu	s2,-1(s1)
 af0:	16090763          	beqz	s2,c5e <vprintf+0x1b6>
    if(state == 0){
 af4:	fe0999e3          	bnez	s3,ae6 <vprintf+0x3e>
      if(c == '%'){
 af8:	ff4910e3          	bne	s2,s4,ad8 <vprintf+0x30>
        state = '%';
 afc:	89d2                	mv	s3,s4
 afe:	b7f5                	j	aea <vprintf+0x42>
      if(c == 'd'){
 b00:	13490463          	beq	s2,s4,c28 <vprintf+0x180>
 b04:	f9d9079b          	addiw	a5,s2,-99
 b08:	0ff7f793          	zext.b	a5,a5
 b0c:	12fb6763          	bltu	s6,a5,c3a <vprintf+0x192>
 b10:	f9d9079b          	addiw	a5,s2,-99
 b14:	0ff7f713          	zext.b	a4,a5
 b18:	12eb6163          	bltu	s6,a4,c3a <vprintf+0x192>
 b1c:	00271793          	slli	a5,a4,0x2
 b20:	00000717          	auipc	a4,0x0
 b24:	6d070713          	addi	a4,a4,1744 # 11f0 <malloc+0x496>
 b28:	97ba                	add	a5,a5,a4
 b2a:	439c                	lw	a5,0(a5)
 b2c:	97ba                	add	a5,a5,a4
 b2e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 b30:	008b8913          	addi	s2,s7,8
 b34:	4685                	li	a3,1
 b36:	4629                	li	a2,10
 b38:	000ba583          	lw	a1,0(s7)
 b3c:	8556                	mv	a0,s5
 b3e:	00000097          	auipc	ra,0x0
 b42:	ebe080e7          	jalr	-322(ra) # 9fc <printint>
 b46:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 b48:	4981                	li	s3,0
 b4a:	b745                	j	aea <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b4c:	008b8913          	addi	s2,s7,8
 b50:	4681                	li	a3,0
 b52:	4629                	li	a2,10
 b54:	000ba583          	lw	a1,0(s7)
 b58:	8556                	mv	a0,s5
 b5a:	00000097          	auipc	ra,0x0
 b5e:	ea2080e7          	jalr	-350(ra) # 9fc <printint>
 b62:	8bca                	mv	s7,s2
      state = 0;
 b64:	4981                	li	s3,0
 b66:	b751                	j	aea <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 b68:	008b8913          	addi	s2,s7,8
 b6c:	4681                	li	a3,0
 b6e:	4641                	li	a2,16
 b70:	000ba583          	lw	a1,0(s7)
 b74:	8556                	mv	a0,s5
 b76:	00000097          	auipc	ra,0x0
 b7a:	e86080e7          	jalr	-378(ra) # 9fc <printint>
 b7e:	8bca                	mv	s7,s2
      state = 0;
 b80:	4981                	li	s3,0
 b82:	b7a5                	j	aea <vprintf+0x42>
 b84:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 b86:	008b8c13          	addi	s8,s7,8
 b8a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 b8e:	03000593          	li	a1,48
 b92:	8556                	mv	a0,s5
 b94:	00000097          	auipc	ra,0x0
 b98:	e46080e7          	jalr	-442(ra) # 9da <putc>
  putc(fd, 'x');
 b9c:	07800593          	li	a1,120
 ba0:	8556                	mv	a0,s5
 ba2:	00000097          	auipc	ra,0x0
 ba6:	e38080e7          	jalr	-456(ra) # 9da <putc>
 baa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bac:	00000b97          	auipc	s7,0x0
 bb0:	69cb8b93          	addi	s7,s7,1692 # 1248 <digits>
 bb4:	03c9d793          	srli	a5,s3,0x3c
 bb8:	97de                	add	a5,a5,s7
 bba:	0007c583          	lbu	a1,0(a5)
 bbe:	8556                	mv	a0,s5
 bc0:	00000097          	auipc	ra,0x0
 bc4:	e1a080e7          	jalr	-486(ra) # 9da <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bc8:	0992                	slli	s3,s3,0x4
 bca:	397d                	addiw	s2,s2,-1
 bcc:	fe0914e3          	bnez	s2,bb4 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 bd0:	8be2                	mv	s7,s8
      state = 0;
 bd2:	4981                	li	s3,0
 bd4:	6c02                	ld	s8,0(sp)
 bd6:	bf11                	j	aea <vprintf+0x42>
        s = va_arg(ap, char*);
 bd8:	008b8993          	addi	s3,s7,8
 bdc:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 be0:	02090163          	beqz	s2,c02 <vprintf+0x15a>
        while(*s != 0){
 be4:	00094583          	lbu	a1,0(s2)
 be8:	c9a5                	beqz	a1,c58 <vprintf+0x1b0>
          putc(fd, *s);
 bea:	8556                	mv	a0,s5
 bec:	00000097          	auipc	ra,0x0
 bf0:	dee080e7          	jalr	-530(ra) # 9da <putc>
          s++;
 bf4:	0905                	addi	s2,s2,1
        while(*s != 0){
 bf6:	00094583          	lbu	a1,0(s2)
 bfa:	f9e5                	bnez	a1,bea <vprintf+0x142>
        s = va_arg(ap, char*);
 bfc:	8bce                	mv	s7,s3
      state = 0;
 bfe:	4981                	li	s3,0
 c00:	b5ed                	j	aea <vprintf+0x42>
          s = "(null)";
 c02:	00000917          	auipc	s2,0x0
 c06:	5e690913          	addi	s2,s2,1510 # 11e8 <malloc+0x48e>
        while(*s != 0){
 c0a:	02800593          	li	a1,40
 c0e:	bff1                	j	bea <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 c10:	008b8913          	addi	s2,s7,8
 c14:	000bc583          	lbu	a1,0(s7)
 c18:	8556                	mv	a0,s5
 c1a:	00000097          	auipc	ra,0x0
 c1e:	dc0080e7          	jalr	-576(ra) # 9da <putc>
 c22:	8bca                	mv	s7,s2
      state = 0;
 c24:	4981                	li	s3,0
 c26:	b5d1                	j	aea <vprintf+0x42>
        putc(fd, c);
 c28:	02500593          	li	a1,37
 c2c:	8556                	mv	a0,s5
 c2e:	00000097          	auipc	ra,0x0
 c32:	dac080e7          	jalr	-596(ra) # 9da <putc>
      state = 0;
 c36:	4981                	li	s3,0
 c38:	bd4d                	j	aea <vprintf+0x42>
        putc(fd, '%');
 c3a:	02500593          	li	a1,37
 c3e:	8556                	mv	a0,s5
 c40:	00000097          	auipc	ra,0x0
 c44:	d9a080e7          	jalr	-614(ra) # 9da <putc>
        putc(fd, c);
 c48:	85ca                	mv	a1,s2
 c4a:	8556                	mv	a0,s5
 c4c:	00000097          	auipc	ra,0x0
 c50:	d8e080e7          	jalr	-626(ra) # 9da <putc>
      state = 0;
 c54:	4981                	li	s3,0
 c56:	bd51                	j	aea <vprintf+0x42>
        s = va_arg(ap, char*);
 c58:	8bce                	mv	s7,s3
      state = 0;
 c5a:	4981                	li	s3,0
 c5c:	b579                	j	aea <vprintf+0x42>
 c5e:	74e2                	ld	s1,56(sp)
 c60:	79a2                	ld	s3,40(sp)
 c62:	7a02                	ld	s4,32(sp)
 c64:	6ae2                	ld	s5,24(sp)
 c66:	6b42                	ld	s6,16(sp)
 c68:	6ba2                	ld	s7,8(sp)
    }
  }
}
 c6a:	60a6                	ld	ra,72(sp)
 c6c:	6406                	ld	s0,64(sp)
 c6e:	7942                	ld	s2,48(sp)
 c70:	6161                	addi	sp,sp,80
 c72:	8082                	ret

0000000000000c74 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c74:	715d                	addi	sp,sp,-80
 c76:	ec06                	sd	ra,24(sp)
 c78:	e822                	sd	s0,16(sp)
 c7a:	1000                	addi	s0,sp,32
 c7c:	e010                	sd	a2,0(s0)
 c7e:	e414                	sd	a3,8(s0)
 c80:	e818                	sd	a4,16(s0)
 c82:	ec1c                	sd	a5,24(s0)
 c84:	03043023          	sd	a6,32(s0)
 c88:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c8c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c90:	8622                	mv	a2,s0
 c92:	00000097          	auipc	ra,0x0
 c96:	e16080e7          	jalr	-490(ra) # aa8 <vprintf>
}
 c9a:	60e2                	ld	ra,24(sp)
 c9c:	6442                	ld	s0,16(sp)
 c9e:	6161                	addi	sp,sp,80
 ca0:	8082                	ret

0000000000000ca2 <printf>:

void
printf(const char *fmt, ...)
{
 ca2:	711d                	addi	sp,sp,-96
 ca4:	ec06                	sd	ra,24(sp)
 ca6:	e822                	sd	s0,16(sp)
 ca8:	1000                	addi	s0,sp,32
 caa:	e40c                	sd	a1,8(s0)
 cac:	e810                	sd	a2,16(s0)
 cae:	ec14                	sd	a3,24(s0)
 cb0:	f018                	sd	a4,32(s0)
 cb2:	f41c                	sd	a5,40(s0)
 cb4:	03043823          	sd	a6,48(s0)
 cb8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cbc:	00840613          	addi	a2,s0,8
 cc0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cc4:	85aa                	mv	a1,a0
 cc6:	4505                	li	a0,1
 cc8:	00000097          	auipc	ra,0x0
 ccc:	de0080e7          	jalr	-544(ra) # aa8 <vprintf>
}
 cd0:	60e2                	ld	ra,24(sp)
 cd2:	6442                	ld	s0,16(sp)
 cd4:	6125                	addi	sp,sp,96
 cd6:	8082                	ret

0000000000000cd8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cd8:	1141                	addi	sp,sp,-16
 cda:	e422                	sd	s0,8(sp)
 cdc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cde:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce2:	00002797          	auipc	a5,0x2
 ce6:	8067b783          	ld	a5,-2042(a5) # 24e8 <freep>
 cea:	a02d                	j	d14 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cec:	4618                	lw	a4,8(a2)
 cee:	9f2d                	addw	a4,a4,a1
 cf0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cf4:	6398                	ld	a4,0(a5)
 cf6:	6310                	ld	a2,0(a4)
 cf8:	a83d                	j	d36 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cfa:	ff852703          	lw	a4,-8(a0)
 cfe:	9f31                	addw	a4,a4,a2
 d00:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 d02:	ff053683          	ld	a3,-16(a0)
 d06:	a091                	j	d4a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d08:	6398                	ld	a4,0(a5)
 d0a:	00e7e463          	bltu	a5,a4,d12 <free+0x3a>
 d0e:	00e6ea63          	bltu	a3,a4,d22 <free+0x4a>
{
 d12:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d14:	fed7fae3          	bgeu	a5,a3,d08 <free+0x30>
 d18:	6398                	ld	a4,0(a5)
 d1a:	00e6e463          	bltu	a3,a4,d22 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d1e:	fee7eae3          	bltu	a5,a4,d12 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d22:	ff852583          	lw	a1,-8(a0)
 d26:	6390                	ld	a2,0(a5)
 d28:	02059813          	slli	a6,a1,0x20
 d2c:	01c85713          	srli	a4,a6,0x1c
 d30:	9736                	add	a4,a4,a3
 d32:	fae60de3          	beq	a2,a4,cec <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d36:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d3a:	4790                	lw	a2,8(a5)
 d3c:	02061593          	slli	a1,a2,0x20
 d40:	01c5d713          	srli	a4,a1,0x1c
 d44:	973e                	add	a4,a4,a5
 d46:	fae68ae3          	beq	a3,a4,cfa <free+0x22>
    p->s.ptr = bp->s.ptr;
 d4a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d4c:	00001717          	auipc	a4,0x1
 d50:	78f73e23          	sd	a5,1948(a4) # 24e8 <freep>
}
 d54:	6422                	ld	s0,8(sp)
 d56:	0141                	addi	sp,sp,16
 d58:	8082                	ret

0000000000000d5a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d5a:	7139                	addi	sp,sp,-64
 d5c:	fc06                	sd	ra,56(sp)
 d5e:	f822                	sd	s0,48(sp)
 d60:	f426                	sd	s1,40(sp)
 d62:	ec4e                	sd	s3,24(sp)
 d64:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d66:	02051493          	slli	s1,a0,0x20
 d6a:	9081                	srli	s1,s1,0x20
 d6c:	04bd                	addi	s1,s1,15
 d6e:	8091                	srli	s1,s1,0x4
 d70:	0014899b          	addiw	s3,s1,1
 d74:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d76:	00001517          	auipc	a0,0x1
 d7a:	77253503          	ld	a0,1906(a0) # 24e8 <freep>
 d7e:	c915                	beqz	a0,db2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d80:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d82:	4798                	lw	a4,8(a5)
 d84:	08977e63          	bgeu	a4,s1,e20 <malloc+0xc6>
 d88:	f04a                	sd	s2,32(sp)
 d8a:	e852                	sd	s4,16(sp)
 d8c:	e456                	sd	s5,8(sp)
 d8e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 d90:	8a4e                	mv	s4,s3
 d92:	0009871b          	sext.w	a4,s3
 d96:	6685                	lui	a3,0x1
 d98:	00d77363          	bgeu	a4,a3,d9e <malloc+0x44>
 d9c:	6a05                	lui	s4,0x1
 d9e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 da2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 da6:	00001917          	auipc	s2,0x1
 daa:	74290913          	addi	s2,s2,1858 # 24e8 <freep>
  if(p == (char*)-1)
 dae:	5afd                	li	s5,-1
 db0:	a091                	j	df4 <malloc+0x9a>
 db2:	f04a                	sd	s2,32(sp)
 db4:	e852                	sd	s4,16(sp)
 db6:	e456                	sd	s5,8(sp)
 db8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 dba:	04001797          	auipc	a5,0x4001
 dbe:	73678793          	addi	a5,a5,1846 # 40024f0 <base>
 dc2:	00001717          	auipc	a4,0x1
 dc6:	72f73323          	sd	a5,1830(a4) # 24e8 <freep>
 dca:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dcc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dd0:	b7c1                	j	d90 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 dd2:	6398                	ld	a4,0(a5)
 dd4:	e118                	sd	a4,0(a0)
 dd6:	a08d                	j	e38 <malloc+0xde>
  hp->s.size = nu;
 dd8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ddc:	0541                	addi	a0,a0,16
 dde:	00000097          	auipc	ra,0x0
 de2:	efa080e7          	jalr	-262(ra) # cd8 <free>
  return freep;
 de6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 dea:	c13d                	beqz	a0,e50 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 dee:	4798                	lw	a4,8(a5)
 df0:	02977463          	bgeu	a4,s1,e18 <malloc+0xbe>
    if(p == freep)
 df4:	00093703          	ld	a4,0(s2)
 df8:	853e                	mv	a0,a5
 dfa:	fef719e3          	bne	a4,a5,dec <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 dfe:	8552                	mv	a0,s4
 e00:	00000097          	auipc	ra,0x0
 e04:	b9a080e7          	jalr	-1126(ra) # 99a <sbrk>
  if(p == (char*)-1)
 e08:	fd5518e3          	bne	a0,s5,dd8 <malloc+0x7e>
        return 0;
 e0c:	4501                	li	a0,0
 e0e:	7902                	ld	s2,32(sp)
 e10:	6a42                	ld	s4,16(sp)
 e12:	6aa2                	ld	s5,8(sp)
 e14:	6b02                	ld	s6,0(sp)
 e16:	a03d                	j	e44 <malloc+0xea>
 e18:	7902                	ld	s2,32(sp)
 e1a:	6a42                	ld	s4,16(sp)
 e1c:	6aa2                	ld	s5,8(sp)
 e1e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 e20:	fae489e3          	beq	s1,a4,dd2 <malloc+0x78>
        p->s.size -= nunits;
 e24:	4137073b          	subw	a4,a4,s3
 e28:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e2a:	02071693          	slli	a3,a4,0x20
 e2e:	01c6d713          	srli	a4,a3,0x1c
 e32:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e34:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e38:	00001717          	auipc	a4,0x1
 e3c:	6aa73823          	sd	a0,1712(a4) # 24e8 <freep>
      return (void*)(p + 1);
 e40:	01078513          	addi	a0,a5,16
  }
}
 e44:	70e2                	ld	ra,56(sp)
 e46:	7442                	ld	s0,48(sp)
 e48:	74a2                	ld	s1,40(sp)
 e4a:	69e2                	ld	s3,24(sp)
 e4c:	6121                	addi	sp,sp,64
 e4e:	8082                	ret
 e50:	7902                	ld	s2,32(sp)
 e52:	6a42                	ld	s4,16(sp)
 e54:	6aa2                	ld	s5,8(sp)
 e56:	6b02                	ld	s6,0(sp)
 e58:	b7f5                	j	e44 <malloc+0xea>
