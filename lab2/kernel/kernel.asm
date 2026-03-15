
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9f013103          	ld	sp,-1552(sp) # 800089f0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	a0070713          	addi	a4,a4,-1536 # 80008a50 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	12e78793          	addi	a5,a5,302 # 80006190 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc727>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	76c080e7          	jalr	1900(ra) # 80002896 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000186:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	a0650513          	addi	a0,a0,-1530 # 80010b90 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	9f648493          	addi	s1,s1,-1546 # 80010b90 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	a8690913          	addi	s2,s2,-1402 # 80010c28 <cons+0x98>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

        if (c == C('D'))
    800001aa:	4b91                	li	s7,4
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
            break;

        dst++;
        --n;

        if (c == '\n')
    800001ae:	4ca9                	li	s9,10
    while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
        while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
            if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	ac2080e7          	jalr	-1342(ra) # 80001c82 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	518080e7          	jalr	1304(ra) # 800026e0 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	262080e7          	jalr	610(ra) # 80002438 <sleep>
        while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
        if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
        cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	62e080e7          	jalr	1582(ra) # 80002840 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1
        if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	96a50513          	addi	a0,a0,-1686 # 80010b90 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	95450513          	addi	a0,a0,-1708 # 80010b90 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
                return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
            if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
                cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	9af72b23          	sw	a5,-1610(a4) # 80010c28 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
        uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	8c450513          	addi	a0,a0,-1852 # 80010b90 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

    switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	5fa080e7          	jalr	1530(ra) # 800028ec <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	89650513          	addi	a0,a0,-1898 # 80010b90 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
    switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	87270713          	addi	a4,a4,-1934 # 80010b90 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
            consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	84878793          	addi	a5,a5,-1976 # 80010b90 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8b27a783          	lw	a5,-1870(a5) # 80010c28 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	80670713          	addi	a4,a4,-2042 # 80010b90 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	7f648493          	addi	s1,s1,2038 # 80010b90 <cons>
        while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
            cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
        while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	7ba70713          	addi	a4,a4,1978 # 80010b90 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	84f72223          	sw	a5,-1980(a4) # 80010c30 <cons+0xa0>
            consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
            consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	77e78793          	addi	a5,a5,1918 # 80010b90 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	7ec7ab23          	sw	a2,2038(a5) # 80010c2c <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	7ea50513          	addi	a0,a0,2026 # 80010c28 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	056080e7          	jalr	86(ra) # 8000249c <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	73050513          	addi	a0,a0,1840 # 80010b90 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	ac878793          	addi	a5,a5,-1336 # 80020f40 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	7007a223          	sw	zero,1796(a5) # 80010c50 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	48f72823          	sw	a5,1168(a4) # 80008a10 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	694dad83          	lw	s11,1684(s11) # 80010c50 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	63e50513          	addi	a0,a0,1598 # 80010c38 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	4e050513          	addi	a0,a0,1248 # 80010c38 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	4c448493          	addi	s1,s1,1220 # 80010c38 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	48450513          	addi	a0,a0,1156 # 80010c58 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	2107a783          	lw	a5,528(a5) # 80008a10 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	1e07b783          	ld	a5,480(a5) # 80008a18 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	1e073703          	ld	a4,480(a4) # 80008a20 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	3f6a0a13          	addi	s4,s4,1014 # 80010c58 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	1ae48493          	addi	s1,s1,430 # 80008a18 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	1ae98993          	addi	s3,s3,430 # 80008a20 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	c08080e7          	jalr	-1016(ra) # 8000249c <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	38850513          	addi	a0,a0,904 # 80010c58 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	1307a783          	lw	a5,304(a5) # 80008a10 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	13673703          	ld	a4,310(a4) # 80008a20 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1267b783          	ld	a5,294(a5) # 80008a18 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	35a98993          	addi	s3,s3,858 # 80010c58 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	11248493          	addi	s1,s1,274 # 80008a18 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	11290913          	addi	s2,s2,274 # 80008a20 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	b1a080e7          	jalr	-1254(ra) # 80002438 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	32448493          	addi	s1,s1,804 # 80010c58 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	0ce7bc23          	sd	a4,216(a5) # 80008a20 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	29e48493          	addi	s1,s1,670 # 80010c58 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	6dc78793          	addi	a5,a5,1756 # 800220d8 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	27490913          	addi	s2,s2,628 # 80010c90 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	1d650513          	addi	a0,a0,470 # 80010c90 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	60a50513          	addi	a0,a0,1546 # 800220d8 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	1a048493          	addi	s1,s1,416 # 80010c90 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	18850513          	addi	a0,a0,392 # 80010c90 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	15c50513          	addi	a0,a0,348 # 80010c90 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	0f6080e7          	jalr	246(ra) # 80001c66 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	0c4080e7          	jalr	196(ra) # 80001c66 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	0b8080e7          	jalr	184(ra) # 80001c66 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	0a0080e7          	jalr	160(ra) # 80001c66 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	060080e7          	jalr	96(ra) # 80001c66 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	034080e7          	jalr	52(ra) # 80001c66 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcf29>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	dd6080e7          	jalr	-554(ra) # 80001c56 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	ba070713          	addi	a4,a4,-1120 # 80008a28 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	dba080e7          	jalr	-582(ra) # 80001c56 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	cb6080e7          	jalr	-842(ra) # 80002b74 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	30a080e7          	jalr	778(ra) # 800061d0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	448080e7          	jalr	1096(ra) # 80002316 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	c2e080e7          	jalr	-978(ra) # 80001b5c <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	c16080e7          	jalr	-1002(ra) # 80002b4c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	c36080e7          	jalr	-970(ra) # 80002b74 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	274080e7          	jalr	628(ra) # 800061ba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	282080e7          	jalr	642(ra) # 800061d0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	416080e7          	jalr	1046(ra) # 8000336c <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	ab6080e7          	jalr	-1354(ra) # 80003a14 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a5c080e7          	jalr	-1444(ra) # 800049c2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	36a080e7          	jalr	874(ra) # 800062d8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	fec080e7          	jalr	-20(ra) # 80001f62 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	aaf72223          	sw	a5,-1372(a4) # 80008a28 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	a987b783          	ld	a5,-1384(a5) # 80008a30 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcf1f>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00001097          	auipc	ra,0x1
    80001232:	898080e7          	jalr	-1896(ra) # 80001ac6 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	7ca7be23          	sd	a0,2012(a5) # 80008a30 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcf28>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <mlfq_scheduler>:
}



void mlfq_scheduler(void)
{
    80001836:	7119                	addi	sp,sp,-128
    80001838:	fc86                	sd	ra,120(sp)
    8000183a:	f8a2                	sd	s0,112(sp)
    8000183c:	f4a6                	sd	s1,104(sp)
    8000183e:	f0ca                	sd	s2,96(sp)
    80001840:	ecce                	sd	s3,88(sp)
    80001842:	e8d2                	sd	s4,80(sp)
    80001844:	e4d6                	sd	s5,72(sp)
    80001846:	e0da                	sd	s6,64(sp)
    80001848:	fc5e                	sd	s7,56(sp)
    8000184a:	f862                	sd	s8,48(sp)
    8000184c:	f466                	sd	s9,40(sp)
    8000184e:	f06a                	sd	s10,32(sp)
    80001850:	ec6e                	sd	s11,24(sp)
    80001852:	0100                	addi	s0,sp,128
  asm volatile("mv %0, tp" : "=r" (x) );
    80001854:	8492                	mv	s1,tp
    int id = r_tp();
    80001856:	2481                	sext.w	s1,s1
    struct proc *p;
    struct cpu *c = mycpu();
    c->proc = 0;
    80001858:	0000fc17          	auipc	s8,0xf
    8000185c:	458c0c13          	addi	s8,s8,1112 # 80010cb0 <cpus>
    80001860:	00749913          	slli	s2,s1,0x7
    80001864:	012c07b3          	add	a5,s8,s2
    80001868:	0007b023          	sd	zero,0(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000186c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001870:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001874:	10079073          	csrw	sstatus,a5
    intr_on();

    acquire(&tickslock);
    80001878:	00015517          	auipc	a0,0x15
    8000187c:	48050513          	addi	a0,a0,1152 # 80016cf8 <tickslock>
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	356080e7          	jalr	854(ra) # 80000bd6 <acquire>
    int startTime = ticks;
    80001888:	00007797          	auipc	a5,0x7
    8000188c:	1b87a783          	lw	a5,440(a5) # 80008a40 <ticks>
    80001890:	f8f43423          	sd	a5,-120(s0)
    release(&tickslock);
    80001894:	00015517          	auipc	a0,0x15
    80001898:	46450513          	addi	a0,a0,1124 # 80016cf8 <tickslock>
    8000189c:	fffff097          	auipc	ra,0xfffff
    800018a0:	3ee080e7          	jalr	1006(ra) # 80000c8a <release>
		// before jumping back to us.
		p->state = RUNNING;
		c->proc = p;

		// Run process
		swtch(&c->context, &p->context);
    800018a4:	0921                	addi	s2,s2,8 # 1008 <_entry-0x7fffeff8>
    800018a6:	9c4a                	add	s8,s8,s2
    int current_prior = 0;
    800018a8:	4a81                	li	s5,0
	for (p = proc; p < &proc[NPROC]; p++)
    800018aa:	00015a17          	auipc	s4,0x15
    800018ae:	44ea0a13          	addi	s4,s4,1102 # 80016cf8 <tickslock>
		c->proc = p;
    800018b2:	049e                	slli	s1,s1,0x7
    800018b4:	0000fb17          	auipc	s6,0xf
    800018b8:	3fcb0b13          	addi	s6,s6,1020 # 80010cb0 <cpus>
    800018bc:	9b26                	add	s6,s6,s1

		if (p->qleft == 0) {
		    p->priority++;
		    p->qleft = quantum[p->priority];
    800018be:	00007d97          	auipc	s11,0x7
    800018c2:	ae2d8d93          	addi	s11,s11,-1310 # 800083a0 <quantum>
    800018c6:	a8b5                	j	80001942 <mlfq_scheduler+0x10c>

		// Process is done running for now.
		// It should have changed its p->state before coming back.
		c->proc = 0;
	    }
	    release(&p->lock);
    800018c8:	8526                	mv	a0,s1
    800018ca:	fffff097          	auipc	ra,0xfffff
    800018ce:	3c0080e7          	jalr	960(ra) # 80000c8a <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800018d2:	17048493          	addi	s1,s1,368
    800018d6:	07448063          	beq	s1,s4,80001936 <mlfq_scheduler+0x100>
	    acquire(&p->lock);
    800018da:	8526                	mv	a0,s1
    800018dc:	fffff097          	auipc	ra,0xfffff
    800018e0:	2fa080e7          	jalr	762(ra) # 80000bd6 <acquire>
	    if (p->state == RUNNABLE && p->priority == current_prior)
    800018e4:	4c9c                	lw	a5,24(s1)
    800018e6:	ff3791e3          	bne	a5,s3,800018c8 <mlfq_scheduler+0x92>
    800018ea:	58dc                	lw	a5,52(s1)
    800018ec:	fd579ee3          	bne	a5,s5,800018c8 <mlfq_scheduler+0x92>
		p->state = RUNNING;
    800018f0:	0194ac23          	sw	s9,24(s1)
		c->proc = p;
    800018f4:	009b3023          	sd	s1,0(s6)
		swtch(&c->context, &p->context);
    800018f8:	06848593          	addi	a1,s1,104
    800018fc:	8562                	mv	a0,s8
    800018fe:	00001097          	auipc	ra,0x1
    80001902:	1e4080e7          	jalr	484(ra) # 80002ae2 <swtch>
		if (p->qleft == 0) {
    80001906:	5c9c                	lw	a5,56(s1)
    80001908:	eb91                	bnez	a5,8000191c <mlfq_scheduler+0xe6>
		    p->priority++;
    8000190a:	58d8                	lw	a4,52(s1)
    8000190c:	2705                	addiw	a4,a4,1
    8000190e:	0007079b          	sext.w	a5,a4
    80001912:	d8d8                	sw	a4,52(s1)
		    p->qleft = quantum[p->priority];
    80001914:	078a                	slli	a5,a5,0x2
    80001916:	97ee                	add	a5,a5,s11
    80001918:	439c                	lw	a5,0(a5)
    8000191a:	dc9c                	sw	a5,56(s1)
		c->proc = 0;
    8000191c:	000b3023          	sd	zero,0(s6)
	    release(&p->lock);
    80001920:	8526                	mv	a0,s1
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	368080e7          	jalr	872(ra) # 80000c8a <release>
	for (p = proc; p < &proc[NPROC]; p++)
    8000192a:	17048493          	addi	s1,s1,368
    8000192e:	03448363          	beq	s1,s4,80001954 <mlfq_scheduler+0x11e>
		ran_proc = 1;
    80001932:	8bea                	mv	s7,s10
    80001934:	b75d                	j	800018da <mlfq_scheduler+0xa4>
	}
	current_prior++;
    80001936:	2a85                	addiw	s5,s5,1 # fffffffffffff001 <end+0xffffffff7ffdcf29>
    while (!ran_proc && current_prior < PRIORNUM) {
    80001938:	000b9e63          	bnez	s7,80001954 <mlfq_scheduler+0x11e>
    8000193c:	4791                	li	a5,4
    8000193e:	00fa8b63          	beq	s5,a5,80001954 <mlfq_scheduler+0x11e>
		ran_proc = 1;
    80001942:	4b81                	li	s7,0
	for (p = proc; p < &proc[NPROC]; p++)
    80001944:	0000f497          	auipc	s1,0xf
    80001948:	7b448493          	addi	s1,s1,1972 # 800110f8 <proc>
	    if (p->state == RUNNABLE && p->priority == current_prior)
    8000194c:	498d                	li	s3,3
		p->state = RUNNING;
    8000194e:	4c91                	li	s9,4
		ran_proc = 1;
    80001950:	4d05                	li	s10,1
    80001952:	b761                	j	800018da <mlfq_scheduler+0xa4>
    }
    acquire(&tickslock);
    80001954:	00015517          	auipc	a0,0x15
    80001958:	3a450513          	addi	a0,a0,932 # 80016cf8 <tickslock>
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	27a080e7          	jalr	634(ra) # 80000bd6 <acquire>
    int timeUsed = ticks - startTime;
    80001964:	00007497          	auipc	s1,0x7
    80001968:	0dc4a483          	lw	s1,220(s1) # 80008a40 <ticks>
    release(&tickslock);
    8000196c:	00015517          	auipc	a0,0x15
    80001970:	38c50513          	addi	a0,a0,908 # 80016cf8 <tickslock>
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	316080e7          	jalr	790(ra) # 80000c8a <release>

    acquire(&boostlock);
    8000197c:	0000f517          	auipc	a0,0xf
    80001980:	73450513          	addi	a0,a0,1844 # 800110b0 <boostlock>
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	252080e7          	jalr	594(ra) # 80000bd6 <acquire>
    boostleft -= timeUsed;
    8000198c:	00007717          	auipc	a4,0x7
    80001990:	fd470713          	addi	a4,a4,-44 # 80008960 <boostleft>
    80001994:	431c                	lw	a5,0(a4)
    80001996:	f8843683          	ld	a3,-120(s0)
    8000199a:	9fb5                	addw	a5,a5,a3
    8000199c:	9f85                	subw	a5,a5,s1
    8000199e:	0007869b          	sext.w	a3,a5
    800019a2:	c31c                	sw	a5,0(a4)
    if (boostleft <= 0) {
    800019a4:	e2b1                	bnez	a3,800019e8 <mlfq_scheduler+0x1b2>
	for (p = proc; p < &proc[NPROC]; p++)
    800019a6:	0000f497          	auipc	s1,0xf
    800019aa:	75248493          	addi	s1,s1,1874 # 800110f8 <proc>
	{
	    acquire(&p->lock);
	    p->priority = 0;
	    p->qleft = quantum[0];
    800019ae:	4989                	li	s3,2
	for (p = proc; p < &proc[NPROC]; p++)
    800019b0:	00015917          	auipc	s2,0x15
    800019b4:	34890913          	addi	s2,s2,840 # 80016cf8 <tickslock>
	    acquire(&p->lock);
    800019b8:	8526                	mv	a0,s1
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	21c080e7          	jalr	540(ra) # 80000bd6 <acquire>
	    p->priority = 0;
    800019c2:	0204aa23          	sw	zero,52(s1)
	    p->qleft = quantum[0];
    800019c6:	0334ac23          	sw	s3,56(s1)
	    release(&p->lock);
    800019ca:	8526                	mv	a0,s1
    800019cc:	fffff097          	auipc	ra,0xfffff
    800019d0:	2be080e7          	jalr	702(ra) # 80000c8a <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800019d4:	17048493          	addi	s1,s1,368
    800019d8:	ff2490e3          	bne	s1,s2,800019b8 <mlfq_scheduler+0x182>
	}
	boostleft = RESETTIME;
    800019dc:	0c800793          	li	a5,200
    800019e0:	00007717          	auipc	a4,0x7
    800019e4:	f8f72023          	sw	a5,-128(a4) # 80008960 <boostleft>
    }
    release(&boostlock);
    800019e8:	0000f517          	auipc	a0,0xf
    800019ec:	6c850513          	addi	a0,a0,1736 # 800110b0 <boostlock>
    800019f0:	fffff097          	auipc	ra,0xfffff
    800019f4:	29a080e7          	jalr	666(ra) # 80000c8a <release>
}
    800019f8:	70e6                	ld	ra,120(sp)
    800019fa:	7446                	ld	s0,112(sp)
    800019fc:	74a6                	ld	s1,104(sp)
    800019fe:	7906                	ld	s2,96(sp)
    80001a00:	69e6                	ld	s3,88(sp)
    80001a02:	6a46                	ld	s4,80(sp)
    80001a04:	6aa6                	ld	s5,72(sp)
    80001a06:	6b06                	ld	s6,64(sp)
    80001a08:	7be2                	ld	s7,56(sp)
    80001a0a:	7c42                	ld	s8,48(sp)
    80001a0c:	7ca2                	ld	s9,40(sp)
    80001a0e:	7d02                	ld	s10,32(sp)
    80001a10:	6de2                	ld	s11,24(sp)
    80001a12:	6109                	addi	sp,sp,128
    80001a14:	8082                	ret

0000000080001a16 <rr_scheduler>:

void rr_scheduler(void)
{
    80001a16:	7139                	addi	sp,sp,-64
    80001a18:	fc06                	sd	ra,56(sp)
    80001a1a:	f822                	sd	s0,48(sp)
    80001a1c:	f426                	sd	s1,40(sp)
    80001a1e:	f04a                	sd	s2,32(sp)
    80001a20:	ec4e                	sd	s3,24(sp)
    80001a22:	e852                	sd	s4,16(sp)
    80001a24:	e456                	sd	s5,8(sp)
    80001a26:	e05a                	sd	s6,0(sp)
    80001a28:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a2a:	8792                	mv	a5,tp
    int id = r_tp();
    80001a2c:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001a2e:	0000fa97          	auipc	s5,0xf
    80001a32:	282a8a93          	addi	s5,s5,642 # 80010cb0 <cpus>
    80001a36:	00779713          	slli	a4,a5,0x7
    80001a3a:	00ea86b3          	add	a3,s5,a4
    80001a3e:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdcf28>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a42:	100026f3          	csrr	a3,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a46:	0026e693          	ori	a3,a3,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a4a:	10069073          	csrw	sstatus,a3
            // Switch to chosen process.  It is the process's job
            // to release its lock and then reacquire it
            // before jumping back to us.
            p->state = RUNNING;
            c->proc = p;
            swtch(&c->context, &p->context);
    80001a4e:	0721                	addi	a4,a4,8
    80001a50:	9aba                	add	s5,s5,a4
    for (p = proc; p < &proc[NPROC]; p++)
    80001a52:	0000f497          	auipc	s1,0xf
    80001a56:	6a648493          	addi	s1,s1,1702 # 800110f8 <proc>
        if (p->state == RUNNABLE)
    80001a5a:	498d                	li	s3,3
            p->state = RUNNING;
    80001a5c:	4b11                	li	s6,4
            c->proc = p;
    80001a5e:	079e                	slli	a5,a5,0x7
    80001a60:	0000fa17          	auipc	s4,0xf
    80001a64:	250a0a13          	addi	s4,s4,592 # 80010cb0 <cpus>
    80001a68:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001a6a:	00015917          	auipc	s2,0x15
    80001a6e:	28e90913          	addi	s2,s2,654 # 80016cf8 <tickslock>
    80001a72:	a811                	j	80001a86 <rr_scheduler+0x70>

            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c->proc = 0;
        }
        release(&p->lock);
    80001a74:	8526                	mv	a0,s1
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	214080e7          	jalr	532(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001a7e:	17048493          	addi	s1,s1,368
    80001a82:	03248863          	beq	s1,s2,80001ab2 <rr_scheduler+0x9c>
        acquire(&p->lock);
    80001a86:	8526                	mv	a0,s1
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	14e080e7          	jalr	334(ra) # 80000bd6 <acquire>
        if (p->state == RUNNABLE)
    80001a90:	4c9c                	lw	a5,24(s1)
    80001a92:	ff3791e3          	bne	a5,s3,80001a74 <rr_scheduler+0x5e>
            p->state = RUNNING;
    80001a96:	0164ac23          	sw	s6,24(s1)
            c->proc = p;
    80001a9a:	009a3023          	sd	s1,0(s4)
            swtch(&c->context, &p->context);
    80001a9e:	06848593          	addi	a1,s1,104
    80001aa2:	8556                	mv	a0,s5
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	03e080e7          	jalr	62(ra) # 80002ae2 <swtch>
            c->proc = 0;
    80001aac:	000a3023          	sd	zero,0(s4)
    80001ab0:	b7d1                	j	80001a74 <rr_scheduler+0x5e>
    }
    // In case a setsched happened, we will switch to the new scheduler after one
    // Round Robin round has completed.
}
    80001ab2:	70e2                	ld	ra,56(sp)
    80001ab4:	7442                	ld	s0,48(sp)
    80001ab6:	74a2                	ld	s1,40(sp)
    80001ab8:	7902                	ld	s2,32(sp)
    80001aba:	69e2                	ld	s3,24(sp)
    80001abc:	6a42                	ld	s4,16(sp)
    80001abe:	6aa2                	ld	s5,8(sp)
    80001ac0:	6b02                	ld	s6,0(sp)
    80001ac2:	6121                	addi	sp,sp,64
    80001ac4:	8082                	ret

0000000080001ac6 <proc_mapstacks>:
{
    80001ac6:	7139                	addi	sp,sp,-64
    80001ac8:	fc06                	sd	ra,56(sp)
    80001aca:	f822                	sd	s0,48(sp)
    80001acc:	f426                	sd	s1,40(sp)
    80001ace:	f04a                	sd	s2,32(sp)
    80001ad0:	ec4e                	sd	s3,24(sp)
    80001ad2:	e852                	sd	s4,16(sp)
    80001ad4:	e456                	sd	s5,8(sp)
    80001ad6:	e05a                	sd	s6,0(sp)
    80001ad8:	0080                	addi	s0,sp,64
    80001ada:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001adc:	0000f497          	auipc	s1,0xf
    80001ae0:	61c48493          	addi	s1,s1,1564 # 800110f8 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001ae4:	8b26                	mv	s6,s1
    80001ae6:	00006a97          	auipc	s5,0x6
    80001aea:	51aa8a93          	addi	s5,s5,1306 # 80008000 <etext>
    80001aee:	04000937          	lui	s2,0x4000
    80001af2:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001af4:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001af6:	00015a17          	auipc	s4,0x15
    80001afa:	202a0a13          	addi	s4,s4,514 # 80016cf8 <tickslock>
        char *pa = kalloc();
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	fe8080e7          	jalr	-24(ra) # 80000ae6 <kalloc>
    80001b06:	862a                	mv	a2,a0
        if (pa == 0)
    80001b08:	c131                	beqz	a0,80001b4c <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001b0a:	416485b3          	sub	a1,s1,s6
    80001b0e:	8591                	srai	a1,a1,0x4
    80001b10:	000ab783          	ld	a5,0(s5)
    80001b14:	02f585b3          	mul	a1,a1,a5
    80001b18:	2585                	addiw	a1,a1,1
    80001b1a:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b1e:	4719                	li	a4,6
    80001b20:	6685                	lui	a3,0x1
    80001b22:	40b905b3          	sub	a1,s2,a1
    80001b26:	854e                	mv	a0,s3
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	616080e7          	jalr	1558(ra) # 8000113e <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b30:	17048493          	addi	s1,s1,368
    80001b34:	fd4495e3          	bne	s1,s4,80001afe <proc_mapstacks+0x38>
}
    80001b38:	70e2                	ld	ra,56(sp)
    80001b3a:	7442                	ld	s0,48(sp)
    80001b3c:	74a2                	ld	s1,40(sp)
    80001b3e:	7902                	ld	s2,32(sp)
    80001b40:	69e2                	ld	s3,24(sp)
    80001b42:	6a42                	ld	s4,16(sp)
    80001b44:	6aa2                	ld	s5,8(sp)
    80001b46:	6b02                	ld	s6,0(sp)
    80001b48:	6121                	addi	sp,sp,64
    80001b4a:	8082                	ret
            panic("kalloc");
    80001b4c:	00006517          	auipc	a0,0x6
    80001b50:	68c50513          	addi	a0,a0,1676 # 800081d8 <digits+0x198>
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	9ec080e7          	jalr	-1556(ra) # 80000540 <panic>

0000000080001b5c <procinit>:
{
    80001b5c:	7139                	addi	sp,sp,-64
    80001b5e:	fc06                	sd	ra,56(sp)
    80001b60:	f822                	sd	s0,48(sp)
    80001b62:	f426                	sd	s1,40(sp)
    80001b64:	f04a                	sd	s2,32(sp)
    80001b66:	ec4e                	sd	s3,24(sp)
    80001b68:	e852                	sd	s4,16(sp)
    80001b6a:	e456                	sd	s5,8(sp)
    80001b6c:	e05a                	sd	s6,0(sp)
    80001b6e:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001b70:	00006597          	auipc	a1,0x6
    80001b74:	67058593          	addi	a1,a1,1648 # 800081e0 <digits+0x1a0>
    80001b78:	0000f517          	auipc	a0,0xf
    80001b7c:	55050513          	addi	a0,a0,1360 # 800110c8 <pid_lock>
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	fc6080e7          	jalr	-58(ra) # 80000b46 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b88:	00006597          	auipc	a1,0x6
    80001b8c:	66058593          	addi	a1,a1,1632 # 800081e8 <digits+0x1a8>
    80001b90:	0000f517          	auipc	a0,0xf
    80001b94:	55050513          	addi	a0,a0,1360 # 800110e0 <wait_lock>
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	fae080e7          	jalr	-82(ra) # 80000b46 <initlock>
    initlock(&boostlock, "boost");
    80001ba0:	00006597          	auipc	a1,0x6
    80001ba4:	65858593          	addi	a1,a1,1624 # 800081f8 <digits+0x1b8>
    80001ba8:	0000f517          	auipc	a0,0xf
    80001bac:	50850513          	addi	a0,a0,1288 # 800110b0 <boostlock>
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	f96080e7          	jalr	-106(ra) # 80000b46 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001bb8:	0000f497          	auipc	s1,0xf
    80001bbc:	54048493          	addi	s1,s1,1344 # 800110f8 <proc>
        initlock(&p->lock, "proc");
    80001bc0:	00006b17          	auipc	s6,0x6
    80001bc4:	640b0b13          	addi	s6,s6,1600 # 80008200 <digits+0x1c0>
        p->kstack = KSTACK((int)(p - proc));
    80001bc8:	8aa6                	mv	s5,s1
    80001bca:	00006a17          	auipc	s4,0x6
    80001bce:	436a0a13          	addi	s4,s4,1078 # 80008000 <etext>
    80001bd2:	04000937          	lui	s2,0x4000
    80001bd6:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001bd8:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001bda:	00015997          	auipc	s3,0x15
    80001bde:	11e98993          	addi	s3,s3,286 # 80016cf8 <tickslock>
        initlock(&p->lock, "proc");
    80001be2:	85da                	mv	a1,s6
    80001be4:	8526                	mv	a0,s1
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	f60080e7          	jalr	-160(ra) # 80000b46 <initlock>
        p->state = UNUSED;
    80001bee:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001bf2:	415487b3          	sub	a5,s1,s5
    80001bf6:	8791                	srai	a5,a5,0x4
    80001bf8:	000a3703          	ld	a4,0(s4)
    80001bfc:	02e787b3          	mul	a5,a5,a4
    80001c00:	2785                	addiw	a5,a5,1
    80001c02:	00d7979b          	slliw	a5,a5,0xd
    80001c06:	40f907b3          	sub	a5,s2,a5
    80001c0a:	e4bc                	sd	a5,72(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001c0c:	17048493          	addi	s1,s1,368
    80001c10:	fd3499e3          	bne	s1,s3,80001be2 <procinit+0x86>
}
    80001c14:	70e2                	ld	ra,56(sp)
    80001c16:	7442                	ld	s0,48(sp)
    80001c18:	74a2                	ld	s1,40(sp)
    80001c1a:	7902                	ld	s2,32(sp)
    80001c1c:	69e2                	ld	s3,24(sp)
    80001c1e:	6a42                	ld	s4,16(sp)
    80001c20:	6aa2                	ld	s5,8(sp)
    80001c22:	6b02                	ld	s6,0(sp)
    80001c24:	6121                	addi	sp,sp,64
    80001c26:	8082                	ret

0000000080001c28 <copy_array>:
{
    80001c28:	1141                	addi	sp,sp,-16
    80001c2a:	e422                	sd	s0,8(sp)
    80001c2c:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001c2e:	02c05163          	blez	a2,80001c50 <copy_array+0x28>
    80001c32:	87aa                	mv	a5,a0
    80001c34:	0505                	addi	a0,a0,1
    80001c36:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001c38:	1602                	slli	a2,a2,0x20
    80001c3a:	9201                	srli	a2,a2,0x20
    80001c3c:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001c40:	0007c703          	lbu	a4,0(a5)
    80001c44:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001c48:	0785                	addi	a5,a5,1
    80001c4a:	0585                	addi	a1,a1,1
    80001c4c:	fed79ae3          	bne	a5,a3,80001c40 <copy_array+0x18>
}
    80001c50:	6422                	ld	s0,8(sp)
    80001c52:	0141                	addi	sp,sp,16
    80001c54:	8082                	ret

0000000080001c56 <cpuid>:
{
    80001c56:	1141                	addi	sp,sp,-16
    80001c58:	e422                	sd	s0,8(sp)
    80001c5a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c5c:	8512                	mv	a0,tp
}
    80001c5e:	2501                	sext.w	a0,a0
    80001c60:	6422                	ld	s0,8(sp)
    80001c62:	0141                	addi	sp,sp,16
    80001c64:	8082                	ret

0000000080001c66 <mycpu>:
{
    80001c66:	1141                	addi	sp,sp,-16
    80001c68:	e422                	sd	s0,8(sp)
    80001c6a:	0800                	addi	s0,sp,16
    80001c6c:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001c6e:	2781                	sext.w	a5,a5
    80001c70:	079e                	slli	a5,a5,0x7
}
    80001c72:	0000f517          	auipc	a0,0xf
    80001c76:	03e50513          	addi	a0,a0,62 # 80010cb0 <cpus>
    80001c7a:	953e                	add	a0,a0,a5
    80001c7c:	6422                	ld	s0,8(sp)
    80001c7e:	0141                	addi	sp,sp,16
    80001c80:	8082                	ret

0000000080001c82 <myproc>:
{
    80001c82:	1101                	addi	sp,sp,-32
    80001c84:	ec06                	sd	ra,24(sp)
    80001c86:	e822                	sd	s0,16(sp)
    80001c88:	e426                	sd	s1,8(sp)
    80001c8a:	1000                	addi	s0,sp,32
    push_off();
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	efe080e7          	jalr	-258(ra) # 80000b8a <push_off>
    80001c94:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c96:	2781                	sext.w	a5,a5
    80001c98:	079e                	slli	a5,a5,0x7
    80001c9a:	0000f717          	auipc	a4,0xf
    80001c9e:	01670713          	addi	a4,a4,22 # 80010cb0 <cpus>
    80001ca2:	97ba                	add	a5,a5,a4
    80001ca4:	6384                	ld	s1,0(a5)
    pop_off();
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	f84080e7          	jalr	-124(ra) # 80000c2a <pop_off>
}
    80001cae:	8526                	mv	a0,s1
    80001cb0:	60e2                	ld	ra,24(sp)
    80001cb2:	6442                	ld	s0,16(sp)
    80001cb4:	64a2                	ld	s1,8(sp)
    80001cb6:	6105                	addi	sp,sp,32
    80001cb8:	8082                	ret

0000000080001cba <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001cba:	1141                	addi	sp,sp,-16
    80001cbc:	e406                	sd	ra,8(sp)
    80001cbe:	e022                	sd	s0,0(sp)
    80001cc0:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	fc0080e7          	jalr	-64(ra) # 80001c82 <myproc>
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	fc0080e7          	jalr	-64(ra) # 80000c8a <release>

    if (first)
    80001cd2:	00007797          	auipc	a5,0x7
    80001cd6:	c7e7a783          	lw	a5,-898(a5) # 80008950 <first.1>
    80001cda:	eb89                	bnez	a5,80001cec <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001cdc:	00001097          	auipc	ra,0x1
    80001ce0:	eb0080e7          	jalr	-336(ra) # 80002b8c <usertrapret>
}
    80001ce4:	60a2                	ld	ra,8(sp)
    80001ce6:	6402                	ld	s0,0(sp)
    80001ce8:	0141                	addi	sp,sp,16
    80001cea:	8082                	ret
        first = 0;
    80001cec:	00007797          	auipc	a5,0x7
    80001cf0:	c607a223          	sw	zero,-924(a5) # 80008950 <first.1>
        fsinit(ROOTDEV);
    80001cf4:	4505                	li	a0,1
    80001cf6:	00002097          	auipc	ra,0x2
    80001cfa:	c9e080e7          	jalr	-866(ra) # 80003994 <fsinit>
    80001cfe:	bff9                	j	80001cdc <forkret+0x22>

0000000080001d00 <allocpid>:
{
    80001d00:	1101                	addi	sp,sp,-32
    80001d02:	ec06                	sd	ra,24(sp)
    80001d04:	e822                	sd	s0,16(sp)
    80001d06:	e426                	sd	s1,8(sp)
    80001d08:	e04a                	sd	s2,0(sp)
    80001d0a:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001d0c:	0000f917          	auipc	s2,0xf
    80001d10:	3bc90913          	addi	s2,s2,956 # 800110c8 <pid_lock>
    80001d14:	854a                	mv	a0,s2
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	ec0080e7          	jalr	-320(ra) # 80000bd6 <acquire>
    pid = nextpid;
    80001d1e:	00007797          	auipc	a5,0x7
    80001d22:	c4678793          	addi	a5,a5,-954 # 80008964 <nextpid>
    80001d26:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001d28:	0014871b          	addiw	a4,s1,1
    80001d2c:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001d2e:	854a                	mv	a0,s2
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	f5a080e7          	jalr	-166(ra) # 80000c8a <release>
}
    80001d38:	8526                	mv	a0,s1
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6902                	ld	s2,0(sp)
    80001d42:	6105                	addi	sp,sp,32
    80001d44:	8082                	ret

0000000080001d46 <proc_pagetable>:
{
    80001d46:	1101                	addi	sp,sp,-32
    80001d48:	ec06                	sd	ra,24(sp)
    80001d4a:	e822                	sd	s0,16(sp)
    80001d4c:	e426                	sd	s1,8(sp)
    80001d4e:	e04a                	sd	s2,0(sp)
    80001d50:	1000                	addi	s0,sp,32
    80001d52:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	5d4080e7          	jalr	1492(ra) # 80001328 <uvmcreate>
    80001d5c:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001d5e:	c121                	beqz	a0,80001d9e <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d60:	4729                	li	a4,10
    80001d62:	00005697          	auipc	a3,0x5
    80001d66:	29e68693          	addi	a3,a3,670 # 80007000 <_trampoline>
    80001d6a:	6605                	lui	a2,0x1
    80001d6c:	040005b7          	lui	a1,0x4000
    80001d70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d72:	05b2                	slli	a1,a1,0xc
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	32a080e7          	jalr	810(ra) # 8000109e <mappages>
    80001d7c:	02054863          	bltz	a0,80001dac <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d80:	4719                	li	a4,6
    80001d82:	06093683          	ld	a3,96(s2)
    80001d86:	6605                	lui	a2,0x1
    80001d88:	020005b7          	lui	a1,0x2000
    80001d8c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d8e:	05b6                	slli	a1,a1,0xd
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	30c080e7          	jalr	780(ra) # 8000109e <mappages>
    80001d9a:	02054163          	bltz	a0,80001dbc <proc_pagetable+0x76>
}
    80001d9e:	8526                	mv	a0,s1
    80001da0:	60e2                	ld	ra,24(sp)
    80001da2:	6442                	ld	s0,16(sp)
    80001da4:	64a2                	ld	s1,8(sp)
    80001da6:	6902                	ld	s2,0(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret
        uvmfree(pagetable, 0);
    80001dac:	4581                	li	a1,0
    80001dae:	8526                	mv	a0,s1
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	77e080e7          	jalr	1918(ra) # 8000152e <uvmfree>
        return 0;
    80001db8:	4481                	li	s1,0
    80001dba:	b7d5                	j	80001d9e <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dbc:	4681                	li	a3,0
    80001dbe:	4605                	li	a2,1
    80001dc0:	040005b7          	lui	a1,0x4000
    80001dc4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dc6:	05b2                	slli	a1,a1,0xc
    80001dc8:	8526                	mv	a0,s1
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	49a080e7          	jalr	1178(ra) # 80001264 <uvmunmap>
        uvmfree(pagetable, 0);
    80001dd2:	4581                	li	a1,0
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	758080e7          	jalr	1880(ra) # 8000152e <uvmfree>
        return 0;
    80001dde:	4481                	li	s1,0
    80001de0:	bf7d                	j	80001d9e <proc_pagetable+0x58>

0000000080001de2 <proc_freepagetable>:
{
    80001de2:	1101                	addi	sp,sp,-32
    80001de4:	ec06                	sd	ra,24(sp)
    80001de6:	e822                	sd	s0,16(sp)
    80001de8:	e426                	sd	s1,8(sp)
    80001dea:	e04a                	sd	s2,0(sp)
    80001dec:	1000                	addi	s0,sp,32
    80001dee:	84aa                	mv	s1,a0
    80001df0:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001df2:	4681                	li	a3,0
    80001df4:	4605                	li	a2,1
    80001df6:	040005b7          	lui	a1,0x4000
    80001dfa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dfc:	05b2                	slli	a1,a1,0xc
    80001dfe:	fffff097          	auipc	ra,0xfffff
    80001e02:	466080e7          	jalr	1126(ra) # 80001264 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e06:	4681                	li	a3,0
    80001e08:	4605                	li	a2,1
    80001e0a:	020005b7          	lui	a1,0x2000
    80001e0e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e10:	05b6                	slli	a1,a1,0xd
    80001e12:	8526                	mv	a0,s1
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	450080e7          	jalr	1104(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, sz);
    80001e1c:	85ca                	mv	a1,s2
    80001e1e:	8526                	mv	a0,s1
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	70e080e7          	jalr	1806(ra) # 8000152e <uvmfree>
}
    80001e28:	60e2                	ld	ra,24(sp)
    80001e2a:	6442                	ld	s0,16(sp)
    80001e2c:	64a2                	ld	s1,8(sp)
    80001e2e:	6902                	ld	s2,0(sp)
    80001e30:	6105                	addi	sp,sp,32
    80001e32:	8082                	ret

0000000080001e34 <freeproc>:
{
    80001e34:	1101                	addi	sp,sp,-32
    80001e36:	ec06                	sd	ra,24(sp)
    80001e38:	e822                	sd	s0,16(sp)
    80001e3a:	e426                	sd	s1,8(sp)
    80001e3c:	1000                	addi	s0,sp,32
    80001e3e:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001e40:	7128                	ld	a0,96(a0)
    80001e42:	c509                	beqz	a0,80001e4c <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	ba4080e7          	jalr	-1116(ra) # 800009e8 <kfree>
    p->trapframe = 0;
    80001e4c:	0604b023          	sd	zero,96(s1)
    if (p->pagetable)
    80001e50:	6ca8                	ld	a0,88(s1)
    80001e52:	c511                	beqz	a0,80001e5e <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001e54:	68ac                	ld	a1,80(s1)
    80001e56:	00000097          	auipc	ra,0x0
    80001e5a:	f8c080e7          	jalr	-116(ra) # 80001de2 <proc_freepagetable>
    p->pagetable = 0;
    80001e5e:	0404bc23          	sd	zero,88(s1)
    p->sz = 0;
    80001e62:	0404b823          	sd	zero,80(s1)
    p->pid = 0;
    80001e66:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001e6a:	0404b023          	sd	zero,64(s1)
    p->name[0] = 0;
    80001e6e:	16048023          	sb	zero,352(s1)
    p->chan = 0;
    80001e72:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001e76:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001e7a:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001e7e:	0004ac23          	sw	zero,24(s1)
}
    80001e82:	60e2                	ld	ra,24(sp)
    80001e84:	6442                	ld	s0,16(sp)
    80001e86:	64a2                	ld	s1,8(sp)
    80001e88:	6105                	addi	sp,sp,32
    80001e8a:	8082                	ret

0000000080001e8c <allocproc>:
{
    80001e8c:	1101                	addi	sp,sp,-32
    80001e8e:	ec06                	sd	ra,24(sp)
    80001e90:	e822                	sd	s0,16(sp)
    80001e92:	e426                	sd	s1,8(sp)
    80001e94:	e04a                	sd	s2,0(sp)
    80001e96:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e98:	0000f497          	auipc	s1,0xf
    80001e9c:	26048493          	addi	s1,s1,608 # 800110f8 <proc>
    80001ea0:	00015917          	auipc	s2,0x15
    80001ea4:	e5890913          	addi	s2,s2,-424 # 80016cf8 <tickslock>
        acquire(&p->lock);
    80001ea8:	8526                	mv	a0,s1
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	d2c080e7          	jalr	-724(ra) # 80000bd6 <acquire>
        if (p->state == UNUSED)
    80001eb2:	4c9c                	lw	a5,24(s1)
    80001eb4:	cf81                	beqz	a5,80001ecc <allocproc+0x40>
            release(&p->lock);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	dd2080e7          	jalr	-558(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ec0:	17048493          	addi	s1,s1,368
    80001ec4:	ff2492e3          	bne	s1,s2,80001ea8 <allocproc+0x1c>
    return 0;
    80001ec8:	4481                	li	s1,0
    80001eca:	a8a9                	j	80001f24 <allocproc+0x98>
    p->pid = allocpid();
    80001ecc:	00000097          	auipc	ra,0x0
    80001ed0:	e34080e7          	jalr	-460(ra) # 80001d00 <allocpid>
    80001ed4:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001ed6:	4785                	li	a5,1
    80001ed8:	cc9c                	sw	a5,24(s1)
    p->priority = 0;
    80001eda:	0204aa23          	sw	zero,52(s1)
    p->qleft = quantum[0];
    80001ede:	4789                	li	a5,2
    80001ee0:	dc9c                	sw	a5,56(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001ee2:	fffff097          	auipc	ra,0xfffff
    80001ee6:	c04080e7          	jalr	-1020(ra) # 80000ae6 <kalloc>
    80001eea:	892a                	mv	s2,a0
    80001eec:	f0a8                	sd	a0,96(s1)
    80001eee:	c131                	beqz	a0,80001f32 <allocproc+0xa6>
    p->pagetable = proc_pagetable(p);
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	00000097          	auipc	ra,0x0
    80001ef6:	e54080e7          	jalr	-428(ra) # 80001d46 <proc_pagetable>
    80001efa:	892a                	mv	s2,a0
    80001efc:	eca8                	sd	a0,88(s1)
    if (p->pagetable == 0)
    80001efe:	c531                	beqz	a0,80001f4a <allocproc+0xbe>
    memset(&p->context, 0, sizeof(p->context));
    80001f00:	07000613          	li	a2,112
    80001f04:	4581                	li	a1,0
    80001f06:	06848513          	addi	a0,s1,104
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	dc8080e7          	jalr	-568(ra) # 80000cd2 <memset>
    p->context.ra = (uint64)forkret;
    80001f12:	00000797          	auipc	a5,0x0
    80001f16:	da878793          	addi	a5,a5,-600 # 80001cba <forkret>
    80001f1a:	f4bc                	sd	a5,104(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001f1c:	64bc                	ld	a5,72(s1)
    80001f1e:	6705                	lui	a4,0x1
    80001f20:	97ba                	add	a5,a5,a4
    80001f22:	f8bc                	sd	a5,112(s1)
}
    80001f24:	8526                	mv	a0,s1
    80001f26:	60e2                	ld	ra,24(sp)
    80001f28:	6442                	ld	s0,16(sp)
    80001f2a:	64a2                	ld	s1,8(sp)
    80001f2c:	6902                	ld	s2,0(sp)
    80001f2e:	6105                	addi	sp,sp,32
    80001f30:	8082                	ret
        freeproc(p);
    80001f32:	8526                	mv	a0,s1
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	f00080e7          	jalr	-256(ra) # 80001e34 <freeproc>
        release(&p->lock);
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	d4c080e7          	jalr	-692(ra) # 80000c8a <release>
        return 0;
    80001f46:	84ca                	mv	s1,s2
    80001f48:	bff1                	j	80001f24 <allocproc+0x98>
        freeproc(p);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	00000097          	auipc	ra,0x0
    80001f50:	ee8080e7          	jalr	-280(ra) # 80001e34 <freeproc>
        release(&p->lock);
    80001f54:	8526                	mv	a0,s1
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	d34080e7          	jalr	-716(ra) # 80000c8a <release>
        return 0;
    80001f5e:	84ca                	mv	s1,s2
    80001f60:	b7d1                	j	80001f24 <allocproc+0x98>

0000000080001f62 <userinit>:
{
    80001f62:	1101                	addi	sp,sp,-32
    80001f64:	ec06                	sd	ra,24(sp)
    80001f66:	e822                	sd	s0,16(sp)
    80001f68:	e426                	sd	s1,8(sp)
    80001f6a:	1000                	addi	s0,sp,32
    p = allocproc();
    80001f6c:	00000097          	auipc	ra,0x0
    80001f70:	f20080e7          	jalr	-224(ra) # 80001e8c <allocproc>
    80001f74:	84aa                	mv	s1,a0
    initproc = p;
    80001f76:	00007797          	auipc	a5,0x7
    80001f7a:	aca7b123          	sd	a0,-1342(a5) # 80008a38 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f7e:	03400613          	li	a2,52
    80001f82:	00007597          	auipc	a1,0x7
    80001f86:	9ee58593          	addi	a1,a1,-1554 # 80008970 <initcode>
    80001f8a:	6d28                	ld	a0,88(a0)
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	3ca080e7          	jalr	970(ra) # 80001356 <uvmfirst>
    p->sz = PGSIZE;
    80001f94:	6785                	lui	a5,0x1
    80001f96:	e8bc                	sd	a5,80(s1)
    p->trapframe->epc = 0;     // user program counter
    80001f98:	70b8                	ld	a4,96(s1)
    80001f9a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f9e:	70b8                	ld	a4,96(s1)
    80001fa0:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fa2:	4641                	li	a2,16
    80001fa4:	00006597          	auipc	a1,0x6
    80001fa8:	26458593          	addi	a1,a1,612 # 80008208 <digits+0x1c8>
    80001fac:	16048513          	addi	a0,s1,352
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	e6c080e7          	jalr	-404(ra) # 80000e1c <safestrcpy>
    p->cwd = namei("/");
    80001fb8:	00006517          	auipc	a0,0x6
    80001fbc:	26050513          	addi	a0,a0,608 # 80008218 <digits+0x1d8>
    80001fc0:	00002097          	auipc	ra,0x2
    80001fc4:	3fe080e7          	jalr	1022(ra) # 800043be <namei>
    80001fc8:	14a4bc23          	sd	a0,344(s1)
    p->state = RUNNABLE;
    80001fcc:	478d                	li	a5,3
    80001fce:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	cb8080e7          	jalr	-840(ra) # 80000c8a <release>
}
    80001fda:	60e2                	ld	ra,24(sp)
    80001fdc:	6442                	ld	s0,16(sp)
    80001fde:	64a2                	ld	s1,8(sp)
    80001fe0:	6105                	addi	sp,sp,32
    80001fe2:	8082                	ret

0000000080001fe4 <growproc>:
{
    80001fe4:	1101                	addi	sp,sp,-32
    80001fe6:	ec06                	sd	ra,24(sp)
    80001fe8:	e822                	sd	s0,16(sp)
    80001fea:	e426                	sd	s1,8(sp)
    80001fec:	e04a                	sd	s2,0(sp)
    80001fee:	1000                	addi	s0,sp,32
    80001ff0:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001ff2:	00000097          	auipc	ra,0x0
    80001ff6:	c90080e7          	jalr	-880(ra) # 80001c82 <myproc>
    80001ffa:	84aa                	mv	s1,a0
    sz = p->sz;
    80001ffc:	692c                	ld	a1,80(a0)
    if (n > 0)
    80001ffe:	01204c63          	bgtz	s2,80002016 <growproc+0x32>
    else if (n < 0)
    80002002:	02094663          	bltz	s2,8000202e <growproc+0x4a>
    p->sz = sz;
    80002006:	e8ac                	sd	a1,80(s1)
    return 0;
    80002008:	4501                	li	a0,0
}
    8000200a:	60e2                	ld	ra,24(sp)
    8000200c:	6442                	ld	s0,16(sp)
    8000200e:	64a2                	ld	s1,8(sp)
    80002010:	6902                	ld	s2,0(sp)
    80002012:	6105                	addi	sp,sp,32
    80002014:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002016:	4691                	li	a3,4
    80002018:	00b90633          	add	a2,s2,a1
    8000201c:	6d28                	ld	a0,88(a0)
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	3f2080e7          	jalr	1010(ra) # 80001410 <uvmalloc>
    80002026:	85aa                	mv	a1,a0
    80002028:	fd79                	bnez	a0,80002006 <growproc+0x22>
            return -1;
    8000202a:	557d                	li	a0,-1
    8000202c:	bff9                	j	8000200a <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000202e:	00b90633          	add	a2,s2,a1
    80002032:	6d28                	ld	a0,88(a0)
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	394080e7          	jalr	916(ra) # 800013c8 <uvmdealloc>
    8000203c:	85aa                	mv	a1,a0
    8000203e:	b7e1                	j	80002006 <growproc+0x22>

0000000080002040 <ps>:
{
    80002040:	715d                	addi	sp,sp,-80
    80002042:	e486                	sd	ra,72(sp)
    80002044:	e0a2                	sd	s0,64(sp)
    80002046:	fc26                	sd	s1,56(sp)
    80002048:	f84a                	sd	s2,48(sp)
    8000204a:	f44e                	sd	s3,40(sp)
    8000204c:	f052                	sd	s4,32(sp)
    8000204e:	ec56                	sd	s5,24(sp)
    80002050:	e85a                	sd	s6,16(sp)
    80002052:	e45e                	sd	s7,8(sp)
    80002054:	e062                	sd	s8,0(sp)
    80002056:	0880                	addi	s0,sp,80
    80002058:	84aa                	mv	s1,a0
    8000205a:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	c26080e7          	jalr	-986(ra) # 80001c82 <myproc>
        return result;
    80002064:	4901                	li	s2,0
    if (count == 0)
    80002066:	0c0b8563          	beqz	s7,80002130 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    8000206a:	05053b03          	ld	s6,80(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000206e:	003b951b          	slliw	a0,s7,0x3
    80002072:	0175053b          	addw	a0,a0,s7
    80002076:	0025151b          	slliw	a0,a0,0x2
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	f6a080e7          	jalr	-150(ra) # 80001fe4 <growproc>
    80002082:	12054f63          	bltz	a0,800021c0 <ps+0x180>
    struct user_proc loc_result[count];
    80002086:	003b9a13          	slli	s4,s7,0x3
    8000208a:	9a5e                	add	s4,s4,s7
    8000208c:	0a0a                	slli	s4,s4,0x2
    8000208e:	00fa0793          	addi	a5,s4,15
    80002092:	8391                	srli	a5,a5,0x4
    80002094:	0792                	slli	a5,a5,0x4
    80002096:	40f10133          	sub	sp,sp,a5
    8000209a:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    8000209c:	17000793          	li	a5,368
    800020a0:	02f484b3          	mul	s1,s1,a5
    800020a4:	0000f797          	auipc	a5,0xf
    800020a8:	05478793          	addi	a5,a5,84 # 800110f8 <proc>
    800020ac:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800020ae:	00015797          	auipc	a5,0x15
    800020b2:	c4a78793          	addi	a5,a5,-950 # 80016cf8 <tickslock>
        return result;
    800020b6:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800020b8:	06f4fc63          	bgeu	s1,a5,80002130 <ps+0xf0>
    acquire(&wait_lock);
    800020bc:	0000f517          	auipc	a0,0xf
    800020c0:	02450513          	addi	a0,a0,36 # 800110e0 <wait_lock>
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	b12080e7          	jalr	-1262(ra) # 80000bd6 <acquire>
        if (localCount == count)
    800020cc:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    800020d0:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    800020d2:	00015c17          	auipc	s8,0x15
    800020d6:	c26c0c13          	addi	s8,s8,-986 # 80016cf8 <tickslock>
    800020da:	a851                	j	8000216e <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    800020dc:	00399793          	slli	a5,s3,0x3
    800020e0:	97ce                	add	a5,a5,s3
    800020e2:	078a                	slli	a5,a5,0x2
    800020e4:	97d6                	add	a5,a5,s5
    800020e6:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	b9e080e7          	jalr	-1122(ra) # 80000c8a <release>
    release(&wait_lock);
    800020f4:	0000f517          	auipc	a0,0xf
    800020f8:	fec50513          	addi	a0,a0,-20 # 800110e0 <wait_lock>
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	b8e080e7          	jalr	-1138(ra) # 80000c8a <release>
    if (localCount < count)
    80002104:	0179f963          	bgeu	s3,s7,80002116 <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002108:	00399793          	slli	a5,s3,0x3
    8000210c:	97ce                	add	a5,a5,s3
    8000210e:	078a                	slli	a5,a5,0x2
    80002110:	97d6                	add	a5,a5,s5
    80002112:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002116:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002118:	00000097          	auipc	ra,0x0
    8000211c:	b6a080e7          	jalr	-1174(ra) # 80001c82 <myproc>
    80002120:	86d2                	mv	a3,s4
    80002122:	8656                	mv	a2,s5
    80002124:	85da                	mv	a1,s6
    80002126:	6d28                	ld	a0,88(a0)
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	544080e7          	jalr	1348(ra) # 8000166c <copyout>
}
    80002130:	854a                	mv	a0,s2
    80002132:	fb040113          	addi	sp,s0,-80
    80002136:	60a6                	ld	ra,72(sp)
    80002138:	6406                	ld	s0,64(sp)
    8000213a:	74e2                	ld	s1,56(sp)
    8000213c:	7942                	ld	s2,48(sp)
    8000213e:	79a2                	ld	s3,40(sp)
    80002140:	7a02                	ld	s4,32(sp)
    80002142:	6ae2                	ld	s5,24(sp)
    80002144:	6b42                	ld	s6,16(sp)
    80002146:	6ba2                	ld	s7,8(sp)
    80002148:	6c02                	ld	s8,0(sp)
    8000214a:	6161                	addi	sp,sp,80
    8000214c:	8082                	ret
        release(&p->lock);
    8000214e:	8526                	mv	a0,s1
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	b3a080e7          	jalr	-1222(ra) # 80000c8a <release>
        localCount++;
    80002158:	2985                	addiw	s3,s3,1
    8000215a:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    8000215e:	17048493          	addi	s1,s1,368
    80002162:	f984f9e3          	bgeu	s1,s8,800020f4 <ps+0xb4>
        if (localCount == count)
    80002166:	02490913          	addi	s2,s2,36
    8000216a:	053b8d63          	beq	s7,s3,800021c4 <ps+0x184>
        acquire(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a66080e7          	jalr	-1434(ra) # 80000bd6 <acquire>
        if (p->state == UNUSED)
    80002178:	4c9c                	lw	a5,24(s1)
    8000217a:	d3ad                	beqz	a5,800020dc <ps+0x9c>
        loc_result[localCount].state = p->state;
    8000217c:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    80002180:	549c                	lw	a5,40(s1)
    80002182:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002186:	54dc                	lw	a5,44(s1)
    80002188:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    8000218c:	589c                	lw	a5,48(s1)
    8000218e:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002192:	4641                	li	a2,16
    80002194:	85ca                	mv	a1,s2
    80002196:	16048513          	addi	a0,s1,352
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	a8e080e7          	jalr	-1394(ra) # 80001c28 <copy_array>
        if (p->parent != 0) // init
    800021a2:	60a8                	ld	a0,64(s1)
    800021a4:	d54d                	beqz	a0,8000214e <ps+0x10e>
            acquire(&p->parent->lock);
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	a30080e7          	jalr	-1488(ra) # 80000bd6 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800021ae:	60a8                	ld	a0,64(s1)
    800021b0:	591c                	lw	a5,48(a0)
    800021b2:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	ad4080e7          	jalr	-1324(ra) # 80000c8a <release>
    800021be:	bf41                	j	8000214e <ps+0x10e>
        return result;
    800021c0:	4901                	li	s2,0
    800021c2:	b7bd                	j	80002130 <ps+0xf0>
    release(&wait_lock);
    800021c4:	0000f517          	auipc	a0,0xf
    800021c8:	f1c50513          	addi	a0,a0,-228 # 800110e0 <wait_lock>
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	abe080e7          	jalr	-1346(ra) # 80000c8a <release>
    if (localCount < count)
    800021d4:	b789                	j	80002116 <ps+0xd6>

00000000800021d6 <fork>:
{
    800021d6:	7139                	addi	sp,sp,-64
    800021d8:	fc06                	sd	ra,56(sp)
    800021da:	f822                	sd	s0,48(sp)
    800021dc:	f426                	sd	s1,40(sp)
    800021de:	f04a                	sd	s2,32(sp)
    800021e0:	ec4e                	sd	s3,24(sp)
    800021e2:	e852                	sd	s4,16(sp)
    800021e4:	e456                	sd	s5,8(sp)
    800021e6:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	a9a080e7          	jalr	-1382(ra) # 80001c82 <myproc>
    800021f0:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    800021f2:	00000097          	auipc	ra,0x0
    800021f6:	c9a080e7          	jalr	-870(ra) # 80001e8c <allocproc>
    800021fa:	10050c63          	beqz	a0,80002312 <fork+0x13c>
    800021fe:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002200:	050ab603          	ld	a2,80(s5)
    80002204:	6d2c                	ld	a1,88(a0)
    80002206:	058ab503          	ld	a0,88(s5)
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	35e080e7          	jalr	862(ra) # 80001568 <uvmcopy>
    80002212:	04054863          	bltz	a0,80002262 <fork+0x8c>
    np->sz = p->sz;
    80002216:	050ab783          	ld	a5,80(s5)
    8000221a:	04fa3823          	sd	a5,80(s4)
    *(np->trapframe) = *(p->trapframe);
    8000221e:	060ab683          	ld	a3,96(s5)
    80002222:	87b6                	mv	a5,a3
    80002224:	060a3703          	ld	a4,96(s4)
    80002228:	12068693          	addi	a3,a3,288
    8000222c:	0007b803          	ld	a6,0(a5)
    80002230:	6788                	ld	a0,8(a5)
    80002232:	6b8c                	ld	a1,16(a5)
    80002234:	6f90                	ld	a2,24(a5)
    80002236:	01073023          	sd	a6,0(a4)
    8000223a:	e708                	sd	a0,8(a4)
    8000223c:	eb0c                	sd	a1,16(a4)
    8000223e:	ef10                	sd	a2,24(a4)
    80002240:	02078793          	addi	a5,a5,32
    80002244:	02070713          	addi	a4,a4,32
    80002248:	fed792e3          	bne	a5,a3,8000222c <fork+0x56>
    np->trapframe->a0 = 0;
    8000224c:	060a3783          	ld	a5,96(s4)
    80002250:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002254:	0d8a8493          	addi	s1,s5,216
    80002258:	0d8a0913          	addi	s2,s4,216
    8000225c:	158a8993          	addi	s3,s5,344
    80002260:	a00d                	j	80002282 <fork+0xac>
        freeproc(np);
    80002262:	8552                	mv	a0,s4
    80002264:	00000097          	auipc	ra,0x0
    80002268:	bd0080e7          	jalr	-1072(ra) # 80001e34 <freeproc>
        release(&np->lock);
    8000226c:	8552                	mv	a0,s4
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a1c080e7          	jalr	-1508(ra) # 80000c8a <release>
        return -1;
    80002276:	597d                	li	s2,-1
    80002278:	a059                	j	800022fe <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    8000227a:	04a1                	addi	s1,s1,8
    8000227c:	0921                	addi	s2,s2,8
    8000227e:	01348b63          	beq	s1,s3,80002294 <fork+0xbe>
        if (p->ofile[i])
    80002282:	6088                	ld	a0,0(s1)
    80002284:	d97d                	beqz	a0,8000227a <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    80002286:	00002097          	auipc	ra,0x2
    8000228a:	7ce080e7          	jalr	1998(ra) # 80004a54 <filedup>
    8000228e:	00a93023          	sd	a0,0(s2)
    80002292:	b7e5                	j	8000227a <fork+0xa4>
    np->cwd = idup(p->cwd);
    80002294:	158ab503          	ld	a0,344(s5)
    80002298:	00002097          	auipc	ra,0x2
    8000229c:	93c080e7          	jalr	-1732(ra) # 80003bd4 <idup>
    800022a0:	14aa3c23          	sd	a0,344(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800022a4:	4641                	li	a2,16
    800022a6:	160a8593          	addi	a1,s5,352
    800022aa:	160a0513          	addi	a0,s4,352
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	b6e080e7          	jalr	-1170(ra) # 80000e1c <safestrcpy>
    pid = np->pid;
    800022b6:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800022ba:	8552                	mv	a0,s4
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	9ce080e7          	jalr	-1586(ra) # 80000c8a <release>
    acquire(&wait_lock);
    800022c4:	0000f497          	auipc	s1,0xf
    800022c8:	e1c48493          	addi	s1,s1,-484 # 800110e0 <wait_lock>
    800022cc:	8526                	mv	a0,s1
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	908080e7          	jalr	-1784(ra) # 80000bd6 <acquire>
    np->parent = p;
    800022d6:	055a3023          	sd	s5,64(s4)
    release(&wait_lock);
    800022da:	8526                	mv	a0,s1
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	9ae080e7          	jalr	-1618(ra) # 80000c8a <release>
    acquire(&np->lock);
    800022e4:	8552                	mv	a0,s4
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	8f0080e7          	jalr	-1808(ra) # 80000bd6 <acquire>
    np->state = RUNNABLE;
    800022ee:	478d                	li	a5,3
    800022f0:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    800022f4:	8552                	mv	a0,s4
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	994080e7          	jalr	-1644(ra) # 80000c8a <release>
}
    800022fe:	854a                	mv	a0,s2
    80002300:	70e2                	ld	ra,56(sp)
    80002302:	7442                	ld	s0,48(sp)
    80002304:	74a2                	ld	s1,40(sp)
    80002306:	7902                	ld	s2,32(sp)
    80002308:	69e2                	ld	s3,24(sp)
    8000230a:	6a42                	ld	s4,16(sp)
    8000230c:	6aa2                	ld	s5,8(sp)
    8000230e:	6121                	addi	sp,sp,64
    80002310:	8082                	ret
        return -1;
    80002312:	597d                	li	s2,-1
    80002314:	b7ed                	j	800022fe <fork+0x128>

0000000080002316 <scheduler>:
{
    80002316:	1101                	addi	sp,sp,-32
    80002318:	ec06                	sd	ra,24(sp)
    8000231a:	e822                	sd	s0,16(sp)
    8000231c:	e426                	sd	s1,8(sp)
    8000231e:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002320:	00006497          	auipc	s1,0x6
    80002324:	63848493          	addi	s1,s1,1592 # 80008958 <sched_pointer>
    80002328:	609c                	ld	a5,0(s1)
    8000232a:	9782                	jalr	a5
        if (old_scheduler != sched_pointer)
    8000232c:	bff5                	j	80002328 <scheduler+0x12>

000000008000232e <sched>:
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000233c:	00000097          	auipc	ra,0x0
    80002340:	946080e7          	jalr	-1722(ra) # 80001c82 <myproc>
    80002344:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	816080e7          	jalr	-2026(ra) # 80000b5c <holding>
    8000234e:	c53d                	beqz	a0,800023bc <sched+0x8e>
    80002350:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002352:	2781                	sext.w	a5,a5
    80002354:	079e                	slli	a5,a5,0x7
    80002356:	0000f717          	auipc	a4,0xf
    8000235a:	95a70713          	addi	a4,a4,-1702 # 80010cb0 <cpus>
    8000235e:	97ba                	add	a5,a5,a4
    80002360:	5fb8                	lw	a4,120(a5)
    80002362:	4785                	li	a5,1
    80002364:	06f71463          	bne	a4,a5,800023cc <sched+0x9e>
    if (p->state == RUNNING)
    80002368:	4c98                	lw	a4,24(s1)
    8000236a:	4791                	li	a5,4
    8000236c:	06f70863          	beq	a4,a5,800023dc <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002370:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002374:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002376:	ebbd                	bnez	a5,800023ec <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002378:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    8000237a:	0000f917          	auipc	s2,0xf
    8000237e:	93690913          	addi	s2,s2,-1738 # 80010cb0 <cpus>
    80002382:	2781                	sext.w	a5,a5
    80002384:	079e                	slli	a5,a5,0x7
    80002386:	97ca                	add	a5,a5,s2
    80002388:	07c7a983          	lw	s3,124(a5)
    8000238c:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    8000238e:	2581                	sext.w	a1,a1
    80002390:	059e                	slli	a1,a1,0x7
    80002392:	05a1                	addi	a1,a1,8
    80002394:	95ca                	add	a1,a1,s2
    80002396:	06848513          	addi	a0,s1,104
    8000239a:	00000097          	auipc	ra,0x0
    8000239e:	748080e7          	jalr	1864(ra) # 80002ae2 <swtch>
    800023a2:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800023a4:	2781                	sext.w	a5,a5
    800023a6:	079e                	slli	a5,a5,0x7
    800023a8:	993e                	add	s2,s2,a5
    800023aa:	07392e23          	sw	s3,124(s2)
}
    800023ae:	70a2                	ld	ra,40(sp)
    800023b0:	7402                	ld	s0,32(sp)
    800023b2:	64e2                	ld	s1,24(sp)
    800023b4:	6942                	ld	s2,16(sp)
    800023b6:	69a2                	ld	s3,8(sp)
    800023b8:	6145                	addi	sp,sp,48
    800023ba:	8082                	ret
        panic("sched p->lock");
    800023bc:	00006517          	auipc	a0,0x6
    800023c0:	e6450513          	addi	a0,a0,-412 # 80008220 <digits+0x1e0>
    800023c4:	ffffe097          	auipc	ra,0xffffe
    800023c8:	17c080e7          	jalr	380(ra) # 80000540 <panic>
        panic("sched locks");
    800023cc:	00006517          	auipc	a0,0x6
    800023d0:	e6450513          	addi	a0,a0,-412 # 80008230 <digits+0x1f0>
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	16c080e7          	jalr	364(ra) # 80000540 <panic>
        panic("sched running");
    800023dc:	00006517          	auipc	a0,0x6
    800023e0:	e6450513          	addi	a0,a0,-412 # 80008240 <digits+0x200>
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	15c080e7          	jalr	348(ra) # 80000540 <panic>
        panic("sched interruptible");
    800023ec:	00006517          	auipc	a0,0x6
    800023f0:	e6450513          	addi	a0,a0,-412 # 80008250 <digits+0x210>
    800023f4:	ffffe097          	auipc	ra,0xffffe
    800023f8:	14c080e7          	jalr	332(ra) # 80000540 <panic>

00000000800023fc <yield>:
{
    800023fc:	1101                	addi	sp,sp,-32
    800023fe:	ec06                	sd	ra,24(sp)
    80002400:	e822                	sd	s0,16(sp)
    80002402:	e426                	sd	s1,8(sp)
    80002404:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002406:	00000097          	auipc	ra,0x0
    8000240a:	87c080e7          	jalr	-1924(ra) # 80001c82 <myproc>
    8000240e:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	7c6080e7          	jalr	1990(ra) # 80000bd6 <acquire>
    p->state = RUNNABLE;
    80002418:	478d                	li	a5,3
    8000241a:	cc9c                	sw	a5,24(s1)
    sched();
    8000241c:	00000097          	auipc	ra,0x0
    80002420:	f12080e7          	jalr	-238(ra) # 8000232e <sched>
    release(&p->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	864080e7          	jalr	-1948(ra) # 80000c8a <release>
}
    8000242e:	60e2                	ld	ra,24(sp)
    80002430:	6442                	ld	s0,16(sp)
    80002432:	64a2                	ld	s1,8(sp)
    80002434:	6105                	addi	sp,sp,32
    80002436:	8082                	ret

0000000080002438 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002438:	7179                	addi	sp,sp,-48
    8000243a:	f406                	sd	ra,40(sp)
    8000243c:	f022                	sd	s0,32(sp)
    8000243e:	ec26                	sd	s1,24(sp)
    80002440:	e84a                	sd	s2,16(sp)
    80002442:	e44e                	sd	s3,8(sp)
    80002444:	1800                	addi	s0,sp,48
    80002446:	89aa                	mv	s3,a0
    80002448:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000244a:	00000097          	auipc	ra,0x0
    8000244e:	838080e7          	jalr	-1992(ra) # 80001c82 <myproc>
    80002452:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002454:	ffffe097          	auipc	ra,0xffffe
    80002458:	782080e7          	jalr	1922(ra) # 80000bd6 <acquire>
    release(lk);
    8000245c:	854a                	mv	a0,s2
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	82c080e7          	jalr	-2004(ra) # 80000c8a <release>

    // Go to sleep.
    p->chan = chan;
    80002466:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    8000246a:	4789                	li	a5,2
    8000246c:	cc9c                	sw	a5,24(s1)

    sched();
    8000246e:	00000097          	auipc	ra,0x0
    80002472:	ec0080e7          	jalr	-320(ra) # 8000232e <sched>

    // Tidy up.
    p->chan = 0;
    80002476:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	80e080e7          	jalr	-2034(ra) # 80000c8a <release>
    acquire(lk);
    80002484:	854a                	mv	a0,s2
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	750080e7          	jalr	1872(ra) # 80000bd6 <acquire>
}
    8000248e:	70a2                	ld	ra,40(sp)
    80002490:	7402                	ld	s0,32(sp)
    80002492:	64e2                	ld	s1,24(sp)
    80002494:	6942                	ld	s2,16(sp)
    80002496:	69a2                	ld	s3,8(sp)
    80002498:	6145                	addi	sp,sp,48
    8000249a:	8082                	ret

000000008000249c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000249c:	7139                	addi	sp,sp,-64
    8000249e:	fc06                	sd	ra,56(sp)
    800024a0:	f822                	sd	s0,48(sp)
    800024a2:	f426                	sd	s1,40(sp)
    800024a4:	f04a                	sd	s2,32(sp)
    800024a6:	ec4e                	sd	s3,24(sp)
    800024a8:	e852                	sd	s4,16(sp)
    800024aa:	e456                	sd	s5,8(sp)
    800024ac:	0080                	addi	s0,sp,64
    800024ae:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024b0:	0000f497          	auipc	s1,0xf
    800024b4:	c4848493          	addi	s1,s1,-952 # 800110f8 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800024b8:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800024ba:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800024bc:	00015917          	auipc	s2,0x15
    800024c0:	83c90913          	addi	s2,s2,-1988 # 80016cf8 <tickslock>
    800024c4:	a811                	j	800024d8 <wakeup+0x3c>
            }
            release(&p->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	7c2080e7          	jalr	1986(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800024d0:	17048493          	addi	s1,s1,368
    800024d4:	03248663          	beq	s1,s2,80002500 <wakeup+0x64>
        if (p != myproc())
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	7aa080e7          	jalr	1962(ra) # 80001c82 <myproc>
    800024e0:	fea488e3          	beq	s1,a0,800024d0 <wakeup+0x34>
            acquire(&p->lock);
    800024e4:	8526                	mv	a0,s1
    800024e6:	ffffe097          	auipc	ra,0xffffe
    800024ea:	6f0080e7          	jalr	1776(ra) # 80000bd6 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    800024ee:	4c9c                	lw	a5,24(s1)
    800024f0:	fd379be3          	bne	a5,s3,800024c6 <wakeup+0x2a>
    800024f4:	709c                	ld	a5,32(s1)
    800024f6:	fd4798e3          	bne	a5,s4,800024c6 <wakeup+0x2a>
                p->state = RUNNABLE;
    800024fa:	0154ac23          	sw	s5,24(s1)
    800024fe:	b7e1                	j	800024c6 <wakeup+0x2a>
        }
    }
}
    80002500:	70e2                	ld	ra,56(sp)
    80002502:	7442                	ld	s0,48(sp)
    80002504:	74a2                	ld	s1,40(sp)
    80002506:	7902                	ld	s2,32(sp)
    80002508:	69e2                	ld	s3,24(sp)
    8000250a:	6a42                	ld	s4,16(sp)
    8000250c:	6aa2                	ld	s5,8(sp)
    8000250e:	6121                	addi	sp,sp,64
    80002510:	8082                	ret

0000000080002512 <reparent>:
{
    80002512:	7179                	addi	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	e052                	sd	s4,0(sp)
    80002520:	1800                	addi	s0,sp,48
    80002522:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002524:	0000f497          	auipc	s1,0xf
    80002528:	bd448493          	addi	s1,s1,-1068 # 800110f8 <proc>
            pp->parent = initproc;
    8000252c:	00006a17          	auipc	s4,0x6
    80002530:	50ca0a13          	addi	s4,s4,1292 # 80008a38 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002534:	00014997          	auipc	s3,0x14
    80002538:	7c498993          	addi	s3,s3,1988 # 80016cf8 <tickslock>
    8000253c:	a029                	j	80002546 <reparent+0x34>
    8000253e:	17048493          	addi	s1,s1,368
    80002542:	01348d63          	beq	s1,s3,8000255c <reparent+0x4a>
        if (pp->parent == p)
    80002546:	60bc                	ld	a5,64(s1)
    80002548:	ff279be3          	bne	a5,s2,8000253e <reparent+0x2c>
            pp->parent = initproc;
    8000254c:	000a3503          	ld	a0,0(s4)
    80002550:	e0a8                	sd	a0,64(s1)
            wakeup(initproc);
    80002552:	00000097          	auipc	ra,0x0
    80002556:	f4a080e7          	jalr	-182(ra) # 8000249c <wakeup>
    8000255a:	b7d5                	j	8000253e <reparent+0x2c>
}
    8000255c:	70a2                	ld	ra,40(sp)
    8000255e:	7402                	ld	s0,32(sp)
    80002560:	64e2                	ld	s1,24(sp)
    80002562:	6942                	ld	s2,16(sp)
    80002564:	69a2                	ld	s3,8(sp)
    80002566:	6a02                	ld	s4,0(sp)
    80002568:	6145                	addi	sp,sp,48
    8000256a:	8082                	ret

000000008000256c <exit>:
{
    8000256c:	7179                	addi	sp,sp,-48
    8000256e:	f406                	sd	ra,40(sp)
    80002570:	f022                	sd	s0,32(sp)
    80002572:	ec26                	sd	s1,24(sp)
    80002574:	e84a                	sd	s2,16(sp)
    80002576:	e44e                	sd	s3,8(sp)
    80002578:	e052                	sd	s4,0(sp)
    8000257a:	1800                	addi	s0,sp,48
    8000257c:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    8000257e:	fffff097          	auipc	ra,0xfffff
    80002582:	704080e7          	jalr	1796(ra) # 80001c82 <myproc>
    80002586:	89aa                	mv	s3,a0
    if (p == initproc)
    80002588:	00006797          	auipc	a5,0x6
    8000258c:	4b07b783          	ld	a5,1200(a5) # 80008a38 <initproc>
    80002590:	0d850493          	addi	s1,a0,216
    80002594:	15850913          	addi	s2,a0,344
    80002598:	02a79363          	bne	a5,a0,800025be <exit+0x52>
        panic("init exiting");
    8000259c:	00006517          	auipc	a0,0x6
    800025a0:	ccc50513          	addi	a0,a0,-820 # 80008268 <digits+0x228>
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	f9c080e7          	jalr	-100(ra) # 80000540 <panic>
            fileclose(f);
    800025ac:	00002097          	auipc	ra,0x2
    800025b0:	4fa080e7          	jalr	1274(ra) # 80004aa6 <fileclose>
            p->ofile[fd] = 0;
    800025b4:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800025b8:	04a1                	addi	s1,s1,8
    800025ba:	01248563          	beq	s1,s2,800025c4 <exit+0x58>
        if (p->ofile[fd])
    800025be:	6088                	ld	a0,0(s1)
    800025c0:	f575                	bnez	a0,800025ac <exit+0x40>
    800025c2:	bfdd                	j	800025b8 <exit+0x4c>
    begin_op();
    800025c4:	00002097          	auipc	ra,0x2
    800025c8:	01a080e7          	jalr	26(ra) # 800045de <begin_op>
    iput(p->cwd);
    800025cc:	1589b503          	ld	a0,344(s3)
    800025d0:	00001097          	auipc	ra,0x1
    800025d4:	7fc080e7          	jalr	2044(ra) # 80003dcc <iput>
    end_op();
    800025d8:	00002097          	auipc	ra,0x2
    800025dc:	084080e7          	jalr	132(ra) # 8000465c <end_op>
    p->cwd = 0;
    800025e0:	1409bc23          	sd	zero,344(s3)
    acquire(&wait_lock);
    800025e4:	0000f497          	auipc	s1,0xf
    800025e8:	afc48493          	addi	s1,s1,-1284 # 800110e0 <wait_lock>
    800025ec:	8526                	mv	a0,s1
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	5e8080e7          	jalr	1512(ra) # 80000bd6 <acquire>
    reparent(p);
    800025f6:	854e                	mv	a0,s3
    800025f8:	00000097          	auipc	ra,0x0
    800025fc:	f1a080e7          	jalr	-230(ra) # 80002512 <reparent>
    wakeup(p->parent);
    80002600:	0409b503          	ld	a0,64(s3)
    80002604:	00000097          	auipc	ra,0x0
    80002608:	e98080e7          	jalr	-360(ra) # 8000249c <wakeup>
    acquire(&p->lock);
    8000260c:	854e                	mv	a0,s3
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	5c8080e7          	jalr	1480(ra) # 80000bd6 <acquire>
    p->xstate = status;
    80002616:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    8000261a:	4795                	li	a5,5
    8000261c:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002620:	8526                	mv	a0,s1
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	668080e7          	jalr	1640(ra) # 80000c8a <release>
    sched();
    8000262a:	00000097          	auipc	ra,0x0
    8000262e:	d04080e7          	jalr	-764(ra) # 8000232e <sched>
    panic("zombie exit");
    80002632:	00006517          	auipc	a0,0x6
    80002636:	c4650513          	addi	a0,a0,-954 # 80008278 <digits+0x238>
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	f06080e7          	jalr	-250(ra) # 80000540 <panic>

0000000080002642 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002642:	7179                	addi	sp,sp,-48
    80002644:	f406                	sd	ra,40(sp)
    80002646:	f022                	sd	s0,32(sp)
    80002648:	ec26                	sd	s1,24(sp)
    8000264a:	e84a                	sd	s2,16(sp)
    8000264c:	e44e                	sd	s3,8(sp)
    8000264e:	1800                	addi	s0,sp,48
    80002650:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002652:	0000f497          	auipc	s1,0xf
    80002656:	aa648493          	addi	s1,s1,-1370 # 800110f8 <proc>
    8000265a:	00014997          	auipc	s3,0x14
    8000265e:	69e98993          	addi	s3,s3,1694 # 80016cf8 <tickslock>
    {
        acquire(&p->lock);
    80002662:	8526                	mv	a0,s1
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	572080e7          	jalr	1394(ra) # 80000bd6 <acquire>
        if (p->pid == pid)
    8000266c:	589c                	lw	a5,48(s1)
    8000266e:	01278d63          	beq	a5,s2,80002688 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002672:	8526                	mv	a0,s1
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	616080e7          	jalr	1558(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000267c:	17048493          	addi	s1,s1,368
    80002680:	ff3491e3          	bne	s1,s3,80002662 <kill+0x20>
    }
    return -1;
    80002684:	557d                	li	a0,-1
    80002686:	a829                	j	800026a0 <kill+0x5e>
            p->killed = 1;
    80002688:	4785                	li	a5,1
    8000268a:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000268c:	4c98                	lw	a4,24(s1)
    8000268e:	4789                	li	a5,2
    80002690:	00f70f63          	beq	a4,a5,800026ae <kill+0x6c>
            release(&p->lock);
    80002694:	8526                	mv	a0,s1
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	5f4080e7          	jalr	1524(ra) # 80000c8a <release>
            return 0;
    8000269e:	4501                	li	a0,0
}
    800026a0:	70a2                	ld	ra,40(sp)
    800026a2:	7402                	ld	s0,32(sp)
    800026a4:	64e2                	ld	s1,24(sp)
    800026a6:	6942                	ld	s2,16(sp)
    800026a8:	69a2                	ld	s3,8(sp)
    800026aa:	6145                	addi	sp,sp,48
    800026ac:	8082                	ret
                p->state = RUNNABLE;
    800026ae:	478d                	li	a5,3
    800026b0:	cc9c                	sw	a5,24(s1)
    800026b2:	b7cd                	j	80002694 <kill+0x52>

00000000800026b4 <setkilled>:

void setkilled(struct proc *p)
{
    800026b4:	1101                	addi	sp,sp,-32
    800026b6:	ec06                	sd	ra,24(sp)
    800026b8:	e822                	sd	s0,16(sp)
    800026ba:	e426                	sd	s1,8(sp)
    800026bc:	1000                	addi	s0,sp,32
    800026be:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	516080e7          	jalr	1302(ra) # 80000bd6 <acquire>
    p->killed = 1;
    800026c8:	4785                	li	a5,1
    800026ca:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800026cc:	8526                	mv	a0,s1
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	5bc080e7          	jalr	1468(ra) # 80000c8a <release>
}
    800026d6:	60e2                	ld	ra,24(sp)
    800026d8:	6442                	ld	s0,16(sp)
    800026da:	64a2                	ld	s1,8(sp)
    800026dc:	6105                	addi	sp,sp,32
    800026de:	8082                	ret

00000000800026e0 <killed>:

int killed(struct proc *p)
{
    800026e0:	1101                	addi	sp,sp,-32
    800026e2:	ec06                	sd	ra,24(sp)
    800026e4:	e822                	sd	s0,16(sp)
    800026e6:	e426                	sd	s1,8(sp)
    800026e8:	e04a                	sd	s2,0(sp)
    800026ea:	1000                	addi	s0,sp,32
    800026ec:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	4e8080e7          	jalr	1256(ra) # 80000bd6 <acquire>
    k = p->killed;
    800026f6:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    800026fa:	8526                	mv	a0,s1
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	58e080e7          	jalr	1422(ra) # 80000c8a <release>
    return k;
}
    80002704:	854a                	mv	a0,s2
    80002706:	60e2                	ld	ra,24(sp)
    80002708:	6442                	ld	s0,16(sp)
    8000270a:	64a2                	ld	s1,8(sp)
    8000270c:	6902                	ld	s2,0(sp)
    8000270e:	6105                	addi	sp,sp,32
    80002710:	8082                	ret

0000000080002712 <wait>:
{
    80002712:	715d                	addi	sp,sp,-80
    80002714:	e486                	sd	ra,72(sp)
    80002716:	e0a2                	sd	s0,64(sp)
    80002718:	fc26                	sd	s1,56(sp)
    8000271a:	f84a                	sd	s2,48(sp)
    8000271c:	f44e                	sd	s3,40(sp)
    8000271e:	f052                	sd	s4,32(sp)
    80002720:	ec56                	sd	s5,24(sp)
    80002722:	e85a                	sd	s6,16(sp)
    80002724:	e45e                	sd	s7,8(sp)
    80002726:	e062                	sd	s8,0(sp)
    80002728:	0880                	addi	s0,sp,80
    8000272a:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	556080e7          	jalr	1366(ra) # 80001c82 <myproc>
    80002734:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002736:	0000f517          	auipc	a0,0xf
    8000273a:	9aa50513          	addi	a0,a0,-1622 # 800110e0 <wait_lock>
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	498080e7          	jalr	1176(ra) # 80000bd6 <acquire>
        havekids = 0;
    80002746:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002748:	4a15                	li	s4,5
                havekids = 1;
    8000274a:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000274c:	00014997          	auipc	s3,0x14
    80002750:	5ac98993          	addi	s3,s3,1452 # 80016cf8 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002754:	0000fc17          	auipc	s8,0xf
    80002758:	98cc0c13          	addi	s8,s8,-1652 # 800110e0 <wait_lock>
        havekids = 0;
    8000275c:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000275e:	0000f497          	auipc	s1,0xf
    80002762:	99a48493          	addi	s1,s1,-1638 # 800110f8 <proc>
    80002766:	a0bd                	j	800027d4 <wait+0xc2>
                    pid = pp->pid;
    80002768:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000276c:	000b0e63          	beqz	s6,80002788 <wait+0x76>
    80002770:	4691                	li	a3,4
    80002772:	02c48613          	addi	a2,s1,44
    80002776:	85da                	mv	a1,s6
    80002778:	05893503          	ld	a0,88(s2)
    8000277c:	fffff097          	auipc	ra,0xfffff
    80002780:	ef0080e7          	jalr	-272(ra) # 8000166c <copyout>
    80002784:	02054563          	bltz	a0,800027ae <wait+0x9c>
                    freeproc(pp);
    80002788:	8526                	mv	a0,s1
    8000278a:	fffff097          	auipc	ra,0xfffff
    8000278e:	6aa080e7          	jalr	1706(ra) # 80001e34 <freeproc>
                    release(&pp->lock);
    80002792:	8526                	mv	a0,s1
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	4f6080e7          	jalr	1270(ra) # 80000c8a <release>
                    release(&wait_lock);
    8000279c:	0000f517          	auipc	a0,0xf
    800027a0:	94450513          	addi	a0,a0,-1724 # 800110e0 <wait_lock>
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	4e6080e7          	jalr	1254(ra) # 80000c8a <release>
                    return pid;
    800027ac:	a0b5                	j	80002818 <wait+0x106>
                        release(&pp->lock);
    800027ae:	8526                	mv	a0,s1
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	4da080e7          	jalr	1242(ra) # 80000c8a <release>
                        release(&wait_lock);
    800027b8:	0000f517          	auipc	a0,0xf
    800027bc:	92850513          	addi	a0,a0,-1752 # 800110e0 <wait_lock>
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	4ca080e7          	jalr	1226(ra) # 80000c8a <release>
                        return -1;
    800027c8:	59fd                	li	s3,-1
    800027ca:	a0b9                	j	80002818 <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027cc:	17048493          	addi	s1,s1,368
    800027d0:	03348463          	beq	s1,s3,800027f8 <wait+0xe6>
            if (pp->parent == p)
    800027d4:	60bc                	ld	a5,64(s1)
    800027d6:	ff279be3          	bne	a5,s2,800027cc <wait+0xba>
                acquire(&pp->lock);
    800027da:	8526                	mv	a0,s1
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	3fa080e7          	jalr	1018(ra) # 80000bd6 <acquire>
                if (pp->state == ZOMBIE)
    800027e4:	4c9c                	lw	a5,24(s1)
    800027e6:	f94781e3          	beq	a5,s4,80002768 <wait+0x56>
                release(&pp->lock);
    800027ea:	8526                	mv	a0,s1
    800027ec:	ffffe097          	auipc	ra,0xffffe
    800027f0:	49e080e7          	jalr	1182(ra) # 80000c8a <release>
                havekids = 1;
    800027f4:	8756                	mv	a4,s5
    800027f6:	bfd9                	j	800027cc <wait+0xba>
        if (!havekids || killed(p))
    800027f8:	c719                	beqz	a4,80002806 <wait+0xf4>
    800027fa:	854a                	mv	a0,s2
    800027fc:	00000097          	auipc	ra,0x0
    80002800:	ee4080e7          	jalr	-284(ra) # 800026e0 <killed>
    80002804:	c51d                	beqz	a0,80002832 <wait+0x120>
            release(&wait_lock);
    80002806:	0000f517          	auipc	a0,0xf
    8000280a:	8da50513          	addi	a0,a0,-1830 # 800110e0 <wait_lock>
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	47c080e7          	jalr	1148(ra) # 80000c8a <release>
            return -1;
    80002816:	59fd                	li	s3,-1
}
    80002818:	854e                	mv	a0,s3
    8000281a:	60a6                	ld	ra,72(sp)
    8000281c:	6406                	ld	s0,64(sp)
    8000281e:	74e2                	ld	s1,56(sp)
    80002820:	7942                	ld	s2,48(sp)
    80002822:	79a2                	ld	s3,40(sp)
    80002824:	7a02                	ld	s4,32(sp)
    80002826:	6ae2                	ld	s5,24(sp)
    80002828:	6b42                	ld	s6,16(sp)
    8000282a:	6ba2                	ld	s7,8(sp)
    8000282c:	6c02                	ld	s8,0(sp)
    8000282e:	6161                	addi	sp,sp,80
    80002830:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002832:	85e2                	mv	a1,s8
    80002834:	854a                	mv	a0,s2
    80002836:	00000097          	auipc	ra,0x0
    8000283a:	c02080e7          	jalr	-1022(ra) # 80002438 <sleep>
        havekids = 0;
    8000283e:	bf39                	j	8000275c <wait+0x4a>

0000000080002840 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002840:	7179                	addi	sp,sp,-48
    80002842:	f406                	sd	ra,40(sp)
    80002844:	f022                	sd	s0,32(sp)
    80002846:	ec26                	sd	s1,24(sp)
    80002848:	e84a                	sd	s2,16(sp)
    8000284a:	e44e                	sd	s3,8(sp)
    8000284c:	e052                	sd	s4,0(sp)
    8000284e:	1800                	addi	s0,sp,48
    80002850:	84aa                	mv	s1,a0
    80002852:	892e                	mv	s2,a1
    80002854:	89b2                	mv	s3,a2
    80002856:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002858:	fffff097          	auipc	ra,0xfffff
    8000285c:	42a080e7          	jalr	1066(ra) # 80001c82 <myproc>
    if (user_dst)
    80002860:	c08d                	beqz	s1,80002882 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002862:	86d2                	mv	a3,s4
    80002864:	864e                	mv	a2,s3
    80002866:	85ca                	mv	a1,s2
    80002868:	6d28                	ld	a0,88(a0)
    8000286a:	fffff097          	auipc	ra,0xfffff
    8000286e:	e02080e7          	jalr	-510(ra) # 8000166c <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002872:	70a2                	ld	ra,40(sp)
    80002874:	7402                	ld	s0,32(sp)
    80002876:	64e2                	ld	s1,24(sp)
    80002878:	6942                	ld	s2,16(sp)
    8000287a:	69a2                	ld	s3,8(sp)
    8000287c:	6a02                	ld	s4,0(sp)
    8000287e:	6145                	addi	sp,sp,48
    80002880:	8082                	ret
        memmove((char *)dst, src, len);
    80002882:	000a061b          	sext.w	a2,s4
    80002886:	85ce                	mv	a1,s3
    80002888:	854a                	mv	a0,s2
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	4a4080e7          	jalr	1188(ra) # 80000d2e <memmove>
        return 0;
    80002892:	8526                	mv	a0,s1
    80002894:	bff9                	j	80002872 <either_copyout+0x32>

0000000080002896 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002896:	7179                	addi	sp,sp,-48
    80002898:	f406                	sd	ra,40(sp)
    8000289a:	f022                	sd	s0,32(sp)
    8000289c:	ec26                	sd	s1,24(sp)
    8000289e:	e84a                	sd	s2,16(sp)
    800028a0:	e44e                	sd	s3,8(sp)
    800028a2:	e052                	sd	s4,0(sp)
    800028a4:	1800                	addi	s0,sp,48
    800028a6:	892a                	mv	s2,a0
    800028a8:	84ae                	mv	s1,a1
    800028aa:	89b2                	mv	s3,a2
    800028ac:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	3d4080e7          	jalr	980(ra) # 80001c82 <myproc>
    if (user_src)
    800028b6:	c08d                	beqz	s1,800028d8 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    800028b8:	86d2                	mv	a3,s4
    800028ba:	864e                	mv	a2,s3
    800028bc:	85ca                	mv	a1,s2
    800028be:	6d28                	ld	a0,88(a0)
    800028c0:	fffff097          	auipc	ra,0xfffff
    800028c4:	e38080e7          	jalr	-456(ra) # 800016f8 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    800028c8:	70a2                	ld	ra,40(sp)
    800028ca:	7402                	ld	s0,32(sp)
    800028cc:	64e2                	ld	s1,24(sp)
    800028ce:	6942                	ld	s2,16(sp)
    800028d0:	69a2                	ld	s3,8(sp)
    800028d2:	6a02                	ld	s4,0(sp)
    800028d4:	6145                	addi	sp,sp,48
    800028d6:	8082                	ret
        memmove(dst, (char *)src, len);
    800028d8:	000a061b          	sext.w	a2,s4
    800028dc:	85ce                	mv	a1,s3
    800028de:	854a                	mv	a0,s2
    800028e0:	ffffe097          	auipc	ra,0xffffe
    800028e4:	44e080e7          	jalr	1102(ra) # 80000d2e <memmove>
        return 0;
    800028e8:	8526                	mv	a0,s1
    800028ea:	bff9                	j	800028c8 <either_copyin+0x32>

00000000800028ec <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800028ec:	715d                	addi	sp,sp,-80
    800028ee:	e486                	sd	ra,72(sp)
    800028f0:	e0a2                	sd	s0,64(sp)
    800028f2:	fc26                	sd	s1,56(sp)
    800028f4:	f84a                	sd	s2,48(sp)
    800028f6:	f44e                	sd	s3,40(sp)
    800028f8:	f052                	sd	s4,32(sp)
    800028fa:	ec56                	sd	s5,24(sp)
    800028fc:	e85a                	sd	s6,16(sp)
    800028fe:	e45e                	sd	s7,8(sp)
    80002900:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002902:	00005517          	auipc	a0,0x5
    80002906:	7c650513          	addi	a0,a0,1990 # 800080c8 <digits+0x88>
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	c80080e7          	jalr	-896(ra) # 8000058a <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002912:	0000f497          	auipc	s1,0xf
    80002916:	94648493          	addi	s1,s1,-1722 # 80011258 <proc+0x160>
    8000291a:	00014917          	auipc	s2,0x14
    8000291e:	53e90913          	addi	s2,s2,1342 # 80016e58 <bcache+0x148>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002922:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002924:	00006997          	auipc	s3,0x6
    80002928:	96498993          	addi	s3,s3,-1692 # 80008288 <digits+0x248>
        printf("%d <%s %s", p->pid, state, p->name);
    8000292c:	00006a97          	auipc	s5,0x6
    80002930:	964a8a93          	addi	s5,s5,-1692 # 80008290 <digits+0x250>
        printf("\n");
    80002934:	00005a17          	auipc	s4,0x5
    80002938:	794a0a13          	addi	s4,s4,1940 # 800080c8 <digits+0x88>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000293c:	00006b97          	auipc	s7,0x6
    80002940:	a64b8b93          	addi	s7,s7,-1436 # 800083a0 <quantum>
    80002944:	a00d                	j	80002966 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002946:	ed06a583          	lw	a1,-304(a3)
    8000294a:	8556                	mv	a0,s5
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	c3e080e7          	jalr	-962(ra) # 8000058a <printf>
        printf("\n");
    80002954:	8552                	mv	a0,s4
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	c34080e7          	jalr	-972(ra) # 8000058a <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    8000295e:	17048493          	addi	s1,s1,368
    80002962:	03248263          	beq	s1,s2,80002986 <procdump+0x9a>
        if (p->state == UNUSED)
    80002966:	86a6                	mv	a3,s1
    80002968:	eb84a783          	lw	a5,-328(s1)
    8000296c:	dbed                	beqz	a5,8000295e <procdump+0x72>
            state = "???";
    8000296e:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002970:	fcfb6be3          	bltu	s6,a5,80002946 <procdump+0x5a>
    80002974:	02079713          	slli	a4,a5,0x20
    80002978:	01d75793          	srli	a5,a4,0x1d
    8000297c:	97de                	add	a5,a5,s7
    8000297e:	6b90                	ld	a2,16(a5)
    80002980:	f279                	bnez	a2,80002946 <procdump+0x5a>
            state = "???";
    80002982:	864e                	mv	a2,s3
    80002984:	b7c9                	j	80002946 <procdump+0x5a>
    }
}
    80002986:	60a6                	ld	ra,72(sp)
    80002988:	6406                	ld	s0,64(sp)
    8000298a:	74e2                	ld	s1,56(sp)
    8000298c:	7942                	ld	s2,48(sp)
    8000298e:	79a2                	ld	s3,40(sp)
    80002990:	7a02                	ld	s4,32(sp)
    80002992:	6ae2                	ld	s5,24(sp)
    80002994:	6b42                	ld	s6,16(sp)
    80002996:	6ba2                	ld	s7,8(sp)
    80002998:	6161                	addi	sp,sp,80
    8000299a:	8082                	ret

000000008000299c <schedls>:

void schedls()
{
    8000299c:	1101                	addi	sp,sp,-32
    8000299e:	ec06                	sd	ra,24(sp)
    800029a0:	e822                	sd	s0,16(sp)
    800029a2:	e426                	sd	s1,8(sp)
    800029a4:	1000                	addi	s0,sp,32
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    800029a6:	00006517          	auipc	a0,0x6
    800029aa:	8fa50513          	addi	a0,a0,-1798 # 800082a0 <digits+0x260>
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	bdc080e7          	jalr	-1060(ra) # 8000058a <printf>
    printf("====================================\n");
    800029b6:	00006517          	auipc	a0,0x6
    800029ba:	91250513          	addi	a0,a0,-1774 # 800082c8 <digits+0x288>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	bcc080e7          	jalr	-1076(ra) # 8000058a <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    800029c6:	00006717          	auipc	a4,0x6
    800029ca:	ff273703          	ld	a4,-14(a4) # 800089b8 <available_schedulers+0x10>
    800029ce:	00006797          	auipc	a5,0x6
    800029d2:	f8a7b783          	ld	a5,-118(a5) # 80008958 <sched_pointer>
    800029d6:	08f70763          	beq	a4,a5,80002a64 <schedls+0xc8>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    800029da:	00006517          	auipc	a0,0x6
    800029de:	91650513          	addi	a0,a0,-1770 # 800082f0 <digits+0x2b0>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	ba8080e7          	jalr	-1112(ra) # 8000058a <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    800029ea:	00006497          	auipc	s1,0x6
    800029ee:	f8648493          	addi	s1,s1,-122 # 80008970 <initcode>
    800029f2:	48b0                	lw	a2,80(s1)
    800029f4:	00006597          	auipc	a1,0x6
    800029f8:	fb458593          	addi	a1,a1,-76 # 800089a8 <available_schedulers>
    800029fc:	00006517          	auipc	a0,0x6
    80002a00:	90450513          	addi	a0,a0,-1788 # 80008300 <digits+0x2c0>
    80002a04:	ffffe097          	auipc	ra,0xffffe
    80002a08:	b86080e7          	jalr	-1146(ra) # 8000058a <printf>
        if (available_schedulers[i].impl == sched_pointer)
    80002a0c:	74b8                	ld	a4,104(s1)
    80002a0e:	00006797          	auipc	a5,0x6
    80002a12:	f4a7b783          	ld	a5,-182(a5) # 80008958 <sched_pointer>
    80002a16:	06f70063          	beq	a4,a5,80002a76 <schedls+0xda>
            printf("   \t");
    80002a1a:	00006517          	auipc	a0,0x6
    80002a1e:	8d650513          	addi	a0,a0,-1834 # 800082f0 <digits+0x2b0>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	b68080e7          	jalr	-1176(ra) # 8000058a <printf>
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002a2a:	00006617          	auipc	a2,0x6
    80002a2e:	fb662603          	lw	a2,-74(a2) # 800089e0 <available_schedulers+0x38>
    80002a32:	00006597          	auipc	a1,0x6
    80002a36:	f9658593          	addi	a1,a1,-106 # 800089c8 <available_schedulers+0x20>
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	8c650513          	addi	a0,a0,-1850 # 80008300 <digits+0x2c0>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b48080e7          	jalr	-1208(ra) # 8000058a <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	8be50513          	addi	a0,a0,-1858 # 80008308 <digits+0x2c8>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b38080e7          	jalr	-1224(ra) # 8000058a <printf>
}
    80002a5a:	60e2                	ld	ra,24(sp)
    80002a5c:	6442                	ld	s0,16(sp)
    80002a5e:	64a2                	ld	s1,8(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret
            printf("[*]\t");
    80002a64:	00006517          	auipc	a0,0x6
    80002a68:	89450513          	addi	a0,a0,-1900 # 800082f8 <digits+0x2b8>
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	b1e080e7          	jalr	-1250(ra) # 8000058a <printf>
    80002a74:	bf9d                	j	800029ea <schedls+0x4e>
    80002a76:	00006517          	auipc	a0,0x6
    80002a7a:	88250513          	addi	a0,a0,-1918 # 800082f8 <digits+0x2b8>
    80002a7e:	ffffe097          	auipc	ra,0xffffe
    80002a82:	b0c080e7          	jalr	-1268(ra) # 8000058a <printf>
    80002a86:	b755                	j	80002a2a <schedls+0x8e>

0000000080002a88 <schedset>:

void schedset(int id)
{
    80002a88:	1141                	addi	sp,sp,-16
    80002a8a:	e406                	sd	ra,8(sp)
    80002a8c:	e022                	sd	s0,0(sp)
    80002a8e:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002a90:	4705                	li	a4,1
    80002a92:	02a76f63          	bltu	a4,a0,80002ad0 <schedset+0x48>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002a96:	00551793          	slli	a5,a0,0x5
    80002a9a:	00006717          	auipc	a4,0x6
    80002a9e:	ed670713          	addi	a4,a4,-298 # 80008970 <initcode>
    80002aa2:	973e                	add	a4,a4,a5
    80002aa4:	6738                	ld	a4,72(a4)
    80002aa6:	00006697          	auipc	a3,0x6
    80002aaa:	eae6b923          	sd	a4,-334(a3) # 80008958 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002aae:	00006597          	auipc	a1,0x6
    80002ab2:	efa58593          	addi	a1,a1,-262 # 800089a8 <available_schedulers>
    80002ab6:	95be                	add	a1,a1,a5
    80002ab8:	00006517          	auipc	a0,0x6
    80002abc:	89050513          	addi	a0,a0,-1904 # 80008348 <digits+0x308>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	aca080e7          	jalr	-1334(ra) # 8000058a <printf>
}
    80002ac8:	60a2                	ld	ra,8(sp)
    80002aca:	6402                	ld	s0,0(sp)
    80002acc:	0141                	addi	sp,sp,16
    80002ace:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002ad0:	00006517          	auipc	a0,0x6
    80002ad4:	85050513          	addi	a0,a0,-1968 # 80008320 <digits+0x2e0>
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	ab2080e7          	jalr	-1358(ra) # 8000058a <printf>
        return;
    80002ae0:	b7e5                	j	80002ac8 <schedset+0x40>

0000000080002ae2 <swtch>:
    80002ae2:	00153023          	sd	ra,0(a0)
    80002ae6:	00253423          	sd	sp,8(a0)
    80002aea:	e900                	sd	s0,16(a0)
    80002aec:	ed04                	sd	s1,24(a0)
    80002aee:	03253023          	sd	s2,32(a0)
    80002af2:	03353423          	sd	s3,40(a0)
    80002af6:	03453823          	sd	s4,48(a0)
    80002afa:	03553c23          	sd	s5,56(a0)
    80002afe:	05653023          	sd	s6,64(a0)
    80002b02:	05753423          	sd	s7,72(a0)
    80002b06:	05853823          	sd	s8,80(a0)
    80002b0a:	05953c23          	sd	s9,88(a0)
    80002b0e:	07a53023          	sd	s10,96(a0)
    80002b12:	07b53423          	sd	s11,104(a0)
    80002b16:	0005b083          	ld	ra,0(a1)
    80002b1a:	0085b103          	ld	sp,8(a1)
    80002b1e:	6980                	ld	s0,16(a1)
    80002b20:	6d84                	ld	s1,24(a1)
    80002b22:	0205b903          	ld	s2,32(a1)
    80002b26:	0285b983          	ld	s3,40(a1)
    80002b2a:	0305ba03          	ld	s4,48(a1)
    80002b2e:	0385ba83          	ld	s5,56(a1)
    80002b32:	0405bb03          	ld	s6,64(a1)
    80002b36:	0485bb83          	ld	s7,72(a1)
    80002b3a:	0505bc03          	ld	s8,80(a1)
    80002b3e:	0585bc83          	ld	s9,88(a1)
    80002b42:	0605bd03          	ld	s10,96(a1)
    80002b46:	0685bd83          	ld	s11,104(a1)
    80002b4a:	8082                	ret

0000000080002b4c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002b4c:	1141                	addi	sp,sp,-16
    80002b4e:	e406                	sd	ra,8(sp)
    80002b50:	e022                	sd	s0,0(sp)
    80002b52:	0800                	addi	s0,sp,16
    initlock(&tickslock, "time");
    80002b54:	00006597          	auipc	a1,0x6
    80002b58:	88c58593          	addi	a1,a1,-1908 # 800083e0 <states.0+0x30>
    80002b5c:	00014517          	auipc	a0,0x14
    80002b60:	19c50513          	addi	a0,a0,412 # 80016cf8 <tickslock>
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	fe2080e7          	jalr	-30(ra) # 80000b46 <initlock>
}
    80002b6c:	60a2                	ld	ra,8(sp)
    80002b6e:	6402                	ld	s0,0(sp)
    80002b70:	0141                	addi	sp,sp,16
    80002b72:	8082                	ret

0000000080002b74 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002b74:	1141                	addi	sp,sp,-16
    80002b76:	e422                	sd	s0,8(sp)
    80002b78:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b7a:	00003797          	auipc	a5,0x3
    80002b7e:	58678793          	addi	a5,a5,1414 # 80006100 <kernelvec>
    80002b82:	10579073          	csrw	stvec,a5
    w_stvec((uint64)kernelvec);
}
    80002b86:	6422                	ld	s0,8(sp)
    80002b88:	0141                	addi	sp,sp,16
    80002b8a:	8082                	ret

0000000080002b8c <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002b8c:	1141                	addi	sp,sp,-16
    80002b8e:	e406                	sd	ra,8(sp)
    80002b90:	e022                	sd	s0,0(sp)
    80002b92:	0800                	addi	s0,sp,16
    struct proc *p = myproc();
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	0ee080e7          	jalr	238(ra) # 80001c82 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba2:	10079073          	csrw	sstatus,a5
    // kerneltrap() to usertrap(), so turn off interrupts until
    // we're back in user space, where usertrap() is correct.
    intr_off();

    // send syscalls, interrupts, and exceptions to uservec in trampoline.S
    uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ba6:	00004697          	auipc	a3,0x4
    80002baa:	45a68693          	addi	a3,a3,1114 # 80007000 <_trampoline>
    80002bae:	00004717          	auipc	a4,0x4
    80002bb2:	45270713          	addi	a4,a4,1106 # 80007000 <_trampoline>
    80002bb6:	8f15                	sub	a4,a4,a3
    80002bb8:	040007b7          	lui	a5,0x4000
    80002bbc:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002bbe:	07b2                	slli	a5,a5,0xc
    80002bc0:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bc2:	10571073          	csrw	stvec,a4
    w_stvec(trampoline_uservec);

    // set up trapframe values that uservec will need when
    // the process next traps into the kernel.
    p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002bc6:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002bc8:	18002673          	csrr	a2,satp
    80002bcc:	e310                	sd	a2,0(a4)
    p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002bce:	7130                	ld	a2,96(a0)
    80002bd0:	6538                	ld	a4,72(a0)
    80002bd2:	6585                	lui	a1,0x1
    80002bd4:	972e                	add	a4,a4,a1
    80002bd6:	e618                	sd	a4,8(a2)
    p->trapframe->kernel_trap = (uint64)usertrap;
    80002bd8:	7138                	ld	a4,96(a0)
    80002bda:	00000617          	auipc	a2,0x0
    80002bde:	13060613          	addi	a2,a2,304 # 80002d0a <usertrap>
    80002be2:	eb10                	sd	a2,16(a4)
    p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002be4:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002be6:	8612                	mv	a2,tp
    80002be8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bea:	10002773          	csrr	a4,sstatus
    // set up the registers that trampoline.S's sret will use
    // to get to user space.

    // set S Previous Privilege mode to User.
    unsigned long x = r_sstatus();
    x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002bee:	eff77713          	andi	a4,a4,-257
    x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002bf2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bf6:	10071073          	csrw	sstatus,a4
    w_sstatus(x);

    // set S Exception Program Counter to the saved user pc.
    w_sepc(p->trapframe->epc);
    80002bfa:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bfc:	6f18                	ld	a4,24(a4)
    80002bfe:	14171073          	csrw	sepc,a4

    // tell trampoline.S the user page table to switch to.
    uint64 satp = MAKE_SATP(p->pagetable);
    80002c02:	6d28                	ld	a0,88(a0)
    80002c04:	8131                	srli	a0,a0,0xc

    // jump to userret in trampoline.S at the top of memory, which
    // switches to the user page table, restores user registers,
    // and switches to user mode with sret.
    uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c06:	00004717          	auipc	a4,0x4
    80002c0a:	49670713          	addi	a4,a4,1174 # 8000709c <userret>
    80002c0e:	8f15                	sub	a4,a4,a3
    80002c10:	97ba                	add	a5,a5,a4
    ((void (*)(uint64))trampoline_userret)(satp);
    80002c12:	577d                	li	a4,-1
    80002c14:	177e                	slli	a4,a4,0x3f
    80002c16:	8d59                	or	a0,a0,a4
    80002c18:	9782                	jalr	a5
}
    80002c1a:	60a2                	ld	ra,8(sp)
    80002c1c:	6402                	ld	s0,0(sp)
    80002c1e:	0141                	addi	sp,sp,16
    80002c20:	8082                	ret

0000000080002c22 <clockintr>:
    w_sepc(sepc);
    w_sstatus(sstatus);
}

void clockintr()
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	e426                	sd	s1,8(sp)
    80002c2a:	1000                	addi	s0,sp,32
    acquire(&tickslock);
    80002c2c:	00014497          	auipc	s1,0x14
    80002c30:	0cc48493          	addi	s1,s1,204 # 80016cf8 <tickslock>
    80002c34:	8526                	mv	a0,s1
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	fa0080e7          	jalr	-96(ra) # 80000bd6 <acquire>
    ticks++;
    80002c3e:	00006517          	auipc	a0,0x6
    80002c42:	e0250513          	addi	a0,a0,-510 # 80008a40 <ticks>
    80002c46:	411c                	lw	a5,0(a0)
    80002c48:	2785                	addiw	a5,a5,1
    80002c4a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002c4c:	00000097          	auipc	ra,0x0
    80002c50:	850080e7          	jalr	-1968(ra) # 8000249c <wakeup>
    release(&tickslock);
    80002c54:	8526                	mv	a0,s1
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	034080e7          	jalr	52(ra) # 80000c8a <release>
}
    80002c5e:	60e2                	ld	ra,24(sp)
    80002c60:	6442                	ld	s0,16(sp)
    80002c62:	64a2                	ld	s1,8(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret

0000000080002c68 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c72:	14202773          	csrr	a4,scause
    uint64 scause = r_scause();

    if ((scause & 0x8000000000000000L) &&
    80002c76:	00074d63          	bltz	a4,80002c90 <devintr+0x28>
        if (irq)
            plic_complete(irq);

        return 1;
    }
    else if (scause == 0x8000000000000001L)
    80002c7a:	57fd                	li	a5,-1
    80002c7c:	17fe                	slli	a5,a5,0x3f
    80002c7e:	0785                	addi	a5,a5,1

        return 2;
    }
    else
    {
        return 0;
    80002c80:	4501                	li	a0,0
    else if (scause == 0x8000000000000001L)
    80002c82:	06f70363          	beq	a4,a5,80002ce8 <devintr+0x80>
    }
}
    80002c86:	60e2                	ld	ra,24(sp)
    80002c88:	6442                	ld	s0,16(sp)
    80002c8a:	64a2                	ld	s1,8(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret
        (scause & 0xff) == 9)
    80002c90:	0ff77793          	zext.b	a5,a4
    if ((scause & 0x8000000000000000L) &&
    80002c94:	46a5                	li	a3,9
    80002c96:	fed792e3          	bne	a5,a3,80002c7a <devintr+0x12>
        int irq = plic_claim();
    80002c9a:	00003097          	auipc	ra,0x3
    80002c9e:	56e080e7          	jalr	1390(ra) # 80006208 <plic_claim>
    80002ca2:	84aa                	mv	s1,a0
        if (irq == UART0_IRQ)
    80002ca4:	47a9                	li	a5,10
    80002ca6:	02f50763          	beq	a0,a5,80002cd4 <devintr+0x6c>
        else if (irq == VIRTIO0_IRQ)
    80002caa:	4785                	li	a5,1
    80002cac:	02f50963          	beq	a0,a5,80002cde <devintr+0x76>
        return 1;
    80002cb0:	4505                	li	a0,1
        else if (irq)
    80002cb2:	d8f1                	beqz	s1,80002c86 <devintr+0x1e>
            printf("unexpected interrupt irq=%d\n", irq);
    80002cb4:	85a6                	mv	a1,s1
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	73250513          	addi	a0,a0,1842 # 800083e8 <states.0+0x38>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	8cc080e7          	jalr	-1844(ra) # 8000058a <printf>
            plic_complete(irq);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	00003097          	auipc	ra,0x3
    80002ccc:	564080e7          	jalr	1380(ra) # 8000622c <plic_complete>
        return 1;
    80002cd0:	4505                	li	a0,1
    80002cd2:	bf55                	j	80002c86 <devintr+0x1e>
            uartintr();
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	cc4080e7          	jalr	-828(ra) # 80000998 <uartintr>
    80002cdc:	b7ed                	j	80002cc6 <devintr+0x5e>
            virtio_disk_intr();
    80002cde:	00004097          	auipc	ra,0x4
    80002ce2:	a16080e7          	jalr	-1514(ra) # 800066f4 <virtio_disk_intr>
    80002ce6:	b7c5                	j	80002cc6 <devintr+0x5e>
        if (cpuid() == 0)
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	f6e080e7          	jalr	-146(ra) # 80001c56 <cpuid>
    80002cf0:	c901                	beqz	a0,80002d00 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002cf2:	144027f3          	csrr	a5,sip
        w_sip(r_sip() & ~2);
    80002cf6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002cf8:	14479073          	csrw	sip,a5
        return 2;
    80002cfc:	4509                	li	a0,2
    80002cfe:	b761                	j	80002c86 <devintr+0x1e>
            clockintr();
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	f22080e7          	jalr	-222(ra) # 80002c22 <clockintr>
    80002d08:	b7ed                	j	80002cf2 <devintr+0x8a>

0000000080002d0a <usertrap>:
{
    80002d0a:	1101                	addi	sp,sp,-32
    80002d0c:	ec06                	sd	ra,24(sp)
    80002d0e:	e822                	sd	s0,16(sp)
    80002d10:	e426                	sd	s1,8(sp)
    80002d12:	e04a                	sd	s2,0(sp)
    80002d14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d16:	100027f3          	csrr	a5,sstatus
    if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002d1a:	1007f793          	andi	a5,a5,256
    80002d1e:	e3b1                	bnez	a5,80002d62 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d20:	00003797          	auipc	a5,0x3
    80002d24:	3e078793          	addi	a5,a5,992 # 80006100 <kernelvec>
    80002d28:	10579073          	csrw	stvec,a5
    struct proc *p = myproc();
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	f56080e7          	jalr	-170(ra) # 80001c82 <myproc>
    80002d34:	84aa                	mv	s1,a0
    p->trapframe->epc = r_sepc();
    80002d36:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d38:	14102773          	csrr	a4,sepc
    80002d3c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d3e:	14202773          	csrr	a4,scause
    if (r_scause() == 8)
    80002d42:	47a1                	li	a5,8
    80002d44:	02f70763          	beq	a4,a5,80002d72 <usertrap+0x68>
    else if ((which_dev = devintr()) != 0)
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	f20080e7          	jalr	-224(ra) # 80002c68 <devintr>
    80002d50:	892a                	mv	s2,a0
    80002d52:	c92d                	beqz	a0,80002dc4 <usertrap+0xba>
    if (killed(p))
    80002d54:	8526                	mv	a0,s1
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	98a080e7          	jalr	-1654(ra) # 800026e0 <killed>
    80002d5e:	c555                	beqz	a0,80002e0a <usertrap+0x100>
    80002d60:	a045                	j	80002e00 <usertrap+0xf6>
        panic("usertrap: not from user mode");
    80002d62:	00005517          	auipc	a0,0x5
    80002d66:	6a650513          	addi	a0,a0,1702 # 80008408 <states.0+0x58>
    80002d6a:	ffffd097          	auipc	ra,0xffffd
    80002d6e:	7d6080e7          	jalr	2006(ra) # 80000540 <panic>
        if (killed(p))
    80002d72:	00000097          	auipc	ra,0x0
    80002d76:	96e080e7          	jalr	-1682(ra) # 800026e0 <killed>
    80002d7a:	ed1d                	bnez	a0,80002db8 <usertrap+0xae>
        p->trapframe->epc += 4;
    80002d7c:	70b8                	ld	a4,96(s1)
    80002d7e:	6f1c                	ld	a5,24(a4)
    80002d80:	0791                	addi	a5,a5,4
    80002d82:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d88:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d8c:	10079073          	csrw	sstatus,a5
        syscall();
    80002d90:	00000097          	auipc	ra,0x0
    80002d94:	2e4080e7          	jalr	740(ra) # 80003074 <syscall>
    if (killed(p))
    80002d98:	8526                	mv	a0,s1
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	946080e7          	jalr	-1722(ra) # 800026e0 <killed>
    80002da2:	ed31                	bnez	a0,80002dfe <usertrap+0xf4>
    usertrapret();
    80002da4:	00000097          	auipc	ra,0x0
    80002da8:	de8080e7          	jalr	-536(ra) # 80002b8c <usertrapret>
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6902                	ld	s2,0(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret
            exit(-1);
    80002db8:	557d                	li	a0,-1
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	7b2080e7          	jalr	1970(ra) # 8000256c <exit>
    80002dc2:	bf6d                	j	80002d7c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dc4:	142025f3          	csrr	a1,scause
        printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002dc8:	5890                	lw	a2,48(s1)
    80002dca:	00005517          	auipc	a0,0x5
    80002dce:	65e50513          	addi	a0,a0,1630 # 80008428 <states.0+0x78>
    80002dd2:	ffffd097          	auipc	ra,0xffffd
    80002dd6:	7b8080e7          	jalr	1976(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dda:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dde:	14302673          	csrr	a2,stval
        printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002de2:	00005517          	auipc	a0,0x5
    80002de6:	67650513          	addi	a0,a0,1654 # 80008458 <states.0+0xa8>
    80002dea:	ffffd097          	auipc	ra,0xffffd
    80002dee:	7a0080e7          	jalr	1952(ra) # 8000058a <printf>
        setkilled(p);
    80002df2:	8526                	mv	a0,s1
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	8c0080e7          	jalr	-1856(ra) # 800026b4 <setkilled>
    80002dfc:	bf71                	j	80002d98 <usertrap+0x8e>
    if (killed(p))
    80002dfe:	4901                	li	s2,0
        exit(-1);
    80002e00:	557d                	li	a0,-1
    80002e02:	fffff097          	auipc	ra,0xfffff
    80002e06:	76a080e7          	jalr	1898(ra) # 8000256c <exit>
    if (which_dev == 2)
    80002e0a:	4789                	li	a5,2
    80002e0c:	f8f91ce3          	bne	s2,a5,80002da4 <usertrap+0x9a>
	p->qleft--;
    80002e10:	5c9c                	lw	a5,56(s1)
    80002e12:	37fd                	addiw	a5,a5,-1
    80002e14:	0007871b          	sext.w	a4,a5
    80002e18:	dc9c                	sw	a5,56(s1)
	if (p->qleft == 0)
    80002e1a:	f749                	bnez	a4,80002da4 <usertrap+0x9a>
	    yield(YIELD_TIMER);
    80002e1c:	4505                	li	a0,1
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	5de080e7          	jalr	1502(ra) # 800023fc <yield>
    80002e26:	bfbd                	j	80002da4 <usertrap+0x9a>

0000000080002e28 <kerneltrap>:
{
    80002e28:	7179                	addi	sp,sp,-48
    80002e2a:	f406                	sd	ra,40(sp)
    80002e2c:	f022                	sd	s0,32(sp)
    80002e2e:	ec26                	sd	s1,24(sp)
    80002e30:	e84a                	sd	s2,16(sp)
    80002e32:	e44e                	sd	s3,8(sp)
    80002e34:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e36:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e3a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e3e:	142029f3          	csrr	s3,scause
    if ((sstatus & SSTATUS_SPP) == 0)
    80002e42:	1004f793          	andi	a5,s1,256
    80002e46:	cb85                	beqz	a5,80002e76 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e4c:	8b89                	andi	a5,a5,2
    if (intr_get() != 0)
    80002e4e:	ef85                	bnez	a5,80002e86 <kerneltrap+0x5e>
    if ((which_dev = devintr()) == 0)
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	e18080e7          	jalr	-488(ra) # 80002c68 <devintr>
    80002e58:	cd1d                	beqz	a0,80002e96 <kerneltrap+0x6e>
    if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e5a:	4789                	li	a5,2
    80002e5c:	06f50a63          	beq	a0,a5,80002ed0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e60:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e64:	10049073          	csrw	sstatus,s1
}
    80002e68:	70a2                	ld	ra,40(sp)
    80002e6a:	7402                	ld	s0,32(sp)
    80002e6c:	64e2                	ld	s1,24(sp)
    80002e6e:	6942                	ld	s2,16(sp)
    80002e70:	69a2                	ld	s3,8(sp)
    80002e72:	6145                	addi	sp,sp,48
    80002e74:	8082                	ret
        panic("kerneltrap: not from supervisor mode");
    80002e76:	00005517          	auipc	a0,0x5
    80002e7a:	60250513          	addi	a0,a0,1538 # 80008478 <states.0+0xc8>
    80002e7e:	ffffd097          	auipc	ra,0xffffd
    80002e82:	6c2080e7          	jalr	1730(ra) # 80000540 <panic>
        panic("kerneltrap: interrupts enabled");
    80002e86:	00005517          	auipc	a0,0x5
    80002e8a:	61a50513          	addi	a0,a0,1562 # 800084a0 <states.0+0xf0>
    80002e8e:	ffffd097          	auipc	ra,0xffffd
    80002e92:	6b2080e7          	jalr	1714(ra) # 80000540 <panic>
        printf("scause %p\n", scause);
    80002e96:	85ce                	mv	a1,s3
    80002e98:	00005517          	auipc	a0,0x5
    80002e9c:	62850513          	addi	a0,a0,1576 # 800084c0 <states.0+0x110>
    80002ea0:	ffffd097          	auipc	ra,0xffffd
    80002ea4:	6ea080e7          	jalr	1770(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ea8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002eac:	14302673          	csrr	a2,stval
        printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002eb0:	00005517          	auipc	a0,0x5
    80002eb4:	62050513          	addi	a0,a0,1568 # 800084d0 <states.0+0x120>
    80002eb8:	ffffd097          	auipc	ra,0xffffd
    80002ebc:	6d2080e7          	jalr	1746(ra) # 8000058a <printf>
        panic("kerneltrap");
    80002ec0:	00005517          	auipc	a0,0x5
    80002ec4:	62850513          	addi	a0,a0,1576 # 800084e8 <states.0+0x138>
    80002ec8:	ffffd097          	auipc	ra,0xffffd
    80002ecc:	678080e7          	jalr	1656(ra) # 80000540 <panic>
    if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	db2080e7          	jalr	-590(ra) # 80001c82 <myproc>
    80002ed8:	d541                	beqz	a0,80002e60 <kerneltrap+0x38>
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	da8080e7          	jalr	-600(ra) # 80001c82 <myproc>
    80002ee2:	4d18                	lw	a4,24(a0)
    80002ee4:	4791                	li	a5,4
    80002ee6:	f6f71de3          	bne	a4,a5,80002e60 <kerneltrap+0x38>
        yield(YIELD_OTHER);
    80002eea:	4509                	li	a0,2
    80002eec:	fffff097          	auipc	ra,0xfffff
    80002ef0:	510080e7          	jalr	1296(ra) # 800023fc <yield>
    80002ef4:	b7b5                	j	80002e60 <kerneltrap+0x38>

0000000080002ef6 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ef6:	1101                	addi	sp,sp,-32
    80002ef8:	ec06                	sd	ra,24(sp)
    80002efa:	e822                	sd	s0,16(sp)
    80002efc:	e426                	sd	s1,8(sp)
    80002efe:	1000                	addi	s0,sp,32
    80002f00:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002f02:	fffff097          	auipc	ra,0xfffff
    80002f06:	d80080e7          	jalr	-640(ra) # 80001c82 <myproc>
    switch (n)
    80002f0a:	4795                	li	a5,5
    80002f0c:	0497e163          	bltu	a5,s1,80002f4e <argraw+0x58>
    80002f10:	048a                	slli	s1,s1,0x2
    80002f12:	00005717          	auipc	a4,0x5
    80002f16:	60e70713          	addi	a4,a4,1550 # 80008520 <states.0+0x170>
    80002f1a:	94ba                	add	s1,s1,a4
    80002f1c:	409c                	lw	a5,0(s1)
    80002f1e:	97ba                	add	a5,a5,a4
    80002f20:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002f22:	713c                	ld	a5,96(a0)
    80002f24:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002f26:	60e2                	ld	ra,24(sp)
    80002f28:	6442                	ld	s0,16(sp)
    80002f2a:	64a2                	ld	s1,8(sp)
    80002f2c:	6105                	addi	sp,sp,32
    80002f2e:	8082                	ret
        return p->trapframe->a1;
    80002f30:	713c                	ld	a5,96(a0)
    80002f32:	7fa8                	ld	a0,120(a5)
    80002f34:	bfcd                	j	80002f26 <argraw+0x30>
        return p->trapframe->a2;
    80002f36:	713c                	ld	a5,96(a0)
    80002f38:	63c8                	ld	a0,128(a5)
    80002f3a:	b7f5                	j	80002f26 <argraw+0x30>
        return p->trapframe->a3;
    80002f3c:	713c                	ld	a5,96(a0)
    80002f3e:	67c8                	ld	a0,136(a5)
    80002f40:	b7dd                	j	80002f26 <argraw+0x30>
        return p->trapframe->a4;
    80002f42:	713c                	ld	a5,96(a0)
    80002f44:	6bc8                	ld	a0,144(a5)
    80002f46:	b7c5                	j	80002f26 <argraw+0x30>
        return p->trapframe->a5;
    80002f48:	713c                	ld	a5,96(a0)
    80002f4a:	6fc8                	ld	a0,152(a5)
    80002f4c:	bfe9                	j	80002f26 <argraw+0x30>
    panic("argraw");
    80002f4e:	00005517          	auipc	a0,0x5
    80002f52:	5aa50513          	addi	a0,a0,1450 # 800084f8 <states.0+0x148>
    80002f56:	ffffd097          	auipc	ra,0xffffd
    80002f5a:	5ea080e7          	jalr	1514(ra) # 80000540 <panic>

0000000080002f5e <fetchaddr>:
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	e04a                	sd	s2,0(sp)
    80002f68:	1000                	addi	s0,sp,32
    80002f6a:	84aa                	mv	s1,a0
    80002f6c:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	d14080e7          	jalr	-748(ra) # 80001c82 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002f76:	693c                	ld	a5,80(a0)
    80002f78:	02f4f863          	bgeu	s1,a5,80002fa8 <fetchaddr+0x4a>
    80002f7c:	00848713          	addi	a4,s1,8
    80002f80:	02e7e663          	bltu	a5,a4,80002fac <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f84:	46a1                	li	a3,8
    80002f86:	8626                	mv	a2,s1
    80002f88:	85ca                	mv	a1,s2
    80002f8a:	6d28                	ld	a0,88(a0)
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	76c080e7          	jalr	1900(ra) # 800016f8 <copyin>
    80002f94:	00a03533          	snez	a0,a0
    80002f98:	40a00533          	neg	a0,a0
}
    80002f9c:	60e2                	ld	ra,24(sp)
    80002f9e:	6442                	ld	s0,16(sp)
    80002fa0:	64a2                	ld	s1,8(sp)
    80002fa2:	6902                	ld	s2,0(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret
        return -1;
    80002fa8:	557d                	li	a0,-1
    80002faa:	bfcd                	j	80002f9c <fetchaddr+0x3e>
    80002fac:	557d                	li	a0,-1
    80002fae:	b7fd                	j	80002f9c <fetchaddr+0x3e>

0000000080002fb0 <fetchstr>:
{
    80002fb0:	7179                	addi	sp,sp,-48
    80002fb2:	f406                	sd	ra,40(sp)
    80002fb4:	f022                	sd	s0,32(sp)
    80002fb6:	ec26                	sd	s1,24(sp)
    80002fb8:	e84a                	sd	s2,16(sp)
    80002fba:	e44e                	sd	s3,8(sp)
    80002fbc:	1800                	addi	s0,sp,48
    80002fbe:	892a                	mv	s2,a0
    80002fc0:	84ae                	mv	s1,a1
    80002fc2:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002fc4:	fffff097          	auipc	ra,0xfffff
    80002fc8:	cbe080e7          	jalr	-834(ra) # 80001c82 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002fcc:	86ce                	mv	a3,s3
    80002fce:	864a                	mv	a2,s2
    80002fd0:	85a6                	mv	a1,s1
    80002fd2:	6d28                	ld	a0,88(a0)
    80002fd4:	ffffe097          	auipc	ra,0xffffe
    80002fd8:	7b2080e7          	jalr	1970(ra) # 80001786 <copyinstr>
    80002fdc:	00054e63          	bltz	a0,80002ff8 <fetchstr+0x48>
    return strlen(buf);
    80002fe0:	8526                	mv	a0,s1
    80002fe2:	ffffe097          	auipc	ra,0xffffe
    80002fe6:	e6c080e7          	jalr	-404(ra) # 80000e4e <strlen>
}
    80002fea:	70a2                	ld	ra,40(sp)
    80002fec:	7402                	ld	s0,32(sp)
    80002fee:	64e2                	ld	s1,24(sp)
    80002ff0:	6942                	ld	s2,16(sp)
    80002ff2:	69a2                	ld	s3,8(sp)
    80002ff4:	6145                	addi	sp,sp,48
    80002ff6:	8082                	ret
        return -1;
    80002ff8:	557d                	li	a0,-1
    80002ffa:	bfc5                	j	80002fea <fetchstr+0x3a>

0000000080002ffc <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002ffc:	1101                	addi	sp,sp,-32
    80002ffe:	ec06                	sd	ra,24(sp)
    80003000:	e822                	sd	s0,16(sp)
    80003002:	e426                	sd	s1,8(sp)
    80003004:	1000                	addi	s0,sp,32
    80003006:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003008:	00000097          	auipc	ra,0x0
    8000300c:	eee080e7          	jalr	-274(ra) # 80002ef6 <argraw>
    80003010:	c088                	sw	a0,0(s1)
}
    80003012:	60e2                	ld	ra,24(sp)
    80003014:	6442                	ld	s0,16(sp)
    80003016:	64a2                	ld	s1,8(sp)
    80003018:	6105                	addi	sp,sp,32
    8000301a:	8082                	ret

000000008000301c <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    8000301c:	1101                	addi	sp,sp,-32
    8000301e:	ec06                	sd	ra,24(sp)
    80003020:	e822                	sd	s0,16(sp)
    80003022:	e426                	sd	s1,8(sp)
    80003024:	1000                	addi	s0,sp,32
    80003026:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003028:	00000097          	auipc	ra,0x0
    8000302c:	ece080e7          	jalr	-306(ra) # 80002ef6 <argraw>
    80003030:	e088                	sd	a0,0(s1)
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	64a2                	ld	s1,8(sp)
    80003038:	6105                	addi	sp,sp,32
    8000303a:	8082                	ret

000000008000303c <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    8000303c:	7179                	addi	sp,sp,-48
    8000303e:	f406                	sd	ra,40(sp)
    80003040:	f022                	sd	s0,32(sp)
    80003042:	ec26                	sd	s1,24(sp)
    80003044:	e84a                	sd	s2,16(sp)
    80003046:	1800                	addi	s0,sp,48
    80003048:	84ae                	mv	s1,a1
    8000304a:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    8000304c:	fd840593          	addi	a1,s0,-40
    80003050:	00000097          	auipc	ra,0x0
    80003054:	fcc080e7          	jalr	-52(ra) # 8000301c <argaddr>
    return fetchstr(addr, buf, max);
    80003058:	864a                	mv	a2,s2
    8000305a:	85a6                	mv	a1,s1
    8000305c:	fd843503          	ld	a0,-40(s0)
    80003060:	00000097          	auipc	ra,0x0
    80003064:	f50080e7          	jalr	-176(ra) # 80002fb0 <fetchstr>
}
    80003068:	70a2                	ld	ra,40(sp)
    8000306a:	7402                	ld	s0,32(sp)
    8000306c:	64e2                	ld	s1,24(sp)
    8000306e:	6942                	ld	s2,16(sp)
    80003070:	6145                	addi	sp,sp,48
    80003072:	8082                	ret

0000000080003074 <syscall>:
    [SYS_schedset] sys_schedset,
    [SYS_yield] sys_yield,
};

void syscall(void)
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	e04a                	sd	s2,0(sp)
    8000307e:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80003080:	fffff097          	auipc	ra,0xfffff
    80003084:	c02080e7          	jalr	-1022(ra) # 80001c82 <myproc>
    80003088:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    8000308a:	06053903          	ld	s2,96(a0)
    8000308e:	0a893783          	ld	a5,168(s2)
    80003092:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003096:	37fd                	addiw	a5,a5,-1
    80003098:	4761                	li	a4,24
    8000309a:	00f76f63          	bltu	a4,a5,800030b8 <syscall+0x44>
    8000309e:	00369713          	slli	a4,a3,0x3
    800030a2:	00005797          	auipc	a5,0x5
    800030a6:	49678793          	addi	a5,a5,1174 # 80008538 <syscalls>
    800030aa:	97ba                	add	a5,a5,a4
    800030ac:	639c                	ld	a5,0(a5)
    800030ae:	c789                	beqz	a5,800030b8 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800030b0:	9782                	jalr	a5
    800030b2:	06a93823          	sd	a0,112(s2)
    800030b6:	a839                	j	800030d4 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800030b8:	16048613          	addi	a2,s1,352
    800030bc:	588c                	lw	a1,48(s1)
    800030be:	00005517          	auipc	a0,0x5
    800030c2:	44250513          	addi	a0,a0,1090 # 80008500 <states.0+0x150>
    800030c6:	ffffd097          	auipc	ra,0xffffd
    800030ca:	4c4080e7          	jalr	1220(ra) # 8000058a <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    800030ce:	70bc                	ld	a5,96(s1)
    800030d0:	577d                	li	a4,-1
    800030d2:	fbb8                	sd	a4,112(a5)
    }
}
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6902                	ld	s2,0(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret

00000000800030e0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800030e0:	1101                	addi	sp,sp,-32
    800030e2:	ec06                	sd	ra,24(sp)
    800030e4:	e822                	sd	s0,16(sp)
    800030e6:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    800030e8:	fec40593          	addi	a1,s0,-20
    800030ec:	4501                	li	a0,0
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	f0e080e7          	jalr	-242(ra) # 80002ffc <argint>
    exit(n);
    800030f6:	fec42503          	lw	a0,-20(s0)
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	472080e7          	jalr	1138(ra) # 8000256c <exit>
    return 0; // not reached
}
    80003102:	4501                	li	a0,0
    80003104:	60e2                	ld	ra,24(sp)
    80003106:	6442                	ld	s0,16(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret

000000008000310c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000310c:	1141                	addi	sp,sp,-16
    8000310e:	e406                	sd	ra,8(sp)
    80003110:	e022                	sd	s0,0(sp)
    80003112:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003114:	fffff097          	auipc	ra,0xfffff
    80003118:	b6e080e7          	jalr	-1170(ra) # 80001c82 <myproc>
}
    8000311c:	5908                	lw	a0,48(a0)
    8000311e:	60a2                	ld	ra,8(sp)
    80003120:	6402                	ld	s0,0(sp)
    80003122:	0141                	addi	sp,sp,16
    80003124:	8082                	ret

0000000080003126 <sys_fork>:

uint64
sys_fork(void)
{
    80003126:	1141                	addi	sp,sp,-16
    80003128:	e406                	sd	ra,8(sp)
    8000312a:	e022                	sd	s0,0(sp)
    8000312c:	0800                	addi	s0,sp,16
    return fork();
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	0a8080e7          	jalr	168(ra) # 800021d6 <fork>
}
    80003136:	60a2                	ld	ra,8(sp)
    80003138:	6402                	ld	s0,0(sp)
    8000313a:	0141                	addi	sp,sp,16
    8000313c:	8082                	ret

000000008000313e <sys_wait>:

uint64
sys_wait(void)
{
    8000313e:	1101                	addi	sp,sp,-32
    80003140:	ec06                	sd	ra,24(sp)
    80003142:	e822                	sd	s0,16(sp)
    80003144:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003146:	fe840593          	addi	a1,s0,-24
    8000314a:	4501                	li	a0,0
    8000314c:	00000097          	auipc	ra,0x0
    80003150:	ed0080e7          	jalr	-304(ra) # 8000301c <argaddr>
    return wait(p);
    80003154:	fe843503          	ld	a0,-24(s0)
    80003158:	fffff097          	auipc	ra,0xfffff
    8000315c:	5ba080e7          	jalr	1466(ra) # 80002712 <wait>
}
    80003160:	60e2                	ld	ra,24(sp)
    80003162:	6442                	ld	s0,16(sp)
    80003164:	6105                	addi	sp,sp,32
    80003166:	8082                	ret

0000000080003168 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003168:	7179                	addi	sp,sp,-48
    8000316a:	f406                	sd	ra,40(sp)
    8000316c:	f022                	sd	s0,32(sp)
    8000316e:	ec26                	sd	s1,24(sp)
    80003170:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003172:	fdc40593          	addi	a1,s0,-36
    80003176:	4501                	li	a0,0
    80003178:	00000097          	auipc	ra,0x0
    8000317c:	e84080e7          	jalr	-380(ra) # 80002ffc <argint>
    addr = myproc()->sz;
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	b02080e7          	jalr	-1278(ra) # 80001c82 <myproc>
    80003188:	6924                	ld	s1,80(a0)
    if (growproc(n) < 0)
    8000318a:	fdc42503          	lw	a0,-36(s0)
    8000318e:	fffff097          	auipc	ra,0xfffff
    80003192:	e56080e7          	jalr	-426(ra) # 80001fe4 <growproc>
    80003196:	00054863          	bltz	a0,800031a6 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    8000319a:	8526                	mv	a0,s1
    8000319c:	70a2                	ld	ra,40(sp)
    8000319e:	7402                	ld	s0,32(sp)
    800031a0:	64e2                	ld	s1,24(sp)
    800031a2:	6145                	addi	sp,sp,48
    800031a4:	8082                	ret
        return -1;
    800031a6:	54fd                	li	s1,-1
    800031a8:	bfcd                	j	8000319a <sys_sbrk+0x32>

00000000800031aa <sys_sleep>:

uint64
sys_sleep(void)
{
    800031aa:	7139                	addi	sp,sp,-64
    800031ac:	fc06                	sd	ra,56(sp)
    800031ae:	f822                	sd	s0,48(sp)
    800031b0:	f426                	sd	s1,40(sp)
    800031b2:	f04a                	sd	s2,32(sp)
    800031b4:	ec4e                	sd	s3,24(sp)
    800031b6:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800031b8:	fcc40593          	addi	a1,s0,-52
    800031bc:	4501                	li	a0,0
    800031be:	00000097          	auipc	ra,0x0
    800031c2:	e3e080e7          	jalr	-450(ra) # 80002ffc <argint>
    acquire(&tickslock);
    800031c6:	00014517          	auipc	a0,0x14
    800031ca:	b3250513          	addi	a0,a0,-1230 # 80016cf8 <tickslock>
    800031ce:	ffffe097          	auipc	ra,0xffffe
    800031d2:	a08080e7          	jalr	-1528(ra) # 80000bd6 <acquire>
    ticks0 = ticks;
    800031d6:	00006917          	auipc	s2,0x6
    800031da:	86a92903          	lw	s2,-1942(s2) # 80008a40 <ticks>
    while (ticks - ticks0 < n)
    800031de:	fcc42783          	lw	a5,-52(s0)
    800031e2:	cf9d                	beqz	a5,80003220 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800031e4:	00014997          	auipc	s3,0x14
    800031e8:	b1498993          	addi	s3,s3,-1260 # 80016cf8 <tickslock>
    800031ec:	00006497          	auipc	s1,0x6
    800031f0:	85448493          	addi	s1,s1,-1964 # 80008a40 <ticks>
        if (killed(myproc()))
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	a8e080e7          	jalr	-1394(ra) # 80001c82 <myproc>
    800031fc:	fffff097          	auipc	ra,0xfffff
    80003200:	4e4080e7          	jalr	1252(ra) # 800026e0 <killed>
    80003204:	ed15                	bnez	a0,80003240 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003206:	85ce                	mv	a1,s3
    80003208:	8526                	mv	a0,s1
    8000320a:	fffff097          	auipc	ra,0xfffff
    8000320e:	22e080e7          	jalr	558(ra) # 80002438 <sleep>
    while (ticks - ticks0 < n)
    80003212:	409c                	lw	a5,0(s1)
    80003214:	412787bb          	subw	a5,a5,s2
    80003218:	fcc42703          	lw	a4,-52(s0)
    8000321c:	fce7ece3          	bltu	a5,a4,800031f4 <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003220:	00014517          	auipc	a0,0x14
    80003224:	ad850513          	addi	a0,a0,-1320 # 80016cf8 <tickslock>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	a62080e7          	jalr	-1438(ra) # 80000c8a <release>
    return 0;
    80003230:	4501                	li	a0,0
}
    80003232:	70e2                	ld	ra,56(sp)
    80003234:	7442                	ld	s0,48(sp)
    80003236:	74a2                	ld	s1,40(sp)
    80003238:	7902                	ld	s2,32(sp)
    8000323a:	69e2                	ld	s3,24(sp)
    8000323c:	6121                	addi	sp,sp,64
    8000323e:	8082                	ret
            release(&tickslock);
    80003240:	00014517          	auipc	a0,0x14
    80003244:	ab850513          	addi	a0,a0,-1352 # 80016cf8 <tickslock>
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	a42080e7          	jalr	-1470(ra) # 80000c8a <release>
            return -1;
    80003250:	557d                	li	a0,-1
    80003252:	b7c5                	j	80003232 <sys_sleep+0x88>

0000000080003254 <sys_kill>:

uint64
sys_kill(void)
{
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000325c:	fec40593          	addi	a1,s0,-20
    80003260:	4501                	li	a0,0
    80003262:	00000097          	auipc	ra,0x0
    80003266:	d9a080e7          	jalr	-614(ra) # 80002ffc <argint>
    return kill(pid);
    8000326a:	fec42503          	lw	a0,-20(s0)
    8000326e:	fffff097          	auipc	ra,0xfffff
    80003272:	3d4080e7          	jalr	980(ra) # 80002642 <kill>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	6105                	addi	sp,sp,32
    8000327c:	8082                	ret

000000008000327e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	e426                	sd	s1,8(sp)
    80003286:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003288:	00014517          	auipc	a0,0x14
    8000328c:	a7050513          	addi	a0,a0,-1424 # 80016cf8 <tickslock>
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	946080e7          	jalr	-1722(ra) # 80000bd6 <acquire>
    xticks = ticks;
    80003298:	00005497          	auipc	s1,0x5
    8000329c:	7a84a483          	lw	s1,1960(s1) # 80008a40 <ticks>
    release(&tickslock);
    800032a0:	00014517          	auipc	a0,0x14
    800032a4:	a5850513          	addi	a0,a0,-1448 # 80016cf8 <tickslock>
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	9e2080e7          	jalr	-1566(ra) # 80000c8a <release>
    return xticks;
}
    800032b0:	02049513          	slli	a0,s1,0x20
    800032b4:	9101                	srli	a0,a0,0x20
    800032b6:	60e2                	ld	ra,24(sp)
    800032b8:	6442                	ld	s0,16(sp)
    800032ba:	64a2                	ld	s1,8(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret

00000000800032c0 <sys_ps>:

void *
sys_ps(void)
{
    800032c0:	1101                	addi	sp,sp,-32
    800032c2:	ec06                	sd	ra,24(sp)
    800032c4:	e822                	sd	s0,16(sp)
    800032c6:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800032c8:	fe042623          	sw	zero,-20(s0)
    800032cc:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800032d0:	fec40593          	addi	a1,s0,-20
    800032d4:	4501                	li	a0,0
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	d26080e7          	jalr	-730(ra) # 80002ffc <argint>
    argint(1, &count);
    800032de:	fe840593          	addi	a1,s0,-24
    800032e2:	4505                	li	a0,1
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	d18080e7          	jalr	-744(ra) # 80002ffc <argint>
    return ps((uint8)start, (uint8)count);
    800032ec:	fe844583          	lbu	a1,-24(s0)
    800032f0:	fec44503          	lbu	a0,-20(s0)
    800032f4:	fffff097          	auipc	ra,0xfffff
    800032f8:	d4c080e7          	jalr	-692(ra) # 80002040 <ps>
}
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	6105                	addi	sp,sp,32
    80003302:	8082                	ret

0000000080003304 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003304:	1141                	addi	sp,sp,-16
    80003306:	e406                	sd	ra,8(sp)
    80003308:	e022                	sd	s0,0(sp)
    8000330a:	0800                	addi	s0,sp,16
    schedls();
    8000330c:	fffff097          	auipc	ra,0xfffff
    80003310:	690080e7          	jalr	1680(ra) # 8000299c <schedls>
    return 0;
}
    80003314:	4501                	li	a0,0
    80003316:	60a2                	ld	ra,8(sp)
    80003318:	6402                	ld	s0,0(sp)
    8000331a:	0141                	addi	sp,sp,16
    8000331c:	8082                	ret

000000008000331e <sys_schedset>:

uint64 sys_schedset(void)
{
    8000331e:	1101                	addi	sp,sp,-32
    80003320:	ec06                	sd	ra,24(sp)
    80003322:	e822                	sd	s0,16(sp)
    80003324:	1000                	addi	s0,sp,32
    int id = 0;
    80003326:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    8000332a:	fec40593          	addi	a1,s0,-20
    8000332e:	4501                	li	a0,0
    80003330:	00000097          	auipc	ra,0x0
    80003334:	ccc080e7          	jalr	-820(ra) # 80002ffc <argint>
    schedset(id - 1);
    80003338:	fec42503          	lw	a0,-20(s0)
    8000333c:	357d                	addiw	a0,a0,-1
    8000333e:	fffff097          	auipc	ra,0xfffff
    80003342:	74a080e7          	jalr	1866(ra) # 80002a88 <schedset>
    return 0;
}
    80003346:	4501                	li	a0,0
    80003348:	60e2                	ld	ra,24(sp)
    8000334a:	6442                	ld	s0,16(sp)
    8000334c:	6105                	addi	sp,sp,32
    8000334e:	8082                	ret

0000000080003350 <sys_yield>:

uint64 sys_yield(void)
{
    80003350:	1141                	addi	sp,sp,-16
    80003352:	e406                	sd	ra,8(sp)
    80003354:	e022                	sd	s0,0(sp)
    80003356:	0800                	addi	s0,sp,16
    yield(YIELD_OTHER);
    80003358:	4509                	li	a0,2
    8000335a:	fffff097          	auipc	ra,0xfffff
    8000335e:	0a2080e7          	jalr	162(ra) # 800023fc <yield>
    return 0;
    80003362:	4501                	li	a0,0
    80003364:	60a2                	ld	ra,8(sp)
    80003366:	6402                	ld	s0,0(sp)
    80003368:	0141                	addi	sp,sp,16
    8000336a:	8082                	ret

000000008000336c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000336c:	7179                	addi	sp,sp,-48
    8000336e:	f406                	sd	ra,40(sp)
    80003370:	f022                	sd	s0,32(sp)
    80003372:	ec26                	sd	s1,24(sp)
    80003374:	e84a                	sd	s2,16(sp)
    80003376:	e44e                	sd	s3,8(sp)
    80003378:	e052                	sd	s4,0(sp)
    8000337a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000337c:	00005597          	auipc	a1,0x5
    80003380:	28c58593          	addi	a1,a1,652 # 80008608 <syscalls+0xd0>
    80003384:	00014517          	auipc	a0,0x14
    80003388:	98c50513          	addi	a0,a0,-1652 # 80016d10 <bcache>
    8000338c:	ffffd097          	auipc	ra,0xffffd
    80003390:	7ba080e7          	jalr	1978(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003394:	0001c797          	auipc	a5,0x1c
    80003398:	97c78793          	addi	a5,a5,-1668 # 8001ed10 <bcache+0x8000>
    8000339c:	0001c717          	auipc	a4,0x1c
    800033a0:	bdc70713          	addi	a4,a4,-1060 # 8001ef78 <bcache+0x8268>
    800033a4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033a8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033ac:	00014497          	auipc	s1,0x14
    800033b0:	97c48493          	addi	s1,s1,-1668 # 80016d28 <bcache+0x18>
    b->next = bcache.head.next;
    800033b4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033b6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033b8:	00005a17          	auipc	s4,0x5
    800033bc:	258a0a13          	addi	s4,s4,600 # 80008610 <syscalls+0xd8>
    b->next = bcache.head.next;
    800033c0:	2b893783          	ld	a5,696(s2)
    800033c4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033c6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033ca:	85d2                	mv	a1,s4
    800033cc:	01048513          	addi	a0,s1,16
    800033d0:	00001097          	auipc	ra,0x1
    800033d4:	4c8080e7          	jalr	1224(ra) # 80004898 <initsleeplock>
    bcache.head.next->prev = b;
    800033d8:	2b893783          	ld	a5,696(s2)
    800033dc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033de:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033e2:	45848493          	addi	s1,s1,1112
    800033e6:	fd349de3          	bne	s1,s3,800033c0 <binit+0x54>
  }
}
    800033ea:	70a2                	ld	ra,40(sp)
    800033ec:	7402                	ld	s0,32(sp)
    800033ee:	64e2                	ld	s1,24(sp)
    800033f0:	6942                	ld	s2,16(sp)
    800033f2:	69a2                	ld	s3,8(sp)
    800033f4:	6a02                	ld	s4,0(sp)
    800033f6:	6145                	addi	sp,sp,48
    800033f8:	8082                	ret

00000000800033fa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033fa:	7179                	addi	sp,sp,-48
    800033fc:	f406                	sd	ra,40(sp)
    800033fe:	f022                	sd	s0,32(sp)
    80003400:	ec26                	sd	s1,24(sp)
    80003402:	e84a                	sd	s2,16(sp)
    80003404:	e44e                	sd	s3,8(sp)
    80003406:	1800                	addi	s0,sp,48
    80003408:	892a                	mv	s2,a0
    8000340a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000340c:	00014517          	auipc	a0,0x14
    80003410:	90450513          	addi	a0,a0,-1788 # 80016d10 <bcache>
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	7c2080e7          	jalr	1986(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000341c:	0001c497          	auipc	s1,0x1c
    80003420:	bac4b483          	ld	s1,-1108(s1) # 8001efc8 <bcache+0x82b8>
    80003424:	0001c797          	auipc	a5,0x1c
    80003428:	b5478793          	addi	a5,a5,-1196 # 8001ef78 <bcache+0x8268>
    8000342c:	02f48f63          	beq	s1,a5,8000346a <bread+0x70>
    80003430:	873e                	mv	a4,a5
    80003432:	a021                	j	8000343a <bread+0x40>
    80003434:	68a4                	ld	s1,80(s1)
    80003436:	02e48a63          	beq	s1,a4,8000346a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000343a:	449c                	lw	a5,8(s1)
    8000343c:	ff279ce3          	bne	a5,s2,80003434 <bread+0x3a>
    80003440:	44dc                	lw	a5,12(s1)
    80003442:	ff3799e3          	bne	a5,s3,80003434 <bread+0x3a>
      b->refcnt++;
    80003446:	40bc                	lw	a5,64(s1)
    80003448:	2785                	addiw	a5,a5,1
    8000344a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000344c:	00014517          	auipc	a0,0x14
    80003450:	8c450513          	addi	a0,a0,-1852 # 80016d10 <bcache>
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	836080e7          	jalr	-1994(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000345c:	01048513          	addi	a0,s1,16
    80003460:	00001097          	auipc	ra,0x1
    80003464:	472080e7          	jalr	1138(ra) # 800048d2 <acquiresleep>
      return b;
    80003468:	a8b9                	j	800034c6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000346a:	0001c497          	auipc	s1,0x1c
    8000346e:	b564b483          	ld	s1,-1194(s1) # 8001efc0 <bcache+0x82b0>
    80003472:	0001c797          	auipc	a5,0x1c
    80003476:	b0678793          	addi	a5,a5,-1274 # 8001ef78 <bcache+0x8268>
    8000347a:	00f48863          	beq	s1,a5,8000348a <bread+0x90>
    8000347e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003480:	40bc                	lw	a5,64(s1)
    80003482:	cf81                	beqz	a5,8000349a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003484:	64a4                	ld	s1,72(s1)
    80003486:	fee49de3          	bne	s1,a4,80003480 <bread+0x86>
  panic("bget: no buffers");
    8000348a:	00005517          	auipc	a0,0x5
    8000348e:	18e50513          	addi	a0,a0,398 # 80008618 <syscalls+0xe0>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	0ae080e7          	jalr	174(ra) # 80000540 <panic>
      b->dev = dev;
    8000349a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000349e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034a2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034a6:	4785                	li	a5,1
    800034a8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034aa:	00014517          	auipc	a0,0x14
    800034ae:	86650513          	addi	a0,a0,-1946 # 80016d10 <bcache>
    800034b2:	ffffd097          	auipc	ra,0xffffd
    800034b6:	7d8080e7          	jalr	2008(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034ba:	01048513          	addi	a0,s1,16
    800034be:	00001097          	auipc	ra,0x1
    800034c2:	414080e7          	jalr	1044(ra) # 800048d2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034c6:	409c                	lw	a5,0(s1)
    800034c8:	cb89                	beqz	a5,800034da <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034ca:	8526                	mv	a0,s1
    800034cc:	70a2                	ld	ra,40(sp)
    800034ce:	7402                	ld	s0,32(sp)
    800034d0:	64e2                	ld	s1,24(sp)
    800034d2:	6942                	ld	s2,16(sp)
    800034d4:	69a2                	ld	s3,8(sp)
    800034d6:	6145                	addi	sp,sp,48
    800034d8:	8082                	ret
    virtio_disk_rw(b, 0);
    800034da:	4581                	li	a1,0
    800034dc:	8526                	mv	a0,s1
    800034de:	00003097          	auipc	ra,0x3
    800034e2:	fe4080e7          	jalr	-28(ra) # 800064c2 <virtio_disk_rw>
    b->valid = 1;
    800034e6:	4785                	li	a5,1
    800034e8:	c09c                	sw	a5,0(s1)
  return b;
    800034ea:	b7c5                	j	800034ca <bread+0xd0>

00000000800034ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034ec:	1101                	addi	sp,sp,-32
    800034ee:	ec06                	sd	ra,24(sp)
    800034f0:	e822                	sd	s0,16(sp)
    800034f2:	e426                	sd	s1,8(sp)
    800034f4:	1000                	addi	s0,sp,32
    800034f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034f8:	0541                	addi	a0,a0,16
    800034fa:	00001097          	auipc	ra,0x1
    800034fe:	472080e7          	jalr	1138(ra) # 8000496c <holdingsleep>
    80003502:	cd01                	beqz	a0,8000351a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003504:	4585                	li	a1,1
    80003506:	8526                	mv	a0,s1
    80003508:	00003097          	auipc	ra,0x3
    8000350c:	fba080e7          	jalr	-70(ra) # 800064c2 <virtio_disk_rw>
}
    80003510:	60e2                	ld	ra,24(sp)
    80003512:	6442                	ld	s0,16(sp)
    80003514:	64a2                	ld	s1,8(sp)
    80003516:	6105                	addi	sp,sp,32
    80003518:	8082                	ret
    panic("bwrite");
    8000351a:	00005517          	auipc	a0,0x5
    8000351e:	11650513          	addi	a0,a0,278 # 80008630 <syscalls+0xf8>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	01e080e7          	jalr	30(ra) # 80000540 <panic>

000000008000352a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000352a:	1101                	addi	sp,sp,-32
    8000352c:	ec06                	sd	ra,24(sp)
    8000352e:	e822                	sd	s0,16(sp)
    80003530:	e426                	sd	s1,8(sp)
    80003532:	e04a                	sd	s2,0(sp)
    80003534:	1000                	addi	s0,sp,32
    80003536:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003538:	01050913          	addi	s2,a0,16
    8000353c:	854a                	mv	a0,s2
    8000353e:	00001097          	auipc	ra,0x1
    80003542:	42e080e7          	jalr	1070(ra) # 8000496c <holdingsleep>
    80003546:	c92d                	beqz	a0,800035b8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003548:	854a                	mv	a0,s2
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	3de080e7          	jalr	990(ra) # 80004928 <releasesleep>

  acquire(&bcache.lock);
    80003552:	00013517          	auipc	a0,0x13
    80003556:	7be50513          	addi	a0,a0,1982 # 80016d10 <bcache>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	67c080e7          	jalr	1660(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003562:	40bc                	lw	a5,64(s1)
    80003564:	37fd                	addiw	a5,a5,-1
    80003566:	0007871b          	sext.w	a4,a5
    8000356a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000356c:	eb05                	bnez	a4,8000359c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000356e:	68bc                	ld	a5,80(s1)
    80003570:	64b8                	ld	a4,72(s1)
    80003572:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003574:	64bc                	ld	a5,72(s1)
    80003576:	68b8                	ld	a4,80(s1)
    80003578:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000357a:	0001b797          	auipc	a5,0x1b
    8000357e:	79678793          	addi	a5,a5,1942 # 8001ed10 <bcache+0x8000>
    80003582:	2b87b703          	ld	a4,696(a5)
    80003586:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003588:	0001c717          	auipc	a4,0x1c
    8000358c:	9f070713          	addi	a4,a4,-1552 # 8001ef78 <bcache+0x8268>
    80003590:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003592:	2b87b703          	ld	a4,696(a5)
    80003596:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003598:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000359c:	00013517          	auipc	a0,0x13
    800035a0:	77450513          	addi	a0,a0,1908 # 80016d10 <bcache>
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	6e6080e7          	jalr	1766(ra) # 80000c8a <release>
}
    800035ac:	60e2                	ld	ra,24(sp)
    800035ae:	6442                	ld	s0,16(sp)
    800035b0:	64a2                	ld	s1,8(sp)
    800035b2:	6902                	ld	s2,0(sp)
    800035b4:	6105                	addi	sp,sp,32
    800035b6:	8082                	ret
    panic("brelse");
    800035b8:	00005517          	auipc	a0,0x5
    800035bc:	08050513          	addi	a0,a0,128 # 80008638 <syscalls+0x100>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	f80080e7          	jalr	-128(ra) # 80000540 <panic>

00000000800035c8 <bpin>:

void
bpin(struct buf *b) {
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	1000                	addi	s0,sp,32
    800035d2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035d4:	00013517          	auipc	a0,0x13
    800035d8:	73c50513          	addi	a0,a0,1852 # 80016d10 <bcache>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	5fa080e7          	jalr	1530(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800035e4:	40bc                	lw	a5,64(s1)
    800035e6:	2785                	addiw	a5,a5,1
    800035e8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035ea:	00013517          	auipc	a0,0x13
    800035ee:	72650513          	addi	a0,a0,1830 # 80016d10 <bcache>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	698080e7          	jalr	1688(ra) # 80000c8a <release>
}
    800035fa:	60e2                	ld	ra,24(sp)
    800035fc:	6442                	ld	s0,16(sp)
    800035fe:	64a2                	ld	s1,8(sp)
    80003600:	6105                	addi	sp,sp,32
    80003602:	8082                	ret

0000000080003604 <bunpin>:

void
bunpin(struct buf *b) {
    80003604:	1101                	addi	sp,sp,-32
    80003606:	ec06                	sd	ra,24(sp)
    80003608:	e822                	sd	s0,16(sp)
    8000360a:	e426                	sd	s1,8(sp)
    8000360c:	1000                	addi	s0,sp,32
    8000360e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003610:	00013517          	auipc	a0,0x13
    80003614:	70050513          	addi	a0,a0,1792 # 80016d10 <bcache>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	5be080e7          	jalr	1470(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003620:	40bc                	lw	a5,64(s1)
    80003622:	37fd                	addiw	a5,a5,-1
    80003624:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003626:	00013517          	auipc	a0,0x13
    8000362a:	6ea50513          	addi	a0,a0,1770 # 80016d10 <bcache>
    8000362e:	ffffd097          	auipc	ra,0xffffd
    80003632:	65c080e7          	jalr	1628(ra) # 80000c8a <release>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret

0000000080003640 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	e04a                	sd	s2,0(sp)
    8000364a:	1000                	addi	s0,sp,32
    8000364c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000364e:	00d5d59b          	srliw	a1,a1,0xd
    80003652:	0001c797          	auipc	a5,0x1c
    80003656:	d9a7a783          	lw	a5,-614(a5) # 8001f3ec <sb+0x1c>
    8000365a:	9dbd                	addw	a1,a1,a5
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	d9e080e7          	jalr	-610(ra) # 800033fa <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003664:	0074f713          	andi	a4,s1,7
    80003668:	4785                	li	a5,1
    8000366a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000366e:	14ce                	slli	s1,s1,0x33
    80003670:	90d9                	srli	s1,s1,0x36
    80003672:	00950733          	add	a4,a0,s1
    80003676:	05874703          	lbu	a4,88(a4)
    8000367a:	00e7f6b3          	and	a3,a5,a4
    8000367e:	c69d                	beqz	a3,800036ac <bfree+0x6c>
    80003680:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003682:	94aa                	add	s1,s1,a0
    80003684:	fff7c793          	not	a5,a5
    80003688:	8f7d                	and	a4,a4,a5
    8000368a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	126080e7          	jalr	294(ra) # 800047b4 <log_write>
  brelse(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	e92080e7          	jalr	-366(ra) # 8000352a <brelse>
}
    800036a0:	60e2                	ld	ra,24(sp)
    800036a2:	6442                	ld	s0,16(sp)
    800036a4:	64a2                	ld	s1,8(sp)
    800036a6:	6902                	ld	s2,0(sp)
    800036a8:	6105                	addi	sp,sp,32
    800036aa:	8082                	ret
    panic("freeing free block");
    800036ac:	00005517          	auipc	a0,0x5
    800036b0:	f9450513          	addi	a0,a0,-108 # 80008640 <syscalls+0x108>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	e8c080e7          	jalr	-372(ra) # 80000540 <panic>

00000000800036bc <balloc>:
{
    800036bc:	711d                	addi	sp,sp,-96
    800036be:	ec86                	sd	ra,88(sp)
    800036c0:	e8a2                	sd	s0,80(sp)
    800036c2:	e4a6                	sd	s1,72(sp)
    800036c4:	e0ca                	sd	s2,64(sp)
    800036c6:	fc4e                	sd	s3,56(sp)
    800036c8:	f852                	sd	s4,48(sp)
    800036ca:	f456                	sd	s5,40(sp)
    800036cc:	f05a                	sd	s6,32(sp)
    800036ce:	ec5e                	sd	s7,24(sp)
    800036d0:	e862                	sd	s8,16(sp)
    800036d2:	e466                	sd	s9,8(sp)
    800036d4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036d6:	0001c797          	auipc	a5,0x1c
    800036da:	cfe7a783          	lw	a5,-770(a5) # 8001f3d4 <sb+0x4>
    800036de:	cff5                	beqz	a5,800037da <balloc+0x11e>
    800036e0:	8baa                	mv	s7,a0
    800036e2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036e4:	0001cb17          	auipc	s6,0x1c
    800036e8:	cecb0b13          	addi	s6,s6,-788 # 8001f3d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ec:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036ee:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036f2:	6c89                	lui	s9,0x2
    800036f4:	a061                	j	8000377c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036f6:	97ca                	add	a5,a5,s2
    800036f8:	8e55                	or	a2,a2,a3
    800036fa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800036fe:	854a                	mv	a0,s2
    80003700:	00001097          	auipc	ra,0x1
    80003704:	0b4080e7          	jalr	180(ra) # 800047b4 <log_write>
        brelse(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	e20080e7          	jalr	-480(ra) # 8000352a <brelse>
  bp = bread(dev, bno);
    80003712:	85a6                	mv	a1,s1
    80003714:	855e                	mv	a0,s7
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	ce4080e7          	jalr	-796(ra) # 800033fa <bread>
    8000371e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003720:	40000613          	li	a2,1024
    80003724:	4581                	li	a1,0
    80003726:	05850513          	addi	a0,a0,88
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	5a8080e7          	jalr	1448(ra) # 80000cd2 <memset>
  log_write(bp);
    80003732:	854a                	mv	a0,s2
    80003734:	00001097          	auipc	ra,0x1
    80003738:	080080e7          	jalr	128(ra) # 800047b4 <log_write>
  brelse(bp);
    8000373c:	854a                	mv	a0,s2
    8000373e:	00000097          	auipc	ra,0x0
    80003742:	dec080e7          	jalr	-532(ra) # 8000352a <brelse>
}
    80003746:	8526                	mv	a0,s1
    80003748:	60e6                	ld	ra,88(sp)
    8000374a:	6446                	ld	s0,80(sp)
    8000374c:	64a6                	ld	s1,72(sp)
    8000374e:	6906                	ld	s2,64(sp)
    80003750:	79e2                	ld	s3,56(sp)
    80003752:	7a42                	ld	s4,48(sp)
    80003754:	7aa2                	ld	s5,40(sp)
    80003756:	7b02                	ld	s6,32(sp)
    80003758:	6be2                	ld	s7,24(sp)
    8000375a:	6c42                	ld	s8,16(sp)
    8000375c:	6ca2                	ld	s9,8(sp)
    8000375e:	6125                	addi	sp,sp,96
    80003760:	8082                	ret
    brelse(bp);
    80003762:	854a                	mv	a0,s2
    80003764:	00000097          	auipc	ra,0x0
    80003768:	dc6080e7          	jalr	-570(ra) # 8000352a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000376c:	015c87bb          	addw	a5,s9,s5
    80003770:	00078a9b          	sext.w	s5,a5
    80003774:	004b2703          	lw	a4,4(s6)
    80003778:	06eaf163          	bgeu	s5,a4,800037da <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000377c:	41fad79b          	sraiw	a5,s5,0x1f
    80003780:	0137d79b          	srliw	a5,a5,0x13
    80003784:	015787bb          	addw	a5,a5,s5
    80003788:	40d7d79b          	sraiw	a5,a5,0xd
    8000378c:	01cb2583          	lw	a1,28(s6)
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	855e                	mv	a0,s7
    80003794:	00000097          	auipc	ra,0x0
    80003798:	c66080e7          	jalr	-922(ra) # 800033fa <bread>
    8000379c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379e:	004b2503          	lw	a0,4(s6)
    800037a2:	000a849b          	sext.w	s1,s5
    800037a6:	8762                	mv	a4,s8
    800037a8:	faa4fde3          	bgeu	s1,a0,80003762 <balloc+0xa6>
      m = 1 << (bi % 8);
    800037ac:	00777693          	andi	a3,a4,7
    800037b0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037b4:	41f7579b          	sraiw	a5,a4,0x1f
    800037b8:	01d7d79b          	srliw	a5,a5,0x1d
    800037bc:	9fb9                	addw	a5,a5,a4
    800037be:	4037d79b          	sraiw	a5,a5,0x3
    800037c2:	00f90633          	add	a2,s2,a5
    800037c6:	05864603          	lbu	a2,88(a2)
    800037ca:	00c6f5b3          	and	a1,a3,a2
    800037ce:	d585                	beqz	a1,800036f6 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037d0:	2705                	addiw	a4,a4,1
    800037d2:	2485                	addiw	s1,s1,1
    800037d4:	fd471ae3          	bne	a4,s4,800037a8 <balloc+0xec>
    800037d8:	b769                	j	80003762 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800037da:	00005517          	auipc	a0,0x5
    800037de:	e7e50513          	addi	a0,a0,-386 # 80008658 <syscalls+0x120>
    800037e2:	ffffd097          	auipc	ra,0xffffd
    800037e6:	da8080e7          	jalr	-600(ra) # 8000058a <printf>
  return 0;
    800037ea:	4481                	li	s1,0
    800037ec:	bfa9                	j	80003746 <balloc+0x8a>

00000000800037ee <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037ee:	7179                	addi	sp,sp,-48
    800037f0:	f406                	sd	ra,40(sp)
    800037f2:	f022                	sd	s0,32(sp)
    800037f4:	ec26                	sd	s1,24(sp)
    800037f6:	e84a                	sd	s2,16(sp)
    800037f8:	e44e                	sd	s3,8(sp)
    800037fa:	e052                	sd	s4,0(sp)
    800037fc:	1800                	addi	s0,sp,48
    800037fe:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003800:	47ad                	li	a5,11
    80003802:	02b7e863          	bltu	a5,a1,80003832 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003806:	02059793          	slli	a5,a1,0x20
    8000380a:	01e7d593          	srli	a1,a5,0x1e
    8000380e:	00b504b3          	add	s1,a0,a1
    80003812:	0504a903          	lw	s2,80(s1)
    80003816:	06091e63          	bnez	s2,80003892 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000381a:	4108                	lw	a0,0(a0)
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	ea0080e7          	jalr	-352(ra) # 800036bc <balloc>
    80003824:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003828:	06090563          	beqz	s2,80003892 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000382c:	0524a823          	sw	s2,80(s1)
    80003830:	a08d                	j	80003892 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003832:	ff45849b          	addiw	s1,a1,-12
    80003836:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000383a:	0ff00793          	li	a5,255
    8000383e:	08e7e563          	bltu	a5,a4,800038c8 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003842:	08052903          	lw	s2,128(a0)
    80003846:	00091d63          	bnez	s2,80003860 <bmap+0x72>
      addr = balloc(ip->dev);
    8000384a:	4108                	lw	a0,0(a0)
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	e70080e7          	jalr	-400(ra) # 800036bc <balloc>
    80003854:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003858:	02090d63          	beqz	s2,80003892 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000385c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003860:	85ca                	mv	a1,s2
    80003862:	0009a503          	lw	a0,0(s3)
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	b94080e7          	jalr	-1132(ra) # 800033fa <bread>
    8000386e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003870:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003874:	02049713          	slli	a4,s1,0x20
    80003878:	01e75593          	srli	a1,a4,0x1e
    8000387c:	00b784b3          	add	s1,a5,a1
    80003880:	0004a903          	lw	s2,0(s1)
    80003884:	02090063          	beqz	s2,800038a4 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003888:	8552                	mv	a0,s4
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	ca0080e7          	jalr	-864(ra) # 8000352a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003892:	854a                	mv	a0,s2
    80003894:	70a2                	ld	ra,40(sp)
    80003896:	7402                	ld	s0,32(sp)
    80003898:	64e2                	ld	s1,24(sp)
    8000389a:	6942                	ld	s2,16(sp)
    8000389c:	69a2                	ld	s3,8(sp)
    8000389e:	6a02                	ld	s4,0(sp)
    800038a0:	6145                	addi	sp,sp,48
    800038a2:	8082                	ret
      addr = balloc(ip->dev);
    800038a4:	0009a503          	lw	a0,0(s3)
    800038a8:	00000097          	auipc	ra,0x0
    800038ac:	e14080e7          	jalr	-492(ra) # 800036bc <balloc>
    800038b0:	0005091b          	sext.w	s2,a0
      if(addr){
    800038b4:	fc090ae3          	beqz	s2,80003888 <bmap+0x9a>
        a[bn] = addr;
    800038b8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038bc:	8552                	mv	a0,s4
    800038be:	00001097          	auipc	ra,0x1
    800038c2:	ef6080e7          	jalr	-266(ra) # 800047b4 <log_write>
    800038c6:	b7c9                	j	80003888 <bmap+0x9a>
  panic("bmap: out of range");
    800038c8:	00005517          	auipc	a0,0x5
    800038cc:	da850513          	addi	a0,a0,-600 # 80008670 <syscalls+0x138>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	c70080e7          	jalr	-912(ra) # 80000540 <panic>

00000000800038d8 <iget>:
{
    800038d8:	7179                	addi	sp,sp,-48
    800038da:	f406                	sd	ra,40(sp)
    800038dc:	f022                	sd	s0,32(sp)
    800038de:	ec26                	sd	s1,24(sp)
    800038e0:	e84a                	sd	s2,16(sp)
    800038e2:	e44e                	sd	s3,8(sp)
    800038e4:	e052                	sd	s4,0(sp)
    800038e6:	1800                	addi	s0,sp,48
    800038e8:	89aa                	mv	s3,a0
    800038ea:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038ec:	0001c517          	auipc	a0,0x1c
    800038f0:	b0450513          	addi	a0,a0,-1276 # 8001f3f0 <itable>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	2e2080e7          	jalr	738(ra) # 80000bd6 <acquire>
  empty = 0;
    800038fc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038fe:	0001c497          	auipc	s1,0x1c
    80003902:	b0a48493          	addi	s1,s1,-1270 # 8001f408 <itable+0x18>
    80003906:	0001d697          	auipc	a3,0x1d
    8000390a:	59268693          	addi	a3,a3,1426 # 80020e98 <log>
    8000390e:	a039                	j	8000391c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003910:	02090b63          	beqz	s2,80003946 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003914:	08848493          	addi	s1,s1,136
    80003918:	02d48a63          	beq	s1,a3,8000394c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000391c:	449c                	lw	a5,8(s1)
    8000391e:	fef059e3          	blez	a5,80003910 <iget+0x38>
    80003922:	4098                	lw	a4,0(s1)
    80003924:	ff3716e3          	bne	a4,s3,80003910 <iget+0x38>
    80003928:	40d8                	lw	a4,4(s1)
    8000392a:	ff4713e3          	bne	a4,s4,80003910 <iget+0x38>
      ip->ref++;
    8000392e:	2785                	addiw	a5,a5,1
    80003930:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003932:	0001c517          	auipc	a0,0x1c
    80003936:	abe50513          	addi	a0,a0,-1346 # 8001f3f0 <itable>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	350080e7          	jalr	848(ra) # 80000c8a <release>
      return ip;
    80003942:	8926                	mv	s2,s1
    80003944:	a03d                	j	80003972 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003946:	f7f9                	bnez	a5,80003914 <iget+0x3c>
    80003948:	8926                	mv	s2,s1
    8000394a:	b7e9                	j	80003914 <iget+0x3c>
  if(empty == 0)
    8000394c:	02090c63          	beqz	s2,80003984 <iget+0xac>
  ip->dev = dev;
    80003950:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003954:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003958:	4785                	li	a5,1
    8000395a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000395e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003962:	0001c517          	auipc	a0,0x1c
    80003966:	a8e50513          	addi	a0,a0,-1394 # 8001f3f0 <itable>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	320080e7          	jalr	800(ra) # 80000c8a <release>
}
    80003972:	854a                	mv	a0,s2
    80003974:	70a2                	ld	ra,40(sp)
    80003976:	7402                	ld	s0,32(sp)
    80003978:	64e2                	ld	s1,24(sp)
    8000397a:	6942                	ld	s2,16(sp)
    8000397c:	69a2                	ld	s3,8(sp)
    8000397e:	6a02                	ld	s4,0(sp)
    80003980:	6145                	addi	sp,sp,48
    80003982:	8082                	ret
    panic("iget: no inodes");
    80003984:	00005517          	auipc	a0,0x5
    80003988:	d0450513          	addi	a0,a0,-764 # 80008688 <syscalls+0x150>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	bb4080e7          	jalr	-1100(ra) # 80000540 <panic>

0000000080003994 <fsinit>:
fsinit(int dev) {
    80003994:	7179                	addi	sp,sp,-48
    80003996:	f406                	sd	ra,40(sp)
    80003998:	f022                	sd	s0,32(sp)
    8000399a:	ec26                	sd	s1,24(sp)
    8000399c:	e84a                	sd	s2,16(sp)
    8000399e:	e44e                	sd	s3,8(sp)
    800039a0:	1800                	addi	s0,sp,48
    800039a2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039a4:	4585                	li	a1,1
    800039a6:	00000097          	auipc	ra,0x0
    800039aa:	a54080e7          	jalr	-1452(ra) # 800033fa <bread>
    800039ae:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039b0:	0001c997          	auipc	s3,0x1c
    800039b4:	a2098993          	addi	s3,s3,-1504 # 8001f3d0 <sb>
    800039b8:	02000613          	li	a2,32
    800039bc:	05850593          	addi	a1,a0,88
    800039c0:	854e                	mv	a0,s3
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	36c080e7          	jalr	876(ra) # 80000d2e <memmove>
  brelse(bp);
    800039ca:	8526                	mv	a0,s1
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	b5e080e7          	jalr	-1186(ra) # 8000352a <brelse>
  if(sb.magic != FSMAGIC)
    800039d4:	0009a703          	lw	a4,0(s3)
    800039d8:	102037b7          	lui	a5,0x10203
    800039dc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039e0:	02f71263          	bne	a4,a5,80003a04 <fsinit+0x70>
  initlog(dev, &sb);
    800039e4:	0001c597          	auipc	a1,0x1c
    800039e8:	9ec58593          	addi	a1,a1,-1556 # 8001f3d0 <sb>
    800039ec:	854a                	mv	a0,s2
    800039ee:	00001097          	auipc	ra,0x1
    800039f2:	b4a080e7          	jalr	-1206(ra) # 80004538 <initlog>
}
    800039f6:	70a2                	ld	ra,40(sp)
    800039f8:	7402                	ld	s0,32(sp)
    800039fa:	64e2                	ld	s1,24(sp)
    800039fc:	6942                	ld	s2,16(sp)
    800039fe:	69a2                	ld	s3,8(sp)
    80003a00:	6145                	addi	sp,sp,48
    80003a02:	8082                	ret
    panic("invalid file system");
    80003a04:	00005517          	auipc	a0,0x5
    80003a08:	c9450513          	addi	a0,a0,-876 # 80008698 <syscalls+0x160>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	b34080e7          	jalr	-1228(ra) # 80000540 <panic>

0000000080003a14 <iinit>:
{
    80003a14:	7179                	addi	sp,sp,-48
    80003a16:	f406                	sd	ra,40(sp)
    80003a18:	f022                	sd	s0,32(sp)
    80003a1a:	ec26                	sd	s1,24(sp)
    80003a1c:	e84a                	sd	s2,16(sp)
    80003a1e:	e44e                	sd	s3,8(sp)
    80003a20:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a22:	00005597          	auipc	a1,0x5
    80003a26:	c8e58593          	addi	a1,a1,-882 # 800086b0 <syscalls+0x178>
    80003a2a:	0001c517          	auipc	a0,0x1c
    80003a2e:	9c650513          	addi	a0,a0,-1594 # 8001f3f0 <itable>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	114080e7          	jalr	276(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a3a:	0001c497          	auipc	s1,0x1c
    80003a3e:	9de48493          	addi	s1,s1,-1570 # 8001f418 <itable+0x28>
    80003a42:	0001d997          	auipc	s3,0x1d
    80003a46:	46698993          	addi	s3,s3,1126 # 80020ea8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a4a:	00005917          	auipc	s2,0x5
    80003a4e:	c6e90913          	addi	s2,s2,-914 # 800086b8 <syscalls+0x180>
    80003a52:	85ca                	mv	a1,s2
    80003a54:	8526                	mv	a0,s1
    80003a56:	00001097          	auipc	ra,0x1
    80003a5a:	e42080e7          	jalr	-446(ra) # 80004898 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a5e:	08848493          	addi	s1,s1,136
    80003a62:	ff3498e3          	bne	s1,s3,80003a52 <iinit+0x3e>
}
    80003a66:	70a2                	ld	ra,40(sp)
    80003a68:	7402                	ld	s0,32(sp)
    80003a6a:	64e2                	ld	s1,24(sp)
    80003a6c:	6942                	ld	s2,16(sp)
    80003a6e:	69a2                	ld	s3,8(sp)
    80003a70:	6145                	addi	sp,sp,48
    80003a72:	8082                	ret

0000000080003a74 <ialloc>:
{
    80003a74:	715d                	addi	sp,sp,-80
    80003a76:	e486                	sd	ra,72(sp)
    80003a78:	e0a2                	sd	s0,64(sp)
    80003a7a:	fc26                	sd	s1,56(sp)
    80003a7c:	f84a                	sd	s2,48(sp)
    80003a7e:	f44e                	sd	s3,40(sp)
    80003a80:	f052                	sd	s4,32(sp)
    80003a82:	ec56                	sd	s5,24(sp)
    80003a84:	e85a                	sd	s6,16(sp)
    80003a86:	e45e                	sd	s7,8(sp)
    80003a88:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a8a:	0001c717          	auipc	a4,0x1c
    80003a8e:	95272703          	lw	a4,-1710(a4) # 8001f3dc <sb+0xc>
    80003a92:	4785                	li	a5,1
    80003a94:	04e7fa63          	bgeu	a5,a4,80003ae8 <ialloc+0x74>
    80003a98:	8aaa                	mv	s5,a0
    80003a9a:	8bae                	mv	s7,a1
    80003a9c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a9e:	0001ca17          	auipc	s4,0x1c
    80003aa2:	932a0a13          	addi	s4,s4,-1742 # 8001f3d0 <sb>
    80003aa6:	00048b1b          	sext.w	s6,s1
    80003aaa:	0044d593          	srli	a1,s1,0x4
    80003aae:	018a2783          	lw	a5,24(s4)
    80003ab2:	9dbd                	addw	a1,a1,a5
    80003ab4:	8556                	mv	a0,s5
    80003ab6:	00000097          	auipc	ra,0x0
    80003aba:	944080e7          	jalr	-1724(ra) # 800033fa <bread>
    80003abe:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ac0:	05850993          	addi	s3,a0,88
    80003ac4:	00f4f793          	andi	a5,s1,15
    80003ac8:	079a                	slli	a5,a5,0x6
    80003aca:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003acc:	00099783          	lh	a5,0(s3)
    80003ad0:	c3a1                	beqz	a5,80003b10 <ialloc+0x9c>
    brelse(bp);
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	a58080e7          	jalr	-1448(ra) # 8000352a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ada:	0485                	addi	s1,s1,1
    80003adc:	00ca2703          	lw	a4,12(s4)
    80003ae0:	0004879b          	sext.w	a5,s1
    80003ae4:	fce7e1e3          	bltu	a5,a4,80003aa6 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ae8:	00005517          	auipc	a0,0x5
    80003aec:	bd850513          	addi	a0,a0,-1064 # 800086c0 <syscalls+0x188>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	a9a080e7          	jalr	-1382(ra) # 8000058a <printf>
  return 0;
    80003af8:	4501                	li	a0,0
}
    80003afa:	60a6                	ld	ra,72(sp)
    80003afc:	6406                	ld	s0,64(sp)
    80003afe:	74e2                	ld	s1,56(sp)
    80003b00:	7942                	ld	s2,48(sp)
    80003b02:	79a2                	ld	s3,40(sp)
    80003b04:	7a02                	ld	s4,32(sp)
    80003b06:	6ae2                	ld	s5,24(sp)
    80003b08:	6b42                	ld	s6,16(sp)
    80003b0a:	6ba2                	ld	s7,8(sp)
    80003b0c:	6161                	addi	sp,sp,80
    80003b0e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b10:	04000613          	li	a2,64
    80003b14:	4581                	li	a1,0
    80003b16:	854e                	mv	a0,s3
    80003b18:	ffffd097          	auipc	ra,0xffffd
    80003b1c:	1ba080e7          	jalr	442(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b20:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b24:	854a                	mv	a0,s2
    80003b26:	00001097          	auipc	ra,0x1
    80003b2a:	c8e080e7          	jalr	-882(ra) # 800047b4 <log_write>
      brelse(bp);
    80003b2e:	854a                	mv	a0,s2
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	9fa080e7          	jalr	-1542(ra) # 8000352a <brelse>
      return iget(dev, inum);
    80003b38:	85da                	mv	a1,s6
    80003b3a:	8556                	mv	a0,s5
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	d9c080e7          	jalr	-612(ra) # 800038d8 <iget>
    80003b44:	bf5d                	j	80003afa <ialloc+0x86>

0000000080003b46 <iupdate>:
{
    80003b46:	1101                	addi	sp,sp,-32
    80003b48:	ec06                	sd	ra,24(sp)
    80003b4a:	e822                	sd	s0,16(sp)
    80003b4c:	e426                	sd	s1,8(sp)
    80003b4e:	e04a                	sd	s2,0(sp)
    80003b50:	1000                	addi	s0,sp,32
    80003b52:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b54:	415c                	lw	a5,4(a0)
    80003b56:	0047d79b          	srliw	a5,a5,0x4
    80003b5a:	0001c597          	auipc	a1,0x1c
    80003b5e:	88e5a583          	lw	a1,-1906(a1) # 8001f3e8 <sb+0x18>
    80003b62:	9dbd                	addw	a1,a1,a5
    80003b64:	4108                	lw	a0,0(a0)
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	894080e7          	jalr	-1900(ra) # 800033fa <bread>
    80003b6e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b70:	05850793          	addi	a5,a0,88
    80003b74:	40d8                	lw	a4,4(s1)
    80003b76:	8b3d                	andi	a4,a4,15
    80003b78:	071a                	slli	a4,a4,0x6
    80003b7a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b7c:	04449703          	lh	a4,68(s1)
    80003b80:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b84:	04649703          	lh	a4,70(s1)
    80003b88:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b8c:	04849703          	lh	a4,72(s1)
    80003b90:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b94:	04a49703          	lh	a4,74(s1)
    80003b98:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b9c:	44f8                	lw	a4,76(s1)
    80003b9e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ba0:	03400613          	li	a2,52
    80003ba4:	05048593          	addi	a1,s1,80
    80003ba8:	00c78513          	addi	a0,a5,12
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	182080e7          	jalr	386(ra) # 80000d2e <memmove>
  log_write(bp);
    80003bb4:	854a                	mv	a0,s2
    80003bb6:	00001097          	auipc	ra,0x1
    80003bba:	bfe080e7          	jalr	-1026(ra) # 800047b4 <log_write>
  brelse(bp);
    80003bbe:	854a                	mv	a0,s2
    80003bc0:	00000097          	auipc	ra,0x0
    80003bc4:	96a080e7          	jalr	-1686(ra) # 8000352a <brelse>
}
    80003bc8:	60e2                	ld	ra,24(sp)
    80003bca:	6442                	ld	s0,16(sp)
    80003bcc:	64a2                	ld	s1,8(sp)
    80003bce:	6902                	ld	s2,0(sp)
    80003bd0:	6105                	addi	sp,sp,32
    80003bd2:	8082                	ret

0000000080003bd4 <idup>:
{
    80003bd4:	1101                	addi	sp,sp,-32
    80003bd6:	ec06                	sd	ra,24(sp)
    80003bd8:	e822                	sd	s0,16(sp)
    80003bda:	e426                	sd	s1,8(sp)
    80003bdc:	1000                	addi	s0,sp,32
    80003bde:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003be0:	0001c517          	auipc	a0,0x1c
    80003be4:	81050513          	addi	a0,a0,-2032 # 8001f3f0 <itable>
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	fee080e7          	jalr	-18(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003bf0:	449c                	lw	a5,8(s1)
    80003bf2:	2785                	addiw	a5,a5,1
    80003bf4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bf6:	0001b517          	auipc	a0,0x1b
    80003bfa:	7fa50513          	addi	a0,a0,2042 # 8001f3f0 <itable>
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	08c080e7          	jalr	140(ra) # 80000c8a <release>
}
    80003c06:	8526                	mv	a0,s1
    80003c08:	60e2                	ld	ra,24(sp)
    80003c0a:	6442                	ld	s0,16(sp)
    80003c0c:	64a2                	ld	s1,8(sp)
    80003c0e:	6105                	addi	sp,sp,32
    80003c10:	8082                	ret

0000000080003c12 <ilock>:
{
    80003c12:	1101                	addi	sp,sp,-32
    80003c14:	ec06                	sd	ra,24(sp)
    80003c16:	e822                	sd	s0,16(sp)
    80003c18:	e426                	sd	s1,8(sp)
    80003c1a:	e04a                	sd	s2,0(sp)
    80003c1c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c1e:	c115                	beqz	a0,80003c42 <ilock+0x30>
    80003c20:	84aa                	mv	s1,a0
    80003c22:	451c                	lw	a5,8(a0)
    80003c24:	00f05f63          	blez	a5,80003c42 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c28:	0541                	addi	a0,a0,16
    80003c2a:	00001097          	auipc	ra,0x1
    80003c2e:	ca8080e7          	jalr	-856(ra) # 800048d2 <acquiresleep>
  if(ip->valid == 0){
    80003c32:	40bc                	lw	a5,64(s1)
    80003c34:	cf99                	beqz	a5,80003c52 <ilock+0x40>
}
    80003c36:	60e2                	ld	ra,24(sp)
    80003c38:	6442                	ld	s0,16(sp)
    80003c3a:	64a2                	ld	s1,8(sp)
    80003c3c:	6902                	ld	s2,0(sp)
    80003c3e:	6105                	addi	sp,sp,32
    80003c40:	8082                	ret
    panic("ilock");
    80003c42:	00005517          	auipc	a0,0x5
    80003c46:	a9650513          	addi	a0,a0,-1386 # 800086d8 <syscalls+0x1a0>
    80003c4a:	ffffd097          	auipc	ra,0xffffd
    80003c4e:	8f6080e7          	jalr	-1802(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c52:	40dc                	lw	a5,4(s1)
    80003c54:	0047d79b          	srliw	a5,a5,0x4
    80003c58:	0001b597          	auipc	a1,0x1b
    80003c5c:	7905a583          	lw	a1,1936(a1) # 8001f3e8 <sb+0x18>
    80003c60:	9dbd                	addw	a1,a1,a5
    80003c62:	4088                	lw	a0,0(s1)
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	796080e7          	jalr	1942(ra) # 800033fa <bread>
    80003c6c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c6e:	05850593          	addi	a1,a0,88
    80003c72:	40dc                	lw	a5,4(s1)
    80003c74:	8bbd                	andi	a5,a5,15
    80003c76:	079a                	slli	a5,a5,0x6
    80003c78:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c7a:	00059783          	lh	a5,0(a1)
    80003c7e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c82:	00259783          	lh	a5,2(a1)
    80003c86:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c8a:	00459783          	lh	a5,4(a1)
    80003c8e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c92:	00659783          	lh	a5,6(a1)
    80003c96:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c9a:	459c                	lw	a5,8(a1)
    80003c9c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c9e:	03400613          	li	a2,52
    80003ca2:	05b1                	addi	a1,a1,12
    80003ca4:	05048513          	addi	a0,s1,80
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	086080e7          	jalr	134(ra) # 80000d2e <memmove>
    brelse(bp);
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	878080e7          	jalr	-1928(ra) # 8000352a <brelse>
    ip->valid = 1;
    80003cba:	4785                	li	a5,1
    80003cbc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cbe:	04449783          	lh	a5,68(s1)
    80003cc2:	fbb5                	bnez	a5,80003c36 <ilock+0x24>
      panic("ilock: no type");
    80003cc4:	00005517          	auipc	a0,0x5
    80003cc8:	a1c50513          	addi	a0,a0,-1508 # 800086e0 <syscalls+0x1a8>
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	874080e7          	jalr	-1932(ra) # 80000540 <panic>

0000000080003cd4 <iunlock>:
{
    80003cd4:	1101                	addi	sp,sp,-32
    80003cd6:	ec06                	sd	ra,24(sp)
    80003cd8:	e822                	sd	s0,16(sp)
    80003cda:	e426                	sd	s1,8(sp)
    80003cdc:	e04a                	sd	s2,0(sp)
    80003cde:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ce0:	c905                	beqz	a0,80003d10 <iunlock+0x3c>
    80003ce2:	84aa                	mv	s1,a0
    80003ce4:	01050913          	addi	s2,a0,16
    80003ce8:	854a                	mv	a0,s2
    80003cea:	00001097          	auipc	ra,0x1
    80003cee:	c82080e7          	jalr	-894(ra) # 8000496c <holdingsleep>
    80003cf2:	cd19                	beqz	a0,80003d10 <iunlock+0x3c>
    80003cf4:	449c                	lw	a5,8(s1)
    80003cf6:	00f05d63          	blez	a5,80003d10 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cfa:	854a                	mv	a0,s2
    80003cfc:	00001097          	auipc	ra,0x1
    80003d00:	c2c080e7          	jalr	-980(ra) # 80004928 <releasesleep>
}
    80003d04:	60e2                	ld	ra,24(sp)
    80003d06:	6442                	ld	s0,16(sp)
    80003d08:	64a2                	ld	s1,8(sp)
    80003d0a:	6902                	ld	s2,0(sp)
    80003d0c:	6105                	addi	sp,sp,32
    80003d0e:	8082                	ret
    panic("iunlock");
    80003d10:	00005517          	auipc	a0,0x5
    80003d14:	9e050513          	addi	a0,a0,-1568 # 800086f0 <syscalls+0x1b8>
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	828080e7          	jalr	-2008(ra) # 80000540 <panic>

0000000080003d20 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d20:	7179                	addi	sp,sp,-48
    80003d22:	f406                	sd	ra,40(sp)
    80003d24:	f022                	sd	s0,32(sp)
    80003d26:	ec26                	sd	s1,24(sp)
    80003d28:	e84a                	sd	s2,16(sp)
    80003d2a:	e44e                	sd	s3,8(sp)
    80003d2c:	e052                	sd	s4,0(sp)
    80003d2e:	1800                	addi	s0,sp,48
    80003d30:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d32:	05050493          	addi	s1,a0,80
    80003d36:	08050913          	addi	s2,a0,128
    80003d3a:	a021                	j	80003d42 <itrunc+0x22>
    80003d3c:	0491                	addi	s1,s1,4
    80003d3e:	01248d63          	beq	s1,s2,80003d58 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d42:	408c                	lw	a1,0(s1)
    80003d44:	dde5                	beqz	a1,80003d3c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d46:	0009a503          	lw	a0,0(s3)
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	8f6080e7          	jalr	-1802(ra) # 80003640 <bfree>
      ip->addrs[i] = 0;
    80003d52:	0004a023          	sw	zero,0(s1)
    80003d56:	b7dd                	j	80003d3c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d58:	0809a583          	lw	a1,128(s3)
    80003d5c:	e185                	bnez	a1,80003d7c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d5e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d62:	854e                	mv	a0,s3
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	de2080e7          	jalr	-542(ra) # 80003b46 <iupdate>
}
    80003d6c:	70a2                	ld	ra,40(sp)
    80003d6e:	7402                	ld	s0,32(sp)
    80003d70:	64e2                	ld	s1,24(sp)
    80003d72:	6942                	ld	s2,16(sp)
    80003d74:	69a2                	ld	s3,8(sp)
    80003d76:	6a02                	ld	s4,0(sp)
    80003d78:	6145                	addi	sp,sp,48
    80003d7a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d7c:	0009a503          	lw	a0,0(s3)
    80003d80:	fffff097          	auipc	ra,0xfffff
    80003d84:	67a080e7          	jalr	1658(ra) # 800033fa <bread>
    80003d88:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d8a:	05850493          	addi	s1,a0,88
    80003d8e:	45850913          	addi	s2,a0,1112
    80003d92:	a021                	j	80003d9a <itrunc+0x7a>
    80003d94:	0491                	addi	s1,s1,4
    80003d96:	01248b63          	beq	s1,s2,80003dac <itrunc+0x8c>
      if(a[j])
    80003d9a:	408c                	lw	a1,0(s1)
    80003d9c:	dde5                	beqz	a1,80003d94 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d9e:	0009a503          	lw	a0,0(s3)
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	89e080e7          	jalr	-1890(ra) # 80003640 <bfree>
    80003daa:	b7ed                	j	80003d94 <itrunc+0x74>
    brelse(bp);
    80003dac:	8552                	mv	a0,s4
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	77c080e7          	jalr	1916(ra) # 8000352a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003db6:	0809a583          	lw	a1,128(s3)
    80003dba:	0009a503          	lw	a0,0(s3)
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	882080e7          	jalr	-1918(ra) # 80003640 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003dc6:	0809a023          	sw	zero,128(s3)
    80003dca:	bf51                	j	80003d5e <itrunc+0x3e>

0000000080003dcc <iput>:
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	e04a                	sd	s2,0(sp)
    80003dd6:	1000                	addi	s0,sp,32
    80003dd8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dda:	0001b517          	auipc	a0,0x1b
    80003dde:	61650513          	addi	a0,a0,1558 # 8001f3f0 <itable>
    80003de2:	ffffd097          	auipc	ra,0xffffd
    80003de6:	df4080e7          	jalr	-524(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dea:	4498                	lw	a4,8(s1)
    80003dec:	4785                	li	a5,1
    80003dee:	02f70363          	beq	a4,a5,80003e14 <iput+0x48>
  ip->ref--;
    80003df2:	449c                	lw	a5,8(s1)
    80003df4:	37fd                	addiw	a5,a5,-1
    80003df6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003df8:	0001b517          	auipc	a0,0x1b
    80003dfc:	5f850513          	addi	a0,a0,1528 # 8001f3f0 <itable>
    80003e00:	ffffd097          	auipc	ra,0xffffd
    80003e04:	e8a080e7          	jalr	-374(ra) # 80000c8a <release>
}
    80003e08:	60e2                	ld	ra,24(sp)
    80003e0a:	6442                	ld	s0,16(sp)
    80003e0c:	64a2                	ld	s1,8(sp)
    80003e0e:	6902                	ld	s2,0(sp)
    80003e10:	6105                	addi	sp,sp,32
    80003e12:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e14:	40bc                	lw	a5,64(s1)
    80003e16:	dff1                	beqz	a5,80003df2 <iput+0x26>
    80003e18:	04a49783          	lh	a5,74(s1)
    80003e1c:	fbf9                	bnez	a5,80003df2 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e1e:	01048913          	addi	s2,s1,16
    80003e22:	854a                	mv	a0,s2
    80003e24:	00001097          	auipc	ra,0x1
    80003e28:	aae080e7          	jalr	-1362(ra) # 800048d2 <acquiresleep>
    release(&itable.lock);
    80003e2c:	0001b517          	auipc	a0,0x1b
    80003e30:	5c450513          	addi	a0,a0,1476 # 8001f3f0 <itable>
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	e56080e7          	jalr	-426(ra) # 80000c8a <release>
    itrunc(ip);
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	ee2080e7          	jalr	-286(ra) # 80003d20 <itrunc>
    ip->type = 0;
    80003e46:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e4a:	8526                	mv	a0,s1
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	cfa080e7          	jalr	-774(ra) # 80003b46 <iupdate>
    ip->valid = 0;
    80003e54:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e58:	854a                	mv	a0,s2
    80003e5a:	00001097          	auipc	ra,0x1
    80003e5e:	ace080e7          	jalr	-1330(ra) # 80004928 <releasesleep>
    acquire(&itable.lock);
    80003e62:	0001b517          	auipc	a0,0x1b
    80003e66:	58e50513          	addi	a0,a0,1422 # 8001f3f0 <itable>
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	d6c080e7          	jalr	-660(ra) # 80000bd6 <acquire>
    80003e72:	b741                	j	80003df2 <iput+0x26>

0000000080003e74 <iunlockput>:
{
    80003e74:	1101                	addi	sp,sp,-32
    80003e76:	ec06                	sd	ra,24(sp)
    80003e78:	e822                	sd	s0,16(sp)
    80003e7a:	e426                	sd	s1,8(sp)
    80003e7c:	1000                	addi	s0,sp,32
    80003e7e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	e54080e7          	jalr	-428(ra) # 80003cd4 <iunlock>
  iput(ip);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	f42080e7          	jalr	-190(ra) # 80003dcc <iput>
}
    80003e92:	60e2                	ld	ra,24(sp)
    80003e94:	6442                	ld	s0,16(sp)
    80003e96:	64a2                	ld	s1,8(sp)
    80003e98:	6105                	addi	sp,sp,32
    80003e9a:	8082                	ret

0000000080003e9c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e9c:	1141                	addi	sp,sp,-16
    80003e9e:	e422                	sd	s0,8(sp)
    80003ea0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ea2:	411c                	lw	a5,0(a0)
    80003ea4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ea6:	415c                	lw	a5,4(a0)
    80003ea8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003eaa:	04451783          	lh	a5,68(a0)
    80003eae:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003eb2:	04a51783          	lh	a5,74(a0)
    80003eb6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003eba:	04c56783          	lwu	a5,76(a0)
    80003ebe:	e99c                	sd	a5,16(a1)
}
    80003ec0:	6422                	ld	s0,8(sp)
    80003ec2:	0141                	addi	sp,sp,16
    80003ec4:	8082                	ret

0000000080003ec6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ec6:	457c                	lw	a5,76(a0)
    80003ec8:	0ed7e963          	bltu	a5,a3,80003fba <readi+0xf4>
{
    80003ecc:	7159                	addi	sp,sp,-112
    80003ece:	f486                	sd	ra,104(sp)
    80003ed0:	f0a2                	sd	s0,96(sp)
    80003ed2:	eca6                	sd	s1,88(sp)
    80003ed4:	e8ca                	sd	s2,80(sp)
    80003ed6:	e4ce                	sd	s3,72(sp)
    80003ed8:	e0d2                	sd	s4,64(sp)
    80003eda:	fc56                	sd	s5,56(sp)
    80003edc:	f85a                	sd	s6,48(sp)
    80003ede:	f45e                	sd	s7,40(sp)
    80003ee0:	f062                	sd	s8,32(sp)
    80003ee2:	ec66                	sd	s9,24(sp)
    80003ee4:	e86a                	sd	s10,16(sp)
    80003ee6:	e46e                	sd	s11,8(sp)
    80003ee8:	1880                	addi	s0,sp,112
    80003eea:	8b2a                	mv	s6,a0
    80003eec:	8bae                	mv	s7,a1
    80003eee:	8a32                	mv	s4,a2
    80003ef0:	84b6                	mv	s1,a3
    80003ef2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ef4:	9f35                	addw	a4,a4,a3
    return 0;
    80003ef6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ef8:	0ad76063          	bltu	a4,a3,80003f98 <readi+0xd2>
  if(off + n > ip->size)
    80003efc:	00e7f463          	bgeu	a5,a4,80003f04 <readi+0x3e>
    n = ip->size - off;
    80003f00:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f04:	0a0a8963          	beqz	s5,80003fb6 <readi+0xf0>
    80003f08:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f0a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f0e:	5c7d                	li	s8,-1
    80003f10:	a82d                	j	80003f4a <readi+0x84>
    80003f12:	020d1d93          	slli	s11,s10,0x20
    80003f16:	020ddd93          	srli	s11,s11,0x20
    80003f1a:	05890613          	addi	a2,s2,88
    80003f1e:	86ee                	mv	a3,s11
    80003f20:	963a                	add	a2,a2,a4
    80003f22:	85d2                	mv	a1,s4
    80003f24:	855e                	mv	a0,s7
    80003f26:	fffff097          	auipc	ra,0xfffff
    80003f2a:	91a080e7          	jalr	-1766(ra) # 80002840 <either_copyout>
    80003f2e:	05850d63          	beq	a0,s8,80003f88 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f32:	854a                	mv	a0,s2
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	5f6080e7          	jalr	1526(ra) # 8000352a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f3c:	013d09bb          	addw	s3,s10,s3
    80003f40:	009d04bb          	addw	s1,s10,s1
    80003f44:	9a6e                	add	s4,s4,s11
    80003f46:	0559f763          	bgeu	s3,s5,80003f94 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f4a:	00a4d59b          	srliw	a1,s1,0xa
    80003f4e:	855a                	mv	a0,s6
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	89e080e7          	jalr	-1890(ra) # 800037ee <bmap>
    80003f58:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f5c:	cd85                	beqz	a1,80003f94 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f5e:	000b2503          	lw	a0,0(s6)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	498080e7          	jalr	1176(ra) # 800033fa <bread>
    80003f6a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6c:	3ff4f713          	andi	a4,s1,1023
    80003f70:	40ec87bb          	subw	a5,s9,a4
    80003f74:	413a86bb          	subw	a3,s5,s3
    80003f78:	8d3e                	mv	s10,a5
    80003f7a:	2781                	sext.w	a5,a5
    80003f7c:	0006861b          	sext.w	a2,a3
    80003f80:	f8f679e3          	bgeu	a2,a5,80003f12 <readi+0x4c>
    80003f84:	8d36                	mv	s10,a3
    80003f86:	b771                	j	80003f12 <readi+0x4c>
      brelse(bp);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	5a0080e7          	jalr	1440(ra) # 8000352a <brelse>
      tot = -1;
    80003f92:	59fd                	li	s3,-1
  }
  return tot;
    80003f94:	0009851b          	sext.w	a0,s3
}
    80003f98:	70a6                	ld	ra,104(sp)
    80003f9a:	7406                	ld	s0,96(sp)
    80003f9c:	64e6                	ld	s1,88(sp)
    80003f9e:	6946                	ld	s2,80(sp)
    80003fa0:	69a6                	ld	s3,72(sp)
    80003fa2:	6a06                	ld	s4,64(sp)
    80003fa4:	7ae2                	ld	s5,56(sp)
    80003fa6:	7b42                	ld	s6,48(sp)
    80003fa8:	7ba2                	ld	s7,40(sp)
    80003faa:	7c02                	ld	s8,32(sp)
    80003fac:	6ce2                	ld	s9,24(sp)
    80003fae:	6d42                	ld	s10,16(sp)
    80003fb0:	6da2                	ld	s11,8(sp)
    80003fb2:	6165                	addi	sp,sp,112
    80003fb4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fb6:	89d6                	mv	s3,s5
    80003fb8:	bff1                	j	80003f94 <readi+0xce>
    return 0;
    80003fba:	4501                	li	a0,0
}
    80003fbc:	8082                	ret

0000000080003fbe <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fbe:	457c                	lw	a5,76(a0)
    80003fc0:	10d7e863          	bltu	a5,a3,800040d0 <writei+0x112>
{
    80003fc4:	7159                	addi	sp,sp,-112
    80003fc6:	f486                	sd	ra,104(sp)
    80003fc8:	f0a2                	sd	s0,96(sp)
    80003fca:	eca6                	sd	s1,88(sp)
    80003fcc:	e8ca                	sd	s2,80(sp)
    80003fce:	e4ce                	sd	s3,72(sp)
    80003fd0:	e0d2                	sd	s4,64(sp)
    80003fd2:	fc56                	sd	s5,56(sp)
    80003fd4:	f85a                	sd	s6,48(sp)
    80003fd6:	f45e                	sd	s7,40(sp)
    80003fd8:	f062                	sd	s8,32(sp)
    80003fda:	ec66                	sd	s9,24(sp)
    80003fdc:	e86a                	sd	s10,16(sp)
    80003fde:	e46e                	sd	s11,8(sp)
    80003fe0:	1880                	addi	s0,sp,112
    80003fe2:	8aaa                	mv	s5,a0
    80003fe4:	8bae                	mv	s7,a1
    80003fe6:	8a32                	mv	s4,a2
    80003fe8:	8936                	mv	s2,a3
    80003fea:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fec:	00e687bb          	addw	a5,a3,a4
    80003ff0:	0ed7e263          	bltu	a5,a3,800040d4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ff4:	00043737          	lui	a4,0x43
    80003ff8:	0ef76063          	bltu	a4,a5,800040d8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ffc:	0c0b0863          	beqz	s6,800040cc <writei+0x10e>
    80004000:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004002:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004006:	5c7d                	li	s8,-1
    80004008:	a091                	j	8000404c <writei+0x8e>
    8000400a:	020d1d93          	slli	s11,s10,0x20
    8000400e:	020ddd93          	srli	s11,s11,0x20
    80004012:	05848513          	addi	a0,s1,88
    80004016:	86ee                	mv	a3,s11
    80004018:	8652                	mv	a2,s4
    8000401a:	85de                	mv	a1,s7
    8000401c:	953a                	add	a0,a0,a4
    8000401e:	fffff097          	auipc	ra,0xfffff
    80004022:	878080e7          	jalr	-1928(ra) # 80002896 <either_copyin>
    80004026:	07850263          	beq	a0,s8,8000408a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000402a:	8526                	mv	a0,s1
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	788080e7          	jalr	1928(ra) # 800047b4 <log_write>
    brelse(bp);
    80004034:	8526                	mv	a0,s1
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	4f4080e7          	jalr	1268(ra) # 8000352a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000403e:	013d09bb          	addw	s3,s10,s3
    80004042:	012d093b          	addw	s2,s10,s2
    80004046:	9a6e                	add	s4,s4,s11
    80004048:	0569f663          	bgeu	s3,s6,80004094 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000404c:	00a9559b          	srliw	a1,s2,0xa
    80004050:	8556                	mv	a0,s5
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	79c080e7          	jalr	1948(ra) # 800037ee <bmap>
    8000405a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000405e:	c99d                	beqz	a1,80004094 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004060:	000aa503          	lw	a0,0(s5)
    80004064:	fffff097          	auipc	ra,0xfffff
    80004068:	396080e7          	jalr	918(ra) # 800033fa <bread>
    8000406c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000406e:	3ff97713          	andi	a4,s2,1023
    80004072:	40ec87bb          	subw	a5,s9,a4
    80004076:	413b06bb          	subw	a3,s6,s3
    8000407a:	8d3e                	mv	s10,a5
    8000407c:	2781                	sext.w	a5,a5
    8000407e:	0006861b          	sext.w	a2,a3
    80004082:	f8f674e3          	bgeu	a2,a5,8000400a <writei+0x4c>
    80004086:	8d36                	mv	s10,a3
    80004088:	b749                	j	8000400a <writei+0x4c>
      brelse(bp);
    8000408a:	8526                	mv	a0,s1
    8000408c:	fffff097          	auipc	ra,0xfffff
    80004090:	49e080e7          	jalr	1182(ra) # 8000352a <brelse>
  }

  if(off > ip->size)
    80004094:	04caa783          	lw	a5,76(s5)
    80004098:	0127f463          	bgeu	a5,s2,800040a0 <writei+0xe2>
    ip->size = off;
    8000409c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040a0:	8556                	mv	a0,s5
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	aa4080e7          	jalr	-1372(ra) # 80003b46 <iupdate>

  return tot;
    800040aa:	0009851b          	sext.w	a0,s3
}
    800040ae:	70a6                	ld	ra,104(sp)
    800040b0:	7406                	ld	s0,96(sp)
    800040b2:	64e6                	ld	s1,88(sp)
    800040b4:	6946                	ld	s2,80(sp)
    800040b6:	69a6                	ld	s3,72(sp)
    800040b8:	6a06                	ld	s4,64(sp)
    800040ba:	7ae2                	ld	s5,56(sp)
    800040bc:	7b42                	ld	s6,48(sp)
    800040be:	7ba2                	ld	s7,40(sp)
    800040c0:	7c02                	ld	s8,32(sp)
    800040c2:	6ce2                	ld	s9,24(sp)
    800040c4:	6d42                	ld	s10,16(sp)
    800040c6:	6da2                	ld	s11,8(sp)
    800040c8:	6165                	addi	sp,sp,112
    800040ca:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040cc:	89da                	mv	s3,s6
    800040ce:	bfc9                	j	800040a0 <writei+0xe2>
    return -1;
    800040d0:	557d                	li	a0,-1
}
    800040d2:	8082                	ret
    return -1;
    800040d4:	557d                	li	a0,-1
    800040d6:	bfe1                	j	800040ae <writei+0xf0>
    return -1;
    800040d8:	557d                	li	a0,-1
    800040da:	bfd1                	j	800040ae <writei+0xf0>

00000000800040dc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040dc:	1141                	addi	sp,sp,-16
    800040de:	e406                	sd	ra,8(sp)
    800040e0:	e022                	sd	s0,0(sp)
    800040e2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040e4:	4639                	li	a2,14
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	cbc080e7          	jalr	-836(ra) # 80000da2 <strncmp>
}
    800040ee:	60a2                	ld	ra,8(sp)
    800040f0:	6402                	ld	s0,0(sp)
    800040f2:	0141                	addi	sp,sp,16
    800040f4:	8082                	ret

00000000800040f6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040f6:	7139                	addi	sp,sp,-64
    800040f8:	fc06                	sd	ra,56(sp)
    800040fa:	f822                	sd	s0,48(sp)
    800040fc:	f426                	sd	s1,40(sp)
    800040fe:	f04a                	sd	s2,32(sp)
    80004100:	ec4e                	sd	s3,24(sp)
    80004102:	e852                	sd	s4,16(sp)
    80004104:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004106:	04451703          	lh	a4,68(a0)
    8000410a:	4785                	li	a5,1
    8000410c:	00f71a63          	bne	a4,a5,80004120 <dirlookup+0x2a>
    80004110:	892a                	mv	s2,a0
    80004112:	89ae                	mv	s3,a1
    80004114:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004116:	457c                	lw	a5,76(a0)
    80004118:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000411a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411c:	e79d                	bnez	a5,8000414a <dirlookup+0x54>
    8000411e:	a8a5                	j	80004196 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004120:	00004517          	auipc	a0,0x4
    80004124:	5d850513          	addi	a0,a0,1496 # 800086f8 <syscalls+0x1c0>
    80004128:	ffffc097          	auipc	ra,0xffffc
    8000412c:	418080e7          	jalr	1048(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004130:	00004517          	auipc	a0,0x4
    80004134:	5e050513          	addi	a0,a0,1504 # 80008710 <syscalls+0x1d8>
    80004138:	ffffc097          	auipc	ra,0xffffc
    8000413c:	408080e7          	jalr	1032(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004140:	24c1                	addiw	s1,s1,16
    80004142:	04c92783          	lw	a5,76(s2)
    80004146:	04f4f763          	bgeu	s1,a5,80004194 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000414a:	4741                	li	a4,16
    8000414c:	86a6                	mv	a3,s1
    8000414e:	fc040613          	addi	a2,s0,-64
    80004152:	4581                	li	a1,0
    80004154:	854a                	mv	a0,s2
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	d70080e7          	jalr	-656(ra) # 80003ec6 <readi>
    8000415e:	47c1                	li	a5,16
    80004160:	fcf518e3          	bne	a0,a5,80004130 <dirlookup+0x3a>
    if(de.inum == 0)
    80004164:	fc045783          	lhu	a5,-64(s0)
    80004168:	dfe1                	beqz	a5,80004140 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000416a:	fc240593          	addi	a1,s0,-62
    8000416e:	854e                	mv	a0,s3
    80004170:	00000097          	auipc	ra,0x0
    80004174:	f6c080e7          	jalr	-148(ra) # 800040dc <namecmp>
    80004178:	f561                	bnez	a0,80004140 <dirlookup+0x4a>
      if(poff)
    8000417a:	000a0463          	beqz	s4,80004182 <dirlookup+0x8c>
        *poff = off;
    8000417e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004182:	fc045583          	lhu	a1,-64(s0)
    80004186:	00092503          	lw	a0,0(s2)
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	74e080e7          	jalr	1870(ra) # 800038d8 <iget>
    80004192:	a011                	j	80004196 <dirlookup+0xa0>
  return 0;
    80004194:	4501                	li	a0,0
}
    80004196:	70e2                	ld	ra,56(sp)
    80004198:	7442                	ld	s0,48(sp)
    8000419a:	74a2                	ld	s1,40(sp)
    8000419c:	7902                	ld	s2,32(sp)
    8000419e:	69e2                	ld	s3,24(sp)
    800041a0:	6a42                	ld	s4,16(sp)
    800041a2:	6121                	addi	sp,sp,64
    800041a4:	8082                	ret

00000000800041a6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041a6:	711d                	addi	sp,sp,-96
    800041a8:	ec86                	sd	ra,88(sp)
    800041aa:	e8a2                	sd	s0,80(sp)
    800041ac:	e4a6                	sd	s1,72(sp)
    800041ae:	e0ca                	sd	s2,64(sp)
    800041b0:	fc4e                	sd	s3,56(sp)
    800041b2:	f852                	sd	s4,48(sp)
    800041b4:	f456                	sd	s5,40(sp)
    800041b6:	f05a                	sd	s6,32(sp)
    800041b8:	ec5e                	sd	s7,24(sp)
    800041ba:	e862                	sd	s8,16(sp)
    800041bc:	e466                	sd	s9,8(sp)
    800041be:	e06a                	sd	s10,0(sp)
    800041c0:	1080                	addi	s0,sp,96
    800041c2:	84aa                	mv	s1,a0
    800041c4:	8b2e                	mv	s6,a1
    800041c6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041c8:	00054703          	lbu	a4,0(a0)
    800041cc:	02f00793          	li	a5,47
    800041d0:	02f70363          	beq	a4,a5,800041f6 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041d4:	ffffe097          	auipc	ra,0xffffe
    800041d8:	aae080e7          	jalr	-1362(ra) # 80001c82 <myproc>
    800041dc:	15853503          	ld	a0,344(a0)
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	9f4080e7          	jalr	-1548(ra) # 80003bd4 <idup>
    800041e8:	8a2a                	mv	s4,a0
  while(*path == '/')
    800041ea:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800041ee:	4cb5                	li	s9,13
  len = path - s;
    800041f0:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041f2:	4c05                	li	s8,1
    800041f4:	a87d                	j	800042b2 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800041f6:	4585                	li	a1,1
    800041f8:	4505                	li	a0,1
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	6de080e7          	jalr	1758(ra) # 800038d8 <iget>
    80004202:	8a2a                	mv	s4,a0
    80004204:	b7dd                	j	800041ea <namex+0x44>
      iunlockput(ip);
    80004206:	8552                	mv	a0,s4
    80004208:	00000097          	auipc	ra,0x0
    8000420c:	c6c080e7          	jalr	-916(ra) # 80003e74 <iunlockput>
      return 0;
    80004210:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004212:	8552                	mv	a0,s4
    80004214:	60e6                	ld	ra,88(sp)
    80004216:	6446                	ld	s0,80(sp)
    80004218:	64a6                	ld	s1,72(sp)
    8000421a:	6906                	ld	s2,64(sp)
    8000421c:	79e2                	ld	s3,56(sp)
    8000421e:	7a42                	ld	s4,48(sp)
    80004220:	7aa2                	ld	s5,40(sp)
    80004222:	7b02                	ld	s6,32(sp)
    80004224:	6be2                	ld	s7,24(sp)
    80004226:	6c42                	ld	s8,16(sp)
    80004228:	6ca2                	ld	s9,8(sp)
    8000422a:	6d02                	ld	s10,0(sp)
    8000422c:	6125                	addi	sp,sp,96
    8000422e:	8082                	ret
      iunlock(ip);
    80004230:	8552                	mv	a0,s4
    80004232:	00000097          	auipc	ra,0x0
    80004236:	aa2080e7          	jalr	-1374(ra) # 80003cd4 <iunlock>
      return ip;
    8000423a:	bfe1                	j	80004212 <namex+0x6c>
      iunlockput(ip);
    8000423c:	8552                	mv	a0,s4
    8000423e:	00000097          	auipc	ra,0x0
    80004242:	c36080e7          	jalr	-970(ra) # 80003e74 <iunlockput>
      return 0;
    80004246:	8a4e                	mv	s4,s3
    80004248:	b7e9                	j	80004212 <namex+0x6c>
  len = path - s;
    8000424a:	40998633          	sub	a2,s3,s1
    8000424e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004252:	09acd863          	bge	s9,s10,800042e2 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004256:	4639                	li	a2,14
    80004258:	85a6                	mv	a1,s1
    8000425a:	8556                	mv	a0,s5
    8000425c:	ffffd097          	auipc	ra,0xffffd
    80004260:	ad2080e7          	jalr	-1326(ra) # 80000d2e <memmove>
    80004264:	84ce                	mv	s1,s3
  while(*path == '/')
    80004266:	0004c783          	lbu	a5,0(s1)
    8000426a:	01279763          	bne	a5,s2,80004278 <namex+0xd2>
    path++;
    8000426e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004270:	0004c783          	lbu	a5,0(s1)
    80004274:	ff278de3          	beq	a5,s2,8000426e <namex+0xc8>
    ilock(ip);
    80004278:	8552                	mv	a0,s4
    8000427a:	00000097          	auipc	ra,0x0
    8000427e:	998080e7          	jalr	-1640(ra) # 80003c12 <ilock>
    if(ip->type != T_DIR){
    80004282:	044a1783          	lh	a5,68(s4)
    80004286:	f98790e3          	bne	a5,s8,80004206 <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000428a:	000b0563          	beqz	s6,80004294 <namex+0xee>
    8000428e:	0004c783          	lbu	a5,0(s1)
    80004292:	dfd9                	beqz	a5,80004230 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004294:	865e                	mv	a2,s7
    80004296:	85d6                	mv	a1,s5
    80004298:	8552                	mv	a0,s4
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	e5c080e7          	jalr	-420(ra) # 800040f6 <dirlookup>
    800042a2:	89aa                	mv	s3,a0
    800042a4:	dd41                	beqz	a0,8000423c <namex+0x96>
    iunlockput(ip);
    800042a6:	8552                	mv	a0,s4
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	bcc080e7          	jalr	-1076(ra) # 80003e74 <iunlockput>
    ip = next;
    800042b0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800042b2:	0004c783          	lbu	a5,0(s1)
    800042b6:	01279763          	bne	a5,s2,800042c4 <namex+0x11e>
    path++;
    800042ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042bc:	0004c783          	lbu	a5,0(s1)
    800042c0:	ff278de3          	beq	a5,s2,800042ba <namex+0x114>
  if(*path == 0)
    800042c4:	cb9d                	beqz	a5,800042fa <namex+0x154>
  while(*path != '/' && *path != 0)
    800042c6:	0004c783          	lbu	a5,0(s1)
    800042ca:	89a6                	mv	s3,s1
  len = path - s;
    800042cc:	8d5e                	mv	s10,s7
    800042ce:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800042d0:	01278963          	beq	a5,s2,800042e2 <namex+0x13c>
    800042d4:	dbbd                	beqz	a5,8000424a <namex+0xa4>
    path++;
    800042d6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800042d8:	0009c783          	lbu	a5,0(s3)
    800042dc:	ff279ce3          	bne	a5,s2,800042d4 <namex+0x12e>
    800042e0:	b7ad                	j	8000424a <namex+0xa4>
    memmove(name, s, len);
    800042e2:	2601                	sext.w	a2,a2
    800042e4:	85a6                	mv	a1,s1
    800042e6:	8556                	mv	a0,s5
    800042e8:	ffffd097          	auipc	ra,0xffffd
    800042ec:	a46080e7          	jalr	-1466(ra) # 80000d2e <memmove>
    name[len] = 0;
    800042f0:	9d56                	add	s10,s10,s5
    800042f2:	000d0023          	sb	zero,0(s10)
    800042f6:	84ce                	mv	s1,s3
    800042f8:	b7bd                	j	80004266 <namex+0xc0>
  if(nameiparent){
    800042fa:	f00b0ce3          	beqz	s6,80004212 <namex+0x6c>
    iput(ip);
    800042fe:	8552                	mv	a0,s4
    80004300:	00000097          	auipc	ra,0x0
    80004304:	acc080e7          	jalr	-1332(ra) # 80003dcc <iput>
    return 0;
    80004308:	4a01                	li	s4,0
    8000430a:	b721                	j	80004212 <namex+0x6c>

000000008000430c <dirlink>:
{
    8000430c:	7139                	addi	sp,sp,-64
    8000430e:	fc06                	sd	ra,56(sp)
    80004310:	f822                	sd	s0,48(sp)
    80004312:	f426                	sd	s1,40(sp)
    80004314:	f04a                	sd	s2,32(sp)
    80004316:	ec4e                	sd	s3,24(sp)
    80004318:	e852                	sd	s4,16(sp)
    8000431a:	0080                	addi	s0,sp,64
    8000431c:	892a                	mv	s2,a0
    8000431e:	8a2e                	mv	s4,a1
    80004320:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004322:	4601                	li	a2,0
    80004324:	00000097          	auipc	ra,0x0
    80004328:	dd2080e7          	jalr	-558(ra) # 800040f6 <dirlookup>
    8000432c:	e93d                	bnez	a0,800043a2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000432e:	04c92483          	lw	s1,76(s2)
    80004332:	c49d                	beqz	s1,80004360 <dirlink+0x54>
    80004334:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004336:	4741                	li	a4,16
    80004338:	86a6                	mv	a3,s1
    8000433a:	fc040613          	addi	a2,s0,-64
    8000433e:	4581                	li	a1,0
    80004340:	854a                	mv	a0,s2
    80004342:	00000097          	auipc	ra,0x0
    80004346:	b84080e7          	jalr	-1148(ra) # 80003ec6 <readi>
    8000434a:	47c1                	li	a5,16
    8000434c:	06f51163          	bne	a0,a5,800043ae <dirlink+0xa2>
    if(de.inum == 0)
    80004350:	fc045783          	lhu	a5,-64(s0)
    80004354:	c791                	beqz	a5,80004360 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004356:	24c1                	addiw	s1,s1,16
    80004358:	04c92783          	lw	a5,76(s2)
    8000435c:	fcf4ede3          	bltu	s1,a5,80004336 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004360:	4639                	li	a2,14
    80004362:	85d2                	mv	a1,s4
    80004364:	fc240513          	addi	a0,s0,-62
    80004368:	ffffd097          	auipc	ra,0xffffd
    8000436c:	a76080e7          	jalr	-1418(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004370:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004374:	4741                	li	a4,16
    80004376:	86a6                	mv	a3,s1
    80004378:	fc040613          	addi	a2,s0,-64
    8000437c:	4581                	li	a1,0
    8000437e:	854a                	mv	a0,s2
    80004380:	00000097          	auipc	ra,0x0
    80004384:	c3e080e7          	jalr	-962(ra) # 80003fbe <writei>
    80004388:	1541                	addi	a0,a0,-16
    8000438a:	00a03533          	snez	a0,a0
    8000438e:	40a00533          	neg	a0,a0
}
    80004392:	70e2                	ld	ra,56(sp)
    80004394:	7442                	ld	s0,48(sp)
    80004396:	74a2                	ld	s1,40(sp)
    80004398:	7902                	ld	s2,32(sp)
    8000439a:	69e2                	ld	s3,24(sp)
    8000439c:	6a42                	ld	s4,16(sp)
    8000439e:	6121                	addi	sp,sp,64
    800043a0:	8082                	ret
    iput(ip);
    800043a2:	00000097          	auipc	ra,0x0
    800043a6:	a2a080e7          	jalr	-1494(ra) # 80003dcc <iput>
    return -1;
    800043aa:	557d                	li	a0,-1
    800043ac:	b7dd                	j	80004392 <dirlink+0x86>
      panic("dirlink read");
    800043ae:	00004517          	auipc	a0,0x4
    800043b2:	37250513          	addi	a0,a0,882 # 80008720 <syscalls+0x1e8>
    800043b6:	ffffc097          	auipc	ra,0xffffc
    800043ba:	18a080e7          	jalr	394(ra) # 80000540 <panic>

00000000800043be <namei>:

struct inode*
namei(char *path)
{
    800043be:	1101                	addi	sp,sp,-32
    800043c0:	ec06                	sd	ra,24(sp)
    800043c2:	e822                	sd	s0,16(sp)
    800043c4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043c6:	fe040613          	addi	a2,s0,-32
    800043ca:	4581                	li	a1,0
    800043cc:	00000097          	auipc	ra,0x0
    800043d0:	dda080e7          	jalr	-550(ra) # 800041a6 <namex>
}
    800043d4:	60e2                	ld	ra,24(sp)
    800043d6:	6442                	ld	s0,16(sp)
    800043d8:	6105                	addi	sp,sp,32
    800043da:	8082                	ret

00000000800043dc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043dc:	1141                	addi	sp,sp,-16
    800043de:	e406                	sd	ra,8(sp)
    800043e0:	e022                	sd	s0,0(sp)
    800043e2:	0800                	addi	s0,sp,16
    800043e4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043e6:	4585                	li	a1,1
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	dbe080e7          	jalr	-578(ra) # 800041a6 <namex>
}
    800043f0:	60a2                	ld	ra,8(sp)
    800043f2:	6402                	ld	s0,0(sp)
    800043f4:	0141                	addi	sp,sp,16
    800043f6:	8082                	ret

00000000800043f8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043f8:	1101                	addi	sp,sp,-32
    800043fa:	ec06                	sd	ra,24(sp)
    800043fc:	e822                	sd	s0,16(sp)
    800043fe:	e426                	sd	s1,8(sp)
    80004400:	e04a                	sd	s2,0(sp)
    80004402:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004404:	0001d917          	auipc	s2,0x1d
    80004408:	a9490913          	addi	s2,s2,-1388 # 80020e98 <log>
    8000440c:	01892583          	lw	a1,24(s2)
    80004410:	02892503          	lw	a0,40(s2)
    80004414:	fffff097          	auipc	ra,0xfffff
    80004418:	fe6080e7          	jalr	-26(ra) # 800033fa <bread>
    8000441c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000441e:	02c92683          	lw	a3,44(s2)
    80004422:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004424:	02d05863          	blez	a3,80004454 <write_head+0x5c>
    80004428:	0001d797          	auipc	a5,0x1d
    8000442c:	aa078793          	addi	a5,a5,-1376 # 80020ec8 <log+0x30>
    80004430:	05c50713          	addi	a4,a0,92
    80004434:	36fd                	addiw	a3,a3,-1
    80004436:	02069613          	slli	a2,a3,0x20
    8000443a:	01e65693          	srli	a3,a2,0x1e
    8000443e:	0001d617          	auipc	a2,0x1d
    80004442:	a8e60613          	addi	a2,a2,-1394 # 80020ecc <log+0x34>
    80004446:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004448:	4390                	lw	a2,0(a5)
    8000444a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000444c:	0791                	addi	a5,a5,4
    8000444e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004450:	fed79ce3          	bne	a5,a3,80004448 <write_head+0x50>
  }
  bwrite(buf);
    80004454:	8526                	mv	a0,s1
    80004456:	fffff097          	auipc	ra,0xfffff
    8000445a:	096080e7          	jalr	150(ra) # 800034ec <bwrite>
  brelse(buf);
    8000445e:	8526                	mv	a0,s1
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	0ca080e7          	jalr	202(ra) # 8000352a <brelse>
}
    80004468:	60e2                	ld	ra,24(sp)
    8000446a:	6442                	ld	s0,16(sp)
    8000446c:	64a2                	ld	s1,8(sp)
    8000446e:	6902                	ld	s2,0(sp)
    80004470:	6105                	addi	sp,sp,32
    80004472:	8082                	ret

0000000080004474 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004474:	0001d797          	auipc	a5,0x1d
    80004478:	a507a783          	lw	a5,-1456(a5) # 80020ec4 <log+0x2c>
    8000447c:	0af05d63          	blez	a5,80004536 <install_trans+0xc2>
{
    80004480:	7139                	addi	sp,sp,-64
    80004482:	fc06                	sd	ra,56(sp)
    80004484:	f822                	sd	s0,48(sp)
    80004486:	f426                	sd	s1,40(sp)
    80004488:	f04a                	sd	s2,32(sp)
    8000448a:	ec4e                	sd	s3,24(sp)
    8000448c:	e852                	sd	s4,16(sp)
    8000448e:	e456                	sd	s5,8(sp)
    80004490:	e05a                	sd	s6,0(sp)
    80004492:	0080                	addi	s0,sp,64
    80004494:	8b2a                	mv	s6,a0
    80004496:	0001da97          	auipc	s5,0x1d
    8000449a:	a32a8a93          	addi	s5,s5,-1486 # 80020ec8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044a0:	0001d997          	auipc	s3,0x1d
    800044a4:	9f898993          	addi	s3,s3,-1544 # 80020e98 <log>
    800044a8:	a00d                	j	800044ca <install_trans+0x56>
    brelse(lbuf);
    800044aa:	854a                	mv	a0,s2
    800044ac:	fffff097          	auipc	ra,0xfffff
    800044b0:	07e080e7          	jalr	126(ra) # 8000352a <brelse>
    brelse(dbuf);
    800044b4:	8526                	mv	a0,s1
    800044b6:	fffff097          	auipc	ra,0xfffff
    800044ba:	074080e7          	jalr	116(ra) # 8000352a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044be:	2a05                	addiw	s4,s4,1
    800044c0:	0a91                	addi	s5,s5,4
    800044c2:	02c9a783          	lw	a5,44(s3)
    800044c6:	04fa5e63          	bge	s4,a5,80004522 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044ca:	0189a583          	lw	a1,24(s3)
    800044ce:	014585bb          	addw	a1,a1,s4
    800044d2:	2585                	addiw	a1,a1,1
    800044d4:	0289a503          	lw	a0,40(s3)
    800044d8:	fffff097          	auipc	ra,0xfffff
    800044dc:	f22080e7          	jalr	-222(ra) # 800033fa <bread>
    800044e0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044e2:	000aa583          	lw	a1,0(s5)
    800044e6:	0289a503          	lw	a0,40(s3)
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	f10080e7          	jalr	-240(ra) # 800033fa <bread>
    800044f2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044f4:	40000613          	li	a2,1024
    800044f8:	05890593          	addi	a1,s2,88
    800044fc:	05850513          	addi	a0,a0,88
    80004500:	ffffd097          	auipc	ra,0xffffd
    80004504:	82e080e7          	jalr	-2002(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004508:	8526                	mv	a0,s1
    8000450a:	fffff097          	auipc	ra,0xfffff
    8000450e:	fe2080e7          	jalr	-30(ra) # 800034ec <bwrite>
    if(recovering == 0)
    80004512:	f80b1ce3          	bnez	s6,800044aa <install_trans+0x36>
      bunpin(dbuf);
    80004516:	8526                	mv	a0,s1
    80004518:	fffff097          	auipc	ra,0xfffff
    8000451c:	0ec080e7          	jalr	236(ra) # 80003604 <bunpin>
    80004520:	b769                	j	800044aa <install_trans+0x36>
}
    80004522:	70e2                	ld	ra,56(sp)
    80004524:	7442                	ld	s0,48(sp)
    80004526:	74a2                	ld	s1,40(sp)
    80004528:	7902                	ld	s2,32(sp)
    8000452a:	69e2                	ld	s3,24(sp)
    8000452c:	6a42                	ld	s4,16(sp)
    8000452e:	6aa2                	ld	s5,8(sp)
    80004530:	6b02                	ld	s6,0(sp)
    80004532:	6121                	addi	sp,sp,64
    80004534:	8082                	ret
    80004536:	8082                	ret

0000000080004538 <initlog>:
{
    80004538:	7179                	addi	sp,sp,-48
    8000453a:	f406                	sd	ra,40(sp)
    8000453c:	f022                	sd	s0,32(sp)
    8000453e:	ec26                	sd	s1,24(sp)
    80004540:	e84a                	sd	s2,16(sp)
    80004542:	e44e                	sd	s3,8(sp)
    80004544:	1800                	addi	s0,sp,48
    80004546:	892a                	mv	s2,a0
    80004548:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000454a:	0001d497          	auipc	s1,0x1d
    8000454e:	94e48493          	addi	s1,s1,-1714 # 80020e98 <log>
    80004552:	00004597          	auipc	a1,0x4
    80004556:	1de58593          	addi	a1,a1,478 # 80008730 <syscalls+0x1f8>
    8000455a:	8526                	mv	a0,s1
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	5ea080e7          	jalr	1514(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004564:	0149a583          	lw	a1,20(s3)
    80004568:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000456a:	0109a783          	lw	a5,16(s3)
    8000456e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004570:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004574:	854a                	mv	a0,s2
    80004576:	fffff097          	auipc	ra,0xfffff
    8000457a:	e84080e7          	jalr	-380(ra) # 800033fa <bread>
  log.lh.n = lh->n;
    8000457e:	4d34                	lw	a3,88(a0)
    80004580:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004582:	02d05663          	blez	a3,800045ae <initlog+0x76>
    80004586:	05c50793          	addi	a5,a0,92
    8000458a:	0001d717          	auipc	a4,0x1d
    8000458e:	93e70713          	addi	a4,a4,-1730 # 80020ec8 <log+0x30>
    80004592:	36fd                	addiw	a3,a3,-1
    80004594:	02069613          	slli	a2,a3,0x20
    80004598:	01e65693          	srli	a3,a2,0x1e
    8000459c:	06050613          	addi	a2,a0,96
    800045a0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045a2:	4390                	lw	a2,0(a5)
    800045a4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045a6:	0791                	addi	a5,a5,4
    800045a8:	0711                	addi	a4,a4,4
    800045aa:	fed79ce3          	bne	a5,a3,800045a2 <initlog+0x6a>
  brelse(buf);
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	f7c080e7          	jalr	-132(ra) # 8000352a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045b6:	4505                	li	a0,1
    800045b8:	00000097          	auipc	ra,0x0
    800045bc:	ebc080e7          	jalr	-324(ra) # 80004474 <install_trans>
  log.lh.n = 0;
    800045c0:	0001d797          	auipc	a5,0x1d
    800045c4:	9007a223          	sw	zero,-1788(a5) # 80020ec4 <log+0x2c>
  write_head(); // clear the log
    800045c8:	00000097          	auipc	ra,0x0
    800045cc:	e30080e7          	jalr	-464(ra) # 800043f8 <write_head>
}
    800045d0:	70a2                	ld	ra,40(sp)
    800045d2:	7402                	ld	s0,32(sp)
    800045d4:	64e2                	ld	s1,24(sp)
    800045d6:	6942                	ld	s2,16(sp)
    800045d8:	69a2                	ld	s3,8(sp)
    800045da:	6145                	addi	sp,sp,48
    800045dc:	8082                	ret

00000000800045de <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045de:	1101                	addi	sp,sp,-32
    800045e0:	ec06                	sd	ra,24(sp)
    800045e2:	e822                	sd	s0,16(sp)
    800045e4:	e426                	sd	s1,8(sp)
    800045e6:	e04a                	sd	s2,0(sp)
    800045e8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045ea:	0001d517          	auipc	a0,0x1d
    800045ee:	8ae50513          	addi	a0,a0,-1874 # 80020e98 <log>
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	5e4080e7          	jalr	1508(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800045fa:	0001d497          	auipc	s1,0x1d
    800045fe:	89e48493          	addi	s1,s1,-1890 # 80020e98 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004602:	4979                	li	s2,30
    80004604:	a039                	j	80004612 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004606:	85a6                	mv	a1,s1
    80004608:	8526                	mv	a0,s1
    8000460a:	ffffe097          	auipc	ra,0xffffe
    8000460e:	e2e080e7          	jalr	-466(ra) # 80002438 <sleep>
    if(log.committing){
    80004612:	50dc                	lw	a5,36(s1)
    80004614:	fbed                	bnez	a5,80004606 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004616:	5098                	lw	a4,32(s1)
    80004618:	2705                	addiw	a4,a4,1
    8000461a:	0007069b          	sext.w	a3,a4
    8000461e:	0027179b          	slliw	a5,a4,0x2
    80004622:	9fb9                	addw	a5,a5,a4
    80004624:	0017979b          	slliw	a5,a5,0x1
    80004628:	54d8                	lw	a4,44(s1)
    8000462a:	9fb9                	addw	a5,a5,a4
    8000462c:	00f95963          	bge	s2,a5,8000463e <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004630:	85a6                	mv	a1,s1
    80004632:	8526                	mv	a0,s1
    80004634:	ffffe097          	auipc	ra,0xffffe
    80004638:	e04080e7          	jalr	-508(ra) # 80002438 <sleep>
    8000463c:	bfd9                	j	80004612 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000463e:	0001d517          	auipc	a0,0x1d
    80004642:	85a50513          	addi	a0,a0,-1958 # 80020e98 <log>
    80004646:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	642080e7          	jalr	1602(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004650:	60e2                	ld	ra,24(sp)
    80004652:	6442                	ld	s0,16(sp)
    80004654:	64a2                	ld	s1,8(sp)
    80004656:	6902                	ld	s2,0(sp)
    80004658:	6105                	addi	sp,sp,32
    8000465a:	8082                	ret

000000008000465c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000465c:	7139                	addi	sp,sp,-64
    8000465e:	fc06                	sd	ra,56(sp)
    80004660:	f822                	sd	s0,48(sp)
    80004662:	f426                	sd	s1,40(sp)
    80004664:	f04a                	sd	s2,32(sp)
    80004666:	ec4e                	sd	s3,24(sp)
    80004668:	e852                	sd	s4,16(sp)
    8000466a:	e456                	sd	s5,8(sp)
    8000466c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000466e:	0001d497          	auipc	s1,0x1d
    80004672:	82a48493          	addi	s1,s1,-2006 # 80020e98 <log>
    80004676:	8526                	mv	a0,s1
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	55e080e7          	jalr	1374(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004680:	509c                	lw	a5,32(s1)
    80004682:	37fd                	addiw	a5,a5,-1
    80004684:	0007891b          	sext.w	s2,a5
    80004688:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000468a:	50dc                	lw	a5,36(s1)
    8000468c:	e7b9                	bnez	a5,800046da <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000468e:	04091e63          	bnez	s2,800046ea <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004692:	0001d497          	auipc	s1,0x1d
    80004696:	80648493          	addi	s1,s1,-2042 # 80020e98 <log>
    8000469a:	4785                	li	a5,1
    8000469c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000469e:	8526                	mv	a0,s1
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	5ea080e7          	jalr	1514(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046a8:	54dc                	lw	a5,44(s1)
    800046aa:	06f04763          	bgtz	a5,80004718 <end_op+0xbc>
    acquire(&log.lock);
    800046ae:	0001c497          	auipc	s1,0x1c
    800046b2:	7ea48493          	addi	s1,s1,2026 # 80020e98 <log>
    800046b6:	8526                	mv	a0,s1
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	51e080e7          	jalr	1310(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800046c0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046c4:	8526                	mv	a0,s1
    800046c6:	ffffe097          	auipc	ra,0xffffe
    800046ca:	dd6080e7          	jalr	-554(ra) # 8000249c <wakeup>
    release(&log.lock);
    800046ce:	8526                	mv	a0,s1
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	5ba080e7          	jalr	1466(ra) # 80000c8a <release>
}
    800046d8:	a03d                	j	80004706 <end_op+0xaa>
    panic("log.committing");
    800046da:	00004517          	auipc	a0,0x4
    800046de:	05e50513          	addi	a0,a0,94 # 80008738 <syscalls+0x200>
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	e5e080e7          	jalr	-418(ra) # 80000540 <panic>
    wakeup(&log);
    800046ea:	0001c497          	auipc	s1,0x1c
    800046ee:	7ae48493          	addi	s1,s1,1966 # 80020e98 <log>
    800046f2:	8526                	mv	a0,s1
    800046f4:	ffffe097          	auipc	ra,0xffffe
    800046f8:	da8080e7          	jalr	-600(ra) # 8000249c <wakeup>
  release(&log.lock);
    800046fc:	8526                	mv	a0,s1
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	58c080e7          	jalr	1420(ra) # 80000c8a <release>
}
    80004706:	70e2                	ld	ra,56(sp)
    80004708:	7442                	ld	s0,48(sp)
    8000470a:	74a2                	ld	s1,40(sp)
    8000470c:	7902                	ld	s2,32(sp)
    8000470e:	69e2                	ld	s3,24(sp)
    80004710:	6a42                	ld	s4,16(sp)
    80004712:	6aa2                	ld	s5,8(sp)
    80004714:	6121                	addi	sp,sp,64
    80004716:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004718:	0001ca97          	auipc	s5,0x1c
    8000471c:	7b0a8a93          	addi	s5,s5,1968 # 80020ec8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004720:	0001ca17          	auipc	s4,0x1c
    80004724:	778a0a13          	addi	s4,s4,1912 # 80020e98 <log>
    80004728:	018a2583          	lw	a1,24(s4)
    8000472c:	012585bb          	addw	a1,a1,s2
    80004730:	2585                	addiw	a1,a1,1
    80004732:	028a2503          	lw	a0,40(s4)
    80004736:	fffff097          	auipc	ra,0xfffff
    8000473a:	cc4080e7          	jalr	-828(ra) # 800033fa <bread>
    8000473e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004740:	000aa583          	lw	a1,0(s5)
    80004744:	028a2503          	lw	a0,40(s4)
    80004748:	fffff097          	auipc	ra,0xfffff
    8000474c:	cb2080e7          	jalr	-846(ra) # 800033fa <bread>
    80004750:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004752:	40000613          	li	a2,1024
    80004756:	05850593          	addi	a1,a0,88
    8000475a:	05848513          	addi	a0,s1,88
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	5d0080e7          	jalr	1488(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004766:	8526                	mv	a0,s1
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	d84080e7          	jalr	-636(ra) # 800034ec <bwrite>
    brelse(from);
    80004770:	854e                	mv	a0,s3
    80004772:	fffff097          	auipc	ra,0xfffff
    80004776:	db8080e7          	jalr	-584(ra) # 8000352a <brelse>
    brelse(to);
    8000477a:	8526                	mv	a0,s1
    8000477c:	fffff097          	auipc	ra,0xfffff
    80004780:	dae080e7          	jalr	-594(ra) # 8000352a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004784:	2905                	addiw	s2,s2,1
    80004786:	0a91                	addi	s5,s5,4
    80004788:	02ca2783          	lw	a5,44(s4)
    8000478c:	f8f94ee3          	blt	s2,a5,80004728 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004790:	00000097          	auipc	ra,0x0
    80004794:	c68080e7          	jalr	-920(ra) # 800043f8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004798:	4501                	li	a0,0
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	cda080e7          	jalr	-806(ra) # 80004474 <install_trans>
    log.lh.n = 0;
    800047a2:	0001c797          	auipc	a5,0x1c
    800047a6:	7207a123          	sw	zero,1826(a5) # 80020ec4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047aa:	00000097          	auipc	ra,0x0
    800047ae:	c4e080e7          	jalr	-946(ra) # 800043f8 <write_head>
    800047b2:	bdf5                	j	800046ae <end_op+0x52>

00000000800047b4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047b4:	1101                	addi	sp,sp,-32
    800047b6:	ec06                	sd	ra,24(sp)
    800047b8:	e822                	sd	s0,16(sp)
    800047ba:	e426                	sd	s1,8(sp)
    800047bc:	e04a                	sd	s2,0(sp)
    800047be:	1000                	addi	s0,sp,32
    800047c0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047c2:	0001c917          	auipc	s2,0x1c
    800047c6:	6d690913          	addi	s2,s2,1750 # 80020e98 <log>
    800047ca:	854a                	mv	a0,s2
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	40a080e7          	jalr	1034(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047d4:	02c92603          	lw	a2,44(s2)
    800047d8:	47f5                	li	a5,29
    800047da:	06c7c563          	blt	a5,a2,80004844 <log_write+0x90>
    800047de:	0001c797          	auipc	a5,0x1c
    800047e2:	6d67a783          	lw	a5,1750(a5) # 80020eb4 <log+0x1c>
    800047e6:	37fd                	addiw	a5,a5,-1
    800047e8:	04f65e63          	bge	a2,a5,80004844 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047ec:	0001c797          	auipc	a5,0x1c
    800047f0:	6cc7a783          	lw	a5,1740(a5) # 80020eb8 <log+0x20>
    800047f4:	06f05063          	blez	a5,80004854 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047f8:	4781                	li	a5,0
    800047fa:	06c05563          	blez	a2,80004864 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047fe:	44cc                	lw	a1,12(s1)
    80004800:	0001c717          	auipc	a4,0x1c
    80004804:	6c870713          	addi	a4,a4,1736 # 80020ec8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004808:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000480a:	4314                	lw	a3,0(a4)
    8000480c:	04b68c63          	beq	a3,a1,80004864 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004810:	2785                	addiw	a5,a5,1
    80004812:	0711                	addi	a4,a4,4
    80004814:	fef61be3          	bne	a2,a5,8000480a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004818:	0621                	addi	a2,a2,8
    8000481a:	060a                	slli	a2,a2,0x2
    8000481c:	0001c797          	auipc	a5,0x1c
    80004820:	67c78793          	addi	a5,a5,1660 # 80020e98 <log>
    80004824:	97b2                	add	a5,a5,a2
    80004826:	44d8                	lw	a4,12(s1)
    80004828:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000482a:	8526                	mv	a0,s1
    8000482c:	fffff097          	auipc	ra,0xfffff
    80004830:	d9c080e7          	jalr	-612(ra) # 800035c8 <bpin>
    log.lh.n++;
    80004834:	0001c717          	auipc	a4,0x1c
    80004838:	66470713          	addi	a4,a4,1636 # 80020e98 <log>
    8000483c:	575c                	lw	a5,44(a4)
    8000483e:	2785                	addiw	a5,a5,1
    80004840:	d75c                	sw	a5,44(a4)
    80004842:	a82d                	j	8000487c <log_write+0xc8>
    panic("too big a transaction");
    80004844:	00004517          	auipc	a0,0x4
    80004848:	f0450513          	addi	a0,a0,-252 # 80008748 <syscalls+0x210>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	cf4080e7          	jalr	-780(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004854:	00004517          	auipc	a0,0x4
    80004858:	f0c50513          	addi	a0,a0,-244 # 80008760 <syscalls+0x228>
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	ce4080e7          	jalr	-796(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004864:	00878693          	addi	a3,a5,8
    80004868:	068a                	slli	a3,a3,0x2
    8000486a:	0001c717          	auipc	a4,0x1c
    8000486e:	62e70713          	addi	a4,a4,1582 # 80020e98 <log>
    80004872:	9736                	add	a4,a4,a3
    80004874:	44d4                	lw	a3,12(s1)
    80004876:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004878:	faf609e3          	beq	a2,a5,8000482a <log_write+0x76>
  }
  release(&log.lock);
    8000487c:	0001c517          	auipc	a0,0x1c
    80004880:	61c50513          	addi	a0,a0,1564 # 80020e98 <log>
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	406080e7          	jalr	1030(ra) # 80000c8a <release>
}
    8000488c:	60e2                	ld	ra,24(sp)
    8000488e:	6442                	ld	s0,16(sp)
    80004890:	64a2                	ld	s1,8(sp)
    80004892:	6902                	ld	s2,0(sp)
    80004894:	6105                	addi	sp,sp,32
    80004896:	8082                	ret

0000000080004898 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004898:	1101                	addi	sp,sp,-32
    8000489a:	ec06                	sd	ra,24(sp)
    8000489c:	e822                	sd	s0,16(sp)
    8000489e:	e426                	sd	s1,8(sp)
    800048a0:	e04a                	sd	s2,0(sp)
    800048a2:	1000                	addi	s0,sp,32
    800048a4:	84aa                	mv	s1,a0
    800048a6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048a8:	00004597          	auipc	a1,0x4
    800048ac:	ed858593          	addi	a1,a1,-296 # 80008780 <syscalls+0x248>
    800048b0:	0521                	addi	a0,a0,8
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	294080e7          	jalr	660(ra) # 80000b46 <initlock>
  lk->name = name;
    800048ba:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048be:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048c2:	0204a423          	sw	zero,40(s1)
}
    800048c6:	60e2                	ld	ra,24(sp)
    800048c8:	6442                	ld	s0,16(sp)
    800048ca:	64a2                	ld	s1,8(sp)
    800048cc:	6902                	ld	s2,0(sp)
    800048ce:	6105                	addi	sp,sp,32
    800048d0:	8082                	ret

00000000800048d2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048d2:	1101                	addi	sp,sp,-32
    800048d4:	ec06                	sd	ra,24(sp)
    800048d6:	e822                	sd	s0,16(sp)
    800048d8:	e426                	sd	s1,8(sp)
    800048da:	e04a                	sd	s2,0(sp)
    800048dc:	1000                	addi	s0,sp,32
    800048de:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048e0:	00850913          	addi	s2,a0,8
    800048e4:	854a                	mv	a0,s2
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	2f0080e7          	jalr	752(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800048ee:	409c                	lw	a5,0(s1)
    800048f0:	cb89                	beqz	a5,80004902 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048f2:	85ca                	mv	a1,s2
    800048f4:	8526                	mv	a0,s1
    800048f6:	ffffe097          	auipc	ra,0xffffe
    800048fa:	b42080e7          	jalr	-1214(ra) # 80002438 <sleep>
  while (lk->locked) {
    800048fe:	409c                	lw	a5,0(s1)
    80004900:	fbed                	bnez	a5,800048f2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004902:	4785                	li	a5,1
    80004904:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004906:	ffffd097          	auipc	ra,0xffffd
    8000490a:	37c080e7          	jalr	892(ra) # 80001c82 <myproc>
    8000490e:	591c                	lw	a5,48(a0)
    80004910:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004912:	854a                	mv	a0,s2
    80004914:	ffffc097          	auipc	ra,0xffffc
    80004918:	376080e7          	jalr	886(ra) # 80000c8a <release>
}
    8000491c:	60e2                	ld	ra,24(sp)
    8000491e:	6442                	ld	s0,16(sp)
    80004920:	64a2                	ld	s1,8(sp)
    80004922:	6902                	ld	s2,0(sp)
    80004924:	6105                	addi	sp,sp,32
    80004926:	8082                	ret

0000000080004928 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004928:	1101                	addi	sp,sp,-32
    8000492a:	ec06                	sd	ra,24(sp)
    8000492c:	e822                	sd	s0,16(sp)
    8000492e:	e426                	sd	s1,8(sp)
    80004930:	e04a                	sd	s2,0(sp)
    80004932:	1000                	addi	s0,sp,32
    80004934:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004936:	00850913          	addi	s2,a0,8
    8000493a:	854a                	mv	a0,s2
    8000493c:	ffffc097          	auipc	ra,0xffffc
    80004940:	29a080e7          	jalr	666(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004944:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004948:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000494c:	8526                	mv	a0,s1
    8000494e:	ffffe097          	auipc	ra,0xffffe
    80004952:	b4e080e7          	jalr	-1202(ra) # 8000249c <wakeup>
  release(&lk->lk);
    80004956:	854a                	mv	a0,s2
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80004960:	60e2                	ld	ra,24(sp)
    80004962:	6442                	ld	s0,16(sp)
    80004964:	64a2                	ld	s1,8(sp)
    80004966:	6902                	ld	s2,0(sp)
    80004968:	6105                	addi	sp,sp,32
    8000496a:	8082                	ret

000000008000496c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000496c:	7179                	addi	sp,sp,-48
    8000496e:	f406                	sd	ra,40(sp)
    80004970:	f022                	sd	s0,32(sp)
    80004972:	ec26                	sd	s1,24(sp)
    80004974:	e84a                	sd	s2,16(sp)
    80004976:	e44e                	sd	s3,8(sp)
    80004978:	1800                	addi	s0,sp,48
    8000497a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000497c:	00850913          	addi	s2,a0,8
    80004980:	854a                	mv	a0,s2
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	254080e7          	jalr	596(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000498a:	409c                	lw	a5,0(s1)
    8000498c:	ef99                	bnez	a5,800049aa <holdingsleep+0x3e>
    8000498e:	4481                	li	s1,0
  release(&lk->lk);
    80004990:	854a                	mv	a0,s2
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	2f8080e7          	jalr	760(ra) # 80000c8a <release>
  return r;
}
    8000499a:	8526                	mv	a0,s1
    8000499c:	70a2                	ld	ra,40(sp)
    8000499e:	7402                	ld	s0,32(sp)
    800049a0:	64e2                	ld	s1,24(sp)
    800049a2:	6942                	ld	s2,16(sp)
    800049a4:	69a2                	ld	s3,8(sp)
    800049a6:	6145                	addi	sp,sp,48
    800049a8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049aa:	0284a983          	lw	s3,40(s1)
    800049ae:	ffffd097          	auipc	ra,0xffffd
    800049b2:	2d4080e7          	jalr	724(ra) # 80001c82 <myproc>
    800049b6:	5904                	lw	s1,48(a0)
    800049b8:	413484b3          	sub	s1,s1,s3
    800049bc:	0014b493          	seqz	s1,s1
    800049c0:	bfc1                	j	80004990 <holdingsleep+0x24>

00000000800049c2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049c2:	1141                	addi	sp,sp,-16
    800049c4:	e406                	sd	ra,8(sp)
    800049c6:	e022                	sd	s0,0(sp)
    800049c8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049ca:	00004597          	auipc	a1,0x4
    800049ce:	dc658593          	addi	a1,a1,-570 # 80008790 <syscalls+0x258>
    800049d2:	0001c517          	auipc	a0,0x1c
    800049d6:	60e50513          	addi	a0,a0,1550 # 80020fe0 <ftable>
    800049da:	ffffc097          	auipc	ra,0xffffc
    800049de:	16c080e7          	jalr	364(ra) # 80000b46 <initlock>
}
    800049e2:	60a2                	ld	ra,8(sp)
    800049e4:	6402                	ld	s0,0(sp)
    800049e6:	0141                	addi	sp,sp,16
    800049e8:	8082                	ret

00000000800049ea <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049ea:	1101                	addi	sp,sp,-32
    800049ec:	ec06                	sd	ra,24(sp)
    800049ee:	e822                	sd	s0,16(sp)
    800049f0:	e426                	sd	s1,8(sp)
    800049f2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049f4:	0001c517          	auipc	a0,0x1c
    800049f8:	5ec50513          	addi	a0,a0,1516 # 80020fe0 <ftable>
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	1da080e7          	jalr	474(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a04:	0001c497          	auipc	s1,0x1c
    80004a08:	5f448493          	addi	s1,s1,1524 # 80020ff8 <ftable+0x18>
    80004a0c:	0001d717          	auipc	a4,0x1d
    80004a10:	58c70713          	addi	a4,a4,1420 # 80021f98 <disk>
    if(f->ref == 0){
    80004a14:	40dc                	lw	a5,4(s1)
    80004a16:	cf99                	beqz	a5,80004a34 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a18:	02848493          	addi	s1,s1,40
    80004a1c:	fee49ce3          	bne	s1,a4,80004a14 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a20:	0001c517          	auipc	a0,0x1c
    80004a24:	5c050513          	addi	a0,a0,1472 # 80020fe0 <ftable>
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	262080e7          	jalr	610(ra) # 80000c8a <release>
  return 0;
    80004a30:	4481                	li	s1,0
    80004a32:	a819                	j	80004a48 <filealloc+0x5e>
      f->ref = 1;
    80004a34:	4785                	li	a5,1
    80004a36:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a38:	0001c517          	auipc	a0,0x1c
    80004a3c:	5a850513          	addi	a0,a0,1448 # 80020fe0 <ftable>
    80004a40:	ffffc097          	auipc	ra,0xffffc
    80004a44:	24a080e7          	jalr	586(ra) # 80000c8a <release>
}
    80004a48:	8526                	mv	a0,s1
    80004a4a:	60e2                	ld	ra,24(sp)
    80004a4c:	6442                	ld	s0,16(sp)
    80004a4e:	64a2                	ld	s1,8(sp)
    80004a50:	6105                	addi	sp,sp,32
    80004a52:	8082                	ret

0000000080004a54 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a54:	1101                	addi	sp,sp,-32
    80004a56:	ec06                	sd	ra,24(sp)
    80004a58:	e822                	sd	s0,16(sp)
    80004a5a:	e426                	sd	s1,8(sp)
    80004a5c:	1000                	addi	s0,sp,32
    80004a5e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a60:	0001c517          	auipc	a0,0x1c
    80004a64:	58050513          	addi	a0,a0,1408 # 80020fe0 <ftable>
    80004a68:	ffffc097          	auipc	ra,0xffffc
    80004a6c:	16e080e7          	jalr	366(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a70:	40dc                	lw	a5,4(s1)
    80004a72:	02f05263          	blez	a5,80004a96 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a76:	2785                	addiw	a5,a5,1
    80004a78:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a7a:	0001c517          	auipc	a0,0x1c
    80004a7e:	56650513          	addi	a0,a0,1382 # 80020fe0 <ftable>
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	208080e7          	jalr	520(ra) # 80000c8a <release>
  return f;
}
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	60e2                	ld	ra,24(sp)
    80004a8e:	6442                	ld	s0,16(sp)
    80004a90:	64a2                	ld	s1,8(sp)
    80004a92:	6105                	addi	sp,sp,32
    80004a94:	8082                	ret
    panic("filedup");
    80004a96:	00004517          	auipc	a0,0x4
    80004a9a:	d0250513          	addi	a0,a0,-766 # 80008798 <syscalls+0x260>
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	aa2080e7          	jalr	-1374(ra) # 80000540 <panic>

0000000080004aa6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004aa6:	7139                	addi	sp,sp,-64
    80004aa8:	fc06                	sd	ra,56(sp)
    80004aaa:	f822                	sd	s0,48(sp)
    80004aac:	f426                	sd	s1,40(sp)
    80004aae:	f04a                	sd	s2,32(sp)
    80004ab0:	ec4e                	sd	s3,24(sp)
    80004ab2:	e852                	sd	s4,16(sp)
    80004ab4:	e456                	sd	s5,8(sp)
    80004ab6:	0080                	addi	s0,sp,64
    80004ab8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004aba:	0001c517          	auipc	a0,0x1c
    80004abe:	52650513          	addi	a0,a0,1318 # 80020fe0 <ftable>
    80004ac2:	ffffc097          	auipc	ra,0xffffc
    80004ac6:	114080e7          	jalr	276(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004aca:	40dc                	lw	a5,4(s1)
    80004acc:	06f05163          	blez	a5,80004b2e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004ad0:	37fd                	addiw	a5,a5,-1
    80004ad2:	0007871b          	sext.w	a4,a5
    80004ad6:	c0dc                	sw	a5,4(s1)
    80004ad8:	06e04363          	bgtz	a4,80004b3e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004adc:	0004a903          	lw	s2,0(s1)
    80004ae0:	0094ca83          	lbu	s5,9(s1)
    80004ae4:	0104ba03          	ld	s4,16(s1)
    80004ae8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004aec:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004af0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004af4:	0001c517          	auipc	a0,0x1c
    80004af8:	4ec50513          	addi	a0,a0,1260 # 80020fe0 <ftable>
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	18e080e7          	jalr	398(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004b04:	4785                	li	a5,1
    80004b06:	04f90d63          	beq	s2,a5,80004b60 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b0a:	3979                	addiw	s2,s2,-2
    80004b0c:	4785                	li	a5,1
    80004b0e:	0527e063          	bltu	a5,s2,80004b4e <fileclose+0xa8>
    begin_op();
    80004b12:	00000097          	auipc	ra,0x0
    80004b16:	acc080e7          	jalr	-1332(ra) # 800045de <begin_op>
    iput(ff.ip);
    80004b1a:	854e                	mv	a0,s3
    80004b1c:	fffff097          	auipc	ra,0xfffff
    80004b20:	2b0080e7          	jalr	688(ra) # 80003dcc <iput>
    end_op();
    80004b24:	00000097          	auipc	ra,0x0
    80004b28:	b38080e7          	jalr	-1224(ra) # 8000465c <end_op>
    80004b2c:	a00d                	j	80004b4e <fileclose+0xa8>
    panic("fileclose");
    80004b2e:	00004517          	auipc	a0,0x4
    80004b32:	c7250513          	addi	a0,a0,-910 # 800087a0 <syscalls+0x268>
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	a0a080e7          	jalr	-1526(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004b3e:	0001c517          	auipc	a0,0x1c
    80004b42:	4a250513          	addi	a0,a0,1186 # 80020fe0 <ftable>
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	144080e7          	jalr	324(ra) # 80000c8a <release>
  }
}
    80004b4e:	70e2                	ld	ra,56(sp)
    80004b50:	7442                	ld	s0,48(sp)
    80004b52:	74a2                	ld	s1,40(sp)
    80004b54:	7902                	ld	s2,32(sp)
    80004b56:	69e2                	ld	s3,24(sp)
    80004b58:	6a42                	ld	s4,16(sp)
    80004b5a:	6aa2                	ld	s5,8(sp)
    80004b5c:	6121                	addi	sp,sp,64
    80004b5e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b60:	85d6                	mv	a1,s5
    80004b62:	8552                	mv	a0,s4
    80004b64:	00000097          	auipc	ra,0x0
    80004b68:	34c080e7          	jalr	844(ra) # 80004eb0 <pipeclose>
    80004b6c:	b7cd                	j	80004b4e <fileclose+0xa8>

0000000080004b6e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b6e:	715d                	addi	sp,sp,-80
    80004b70:	e486                	sd	ra,72(sp)
    80004b72:	e0a2                	sd	s0,64(sp)
    80004b74:	fc26                	sd	s1,56(sp)
    80004b76:	f84a                	sd	s2,48(sp)
    80004b78:	f44e                	sd	s3,40(sp)
    80004b7a:	0880                	addi	s0,sp,80
    80004b7c:	84aa                	mv	s1,a0
    80004b7e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b80:	ffffd097          	auipc	ra,0xffffd
    80004b84:	102080e7          	jalr	258(ra) # 80001c82 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b88:	409c                	lw	a5,0(s1)
    80004b8a:	37f9                	addiw	a5,a5,-2
    80004b8c:	4705                	li	a4,1
    80004b8e:	04f76763          	bltu	a4,a5,80004bdc <filestat+0x6e>
    80004b92:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b94:	6c88                	ld	a0,24(s1)
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	07c080e7          	jalr	124(ra) # 80003c12 <ilock>
    stati(f->ip, &st);
    80004b9e:	fb840593          	addi	a1,s0,-72
    80004ba2:	6c88                	ld	a0,24(s1)
    80004ba4:	fffff097          	auipc	ra,0xfffff
    80004ba8:	2f8080e7          	jalr	760(ra) # 80003e9c <stati>
    iunlock(f->ip);
    80004bac:	6c88                	ld	a0,24(s1)
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	126080e7          	jalr	294(ra) # 80003cd4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bb6:	46e1                	li	a3,24
    80004bb8:	fb840613          	addi	a2,s0,-72
    80004bbc:	85ce                	mv	a1,s3
    80004bbe:	05893503          	ld	a0,88(s2)
    80004bc2:	ffffd097          	auipc	ra,0xffffd
    80004bc6:	aaa080e7          	jalr	-1366(ra) # 8000166c <copyout>
    80004bca:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bce:	60a6                	ld	ra,72(sp)
    80004bd0:	6406                	ld	s0,64(sp)
    80004bd2:	74e2                	ld	s1,56(sp)
    80004bd4:	7942                	ld	s2,48(sp)
    80004bd6:	79a2                	ld	s3,40(sp)
    80004bd8:	6161                	addi	sp,sp,80
    80004bda:	8082                	ret
  return -1;
    80004bdc:	557d                	li	a0,-1
    80004bde:	bfc5                	j	80004bce <filestat+0x60>

0000000080004be0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004be0:	7179                	addi	sp,sp,-48
    80004be2:	f406                	sd	ra,40(sp)
    80004be4:	f022                	sd	s0,32(sp)
    80004be6:	ec26                	sd	s1,24(sp)
    80004be8:	e84a                	sd	s2,16(sp)
    80004bea:	e44e                	sd	s3,8(sp)
    80004bec:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bee:	00854783          	lbu	a5,8(a0)
    80004bf2:	c3d5                	beqz	a5,80004c96 <fileread+0xb6>
    80004bf4:	84aa                	mv	s1,a0
    80004bf6:	89ae                	mv	s3,a1
    80004bf8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bfa:	411c                	lw	a5,0(a0)
    80004bfc:	4705                	li	a4,1
    80004bfe:	04e78963          	beq	a5,a4,80004c50 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c02:	470d                	li	a4,3
    80004c04:	04e78d63          	beq	a5,a4,80004c5e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c08:	4709                	li	a4,2
    80004c0a:	06e79e63          	bne	a5,a4,80004c86 <fileread+0xa6>
    ilock(f->ip);
    80004c0e:	6d08                	ld	a0,24(a0)
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	002080e7          	jalr	2(ra) # 80003c12 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c18:	874a                	mv	a4,s2
    80004c1a:	5094                	lw	a3,32(s1)
    80004c1c:	864e                	mv	a2,s3
    80004c1e:	4585                	li	a1,1
    80004c20:	6c88                	ld	a0,24(s1)
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	2a4080e7          	jalr	676(ra) # 80003ec6 <readi>
    80004c2a:	892a                	mv	s2,a0
    80004c2c:	00a05563          	blez	a0,80004c36 <fileread+0x56>
      f->off += r;
    80004c30:	509c                	lw	a5,32(s1)
    80004c32:	9fa9                	addw	a5,a5,a0
    80004c34:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c36:	6c88                	ld	a0,24(s1)
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	09c080e7          	jalr	156(ra) # 80003cd4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c40:	854a                	mv	a0,s2
    80004c42:	70a2                	ld	ra,40(sp)
    80004c44:	7402                	ld	s0,32(sp)
    80004c46:	64e2                	ld	s1,24(sp)
    80004c48:	6942                	ld	s2,16(sp)
    80004c4a:	69a2                	ld	s3,8(sp)
    80004c4c:	6145                	addi	sp,sp,48
    80004c4e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c50:	6908                	ld	a0,16(a0)
    80004c52:	00000097          	auipc	ra,0x0
    80004c56:	3c6080e7          	jalr	966(ra) # 80005018 <piperead>
    80004c5a:	892a                	mv	s2,a0
    80004c5c:	b7d5                	j	80004c40 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c5e:	02451783          	lh	a5,36(a0)
    80004c62:	03079693          	slli	a3,a5,0x30
    80004c66:	92c1                	srli	a3,a3,0x30
    80004c68:	4725                	li	a4,9
    80004c6a:	02d76863          	bltu	a4,a3,80004c9a <fileread+0xba>
    80004c6e:	0792                	slli	a5,a5,0x4
    80004c70:	0001c717          	auipc	a4,0x1c
    80004c74:	2d070713          	addi	a4,a4,720 # 80020f40 <devsw>
    80004c78:	97ba                	add	a5,a5,a4
    80004c7a:	639c                	ld	a5,0(a5)
    80004c7c:	c38d                	beqz	a5,80004c9e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c7e:	4505                	li	a0,1
    80004c80:	9782                	jalr	a5
    80004c82:	892a                	mv	s2,a0
    80004c84:	bf75                	j	80004c40 <fileread+0x60>
    panic("fileread");
    80004c86:	00004517          	auipc	a0,0x4
    80004c8a:	b2a50513          	addi	a0,a0,-1238 # 800087b0 <syscalls+0x278>
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	8b2080e7          	jalr	-1870(ra) # 80000540 <panic>
    return -1;
    80004c96:	597d                	li	s2,-1
    80004c98:	b765                	j	80004c40 <fileread+0x60>
      return -1;
    80004c9a:	597d                	li	s2,-1
    80004c9c:	b755                	j	80004c40 <fileread+0x60>
    80004c9e:	597d                	li	s2,-1
    80004ca0:	b745                	j	80004c40 <fileread+0x60>

0000000080004ca2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ca2:	715d                	addi	sp,sp,-80
    80004ca4:	e486                	sd	ra,72(sp)
    80004ca6:	e0a2                	sd	s0,64(sp)
    80004ca8:	fc26                	sd	s1,56(sp)
    80004caa:	f84a                	sd	s2,48(sp)
    80004cac:	f44e                	sd	s3,40(sp)
    80004cae:	f052                	sd	s4,32(sp)
    80004cb0:	ec56                	sd	s5,24(sp)
    80004cb2:	e85a                	sd	s6,16(sp)
    80004cb4:	e45e                	sd	s7,8(sp)
    80004cb6:	e062                	sd	s8,0(sp)
    80004cb8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004cba:	00954783          	lbu	a5,9(a0)
    80004cbe:	10078663          	beqz	a5,80004dca <filewrite+0x128>
    80004cc2:	892a                	mv	s2,a0
    80004cc4:	8b2e                	mv	s6,a1
    80004cc6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cc8:	411c                	lw	a5,0(a0)
    80004cca:	4705                	li	a4,1
    80004ccc:	02e78263          	beq	a5,a4,80004cf0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cd0:	470d                	li	a4,3
    80004cd2:	02e78663          	beq	a5,a4,80004cfe <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cd6:	4709                	li	a4,2
    80004cd8:	0ee79163          	bne	a5,a4,80004dba <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cdc:	0ac05d63          	blez	a2,80004d96 <filewrite+0xf4>
    int i = 0;
    80004ce0:	4981                	li	s3,0
    80004ce2:	6b85                	lui	s7,0x1
    80004ce4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ce8:	6c05                	lui	s8,0x1
    80004cea:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004cee:	a861                	j	80004d86 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cf0:	6908                	ld	a0,16(a0)
    80004cf2:	00000097          	auipc	ra,0x0
    80004cf6:	22e080e7          	jalr	558(ra) # 80004f20 <pipewrite>
    80004cfa:	8a2a                	mv	s4,a0
    80004cfc:	a045                	j	80004d9c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cfe:	02451783          	lh	a5,36(a0)
    80004d02:	03079693          	slli	a3,a5,0x30
    80004d06:	92c1                	srli	a3,a3,0x30
    80004d08:	4725                	li	a4,9
    80004d0a:	0cd76263          	bltu	a4,a3,80004dce <filewrite+0x12c>
    80004d0e:	0792                	slli	a5,a5,0x4
    80004d10:	0001c717          	auipc	a4,0x1c
    80004d14:	23070713          	addi	a4,a4,560 # 80020f40 <devsw>
    80004d18:	97ba                	add	a5,a5,a4
    80004d1a:	679c                	ld	a5,8(a5)
    80004d1c:	cbdd                	beqz	a5,80004dd2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d1e:	4505                	li	a0,1
    80004d20:	9782                	jalr	a5
    80004d22:	8a2a                	mv	s4,a0
    80004d24:	a8a5                	j	80004d9c <filewrite+0xfa>
    80004d26:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d2a:	00000097          	auipc	ra,0x0
    80004d2e:	8b4080e7          	jalr	-1868(ra) # 800045de <begin_op>
      ilock(f->ip);
    80004d32:	01893503          	ld	a0,24(s2)
    80004d36:	fffff097          	auipc	ra,0xfffff
    80004d3a:	edc080e7          	jalr	-292(ra) # 80003c12 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d3e:	8756                	mv	a4,s5
    80004d40:	02092683          	lw	a3,32(s2)
    80004d44:	01698633          	add	a2,s3,s6
    80004d48:	4585                	li	a1,1
    80004d4a:	01893503          	ld	a0,24(s2)
    80004d4e:	fffff097          	auipc	ra,0xfffff
    80004d52:	270080e7          	jalr	624(ra) # 80003fbe <writei>
    80004d56:	84aa                	mv	s1,a0
    80004d58:	00a05763          	blez	a0,80004d66 <filewrite+0xc4>
        f->off += r;
    80004d5c:	02092783          	lw	a5,32(s2)
    80004d60:	9fa9                	addw	a5,a5,a0
    80004d62:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d66:	01893503          	ld	a0,24(s2)
    80004d6a:	fffff097          	auipc	ra,0xfffff
    80004d6e:	f6a080e7          	jalr	-150(ra) # 80003cd4 <iunlock>
      end_op();
    80004d72:	00000097          	auipc	ra,0x0
    80004d76:	8ea080e7          	jalr	-1814(ra) # 8000465c <end_op>

      if(r != n1){
    80004d7a:	009a9f63          	bne	s5,s1,80004d98 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d7e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d82:	0149db63          	bge	s3,s4,80004d98 <filewrite+0xf6>
      int n1 = n - i;
    80004d86:	413a04bb          	subw	s1,s4,s3
    80004d8a:	0004879b          	sext.w	a5,s1
    80004d8e:	f8fbdce3          	bge	s7,a5,80004d26 <filewrite+0x84>
    80004d92:	84e2                	mv	s1,s8
    80004d94:	bf49                	j	80004d26 <filewrite+0x84>
    int i = 0;
    80004d96:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d98:	013a1f63          	bne	s4,s3,80004db6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d9c:	8552                	mv	a0,s4
    80004d9e:	60a6                	ld	ra,72(sp)
    80004da0:	6406                	ld	s0,64(sp)
    80004da2:	74e2                	ld	s1,56(sp)
    80004da4:	7942                	ld	s2,48(sp)
    80004da6:	79a2                	ld	s3,40(sp)
    80004da8:	7a02                	ld	s4,32(sp)
    80004daa:	6ae2                	ld	s5,24(sp)
    80004dac:	6b42                	ld	s6,16(sp)
    80004dae:	6ba2                	ld	s7,8(sp)
    80004db0:	6c02                	ld	s8,0(sp)
    80004db2:	6161                	addi	sp,sp,80
    80004db4:	8082                	ret
    ret = (i == n ? n : -1);
    80004db6:	5a7d                	li	s4,-1
    80004db8:	b7d5                	j	80004d9c <filewrite+0xfa>
    panic("filewrite");
    80004dba:	00004517          	auipc	a0,0x4
    80004dbe:	a0650513          	addi	a0,a0,-1530 # 800087c0 <syscalls+0x288>
    80004dc2:	ffffb097          	auipc	ra,0xffffb
    80004dc6:	77e080e7          	jalr	1918(ra) # 80000540 <panic>
    return -1;
    80004dca:	5a7d                	li	s4,-1
    80004dcc:	bfc1                	j	80004d9c <filewrite+0xfa>
      return -1;
    80004dce:	5a7d                	li	s4,-1
    80004dd0:	b7f1                	j	80004d9c <filewrite+0xfa>
    80004dd2:	5a7d                	li	s4,-1
    80004dd4:	b7e1                	j	80004d9c <filewrite+0xfa>

0000000080004dd6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dd6:	7179                	addi	sp,sp,-48
    80004dd8:	f406                	sd	ra,40(sp)
    80004dda:	f022                	sd	s0,32(sp)
    80004ddc:	ec26                	sd	s1,24(sp)
    80004dde:	e84a                	sd	s2,16(sp)
    80004de0:	e44e                	sd	s3,8(sp)
    80004de2:	e052                	sd	s4,0(sp)
    80004de4:	1800                	addi	s0,sp,48
    80004de6:	84aa                	mv	s1,a0
    80004de8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004dea:	0005b023          	sd	zero,0(a1)
    80004dee:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004df2:	00000097          	auipc	ra,0x0
    80004df6:	bf8080e7          	jalr	-1032(ra) # 800049ea <filealloc>
    80004dfa:	e088                	sd	a0,0(s1)
    80004dfc:	c551                	beqz	a0,80004e88 <pipealloc+0xb2>
    80004dfe:	00000097          	auipc	ra,0x0
    80004e02:	bec080e7          	jalr	-1044(ra) # 800049ea <filealloc>
    80004e06:	00aa3023          	sd	a0,0(s4)
    80004e0a:	c92d                	beqz	a0,80004e7c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	cda080e7          	jalr	-806(ra) # 80000ae6 <kalloc>
    80004e14:	892a                	mv	s2,a0
    80004e16:	c125                	beqz	a0,80004e76 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e18:	4985                	li	s3,1
    80004e1a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e1e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e22:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e26:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e2a:	00004597          	auipc	a1,0x4
    80004e2e:	9a658593          	addi	a1,a1,-1626 # 800087d0 <syscalls+0x298>
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	d14080e7          	jalr	-748(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e3a:	609c                	ld	a5,0(s1)
    80004e3c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e40:	609c                	ld	a5,0(s1)
    80004e42:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e46:	609c                	ld	a5,0(s1)
    80004e48:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e4c:	609c                	ld	a5,0(s1)
    80004e4e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e52:	000a3783          	ld	a5,0(s4)
    80004e56:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e5a:	000a3783          	ld	a5,0(s4)
    80004e5e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e62:	000a3783          	ld	a5,0(s4)
    80004e66:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e6a:	000a3783          	ld	a5,0(s4)
    80004e6e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e72:	4501                	li	a0,0
    80004e74:	a025                	j	80004e9c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e76:	6088                	ld	a0,0(s1)
    80004e78:	e501                	bnez	a0,80004e80 <pipealloc+0xaa>
    80004e7a:	a039                	j	80004e88 <pipealloc+0xb2>
    80004e7c:	6088                	ld	a0,0(s1)
    80004e7e:	c51d                	beqz	a0,80004eac <pipealloc+0xd6>
    fileclose(*f0);
    80004e80:	00000097          	auipc	ra,0x0
    80004e84:	c26080e7          	jalr	-986(ra) # 80004aa6 <fileclose>
  if(*f1)
    80004e88:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e8c:	557d                	li	a0,-1
  if(*f1)
    80004e8e:	c799                	beqz	a5,80004e9c <pipealloc+0xc6>
    fileclose(*f1);
    80004e90:	853e                	mv	a0,a5
    80004e92:	00000097          	auipc	ra,0x0
    80004e96:	c14080e7          	jalr	-1004(ra) # 80004aa6 <fileclose>
  return -1;
    80004e9a:	557d                	li	a0,-1
}
    80004e9c:	70a2                	ld	ra,40(sp)
    80004e9e:	7402                	ld	s0,32(sp)
    80004ea0:	64e2                	ld	s1,24(sp)
    80004ea2:	6942                	ld	s2,16(sp)
    80004ea4:	69a2                	ld	s3,8(sp)
    80004ea6:	6a02                	ld	s4,0(sp)
    80004ea8:	6145                	addi	sp,sp,48
    80004eaa:	8082                	ret
  return -1;
    80004eac:	557d                	li	a0,-1
    80004eae:	b7fd                	j	80004e9c <pipealloc+0xc6>

0000000080004eb0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004eb0:	1101                	addi	sp,sp,-32
    80004eb2:	ec06                	sd	ra,24(sp)
    80004eb4:	e822                	sd	s0,16(sp)
    80004eb6:	e426                	sd	s1,8(sp)
    80004eb8:	e04a                	sd	s2,0(sp)
    80004eba:	1000                	addi	s0,sp,32
    80004ebc:	84aa                	mv	s1,a0
    80004ebe:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ec0:	ffffc097          	auipc	ra,0xffffc
    80004ec4:	d16080e7          	jalr	-746(ra) # 80000bd6 <acquire>
  if(writable){
    80004ec8:	02090d63          	beqz	s2,80004f02 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ecc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ed0:	21848513          	addi	a0,s1,536
    80004ed4:	ffffd097          	auipc	ra,0xffffd
    80004ed8:	5c8080e7          	jalr	1480(ra) # 8000249c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004edc:	2204b783          	ld	a5,544(s1)
    80004ee0:	eb95                	bnez	a5,80004f14 <pipeclose+0x64>
    release(&pi->lock);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	da6080e7          	jalr	-602(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004eec:	8526                	mv	a0,s1
    80004eee:	ffffc097          	auipc	ra,0xffffc
    80004ef2:	afa080e7          	jalr	-1286(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004ef6:	60e2                	ld	ra,24(sp)
    80004ef8:	6442                	ld	s0,16(sp)
    80004efa:	64a2                	ld	s1,8(sp)
    80004efc:	6902                	ld	s2,0(sp)
    80004efe:	6105                	addi	sp,sp,32
    80004f00:	8082                	ret
    pi->readopen = 0;
    80004f02:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f06:	21c48513          	addi	a0,s1,540
    80004f0a:	ffffd097          	auipc	ra,0xffffd
    80004f0e:	592080e7          	jalr	1426(ra) # 8000249c <wakeup>
    80004f12:	b7e9                	j	80004edc <pipeclose+0x2c>
    release(&pi->lock);
    80004f14:	8526                	mv	a0,s1
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	d74080e7          	jalr	-652(ra) # 80000c8a <release>
}
    80004f1e:	bfe1                	j	80004ef6 <pipeclose+0x46>

0000000080004f20 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f20:	711d                	addi	sp,sp,-96
    80004f22:	ec86                	sd	ra,88(sp)
    80004f24:	e8a2                	sd	s0,80(sp)
    80004f26:	e4a6                	sd	s1,72(sp)
    80004f28:	e0ca                	sd	s2,64(sp)
    80004f2a:	fc4e                	sd	s3,56(sp)
    80004f2c:	f852                	sd	s4,48(sp)
    80004f2e:	f456                	sd	s5,40(sp)
    80004f30:	f05a                	sd	s6,32(sp)
    80004f32:	ec5e                	sd	s7,24(sp)
    80004f34:	e862                	sd	s8,16(sp)
    80004f36:	1080                	addi	s0,sp,96
    80004f38:	84aa                	mv	s1,a0
    80004f3a:	8aae                	mv	s5,a1
    80004f3c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f3e:	ffffd097          	auipc	ra,0xffffd
    80004f42:	d44080e7          	jalr	-700(ra) # 80001c82 <myproc>
    80004f46:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f48:	8526                	mv	a0,s1
    80004f4a:	ffffc097          	auipc	ra,0xffffc
    80004f4e:	c8c080e7          	jalr	-884(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f52:	0b405663          	blez	s4,80004ffe <pipewrite+0xde>
  int i = 0;
    80004f56:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f58:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f5a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f5e:	21c48b93          	addi	s7,s1,540
    80004f62:	a089                	j	80004fa4 <pipewrite+0x84>
      release(&pi->lock);
    80004f64:	8526                	mv	a0,s1
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	d24080e7          	jalr	-732(ra) # 80000c8a <release>
      return -1;
    80004f6e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f70:	854a                	mv	a0,s2
    80004f72:	60e6                	ld	ra,88(sp)
    80004f74:	6446                	ld	s0,80(sp)
    80004f76:	64a6                	ld	s1,72(sp)
    80004f78:	6906                	ld	s2,64(sp)
    80004f7a:	79e2                	ld	s3,56(sp)
    80004f7c:	7a42                	ld	s4,48(sp)
    80004f7e:	7aa2                	ld	s5,40(sp)
    80004f80:	7b02                	ld	s6,32(sp)
    80004f82:	6be2                	ld	s7,24(sp)
    80004f84:	6c42                	ld	s8,16(sp)
    80004f86:	6125                	addi	sp,sp,96
    80004f88:	8082                	ret
      wakeup(&pi->nread);
    80004f8a:	8562                	mv	a0,s8
    80004f8c:	ffffd097          	auipc	ra,0xffffd
    80004f90:	510080e7          	jalr	1296(ra) # 8000249c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f94:	85a6                	mv	a1,s1
    80004f96:	855e                	mv	a0,s7
    80004f98:	ffffd097          	auipc	ra,0xffffd
    80004f9c:	4a0080e7          	jalr	1184(ra) # 80002438 <sleep>
  while(i < n){
    80004fa0:	07495063          	bge	s2,s4,80005000 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004fa4:	2204a783          	lw	a5,544(s1)
    80004fa8:	dfd5                	beqz	a5,80004f64 <pipewrite+0x44>
    80004faa:	854e                	mv	a0,s3
    80004fac:	ffffd097          	auipc	ra,0xffffd
    80004fb0:	734080e7          	jalr	1844(ra) # 800026e0 <killed>
    80004fb4:	f945                	bnez	a0,80004f64 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fb6:	2184a783          	lw	a5,536(s1)
    80004fba:	21c4a703          	lw	a4,540(s1)
    80004fbe:	2007879b          	addiw	a5,a5,512
    80004fc2:	fcf704e3          	beq	a4,a5,80004f8a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fc6:	4685                	li	a3,1
    80004fc8:	01590633          	add	a2,s2,s5
    80004fcc:	faf40593          	addi	a1,s0,-81
    80004fd0:	0589b503          	ld	a0,88(s3)
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	724080e7          	jalr	1828(ra) # 800016f8 <copyin>
    80004fdc:	03650263          	beq	a0,s6,80005000 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fe0:	21c4a783          	lw	a5,540(s1)
    80004fe4:	0017871b          	addiw	a4,a5,1
    80004fe8:	20e4ae23          	sw	a4,540(s1)
    80004fec:	1ff7f793          	andi	a5,a5,511
    80004ff0:	97a6                	add	a5,a5,s1
    80004ff2:	faf44703          	lbu	a4,-81(s0)
    80004ff6:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ffa:	2905                	addiw	s2,s2,1
    80004ffc:	b755                	j	80004fa0 <pipewrite+0x80>
  int i = 0;
    80004ffe:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005000:	21848513          	addi	a0,s1,536
    80005004:	ffffd097          	auipc	ra,0xffffd
    80005008:	498080e7          	jalr	1176(ra) # 8000249c <wakeup>
  release(&pi->lock);
    8000500c:	8526                	mv	a0,s1
    8000500e:	ffffc097          	auipc	ra,0xffffc
    80005012:	c7c080e7          	jalr	-900(ra) # 80000c8a <release>
  return i;
    80005016:	bfa9                	j	80004f70 <pipewrite+0x50>

0000000080005018 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005018:	715d                	addi	sp,sp,-80
    8000501a:	e486                	sd	ra,72(sp)
    8000501c:	e0a2                	sd	s0,64(sp)
    8000501e:	fc26                	sd	s1,56(sp)
    80005020:	f84a                	sd	s2,48(sp)
    80005022:	f44e                	sd	s3,40(sp)
    80005024:	f052                	sd	s4,32(sp)
    80005026:	ec56                	sd	s5,24(sp)
    80005028:	e85a                	sd	s6,16(sp)
    8000502a:	0880                	addi	s0,sp,80
    8000502c:	84aa                	mv	s1,a0
    8000502e:	892e                	mv	s2,a1
    80005030:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005032:	ffffd097          	auipc	ra,0xffffd
    80005036:	c50080e7          	jalr	-944(ra) # 80001c82 <myproc>
    8000503a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000503c:	8526                	mv	a0,s1
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	b98080e7          	jalr	-1128(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005046:	2184a703          	lw	a4,536(s1)
    8000504a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000504e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005052:	02f71763          	bne	a4,a5,80005080 <piperead+0x68>
    80005056:	2244a783          	lw	a5,548(s1)
    8000505a:	c39d                	beqz	a5,80005080 <piperead+0x68>
    if(killed(pr)){
    8000505c:	8552                	mv	a0,s4
    8000505e:	ffffd097          	auipc	ra,0xffffd
    80005062:	682080e7          	jalr	1666(ra) # 800026e0 <killed>
    80005066:	e949                	bnez	a0,800050f8 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005068:	85a6                	mv	a1,s1
    8000506a:	854e                	mv	a0,s3
    8000506c:	ffffd097          	auipc	ra,0xffffd
    80005070:	3cc080e7          	jalr	972(ra) # 80002438 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005074:	2184a703          	lw	a4,536(s1)
    80005078:	21c4a783          	lw	a5,540(s1)
    8000507c:	fcf70de3          	beq	a4,a5,80005056 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005080:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005082:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005084:	05505463          	blez	s5,800050cc <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005088:	2184a783          	lw	a5,536(s1)
    8000508c:	21c4a703          	lw	a4,540(s1)
    80005090:	02f70e63          	beq	a4,a5,800050cc <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005094:	0017871b          	addiw	a4,a5,1
    80005098:	20e4ac23          	sw	a4,536(s1)
    8000509c:	1ff7f793          	andi	a5,a5,511
    800050a0:	97a6                	add	a5,a5,s1
    800050a2:	0187c783          	lbu	a5,24(a5)
    800050a6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050aa:	4685                	li	a3,1
    800050ac:	fbf40613          	addi	a2,s0,-65
    800050b0:	85ca                	mv	a1,s2
    800050b2:	058a3503          	ld	a0,88(s4)
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	5b6080e7          	jalr	1462(ra) # 8000166c <copyout>
    800050be:	01650763          	beq	a0,s6,800050cc <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c2:	2985                	addiw	s3,s3,1
    800050c4:	0905                	addi	s2,s2,1
    800050c6:	fd3a91e3          	bne	s5,s3,80005088 <piperead+0x70>
    800050ca:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050cc:	21c48513          	addi	a0,s1,540
    800050d0:	ffffd097          	auipc	ra,0xffffd
    800050d4:	3cc080e7          	jalr	972(ra) # 8000249c <wakeup>
  release(&pi->lock);
    800050d8:	8526                	mv	a0,s1
    800050da:	ffffc097          	auipc	ra,0xffffc
    800050de:	bb0080e7          	jalr	-1104(ra) # 80000c8a <release>
  return i;
}
    800050e2:	854e                	mv	a0,s3
    800050e4:	60a6                	ld	ra,72(sp)
    800050e6:	6406                	ld	s0,64(sp)
    800050e8:	74e2                	ld	s1,56(sp)
    800050ea:	7942                	ld	s2,48(sp)
    800050ec:	79a2                	ld	s3,40(sp)
    800050ee:	7a02                	ld	s4,32(sp)
    800050f0:	6ae2                	ld	s5,24(sp)
    800050f2:	6b42                	ld	s6,16(sp)
    800050f4:	6161                	addi	sp,sp,80
    800050f6:	8082                	ret
      release(&pi->lock);
    800050f8:	8526                	mv	a0,s1
    800050fa:	ffffc097          	auipc	ra,0xffffc
    800050fe:	b90080e7          	jalr	-1136(ra) # 80000c8a <release>
      return -1;
    80005102:	59fd                	li	s3,-1
    80005104:	bff9                	j	800050e2 <piperead+0xca>

0000000080005106 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005106:	1141                	addi	sp,sp,-16
    80005108:	e422                	sd	s0,8(sp)
    8000510a:	0800                	addi	s0,sp,16
    8000510c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000510e:	8905                	andi	a0,a0,1
    80005110:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005112:	8b89                	andi	a5,a5,2
    80005114:	c399                	beqz	a5,8000511a <flags2perm+0x14>
      perm |= PTE_W;
    80005116:	00456513          	ori	a0,a0,4
    return perm;
}
    8000511a:	6422                	ld	s0,8(sp)
    8000511c:	0141                	addi	sp,sp,16
    8000511e:	8082                	ret

0000000080005120 <exec>:

int
exec(char *path, char **argv)
{
    80005120:	de010113          	addi	sp,sp,-544
    80005124:	20113c23          	sd	ra,536(sp)
    80005128:	20813823          	sd	s0,528(sp)
    8000512c:	20913423          	sd	s1,520(sp)
    80005130:	21213023          	sd	s2,512(sp)
    80005134:	ffce                	sd	s3,504(sp)
    80005136:	fbd2                	sd	s4,496(sp)
    80005138:	f7d6                	sd	s5,488(sp)
    8000513a:	f3da                	sd	s6,480(sp)
    8000513c:	efde                	sd	s7,472(sp)
    8000513e:	ebe2                	sd	s8,464(sp)
    80005140:	e7e6                	sd	s9,456(sp)
    80005142:	e3ea                	sd	s10,448(sp)
    80005144:	ff6e                	sd	s11,440(sp)
    80005146:	1400                	addi	s0,sp,544
    80005148:	892a                	mv	s2,a0
    8000514a:	dea43423          	sd	a0,-536(s0)
    8000514e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005152:	ffffd097          	auipc	ra,0xffffd
    80005156:	b30080e7          	jalr	-1232(ra) # 80001c82 <myproc>
    8000515a:	84aa                	mv	s1,a0

  begin_op();
    8000515c:	fffff097          	auipc	ra,0xfffff
    80005160:	482080e7          	jalr	1154(ra) # 800045de <begin_op>

  if((ip = namei(path)) == 0){
    80005164:	854a                	mv	a0,s2
    80005166:	fffff097          	auipc	ra,0xfffff
    8000516a:	258080e7          	jalr	600(ra) # 800043be <namei>
    8000516e:	c93d                	beqz	a0,800051e4 <exec+0xc4>
    80005170:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005172:	fffff097          	auipc	ra,0xfffff
    80005176:	aa0080e7          	jalr	-1376(ra) # 80003c12 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000517a:	04000713          	li	a4,64
    8000517e:	4681                	li	a3,0
    80005180:	e5040613          	addi	a2,s0,-432
    80005184:	4581                	li	a1,0
    80005186:	8556                	mv	a0,s5
    80005188:	fffff097          	auipc	ra,0xfffff
    8000518c:	d3e080e7          	jalr	-706(ra) # 80003ec6 <readi>
    80005190:	04000793          	li	a5,64
    80005194:	00f51a63          	bne	a0,a5,800051a8 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005198:	e5042703          	lw	a4,-432(s0)
    8000519c:	464c47b7          	lui	a5,0x464c4
    800051a0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051a4:	04f70663          	beq	a4,a5,800051f0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051a8:	8556                	mv	a0,s5
    800051aa:	fffff097          	auipc	ra,0xfffff
    800051ae:	cca080e7          	jalr	-822(ra) # 80003e74 <iunlockput>
    end_op();
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	4aa080e7          	jalr	1194(ra) # 8000465c <end_op>
  }
  return -1;
    800051ba:	557d                	li	a0,-1
}
    800051bc:	21813083          	ld	ra,536(sp)
    800051c0:	21013403          	ld	s0,528(sp)
    800051c4:	20813483          	ld	s1,520(sp)
    800051c8:	20013903          	ld	s2,512(sp)
    800051cc:	79fe                	ld	s3,504(sp)
    800051ce:	7a5e                	ld	s4,496(sp)
    800051d0:	7abe                	ld	s5,488(sp)
    800051d2:	7b1e                	ld	s6,480(sp)
    800051d4:	6bfe                	ld	s7,472(sp)
    800051d6:	6c5e                	ld	s8,464(sp)
    800051d8:	6cbe                	ld	s9,456(sp)
    800051da:	6d1e                	ld	s10,448(sp)
    800051dc:	7dfa                	ld	s11,440(sp)
    800051de:	22010113          	addi	sp,sp,544
    800051e2:	8082                	ret
    end_op();
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	478080e7          	jalr	1144(ra) # 8000465c <end_op>
    return -1;
    800051ec:	557d                	li	a0,-1
    800051ee:	b7f9                	j	800051bc <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051f0:	8526                	mv	a0,s1
    800051f2:	ffffd097          	auipc	ra,0xffffd
    800051f6:	b54080e7          	jalr	-1196(ra) # 80001d46 <proc_pagetable>
    800051fa:	8b2a                	mv	s6,a0
    800051fc:	d555                	beqz	a0,800051a8 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051fe:	e7042783          	lw	a5,-400(s0)
    80005202:	e8845703          	lhu	a4,-376(s0)
    80005206:	c735                	beqz	a4,80005272 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005208:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000520a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000520e:	6a05                	lui	s4,0x1
    80005210:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005214:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005218:	6d85                	lui	s11,0x1
    8000521a:	7d7d                	lui	s10,0xfffff
    8000521c:	ac3d                	j	8000545a <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000521e:	00003517          	auipc	a0,0x3
    80005222:	5ba50513          	addi	a0,a0,1466 # 800087d8 <syscalls+0x2a0>
    80005226:	ffffb097          	auipc	ra,0xffffb
    8000522a:	31a080e7          	jalr	794(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000522e:	874a                	mv	a4,s2
    80005230:	009c86bb          	addw	a3,s9,s1
    80005234:	4581                	li	a1,0
    80005236:	8556                	mv	a0,s5
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	c8e080e7          	jalr	-882(ra) # 80003ec6 <readi>
    80005240:	2501                	sext.w	a0,a0
    80005242:	1aa91963          	bne	s2,a0,800053f4 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005246:	009d84bb          	addw	s1,s11,s1
    8000524a:	013d09bb          	addw	s3,s10,s3
    8000524e:	1f74f663          	bgeu	s1,s7,8000543a <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005252:	02049593          	slli	a1,s1,0x20
    80005256:	9181                	srli	a1,a1,0x20
    80005258:	95e2                	add	a1,a1,s8
    8000525a:	855a                	mv	a0,s6
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	e00080e7          	jalr	-512(ra) # 8000105c <walkaddr>
    80005264:	862a                	mv	a2,a0
    if(pa == 0)
    80005266:	dd45                	beqz	a0,8000521e <exec+0xfe>
      n = PGSIZE;
    80005268:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000526a:	fd49f2e3          	bgeu	s3,s4,8000522e <exec+0x10e>
      n = sz - i;
    8000526e:	894e                	mv	s2,s3
    80005270:	bf7d                	j	8000522e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005272:	4901                	li	s2,0
  iunlockput(ip);
    80005274:	8556                	mv	a0,s5
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	bfe080e7          	jalr	-1026(ra) # 80003e74 <iunlockput>
  end_op();
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	3de080e7          	jalr	990(ra) # 8000465c <end_op>
  p = myproc();
    80005286:	ffffd097          	auipc	ra,0xffffd
    8000528a:	9fc080e7          	jalr	-1540(ra) # 80001c82 <myproc>
    8000528e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005290:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005294:	6785                	lui	a5,0x1
    80005296:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005298:	97ca                	add	a5,a5,s2
    8000529a:	777d                	lui	a4,0xfffff
    8000529c:	8ff9                	and	a5,a5,a4
    8000529e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052a2:	4691                	li	a3,4
    800052a4:	6609                	lui	a2,0x2
    800052a6:	963e                	add	a2,a2,a5
    800052a8:	85be                	mv	a1,a5
    800052aa:	855a                	mv	a0,s6
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	164080e7          	jalr	356(ra) # 80001410 <uvmalloc>
    800052b4:	8c2a                	mv	s8,a0
  ip = 0;
    800052b6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052b8:	12050e63          	beqz	a0,800053f4 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052bc:	75f9                	lui	a1,0xffffe
    800052be:	95aa                	add	a1,a1,a0
    800052c0:	855a                	mv	a0,s6
    800052c2:	ffffc097          	auipc	ra,0xffffc
    800052c6:	378080e7          	jalr	888(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    800052ca:	7afd                	lui	s5,0xfffff
    800052cc:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052ce:	df043783          	ld	a5,-528(s0)
    800052d2:	6388                	ld	a0,0(a5)
    800052d4:	c925                	beqz	a0,80005344 <exec+0x224>
    800052d6:	e9040993          	addi	s3,s0,-368
    800052da:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052de:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052e0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052e2:	ffffc097          	auipc	ra,0xffffc
    800052e6:	b6c080e7          	jalr	-1172(ra) # 80000e4e <strlen>
    800052ea:	0015079b          	addiw	a5,a0,1
    800052ee:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052f2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800052f6:	13596663          	bltu	s2,s5,80005422 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052fa:	df043d83          	ld	s11,-528(s0)
    800052fe:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005302:	8552                	mv	a0,s4
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	b4a080e7          	jalr	-1206(ra) # 80000e4e <strlen>
    8000530c:	0015069b          	addiw	a3,a0,1
    80005310:	8652                	mv	a2,s4
    80005312:	85ca                	mv	a1,s2
    80005314:	855a                	mv	a0,s6
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	356080e7          	jalr	854(ra) # 8000166c <copyout>
    8000531e:	10054663          	bltz	a0,8000542a <exec+0x30a>
    ustack[argc] = sp;
    80005322:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005326:	0485                	addi	s1,s1,1
    80005328:	008d8793          	addi	a5,s11,8
    8000532c:	def43823          	sd	a5,-528(s0)
    80005330:	008db503          	ld	a0,8(s11)
    80005334:	c911                	beqz	a0,80005348 <exec+0x228>
    if(argc >= MAXARG)
    80005336:	09a1                	addi	s3,s3,8
    80005338:	fb3c95e3          	bne	s9,s3,800052e2 <exec+0x1c2>
  sz = sz1;
    8000533c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005340:	4a81                	li	s5,0
    80005342:	a84d                	j	800053f4 <exec+0x2d4>
  sp = sz;
    80005344:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005346:	4481                	li	s1,0
  ustack[argc] = 0;
    80005348:	00349793          	slli	a5,s1,0x3
    8000534c:	f9078793          	addi	a5,a5,-112
    80005350:	97a2                	add	a5,a5,s0
    80005352:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005356:	00148693          	addi	a3,s1,1
    8000535a:	068e                	slli	a3,a3,0x3
    8000535c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005360:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005364:	01597663          	bgeu	s2,s5,80005370 <exec+0x250>
  sz = sz1;
    80005368:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000536c:	4a81                	li	s5,0
    8000536e:	a059                	j	800053f4 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005370:	e9040613          	addi	a2,s0,-368
    80005374:	85ca                	mv	a1,s2
    80005376:	855a                	mv	a0,s6
    80005378:	ffffc097          	auipc	ra,0xffffc
    8000537c:	2f4080e7          	jalr	756(ra) # 8000166c <copyout>
    80005380:	0a054963          	bltz	a0,80005432 <exec+0x312>
  p->trapframe->a1 = sp;
    80005384:	060bb783          	ld	a5,96(s7)
    80005388:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000538c:	de843783          	ld	a5,-536(s0)
    80005390:	0007c703          	lbu	a4,0(a5)
    80005394:	cf11                	beqz	a4,800053b0 <exec+0x290>
    80005396:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005398:	02f00693          	li	a3,47
    8000539c:	a039                	j	800053aa <exec+0x28a>
      last = s+1;
    8000539e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053a2:	0785                	addi	a5,a5,1
    800053a4:	fff7c703          	lbu	a4,-1(a5)
    800053a8:	c701                	beqz	a4,800053b0 <exec+0x290>
    if(*s == '/')
    800053aa:	fed71ce3          	bne	a4,a3,800053a2 <exec+0x282>
    800053ae:	bfc5                	j	8000539e <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800053b0:	4641                	li	a2,16
    800053b2:	de843583          	ld	a1,-536(s0)
    800053b6:	160b8513          	addi	a0,s7,352
    800053ba:	ffffc097          	auipc	ra,0xffffc
    800053be:	a62080e7          	jalr	-1438(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800053c2:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    800053c6:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    800053ca:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053ce:	060bb783          	ld	a5,96(s7)
    800053d2:	e6843703          	ld	a4,-408(s0)
    800053d6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053d8:	060bb783          	ld	a5,96(s7)
    800053dc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053e0:	85ea                	mv	a1,s10
    800053e2:	ffffd097          	auipc	ra,0xffffd
    800053e6:	a00080e7          	jalr	-1536(ra) # 80001de2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053ea:	0004851b          	sext.w	a0,s1
    800053ee:	b3f9                	j	800051bc <exec+0x9c>
    800053f0:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053f4:	df843583          	ld	a1,-520(s0)
    800053f8:	855a                	mv	a0,s6
    800053fa:	ffffd097          	auipc	ra,0xffffd
    800053fe:	9e8080e7          	jalr	-1560(ra) # 80001de2 <proc_freepagetable>
  if(ip){
    80005402:	da0a93e3          	bnez	s5,800051a8 <exec+0x88>
  return -1;
    80005406:	557d                	li	a0,-1
    80005408:	bb55                	j	800051bc <exec+0x9c>
    8000540a:	df243c23          	sd	s2,-520(s0)
    8000540e:	b7dd                	j	800053f4 <exec+0x2d4>
    80005410:	df243c23          	sd	s2,-520(s0)
    80005414:	b7c5                	j	800053f4 <exec+0x2d4>
    80005416:	df243c23          	sd	s2,-520(s0)
    8000541a:	bfe9                	j	800053f4 <exec+0x2d4>
    8000541c:	df243c23          	sd	s2,-520(s0)
    80005420:	bfd1                	j	800053f4 <exec+0x2d4>
  sz = sz1;
    80005422:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005426:	4a81                	li	s5,0
    80005428:	b7f1                	j	800053f4 <exec+0x2d4>
  sz = sz1;
    8000542a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000542e:	4a81                	li	s5,0
    80005430:	b7d1                	j	800053f4 <exec+0x2d4>
  sz = sz1;
    80005432:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005436:	4a81                	li	s5,0
    80005438:	bf75                	j	800053f4 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000543a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000543e:	e0843783          	ld	a5,-504(s0)
    80005442:	0017869b          	addiw	a3,a5,1
    80005446:	e0d43423          	sd	a3,-504(s0)
    8000544a:	e0043783          	ld	a5,-512(s0)
    8000544e:	0387879b          	addiw	a5,a5,56
    80005452:	e8845703          	lhu	a4,-376(s0)
    80005456:	e0e6dfe3          	bge	a3,a4,80005274 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000545a:	2781                	sext.w	a5,a5
    8000545c:	e0f43023          	sd	a5,-512(s0)
    80005460:	03800713          	li	a4,56
    80005464:	86be                	mv	a3,a5
    80005466:	e1840613          	addi	a2,s0,-488
    8000546a:	4581                	li	a1,0
    8000546c:	8556                	mv	a0,s5
    8000546e:	fffff097          	auipc	ra,0xfffff
    80005472:	a58080e7          	jalr	-1448(ra) # 80003ec6 <readi>
    80005476:	03800793          	li	a5,56
    8000547a:	f6f51be3          	bne	a0,a5,800053f0 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000547e:	e1842783          	lw	a5,-488(s0)
    80005482:	4705                	li	a4,1
    80005484:	fae79de3          	bne	a5,a4,8000543e <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005488:	e4043483          	ld	s1,-448(s0)
    8000548c:	e3843783          	ld	a5,-456(s0)
    80005490:	f6f4ede3          	bltu	s1,a5,8000540a <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005494:	e2843783          	ld	a5,-472(s0)
    80005498:	94be                	add	s1,s1,a5
    8000549a:	f6f4ebe3          	bltu	s1,a5,80005410 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000549e:	de043703          	ld	a4,-544(s0)
    800054a2:	8ff9                	and	a5,a5,a4
    800054a4:	fbad                	bnez	a5,80005416 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054a6:	e1c42503          	lw	a0,-484(s0)
    800054aa:	00000097          	auipc	ra,0x0
    800054ae:	c5c080e7          	jalr	-932(ra) # 80005106 <flags2perm>
    800054b2:	86aa                	mv	a3,a0
    800054b4:	8626                	mv	a2,s1
    800054b6:	85ca                	mv	a1,s2
    800054b8:	855a                	mv	a0,s6
    800054ba:	ffffc097          	auipc	ra,0xffffc
    800054be:	f56080e7          	jalr	-170(ra) # 80001410 <uvmalloc>
    800054c2:	dea43c23          	sd	a0,-520(s0)
    800054c6:	d939                	beqz	a0,8000541c <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054c8:	e2843c03          	ld	s8,-472(s0)
    800054cc:	e2042c83          	lw	s9,-480(s0)
    800054d0:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054d4:	f60b83e3          	beqz	s7,8000543a <exec+0x31a>
    800054d8:	89de                	mv	s3,s7
    800054da:	4481                	li	s1,0
    800054dc:	bb9d                	j	80005252 <exec+0x132>

00000000800054de <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054de:	7179                	addi	sp,sp,-48
    800054e0:	f406                	sd	ra,40(sp)
    800054e2:	f022                	sd	s0,32(sp)
    800054e4:	ec26                	sd	s1,24(sp)
    800054e6:	e84a                	sd	s2,16(sp)
    800054e8:	1800                	addi	s0,sp,48
    800054ea:	892e                	mv	s2,a1
    800054ec:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054ee:	fdc40593          	addi	a1,s0,-36
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	b0a080e7          	jalr	-1270(ra) # 80002ffc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054fa:	fdc42703          	lw	a4,-36(s0)
    800054fe:	47bd                	li	a5,15
    80005500:	02e7eb63          	bltu	a5,a4,80005536 <argfd+0x58>
    80005504:	ffffc097          	auipc	ra,0xffffc
    80005508:	77e080e7          	jalr	1918(ra) # 80001c82 <myproc>
    8000550c:	fdc42703          	lw	a4,-36(s0)
    80005510:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdcf42>
    80005514:	078e                	slli	a5,a5,0x3
    80005516:	953e                	add	a0,a0,a5
    80005518:	651c                	ld	a5,8(a0)
    8000551a:	c385                	beqz	a5,8000553a <argfd+0x5c>
    return -1;
  if(pfd)
    8000551c:	00090463          	beqz	s2,80005524 <argfd+0x46>
    *pfd = fd;
    80005520:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005524:	4501                	li	a0,0
  if(pf)
    80005526:	c091                	beqz	s1,8000552a <argfd+0x4c>
    *pf = f;
    80005528:	e09c                	sd	a5,0(s1)
}
    8000552a:	70a2                	ld	ra,40(sp)
    8000552c:	7402                	ld	s0,32(sp)
    8000552e:	64e2                	ld	s1,24(sp)
    80005530:	6942                	ld	s2,16(sp)
    80005532:	6145                	addi	sp,sp,48
    80005534:	8082                	ret
    return -1;
    80005536:	557d                	li	a0,-1
    80005538:	bfcd                	j	8000552a <argfd+0x4c>
    8000553a:	557d                	li	a0,-1
    8000553c:	b7fd                	j	8000552a <argfd+0x4c>

000000008000553e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000553e:	1101                	addi	sp,sp,-32
    80005540:	ec06                	sd	ra,24(sp)
    80005542:	e822                	sd	s0,16(sp)
    80005544:	e426                	sd	s1,8(sp)
    80005546:	1000                	addi	s0,sp,32
    80005548:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000554a:	ffffc097          	auipc	ra,0xffffc
    8000554e:	738080e7          	jalr	1848(ra) # 80001c82 <myproc>
    80005552:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005554:	0d850793          	addi	a5,a0,216
    80005558:	4501                	li	a0,0
    8000555a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000555c:	6398                	ld	a4,0(a5)
    8000555e:	cb19                	beqz	a4,80005574 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005560:	2505                	addiw	a0,a0,1
    80005562:	07a1                	addi	a5,a5,8
    80005564:	fed51ce3          	bne	a0,a3,8000555c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005568:	557d                	li	a0,-1
}
    8000556a:	60e2                	ld	ra,24(sp)
    8000556c:	6442                	ld	s0,16(sp)
    8000556e:	64a2                	ld	s1,8(sp)
    80005570:	6105                	addi	sp,sp,32
    80005572:	8082                	ret
      p->ofile[fd] = f;
    80005574:	01a50793          	addi	a5,a0,26
    80005578:	078e                	slli	a5,a5,0x3
    8000557a:	963e                	add	a2,a2,a5
    8000557c:	e604                	sd	s1,8(a2)
      return fd;
    8000557e:	b7f5                	j	8000556a <fdalloc+0x2c>

0000000080005580 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005580:	715d                	addi	sp,sp,-80
    80005582:	e486                	sd	ra,72(sp)
    80005584:	e0a2                	sd	s0,64(sp)
    80005586:	fc26                	sd	s1,56(sp)
    80005588:	f84a                	sd	s2,48(sp)
    8000558a:	f44e                	sd	s3,40(sp)
    8000558c:	f052                	sd	s4,32(sp)
    8000558e:	ec56                	sd	s5,24(sp)
    80005590:	e85a                	sd	s6,16(sp)
    80005592:	0880                	addi	s0,sp,80
    80005594:	8b2e                	mv	s6,a1
    80005596:	89b2                	mv	s3,a2
    80005598:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000559a:	fb040593          	addi	a1,s0,-80
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	e3e080e7          	jalr	-450(ra) # 800043dc <nameiparent>
    800055a6:	84aa                	mv	s1,a0
    800055a8:	14050f63          	beqz	a0,80005706 <create+0x186>
    return 0;

  ilock(dp);
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	666080e7          	jalr	1638(ra) # 80003c12 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055b4:	4601                	li	a2,0
    800055b6:	fb040593          	addi	a1,s0,-80
    800055ba:	8526                	mv	a0,s1
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	b3a080e7          	jalr	-1222(ra) # 800040f6 <dirlookup>
    800055c4:	8aaa                	mv	s5,a0
    800055c6:	c931                	beqz	a0,8000561a <create+0x9a>
    iunlockput(dp);
    800055c8:	8526                	mv	a0,s1
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	8aa080e7          	jalr	-1878(ra) # 80003e74 <iunlockput>
    ilock(ip);
    800055d2:	8556                	mv	a0,s5
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	63e080e7          	jalr	1598(ra) # 80003c12 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055dc:	000b059b          	sext.w	a1,s6
    800055e0:	4789                	li	a5,2
    800055e2:	02f59563          	bne	a1,a5,8000560c <create+0x8c>
    800055e6:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcf6c>
    800055ea:	37f9                	addiw	a5,a5,-2
    800055ec:	17c2                	slli	a5,a5,0x30
    800055ee:	93c1                	srli	a5,a5,0x30
    800055f0:	4705                	li	a4,1
    800055f2:	00f76d63          	bltu	a4,a5,8000560c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055f6:	8556                	mv	a0,s5
    800055f8:	60a6                	ld	ra,72(sp)
    800055fa:	6406                	ld	s0,64(sp)
    800055fc:	74e2                	ld	s1,56(sp)
    800055fe:	7942                	ld	s2,48(sp)
    80005600:	79a2                	ld	s3,40(sp)
    80005602:	7a02                	ld	s4,32(sp)
    80005604:	6ae2                	ld	s5,24(sp)
    80005606:	6b42                	ld	s6,16(sp)
    80005608:	6161                	addi	sp,sp,80
    8000560a:	8082                	ret
    iunlockput(ip);
    8000560c:	8556                	mv	a0,s5
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	866080e7          	jalr	-1946(ra) # 80003e74 <iunlockput>
    return 0;
    80005616:	4a81                	li	s5,0
    80005618:	bff9                	j	800055f6 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000561a:	85da                	mv	a1,s6
    8000561c:	4088                	lw	a0,0(s1)
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	456080e7          	jalr	1110(ra) # 80003a74 <ialloc>
    80005626:	8a2a                	mv	s4,a0
    80005628:	c539                	beqz	a0,80005676 <create+0xf6>
  ilock(ip);
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	5e8080e7          	jalr	1512(ra) # 80003c12 <ilock>
  ip->major = major;
    80005632:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005636:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000563a:	4905                	li	s2,1
    8000563c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005640:	8552                	mv	a0,s4
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	504080e7          	jalr	1284(ra) # 80003b46 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000564a:	000b059b          	sext.w	a1,s6
    8000564e:	03258b63          	beq	a1,s2,80005684 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005652:	004a2603          	lw	a2,4(s4)
    80005656:	fb040593          	addi	a1,s0,-80
    8000565a:	8526                	mv	a0,s1
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	cb0080e7          	jalr	-848(ra) # 8000430c <dirlink>
    80005664:	06054f63          	bltz	a0,800056e2 <create+0x162>
  iunlockput(dp);
    80005668:	8526                	mv	a0,s1
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	80a080e7          	jalr	-2038(ra) # 80003e74 <iunlockput>
  return ip;
    80005672:	8ad2                	mv	s5,s4
    80005674:	b749                	j	800055f6 <create+0x76>
    iunlockput(dp);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	7fc080e7          	jalr	2044(ra) # 80003e74 <iunlockput>
    return 0;
    80005680:	8ad2                	mv	s5,s4
    80005682:	bf95                	j	800055f6 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005684:	004a2603          	lw	a2,4(s4)
    80005688:	00003597          	auipc	a1,0x3
    8000568c:	17058593          	addi	a1,a1,368 # 800087f8 <syscalls+0x2c0>
    80005690:	8552                	mv	a0,s4
    80005692:	fffff097          	auipc	ra,0xfffff
    80005696:	c7a080e7          	jalr	-902(ra) # 8000430c <dirlink>
    8000569a:	04054463          	bltz	a0,800056e2 <create+0x162>
    8000569e:	40d0                	lw	a2,4(s1)
    800056a0:	00003597          	auipc	a1,0x3
    800056a4:	16058593          	addi	a1,a1,352 # 80008800 <syscalls+0x2c8>
    800056a8:	8552                	mv	a0,s4
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	c62080e7          	jalr	-926(ra) # 8000430c <dirlink>
    800056b2:	02054863          	bltz	a0,800056e2 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800056b6:	004a2603          	lw	a2,4(s4)
    800056ba:	fb040593          	addi	a1,s0,-80
    800056be:	8526                	mv	a0,s1
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	c4c080e7          	jalr	-948(ra) # 8000430c <dirlink>
    800056c8:	00054d63          	bltz	a0,800056e2 <create+0x162>
    dp->nlink++;  // for ".."
    800056cc:	04a4d783          	lhu	a5,74(s1)
    800056d0:	2785                	addiw	a5,a5,1
    800056d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	46e080e7          	jalr	1134(ra) # 80003b46 <iupdate>
    800056e0:	b761                	j	80005668 <create+0xe8>
  ip->nlink = 0;
    800056e2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056e6:	8552                	mv	a0,s4
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	45e080e7          	jalr	1118(ra) # 80003b46 <iupdate>
  iunlockput(ip);
    800056f0:	8552                	mv	a0,s4
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	782080e7          	jalr	1922(ra) # 80003e74 <iunlockput>
  iunlockput(dp);
    800056fa:	8526                	mv	a0,s1
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	778080e7          	jalr	1912(ra) # 80003e74 <iunlockput>
  return 0;
    80005704:	bdcd                	j	800055f6 <create+0x76>
    return 0;
    80005706:	8aaa                	mv	s5,a0
    80005708:	b5fd                	j	800055f6 <create+0x76>

000000008000570a <sys_dup>:
{
    8000570a:	7179                	addi	sp,sp,-48
    8000570c:	f406                	sd	ra,40(sp)
    8000570e:	f022                	sd	s0,32(sp)
    80005710:	ec26                	sd	s1,24(sp)
    80005712:	e84a                	sd	s2,16(sp)
    80005714:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005716:	fd840613          	addi	a2,s0,-40
    8000571a:	4581                	li	a1,0
    8000571c:	4501                	li	a0,0
    8000571e:	00000097          	auipc	ra,0x0
    80005722:	dc0080e7          	jalr	-576(ra) # 800054de <argfd>
    return -1;
    80005726:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005728:	02054363          	bltz	a0,8000574e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000572c:	fd843903          	ld	s2,-40(s0)
    80005730:	854a                	mv	a0,s2
    80005732:	00000097          	auipc	ra,0x0
    80005736:	e0c080e7          	jalr	-500(ra) # 8000553e <fdalloc>
    8000573a:	84aa                	mv	s1,a0
    return -1;
    8000573c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000573e:	00054863          	bltz	a0,8000574e <sys_dup+0x44>
  filedup(f);
    80005742:	854a                	mv	a0,s2
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	310080e7          	jalr	784(ra) # 80004a54 <filedup>
  return fd;
    8000574c:	87a6                	mv	a5,s1
}
    8000574e:	853e                	mv	a0,a5
    80005750:	70a2                	ld	ra,40(sp)
    80005752:	7402                	ld	s0,32(sp)
    80005754:	64e2                	ld	s1,24(sp)
    80005756:	6942                	ld	s2,16(sp)
    80005758:	6145                	addi	sp,sp,48
    8000575a:	8082                	ret

000000008000575c <sys_read>:
{
    8000575c:	7179                	addi	sp,sp,-48
    8000575e:	f406                	sd	ra,40(sp)
    80005760:	f022                	sd	s0,32(sp)
    80005762:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005764:	fd840593          	addi	a1,s0,-40
    80005768:	4505                	li	a0,1
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	8b2080e7          	jalr	-1870(ra) # 8000301c <argaddr>
  argint(2, &n);
    80005772:	fe440593          	addi	a1,s0,-28
    80005776:	4509                	li	a0,2
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	884080e7          	jalr	-1916(ra) # 80002ffc <argint>
  if(argfd(0, 0, &f) < 0)
    80005780:	fe840613          	addi	a2,s0,-24
    80005784:	4581                	li	a1,0
    80005786:	4501                	li	a0,0
    80005788:	00000097          	auipc	ra,0x0
    8000578c:	d56080e7          	jalr	-682(ra) # 800054de <argfd>
    80005790:	87aa                	mv	a5,a0
    return -1;
    80005792:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005794:	0007cc63          	bltz	a5,800057ac <sys_read+0x50>
  return fileread(f, p, n);
    80005798:	fe442603          	lw	a2,-28(s0)
    8000579c:	fd843583          	ld	a1,-40(s0)
    800057a0:	fe843503          	ld	a0,-24(s0)
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	43c080e7          	jalr	1084(ra) # 80004be0 <fileread>
}
    800057ac:	70a2                	ld	ra,40(sp)
    800057ae:	7402                	ld	s0,32(sp)
    800057b0:	6145                	addi	sp,sp,48
    800057b2:	8082                	ret

00000000800057b4 <sys_write>:
{
    800057b4:	7179                	addi	sp,sp,-48
    800057b6:	f406                	sd	ra,40(sp)
    800057b8:	f022                	sd	s0,32(sp)
    800057ba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057bc:	fd840593          	addi	a1,s0,-40
    800057c0:	4505                	li	a0,1
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	85a080e7          	jalr	-1958(ra) # 8000301c <argaddr>
  argint(2, &n);
    800057ca:	fe440593          	addi	a1,s0,-28
    800057ce:	4509                	li	a0,2
    800057d0:	ffffe097          	auipc	ra,0xffffe
    800057d4:	82c080e7          	jalr	-2004(ra) # 80002ffc <argint>
  if(argfd(0, 0, &f) < 0)
    800057d8:	fe840613          	addi	a2,s0,-24
    800057dc:	4581                	li	a1,0
    800057de:	4501                	li	a0,0
    800057e0:	00000097          	auipc	ra,0x0
    800057e4:	cfe080e7          	jalr	-770(ra) # 800054de <argfd>
    800057e8:	87aa                	mv	a5,a0
    return -1;
    800057ea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057ec:	0007cc63          	bltz	a5,80005804 <sys_write+0x50>
  return filewrite(f, p, n);
    800057f0:	fe442603          	lw	a2,-28(s0)
    800057f4:	fd843583          	ld	a1,-40(s0)
    800057f8:	fe843503          	ld	a0,-24(s0)
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	4a6080e7          	jalr	1190(ra) # 80004ca2 <filewrite>
}
    80005804:	70a2                	ld	ra,40(sp)
    80005806:	7402                	ld	s0,32(sp)
    80005808:	6145                	addi	sp,sp,48
    8000580a:	8082                	ret

000000008000580c <sys_close>:
{
    8000580c:	1101                	addi	sp,sp,-32
    8000580e:	ec06                	sd	ra,24(sp)
    80005810:	e822                	sd	s0,16(sp)
    80005812:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005814:	fe040613          	addi	a2,s0,-32
    80005818:	fec40593          	addi	a1,s0,-20
    8000581c:	4501                	li	a0,0
    8000581e:	00000097          	auipc	ra,0x0
    80005822:	cc0080e7          	jalr	-832(ra) # 800054de <argfd>
    return -1;
    80005826:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005828:	02054463          	bltz	a0,80005850 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000582c:	ffffc097          	auipc	ra,0xffffc
    80005830:	456080e7          	jalr	1110(ra) # 80001c82 <myproc>
    80005834:	fec42783          	lw	a5,-20(s0)
    80005838:	07e9                	addi	a5,a5,26
    8000583a:	078e                	slli	a5,a5,0x3
    8000583c:	953e                	add	a0,a0,a5
    8000583e:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005842:	fe043503          	ld	a0,-32(s0)
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	260080e7          	jalr	608(ra) # 80004aa6 <fileclose>
  return 0;
    8000584e:	4781                	li	a5,0
}
    80005850:	853e                	mv	a0,a5
    80005852:	60e2                	ld	ra,24(sp)
    80005854:	6442                	ld	s0,16(sp)
    80005856:	6105                	addi	sp,sp,32
    80005858:	8082                	ret

000000008000585a <sys_fstat>:
{
    8000585a:	1101                	addi	sp,sp,-32
    8000585c:	ec06                	sd	ra,24(sp)
    8000585e:	e822                	sd	s0,16(sp)
    80005860:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005862:	fe040593          	addi	a1,s0,-32
    80005866:	4505                	li	a0,1
    80005868:	ffffd097          	auipc	ra,0xffffd
    8000586c:	7b4080e7          	jalr	1972(ra) # 8000301c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005870:	fe840613          	addi	a2,s0,-24
    80005874:	4581                	li	a1,0
    80005876:	4501                	li	a0,0
    80005878:	00000097          	auipc	ra,0x0
    8000587c:	c66080e7          	jalr	-922(ra) # 800054de <argfd>
    80005880:	87aa                	mv	a5,a0
    return -1;
    80005882:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005884:	0007ca63          	bltz	a5,80005898 <sys_fstat+0x3e>
  return filestat(f, st);
    80005888:	fe043583          	ld	a1,-32(s0)
    8000588c:	fe843503          	ld	a0,-24(s0)
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	2de080e7          	jalr	734(ra) # 80004b6e <filestat>
}
    80005898:	60e2                	ld	ra,24(sp)
    8000589a:	6442                	ld	s0,16(sp)
    8000589c:	6105                	addi	sp,sp,32
    8000589e:	8082                	ret

00000000800058a0 <sys_link>:
{
    800058a0:	7169                	addi	sp,sp,-304
    800058a2:	f606                	sd	ra,296(sp)
    800058a4:	f222                	sd	s0,288(sp)
    800058a6:	ee26                	sd	s1,280(sp)
    800058a8:	ea4a                	sd	s2,272(sp)
    800058aa:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058ac:	08000613          	li	a2,128
    800058b0:	ed040593          	addi	a1,s0,-304
    800058b4:	4501                	li	a0,0
    800058b6:	ffffd097          	auipc	ra,0xffffd
    800058ba:	786080e7          	jalr	1926(ra) # 8000303c <argstr>
    return -1;
    800058be:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058c0:	10054e63          	bltz	a0,800059dc <sys_link+0x13c>
    800058c4:	08000613          	li	a2,128
    800058c8:	f5040593          	addi	a1,s0,-176
    800058cc:	4505                	li	a0,1
    800058ce:	ffffd097          	auipc	ra,0xffffd
    800058d2:	76e080e7          	jalr	1902(ra) # 8000303c <argstr>
    return -1;
    800058d6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058d8:	10054263          	bltz	a0,800059dc <sys_link+0x13c>
  begin_op();
    800058dc:	fffff097          	auipc	ra,0xfffff
    800058e0:	d02080e7          	jalr	-766(ra) # 800045de <begin_op>
  if((ip = namei(old)) == 0){
    800058e4:	ed040513          	addi	a0,s0,-304
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	ad6080e7          	jalr	-1322(ra) # 800043be <namei>
    800058f0:	84aa                	mv	s1,a0
    800058f2:	c551                	beqz	a0,8000597e <sys_link+0xde>
  ilock(ip);
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	31e080e7          	jalr	798(ra) # 80003c12 <ilock>
  if(ip->type == T_DIR){
    800058fc:	04449703          	lh	a4,68(s1)
    80005900:	4785                	li	a5,1
    80005902:	08f70463          	beq	a4,a5,8000598a <sys_link+0xea>
  ip->nlink++;
    80005906:	04a4d783          	lhu	a5,74(s1)
    8000590a:	2785                	addiw	a5,a5,1
    8000590c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005910:	8526                	mv	a0,s1
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	234080e7          	jalr	564(ra) # 80003b46 <iupdate>
  iunlock(ip);
    8000591a:	8526                	mv	a0,s1
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	3b8080e7          	jalr	952(ra) # 80003cd4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005924:	fd040593          	addi	a1,s0,-48
    80005928:	f5040513          	addi	a0,s0,-176
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	ab0080e7          	jalr	-1360(ra) # 800043dc <nameiparent>
    80005934:	892a                	mv	s2,a0
    80005936:	c935                	beqz	a0,800059aa <sys_link+0x10a>
  ilock(dp);
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	2da080e7          	jalr	730(ra) # 80003c12 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005940:	00092703          	lw	a4,0(s2)
    80005944:	409c                	lw	a5,0(s1)
    80005946:	04f71d63          	bne	a4,a5,800059a0 <sys_link+0x100>
    8000594a:	40d0                	lw	a2,4(s1)
    8000594c:	fd040593          	addi	a1,s0,-48
    80005950:	854a                	mv	a0,s2
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	9ba080e7          	jalr	-1606(ra) # 8000430c <dirlink>
    8000595a:	04054363          	bltz	a0,800059a0 <sys_link+0x100>
  iunlockput(dp);
    8000595e:	854a                	mv	a0,s2
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	514080e7          	jalr	1300(ra) # 80003e74 <iunlockput>
  iput(ip);
    80005968:	8526                	mv	a0,s1
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	462080e7          	jalr	1122(ra) # 80003dcc <iput>
  end_op();
    80005972:	fffff097          	auipc	ra,0xfffff
    80005976:	cea080e7          	jalr	-790(ra) # 8000465c <end_op>
  return 0;
    8000597a:	4781                	li	a5,0
    8000597c:	a085                	j	800059dc <sys_link+0x13c>
    end_op();
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	cde080e7          	jalr	-802(ra) # 8000465c <end_op>
    return -1;
    80005986:	57fd                	li	a5,-1
    80005988:	a891                	j	800059dc <sys_link+0x13c>
    iunlockput(ip);
    8000598a:	8526                	mv	a0,s1
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	4e8080e7          	jalr	1256(ra) # 80003e74 <iunlockput>
    end_op();
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	cc8080e7          	jalr	-824(ra) # 8000465c <end_op>
    return -1;
    8000599c:	57fd                	li	a5,-1
    8000599e:	a83d                	j	800059dc <sys_link+0x13c>
    iunlockput(dp);
    800059a0:	854a                	mv	a0,s2
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	4d2080e7          	jalr	1234(ra) # 80003e74 <iunlockput>
  ilock(ip);
    800059aa:	8526                	mv	a0,s1
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	266080e7          	jalr	614(ra) # 80003c12 <ilock>
  ip->nlink--;
    800059b4:	04a4d783          	lhu	a5,74(s1)
    800059b8:	37fd                	addiw	a5,a5,-1
    800059ba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059be:	8526                	mv	a0,s1
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	186080e7          	jalr	390(ra) # 80003b46 <iupdate>
  iunlockput(ip);
    800059c8:	8526                	mv	a0,s1
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	4aa080e7          	jalr	1194(ra) # 80003e74 <iunlockput>
  end_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	c8a080e7          	jalr	-886(ra) # 8000465c <end_op>
  return -1;
    800059da:	57fd                	li	a5,-1
}
    800059dc:	853e                	mv	a0,a5
    800059de:	70b2                	ld	ra,296(sp)
    800059e0:	7412                	ld	s0,288(sp)
    800059e2:	64f2                	ld	s1,280(sp)
    800059e4:	6952                	ld	s2,272(sp)
    800059e6:	6155                	addi	sp,sp,304
    800059e8:	8082                	ret

00000000800059ea <sys_unlink>:
{
    800059ea:	7151                	addi	sp,sp,-240
    800059ec:	f586                	sd	ra,232(sp)
    800059ee:	f1a2                	sd	s0,224(sp)
    800059f0:	eda6                	sd	s1,216(sp)
    800059f2:	e9ca                	sd	s2,208(sp)
    800059f4:	e5ce                	sd	s3,200(sp)
    800059f6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059f8:	08000613          	li	a2,128
    800059fc:	f3040593          	addi	a1,s0,-208
    80005a00:	4501                	li	a0,0
    80005a02:	ffffd097          	auipc	ra,0xffffd
    80005a06:	63a080e7          	jalr	1594(ra) # 8000303c <argstr>
    80005a0a:	18054163          	bltz	a0,80005b8c <sys_unlink+0x1a2>
  begin_op();
    80005a0e:	fffff097          	auipc	ra,0xfffff
    80005a12:	bd0080e7          	jalr	-1072(ra) # 800045de <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a16:	fb040593          	addi	a1,s0,-80
    80005a1a:	f3040513          	addi	a0,s0,-208
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	9be080e7          	jalr	-1602(ra) # 800043dc <nameiparent>
    80005a26:	84aa                	mv	s1,a0
    80005a28:	c979                	beqz	a0,80005afe <sys_unlink+0x114>
  ilock(dp);
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	1e8080e7          	jalr	488(ra) # 80003c12 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a32:	00003597          	auipc	a1,0x3
    80005a36:	dc658593          	addi	a1,a1,-570 # 800087f8 <syscalls+0x2c0>
    80005a3a:	fb040513          	addi	a0,s0,-80
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	69e080e7          	jalr	1694(ra) # 800040dc <namecmp>
    80005a46:	14050a63          	beqz	a0,80005b9a <sys_unlink+0x1b0>
    80005a4a:	00003597          	auipc	a1,0x3
    80005a4e:	db658593          	addi	a1,a1,-586 # 80008800 <syscalls+0x2c8>
    80005a52:	fb040513          	addi	a0,s0,-80
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	686080e7          	jalr	1670(ra) # 800040dc <namecmp>
    80005a5e:	12050e63          	beqz	a0,80005b9a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a62:	f2c40613          	addi	a2,s0,-212
    80005a66:	fb040593          	addi	a1,s0,-80
    80005a6a:	8526                	mv	a0,s1
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	68a080e7          	jalr	1674(ra) # 800040f6 <dirlookup>
    80005a74:	892a                	mv	s2,a0
    80005a76:	12050263          	beqz	a0,80005b9a <sys_unlink+0x1b0>
  ilock(ip);
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	198080e7          	jalr	408(ra) # 80003c12 <ilock>
  if(ip->nlink < 1)
    80005a82:	04a91783          	lh	a5,74(s2)
    80005a86:	08f05263          	blez	a5,80005b0a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a8a:	04491703          	lh	a4,68(s2)
    80005a8e:	4785                	li	a5,1
    80005a90:	08f70563          	beq	a4,a5,80005b1a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a94:	4641                	li	a2,16
    80005a96:	4581                	li	a1,0
    80005a98:	fc040513          	addi	a0,s0,-64
    80005a9c:	ffffb097          	auipc	ra,0xffffb
    80005aa0:	236080e7          	jalr	566(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005aa4:	4741                	li	a4,16
    80005aa6:	f2c42683          	lw	a3,-212(s0)
    80005aaa:	fc040613          	addi	a2,s0,-64
    80005aae:	4581                	li	a1,0
    80005ab0:	8526                	mv	a0,s1
    80005ab2:	ffffe097          	auipc	ra,0xffffe
    80005ab6:	50c080e7          	jalr	1292(ra) # 80003fbe <writei>
    80005aba:	47c1                	li	a5,16
    80005abc:	0af51563          	bne	a0,a5,80005b66 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005ac0:	04491703          	lh	a4,68(s2)
    80005ac4:	4785                	li	a5,1
    80005ac6:	0af70863          	beq	a4,a5,80005b76 <sys_unlink+0x18c>
  iunlockput(dp);
    80005aca:	8526                	mv	a0,s1
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	3a8080e7          	jalr	936(ra) # 80003e74 <iunlockput>
  ip->nlink--;
    80005ad4:	04a95783          	lhu	a5,74(s2)
    80005ad8:	37fd                	addiw	a5,a5,-1
    80005ada:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ade:	854a                	mv	a0,s2
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	066080e7          	jalr	102(ra) # 80003b46 <iupdate>
  iunlockput(ip);
    80005ae8:	854a                	mv	a0,s2
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	38a080e7          	jalr	906(ra) # 80003e74 <iunlockput>
  end_op();
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	b6a080e7          	jalr	-1174(ra) # 8000465c <end_op>
  return 0;
    80005afa:	4501                	li	a0,0
    80005afc:	a84d                	j	80005bae <sys_unlink+0x1c4>
    end_op();
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	b5e080e7          	jalr	-1186(ra) # 8000465c <end_op>
    return -1;
    80005b06:	557d                	li	a0,-1
    80005b08:	a05d                	j	80005bae <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b0a:	00003517          	auipc	a0,0x3
    80005b0e:	cfe50513          	addi	a0,a0,-770 # 80008808 <syscalls+0x2d0>
    80005b12:	ffffb097          	auipc	ra,0xffffb
    80005b16:	a2e080e7          	jalr	-1490(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b1a:	04c92703          	lw	a4,76(s2)
    80005b1e:	02000793          	li	a5,32
    80005b22:	f6e7f9e3          	bgeu	a5,a4,80005a94 <sys_unlink+0xaa>
    80005b26:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b2a:	4741                	li	a4,16
    80005b2c:	86ce                	mv	a3,s3
    80005b2e:	f1840613          	addi	a2,s0,-232
    80005b32:	4581                	li	a1,0
    80005b34:	854a                	mv	a0,s2
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	390080e7          	jalr	912(ra) # 80003ec6 <readi>
    80005b3e:	47c1                	li	a5,16
    80005b40:	00f51b63          	bne	a0,a5,80005b56 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b44:	f1845783          	lhu	a5,-232(s0)
    80005b48:	e7a1                	bnez	a5,80005b90 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b4a:	29c1                	addiw	s3,s3,16
    80005b4c:	04c92783          	lw	a5,76(s2)
    80005b50:	fcf9ede3          	bltu	s3,a5,80005b2a <sys_unlink+0x140>
    80005b54:	b781                	j	80005a94 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b56:	00003517          	auipc	a0,0x3
    80005b5a:	cca50513          	addi	a0,a0,-822 # 80008820 <syscalls+0x2e8>
    80005b5e:	ffffb097          	auipc	ra,0xffffb
    80005b62:	9e2080e7          	jalr	-1566(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005b66:	00003517          	auipc	a0,0x3
    80005b6a:	cd250513          	addi	a0,a0,-814 # 80008838 <syscalls+0x300>
    80005b6e:	ffffb097          	auipc	ra,0xffffb
    80005b72:	9d2080e7          	jalr	-1582(ra) # 80000540 <panic>
    dp->nlink--;
    80005b76:	04a4d783          	lhu	a5,74(s1)
    80005b7a:	37fd                	addiw	a5,a5,-1
    80005b7c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	fc4080e7          	jalr	-60(ra) # 80003b46 <iupdate>
    80005b8a:	b781                	j	80005aca <sys_unlink+0xe0>
    return -1;
    80005b8c:	557d                	li	a0,-1
    80005b8e:	a005                	j	80005bae <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b90:	854a                	mv	a0,s2
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	2e2080e7          	jalr	738(ra) # 80003e74 <iunlockput>
  iunlockput(dp);
    80005b9a:	8526                	mv	a0,s1
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	2d8080e7          	jalr	728(ra) # 80003e74 <iunlockput>
  end_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	ab8080e7          	jalr	-1352(ra) # 8000465c <end_op>
  return -1;
    80005bac:	557d                	li	a0,-1
}
    80005bae:	70ae                	ld	ra,232(sp)
    80005bb0:	740e                	ld	s0,224(sp)
    80005bb2:	64ee                	ld	s1,216(sp)
    80005bb4:	694e                	ld	s2,208(sp)
    80005bb6:	69ae                	ld	s3,200(sp)
    80005bb8:	616d                	addi	sp,sp,240
    80005bba:	8082                	ret

0000000080005bbc <sys_open>:

uint64
sys_open(void)
{
    80005bbc:	7131                	addi	sp,sp,-192
    80005bbe:	fd06                	sd	ra,184(sp)
    80005bc0:	f922                	sd	s0,176(sp)
    80005bc2:	f526                	sd	s1,168(sp)
    80005bc4:	f14a                	sd	s2,160(sp)
    80005bc6:	ed4e                	sd	s3,152(sp)
    80005bc8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bca:	f4c40593          	addi	a1,s0,-180
    80005bce:	4505                	li	a0,1
    80005bd0:	ffffd097          	auipc	ra,0xffffd
    80005bd4:	42c080e7          	jalr	1068(ra) # 80002ffc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bd8:	08000613          	li	a2,128
    80005bdc:	f5040593          	addi	a1,s0,-176
    80005be0:	4501                	li	a0,0
    80005be2:	ffffd097          	auipc	ra,0xffffd
    80005be6:	45a080e7          	jalr	1114(ra) # 8000303c <argstr>
    80005bea:	87aa                	mv	a5,a0
    return -1;
    80005bec:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bee:	0a07c963          	bltz	a5,80005ca0 <sys_open+0xe4>

  begin_op();
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	9ec080e7          	jalr	-1556(ra) # 800045de <begin_op>

  if(omode & O_CREATE){
    80005bfa:	f4c42783          	lw	a5,-180(s0)
    80005bfe:	2007f793          	andi	a5,a5,512
    80005c02:	cfc5                	beqz	a5,80005cba <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c04:	4681                	li	a3,0
    80005c06:	4601                	li	a2,0
    80005c08:	4589                	li	a1,2
    80005c0a:	f5040513          	addi	a0,s0,-176
    80005c0e:	00000097          	auipc	ra,0x0
    80005c12:	972080e7          	jalr	-1678(ra) # 80005580 <create>
    80005c16:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c18:	c959                	beqz	a0,80005cae <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c1a:	04449703          	lh	a4,68(s1)
    80005c1e:	478d                	li	a5,3
    80005c20:	00f71763          	bne	a4,a5,80005c2e <sys_open+0x72>
    80005c24:	0464d703          	lhu	a4,70(s1)
    80005c28:	47a5                	li	a5,9
    80005c2a:	0ce7ed63          	bltu	a5,a4,80005d04 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	dbc080e7          	jalr	-580(ra) # 800049ea <filealloc>
    80005c36:	89aa                	mv	s3,a0
    80005c38:	10050363          	beqz	a0,80005d3e <sys_open+0x182>
    80005c3c:	00000097          	auipc	ra,0x0
    80005c40:	902080e7          	jalr	-1790(ra) # 8000553e <fdalloc>
    80005c44:	892a                	mv	s2,a0
    80005c46:	0e054763          	bltz	a0,80005d34 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c4a:	04449703          	lh	a4,68(s1)
    80005c4e:	478d                	li	a5,3
    80005c50:	0cf70563          	beq	a4,a5,80005d1a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c54:	4789                	li	a5,2
    80005c56:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c5a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c5e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c62:	f4c42783          	lw	a5,-180(s0)
    80005c66:	0017c713          	xori	a4,a5,1
    80005c6a:	8b05                	andi	a4,a4,1
    80005c6c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c70:	0037f713          	andi	a4,a5,3
    80005c74:	00e03733          	snez	a4,a4
    80005c78:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c7c:	4007f793          	andi	a5,a5,1024
    80005c80:	c791                	beqz	a5,80005c8c <sys_open+0xd0>
    80005c82:	04449703          	lh	a4,68(s1)
    80005c86:	4789                	li	a5,2
    80005c88:	0af70063          	beq	a4,a5,80005d28 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c8c:	8526                	mv	a0,s1
    80005c8e:	ffffe097          	auipc	ra,0xffffe
    80005c92:	046080e7          	jalr	70(ra) # 80003cd4 <iunlock>
  end_op();
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	9c6080e7          	jalr	-1594(ra) # 8000465c <end_op>

  return fd;
    80005c9e:	854a                	mv	a0,s2
}
    80005ca0:	70ea                	ld	ra,184(sp)
    80005ca2:	744a                	ld	s0,176(sp)
    80005ca4:	74aa                	ld	s1,168(sp)
    80005ca6:	790a                	ld	s2,160(sp)
    80005ca8:	69ea                	ld	s3,152(sp)
    80005caa:	6129                	addi	sp,sp,192
    80005cac:	8082                	ret
      end_op();
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	9ae080e7          	jalr	-1618(ra) # 8000465c <end_op>
      return -1;
    80005cb6:	557d                	li	a0,-1
    80005cb8:	b7e5                	j	80005ca0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005cba:	f5040513          	addi	a0,s0,-176
    80005cbe:	ffffe097          	auipc	ra,0xffffe
    80005cc2:	700080e7          	jalr	1792(ra) # 800043be <namei>
    80005cc6:	84aa                	mv	s1,a0
    80005cc8:	c905                	beqz	a0,80005cf8 <sys_open+0x13c>
    ilock(ip);
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	f48080e7          	jalr	-184(ra) # 80003c12 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cd2:	04449703          	lh	a4,68(s1)
    80005cd6:	4785                	li	a5,1
    80005cd8:	f4f711e3          	bne	a4,a5,80005c1a <sys_open+0x5e>
    80005cdc:	f4c42783          	lw	a5,-180(s0)
    80005ce0:	d7b9                	beqz	a5,80005c2e <sys_open+0x72>
      iunlockput(ip);
    80005ce2:	8526                	mv	a0,s1
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	190080e7          	jalr	400(ra) # 80003e74 <iunlockput>
      end_op();
    80005cec:	fffff097          	auipc	ra,0xfffff
    80005cf0:	970080e7          	jalr	-1680(ra) # 8000465c <end_op>
      return -1;
    80005cf4:	557d                	li	a0,-1
    80005cf6:	b76d                	j	80005ca0 <sys_open+0xe4>
      end_op();
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	964080e7          	jalr	-1692(ra) # 8000465c <end_op>
      return -1;
    80005d00:	557d                	li	a0,-1
    80005d02:	bf79                	j	80005ca0 <sys_open+0xe4>
    iunlockput(ip);
    80005d04:	8526                	mv	a0,s1
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	16e080e7          	jalr	366(ra) # 80003e74 <iunlockput>
    end_op();
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	94e080e7          	jalr	-1714(ra) # 8000465c <end_op>
    return -1;
    80005d16:	557d                	li	a0,-1
    80005d18:	b761                	j	80005ca0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d1a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d1e:	04649783          	lh	a5,70(s1)
    80005d22:	02f99223          	sh	a5,36(s3)
    80005d26:	bf25                	j	80005c5e <sys_open+0xa2>
    itrunc(ip);
    80005d28:	8526                	mv	a0,s1
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	ff6080e7          	jalr	-10(ra) # 80003d20 <itrunc>
    80005d32:	bfa9                	j	80005c8c <sys_open+0xd0>
      fileclose(f);
    80005d34:	854e                	mv	a0,s3
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	d70080e7          	jalr	-656(ra) # 80004aa6 <fileclose>
    iunlockput(ip);
    80005d3e:	8526                	mv	a0,s1
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	134080e7          	jalr	308(ra) # 80003e74 <iunlockput>
    end_op();
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	914080e7          	jalr	-1772(ra) # 8000465c <end_op>
    return -1;
    80005d50:	557d                	li	a0,-1
    80005d52:	b7b9                	j	80005ca0 <sys_open+0xe4>

0000000080005d54 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d54:	7175                	addi	sp,sp,-144
    80005d56:	e506                	sd	ra,136(sp)
    80005d58:	e122                	sd	s0,128(sp)
    80005d5a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d5c:	fffff097          	auipc	ra,0xfffff
    80005d60:	882080e7          	jalr	-1918(ra) # 800045de <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d64:	08000613          	li	a2,128
    80005d68:	f7040593          	addi	a1,s0,-144
    80005d6c:	4501                	li	a0,0
    80005d6e:	ffffd097          	auipc	ra,0xffffd
    80005d72:	2ce080e7          	jalr	718(ra) # 8000303c <argstr>
    80005d76:	02054963          	bltz	a0,80005da8 <sys_mkdir+0x54>
    80005d7a:	4681                	li	a3,0
    80005d7c:	4601                	li	a2,0
    80005d7e:	4585                	li	a1,1
    80005d80:	f7040513          	addi	a0,s0,-144
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	7fc080e7          	jalr	2044(ra) # 80005580 <create>
    80005d8c:	cd11                	beqz	a0,80005da8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	0e6080e7          	jalr	230(ra) # 80003e74 <iunlockput>
  end_op();
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	8c6080e7          	jalr	-1850(ra) # 8000465c <end_op>
  return 0;
    80005d9e:	4501                	li	a0,0
}
    80005da0:	60aa                	ld	ra,136(sp)
    80005da2:	640a                	ld	s0,128(sp)
    80005da4:	6149                	addi	sp,sp,144
    80005da6:	8082                	ret
    end_op();
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	8b4080e7          	jalr	-1868(ra) # 8000465c <end_op>
    return -1;
    80005db0:	557d                	li	a0,-1
    80005db2:	b7fd                	j	80005da0 <sys_mkdir+0x4c>

0000000080005db4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005db4:	7135                	addi	sp,sp,-160
    80005db6:	ed06                	sd	ra,152(sp)
    80005db8:	e922                	sd	s0,144(sp)
    80005dba:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	822080e7          	jalr	-2014(ra) # 800045de <begin_op>
  argint(1, &major);
    80005dc4:	f6c40593          	addi	a1,s0,-148
    80005dc8:	4505                	li	a0,1
    80005dca:	ffffd097          	auipc	ra,0xffffd
    80005dce:	232080e7          	jalr	562(ra) # 80002ffc <argint>
  argint(2, &minor);
    80005dd2:	f6840593          	addi	a1,s0,-152
    80005dd6:	4509                	li	a0,2
    80005dd8:	ffffd097          	auipc	ra,0xffffd
    80005ddc:	224080e7          	jalr	548(ra) # 80002ffc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005de0:	08000613          	li	a2,128
    80005de4:	f7040593          	addi	a1,s0,-144
    80005de8:	4501                	li	a0,0
    80005dea:	ffffd097          	auipc	ra,0xffffd
    80005dee:	252080e7          	jalr	594(ra) # 8000303c <argstr>
    80005df2:	02054b63          	bltz	a0,80005e28 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005df6:	f6841683          	lh	a3,-152(s0)
    80005dfa:	f6c41603          	lh	a2,-148(s0)
    80005dfe:	458d                	li	a1,3
    80005e00:	f7040513          	addi	a0,s0,-144
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	77c080e7          	jalr	1916(ra) # 80005580 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e0c:	cd11                	beqz	a0,80005e28 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e0e:	ffffe097          	auipc	ra,0xffffe
    80005e12:	066080e7          	jalr	102(ra) # 80003e74 <iunlockput>
  end_op();
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	846080e7          	jalr	-1978(ra) # 8000465c <end_op>
  return 0;
    80005e1e:	4501                	li	a0,0
}
    80005e20:	60ea                	ld	ra,152(sp)
    80005e22:	644a                	ld	s0,144(sp)
    80005e24:	610d                	addi	sp,sp,160
    80005e26:	8082                	ret
    end_op();
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	834080e7          	jalr	-1996(ra) # 8000465c <end_op>
    return -1;
    80005e30:	557d                	li	a0,-1
    80005e32:	b7fd                	j	80005e20 <sys_mknod+0x6c>

0000000080005e34 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e34:	7135                	addi	sp,sp,-160
    80005e36:	ed06                	sd	ra,152(sp)
    80005e38:	e922                	sd	s0,144(sp)
    80005e3a:	e526                	sd	s1,136(sp)
    80005e3c:	e14a                	sd	s2,128(sp)
    80005e3e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	e42080e7          	jalr	-446(ra) # 80001c82 <myproc>
    80005e48:	892a                	mv	s2,a0
  
  begin_op();
    80005e4a:	ffffe097          	auipc	ra,0xffffe
    80005e4e:	794080e7          	jalr	1940(ra) # 800045de <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e52:	08000613          	li	a2,128
    80005e56:	f6040593          	addi	a1,s0,-160
    80005e5a:	4501                	li	a0,0
    80005e5c:	ffffd097          	auipc	ra,0xffffd
    80005e60:	1e0080e7          	jalr	480(ra) # 8000303c <argstr>
    80005e64:	04054b63          	bltz	a0,80005eba <sys_chdir+0x86>
    80005e68:	f6040513          	addi	a0,s0,-160
    80005e6c:	ffffe097          	auipc	ra,0xffffe
    80005e70:	552080e7          	jalr	1362(ra) # 800043be <namei>
    80005e74:	84aa                	mv	s1,a0
    80005e76:	c131                	beqz	a0,80005eba <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e78:	ffffe097          	auipc	ra,0xffffe
    80005e7c:	d9a080e7          	jalr	-614(ra) # 80003c12 <ilock>
  if(ip->type != T_DIR){
    80005e80:	04449703          	lh	a4,68(s1)
    80005e84:	4785                	li	a5,1
    80005e86:	04f71063          	bne	a4,a5,80005ec6 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e8a:	8526                	mv	a0,s1
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	e48080e7          	jalr	-440(ra) # 80003cd4 <iunlock>
  iput(p->cwd);
    80005e94:	15893503          	ld	a0,344(s2)
    80005e98:	ffffe097          	auipc	ra,0xffffe
    80005e9c:	f34080e7          	jalr	-204(ra) # 80003dcc <iput>
  end_op();
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	7bc080e7          	jalr	1980(ra) # 8000465c <end_op>
  p->cwd = ip;
    80005ea8:	14993c23          	sd	s1,344(s2)
  return 0;
    80005eac:	4501                	li	a0,0
}
    80005eae:	60ea                	ld	ra,152(sp)
    80005eb0:	644a                	ld	s0,144(sp)
    80005eb2:	64aa                	ld	s1,136(sp)
    80005eb4:	690a                	ld	s2,128(sp)
    80005eb6:	610d                	addi	sp,sp,160
    80005eb8:	8082                	ret
    end_op();
    80005eba:	ffffe097          	auipc	ra,0xffffe
    80005ebe:	7a2080e7          	jalr	1954(ra) # 8000465c <end_op>
    return -1;
    80005ec2:	557d                	li	a0,-1
    80005ec4:	b7ed                	j	80005eae <sys_chdir+0x7a>
    iunlockput(ip);
    80005ec6:	8526                	mv	a0,s1
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	fac080e7          	jalr	-84(ra) # 80003e74 <iunlockput>
    end_op();
    80005ed0:	ffffe097          	auipc	ra,0xffffe
    80005ed4:	78c080e7          	jalr	1932(ra) # 8000465c <end_op>
    return -1;
    80005ed8:	557d                	li	a0,-1
    80005eda:	bfd1                	j	80005eae <sys_chdir+0x7a>

0000000080005edc <sys_exec>:

uint64
sys_exec(void)
{
    80005edc:	7145                	addi	sp,sp,-464
    80005ede:	e786                	sd	ra,456(sp)
    80005ee0:	e3a2                	sd	s0,448(sp)
    80005ee2:	ff26                	sd	s1,440(sp)
    80005ee4:	fb4a                	sd	s2,432(sp)
    80005ee6:	f74e                	sd	s3,424(sp)
    80005ee8:	f352                	sd	s4,416(sp)
    80005eea:	ef56                	sd	s5,408(sp)
    80005eec:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005eee:	e3840593          	addi	a1,s0,-456
    80005ef2:	4505                	li	a0,1
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	128080e7          	jalr	296(ra) # 8000301c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005efc:	08000613          	li	a2,128
    80005f00:	f4040593          	addi	a1,s0,-192
    80005f04:	4501                	li	a0,0
    80005f06:	ffffd097          	auipc	ra,0xffffd
    80005f0a:	136080e7          	jalr	310(ra) # 8000303c <argstr>
    80005f0e:	87aa                	mv	a5,a0
    return -1;
    80005f10:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f12:	0c07c363          	bltz	a5,80005fd8 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005f16:	10000613          	li	a2,256
    80005f1a:	4581                	li	a1,0
    80005f1c:	e4040513          	addi	a0,s0,-448
    80005f20:	ffffb097          	auipc	ra,0xffffb
    80005f24:	db2080e7          	jalr	-590(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f28:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f2c:	89a6                	mv	s3,s1
    80005f2e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f30:	02000a13          	li	s4,32
    80005f34:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f38:	00391513          	slli	a0,s2,0x3
    80005f3c:	e3040593          	addi	a1,s0,-464
    80005f40:	e3843783          	ld	a5,-456(s0)
    80005f44:	953e                	add	a0,a0,a5
    80005f46:	ffffd097          	auipc	ra,0xffffd
    80005f4a:	018080e7          	jalr	24(ra) # 80002f5e <fetchaddr>
    80005f4e:	02054a63          	bltz	a0,80005f82 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f52:	e3043783          	ld	a5,-464(s0)
    80005f56:	c3b9                	beqz	a5,80005f9c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f58:	ffffb097          	auipc	ra,0xffffb
    80005f5c:	b8e080e7          	jalr	-1138(ra) # 80000ae6 <kalloc>
    80005f60:	85aa                	mv	a1,a0
    80005f62:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f66:	cd11                	beqz	a0,80005f82 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f68:	6605                	lui	a2,0x1
    80005f6a:	e3043503          	ld	a0,-464(s0)
    80005f6e:	ffffd097          	auipc	ra,0xffffd
    80005f72:	042080e7          	jalr	66(ra) # 80002fb0 <fetchstr>
    80005f76:	00054663          	bltz	a0,80005f82 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f7a:	0905                	addi	s2,s2,1
    80005f7c:	09a1                	addi	s3,s3,8
    80005f7e:	fb491be3          	bne	s2,s4,80005f34 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f82:	f4040913          	addi	s2,s0,-192
    80005f86:	6088                	ld	a0,0(s1)
    80005f88:	c539                	beqz	a0,80005fd6 <sys_exec+0xfa>
    kfree(argv[i]);
    80005f8a:	ffffb097          	auipc	ra,0xffffb
    80005f8e:	a5e080e7          	jalr	-1442(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f92:	04a1                	addi	s1,s1,8
    80005f94:	ff2499e3          	bne	s1,s2,80005f86 <sys_exec+0xaa>
  return -1;
    80005f98:	557d                	li	a0,-1
    80005f9a:	a83d                	j	80005fd8 <sys_exec+0xfc>
      argv[i] = 0;
    80005f9c:	0a8e                	slli	s5,s5,0x3
    80005f9e:	fc0a8793          	addi	a5,s5,-64
    80005fa2:	00878ab3          	add	s5,a5,s0
    80005fa6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005faa:	e4040593          	addi	a1,s0,-448
    80005fae:	f4040513          	addi	a0,s0,-192
    80005fb2:	fffff097          	auipc	ra,0xfffff
    80005fb6:	16e080e7          	jalr	366(ra) # 80005120 <exec>
    80005fba:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fbc:	f4040993          	addi	s3,s0,-192
    80005fc0:	6088                	ld	a0,0(s1)
    80005fc2:	c901                	beqz	a0,80005fd2 <sys_exec+0xf6>
    kfree(argv[i]);
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	a24080e7          	jalr	-1500(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fcc:	04a1                	addi	s1,s1,8
    80005fce:	ff3499e3          	bne	s1,s3,80005fc0 <sys_exec+0xe4>
  return ret;
    80005fd2:	854a                	mv	a0,s2
    80005fd4:	a011                	j	80005fd8 <sys_exec+0xfc>
  return -1;
    80005fd6:	557d                	li	a0,-1
}
    80005fd8:	60be                	ld	ra,456(sp)
    80005fda:	641e                	ld	s0,448(sp)
    80005fdc:	74fa                	ld	s1,440(sp)
    80005fde:	795a                	ld	s2,432(sp)
    80005fe0:	79ba                	ld	s3,424(sp)
    80005fe2:	7a1a                	ld	s4,416(sp)
    80005fe4:	6afa                	ld	s5,408(sp)
    80005fe6:	6179                	addi	sp,sp,464
    80005fe8:	8082                	ret

0000000080005fea <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fea:	7139                	addi	sp,sp,-64
    80005fec:	fc06                	sd	ra,56(sp)
    80005fee:	f822                	sd	s0,48(sp)
    80005ff0:	f426                	sd	s1,40(sp)
    80005ff2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ff4:	ffffc097          	auipc	ra,0xffffc
    80005ff8:	c8e080e7          	jalr	-882(ra) # 80001c82 <myproc>
    80005ffc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ffe:	fd840593          	addi	a1,s0,-40
    80006002:	4501                	li	a0,0
    80006004:	ffffd097          	auipc	ra,0xffffd
    80006008:	018080e7          	jalr	24(ra) # 8000301c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000600c:	fc840593          	addi	a1,s0,-56
    80006010:	fd040513          	addi	a0,s0,-48
    80006014:	fffff097          	auipc	ra,0xfffff
    80006018:	dc2080e7          	jalr	-574(ra) # 80004dd6 <pipealloc>
    return -1;
    8000601c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000601e:	0c054463          	bltz	a0,800060e6 <sys_pipe+0xfc>
  fd0 = -1;
    80006022:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006026:	fd043503          	ld	a0,-48(s0)
    8000602a:	fffff097          	auipc	ra,0xfffff
    8000602e:	514080e7          	jalr	1300(ra) # 8000553e <fdalloc>
    80006032:	fca42223          	sw	a0,-60(s0)
    80006036:	08054b63          	bltz	a0,800060cc <sys_pipe+0xe2>
    8000603a:	fc843503          	ld	a0,-56(s0)
    8000603e:	fffff097          	auipc	ra,0xfffff
    80006042:	500080e7          	jalr	1280(ra) # 8000553e <fdalloc>
    80006046:	fca42023          	sw	a0,-64(s0)
    8000604a:	06054863          	bltz	a0,800060ba <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000604e:	4691                	li	a3,4
    80006050:	fc440613          	addi	a2,s0,-60
    80006054:	fd843583          	ld	a1,-40(s0)
    80006058:	6ca8                	ld	a0,88(s1)
    8000605a:	ffffb097          	auipc	ra,0xffffb
    8000605e:	612080e7          	jalr	1554(ra) # 8000166c <copyout>
    80006062:	02054063          	bltz	a0,80006082 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006066:	4691                	li	a3,4
    80006068:	fc040613          	addi	a2,s0,-64
    8000606c:	fd843583          	ld	a1,-40(s0)
    80006070:	0591                	addi	a1,a1,4
    80006072:	6ca8                	ld	a0,88(s1)
    80006074:	ffffb097          	auipc	ra,0xffffb
    80006078:	5f8080e7          	jalr	1528(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000607c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000607e:	06055463          	bgez	a0,800060e6 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006082:	fc442783          	lw	a5,-60(s0)
    80006086:	07e9                	addi	a5,a5,26
    80006088:	078e                	slli	a5,a5,0x3
    8000608a:	97a6                	add	a5,a5,s1
    8000608c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006090:	fc042783          	lw	a5,-64(s0)
    80006094:	07e9                	addi	a5,a5,26
    80006096:	078e                	slli	a5,a5,0x3
    80006098:	94be                	add	s1,s1,a5
    8000609a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000609e:	fd043503          	ld	a0,-48(s0)
    800060a2:	fffff097          	auipc	ra,0xfffff
    800060a6:	a04080e7          	jalr	-1532(ra) # 80004aa6 <fileclose>
    fileclose(wf);
    800060aa:	fc843503          	ld	a0,-56(s0)
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	9f8080e7          	jalr	-1544(ra) # 80004aa6 <fileclose>
    return -1;
    800060b6:	57fd                	li	a5,-1
    800060b8:	a03d                	j	800060e6 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060ba:	fc442783          	lw	a5,-60(s0)
    800060be:	0007c763          	bltz	a5,800060cc <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060c2:	07e9                	addi	a5,a5,26
    800060c4:	078e                	slli	a5,a5,0x3
    800060c6:	97a6                	add	a5,a5,s1
    800060c8:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800060cc:	fd043503          	ld	a0,-48(s0)
    800060d0:	fffff097          	auipc	ra,0xfffff
    800060d4:	9d6080e7          	jalr	-1578(ra) # 80004aa6 <fileclose>
    fileclose(wf);
    800060d8:	fc843503          	ld	a0,-56(s0)
    800060dc:	fffff097          	auipc	ra,0xfffff
    800060e0:	9ca080e7          	jalr	-1590(ra) # 80004aa6 <fileclose>
    return -1;
    800060e4:	57fd                	li	a5,-1
}
    800060e6:	853e                	mv	a0,a5
    800060e8:	70e2                	ld	ra,56(sp)
    800060ea:	7442                	ld	s0,48(sp)
    800060ec:	74a2                	ld	s1,40(sp)
    800060ee:	6121                	addi	sp,sp,64
    800060f0:	8082                	ret
	...

0000000080006100 <kernelvec>:
    80006100:	7111                	addi	sp,sp,-256
    80006102:	e006                	sd	ra,0(sp)
    80006104:	e40a                	sd	sp,8(sp)
    80006106:	e80e                	sd	gp,16(sp)
    80006108:	ec12                	sd	tp,24(sp)
    8000610a:	f016                	sd	t0,32(sp)
    8000610c:	f41a                	sd	t1,40(sp)
    8000610e:	f81e                	sd	t2,48(sp)
    80006110:	fc22                	sd	s0,56(sp)
    80006112:	e0a6                	sd	s1,64(sp)
    80006114:	e4aa                	sd	a0,72(sp)
    80006116:	e8ae                	sd	a1,80(sp)
    80006118:	ecb2                	sd	a2,88(sp)
    8000611a:	f0b6                	sd	a3,96(sp)
    8000611c:	f4ba                	sd	a4,104(sp)
    8000611e:	f8be                	sd	a5,112(sp)
    80006120:	fcc2                	sd	a6,120(sp)
    80006122:	e146                	sd	a7,128(sp)
    80006124:	e54a                	sd	s2,136(sp)
    80006126:	e94e                	sd	s3,144(sp)
    80006128:	ed52                	sd	s4,152(sp)
    8000612a:	f156                	sd	s5,160(sp)
    8000612c:	f55a                	sd	s6,168(sp)
    8000612e:	f95e                	sd	s7,176(sp)
    80006130:	fd62                	sd	s8,184(sp)
    80006132:	e1e6                	sd	s9,192(sp)
    80006134:	e5ea                	sd	s10,200(sp)
    80006136:	e9ee                	sd	s11,208(sp)
    80006138:	edf2                	sd	t3,216(sp)
    8000613a:	f1f6                	sd	t4,224(sp)
    8000613c:	f5fa                	sd	t5,232(sp)
    8000613e:	f9fe                	sd	t6,240(sp)
    80006140:	ce9fc0ef          	jal	ra,80002e28 <kerneltrap>
    80006144:	6082                	ld	ra,0(sp)
    80006146:	6122                	ld	sp,8(sp)
    80006148:	61c2                	ld	gp,16(sp)
    8000614a:	7282                	ld	t0,32(sp)
    8000614c:	7322                	ld	t1,40(sp)
    8000614e:	73c2                	ld	t2,48(sp)
    80006150:	7462                	ld	s0,56(sp)
    80006152:	6486                	ld	s1,64(sp)
    80006154:	6526                	ld	a0,72(sp)
    80006156:	65c6                	ld	a1,80(sp)
    80006158:	6666                	ld	a2,88(sp)
    8000615a:	7686                	ld	a3,96(sp)
    8000615c:	7726                	ld	a4,104(sp)
    8000615e:	77c6                	ld	a5,112(sp)
    80006160:	7866                	ld	a6,120(sp)
    80006162:	688a                	ld	a7,128(sp)
    80006164:	692a                	ld	s2,136(sp)
    80006166:	69ca                	ld	s3,144(sp)
    80006168:	6a6a                	ld	s4,152(sp)
    8000616a:	7a8a                	ld	s5,160(sp)
    8000616c:	7b2a                	ld	s6,168(sp)
    8000616e:	7bca                	ld	s7,176(sp)
    80006170:	7c6a                	ld	s8,184(sp)
    80006172:	6c8e                	ld	s9,192(sp)
    80006174:	6d2e                	ld	s10,200(sp)
    80006176:	6dce                	ld	s11,208(sp)
    80006178:	6e6e                	ld	t3,216(sp)
    8000617a:	7e8e                	ld	t4,224(sp)
    8000617c:	7f2e                	ld	t5,232(sp)
    8000617e:	7fce                	ld	t6,240(sp)
    80006180:	6111                	addi	sp,sp,256
    80006182:	10200073          	sret
    80006186:	00000013          	nop
    8000618a:	00000013          	nop
    8000618e:	0001                	nop

0000000080006190 <timervec>:
    80006190:	34051573          	csrrw	a0,mscratch,a0
    80006194:	e10c                	sd	a1,0(a0)
    80006196:	e510                	sd	a2,8(a0)
    80006198:	e914                	sd	a3,16(a0)
    8000619a:	6d0c                	ld	a1,24(a0)
    8000619c:	7110                	ld	a2,32(a0)
    8000619e:	6194                	ld	a3,0(a1)
    800061a0:	96b2                	add	a3,a3,a2
    800061a2:	e194                	sd	a3,0(a1)
    800061a4:	4589                	li	a1,2
    800061a6:	14459073          	csrw	sip,a1
    800061aa:	6914                	ld	a3,16(a0)
    800061ac:	6510                	ld	a2,8(a0)
    800061ae:	610c                	ld	a1,0(a0)
    800061b0:	34051573          	csrrw	a0,mscratch,a0
    800061b4:	30200073          	mret
	...

00000000800061ba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061ba:	1141                	addi	sp,sp,-16
    800061bc:	e422                	sd	s0,8(sp)
    800061be:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061c0:	0c0007b7          	lui	a5,0xc000
    800061c4:	4705                	li	a4,1
    800061c6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061c8:	c3d8                	sw	a4,4(a5)
}
    800061ca:	6422                	ld	s0,8(sp)
    800061cc:	0141                	addi	sp,sp,16
    800061ce:	8082                	ret

00000000800061d0 <plicinithart>:

void
plicinithart(void)
{
    800061d0:	1141                	addi	sp,sp,-16
    800061d2:	e406                	sd	ra,8(sp)
    800061d4:	e022                	sd	s0,0(sp)
    800061d6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	a7e080e7          	jalr	-1410(ra) # 80001c56 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061e0:	0085171b          	slliw	a4,a0,0x8
    800061e4:	0c0027b7          	lui	a5,0xc002
    800061e8:	97ba                	add	a5,a5,a4
    800061ea:	40200713          	li	a4,1026
    800061ee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061f2:	00d5151b          	slliw	a0,a0,0xd
    800061f6:	0c2017b7          	lui	a5,0xc201
    800061fa:	97aa                	add	a5,a5,a0
    800061fc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006200:	60a2                	ld	ra,8(sp)
    80006202:	6402                	ld	s0,0(sp)
    80006204:	0141                	addi	sp,sp,16
    80006206:	8082                	ret

0000000080006208 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006208:	1141                	addi	sp,sp,-16
    8000620a:	e406                	sd	ra,8(sp)
    8000620c:	e022                	sd	s0,0(sp)
    8000620e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006210:	ffffc097          	auipc	ra,0xffffc
    80006214:	a46080e7          	jalr	-1466(ra) # 80001c56 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006218:	00d5151b          	slliw	a0,a0,0xd
    8000621c:	0c2017b7          	lui	a5,0xc201
    80006220:	97aa                	add	a5,a5,a0
  return irq;
}
    80006222:	43c8                	lw	a0,4(a5)
    80006224:	60a2                	ld	ra,8(sp)
    80006226:	6402                	ld	s0,0(sp)
    80006228:	0141                	addi	sp,sp,16
    8000622a:	8082                	ret

000000008000622c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000622c:	1101                	addi	sp,sp,-32
    8000622e:	ec06                	sd	ra,24(sp)
    80006230:	e822                	sd	s0,16(sp)
    80006232:	e426                	sd	s1,8(sp)
    80006234:	1000                	addi	s0,sp,32
    80006236:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006238:	ffffc097          	auipc	ra,0xffffc
    8000623c:	a1e080e7          	jalr	-1506(ra) # 80001c56 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006240:	00d5151b          	slliw	a0,a0,0xd
    80006244:	0c2017b7          	lui	a5,0xc201
    80006248:	97aa                	add	a5,a5,a0
    8000624a:	c3c4                	sw	s1,4(a5)
}
    8000624c:	60e2                	ld	ra,24(sp)
    8000624e:	6442                	ld	s0,16(sp)
    80006250:	64a2                	ld	s1,8(sp)
    80006252:	6105                	addi	sp,sp,32
    80006254:	8082                	ret

0000000080006256 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006256:	1141                	addi	sp,sp,-16
    80006258:	e406                	sd	ra,8(sp)
    8000625a:	e022                	sd	s0,0(sp)
    8000625c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000625e:	479d                	li	a5,7
    80006260:	04a7cc63          	blt	a5,a0,800062b8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006264:	0001c797          	auipc	a5,0x1c
    80006268:	d3478793          	addi	a5,a5,-716 # 80021f98 <disk>
    8000626c:	97aa                	add	a5,a5,a0
    8000626e:	0187c783          	lbu	a5,24(a5)
    80006272:	ebb9                	bnez	a5,800062c8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006274:	00451693          	slli	a3,a0,0x4
    80006278:	0001c797          	auipc	a5,0x1c
    8000627c:	d2078793          	addi	a5,a5,-736 # 80021f98 <disk>
    80006280:	6398                	ld	a4,0(a5)
    80006282:	9736                	add	a4,a4,a3
    80006284:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006288:	6398                	ld	a4,0(a5)
    8000628a:	9736                	add	a4,a4,a3
    8000628c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006290:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006294:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006298:	97aa                	add	a5,a5,a0
    8000629a:	4705                	li	a4,1
    8000629c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800062a0:	0001c517          	auipc	a0,0x1c
    800062a4:	d1050513          	addi	a0,a0,-752 # 80021fb0 <disk+0x18>
    800062a8:	ffffc097          	auipc	ra,0xffffc
    800062ac:	1f4080e7          	jalr	500(ra) # 8000249c <wakeup>
}
    800062b0:	60a2                	ld	ra,8(sp)
    800062b2:	6402                	ld	s0,0(sp)
    800062b4:	0141                	addi	sp,sp,16
    800062b6:	8082                	ret
    panic("free_desc 1");
    800062b8:	00002517          	auipc	a0,0x2
    800062bc:	59050513          	addi	a0,a0,1424 # 80008848 <syscalls+0x310>
    800062c0:	ffffa097          	auipc	ra,0xffffa
    800062c4:	280080e7          	jalr	640(ra) # 80000540 <panic>
    panic("free_desc 2");
    800062c8:	00002517          	auipc	a0,0x2
    800062cc:	59050513          	addi	a0,a0,1424 # 80008858 <syscalls+0x320>
    800062d0:	ffffa097          	auipc	ra,0xffffa
    800062d4:	270080e7          	jalr	624(ra) # 80000540 <panic>

00000000800062d8 <virtio_disk_init>:
{
    800062d8:	1101                	addi	sp,sp,-32
    800062da:	ec06                	sd	ra,24(sp)
    800062dc:	e822                	sd	s0,16(sp)
    800062de:	e426                	sd	s1,8(sp)
    800062e0:	e04a                	sd	s2,0(sp)
    800062e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062e4:	00002597          	auipc	a1,0x2
    800062e8:	58458593          	addi	a1,a1,1412 # 80008868 <syscalls+0x330>
    800062ec:	0001c517          	auipc	a0,0x1c
    800062f0:	dd450513          	addi	a0,a0,-556 # 800220c0 <disk+0x128>
    800062f4:	ffffb097          	auipc	ra,0xffffb
    800062f8:	852080e7          	jalr	-1966(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062fc:	100017b7          	lui	a5,0x10001
    80006300:	4398                	lw	a4,0(a5)
    80006302:	2701                	sext.w	a4,a4
    80006304:	747277b7          	lui	a5,0x74727
    80006308:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000630c:	14f71b63          	bne	a4,a5,80006462 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006310:	100017b7          	lui	a5,0x10001
    80006314:	43dc                	lw	a5,4(a5)
    80006316:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006318:	4709                	li	a4,2
    8000631a:	14e79463          	bne	a5,a4,80006462 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000631e:	100017b7          	lui	a5,0x10001
    80006322:	479c                	lw	a5,8(a5)
    80006324:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006326:	12e79e63          	bne	a5,a4,80006462 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000632a:	100017b7          	lui	a5,0x10001
    8000632e:	47d8                	lw	a4,12(a5)
    80006330:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006332:	554d47b7          	lui	a5,0x554d4
    80006336:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000633a:	12f71463          	bne	a4,a5,80006462 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000633e:	100017b7          	lui	a5,0x10001
    80006342:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006346:	4705                	li	a4,1
    80006348:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000634a:	470d                	li	a4,3
    8000634c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000634e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006350:	c7ffe6b7          	lui	a3,0xc7ffe
    80006354:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc687>
    80006358:	8f75                	and	a4,a4,a3
    8000635a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000635c:	472d                	li	a4,11
    8000635e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006360:	5bbc                	lw	a5,112(a5)
    80006362:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006366:	8ba1                	andi	a5,a5,8
    80006368:	10078563          	beqz	a5,80006472 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000636c:	100017b7          	lui	a5,0x10001
    80006370:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006374:	43fc                	lw	a5,68(a5)
    80006376:	2781                	sext.w	a5,a5
    80006378:	10079563          	bnez	a5,80006482 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000637c:	100017b7          	lui	a5,0x10001
    80006380:	5bdc                	lw	a5,52(a5)
    80006382:	2781                	sext.w	a5,a5
  if(max == 0)
    80006384:	10078763          	beqz	a5,80006492 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006388:	471d                	li	a4,7
    8000638a:	10f77c63          	bgeu	a4,a5,800064a2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000638e:	ffffa097          	auipc	ra,0xffffa
    80006392:	758080e7          	jalr	1880(ra) # 80000ae6 <kalloc>
    80006396:	0001c497          	auipc	s1,0x1c
    8000639a:	c0248493          	addi	s1,s1,-1022 # 80021f98 <disk>
    8000639e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800063a0:	ffffa097          	auipc	ra,0xffffa
    800063a4:	746080e7          	jalr	1862(ra) # 80000ae6 <kalloc>
    800063a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	73c080e7          	jalr	1852(ra) # 80000ae6 <kalloc>
    800063b2:	87aa                	mv	a5,a0
    800063b4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800063b6:	6088                	ld	a0,0(s1)
    800063b8:	cd6d                	beqz	a0,800064b2 <virtio_disk_init+0x1da>
    800063ba:	0001c717          	auipc	a4,0x1c
    800063be:	be673703          	ld	a4,-1050(a4) # 80021fa0 <disk+0x8>
    800063c2:	cb65                	beqz	a4,800064b2 <virtio_disk_init+0x1da>
    800063c4:	c7fd                	beqz	a5,800064b2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800063c6:	6605                	lui	a2,0x1
    800063c8:	4581                	li	a1,0
    800063ca:	ffffb097          	auipc	ra,0xffffb
    800063ce:	908080e7          	jalr	-1784(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063d2:	0001c497          	auipc	s1,0x1c
    800063d6:	bc648493          	addi	s1,s1,-1082 # 80021f98 <disk>
    800063da:	6605                	lui	a2,0x1
    800063dc:	4581                	li	a1,0
    800063de:	6488                	ld	a0,8(s1)
    800063e0:	ffffb097          	auipc	ra,0xffffb
    800063e4:	8f2080e7          	jalr	-1806(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800063e8:	6605                	lui	a2,0x1
    800063ea:	4581                	li	a1,0
    800063ec:	6888                	ld	a0,16(s1)
    800063ee:	ffffb097          	auipc	ra,0xffffb
    800063f2:	8e4080e7          	jalr	-1820(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063f6:	100017b7          	lui	a5,0x10001
    800063fa:	4721                	li	a4,8
    800063fc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063fe:	4098                	lw	a4,0(s1)
    80006400:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006404:	40d8                	lw	a4,4(s1)
    80006406:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000640a:	6498                	ld	a4,8(s1)
    8000640c:	0007069b          	sext.w	a3,a4
    80006410:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006414:	9701                	srai	a4,a4,0x20
    80006416:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000641a:	6898                	ld	a4,16(s1)
    8000641c:	0007069b          	sext.w	a3,a4
    80006420:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006424:	9701                	srai	a4,a4,0x20
    80006426:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000642a:	4705                	li	a4,1
    8000642c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000642e:	00e48c23          	sb	a4,24(s1)
    80006432:	00e48ca3          	sb	a4,25(s1)
    80006436:	00e48d23          	sb	a4,26(s1)
    8000643a:	00e48da3          	sb	a4,27(s1)
    8000643e:	00e48e23          	sb	a4,28(s1)
    80006442:	00e48ea3          	sb	a4,29(s1)
    80006446:	00e48f23          	sb	a4,30(s1)
    8000644a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000644e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006452:	0727a823          	sw	s2,112(a5)
}
    80006456:	60e2                	ld	ra,24(sp)
    80006458:	6442                	ld	s0,16(sp)
    8000645a:	64a2                	ld	s1,8(sp)
    8000645c:	6902                	ld	s2,0(sp)
    8000645e:	6105                	addi	sp,sp,32
    80006460:	8082                	ret
    panic("could not find virtio disk");
    80006462:	00002517          	auipc	a0,0x2
    80006466:	41650513          	addi	a0,a0,1046 # 80008878 <syscalls+0x340>
    8000646a:	ffffa097          	auipc	ra,0xffffa
    8000646e:	0d6080e7          	jalr	214(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006472:	00002517          	auipc	a0,0x2
    80006476:	42650513          	addi	a0,a0,1062 # 80008898 <syscalls+0x360>
    8000647a:	ffffa097          	auipc	ra,0xffffa
    8000647e:	0c6080e7          	jalr	198(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006482:	00002517          	auipc	a0,0x2
    80006486:	43650513          	addi	a0,a0,1078 # 800088b8 <syscalls+0x380>
    8000648a:	ffffa097          	auipc	ra,0xffffa
    8000648e:	0b6080e7          	jalr	182(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006492:	00002517          	auipc	a0,0x2
    80006496:	44650513          	addi	a0,a0,1094 # 800088d8 <syscalls+0x3a0>
    8000649a:	ffffa097          	auipc	ra,0xffffa
    8000649e:	0a6080e7          	jalr	166(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800064a2:	00002517          	auipc	a0,0x2
    800064a6:	45650513          	addi	a0,a0,1110 # 800088f8 <syscalls+0x3c0>
    800064aa:	ffffa097          	auipc	ra,0xffffa
    800064ae:	096080e7          	jalr	150(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800064b2:	00002517          	auipc	a0,0x2
    800064b6:	46650513          	addi	a0,a0,1126 # 80008918 <syscalls+0x3e0>
    800064ba:	ffffa097          	auipc	ra,0xffffa
    800064be:	086080e7          	jalr	134(ra) # 80000540 <panic>

00000000800064c2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064c2:	7119                	addi	sp,sp,-128
    800064c4:	fc86                	sd	ra,120(sp)
    800064c6:	f8a2                	sd	s0,112(sp)
    800064c8:	f4a6                	sd	s1,104(sp)
    800064ca:	f0ca                	sd	s2,96(sp)
    800064cc:	ecce                	sd	s3,88(sp)
    800064ce:	e8d2                	sd	s4,80(sp)
    800064d0:	e4d6                	sd	s5,72(sp)
    800064d2:	e0da                	sd	s6,64(sp)
    800064d4:	fc5e                	sd	s7,56(sp)
    800064d6:	f862                	sd	s8,48(sp)
    800064d8:	f466                	sd	s9,40(sp)
    800064da:	f06a                	sd	s10,32(sp)
    800064dc:	ec6e                	sd	s11,24(sp)
    800064de:	0100                	addi	s0,sp,128
    800064e0:	8aaa                	mv	s5,a0
    800064e2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064e4:	00c52d03          	lw	s10,12(a0)
    800064e8:	001d1d1b          	slliw	s10,s10,0x1
    800064ec:	1d02                	slli	s10,s10,0x20
    800064ee:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800064f2:	0001c517          	auipc	a0,0x1c
    800064f6:	bce50513          	addi	a0,a0,-1074 # 800220c0 <disk+0x128>
    800064fa:	ffffa097          	auipc	ra,0xffffa
    800064fe:	6dc080e7          	jalr	1756(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006502:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006504:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006506:	0001cb97          	auipc	s7,0x1c
    8000650a:	a92b8b93          	addi	s7,s7,-1390 # 80021f98 <disk>
  for(int i = 0; i < 3; i++){
    8000650e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006510:	0001cc97          	auipc	s9,0x1c
    80006514:	bb0c8c93          	addi	s9,s9,-1104 # 800220c0 <disk+0x128>
    80006518:	a08d                	j	8000657a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000651a:	00fb8733          	add	a4,s7,a5
    8000651e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006522:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006524:	0207c563          	bltz	a5,8000654e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006528:	2905                	addiw	s2,s2,1
    8000652a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000652c:	05690c63          	beq	s2,s6,80006584 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006530:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006532:	0001c717          	auipc	a4,0x1c
    80006536:	a6670713          	addi	a4,a4,-1434 # 80021f98 <disk>
    8000653a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000653c:	01874683          	lbu	a3,24(a4)
    80006540:	fee9                	bnez	a3,8000651a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006542:	2785                	addiw	a5,a5,1
    80006544:	0705                	addi	a4,a4,1
    80006546:	fe979be3          	bne	a5,s1,8000653c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000654a:	57fd                	li	a5,-1
    8000654c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000654e:	01205d63          	blez	s2,80006568 <virtio_disk_rw+0xa6>
    80006552:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006554:	000a2503          	lw	a0,0(s4)
    80006558:	00000097          	auipc	ra,0x0
    8000655c:	cfe080e7          	jalr	-770(ra) # 80006256 <free_desc>
      for(int j = 0; j < i; j++)
    80006560:	2d85                	addiw	s11,s11,1
    80006562:	0a11                	addi	s4,s4,4
    80006564:	ff2d98e3          	bne	s11,s2,80006554 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006568:	85e6                	mv	a1,s9
    8000656a:	0001c517          	auipc	a0,0x1c
    8000656e:	a4650513          	addi	a0,a0,-1466 # 80021fb0 <disk+0x18>
    80006572:	ffffc097          	auipc	ra,0xffffc
    80006576:	ec6080e7          	jalr	-314(ra) # 80002438 <sleep>
  for(int i = 0; i < 3; i++){
    8000657a:	f8040a13          	addi	s4,s0,-128
{
    8000657e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006580:	894e                	mv	s2,s3
    80006582:	b77d                	j	80006530 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006584:	f8042503          	lw	a0,-128(s0)
    80006588:	00a50713          	addi	a4,a0,10
    8000658c:	0712                	slli	a4,a4,0x4

  if(write)
    8000658e:	0001c797          	auipc	a5,0x1c
    80006592:	a0a78793          	addi	a5,a5,-1526 # 80021f98 <disk>
    80006596:	00e786b3          	add	a3,a5,a4
    8000659a:	01803633          	snez	a2,s8
    8000659e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800065a0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800065a4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065a8:	f6070613          	addi	a2,a4,-160
    800065ac:	6394                	ld	a3,0(a5)
    800065ae:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065b0:	00870593          	addi	a1,a4,8
    800065b4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800065b6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800065b8:	0007b803          	ld	a6,0(a5)
    800065bc:	9642                	add	a2,a2,a6
    800065be:	46c1                	li	a3,16
    800065c0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065c2:	4585                	li	a1,1
    800065c4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800065c8:	f8442683          	lw	a3,-124(s0)
    800065cc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065d0:	0692                	slli	a3,a3,0x4
    800065d2:	9836                	add	a6,a6,a3
    800065d4:	058a8613          	addi	a2,s5,88
    800065d8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800065dc:	0007b803          	ld	a6,0(a5)
    800065e0:	96c2                	add	a3,a3,a6
    800065e2:	40000613          	li	a2,1024
    800065e6:	c690                	sw	a2,8(a3)
  if(write)
    800065e8:	001c3613          	seqz	a2,s8
    800065ec:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065f0:	00166613          	ori	a2,a2,1
    800065f4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800065f8:	f8842603          	lw	a2,-120(s0)
    800065fc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006600:	00250693          	addi	a3,a0,2
    80006604:	0692                	slli	a3,a3,0x4
    80006606:	96be                	add	a3,a3,a5
    80006608:	58fd                	li	a7,-1
    8000660a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000660e:	0612                	slli	a2,a2,0x4
    80006610:	9832                	add	a6,a6,a2
    80006612:	f9070713          	addi	a4,a4,-112
    80006616:	973e                	add	a4,a4,a5
    80006618:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000661c:	6398                	ld	a4,0(a5)
    8000661e:	9732                	add	a4,a4,a2
    80006620:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006622:	4609                	li	a2,2
    80006624:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006628:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000662c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006630:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006634:	6794                	ld	a3,8(a5)
    80006636:	0026d703          	lhu	a4,2(a3)
    8000663a:	8b1d                	andi	a4,a4,7
    8000663c:	0706                	slli	a4,a4,0x1
    8000663e:	96ba                	add	a3,a3,a4
    80006640:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006644:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006648:	6798                	ld	a4,8(a5)
    8000664a:	00275783          	lhu	a5,2(a4)
    8000664e:	2785                	addiw	a5,a5,1
    80006650:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006654:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006658:	100017b7          	lui	a5,0x10001
    8000665c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006660:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006664:	0001c917          	auipc	s2,0x1c
    80006668:	a5c90913          	addi	s2,s2,-1444 # 800220c0 <disk+0x128>
  while(b->disk == 1) {
    8000666c:	4485                	li	s1,1
    8000666e:	00b79c63          	bne	a5,a1,80006686 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006672:	85ca                	mv	a1,s2
    80006674:	8556                	mv	a0,s5
    80006676:	ffffc097          	auipc	ra,0xffffc
    8000667a:	dc2080e7          	jalr	-574(ra) # 80002438 <sleep>
  while(b->disk == 1) {
    8000667e:	004aa783          	lw	a5,4(s5)
    80006682:	fe9788e3          	beq	a5,s1,80006672 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006686:	f8042903          	lw	s2,-128(s0)
    8000668a:	00290713          	addi	a4,s2,2
    8000668e:	0712                	slli	a4,a4,0x4
    80006690:	0001c797          	auipc	a5,0x1c
    80006694:	90878793          	addi	a5,a5,-1784 # 80021f98 <disk>
    80006698:	97ba                	add	a5,a5,a4
    8000669a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000669e:	0001c997          	auipc	s3,0x1c
    800066a2:	8fa98993          	addi	s3,s3,-1798 # 80021f98 <disk>
    800066a6:	00491713          	slli	a4,s2,0x4
    800066aa:	0009b783          	ld	a5,0(s3)
    800066ae:	97ba                	add	a5,a5,a4
    800066b0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066b4:	854a                	mv	a0,s2
    800066b6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066ba:	00000097          	auipc	ra,0x0
    800066be:	b9c080e7          	jalr	-1124(ra) # 80006256 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066c2:	8885                	andi	s1,s1,1
    800066c4:	f0ed                	bnez	s1,800066a6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066c6:	0001c517          	auipc	a0,0x1c
    800066ca:	9fa50513          	addi	a0,a0,-1542 # 800220c0 <disk+0x128>
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	5bc080e7          	jalr	1468(ra) # 80000c8a <release>
}
    800066d6:	70e6                	ld	ra,120(sp)
    800066d8:	7446                	ld	s0,112(sp)
    800066da:	74a6                	ld	s1,104(sp)
    800066dc:	7906                	ld	s2,96(sp)
    800066de:	69e6                	ld	s3,88(sp)
    800066e0:	6a46                	ld	s4,80(sp)
    800066e2:	6aa6                	ld	s5,72(sp)
    800066e4:	6b06                	ld	s6,64(sp)
    800066e6:	7be2                	ld	s7,56(sp)
    800066e8:	7c42                	ld	s8,48(sp)
    800066ea:	7ca2                	ld	s9,40(sp)
    800066ec:	7d02                	ld	s10,32(sp)
    800066ee:	6de2                	ld	s11,24(sp)
    800066f0:	6109                	addi	sp,sp,128
    800066f2:	8082                	ret

00000000800066f4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066f4:	1101                	addi	sp,sp,-32
    800066f6:	ec06                	sd	ra,24(sp)
    800066f8:	e822                	sd	s0,16(sp)
    800066fa:	e426                	sd	s1,8(sp)
    800066fc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066fe:	0001c497          	auipc	s1,0x1c
    80006702:	89a48493          	addi	s1,s1,-1894 # 80021f98 <disk>
    80006706:	0001c517          	auipc	a0,0x1c
    8000670a:	9ba50513          	addi	a0,a0,-1606 # 800220c0 <disk+0x128>
    8000670e:	ffffa097          	auipc	ra,0xffffa
    80006712:	4c8080e7          	jalr	1224(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006716:	10001737          	lui	a4,0x10001
    8000671a:	533c                	lw	a5,96(a4)
    8000671c:	8b8d                	andi	a5,a5,3
    8000671e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006720:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006724:	689c                	ld	a5,16(s1)
    80006726:	0204d703          	lhu	a4,32(s1)
    8000672a:	0027d783          	lhu	a5,2(a5)
    8000672e:	04f70863          	beq	a4,a5,8000677e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006732:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006736:	6898                	ld	a4,16(s1)
    80006738:	0204d783          	lhu	a5,32(s1)
    8000673c:	8b9d                	andi	a5,a5,7
    8000673e:	078e                	slli	a5,a5,0x3
    80006740:	97ba                	add	a5,a5,a4
    80006742:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006744:	00278713          	addi	a4,a5,2
    80006748:	0712                	slli	a4,a4,0x4
    8000674a:	9726                	add	a4,a4,s1
    8000674c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006750:	e721                	bnez	a4,80006798 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006752:	0789                	addi	a5,a5,2
    80006754:	0792                	slli	a5,a5,0x4
    80006756:	97a6                	add	a5,a5,s1
    80006758:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000675a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000675e:	ffffc097          	auipc	ra,0xffffc
    80006762:	d3e080e7          	jalr	-706(ra) # 8000249c <wakeup>

    disk.used_idx += 1;
    80006766:	0204d783          	lhu	a5,32(s1)
    8000676a:	2785                	addiw	a5,a5,1
    8000676c:	17c2                	slli	a5,a5,0x30
    8000676e:	93c1                	srli	a5,a5,0x30
    80006770:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006774:	6898                	ld	a4,16(s1)
    80006776:	00275703          	lhu	a4,2(a4)
    8000677a:	faf71ce3          	bne	a4,a5,80006732 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000677e:	0001c517          	auipc	a0,0x1c
    80006782:	94250513          	addi	a0,a0,-1726 # 800220c0 <disk+0x128>
    80006786:	ffffa097          	auipc	ra,0xffffa
    8000678a:	504080e7          	jalr	1284(ra) # 80000c8a <release>
}
    8000678e:	60e2                	ld	ra,24(sp)
    80006790:	6442                	ld	s0,16(sp)
    80006792:	64a2                	ld	s1,8(sp)
    80006794:	6105                	addi	sp,sp,32
    80006796:	8082                	ret
      panic("virtio_disk_intr status");
    80006798:	00002517          	auipc	a0,0x2
    8000679c:	19850513          	addi	a0,a0,408 # 80008930 <syscalls+0x3f8>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	da0080e7          	jalr	-608(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
