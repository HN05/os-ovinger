
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a2013103          	ld	sp,-1504(sp) # 80008a20 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    asm volatile("csrr %0, mhartid" : "=r"(x));
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
    80000054:	a4070713          	addi	a4,a4,-1472 # 80008a90 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void
w_mscratch(uint64 x)
{
    asm volatile("csrw mscratch, %0" : : "r"(x));
    8000005e:	34071073          	csrw	mscratch,a4
    asm volatile("csrw mtvec, %0" : : "r"(x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	3ae78793          	addi	a5,a5,942 # 80006410 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    asm volatile("csrr %0, mstatus" : "=r"(x));
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r"(x));
    80000076:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r"(x));
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
    asm volatile("csrw mie, %0" : : "r"(x));
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
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbc8e7>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	08c78793          	addi	a5,a5,140 # 80001138 <main>
    800000b4:	34179073          	csrw	mepc,a5
    asm volatile("csrw satp, %0" : : "r"(x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg, %0" : : "r"(x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg, %0" : : "r"(x));
    800000c6:	30379073          	csrw	mideleg,a5
    asm volatile("csrr %0, sie" : "=r"(x));
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
    asm volatile("csrw sie, %0" : : "r"(x));
    800000d2:	10479073          	csrw	sie,a5
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
    asm volatile("csrr %0, mhartid" : "=r"(x));
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
    asm volatile("mv tp, %0" : : "r"(x));
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
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	8a4080e7          	jalr	-1884(ra) # 800029ce <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	796080e7          	jalr	1942(ra) # 800008d0 <uartputc>
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
    8000018e:	a4650513          	addi	a0,a0,-1466 # 80010bd0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	d04080e7          	jalr	-764(ra) # 80000e96 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a3648493          	addi	s1,s1,-1482 # 80010bd0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	ac690913          	addi	s2,s2,-1338 # 80010c68 <cons+0x98>
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
    800001c4:	c02080e7          	jalr	-1022(ra) # 80001dc2 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	650080e7          	jalr	1616(ra) # 80002818 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	39a080e7          	jalr	922(ra) # 80002570 <sleep>
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
    80000216:	766080e7          	jalr	1894(ra) # 80002978 <either_copyout>
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
    8000022a:	9aa50513          	addi	a0,a0,-1622 # 80010bd0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	d1c080e7          	jalr	-740(ra) # 80000f4a <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	99450513          	addi	a0,a0,-1644 # 80010bd0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	d06080e7          	jalr	-762(ra) # 80000f4a <release>
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
    80000276:	9ef72b23          	sw	a5,-1546(a4) # 80010c68 <cons+0x98>
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
    80000290:	572080e7          	jalr	1394(ra) # 800007fe <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	560080e7          	jalr	1376(ra) # 800007fe <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	554080e7          	jalr	1364(ra) # 800007fe <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	54a080e7          	jalr	1354(ra) # 800007fe <uartputc_sync>
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
    800002d0:	90450513          	addi	a0,a0,-1788 # 80010bd0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	bc2080e7          	jalr	-1086(ra) # 80000e96 <acquire>

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
    800002f6:	732080e7          	jalr	1842(ra) # 80002a24 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	8d650513          	addi	a0,a0,-1834 # 80010bd0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	c48080e7          	jalr	-952(ra) # 80000f4a <release>
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
    80000322:	8b270713          	addi	a4,a4,-1870 # 80010bd0 <cons>
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
    8000034c:	88878793          	addi	a5,a5,-1912 # 80010bd0 <cons>
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
    8000037a:	8f27a783          	lw	a5,-1806(a5) # 80010c68 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	84670713          	addi	a4,a4,-1978 # 80010bd0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	83648493          	addi	s1,s1,-1994 # 80010bd0 <cons>
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
    800003da:	7fa70713          	addi	a4,a4,2042 # 80010bd0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	88f72223          	sw	a5,-1916(a4) # 80010c70 <cons+0xa0>
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
    80000416:	7be78793          	addi	a5,a5,1982 # 80010bd0 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	82c7ab23          	sw	a2,-1994(a5) # 80010c6c <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	82a50513          	addi	a0,a0,-2006 # 80010c68 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	18e080e7          	jalr	398(ra) # 800025d4 <wakeup>
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
    8000045c:	bc858593          	addi	a1,a1,-1080 # 80008020 <__func__.1+0x18>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	77050513          	addi	a0,a0,1904 # 80010bd0 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	99e080e7          	jalr	-1634(ra) # 80000e06 <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	33e080e7          	jalr	830(ra) # 800007ae <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00041797          	auipc	a5,0x41
    8000047c:	90878793          	addi	a5,a5,-1784 # 80040d80 <devsw>
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

    if (sign && (sign = xx < 0))
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
    do
    {
        buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b9660613          	addi	a2,a2,-1130 # 80008050 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

    if (sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
        buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
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
    while (--i >= 0)
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
    if (sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
        x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000540:	711d                	addi	sp,sp,-96
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
    8000054c:	e40c                	sd	a1,8(s0)
    8000054e:	e810                	sd	a2,16(s0)
    80000550:	ec14                	sd	a3,24(s0)
    80000552:	f018                	sd	a4,32(s0)
    80000554:	f41c                	sd	a5,40(s0)
    80000556:	03043823          	sd	a6,48(s0)
    8000055a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000055e:	00010797          	auipc	a5,0x10
    80000562:	7207a923          	sw	zero,1842(a5) # 80010c90 <pr+0x18>
    printf("panic: ");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	ac250513          	addi	a0,a0,-1342 # 80008028 <__func__.1+0x20>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	02e080e7          	jalr	46(ra) # 8000059c <printf>
    printf(s);
    80000576:	8526                	mv	a0,s1
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	024080e7          	jalr	36(ra) # 8000059c <printf>
    printf("\n");
    80000580:	00008517          	auipc	a0,0x8
    80000584:	b1850513          	addi	a0,a0,-1256 # 80008098 <digits+0x48>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	014080e7          	jalr	20(ra) # 8000059c <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000590:	4785                	li	a5,1
    80000592:	00008717          	auipc	a4,0x8
    80000596:	4af72723          	sw	a5,1198(a4) # 80008a40 <panicked>
    for (;;)
    8000059a:	a001                	j	8000059a <panic+0x5a>

000000008000059c <printf>:
{
    8000059c:	7131                	addi	sp,sp,-192
    8000059e:	fc86                	sd	ra,120(sp)
    800005a0:	f8a2                	sd	s0,112(sp)
    800005a2:	f4a6                	sd	s1,104(sp)
    800005a4:	f0ca                	sd	s2,96(sp)
    800005a6:	ecce                	sd	s3,88(sp)
    800005a8:	e8d2                	sd	s4,80(sp)
    800005aa:	e4d6                	sd	s5,72(sp)
    800005ac:	e0da                	sd	s6,64(sp)
    800005ae:	fc5e                	sd	s7,56(sp)
    800005b0:	f862                	sd	s8,48(sp)
    800005b2:	f466                	sd	s9,40(sp)
    800005b4:	f06a                	sd	s10,32(sp)
    800005b6:	ec6e                	sd	s11,24(sp)
    800005b8:	0100                	addi	s0,sp,128
    800005ba:	8a2a                	mv	s4,a0
    800005bc:	e40c                	sd	a1,8(s0)
    800005be:	e810                	sd	a2,16(s0)
    800005c0:	ec14                	sd	a3,24(s0)
    800005c2:	f018                	sd	a4,32(s0)
    800005c4:	f41c                	sd	a5,40(s0)
    800005c6:	03043823          	sd	a6,48(s0)
    800005ca:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005ce:	00010d97          	auipc	s11,0x10
    800005d2:	6c2dad83          	lw	s11,1730(s11) # 80010c90 <pr+0x18>
    if (locking)
    800005d6:	020d9b63          	bnez	s11,8000060c <printf+0x70>
    if (fmt == 0)
    800005da:	040a0263          	beqz	s4,8000061e <printf+0x82>
    va_start(ap, fmt);
    800005de:	00840793          	addi	a5,s0,8
    800005e2:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005e6:	000a4503          	lbu	a0,0(s4)
    800005ea:	14050f63          	beqz	a0,80000748 <printf+0x1ac>
    800005ee:	4981                	li	s3,0
        if (c != '%')
    800005f0:	02500a93          	li	s5,37
        switch (c)
    800005f4:	07000b93          	li	s7,112
    consputc('x');
    800005f8:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005fa:	00008b17          	auipc	s6,0x8
    800005fe:	a56b0b13          	addi	s6,s6,-1450 # 80008050 <digits>
        switch (c)
    80000602:	07300c93          	li	s9,115
    80000606:	06400c13          	li	s8,100
    8000060a:	a82d                	j	80000644 <printf+0xa8>
        acquire(&pr.lock);
    8000060c:	00010517          	auipc	a0,0x10
    80000610:	66c50513          	addi	a0,a0,1644 # 80010c78 <pr>
    80000614:	00001097          	auipc	ra,0x1
    80000618:	882080e7          	jalr	-1918(ra) # 80000e96 <acquire>
    8000061c:	bf7d                	j	800005da <printf+0x3e>
        panic("null fmt");
    8000061e:	00008517          	auipc	a0,0x8
    80000622:	a1a50513          	addi	a0,a0,-1510 # 80008038 <__func__.1+0x30>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	f1a080e7          	jalr	-230(ra) # 80000540 <panic>
            consputc(c);
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	c4e080e7          	jalr	-946(ra) # 8000027c <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c503          	lbu	a0,0(a5)
    80000640:	10050463          	beqz	a0,80000748 <printf+0x1ac>
        if (c != '%')
    80000644:	ff5515e3          	bne	a0,s5,8000062e <printf+0x92>
        c = fmt[++i] & 0xff;
    80000648:	2985                	addiw	s3,s3,1
    8000064a:	013a07b3          	add	a5,s4,s3
    8000064e:	0007c783          	lbu	a5,0(a5)
    80000652:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000656:	cbed                	beqz	a5,80000748 <printf+0x1ac>
        switch (c)
    80000658:	05778a63          	beq	a5,s7,800006ac <printf+0x110>
    8000065c:	02fbf663          	bgeu	s7,a5,80000688 <printf+0xec>
    80000660:	09978863          	beq	a5,s9,800006f0 <printf+0x154>
    80000664:	07800713          	li	a4,120
    80000668:	0ce79563          	bne	a5,a4,80000732 <printf+0x196>
            printint(va_arg(ap, int), 16, 1);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	4605                	li	a2,1
    8000067a:	85ea                	mv	a1,s10
    8000067c:	4388                	lw	a0,0(a5)
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	e1e080e7          	jalr	-482(ra) # 8000049c <printint>
            break;
    80000686:	bf45                	j	80000636 <printf+0x9a>
        switch (c)
    80000688:	09578f63          	beq	a5,s5,80000726 <printf+0x18a>
    8000068c:	0b879363          	bne	a5,s8,80000732 <printf+0x196>
            printint(va_arg(ap, int), 10, 1);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4605                	li	a2,1
    8000069e:	45a9                	li	a1,10
    800006a0:	4388                	lw	a0,0(a5)
    800006a2:	00000097          	auipc	ra,0x0
    800006a6:	dfa080e7          	jalr	-518(ra) # 8000049c <printint>
            break;
    800006aa:	b771                	j	80000636 <printf+0x9a>
            printptr(va_arg(ap, uint64));
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006bc:	03000513          	li	a0,48
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bbc080e7          	jalr	-1092(ra) # 8000027c <consputc>
    consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
    800006d4:	84ea                	mv	s1,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d6:	03c95793          	srli	a5,s2,0x3c
    800006da:	97da                	add	a5,a5,s6
    800006dc:	0007c503          	lbu	a0,0(a5)
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	b9c080e7          	jalr	-1124(ra) # 8000027c <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0912                	slli	s2,s2,0x4
    800006ea:	34fd                	addiw	s1,s1,-1
    800006ec:	f4ed                	bnez	s1,800006d6 <printf+0x13a>
    800006ee:	b7a1                	j	80000636 <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	6384                	ld	s1,0(a5)
    800006fe:	cc89                	beqz	s1,80000718 <printf+0x17c>
            for (; *s; s++)
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	d90d                	beqz	a0,80000636 <printf+0x9a>
                consputc(*s);
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	b76080e7          	jalr	-1162(ra) # 8000027c <consputc>
            for (; *s; s++)
    8000070e:	0485                	addi	s1,s1,1
    80000710:	0004c503          	lbu	a0,0(s1)
    80000714:	f96d                	bnez	a0,80000706 <printf+0x16a>
    80000716:	b705                	j	80000636 <printf+0x9a>
                s = "(null)";
    80000718:	00008497          	auipc	s1,0x8
    8000071c:	91848493          	addi	s1,s1,-1768 # 80008030 <__func__.1+0x28>
            for (; *s; s++)
    80000720:	02800513          	li	a0,40
    80000724:	b7cd                	j	80000706 <printf+0x16a>
            consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b54080e7          	jalr	-1196(ra) # 8000027c <consputc>
            break;
    80000730:	b719                	j	80000636 <printf+0x9a>
            consputc('%');
    80000732:	8556                	mv	a0,s5
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b48080e7          	jalr	-1208(ra) # 8000027c <consputc>
            consputc(c);
    8000073c:	8526                	mv	a0,s1
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	b3e080e7          	jalr	-1218(ra) # 8000027c <consputc>
            break;
    80000746:	bdc5                	j	80000636 <printf+0x9a>
    if (locking)
    80000748:	020d9163          	bnez	s11,8000076a <printf+0x1ce>
}
    8000074c:	70e6                	ld	ra,120(sp)
    8000074e:	7446                	ld	s0,112(sp)
    80000750:	74a6                	ld	s1,104(sp)
    80000752:	7906                	ld	s2,96(sp)
    80000754:	69e6                	ld	s3,88(sp)
    80000756:	6a46                	ld	s4,80(sp)
    80000758:	6aa6                	ld	s5,72(sp)
    8000075a:	6b06                	ld	s6,64(sp)
    8000075c:	7be2                	ld	s7,56(sp)
    8000075e:	7c42                	ld	s8,48(sp)
    80000760:	7ca2                	ld	s9,40(sp)
    80000762:	7d02                	ld	s10,32(sp)
    80000764:	6de2                	ld	s11,24(sp)
    80000766:	6129                	addi	sp,sp,192
    80000768:	8082                	ret
        release(&pr.lock);
    8000076a:	00010517          	auipc	a0,0x10
    8000076e:	50e50513          	addi	a0,a0,1294 # 80010c78 <pr>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	7d8080e7          	jalr	2008(ra) # 80000f4a <release>
}
    8000077a:	bfc9                	j	8000074c <printf+0x1b0>

000000008000077c <printfinit>:
        ;
}

void printfinit(void)
{
    8000077c:	1101                	addi	sp,sp,-32
    8000077e:	ec06                	sd	ra,24(sp)
    80000780:	e822                	sd	s0,16(sp)
    80000782:	e426                	sd	s1,8(sp)
    80000784:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000786:	00010497          	auipc	s1,0x10
    8000078a:	4f248493          	addi	s1,s1,1266 # 80010c78 <pr>
    8000078e:	00008597          	auipc	a1,0x8
    80000792:	8ba58593          	addi	a1,a1,-1862 # 80008048 <__func__.1+0x40>
    80000796:	8526                	mv	a0,s1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	66e080e7          	jalr	1646(ra) # 80000e06 <initlock>
    pr.locking = 1;
    800007a0:	4785                	li	a5,1
    800007a2:	cc9c                	sw	a5,24(s1)
}
    800007a4:	60e2                	ld	ra,24(sp)
    800007a6:	6442                	ld	s0,16(sp)
    800007a8:	64a2                	ld	s1,8(sp)
    800007aa:	6105                	addi	sp,sp,32
    800007ac:	8082                	ret

00000000800007ae <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ae:	1141                	addi	sp,sp,-16
    800007b0:	e406                	sd	ra,8(sp)
    800007b2:	e022                	sd	s0,0(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d4:	469d                	li	a3,7
    800007d6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007da:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007de:	00008597          	auipc	a1,0x8
    800007e2:	88a58593          	addi	a1,a1,-1910 # 80008068 <digits+0x18>
    800007e6:	00010517          	auipc	a0,0x10
    800007ea:	4b250513          	addi	a0,a0,1202 # 80010c98 <uart_tx_lock>
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	618080e7          	jalr	1560(ra) # 80000e06 <initlock>
}
    800007f6:	60a2                	ld	ra,8(sp)
    800007f8:	6402                	ld	s0,0(sp)
    800007fa:	0141                	addi	sp,sp,16
    800007fc:	8082                	ret

00000000800007fe <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fe:	1101                	addi	sp,sp,-32
    80000800:	ec06                	sd	ra,24(sp)
    80000802:	e822                	sd	s0,16(sp)
    80000804:	e426                	sd	s1,8(sp)
    80000806:	1000                	addi	s0,sp,32
    80000808:	84aa                	mv	s1,a0
  push_off();
    8000080a:	00000097          	auipc	ra,0x0
    8000080e:	640080e7          	jalr	1600(ra) # 80000e4a <push_off>

  if(panicked){
    80000812:	00008797          	auipc	a5,0x8
    80000816:	22e7a783          	lw	a5,558(a5) # 80008a40 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081e:	c391                	beqz	a5,80000822 <uartputc_sync+0x24>
    for(;;)
    80000820:	a001                	j	80000820 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dfe5                	beqz	a5,80000822 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f513          	zext.b	a0,s1
    80000830:	100007b7          	lui	a5,0x10000
    80000834:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	6b2080e7          	jalr	1714(ra) # 80000eea <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	1fe7b783          	ld	a5,510(a5) # 80008a48 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	1fe73703          	ld	a4,510(a4) # 80008a50 <uart_tx_w>
    8000085a:	06f70a63          	beq	a4,a5,800008ce <uartstart+0x84>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000874:	00010a17          	auipc	s4,0x10
    80000878:	424a0a13          	addi	s4,s4,1060 # 80010c98 <uart_tx_lock>
    uart_tx_r += 1;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	1cc48493          	addi	s1,s1,460 # 80008a48 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	1cc98993          	addi	s3,s3,460 # 80008a50 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	02077713          	andi	a4,a4,32
    80000894:	c705                	beqz	a4,800008bc <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f7f713          	andi	a4,a5,31
    8000089a:	9752                	add	a4,a4,s4
    8000089c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a0:	0785                	addi	a5,a5,1
    800008a2:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	d2e080e7          	jalr	-722(ra) # 800025d4 <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ae3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	3b650513          	addi	a0,a0,950 # 80010c98 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	5ac080e7          	jalr	1452(ra) # 80000e96 <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	14e7a783          	lw	a5,334(a5) # 80008a40 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008717          	auipc	a4,0x8
    80000900:	15473703          	ld	a4,340(a4) # 80008a50 <uart_tx_w>
    80000904:	00008797          	auipc	a5,0x8
    80000908:	1447b783          	ld	a5,324(a5) # 80008a48 <uart_tx_r>
    8000090c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	38898993          	addi	s3,s3,904 # 80010c98 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	13048493          	addi	s1,s1,304 # 80008a48 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	13090913          	addi	s2,s2,304 # 80008a50 <uart_tx_w>
    80000928:	00e79f63          	bne	a5,a4,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85ce                	mv	a1,s3
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	c40080e7          	jalr	-960(ra) # 80002570 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093703          	ld	a4,0(s2)
    8000093c:	609c                	ld	a5,0(s1)
    8000093e:	02078793          	addi	a5,a5,32
    80000942:	fee785e3          	beq	a5,a4,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	35248493          	addi	s1,s1,850 # 80010c98 <uart_tx_lock>
    8000094e:	01f77793          	andi	a5,a4,31
    80000952:	97a6                	add	a5,a5,s1
    80000954:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000958:	0705                	addi	a4,a4,1
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	0ee7bb23          	sd	a4,246(a5) # 80008a50 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee8080e7          	jalr	-280(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	5de080e7          	jalr	1502(ra) # 80000f4a <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb81                	beqz	a5,800009a6 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a0:	6422                	ld	s0,8(sp)
    800009a2:	0141                	addi	sp,sp,16
    800009a4:	8082                	ret
    return -1;
    800009a6:	557d                	li	a0,-1
    800009a8:	bfe5                	j	800009a0 <uartgetc+0x1a>

00000000800009aa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009aa:	1101                	addi	sp,sp,-32
    800009ac:	ec06                	sd	ra,24(sp)
    800009ae:	e822                	sd	s0,16(sp)
    800009b0:	e426                	sd	s1,8(sp)
    800009b2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b4:	54fd                	li	s1,-1
    800009b6:	a029                	j	800009c0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	906080e7          	jalr	-1786(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	fc6080e7          	jalr	-58(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c8:	fe9518e3          	bne	a0,s1,800009b8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009cc:	00010497          	auipc	s1,0x10
    800009d0:	2cc48493          	addi	s1,s1,716 # 80010c98 <uart_tx_lock>
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	4c0080e7          	jalr	1216(ra) # 80000e96 <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	562080e7          	jalr	1378(ra) # 80000f4a <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <refindex>:
int refcount[NPAGES];

int
refindex(uint64 pa)
{
    if (pa < KERNBASE || pa >= PHYSTOP)
    800009fa:	800007b7          	lui	a5,0x80000
    800009fe:	953e                	add	a0,a0,a5
    80000a00:	080007b7          	lui	a5,0x8000
    80000a04:	00f57563          	bgeu	a0,a5,80000a0e <refindex+0x14>
        panic("refindex");

    return (pa - KERNBASE) / PGSIZE;
    80000a08:	8131                	srli	a0,a0,0xc
}
    80000a0a:	2501                	sext.w	a0,a0
    80000a0c:	8082                	ret
{
    80000a0e:	1141                	addi	sp,sp,-16
    80000a10:	e406                	sd	ra,8(sp)
    80000a12:	e022                	sd	s0,0(sp)
    80000a14:	0800                	addi	s0,sp,16
        panic("refindex");
    80000a16:	00007517          	auipc	a0,0x7
    80000a1a:	65a50513          	addi	a0,a0,1626 # 80008070 <digits+0x20>
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	b22080e7          	jalr	-1246(ra) # 80000540 <panic>

0000000080000a26 <getrefcount>:

int
getrefcount(uint64 pa)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	e04a                	sd	s2,0(sp)
    80000a30:	1000                	addi	s0,sp,32
    80000a32:	84aa                	mv	s1,a0
    int count;
    acquire(&refcountlock);
    80000a34:	00010917          	auipc	s2,0x10
    80000a38:	29c90913          	addi	s2,s2,668 # 80010cd0 <refcountlock>
    80000a3c:	854a                	mv	a0,s2
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	458080e7          	jalr	1112(ra) # 80000e96 <acquire>
    count = refcount[refindex(pa)];
    80000a46:	8526                	mv	a0,s1
    80000a48:	00000097          	auipc	ra,0x0
    80000a4c:	fb2080e7          	jalr	-78(ra) # 800009fa <refindex>
    80000a50:	050a                	slli	a0,a0,0x2
    80000a52:	00010797          	auipc	a5,0x10
    80000a56:	2b678793          	addi	a5,a5,694 # 80010d08 <refcount>
    80000a5a:	97aa                	add	a5,a5,a0
    80000a5c:	4384                	lw	s1,0(a5)
    release(&refcountlock);
    80000a5e:	854a                	mv	a0,s2
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	4ea080e7          	jalr	1258(ra) # 80000f4a <release>
    return count;
}
    80000a68:	8526                	mv	a0,s1
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret

0000000080000a76 <decrefcount>:

void
decrefcount(uint64 pa)
{
    80000a76:	1101                	addi	sp,sp,-32
    80000a78:	ec06                	sd	ra,24(sp)
    80000a7a:	e822                	sd	s0,16(sp)
    80000a7c:	e426                	sd	s1,8(sp)
    80000a7e:	e04a                	sd	s2,0(sp)
    80000a80:	1000                	addi	s0,sp,32
    80000a82:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000a84:	00010917          	auipc	s2,0x10
    80000a88:	24c90913          	addi	s2,s2,588 # 80010cd0 <refcountlock>
    80000a8c:	854a                	mv	a0,s2
    80000a8e:	00000097          	auipc	ra,0x0
    80000a92:	408080e7          	jalr	1032(ra) # 80000e96 <acquire>
    refcount[refindex(pa)]--;
    80000a96:	8526                	mv	a0,s1
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	f62080e7          	jalr	-158(ra) # 800009fa <refindex>
    80000aa0:	050a                	slli	a0,a0,0x2
    80000aa2:	00010797          	auipc	a5,0x10
    80000aa6:	26678793          	addi	a5,a5,614 # 80010d08 <refcount>
    80000aaa:	97aa                	add	a5,a5,a0
    80000aac:	4398                	lw	a4,0(a5)
    80000aae:	377d                	addiw	a4,a4,-1
    80000ab0:	c398                	sw	a4,0(a5)
    release(&refcountlock);
    80000ab2:	854a                	mv	a0,s2
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	496080e7          	jalr	1174(ra) # 80000f4a <release>
}
    80000abc:	60e2                	ld	ra,24(sp)
    80000abe:	6442                	ld	s0,16(sp)
    80000ac0:	64a2                	ld	s1,8(sp)
    80000ac2:	6902                	ld	s2,0(sp)
    80000ac4:	6105                	addi	sp,sp,32
    80000ac6:	8082                	ret

0000000080000ac8 <increfcount>:

void
increfcount(uint64 pa)
{
    80000ac8:	1101                	addi	sp,sp,-32
    80000aca:	ec06                	sd	ra,24(sp)
    80000acc:	e822                	sd	s0,16(sp)
    80000ace:	e426                	sd	s1,8(sp)
    80000ad0:	e04a                	sd	s2,0(sp)
    80000ad2:	1000                	addi	s0,sp,32
    80000ad4:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000ad6:	00010917          	auipc	s2,0x10
    80000ada:	1fa90913          	addi	s2,s2,506 # 80010cd0 <refcountlock>
    80000ade:	854a                	mv	a0,s2
    80000ae0:	00000097          	auipc	ra,0x0
    80000ae4:	3b6080e7          	jalr	950(ra) # 80000e96 <acquire>
    refcount[refindex(pa)]++;
    80000ae8:	8526                	mv	a0,s1
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f10080e7          	jalr	-240(ra) # 800009fa <refindex>
    80000af2:	050a                	slli	a0,a0,0x2
    80000af4:	00010797          	auipc	a5,0x10
    80000af8:	21478793          	addi	a5,a5,532 # 80010d08 <refcount>
    80000afc:	97aa                	add	a5,a5,a0
    80000afe:	4398                	lw	a4,0(a5)
    80000b00:	2705                	addiw	a4,a4,1
    80000b02:	c398                	sw	a4,0(a5)
    release(&refcountlock);
    80000b04:	854a                	mv	a0,s2
    80000b06:	00000097          	auipc	ra,0x0
    80000b0a:	444080e7          	jalr	1092(ra) # 80000f4a <release>
}
    80000b0e:	60e2                	ld	ra,24(sp)
    80000b10:	6442                	ld	s0,16(sp)
    80000b12:	64a2                	ld	s1,8(sp)
    80000b14:	6902                	ld	s2,0(sp)
    80000b16:	6105                	addi	sp,sp,32
    80000b18:	8082                	ret

0000000080000b1a <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000b1a:	7179                	addi	sp,sp,-48
    80000b1c:	f406                	sd	ra,40(sp)
    80000b1e:	f022                	sd	s0,32(sp)
    80000b20:	ec26                	sd	s1,24(sp)
    80000b22:	e84a                	sd	s2,16(sp)
    80000b24:	e44e                	sd	s3,8(sp)
    80000b26:	1800                	addi	s0,sp,48
    80000b28:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000b2a:	00008797          	auipc	a5,0x8
    80000b2e:	f367b783          	ld	a5,-202(a5) # 80008a60 <MAX_PAGES>
    80000b32:	c799                	beqz	a5,80000b40 <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000b34:	00008717          	auipc	a4,0x8
    80000b38:	f2473703          	ld	a4,-220(a4) # 80008a58 <FREE_PAGES>
    80000b3c:	08f77863          	bgeu	a4,a5,80000bcc <kfree+0xb2>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000b40:	03449793          	slli	a5,s1,0x34
    80000b44:	efd5                	bnez	a5,80000c00 <kfree+0xe6>
    80000b46:	00041797          	auipc	a5,0x41
    80000b4a:	3d278793          	addi	a5,a5,978 # 80041f18 <end>
    80000b4e:	0af4e963          	bltu	s1,a5,80000c00 <kfree+0xe6>
    80000b52:	47c5                	li	a5,17
    80000b54:	07ee                	slli	a5,a5,0x1b
    80000b56:	0af4f563          	bgeu	s1,a5,80000c00 <kfree+0xe6>
        panic("kfree");

    // decrement refcount

    int i = refindex((uint64) pa);
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	e9e080e7          	jalr	-354(ra) # 800009fa <refindex>
    80000b64:	892a                	mv	s2,a0
    int empty;

    acquire(&refcountlock);
    80000b66:	00010517          	auipc	a0,0x10
    80000b6a:	16a50513          	addi	a0,a0,362 # 80010cd0 <refcountlock>
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	328080e7          	jalr	808(ra) # 80000e96 <acquire>
    if (refcount[i] > 0) refcount[i]--;
    80000b76:	00291713          	slli	a4,s2,0x2
    80000b7a:	00010797          	auipc	a5,0x10
    80000b7e:	18e78793          	addi	a5,a5,398 # 80010d08 <refcount>
    80000b82:	97ba                	add	a5,a5,a4
    80000b84:	439c                	lw	a5,0(a5)
    80000b86:	00f05a63          	blez	a5,80000b9a <kfree+0x80>
    80000b8a:	86ba                	mv	a3,a4
    80000b8c:	00010717          	auipc	a4,0x10
    80000b90:	17c70713          	addi	a4,a4,380 # 80010d08 <refcount>
    80000b94:	9736                	add	a4,a4,a3
    80000b96:	37fd                	addiw	a5,a5,-1
    80000b98:	c31c                	sw	a5,0(a4)
    empty = refcount[i] == 0;
    80000b9a:	090a                	slli	s2,s2,0x2
    80000b9c:	00010797          	auipc	a5,0x10
    80000ba0:	16c78793          	addi	a5,a5,364 # 80010d08 <refcount>
    80000ba4:	97ca                	add	a5,a5,s2
    80000ba6:	0007a903          	lw	s2,0(a5)
    release(&refcountlock);
    80000baa:	00010517          	auipc	a0,0x10
    80000bae:	12650513          	addi	a0,a0,294 # 80010cd0 <refcountlock>
    80000bb2:	00000097          	auipc	ra,0x0
    80000bb6:	398080e7          	jalr	920(ra) # 80000f4a <release>

    if (!empty) return;
    80000bba:	04090b63          	beqz	s2,80000c10 <kfree+0xf6>
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}
    80000bbe:	70a2                	ld	ra,40(sp)
    80000bc0:	7402                	ld	s0,32(sp)
    80000bc2:	64e2                	ld	s1,24(sp)
    80000bc4:	6942                	ld	s2,16(sp)
    80000bc6:	69a2                	ld	s3,8(sp)
    80000bc8:	6145                	addi	sp,sp,48
    80000bca:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000bcc:	06100693          	li	a3,97
    80000bd0:	00007617          	auipc	a2,0x7
    80000bd4:	43860613          	addi	a2,a2,1080 # 80008008 <__func__.1>
    80000bd8:	00007597          	auipc	a1,0x7
    80000bdc:	4a858593          	addi	a1,a1,1192 # 80008080 <digits+0x30>
    80000be0:	00007517          	auipc	a0,0x7
    80000be4:	4b050513          	addi	a0,a0,1200 # 80008090 <digits+0x40>
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	9b4080e7          	jalr	-1612(ra) # 8000059c <printf>
    80000bf0:	00007517          	auipc	a0,0x7
    80000bf4:	4b050513          	addi	a0,a0,1200 # 800080a0 <digits+0x50>
    80000bf8:	00000097          	auipc	ra,0x0
    80000bfc:	948080e7          	jalr	-1720(ra) # 80000540 <panic>
        panic("kfree");
    80000c00:	00007517          	auipc	a0,0x7
    80000c04:	4b050513          	addi	a0,a0,1200 # 800080b0 <digits+0x60>
    80000c08:	00000097          	auipc	ra,0x0
    80000c0c:	938080e7          	jalr	-1736(ra) # 80000540 <panic>
    memset(pa, 1, PGSIZE);
    80000c10:	6605                	lui	a2,0x1
    80000c12:	4585                	li	a1,1
    80000c14:	8526                	mv	a0,s1
    80000c16:	00000097          	auipc	ra,0x0
    80000c1a:	37c080e7          	jalr	892(ra) # 80000f92 <memset>
    acquire(&kmem.lock);
    80000c1e:	00010997          	auipc	s3,0x10
    80000c22:	0b298993          	addi	s3,s3,178 # 80010cd0 <refcountlock>
    80000c26:	00010917          	auipc	s2,0x10
    80000c2a:	0c290913          	addi	s2,s2,194 # 80010ce8 <kmem>
    80000c2e:	854a                	mv	a0,s2
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	266080e7          	jalr	614(ra) # 80000e96 <acquire>
    r->next = kmem.freelist;
    80000c38:	0309b783          	ld	a5,48(s3)
    80000c3c:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000c3e:	0299b823          	sd	s1,48(s3)
    FREE_PAGES++;
    80000c42:	00008717          	auipc	a4,0x8
    80000c46:	e1670713          	addi	a4,a4,-490 # 80008a58 <FREE_PAGES>
    80000c4a:	631c                	ld	a5,0(a4)
    80000c4c:	0785                	addi	a5,a5,1
    80000c4e:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000c50:	854a                	mv	a0,s2
    80000c52:	00000097          	auipc	ra,0x0
    80000c56:	2f8080e7          	jalr	760(ra) # 80000f4a <release>
    80000c5a:	b795                	j	80000bbe <kfree+0xa4>

0000000080000c5c <freerange>:
{
    80000c5c:	7179                	addi	sp,sp,-48
    80000c5e:	f406                	sd	ra,40(sp)
    80000c60:	f022                	sd	s0,32(sp)
    80000c62:	ec26                	sd	s1,24(sp)
    80000c64:	e84a                	sd	s2,16(sp)
    80000c66:	e44e                	sd	s3,8(sp)
    80000c68:	e052                	sd	s4,0(sp)
    80000c6a:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000c6c:	6785                	lui	a5,0x1
    80000c6e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000c72:	00e504b3          	add	s1,a0,a4
    80000c76:	777d                	lui	a4,0xfffff
    80000c78:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c7a:	94be                	add	s1,s1,a5
    80000c7c:	0095ee63          	bltu	a1,s1,80000c98 <freerange+0x3c>
    80000c80:	892e                	mv	s2,a1
        kfree(p);
    80000c82:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c84:	6985                	lui	s3,0x1
        kfree(p);
    80000c86:	01448533          	add	a0,s1,s4
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	e90080e7          	jalr	-368(ra) # 80000b1a <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c92:	94ce                	add	s1,s1,s3
    80000c94:	fe9979e3          	bgeu	s2,s1,80000c86 <freerange+0x2a>
}
    80000c98:	70a2                	ld	ra,40(sp)
    80000c9a:	7402                	ld	s0,32(sp)
    80000c9c:	64e2                	ld	s1,24(sp)
    80000c9e:	6942                	ld	s2,16(sp)
    80000ca0:	69a2                	ld	s3,8(sp)
    80000ca2:	6a02                	ld	s4,0(sp)
    80000ca4:	6145                	addi	sp,sp,48
    80000ca6:	8082                	ret

0000000080000ca8 <kinit>:
{
    80000ca8:	1141                	addi	sp,sp,-16
    80000caa:	e406                	sd	ra,8(sp)
    80000cac:	e022                	sd	s0,0(sp)
    80000cae:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000cb0:	00007597          	auipc	a1,0x7
    80000cb4:	40858593          	addi	a1,a1,1032 # 800080b8 <digits+0x68>
    80000cb8:	00010517          	auipc	a0,0x10
    80000cbc:	03050513          	addi	a0,a0,48 # 80010ce8 <kmem>
    80000cc0:	00000097          	auipc	ra,0x0
    80000cc4:	146080e7          	jalr	326(ra) # 80000e06 <initlock>
    initlock(&refcountlock, "refcount");
    80000cc8:	00007597          	auipc	a1,0x7
    80000ccc:	3f858593          	addi	a1,a1,1016 # 800080c0 <digits+0x70>
    80000cd0:	00010517          	auipc	a0,0x10
    80000cd4:	00050513          	mv	a0,a0
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	12e080e7          	jalr	302(ra) # 80000e06 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000ce0:	45c5                	li	a1,17
    80000ce2:	05ee                	slli	a1,a1,0x1b
    80000ce4:	00041517          	auipc	a0,0x41
    80000ce8:	23450513          	addi	a0,a0,564 # 80041f18 <end>
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	f70080e7          	jalr	-144(ra) # 80000c5c <freerange>
    MAX_PAGES = FREE_PAGES;
    80000cf4:	00008797          	auipc	a5,0x8
    80000cf8:	d647b783          	ld	a5,-668(a5) # 80008a58 <FREE_PAGES>
    80000cfc:	00008717          	auipc	a4,0x8
    80000d00:	d6f73223          	sd	a5,-668(a4) # 80008a60 <MAX_PAGES>
}
    80000d04:	60a2                	ld	ra,8(sp)
    80000d06:	6402                	ld	s0,0(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000d0c:	7179                	addi	sp,sp,-48
    80000d0e:	f406                	sd	ra,40(sp)
    80000d10:	f022                	sd	s0,32(sp)
    80000d12:	ec26                	sd	s1,24(sp)
    80000d14:	e84a                	sd	s2,16(sp)
    80000d16:	e44e                	sd	s3,8(sp)
    80000d18:	1800                	addi	s0,sp,48
    assert(FREE_PAGES > 0);
    80000d1a:	00008797          	auipc	a5,0x8
    80000d1e:	d3e7b783          	ld	a5,-706(a5) # 80008a58 <FREE_PAGES>
    80000d22:	cfd9                	beqz	a5,80000dc0 <kalloc+0xb4>
    struct run *r;

    acquire(&kmem.lock);
    80000d24:	00010517          	auipc	a0,0x10
    80000d28:	fc450513          	addi	a0,a0,-60 # 80010ce8 <kmem>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	16a080e7          	jalr	362(ra) # 80000e96 <acquire>
    r = kmem.freelist;
    80000d34:	00010917          	auipc	s2,0x10
    80000d38:	fcc93903          	ld	s2,-52(s2) # 80010d00 <kmem+0x18>
    if (r)
    80000d3c:	0a090c63          	beqz	s2,80000df4 <kalloc+0xe8>
        kmem.freelist = r->next;
    80000d40:	00093783          	ld	a5,0(s2)
    80000d44:	00010717          	auipc	a4,0x10
    80000d48:	faf73e23          	sd	a5,-68(a4) # 80010d00 <kmem+0x18>
    release(&kmem.lock);
    80000d4c:	00010517          	auipc	a0,0x10
    80000d50:	f9c50513          	addi	a0,a0,-100 # 80010ce8 <kmem>
    80000d54:	00000097          	auipc	ra,0x0
    80000d58:	1f6080e7          	jalr	502(ra) # 80000f4a <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000d5c:	6605                	lui	a2,0x1
    80000d5e:	4595                	li	a1,5
    80000d60:	854a                	mv	a0,s2
    80000d62:	00000097          	auipc	ra,0x0
    80000d66:	230080e7          	jalr	560(ra) # 80000f92 <memset>
    FREE_PAGES--;
    80000d6a:	00008717          	auipc	a4,0x8
    80000d6e:	cee70713          	addi	a4,a4,-786 # 80008a58 <FREE_PAGES>
    80000d72:	631c                	ld	a5,0(a4)
    80000d74:	17fd                	addi	a5,a5,-1
    80000d76:	e31c                	sd	a5,0(a4)

    int i = refindex((uint64) r);
    80000d78:	854a                	mv	a0,s2
    80000d7a:	00000097          	auipc	ra,0x0
    80000d7e:	c80080e7          	jalr	-896(ra) # 800009fa <refindex>
    80000d82:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000d84:	00010997          	auipc	s3,0x10
    80000d88:	f4c98993          	addi	s3,s3,-180 # 80010cd0 <refcountlock>
    80000d8c:	854e                	mv	a0,s3
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	108080e7          	jalr	264(ra) # 80000e96 <acquire>
    refcount[i] = 1;
    80000d96:	048a                	slli	s1,s1,0x2
    80000d98:	00010797          	auipc	a5,0x10
    80000d9c:	f7078793          	addi	a5,a5,-144 # 80010d08 <refcount>
    80000da0:	97a6                	add	a5,a5,s1
    80000da2:	4705                	li	a4,1
    80000da4:	c398                	sw	a4,0(a5)
    release(&refcountlock);
    80000da6:	854e                	mv	a0,s3
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	1a2080e7          	jalr	418(ra) # 80000f4a <release>

    return (void *)r;
}
    80000db0:	854a                	mv	a0,s2
    80000db2:	70a2                	ld	ra,40(sp)
    80000db4:	7402                	ld	s0,32(sp)
    80000db6:	64e2                	ld	s1,24(sp)
    80000db8:	6942                	ld	s2,16(sp)
    80000dba:	69a2                	ld	s3,8(sp)
    80000dbc:	6145                	addi	sp,sp,48
    80000dbe:	8082                	ret
    assert(FREE_PAGES > 0);
    80000dc0:	08700693          	li	a3,135
    80000dc4:	00007617          	auipc	a2,0x7
    80000dc8:	23c60613          	addi	a2,a2,572 # 80008000 <etext>
    80000dcc:	00007597          	auipc	a1,0x7
    80000dd0:	2b458593          	addi	a1,a1,692 # 80008080 <digits+0x30>
    80000dd4:	00007517          	auipc	a0,0x7
    80000dd8:	2bc50513          	addi	a0,a0,700 # 80008090 <digits+0x40>
    80000ddc:	fffff097          	auipc	ra,0xfffff
    80000de0:	7c0080e7          	jalr	1984(ra) # 8000059c <printf>
    80000de4:	00007517          	auipc	a0,0x7
    80000de8:	2bc50513          	addi	a0,a0,700 # 800080a0 <digits+0x50>
    80000dec:	fffff097          	auipc	ra,0xfffff
    80000df0:	754080e7          	jalr	1876(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000df4:	00010517          	auipc	a0,0x10
    80000df8:	ef450513          	addi	a0,a0,-268 # 80010ce8 <kmem>
    80000dfc:	00000097          	auipc	ra,0x0
    80000e00:	14e080e7          	jalr	334(ra) # 80000f4a <release>
    if (r)
    80000e04:	b79d                	j	80000d6a <kalloc+0x5e>

0000000080000e06 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000e0c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000e0e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000e12:	00053823          	sd	zero,16(a0)
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000e1c:	411c                	lw	a5,0(a0)
    80000e1e:	e399                	bnez	a5,80000e24 <holding+0x8>
    80000e20:	4501                	li	a0,0
  return r;
}
    80000e22:	8082                	ret
{
    80000e24:	1101                	addi	sp,sp,-32
    80000e26:	ec06                	sd	ra,24(sp)
    80000e28:	e822                	sd	s0,16(sp)
    80000e2a:	e426                	sd	s1,8(sp)
    80000e2c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000e2e:	6904                	ld	s1,16(a0)
    80000e30:	00001097          	auipc	ra,0x1
    80000e34:	f76080e7          	jalr	-138(ra) # 80001da6 <mycpu>
    80000e38:	40a48533          	sub	a0,s1,a0
    80000e3c:	00153513          	seqz	a0,a0
}
    80000e40:	60e2                	ld	ra,24(sp)
    80000e42:	6442                	ld	s0,16(sp)
    80000e44:	64a2                	ld	s1,8(sp)
    80000e46:	6105                	addi	sp,sp,32
    80000e48:	8082                	ret

0000000080000e4a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000e4a:	1101                	addi	sp,sp,-32
    80000e4c:	ec06                	sd	ra,24(sp)
    80000e4e:	e822                	sd	s0,16(sp)
    80000e50:	e426                	sd	s1,8(sp)
    80000e52:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000e54:	100024f3          	csrr	s1,sstatus
    80000e58:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000e5c:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000e5e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000e62:	00001097          	auipc	ra,0x1
    80000e66:	f44080e7          	jalr	-188(ra) # 80001da6 <mycpu>
    80000e6a:	5d3c                	lw	a5,120(a0)
    80000e6c:	cf89                	beqz	a5,80000e86 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000e6e:	00001097          	auipc	ra,0x1
    80000e72:	f38080e7          	jalr	-200(ra) # 80001da6 <mycpu>
    80000e76:	5d3c                	lw	a5,120(a0)
    80000e78:	2785                	addiw	a5,a5,1
    80000e7a:	dd3c                	sw	a5,120(a0)
}
    80000e7c:	60e2                	ld	ra,24(sp)
    80000e7e:	6442                	ld	s0,16(sp)
    80000e80:	64a2                	ld	s1,8(sp)
    80000e82:	6105                	addi	sp,sp,32
    80000e84:	8082                	ret
    mycpu()->intena = old;
    80000e86:	00001097          	auipc	ra,0x1
    80000e8a:	f20080e7          	jalr	-224(ra) # 80001da6 <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000e8e:	8085                	srli	s1,s1,0x1
    80000e90:	8885                	andi	s1,s1,1
    80000e92:	dd64                	sw	s1,124(a0)
    80000e94:	bfe9                	j	80000e6e <push_off+0x24>

0000000080000e96 <acquire>:
{
    80000e96:	1101                	addi	sp,sp,-32
    80000e98:	ec06                	sd	ra,24(sp)
    80000e9a:	e822                	sd	s0,16(sp)
    80000e9c:	e426                	sd	s1,8(sp)
    80000e9e:	1000                	addi	s0,sp,32
    80000ea0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ea2:	00000097          	auipc	ra,0x0
    80000ea6:	fa8080e7          	jalr	-88(ra) # 80000e4a <push_off>
  if(holding(lk))
    80000eaa:	8526                	mv	a0,s1
    80000eac:	00000097          	auipc	ra,0x0
    80000eb0:	f70080e7          	jalr	-144(ra) # 80000e1c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000eb4:	4705                	li	a4,1
  if(holding(lk))
    80000eb6:	e115                	bnez	a0,80000eda <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000eb8:	87ba                	mv	a5,a4
    80000eba:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000ebe:	2781                	sext.w	a5,a5
    80000ec0:	ffe5                	bnez	a5,80000eb8 <acquire+0x22>
  __sync_synchronize();
    80000ec2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000ec6:	00001097          	auipc	ra,0x1
    80000eca:	ee0080e7          	jalr	-288(ra) # 80001da6 <mycpu>
    80000ece:	e888                	sd	a0,16(s1)
}
    80000ed0:	60e2                	ld	ra,24(sp)
    80000ed2:	6442                	ld	s0,16(sp)
    80000ed4:	64a2                	ld	s1,8(sp)
    80000ed6:	6105                	addi	sp,sp,32
    80000ed8:	8082                	ret
    panic("acquire");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1f650513          	addi	a0,a0,502 # 800080d0 <digits+0x80>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	65e080e7          	jalr	1630(ra) # 80000540 <panic>

0000000080000eea <pop_off>:

void
pop_off(void)
{
    80000eea:	1141                	addi	sp,sp,-16
    80000eec:	e406                	sd	ra,8(sp)
    80000eee:	e022                	sd	s0,0(sp)
    80000ef0:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000ef2:	00001097          	auipc	ra,0x1
    80000ef6:	eb4080e7          	jalr	-332(ra) # 80001da6 <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000efa:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000efe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000f00:	e78d                	bnez	a5,80000f2a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000f02:	5d3c                	lw	a5,120(a0)
    80000f04:	02f05b63          	blez	a5,80000f3a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000f08:	37fd                	addiw	a5,a5,-1
    80000f0a:	0007871b          	sext.w	a4,a5
    80000f0e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000f10:	eb09                	bnez	a4,80000f22 <pop_off+0x38>
    80000f12:	5d7c                	lw	a5,124(a0)
    80000f14:	c799                	beqz	a5,80000f22 <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000f16:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000f1a:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000f1e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000f22:	60a2                	ld	ra,8(sp)
    80000f24:	6402                	ld	s0,0(sp)
    80000f26:	0141                	addi	sp,sp,16
    80000f28:	8082                	ret
    panic("pop_off - interruptible");
    80000f2a:	00007517          	auipc	a0,0x7
    80000f2e:	1ae50513          	addi	a0,a0,430 # 800080d8 <digits+0x88>
    80000f32:	fffff097          	auipc	ra,0xfffff
    80000f36:	60e080e7          	jalr	1550(ra) # 80000540 <panic>
    panic("pop_off");
    80000f3a:	00007517          	auipc	a0,0x7
    80000f3e:	1b650513          	addi	a0,a0,438 # 800080f0 <digits+0xa0>
    80000f42:	fffff097          	auipc	ra,0xfffff
    80000f46:	5fe080e7          	jalr	1534(ra) # 80000540 <panic>

0000000080000f4a <release>:
{
    80000f4a:	1101                	addi	sp,sp,-32
    80000f4c:	ec06                	sd	ra,24(sp)
    80000f4e:	e822                	sd	s0,16(sp)
    80000f50:	e426                	sd	s1,8(sp)
    80000f52:	1000                	addi	s0,sp,32
    80000f54:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000f56:	00000097          	auipc	ra,0x0
    80000f5a:	ec6080e7          	jalr	-314(ra) # 80000e1c <holding>
    80000f5e:	c115                	beqz	a0,80000f82 <release+0x38>
  lk->cpu = 0;
    80000f60:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000f64:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000f68:	0f50000f          	fence	iorw,ow
    80000f6c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	f7a080e7          	jalr	-134(ra) # 80000eea <pop_off>
}
    80000f78:	60e2                	ld	ra,24(sp)
    80000f7a:	6442                	ld	s0,16(sp)
    80000f7c:	64a2                	ld	s1,8(sp)
    80000f7e:	6105                	addi	sp,sp,32
    80000f80:	8082                	ret
    panic("release");
    80000f82:	00007517          	auipc	a0,0x7
    80000f86:	17650513          	addi	a0,a0,374 # 800080f8 <digits+0xa8>
    80000f8a:	fffff097          	auipc	ra,0xfffff
    80000f8e:	5b6080e7          	jalr	1462(ra) # 80000540 <panic>

0000000080000f92 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f92:	1141                	addi	sp,sp,-16
    80000f94:	e422                	sd	s0,8(sp)
    80000f96:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f98:	ca19                	beqz	a2,80000fae <memset+0x1c>
    80000f9a:	87aa                	mv	a5,a0
    80000f9c:	1602                	slli	a2,a2,0x20
    80000f9e:	9201                	srli	a2,a2,0x20
    80000fa0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000fa4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000fa8:	0785                	addi	a5,a5,1
    80000faa:	fee79de3          	bne	a5,a4,80000fa4 <memset+0x12>
  }
  return dst;
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret

0000000080000fb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000fb4:	1141                	addi	sp,sp,-16
    80000fb6:	e422                	sd	s0,8(sp)
    80000fb8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000fba:	ca05                	beqz	a2,80000fea <memcmp+0x36>
    80000fbc:	fff6069b          	addiw	a3,a2,-1
    80000fc0:	1682                	slli	a3,a3,0x20
    80000fc2:	9281                	srli	a3,a3,0x20
    80000fc4:	0685                	addi	a3,a3,1
    80000fc6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000fc8:	00054783          	lbu	a5,0(a0)
    80000fcc:	0005c703          	lbu	a4,0(a1)
    80000fd0:	00e79863          	bne	a5,a4,80000fe0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000fd4:	0505                	addi	a0,a0,1
    80000fd6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000fd8:	fed518e3          	bne	a0,a3,80000fc8 <memcmp+0x14>
  }

  return 0;
    80000fdc:	4501                	li	a0,0
    80000fde:	a019                	j	80000fe4 <memcmp+0x30>
      return *s1 - *s2;
    80000fe0:	40e7853b          	subw	a0,a5,a4
}
    80000fe4:	6422                	ld	s0,8(sp)
    80000fe6:	0141                	addi	sp,sp,16
    80000fe8:	8082                	ret
  return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	bfe5                	j	80000fe4 <memcmp+0x30>

0000000080000fee <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000fee:	1141                	addi	sp,sp,-16
    80000ff0:	e422                	sd	s0,8(sp)
    80000ff2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ff4:	c205                	beqz	a2,80001014 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ff6:	02a5e263          	bltu	a1,a0,8000101a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ffa:	1602                	slli	a2,a2,0x20
    80000ffc:	9201                	srli	a2,a2,0x20
    80000ffe:	00c587b3          	add	a5,a1,a2
{
    80001002:	872a                	mv	a4,a0
      *d++ = *s++;
    80001004:	0585                	addi	a1,a1,1
    80001006:	0705                	addi	a4,a4,1
    80001008:	fff5c683          	lbu	a3,-1(a1)
    8000100c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80001010:	fef59ae3          	bne	a1,a5,80001004 <memmove+0x16>

  return dst;
}
    80001014:	6422                	ld	s0,8(sp)
    80001016:	0141                	addi	sp,sp,16
    80001018:	8082                	ret
  if(s < d && s + n > d){
    8000101a:	02061693          	slli	a3,a2,0x20
    8000101e:	9281                	srli	a3,a3,0x20
    80001020:	00d58733          	add	a4,a1,a3
    80001024:	fce57be3          	bgeu	a0,a4,80000ffa <memmove+0xc>
    d += n;
    80001028:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000102a:	fff6079b          	addiw	a5,a2,-1
    8000102e:	1782                	slli	a5,a5,0x20
    80001030:	9381                	srli	a5,a5,0x20
    80001032:	fff7c793          	not	a5,a5
    80001036:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80001038:	177d                	addi	a4,a4,-1
    8000103a:	16fd                	addi	a3,a3,-1
    8000103c:	00074603          	lbu	a2,0(a4)
    80001040:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80001044:	fee79ae3          	bne	a5,a4,80001038 <memmove+0x4a>
    80001048:	b7f1                	j	80001014 <memmove+0x26>

000000008000104a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000104a:	1141                	addi	sp,sp,-16
    8000104c:	e406                	sd	ra,8(sp)
    8000104e:	e022                	sd	s0,0(sp)
    80001050:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80001052:	00000097          	auipc	ra,0x0
    80001056:	f9c080e7          	jalr	-100(ra) # 80000fee <memmove>
}
    8000105a:	60a2                	ld	ra,8(sp)
    8000105c:	6402                	ld	s0,0(sp)
    8000105e:	0141                	addi	sp,sp,16
    80001060:	8082                	ret

0000000080001062 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e422                	sd	s0,8(sp)
    80001066:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001068:	ce11                	beqz	a2,80001084 <strncmp+0x22>
    8000106a:	00054783          	lbu	a5,0(a0)
    8000106e:	cf89                	beqz	a5,80001088 <strncmp+0x26>
    80001070:	0005c703          	lbu	a4,0(a1)
    80001074:	00f71a63          	bne	a4,a5,80001088 <strncmp+0x26>
    n--, p++, q++;
    80001078:	367d                	addiw	a2,a2,-1
    8000107a:	0505                	addi	a0,a0,1
    8000107c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000107e:	f675                	bnez	a2,8000106a <strncmp+0x8>
  if(n == 0)
    return 0;
    80001080:	4501                	li	a0,0
    80001082:	a809                	j	80001094 <strncmp+0x32>
    80001084:	4501                	li	a0,0
    80001086:	a039                	j	80001094 <strncmp+0x32>
  if(n == 0)
    80001088:	ca09                	beqz	a2,8000109a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    8000108a:	00054503          	lbu	a0,0(a0)
    8000108e:	0005c783          	lbu	a5,0(a1)
    80001092:	9d1d                	subw	a0,a0,a5
}
    80001094:	6422                	ld	s0,8(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	bfe5                	j	80001094 <strncmp+0x32>

000000008000109e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e422                	sd	s0,8(sp)
    800010a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800010a4:	872a                	mv	a4,a0
    800010a6:	8832                	mv	a6,a2
    800010a8:	367d                	addiw	a2,a2,-1
    800010aa:	01005963          	blez	a6,800010bc <strncpy+0x1e>
    800010ae:	0705                	addi	a4,a4,1
    800010b0:	0005c783          	lbu	a5,0(a1)
    800010b4:	fef70fa3          	sb	a5,-1(a4)
    800010b8:	0585                	addi	a1,a1,1
    800010ba:	f7f5                	bnez	a5,800010a6 <strncpy+0x8>
    ;
  while(n-- > 0)
    800010bc:	86ba                	mv	a3,a4
    800010be:	00c05c63          	blez	a2,800010d6 <strncpy+0x38>
    *s++ = 0;
    800010c2:	0685                	addi	a3,a3,1
    800010c4:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800010c8:	40d707bb          	subw	a5,a4,a3
    800010cc:	37fd                	addiw	a5,a5,-1
    800010ce:	010787bb          	addw	a5,a5,a6
    800010d2:	fef048e3          	bgtz	a5,800010c2 <strncpy+0x24>
  return os;
}
    800010d6:	6422                	ld	s0,8(sp)
    800010d8:	0141                	addi	sp,sp,16
    800010da:	8082                	ret

00000000800010dc <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800010dc:	1141                	addi	sp,sp,-16
    800010de:	e422                	sd	s0,8(sp)
    800010e0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800010e2:	02c05363          	blez	a2,80001108 <safestrcpy+0x2c>
    800010e6:	fff6069b          	addiw	a3,a2,-1
    800010ea:	1682                	slli	a3,a3,0x20
    800010ec:	9281                	srli	a3,a3,0x20
    800010ee:	96ae                	add	a3,a3,a1
    800010f0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800010f2:	00d58963          	beq	a1,a3,80001104 <safestrcpy+0x28>
    800010f6:	0585                	addi	a1,a1,1
    800010f8:	0785                	addi	a5,a5,1
    800010fa:	fff5c703          	lbu	a4,-1(a1)
    800010fe:	fee78fa3          	sb	a4,-1(a5)
    80001102:	fb65                	bnez	a4,800010f2 <safestrcpy+0x16>
    ;
  *s = 0;
    80001104:	00078023          	sb	zero,0(a5)
  return os;
}
    80001108:	6422                	ld	s0,8(sp)
    8000110a:	0141                	addi	sp,sp,16
    8000110c:	8082                	ret

000000008000110e <strlen>:

int
strlen(const char *s)
{
    8000110e:	1141                	addi	sp,sp,-16
    80001110:	e422                	sd	s0,8(sp)
    80001112:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001114:	00054783          	lbu	a5,0(a0)
    80001118:	cf91                	beqz	a5,80001134 <strlen+0x26>
    8000111a:	0505                	addi	a0,a0,1
    8000111c:	87aa                	mv	a5,a0
    8000111e:	4685                	li	a3,1
    80001120:	9e89                	subw	a3,a3,a0
    80001122:	00f6853b          	addw	a0,a3,a5
    80001126:	0785                	addi	a5,a5,1
    80001128:	fff7c703          	lbu	a4,-1(a5)
    8000112c:	fb7d                	bnez	a4,80001122 <strlen+0x14>
    ;
  return n;
}
    8000112e:	6422                	ld	s0,8(sp)
    80001130:	0141                	addi	sp,sp,16
    80001132:	8082                	ret
  for(n = 0; s[n]; n++)
    80001134:	4501                	li	a0,0
    80001136:	bfe5                	j	8000112e <strlen+0x20>

0000000080001138 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001140:	00001097          	auipc	ra,0x1
    80001144:	c56080e7          	jalr	-938(ra) # 80001d96 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001148:	00008717          	auipc	a4,0x8
    8000114c:	92070713          	addi	a4,a4,-1760 # 80008a68 <started>
  if(cpuid() == 0){
    80001150:	c139                	beqz	a0,80001196 <main+0x5e>
    while(started == 0)
    80001152:	431c                	lw	a5,0(a4)
    80001154:	2781                	sext.w	a5,a5
    80001156:	dff5                	beqz	a5,80001152 <main+0x1a>
      ;
    __sync_synchronize();
    80001158:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000115c:	00001097          	auipc	ra,0x1
    80001160:	c3a080e7          	jalr	-966(ra) # 80001d96 <cpuid>
    80001164:	85aa                	mv	a1,a0
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	fb250513          	addi	a0,a0,-78 # 80008118 <digits+0xc8>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	42e080e7          	jalr	1070(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    80001176:	00000097          	auipc	ra,0x0
    8000117a:	0d8080e7          	jalr	216(ra) # 8000124e <kvminithart>
    trapinithart();   // install kernel trap vector
    8000117e:	00002097          	auipc	ra,0x2
    80001182:	b40080e7          	jalr	-1216(ra) # 80002cbe <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001186:	00005097          	auipc	ra,0x5
    8000118a:	2ca080e7          	jalr	714(ra) # 80006450 <plicinithart>
  }

  scheduler();        
    8000118e:	00001097          	auipc	ra,0x1
    80001192:	2c0080e7          	jalr	704(ra) # 8000244e <scheduler>
    consoleinit();
    80001196:	fffff097          	auipc	ra,0xfffff
    8000119a:	2ba080e7          	jalr	698(ra) # 80000450 <consoleinit>
    printfinit();
    8000119e:	fffff097          	auipc	ra,0xfffff
    800011a2:	5de080e7          	jalr	1502(ra) # 8000077c <printfinit>
    printf("\n");
    800011a6:	00007517          	auipc	a0,0x7
    800011aa:	ef250513          	addi	a0,a0,-270 # 80008098 <digits+0x48>
    800011ae:	fffff097          	auipc	ra,0xfffff
    800011b2:	3ee080e7          	jalr	1006(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    800011b6:	00007517          	auipc	a0,0x7
    800011ba:	f4a50513          	addi	a0,a0,-182 # 80008100 <digits+0xb0>
    800011be:	fffff097          	auipc	ra,0xfffff
    800011c2:	3de080e7          	jalr	990(ra) # 8000059c <printf>
    printf("\n");
    800011c6:	00007517          	auipc	a0,0x7
    800011ca:	ed250513          	addi	a0,a0,-302 # 80008098 <digits+0x48>
    800011ce:	fffff097          	auipc	ra,0xfffff
    800011d2:	3ce080e7          	jalr	974(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	ad2080e7          	jalr	-1326(ra) # 80000ca8 <kinit>
    kvminit();       // create kernel page table
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	326080e7          	jalr	806(ra) # 80001504 <kvminit>
    kvminithart();   // turn on paging
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	068080e7          	jalr	104(ra) # 8000124e <kvminithart>
    procinit();      // process table
    800011ee:	00001097          	auipc	ra,0x1
    800011f2:	ac6080e7          	jalr	-1338(ra) # 80001cb4 <procinit>
    trapinit();      // trap vectors
    800011f6:	00002097          	auipc	ra,0x2
    800011fa:	aa0080e7          	jalr	-1376(ra) # 80002c96 <trapinit>
    trapinithart();  // install kernel trap vector
    800011fe:	00002097          	auipc	ra,0x2
    80001202:	ac0080e7          	jalr	-1344(ra) # 80002cbe <trapinithart>
    plicinit();      // set up interrupt controller
    80001206:	00005097          	auipc	ra,0x5
    8000120a:	234080e7          	jalr	564(ra) # 8000643a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000120e:	00005097          	auipc	ra,0x5
    80001212:	242080e7          	jalr	578(ra) # 80006450 <plicinithart>
    binit();         // buffer cache
    80001216:	00002097          	auipc	ra,0x2
    8000121a:	3e4080e7          	jalr	996(ra) # 800035fa <binit>
    iinit();         // inode table
    8000121e:	00003097          	auipc	ra,0x3
    80001222:	a84080e7          	jalr	-1404(ra) # 80003ca2 <iinit>
    fileinit();      // file table
    80001226:	00004097          	auipc	ra,0x4
    8000122a:	a2a080e7          	jalr	-1494(ra) # 80004c50 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000122e:	00005097          	auipc	ra,0x5
    80001232:	32a080e7          	jalr	810(ra) # 80006558 <virtio_disk_init>
    userinit();      // first user process
    80001236:	00001097          	auipc	ra,0x1
    8000123a:	e64080e7          	jalr	-412(ra) # 8000209a <userinit>
    __sync_synchronize();
    8000123e:	0ff0000f          	fence
    started = 1;
    80001242:	4785                	li	a5,1
    80001244:	00008717          	auipc	a4,0x8
    80001248:	82f72223          	sw	a5,-2012(a4) # 80008a68 <started>
    8000124c:	b789                	j	8000118e <main+0x56>

000000008000124e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000124e:	1141                	addi	sp,sp,-16
    80001250:	e422                	sd	s0,8(sp)
    80001252:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    80001254:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001258:	00008797          	auipc	a5,0x8
    8000125c:	8187b783          	ld	a5,-2024(a5) # 80008a70 <kernel_pagetable>
    80001260:	83b1                	srli	a5,a5,0xc
    80001262:	577d                	li	a4,-1
    80001264:	177e                	slli	a4,a4,0x3f
    80001266:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80001268:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    8000126c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001270:	6422                	ld	s0,8(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001276:	7139                	addi	sp,sp,-64
    80001278:	fc06                	sd	ra,56(sp)
    8000127a:	f822                	sd	s0,48(sp)
    8000127c:	f426                	sd	s1,40(sp)
    8000127e:	f04a                	sd	s2,32(sp)
    80001280:	ec4e                	sd	s3,24(sp)
    80001282:	e852                	sd	s4,16(sp)
    80001284:	e456                	sd	s5,8(sp)
    80001286:	e05a                	sd	s6,0(sp)
    80001288:	0080                	addi	s0,sp,64
    8000128a:	84aa                	mv	s1,a0
    8000128c:	89ae                	mv	s3,a1
    8000128e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001290:	57fd                	li	a5,-1
    80001292:	83e9                	srli	a5,a5,0x1a
    80001294:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001296:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001298:	04b7f263          	bgeu	a5,a1,800012dc <walk+0x66>
    panic("walk");
    8000129c:	00007517          	auipc	a0,0x7
    800012a0:	e9450513          	addi	a0,a0,-364 # 80008130 <digits+0xe0>
    800012a4:	fffff097          	auipc	ra,0xfffff
    800012a8:	29c080e7          	jalr	668(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800012ac:	060a8663          	beqz	s5,80001318 <walk+0xa2>
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	a5c080e7          	jalr	-1444(ra) # 80000d0c <kalloc>
    800012b8:	84aa                	mv	s1,a0
    800012ba:	c529                	beqz	a0,80001304 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800012bc:	6605                	lui	a2,0x1
    800012be:	4581                	li	a1,0
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	cd2080e7          	jalr	-814(ra) # 80000f92 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800012c8:	00c4d793          	srli	a5,s1,0xc
    800012cc:	07aa                	slli	a5,a5,0xa
    800012ce:	0017e793          	ori	a5,a5,1
    800012d2:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800012d6:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffbd0df>
    800012d8:	036a0063          	beq	s4,s6,800012f8 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800012dc:	0149d933          	srl	s2,s3,s4
    800012e0:	1ff97913          	andi	s2,s2,511
    800012e4:	090e                	slli	s2,s2,0x3
    800012e6:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800012e8:	00093483          	ld	s1,0(s2)
    800012ec:	0014f793          	andi	a5,s1,1
    800012f0:	dfd5                	beqz	a5,800012ac <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800012f2:	80a9                	srli	s1,s1,0xa
    800012f4:	04b2                	slli	s1,s1,0xc
    800012f6:	b7c5                	j	800012d6 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800012f8:	00c9d513          	srli	a0,s3,0xc
    800012fc:	1ff57513          	andi	a0,a0,511
    80001300:	050e                	slli	a0,a0,0x3
    80001302:	9526                	add	a0,a0,s1
}
    80001304:	70e2                	ld	ra,56(sp)
    80001306:	7442                	ld	s0,48(sp)
    80001308:	74a2                	ld	s1,40(sp)
    8000130a:	7902                	ld	s2,32(sp)
    8000130c:	69e2                	ld	s3,24(sp)
    8000130e:	6a42                	ld	s4,16(sp)
    80001310:	6aa2                	ld	s5,8(sp)
    80001312:	6b02                	ld	s6,0(sp)
    80001314:	6121                	addi	sp,sp,64
    80001316:	8082                	ret
        return 0;
    80001318:	4501                	li	a0,0
    8000131a:	b7ed                	j	80001304 <walk+0x8e>

000000008000131c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000131c:	57fd                	li	a5,-1
    8000131e:	83e9                	srli	a5,a5,0x1a
    80001320:	00b7f463          	bgeu	a5,a1,80001328 <walkaddr+0xc>
    return 0;
    80001324:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001326:	8082                	ret
{
    80001328:	1141                	addi	sp,sp,-16
    8000132a:	e406                	sd	ra,8(sp)
    8000132c:	e022                	sd	s0,0(sp)
    8000132e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001330:	4601                	li	a2,0
    80001332:	00000097          	auipc	ra,0x0
    80001336:	f44080e7          	jalr	-188(ra) # 80001276 <walk>
  if(pte == 0)
    8000133a:	c105                	beqz	a0,8000135a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000133c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000133e:	0117f693          	andi	a3,a5,17
    80001342:	4745                	li	a4,17
    return 0;
    80001344:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001346:	00e68663          	beq	a3,a4,80001352 <walkaddr+0x36>
}
    8000134a:	60a2                	ld	ra,8(sp)
    8000134c:	6402                	ld	s0,0(sp)
    8000134e:	0141                	addi	sp,sp,16
    80001350:	8082                	ret
  pa = PTE2PA(*pte);
    80001352:	83a9                	srli	a5,a5,0xa
    80001354:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001358:	bfcd                	j	8000134a <walkaddr+0x2e>
    return 0;
    8000135a:	4501                	li	a0,0
    8000135c:	b7fd                	j	8000134a <walkaddr+0x2e>

000000008000135e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000135e:	715d                	addi	sp,sp,-80
    80001360:	e486                	sd	ra,72(sp)
    80001362:	e0a2                	sd	s0,64(sp)
    80001364:	fc26                	sd	s1,56(sp)
    80001366:	f84a                	sd	s2,48(sp)
    80001368:	f44e                	sd	s3,40(sp)
    8000136a:	f052                	sd	s4,32(sp)
    8000136c:	ec56                	sd	s5,24(sp)
    8000136e:	e85a                	sd	s6,16(sp)
    80001370:	e45e                	sd	s7,8(sp)
    80001372:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001374:	c639                	beqz	a2,800013c2 <mappages+0x64>
    80001376:	8aaa                	mv	s5,a0
    80001378:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000137a:	777d                	lui	a4,0xfffff
    8000137c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001380:	fff58993          	addi	s3,a1,-1
    80001384:	99b2                	add	s3,s3,a2
    80001386:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000138a:	893e                	mv	s2,a5
    8000138c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001390:	6b85                	lui	s7,0x1
    80001392:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001396:	4605                	li	a2,1
    80001398:	85ca                	mv	a1,s2
    8000139a:	8556                	mv	a0,s5
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	eda080e7          	jalr	-294(ra) # 80001276 <walk>
    800013a4:	cd1d                	beqz	a0,800013e2 <mappages+0x84>
    if(*pte & PTE_V)
    800013a6:	611c                	ld	a5,0(a0)
    800013a8:	8b85                	andi	a5,a5,1
    800013aa:	e785                	bnez	a5,800013d2 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800013ac:	80b1                	srli	s1,s1,0xc
    800013ae:	04aa                	slli	s1,s1,0xa
    800013b0:	0164e4b3          	or	s1,s1,s6
    800013b4:	0014e493          	ori	s1,s1,1
    800013b8:	e104                	sd	s1,0(a0)
    if(a == last)
    800013ba:	05390063          	beq	s2,s3,800013fa <mappages+0x9c>
    a += PGSIZE;
    800013be:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800013c0:	bfc9                	j	80001392 <mappages+0x34>
    panic("mappages: size");
    800013c2:	00007517          	auipc	a0,0x7
    800013c6:	d7650513          	addi	a0,a0,-650 # 80008138 <digits+0xe8>
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	176080e7          	jalr	374(ra) # 80000540 <panic>
      panic("mappages: remap");
    800013d2:	00007517          	auipc	a0,0x7
    800013d6:	d7650513          	addi	a0,a0,-650 # 80008148 <digits+0xf8>
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	166080e7          	jalr	358(ra) # 80000540 <panic>
      return -1;
    800013e2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800013e4:	60a6                	ld	ra,72(sp)
    800013e6:	6406                	ld	s0,64(sp)
    800013e8:	74e2                	ld	s1,56(sp)
    800013ea:	7942                	ld	s2,48(sp)
    800013ec:	79a2                	ld	s3,40(sp)
    800013ee:	7a02                	ld	s4,32(sp)
    800013f0:	6ae2                	ld	s5,24(sp)
    800013f2:	6b42                	ld	s6,16(sp)
    800013f4:	6ba2                	ld	s7,8(sp)
    800013f6:	6161                	addi	sp,sp,80
    800013f8:	8082                	ret
  return 0;
    800013fa:	4501                	li	a0,0
    800013fc:	b7e5                	j	800013e4 <mappages+0x86>

00000000800013fe <kvmmap>:
{
    800013fe:	1141                	addi	sp,sp,-16
    80001400:	e406                	sd	ra,8(sp)
    80001402:	e022                	sd	s0,0(sp)
    80001404:	0800                	addi	s0,sp,16
    80001406:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001408:	86b2                	mv	a3,a2
    8000140a:	863e                	mv	a2,a5
    8000140c:	00000097          	auipc	ra,0x0
    80001410:	f52080e7          	jalr	-174(ra) # 8000135e <mappages>
    80001414:	e509                	bnez	a0,8000141e <kvmmap+0x20>
}
    80001416:	60a2                	ld	ra,8(sp)
    80001418:	6402                	ld	s0,0(sp)
    8000141a:	0141                	addi	sp,sp,16
    8000141c:	8082                	ret
    panic("kvmmap");
    8000141e:	00007517          	auipc	a0,0x7
    80001422:	d3a50513          	addi	a0,a0,-710 # 80008158 <digits+0x108>
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	11a080e7          	jalr	282(ra) # 80000540 <panic>

000000008000142e <kvmmake>:
{
    8000142e:	1101                	addi	sp,sp,-32
    80001430:	ec06                	sd	ra,24(sp)
    80001432:	e822                	sd	s0,16(sp)
    80001434:	e426                	sd	s1,8(sp)
    80001436:	e04a                	sd	s2,0(sp)
    80001438:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	8d2080e7          	jalr	-1838(ra) # 80000d0c <kalloc>
    80001442:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001444:	6605                	lui	a2,0x1
    80001446:	4581                	li	a1,0
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	b4a080e7          	jalr	-1206(ra) # 80000f92 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001450:	4719                	li	a4,6
    80001452:	6685                	lui	a3,0x1
    80001454:	10000637          	lui	a2,0x10000
    80001458:	100005b7          	lui	a1,0x10000
    8000145c:	8526                	mv	a0,s1
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	fa0080e7          	jalr	-96(ra) # 800013fe <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001466:	4719                	li	a4,6
    80001468:	6685                	lui	a3,0x1
    8000146a:	10001637          	lui	a2,0x10001
    8000146e:	100015b7          	lui	a1,0x10001
    80001472:	8526                	mv	a0,s1
    80001474:	00000097          	auipc	ra,0x0
    80001478:	f8a080e7          	jalr	-118(ra) # 800013fe <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000147c:	4719                	li	a4,6
    8000147e:	004006b7          	lui	a3,0x400
    80001482:	0c000637          	lui	a2,0xc000
    80001486:	0c0005b7          	lui	a1,0xc000
    8000148a:	8526                	mv	a0,s1
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f72080e7          	jalr	-142(ra) # 800013fe <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001494:	00007917          	auipc	s2,0x7
    80001498:	b6c90913          	addi	s2,s2,-1172 # 80008000 <etext>
    8000149c:	4729                	li	a4,10
    8000149e:	80007697          	auipc	a3,0x80007
    800014a2:	b6268693          	addi	a3,a3,-1182 # 8000 <_entry-0x7fff8000>
    800014a6:	4605                	li	a2,1
    800014a8:	067e                	slli	a2,a2,0x1f
    800014aa:	85b2                	mv	a1,a2
    800014ac:	8526                	mv	a0,s1
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f50080e7          	jalr	-176(ra) # 800013fe <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800014b6:	4719                	li	a4,6
    800014b8:	46c5                	li	a3,17
    800014ba:	06ee                	slli	a3,a3,0x1b
    800014bc:	412686b3          	sub	a3,a3,s2
    800014c0:	864a                	mv	a2,s2
    800014c2:	85ca                	mv	a1,s2
    800014c4:	8526                	mv	a0,s1
    800014c6:	00000097          	auipc	ra,0x0
    800014ca:	f38080e7          	jalr	-200(ra) # 800013fe <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800014ce:	4729                	li	a4,10
    800014d0:	6685                	lui	a3,0x1
    800014d2:	00006617          	auipc	a2,0x6
    800014d6:	b2e60613          	addi	a2,a2,-1234 # 80007000 <_trampoline>
    800014da:	040005b7          	lui	a1,0x4000
    800014de:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800014e0:	05b2                	slli	a1,a1,0xc
    800014e2:	8526                	mv	a0,s1
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	f1a080e7          	jalr	-230(ra) # 800013fe <kvmmap>
  proc_mapstacks(kpgtbl);
    800014ec:	8526                	mv	a0,s1
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	730080e7          	jalr	1840(ra) # 80001c1e <proc_mapstacks>
}
    800014f6:	8526                	mv	a0,s1
    800014f8:	60e2                	ld	ra,24(sp)
    800014fa:	6442                	ld	s0,16(sp)
    800014fc:	64a2                	ld	s1,8(sp)
    800014fe:	6902                	ld	s2,0(sp)
    80001500:	6105                	addi	sp,sp,32
    80001502:	8082                	ret

0000000080001504 <kvminit>:
{
    80001504:	1141                	addi	sp,sp,-16
    80001506:	e406                	sd	ra,8(sp)
    80001508:	e022                	sd	s0,0(sp)
    8000150a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	f22080e7          	jalr	-222(ra) # 8000142e <kvmmake>
    80001514:	00007797          	auipc	a5,0x7
    80001518:	54a7be23          	sd	a0,1372(a5) # 80008a70 <kernel_pagetable>
}
    8000151c:	60a2                	ld	ra,8(sp)
    8000151e:	6402                	ld	s0,0(sp)
    80001520:	0141                	addi	sp,sp,16
    80001522:	8082                	ret

0000000080001524 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001524:	715d                	addi	sp,sp,-80
    80001526:	e486                	sd	ra,72(sp)
    80001528:	e0a2                	sd	s0,64(sp)
    8000152a:	fc26                	sd	s1,56(sp)
    8000152c:	f84a                	sd	s2,48(sp)
    8000152e:	f44e                	sd	s3,40(sp)
    80001530:	f052                	sd	s4,32(sp)
    80001532:	ec56                	sd	s5,24(sp)
    80001534:	e85a                	sd	s6,16(sp)
    80001536:	e45e                	sd	s7,8(sp)
    80001538:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000153a:	03459793          	slli	a5,a1,0x34
    8000153e:	e795                	bnez	a5,8000156a <uvmunmap+0x46>
    80001540:	8a2a                	mv	s4,a0
    80001542:	892e                	mv	s2,a1
    80001544:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001546:	0632                	slli	a2,a2,0xc
    80001548:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000154c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000154e:	6b05                	lui	s6,0x1
    80001550:	0735e263          	bltu	a1,s3,800015b4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001554:	60a6                	ld	ra,72(sp)
    80001556:	6406                	ld	s0,64(sp)
    80001558:	74e2                	ld	s1,56(sp)
    8000155a:	7942                	ld	s2,48(sp)
    8000155c:	79a2                	ld	s3,40(sp)
    8000155e:	7a02                	ld	s4,32(sp)
    80001560:	6ae2                	ld	s5,24(sp)
    80001562:	6b42                	ld	s6,16(sp)
    80001564:	6ba2                	ld	s7,8(sp)
    80001566:	6161                	addi	sp,sp,80
    80001568:	8082                	ret
    panic("uvmunmap: not aligned");
    8000156a:	00007517          	auipc	a0,0x7
    8000156e:	bf650513          	addi	a0,a0,-1034 # 80008160 <digits+0x110>
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	fce080e7          	jalr	-50(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bfe50513          	addi	a0,a0,-1026 # 80008178 <digits+0x128>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fbe080e7          	jalr	-66(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    8000158a:	00007517          	auipc	a0,0x7
    8000158e:	bfe50513          	addi	a0,a0,-1026 # 80008188 <digits+0x138>
    80001592:	fffff097          	auipc	ra,0xfffff
    80001596:	fae080e7          	jalr	-82(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    8000159a:	00007517          	auipc	a0,0x7
    8000159e:	c0650513          	addi	a0,a0,-1018 # 800081a0 <digits+0x150>
    800015a2:	fffff097          	auipc	ra,0xfffff
    800015a6:	f9e080e7          	jalr	-98(ra) # 80000540 <panic>
    *pte = 0;
    800015aa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015ae:	995a                	add	s2,s2,s6
    800015b0:	fb3972e3          	bgeu	s2,s3,80001554 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800015b4:	4601                	li	a2,0
    800015b6:	85ca                	mv	a1,s2
    800015b8:	8552                	mv	a0,s4
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	cbc080e7          	jalr	-836(ra) # 80001276 <walk>
    800015c2:	84aa                	mv	s1,a0
    800015c4:	d95d                	beqz	a0,8000157a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800015c6:	6108                	ld	a0,0(a0)
    800015c8:	00157793          	andi	a5,a0,1
    800015cc:	dfdd                	beqz	a5,8000158a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800015ce:	3ff57793          	andi	a5,a0,1023
    800015d2:	fd7784e3          	beq	a5,s7,8000159a <uvmunmap+0x76>
    if(do_free){
    800015d6:	fc0a8ae3          	beqz	s5,800015aa <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800015da:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800015dc:	0532                	slli	a0,a0,0xc
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	53c080e7          	jalr	1340(ra) # 80000b1a <kfree>
    800015e6:	b7d1                	j	800015aa <uvmunmap+0x86>

00000000800015e8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800015e8:	1101                	addi	sp,sp,-32
    800015ea:	ec06                	sd	ra,24(sp)
    800015ec:	e822                	sd	s0,16(sp)
    800015ee:	e426                	sd	s1,8(sp)
    800015f0:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	71a080e7          	jalr	1818(ra) # 80000d0c <kalloc>
    800015fa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800015fc:	c519                	beqz	a0,8000160a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800015fe:	6605                	lui	a2,0x1
    80001600:	4581                	li	a1,0
    80001602:	00000097          	auipc	ra,0x0
    80001606:	990080e7          	jalr	-1648(ra) # 80000f92 <memset>
  return pagetable;
}
    8000160a:	8526                	mv	a0,s1
    8000160c:	60e2                	ld	ra,24(sp)
    8000160e:	6442                	ld	s0,16(sp)
    80001610:	64a2                	ld	s1,8(sp)
    80001612:	6105                	addi	sp,sp,32
    80001614:	8082                	ret

0000000080001616 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001616:	7179                	addi	sp,sp,-48
    80001618:	f406                	sd	ra,40(sp)
    8000161a:	f022                	sd	s0,32(sp)
    8000161c:	ec26                	sd	s1,24(sp)
    8000161e:	e84a                	sd	s2,16(sp)
    80001620:	e44e                	sd	s3,8(sp)
    80001622:	e052                	sd	s4,0(sp)
    80001624:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001626:	6785                	lui	a5,0x1
    80001628:	04f67863          	bgeu	a2,a5,80001678 <uvmfirst+0x62>
    8000162c:	8a2a                	mv	s4,a0
    8000162e:	89ae                	mv	s3,a1
    80001630:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	6da080e7          	jalr	1754(ra) # 80000d0c <kalloc>
    8000163a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000163c:	6605                	lui	a2,0x1
    8000163e:	4581                	li	a1,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	952080e7          	jalr	-1710(ra) # 80000f92 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001648:	4779                	li	a4,30
    8000164a:	86ca                	mv	a3,s2
    8000164c:	6605                	lui	a2,0x1
    8000164e:	4581                	li	a1,0
    80001650:	8552                	mv	a0,s4
    80001652:	00000097          	auipc	ra,0x0
    80001656:	d0c080e7          	jalr	-756(ra) # 8000135e <mappages>
  memmove(mem, src, sz);
    8000165a:	8626                	mv	a2,s1
    8000165c:	85ce                	mv	a1,s3
    8000165e:	854a                	mv	a0,s2
    80001660:	00000097          	auipc	ra,0x0
    80001664:	98e080e7          	jalr	-1650(ra) # 80000fee <memmove>
}
    80001668:	70a2                	ld	ra,40(sp)
    8000166a:	7402                	ld	s0,32(sp)
    8000166c:	64e2                	ld	s1,24(sp)
    8000166e:	6942                	ld	s2,16(sp)
    80001670:	69a2                	ld	s3,8(sp)
    80001672:	6a02                	ld	s4,0(sp)
    80001674:	6145                	addi	sp,sp,48
    80001676:	8082                	ret
    panic("uvmfirst: more than a page");
    80001678:	00007517          	auipc	a0,0x7
    8000167c:	b4050513          	addi	a0,a0,-1216 # 800081b8 <digits+0x168>
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	ec0080e7          	jalr	-320(ra) # 80000540 <panic>

0000000080001688 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001688:	1101                	addi	sp,sp,-32
    8000168a:	ec06                	sd	ra,24(sp)
    8000168c:	e822                	sd	s0,16(sp)
    8000168e:	e426                	sd	s1,8(sp)
    80001690:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001692:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001694:	00b67d63          	bgeu	a2,a1,800016ae <uvmdealloc+0x26>
    80001698:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000169a:	6785                	lui	a5,0x1
    8000169c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000169e:	00f60733          	add	a4,a2,a5
    800016a2:	76fd                	lui	a3,0xfffff
    800016a4:	8f75                	and	a4,a4,a3
    800016a6:	97ae                	add	a5,a5,a1
    800016a8:	8ff5                	and	a5,a5,a3
    800016aa:	00f76863          	bltu	a4,a5,800016ba <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800016ae:	8526                	mv	a0,s1
    800016b0:	60e2                	ld	ra,24(sp)
    800016b2:	6442                	ld	s0,16(sp)
    800016b4:	64a2                	ld	s1,8(sp)
    800016b6:	6105                	addi	sp,sp,32
    800016b8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800016ba:	8f99                	sub	a5,a5,a4
    800016bc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800016be:	4685                	li	a3,1
    800016c0:	0007861b          	sext.w	a2,a5
    800016c4:	85ba                	mv	a1,a4
    800016c6:	00000097          	auipc	ra,0x0
    800016ca:	e5e080e7          	jalr	-418(ra) # 80001524 <uvmunmap>
    800016ce:	b7c5                	j	800016ae <uvmdealloc+0x26>

00000000800016d0 <uvmalloc>:
  if(newsz < oldsz)
    800016d0:	0ab66563          	bltu	a2,a1,8000177a <uvmalloc+0xaa>
{
    800016d4:	7139                	addi	sp,sp,-64
    800016d6:	fc06                	sd	ra,56(sp)
    800016d8:	f822                	sd	s0,48(sp)
    800016da:	f426                	sd	s1,40(sp)
    800016dc:	f04a                	sd	s2,32(sp)
    800016de:	ec4e                	sd	s3,24(sp)
    800016e0:	e852                	sd	s4,16(sp)
    800016e2:	e456                	sd	s5,8(sp)
    800016e4:	e05a                	sd	s6,0(sp)
    800016e6:	0080                	addi	s0,sp,64
    800016e8:	8aaa                	mv	s5,a0
    800016ea:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800016ec:	6785                	lui	a5,0x1
    800016ee:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016f0:	95be                	add	a1,a1,a5
    800016f2:	77fd                	lui	a5,0xfffff
    800016f4:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016f8:	08c9f363          	bgeu	s3,a2,8000177e <uvmalloc+0xae>
    800016fc:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800016fe:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	60a080e7          	jalr	1546(ra) # 80000d0c <kalloc>
    8000170a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000170c:	c51d                	beqz	a0,8000173a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000170e:	6605                	lui	a2,0x1
    80001710:	4581                	li	a1,0
    80001712:	00000097          	auipc	ra,0x0
    80001716:	880080e7          	jalr	-1920(ra) # 80000f92 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000171a:	875a                	mv	a4,s6
    8000171c:	86a6                	mv	a3,s1
    8000171e:	6605                	lui	a2,0x1
    80001720:	85ca                	mv	a1,s2
    80001722:	8556                	mv	a0,s5
    80001724:	00000097          	auipc	ra,0x0
    80001728:	c3a080e7          	jalr	-966(ra) # 8000135e <mappages>
    8000172c:	e90d                	bnez	a0,8000175e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000172e:	6785                	lui	a5,0x1
    80001730:	993e                	add	s2,s2,a5
    80001732:	fd4968e3          	bltu	s2,s4,80001702 <uvmalloc+0x32>
  return newsz;
    80001736:	8552                	mv	a0,s4
    80001738:	a809                	j	8000174a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000173a:	864e                	mv	a2,s3
    8000173c:	85ca                	mv	a1,s2
    8000173e:	8556                	mv	a0,s5
    80001740:	00000097          	auipc	ra,0x0
    80001744:	f48080e7          	jalr	-184(ra) # 80001688 <uvmdealloc>
      return 0;
    80001748:	4501                	li	a0,0
}
    8000174a:	70e2                	ld	ra,56(sp)
    8000174c:	7442                	ld	s0,48(sp)
    8000174e:	74a2                	ld	s1,40(sp)
    80001750:	7902                	ld	s2,32(sp)
    80001752:	69e2                	ld	s3,24(sp)
    80001754:	6a42                	ld	s4,16(sp)
    80001756:	6aa2                	ld	s5,8(sp)
    80001758:	6b02                	ld	s6,0(sp)
    8000175a:	6121                	addi	sp,sp,64
    8000175c:	8082                	ret
      kfree(mem);
    8000175e:	8526                	mv	a0,s1
    80001760:	fffff097          	auipc	ra,0xfffff
    80001764:	3ba080e7          	jalr	954(ra) # 80000b1a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001768:	864e                	mv	a2,s3
    8000176a:	85ca                	mv	a1,s2
    8000176c:	8556                	mv	a0,s5
    8000176e:	00000097          	auipc	ra,0x0
    80001772:	f1a080e7          	jalr	-230(ra) # 80001688 <uvmdealloc>
      return 0;
    80001776:	4501                	li	a0,0
    80001778:	bfc9                	j	8000174a <uvmalloc+0x7a>
    return oldsz;
    8000177a:	852e                	mv	a0,a1
}
    8000177c:	8082                	ret
  return newsz;
    8000177e:	8532                	mv	a0,a2
    80001780:	b7e9                	j	8000174a <uvmalloc+0x7a>

0000000080001782 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001782:	7179                	addi	sp,sp,-48
    80001784:	f406                	sd	ra,40(sp)
    80001786:	f022                	sd	s0,32(sp)
    80001788:	ec26                	sd	s1,24(sp)
    8000178a:	e84a                	sd	s2,16(sp)
    8000178c:	e44e                	sd	s3,8(sp)
    8000178e:	e052                	sd	s4,0(sp)
    80001790:	1800                	addi	s0,sp,48
    80001792:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001794:	84aa                	mv	s1,a0
    80001796:	6905                	lui	s2,0x1
    80001798:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000179a:	4985                	li	s3,1
    8000179c:	a829                	j	800017b6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000179e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800017a0:	00c79513          	slli	a0,a5,0xc
    800017a4:	00000097          	auipc	ra,0x0
    800017a8:	fde080e7          	jalr	-34(ra) # 80001782 <freewalk>
      pagetable[i] = 0;
    800017ac:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800017b0:	04a1                	addi	s1,s1,8
    800017b2:	03248163          	beq	s1,s2,800017d4 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800017b6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800017b8:	00f7f713          	andi	a4,a5,15
    800017bc:	ff3701e3          	beq	a4,s3,8000179e <freewalk+0x1c>
    } else if(pte & PTE_V){
    800017c0:	8b85                	andi	a5,a5,1
    800017c2:	d7fd                	beqz	a5,800017b0 <freewalk+0x2e>
      panic("freewalk: leaf");
    800017c4:	00007517          	auipc	a0,0x7
    800017c8:	a1450513          	addi	a0,a0,-1516 # 800081d8 <digits+0x188>
    800017cc:	fffff097          	auipc	ra,0xfffff
    800017d0:	d74080e7          	jalr	-652(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    800017d4:	8552                	mv	a0,s4
    800017d6:	fffff097          	auipc	ra,0xfffff
    800017da:	344080e7          	jalr	836(ra) # 80000b1a <kfree>
}
    800017de:	70a2                	ld	ra,40(sp)
    800017e0:	7402                	ld	s0,32(sp)
    800017e2:	64e2                	ld	s1,24(sp)
    800017e4:	6942                	ld	s2,16(sp)
    800017e6:	69a2                	ld	s3,8(sp)
    800017e8:	6a02                	ld	s4,0(sp)
    800017ea:	6145                	addi	sp,sp,48
    800017ec:	8082                	ret

00000000800017ee <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800017ee:	1101                	addi	sp,sp,-32
    800017f0:	ec06                	sd	ra,24(sp)
    800017f2:	e822                	sd	s0,16(sp)
    800017f4:	e426                	sd	s1,8(sp)
    800017f6:	1000                	addi	s0,sp,32
    800017f8:	84aa                	mv	s1,a0
  if(sz > 0)
    800017fa:	e999                	bnez	a1,80001810 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800017fc:	8526                	mv	a0,s1
    800017fe:	00000097          	auipc	ra,0x0
    80001802:	f84080e7          	jalr	-124(ra) # 80001782 <freewalk>
}
    80001806:	60e2                	ld	ra,24(sp)
    80001808:	6442                	ld	s0,16(sp)
    8000180a:	64a2                	ld	s1,8(sp)
    8000180c:	6105                	addi	sp,sp,32
    8000180e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001810:	6785                	lui	a5,0x1
    80001812:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001814:	95be                	add	a1,a1,a5
    80001816:	4685                	li	a3,1
    80001818:	00c5d613          	srli	a2,a1,0xc
    8000181c:	4581                	li	a1,0
    8000181e:	00000097          	auipc	ra,0x0
    80001822:	d06080e7          	jalr	-762(ra) # 80001524 <uvmunmap>
    80001826:	bfd9                	j	800017fc <uvmfree+0xe>

0000000080001828 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001828:	c669                	beqz	a2,800018f2 <uvmcopy+0xca>
{
    8000182a:	7139                	addi	sp,sp,-64
    8000182c:	fc06                	sd	ra,56(sp)
    8000182e:	f822                	sd	s0,48(sp)
    80001830:	f426                	sd	s1,40(sp)
    80001832:	f04a                	sd	s2,32(sp)
    80001834:	ec4e                	sd	s3,24(sp)
    80001836:	e852                	sd	s4,16(sp)
    80001838:	e456                	sd	s5,8(sp)
    8000183a:	e05a                	sd	s6,0(sp)
    8000183c:	0080                	addi	s0,sp,64
    8000183e:	8b2a                	mv	s6,a0
    80001840:	8aae                	mv	s5,a1
    80001842:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001844:	4981                	li	s3,0
    80001846:	a091                	j	8000188a <uvmcopy+0x62>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    80001848:	00007517          	auipc	a0,0x7
    8000184c:	9a050513          	addi	a0,a0,-1632 # 800081e8 <digits+0x198>
    80001850:	fffff097          	auipc	ra,0xfffff
    80001854:	cf0080e7          	jalr	-784(ra) # 80000540 <panic>
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    80001858:	00007517          	auipc	a0,0x7
    8000185c:	9b050513          	addi	a0,a0,-1616 # 80008208 <digits+0x1b8>
    80001860:	fffff097          	auipc	ra,0xfffff
    80001864:	ce0080e7          	jalr	-800(ra) # 80000540 <panic>
    {
	*pte &= ~PTE_W; // remove write access
	*pte |= PTE_COW; // set copy on write
    }
    
    flags = PTE_FLAGS(*pte);
    80001868:	00093703          	ld	a4,0(s2) # 1000 <_entry-0x7ffff000>

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    8000186c:	3ff77713          	andi	a4,a4,1023
    80001870:	86a6                	mv	a3,s1
    80001872:	6605                	lui	a2,0x1
    80001874:	85ce                	mv	a1,s3
    80001876:	8556                	mv	a0,s5
    80001878:	00000097          	auipc	ra,0x0
    8000187c:	ae6080e7          	jalr	-1306(ra) # 8000135e <mappages>
    80001880:	e529                	bnez	a0,800018ca <uvmcopy+0xa2>
  for(i = 0; i < sz; i += PGSIZE){
    80001882:	6785                	lui	a5,0x1
    80001884:	99be                	add	s3,s3,a5
    80001886:	0549fc63          	bgeu	s3,s4,800018de <uvmcopy+0xb6>
    if((pte = walk(old, i, 0)) == 0)
    8000188a:	4601                	li	a2,0
    8000188c:	85ce                	mv	a1,s3
    8000188e:	855a                	mv	a0,s6
    80001890:	00000097          	auipc	ra,0x0
    80001894:	9e6080e7          	jalr	-1562(ra) # 80001276 <walk>
    80001898:	892a                	mv	s2,a0
    8000189a:	d55d                	beqz	a0,80001848 <uvmcopy+0x20>
    if((*pte & PTE_V) == 0)
    8000189c:	6114                	ld	a3,0(a0)
    8000189e:	0016f793          	andi	a5,a3,1
    800018a2:	dbdd                	beqz	a5,80001858 <uvmcopy+0x30>
    pa = PTE2PA(*pte);
    800018a4:	82a9                	srli	a3,a3,0xa
    800018a6:	00c69493          	slli	s1,a3,0xc
    increfcount(pa);
    800018aa:	8526                	mv	a0,s1
    800018ac:	fffff097          	auipc	ra,0xfffff
    800018b0:	21c080e7          	jalr	540(ra) # 80000ac8 <increfcount>
    if (*pte & PTE_W)
    800018b4:	00093783          	ld	a5,0(s2)
    800018b8:	0047f713          	andi	a4,a5,4
    800018bc:	d755                	beqz	a4,80001868 <uvmcopy+0x40>
	*pte &= ~PTE_W; // remove write access
    800018be:	9bed                	andi	a5,a5,-5
	*pte |= PTE_COW; // set copy on write
    800018c0:	2007e793          	ori	a5,a5,512
    800018c4:	00f93023          	sd	a5,0(s2)
    800018c8:	b745                	j	80001868 <uvmcopy+0x40>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800018ca:	4685                	li	a3,1
    800018cc:	00c9d613          	srli	a2,s3,0xc
    800018d0:	4581                	li	a1,0
    800018d2:	8556                	mv	a0,s5
    800018d4:	00000097          	auipc	ra,0x0
    800018d8:	c50080e7          	jalr	-944(ra) # 80001524 <uvmunmap>
  return -1;
    800018dc:	557d                	li	a0,-1
}
    800018de:	70e2                	ld	ra,56(sp)
    800018e0:	7442                	ld	s0,48(sp)
    800018e2:	74a2                	ld	s1,40(sp)
    800018e4:	7902                	ld	s2,32(sp)
    800018e6:	69e2                	ld	s3,24(sp)
    800018e8:	6a42                	ld	s4,16(sp)
    800018ea:	6aa2                	ld	s5,8(sp)
    800018ec:	6b02                	ld	s6,0(sp)
    800018ee:	6121                	addi	sp,sp,64
    800018f0:	8082                	ret
  return 0;
    800018f2:	4501                	li	a0,0
}
    800018f4:	8082                	ret

00000000800018f6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800018f6:	1141                	addi	sp,sp,-16
    800018f8:	e406                	sd	ra,8(sp)
    800018fa:	e022                	sd	s0,0(sp)
    800018fc:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800018fe:	4601                	li	a2,0
    80001900:	00000097          	auipc	ra,0x0
    80001904:	976080e7          	jalr	-1674(ra) # 80001276 <walk>
  if(pte == 0)
    80001908:	c901                	beqz	a0,80001918 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000190a:	611c                	ld	a5,0(a0)
    8000190c:	9bbd                	andi	a5,a5,-17
    8000190e:	e11c                	sd	a5,0(a0)
}
    80001910:	60a2                	ld	ra,8(sp)
    80001912:	6402                	ld	s0,0(sp)
    80001914:	0141                	addi	sp,sp,16
    80001916:	8082                	ret
    panic("uvmclear");
    80001918:	00007517          	auipc	a0,0x7
    8000191c:	91050513          	addi	a0,a0,-1776 # 80008228 <digits+0x1d8>
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	c20080e7          	jalr	-992(ra) # 80000540 <panic>

0000000080001928 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001928:	c6bd                	beqz	a3,80001996 <copyout+0x6e>
{
    8000192a:	715d                	addi	sp,sp,-80
    8000192c:	e486                	sd	ra,72(sp)
    8000192e:	e0a2                	sd	s0,64(sp)
    80001930:	fc26                	sd	s1,56(sp)
    80001932:	f84a                	sd	s2,48(sp)
    80001934:	f44e                	sd	s3,40(sp)
    80001936:	f052                	sd	s4,32(sp)
    80001938:	ec56                	sd	s5,24(sp)
    8000193a:	e85a                	sd	s6,16(sp)
    8000193c:	e45e                	sd	s7,8(sp)
    8000193e:	e062                	sd	s8,0(sp)
    80001940:	0880                	addi	s0,sp,80
    80001942:	8b2a                	mv	s6,a0
    80001944:	8c2e                	mv	s8,a1
    80001946:	8a32                	mv	s4,a2
    80001948:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000194a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000194c:	6a85                	lui	s5,0x1
    8000194e:	a015                	j	80001972 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001950:	9562                	add	a0,a0,s8
    80001952:	0004861b          	sext.w	a2,s1
    80001956:	85d2                	mv	a1,s4
    80001958:	41250533          	sub	a0,a0,s2
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	692080e7          	jalr	1682(ra) # 80000fee <memmove>

    len -= n;
    80001964:	409989b3          	sub	s3,s3,s1
    src += n;
    80001968:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000196a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000196e:	02098263          	beqz	s3,80001992 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001972:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001976:	85ca                	mv	a1,s2
    80001978:	855a                	mv	a0,s6
    8000197a:	00000097          	auipc	ra,0x0
    8000197e:	9a2080e7          	jalr	-1630(ra) # 8000131c <walkaddr>
    if(pa0 == 0)
    80001982:	cd01                	beqz	a0,8000199a <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001984:	418904b3          	sub	s1,s2,s8
    80001988:	94d6                	add	s1,s1,s5
    8000198a:	fc99f3e3          	bgeu	s3,s1,80001950 <copyout+0x28>
    8000198e:	84ce                	mv	s1,s3
    80001990:	b7c1                	j	80001950 <copyout+0x28>
  }
  return 0;
    80001992:	4501                	li	a0,0
    80001994:	a021                	j	8000199c <copyout+0x74>
    80001996:	4501                	li	a0,0
}
    80001998:	8082                	ret
      return -1;
    8000199a:	557d                	li	a0,-1
}
    8000199c:	60a6                	ld	ra,72(sp)
    8000199e:	6406                	ld	s0,64(sp)
    800019a0:	74e2                	ld	s1,56(sp)
    800019a2:	7942                	ld	s2,48(sp)
    800019a4:	79a2                	ld	s3,40(sp)
    800019a6:	7a02                	ld	s4,32(sp)
    800019a8:	6ae2                	ld	s5,24(sp)
    800019aa:	6b42                	ld	s6,16(sp)
    800019ac:	6ba2                	ld	s7,8(sp)
    800019ae:	6c02                	ld	s8,0(sp)
    800019b0:	6161                	addi	sp,sp,80
    800019b2:	8082                	ret

00000000800019b4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800019b4:	caa5                	beqz	a3,80001a24 <copyin+0x70>
{
    800019b6:	715d                	addi	sp,sp,-80
    800019b8:	e486                	sd	ra,72(sp)
    800019ba:	e0a2                	sd	s0,64(sp)
    800019bc:	fc26                	sd	s1,56(sp)
    800019be:	f84a                	sd	s2,48(sp)
    800019c0:	f44e                	sd	s3,40(sp)
    800019c2:	f052                	sd	s4,32(sp)
    800019c4:	ec56                	sd	s5,24(sp)
    800019c6:	e85a                	sd	s6,16(sp)
    800019c8:	e45e                	sd	s7,8(sp)
    800019ca:	e062                	sd	s8,0(sp)
    800019cc:	0880                	addi	s0,sp,80
    800019ce:	8b2a                	mv	s6,a0
    800019d0:	8a2e                	mv	s4,a1
    800019d2:	8c32                	mv	s8,a2
    800019d4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800019d6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019d8:	6a85                	lui	s5,0x1
    800019da:	a01d                	j	80001a00 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800019dc:	018505b3          	add	a1,a0,s8
    800019e0:	0004861b          	sext.w	a2,s1
    800019e4:	412585b3          	sub	a1,a1,s2
    800019e8:	8552                	mv	a0,s4
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	604080e7          	jalr	1540(ra) # 80000fee <memmove>

    len -= n;
    800019f2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800019f6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800019f8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800019fc:	02098263          	beqz	s3,80001a20 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001a00:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a04:	85ca                	mv	a1,s2
    80001a06:	855a                	mv	a0,s6
    80001a08:	00000097          	auipc	ra,0x0
    80001a0c:	914080e7          	jalr	-1772(ra) # 8000131c <walkaddr>
    if(pa0 == 0)
    80001a10:	cd01                	beqz	a0,80001a28 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001a12:	418904b3          	sub	s1,s2,s8
    80001a16:	94d6                	add	s1,s1,s5
    80001a18:	fc99f2e3          	bgeu	s3,s1,800019dc <copyin+0x28>
    80001a1c:	84ce                	mv	s1,s3
    80001a1e:	bf7d                	j	800019dc <copyin+0x28>
  }
  return 0;
    80001a20:	4501                	li	a0,0
    80001a22:	a021                	j	80001a2a <copyin+0x76>
    80001a24:	4501                	li	a0,0
}
    80001a26:	8082                	ret
      return -1;
    80001a28:	557d                	li	a0,-1
}
    80001a2a:	60a6                	ld	ra,72(sp)
    80001a2c:	6406                	ld	s0,64(sp)
    80001a2e:	74e2                	ld	s1,56(sp)
    80001a30:	7942                	ld	s2,48(sp)
    80001a32:	79a2                	ld	s3,40(sp)
    80001a34:	7a02                	ld	s4,32(sp)
    80001a36:	6ae2                	ld	s5,24(sp)
    80001a38:	6b42                	ld	s6,16(sp)
    80001a3a:	6ba2                	ld	s7,8(sp)
    80001a3c:	6c02                	ld	s8,0(sp)
    80001a3e:	6161                	addi	sp,sp,80
    80001a40:	8082                	ret

0000000080001a42 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001a42:	c2dd                	beqz	a3,80001ae8 <copyinstr+0xa6>
{
    80001a44:	715d                	addi	sp,sp,-80
    80001a46:	e486                	sd	ra,72(sp)
    80001a48:	e0a2                	sd	s0,64(sp)
    80001a4a:	fc26                	sd	s1,56(sp)
    80001a4c:	f84a                	sd	s2,48(sp)
    80001a4e:	f44e                	sd	s3,40(sp)
    80001a50:	f052                	sd	s4,32(sp)
    80001a52:	ec56                	sd	s5,24(sp)
    80001a54:	e85a                	sd	s6,16(sp)
    80001a56:	e45e                	sd	s7,8(sp)
    80001a58:	0880                	addi	s0,sp,80
    80001a5a:	8a2a                	mv	s4,a0
    80001a5c:	8b2e                	mv	s6,a1
    80001a5e:	8bb2                	mv	s7,a2
    80001a60:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001a62:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a64:	6985                	lui	s3,0x1
    80001a66:	a02d                	j	80001a90 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a68:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001a6c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a6e:	37fd                	addiw	a5,a5,-1
    80001a70:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a74:	60a6                	ld	ra,72(sp)
    80001a76:	6406                	ld	s0,64(sp)
    80001a78:	74e2                	ld	s1,56(sp)
    80001a7a:	7942                	ld	s2,48(sp)
    80001a7c:	79a2                	ld	s3,40(sp)
    80001a7e:	7a02                	ld	s4,32(sp)
    80001a80:	6ae2                	ld	s5,24(sp)
    80001a82:	6b42                	ld	s6,16(sp)
    80001a84:	6ba2                	ld	s7,8(sp)
    80001a86:	6161                	addi	sp,sp,80
    80001a88:	8082                	ret
    srcva = va0 + PGSIZE;
    80001a8a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001a8e:	c8a9                	beqz	s1,80001ae0 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001a90:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001a94:	85ca                	mv	a1,s2
    80001a96:	8552                	mv	a0,s4
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	884080e7          	jalr	-1916(ra) # 8000131c <walkaddr>
    if(pa0 == 0)
    80001aa0:	c131                	beqz	a0,80001ae4 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001aa2:	417906b3          	sub	a3,s2,s7
    80001aa6:	96ce                	add	a3,a3,s3
    80001aa8:	00d4f363          	bgeu	s1,a3,80001aae <copyinstr+0x6c>
    80001aac:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001aae:	955e                	add	a0,a0,s7
    80001ab0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001ab4:	daf9                	beqz	a3,80001a8a <copyinstr+0x48>
    80001ab6:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001ab8:	41650633          	sub	a2,a0,s6
    80001abc:	fff48593          	addi	a1,s1,-1
    80001ac0:	95da                	add	a1,a1,s6
    while(n > 0){
    80001ac2:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001ac4:	00f60733          	add	a4,a2,a5
    80001ac8:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd0e8>
    80001acc:	df51                	beqz	a4,80001a68 <copyinstr+0x26>
        *dst = *p;
    80001ace:	00e78023          	sb	a4,0(a5)
      --max;
    80001ad2:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001ad6:	0785                	addi	a5,a5,1
    while(n > 0){
    80001ad8:	fed796e3          	bne	a5,a3,80001ac4 <copyinstr+0x82>
      dst++;
    80001adc:	8b3e                	mv	s6,a5
    80001ade:	b775                	j	80001a8a <copyinstr+0x48>
    80001ae0:	4781                	li	a5,0
    80001ae2:	b771                	j	80001a6e <copyinstr+0x2c>
      return -1;
    80001ae4:	557d                	li	a0,-1
    80001ae6:	b779                	j	80001a74 <copyinstr+0x32>
  int got_null = 0;
    80001ae8:	4781                	li	a5,0
  if(got_null){
    80001aea:	37fd                	addiw	a5,a5,-1
    80001aec:	0007851b          	sext.w	a0,a5
}
    80001af0:	8082                	ret

0000000080001af2 <transvirt>:

uint64 transvirt(uint64 vaddr, pagetable_t pagetable)
{
    80001af2:	1141                	addi	sp,sp,-16
    80001af4:	e422                	sd	s0,8(sp)
    80001af6:	0800                	addi	s0,sp,16
    80001af8:	872a                	mv	a4,a0
    for (int level = 2; level > 0; level--)
    {
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001afa:	01e55793          	srli	a5,a0,0x1e
    80001afe:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001b02:	078e                	slli	a5,a5,0x3
    80001b04:	95be                	add	a1,a1,a5
    80001b06:	619c                	ld	a5,0(a1)
    80001b08:	0017f513          	andi	a0,a5,1
    80001b0c:	cd15                	beqz	a0,80001b48 <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001b0e:	83a9                	srli	a5,a5,0xa
    80001b10:	00c79693          	slli	a3,a5,0xc
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001b14:	01575793          	srli	a5,a4,0x15
    80001b18:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001b1c:	078e                	slli	a5,a5,0x3
    80001b1e:	97b6                	add	a5,a5,a3
    80001b20:	639c                	ld	a5,0(a5)
    80001b22:	0017f513          	andi	a0,a5,1
    80001b26:	c10d                	beqz	a0,80001b48 <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001b28:	83a9                	srli	a5,a5,0xa
    80001b2a:	00c79693          	slli	a3,a5,0xc
	} else {
	    return 0;
	}
    }
    uint64 pagenum = PTE2PA(pagetable[PX(0, vaddr)]);
    80001b2e:	00c75793          	srli	a5,a4,0xc
    80001b32:	1ff7f793          	andi	a5,a5,511
    80001b36:	078e                	slli	a5,a5,0x3
    80001b38:	97b6                	add	a5,a5,a3
    80001b3a:	639c                	ld	a5,0(a5)
    80001b3c:	83a9                	srli	a5,a5,0xa
    80001b3e:	07b2                	slli	a5,a5,0xc
    uint64 offset = vaddr & 0xFFF;
    80001b40:	1752                	slli	a4,a4,0x34
    80001b42:	9351                	srli	a4,a4,0x34
    return pagenum | offset;
    80001b44:	00e7e533          	or	a0,a5,a4
}
    80001b48:	6422                	ld	s0,8(sp)
    80001b4a:	0141                	addi	sp,sp,16
    80001b4c:	8082                	ret

0000000080001b4e <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001b4e:	715d                	addi	sp,sp,-80
    80001b50:	e486                	sd	ra,72(sp)
    80001b52:	e0a2                	sd	s0,64(sp)
    80001b54:	fc26                	sd	s1,56(sp)
    80001b56:	f84a                	sd	s2,48(sp)
    80001b58:	f44e                	sd	s3,40(sp)
    80001b5a:	f052                	sd	s4,32(sp)
    80001b5c:	ec56                	sd	s5,24(sp)
    80001b5e:	e85a                	sd	s6,16(sp)
    80001b60:	e45e                	sd	s7,8(sp)
    80001b62:	e062                	sd	s8,0(sp)
    80001b64:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001b66:	8792                	mv	a5,tp
    int id = r_tp();
    80001b68:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001b6a:	0002fa97          	auipc	s5,0x2f
    80001b6e:	19ea8a93          	addi	s5,s5,414 # 80030d08 <cpus>
    80001b72:	00779713          	slli	a4,a5,0x7
    80001b76:	00ea86b3          	add	a3,s5,a4
    80001b7a:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffbd0e8>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001b7e:	0721                	addi	a4,a4,8
    80001b80:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001b82:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001b84:	00007c17          	auipc	s8,0x7
    80001b88:	e24c0c13          	addi	s8,s8,-476 # 800089a8 <sched_pointer>
    80001b8c:	00000b97          	auipc	s7,0x0
    80001b90:	fc2b8b93          	addi	s7,s7,-62 # 80001b4e <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001b94:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001b98:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001b9c:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001ba0:	0002f497          	auipc	s1,0x2f
    80001ba4:	59848493          	addi	s1,s1,1432 # 80031138 <proc>
            if (p->state == RUNNABLE)
    80001ba8:	498d                	li	s3,3
                p->state = RUNNING;
    80001baa:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001bac:	00035a17          	auipc	s4,0x35
    80001bb0:	f8ca0a13          	addi	s4,s4,-116 # 80036b38 <tickslock>
    80001bb4:	a81d                	j	80001bea <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	392080e7          	jalr	914(ra) # 80000f4a <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001bc0:	60a6                	ld	ra,72(sp)
    80001bc2:	6406                	ld	s0,64(sp)
    80001bc4:	74e2                	ld	s1,56(sp)
    80001bc6:	7942                	ld	s2,48(sp)
    80001bc8:	79a2                	ld	s3,40(sp)
    80001bca:	7a02                	ld	s4,32(sp)
    80001bcc:	6ae2                	ld	s5,24(sp)
    80001bce:	6b42                	ld	s6,16(sp)
    80001bd0:	6ba2                	ld	s7,8(sp)
    80001bd2:	6c02                	ld	s8,0(sp)
    80001bd4:	6161                	addi	sp,sp,80
    80001bd6:	8082                	ret
            release(&p->lock);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	370080e7          	jalr	880(ra) # 80000f4a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001be2:	16848493          	addi	s1,s1,360
    80001be6:	fb4487e3          	beq	s1,s4,80001b94 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001bea:	8526                	mv	a0,s1
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	2aa080e7          	jalr	682(ra) # 80000e96 <acquire>
            if (p->state == RUNNABLE)
    80001bf4:	4c9c                	lw	a5,24(s1)
    80001bf6:	ff3791e3          	bne	a5,s3,80001bd8 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001bfa:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001bfe:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001c02:	06048593          	addi	a1,s1,96
    80001c06:	8556                	mv	a0,s5
    80001c08:	00001097          	auipc	ra,0x1
    80001c0c:	024080e7          	jalr	36(ra) # 80002c2c <swtch>
                if (sched_pointer != &rr_scheduler)
    80001c10:	000c3783          	ld	a5,0(s8)
    80001c14:	fb7791e3          	bne	a5,s7,80001bb6 <rr_scheduler+0x68>
                c->proc = 0;
    80001c18:	00093023          	sd	zero,0(s2)
    80001c1c:	bf75                	j	80001bd8 <rr_scheduler+0x8a>

0000000080001c1e <proc_mapstacks>:
{
    80001c1e:	7139                	addi	sp,sp,-64
    80001c20:	fc06                	sd	ra,56(sp)
    80001c22:	f822                	sd	s0,48(sp)
    80001c24:	f426                	sd	s1,40(sp)
    80001c26:	f04a                	sd	s2,32(sp)
    80001c28:	ec4e                	sd	s3,24(sp)
    80001c2a:	e852                	sd	s4,16(sp)
    80001c2c:	e456                	sd	s5,8(sp)
    80001c2e:	e05a                	sd	s6,0(sp)
    80001c30:	0080                	addi	s0,sp,64
    80001c32:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001c34:	0002f497          	auipc	s1,0x2f
    80001c38:	50448493          	addi	s1,s1,1284 # 80031138 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001c3c:	8b26                	mv	s6,s1
    80001c3e:	00006a97          	auipc	s5,0x6
    80001c42:	3d2a8a93          	addi	s5,s5,978 # 80008010 <__func__.1+0x8>
    80001c46:	04000937          	lui	s2,0x4000
    80001c4a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001c4c:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001c4e:	00035a17          	auipc	s4,0x35
    80001c52:	eeaa0a13          	addi	s4,s4,-278 # 80036b38 <tickslock>
        char *pa = kalloc();
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	0b6080e7          	jalr	182(ra) # 80000d0c <kalloc>
    80001c5e:	862a                	mv	a2,a0
        if (pa == 0)
    80001c60:	c131                	beqz	a0,80001ca4 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001c62:	416485b3          	sub	a1,s1,s6
    80001c66:	858d                	srai	a1,a1,0x3
    80001c68:	000ab783          	ld	a5,0(s5)
    80001c6c:	02f585b3          	mul	a1,a1,a5
    80001c70:	2585                	addiw	a1,a1,1
    80001c72:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c76:	4719                	li	a4,6
    80001c78:	6685                	lui	a3,0x1
    80001c7a:	40b905b3          	sub	a1,s2,a1
    80001c7e:	854e                	mv	a0,s3
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	77e080e7          	jalr	1918(ra) # 800013fe <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001c88:	16848493          	addi	s1,s1,360
    80001c8c:	fd4495e3          	bne	s1,s4,80001c56 <proc_mapstacks+0x38>
}
    80001c90:	70e2                	ld	ra,56(sp)
    80001c92:	7442                	ld	s0,48(sp)
    80001c94:	74a2                	ld	s1,40(sp)
    80001c96:	7902                	ld	s2,32(sp)
    80001c98:	69e2                	ld	s3,24(sp)
    80001c9a:	6a42                	ld	s4,16(sp)
    80001c9c:	6aa2                	ld	s5,8(sp)
    80001c9e:	6b02                	ld	s6,0(sp)
    80001ca0:	6121                	addi	sp,sp,64
    80001ca2:	8082                	ret
            panic("kalloc");
    80001ca4:	00006517          	auipc	a0,0x6
    80001ca8:	59450513          	addi	a0,a0,1428 # 80008238 <digits+0x1e8>
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	894080e7          	jalr	-1900(ra) # 80000540 <panic>

0000000080001cb4 <procinit>:
{
    80001cb4:	7139                	addi	sp,sp,-64
    80001cb6:	fc06                	sd	ra,56(sp)
    80001cb8:	f822                	sd	s0,48(sp)
    80001cba:	f426                	sd	s1,40(sp)
    80001cbc:	f04a                	sd	s2,32(sp)
    80001cbe:	ec4e                	sd	s3,24(sp)
    80001cc0:	e852                	sd	s4,16(sp)
    80001cc2:	e456                	sd	s5,8(sp)
    80001cc4:	e05a                	sd	s6,0(sp)
    80001cc6:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001cc8:	00006597          	auipc	a1,0x6
    80001ccc:	57858593          	addi	a1,a1,1400 # 80008240 <digits+0x1f0>
    80001cd0:	0002f517          	auipc	a0,0x2f
    80001cd4:	43850513          	addi	a0,a0,1080 # 80031108 <pid_lock>
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	12e080e7          	jalr	302(ra) # 80000e06 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001ce0:	00006597          	auipc	a1,0x6
    80001ce4:	56858593          	addi	a1,a1,1384 # 80008248 <digits+0x1f8>
    80001ce8:	0002f517          	auipc	a0,0x2f
    80001cec:	43850513          	addi	a0,a0,1080 # 80031120 <wait_lock>
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	116080e7          	jalr	278(ra) # 80000e06 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001cf8:	0002f497          	auipc	s1,0x2f
    80001cfc:	44048493          	addi	s1,s1,1088 # 80031138 <proc>
        initlock(&p->lock, "proc");
    80001d00:	00006b17          	auipc	s6,0x6
    80001d04:	558b0b13          	addi	s6,s6,1368 # 80008258 <digits+0x208>
        p->kstack = KSTACK((int)(p - proc));
    80001d08:	8aa6                	mv	s5,s1
    80001d0a:	00006a17          	auipc	s4,0x6
    80001d0e:	306a0a13          	addi	s4,s4,774 # 80008010 <__func__.1+0x8>
    80001d12:	04000937          	lui	s2,0x4000
    80001d16:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001d18:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001d1a:	00035997          	auipc	s3,0x35
    80001d1e:	e1e98993          	addi	s3,s3,-482 # 80036b38 <tickslock>
        initlock(&p->lock, "proc");
    80001d22:	85da                	mv	a1,s6
    80001d24:	8526                	mv	a0,s1
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	0e0080e7          	jalr	224(ra) # 80000e06 <initlock>
        p->state = UNUSED;
    80001d2e:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001d32:	415487b3          	sub	a5,s1,s5
    80001d36:	878d                	srai	a5,a5,0x3
    80001d38:	000a3703          	ld	a4,0(s4)
    80001d3c:	02e787b3          	mul	a5,a5,a4
    80001d40:	2785                	addiw	a5,a5,1
    80001d42:	00d7979b          	slliw	a5,a5,0xd
    80001d46:	40f907b3          	sub	a5,s2,a5
    80001d4a:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001d4c:	16848493          	addi	s1,s1,360
    80001d50:	fd3499e3          	bne	s1,s3,80001d22 <procinit+0x6e>
}
    80001d54:	70e2                	ld	ra,56(sp)
    80001d56:	7442                	ld	s0,48(sp)
    80001d58:	74a2                	ld	s1,40(sp)
    80001d5a:	7902                	ld	s2,32(sp)
    80001d5c:	69e2                	ld	s3,24(sp)
    80001d5e:	6a42                	ld	s4,16(sp)
    80001d60:	6aa2                	ld	s5,8(sp)
    80001d62:	6b02                	ld	s6,0(sp)
    80001d64:	6121                	addi	sp,sp,64
    80001d66:	8082                	ret

0000000080001d68 <copy_array>:
{
    80001d68:	1141                	addi	sp,sp,-16
    80001d6a:	e422                	sd	s0,8(sp)
    80001d6c:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001d6e:	02c05163          	blez	a2,80001d90 <copy_array+0x28>
    80001d72:	87aa                	mv	a5,a0
    80001d74:	0505                	addi	a0,a0,1
    80001d76:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001d78:	1602                	slli	a2,a2,0x20
    80001d7a:	9201                	srli	a2,a2,0x20
    80001d7c:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001d80:	0007c703          	lbu	a4,0(a5)
    80001d84:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001d88:	0785                	addi	a5,a5,1
    80001d8a:	0585                	addi	a1,a1,1
    80001d8c:	fed79ae3          	bne	a5,a3,80001d80 <copy_array+0x18>
}
    80001d90:	6422                	ld	s0,8(sp)
    80001d92:	0141                	addi	sp,sp,16
    80001d94:	8082                	ret

0000000080001d96 <cpuid>:
{
    80001d96:	1141                	addi	sp,sp,-16
    80001d98:	e422                	sd	s0,8(sp)
    80001d9a:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001d9c:	8512                	mv	a0,tp
}
    80001d9e:	2501                	sext.w	a0,a0
    80001da0:	6422                	ld	s0,8(sp)
    80001da2:	0141                	addi	sp,sp,16
    80001da4:	8082                	ret

0000000080001da6 <mycpu>:
{
    80001da6:	1141                	addi	sp,sp,-16
    80001da8:	e422                	sd	s0,8(sp)
    80001daa:	0800                	addi	s0,sp,16
    80001dac:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001dae:	2781                	sext.w	a5,a5
    80001db0:	079e                	slli	a5,a5,0x7
}
    80001db2:	0002f517          	auipc	a0,0x2f
    80001db6:	f5650513          	addi	a0,a0,-170 # 80030d08 <cpus>
    80001dba:	953e                	add	a0,a0,a5
    80001dbc:	6422                	ld	s0,8(sp)
    80001dbe:	0141                	addi	sp,sp,16
    80001dc0:	8082                	ret

0000000080001dc2 <myproc>:
{
    80001dc2:	1101                	addi	sp,sp,-32
    80001dc4:	ec06                	sd	ra,24(sp)
    80001dc6:	e822                	sd	s0,16(sp)
    80001dc8:	e426                	sd	s1,8(sp)
    80001dca:	1000                	addi	s0,sp,32
    push_off();
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	07e080e7          	jalr	126(ra) # 80000e4a <push_off>
    80001dd4:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001dd6:	2781                	sext.w	a5,a5
    80001dd8:	079e                	slli	a5,a5,0x7
    80001dda:	0002f717          	auipc	a4,0x2f
    80001dde:	f2e70713          	addi	a4,a4,-210 # 80030d08 <cpus>
    80001de2:	97ba                	add	a5,a5,a4
    80001de4:	6384                	ld	s1,0(a5)
    pop_off();
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	104080e7          	jalr	260(ra) # 80000eea <pop_off>
}
    80001dee:	8526                	mv	a0,s1
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6105                	addi	sp,sp,32
    80001df8:	8082                	ret

0000000080001dfa <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001dfa:	1141                	addi	sp,sp,-16
    80001dfc:	e406                	sd	ra,8(sp)
    80001dfe:	e022                	sd	s0,0(sp)
    80001e00:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	fc0080e7          	jalr	-64(ra) # 80001dc2 <myproc>
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	140080e7          	jalr	320(ra) # 80000f4a <release>

    if (first)
    80001e12:	00007797          	auipc	a5,0x7
    80001e16:	b8e7a783          	lw	a5,-1138(a5) # 800089a0 <first.1>
    80001e1a:	eb89                	bnez	a5,80001e2c <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001e1c:	00001097          	auipc	ra,0x1
    80001e20:	eba080e7          	jalr	-326(ra) # 80002cd6 <usertrapret>
}
    80001e24:	60a2                	ld	ra,8(sp)
    80001e26:	6402                	ld	s0,0(sp)
    80001e28:	0141                	addi	sp,sp,16
    80001e2a:	8082                	ret
        first = 0;
    80001e2c:	00007797          	auipc	a5,0x7
    80001e30:	b607aa23          	sw	zero,-1164(a5) # 800089a0 <first.1>
        fsinit(ROOTDEV);
    80001e34:	4505                	li	a0,1
    80001e36:	00002097          	auipc	ra,0x2
    80001e3a:	dec080e7          	jalr	-532(ra) # 80003c22 <fsinit>
    80001e3e:	bff9                	j	80001e1c <forkret+0x22>

0000000080001e40 <allocpid>:
{
    80001e40:	1101                	addi	sp,sp,-32
    80001e42:	ec06                	sd	ra,24(sp)
    80001e44:	e822                	sd	s0,16(sp)
    80001e46:	e426                	sd	s1,8(sp)
    80001e48:	e04a                	sd	s2,0(sp)
    80001e4a:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001e4c:	0002f917          	auipc	s2,0x2f
    80001e50:	2bc90913          	addi	s2,s2,700 # 80031108 <pid_lock>
    80001e54:	854a                	mv	a0,s2
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	040080e7          	jalr	64(ra) # 80000e96 <acquire>
    pid = nextpid;
    80001e5e:	00007797          	auipc	a5,0x7
    80001e62:	b5278793          	addi	a5,a5,-1198 # 800089b0 <nextpid>
    80001e66:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001e68:	0014871b          	addiw	a4,s1,1
    80001e6c:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001e6e:	854a                	mv	a0,s2
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	0da080e7          	jalr	218(ra) # 80000f4a <release>
}
    80001e78:	8526                	mv	a0,s1
    80001e7a:	60e2                	ld	ra,24(sp)
    80001e7c:	6442                	ld	s0,16(sp)
    80001e7e:	64a2                	ld	s1,8(sp)
    80001e80:	6902                	ld	s2,0(sp)
    80001e82:	6105                	addi	sp,sp,32
    80001e84:	8082                	ret

0000000080001e86 <proc_pagetable>:
{
    80001e86:	1101                	addi	sp,sp,-32
    80001e88:	ec06                	sd	ra,24(sp)
    80001e8a:	e822                	sd	s0,16(sp)
    80001e8c:	e426                	sd	s1,8(sp)
    80001e8e:	e04a                	sd	s2,0(sp)
    80001e90:	1000                	addi	s0,sp,32
    80001e92:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	754080e7          	jalr	1876(ra) # 800015e8 <uvmcreate>
    80001e9c:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001e9e:	c121                	beqz	a0,80001ede <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ea0:	4729                	li	a4,10
    80001ea2:	00005697          	auipc	a3,0x5
    80001ea6:	15e68693          	addi	a3,a3,350 # 80007000 <_trampoline>
    80001eaa:	6605                	lui	a2,0x1
    80001eac:	040005b7          	lui	a1,0x4000
    80001eb0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001eb2:	05b2                	slli	a1,a1,0xc
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	4aa080e7          	jalr	1194(ra) # 8000135e <mappages>
    80001ebc:	02054863          	bltz	a0,80001eec <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ec0:	4719                	li	a4,6
    80001ec2:	05893683          	ld	a3,88(s2)
    80001ec6:	6605                	lui	a2,0x1
    80001ec8:	020005b7          	lui	a1,0x2000
    80001ecc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ece:	05b6                	slli	a1,a1,0xd
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	48c080e7          	jalr	1164(ra) # 8000135e <mappages>
    80001eda:	02054163          	bltz	a0,80001efc <proc_pagetable+0x76>
}
    80001ede:	8526                	mv	a0,s1
    80001ee0:	60e2                	ld	ra,24(sp)
    80001ee2:	6442                	ld	s0,16(sp)
    80001ee4:	64a2                	ld	s1,8(sp)
    80001ee6:	6902                	ld	s2,0(sp)
    80001ee8:	6105                	addi	sp,sp,32
    80001eea:	8082                	ret
        uvmfree(pagetable, 0);
    80001eec:	4581                	li	a1,0
    80001eee:	8526                	mv	a0,s1
    80001ef0:	00000097          	auipc	ra,0x0
    80001ef4:	8fe080e7          	jalr	-1794(ra) # 800017ee <uvmfree>
        return 0;
    80001ef8:	4481                	li	s1,0
    80001efa:	b7d5                	j	80001ede <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001efc:	4681                	li	a3,0
    80001efe:	4605                	li	a2,1
    80001f00:	040005b7          	lui	a1,0x4000
    80001f04:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f06:	05b2                	slli	a1,a1,0xc
    80001f08:	8526                	mv	a0,s1
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	61a080e7          	jalr	1562(ra) # 80001524 <uvmunmap>
        uvmfree(pagetable, 0);
    80001f12:	4581                	li	a1,0
    80001f14:	8526                	mv	a0,s1
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	8d8080e7          	jalr	-1832(ra) # 800017ee <uvmfree>
        return 0;
    80001f1e:	4481                	li	s1,0
    80001f20:	bf7d                	j	80001ede <proc_pagetable+0x58>

0000000080001f22 <proc_freepagetable>:
{
    80001f22:	1101                	addi	sp,sp,-32
    80001f24:	ec06                	sd	ra,24(sp)
    80001f26:	e822                	sd	s0,16(sp)
    80001f28:	e426                	sd	s1,8(sp)
    80001f2a:	e04a                	sd	s2,0(sp)
    80001f2c:	1000                	addi	s0,sp,32
    80001f2e:	84aa                	mv	s1,a0
    80001f30:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f32:	4681                	li	a3,0
    80001f34:	4605                	li	a2,1
    80001f36:	040005b7          	lui	a1,0x4000
    80001f3a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f3c:	05b2                	slli	a1,a1,0xc
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	5e6080e7          	jalr	1510(ra) # 80001524 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f46:	4681                	li	a3,0
    80001f48:	4605                	li	a2,1
    80001f4a:	020005b7          	lui	a1,0x2000
    80001f4e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001f50:	05b6                	slli	a1,a1,0xd
    80001f52:	8526                	mv	a0,s1
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	5d0080e7          	jalr	1488(ra) # 80001524 <uvmunmap>
    uvmfree(pagetable, sz);
    80001f5c:	85ca                	mv	a1,s2
    80001f5e:	8526                	mv	a0,s1
    80001f60:	00000097          	auipc	ra,0x0
    80001f64:	88e080e7          	jalr	-1906(ra) # 800017ee <uvmfree>
}
    80001f68:	60e2                	ld	ra,24(sp)
    80001f6a:	6442                	ld	s0,16(sp)
    80001f6c:	64a2                	ld	s1,8(sp)
    80001f6e:	6902                	ld	s2,0(sp)
    80001f70:	6105                	addi	sp,sp,32
    80001f72:	8082                	ret

0000000080001f74 <freeproc>:
{
    80001f74:	1101                	addi	sp,sp,-32
    80001f76:	ec06                	sd	ra,24(sp)
    80001f78:	e822                	sd	s0,16(sp)
    80001f7a:	e426                	sd	s1,8(sp)
    80001f7c:	1000                	addi	s0,sp,32
    80001f7e:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001f80:	6d28                	ld	a0,88(a0)
    80001f82:	c509                	beqz	a0,80001f8c <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	b96080e7          	jalr	-1130(ra) # 80000b1a <kfree>
    p->trapframe = 0;
    80001f8c:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001f90:	68a8                	ld	a0,80(s1)
    80001f92:	c511                	beqz	a0,80001f9e <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001f94:	64ac                	ld	a1,72(s1)
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	f8c080e7          	jalr	-116(ra) # 80001f22 <proc_freepagetable>
    p->pagetable = 0;
    80001f9e:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001fa2:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001fa6:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001faa:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001fae:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001fb2:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001fb6:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001fba:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001fbe:	0004ac23          	sw	zero,24(s1)
}
    80001fc2:	60e2                	ld	ra,24(sp)
    80001fc4:	6442                	ld	s0,16(sp)
    80001fc6:	64a2                	ld	s1,8(sp)
    80001fc8:	6105                	addi	sp,sp,32
    80001fca:	8082                	ret

0000000080001fcc <allocproc>:
{
    80001fcc:	1101                	addi	sp,sp,-32
    80001fce:	ec06                	sd	ra,24(sp)
    80001fd0:	e822                	sd	s0,16(sp)
    80001fd2:	e426                	sd	s1,8(sp)
    80001fd4:	e04a                	sd	s2,0(sp)
    80001fd6:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001fd8:	0002f497          	auipc	s1,0x2f
    80001fdc:	16048493          	addi	s1,s1,352 # 80031138 <proc>
    80001fe0:	00035917          	auipc	s2,0x35
    80001fe4:	b5890913          	addi	s2,s2,-1192 # 80036b38 <tickslock>
        acquire(&p->lock);
    80001fe8:	8526                	mv	a0,s1
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	eac080e7          	jalr	-340(ra) # 80000e96 <acquire>
        if (p->state == UNUSED)
    80001ff2:	4c9c                	lw	a5,24(s1)
    80001ff4:	cf81                	beqz	a5,8000200c <allocproc+0x40>
            release(&p->lock);
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	f52080e7          	jalr	-174(ra) # 80000f4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002000:	16848493          	addi	s1,s1,360
    80002004:	ff2492e3          	bne	s1,s2,80001fe8 <allocproc+0x1c>
    return 0;
    80002008:	4481                	li	s1,0
    8000200a:	a889                	j	8000205c <allocproc+0x90>
    p->pid = allocpid();
    8000200c:	00000097          	auipc	ra,0x0
    80002010:	e34080e7          	jalr	-460(ra) # 80001e40 <allocpid>
    80002014:	d888                	sw	a0,48(s1)
    p->state = USED;
    80002016:	4785                	li	a5,1
    80002018:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	cf2080e7          	jalr	-782(ra) # 80000d0c <kalloc>
    80002022:	892a                	mv	s2,a0
    80002024:	eca8                	sd	a0,88(s1)
    80002026:	c131                	beqz	a0,8000206a <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80002028:	8526                	mv	a0,s1
    8000202a:	00000097          	auipc	ra,0x0
    8000202e:	e5c080e7          	jalr	-420(ra) # 80001e86 <proc_pagetable>
    80002032:	892a                	mv	s2,a0
    80002034:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80002036:	c531                	beqz	a0,80002082 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80002038:	07000613          	li	a2,112
    8000203c:	4581                	li	a1,0
    8000203e:	06048513          	addi	a0,s1,96
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	f50080e7          	jalr	-176(ra) # 80000f92 <memset>
    p->context.ra = (uint64)forkret;
    8000204a:	00000797          	auipc	a5,0x0
    8000204e:	db078793          	addi	a5,a5,-592 # 80001dfa <forkret>
    80002052:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80002054:	60bc                	ld	a5,64(s1)
    80002056:	6705                	lui	a4,0x1
    80002058:	97ba                	add	a5,a5,a4
    8000205a:	f4bc                	sd	a5,104(s1)
}
    8000205c:	8526                	mv	a0,s1
    8000205e:	60e2                	ld	ra,24(sp)
    80002060:	6442                	ld	s0,16(sp)
    80002062:	64a2                	ld	s1,8(sp)
    80002064:	6902                	ld	s2,0(sp)
    80002066:	6105                	addi	sp,sp,32
    80002068:	8082                	ret
        freeproc(p);
    8000206a:	8526                	mv	a0,s1
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	f08080e7          	jalr	-248(ra) # 80001f74 <freeproc>
        release(&p->lock);
    80002074:	8526                	mv	a0,s1
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	ed4080e7          	jalr	-300(ra) # 80000f4a <release>
        return 0;
    8000207e:	84ca                	mv	s1,s2
    80002080:	bff1                	j	8000205c <allocproc+0x90>
        freeproc(p);
    80002082:	8526                	mv	a0,s1
    80002084:	00000097          	auipc	ra,0x0
    80002088:	ef0080e7          	jalr	-272(ra) # 80001f74 <freeproc>
        release(&p->lock);
    8000208c:	8526                	mv	a0,s1
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	ebc080e7          	jalr	-324(ra) # 80000f4a <release>
        return 0;
    80002096:	84ca                	mv	s1,s2
    80002098:	b7d1                	j	8000205c <allocproc+0x90>

000000008000209a <userinit>:
{
    8000209a:	1101                	addi	sp,sp,-32
    8000209c:	ec06                	sd	ra,24(sp)
    8000209e:	e822                	sd	s0,16(sp)
    800020a0:	e426                	sd	s1,8(sp)
    800020a2:	1000                	addi	s0,sp,32
    p = allocproc();
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	f28080e7          	jalr	-216(ra) # 80001fcc <allocproc>
    800020ac:	84aa                	mv	s1,a0
    initproc = p;
    800020ae:	00007797          	auipc	a5,0x7
    800020b2:	9ca7b523          	sd	a0,-1590(a5) # 80008a78 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800020b6:	03400613          	li	a2,52
    800020ba:	00007597          	auipc	a1,0x7
    800020be:	90658593          	addi	a1,a1,-1786 # 800089c0 <initcode>
    800020c2:	6928                	ld	a0,80(a0)
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	552080e7          	jalr	1362(ra) # 80001616 <uvmfirst>
    p->sz = PGSIZE;
    800020cc:	6785                	lui	a5,0x1
    800020ce:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    800020d0:	6cb8                	ld	a4,88(s1)
    800020d2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    800020d6:	6cb8                	ld	a4,88(s1)
    800020d8:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    800020da:	4641                	li	a2,16
    800020dc:	00006597          	auipc	a1,0x6
    800020e0:	18458593          	addi	a1,a1,388 # 80008260 <digits+0x210>
    800020e4:	15848513          	addi	a0,s1,344
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	ff4080e7          	jalr	-12(ra) # 800010dc <safestrcpy>
    p->cwd = namei("/");
    800020f0:	00006517          	auipc	a0,0x6
    800020f4:	18050513          	addi	a0,a0,384 # 80008270 <digits+0x220>
    800020f8:	00002097          	auipc	ra,0x2
    800020fc:	554080e7          	jalr	1364(ra) # 8000464c <namei>
    80002100:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80002104:	478d                	li	a5,3
    80002106:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	e40080e7          	jalr	-448(ra) # 80000f4a <release>
}
    80002112:	60e2                	ld	ra,24(sp)
    80002114:	6442                	ld	s0,16(sp)
    80002116:	64a2                	ld	s1,8(sp)
    80002118:	6105                	addi	sp,sp,32
    8000211a:	8082                	ret

000000008000211c <growproc>:
{
    8000211c:	1101                	addi	sp,sp,-32
    8000211e:	ec06                	sd	ra,24(sp)
    80002120:	e822                	sd	s0,16(sp)
    80002122:	e426                	sd	s1,8(sp)
    80002124:	e04a                	sd	s2,0(sp)
    80002126:	1000                	addi	s0,sp,32
    80002128:	892a                	mv	s2,a0
    struct proc *p = myproc();
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	c98080e7          	jalr	-872(ra) # 80001dc2 <myproc>
    80002132:	84aa                	mv	s1,a0
    sz = p->sz;
    80002134:	652c                	ld	a1,72(a0)
    if (n > 0)
    80002136:	01204c63          	bgtz	s2,8000214e <growproc+0x32>
    else if (n < 0)
    8000213a:	02094663          	bltz	s2,80002166 <growproc+0x4a>
    p->sz = sz;
    8000213e:	e4ac                	sd	a1,72(s1)
    return 0;
    80002140:	4501                	li	a0,0
}
    80002142:	60e2                	ld	ra,24(sp)
    80002144:	6442                	ld	s0,16(sp)
    80002146:	64a2                	ld	s1,8(sp)
    80002148:	6902                	ld	s2,0(sp)
    8000214a:	6105                	addi	sp,sp,32
    8000214c:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    8000214e:	4691                	li	a3,4
    80002150:	00b90633          	add	a2,s2,a1
    80002154:	6928                	ld	a0,80(a0)
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	57a080e7          	jalr	1402(ra) # 800016d0 <uvmalloc>
    8000215e:	85aa                	mv	a1,a0
    80002160:	fd79                	bnez	a0,8000213e <growproc+0x22>
            return -1;
    80002162:	557d                	li	a0,-1
    80002164:	bff9                	j	80002142 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002166:	00b90633          	add	a2,s2,a1
    8000216a:	6928                	ld	a0,80(a0)
    8000216c:	fffff097          	auipc	ra,0xfffff
    80002170:	51c080e7          	jalr	1308(ra) # 80001688 <uvmdealloc>
    80002174:	85aa                	mv	a1,a0
    80002176:	b7e1                	j	8000213e <growproc+0x22>

0000000080002178 <ps>:
{
    80002178:	715d                	addi	sp,sp,-80
    8000217a:	e486                	sd	ra,72(sp)
    8000217c:	e0a2                	sd	s0,64(sp)
    8000217e:	fc26                	sd	s1,56(sp)
    80002180:	f84a                	sd	s2,48(sp)
    80002182:	f44e                	sd	s3,40(sp)
    80002184:	f052                	sd	s4,32(sp)
    80002186:	ec56                	sd	s5,24(sp)
    80002188:	e85a                	sd	s6,16(sp)
    8000218a:	e45e                	sd	s7,8(sp)
    8000218c:	e062                	sd	s8,0(sp)
    8000218e:	0880                	addi	s0,sp,80
    80002190:	84aa                	mv	s1,a0
    80002192:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80002194:	00000097          	auipc	ra,0x0
    80002198:	c2e080e7          	jalr	-978(ra) # 80001dc2 <myproc>
        return result;
    8000219c:	4901                	li	s2,0
    if (count == 0)
    8000219e:	0c0b8563          	beqz	s7,80002268 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    800021a2:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    800021a6:	003b951b          	slliw	a0,s7,0x3
    800021aa:	0175053b          	addw	a0,a0,s7
    800021ae:	0025151b          	slliw	a0,a0,0x2
    800021b2:	00000097          	auipc	ra,0x0
    800021b6:	f6a080e7          	jalr	-150(ra) # 8000211c <growproc>
    800021ba:	12054f63          	bltz	a0,800022f8 <ps+0x180>
    struct user_proc loc_result[count];
    800021be:	003b9a13          	slli	s4,s7,0x3
    800021c2:	9a5e                	add	s4,s4,s7
    800021c4:	0a0a                	slli	s4,s4,0x2
    800021c6:	00fa0793          	addi	a5,s4,15
    800021ca:	8391                	srli	a5,a5,0x4
    800021cc:	0792                	slli	a5,a5,0x4
    800021ce:	40f10133          	sub	sp,sp,a5
    800021d2:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800021d4:	16800793          	li	a5,360
    800021d8:	02f484b3          	mul	s1,s1,a5
    800021dc:	0002f797          	auipc	a5,0x2f
    800021e0:	f5c78793          	addi	a5,a5,-164 # 80031138 <proc>
    800021e4:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800021e6:	00035797          	auipc	a5,0x35
    800021ea:	95278793          	addi	a5,a5,-1710 # 80036b38 <tickslock>
        return result;
    800021ee:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800021f0:	06f4fc63          	bgeu	s1,a5,80002268 <ps+0xf0>
    acquire(&wait_lock);
    800021f4:	0002f517          	auipc	a0,0x2f
    800021f8:	f2c50513          	addi	a0,a0,-212 # 80031120 <wait_lock>
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	c9a080e7          	jalr	-870(ra) # 80000e96 <acquire>
        if (localCount == count)
    80002204:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002208:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    8000220a:	00035c17          	auipc	s8,0x35
    8000220e:	92ec0c13          	addi	s8,s8,-1746 # 80036b38 <tickslock>
    80002212:	a851                	j	800022a6 <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    80002214:	00399793          	slli	a5,s3,0x3
    80002218:	97ce                	add	a5,a5,s3
    8000221a:	078a                	slli	a5,a5,0x2
    8000221c:	97d6                	add	a5,a5,s5
    8000221e:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	d26080e7          	jalr	-730(ra) # 80000f4a <release>
    release(&wait_lock);
    8000222c:	0002f517          	auipc	a0,0x2f
    80002230:	ef450513          	addi	a0,a0,-268 # 80031120 <wait_lock>
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	d16080e7          	jalr	-746(ra) # 80000f4a <release>
    if (localCount < count)
    8000223c:	0179f963          	bgeu	s3,s7,8000224e <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002240:	00399793          	slli	a5,s3,0x3
    80002244:	97ce                	add	a5,a5,s3
    80002246:	078a                	slli	a5,a5,0x2
    80002248:	97d6                	add	a5,a5,s5
    8000224a:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    8000224e:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002250:	00000097          	auipc	ra,0x0
    80002254:	b72080e7          	jalr	-1166(ra) # 80001dc2 <myproc>
    80002258:	86d2                	mv	a3,s4
    8000225a:	8656                	mv	a2,s5
    8000225c:	85da                	mv	a1,s6
    8000225e:	6928                	ld	a0,80(a0)
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	6c8080e7          	jalr	1736(ra) # 80001928 <copyout>
}
    80002268:	854a                	mv	a0,s2
    8000226a:	fb040113          	addi	sp,s0,-80
    8000226e:	60a6                	ld	ra,72(sp)
    80002270:	6406                	ld	s0,64(sp)
    80002272:	74e2                	ld	s1,56(sp)
    80002274:	7942                	ld	s2,48(sp)
    80002276:	79a2                	ld	s3,40(sp)
    80002278:	7a02                	ld	s4,32(sp)
    8000227a:	6ae2                	ld	s5,24(sp)
    8000227c:	6b42                	ld	s6,16(sp)
    8000227e:	6ba2                	ld	s7,8(sp)
    80002280:	6c02                	ld	s8,0(sp)
    80002282:	6161                	addi	sp,sp,80
    80002284:	8082                	ret
        release(&p->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	cc2080e7          	jalr	-830(ra) # 80000f4a <release>
        localCount++;
    80002290:	2985                	addiw	s3,s3,1
    80002292:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    80002296:	16848493          	addi	s1,s1,360
    8000229a:	f984f9e3          	bgeu	s1,s8,8000222c <ps+0xb4>
        if (localCount == count)
    8000229e:	02490913          	addi	s2,s2,36
    800022a2:	053b8d63          	beq	s7,s3,800022fc <ps+0x184>
        acquire(&p->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	bee080e7          	jalr	-1042(ra) # 80000e96 <acquire>
        if (p->state == UNUSED)
    800022b0:	4c9c                	lw	a5,24(s1)
    800022b2:	d3ad                	beqz	a5,80002214 <ps+0x9c>
        loc_result[localCount].state = p->state;
    800022b4:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800022b8:	549c                	lw	a5,40(s1)
    800022ba:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800022be:	54dc                	lw	a5,44(s1)
    800022c0:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800022c4:	589c                	lw	a5,48(s1)
    800022c6:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800022ca:	4641                	li	a2,16
    800022cc:	85ca                	mv	a1,s2
    800022ce:	15848513          	addi	a0,s1,344
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	a96080e7          	jalr	-1386(ra) # 80001d68 <copy_array>
        if (p->parent != 0) // init
    800022da:	7c88                	ld	a0,56(s1)
    800022dc:	d54d                	beqz	a0,80002286 <ps+0x10e>
            acquire(&p->parent->lock);
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	bb8080e7          	jalr	-1096(ra) # 80000e96 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800022e6:	7c88                	ld	a0,56(s1)
    800022e8:	591c                	lw	a5,48(a0)
    800022ea:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	c5c080e7          	jalr	-932(ra) # 80000f4a <release>
    800022f6:	bf41                	j	80002286 <ps+0x10e>
        return result;
    800022f8:	4901                	li	s2,0
    800022fa:	b7bd                	j	80002268 <ps+0xf0>
    release(&wait_lock);
    800022fc:	0002f517          	auipc	a0,0x2f
    80002300:	e2450513          	addi	a0,a0,-476 # 80031120 <wait_lock>
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	c46080e7          	jalr	-954(ra) # 80000f4a <release>
    if (localCount < count)
    8000230c:	b789                	j	8000224e <ps+0xd6>

000000008000230e <fork>:
{
    8000230e:	7139                	addi	sp,sp,-64
    80002310:	fc06                	sd	ra,56(sp)
    80002312:	f822                	sd	s0,48(sp)
    80002314:	f426                	sd	s1,40(sp)
    80002316:	f04a                	sd	s2,32(sp)
    80002318:	ec4e                	sd	s3,24(sp)
    8000231a:	e852                	sd	s4,16(sp)
    8000231c:	e456                	sd	s5,8(sp)
    8000231e:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002320:	00000097          	auipc	ra,0x0
    80002324:	aa2080e7          	jalr	-1374(ra) # 80001dc2 <myproc>
    80002328:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    8000232a:	00000097          	auipc	ra,0x0
    8000232e:	ca2080e7          	jalr	-862(ra) # 80001fcc <allocproc>
    80002332:	10050c63          	beqz	a0,8000244a <fork+0x13c>
    80002336:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002338:	048ab603          	ld	a2,72(s5)
    8000233c:	692c                	ld	a1,80(a0)
    8000233e:	050ab503          	ld	a0,80(s5)
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	4e6080e7          	jalr	1254(ra) # 80001828 <uvmcopy>
    8000234a:	04054863          	bltz	a0,8000239a <fork+0x8c>
    np->sz = p->sz;
    8000234e:	048ab783          	ld	a5,72(s5)
    80002352:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002356:	058ab683          	ld	a3,88(s5)
    8000235a:	87b6                	mv	a5,a3
    8000235c:	058a3703          	ld	a4,88(s4)
    80002360:	12068693          	addi	a3,a3,288
    80002364:	0007b803          	ld	a6,0(a5)
    80002368:	6788                	ld	a0,8(a5)
    8000236a:	6b8c                	ld	a1,16(a5)
    8000236c:	6f90                	ld	a2,24(a5)
    8000236e:	01073023          	sd	a6,0(a4)
    80002372:	e708                	sd	a0,8(a4)
    80002374:	eb0c                	sd	a1,16(a4)
    80002376:	ef10                	sd	a2,24(a4)
    80002378:	02078793          	addi	a5,a5,32
    8000237c:	02070713          	addi	a4,a4,32
    80002380:	fed792e3          	bne	a5,a3,80002364 <fork+0x56>
    np->trapframe->a0 = 0;
    80002384:	058a3783          	ld	a5,88(s4)
    80002388:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    8000238c:	0d0a8493          	addi	s1,s5,208
    80002390:	0d0a0913          	addi	s2,s4,208
    80002394:	150a8993          	addi	s3,s5,336
    80002398:	a00d                	j	800023ba <fork+0xac>
        freeproc(np);
    8000239a:	8552                	mv	a0,s4
    8000239c:	00000097          	auipc	ra,0x0
    800023a0:	bd8080e7          	jalr	-1064(ra) # 80001f74 <freeproc>
        release(&np->lock);
    800023a4:	8552                	mv	a0,s4
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	ba4080e7          	jalr	-1116(ra) # 80000f4a <release>
        return -1;
    800023ae:	597d                	li	s2,-1
    800023b0:	a059                	j	80002436 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    800023b2:	04a1                	addi	s1,s1,8
    800023b4:	0921                	addi	s2,s2,8
    800023b6:	01348b63          	beq	s1,s3,800023cc <fork+0xbe>
        if (p->ofile[i])
    800023ba:	6088                	ld	a0,0(s1)
    800023bc:	d97d                	beqz	a0,800023b2 <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    800023be:	00003097          	auipc	ra,0x3
    800023c2:	924080e7          	jalr	-1756(ra) # 80004ce2 <filedup>
    800023c6:	00a93023          	sd	a0,0(s2)
    800023ca:	b7e5                	j	800023b2 <fork+0xa4>
    np->cwd = idup(p->cwd);
    800023cc:	150ab503          	ld	a0,336(s5)
    800023d0:	00002097          	auipc	ra,0x2
    800023d4:	a92080e7          	jalr	-1390(ra) # 80003e62 <idup>
    800023d8:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800023dc:	4641                	li	a2,16
    800023de:	158a8593          	addi	a1,s5,344
    800023e2:	158a0513          	addi	a0,s4,344
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	cf6080e7          	jalr	-778(ra) # 800010dc <safestrcpy>
    pid = np->pid;
    800023ee:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800023f2:	8552                	mv	a0,s4
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	b56080e7          	jalr	-1194(ra) # 80000f4a <release>
    acquire(&wait_lock);
    800023fc:	0002f497          	auipc	s1,0x2f
    80002400:	d2448493          	addi	s1,s1,-732 # 80031120 <wait_lock>
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	a90080e7          	jalr	-1392(ra) # 80000e96 <acquire>
    np->parent = p;
    8000240e:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	b36080e7          	jalr	-1226(ra) # 80000f4a <release>
    acquire(&np->lock);
    8000241c:	8552                	mv	a0,s4
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	a78080e7          	jalr	-1416(ra) # 80000e96 <acquire>
    np->state = RUNNABLE;
    80002426:	478d                	li	a5,3
    80002428:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    8000242c:	8552                	mv	a0,s4
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	b1c080e7          	jalr	-1252(ra) # 80000f4a <release>
}
    80002436:	854a                	mv	a0,s2
    80002438:	70e2                	ld	ra,56(sp)
    8000243a:	7442                	ld	s0,48(sp)
    8000243c:	74a2                	ld	s1,40(sp)
    8000243e:	7902                	ld	s2,32(sp)
    80002440:	69e2                	ld	s3,24(sp)
    80002442:	6a42                	ld	s4,16(sp)
    80002444:	6aa2                	ld	s5,8(sp)
    80002446:	6121                	addi	sp,sp,64
    80002448:	8082                	ret
        return -1;
    8000244a:	597d                	li	s2,-1
    8000244c:	b7ed                	j	80002436 <fork+0x128>

000000008000244e <scheduler>:
{
    8000244e:	1101                	addi	sp,sp,-32
    80002450:	ec06                	sd	ra,24(sp)
    80002452:	e822                	sd	s0,16(sp)
    80002454:	e426                	sd	s1,8(sp)
    80002456:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002458:	00006497          	auipc	s1,0x6
    8000245c:	55048493          	addi	s1,s1,1360 # 800089a8 <sched_pointer>
    80002460:	609c                	ld	a5,0(s1)
    80002462:	9782                	jalr	a5
    while (1)
    80002464:	bff5                	j	80002460 <scheduler+0x12>

0000000080002466 <sched>:
{
    80002466:	7179                	addi	sp,sp,-48
    80002468:	f406                	sd	ra,40(sp)
    8000246a:	f022                	sd	s0,32(sp)
    8000246c:	ec26                	sd	s1,24(sp)
    8000246e:	e84a                	sd	s2,16(sp)
    80002470:	e44e                	sd	s3,8(sp)
    80002472:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    80002474:	00000097          	auipc	ra,0x0
    80002478:	94e080e7          	jalr	-1714(ra) # 80001dc2 <myproc>
    8000247c:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	99e080e7          	jalr	-1634(ra) # 80000e1c <holding>
    80002486:	c53d                	beqz	a0,800024f4 <sched+0x8e>
    80002488:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    8000248a:	2781                	sext.w	a5,a5
    8000248c:	079e                	slli	a5,a5,0x7
    8000248e:	0002f717          	auipc	a4,0x2f
    80002492:	87a70713          	addi	a4,a4,-1926 # 80030d08 <cpus>
    80002496:	97ba                	add	a5,a5,a4
    80002498:	5fb8                	lw	a4,120(a5)
    8000249a:	4785                	li	a5,1
    8000249c:	06f71463          	bne	a4,a5,80002504 <sched+0x9e>
    if (p->state == RUNNING)
    800024a0:	4c98                	lw	a4,24(s1)
    800024a2:	4791                	li	a5,4
    800024a4:	06f70863          	beq	a4,a5,80002514 <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800024a8:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    800024ac:	8b89                	andi	a5,a5,2
    if (intr_get())
    800024ae:	ebbd                	bnez	a5,80002524 <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800024b0:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800024b2:	0002f917          	auipc	s2,0x2f
    800024b6:	85690913          	addi	s2,s2,-1962 # 80030d08 <cpus>
    800024ba:	2781                	sext.w	a5,a5
    800024bc:	079e                	slli	a5,a5,0x7
    800024be:	97ca                	add	a5,a5,s2
    800024c0:	07c7a983          	lw	s3,124(a5)
    800024c4:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800024c6:	2581                	sext.w	a1,a1
    800024c8:	059e                	slli	a1,a1,0x7
    800024ca:	05a1                	addi	a1,a1,8
    800024cc:	95ca                	add	a1,a1,s2
    800024ce:	06048513          	addi	a0,s1,96
    800024d2:	00000097          	auipc	ra,0x0
    800024d6:	75a080e7          	jalr	1882(ra) # 80002c2c <swtch>
    800024da:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800024dc:	2781                	sext.w	a5,a5
    800024de:	079e                	slli	a5,a5,0x7
    800024e0:	993e                	add	s2,s2,a5
    800024e2:	07392e23          	sw	s3,124(s2)
}
    800024e6:	70a2                	ld	ra,40(sp)
    800024e8:	7402                	ld	s0,32(sp)
    800024ea:	64e2                	ld	s1,24(sp)
    800024ec:	6942                	ld	s2,16(sp)
    800024ee:	69a2                	ld	s3,8(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret
        panic("sched p->lock");
    800024f4:	00006517          	auipc	a0,0x6
    800024f8:	d8450513          	addi	a0,a0,-636 # 80008278 <digits+0x228>
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	044080e7          	jalr	68(ra) # 80000540 <panic>
        panic("sched locks");
    80002504:	00006517          	auipc	a0,0x6
    80002508:	d8450513          	addi	a0,a0,-636 # 80008288 <digits+0x238>
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	034080e7          	jalr	52(ra) # 80000540 <panic>
        panic("sched running");
    80002514:	00006517          	auipc	a0,0x6
    80002518:	d8450513          	addi	a0,a0,-636 # 80008298 <digits+0x248>
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	024080e7          	jalr	36(ra) # 80000540 <panic>
        panic("sched interruptible");
    80002524:	00006517          	auipc	a0,0x6
    80002528:	d8450513          	addi	a0,a0,-636 # 800082a8 <digits+0x258>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	014080e7          	jalr	20(ra) # 80000540 <panic>

0000000080002534 <yield>:
{
    80002534:	1101                	addi	sp,sp,-32
    80002536:	ec06                	sd	ra,24(sp)
    80002538:	e822                	sd	s0,16(sp)
    8000253a:	e426                	sd	s1,8(sp)
    8000253c:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    8000253e:	00000097          	auipc	ra,0x0
    80002542:	884080e7          	jalr	-1916(ra) # 80001dc2 <myproc>
    80002546:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002548:	fffff097          	auipc	ra,0xfffff
    8000254c:	94e080e7          	jalr	-1714(ra) # 80000e96 <acquire>
    p->state = RUNNABLE;
    80002550:	478d                	li	a5,3
    80002552:	cc9c                	sw	a5,24(s1)
    sched();
    80002554:	00000097          	auipc	ra,0x0
    80002558:	f12080e7          	jalr	-238(ra) # 80002466 <sched>
    release(&p->lock);
    8000255c:	8526                	mv	a0,s1
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	9ec080e7          	jalr	-1556(ra) # 80000f4a <release>
}
    80002566:	60e2                	ld	ra,24(sp)
    80002568:	6442                	ld	s0,16(sp)
    8000256a:	64a2                	ld	s1,8(sp)
    8000256c:	6105                	addi	sp,sp,32
    8000256e:	8082                	ret

0000000080002570 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002570:	7179                	addi	sp,sp,-48
    80002572:	f406                	sd	ra,40(sp)
    80002574:	f022                	sd	s0,32(sp)
    80002576:	ec26                	sd	s1,24(sp)
    80002578:	e84a                	sd	s2,16(sp)
    8000257a:	e44e                	sd	s3,8(sp)
    8000257c:	1800                	addi	s0,sp,48
    8000257e:	89aa                	mv	s3,a0
    80002580:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002582:	00000097          	auipc	ra,0x0
    80002586:	840080e7          	jalr	-1984(ra) # 80001dc2 <myproc>
    8000258a:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	90a080e7          	jalr	-1782(ra) # 80000e96 <acquire>
    release(lk);
    80002594:	854a                	mv	a0,s2
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	9b4080e7          	jalr	-1612(ra) # 80000f4a <release>

    // Go to sleep.
    p->chan = chan;
    8000259e:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800025a2:	4789                	li	a5,2
    800025a4:	cc9c                	sw	a5,24(s1)

    sched();
    800025a6:	00000097          	auipc	ra,0x0
    800025aa:	ec0080e7          	jalr	-320(ra) # 80002466 <sched>

    // Tidy up.
    p->chan = 0;
    800025ae:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800025b2:	8526                	mv	a0,s1
    800025b4:	fffff097          	auipc	ra,0xfffff
    800025b8:	996080e7          	jalr	-1642(ra) # 80000f4a <release>
    acquire(lk);
    800025bc:	854a                	mv	a0,s2
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	8d8080e7          	jalr	-1832(ra) # 80000e96 <acquire>
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6145                	addi	sp,sp,48
    800025d2:	8082                	ret

00000000800025d4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800025d4:	7139                	addi	sp,sp,-64
    800025d6:	fc06                	sd	ra,56(sp)
    800025d8:	f822                	sd	s0,48(sp)
    800025da:	f426                	sd	s1,40(sp)
    800025dc:	f04a                	sd	s2,32(sp)
    800025de:	ec4e                	sd	s3,24(sp)
    800025e0:	e852                	sd	s4,16(sp)
    800025e2:	e456                	sd	s5,8(sp)
    800025e4:	0080                	addi	s0,sp,64
    800025e6:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800025e8:	0002f497          	auipc	s1,0x2f
    800025ec:	b5048493          	addi	s1,s1,-1200 # 80031138 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800025f0:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800025f2:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800025f4:	00034917          	auipc	s2,0x34
    800025f8:	54490913          	addi	s2,s2,1348 # 80036b38 <tickslock>
    800025fc:	a811                	j	80002610 <wakeup+0x3c>
            }
            release(&p->lock);
    800025fe:	8526                	mv	a0,s1
    80002600:	fffff097          	auipc	ra,0xfffff
    80002604:	94a080e7          	jalr	-1718(ra) # 80000f4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002608:	16848493          	addi	s1,s1,360
    8000260c:	03248663          	beq	s1,s2,80002638 <wakeup+0x64>
        if (p != myproc())
    80002610:	fffff097          	auipc	ra,0xfffff
    80002614:	7b2080e7          	jalr	1970(ra) # 80001dc2 <myproc>
    80002618:	fea488e3          	beq	s1,a0,80002608 <wakeup+0x34>
            acquire(&p->lock);
    8000261c:	8526                	mv	a0,s1
    8000261e:	fffff097          	auipc	ra,0xfffff
    80002622:	878080e7          	jalr	-1928(ra) # 80000e96 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002626:	4c9c                	lw	a5,24(s1)
    80002628:	fd379be3          	bne	a5,s3,800025fe <wakeup+0x2a>
    8000262c:	709c                	ld	a5,32(s1)
    8000262e:	fd4798e3          	bne	a5,s4,800025fe <wakeup+0x2a>
                p->state = RUNNABLE;
    80002632:	0154ac23          	sw	s5,24(s1)
    80002636:	b7e1                	j	800025fe <wakeup+0x2a>
        }
    }
}
    80002638:	70e2                	ld	ra,56(sp)
    8000263a:	7442                	ld	s0,48(sp)
    8000263c:	74a2                	ld	s1,40(sp)
    8000263e:	7902                	ld	s2,32(sp)
    80002640:	69e2                	ld	s3,24(sp)
    80002642:	6a42                	ld	s4,16(sp)
    80002644:	6aa2                	ld	s5,8(sp)
    80002646:	6121                	addi	sp,sp,64
    80002648:	8082                	ret

000000008000264a <reparent>:
{
    8000264a:	7179                	addi	sp,sp,-48
    8000264c:	f406                	sd	ra,40(sp)
    8000264e:	f022                	sd	s0,32(sp)
    80002650:	ec26                	sd	s1,24(sp)
    80002652:	e84a                	sd	s2,16(sp)
    80002654:	e44e                	sd	s3,8(sp)
    80002656:	e052                	sd	s4,0(sp)
    80002658:	1800                	addi	s0,sp,48
    8000265a:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000265c:	0002f497          	auipc	s1,0x2f
    80002660:	adc48493          	addi	s1,s1,-1316 # 80031138 <proc>
            pp->parent = initproc;
    80002664:	00006a17          	auipc	s4,0x6
    80002668:	414a0a13          	addi	s4,s4,1044 # 80008a78 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000266c:	00034997          	auipc	s3,0x34
    80002670:	4cc98993          	addi	s3,s3,1228 # 80036b38 <tickslock>
    80002674:	a029                	j	8000267e <reparent+0x34>
    80002676:	16848493          	addi	s1,s1,360
    8000267a:	01348d63          	beq	s1,s3,80002694 <reparent+0x4a>
        if (pp->parent == p)
    8000267e:	7c9c                	ld	a5,56(s1)
    80002680:	ff279be3          	bne	a5,s2,80002676 <reparent+0x2c>
            pp->parent = initproc;
    80002684:	000a3503          	ld	a0,0(s4)
    80002688:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    8000268a:	00000097          	auipc	ra,0x0
    8000268e:	f4a080e7          	jalr	-182(ra) # 800025d4 <wakeup>
    80002692:	b7d5                	j	80002676 <reparent+0x2c>
}
    80002694:	70a2                	ld	ra,40(sp)
    80002696:	7402                	ld	s0,32(sp)
    80002698:	64e2                	ld	s1,24(sp)
    8000269a:	6942                	ld	s2,16(sp)
    8000269c:	69a2                	ld	s3,8(sp)
    8000269e:	6a02                	ld	s4,0(sp)
    800026a0:	6145                	addi	sp,sp,48
    800026a2:	8082                	ret

00000000800026a4 <exit>:
{
    800026a4:	7179                	addi	sp,sp,-48
    800026a6:	f406                	sd	ra,40(sp)
    800026a8:	f022                	sd	s0,32(sp)
    800026aa:	ec26                	sd	s1,24(sp)
    800026ac:	e84a                	sd	s2,16(sp)
    800026ae:	e44e                	sd	s3,8(sp)
    800026b0:	e052                	sd	s4,0(sp)
    800026b2:	1800                	addi	s0,sp,48
    800026b4:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800026b6:	fffff097          	auipc	ra,0xfffff
    800026ba:	70c080e7          	jalr	1804(ra) # 80001dc2 <myproc>
    800026be:	89aa                	mv	s3,a0
    if (p == initproc)
    800026c0:	00006797          	auipc	a5,0x6
    800026c4:	3b87b783          	ld	a5,952(a5) # 80008a78 <initproc>
    800026c8:	0d050493          	addi	s1,a0,208
    800026cc:	15050913          	addi	s2,a0,336
    800026d0:	02a79363          	bne	a5,a0,800026f6 <exit+0x52>
        panic("init exiting");
    800026d4:	00006517          	auipc	a0,0x6
    800026d8:	bec50513          	addi	a0,a0,-1044 # 800082c0 <digits+0x270>
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	e64080e7          	jalr	-412(ra) # 80000540 <panic>
            fileclose(f);
    800026e4:	00002097          	auipc	ra,0x2
    800026e8:	650080e7          	jalr	1616(ra) # 80004d34 <fileclose>
            p->ofile[fd] = 0;
    800026ec:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800026f0:	04a1                	addi	s1,s1,8
    800026f2:	01248563          	beq	s1,s2,800026fc <exit+0x58>
        if (p->ofile[fd])
    800026f6:	6088                	ld	a0,0(s1)
    800026f8:	f575                	bnez	a0,800026e4 <exit+0x40>
    800026fa:	bfdd                	j	800026f0 <exit+0x4c>
    begin_op();
    800026fc:	00002097          	auipc	ra,0x2
    80002700:	170080e7          	jalr	368(ra) # 8000486c <begin_op>
    iput(p->cwd);
    80002704:	1509b503          	ld	a0,336(s3)
    80002708:	00002097          	auipc	ra,0x2
    8000270c:	952080e7          	jalr	-1710(ra) # 8000405a <iput>
    end_op();
    80002710:	00002097          	auipc	ra,0x2
    80002714:	1da080e7          	jalr	474(ra) # 800048ea <end_op>
    p->cwd = 0;
    80002718:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    8000271c:	0002f497          	auipc	s1,0x2f
    80002720:	a0448493          	addi	s1,s1,-1532 # 80031120 <wait_lock>
    80002724:	8526                	mv	a0,s1
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	770080e7          	jalr	1904(ra) # 80000e96 <acquire>
    reparent(p);
    8000272e:	854e                	mv	a0,s3
    80002730:	00000097          	auipc	ra,0x0
    80002734:	f1a080e7          	jalr	-230(ra) # 8000264a <reparent>
    wakeup(p->parent);
    80002738:	0389b503          	ld	a0,56(s3)
    8000273c:	00000097          	auipc	ra,0x0
    80002740:	e98080e7          	jalr	-360(ra) # 800025d4 <wakeup>
    acquire(&p->lock);
    80002744:	854e                	mv	a0,s3
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	750080e7          	jalr	1872(ra) # 80000e96 <acquire>
    p->xstate = status;
    8000274e:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002752:	4795                	li	a5,5
    80002754:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	7f0080e7          	jalr	2032(ra) # 80000f4a <release>
    sched();
    80002762:	00000097          	auipc	ra,0x0
    80002766:	d04080e7          	jalr	-764(ra) # 80002466 <sched>
    panic("zombie exit");
    8000276a:	00006517          	auipc	a0,0x6
    8000276e:	b6650513          	addi	a0,a0,-1178 # 800082d0 <digits+0x280>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	dce080e7          	jalr	-562(ra) # 80000540 <panic>

000000008000277a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000277a:	7179                	addi	sp,sp,-48
    8000277c:	f406                	sd	ra,40(sp)
    8000277e:	f022                	sd	s0,32(sp)
    80002780:	ec26                	sd	s1,24(sp)
    80002782:	e84a                	sd	s2,16(sp)
    80002784:	e44e                	sd	s3,8(sp)
    80002786:	1800                	addi	s0,sp,48
    80002788:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    8000278a:	0002f497          	auipc	s1,0x2f
    8000278e:	9ae48493          	addi	s1,s1,-1618 # 80031138 <proc>
    80002792:	00034997          	auipc	s3,0x34
    80002796:	3a698993          	addi	s3,s3,934 # 80036b38 <tickslock>
    {
        acquire(&p->lock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	6fa080e7          	jalr	1786(ra) # 80000e96 <acquire>
        if (p->pid == pid)
    800027a4:	589c                	lw	a5,48(s1)
    800027a6:	01278d63          	beq	a5,s2,800027c0 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800027aa:	8526                	mv	a0,s1
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	79e080e7          	jalr	1950(ra) # 80000f4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800027b4:	16848493          	addi	s1,s1,360
    800027b8:	ff3491e3          	bne	s1,s3,8000279a <kill+0x20>
    }
    return -1;
    800027bc:	557d                	li	a0,-1
    800027be:	a829                	j	800027d8 <kill+0x5e>
            p->killed = 1;
    800027c0:	4785                	li	a5,1
    800027c2:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800027c4:	4c98                	lw	a4,24(s1)
    800027c6:	4789                	li	a5,2
    800027c8:	00f70f63          	beq	a4,a5,800027e6 <kill+0x6c>
            release(&p->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	77c080e7          	jalr	1916(ra) # 80000f4a <release>
            return 0;
    800027d6:	4501                	li	a0,0
}
    800027d8:	70a2                	ld	ra,40(sp)
    800027da:	7402                	ld	s0,32(sp)
    800027dc:	64e2                	ld	s1,24(sp)
    800027de:	6942                	ld	s2,16(sp)
    800027e0:	69a2                	ld	s3,8(sp)
    800027e2:	6145                	addi	sp,sp,48
    800027e4:	8082                	ret
                p->state = RUNNABLE;
    800027e6:	478d                	li	a5,3
    800027e8:	cc9c                	sw	a5,24(s1)
    800027ea:	b7cd                	j	800027cc <kill+0x52>

00000000800027ec <setkilled>:

void setkilled(struct proc *p)
{
    800027ec:	1101                	addi	sp,sp,-32
    800027ee:	ec06                	sd	ra,24(sp)
    800027f0:	e822                	sd	s0,16(sp)
    800027f2:	e426                	sd	s1,8(sp)
    800027f4:	1000                	addi	s0,sp,32
    800027f6:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800027f8:	ffffe097          	auipc	ra,0xffffe
    800027fc:	69e080e7          	jalr	1694(ra) # 80000e96 <acquire>
    p->killed = 1;
    80002800:	4785                	li	a5,1
    80002802:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	744080e7          	jalr	1860(ra) # 80000f4a <release>
}
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	64a2                	ld	s1,8(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret

0000000080002818 <killed>:

int killed(struct proc *p)
{
    80002818:	1101                	addi	sp,sp,-32
    8000281a:	ec06                	sd	ra,24(sp)
    8000281c:	e822                	sd	s0,16(sp)
    8000281e:	e426                	sd	s1,8(sp)
    80002820:	e04a                	sd	s2,0(sp)
    80002822:	1000                	addi	s0,sp,32
    80002824:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	670080e7          	jalr	1648(ra) # 80000e96 <acquire>
    k = p->killed;
    8000282e:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002832:	8526                	mv	a0,s1
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	716080e7          	jalr	1814(ra) # 80000f4a <release>
    return k;
}
    8000283c:	854a                	mv	a0,s2
    8000283e:	60e2                	ld	ra,24(sp)
    80002840:	6442                	ld	s0,16(sp)
    80002842:	64a2                	ld	s1,8(sp)
    80002844:	6902                	ld	s2,0(sp)
    80002846:	6105                	addi	sp,sp,32
    80002848:	8082                	ret

000000008000284a <wait>:
{
    8000284a:	715d                	addi	sp,sp,-80
    8000284c:	e486                	sd	ra,72(sp)
    8000284e:	e0a2                	sd	s0,64(sp)
    80002850:	fc26                	sd	s1,56(sp)
    80002852:	f84a                	sd	s2,48(sp)
    80002854:	f44e                	sd	s3,40(sp)
    80002856:	f052                	sd	s4,32(sp)
    80002858:	ec56                	sd	s5,24(sp)
    8000285a:	e85a                	sd	s6,16(sp)
    8000285c:	e45e                	sd	s7,8(sp)
    8000285e:	e062                	sd	s8,0(sp)
    80002860:	0880                	addi	s0,sp,80
    80002862:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	55e080e7          	jalr	1374(ra) # 80001dc2 <myproc>
    8000286c:	892a                	mv	s2,a0
    acquire(&wait_lock);
    8000286e:	0002f517          	auipc	a0,0x2f
    80002872:	8b250513          	addi	a0,a0,-1870 # 80031120 <wait_lock>
    80002876:	ffffe097          	auipc	ra,0xffffe
    8000287a:	620080e7          	jalr	1568(ra) # 80000e96 <acquire>
        havekids = 0;
    8000287e:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002880:	4a15                	li	s4,5
                havekids = 1;
    80002882:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002884:	00034997          	auipc	s3,0x34
    80002888:	2b498993          	addi	s3,s3,692 # 80036b38 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    8000288c:	0002fc17          	auipc	s8,0x2f
    80002890:	894c0c13          	addi	s8,s8,-1900 # 80031120 <wait_lock>
        havekids = 0;
    80002894:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002896:	0002f497          	auipc	s1,0x2f
    8000289a:	8a248493          	addi	s1,s1,-1886 # 80031138 <proc>
    8000289e:	a0bd                	j	8000290c <wait+0xc2>
                    pid = pp->pid;
    800028a0:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800028a4:	000b0e63          	beqz	s6,800028c0 <wait+0x76>
    800028a8:	4691                	li	a3,4
    800028aa:	02c48613          	addi	a2,s1,44
    800028ae:	85da                	mv	a1,s6
    800028b0:	05093503          	ld	a0,80(s2)
    800028b4:	fffff097          	auipc	ra,0xfffff
    800028b8:	074080e7          	jalr	116(ra) # 80001928 <copyout>
    800028bc:	02054563          	bltz	a0,800028e6 <wait+0x9c>
                    freeproc(pp);
    800028c0:	8526                	mv	a0,s1
    800028c2:	fffff097          	auipc	ra,0xfffff
    800028c6:	6b2080e7          	jalr	1714(ra) # 80001f74 <freeproc>
                    release(&pp->lock);
    800028ca:	8526                	mv	a0,s1
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	67e080e7          	jalr	1662(ra) # 80000f4a <release>
                    release(&wait_lock);
    800028d4:	0002f517          	auipc	a0,0x2f
    800028d8:	84c50513          	addi	a0,a0,-1972 # 80031120 <wait_lock>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	66e080e7          	jalr	1646(ra) # 80000f4a <release>
                    return pid;
    800028e4:	a0b5                	j	80002950 <wait+0x106>
                        release(&pp->lock);
    800028e6:	8526                	mv	a0,s1
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	662080e7          	jalr	1634(ra) # 80000f4a <release>
                        release(&wait_lock);
    800028f0:	0002f517          	auipc	a0,0x2f
    800028f4:	83050513          	addi	a0,a0,-2000 # 80031120 <wait_lock>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	652080e7          	jalr	1618(ra) # 80000f4a <release>
                        return -1;
    80002900:	59fd                	li	s3,-1
    80002902:	a0b9                	j	80002950 <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002904:	16848493          	addi	s1,s1,360
    80002908:	03348463          	beq	s1,s3,80002930 <wait+0xe6>
            if (pp->parent == p)
    8000290c:	7c9c                	ld	a5,56(s1)
    8000290e:	ff279be3          	bne	a5,s2,80002904 <wait+0xba>
                acquire(&pp->lock);
    80002912:	8526                	mv	a0,s1
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	582080e7          	jalr	1410(ra) # 80000e96 <acquire>
                if (pp->state == ZOMBIE)
    8000291c:	4c9c                	lw	a5,24(s1)
    8000291e:	f94781e3          	beq	a5,s4,800028a0 <wait+0x56>
                release(&pp->lock);
    80002922:	8526                	mv	a0,s1
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	626080e7          	jalr	1574(ra) # 80000f4a <release>
                havekids = 1;
    8000292c:	8756                	mv	a4,s5
    8000292e:	bfd9                	j	80002904 <wait+0xba>
        if (!havekids || killed(p))
    80002930:	c719                	beqz	a4,8000293e <wait+0xf4>
    80002932:	854a                	mv	a0,s2
    80002934:	00000097          	auipc	ra,0x0
    80002938:	ee4080e7          	jalr	-284(ra) # 80002818 <killed>
    8000293c:	c51d                	beqz	a0,8000296a <wait+0x120>
            release(&wait_lock);
    8000293e:	0002e517          	auipc	a0,0x2e
    80002942:	7e250513          	addi	a0,a0,2018 # 80031120 <wait_lock>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	604080e7          	jalr	1540(ra) # 80000f4a <release>
            return -1;
    8000294e:	59fd                	li	s3,-1
}
    80002950:	854e                	mv	a0,s3
    80002952:	60a6                	ld	ra,72(sp)
    80002954:	6406                	ld	s0,64(sp)
    80002956:	74e2                	ld	s1,56(sp)
    80002958:	7942                	ld	s2,48(sp)
    8000295a:	79a2                	ld	s3,40(sp)
    8000295c:	7a02                	ld	s4,32(sp)
    8000295e:	6ae2                	ld	s5,24(sp)
    80002960:	6b42                	ld	s6,16(sp)
    80002962:	6ba2                	ld	s7,8(sp)
    80002964:	6c02                	ld	s8,0(sp)
    80002966:	6161                	addi	sp,sp,80
    80002968:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    8000296a:	85e2                	mv	a1,s8
    8000296c:	854a                	mv	a0,s2
    8000296e:	00000097          	auipc	ra,0x0
    80002972:	c02080e7          	jalr	-1022(ra) # 80002570 <sleep>
        havekids = 0;
    80002976:	bf39                	j	80002894 <wait+0x4a>

0000000080002978 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002978:	7179                	addi	sp,sp,-48
    8000297a:	f406                	sd	ra,40(sp)
    8000297c:	f022                	sd	s0,32(sp)
    8000297e:	ec26                	sd	s1,24(sp)
    80002980:	e84a                	sd	s2,16(sp)
    80002982:	e44e                	sd	s3,8(sp)
    80002984:	e052                	sd	s4,0(sp)
    80002986:	1800                	addi	s0,sp,48
    80002988:	84aa                	mv	s1,a0
    8000298a:	892e                	mv	s2,a1
    8000298c:	89b2                	mv	s3,a2
    8000298e:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	432080e7          	jalr	1074(ra) # 80001dc2 <myproc>
    if (user_dst)
    80002998:	c08d                	beqz	s1,800029ba <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    8000299a:	86d2                	mv	a3,s4
    8000299c:	864e                	mv	a2,s3
    8000299e:	85ca                	mv	a1,s2
    800029a0:	6928                	ld	a0,80(a0)
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	f86080e7          	jalr	-122(ra) # 80001928 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    800029aa:	70a2                	ld	ra,40(sp)
    800029ac:	7402                	ld	s0,32(sp)
    800029ae:	64e2                	ld	s1,24(sp)
    800029b0:	6942                	ld	s2,16(sp)
    800029b2:	69a2                	ld	s3,8(sp)
    800029b4:	6a02                	ld	s4,0(sp)
    800029b6:	6145                	addi	sp,sp,48
    800029b8:	8082                	ret
        memmove((char *)dst, src, len);
    800029ba:	000a061b          	sext.w	a2,s4
    800029be:	85ce                	mv	a1,s3
    800029c0:	854a                	mv	a0,s2
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	62c080e7          	jalr	1580(ra) # 80000fee <memmove>
        return 0;
    800029ca:	8526                	mv	a0,s1
    800029cc:	bff9                	j	800029aa <either_copyout+0x32>

00000000800029ce <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029ce:	7179                	addi	sp,sp,-48
    800029d0:	f406                	sd	ra,40(sp)
    800029d2:	f022                	sd	s0,32(sp)
    800029d4:	ec26                	sd	s1,24(sp)
    800029d6:	e84a                	sd	s2,16(sp)
    800029d8:	e44e                	sd	s3,8(sp)
    800029da:	e052                	sd	s4,0(sp)
    800029dc:	1800                	addi	s0,sp,48
    800029de:	892a                	mv	s2,a0
    800029e0:	84ae                	mv	s1,a1
    800029e2:	89b2                	mv	s3,a2
    800029e4:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	3dc080e7          	jalr	988(ra) # 80001dc2 <myproc>
    if (user_src)
    800029ee:	c08d                	beqz	s1,80002a10 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    800029f0:	86d2                	mv	a3,s4
    800029f2:	864e                	mv	a2,s3
    800029f4:	85ca                	mv	a1,s2
    800029f6:	6928                	ld	a0,80(a0)
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	fbc080e7          	jalr	-68(ra) # 800019b4 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6a02                	ld	s4,0(sp)
    80002a0c:	6145                	addi	sp,sp,48
    80002a0e:	8082                	ret
        memmove(dst, (char *)src, len);
    80002a10:	000a061b          	sext.w	a2,s4
    80002a14:	85ce                	mv	a1,s3
    80002a16:	854a                	mv	a0,s2
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	5d6080e7          	jalr	1494(ra) # 80000fee <memmove>
        return 0;
    80002a20:	8526                	mv	a0,s1
    80002a22:	bff9                	j	80002a00 <either_copyin+0x32>

0000000080002a24 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002a24:	715d                	addi	sp,sp,-80
    80002a26:	e486                	sd	ra,72(sp)
    80002a28:	e0a2                	sd	s0,64(sp)
    80002a2a:	fc26                	sd	s1,56(sp)
    80002a2c:	f84a                	sd	s2,48(sp)
    80002a2e:	f44e                	sd	s3,40(sp)
    80002a30:	f052                	sd	s4,32(sp)
    80002a32:	ec56                	sd	s5,24(sp)
    80002a34:	e85a                	sd	s6,16(sp)
    80002a36:	e45e                	sd	s7,8(sp)
    80002a38:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002a3a:	00005517          	auipc	a0,0x5
    80002a3e:	65e50513          	addi	a0,a0,1630 # 80008098 <digits+0x48>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	b5a080e7          	jalr	-1190(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002a4a:	0002f497          	auipc	s1,0x2f
    80002a4e:	84648493          	addi	s1,s1,-1978 # 80031290 <proc+0x158>
    80002a52:	00034917          	auipc	s2,0x34
    80002a56:	23e90913          	addi	s2,s2,574 # 80036c90 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a5a:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002a5c:	00006997          	auipc	s3,0x6
    80002a60:	88498993          	addi	s3,s3,-1916 # 800082e0 <digits+0x290>
        printf("%d <%s %s", p->pid, state, p->name);
    80002a64:	00006a97          	auipc	s5,0x6
    80002a68:	884a8a93          	addi	s5,s5,-1916 # 800082e8 <digits+0x298>
        printf("\n");
    80002a6c:	00005a17          	auipc	s4,0x5
    80002a70:	62ca0a13          	addi	s4,s4,1580 # 80008098 <digits+0x48>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a74:	00006b97          	auipc	s7,0x6
    80002a78:	984b8b93          	addi	s7,s7,-1660 # 800083f8 <states.0>
    80002a7c:	a00d                	j	80002a9e <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002a7e:	ed86a583          	lw	a1,-296(a3)
    80002a82:	8556                	mv	a0,s5
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	b18080e7          	jalr	-1256(ra) # 8000059c <printf>
        printf("\n");
    80002a8c:	8552                	mv	a0,s4
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	b0e080e7          	jalr	-1266(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002a96:	16848493          	addi	s1,s1,360
    80002a9a:	03248263          	beq	s1,s2,80002abe <procdump+0x9a>
        if (p->state == UNUSED)
    80002a9e:	86a6                	mv	a3,s1
    80002aa0:	ec04a783          	lw	a5,-320(s1)
    80002aa4:	dbed                	beqz	a5,80002a96 <procdump+0x72>
            state = "???";
    80002aa6:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002aa8:	fcfb6be3          	bltu	s6,a5,80002a7e <procdump+0x5a>
    80002aac:	02079713          	slli	a4,a5,0x20
    80002ab0:	01d75793          	srli	a5,a4,0x1d
    80002ab4:	97de                	add	a5,a5,s7
    80002ab6:	6390                	ld	a2,0(a5)
    80002ab8:	f279                	bnez	a2,80002a7e <procdump+0x5a>
            state = "???";
    80002aba:	864e                	mv	a2,s3
    80002abc:	b7c9                	j	80002a7e <procdump+0x5a>
    }
}
    80002abe:	60a6                	ld	ra,72(sp)
    80002ac0:	6406                	ld	s0,64(sp)
    80002ac2:	74e2                	ld	s1,56(sp)
    80002ac4:	7942                	ld	s2,48(sp)
    80002ac6:	79a2                	ld	s3,40(sp)
    80002ac8:	7a02                	ld	s4,32(sp)
    80002aca:	6ae2                	ld	s5,24(sp)
    80002acc:	6b42                	ld	s6,16(sp)
    80002ace:	6ba2                	ld	s7,8(sp)
    80002ad0:	6161                	addi	sp,sp,80
    80002ad2:	8082                	ret

0000000080002ad4 <schedls>:

void schedls()
{
    80002ad4:	1141                	addi	sp,sp,-16
    80002ad6:	e406                	sd	ra,8(sp)
    80002ad8:	e022                	sd	s0,0(sp)
    80002ada:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002adc:	00006517          	auipc	a0,0x6
    80002ae0:	81c50513          	addi	a0,a0,-2020 # 800082f8 <digits+0x2a8>
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	ab8080e7          	jalr	-1352(ra) # 8000059c <printf>
    printf("====================================\n");
    80002aec:	00006517          	auipc	a0,0x6
    80002af0:	83450513          	addi	a0,a0,-1996 # 80008320 <digits+0x2d0>
    80002af4:	ffffe097          	auipc	ra,0xffffe
    80002af8:	aa8080e7          	jalr	-1368(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002afc:	00006717          	auipc	a4,0x6
    80002b00:	f0c73703          	ld	a4,-244(a4) # 80008a08 <available_schedulers+0x10>
    80002b04:	00006797          	auipc	a5,0x6
    80002b08:	ea47b783          	ld	a5,-348(a5) # 800089a8 <sched_pointer>
    80002b0c:	04f70663          	beq	a4,a5,80002b58 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002b10:	00006517          	auipc	a0,0x6
    80002b14:	84050513          	addi	a0,a0,-1984 # 80008350 <digits+0x300>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	a84080e7          	jalr	-1404(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002b20:	00006617          	auipc	a2,0x6
    80002b24:	ef062603          	lw	a2,-272(a2) # 80008a10 <available_schedulers+0x18>
    80002b28:	00006597          	auipc	a1,0x6
    80002b2c:	ed058593          	addi	a1,a1,-304 # 800089f8 <available_schedulers>
    80002b30:	00006517          	auipc	a0,0x6
    80002b34:	82850513          	addi	a0,a0,-2008 # 80008358 <digits+0x308>
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	a64080e7          	jalr	-1436(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002b40:	00006517          	auipc	a0,0x6
    80002b44:	82050513          	addi	a0,a0,-2016 # 80008360 <digits+0x310>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a54080e7          	jalr	-1452(ra) # 8000059c <printf>
}
    80002b50:	60a2                	ld	ra,8(sp)
    80002b52:	6402                	ld	s0,0(sp)
    80002b54:	0141                	addi	sp,sp,16
    80002b56:	8082                	ret
            printf("[*]\t");
    80002b58:	00005517          	auipc	a0,0x5
    80002b5c:	7f050513          	addi	a0,a0,2032 # 80008348 <digits+0x2f8>
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	a3c080e7          	jalr	-1476(ra) # 8000059c <printf>
    80002b68:	bf65                	j	80002b20 <schedls+0x4c>

0000000080002b6a <schedset>:

void schedset(int id)
{
    80002b6a:	1141                	addi	sp,sp,-16
    80002b6c:	e406                	sd	ra,8(sp)
    80002b6e:	e022                	sd	s0,0(sp)
    80002b70:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002b72:	e90d                	bnez	a0,80002ba4 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002b74:	00006797          	auipc	a5,0x6
    80002b78:	e947b783          	ld	a5,-364(a5) # 80008a08 <available_schedulers+0x10>
    80002b7c:	00006717          	auipc	a4,0x6
    80002b80:	e2f73623          	sd	a5,-468(a4) # 800089a8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002b84:	00006597          	auipc	a1,0x6
    80002b88:	e7458593          	addi	a1,a1,-396 # 800089f8 <available_schedulers>
    80002b8c:	00006517          	auipc	a0,0x6
    80002b90:	81450513          	addi	a0,a0,-2028 # 800083a0 <digits+0x350>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	a08080e7          	jalr	-1528(ra) # 8000059c <printf>
}
    80002b9c:	60a2                	ld	ra,8(sp)
    80002b9e:	6402                	ld	s0,0(sp)
    80002ba0:	0141                	addi	sp,sp,16
    80002ba2:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	7d450513          	addi	a0,a0,2004 # 80008378 <digits+0x328>
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	9f0080e7          	jalr	-1552(ra) # 8000059c <printf>
        return;
    80002bb4:	b7e5                	j	80002b9c <schedset+0x32>

0000000080002bb6 <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    80002bb6:	7179                	addi	sp,sp,-48
    80002bb8:	f406                	sd	ra,40(sp)
    80002bba:	f022                	sd	s0,32(sp)
    80002bbc:	ec26                	sd	s1,24(sp)
    80002bbe:	e84a                	sd	s2,16(sp)
    80002bc0:	e44e                	sd	s3,8(sp)
    80002bc2:	e052                	sd	s4,0(sp)
    80002bc4:	1800                	addi	s0,sp,48
    80002bc6:	8a2a                	mv	s4,a0
    80002bc8:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    80002bca:	0002e497          	auipc	s1,0x2e
    80002bce:	56e48493          	addi	s1,s1,1390 # 80031138 <proc>
    80002bd2:	00034997          	auipc	s3,0x34
    80002bd6:	f6698993          	addi	s3,s3,-154 # 80036b38 <tickslock>
    80002bda:	a811                	j	80002bee <transvirtproc+0x38>
    {
	acquire(&p->lock);
	found = p->pid == pid && p->state != UNUSED; 
	release(&p->lock);
    80002bdc:	8526                	mv	a0,s1
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	36c080e7          	jalr	876(ra) # 80000f4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002be6:	16848493          	addi	s1,s1,360
    80002bea:	03348f63          	beq	s1,s3,80002c28 <transvirtproc+0x72>
	acquire(&p->lock);
    80002bee:	8526                	mv	a0,s1
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	2a6080e7          	jalr	678(ra) # 80000e96 <acquire>
	found = p->pid == pid && p->state != UNUSED; 
    80002bf8:	589c                	lw	a5,48(s1)
    80002bfa:	ff2791e3          	bne	a5,s2,80002bdc <transvirtproc+0x26>
    80002bfe:	4c9c                	lw	a5,24(s1)
    80002c00:	dff1                	beqz	a5,80002bdc <transvirtproc+0x26>
	release(&p->lock);
    80002c02:	8526                	mv	a0,s1
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	346080e7          	jalr	838(ra) # 80000f4a <release>
    if (!found) {
	return 0;
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002c0c:	68ac                	ld	a1,80(s1)
    80002c0e:	8552                	mv	a0,s4
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	ee2080e7          	jalr	-286(ra) # 80001af2 <transvirt>
}
    80002c18:	70a2                	ld	ra,40(sp)
    80002c1a:	7402                	ld	s0,32(sp)
    80002c1c:	64e2                	ld	s1,24(sp)
    80002c1e:	6942                	ld	s2,16(sp)
    80002c20:	69a2                	ld	s3,8(sp)
    80002c22:	6a02                	ld	s4,0(sp)
    80002c24:	6145                	addi	sp,sp,48
    80002c26:	8082                	ret
	return 0;
    80002c28:	4501                	li	a0,0
    80002c2a:	b7fd                	j	80002c18 <transvirtproc+0x62>

0000000080002c2c <swtch>:
    80002c2c:	00153023          	sd	ra,0(a0)
    80002c30:	00253423          	sd	sp,8(a0)
    80002c34:	e900                	sd	s0,16(a0)
    80002c36:	ed04                	sd	s1,24(a0)
    80002c38:	03253023          	sd	s2,32(a0)
    80002c3c:	03353423          	sd	s3,40(a0)
    80002c40:	03453823          	sd	s4,48(a0)
    80002c44:	03553c23          	sd	s5,56(a0)
    80002c48:	05653023          	sd	s6,64(a0)
    80002c4c:	05753423          	sd	s7,72(a0)
    80002c50:	05853823          	sd	s8,80(a0)
    80002c54:	05953c23          	sd	s9,88(a0)
    80002c58:	07a53023          	sd	s10,96(a0)
    80002c5c:	07b53423          	sd	s11,104(a0)
    80002c60:	0005b083          	ld	ra,0(a1)
    80002c64:	0085b103          	ld	sp,8(a1)
    80002c68:	6980                	ld	s0,16(a1)
    80002c6a:	6d84                	ld	s1,24(a1)
    80002c6c:	0205b903          	ld	s2,32(a1)
    80002c70:	0285b983          	ld	s3,40(a1)
    80002c74:	0305ba03          	ld	s4,48(a1)
    80002c78:	0385ba83          	ld	s5,56(a1)
    80002c7c:	0405bb03          	ld	s6,64(a1)
    80002c80:	0485bb83          	ld	s7,72(a1)
    80002c84:	0505bc03          	ld	s8,80(a1)
    80002c88:	0585bc83          	ld	s9,88(a1)
    80002c8c:	0605bd03          	ld	s10,96(a1)
    80002c90:	0685bd83          	ld	s11,104(a1)
    80002c94:	8082                	ret

0000000080002c96 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c96:	1141                	addi	sp,sp,-16
    80002c98:	e406                	sd	ra,8(sp)
    80002c9a:	e022                	sd	s0,0(sp)
    80002c9c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c9e:	00005597          	auipc	a1,0x5
    80002ca2:	78a58593          	addi	a1,a1,1930 # 80008428 <states.0+0x30>
    80002ca6:	00034517          	auipc	a0,0x34
    80002caa:	e9250513          	addi	a0,a0,-366 # 80036b38 <tickslock>
    80002cae:	ffffe097          	auipc	ra,0xffffe
    80002cb2:	158080e7          	jalr	344(ra) # 80000e06 <initlock>
}
    80002cb6:	60a2                	ld	ra,8(sp)
    80002cb8:	6402                	ld	s0,0(sp)
    80002cba:	0141                	addi	sp,sp,16
    80002cbc:	8082                	ret

0000000080002cbe <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002cbe:	1141                	addi	sp,sp,-16
    80002cc0:	e422                	sd	s0,8(sp)
    80002cc2:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002cc4:	00003797          	auipc	a5,0x3
    80002cc8:	6bc78793          	addi	a5,a5,1724 # 80006380 <kernelvec>
    80002ccc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002cd0:	6422                	ld	s0,8(sp)
    80002cd2:	0141                	addi	sp,sp,16
    80002cd4:	8082                	ret

0000000080002cd6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002cd6:	1141                	addi	sp,sp,-16
    80002cd8:	e406                	sd	ra,8(sp)
    80002cda:	e022                	sd	s0,0(sp)
    80002cdc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002cde:	fffff097          	auipc	ra,0xfffff
    80002ce2:	0e4080e7          	jalr	228(ra) # 80001dc2 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002ce6:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002cea:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002cec:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002cf0:	00004697          	auipc	a3,0x4
    80002cf4:	31068693          	addi	a3,a3,784 # 80007000 <_trampoline>
    80002cf8:	00004717          	auipc	a4,0x4
    80002cfc:	30870713          	addi	a4,a4,776 # 80007000 <_trampoline>
    80002d00:	8f15                	sub	a4,a4,a3
    80002d02:	040007b7          	lui	a5,0x4000
    80002d06:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002d08:	07b2                	slli	a5,a5,0xc
    80002d0a:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002d0c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d10:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002d12:	18002673          	csrr	a2,satp
    80002d16:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d18:	6d30                	ld	a2,88(a0)
    80002d1a:	6138                	ld	a4,64(a0)
    80002d1c:	6585                	lui	a1,0x1
    80002d1e:	972e                	add	a4,a4,a1
    80002d20:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d22:	6d38                	ld	a4,88(a0)
    80002d24:	00000617          	auipc	a2,0x0
    80002d28:	13060613          	addi	a2,a2,304 # 80002e54 <usertrap>
    80002d2c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d2e:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002d30:	8612                	mv	a2,tp
    80002d32:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002d34:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d38:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d3c:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002d40:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d44:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002d46:	6f18                	ld	a4,24(a4)
    80002d48:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d4c:	6928                	ld	a0,80(a0)
    80002d4e:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002d50:	00004717          	auipc	a4,0x4
    80002d54:	34c70713          	addi	a4,a4,844 # 8000709c <userret>
    80002d58:	8f15                	sub	a4,a4,a3
    80002d5a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002d5c:	577d                	li	a4,-1
    80002d5e:	177e                	slli	a4,a4,0x3f
    80002d60:	8d59                	or	a0,a0,a4
    80002d62:	9782                	jalr	a5
}
    80002d64:	60a2                	ld	ra,8(sp)
    80002d66:	6402                	ld	s0,0(sp)
    80002d68:	0141                	addi	sp,sp,16
    80002d6a:	8082                	ret

0000000080002d6c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d76:	00034497          	auipc	s1,0x34
    80002d7a:	dc248493          	addi	s1,s1,-574 # 80036b38 <tickslock>
    80002d7e:	8526                	mv	a0,s1
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	116080e7          	jalr	278(ra) # 80000e96 <acquire>
  ticks++;
    80002d88:	00006517          	auipc	a0,0x6
    80002d8c:	cf850513          	addi	a0,a0,-776 # 80008a80 <ticks>
    80002d90:	411c                	lw	a5,0(a0)
    80002d92:	2785                	addiw	a5,a5,1
    80002d94:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	83e080e7          	jalr	-1986(ra) # 800025d4 <wakeup>
  release(&tickslock);
    80002d9e:	8526                	mv	a0,s1
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	1aa080e7          	jalr	426(ra) # 80000f4a <release>
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	64a2                	ld	s1,8(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, scause" : "=r"(x));
    80002dbc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002dc0:	00074d63          	bltz	a4,80002dda <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002dc4:	57fd                	li	a5,-1
    80002dc6:	17fe                	slli	a5,a5,0x3f
    80002dc8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002dca:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002dcc:	06f70363          	beq	a4,a5,80002e32 <devintr+0x80>
  }
}
    80002dd0:	60e2                	ld	ra,24(sp)
    80002dd2:	6442                	ld	s0,16(sp)
    80002dd4:	64a2                	ld	s1,8(sp)
    80002dd6:	6105                	addi	sp,sp,32
    80002dd8:	8082                	ret
     (scause & 0xff) == 9){
    80002dda:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002dde:	46a5                	li	a3,9
    80002de0:	fed792e3          	bne	a5,a3,80002dc4 <devintr+0x12>
    int irq = plic_claim();
    80002de4:	00003097          	auipc	ra,0x3
    80002de8:	6a4080e7          	jalr	1700(ra) # 80006488 <plic_claim>
    80002dec:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002dee:	47a9                	li	a5,10
    80002df0:	02f50763          	beq	a0,a5,80002e1e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002df4:	4785                	li	a5,1
    80002df6:	02f50963          	beq	a0,a5,80002e28 <devintr+0x76>
    return 1;
    80002dfa:	4505                	li	a0,1
    } else if(irq){
    80002dfc:	d8f1                	beqz	s1,80002dd0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002dfe:	85a6                	mv	a1,s1
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	63050513          	addi	a0,a0,1584 # 80008430 <states.0+0x38>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	794080e7          	jalr	1940(ra) # 8000059c <printf>
      plic_complete(irq);
    80002e10:	8526                	mv	a0,s1
    80002e12:	00003097          	auipc	ra,0x3
    80002e16:	69a080e7          	jalr	1690(ra) # 800064ac <plic_complete>
    return 1;
    80002e1a:	4505                	li	a0,1
    80002e1c:	bf55                	j	80002dd0 <devintr+0x1e>
      uartintr();
    80002e1e:	ffffe097          	auipc	ra,0xffffe
    80002e22:	b8c080e7          	jalr	-1140(ra) # 800009aa <uartintr>
    80002e26:	b7ed                	j	80002e10 <devintr+0x5e>
      virtio_disk_intr();
    80002e28:	00004097          	auipc	ra,0x4
    80002e2c:	b4c080e7          	jalr	-1204(ra) # 80006974 <virtio_disk_intr>
    80002e30:	b7c5                	j	80002e10 <devintr+0x5e>
    if(cpuid() == 0){
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	f64080e7          	jalr	-156(ra) # 80001d96 <cpuid>
    80002e3a:	c901                	beqz	a0,80002e4a <devintr+0x98>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002e3c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e40:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002e42:	14479073          	csrw	sip,a5
    return 2;
    80002e46:	4509                	li	a0,2
    80002e48:	b761                	j	80002dd0 <devintr+0x1e>
      clockintr();
    80002e4a:	00000097          	auipc	ra,0x0
    80002e4e:	f22080e7          	jalr	-222(ra) # 80002d6c <clockintr>
    80002e52:	b7ed                	j	80002e3c <devintr+0x8a>

0000000080002e54 <usertrap>:
{
    80002e54:	7179                	addi	sp,sp,-48
    80002e56:	f406                	sd	ra,40(sp)
    80002e58:	f022                	sd	s0,32(sp)
    80002e5a:	ec26                	sd	s1,24(sp)
    80002e5c:	e84a                	sd	s2,16(sp)
    80002e5e:	e44e                	sd	s3,8(sp)
    80002e60:	e052                	sd	s4,0(sp)
    80002e62:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002e64:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e68:	1007f793          	andi	a5,a5,256
    80002e6c:	eba9                	bnez	a5,80002ebe <usertrap+0x6a>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002e6e:	00003797          	auipc	a5,0x3
    80002e72:	51278793          	addi	a5,a5,1298 # 80006380 <kernelvec>
    80002e76:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e7a:	fffff097          	auipc	ra,0xfffff
    80002e7e:	f48080e7          	jalr	-184(ra) # 80001dc2 <myproc>
    80002e82:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e84:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002e86:	14102773          	csrr	a4,sepc
    80002e8a:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002e8c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e90:	47a1                	li	a5,8
    80002e92:	02f70e63          	beq	a4,a5,80002ece <usertrap+0x7a>
    80002e96:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002e9a:	47bd                	li	a5,15
    80002e9c:	08f70563          	beq	a4,a5,80002f26 <usertrap+0xd2>
  } else if((which_dev = devintr()) != 0){
    80002ea0:	00000097          	auipc	ra,0x0
    80002ea4:	f12080e7          	jalr	-238(ra) # 80002db2 <devintr>
    80002ea8:	892a                	mv	s2,a0
    80002eaa:	12050c63          	beqz	a0,80002fe2 <usertrap+0x18e>
  if(killed(p))
    80002eae:	8526                	mv	a0,s1
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	968080e7          	jalr	-1688(ra) # 80002818 <killed>
    80002eb8:	16050863          	beqz	a0,80003028 <usertrap+0x1d4>
    80002ebc:	a28d                	j	8000301e <usertrap+0x1ca>
    panic("usertrap: not from user mode");
    80002ebe:	00005517          	auipc	a0,0x5
    80002ec2:	59250513          	addi	a0,a0,1426 # 80008450 <states.0+0x58>
    80002ec6:	ffffd097          	auipc	ra,0xffffd
    80002eca:	67a080e7          	jalr	1658(ra) # 80000540 <panic>
    if(killed(p))
    80002ece:	00000097          	auipc	ra,0x0
    80002ed2:	94a080e7          	jalr	-1718(ra) # 80002818 <killed>
    80002ed6:	e131                	bnez	a0,80002f1a <usertrap+0xc6>
    p->trapframe->epc += 4;
    80002ed8:	6cb8                	ld	a4,88(s1)
    80002eda:	6f1c                	ld	a5,24(a4)
    80002edc:	0791                	addi	a5,a5,4
    80002ede:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002ee0:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ee4:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002ee8:	10079073          	csrw	sstatus,a5
    syscall();
    80002eec:	00000097          	auipc	ra,0x0
    80002ef0:	396080e7          	jalr	918(ra) # 80003282 <syscall>
  if(killed(p))
    80002ef4:	8526                	mv	a0,s1
    80002ef6:	00000097          	auipc	ra,0x0
    80002efa:	922080e7          	jalr	-1758(ra) # 80002818 <killed>
    80002efe:	10051f63          	bnez	a0,8000301c <usertrap+0x1c8>
  usertrapret();
    80002f02:	00000097          	auipc	ra,0x0
    80002f06:	dd4080e7          	jalr	-556(ra) # 80002cd6 <usertrapret>
}
    80002f0a:	70a2                	ld	ra,40(sp)
    80002f0c:	7402                	ld	s0,32(sp)
    80002f0e:	64e2                	ld	s1,24(sp)
    80002f10:	6942                	ld	s2,16(sp)
    80002f12:	69a2                	ld	s3,8(sp)
    80002f14:	6a02                	ld	s4,0(sp)
    80002f16:	6145                	addi	sp,sp,48
    80002f18:	8082                	ret
      exit(-1);
    80002f1a:	557d                	li	a0,-1
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	788080e7          	jalr	1928(ra) # 800026a4 <exit>
    80002f24:	bf55                	j	80002ed8 <usertrap+0x84>
    asm volatile("csrr %0, stval" : "=r"(x));
    80002f26:	143029f3          	csrr	s3,stval
    uint64 va = PGROUNDDOWN(r_stval());
    80002f2a:	77fd                	lui	a5,0xfffff
    80002f2c:	00f9f9b3          	and	s3,s3,a5
    acquire(&p->lock);
    80002f30:	ffffe097          	auipc	ra,0xffffe
    80002f34:	f66080e7          	jalr	-154(ra) # 80000e96 <acquire>
    pagetable_t pgtable = p->pagetable;
    80002f38:	0504b903          	ld	s2,80(s1)
    int pid = p->pid;
    80002f3c:	0304aa03          	lw	s4,48(s1)
    release(&p->lock);
    80002f40:	8526                	mv	a0,s1
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	008080e7          	jalr	8(ra) # 80000f4a <release>
    pte_t *pgentry = walk(pgtable, va, 0);
    80002f4a:	4601                	li	a2,0
    80002f4c:	85ce                	mv	a1,s3
    80002f4e:	854a                	mv	a0,s2
    80002f50:	ffffe097          	auipc	ra,0xffffe
    80002f54:	326080e7          	jalr	806(ra) # 80001276 <walk>
    80002f58:	892a                	mv	s2,a0
    if (!pgentry) {
    80002f5a:	c525                	beqz	a0,80002fc2 <usertrap+0x16e>
    int isCOW = PTE_COW & *pgentry;
    80002f5c:	611c                	ld	a5,0(a0)
    if (isCOW)
    80002f5e:	2007f713          	andi	a4,a5,512
    80002f62:	db49                	beqz	a4,80002ef4 <usertrap+0xa0>
      *pgentry &= ~PTE_COW;
    80002f64:	dff7f793          	andi	a5,a5,-513
      *pgentry |= PTE_W;
    80002f68:	0047e793          	ori	a5,a5,4
    80002f6c:	e11c                	sd	a5,0(a0)
      uint64 pa = transvirtproc(va, pid);
    80002f6e:	85d2                	mv	a1,s4
    80002f70:	854e                	mv	a0,s3
    80002f72:	00000097          	auipc	ra,0x0
    80002f76:	c44080e7          	jalr	-956(ra) # 80002bb6 <transvirtproc>
    80002f7a:	8a2a                	mv	s4,a0
      int refcount = getrefcount(pa);
    80002f7c:	ffffe097          	auipc	ra,0xffffe
    80002f80:	aaa080e7          	jalr	-1366(ra) # 80000a26 <getrefcount>
      if (refcount > 1) {
    80002f84:	4785                	li	a5,1
    80002f86:	f6a7d7e3          	bge	a5,a0,80002ef4 <usertrap+0xa0>
	decrefcount(pa);
    80002f8a:	8552                	mv	a0,s4
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	aea080e7          	jalr	-1302(ra) # 80000a76 <decrefcount>
	void* new = kalloc();
    80002f94:	ffffe097          	auipc	ra,0xffffe
    80002f98:	d78080e7          	jalr	-648(ra) # 80000d0c <kalloc>
    80002f9c:	89aa                	mv	s3,a0
	if (new == 0)
    80002f9e:	c915                	beqz	a0,80002fd2 <usertrap+0x17e>
	memmove(new, (void*) pa, PGSIZE);
    80002fa0:	6605                	lui	a2,0x1
    80002fa2:	85d2                	mv	a1,s4
    80002fa4:	ffffe097          	auipc	ra,0xffffe
    80002fa8:	04a080e7          	jalr	74(ra) # 80000fee <memmove>
	*pgentry = PA2PTE(new) | flags;
    80002fac:	00c9d793          	srli	a5,s3,0xc
    80002fb0:	07aa                	slli	a5,a5,0xa
	uint flags = PTE_FLAGS(*pgentry);
    80002fb2:	00093703          	ld	a4,0(s2)
	*pgentry = PA2PTE(new) | flags;
    80002fb6:	3ff77713          	andi	a4,a4,1023
    80002fba:	8fd9                	or	a5,a5,a4
    80002fbc:	00f93023          	sd	a5,0(s2)
    80002fc0:	bf15                	j	80002ef4 <usertrap+0xa0>
      panic("todo");
    80002fc2:	00005517          	auipc	a0,0x5
    80002fc6:	4ae50513          	addi	a0,a0,1198 # 80008470 <states.0+0x78>
    80002fca:	ffffd097          	auipc	ra,0xffffd
    80002fce:	576080e7          	jalr	1398(ra) # 80000540 <panic>
	  panic("todo");
    80002fd2:	00005517          	auipc	a0,0x5
    80002fd6:	49e50513          	addi	a0,a0,1182 # 80008470 <states.0+0x78>
    80002fda:	ffffd097          	auipc	ra,0xffffd
    80002fde:	566080e7          	jalr	1382(ra) # 80000540 <panic>
    asm volatile("csrr %0, scause" : "=r"(x));
    80002fe2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002fe6:	5890                	lw	a2,48(s1)
    80002fe8:	00005517          	auipc	a0,0x5
    80002fec:	49050513          	addi	a0,a0,1168 # 80008478 <states.0+0x80>
    80002ff0:	ffffd097          	auipc	ra,0xffffd
    80002ff4:	5ac080e7          	jalr	1452(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002ff8:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002ffc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003000:	00005517          	auipc	a0,0x5
    80003004:	4a850513          	addi	a0,a0,1192 # 800084a8 <states.0+0xb0>
    80003008:	ffffd097          	auipc	ra,0xffffd
    8000300c:	594080e7          	jalr	1428(ra) # 8000059c <printf>
    setkilled(p);
    80003010:	8526                	mv	a0,s1
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	7da080e7          	jalr	2010(ra) # 800027ec <setkilled>
    8000301a:	bde9                	j	80002ef4 <usertrap+0xa0>
  if(killed(p))
    8000301c:	4901                	li	s2,0
    exit(-1);
    8000301e:	557d                	li	a0,-1
    80003020:	fffff097          	auipc	ra,0xfffff
    80003024:	684080e7          	jalr	1668(ra) # 800026a4 <exit>
  if(which_dev == 2)
    80003028:	4789                	li	a5,2
    8000302a:	ecf91ce3          	bne	s2,a5,80002f02 <usertrap+0xae>
    yield();
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	506080e7          	jalr	1286(ra) # 80002534 <yield>
    80003036:	b5f1                	j	80002f02 <usertrap+0xae>

0000000080003038 <kerneltrap>:
{
    80003038:	7179                	addi	sp,sp,-48
    8000303a:	f406                	sd	ra,40(sp)
    8000303c:	f022                	sd	s0,32(sp)
    8000303e:	ec26                	sd	s1,24(sp)
    80003040:	e84a                	sd	s2,16(sp)
    80003042:	e44e                	sd	s3,8(sp)
    80003044:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003046:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000304a:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    8000304e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003052:	1004f793          	andi	a5,s1,256
    80003056:	cb85                	beqz	a5,80003086 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003058:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    8000305c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000305e:	ef85                	bnez	a5,80003096 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003060:	00000097          	auipc	ra,0x0
    80003064:	d52080e7          	jalr	-686(ra) # 80002db2 <devintr>
    80003068:	cd1d                	beqz	a0,800030a6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000306a:	4789                	li	a5,2
    8000306c:	06f50a63          	beq	a0,a5,800030e0 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80003070:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80003074:	10049073          	csrw	sstatus,s1
}
    80003078:	70a2                	ld	ra,40(sp)
    8000307a:	7402                	ld	s0,32(sp)
    8000307c:	64e2                	ld	s1,24(sp)
    8000307e:	6942                	ld	s2,16(sp)
    80003080:	69a2                	ld	s3,8(sp)
    80003082:	6145                	addi	sp,sp,48
    80003084:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003086:	00005517          	auipc	a0,0x5
    8000308a:	44250513          	addi	a0,a0,1090 # 800084c8 <states.0+0xd0>
    8000308e:	ffffd097          	auipc	ra,0xffffd
    80003092:	4b2080e7          	jalr	1202(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80003096:	00005517          	auipc	a0,0x5
    8000309a:	45a50513          	addi	a0,a0,1114 # 800084f0 <states.0+0xf8>
    8000309e:	ffffd097          	auipc	ra,0xffffd
    800030a2:	4a2080e7          	jalr	1186(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    800030a6:	85ce                	mv	a1,s3
    800030a8:	00005517          	auipc	a0,0x5
    800030ac:	46850513          	addi	a0,a0,1128 # 80008510 <states.0+0x118>
    800030b0:	ffffd097          	auipc	ra,0xffffd
    800030b4:	4ec080e7          	jalr	1260(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800030b8:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800030bc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030c0:	00005517          	auipc	a0,0x5
    800030c4:	46050513          	addi	a0,a0,1120 # 80008520 <states.0+0x128>
    800030c8:	ffffd097          	auipc	ra,0xffffd
    800030cc:	4d4080e7          	jalr	1236(ra) # 8000059c <printf>
    panic("kerneltrap");
    800030d0:	00005517          	auipc	a0,0x5
    800030d4:	46850513          	addi	a0,a0,1128 # 80008538 <states.0+0x140>
    800030d8:	ffffd097          	auipc	ra,0xffffd
    800030dc:	468080e7          	jalr	1128(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030e0:	fffff097          	auipc	ra,0xfffff
    800030e4:	ce2080e7          	jalr	-798(ra) # 80001dc2 <myproc>
    800030e8:	d541                	beqz	a0,80003070 <kerneltrap+0x38>
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	cd8080e7          	jalr	-808(ra) # 80001dc2 <myproc>
    800030f2:	4d18                	lw	a4,24(a0)
    800030f4:	4791                	li	a5,4
    800030f6:	f6f71de3          	bne	a4,a5,80003070 <kerneltrap+0x38>
    yield();
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	43a080e7          	jalr	1082(ra) # 80002534 <yield>
    80003102:	b7bd                	j	80003070 <kerneltrap+0x38>

0000000080003104 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	1000                	addi	s0,sp,32
    8000310e:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	cb2080e7          	jalr	-846(ra) # 80001dc2 <myproc>
    switch (n)
    80003118:	4795                	li	a5,5
    8000311a:	0497e163          	bltu	a5,s1,8000315c <argraw+0x58>
    8000311e:	048a                	slli	s1,s1,0x2
    80003120:	00005717          	auipc	a4,0x5
    80003124:	45070713          	addi	a4,a4,1104 # 80008570 <states.0+0x178>
    80003128:	94ba                	add	s1,s1,a4
    8000312a:	409c                	lw	a5,0(s1)
    8000312c:	97ba                	add	a5,a5,a4
    8000312e:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80003130:	6d3c                	ld	a5,88(a0)
    80003132:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80003134:	60e2                	ld	ra,24(sp)
    80003136:	6442                	ld	s0,16(sp)
    80003138:	64a2                	ld	s1,8(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret
        return p->trapframe->a1;
    8000313e:	6d3c                	ld	a5,88(a0)
    80003140:	7fa8                	ld	a0,120(a5)
    80003142:	bfcd                	j	80003134 <argraw+0x30>
        return p->trapframe->a2;
    80003144:	6d3c                	ld	a5,88(a0)
    80003146:	63c8                	ld	a0,128(a5)
    80003148:	b7f5                	j	80003134 <argraw+0x30>
        return p->trapframe->a3;
    8000314a:	6d3c                	ld	a5,88(a0)
    8000314c:	67c8                	ld	a0,136(a5)
    8000314e:	b7dd                	j	80003134 <argraw+0x30>
        return p->trapframe->a4;
    80003150:	6d3c                	ld	a5,88(a0)
    80003152:	6bc8                	ld	a0,144(a5)
    80003154:	b7c5                	j	80003134 <argraw+0x30>
        return p->trapframe->a5;
    80003156:	6d3c                	ld	a5,88(a0)
    80003158:	6fc8                	ld	a0,152(a5)
    8000315a:	bfe9                	j	80003134 <argraw+0x30>
    panic("argraw");
    8000315c:	00005517          	auipc	a0,0x5
    80003160:	3ec50513          	addi	a0,a0,1004 # 80008548 <states.0+0x150>
    80003164:	ffffd097          	auipc	ra,0xffffd
    80003168:	3dc080e7          	jalr	988(ra) # 80000540 <panic>

000000008000316c <fetchaddr>:
{
    8000316c:	1101                	addi	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	e426                	sd	s1,8(sp)
    80003174:	e04a                	sd	s2,0(sp)
    80003176:	1000                	addi	s0,sp,32
    80003178:	84aa                	mv	s1,a0
    8000317a:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000317c:	fffff097          	auipc	ra,0xfffff
    80003180:	c46080e7          	jalr	-954(ra) # 80001dc2 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003184:	653c                	ld	a5,72(a0)
    80003186:	02f4f863          	bgeu	s1,a5,800031b6 <fetchaddr+0x4a>
    8000318a:	00848713          	addi	a4,s1,8
    8000318e:	02e7e663          	bltu	a5,a4,800031ba <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003192:	46a1                	li	a3,8
    80003194:	8626                	mv	a2,s1
    80003196:	85ca                	mv	a1,s2
    80003198:	6928                	ld	a0,80(a0)
    8000319a:	fffff097          	auipc	ra,0xfffff
    8000319e:	81a080e7          	jalr	-2022(ra) # 800019b4 <copyin>
    800031a2:	00a03533          	snez	a0,a0
    800031a6:	40a00533          	neg	a0,a0
}
    800031aa:	60e2                	ld	ra,24(sp)
    800031ac:	6442                	ld	s0,16(sp)
    800031ae:	64a2                	ld	s1,8(sp)
    800031b0:	6902                	ld	s2,0(sp)
    800031b2:	6105                	addi	sp,sp,32
    800031b4:	8082                	ret
        return -1;
    800031b6:	557d                	li	a0,-1
    800031b8:	bfcd                	j	800031aa <fetchaddr+0x3e>
    800031ba:	557d                	li	a0,-1
    800031bc:	b7fd                	j	800031aa <fetchaddr+0x3e>

00000000800031be <fetchstr>:
{
    800031be:	7179                	addi	sp,sp,-48
    800031c0:	f406                	sd	ra,40(sp)
    800031c2:	f022                	sd	s0,32(sp)
    800031c4:	ec26                	sd	s1,24(sp)
    800031c6:	e84a                	sd	s2,16(sp)
    800031c8:	e44e                	sd	s3,8(sp)
    800031ca:	1800                	addi	s0,sp,48
    800031cc:	892a                	mv	s2,a0
    800031ce:	84ae                	mv	s1,a1
    800031d0:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    800031d2:	fffff097          	auipc	ra,0xfffff
    800031d6:	bf0080e7          	jalr	-1040(ra) # 80001dc2 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800031da:	86ce                	mv	a3,s3
    800031dc:	864a                	mv	a2,s2
    800031de:	85a6                	mv	a1,s1
    800031e0:	6928                	ld	a0,80(a0)
    800031e2:	fffff097          	auipc	ra,0xfffff
    800031e6:	860080e7          	jalr	-1952(ra) # 80001a42 <copyinstr>
    800031ea:	00054e63          	bltz	a0,80003206 <fetchstr+0x48>
    return strlen(buf);
    800031ee:	8526                	mv	a0,s1
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	f1e080e7          	jalr	-226(ra) # 8000110e <strlen>
}
    800031f8:	70a2                	ld	ra,40(sp)
    800031fa:	7402                	ld	s0,32(sp)
    800031fc:	64e2                	ld	s1,24(sp)
    800031fe:	6942                	ld	s2,16(sp)
    80003200:	69a2                	ld	s3,8(sp)
    80003202:	6145                	addi	sp,sp,48
    80003204:	8082                	ret
        return -1;
    80003206:	557d                	li	a0,-1
    80003208:	bfc5                	j	800031f8 <fetchstr+0x3a>

000000008000320a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
    80003214:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	eee080e7          	jalr	-274(ra) # 80003104 <argraw>
    8000321e:	c088                	sw	a0,0(s1)
}
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	64a2                	ld	s1,8(sp)
    80003226:	6105                	addi	sp,sp,32
    80003228:	8082                	ret

000000008000322a <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    8000322a:	1101                	addi	sp,sp,-32
    8000322c:	ec06                	sd	ra,24(sp)
    8000322e:	e822                	sd	s0,16(sp)
    80003230:	e426                	sd	s1,8(sp)
    80003232:	1000                	addi	s0,sp,32
    80003234:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	ece080e7          	jalr	-306(ra) # 80003104 <argraw>
    8000323e:	e088                	sd	a0,0(s1)
}
    80003240:	60e2                	ld	ra,24(sp)
    80003242:	6442                	ld	s0,16(sp)
    80003244:	64a2                	ld	s1,8(sp)
    80003246:	6105                	addi	sp,sp,32
    80003248:	8082                	ret

000000008000324a <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    8000324a:	7179                	addi	sp,sp,-48
    8000324c:	f406                	sd	ra,40(sp)
    8000324e:	f022                	sd	s0,32(sp)
    80003250:	ec26                	sd	s1,24(sp)
    80003252:	e84a                	sd	s2,16(sp)
    80003254:	1800                	addi	s0,sp,48
    80003256:	84ae                	mv	s1,a1
    80003258:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    8000325a:	fd840593          	addi	a1,s0,-40
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	fcc080e7          	jalr	-52(ra) # 8000322a <argaddr>
    return fetchstr(addr, buf, max);
    80003266:	864a                	mv	a2,s2
    80003268:	85a6                	mv	a1,s1
    8000326a:	fd843503          	ld	a0,-40(s0)
    8000326e:	00000097          	auipc	ra,0x0
    80003272:	f50080e7          	jalr	-176(ra) # 800031be <fetchstr>
}
    80003276:	70a2                	ld	ra,40(sp)
    80003278:	7402                	ld	s0,32(sp)
    8000327a:	64e2                	ld	s1,24(sp)
    8000327c:	6942                	ld	s2,16(sp)
    8000327e:	6145                	addi	sp,sp,48
    80003280:	8082                	ret

0000000080003282 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80003282:	1101                	addi	sp,sp,-32
    80003284:	ec06                	sd	ra,24(sp)
    80003286:	e822                	sd	s0,16(sp)
    80003288:	e426                	sd	s1,8(sp)
    8000328a:	e04a                	sd	s2,0(sp)
    8000328c:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    8000328e:	fffff097          	auipc	ra,0xfffff
    80003292:	b34080e7          	jalr	-1228(ra) # 80001dc2 <myproc>
    80003296:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003298:	05853903          	ld	s2,88(a0)
    8000329c:	0a893783          	ld	a5,168(s2)
    800032a0:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800032a4:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffbd0e7>
    800032a6:	4765                	li	a4,25
    800032a8:	00f76f63          	bltu	a4,a5,800032c6 <syscall+0x44>
    800032ac:	00369713          	slli	a4,a3,0x3
    800032b0:	00005797          	auipc	a5,0x5
    800032b4:	2d878793          	addi	a5,a5,728 # 80008588 <syscalls>
    800032b8:	97ba                	add	a5,a5,a4
    800032ba:	639c                	ld	a5,0(a5)
    800032bc:	c789                	beqz	a5,800032c6 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800032be:	9782                	jalr	a5
    800032c0:	06a93823          	sd	a0,112(s2)
    800032c4:	a839                	j	800032e2 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800032c6:	15848613          	addi	a2,s1,344
    800032ca:	588c                	lw	a1,48(s1)
    800032cc:	00005517          	auipc	a0,0x5
    800032d0:	28450513          	addi	a0,a0,644 # 80008550 <states.0+0x158>
    800032d4:	ffffd097          	auipc	ra,0xffffd
    800032d8:	2c8080e7          	jalr	712(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    800032dc:	6cbc                	ld	a5,88(s1)
    800032de:	577d                	li	a4,-1
    800032e0:	fbb8                	sd	a4,112(a5)
    }
}
    800032e2:	60e2                	ld	ra,24(sp)
    800032e4:	6442                	ld	s0,16(sp)
    800032e6:	64a2                	ld	s1,8(sp)
    800032e8:	6902                	ld	s2,0(sp)
    800032ea:	6105                	addi	sp,sp,32
    800032ec:	8082                	ret

00000000800032ee <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    800032ee:	1101                	addi	sp,sp,-32
    800032f0:	ec06                	sd	ra,24(sp)
    800032f2:	e822                	sd	s0,16(sp)
    800032f4:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    800032f6:	fec40593          	addi	a1,s0,-20
    800032fa:	4501                	li	a0,0
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	f0e080e7          	jalr	-242(ra) # 8000320a <argint>
    exit(n);
    80003304:	fec42503          	lw	a0,-20(s0)
    80003308:	fffff097          	auipc	ra,0xfffff
    8000330c:	39c080e7          	jalr	924(ra) # 800026a4 <exit>
    return 0; // not reached
}
    80003310:	4501                	li	a0,0
    80003312:	60e2                	ld	ra,24(sp)
    80003314:	6442                	ld	s0,16(sp)
    80003316:	6105                	addi	sp,sp,32
    80003318:	8082                	ret

000000008000331a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000331a:	1141                	addi	sp,sp,-16
    8000331c:	e406                	sd	ra,8(sp)
    8000331e:	e022                	sd	s0,0(sp)
    80003320:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003322:	fffff097          	auipc	ra,0xfffff
    80003326:	aa0080e7          	jalr	-1376(ra) # 80001dc2 <myproc>
}
    8000332a:	5908                	lw	a0,48(a0)
    8000332c:	60a2                	ld	ra,8(sp)
    8000332e:	6402                	ld	s0,0(sp)
    80003330:	0141                	addi	sp,sp,16
    80003332:	8082                	ret

0000000080003334 <sys_fork>:

uint64
sys_fork(void)
{
    80003334:	1141                	addi	sp,sp,-16
    80003336:	e406                	sd	ra,8(sp)
    80003338:	e022                	sd	s0,0(sp)
    8000333a:	0800                	addi	s0,sp,16
    return fork();
    8000333c:	fffff097          	auipc	ra,0xfffff
    80003340:	fd2080e7          	jalr	-46(ra) # 8000230e <fork>
}
    80003344:	60a2                	ld	ra,8(sp)
    80003346:	6402                	ld	s0,0(sp)
    80003348:	0141                	addi	sp,sp,16
    8000334a:	8082                	ret

000000008000334c <sys_wait>:

uint64
sys_wait(void)
{
    8000334c:	1101                	addi	sp,sp,-32
    8000334e:	ec06                	sd	ra,24(sp)
    80003350:	e822                	sd	s0,16(sp)
    80003352:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003354:	fe840593          	addi	a1,s0,-24
    80003358:	4501                	li	a0,0
    8000335a:	00000097          	auipc	ra,0x0
    8000335e:	ed0080e7          	jalr	-304(ra) # 8000322a <argaddr>
    return wait(p);
    80003362:	fe843503          	ld	a0,-24(s0)
    80003366:	fffff097          	auipc	ra,0xfffff
    8000336a:	4e4080e7          	jalr	1252(ra) # 8000284a <wait>
}
    8000336e:	60e2                	ld	ra,24(sp)
    80003370:	6442                	ld	s0,16(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret

0000000080003376 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003376:	7179                	addi	sp,sp,-48
    80003378:	f406                	sd	ra,40(sp)
    8000337a:	f022                	sd	s0,32(sp)
    8000337c:	ec26                	sd	s1,24(sp)
    8000337e:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003380:	fdc40593          	addi	a1,s0,-36
    80003384:	4501                	li	a0,0
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	e84080e7          	jalr	-380(ra) # 8000320a <argint>
    addr = myproc()->sz;
    8000338e:	fffff097          	auipc	ra,0xfffff
    80003392:	a34080e7          	jalr	-1484(ra) # 80001dc2 <myproc>
    80003396:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003398:	fdc42503          	lw	a0,-36(s0)
    8000339c:	fffff097          	auipc	ra,0xfffff
    800033a0:	d80080e7          	jalr	-640(ra) # 8000211c <growproc>
    800033a4:	00054863          	bltz	a0,800033b4 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800033a8:	8526                	mv	a0,s1
    800033aa:	70a2                	ld	ra,40(sp)
    800033ac:	7402                	ld	s0,32(sp)
    800033ae:	64e2                	ld	s1,24(sp)
    800033b0:	6145                	addi	sp,sp,48
    800033b2:	8082                	ret
        return -1;
    800033b4:	54fd                	li	s1,-1
    800033b6:	bfcd                	j	800033a8 <sys_sbrk+0x32>

00000000800033b8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800033b8:	7139                	addi	sp,sp,-64
    800033ba:	fc06                	sd	ra,56(sp)
    800033bc:	f822                	sd	s0,48(sp)
    800033be:	f426                	sd	s1,40(sp)
    800033c0:	f04a                	sd	s2,32(sp)
    800033c2:	ec4e                	sd	s3,24(sp)
    800033c4:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800033c6:	fcc40593          	addi	a1,s0,-52
    800033ca:	4501                	li	a0,0
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	e3e080e7          	jalr	-450(ra) # 8000320a <argint>
    acquire(&tickslock);
    800033d4:	00033517          	auipc	a0,0x33
    800033d8:	76450513          	addi	a0,a0,1892 # 80036b38 <tickslock>
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	aba080e7          	jalr	-1350(ra) # 80000e96 <acquire>
    ticks0 = ticks;
    800033e4:	00005917          	auipc	s2,0x5
    800033e8:	69c92903          	lw	s2,1692(s2) # 80008a80 <ticks>
    while (ticks - ticks0 < n)
    800033ec:	fcc42783          	lw	a5,-52(s0)
    800033f0:	cf9d                	beqz	a5,8000342e <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800033f2:	00033997          	auipc	s3,0x33
    800033f6:	74698993          	addi	s3,s3,1862 # 80036b38 <tickslock>
    800033fa:	00005497          	auipc	s1,0x5
    800033fe:	68648493          	addi	s1,s1,1670 # 80008a80 <ticks>
        if (killed(myproc()))
    80003402:	fffff097          	auipc	ra,0xfffff
    80003406:	9c0080e7          	jalr	-1600(ra) # 80001dc2 <myproc>
    8000340a:	fffff097          	auipc	ra,0xfffff
    8000340e:	40e080e7          	jalr	1038(ra) # 80002818 <killed>
    80003412:	ed15                	bnez	a0,8000344e <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003414:	85ce                	mv	a1,s3
    80003416:	8526                	mv	a0,s1
    80003418:	fffff097          	auipc	ra,0xfffff
    8000341c:	158080e7          	jalr	344(ra) # 80002570 <sleep>
    while (ticks - ticks0 < n)
    80003420:	409c                	lw	a5,0(s1)
    80003422:	412787bb          	subw	a5,a5,s2
    80003426:	fcc42703          	lw	a4,-52(s0)
    8000342a:	fce7ece3          	bltu	a5,a4,80003402 <sys_sleep+0x4a>
    }
    release(&tickslock);
    8000342e:	00033517          	auipc	a0,0x33
    80003432:	70a50513          	addi	a0,a0,1802 # 80036b38 <tickslock>
    80003436:	ffffe097          	auipc	ra,0xffffe
    8000343a:	b14080e7          	jalr	-1260(ra) # 80000f4a <release>
    return 0;
    8000343e:	4501                	li	a0,0
}
    80003440:	70e2                	ld	ra,56(sp)
    80003442:	7442                	ld	s0,48(sp)
    80003444:	74a2                	ld	s1,40(sp)
    80003446:	7902                	ld	s2,32(sp)
    80003448:	69e2                	ld	s3,24(sp)
    8000344a:	6121                	addi	sp,sp,64
    8000344c:	8082                	ret
            release(&tickslock);
    8000344e:	00033517          	auipc	a0,0x33
    80003452:	6ea50513          	addi	a0,a0,1770 # 80036b38 <tickslock>
    80003456:	ffffe097          	auipc	ra,0xffffe
    8000345a:	af4080e7          	jalr	-1292(ra) # 80000f4a <release>
            return -1;
    8000345e:	557d                	li	a0,-1
    80003460:	b7c5                	j	80003440 <sys_sleep+0x88>

0000000080003462 <sys_kill>:

uint64
sys_kill(void)
{
    80003462:	1101                	addi	sp,sp,-32
    80003464:	ec06                	sd	ra,24(sp)
    80003466:	e822                	sd	s0,16(sp)
    80003468:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000346a:	fec40593          	addi	a1,s0,-20
    8000346e:	4501                	li	a0,0
    80003470:	00000097          	auipc	ra,0x0
    80003474:	d9a080e7          	jalr	-614(ra) # 8000320a <argint>
    return kill(pid);
    80003478:	fec42503          	lw	a0,-20(s0)
    8000347c:	fffff097          	auipc	ra,0xfffff
    80003480:	2fe080e7          	jalr	766(ra) # 8000277a <kill>
}
    80003484:	60e2                	ld	ra,24(sp)
    80003486:	6442                	ld	s0,16(sp)
    80003488:	6105                	addi	sp,sp,32
    8000348a:	8082                	ret

000000008000348c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	e426                	sd	s1,8(sp)
    80003494:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003496:	00033517          	auipc	a0,0x33
    8000349a:	6a250513          	addi	a0,a0,1698 # 80036b38 <tickslock>
    8000349e:	ffffe097          	auipc	ra,0xffffe
    800034a2:	9f8080e7          	jalr	-1544(ra) # 80000e96 <acquire>
    xticks = ticks;
    800034a6:	00005497          	auipc	s1,0x5
    800034aa:	5da4a483          	lw	s1,1498(s1) # 80008a80 <ticks>
    release(&tickslock);
    800034ae:	00033517          	auipc	a0,0x33
    800034b2:	68a50513          	addi	a0,a0,1674 # 80036b38 <tickslock>
    800034b6:	ffffe097          	auipc	ra,0xffffe
    800034ba:	a94080e7          	jalr	-1388(ra) # 80000f4a <release>
    return xticks;
}
    800034be:	02049513          	slli	a0,s1,0x20
    800034c2:	9101                	srli	a0,a0,0x20
    800034c4:	60e2                	ld	ra,24(sp)
    800034c6:	6442                	ld	s0,16(sp)
    800034c8:	64a2                	ld	s1,8(sp)
    800034ca:	6105                	addi	sp,sp,32
    800034cc:	8082                	ret

00000000800034ce <sys_ps>:

void *
sys_ps(void)
{
    800034ce:	1101                	addi	sp,sp,-32
    800034d0:	ec06                	sd	ra,24(sp)
    800034d2:	e822                	sd	s0,16(sp)
    800034d4:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800034d6:	fe042623          	sw	zero,-20(s0)
    800034da:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800034de:	fec40593          	addi	a1,s0,-20
    800034e2:	4501                	li	a0,0
    800034e4:	00000097          	auipc	ra,0x0
    800034e8:	d26080e7          	jalr	-730(ra) # 8000320a <argint>
    argint(1, &count);
    800034ec:	fe840593          	addi	a1,s0,-24
    800034f0:	4505                	li	a0,1
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	d18080e7          	jalr	-744(ra) # 8000320a <argint>
    return ps((uint8)start, (uint8)count);
    800034fa:	fe844583          	lbu	a1,-24(s0)
    800034fe:	fec44503          	lbu	a0,-20(s0)
    80003502:	fffff097          	auipc	ra,0xfffff
    80003506:	c76080e7          	jalr	-906(ra) # 80002178 <ps>
}
    8000350a:	60e2                	ld	ra,24(sp)
    8000350c:	6442                	ld	s0,16(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003512:	1141                	addi	sp,sp,-16
    80003514:	e406                	sd	ra,8(sp)
    80003516:	e022                	sd	s0,0(sp)
    80003518:	0800                	addi	s0,sp,16
    schedls();
    8000351a:	fffff097          	auipc	ra,0xfffff
    8000351e:	5ba080e7          	jalr	1466(ra) # 80002ad4 <schedls>
    return 0;
}
    80003522:	4501                	li	a0,0
    80003524:	60a2                	ld	ra,8(sp)
    80003526:	6402                	ld	s0,0(sp)
    80003528:	0141                	addi	sp,sp,16
    8000352a:	8082                	ret

000000008000352c <sys_schedset>:

uint64 sys_schedset(void)
{
    8000352c:	1101                	addi	sp,sp,-32
    8000352e:	ec06                	sd	ra,24(sp)
    80003530:	e822                	sd	s0,16(sp)
    80003532:	1000                	addi	s0,sp,32
    int id = 0;
    80003534:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003538:	fec40593          	addi	a1,s0,-20
    8000353c:	4501                	li	a0,0
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	ccc080e7          	jalr	-820(ra) # 8000320a <argint>
    schedset(id - 1);
    80003546:	fec42503          	lw	a0,-20(s0)
    8000354a:	357d                	addiw	a0,a0,-1
    8000354c:	fffff097          	auipc	ra,0xfffff
    80003550:	61e080e7          	jalr	1566(ra) # 80002b6a <schedset>
    return 0;
}
    80003554:	4501                	li	a0,0
    80003556:	60e2                	ld	ra,24(sp)
    80003558:	6442                	ld	s0,16(sp)
    8000355a:	6105                	addi	sp,sp,32
    8000355c:	8082                	ret

000000008000355e <sys_va2pa>:

uint64 sys_va2pa(void)
{
    8000355e:	7179                	addi	sp,sp,-48
    80003560:	f406                	sd	ra,40(sp)
    80003562:	f022                	sd	s0,32(sp)
    80003564:	ec26                	sd	s1,24(sp)
    80003566:	1800                	addi	s0,sp,48
    int pid = 0;
    80003568:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    8000356c:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    80003570:	fd040593          	addi	a1,s0,-48
    80003574:	4501                	li	a0,0
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	cb4080e7          	jalr	-844(ra) # 8000322a <argaddr>
    argint(1, &pid);
    8000357e:	fdc40593          	addi	a1,s0,-36
    80003582:	4505                	li	a0,1
    80003584:	00000097          	auipc	ra,0x0
    80003588:	c86080e7          	jalr	-890(ra) # 8000320a <argint>
    if (pid == 0) {
    8000358c:	fdc42783          	lw	a5,-36(s0)
    80003590:	cf91                	beqz	a5,800035ac <sys_va2pa+0x4e>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    80003592:	fdc42583          	lw	a1,-36(s0)
    80003596:	fd043503          	ld	a0,-48(s0)
    8000359a:	fffff097          	auipc	ra,0xfffff
    8000359e:	61c080e7          	jalr	1564(ra) # 80002bb6 <transvirtproc>
}
    800035a2:	70a2                	ld	ra,40(sp)
    800035a4:	7402                	ld	s0,32(sp)
    800035a6:	64e2                	ld	s1,24(sp)
    800035a8:	6145                	addi	sp,sp,48
    800035aa:	8082                	ret
	struct proc *p = myproc();
    800035ac:	fffff097          	auipc	ra,0xfffff
    800035b0:	816080e7          	jalr	-2026(ra) # 80001dc2 <myproc>
    800035b4:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800035b6:	ffffe097          	auipc	ra,0xffffe
    800035ba:	8e0080e7          	jalr	-1824(ra) # 80000e96 <acquire>
	pid = p->pid;
    800035be:	589c                	lw	a5,48(s1)
    800035c0:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    800035c4:	8526                	mv	a0,s1
    800035c6:	ffffe097          	auipc	ra,0xffffe
    800035ca:	984080e7          	jalr	-1660(ra) # 80000f4a <release>
    800035ce:	b7d1                	j	80003592 <sys_va2pa+0x34>

00000000800035d0 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    800035d0:	1141                	addi	sp,sp,-16
    800035d2:	e406                	sd	ra,8(sp)
    800035d4:	e022                	sd	s0,0(sp)
    800035d6:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800035d8:	00005597          	auipc	a1,0x5
    800035dc:	4805b583          	ld	a1,1152(a1) # 80008a58 <FREE_PAGES>
    800035e0:	00005517          	auipc	a0,0x5
    800035e4:	f8850513          	addi	a0,a0,-120 # 80008568 <states.0+0x170>
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	fb4080e7          	jalr	-76(ra) # 8000059c <printf>
    return 0;
}
    800035f0:	4501                	li	a0,0
    800035f2:	60a2                	ld	ra,8(sp)
    800035f4:	6402                	ld	s0,0(sp)
    800035f6:	0141                	addi	sp,sp,16
    800035f8:	8082                	ret

00000000800035fa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800035fa:	7179                	addi	sp,sp,-48
    800035fc:	f406                	sd	ra,40(sp)
    800035fe:	f022                	sd	s0,32(sp)
    80003600:	ec26                	sd	s1,24(sp)
    80003602:	e84a                	sd	s2,16(sp)
    80003604:	e44e                	sd	s3,8(sp)
    80003606:	e052                	sd	s4,0(sp)
    80003608:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000360a:	00005597          	auipc	a1,0x5
    8000360e:	05658593          	addi	a1,a1,86 # 80008660 <syscalls+0xd8>
    80003612:	00033517          	auipc	a0,0x33
    80003616:	53e50513          	addi	a0,a0,1342 # 80036b50 <bcache>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	7ec080e7          	jalr	2028(ra) # 80000e06 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003622:	0003b797          	auipc	a5,0x3b
    80003626:	52e78793          	addi	a5,a5,1326 # 8003eb50 <bcache+0x8000>
    8000362a:	0003b717          	auipc	a4,0x3b
    8000362e:	78e70713          	addi	a4,a4,1934 # 8003edb8 <bcache+0x8268>
    80003632:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003636:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000363a:	00033497          	auipc	s1,0x33
    8000363e:	52e48493          	addi	s1,s1,1326 # 80036b68 <bcache+0x18>
    b->next = bcache.head.next;
    80003642:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003644:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003646:	00005a17          	auipc	s4,0x5
    8000364a:	022a0a13          	addi	s4,s4,34 # 80008668 <syscalls+0xe0>
    b->next = bcache.head.next;
    8000364e:	2b893783          	ld	a5,696(s2)
    80003652:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003654:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003658:	85d2                	mv	a1,s4
    8000365a:	01048513          	addi	a0,s1,16
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	4c8080e7          	jalr	1224(ra) # 80004b26 <initsleeplock>
    bcache.head.next->prev = b;
    80003666:	2b893783          	ld	a5,696(s2)
    8000366a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000366c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003670:	45848493          	addi	s1,s1,1112
    80003674:	fd349de3          	bne	s1,s3,8000364e <binit+0x54>
  }
}
    80003678:	70a2                	ld	ra,40(sp)
    8000367a:	7402                	ld	s0,32(sp)
    8000367c:	64e2                	ld	s1,24(sp)
    8000367e:	6942                	ld	s2,16(sp)
    80003680:	69a2                	ld	s3,8(sp)
    80003682:	6a02                	ld	s4,0(sp)
    80003684:	6145                	addi	sp,sp,48
    80003686:	8082                	ret

0000000080003688 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003688:	7179                	addi	sp,sp,-48
    8000368a:	f406                	sd	ra,40(sp)
    8000368c:	f022                	sd	s0,32(sp)
    8000368e:	ec26                	sd	s1,24(sp)
    80003690:	e84a                	sd	s2,16(sp)
    80003692:	e44e                	sd	s3,8(sp)
    80003694:	1800                	addi	s0,sp,48
    80003696:	892a                	mv	s2,a0
    80003698:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000369a:	00033517          	auipc	a0,0x33
    8000369e:	4b650513          	addi	a0,a0,1206 # 80036b50 <bcache>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	7f4080e7          	jalr	2036(ra) # 80000e96 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800036aa:	0003b497          	auipc	s1,0x3b
    800036ae:	75e4b483          	ld	s1,1886(s1) # 8003ee08 <bcache+0x82b8>
    800036b2:	0003b797          	auipc	a5,0x3b
    800036b6:	70678793          	addi	a5,a5,1798 # 8003edb8 <bcache+0x8268>
    800036ba:	02f48f63          	beq	s1,a5,800036f8 <bread+0x70>
    800036be:	873e                	mv	a4,a5
    800036c0:	a021                	j	800036c8 <bread+0x40>
    800036c2:	68a4                	ld	s1,80(s1)
    800036c4:	02e48a63          	beq	s1,a4,800036f8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036c8:	449c                	lw	a5,8(s1)
    800036ca:	ff279ce3          	bne	a5,s2,800036c2 <bread+0x3a>
    800036ce:	44dc                	lw	a5,12(s1)
    800036d0:	ff3799e3          	bne	a5,s3,800036c2 <bread+0x3a>
      b->refcnt++;
    800036d4:	40bc                	lw	a5,64(s1)
    800036d6:	2785                	addiw	a5,a5,1
    800036d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036da:	00033517          	auipc	a0,0x33
    800036de:	47650513          	addi	a0,a0,1142 # 80036b50 <bcache>
    800036e2:	ffffe097          	auipc	ra,0xffffe
    800036e6:	868080e7          	jalr	-1944(ra) # 80000f4a <release>
      acquiresleep(&b->lock);
    800036ea:	01048513          	addi	a0,s1,16
    800036ee:	00001097          	auipc	ra,0x1
    800036f2:	472080e7          	jalr	1138(ra) # 80004b60 <acquiresleep>
      return b;
    800036f6:	a8b9                	j	80003754 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036f8:	0003b497          	auipc	s1,0x3b
    800036fc:	7084b483          	ld	s1,1800(s1) # 8003ee00 <bcache+0x82b0>
    80003700:	0003b797          	auipc	a5,0x3b
    80003704:	6b878793          	addi	a5,a5,1720 # 8003edb8 <bcache+0x8268>
    80003708:	00f48863          	beq	s1,a5,80003718 <bread+0x90>
    8000370c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000370e:	40bc                	lw	a5,64(s1)
    80003710:	cf81                	beqz	a5,80003728 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003712:	64a4                	ld	s1,72(s1)
    80003714:	fee49de3          	bne	s1,a4,8000370e <bread+0x86>
  panic("bget: no buffers");
    80003718:	00005517          	auipc	a0,0x5
    8000371c:	f5850513          	addi	a0,a0,-168 # 80008670 <syscalls+0xe8>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	e20080e7          	jalr	-480(ra) # 80000540 <panic>
      b->dev = dev;
    80003728:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000372c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003730:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003734:	4785                	li	a5,1
    80003736:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003738:	00033517          	auipc	a0,0x33
    8000373c:	41850513          	addi	a0,a0,1048 # 80036b50 <bcache>
    80003740:	ffffe097          	auipc	ra,0xffffe
    80003744:	80a080e7          	jalr	-2038(ra) # 80000f4a <release>
      acquiresleep(&b->lock);
    80003748:	01048513          	addi	a0,s1,16
    8000374c:	00001097          	auipc	ra,0x1
    80003750:	414080e7          	jalr	1044(ra) # 80004b60 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003754:	409c                	lw	a5,0(s1)
    80003756:	cb89                	beqz	a5,80003768 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003758:	8526                	mv	a0,s1
    8000375a:	70a2                	ld	ra,40(sp)
    8000375c:	7402                	ld	s0,32(sp)
    8000375e:	64e2                	ld	s1,24(sp)
    80003760:	6942                	ld	s2,16(sp)
    80003762:	69a2                	ld	s3,8(sp)
    80003764:	6145                	addi	sp,sp,48
    80003766:	8082                	ret
    virtio_disk_rw(b, 0);
    80003768:	4581                	li	a1,0
    8000376a:	8526                	mv	a0,s1
    8000376c:	00003097          	auipc	ra,0x3
    80003770:	fd6080e7          	jalr	-42(ra) # 80006742 <virtio_disk_rw>
    b->valid = 1;
    80003774:	4785                	li	a5,1
    80003776:	c09c                	sw	a5,0(s1)
  return b;
    80003778:	b7c5                	j	80003758 <bread+0xd0>

000000008000377a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000377a:	1101                	addi	sp,sp,-32
    8000377c:	ec06                	sd	ra,24(sp)
    8000377e:	e822                	sd	s0,16(sp)
    80003780:	e426                	sd	s1,8(sp)
    80003782:	1000                	addi	s0,sp,32
    80003784:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003786:	0541                	addi	a0,a0,16
    80003788:	00001097          	auipc	ra,0x1
    8000378c:	472080e7          	jalr	1138(ra) # 80004bfa <holdingsleep>
    80003790:	cd01                	beqz	a0,800037a8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003792:	4585                	li	a1,1
    80003794:	8526                	mv	a0,s1
    80003796:	00003097          	auipc	ra,0x3
    8000379a:	fac080e7          	jalr	-84(ra) # 80006742 <virtio_disk_rw>
}
    8000379e:	60e2                	ld	ra,24(sp)
    800037a0:	6442                	ld	s0,16(sp)
    800037a2:	64a2                	ld	s1,8(sp)
    800037a4:	6105                	addi	sp,sp,32
    800037a6:	8082                	ret
    panic("bwrite");
    800037a8:	00005517          	auipc	a0,0x5
    800037ac:	ee050513          	addi	a0,a0,-288 # 80008688 <syscalls+0x100>
    800037b0:	ffffd097          	auipc	ra,0xffffd
    800037b4:	d90080e7          	jalr	-624(ra) # 80000540 <panic>

00000000800037b8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037b8:	1101                	addi	sp,sp,-32
    800037ba:	ec06                	sd	ra,24(sp)
    800037bc:	e822                	sd	s0,16(sp)
    800037be:	e426                	sd	s1,8(sp)
    800037c0:	e04a                	sd	s2,0(sp)
    800037c2:	1000                	addi	s0,sp,32
    800037c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037c6:	01050913          	addi	s2,a0,16
    800037ca:	854a                	mv	a0,s2
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	42e080e7          	jalr	1070(ra) # 80004bfa <holdingsleep>
    800037d4:	c92d                	beqz	a0,80003846 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800037d6:	854a                	mv	a0,s2
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	3de080e7          	jalr	990(ra) # 80004bb6 <releasesleep>

  acquire(&bcache.lock);
    800037e0:	00033517          	auipc	a0,0x33
    800037e4:	37050513          	addi	a0,a0,880 # 80036b50 <bcache>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	6ae080e7          	jalr	1710(ra) # 80000e96 <acquire>
  b->refcnt--;
    800037f0:	40bc                	lw	a5,64(s1)
    800037f2:	37fd                	addiw	a5,a5,-1
    800037f4:	0007871b          	sext.w	a4,a5
    800037f8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800037fa:	eb05                	bnez	a4,8000382a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037fc:	68bc                	ld	a5,80(s1)
    800037fe:	64b8                	ld	a4,72(s1)
    80003800:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003802:	64bc                	ld	a5,72(s1)
    80003804:	68b8                	ld	a4,80(s1)
    80003806:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003808:	0003b797          	auipc	a5,0x3b
    8000380c:	34878793          	addi	a5,a5,840 # 8003eb50 <bcache+0x8000>
    80003810:	2b87b703          	ld	a4,696(a5)
    80003814:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003816:	0003b717          	auipc	a4,0x3b
    8000381a:	5a270713          	addi	a4,a4,1442 # 8003edb8 <bcache+0x8268>
    8000381e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003820:	2b87b703          	ld	a4,696(a5)
    80003824:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003826:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000382a:	00033517          	auipc	a0,0x33
    8000382e:	32650513          	addi	a0,a0,806 # 80036b50 <bcache>
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	718080e7          	jalr	1816(ra) # 80000f4a <release>
}
    8000383a:	60e2                	ld	ra,24(sp)
    8000383c:	6442                	ld	s0,16(sp)
    8000383e:	64a2                	ld	s1,8(sp)
    80003840:	6902                	ld	s2,0(sp)
    80003842:	6105                	addi	sp,sp,32
    80003844:	8082                	ret
    panic("brelse");
    80003846:	00005517          	auipc	a0,0x5
    8000384a:	e4a50513          	addi	a0,a0,-438 # 80008690 <syscalls+0x108>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	cf2080e7          	jalr	-782(ra) # 80000540 <panic>

0000000080003856 <bpin>:

void
bpin(struct buf *b) {
    80003856:	1101                	addi	sp,sp,-32
    80003858:	ec06                	sd	ra,24(sp)
    8000385a:	e822                	sd	s0,16(sp)
    8000385c:	e426                	sd	s1,8(sp)
    8000385e:	1000                	addi	s0,sp,32
    80003860:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003862:	00033517          	auipc	a0,0x33
    80003866:	2ee50513          	addi	a0,a0,750 # 80036b50 <bcache>
    8000386a:	ffffd097          	auipc	ra,0xffffd
    8000386e:	62c080e7          	jalr	1580(ra) # 80000e96 <acquire>
  b->refcnt++;
    80003872:	40bc                	lw	a5,64(s1)
    80003874:	2785                	addiw	a5,a5,1
    80003876:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003878:	00033517          	auipc	a0,0x33
    8000387c:	2d850513          	addi	a0,a0,728 # 80036b50 <bcache>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	6ca080e7          	jalr	1738(ra) # 80000f4a <release>
}
    80003888:	60e2                	ld	ra,24(sp)
    8000388a:	6442                	ld	s0,16(sp)
    8000388c:	64a2                	ld	s1,8(sp)
    8000388e:	6105                	addi	sp,sp,32
    80003890:	8082                	ret

0000000080003892 <bunpin>:

void
bunpin(struct buf *b) {
    80003892:	1101                	addi	sp,sp,-32
    80003894:	ec06                	sd	ra,24(sp)
    80003896:	e822                	sd	s0,16(sp)
    80003898:	e426                	sd	s1,8(sp)
    8000389a:	1000                	addi	s0,sp,32
    8000389c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000389e:	00033517          	auipc	a0,0x33
    800038a2:	2b250513          	addi	a0,a0,690 # 80036b50 <bcache>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	5f0080e7          	jalr	1520(ra) # 80000e96 <acquire>
  b->refcnt--;
    800038ae:	40bc                	lw	a5,64(s1)
    800038b0:	37fd                	addiw	a5,a5,-1
    800038b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038b4:	00033517          	auipc	a0,0x33
    800038b8:	29c50513          	addi	a0,a0,668 # 80036b50 <bcache>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	68e080e7          	jalr	1678(ra) # 80000f4a <release>
}
    800038c4:	60e2                	ld	ra,24(sp)
    800038c6:	6442                	ld	s0,16(sp)
    800038c8:	64a2                	ld	s1,8(sp)
    800038ca:	6105                	addi	sp,sp,32
    800038cc:	8082                	ret

00000000800038ce <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038ce:	1101                	addi	sp,sp,-32
    800038d0:	ec06                	sd	ra,24(sp)
    800038d2:	e822                	sd	s0,16(sp)
    800038d4:	e426                	sd	s1,8(sp)
    800038d6:	e04a                	sd	s2,0(sp)
    800038d8:	1000                	addi	s0,sp,32
    800038da:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038dc:	00d5d59b          	srliw	a1,a1,0xd
    800038e0:	0003c797          	auipc	a5,0x3c
    800038e4:	94c7a783          	lw	a5,-1716(a5) # 8003f22c <sb+0x1c>
    800038e8:	9dbd                	addw	a1,a1,a5
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	d9e080e7          	jalr	-610(ra) # 80003688 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800038f2:	0074f713          	andi	a4,s1,7
    800038f6:	4785                	li	a5,1
    800038f8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800038fc:	14ce                	slli	s1,s1,0x33
    800038fe:	90d9                	srli	s1,s1,0x36
    80003900:	00950733          	add	a4,a0,s1
    80003904:	05874703          	lbu	a4,88(a4)
    80003908:	00e7f6b3          	and	a3,a5,a4
    8000390c:	c69d                	beqz	a3,8000393a <bfree+0x6c>
    8000390e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003910:	94aa                	add	s1,s1,a0
    80003912:	fff7c793          	not	a5,a5
    80003916:	8f7d                	and	a4,a4,a5
    80003918:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000391c:	00001097          	auipc	ra,0x1
    80003920:	126080e7          	jalr	294(ra) # 80004a42 <log_write>
  brelse(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	e92080e7          	jalr	-366(ra) # 800037b8 <brelse>
}
    8000392e:	60e2                	ld	ra,24(sp)
    80003930:	6442                	ld	s0,16(sp)
    80003932:	64a2                	ld	s1,8(sp)
    80003934:	6902                	ld	s2,0(sp)
    80003936:	6105                	addi	sp,sp,32
    80003938:	8082                	ret
    panic("freeing free block");
    8000393a:	00005517          	auipc	a0,0x5
    8000393e:	d5e50513          	addi	a0,a0,-674 # 80008698 <syscalls+0x110>
    80003942:	ffffd097          	auipc	ra,0xffffd
    80003946:	bfe080e7          	jalr	-1026(ra) # 80000540 <panic>

000000008000394a <balloc>:
{
    8000394a:	711d                	addi	sp,sp,-96
    8000394c:	ec86                	sd	ra,88(sp)
    8000394e:	e8a2                	sd	s0,80(sp)
    80003950:	e4a6                	sd	s1,72(sp)
    80003952:	e0ca                	sd	s2,64(sp)
    80003954:	fc4e                	sd	s3,56(sp)
    80003956:	f852                	sd	s4,48(sp)
    80003958:	f456                	sd	s5,40(sp)
    8000395a:	f05a                	sd	s6,32(sp)
    8000395c:	ec5e                	sd	s7,24(sp)
    8000395e:	e862                	sd	s8,16(sp)
    80003960:	e466                	sd	s9,8(sp)
    80003962:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003964:	0003c797          	auipc	a5,0x3c
    80003968:	8b07a783          	lw	a5,-1872(a5) # 8003f214 <sb+0x4>
    8000396c:	cff5                	beqz	a5,80003a68 <balloc+0x11e>
    8000396e:	8baa                	mv	s7,a0
    80003970:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003972:	0003cb17          	auipc	s6,0x3c
    80003976:	89eb0b13          	addi	s6,s6,-1890 # 8003f210 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000397a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000397c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000397e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003980:	6c89                	lui	s9,0x2
    80003982:	a061                	j	80003a0a <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003984:	97ca                	add	a5,a5,s2
    80003986:	8e55                	or	a2,a2,a3
    80003988:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000398c:	854a                	mv	a0,s2
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	0b4080e7          	jalr	180(ra) # 80004a42 <log_write>
        brelse(bp);
    80003996:	854a                	mv	a0,s2
    80003998:	00000097          	auipc	ra,0x0
    8000399c:	e20080e7          	jalr	-480(ra) # 800037b8 <brelse>
  bp = bread(dev, bno);
    800039a0:	85a6                	mv	a1,s1
    800039a2:	855e                	mv	a0,s7
    800039a4:	00000097          	auipc	ra,0x0
    800039a8:	ce4080e7          	jalr	-796(ra) # 80003688 <bread>
    800039ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039ae:	40000613          	li	a2,1024
    800039b2:	4581                	li	a1,0
    800039b4:	05850513          	addi	a0,a0,88
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	5da080e7          	jalr	1498(ra) # 80000f92 <memset>
  log_write(bp);
    800039c0:	854a                	mv	a0,s2
    800039c2:	00001097          	auipc	ra,0x1
    800039c6:	080080e7          	jalr	128(ra) # 80004a42 <log_write>
  brelse(bp);
    800039ca:	854a                	mv	a0,s2
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	dec080e7          	jalr	-532(ra) # 800037b8 <brelse>
}
    800039d4:	8526                	mv	a0,s1
    800039d6:	60e6                	ld	ra,88(sp)
    800039d8:	6446                	ld	s0,80(sp)
    800039da:	64a6                	ld	s1,72(sp)
    800039dc:	6906                	ld	s2,64(sp)
    800039de:	79e2                	ld	s3,56(sp)
    800039e0:	7a42                	ld	s4,48(sp)
    800039e2:	7aa2                	ld	s5,40(sp)
    800039e4:	7b02                	ld	s6,32(sp)
    800039e6:	6be2                	ld	s7,24(sp)
    800039e8:	6c42                	ld	s8,16(sp)
    800039ea:	6ca2                	ld	s9,8(sp)
    800039ec:	6125                	addi	sp,sp,96
    800039ee:	8082                	ret
    brelse(bp);
    800039f0:	854a                	mv	a0,s2
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	dc6080e7          	jalr	-570(ra) # 800037b8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800039fa:	015c87bb          	addw	a5,s9,s5
    800039fe:	00078a9b          	sext.w	s5,a5
    80003a02:	004b2703          	lw	a4,4(s6)
    80003a06:	06eaf163          	bgeu	s5,a4,80003a68 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003a0a:	41fad79b          	sraiw	a5,s5,0x1f
    80003a0e:	0137d79b          	srliw	a5,a5,0x13
    80003a12:	015787bb          	addw	a5,a5,s5
    80003a16:	40d7d79b          	sraiw	a5,a5,0xd
    80003a1a:	01cb2583          	lw	a1,28(s6)
    80003a1e:	9dbd                	addw	a1,a1,a5
    80003a20:	855e                	mv	a0,s7
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	c66080e7          	jalr	-922(ra) # 80003688 <bread>
    80003a2a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a2c:	004b2503          	lw	a0,4(s6)
    80003a30:	000a849b          	sext.w	s1,s5
    80003a34:	8762                	mv	a4,s8
    80003a36:	faa4fde3          	bgeu	s1,a0,800039f0 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003a3a:	00777693          	andi	a3,a4,7
    80003a3e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a42:	41f7579b          	sraiw	a5,a4,0x1f
    80003a46:	01d7d79b          	srliw	a5,a5,0x1d
    80003a4a:	9fb9                	addw	a5,a5,a4
    80003a4c:	4037d79b          	sraiw	a5,a5,0x3
    80003a50:	00f90633          	add	a2,s2,a5
    80003a54:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003a58:	00c6f5b3          	and	a1,a3,a2
    80003a5c:	d585                	beqz	a1,80003984 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a5e:	2705                	addiw	a4,a4,1
    80003a60:	2485                	addiw	s1,s1,1
    80003a62:	fd471ae3          	bne	a4,s4,80003a36 <balloc+0xec>
    80003a66:	b769                	j	800039f0 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003a68:	00005517          	auipc	a0,0x5
    80003a6c:	c4850513          	addi	a0,a0,-952 # 800086b0 <syscalls+0x128>
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	b2c080e7          	jalr	-1236(ra) # 8000059c <printf>
  return 0;
    80003a78:	4481                	li	s1,0
    80003a7a:	bfa9                	j	800039d4 <balloc+0x8a>

0000000080003a7c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a7c:	7179                	addi	sp,sp,-48
    80003a7e:	f406                	sd	ra,40(sp)
    80003a80:	f022                	sd	s0,32(sp)
    80003a82:	ec26                	sd	s1,24(sp)
    80003a84:	e84a                	sd	s2,16(sp)
    80003a86:	e44e                	sd	s3,8(sp)
    80003a88:	e052                	sd	s4,0(sp)
    80003a8a:	1800                	addi	s0,sp,48
    80003a8c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a8e:	47ad                	li	a5,11
    80003a90:	02b7e863          	bltu	a5,a1,80003ac0 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003a94:	02059793          	slli	a5,a1,0x20
    80003a98:	01e7d593          	srli	a1,a5,0x1e
    80003a9c:	00b504b3          	add	s1,a0,a1
    80003aa0:	0504a903          	lw	s2,80(s1)
    80003aa4:	06091e63          	bnez	s2,80003b20 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003aa8:	4108                	lw	a0,0(a0)
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	ea0080e7          	jalr	-352(ra) # 8000394a <balloc>
    80003ab2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ab6:	06090563          	beqz	s2,80003b20 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003aba:	0524a823          	sw	s2,80(s1)
    80003abe:	a08d                	j	80003b20 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003ac0:	ff45849b          	addiw	s1,a1,-12
    80003ac4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003ac8:	0ff00793          	li	a5,255
    80003acc:	08e7e563          	bltu	a5,a4,80003b56 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ad0:	08052903          	lw	s2,128(a0)
    80003ad4:	00091d63          	bnez	s2,80003aee <bmap+0x72>
      addr = balloc(ip->dev);
    80003ad8:	4108                	lw	a0,0(a0)
    80003ada:	00000097          	auipc	ra,0x0
    80003ade:	e70080e7          	jalr	-400(ra) # 8000394a <balloc>
    80003ae2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ae6:	02090d63          	beqz	s2,80003b20 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003aea:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003aee:	85ca                	mv	a1,s2
    80003af0:	0009a503          	lw	a0,0(s3)
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	b94080e7          	jalr	-1132(ra) # 80003688 <bread>
    80003afc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003afe:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b02:	02049713          	slli	a4,s1,0x20
    80003b06:	01e75593          	srli	a1,a4,0x1e
    80003b0a:	00b784b3          	add	s1,a5,a1
    80003b0e:	0004a903          	lw	s2,0(s1)
    80003b12:	02090063          	beqz	s2,80003b32 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b16:	8552                	mv	a0,s4
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	ca0080e7          	jalr	-864(ra) # 800037b8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b20:	854a                	mv	a0,s2
    80003b22:	70a2                	ld	ra,40(sp)
    80003b24:	7402                	ld	s0,32(sp)
    80003b26:	64e2                	ld	s1,24(sp)
    80003b28:	6942                	ld	s2,16(sp)
    80003b2a:	69a2                	ld	s3,8(sp)
    80003b2c:	6a02                	ld	s4,0(sp)
    80003b2e:	6145                	addi	sp,sp,48
    80003b30:	8082                	ret
      addr = balloc(ip->dev);
    80003b32:	0009a503          	lw	a0,0(s3)
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	e14080e7          	jalr	-492(ra) # 8000394a <balloc>
    80003b3e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b42:	fc090ae3          	beqz	s2,80003b16 <bmap+0x9a>
        a[bn] = addr;
    80003b46:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b4a:	8552                	mv	a0,s4
    80003b4c:	00001097          	auipc	ra,0x1
    80003b50:	ef6080e7          	jalr	-266(ra) # 80004a42 <log_write>
    80003b54:	b7c9                	j	80003b16 <bmap+0x9a>
  panic("bmap: out of range");
    80003b56:	00005517          	auipc	a0,0x5
    80003b5a:	b7250513          	addi	a0,a0,-1166 # 800086c8 <syscalls+0x140>
    80003b5e:	ffffd097          	auipc	ra,0xffffd
    80003b62:	9e2080e7          	jalr	-1566(ra) # 80000540 <panic>

0000000080003b66 <iget>:
{
    80003b66:	7179                	addi	sp,sp,-48
    80003b68:	f406                	sd	ra,40(sp)
    80003b6a:	f022                	sd	s0,32(sp)
    80003b6c:	ec26                	sd	s1,24(sp)
    80003b6e:	e84a                	sd	s2,16(sp)
    80003b70:	e44e                	sd	s3,8(sp)
    80003b72:	e052                	sd	s4,0(sp)
    80003b74:	1800                	addi	s0,sp,48
    80003b76:	89aa                	mv	s3,a0
    80003b78:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b7a:	0003b517          	auipc	a0,0x3b
    80003b7e:	6b650513          	addi	a0,a0,1718 # 8003f230 <itable>
    80003b82:	ffffd097          	auipc	ra,0xffffd
    80003b86:	314080e7          	jalr	788(ra) # 80000e96 <acquire>
  empty = 0;
    80003b8a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b8c:	0003b497          	auipc	s1,0x3b
    80003b90:	6bc48493          	addi	s1,s1,1724 # 8003f248 <itable+0x18>
    80003b94:	0003d697          	auipc	a3,0x3d
    80003b98:	14468693          	addi	a3,a3,324 # 80040cd8 <log>
    80003b9c:	a039                	j	80003baa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b9e:	02090b63          	beqz	s2,80003bd4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ba2:	08848493          	addi	s1,s1,136
    80003ba6:	02d48a63          	beq	s1,a3,80003bda <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003baa:	449c                	lw	a5,8(s1)
    80003bac:	fef059e3          	blez	a5,80003b9e <iget+0x38>
    80003bb0:	4098                	lw	a4,0(s1)
    80003bb2:	ff3716e3          	bne	a4,s3,80003b9e <iget+0x38>
    80003bb6:	40d8                	lw	a4,4(s1)
    80003bb8:	ff4713e3          	bne	a4,s4,80003b9e <iget+0x38>
      ip->ref++;
    80003bbc:	2785                	addiw	a5,a5,1
    80003bbe:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003bc0:	0003b517          	auipc	a0,0x3b
    80003bc4:	67050513          	addi	a0,a0,1648 # 8003f230 <itable>
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	382080e7          	jalr	898(ra) # 80000f4a <release>
      return ip;
    80003bd0:	8926                	mv	s2,s1
    80003bd2:	a03d                	j	80003c00 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bd4:	f7f9                	bnez	a5,80003ba2 <iget+0x3c>
    80003bd6:	8926                	mv	s2,s1
    80003bd8:	b7e9                	j	80003ba2 <iget+0x3c>
  if(empty == 0)
    80003bda:	02090c63          	beqz	s2,80003c12 <iget+0xac>
  ip->dev = dev;
    80003bde:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003be2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003be6:	4785                	li	a5,1
    80003be8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bec:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003bf0:	0003b517          	auipc	a0,0x3b
    80003bf4:	64050513          	addi	a0,a0,1600 # 8003f230 <itable>
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	352080e7          	jalr	850(ra) # 80000f4a <release>
}
    80003c00:	854a                	mv	a0,s2
    80003c02:	70a2                	ld	ra,40(sp)
    80003c04:	7402                	ld	s0,32(sp)
    80003c06:	64e2                	ld	s1,24(sp)
    80003c08:	6942                	ld	s2,16(sp)
    80003c0a:	69a2                	ld	s3,8(sp)
    80003c0c:	6a02                	ld	s4,0(sp)
    80003c0e:	6145                	addi	sp,sp,48
    80003c10:	8082                	ret
    panic("iget: no inodes");
    80003c12:	00005517          	auipc	a0,0x5
    80003c16:	ace50513          	addi	a0,a0,-1330 # 800086e0 <syscalls+0x158>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	926080e7          	jalr	-1754(ra) # 80000540 <panic>

0000000080003c22 <fsinit>:
fsinit(int dev) {
    80003c22:	7179                	addi	sp,sp,-48
    80003c24:	f406                	sd	ra,40(sp)
    80003c26:	f022                	sd	s0,32(sp)
    80003c28:	ec26                	sd	s1,24(sp)
    80003c2a:	e84a                	sd	s2,16(sp)
    80003c2c:	e44e                	sd	s3,8(sp)
    80003c2e:	1800                	addi	s0,sp,48
    80003c30:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c32:	4585                	li	a1,1
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	a54080e7          	jalr	-1452(ra) # 80003688 <bread>
    80003c3c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c3e:	0003b997          	auipc	s3,0x3b
    80003c42:	5d298993          	addi	s3,s3,1490 # 8003f210 <sb>
    80003c46:	02000613          	li	a2,32
    80003c4a:	05850593          	addi	a1,a0,88
    80003c4e:	854e                	mv	a0,s3
    80003c50:	ffffd097          	auipc	ra,0xffffd
    80003c54:	39e080e7          	jalr	926(ra) # 80000fee <memmove>
  brelse(bp);
    80003c58:	8526                	mv	a0,s1
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	b5e080e7          	jalr	-1186(ra) # 800037b8 <brelse>
  if(sb.magic != FSMAGIC)
    80003c62:	0009a703          	lw	a4,0(s3)
    80003c66:	102037b7          	lui	a5,0x10203
    80003c6a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c6e:	02f71263          	bne	a4,a5,80003c92 <fsinit+0x70>
  initlog(dev, &sb);
    80003c72:	0003b597          	auipc	a1,0x3b
    80003c76:	59e58593          	addi	a1,a1,1438 # 8003f210 <sb>
    80003c7a:	854a                	mv	a0,s2
    80003c7c:	00001097          	auipc	ra,0x1
    80003c80:	b4a080e7          	jalr	-1206(ra) # 800047c6 <initlog>
}
    80003c84:	70a2                	ld	ra,40(sp)
    80003c86:	7402                	ld	s0,32(sp)
    80003c88:	64e2                	ld	s1,24(sp)
    80003c8a:	6942                	ld	s2,16(sp)
    80003c8c:	69a2                	ld	s3,8(sp)
    80003c8e:	6145                	addi	sp,sp,48
    80003c90:	8082                	ret
    panic("invalid file system");
    80003c92:	00005517          	auipc	a0,0x5
    80003c96:	a5e50513          	addi	a0,a0,-1442 # 800086f0 <syscalls+0x168>
    80003c9a:	ffffd097          	auipc	ra,0xffffd
    80003c9e:	8a6080e7          	jalr	-1882(ra) # 80000540 <panic>

0000000080003ca2 <iinit>:
{
    80003ca2:	7179                	addi	sp,sp,-48
    80003ca4:	f406                	sd	ra,40(sp)
    80003ca6:	f022                	sd	s0,32(sp)
    80003ca8:	ec26                	sd	s1,24(sp)
    80003caa:	e84a                	sd	s2,16(sp)
    80003cac:	e44e                	sd	s3,8(sp)
    80003cae:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cb0:	00005597          	auipc	a1,0x5
    80003cb4:	a5858593          	addi	a1,a1,-1448 # 80008708 <syscalls+0x180>
    80003cb8:	0003b517          	auipc	a0,0x3b
    80003cbc:	57850513          	addi	a0,a0,1400 # 8003f230 <itable>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	146080e7          	jalr	326(ra) # 80000e06 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cc8:	0003b497          	auipc	s1,0x3b
    80003ccc:	59048493          	addi	s1,s1,1424 # 8003f258 <itable+0x28>
    80003cd0:	0003d997          	auipc	s3,0x3d
    80003cd4:	01898993          	addi	s3,s3,24 # 80040ce8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cd8:	00005917          	auipc	s2,0x5
    80003cdc:	a3890913          	addi	s2,s2,-1480 # 80008710 <syscalls+0x188>
    80003ce0:	85ca                	mv	a1,s2
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	00001097          	auipc	ra,0x1
    80003ce8:	e42080e7          	jalr	-446(ra) # 80004b26 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003cec:	08848493          	addi	s1,s1,136
    80003cf0:	ff3498e3          	bne	s1,s3,80003ce0 <iinit+0x3e>
}
    80003cf4:	70a2                	ld	ra,40(sp)
    80003cf6:	7402                	ld	s0,32(sp)
    80003cf8:	64e2                	ld	s1,24(sp)
    80003cfa:	6942                	ld	s2,16(sp)
    80003cfc:	69a2                	ld	s3,8(sp)
    80003cfe:	6145                	addi	sp,sp,48
    80003d00:	8082                	ret

0000000080003d02 <ialloc>:
{
    80003d02:	715d                	addi	sp,sp,-80
    80003d04:	e486                	sd	ra,72(sp)
    80003d06:	e0a2                	sd	s0,64(sp)
    80003d08:	fc26                	sd	s1,56(sp)
    80003d0a:	f84a                	sd	s2,48(sp)
    80003d0c:	f44e                	sd	s3,40(sp)
    80003d0e:	f052                	sd	s4,32(sp)
    80003d10:	ec56                	sd	s5,24(sp)
    80003d12:	e85a                	sd	s6,16(sp)
    80003d14:	e45e                	sd	s7,8(sp)
    80003d16:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d18:	0003b717          	auipc	a4,0x3b
    80003d1c:	50472703          	lw	a4,1284(a4) # 8003f21c <sb+0xc>
    80003d20:	4785                	li	a5,1
    80003d22:	04e7fa63          	bgeu	a5,a4,80003d76 <ialloc+0x74>
    80003d26:	8aaa                	mv	s5,a0
    80003d28:	8bae                	mv	s7,a1
    80003d2a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d2c:	0003ba17          	auipc	s4,0x3b
    80003d30:	4e4a0a13          	addi	s4,s4,1252 # 8003f210 <sb>
    80003d34:	00048b1b          	sext.w	s6,s1
    80003d38:	0044d593          	srli	a1,s1,0x4
    80003d3c:	018a2783          	lw	a5,24(s4)
    80003d40:	9dbd                	addw	a1,a1,a5
    80003d42:	8556                	mv	a0,s5
    80003d44:	00000097          	auipc	ra,0x0
    80003d48:	944080e7          	jalr	-1724(ra) # 80003688 <bread>
    80003d4c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d4e:	05850993          	addi	s3,a0,88
    80003d52:	00f4f793          	andi	a5,s1,15
    80003d56:	079a                	slli	a5,a5,0x6
    80003d58:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d5a:	00099783          	lh	a5,0(s3)
    80003d5e:	c3a1                	beqz	a5,80003d9e <ialloc+0x9c>
    brelse(bp);
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	a58080e7          	jalr	-1448(ra) # 800037b8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d68:	0485                	addi	s1,s1,1
    80003d6a:	00ca2703          	lw	a4,12(s4)
    80003d6e:	0004879b          	sext.w	a5,s1
    80003d72:	fce7e1e3          	bltu	a5,a4,80003d34 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d76:	00005517          	auipc	a0,0x5
    80003d7a:	9a250513          	addi	a0,a0,-1630 # 80008718 <syscalls+0x190>
    80003d7e:	ffffd097          	auipc	ra,0xffffd
    80003d82:	81e080e7          	jalr	-2018(ra) # 8000059c <printf>
  return 0;
    80003d86:	4501                	li	a0,0
}
    80003d88:	60a6                	ld	ra,72(sp)
    80003d8a:	6406                	ld	s0,64(sp)
    80003d8c:	74e2                	ld	s1,56(sp)
    80003d8e:	7942                	ld	s2,48(sp)
    80003d90:	79a2                	ld	s3,40(sp)
    80003d92:	7a02                	ld	s4,32(sp)
    80003d94:	6ae2                	ld	s5,24(sp)
    80003d96:	6b42                	ld	s6,16(sp)
    80003d98:	6ba2                	ld	s7,8(sp)
    80003d9a:	6161                	addi	sp,sp,80
    80003d9c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003d9e:	04000613          	li	a2,64
    80003da2:	4581                	li	a1,0
    80003da4:	854e                	mv	a0,s3
    80003da6:	ffffd097          	auipc	ra,0xffffd
    80003daa:	1ec080e7          	jalr	492(ra) # 80000f92 <memset>
      dip->type = type;
    80003dae:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003db2:	854a                	mv	a0,s2
    80003db4:	00001097          	auipc	ra,0x1
    80003db8:	c8e080e7          	jalr	-882(ra) # 80004a42 <log_write>
      brelse(bp);
    80003dbc:	854a                	mv	a0,s2
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	9fa080e7          	jalr	-1542(ra) # 800037b8 <brelse>
      return iget(dev, inum);
    80003dc6:	85da                	mv	a1,s6
    80003dc8:	8556                	mv	a0,s5
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	d9c080e7          	jalr	-612(ra) # 80003b66 <iget>
    80003dd2:	bf5d                	j	80003d88 <ialloc+0x86>

0000000080003dd4 <iupdate>:
{
    80003dd4:	1101                	addi	sp,sp,-32
    80003dd6:	ec06                	sd	ra,24(sp)
    80003dd8:	e822                	sd	s0,16(sp)
    80003dda:	e426                	sd	s1,8(sp)
    80003ddc:	e04a                	sd	s2,0(sp)
    80003dde:	1000                	addi	s0,sp,32
    80003de0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003de2:	415c                	lw	a5,4(a0)
    80003de4:	0047d79b          	srliw	a5,a5,0x4
    80003de8:	0003b597          	auipc	a1,0x3b
    80003dec:	4405a583          	lw	a1,1088(a1) # 8003f228 <sb+0x18>
    80003df0:	9dbd                	addw	a1,a1,a5
    80003df2:	4108                	lw	a0,0(a0)
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	894080e7          	jalr	-1900(ra) # 80003688 <bread>
    80003dfc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dfe:	05850793          	addi	a5,a0,88
    80003e02:	40d8                	lw	a4,4(s1)
    80003e04:	8b3d                	andi	a4,a4,15
    80003e06:	071a                	slli	a4,a4,0x6
    80003e08:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003e0a:	04449703          	lh	a4,68(s1)
    80003e0e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003e12:	04649703          	lh	a4,70(s1)
    80003e16:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003e1a:	04849703          	lh	a4,72(s1)
    80003e1e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003e22:	04a49703          	lh	a4,74(s1)
    80003e26:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003e2a:	44f8                	lw	a4,76(s1)
    80003e2c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e2e:	03400613          	li	a2,52
    80003e32:	05048593          	addi	a1,s1,80
    80003e36:	00c78513          	addi	a0,a5,12
    80003e3a:	ffffd097          	auipc	ra,0xffffd
    80003e3e:	1b4080e7          	jalr	436(ra) # 80000fee <memmove>
  log_write(bp);
    80003e42:	854a                	mv	a0,s2
    80003e44:	00001097          	auipc	ra,0x1
    80003e48:	bfe080e7          	jalr	-1026(ra) # 80004a42 <log_write>
  brelse(bp);
    80003e4c:	854a                	mv	a0,s2
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	96a080e7          	jalr	-1686(ra) # 800037b8 <brelse>
}
    80003e56:	60e2                	ld	ra,24(sp)
    80003e58:	6442                	ld	s0,16(sp)
    80003e5a:	64a2                	ld	s1,8(sp)
    80003e5c:	6902                	ld	s2,0(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret

0000000080003e62 <idup>:
{
    80003e62:	1101                	addi	sp,sp,-32
    80003e64:	ec06                	sd	ra,24(sp)
    80003e66:	e822                	sd	s0,16(sp)
    80003e68:	e426                	sd	s1,8(sp)
    80003e6a:	1000                	addi	s0,sp,32
    80003e6c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e6e:	0003b517          	auipc	a0,0x3b
    80003e72:	3c250513          	addi	a0,a0,962 # 8003f230 <itable>
    80003e76:	ffffd097          	auipc	ra,0xffffd
    80003e7a:	020080e7          	jalr	32(ra) # 80000e96 <acquire>
  ip->ref++;
    80003e7e:	449c                	lw	a5,8(s1)
    80003e80:	2785                	addiw	a5,a5,1
    80003e82:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e84:	0003b517          	auipc	a0,0x3b
    80003e88:	3ac50513          	addi	a0,a0,940 # 8003f230 <itable>
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	0be080e7          	jalr	190(ra) # 80000f4a <release>
}
    80003e94:	8526                	mv	a0,s1
    80003e96:	60e2                	ld	ra,24(sp)
    80003e98:	6442                	ld	s0,16(sp)
    80003e9a:	64a2                	ld	s1,8(sp)
    80003e9c:	6105                	addi	sp,sp,32
    80003e9e:	8082                	ret

0000000080003ea0 <ilock>:
{
    80003ea0:	1101                	addi	sp,sp,-32
    80003ea2:	ec06                	sd	ra,24(sp)
    80003ea4:	e822                	sd	s0,16(sp)
    80003ea6:	e426                	sd	s1,8(sp)
    80003ea8:	e04a                	sd	s2,0(sp)
    80003eaa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003eac:	c115                	beqz	a0,80003ed0 <ilock+0x30>
    80003eae:	84aa                	mv	s1,a0
    80003eb0:	451c                	lw	a5,8(a0)
    80003eb2:	00f05f63          	blez	a5,80003ed0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003eb6:	0541                	addi	a0,a0,16
    80003eb8:	00001097          	auipc	ra,0x1
    80003ebc:	ca8080e7          	jalr	-856(ra) # 80004b60 <acquiresleep>
  if(ip->valid == 0){
    80003ec0:	40bc                	lw	a5,64(s1)
    80003ec2:	cf99                	beqz	a5,80003ee0 <ilock+0x40>
}
    80003ec4:	60e2                	ld	ra,24(sp)
    80003ec6:	6442                	ld	s0,16(sp)
    80003ec8:	64a2                	ld	s1,8(sp)
    80003eca:	6902                	ld	s2,0(sp)
    80003ecc:	6105                	addi	sp,sp,32
    80003ece:	8082                	ret
    panic("ilock");
    80003ed0:	00005517          	auipc	a0,0x5
    80003ed4:	86050513          	addi	a0,a0,-1952 # 80008730 <syscalls+0x1a8>
    80003ed8:	ffffc097          	auipc	ra,0xffffc
    80003edc:	668080e7          	jalr	1640(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ee0:	40dc                	lw	a5,4(s1)
    80003ee2:	0047d79b          	srliw	a5,a5,0x4
    80003ee6:	0003b597          	auipc	a1,0x3b
    80003eea:	3425a583          	lw	a1,834(a1) # 8003f228 <sb+0x18>
    80003eee:	9dbd                	addw	a1,a1,a5
    80003ef0:	4088                	lw	a0,0(s1)
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	796080e7          	jalr	1942(ra) # 80003688 <bread>
    80003efa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003efc:	05850593          	addi	a1,a0,88
    80003f00:	40dc                	lw	a5,4(s1)
    80003f02:	8bbd                	andi	a5,a5,15
    80003f04:	079a                	slli	a5,a5,0x6
    80003f06:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f08:	00059783          	lh	a5,0(a1)
    80003f0c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f10:	00259783          	lh	a5,2(a1)
    80003f14:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f18:	00459783          	lh	a5,4(a1)
    80003f1c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f20:	00659783          	lh	a5,6(a1)
    80003f24:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f28:	459c                	lw	a5,8(a1)
    80003f2a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f2c:	03400613          	li	a2,52
    80003f30:	05b1                	addi	a1,a1,12
    80003f32:	05048513          	addi	a0,s1,80
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	0b8080e7          	jalr	184(ra) # 80000fee <memmove>
    brelse(bp);
    80003f3e:	854a                	mv	a0,s2
    80003f40:	00000097          	auipc	ra,0x0
    80003f44:	878080e7          	jalr	-1928(ra) # 800037b8 <brelse>
    ip->valid = 1;
    80003f48:	4785                	li	a5,1
    80003f4a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f4c:	04449783          	lh	a5,68(s1)
    80003f50:	fbb5                	bnez	a5,80003ec4 <ilock+0x24>
      panic("ilock: no type");
    80003f52:	00004517          	auipc	a0,0x4
    80003f56:	7e650513          	addi	a0,a0,2022 # 80008738 <syscalls+0x1b0>
    80003f5a:	ffffc097          	auipc	ra,0xffffc
    80003f5e:	5e6080e7          	jalr	1510(ra) # 80000540 <panic>

0000000080003f62 <iunlock>:
{
    80003f62:	1101                	addi	sp,sp,-32
    80003f64:	ec06                	sd	ra,24(sp)
    80003f66:	e822                	sd	s0,16(sp)
    80003f68:	e426                	sd	s1,8(sp)
    80003f6a:	e04a                	sd	s2,0(sp)
    80003f6c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f6e:	c905                	beqz	a0,80003f9e <iunlock+0x3c>
    80003f70:	84aa                	mv	s1,a0
    80003f72:	01050913          	addi	s2,a0,16
    80003f76:	854a                	mv	a0,s2
    80003f78:	00001097          	auipc	ra,0x1
    80003f7c:	c82080e7          	jalr	-894(ra) # 80004bfa <holdingsleep>
    80003f80:	cd19                	beqz	a0,80003f9e <iunlock+0x3c>
    80003f82:	449c                	lw	a5,8(s1)
    80003f84:	00f05d63          	blez	a5,80003f9e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	00001097          	auipc	ra,0x1
    80003f8e:	c2c080e7          	jalr	-980(ra) # 80004bb6 <releasesleep>
}
    80003f92:	60e2                	ld	ra,24(sp)
    80003f94:	6442                	ld	s0,16(sp)
    80003f96:	64a2                	ld	s1,8(sp)
    80003f98:	6902                	ld	s2,0(sp)
    80003f9a:	6105                	addi	sp,sp,32
    80003f9c:	8082                	ret
    panic("iunlock");
    80003f9e:	00004517          	auipc	a0,0x4
    80003fa2:	7aa50513          	addi	a0,a0,1962 # 80008748 <syscalls+0x1c0>
    80003fa6:	ffffc097          	auipc	ra,0xffffc
    80003faa:	59a080e7          	jalr	1434(ra) # 80000540 <panic>

0000000080003fae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fae:	7179                	addi	sp,sp,-48
    80003fb0:	f406                	sd	ra,40(sp)
    80003fb2:	f022                	sd	s0,32(sp)
    80003fb4:	ec26                	sd	s1,24(sp)
    80003fb6:	e84a                	sd	s2,16(sp)
    80003fb8:	e44e                	sd	s3,8(sp)
    80003fba:	e052                	sd	s4,0(sp)
    80003fbc:	1800                	addi	s0,sp,48
    80003fbe:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fc0:	05050493          	addi	s1,a0,80
    80003fc4:	08050913          	addi	s2,a0,128
    80003fc8:	a021                	j	80003fd0 <itrunc+0x22>
    80003fca:	0491                	addi	s1,s1,4
    80003fcc:	01248d63          	beq	s1,s2,80003fe6 <itrunc+0x38>
    if(ip->addrs[i]){
    80003fd0:	408c                	lw	a1,0(s1)
    80003fd2:	dde5                	beqz	a1,80003fca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fd4:	0009a503          	lw	a0,0(s3)
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	8f6080e7          	jalr	-1802(ra) # 800038ce <bfree>
      ip->addrs[i] = 0;
    80003fe0:	0004a023          	sw	zero,0(s1)
    80003fe4:	b7dd                	j	80003fca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fe6:	0809a583          	lw	a1,128(s3)
    80003fea:	e185                	bnez	a1,8000400a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ff0:	854e                	mv	a0,s3
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	de2080e7          	jalr	-542(ra) # 80003dd4 <iupdate>
}
    80003ffa:	70a2                	ld	ra,40(sp)
    80003ffc:	7402                	ld	s0,32(sp)
    80003ffe:	64e2                	ld	s1,24(sp)
    80004000:	6942                	ld	s2,16(sp)
    80004002:	69a2                	ld	s3,8(sp)
    80004004:	6a02                	ld	s4,0(sp)
    80004006:	6145                	addi	sp,sp,48
    80004008:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000400a:	0009a503          	lw	a0,0(s3)
    8000400e:	fffff097          	auipc	ra,0xfffff
    80004012:	67a080e7          	jalr	1658(ra) # 80003688 <bread>
    80004016:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004018:	05850493          	addi	s1,a0,88
    8000401c:	45850913          	addi	s2,a0,1112
    80004020:	a021                	j	80004028 <itrunc+0x7a>
    80004022:	0491                	addi	s1,s1,4
    80004024:	01248b63          	beq	s1,s2,8000403a <itrunc+0x8c>
      if(a[j])
    80004028:	408c                	lw	a1,0(s1)
    8000402a:	dde5                	beqz	a1,80004022 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000402c:	0009a503          	lw	a0,0(s3)
    80004030:	00000097          	auipc	ra,0x0
    80004034:	89e080e7          	jalr	-1890(ra) # 800038ce <bfree>
    80004038:	b7ed                	j	80004022 <itrunc+0x74>
    brelse(bp);
    8000403a:	8552                	mv	a0,s4
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	77c080e7          	jalr	1916(ra) # 800037b8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004044:	0809a583          	lw	a1,128(s3)
    80004048:	0009a503          	lw	a0,0(s3)
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	882080e7          	jalr	-1918(ra) # 800038ce <bfree>
    ip->addrs[NDIRECT] = 0;
    80004054:	0809a023          	sw	zero,128(s3)
    80004058:	bf51                	j	80003fec <itrunc+0x3e>

000000008000405a <iput>:
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
    80004066:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004068:	0003b517          	auipc	a0,0x3b
    8000406c:	1c850513          	addi	a0,a0,456 # 8003f230 <itable>
    80004070:	ffffd097          	auipc	ra,0xffffd
    80004074:	e26080e7          	jalr	-474(ra) # 80000e96 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004078:	4498                	lw	a4,8(s1)
    8000407a:	4785                	li	a5,1
    8000407c:	02f70363          	beq	a4,a5,800040a2 <iput+0x48>
  ip->ref--;
    80004080:	449c                	lw	a5,8(s1)
    80004082:	37fd                	addiw	a5,a5,-1
    80004084:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004086:	0003b517          	auipc	a0,0x3b
    8000408a:	1aa50513          	addi	a0,a0,426 # 8003f230 <itable>
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	ebc080e7          	jalr	-324(ra) # 80000f4a <release>
}
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	64a2                	ld	s1,8(sp)
    8000409c:	6902                	ld	s2,0(sp)
    8000409e:	6105                	addi	sp,sp,32
    800040a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040a2:	40bc                	lw	a5,64(s1)
    800040a4:	dff1                	beqz	a5,80004080 <iput+0x26>
    800040a6:	04a49783          	lh	a5,74(s1)
    800040aa:	fbf9                	bnez	a5,80004080 <iput+0x26>
    acquiresleep(&ip->lock);
    800040ac:	01048913          	addi	s2,s1,16
    800040b0:	854a                	mv	a0,s2
    800040b2:	00001097          	auipc	ra,0x1
    800040b6:	aae080e7          	jalr	-1362(ra) # 80004b60 <acquiresleep>
    release(&itable.lock);
    800040ba:	0003b517          	auipc	a0,0x3b
    800040be:	17650513          	addi	a0,a0,374 # 8003f230 <itable>
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	e88080e7          	jalr	-376(ra) # 80000f4a <release>
    itrunc(ip);
    800040ca:	8526                	mv	a0,s1
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	ee2080e7          	jalr	-286(ra) # 80003fae <itrunc>
    ip->type = 0;
    800040d4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040d8:	8526                	mv	a0,s1
    800040da:	00000097          	auipc	ra,0x0
    800040de:	cfa080e7          	jalr	-774(ra) # 80003dd4 <iupdate>
    ip->valid = 0;
    800040e2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040e6:	854a                	mv	a0,s2
    800040e8:	00001097          	auipc	ra,0x1
    800040ec:	ace080e7          	jalr	-1330(ra) # 80004bb6 <releasesleep>
    acquire(&itable.lock);
    800040f0:	0003b517          	auipc	a0,0x3b
    800040f4:	14050513          	addi	a0,a0,320 # 8003f230 <itable>
    800040f8:	ffffd097          	auipc	ra,0xffffd
    800040fc:	d9e080e7          	jalr	-610(ra) # 80000e96 <acquire>
    80004100:	b741                	j	80004080 <iput+0x26>

0000000080004102 <iunlockput>:
{
    80004102:	1101                	addi	sp,sp,-32
    80004104:	ec06                	sd	ra,24(sp)
    80004106:	e822                	sd	s0,16(sp)
    80004108:	e426                	sd	s1,8(sp)
    8000410a:	1000                	addi	s0,sp,32
    8000410c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	e54080e7          	jalr	-428(ra) # 80003f62 <iunlock>
  iput(ip);
    80004116:	8526                	mv	a0,s1
    80004118:	00000097          	auipc	ra,0x0
    8000411c:	f42080e7          	jalr	-190(ra) # 8000405a <iput>
}
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	64a2                	ld	s1,8(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000412a:	1141                	addi	sp,sp,-16
    8000412c:	e422                	sd	s0,8(sp)
    8000412e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004130:	411c                	lw	a5,0(a0)
    80004132:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004134:	415c                	lw	a5,4(a0)
    80004136:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004138:	04451783          	lh	a5,68(a0)
    8000413c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004140:	04a51783          	lh	a5,74(a0)
    80004144:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004148:	04c56783          	lwu	a5,76(a0)
    8000414c:	e99c                	sd	a5,16(a1)
}
    8000414e:	6422                	ld	s0,8(sp)
    80004150:	0141                	addi	sp,sp,16
    80004152:	8082                	ret

0000000080004154 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004154:	457c                	lw	a5,76(a0)
    80004156:	0ed7e963          	bltu	a5,a3,80004248 <readi+0xf4>
{
    8000415a:	7159                	addi	sp,sp,-112
    8000415c:	f486                	sd	ra,104(sp)
    8000415e:	f0a2                	sd	s0,96(sp)
    80004160:	eca6                	sd	s1,88(sp)
    80004162:	e8ca                	sd	s2,80(sp)
    80004164:	e4ce                	sd	s3,72(sp)
    80004166:	e0d2                	sd	s4,64(sp)
    80004168:	fc56                	sd	s5,56(sp)
    8000416a:	f85a                	sd	s6,48(sp)
    8000416c:	f45e                	sd	s7,40(sp)
    8000416e:	f062                	sd	s8,32(sp)
    80004170:	ec66                	sd	s9,24(sp)
    80004172:	e86a                	sd	s10,16(sp)
    80004174:	e46e                	sd	s11,8(sp)
    80004176:	1880                	addi	s0,sp,112
    80004178:	8b2a                	mv	s6,a0
    8000417a:	8bae                	mv	s7,a1
    8000417c:	8a32                	mv	s4,a2
    8000417e:	84b6                	mv	s1,a3
    80004180:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004182:	9f35                	addw	a4,a4,a3
    return 0;
    80004184:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004186:	0ad76063          	bltu	a4,a3,80004226 <readi+0xd2>
  if(off + n > ip->size)
    8000418a:	00e7f463          	bgeu	a5,a4,80004192 <readi+0x3e>
    n = ip->size - off;
    8000418e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004192:	0a0a8963          	beqz	s5,80004244 <readi+0xf0>
    80004196:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004198:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000419c:	5c7d                	li	s8,-1
    8000419e:	a82d                	j	800041d8 <readi+0x84>
    800041a0:	020d1d93          	slli	s11,s10,0x20
    800041a4:	020ddd93          	srli	s11,s11,0x20
    800041a8:	05890613          	addi	a2,s2,88
    800041ac:	86ee                	mv	a3,s11
    800041ae:	963a                	add	a2,a2,a4
    800041b0:	85d2                	mv	a1,s4
    800041b2:	855e                	mv	a0,s7
    800041b4:	ffffe097          	auipc	ra,0xffffe
    800041b8:	7c4080e7          	jalr	1988(ra) # 80002978 <either_copyout>
    800041bc:	05850d63          	beq	a0,s8,80004216 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041c0:	854a                	mv	a0,s2
    800041c2:	fffff097          	auipc	ra,0xfffff
    800041c6:	5f6080e7          	jalr	1526(ra) # 800037b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041ca:	013d09bb          	addw	s3,s10,s3
    800041ce:	009d04bb          	addw	s1,s10,s1
    800041d2:	9a6e                	add	s4,s4,s11
    800041d4:	0559f763          	bgeu	s3,s5,80004222 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800041d8:	00a4d59b          	srliw	a1,s1,0xa
    800041dc:	855a                	mv	a0,s6
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	89e080e7          	jalr	-1890(ra) # 80003a7c <bmap>
    800041e6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800041ea:	cd85                	beqz	a1,80004222 <readi+0xce>
    bp = bread(ip->dev, addr);
    800041ec:	000b2503          	lw	a0,0(s6)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	498080e7          	jalr	1176(ra) # 80003688 <bread>
    800041f8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041fa:	3ff4f713          	andi	a4,s1,1023
    800041fe:	40ec87bb          	subw	a5,s9,a4
    80004202:	413a86bb          	subw	a3,s5,s3
    80004206:	8d3e                	mv	s10,a5
    80004208:	2781                	sext.w	a5,a5
    8000420a:	0006861b          	sext.w	a2,a3
    8000420e:	f8f679e3          	bgeu	a2,a5,800041a0 <readi+0x4c>
    80004212:	8d36                	mv	s10,a3
    80004214:	b771                	j	800041a0 <readi+0x4c>
      brelse(bp);
    80004216:	854a                	mv	a0,s2
    80004218:	fffff097          	auipc	ra,0xfffff
    8000421c:	5a0080e7          	jalr	1440(ra) # 800037b8 <brelse>
      tot = -1;
    80004220:	59fd                	li	s3,-1
  }
  return tot;
    80004222:	0009851b          	sext.w	a0,s3
}
    80004226:	70a6                	ld	ra,104(sp)
    80004228:	7406                	ld	s0,96(sp)
    8000422a:	64e6                	ld	s1,88(sp)
    8000422c:	6946                	ld	s2,80(sp)
    8000422e:	69a6                	ld	s3,72(sp)
    80004230:	6a06                	ld	s4,64(sp)
    80004232:	7ae2                	ld	s5,56(sp)
    80004234:	7b42                	ld	s6,48(sp)
    80004236:	7ba2                	ld	s7,40(sp)
    80004238:	7c02                	ld	s8,32(sp)
    8000423a:	6ce2                	ld	s9,24(sp)
    8000423c:	6d42                	ld	s10,16(sp)
    8000423e:	6da2                	ld	s11,8(sp)
    80004240:	6165                	addi	sp,sp,112
    80004242:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004244:	89d6                	mv	s3,s5
    80004246:	bff1                	j	80004222 <readi+0xce>
    return 0;
    80004248:	4501                	li	a0,0
}
    8000424a:	8082                	ret

000000008000424c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000424c:	457c                	lw	a5,76(a0)
    8000424e:	10d7e863          	bltu	a5,a3,8000435e <writei+0x112>
{
    80004252:	7159                	addi	sp,sp,-112
    80004254:	f486                	sd	ra,104(sp)
    80004256:	f0a2                	sd	s0,96(sp)
    80004258:	eca6                	sd	s1,88(sp)
    8000425a:	e8ca                	sd	s2,80(sp)
    8000425c:	e4ce                	sd	s3,72(sp)
    8000425e:	e0d2                	sd	s4,64(sp)
    80004260:	fc56                	sd	s5,56(sp)
    80004262:	f85a                	sd	s6,48(sp)
    80004264:	f45e                	sd	s7,40(sp)
    80004266:	f062                	sd	s8,32(sp)
    80004268:	ec66                	sd	s9,24(sp)
    8000426a:	e86a                	sd	s10,16(sp)
    8000426c:	e46e                	sd	s11,8(sp)
    8000426e:	1880                	addi	s0,sp,112
    80004270:	8aaa                	mv	s5,a0
    80004272:	8bae                	mv	s7,a1
    80004274:	8a32                	mv	s4,a2
    80004276:	8936                	mv	s2,a3
    80004278:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000427a:	00e687bb          	addw	a5,a3,a4
    8000427e:	0ed7e263          	bltu	a5,a3,80004362 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004282:	00043737          	lui	a4,0x43
    80004286:	0ef76063          	bltu	a4,a5,80004366 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000428a:	0c0b0863          	beqz	s6,8000435a <writei+0x10e>
    8000428e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004290:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004294:	5c7d                	li	s8,-1
    80004296:	a091                	j	800042da <writei+0x8e>
    80004298:	020d1d93          	slli	s11,s10,0x20
    8000429c:	020ddd93          	srli	s11,s11,0x20
    800042a0:	05848513          	addi	a0,s1,88
    800042a4:	86ee                	mv	a3,s11
    800042a6:	8652                	mv	a2,s4
    800042a8:	85de                	mv	a1,s7
    800042aa:	953a                	add	a0,a0,a4
    800042ac:	ffffe097          	auipc	ra,0xffffe
    800042b0:	722080e7          	jalr	1826(ra) # 800029ce <either_copyin>
    800042b4:	07850263          	beq	a0,s8,80004318 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042b8:	8526                	mv	a0,s1
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	788080e7          	jalr	1928(ra) # 80004a42 <log_write>
    brelse(bp);
    800042c2:	8526                	mv	a0,s1
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	4f4080e7          	jalr	1268(ra) # 800037b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042cc:	013d09bb          	addw	s3,s10,s3
    800042d0:	012d093b          	addw	s2,s10,s2
    800042d4:	9a6e                	add	s4,s4,s11
    800042d6:	0569f663          	bgeu	s3,s6,80004322 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800042da:	00a9559b          	srliw	a1,s2,0xa
    800042de:	8556                	mv	a0,s5
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	79c080e7          	jalr	1948(ra) # 80003a7c <bmap>
    800042e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042ec:	c99d                	beqz	a1,80004322 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800042ee:	000aa503          	lw	a0,0(s5)
    800042f2:	fffff097          	auipc	ra,0xfffff
    800042f6:	396080e7          	jalr	918(ra) # 80003688 <bread>
    800042fa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042fc:	3ff97713          	andi	a4,s2,1023
    80004300:	40ec87bb          	subw	a5,s9,a4
    80004304:	413b06bb          	subw	a3,s6,s3
    80004308:	8d3e                	mv	s10,a5
    8000430a:	2781                	sext.w	a5,a5
    8000430c:	0006861b          	sext.w	a2,a3
    80004310:	f8f674e3          	bgeu	a2,a5,80004298 <writei+0x4c>
    80004314:	8d36                	mv	s10,a3
    80004316:	b749                	j	80004298 <writei+0x4c>
      brelse(bp);
    80004318:	8526                	mv	a0,s1
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	49e080e7          	jalr	1182(ra) # 800037b8 <brelse>
  }

  if(off > ip->size)
    80004322:	04caa783          	lw	a5,76(s5)
    80004326:	0127f463          	bgeu	a5,s2,8000432e <writei+0xe2>
    ip->size = off;
    8000432a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000432e:	8556                	mv	a0,s5
    80004330:	00000097          	auipc	ra,0x0
    80004334:	aa4080e7          	jalr	-1372(ra) # 80003dd4 <iupdate>

  return tot;
    80004338:	0009851b          	sext.w	a0,s3
}
    8000433c:	70a6                	ld	ra,104(sp)
    8000433e:	7406                	ld	s0,96(sp)
    80004340:	64e6                	ld	s1,88(sp)
    80004342:	6946                	ld	s2,80(sp)
    80004344:	69a6                	ld	s3,72(sp)
    80004346:	6a06                	ld	s4,64(sp)
    80004348:	7ae2                	ld	s5,56(sp)
    8000434a:	7b42                	ld	s6,48(sp)
    8000434c:	7ba2                	ld	s7,40(sp)
    8000434e:	7c02                	ld	s8,32(sp)
    80004350:	6ce2                	ld	s9,24(sp)
    80004352:	6d42                	ld	s10,16(sp)
    80004354:	6da2                	ld	s11,8(sp)
    80004356:	6165                	addi	sp,sp,112
    80004358:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000435a:	89da                	mv	s3,s6
    8000435c:	bfc9                	j	8000432e <writei+0xe2>
    return -1;
    8000435e:	557d                	li	a0,-1
}
    80004360:	8082                	ret
    return -1;
    80004362:	557d                	li	a0,-1
    80004364:	bfe1                	j	8000433c <writei+0xf0>
    return -1;
    80004366:	557d                	li	a0,-1
    80004368:	bfd1                	j	8000433c <writei+0xf0>

000000008000436a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000436a:	1141                	addi	sp,sp,-16
    8000436c:	e406                	sd	ra,8(sp)
    8000436e:	e022                	sd	s0,0(sp)
    80004370:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004372:	4639                	li	a2,14
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	cee080e7          	jalr	-786(ra) # 80001062 <strncmp>
}
    8000437c:	60a2                	ld	ra,8(sp)
    8000437e:	6402                	ld	s0,0(sp)
    80004380:	0141                	addi	sp,sp,16
    80004382:	8082                	ret

0000000080004384 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004384:	7139                	addi	sp,sp,-64
    80004386:	fc06                	sd	ra,56(sp)
    80004388:	f822                	sd	s0,48(sp)
    8000438a:	f426                	sd	s1,40(sp)
    8000438c:	f04a                	sd	s2,32(sp)
    8000438e:	ec4e                	sd	s3,24(sp)
    80004390:	e852                	sd	s4,16(sp)
    80004392:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004394:	04451703          	lh	a4,68(a0)
    80004398:	4785                	li	a5,1
    8000439a:	00f71a63          	bne	a4,a5,800043ae <dirlookup+0x2a>
    8000439e:	892a                	mv	s2,a0
    800043a0:	89ae                	mv	s3,a1
    800043a2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800043a4:	457c                	lw	a5,76(a0)
    800043a6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043a8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043aa:	e79d                	bnez	a5,800043d8 <dirlookup+0x54>
    800043ac:	a8a5                	j	80004424 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800043ae:	00004517          	auipc	a0,0x4
    800043b2:	3a250513          	addi	a0,a0,930 # 80008750 <syscalls+0x1c8>
    800043b6:	ffffc097          	auipc	ra,0xffffc
    800043ba:	18a080e7          	jalr	394(ra) # 80000540 <panic>
      panic("dirlookup read");
    800043be:	00004517          	auipc	a0,0x4
    800043c2:	3aa50513          	addi	a0,a0,938 # 80008768 <syscalls+0x1e0>
    800043c6:	ffffc097          	auipc	ra,0xffffc
    800043ca:	17a080e7          	jalr	378(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ce:	24c1                	addiw	s1,s1,16
    800043d0:	04c92783          	lw	a5,76(s2)
    800043d4:	04f4f763          	bgeu	s1,a5,80004422 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d8:	4741                	li	a4,16
    800043da:	86a6                	mv	a3,s1
    800043dc:	fc040613          	addi	a2,s0,-64
    800043e0:	4581                	li	a1,0
    800043e2:	854a                	mv	a0,s2
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	d70080e7          	jalr	-656(ra) # 80004154 <readi>
    800043ec:	47c1                	li	a5,16
    800043ee:	fcf518e3          	bne	a0,a5,800043be <dirlookup+0x3a>
    if(de.inum == 0)
    800043f2:	fc045783          	lhu	a5,-64(s0)
    800043f6:	dfe1                	beqz	a5,800043ce <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800043f8:	fc240593          	addi	a1,s0,-62
    800043fc:	854e                	mv	a0,s3
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	f6c080e7          	jalr	-148(ra) # 8000436a <namecmp>
    80004406:	f561                	bnez	a0,800043ce <dirlookup+0x4a>
      if(poff)
    80004408:	000a0463          	beqz	s4,80004410 <dirlookup+0x8c>
        *poff = off;
    8000440c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004410:	fc045583          	lhu	a1,-64(s0)
    80004414:	00092503          	lw	a0,0(s2)
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	74e080e7          	jalr	1870(ra) # 80003b66 <iget>
    80004420:	a011                	j	80004424 <dirlookup+0xa0>
  return 0;
    80004422:	4501                	li	a0,0
}
    80004424:	70e2                	ld	ra,56(sp)
    80004426:	7442                	ld	s0,48(sp)
    80004428:	74a2                	ld	s1,40(sp)
    8000442a:	7902                	ld	s2,32(sp)
    8000442c:	69e2                	ld	s3,24(sp)
    8000442e:	6a42                	ld	s4,16(sp)
    80004430:	6121                	addi	sp,sp,64
    80004432:	8082                	ret

0000000080004434 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004434:	711d                	addi	sp,sp,-96
    80004436:	ec86                	sd	ra,88(sp)
    80004438:	e8a2                	sd	s0,80(sp)
    8000443a:	e4a6                	sd	s1,72(sp)
    8000443c:	e0ca                	sd	s2,64(sp)
    8000443e:	fc4e                	sd	s3,56(sp)
    80004440:	f852                	sd	s4,48(sp)
    80004442:	f456                	sd	s5,40(sp)
    80004444:	f05a                	sd	s6,32(sp)
    80004446:	ec5e                	sd	s7,24(sp)
    80004448:	e862                	sd	s8,16(sp)
    8000444a:	e466                	sd	s9,8(sp)
    8000444c:	e06a                	sd	s10,0(sp)
    8000444e:	1080                	addi	s0,sp,96
    80004450:	84aa                	mv	s1,a0
    80004452:	8b2e                	mv	s6,a1
    80004454:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004456:	00054703          	lbu	a4,0(a0)
    8000445a:	02f00793          	li	a5,47
    8000445e:	02f70363          	beq	a4,a5,80004484 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004462:	ffffe097          	auipc	ra,0xffffe
    80004466:	960080e7          	jalr	-1696(ra) # 80001dc2 <myproc>
    8000446a:	15053503          	ld	a0,336(a0)
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	9f4080e7          	jalr	-1548(ra) # 80003e62 <idup>
    80004476:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004478:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000447c:	4cb5                	li	s9,13
  len = path - s;
    8000447e:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004480:	4c05                	li	s8,1
    80004482:	a87d                	j	80004540 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004484:	4585                	li	a1,1
    80004486:	4505                	li	a0,1
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	6de080e7          	jalr	1758(ra) # 80003b66 <iget>
    80004490:	8a2a                	mv	s4,a0
    80004492:	b7dd                	j	80004478 <namex+0x44>
      iunlockput(ip);
    80004494:	8552                	mv	a0,s4
    80004496:	00000097          	auipc	ra,0x0
    8000449a:	c6c080e7          	jalr	-916(ra) # 80004102 <iunlockput>
      return 0;
    8000449e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800044a0:	8552                	mv	a0,s4
    800044a2:	60e6                	ld	ra,88(sp)
    800044a4:	6446                	ld	s0,80(sp)
    800044a6:	64a6                	ld	s1,72(sp)
    800044a8:	6906                	ld	s2,64(sp)
    800044aa:	79e2                	ld	s3,56(sp)
    800044ac:	7a42                	ld	s4,48(sp)
    800044ae:	7aa2                	ld	s5,40(sp)
    800044b0:	7b02                	ld	s6,32(sp)
    800044b2:	6be2                	ld	s7,24(sp)
    800044b4:	6c42                	ld	s8,16(sp)
    800044b6:	6ca2                	ld	s9,8(sp)
    800044b8:	6d02                	ld	s10,0(sp)
    800044ba:	6125                	addi	sp,sp,96
    800044bc:	8082                	ret
      iunlock(ip);
    800044be:	8552                	mv	a0,s4
    800044c0:	00000097          	auipc	ra,0x0
    800044c4:	aa2080e7          	jalr	-1374(ra) # 80003f62 <iunlock>
      return ip;
    800044c8:	bfe1                	j	800044a0 <namex+0x6c>
      iunlockput(ip);
    800044ca:	8552                	mv	a0,s4
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	c36080e7          	jalr	-970(ra) # 80004102 <iunlockput>
      return 0;
    800044d4:	8a4e                	mv	s4,s3
    800044d6:	b7e9                	j	800044a0 <namex+0x6c>
  len = path - s;
    800044d8:	40998633          	sub	a2,s3,s1
    800044dc:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800044e0:	09acd863          	bge	s9,s10,80004570 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800044e4:	4639                	li	a2,14
    800044e6:	85a6                	mv	a1,s1
    800044e8:	8556                	mv	a0,s5
    800044ea:	ffffd097          	auipc	ra,0xffffd
    800044ee:	b04080e7          	jalr	-1276(ra) # 80000fee <memmove>
    800044f2:	84ce                	mv	s1,s3
  while(*path == '/')
    800044f4:	0004c783          	lbu	a5,0(s1)
    800044f8:	01279763          	bne	a5,s2,80004506 <namex+0xd2>
    path++;
    800044fc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044fe:	0004c783          	lbu	a5,0(s1)
    80004502:	ff278de3          	beq	a5,s2,800044fc <namex+0xc8>
    ilock(ip);
    80004506:	8552                	mv	a0,s4
    80004508:	00000097          	auipc	ra,0x0
    8000450c:	998080e7          	jalr	-1640(ra) # 80003ea0 <ilock>
    if(ip->type != T_DIR){
    80004510:	044a1783          	lh	a5,68(s4)
    80004514:	f98790e3          	bne	a5,s8,80004494 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004518:	000b0563          	beqz	s6,80004522 <namex+0xee>
    8000451c:	0004c783          	lbu	a5,0(s1)
    80004520:	dfd9                	beqz	a5,800044be <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004522:	865e                	mv	a2,s7
    80004524:	85d6                	mv	a1,s5
    80004526:	8552                	mv	a0,s4
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	e5c080e7          	jalr	-420(ra) # 80004384 <dirlookup>
    80004530:	89aa                	mv	s3,a0
    80004532:	dd41                	beqz	a0,800044ca <namex+0x96>
    iunlockput(ip);
    80004534:	8552                	mv	a0,s4
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	bcc080e7          	jalr	-1076(ra) # 80004102 <iunlockput>
    ip = next;
    8000453e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004540:	0004c783          	lbu	a5,0(s1)
    80004544:	01279763          	bne	a5,s2,80004552 <namex+0x11e>
    path++;
    80004548:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000454a:	0004c783          	lbu	a5,0(s1)
    8000454e:	ff278de3          	beq	a5,s2,80004548 <namex+0x114>
  if(*path == 0)
    80004552:	cb9d                	beqz	a5,80004588 <namex+0x154>
  while(*path != '/' && *path != 0)
    80004554:	0004c783          	lbu	a5,0(s1)
    80004558:	89a6                	mv	s3,s1
  len = path - s;
    8000455a:	8d5e                	mv	s10,s7
    8000455c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000455e:	01278963          	beq	a5,s2,80004570 <namex+0x13c>
    80004562:	dbbd                	beqz	a5,800044d8 <namex+0xa4>
    path++;
    80004564:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004566:	0009c783          	lbu	a5,0(s3)
    8000456a:	ff279ce3          	bne	a5,s2,80004562 <namex+0x12e>
    8000456e:	b7ad                	j	800044d8 <namex+0xa4>
    memmove(name, s, len);
    80004570:	2601                	sext.w	a2,a2
    80004572:	85a6                	mv	a1,s1
    80004574:	8556                	mv	a0,s5
    80004576:	ffffd097          	auipc	ra,0xffffd
    8000457a:	a78080e7          	jalr	-1416(ra) # 80000fee <memmove>
    name[len] = 0;
    8000457e:	9d56                	add	s10,s10,s5
    80004580:	000d0023          	sb	zero,0(s10)
    80004584:	84ce                	mv	s1,s3
    80004586:	b7bd                	j	800044f4 <namex+0xc0>
  if(nameiparent){
    80004588:	f00b0ce3          	beqz	s6,800044a0 <namex+0x6c>
    iput(ip);
    8000458c:	8552                	mv	a0,s4
    8000458e:	00000097          	auipc	ra,0x0
    80004592:	acc080e7          	jalr	-1332(ra) # 8000405a <iput>
    return 0;
    80004596:	4a01                	li	s4,0
    80004598:	b721                	j	800044a0 <namex+0x6c>

000000008000459a <dirlink>:
{
    8000459a:	7139                	addi	sp,sp,-64
    8000459c:	fc06                	sd	ra,56(sp)
    8000459e:	f822                	sd	s0,48(sp)
    800045a0:	f426                	sd	s1,40(sp)
    800045a2:	f04a                	sd	s2,32(sp)
    800045a4:	ec4e                	sd	s3,24(sp)
    800045a6:	e852                	sd	s4,16(sp)
    800045a8:	0080                	addi	s0,sp,64
    800045aa:	892a                	mv	s2,a0
    800045ac:	8a2e                	mv	s4,a1
    800045ae:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800045b0:	4601                	li	a2,0
    800045b2:	00000097          	auipc	ra,0x0
    800045b6:	dd2080e7          	jalr	-558(ra) # 80004384 <dirlookup>
    800045ba:	e93d                	bnez	a0,80004630 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045bc:	04c92483          	lw	s1,76(s2)
    800045c0:	c49d                	beqz	s1,800045ee <dirlink+0x54>
    800045c2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045c4:	4741                	li	a4,16
    800045c6:	86a6                	mv	a3,s1
    800045c8:	fc040613          	addi	a2,s0,-64
    800045cc:	4581                	li	a1,0
    800045ce:	854a                	mv	a0,s2
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	b84080e7          	jalr	-1148(ra) # 80004154 <readi>
    800045d8:	47c1                	li	a5,16
    800045da:	06f51163          	bne	a0,a5,8000463c <dirlink+0xa2>
    if(de.inum == 0)
    800045de:	fc045783          	lhu	a5,-64(s0)
    800045e2:	c791                	beqz	a5,800045ee <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045e4:	24c1                	addiw	s1,s1,16
    800045e6:	04c92783          	lw	a5,76(s2)
    800045ea:	fcf4ede3          	bltu	s1,a5,800045c4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800045ee:	4639                	li	a2,14
    800045f0:	85d2                	mv	a1,s4
    800045f2:	fc240513          	addi	a0,s0,-62
    800045f6:	ffffd097          	auipc	ra,0xffffd
    800045fa:	aa8080e7          	jalr	-1368(ra) # 8000109e <strncpy>
  de.inum = inum;
    800045fe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004602:	4741                	li	a4,16
    80004604:	86a6                	mv	a3,s1
    80004606:	fc040613          	addi	a2,s0,-64
    8000460a:	4581                	li	a1,0
    8000460c:	854a                	mv	a0,s2
    8000460e:	00000097          	auipc	ra,0x0
    80004612:	c3e080e7          	jalr	-962(ra) # 8000424c <writei>
    80004616:	1541                	addi	a0,a0,-16
    80004618:	00a03533          	snez	a0,a0
    8000461c:	40a00533          	neg	a0,a0
}
    80004620:	70e2                	ld	ra,56(sp)
    80004622:	7442                	ld	s0,48(sp)
    80004624:	74a2                	ld	s1,40(sp)
    80004626:	7902                	ld	s2,32(sp)
    80004628:	69e2                	ld	s3,24(sp)
    8000462a:	6a42                	ld	s4,16(sp)
    8000462c:	6121                	addi	sp,sp,64
    8000462e:	8082                	ret
    iput(ip);
    80004630:	00000097          	auipc	ra,0x0
    80004634:	a2a080e7          	jalr	-1494(ra) # 8000405a <iput>
    return -1;
    80004638:	557d                	li	a0,-1
    8000463a:	b7dd                	j	80004620 <dirlink+0x86>
      panic("dirlink read");
    8000463c:	00004517          	auipc	a0,0x4
    80004640:	13c50513          	addi	a0,a0,316 # 80008778 <syscalls+0x1f0>
    80004644:	ffffc097          	auipc	ra,0xffffc
    80004648:	efc080e7          	jalr	-260(ra) # 80000540 <panic>

000000008000464c <namei>:

struct inode*
namei(char *path)
{
    8000464c:	1101                	addi	sp,sp,-32
    8000464e:	ec06                	sd	ra,24(sp)
    80004650:	e822                	sd	s0,16(sp)
    80004652:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004654:	fe040613          	addi	a2,s0,-32
    80004658:	4581                	li	a1,0
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	dda080e7          	jalr	-550(ra) # 80004434 <namex>
}
    80004662:	60e2                	ld	ra,24(sp)
    80004664:	6442                	ld	s0,16(sp)
    80004666:	6105                	addi	sp,sp,32
    80004668:	8082                	ret

000000008000466a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000466a:	1141                	addi	sp,sp,-16
    8000466c:	e406                	sd	ra,8(sp)
    8000466e:	e022                	sd	s0,0(sp)
    80004670:	0800                	addi	s0,sp,16
    80004672:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004674:	4585                	li	a1,1
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	dbe080e7          	jalr	-578(ra) # 80004434 <namex>
}
    8000467e:	60a2                	ld	ra,8(sp)
    80004680:	6402                	ld	s0,0(sp)
    80004682:	0141                	addi	sp,sp,16
    80004684:	8082                	ret

0000000080004686 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004686:	1101                	addi	sp,sp,-32
    80004688:	ec06                	sd	ra,24(sp)
    8000468a:	e822                	sd	s0,16(sp)
    8000468c:	e426                	sd	s1,8(sp)
    8000468e:	e04a                	sd	s2,0(sp)
    80004690:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004692:	0003c917          	auipc	s2,0x3c
    80004696:	64690913          	addi	s2,s2,1606 # 80040cd8 <log>
    8000469a:	01892583          	lw	a1,24(s2)
    8000469e:	02892503          	lw	a0,40(s2)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	fe6080e7          	jalr	-26(ra) # 80003688 <bread>
    800046aa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046ac:	02c92683          	lw	a3,44(s2)
    800046b0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046b2:	02d05863          	blez	a3,800046e2 <write_head+0x5c>
    800046b6:	0003c797          	auipc	a5,0x3c
    800046ba:	65278793          	addi	a5,a5,1618 # 80040d08 <log+0x30>
    800046be:	05c50713          	addi	a4,a0,92
    800046c2:	36fd                	addiw	a3,a3,-1
    800046c4:	02069613          	slli	a2,a3,0x20
    800046c8:	01e65693          	srli	a3,a2,0x1e
    800046cc:	0003c617          	auipc	a2,0x3c
    800046d0:	64060613          	addi	a2,a2,1600 # 80040d0c <log+0x34>
    800046d4:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800046d6:	4390                	lw	a2,0(a5)
    800046d8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046da:	0791                	addi	a5,a5,4
    800046dc:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800046de:	fed79ce3          	bne	a5,a3,800046d6 <write_head+0x50>
  }
  bwrite(buf);
    800046e2:	8526                	mv	a0,s1
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	096080e7          	jalr	150(ra) # 8000377a <bwrite>
  brelse(buf);
    800046ec:	8526                	mv	a0,s1
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	0ca080e7          	jalr	202(ra) # 800037b8 <brelse>
}
    800046f6:	60e2                	ld	ra,24(sp)
    800046f8:	6442                	ld	s0,16(sp)
    800046fa:	64a2                	ld	s1,8(sp)
    800046fc:	6902                	ld	s2,0(sp)
    800046fe:	6105                	addi	sp,sp,32
    80004700:	8082                	ret

0000000080004702 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004702:	0003c797          	auipc	a5,0x3c
    80004706:	6027a783          	lw	a5,1538(a5) # 80040d04 <log+0x2c>
    8000470a:	0af05d63          	blez	a5,800047c4 <install_trans+0xc2>
{
    8000470e:	7139                	addi	sp,sp,-64
    80004710:	fc06                	sd	ra,56(sp)
    80004712:	f822                	sd	s0,48(sp)
    80004714:	f426                	sd	s1,40(sp)
    80004716:	f04a                	sd	s2,32(sp)
    80004718:	ec4e                	sd	s3,24(sp)
    8000471a:	e852                	sd	s4,16(sp)
    8000471c:	e456                	sd	s5,8(sp)
    8000471e:	e05a                	sd	s6,0(sp)
    80004720:	0080                	addi	s0,sp,64
    80004722:	8b2a                	mv	s6,a0
    80004724:	0003ca97          	auipc	s5,0x3c
    80004728:	5e4a8a93          	addi	s5,s5,1508 # 80040d08 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000472c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000472e:	0003c997          	auipc	s3,0x3c
    80004732:	5aa98993          	addi	s3,s3,1450 # 80040cd8 <log>
    80004736:	a00d                	j	80004758 <install_trans+0x56>
    brelse(lbuf);
    80004738:	854a                	mv	a0,s2
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	07e080e7          	jalr	126(ra) # 800037b8 <brelse>
    brelse(dbuf);
    80004742:	8526                	mv	a0,s1
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	074080e7          	jalr	116(ra) # 800037b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000474c:	2a05                	addiw	s4,s4,1
    8000474e:	0a91                	addi	s5,s5,4
    80004750:	02c9a783          	lw	a5,44(s3)
    80004754:	04fa5e63          	bge	s4,a5,800047b0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004758:	0189a583          	lw	a1,24(s3)
    8000475c:	014585bb          	addw	a1,a1,s4
    80004760:	2585                	addiw	a1,a1,1
    80004762:	0289a503          	lw	a0,40(s3)
    80004766:	fffff097          	auipc	ra,0xfffff
    8000476a:	f22080e7          	jalr	-222(ra) # 80003688 <bread>
    8000476e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004770:	000aa583          	lw	a1,0(s5)
    80004774:	0289a503          	lw	a0,40(s3)
    80004778:	fffff097          	auipc	ra,0xfffff
    8000477c:	f10080e7          	jalr	-240(ra) # 80003688 <bread>
    80004780:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004782:	40000613          	li	a2,1024
    80004786:	05890593          	addi	a1,s2,88
    8000478a:	05850513          	addi	a0,a0,88
    8000478e:	ffffd097          	auipc	ra,0xffffd
    80004792:	860080e7          	jalr	-1952(ra) # 80000fee <memmove>
    bwrite(dbuf);  // write dst to disk
    80004796:	8526                	mv	a0,s1
    80004798:	fffff097          	auipc	ra,0xfffff
    8000479c:	fe2080e7          	jalr	-30(ra) # 8000377a <bwrite>
    if(recovering == 0)
    800047a0:	f80b1ce3          	bnez	s6,80004738 <install_trans+0x36>
      bunpin(dbuf);
    800047a4:	8526                	mv	a0,s1
    800047a6:	fffff097          	auipc	ra,0xfffff
    800047aa:	0ec080e7          	jalr	236(ra) # 80003892 <bunpin>
    800047ae:	b769                	j	80004738 <install_trans+0x36>
}
    800047b0:	70e2                	ld	ra,56(sp)
    800047b2:	7442                	ld	s0,48(sp)
    800047b4:	74a2                	ld	s1,40(sp)
    800047b6:	7902                	ld	s2,32(sp)
    800047b8:	69e2                	ld	s3,24(sp)
    800047ba:	6a42                	ld	s4,16(sp)
    800047bc:	6aa2                	ld	s5,8(sp)
    800047be:	6b02                	ld	s6,0(sp)
    800047c0:	6121                	addi	sp,sp,64
    800047c2:	8082                	ret
    800047c4:	8082                	ret

00000000800047c6 <initlog>:
{
    800047c6:	7179                	addi	sp,sp,-48
    800047c8:	f406                	sd	ra,40(sp)
    800047ca:	f022                	sd	s0,32(sp)
    800047cc:	ec26                	sd	s1,24(sp)
    800047ce:	e84a                	sd	s2,16(sp)
    800047d0:	e44e                	sd	s3,8(sp)
    800047d2:	1800                	addi	s0,sp,48
    800047d4:	892a                	mv	s2,a0
    800047d6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047d8:	0003c497          	auipc	s1,0x3c
    800047dc:	50048493          	addi	s1,s1,1280 # 80040cd8 <log>
    800047e0:	00004597          	auipc	a1,0x4
    800047e4:	fa858593          	addi	a1,a1,-88 # 80008788 <syscalls+0x200>
    800047e8:	8526                	mv	a0,s1
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	61c080e7          	jalr	1564(ra) # 80000e06 <initlock>
  log.start = sb->logstart;
    800047f2:	0149a583          	lw	a1,20(s3)
    800047f6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800047f8:	0109a783          	lw	a5,16(s3)
    800047fc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800047fe:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004802:	854a                	mv	a0,s2
    80004804:	fffff097          	auipc	ra,0xfffff
    80004808:	e84080e7          	jalr	-380(ra) # 80003688 <bread>
  log.lh.n = lh->n;
    8000480c:	4d34                	lw	a3,88(a0)
    8000480e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004810:	02d05663          	blez	a3,8000483c <initlog+0x76>
    80004814:	05c50793          	addi	a5,a0,92
    80004818:	0003c717          	auipc	a4,0x3c
    8000481c:	4f070713          	addi	a4,a4,1264 # 80040d08 <log+0x30>
    80004820:	36fd                	addiw	a3,a3,-1
    80004822:	02069613          	slli	a2,a3,0x20
    80004826:	01e65693          	srli	a3,a2,0x1e
    8000482a:	06050613          	addi	a2,a0,96
    8000482e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004830:	4390                	lw	a2,0(a5)
    80004832:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004834:	0791                	addi	a5,a5,4
    80004836:	0711                	addi	a4,a4,4
    80004838:	fed79ce3          	bne	a5,a3,80004830 <initlog+0x6a>
  brelse(buf);
    8000483c:	fffff097          	auipc	ra,0xfffff
    80004840:	f7c080e7          	jalr	-132(ra) # 800037b8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004844:	4505                	li	a0,1
    80004846:	00000097          	auipc	ra,0x0
    8000484a:	ebc080e7          	jalr	-324(ra) # 80004702 <install_trans>
  log.lh.n = 0;
    8000484e:	0003c797          	auipc	a5,0x3c
    80004852:	4a07ab23          	sw	zero,1206(a5) # 80040d04 <log+0x2c>
  write_head(); // clear the log
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	e30080e7          	jalr	-464(ra) # 80004686 <write_head>
}
    8000485e:	70a2                	ld	ra,40(sp)
    80004860:	7402                	ld	s0,32(sp)
    80004862:	64e2                	ld	s1,24(sp)
    80004864:	6942                	ld	s2,16(sp)
    80004866:	69a2                	ld	s3,8(sp)
    80004868:	6145                	addi	sp,sp,48
    8000486a:	8082                	ret

000000008000486c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000486c:	1101                	addi	sp,sp,-32
    8000486e:	ec06                	sd	ra,24(sp)
    80004870:	e822                	sd	s0,16(sp)
    80004872:	e426                	sd	s1,8(sp)
    80004874:	e04a                	sd	s2,0(sp)
    80004876:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004878:	0003c517          	auipc	a0,0x3c
    8000487c:	46050513          	addi	a0,a0,1120 # 80040cd8 <log>
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	616080e7          	jalr	1558(ra) # 80000e96 <acquire>
  while(1){
    if(log.committing){
    80004888:	0003c497          	auipc	s1,0x3c
    8000488c:	45048493          	addi	s1,s1,1104 # 80040cd8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004890:	4979                	li	s2,30
    80004892:	a039                	j	800048a0 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004894:	85a6                	mv	a1,s1
    80004896:	8526                	mv	a0,s1
    80004898:	ffffe097          	auipc	ra,0xffffe
    8000489c:	cd8080e7          	jalr	-808(ra) # 80002570 <sleep>
    if(log.committing){
    800048a0:	50dc                	lw	a5,36(s1)
    800048a2:	fbed                	bnez	a5,80004894 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800048a4:	5098                	lw	a4,32(s1)
    800048a6:	2705                	addiw	a4,a4,1
    800048a8:	0007069b          	sext.w	a3,a4
    800048ac:	0027179b          	slliw	a5,a4,0x2
    800048b0:	9fb9                	addw	a5,a5,a4
    800048b2:	0017979b          	slliw	a5,a5,0x1
    800048b6:	54d8                	lw	a4,44(s1)
    800048b8:	9fb9                	addw	a5,a5,a4
    800048ba:	00f95963          	bge	s2,a5,800048cc <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048be:	85a6                	mv	a1,s1
    800048c0:	8526                	mv	a0,s1
    800048c2:	ffffe097          	auipc	ra,0xffffe
    800048c6:	cae080e7          	jalr	-850(ra) # 80002570 <sleep>
    800048ca:	bfd9                	j	800048a0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048cc:	0003c517          	auipc	a0,0x3c
    800048d0:	40c50513          	addi	a0,a0,1036 # 80040cd8 <log>
    800048d4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	674080e7          	jalr	1652(ra) # 80000f4a <release>
      break;
    }
  }
}
    800048de:	60e2                	ld	ra,24(sp)
    800048e0:	6442                	ld	s0,16(sp)
    800048e2:	64a2                	ld	s1,8(sp)
    800048e4:	6902                	ld	s2,0(sp)
    800048e6:	6105                	addi	sp,sp,32
    800048e8:	8082                	ret

00000000800048ea <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048ea:	7139                	addi	sp,sp,-64
    800048ec:	fc06                	sd	ra,56(sp)
    800048ee:	f822                	sd	s0,48(sp)
    800048f0:	f426                	sd	s1,40(sp)
    800048f2:	f04a                	sd	s2,32(sp)
    800048f4:	ec4e                	sd	s3,24(sp)
    800048f6:	e852                	sd	s4,16(sp)
    800048f8:	e456                	sd	s5,8(sp)
    800048fa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800048fc:	0003c497          	auipc	s1,0x3c
    80004900:	3dc48493          	addi	s1,s1,988 # 80040cd8 <log>
    80004904:	8526                	mv	a0,s1
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	590080e7          	jalr	1424(ra) # 80000e96 <acquire>
  log.outstanding -= 1;
    8000490e:	509c                	lw	a5,32(s1)
    80004910:	37fd                	addiw	a5,a5,-1
    80004912:	0007891b          	sext.w	s2,a5
    80004916:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004918:	50dc                	lw	a5,36(s1)
    8000491a:	e7b9                	bnez	a5,80004968 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000491c:	04091e63          	bnez	s2,80004978 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004920:	0003c497          	auipc	s1,0x3c
    80004924:	3b848493          	addi	s1,s1,952 # 80040cd8 <log>
    80004928:	4785                	li	a5,1
    8000492a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000492c:	8526                	mv	a0,s1
    8000492e:	ffffc097          	auipc	ra,0xffffc
    80004932:	61c080e7          	jalr	1564(ra) # 80000f4a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004936:	54dc                	lw	a5,44(s1)
    80004938:	06f04763          	bgtz	a5,800049a6 <end_op+0xbc>
    acquire(&log.lock);
    8000493c:	0003c497          	auipc	s1,0x3c
    80004940:	39c48493          	addi	s1,s1,924 # 80040cd8 <log>
    80004944:	8526                	mv	a0,s1
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	550080e7          	jalr	1360(ra) # 80000e96 <acquire>
    log.committing = 0;
    8000494e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004952:	8526                	mv	a0,s1
    80004954:	ffffe097          	auipc	ra,0xffffe
    80004958:	c80080e7          	jalr	-896(ra) # 800025d4 <wakeup>
    release(&log.lock);
    8000495c:	8526                	mv	a0,s1
    8000495e:	ffffc097          	auipc	ra,0xffffc
    80004962:	5ec080e7          	jalr	1516(ra) # 80000f4a <release>
}
    80004966:	a03d                	j	80004994 <end_op+0xaa>
    panic("log.committing");
    80004968:	00004517          	auipc	a0,0x4
    8000496c:	e2850513          	addi	a0,a0,-472 # 80008790 <syscalls+0x208>
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	bd0080e7          	jalr	-1072(ra) # 80000540 <panic>
    wakeup(&log);
    80004978:	0003c497          	auipc	s1,0x3c
    8000497c:	36048493          	addi	s1,s1,864 # 80040cd8 <log>
    80004980:	8526                	mv	a0,s1
    80004982:	ffffe097          	auipc	ra,0xffffe
    80004986:	c52080e7          	jalr	-942(ra) # 800025d4 <wakeup>
  release(&log.lock);
    8000498a:	8526                	mv	a0,s1
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	5be080e7          	jalr	1470(ra) # 80000f4a <release>
}
    80004994:	70e2                	ld	ra,56(sp)
    80004996:	7442                	ld	s0,48(sp)
    80004998:	74a2                	ld	s1,40(sp)
    8000499a:	7902                	ld	s2,32(sp)
    8000499c:	69e2                	ld	s3,24(sp)
    8000499e:	6a42                	ld	s4,16(sp)
    800049a0:	6aa2                	ld	s5,8(sp)
    800049a2:	6121                	addi	sp,sp,64
    800049a4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800049a6:	0003ca97          	auipc	s5,0x3c
    800049aa:	362a8a93          	addi	s5,s5,866 # 80040d08 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049ae:	0003ca17          	auipc	s4,0x3c
    800049b2:	32aa0a13          	addi	s4,s4,810 # 80040cd8 <log>
    800049b6:	018a2583          	lw	a1,24(s4)
    800049ba:	012585bb          	addw	a1,a1,s2
    800049be:	2585                	addiw	a1,a1,1
    800049c0:	028a2503          	lw	a0,40(s4)
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	cc4080e7          	jalr	-828(ra) # 80003688 <bread>
    800049cc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049ce:	000aa583          	lw	a1,0(s5)
    800049d2:	028a2503          	lw	a0,40(s4)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	cb2080e7          	jalr	-846(ra) # 80003688 <bread>
    800049de:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049e0:	40000613          	li	a2,1024
    800049e4:	05850593          	addi	a1,a0,88
    800049e8:	05848513          	addi	a0,s1,88
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	602080e7          	jalr	1538(ra) # 80000fee <memmove>
    bwrite(to);  // write the log
    800049f4:	8526                	mv	a0,s1
    800049f6:	fffff097          	auipc	ra,0xfffff
    800049fa:	d84080e7          	jalr	-636(ra) # 8000377a <bwrite>
    brelse(from);
    800049fe:	854e                	mv	a0,s3
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	db8080e7          	jalr	-584(ra) # 800037b8 <brelse>
    brelse(to);
    80004a08:	8526                	mv	a0,s1
    80004a0a:	fffff097          	auipc	ra,0xfffff
    80004a0e:	dae080e7          	jalr	-594(ra) # 800037b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a12:	2905                	addiw	s2,s2,1
    80004a14:	0a91                	addi	s5,s5,4
    80004a16:	02ca2783          	lw	a5,44(s4)
    80004a1a:	f8f94ee3          	blt	s2,a5,800049b6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a1e:	00000097          	auipc	ra,0x0
    80004a22:	c68080e7          	jalr	-920(ra) # 80004686 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a26:	4501                	li	a0,0
    80004a28:	00000097          	auipc	ra,0x0
    80004a2c:	cda080e7          	jalr	-806(ra) # 80004702 <install_trans>
    log.lh.n = 0;
    80004a30:	0003c797          	auipc	a5,0x3c
    80004a34:	2c07aa23          	sw	zero,724(a5) # 80040d04 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	c4e080e7          	jalr	-946(ra) # 80004686 <write_head>
    80004a40:	bdf5                	j	8000493c <end_op+0x52>

0000000080004a42 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a42:	1101                	addi	sp,sp,-32
    80004a44:	ec06                	sd	ra,24(sp)
    80004a46:	e822                	sd	s0,16(sp)
    80004a48:	e426                	sd	s1,8(sp)
    80004a4a:	e04a                	sd	s2,0(sp)
    80004a4c:	1000                	addi	s0,sp,32
    80004a4e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a50:	0003c917          	auipc	s2,0x3c
    80004a54:	28890913          	addi	s2,s2,648 # 80040cd8 <log>
    80004a58:	854a                	mv	a0,s2
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	43c080e7          	jalr	1084(ra) # 80000e96 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a62:	02c92603          	lw	a2,44(s2)
    80004a66:	47f5                	li	a5,29
    80004a68:	06c7c563          	blt	a5,a2,80004ad2 <log_write+0x90>
    80004a6c:	0003c797          	auipc	a5,0x3c
    80004a70:	2887a783          	lw	a5,648(a5) # 80040cf4 <log+0x1c>
    80004a74:	37fd                	addiw	a5,a5,-1
    80004a76:	04f65e63          	bge	a2,a5,80004ad2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a7a:	0003c797          	auipc	a5,0x3c
    80004a7e:	27e7a783          	lw	a5,638(a5) # 80040cf8 <log+0x20>
    80004a82:	06f05063          	blez	a5,80004ae2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a86:	4781                	li	a5,0
    80004a88:	06c05563          	blez	a2,80004af2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a8c:	44cc                	lw	a1,12(s1)
    80004a8e:	0003c717          	auipc	a4,0x3c
    80004a92:	27a70713          	addi	a4,a4,634 # 80040d08 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004a96:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a98:	4314                	lw	a3,0(a4)
    80004a9a:	04b68c63          	beq	a3,a1,80004af2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004a9e:	2785                	addiw	a5,a5,1
    80004aa0:	0711                	addi	a4,a4,4
    80004aa2:	fef61be3          	bne	a2,a5,80004a98 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004aa6:	0621                	addi	a2,a2,8
    80004aa8:	060a                	slli	a2,a2,0x2
    80004aaa:	0003c797          	auipc	a5,0x3c
    80004aae:	22e78793          	addi	a5,a5,558 # 80040cd8 <log>
    80004ab2:	97b2                	add	a5,a5,a2
    80004ab4:	44d8                	lw	a4,12(s1)
    80004ab6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ab8:	8526                	mv	a0,s1
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	d9c080e7          	jalr	-612(ra) # 80003856 <bpin>
    log.lh.n++;
    80004ac2:	0003c717          	auipc	a4,0x3c
    80004ac6:	21670713          	addi	a4,a4,534 # 80040cd8 <log>
    80004aca:	575c                	lw	a5,44(a4)
    80004acc:	2785                	addiw	a5,a5,1
    80004ace:	d75c                	sw	a5,44(a4)
    80004ad0:	a82d                	j	80004b0a <log_write+0xc8>
    panic("too big a transaction");
    80004ad2:	00004517          	auipc	a0,0x4
    80004ad6:	cce50513          	addi	a0,a0,-818 # 800087a0 <syscalls+0x218>
    80004ada:	ffffc097          	auipc	ra,0xffffc
    80004ade:	a66080e7          	jalr	-1434(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004ae2:	00004517          	auipc	a0,0x4
    80004ae6:	cd650513          	addi	a0,a0,-810 # 800087b8 <syscalls+0x230>
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	a56080e7          	jalr	-1450(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004af2:	00878693          	addi	a3,a5,8
    80004af6:	068a                	slli	a3,a3,0x2
    80004af8:	0003c717          	auipc	a4,0x3c
    80004afc:	1e070713          	addi	a4,a4,480 # 80040cd8 <log>
    80004b00:	9736                	add	a4,a4,a3
    80004b02:	44d4                	lw	a3,12(s1)
    80004b04:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b06:	faf609e3          	beq	a2,a5,80004ab8 <log_write+0x76>
  }
  release(&log.lock);
    80004b0a:	0003c517          	auipc	a0,0x3c
    80004b0e:	1ce50513          	addi	a0,a0,462 # 80040cd8 <log>
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	438080e7          	jalr	1080(ra) # 80000f4a <release>
}
    80004b1a:	60e2                	ld	ra,24(sp)
    80004b1c:	6442                	ld	s0,16(sp)
    80004b1e:	64a2                	ld	s1,8(sp)
    80004b20:	6902                	ld	s2,0(sp)
    80004b22:	6105                	addi	sp,sp,32
    80004b24:	8082                	ret

0000000080004b26 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b26:	1101                	addi	sp,sp,-32
    80004b28:	ec06                	sd	ra,24(sp)
    80004b2a:	e822                	sd	s0,16(sp)
    80004b2c:	e426                	sd	s1,8(sp)
    80004b2e:	e04a                	sd	s2,0(sp)
    80004b30:	1000                	addi	s0,sp,32
    80004b32:	84aa                	mv	s1,a0
    80004b34:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b36:	00004597          	auipc	a1,0x4
    80004b3a:	ca258593          	addi	a1,a1,-862 # 800087d8 <syscalls+0x250>
    80004b3e:	0521                	addi	a0,a0,8
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	2c6080e7          	jalr	710(ra) # 80000e06 <initlock>
  lk->name = name;
    80004b48:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b4c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b50:	0204a423          	sw	zero,40(s1)
}
    80004b54:	60e2                	ld	ra,24(sp)
    80004b56:	6442                	ld	s0,16(sp)
    80004b58:	64a2                	ld	s1,8(sp)
    80004b5a:	6902                	ld	s2,0(sp)
    80004b5c:	6105                	addi	sp,sp,32
    80004b5e:	8082                	ret

0000000080004b60 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b60:	1101                	addi	sp,sp,-32
    80004b62:	ec06                	sd	ra,24(sp)
    80004b64:	e822                	sd	s0,16(sp)
    80004b66:	e426                	sd	s1,8(sp)
    80004b68:	e04a                	sd	s2,0(sp)
    80004b6a:	1000                	addi	s0,sp,32
    80004b6c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b6e:	00850913          	addi	s2,a0,8
    80004b72:	854a                	mv	a0,s2
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	322080e7          	jalr	802(ra) # 80000e96 <acquire>
  while (lk->locked) {
    80004b7c:	409c                	lw	a5,0(s1)
    80004b7e:	cb89                	beqz	a5,80004b90 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b80:	85ca                	mv	a1,s2
    80004b82:	8526                	mv	a0,s1
    80004b84:	ffffe097          	auipc	ra,0xffffe
    80004b88:	9ec080e7          	jalr	-1556(ra) # 80002570 <sleep>
  while (lk->locked) {
    80004b8c:	409c                	lw	a5,0(s1)
    80004b8e:	fbed                	bnez	a5,80004b80 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b90:	4785                	li	a5,1
    80004b92:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b94:	ffffd097          	auipc	ra,0xffffd
    80004b98:	22e080e7          	jalr	558(ra) # 80001dc2 <myproc>
    80004b9c:	591c                	lw	a5,48(a0)
    80004b9e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ba0:	854a                	mv	a0,s2
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	3a8080e7          	jalr	936(ra) # 80000f4a <release>
}
    80004baa:	60e2                	ld	ra,24(sp)
    80004bac:	6442                	ld	s0,16(sp)
    80004bae:	64a2                	ld	s1,8(sp)
    80004bb0:	6902                	ld	s2,0(sp)
    80004bb2:	6105                	addi	sp,sp,32
    80004bb4:	8082                	ret

0000000080004bb6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bb6:	1101                	addi	sp,sp,-32
    80004bb8:	ec06                	sd	ra,24(sp)
    80004bba:	e822                	sd	s0,16(sp)
    80004bbc:	e426                	sd	s1,8(sp)
    80004bbe:	e04a                	sd	s2,0(sp)
    80004bc0:	1000                	addi	s0,sp,32
    80004bc2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bc4:	00850913          	addi	s2,a0,8
    80004bc8:	854a                	mv	a0,s2
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	2cc080e7          	jalr	716(ra) # 80000e96 <acquire>
  lk->locked = 0;
    80004bd2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bd6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004bda:	8526                	mv	a0,s1
    80004bdc:	ffffe097          	auipc	ra,0xffffe
    80004be0:	9f8080e7          	jalr	-1544(ra) # 800025d4 <wakeup>
  release(&lk->lk);
    80004be4:	854a                	mv	a0,s2
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	364080e7          	jalr	868(ra) # 80000f4a <release>
}
    80004bee:	60e2                	ld	ra,24(sp)
    80004bf0:	6442                	ld	s0,16(sp)
    80004bf2:	64a2                	ld	s1,8(sp)
    80004bf4:	6902                	ld	s2,0(sp)
    80004bf6:	6105                	addi	sp,sp,32
    80004bf8:	8082                	ret

0000000080004bfa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004bfa:	7179                	addi	sp,sp,-48
    80004bfc:	f406                	sd	ra,40(sp)
    80004bfe:	f022                	sd	s0,32(sp)
    80004c00:	ec26                	sd	s1,24(sp)
    80004c02:	e84a                	sd	s2,16(sp)
    80004c04:	e44e                	sd	s3,8(sp)
    80004c06:	1800                	addi	s0,sp,48
    80004c08:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c0a:	00850913          	addi	s2,a0,8
    80004c0e:	854a                	mv	a0,s2
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	286080e7          	jalr	646(ra) # 80000e96 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c18:	409c                	lw	a5,0(s1)
    80004c1a:	ef99                	bnez	a5,80004c38 <holdingsleep+0x3e>
    80004c1c:	4481                	li	s1,0
  release(&lk->lk);
    80004c1e:	854a                	mv	a0,s2
    80004c20:	ffffc097          	auipc	ra,0xffffc
    80004c24:	32a080e7          	jalr	810(ra) # 80000f4a <release>
  return r;
}
    80004c28:	8526                	mv	a0,s1
    80004c2a:	70a2                	ld	ra,40(sp)
    80004c2c:	7402                	ld	s0,32(sp)
    80004c2e:	64e2                	ld	s1,24(sp)
    80004c30:	6942                	ld	s2,16(sp)
    80004c32:	69a2                	ld	s3,8(sp)
    80004c34:	6145                	addi	sp,sp,48
    80004c36:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c38:	0284a983          	lw	s3,40(s1)
    80004c3c:	ffffd097          	auipc	ra,0xffffd
    80004c40:	186080e7          	jalr	390(ra) # 80001dc2 <myproc>
    80004c44:	5904                	lw	s1,48(a0)
    80004c46:	413484b3          	sub	s1,s1,s3
    80004c4a:	0014b493          	seqz	s1,s1
    80004c4e:	bfc1                	j	80004c1e <holdingsleep+0x24>

0000000080004c50 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c50:	1141                	addi	sp,sp,-16
    80004c52:	e406                	sd	ra,8(sp)
    80004c54:	e022                	sd	s0,0(sp)
    80004c56:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c58:	00004597          	auipc	a1,0x4
    80004c5c:	b9058593          	addi	a1,a1,-1136 # 800087e8 <syscalls+0x260>
    80004c60:	0003c517          	auipc	a0,0x3c
    80004c64:	1c050513          	addi	a0,a0,448 # 80040e20 <ftable>
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	19e080e7          	jalr	414(ra) # 80000e06 <initlock>
}
    80004c70:	60a2                	ld	ra,8(sp)
    80004c72:	6402                	ld	s0,0(sp)
    80004c74:	0141                	addi	sp,sp,16
    80004c76:	8082                	ret

0000000080004c78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c78:	1101                	addi	sp,sp,-32
    80004c7a:	ec06                	sd	ra,24(sp)
    80004c7c:	e822                	sd	s0,16(sp)
    80004c7e:	e426                	sd	s1,8(sp)
    80004c80:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c82:	0003c517          	auipc	a0,0x3c
    80004c86:	19e50513          	addi	a0,a0,414 # 80040e20 <ftable>
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	20c080e7          	jalr	524(ra) # 80000e96 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c92:	0003c497          	auipc	s1,0x3c
    80004c96:	1a648493          	addi	s1,s1,422 # 80040e38 <ftable+0x18>
    80004c9a:	0003d717          	auipc	a4,0x3d
    80004c9e:	13e70713          	addi	a4,a4,318 # 80041dd8 <disk>
    if(f->ref == 0){
    80004ca2:	40dc                	lw	a5,4(s1)
    80004ca4:	cf99                	beqz	a5,80004cc2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ca6:	02848493          	addi	s1,s1,40
    80004caa:	fee49ce3          	bne	s1,a4,80004ca2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cae:	0003c517          	auipc	a0,0x3c
    80004cb2:	17250513          	addi	a0,a0,370 # 80040e20 <ftable>
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	294080e7          	jalr	660(ra) # 80000f4a <release>
  return 0;
    80004cbe:	4481                	li	s1,0
    80004cc0:	a819                	j	80004cd6 <filealloc+0x5e>
      f->ref = 1;
    80004cc2:	4785                	li	a5,1
    80004cc4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cc6:	0003c517          	auipc	a0,0x3c
    80004cca:	15a50513          	addi	a0,a0,346 # 80040e20 <ftable>
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	27c080e7          	jalr	636(ra) # 80000f4a <release>
}
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	60e2                	ld	ra,24(sp)
    80004cda:	6442                	ld	s0,16(sp)
    80004cdc:	64a2                	ld	s1,8(sp)
    80004cde:	6105                	addi	sp,sp,32
    80004ce0:	8082                	ret

0000000080004ce2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ce2:	1101                	addi	sp,sp,-32
    80004ce4:	ec06                	sd	ra,24(sp)
    80004ce6:	e822                	sd	s0,16(sp)
    80004ce8:	e426                	sd	s1,8(sp)
    80004cea:	1000                	addi	s0,sp,32
    80004cec:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004cee:	0003c517          	auipc	a0,0x3c
    80004cf2:	13250513          	addi	a0,a0,306 # 80040e20 <ftable>
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	1a0080e7          	jalr	416(ra) # 80000e96 <acquire>
  if(f->ref < 1)
    80004cfe:	40dc                	lw	a5,4(s1)
    80004d00:	02f05263          	blez	a5,80004d24 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d04:	2785                	addiw	a5,a5,1
    80004d06:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d08:	0003c517          	auipc	a0,0x3c
    80004d0c:	11850513          	addi	a0,a0,280 # 80040e20 <ftable>
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	23a080e7          	jalr	570(ra) # 80000f4a <release>
  return f;
}
    80004d18:	8526                	mv	a0,s1
    80004d1a:	60e2                	ld	ra,24(sp)
    80004d1c:	6442                	ld	s0,16(sp)
    80004d1e:	64a2                	ld	s1,8(sp)
    80004d20:	6105                	addi	sp,sp,32
    80004d22:	8082                	ret
    panic("filedup");
    80004d24:	00004517          	auipc	a0,0x4
    80004d28:	acc50513          	addi	a0,a0,-1332 # 800087f0 <syscalls+0x268>
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	814080e7          	jalr	-2028(ra) # 80000540 <panic>

0000000080004d34 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d34:	7139                	addi	sp,sp,-64
    80004d36:	fc06                	sd	ra,56(sp)
    80004d38:	f822                	sd	s0,48(sp)
    80004d3a:	f426                	sd	s1,40(sp)
    80004d3c:	f04a                	sd	s2,32(sp)
    80004d3e:	ec4e                	sd	s3,24(sp)
    80004d40:	e852                	sd	s4,16(sp)
    80004d42:	e456                	sd	s5,8(sp)
    80004d44:	0080                	addi	s0,sp,64
    80004d46:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d48:	0003c517          	auipc	a0,0x3c
    80004d4c:	0d850513          	addi	a0,a0,216 # 80040e20 <ftable>
    80004d50:	ffffc097          	auipc	ra,0xffffc
    80004d54:	146080e7          	jalr	326(ra) # 80000e96 <acquire>
  if(f->ref < 1)
    80004d58:	40dc                	lw	a5,4(s1)
    80004d5a:	06f05163          	blez	a5,80004dbc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004d5e:	37fd                	addiw	a5,a5,-1
    80004d60:	0007871b          	sext.w	a4,a5
    80004d64:	c0dc                	sw	a5,4(s1)
    80004d66:	06e04363          	bgtz	a4,80004dcc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d6a:	0004a903          	lw	s2,0(s1)
    80004d6e:	0094ca83          	lbu	s5,9(s1)
    80004d72:	0104ba03          	ld	s4,16(s1)
    80004d76:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d7a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d7e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d82:	0003c517          	auipc	a0,0x3c
    80004d86:	09e50513          	addi	a0,a0,158 # 80040e20 <ftable>
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	1c0080e7          	jalr	448(ra) # 80000f4a <release>

  if(ff.type == FD_PIPE){
    80004d92:	4785                	li	a5,1
    80004d94:	04f90d63          	beq	s2,a5,80004dee <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d98:	3979                	addiw	s2,s2,-2
    80004d9a:	4785                	li	a5,1
    80004d9c:	0527e063          	bltu	a5,s2,80004ddc <fileclose+0xa8>
    begin_op();
    80004da0:	00000097          	auipc	ra,0x0
    80004da4:	acc080e7          	jalr	-1332(ra) # 8000486c <begin_op>
    iput(ff.ip);
    80004da8:	854e                	mv	a0,s3
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	2b0080e7          	jalr	688(ra) # 8000405a <iput>
    end_op();
    80004db2:	00000097          	auipc	ra,0x0
    80004db6:	b38080e7          	jalr	-1224(ra) # 800048ea <end_op>
    80004dba:	a00d                	j	80004ddc <fileclose+0xa8>
    panic("fileclose");
    80004dbc:	00004517          	auipc	a0,0x4
    80004dc0:	a3c50513          	addi	a0,a0,-1476 # 800087f8 <syscalls+0x270>
    80004dc4:	ffffb097          	auipc	ra,0xffffb
    80004dc8:	77c080e7          	jalr	1916(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004dcc:	0003c517          	auipc	a0,0x3c
    80004dd0:	05450513          	addi	a0,a0,84 # 80040e20 <ftable>
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	176080e7          	jalr	374(ra) # 80000f4a <release>
  }
}
    80004ddc:	70e2                	ld	ra,56(sp)
    80004dde:	7442                	ld	s0,48(sp)
    80004de0:	74a2                	ld	s1,40(sp)
    80004de2:	7902                	ld	s2,32(sp)
    80004de4:	69e2                	ld	s3,24(sp)
    80004de6:	6a42                	ld	s4,16(sp)
    80004de8:	6aa2                	ld	s5,8(sp)
    80004dea:	6121                	addi	sp,sp,64
    80004dec:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004dee:	85d6                	mv	a1,s5
    80004df0:	8552                	mv	a0,s4
    80004df2:	00000097          	auipc	ra,0x0
    80004df6:	34c080e7          	jalr	844(ra) # 8000513e <pipeclose>
    80004dfa:	b7cd                	j	80004ddc <fileclose+0xa8>

0000000080004dfc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004dfc:	715d                	addi	sp,sp,-80
    80004dfe:	e486                	sd	ra,72(sp)
    80004e00:	e0a2                	sd	s0,64(sp)
    80004e02:	fc26                	sd	s1,56(sp)
    80004e04:	f84a                	sd	s2,48(sp)
    80004e06:	f44e                	sd	s3,40(sp)
    80004e08:	0880                	addi	s0,sp,80
    80004e0a:	84aa                	mv	s1,a0
    80004e0c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e0e:	ffffd097          	auipc	ra,0xffffd
    80004e12:	fb4080e7          	jalr	-76(ra) # 80001dc2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e16:	409c                	lw	a5,0(s1)
    80004e18:	37f9                	addiw	a5,a5,-2
    80004e1a:	4705                	li	a4,1
    80004e1c:	04f76763          	bltu	a4,a5,80004e6a <filestat+0x6e>
    80004e20:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e22:	6c88                	ld	a0,24(s1)
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	07c080e7          	jalr	124(ra) # 80003ea0 <ilock>
    stati(f->ip, &st);
    80004e2c:	fb840593          	addi	a1,s0,-72
    80004e30:	6c88                	ld	a0,24(s1)
    80004e32:	fffff097          	auipc	ra,0xfffff
    80004e36:	2f8080e7          	jalr	760(ra) # 8000412a <stati>
    iunlock(f->ip);
    80004e3a:	6c88                	ld	a0,24(s1)
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	126080e7          	jalr	294(ra) # 80003f62 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e44:	46e1                	li	a3,24
    80004e46:	fb840613          	addi	a2,s0,-72
    80004e4a:	85ce                	mv	a1,s3
    80004e4c:	05093503          	ld	a0,80(s2)
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	ad8080e7          	jalr	-1320(ra) # 80001928 <copyout>
    80004e58:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e5c:	60a6                	ld	ra,72(sp)
    80004e5e:	6406                	ld	s0,64(sp)
    80004e60:	74e2                	ld	s1,56(sp)
    80004e62:	7942                	ld	s2,48(sp)
    80004e64:	79a2                	ld	s3,40(sp)
    80004e66:	6161                	addi	sp,sp,80
    80004e68:	8082                	ret
  return -1;
    80004e6a:	557d                	li	a0,-1
    80004e6c:	bfc5                	j	80004e5c <filestat+0x60>

0000000080004e6e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e6e:	7179                	addi	sp,sp,-48
    80004e70:	f406                	sd	ra,40(sp)
    80004e72:	f022                	sd	s0,32(sp)
    80004e74:	ec26                	sd	s1,24(sp)
    80004e76:	e84a                	sd	s2,16(sp)
    80004e78:	e44e                	sd	s3,8(sp)
    80004e7a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e7c:	00854783          	lbu	a5,8(a0)
    80004e80:	c3d5                	beqz	a5,80004f24 <fileread+0xb6>
    80004e82:	84aa                	mv	s1,a0
    80004e84:	89ae                	mv	s3,a1
    80004e86:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e88:	411c                	lw	a5,0(a0)
    80004e8a:	4705                	li	a4,1
    80004e8c:	04e78963          	beq	a5,a4,80004ede <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e90:	470d                	li	a4,3
    80004e92:	04e78d63          	beq	a5,a4,80004eec <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e96:	4709                	li	a4,2
    80004e98:	06e79e63          	bne	a5,a4,80004f14 <fileread+0xa6>
    ilock(f->ip);
    80004e9c:	6d08                	ld	a0,24(a0)
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	002080e7          	jalr	2(ra) # 80003ea0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ea6:	874a                	mv	a4,s2
    80004ea8:	5094                	lw	a3,32(s1)
    80004eaa:	864e                	mv	a2,s3
    80004eac:	4585                	li	a1,1
    80004eae:	6c88                	ld	a0,24(s1)
    80004eb0:	fffff097          	auipc	ra,0xfffff
    80004eb4:	2a4080e7          	jalr	676(ra) # 80004154 <readi>
    80004eb8:	892a                	mv	s2,a0
    80004eba:	00a05563          	blez	a0,80004ec4 <fileread+0x56>
      f->off += r;
    80004ebe:	509c                	lw	a5,32(s1)
    80004ec0:	9fa9                	addw	a5,a5,a0
    80004ec2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ec4:	6c88                	ld	a0,24(s1)
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	09c080e7          	jalr	156(ra) # 80003f62 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ece:	854a                	mv	a0,s2
    80004ed0:	70a2                	ld	ra,40(sp)
    80004ed2:	7402                	ld	s0,32(sp)
    80004ed4:	64e2                	ld	s1,24(sp)
    80004ed6:	6942                	ld	s2,16(sp)
    80004ed8:	69a2                	ld	s3,8(sp)
    80004eda:	6145                	addi	sp,sp,48
    80004edc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ede:	6908                	ld	a0,16(a0)
    80004ee0:	00000097          	auipc	ra,0x0
    80004ee4:	3c6080e7          	jalr	966(ra) # 800052a6 <piperead>
    80004ee8:	892a                	mv	s2,a0
    80004eea:	b7d5                	j	80004ece <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004eec:	02451783          	lh	a5,36(a0)
    80004ef0:	03079693          	slli	a3,a5,0x30
    80004ef4:	92c1                	srli	a3,a3,0x30
    80004ef6:	4725                	li	a4,9
    80004ef8:	02d76863          	bltu	a4,a3,80004f28 <fileread+0xba>
    80004efc:	0792                	slli	a5,a5,0x4
    80004efe:	0003c717          	auipc	a4,0x3c
    80004f02:	e8270713          	addi	a4,a4,-382 # 80040d80 <devsw>
    80004f06:	97ba                	add	a5,a5,a4
    80004f08:	639c                	ld	a5,0(a5)
    80004f0a:	c38d                	beqz	a5,80004f2c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f0c:	4505                	li	a0,1
    80004f0e:	9782                	jalr	a5
    80004f10:	892a                	mv	s2,a0
    80004f12:	bf75                	j	80004ece <fileread+0x60>
    panic("fileread");
    80004f14:	00004517          	auipc	a0,0x4
    80004f18:	8f450513          	addi	a0,a0,-1804 # 80008808 <syscalls+0x280>
    80004f1c:	ffffb097          	auipc	ra,0xffffb
    80004f20:	624080e7          	jalr	1572(ra) # 80000540 <panic>
    return -1;
    80004f24:	597d                	li	s2,-1
    80004f26:	b765                	j	80004ece <fileread+0x60>
      return -1;
    80004f28:	597d                	li	s2,-1
    80004f2a:	b755                	j	80004ece <fileread+0x60>
    80004f2c:	597d                	li	s2,-1
    80004f2e:	b745                	j	80004ece <fileread+0x60>

0000000080004f30 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004f30:	715d                	addi	sp,sp,-80
    80004f32:	e486                	sd	ra,72(sp)
    80004f34:	e0a2                	sd	s0,64(sp)
    80004f36:	fc26                	sd	s1,56(sp)
    80004f38:	f84a                	sd	s2,48(sp)
    80004f3a:	f44e                	sd	s3,40(sp)
    80004f3c:	f052                	sd	s4,32(sp)
    80004f3e:	ec56                	sd	s5,24(sp)
    80004f40:	e85a                	sd	s6,16(sp)
    80004f42:	e45e                	sd	s7,8(sp)
    80004f44:	e062                	sd	s8,0(sp)
    80004f46:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f48:	00954783          	lbu	a5,9(a0)
    80004f4c:	10078663          	beqz	a5,80005058 <filewrite+0x128>
    80004f50:	892a                	mv	s2,a0
    80004f52:	8b2e                	mv	s6,a1
    80004f54:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f56:	411c                	lw	a5,0(a0)
    80004f58:	4705                	li	a4,1
    80004f5a:	02e78263          	beq	a5,a4,80004f7e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f5e:	470d                	li	a4,3
    80004f60:	02e78663          	beq	a5,a4,80004f8c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f64:	4709                	li	a4,2
    80004f66:	0ee79163          	bne	a5,a4,80005048 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f6a:	0ac05d63          	blez	a2,80005024 <filewrite+0xf4>
    int i = 0;
    80004f6e:	4981                	li	s3,0
    80004f70:	6b85                	lui	s7,0x1
    80004f72:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004f76:	6c05                	lui	s8,0x1
    80004f78:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004f7c:	a861                	j	80005014 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f7e:	6908                	ld	a0,16(a0)
    80004f80:	00000097          	auipc	ra,0x0
    80004f84:	22e080e7          	jalr	558(ra) # 800051ae <pipewrite>
    80004f88:	8a2a                	mv	s4,a0
    80004f8a:	a045                	j	8000502a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f8c:	02451783          	lh	a5,36(a0)
    80004f90:	03079693          	slli	a3,a5,0x30
    80004f94:	92c1                	srli	a3,a3,0x30
    80004f96:	4725                	li	a4,9
    80004f98:	0cd76263          	bltu	a4,a3,8000505c <filewrite+0x12c>
    80004f9c:	0792                	slli	a5,a5,0x4
    80004f9e:	0003c717          	auipc	a4,0x3c
    80004fa2:	de270713          	addi	a4,a4,-542 # 80040d80 <devsw>
    80004fa6:	97ba                	add	a5,a5,a4
    80004fa8:	679c                	ld	a5,8(a5)
    80004faa:	cbdd                	beqz	a5,80005060 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004fac:	4505                	li	a0,1
    80004fae:	9782                	jalr	a5
    80004fb0:	8a2a                	mv	s4,a0
    80004fb2:	a8a5                	j	8000502a <filewrite+0xfa>
    80004fb4:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fb8:	00000097          	auipc	ra,0x0
    80004fbc:	8b4080e7          	jalr	-1868(ra) # 8000486c <begin_op>
      ilock(f->ip);
    80004fc0:	01893503          	ld	a0,24(s2)
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	edc080e7          	jalr	-292(ra) # 80003ea0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fcc:	8756                	mv	a4,s5
    80004fce:	02092683          	lw	a3,32(s2)
    80004fd2:	01698633          	add	a2,s3,s6
    80004fd6:	4585                	li	a1,1
    80004fd8:	01893503          	ld	a0,24(s2)
    80004fdc:	fffff097          	auipc	ra,0xfffff
    80004fe0:	270080e7          	jalr	624(ra) # 8000424c <writei>
    80004fe4:	84aa                	mv	s1,a0
    80004fe6:	00a05763          	blez	a0,80004ff4 <filewrite+0xc4>
        f->off += r;
    80004fea:	02092783          	lw	a5,32(s2)
    80004fee:	9fa9                	addw	a5,a5,a0
    80004ff0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ff4:	01893503          	ld	a0,24(s2)
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	f6a080e7          	jalr	-150(ra) # 80003f62 <iunlock>
      end_op();
    80005000:	00000097          	auipc	ra,0x0
    80005004:	8ea080e7          	jalr	-1814(ra) # 800048ea <end_op>

      if(r != n1){
    80005008:	009a9f63          	bne	s5,s1,80005026 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000500c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005010:	0149db63          	bge	s3,s4,80005026 <filewrite+0xf6>
      int n1 = n - i;
    80005014:	413a04bb          	subw	s1,s4,s3
    80005018:	0004879b          	sext.w	a5,s1
    8000501c:	f8fbdce3          	bge	s7,a5,80004fb4 <filewrite+0x84>
    80005020:	84e2                	mv	s1,s8
    80005022:	bf49                	j	80004fb4 <filewrite+0x84>
    int i = 0;
    80005024:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005026:	013a1f63          	bne	s4,s3,80005044 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000502a:	8552                	mv	a0,s4
    8000502c:	60a6                	ld	ra,72(sp)
    8000502e:	6406                	ld	s0,64(sp)
    80005030:	74e2                	ld	s1,56(sp)
    80005032:	7942                	ld	s2,48(sp)
    80005034:	79a2                	ld	s3,40(sp)
    80005036:	7a02                	ld	s4,32(sp)
    80005038:	6ae2                	ld	s5,24(sp)
    8000503a:	6b42                	ld	s6,16(sp)
    8000503c:	6ba2                	ld	s7,8(sp)
    8000503e:	6c02                	ld	s8,0(sp)
    80005040:	6161                	addi	sp,sp,80
    80005042:	8082                	ret
    ret = (i == n ? n : -1);
    80005044:	5a7d                	li	s4,-1
    80005046:	b7d5                	j	8000502a <filewrite+0xfa>
    panic("filewrite");
    80005048:	00003517          	auipc	a0,0x3
    8000504c:	7d050513          	addi	a0,a0,2000 # 80008818 <syscalls+0x290>
    80005050:	ffffb097          	auipc	ra,0xffffb
    80005054:	4f0080e7          	jalr	1264(ra) # 80000540 <panic>
    return -1;
    80005058:	5a7d                	li	s4,-1
    8000505a:	bfc1                	j	8000502a <filewrite+0xfa>
      return -1;
    8000505c:	5a7d                	li	s4,-1
    8000505e:	b7f1                	j	8000502a <filewrite+0xfa>
    80005060:	5a7d                	li	s4,-1
    80005062:	b7e1                	j	8000502a <filewrite+0xfa>

0000000080005064 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005064:	7179                	addi	sp,sp,-48
    80005066:	f406                	sd	ra,40(sp)
    80005068:	f022                	sd	s0,32(sp)
    8000506a:	ec26                	sd	s1,24(sp)
    8000506c:	e84a                	sd	s2,16(sp)
    8000506e:	e44e                	sd	s3,8(sp)
    80005070:	e052                	sd	s4,0(sp)
    80005072:	1800                	addi	s0,sp,48
    80005074:	84aa                	mv	s1,a0
    80005076:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005078:	0005b023          	sd	zero,0(a1)
    8000507c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005080:	00000097          	auipc	ra,0x0
    80005084:	bf8080e7          	jalr	-1032(ra) # 80004c78 <filealloc>
    80005088:	e088                	sd	a0,0(s1)
    8000508a:	c551                	beqz	a0,80005116 <pipealloc+0xb2>
    8000508c:	00000097          	auipc	ra,0x0
    80005090:	bec080e7          	jalr	-1044(ra) # 80004c78 <filealloc>
    80005094:	00aa3023          	sd	a0,0(s4)
    80005098:	c92d                	beqz	a0,8000510a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	c72080e7          	jalr	-910(ra) # 80000d0c <kalloc>
    800050a2:	892a                	mv	s2,a0
    800050a4:	c125                	beqz	a0,80005104 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050a6:	4985                	li	s3,1
    800050a8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050ac:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050b0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050b4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050b8:	00003597          	auipc	a1,0x3
    800050bc:	77058593          	addi	a1,a1,1904 # 80008828 <syscalls+0x2a0>
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	d46080e7          	jalr	-698(ra) # 80000e06 <initlock>
  (*f0)->type = FD_PIPE;
    800050c8:	609c                	ld	a5,0(s1)
    800050ca:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050ce:	609c                	ld	a5,0(s1)
    800050d0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050d4:	609c                	ld	a5,0(s1)
    800050d6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050da:	609c                	ld	a5,0(s1)
    800050dc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050e0:	000a3783          	ld	a5,0(s4)
    800050e4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050e8:	000a3783          	ld	a5,0(s4)
    800050ec:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050f0:	000a3783          	ld	a5,0(s4)
    800050f4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800050f8:	000a3783          	ld	a5,0(s4)
    800050fc:	0127b823          	sd	s2,16(a5)
  return 0;
    80005100:	4501                	li	a0,0
    80005102:	a025                	j	8000512a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005104:	6088                	ld	a0,0(s1)
    80005106:	e501                	bnez	a0,8000510e <pipealloc+0xaa>
    80005108:	a039                	j	80005116 <pipealloc+0xb2>
    8000510a:	6088                	ld	a0,0(s1)
    8000510c:	c51d                	beqz	a0,8000513a <pipealloc+0xd6>
    fileclose(*f0);
    8000510e:	00000097          	auipc	ra,0x0
    80005112:	c26080e7          	jalr	-986(ra) # 80004d34 <fileclose>
  if(*f1)
    80005116:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000511a:	557d                	li	a0,-1
  if(*f1)
    8000511c:	c799                	beqz	a5,8000512a <pipealloc+0xc6>
    fileclose(*f1);
    8000511e:	853e                	mv	a0,a5
    80005120:	00000097          	auipc	ra,0x0
    80005124:	c14080e7          	jalr	-1004(ra) # 80004d34 <fileclose>
  return -1;
    80005128:	557d                	li	a0,-1
}
    8000512a:	70a2                	ld	ra,40(sp)
    8000512c:	7402                	ld	s0,32(sp)
    8000512e:	64e2                	ld	s1,24(sp)
    80005130:	6942                	ld	s2,16(sp)
    80005132:	69a2                	ld	s3,8(sp)
    80005134:	6a02                	ld	s4,0(sp)
    80005136:	6145                	addi	sp,sp,48
    80005138:	8082                	ret
  return -1;
    8000513a:	557d                	li	a0,-1
    8000513c:	b7fd                	j	8000512a <pipealloc+0xc6>

000000008000513e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000513e:	1101                	addi	sp,sp,-32
    80005140:	ec06                	sd	ra,24(sp)
    80005142:	e822                	sd	s0,16(sp)
    80005144:	e426                	sd	s1,8(sp)
    80005146:	e04a                	sd	s2,0(sp)
    80005148:	1000                	addi	s0,sp,32
    8000514a:	84aa                	mv	s1,a0
    8000514c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	d48080e7          	jalr	-696(ra) # 80000e96 <acquire>
  if(writable){
    80005156:	02090d63          	beqz	s2,80005190 <pipeclose+0x52>
    pi->writeopen = 0;
    8000515a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000515e:	21848513          	addi	a0,s1,536
    80005162:	ffffd097          	auipc	ra,0xffffd
    80005166:	472080e7          	jalr	1138(ra) # 800025d4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000516a:	2204b783          	ld	a5,544(s1)
    8000516e:	eb95                	bnez	a5,800051a2 <pipeclose+0x64>
    release(&pi->lock);
    80005170:	8526                	mv	a0,s1
    80005172:	ffffc097          	auipc	ra,0xffffc
    80005176:	dd8080e7          	jalr	-552(ra) # 80000f4a <release>
    kfree((char*)pi);
    8000517a:	8526                	mv	a0,s1
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	99e080e7          	jalr	-1634(ra) # 80000b1a <kfree>
  } else
    release(&pi->lock);
}
    80005184:	60e2                	ld	ra,24(sp)
    80005186:	6442                	ld	s0,16(sp)
    80005188:	64a2                	ld	s1,8(sp)
    8000518a:	6902                	ld	s2,0(sp)
    8000518c:	6105                	addi	sp,sp,32
    8000518e:	8082                	ret
    pi->readopen = 0;
    80005190:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005194:	21c48513          	addi	a0,s1,540
    80005198:	ffffd097          	auipc	ra,0xffffd
    8000519c:	43c080e7          	jalr	1084(ra) # 800025d4 <wakeup>
    800051a0:	b7e9                	j	8000516a <pipeclose+0x2c>
    release(&pi->lock);
    800051a2:	8526                	mv	a0,s1
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	da6080e7          	jalr	-602(ra) # 80000f4a <release>
}
    800051ac:	bfe1                	j	80005184 <pipeclose+0x46>

00000000800051ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051ae:	711d                	addi	sp,sp,-96
    800051b0:	ec86                	sd	ra,88(sp)
    800051b2:	e8a2                	sd	s0,80(sp)
    800051b4:	e4a6                	sd	s1,72(sp)
    800051b6:	e0ca                	sd	s2,64(sp)
    800051b8:	fc4e                	sd	s3,56(sp)
    800051ba:	f852                	sd	s4,48(sp)
    800051bc:	f456                	sd	s5,40(sp)
    800051be:	f05a                	sd	s6,32(sp)
    800051c0:	ec5e                	sd	s7,24(sp)
    800051c2:	e862                	sd	s8,16(sp)
    800051c4:	1080                	addi	s0,sp,96
    800051c6:	84aa                	mv	s1,a0
    800051c8:	8aae                	mv	s5,a1
    800051ca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051cc:	ffffd097          	auipc	ra,0xffffd
    800051d0:	bf6080e7          	jalr	-1034(ra) # 80001dc2 <myproc>
    800051d4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051d6:	8526                	mv	a0,s1
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	cbe080e7          	jalr	-834(ra) # 80000e96 <acquire>
  while(i < n){
    800051e0:	0b405663          	blez	s4,8000528c <pipewrite+0xde>
  int i = 0;
    800051e4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051e6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800051e8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800051ec:	21c48b93          	addi	s7,s1,540
    800051f0:	a089                	j	80005232 <pipewrite+0x84>
      release(&pi->lock);
    800051f2:	8526                	mv	a0,s1
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	d56080e7          	jalr	-682(ra) # 80000f4a <release>
      return -1;
    800051fc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800051fe:	854a                	mv	a0,s2
    80005200:	60e6                	ld	ra,88(sp)
    80005202:	6446                	ld	s0,80(sp)
    80005204:	64a6                	ld	s1,72(sp)
    80005206:	6906                	ld	s2,64(sp)
    80005208:	79e2                	ld	s3,56(sp)
    8000520a:	7a42                	ld	s4,48(sp)
    8000520c:	7aa2                	ld	s5,40(sp)
    8000520e:	7b02                	ld	s6,32(sp)
    80005210:	6be2                	ld	s7,24(sp)
    80005212:	6c42                	ld	s8,16(sp)
    80005214:	6125                	addi	sp,sp,96
    80005216:	8082                	ret
      wakeup(&pi->nread);
    80005218:	8562                	mv	a0,s8
    8000521a:	ffffd097          	auipc	ra,0xffffd
    8000521e:	3ba080e7          	jalr	954(ra) # 800025d4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005222:	85a6                	mv	a1,s1
    80005224:	855e                	mv	a0,s7
    80005226:	ffffd097          	auipc	ra,0xffffd
    8000522a:	34a080e7          	jalr	842(ra) # 80002570 <sleep>
  while(i < n){
    8000522e:	07495063          	bge	s2,s4,8000528e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005232:	2204a783          	lw	a5,544(s1)
    80005236:	dfd5                	beqz	a5,800051f2 <pipewrite+0x44>
    80005238:	854e                	mv	a0,s3
    8000523a:	ffffd097          	auipc	ra,0xffffd
    8000523e:	5de080e7          	jalr	1502(ra) # 80002818 <killed>
    80005242:	f945                	bnez	a0,800051f2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005244:	2184a783          	lw	a5,536(s1)
    80005248:	21c4a703          	lw	a4,540(s1)
    8000524c:	2007879b          	addiw	a5,a5,512
    80005250:	fcf704e3          	beq	a4,a5,80005218 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005254:	4685                	li	a3,1
    80005256:	01590633          	add	a2,s2,s5
    8000525a:	faf40593          	addi	a1,s0,-81
    8000525e:	0509b503          	ld	a0,80(s3)
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	752080e7          	jalr	1874(ra) # 800019b4 <copyin>
    8000526a:	03650263          	beq	a0,s6,8000528e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000526e:	21c4a783          	lw	a5,540(s1)
    80005272:	0017871b          	addiw	a4,a5,1
    80005276:	20e4ae23          	sw	a4,540(s1)
    8000527a:	1ff7f793          	andi	a5,a5,511
    8000527e:	97a6                	add	a5,a5,s1
    80005280:	faf44703          	lbu	a4,-81(s0)
    80005284:	00e78c23          	sb	a4,24(a5)
      i++;
    80005288:	2905                	addiw	s2,s2,1
    8000528a:	b755                	j	8000522e <pipewrite+0x80>
  int i = 0;
    8000528c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000528e:	21848513          	addi	a0,s1,536
    80005292:	ffffd097          	auipc	ra,0xffffd
    80005296:	342080e7          	jalr	834(ra) # 800025d4 <wakeup>
  release(&pi->lock);
    8000529a:	8526                	mv	a0,s1
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	cae080e7          	jalr	-850(ra) # 80000f4a <release>
  return i;
    800052a4:	bfa9                	j	800051fe <pipewrite+0x50>

00000000800052a6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052a6:	715d                	addi	sp,sp,-80
    800052a8:	e486                	sd	ra,72(sp)
    800052aa:	e0a2                	sd	s0,64(sp)
    800052ac:	fc26                	sd	s1,56(sp)
    800052ae:	f84a                	sd	s2,48(sp)
    800052b0:	f44e                	sd	s3,40(sp)
    800052b2:	f052                	sd	s4,32(sp)
    800052b4:	ec56                	sd	s5,24(sp)
    800052b6:	e85a                	sd	s6,16(sp)
    800052b8:	0880                	addi	s0,sp,80
    800052ba:	84aa                	mv	s1,a0
    800052bc:	892e                	mv	s2,a1
    800052be:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052c0:	ffffd097          	auipc	ra,0xffffd
    800052c4:	b02080e7          	jalr	-1278(ra) # 80001dc2 <myproc>
    800052c8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052ca:	8526                	mv	a0,s1
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	bca080e7          	jalr	-1078(ra) # 80000e96 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052d4:	2184a703          	lw	a4,536(s1)
    800052d8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052dc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052e0:	02f71763          	bne	a4,a5,8000530e <piperead+0x68>
    800052e4:	2244a783          	lw	a5,548(s1)
    800052e8:	c39d                	beqz	a5,8000530e <piperead+0x68>
    if(killed(pr)){
    800052ea:	8552                	mv	a0,s4
    800052ec:	ffffd097          	auipc	ra,0xffffd
    800052f0:	52c080e7          	jalr	1324(ra) # 80002818 <killed>
    800052f4:	e949                	bnez	a0,80005386 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052f6:	85a6                	mv	a1,s1
    800052f8:	854e                	mv	a0,s3
    800052fa:	ffffd097          	auipc	ra,0xffffd
    800052fe:	276080e7          	jalr	630(ra) # 80002570 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005302:	2184a703          	lw	a4,536(s1)
    80005306:	21c4a783          	lw	a5,540(s1)
    8000530a:	fcf70de3          	beq	a4,a5,800052e4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000530e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005310:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005312:	05505463          	blez	s5,8000535a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005316:	2184a783          	lw	a5,536(s1)
    8000531a:	21c4a703          	lw	a4,540(s1)
    8000531e:	02f70e63          	beq	a4,a5,8000535a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005322:	0017871b          	addiw	a4,a5,1
    80005326:	20e4ac23          	sw	a4,536(s1)
    8000532a:	1ff7f793          	andi	a5,a5,511
    8000532e:	97a6                	add	a5,a5,s1
    80005330:	0187c783          	lbu	a5,24(a5)
    80005334:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005338:	4685                	li	a3,1
    8000533a:	fbf40613          	addi	a2,s0,-65
    8000533e:	85ca                	mv	a1,s2
    80005340:	050a3503          	ld	a0,80(s4)
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	5e4080e7          	jalr	1508(ra) # 80001928 <copyout>
    8000534c:	01650763          	beq	a0,s6,8000535a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005350:	2985                	addiw	s3,s3,1
    80005352:	0905                	addi	s2,s2,1
    80005354:	fd3a91e3          	bne	s5,s3,80005316 <piperead+0x70>
    80005358:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000535a:	21c48513          	addi	a0,s1,540
    8000535e:	ffffd097          	auipc	ra,0xffffd
    80005362:	276080e7          	jalr	630(ra) # 800025d4 <wakeup>
  release(&pi->lock);
    80005366:	8526                	mv	a0,s1
    80005368:	ffffc097          	auipc	ra,0xffffc
    8000536c:	be2080e7          	jalr	-1054(ra) # 80000f4a <release>
  return i;
}
    80005370:	854e                	mv	a0,s3
    80005372:	60a6                	ld	ra,72(sp)
    80005374:	6406                	ld	s0,64(sp)
    80005376:	74e2                	ld	s1,56(sp)
    80005378:	7942                	ld	s2,48(sp)
    8000537a:	79a2                	ld	s3,40(sp)
    8000537c:	7a02                	ld	s4,32(sp)
    8000537e:	6ae2                	ld	s5,24(sp)
    80005380:	6b42                	ld	s6,16(sp)
    80005382:	6161                	addi	sp,sp,80
    80005384:	8082                	ret
      release(&pi->lock);
    80005386:	8526                	mv	a0,s1
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	bc2080e7          	jalr	-1086(ra) # 80000f4a <release>
      return -1;
    80005390:	59fd                	li	s3,-1
    80005392:	bff9                	j	80005370 <piperead+0xca>

0000000080005394 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005394:	1141                	addi	sp,sp,-16
    80005396:	e422                	sd	s0,8(sp)
    80005398:	0800                	addi	s0,sp,16
    8000539a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000539c:	8905                	andi	a0,a0,1
    8000539e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800053a0:	8b89                	andi	a5,a5,2
    800053a2:	c399                	beqz	a5,800053a8 <flags2perm+0x14>
      perm |= PTE_W;
    800053a4:	00456513          	ori	a0,a0,4
    return perm;
}
    800053a8:	6422                	ld	s0,8(sp)
    800053aa:	0141                	addi	sp,sp,16
    800053ac:	8082                	ret

00000000800053ae <exec>:

int
exec(char *path, char **argv)
{
    800053ae:	de010113          	addi	sp,sp,-544
    800053b2:	20113c23          	sd	ra,536(sp)
    800053b6:	20813823          	sd	s0,528(sp)
    800053ba:	20913423          	sd	s1,520(sp)
    800053be:	21213023          	sd	s2,512(sp)
    800053c2:	ffce                	sd	s3,504(sp)
    800053c4:	fbd2                	sd	s4,496(sp)
    800053c6:	f7d6                	sd	s5,488(sp)
    800053c8:	f3da                	sd	s6,480(sp)
    800053ca:	efde                	sd	s7,472(sp)
    800053cc:	ebe2                	sd	s8,464(sp)
    800053ce:	e7e6                	sd	s9,456(sp)
    800053d0:	e3ea                	sd	s10,448(sp)
    800053d2:	ff6e                	sd	s11,440(sp)
    800053d4:	1400                	addi	s0,sp,544
    800053d6:	892a                	mv	s2,a0
    800053d8:	dea43423          	sd	a0,-536(s0)
    800053dc:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800053e0:	ffffd097          	auipc	ra,0xffffd
    800053e4:	9e2080e7          	jalr	-1566(ra) # 80001dc2 <myproc>
    800053e8:	84aa                	mv	s1,a0

  begin_op();
    800053ea:	fffff097          	auipc	ra,0xfffff
    800053ee:	482080e7          	jalr	1154(ra) # 8000486c <begin_op>

  if((ip = namei(path)) == 0){
    800053f2:	854a                	mv	a0,s2
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	258080e7          	jalr	600(ra) # 8000464c <namei>
    800053fc:	c93d                	beqz	a0,80005472 <exec+0xc4>
    800053fe:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	aa0080e7          	jalr	-1376(ra) # 80003ea0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005408:	04000713          	li	a4,64
    8000540c:	4681                	li	a3,0
    8000540e:	e5040613          	addi	a2,s0,-432
    80005412:	4581                	li	a1,0
    80005414:	8556                	mv	a0,s5
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	d3e080e7          	jalr	-706(ra) # 80004154 <readi>
    8000541e:	04000793          	li	a5,64
    80005422:	00f51a63          	bne	a0,a5,80005436 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005426:	e5042703          	lw	a4,-432(s0)
    8000542a:	464c47b7          	lui	a5,0x464c4
    8000542e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005432:	04f70663          	beq	a4,a5,8000547e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005436:	8556                	mv	a0,s5
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	cca080e7          	jalr	-822(ra) # 80004102 <iunlockput>
    end_op();
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	4aa080e7          	jalr	1194(ra) # 800048ea <end_op>
  }
  return -1;
    80005448:	557d                	li	a0,-1
}
    8000544a:	21813083          	ld	ra,536(sp)
    8000544e:	21013403          	ld	s0,528(sp)
    80005452:	20813483          	ld	s1,520(sp)
    80005456:	20013903          	ld	s2,512(sp)
    8000545a:	79fe                	ld	s3,504(sp)
    8000545c:	7a5e                	ld	s4,496(sp)
    8000545e:	7abe                	ld	s5,488(sp)
    80005460:	7b1e                	ld	s6,480(sp)
    80005462:	6bfe                	ld	s7,472(sp)
    80005464:	6c5e                	ld	s8,464(sp)
    80005466:	6cbe                	ld	s9,456(sp)
    80005468:	6d1e                	ld	s10,448(sp)
    8000546a:	7dfa                	ld	s11,440(sp)
    8000546c:	22010113          	addi	sp,sp,544
    80005470:	8082                	ret
    end_op();
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	478080e7          	jalr	1144(ra) # 800048ea <end_op>
    return -1;
    8000547a:	557d                	li	a0,-1
    8000547c:	b7f9                	j	8000544a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffd097          	auipc	ra,0xffffd
    80005484:	a06080e7          	jalr	-1530(ra) # 80001e86 <proc_pagetable>
    80005488:	8b2a                	mv	s6,a0
    8000548a:	d555                	beqz	a0,80005436 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000548c:	e7042783          	lw	a5,-400(s0)
    80005490:	e8845703          	lhu	a4,-376(s0)
    80005494:	c735                	beqz	a4,80005500 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005496:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005498:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000549c:	6a05                	lui	s4,0x1
    8000549e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800054a2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800054a6:	6d85                	lui	s11,0x1
    800054a8:	7d7d                	lui	s10,0xfffff
    800054aa:	ac3d                	j	800056e8 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054ac:	00003517          	auipc	a0,0x3
    800054b0:	38450513          	addi	a0,a0,900 # 80008830 <syscalls+0x2a8>
    800054b4:	ffffb097          	auipc	ra,0xffffb
    800054b8:	08c080e7          	jalr	140(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054bc:	874a                	mv	a4,s2
    800054be:	009c86bb          	addw	a3,s9,s1
    800054c2:	4581                	li	a1,0
    800054c4:	8556                	mv	a0,s5
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	c8e080e7          	jalr	-882(ra) # 80004154 <readi>
    800054ce:	2501                	sext.w	a0,a0
    800054d0:	1aa91963          	bne	s2,a0,80005682 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    800054d4:	009d84bb          	addw	s1,s11,s1
    800054d8:	013d09bb          	addw	s3,s10,s3
    800054dc:	1f74f663          	bgeu	s1,s7,800056c8 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    800054e0:	02049593          	slli	a1,s1,0x20
    800054e4:	9181                	srli	a1,a1,0x20
    800054e6:	95e2                	add	a1,a1,s8
    800054e8:	855a                	mv	a0,s6
    800054ea:	ffffc097          	auipc	ra,0xffffc
    800054ee:	e32080e7          	jalr	-462(ra) # 8000131c <walkaddr>
    800054f2:	862a                	mv	a2,a0
    if(pa == 0)
    800054f4:	dd45                	beqz	a0,800054ac <exec+0xfe>
      n = PGSIZE;
    800054f6:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800054f8:	fd49f2e3          	bgeu	s3,s4,800054bc <exec+0x10e>
      n = sz - i;
    800054fc:	894e                	mv	s2,s3
    800054fe:	bf7d                	j	800054bc <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005500:	4901                	li	s2,0
  iunlockput(ip);
    80005502:	8556                	mv	a0,s5
    80005504:	fffff097          	auipc	ra,0xfffff
    80005508:	bfe080e7          	jalr	-1026(ra) # 80004102 <iunlockput>
  end_op();
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	3de080e7          	jalr	990(ra) # 800048ea <end_op>
  p = myproc();
    80005514:	ffffd097          	auipc	ra,0xffffd
    80005518:	8ae080e7          	jalr	-1874(ra) # 80001dc2 <myproc>
    8000551c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000551e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005522:	6785                	lui	a5,0x1
    80005524:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005526:	97ca                	add	a5,a5,s2
    80005528:	777d                	lui	a4,0xfffff
    8000552a:	8ff9                	and	a5,a5,a4
    8000552c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005530:	4691                	li	a3,4
    80005532:	6609                	lui	a2,0x2
    80005534:	963e                	add	a2,a2,a5
    80005536:	85be                	mv	a1,a5
    80005538:	855a                	mv	a0,s6
    8000553a:	ffffc097          	auipc	ra,0xffffc
    8000553e:	196080e7          	jalr	406(ra) # 800016d0 <uvmalloc>
    80005542:	8c2a                	mv	s8,a0
  ip = 0;
    80005544:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005546:	12050e63          	beqz	a0,80005682 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000554a:	75f9                	lui	a1,0xffffe
    8000554c:	95aa                	add	a1,a1,a0
    8000554e:	855a                	mv	a0,s6
    80005550:	ffffc097          	auipc	ra,0xffffc
    80005554:	3a6080e7          	jalr	934(ra) # 800018f6 <uvmclear>
  stackbase = sp - PGSIZE;
    80005558:	7afd                	lui	s5,0xfffff
    8000555a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000555c:	df043783          	ld	a5,-528(s0)
    80005560:	6388                	ld	a0,0(a5)
    80005562:	c925                	beqz	a0,800055d2 <exec+0x224>
    80005564:	e9040993          	addi	s3,s0,-368
    80005568:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000556c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000556e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005570:	ffffc097          	auipc	ra,0xffffc
    80005574:	b9e080e7          	jalr	-1122(ra) # 8000110e <strlen>
    80005578:	0015079b          	addiw	a5,a0,1
    8000557c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005580:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005584:	13596663          	bltu	s2,s5,800056b0 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005588:	df043d83          	ld	s11,-528(s0)
    8000558c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005590:	8552                	mv	a0,s4
    80005592:	ffffc097          	auipc	ra,0xffffc
    80005596:	b7c080e7          	jalr	-1156(ra) # 8000110e <strlen>
    8000559a:	0015069b          	addiw	a3,a0,1
    8000559e:	8652                	mv	a2,s4
    800055a0:	85ca                	mv	a1,s2
    800055a2:	855a                	mv	a0,s6
    800055a4:	ffffc097          	auipc	ra,0xffffc
    800055a8:	384080e7          	jalr	900(ra) # 80001928 <copyout>
    800055ac:	10054663          	bltz	a0,800056b8 <exec+0x30a>
    ustack[argc] = sp;
    800055b0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055b4:	0485                	addi	s1,s1,1
    800055b6:	008d8793          	addi	a5,s11,8
    800055ba:	def43823          	sd	a5,-528(s0)
    800055be:	008db503          	ld	a0,8(s11)
    800055c2:	c911                	beqz	a0,800055d6 <exec+0x228>
    if(argc >= MAXARG)
    800055c4:	09a1                	addi	s3,s3,8
    800055c6:	fb3c95e3          	bne	s9,s3,80005570 <exec+0x1c2>
  sz = sz1;
    800055ca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055ce:	4a81                	li	s5,0
    800055d0:	a84d                	j	80005682 <exec+0x2d4>
  sp = sz;
    800055d2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800055d4:	4481                	li	s1,0
  ustack[argc] = 0;
    800055d6:	00349793          	slli	a5,s1,0x3
    800055da:	f9078793          	addi	a5,a5,-112
    800055de:	97a2                	add	a5,a5,s0
    800055e0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800055e4:	00148693          	addi	a3,s1,1
    800055e8:	068e                	slli	a3,a3,0x3
    800055ea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055ee:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800055f2:	01597663          	bgeu	s2,s5,800055fe <exec+0x250>
  sz = sz1;
    800055f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055fa:	4a81                	li	s5,0
    800055fc:	a059                	j	80005682 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800055fe:	e9040613          	addi	a2,s0,-368
    80005602:	85ca                	mv	a1,s2
    80005604:	855a                	mv	a0,s6
    80005606:	ffffc097          	auipc	ra,0xffffc
    8000560a:	322080e7          	jalr	802(ra) # 80001928 <copyout>
    8000560e:	0a054963          	bltz	a0,800056c0 <exec+0x312>
  p->trapframe->a1 = sp;
    80005612:	058bb783          	ld	a5,88(s7)
    80005616:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000561a:	de843783          	ld	a5,-536(s0)
    8000561e:	0007c703          	lbu	a4,0(a5)
    80005622:	cf11                	beqz	a4,8000563e <exec+0x290>
    80005624:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005626:	02f00693          	li	a3,47
    8000562a:	a039                	j	80005638 <exec+0x28a>
      last = s+1;
    8000562c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005630:	0785                	addi	a5,a5,1
    80005632:	fff7c703          	lbu	a4,-1(a5)
    80005636:	c701                	beqz	a4,8000563e <exec+0x290>
    if(*s == '/')
    80005638:	fed71ce3          	bne	a4,a3,80005630 <exec+0x282>
    8000563c:	bfc5                	j	8000562c <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000563e:	4641                	li	a2,16
    80005640:	de843583          	ld	a1,-536(s0)
    80005644:	158b8513          	addi	a0,s7,344
    80005648:	ffffc097          	auipc	ra,0xffffc
    8000564c:	a94080e7          	jalr	-1388(ra) # 800010dc <safestrcpy>
  oldpagetable = p->pagetable;
    80005650:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005654:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005658:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000565c:	058bb783          	ld	a5,88(s7)
    80005660:	e6843703          	ld	a4,-408(s0)
    80005664:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005666:	058bb783          	ld	a5,88(s7)
    8000566a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000566e:	85ea                	mv	a1,s10
    80005670:	ffffd097          	auipc	ra,0xffffd
    80005674:	8b2080e7          	jalr	-1870(ra) # 80001f22 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005678:	0004851b          	sext.w	a0,s1
    8000567c:	b3f9                	j	8000544a <exec+0x9c>
    8000567e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005682:	df843583          	ld	a1,-520(s0)
    80005686:	855a                	mv	a0,s6
    80005688:	ffffd097          	auipc	ra,0xffffd
    8000568c:	89a080e7          	jalr	-1894(ra) # 80001f22 <proc_freepagetable>
  if(ip){
    80005690:	da0a93e3          	bnez	s5,80005436 <exec+0x88>
  return -1;
    80005694:	557d                	li	a0,-1
    80005696:	bb55                	j	8000544a <exec+0x9c>
    80005698:	df243c23          	sd	s2,-520(s0)
    8000569c:	b7dd                	j	80005682 <exec+0x2d4>
    8000569e:	df243c23          	sd	s2,-520(s0)
    800056a2:	b7c5                	j	80005682 <exec+0x2d4>
    800056a4:	df243c23          	sd	s2,-520(s0)
    800056a8:	bfe9                	j	80005682 <exec+0x2d4>
    800056aa:	df243c23          	sd	s2,-520(s0)
    800056ae:	bfd1                	j	80005682 <exec+0x2d4>
  sz = sz1;
    800056b0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056b4:	4a81                	li	s5,0
    800056b6:	b7f1                	j	80005682 <exec+0x2d4>
  sz = sz1;
    800056b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056bc:	4a81                	li	s5,0
    800056be:	b7d1                	j	80005682 <exec+0x2d4>
  sz = sz1;
    800056c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056c4:	4a81                	li	s5,0
    800056c6:	bf75                	j	80005682 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056c8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056cc:	e0843783          	ld	a5,-504(s0)
    800056d0:	0017869b          	addiw	a3,a5,1
    800056d4:	e0d43423          	sd	a3,-504(s0)
    800056d8:	e0043783          	ld	a5,-512(s0)
    800056dc:	0387879b          	addiw	a5,a5,56
    800056e0:	e8845703          	lhu	a4,-376(s0)
    800056e4:	e0e6dfe3          	bge	a3,a4,80005502 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056e8:	2781                	sext.w	a5,a5
    800056ea:	e0f43023          	sd	a5,-512(s0)
    800056ee:	03800713          	li	a4,56
    800056f2:	86be                	mv	a3,a5
    800056f4:	e1840613          	addi	a2,s0,-488
    800056f8:	4581                	li	a1,0
    800056fa:	8556                	mv	a0,s5
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	a58080e7          	jalr	-1448(ra) # 80004154 <readi>
    80005704:	03800793          	li	a5,56
    80005708:	f6f51be3          	bne	a0,a5,8000567e <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000570c:	e1842783          	lw	a5,-488(s0)
    80005710:	4705                	li	a4,1
    80005712:	fae79de3          	bne	a5,a4,800056cc <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005716:	e4043483          	ld	s1,-448(s0)
    8000571a:	e3843783          	ld	a5,-456(s0)
    8000571e:	f6f4ede3          	bltu	s1,a5,80005698 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005722:	e2843783          	ld	a5,-472(s0)
    80005726:	94be                	add	s1,s1,a5
    80005728:	f6f4ebe3          	bltu	s1,a5,8000569e <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000572c:	de043703          	ld	a4,-544(s0)
    80005730:	8ff9                	and	a5,a5,a4
    80005732:	fbad                	bnez	a5,800056a4 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005734:	e1c42503          	lw	a0,-484(s0)
    80005738:	00000097          	auipc	ra,0x0
    8000573c:	c5c080e7          	jalr	-932(ra) # 80005394 <flags2perm>
    80005740:	86aa                	mv	a3,a0
    80005742:	8626                	mv	a2,s1
    80005744:	85ca                	mv	a1,s2
    80005746:	855a                	mv	a0,s6
    80005748:	ffffc097          	auipc	ra,0xffffc
    8000574c:	f88080e7          	jalr	-120(ra) # 800016d0 <uvmalloc>
    80005750:	dea43c23          	sd	a0,-520(s0)
    80005754:	d939                	beqz	a0,800056aa <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005756:	e2843c03          	ld	s8,-472(s0)
    8000575a:	e2042c83          	lw	s9,-480(s0)
    8000575e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005762:	f60b83e3          	beqz	s7,800056c8 <exec+0x31a>
    80005766:	89de                	mv	s3,s7
    80005768:	4481                	li	s1,0
    8000576a:	bb9d                	j	800054e0 <exec+0x132>

000000008000576c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000576c:	7179                	addi	sp,sp,-48
    8000576e:	f406                	sd	ra,40(sp)
    80005770:	f022                	sd	s0,32(sp)
    80005772:	ec26                	sd	s1,24(sp)
    80005774:	e84a                	sd	s2,16(sp)
    80005776:	1800                	addi	s0,sp,48
    80005778:	892e                	mv	s2,a1
    8000577a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000577c:	fdc40593          	addi	a1,s0,-36
    80005780:	ffffe097          	auipc	ra,0xffffe
    80005784:	a8a080e7          	jalr	-1398(ra) # 8000320a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005788:	fdc42703          	lw	a4,-36(s0)
    8000578c:	47bd                	li	a5,15
    8000578e:	02e7eb63          	bltu	a5,a4,800057c4 <argfd+0x58>
    80005792:	ffffc097          	auipc	ra,0xffffc
    80005796:	630080e7          	jalr	1584(ra) # 80001dc2 <myproc>
    8000579a:	fdc42703          	lw	a4,-36(s0)
    8000579e:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffbd102>
    800057a2:	078e                	slli	a5,a5,0x3
    800057a4:	953e                	add	a0,a0,a5
    800057a6:	611c                	ld	a5,0(a0)
    800057a8:	c385                	beqz	a5,800057c8 <argfd+0x5c>
    return -1;
  if(pfd)
    800057aa:	00090463          	beqz	s2,800057b2 <argfd+0x46>
    *pfd = fd;
    800057ae:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800057b2:	4501                	li	a0,0
  if(pf)
    800057b4:	c091                	beqz	s1,800057b8 <argfd+0x4c>
    *pf = f;
    800057b6:	e09c                	sd	a5,0(s1)
}
    800057b8:	70a2                	ld	ra,40(sp)
    800057ba:	7402                	ld	s0,32(sp)
    800057bc:	64e2                	ld	s1,24(sp)
    800057be:	6942                	ld	s2,16(sp)
    800057c0:	6145                	addi	sp,sp,48
    800057c2:	8082                	ret
    return -1;
    800057c4:	557d                	li	a0,-1
    800057c6:	bfcd                	j	800057b8 <argfd+0x4c>
    800057c8:	557d                	li	a0,-1
    800057ca:	b7fd                	j	800057b8 <argfd+0x4c>

00000000800057cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057cc:	1101                	addi	sp,sp,-32
    800057ce:	ec06                	sd	ra,24(sp)
    800057d0:	e822                	sd	s0,16(sp)
    800057d2:	e426                	sd	s1,8(sp)
    800057d4:	1000                	addi	s0,sp,32
    800057d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057d8:	ffffc097          	auipc	ra,0xffffc
    800057dc:	5ea080e7          	jalr	1514(ra) # 80001dc2 <myproc>
    800057e0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057e2:	0d050793          	addi	a5,a0,208
    800057e6:	4501                	li	a0,0
    800057e8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057ea:	6398                	ld	a4,0(a5)
    800057ec:	cb19                	beqz	a4,80005802 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057ee:	2505                	addiw	a0,a0,1
    800057f0:	07a1                	addi	a5,a5,8
    800057f2:	fed51ce3          	bne	a0,a3,800057ea <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800057f6:	557d                	li	a0,-1
}
    800057f8:	60e2                	ld	ra,24(sp)
    800057fa:	6442                	ld	s0,16(sp)
    800057fc:	64a2                	ld	s1,8(sp)
    800057fe:	6105                	addi	sp,sp,32
    80005800:	8082                	ret
      p->ofile[fd] = f;
    80005802:	01a50793          	addi	a5,a0,26
    80005806:	078e                	slli	a5,a5,0x3
    80005808:	963e                	add	a2,a2,a5
    8000580a:	e204                	sd	s1,0(a2)
      return fd;
    8000580c:	b7f5                	j	800057f8 <fdalloc+0x2c>

000000008000580e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000580e:	715d                	addi	sp,sp,-80
    80005810:	e486                	sd	ra,72(sp)
    80005812:	e0a2                	sd	s0,64(sp)
    80005814:	fc26                	sd	s1,56(sp)
    80005816:	f84a                	sd	s2,48(sp)
    80005818:	f44e                	sd	s3,40(sp)
    8000581a:	f052                	sd	s4,32(sp)
    8000581c:	ec56                	sd	s5,24(sp)
    8000581e:	e85a                	sd	s6,16(sp)
    80005820:	0880                	addi	s0,sp,80
    80005822:	8b2e                	mv	s6,a1
    80005824:	89b2                	mv	s3,a2
    80005826:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005828:	fb040593          	addi	a1,s0,-80
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	e3e080e7          	jalr	-450(ra) # 8000466a <nameiparent>
    80005834:	84aa                	mv	s1,a0
    80005836:	14050f63          	beqz	a0,80005994 <create+0x186>
    return 0;

  ilock(dp);
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	666080e7          	jalr	1638(ra) # 80003ea0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005842:	4601                	li	a2,0
    80005844:	fb040593          	addi	a1,s0,-80
    80005848:	8526                	mv	a0,s1
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	b3a080e7          	jalr	-1222(ra) # 80004384 <dirlookup>
    80005852:	8aaa                	mv	s5,a0
    80005854:	c931                	beqz	a0,800058a8 <create+0x9a>
    iunlockput(dp);
    80005856:	8526                	mv	a0,s1
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	8aa080e7          	jalr	-1878(ra) # 80004102 <iunlockput>
    ilock(ip);
    80005860:	8556                	mv	a0,s5
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	63e080e7          	jalr	1598(ra) # 80003ea0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000586a:	000b059b          	sext.w	a1,s6
    8000586e:	4789                	li	a5,2
    80005870:	02f59563          	bne	a1,a5,8000589a <create+0x8c>
    80005874:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffbd12c>
    80005878:	37f9                	addiw	a5,a5,-2
    8000587a:	17c2                	slli	a5,a5,0x30
    8000587c:	93c1                	srli	a5,a5,0x30
    8000587e:	4705                	li	a4,1
    80005880:	00f76d63          	bltu	a4,a5,8000589a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005884:	8556                	mv	a0,s5
    80005886:	60a6                	ld	ra,72(sp)
    80005888:	6406                	ld	s0,64(sp)
    8000588a:	74e2                	ld	s1,56(sp)
    8000588c:	7942                	ld	s2,48(sp)
    8000588e:	79a2                	ld	s3,40(sp)
    80005890:	7a02                	ld	s4,32(sp)
    80005892:	6ae2                	ld	s5,24(sp)
    80005894:	6b42                	ld	s6,16(sp)
    80005896:	6161                	addi	sp,sp,80
    80005898:	8082                	ret
    iunlockput(ip);
    8000589a:	8556                	mv	a0,s5
    8000589c:	fffff097          	auipc	ra,0xfffff
    800058a0:	866080e7          	jalr	-1946(ra) # 80004102 <iunlockput>
    return 0;
    800058a4:	4a81                	li	s5,0
    800058a6:	bff9                	j	80005884 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800058a8:	85da                	mv	a1,s6
    800058aa:	4088                	lw	a0,0(s1)
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	456080e7          	jalr	1110(ra) # 80003d02 <ialloc>
    800058b4:	8a2a                	mv	s4,a0
    800058b6:	c539                	beqz	a0,80005904 <create+0xf6>
  ilock(ip);
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	5e8080e7          	jalr	1512(ra) # 80003ea0 <ilock>
  ip->major = major;
    800058c0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800058c4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800058c8:	4905                	li	s2,1
    800058ca:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800058ce:	8552                	mv	a0,s4
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	504080e7          	jalr	1284(ra) # 80003dd4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058d8:	000b059b          	sext.w	a1,s6
    800058dc:	03258b63          	beq	a1,s2,80005912 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800058e0:	004a2603          	lw	a2,4(s4)
    800058e4:	fb040593          	addi	a1,s0,-80
    800058e8:	8526                	mv	a0,s1
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	cb0080e7          	jalr	-848(ra) # 8000459a <dirlink>
    800058f2:	06054f63          	bltz	a0,80005970 <create+0x162>
  iunlockput(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	80a080e7          	jalr	-2038(ra) # 80004102 <iunlockput>
  return ip;
    80005900:	8ad2                	mv	s5,s4
    80005902:	b749                	j	80005884 <create+0x76>
    iunlockput(dp);
    80005904:	8526                	mv	a0,s1
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	7fc080e7          	jalr	2044(ra) # 80004102 <iunlockput>
    return 0;
    8000590e:	8ad2                	mv	s5,s4
    80005910:	bf95                	j	80005884 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005912:	004a2603          	lw	a2,4(s4)
    80005916:	00003597          	auipc	a1,0x3
    8000591a:	f3a58593          	addi	a1,a1,-198 # 80008850 <syscalls+0x2c8>
    8000591e:	8552                	mv	a0,s4
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	c7a080e7          	jalr	-902(ra) # 8000459a <dirlink>
    80005928:	04054463          	bltz	a0,80005970 <create+0x162>
    8000592c:	40d0                	lw	a2,4(s1)
    8000592e:	00003597          	auipc	a1,0x3
    80005932:	f2a58593          	addi	a1,a1,-214 # 80008858 <syscalls+0x2d0>
    80005936:	8552                	mv	a0,s4
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	c62080e7          	jalr	-926(ra) # 8000459a <dirlink>
    80005940:	02054863          	bltz	a0,80005970 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005944:	004a2603          	lw	a2,4(s4)
    80005948:	fb040593          	addi	a1,s0,-80
    8000594c:	8526                	mv	a0,s1
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	c4c080e7          	jalr	-948(ra) # 8000459a <dirlink>
    80005956:	00054d63          	bltz	a0,80005970 <create+0x162>
    dp->nlink++;  // for ".."
    8000595a:	04a4d783          	lhu	a5,74(s1)
    8000595e:	2785                	addiw	a5,a5,1
    80005960:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005964:	8526                	mv	a0,s1
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	46e080e7          	jalr	1134(ra) # 80003dd4 <iupdate>
    8000596e:	b761                	j	800058f6 <create+0xe8>
  ip->nlink = 0;
    80005970:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005974:	8552                	mv	a0,s4
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	45e080e7          	jalr	1118(ra) # 80003dd4 <iupdate>
  iunlockput(ip);
    8000597e:	8552                	mv	a0,s4
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	782080e7          	jalr	1922(ra) # 80004102 <iunlockput>
  iunlockput(dp);
    80005988:	8526                	mv	a0,s1
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	778080e7          	jalr	1912(ra) # 80004102 <iunlockput>
  return 0;
    80005992:	bdcd                	j	80005884 <create+0x76>
    return 0;
    80005994:	8aaa                	mv	s5,a0
    80005996:	b5fd                	j	80005884 <create+0x76>

0000000080005998 <sys_dup>:
{
    80005998:	7179                	addi	sp,sp,-48
    8000599a:	f406                	sd	ra,40(sp)
    8000599c:	f022                	sd	s0,32(sp)
    8000599e:	ec26                	sd	s1,24(sp)
    800059a0:	e84a                	sd	s2,16(sp)
    800059a2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800059a4:	fd840613          	addi	a2,s0,-40
    800059a8:	4581                	li	a1,0
    800059aa:	4501                	li	a0,0
    800059ac:	00000097          	auipc	ra,0x0
    800059b0:	dc0080e7          	jalr	-576(ra) # 8000576c <argfd>
    return -1;
    800059b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059b6:	02054363          	bltz	a0,800059dc <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800059ba:	fd843903          	ld	s2,-40(s0)
    800059be:	854a                	mv	a0,s2
    800059c0:	00000097          	auipc	ra,0x0
    800059c4:	e0c080e7          	jalr	-500(ra) # 800057cc <fdalloc>
    800059c8:	84aa                	mv	s1,a0
    return -1;
    800059ca:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059cc:	00054863          	bltz	a0,800059dc <sys_dup+0x44>
  filedup(f);
    800059d0:	854a                	mv	a0,s2
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	310080e7          	jalr	784(ra) # 80004ce2 <filedup>
  return fd;
    800059da:	87a6                	mv	a5,s1
}
    800059dc:	853e                	mv	a0,a5
    800059de:	70a2                	ld	ra,40(sp)
    800059e0:	7402                	ld	s0,32(sp)
    800059e2:	64e2                	ld	s1,24(sp)
    800059e4:	6942                	ld	s2,16(sp)
    800059e6:	6145                	addi	sp,sp,48
    800059e8:	8082                	ret

00000000800059ea <sys_read>:
{
    800059ea:	7179                	addi	sp,sp,-48
    800059ec:	f406                	sd	ra,40(sp)
    800059ee:	f022                	sd	s0,32(sp)
    800059f0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059f2:	fd840593          	addi	a1,s0,-40
    800059f6:	4505                	li	a0,1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	832080e7          	jalr	-1998(ra) # 8000322a <argaddr>
  argint(2, &n);
    80005a00:	fe440593          	addi	a1,s0,-28
    80005a04:	4509                	li	a0,2
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	804080e7          	jalr	-2044(ra) # 8000320a <argint>
  if(argfd(0, 0, &f) < 0)
    80005a0e:	fe840613          	addi	a2,s0,-24
    80005a12:	4581                	li	a1,0
    80005a14:	4501                	li	a0,0
    80005a16:	00000097          	auipc	ra,0x0
    80005a1a:	d56080e7          	jalr	-682(ra) # 8000576c <argfd>
    80005a1e:	87aa                	mv	a5,a0
    return -1;
    80005a20:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a22:	0007cc63          	bltz	a5,80005a3a <sys_read+0x50>
  return fileread(f, p, n);
    80005a26:	fe442603          	lw	a2,-28(s0)
    80005a2a:	fd843583          	ld	a1,-40(s0)
    80005a2e:	fe843503          	ld	a0,-24(s0)
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	43c080e7          	jalr	1084(ra) # 80004e6e <fileread>
}
    80005a3a:	70a2                	ld	ra,40(sp)
    80005a3c:	7402                	ld	s0,32(sp)
    80005a3e:	6145                	addi	sp,sp,48
    80005a40:	8082                	ret

0000000080005a42 <sys_write>:
{
    80005a42:	7179                	addi	sp,sp,-48
    80005a44:	f406                	sd	ra,40(sp)
    80005a46:	f022                	sd	s0,32(sp)
    80005a48:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a4a:	fd840593          	addi	a1,s0,-40
    80005a4e:	4505                	li	a0,1
    80005a50:	ffffd097          	auipc	ra,0xffffd
    80005a54:	7da080e7          	jalr	2010(ra) # 8000322a <argaddr>
  argint(2, &n);
    80005a58:	fe440593          	addi	a1,s0,-28
    80005a5c:	4509                	li	a0,2
    80005a5e:	ffffd097          	auipc	ra,0xffffd
    80005a62:	7ac080e7          	jalr	1964(ra) # 8000320a <argint>
  if(argfd(0, 0, &f) < 0)
    80005a66:	fe840613          	addi	a2,s0,-24
    80005a6a:	4581                	li	a1,0
    80005a6c:	4501                	li	a0,0
    80005a6e:	00000097          	auipc	ra,0x0
    80005a72:	cfe080e7          	jalr	-770(ra) # 8000576c <argfd>
    80005a76:	87aa                	mv	a5,a0
    return -1;
    80005a78:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a7a:	0007cc63          	bltz	a5,80005a92 <sys_write+0x50>
  return filewrite(f, p, n);
    80005a7e:	fe442603          	lw	a2,-28(s0)
    80005a82:	fd843583          	ld	a1,-40(s0)
    80005a86:	fe843503          	ld	a0,-24(s0)
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	4a6080e7          	jalr	1190(ra) # 80004f30 <filewrite>
}
    80005a92:	70a2                	ld	ra,40(sp)
    80005a94:	7402                	ld	s0,32(sp)
    80005a96:	6145                	addi	sp,sp,48
    80005a98:	8082                	ret

0000000080005a9a <sys_close>:
{
    80005a9a:	1101                	addi	sp,sp,-32
    80005a9c:	ec06                	sd	ra,24(sp)
    80005a9e:	e822                	sd	s0,16(sp)
    80005aa0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005aa2:	fe040613          	addi	a2,s0,-32
    80005aa6:	fec40593          	addi	a1,s0,-20
    80005aaa:	4501                	li	a0,0
    80005aac:	00000097          	auipc	ra,0x0
    80005ab0:	cc0080e7          	jalr	-832(ra) # 8000576c <argfd>
    return -1;
    80005ab4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ab6:	02054463          	bltz	a0,80005ade <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005aba:	ffffc097          	auipc	ra,0xffffc
    80005abe:	308080e7          	jalr	776(ra) # 80001dc2 <myproc>
    80005ac2:	fec42783          	lw	a5,-20(s0)
    80005ac6:	07e9                	addi	a5,a5,26
    80005ac8:	078e                	slli	a5,a5,0x3
    80005aca:	953e                	add	a0,a0,a5
    80005acc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005ad0:	fe043503          	ld	a0,-32(s0)
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	260080e7          	jalr	608(ra) # 80004d34 <fileclose>
  return 0;
    80005adc:	4781                	li	a5,0
}
    80005ade:	853e                	mv	a0,a5
    80005ae0:	60e2                	ld	ra,24(sp)
    80005ae2:	6442                	ld	s0,16(sp)
    80005ae4:	6105                	addi	sp,sp,32
    80005ae6:	8082                	ret

0000000080005ae8 <sys_fstat>:
{
    80005ae8:	1101                	addi	sp,sp,-32
    80005aea:	ec06                	sd	ra,24(sp)
    80005aec:	e822                	sd	s0,16(sp)
    80005aee:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005af0:	fe040593          	addi	a1,s0,-32
    80005af4:	4505                	li	a0,1
    80005af6:	ffffd097          	auipc	ra,0xffffd
    80005afa:	734080e7          	jalr	1844(ra) # 8000322a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005afe:	fe840613          	addi	a2,s0,-24
    80005b02:	4581                	li	a1,0
    80005b04:	4501                	li	a0,0
    80005b06:	00000097          	auipc	ra,0x0
    80005b0a:	c66080e7          	jalr	-922(ra) # 8000576c <argfd>
    80005b0e:	87aa                	mv	a5,a0
    return -1;
    80005b10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b12:	0007ca63          	bltz	a5,80005b26 <sys_fstat+0x3e>
  return filestat(f, st);
    80005b16:	fe043583          	ld	a1,-32(s0)
    80005b1a:	fe843503          	ld	a0,-24(s0)
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	2de080e7          	jalr	734(ra) # 80004dfc <filestat>
}
    80005b26:	60e2                	ld	ra,24(sp)
    80005b28:	6442                	ld	s0,16(sp)
    80005b2a:	6105                	addi	sp,sp,32
    80005b2c:	8082                	ret

0000000080005b2e <sys_link>:
{
    80005b2e:	7169                	addi	sp,sp,-304
    80005b30:	f606                	sd	ra,296(sp)
    80005b32:	f222                	sd	s0,288(sp)
    80005b34:	ee26                	sd	s1,280(sp)
    80005b36:	ea4a                	sd	s2,272(sp)
    80005b38:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b3a:	08000613          	li	a2,128
    80005b3e:	ed040593          	addi	a1,s0,-304
    80005b42:	4501                	li	a0,0
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	706080e7          	jalr	1798(ra) # 8000324a <argstr>
    return -1;
    80005b4c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b4e:	10054e63          	bltz	a0,80005c6a <sys_link+0x13c>
    80005b52:	08000613          	li	a2,128
    80005b56:	f5040593          	addi	a1,s0,-176
    80005b5a:	4505                	li	a0,1
    80005b5c:	ffffd097          	auipc	ra,0xffffd
    80005b60:	6ee080e7          	jalr	1774(ra) # 8000324a <argstr>
    return -1;
    80005b64:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b66:	10054263          	bltz	a0,80005c6a <sys_link+0x13c>
  begin_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	d02080e7          	jalr	-766(ra) # 8000486c <begin_op>
  if((ip = namei(old)) == 0){
    80005b72:	ed040513          	addi	a0,s0,-304
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	ad6080e7          	jalr	-1322(ra) # 8000464c <namei>
    80005b7e:	84aa                	mv	s1,a0
    80005b80:	c551                	beqz	a0,80005c0c <sys_link+0xde>
  ilock(ip);
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	31e080e7          	jalr	798(ra) # 80003ea0 <ilock>
  if(ip->type == T_DIR){
    80005b8a:	04449703          	lh	a4,68(s1)
    80005b8e:	4785                	li	a5,1
    80005b90:	08f70463          	beq	a4,a5,80005c18 <sys_link+0xea>
  ip->nlink++;
    80005b94:	04a4d783          	lhu	a5,74(s1)
    80005b98:	2785                	addiw	a5,a5,1
    80005b9a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b9e:	8526                	mv	a0,s1
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	234080e7          	jalr	564(ra) # 80003dd4 <iupdate>
  iunlock(ip);
    80005ba8:	8526                	mv	a0,s1
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	3b8080e7          	jalr	952(ra) # 80003f62 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bb2:	fd040593          	addi	a1,s0,-48
    80005bb6:	f5040513          	addi	a0,s0,-176
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	ab0080e7          	jalr	-1360(ra) # 8000466a <nameiparent>
    80005bc2:	892a                	mv	s2,a0
    80005bc4:	c935                	beqz	a0,80005c38 <sys_link+0x10a>
  ilock(dp);
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	2da080e7          	jalr	730(ra) # 80003ea0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005bce:	00092703          	lw	a4,0(s2)
    80005bd2:	409c                	lw	a5,0(s1)
    80005bd4:	04f71d63          	bne	a4,a5,80005c2e <sys_link+0x100>
    80005bd8:	40d0                	lw	a2,4(s1)
    80005bda:	fd040593          	addi	a1,s0,-48
    80005bde:	854a                	mv	a0,s2
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	9ba080e7          	jalr	-1606(ra) # 8000459a <dirlink>
    80005be8:	04054363          	bltz	a0,80005c2e <sys_link+0x100>
  iunlockput(dp);
    80005bec:	854a                	mv	a0,s2
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	514080e7          	jalr	1300(ra) # 80004102 <iunlockput>
  iput(ip);
    80005bf6:	8526                	mv	a0,s1
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	462080e7          	jalr	1122(ra) # 8000405a <iput>
  end_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	cea080e7          	jalr	-790(ra) # 800048ea <end_op>
  return 0;
    80005c08:	4781                	li	a5,0
    80005c0a:	a085                	j	80005c6a <sys_link+0x13c>
    end_op();
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	cde080e7          	jalr	-802(ra) # 800048ea <end_op>
    return -1;
    80005c14:	57fd                	li	a5,-1
    80005c16:	a891                	j	80005c6a <sys_link+0x13c>
    iunlockput(ip);
    80005c18:	8526                	mv	a0,s1
    80005c1a:	ffffe097          	auipc	ra,0xffffe
    80005c1e:	4e8080e7          	jalr	1256(ra) # 80004102 <iunlockput>
    end_op();
    80005c22:	fffff097          	auipc	ra,0xfffff
    80005c26:	cc8080e7          	jalr	-824(ra) # 800048ea <end_op>
    return -1;
    80005c2a:	57fd                	li	a5,-1
    80005c2c:	a83d                	j	80005c6a <sys_link+0x13c>
    iunlockput(dp);
    80005c2e:	854a                	mv	a0,s2
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	4d2080e7          	jalr	1234(ra) # 80004102 <iunlockput>
  ilock(ip);
    80005c38:	8526                	mv	a0,s1
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	266080e7          	jalr	614(ra) # 80003ea0 <ilock>
  ip->nlink--;
    80005c42:	04a4d783          	lhu	a5,74(s1)
    80005c46:	37fd                	addiw	a5,a5,-1
    80005c48:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c4c:	8526                	mv	a0,s1
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	186080e7          	jalr	390(ra) # 80003dd4 <iupdate>
  iunlockput(ip);
    80005c56:	8526                	mv	a0,s1
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	4aa080e7          	jalr	1194(ra) # 80004102 <iunlockput>
  end_op();
    80005c60:	fffff097          	auipc	ra,0xfffff
    80005c64:	c8a080e7          	jalr	-886(ra) # 800048ea <end_op>
  return -1;
    80005c68:	57fd                	li	a5,-1
}
    80005c6a:	853e                	mv	a0,a5
    80005c6c:	70b2                	ld	ra,296(sp)
    80005c6e:	7412                	ld	s0,288(sp)
    80005c70:	64f2                	ld	s1,280(sp)
    80005c72:	6952                	ld	s2,272(sp)
    80005c74:	6155                	addi	sp,sp,304
    80005c76:	8082                	ret

0000000080005c78 <sys_unlink>:
{
    80005c78:	7151                	addi	sp,sp,-240
    80005c7a:	f586                	sd	ra,232(sp)
    80005c7c:	f1a2                	sd	s0,224(sp)
    80005c7e:	eda6                	sd	s1,216(sp)
    80005c80:	e9ca                	sd	s2,208(sp)
    80005c82:	e5ce                	sd	s3,200(sp)
    80005c84:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c86:	08000613          	li	a2,128
    80005c8a:	f3040593          	addi	a1,s0,-208
    80005c8e:	4501                	li	a0,0
    80005c90:	ffffd097          	auipc	ra,0xffffd
    80005c94:	5ba080e7          	jalr	1466(ra) # 8000324a <argstr>
    80005c98:	18054163          	bltz	a0,80005e1a <sys_unlink+0x1a2>
  begin_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	bd0080e7          	jalr	-1072(ra) # 8000486c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ca4:	fb040593          	addi	a1,s0,-80
    80005ca8:	f3040513          	addi	a0,s0,-208
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	9be080e7          	jalr	-1602(ra) # 8000466a <nameiparent>
    80005cb4:	84aa                	mv	s1,a0
    80005cb6:	c979                	beqz	a0,80005d8c <sys_unlink+0x114>
  ilock(dp);
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	1e8080e7          	jalr	488(ra) # 80003ea0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005cc0:	00003597          	auipc	a1,0x3
    80005cc4:	b9058593          	addi	a1,a1,-1136 # 80008850 <syscalls+0x2c8>
    80005cc8:	fb040513          	addi	a0,s0,-80
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	69e080e7          	jalr	1694(ra) # 8000436a <namecmp>
    80005cd4:	14050a63          	beqz	a0,80005e28 <sys_unlink+0x1b0>
    80005cd8:	00003597          	auipc	a1,0x3
    80005cdc:	b8058593          	addi	a1,a1,-1152 # 80008858 <syscalls+0x2d0>
    80005ce0:	fb040513          	addi	a0,s0,-80
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	686080e7          	jalr	1670(ra) # 8000436a <namecmp>
    80005cec:	12050e63          	beqz	a0,80005e28 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cf0:	f2c40613          	addi	a2,s0,-212
    80005cf4:	fb040593          	addi	a1,s0,-80
    80005cf8:	8526                	mv	a0,s1
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	68a080e7          	jalr	1674(ra) # 80004384 <dirlookup>
    80005d02:	892a                	mv	s2,a0
    80005d04:	12050263          	beqz	a0,80005e28 <sys_unlink+0x1b0>
  ilock(ip);
    80005d08:	ffffe097          	auipc	ra,0xffffe
    80005d0c:	198080e7          	jalr	408(ra) # 80003ea0 <ilock>
  if(ip->nlink < 1)
    80005d10:	04a91783          	lh	a5,74(s2)
    80005d14:	08f05263          	blez	a5,80005d98 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d18:	04491703          	lh	a4,68(s2)
    80005d1c:	4785                	li	a5,1
    80005d1e:	08f70563          	beq	a4,a5,80005da8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d22:	4641                	li	a2,16
    80005d24:	4581                	li	a1,0
    80005d26:	fc040513          	addi	a0,s0,-64
    80005d2a:	ffffb097          	auipc	ra,0xffffb
    80005d2e:	268080e7          	jalr	616(ra) # 80000f92 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d32:	4741                	li	a4,16
    80005d34:	f2c42683          	lw	a3,-212(s0)
    80005d38:	fc040613          	addi	a2,s0,-64
    80005d3c:	4581                	li	a1,0
    80005d3e:	8526                	mv	a0,s1
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	50c080e7          	jalr	1292(ra) # 8000424c <writei>
    80005d48:	47c1                	li	a5,16
    80005d4a:	0af51563          	bne	a0,a5,80005df4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005d4e:	04491703          	lh	a4,68(s2)
    80005d52:	4785                	li	a5,1
    80005d54:	0af70863          	beq	a4,a5,80005e04 <sys_unlink+0x18c>
  iunlockput(dp);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	3a8080e7          	jalr	936(ra) # 80004102 <iunlockput>
  ip->nlink--;
    80005d62:	04a95783          	lhu	a5,74(s2)
    80005d66:	37fd                	addiw	a5,a5,-1
    80005d68:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d6c:	854a                	mv	a0,s2
    80005d6e:	ffffe097          	auipc	ra,0xffffe
    80005d72:	066080e7          	jalr	102(ra) # 80003dd4 <iupdate>
  iunlockput(ip);
    80005d76:	854a                	mv	a0,s2
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	38a080e7          	jalr	906(ra) # 80004102 <iunlockput>
  end_op();
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	b6a080e7          	jalr	-1174(ra) # 800048ea <end_op>
  return 0;
    80005d88:	4501                	li	a0,0
    80005d8a:	a84d                	j	80005e3c <sys_unlink+0x1c4>
    end_op();
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	b5e080e7          	jalr	-1186(ra) # 800048ea <end_op>
    return -1;
    80005d94:	557d                	li	a0,-1
    80005d96:	a05d                	j	80005e3c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005d98:	00003517          	auipc	a0,0x3
    80005d9c:	ac850513          	addi	a0,a0,-1336 # 80008860 <syscalls+0x2d8>
    80005da0:	ffffa097          	auipc	ra,0xffffa
    80005da4:	7a0080e7          	jalr	1952(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005da8:	04c92703          	lw	a4,76(s2)
    80005dac:	02000793          	li	a5,32
    80005db0:	f6e7f9e3          	bgeu	a5,a4,80005d22 <sys_unlink+0xaa>
    80005db4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005db8:	4741                	li	a4,16
    80005dba:	86ce                	mv	a3,s3
    80005dbc:	f1840613          	addi	a2,s0,-232
    80005dc0:	4581                	li	a1,0
    80005dc2:	854a                	mv	a0,s2
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	390080e7          	jalr	912(ra) # 80004154 <readi>
    80005dcc:	47c1                	li	a5,16
    80005dce:	00f51b63          	bne	a0,a5,80005de4 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005dd2:	f1845783          	lhu	a5,-232(s0)
    80005dd6:	e7a1                	bnez	a5,80005e1e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dd8:	29c1                	addiw	s3,s3,16
    80005dda:	04c92783          	lw	a5,76(s2)
    80005dde:	fcf9ede3          	bltu	s3,a5,80005db8 <sys_unlink+0x140>
    80005de2:	b781                	j	80005d22 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005de4:	00003517          	auipc	a0,0x3
    80005de8:	a9450513          	addi	a0,a0,-1388 # 80008878 <syscalls+0x2f0>
    80005dec:	ffffa097          	auipc	ra,0xffffa
    80005df0:	754080e7          	jalr	1876(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005df4:	00003517          	auipc	a0,0x3
    80005df8:	a9c50513          	addi	a0,a0,-1380 # 80008890 <syscalls+0x308>
    80005dfc:	ffffa097          	auipc	ra,0xffffa
    80005e00:	744080e7          	jalr	1860(ra) # 80000540 <panic>
    dp->nlink--;
    80005e04:	04a4d783          	lhu	a5,74(s1)
    80005e08:	37fd                	addiw	a5,a5,-1
    80005e0a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	fc4080e7          	jalr	-60(ra) # 80003dd4 <iupdate>
    80005e18:	b781                	j	80005d58 <sys_unlink+0xe0>
    return -1;
    80005e1a:	557d                	li	a0,-1
    80005e1c:	a005                	j	80005e3c <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e1e:	854a                	mv	a0,s2
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	2e2080e7          	jalr	738(ra) # 80004102 <iunlockput>
  iunlockput(dp);
    80005e28:	8526                	mv	a0,s1
    80005e2a:	ffffe097          	auipc	ra,0xffffe
    80005e2e:	2d8080e7          	jalr	728(ra) # 80004102 <iunlockput>
  end_op();
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	ab8080e7          	jalr	-1352(ra) # 800048ea <end_op>
  return -1;
    80005e3a:	557d                	li	a0,-1
}
    80005e3c:	70ae                	ld	ra,232(sp)
    80005e3e:	740e                	ld	s0,224(sp)
    80005e40:	64ee                	ld	s1,216(sp)
    80005e42:	694e                	ld	s2,208(sp)
    80005e44:	69ae                	ld	s3,200(sp)
    80005e46:	616d                	addi	sp,sp,240
    80005e48:	8082                	ret

0000000080005e4a <sys_open>:

uint64
sys_open(void)
{
    80005e4a:	7131                	addi	sp,sp,-192
    80005e4c:	fd06                	sd	ra,184(sp)
    80005e4e:	f922                	sd	s0,176(sp)
    80005e50:	f526                	sd	s1,168(sp)
    80005e52:	f14a                	sd	s2,160(sp)
    80005e54:	ed4e                	sd	s3,152(sp)
    80005e56:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e58:	f4c40593          	addi	a1,s0,-180
    80005e5c:	4505                	li	a0,1
    80005e5e:	ffffd097          	auipc	ra,0xffffd
    80005e62:	3ac080e7          	jalr	940(ra) # 8000320a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e66:	08000613          	li	a2,128
    80005e6a:	f5040593          	addi	a1,s0,-176
    80005e6e:	4501                	li	a0,0
    80005e70:	ffffd097          	auipc	ra,0xffffd
    80005e74:	3da080e7          	jalr	986(ra) # 8000324a <argstr>
    80005e78:	87aa                	mv	a5,a0
    return -1;
    80005e7a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e7c:	0a07c963          	bltz	a5,80005f2e <sys_open+0xe4>

  begin_op();
    80005e80:	fffff097          	auipc	ra,0xfffff
    80005e84:	9ec080e7          	jalr	-1556(ra) # 8000486c <begin_op>

  if(omode & O_CREATE){
    80005e88:	f4c42783          	lw	a5,-180(s0)
    80005e8c:	2007f793          	andi	a5,a5,512
    80005e90:	cfc5                	beqz	a5,80005f48 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e92:	4681                	li	a3,0
    80005e94:	4601                	li	a2,0
    80005e96:	4589                	li	a1,2
    80005e98:	f5040513          	addi	a0,s0,-176
    80005e9c:	00000097          	auipc	ra,0x0
    80005ea0:	972080e7          	jalr	-1678(ra) # 8000580e <create>
    80005ea4:	84aa                	mv	s1,a0
    if(ip == 0){
    80005ea6:	c959                	beqz	a0,80005f3c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ea8:	04449703          	lh	a4,68(s1)
    80005eac:	478d                	li	a5,3
    80005eae:	00f71763          	bne	a4,a5,80005ebc <sys_open+0x72>
    80005eb2:	0464d703          	lhu	a4,70(s1)
    80005eb6:	47a5                	li	a5,9
    80005eb8:	0ce7ed63          	bltu	a5,a4,80005f92 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ebc:	fffff097          	auipc	ra,0xfffff
    80005ec0:	dbc080e7          	jalr	-580(ra) # 80004c78 <filealloc>
    80005ec4:	89aa                	mv	s3,a0
    80005ec6:	10050363          	beqz	a0,80005fcc <sys_open+0x182>
    80005eca:	00000097          	auipc	ra,0x0
    80005ece:	902080e7          	jalr	-1790(ra) # 800057cc <fdalloc>
    80005ed2:	892a                	mv	s2,a0
    80005ed4:	0e054763          	bltz	a0,80005fc2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ed8:	04449703          	lh	a4,68(s1)
    80005edc:	478d                	li	a5,3
    80005ede:	0cf70563          	beq	a4,a5,80005fa8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ee2:	4789                	li	a5,2
    80005ee4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ee8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005eec:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ef0:	f4c42783          	lw	a5,-180(s0)
    80005ef4:	0017c713          	xori	a4,a5,1
    80005ef8:	8b05                	andi	a4,a4,1
    80005efa:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005efe:	0037f713          	andi	a4,a5,3
    80005f02:	00e03733          	snez	a4,a4
    80005f06:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f0a:	4007f793          	andi	a5,a5,1024
    80005f0e:	c791                	beqz	a5,80005f1a <sys_open+0xd0>
    80005f10:	04449703          	lh	a4,68(s1)
    80005f14:	4789                	li	a5,2
    80005f16:	0af70063          	beq	a4,a5,80005fb6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f1a:	8526                	mv	a0,s1
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	046080e7          	jalr	70(ra) # 80003f62 <iunlock>
  end_op();
    80005f24:	fffff097          	auipc	ra,0xfffff
    80005f28:	9c6080e7          	jalr	-1594(ra) # 800048ea <end_op>

  return fd;
    80005f2c:	854a                	mv	a0,s2
}
    80005f2e:	70ea                	ld	ra,184(sp)
    80005f30:	744a                	ld	s0,176(sp)
    80005f32:	74aa                	ld	s1,168(sp)
    80005f34:	790a                	ld	s2,160(sp)
    80005f36:	69ea                	ld	s3,152(sp)
    80005f38:	6129                	addi	sp,sp,192
    80005f3a:	8082                	ret
      end_op();
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	9ae080e7          	jalr	-1618(ra) # 800048ea <end_op>
      return -1;
    80005f44:	557d                	li	a0,-1
    80005f46:	b7e5                	j	80005f2e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f48:	f5040513          	addi	a0,s0,-176
    80005f4c:	ffffe097          	auipc	ra,0xffffe
    80005f50:	700080e7          	jalr	1792(ra) # 8000464c <namei>
    80005f54:	84aa                	mv	s1,a0
    80005f56:	c905                	beqz	a0,80005f86 <sys_open+0x13c>
    ilock(ip);
    80005f58:	ffffe097          	auipc	ra,0xffffe
    80005f5c:	f48080e7          	jalr	-184(ra) # 80003ea0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f60:	04449703          	lh	a4,68(s1)
    80005f64:	4785                	li	a5,1
    80005f66:	f4f711e3          	bne	a4,a5,80005ea8 <sys_open+0x5e>
    80005f6a:	f4c42783          	lw	a5,-180(s0)
    80005f6e:	d7b9                	beqz	a5,80005ebc <sys_open+0x72>
      iunlockput(ip);
    80005f70:	8526                	mv	a0,s1
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	190080e7          	jalr	400(ra) # 80004102 <iunlockput>
      end_op();
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	970080e7          	jalr	-1680(ra) # 800048ea <end_op>
      return -1;
    80005f82:	557d                	li	a0,-1
    80005f84:	b76d                	j	80005f2e <sys_open+0xe4>
      end_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	964080e7          	jalr	-1692(ra) # 800048ea <end_op>
      return -1;
    80005f8e:	557d                	li	a0,-1
    80005f90:	bf79                	j	80005f2e <sys_open+0xe4>
    iunlockput(ip);
    80005f92:	8526                	mv	a0,s1
    80005f94:	ffffe097          	auipc	ra,0xffffe
    80005f98:	16e080e7          	jalr	366(ra) # 80004102 <iunlockput>
    end_op();
    80005f9c:	fffff097          	auipc	ra,0xfffff
    80005fa0:	94e080e7          	jalr	-1714(ra) # 800048ea <end_op>
    return -1;
    80005fa4:	557d                	li	a0,-1
    80005fa6:	b761                	j	80005f2e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005fa8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fac:	04649783          	lh	a5,70(s1)
    80005fb0:	02f99223          	sh	a5,36(s3)
    80005fb4:	bf25                	j	80005eec <sys_open+0xa2>
    itrunc(ip);
    80005fb6:	8526                	mv	a0,s1
    80005fb8:	ffffe097          	auipc	ra,0xffffe
    80005fbc:	ff6080e7          	jalr	-10(ra) # 80003fae <itrunc>
    80005fc0:	bfa9                	j	80005f1a <sys_open+0xd0>
      fileclose(f);
    80005fc2:	854e                	mv	a0,s3
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	d70080e7          	jalr	-656(ra) # 80004d34 <fileclose>
    iunlockput(ip);
    80005fcc:	8526                	mv	a0,s1
    80005fce:	ffffe097          	auipc	ra,0xffffe
    80005fd2:	134080e7          	jalr	308(ra) # 80004102 <iunlockput>
    end_op();
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	914080e7          	jalr	-1772(ra) # 800048ea <end_op>
    return -1;
    80005fde:	557d                	li	a0,-1
    80005fe0:	b7b9                	j	80005f2e <sys_open+0xe4>

0000000080005fe2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fe2:	7175                	addi	sp,sp,-144
    80005fe4:	e506                	sd	ra,136(sp)
    80005fe6:	e122                	sd	s0,128(sp)
    80005fe8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005fea:	fffff097          	auipc	ra,0xfffff
    80005fee:	882080e7          	jalr	-1918(ra) # 8000486c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ff2:	08000613          	li	a2,128
    80005ff6:	f7040593          	addi	a1,s0,-144
    80005ffa:	4501                	li	a0,0
    80005ffc:	ffffd097          	auipc	ra,0xffffd
    80006000:	24e080e7          	jalr	590(ra) # 8000324a <argstr>
    80006004:	02054963          	bltz	a0,80006036 <sys_mkdir+0x54>
    80006008:	4681                	li	a3,0
    8000600a:	4601                	li	a2,0
    8000600c:	4585                	li	a1,1
    8000600e:	f7040513          	addi	a0,s0,-144
    80006012:	fffff097          	auipc	ra,0xfffff
    80006016:	7fc080e7          	jalr	2044(ra) # 8000580e <create>
    8000601a:	cd11                	beqz	a0,80006036 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000601c:	ffffe097          	auipc	ra,0xffffe
    80006020:	0e6080e7          	jalr	230(ra) # 80004102 <iunlockput>
  end_op();
    80006024:	fffff097          	auipc	ra,0xfffff
    80006028:	8c6080e7          	jalr	-1850(ra) # 800048ea <end_op>
  return 0;
    8000602c:	4501                	li	a0,0
}
    8000602e:	60aa                	ld	ra,136(sp)
    80006030:	640a                	ld	s0,128(sp)
    80006032:	6149                	addi	sp,sp,144
    80006034:	8082                	ret
    end_op();
    80006036:	fffff097          	auipc	ra,0xfffff
    8000603a:	8b4080e7          	jalr	-1868(ra) # 800048ea <end_op>
    return -1;
    8000603e:	557d                	li	a0,-1
    80006040:	b7fd                	j	8000602e <sys_mkdir+0x4c>

0000000080006042 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006042:	7135                	addi	sp,sp,-160
    80006044:	ed06                	sd	ra,152(sp)
    80006046:	e922                	sd	s0,144(sp)
    80006048:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000604a:	fffff097          	auipc	ra,0xfffff
    8000604e:	822080e7          	jalr	-2014(ra) # 8000486c <begin_op>
  argint(1, &major);
    80006052:	f6c40593          	addi	a1,s0,-148
    80006056:	4505                	li	a0,1
    80006058:	ffffd097          	auipc	ra,0xffffd
    8000605c:	1b2080e7          	jalr	434(ra) # 8000320a <argint>
  argint(2, &minor);
    80006060:	f6840593          	addi	a1,s0,-152
    80006064:	4509                	li	a0,2
    80006066:	ffffd097          	auipc	ra,0xffffd
    8000606a:	1a4080e7          	jalr	420(ra) # 8000320a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000606e:	08000613          	li	a2,128
    80006072:	f7040593          	addi	a1,s0,-144
    80006076:	4501                	li	a0,0
    80006078:	ffffd097          	auipc	ra,0xffffd
    8000607c:	1d2080e7          	jalr	466(ra) # 8000324a <argstr>
    80006080:	02054b63          	bltz	a0,800060b6 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006084:	f6841683          	lh	a3,-152(s0)
    80006088:	f6c41603          	lh	a2,-148(s0)
    8000608c:	458d                	li	a1,3
    8000608e:	f7040513          	addi	a0,s0,-144
    80006092:	fffff097          	auipc	ra,0xfffff
    80006096:	77c080e7          	jalr	1916(ra) # 8000580e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000609a:	cd11                	beqz	a0,800060b6 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000609c:	ffffe097          	auipc	ra,0xffffe
    800060a0:	066080e7          	jalr	102(ra) # 80004102 <iunlockput>
  end_op();
    800060a4:	fffff097          	auipc	ra,0xfffff
    800060a8:	846080e7          	jalr	-1978(ra) # 800048ea <end_op>
  return 0;
    800060ac:	4501                	li	a0,0
}
    800060ae:	60ea                	ld	ra,152(sp)
    800060b0:	644a                	ld	s0,144(sp)
    800060b2:	610d                	addi	sp,sp,160
    800060b4:	8082                	ret
    end_op();
    800060b6:	fffff097          	auipc	ra,0xfffff
    800060ba:	834080e7          	jalr	-1996(ra) # 800048ea <end_op>
    return -1;
    800060be:	557d                	li	a0,-1
    800060c0:	b7fd                	j	800060ae <sys_mknod+0x6c>

00000000800060c2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800060c2:	7135                	addi	sp,sp,-160
    800060c4:	ed06                	sd	ra,152(sp)
    800060c6:	e922                	sd	s0,144(sp)
    800060c8:	e526                	sd	s1,136(sp)
    800060ca:	e14a                	sd	s2,128(sp)
    800060cc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060ce:	ffffc097          	auipc	ra,0xffffc
    800060d2:	cf4080e7          	jalr	-780(ra) # 80001dc2 <myproc>
    800060d6:	892a                	mv	s2,a0
  
  begin_op();
    800060d8:	ffffe097          	auipc	ra,0xffffe
    800060dc:	794080e7          	jalr	1940(ra) # 8000486c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060e0:	08000613          	li	a2,128
    800060e4:	f6040593          	addi	a1,s0,-160
    800060e8:	4501                	li	a0,0
    800060ea:	ffffd097          	auipc	ra,0xffffd
    800060ee:	160080e7          	jalr	352(ra) # 8000324a <argstr>
    800060f2:	04054b63          	bltz	a0,80006148 <sys_chdir+0x86>
    800060f6:	f6040513          	addi	a0,s0,-160
    800060fa:	ffffe097          	auipc	ra,0xffffe
    800060fe:	552080e7          	jalr	1362(ra) # 8000464c <namei>
    80006102:	84aa                	mv	s1,a0
    80006104:	c131                	beqz	a0,80006148 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006106:	ffffe097          	auipc	ra,0xffffe
    8000610a:	d9a080e7          	jalr	-614(ra) # 80003ea0 <ilock>
  if(ip->type != T_DIR){
    8000610e:	04449703          	lh	a4,68(s1)
    80006112:	4785                	li	a5,1
    80006114:	04f71063          	bne	a4,a5,80006154 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006118:	8526                	mv	a0,s1
    8000611a:	ffffe097          	auipc	ra,0xffffe
    8000611e:	e48080e7          	jalr	-440(ra) # 80003f62 <iunlock>
  iput(p->cwd);
    80006122:	15093503          	ld	a0,336(s2)
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	f34080e7          	jalr	-204(ra) # 8000405a <iput>
  end_op();
    8000612e:	ffffe097          	auipc	ra,0xffffe
    80006132:	7bc080e7          	jalr	1980(ra) # 800048ea <end_op>
  p->cwd = ip;
    80006136:	14993823          	sd	s1,336(s2)
  return 0;
    8000613a:	4501                	li	a0,0
}
    8000613c:	60ea                	ld	ra,152(sp)
    8000613e:	644a                	ld	s0,144(sp)
    80006140:	64aa                	ld	s1,136(sp)
    80006142:	690a                	ld	s2,128(sp)
    80006144:	610d                	addi	sp,sp,160
    80006146:	8082                	ret
    end_op();
    80006148:	ffffe097          	auipc	ra,0xffffe
    8000614c:	7a2080e7          	jalr	1954(ra) # 800048ea <end_op>
    return -1;
    80006150:	557d                	li	a0,-1
    80006152:	b7ed                	j	8000613c <sys_chdir+0x7a>
    iunlockput(ip);
    80006154:	8526                	mv	a0,s1
    80006156:	ffffe097          	auipc	ra,0xffffe
    8000615a:	fac080e7          	jalr	-84(ra) # 80004102 <iunlockput>
    end_op();
    8000615e:	ffffe097          	auipc	ra,0xffffe
    80006162:	78c080e7          	jalr	1932(ra) # 800048ea <end_op>
    return -1;
    80006166:	557d                	li	a0,-1
    80006168:	bfd1                	j	8000613c <sys_chdir+0x7a>

000000008000616a <sys_exec>:

uint64
sys_exec(void)
{
    8000616a:	7145                	addi	sp,sp,-464
    8000616c:	e786                	sd	ra,456(sp)
    8000616e:	e3a2                	sd	s0,448(sp)
    80006170:	ff26                	sd	s1,440(sp)
    80006172:	fb4a                	sd	s2,432(sp)
    80006174:	f74e                	sd	s3,424(sp)
    80006176:	f352                	sd	s4,416(sp)
    80006178:	ef56                	sd	s5,408(sp)
    8000617a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000617c:	e3840593          	addi	a1,s0,-456
    80006180:	4505                	li	a0,1
    80006182:	ffffd097          	auipc	ra,0xffffd
    80006186:	0a8080e7          	jalr	168(ra) # 8000322a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000618a:	08000613          	li	a2,128
    8000618e:	f4040593          	addi	a1,s0,-192
    80006192:	4501                	li	a0,0
    80006194:	ffffd097          	auipc	ra,0xffffd
    80006198:	0b6080e7          	jalr	182(ra) # 8000324a <argstr>
    8000619c:	87aa                	mv	a5,a0
    return -1;
    8000619e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800061a0:	0c07c363          	bltz	a5,80006266 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800061a4:	10000613          	li	a2,256
    800061a8:	4581                	li	a1,0
    800061aa:	e4040513          	addi	a0,s0,-448
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	de4080e7          	jalr	-540(ra) # 80000f92 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061b6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061ba:	89a6                	mv	s3,s1
    800061bc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061be:	02000a13          	li	s4,32
    800061c2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061c6:	00391513          	slli	a0,s2,0x3
    800061ca:	e3040593          	addi	a1,s0,-464
    800061ce:	e3843783          	ld	a5,-456(s0)
    800061d2:	953e                	add	a0,a0,a5
    800061d4:	ffffd097          	auipc	ra,0xffffd
    800061d8:	f98080e7          	jalr	-104(ra) # 8000316c <fetchaddr>
    800061dc:	02054a63          	bltz	a0,80006210 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800061e0:	e3043783          	ld	a5,-464(s0)
    800061e4:	c3b9                	beqz	a5,8000622a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061e6:	ffffb097          	auipc	ra,0xffffb
    800061ea:	b26080e7          	jalr	-1242(ra) # 80000d0c <kalloc>
    800061ee:	85aa                	mv	a1,a0
    800061f0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061f4:	cd11                	beqz	a0,80006210 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061f6:	6605                	lui	a2,0x1
    800061f8:	e3043503          	ld	a0,-464(s0)
    800061fc:	ffffd097          	auipc	ra,0xffffd
    80006200:	fc2080e7          	jalr	-62(ra) # 800031be <fetchstr>
    80006204:	00054663          	bltz	a0,80006210 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006208:	0905                	addi	s2,s2,1
    8000620a:	09a1                	addi	s3,s3,8
    8000620c:	fb491be3          	bne	s2,s4,800061c2 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006210:	f4040913          	addi	s2,s0,-192
    80006214:	6088                	ld	a0,0(s1)
    80006216:	c539                	beqz	a0,80006264 <sys_exec+0xfa>
    kfree(argv[i]);
    80006218:	ffffb097          	auipc	ra,0xffffb
    8000621c:	902080e7          	jalr	-1790(ra) # 80000b1a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006220:	04a1                	addi	s1,s1,8
    80006222:	ff2499e3          	bne	s1,s2,80006214 <sys_exec+0xaa>
  return -1;
    80006226:	557d                	li	a0,-1
    80006228:	a83d                	j	80006266 <sys_exec+0xfc>
      argv[i] = 0;
    8000622a:	0a8e                	slli	s5,s5,0x3
    8000622c:	fc0a8793          	addi	a5,s5,-64
    80006230:	00878ab3          	add	s5,a5,s0
    80006234:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006238:	e4040593          	addi	a1,s0,-448
    8000623c:	f4040513          	addi	a0,s0,-192
    80006240:	fffff097          	auipc	ra,0xfffff
    80006244:	16e080e7          	jalr	366(ra) # 800053ae <exec>
    80006248:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000624a:	f4040993          	addi	s3,s0,-192
    8000624e:	6088                	ld	a0,0(s1)
    80006250:	c901                	beqz	a0,80006260 <sys_exec+0xf6>
    kfree(argv[i]);
    80006252:	ffffb097          	auipc	ra,0xffffb
    80006256:	8c8080e7          	jalr	-1848(ra) # 80000b1a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000625a:	04a1                	addi	s1,s1,8
    8000625c:	ff3499e3          	bne	s1,s3,8000624e <sys_exec+0xe4>
  return ret;
    80006260:	854a                	mv	a0,s2
    80006262:	a011                	j	80006266 <sys_exec+0xfc>
  return -1;
    80006264:	557d                	li	a0,-1
}
    80006266:	60be                	ld	ra,456(sp)
    80006268:	641e                	ld	s0,448(sp)
    8000626a:	74fa                	ld	s1,440(sp)
    8000626c:	795a                	ld	s2,432(sp)
    8000626e:	79ba                	ld	s3,424(sp)
    80006270:	7a1a                	ld	s4,416(sp)
    80006272:	6afa                	ld	s5,408(sp)
    80006274:	6179                	addi	sp,sp,464
    80006276:	8082                	ret

0000000080006278 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006278:	7139                	addi	sp,sp,-64
    8000627a:	fc06                	sd	ra,56(sp)
    8000627c:	f822                	sd	s0,48(sp)
    8000627e:	f426                	sd	s1,40(sp)
    80006280:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006282:	ffffc097          	auipc	ra,0xffffc
    80006286:	b40080e7          	jalr	-1216(ra) # 80001dc2 <myproc>
    8000628a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000628c:	fd840593          	addi	a1,s0,-40
    80006290:	4501                	li	a0,0
    80006292:	ffffd097          	auipc	ra,0xffffd
    80006296:	f98080e7          	jalr	-104(ra) # 8000322a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000629a:	fc840593          	addi	a1,s0,-56
    8000629e:	fd040513          	addi	a0,s0,-48
    800062a2:	fffff097          	auipc	ra,0xfffff
    800062a6:	dc2080e7          	jalr	-574(ra) # 80005064 <pipealloc>
    return -1;
    800062aa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062ac:	0c054463          	bltz	a0,80006374 <sys_pipe+0xfc>
  fd0 = -1;
    800062b0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062b4:	fd043503          	ld	a0,-48(s0)
    800062b8:	fffff097          	auipc	ra,0xfffff
    800062bc:	514080e7          	jalr	1300(ra) # 800057cc <fdalloc>
    800062c0:	fca42223          	sw	a0,-60(s0)
    800062c4:	08054b63          	bltz	a0,8000635a <sys_pipe+0xe2>
    800062c8:	fc843503          	ld	a0,-56(s0)
    800062cc:	fffff097          	auipc	ra,0xfffff
    800062d0:	500080e7          	jalr	1280(ra) # 800057cc <fdalloc>
    800062d4:	fca42023          	sw	a0,-64(s0)
    800062d8:	06054863          	bltz	a0,80006348 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062dc:	4691                	li	a3,4
    800062de:	fc440613          	addi	a2,s0,-60
    800062e2:	fd843583          	ld	a1,-40(s0)
    800062e6:	68a8                	ld	a0,80(s1)
    800062e8:	ffffb097          	auipc	ra,0xffffb
    800062ec:	640080e7          	jalr	1600(ra) # 80001928 <copyout>
    800062f0:	02054063          	bltz	a0,80006310 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062f4:	4691                	li	a3,4
    800062f6:	fc040613          	addi	a2,s0,-64
    800062fa:	fd843583          	ld	a1,-40(s0)
    800062fe:	0591                	addi	a1,a1,4
    80006300:	68a8                	ld	a0,80(s1)
    80006302:	ffffb097          	auipc	ra,0xffffb
    80006306:	626080e7          	jalr	1574(ra) # 80001928 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000630a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000630c:	06055463          	bgez	a0,80006374 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006310:	fc442783          	lw	a5,-60(s0)
    80006314:	07e9                	addi	a5,a5,26
    80006316:	078e                	slli	a5,a5,0x3
    80006318:	97a6                	add	a5,a5,s1
    8000631a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000631e:	fc042783          	lw	a5,-64(s0)
    80006322:	07e9                	addi	a5,a5,26
    80006324:	078e                	slli	a5,a5,0x3
    80006326:	94be                	add	s1,s1,a5
    80006328:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000632c:	fd043503          	ld	a0,-48(s0)
    80006330:	fffff097          	auipc	ra,0xfffff
    80006334:	a04080e7          	jalr	-1532(ra) # 80004d34 <fileclose>
    fileclose(wf);
    80006338:	fc843503          	ld	a0,-56(s0)
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	9f8080e7          	jalr	-1544(ra) # 80004d34 <fileclose>
    return -1;
    80006344:	57fd                	li	a5,-1
    80006346:	a03d                	j	80006374 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006348:	fc442783          	lw	a5,-60(s0)
    8000634c:	0007c763          	bltz	a5,8000635a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006350:	07e9                	addi	a5,a5,26
    80006352:	078e                	slli	a5,a5,0x3
    80006354:	97a6                	add	a5,a5,s1
    80006356:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000635a:	fd043503          	ld	a0,-48(s0)
    8000635e:	fffff097          	auipc	ra,0xfffff
    80006362:	9d6080e7          	jalr	-1578(ra) # 80004d34 <fileclose>
    fileclose(wf);
    80006366:	fc843503          	ld	a0,-56(s0)
    8000636a:	fffff097          	auipc	ra,0xfffff
    8000636e:	9ca080e7          	jalr	-1590(ra) # 80004d34 <fileclose>
    return -1;
    80006372:	57fd                	li	a5,-1
}
    80006374:	853e                	mv	a0,a5
    80006376:	70e2                	ld	ra,56(sp)
    80006378:	7442                	ld	s0,48(sp)
    8000637a:	74a2                	ld	s1,40(sp)
    8000637c:	6121                	addi	sp,sp,64
    8000637e:	8082                	ret

0000000080006380 <kernelvec>:
    80006380:	7111                	addi	sp,sp,-256
    80006382:	e006                	sd	ra,0(sp)
    80006384:	e40a                	sd	sp,8(sp)
    80006386:	e80e                	sd	gp,16(sp)
    80006388:	ec12                	sd	tp,24(sp)
    8000638a:	f016                	sd	t0,32(sp)
    8000638c:	f41a                	sd	t1,40(sp)
    8000638e:	f81e                	sd	t2,48(sp)
    80006390:	fc22                	sd	s0,56(sp)
    80006392:	e0a6                	sd	s1,64(sp)
    80006394:	e4aa                	sd	a0,72(sp)
    80006396:	e8ae                	sd	a1,80(sp)
    80006398:	ecb2                	sd	a2,88(sp)
    8000639a:	f0b6                	sd	a3,96(sp)
    8000639c:	f4ba                	sd	a4,104(sp)
    8000639e:	f8be                	sd	a5,112(sp)
    800063a0:	fcc2                	sd	a6,120(sp)
    800063a2:	e146                	sd	a7,128(sp)
    800063a4:	e54a                	sd	s2,136(sp)
    800063a6:	e94e                	sd	s3,144(sp)
    800063a8:	ed52                	sd	s4,152(sp)
    800063aa:	f156                	sd	s5,160(sp)
    800063ac:	f55a                	sd	s6,168(sp)
    800063ae:	f95e                	sd	s7,176(sp)
    800063b0:	fd62                	sd	s8,184(sp)
    800063b2:	e1e6                	sd	s9,192(sp)
    800063b4:	e5ea                	sd	s10,200(sp)
    800063b6:	e9ee                	sd	s11,208(sp)
    800063b8:	edf2                	sd	t3,216(sp)
    800063ba:	f1f6                	sd	t4,224(sp)
    800063bc:	f5fa                	sd	t5,232(sp)
    800063be:	f9fe                	sd	t6,240(sp)
    800063c0:	c79fc0ef          	jal	ra,80003038 <kerneltrap>
    800063c4:	6082                	ld	ra,0(sp)
    800063c6:	6122                	ld	sp,8(sp)
    800063c8:	61c2                	ld	gp,16(sp)
    800063ca:	7282                	ld	t0,32(sp)
    800063cc:	7322                	ld	t1,40(sp)
    800063ce:	73c2                	ld	t2,48(sp)
    800063d0:	7462                	ld	s0,56(sp)
    800063d2:	6486                	ld	s1,64(sp)
    800063d4:	6526                	ld	a0,72(sp)
    800063d6:	65c6                	ld	a1,80(sp)
    800063d8:	6666                	ld	a2,88(sp)
    800063da:	7686                	ld	a3,96(sp)
    800063dc:	7726                	ld	a4,104(sp)
    800063de:	77c6                	ld	a5,112(sp)
    800063e0:	7866                	ld	a6,120(sp)
    800063e2:	688a                	ld	a7,128(sp)
    800063e4:	692a                	ld	s2,136(sp)
    800063e6:	69ca                	ld	s3,144(sp)
    800063e8:	6a6a                	ld	s4,152(sp)
    800063ea:	7a8a                	ld	s5,160(sp)
    800063ec:	7b2a                	ld	s6,168(sp)
    800063ee:	7bca                	ld	s7,176(sp)
    800063f0:	7c6a                	ld	s8,184(sp)
    800063f2:	6c8e                	ld	s9,192(sp)
    800063f4:	6d2e                	ld	s10,200(sp)
    800063f6:	6dce                	ld	s11,208(sp)
    800063f8:	6e6e                	ld	t3,216(sp)
    800063fa:	7e8e                	ld	t4,224(sp)
    800063fc:	7f2e                	ld	t5,232(sp)
    800063fe:	7fce                	ld	t6,240(sp)
    80006400:	6111                	addi	sp,sp,256
    80006402:	10200073          	sret
    80006406:	00000013          	nop
    8000640a:	00000013          	nop
    8000640e:	0001                	nop

0000000080006410 <timervec>:
    80006410:	34051573          	csrrw	a0,mscratch,a0
    80006414:	e10c                	sd	a1,0(a0)
    80006416:	e510                	sd	a2,8(a0)
    80006418:	e914                	sd	a3,16(a0)
    8000641a:	6d0c                	ld	a1,24(a0)
    8000641c:	7110                	ld	a2,32(a0)
    8000641e:	6194                	ld	a3,0(a1)
    80006420:	96b2                	add	a3,a3,a2
    80006422:	e194                	sd	a3,0(a1)
    80006424:	4589                	li	a1,2
    80006426:	14459073          	csrw	sip,a1
    8000642a:	6914                	ld	a3,16(a0)
    8000642c:	6510                	ld	a2,8(a0)
    8000642e:	610c                	ld	a1,0(a0)
    80006430:	34051573          	csrrw	a0,mscratch,a0
    80006434:	30200073          	mret
	...

000000008000643a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000643a:	1141                	addi	sp,sp,-16
    8000643c:	e422                	sd	s0,8(sp)
    8000643e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006440:	0c0007b7          	lui	a5,0xc000
    80006444:	4705                	li	a4,1
    80006446:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006448:	c3d8                	sw	a4,4(a5)
}
    8000644a:	6422                	ld	s0,8(sp)
    8000644c:	0141                	addi	sp,sp,16
    8000644e:	8082                	ret

0000000080006450 <plicinithart>:

void
plicinithart(void)
{
    80006450:	1141                	addi	sp,sp,-16
    80006452:	e406                	sd	ra,8(sp)
    80006454:	e022                	sd	s0,0(sp)
    80006456:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006458:	ffffc097          	auipc	ra,0xffffc
    8000645c:	93e080e7          	jalr	-1730(ra) # 80001d96 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006460:	0085171b          	slliw	a4,a0,0x8
    80006464:	0c0027b7          	lui	a5,0xc002
    80006468:	97ba                	add	a5,a5,a4
    8000646a:	40200713          	li	a4,1026
    8000646e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006472:	00d5151b          	slliw	a0,a0,0xd
    80006476:	0c2017b7          	lui	a5,0xc201
    8000647a:	97aa                	add	a5,a5,a0
    8000647c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006480:	60a2                	ld	ra,8(sp)
    80006482:	6402                	ld	s0,0(sp)
    80006484:	0141                	addi	sp,sp,16
    80006486:	8082                	ret

0000000080006488 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006488:	1141                	addi	sp,sp,-16
    8000648a:	e406                	sd	ra,8(sp)
    8000648c:	e022                	sd	s0,0(sp)
    8000648e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006490:	ffffc097          	auipc	ra,0xffffc
    80006494:	906080e7          	jalr	-1786(ra) # 80001d96 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006498:	00d5151b          	slliw	a0,a0,0xd
    8000649c:	0c2017b7          	lui	a5,0xc201
    800064a0:	97aa                	add	a5,a5,a0
  return irq;
}
    800064a2:	43c8                	lw	a0,4(a5)
    800064a4:	60a2                	ld	ra,8(sp)
    800064a6:	6402                	ld	s0,0(sp)
    800064a8:	0141                	addi	sp,sp,16
    800064aa:	8082                	ret

00000000800064ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064ac:	1101                	addi	sp,sp,-32
    800064ae:	ec06                	sd	ra,24(sp)
    800064b0:	e822                	sd	s0,16(sp)
    800064b2:	e426                	sd	s1,8(sp)
    800064b4:	1000                	addi	s0,sp,32
    800064b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064b8:	ffffc097          	auipc	ra,0xffffc
    800064bc:	8de080e7          	jalr	-1826(ra) # 80001d96 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064c0:	00d5151b          	slliw	a0,a0,0xd
    800064c4:	0c2017b7          	lui	a5,0xc201
    800064c8:	97aa                	add	a5,a5,a0
    800064ca:	c3c4                	sw	s1,4(a5)
}
    800064cc:	60e2                	ld	ra,24(sp)
    800064ce:	6442                	ld	s0,16(sp)
    800064d0:	64a2                	ld	s1,8(sp)
    800064d2:	6105                	addi	sp,sp,32
    800064d4:	8082                	ret

00000000800064d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064d6:	1141                	addi	sp,sp,-16
    800064d8:	e406                	sd	ra,8(sp)
    800064da:	e022                	sd	s0,0(sp)
    800064dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064de:	479d                	li	a5,7
    800064e0:	04a7cc63          	blt	a5,a0,80006538 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800064e4:	0003c797          	auipc	a5,0x3c
    800064e8:	8f478793          	addi	a5,a5,-1804 # 80041dd8 <disk>
    800064ec:	97aa                	add	a5,a5,a0
    800064ee:	0187c783          	lbu	a5,24(a5)
    800064f2:	ebb9                	bnez	a5,80006548 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800064f4:	00451693          	slli	a3,a0,0x4
    800064f8:	0003c797          	auipc	a5,0x3c
    800064fc:	8e078793          	addi	a5,a5,-1824 # 80041dd8 <disk>
    80006500:	6398                	ld	a4,0(a5)
    80006502:	9736                	add	a4,a4,a3
    80006504:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006508:	6398                	ld	a4,0(a5)
    8000650a:	9736                	add	a4,a4,a3
    8000650c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006510:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006514:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006518:	97aa                	add	a5,a5,a0
    8000651a:	4705                	li	a4,1
    8000651c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006520:	0003c517          	auipc	a0,0x3c
    80006524:	8d050513          	addi	a0,a0,-1840 # 80041df0 <disk+0x18>
    80006528:	ffffc097          	auipc	ra,0xffffc
    8000652c:	0ac080e7          	jalr	172(ra) # 800025d4 <wakeup>
}
    80006530:	60a2                	ld	ra,8(sp)
    80006532:	6402                	ld	s0,0(sp)
    80006534:	0141                	addi	sp,sp,16
    80006536:	8082                	ret
    panic("free_desc 1");
    80006538:	00002517          	auipc	a0,0x2
    8000653c:	36850513          	addi	a0,a0,872 # 800088a0 <syscalls+0x318>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	000080e7          	jalr	ra # 80000540 <panic>
    panic("free_desc 2");
    80006548:	00002517          	auipc	a0,0x2
    8000654c:	36850513          	addi	a0,a0,872 # 800088b0 <syscalls+0x328>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	ff0080e7          	jalr	-16(ra) # 80000540 <panic>

0000000080006558 <virtio_disk_init>:
{
    80006558:	1101                	addi	sp,sp,-32
    8000655a:	ec06                	sd	ra,24(sp)
    8000655c:	e822                	sd	s0,16(sp)
    8000655e:	e426                	sd	s1,8(sp)
    80006560:	e04a                	sd	s2,0(sp)
    80006562:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006564:	00002597          	auipc	a1,0x2
    80006568:	35c58593          	addi	a1,a1,860 # 800088c0 <syscalls+0x338>
    8000656c:	0003c517          	auipc	a0,0x3c
    80006570:	99450513          	addi	a0,a0,-1644 # 80041f00 <disk+0x128>
    80006574:	ffffb097          	auipc	ra,0xffffb
    80006578:	892080e7          	jalr	-1902(ra) # 80000e06 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000657c:	100017b7          	lui	a5,0x10001
    80006580:	4398                	lw	a4,0(a5)
    80006582:	2701                	sext.w	a4,a4
    80006584:	747277b7          	lui	a5,0x74727
    80006588:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000658c:	14f71b63          	bne	a4,a5,800066e2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006590:	100017b7          	lui	a5,0x10001
    80006594:	43dc                	lw	a5,4(a5)
    80006596:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006598:	4709                	li	a4,2
    8000659a:	14e79463          	bne	a5,a4,800066e2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000659e:	100017b7          	lui	a5,0x10001
    800065a2:	479c                	lw	a5,8(a5)
    800065a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065a6:	12e79e63          	bne	a5,a4,800066e2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065aa:	100017b7          	lui	a5,0x10001
    800065ae:	47d8                	lw	a4,12(a5)
    800065b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065b2:	554d47b7          	lui	a5,0x554d4
    800065b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065ba:	12f71463          	bne	a4,a5,800066e2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065be:	100017b7          	lui	a5,0x10001
    800065c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065c6:	4705                	li	a4,1
    800065c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ca:	470d                	li	a4,3
    800065cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065ce:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800065d0:	c7ffe6b7          	lui	a3,0xc7ffe
    800065d4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc847>
    800065d8:	8f75                	and	a4,a4,a3
    800065da:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065dc:	472d                	li	a4,11
    800065de:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800065e0:	5bbc                	lw	a5,112(a5)
    800065e2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800065e6:	8ba1                	andi	a5,a5,8
    800065e8:	10078563          	beqz	a5,800066f2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800065ec:	100017b7          	lui	a5,0x10001
    800065f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800065f4:	43fc                	lw	a5,68(a5)
    800065f6:	2781                	sext.w	a5,a5
    800065f8:	10079563          	bnez	a5,80006702 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800065fc:	100017b7          	lui	a5,0x10001
    80006600:	5bdc                	lw	a5,52(a5)
    80006602:	2781                	sext.w	a5,a5
  if(max == 0)
    80006604:	10078763          	beqz	a5,80006712 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006608:	471d                	li	a4,7
    8000660a:	10f77c63          	bgeu	a4,a5,80006722 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000660e:	ffffa097          	auipc	ra,0xffffa
    80006612:	6fe080e7          	jalr	1790(ra) # 80000d0c <kalloc>
    80006616:	0003b497          	auipc	s1,0x3b
    8000661a:	7c248493          	addi	s1,s1,1986 # 80041dd8 <disk>
    8000661e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	6ec080e7          	jalr	1772(ra) # 80000d0c <kalloc>
    80006628:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	6e2080e7          	jalr	1762(ra) # 80000d0c <kalloc>
    80006632:	87aa                	mv	a5,a0
    80006634:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006636:	6088                	ld	a0,0(s1)
    80006638:	cd6d                	beqz	a0,80006732 <virtio_disk_init+0x1da>
    8000663a:	0003b717          	auipc	a4,0x3b
    8000663e:	7a673703          	ld	a4,1958(a4) # 80041de0 <disk+0x8>
    80006642:	cb65                	beqz	a4,80006732 <virtio_disk_init+0x1da>
    80006644:	c7fd                	beqz	a5,80006732 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006646:	6605                	lui	a2,0x1
    80006648:	4581                	li	a1,0
    8000664a:	ffffb097          	auipc	ra,0xffffb
    8000664e:	948080e7          	jalr	-1720(ra) # 80000f92 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006652:	0003b497          	auipc	s1,0x3b
    80006656:	78648493          	addi	s1,s1,1926 # 80041dd8 <disk>
    8000665a:	6605                	lui	a2,0x1
    8000665c:	4581                	li	a1,0
    8000665e:	6488                	ld	a0,8(s1)
    80006660:	ffffb097          	auipc	ra,0xffffb
    80006664:	932080e7          	jalr	-1742(ra) # 80000f92 <memset>
  memset(disk.used, 0, PGSIZE);
    80006668:	6605                	lui	a2,0x1
    8000666a:	4581                	li	a1,0
    8000666c:	6888                	ld	a0,16(s1)
    8000666e:	ffffb097          	auipc	ra,0xffffb
    80006672:	924080e7          	jalr	-1756(ra) # 80000f92 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006676:	100017b7          	lui	a5,0x10001
    8000667a:	4721                	li	a4,8
    8000667c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000667e:	4098                	lw	a4,0(s1)
    80006680:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006684:	40d8                	lw	a4,4(s1)
    80006686:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000668a:	6498                	ld	a4,8(s1)
    8000668c:	0007069b          	sext.w	a3,a4
    80006690:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006694:	9701                	srai	a4,a4,0x20
    80006696:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000669a:	6898                	ld	a4,16(s1)
    8000669c:	0007069b          	sext.w	a3,a4
    800066a0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066a4:	9701                	srai	a4,a4,0x20
    800066a6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800066aa:	4705                	li	a4,1
    800066ac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800066ae:	00e48c23          	sb	a4,24(s1)
    800066b2:	00e48ca3          	sb	a4,25(s1)
    800066b6:	00e48d23          	sb	a4,26(s1)
    800066ba:	00e48da3          	sb	a4,27(s1)
    800066be:	00e48e23          	sb	a4,28(s1)
    800066c2:	00e48ea3          	sb	a4,29(s1)
    800066c6:	00e48f23          	sb	a4,30(s1)
    800066ca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800066ce:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800066d2:	0727a823          	sw	s2,112(a5)
}
    800066d6:	60e2                	ld	ra,24(sp)
    800066d8:	6442                	ld	s0,16(sp)
    800066da:	64a2                	ld	s1,8(sp)
    800066dc:	6902                	ld	s2,0(sp)
    800066de:	6105                	addi	sp,sp,32
    800066e0:	8082                	ret
    panic("could not find virtio disk");
    800066e2:	00002517          	auipc	a0,0x2
    800066e6:	1ee50513          	addi	a0,a0,494 # 800088d0 <syscalls+0x348>
    800066ea:	ffffa097          	auipc	ra,0xffffa
    800066ee:	e56080e7          	jalr	-426(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    800066f2:	00002517          	auipc	a0,0x2
    800066f6:	1fe50513          	addi	a0,a0,510 # 800088f0 <syscalls+0x368>
    800066fa:	ffffa097          	auipc	ra,0xffffa
    800066fe:	e46080e7          	jalr	-442(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006702:	00002517          	auipc	a0,0x2
    80006706:	20e50513          	addi	a0,a0,526 # 80008910 <syscalls+0x388>
    8000670a:	ffffa097          	auipc	ra,0xffffa
    8000670e:	e36080e7          	jalr	-458(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006712:	00002517          	auipc	a0,0x2
    80006716:	21e50513          	addi	a0,a0,542 # 80008930 <syscalls+0x3a8>
    8000671a:	ffffa097          	auipc	ra,0xffffa
    8000671e:	e26080e7          	jalr	-474(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006722:	00002517          	auipc	a0,0x2
    80006726:	22e50513          	addi	a0,a0,558 # 80008950 <syscalls+0x3c8>
    8000672a:	ffffa097          	auipc	ra,0xffffa
    8000672e:	e16080e7          	jalr	-490(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006732:	00002517          	auipc	a0,0x2
    80006736:	23e50513          	addi	a0,a0,574 # 80008970 <syscalls+0x3e8>
    8000673a:	ffffa097          	auipc	ra,0xffffa
    8000673e:	e06080e7          	jalr	-506(ra) # 80000540 <panic>

0000000080006742 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006742:	7119                	addi	sp,sp,-128
    80006744:	fc86                	sd	ra,120(sp)
    80006746:	f8a2                	sd	s0,112(sp)
    80006748:	f4a6                	sd	s1,104(sp)
    8000674a:	f0ca                	sd	s2,96(sp)
    8000674c:	ecce                	sd	s3,88(sp)
    8000674e:	e8d2                	sd	s4,80(sp)
    80006750:	e4d6                	sd	s5,72(sp)
    80006752:	e0da                	sd	s6,64(sp)
    80006754:	fc5e                	sd	s7,56(sp)
    80006756:	f862                	sd	s8,48(sp)
    80006758:	f466                	sd	s9,40(sp)
    8000675a:	f06a                	sd	s10,32(sp)
    8000675c:	ec6e                	sd	s11,24(sp)
    8000675e:	0100                	addi	s0,sp,128
    80006760:	8aaa                	mv	s5,a0
    80006762:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006764:	00c52d03          	lw	s10,12(a0)
    80006768:	001d1d1b          	slliw	s10,s10,0x1
    8000676c:	1d02                	slli	s10,s10,0x20
    8000676e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006772:	0003b517          	auipc	a0,0x3b
    80006776:	78e50513          	addi	a0,a0,1934 # 80041f00 <disk+0x128>
    8000677a:	ffffa097          	auipc	ra,0xffffa
    8000677e:	71c080e7          	jalr	1820(ra) # 80000e96 <acquire>
  for(int i = 0; i < 3; i++){
    80006782:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006784:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006786:	0003bb97          	auipc	s7,0x3b
    8000678a:	652b8b93          	addi	s7,s7,1618 # 80041dd8 <disk>
  for(int i = 0; i < 3; i++){
    8000678e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006790:	0003bc97          	auipc	s9,0x3b
    80006794:	770c8c93          	addi	s9,s9,1904 # 80041f00 <disk+0x128>
    80006798:	a08d                	j	800067fa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000679a:	00fb8733          	add	a4,s7,a5
    8000679e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800067a2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067a4:	0207c563          	bltz	a5,800067ce <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800067a8:	2905                	addiw	s2,s2,1
    800067aa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800067ac:	05690c63          	beq	s2,s6,80006804 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800067b0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800067b2:	0003b717          	auipc	a4,0x3b
    800067b6:	62670713          	addi	a4,a4,1574 # 80041dd8 <disk>
    800067ba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800067bc:	01874683          	lbu	a3,24(a4)
    800067c0:	fee9                	bnez	a3,8000679a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800067c2:	2785                	addiw	a5,a5,1
    800067c4:	0705                	addi	a4,a4,1
    800067c6:	fe979be3          	bne	a5,s1,800067bc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800067ca:	57fd                	li	a5,-1
    800067cc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800067ce:	01205d63          	blez	s2,800067e8 <virtio_disk_rw+0xa6>
    800067d2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800067d4:	000a2503          	lw	a0,0(s4)
    800067d8:	00000097          	auipc	ra,0x0
    800067dc:	cfe080e7          	jalr	-770(ra) # 800064d6 <free_desc>
      for(int j = 0; j < i; j++)
    800067e0:	2d85                	addiw	s11,s11,1
    800067e2:	0a11                	addi	s4,s4,4
    800067e4:	ff2d98e3          	bne	s11,s2,800067d4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067e8:	85e6                	mv	a1,s9
    800067ea:	0003b517          	auipc	a0,0x3b
    800067ee:	60650513          	addi	a0,a0,1542 # 80041df0 <disk+0x18>
    800067f2:	ffffc097          	auipc	ra,0xffffc
    800067f6:	d7e080e7          	jalr	-642(ra) # 80002570 <sleep>
  for(int i = 0; i < 3; i++){
    800067fa:	f8040a13          	addi	s4,s0,-128
{
    800067fe:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006800:	894e                	mv	s2,s3
    80006802:	b77d                	j	800067b0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006804:	f8042503          	lw	a0,-128(s0)
    80006808:	00a50713          	addi	a4,a0,10
    8000680c:	0712                	slli	a4,a4,0x4

  if(write)
    8000680e:	0003b797          	auipc	a5,0x3b
    80006812:	5ca78793          	addi	a5,a5,1482 # 80041dd8 <disk>
    80006816:	00e786b3          	add	a3,a5,a4
    8000681a:	01803633          	snez	a2,s8
    8000681e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006820:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006824:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006828:	f6070613          	addi	a2,a4,-160
    8000682c:	6394                	ld	a3,0(a5)
    8000682e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006830:	00870593          	addi	a1,a4,8
    80006834:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006836:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006838:	0007b803          	ld	a6,0(a5)
    8000683c:	9642                	add	a2,a2,a6
    8000683e:	46c1                	li	a3,16
    80006840:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006842:	4585                	li	a1,1
    80006844:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006848:	f8442683          	lw	a3,-124(s0)
    8000684c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006850:	0692                	slli	a3,a3,0x4
    80006852:	9836                	add	a6,a6,a3
    80006854:	058a8613          	addi	a2,s5,88
    80006858:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000685c:	0007b803          	ld	a6,0(a5)
    80006860:	96c2                	add	a3,a3,a6
    80006862:	40000613          	li	a2,1024
    80006866:	c690                	sw	a2,8(a3)
  if(write)
    80006868:	001c3613          	seqz	a2,s8
    8000686c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006870:	00166613          	ori	a2,a2,1
    80006874:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006878:	f8842603          	lw	a2,-120(s0)
    8000687c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006880:	00250693          	addi	a3,a0,2
    80006884:	0692                	slli	a3,a3,0x4
    80006886:	96be                	add	a3,a3,a5
    80006888:	58fd                	li	a7,-1
    8000688a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000688e:	0612                	slli	a2,a2,0x4
    80006890:	9832                	add	a6,a6,a2
    80006892:	f9070713          	addi	a4,a4,-112
    80006896:	973e                	add	a4,a4,a5
    80006898:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000689c:	6398                	ld	a4,0(a5)
    8000689e:	9732                	add	a4,a4,a2
    800068a0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068a2:	4609                	li	a2,2
    800068a4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800068a8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068ac:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800068b0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800068b4:	6794                	ld	a3,8(a5)
    800068b6:	0026d703          	lhu	a4,2(a3)
    800068ba:	8b1d                	andi	a4,a4,7
    800068bc:	0706                	slli	a4,a4,0x1
    800068be:	96ba                	add	a3,a3,a4
    800068c0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800068c4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800068c8:	6798                	ld	a4,8(a5)
    800068ca:	00275783          	lhu	a5,2(a4)
    800068ce:	2785                	addiw	a5,a5,1
    800068d0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800068d4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800068d8:	100017b7          	lui	a5,0x10001
    800068dc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800068e0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800068e4:	0003b917          	auipc	s2,0x3b
    800068e8:	61c90913          	addi	s2,s2,1564 # 80041f00 <disk+0x128>
  while(b->disk == 1) {
    800068ec:	4485                	li	s1,1
    800068ee:	00b79c63          	bne	a5,a1,80006906 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800068f2:	85ca                	mv	a1,s2
    800068f4:	8556                	mv	a0,s5
    800068f6:	ffffc097          	auipc	ra,0xffffc
    800068fa:	c7a080e7          	jalr	-902(ra) # 80002570 <sleep>
  while(b->disk == 1) {
    800068fe:	004aa783          	lw	a5,4(s5)
    80006902:	fe9788e3          	beq	a5,s1,800068f2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006906:	f8042903          	lw	s2,-128(s0)
    8000690a:	00290713          	addi	a4,s2,2
    8000690e:	0712                	slli	a4,a4,0x4
    80006910:	0003b797          	auipc	a5,0x3b
    80006914:	4c878793          	addi	a5,a5,1224 # 80041dd8 <disk>
    80006918:	97ba                	add	a5,a5,a4
    8000691a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000691e:	0003b997          	auipc	s3,0x3b
    80006922:	4ba98993          	addi	s3,s3,1210 # 80041dd8 <disk>
    80006926:	00491713          	slli	a4,s2,0x4
    8000692a:	0009b783          	ld	a5,0(s3)
    8000692e:	97ba                	add	a5,a5,a4
    80006930:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006934:	854a                	mv	a0,s2
    80006936:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000693a:	00000097          	auipc	ra,0x0
    8000693e:	b9c080e7          	jalr	-1124(ra) # 800064d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006942:	8885                	andi	s1,s1,1
    80006944:	f0ed                	bnez	s1,80006926 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006946:	0003b517          	auipc	a0,0x3b
    8000694a:	5ba50513          	addi	a0,a0,1466 # 80041f00 <disk+0x128>
    8000694e:	ffffa097          	auipc	ra,0xffffa
    80006952:	5fc080e7          	jalr	1532(ra) # 80000f4a <release>
}
    80006956:	70e6                	ld	ra,120(sp)
    80006958:	7446                	ld	s0,112(sp)
    8000695a:	74a6                	ld	s1,104(sp)
    8000695c:	7906                	ld	s2,96(sp)
    8000695e:	69e6                	ld	s3,88(sp)
    80006960:	6a46                	ld	s4,80(sp)
    80006962:	6aa6                	ld	s5,72(sp)
    80006964:	6b06                	ld	s6,64(sp)
    80006966:	7be2                	ld	s7,56(sp)
    80006968:	7c42                	ld	s8,48(sp)
    8000696a:	7ca2                	ld	s9,40(sp)
    8000696c:	7d02                	ld	s10,32(sp)
    8000696e:	6de2                	ld	s11,24(sp)
    80006970:	6109                	addi	sp,sp,128
    80006972:	8082                	ret

0000000080006974 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006974:	1101                	addi	sp,sp,-32
    80006976:	ec06                	sd	ra,24(sp)
    80006978:	e822                	sd	s0,16(sp)
    8000697a:	e426                	sd	s1,8(sp)
    8000697c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000697e:	0003b497          	auipc	s1,0x3b
    80006982:	45a48493          	addi	s1,s1,1114 # 80041dd8 <disk>
    80006986:	0003b517          	auipc	a0,0x3b
    8000698a:	57a50513          	addi	a0,a0,1402 # 80041f00 <disk+0x128>
    8000698e:	ffffa097          	auipc	ra,0xffffa
    80006992:	508080e7          	jalr	1288(ra) # 80000e96 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006996:	10001737          	lui	a4,0x10001
    8000699a:	533c                	lw	a5,96(a4)
    8000699c:	8b8d                	andi	a5,a5,3
    8000699e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800069a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069a4:	689c                	ld	a5,16(s1)
    800069a6:	0204d703          	lhu	a4,32(s1)
    800069aa:	0027d783          	lhu	a5,2(a5)
    800069ae:	04f70863          	beq	a4,a5,800069fe <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800069b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069b6:	6898                	ld	a4,16(s1)
    800069b8:	0204d783          	lhu	a5,32(s1)
    800069bc:	8b9d                	andi	a5,a5,7
    800069be:	078e                	slli	a5,a5,0x3
    800069c0:	97ba                	add	a5,a5,a4
    800069c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069c4:	00278713          	addi	a4,a5,2
    800069c8:	0712                	slli	a4,a4,0x4
    800069ca:	9726                	add	a4,a4,s1
    800069cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800069d0:	e721                	bnez	a4,80006a18 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800069d2:	0789                	addi	a5,a5,2
    800069d4:	0792                	slli	a5,a5,0x4
    800069d6:	97a6                	add	a5,a5,s1
    800069d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800069da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800069de:	ffffc097          	auipc	ra,0xffffc
    800069e2:	bf6080e7          	jalr	-1034(ra) # 800025d4 <wakeup>

    disk.used_idx += 1;
    800069e6:	0204d783          	lhu	a5,32(s1)
    800069ea:	2785                	addiw	a5,a5,1
    800069ec:	17c2                	slli	a5,a5,0x30
    800069ee:	93c1                	srli	a5,a5,0x30
    800069f0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800069f4:	6898                	ld	a4,16(s1)
    800069f6:	00275703          	lhu	a4,2(a4)
    800069fa:	faf71ce3          	bne	a4,a5,800069b2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800069fe:	0003b517          	auipc	a0,0x3b
    80006a02:	50250513          	addi	a0,a0,1282 # 80041f00 <disk+0x128>
    80006a06:	ffffa097          	auipc	ra,0xffffa
    80006a0a:	544080e7          	jalr	1348(ra) # 80000f4a <release>
}
    80006a0e:	60e2                	ld	ra,24(sp)
    80006a10:	6442                	ld	s0,16(sp)
    80006a12:	64a2                	ld	s1,8(sp)
    80006a14:	6105                	addi	sp,sp,32
    80006a16:	8082                	ret
      panic("virtio_disk_intr status");
    80006a18:	00002517          	auipc	a0,0x2
    80006a1c:	f7050513          	addi	a0,a0,-144 # 80008988 <syscalls+0x400>
    80006a20:	ffffa097          	auipc	ra,0xffffa
    80006a24:	b20080e7          	jalr	-1248(ra) # 80000540 <panic>
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
