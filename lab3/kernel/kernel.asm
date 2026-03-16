
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
    80000066:	2de78793          	addi	a5,a5,734 # 80006340 <timervec>
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
    800000b0:	fe878793          	addi	a5,a5,-24 # 80001094 <main>
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
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	7e2080e7          	jalr	2018(ra) # 8000290c <either_copyin>
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
    80000196:	c60080e7          	jalr	-928(ra) # 80000df2 <acquire>
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
    800001c4:	b40080e7          	jalr	-1216(ra) # 80001d00 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	58e080e7          	jalr	1422(ra) # 80002756 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	2d8080e7          	jalr	728(ra) # 800024ae <sleep>
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
    80000216:	6a4080e7          	jalr	1700(ra) # 800028b6 <either_copyout>
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
    80000232:	c78080e7          	jalr	-904(ra) # 80000ea6 <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	99450513          	addi	a0,a0,-1644 # 80010bd0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	c62080e7          	jalr	-926(ra) # 80000ea6 <release>
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
    800002d8:	b1e080e7          	jalr	-1250(ra) # 80000df2 <acquire>

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
    800002f6:	670080e7          	jalr	1648(ra) # 80002962 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	8d650513          	addi	a0,a0,-1834 # 80010bd0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	ba4080e7          	jalr	-1116(ra) # 80000ea6 <release>
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
    8000044a:	0cc080e7          	jalr	204(ra) # 80002512 <wakeup>
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
    8000046c:	8fa080e7          	jalr	-1798(ra) # 80000d62 <initlock>

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
    80000614:	00000097          	auipc	ra,0x0
    80000618:	7de080e7          	jalr	2014(ra) # 80000df2 <acquire>
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
    80000776:	734080e7          	jalr	1844(ra) # 80000ea6 <release>
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
    8000079c:	5ca080e7          	jalr	1482(ra) # 80000d62 <initlock>
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
    800007f2:	574080e7          	jalr	1396(ra) # 80000d62 <initlock>
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
    8000080e:	59c080e7          	jalr	1436(ra) # 80000da6 <push_off>

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
    8000083c:	60e080e7          	jalr	1550(ra) # 80000e46 <pop_off>
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
    800008aa:	c6c080e7          	jalr	-916(ra) # 80002512 <wakeup>
    
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
    800008ee:	508080e7          	jalr	1288(ra) # 80000df2 <acquire>
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
    80000934:	b7e080e7          	jalr	-1154(ra) # 800024ae <sleep>
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
    80000970:	53a080e7          	jalr	1338(ra) # 80000ea6 <release>
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
    800009da:	41c080e7          	jalr	1052(ra) # 80000df2 <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	4be080e7          	jalr	1214(ra) # 80000ea6 <release>
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
    80000a26:	1141                	addi	sp,sp,-16
    80000a28:	e406                	sd	ra,8(sp)
    80000a2a:	e022                	sd	s0,0(sp)
    80000a2c:	0800                	addi	s0,sp,16
    return refcount[refindex(pa)];
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	fcc080e7          	jalr	-52(ra) # 800009fa <refindex>
    80000a36:	050a                	slli	a0,a0,0x2
    80000a38:	00010797          	auipc	a5,0x10
    80000a3c:	2d078793          	addi	a5,a5,720 # 80010d08 <refcount>
    80000a40:	97aa                	add	a5,a5,a0
}
    80000a42:	4388                	lw	a0,0(a5)
    80000a44:	60a2                	ld	ra,8(sp)
    80000a46:	6402                	ld	s0,0(sp)
    80000a48:	0141                	addi	sp,sp,16
    80000a4a:	8082                	ret

0000000080000a4c <decrefcount>:

void
decrefcount(uint64 pa)
{
    80000a4c:	1141                	addi	sp,sp,-16
    80000a4e:	e406                	sd	ra,8(sp)
    80000a50:	e022                	sd	s0,0(sp)
    80000a52:	0800                	addi	s0,sp,16
    refcount[refindex(pa)]--;
    80000a54:	00000097          	auipc	ra,0x0
    80000a58:	fa6080e7          	jalr	-90(ra) # 800009fa <refindex>
    80000a5c:	050a                	slli	a0,a0,0x2
    80000a5e:	00010797          	auipc	a5,0x10
    80000a62:	2aa78793          	addi	a5,a5,682 # 80010d08 <refcount>
    80000a66:	97aa                	add	a5,a5,a0
    80000a68:	4398                	lw	a4,0(a5)
    80000a6a:	377d                	addiw	a4,a4,-1
    80000a6c:	c398                	sw	a4,0(a5)
}
    80000a6e:	60a2                	ld	ra,8(sp)
    80000a70:	6402                	ld	s0,0(sp)
    80000a72:	0141                	addi	sp,sp,16
    80000a74:	8082                	ret

0000000080000a76 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a76:	7179                	addi	sp,sp,-48
    80000a78:	f406                	sd	ra,40(sp)
    80000a7a:	f022                	sd	s0,32(sp)
    80000a7c:	ec26                	sd	s1,24(sp)
    80000a7e:	e84a                	sd	s2,16(sp)
    80000a80:	e44e                	sd	s3,8(sp)
    80000a82:	1800                	addi	s0,sp,48
    80000a84:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a86:	00008797          	auipc	a5,0x8
    80000a8a:	fda7b783          	ld	a5,-38(a5) # 80008a60 <MAX_PAGES>
    80000a8e:	c799                	beqz	a5,80000a9c <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000a90:	00008717          	auipc	a4,0x8
    80000a94:	fc873703          	ld	a4,-56(a4) # 80008a58 <FREE_PAGES>
    80000a98:	08f77863          	bgeu	a4,a5,80000b28 <kfree+0xb2>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a9c:	03449793          	slli	a5,s1,0x34
    80000aa0:	efd5                	bnez	a5,80000b5c <kfree+0xe6>
    80000aa2:	00041797          	auipc	a5,0x41
    80000aa6:	47678793          	addi	a5,a5,1142 # 80041f18 <end>
    80000aaa:	0af4e963          	bltu	s1,a5,80000b5c <kfree+0xe6>
    80000aae:	47c5                	li	a5,17
    80000ab0:	07ee                	slli	a5,a5,0x1b
    80000ab2:	0af4f563          	bgeu	s1,a5,80000b5c <kfree+0xe6>
        panic("kfree");

    // decrement refcount

    int i = refindex((uint64) pa);
    80000ab6:	8526                	mv	a0,s1
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	f42080e7          	jalr	-190(ra) # 800009fa <refindex>
    80000ac0:	892a                	mv	s2,a0
    int empty;

    acquire(&refcountlock);
    80000ac2:	00010517          	auipc	a0,0x10
    80000ac6:	20e50513          	addi	a0,a0,526 # 80010cd0 <refcountlock>
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	328080e7          	jalr	808(ra) # 80000df2 <acquire>
    if (refcount[i] > 0) refcount[i]--;
    80000ad2:	00291713          	slli	a4,s2,0x2
    80000ad6:	00010797          	auipc	a5,0x10
    80000ada:	23278793          	addi	a5,a5,562 # 80010d08 <refcount>
    80000ade:	97ba                	add	a5,a5,a4
    80000ae0:	439c                	lw	a5,0(a5)
    80000ae2:	00f05a63          	blez	a5,80000af6 <kfree+0x80>
    80000ae6:	86ba                	mv	a3,a4
    80000ae8:	00010717          	auipc	a4,0x10
    80000aec:	22070713          	addi	a4,a4,544 # 80010d08 <refcount>
    80000af0:	9736                	add	a4,a4,a3
    80000af2:	37fd                	addiw	a5,a5,-1
    80000af4:	c31c                	sw	a5,0(a4)
    empty = refcount[i] == 0;
    80000af6:	090a                	slli	s2,s2,0x2
    80000af8:	00010797          	auipc	a5,0x10
    80000afc:	21078793          	addi	a5,a5,528 # 80010d08 <refcount>
    80000b00:	97ca                	add	a5,a5,s2
    80000b02:	0007a903          	lw	s2,0(a5)
    release(&refcountlock);
    80000b06:	00010517          	auipc	a0,0x10
    80000b0a:	1ca50513          	addi	a0,a0,458 # 80010cd0 <refcountlock>
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	398080e7          	jalr	920(ra) # 80000ea6 <release>

    if (!empty) return;
    80000b16:	04090b63          	beqz	s2,80000b6c <kfree+0xf6>
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}
    80000b1a:	70a2                	ld	ra,40(sp)
    80000b1c:	7402                	ld	s0,32(sp)
    80000b1e:	64e2                	ld	s1,24(sp)
    80000b20:	6942                	ld	s2,16(sp)
    80000b22:	69a2                	ld	s3,8(sp)
    80000b24:	6145                	addi	sp,sp,48
    80000b26:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000b28:	05300693          	li	a3,83
    80000b2c:	00007617          	auipc	a2,0x7
    80000b30:	4dc60613          	addi	a2,a2,1244 # 80008008 <__func__.1>
    80000b34:	00007597          	auipc	a1,0x7
    80000b38:	54c58593          	addi	a1,a1,1356 # 80008080 <digits+0x30>
    80000b3c:	00007517          	auipc	a0,0x7
    80000b40:	55450513          	addi	a0,a0,1364 # 80008090 <digits+0x40>
    80000b44:	00000097          	auipc	ra,0x0
    80000b48:	a58080e7          	jalr	-1448(ra) # 8000059c <printf>
    80000b4c:	00007517          	auipc	a0,0x7
    80000b50:	55450513          	addi	a0,a0,1364 # 800080a0 <digits+0x50>
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	9ec080e7          	jalr	-1556(ra) # 80000540 <panic>
        panic("kfree");
    80000b5c:	00007517          	auipc	a0,0x7
    80000b60:	55450513          	addi	a0,a0,1364 # 800080b0 <digits+0x60>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	9dc080e7          	jalr	-1572(ra) # 80000540 <panic>
    memset(pa, 1, PGSIZE);
    80000b6c:	6605                	lui	a2,0x1
    80000b6e:	4585                	li	a1,1
    80000b70:	8526                	mv	a0,s1
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	37c080e7          	jalr	892(ra) # 80000eee <memset>
    acquire(&kmem.lock);
    80000b7a:	00010997          	auipc	s3,0x10
    80000b7e:	15698993          	addi	s3,s3,342 # 80010cd0 <refcountlock>
    80000b82:	00010917          	auipc	s2,0x10
    80000b86:	16690913          	addi	s2,s2,358 # 80010ce8 <kmem>
    80000b8a:	854a                	mv	a0,s2
    80000b8c:	00000097          	auipc	ra,0x0
    80000b90:	266080e7          	jalr	614(ra) # 80000df2 <acquire>
    r->next = kmem.freelist;
    80000b94:	0309b783          	ld	a5,48(s3)
    80000b98:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000b9a:	0299b823          	sd	s1,48(s3)
    FREE_PAGES++;
    80000b9e:	00008717          	auipc	a4,0x8
    80000ba2:	eba70713          	addi	a4,a4,-326 # 80008a58 <FREE_PAGES>
    80000ba6:	631c                	ld	a5,0(a4)
    80000ba8:	0785                	addi	a5,a5,1
    80000baa:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000bac:	854a                	mv	a0,s2
    80000bae:	00000097          	auipc	ra,0x0
    80000bb2:	2f8080e7          	jalr	760(ra) # 80000ea6 <release>
    80000bb6:	b795                	j	80000b1a <kfree+0xa4>

0000000080000bb8 <freerange>:
{
    80000bb8:	7179                	addi	sp,sp,-48
    80000bba:	f406                	sd	ra,40(sp)
    80000bbc:	f022                	sd	s0,32(sp)
    80000bbe:	ec26                	sd	s1,24(sp)
    80000bc0:	e84a                	sd	s2,16(sp)
    80000bc2:	e44e                	sd	s3,8(sp)
    80000bc4:	e052                	sd	s4,0(sp)
    80000bc6:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000bc8:	6785                	lui	a5,0x1
    80000bca:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000bce:	00e504b3          	add	s1,a0,a4
    80000bd2:	777d                	lui	a4,0xfffff
    80000bd4:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bd6:	94be                	add	s1,s1,a5
    80000bd8:	0095ee63          	bltu	a1,s1,80000bf4 <freerange+0x3c>
    80000bdc:	892e                	mv	s2,a1
        kfree(p);
    80000bde:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000be0:	6985                	lui	s3,0x1
        kfree(p);
    80000be2:	01448533          	add	a0,s1,s4
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	e90080e7          	jalr	-368(ra) # 80000a76 <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bee:	94ce                	add	s1,s1,s3
    80000bf0:	fe9979e3          	bgeu	s2,s1,80000be2 <freerange+0x2a>
}
    80000bf4:	70a2                	ld	ra,40(sp)
    80000bf6:	7402                	ld	s0,32(sp)
    80000bf8:	64e2                	ld	s1,24(sp)
    80000bfa:	6942                	ld	s2,16(sp)
    80000bfc:	69a2                	ld	s3,8(sp)
    80000bfe:	6a02                	ld	s4,0(sp)
    80000c00:	6145                	addi	sp,sp,48
    80000c02:	8082                	ret

0000000080000c04 <kinit>:
{
    80000c04:	1141                	addi	sp,sp,-16
    80000c06:	e406                	sd	ra,8(sp)
    80000c08:	e022                	sd	s0,0(sp)
    80000c0a:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000c0c:	00007597          	auipc	a1,0x7
    80000c10:	4ac58593          	addi	a1,a1,1196 # 800080b8 <digits+0x68>
    80000c14:	00010517          	auipc	a0,0x10
    80000c18:	0d450513          	addi	a0,a0,212 # 80010ce8 <kmem>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	146080e7          	jalr	326(ra) # 80000d62 <initlock>
    initlock(&refcountlock, "refcount");
    80000c24:	00007597          	auipc	a1,0x7
    80000c28:	49c58593          	addi	a1,a1,1180 # 800080c0 <digits+0x70>
    80000c2c:	00010517          	auipc	a0,0x10
    80000c30:	0a450513          	addi	a0,a0,164 # 80010cd0 <refcountlock>
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	12e080e7          	jalr	302(ra) # 80000d62 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000c3c:	45c5                	li	a1,17
    80000c3e:	05ee                	slli	a1,a1,0x1b
    80000c40:	00041517          	auipc	a0,0x41
    80000c44:	2d850513          	addi	a0,a0,728 # 80041f18 <end>
    80000c48:	00000097          	auipc	ra,0x0
    80000c4c:	f70080e7          	jalr	-144(ra) # 80000bb8 <freerange>
    MAX_PAGES = FREE_PAGES;
    80000c50:	00008797          	auipc	a5,0x8
    80000c54:	e087b783          	ld	a5,-504(a5) # 80008a58 <FREE_PAGES>
    80000c58:	00008717          	auipc	a4,0x8
    80000c5c:	e0f73423          	sd	a5,-504(a4) # 80008a60 <MAX_PAGES>
}
    80000c60:	60a2                	ld	ra,8(sp)
    80000c62:	6402                	ld	s0,0(sp)
    80000c64:	0141                	addi	sp,sp,16
    80000c66:	8082                	ret

0000000080000c68 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c68:	7179                	addi	sp,sp,-48
    80000c6a:	f406                	sd	ra,40(sp)
    80000c6c:	f022                	sd	s0,32(sp)
    80000c6e:	ec26                	sd	s1,24(sp)
    80000c70:	e84a                	sd	s2,16(sp)
    80000c72:	e44e                	sd	s3,8(sp)
    80000c74:	1800                	addi	s0,sp,48
    assert(FREE_PAGES > 0);
    80000c76:	00008797          	auipc	a5,0x8
    80000c7a:	de27b783          	ld	a5,-542(a5) # 80008a58 <FREE_PAGES>
    80000c7e:	cfd9                	beqz	a5,80000d1c <kalloc+0xb4>
    struct run *r;

    acquire(&kmem.lock);
    80000c80:	00010517          	auipc	a0,0x10
    80000c84:	06850513          	addi	a0,a0,104 # 80010ce8 <kmem>
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	16a080e7          	jalr	362(ra) # 80000df2 <acquire>
    r = kmem.freelist;
    80000c90:	00010917          	auipc	s2,0x10
    80000c94:	07093903          	ld	s2,112(s2) # 80010d00 <kmem+0x18>
    if (r)
    80000c98:	0a090c63          	beqz	s2,80000d50 <kalloc+0xe8>
        kmem.freelist = r->next;
    80000c9c:	00093783          	ld	a5,0(s2)
    80000ca0:	00010717          	auipc	a4,0x10
    80000ca4:	06f73023          	sd	a5,96(a4) # 80010d00 <kmem+0x18>
    release(&kmem.lock);
    80000ca8:	00010517          	auipc	a0,0x10
    80000cac:	04050513          	addi	a0,a0,64 # 80010ce8 <kmem>
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	1f6080e7          	jalr	502(ra) # 80000ea6 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000cb8:	6605                	lui	a2,0x1
    80000cba:	4595                	li	a1,5
    80000cbc:	854a                	mv	a0,s2
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	230080e7          	jalr	560(ra) # 80000eee <memset>
    FREE_PAGES--;
    80000cc6:	00008717          	auipc	a4,0x8
    80000cca:	d9270713          	addi	a4,a4,-622 # 80008a58 <FREE_PAGES>
    80000cce:	631c                	ld	a5,0(a4)
    80000cd0:	17fd                	addi	a5,a5,-1
    80000cd2:	e31c                	sd	a5,0(a4)

    int i = refindex((uint64) r);
    80000cd4:	854a                	mv	a0,s2
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	d24080e7          	jalr	-732(ra) # 800009fa <refindex>
    80000cde:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000ce0:	00010997          	auipc	s3,0x10
    80000ce4:	ff098993          	addi	s3,s3,-16 # 80010cd0 <refcountlock>
    80000ce8:	854e                	mv	a0,s3
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	108080e7          	jalr	264(ra) # 80000df2 <acquire>
    refcount[i] = 1;
    80000cf2:	048a                	slli	s1,s1,0x2
    80000cf4:	00010797          	auipc	a5,0x10
    80000cf8:	01478793          	addi	a5,a5,20 # 80010d08 <refcount>
    80000cfc:	97a6                	add	a5,a5,s1
    80000cfe:	4705                	li	a4,1
    80000d00:	c398                	sw	a4,0(a5)
    release(&refcountlock);
    80000d02:	854e                	mv	a0,s3
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	1a2080e7          	jalr	418(ra) # 80000ea6 <release>

    return (void *)r;
}
    80000d0c:	854a                	mv	a0,s2
    80000d0e:	70a2                	ld	ra,40(sp)
    80000d10:	7402                	ld	s0,32(sp)
    80000d12:	64e2                	ld	s1,24(sp)
    80000d14:	6942                	ld	s2,16(sp)
    80000d16:	69a2                	ld	s3,8(sp)
    80000d18:	6145                	addi	sp,sp,48
    80000d1a:	8082                	ret
    assert(FREE_PAGES > 0);
    80000d1c:	07900693          	li	a3,121
    80000d20:	00007617          	auipc	a2,0x7
    80000d24:	2e060613          	addi	a2,a2,736 # 80008000 <etext>
    80000d28:	00007597          	auipc	a1,0x7
    80000d2c:	35858593          	addi	a1,a1,856 # 80008080 <digits+0x30>
    80000d30:	00007517          	auipc	a0,0x7
    80000d34:	36050513          	addi	a0,a0,864 # 80008090 <digits+0x40>
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	864080e7          	jalr	-1948(ra) # 8000059c <printf>
    80000d40:	00007517          	auipc	a0,0x7
    80000d44:	36050513          	addi	a0,a0,864 # 800080a0 <digits+0x50>
    80000d48:	fffff097          	auipc	ra,0xfffff
    80000d4c:	7f8080e7          	jalr	2040(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000d50:	00010517          	auipc	a0,0x10
    80000d54:	f9850513          	addi	a0,a0,-104 # 80010ce8 <kmem>
    80000d58:	00000097          	auipc	ra,0x0
    80000d5c:	14e080e7          	jalr	334(ra) # 80000ea6 <release>
    if (r)
    80000d60:	b79d                	j	80000cc6 <kalloc+0x5e>

0000000080000d62 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d62:	1141                	addi	sp,sp,-16
    80000d64:	e422                	sd	s0,8(sp)
    80000d66:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d68:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d6a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d6e:	00053823          	sd	zero,16(a0)
}
    80000d72:	6422                	ld	s0,8(sp)
    80000d74:	0141                	addi	sp,sp,16
    80000d76:	8082                	ret

0000000080000d78 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d78:	411c                	lw	a5,0(a0)
    80000d7a:	e399                	bnez	a5,80000d80 <holding+0x8>
    80000d7c:	4501                	li	a0,0
  return r;
}
    80000d7e:	8082                	ret
{
    80000d80:	1101                	addi	sp,sp,-32
    80000d82:	ec06                	sd	ra,24(sp)
    80000d84:	e822                	sd	s0,16(sp)
    80000d86:	e426                	sd	s1,8(sp)
    80000d88:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d8a:	6904                	ld	s1,16(a0)
    80000d8c:	00001097          	auipc	ra,0x1
    80000d90:	f58080e7          	jalr	-168(ra) # 80001ce4 <mycpu>
    80000d94:	40a48533          	sub	a0,s1,a0
    80000d98:	00153513          	seqz	a0,a0
}
    80000d9c:	60e2                	ld	ra,24(sp)
    80000d9e:	6442                	ld	s0,16(sp)
    80000da0:	64a2                	ld	s1,8(sp)
    80000da2:	6105                	addi	sp,sp,32
    80000da4:	8082                	ret

0000000080000da6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000da6:	1101                	addi	sp,sp,-32
    80000da8:	ec06                	sd	ra,24(sp)
    80000daa:	e822                	sd	s0,16(sp)
    80000dac:	e426                	sd	s1,8(sp)
    80000dae:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000db0:	100024f3          	csrr	s1,sstatus
    80000db4:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000db8:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000dba:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000dbe:	00001097          	auipc	ra,0x1
    80000dc2:	f26080e7          	jalr	-218(ra) # 80001ce4 <mycpu>
    80000dc6:	5d3c                	lw	a5,120(a0)
    80000dc8:	cf89                	beqz	a5,80000de2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000dca:	00001097          	auipc	ra,0x1
    80000dce:	f1a080e7          	jalr	-230(ra) # 80001ce4 <mycpu>
    80000dd2:	5d3c                	lw	a5,120(a0)
    80000dd4:	2785                	addiw	a5,a5,1
    80000dd6:	dd3c                	sw	a5,120(a0)
}
    80000dd8:	60e2                	ld	ra,24(sp)
    80000dda:	6442                	ld	s0,16(sp)
    80000ddc:	64a2                	ld	s1,8(sp)
    80000dde:	6105                	addi	sp,sp,32
    80000de0:	8082                	ret
    mycpu()->intena = old;
    80000de2:	00001097          	auipc	ra,0x1
    80000de6:	f02080e7          	jalr	-254(ra) # 80001ce4 <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000dea:	8085                	srli	s1,s1,0x1
    80000dec:	8885                	andi	s1,s1,1
    80000dee:	dd64                	sw	s1,124(a0)
    80000df0:	bfe9                	j	80000dca <push_off+0x24>

0000000080000df2 <acquire>:
{
    80000df2:	1101                	addi	sp,sp,-32
    80000df4:	ec06                	sd	ra,24(sp)
    80000df6:	e822                	sd	s0,16(sp)
    80000df8:	e426                	sd	s1,8(sp)
    80000dfa:	1000                	addi	s0,sp,32
    80000dfc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000dfe:	00000097          	auipc	ra,0x0
    80000e02:	fa8080e7          	jalr	-88(ra) # 80000da6 <push_off>
  if(holding(lk))
    80000e06:	8526                	mv	a0,s1
    80000e08:	00000097          	auipc	ra,0x0
    80000e0c:	f70080e7          	jalr	-144(ra) # 80000d78 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e10:	4705                	li	a4,1
  if(holding(lk))
    80000e12:	e115                	bnez	a0,80000e36 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e14:	87ba                	mv	a5,a4
    80000e16:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e1a:	2781                	sext.w	a5,a5
    80000e1c:	ffe5                	bnez	a5,80000e14 <acquire+0x22>
  __sync_synchronize();
    80000e1e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e22:	00001097          	auipc	ra,0x1
    80000e26:	ec2080e7          	jalr	-318(ra) # 80001ce4 <mycpu>
    80000e2a:	e888                	sd	a0,16(s1)
}
    80000e2c:	60e2                	ld	ra,24(sp)
    80000e2e:	6442                	ld	s0,16(sp)
    80000e30:	64a2                	ld	s1,8(sp)
    80000e32:	6105                	addi	sp,sp,32
    80000e34:	8082                	ret
    panic("acquire");
    80000e36:	00007517          	auipc	a0,0x7
    80000e3a:	29a50513          	addi	a0,a0,666 # 800080d0 <digits+0x80>
    80000e3e:	fffff097          	auipc	ra,0xfffff
    80000e42:	702080e7          	jalr	1794(ra) # 80000540 <panic>

0000000080000e46 <pop_off>:

void
pop_off(void)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e406                	sd	ra,8(sp)
    80000e4a:	e022                	sd	s0,0(sp)
    80000e4c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e4e:	00001097          	auipc	ra,0x1
    80000e52:	e96080e7          	jalr	-362(ra) # 80001ce4 <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000e56:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000e5a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e5c:	e78d                	bnez	a5,80000e86 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e5e:	5d3c                	lw	a5,120(a0)
    80000e60:	02f05b63          	blez	a5,80000e96 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e64:	37fd                	addiw	a5,a5,-1
    80000e66:	0007871b          	sext.w	a4,a5
    80000e6a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e6c:	eb09                	bnez	a4,80000e7e <pop_off+0x38>
    80000e6e:	5d7c                	lw	a5,124(a0)
    80000e70:	c799                	beqz	a5,80000e7e <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000e72:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e76:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000e7a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e7e:	60a2                	ld	ra,8(sp)
    80000e80:	6402                	ld	s0,0(sp)
    80000e82:	0141                	addi	sp,sp,16
    80000e84:	8082                	ret
    panic("pop_off - interruptible");
    80000e86:	00007517          	auipc	a0,0x7
    80000e8a:	25250513          	addi	a0,a0,594 # 800080d8 <digits+0x88>
    80000e8e:	fffff097          	auipc	ra,0xfffff
    80000e92:	6b2080e7          	jalr	1714(ra) # 80000540 <panic>
    panic("pop_off");
    80000e96:	00007517          	auipc	a0,0x7
    80000e9a:	25a50513          	addi	a0,a0,602 # 800080f0 <digits+0xa0>
    80000e9e:	fffff097          	auipc	ra,0xfffff
    80000ea2:	6a2080e7          	jalr	1698(ra) # 80000540 <panic>

0000000080000ea6 <release>:
{
    80000ea6:	1101                	addi	sp,sp,-32
    80000ea8:	ec06                	sd	ra,24(sp)
    80000eaa:	e822                	sd	s0,16(sp)
    80000eac:	e426                	sd	s1,8(sp)
    80000eae:	1000                	addi	s0,sp,32
    80000eb0:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000eb2:	00000097          	auipc	ra,0x0
    80000eb6:	ec6080e7          	jalr	-314(ra) # 80000d78 <holding>
    80000eba:	c115                	beqz	a0,80000ede <release+0x38>
  lk->cpu = 0;
    80000ebc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ec0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ec4:	0f50000f          	fence	iorw,ow
    80000ec8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	f7a080e7          	jalr	-134(ra) # 80000e46 <pop_off>
}
    80000ed4:	60e2                	ld	ra,24(sp)
    80000ed6:	6442                	ld	s0,16(sp)
    80000ed8:	64a2                	ld	s1,8(sp)
    80000eda:	6105                	addi	sp,sp,32
    80000edc:	8082                	ret
    panic("release");
    80000ede:	00007517          	auipc	a0,0x7
    80000ee2:	21a50513          	addi	a0,a0,538 # 800080f8 <digits+0xa8>
    80000ee6:	fffff097          	auipc	ra,0xfffff
    80000eea:	65a080e7          	jalr	1626(ra) # 80000540 <panic>

0000000080000eee <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ef4:	ca19                	beqz	a2,80000f0a <memset+0x1c>
    80000ef6:	87aa                	mv	a5,a0
    80000ef8:	1602                	slli	a2,a2,0x20
    80000efa:	9201                	srli	a2,a2,0x20
    80000efc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f00:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f04:	0785                	addi	a5,a5,1
    80000f06:	fee79de3          	bne	a5,a4,80000f00 <memset+0x12>
  }
  return dst;
}
    80000f0a:	6422                	ld	s0,8(sp)
    80000f0c:	0141                	addi	sp,sp,16
    80000f0e:	8082                	ret

0000000080000f10 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f10:	1141                	addi	sp,sp,-16
    80000f12:	e422                	sd	s0,8(sp)
    80000f14:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f16:	ca05                	beqz	a2,80000f46 <memcmp+0x36>
    80000f18:	fff6069b          	addiw	a3,a2,-1
    80000f1c:	1682                	slli	a3,a3,0x20
    80000f1e:	9281                	srli	a3,a3,0x20
    80000f20:	0685                	addi	a3,a3,1
    80000f22:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f24:	00054783          	lbu	a5,0(a0)
    80000f28:	0005c703          	lbu	a4,0(a1)
    80000f2c:	00e79863          	bne	a5,a4,80000f3c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f30:	0505                	addi	a0,a0,1
    80000f32:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f34:	fed518e3          	bne	a0,a3,80000f24 <memcmp+0x14>
  }

  return 0;
    80000f38:	4501                	li	a0,0
    80000f3a:	a019                	j	80000f40 <memcmp+0x30>
      return *s1 - *s2;
    80000f3c:	40e7853b          	subw	a0,a5,a4
}
    80000f40:	6422                	ld	s0,8(sp)
    80000f42:	0141                	addi	sp,sp,16
    80000f44:	8082                	ret
  return 0;
    80000f46:	4501                	li	a0,0
    80000f48:	bfe5                	j	80000f40 <memcmp+0x30>

0000000080000f4a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f4a:	1141                	addi	sp,sp,-16
    80000f4c:	e422                	sd	s0,8(sp)
    80000f4e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f50:	c205                	beqz	a2,80000f70 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f52:	02a5e263          	bltu	a1,a0,80000f76 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f56:	1602                	slli	a2,a2,0x20
    80000f58:	9201                	srli	a2,a2,0x20
    80000f5a:	00c587b3          	add	a5,a1,a2
{
    80000f5e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f60:	0585                	addi	a1,a1,1
    80000f62:	0705                	addi	a4,a4,1
    80000f64:	fff5c683          	lbu	a3,-1(a1)
    80000f68:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f6c:	fef59ae3          	bne	a1,a5,80000f60 <memmove+0x16>

  return dst;
}
    80000f70:	6422                	ld	s0,8(sp)
    80000f72:	0141                	addi	sp,sp,16
    80000f74:	8082                	ret
  if(s < d && s + n > d){
    80000f76:	02061693          	slli	a3,a2,0x20
    80000f7a:	9281                	srli	a3,a3,0x20
    80000f7c:	00d58733          	add	a4,a1,a3
    80000f80:	fce57be3          	bgeu	a0,a4,80000f56 <memmove+0xc>
    d += n;
    80000f84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f86:	fff6079b          	addiw	a5,a2,-1
    80000f8a:	1782                	slli	a5,a5,0x20
    80000f8c:	9381                	srli	a5,a5,0x20
    80000f8e:	fff7c793          	not	a5,a5
    80000f92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f94:	177d                	addi	a4,a4,-1
    80000f96:	16fd                	addi	a3,a3,-1
    80000f98:	00074603          	lbu	a2,0(a4)
    80000f9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000fa0:	fee79ae3          	bne	a5,a4,80000f94 <memmove+0x4a>
    80000fa4:	b7f1                	j	80000f70 <memmove+0x26>

0000000080000fa6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000fa6:	1141                	addi	sp,sp,-16
    80000fa8:	e406                	sd	ra,8(sp)
    80000faa:	e022                	sd	s0,0(sp)
    80000fac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000fae:	00000097          	auipc	ra,0x0
    80000fb2:	f9c080e7          	jalr	-100(ra) # 80000f4a <memmove>
}
    80000fb6:	60a2                	ld	ra,8(sp)
    80000fb8:	6402                	ld	s0,0(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret

0000000080000fbe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000fbe:	1141                	addi	sp,sp,-16
    80000fc0:	e422                	sd	s0,8(sp)
    80000fc2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000fc4:	ce11                	beqz	a2,80000fe0 <strncmp+0x22>
    80000fc6:	00054783          	lbu	a5,0(a0)
    80000fca:	cf89                	beqz	a5,80000fe4 <strncmp+0x26>
    80000fcc:	0005c703          	lbu	a4,0(a1)
    80000fd0:	00f71a63          	bne	a4,a5,80000fe4 <strncmp+0x26>
    n--, p++, q++;
    80000fd4:	367d                	addiw	a2,a2,-1
    80000fd6:	0505                	addi	a0,a0,1
    80000fd8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000fda:	f675                	bnez	a2,80000fc6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000fdc:	4501                	li	a0,0
    80000fde:	a809                	j	80000ff0 <strncmp+0x32>
    80000fe0:	4501                	li	a0,0
    80000fe2:	a039                	j	80000ff0 <strncmp+0x32>
  if(n == 0)
    80000fe4:	ca09                	beqz	a2,80000ff6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000fe6:	00054503          	lbu	a0,0(a0)
    80000fea:	0005c783          	lbu	a5,0(a1)
    80000fee:	9d1d                	subw	a0,a0,a5
}
    80000ff0:	6422                	ld	s0,8(sp)
    80000ff2:	0141                	addi	sp,sp,16
    80000ff4:	8082                	ret
    return 0;
    80000ff6:	4501                	li	a0,0
    80000ff8:	bfe5                	j	80000ff0 <strncmp+0x32>

0000000080000ffa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ffa:	1141                	addi	sp,sp,-16
    80000ffc:	e422                	sd	s0,8(sp)
    80000ffe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001000:	872a                	mv	a4,a0
    80001002:	8832                	mv	a6,a2
    80001004:	367d                	addiw	a2,a2,-1
    80001006:	01005963          	blez	a6,80001018 <strncpy+0x1e>
    8000100a:	0705                	addi	a4,a4,1
    8000100c:	0005c783          	lbu	a5,0(a1)
    80001010:	fef70fa3          	sb	a5,-1(a4)
    80001014:	0585                	addi	a1,a1,1
    80001016:	f7f5                	bnez	a5,80001002 <strncpy+0x8>
    ;
  while(n-- > 0)
    80001018:	86ba                	mv	a3,a4
    8000101a:	00c05c63          	blez	a2,80001032 <strncpy+0x38>
    *s++ = 0;
    8000101e:	0685                	addi	a3,a3,1
    80001020:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001024:	40d707bb          	subw	a5,a4,a3
    80001028:	37fd                	addiw	a5,a5,-1
    8000102a:	010787bb          	addw	a5,a5,a6
    8000102e:	fef048e3          	bgtz	a5,8000101e <strncpy+0x24>
  return os;
}
    80001032:	6422                	ld	s0,8(sp)
    80001034:	0141                	addi	sp,sp,16
    80001036:	8082                	ret

0000000080001038 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001038:	1141                	addi	sp,sp,-16
    8000103a:	e422                	sd	s0,8(sp)
    8000103c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000103e:	02c05363          	blez	a2,80001064 <safestrcpy+0x2c>
    80001042:	fff6069b          	addiw	a3,a2,-1
    80001046:	1682                	slli	a3,a3,0x20
    80001048:	9281                	srli	a3,a3,0x20
    8000104a:	96ae                	add	a3,a3,a1
    8000104c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000104e:	00d58963          	beq	a1,a3,80001060 <safestrcpy+0x28>
    80001052:	0585                	addi	a1,a1,1
    80001054:	0785                	addi	a5,a5,1
    80001056:	fff5c703          	lbu	a4,-1(a1)
    8000105a:	fee78fa3          	sb	a4,-1(a5)
    8000105e:	fb65                	bnez	a4,8000104e <safestrcpy+0x16>
    ;
  *s = 0;
    80001060:	00078023          	sb	zero,0(a5)
  return os;
}
    80001064:	6422                	ld	s0,8(sp)
    80001066:	0141                	addi	sp,sp,16
    80001068:	8082                	ret

000000008000106a <strlen>:

int
strlen(const char *s)
{
    8000106a:	1141                	addi	sp,sp,-16
    8000106c:	e422                	sd	s0,8(sp)
    8000106e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001070:	00054783          	lbu	a5,0(a0)
    80001074:	cf91                	beqz	a5,80001090 <strlen+0x26>
    80001076:	0505                	addi	a0,a0,1
    80001078:	87aa                	mv	a5,a0
    8000107a:	4685                	li	a3,1
    8000107c:	9e89                	subw	a3,a3,a0
    8000107e:	00f6853b          	addw	a0,a3,a5
    80001082:	0785                	addi	a5,a5,1
    80001084:	fff7c703          	lbu	a4,-1(a5)
    80001088:	fb7d                	bnez	a4,8000107e <strlen+0x14>
    ;
  return n;
}
    8000108a:	6422                	ld	s0,8(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret
  for(n = 0; s[n]; n++)
    80001090:	4501                	li	a0,0
    80001092:	bfe5                	j	8000108a <strlen+0x20>

0000000080001094 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001094:	1141                	addi	sp,sp,-16
    80001096:	e406                	sd	ra,8(sp)
    80001098:	e022                	sd	s0,0(sp)
    8000109a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000109c:	00001097          	auipc	ra,0x1
    800010a0:	c38080e7          	jalr	-968(ra) # 80001cd4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800010a4:	00008717          	auipc	a4,0x8
    800010a8:	9c470713          	addi	a4,a4,-1596 # 80008a68 <started>
  if(cpuid() == 0){
    800010ac:	c139                	beqz	a0,800010f2 <main+0x5e>
    while(started == 0)
    800010ae:	431c                	lw	a5,0(a4)
    800010b0:	2781                	sext.w	a5,a5
    800010b2:	dff5                	beqz	a5,800010ae <main+0x1a>
      ;
    __sync_synchronize();
    800010b4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800010b8:	00001097          	auipc	ra,0x1
    800010bc:	c1c080e7          	jalr	-996(ra) # 80001cd4 <cpuid>
    800010c0:	85aa                	mv	a1,a0
    800010c2:	00007517          	auipc	a0,0x7
    800010c6:	05650513          	addi	a0,a0,86 # 80008118 <digits+0xc8>
    800010ca:	fffff097          	auipc	ra,0xfffff
    800010ce:	4d2080e7          	jalr	1234(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	0d8080e7          	jalr	216(ra) # 800011aa <kvminithart>
    trapinithart();   // install kernel trap vector
    800010da:	00002097          	auipc	ra,0x2
    800010de:	b22080e7          	jalr	-1246(ra) # 80002bfc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800010e2:	00005097          	auipc	ra,0x5
    800010e6:	29e080e7          	jalr	670(ra) # 80006380 <plicinithart>
  }

  scheduler();        
    800010ea:	00001097          	auipc	ra,0x1
    800010ee:	2a2080e7          	jalr	674(ra) # 8000238c <scheduler>
    consoleinit();
    800010f2:	fffff097          	auipc	ra,0xfffff
    800010f6:	35e080e7          	jalr	862(ra) # 80000450 <consoleinit>
    printfinit();
    800010fa:	fffff097          	auipc	ra,0xfffff
    800010fe:	682080e7          	jalr	1666(ra) # 8000077c <printfinit>
    printf("\n");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	f9650513          	addi	a0,a0,-106 # 80008098 <digits+0x48>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	492080e7          	jalr	1170(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fee50513          	addi	a0,a0,-18 # 80008100 <digits+0xb0>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	482080e7          	jalr	1154(ra) # 8000059c <printf>
    printf("\n");
    80001122:	00007517          	auipc	a0,0x7
    80001126:	f7650513          	addi	a0,a0,-138 # 80008098 <digits+0x48>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	472080e7          	jalr	1138(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    80001132:	00000097          	auipc	ra,0x0
    80001136:	ad2080e7          	jalr	-1326(ra) # 80000c04 <kinit>
    kvminit();       // create kernel page table
    8000113a:	00000097          	auipc	ra,0x0
    8000113e:	326080e7          	jalr	806(ra) # 80001460 <kvminit>
    kvminithart();   // turn on paging
    80001142:	00000097          	auipc	ra,0x0
    80001146:	068080e7          	jalr	104(ra) # 800011aa <kvminithart>
    procinit();      // process table
    8000114a:	00001097          	auipc	ra,0x1
    8000114e:	aa8080e7          	jalr	-1368(ra) # 80001bf2 <procinit>
    trapinit();      // trap vectors
    80001152:	00002097          	auipc	ra,0x2
    80001156:	a82080e7          	jalr	-1406(ra) # 80002bd4 <trapinit>
    trapinithart();  // install kernel trap vector
    8000115a:	00002097          	auipc	ra,0x2
    8000115e:	aa2080e7          	jalr	-1374(ra) # 80002bfc <trapinithart>
    plicinit();      // set up interrupt controller
    80001162:	00005097          	auipc	ra,0x5
    80001166:	208080e7          	jalr	520(ra) # 8000636a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000116a:	00005097          	auipc	ra,0x5
    8000116e:	216080e7          	jalr	534(ra) # 80006380 <plicinithart>
    binit();         // buffer cache
    80001172:	00002097          	auipc	ra,0x2
    80001176:	3b8080e7          	jalr	952(ra) # 8000352a <binit>
    iinit();         // inode table
    8000117a:	00003097          	auipc	ra,0x3
    8000117e:	a58080e7          	jalr	-1448(ra) # 80003bd2 <iinit>
    fileinit();      // file table
    80001182:	00004097          	auipc	ra,0x4
    80001186:	9fe080e7          	jalr	-1538(ra) # 80004b80 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000118a:	00005097          	auipc	ra,0x5
    8000118e:	2fe080e7          	jalr	766(ra) # 80006488 <virtio_disk_init>
    userinit();      // first user process
    80001192:	00001097          	auipc	ra,0x1
    80001196:	e46080e7          	jalr	-442(ra) # 80001fd8 <userinit>
    __sync_synchronize();
    8000119a:	0ff0000f          	fence
    started = 1;
    8000119e:	4785                	li	a5,1
    800011a0:	00008717          	auipc	a4,0x8
    800011a4:	8cf72423          	sw	a5,-1848(a4) # 80008a68 <started>
    800011a8:	b789                	j	800010ea <main+0x56>

00000000800011aa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800011aa:	1141                	addi	sp,sp,-16
    800011ac:	e422                	sd	s0,8(sp)
    800011ae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    800011b0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800011b4:	00008797          	auipc	a5,0x8
    800011b8:	8bc7b783          	ld	a5,-1860(a5) # 80008a70 <kernel_pagetable>
    800011bc:	83b1                	srli	a5,a5,0xc
    800011be:	577d                	li	a4,-1
    800011c0:	177e                	slli	a4,a4,0x3f
    800011c2:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    800011c4:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    800011c8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800011cc:	6422                	ld	s0,8(sp)
    800011ce:	0141                	addi	sp,sp,16
    800011d0:	8082                	ret

00000000800011d2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800011d2:	7139                	addi	sp,sp,-64
    800011d4:	fc06                	sd	ra,56(sp)
    800011d6:	f822                	sd	s0,48(sp)
    800011d8:	f426                	sd	s1,40(sp)
    800011da:	f04a                	sd	s2,32(sp)
    800011dc:	ec4e                	sd	s3,24(sp)
    800011de:	e852                	sd	s4,16(sp)
    800011e0:	e456                	sd	s5,8(sp)
    800011e2:	e05a                	sd	s6,0(sp)
    800011e4:	0080                	addi	s0,sp,64
    800011e6:	84aa                	mv	s1,a0
    800011e8:	89ae                	mv	s3,a1
    800011ea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800011ec:	57fd                	li	a5,-1
    800011ee:	83e9                	srli	a5,a5,0x1a
    800011f0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011f2:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011f4:	04b7f263          	bgeu	a5,a1,80001238 <walk+0x66>
    panic("walk");
    800011f8:	00007517          	auipc	a0,0x7
    800011fc:	f3850513          	addi	a0,a0,-200 # 80008130 <digits+0xe0>
    80001200:	fffff097          	auipc	ra,0xfffff
    80001204:	340080e7          	jalr	832(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001208:	060a8663          	beqz	s5,80001274 <walk+0xa2>
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	a5c080e7          	jalr	-1444(ra) # 80000c68 <kalloc>
    80001214:	84aa                	mv	s1,a0
    80001216:	c529                	beqz	a0,80001260 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001218:	6605                	lui	a2,0x1
    8000121a:	4581                	li	a1,0
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	cd2080e7          	jalr	-814(ra) # 80000eee <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001224:	00c4d793          	srli	a5,s1,0xc
    80001228:	07aa                	slli	a5,a5,0xa
    8000122a:	0017e793          	ori	a5,a5,1
    8000122e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001232:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffbd0df>
    80001234:	036a0063          	beq	s4,s6,80001254 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001238:	0149d933          	srl	s2,s3,s4
    8000123c:	1ff97913          	andi	s2,s2,511
    80001240:	090e                	slli	s2,s2,0x3
    80001242:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001244:	00093483          	ld	s1,0(s2)
    80001248:	0014f793          	andi	a5,s1,1
    8000124c:	dfd5                	beqz	a5,80001208 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000124e:	80a9                	srli	s1,s1,0xa
    80001250:	04b2                	slli	s1,s1,0xc
    80001252:	b7c5                	j	80001232 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001254:	00c9d513          	srli	a0,s3,0xc
    80001258:	1ff57513          	andi	a0,a0,511
    8000125c:	050e                	slli	a0,a0,0x3
    8000125e:	9526                	add	a0,a0,s1
}
    80001260:	70e2                	ld	ra,56(sp)
    80001262:	7442                	ld	s0,48(sp)
    80001264:	74a2                	ld	s1,40(sp)
    80001266:	7902                	ld	s2,32(sp)
    80001268:	69e2                	ld	s3,24(sp)
    8000126a:	6a42                	ld	s4,16(sp)
    8000126c:	6aa2                	ld	s5,8(sp)
    8000126e:	6b02                	ld	s6,0(sp)
    80001270:	6121                	addi	sp,sp,64
    80001272:	8082                	ret
        return 0;
    80001274:	4501                	li	a0,0
    80001276:	b7ed                	j	80001260 <walk+0x8e>

0000000080001278 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001278:	57fd                	li	a5,-1
    8000127a:	83e9                	srli	a5,a5,0x1a
    8000127c:	00b7f463          	bgeu	a5,a1,80001284 <walkaddr+0xc>
    return 0;
    80001280:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001282:	8082                	ret
{
    80001284:	1141                	addi	sp,sp,-16
    80001286:	e406                	sd	ra,8(sp)
    80001288:	e022                	sd	s0,0(sp)
    8000128a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000128c:	4601                	li	a2,0
    8000128e:	00000097          	auipc	ra,0x0
    80001292:	f44080e7          	jalr	-188(ra) # 800011d2 <walk>
  if(pte == 0)
    80001296:	c105                	beqz	a0,800012b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001298:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000129a:	0117f693          	andi	a3,a5,17
    8000129e:	4745                	li	a4,17
    return 0;
    800012a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012a2:	00e68663          	beq	a3,a4,800012ae <walkaddr+0x36>
}
    800012a6:	60a2                	ld	ra,8(sp)
    800012a8:	6402                	ld	s0,0(sp)
    800012aa:	0141                	addi	sp,sp,16
    800012ac:	8082                	ret
  pa = PTE2PA(*pte);
    800012ae:	83a9                	srli	a5,a5,0xa
    800012b0:	00c79513          	slli	a0,a5,0xc
  return pa;
    800012b4:	bfcd                	j	800012a6 <walkaddr+0x2e>
    return 0;
    800012b6:	4501                	li	a0,0
    800012b8:	b7fd                	j	800012a6 <walkaddr+0x2e>

00000000800012ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012ba:	715d                	addi	sp,sp,-80
    800012bc:	e486                	sd	ra,72(sp)
    800012be:	e0a2                	sd	s0,64(sp)
    800012c0:	fc26                	sd	s1,56(sp)
    800012c2:	f84a                	sd	s2,48(sp)
    800012c4:	f44e                	sd	s3,40(sp)
    800012c6:	f052                	sd	s4,32(sp)
    800012c8:	ec56                	sd	s5,24(sp)
    800012ca:	e85a                	sd	s6,16(sp)
    800012cc:	e45e                	sd	s7,8(sp)
    800012ce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800012d0:	c639                	beqz	a2,8000131e <mappages+0x64>
    800012d2:	8aaa                	mv	s5,a0
    800012d4:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800012d6:	777d                	lui	a4,0xfffff
    800012d8:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800012dc:	fff58993          	addi	s3,a1,-1
    800012e0:	99b2                	add	s3,s3,a2
    800012e2:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800012e6:	893e                	mv	s2,a5
    800012e8:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800012ec:	6b85                	lui	s7,0x1
    800012ee:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800012f2:	4605                	li	a2,1
    800012f4:	85ca                	mv	a1,s2
    800012f6:	8556                	mv	a0,s5
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	eda080e7          	jalr	-294(ra) # 800011d2 <walk>
    80001300:	cd1d                	beqz	a0,8000133e <mappages+0x84>
    if(*pte & PTE_V)
    80001302:	611c                	ld	a5,0(a0)
    80001304:	8b85                	andi	a5,a5,1
    80001306:	e785                	bnez	a5,8000132e <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001308:	80b1                	srli	s1,s1,0xc
    8000130a:	04aa                	slli	s1,s1,0xa
    8000130c:	0164e4b3          	or	s1,s1,s6
    80001310:	0014e493          	ori	s1,s1,1
    80001314:	e104                	sd	s1,0(a0)
    if(a == last)
    80001316:	05390063          	beq	s2,s3,80001356 <mappages+0x9c>
    a += PGSIZE;
    8000131a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000131c:	bfc9                	j	800012ee <mappages+0x34>
    panic("mappages: size");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	e1a50513          	addi	a0,a0,-486 # 80008138 <digits+0xe8>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	21a080e7          	jalr	538(ra) # 80000540 <panic>
      panic("mappages: remap");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	e1a50513          	addi	a0,a0,-486 # 80008148 <digits+0xf8>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	20a080e7          	jalr	522(ra) # 80000540 <panic>
      return -1;
    8000133e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001340:	60a6                	ld	ra,72(sp)
    80001342:	6406                	ld	s0,64(sp)
    80001344:	74e2                	ld	s1,56(sp)
    80001346:	7942                	ld	s2,48(sp)
    80001348:	79a2                	ld	s3,40(sp)
    8000134a:	7a02                	ld	s4,32(sp)
    8000134c:	6ae2                	ld	s5,24(sp)
    8000134e:	6b42                	ld	s6,16(sp)
    80001350:	6ba2                	ld	s7,8(sp)
    80001352:	6161                	addi	sp,sp,80
    80001354:	8082                	ret
  return 0;
    80001356:	4501                	li	a0,0
    80001358:	b7e5                	j	80001340 <mappages+0x86>

000000008000135a <kvmmap>:
{
    8000135a:	1141                	addi	sp,sp,-16
    8000135c:	e406                	sd	ra,8(sp)
    8000135e:	e022                	sd	s0,0(sp)
    80001360:	0800                	addi	s0,sp,16
    80001362:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001364:	86b2                	mv	a3,a2
    80001366:	863e                	mv	a2,a5
    80001368:	00000097          	auipc	ra,0x0
    8000136c:	f52080e7          	jalr	-174(ra) # 800012ba <mappages>
    80001370:	e509                	bnez	a0,8000137a <kvmmap+0x20>
}
    80001372:	60a2                	ld	ra,8(sp)
    80001374:	6402                	ld	s0,0(sp)
    80001376:	0141                	addi	sp,sp,16
    80001378:	8082                	ret
    panic("kvmmap");
    8000137a:	00007517          	auipc	a0,0x7
    8000137e:	dde50513          	addi	a0,a0,-546 # 80008158 <digits+0x108>
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	1be080e7          	jalr	446(ra) # 80000540 <panic>

000000008000138a <kvmmake>:
{
    8000138a:	1101                	addi	sp,sp,-32
    8000138c:	ec06                	sd	ra,24(sp)
    8000138e:	e822                	sd	s0,16(sp)
    80001390:	e426                	sd	s1,8(sp)
    80001392:	e04a                	sd	s2,0(sp)
    80001394:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	8d2080e7          	jalr	-1838(ra) # 80000c68 <kalloc>
    8000139e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800013a0:	6605                	lui	a2,0x1
    800013a2:	4581                	li	a1,0
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	b4a080e7          	jalr	-1206(ra) # 80000eee <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013ac:	4719                	li	a4,6
    800013ae:	6685                	lui	a3,0x1
    800013b0:	10000637          	lui	a2,0x10000
    800013b4:	100005b7          	lui	a1,0x10000
    800013b8:	8526                	mv	a0,s1
    800013ba:	00000097          	auipc	ra,0x0
    800013be:	fa0080e7          	jalr	-96(ra) # 8000135a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013c2:	4719                	li	a4,6
    800013c4:	6685                	lui	a3,0x1
    800013c6:	10001637          	lui	a2,0x10001
    800013ca:	100015b7          	lui	a1,0x10001
    800013ce:	8526                	mv	a0,s1
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	f8a080e7          	jalr	-118(ra) # 8000135a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013d8:	4719                	li	a4,6
    800013da:	004006b7          	lui	a3,0x400
    800013de:	0c000637          	lui	a2,0xc000
    800013e2:	0c0005b7          	lui	a1,0xc000
    800013e6:	8526                	mv	a0,s1
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	f72080e7          	jalr	-142(ra) # 8000135a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013f0:	00007917          	auipc	s2,0x7
    800013f4:	c1090913          	addi	s2,s2,-1008 # 80008000 <etext>
    800013f8:	4729                	li	a4,10
    800013fa:	80007697          	auipc	a3,0x80007
    800013fe:	c0668693          	addi	a3,a3,-1018 # 8000 <_entry-0x7fff8000>
    80001402:	4605                	li	a2,1
    80001404:	067e                	slli	a2,a2,0x1f
    80001406:	85b2                	mv	a1,a2
    80001408:	8526                	mv	a0,s1
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	f50080e7          	jalr	-176(ra) # 8000135a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001412:	4719                	li	a4,6
    80001414:	46c5                	li	a3,17
    80001416:	06ee                	slli	a3,a3,0x1b
    80001418:	412686b3          	sub	a3,a3,s2
    8000141c:	864a                	mv	a2,s2
    8000141e:	85ca                	mv	a1,s2
    80001420:	8526                	mv	a0,s1
    80001422:	00000097          	auipc	ra,0x0
    80001426:	f38080e7          	jalr	-200(ra) # 8000135a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000142a:	4729                	li	a4,10
    8000142c:	6685                	lui	a3,0x1
    8000142e:	00006617          	auipc	a2,0x6
    80001432:	bd260613          	addi	a2,a2,-1070 # 80007000 <_trampoline>
    80001436:	040005b7          	lui	a1,0x4000
    8000143a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000143c:	05b2                	slli	a1,a1,0xc
    8000143e:	8526                	mv	a0,s1
    80001440:	00000097          	auipc	ra,0x0
    80001444:	f1a080e7          	jalr	-230(ra) # 8000135a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001448:	8526                	mv	a0,s1
    8000144a:	00000097          	auipc	ra,0x0
    8000144e:	712080e7          	jalr	1810(ra) # 80001b5c <proc_mapstacks>
}
    80001452:	8526                	mv	a0,s1
    80001454:	60e2                	ld	ra,24(sp)
    80001456:	6442                	ld	s0,16(sp)
    80001458:	64a2                	ld	s1,8(sp)
    8000145a:	6902                	ld	s2,0(sp)
    8000145c:	6105                	addi	sp,sp,32
    8000145e:	8082                	ret

0000000080001460 <kvminit>:
{
    80001460:	1141                	addi	sp,sp,-16
    80001462:	e406                	sd	ra,8(sp)
    80001464:	e022                	sd	s0,0(sp)
    80001466:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	f22080e7          	jalr	-222(ra) # 8000138a <kvmmake>
    80001470:	00007797          	auipc	a5,0x7
    80001474:	60a7b023          	sd	a0,1536(a5) # 80008a70 <kernel_pagetable>
}
    80001478:	60a2                	ld	ra,8(sp)
    8000147a:	6402                	ld	s0,0(sp)
    8000147c:	0141                	addi	sp,sp,16
    8000147e:	8082                	ret

0000000080001480 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001480:	715d                	addi	sp,sp,-80
    80001482:	e486                	sd	ra,72(sp)
    80001484:	e0a2                	sd	s0,64(sp)
    80001486:	fc26                	sd	s1,56(sp)
    80001488:	f84a                	sd	s2,48(sp)
    8000148a:	f44e                	sd	s3,40(sp)
    8000148c:	f052                	sd	s4,32(sp)
    8000148e:	ec56                	sd	s5,24(sp)
    80001490:	e85a                	sd	s6,16(sp)
    80001492:	e45e                	sd	s7,8(sp)
    80001494:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001496:	03459793          	slli	a5,a1,0x34
    8000149a:	e795                	bnez	a5,800014c6 <uvmunmap+0x46>
    8000149c:	8a2a                	mv	s4,a0
    8000149e:	892e                	mv	s2,a1
    800014a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014a2:	0632                	slli	a2,a2,0xc
    800014a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800014a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014aa:	6b05                	lui	s6,0x1
    800014ac:	0735e263          	bltu	a1,s3,80001510 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800014b0:	60a6                	ld	ra,72(sp)
    800014b2:	6406                	ld	s0,64(sp)
    800014b4:	74e2                	ld	s1,56(sp)
    800014b6:	7942                	ld	s2,48(sp)
    800014b8:	79a2                	ld	s3,40(sp)
    800014ba:	7a02                	ld	s4,32(sp)
    800014bc:	6ae2                	ld	s5,24(sp)
    800014be:	6b42                	ld	s6,16(sp)
    800014c0:	6ba2                	ld	s7,8(sp)
    800014c2:	6161                	addi	sp,sp,80
    800014c4:	8082                	ret
    panic("uvmunmap: not aligned");
    800014c6:	00007517          	auipc	a0,0x7
    800014ca:	c9a50513          	addi	a0,a0,-870 # 80008160 <digits+0x110>
    800014ce:	fffff097          	auipc	ra,0xfffff
    800014d2:	072080e7          	jalr	114(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800014d6:	00007517          	auipc	a0,0x7
    800014da:	ca250513          	addi	a0,a0,-862 # 80008178 <digits+0x128>
    800014de:	fffff097          	auipc	ra,0xfffff
    800014e2:	062080e7          	jalr	98(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800014e6:	00007517          	auipc	a0,0x7
    800014ea:	ca250513          	addi	a0,a0,-862 # 80008188 <digits+0x138>
    800014ee:	fffff097          	auipc	ra,0xfffff
    800014f2:	052080e7          	jalr	82(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800014f6:	00007517          	auipc	a0,0x7
    800014fa:	caa50513          	addi	a0,a0,-854 # 800081a0 <digits+0x150>
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	042080e7          	jalr	66(ra) # 80000540 <panic>
    *pte = 0;
    80001506:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000150a:	995a                	add	s2,s2,s6
    8000150c:	fb3972e3          	bgeu	s2,s3,800014b0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001510:	4601                	li	a2,0
    80001512:	85ca                	mv	a1,s2
    80001514:	8552                	mv	a0,s4
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	cbc080e7          	jalr	-836(ra) # 800011d2 <walk>
    8000151e:	84aa                	mv	s1,a0
    80001520:	d95d                	beqz	a0,800014d6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001522:	6108                	ld	a0,0(a0)
    80001524:	00157793          	andi	a5,a0,1
    80001528:	dfdd                	beqz	a5,800014e6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000152a:	3ff57793          	andi	a5,a0,1023
    8000152e:	fd7784e3          	beq	a5,s7,800014f6 <uvmunmap+0x76>
    if(do_free){
    80001532:	fc0a8ae3          	beqz	s5,80001506 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001536:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001538:	0532                	slli	a0,a0,0xc
    8000153a:	fffff097          	auipc	ra,0xfffff
    8000153e:	53c080e7          	jalr	1340(ra) # 80000a76 <kfree>
    80001542:	b7d1                	j	80001506 <uvmunmap+0x86>

0000000080001544 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001544:	1101                	addi	sp,sp,-32
    80001546:	ec06                	sd	ra,24(sp)
    80001548:	e822                	sd	s0,16(sp)
    8000154a:	e426                	sd	s1,8(sp)
    8000154c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000154e:	fffff097          	auipc	ra,0xfffff
    80001552:	71a080e7          	jalr	1818(ra) # 80000c68 <kalloc>
    80001556:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001558:	c519                	beqz	a0,80001566 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000155a:	6605                	lui	a2,0x1
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	990080e7          	jalr	-1648(ra) # 80000eee <memset>
  return pagetable;
}
    80001566:	8526                	mv	a0,s1
    80001568:	60e2                	ld	ra,24(sp)
    8000156a:	6442                	ld	s0,16(sp)
    8000156c:	64a2                	ld	s1,8(sp)
    8000156e:	6105                	addi	sp,sp,32
    80001570:	8082                	ret

0000000080001572 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001572:	7179                	addi	sp,sp,-48
    80001574:	f406                	sd	ra,40(sp)
    80001576:	f022                	sd	s0,32(sp)
    80001578:	ec26                	sd	s1,24(sp)
    8000157a:	e84a                	sd	s2,16(sp)
    8000157c:	e44e                	sd	s3,8(sp)
    8000157e:	e052                	sd	s4,0(sp)
    80001580:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001582:	6785                	lui	a5,0x1
    80001584:	04f67863          	bgeu	a2,a5,800015d4 <uvmfirst+0x62>
    80001588:	8a2a                	mv	s4,a0
    8000158a:	89ae                	mv	s3,a1
    8000158c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	6da080e7          	jalr	1754(ra) # 80000c68 <kalloc>
    80001596:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001598:	6605                	lui	a2,0x1
    8000159a:	4581                	li	a1,0
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	952080e7          	jalr	-1710(ra) # 80000eee <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015a4:	4779                	li	a4,30
    800015a6:	86ca                	mv	a3,s2
    800015a8:	6605                	lui	a2,0x1
    800015aa:	4581                	li	a1,0
    800015ac:	8552                	mv	a0,s4
    800015ae:	00000097          	auipc	ra,0x0
    800015b2:	d0c080e7          	jalr	-756(ra) # 800012ba <mappages>
  memmove(mem, src, sz);
    800015b6:	8626                	mv	a2,s1
    800015b8:	85ce                	mv	a1,s3
    800015ba:	854a                	mv	a0,s2
    800015bc:	00000097          	auipc	ra,0x0
    800015c0:	98e080e7          	jalr	-1650(ra) # 80000f4a <memmove>
}
    800015c4:	70a2                	ld	ra,40(sp)
    800015c6:	7402                	ld	s0,32(sp)
    800015c8:	64e2                	ld	s1,24(sp)
    800015ca:	6942                	ld	s2,16(sp)
    800015cc:	69a2                	ld	s3,8(sp)
    800015ce:	6a02                	ld	s4,0(sp)
    800015d0:	6145                	addi	sp,sp,48
    800015d2:	8082                	ret
    panic("uvmfirst: more than a page");
    800015d4:	00007517          	auipc	a0,0x7
    800015d8:	be450513          	addi	a0,a0,-1052 # 800081b8 <digits+0x168>
    800015dc:	fffff097          	auipc	ra,0xfffff
    800015e0:	f64080e7          	jalr	-156(ra) # 80000540 <panic>

00000000800015e4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015e4:	1101                	addi	sp,sp,-32
    800015e6:	ec06                	sd	ra,24(sp)
    800015e8:	e822                	sd	s0,16(sp)
    800015ea:	e426                	sd	s1,8(sp)
    800015ec:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015ee:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015f0:	00b67d63          	bgeu	a2,a1,8000160a <uvmdealloc+0x26>
    800015f4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015f6:	6785                	lui	a5,0x1
    800015f8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015fa:	00f60733          	add	a4,a2,a5
    800015fe:	76fd                	lui	a3,0xfffff
    80001600:	8f75                	and	a4,a4,a3
    80001602:	97ae                	add	a5,a5,a1
    80001604:	8ff5                	and	a5,a5,a3
    80001606:	00f76863          	bltu	a4,a5,80001616 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000160a:	8526                	mv	a0,s1
    8000160c:	60e2                	ld	ra,24(sp)
    8000160e:	6442                	ld	s0,16(sp)
    80001610:	64a2                	ld	s1,8(sp)
    80001612:	6105                	addi	sp,sp,32
    80001614:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001616:	8f99                	sub	a5,a5,a4
    80001618:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000161a:	4685                	li	a3,1
    8000161c:	0007861b          	sext.w	a2,a5
    80001620:	85ba                	mv	a1,a4
    80001622:	00000097          	auipc	ra,0x0
    80001626:	e5e080e7          	jalr	-418(ra) # 80001480 <uvmunmap>
    8000162a:	b7c5                	j	8000160a <uvmdealloc+0x26>

000000008000162c <uvmalloc>:
  if(newsz < oldsz)
    8000162c:	0ab66563          	bltu	a2,a1,800016d6 <uvmalloc+0xaa>
{
    80001630:	7139                	addi	sp,sp,-64
    80001632:	fc06                	sd	ra,56(sp)
    80001634:	f822                	sd	s0,48(sp)
    80001636:	f426                	sd	s1,40(sp)
    80001638:	f04a                	sd	s2,32(sp)
    8000163a:	ec4e                	sd	s3,24(sp)
    8000163c:	e852                	sd	s4,16(sp)
    8000163e:	e456                	sd	s5,8(sp)
    80001640:	e05a                	sd	s6,0(sp)
    80001642:	0080                	addi	s0,sp,64
    80001644:	8aaa                	mv	s5,a0
    80001646:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001648:	6785                	lui	a5,0x1
    8000164a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000164c:	95be                	add	a1,a1,a5
    8000164e:	77fd                	lui	a5,0xfffff
    80001650:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001654:	08c9f363          	bgeu	s3,a2,800016da <uvmalloc+0xae>
    80001658:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000165a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	60a080e7          	jalr	1546(ra) # 80000c68 <kalloc>
    80001666:	84aa                	mv	s1,a0
    if(mem == 0){
    80001668:	c51d                	beqz	a0,80001696 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000166a:	6605                	lui	a2,0x1
    8000166c:	4581                	li	a1,0
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	880080e7          	jalr	-1920(ra) # 80000eee <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001676:	875a                	mv	a4,s6
    80001678:	86a6                	mv	a3,s1
    8000167a:	6605                	lui	a2,0x1
    8000167c:	85ca                	mv	a1,s2
    8000167e:	8556                	mv	a0,s5
    80001680:	00000097          	auipc	ra,0x0
    80001684:	c3a080e7          	jalr	-966(ra) # 800012ba <mappages>
    80001688:	e90d                	bnez	a0,800016ba <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000168a:	6785                	lui	a5,0x1
    8000168c:	993e                	add	s2,s2,a5
    8000168e:	fd4968e3          	bltu	s2,s4,8000165e <uvmalloc+0x32>
  return newsz;
    80001692:	8552                	mv	a0,s4
    80001694:	a809                	j	800016a6 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001696:	864e                	mv	a2,s3
    80001698:	85ca                	mv	a1,s2
    8000169a:	8556                	mv	a0,s5
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	f48080e7          	jalr	-184(ra) # 800015e4 <uvmdealloc>
      return 0;
    800016a4:	4501                	li	a0,0
}
    800016a6:	70e2                	ld	ra,56(sp)
    800016a8:	7442                	ld	s0,48(sp)
    800016aa:	74a2                	ld	s1,40(sp)
    800016ac:	7902                	ld	s2,32(sp)
    800016ae:	69e2                	ld	s3,24(sp)
    800016b0:	6a42                	ld	s4,16(sp)
    800016b2:	6aa2                	ld	s5,8(sp)
    800016b4:	6b02                	ld	s6,0(sp)
    800016b6:	6121                	addi	sp,sp,64
    800016b8:	8082                	ret
      kfree(mem);
    800016ba:	8526                	mv	a0,s1
    800016bc:	fffff097          	auipc	ra,0xfffff
    800016c0:	3ba080e7          	jalr	954(ra) # 80000a76 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016c4:	864e                	mv	a2,s3
    800016c6:	85ca                	mv	a1,s2
    800016c8:	8556                	mv	a0,s5
    800016ca:	00000097          	auipc	ra,0x0
    800016ce:	f1a080e7          	jalr	-230(ra) # 800015e4 <uvmdealloc>
      return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	bfc9                	j	800016a6 <uvmalloc+0x7a>
    return oldsz;
    800016d6:	852e                	mv	a0,a1
}
    800016d8:	8082                	ret
  return newsz;
    800016da:	8532                	mv	a0,a2
    800016dc:	b7e9                	j	800016a6 <uvmalloc+0x7a>

00000000800016de <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016de:	7179                	addi	sp,sp,-48
    800016e0:	f406                	sd	ra,40(sp)
    800016e2:	f022                	sd	s0,32(sp)
    800016e4:	ec26                	sd	s1,24(sp)
    800016e6:	e84a                	sd	s2,16(sp)
    800016e8:	e44e                	sd	s3,8(sp)
    800016ea:	e052                	sd	s4,0(sp)
    800016ec:	1800                	addi	s0,sp,48
    800016ee:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016f0:	84aa                	mv	s1,a0
    800016f2:	6905                	lui	s2,0x1
    800016f4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016f6:	4985                	li	s3,1
    800016f8:	a829                	j	80001712 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016fa:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800016fc:	00c79513          	slli	a0,a5,0xc
    80001700:	00000097          	auipc	ra,0x0
    80001704:	fde080e7          	jalr	-34(ra) # 800016de <freewalk>
      pagetable[i] = 0;
    80001708:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000170c:	04a1                	addi	s1,s1,8
    8000170e:	03248163          	beq	s1,s2,80001730 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001712:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001714:	00f7f713          	andi	a4,a5,15
    80001718:	ff3701e3          	beq	a4,s3,800016fa <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000171c:	8b85                	andi	a5,a5,1
    8000171e:	d7fd                	beqz	a5,8000170c <freewalk+0x2e>
      panic("freewalk: leaf");
    80001720:	00007517          	auipc	a0,0x7
    80001724:	ab850513          	addi	a0,a0,-1352 # 800081d8 <digits+0x188>
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	e18080e7          	jalr	-488(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	344080e7          	jalr	836(ra) # 80000a76 <kfree>
}
    8000173a:	70a2                	ld	ra,40(sp)
    8000173c:	7402                	ld	s0,32(sp)
    8000173e:	64e2                	ld	s1,24(sp)
    80001740:	6942                	ld	s2,16(sp)
    80001742:	69a2                	ld	s3,8(sp)
    80001744:	6a02                	ld	s4,0(sp)
    80001746:	6145                	addi	sp,sp,48
    80001748:	8082                	ret

000000008000174a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000174a:	1101                	addi	sp,sp,-32
    8000174c:	ec06                	sd	ra,24(sp)
    8000174e:	e822                	sd	s0,16(sp)
    80001750:	e426                	sd	s1,8(sp)
    80001752:	1000                	addi	s0,sp,32
    80001754:	84aa                	mv	s1,a0
  if(sz > 0)
    80001756:	e999                	bnez	a1,8000176c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001758:	8526                	mv	a0,s1
    8000175a:	00000097          	auipc	ra,0x0
    8000175e:	f84080e7          	jalr	-124(ra) # 800016de <freewalk>
}
    80001762:	60e2                	ld	ra,24(sp)
    80001764:	6442                	ld	s0,16(sp)
    80001766:	64a2                	ld	s1,8(sp)
    80001768:	6105                	addi	sp,sp,32
    8000176a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000176c:	6785                	lui	a5,0x1
    8000176e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001770:	95be                	add	a1,a1,a5
    80001772:	4685                	li	a3,1
    80001774:	00c5d613          	srli	a2,a1,0xc
    80001778:	4581                	li	a1,0
    8000177a:	00000097          	auipc	ra,0x0
    8000177e:	d06080e7          	jalr	-762(ra) # 80001480 <uvmunmap>
    80001782:	bfd9                	j	80001758 <uvmfree+0xe>

0000000080001784 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001784:	c655                	beqz	a2,80001830 <uvmcopy+0xac>
{
    80001786:	7179                	addi	sp,sp,-48
    80001788:	f406                	sd	ra,40(sp)
    8000178a:	f022                	sd	s0,32(sp)
    8000178c:	ec26                	sd	s1,24(sp)
    8000178e:	e84a                	sd	s2,16(sp)
    80001790:	e44e                	sd	s3,8(sp)
    80001792:	e052                	sd	s4,0(sp)
    80001794:	1800                	addi	s0,sp,48
    80001796:	8a2a                	mv	s4,a0
    80001798:	89ae                	mv	s3,a1
    8000179a:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000179c:	4481                	li	s1,0
    8000179e:	a081                	j	800017de <uvmcopy+0x5a>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    800017a0:	00007517          	auipc	a0,0x7
    800017a4:	a4850513          	addi	a0,a0,-1464 # 800081e8 <digits+0x198>
    800017a8:	fffff097          	auipc	ra,0xfffff
    800017ac:	d98080e7          	jalr	-616(ra) # 80000540 <panic>
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    800017b0:	00007517          	auipc	a0,0x7
    800017b4:	a5850513          	addi	a0,a0,-1448 # 80008208 <digits+0x1b8>
    800017b8:	fffff097          	auipc	ra,0xfffff
    800017bc:	d88080e7          	jalr	-632(ra) # 80000540 <panic>
    {
	*pte &= ~PTE_W; // remove write access
	*pte |= PTE_COW;
    }
    
    flags = PTE_FLAGS(*pte);
    800017c0:	6118                	ld	a4,0(a0)

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800017c2:	3ff77713          	andi	a4,a4,1023
    800017c6:	6605                	lui	a2,0x1
    800017c8:	85a6                	mv	a1,s1
    800017ca:	854e                	mv	a0,s3
    800017cc:	00000097          	auipc	ra,0x0
    800017d0:	aee080e7          	jalr	-1298(ra) # 800012ba <mappages>
    800017d4:	ed05                	bnez	a0,8000180c <uvmcopy+0x88>
  for(i = 0; i < sz; i += PGSIZE){
    800017d6:	6785                	lui	a5,0x1
    800017d8:	94be                	add	s1,s1,a5
    800017da:	0524f363          	bgeu	s1,s2,80001820 <uvmcopy+0x9c>
    if((pte = walk(old, i, 0)) == 0)
    800017de:	4601                	li	a2,0
    800017e0:	85a6                	mv	a1,s1
    800017e2:	8552                	mv	a0,s4
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	9ee080e7          	jalr	-1554(ra) # 800011d2 <walk>
    800017ec:	d955                	beqz	a0,800017a0 <uvmcopy+0x1c>
    if((*pte & PTE_V) == 0)
    800017ee:	611c                	ld	a5,0(a0)
    800017f0:	0017f713          	andi	a4,a5,1
    800017f4:	df55                	beqz	a4,800017b0 <uvmcopy+0x2c>
    pa = PTE2PA(*pte);
    800017f6:	00a7d693          	srli	a3,a5,0xa
    800017fa:	06b2                	slli	a3,a3,0xc
    if (*pte & PTE_W)
    800017fc:	0047f713          	andi	a4,a5,4
    80001800:	d361                	beqz	a4,800017c0 <uvmcopy+0x3c>
	*pte &= ~PTE_W; // remove write access
    80001802:	9bed                	andi	a5,a5,-5
	*pte |= PTE_COW;
    80001804:	2007e793          	ori	a5,a5,512
    80001808:	e11c                	sd	a5,0(a0)
    8000180a:	bf5d                	j	800017c0 <uvmcopy+0x3c>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000180c:	4685                	li	a3,1
    8000180e:	00c4d613          	srli	a2,s1,0xc
    80001812:	4581                	li	a1,0
    80001814:	854e                	mv	a0,s3
    80001816:	00000097          	auipc	ra,0x0
    8000181a:	c6a080e7          	jalr	-918(ra) # 80001480 <uvmunmap>
  return -1;
    8000181e:	557d                	li	a0,-1
}
    80001820:	70a2                	ld	ra,40(sp)
    80001822:	7402                	ld	s0,32(sp)
    80001824:	64e2                	ld	s1,24(sp)
    80001826:	6942                	ld	s2,16(sp)
    80001828:	69a2                	ld	s3,8(sp)
    8000182a:	6a02                	ld	s4,0(sp)
    8000182c:	6145                	addi	sp,sp,48
    8000182e:	8082                	ret
  return 0;
    80001830:	4501                	li	a0,0
}
    80001832:	8082                	ret

0000000080001834 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001834:	1141                	addi	sp,sp,-16
    80001836:	e406                	sd	ra,8(sp)
    80001838:	e022                	sd	s0,0(sp)
    8000183a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000183c:	4601                	li	a2,0
    8000183e:	00000097          	auipc	ra,0x0
    80001842:	994080e7          	jalr	-1644(ra) # 800011d2 <walk>
  if(pte == 0)
    80001846:	c901                	beqz	a0,80001856 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001848:	611c                	ld	a5,0(a0)
    8000184a:	9bbd                	andi	a5,a5,-17
    8000184c:	e11c                	sd	a5,0(a0)
}
    8000184e:	60a2                	ld	ra,8(sp)
    80001850:	6402                	ld	s0,0(sp)
    80001852:	0141                	addi	sp,sp,16
    80001854:	8082                	ret
    panic("uvmclear");
    80001856:	00007517          	auipc	a0,0x7
    8000185a:	9d250513          	addi	a0,a0,-1582 # 80008228 <digits+0x1d8>
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	ce2080e7          	jalr	-798(ra) # 80000540 <panic>

0000000080001866 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001866:	c6bd                	beqz	a3,800018d4 <copyout+0x6e>
{
    80001868:	715d                	addi	sp,sp,-80
    8000186a:	e486                	sd	ra,72(sp)
    8000186c:	e0a2                	sd	s0,64(sp)
    8000186e:	fc26                	sd	s1,56(sp)
    80001870:	f84a                	sd	s2,48(sp)
    80001872:	f44e                	sd	s3,40(sp)
    80001874:	f052                	sd	s4,32(sp)
    80001876:	ec56                	sd	s5,24(sp)
    80001878:	e85a                	sd	s6,16(sp)
    8000187a:	e45e                	sd	s7,8(sp)
    8000187c:	e062                	sd	s8,0(sp)
    8000187e:	0880                	addi	s0,sp,80
    80001880:	8b2a                	mv	s6,a0
    80001882:	8c2e                	mv	s8,a1
    80001884:	8a32                	mv	s4,a2
    80001886:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001888:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000188a:	6a85                	lui	s5,0x1
    8000188c:	a015                	j	800018b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000188e:	9562                	add	a0,a0,s8
    80001890:	0004861b          	sext.w	a2,s1
    80001894:	85d2                	mv	a1,s4
    80001896:	41250533          	sub	a0,a0,s2
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	6b0080e7          	jalr	1712(ra) # 80000f4a <memmove>

    len -= n;
    800018a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800018a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800018a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018ac:	02098263          	beqz	s3,800018d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800018b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018b4:	85ca                	mv	a1,s2
    800018b6:	855a                	mv	a0,s6
    800018b8:	00000097          	auipc	ra,0x0
    800018bc:	9c0080e7          	jalr	-1600(ra) # 80001278 <walkaddr>
    if(pa0 == 0)
    800018c0:	cd01                	beqz	a0,800018d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800018c2:	418904b3          	sub	s1,s2,s8
    800018c6:	94d6                	add	s1,s1,s5
    800018c8:	fc99f3e3          	bgeu	s3,s1,8000188e <copyout+0x28>
    800018cc:	84ce                	mv	s1,s3
    800018ce:	b7c1                	j	8000188e <copyout+0x28>
  }
  return 0;
    800018d0:	4501                	li	a0,0
    800018d2:	a021                	j	800018da <copyout+0x74>
    800018d4:	4501                	li	a0,0
}
    800018d6:	8082                	ret
      return -1;
    800018d8:	557d                	li	a0,-1
}
    800018da:	60a6                	ld	ra,72(sp)
    800018dc:	6406                	ld	s0,64(sp)
    800018de:	74e2                	ld	s1,56(sp)
    800018e0:	7942                	ld	s2,48(sp)
    800018e2:	79a2                	ld	s3,40(sp)
    800018e4:	7a02                	ld	s4,32(sp)
    800018e6:	6ae2                	ld	s5,24(sp)
    800018e8:	6b42                	ld	s6,16(sp)
    800018ea:	6ba2                	ld	s7,8(sp)
    800018ec:	6c02                	ld	s8,0(sp)
    800018ee:	6161                	addi	sp,sp,80
    800018f0:	8082                	ret

00000000800018f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018f2:	caa5                	beqz	a3,80001962 <copyin+0x70>
{
    800018f4:	715d                	addi	sp,sp,-80
    800018f6:	e486                	sd	ra,72(sp)
    800018f8:	e0a2                	sd	s0,64(sp)
    800018fa:	fc26                	sd	s1,56(sp)
    800018fc:	f84a                	sd	s2,48(sp)
    800018fe:	f44e                	sd	s3,40(sp)
    80001900:	f052                	sd	s4,32(sp)
    80001902:	ec56                	sd	s5,24(sp)
    80001904:	e85a                	sd	s6,16(sp)
    80001906:	e45e                	sd	s7,8(sp)
    80001908:	e062                	sd	s8,0(sp)
    8000190a:	0880                	addi	s0,sp,80
    8000190c:	8b2a                	mv	s6,a0
    8000190e:	8a2e                	mv	s4,a1
    80001910:	8c32                	mv	s8,a2
    80001912:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001914:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001916:	6a85                	lui	s5,0x1
    80001918:	a01d                	j	8000193e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000191a:	018505b3          	add	a1,a0,s8
    8000191e:	0004861b          	sext.w	a2,s1
    80001922:	412585b3          	sub	a1,a1,s2
    80001926:	8552                	mv	a0,s4
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	622080e7          	jalr	1570(ra) # 80000f4a <memmove>

    len -= n;
    80001930:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001934:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001936:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000193a:	02098263          	beqz	s3,8000195e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000193e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001942:	85ca                	mv	a1,s2
    80001944:	855a                	mv	a0,s6
    80001946:	00000097          	auipc	ra,0x0
    8000194a:	932080e7          	jalr	-1742(ra) # 80001278 <walkaddr>
    if(pa0 == 0)
    8000194e:	cd01                	beqz	a0,80001966 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001950:	418904b3          	sub	s1,s2,s8
    80001954:	94d6                	add	s1,s1,s5
    80001956:	fc99f2e3          	bgeu	s3,s1,8000191a <copyin+0x28>
    8000195a:	84ce                	mv	s1,s3
    8000195c:	bf7d                	j	8000191a <copyin+0x28>
  }
  return 0;
    8000195e:	4501                	li	a0,0
    80001960:	a021                	j	80001968 <copyin+0x76>
    80001962:	4501                	li	a0,0
}
    80001964:	8082                	ret
      return -1;
    80001966:	557d                	li	a0,-1
}
    80001968:	60a6                	ld	ra,72(sp)
    8000196a:	6406                	ld	s0,64(sp)
    8000196c:	74e2                	ld	s1,56(sp)
    8000196e:	7942                	ld	s2,48(sp)
    80001970:	79a2                	ld	s3,40(sp)
    80001972:	7a02                	ld	s4,32(sp)
    80001974:	6ae2                	ld	s5,24(sp)
    80001976:	6b42                	ld	s6,16(sp)
    80001978:	6ba2                	ld	s7,8(sp)
    8000197a:	6c02                	ld	s8,0(sp)
    8000197c:	6161                	addi	sp,sp,80
    8000197e:	8082                	ret

0000000080001980 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001980:	c2dd                	beqz	a3,80001a26 <copyinstr+0xa6>
{
    80001982:	715d                	addi	sp,sp,-80
    80001984:	e486                	sd	ra,72(sp)
    80001986:	e0a2                	sd	s0,64(sp)
    80001988:	fc26                	sd	s1,56(sp)
    8000198a:	f84a                	sd	s2,48(sp)
    8000198c:	f44e                	sd	s3,40(sp)
    8000198e:	f052                	sd	s4,32(sp)
    80001990:	ec56                	sd	s5,24(sp)
    80001992:	e85a                	sd	s6,16(sp)
    80001994:	e45e                	sd	s7,8(sp)
    80001996:	0880                	addi	s0,sp,80
    80001998:	8a2a                	mv	s4,a0
    8000199a:	8b2e                	mv	s6,a1
    8000199c:	8bb2                	mv	s7,a2
    8000199e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800019a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019a2:	6985                	lui	s3,0x1
    800019a4:	a02d                	j	800019ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800019a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800019aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800019ac:	37fd                	addiw	a5,a5,-1
    800019ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800019b2:	60a6                	ld	ra,72(sp)
    800019b4:	6406                	ld	s0,64(sp)
    800019b6:	74e2                	ld	s1,56(sp)
    800019b8:	7942                	ld	s2,48(sp)
    800019ba:	79a2                	ld	s3,40(sp)
    800019bc:	7a02                	ld	s4,32(sp)
    800019be:	6ae2                	ld	s5,24(sp)
    800019c0:	6b42                	ld	s6,16(sp)
    800019c2:	6ba2                	ld	s7,8(sp)
    800019c4:	6161                	addi	sp,sp,80
    800019c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800019c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800019cc:	c8a9                	beqz	s1,80001a1e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800019ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800019d2:	85ca                	mv	a1,s2
    800019d4:	8552                	mv	a0,s4
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	8a2080e7          	jalr	-1886(ra) # 80001278 <walkaddr>
    if(pa0 == 0)
    800019de:	c131                	beqz	a0,80001a22 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800019e0:	417906b3          	sub	a3,s2,s7
    800019e4:	96ce                	add	a3,a3,s3
    800019e6:	00d4f363          	bgeu	s1,a3,800019ec <copyinstr+0x6c>
    800019ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019ec:	955e                	add	a0,a0,s7
    800019ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019f2:	daf9                	beqz	a3,800019c8 <copyinstr+0x48>
    800019f4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019f6:	41650633          	sub	a2,a0,s6
    800019fa:	fff48593          	addi	a1,s1,-1
    800019fe:	95da                	add	a1,a1,s6
    while(n > 0){
    80001a00:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001a02:	00f60733          	add	a4,a2,a5
    80001a06:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd0e8>
    80001a0a:	df51                	beqz	a4,800019a6 <copyinstr+0x26>
        *dst = *p;
    80001a0c:	00e78023          	sb	a4,0(a5)
      --max;
    80001a10:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001a14:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a16:	fed796e3          	bne	a5,a3,80001a02 <copyinstr+0x82>
      dst++;
    80001a1a:	8b3e                	mv	s6,a5
    80001a1c:	b775                	j	800019c8 <copyinstr+0x48>
    80001a1e:	4781                	li	a5,0
    80001a20:	b771                	j	800019ac <copyinstr+0x2c>
      return -1;
    80001a22:	557d                	li	a0,-1
    80001a24:	b779                	j	800019b2 <copyinstr+0x32>
  int got_null = 0;
    80001a26:	4781                	li	a5,0
  if(got_null){
    80001a28:	37fd                	addiw	a5,a5,-1
    80001a2a:	0007851b          	sext.w	a0,a5
}
    80001a2e:	8082                	ret

0000000080001a30 <transvirt>:

uint64 transvirt(uint64 vaddr, pagetable_t pagetable)
{
    80001a30:	1141                	addi	sp,sp,-16
    80001a32:	e422                	sd	s0,8(sp)
    80001a34:	0800                	addi	s0,sp,16
    80001a36:	872a                	mv	a4,a0
    for (int level = 2; level > 0; level--)
    {
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001a38:	01e55793          	srli	a5,a0,0x1e
    80001a3c:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001a40:	078e                	slli	a5,a5,0x3
    80001a42:	95be                	add	a1,a1,a5
    80001a44:	619c                	ld	a5,0(a1)
    80001a46:	0017f513          	andi	a0,a5,1
    80001a4a:	cd15                	beqz	a0,80001a86 <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001a4c:	83a9                	srli	a5,a5,0xa
    80001a4e:	00c79693          	slli	a3,a5,0xc
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001a52:	01575793          	srli	a5,a4,0x15
    80001a56:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001a5a:	078e                	slli	a5,a5,0x3
    80001a5c:	97b6                	add	a5,a5,a3
    80001a5e:	639c                	ld	a5,0(a5)
    80001a60:	0017f513          	andi	a0,a5,1
    80001a64:	c10d                	beqz	a0,80001a86 <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001a66:	83a9                	srli	a5,a5,0xa
    80001a68:	00c79693          	slli	a3,a5,0xc
	} else {
	    return 0;
	}
    }
    uint64 pagenum = PTE2PA(pagetable[PX(0, vaddr)]);
    80001a6c:	00c75793          	srli	a5,a4,0xc
    80001a70:	1ff7f793          	andi	a5,a5,511
    80001a74:	078e                	slli	a5,a5,0x3
    80001a76:	97b6                	add	a5,a5,a3
    80001a78:	639c                	ld	a5,0(a5)
    80001a7a:	83a9                	srli	a5,a5,0xa
    80001a7c:	07b2                	slli	a5,a5,0xc
    uint64 offset = vaddr & 0xFFF;
    80001a7e:	1752                	slli	a4,a4,0x34
    80001a80:	9351                	srli	a4,a4,0x34
    return pagenum | offset;
    80001a82:	00e7e533          	or	a0,a5,a4
}
    80001a86:	6422                	ld	s0,8(sp)
    80001a88:	0141                	addi	sp,sp,16
    80001a8a:	8082                	ret

0000000080001a8c <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001a8c:	715d                	addi	sp,sp,-80
    80001a8e:	e486                	sd	ra,72(sp)
    80001a90:	e0a2                	sd	s0,64(sp)
    80001a92:	fc26                	sd	s1,56(sp)
    80001a94:	f84a                	sd	s2,48(sp)
    80001a96:	f44e                	sd	s3,40(sp)
    80001a98:	f052                	sd	s4,32(sp)
    80001a9a:	ec56                	sd	s5,24(sp)
    80001a9c:	e85a                	sd	s6,16(sp)
    80001a9e:	e45e                	sd	s7,8(sp)
    80001aa0:	e062                	sd	s8,0(sp)
    80001aa2:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001aa4:	8792                	mv	a5,tp
    int id = r_tp();
    80001aa6:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001aa8:	0002fa97          	auipc	s5,0x2f
    80001aac:	260a8a93          	addi	s5,s5,608 # 80030d08 <cpus>
    80001ab0:	00779713          	slli	a4,a5,0x7
    80001ab4:	00ea86b3          	add	a3,s5,a4
    80001ab8:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffbd0e8>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001abc:	0721                	addi	a4,a4,8
    80001abe:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001ac0:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001ac2:	00007c17          	auipc	s8,0x7
    80001ac6:	ee6c0c13          	addi	s8,s8,-282 # 800089a8 <sched_pointer>
    80001aca:	00000b97          	auipc	s7,0x0
    80001ace:	fc2b8b93          	addi	s7,s7,-62 # 80001a8c <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001ad2:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ad6:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001ada:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001ade:	0002f497          	auipc	s1,0x2f
    80001ae2:	65a48493          	addi	s1,s1,1626 # 80031138 <proc>
            if (p->state == RUNNABLE)
    80001ae6:	498d                	li	s3,3
                p->state = RUNNING;
    80001ae8:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001aea:	00035a17          	auipc	s4,0x35
    80001aee:	04ea0a13          	addi	s4,s4,78 # 80036b38 <tickslock>
    80001af2:	a81d                	j	80001b28 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001af4:	8526                	mv	a0,s1
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	3b0080e7          	jalr	944(ra) # 80000ea6 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001afe:	60a6                	ld	ra,72(sp)
    80001b00:	6406                	ld	s0,64(sp)
    80001b02:	74e2                	ld	s1,56(sp)
    80001b04:	7942                	ld	s2,48(sp)
    80001b06:	79a2                	ld	s3,40(sp)
    80001b08:	7a02                	ld	s4,32(sp)
    80001b0a:	6ae2                	ld	s5,24(sp)
    80001b0c:	6b42                	ld	s6,16(sp)
    80001b0e:	6ba2                	ld	s7,8(sp)
    80001b10:	6c02                	ld	s8,0(sp)
    80001b12:	6161                	addi	sp,sp,80
    80001b14:	8082                	ret
            release(&p->lock);
    80001b16:	8526                	mv	a0,s1
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	38e080e7          	jalr	910(ra) # 80000ea6 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001b20:	16848493          	addi	s1,s1,360
    80001b24:	fb4487e3          	beq	s1,s4,80001ad2 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	2c8080e7          	jalr	712(ra) # 80000df2 <acquire>
            if (p->state == RUNNABLE)
    80001b32:	4c9c                	lw	a5,24(s1)
    80001b34:	ff3791e3          	bne	a5,s3,80001b16 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001b38:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001b3c:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    80001b40:	06048593          	addi	a1,s1,96
    80001b44:	8556                	mv	a0,s5
    80001b46:	00001097          	auipc	ra,0x1
    80001b4a:	024080e7          	jalr	36(ra) # 80002b6a <swtch>
                if (sched_pointer != &rr_scheduler)
    80001b4e:	000c3783          	ld	a5,0(s8)
    80001b52:	fb7791e3          	bne	a5,s7,80001af4 <rr_scheduler+0x68>
                c->proc = 0;
    80001b56:	00093023          	sd	zero,0(s2)
    80001b5a:	bf75                	j	80001b16 <rr_scheduler+0x8a>

0000000080001b5c <proc_mapstacks>:
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
    80001b70:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001b72:	0002f497          	auipc	s1,0x2f
    80001b76:	5c648493          	addi	s1,s1,1478 # 80031138 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001b7a:	8b26                	mv	s6,s1
    80001b7c:	00006a97          	auipc	s5,0x6
    80001b80:	494a8a93          	addi	s5,s5,1172 # 80008010 <__func__.1+0x8>
    80001b84:	04000937          	lui	s2,0x4000
    80001b88:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b8a:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b8c:	00035a17          	auipc	s4,0x35
    80001b90:	faca0a13          	addi	s4,s4,-84 # 80036b38 <tickslock>
        char *pa = kalloc();
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	0d4080e7          	jalr	212(ra) # 80000c68 <kalloc>
    80001b9c:	862a                	mv	a2,a0
        if (pa == 0)
    80001b9e:	c131                	beqz	a0,80001be2 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001ba0:	416485b3          	sub	a1,s1,s6
    80001ba4:	858d                	srai	a1,a1,0x3
    80001ba6:	000ab783          	ld	a5,0(s5)
    80001baa:	02f585b3          	mul	a1,a1,a5
    80001bae:	2585                	addiw	a1,a1,1
    80001bb0:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bb4:	4719                	li	a4,6
    80001bb6:	6685                	lui	a3,0x1
    80001bb8:	40b905b3          	sub	a1,s2,a1
    80001bbc:	854e                	mv	a0,s3
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	79c080e7          	jalr	1948(ra) # 8000135a <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001bc6:	16848493          	addi	s1,s1,360
    80001bca:	fd4495e3          	bne	s1,s4,80001b94 <proc_mapstacks+0x38>
}
    80001bce:	70e2                	ld	ra,56(sp)
    80001bd0:	7442                	ld	s0,48(sp)
    80001bd2:	74a2                	ld	s1,40(sp)
    80001bd4:	7902                	ld	s2,32(sp)
    80001bd6:	69e2                	ld	s3,24(sp)
    80001bd8:	6a42                	ld	s4,16(sp)
    80001bda:	6aa2                	ld	s5,8(sp)
    80001bdc:	6b02                	ld	s6,0(sp)
    80001bde:	6121                	addi	sp,sp,64
    80001be0:	8082                	ret
            panic("kalloc");
    80001be2:	00006517          	auipc	a0,0x6
    80001be6:	65650513          	addi	a0,a0,1622 # 80008238 <digits+0x1e8>
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	956080e7          	jalr	-1706(ra) # 80000540 <panic>

0000000080001bf2 <procinit>:
{
    80001bf2:	7139                	addi	sp,sp,-64
    80001bf4:	fc06                	sd	ra,56(sp)
    80001bf6:	f822                	sd	s0,48(sp)
    80001bf8:	f426                	sd	s1,40(sp)
    80001bfa:	f04a                	sd	s2,32(sp)
    80001bfc:	ec4e                	sd	s3,24(sp)
    80001bfe:	e852                	sd	s4,16(sp)
    80001c00:	e456                	sd	s5,8(sp)
    80001c02:	e05a                	sd	s6,0(sp)
    80001c04:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001c06:	00006597          	auipc	a1,0x6
    80001c0a:	63a58593          	addi	a1,a1,1594 # 80008240 <digits+0x1f0>
    80001c0e:	0002f517          	auipc	a0,0x2f
    80001c12:	4fa50513          	addi	a0,a0,1274 # 80031108 <pid_lock>
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	14c080e7          	jalr	332(ra) # 80000d62 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001c1e:	00006597          	auipc	a1,0x6
    80001c22:	62a58593          	addi	a1,a1,1578 # 80008248 <digits+0x1f8>
    80001c26:	0002f517          	auipc	a0,0x2f
    80001c2a:	4fa50513          	addi	a0,a0,1274 # 80031120 <wait_lock>
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	134080e7          	jalr	308(ra) # 80000d62 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001c36:	0002f497          	auipc	s1,0x2f
    80001c3a:	50248493          	addi	s1,s1,1282 # 80031138 <proc>
        initlock(&p->lock, "proc");
    80001c3e:	00006b17          	auipc	s6,0x6
    80001c42:	61ab0b13          	addi	s6,s6,1562 # 80008258 <digits+0x208>
        p->kstack = KSTACK((int)(p - proc));
    80001c46:	8aa6                	mv	s5,s1
    80001c48:	00006a17          	auipc	s4,0x6
    80001c4c:	3c8a0a13          	addi	s4,s4,968 # 80008010 <__func__.1+0x8>
    80001c50:	04000937          	lui	s2,0x4000
    80001c54:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001c56:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001c58:	00035997          	auipc	s3,0x35
    80001c5c:	ee098993          	addi	s3,s3,-288 # 80036b38 <tickslock>
        initlock(&p->lock, "proc");
    80001c60:	85da                	mv	a1,s6
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	0fe080e7          	jalr	254(ra) # 80000d62 <initlock>
        p->state = UNUSED;
    80001c6c:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001c70:	415487b3          	sub	a5,s1,s5
    80001c74:	878d                	srai	a5,a5,0x3
    80001c76:	000a3703          	ld	a4,0(s4)
    80001c7a:	02e787b3          	mul	a5,a5,a4
    80001c7e:	2785                	addiw	a5,a5,1
    80001c80:	00d7979b          	slliw	a5,a5,0xd
    80001c84:	40f907b3          	sub	a5,s2,a5
    80001c88:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001c8a:	16848493          	addi	s1,s1,360
    80001c8e:	fd3499e3          	bne	s1,s3,80001c60 <procinit+0x6e>
}
    80001c92:	70e2                	ld	ra,56(sp)
    80001c94:	7442                	ld	s0,48(sp)
    80001c96:	74a2                	ld	s1,40(sp)
    80001c98:	7902                	ld	s2,32(sp)
    80001c9a:	69e2                	ld	s3,24(sp)
    80001c9c:	6a42                	ld	s4,16(sp)
    80001c9e:	6aa2                	ld	s5,8(sp)
    80001ca0:	6b02                	ld	s6,0(sp)
    80001ca2:	6121                	addi	sp,sp,64
    80001ca4:	8082                	ret

0000000080001ca6 <copy_array>:
{
    80001ca6:	1141                	addi	sp,sp,-16
    80001ca8:	e422                	sd	s0,8(sp)
    80001caa:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001cac:	02c05163          	blez	a2,80001cce <copy_array+0x28>
    80001cb0:	87aa                	mv	a5,a0
    80001cb2:	0505                	addi	a0,a0,1
    80001cb4:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001cb6:	1602                	slli	a2,a2,0x20
    80001cb8:	9201                	srli	a2,a2,0x20
    80001cba:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001cbe:	0007c703          	lbu	a4,0(a5)
    80001cc2:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001cc6:	0785                	addi	a5,a5,1
    80001cc8:	0585                	addi	a1,a1,1
    80001cca:	fed79ae3          	bne	a5,a3,80001cbe <copy_array+0x18>
}
    80001cce:	6422                	ld	s0,8(sp)
    80001cd0:	0141                	addi	sp,sp,16
    80001cd2:	8082                	ret

0000000080001cd4 <cpuid>:
{
    80001cd4:	1141                	addi	sp,sp,-16
    80001cd6:	e422                	sd	s0,8(sp)
    80001cd8:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001cda:	8512                	mv	a0,tp
}
    80001cdc:	2501                	sext.w	a0,a0
    80001cde:	6422                	ld	s0,8(sp)
    80001ce0:	0141                	addi	sp,sp,16
    80001ce2:	8082                	ret

0000000080001ce4 <mycpu>:
{
    80001ce4:	1141                	addi	sp,sp,-16
    80001ce6:	e422                	sd	s0,8(sp)
    80001ce8:	0800                	addi	s0,sp,16
    80001cea:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001cec:	2781                	sext.w	a5,a5
    80001cee:	079e                	slli	a5,a5,0x7
}
    80001cf0:	0002f517          	auipc	a0,0x2f
    80001cf4:	01850513          	addi	a0,a0,24 # 80030d08 <cpus>
    80001cf8:	953e                	add	a0,a0,a5
    80001cfa:	6422                	ld	s0,8(sp)
    80001cfc:	0141                	addi	sp,sp,16
    80001cfe:	8082                	ret

0000000080001d00 <myproc>:
{
    80001d00:	1101                	addi	sp,sp,-32
    80001d02:	ec06                	sd	ra,24(sp)
    80001d04:	e822                	sd	s0,16(sp)
    80001d06:	e426                	sd	s1,8(sp)
    80001d08:	1000                	addi	s0,sp,32
    push_off();
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	09c080e7          	jalr	156(ra) # 80000da6 <push_off>
    80001d12:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001d14:	2781                	sext.w	a5,a5
    80001d16:	079e                	slli	a5,a5,0x7
    80001d18:	0002f717          	auipc	a4,0x2f
    80001d1c:	ff070713          	addi	a4,a4,-16 # 80030d08 <cpus>
    80001d20:	97ba                	add	a5,a5,a4
    80001d22:	6384                	ld	s1,0(a5)
    pop_off();
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	122080e7          	jalr	290(ra) # 80000e46 <pop_off>
}
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret

0000000080001d38 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001d38:	1141                	addi	sp,sp,-16
    80001d3a:	e406                	sd	ra,8(sp)
    80001d3c:	e022                	sd	s0,0(sp)
    80001d3e:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	fc0080e7          	jalr	-64(ra) # 80001d00 <myproc>
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	15e080e7          	jalr	350(ra) # 80000ea6 <release>

    if (first)
    80001d50:	00007797          	auipc	a5,0x7
    80001d54:	c507a783          	lw	a5,-944(a5) # 800089a0 <first.1>
    80001d58:	eb89                	bnez	a5,80001d6a <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001d5a:	00001097          	auipc	ra,0x1
    80001d5e:	eba080e7          	jalr	-326(ra) # 80002c14 <usertrapret>
}
    80001d62:	60a2                	ld	ra,8(sp)
    80001d64:	6402                	ld	s0,0(sp)
    80001d66:	0141                	addi	sp,sp,16
    80001d68:	8082                	ret
        first = 0;
    80001d6a:	00007797          	auipc	a5,0x7
    80001d6e:	c207ab23          	sw	zero,-970(a5) # 800089a0 <first.1>
        fsinit(ROOTDEV);
    80001d72:	4505                	li	a0,1
    80001d74:	00002097          	auipc	ra,0x2
    80001d78:	dde080e7          	jalr	-546(ra) # 80003b52 <fsinit>
    80001d7c:	bff9                	j	80001d5a <forkret+0x22>

0000000080001d7e <allocpid>:
{
    80001d7e:	1101                	addi	sp,sp,-32
    80001d80:	ec06                	sd	ra,24(sp)
    80001d82:	e822                	sd	s0,16(sp)
    80001d84:	e426                	sd	s1,8(sp)
    80001d86:	e04a                	sd	s2,0(sp)
    80001d88:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001d8a:	0002f917          	auipc	s2,0x2f
    80001d8e:	37e90913          	addi	s2,s2,894 # 80031108 <pid_lock>
    80001d92:	854a                	mv	a0,s2
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	05e080e7          	jalr	94(ra) # 80000df2 <acquire>
    pid = nextpid;
    80001d9c:	00007797          	auipc	a5,0x7
    80001da0:	c1478793          	addi	a5,a5,-1004 # 800089b0 <nextpid>
    80001da4:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001da6:	0014871b          	addiw	a4,s1,1
    80001daa:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001dac:	854a                	mv	a0,s2
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	0f8080e7          	jalr	248(ra) # 80000ea6 <release>
}
    80001db6:	8526                	mv	a0,s1
    80001db8:	60e2                	ld	ra,24(sp)
    80001dba:	6442                	ld	s0,16(sp)
    80001dbc:	64a2                	ld	s1,8(sp)
    80001dbe:	6902                	ld	s2,0(sp)
    80001dc0:	6105                	addi	sp,sp,32
    80001dc2:	8082                	ret

0000000080001dc4 <proc_pagetable>:
{
    80001dc4:	1101                	addi	sp,sp,-32
    80001dc6:	ec06                	sd	ra,24(sp)
    80001dc8:	e822                	sd	s0,16(sp)
    80001dca:	e426                	sd	s1,8(sp)
    80001dcc:	e04a                	sd	s2,0(sp)
    80001dce:	1000                	addi	s0,sp,32
    80001dd0:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	772080e7          	jalr	1906(ra) # 80001544 <uvmcreate>
    80001dda:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001ddc:	c121                	beqz	a0,80001e1c <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001dde:	4729                	li	a4,10
    80001de0:	00005697          	auipc	a3,0x5
    80001de4:	22068693          	addi	a3,a3,544 # 80007000 <_trampoline>
    80001de8:	6605                	lui	a2,0x1
    80001dea:	040005b7          	lui	a1,0x4000
    80001dee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001df0:	05b2                	slli	a1,a1,0xc
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	4c8080e7          	jalr	1224(ra) # 800012ba <mappages>
    80001dfa:	02054863          	bltz	a0,80001e2a <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001dfe:	4719                	li	a4,6
    80001e00:	05893683          	ld	a3,88(s2)
    80001e04:	6605                	lui	a2,0x1
    80001e06:	020005b7          	lui	a1,0x2000
    80001e0a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e0c:	05b6                	slli	a1,a1,0xd
    80001e0e:	8526                	mv	a0,s1
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	4aa080e7          	jalr	1194(ra) # 800012ba <mappages>
    80001e18:	02054163          	bltz	a0,80001e3a <proc_pagetable+0x76>
}
    80001e1c:	8526                	mv	a0,s1
    80001e1e:	60e2                	ld	ra,24(sp)
    80001e20:	6442                	ld	s0,16(sp)
    80001e22:	64a2                	ld	s1,8(sp)
    80001e24:	6902                	ld	s2,0(sp)
    80001e26:	6105                	addi	sp,sp,32
    80001e28:	8082                	ret
        uvmfree(pagetable, 0);
    80001e2a:	4581                	li	a1,0
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	91c080e7          	jalr	-1764(ra) # 8000174a <uvmfree>
        return 0;
    80001e36:	4481                	li	s1,0
    80001e38:	b7d5                	j	80001e1c <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e3a:	4681                	li	a3,0
    80001e3c:	4605                	li	a2,1
    80001e3e:	040005b7          	lui	a1,0x4000
    80001e42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e44:	05b2                	slli	a1,a1,0xc
    80001e46:	8526                	mv	a0,s1
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	638080e7          	jalr	1592(ra) # 80001480 <uvmunmap>
        uvmfree(pagetable, 0);
    80001e50:	4581                	li	a1,0
    80001e52:	8526                	mv	a0,s1
    80001e54:	00000097          	auipc	ra,0x0
    80001e58:	8f6080e7          	jalr	-1802(ra) # 8000174a <uvmfree>
        return 0;
    80001e5c:	4481                	li	s1,0
    80001e5e:	bf7d                	j	80001e1c <proc_pagetable+0x58>

0000000080001e60 <proc_freepagetable>:
{
    80001e60:	1101                	addi	sp,sp,-32
    80001e62:	ec06                	sd	ra,24(sp)
    80001e64:	e822                	sd	s0,16(sp)
    80001e66:	e426                	sd	s1,8(sp)
    80001e68:	e04a                	sd	s2,0(sp)
    80001e6a:	1000                	addi	s0,sp,32
    80001e6c:	84aa                	mv	s1,a0
    80001e6e:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e70:	4681                	li	a3,0
    80001e72:	4605                	li	a2,1
    80001e74:	040005b7          	lui	a1,0x4000
    80001e78:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e7a:	05b2                	slli	a1,a1,0xc
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	604080e7          	jalr	1540(ra) # 80001480 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e84:	4681                	li	a3,0
    80001e86:	4605                	li	a2,1
    80001e88:	020005b7          	lui	a1,0x2000
    80001e8c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e8e:	05b6                	slli	a1,a1,0xd
    80001e90:	8526                	mv	a0,s1
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	5ee080e7          	jalr	1518(ra) # 80001480 <uvmunmap>
    uvmfree(pagetable, sz);
    80001e9a:	85ca                	mv	a1,s2
    80001e9c:	8526                	mv	a0,s1
    80001e9e:	00000097          	auipc	ra,0x0
    80001ea2:	8ac080e7          	jalr	-1876(ra) # 8000174a <uvmfree>
}
    80001ea6:	60e2                	ld	ra,24(sp)
    80001ea8:	6442                	ld	s0,16(sp)
    80001eaa:	64a2                	ld	s1,8(sp)
    80001eac:	6902                	ld	s2,0(sp)
    80001eae:	6105                	addi	sp,sp,32
    80001eb0:	8082                	ret

0000000080001eb2 <freeproc>:
{
    80001eb2:	1101                	addi	sp,sp,-32
    80001eb4:	ec06                	sd	ra,24(sp)
    80001eb6:	e822                	sd	s0,16(sp)
    80001eb8:	e426                	sd	s1,8(sp)
    80001eba:	1000                	addi	s0,sp,32
    80001ebc:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001ebe:	6d28                	ld	a0,88(a0)
    80001ec0:	c509                	beqz	a0,80001eca <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	bb4080e7          	jalr	-1100(ra) # 80000a76 <kfree>
    p->trapframe = 0;
    80001eca:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001ece:	68a8                	ld	a0,80(s1)
    80001ed0:	c511                	beqz	a0,80001edc <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001ed2:	64ac                	ld	a1,72(s1)
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	f8c080e7          	jalr	-116(ra) # 80001e60 <proc_freepagetable>
    p->pagetable = 0;
    80001edc:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001ee0:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001ee4:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001ee8:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001eec:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001ef0:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001ef4:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001ef8:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001efc:	0004ac23          	sw	zero,24(s1)
}
    80001f00:	60e2                	ld	ra,24(sp)
    80001f02:	6442                	ld	s0,16(sp)
    80001f04:	64a2                	ld	s1,8(sp)
    80001f06:	6105                	addi	sp,sp,32
    80001f08:	8082                	ret

0000000080001f0a <allocproc>:
{
    80001f0a:	1101                	addi	sp,sp,-32
    80001f0c:	ec06                	sd	ra,24(sp)
    80001f0e:	e822                	sd	s0,16(sp)
    80001f10:	e426                	sd	s1,8(sp)
    80001f12:	e04a                	sd	s2,0(sp)
    80001f14:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001f16:	0002f497          	auipc	s1,0x2f
    80001f1a:	22248493          	addi	s1,s1,546 # 80031138 <proc>
    80001f1e:	00035917          	auipc	s2,0x35
    80001f22:	c1a90913          	addi	s2,s2,-998 # 80036b38 <tickslock>
        acquire(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	eca080e7          	jalr	-310(ra) # 80000df2 <acquire>
        if (p->state == UNUSED)
    80001f30:	4c9c                	lw	a5,24(s1)
    80001f32:	cf81                	beqz	a5,80001f4a <allocproc+0x40>
            release(&p->lock);
    80001f34:	8526                	mv	a0,s1
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	f70080e7          	jalr	-144(ra) # 80000ea6 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f3e:	16848493          	addi	s1,s1,360
    80001f42:	ff2492e3          	bne	s1,s2,80001f26 <allocproc+0x1c>
    return 0;
    80001f46:	4481                	li	s1,0
    80001f48:	a889                	j	80001f9a <allocproc+0x90>
    p->pid = allocpid();
    80001f4a:	00000097          	auipc	ra,0x0
    80001f4e:	e34080e7          	jalr	-460(ra) # 80001d7e <allocpid>
    80001f52:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001f54:	4785                	li	a5,1
    80001f56:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	d10080e7          	jalr	-752(ra) # 80000c68 <kalloc>
    80001f60:	892a                	mv	s2,a0
    80001f62:	eca8                	sd	a0,88(s1)
    80001f64:	c131                	beqz	a0,80001fa8 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001f66:	8526                	mv	a0,s1
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	e5c080e7          	jalr	-420(ra) # 80001dc4 <proc_pagetable>
    80001f70:	892a                	mv	s2,a0
    80001f72:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001f74:	c531                	beqz	a0,80001fc0 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001f76:	07000613          	li	a2,112
    80001f7a:	4581                	li	a1,0
    80001f7c:	06048513          	addi	a0,s1,96
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	f6e080e7          	jalr	-146(ra) # 80000eee <memset>
    p->context.ra = (uint64)forkret;
    80001f88:	00000797          	auipc	a5,0x0
    80001f8c:	db078793          	addi	a5,a5,-592 # 80001d38 <forkret>
    80001f90:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001f92:	60bc                	ld	a5,64(s1)
    80001f94:	6705                	lui	a4,0x1
    80001f96:	97ba                	add	a5,a5,a4
    80001f98:	f4bc                	sd	a5,104(s1)
}
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	60e2                	ld	ra,24(sp)
    80001f9e:	6442                	ld	s0,16(sp)
    80001fa0:	64a2                	ld	s1,8(sp)
    80001fa2:	6902                	ld	s2,0(sp)
    80001fa4:	6105                	addi	sp,sp,32
    80001fa6:	8082                	ret
        freeproc(p);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	00000097          	auipc	ra,0x0
    80001fae:	f08080e7          	jalr	-248(ra) # 80001eb2 <freeproc>
        release(&p->lock);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	ef2080e7          	jalr	-270(ra) # 80000ea6 <release>
        return 0;
    80001fbc:	84ca                	mv	s1,s2
    80001fbe:	bff1                	j	80001f9a <allocproc+0x90>
        freeproc(p);
    80001fc0:	8526                	mv	a0,s1
    80001fc2:	00000097          	auipc	ra,0x0
    80001fc6:	ef0080e7          	jalr	-272(ra) # 80001eb2 <freeproc>
        release(&p->lock);
    80001fca:	8526                	mv	a0,s1
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	eda080e7          	jalr	-294(ra) # 80000ea6 <release>
        return 0;
    80001fd4:	84ca                	mv	s1,s2
    80001fd6:	b7d1                	j	80001f9a <allocproc+0x90>

0000000080001fd8 <userinit>:
{
    80001fd8:	1101                	addi	sp,sp,-32
    80001fda:	ec06                	sd	ra,24(sp)
    80001fdc:	e822                	sd	s0,16(sp)
    80001fde:	e426                	sd	s1,8(sp)
    80001fe0:	1000                	addi	s0,sp,32
    p = allocproc();
    80001fe2:	00000097          	auipc	ra,0x0
    80001fe6:	f28080e7          	jalr	-216(ra) # 80001f0a <allocproc>
    80001fea:	84aa                	mv	s1,a0
    initproc = p;
    80001fec:	00007797          	auipc	a5,0x7
    80001ff0:	a8a7b623          	sd	a0,-1396(a5) # 80008a78 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ff4:	03400613          	li	a2,52
    80001ff8:	00007597          	auipc	a1,0x7
    80001ffc:	9c858593          	addi	a1,a1,-1592 # 800089c0 <initcode>
    80002000:	6928                	ld	a0,80(a0)
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	570080e7          	jalr	1392(ra) # 80001572 <uvmfirst>
    p->sz = PGSIZE;
    8000200a:	6785                	lui	a5,0x1
    8000200c:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    8000200e:	6cb8                	ld	a4,88(s1)
    80002010:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80002014:	6cb8                	ld	a4,88(s1)
    80002016:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80002018:	4641                	li	a2,16
    8000201a:	00006597          	auipc	a1,0x6
    8000201e:	24658593          	addi	a1,a1,582 # 80008260 <digits+0x210>
    80002022:	15848513          	addi	a0,s1,344
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	012080e7          	jalr	18(ra) # 80001038 <safestrcpy>
    p->cwd = namei("/");
    8000202e:	00006517          	auipc	a0,0x6
    80002032:	24250513          	addi	a0,a0,578 # 80008270 <digits+0x220>
    80002036:	00002097          	auipc	ra,0x2
    8000203a:	546080e7          	jalr	1350(ra) # 8000457c <namei>
    8000203e:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80002042:	478d                	li	a5,3
    80002044:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	e5e080e7          	jalr	-418(ra) # 80000ea6 <release>
}
    80002050:	60e2                	ld	ra,24(sp)
    80002052:	6442                	ld	s0,16(sp)
    80002054:	64a2                	ld	s1,8(sp)
    80002056:	6105                	addi	sp,sp,32
    80002058:	8082                	ret

000000008000205a <growproc>:
{
    8000205a:	1101                	addi	sp,sp,-32
    8000205c:	ec06                	sd	ra,24(sp)
    8000205e:	e822                	sd	s0,16(sp)
    80002060:	e426                	sd	s1,8(sp)
    80002062:	e04a                	sd	s2,0(sp)
    80002064:	1000                	addi	s0,sp,32
    80002066:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	c98080e7          	jalr	-872(ra) # 80001d00 <myproc>
    80002070:	84aa                	mv	s1,a0
    sz = p->sz;
    80002072:	652c                	ld	a1,72(a0)
    if (n > 0)
    80002074:	01204c63          	bgtz	s2,8000208c <growproc+0x32>
    else if (n < 0)
    80002078:	02094663          	bltz	s2,800020a4 <growproc+0x4a>
    p->sz = sz;
    8000207c:	e4ac                	sd	a1,72(s1)
    return 0;
    8000207e:	4501                	li	a0,0
}
    80002080:	60e2                	ld	ra,24(sp)
    80002082:	6442                	ld	s0,16(sp)
    80002084:	64a2                	ld	s1,8(sp)
    80002086:	6902                	ld	s2,0(sp)
    80002088:	6105                	addi	sp,sp,32
    8000208a:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    8000208c:	4691                	li	a3,4
    8000208e:	00b90633          	add	a2,s2,a1
    80002092:	6928                	ld	a0,80(a0)
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	598080e7          	jalr	1432(ra) # 8000162c <uvmalloc>
    8000209c:	85aa                	mv	a1,a0
    8000209e:	fd79                	bnez	a0,8000207c <growproc+0x22>
            return -1;
    800020a0:	557d                	li	a0,-1
    800020a2:	bff9                	j	80002080 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020a4:	00b90633          	add	a2,s2,a1
    800020a8:	6928                	ld	a0,80(a0)
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	53a080e7          	jalr	1338(ra) # 800015e4 <uvmdealloc>
    800020b2:	85aa                	mv	a1,a0
    800020b4:	b7e1                	j	8000207c <growproc+0x22>

00000000800020b6 <ps>:
{
    800020b6:	715d                	addi	sp,sp,-80
    800020b8:	e486                	sd	ra,72(sp)
    800020ba:	e0a2                	sd	s0,64(sp)
    800020bc:	fc26                	sd	s1,56(sp)
    800020be:	f84a                	sd	s2,48(sp)
    800020c0:	f44e                	sd	s3,40(sp)
    800020c2:	f052                	sd	s4,32(sp)
    800020c4:	ec56                	sd	s5,24(sp)
    800020c6:	e85a                	sd	s6,16(sp)
    800020c8:	e45e                	sd	s7,8(sp)
    800020ca:	e062                	sd	s8,0(sp)
    800020cc:	0880                	addi	s0,sp,80
    800020ce:	84aa                	mv	s1,a0
    800020d0:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    800020d2:	00000097          	auipc	ra,0x0
    800020d6:	c2e080e7          	jalr	-978(ra) # 80001d00 <myproc>
        return result;
    800020da:	4901                	li	s2,0
    if (count == 0)
    800020dc:	0c0b8563          	beqz	s7,800021a6 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    800020e0:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    800020e4:	003b951b          	slliw	a0,s7,0x3
    800020e8:	0175053b          	addw	a0,a0,s7
    800020ec:	0025151b          	slliw	a0,a0,0x2
    800020f0:	00000097          	auipc	ra,0x0
    800020f4:	f6a080e7          	jalr	-150(ra) # 8000205a <growproc>
    800020f8:	12054f63          	bltz	a0,80002236 <ps+0x180>
    struct user_proc loc_result[count];
    800020fc:	003b9a13          	slli	s4,s7,0x3
    80002100:	9a5e                	add	s4,s4,s7
    80002102:	0a0a                	slli	s4,s4,0x2
    80002104:	00fa0793          	addi	a5,s4,15
    80002108:	8391                	srli	a5,a5,0x4
    8000210a:	0792                	slli	a5,a5,0x4
    8000210c:	40f10133          	sub	sp,sp,a5
    80002110:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    80002112:	16800793          	li	a5,360
    80002116:	02f484b3          	mul	s1,s1,a5
    8000211a:	0002f797          	auipc	a5,0x2f
    8000211e:	01e78793          	addi	a5,a5,30 # 80031138 <proc>
    80002122:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80002124:	00035797          	auipc	a5,0x35
    80002128:	a1478793          	addi	a5,a5,-1516 # 80036b38 <tickslock>
        return result;
    8000212c:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    8000212e:	06f4fc63          	bgeu	s1,a5,800021a6 <ps+0xf0>
    acquire(&wait_lock);
    80002132:	0002f517          	auipc	a0,0x2f
    80002136:	fee50513          	addi	a0,a0,-18 # 80031120 <wait_lock>
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	cb8080e7          	jalr	-840(ra) # 80000df2 <acquire>
        if (localCount == count)
    80002142:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002146:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002148:	00035c17          	auipc	s8,0x35
    8000214c:	9f0c0c13          	addi	s8,s8,-1552 # 80036b38 <tickslock>
    80002150:	a851                	j	800021e4 <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    80002152:	00399793          	slli	a5,s3,0x3
    80002156:	97ce                	add	a5,a5,s3
    80002158:	078a                	slli	a5,a5,0x2
    8000215a:	97d6                	add	a5,a5,s5
    8000215c:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	d44080e7          	jalr	-700(ra) # 80000ea6 <release>
    release(&wait_lock);
    8000216a:	0002f517          	auipc	a0,0x2f
    8000216e:	fb650513          	addi	a0,a0,-74 # 80031120 <wait_lock>
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	d34080e7          	jalr	-716(ra) # 80000ea6 <release>
    if (localCount < count)
    8000217a:	0179f963          	bgeu	s3,s7,8000218c <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    8000217e:	00399793          	slli	a5,s3,0x3
    80002182:	97ce                	add	a5,a5,s3
    80002184:	078a                	slli	a5,a5,0x2
    80002186:	97d6                	add	a5,a5,s5
    80002188:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    8000218c:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	b72080e7          	jalr	-1166(ra) # 80001d00 <myproc>
    80002196:	86d2                	mv	a3,s4
    80002198:	8656                	mv	a2,s5
    8000219a:	85da                	mv	a1,s6
    8000219c:	6928                	ld	a0,80(a0)
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	6c8080e7          	jalr	1736(ra) # 80001866 <copyout>
}
    800021a6:	854a                	mv	a0,s2
    800021a8:	fb040113          	addi	sp,s0,-80
    800021ac:	60a6                	ld	ra,72(sp)
    800021ae:	6406                	ld	s0,64(sp)
    800021b0:	74e2                	ld	s1,56(sp)
    800021b2:	7942                	ld	s2,48(sp)
    800021b4:	79a2                	ld	s3,40(sp)
    800021b6:	7a02                	ld	s4,32(sp)
    800021b8:	6ae2                	ld	s5,24(sp)
    800021ba:	6b42                	ld	s6,16(sp)
    800021bc:	6ba2                	ld	s7,8(sp)
    800021be:	6c02                	ld	s8,0(sp)
    800021c0:	6161                	addi	sp,sp,80
    800021c2:	8082                	ret
        release(&p->lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	ce0080e7          	jalr	-800(ra) # 80000ea6 <release>
        localCount++;
    800021ce:	2985                	addiw	s3,s3,1
    800021d0:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800021d4:	16848493          	addi	s1,s1,360
    800021d8:	f984f9e3          	bgeu	s1,s8,8000216a <ps+0xb4>
        if (localCount == count)
    800021dc:	02490913          	addi	s2,s2,36
    800021e0:	053b8d63          	beq	s7,s3,8000223a <ps+0x184>
        acquire(&p->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	c0c080e7          	jalr	-1012(ra) # 80000df2 <acquire>
        if (p->state == UNUSED)
    800021ee:	4c9c                	lw	a5,24(s1)
    800021f0:	d3ad                	beqz	a5,80002152 <ps+0x9c>
        loc_result[localCount].state = p->state;
    800021f2:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800021f6:	549c                	lw	a5,40(s1)
    800021f8:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800021fc:	54dc                	lw	a5,44(s1)
    800021fe:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    80002202:	589c                	lw	a5,48(s1)
    80002204:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002208:	4641                	li	a2,16
    8000220a:	85ca                	mv	a1,s2
    8000220c:	15848513          	addi	a0,s1,344
    80002210:	00000097          	auipc	ra,0x0
    80002214:	a96080e7          	jalr	-1386(ra) # 80001ca6 <copy_array>
        if (p->parent != 0) // init
    80002218:	7c88                	ld	a0,56(s1)
    8000221a:	d54d                	beqz	a0,800021c4 <ps+0x10e>
            acquire(&p->parent->lock);
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	bd6080e7          	jalr	-1066(ra) # 80000df2 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    80002224:	7c88                	ld	a0,56(s1)
    80002226:	591c                	lw	a5,48(a0)
    80002228:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	c7a080e7          	jalr	-902(ra) # 80000ea6 <release>
    80002234:	bf41                	j	800021c4 <ps+0x10e>
        return result;
    80002236:	4901                	li	s2,0
    80002238:	b7bd                	j	800021a6 <ps+0xf0>
    release(&wait_lock);
    8000223a:	0002f517          	auipc	a0,0x2f
    8000223e:	ee650513          	addi	a0,a0,-282 # 80031120 <wait_lock>
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	c64080e7          	jalr	-924(ra) # 80000ea6 <release>
    if (localCount < count)
    8000224a:	b789                	j	8000218c <ps+0xd6>

000000008000224c <fork>:
{
    8000224c:	7139                	addi	sp,sp,-64
    8000224e:	fc06                	sd	ra,56(sp)
    80002250:	f822                	sd	s0,48(sp)
    80002252:	f426                	sd	s1,40(sp)
    80002254:	f04a                	sd	s2,32(sp)
    80002256:	ec4e                	sd	s3,24(sp)
    80002258:	e852                	sd	s4,16(sp)
    8000225a:	e456                	sd	s5,8(sp)
    8000225c:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000225e:	00000097          	auipc	ra,0x0
    80002262:	aa2080e7          	jalr	-1374(ra) # 80001d00 <myproc>
    80002266:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002268:	00000097          	auipc	ra,0x0
    8000226c:	ca2080e7          	jalr	-862(ra) # 80001f0a <allocproc>
    80002270:	10050c63          	beqz	a0,80002388 <fork+0x13c>
    80002274:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002276:	048ab603          	ld	a2,72(s5)
    8000227a:	692c                	ld	a1,80(a0)
    8000227c:	050ab503          	ld	a0,80(s5)
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	504080e7          	jalr	1284(ra) # 80001784 <uvmcopy>
    80002288:	04054863          	bltz	a0,800022d8 <fork+0x8c>
    np->sz = p->sz;
    8000228c:	048ab783          	ld	a5,72(s5)
    80002290:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002294:	058ab683          	ld	a3,88(s5)
    80002298:	87b6                	mv	a5,a3
    8000229a:	058a3703          	ld	a4,88(s4)
    8000229e:	12068693          	addi	a3,a3,288
    800022a2:	0007b803          	ld	a6,0(a5)
    800022a6:	6788                	ld	a0,8(a5)
    800022a8:	6b8c                	ld	a1,16(a5)
    800022aa:	6f90                	ld	a2,24(a5)
    800022ac:	01073023          	sd	a6,0(a4)
    800022b0:	e708                	sd	a0,8(a4)
    800022b2:	eb0c                	sd	a1,16(a4)
    800022b4:	ef10                	sd	a2,24(a4)
    800022b6:	02078793          	addi	a5,a5,32
    800022ba:	02070713          	addi	a4,a4,32
    800022be:	fed792e3          	bne	a5,a3,800022a2 <fork+0x56>
    np->trapframe->a0 = 0;
    800022c2:	058a3783          	ld	a5,88(s4)
    800022c6:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800022ca:	0d0a8493          	addi	s1,s5,208
    800022ce:	0d0a0913          	addi	s2,s4,208
    800022d2:	150a8993          	addi	s3,s5,336
    800022d6:	a00d                	j	800022f8 <fork+0xac>
        freeproc(np);
    800022d8:	8552                	mv	a0,s4
    800022da:	00000097          	auipc	ra,0x0
    800022de:	bd8080e7          	jalr	-1064(ra) # 80001eb2 <freeproc>
        release(&np->lock);
    800022e2:	8552                	mv	a0,s4
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	bc2080e7          	jalr	-1086(ra) # 80000ea6 <release>
        return -1;
    800022ec:	597d                	li	s2,-1
    800022ee:	a059                	j	80002374 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    800022f0:	04a1                	addi	s1,s1,8
    800022f2:	0921                	addi	s2,s2,8
    800022f4:	01348b63          	beq	s1,s3,8000230a <fork+0xbe>
        if (p->ofile[i])
    800022f8:	6088                	ld	a0,0(s1)
    800022fa:	d97d                	beqz	a0,800022f0 <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    800022fc:	00003097          	auipc	ra,0x3
    80002300:	916080e7          	jalr	-1770(ra) # 80004c12 <filedup>
    80002304:	00a93023          	sd	a0,0(s2)
    80002308:	b7e5                	j	800022f0 <fork+0xa4>
    np->cwd = idup(p->cwd);
    8000230a:	150ab503          	ld	a0,336(s5)
    8000230e:	00002097          	auipc	ra,0x2
    80002312:	a84080e7          	jalr	-1404(ra) # 80003d92 <idup>
    80002316:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    8000231a:	4641                	li	a2,16
    8000231c:	158a8593          	addi	a1,s5,344
    80002320:	158a0513          	addi	a0,s4,344
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	d14080e7          	jalr	-748(ra) # 80001038 <safestrcpy>
    pid = np->pid;
    8000232c:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    80002330:	8552                	mv	a0,s4
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	b74080e7          	jalr	-1164(ra) # 80000ea6 <release>
    acquire(&wait_lock);
    8000233a:	0002f497          	auipc	s1,0x2f
    8000233e:	de648493          	addi	s1,s1,-538 # 80031120 <wait_lock>
    80002342:	8526                	mv	a0,s1
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	aae080e7          	jalr	-1362(ra) # 80000df2 <acquire>
    np->parent = p;
    8000234c:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002350:	8526                	mv	a0,s1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	b54080e7          	jalr	-1196(ra) # 80000ea6 <release>
    acquire(&np->lock);
    8000235a:	8552                	mv	a0,s4
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	a96080e7          	jalr	-1386(ra) # 80000df2 <acquire>
    np->state = RUNNABLE;
    80002364:	478d                	li	a5,3
    80002366:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    8000236a:	8552                	mv	a0,s4
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	b3a080e7          	jalr	-1222(ra) # 80000ea6 <release>
}
    80002374:	854a                	mv	a0,s2
    80002376:	70e2                	ld	ra,56(sp)
    80002378:	7442                	ld	s0,48(sp)
    8000237a:	74a2                	ld	s1,40(sp)
    8000237c:	7902                	ld	s2,32(sp)
    8000237e:	69e2                	ld	s3,24(sp)
    80002380:	6a42                	ld	s4,16(sp)
    80002382:	6aa2                	ld	s5,8(sp)
    80002384:	6121                	addi	sp,sp,64
    80002386:	8082                	ret
        return -1;
    80002388:	597d                	li	s2,-1
    8000238a:	b7ed                	j	80002374 <fork+0x128>

000000008000238c <scheduler>:
{
    8000238c:	1101                	addi	sp,sp,-32
    8000238e:	ec06                	sd	ra,24(sp)
    80002390:	e822                	sd	s0,16(sp)
    80002392:	e426                	sd	s1,8(sp)
    80002394:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002396:	00006497          	auipc	s1,0x6
    8000239a:	61248493          	addi	s1,s1,1554 # 800089a8 <sched_pointer>
    8000239e:	609c                	ld	a5,0(s1)
    800023a0:	9782                	jalr	a5
    while (1)
    800023a2:	bff5                	j	8000239e <scheduler+0x12>

00000000800023a4 <sched>:
{
    800023a4:	7179                	addi	sp,sp,-48
    800023a6:	f406                	sd	ra,40(sp)
    800023a8:	f022                	sd	s0,32(sp)
    800023aa:	ec26                	sd	s1,24(sp)
    800023ac:	e84a                	sd	s2,16(sp)
    800023ae:	e44e                	sd	s3,8(sp)
    800023b0:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800023b2:	00000097          	auipc	ra,0x0
    800023b6:	94e080e7          	jalr	-1714(ra) # 80001d00 <myproc>
    800023ba:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	9bc080e7          	jalr	-1604(ra) # 80000d78 <holding>
    800023c4:	c53d                	beqz	a0,80002432 <sched+0x8e>
    800023c6:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800023c8:	2781                	sext.w	a5,a5
    800023ca:	079e                	slli	a5,a5,0x7
    800023cc:	0002f717          	auipc	a4,0x2f
    800023d0:	93c70713          	addi	a4,a4,-1732 # 80030d08 <cpus>
    800023d4:	97ba                	add	a5,a5,a4
    800023d6:	5fb8                	lw	a4,120(a5)
    800023d8:	4785                	li	a5,1
    800023da:	06f71463          	bne	a4,a5,80002442 <sched+0x9e>
    if (p->state == RUNNING)
    800023de:	4c98                	lw	a4,24(s1)
    800023e0:	4791                	li	a5,4
    800023e2:	06f70863          	beq	a4,a5,80002452 <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800023e6:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    800023ea:	8b89                	andi	a5,a5,2
    if (intr_get())
    800023ec:	ebbd                	bnez	a5,80002462 <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800023ee:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800023f0:	0002f917          	auipc	s2,0x2f
    800023f4:	91890913          	addi	s2,s2,-1768 # 80030d08 <cpus>
    800023f8:	2781                	sext.w	a5,a5
    800023fa:	079e                	slli	a5,a5,0x7
    800023fc:	97ca                	add	a5,a5,s2
    800023fe:	07c7a983          	lw	s3,124(a5)
    80002402:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    80002404:	2581                	sext.w	a1,a1
    80002406:	059e                	slli	a1,a1,0x7
    80002408:	05a1                	addi	a1,a1,8
    8000240a:	95ca                	add	a1,a1,s2
    8000240c:	06048513          	addi	a0,s1,96
    80002410:	00000097          	auipc	ra,0x0
    80002414:	75a080e7          	jalr	1882(ra) # 80002b6a <swtch>
    80002418:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    8000241a:	2781                	sext.w	a5,a5
    8000241c:	079e                	slli	a5,a5,0x7
    8000241e:	993e                	add	s2,s2,a5
    80002420:	07392e23          	sw	s3,124(s2)
}
    80002424:	70a2                	ld	ra,40(sp)
    80002426:	7402                	ld	s0,32(sp)
    80002428:	64e2                	ld	s1,24(sp)
    8000242a:	6942                	ld	s2,16(sp)
    8000242c:	69a2                	ld	s3,8(sp)
    8000242e:	6145                	addi	sp,sp,48
    80002430:	8082                	ret
        panic("sched p->lock");
    80002432:	00006517          	auipc	a0,0x6
    80002436:	e4650513          	addi	a0,a0,-442 # 80008278 <digits+0x228>
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	106080e7          	jalr	262(ra) # 80000540 <panic>
        panic("sched locks");
    80002442:	00006517          	auipc	a0,0x6
    80002446:	e4650513          	addi	a0,a0,-442 # 80008288 <digits+0x238>
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	0f6080e7          	jalr	246(ra) # 80000540 <panic>
        panic("sched running");
    80002452:	00006517          	auipc	a0,0x6
    80002456:	e4650513          	addi	a0,a0,-442 # 80008298 <digits+0x248>
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	0e6080e7          	jalr	230(ra) # 80000540 <panic>
        panic("sched interruptible");
    80002462:	00006517          	auipc	a0,0x6
    80002466:	e4650513          	addi	a0,a0,-442 # 800082a8 <digits+0x258>
    8000246a:	ffffe097          	auipc	ra,0xffffe
    8000246e:	0d6080e7          	jalr	214(ra) # 80000540 <panic>

0000000080002472 <yield>:
{
    80002472:	1101                	addi	sp,sp,-32
    80002474:	ec06                	sd	ra,24(sp)
    80002476:	e822                	sd	s0,16(sp)
    80002478:	e426                	sd	s1,8(sp)
    8000247a:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    8000247c:	00000097          	auipc	ra,0x0
    80002480:	884080e7          	jalr	-1916(ra) # 80001d00 <myproc>
    80002484:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	96c080e7          	jalr	-1684(ra) # 80000df2 <acquire>
    p->state = RUNNABLE;
    8000248e:	478d                	li	a5,3
    80002490:	cc9c                	sw	a5,24(s1)
    sched();
    80002492:	00000097          	auipc	ra,0x0
    80002496:	f12080e7          	jalr	-238(ra) # 800023a4 <sched>
    release(&p->lock);
    8000249a:	8526                	mv	a0,s1
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	a0a080e7          	jalr	-1526(ra) # 80000ea6 <release>
}
    800024a4:	60e2                	ld	ra,24(sp)
    800024a6:	6442                	ld	s0,16(sp)
    800024a8:	64a2                	ld	s1,8(sp)
    800024aa:	6105                	addi	sp,sp,32
    800024ac:	8082                	ret

00000000800024ae <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800024ae:	7179                	addi	sp,sp,-48
    800024b0:	f406                	sd	ra,40(sp)
    800024b2:	f022                	sd	s0,32(sp)
    800024b4:	ec26                	sd	s1,24(sp)
    800024b6:	e84a                	sd	s2,16(sp)
    800024b8:	e44e                	sd	s3,8(sp)
    800024ba:	1800                	addi	s0,sp,48
    800024bc:	89aa                	mv	s3,a0
    800024be:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	840080e7          	jalr	-1984(ra) # 80001d00 <myproc>
    800024c8:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	928080e7          	jalr	-1752(ra) # 80000df2 <acquire>
    release(lk);
    800024d2:	854a                	mv	a0,s2
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	9d2080e7          	jalr	-1582(ra) # 80000ea6 <release>

    // Go to sleep.
    p->chan = chan;
    800024dc:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800024e0:	4789                	li	a5,2
    800024e2:	cc9c                	sw	a5,24(s1)

    sched();
    800024e4:	00000097          	auipc	ra,0x0
    800024e8:	ec0080e7          	jalr	-320(ra) # 800023a4 <sched>

    // Tidy up.
    p->chan = 0;
    800024ec:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800024f0:	8526                	mv	a0,s1
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	9b4080e7          	jalr	-1612(ra) # 80000ea6 <release>
    acquire(lk);
    800024fa:	854a                	mv	a0,s2
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	8f6080e7          	jalr	-1802(ra) # 80000df2 <acquire>
}
    80002504:	70a2                	ld	ra,40(sp)
    80002506:	7402                	ld	s0,32(sp)
    80002508:	64e2                	ld	s1,24(sp)
    8000250a:	6942                	ld	s2,16(sp)
    8000250c:	69a2                	ld	s3,8(sp)
    8000250e:	6145                	addi	sp,sp,48
    80002510:	8082                	ret

0000000080002512 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002512:	7139                	addi	sp,sp,-64
    80002514:	fc06                	sd	ra,56(sp)
    80002516:	f822                	sd	s0,48(sp)
    80002518:	f426                	sd	s1,40(sp)
    8000251a:	f04a                	sd	s2,32(sp)
    8000251c:	ec4e                	sd	s3,24(sp)
    8000251e:	e852                	sd	s4,16(sp)
    80002520:	e456                	sd	s5,8(sp)
    80002522:	0080                	addi	s0,sp,64
    80002524:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002526:	0002f497          	auipc	s1,0x2f
    8000252a:	c1248493          	addi	s1,s1,-1006 # 80031138 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000252e:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    80002530:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002532:	00034917          	auipc	s2,0x34
    80002536:	60690913          	addi	s2,s2,1542 # 80036b38 <tickslock>
    8000253a:	a811                	j	8000254e <wakeup+0x3c>
            }
            release(&p->lock);
    8000253c:	8526                	mv	a0,s1
    8000253e:	fffff097          	auipc	ra,0xfffff
    80002542:	968080e7          	jalr	-1688(ra) # 80000ea6 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002546:	16848493          	addi	s1,s1,360
    8000254a:	03248663          	beq	s1,s2,80002576 <wakeup+0x64>
        if (p != myproc())
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	7b2080e7          	jalr	1970(ra) # 80001d00 <myproc>
    80002556:	fea488e3          	beq	s1,a0,80002546 <wakeup+0x34>
            acquire(&p->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	fffff097          	auipc	ra,0xfffff
    80002560:	896080e7          	jalr	-1898(ra) # 80000df2 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002564:	4c9c                	lw	a5,24(s1)
    80002566:	fd379be3          	bne	a5,s3,8000253c <wakeup+0x2a>
    8000256a:	709c                	ld	a5,32(s1)
    8000256c:	fd4798e3          	bne	a5,s4,8000253c <wakeup+0x2a>
                p->state = RUNNABLE;
    80002570:	0154ac23          	sw	s5,24(s1)
    80002574:	b7e1                	j	8000253c <wakeup+0x2a>
        }
    }
}
    80002576:	70e2                	ld	ra,56(sp)
    80002578:	7442                	ld	s0,48(sp)
    8000257a:	74a2                	ld	s1,40(sp)
    8000257c:	7902                	ld	s2,32(sp)
    8000257e:	69e2                	ld	s3,24(sp)
    80002580:	6a42                	ld	s4,16(sp)
    80002582:	6aa2                	ld	s5,8(sp)
    80002584:	6121                	addi	sp,sp,64
    80002586:	8082                	ret

0000000080002588 <reparent>:
{
    80002588:	7179                	addi	sp,sp,-48
    8000258a:	f406                	sd	ra,40(sp)
    8000258c:	f022                	sd	s0,32(sp)
    8000258e:	ec26                	sd	s1,24(sp)
    80002590:	e84a                	sd	s2,16(sp)
    80002592:	e44e                	sd	s3,8(sp)
    80002594:	e052                	sd	s4,0(sp)
    80002596:	1800                	addi	s0,sp,48
    80002598:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000259a:	0002f497          	auipc	s1,0x2f
    8000259e:	b9e48493          	addi	s1,s1,-1122 # 80031138 <proc>
            pp->parent = initproc;
    800025a2:	00006a17          	auipc	s4,0x6
    800025a6:	4d6a0a13          	addi	s4,s4,1238 # 80008a78 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025aa:	00034997          	auipc	s3,0x34
    800025ae:	58e98993          	addi	s3,s3,1422 # 80036b38 <tickslock>
    800025b2:	a029                	j	800025bc <reparent+0x34>
    800025b4:	16848493          	addi	s1,s1,360
    800025b8:	01348d63          	beq	s1,s3,800025d2 <reparent+0x4a>
        if (pp->parent == p)
    800025bc:	7c9c                	ld	a5,56(s1)
    800025be:	ff279be3          	bne	a5,s2,800025b4 <reparent+0x2c>
            pp->parent = initproc;
    800025c2:	000a3503          	ld	a0,0(s4)
    800025c6:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800025c8:	00000097          	auipc	ra,0x0
    800025cc:	f4a080e7          	jalr	-182(ra) # 80002512 <wakeup>
    800025d0:	b7d5                	j	800025b4 <reparent+0x2c>
}
    800025d2:	70a2                	ld	ra,40(sp)
    800025d4:	7402                	ld	s0,32(sp)
    800025d6:	64e2                	ld	s1,24(sp)
    800025d8:	6942                	ld	s2,16(sp)
    800025da:	69a2                	ld	s3,8(sp)
    800025dc:	6a02                	ld	s4,0(sp)
    800025de:	6145                	addi	sp,sp,48
    800025e0:	8082                	ret

00000000800025e2 <exit>:
{
    800025e2:	7179                	addi	sp,sp,-48
    800025e4:	f406                	sd	ra,40(sp)
    800025e6:	f022                	sd	s0,32(sp)
    800025e8:	ec26                	sd	s1,24(sp)
    800025ea:	e84a                	sd	s2,16(sp)
    800025ec:	e44e                	sd	s3,8(sp)
    800025ee:	e052                	sd	s4,0(sp)
    800025f0:	1800                	addi	s0,sp,48
    800025f2:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	70c080e7          	jalr	1804(ra) # 80001d00 <myproc>
    800025fc:	89aa                	mv	s3,a0
    if (p == initproc)
    800025fe:	00006797          	auipc	a5,0x6
    80002602:	47a7b783          	ld	a5,1146(a5) # 80008a78 <initproc>
    80002606:	0d050493          	addi	s1,a0,208
    8000260a:	15050913          	addi	s2,a0,336
    8000260e:	02a79363          	bne	a5,a0,80002634 <exit+0x52>
        panic("init exiting");
    80002612:	00006517          	auipc	a0,0x6
    80002616:	cae50513          	addi	a0,a0,-850 # 800082c0 <digits+0x270>
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	f26080e7          	jalr	-218(ra) # 80000540 <panic>
            fileclose(f);
    80002622:	00002097          	auipc	ra,0x2
    80002626:	642080e7          	jalr	1602(ra) # 80004c64 <fileclose>
            p->ofile[fd] = 0;
    8000262a:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000262e:	04a1                	addi	s1,s1,8
    80002630:	01248563          	beq	s1,s2,8000263a <exit+0x58>
        if (p->ofile[fd])
    80002634:	6088                	ld	a0,0(s1)
    80002636:	f575                	bnez	a0,80002622 <exit+0x40>
    80002638:	bfdd                	j	8000262e <exit+0x4c>
    begin_op();
    8000263a:	00002097          	auipc	ra,0x2
    8000263e:	162080e7          	jalr	354(ra) # 8000479c <begin_op>
    iput(p->cwd);
    80002642:	1509b503          	ld	a0,336(s3)
    80002646:	00002097          	auipc	ra,0x2
    8000264a:	944080e7          	jalr	-1724(ra) # 80003f8a <iput>
    end_op();
    8000264e:	00002097          	auipc	ra,0x2
    80002652:	1cc080e7          	jalr	460(ra) # 8000481a <end_op>
    p->cwd = 0;
    80002656:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    8000265a:	0002f497          	auipc	s1,0x2f
    8000265e:	ac648493          	addi	s1,s1,-1338 # 80031120 <wait_lock>
    80002662:	8526                	mv	a0,s1
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	78e080e7          	jalr	1934(ra) # 80000df2 <acquire>
    reparent(p);
    8000266c:	854e                	mv	a0,s3
    8000266e:	00000097          	auipc	ra,0x0
    80002672:	f1a080e7          	jalr	-230(ra) # 80002588 <reparent>
    wakeup(p->parent);
    80002676:	0389b503          	ld	a0,56(s3)
    8000267a:	00000097          	auipc	ra,0x0
    8000267e:	e98080e7          	jalr	-360(ra) # 80002512 <wakeup>
    acquire(&p->lock);
    80002682:	854e                	mv	a0,s3
    80002684:	ffffe097          	auipc	ra,0xffffe
    80002688:	76e080e7          	jalr	1902(ra) # 80000df2 <acquire>
    p->xstate = status;
    8000268c:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002690:	4795                	li	a5,5
    80002692:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002696:	8526                	mv	a0,s1
    80002698:	fffff097          	auipc	ra,0xfffff
    8000269c:	80e080e7          	jalr	-2034(ra) # 80000ea6 <release>
    sched();
    800026a0:	00000097          	auipc	ra,0x0
    800026a4:	d04080e7          	jalr	-764(ra) # 800023a4 <sched>
    panic("zombie exit");
    800026a8:	00006517          	auipc	a0,0x6
    800026ac:	c2850513          	addi	a0,a0,-984 # 800082d0 <digits+0x280>
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	e90080e7          	jalr	-368(ra) # 80000540 <panic>

00000000800026b8 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800026b8:	7179                	addi	sp,sp,-48
    800026ba:	f406                	sd	ra,40(sp)
    800026bc:	f022                	sd	s0,32(sp)
    800026be:	ec26                	sd	s1,24(sp)
    800026c0:	e84a                	sd	s2,16(sp)
    800026c2:	e44e                	sd	s3,8(sp)
    800026c4:	1800                	addi	s0,sp,48
    800026c6:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800026c8:	0002f497          	auipc	s1,0x2f
    800026cc:	a7048493          	addi	s1,s1,-1424 # 80031138 <proc>
    800026d0:	00034997          	auipc	s3,0x34
    800026d4:	46898993          	addi	s3,s3,1128 # 80036b38 <tickslock>
    {
        acquire(&p->lock);
    800026d8:	8526                	mv	a0,s1
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	718080e7          	jalr	1816(ra) # 80000df2 <acquire>
        if (p->pid == pid)
    800026e2:	589c                	lw	a5,48(s1)
    800026e4:	01278d63          	beq	a5,s2,800026fe <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800026e8:	8526                	mv	a0,s1
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	7bc080e7          	jalr	1980(ra) # 80000ea6 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800026f2:	16848493          	addi	s1,s1,360
    800026f6:	ff3491e3          	bne	s1,s3,800026d8 <kill+0x20>
    }
    return -1;
    800026fa:	557d                	li	a0,-1
    800026fc:	a829                	j	80002716 <kill+0x5e>
            p->killed = 1;
    800026fe:	4785                	li	a5,1
    80002700:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    80002702:	4c98                	lw	a4,24(s1)
    80002704:	4789                	li	a5,2
    80002706:	00f70f63          	beq	a4,a5,80002724 <kill+0x6c>
            release(&p->lock);
    8000270a:	8526                	mv	a0,s1
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	79a080e7          	jalr	1946(ra) # 80000ea6 <release>
            return 0;
    80002714:	4501                	li	a0,0
}
    80002716:	70a2                	ld	ra,40(sp)
    80002718:	7402                	ld	s0,32(sp)
    8000271a:	64e2                	ld	s1,24(sp)
    8000271c:	6942                	ld	s2,16(sp)
    8000271e:	69a2                	ld	s3,8(sp)
    80002720:	6145                	addi	sp,sp,48
    80002722:	8082                	ret
                p->state = RUNNABLE;
    80002724:	478d                	li	a5,3
    80002726:	cc9c                	sw	a5,24(s1)
    80002728:	b7cd                	j	8000270a <kill+0x52>

000000008000272a <setkilled>:

void setkilled(struct proc *p)
{
    8000272a:	1101                	addi	sp,sp,-32
    8000272c:	ec06                	sd	ra,24(sp)
    8000272e:	e822                	sd	s0,16(sp)
    80002730:	e426                	sd	s1,8(sp)
    80002732:	1000                	addi	s0,sp,32
    80002734:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	6bc080e7          	jalr	1724(ra) # 80000df2 <acquire>
    p->killed = 1;
    8000273e:	4785                	li	a5,1
    80002740:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002742:	8526                	mv	a0,s1
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	762080e7          	jalr	1890(ra) # 80000ea6 <release>
}
    8000274c:	60e2                	ld	ra,24(sp)
    8000274e:	6442                	ld	s0,16(sp)
    80002750:	64a2                	ld	s1,8(sp)
    80002752:	6105                	addi	sp,sp,32
    80002754:	8082                	ret

0000000080002756 <killed>:

int killed(struct proc *p)
{
    80002756:	1101                	addi	sp,sp,-32
    80002758:	ec06                	sd	ra,24(sp)
    8000275a:	e822                	sd	s0,16(sp)
    8000275c:	e426                	sd	s1,8(sp)
    8000275e:	e04a                	sd	s2,0(sp)
    80002760:	1000                	addi	s0,sp,32
    80002762:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	68e080e7          	jalr	1678(ra) # 80000df2 <acquire>
    k = p->killed;
    8000276c:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	734080e7          	jalr	1844(ra) # 80000ea6 <release>
    return k;
}
    8000277a:	854a                	mv	a0,s2
    8000277c:	60e2                	ld	ra,24(sp)
    8000277e:	6442                	ld	s0,16(sp)
    80002780:	64a2                	ld	s1,8(sp)
    80002782:	6902                	ld	s2,0(sp)
    80002784:	6105                	addi	sp,sp,32
    80002786:	8082                	ret

0000000080002788 <wait>:
{
    80002788:	715d                	addi	sp,sp,-80
    8000278a:	e486                	sd	ra,72(sp)
    8000278c:	e0a2                	sd	s0,64(sp)
    8000278e:	fc26                	sd	s1,56(sp)
    80002790:	f84a                	sd	s2,48(sp)
    80002792:	f44e                	sd	s3,40(sp)
    80002794:	f052                	sd	s4,32(sp)
    80002796:	ec56                	sd	s5,24(sp)
    80002798:	e85a                	sd	s6,16(sp)
    8000279a:	e45e                	sd	s7,8(sp)
    8000279c:	e062                	sd	s8,0(sp)
    8000279e:	0880                	addi	s0,sp,80
    800027a0:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800027a2:	fffff097          	auipc	ra,0xfffff
    800027a6:	55e080e7          	jalr	1374(ra) # 80001d00 <myproc>
    800027aa:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800027ac:	0002f517          	auipc	a0,0x2f
    800027b0:	97450513          	addi	a0,a0,-1676 # 80031120 <wait_lock>
    800027b4:	ffffe097          	auipc	ra,0xffffe
    800027b8:	63e080e7          	jalr	1598(ra) # 80000df2 <acquire>
        havekids = 0;
    800027bc:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800027be:	4a15                	li	s4,5
                havekids = 1;
    800027c0:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027c2:	00034997          	auipc	s3,0x34
    800027c6:	37698993          	addi	s3,s3,886 # 80036b38 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800027ca:	0002fc17          	auipc	s8,0x2f
    800027ce:	956c0c13          	addi	s8,s8,-1706 # 80031120 <wait_lock>
        havekids = 0;
    800027d2:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027d4:	0002f497          	auipc	s1,0x2f
    800027d8:	96448493          	addi	s1,s1,-1692 # 80031138 <proc>
    800027dc:	a0bd                	j	8000284a <wait+0xc2>
                    pid = pp->pid;
    800027de:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027e2:	000b0e63          	beqz	s6,800027fe <wait+0x76>
    800027e6:	4691                	li	a3,4
    800027e8:	02c48613          	addi	a2,s1,44
    800027ec:	85da                	mv	a1,s6
    800027ee:	05093503          	ld	a0,80(s2)
    800027f2:	fffff097          	auipc	ra,0xfffff
    800027f6:	074080e7          	jalr	116(ra) # 80001866 <copyout>
    800027fa:	02054563          	bltz	a0,80002824 <wait+0x9c>
                    freeproc(pp);
    800027fe:	8526                	mv	a0,s1
    80002800:	fffff097          	auipc	ra,0xfffff
    80002804:	6b2080e7          	jalr	1714(ra) # 80001eb2 <freeproc>
                    release(&pp->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	69c080e7          	jalr	1692(ra) # 80000ea6 <release>
                    release(&wait_lock);
    80002812:	0002f517          	auipc	a0,0x2f
    80002816:	90e50513          	addi	a0,a0,-1778 # 80031120 <wait_lock>
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	68c080e7          	jalr	1676(ra) # 80000ea6 <release>
                    return pid;
    80002822:	a0b5                	j	8000288e <wait+0x106>
                        release(&pp->lock);
    80002824:	8526                	mv	a0,s1
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	680080e7          	jalr	1664(ra) # 80000ea6 <release>
                        release(&wait_lock);
    8000282e:	0002f517          	auipc	a0,0x2f
    80002832:	8f250513          	addi	a0,a0,-1806 # 80031120 <wait_lock>
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	670080e7          	jalr	1648(ra) # 80000ea6 <release>
                        return -1;
    8000283e:	59fd                	li	s3,-1
    80002840:	a0b9                	j	8000288e <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002842:	16848493          	addi	s1,s1,360
    80002846:	03348463          	beq	s1,s3,8000286e <wait+0xe6>
            if (pp->parent == p)
    8000284a:	7c9c                	ld	a5,56(s1)
    8000284c:	ff279be3          	bne	a5,s2,80002842 <wait+0xba>
                acquire(&pp->lock);
    80002850:	8526                	mv	a0,s1
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	5a0080e7          	jalr	1440(ra) # 80000df2 <acquire>
                if (pp->state == ZOMBIE)
    8000285a:	4c9c                	lw	a5,24(s1)
    8000285c:	f94781e3          	beq	a5,s4,800027de <wait+0x56>
                release(&pp->lock);
    80002860:	8526                	mv	a0,s1
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	644080e7          	jalr	1604(ra) # 80000ea6 <release>
                havekids = 1;
    8000286a:	8756                	mv	a4,s5
    8000286c:	bfd9                	j	80002842 <wait+0xba>
        if (!havekids || killed(p))
    8000286e:	c719                	beqz	a4,8000287c <wait+0xf4>
    80002870:	854a                	mv	a0,s2
    80002872:	00000097          	auipc	ra,0x0
    80002876:	ee4080e7          	jalr	-284(ra) # 80002756 <killed>
    8000287a:	c51d                	beqz	a0,800028a8 <wait+0x120>
            release(&wait_lock);
    8000287c:	0002f517          	auipc	a0,0x2f
    80002880:	8a450513          	addi	a0,a0,-1884 # 80031120 <wait_lock>
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	622080e7          	jalr	1570(ra) # 80000ea6 <release>
            return -1;
    8000288c:	59fd                	li	s3,-1
}
    8000288e:	854e                	mv	a0,s3
    80002890:	60a6                	ld	ra,72(sp)
    80002892:	6406                	ld	s0,64(sp)
    80002894:	74e2                	ld	s1,56(sp)
    80002896:	7942                	ld	s2,48(sp)
    80002898:	79a2                	ld	s3,40(sp)
    8000289a:	7a02                	ld	s4,32(sp)
    8000289c:	6ae2                	ld	s5,24(sp)
    8000289e:	6b42                	ld	s6,16(sp)
    800028a0:	6ba2                	ld	s7,8(sp)
    800028a2:	6c02                	ld	s8,0(sp)
    800028a4:	6161                	addi	sp,sp,80
    800028a6:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    800028a8:	85e2                	mv	a1,s8
    800028aa:	854a                	mv	a0,s2
    800028ac:	00000097          	auipc	ra,0x0
    800028b0:	c02080e7          	jalr	-1022(ra) # 800024ae <sleep>
        havekids = 0;
    800028b4:	bf39                	j	800027d2 <wait+0x4a>

00000000800028b6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028b6:	7179                	addi	sp,sp,-48
    800028b8:	f406                	sd	ra,40(sp)
    800028ba:	f022                	sd	s0,32(sp)
    800028bc:	ec26                	sd	s1,24(sp)
    800028be:	e84a                	sd	s2,16(sp)
    800028c0:	e44e                	sd	s3,8(sp)
    800028c2:	e052                	sd	s4,0(sp)
    800028c4:	1800                	addi	s0,sp,48
    800028c6:	84aa                	mv	s1,a0
    800028c8:	892e                	mv	s2,a1
    800028ca:	89b2                	mv	s3,a2
    800028cc:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800028ce:	fffff097          	auipc	ra,0xfffff
    800028d2:	432080e7          	jalr	1074(ra) # 80001d00 <myproc>
    if (user_dst)
    800028d6:	c08d                	beqz	s1,800028f8 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800028d8:	86d2                	mv	a3,s4
    800028da:	864e                	mv	a2,s3
    800028dc:	85ca                	mv	a1,s2
    800028de:	6928                	ld	a0,80(a0)
    800028e0:	fffff097          	auipc	ra,0xfffff
    800028e4:	f86080e7          	jalr	-122(ra) # 80001866 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    800028e8:	70a2                	ld	ra,40(sp)
    800028ea:	7402                	ld	s0,32(sp)
    800028ec:	64e2                	ld	s1,24(sp)
    800028ee:	6942                	ld	s2,16(sp)
    800028f0:	69a2                	ld	s3,8(sp)
    800028f2:	6a02                	ld	s4,0(sp)
    800028f4:	6145                	addi	sp,sp,48
    800028f6:	8082                	ret
        memmove((char *)dst, src, len);
    800028f8:	000a061b          	sext.w	a2,s4
    800028fc:	85ce                	mv	a1,s3
    800028fe:	854a                	mv	a0,s2
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	64a080e7          	jalr	1610(ra) # 80000f4a <memmove>
        return 0;
    80002908:	8526                	mv	a0,s1
    8000290a:	bff9                	j	800028e8 <either_copyout+0x32>

000000008000290c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000290c:	7179                	addi	sp,sp,-48
    8000290e:	f406                	sd	ra,40(sp)
    80002910:	f022                	sd	s0,32(sp)
    80002912:	ec26                	sd	s1,24(sp)
    80002914:	e84a                	sd	s2,16(sp)
    80002916:	e44e                	sd	s3,8(sp)
    80002918:	e052                	sd	s4,0(sp)
    8000291a:	1800                	addi	s0,sp,48
    8000291c:	892a                	mv	s2,a0
    8000291e:	84ae                	mv	s1,a1
    80002920:	89b2                	mv	s3,a2
    80002922:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002924:	fffff097          	auipc	ra,0xfffff
    80002928:	3dc080e7          	jalr	988(ra) # 80001d00 <myproc>
    if (user_src)
    8000292c:	c08d                	beqz	s1,8000294e <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    8000292e:	86d2                	mv	a3,s4
    80002930:	864e                	mv	a2,s3
    80002932:	85ca                	mv	a1,s2
    80002934:	6928                	ld	a0,80(a0)
    80002936:	fffff097          	auipc	ra,0xfffff
    8000293a:	fbc080e7          	jalr	-68(ra) # 800018f2 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    8000293e:	70a2                	ld	ra,40(sp)
    80002940:	7402                	ld	s0,32(sp)
    80002942:	64e2                	ld	s1,24(sp)
    80002944:	6942                	ld	s2,16(sp)
    80002946:	69a2                	ld	s3,8(sp)
    80002948:	6a02                	ld	s4,0(sp)
    8000294a:	6145                	addi	sp,sp,48
    8000294c:	8082                	ret
        memmove(dst, (char *)src, len);
    8000294e:	000a061b          	sext.w	a2,s4
    80002952:	85ce                	mv	a1,s3
    80002954:	854a                	mv	a0,s2
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	5f4080e7          	jalr	1524(ra) # 80000f4a <memmove>
        return 0;
    8000295e:	8526                	mv	a0,s1
    80002960:	bff9                	j	8000293e <either_copyin+0x32>

0000000080002962 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002962:	715d                	addi	sp,sp,-80
    80002964:	e486                	sd	ra,72(sp)
    80002966:	e0a2                	sd	s0,64(sp)
    80002968:	fc26                	sd	s1,56(sp)
    8000296a:	f84a                	sd	s2,48(sp)
    8000296c:	f44e                	sd	s3,40(sp)
    8000296e:	f052                	sd	s4,32(sp)
    80002970:	ec56                	sd	s5,24(sp)
    80002972:	e85a                	sd	s6,16(sp)
    80002974:	e45e                	sd	s7,8(sp)
    80002976:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002978:	00005517          	auipc	a0,0x5
    8000297c:	72050513          	addi	a0,a0,1824 # 80008098 <digits+0x48>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	c1c080e7          	jalr	-996(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002988:	0002f497          	auipc	s1,0x2f
    8000298c:	90848493          	addi	s1,s1,-1784 # 80031290 <proc+0x158>
    80002990:	00034917          	auipc	s2,0x34
    80002994:	30090913          	addi	s2,s2,768 # 80036c90 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002998:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    8000299a:	00006997          	auipc	s3,0x6
    8000299e:	94698993          	addi	s3,s3,-1722 # 800082e0 <digits+0x290>
        printf("%d <%s %s", p->pid, state, p->name);
    800029a2:	00006a97          	auipc	s5,0x6
    800029a6:	946a8a93          	addi	s5,s5,-1722 # 800082e8 <digits+0x298>
        printf("\n");
    800029aa:	00005a17          	auipc	s4,0x5
    800029ae:	6eea0a13          	addi	s4,s4,1774 # 80008098 <digits+0x48>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029b2:	00006b97          	auipc	s7,0x6
    800029b6:	a46b8b93          	addi	s7,s7,-1466 # 800083f8 <states.0>
    800029ba:	a00d                	j	800029dc <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800029bc:	ed86a583          	lw	a1,-296(a3)
    800029c0:	8556                	mv	a0,s5
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	bda080e7          	jalr	-1062(ra) # 8000059c <printf>
        printf("\n");
    800029ca:	8552                	mv	a0,s4
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	bd0080e7          	jalr	-1072(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800029d4:	16848493          	addi	s1,s1,360
    800029d8:	03248263          	beq	s1,s2,800029fc <procdump+0x9a>
        if (p->state == UNUSED)
    800029dc:	86a6                	mv	a3,s1
    800029de:	ec04a783          	lw	a5,-320(s1)
    800029e2:	dbed                	beqz	a5,800029d4 <procdump+0x72>
            state = "???";
    800029e4:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029e6:	fcfb6be3          	bltu	s6,a5,800029bc <procdump+0x5a>
    800029ea:	02079713          	slli	a4,a5,0x20
    800029ee:	01d75793          	srli	a5,a4,0x1d
    800029f2:	97de                	add	a5,a5,s7
    800029f4:	6390                	ld	a2,0(a5)
    800029f6:	f279                	bnez	a2,800029bc <procdump+0x5a>
            state = "???";
    800029f8:	864e                	mv	a2,s3
    800029fa:	b7c9                	j	800029bc <procdump+0x5a>
    }
}
    800029fc:	60a6                	ld	ra,72(sp)
    800029fe:	6406                	ld	s0,64(sp)
    80002a00:	74e2                	ld	s1,56(sp)
    80002a02:	7942                	ld	s2,48(sp)
    80002a04:	79a2                	ld	s3,40(sp)
    80002a06:	7a02                	ld	s4,32(sp)
    80002a08:	6ae2                	ld	s5,24(sp)
    80002a0a:	6b42                	ld	s6,16(sp)
    80002a0c:	6ba2                	ld	s7,8(sp)
    80002a0e:	6161                	addi	sp,sp,80
    80002a10:	8082                	ret

0000000080002a12 <schedls>:

void schedls()
{
    80002a12:	1141                	addi	sp,sp,-16
    80002a14:	e406                	sd	ra,8(sp)
    80002a16:	e022                	sd	s0,0(sp)
    80002a18:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002a1a:	00006517          	auipc	a0,0x6
    80002a1e:	8de50513          	addi	a0,a0,-1826 # 800082f8 <digits+0x2a8>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	b7a080e7          	jalr	-1158(ra) # 8000059c <printf>
    printf("====================================\n");
    80002a2a:	00006517          	auipc	a0,0x6
    80002a2e:	8f650513          	addi	a0,a0,-1802 # 80008320 <digits+0x2d0>
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	b6a080e7          	jalr	-1174(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002a3a:	00006717          	auipc	a4,0x6
    80002a3e:	fce73703          	ld	a4,-50(a4) # 80008a08 <available_schedulers+0x10>
    80002a42:	00006797          	auipc	a5,0x6
    80002a46:	f667b783          	ld	a5,-154(a5) # 800089a8 <sched_pointer>
    80002a4a:	04f70663          	beq	a4,a5,80002a96 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002a4e:	00006517          	auipc	a0,0x6
    80002a52:	90250513          	addi	a0,a0,-1790 # 80008350 <digits+0x300>
    80002a56:	ffffe097          	auipc	ra,0xffffe
    80002a5a:	b46080e7          	jalr	-1210(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002a5e:	00006617          	auipc	a2,0x6
    80002a62:	fb262603          	lw	a2,-78(a2) # 80008a10 <available_schedulers+0x18>
    80002a66:	00006597          	auipc	a1,0x6
    80002a6a:	f9258593          	addi	a1,a1,-110 # 800089f8 <available_schedulers>
    80002a6e:	00006517          	auipc	a0,0x6
    80002a72:	8ea50513          	addi	a0,a0,-1814 # 80008358 <digits+0x308>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	b26080e7          	jalr	-1242(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002a7e:	00006517          	auipc	a0,0x6
    80002a82:	8e250513          	addi	a0,a0,-1822 # 80008360 <digits+0x310>
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	b16080e7          	jalr	-1258(ra) # 8000059c <printf>
}
    80002a8e:	60a2                	ld	ra,8(sp)
    80002a90:	6402                	ld	s0,0(sp)
    80002a92:	0141                	addi	sp,sp,16
    80002a94:	8082                	ret
            printf("[*]\t");
    80002a96:	00006517          	auipc	a0,0x6
    80002a9a:	8b250513          	addi	a0,a0,-1870 # 80008348 <digits+0x2f8>
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	afe080e7          	jalr	-1282(ra) # 8000059c <printf>
    80002aa6:	bf65                	j	80002a5e <schedls+0x4c>

0000000080002aa8 <schedset>:

void schedset(int id)
{
    80002aa8:	1141                	addi	sp,sp,-16
    80002aaa:	e406                	sd	ra,8(sp)
    80002aac:	e022                	sd	s0,0(sp)
    80002aae:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002ab0:	e90d                	bnez	a0,80002ae2 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002ab2:	00006797          	auipc	a5,0x6
    80002ab6:	f567b783          	ld	a5,-170(a5) # 80008a08 <available_schedulers+0x10>
    80002aba:	00006717          	auipc	a4,0x6
    80002abe:	eef73723          	sd	a5,-274(a4) # 800089a8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002ac2:	00006597          	auipc	a1,0x6
    80002ac6:	f3658593          	addi	a1,a1,-202 # 800089f8 <available_schedulers>
    80002aca:	00006517          	auipc	a0,0x6
    80002ace:	8d650513          	addi	a0,a0,-1834 # 800083a0 <digits+0x350>
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	aca080e7          	jalr	-1334(ra) # 8000059c <printf>
}
    80002ada:	60a2                	ld	ra,8(sp)
    80002adc:	6402                	ld	s0,0(sp)
    80002ade:	0141                	addi	sp,sp,16
    80002ae0:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002ae2:	00006517          	auipc	a0,0x6
    80002ae6:	89650513          	addi	a0,a0,-1898 # 80008378 <digits+0x328>
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	ab2080e7          	jalr	-1358(ra) # 8000059c <printf>
        return;
    80002af2:	b7e5                	j	80002ada <schedset+0x32>

0000000080002af4 <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    80002af4:	7179                	addi	sp,sp,-48
    80002af6:	f406                	sd	ra,40(sp)
    80002af8:	f022                	sd	s0,32(sp)
    80002afa:	ec26                	sd	s1,24(sp)
    80002afc:	e84a                	sd	s2,16(sp)
    80002afe:	e44e                	sd	s3,8(sp)
    80002b00:	e052                	sd	s4,0(sp)
    80002b02:	1800                	addi	s0,sp,48
    80002b04:	8a2a                	mv	s4,a0
    80002b06:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    80002b08:	0002e497          	auipc	s1,0x2e
    80002b0c:	63048493          	addi	s1,s1,1584 # 80031138 <proc>
    80002b10:	00034997          	auipc	s3,0x34
    80002b14:	02898993          	addi	s3,s3,40 # 80036b38 <tickslock>
    80002b18:	a811                	j	80002b2c <transvirtproc+0x38>
    {
	acquire(&p->lock);
	found = p->pid == pid && p->state != UNUSED; 
	release(&p->lock);
    80002b1a:	8526                	mv	a0,s1
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	38a080e7          	jalr	906(ra) # 80000ea6 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002b24:	16848493          	addi	s1,s1,360
    80002b28:	03348f63          	beq	s1,s3,80002b66 <transvirtproc+0x72>
	acquire(&p->lock);
    80002b2c:	8526                	mv	a0,s1
    80002b2e:	ffffe097          	auipc	ra,0xffffe
    80002b32:	2c4080e7          	jalr	708(ra) # 80000df2 <acquire>
	found = p->pid == pid && p->state != UNUSED; 
    80002b36:	589c                	lw	a5,48(s1)
    80002b38:	ff2791e3          	bne	a5,s2,80002b1a <transvirtproc+0x26>
    80002b3c:	4c9c                	lw	a5,24(s1)
    80002b3e:	dff1                	beqz	a5,80002b1a <transvirtproc+0x26>
	release(&p->lock);
    80002b40:	8526                	mv	a0,s1
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	364080e7          	jalr	868(ra) # 80000ea6 <release>
    if (!found) {
	return 0;
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002b4a:	68ac                	ld	a1,80(s1)
    80002b4c:	8552                	mv	a0,s4
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	ee2080e7          	jalr	-286(ra) # 80001a30 <transvirt>
}
    80002b56:	70a2                	ld	ra,40(sp)
    80002b58:	7402                	ld	s0,32(sp)
    80002b5a:	64e2                	ld	s1,24(sp)
    80002b5c:	6942                	ld	s2,16(sp)
    80002b5e:	69a2                	ld	s3,8(sp)
    80002b60:	6a02                	ld	s4,0(sp)
    80002b62:	6145                	addi	sp,sp,48
    80002b64:	8082                	ret
	return 0;
    80002b66:	4501                	li	a0,0
    80002b68:	b7fd                	j	80002b56 <transvirtproc+0x62>

0000000080002b6a <swtch>:
    80002b6a:	00153023          	sd	ra,0(a0)
    80002b6e:	00253423          	sd	sp,8(a0)
    80002b72:	e900                	sd	s0,16(a0)
    80002b74:	ed04                	sd	s1,24(a0)
    80002b76:	03253023          	sd	s2,32(a0)
    80002b7a:	03353423          	sd	s3,40(a0)
    80002b7e:	03453823          	sd	s4,48(a0)
    80002b82:	03553c23          	sd	s5,56(a0)
    80002b86:	05653023          	sd	s6,64(a0)
    80002b8a:	05753423          	sd	s7,72(a0)
    80002b8e:	05853823          	sd	s8,80(a0)
    80002b92:	05953c23          	sd	s9,88(a0)
    80002b96:	07a53023          	sd	s10,96(a0)
    80002b9a:	07b53423          	sd	s11,104(a0)
    80002b9e:	0005b083          	ld	ra,0(a1)
    80002ba2:	0085b103          	ld	sp,8(a1)
    80002ba6:	6980                	ld	s0,16(a1)
    80002ba8:	6d84                	ld	s1,24(a1)
    80002baa:	0205b903          	ld	s2,32(a1)
    80002bae:	0285b983          	ld	s3,40(a1)
    80002bb2:	0305ba03          	ld	s4,48(a1)
    80002bb6:	0385ba83          	ld	s5,56(a1)
    80002bba:	0405bb03          	ld	s6,64(a1)
    80002bbe:	0485bb83          	ld	s7,72(a1)
    80002bc2:	0505bc03          	ld	s8,80(a1)
    80002bc6:	0585bc83          	ld	s9,88(a1)
    80002bca:	0605bd03          	ld	s10,96(a1)
    80002bce:	0685bd83          	ld	s11,104(a1)
    80002bd2:	8082                	ret

0000000080002bd4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002bd4:	1141                	addi	sp,sp,-16
    80002bd6:	e406                	sd	ra,8(sp)
    80002bd8:	e022                	sd	s0,0(sp)
    80002bda:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002bdc:	00006597          	auipc	a1,0x6
    80002be0:	84c58593          	addi	a1,a1,-1972 # 80008428 <states.0+0x30>
    80002be4:	00034517          	auipc	a0,0x34
    80002be8:	f5450513          	addi	a0,a0,-172 # 80036b38 <tickslock>
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	176080e7          	jalr	374(ra) # 80000d62 <initlock>
}
    80002bf4:	60a2                	ld	ra,8(sp)
    80002bf6:	6402                	ld	s0,0(sp)
    80002bf8:	0141                	addi	sp,sp,16
    80002bfa:	8082                	ret

0000000080002bfc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bfc:	1141                	addi	sp,sp,-16
    80002bfe:	e422                	sd	s0,8(sp)
    80002c00:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002c02:	00003797          	auipc	a5,0x3
    80002c06:	6ae78793          	addi	a5,a5,1710 # 800062b0 <kernelvec>
    80002c0a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c0e:	6422                	ld	s0,8(sp)
    80002c10:	0141                	addi	sp,sp,16
    80002c12:	8082                	ret

0000000080002c14 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002c14:	1141                	addi	sp,sp,-16
    80002c16:	e406                	sd	ra,8(sp)
    80002c18:	e022                	sd	s0,0(sp)
    80002c1a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	0e4080e7          	jalr	228(ra) # 80001d00 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002c24:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c28:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002c2a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002c2e:	00004697          	auipc	a3,0x4
    80002c32:	3d268693          	addi	a3,a3,978 # 80007000 <_trampoline>
    80002c36:	00004717          	auipc	a4,0x4
    80002c3a:	3ca70713          	addi	a4,a4,970 # 80007000 <_trampoline>
    80002c3e:	8f15                	sub	a4,a4,a3
    80002c40:	040007b7          	lui	a5,0x4000
    80002c44:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002c46:	07b2                	slli	a5,a5,0xc
    80002c48:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002c4a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c4e:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002c50:	18002673          	csrr	a2,satp
    80002c54:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c56:	6d30                	ld	a2,88(a0)
    80002c58:	6138                	ld	a4,64(a0)
    80002c5a:	6585                	lui	a1,0x1
    80002c5c:	972e                	add	a4,a4,a1
    80002c5e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c60:	6d38                	ld	a4,88(a0)
    80002c62:	00000617          	auipc	a2,0x0
    80002c66:	13060613          	addi	a2,a2,304 # 80002d92 <usertrap>
    80002c6a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c6c:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002c6e:	8612                	mv	a2,tp
    80002c70:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002c72:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c76:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c7a:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002c7e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c82:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002c84:	6f18                	ld	a4,24(a4)
    80002c86:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c8a:	6928                	ld	a0,80(a0)
    80002c8c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c8e:	00004717          	auipc	a4,0x4
    80002c92:	40e70713          	addi	a4,a4,1038 # 8000709c <userret>
    80002c96:	8f15                	sub	a4,a4,a3
    80002c98:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c9a:	577d                	li	a4,-1
    80002c9c:	177e                	slli	a4,a4,0x3f
    80002c9e:	8d59                	or	a0,a0,a4
    80002ca0:	9782                	jalr	a5
}
    80002ca2:	60a2                	ld	ra,8(sp)
    80002ca4:	6402                	ld	s0,0(sp)
    80002ca6:	0141                	addi	sp,sp,16
    80002ca8:	8082                	ret

0000000080002caa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002caa:	1101                	addi	sp,sp,-32
    80002cac:	ec06                	sd	ra,24(sp)
    80002cae:	e822                	sd	s0,16(sp)
    80002cb0:	e426                	sd	s1,8(sp)
    80002cb2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002cb4:	00034497          	auipc	s1,0x34
    80002cb8:	e8448493          	addi	s1,s1,-380 # 80036b38 <tickslock>
    80002cbc:	8526                	mv	a0,s1
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	134080e7          	jalr	308(ra) # 80000df2 <acquire>
  ticks++;
    80002cc6:	00006517          	auipc	a0,0x6
    80002cca:	dba50513          	addi	a0,a0,-582 # 80008a80 <ticks>
    80002cce:	411c                	lw	a5,0(a0)
    80002cd0:	2785                	addiw	a5,a5,1
    80002cd2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002cd4:	00000097          	auipc	ra,0x0
    80002cd8:	83e080e7          	jalr	-1986(ra) # 80002512 <wakeup>
  release(&tickslock);
    80002cdc:	8526                	mv	a0,s1
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	1c8080e7          	jalr	456(ra) # 80000ea6 <release>
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6105                	addi	sp,sp,32
    80002cee:	8082                	ret

0000000080002cf0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cf0:	1101                	addi	sp,sp,-32
    80002cf2:	ec06                	sd	ra,24(sp)
    80002cf4:	e822                	sd	s0,16(sp)
    80002cf6:	e426                	sd	s1,8(sp)
    80002cf8:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, scause" : "=r"(x));
    80002cfa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002cfe:	00074d63          	bltz	a4,80002d18 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002d02:	57fd                	li	a5,-1
    80002d04:	17fe                	slli	a5,a5,0x3f
    80002d06:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002d08:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002d0a:	06f70363          	beq	a4,a5,80002d70 <devintr+0x80>
  }
}
    80002d0e:	60e2                	ld	ra,24(sp)
    80002d10:	6442                	ld	s0,16(sp)
    80002d12:	64a2                	ld	s1,8(sp)
    80002d14:	6105                	addi	sp,sp,32
    80002d16:	8082                	ret
     (scause & 0xff) == 9){
    80002d18:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002d1c:	46a5                	li	a3,9
    80002d1e:	fed792e3          	bne	a5,a3,80002d02 <devintr+0x12>
    int irq = plic_claim();
    80002d22:	00003097          	auipc	ra,0x3
    80002d26:	696080e7          	jalr	1686(ra) # 800063b8 <plic_claim>
    80002d2a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d2c:	47a9                	li	a5,10
    80002d2e:	02f50763          	beq	a0,a5,80002d5c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d32:	4785                	li	a5,1
    80002d34:	02f50963          	beq	a0,a5,80002d66 <devintr+0x76>
    return 1;
    80002d38:	4505                	li	a0,1
    } else if(irq){
    80002d3a:	d8f1                	beqz	s1,80002d0e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d3c:	85a6                	mv	a1,s1
    80002d3e:	00005517          	auipc	a0,0x5
    80002d42:	6f250513          	addi	a0,a0,1778 # 80008430 <states.0+0x38>
    80002d46:	ffffe097          	auipc	ra,0xffffe
    80002d4a:	856080e7          	jalr	-1962(ra) # 8000059c <printf>
      plic_complete(irq);
    80002d4e:	8526                	mv	a0,s1
    80002d50:	00003097          	auipc	ra,0x3
    80002d54:	68c080e7          	jalr	1676(ra) # 800063dc <plic_complete>
    return 1;
    80002d58:	4505                	li	a0,1
    80002d5a:	bf55                	j	80002d0e <devintr+0x1e>
      uartintr();
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	c4e080e7          	jalr	-946(ra) # 800009aa <uartintr>
    80002d64:	b7ed                	j	80002d4e <devintr+0x5e>
      virtio_disk_intr();
    80002d66:	00004097          	auipc	ra,0x4
    80002d6a:	b3e080e7          	jalr	-1218(ra) # 800068a4 <virtio_disk_intr>
    80002d6e:	b7c5                	j	80002d4e <devintr+0x5e>
    if(cpuid() == 0){
    80002d70:	fffff097          	auipc	ra,0xfffff
    80002d74:	f64080e7          	jalr	-156(ra) # 80001cd4 <cpuid>
    80002d78:	c901                	beqz	a0,80002d88 <devintr+0x98>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002d7a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d7e:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002d80:	14479073          	csrw	sip,a5
    return 2;
    80002d84:	4509                	li	a0,2
    80002d86:	b761                	j	80002d0e <devintr+0x1e>
      clockintr();
    80002d88:	00000097          	auipc	ra,0x0
    80002d8c:	f22080e7          	jalr	-222(ra) # 80002caa <clockintr>
    80002d90:	b7ed                	j	80002d7a <devintr+0x8a>

0000000080002d92 <usertrap>:
{
    80002d92:	7179                	addi	sp,sp,-48
    80002d94:	f406                	sd	ra,40(sp)
    80002d96:	f022                	sd	s0,32(sp)
    80002d98:	ec26                	sd	s1,24(sp)
    80002d9a:	e84a                	sd	s2,16(sp)
    80002d9c:	e44e                	sd	s3,8(sp)
    80002d9e:	e052                	sd	s4,0(sp)
    80002da0:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002da2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002da6:	1007f793          	andi	a5,a5,256
    80002daa:	efb5                	bnez	a5,80002e26 <usertrap+0x94>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002dac:	00003797          	auipc	a5,0x3
    80002db0:	50478793          	addi	a5,a5,1284 # 800062b0 <kernelvec>
    80002db4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	f48080e7          	jalr	-184(ra) # 80001d00 <myproc>
    80002dc0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002dc2:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002dc4:	14102773          	csrr	a4,sepc
    80002dc8:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002dca:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002dce:	47a1                	li	a5,8
    80002dd0:	06f70363          	beq	a4,a5,80002e36 <usertrap+0xa4>
  } else if((which_dev = devintr()) != 0){
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	f1c080e7          	jalr	-228(ra) # 80002cf0 <devintr>
    80002ddc:	892a                	mv	s2,a0
    80002dde:	16051063          	bnez	a0,80002f3e <usertrap+0x1ac>
    80002de2:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002de6:	47bd                	li	a5,15
    80002de8:	0af70263          	beq	a4,a5,80002e8c <usertrap+0xfa>
    80002dec:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002df0:	5890                	lw	a2,48(s1)
    80002df2:	00005517          	auipc	a0,0x5
    80002df6:	68650513          	addi	a0,a0,1670 # 80008478 <states.0+0x80>
    80002dfa:	ffffd097          	auipc	ra,0xffffd
    80002dfe:	7a2080e7          	jalr	1954(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002e02:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002e06:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e0a:	00005517          	auipc	a0,0x5
    80002e0e:	69e50513          	addi	a0,a0,1694 # 800084a8 <states.0+0xb0>
    80002e12:	ffffd097          	auipc	ra,0xffffd
    80002e16:	78a080e7          	jalr	1930(ra) # 8000059c <printf>
    setkilled(p);
    80002e1a:	8526                	mv	a0,s1
    80002e1c:	00000097          	auipc	ra,0x0
    80002e20:	90e080e7          	jalr	-1778(ra) # 8000272a <setkilled>
    80002e24:	a825                	j	80002e5c <usertrap+0xca>
    panic("usertrap: not from user mode");
    80002e26:	00005517          	auipc	a0,0x5
    80002e2a:	62a50513          	addi	a0,a0,1578 # 80008450 <states.0+0x58>
    80002e2e:	ffffd097          	auipc	ra,0xffffd
    80002e32:	712080e7          	jalr	1810(ra) # 80000540 <panic>
    if(killed(p))
    80002e36:	00000097          	auipc	ra,0x0
    80002e3a:	920080e7          	jalr	-1760(ra) # 80002756 <killed>
    80002e3e:	e129                	bnez	a0,80002e80 <usertrap+0xee>
    p->trapframe->epc += 4;
    80002e40:	6cb8                	ld	a4,88(s1)
    80002e42:	6f1c                	ld	a5,24(a4)
    80002e44:	0791                	addi	a5,a5,4
    80002e46:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002e48:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e4c:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002e50:	10079073          	csrw	sstatus,a5
    syscall();
    80002e54:	00000097          	auipc	ra,0x0
    80002e58:	35e080e7          	jalr	862(ra) # 800031b2 <syscall>
  if(killed(p))
    80002e5c:	8526                	mv	a0,s1
    80002e5e:	00000097          	auipc	ra,0x0
    80002e62:	8f8080e7          	jalr	-1800(ra) # 80002756 <killed>
    80002e66:	e17d                	bnez	a0,80002f4c <usertrap+0x1ba>
  usertrapret();
    80002e68:	00000097          	auipc	ra,0x0
    80002e6c:	dac080e7          	jalr	-596(ra) # 80002c14 <usertrapret>
}
    80002e70:	70a2                	ld	ra,40(sp)
    80002e72:	7402                	ld	s0,32(sp)
    80002e74:	64e2                	ld	s1,24(sp)
    80002e76:	6942                	ld	s2,16(sp)
    80002e78:	69a2                	ld	s3,8(sp)
    80002e7a:	6a02                	ld	s4,0(sp)
    80002e7c:	6145                	addi	sp,sp,48
    80002e7e:	8082                	ret
      exit(-1);
    80002e80:	557d                	li	a0,-1
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	760080e7          	jalr	1888(ra) # 800025e2 <exit>
    80002e8a:	bf5d                	j	80002e40 <usertrap+0xae>
    asm volatile("csrr %0, stval" : "=r"(x));
    80002e8c:	143029f3          	csrr	s3,stval
    uint64 va = PGROUNDDOWN(r_stval());
    80002e90:	77fd                	lui	a5,0xfffff
    80002e92:	00f9f9b3          	and	s3,s3,a5
    acquire(&p->lock);
    80002e96:	8526                	mv	a0,s1
    80002e98:	ffffe097          	auipc	ra,0xffffe
    80002e9c:	f5a080e7          	jalr	-166(ra) # 80000df2 <acquire>
    pagetable_t pgtable = p->pagetable;
    80002ea0:	0504b903          	ld	s2,80(s1)
    int pid = p->pid;
    80002ea4:	0304aa03          	lw	s4,48(s1)
    release(&p->lock);
    80002ea8:	8526                	mv	a0,s1
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	ffc080e7          	jalr	-4(ra) # 80000ea6 <release>
    pte_t *pgentry = walk(pgtable, va, 0);
    80002eb2:	4601                	li	a2,0
    80002eb4:	85ce                	mv	a1,s3
    80002eb6:	854a                	mv	a0,s2
    80002eb8:	ffffe097          	auipc	ra,0xffffe
    80002ebc:	31a080e7          	jalr	794(ra) # 800011d2 <walk>
    80002ec0:	892a                	mv	s2,a0
    if (PTE_COW & *pgentry)
    80002ec2:	611c                	ld	a5,0(a0)
    80002ec4:	2007f793          	andi	a5,a5,512
    80002ec8:	dbd1                	beqz	a5,80002e5c <usertrap+0xca>
      uint64 pa = transvirtproc(va, pid);
    80002eca:	85d2                	mv	a1,s4
    80002ecc:	854e                	mv	a0,s3
    80002ece:	00000097          	auipc	ra,0x0
    80002ed2:	c26080e7          	jalr	-986(ra) # 80002af4 <transvirtproc>
    80002ed6:	8a2a                	mv	s4,a0
      int refcount = getrefcount(pa);
    80002ed8:	ffffe097          	auipc	ra,0xffffe
    80002edc:	b4e080e7          	jalr	-1202(ra) # 80000a26 <getrefcount>
      *pgentry &= ~PTE_COW;
    80002ee0:	00093783          	ld	a5,0(s2)
    80002ee4:	dff7f793          	andi	a5,a5,-513
      *pgentry |= PTE_W;
    80002ee8:	0047e793          	ori	a5,a5,4
    80002eec:	00f93023          	sd	a5,0(s2)
      if (refcount > 1) {
    80002ef0:	4785                	li	a5,1
    80002ef2:	f6a7d5e3          	bge	a5,a0,80002e5c <usertrap+0xca>
	decrefcount(pa);
    80002ef6:	8552                	mv	a0,s4
    80002ef8:	ffffe097          	auipc	ra,0xffffe
    80002efc:	b54080e7          	jalr	-1196(ra) # 80000a4c <decrefcount>
	void* new = kalloc();
    80002f00:	ffffe097          	auipc	ra,0xffffe
    80002f04:	d68080e7          	jalr	-664(ra) # 80000c68 <kalloc>
    80002f08:	89aa                	mv	s3,a0
	if (new == 0)
    80002f0a:	c115                	beqz	a0,80002f2e <usertrap+0x19c>
	memmove(new, (void*) pa, PGSIZE);
    80002f0c:	6605                	lui	a2,0x1
    80002f0e:	85d2                	mv	a1,s4
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	03a080e7          	jalr	58(ra) # 80000f4a <memmove>
	*pgentry = PA2PTE(new) | flags;
    80002f18:	00c9d793          	srli	a5,s3,0xc
    80002f1c:	07aa                	slli	a5,a5,0xa
	uint flags = PTE_FLAGS(*pgentry);
    80002f1e:	00093703          	ld	a4,0(s2)
	*pgentry = PA2PTE(new) | flags;
    80002f22:	3ff77713          	andi	a4,a4,1023
    80002f26:	8fd9                	or	a5,a5,a4
    80002f28:	00f93023          	sd	a5,0(s2)
    80002f2c:	bf05                	j	80002e5c <usertrap+0xca>
	  panic("hello");
    80002f2e:	00005517          	auipc	a0,0x5
    80002f32:	54250513          	addi	a0,a0,1346 # 80008470 <states.0+0x78>
    80002f36:	ffffd097          	auipc	ra,0xffffd
    80002f3a:	60a080e7          	jalr	1546(ra) # 80000540 <panic>
  if(killed(p))
    80002f3e:	8526                	mv	a0,s1
    80002f40:	00000097          	auipc	ra,0x0
    80002f44:	816080e7          	jalr	-2026(ra) # 80002756 <killed>
    80002f48:	c901                	beqz	a0,80002f58 <usertrap+0x1c6>
    80002f4a:	a011                	j	80002f4e <usertrap+0x1bc>
    80002f4c:	4901                	li	s2,0
    exit(-1);
    80002f4e:	557d                	li	a0,-1
    80002f50:	fffff097          	auipc	ra,0xfffff
    80002f54:	692080e7          	jalr	1682(ra) # 800025e2 <exit>
  if(which_dev == 2)
    80002f58:	4789                	li	a5,2
    80002f5a:	f0f917e3          	bne	s2,a5,80002e68 <usertrap+0xd6>
    yield();
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	514080e7          	jalr	1300(ra) # 80002472 <yield>
    80002f66:	b709                	j	80002e68 <usertrap+0xd6>

0000000080002f68 <kerneltrap>:
{
    80002f68:	7179                	addi	sp,sp,-48
    80002f6a:	f406                	sd	ra,40(sp)
    80002f6c:	f022                	sd	s0,32(sp)
    80002f6e:	ec26                	sd	s1,24(sp)
    80002f70:	e84a                	sd	s2,16(sp)
    80002f72:	e44e                	sd	s3,8(sp)
    80002f74:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002f76:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f7a:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    80002f7e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f82:	1004f793          	andi	a5,s1,256
    80002f86:	cb85                	beqz	a5,80002fb6 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f88:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002f8c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f8e:	ef85                	bnez	a5,80002fc6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	d60080e7          	jalr	-672(ra) # 80002cf0 <devintr>
    80002f98:	cd1d                	beqz	a0,80002fd6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f9a:	4789                	li	a5,2
    80002f9c:	06f50a63          	beq	a0,a5,80003010 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002fa0:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002fa4:	10049073          	csrw	sstatus,s1
}
    80002fa8:	70a2                	ld	ra,40(sp)
    80002faa:	7402                	ld	s0,32(sp)
    80002fac:	64e2                	ld	s1,24(sp)
    80002fae:	6942                	ld	s2,16(sp)
    80002fb0:	69a2                	ld	s3,8(sp)
    80002fb2:	6145                	addi	sp,sp,48
    80002fb4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002fb6:	00005517          	auipc	a0,0x5
    80002fba:	51250513          	addi	a0,a0,1298 # 800084c8 <states.0+0xd0>
    80002fbe:	ffffd097          	auipc	ra,0xffffd
    80002fc2:	582080e7          	jalr	1410(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002fc6:	00005517          	auipc	a0,0x5
    80002fca:	52a50513          	addi	a0,a0,1322 # 800084f0 <states.0+0xf8>
    80002fce:	ffffd097          	auipc	ra,0xffffd
    80002fd2:	572080e7          	jalr	1394(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002fd6:	85ce                	mv	a1,s3
    80002fd8:	00005517          	auipc	a0,0x5
    80002fdc:	53850513          	addi	a0,a0,1336 # 80008510 <states.0+0x118>
    80002fe0:	ffffd097          	auipc	ra,0xffffd
    80002fe4:	5bc080e7          	jalr	1468(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002fe8:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002fec:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ff0:	00005517          	auipc	a0,0x5
    80002ff4:	53050513          	addi	a0,a0,1328 # 80008520 <states.0+0x128>
    80002ff8:	ffffd097          	auipc	ra,0xffffd
    80002ffc:	5a4080e7          	jalr	1444(ra) # 8000059c <printf>
    panic("kerneltrap");
    80003000:	00005517          	auipc	a0,0x5
    80003004:	53850513          	addi	a0,a0,1336 # 80008538 <states.0+0x140>
    80003008:	ffffd097          	auipc	ra,0xffffd
    8000300c:	538080e7          	jalr	1336(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003010:	fffff097          	auipc	ra,0xfffff
    80003014:	cf0080e7          	jalr	-784(ra) # 80001d00 <myproc>
    80003018:	d541                	beqz	a0,80002fa0 <kerneltrap+0x38>
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	ce6080e7          	jalr	-794(ra) # 80001d00 <myproc>
    80003022:	4d18                	lw	a4,24(a0)
    80003024:	4791                	li	a5,4
    80003026:	f6f71de3          	bne	a4,a5,80002fa0 <kerneltrap+0x38>
    yield();
    8000302a:	fffff097          	auipc	ra,0xfffff
    8000302e:	448080e7          	jalr	1096(ra) # 80002472 <yield>
    80003032:	b7bd                	j	80002fa0 <kerneltrap+0x38>

0000000080003034 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80003034:	1101                	addi	sp,sp,-32
    80003036:	ec06                	sd	ra,24(sp)
    80003038:	e822                	sd	s0,16(sp)
    8000303a:	e426                	sd	s1,8(sp)
    8000303c:	1000                	addi	s0,sp,32
    8000303e:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	cc0080e7          	jalr	-832(ra) # 80001d00 <myproc>
    switch (n)
    80003048:	4795                	li	a5,5
    8000304a:	0497e163          	bltu	a5,s1,8000308c <argraw+0x58>
    8000304e:	048a                	slli	s1,s1,0x2
    80003050:	00005717          	auipc	a4,0x5
    80003054:	52070713          	addi	a4,a4,1312 # 80008570 <states.0+0x178>
    80003058:	94ba                	add	s1,s1,a4
    8000305a:	409c                	lw	a5,0(s1)
    8000305c:	97ba                	add	a5,a5,a4
    8000305e:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80003060:	6d3c                	ld	a5,88(a0)
    80003062:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	64a2                	ld	s1,8(sp)
    8000306a:	6105                	addi	sp,sp,32
    8000306c:	8082                	ret
        return p->trapframe->a1;
    8000306e:	6d3c                	ld	a5,88(a0)
    80003070:	7fa8                	ld	a0,120(a5)
    80003072:	bfcd                	j	80003064 <argraw+0x30>
        return p->trapframe->a2;
    80003074:	6d3c                	ld	a5,88(a0)
    80003076:	63c8                	ld	a0,128(a5)
    80003078:	b7f5                	j	80003064 <argraw+0x30>
        return p->trapframe->a3;
    8000307a:	6d3c                	ld	a5,88(a0)
    8000307c:	67c8                	ld	a0,136(a5)
    8000307e:	b7dd                	j	80003064 <argraw+0x30>
        return p->trapframe->a4;
    80003080:	6d3c                	ld	a5,88(a0)
    80003082:	6bc8                	ld	a0,144(a5)
    80003084:	b7c5                	j	80003064 <argraw+0x30>
        return p->trapframe->a5;
    80003086:	6d3c                	ld	a5,88(a0)
    80003088:	6fc8                	ld	a0,152(a5)
    8000308a:	bfe9                	j	80003064 <argraw+0x30>
    panic("argraw");
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	4bc50513          	addi	a0,a0,1212 # 80008548 <states.0+0x150>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	4ac080e7          	jalr	1196(ra) # 80000540 <panic>

000000008000309c <fetchaddr>:
{
    8000309c:	1101                	addi	sp,sp,-32
    8000309e:	ec06                	sd	ra,24(sp)
    800030a0:	e822                	sd	s0,16(sp)
    800030a2:	e426                	sd	s1,8(sp)
    800030a4:	e04a                	sd	s2,0(sp)
    800030a6:	1000                	addi	s0,sp,32
    800030a8:	84aa                	mv	s1,a0
    800030aa:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800030ac:	fffff097          	auipc	ra,0xfffff
    800030b0:	c54080e7          	jalr	-940(ra) # 80001d00 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030b4:	653c                	ld	a5,72(a0)
    800030b6:	02f4f863          	bgeu	s1,a5,800030e6 <fetchaddr+0x4a>
    800030ba:	00848713          	addi	a4,s1,8
    800030be:	02e7e663          	bltu	a5,a4,800030ea <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030c2:	46a1                	li	a3,8
    800030c4:	8626                	mv	a2,s1
    800030c6:	85ca                	mv	a1,s2
    800030c8:	6928                	ld	a0,80(a0)
    800030ca:	fffff097          	auipc	ra,0xfffff
    800030ce:	828080e7          	jalr	-2008(ra) # 800018f2 <copyin>
    800030d2:	00a03533          	snez	a0,a0
    800030d6:	40a00533          	neg	a0,a0
}
    800030da:	60e2                	ld	ra,24(sp)
    800030dc:	6442                	ld	s0,16(sp)
    800030de:	64a2                	ld	s1,8(sp)
    800030e0:	6902                	ld	s2,0(sp)
    800030e2:	6105                	addi	sp,sp,32
    800030e4:	8082                	ret
        return -1;
    800030e6:	557d                	li	a0,-1
    800030e8:	bfcd                	j	800030da <fetchaddr+0x3e>
    800030ea:	557d                	li	a0,-1
    800030ec:	b7fd                	j	800030da <fetchaddr+0x3e>

00000000800030ee <fetchstr>:
{
    800030ee:	7179                	addi	sp,sp,-48
    800030f0:	f406                	sd	ra,40(sp)
    800030f2:	f022                	sd	s0,32(sp)
    800030f4:	ec26                	sd	s1,24(sp)
    800030f6:	e84a                	sd	s2,16(sp)
    800030f8:	e44e                	sd	s3,8(sp)
    800030fa:	1800                	addi	s0,sp,48
    800030fc:	892a                	mv	s2,a0
    800030fe:	84ae                	mv	s1,a1
    80003100:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80003102:	fffff097          	auipc	ra,0xfffff
    80003106:	bfe080e7          	jalr	-1026(ra) # 80001d00 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    8000310a:	86ce                	mv	a3,s3
    8000310c:	864a                	mv	a2,s2
    8000310e:	85a6                	mv	a1,s1
    80003110:	6928                	ld	a0,80(a0)
    80003112:	fffff097          	auipc	ra,0xfffff
    80003116:	86e080e7          	jalr	-1938(ra) # 80001980 <copyinstr>
    8000311a:	00054e63          	bltz	a0,80003136 <fetchstr+0x48>
    return strlen(buf);
    8000311e:	8526                	mv	a0,s1
    80003120:	ffffe097          	auipc	ra,0xffffe
    80003124:	f4a080e7          	jalr	-182(ra) # 8000106a <strlen>
}
    80003128:	70a2                	ld	ra,40(sp)
    8000312a:	7402                	ld	s0,32(sp)
    8000312c:	64e2                	ld	s1,24(sp)
    8000312e:	6942                	ld	s2,16(sp)
    80003130:	69a2                	ld	s3,8(sp)
    80003132:	6145                	addi	sp,sp,48
    80003134:	8082                	ret
        return -1;
    80003136:	557d                	li	a0,-1
    80003138:	bfc5                	j	80003128 <fetchstr+0x3a>

000000008000313a <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    8000313a:	1101                	addi	sp,sp,-32
    8000313c:	ec06                	sd	ra,24(sp)
    8000313e:	e822                	sd	s0,16(sp)
    80003140:	e426                	sd	s1,8(sp)
    80003142:	1000                	addi	s0,sp,32
    80003144:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003146:	00000097          	auipc	ra,0x0
    8000314a:	eee080e7          	jalr	-274(ra) # 80003034 <argraw>
    8000314e:	c088                	sw	a0,0(s1)
}
    80003150:	60e2                	ld	ra,24(sp)
    80003152:	6442                	ld	s0,16(sp)
    80003154:	64a2                	ld	s1,8(sp)
    80003156:	6105                	addi	sp,sp,32
    80003158:	8082                	ret

000000008000315a <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	1000                	addi	s0,sp,32
    80003164:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003166:	00000097          	auipc	ra,0x0
    8000316a:	ece080e7          	jalr	-306(ra) # 80003034 <argraw>
    8000316e:	e088                	sd	a0,0(s1)
}
    80003170:	60e2                	ld	ra,24(sp)
    80003172:	6442                	ld	s0,16(sp)
    80003174:	64a2                	ld	s1,8(sp)
    80003176:	6105                	addi	sp,sp,32
    80003178:	8082                	ret

000000008000317a <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    8000317a:	7179                	addi	sp,sp,-48
    8000317c:	f406                	sd	ra,40(sp)
    8000317e:	f022                	sd	s0,32(sp)
    80003180:	ec26                	sd	s1,24(sp)
    80003182:	e84a                	sd	s2,16(sp)
    80003184:	1800                	addi	s0,sp,48
    80003186:	84ae                	mv	s1,a1
    80003188:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    8000318a:	fd840593          	addi	a1,s0,-40
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	fcc080e7          	jalr	-52(ra) # 8000315a <argaddr>
    return fetchstr(addr, buf, max);
    80003196:	864a                	mv	a2,s2
    80003198:	85a6                	mv	a1,s1
    8000319a:	fd843503          	ld	a0,-40(s0)
    8000319e:	00000097          	auipc	ra,0x0
    800031a2:	f50080e7          	jalr	-176(ra) # 800030ee <fetchstr>
}
    800031a6:	70a2                	ld	ra,40(sp)
    800031a8:	7402                	ld	s0,32(sp)
    800031aa:	64e2                	ld	s1,24(sp)
    800031ac:	6942                	ld	s2,16(sp)
    800031ae:	6145                	addi	sp,sp,48
    800031b0:	8082                	ret

00000000800031b2 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    800031b2:	1101                	addi	sp,sp,-32
    800031b4:	ec06                	sd	ra,24(sp)
    800031b6:	e822                	sd	s0,16(sp)
    800031b8:	e426                	sd	s1,8(sp)
    800031ba:	e04a                	sd	s2,0(sp)
    800031bc:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	b42080e7          	jalr	-1214(ra) # 80001d00 <myproc>
    800031c6:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    800031c8:	05853903          	ld	s2,88(a0)
    800031cc:	0a893783          	ld	a5,168(s2)
    800031d0:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800031d4:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffbd0e7>
    800031d6:	4765                	li	a4,25
    800031d8:	00f76f63          	bltu	a4,a5,800031f6 <syscall+0x44>
    800031dc:	00369713          	slli	a4,a3,0x3
    800031e0:	00005797          	auipc	a5,0x5
    800031e4:	3a878793          	addi	a5,a5,936 # 80008588 <syscalls>
    800031e8:	97ba                	add	a5,a5,a4
    800031ea:	639c                	ld	a5,0(a5)
    800031ec:	c789                	beqz	a5,800031f6 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800031ee:	9782                	jalr	a5
    800031f0:	06a93823          	sd	a0,112(s2)
    800031f4:	a839                	j	80003212 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800031f6:	15848613          	addi	a2,s1,344
    800031fa:	588c                	lw	a1,48(s1)
    800031fc:	00005517          	auipc	a0,0x5
    80003200:	35450513          	addi	a0,a0,852 # 80008550 <states.0+0x158>
    80003204:	ffffd097          	auipc	ra,0xffffd
    80003208:	398080e7          	jalr	920(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    8000320c:	6cbc                	ld	a5,88(s1)
    8000320e:	577d                	li	a4,-1
    80003210:	fbb8                	sd	a4,112(a5)
    }
}
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	64a2                	ld	s1,8(sp)
    80003218:	6902                	ld	s2,0(sp)
    8000321a:	6105                	addi	sp,sp,32
    8000321c:	8082                	ret

000000008000321e <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    8000321e:	1101                	addi	sp,sp,-32
    80003220:	ec06                	sd	ra,24(sp)
    80003222:	e822                	sd	s0,16(sp)
    80003224:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80003226:	fec40593          	addi	a1,s0,-20
    8000322a:	4501                	li	a0,0
    8000322c:	00000097          	auipc	ra,0x0
    80003230:	f0e080e7          	jalr	-242(ra) # 8000313a <argint>
    exit(n);
    80003234:	fec42503          	lw	a0,-20(s0)
    80003238:	fffff097          	auipc	ra,0xfffff
    8000323c:	3aa080e7          	jalr	938(ra) # 800025e2 <exit>
    return 0; // not reached
}
    80003240:	4501                	li	a0,0
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	6105                	addi	sp,sp,32
    80003248:	8082                	ret

000000008000324a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000324a:	1141                	addi	sp,sp,-16
    8000324c:	e406                	sd	ra,8(sp)
    8000324e:	e022                	sd	s0,0(sp)
    80003250:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003252:	fffff097          	auipc	ra,0xfffff
    80003256:	aae080e7          	jalr	-1362(ra) # 80001d00 <myproc>
}
    8000325a:	5908                	lw	a0,48(a0)
    8000325c:	60a2                	ld	ra,8(sp)
    8000325e:	6402                	ld	s0,0(sp)
    80003260:	0141                	addi	sp,sp,16
    80003262:	8082                	ret

0000000080003264 <sys_fork>:

uint64
sys_fork(void)
{
    80003264:	1141                	addi	sp,sp,-16
    80003266:	e406                	sd	ra,8(sp)
    80003268:	e022                	sd	s0,0(sp)
    8000326a:	0800                	addi	s0,sp,16
    return fork();
    8000326c:	fffff097          	auipc	ra,0xfffff
    80003270:	fe0080e7          	jalr	-32(ra) # 8000224c <fork>
}
    80003274:	60a2                	ld	ra,8(sp)
    80003276:	6402                	ld	s0,0(sp)
    80003278:	0141                	addi	sp,sp,16
    8000327a:	8082                	ret

000000008000327c <sys_wait>:

uint64
sys_wait(void)
{
    8000327c:	1101                	addi	sp,sp,-32
    8000327e:	ec06                	sd	ra,24(sp)
    80003280:	e822                	sd	s0,16(sp)
    80003282:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003284:	fe840593          	addi	a1,s0,-24
    80003288:	4501                	li	a0,0
    8000328a:	00000097          	auipc	ra,0x0
    8000328e:	ed0080e7          	jalr	-304(ra) # 8000315a <argaddr>
    return wait(p);
    80003292:	fe843503          	ld	a0,-24(s0)
    80003296:	fffff097          	auipc	ra,0xfffff
    8000329a:	4f2080e7          	jalr	1266(ra) # 80002788 <wait>
}
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret

00000000800032a6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032a6:	7179                	addi	sp,sp,-48
    800032a8:	f406                	sd	ra,40(sp)
    800032aa:	f022                	sd	s0,32(sp)
    800032ac:	ec26                	sd	s1,24(sp)
    800032ae:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800032b0:	fdc40593          	addi	a1,s0,-36
    800032b4:	4501                	li	a0,0
    800032b6:	00000097          	auipc	ra,0x0
    800032ba:	e84080e7          	jalr	-380(ra) # 8000313a <argint>
    addr = myproc()->sz;
    800032be:	fffff097          	auipc	ra,0xfffff
    800032c2:	a42080e7          	jalr	-1470(ra) # 80001d00 <myproc>
    800032c6:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    800032c8:	fdc42503          	lw	a0,-36(s0)
    800032cc:	fffff097          	auipc	ra,0xfffff
    800032d0:	d8e080e7          	jalr	-626(ra) # 8000205a <growproc>
    800032d4:	00054863          	bltz	a0,800032e4 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800032d8:	8526                	mv	a0,s1
    800032da:	70a2                	ld	ra,40(sp)
    800032dc:	7402                	ld	s0,32(sp)
    800032de:	64e2                	ld	s1,24(sp)
    800032e0:	6145                	addi	sp,sp,48
    800032e2:	8082                	ret
        return -1;
    800032e4:	54fd                	li	s1,-1
    800032e6:	bfcd                	j	800032d8 <sys_sbrk+0x32>

00000000800032e8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032e8:	7139                	addi	sp,sp,-64
    800032ea:	fc06                	sd	ra,56(sp)
    800032ec:	f822                	sd	s0,48(sp)
    800032ee:	f426                	sd	s1,40(sp)
    800032f0:	f04a                	sd	s2,32(sp)
    800032f2:	ec4e                	sd	s3,24(sp)
    800032f4:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800032f6:	fcc40593          	addi	a1,s0,-52
    800032fa:	4501                	li	a0,0
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	e3e080e7          	jalr	-450(ra) # 8000313a <argint>
    acquire(&tickslock);
    80003304:	00034517          	auipc	a0,0x34
    80003308:	83450513          	addi	a0,a0,-1996 # 80036b38 <tickslock>
    8000330c:	ffffe097          	auipc	ra,0xffffe
    80003310:	ae6080e7          	jalr	-1306(ra) # 80000df2 <acquire>
    ticks0 = ticks;
    80003314:	00005917          	auipc	s2,0x5
    80003318:	76c92903          	lw	s2,1900(s2) # 80008a80 <ticks>
    while (ticks - ticks0 < n)
    8000331c:	fcc42783          	lw	a5,-52(s0)
    80003320:	cf9d                	beqz	a5,8000335e <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80003322:	00034997          	auipc	s3,0x34
    80003326:	81698993          	addi	s3,s3,-2026 # 80036b38 <tickslock>
    8000332a:	00005497          	auipc	s1,0x5
    8000332e:	75648493          	addi	s1,s1,1878 # 80008a80 <ticks>
        if (killed(myproc()))
    80003332:	fffff097          	auipc	ra,0xfffff
    80003336:	9ce080e7          	jalr	-1586(ra) # 80001d00 <myproc>
    8000333a:	fffff097          	auipc	ra,0xfffff
    8000333e:	41c080e7          	jalr	1052(ra) # 80002756 <killed>
    80003342:	ed15                	bnez	a0,8000337e <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003344:	85ce                	mv	a1,s3
    80003346:	8526                	mv	a0,s1
    80003348:	fffff097          	auipc	ra,0xfffff
    8000334c:	166080e7          	jalr	358(ra) # 800024ae <sleep>
    while (ticks - ticks0 < n)
    80003350:	409c                	lw	a5,0(s1)
    80003352:	412787bb          	subw	a5,a5,s2
    80003356:	fcc42703          	lw	a4,-52(s0)
    8000335a:	fce7ece3          	bltu	a5,a4,80003332 <sys_sleep+0x4a>
    }
    release(&tickslock);
    8000335e:	00033517          	auipc	a0,0x33
    80003362:	7da50513          	addi	a0,a0,2010 # 80036b38 <tickslock>
    80003366:	ffffe097          	auipc	ra,0xffffe
    8000336a:	b40080e7          	jalr	-1216(ra) # 80000ea6 <release>
    return 0;
    8000336e:	4501                	li	a0,0
}
    80003370:	70e2                	ld	ra,56(sp)
    80003372:	7442                	ld	s0,48(sp)
    80003374:	74a2                	ld	s1,40(sp)
    80003376:	7902                	ld	s2,32(sp)
    80003378:	69e2                	ld	s3,24(sp)
    8000337a:	6121                	addi	sp,sp,64
    8000337c:	8082                	ret
            release(&tickslock);
    8000337e:	00033517          	auipc	a0,0x33
    80003382:	7ba50513          	addi	a0,a0,1978 # 80036b38 <tickslock>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	b20080e7          	jalr	-1248(ra) # 80000ea6 <release>
            return -1;
    8000338e:	557d                	li	a0,-1
    80003390:	b7c5                	j	80003370 <sys_sleep+0x88>

0000000080003392 <sys_kill>:

uint64
sys_kill(void)
{
    80003392:	1101                	addi	sp,sp,-32
    80003394:	ec06                	sd	ra,24(sp)
    80003396:	e822                	sd	s0,16(sp)
    80003398:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000339a:	fec40593          	addi	a1,s0,-20
    8000339e:	4501                	li	a0,0
    800033a0:	00000097          	auipc	ra,0x0
    800033a4:	d9a080e7          	jalr	-614(ra) # 8000313a <argint>
    return kill(pid);
    800033a8:	fec42503          	lw	a0,-20(s0)
    800033ac:	fffff097          	auipc	ra,0xfffff
    800033b0:	30c080e7          	jalr	780(ra) # 800026b8 <kill>
}
    800033b4:	60e2                	ld	ra,24(sp)
    800033b6:	6442                	ld	s0,16(sp)
    800033b8:	6105                	addi	sp,sp,32
    800033ba:	8082                	ret

00000000800033bc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033bc:	1101                	addi	sp,sp,-32
    800033be:	ec06                	sd	ra,24(sp)
    800033c0:	e822                	sd	s0,16(sp)
    800033c2:	e426                	sd	s1,8(sp)
    800033c4:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800033c6:	00033517          	auipc	a0,0x33
    800033ca:	77250513          	addi	a0,a0,1906 # 80036b38 <tickslock>
    800033ce:	ffffe097          	auipc	ra,0xffffe
    800033d2:	a24080e7          	jalr	-1500(ra) # 80000df2 <acquire>
    xticks = ticks;
    800033d6:	00005497          	auipc	s1,0x5
    800033da:	6aa4a483          	lw	s1,1706(s1) # 80008a80 <ticks>
    release(&tickslock);
    800033de:	00033517          	auipc	a0,0x33
    800033e2:	75a50513          	addi	a0,a0,1882 # 80036b38 <tickslock>
    800033e6:	ffffe097          	auipc	ra,0xffffe
    800033ea:	ac0080e7          	jalr	-1344(ra) # 80000ea6 <release>
    return xticks;
}
    800033ee:	02049513          	slli	a0,s1,0x20
    800033f2:	9101                	srli	a0,a0,0x20
    800033f4:	60e2                	ld	ra,24(sp)
    800033f6:	6442                	ld	s0,16(sp)
    800033f8:	64a2                	ld	s1,8(sp)
    800033fa:	6105                	addi	sp,sp,32
    800033fc:	8082                	ret

00000000800033fe <sys_ps>:

void *
sys_ps(void)
{
    800033fe:	1101                	addi	sp,sp,-32
    80003400:	ec06                	sd	ra,24(sp)
    80003402:	e822                	sd	s0,16(sp)
    80003404:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003406:	fe042623          	sw	zero,-20(s0)
    8000340a:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    8000340e:	fec40593          	addi	a1,s0,-20
    80003412:	4501                	li	a0,0
    80003414:	00000097          	auipc	ra,0x0
    80003418:	d26080e7          	jalr	-730(ra) # 8000313a <argint>
    argint(1, &count);
    8000341c:	fe840593          	addi	a1,s0,-24
    80003420:	4505                	li	a0,1
    80003422:	00000097          	auipc	ra,0x0
    80003426:	d18080e7          	jalr	-744(ra) # 8000313a <argint>
    return ps((uint8)start, (uint8)count);
    8000342a:	fe844583          	lbu	a1,-24(s0)
    8000342e:	fec44503          	lbu	a0,-20(s0)
    80003432:	fffff097          	auipc	ra,0xfffff
    80003436:	c84080e7          	jalr	-892(ra) # 800020b6 <ps>
}
    8000343a:	60e2                	ld	ra,24(sp)
    8000343c:	6442                	ld	s0,16(sp)
    8000343e:	6105                	addi	sp,sp,32
    80003440:	8082                	ret

0000000080003442 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003442:	1141                	addi	sp,sp,-16
    80003444:	e406                	sd	ra,8(sp)
    80003446:	e022                	sd	s0,0(sp)
    80003448:	0800                	addi	s0,sp,16
    schedls();
    8000344a:	fffff097          	auipc	ra,0xfffff
    8000344e:	5c8080e7          	jalr	1480(ra) # 80002a12 <schedls>
    return 0;
}
    80003452:	4501                	li	a0,0
    80003454:	60a2                	ld	ra,8(sp)
    80003456:	6402                	ld	s0,0(sp)
    80003458:	0141                	addi	sp,sp,16
    8000345a:	8082                	ret

000000008000345c <sys_schedset>:

uint64 sys_schedset(void)
{
    8000345c:	1101                	addi	sp,sp,-32
    8000345e:	ec06                	sd	ra,24(sp)
    80003460:	e822                	sd	s0,16(sp)
    80003462:	1000                	addi	s0,sp,32
    int id = 0;
    80003464:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003468:	fec40593          	addi	a1,s0,-20
    8000346c:	4501                	li	a0,0
    8000346e:	00000097          	auipc	ra,0x0
    80003472:	ccc080e7          	jalr	-820(ra) # 8000313a <argint>
    schedset(id - 1);
    80003476:	fec42503          	lw	a0,-20(s0)
    8000347a:	357d                	addiw	a0,a0,-1
    8000347c:	fffff097          	auipc	ra,0xfffff
    80003480:	62c080e7          	jalr	1580(ra) # 80002aa8 <schedset>
    return 0;
}
    80003484:	4501                	li	a0,0
    80003486:	60e2                	ld	ra,24(sp)
    80003488:	6442                	ld	s0,16(sp)
    8000348a:	6105                	addi	sp,sp,32
    8000348c:	8082                	ret

000000008000348e <sys_va2pa>:

uint64 sys_va2pa(void)
{
    8000348e:	7179                	addi	sp,sp,-48
    80003490:	f406                	sd	ra,40(sp)
    80003492:	f022                	sd	s0,32(sp)
    80003494:	ec26                	sd	s1,24(sp)
    80003496:	1800                	addi	s0,sp,48
    int pid = 0;
    80003498:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    8000349c:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    800034a0:	fd040593          	addi	a1,s0,-48
    800034a4:	4501                	li	a0,0
    800034a6:	00000097          	auipc	ra,0x0
    800034aa:	cb4080e7          	jalr	-844(ra) # 8000315a <argaddr>
    argint(1, &pid);
    800034ae:	fdc40593          	addi	a1,s0,-36
    800034b2:	4505                	li	a0,1
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	c86080e7          	jalr	-890(ra) # 8000313a <argint>
    if (pid == 0) {
    800034bc:	fdc42783          	lw	a5,-36(s0)
    800034c0:	cf91                	beqz	a5,800034dc <sys_va2pa+0x4e>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    800034c2:	fdc42583          	lw	a1,-36(s0)
    800034c6:	fd043503          	ld	a0,-48(s0)
    800034ca:	fffff097          	auipc	ra,0xfffff
    800034ce:	62a080e7          	jalr	1578(ra) # 80002af4 <transvirtproc>
}
    800034d2:	70a2                	ld	ra,40(sp)
    800034d4:	7402                	ld	s0,32(sp)
    800034d6:	64e2                	ld	s1,24(sp)
    800034d8:	6145                	addi	sp,sp,48
    800034da:	8082                	ret
	struct proc *p = myproc();
    800034dc:	fffff097          	auipc	ra,0xfffff
    800034e0:	824080e7          	jalr	-2012(ra) # 80001d00 <myproc>
    800034e4:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800034e6:	ffffe097          	auipc	ra,0xffffe
    800034ea:	90c080e7          	jalr	-1780(ra) # 80000df2 <acquire>
	pid = p->pid;
    800034ee:	589c                	lw	a5,48(s1)
    800034f0:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    800034f4:	8526                	mv	a0,s1
    800034f6:	ffffe097          	auipc	ra,0xffffe
    800034fa:	9b0080e7          	jalr	-1616(ra) # 80000ea6 <release>
    800034fe:	b7d1                	j	800034c2 <sys_va2pa+0x34>

0000000080003500 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003500:	1141                	addi	sp,sp,-16
    80003502:	e406                	sd	ra,8(sp)
    80003504:	e022                	sd	s0,0(sp)
    80003506:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    80003508:	00005597          	auipc	a1,0x5
    8000350c:	5505b583          	ld	a1,1360(a1) # 80008a58 <FREE_PAGES>
    80003510:	00005517          	auipc	a0,0x5
    80003514:	05850513          	addi	a0,a0,88 # 80008568 <states.0+0x170>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	084080e7          	jalr	132(ra) # 8000059c <printf>
    return 0;
}
    80003520:	4501                	li	a0,0
    80003522:	60a2                	ld	ra,8(sp)
    80003524:	6402                	ld	s0,0(sp)
    80003526:	0141                	addi	sp,sp,16
    80003528:	8082                	ret

000000008000352a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000352a:	7179                	addi	sp,sp,-48
    8000352c:	f406                	sd	ra,40(sp)
    8000352e:	f022                	sd	s0,32(sp)
    80003530:	ec26                	sd	s1,24(sp)
    80003532:	e84a                	sd	s2,16(sp)
    80003534:	e44e                	sd	s3,8(sp)
    80003536:	e052                	sd	s4,0(sp)
    80003538:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000353a:	00005597          	auipc	a1,0x5
    8000353e:	12658593          	addi	a1,a1,294 # 80008660 <syscalls+0xd8>
    80003542:	00033517          	auipc	a0,0x33
    80003546:	60e50513          	addi	a0,a0,1550 # 80036b50 <bcache>
    8000354a:	ffffe097          	auipc	ra,0xffffe
    8000354e:	818080e7          	jalr	-2024(ra) # 80000d62 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003552:	0003b797          	auipc	a5,0x3b
    80003556:	5fe78793          	addi	a5,a5,1534 # 8003eb50 <bcache+0x8000>
    8000355a:	0003c717          	auipc	a4,0x3c
    8000355e:	85e70713          	addi	a4,a4,-1954 # 8003edb8 <bcache+0x8268>
    80003562:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003566:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000356a:	00033497          	auipc	s1,0x33
    8000356e:	5fe48493          	addi	s1,s1,1534 # 80036b68 <bcache+0x18>
    b->next = bcache.head.next;
    80003572:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003574:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003576:	00005a17          	auipc	s4,0x5
    8000357a:	0f2a0a13          	addi	s4,s4,242 # 80008668 <syscalls+0xe0>
    b->next = bcache.head.next;
    8000357e:	2b893783          	ld	a5,696(s2)
    80003582:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003584:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003588:	85d2                	mv	a1,s4
    8000358a:	01048513          	addi	a0,s1,16
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	4c8080e7          	jalr	1224(ra) # 80004a56 <initsleeplock>
    bcache.head.next->prev = b;
    80003596:	2b893783          	ld	a5,696(s2)
    8000359a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000359c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035a0:	45848493          	addi	s1,s1,1112
    800035a4:	fd349de3          	bne	s1,s3,8000357e <binit+0x54>
  }
}
    800035a8:	70a2                	ld	ra,40(sp)
    800035aa:	7402                	ld	s0,32(sp)
    800035ac:	64e2                	ld	s1,24(sp)
    800035ae:	6942                	ld	s2,16(sp)
    800035b0:	69a2                	ld	s3,8(sp)
    800035b2:	6a02                	ld	s4,0(sp)
    800035b4:	6145                	addi	sp,sp,48
    800035b6:	8082                	ret

00000000800035b8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035b8:	7179                	addi	sp,sp,-48
    800035ba:	f406                	sd	ra,40(sp)
    800035bc:	f022                	sd	s0,32(sp)
    800035be:	ec26                	sd	s1,24(sp)
    800035c0:	e84a                	sd	s2,16(sp)
    800035c2:	e44e                	sd	s3,8(sp)
    800035c4:	1800                	addi	s0,sp,48
    800035c6:	892a                	mv	s2,a0
    800035c8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035ca:	00033517          	auipc	a0,0x33
    800035ce:	58650513          	addi	a0,a0,1414 # 80036b50 <bcache>
    800035d2:	ffffe097          	auipc	ra,0xffffe
    800035d6:	820080e7          	jalr	-2016(ra) # 80000df2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035da:	0003c497          	auipc	s1,0x3c
    800035de:	82e4b483          	ld	s1,-2002(s1) # 8003ee08 <bcache+0x82b8>
    800035e2:	0003b797          	auipc	a5,0x3b
    800035e6:	7d678793          	addi	a5,a5,2006 # 8003edb8 <bcache+0x8268>
    800035ea:	02f48f63          	beq	s1,a5,80003628 <bread+0x70>
    800035ee:	873e                	mv	a4,a5
    800035f0:	a021                	j	800035f8 <bread+0x40>
    800035f2:	68a4                	ld	s1,80(s1)
    800035f4:	02e48a63          	beq	s1,a4,80003628 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035f8:	449c                	lw	a5,8(s1)
    800035fa:	ff279ce3          	bne	a5,s2,800035f2 <bread+0x3a>
    800035fe:	44dc                	lw	a5,12(s1)
    80003600:	ff3799e3          	bne	a5,s3,800035f2 <bread+0x3a>
      b->refcnt++;
    80003604:	40bc                	lw	a5,64(s1)
    80003606:	2785                	addiw	a5,a5,1
    80003608:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000360a:	00033517          	auipc	a0,0x33
    8000360e:	54650513          	addi	a0,a0,1350 # 80036b50 <bcache>
    80003612:	ffffe097          	auipc	ra,0xffffe
    80003616:	894080e7          	jalr	-1900(ra) # 80000ea6 <release>
      acquiresleep(&b->lock);
    8000361a:	01048513          	addi	a0,s1,16
    8000361e:	00001097          	auipc	ra,0x1
    80003622:	472080e7          	jalr	1138(ra) # 80004a90 <acquiresleep>
      return b;
    80003626:	a8b9                	j	80003684 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003628:	0003b497          	auipc	s1,0x3b
    8000362c:	7d84b483          	ld	s1,2008(s1) # 8003ee00 <bcache+0x82b0>
    80003630:	0003b797          	auipc	a5,0x3b
    80003634:	78878793          	addi	a5,a5,1928 # 8003edb8 <bcache+0x8268>
    80003638:	00f48863          	beq	s1,a5,80003648 <bread+0x90>
    8000363c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000363e:	40bc                	lw	a5,64(s1)
    80003640:	cf81                	beqz	a5,80003658 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003642:	64a4                	ld	s1,72(s1)
    80003644:	fee49de3          	bne	s1,a4,8000363e <bread+0x86>
  panic("bget: no buffers");
    80003648:	00005517          	auipc	a0,0x5
    8000364c:	02850513          	addi	a0,a0,40 # 80008670 <syscalls+0xe8>
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	ef0080e7          	jalr	-272(ra) # 80000540 <panic>
      b->dev = dev;
    80003658:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000365c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003660:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003664:	4785                	li	a5,1
    80003666:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003668:	00033517          	auipc	a0,0x33
    8000366c:	4e850513          	addi	a0,a0,1256 # 80036b50 <bcache>
    80003670:	ffffe097          	auipc	ra,0xffffe
    80003674:	836080e7          	jalr	-1994(ra) # 80000ea6 <release>
      acquiresleep(&b->lock);
    80003678:	01048513          	addi	a0,s1,16
    8000367c:	00001097          	auipc	ra,0x1
    80003680:	414080e7          	jalr	1044(ra) # 80004a90 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003684:	409c                	lw	a5,0(s1)
    80003686:	cb89                	beqz	a5,80003698 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003688:	8526                	mv	a0,s1
    8000368a:	70a2                	ld	ra,40(sp)
    8000368c:	7402                	ld	s0,32(sp)
    8000368e:	64e2                	ld	s1,24(sp)
    80003690:	6942                	ld	s2,16(sp)
    80003692:	69a2                	ld	s3,8(sp)
    80003694:	6145                	addi	sp,sp,48
    80003696:	8082                	ret
    virtio_disk_rw(b, 0);
    80003698:	4581                	li	a1,0
    8000369a:	8526                	mv	a0,s1
    8000369c:	00003097          	auipc	ra,0x3
    800036a0:	fd6080e7          	jalr	-42(ra) # 80006672 <virtio_disk_rw>
    b->valid = 1;
    800036a4:	4785                	li	a5,1
    800036a6:	c09c                	sw	a5,0(s1)
  return b;
    800036a8:	b7c5                	j	80003688 <bread+0xd0>

00000000800036aa <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036aa:	1101                	addi	sp,sp,-32
    800036ac:	ec06                	sd	ra,24(sp)
    800036ae:	e822                	sd	s0,16(sp)
    800036b0:	e426                	sd	s1,8(sp)
    800036b2:	1000                	addi	s0,sp,32
    800036b4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036b6:	0541                	addi	a0,a0,16
    800036b8:	00001097          	auipc	ra,0x1
    800036bc:	472080e7          	jalr	1138(ra) # 80004b2a <holdingsleep>
    800036c0:	cd01                	beqz	a0,800036d8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036c2:	4585                	li	a1,1
    800036c4:	8526                	mv	a0,s1
    800036c6:	00003097          	auipc	ra,0x3
    800036ca:	fac080e7          	jalr	-84(ra) # 80006672 <virtio_disk_rw>
}
    800036ce:	60e2                	ld	ra,24(sp)
    800036d0:	6442                	ld	s0,16(sp)
    800036d2:	64a2                	ld	s1,8(sp)
    800036d4:	6105                	addi	sp,sp,32
    800036d6:	8082                	ret
    panic("bwrite");
    800036d8:	00005517          	auipc	a0,0x5
    800036dc:	fb050513          	addi	a0,a0,-80 # 80008688 <syscalls+0x100>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	e60080e7          	jalr	-416(ra) # 80000540 <panic>

00000000800036e8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036e8:	1101                	addi	sp,sp,-32
    800036ea:	ec06                	sd	ra,24(sp)
    800036ec:	e822                	sd	s0,16(sp)
    800036ee:	e426                	sd	s1,8(sp)
    800036f0:	e04a                	sd	s2,0(sp)
    800036f2:	1000                	addi	s0,sp,32
    800036f4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036f6:	01050913          	addi	s2,a0,16
    800036fa:	854a                	mv	a0,s2
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	42e080e7          	jalr	1070(ra) # 80004b2a <holdingsleep>
    80003704:	c92d                	beqz	a0,80003776 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003706:	854a                	mv	a0,s2
    80003708:	00001097          	auipc	ra,0x1
    8000370c:	3de080e7          	jalr	990(ra) # 80004ae6 <releasesleep>

  acquire(&bcache.lock);
    80003710:	00033517          	auipc	a0,0x33
    80003714:	44050513          	addi	a0,a0,1088 # 80036b50 <bcache>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	6da080e7          	jalr	1754(ra) # 80000df2 <acquire>
  b->refcnt--;
    80003720:	40bc                	lw	a5,64(s1)
    80003722:	37fd                	addiw	a5,a5,-1
    80003724:	0007871b          	sext.w	a4,a5
    80003728:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000372a:	eb05                	bnez	a4,8000375a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000372c:	68bc                	ld	a5,80(s1)
    8000372e:	64b8                	ld	a4,72(s1)
    80003730:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003732:	64bc                	ld	a5,72(s1)
    80003734:	68b8                	ld	a4,80(s1)
    80003736:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003738:	0003b797          	auipc	a5,0x3b
    8000373c:	41878793          	addi	a5,a5,1048 # 8003eb50 <bcache+0x8000>
    80003740:	2b87b703          	ld	a4,696(a5)
    80003744:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003746:	0003b717          	auipc	a4,0x3b
    8000374a:	67270713          	addi	a4,a4,1650 # 8003edb8 <bcache+0x8268>
    8000374e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003750:	2b87b703          	ld	a4,696(a5)
    80003754:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003756:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000375a:	00033517          	auipc	a0,0x33
    8000375e:	3f650513          	addi	a0,a0,1014 # 80036b50 <bcache>
    80003762:	ffffd097          	auipc	ra,0xffffd
    80003766:	744080e7          	jalr	1860(ra) # 80000ea6 <release>
}
    8000376a:	60e2                	ld	ra,24(sp)
    8000376c:	6442                	ld	s0,16(sp)
    8000376e:	64a2                	ld	s1,8(sp)
    80003770:	6902                	ld	s2,0(sp)
    80003772:	6105                	addi	sp,sp,32
    80003774:	8082                	ret
    panic("brelse");
    80003776:	00005517          	auipc	a0,0x5
    8000377a:	f1a50513          	addi	a0,a0,-230 # 80008690 <syscalls+0x108>
    8000377e:	ffffd097          	auipc	ra,0xffffd
    80003782:	dc2080e7          	jalr	-574(ra) # 80000540 <panic>

0000000080003786 <bpin>:

void
bpin(struct buf *b) {
    80003786:	1101                	addi	sp,sp,-32
    80003788:	ec06                	sd	ra,24(sp)
    8000378a:	e822                	sd	s0,16(sp)
    8000378c:	e426                	sd	s1,8(sp)
    8000378e:	1000                	addi	s0,sp,32
    80003790:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003792:	00033517          	auipc	a0,0x33
    80003796:	3be50513          	addi	a0,a0,958 # 80036b50 <bcache>
    8000379a:	ffffd097          	auipc	ra,0xffffd
    8000379e:	658080e7          	jalr	1624(ra) # 80000df2 <acquire>
  b->refcnt++;
    800037a2:	40bc                	lw	a5,64(s1)
    800037a4:	2785                	addiw	a5,a5,1
    800037a6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037a8:	00033517          	auipc	a0,0x33
    800037ac:	3a850513          	addi	a0,a0,936 # 80036b50 <bcache>
    800037b0:	ffffd097          	auipc	ra,0xffffd
    800037b4:	6f6080e7          	jalr	1782(ra) # 80000ea6 <release>
}
    800037b8:	60e2                	ld	ra,24(sp)
    800037ba:	6442                	ld	s0,16(sp)
    800037bc:	64a2                	ld	s1,8(sp)
    800037be:	6105                	addi	sp,sp,32
    800037c0:	8082                	ret

00000000800037c2 <bunpin>:

void
bunpin(struct buf *b) {
    800037c2:	1101                	addi	sp,sp,-32
    800037c4:	ec06                	sd	ra,24(sp)
    800037c6:	e822                	sd	s0,16(sp)
    800037c8:	e426                	sd	s1,8(sp)
    800037ca:	1000                	addi	s0,sp,32
    800037cc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037ce:	00033517          	auipc	a0,0x33
    800037d2:	38250513          	addi	a0,a0,898 # 80036b50 <bcache>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	61c080e7          	jalr	1564(ra) # 80000df2 <acquire>
  b->refcnt--;
    800037de:	40bc                	lw	a5,64(s1)
    800037e0:	37fd                	addiw	a5,a5,-1
    800037e2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037e4:	00033517          	auipc	a0,0x33
    800037e8:	36c50513          	addi	a0,a0,876 # 80036b50 <bcache>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	6ba080e7          	jalr	1722(ra) # 80000ea6 <release>
}
    800037f4:	60e2                	ld	ra,24(sp)
    800037f6:	6442                	ld	s0,16(sp)
    800037f8:	64a2                	ld	s1,8(sp)
    800037fa:	6105                	addi	sp,sp,32
    800037fc:	8082                	ret

00000000800037fe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037fe:	1101                	addi	sp,sp,-32
    80003800:	ec06                	sd	ra,24(sp)
    80003802:	e822                	sd	s0,16(sp)
    80003804:	e426                	sd	s1,8(sp)
    80003806:	e04a                	sd	s2,0(sp)
    80003808:	1000                	addi	s0,sp,32
    8000380a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000380c:	00d5d59b          	srliw	a1,a1,0xd
    80003810:	0003c797          	auipc	a5,0x3c
    80003814:	a1c7a783          	lw	a5,-1508(a5) # 8003f22c <sb+0x1c>
    80003818:	9dbd                	addw	a1,a1,a5
    8000381a:	00000097          	auipc	ra,0x0
    8000381e:	d9e080e7          	jalr	-610(ra) # 800035b8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003822:	0074f713          	andi	a4,s1,7
    80003826:	4785                	li	a5,1
    80003828:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000382c:	14ce                	slli	s1,s1,0x33
    8000382e:	90d9                	srli	s1,s1,0x36
    80003830:	00950733          	add	a4,a0,s1
    80003834:	05874703          	lbu	a4,88(a4)
    80003838:	00e7f6b3          	and	a3,a5,a4
    8000383c:	c69d                	beqz	a3,8000386a <bfree+0x6c>
    8000383e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003840:	94aa                	add	s1,s1,a0
    80003842:	fff7c793          	not	a5,a5
    80003846:	8f7d                	and	a4,a4,a5
    80003848:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000384c:	00001097          	auipc	ra,0x1
    80003850:	126080e7          	jalr	294(ra) # 80004972 <log_write>
  brelse(bp);
    80003854:	854a                	mv	a0,s2
    80003856:	00000097          	auipc	ra,0x0
    8000385a:	e92080e7          	jalr	-366(ra) # 800036e8 <brelse>
}
    8000385e:	60e2                	ld	ra,24(sp)
    80003860:	6442                	ld	s0,16(sp)
    80003862:	64a2                	ld	s1,8(sp)
    80003864:	6902                	ld	s2,0(sp)
    80003866:	6105                	addi	sp,sp,32
    80003868:	8082                	ret
    panic("freeing free block");
    8000386a:	00005517          	auipc	a0,0x5
    8000386e:	e2e50513          	addi	a0,a0,-466 # 80008698 <syscalls+0x110>
    80003872:	ffffd097          	auipc	ra,0xffffd
    80003876:	cce080e7          	jalr	-818(ra) # 80000540 <panic>

000000008000387a <balloc>:
{
    8000387a:	711d                	addi	sp,sp,-96
    8000387c:	ec86                	sd	ra,88(sp)
    8000387e:	e8a2                	sd	s0,80(sp)
    80003880:	e4a6                	sd	s1,72(sp)
    80003882:	e0ca                	sd	s2,64(sp)
    80003884:	fc4e                	sd	s3,56(sp)
    80003886:	f852                	sd	s4,48(sp)
    80003888:	f456                	sd	s5,40(sp)
    8000388a:	f05a                	sd	s6,32(sp)
    8000388c:	ec5e                	sd	s7,24(sp)
    8000388e:	e862                	sd	s8,16(sp)
    80003890:	e466                	sd	s9,8(sp)
    80003892:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003894:	0003c797          	auipc	a5,0x3c
    80003898:	9807a783          	lw	a5,-1664(a5) # 8003f214 <sb+0x4>
    8000389c:	cff5                	beqz	a5,80003998 <balloc+0x11e>
    8000389e:	8baa                	mv	s7,a0
    800038a0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038a2:	0003cb17          	auipc	s6,0x3c
    800038a6:	96eb0b13          	addi	s6,s6,-1682 # 8003f210 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038aa:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038ac:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038ae:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038b0:	6c89                	lui	s9,0x2
    800038b2:	a061                	j	8000393a <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038b4:	97ca                	add	a5,a5,s2
    800038b6:	8e55                	or	a2,a2,a3
    800038b8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800038bc:	854a                	mv	a0,s2
    800038be:	00001097          	auipc	ra,0x1
    800038c2:	0b4080e7          	jalr	180(ra) # 80004972 <log_write>
        brelse(bp);
    800038c6:	854a                	mv	a0,s2
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	e20080e7          	jalr	-480(ra) # 800036e8 <brelse>
  bp = bread(dev, bno);
    800038d0:	85a6                	mv	a1,s1
    800038d2:	855e                	mv	a0,s7
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	ce4080e7          	jalr	-796(ra) # 800035b8 <bread>
    800038dc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038de:	40000613          	li	a2,1024
    800038e2:	4581                	li	a1,0
    800038e4:	05850513          	addi	a0,a0,88
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	606080e7          	jalr	1542(ra) # 80000eee <memset>
  log_write(bp);
    800038f0:	854a                	mv	a0,s2
    800038f2:	00001097          	auipc	ra,0x1
    800038f6:	080080e7          	jalr	128(ra) # 80004972 <log_write>
  brelse(bp);
    800038fa:	854a                	mv	a0,s2
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	dec080e7          	jalr	-532(ra) # 800036e8 <brelse>
}
    80003904:	8526                	mv	a0,s1
    80003906:	60e6                	ld	ra,88(sp)
    80003908:	6446                	ld	s0,80(sp)
    8000390a:	64a6                	ld	s1,72(sp)
    8000390c:	6906                	ld	s2,64(sp)
    8000390e:	79e2                	ld	s3,56(sp)
    80003910:	7a42                	ld	s4,48(sp)
    80003912:	7aa2                	ld	s5,40(sp)
    80003914:	7b02                	ld	s6,32(sp)
    80003916:	6be2                	ld	s7,24(sp)
    80003918:	6c42                	ld	s8,16(sp)
    8000391a:	6ca2                	ld	s9,8(sp)
    8000391c:	6125                	addi	sp,sp,96
    8000391e:	8082                	ret
    brelse(bp);
    80003920:	854a                	mv	a0,s2
    80003922:	00000097          	auipc	ra,0x0
    80003926:	dc6080e7          	jalr	-570(ra) # 800036e8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000392a:	015c87bb          	addw	a5,s9,s5
    8000392e:	00078a9b          	sext.w	s5,a5
    80003932:	004b2703          	lw	a4,4(s6)
    80003936:	06eaf163          	bgeu	s5,a4,80003998 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000393a:	41fad79b          	sraiw	a5,s5,0x1f
    8000393e:	0137d79b          	srliw	a5,a5,0x13
    80003942:	015787bb          	addw	a5,a5,s5
    80003946:	40d7d79b          	sraiw	a5,a5,0xd
    8000394a:	01cb2583          	lw	a1,28(s6)
    8000394e:	9dbd                	addw	a1,a1,a5
    80003950:	855e                	mv	a0,s7
    80003952:	00000097          	auipc	ra,0x0
    80003956:	c66080e7          	jalr	-922(ra) # 800035b8 <bread>
    8000395a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000395c:	004b2503          	lw	a0,4(s6)
    80003960:	000a849b          	sext.w	s1,s5
    80003964:	8762                	mv	a4,s8
    80003966:	faa4fde3          	bgeu	s1,a0,80003920 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000396a:	00777693          	andi	a3,a4,7
    8000396e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003972:	41f7579b          	sraiw	a5,a4,0x1f
    80003976:	01d7d79b          	srliw	a5,a5,0x1d
    8000397a:	9fb9                	addw	a5,a5,a4
    8000397c:	4037d79b          	sraiw	a5,a5,0x3
    80003980:	00f90633          	add	a2,s2,a5
    80003984:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003988:	00c6f5b3          	and	a1,a3,a2
    8000398c:	d585                	beqz	a1,800038b4 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000398e:	2705                	addiw	a4,a4,1
    80003990:	2485                	addiw	s1,s1,1
    80003992:	fd471ae3          	bne	a4,s4,80003966 <balloc+0xec>
    80003996:	b769                	j	80003920 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003998:	00005517          	auipc	a0,0x5
    8000399c:	d1850513          	addi	a0,a0,-744 # 800086b0 <syscalls+0x128>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	bfc080e7          	jalr	-1028(ra) # 8000059c <printf>
  return 0;
    800039a8:	4481                	li	s1,0
    800039aa:	bfa9                	j	80003904 <balloc+0x8a>

00000000800039ac <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800039ac:	7179                	addi	sp,sp,-48
    800039ae:	f406                	sd	ra,40(sp)
    800039b0:	f022                	sd	s0,32(sp)
    800039b2:	ec26                	sd	s1,24(sp)
    800039b4:	e84a                	sd	s2,16(sp)
    800039b6:	e44e                	sd	s3,8(sp)
    800039b8:	e052                	sd	s4,0(sp)
    800039ba:	1800                	addi	s0,sp,48
    800039bc:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039be:	47ad                	li	a5,11
    800039c0:	02b7e863          	bltu	a5,a1,800039f0 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800039c4:	02059793          	slli	a5,a1,0x20
    800039c8:	01e7d593          	srli	a1,a5,0x1e
    800039cc:	00b504b3          	add	s1,a0,a1
    800039d0:	0504a903          	lw	s2,80(s1)
    800039d4:	06091e63          	bnez	s2,80003a50 <bmap+0xa4>
      addr = balloc(ip->dev);
    800039d8:	4108                	lw	a0,0(a0)
    800039da:	00000097          	auipc	ra,0x0
    800039de:	ea0080e7          	jalr	-352(ra) # 8000387a <balloc>
    800039e2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039e6:	06090563          	beqz	s2,80003a50 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800039ea:	0524a823          	sw	s2,80(s1)
    800039ee:	a08d                	j	80003a50 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039f0:	ff45849b          	addiw	s1,a1,-12
    800039f4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039f8:	0ff00793          	li	a5,255
    800039fc:	08e7e563          	bltu	a5,a4,80003a86 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003a00:	08052903          	lw	s2,128(a0)
    80003a04:	00091d63          	bnez	s2,80003a1e <bmap+0x72>
      addr = balloc(ip->dev);
    80003a08:	4108                	lw	a0,0(a0)
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	e70080e7          	jalr	-400(ra) # 8000387a <balloc>
    80003a12:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a16:	02090d63          	beqz	s2,80003a50 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a1a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003a1e:	85ca                	mv	a1,s2
    80003a20:	0009a503          	lw	a0,0(s3)
    80003a24:	00000097          	auipc	ra,0x0
    80003a28:	b94080e7          	jalr	-1132(ra) # 800035b8 <bread>
    80003a2c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a2e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a32:	02049713          	slli	a4,s1,0x20
    80003a36:	01e75593          	srli	a1,a4,0x1e
    80003a3a:	00b784b3          	add	s1,a5,a1
    80003a3e:	0004a903          	lw	s2,0(s1)
    80003a42:	02090063          	beqz	s2,80003a62 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a46:	8552                	mv	a0,s4
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	ca0080e7          	jalr	-864(ra) # 800036e8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a50:	854a                	mv	a0,s2
    80003a52:	70a2                	ld	ra,40(sp)
    80003a54:	7402                	ld	s0,32(sp)
    80003a56:	64e2                	ld	s1,24(sp)
    80003a58:	6942                	ld	s2,16(sp)
    80003a5a:	69a2                	ld	s3,8(sp)
    80003a5c:	6a02                	ld	s4,0(sp)
    80003a5e:	6145                	addi	sp,sp,48
    80003a60:	8082                	ret
      addr = balloc(ip->dev);
    80003a62:	0009a503          	lw	a0,0(s3)
    80003a66:	00000097          	auipc	ra,0x0
    80003a6a:	e14080e7          	jalr	-492(ra) # 8000387a <balloc>
    80003a6e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a72:	fc090ae3          	beqz	s2,80003a46 <bmap+0x9a>
        a[bn] = addr;
    80003a76:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a7a:	8552                	mv	a0,s4
    80003a7c:	00001097          	auipc	ra,0x1
    80003a80:	ef6080e7          	jalr	-266(ra) # 80004972 <log_write>
    80003a84:	b7c9                	j	80003a46 <bmap+0x9a>
  panic("bmap: out of range");
    80003a86:	00005517          	auipc	a0,0x5
    80003a8a:	c4250513          	addi	a0,a0,-958 # 800086c8 <syscalls+0x140>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	ab2080e7          	jalr	-1358(ra) # 80000540 <panic>

0000000080003a96 <iget>:
{
    80003a96:	7179                	addi	sp,sp,-48
    80003a98:	f406                	sd	ra,40(sp)
    80003a9a:	f022                	sd	s0,32(sp)
    80003a9c:	ec26                	sd	s1,24(sp)
    80003a9e:	e84a                	sd	s2,16(sp)
    80003aa0:	e44e                	sd	s3,8(sp)
    80003aa2:	e052                	sd	s4,0(sp)
    80003aa4:	1800                	addi	s0,sp,48
    80003aa6:	89aa                	mv	s3,a0
    80003aa8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003aaa:	0003b517          	auipc	a0,0x3b
    80003aae:	78650513          	addi	a0,a0,1926 # 8003f230 <itable>
    80003ab2:	ffffd097          	auipc	ra,0xffffd
    80003ab6:	340080e7          	jalr	832(ra) # 80000df2 <acquire>
  empty = 0;
    80003aba:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003abc:	0003b497          	auipc	s1,0x3b
    80003ac0:	78c48493          	addi	s1,s1,1932 # 8003f248 <itable+0x18>
    80003ac4:	0003d697          	auipc	a3,0x3d
    80003ac8:	21468693          	addi	a3,a3,532 # 80040cd8 <log>
    80003acc:	a039                	j	80003ada <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ace:	02090b63          	beqz	s2,80003b04 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ad2:	08848493          	addi	s1,s1,136
    80003ad6:	02d48a63          	beq	s1,a3,80003b0a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ada:	449c                	lw	a5,8(s1)
    80003adc:	fef059e3          	blez	a5,80003ace <iget+0x38>
    80003ae0:	4098                	lw	a4,0(s1)
    80003ae2:	ff3716e3          	bne	a4,s3,80003ace <iget+0x38>
    80003ae6:	40d8                	lw	a4,4(s1)
    80003ae8:	ff4713e3          	bne	a4,s4,80003ace <iget+0x38>
      ip->ref++;
    80003aec:	2785                	addiw	a5,a5,1
    80003aee:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003af0:	0003b517          	auipc	a0,0x3b
    80003af4:	74050513          	addi	a0,a0,1856 # 8003f230 <itable>
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	3ae080e7          	jalr	942(ra) # 80000ea6 <release>
      return ip;
    80003b00:	8926                	mv	s2,s1
    80003b02:	a03d                	j	80003b30 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b04:	f7f9                	bnez	a5,80003ad2 <iget+0x3c>
    80003b06:	8926                	mv	s2,s1
    80003b08:	b7e9                	j	80003ad2 <iget+0x3c>
  if(empty == 0)
    80003b0a:	02090c63          	beqz	s2,80003b42 <iget+0xac>
  ip->dev = dev;
    80003b0e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b12:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b16:	4785                	li	a5,1
    80003b18:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b1c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b20:	0003b517          	auipc	a0,0x3b
    80003b24:	71050513          	addi	a0,a0,1808 # 8003f230 <itable>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	37e080e7          	jalr	894(ra) # 80000ea6 <release>
}
    80003b30:	854a                	mv	a0,s2
    80003b32:	70a2                	ld	ra,40(sp)
    80003b34:	7402                	ld	s0,32(sp)
    80003b36:	64e2                	ld	s1,24(sp)
    80003b38:	6942                	ld	s2,16(sp)
    80003b3a:	69a2                	ld	s3,8(sp)
    80003b3c:	6a02                	ld	s4,0(sp)
    80003b3e:	6145                	addi	sp,sp,48
    80003b40:	8082                	ret
    panic("iget: no inodes");
    80003b42:	00005517          	auipc	a0,0x5
    80003b46:	b9e50513          	addi	a0,a0,-1122 # 800086e0 <syscalls+0x158>
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	9f6080e7          	jalr	-1546(ra) # 80000540 <panic>

0000000080003b52 <fsinit>:
fsinit(int dev) {
    80003b52:	7179                	addi	sp,sp,-48
    80003b54:	f406                	sd	ra,40(sp)
    80003b56:	f022                	sd	s0,32(sp)
    80003b58:	ec26                	sd	s1,24(sp)
    80003b5a:	e84a                	sd	s2,16(sp)
    80003b5c:	e44e                	sd	s3,8(sp)
    80003b5e:	1800                	addi	s0,sp,48
    80003b60:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b62:	4585                	li	a1,1
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	a54080e7          	jalr	-1452(ra) # 800035b8 <bread>
    80003b6c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b6e:	0003b997          	auipc	s3,0x3b
    80003b72:	6a298993          	addi	s3,s3,1698 # 8003f210 <sb>
    80003b76:	02000613          	li	a2,32
    80003b7a:	05850593          	addi	a1,a0,88
    80003b7e:	854e                	mv	a0,s3
    80003b80:	ffffd097          	auipc	ra,0xffffd
    80003b84:	3ca080e7          	jalr	970(ra) # 80000f4a <memmove>
  brelse(bp);
    80003b88:	8526                	mv	a0,s1
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	b5e080e7          	jalr	-1186(ra) # 800036e8 <brelse>
  if(sb.magic != FSMAGIC)
    80003b92:	0009a703          	lw	a4,0(s3)
    80003b96:	102037b7          	lui	a5,0x10203
    80003b9a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b9e:	02f71263          	bne	a4,a5,80003bc2 <fsinit+0x70>
  initlog(dev, &sb);
    80003ba2:	0003b597          	auipc	a1,0x3b
    80003ba6:	66e58593          	addi	a1,a1,1646 # 8003f210 <sb>
    80003baa:	854a                	mv	a0,s2
    80003bac:	00001097          	auipc	ra,0x1
    80003bb0:	b4a080e7          	jalr	-1206(ra) # 800046f6 <initlog>
}
    80003bb4:	70a2                	ld	ra,40(sp)
    80003bb6:	7402                	ld	s0,32(sp)
    80003bb8:	64e2                	ld	s1,24(sp)
    80003bba:	6942                	ld	s2,16(sp)
    80003bbc:	69a2                	ld	s3,8(sp)
    80003bbe:	6145                	addi	sp,sp,48
    80003bc0:	8082                	ret
    panic("invalid file system");
    80003bc2:	00005517          	auipc	a0,0x5
    80003bc6:	b2e50513          	addi	a0,a0,-1234 # 800086f0 <syscalls+0x168>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	976080e7          	jalr	-1674(ra) # 80000540 <panic>

0000000080003bd2 <iinit>:
{
    80003bd2:	7179                	addi	sp,sp,-48
    80003bd4:	f406                	sd	ra,40(sp)
    80003bd6:	f022                	sd	s0,32(sp)
    80003bd8:	ec26                	sd	s1,24(sp)
    80003bda:	e84a                	sd	s2,16(sp)
    80003bdc:	e44e                	sd	s3,8(sp)
    80003bde:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003be0:	00005597          	auipc	a1,0x5
    80003be4:	b2858593          	addi	a1,a1,-1240 # 80008708 <syscalls+0x180>
    80003be8:	0003b517          	auipc	a0,0x3b
    80003bec:	64850513          	addi	a0,a0,1608 # 8003f230 <itable>
    80003bf0:	ffffd097          	auipc	ra,0xffffd
    80003bf4:	172080e7          	jalr	370(ra) # 80000d62 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bf8:	0003b497          	auipc	s1,0x3b
    80003bfc:	66048493          	addi	s1,s1,1632 # 8003f258 <itable+0x28>
    80003c00:	0003d997          	auipc	s3,0x3d
    80003c04:	0e898993          	addi	s3,s3,232 # 80040ce8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c08:	00005917          	auipc	s2,0x5
    80003c0c:	b0890913          	addi	s2,s2,-1272 # 80008710 <syscalls+0x188>
    80003c10:	85ca                	mv	a1,s2
    80003c12:	8526                	mv	a0,s1
    80003c14:	00001097          	auipc	ra,0x1
    80003c18:	e42080e7          	jalr	-446(ra) # 80004a56 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c1c:	08848493          	addi	s1,s1,136
    80003c20:	ff3498e3          	bne	s1,s3,80003c10 <iinit+0x3e>
}
    80003c24:	70a2                	ld	ra,40(sp)
    80003c26:	7402                	ld	s0,32(sp)
    80003c28:	64e2                	ld	s1,24(sp)
    80003c2a:	6942                	ld	s2,16(sp)
    80003c2c:	69a2                	ld	s3,8(sp)
    80003c2e:	6145                	addi	sp,sp,48
    80003c30:	8082                	ret

0000000080003c32 <ialloc>:
{
    80003c32:	715d                	addi	sp,sp,-80
    80003c34:	e486                	sd	ra,72(sp)
    80003c36:	e0a2                	sd	s0,64(sp)
    80003c38:	fc26                	sd	s1,56(sp)
    80003c3a:	f84a                	sd	s2,48(sp)
    80003c3c:	f44e                	sd	s3,40(sp)
    80003c3e:	f052                	sd	s4,32(sp)
    80003c40:	ec56                	sd	s5,24(sp)
    80003c42:	e85a                	sd	s6,16(sp)
    80003c44:	e45e                	sd	s7,8(sp)
    80003c46:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c48:	0003b717          	auipc	a4,0x3b
    80003c4c:	5d472703          	lw	a4,1492(a4) # 8003f21c <sb+0xc>
    80003c50:	4785                	li	a5,1
    80003c52:	04e7fa63          	bgeu	a5,a4,80003ca6 <ialloc+0x74>
    80003c56:	8aaa                	mv	s5,a0
    80003c58:	8bae                	mv	s7,a1
    80003c5a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c5c:	0003ba17          	auipc	s4,0x3b
    80003c60:	5b4a0a13          	addi	s4,s4,1460 # 8003f210 <sb>
    80003c64:	00048b1b          	sext.w	s6,s1
    80003c68:	0044d593          	srli	a1,s1,0x4
    80003c6c:	018a2783          	lw	a5,24(s4)
    80003c70:	9dbd                	addw	a1,a1,a5
    80003c72:	8556                	mv	a0,s5
    80003c74:	00000097          	auipc	ra,0x0
    80003c78:	944080e7          	jalr	-1724(ra) # 800035b8 <bread>
    80003c7c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c7e:	05850993          	addi	s3,a0,88
    80003c82:	00f4f793          	andi	a5,s1,15
    80003c86:	079a                	slli	a5,a5,0x6
    80003c88:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c8a:	00099783          	lh	a5,0(s3)
    80003c8e:	c3a1                	beqz	a5,80003cce <ialloc+0x9c>
    brelse(bp);
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	a58080e7          	jalr	-1448(ra) # 800036e8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c98:	0485                	addi	s1,s1,1
    80003c9a:	00ca2703          	lw	a4,12(s4)
    80003c9e:	0004879b          	sext.w	a5,s1
    80003ca2:	fce7e1e3          	bltu	a5,a4,80003c64 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ca6:	00005517          	auipc	a0,0x5
    80003caa:	a7250513          	addi	a0,a0,-1422 # 80008718 <syscalls+0x190>
    80003cae:	ffffd097          	auipc	ra,0xffffd
    80003cb2:	8ee080e7          	jalr	-1810(ra) # 8000059c <printf>
  return 0;
    80003cb6:	4501                	li	a0,0
}
    80003cb8:	60a6                	ld	ra,72(sp)
    80003cba:	6406                	ld	s0,64(sp)
    80003cbc:	74e2                	ld	s1,56(sp)
    80003cbe:	7942                	ld	s2,48(sp)
    80003cc0:	79a2                	ld	s3,40(sp)
    80003cc2:	7a02                	ld	s4,32(sp)
    80003cc4:	6ae2                	ld	s5,24(sp)
    80003cc6:	6b42                	ld	s6,16(sp)
    80003cc8:	6ba2                	ld	s7,8(sp)
    80003cca:	6161                	addi	sp,sp,80
    80003ccc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003cce:	04000613          	li	a2,64
    80003cd2:	4581                	li	a1,0
    80003cd4:	854e                	mv	a0,s3
    80003cd6:	ffffd097          	auipc	ra,0xffffd
    80003cda:	218080e7          	jalr	536(ra) # 80000eee <memset>
      dip->type = type;
    80003cde:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ce2:	854a                	mv	a0,s2
    80003ce4:	00001097          	auipc	ra,0x1
    80003ce8:	c8e080e7          	jalr	-882(ra) # 80004972 <log_write>
      brelse(bp);
    80003cec:	854a                	mv	a0,s2
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	9fa080e7          	jalr	-1542(ra) # 800036e8 <brelse>
      return iget(dev, inum);
    80003cf6:	85da                	mv	a1,s6
    80003cf8:	8556                	mv	a0,s5
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	d9c080e7          	jalr	-612(ra) # 80003a96 <iget>
    80003d02:	bf5d                	j	80003cb8 <ialloc+0x86>

0000000080003d04 <iupdate>:
{
    80003d04:	1101                	addi	sp,sp,-32
    80003d06:	ec06                	sd	ra,24(sp)
    80003d08:	e822                	sd	s0,16(sp)
    80003d0a:	e426                	sd	s1,8(sp)
    80003d0c:	e04a                	sd	s2,0(sp)
    80003d0e:	1000                	addi	s0,sp,32
    80003d10:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d12:	415c                	lw	a5,4(a0)
    80003d14:	0047d79b          	srliw	a5,a5,0x4
    80003d18:	0003b597          	auipc	a1,0x3b
    80003d1c:	5105a583          	lw	a1,1296(a1) # 8003f228 <sb+0x18>
    80003d20:	9dbd                	addw	a1,a1,a5
    80003d22:	4108                	lw	a0,0(a0)
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	894080e7          	jalr	-1900(ra) # 800035b8 <bread>
    80003d2c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d2e:	05850793          	addi	a5,a0,88
    80003d32:	40d8                	lw	a4,4(s1)
    80003d34:	8b3d                	andi	a4,a4,15
    80003d36:	071a                	slli	a4,a4,0x6
    80003d38:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d3a:	04449703          	lh	a4,68(s1)
    80003d3e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d42:	04649703          	lh	a4,70(s1)
    80003d46:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d4a:	04849703          	lh	a4,72(s1)
    80003d4e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d52:	04a49703          	lh	a4,74(s1)
    80003d56:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d5a:	44f8                	lw	a4,76(s1)
    80003d5c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d5e:	03400613          	li	a2,52
    80003d62:	05048593          	addi	a1,s1,80
    80003d66:	00c78513          	addi	a0,a5,12
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	1e0080e7          	jalr	480(ra) # 80000f4a <memmove>
  log_write(bp);
    80003d72:	854a                	mv	a0,s2
    80003d74:	00001097          	auipc	ra,0x1
    80003d78:	bfe080e7          	jalr	-1026(ra) # 80004972 <log_write>
  brelse(bp);
    80003d7c:	854a                	mv	a0,s2
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	96a080e7          	jalr	-1686(ra) # 800036e8 <brelse>
}
    80003d86:	60e2                	ld	ra,24(sp)
    80003d88:	6442                	ld	s0,16(sp)
    80003d8a:	64a2                	ld	s1,8(sp)
    80003d8c:	6902                	ld	s2,0(sp)
    80003d8e:	6105                	addi	sp,sp,32
    80003d90:	8082                	ret

0000000080003d92 <idup>:
{
    80003d92:	1101                	addi	sp,sp,-32
    80003d94:	ec06                	sd	ra,24(sp)
    80003d96:	e822                	sd	s0,16(sp)
    80003d98:	e426                	sd	s1,8(sp)
    80003d9a:	1000                	addi	s0,sp,32
    80003d9c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d9e:	0003b517          	auipc	a0,0x3b
    80003da2:	49250513          	addi	a0,a0,1170 # 8003f230 <itable>
    80003da6:	ffffd097          	auipc	ra,0xffffd
    80003daa:	04c080e7          	jalr	76(ra) # 80000df2 <acquire>
  ip->ref++;
    80003dae:	449c                	lw	a5,8(s1)
    80003db0:	2785                	addiw	a5,a5,1
    80003db2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003db4:	0003b517          	auipc	a0,0x3b
    80003db8:	47c50513          	addi	a0,a0,1148 # 8003f230 <itable>
    80003dbc:	ffffd097          	auipc	ra,0xffffd
    80003dc0:	0ea080e7          	jalr	234(ra) # 80000ea6 <release>
}
    80003dc4:	8526                	mv	a0,s1
    80003dc6:	60e2                	ld	ra,24(sp)
    80003dc8:	6442                	ld	s0,16(sp)
    80003dca:	64a2                	ld	s1,8(sp)
    80003dcc:	6105                	addi	sp,sp,32
    80003dce:	8082                	ret

0000000080003dd0 <ilock>:
{
    80003dd0:	1101                	addi	sp,sp,-32
    80003dd2:	ec06                	sd	ra,24(sp)
    80003dd4:	e822                	sd	s0,16(sp)
    80003dd6:	e426                	sd	s1,8(sp)
    80003dd8:	e04a                	sd	s2,0(sp)
    80003dda:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ddc:	c115                	beqz	a0,80003e00 <ilock+0x30>
    80003dde:	84aa                	mv	s1,a0
    80003de0:	451c                	lw	a5,8(a0)
    80003de2:	00f05f63          	blez	a5,80003e00 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003de6:	0541                	addi	a0,a0,16
    80003de8:	00001097          	auipc	ra,0x1
    80003dec:	ca8080e7          	jalr	-856(ra) # 80004a90 <acquiresleep>
  if(ip->valid == 0){
    80003df0:	40bc                	lw	a5,64(s1)
    80003df2:	cf99                	beqz	a5,80003e10 <ilock+0x40>
}
    80003df4:	60e2                	ld	ra,24(sp)
    80003df6:	6442                	ld	s0,16(sp)
    80003df8:	64a2                	ld	s1,8(sp)
    80003dfa:	6902                	ld	s2,0(sp)
    80003dfc:	6105                	addi	sp,sp,32
    80003dfe:	8082                	ret
    panic("ilock");
    80003e00:	00005517          	auipc	a0,0x5
    80003e04:	93050513          	addi	a0,a0,-1744 # 80008730 <syscalls+0x1a8>
    80003e08:	ffffc097          	auipc	ra,0xffffc
    80003e0c:	738080e7          	jalr	1848(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e10:	40dc                	lw	a5,4(s1)
    80003e12:	0047d79b          	srliw	a5,a5,0x4
    80003e16:	0003b597          	auipc	a1,0x3b
    80003e1a:	4125a583          	lw	a1,1042(a1) # 8003f228 <sb+0x18>
    80003e1e:	9dbd                	addw	a1,a1,a5
    80003e20:	4088                	lw	a0,0(s1)
    80003e22:	fffff097          	auipc	ra,0xfffff
    80003e26:	796080e7          	jalr	1942(ra) # 800035b8 <bread>
    80003e2a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e2c:	05850593          	addi	a1,a0,88
    80003e30:	40dc                	lw	a5,4(s1)
    80003e32:	8bbd                	andi	a5,a5,15
    80003e34:	079a                	slli	a5,a5,0x6
    80003e36:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e38:	00059783          	lh	a5,0(a1)
    80003e3c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e40:	00259783          	lh	a5,2(a1)
    80003e44:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e48:	00459783          	lh	a5,4(a1)
    80003e4c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e50:	00659783          	lh	a5,6(a1)
    80003e54:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e58:	459c                	lw	a5,8(a1)
    80003e5a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e5c:	03400613          	li	a2,52
    80003e60:	05b1                	addi	a1,a1,12
    80003e62:	05048513          	addi	a0,s1,80
    80003e66:	ffffd097          	auipc	ra,0xffffd
    80003e6a:	0e4080e7          	jalr	228(ra) # 80000f4a <memmove>
    brelse(bp);
    80003e6e:	854a                	mv	a0,s2
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	878080e7          	jalr	-1928(ra) # 800036e8 <brelse>
    ip->valid = 1;
    80003e78:	4785                	li	a5,1
    80003e7a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e7c:	04449783          	lh	a5,68(s1)
    80003e80:	fbb5                	bnez	a5,80003df4 <ilock+0x24>
      panic("ilock: no type");
    80003e82:	00005517          	auipc	a0,0x5
    80003e86:	8b650513          	addi	a0,a0,-1866 # 80008738 <syscalls+0x1b0>
    80003e8a:	ffffc097          	auipc	ra,0xffffc
    80003e8e:	6b6080e7          	jalr	1718(ra) # 80000540 <panic>

0000000080003e92 <iunlock>:
{
    80003e92:	1101                	addi	sp,sp,-32
    80003e94:	ec06                	sd	ra,24(sp)
    80003e96:	e822                	sd	s0,16(sp)
    80003e98:	e426                	sd	s1,8(sp)
    80003e9a:	e04a                	sd	s2,0(sp)
    80003e9c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e9e:	c905                	beqz	a0,80003ece <iunlock+0x3c>
    80003ea0:	84aa                	mv	s1,a0
    80003ea2:	01050913          	addi	s2,a0,16
    80003ea6:	854a                	mv	a0,s2
    80003ea8:	00001097          	auipc	ra,0x1
    80003eac:	c82080e7          	jalr	-894(ra) # 80004b2a <holdingsleep>
    80003eb0:	cd19                	beqz	a0,80003ece <iunlock+0x3c>
    80003eb2:	449c                	lw	a5,8(s1)
    80003eb4:	00f05d63          	blez	a5,80003ece <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003eb8:	854a                	mv	a0,s2
    80003eba:	00001097          	auipc	ra,0x1
    80003ebe:	c2c080e7          	jalr	-980(ra) # 80004ae6 <releasesleep>
}
    80003ec2:	60e2                	ld	ra,24(sp)
    80003ec4:	6442                	ld	s0,16(sp)
    80003ec6:	64a2                	ld	s1,8(sp)
    80003ec8:	6902                	ld	s2,0(sp)
    80003eca:	6105                	addi	sp,sp,32
    80003ecc:	8082                	ret
    panic("iunlock");
    80003ece:	00005517          	auipc	a0,0x5
    80003ed2:	87a50513          	addi	a0,a0,-1926 # 80008748 <syscalls+0x1c0>
    80003ed6:	ffffc097          	auipc	ra,0xffffc
    80003eda:	66a080e7          	jalr	1642(ra) # 80000540 <panic>

0000000080003ede <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ede:	7179                	addi	sp,sp,-48
    80003ee0:	f406                	sd	ra,40(sp)
    80003ee2:	f022                	sd	s0,32(sp)
    80003ee4:	ec26                	sd	s1,24(sp)
    80003ee6:	e84a                	sd	s2,16(sp)
    80003ee8:	e44e                	sd	s3,8(sp)
    80003eea:	e052                	sd	s4,0(sp)
    80003eec:	1800                	addi	s0,sp,48
    80003eee:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ef0:	05050493          	addi	s1,a0,80
    80003ef4:	08050913          	addi	s2,a0,128
    80003ef8:	a021                	j	80003f00 <itrunc+0x22>
    80003efa:	0491                	addi	s1,s1,4
    80003efc:	01248d63          	beq	s1,s2,80003f16 <itrunc+0x38>
    if(ip->addrs[i]){
    80003f00:	408c                	lw	a1,0(s1)
    80003f02:	dde5                	beqz	a1,80003efa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003f04:	0009a503          	lw	a0,0(s3)
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	8f6080e7          	jalr	-1802(ra) # 800037fe <bfree>
      ip->addrs[i] = 0;
    80003f10:	0004a023          	sw	zero,0(s1)
    80003f14:	b7dd                	j	80003efa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f16:	0809a583          	lw	a1,128(s3)
    80003f1a:	e185                	bnez	a1,80003f3a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f1c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f20:	854e                	mv	a0,s3
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	de2080e7          	jalr	-542(ra) # 80003d04 <iupdate>
}
    80003f2a:	70a2                	ld	ra,40(sp)
    80003f2c:	7402                	ld	s0,32(sp)
    80003f2e:	64e2                	ld	s1,24(sp)
    80003f30:	6942                	ld	s2,16(sp)
    80003f32:	69a2                	ld	s3,8(sp)
    80003f34:	6a02                	ld	s4,0(sp)
    80003f36:	6145                	addi	sp,sp,48
    80003f38:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f3a:	0009a503          	lw	a0,0(s3)
    80003f3e:	fffff097          	auipc	ra,0xfffff
    80003f42:	67a080e7          	jalr	1658(ra) # 800035b8 <bread>
    80003f46:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f48:	05850493          	addi	s1,a0,88
    80003f4c:	45850913          	addi	s2,a0,1112
    80003f50:	a021                	j	80003f58 <itrunc+0x7a>
    80003f52:	0491                	addi	s1,s1,4
    80003f54:	01248b63          	beq	s1,s2,80003f6a <itrunc+0x8c>
      if(a[j])
    80003f58:	408c                	lw	a1,0(s1)
    80003f5a:	dde5                	beqz	a1,80003f52 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003f5c:	0009a503          	lw	a0,0(s3)
    80003f60:	00000097          	auipc	ra,0x0
    80003f64:	89e080e7          	jalr	-1890(ra) # 800037fe <bfree>
    80003f68:	b7ed                	j	80003f52 <itrunc+0x74>
    brelse(bp);
    80003f6a:	8552                	mv	a0,s4
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	77c080e7          	jalr	1916(ra) # 800036e8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f74:	0809a583          	lw	a1,128(s3)
    80003f78:	0009a503          	lw	a0,0(s3)
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	882080e7          	jalr	-1918(ra) # 800037fe <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f84:	0809a023          	sw	zero,128(s3)
    80003f88:	bf51                	j	80003f1c <itrunc+0x3e>

0000000080003f8a <iput>:
{
    80003f8a:	1101                	addi	sp,sp,-32
    80003f8c:	ec06                	sd	ra,24(sp)
    80003f8e:	e822                	sd	s0,16(sp)
    80003f90:	e426                	sd	s1,8(sp)
    80003f92:	e04a                	sd	s2,0(sp)
    80003f94:	1000                	addi	s0,sp,32
    80003f96:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f98:	0003b517          	auipc	a0,0x3b
    80003f9c:	29850513          	addi	a0,a0,664 # 8003f230 <itable>
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	e52080e7          	jalr	-430(ra) # 80000df2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fa8:	4498                	lw	a4,8(s1)
    80003faa:	4785                	li	a5,1
    80003fac:	02f70363          	beq	a4,a5,80003fd2 <iput+0x48>
  ip->ref--;
    80003fb0:	449c                	lw	a5,8(s1)
    80003fb2:	37fd                	addiw	a5,a5,-1
    80003fb4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fb6:	0003b517          	auipc	a0,0x3b
    80003fba:	27a50513          	addi	a0,a0,634 # 8003f230 <itable>
    80003fbe:	ffffd097          	auipc	ra,0xffffd
    80003fc2:	ee8080e7          	jalr	-280(ra) # 80000ea6 <release>
}
    80003fc6:	60e2                	ld	ra,24(sp)
    80003fc8:	6442                	ld	s0,16(sp)
    80003fca:	64a2                	ld	s1,8(sp)
    80003fcc:	6902                	ld	s2,0(sp)
    80003fce:	6105                	addi	sp,sp,32
    80003fd0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fd2:	40bc                	lw	a5,64(s1)
    80003fd4:	dff1                	beqz	a5,80003fb0 <iput+0x26>
    80003fd6:	04a49783          	lh	a5,74(s1)
    80003fda:	fbf9                	bnez	a5,80003fb0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003fdc:	01048913          	addi	s2,s1,16
    80003fe0:	854a                	mv	a0,s2
    80003fe2:	00001097          	auipc	ra,0x1
    80003fe6:	aae080e7          	jalr	-1362(ra) # 80004a90 <acquiresleep>
    release(&itable.lock);
    80003fea:	0003b517          	auipc	a0,0x3b
    80003fee:	24650513          	addi	a0,a0,582 # 8003f230 <itable>
    80003ff2:	ffffd097          	auipc	ra,0xffffd
    80003ff6:	eb4080e7          	jalr	-332(ra) # 80000ea6 <release>
    itrunc(ip);
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	ee2080e7          	jalr	-286(ra) # 80003ede <itrunc>
    ip->type = 0;
    80004004:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004008:	8526                	mv	a0,s1
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	cfa080e7          	jalr	-774(ra) # 80003d04 <iupdate>
    ip->valid = 0;
    80004012:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004016:	854a                	mv	a0,s2
    80004018:	00001097          	auipc	ra,0x1
    8000401c:	ace080e7          	jalr	-1330(ra) # 80004ae6 <releasesleep>
    acquire(&itable.lock);
    80004020:	0003b517          	auipc	a0,0x3b
    80004024:	21050513          	addi	a0,a0,528 # 8003f230 <itable>
    80004028:	ffffd097          	auipc	ra,0xffffd
    8000402c:	dca080e7          	jalr	-566(ra) # 80000df2 <acquire>
    80004030:	b741                	j	80003fb0 <iput+0x26>

0000000080004032 <iunlockput>:
{
    80004032:	1101                	addi	sp,sp,-32
    80004034:	ec06                	sd	ra,24(sp)
    80004036:	e822                	sd	s0,16(sp)
    80004038:	e426                	sd	s1,8(sp)
    8000403a:	1000                	addi	s0,sp,32
    8000403c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	e54080e7          	jalr	-428(ra) # 80003e92 <iunlock>
  iput(ip);
    80004046:	8526                	mv	a0,s1
    80004048:	00000097          	auipc	ra,0x0
    8000404c:	f42080e7          	jalr	-190(ra) # 80003f8a <iput>
}
    80004050:	60e2                	ld	ra,24(sp)
    80004052:	6442                	ld	s0,16(sp)
    80004054:	64a2                	ld	s1,8(sp)
    80004056:	6105                	addi	sp,sp,32
    80004058:	8082                	ret

000000008000405a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000405a:	1141                	addi	sp,sp,-16
    8000405c:	e422                	sd	s0,8(sp)
    8000405e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004060:	411c                	lw	a5,0(a0)
    80004062:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004064:	415c                	lw	a5,4(a0)
    80004066:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004068:	04451783          	lh	a5,68(a0)
    8000406c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004070:	04a51783          	lh	a5,74(a0)
    80004074:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004078:	04c56783          	lwu	a5,76(a0)
    8000407c:	e99c                	sd	a5,16(a1)
}
    8000407e:	6422                	ld	s0,8(sp)
    80004080:	0141                	addi	sp,sp,16
    80004082:	8082                	ret

0000000080004084 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004084:	457c                	lw	a5,76(a0)
    80004086:	0ed7e963          	bltu	a5,a3,80004178 <readi+0xf4>
{
    8000408a:	7159                	addi	sp,sp,-112
    8000408c:	f486                	sd	ra,104(sp)
    8000408e:	f0a2                	sd	s0,96(sp)
    80004090:	eca6                	sd	s1,88(sp)
    80004092:	e8ca                	sd	s2,80(sp)
    80004094:	e4ce                	sd	s3,72(sp)
    80004096:	e0d2                	sd	s4,64(sp)
    80004098:	fc56                	sd	s5,56(sp)
    8000409a:	f85a                	sd	s6,48(sp)
    8000409c:	f45e                	sd	s7,40(sp)
    8000409e:	f062                	sd	s8,32(sp)
    800040a0:	ec66                	sd	s9,24(sp)
    800040a2:	e86a                	sd	s10,16(sp)
    800040a4:	e46e                	sd	s11,8(sp)
    800040a6:	1880                	addi	s0,sp,112
    800040a8:	8b2a                	mv	s6,a0
    800040aa:	8bae                	mv	s7,a1
    800040ac:	8a32                	mv	s4,a2
    800040ae:	84b6                	mv	s1,a3
    800040b0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800040b2:	9f35                	addw	a4,a4,a3
    return 0;
    800040b4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800040b6:	0ad76063          	bltu	a4,a3,80004156 <readi+0xd2>
  if(off + n > ip->size)
    800040ba:	00e7f463          	bgeu	a5,a4,800040c2 <readi+0x3e>
    n = ip->size - off;
    800040be:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040c2:	0a0a8963          	beqz	s5,80004174 <readi+0xf0>
    800040c6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040cc:	5c7d                	li	s8,-1
    800040ce:	a82d                	j	80004108 <readi+0x84>
    800040d0:	020d1d93          	slli	s11,s10,0x20
    800040d4:	020ddd93          	srli	s11,s11,0x20
    800040d8:	05890613          	addi	a2,s2,88
    800040dc:	86ee                	mv	a3,s11
    800040de:	963a                	add	a2,a2,a4
    800040e0:	85d2                	mv	a1,s4
    800040e2:	855e                	mv	a0,s7
    800040e4:	ffffe097          	auipc	ra,0xffffe
    800040e8:	7d2080e7          	jalr	2002(ra) # 800028b6 <either_copyout>
    800040ec:	05850d63          	beq	a0,s8,80004146 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040f0:	854a                	mv	a0,s2
    800040f2:	fffff097          	auipc	ra,0xfffff
    800040f6:	5f6080e7          	jalr	1526(ra) # 800036e8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040fa:	013d09bb          	addw	s3,s10,s3
    800040fe:	009d04bb          	addw	s1,s10,s1
    80004102:	9a6e                	add	s4,s4,s11
    80004104:	0559f763          	bgeu	s3,s5,80004152 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004108:	00a4d59b          	srliw	a1,s1,0xa
    8000410c:	855a                	mv	a0,s6
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	89e080e7          	jalr	-1890(ra) # 800039ac <bmap>
    80004116:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000411a:	cd85                	beqz	a1,80004152 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000411c:	000b2503          	lw	a0,0(s6)
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	498080e7          	jalr	1176(ra) # 800035b8 <bread>
    80004128:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000412a:	3ff4f713          	andi	a4,s1,1023
    8000412e:	40ec87bb          	subw	a5,s9,a4
    80004132:	413a86bb          	subw	a3,s5,s3
    80004136:	8d3e                	mv	s10,a5
    80004138:	2781                	sext.w	a5,a5
    8000413a:	0006861b          	sext.w	a2,a3
    8000413e:	f8f679e3          	bgeu	a2,a5,800040d0 <readi+0x4c>
    80004142:	8d36                	mv	s10,a3
    80004144:	b771                	j	800040d0 <readi+0x4c>
      brelse(bp);
    80004146:	854a                	mv	a0,s2
    80004148:	fffff097          	auipc	ra,0xfffff
    8000414c:	5a0080e7          	jalr	1440(ra) # 800036e8 <brelse>
      tot = -1;
    80004150:	59fd                	li	s3,-1
  }
  return tot;
    80004152:	0009851b          	sext.w	a0,s3
}
    80004156:	70a6                	ld	ra,104(sp)
    80004158:	7406                	ld	s0,96(sp)
    8000415a:	64e6                	ld	s1,88(sp)
    8000415c:	6946                	ld	s2,80(sp)
    8000415e:	69a6                	ld	s3,72(sp)
    80004160:	6a06                	ld	s4,64(sp)
    80004162:	7ae2                	ld	s5,56(sp)
    80004164:	7b42                	ld	s6,48(sp)
    80004166:	7ba2                	ld	s7,40(sp)
    80004168:	7c02                	ld	s8,32(sp)
    8000416a:	6ce2                	ld	s9,24(sp)
    8000416c:	6d42                	ld	s10,16(sp)
    8000416e:	6da2                	ld	s11,8(sp)
    80004170:	6165                	addi	sp,sp,112
    80004172:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004174:	89d6                	mv	s3,s5
    80004176:	bff1                	j	80004152 <readi+0xce>
    return 0;
    80004178:	4501                	li	a0,0
}
    8000417a:	8082                	ret

000000008000417c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000417c:	457c                	lw	a5,76(a0)
    8000417e:	10d7e863          	bltu	a5,a3,8000428e <writei+0x112>
{
    80004182:	7159                	addi	sp,sp,-112
    80004184:	f486                	sd	ra,104(sp)
    80004186:	f0a2                	sd	s0,96(sp)
    80004188:	eca6                	sd	s1,88(sp)
    8000418a:	e8ca                	sd	s2,80(sp)
    8000418c:	e4ce                	sd	s3,72(sp)
    8000418e:	e0d2                	sd	s4,64(sp)
    80004190:	fc56                	sd	s5,56(sp)
    80004192:	f85a                	sd	s6,48(sp)
    80004194:	f45e                	sd	s7,40(sp)
    80004196:	f062                	sd	s8,32(sp)
    80004198:	ec66                	sd	s9,24(sp)
    8000419a:	e86a                	sd	s10,16(sp)
    8000419c:	e46e                	sd	s11,8(sp)
    8000419e:	1880                	addi	s0,sp,112
    800041a0:	8aaa                	mv	s5,a0
    800041a2:	8bae                	mv	s7,a1
    800041a4:	8a32                	mv	s4,a2
    800041a6:	8936                	mv	s2,a3
    800041a8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800041aa:	00e687bb          	addw	a5,a3,a4
    800041ae:	0ed7e263          	bltu	a5,a3,80004292 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041b2:	00043737          	lui	a4,0x43
    800041b6:	0ef76063          	bltu	a4,a5,80004296 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041ba:	0c0b0863          	beqz	s6,8000428a <writei+0x10e>
    800041be:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041c0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041c4:	5c7d                	li	s8,-1
    800041c6:	a091                	j	8000420a <writei+0x8e>
    800041c8:	020d1d93          	slli	s11,s10,0x20
    800041cc:	020ddd93          	srli	s11,s11,0x20
    800041d0:	05848513          	addi	a0,s1,88
    800041d4:	86ee                	mv	a3,s11
    800041d6:	8652                	mv	a2,s4
    800041d8:	85de                	mv	a1,s7
    800041da:	953a                	add	a0,a0,a4
    800041dc:	ffffe097          	auipc	ra,0xffffe
    800041e0:	730080e7          	jalr	1840(ra) # 8000290c <either_copyin>
    800041e4:	07850263          	beq	a0,s8,80004248 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041e8:	8526                	mv	a0,s1
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	788080e7          	jalr	1928(ra) # 80004972 <log_write>
    brelse(bp);
    800041f2:	8526                	mv	a0,s1
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	4f4080e7          	jalr	1268(ra) # 800036e8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041fc:	013d09bb          	addw	s3,s10,s3
    80004200:	012d093b          	addw	s2,s10,s2
    80004204:	9a6e                	add	s4,s4,s11
    80004206:	0569f663          	bgeu	s3,s6,80004252 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000420a:	00a9559b          	srliw	a1,s2,0xa
    8000420e:	8556                	mv	a0,s5
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	79c080e7          	jalr	1948(ra) # 800039ac <bmap>
    80004218:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000421c:	c99d                	beqz	a1,80004252 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000421e:	000aa503          	lw	a0,0(s5)
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	396080e7          	jalr	918(ra) # 800035b8 <bread>
    8000422a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000422c:	3ff97713          	andi	a4,s2,1023
    80004230:	40ec87bb          	subw	a5,s9,a4
    80004234:	413b06bb          	subw	a3,s6,s3
    80004238:	8d3e                	mv	s10,a5
    8000423a:	2781                	sext.w	a5,a5
    8000423c:	0006861b          	sext.w	a2,a3
    80004240:	f8f674e3          	bgeu	a2,a5,800041c8 <writei+0x4c>
    80004244:	8d36                	mv	s10,a3
    80004246:	b749                	j	800041c8 <writei+0x4c>
      brelse(bp);
    80004248:	8526                	mv	a0,s1
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	49e080e7          	jalr	1182(ra) # 800036e8 <brelse>
  }

  if(off > ip->size)
    80004252:	04caa783          	lw	a5,76(s5)
    80004256:	0127f463          	bgeu	a5,s2,8000425e <writei+0xe2>
    ip->size = off;
    8000425a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000425e:	8556                	mv	a0,s5
    80004260:	00000097          	auipc	ra,0x0
    80004264:	aa4080e7          	jalr	-1372(ra) # 80003d04 <iupdate>

  return tot;
    80004268:	0009851b          	sext.w	a0,s3
}
    8000426c:	70a6                	ld	ra,104(sp)
    8000426e:	7406                	ld	s0,96(sp)
    80004270:	64e6                	ld	s1,88(sp)
    80004272:	6946                	ld	s2,80(sp)
    80004274:	69a6                	ld	s3,72(sp)
    80004276:	6a06                	ld	s4,64(sp)
    80004278:	7ae2                	ld	s5,56(sp)
    8000427a:	7b42                	ld	s6,48(sp)
    8000427c:	7ba2                	ld	s7,40(sp)
    8000427e:	7c02                	ld	s8,32(sp)
    80004280:	6ce2                	ld	s9,24(sp)
    80004282:	6d42                	ld	s10,16(sp)
    80004284:	6da2                	ld	s11,8(sp)
    80004286:	6165                	addi	sp,sp,112
    80004288:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000428a:	89da                	mv	s3,s6
    8000428c:	bfc9                	j	8000425e <writei+0xe2>
    return -1;
    8000428e:	557d                	li	a0,-1
}
    80004290:	8082                	ret
    return -1;
    80004292:	557d                	li	a0,-1
    80004294:	bfe1                	j	8000426c <writei+0xf0>
    return -1;
    80004296:	557d                	li	a0,-1
    80004298:	bfd1                	j	8000426c <writei+0xf0>

000000008000429a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000429a:	1141                	addi	sp,sp,-16
    8000429c:	e406                	sd	ra,8(sp)
    8000429e:	e022                	sd	s0,0(sp)
    800042a0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042a2:	4639                	li	a2,14
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	d1a080e7          	jalr	-742(ra) # 80000fbe <strncmp>
}
    800042ac:	60a2                	ld	ra,8(sp)
    800042ae:	6402                	ld	s0,0(sp)
    800042b0:	0141                	addi	sp,sp,16
    800042b2:	8082                	ret

00000000800042b4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042b4:	7139                	addi	sp,sp,-64
    800042b6:	fc06                	sd	ra,56(sp)
    800042b8:	f822                	sd	s0,48(sp)
    800042ba:	f426                	sd	s1,40(sp)
    800042bc:	f04a                	sd	s2,32(sp)
    800042be:	ec4e                	sd	s3,24(sp)
    800042c0:	e852                	sd	s4,16(sp)
    800042c2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042c4:	04451703          	lh	a4,68(a0)
    800042c8:	4785                	li	a5,1
    800042ca:	00f71a63          	bne	a4,a5,800042de <dirlookup+0x2a>
    800042ce:	892a                	mv	s2,a0
    800042d0:	89ae                	mv	s3,a1
    800042d2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d4:	457c                	lw	a5,76(a0)
    800042d6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042d8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042da:	e79d                	bnez	a5,80004308 <dirlookup+0x54>
    800042dc:	a8a5                	j	80004354 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042de:	00004517          	auipc	a0,0x4
    800042e2:	47250513          	addi	a0,a0,1138 # 80008750 <syscalls+0x1c8>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	25a080e7          	jalr	602(ra) # 80000540 <panic>
      panic("dirlookup read");
    800042ee:	00004517          	auipc	a0,0x4
    800042f2:	47a50513          	addi	a0,a0,1146 # 80008768 <syscalls+0x1e0>
    800042f6:	ffffc097          	auipc	ra,0xffffc
    800042fa:	24a080e7          	jalr	586(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042fe:	24c1                	addiw	s1,s1,16
    80004300:	04c92783          	lw	a5,76(s2)
    80004304:	04f4f763          	bgeu	s1,a5,80004352 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004308:	4741                	li	a4,16
    8000430a:	86a6                	mv	a3,s1
    8000430c:	fc040613          	addi	a2,s0,-64
    80004310:	4581                	li	a1,0
    80004312:	854a                	mv	a0,s2
    80004314:	00000097          	auipc	ra,0x0
    80004318:	d70080e7          	jalr	-656(ra) # 80004084 <readi>
    8000431c:	47c1                	li	a5,16
    8000431e:	fcf518e3          	bne	a0,a5,800042ee <dirlookup+0x3a>
    if(de.inum == 0)
    80004322:	fc045783          	lhu	a5,-64(s0)
    80004326:	dfe1                	beqz	a5,800042fe <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004328:	fc240593          	addi	a1,s0,-62
    8000432c:	854e                	mv	a0,s3
    8000432e:	00000097          	auipc	ra,0x0
    80004332:	f6c080e7          	jalr	-148(ra) # 8000429a <namecmp>
    80004336:	f561                	bnez	a0,800042fe <dirlookup+0x4a>
      if(poff)
    80004338:	000a0463          	beqz	s4,80004340 <dirlookup+0x8c>
        *poff = off;
    8000433c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004340:	fc045583          	lhu	a1,-64(s0)
    80004344:	00092503          	lw	a0,0(s2)
    80004348:	fffff097          	auipc	ra,0xfffff
    8000434c:	74e080e7          	jalr	1870(ra) # 80003a96 <iget>
    80004350:	a011                	j	80004354 <dirlookup+0xa0>
  return 0;
    80004352:	4501                	li	a0,0
}
    80004354:	70e2                	ld	ra,56(sp)
    80004356:	7442                	ld	s0,48(sp)
    80004358:	74a2                	ld	s1,40(sp)
    8000435a:	7902                	ld	s2,32(sp)
    8000435c:	69e2                	ld	s3,24(sp)
    8000435e:	6a42                	ld	s4,16(sp)
    80004360:	6121                	addi	sp,sp,64
    80004362:	8082                	ret

0000000080004364 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004364:	711d                	addi	sp,sp,-96
    80004366:	ec86                	sd	ra,88(sp)
    80004368:	e8a2                	sd	s0,80(sp)
    8000436a:	e4a6                	sd	s1,72(sp)
    8000436c:	e0ca                	sd	s2,64(sp)
    8000436e:	fc4e                	sd	s3,56(sp)
    80004370:	f852                	sd	s4,48(sp)
    80004372:	f456                	sd	s5,40(sp)
    80004374:	f05a                	sd	s6,32(sp)
    80004376:	ec5e                	sd	s7,24(sp)
    80004378:	e862                	sd	s8,16(sp)
    8000437a:	e466                	sd	s9,8(sp)
    8000437c:	e06a                	sd	s10,0(sp)
    8000437e:	1080                	addi	s0,sp,96
    80004380:	84aa                	mv	s1,a0
    80004382:	8b2e                	mv	s6,a1
    80004384:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004386:	00054703          	lbu	a4,0(a0)
    8000438a:	02f00793          	li	a5,47
    8000438e:	02f70363          	beq	a4,a5,800043b4 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004392:	ffffe097          	auipc	ra,0xffffe
    80004396:	96e080e7          	jalr	-1682(ra) # 80001d00 <myproc>
    8000439a:	15053503          	ld	a0,336(a0)
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	9f4080e7          	jalr	-1548(ra) # 80003d92 <idup>
    800043a6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800043a8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800043ac:	4cb5                	li	s9,13
  len = path - s;
    800043ae:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043b0:	4c05                	li	s8,1
    800043b2:	a87d                	j	80004470 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800043b4:	4585                	li	a1,1
    800043b6:	4505                	li	a0,1
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	6de080e7          	jalr	1758(ra) # 80003a96 <iget>
    800043c0:	8a2a                	mv	s4,a0
    800043c2:	b7dd                	j	800043a8 <namex+0x44>
      iunlockput(ip);
    800043c4:	8552                	mv	a0,s4
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	c6c080e7          	jalr	-916(ra) # 80004032 <iunlockput>
      return 0;
    800043ce:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043d0:	8552                	mv	a0,s4
    800043d2:	60e6                	ld	ra,88(sp)
    800043d4:	6446                	ld	s0,80(sp)
    800043d6:	64a6                	ld	s1,72(sp)
    800043d8:	6906                	ld	s2,64(sp)
    800043da:	79e2                	ld	s3,56(sp)
    800043dc:	7a42                	ld	s4,48(sp)
    800043de:	7aa2                	ld	s5,40(sp)
    800043e0:	7b02                	ld	s6,32(sp)
    800043e2:	6be2                	ld	s7,24(sp)
    800043e4:	6c42                	ld	s8,16(sp)
    800043e6:	6ca2                	ld	s9,8(sp)
    800043e8:	6d02                	ld	s10,0(sp)
    800043ea:	6125                	addi	sp,sp,96
    800043ec:	8082                	ret
      iunlock(ip);
    800043ee:	8552                	mv	a0,s4
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	aa2080e7          	jalr	-1374(ra) # 80003e92 <iunlock>
      return ip;
    800043f8:	bfe1                	j	800043d0 <namex+0x6c>
      iunlockput(ip);
    800043fa:	8552                	mv	a0,s4
    800043fc:	00000097          	auipc	ra,0x0
    80004400:	c36080e7          	jalr	-970(ra) # 80004032 <iunlockput>
      return 0;
    80004404:	8a4e                	mv	s4,s3
    80004406:	b7e9                	j	800043d0 <namex+0x6c>
  len = path - s;
    80004408:	40998633          	sub	a2,s3,s1
    8000440c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004410:	09acd863          	bge	s9,s10,800044a0 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004414:	4639                	li	a2,14
    80004416:	85a6                	mv	a1,s1
    80004418:	8556                	mv	a0,s5
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	b30080e7          	jalr	-1232(ra) # 80000f4a <memmove>
    80004422:	84ce                	mv	s1,s3
  while(*path == '/')
    80004424:	0004c783          	lbu	a5,0(s1)
    80004428:	01279763          	bne	a5,s2,80004436 <namex+0xd2>
    path++;
    8000442c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000442e:	0004c783          	lbu	a5,0(s1)
    80004432:	ff278de3          	beq	a5,s2,8000442c <namex+0xc8>
    ilock(ip);
    80004436:	8552                	mv	a0,s4
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	998080e7          	jalr	-1640(ra) # 80003dd0 <ilock>
    if(ip->type != T_DIR){
    80004440:	044a1783          	lh	a5,68(s4)
    80004444:	f98790e3          	bne	a5,s8,800043c4 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004448:	000b0563          	beqz	s6,80004452 <namex+0xee>
    8000444c:	0004c783          	lbu	a5,0(s1)
    80004450:	dfd9                	beqz	a5,800043ee <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004452:	865e                	mv	a2,s7
    80004454:	85d6                	mv	a1,s5
    80004456:	8552                	mv	a0,s4
    80004458:	00000097          	auipc	ra,0x0
    8000445c:	e5c080e7          	jalr	-420(ra) # 800042b4 <dirlookup>
    80004460:	89aa                	mv	s3,a0
    80004462:	dd41                	beqz	a0,800043fa <namex+0x96>
    iunlockput(ip);
    80004464:	8552                	mv	a0,s4
    80004466:	00000097          	auipc	ra,0x0
    8000446a:	bcc080e7          	jalr	-1076(ra) # 80004032 <iunlockput>
    ip = next;
    8000446e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004470:	0004c783          	lbu	a5,0(s1)
    80004474:	01279763          	bne	a5,s2,80004482 <namex+0x11e>
    path++;
    80004478:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000447a:	0004c783          	lbu	a5,0(s1)
    8000447e:	ff278de3          	beq	a5,s2,80004478 <namex+0x114>
  if(*path == 0)
    80004482:	cb9d                	beqz	a5,800044b8 <namex+0x154>
  while(*path != '/' && *path != 0)
    80004484:	0004c783          	lbu	a5,0(s1)
    80004488:	89a6                	mv	s3,s1
  len = path - s;
    8000448a:	8d5e                	mv	s10,s7
    8000448c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000448e:	01278963          	beq	a5,s2,800044a0 <namex+0x13c>
    80004492:	dbbd                	beqz	a5,80004408 <namex+0xa4>
    path++;
    80004494:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004496:	0009c783          	lbu	a5,0(s3)
    8000449a:	ff279ce3          	bne	a5,s2,80004492 <namex+0x12e>
    8000449e:	b7ad                	j	80004408 <namex+0xa4>
    memmove(name, s, len);
    800044a0:	2601                	sext.w	a2,a2
    800044a2:	85a6                	mv	a1,s1
    800044a4:	8556                	mv	a0,s5
    800044a6:	ffffd097          	auipc	ra,0xffffd
    800044aa:	aa4080e7          	jalr	-1372(ra) # 80000f4a <memmove>
    name[len] = 0;
    800044ae:	9d56                	add	s10,s10,s5
    800044b0:	000d0023          	sb	zero,0(s10)
    800044b4:	84ce                	mv	s1,s3
    800044b6:	b7bd                	j	80004424 <namex+0xc0>
  if(nameiparent){
    800044b8:	f00b0ce3          	beqz	s6,800043d0 <namex+0x6c>
    iput(ip);
    800044bc:	8552                	mv	a0,s4
    800044be:	00000097          	auipc	ra,0x0
    800044c2:	acc080e7          	jalr	-1332(ra) # 80003f8a <iput>
    return 0;
    800044c6:	4a01                	li	s4,0
    800044c8:	b721                	j	800043d0 <namex+0x6c>

00000000800044ca <dirlink>:
{
    800044ca:	7139                	addi	sp,sp,-64
    800044cc:	fc06                	sd	ra,56(sp)
    800044ce:	f822                	sd	s0,48(sp)
    800044d0:	f426                	sd	s1,40(sp)
    800044d2:	f04a                	sd	s2,32(sp)
    800044d4:	ec4e                	sd	s3,24(sp)
    800044d6:	e852                	sd	s4,16(sp)
    800044d8:	0080                	addi	s0,sp,64
    800044da:	892a                	mv	s2,a0
    800044dc:	8a2e                	mv	s4,a1
    800044de:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044e0:	4601                	li	a2,0
    800044e2:	00000097          	auipc	ra,0x0
    800044e6:	dd2080e7          	jalr	-558(ra) # 800042b4 <dirlookup>
    800044ea:	e93d                	bnez	a0,80004560 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ec:	04c92483          	lw	s1,76(s2)
    800044f0:	c49d                	beqz	s1,8000451e <dirlink+0x54>
    800044f2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044f4:	4741                	li	a4,16
    800044f6:	86a6                	mv	a3,s1
    800044f8:	fc040613          	addi	a2,s0,-64
    800044fc:	4581                	li	a1,0
    800044fe:	854a                	mv	a0,s2
    80004500:	00000097          	auipc	ra,0x0
    80004504:	b84080e7          	jalr	-1148(ra) # 80004084 <readi>
    80004508:	47c1                	li	a5,16
    8000450a:	06f51163          	bne	a0,a5,8000456c <dirlink+0xa2>
    if(de.inum == 0)
    8000450e:	fc045783          	lhu	a5,-64(s0)
    80004512:	c791                	beqz	a5,8000451e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004514:	24c1                	addiw	s1,s1,16
    80004516:	04c92783          	lw	a5,76(s2)
    8000451a:	fcf4ede3          	bltu	s1,a5,800044f4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000451e:	4639                	li	a2,14
    80004520:	85d2                	mv	a1,s4
    80004522:	fc240513          	addi	a0,s0,-62
    80004526:	ffffd097          	auipc	ra,0xffffd
    8000452a:	ad4080e7          	jalr	-1324(ra) # 80000ffa <strncpy>
  de.inum = inum;
    8000452e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004532:	4741                	li	a4,16
    80004534:	86a6                	mv	a3,s1
    80004536:	fc040613          	addi	a2,s0,-64
    8000453a:	4581                	li	a1,0
    8000453c:	854a                	mv	a0,s2
    8000453e:	00000097          	auipc	ra,0x0
    80004542:	c3e080e7          	jalr	-962(ra) # 8000417c <writei>
    80004546:	1541                	addi	a0,a0,-16
    80004548:	00a03533          	snez	a0,a0
    8000454c:	40a00533          	neg	a0,a0
}
    80004550:	70e2                	ld	ra,56(sp)
    80004552:	7442                	ld	s0,48(sp)
    80004554:	74a2                	ld	s1,40(sp)
    80004556:	7902                	ld	s2,32(sp)
    80004558:	69e2                	ld	s3,24(sp)
    8000455a:	6a42                	ld	s4,16(sp)
    8000455c:	6121                	addi	sp,sp,64
    8000455e:	8082                	ret
    iput(ip);
    80004560:	00000097          	auipc	ra,0x0
    80004564:	a2a080e7          	jalr	-1494(ra) # 80003f8a <iput>
    return -1;
    80004568:	557d                	li	a0,-1
    8000456a:	b7dd                	j	80004550 <dirlink+0x86>
      panic("dirlink read");
    8000456c:	00004517          	auipc	a0,0x4
    80004570:	20c50513          	addi	a0,a0,524 # 80008778 <syscalls+0x1f0>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	fcc080e7          	jalr	-52(ra) # 80000540 <panic>

000000008000457c <namei>:

struct inode*
namei(char *path)
{
    8000457c:	1101                	addi	sp,sp,-32
    8000457e:	ec06                	sd	ra,24(sp)
    80004580:	e822                	sd	s0,16(sp)
    80004582:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004584:	fe040613          	addi	a2,s0,-32
    80004588:	4581                	li	a1,0
    8000458a:	00000097          	auipc	ra,0x0
    8000458e:	dda080e7          	jalr	-550(ra) # 80004364 <namex>
}
    80004592:	60e2                	ld	ra,24(sp)
    80004594:	6442                	ld	s0,16(sp)
    80004596:	6105                	addi	sp,sp,32
    80004598:	8082                	ret

000000008000459a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000459a:	1141                	addi	sp,sp,-16
    8000459c:	e406                	sd	ra,8(sp)
    8000459e:	e022                	sd	s0,0(sp)
    800045a0:	0800                	addi	s0,sp,16
    800045a2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045a4:	4585                	li	a1,1
    800045a6:	00000097          	auipc	ra,0x0
    800045aa:	dbe080e7          	jalr	-578(ra) # 80004364 <namex>
}
    800045ae:	60a2                	ld	ra,8(sp)
    800045b0:	6402                	ld	s0,0(sp)
    800045b2:	0141                	addi	sp,sp,16
    800045b4:	8082                	ret

00000000800045b6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045b6:	1101                	addi	sp,sp,-32
    800045b8:	ec06                	sd	ra,24(sp)
    800045ba:	e822                	sd	s0,16(sp)
    800045bc:	e426                	sd	s1,8(sp)
    800045be:	e04a                	sd	s2,0(sp)
    800045c0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045c2:	0003c917          	auipc	s2,0x3c
    800045c6:	71690913          	addi	s2,s2,1814 # 80040cd8 <log>
    800045ca:	01892583          	lw	a1,24(s2)
    800045ce:	02892503          	lw	a0,40(s2)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	fe6080e7          	jalr	-26(ra) # 800035b8 <bread>
    800045da:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800045dc:	02c92683          	lw	a3,44(s2)
    800045e0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800045e2:	02d05863          	blez	a3,80004612 <write_head+0x5c>
    800045e6:	0003c797          	auipc	a5,0x3c
    800045ea:	72278793          	addi	a5,a5,1826 # 80040d08 <log+0x30>
    800045ee:	05c50713          	addi	a4,a0,92
    800045f2:	36fd                	addiw	a3,a3,-1
    800045f4:	02069613          	slli	a2,a3,0x20
    800045f8:	01e65693          	srli	a3,a2,0x1e
    800045fc:	0003c617          	auipc	a2,0x3c
    80004600:	71060613          	addi	a2,a2,1808 # 80040d0c <log+0x34>
    80004604:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004606:	4390                	lw	a2,0(a5)
    80004608:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000460a:	0791                	addi	a5,a5,4
    8000460c:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000460e:	fed79ce3          	bne	a5,a3,80004606 <write_head+0x50>
  }
  bwrite(buf);
    80004612:	8526                	mv	a0,s1
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	096080e7          	jalr	150(ra) # 800036aa <bwrite>
  brelse(buf);
    8000461c:	8526                	mv	a0,s1
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	0ca080e7          	jalr	202(ra) # 800036e8 <brelse>
}
    80004626:	60e2                	ld	ra,24(sp)
    80004628:	6442                	ld	s0,16(sp)
    8000462a:	64a2                	ld	s1,8(sp)
    8000462c:	6902                	ld	s2,0(sp)
    8000462e:	6105                	addi	sp,sp,32
    80004630:	8082                	ret

0000000080004632 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004632:	0003c797          	auipc	a5,0x3c
    80004636:	6d27a783          	lw	a5,1746(a5) # 80040d04 <log+0x2c>
    8000463a:	0af05d63          	blez	a5,800046f4 <install_trans+0xc2>
{
    8000463e:	7139                	addi	sp,sp,-64
    80004640:	fc06                	sd	ra,56(sp)
    80004642:	f822                	sd	s0,48(sp)
    80004644:	f426                	sd	s1,40(sp)
    80004646:	f04a                	sd	s2,32(sp)
    80004648:	ec4e                	sd	s3,24(sp)
    8000464a:	e852                	sd	s4,16(sp)
    8000464c:	e456                	sd	s5,8(sp)
    8000464e:	e05a                	sd	s6,0(sp)
    80004650:	0080                	addi	s0,sp,64
    80004652:	8b2a                	mv	s6,a0
    80004654:	0003ca97          	auipc	s5,0x3c
    80004658:	6b4a8a93          	addi	s5,s5,1716 # 80040d08 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000465c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000465e:	0003c997          	auipc	s3,0x3c
    80004662:	67a98993          	addi	s3,s3,1658 # 80040cd8 <log>
    80004666:	a00d                	j	80004688 <install_trans+0x56>
    brelse(lbuf);
    80004668:	854a                	mv	a0,s2
    8000466a:	fffff097          	auipc	ra,0xfffff
    8000466e:	07e080e7          	jalr	126(ra) # 800036e8 <brelse>
    brelse(dbuf);
    80004672:	8526                	mv	a0,s1
    80004674:	fffff097          	auipc	ra,0xfffff
    80004678:	074080e7          	jalr	116(ra) # 800036e8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000467c:	2a05                	addiw	s4,s4,1
    8000467e:	0a91                	addi	s5,s5,4
    80004680:	02c9a783          	lw	a5,44(s3)
    80004684:	04fa5e63          	bge	s4,a5,800046e0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004688:	0189a583          	lw	a1,24(s3)
    8000468c:	014585bb          	addw	a1,a1,s4
    80004690:	2585                	addiw	a1,a1,1
    80004692:	0289a503          	lw	a0,40(s3)
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	f22080e7          	jalr	-222(ra) # 800035b8 <bread>
    8000469e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800046a0:	000aa583          	lw	a1,0(s5)
    800046a4:	0289a503          	lw	a0,40(s3)
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	f10080e7          	jalr	-240(ra) # 800035b8 <bread>
    800046b0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046b2:	40000613          	li	a2,1024
    800046b6:	05890593          	addi	a1,s2,88
    800046ba:	05850513          	addi	a0,a0,88
    800046be:	ffffd097          	auipc	ra,0xffffd
    800046c2:	88c080e7          	jalr	-1908(ra) # 80000f4a <memmove>
    bwrite(dbuf);  // write dst to disk
    800046c6:	8526                	mv	a0,s1
    800046c8:	fffff097          	auipc	ra,0xfffff
    800046cc:	fe2080e7          	jalr	-30(ra) # 800036aa <bwrite>
    if(recovering == 0)
    800046d0:	f80b1ce3          	bnez	s6,80004668 <install_trans+0x36>
      bunpin(dbuf);
    800046d4:	8526                	mv	a0,s1
    800046d6:	fffff097          	auipc	ra,0xfffff
    800046da:	0ec080e7          	jalr	236(ra) # 800037c2 <bunpin>
    800046de:	b769                	j	80004668 <install_trans+0x36>
}
    800046e0:	70e2                	ld	ra,56(sp)
    800046e2:	7442                	ld	s0,48(sp)
    800046e4:	74a2                	ld	s1,40(sp)
    800046e6:	7902                	ld	s2,32(sp)
    800046e8:	69e2                	ld	s3,24(sp)
    800046ea:	6a42                	ld	s4,16(sp)
    800046ec:	6aa2                	ld	s5,8(sp)
    800046ee:	6b02                	ld	s6,0(sp)
    800046f0:	6121                	addi	sp,sp,64
    800046f2:	8082                	ret
    800046f4:	8082                	ret

00000000800046f6 <initlog>:
{
    800046f6:	7179                	addi	sp,sp,-48
    800046f8:	f406                	sd	ra,40(sp)
    800046fa:	f022                	sd	s0,32(sp)
    800046fc:	ec26                	sd	s1,24(sp)
    800046fe:	e84a                	sd	s2,16(sp)
    80004700:	e44e                	sd	s3,8(sp)
    80004702:	1800                	addi	s0,sp,48
    80004704:	892a                	mv	s2,a0
    80004706:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004708:	0003c497          	auipc	s1,0x3c
    8000470c:	5d048493          	addi	s1,s1,1488 # 80040cd8 <log>
    80004710:	00004597          	auipc	a1,0x4
    80004714:	07858593          	addi	a1,a1,120 # 80008788 <syscalls+0x200>
    80004718:	8526                	mv	a0,s1
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	648080e7          	jalr	1608(ra) # 80000d62 <initlock>
  log.start = sb->logstart;
    80004722:	0149a583          	lw	a1,20(s3)
    80004726:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004728:	0109a783          	lw	a5,16(s3)
    8000472c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000472e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004732:	854a                	mv	a0,s2
    80004734:	fffff097          	auipc	ra,0xfffff
    80004738:	e84080e7          	jalr	-380(ra) # 800035b8 <bread>
  log.lh.n = lh->n;
    8000473c:	4d34                	lw	a3,88(a0)
    8000473e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004740:	02d05663          	blez	a3,8000476c <initlog+0x76>
    80004744:	05c50793          	addi	a5,a0,92
    80004748:	0003c717          	auipc	a4,0x3c
    8000474c:	5c070713          	addi	a4,a4,1472 # 80040d08 <log+0x30>
    80004750:	36fd                	addiw	a3,a3,-1
    80004752:	02069613          	slli	a2,a3,0x20
    80004756:	01e65693          	srli	a3,a2,0x1e
    8000475a:	06050613          	addi	a2,a0,96
    8000475e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004760:	4390                	lw	a2,0(a5)
    80004762:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004764:	0791                	addi	a5,a5,4
    80004766:	0711                	addi	a4,a4,4
    80004768:	fed79ce3          	bne	a5,a3,80004760 <initlog+0x6a>
  brelse(buf);
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	f7c080e7          	jalr	-132(ra) # 800036e8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004774:	4505                	li	a0,1
    80004776:	00000097          	auipc	ra,0x0
    8000477a:	ebc080e7          	jalr	-324(ra) # 80004632 <install_trans>
  log.lh.n = 0;
    8000477e:	0003c797          	auipc	a5,0x3c
    80004782:	5807a323          	sw	zero,1414(a5) # 80040d04 <log+0x2c>
  write_head(); // clear the log
    80004786:	00000097          	auipc	ra,0x0
    8000478a:	e30080e7          	jalr	-464(ra) # 800045b6 <write_head>
}
    8000478e:	70a2                	ld	ra,40(sp)
    80004790:	7402                	ld	s0,32(sp)
    80004792:	64e2                	ld	s1,24(sp)
    80004794:	6942                	ld	s2,16(sp)
    80004796:	69a2                	ld	s3,8(sp)
    80004798:	6145                	addi	sp,sp,48
    8000479a:	8082                	ret

000000008000479c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000479c:	1101                	addi	sp,sp,-32
    8000479e:	ec06                	sd	ra,24(sp)
    800047a0:	e822                	sd	s0,16(sp)
    800047a2:	e426                	sd	s1,8(sp)
    800047a4:	e04a                	sd	s2,0(sp)
    800047a6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800047a8:	0003c517          	auipc	a0,0x3c
    800047ac:	53050513          	addi	a0,a0,1328 # 80040cd8 <log>
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	642080e7          	jalr	1602(ra) # 80000df2 <acquire>
  while(1){
    if(log.committing){
    800047b8:	0003c497          	auipc	s1,0x3c
    800047bc:	52048493          	addi	s1,s1,1312 # 80040cd8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047c0:	4979                	li	s2,30
    800047c2:	a039                	j	800047d0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800047c4:	85a6                	mv	a1,s1
    800047c6:	8526                	mv	a0,s1
    800047c8:	ffffe097          	auipc	ra,0xffffe
    800047cc:	ce6080e7          	jalr	-794(ra) # 800024ae <sleep>
    if(log.committing){
    800047d0:	50dc                	lw	a5,36(s1)
    800047d2:	fbed                	bnez	a5,800047c4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047d4:	5098                	lw	a4,32(s1)
    800047d6:	2705                	addiw	a4,a4,1
    800047d8:	0007069b          	sext.w	a3,a4
    800047dc:	0027179b          	slliw	a5,a4,0x2
    800047e0:	9fb9                	addw	a5,a5,a4
    800047e2:	0017979b          	slliw	a5,a5,0x1
    800047e6:	54d8                	lw	a4,44(s1)
    800047e8:	9fb9                	addw	a5,a5,a4
    800047ea:	00f95963          	bge	s2,a5,800047fc <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047ee:	85a6                	mv	a1,s1
    800047f0:	8526                	mv	a0,s1
    800047f2:	ffffe097          	auipc	ra,0xffffe
    800047f6:	cbc080e7          	jalr	-836(ra) # 800024ae <sleep>
    800047fa:	bfd9                	j	800047d0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800047fc:	0003c517          	auipc	a0,0x3c
    80004800:	4dc50513          	addi	a0,a0,1244 # 80040cd8 <log>
    80004804:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	6a0080e7          	jalr	1696(ra) # 80000ea6 <release>
      break;
    }
  }
}
    8000480e:	60e2                	ld	ra,24(sp)
    80004810:	6442                	ld	s0,16(sp)
    80004812:	64a2                	ld	s1,8(sp)
    80004814:	6902                	ld	s2,0(sp)
    80004816:	6105                	addi	sp,sp,32
    80004818:	8082                	ret

000000008000481a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000481a:	7139                	addi	sp,sp,-64
    8000481c:	fc06                	sd	ra,56(sp)
    8000481e:	f822                	sd	s0,48(sp)
    80004820:	f426                	sd	s1,40(sp)
    80004822:	f04a                	sd	s2,32(sp)
    80004824:	ec4e                	sd	s3,24(sp)
    80004826:	e852                	sd	s4,16(sp)
    80004828:	e456                	sd	s5,8(sp)
    8000482a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000482c:	0003c497          	auipc	s1,0x3c
    80004830:	4ac48493          	addi	s1,s1,1196 # 80040cd8 <log>
    80004834:	8526                	mv	a0,s1
    80004836:	ffffc097          	auipc	ra,0xffffc
    8000483a:	5bc080e7          	jalr	1468(ra) # 80000df2 <acquire>
  log.outstanding -= 1;
    8000483e:	509c                	lw	a5,32(s1)
    80004840:	37fd                	addiw	a5,a5,-1
    80004842:	0007891b          	sext.w	s2,a5
    80004846:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004848:	50dc                	lw	a5,36(s1)
    8000484a:	e7b9                	bnez	a5,80004898 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000484c:	04091e63          	bnez	s2,800048a8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004850:	0003c497          	auipc	s1,0x3c
    80004854:	48848493          	addi	s1,s1,1160 # 80040cd8 <log>
    80004858:	4785                	li	a5,1
    8000485a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000485c:	8526                	mv	a0,s1
    8000485e:	ffffc097          	auipc	ra,0xffffc
    80004862:	648080e7          	jalr	1608(ra) # 80000ea6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004866:	54dc                	lw	a5,44(s1)
    80004868:	06f04763          	bgtz	a5,800048d6 <end_op+0xbc>
    acquire(&log.lock);
    8000486c:	0003c497          	auipc	s1,0x3c
    80004870:	46c48493          	addi	s1,s1,1132 # 80040cd8 <log>
    80004874:	8526                	mv	a0,s1
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	57c080e7          	jalr	1404(ra) # 80000df2 <acquire>
    log.committing = 0;
    8000487e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004882:	8526                	mv	a0,s1
    80004884:	ffffe097          	auipc	ra,0xffffe
    80004888:	c8e080e7          	jalr	-882(ra) # 80002512 <wakeup>
    release(&log.lock);
    8000488c:	8526                	mv	a0,s1
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	618080e7          	jalr	1560(ra) # 80000ea6 <release>
}
    80004896:	a03d                	j	800048c4 <end_op+0xaa>
    panic("log.committing");
    80004898:	00004517          	auipc	a0,0x4
    8000489c:	ef850513          	addi	a0,a0,-264 # 80008790 <syscalls+0x208>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	ca0080e7          	jalr	-864(ra) # 80000540 <panic>
    wakeup(&log);
    800048a8:	0003c497          	auipc	s1,0x3c
    800048ac:	43048493          	addi	s1,s1,1072 # 80040cd8 <log>
    800048b0:	8526                	mv	a0,s1
    800048b2:	ffffe097          	auipc	ra,0xffffe
    800048b6:	c60080e7          	jalr	-928(ra) # 80002512 <wakeup>
  release(&log.lock);
    800048ba:	8526                	mv	a0,s1
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	5ea080e7          	jalr	1514(ra) # 80000ea6 <release>
}
    800048c4:	70e2                	ld	ra,56(sp)
    800048c6:	7442                	ld	s0,48(sp)
    800048c8:	74a2                	ld	s1,40(sp)
    800048ca:	7902                	ld	s2,32(sp)
    800048cc:	69e2                	ld	s3,24(sp)
    800048ce:	6a42                	ld	s4,16(sp)
    800048d0:	6aa2                	ld	s5,8(sp)
    800048d2:	6121                	addi	sp,sp,64
    800048d4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800048d6:	0003ca97          	auipc	s5,0x3c
    800048da:	432a8a93          	addi	s5,s5,1074 # 80040d08 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800048de:	0003ca17          	auipc	s4,0x3c
    800048e2:	3faa0a13          	addi	s4,s4,1018 # 80040cd8 <log>
    800048e6:	018a2583          	lw	a1,24(s4)
    800048ea:	012585bb          	addw	a1,a1,s2
    800048ee:	2585                	addiw	a1,a1,1
    800048f0:	028a2503          	lw	a0,40(s4)
    800048f4:	fffff097          	auipc	ra,0xfffff
    800048f8:	cc4080e7          	jalr	-828(ra) # 800035b8 <bread>
    800048fc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800048fe:	000aa583          	lw	a1,0(s5)
    80004902:	028a2503          	lw	a0,40(s4)
    80004906:	fffff097          	auipc	ra,0xfffff
    8000490a:	cb2080e7          	jalr	-846(ra) # 800035b8 <bread>
    8000490e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004910:	40000613          	li	a2,1024
    80004914:	05850593          	addi	a1,a0,88
    80004918:	05848513          	addi	a0,s1,88
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	62e080e7          	jalr	1582(ra) # 80000f4a <memmove>
    bwrite(to);  // write the log
    80004924:	8526                	mv	a0,s1
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	d84080e7          	jalr	-636(ra) # 800036aa <bwrite>
    brelse(from);
    8000492e:	854e                	mv	a0,s3
    80004930:	fffff097          	auipc	ra,0xfffff
    80004934:	db8080e7          	jalr	-584(ra) # 800036e8 <brelse>
    brelse(to);
    80004938:	8526                	mv	a0,s1
    8000493a:	fffff097          	auipc	ra,0xfffff
    8000493e:	dae080e7          	jalr	-594(ra) # 800036e8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004942:	2905                	addiw	s2,s2,1
    80004944:	0a91                	addi	s5,s5,4
    80004946:	02ca2783          	lw	a5,44(s4)
    8000494a:	f8f94ee3          	blt	s2,a5,800048e6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000494e:	00000097          	auipc	ra,0x0
    80004952:	c68080e7          	jalr	-920(ra) # 800045b6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004956:	4501                	li	a0,0
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	cda080e7          	jalr	-806(ra) # 80004632 <install_trans>
    log.lh.n = 0;
    80004960:	0003c797          	auipc	a5,0x3c
    80004964:	3a07a223          	sw	zero,932(a5) # 80040d04 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004968:	00000097          	auipc	ra,0x0
    8000496c:	c4e080e7          	jalr	-946(ra) # 800045b6 <write_head>
    80004970:	bdf5                	j	8000486c <end_op+0x52>

0000000080004972 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004972:	1101                	addi	sp,sp,-32
    80004974:	ec06                	sd	ra,24(sp)
    80004976:	e822                	sd	s0,16(sp)
    80004978:	e426                	sd	s1,8(sp)
    8000497a:	e04a                	sd	s2,0(sp)
    8000497c:	1000                	addi	s0,sp,32
    8000497e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004980:	0003c917          	auipc	s2,0x3c
    80004984:	35890913          	addi	s2,s2,856 # 80040cd8 <log>
    80004988:	854a                	mv	a0,s2
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	468080e7          	jalr	1128(ra) # 80000df2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004992:	02c92603          	lw	a2,44(s2)
    80004996:	47f5                	li	a5,29
    80004998:	06c7c563          	blt	a5,a2,80004a02 <log_write+0x90>
    8000499c:	0003c797          	auipc	a5,0x3c
    800049a0:	3587a783          	lw	a5,856(a5) # 80040cf4 <log+0x1c>
    800049a4:	37fd                	addiw	a5,a5,-1
    800049a6:	04f65e63          	bge	a2,a5,80004a02 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800049aa:	0003c797          	auipc	a5,0x3c
    800049ae:	34e7a783          	lw	a5,846(a5) # 80040cf8 <log+0x20>
    800049b2:	06f05063          	blez	a5,80004a12 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800049b6:	4781                	li	a5,0
    800049b8:	06c05563          	blez	a2,80004a22 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049bc:	44cc                	lw	a1,12(s1)
    800049be:	0003c717          	auipc	a4,0x3c
    800049c2:	34a70713          	addi	a4,a4,842 # 80040d08 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049c6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049c8:	4314                	lw	a3,0(a4)
    800049ca:	04b68c63          	beq	a3,a1,80004a22 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800049ce:	2785                	addiw	a5,a5,1
    800049d0:	0711                	addi	a4,a4,4
    800049d2:	fef61be3          	bne	a2,a5,800049c8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049d6:	0621                	addi	a2,a2,8
    800049d8:	060a                	slli	a2,a2,0x2
    800049da:	0003c797          	auipc	a5,0x3c
    800049de:	2fe78793          	addi	a5,a5,766 # 80040cd8 <log>
    800049e2:	97b2                	add	a5,a5,a2
    800049e4:	44d8                	lw	a4,12(s1)
    800049e6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800049e8:	8526                	mv	a0,s1
    800049ea:	fffff097          	auipc	ra,0xfffff
    800049ee:	d9c080e7          	jalr	-612(ra) # 80003786 <bpin>
    log.lh.n++;
    800049f2:	0003c717          	auipc	a4,0x3c
    800049f6:	2e670713          	addi	a4,a4,742 # 80040cd8 <log>
    800049fa:	575c                	lw	a5,44(a4)
    800049fc:	2785                	addiw	a5,a5,1
    800049fe:	d75c                	sw	a5,44(a4)
    80004a00:	a82d                	j	80004a3a <log_write+0xc8>
    panic("too big a transaction");
    80004a02:	00004517          	auipc	a0,0x4
    80004a06:	d9e50513          	addi	a0,a0,-610 # 800087a0 <syscalls+0x218>
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	b36080e7          	jalr	-1226(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004a12:	00004517          	auipc	a0,0x4
    80004a16:	da650513          	addi	a0,a0,-602 # 800087b8 <syscalls+0x230>
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	b26080e7          	jalr	-1242(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004a22:	00878693          	addi	a3,a5,8
    80004a26:	068a                	slli	a3,a3,0x2
    80004a28:	0003c717          	auipc	a4,0x3c
    80004a2c:	2b070713          	addi	a4,a4,688 # 80040cd8 <log>
    80004a30:	9736                	add	a4,a4,a3
    80004a32:	44d4                	lw	a3,12(s1)
    80004a34:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a36:	faf609e3          	beq	a2,a5,800049e8 <log_write+0x76>
  }
  release(&log.lock);
    80004a3a:	0003c517          	auipc	a0,0x3c
    80004a3e:	29e50513          	addi	a0,a0,670 # 80040cd8 <log>
    80004a42:	ffffc097          	auipc	ra,0xffffc
    80004a46:	464080e7          	jalr	1124(ra) # 80000ea6 <release>
}
    80004a4a:	60e2                	ld	ra,24(sp)
    80004a4c:	6442                	ld	s0,16(sp)
    80004a4e:	64a2                	ld	s1,8(sp)
    80004a50:	6902                	ld	s2,0(sp)
    80004a52:	6105                	addi	sp,sp,32
    80004a54:	8082                	ret

0000000080004a56 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a56:	1101                	addi	sp,sp,-32
    80004a58:	ec06                	sd	ra,24(sp)
    80004a5a:	e822                	sd	s0,16(sp)
    80004a5c:	e426                	sd	s1,8(sp)
    80004a5e:	e04a                	sd	s2,0(sp)
    80004a60:	1000                	addi	s0,sp,32
    80004a62:	84aa                	mv	s1,a0
    80004a64:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a66:	00004597          	auipc	a1,0x4
    80004a6a:	d7258593          	addi	a1,a1,-654 # 800087d8 <syscalls+0x250>
    80004a6e:	0521                	addi	a0,a0,8
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	2f2080e7          	jalr	754(ra) # 80000d62 <initlock>
  lk->name = name;
    80004a78:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a7c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a80:	0204a423          	sw	zero,40(s1)
}
    80004a84:	60e2                	ld	ra,24(sp)
    80004a86:	6442                	ld	s0,16(sp)
    80004a88:	64a2                	ld	s1,8(sp)
    80004a8a:	6902                	ld	s2,0(sp)
    80004a8c:	6105                	addi	sp,sp,32
    80004a8e:	8082                	ret

0000000080004a90 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a90:	1101                	addi	sp,sp,-32
    80004a92:	ec06                	sd	ra,24(sp)
    80004a94:	e822                	sd	s0,16(sp)
    80004a96:	e426                	sd	s1,8(sp)
    80004a98:	e04a                	sd	s2,0(sp)
    80004a9a:	1000                	addi	s0,sp,32
    80004a9c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a9e:	00850913          	addi	s2,a0,8
    80004aa2:	854a                	mv	a0,s2
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	34e080e7          	jalr	846(ra) # 80000df2 <acquire>
  while (lk->locked) {
    80004aac:	409c                	lw	a5,0(s1)
    80004aae:	cb89                	beqz	a5,80004ac0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004ab0:	85ca                	mv	a1,s2
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	ffffe097          	auipc	ra,0xffffe
    80004ab8:	9fa080e7          	jalr	-1542(ra) # 800024ae <sleep>
  while (lk->locked) {
    80004abc:	409c                	lw	a5,0(s1)
    80004abe:	fbed                	bnez	a5,80004ab0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ac0:	4785                	li	a5,1
    80004ac2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ac4:	ffffd097          	auipc	ra,0xffffd
    80004ac8:	23c080e7          	jalr	572(ra) # 80001d00 <myproc>
    80004acc:	591c                	lw	a5,48(a0)
    80004ace:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ad0:	854a                	mv	a0,s2
    80004ad2:	ffffc097          	auipc	ra,0xffffc
    80004ad6:	3d4080e7          	jalr	980(ra) # 80000ea6 <release>
}
    80004ada:	60e2                	ld	ra,24(sp)
    80004adc:	6442                	ld	s0,16(sp)
    80004ade:	64a2                	ld	s1,8(sp)
    80004ae0:	6902                	ld	s2,0(sp)
    80004ae2:	6105                	addi	sp,sp,32
    80004ae4:	8082                	ret

0000000080004ae6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ae6:	1101                	addi	sp,sp,-32
    80004ae8:	ec06                	sd	ra,24(sp)
    80004aea:	e822                	sd	s0,16(sp)
    80004aec:	e426                	sd	s1,8(sp)
    80004aee:	e04a                	sd	s2,0(sp)
    80004af0:	1000                	addi	s0,sp,32
    80004af2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004af4:	00850913          	addi	s2,a0,8
    80004af8:	854a                	mv	a0,s2
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	2f8080e7          	jalr	760(ra) # 80000df2 <acquire>
  lk->locked = 0;
    80004b02:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b06:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	ffffe097          	auipc	ra,0xffffe
    80004b10:	a06080e7          	jalr	-1530(ra) # 80002512 <wakeup>
  release(&lk->lk);
    80004b14:	854a                	mv	a0,s2
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	390080e7          	jalr	912(ra) # 80000ea6 <release>
}
    80004b1e:	60e2                	ld	ra,24(sp)
    80004b20:	6442                	ld	s0,16(sp)
    80004b22:	64a2                	ld	s1,8(sp)
    80004b24:	6902                	ld	s2,0(sp)
    80004b26:	6105                	addi	sp,sp,32
    80004b28:	8082                	ret

0000000080004b2a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b2a:	7179                	addi	sp,sp,-48
    80004b2c:	f406                	sd	ra,40(sp)
    80004b2e:	f022                	sd	s0,32(sp)
    80004b30:	ec26                	sd	s1,24(sp)
    80004b32:	e84a                	sd	s2,16(sp)
    80004b34:	e44e                	sd	s3,8(sp)
    80004b36:	1800                	addi	s0,sp,48
    80004b38:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b3a:	00850913          	addi	s2,a0,8
    80004b3e:	854a                	mv	a0,s2
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	2b2080e7          	jalr	690(ra) # 80000df2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b48:	409c                	lw	a5,0(s1)
    80004b4a:	ef99                	bnez	a5,80004b68 <holdingsleep+0x3e>
    80004b4c:	4481                	li	s1,0
  release(&lk->lk);
    80004b4e:	854a                	mv	a0,s2
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	356080e7          	jalr	854(ra) # 80000ea6 <release>
  return r;
}
    80004b58:	8526                	mv	a0,s1
    80004b5a:	70a2                	ld	ra,40(sp)
    80004b5c:	7402                	ld	s0,32(sp)
    80004b5e:	64e2                	ld	s1,24(sp)
    80004b60:	6942                	ld	s2,16(sp)
    80004b62:	69a2                	ld	s3,8(sp)
    80004b64:	6145                	addi	sp,sp,48
    80004b66:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b68:	0284a983          	lw	s3,40(s1)
    80004b6c:	ffffd097          	auipc	ra,0xffffd
    80004b70:	194080e7          	jalr	404(ra) # 80001d00 <myproc>
    80004b74:	5904                	lw	s1,48(a0)
    80004b76:	413484b3          	sub	s1,s1,s3
    80004b7a:	0014b493          	seqz	s1,s1
    80004b7e:	bfc1                	j	80004b4e <holdingsleep+0x24>

0000000080004b80 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b80:	1141                	addi	sp,sp,-16
    80004b82:	e406                	sd	ra,8(sp)
    80004b84:	e022                	sd	s0,0(sp)
    80004b86:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b88:	00004597          	auipc	a1,0x4
    80004b8c:	c6058593          	addi	a1,a1,-928 # 800087e8 <syscalls+0x260>
    80004b90:	0003c517          	auipc	a0,0x3c
    80004b94:	29050513          	addi	a0,a0,656 # 80040e20 <ftable>
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	1ca080e7          	jalr	458(ra) # 80000d62 <initlock>
}
    80004ba0:	60a2                	ld	ra,8(sp)
    80004ba2:	6402                	ld	s0,0(sp)
    80004ba4:	0141                	addi	sp,sp,16
    80004ba6:	8082                	ret

0000000080004ba8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ba8:	1101                	addi	sp,sp,-32
    80004baa:	ec06                	sd	ra,24(sp)
    80004bac:	e822                	sd	s0,16(sp)
    80004bae:	e426                	sd	s1,8(sp)
    80004bb0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004bb2:	0003c517          	auipc	a0,0x3c
    80004bb6:	26e50513          	addi	a0,a0,622 # 80040e20 <ftable>
    80004bba:	ffffc097          	auipc	ra,0xffffc
    80004bbe:	238080e7          	jalr	568(ra) # 80000df2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bc2:	0003c497          	auipc	s1,0x3c
    80004bc6:	27648493          	addi	s1,s1,630 # 80040e38 <ftable+0x18>
    80004bca:	0003d717          	auipc	a4,0x3d
    80004bce:	20e70713          	addi	a4,a4,526 # 80041dd8 <disk>
    if(f->ref == 0){
    80004bd2:	40dc                	lw	a5,4(s1)
    80004bd4:	cf99                	beqz	a5,80004bf2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bd6:	02848493          	addi	s1,s1,40
    80004bda:	fee49ce3          	bne	s1,a4,80004bd2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004bde:	0003c517          	auipc	a0,0x3c
    80004be2:	24250513          	addi	a0,a0,578 # 80040e20 <ftable>
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	2c0080e7          	jalr	704(ra) # 80000ea6 <release>
  return 0;
    80004bee:	4481                	li	s1,0
    80004bf0:	a819                	j	80004c06 <filealloc+0x5e>
      f->ref = 1;
    80004bf2:	4785                	li	a5,1
    80004bf4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004bf6:	0003c517          	auipc	a0,0x3c
    80004bfa:	22a50513          	addi	a0,a0,554 # 80040e20 <ftable>
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	2a8080e7          	jalr	680(ra) # 80000ea6 <release>
}
    80004c06:	8526                	mv	a0,s1
    80004c08:	60e2                	ld	ra,24(sp)
    80004c0a:	6442                	ld	s0,16(sp)
    80004c0c:	64a2                	ld	s1,8(sp)
    80004c0e:	6105                	addi	sp,sp,32
    80004c10:	8082                	ret

0000000080004c12 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c12:	1101                	addi	sp,sp,-32
    80004c14:	ec06                	sd	ra,24(sp)
    80004c16:	e822                	sd	s0,16(sp)
    80004c18:	e426                	sd	s1,8(sp)
    80004c1a:	1000                	addi	s0,sp,32
    80004c1c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c1e:	0003c517          	auipc	a0,0x3c
    80004c22:	20250513          	addi	a0,a0,514 # 80040e20 <ftable>
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	1cc080e7          	jalr	460(ra) # 80000df2 <acquire>
  if(f->ref < 1)
    80004c2e:	40dc                	lw	a5,4(s1)
    80004c30:	02f05263          	blez	a5,80004c54 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c34:	2785                	addiw	a5,a5,1
    80004c36:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c38:	0003c517          	auipc	a0,0x3c
    80004c3c:	1e850513          	addi	a0,a0,488 # 80040e20 <ftable>
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	266080e7          	jalr	614(ra) # 80000ea6 <release>
  return f;
}
    80004c48:	8526                	mv	a0,s1
    80004c4a:	60e2                	ld	ra,24(sp)
    80004c4c:	6442                	ld	s0,16(sp)
    80004c4e:	64a2                	ld	s1,8(sp)
    80004c50:	6105                	addi	sp,sp,32
    80004c52:	8082                	ret
    panic("filedup");
    80004c54:	00004517          	auipc	a0,0x4
    80004c58:	b9c50513          	addi	a0,a0,-1124 # 800087f0 <syscalls+0x268>
    80004c5c:	ffffc097          	auipc	ra,0xffffc
    80004c60:	8e4080e7          	jalr	-1820(ra) # 80000540 <panic>

0000000080004c64 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c64:	7139                	addi	sp,sp,-64
    80004c66:	fc06                	sd	ra,56(sp)
    80004c68:	f822                	sd	s0,48(sp)
    80004c6a:	f426                	sd	s1,40(sp)
    80004c6c:	f04a                	sd	s2,32(sp)
    80004c6e:	ec4e                	sd	s3,24(sp)
    80004c70:	e852                	sd	s4,16(sp)
    80004c72:	e456                	sd	s5,8(sp)
    80004c74:	0080                	addi	s0,sp,64
    80004c76:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c78:	0003c517          	auipc	a0,0x3c
    80004c7c:	1a850513          	addi	a0,a0,424 # 80040e20 <ftable>
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	172080e7          	jalr	370(ra) # 80000df2 <acquire>
  if(f->ref < 1)
    80004c88:	40dc                	lw	a5,4(s1)
    80004c8a:	06f05163          	blez	a5,80004cec <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c8e:	37fd                	addiw	a5,a5,-1
    80004c90:	0007871b          	sext.w	a4,a5
    80004c94:	c0dc                	sw	a5,4(s1)
    80004c96:	06e04363          	bgtz	a4,80004cfc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c9a:	0004a903          	lw	s2,0(s1)
    80004c9e:	0094ca83          	lbu	s5,9(s1)
    80004ca2:	0104ba03          	ld	s4,16(s1)
    80004ca6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004caa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cae:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004cb2:	0003c517          	auipc	a0,0x3c
    80004cb6:	16e50513          	addi	a0,a0,366 # 80040e20 <ftable>
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	1ec080e7          	jalr	492(ra) # 80000ea6 <release>

  if(ff.type == FD_PIPE){
    80004cc2:	4785                	li	a5,1
    80004cc4:	04f90d63          	beq	s2,a5,80004d1e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cc8:	3979                	addiw	s2,s2,-2
    80004cca:	4785                	li	a5,1
    80004ccc:	0527e063          	bltu	a5,s2,80004d0c <fileclose+0xa8>
    begin_op();
    80004cd0:	00000097          	auipc	ra,0x0
    80004cd4:	acc080e7          	jalr	-1332(ra) # 8000479c <begin_op>
    iput(ff.ip);
    80004cd8:	854e                	mv	a0,s3
    80004cda:	fffff097          	auipc	ra,0xfffff
    80004cde:	2b0080e7          	jalr	688(ra) # 80003f8a <iput>
    end_op();
    80004ce2:	00000097          	auipc	ra,0x0
    80004ce6:	b38080e7          	jalr	-1224(ra) # 8000481a <end_op>
    80004cea:	a00d                	j	80004d0c <fileclose+0xa8>
    panic("fileclose");
    80004cec:	00004517          	auipc	a0,0x4
    80004cf0:	b0c50513          	addi	a0,a0,-1268 # 800087f8 <syscalls+0x270>
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	84c080e7          	jalr	-1972(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004cfc:	0003c517          	auipc	a0,0x3c
    80004d00:	12450513          	addi	a0,a0,292 # 80040e20 <ftable>
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	1a2080e7          	jalr	418(ra) # 80000ea6 <release>
  }
}
    80004d0c:	70e2                	ld	ra,56(sp)
    80004d0e:	7442                	ld	s0,48(sp)
    80004d10:	74a2                	ld	s1,40(sp)
    80004d12:	7902                	ld	s2,32(sp)
    80004d14:	69e2                	ld	s3,24(sp)
    80004d16:	6a42                	ld	s4,16(sp)
    80004d18:	6aa2                	ld	s5,8(sp)
    80004d1a:	6121                	addi	sp,sp,64
    80004d1c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d1e:	85d6                	mv	a1,s5
    80004d20:	8552                	mv	a0,s4
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	34c080e7          	jalr	844(ra) # 8000506e <pipeclose>
    80004d2a:	b7cd                	j	80004d0c <fileclose+0xa8>

0000000080004d2c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d2c:	715d                	addi	sp,sp,-80
    80004d2e:	e486                	sd	ra,72(sp)
    80004d30:	e0a2                	sd	s0,64(sp)
    80004d32:	fc26                	sd	s1,56(sp)
    80004d34:	f84a                	sd	s2,48(sp)
    80004d36:	f44e                	sd	s3,40(sp)
    80004d38:	0880                	addi	s0,sp,80
    80004d3a:	84aa                	mv	s1,a0
    80004d3c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d3e:	ffffd097          	auipc	ra,0xffffd
    80004d42:	fc2080e7          	jalr	-62(ra) # 80001d00 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d46:	409c                	lw	a5,0(s1)
    80004d48:	37f9                	addiw	a5,a5,-2
    80004d4a:	4705                	li	a4,1
    80004d4c:	04f76763          	bltu	a4,a5,80004d9a <filestat+0x6e>
    80004d50:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d52:	6c88                	ld	a0,24(s1)
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	07c080e7          	jalr	124(ra) # 80003dd0 <ilock>
    stati(f->ip, &st);
    80004d5c:	fb840593          	addi	a1,s0,-72
    80004d60:	6c88                	ld	a0,24(s1)
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	2f8080e7          	jalr	760(ra) # 8000405a <stati>
    iunlock(f->ip);
    80004d6a:	6c88                	ld	a0,24(s1)
    80004d6c:	fffff097          	auipc	ra,0xfffff
    80004d70:	126080e7          	jalr	294(ra) # 80003e92 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d74:	46e1                	li	a3,24
    80004d76:	fb840613          	addi	a2,s0,-72
    80004d7a:	85ce                	mv	a1,s3
    80004d7c:	05093503          	ld	a0,80(s2)
    80004d80:	ffffd097          	auipc	ra,0xffffd
    80004d84:	ae6080e7          	jalr	-1306(ra) # 80001866 <copyout>
    80004d88:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d8c:	60a6                	ld	ra,72(sp)
    80004d8e:	6406                	ld	s0,64(sp)
    80004d90:	74e2                	ld	s1,56(sp)
    80004d92:	7942                	ld	s2,48(sp)
    80004d94:	79a2                	ld	s3,40(sp)
    80004d96:	6161                	addi	sp,sp,80
    80004d98:	8082                	ret
  return -1;
    80004d9a:	557d                	li	a0,-1
    80004d9c:	bfc5                	j	80004d8c <filestat+0x60>

0000000080004d9e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d9e:	7179                	addi	sp,sp,-48
    80004da0:	f406                	sd	ra,40(sp)
    80004da2:	f022                	sd	s0,32(sp)
    80004da4:	ec26                	sd	s1,24(sp)
    80004da6:	e84a                	sd	s2,16(sp)
    80004da8:	e44e                	sd	s3,8(sp)
    80004daa:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004dac:	00854783          	lbu	a5,8(a0)
    80004db0:	c3d5                	beqz	a5,80004e54 <fileread+0xb6>
    80004db2:	84aa                	mv	s1,a0
    80004db4:	89ae                	mv	s3,a1
    80004db6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004db8:	411c                	lw	a5,0(a0)
    80004dba:	4705                	li	a4,1
    80004dbc:	04e78963          	beq	a5,a4,80004e0e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dc0:	470d                	li	a4,3
    80004dc2:	04e78d63          	beq	a5,a4,80004e1c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dc6:	4709                	li	a4,2
    80004dc8:	06e79e63          	bne	a5,a4,80004e44 <fileread+0xa6>
    ilock(f->ip);
    80004dcc:	6d08                	ld	a0,24(a0)
    80004dce:	fffff097          	auipc	ra,0xfffff
    80004dd2:	002080e7          	jalr	2(ra) # 80003dd0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dd6:	874a                	mv	a4,s2
    80004dd8:	5094                	lw	a3,32(s1)
    80004dda:	864e                	mv	a2,s3
    80004ddc:	4585                	li	a1,1
    80004dde:	6c88                	ld	a0,24(s1)
    80004de0:	fffff097          	auipc	ra,0xfffff
    80004de4:	2a4080e7          	jalr	676(ra) # 80004084 <readi>
    80004de8:	892a                	mv	s2,a0
    80004dea:	00a05563          	blez	a0,80004df4 <fileread+0x56>
      f->off += r;
    80004dee:	509c                	lw	a5,32(s1)
    80004df0:	9fa9                	addw	a5,a5,a0
    80004df2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004df4:	6c88                	ld	a0,24(s1)
    80004df6:	fffff097          	auipc	ra,0xfffff
    80004dfa:	09c080e7          	jalr	156(ra) # 80003e92 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004dfe:	854a                	mv	a0,s2
    80004e00:	70a2                	ld	ra,40(sp)
    80004e02:	7402                	ld	s0,32(sp)
    80004e04:	64e2                	ld	s1,24(sp)
    80004e06:	6942                	ld	s2,16(sp)
    80004e08:	69a2                	ld	s3,8(sp)
    80004e0a:	6145                	addi	sp,sp,48
    80004e0c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e0e:	6908                	ld	a0,16(a0)
    80004e10:	00000097          	auipc	ra,0x0
    80004e14:	3c6080e7          	jalr	966(ra) # 800051d6 <piperead>
    80004e18:	892a                	mv	s2,a0
    80004e1a:	b7d5                	j	80004dfe <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e1c:	02451783          	lh	a5,36(a0)
    80004e20:	03079693          	slli	a3,a5,0x30
    80004e24:	92c1                	srli	a3,a3,0x30
    80004e26:	4725                	li	a4,9
    80004e28:	02d76863          	bltu	a4,a3,80004e58 <fileread+0xba>
    80004e2c:	0792                	slli	a5,a5,0x4
    80004e2e:	0003c717          	auipc	a4,0x3c
    80004e32:	f5270713          	addi	a4,a4,-174 # 80040d80 <devsw>
    80004e36:	97ba                	add	a5,a5,a4
    80004e38:	639c                	ld	a5,0(a5)
    80004e3a:	c38d                	beqz	a5,80004e5c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e3c:	4505                	li	a0,1
    80004e3e:	9782                	jalr	a5
    80004e40:	892a                	mv	s2,a0
    80004e42:	bf75                	j	80004dfe <fileread+0x60>
    panic("fileread");
    80004e44:	00004517          	auipc	a0,0x4
    80004e48:	9c450513          	addi	a0,a0,-1596 # 80008808 <syscalls+0x280>
    80004e4c:	ffffb097          	auipc	ra,0xffffb
    80004e50:	6f4080e7          	jalr	1780(ra) # 80000540 <panic>
    return -1;
    80004e54:	597d                	li	s2,-1
    80004e56:	b765                	j	80004dfe <fileread+0x60>
      return -1;
    80004e58:	597d                	li	s2,-1
    80004e5a:	b755                	j	80004dfe <fileread+0x60>
    80004e5c:	597d                	li	s2,-1
    80004e5e:	b745                	j	80004dfe <fileread+0x60>

0000000080004e60 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e60:	715d                	addi	sp,sp,-80
    80004e62:	e486                	sd	ra,72(sp)
    80004e64:	e0a2                	sd	s0,64(sp)
    80004e66:	fc26                	sd	s1,56(sp)
    80004e68:	f84a                	sd	s2,48(sp)
    80004e6a:	f44e                	sd	s3,40(sp)
    80004e6c:	f052                	sd	s4,32(sp)
    80004e6e:	ec56                	sd	s5,24(sp)
    80004e70:	e85a                	sd	s6,16(sp)
    80004e72:	e45e                	sd	s7,8(sp)
    80004e74:	e062                	sd	s8,0(sp)
    80004e76:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e78:	00954783          	lbu	a5,9(a0)
    80004e7c:	10078663          	beqz	a5,80004f88 <filewrite+0x128>
    80004e80:	892a                	mv	s2,a0
    80004e82:	8b2e                	mv	s6,a1
    80004e84:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e86:	411c                	lw	a5,0(a0)
    80004e88:	4705                	li	a4,1
    80004e8a:	02e78263          	beq	a5,a4,80004eae <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e8e:	470d                	li	a4,3
    80004e90:	02e78663          	beq	a5,a4,80004ebc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e94:	4709                	li	a4,2
    80004e96:	0ee79163          	bne	a5,a4,80004f78 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e9a:	0ac05d63          	blez	a2,80004f54 <filewrite+0xf4>
    int i = 0;
    80004e9e:	4981                	li	s3,0
    80004ea0:	6b85                	lui	s7,0x1
    80004ea2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ea6:	6c05                	lui	s8,0x1
    80004ea8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004eac:	a861                	j	80004f44 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004eae:	6908                	ld	a0,16(a0)
    80004eb0:	00000097          	auipc	ra,0x0
    80004eb4:	22e080e7          	jalr	558(ra) # 800050de <pipewrite>
    80004eb8:	8a2a                	mv	s4,a0
    80004eba:	a045                	j	80004f5a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ebc:	02451783          	lh	a5,36(a0)
    80004ec0:	03079693          	slli	a3,a5,0x30
    80004ec4:	92c1                	srli	a3,a3,0x30
    80004ec6:	4725                	li	a4,9
    80004ec8:	0cd76263          	bltu	a4,a3,80004f8c <filewrite+0x12c>
    80004ecc:	0792                	slli	a5,a5,0x4
    80004ece:	0003c717          	auipc	a4,0x3c
    80004ed2:	eb270713          	addi	a4,a4,-334 # 80040d80 <devsw>
    80004ed6:	97ba                	add	a5,a5,a4
    80004ed8:	679c                	ld	a5,8(a5)
    80004eda:	cbdd                	beqz	a5,80004f90 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004edc:	4505                	li	a0,1
    80004ede:	9782                	jalr	a5
    80004ee0:	8a2a                	mv	s4,a0
    80004ee2:	a8a5                	j	80004f5a <filewrite+0xfa>
    80004ee4:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ee8:	00000097          	auipc	ra,0x0
    80004eec:	8b4080e7          	jalr	-1868(ra) # 8000479c <begin_op>
      ilock(f->ip);
    80004ef0:	01893503          	ld	a0,24(s2)
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	edc080e7          	jalr	-292(ra) # 80003dd0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004efc:	8756                	mv	a4,s5
    80004efe:	02092683          	lw	a3,32(s2)
    80004f02:	01698633          	add	a2,s3,s6
    80004f06:	4585                	li	a1,1
    80004f08:	01893503          	ld	a0,24(s2)
    80004f0c:	fffff097          	auipc	ra,0xfffff
    80004f10:	270080e7          	jalr	624(ra) # 8000417c <writei>
    80004f14:	84aa                	mv	s1,a0
    80004f16:	00a05763          	blez	a0,80004f24 <filewrite+0xc4>
        f->off += r;
    80004f1a:	02092783          	lw	a5,32(s2)
    80004f1e:	9fa9                	addw	a5,a5,a0
    80004f20:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f24:	01893503          	ld	a0,24(s2)
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	f6a080e7          	jalr	-150(ra) # 80003e92 <iunlock>
      end_op();
    80004f30:	00000097          	auipc	ra,0x0
    80004f34:	8ea080e7          	jalr	-1814(ra) # 8000481a <end_op>

      if(r != n1){
    80004f38:	009a9f63          	bne	s5,s1,80004f56 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004f3c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f40:	0149db63          	bge	s3,s4,80004f56 <filewrite+0xf6>
      int n1 = n - i;
    80004f44:	413a04bb          	subw	s1,s4,s3
    80004f48:	0004879b          	sext.w	a5,s1
    80004f4c:	f8fbdce3          	bge	s7,a5,80004ee4 <filewrite+0x84>
    80004f50:	84e2                	mv	s1,s8
    80004f52:	bf49                	j	80004ee4 <filewrite+0x84>
    int i = 0;
    80004f54:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f56:	013a1f63          	bne	s4,s3,80004f74 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f5a:	8552                	mv	a0,s4
    80004f5c:	60a6                	ld	ra,72(sp)
    80004f5e:	6406                	ld	s0,64(sp)
    80004f60:	74e2                	ld	s1,56(sp)
    80004f62:	7942                	ld	s2,48(sp)
    80004f64:	79a2                	ld	s3,40(sp)
    80004f66:	7a02                	ld	s4,32(sp)
    80004f68:	6ae2                	ld	s5,24(sp)
    80004f6a:	6b42                	ld	s6,16(sp)
    80004f6c:	6ba2                	ld	s7,8(sp)
    80004f6e:	6c02                	ld	s8,0(sp)
    80004f70:	6161                	addi	sp,sp,80
    80004f72:	8082                	ret
    ret = (i == n ? n : -1);
    80004f74:	5a7d                	li	s4,-1
    80004f76:	b7d5                	j	80004f5a <filewrite+0xfa>
    panic("filewrite");
    80004f78:	00004517          	auipc	a0,0x4
    80004f7c:	8a050513          	addi	a0,a0,-1888 # 80008818 <syscalls+0x290>
    80004f80:	ffffb097          	auipc	ra,0xffffb
    80004f84:	5c0080e7          	jalr	1472(ra) # 80000540 <panic>
    return -1;
    80004f88:	5a7d                	li	s4,-1
    80004f8a:	bfc1                	j	80004f5a <filewrite+0xfa>
      return -1;
    80004f8c:	5a7d                	li	s4,-1
    80004f8e:	b7f1                	j	80004f5a <filewrite+0xfa>
    80004f90:	5a7d                	li	s4,-1
    80004f92:	b7e1                	j	80004f5a <filewrite+0xfa>

0000000080004f94 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f94:	7179                	addi	sp,sp,-48
    80004f96:	f406                	sd	ra,40(sp)
    80004f98:	f022                	sd	s0,32(sp)
    80004f9a:	ec26                	sd	s1,24(sp)
    80004f9c:	e84a                	sd	s2,16(sp)
    80004f9e:	e44e                	sd	s3,8(sp)
    80004fa0:	e052                	sd	s4,0(sp)
    80004fa2:	1800                	addi	s0,sp,48
    80004fa4:	84aa                	mv	s1,a0
    80004fa6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004fa8:	0005b023          	sd	zero,0(a1)
    80004fac:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fb0:	00000097          	auipc	ra,0x0
    80004fb4:	bf8080e7          	jalr	-1032(ra) # 80004ba8 <filealloc>
    80004fb8:	e088                	sd	a0,0(s1)
    80004fba:	c551                	beqz	a0,80005046 <pipealloc+0xb2>
    80004fbc:	00000097          	auipc	ra,0x0
    80004fc0:	bec080e7          	jalr	-1044(ra) # 80004ba8 <filealloc>
    80004fc4:	00aa3023          	sd	a0,0(s4)
    80004fc8:	c92d                	beqz	a0,8000503a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004fca:	ffffc097          	auipc	ra,0xffffc
    80004fce:	c9e080e7          	jalr	-866(ra) # 80000c68 <kalloc>
    80004fd2:	892a                	mv	s2,a0
    80004fd4:	c125                	beqz	a0,80005034 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004fd6:	4985                	li	s3,1
    80004fd8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fdc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fe0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fe4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fe8:	00004597          	auipc	a1,0x4
    80004fec:	84058593          	addi	a1,a1,-1984 # 80008828 <syscalls+0x2a0>
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	d72080e7          	jalr	-654(ra) # 80000d62 <initlock>
  (*f0)->type = FD_PIPE;
    80004ff8:	609c                	ld	a5,0(s1)
    80004ffa:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ffe:	609c                	ld	a5,0(s1)
    80005000:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005004:	609c                	ld	a5,0(s1)
    80005006:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000500a:	609c                	ld	a5,0(s1)
    8000500c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005010:	000a3783          	ld	a5,0(s4)
    80005014:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005018:	000a3783          	ld	a5,0(s4)
    8000501c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005020:	000a3783          	ld	a5,0(s4)
    80005024:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005028:	000a3783          	ld	a5,0(s4)
    8000502c:	0127b823          	sd	s2,16(a5)
  return 0;
    80005030:	4501                	li	a0,0
    80005032:	a025                	j	8000505a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005034:	6088                	ld	a0,0(s1)
    80005036:	e501                	bnez	a0,8000503e <pipealloc+0xaa>
    80005038:	a039                	j	80005046 <pipealloc+0xb2>
    8000503a:	6088                	ld	a0,0(s1)
    8000503c:	c51d                	beqz	a0,8000506a <pipealloc+0xd6>
    fileclose(*f0);
    8000503e:	00000097          	auipc	ra,0x0
    80005042:	c26080e7          	jalr	-986(ra) # 80004c64 <fileclose>
  if(*f1)
    80005046:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000504a:	557d                	li	a0,-1
  if(*f1)
    8000504c:	c799                	beqz	a5,8000505a <pipealloc+0xc6>
    fileclose(*f1);
    8000504e:	853e                	mv	a0,a5
    80005050:	00000097          	auipc	ra,0x0
    80005054:	c14080e7          	jalr	-1004(ra) # 80004c64 <fileclose>
  return -1;
    80005058:	557d                	li	a0,-1
}
    8000505a:	70a2                	ld	ra,40(sp)
    8000505c:	7402                	ld	s0,32(sp)
    8000505e:	64e2                	ld	s1,24(sp)
    80005060:	6942                	ld	s2,16(sp)
    80005062:	69a2                	ld	s3,8(sp)
    80005064:	6a02                	ld	s4,0(sp)
    80005066:	6145                	addi	sp,sp,48
    80005068:	8082                	ret
  return -1;
    8000506a:	557d                	li	a0,-1
    8000506c:	b7fd                	j	8000505a <pipealloc+0xc6>

000000008000506e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000506e:	1101                	addi	sp,sp,-32
    80005070:	ec06                	sd	ra,24(sp)
    80005072:	e822                	sd	s0,16(sp)
    80005074:	e426                	sd	s1,8(sp)
    80005076:	e04a                	sd	s2,0(sp)
    80005078:	1000                	addi	s0,sp,32
    8000507a:	84aa                	mv	s1,a0
    8000507c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000507e:	ffffc097          	auipc	ra,0xffffc
    80005082:	d74080e7          	jalr	-652(ra) # 80000df2 <acquire>
  if(writable){
    80005086:	02090d63          	beqz	s2,800050c0 <pipeclose+0x52>
    pi->writeopen = 0;
    8000508a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000508e:	21848513          	addi	a0,s1,536
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	480080e7          	jalr	1152(ra) # 80002512 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000509a:	2204b783          	ld	a5,544(s1)
    8000509e:	eb95                	bnez	a5,800050d2 <pipeclose+0x64>
    release(&pi->lock);
    800050a0:	8526                	mv	a0,s1
    800050a2:	ffffc097          	auipc	ra,0xffffc
    800050a6:	e04080e7          	jalr	-508(ra) # 80000ea6 <release>
    kfree((char*)pi);
    800050aa:	8526                	mv	a0,s1
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	9ca080e7          	jalr	-1590(ra) # 80000a76 <kfree>
  } else
    release(&pi->lock);
}
    800050b4:	60e2                	ld	ra,24(sp)
    800050b6:	6442                	ld	s0,16(sp)
    800050b8:	64a2                	ld	s1,8(sp)
    800050ba:	6902                	ld	s2,0(sp)
    800050bc:	6105                	addi	sp,sp,32
    800050be:	8082                	ret
    pi->readopen = 0;
    800050c0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050c4:	21c48513          	addi	a0,s1,540
    800050c8:	ffffd097          	auipc	ra,0xffffd
    800050cc:	44a080e7          	jalr	1098(ra) # 80002512 <wakeup>
    800050d0:	b7e9                	j	8000509a <pipeclose+0x2c>
    release(&pi->lock);
    800050d2:	8526                	mv	a0,s1
    800050d4:	ffffc097          	auipc	ra,0xffffc
    800050d8:	dd2080e7          	jalr	-558(ra) # 80000ea6 <release>
}
    800050dc:	bfe1                	j	800050b4 <pipeclose+0x46>

00000000800050de <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800050de:	711d                	addi	sp,sp,-96
    800050e0:	ec86                	sd	ra,88(sp)
    800050e2:	e8a2                	sd	s0,80(sp)
    800050e4:	e4a6                	sd	s1,72(sp)
    800050e6:	e0ca                	sd	s2,64(sp)
    800050e8:	fc4e                	sd	s3,56(sp)
    800050ea:	f852                	sd	s4,48(sp)
    800050ec:	f456                	sd	s5,40(sp)
    800050ee:	f05a                	sd	s6,32(sp)
    800050f0:	ec5e                	sd	s7,24(sp)
    800050f2:	e862                	sd	s8,16(sp)
    800050f4:	1080                	addi	s0,sp,96
    800050f6:	84aa                	mv	s1,a0
    800050f8:	8aae                	mv	s5,a1
    800050fa:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	c04080e7          	jalr	-1020(ra) # 80001d00 <myproc>
    80005104:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005106:	8526                	mv	a0,s1
    80005108:	ffffc097          	auipc	ra,0xffffc
    8000510c:	cea080e7          	jalr	-790(ra) # 80000df2 <acquire>
  while(i < n){
    80005110:	0b405663          	blez	s4,800051bc <pipewrite+0xde>
  int i = 0;
    80005114:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005116:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005118:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000511c:	21c48b93          	addi	s7,s1,540
    80005120:	a089                	j	80005162 <pipewrite+0x84>
      release(&pi->lock);
    80005122:	8526                	mv	a0,s1
    80005124:	ffffc097          	auipc	ra,0xffffc
    80005128:	d82080e7          	jalr	-638(ra) # 80000ea6 <release>
      return -1;
    8000512c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000512e:	854a                	mv	a0,s2
    80005130:	60e6                	ld	ra,88(sp)
    80005132:	6446                	ld	s0,80(sp)
    80005134:	64a6                	ld	s1,72(sp)
    80005136:	6906                	ld	s2,64(sp)
    80005138:	79e2                	ld	s3,56(sp)
    8000513a:	7a42                	ld	s4,48(sp)
    8000513c:	7aa2                	ld	s5,40(sp)
    8000513e:	7b02                	ld	s6,32(sp)
    80005140:	6be2                	ld	s7,24(sp)
    80005142:	6c42                	ld	s8,16(sp)
    80005144:	6125                	addi	sp,sp,96
    80005146:	8082                	ret
      wakeup(&pi->nread);
    80005148:	8562                	mv	a0,s8
    8000514a:	ffffd097          	auipc	ra,0xffffd
    8000514e:	3c8080e7          	jalr	968(ra) # 80002512 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005152:	85a6                	mv	a1,s1
    80005154:	855e                	mv	a0,s7
    80005156:	ffffd097          	auipc	ra,0xffffd
    8000515a:	358080e7          	jalr	856(ra) # 800024ae <sleep>
  while(i < n){
    8000515e:	07495063          	bge	s2,s4,800051be <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005162:	2204a783          	lw	a5,544(s1)
    80005166:	dfd5                	beqz	a5,80005122 <pipewrite+0x44>
    80005168:	854e                	mv	a0,s3
    8000516a:	ffffd097          	auipc	ra,0xffffd
    8000516e:	5ec080e7          	jalr	1516(ra) # 80002756 <killed>
    80005172:	f945                	bnez	a0,80005122 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005174:	2184a783          	lw	a5,536(s1)
    80005178:	21c4a703          	lw	a4,540(s1)
    8000517c:	2007879b          	addiw	a5,a5,512
    80005180:	fcf704e3          	beq	a4,a5,80005148 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005184:	4685                	li	a3,1
    80005186:	01590633          	add	a2,s2,s5
    8000518a:	faf40593          	addi	a1,s0,-81
    8000518e:	0509b503          	ld	a0,80(s3)
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	760080e7          	jalr	1888(ra) # 800018f2 <copyin>
    8000519a:	03650263          	beq	a0,s6,800051be <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000519e:	21c4a783          	lw	a5,540(s1)
    800051a2:	0017871b          	addiw	a4,a5,1
    800051a6:	20e4ae23          	sw	a4,540(s1)
    800051aa:	1ff7f793          	andi	a5,a5,511
    800051ae:	97a6                	add	a5,a5,s1
    800051b0:	faf44703          	lbu	a4,-81(s0)
    800051b4:	00e78c23          	sb	a4,24(a5)
      i++;
    800051b8:	2905                	addiw	s2,s2,1
    800051ba:	b755                	j	8000515e <pipewrite+0x80>
  int i = 0;
    800051bc:	4901                	li	s2,0
  wakeup(&pi->nread);
    800051be:	21848513          	addi	a0,s1,536
    800051c2:	ffffd097          	auipc	ra,0xffffd
    800051c6:	350080e7          	jalr	848(ra) # 80002512 <wakeup>
  release(&pi->lock);
    800051ca:	8526                	mv	a0,s1
    800051cc:	ffffc097          	auipc	ra,0xffffc
    800051d0:	cda080e7          	jalr	-806(ra) # 80000ea6 <release>
  return i;
    800051d4:	bfa9                	j	8000512e <pipewrite+0x50>

00000000800051d6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800051d6:	715d                	addi	sp,sp,-80
    800051d8:	e486                	sd	ra,72(sp)
    800051da:	e0a2                	sd	s0,64(sp)
    800051dc:	fc26                	sd	s1,56(sp)
    800051de:	f84a                	sd	s2,48(sp)
    800051e0:	f44e                	sd	s3,40(sp)
    800051e2:	f052                	sd	s4,32(sp)
    800051e4:	ec56                	sd	s5,24(sp)
    800051e6:	e85a                	sd	s6,16(sp)
    800051e8:	0880                	addi	s0,sp,80
    800051ea:	84aa                	mv	s1,a0
    800051ec:	892e                	mv	s2,a1
    800051ee:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800051f0:	ffffd097          	auipc	ra,0xffffd
    800051f4:	b10080e7          	jalr	-1264(ra) # 80001d00 <myproc>
    800051f8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051fa:	8526                	mv	a0,s1
    800051fc:	ffffc097          	auipc	ra,0xffffc
    80005200:	bf6080e7          	jalr	-1034(ra) # 80000df2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005204:	2184a703          	lw	a4,536(s1)
    80005208:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000520c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005210:	02f71763          	bne	a4,a5,8000523e <piperead+0x68>
    80005214:	2244a783          	lw	a5,548(s1)
    80005218:	c39d                	beqz	a5,8000523e <piperead+0x68>
    if(killed(pr)){
    8000521a:	8552                	mv	a0,s4
    8000521c:	ffffd097          	auipc	ra,0xffffd
    80005220:	53a080e7          	jalr	1338(ra) # 80002756 <killed>
    80005224:	e949                	bnez	a0,800052b6 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005226:	85a6                	mv	a1,s1
    80005228:	854e                	mv	a0,s3
    8000522a:	ffffd097          	auipc	ra,0xffffd
    8000522e:	284080e7          	jalr	644(ra) # 800024ae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005232:	2184a703          	lw	a4,536(s1)
    80005236:	21c4a783          	lw	a5,540(s1)
    8000523a:	fcf70de3          	beq	a4,a5,80005214 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000523e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005240:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005242:	05505463          	blez	s5,8000528a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005246:	2184a783          	lw	a5,536(s1)
    8000524a:	21c4a703          	lw	a4,540(s1)
    8000524e:	02f70e63          	beq	a4,a5,8000528a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005252:	0017871b          	addiw	a4,a5,1
    80005256:	20e4ac23          	sw	a4,536(s1)
    8000525a:	1ff7f793          	andi	a5,a5,511
    8000525e:	97a6                	add	a5,a5,s1
    80005260:	0187c783          	lbu	a5,24(a5)
    80005264:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005268:	4685                	li	a3,1
    8000526a:	fbf40613          	addi	a2,s0,-65
    8000526e:	85ca                	mv	a1,s2
    80005270:	050a3503          	ld	a0,80(s4)
    80005274:	ffffc097          	auipc	ra,0xffffc
    80005278:	5f2080e7          	jalr	1522(ra) # 80001866 <copyout>
    8000527c:	01650763          	beq	a0,s6,8000528a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005280:	2985                	addiw	s3,s3,1
    80005282:	0905                	addi	s2,s2,1
    80005284:	fd3a91e3          	bne	s5,s3,80005246 <piperead+0x70>
    80005288:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000528a:	21c48513          	addi	a0,s1,540
    8000528e:	ffffd097          	auipc	ra,0xffffd
    80005292:	284080e7          	jalr	644(ra) # 80002512 <wakeup>
  release(&pi->lock);
    80005296:	8526                	mv	a0,s1
    80005298:	ffffc097          	auipc	ra,0xffffc
    8000529c:	c0e080e7          	jalr	-1010(ra) # 80000ea6 <release>
  return i;
}
    800052a0:	854e                	mv	a0,s3
    800052a2:	60a6                	ld	ra,72(sp)
    800052a4:	6406                	ld	s0,64(sp)
    800052a6:	74e2                	ld	s1,56(sp)
    800052a8:	7942                	ld	s2,48(sp)
    800052aa:	79a2                	ld	s3,40(sp)
    800052ac:	7a02                	ld	s4,32(sp)
    800052ae:	6ae2                	ld	s5,24(sp)
    800052b0:	6b42                	ld	s6,16(sp)
    800052b2:	6161                	addi	sp,sp,80
    800052b4:	8082                	ret
      release(&pi->lock);
    800052b6:	8526                	mv	a0,s1
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	bee080e7          	jalr	-1042(ra) # 80000ea6 <release>
      return -1;
    800052c0:	59fd                	li	s3,-1
    800052c2:	bff9                	j	800052a0 <piperead+0xca>

00000000800052c4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800052c4:	1141                	addi	sp,sp,-16
    800052c6:	e422                	sd	s0,8(sp)
    800052c8:	0800                	addi	s0,sp,16
    800052ca:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800052cc:	8905                	andi	a0,a0,1
    800052ce:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800052d0:	8b89                	andi	a5,a5,2
    800052d2:	c399                	beqz	a5,800052d8 <flags2perm+0x14>
      perm |= PTE_W;
    800052d4:	00456513          	ori	a0,a0,4
    return perm;
}
    800052d8:	6422                	ld	s0,8(sp)
    800052da:	0141                	addi	sp,sp,16
    800052dc:	8082                	ret

00000000800052de <exec>:

int
exec(char *path, char **argv)
{
    800052de:	de010113          	addi	sp,sp,-544
    800052e2:	20113c23          	sd	ra,536(sp)
    800052e6:	20813823          	sd	s0,528(sp)
    800052ea:	20913423          	sd	s1,520(sp)
    800052ee:	21213023          	sd	s2,512(sp)
    800052f2:	ffce                	sd	s3,504(sp)
    800052f4:	fbd2                	sd	s4,496(sp)
    800052f6:	f7d6                	sd	s5,488(sp)
    800052f8:	f3da                	sd	s6,480(sp)
    800052fa:	efde                	sd	s7,472(sp)
    800052fc:	ebe2                	sd	s8,464(sp)
    800052fe:	e7e6                	sd	s9,456(sp)
    80005300:	e3ea                	sd	s10,448(sp)
    80005302:	ff6e                	sd	s11,440(sp)
    80005304:	1400                	addi	s0,sp,544
    80005306:	892a                	mv	s2,a0
    80005308:	dea43423          	sd	a0,-536(s0)
    8000530c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005310:	ffffd097          	auipc	ra,0xffffd
    80005314:	9f0080e7          	jalr	-1552(ra) # 80001d00 <myproc>
    80005318:	84aa                	mv	s1,a0

  begin_op();
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	482080e7          	jalr	1154(ra) # 8000479c <begin_op>

  if((ip = namei(path)) == 0){
    80005322:	854a                	mv	a0,s2
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	258080e7          	jalr	600(ra) # 8000457c <namei>
    8000532c:	c93d                	beqz	a0,800053a2 <exec+0xc4>
    8000532e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	aa0080e7          	jalr	-1376(ra) # 80003dd0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005338:	04000713          	li	a4,64
    8000533c:	4681                	li	a3,0
    8000533e:	e5040613          	addi	a2,s0,-432
    80005342:	4581                	li	a1,0
    80005344:	8556                	mv	a0,s5
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	d3e080e7          	jalr	-706(ra) # 80004084 <readi>
    8000534e:	04000793          	li	a5,64
    80005352:	00f51a63          	bne	a0,a5,80005366 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005356:	e5042703          	lw	a4,-432(s0)
    8000535a:	464c47b7          	lui	a5,0x464c4
    8000535e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005362:	04f70663          	beq	a4,a5,800053ae <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005366:	8556                	mv	a0,s5
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	cca080e7          	jalr	-822(ra) # 80004032 <iunlockput>
    end_op();
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	4aa080e7          	jalr	1194(ra) # 8000481a <end_op>
  }
  return -1;
    80005378:	557d                	li	a0,-1
}
    8000537a:	21813083          	ld	ra,536(sp)
    8000537e:	21013403          	ld	s0,528(sp)
    80005382:	20813483          	ld	s1,520(sp)
    80005386:	20013903          	ld	s2,512(sp)
    8000538a:	79fe                	ld	s3,504(sp)
    8000538c:	7a5e                	ld	s4,496(sp)
    8000538e:	7abe                	ld	s5,488(sp)
    80005390:	7b1e                	ld	s6,480(sp)
    80005392:	6bfe                	ld	s7,472(sp)
    80005394:	6c5e                	ld	s8,464(sp)
    80005396:	6cbe                	ld	s9,456(sp)
    80005398:	6d1e                	ld	s10,448(sp)
    8000539a:	7dfa                	ld	s11,440(sp)
    8000539c:	22010113          	addi	sp,sp,544
    800053a0:	8082                	ret
    end_op();
    800053a2:	fffff097          	auipc	ra,0xfffff
    800053a6:	478080e7          	jalr	1144(ra) # 8000481a <end_op>
    return -1;
    800053aa:	557d                	li	a0,-1
    800053ac:	b7f9                	j	8000537a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800053ae:	8526                	mv	a0,s1
    800053b0:	ffffd097          	auipc	ra,0xffffd
    800053b4:	a14080e7          	jalr	-1516(ra) # 80001dc4 <proc_pagetable>
    800053b8:	8b2a                	mv	s6,a0
    800053ba:	d555                	beqz	a0,80005366 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053bc:	e7042783          	lw	a5,-400(s0)
    800053c0:	e8845703          	lhu	a4,-376(s0)
    800053c4:	c735                	beqz	a4,80005430 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053c6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053c8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800053cc:	6a05                	lui	s4,0x1
    800053ce:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800053d2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800053d6:	6d85                	lui	s11,0x1
    800053d8:	7d7d                	lui	s10,0xfffff
    800053da:	ac3d                	j	80005618 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800053dc:	00003517          	auipc	a0,0x3
    800053e0:	45450513          	addi	a0,a0,1108 # 80008830 <syscalls+0x2a8>
    800053e4:	ffffb097          	auipc	ra,0xffffb
    800053e8:	15c080e7          	jalr	348(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800053ec:	874a                	mv	a4,s2
    800053ee:	009c86bb          	addw	a3,s9,s1
    800053f2:	4581                	li	a1,0
    800053f4:	8556                	mv	a0,s5
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	c8e080e7          	jalr	-882(ra) # 80004084 <readi>
    800053fe:	2501                	sext.w	a0,a0
    80005400:	1aa91963          	bne	s2,a0,800055b2 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005404:	009d84bb          	addw	s1,s11,s1
    80005408:	013d09bb          	addw	s3,s10,s3
    8000540c:	1f74f663          	bgeu	s1,s7,800055f8 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005410:	02049593          	slli	a1,s1,0x20
    80005414:	9181                	srli	a1,a1,0x20
    80005416:	95e2                	add	a1,a1,s8
    80005418:	855a                	mv	a0,s6
    8000541a:	ffffc097          	auipc	ra,0xffffc
    8000541e:	e5e080e7          	jalr	-418(ra) # 80001278 <walkaddr>
    80005422:	862a                	mv	a2,a0
    if(pa == 0)
    80005424:	dd45                	beqz	a0,800053dc <exec+0xfe>
      n = PGSIZE;
    80005426:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005428:	fd49f2e3          	bgeu	s3,s4,800053ec <exec+0x10e>
      n = sz - i;
    8000542c:	894e                	mv	s2,s3
    8000542e:	bf7d                	j	800053ec <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005430:	4901                	li	s2,0
  iunlockput(ip);
    80005432:	8556                	mv	a0,s5
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	bfe080e7          	jalr	-1026(ra) # 80004032 <iunlockput>
  end_op();
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	3de080e7          	jalr	990(ra) # 8000481a <end_op>
  p = myproc();
    80005444:	ffffd097          	auipc	ra,0xffffd
    80005448:	8bc080e7          	jalr	-1860(ra) # 80001d00 <myproc>
    8000544c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000544e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005452:	6785                	lui	a5,0x1
    80005454:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005456:	97ca                	add	a5,a5,s2
    80005458:	777d                	lui	a4,0xfffff
    8000545a:	8ff9                	and	a5,a5,a4
    8000545c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005460:	4691                	li	a3,4
    80005462:	6609                	lui	a2,0x2
    80005464:	963e                	add	a2,a2,a5
    80005466:	85be                	mv	a1,a5
    80005468:	855a                	mv	a0,s6
    8000546a:	ffffc097          	auipc	ra,0xffffc
    8000546e:	1c2080e7          	jalr	450(ra) # 8000162c <uvmalloc>
    80005472:	8c2a                	mv	s8,a0
  ip = 0;
    80005474:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005476:	12050e63          	beqz	a0,800055b2 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000547a:	75f9                	lui	a1,0xffffe
    8000547c:	95aa                	add	a1,a1,a0
    8000547e:	855a                	mv	a0,s6
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	3b4080e7          	jalr	948(ra) # 80001834 <uvmclear>
  stackbase = sp - PGSIZE;
    80005488:	7afd                	lui	s5,0xfffff
    8000548a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000548c:	df043783          	ld	a5,-528(s0)
    80005490:	6388                	ld	a0,0(a5)
    80005492:	c925                	beqz	a0,80005502 <exec+0x224>
    80005494:	e9040993          	addi	s3,s0,-368
    80005498:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000549c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000549e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054a0:	ffffc097          	auipc	ra,0xffffc
    800054a4:	bca080e7          	jalr	-1078(ra) # 8000106a <strlen>
    800054a8:	0015079b          	addiw	a5,a0,1
    800054ac:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054b0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800054b4:	13596663          	bltu	s2,s5,800055e0 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054b8:	df043d83          	ld	s11,-528(s0)
    800054bc:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800054c0:	8552                	mv	a0,s4
    800054c2:	ffffc097          	auipc	ra,0xffffc
    800054c6:	ba8080e7          	jalr	-1112(ra) # 8000106a <strlen>
    800054ca:	0015069b          	addiw	a3,a0,1
    800054ce:	8652                	mv	a2,s4
    800054d0:	85ca                	mv	a1,s2
    800054d2:	855a                	mv	a0,s6
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	392080e7          	jalr	914(ra) # 80001866 <copyout>
    800054dc:	10054663          	bltz	a0,800055e8 <exec+0x30a>
    ustack[argc] = sp;
    800054e0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800054e4:	0485                	addi	s1,s1,1
    800054e6:	008d8793          	addi	a5,s11,8
    800054ea:	def43823          	sd	a5,-528(s0)
    800054ee:	008db503          	ld	a0,8(s11)
    800054f2:	c911                	beqz	a0,80005506 <exec+0x228>
    if(argc >= MAXARG)
    800054f4:	09a1                	addi	s3,s3,8
    800054f6:	fb3c95e3          	bne	s9,s3,800054a0 <exec+0x1c2>
  sz = sz1;
    800054fa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054fe:	4a81                	li	s5,0
    80005500:	a84d                	j	800055b2 <exec+0x2d4>
  sp = sz;
    80005502:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005504:	4481                	li	s1,0
  ustack[argc] = 0;
    80005506:	00349793          	slli	a5,s1,0x3
    8000550a:	f9078793          	addi	a5,a5,-112
    8000550e:	97a2                	add	a5,a5,s0
    80005510:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005514:	00148693          	addi	a3,s1,1
    80005518:	068e                	slli	a3,a3,0x3
    8000551a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000551e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005522:	01597663          	bgeu	s2,s5,8000552e <exec+0x250>
  sz = sz1;
    80005526:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000552a:	4a81                	li	s5,0
    8000552c:	a059                	j	800055b2 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000552e:	e9040613          	addi	a2,s0,-368
    80005532:	85ca                	mv	a1,s2
    80005534:	855a                	mv	a0,s6
    80005536:	ffffc097          	auipc	ra,0xffffc
    8000553a:	330080e7          	jalr	816(ra) # 80001866 <copyout>
    8000553e:	0a054963          	bltz	a0,800055f0 <exec+0x312>
  p->trapframe->a1 = sp;
    80005542:	058bb783          	ld	a5,88(s7)
    80005546:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000554a:	de843783          	ld	a5,-536(s0)
    8000554e:	0007c703          	lbu	a4,0(a5)
    80005552:	cf11                	beqz	a4,8000556e <exec+0x290>
    80005554:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005556:	02f00693          	li	a3,47
    8000555a:	a039                	j	80005568 <exec+0x28a>
      last = s+1;
    8000555c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005560:	0785                	addi	a5,a5,1
    80005562:	fff7c703          	lbu	a4,-1(a5)
    80005566:	c701                	beqz	a4,8000556e <exec+0x290>
    if(*s == '/')
    80005568:	fed71ce3          	bne	a4,a3,80005560 <exec+0x282>
    8000556c:	bfc5                	j	8000555c <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000556e:	4641                	li	a2,16
    80005570:	de843583          	ld	a1,-536(s0)
    80005574:	158b8513          	addi	a0,s7,344
    80005578:	ffffc097          	auipc	ra,0xffffc
    8000557c:	ac0080e7          	jalr	-1344(ra) # 80001038 <safestrcpy>
  oldpagetable = p->pagetable;
    80005580:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005584:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005588:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000558c:	058bb783          	ld	a5,88(s7)
    80005590:	e6843703          	ld	a4,-408(s0)
    80005594:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005596:	058bb783          	ld	a5,88(s7)
    8000559a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000559e:	85ea                	mv	a1,s10
    800055a0:	ffffd097          	auipc	ra,0xffffd
    800055a4:	8c0080e7          	jalr	-1856(ra) # 80001e60 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055a8:	0004851b          	sext.w	a0,s1
    800055ac:	b3f9                	j	8000537a <exec+0x9c>
    800055ae:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800055b2:	df843583          	ld	a1,-520(s0)
    800055b6:	855a                	mv	a0,s6
    800055b8:	ffffd097          	auipc	ra,0xffffd
    800055bc:	8a8080e7          	jalr	-1880(ra) # 80001e60 <proc_freepagetable>
  if(ip){
    800055c0:	da0a93e3          	bnez	s5,80005366 <exec+0x88>
  return -1;
    800055c4:	557d                	li	a0,-1
    800055c6:	bb55                	j	8000537a <exec+0x9c>
    800055c8:	df243c23          	sd	s2,-520(s0)
    800055cc:	b7dd                	j	800055b2 <exec+0x2d4>
    800055ce:	df243c23          	sd	s2,-520(s0)
    800055d2:	b7c5                	j	800055b2 <exec+0x2d4>
    800055d4:	df243c23          	sd	s2,-520(s0)
    800055d8:	bfe9                	j	800055b2 <exec+0x2d4>
    800055da:	df243c23          	sd	s2,-520(s0)
    800055de:	bfd1                	j	800055b2 <exec+0x2d4>
  sz = sz1;
    800055e0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055e4:	4a81                	li	s5,0
    800055e6:	b7f1                	j	800055b2 <exec+0x2d4>
  sz = sz1;
    800055e8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055ec:	4a81                	li	s5,0
    800055ee:	b7d1                	j	800055b2 <exec+0x2d4>
  sz = sz1;
    800055f0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055f4:	4a81                	li	s5,0
    800055f6:	bf75                	j	800055b2 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055f8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055fc:	e0843783          	ld	a5,-504(s0)
    80005600:	0017869b          	addiw	a3,a5,1
    80005604:	e0d43423          	sd	a3,-504(s0)
    80005608:	e0043783          	ld	a5,-512(s0)
    8000560c:	0387879b          	addiw	a5,a5,56
    80005610:	e8845703          	lhu	a4,-376(s0)
    80005614:	e0e6dfe3          	bge	a3,a4,80005432 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005618:	2781                	sext.w	a5,a5
    8000561a:	e0f43023          	sd	a5,-512(s0)
    8000561e:	03800713          	li	a4,56
    80005622:	86be                	mv	a3,a5
    80005624:	e1840613          	addi	a2,s0,-488
    80005628:	4581                	li	a1,0
    8000562a:	8556                	mv	a0,s5
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	a58080e7          	jalr	-1448(ra) # 80004084 <readi>
    80005634:	03800793          	li	a5,56
    80005638:	f6f51be3          	bne	a0,a5,800055ae <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000563c:	e1842783          	lw	a5,-488(s0)
    80005640:	4705                	li	a4,1
    80005642:	fae79de3          	bne	a5,a4,800055fc <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005646:	e4043483          	ld	s1,-448(s0)
    8000564a:	e3843783          	ld	a5,-456(s0)
    8000564e:	f6f4ede3          	bltu	s1,a5,800055c8 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005652:	e2843783          	ld	a5,-472(s0)
    80005656:	94be                	add	s1,s1,a5
    80005658:	f6f4ebe3          	bltu	s1,a5,800055ce <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000565c:	de043703          	ld	a4,-544(s0)
    80005660:	8ff9                	and	a5,a5,a4
    80005662:	fbad                	bnez	a5,800055d4 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005664:	e1c42503          	lw	a0,-484(s0)
    80005668:	00000097          	auipc	ra,0x0
    8000566c:	c5c080e7          	jalr	-932(ra) # 800052c4 <flags2perm>
    80005670:	86aa                	mv	a3,a0
    80005672:	8626                	mv	a2,s1
    80005674:	85ca                	mv	a1,s2
    80005676:	855a                	mv	a0,s6
    80005678:	ffffc097          	auipc	ra,0xffffc
    8000567c:	fb4080e7          	jalr	-76(ra) # 8000162c <uvmalloc>
    80005680:	dea43c23          	sd	a0,-520(s0)
    80005684:	d939                	beqz	a0,800055da <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005686:	e2843c03          	ld	s8,-472(s0)
    8000568a:	e2042c83          	lw	s9,-480(s0)
    8000568e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005692:	f60b83e3          	beqz	s7,800055f8 <exec+0x31a>
    80005696:	89de                	mv	s3,s7
    80005698:	4481                	li	s1,0
    8000569a:	bb9d                	j	80005410 <exec+0x132>

000000008000569c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000569c:	7179                	addi	sp,sp,-48
    8000569e:	f406                	sd	ra,40(sp)
    800056a0:	f022                	sd	s0,32(sp)
    800056a2:	ec26                	sd	s1,24(sp)
    800056a4:	e84a                	sd	s2,16(sp)
    800056a6:	1800                	addi	s0,sp,48
    800056a8:	892e                	mv	s2,a1
    800056aa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800056ac:	fdc40593          	addi	a1,s0,-36
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	a8a080e7          	jalr	-1398(ra) # 8000313a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800056b8:	fdc42703          	lw	a4,-36(s0)
    800056bc:	47bd                	li	a5,15
    800056be:	02e7eb63          	bltu	a5,a4,800056f4 <argfd+0x58>
    800056c2:	ffffc097          	auipc	ra,0xffffc
    800056c6:	63e080e7          	jalr	1598(ra) # 80001d00 <myproc>
    800056ca:	fdc42703          	lw	a4,-36(s0)
    800056ce:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffbd102>
    800056d2:	078e                	slli	a5,a5,0x3
    800056d4:	953e                	add	a0,a0,a5
    800056d6:	611c                	ld	a5,0(a0)
    800056d8:	c385                	beqz	a5,800056f8 <argfd+0x5c>
    return -1;
  if(pfd)
    800056da:	00090463          	beqz	s2,800056e2 <argfd+0x46>
    *pfd = fd;
    800056de:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800056e2:	4501                	li	a0,0
  if(pf)
    800056e4:	c091                	beqz	s1,800056e8 <argfd+0x4c>
    *pf = f;
    800056e6:	e09c                	sd	a5,0(s1)
}
    800056e8:	70a2                	ld	ra,40(sp)
    800056ea:	7402                	ld	s0,32(sp)
    800056ec:	64e2                	ld	s1,24(sp)
    800056ee:	6942                	ld	s2,16(sp)
    800056f0:	6145                	addi	sp,sp,48
    800056f2:	8082                	ret
    return -1;
    800056f4:	557d                	li	a0,-1
    800056f6:	bfcd                	j	800056e8 <argfd+0x4c>
    800056f8:	557d                	li	a0,-1
    800056fa:	b7fd                	j	800056e8 <argfd+0x4c>

00000000800056fc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800056fc:	1101                	addi	sp,sp,-32
    800056fe:	ec06                	sd	ra,24(sp)
    80005700:	e822                	sd	s0,16(sp)
    80005702:	e426                	sd	s1,8(sp)
    80005704:	1000                	addi	s0,sp,32
    80005706:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005708:	ffffc097          	auipc	ra,0xffffc
    8000570c:	5f8080e7          	jalr	1528(ra) # 80001d00 <myproc>
    80005710:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005712:	0d050793          	addi	a5,a0,208
    80005716:	4501                	li	a0,0
    80005718:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000571a:	6398                	ld	a4,0(a5)
    8000571c:	cb19                	beqz	a4,80005732 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000571e:	2505                	addiw	a0,a0,1
    80005720:	07a1                	addi	a5,a5,8
    80005722:	fed51ce3          	bne	a0,a3,8000571a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005726:	557d                	li	a0,-1
}
    80005728:	60e2                	ld	ra,24(sp)
    8000572a:	6442                	ld	s0,16(sp)
    8000572c:	64a2                	ld	s1,8(sp)
    8000572e:	6105                	addi	sp,sp,32
    80005730:	8082                	ret
      p->ofile[fd] = f;
    80005732:	01a50793          	addi	a5,a0,26
    80005736:	078e                	slli	a5,a5,0x3
    80005738:	963e                	add	a2,a2,a5
    8000573a:	e204                	sd	s1,0(a2)
      return fd;
    8000573c:	b7f5                	j	80005728 <fdalloc+0x2c>

000000008000573e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000573e:	715d                	addi	sp,sp,-80
    80005740:	e486                	sd	ra,72(sp)
    80005742:	e0a2                	sd	s0,64(sp)
    80005744:	fc26                	sd	s1,56(sp)
    80005746:	f84a                	sd	s2,48(sp)
    80005748:	f44e                	sd	s3,40(sp)
    8000574a:	f052                	sd	s4,32(sp)
    8000574c:	ec56                	sd	s5,24(sp)
    8000574e:	e85a                	sd	s6,16(sp)
    80005750:	0880                	addi	s0,sp,80
    80005752:	8b2e                	mv	s6,a1
    80005754:	89b2                	mv	s3,a2
    80005756:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005758:	fb040593          	addi	a1,s0,-80
    8000575c:	fffff097          	auipc	ra,0xfffff
    80005760:	e3e080e7          	jalr	-450(ra) # 8000459a <nameiparent>
    80005764:	84aa                	mv	s1,a0
    80005766:	14050f63          	beqz	a0,800058c4 <create+0x186>
    return 0;

  ilock(dp);
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	666080e7          	jalr	1638(ra) # 80003dd0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005772:	4601                	li	a2,0
    80005774:	fb040593          	addi	a1,s0,-80
    80005778:	8526                	mv	a0,s1
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	b3a080e7          	jalr	-1222(ra) # 800042b4 <dirlookup>
    80005782:	8aaa                	mv	s5,a0
    80005784:	c931                	beqz	a0,800057d8 <create+0x9a>
    iunlockput(dp);
    80005786:	8526                	mv	a0,s1
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	8aa080e7          	jalr	-1878(ra) # 80004032 <iunlockput>
    ilock(ip);
    80005790:	8556                	mv	a0,s5
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	63e080e7          	jalr	1598(ra) # 80003dd0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000579a:	000b059b          	sext.w	a1,s6
    8000579e:	4789                	li	a5,2
    800057a0:	02f59563          	bne	a1,a5,800057ca <create+0x8c>
    800057a4:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffbd12c>
    800057a8:	37f9                	addiw	a5,a5,-2
    800057aa:	17c2                	slli	a5,a5,0x30
    800057ac:	93c1                	srli	a5,a5,0x30
    800057ae:	4705                	li	a4,1
    800057b0:	00f76d63          	bltu	a4,a5,800057ca <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800057b4:	8556                	mv	a0,s5
    800057b6:	60a6                	ld	ra,72(sp)
    800057b8:	6406                	ld	s0,64(sp)
    800057ba:	74e2                	ld	s1,56(sp)
    800057bc:	7942                	ld	s2,48(sp)
    800057be:	79a2                	ld	s3,40(sp)
    800057c0:	7a02                	ld	s4,32(sp)
    800057c2:	6ae2                	ld	s5,24(sp)
    800057c4:	6b42                	ld	s6,16(sp)
    800057c6:	6161                	addi	sp,sp,80
    800057c8:	8082                	ret
    iunlockput(ip);
    800057ca:	8556                	mv	a0,s5
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	866080e7          	jalr	-1946(ra) # 80004032 <iunlockput>
    return 0;
    800057d4:	4a81                	li	s5,0
    800057d6:	bff9                	j	800057b4 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800057d8:	85da                	mv	a1,s6
    800057da:	4088                	lw	a0,0(s1)
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	456080e7          	jalr	1110(ra) # 80003c32 <ialloc>
    800057e4:	8a2a                	mv	s4,a0
    800057e6:	c539                	beqz	a0,80005834 <create+0xf6>
  ilock(ip);
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	5e8080e7          	jalr	1512(ra) # 80003dd0 <ilock>
  ip->major = major;
    800057f0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800057f4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800057f8:	4905                	li	s2,1
    800057fa:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800057fe:	8552                	mv	a0,s4
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	504080e7          	jalr	1284(ra) # 80003d04 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005808:	000b059b          	sext.w	a1,s6
    8000580c:	03258b63          	beq	a1,s2,80005842 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005810:	004a2603          	lw	a2,4(s4)
    80005814:	fb040593          	addi	a1,s0,-80
    80005818:	8526                	mv	a0,s1
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	cb0080e7          	jalr	-848(ra) # 800044ca <dirlink>
    80005822:	06054f63          	bltz	a0,800058a0 <create+0x162>
  iunlockput(dp);
    80005826:	8526                	mv	a0,s1
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	80a080e7          	jalr	-2038(ra) # 80004032 <iunlockput>
  return ip;
    80005830:	8ad2                	mv	s5,s4
    80005832:	b749                	j	800057b4 <create+0x76>
    iunlockput(dp);
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	7fc080e7          	jalr	2044(ra) # 80004032 <iunlockput>
    return 0;
    8000583e:	8ad2                	mv	s5,s4
    80005840:	bf95                	j	800057b4 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005842:	004a2603          	lw	a2,4(s4)
    80005846:	00003597          	auipc	a1,0x3
    8000584a:	00a58593          	addi	a1,a1,10 # 80008850 <syscalls+0x2c8>
    8000584e:	8552                	mv	a0,s4
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	c7a080e7          	jalr	-902(ra) # 800044ca <dirlink>
    80005858:	04054463          	bltz	a0,800058a0 <create+0x162>
    8000585c:	40d0                	lw	a2,4(s1)
    8000585e:	00003597          	auipc	a1,0x3
    80005862:	ffa58593          	addi	a1,a1,-6 # 80008858 <syscalls+0x2d0>
    80005866:	8552                	mv	a0,s4
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	c62080e7          	jalr	-926(ra) # 800044ca <dirlink>
    80005870:	02054863          	bltz	a0,800058a0 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005874:	004a2603          	lw	a2,4(s4)
    80005878:	fb040593          	addi	a1,s0,-80
    8000587c:	8526                	mv	a0,s1
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	c4c080e7          	jalr	-948(ra) # 800044ca <dirlink>
    80005886:	00054d63          	bltz	a0,800058a0 <create+0x162>
    dp->nlink++;  // for ".."
    8000588a:	04a4d783          	lhu	a5,74(s1)
    8000588e:	2785                	addiw	a5,a5,1
    80005890:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005894:	8526                	mv	a0,s1
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	46e080e7          	jalr	1134(ra) # 80003d04 <iupdate>
    8000589e:	b761                	j	80005826 <create+0xe8>
  ip->nlink = 0;
    800058a0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800058a4:	8552                	mv	a0,s4
    800058a6:	ffffe097          	auipc	ra,0xffffe
    800058aa:	45e080e7          	jalr	1118(ra) # 80003d04 <iupdate>
  iunlockput(ip);
    800058ae:	8552                	mv	a0,s4
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	782080e7          	jalr	1922(ra) # 80004032 <iunlockput>
  iunlockput(dp);
    800058b8:	8526                	mv	a0,s1
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	778080e7          	jalr	1912(ra) # 80004032 <iunlockput>
  return 0;
    800058c2:	bdcd                	j	800057b4 <create+0x76>
    return 0;
    800058c4:	8aaa                	mv	s5,a0
    800058c6:	b5fd                	j	800057b4 <create+0x76>

00000000800058c8 <sys_dup>:
{
    800058c8:	7179                	addi	sp,sp,-48
    800058ca:	f406                	sd	ra,40(sp)
    800058cc:	f022                	sd	s0,32(sp)
    800058ce:	ec26                	sd	s1,24(sp)
    800058d0:	e84a                	sd	s2,16(sp)
    800058d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800058d4:	fd840613          	addi	a2,s0,-40
    800058d8:	4581                	li	a1,0
    800058da:	4501                	li	a0,0
    800058dc:	00000097          	auipc	ra,0x0
    800058e0:	dc0080e7          	jalr	-576(ra) # 8000569c <argfd>
    return -1;
    800058e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800058e6:	02054363          	bltz	a0,8000590c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800058ea:	fd843903          	ld	s2,-40(s0)
    800058ee:	854a                	mv	a0,s2
    800058f0:	00000097          	auipc	ra,0x0
    800058f4:	e0c080e7          	jalr	-500(ra) # 800056fc <fdalloc>
    800058f8:	84aa                	mv	s1,a0
    return -1;
    800058fa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800058fc:	00054863          	bltz	a0,8000590c <sys_dup+0x44>
  filedup(f);
    80005900:	854a                	mv	a0,s2
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	310080e7          	jalr	784(ra) # 80004c12 <filedup>
  return fd;
    8000590a:	87a6                	mv	a5,s1
}
    8000590c:	853e                	mv	a0,a5
    8000590e:	70a2                	ld	ra,40(sp)
    80005910:	7402                	ld	s0,32(sp)
    80005912:	64e2                	ld	s1,24(sp)
    80005914:	6942                	ld	s2,16(sp)
    80005916:	6145                	addi	sp,sp,48
    80005918:	8082                	ret

000000008000591a <sys_read>:
{
    8000591a:	7179                	addi	sp,sp,-48
    8000591c:	f406                	sd	ra,40(sp)
    8000591e:	f022                	sd	s0,32(sp)
    80005920:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005922:	fd840593          	addi	a1,s0,-40
    80005926:	4505                	li	a0,1
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	832080e7          	jalr	-1998(ra) # 8000315a <argaddr>
  argint(2, &n);
    80005930:	fe440593          	addi	a1,s0,-28
    80005934:	4509                	li	a0,2
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	804080e7          	jalr	-2044(ra) # 8000313a <argint>
  if(argfd(0, 0, &f) < 0)
    8000593e:	fe840613          	addi	a2,s0,-24
    80005942:	4581                	li	a1,0
    80005944:	4501                	li	a0,0
    80005946:	00000097          	auipc	ra,0x0
    8000594a:	d56080e7          	jalr	-682(ra) # 8000569c <argfd>
    8000594e:	87aa                	mv	a5,a0
    return -1;
    80005950:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005952:	0007cc63          	bltz	a5,8000596a <sys_read+0x50>
  return fileread(f, p, n);
    80005956:	fe442603          	lw	a2,-28(s0)
    8000595a:	fd843583          	ld	a1,-40(s0)
    8000595e:	fe843503          	ld	a0,-24(s0)
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	43c080e7          	jalr	1084(ra) # 80004d9e <fileread>
}
    8000596a:	70a2                	ld	ra,40(sp)
    8000596c:	7402                	ld	s0,32(sp)
    8000596e:	6145                	addi	sp,sp,48
    80005970:	8082                	ret

0000000080005972 <sys_write>:
{
    80005972:	7179                	addi	sp,sp,-48
    80005974:	f406                	sd	ra,40(sp)
    80005976:	f022                	sd	s0,32(sp)
    80005978:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000597a:	fd840593          	addi	a1,s0,-40
    8000597e:	4505                	li	a0,1
    80005980:	ffffd097          	auipc	ra,0xffffd
    80005984:	7da080e7          	jalr	2010(ra) # 8000315a <argaddr>
  argint(2, &n);
    80005988:	fe440593          	addi	a1,s0,-28
    8000598c:	4509                	li	a0,2
    8000598e:	ffffd097          	auipc	ra,0xffffd
    80005992:	7ac080e7          	jalr	1964(ra) # 8000313a <argint>
  if(argfd(0, 0, &f) < 0)
    80005996:	fe840613          	addi	a2,s0,-24
    8000599a:	4581                	li	a1,0
    8000599c:	4501                	li	a0,0
    8000599e:	00000097          	auipc	ra,0x0
    800059a2:	cfe080e7          	jalr	-770(ra) # 8000569c <argfd>
    800059a6:	87aa                	mv	a5,a0
    return -1;
    800059a8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059aa:	0007cc63          	bltz	a5,800059c2 <sys_write+0x50>
  return filewrite(f, p, n);
    800059ae:	fe442603          	lw	a2,-28(s0)
    800059b2:	fd843583          	ld	a1,-40(s0)
    800059b6:	fe843503          	ld	a0,-24(s0)
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	4a6080e7          	jalr	1190(ra) # 80004e60 <filewrite>
}
    800059c2:	70a2                	ld	ra,40(sp)
    800059c4:	7402                	ld	s0,32(sp)
    800059c6:	6145                	addi	sp,sp,48
    800059c8:	8082                	ret

00000000800059ca <sys_close>:
{
    800059ca:	1101                	addi	sp,sp,-32
    800059cc:	ec06                	sd	ra,24(sp)
    800059ce:	e822                	sd	s0,16(sp)
    800059d0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800059d2:	fe040613          	addi	a2,s0,-32
    800059d6:	fec40593          	addi	a1,s0,-20
    800059da:	4501                	li	a0,0
    800059dc:	00000097          	auipc	ra,0x0
    800059e0:	cc0080e7          	jalr	-832(ra) # 8000569c <argfd>
    return -1;
    800059e4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800059e6:	02054463          	bltz	a0,80005a0e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800059ea:	ffffc097          	auipc	ra,0xffffc
    800059ee:	316080e7          	jalr	790(ra) # 80001d00 <myproc>
    800059f2:	fec42783          	lw	a5,-20(s0)
    800059f6:	07e9                	addi	a5,a5,26
    800059f8:	078e                	slli	a5,a5,0x3
    800059fa:	953e                	add	a0,a0,a5
    800059fc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005a00:	fe043503          	ld	a0,-32(s0)
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	260080e7          	jalr	608(ra) # 80004c64 <fileclose>
  return 0;
    80005a0c:	4781                	li	a5,0
}
    80005a0e:	853e                	mv	a0,a5
    80005a10:	60e2                	ld	ra,24(sp)
    80005a12:	6442                	ld	s0,16(sp)
    80005a14:	6105                	addi	sp,sp,32
    80005a16:	8082                	ret

0000000080005a18 <sys_fstat>:
{
    80005a18:	1101                	addi	sp,sp,-32
    80005a1a:	ec06                	sd	ra,24(sp)
    80005a1c:	e822                	sd	s0,16(sp)
    80005a1e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005a20:	fe040593          	addi	a1,s0,-32
    80005a24:	4505                	li	a0,1
    80005a26:	ffffd097          	auipc	ra,0xffffd
    80005a2a:	734080e7          	jalr	1844(ra) # 8000315a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005a2e:	fe840613          	addi	a2,s0,-24
    80005a32:	4581                	li	a1,0
    80005a34:	4501                	li	a0,0
    80005a36:	00000097          	auipc	ra,0x0
    80005a3a:	c66080e7          	jalr	-922(ra) # 8000569c <argfd>
    80005a3e:	87aa                	mv	a5,a0
    return -1;
    80005a40:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a42:	0007ca63          	bltz	a5,80005a56 <sys_fstat+0x3e>
  return filestat(f, st);
    80005a46:	fe043583          	ld	a1,-32(s0)
    80005a4a:	fe843503          	ld	a0,-24(s0)
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	2de080e7          	jalr	734(ra) # 80004d2c <filestat>
}
    80005a56:	60e2                	ld	ra,24(sp)
    80005a58:	6442                	ld	s0,16(sp)
    80005a5a:	6105                	addi	sp,sp,32
    80005a5c:	8082                	ret

0000000080005a5e <sys_link>:
{
    80005a5e:	7169                	addi	sp,sp,-304
    80005a60:	f606                	sd	ra,296(sp)
    80005a62:	f222                	sd	s0,288(sp)
    80005a64:	ee26                	sd	s1,280(sp)
    80005a66:	ea4a                	sd	s2,272(sp)
    80005a68:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a6a:	08000613          	li	a2,128
    80005a6e:	ed040593          	addi	a1,s0,-304
    80005a72:	4501                	li	a0,0
    80005a74:	ffffd097          	auipc	ra,0xffffd
    80005a78:	706080e7          	jalr	1798(ra) # 8000317a <argstr>
    return -1;
    80005a7c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a7e:	10054e63          	bltz	a0,80005b9a <sys_link+0x13c>
    80005a82:	08000613          	li	a2,128
    80005a86:	f5040593          	addi	a1,s0,-176
    80005a8a:	4505                	li	a0,1
    80005a8c:	ffffd097          	auipc	ra,0xffffd
    80005a90:	6ee080e7          	jalr	1774(ra) # 8000317a <argstr>
    return -1;
    80005a94:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a96:	10054263          	bltz	a0,80005b9a <sys_link+0x13c>
  begin_op();
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	d02080e7          	jalr	-766(ra) # 8000479c <begin_op>
  if((ip = namei(old)) == 0){
    80005aa2:	ed040513          	addi	a0,s0,-304
    80005aa6:	fffff097          	auipc	ra,0xfffff
    80005aaa:	ad6080e7          	jalr	-1322(ra) # 8000457c <namei>
    80005aae:	84aa                	mv	s1,a0
    80005ab0:	c551                	beqz	a0,80005b3c <sys_link+0xde>
  ilock(ip);
    80005ab2:	ffffe097          	auipc	ra,0xffffe
    80005ab6:	31e080e7          	jalr	798(ra) # 80003dd0 <ilock>
  if(ip->type == T_DIR){
    80005aba:	04449703          	lh	a4,68(s1)
    80005abe:	4785                	li	a5,1
    80005ac0:	08f70463          	beq	a4,a5,80005b48 <sys_link+0xea>
  ip->nlink++;
    80005ac4:	04a4d783          	lhu	a5,74(s1)
    80005ac8:	2785                	addiw	a5,a5,1
    80005aca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ace:	8526                	mv	a0,s1
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	234080e7          	jalr	564(ra) # 80003d04 <iupdate>
  iunlock(ip);
    80005ad8:	8526                	mv	a0,s1
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	3b8080e7          	jalr	952(ra) # 80003e92 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ae2:	fd040593          	addi	a1,s0,-48
    80005ae6:	f5040513          	addi	a0,s0,-176
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	ab0080e7          	jalr	-1360(ra) # 8000459a <nameiparent>
    80005af2:	892a                	mv	s2,a0
    80005af4:	c935                	beqz	a0,80005b68 <sys_link+0x10a>
  ilock(dp);
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	2da080e7          	jalr	730(ra) # 80003dd0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005afe:	00092703          	lw	a4,0(s2)
    80005b02:	409c                	lw	a5,0(s1)
    80005b04:	04f71d63          	bne	a4,a5,80005b5e <sys_link+0x100>
    80005b08:	40d0                	lw	a2,4(s1)
    80005b0a:	fd040593          	addi	a1,s0,-48
    80005b0e:	854a                	mv	a0,s2
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	9ba080e7          	jalr	-1606(ra) # 800044ca <dirlink>
    80005b18:	04054363          	bltz	a0,80005b5e <sys_link+0x100>
  iunlockput(dp);
    80005b1c:	854a                	mv	a0,s2
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	514080e7          	jalr	1300(ra) # 80004032 <iunlockput>
  iput(ip);
    80005b26:	8526                	mv	a0,s1
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	462080e7          	jalr	1122(ra) # 80003f8a <iput>
  end_op();
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	cea080e7          	jalr	-790(ra) # 8000481a <end_op>
  return 0;
    80005b38:	4781                	li	a5,0
    80005b3a:	a085                	j	80005b9a <sys_link+0x13c>
    end_op();
    80005b3c:	fffff097          	auipc	ra,0xfffff
    80005b40:	cde080e7          	jalr	-802(ra) # 8000481a <end_op>
    return -1;
    80005b44:	57fd                	li	a5,-1
    80005b46:	a891                	j	80005b9a <sys_link+0x13c>
    iunlockput(ip);
    80005b48:	8526                	mv	a0,s1
    80005b4a:	ffffe097          	auipc	ra,0xffffe
    80005b4e:	4e8080e7          	jalr	1256(ra) # 80004032 <iunlockput>
    end_op();
    80005b52:	fffff097          	auipc	ra,0xfffff
    80005b56:	cc8080e7          	jalr	-824(ra) # 8000481a <end_op>
    return -1;
    80005b5a:	57fd                	li	a5,-1
    80005b5c:	a83d                	j	80005b9a <sys_link+0x13c>
    iunlockput(dp);
    80005b5e:	854a                	mv	a0,s2
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	4d2080e7          	jalr	1234(ra) # 80004032 <iunlockput>
  ilock(ip);
    80005b68:	8526                	mv	a0,s1
    80005b6a:	ffffe097          	auipc	ra,0xffffe
    80005b6e:	266080e7          	jalr	614(ra) # 80003dd0 <ilock>
  ip->nlink--;
    80005b72:	04a4d783          	lhu	a5,74(s1)
    80005b76:	37fd                	addiw	a5,a5,-1
    80005b78:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b7c:	8526                	mv	a0,s1
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	186080e7          	jalr	390(ra) # 80003d04 <iupdate>
  iunlockput(ip);
    80005b86:	8526                	mv	a0,s1
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	4aa080e7          	jalr	1194(ra) # 80004032 <iunlockput>
  end_op();
    80005b90:	fffff097          	auipc	ra,0xfffff
    80005b94:	c8a080e7          	jalr	-886(ra) # 8000481a <end_op>
  return -1;
    80005b98:	57fd                	li	a5,-1
}
    80005b9a:	853e                	mv	a0,a5
    80005b9c:	70b2                	ld	ra,296(sp)
    80005b9e:	7412                	ld	s0,288(sp)
    80005ba0:	64f2                	ld	s1,280(sp)
    80005ba2:	6952                	ld	s2,272(sp)
    80005ba4:	6155                	addi	sp,sp,304
    80005ba6:	8082                	ret

0000000080005ba8 <sys_unlink>:
{
    80005ba8:	7151                	addi	sp,sp,-240
    80005baa:	f586                	sd	ra,232(sp)
    80005bac:	f1a2                	sd	s0,224(sp)
    80005bae:	eda6                	sd	s1,216(sp)
    80005bb0:	e9ca                	sd	s2,208(sp)
    80005bb2:	e5ce                	sd	s3,200(sp)
    80005bb4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005bb6:	08000613          	li	a2,128
    80005bba:	f3040593          	addi	a1,s0,-208
    80005bbe:	4501                	li	a0,0
    80005bc0:	ffffd097          	auipc	ra,0xffffd
    80005bc4:	5ba080e7          	jalr	1466(ra) # 8000317a <argstr>
    80005bc8:	18054163          	bltz	a0,80005d4a <sys_unlink+0x1a2>
  begin_op();
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	bd0080e7          	jalr	-1072(ra) # 8000479c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005bd4:	fb040593          	addi	a1,s0,-80
    80005bd8:	f3040513          	addi	a0,s0,-208
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	9be080e7          	jalr	-1602(ra) # 8000459a <nameiparent>
    80005be4:	84aa                	mv	s1,a0
    80005be6:	c979                	beqz	a0,80005cbc <sys_unlink+0x114>
  ilock(dp);
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	1e8080e7          	jalr	488(ra) # 80003dd0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005bf0:	00003597          	auipc	a1,0x3
    80005bf4:	c6058593          	addi	a1,a1,-928 # 80008850 <syscalls+0x2c8>
    80005bf8:	fb040513          	addi	a0,s0,-80
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	69e080e7          	jalr	1694(ra) # 8000429a <namecmp>
    80005c04:	14050a63          	beqz	a0,80005d58 <sys_unlink+0x1b0>
    80005c08:	00003597          	auipc	a1,0x3
    80005c0c:	c5058593          	addi	a1,a1,-944 # 80008858 <syscalls+0x2d0>
    80005c10:	fb040513          	addi	a0,s0,-80
    80005c14:	ffffe097          	auipc	ra,0xffffe
    80005c18:	686080e7          	jalr	1670(ra) # 8000429a <namecmp>
    80005c1c:	12050e63          	beqz	a0,80005d58 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c20:	f2c40613          	addi	a2,s0,-212
    80005c24:	fb040593          	addi	a1,s0,-80
    80005c28:	8526                	mv	a0,s1
    80005c2a:	ffffe097          	auipc	ra,0xffffe
    80005c2e:	68a080e7          	jalr	1674(ra) # 800042b4 <dirlookup>
    80005c32:	892a                	mv	s2,a0
    80005c34:	12050263          	beqz	a0,80005d58 <sys_unlink+0x1b0>
  ilock(ip);
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	198080e7          	jalr	408(ra) # 80003dd0 <ilock>
  if(ip->nlink < 1)
    80005c40:	04a91783          	lh	a5,74(s2)
    80005c44:	08f05263          	blez	a5,80005cc8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005c48:	04491703          	lh	a4,68(s2)
    80005c4c:	4785                	li	a5,1
    80005c4e:	08f70563          	beq	a4,a5,80005cd8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005c52:	4641                	li	a2,16
    80005c54:	4581                	li	a1,0
    80005c56:	fc040513          	addi	a0,s0,-64
    80005c5a:	ffffb097          	auipc	ra,0xffffb
    80005c5e:	294080e7          	jalr	660(ra) # 80000eee <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c62:	4741                	li	a4,16
    80005c64:	f2c42683          	lw	a3,-212(s0)
    80005c68:	fc040613          	addi	a2,s0,-64
    80005c6c:	4581                	li	a1,0
    80005c6e:	8526                	mv	a0,s1
    80005c70:	ffffe097          	auipc	ra,0xffffe
    80005c74:	50c080e7          	jalr	1292(ra) # 8000417c <writei>
    80005c78:	47c1                	li	a5,16
    80005c7a:	0af51563          	bne	a0,a5,80005d24 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005c7e:	04491703          	lh	a4,68(s2)
    80005c82:	4785                	li	a5,1
    80005c84:	0af70863          	beq	a4,a5,80005d34 <sys_unlink+0x18c>
  iunlockput(dp);
    80005c88:	8526                	mv	a0,s1
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	3a8080e7          	jalr	936(ra) # 80004032 <iunlockput>
  ip->nlink--;
    80005c92:	04a95783          	lhu	a5,74(s2)
    80005c96:	37fd                	addiw	a5,a5,-1
    80005c98:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c9c:	854a                	mv	a0,s2
    80005c9e:	ffffe097          	auipc	ra,0xffffe
    80005ca2:	066080e7          	jalr	102(ra) # 80003d04 <iupdate>
  iunlockput(ip);
    80005ca6:	854a                	mv	a0,s2
    80005ca8:	ffffe097          	auipc	ra,0xffffe
    80005cac:	38a080e7          	jalr	906(ra) # 80004032 <iunlockput>
  end_op();
    80005cb0:	fffff097          	auipc	ra,0xfffff
    80005cb4:	b6a080e7          	jalr	-1174(ra) # 8000481a <end_op>
  return 0;
    80005cb8:	4501                	li	a0,0
    80005cba:	a84d                	j	80005d6c <sys_unlink+0x1c4>
    end_op();
    80005cbc:	fffff097          	auipc	ra,0xfffff
    80005cc0:	b5e080e7          	jalr	-1186(ra) # 8000481a <end_op>
    return -1;
    80005cc4:	557d                	li	a0,-1
    80005cc6:	a05d                	j	80005d6c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005cc8:	00003517          	auipc	a0,0x3
    80005ccc:	b9850513          	addi	a0,a0,-1128 # 80008860 <syscalls+0x2d8>
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	870080e7          	jalr	-1936(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005cd8:	04c92703          	lw	a4,76(s2)
    80005cdc:	02000793          	li	a5,32
    80005ce0:	f6e7f9e3          	bgeu	a5,a4,80005c52 <sys_unlink+0xaa>
    80005ce4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ce8:	4741                	li	a4,16
    80005cea:	86ce                	mv	a3,s3
    80005cec:	f1840613          	addi	a2,s0,-232
    80005cf0:	4581                	li	a1,0
    80005cf2:	854a                	mv	a0,s2
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	390080e7          	jalr	912(ra) # 80004084 <readi>
    80005cfc:	47c1                	li	a5,16
    80005cfe:	00f51b63          	bne	a0,a5,80005d14 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005d02:	f1845783          	lhu	a5,-232(s0)
    80005d06:	e7a1                	bnez	a5,80005d4e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d08:	29c1                	addiw	s3,s3,16
    80005d0a:	04c92783          	lw	a5,76(s2)
    80005d0e:	fcf9ede3          	bltu	s3,a5,80005ce8 <sys_unlink+0x140>
    80005d12:	b781                	j	80005c52 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005d14:	00003517          	auipc	a0,0x3
    80005d18:	b6450513          	addi	a0,a0,-1180 # 80008878 <syscalls+0x2f0>
    80005d1c:	ffffb097          	auipc	ra,0xffffb
    80005d20:	824080e7          	jalr	-2012(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005d24:	00003517          	auipc	a0,0x3
    80005d28:	b6c50513          	addi	a0,a0,-1172 # 80008890 <syscalls+0x308>
    80005d2c:	ffffb097          	auipc	ra,0xffffb
    80005d30:	814080e7          	jalr	-2028(ra) # 80000540 <panic>
    dp->nlink--;
    80005d34:	04a4d783          	lhu	a5,74(s1)
    80005d38:	37fd                	addiw	a5,a5,-1
    80005d3a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d3e:	8526                	mv	a0,s1
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	fc4080e7          	jalr	-60(ra) # 80003d04 <iupdate>
    80005d48:	b781                	j	80005c88 <sys_unlink+0xe0>
    return -1;
    80005d4a:	557d                	li	a0,-1
    80005d4c:	a005                	j	80005d6c <sys_unlink+0x1c4>
    iunlockput(ip);
    80005d4e:	854a                	mv	a0,s2
    80005d50:	ffffe097          	auipc	ra,0xffffe
    80005d54:	2e2080e7          	jalr	738(ra) # 80004032 <iunlockput>
  iunlockput(dp);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	2d8080e7          	jalr	728(ra) # 80004032 <iunlockput>
  end_op();
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	ab8080e7          	jalr	-1352(ra) # 8000481a <end_op>
  return -1;
    80005d6a:	557d                	li	a0,-1
}
    80005d6c:	70ae                	ld	ra,232(sp)
    80005d6e:	740e                	ld	s0,224(sp)
    80005d70:	64ee                	ld	s1,216(sp)
    80005d72:	694e                	ld	s2,208(sp)
    80005d74:	69ae                	ld	s3,200(sp)
    80005d76:	616d                	addi	sp,sp,240
    80005d78:	8082                	ret

0000000080005d7a <sys_open>:

uint64
sys_open(void)
{
    80005d7a:	7131                	addi	sp,sp,-192
    80005d7c:	fd06                	sd	ra,184(sp)
    80005d7e:	f922                	sd	s0,176(sp)
    80005d80:	f526                	sd	s1,168(sp)
    80005d82:	f14a                	sd	s2,160(sp)
    80005d84:	ed4e                	sd	s3,152(sp)
    80005d86:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d88:	f4c40593          	addi	a1,s0,-180
    80005d8c:	4505                	li	a0,1
    80005d8e:	ffffd097          	auipc	ra,0xffffd
    80005d92:	3ac080e7          	jalr	940(ra) # 8000313a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d96:	08000613          	li	a2,128
    80005d9a:	f5040593          	addi	a1,s0,-176
    80005d9e:	4501                	li	a0,0
    80005da0:	ffffd097          	auipc	ra,0xffffd
    80005da4:	3da080e7          	jalr	986(ra) # 8000317a <argstr>
    80005da8:	87aa                	mv	a5,a0
    return -1;
    80005daa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005dac:	0a07c963          	bltz	a5,80005e5e <sys_open+0xe4>

  begin_op();
    80005db0:	fffff097          	auipc	ra,0xfffff
    80005db4:	9ec080e7          	jalr	-1556(ra) # 8000479c <begin_op>

  if(omode & O_CREATE){
    80005db8:	f4c42783          	lw	a5,-180(s0)
    80005dbc:	2007f793          	andi	a5,a5,512
    80005dc0:	cfc5                	beqz	a5,80005e78 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005dc2:	4681                	li	a3,0
    80005dc4:	4601                	li	a2,0
    80005dc6:	4589                	li	a1,2
    80005dc8:	f5040513          	addi	a0,s0,-176
    80005dcc:	00000097          	auipc	ra,0x0
    80005dd0:	972080e7          	jalr	-1678(ra) # 8000573e <create>
    80005dd4:	84aa                	mv	s1,a0
    if(ip == 0){
    80005dd6:	c959                	beqz	a0,80005e6c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005dd8:	04449703          	lh	a4,68(s1)
    80005ddc:	478d                	li	a5,3
    80005dde:	00f71763          	bne	a4,a5,80005dec <sys_open+0x72>
    80005de2:	0464d703          	lhu	a4,70(s1)
    80005de6:	47a5                	li	a5,9
    80005de8:	0ce7ed63          	bltu	a5,a4,80005ec2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005dec:	fffff097          	auipc	ra,0xfffff
    80005df0:	dbc080e7          	jalr	-580(ra) # 80004ba8 <filealloc>
    80005df4:	89aa                	mv	s3,a0
    80005df6:	10050363          	beqz	a0,80005efc <sys_open+0x182>
    80005dfa:	00000097          	auipc	ra,0x0
    80005dfe:	902080e7          	jalr	-1790(ra) # 800056fc <fdalloc>
    80005e02:	892a                	mv	s2,a0
    80005e04:	0e054763          	bltz	a0,80005ef2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005e08:	04449703          	lh	a4,68(s1)
    80005e0c:	478d                	li	a5,3
    80005e0e:	0cf70563          	beq	a4,a5,80005ed8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e12:	4789                	li	a5,2
    80005e14:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005e18:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005e1c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005e20:	f4c42783          	lw	a5,-180(s0)
    80005e24:	0017c713          	xori	a4,a5,1
    80005e28:	8b05                	andi	a4,a4,1
    80005e2a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e2e:	0037f713          	andi	a4,a5,3
    80005e32:	00e03733          	snez	a4,a4
    80005e36:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e3a:	4007f793          	andi	a5,a5,1024
    80005e3e:	c791                	beqz	a5,80005e4a <sys_open+0xd0>
    80005e40:	04449703          	lh	a4,68(s1)
    80005e44:	4789                	li	a5,2
    80005e46:	0af70063          	beq	a4,a5,80005ee6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005e4a:	8526                	mv	a0,s1
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	046080e7          	jalr	70(ra) # 80003e92 <iunlock>
  end_op();
    80005e54:	fffff097          	auipc	ra,0xfffff
    80005e58:	9c6080e7          	jalr	-1594(ra) # 8000481a <end_op>

  return fd;
    80005e5c:	854a                	mv	a0,s2
}
    80005e5e:	70ea                	ld	ra,184(sp)
    80005e60:	744a                	ld	s0,176(sp)
    80005e62:	74aa                	ld	s1,168(sp)
    80005e64:	790a                	ld	s2,160(sp)
    80005e66:	69ea                	ld	s3,152(sp)
    80005e68:	6129                	addi	sp,sp,192
    80005e6a:	8082                	ret
      end_op();
    80005e6c:	fffff097          	auipc	ra,0xfffff
    80005e70:	9ae080e7          	jalr	-1618(ra) # 8000481a <end_op>
      return -1;
    80005e74:	557d                	li	a0,-1
    80005e76:	b7e5                	j	80005e5e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005e78:	f5040513          	addi	a0,s0,-176
    80005e7c:	ffffe097          	auipc	ra,0xffffe
    80005e80:	700080e7          	jalr	1792(ra) # 8000457c <namei>
    80005e84:	84aa                	mv	s1,a0
    80005e86:	c905                	beqz	a0,80005eb6 <sys_open+0x13c>
    ilock(ip);
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	f48080e7          	jalr	-184(ra) # 80003dd0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e90:	04449703          	lh	a4,68(s1)
    80005e94:	4785                	li	a5,1
    80005e96:	f4f711e3          	bne	a4,a5,80005dd8 <sys_open+0x5e>
    80005e9a:	f4c42783          	lw	a5,-180(s0)
    80005e9e:	d7b9                	beqz	a5,80005dec <sys_open+0x72>
      iunlockput(ip);
    80005ea0:	8526                	mv	a0,s1
    80005ea2:	ffffe097          	auipc	ra,0xffffe
    80005ea6:	190080e7          	jalr	400(ra) # 80004032 <iunlockput>
      end_op();
    80005eaa:	fffff097          	auipc	ra,0xfffff
    80005eae:	970080e7          	jalr	-1680(ra) # 8000481a <end_op>
      return -1;
    80005eb2:	557d                	li	a0,-1
    80005eb4:	b76d                	j	80005e5e <sys_open+0xe4>
      end_op();
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	964080e7          	jalr	-1692(ra) # 8000481a <end_op>
      return -1;
    80005ebe:	557d                	li	a0,-1
    80005ec0:	bf79                	j	80005e5e <sys_open+0xe4>
    iunlockput(ip);
    80005ec2:	8526                	mv	a0,s1
    80005ec4:	ffffe097          	auipc	ra,0xffffe
    80005ec8:	16e080e7          	jalr	366(ra) # 80004032 <iunlockput>
    end_op();
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	94e080e7          	jalr	-1714(ra) # 8000481a <end_op>
    return -1;
    80005ed4:	557d                	li	a0,-1
    80005ed6:	b761                	j	80005e5e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ed8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005edc:	04649783          	lh	a5,70(s1)
    80005ee0:	02f99223          	sh	a5,36(s3)
    80005ee4:	bf25                	j	80005e1c <sys_open+0xa2>
    itrunc(ip);
    80005ee6:	8526                	mv	a0,s1
    80005ee8:	ffffe097          	auipc	ra,0xffffe
    80005eec:	ff6080e7          	jalr	-10(ra) # 80003ede <itrunc>
    80005ef0:	bfa9                	j	80005e4a <sys_open+0xd0>
      fileclose(f);
    80005ef2:	854e                	mv	a0,s3
    80005ef4:	fffff097          	auipc	ra,0xfffff
    80005ef8:	d70080e7          	jalr	-656(ra) # 80004c64 <fileclose>
    iunlockput(ip);
    80005efc:	8526                	mv	a0,s1
    80005efe:	ffffe097          	auipc	ra,0xffffe
    80005f02:	134080e7          	jalr	308(ra) # 80004032 <iunlockput>
    end_op();
    80005f06:	fffff097          	auipc	ra,0xfffff
    80005f0a:	914080e7          	jalr	-1772(ra) # 8000481a <end_op>
    return -1;
    80005f0e:	557d                	li	a0,-1
    80005f10:	b7b9                	j	80005e5e <sys_open+0xe4>

0000000080005f12 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005f12:	7175                	addi	sp,sp,-144
    80005f14:	e506                	sd	ra,136(sp)
    80005f16:	e122                	sd	s0,128(sp)
    80005f18:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005f1a:	fffff097          	auipc	ra,0xfffff
    80005f1e:	882080e7          	jalr	-1918(ra) # 8000479c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005f22:	08000613          	li	a2,128
    80005f26:	f7040593          	addi	a1,s0,-144
    80005f2a:	4501                	li	a0,0
    80005f2c:	ffffd097          	auipc	ra,0xffffd
    80005f30:	24e080e7          	jalr	590(ra) # 8000317a <argstr>
    80005f34:	02054963          	bltz	a0,80005f66 <sys_mkdir+0x54>
    80005f38:	4681                	li	a3,0
    80005f3a:	4601                	li	a2,0
    80005f3c:	4585                	li	a1,1
    80005f3e:	f7040513          	addi	a0,s0,-144
    80005f42:	fffff097          	auipc	ra,0xfffff
    80005f46:	7fc080e7          	jalr	2044(ra) # 8000573e <create>
    80005f4a:	cd11                	beqz	a0,80005f66 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f4c:	ffffe097          	auipc	ra,0xffffe
    80005f50:	0e6080e7          	jalr	230(ra) # 80004032 <iunlockput>
  end_op();
    80005f54:	fffff097          	auipc	ra,0xfffff
    80005f58:	8c6080e7          	jalr	-1850(ra) # 8000481a <end_op>
  return 0;
    80005f5c:	4501                	li	a0,0
}
    80005f5e:	60aa                	ld	ra,136(sp)
    80005f60:	640a                	ld	s0,128(sp)
    80005f62:	6149                	addi	sp,sp,144
    80005f64:	8082                	ret
    end_op();
    80005f66:	fffff097          	auipc	ra,0xfffff
    80005f6a:	8b4080e7          	jalr	-1868(ra) # 8000481a <end_op>
    return -1;
    80005f6e:	557d                	li	a0,-1
    80005f70:	b7fd                	j	80005f5e <sys_mkdir+0x4c>

0000000080005f72 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f72:	7135                	addi	sp,sp,-160
    80005f74:	ed06                	sd	ra,152(sp)
    80005f76:	e922                	sd	s0,144(sp)
    80005f78:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	822080e7          	jalr	-2014(ra) # 8000479c <begin_op>
  argint(1, &major);
    80005f82:	f6c40593          	addi	a1,s0,-148
    80005f86:	4505                	li	a0,1
    80005f88:	ffffd097          	auipc	ra,0xffffd
    80005f8c:	1b2080e7          	jalr	434(ra) # 8000313a <argint>
  argint(2, &minor);
    80005f90:	f6840593          	addi	a1,s0,-152
    80005f94:	4509                	li	a0,2
    80005f96:	ffffd097          	auipc	ra,0xffffd
    80005f9a:	1a4080e7          	jalr	420(ra) # 8000313a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f9e:	08000613          	li	a2,128
    80005fa2:	f7040593          	addi	a1,s0,-144
    80005fa6:	4501                	li	a0,0
    80005fa8:	ffffd097          	auipc	ra,0xffffd
    80005fac:	1d2080e7          	jalr	466(ra) # 8000317a <argstr>
    80005fb0:	02054b63          	bltz	a0,80005fe6 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005fb4:	f6841683          	lh	a3,-152(s0)
    80005fb8:	f6c41603          	lh	a2,-148(s0)
    80005fbc:	458d                	li	a1,3
    80005fbe:	f7040513          	addi	a0,s0,-144
    80005fc2:	fffff097          	auipc	ra,0xfffff
    80005fc6:	77c080e7          	jalr	1916(ra) # 8000573e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005fca:	cd11                	beqz	a0,80005fe6 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fcc:	ffffe097          	auipc	ra,0xffffe
    80005fd0:	066080e7          	jalr	102(ra) # 80004032 <iunlockput>
  end_op();
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	846080e7          	jalr	-1978(ra) # 8000481a <end_op>
  return 0;
    80005fdc:	4501                	li	a0,0
}
    80005fde:	60ea                	ld	ra,152(sp)
    80005fe0:	644a                	ld	s0,144(sp)
    80005fe2:	610d                	addi	sp,sp,160
    80005fe4:	8082                	ret
    end_op();
    80005fe6:	fffff097          	auipc	ra,0xfffff
    80005fea:	834080e7          	jalr	-1996(ra) # 8000481a <end_op>
    return -1;
    80005fee:	557d                	li	a0,-1
    80005ff0:	b7fd                	j	80005fde <sys_mknod+0x6c>

0000000080005ff2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ff2:	7135                	addi	sp,sp,-160
    80005ff4:	ed06                	sd	ra,152(sp)
    80005ff6:	e922                	sd	s0,144(sp)
    80005ff8:	e526                	sd	s1,136(sp)
    80005ffa:	e14a                	sd	s2,128(sp)
    80005ffc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ffe:	ffffc097          	auipc	ra,0xffffc
    80006002:	d02080e7          	jalr	-766(ra) # 80001d00 <myproc>
    80006006:	892a                	mv	s2,a0
  
  begin_op();
    80006008:	ffffe097          	auipc	ra,0xffffe
    8000600c:	794080e7          	jalr	1940(ra) # 8000479c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006010:	08000613          	li	a2,128
    80006014:	f6040593          	addi	a1,s0,-160
    80006018:	4501                	li	a0,0
    8000601a:	ffffd097          	auipc	ra,0xffffd
    8000601e:	160080e7          	jalr	352(ra) # 8000317a <argstr>
    80006022:	04054b63          	bltz	a0,80006078 <sys_chdir+0x86>
    80006026:	f6040513          	addi	a0,s0,-160
    8000602a:	ffffe097          	auipc	ra,0xffffe
    8000602e:	552080e7          	jalr	1362(ra) # 8000457c <namei>
    80006032:	84aa                	mv	s1,a0
    80006034:	c131                	beqz	a0,80006078 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	d9a080e7          	jalr	-614(ra) # 80003dd0 <ilock>
  if(ip->type != T_DIR){
    8000603e:	04449703          	lh	a4,68(s1)
    80006042:	4785                	li	a5,1
    80006044:	04f71063          	bne	a4,a5,80006084 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006048:	8526                	mv	a0,s1
    8000604a:	ffffe097          	auipc	ra,0xffffe
    8000604e:	e48080e7          	jalr	-440(ra) # 80003e92 <iunlock>
  iput(p->cwd);
    80006052:	15093503          	ld	a0,336(s2)
    80006056:	ffffe097          	auipc	ra,0xffffe
    8000605a:	f34080e7          	jalr	-204(ra) # 80003f8a <iput>
  end_op();
    8000605e:	ffffe097          	auipc	ra,0xffffe
    80006062:	7bc080e7          	jalr	1980(ra) # 8000481a <end_op>
  p->cwd = ip;
    80006066:	14993823          	sd	s1,336(s2)
  return 0;
    8000606a:	4501                	li	a0,0
}
    8000606c:	60ea                	ld	ra,152(sp)
    8000606e:	644a                	ld	s0,144(sp)
    80006070:	64aa                	ld	s1,136(sp)
    80006072:	690a                	ld	s2,128(sp)
    80006074:	610d                	addi	sp,sp,160
    80006076:	8082                	ret
    end_op();
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	7a2080e7          	jalr	1954(ra) # 8000481a <end_op>
    return -1;
    80006080:	557d                	li	a0,-1
    80006082:	b7ed                	j	8000606c <sys_chdir+0x7a>
    iunlockput(ip);
    80006084:	8526                	mv	a0,s1
    80006086:	ffffe097          	auipc	ra,0xffffe
    8000608a:	fac080e7          	jalr	-84(ra) # 80004032 <iunlockput>
    end_op();
    8000608e:	ffffe097          	auipc	ra,0xffffe
    80006092:	78c080e7          	jalr	1932(ra) # 8000481a <end_op>
    return -1;
    80006096:	557d                	li	a0,-1
    80006098:	bfd1                	j	8000606c <sys_chdir+0x7a>

000000008000609a <sys_exec>:

uint64
sys_exec(void)
{
    8000609a:	7145                	addi	sp,sp,-464
    8000609c:	e786                	sd	ra,456(sp)
    8000609e:	e3a2                	sd	s0,448(sp)
    800060a0:	ff26                	sd	s1,440(sp)
    800060a2:	fb4a                	sd	s2,432(sp)
    800060a4:	f74e                	sd	s3,424(sp)
    800060a6:	f352                	sd	s4,416(sp)
    800060a8:	ef56                	sd	s5,408(sp)
    800060aa:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800060ac:	e3840593          	addi	a1,s0,-456
    800060b0:	4505                	li	a0,1
    800060b2:	ffffd097          	auipc	ra,0xffffd
    800060b6:	0a8080e7          	jalr	168(ra) # 8000315a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800060ba:	08000613          	li	a2,128
    800060be:	f4040593          	addi	a1,s0,-192
    800060c2:	4501                	li	a0,0
    800060c4:	ffffd097          	auipc	ra,0xffffd
    800060c8:	0b6080e7          	jalr	182(ra) # 8000317a <argstr>
    800060cc:	87aa                	mv	a5,a0
    return -1;
    800060ce:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800060d0:	0c07c363          	bltz	a5,80006196 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800060d4:	10000613          	li	a2,256
    800060d8:	4581                	li	a1,0
    800060da:	e4040513          	addi	a0,s0,-448
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	e10080e7          	jalr	-496(ra) # 80000eee <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800060e6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800060ea:	89a6                	mv	s3,s1
    800060ec:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800060ee:	02000a13          	li	s4,32
    800060f2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060f6:	00391513          	slli	a0,s2,0x3
    800060fa:	e3040593          	addi	a1,s0,-464
    800060fe:	e3843783          	ld	a5,-456(s0)
    80006102:	953e                	add	a0,a0,a5
    80006104:	ffffd097          	auipc	ra,0xffffd
    80006108:	f98080e7          	jalr	-104(ra) # 8000309c <fetchaddr>
    8000610c:	02054a63          	bltz	a0,80006140 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006110:	e3043783          	ld	a5,-464(s0)
    80006114:	c3b9                	beqz	a5,8000615a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006116:	ffffb097          	auipc	ra,0xffffb
    8000611a:	b52080e7          	jalr	-1198(ra) # 80000c68 <kalloc>
    8000611e:	85aa                	mv	a1,a0
    80006120:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006124:	cd11                	beqz	a0,80006140 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006126:	6605                	lui	a2,0x1
    80006128:	e3043503          	ld	a0,-464(s0)
    8000612c:	ffffd097          	auipc	ra,0xffffd
    80006130:	fc2080e7          	jalr	-62(ra) # 800030ee <fetchstr>
    80006134:	00054663          	bltz	a0,80006140 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006138:	0905                	addi	s2,s2,1
    8000613a:	09a1                	addi	s3,s3,8
    8000613c:	fb491be3          	bne	s2,s4,800060f2 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006140:	f4040913          	addi	s2,s0,-192
    80006144:	6088                	ld	a0,0(s1)
    80006146:	c539                	beqz	a0,80006194 <sys_exec+0xfa>
    kfree(argv[i]);
    80006148:	ffffb097          	auipc	ra,0xffffb
    8000614c:	92e080e7          	jalr	-1746(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006150:	04a1                	addi	s1,s1,8
    80006152:	ff2499e3          	bne	s1,s2,80006144 <sys_exec+0xaa>
  return -1;
    80006156:	557d                	li	a0,-1
    80006158:	a83d                	j	80006196 <sys_exec+0xfc>
      argv[i] = 0;
    8000615a:	0a8e                	slli	s5,s5,0x3
    8000615c:	fc0a8793          	addi	a5,s5,-64
    80006160:	00878ab3          	add	s5,a5,s0
    80006164:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006168:	e4040593          	addi	a1,s0,-448
    8000616c:	f4040513          	addi	a0,s0,-192
    80006170:	fffff097          	auipc	ra,0xfffff
    80006174:	16e080e7          	jalr	366(ra) # 800052de <exec>
    80006178:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000617a:	f4040993          	addi	s3,s0,-192
    8000617e:	6088                	ld	a0,0(s1)
    80006180:	c901                	beqz	a0,80006190 <sys_exec+0xf6>
    kfree(argv[i]);
    80006182:	ffffb097          	auipc	ra,0xffffb
    80006186:	8f4080e7          	jalr	-1804(ra) # 80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000618a:	04a1                	addi	s1,s1,8
    8000618c:	ff3499e3          	bne	s1,s3,8000617e <sys_exec+0xe4>
  return ret;
    80006190:	854a                	mv	a0,s2
    80006192:	a011                	j	80006196 <sys_exec+0xfc>
  return -1;
    80006194:	557d                	li	a0,-1
}
    80006196:	60be                	ld	ra,456(sp)
    80006198:	641e                	ld	s0,448(sp)
    8000619a:	74fa                	ld	s1,440(sp)
    8000619c:	795a                	ld	s2,432(sp)
    8000619e:	79ba                	ld	s3,424(sp)
    800061a0:	7a1a                	ld	s4,416(sp)
    800061a2:	6afa                	ld	s5,408(sp)
    800061a4:	6179                	addi	sp,sp,464
    800061a6:	8082                	ret

00000000800061a8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800061a8:	7139                	addi	sp,sp,-64
    800061aa:	fc06                	sd	ra,56(sp)
    800061ac:	f822                	sd	s0,48(sp)
    800061ae:	f426                	sd	s1,40(sp)
    800061b0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800061b2:	ffffc097          	auipc	ra,0xffffc
    800061b6:	b4e080e7          	jalr	-1202(ra) # 80001d00 <myproc>
    800061ba:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800061bc:	fd840593          	addi	a1,s0,-40
    800061c0:	4501                	li	a0,0
    800061c2:	ffffd097          	auipc	ra,0xffffd
    800061c6:	f98080e7          	jalr	-104(ra) # 8000315a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800061ca:	fc840593          	addi	a1,s0,-56
    800061ce:	fd040513          	addi	a0,s0,-48
    800061d2:	fffff097          	auipc	ra,0xfffff
    800061d6:	dc2080e7          	jalr	-574(ra) # 80004f94 <pipealloc>
    return -1;
    800061da:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800061dc:	0c054463          	bltz	a0,800062a4 <sys_pipe+0xfc>
  fd0 = -1;
    800061e0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061e4:	fd043503          	ld	a0,-48(s0)
    800061e8:	fffff097          	auipc	ra,0xfffff
    800061ec:	514080e7          	jalr	1300(ra) # 800056fc <fdalloc>
    800061f0:	fca42223          	sw	a0,-60(s0)
    800061f4:	08054b63          	bltz	a0,8000628a <sys_pipe+0xe2>
    800061f8:	fc843503          	ld	a0,-56(s0)
    800061fc:	fffff097          	auipc	ra,0xfffff
    80006200:	500080e7          	jalr	1280(ra) # 800056fc <fdalloc>
    80006204:	fca42023          	sw	a0,-64(s0)
    80006208:	06054863          	bltz	a0,80006278 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000620c:	4691                	li	a3,4
    8000620e:	fc440613          	addi	a2,s0,-60
    80006212:	fd843583          	ld	a1,-40(s0)
    80006216:	68a8                	ld	a0,80(s1)
    80006218:	ffffb097          	auipc	ra,0xffffb
    8000621c:	64e080e7          	jalr	1614(ra) # 80001866 <copyout>
    80006220:	02054063          	bltz	a0,80006240 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006224:	4691                	li	a3,4
    80006226:	fc040613          	addi	a2,s0,-64
    8000622a:	fd843583          	ld	a1,-40(s0)
    8000622e:	0591                	addi	a1,a1,4
    80006230:	68a8                	ld	a0,80(s1)
    80006232:	ffffb097          	auipc	ra,0xffffb
    80006236:	634080e7          	jalr	1588(ra) # 80001866 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000623a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000623c:	06055463          	bgez	a0,800062a4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006240:	fc442783          	lw	a5,-60(s0)
    80006244:	07e9                	addi	a5,a5,26
    80006246:	078e                	slli	a5,a5,0x3
    80006248:	97a6                	add	a5,a5,s1
    8000624a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000624e:	fc042783          	lw	a5,-64(s0)
    80006252:	07e9                	addi	a5,a5,26
    80006254:	078e                	slli	a5,a5,0x3
    80006256:	94be                	add	s1,s1,a5
    80006258:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000625c:	fd043503          	ld	a0,-48(s0)
    80006260:	fffff097          	auipc	ra,0xfffff
    80006264:	a04080e7          	jalr	-1532(ra) # 80004c64 <fileclose>
    fileclose(wf);
    80006268:	fc843503          	ld	a0,-56(s0)
    8000626c:	fffff097          	auipc	ra,0xfffff
    80006270:	9f8080e7          	jalr	-1544(ra) # 80004c64 <fileclose>
    return -1;
    80006274:	57fd                	li	a5,-1
    80006276:	a03d                	j	800062a4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006278:	fc442783          	lw	a5,-60(s0)
    8000627c:	0007c763          	bltz	a5,8000628a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006280:	07e9                	addi	a5,a5,26
    80006282:	078e                	slli	a5,a5,0x3
    80006284:	97a6                	add	a5,a5,s1
    80006286:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000628a:	fd043503          	ld	a0,-48(s0)
    8000628e:	fffff097          	auipc	ra,0xfffff
    80006292:	9d6080e7          	jalr	-1578(ra) # 80004c64 <fileclose>
    fileclose(wf);
    80006296:	fc843503          	ld	a0,-56(s0)
    8000629a:	fffff097          	auipc	ra,0xfffff
    8000629e:	9ca080e7          	jalr	-1590(ra) # 80004c64 <fileclose>
    return -1;
    800062a2:	57fd                	li	a5,-1
}
    800062a4:	853e                	mv	a0,a5
    800062a6:	70e2                	ld	ra,56(sp)
    800062a8:	7442                	ld	s0,48(sp)
    800062aa:	74a2                	ld	s1,40(sp)
    800062ac:	6121                	addi	sp,sp,64
    800062ae:	8082                	ret

00000000800062b0 <kernelvec>:
    800062b0:	7111                	addi	sp,sp,-256
    800062b2:	e006                	sd	ra,0(sp)
    800062b4:	e40a                	sd	sp,8(sp)
    800062b6:	e80e                	sd	gp,16(sp)
    800062b8:	ec12                	sd	tp,24(sp)
    800062ba:	f016                	sd	t0,32(sp)
    800062bc:	f41a                	sd	t1,40(sp)
    800062be:	f81e                	sd	t2,48(sp)
    800062c0:	fc22                	sd	s0,56(sp)
    800062c2:	e0a6                	sd	s1,64(sp)
    800062c4:	e4aa                	sd	a0,72(sp)
    800062c6:	e8ae                	sd	a1,80(sp)
    800062c8:	ecb2                	sd	a2,88(sp)
    800062ca:	f0b6                	sd	a3,96(sp)
    800062cc:	f4ba                	sd	a4,104(sp)
    800062ce:	f8be                	sd	a5,112(sp)
    800062d0:	fcc2                	sd	a6,120(sp)
    800062d2:	e146                	sd	a7,128(sp)
    800062d4:	e54a                	sd	s2,136(sp)
    800062d6:	e94e                	sd	s3,144(sp)
    800062d8:	ed52                	sd	s4,152(sp)
    800062da:	f156                	sd	s5,160(sp)
    800062dc:	f55a                	sd	s6,168(sp)
    800062de:	f95e                	sd	s7,176(sp)
    800062e0:	fd62                	sd	s8,184(sp)
    800062e2:	e1e6                	sd	s9,192(sp)
    800062e4:	e5ea                	sd	s10,200(sp)
    800062e6:	e9ee                	sd	s11,208(sp)
    800062e8:	edf2                	sd	t3,216(sp)
    800062ea:	f1f6                	sd	t4,224(sp)
    800062ec:	f5fa                	sd	t5,232(sp)
    800062ee:	f9fe                	sd	t6,240(sp)
    800062f0:	c79fc0ef          	jal	ra,80002f68 <kerneltrap>
    800062f4:	6082                	ld	ra,0(sp)
    800062f6:	6122                	ld	sp,8(sp)
    800062f8:	61c2                	ld	gp,16(sp)
    800062fa:	7282                	ld	t0,32(sp)
    800062fc:	7322                	ld	t1,40(sp)
    800062fe:	73c2                	ld	t2,48(sp)
    80006300:	7462                	ld	s0,56(sp)
    80006302:	6486                	ld	s1,64(sp)
    80006304:	6526                	ld	a0,72(sp)
    80006306:	65c6                	ld	a1,80(sp)
    80006308:	6666                	ld	a2,88(sp)
    8000630a:	7686                	ld	a3,96(sp)
    8000630c:	7726                	ld	a4,104(sp)
    8000630e:	77c6                	ld	a5,112(sp)
    80006310:	7866                	ld	a6,120(sp)
    80006312:	688a                	ld	a7,128(sp)
    80006314:	692a                	ld	s2,136(sp)
    80006316:	69ca                	ld	s3,144(sp)
    80006318:	6a6a                	ld	s4,152(sp)
    8000631a:	7a8a                	ld	s5,160(sp)
    8000631c:	7b2a                	ld	s6,168(sp)
    8000631e:	7bca                	ld	s7,176(sp)
    80006320:	7c6a                	ld	s8,184(sp)
    80006322:	6c8e                	ld	s9,192(sp)
    80006324:	6d2e                	ld	s10,200(sp)
    80006326:	6dce                	ld	s11,208(sp)
    80006328:	6e6e                	ld	t3,216(sp)
    8000632a:	7e8e                	ld	t4,224(sp)
    8000632c:	7f2e                	ld	t5,232(sp)
    8000632e:	7fce                	ld	t6,240(sp)
    80006330:	6111                	addi	sp,sp,256
    80006332:	10200073          	sret
    80006336:	00000013          	nop
    8000633a:	00000013          	nop
    8000633e:	0001                	nop

0000000080006340 <timervec>:
    80006340:	34051573          	csrrw	a0,mscratch,a0
    80006344:	e10c                	sd	a1,0(a0)
    80006346:	e510                	sd	a2,8(a0)
    80006348:	e914                	sd	a3,16(a0)
    8000634a:	6d0c                	ld	a1,24(a0)
    8000634c:	7110                	ld	a2,32(a0)
    8000634e:	6194                	ld	a3,0(a1)
    80006350:	96b2                	add	a3,a3,a2
    80006352:	e194                	sd	a3,0(a1)
    80006354:	4589                	li	a1,2
    80006356:	14459073          	csrw	sip,a1
    8000635a:	6914                	ld	a3,16(a0)
    8000635c:	6510                	ld	a2,8(a0)
    8000635e:	610c                	ld	a1,0(a0)
    80006360:	34051573          	csrrw	a0,mscratch,a0
    80006364:	30200073          	mret
	...

000000008000636a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000636a:	1141                	addi	sp,sp,-16
    8000636c:	e422                	sd	s0,8(sp)
    8000636e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006370:	0c0007b7          	lui	a5,0xc000
    80006374:	4705                	li	a4,1
    80006376:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006378:	c3d8                	sw	a4,4(a5)
}
    8000637a:	6422                	ld	s0,8(sp)
    8000637c:	0141                	addi	sp,sp,16
    8000637e:	8082                	ret

0000000080006380 <plicinithart>:

void
plicinithart(void)
{
    80006380:	1141                	addi	sp,sp,-16
    80006382:	e406                	sd	ra,8(sp)
    80006384:	e022                	sd	s0,0(sp)
    80006386:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006388:	ffffc097          	auipc	ra,0xffffc
    8000638c:	94c080e7          	jalr	-1716(ra) # 80001cd4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006390:	0085171b          	slliw	a4,a0,0x8
    80006394:	0c0027b7          	lui	a5,0xc002
    80006398:	97ba                	add	a5,a5,a4
    8000639a:	40200713          	li	a4,1026
    8000639e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800063a2:	00d5151b          	slliw	a0,a0,0xd
    800063a6:	0c2017b7          	lui	a5,0xc201
    800063aa:	97aa                	add	a5,a5,a0
    800063ac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800063b0:	60a2                	ld	ra,8(sp)
    800063b2:	6402                	ld	s0,0(sp)
    800063b4:	0141                	addi	sp,sp,16
    800063b6:	8082                	ret

00000000800063b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800063b8:	1141                	addi	sp,sp,-16
    800063ba:	e406                	sd	ra,8(sp)
    800063bc:	e022                	sd	s0,0(sp)
    800063be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063c0:	ffffc097          	auipc	ra,0xffffc
    800063c4:	914080e7          	jalr	-1772(ra) # 80001cd4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800063c8:	00d5151b          	slliw	a0,a0,0xd
    800063cc:	0c2017b7          	lui	a5,0xc201
    800063d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800063d2:	43c8                	lw	a0,4(a5)
    800063d4:	60a2                	ld	ra,8(sp)
    800063d6:	6402                	ld	s0,0(sp)
    800063d8:	0141                	addi	sp,sp,16
    800063da:	8082                	ret

00000000800063dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063dc:	1101                	addi	sp,sp,-32
    800063de:	ec06                	sd	ra,24(sp)
    800063e0:	e822                	sd	s0,16(sp)
    800063e2:	e426                	sd	s1,8(sp)
    800063e4:	1000                	addi	s0,sp,32
    800063e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063e8:	ffffc097          	auipc	ra,0xffffc
    800063ec:	8ec080e7          	jalr	-1812(ra) # 80001cd4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063f0:	00d5151b          	slliw	a0,a0,0xd
    800063f4:	0c2017b7          	lui	a5,0xc201
    800063f8:	97aa                	add	a5,a5,a0
    800063fa:	c3c4                	sw	s1,4(a5)
}
    800063fc:	60e2                	ld	ra,24(sp)
    800063fe:	6442                	ld	s0,16(sp)
    80006400:	64a2                	ld	s1,8(sp)
    80006402:	6105                	addi	sp,sp,32
    80006404:	8082                	ret

0000000080006406 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006406:	1141                	addi	sp,sp,-16
    80006408:	e406                	sd	ra,8(sp)
    8000640a:	e022                	sd	s0,0(sp)
    8000640c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000640e:	479d                	li	a5,7
    80006410:	04a7cc63          	blt	a5,a0,80006468 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006414:	0003c797          	auipc	a5,0x3c
    80006418:	9c478793          	addi	a5,a5,-1596 # 80041dd8 <disk>
    8000641c:	97aa                	add	a5,a5,a0
    8000641e:	0187c783          	lbu	a5,24(a5)
    80006422:	ebb9                	bnez	a5,80006478 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006424:	00451693          	slli	a3,a0,0x4
    80006428:	0003c797          	auipc	a5,0x3c
    8000642c:	9b078793          	addi	a5,a5,-1616 # 80041dd8 <disk>
    80006430:	6398                	ld	a4,0(a5)
    80006432:	9736                	add	a4,a4,a3
    80006434:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006438:	6398                	ld	a4,0(a5)
    8000643a:	9736                	add	a4,a4,a3
    8000643c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006440:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006444:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006448:	97aa                	add	a5,a5,a0
    8000644a:	4705                	li	a4,1
    8000644c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006450:	0003c517          	auipc	a0,0x3c
    80006454:	9a050513          	addi	a0,a0,-1632 # 80041df0 <disk+0x18>
    80006458:	ffffc097          	auipc	ra,0xffffc
    8000645c:	0ba080e7          	jalr	186(ra) # 80002512 <wakeup>
}
    80006460:	60a2                	ld	ra,8(sp)
    80006462:	6402                	ld	s0,0(sp)
    80006464:	0141                	addi	sp,sp,16
    80006466:	8082                	ret
    panic("free_desc 1");
    80006468:	00002517          	auipc	a0,0x2
    8000646c:	43850513          	addi	a0,a0,1080 # 800088a0 <syscalls+0x318>
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	0d0080e7          	jalr	208(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006478:	00002517          	auipc	a0,0x2
    8000647c:	43850513          	addi	a0,a0,1080 # 800088b0 <syscalls+0x328>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0c0080e7          	jalr	192(ra) # 80000540 <panic>

0000000080006488 <virtio_disk_init>:
{
    80006488:	1101                	addi	sp,sp,-32
    8000648a:	ec06                	sd	ra,24(sp)
    8000648c:	e822                	sd	s0,16(sp)
    8000648e:	e426                	sd	s1,8(sp)
    80006490:	e04a                	sd	s2,0(sp)
    80006492:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006494:	00002597          	auipc	a1,0x2
    80006498:	42c58593          	addi	a1,a1,1068 # 800088c0 <syscalls+0x338>
    8000649c:	0003c517          	auipc	a0,0x3c
    800064a0:	a6450513          	addi	a0,a0,-1436 # 80041f00 <disk+0x128>
    800064a4:	ffffb097          	auipc	ra,0xffffb
    800064a8:	8be080e7          	jalr	-1858(ra) # 80000d62 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064ac:	100017b7          	lui	a5,0x10001
    800064b0:	4398                	lw	a4,0(a5)
    800064b2:	2701                	sext.w	a4,a4
    800064b4:	747277b7          	lui	a5,0x74727
    800064b8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800064bc:	14f71b63          	bne	a4,a5,80006612 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064c0:	100017b7          	lui	a5,0x10001
    800064c4:	43dc                	lw	a5,4(a5)
    800064c6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064c8:	4709                	li	a4,2
    800064ca:	14e79463          	bne	a5,a4,80006612 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064ce:	100017b7          	lui	a5,0x10001
    800064d2:	479c                	lw	a5,8(a5)
    800064d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064d6:	12e79e63          	bne	a5,a4,80006612 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064da:	100017b7          	lui	a5,0x10001
    800064de:	47d8                	lw	a4,12(a5)
    800064e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064e2:	554d47b7          	lui	a5,0x554d4
    800064e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064ea:	12f71463          	bne	a4,a5,80006612 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064ee:	100017b7          	lui	a5,0x10001
    800064f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064f6:	4705                	li	a4,1
    800064f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064fa:	470d                	li	a4,3
    800064fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800064fe:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006500:	c7ffe6b7          	lui	a3,0xc7ffe
    80006504:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc847>
    80006508:	8f75                	and	a4,a4,a3
    8000650a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000650c:	472d                	li	a4,11
    8000650e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006510:	5bbc                	lw	a5,112(a5)
    80006512:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006516:	8ba1                	andi	a5,a5,8
    80006518:	10078563          	beqz	a5,80006622 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000651c:	100017b7          	lui	a5,0x10001
    80006520:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006524:	43fc                	lw	a5,68(a5)
    80006526:	2781                	sext.w	a5,a5
    80006528:	10079563          	bnez	a5,80006632 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000652c:	100017b7          	lui	a5,0x10001
    80006530:	5bdc                	lw	a5,52(a5)
    80006532:	2781                	sext.w	a5,a5
  if(max == 0)
    80006534:	10078763          	beqz	a5,80006642 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006538:	471d                	li	a4,7
    8000653a:	10f77c63          	bgeu	a4,a5,80006652 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	72a080e7          	jalr	1834(ra) # 80000c68 <kalloc>
    80006546:	0003c497          	auipc	s1,0x3c
    8000654a:	89248493          	addi	s1,s1,-1902 # 80041dd8 <disk>
    8000654e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	718080e7          	jalr	1816(ra) # 80000c68 <kalloc>
    80006558:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	70e080e7          	jalr	1806(ra) # 80000c68 <kalloc>
    80006562:	87aa                	mv	a5,a0
    80006564:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006566:	6088                	ld	a0,0(s1)
    80006568:	cd6d                	beqz	a0,80006662 <virtio_disk_init+0x1da>
    8000656a:	0003c717          	auipc	a4,0x3c
    8000656e:	87673703          	ld	a4,-1930(a4) # 80041de0 <disk+0x8>
    80006572:	cb65                	beqz	a4,80006662 <virtio_disk_init+0x1da>
    80006574:	c7fd                	beqz	a5,80006662 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006576:	6605                	lui	a2,0x1
    80006578:	4581                	li	a1,0
    8000657a:	ffffb097          	auipc	ra,0xffffb
    8000657e:	974080e7          	jalr	-1676(ra) # 80000eee <memset>
  memset(disk.avail, 0, PGSIZE);
    80006582:	0003c497          	auipc	s1,0x3c
    80006586:	85648493          	addi	s1,s1,-1962 # 80041dd8 <disk>
    8000658a:	6605                	lui	a2,0x1
    8000658c:	4581                	li	a1,0
    8000658e:	6488                	ld	a0,8(s1)
    80006590:	ffffb097          	auipc	ra,0xffffb
    80006594:	95e080e7          	jalr	-1698(ra) # 80000eee <memset>
  memset(disk.used, 0, PGSIZE);
    80006598:	6605                	lui	a2,0x1
    8000659a:	4581                	li	a1,0
    8000659c:	6888                	ld	a0,16(s1)
    8000659e:	ffffb097          	auipc	ra,0xffffb
    800065a2:	950080e7          	jalr	-1712(ra) # 80000eee <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800065a6:	100017b7          	lui	a5,0x10001
    800065aa:	4721                	li	a4,8
    800065ac:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800065ae:	4098                	lw	a4,0(s1)
    800065b0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800065b4:	40d8                	lw	a4,4(s1)
    800065b6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800065ba:	6498                	ld	a4,8(s1)
    800065bc:	0007069b          	sext.w	a3,a4
    800065c0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800065c4:	9701                	srai	a4,a4,0x20
    800065c6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800065ca:	6898                	ld	a4,16(s1)
    800065cc:	0007069b          	sext.w	a3,a4
    800065d0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800065d4:	9701                	srai	a4,a4,0x20
    800065d6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800065da:	4705                	li	a4,1
    800065dc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800065de:	00e48c23          	sb	a4,24(s1)
    800065e2:	00e48ca3          	sb	a4,25(s1)
    800065e6:	00e48d23          	sb	a4,26(s1)
    800065ea:	00e48da3          	sb	a4,27(s1)
    800065ee:	00e48e23          	sb	a4,28(s1)
    800065f2:	00e48ea3          	sb	a4,29(s1)
    800065f6:	00e48f23          	sb	a4,30(s1)
    800065fa:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800065fe:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006602:	0727a823          	sw	s2,112(a5)
}
    80006606:	60e2                	ld	ra,24(sp)
    80006608:	6442                	ld	s0,16(sp)
    8000660a:	64a2                	ld	s1,8(sp)
    8000660c:	6902                	ld	s2,0(sp)
    8000660e:	6105                	addi	sp,sp,32
    80006610:	8082                	ret
    panic("could not find virtio disk");
    80006612:	00002517          	auipc	a0,0x2
    80006616:	2be50513          	addi	a0,a0,702 # 800088d0 <syscalls+0x348>
    8000661a:	ffffa097          	auipc	ra,0xffffa
    8000661e:	f26080e7          	jalr	-218(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006622:	00002517          	auipc	a0,0x2
    80006626:	2ce50513          	addi	a0,a0,718 # 800088f0 <syscalls+0x368>
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	f16080e7          	jalr	-234(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006632:	00002517          	auipc	a0,0x2
    80006636:	2de50513          	addi	a0,a0,734 # 80008910 <syscalls+0x388>
    8000663a:	ffffa097          	auipc	ra,0xffffa
    8000663e:	f06080e7          	jalr	-250(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006642:	00002517          	auipc	a0,0x2
    80006646:	2ee50513          	addi	a0,a0,750 # 80008930 <syscalls+0x3a8>
    8000664a:	ffffa097          	auipc	ra,0xffffa
    8000664e:	ef6080e7          	jalr	-266(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006652:	00002517          	auipc	a0,0x2
    80006656:	2fe50513          	addi	a0,a0,766 # 80008950 <syscalls+0x3c8>
    8000665a:	ffffa097          	auipc	ra,0xffffa
    8000665e:	ee6080e7          	jalr	-282(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006662:	00002517          	auipc	a0,0x2
    80006666:	30e50513          	addi	a0,a0,782 # 80008970 <syscalls+0x3e8>
    8000666a:	ffffa097          	auipc	ra,0xffffa
    8000666e:	ed6080e7          	jalr	-298(ra) # 80000540 <panic>

0000000080006672 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006672:	7119                	addi	sp,sp,-128
    80006674:	fc86                	sd	ra,120(sp)
    80006676:	f8a2                	sd	s0,112(sp)
    80006678:	f4a6                	sd	s1,104(sp)
    8000667a:	f0ca                	sd	s2,96(sp)
    8000667c:	ecce                	sd	s3,88(sp)
    8000667e:	e8d2                	sd	s4,80(sp)
    80006680:	e4d6                	sd	s5,72(sp)
    80006682:	e0da                	sd	s6,64(sp)
    80006684:	fc5e                	sd	s7,56(sp)
    80006686:	f862                	sd	s8,48(sp)
    80006688:	f466                	sd	s9,40(sp)
    8000668a:	f06a                	sd	s10,32(sp)
    8000668c:	ec6e                	sd	s11,24(sp)
    8000668e:	0100                	addi	s0,sp,128
    80006690:	8aaa                	mv	s5,a0
    80006692:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006694:	00c52d03          	lw	s10,12(a0)
    80006698:	001d1d1b          	slliw	s10,s10,0x1
    8000669c:	1d02                	slli	s10,s10,0x20
    8000669e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800066a2:	0003c517          	auipc	a0,0x3c
    800066a6:	85e50513          	addi	a0,a0,-1954 # 80041f00 <disk+0x128>
    800066aa:	ffffa097          	auipc	ra,0xffffa
    800066ae:	748080e7          	jalr	1864(ra) # 80000df2 <acquire>
  for(int i = 0; i < 3; i++){
    800066b2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800066b4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800066b6:	0003bb97          	auipc	s7,0x3b
    800066ba:	722b8b93          	addi	s7,s7,1826 # 80041dd8 <disk>
  for(int i = 0; i < 3; i++){
    800066be:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800066c0:	0003cc97          	auipc	s9,0x3c
    800066c4:	840c8c93          	addi	s9,s9,-1984 # 80041f00 <disk+0x128>
    800066c8:	a08d                	j	8000672a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800066ca:	00fb8733          	add	a4,s7,a5
    800066ce:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800066d2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800066d4:	0207c563          	bltz	a5,800066fe <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800066d8:	2905                	addiw	s2,s2,1
    800066da:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800066dc:	05690c63          	beq	s2,s6,80006734 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800066e0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800066e2:	0003b717          	auipc	a4,0x3b
    800066e6:	6f670713          	addi	a4,a4,1782 # 80041dd8 <disk>
    800066ea:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800066ec:	01874683          	lbu	a3,24(a4)
    800066f0:	fee9                	bnez	a3,800066ca <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800066f2:	2785                	addiw	a5,a5,1
    800066f4:	0705                	addi	a4,a4,1
    800066f6:	fe979be3          	bne	a5,s1,800066ec <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800066fa:	57fd                	li	a5,-1
    800066fc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800066fe:	01205d63          	blez	s2,80006718 <virtio_disk_rw+0xa6>
    80006702:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006704:	000a2503          	lw	a0,0(s4)
    80006708:	00000097          	auipc	ra,0x0
    8000670c:	cfe080e7          	jalr	-770(ra) # 80006406 <free_desc>
      for(int j = 0; j < i; j++)
    80006710:	2d85                	addiw	s11,s11,1
    80006712:	0a11                	addi	s4,s4,4
    80006714:	ff2d98e3          	bne	s11,s2,80006704 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006718:	85e6                	mv	a1,s9
    8000671a:	0003b517          	auipc	a0,0x3b
    8000671e:	6d650513          	addi	a0,a0,1750 # 80041df0 <disk+0x18>
    80006722:	ffffc097          	auipc	ra,0xffffc
    80006726:	d8c080e7          	jalr	-628(ra) # 800024ae <sleep>
  for(int i = 0; i < 3; i++){
    8000672a:	f8040a13          	addi	s4,s0,-128
{
    8000672e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006730:	894e                	mv	s2,s3
    80006732:	b77d                	j	800066e0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006734:	f8042503          	lw	a0,-128(s0)
    80006738:	00a50713          	addi	a4,a0,10
    8000673c:	0712                	slli	a4,a4,0x4

  if(write)
    8000673e:	0003b797          	auipc	a5,0x3b
    80006742:	69a78793          	addi	a5,a5,1690 # 80041dd8 <disk>
    80006746:	00e786b3          	add	a3,a5,a4
    8000674a:	01803633          	snez	a2,s8
    8000674e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006750:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006754:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006758:	f6070613          	addi	a2,a4,-160
    8000675c:	6394                	ld	a3,0(a5)
    8000675e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006760:	00870593          	addi	a1,a4,8
    80006764:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006766:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006768:	0007b803          	ld	a6,0(a5)
    8000676c:	9642                	add	a2,a2,a6
    8000676e:	46c1                	li	a3,16
    80006770:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006772:	4585                	li	a1,1
    80006774:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006778:	f8442683          	lw	a3,-124(s0)
    8000677c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006780:	0692                	slli	a3,a3,0x4
    80006782:	9836                	add	a6,a6,a3
    80006784:	058a8613          	addi	a2,s5,88
    80006788:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000678c:	0007b803          	ld	a6,0(a5)
    80006790:	96c2                	add	a3,a3,a6
    80006792:	40000613          	li	a2,1024
    80006796:	c690                	sw	a2,8(a3)
  if(write)
    80006798:	001c3613          	seqz	a2,s8
    8000679c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800067a0:	00166613          	ori	a2,a2,1
    800067a4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800067a8:	f8842603          	lw	a2,-120(s0)
    800067ac:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800067b0:	00250693          	addi	a3,a0,2
    800067b4:	0692                	slli	a3,a3,0x4
    800067b6:	96be                	add	a3,a3,a5
    800067b8:	58fd                	li	a7,-1
    800067ba:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800067be:	0612                	slli	a2,a2,0x4
    800067c0:	9832                	add	a6,a6,a2
    800067c2:	f9070713          	addi	a4,a4,-112
    800067c6:	973e                	add	a4,a4,a5
    800067c8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800067cc:	6398                	ld	a4,0(a5)
    800067ce:	9732                	add	a4,a4,a2
    800067d0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800067d2:	4609                	li	a2,2
    800067d4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800067d8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800067dc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800067e0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800067e4:	6794                	ld	a3,8(a5)
    800067e6:	0026d703          	lhu	a4,2(a3)
    800067ea:	8b1d                	andi	a4,a4,7
    800067ec:	0706                	slli	a4,a4,0x1
    800067ee:	96ba                	add	a3,a3,a4
    800067f0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800067f4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800067f8:	6798                	ld	a4,8(a5)
    800067fa:	00275783          	lhu	a5,2(a4)
    800067fe:	2785                	addiw	a5,a5,1
    80006800:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006804:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006808:	100017b7          	lui	a5,0x10001
    8000680c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006810:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006814:	0003b917          	auipc	s2,0x3b
    80006818:	6ec90913          	addi	s2,s2,1772 # 80041f00 <disk+0x128>
  while(b->disk == 1) {
    8000681c:	4485                	li	s1,1
    8000681e:	00b79c63          	bne	a5,a1,80006836 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006822:	85ca                	mv	a1,s2
    80006824:	8556                	mv	a0,s5
    80006826:	ffffc097          	auipc	ra,0xffffc
    8000682a:	c88080e7          	jalr	-888(ra) # 800024ae <sleep>
  while(b->disk == 1) {
    8000682e:	004aa783          	lw	a5,4(s5)
    80006832:	fe9788e3          	beq	a5,s1,80006822 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006836:	f8042903          	lw	s2,-128(s0)
    8000683a:	00290713          	addi	a4,s2,2
    8000683e:	0712                	slli	a4,a4,0x4
    80006840:	0003b797          	auipc	a5,0x3b
    80006844:	59878793          	addi	a5,a5,1432 # 80041dd8 <disk>
    80006848:	97ba                	add	a5,a5,a4
    8000684a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000684e:	0003b997          	auipc	s3,0x3b
    80006852:	58a98993          	addi	s3,s3,1418 # 80041dd8 <disk>
    80006856:	00491713          	slli	a4,s2,0x4
    8000685a:	0009b783          	ld	a5,0(s3)
    8000685e:	97ba                	add	a5,a5,a4
    80006860:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006864:	854a                	mv	a0,s2
    80006866:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000686a:	00000097          	auipc	ra,0x0
    8000686e:	b9c080e7          	jalr	-1124(ra) # 80006406 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006872:	8885                	andi	s1,s1,1
    80006874:	f0ed                	bnez	s1,80006856 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006876:	0003b517          	auipc	a0,0x3b
    8000687a:	68a50513          	addi	a0,a0,1674 # 80041f00 <disk+0x128>
    8000687e:	ffffa097          	auipc	ra,0xffffa
    80006882:	628080e7          	jalr	1576(ra) # 80000ea6 <release>
}
    80006886:	70e6                	ld	ra,120(sp)
    80006888:	7446                	ld	s0,112(sp)
    8000688a:	74a6                	ld	s1,104(sp)
    8000688c:	7906                	ld	s2,96(sp)
    8000688e:	69e6                	ld	s3,88(sp)
    80006890:	6a46                	ld	s4,80(sp)
    80006892:	6aa6                	ld	s5,72(sp)
    80006894:	6b06                	ld	s6,64(sp)
    80006896:	7be2                	ld	s7,56(sp)
    80006898:	7c42                	ld	s8,48(sp)
    8000689a:	7ca2                	ld	s9,40(sp)
    8000689c:	7d02                	ld	s10,32(sp)
    8000689e:	6de2                	ld	s11,24(sp)
    800068a0:	6109                	addi	sp,sp,128
    800068a2:	8082                	ret

00000000800068a4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800068a4:	1101                	addi	sp,sp,-32
    800068a6:	ec06                	sd	ra,24(sp)
    800068a8:	e822                	sd	s0,16(sp)
    800068aa:	e426                	sd	s1,8(sp)
    800068ac:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800068ae:	0003b497          	auipc	s1,0x3b
    800068b2:	52a48493          	addi	s1,s1,1322 # 80041dd8 <disk>
    800068b6:	0003b517          	auipc	a0,0x3b
    800068ba:	64a50513          	addi	a0,a0,1610 # 80041f00 <disk+0x128>
    800068be:	ffffa097          	auipc	ra,0xffffa
    800068c2:	534080e7          	jalr	1332(ra) # 80000df2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800068c6:	10001737          	lui	a4,0x10001
    800068ca:	533c                	lw	a5,96(a4)
    800068cc:	8b8d                	andi	a5,a5,3
    800068ce:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800068d0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800068d4:	689c                	ld	a5,16(s1)
    800068d6:	0204d703          	lhu	a4,32(s1)
    800068da:	0027d783          	lhu	a5,2(a5)
    800068de:	04f70863          	beq	a4,a5,8000692e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800068e2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068e6:	6898                	ld	a4,16(s1)
    800068e8:	0204d783          	lhu	a5,32(s1)
    800068ec:	8b9d                	andi	a5,a5,7
    800068ee:	078e                	slli	a5,a5,0x3
    800068f0:	97ba                	add	a5,a5,a4
    800068f2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068f4:	00278713          	addi	a4,a5,2
    800068f8:	0712                	slli	a4,a4,0x4
    800068fa:	9726                	add	a4,a4,s1
    800068fc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006900:	e721                	bnez	a4,80006948 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006902:	0789                	addi	a5,a5,2
    80006904:	0792                	slli	a5,a5,0x4
    80006906:	97a6                	add	a5,a5,s1
    80006908:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000690a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000690e:	ffffc097          	auipc	ra,0xffffc
    80006912:	c04080e7          	jalr	-1020(ra) # 80002512 <wakeup>

    disk.used_idx += 1;
    80006916:	0204d783          	lhu	a5,32(s1)
    8000691a:	2785                	addiw	a5,a5,1
    8000691c:	17c2                	slli	a5,a5,0x30
    8000691e:	93c1                	srli	a5,a5,0x30
    80006920:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006924:	6898                	ld	a4,16(s1)
    80006926:	00275703          	lhu	a4,2(a4)
    8000692a:	faf71ce3          	bne	a4,a5,800068e2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000692e:	0003b517          	auipc	a0,0x3b
    80006932:	5d250513          	addi	a0,a0,1490 # 80041f00 <disk+0x128>
    80006936:	ffffa097          	auipc	ra,0xffffa
    8000693a:	570080e7          	jalr	1392(ra) # 80000ea6 <release>
}
    8000693e:	60e2                	ld	ra,24(sp)
    80006940:	6442                	ld	s0,16(sp)
    80006942:	64a2                	ld	s1,8(sp)
    80006944:	6105                	addi	sp,sp,32
    80006946:	8082                	ret
      panic("virtio_disk_intr status");
    80006948:	00002517          	auipc	a0,0x2
    8000694c:	04050513          	addi	a0,a0,64 # 80008988 <syscalls+0x400>
    80006950:	ffffa097          	auipc	ra,0xffffa
    80006954:	bf0080e7          	jalr	-1040(ra) # 80000540 <panic>
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
