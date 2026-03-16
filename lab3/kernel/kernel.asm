
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
    80000066:	1fe78793          	addi	a5,a5,510 # 80006260 <timervec>
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
    800000b0:	f9e78793          	addi	a5,a5,-98 # 8000104a <main>
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
    8000012e:	7ba080e7          	jalr	1978(ra) # 800028e4 <either_copyin>
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
    80000196:	c16080e7          	jalr	-1002(ra) # 80000da8 <acquire>
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
    800001c4:	b18080e7          	jalr	-1256(ra) # 80001cd8 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	566080e7          	jalr	1382(ra) # 8000272e <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	2b0080e7          	jalr	688(ra) # 80002486 <sleep>
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
    80000216:	67c080e7          	jalr	1660(ra) # 8000288e <either_copyout>
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
    80000232:	c2e080e7          	jalr	-978(ra) # 80000e5c <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	99450513          	addi	a0,a0,-1644 # 80010bd0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	c18080e7          	jalr	-1000(ra) # 80000e5c <release>
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
    800002d8:	ad4080e7          	jalr	-1324(ra) # 80000da8 <acquire>

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
    800002f6:	648080e7          	jalr	1608(ra) # 8000293a <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	8d650513          	addi	a0,a0,-1834 # 80010bd0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	b5a080e7          	jalr	-1190(ra) # 80000e5c <release>
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
    8000044a:	0a4080e7          	jalr	164(ra) # 800024ea <wakeup>
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
    8000046c:	8b0080e7          	jalr	-1872(ra) # 80000d18 <initlock>

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
    80000618:	794080e7          	jalr	1940(ra) # 80000da8 <acquire>
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
    80000776:	6ea080e7          	jalr	1770(ra) # 80000e5c <release>
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
    8000079c:	580080e7          	jalr	1408(ra) # 80000d18 <initlock>
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
    800007f2:	52a080e7          	jalr	1322(ra) # 80000d18 <initlock>
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
    8000080e:	552080e7          	jalr	1362(ra) # 80000d5c <push_off>

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
    8000083c:	5c4080e7          	jalr	1476(ra) # 80000dfc <pop_off>
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
    800008aa:	c44080e7          	jalr	-956(ra) # 800024ea <wakeup>
    
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
    800008ee:	4be080e7          	jalr	1214(ra) # 80000da8 <acquire>
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
    80000934:	b56080e7          	jalr	-1194(ra) # 80002486 <sleep>
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
    80000970:	4f0080e7          	jalr	1264(ra) # 80000e5c <release>
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
    800009da:	3d2080e7          	jalr	978(ra) # 80000da8 <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	474080e7          	jalr	1140(ra) # 80000e5c <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <refindex>:
int refcount[NPAGES];

int
refindex(void *pa)
{
    if (((uint64)pa % PGSIZE) != 0 || (uint64)pa < KERNBASE || (uint64)pa >= PHYSTOP)
    800009fa:	03451793          	slli	a5,a0,0x34
    800009fe:	eb99                	bnez	a5,80000a14 <refindex+0x1a>
    80000a00:	800007b7          	lui	a5,0x80000
    80000a04:	953e                	add	a0,a0,a5
    80000a06:	080007b7          	lui	a5,0x8000
    80000a0a:	00f57563          	bgeu	a0,a5,80000a14 <refindex+0x1a>
        panic("refindex");

    return ((uint64) pa - KERNBASE) / PGSIZE;
    80000a0e:	8131                	srli	a0,a0,0xc
}
    80000a10:	2501                	sext.w	a0,a0
    80000a12:	8082                	ret
{
    80000a14:	1141                	addi	sp,sp,-16
    80000a16:	e406                	sd	ra,8(sp)
    80000a18:	e022                	sd	s0,0(sp)
    80000a1a:	0800                	addi	s0,sp,16
        panic("refindex");
    80000a1c:	00007517          	auipc	a0,0x7
    80000a20:	65450513          	addi	a0,a0,1620 # 80008070 <digits+0x20>
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	b1c080e7          	jalr	-1252(ra) # 80000540 <panic>

0000000080000a2c <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a2c:	7179                	addi	sp,sp,-48
    80000a2e:	f406                	sd	ra,40(sp)
    80000a30:	f022                	sd	s0,32(sp)
    80000a32:	ec26                	sd	s1,24(sp)
    80000a34:	e84a                	sd	s2,16(sp)
    80000a36:	e44e                	sd	s3,8(sp)
    80000a38:	1800                	addi	s0,sp,48
    80000a3a:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a3c:	00008797          	auipc	a5,0x8
    80000a40:	0247b783          	ld	a5,36(a5) # 80008a60 <MAX_PAGES>
    80000a44:	c799                	beqz	a5,80000a52 <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000a46:	00008717          	auipc	a4,0x8
    80000a4a:	01273703          	ld	a4,18(a4) # 80008a58 <FREE_PAGES>
    80000a4e:	08f77863          	bgeu	a4,a5,80000ade <kfree+0xb2>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a52:	03449793          	slli	a5,s1,0x34
    80000a56:	efd5                	bnez	a5,80000b12 <kfree+0xe6>
    80000a58:	00041797          	auipc	a5,0x41
    80000a5c:	4c078793          	addi	a5,a5,1216 # 80041f18 <end>
    80000a60:	0af4e963          	bltu	s1,a5,80000b12 <kfree+0xe6>
    80000a64:	47c5                	li	a5,17
    80000a66:	07ee                	slli	a5,a5,0x1b
    80000a68:	0af4f563          	bgeu	s1,a5,80000b12 <kfree+0xe6>
        panic("kfree");

    // decrement refcount

    int i = refindex(pa);
    80000a6c:	8526                	mv	a0,s1
    80000a6e:	00000097          	auipc	ra,0x0
    80000a72:	f8c080e7          	jalr	-116(ra) # 800009fa <refindex>
    80000a76:	892a                	mv	s2,a0
    int empty;

    acquire(&refcountlock);
    80000a78:	00010517          	auipc	a0,0x10
    80000a7c:	25850513          	addi	a0,a0,600 # 80010cd0 <refcountlock>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	328080e7          	jalr	808(ra) # 80000da8 <acquire>
    if (refcount[i] > 0) refcount[i]--;
    80000a88:	00291713          	slli	a4,s2,0x2
    80000a8c:	00010797          	auipc	a5,0x10
    80000a90:	27c78793          	addi	a5,a5,636 # 80010d08 <refcount>
    80000a94:	97ba                	add	a5,a5,a4
    80000a96:	439c                	lw	a5,0(a5)
    80000a98:	00f05a63          	blez	a5,80000aac <kfree+0x80>
    80000a9c:	86ba                	mv	a3,a4
    80000a9e:	00010717          	auipc	a4,0x10
    80000aa2:	26a70713          	addi	a4,a4,618 # 80010d08 <refcount>
    80000aa6:	9736                	add	a4,a4,a3
    80000aa8:	37fd                	addiw	a5,a5,-1
    80000aaa:	c31c                	sw	a5,0(a4)
    empty = refcount[i] == 0;
    80000aac:	090a                	slli	s2,s2,0x2
    80000aae:	00010797          	auipc	a5,0x10
    80000ab2:	25a78793          	addi	a5,a5,602 # 80010d08 <refcount>
    80000ab6:	97ca                	add	a5,a5,s2
    80000ab8:	0007a903          	lw	s2,0(a5)
    release(&refcountlock);
    80000abc:	00010517          	auipc	a0,0x10
    80000ac0:	21450513          	addi	a0,a0,532 # 80010cd0 <refcountlock>
    80000ac4:	00000097          	auipc	ra,0x0
    80000ac8:	398080e7          	jalr	920(ra) # 80000e5c <release>

    if (!empty) return;
    80000acc:	04090b63          	beqz	s2,80000b22 <kfree+0xf6>
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}
    80000ad0:	70a2                	ld	ra,40(sp)
    80000ad2:	7402                	ld	s0,32(sp)
    80000ad4:	64e2                	ld	s1,24(sp)
    80000ad6:	6942                	ld	s2,16(sp)
    80000ad8:	69a2                	ld	s3,8(sp)
    80000ada:	6145                	addi	sp,sp,48
    80000adc:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000ade:	04800693          	li	a3,72
    80000ae2:	00007617          	auipc	a2,0x7
    80000ae6:	52660613          	addi	a2,a2,1318 # 80008008 <__func__.1>
    80000aea:	00007597          	auipc	a1,0x7
    80000aee:	59658593          	addi	a1,a1,1430 # 80008080 <digits+0x30>
    80000af2:	00007517          	auipc	a0,0x7
    80000af6:	59e50513          	addi	a0,a0,1438 # 80008090 <digits+0x40>
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	aa2080e7          	jalr	-1374(ra) # 8000059c <printf>
    80000b02:	00007517          	auipc	a0,0x7
    80000b06:	59e50513          	addi	a0,a0,1438 # 800080a0 <digits+0x50>
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	a36080e7          	jalr	-1482(ra) # 80000540 <panic>
        panic("kfree");
    80000b12:	00007517          	auipc	a0,0x7
    80000b16:	59e50513          	addi	a0,a0,1438 # 800080b0 <digits+0x60>
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	a26080e7          	jalr	-1498(ra) # 80000540 <panic>
    memset(pa, 1, PGSIZE);
    80000b22:	6605                	lui	a2,0x1
    80000b24:	4585                	li	a1,1
    80000b26:	8526                	mv	a0,s1
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	37c080e7          	jalr	892(ra) # 80000ea4 <memset>
    acquire(&kmem.lock);
    80000b30:	00010997          	auipc	s3,0x10
    80000b34:	1a098993          	addi	s3,s3,416 # 80010cd0 <refcountlock>
    80000b38:	00010917          	auipc	s2,0x10
    80000b3c:	1b090913          	addi	s2,s2,432 # 80010ce8 <kmem>
    80000b40:	854a                	mv	a0,s2
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	266080e7          	jalr	614(ra) # 80000da8 <acquire>
    r->next = kmem.freelist;
    80000b4a:	0309b783          	ld	a5,48(s3)
    80000b4e:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000b50:	0299b823          	sd	s1,48(s3)
    FREE_PAGES++;
    80000b54:	00008717          	auipc	a4,0x8
    80000b58:	f0470713          	addi	a4,a4,-252 # 80008a58 <FREE_PAGES>
    80000b5c:	631c                	ld	a5,0(a4)
    80000b5e:	0785                	addi	a5,a5,1
    80000b60:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000b62:	854a                	mv	a0,s2
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	2f8080e7          	jalr	760(ra) # 80000e5c <release>
    80000b6c:	b795                	j	80000ad0 <kfree+0xa4>

0000000080000b6e <freerange>:
{
    80000b6e:	7179                	addi	sp,sp,-48
    80000b70:	f406                	sd	ra,40(sp)
    80000b72:	f022                	sd	s0,32(sp)
    80000b74:	ec26                	sd	s1,24(sp)
    80000b76:	e84a                	sd	s2,16(sp)
    80000b78:	e44e                	sd	s3,8(sp)
    80000b7a:	e052                	sd	s4,0(sp)
    80000b7c:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000b7e:	6785                	lui	a5,0x1
    80000b80:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b84:	00e504b3          	add	s1,a0,a4
    80000b88:	777d                	lui	a4,0xfffff
    80000b8a:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b8c:	94be                	add	s1,s1,a5
    80000b8e:	0095ee63          	bltu	a1,s1,80000baa <freerange+0x3c>
    80000b92:	892e                	mv	s2,a1
        kfree(p);
    80000b94:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b96:	6985                	lui	s3,0x1
        kfree(p);
    80000b98:	01448533          	add	a0,s1,s4
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	e90080e7          	jalr	-368(ra) # 80000a2c <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ba4:	94ce                	add	s1,s1,s3
    80000ba6:	fe9979e3          	bgeu	s2,s1,80000b98 <freerange+0x2a>
}
    80000baa:	70a2                	ld	ra,40(sp)
    80000bac:	7402                	ld	s0,32(sp)
    80000bae:	64e2                	ld	s1,24(sp)
    80000bb0:	6942                	ld	s2,16(sp)
    80000bb2:	69a2                	ld	s3,8(sp)
    80000bb4:	6a02                	ld	s4,0(sp)
    80000bb6:	6145                	addi	sp,sp,48
    80000bb8:	8082                	ret

0000000080000bba <kinit>:
{
    80000bba:	1141                	addi	sp,sp,-16
    80000bbc:	e406                	sd	ra,8(sp)
    80000bbe:	e022                	sd	s0,0(sp)
    80000bc0:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000bc2:	00007597          	auipc	a1,0x7
    80000bc6:	4f658593          	addi	a1,a1,1270 # 800080b8 <digits+0x68>
    80000bca:	00010517          	auipc	a0,0x10
    80000bce:	11e50513          	addi	a0,a0,286 # 80010ce8 <kmem>
    80000bd2:	00000097          	auipc	ra,0x0
    80000bd6:	146080e7          	jalr	326(ra) # 80000d18 <initlock>
    initlock(&refcountlock, "refcount");
    80000bda:	00007597          	auipc	a1,0x7
    80000bde:	4e658593          	addi	a1,a1,1254 # 800080c0 <digits+0x70>
    80000be2:	00010517          	auipc	a0,0x10
    80000be6:	0ee50513          	addi	a0,a0,238 # 80010cd0 <refcountlock>
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	12e080e7          	jalr	302(ra) # 80000d18 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000bf2:	45c5                	li	a1,17
    80000bf4:	05ee                	slli	a1,a1,0x1b
    80000bf6:	00041517          	auipc	a0,0x41
    80000bfa:	32250513          	addi	a0,a0,802 # 80041f18 <end>
    80000bfe:	00000097          	auipc	ra,0x0
    80000c02:	f70080e7          	jalr	-144(ra) # 80000b6e <freerange>
    MAX_PAGES = FREE_PAGES;
    80000c06:	00008797          	auipc	a5,0x8
    80000c0a:	e527b783          	ld	a5,-430(a5) # 80008a58 <FREE_PAGES>
    80000c0e:	00008717          	auipc	a4,0x8
    80000c12:	e4f73923          	sd	a5,-430(a4) # 80008a60 <MAX_PAGES>
}
    80000c16:	60a2                	ld	ra,8(sp)
    80000c18:	6402                	ld	s0,0(sp)
    80000c1a:	0141                	addi	sp,sp,16
    80000c1c:	8082                	ret

0000000080000c1e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c1e:	7179                	addi	sp,sp,-48
    80000c20:	f406                	sd	ra,40(sp)
    80000c22:	f022                	sd	s0,32(sp)
    80000c24:	ec26                	sd	s1,24(sp)
    80000c26:	e84a                	sd	s2,16(sp)
    80000c28:	e44e                	sd	s3,8(sp)
    80000c2a:	1800                	addi	s0,sp,48
    assert(FREE_PAGES > 0);
    80000c2c:	00008797          	auipc	a5,0x8
    80000c30:	e2c7b783          	ld	a5,-468(a5) # 80008a58 <FREE_PAGES>
    80000c34:	cfd9                	beqz	a5,80000cd2 <kalloc+0xb4>
    struct run *r;

    acquire(&kmem.lock);
    80000c36:	00010517          	auipc	a0,0x10
    80000c3a:	0b250513          	addi	a0,a0,178 # 80010ce8 <kmem>
    80000c3e:	00000097          	auipc	ra,0x0
    80000c42:	16a080e7          	jalr	362(ra) # 80000da8 <acquire>
    r = kmem.freelist;
    80000c46:	00010917          	auipc	s2,0x10
    80000c4a:	0ba93903          	ld	s2,186(s2) # 80010d00 <kmem+0x18>
    if (r)
    80000c4e:	0a090c63          	beqz	s2,80000d06 <kalloc+0xe8>
        kmem.freelist = r->next;
    80000c52:	00093783          	ld	a5,0(s2)
    80000c56:	00010717          	auipc	a4,0x10
    80000c5a:	0af73523          	sd	a5,170(a4) # 80010d00 <kmem+0x18>
    release(&kmem.lock);
    80000c5e:	00010517          	auipc	a0,0x10
    80000c62:	08a50513          	addi	a0,a0,138 # 80010ce8 <kmem>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	1f6080e7          	jalr	502(ra) # 80000e5c <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000c6e:	6605                	lui	a2,0x1
    80000c70:	4595                	li	a1,5
    80000c72:	854a                	mv	a0,s2
    80000c74:	00000097          	auipc	ra,0x0
    80000c78:	230080e7          	jalr	560(ra) # 80000ea4 <memset>
    FREE_PAGES--;
    80000c7c:	00008717          	auipc	a4,0x8
    80000c80:	ddc70713          	addi	a4,a4,-548 # 80008a58 <FREE_PAGES>
    80000c84:	631c                	ld	a5,0(a4)
    80000c86:	17fd                	addi	a5,a5,-1
    80000c88:	e31c                	sd	a5,0(a4)

    int i = refindex((void*) r);
    80000c8a:	854a                	mv	a0,s2
    80000c8c:	00000097          	auipc	ra,0x0
    80000c90:	d6e080e7          	jalr	-658(ra) # 800009fa <refindex>
    80000c94:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000c96:	00010997          	auipc	s3,0x10
    80000c9a:	03a98993          	addi	s3,s3,58 # 80010cd0 <refcountlock>
    80000c9e:	854e                	mv	a0,s3
    80000ca0:	00000097          	auipc	ra,0x0
    80000ca4:	108080e7          	jalr	264(ra) # 80000da8 <acquire>
    refcount[i] = 1;
    80000ca8:	048a                	slli	s1,s1,0x2
    80000caa:	00010797          	auipc	a5,0x10
    80000cae:	05e78793          	addi	a5,a5,94 # 80010d08 <refcount>
    80000cb2:	97a6                	add	a5,a5,s1
    80000cb4:	4705                	li	a4,1
    80000cb6:	c398                	sw	a4,0(a5)
    release(&refcountlock);
    80000cb8:	854e                	mv	a0,s3
    80000cba:	00000097          	auipc	ra,0x0
    80000cbe:	1a2080e7          	jalr	418(ra) # 80000e5c <release>

    return (void *)r;
}
    80000cc2:	854a                	mv	a0,s2
    80000cc4:	70a2                	ld	ra,40(sp)
    80000cc6:	7402                	ld	s0,32(sp)
    80000cc8:	64e2                	ld	s1,24(sp)
    80000cca:	6942                	ld	s2,16(sp)
    80000ccc:	69a2                	ld	s3,8(sp)
    80000cce:	6145                	addi	sp,sp,48
    80000cd0:	8082                	ret
    assert(FREE_PAGES > 0);
    80000cd2:	06e00693          	li	a3,110
    80000cd6:	00007617          	auipc	a2,0x7
    80000cda:	32a60613          	addi	a2,a2,810 # 80008000 <etext>
    80000cde:	00007597          	auipc	a1,0x7
    80000ce2:	3a258593          	addi	a1,a1,930 # 80008080 <digits+0x30>
    80000ce6:	00007517          	auipc	a0,0x7
    80000cea:	3aa50513          	addi	a0,a0,938 # 80008090 <digits+0x40>
    80000cee:	00000097          	auipc	ra,0x0
    80000cf2:	8ae080e7          	jalr	-1874(ra) # 8000059c <printf>
    80000cf6:	00007517          	auipc	a0,0x7
    80000cfa:	3aa50513          	addi	a0,a0,938 # 800080a0 <digits+0x50>
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	842080e7          	jalr	-1982(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000d06:	00010517          	auipc	a0,0x10
    80000d0a:	fe250513          	addi	a0,a0,-30 # 80010ce8 <kmem>
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	14e080e7          	jalr	334(ra) # 80000e5c <release>
    if (r)
    80000d16:	b79d                	j	80000c7c <kalloc+0x5e>

0000000080000d18 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d18:	1141                	addi	sp,sp,-16
    80000d1a:	e422                	sd	s0,8(sp)
    80000d1c:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d1e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d20:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d24:	00053823          	sd	zero,16(a0)
}
    80000d28:	6422                	ld	s0,8(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret

0000000080000d2e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d2e:	411c                	lw	a5,0(a0)
    80000d30:	e399                	bnez	a5,80000d36 <holding+0x8>
    80000d32:	4501                	li	a0,0
  return r;
}
    80000d34:	8082                	ret
{
    80000d36:	1101                	addi	sp,sp,-32
    80000d38:	ec06                	sd	ra,24(sp)
    80000d3a:	e822                	sd	s0,16(sp)
    80000d3c:	e426                	sd	s1,8(sp)
    80000d3e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d40:	6904                	ld	s1,16(a0)
    80000d42:	00001097          	auipc	ra,0x1
    80000d46:	f7a080e7          	jalr	-134(ra) # 80001cbc <mycpu>
    80000d4a:	40a48533          	sub	a0,s1,a0
    80000d4e:	00153513          	seqz	a0,a0
}
    80000d52:	60e2                	ld	ra,24(sp)
    80000d54:	6442                	ld	s0,16(sp)
    80000d56:	64a2                	ld	s1,8(sp)
    80000d58:	6105                	addi	sp,sp,32
    80000d5a:	8082                	ret

0000000080000d5c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d5c:	1101                	addi	sp,sp,-32
    80000d5e:	ec06                	sd	ra,24(sp)
    80000d60:	e822                	sd	s0,16(sp)
    80000d62:	e426                	sd	s1,8(sp)
    80000d64:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d66:	100024f3          	csrr	s1,sstatus
    80000d6a:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d6e:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000d70:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d74:	00001097          	auipc	ra,0x1
    80000d78:	f48080e7          	jalr	-184(ra) # 80001cbc <mycpu>
    80000d7c:	5d3c                	lw	a5,120(a0)
    80000d7e:	cf89                	beqz	a5,80000d98 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d80:	00001097          	auipc	ra,0x1
    80000d84:	f3c080e7          	jalr	-196(ra) # 80001cbc <mycpu>
    80000d88:	5d3c                	lw	a5,120(a0)
    80000d8a:	2785                	addiw	a5,a5,1
    80000d8c:	dd3c                	sw	a5,120(a0)
}
    80000d8e:	60e2                	ld	ra,24(sp)
    80000d90:	6442                	ld	s0,16(sp)
    80000d92:	64a2                	ld	s1,8(sp)
    80000d94:	6105                	addi	sp,sp,32
    80000d96:	8082                	ret
    mycpu()->intena = old;
    80000d98:	00001097          	auipc	ra,0x1
    80000d9c:	f24080e7          	jalr	-220(ra) # 80001cbc <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000da0:	8085                	srli	s1,s1,0x1
    80000da2:	8885                	andi	s1,s1,1
    80000da4:	dd64                	sw	s1,124(a0)
    80000da6:	bfe9                	j	80000d80 <push_off+0x24>

0000000080000da8 <acquire>:
{
    80000da8:	1101                	addi	sp,sp,-32
    80000daa:	ec06                	sd	ra,24(sp)
    80000dac:	e822                	sd	s0,16(sp)
    80000dae:	e426                	sd	s1,8(sp)
    80000db0:	1000                	addi	s0,sp,32
    80000db2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000db4:	00000097          	auipc	ra,0x0
    80000db8:	fa8080e7          	jalr	-88(ra) # 80000d5c <push_off>
  if(holding(lk))
    80000dbc:	8526                	mv	a0,s1
    80000dbe:	00000097          	auipc	ra,0x0
    80000dc2:	f70080e7          	jalr	-144(ra) # 80000d2e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dc6:	4705                	li	a4,1
  if(holding(lk))
    80000dc8:	e115                	bnez	a0,80000dec <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dca:	87ba                	mv	a5,a4
    80000dcc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dd0:	2781                	sext.w	a5,a5
    80000dd2:	ffe5                	bnez	a5,80000dca <acquire+0x22>
  __sync_synchronize();
    80000dd4:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000dd8:	00001097          	auipc	ra,0x1
    80000ddc:	ee4080e7          	jalr	-284(ra) # 80001cbc <mycpu>
    80000de0:	e888                	sd	a0,16(s1)
}
    80000de2:	60e2                	ld	ra,24(sp)
    80000de4:	6442                	ld	s0,16(sp)
    80000de6:	64a2                	ld	s1,8(sp)
    80000de8:	6105                	addi	sp,sp,32
    80000dea:	8082                	ret
    panic("acquire");
    80000dec:	00007517          	auipc	a0,0x7
    80000df0:	2e450513          	addi	a0,a0,740 # 800080d0 <digits+0x80>
    80000df4:	fffff097          	auipc	ra,0xfffff
    80000df8:	74c080e7          	jalr	1868(ra) # 80000540 <panic>

0000000080000dfc <pop_off>:

void
pop_off(void)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e406                	sd	ra,8(sp)
    80000e00:	e022                	sd	s0,0(sp)
    80000e02:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e04:	00001097          	auipc	ra,0x1
    80000e08:	eb8080e7          	jalr	-328(ra) # 80001cbc <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000e0c:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000e10:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e12:	e78d                	bnez	a5,80000e3c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e14:	5d3c                	lw	a5,120(a0)
    80000e16:	02f05b63          	blez	a5,80000e4c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e1a:	37fd                	addiw	a5,a5,-1
    80000e1c:	0007871b          	sext.w	a4,a5
    80000e20:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e22:	eb09                	bnez	a4,80000e34 <pop_off+0x38>
    80000e24:	5d7c                	lw	a5,124(a0)
    80000e26:	c799                	beqz	a5,80000e34 <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000e28:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e2c:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000e30:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e34:	60a2                	ld	ra,8(sp)
    80000e36:	6402                	ld	s0,0(sp)
    80000e38:	0141                	addi	sp,sp,16
    80000e3a:	8082                	ret
    panic("pop_off - interruptible");
    80000e3c:	00007517          	auipc	a0,0x7
    80000e40:	29c50513          	addi	a0,a0,668 # 800080d8 <digits+0x88>
    80000e44:	fffff097          	auipc	ra,0xfffff
    80000e48:	6fc080e7          	jalr	1788(ra) # 80000540 <panic>
    panic("pop_off");
    80000e4c:	00007517          	auipc	a0,0x7
    80000e50:	2a450513          	addi	a0,a0,676 # 800080f0 <digits+0xa0>
    80000e54:	fffff097          	auipc	ra,0xfffff
    80000e58:	6ec080e7          	jalr	1772(ra) # 80000540 <panic>

0000000080000e5c <release>:
{
    80000e5c:	1101                	addi	sp,sp,-32
    80000e5e:	ec06                	sd	ra,24(sp)
    80000e60:	e822                	sd	s0,16(sp)
    80000e62:	e426                	sd	s1,8(sp)
    80000e64:	1000                	addi	s0,sp,32
    80000e66:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e68:	00000097          	auipc	ra,0x0
    80000e6c:	ec6080e7          	jalr	-314(ra) # 80000d2e <holding>
    80000e70:	c115                	beqz	a0,80000e94 <release+0x38>
  lk->cpu = 0;
    80000e72:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e76:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e7a:	0f50000f          	fence	iorw,ow
    80000e7e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e82:	00000097          	auipc	ra,0x0
    80000e86:	f7a080e7          	jalr	-134(ra) # 80000dfc <pop_off>
}
    80000e8a:	60e2                	ld	ra,24(sp)
    80000e8c:	6442                	ld	s0,16(sp)
    80000e8e:	64a2                	ld	s1,8(sp)
    80000e90:	6105                	addi	sp,sp,32
    80000e92:	8082                	ret
    panic("release");
    80000e94:	00007517          	auipc	a0,0x7
    80000e98:	26450513          	addi	a0,a0,612 # 800080f8 <digits+0xa8>
    80000e9c:	fffff097          	auipc	ra,0xfffff
    80000ea0:	6a4080e7          	jalr	1700(ra) # 80000540 <panic>

0000000080000ea4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e422                	sd	s0,8(sp)
    80000ea8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000eaa:	ca19                	beqz	a2,80000ec0 <memset+0x1c>
    80000eac:	87aa                	mv	a5,a0
    80000eae:	1602                	slli	a2,a2,0x20
    80000eb0:	9201                	srli	a2,a2,0x20
    80000eb2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000eb6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000eba:	0785                	addi	a5,a5,1
    80000ebc:	fee79de3          	bne	a5,a4,80000eb6 <memset+0x12>
  }
  return dst;
}
    80000ec0:	6422                	ld	s0,8(sp)
    80000ec2:	0141                	addi	sp,sp,16
    80000ec4:	8082                	ret

0000000080000ec6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ec6:	1141                	addi	sp,sp,-16
    80000ec8:	e422                	sd	s0,8(sp)
    80000eca:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ecc:	ca05                	beqz	a2,80000efc <memcmp+0x36>
    80000ece:	fff6069b          	addiw	a3,a2,-1
    80000ed2:	1682                	slli	a3,a3,0x20
    80000ed4:	9281                	srli	a3,a3,0x20
    80000ed6:	0685                	addi	a3,a3,1
    80000ed8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000eda:	00054783          	lbu	a5,0(a0)
    80000ede:	0005c703          	lbu	a4,0(a1)
    80000ee2:	00e79863          	bne	a5,a4,80000ef2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ee6:	0505                	addi	a0,a0,1
    80000ee8:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000eea:	fed518e3          	bne	a0,a3,80000eda <memcmp+0x14>
  }

  return 0;
    80000eee:	4501                	li	a0,0
    80000ef0:	a019                	j	80000ef6 <memcmp+0x30>
      return *s1 - *s2;
    80000ef2:	40e7853b          	subw	a0,a5,a4
}
    80000ef6:	6422                	ld	s0,8(sp)
    80000ef8:	0141                	addi	sp,sp,16
    80000efa:	8082                	ret
  return 0;
    80000efc:	4501                	li	a0,0
    80000efe:	bfe5                	j	80000ef6 <memcmp+0x30>

0000000080000f00 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f00:	1141                	addi	sp,sp,-16
    80000f02:	e422                	sd	s0,8(sp)
    80000f04:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f06:	c205                	beqz	a2,80000f26 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f08:	02a5e263          	bltu	a1,a0,80000f2c <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f0c:	1602                	slli	a2,a2,0x20
    80000f0e:	9201                	srli	a2,a2,0x20
    80000f10:	00c587b3          	add	a5,a1,a2
{
    80000f14:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f16:	0585                	addi	a1,a1,1
    80000f18:	0705                	addi	a4,a4,1
    80000f1a:	fff5c683          	lbu	a3,-1(a1)
    80000f1e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f22:	fef59ae3          	bne	a1,a5,80000f16 <memmove+0x16>

  return dst;
}
    80000f26:	6422                	ld	s0,8(sp)
    80000f28:	0141                	addi	sp,sp,16
    80000f2a:	8082                	ret
  if(s < d && s + n > d){
    80000f2c:	02061693          	slli	a3,a2,0x20
    80000f30:	9281                	srli	a3,a3,0x20
    80000f32:	00d58733          	add	a4,a1,a3
    80000f36:	fce57be3          	bgeu	a0,a4,80000f0c <memmove+0xc>
    d += n;
    80000f3a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f3c:	fff6079b          	addiw	a5,a2,-1
    80000f40:	1782                	slli	a5,a5,0x20
    80000f42:	9381                	srli	a5,a5,0x20
    80000f44:	fff7c793          	not	a5,a5
    80000f48:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f4a:	177d                	addi	a4,a4,-1
    80000f4c:	16fd                	addi	a3,a3,-1
    80000f4e:	00074603          	lbu	a2,0(a4)
    80000f52:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f56:	fee79ae3          	bne	a5,a4,80000f4a <memmove+0x4a>
    80000f5a:	b7f1                	j	80000f26 <memmove+0x26>

0000000080000f5c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f5c:	1141                	addi	sp,sp,-16
    80000f5e:	e406                	sd	ra,8(sp)
    80000f60:	e022                	sd	s0,0(sp)
    80000f62:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	f9c080e7          	jalr	-100(ra) # 80000f00 <memmove>
}
    80000f6c:	60a2                	ld	ra,8(sp)
    80000f6e:	6402                	ld	s0,0(sp)
    80000f70:	0141                	addi	sp,sp,16
    80000f72:	8082                	ret

0000000080000f74 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f74:	1141                	addi	sp,sp,-16
    80000f76:	e422                	sd	s0,8(sp)
    80000f78:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f7a:	ce11                	beqz	a2,80000f96 <strncmp+0x22>
    80000f7c:	00054783          	lbu	a5,0(a0)
    80000f80:	cf89                	beqz	a5,80000f9a <strncmp+0x26>
    80000f82:	0005c703          	lbu	a4,0(a1)
    80000f86:	00f71a63          	bne	a4,a5,80000f9a <strncmp+0x26>
    n--, p++, q++;
    80000f8a:	367d                	addiw	a2,a2,-1
    80000f8c:	0505                	addi	a0,a0,1
    80000f8e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f90:	f675                	bnez	a2,80000f7c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f92:	4501                	li	a0,0
    80000f94:	a809                	j	80000fa6 <strncmp+0x32>
    80000f96:	4501                	li	a0,0
    80000f98:	a039                	j	80000fa6 <strncmp+0x32>
  if(n == 0)
    80000f9a:	ca09                	beqz	a2,80000fac <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f9c:	00054503          	lbu	a0,0(a0)
    80000fa0:	0005c783          	lbu	a5,0(a1)
    80000fa4:	9d1d                	subw	a0,a0,a5
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret
    return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	bfe5                	j	80000fa6 <strncmp+0x32>

0000000080000fb0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fb0:	1141                	addi	sp,sp,-16
    80000fb2:	e422                	sd	s0,8(sp)
    80000fb4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fb6:	872a                	mv	a4,a0
    80000fb8:	8832                	mv	a6,a2
    80000fba:	367d                	addiw	a2,a2,-1
    80000fbc:	01005963          	blez	a6,80000fce <strncpy+0x1e>
    80000fc0:	0705                	addi	a4,a4,1
    80000fc2:	0005c783          	lbu	a5,0(a1)
    80000fc6:	fef70fa3          	sb	a5,-1(a4)
    80000fca:	0585                	addi	a1,a1,1
    80000fcc:	f7f5                	bnez	a5,80000fb8 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fce:	86ba                	mv	a3,a4
    80000fd0:	00c05c63          	blez	a2,80000fe8 <strncpy+0x38>
    *s++ = 0;
    80000fd4:	0685                	addi	a3,a3,1
    80000fd6:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fda:	40d707bb          	subw	a5,a4,a3
    80000fde:	37fd                	addiw	a5,a5,-1
    80000fe0:	010787bb          	addw	a5,a5,a6
    80000fe4:	fef048e3          	bgtz	a5,80000fd4 <strncpy+0x24>
  return os;
}
    80000fe8:	6422                	ld	s0,8(sp)
    80000fea:	0141                	addi	sp,sp,16
    80000fec:	8082                	ret

0000000080000fee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fee:	1141                	addi	sp,sp,-16
    80000ff0:	e422                	sd	s0,8(sp)
    80000ff2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ff4:	02c05363          	blez	a2,8000101a <safestrcpy+0x2c>
    80000ff8:	fff6069b          	addiw	a3,a2,-1
    80000ffc:	1682                	slli	a3,a3,0x20
    80000ffe:	9281                	srli	a3,a3,0x20
    80001000:	96ae                	add	a3,a3,a1
    80001002:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001004:	00d58963          	beq	a1,a3,80001016 <safestrcpy+0x28>
    80001008:	0585                	addi	a1,a1,1
    8000100a:	0785                	addi	a5,a5,1
    8000100c:	fff5c703          	lbu	a4,-1(a1)
    80001010:	fee78fa3          	sb	a4,-1(a5)
    80001014:	fb65                	bnez	a4,80001004 <safestrcpy+0x16>
    ;
  *s = 0;
    80001016:	00078023          	sb	zero,0(a5)
  return os;
}
    8000101a:	6422                	ld	s0,8(sp)
    8000101c:	0141                	addi	sp,sp,16
    8000101e:	8082                	ret

0000000080001020 <strlen>:

int
strlen(const char *s)
{
    80001020:	1141                	addi	sp,sp,-16
    80001022:	e422                	sd	s0,8(sp)
    80001024:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001026:	00054783          	lbu	a5,0(a0)
    8000102a:	cf91                	beqz	a5,80001046 <strlen+0x26>
    8000102c:	0505                	addi	a0,a0,1
    8000102e:	87aa                	mv	a5,a0
    80001030:	4685                	li	a3,1
    80001032:	9e89                	subw	a3,a3,a0
    80001034:	00f6853b          	addw	a0,a3,a5
    80001038:	0785                	addi	a5,a5,1
    8000103a:	fff7c703          	lbu	a4,-1(a5)
    8000103e:	fb7d                	bnez	a4,80001034 <strlen+0x14>
    ;
  return n;
}
    80001040:	6422                	ld	s0,8(sp)
    80001042:	0141                	addi	sp,sp,16
    80001044:	8082                	ret
  for(n = 0; s[n]; n++)
    80001046:	4501                	li	a0,0
    80001048:	bfe5                	j	80001040 <strlen+0x20>

000000008000104a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000104a:	1141                	addi	sp,sp,-16
    8000104c:	e406                	sd	ra,8(sp)
    8000104e:	e022                	sd	s0,0(sp)
    80001050:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001052:	00001097          	auipc	ra,0x1
    80001056:	c5a080e7          	jalr	-934(ra) # 80001cac <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000105a:	00008717          	auipc	a4,0x8
    8000105e:	a0e70713          	addi	a4,a4,-1522 # 80008a68 <started>
  if(cpuid() == 0){
    80001062:	c139                	beqz	a0,800010a8 <main+0x5e>
    while(started == 0)
    80001064:	431c                	lw	a5,0(a4)
    80001066:	2781                	sext.w	a5,a5
    80001068:	dff5                	beqz	a5,80001064 <main+0x1a>
      ;
    __sync_synchronize();
    8000106a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000106e:	00001097          	auipc	ra,0x1
    80001072:	c3e080e7          	jalr	-962(ra) # 80001cac <cpuid>
    80001076:	85aa                	mv	a1,a0
    80001078:	00007517          	auipc	a0,0x7
    8000107c:	0a050513          	addi	a0,a0,160 # 80008118 <digits+0xc8>
    80001080:	fffff097          	auipc	ra,0xfffff
    80001084:	51c080e7          	jalr	1308(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    80001088:	00000097          	auipc	ra,0x0
    8000108c:	0d8080e7          	jalr	216(ra) # 80001160 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001090:	00002097          	auipc	ra,0x2
    80001094:	b44080e7          	jalr	-1212(ra) # 80002bd4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001098:	00005097          	auipc	ra,0x5
    8000109c:	208080e7          	jalr	520(ra) # 800062a0 <plicinithart>
  }

  scheduler();        
    800010a0:	00001097          	auipc	ra,0x1
    800010a4:	2c4080e7          	jalr	708(ra) # 80002364 <scheduler>
    consoleinit();
    800010a8:	fffff097          	auipc	ra,0xfffff
    800010ac:	3a8080e7          	jalr	936(ra) # 80000450 <consoleinit>
    printfinit();
    800010b0:	fffff097          	auipc	ra,0xfffff
    800010b4:	6cc080e7          	jalr	1740(ra) # 8000077c <printfinit>
    printf("\n");
    800010b8:	00007517          	auipc	a0,0x7
    800010bc:	fe050513          	addi	a0,a0,-32 # 80008098 <digits+0x48>
    800010c0:	fffff097          	auipc	ra,0xfffff
    800010c4:	4dc080e7          	jalr	1244(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    800010c8:	00007517          	auipc	a0,0x7
    800010cc:	03850513          	addi	a0,a0,56 # 80008100 <digits+0xb0>
    800010d0:	fffff097          	auipc	ra,0xfffff
    800010d4:	4cc080e7          	jalr	1228(ra) # 8000059c <printf>
    printf("\n");
    800010d8:	00007517          	auipc	a0,0x7
    800010dc:	fc050513          	addi	a0,a0,-64 # 80008098 <digits+0x48>
    800010e0:	fffff097          	auipc	ra,0xfffff
    800010e4:	4bc080e7          	jalr	1212(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    800010e8:	00000097          	auipc	ra,0x0
    800010ec:	ad2080e7          	jalr	-1326(ra) # 80000bba <kinit>
    kvminit();       // create kernel page table
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	326080e7          	jalr	806(ra) # 80001416 <kvminit>
    kvminithart();   // turn on paging
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	068080e7          	jalr	104(ra) # 80001160 <kvminithart>
    procinit();      // process table
    80001100:	00001097          	auipc	ra,0x1
    80001104:	aca080e7          	jalr	-1334(ra) # 80001bca <procinit>
    trapinit();      // trap vectors
    80001108:	00002097          	auipc	ra,0x2
    8000110c:	aa4080e7          	jalr	-1372(ra) # 80002bac <trapinit>
    trapinithart();  // install kernel trap vector
    80001110:	00002097          	auipc	ra,0x2
    80001114:	ac4080e7          	jalr	-1340(ra) # 80002bd4 <trapinithart>
    plicinit();      // set up interrupt controller
    80001118:	00005097          	auipc	ra,0x5
    8000111c:	172080e7          	jalr	370(ra) # 8000628a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001120:	00005097          	auipc	ra,0x5
    80001124:	180080e7          	jalr	384(ra) # 800062a0 <plicinithart>
    binit();         // buffer cache
    80001128:	00002097          	auipc	ra,0x2
    8000112c:	314080e7          	jalr	788(ra) # 8000343c <binit>
    iinit();         // inode table
    80001130:	00003097          	auipc	ra,0x3
    80001134:	9b4080e7          	jalr	-1612(ra) # 80003ae4 <iinit>
    fileinit();      // file table
    80001138:	00004097          	auipc	ra,0x4
    8000113c:	95a080e7          	jalr	-1702(ra) # 80004a92 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001140:	00005097          	auipc	ra,0x5
    80001144:	268080e7          	jalr	616(ra) # 800063a8 <virtio_disk_init>
    userinit();      // first user process
    80001148:	00001097          	auipc	ra,0x1
    8000114c:	e68080e7          	jalr	-408(ra) # 80001fb0 <userinit>
    __sync_synchronize();
    80001150:	0ff0000f          	fence
    started = 1;
    80001154:	4785                	li	a5,1
    80001156:	00008717          	auipc	a4,0x8
    8000115a:	90f72923          	sw	a5,-1774(a4) # 80008a68 <started>
    8000115e:	b789                	j	800010a0 <main+0x56>

0000000080001160 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001160:	1141                	addi	sp,sp,-16
    80001162:	e422                	sd	s0,8(sp)
    80001164:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    80001166:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000116a:	00008797          	auipc	a5,0x8
    8000116e:	9067b783          	ld	a5,-1786(a5) # 80008a70 <kernel_pagetable>
    80001172:	83b1                	srli	a5,a5,0xc
    80001174:	577d                	li	a4,-1
    80001176:	177e                	slli	a4,a4,0x3f
    80001178:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    8000117a:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    8000117e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001182:	6422                	ld	s0,8(sp)
    80001184:	0141                	addi	sp,sp,16
    80001186:	8082                	ret

0000000080001188 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001188:	7139                	addi	sp,sp,-64
    8000118a:	fc06                	sd	ra,56(sp)
    8000118c:	f822                	sd	s0,48(sp)
    8000118e:	f426                	sd	s1,40(sp)
    80001190:	f04a                	sd	s2,32(sp)
    80001192:	ec4e                	sd	s3,24(sp)
    80001194:	e852                	sd	s4,16(sp)
    80001196:	e456                	sd	s5,8(sp)
    80001198:	e05a                	sd	s6,0(sp)
    8000119a:	0080                	addi	s0,sp,64
    8000119c:	84aa                	mv	s1,a0
    8000119e:	89ae                	mv	s3,a1
    800011a0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800011a2:	57fd                	li	a5,-1
    800011a4:	83e9                	srli	a5,a5,0x1a
    800011a6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011a8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011aa:	04b7f263          	bgeu	a5,a1,800011ee <walk+0x66>
    panic("walk");
    800011ae:	00007517          	auipc	a0,0x7
    800011b2:	f8250513          	addi	a0,a0,-126 # 80008130 <digits+0xe0>
    800011b6:	fffff097          	auipc	ra,0xfffff
    800011ba:	38a080e7          	jalr	906(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011be:	060a8663          	beqz	s5,8000122a <walk+0xa2>
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	a5c080e7          	jalr	-1444(ra) # 80000c1e <kalloc>
    800011ca:	84aa                	mv	s1,a0
    800011cc:	c529                	beqz	a0,80001216 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011ce:	6605                	lui	a2,0x1
    800011d0:	4581                	li	a1,0
    800011d2:	00000097          	auipc	ra,0x0
    800011d6:	cd2080e7          	jalr	-814(ra) # 80000ea4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011da:	00c4d793          	srli	a5,s1,0xc
    800011de:	07aa                	slli	a5,a5,0xa
    800011e0:	0017e793          	ori	a5,a5,1
    800011e4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011e8:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffbd0df>
    800011ea:	036a0063          	beq	s4,s6,8000120a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011ee:	0149d933          	srl	s2,s3,s4
    800011f2:	1ff97913          	andi	s2,s2,511
    800011f6:	090e                	slli	s2,s2,0x3
    800011f8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011fa:	00093483          	ld	s1,0(s2)
    800011fe:	0014f793          	andi	a5,s1,1
    80001202:	dfd5                	beqz	a5,800011be <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001204:	80a9                	srli	s1,s1,0xa
    80001206:	04b2                	slli	s1,s1,0xc
    80001208:	b7c5                	j	800011e8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000120a:	00c9d513          	srli	a0,s3,0xc
    8000120e:	1ff57513          	andi	a0,a0,511
    80001212:	050e                	slli	a0,a0,0x3
    80001214:	9526                	add	a0,a0,s1
}
    80001216:	70e2                	ld	ra,56(sp)
    80001218:	7442                	ld	s0,48(sp)
    8000121a:	74a2                	ld	s1,40(sp)
    8000121c:	7902                	ld	s2,32(sp)
    8000121e:	69e2                	ld	s3,24(sp)
    80001220:	6a42                	ld	s4,16(sp)
    80001222:	6aa2                	ld	s5,8(sp)
    80001224:	6b02                	ld	s6,0(sp)
    80001226:	6121                	addi	sp,sp,64
    80001228:	8082                	ret
        return 0;
    8000122a:	4501                	li	a0,0
    8000122c:	b7ed                	j	80001216 <walk+0x8e>

000000008000122e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000122e:	57fd                	li	a5,-1
    80001230:	83e9                	srli	a5,a5,0x1a
    80001232:	00b7f463          	bgeu	a5,a1,8000123a <walkaddr+0xc>
    return 0;
    80001236:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001238:	8082                	ret
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001242:	4601                	li	a2,0
    80001244:	00000097          	auipc	ra,0x0
    80001248:	f44080e7          	jalr	-188(ra) # 80001188 <walk>
  if(pte == 0)
    8000124c:	c105                	beqz	a0,8000126c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000124e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001250:	0117f693          	andi	a3,a5,17
    80001254:	4745                	li	a4,17
    return 0;
    80001256:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001258:	00e68663          	beq	a3,a4,80001264 <walkaddr+0x36>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret
  pa = PTE2PA(*pte);
    80001264:	83a9                	srli	a5,a5,0xa
    80001266:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000126a:	bfcd                	j	8000125c <walkaddr+0x2e>
    return 0;
    8000126c:	4501                	li	a0,0
    8000126e:	b7fd                	j	8000125c <walkaddr+0x2e>

0000000080001270 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001270:	715d                	addi	sp,sp,-80
    80001272:	e486                	sd	ra,72(sp)
    80001274:	e0a2                	sd	s0,64(sp)
    80001276:	fc26                	sd	s1,56(sp)
    80001278:	f84a                	sd	s2,48(sp)
    8000127a:	f44e                	sd	s3,40(sp)
    8000127c:	f052                	sd	s4,32(sp)
    8000127e:	ec56                	sd	s5,24(sp)
    80001280:	e85a                	sd	s6,16(sp)
    80001282:	e45e                	sd	s7,8(sp)
    80001284:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001286:	c639                	beqz	a2,800012d4 <mappages+0x64>
    80001288:	8aaa                	mv	s5,a0
    8000128a:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000128c:	777d                	lui	a4,0xfffff
    8000128e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001292:	fff58993          	addi	s3,a1,-1
    80001296:	99b2                	add	s3,s3,a2
    80001298:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000129c:	893e                	mv	s2,a5
    8000129e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800012a2:	6b85                	lui	s7,0x1
    800012a4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800012a8:	4605                	li	a2,1
    800012aa:	85ca                	mv	a1,s2
    800012ac:	8556                	mv	a0,s5
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	eda080e7          	jalr	-294(ra) # 80001188 <walk>
    800012b6:	cd1d                	beqz	a0,800012f4 <mappages+0x84>
    if(*pte & PTE_V)
    800012b8:	611c                	ld	a5,0(a0)
    800012ba:	8b85                	andi	a5,a5,1
    800012bc:	e785                	bnez	a5,800012e4 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800012be:	80b1                	srli	s1,s1,0xc
    800012c0:	04aa                	slli	s1,s1,0xa
    800012c2:	0164e4b3          	or	s1,s1,s6
    800012c6:	0014e493          	ori	s1,s1,1
    800012ca:	e104                	sd	s1,0(a0)
    if(a == last)
    800012cc:	05390063          	beq	s2,s3,8000130c <mappages+0x9c>
    a += PGSIZE;
    800012d0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800012d2:	bfc9                	j	800012a4 <mappages+0x34>
    panic("mappages: size");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6450513          	addi	a0,a0,-412 # 80008138 <digits+0xe8>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	264080e7          	jalr	612(ra) # 80000540 <panic>
      panic("mappages: remap");
    800012e4:	00007517          	auipc	a0,0x7
    800012e8:	e6450513          	addi	a0,a0,-412 # 80008148 <digits+0xf8>
    800012ec:	fffff097          	auipc	ra,0xfffff
    800012f0:	254080e7          	jalr	596(ra) # 80000540 <panic>
      return -1;
    800012f4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800012f6:	60a6                	ld	ra,72(sp)
    800012f8:	6406                	ld	s0,64(sp)
    800012fa:	74e2                	ld	s1,56(sp)
    800012fc:	7942                	ld	s2,48(sp)
    800012fe:	79a2                	ld	s3,40(sp)
    80001300:	7a02                	ld	s4,32(sp)
    80001302:	6ae2                	ld	s5,24(sp)
    80001304:	6b42                	ld	s6,16(sp)
    80001306:	6ba2                	ld	s7,8(sp)
    80001308:	6161                	addi	sp,sp,80
    8000130a:	8082                	ret
  return 0;
    8000130c:	4501                	li	a0,0
    8000130e:	b7e5                	j	800012f6 <mappages+0x86>

0000000080001310 <kvmmap>:
{
    80001310:	1141                	addi	sp,sp,-16
    80001312:	e406                	sd	ra,8(sp)
    80001314:	e022                	sd	s0,0(sp)
    80001316:	0800                	addi	s0,sp,16
    80001318:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000131a:	86b2                	mv	a3,a2
    8000131c:	863e                	mv	a2,a5
    8000131e:	00000097          	auipc	ra,0x0
    80001322:	f52080e7          	jalr	-174(ra) # 80001270 <mappages>
    80001326:	e509                	bnez	a0,80001330 <kvmmap+0x20>
}
    80001328:	60a2                	ld	ra,8(sp)
    8000132a:	6402                	ld	s0,0(sp)
    8000132c:	0141                	addi	sp,sp,16
    8000132e:	8082                	ret
    panic("kvmmap");
    80001330:	00007517          	auipc	a0,0x7
    80001334:	e2850513          	addi	a0,a0,-472 # 80008158 <digits+0x108>
    80001338:	fffff097          	auipc	ra,0xfffff
    8000133c:	208080e7          	jalr	520(ra) # 80000540 <panic>

0000000080001340 <kvmmake>:
{
    80001340:	1101                	addi	sp,sp,-32
    80001342:	ec06                	sd	ra,24(sp)
    80001344:	e822                	sd	s0,16(sp)
    80001346:	e426                	sd	s1,8(sp)
    80001348:	e04a                	sd	s2,0(sp)
    8000134a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	8d2080e7          	jalr	-1838(ra) # 80000c1e <kalloc>
    80001354:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001356:	6605                	lui	a2,0x1
    80001358:	4581                	li	a1,0
    8000135a:	00000097          	auipc	ra,0x0
    8000135e:	b4a080e7          	jalr	-1206(ra) # 80000ea4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001362:	4719                	li	a4,6
    80001364:	6685                	lui	a3,0x1
    80001366:	10000637          	lui	a2,0x10000
    8000136a:	100005b7          	lui	a1,0x10000
    8000136e:	8526                	mv	a0,s1
    80001370:	00000097          	auipc	ra,0x0
    80001374:	fa0080e7          	jalr	-96(ra) # 80001310 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001378:	4719                	li	a4,6
    8000137a:	6685                	lui	a3,0x1
    8000137c:	10001637          	lui	a2,0x10001
    80001380:	100015b7          	lui	a1,0x10001
    80001384:	8526                	mv	a0,s1
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	f8a080e7          	jalr	-118(ra) # 80001310 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000138e:	4719                	li	a4,6
    80001390:	004006b7          	lui	a3,0x400
    80001394:	0c000637          	lui	a2,0xc000
    80001398:	0c0005b7          	lui	a1,0xc000
    8000139c:	8526                	mv	a0,s1
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	f72080e7          	jalr	-142(ra) # 80001310 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013a6:	00007917          	auipc	s2,0x7
    800013aa:	c5a90913          	addi	s2,s2,-934 # 80008000 <etext>
    800013ae:	4729                	li	a4,10
    800013b0:	80007697          	auipc	a3,0x80007
    800013b4:	c5068693          	addi	a3,a3,-944 # 8000 <_entry-0x7fff8000>
    800013b8:	4605                	li	a2,1
    800013ba:	067e                	slli	a2,a2,0x1f
    800013bc:	85b2                	mv	a1,a2
    800013be:	8526                	mv	a0,s1
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	f50080e7          	jalr	-176(ra) # 80001310 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013c8:	4719                	li	a4,6
    800013ca:	46c5                	li	a3,17
    800013cc:	06ee                	slli	a3,a3,0x1b
    800013ce:	412686b3          	sub	a3,a3,s2
    800013d2:	864a                	mv	a2,s2
    800013d4:	85ca                	mv	a1,s2
    800013d6:	8526                	mv	a0,s1
    800013d8:	00000097          	auipc	ra,0x0
    800013dc:	f38080e7          	jalr	-200(ra) # 80001310 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013e0:	4729                	li	a4,10
    800013e2:	6685                	lui	a3,0x1
    800013e4:	00006617          	auipc	a2,0x6
    800013e8:	c1c60613          	addi	a2,a2,-996 # 80007000 <_trampoline>
    800013ec:	040005b7          	lui	a1,0x4000
    800013f0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800013f2:	05b2                	slli	a1,a1,0xc
    800013f4:	8526                	mv	a0,s1
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	f1a080e7          	jalr	-230(ra) # 80001310 <kvmmap>
  proc_mapstacks(kpgtbl);
    800013fe:	8526                	mv	a0,s1
    80001400:	00000097          	auipc	ra,0x0
    80001404:	734080e7          	jalr	1844(ra) # 80001b34 <proc_mapstacks>
}
    80001408:	8526                	mv	a0,s1
    8000140a:	60e2                	ld	ra,24(sp)
    8000140c:	6442                	ld	s0,16(sp)
    8000140e:	64a2                	ld	s1,8(sp)
    80001410:	6902                	ld	s2,0(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret

0000000080001416 <kvminit>:
{
    80001416:	1141                	addi	sp,sp,-16
    80001418:	e406                	sd	ra,8(sp)
    8000141a:	e022                	sd	s0,0(sp)
    8000141c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	f22080e7          	jalr	-222(ra) # 80001340 <kvmmake>
    80001426:	00007797          	auipc	a5,0x7
    8000142a:	64a7b523          	sd	a0,1610(a5) # 80008a70 <kernel_pagetable>
}
    8000142e:	60a2                	ld	ra,8(sp)
    80001430:	6402                	ld	s0,0(sp)
    80001432:	0141                	addi	sp,sp,16
    80001434:	8082                	ret

0000000080001436 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000144c:	03459793          	slli	a5,a1,0x34
    80001450:	e795                	bnez	a5,8000147c <uvmunmap+0x46>
    80001452:	8a2a                	mv	s4,a0
    80001454:	892e                	mv	s2,a1
    80001456:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001458:	0632                	slli	a2,a2,0xc
    8000145a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000145e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001460:	6b05                	lui	s6,0x1
    80001462:	0735e263          	bltu	a1,s3,800014c6 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001466:	60a6                	ld	ra,72(sp)
    80001468:	6406                	ld	s0,64(sp)
    8000146a:	74e2                	ld	s1,56(sp)
    8000146c:	7942                	ld	s2,48(sp)
    8000146e:	79a2                	ld	s3,40(sp)
    80001470:	7a02                	ld	s4,32(sp)
    80001472:	6ae2                	ld	s5,24(sp)
    80001474:	6b42                	ld	s6,16(sp)
    80001476:	6ba2                	ld	s7,8(sp)
    80001478:	6161                	addi	sp,sp,80
    8000147a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000147c:	00007517          	auipc	a0,0x7
    80001480:	ce450513          	addi	a0,a0,-796 # 80008160 <digits+0x110>
    80001484:	fffff097          	auipc	ra,0xfffff
    80001488:	0bc080e7          	jalr	188(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    8000148c:	00007517          	auipc	a0,0x7
    80001490:	cec50513          	addi	a0,a0,-788 # 80008178 <digits+0x128>
    80001494:	fffff097          	auipc	ra,0xfffff
    80001498:	0ac080e7          	jalr	172(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    8000149c:	00007517          	auipc	a0,0x7
    800014a0:	cec50513          	addi	a0,a0,-788 # 80008188 <digits+0x138>
    800014a4:	fffff097          	auipc	ra,0xfffff
    800014a8:	09c080e7          	jalr	156(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800014ac:	00007517          	auipc	a0,0x7
    800014b0:	cf450513          	addi	a0,a0,-780 # 800081a0 <digits+0x150>
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	08c080e7          	jalr	140(ra) # 80000540 <panic>
    *pte = 0;
    800014bc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014c0:	995a                	add	s2,s2,s6
    800014c2:	fb3972e3          	bgeu	s2,s3,80001466 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014c6:	4601                	li	a2,0
    800014c8:	85ca                	mv	a1,s2
    800014ca:	8552                	mv	a0,s4
    800014cc:	00000097          	auipc	ra,0x0
    800014d0:	cbc080e7          	jalr	-836(ra) # 80001188 <walk>
    800014d4:	84aa                	mv	s1,a0
    800014d6:	d95d                	beqz	a0,8000148c <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800014d8:	6108                	ld	a0,0(a0)
    800014da:	00157793          	andi	a5,a0,1
    800014de:	dfdd                	beqz	a5,8000149c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014e0:	3ff57793          	andi	a5,a0,1023
    800014e4:	fd7784e3          	beq	a5,s7,800014ac <uvmunmap+0x76>
    if(do_free){
    800014e8:	fc0a8ae3          	beqz	s5,800014bc <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800014ec:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800014ee:	0532                	slli	a0,a0,0xc
    800014f0:	fffff097          	auipc	ra,0xfffff
    800014f4:	53c080e7          	jalr	1340(ra) # 80000a2c <kfree>
    800014f8:	b7d1                	j	800014bc <uvmunmap+0x86>

00000000800014fa <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800014fa:	1101                	addi	sp,sp,-32
    800014fc:	ec06                	sd	ra,24(sp)
    800014fe:	e822                	sd	s0,16(sp)
    80001500:	e426                	sd	s1,8(sp)
    80001502:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	71a080e7          	jalr	1818(ra) # 80000c1e <kalloc>
    8000150c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000150e:	c519                	beqz	a0,8000151c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001510:	6605                	lui	a2,0x1
    80001512:	4581                	li	a1,0
    80001514:	00000097          	auipc	ra,0x0
    80001518:	990080e7          	jalr	-1648(ra) # 80000ea4 <memset>
  return pagetable;
}
    8000151c:	8526                	mv	a0,s1
    8000151e:	60e2                	ld	ra,24(sp)
    80001520:	6442                	ld	s0,16(sp)
    80001522:	64a2                	ld	s1,8(sp)
    80001524:	6105                	addi	sp,sp,32
    80001526:	8082                	ret

0000000080001528 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001528:	7179                	addi	sp,sp,-48
    8000152a:	f406                	sd	ra,40(sp)
    8000152c:	f022                	sd	s0,32(sp)
    8000152e:	ec26                	sd	s1,24(sp)
    80001530:	e84a                	sd	s2,16(sp)
    80001532:	e44e                	sd	s3,8(sp)
    80001534:	e052                	sd	s4,0(sp)
    80001536:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001538:	6785                	lui	a5,0x1
    8000153a:	04f67863          	bgeu	a2,a5,8000158a <uvmfirst+0x62>
    8000153e:	8a2a                	mv	s4,a0
    80001540:	89ae                	mv	s3,a1
    80001542:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001544:	fffff097          	auipc	ra,0xfffff
    80001548:	6da080e7          	jalr	1754(ra) # 80000c1e <kalloc>
    8000154c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000154e:	6605                	lui	a2,0x1
    80001550:	4581                	li	a1,0
    80001552:	00000097          	auipc	ra,0x0
    80001556:	952080e7          	jalr	-1710(ra) # 80000ea4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000155a:	4779                	li	a4,30
    8000155c:	86ca                	mv	a3,s2
    8000155e:	6605                	lui	a2,0x1
    80001560:	4581                	li	a1,0
    80001562:	8552                	mv	a0,s4
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d0c080e7          	jalr	-756(ra) # 80001270 <mappages>
  memmove(mem, src, sz);
    8000156c:	8626                	mv	a2,s1
    8000156e:	85ce                	mv	a1,s3
    80001570:	854a                	mv	a0,s2
    80001572:	00000097          	auipc	ra,0x0
    80001576:	98e080e7          	jalr	-1650(ra) # 80000f00 <memmove>
}
    8000157a:	70a2                	ld	ra,40(sp)
    8000157c:	7402                	ld	s0,32(sp)
    8000157e:	64e2                	ld	s1,24(sp)
    80001580:	6942                	ld	s2,16(sp)
    80001582:	69a2                	ld	s3,8(sp)
    80001584:	6a02                	ld	s4,0(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    panic("uvmfirst: more than a page");
    8000158a:	00007517          	auipc	a0,0x7
    8000158e:	c2e50513          	addi	a0,a0,-978 # 800081b8 <digits+0x168>
    80001592:	fffff097          	auipc	ra,0xfffff
    80001596:	fae080e7          	jalr	-82(ra) # 80000540 <panic>

000000008000159a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000159a:	1101                	addi	sp,sp,-32
    8000159c:	ec06                	sd	ra,24(sp)
    8000159e:	e822                	sd	s0,16(sp)
    800015a0:	e426                	sd	s1,8(sp)
    800015a2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015a4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015a6:	00b67d63          	bgeu	a2,a1,800015c0 <uvmdealloc+0x26>
    800015aa:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015ac:	6785                	lui	a5,0x1
    800015ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015b0:	00f60733          	add	a4,a2,a5
    800015b4:	76fd                	lui	a3,0xfffff
    800015b6:	8f75                	and	a4,a4,a3
    800015b8:	97ae                	add	a5,a5,a1
    800015ba:	8ff5                	and	a5,a5,a3
    800015bc:	00f76863          	bltu	a4,a5,800015cc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800015c0:	8526                	mv	a0,s1
    800015c2:	60e2                	ld	ra,24(sp)
    800015c4:	6442                	ld	s0,16(sp)
    800015c6:	64a2                	ld	s1,8(sp)
    800015c8:	6105                	addi	sp,sp,32
    800015ca:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015cc:	8f99                	sub	a5,a5,a4
    800015ce:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800015d0:	4685                	li	a3,1
    800015d2:	0007861b          	sext.w	a2,a5
    800015d6:	85ba                	mv	a1,a4
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	e5e080e7          	jalr	-418(ra) # 80001436 <uvmunmap>
    800015e0:	b7c5                	j	800015c0 <uvmdealloc+0x26>

00000000800015e2 <uvmalloc>:
  if(newsz < oldsz)
    800015e2:	0ab66563          	bltu	a2,a1,8000168c <uvmalloc+0xaa>
{
    800015e6:	7139                	addi	sp,sp,-64
    800015e8:	fc06                	sd	ra,56(sp)
    800015ea:	f822                	sd	s0,48(sp)
    800015ec:	f426                	sd	s1,40(sp)
    800015ee:	f04a                	sd	s2,32(sp)
    800015f0:	ec4e                	sd	s3,24(sp)
    800015f2:	e852                	sd	s4,16(sp)
    800015f4:	e456                	sd	s5,8(sp)
    800015f6:	e05a                	sd	s6,0(sp)
    800015f8:	0080                	addi	s0,sp,64
    800015fa:	8aaa                	mv	s5,a0
    800015fc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015fe:	6785                	lui	a5,0x1
    80001600:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001602:	95be                	add	a1,a1,a5
    80001604:	77fd                	lui	a5,0xfffff
    80001606:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000160a:	08c9f363          	bgeu	s3,a2,80001690 <uvmalloc+0xae>
    8000160e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001610:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001614:	fffff097          	auipc	ra,0xfffff
    80001618:	60a080e7          	jalr	1546(ra) # 80000c1e <kalloc>
    8000161c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000161e:	c51d                	beqz	a0,8000164c <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001620:	6605                	lui	a2,0x1
    80001622:	4581                	li	a1,0
    80001624:	00000097          	auipc	ra,0x0
    80001628:	880080e7          	jalr	-1920(ra) # 80000ea4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000162c:	875a                	mv	a4,s6
    8000162e:	86a6                	mv	a3,s1
    80001630:	6605                	lui	a2,0x1
    80001632:	85ca                	mv	a1,s2
    80001634:	8556                	mv	a0,s5
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	c3a080e7          	jalr	-966(ra) # 80001270 <mappages>
    8000163e:	e90d                	bnez	a0,80001670 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001640:	6785                	lui	a5,0x1
    80001642:	993e                	add	s2,s2,a5
    80001644:	fd4968e3          	bltu	s2,s4,80001614 <uvmalloc+0x32>
  return newsz;
    80001648:	8552                	mv	a0,s4
    8000164a:	a809                	j	8000165c <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000164c:	864e                	mv	a2,s3
    8000164e:	85ca                	mv	a1,s2
    80001650:	8556                	mv	a0,s5
    80001652:	00000097          	auipc	ra,0x0
    80001656:	f48080e7          	jalr	-184(ra) # 8000159a <uvmdealloc>
      return 0;
    8000165a:	4501                	li	a0,0
}
    8000165c:	70e2                	ld	ra,56(sp)
    8000165e:	7442                	ld	s0,48(sp)
    80001660:	74a2                	ld	s1,40(sp)
    80001662:	7902                	ld	s2,32(sp)
    80001664:	69e2                	ld	s3,24(sp)
    80001666:	6a42                	ld	s4,16(sp)
    80001668:	6aa2                	ld	s5,8(sp)
    8000166a:	6b02                	ld	s6,0(sp)
    8000166c:	6121                	addi	sp,sp,64
    8000166e:	8082                	ret
      kfree(mem);
    80001670:	8526                	mv	a0,s1
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	3ba080e7          	jalr	954(ra) # 80000a2c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000167a:	864e                	mv	a2,s3
    8000167c:	85ca                	mv	a1,s2
    8000167e:	8556                	mv	a0,s5
    80001680:	00000097          	auipc	ra,0x0
    80001684:	f1a080e7          	jalr	-230(ra) # 8000159a <uvmdealloc>
      return 0;
    80001688:	4501                	li	a0,0
    8000168a:	bfc9                	j	8000165c <uvmalloc+0x7a>
    return oldsz;
    8000168c:	852e                	mv	a0,a1
}
    8000168e:	8082                	ret
  return newsz;
    80001690:	8532                	mv	a0,a2
    80001692:	b7e9                	j	8000165c <uvmalloc+0x7a>

0000000080001694 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001694:	7179                	addi	sp,sp,-48
    80001696:	f406                	sd	ra,40(sp)
    80001698:	f022                	sd	s0,32(sp)
    8000169a:	ec26                	sd	s1,24(sp)
    8000169c:	e84a                	sd	s2,16(sp)
    8000169e:	e44e                	sd	s3,8(sp)
    800016a0:	e052                	sd	s4,0(sp)
    800016a2:	1800                	addi	s0,sp,48
    800016a4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016a6:	84aa                	mv	s1,a0
    800016a8:	6905                	lui	s2,0x1
    800016aa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ac:	4985                	li	s3,1
    800016ae:	a829                	j	800016c8 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016b0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800016b2:	00c79513          	slli	a0,a5,0xc
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	fde080e7          	jalr	-34(ra) # 80001694 <freewalk>
      pagetable[i] = 0;
    800016be:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800016c2:	04a1                	addi	s1,s1,8
    800016c4:	03248163          	beq	s1,s2,800016e6 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800016c8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ca:	00f7f713          	andi	a4,a5,15
    800016ce:	ff3701e3          	beq	a4,s3,800016b0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800016d2:	8b85                	andi	a5,a5,1
    800016d4:	d7fd                	beqz	a5,800016c2 <freewalk+0x2e>
      panic("freewalk: leaf");
    800016d6:	00007517          	auipc	a0,0x7
    800016da:	b0250513          	addi	a0,a0,-1278 # 800081d8 <digits+0x188>
    800016de:	fffff097          	auipc	ra,0xfffff
    800016e2:	e62080e7          	jalr	-414(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    800016e6:	8552                	mv	a0,s4
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	344080e7          	jalr	836(ra) # 80000a2c <kfree>
}
    800016f0:	70a2                	ld	ra,40(sp)
    800016f2:	7402                	ld	s0,32(sp)
    800016f4:	64e2                	ld	s1,24(sp)
    800016f6:	6942                	ld	s2,16(sp)
    800016f8:	69a2                	ld	s3,8(sp)
    800016fa:	6a02                	ld	s4,0(sp)
    800016fc:	6145                	addi	sp,sp,48
    800016fe:	8082                	ret

0000000080001700 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001700:	1101                	addi	sp,sp,-32
    80001702:	ec06                	sd	ra,24(sp)
    80001704:	e822                	sd	s0,16(sp)
    80001706:	e426                	sd	s1,8(sp)
    80001708:	1000                	addi	s0,sp,32
    8000170a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000170c:	e999                	bnez	a1,80001722 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000170e:	8526                	mv	a0,s1
    80001710:	00000097          	auipc	ra,0x0
    80001714:	f84080e7          	jalr	-124(ra) # 80001694 <freewalk>
}
    80001718:	60e2                	ld	ra,24(sp)
    8000171a:	6442                	ld	s0,16(sp)
    8000171c:	64a2                	ld	s1,8(sp)
    8000171e:	6105                	addi	sp,sp,32
    80001720:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001722:	6785                	lui	a5,0x1
    80001724:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001726:	95be                	add	a1,a1,a5
    80001728:	4685                	li	a3,1
    8000172a:	00c5d613          	srli	a2,a1,0xc
    8000172e:	4581                	li	a1,0
    80001730:	00000097          	auipc	ra,0x0
    80001734:	d06080e7          	jalr	-762(ra) # 80001436 <uvmunmap>
    80001738:	bfd9                	j	8000170e <uvmfree+0xe>

000000008000173a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000173a:	c679                	beqz	a2,80001808 <uvmcopy+0xce>
{
    8000173c:	715d                	addi	sp,sp,-80
    8000173e:	e486                	sd	ra,72(sp)
    80001740:	e0a2                	sd	s0,64(sp)
    80001742:	fc26                	sd	s1,56(sp)
    80001744:	f84a                	sd	s2,48(sp)
    80001746:	f44e                	sd	s3,40(sp)
    80001748:	f052                	sd	s4,32(sp)
    8000174a:	ec56                	sd	s5,24(sp)
    8000174c:	e85a                	sd	s6,16(sp)
    8000174e:	e45e                	sd	s7,8(sp)
    80001750:	0880                	addi	s0,sp,80
    80001752:	8b2a                	mv	s6,a0
    80001754:	8aae                	mv	s5,a1
    80001756:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001758:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000175a:	4601                	li	a2,0
    8000175c:	85ce                	mv	a1,s3
    8000175e:	855a                	mv	a0,s6
    80001760:	00000097          	auipc	ra,0x0
    80001764:	a28080e7          	jalr	-1496(ra) # 80001188 <walk>
    80001768:	c531                	beqz	a0,800017b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000176a:	6118                	ld	a4,0(a0)
    8000176c:	00177793          	andi	a5,a4,1
    80001770:	cbb1                	beqz	a5,800017c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001772:	00a75593          	srli	a1,a4,0xa
    80001776:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000177a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000177e:	fffff097          	auipc	ra,0xfffff
    80001782:	4a0080e7          	jalr	1184(ra) # 80000c1e <kalloc>
    80001786:	892a                	mv	s2,a0
    80001788:	c939                	beqz	a0,800017de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000178a:	6605                	lui	a2,0x1
    8000178c:	85de                	mv	a1,s7
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	772080e7          	jalr	1906(ra) # 80000f00 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001796:	8726                	mv	a4,s1
    80001798:	86ca                	mv	a3,s2
    8000179a:	6605                	lui	a2,0x1
    8000179c:	85ce                	mv	a1,s3
    8000179e:	8556                	mv	a0,s5
    800017a0:	00000097          	auipc	ra,0x0
    800017a4:	ad0080e7          	jalr	-1328(ra) # 80001270 <mappages>
    800017a8:	e515                	bnez	a0,800017d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800017aa:	6785                	lui	a5,0x1
    800017ac:	99be                	add	s3,s3,a5
    800017ae:	fb49e6e3          	bltu	s3,s4,8000175a <uvmcopy+0x20>
    800017b2:	a081                	j	800017f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800017b4:	00007517          	auipc	a0,0x7
    800017b8:	a3450513          	addi	a0,a0,-1484 # 800081e8 <digits+0x198>
    800017bc:	fffff097          	auipc	ra,0xfffff
    800017c0:	d84080e7          	jalr	-636(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800017c4:	00007517          	auipc	a0,0x7
    800017c8:	a4450513          	addi	a0,a0,-1468 # 80008208 <digits+0x1b8>
    800017cc:	fffff097          	auipc	ra,0xfffff
    800017d0:	d74080e7          	jalr	-652(ra) # 80000540 <panic>
      kfree(mem);
    800017d4:	854a                	mv	a0,s2
    800017d6:	fffff097          	auipc	ra,0xfffff
    800017da:	256080e7          	jalr	598(ra) # 80000a2c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017de:	4685                	li	a3,1
    800017e0:	00c9d613          	srli	a2,s3,0xc
    800017e4:	4581                	li	a1,0
    800017e6:	8556                	mv	a0,s5
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	c4e080e7          	jalr	-946(ra) # 80001436 <uvmunmap>
  return -1;
    800017f0:	557d                	li	a0,-1
}
    800017f2:	60a6                	ld	ra,72(sp)
    800017f4:	6406                	ld	s0,64(sp)
    800017f6:	74e2                	ld	s1,56(sp)
    800017f8:	7942                	ld	s2,48(sp)
    800017fa:	79a2                	ld	s3,40(sp)
    800017fc:	7a02                	ld	s4,32(sp)
    800017fe:	6ae2                	ld	s5,24(sp)
    80001800:	6b42                	ld	s6,16(sp)
    80001802:	6ba2                	ld	s7,8(sp)
    80001804:	6161                	addi	sp,sp,80
    80001806:	8082                	ret
  return 0;
    80001808:	4501                	li	a0,0
}
    8000180a:	8082                	ret

000000008000180c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000180c:	1141                	addi	sp,sp,-16
    8000180e:	e406                	sd	ra,8(sp)
    80001810:	e022                	sd	s0,0(sp)
    80001812:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001814:	4601                	li	a2,0
    80001816:	00000097          	auipc	ra,0x0
    8000181a:	972080e7          	jalr	-1678(ra) # 80001188 <walk>
  if(pte == 0)
    8000181e:	c901                	beqz	a0,8000182e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001820:	611c                	ld	a5,0(a0)
    80001822:	9bbd                	andi	a5,a5,-17
    80001824:	e11c                	sd	a5,0(a0)
}
    80001826:	60a2                	ld	ra,8(sp)
    80001828:	6402                	ld	s0,0(sp)
    8000182a:	0141                	addi	sp,sp,16
    8000182c:	8082                	ret
    panic("uvmclear");
    8000182e:	00007517          	auipc	a0,0x7
    80001832:	9fa50513          	addi	a0,a0,-1542 # 80008228 <digits+0x1d8>
    80001836:	fffff097          	auipc	ra,0xfffff
    8000183a:	d0a080e7          	jalr	-758(ra) # 80000540 <panic>

000000008000183e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000183e:	c6bd                	beqz	a3,800018ac <copyout+0x6e>
{
    80001840:	715d                	addi	sp,sp,-80
    80001842:	e486                	sd	ra,72(sp)
    80001844:	e0a2                	sd	s0,64(sp)
    80001846:	fc26                	sd	s1,56(sp)
    80001848:	f84a                	sd	s2,48(sp)
    8000184a:	f44e                	sd	s3,40(sp)
    8000184c:	f052                	sd	s4,32(sp)
    8000184e:	ec56                	sd	s5,24(sp)
    80001850:	e85a                	sd	s6,16(sp)
    80001852:	e45e                	sd	s7,8(sp)
    80001854:	e062                	sd	s8,0(sp)
    80001856:	0880                	addi	s0,sp,80
    80001858:	8b2a                	mv	s6,a0
    8000185a:	8c2e                	mv	s8,a1
    8000185c:	8a32                	mv	s4,a2
    8000185e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001860:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001862:	6a85                	lui	s5,0x1
    80001864:	a015                	j	80001888 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001866:	9562                	add	a0,a0,s8
    80001868:	0004861b          	sext.w	a2,s1
    8000186c:	85d2                	mv	a1,s4
    8000186e:	41250533          	sub	a0,a0,s2
    80001872:	fffff097          	auipc	ra,0xfffff
    80001876:	68e080e7          	jalr	1678(ra) # 80000f00 <memmove>

    len -= n;
    8000187a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000187e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001880:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001884:	02098263          	beqz	s3,800018a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001888:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000188c:	85ca                	mv	a1,s2
    8000188e:	855a                	mv	a0,s6
    80001890:	00000097          	auipc	ra,0x0
    80001894:	99e080e7          	jalr	-1634(ra) # 8000122e <walkaddr>
    if(pa0 == 0)
    80001898:	cd01                	beqz	a0,800018b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000189a:	418904b3          	sub	s1,s2,s8
    8000189e:	94d6                	add	s1,s1,s5
    800018a0:	fc99f3e3          	bgeu	s3,s1,80001866 <copyout+0x28>
    800018a4:	84ce                	mv	s1,s3
    800018a6:	b7c1                	j	80001866 <copyout+0x28>
  }
  return 0;
    800018a8:	4501                	li	a0,0
    800018aa:	a021                	j	800018b2 <copyout+0x74>
    800018ac:	4501                	li	a0,0
}
    800018ae:	8082                	ret
      return -1;
    800018b0:	557d                	li	a0,-1
}
    800018b2:	60a6                	ld	ra,72(sp)
    800018b4:	6406                	ld	s0,64(sp)
    800018b6:	74e2                	ld	s1,56(sp)
    800018b8:	7942                	ld	s2,48(sp)
    800018ba:	79a2                	ld	s3,40(sp)
    800018bc:	7a02                	ld	s4,32(sp)
    800018be:	6ae2                	ld	s5,24(sp)
    800018c0:	6b42                	ld	s6,16(sp)
    800018c2:	6ba2                	ld	s7,8(sp)
    800018c4:	6c02                	ld	s8,0(sp)
    800018c6:	6161                	addi	sp,sp,80
    800018c8:	8082                	ret

00000000800018ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018ca:	caa5                	beqz	a3,8000193a <copyin+0x70>
{
    800018cc:	715d                	addi	sp,sp,-80
    800018ce:	e486                	sd	ra,72(sp)
    800018d0:	e0a2                	sd	s0,64(sp)
    800018d2:	fc26                	sd	s1,56(sp)
    800018d4:	f84a                	sd	s2,48(sp)
    800018d6:	f44e                	sd	s3,40(sp)
    800018d8:	f052                	sd	s4,32(sp)
    800018da:	ec56                	sd	s5,24(sp)
    800018dc:	e85a                	sd	s6,16(sp)
    800018de:	e45e                	sd	s7,8(sp)
    800018e0:	e062                	sd	s8,0(sp)
    800018e2:	0880                	addi	s0,sp,80
    800018e4:	8b2a                	mv	s6,a0
    800018e6:	8a2e                	mv	s4,a1
    800018e8:	8c32                	mv	s8,a2
    800018ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018ee:	6a85                	lui	s5,0x1
    800018f0:	a01d                	j	80001916 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018f2:	018505b3          	add	a1,a0,s8
    800018f6:	0004861b          	sext.w	a2,s1
    800018fa:	412585b3          	sub	a1,a1,s2
    800018fe:	8552                	mv	a0,s4
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	600080e7          	jalr	1536(ra) # 80000f00 <memmove>

    len -= n;
    80001908:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000190c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000190e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001912:	02098263          	beqz	s3,80001936 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001916:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000191a:	85ca                	mv	a1,s2
    8000191c:	855a                	mv	a0,s6
    8000191e:	00000097          	auipc	ra,0x0
    80001922:	910080e7          	jalr	-1776(ra) # 8000122e <walkaddr>
    if(pa0 == 0)
    80001926:	cd01                	beqz	a0,8000193e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001928:	418904b3          	sub	s1,s2,s8
    8000192c:	94d6                	add	s1,s1,s5
    8000192e:	fc99f2e3          	bgeu	s3,s1,800018f2 <copyin+0x28>
    80001932:	84ce                	mv	s1,s3
    80001934:	bf7d                	j	800018f2 <copyin+0x28>
  }
  return 0;
    80001936:	4501                	li	a0,0
    80001938:	a021                	j	80001940 <copyin+0x76>
    8000193a:	4501                	li	a0,0
}
    8000193c:	8082                	ret
      return -1;
    8000193e:	557d                	li	a0,-1
}
    80001940:	60a6                	ld	ra,72(sp)
    80001942:	6406                	ld	s0,64(sp)
    80001944:	74e2                	ld	s1,56(sp)
    80001946:	7942                	ld	s2,48(sp)
    80001948:	79a2                	ld	s3,40(sp)
    8000194a:	7a02                	ld	s4,32(sp)
    8000194c:	6ae2                	ld	s5,24(sp)
    8000194e:	6b42                	ld	s6,16(sp)
    80001950:	6ba2                	ld	s7,8(sp)
    80001952:	6c02                	ld	s8,0(sp)
    80001954:	6161                	addi	sp,sp,80
    80001956:	8082                	ret

0000000080001958 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001958:	c2dd                	beqz	a3,800019fe <copyinstr+0xa6>
{
    8000195a:	715d                	addi	sp,sp,-80
    8000195c:	e486                	sd	ra,72(sp)
    8000195e:	e0a2                	sd	s0,64(sp)
    80001960:	fc26                	sd	s1,56(sp)
    80001962:	f84a                	sd	s2,48(sp)
    80001964:	f44e                	sd	s3,40(sp)
    80001966:	f052                	sd	s4,32(sp)
    80001968:	ec56                	sd	s5,24(sp)
    8000196a:	e85a                	sd	s6,16(sp)
    8000196c:	e45e                	sd	s7,8(sp)
    8000196e:	0880                	addi	s0,sp,80
    80001970:	8a2a                	mv	s4,a0
    80001972:	8b2e                	mv	s6,a1
    80001974:	8bb2                	mv	s7,a2
    80001976:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001978:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000197a:	6985                	lui	s3,0x1
    8000197c:	a02d                	j	800019a6 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000197e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001982:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001984:	37fd                	addiw	a5,a5,-1
    80001986:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000198a:	60a6                	ld	ra,72(sp)
    8000198c:	6406                	ld	s0,64(sp)
    8000198e:	74e2                	ld	s1,56(sp)
    80001990:	7942                	ld	s2,48(sp)
    80001992:	79a2                	ld	s3,40(sp)
    80001994:	7a02                	ld	s4,32(sp)
    80001996:	6ae2                	ld	s5,24(sp)
    80001998:	6b42                	ld	s6,16(sp)
    8000199a:	6ba2                	ld	s7,8(sp)
    8000199c:	6161                	addi	sp,sp,80
    8000199e:	8082                	ret
    srcva = va0 + PGSIZE;
    800019a0:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800019a4:	c8a9                	beqz	s1,800019f6 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800019a6:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800019aa:	85ca                	mv	a1,s2
    800019ac:	8552                	mv	a0,s4
    800019ae:	00000097          	auipc	ra,0x0
    800019b2:	880080e7          	jalr	-1920(ra) # 8000122e <walkaddr>
    if(pa0 == 0)
    800019b6:	c131                	beqz	a0,800019fa <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800019b8:	417906b3          	sub	a3,s2,s7
    800019bc:	96ce                	add	a3,a3,s3
    800019be:	00d4f363          	bgeu	s1,a3,800019c4 <copyinstr+0x6c>
    800019c2:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019c4:	955e                	add	a0,a0,s7
    800019c6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019ca:	daf9                	beqz	a3,800019a0 <copyinstr+0x48>
    800019cc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019ce:	41650633          	sub	a2,a0,s6
    800019d2:	fff48593          	addi	a1,s1,-1
    800019d6:	95da                	add	a1,a1,s6
    while(n > 0){
    800019d8:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800019da:	00f60733          	add	a4,a2,a5
    800019de:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd0e8>
    800019e2:	df51                	beqz	a4,8000197e <copyinstr+0x26>
        *dst = *p;
    800019e4:	00e78023          	sb	a4,0(a5)
      --max;
    800019e8:	40f584b3          	sub	s1,a1,a5
      dst++;
    800019ec:	0785                	addi	a5,a5,1
    while(n > 0){
    800019ee:	fed796e3          	bne	a5,a3,800019da <copyinstr+0x82>
      dst++;
    800019f2:	8b3e                	mv	s6,a5
    800019f4:	b775                	j	800019a0 <copyinstr+0x48>
    800019f6:	4781                	li	a5,0
    800019f8:	b771                	j	80001984 <copyinstr+0x2c>
      return -1;
    800019fa:	557d                	li	a0,-1
    800019fc:	b779                	j	8000198a <copyinstr+0x32>
  int got_null = 0;
    800019fe:	4781                	li	a5,0
  if(got_null){
    80001a00:	37fd                	addiw	a5,a5,-1
    80001a02:	0007851b          	sext.w	a0,a5
}
    80001a06:	8082                	ret

0000000080001a08 <transvirt>:

uint64 transvirt(uint64 vaddr, pagetable_t pagetable)
{
    80001a08:	1141                	addi	sp,sp,-16
    80001a0a:	e422                	sd	s0,8(sp)
    80001a0c:	0800                	addi	s0,sp,16
    80001a0e:	872a                	mv	a4,a0
    for (int level = 2; level > 0; level--)
    {
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001a10:	01e55793          	srli	a5,a0,0x1e
    80001a14:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001a18:	078e                	slli	a5,a5,0x3
    80001a1a:	95be                	add	a1,a1,a5
    80001a1c:	619c                	ld	a5,0(a1)
    80001a1e:	0017f513          	andi	a0,a5,1
    80001a22:	cd15                	beqz	a0,80001a5e <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001a24:	83a9                	srli	a5,a5,0xa
    80001a26:	00c79693          	slli	a3,a5,0xc
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001a2a:	01575793          	srli	a5,a4,0x15
    80001a2e:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001a32:	078e                	slli	a5,a5,0x3
    80001a34:	97b6                	add	a5,a5,a3
    80001a36:	639c                	ld	a5,0(a5)
    80001a38:	0017f513          	andi	a0,a5,1
    80001a3c:	c10d                	beqz	a0,80001a5e <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001a3e:	83a9                	srli	a5,a5,0xa
    80001a40:	00c79693          	slli	a3,a5,0xc
	} else {
	    return 0;
	}
    }
    uint64 pagenum = PTE2PA(pagetable[PX(0, vaddr)]);
    80001a44:	00c75793          	srli	a5,a4,0xc
    80001a48:	1ff7f793          	andi	a5,a5,511
    80001a4c:	078e                	slli	a5,a5,0x3
    80001a4e:	97b6                	add	a5,a5,a3
    80001a50:	639c                	ld	a5,0(a5)
    80001a52:	83a9                	srli	a5,a5,0xa
    80001a54:	07b2                	slli	a5,a5,0xc
    uint64 offset = vaddr & 0xFFF;
    80001a56:	1752                	slli	a4,a4,0x34
    80001a58:	9351                	srli	a4,a4,0x34
    return pagenum | offset;
    80001a5a:	00e7e533          	or	a0,a5,a4
}
    80001a5e:	6422                	ld	s0,8(sp)
    80001a60:	0141                	addi	sp,sp,16
    80001a62:	8082                	ret

0000000080001a64 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001a64:	715d                	addi	sp,sp,-80
    80001a66:	e486                	sd	ra,72(sp)
    80001a68:	e0a2                	sd	s0,64(sp)
    80001a6a:	fc26                	sd	s1,56(sp)
    80001a6c:	f84a                	sd	s2,48(sp)
    80001a6e:	f44e                	sd	s3,40(sp)
    80001a70:	f052                	sd	s4,32(sp)
    80001a72:	ec56                	sd	s5,24(sp)
    80001a74:	e85a                	sd	s6,16(sp)
    80001a76:	e45e                	sd	s7,8(sp)
    80001a78:	e062                	sd	s8,0(sp)
    80001a7a:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001a7c:	8792                	mv	a5,tp
    int id = r_tp();
    80001a7e:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001a80:	0002fa97          	auipc	s5,0x2f
    80001a84:	288a8a93          	addi	s5,s5,648 # 80030d08 <cpus>
    80001a88:	00779713          	slli	a4,a5,0x7
    80001a8c:	00ea86b3          	add	a3,s5,a4
    80001a90:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffbd0e8>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001a94:	0721                	addi	a4,a4,8
    80001a96:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001a98:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001a9a:	00007c17          	auipc	s8,0x7
    80001a9e:	f0ec0c13          	addi	s8,s8,-242 # 800089a8 <sched_pointer>
    80001aa2:	00000b97          	auipc	s7,0x0
    80001aa6:	fc2b8b93          	addi	s7,s7,-62 # 80001a64 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001aaa:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001aae:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001ab2:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001ab6:	0002f497          	auipc	s1,0x2f
    80001aba:	68248493          	addi	s1,s1,1666 # 80031138 <proc>
            if (p->state == RUNNABLE)
    80001abe:	498d                	li	s3,3
                p->state = RUNNING;
    80001ac0:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001ac2:	00035a17          	auipc	s4,0x35
    80001ac6:	076a0a13          	addi	s4,s4,118 # 80036b38 <tickslock>
    80001aca:	a81d                	j	80001b00 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001acc:	8526                	mv	a0,s1
    80001ace:	fffff097          	auipc	ra,0xfffff
    80001ad2:	38e080e7          	jalr	910(ra) # 80000e5c <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001ad6:	60a6                	ld	ra,72(sp)
    80001ad8:	6406                	ld	s0,64(sp)
    80001ada:	74e2                	ld	s1,56(sp)
    80001adc:	7942                	ld	s2,48(sp)
    80001ade:	79a2                	ld	s3,40(sp)
    80001ae0:	7a02                	ld	s4,32(sp)
    80001ae2:	6ae2                	ld	s5,24(sp)
    80001ae4:	6b42                	ld	s6,16(sp)
    80001ae6:	6ba2                	ld	s7,8(sp)
    80001ae8:	6c02                	ld	s8,0(sp)
    80001aea:	6161                	addi	sp,sp,80
    80001aec:	8082                	ret
            release(&p->lock);
    80001aee:	8526                	mv	a0,s1
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	36c080e7          	jalr	876(ra) # 80000e5c <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001af8:	16848493          	addi	s1,s1,360
    80001afc:	fb4487e3          	beq	s1,s4,80001aaa <rr_scheduler+0x46>
            acquire(&p->lock);
    80001b00:	8526                	mv	a0,s1
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	2a6080e7          	jalr	678(ra) # 80000da8 <acquire>
            if (p->state == RUNNABLE)
    80001b0a:	4c9c                	lw	a5,24(s1)
    80001b0c:	ff3791e3          	bne	a5,s3,80001aee <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001b10:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001b14:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    80001b18:	06048593          	addi	a1,s1,96
    80001b1c:	8556                	mv	a0,s5
    80001b1e:	00001097          	auipc	ra,0x1
    80001b22:	024080e7          	jalr	36(ra) # 80002b42 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001b26:	000c3783          	ld	a5,0(s8)
    80001b2a:	fb7791e3          	bne	a5,s7,80001acc <rr_scheduler+0x68>
                c->proc = 0;
    80001b2e:	00093023          	sd	zero,0(s2)
    80001b32:	bf75                	j	80001aee <rr_scheduler+0x8a>

0000000080001b34 <proc_mapstacks>:
{
    80001b34:	7139                	addi	sp,sp,-64
    80001b36:	fc06                	sd	ra,56(sp)
    80001b38:	f822                	sd	s0,48(sp)
    80001b3a:	f426                	sd	s1,40(sp)
    80001b3c:	f04a                	sd	s2,32(sp)
    80001b3e:	ec4e                	sd	s3,24(sp)
    80001b40:	e852                	sd	s4,16(sp)
    80001b42:	e456                	sd	s5,8(sp)
    80001b44:	e05a                	sd	s6,0(sp)
    80001b46:	0080                	addi	s0,sp,64
    80001b48:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001b4a:	0002f497          	auipc	s1,0x2f
    80001b4e:	5ee48493          	addi	s1,s1,1518 # 80031138 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001b52:	8b26                	mv	s6,s1
    80001b54:	00006a97          	auipc	s5,0x6
    80001b58:	4bca8a93          	addi	s5,s5,1212 # 80008010 <__func__.1+0x8>
    80001b5c:	04000937          	lui	s2,0x4000
    80001b60:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b62:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b64:	00035a17          	auipc	s4,0x35
    80001b68:	fd4a0a13          	addi	s4,s4,-44 # 80036b38 <tickslock>
        char *pa = kalloc();
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	0b2080e7          	jalr	178(ra) # 80000c1e <kalloc>
    80001b74:	862a                	mv	a2,a0
        if (pa == 0)
    80001b76:	c131                	beqz	a0,80001bba <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001b78:	416485b3          	sub	a1,s1,s6
    80001b7c:	858d                	srai	a1,a1,0x3
    80001b7e:	000ab783          	ld	a5,0(s5)
    80001b82:	02f585b3          	mul	a1,a1,a5
    80001b86:	2585                	addiw	a1,a1,1
    80001b88:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b8c:	4719                	li	a4,6
    80001b8e:	6685                	lui	a3,0x1
    80001b90:	40b905b3          	sub	a1,s2,a1
    80001b94:	854e                	mv	a0,s3
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	77a080e7          	jalr	1914(ra) # 80001310 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b9e:	16848493          	addi	s1,s1,360
    80001ba2:	fd4495e3          	bne	s1,s4,80001b6c <proc_mapstacks+0x38>
}
    80001ba6:	70e2                	ld	ra,56(sp)
    80001ba8:	7442                	ld	s0,48(sp)
    80001baa:	74a2                	ld	s1,40(sp)
    80001bac:	7902                	ld	s2,32(sp)
    80001bae:	69e2                	ld	s3,24(sp)
    80001bb0:	6a42                	ld	s4,16(sp)
    80001bb2:	6aa2                	ld	s5,8(sp)
    80001bb4:	6b02                	ld	s6,0(sp)
    80001bb6:	6121                	addi	sp,sp,64
    80001bb8:	8082                	ret
            panic("kalloc");
    80001bba:	00006517          	auipc	a0,0x6
    80001bbe:	67e50513          	addi	a0,a0,1662 # 80008238 <digits+0x1e8>
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	97e080e7          	jalr	-1666(ra) # 80000540 <panic>

0000000080001bca <procinit>:
{
    80001bca:	7139                	addi	sp,sp,-64
    80001bcc:	fc06                	sd	ra,56(sp)
    80001bce:	f822                	sd	s0,48(sp)
    80001bd0:	f426                	sd	s1,40(sp)
    80001bd2:	f04a                	sd	s2,32(sp)
    80001bd4:	ec4e                	sd	s3,24(sp)
    80001bd6:	e852                	sd	s4,16(sp)
    80001bd8:	e456                	sd	s5,8(sp)
    80001bda:	e05a                	sd	s6,0(sp)
    80001bdc:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001bde:	00006597          	auipc	a1,0x6
    80001be2:	66258593          	addi	a1,a1,1634 # 80008240 <digits+0x1f0>
    80001be6:	0002f517          	auipc	a0,0x2f
    80001bea:	52250513          	addi	a0,a0,1314 # 80031108 <pid_lock>
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	12a080e7          	jalr	298(ra) # 80000d18 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001bf6:	00006597          	auipc	a1,0x6
    80001bfa:	65258593          	addi	a1,a1,1618 # 80008248 <digits+0x1f8>
    80001bfe:	0002f517          	auipc	a0,0x2f
    80001c02:	52250513          	addi	a0,a0,1314 # 80031120 <wait_lock>
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	112080e7          	jalr	274(ra) # 80000d18 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001c0e:	0002f497          	auipc	s1,0x2f
    80001c12:	52a48493          	addi	s1,s1,1322 # 80031138 <proc>
        initlock(&p->lock, "proc");
    80001c16:	00006b17          	auipc	s6,0x6
    80001c1a:	642b0b13          	addi	s6,s6,1602 # 80008258 <digits+0x208>
        p->kstack = KSTACK((int)(p - proc));
    80001c1e:	8aa6                	mv	s5,s1
    80001c20:	00006a17          	auipc	s4,0x6
    80001c24:	3f0a0a13          	addi	s4,s4,1008 # 80008010 <__func__.1+0x8>
    80001c28:	04000937          	lui	s2,0x4000
    80001c2c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001c2e:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001c30:	00035997          	auipc	s3,0x35
    80001c34:	f0898993          	addi	s3,s3,-248 # 80036b38 <tickslock>
        initlock(&p->lock, "proc");
    80001c38:	85da                	mv	a1,s6
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	0dc080e7          	jalr	220(ra) # 80000d18 <initlock>
        p->state = UNUSED;
    80001c44:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001c48:	415487b3          	sub	a5,s1,s5
    80001c4c:	878d                	srai	a5,a5,0x3
    80001c4e:	000a3703          	ld	a4,0(s4)
    80001c52:	02e787b3          	mul	a5,a5,a4
    80001c56:	2785                	addiw	a5,a5,1
    80001c58:	00d7979b          	slliw	a5,a5,0xd
    80001c5c:	40f907b3          	sub	a5,s2,a5
    80001c60:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001c62:	16848493          	addi	s1,s1,360
    80001c66:	fd3499e3          	bne	s1,s3,80001c38 <procinit+0x6e>
}
    80001c6a:	70e2                	ld	ra,56(sp)
    80001c6c:	7442                	ld	s0,48(sp)
    80001c6e:	74a2                	ld	s1,40(sp)
    80001c70:	7902                	ld	s2,32(sp)
    80001c72:	69e2                	ld	s3,24(sp)
    80001c74:	6a42                	ld	s4,16(sp)
    80001c76:	6aa2                	ld	s5,8(sp)
    80001c78:	6b02                	ld	s6,0(sp)
    80001c7a:	6121                	addi	sp,sp,64
    80001c7c:	8082                	ret

0000000080001c7e <copy_array>:
{
    80001c7e:	1141                	addi	sp,sp,-16
    80001c80:	e422                	sd	s0,8(sp)
    80001c82:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001c84:	02c05163          	blez	a2,80001ca6 <copy_array+0x28>
    80001c88:	87aa                	mv	a5,a0
    80001c8a:	0505                	addi	a0,a0,1
    80001c8c:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001c8e:	1602                	slli	a2,a2,0x20
    80001c90:	9201                	srli	a2,a2,0x20
    80001c92:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001c96:	0007c703          	lbu	a4,0(a5)
    80001c9a:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001c9e:	0785                	addi	a5,a5,1
    80001ca0:	0585                	addi	a1,a1,1
    80001ca2:	fed79ae3          	bne	a5,a3,80001c96 <copy_array+0x18>
}
    80001ca6:	6422                	ld	s0,8(sp)
    80001ca8:	0141                	addi	sp,sp,16
    80001caa:	8082                	ret

0000000080001cac <cpuid>:
{
    80001cac:	1141                	addi	sp,sp,-16
    80001cae:	e422                	sd	s0,8(sp)
    80001cb0:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001cb2:	8512                	mv	a0,tp
}
    80001cb4:	2501                	sext.w	a0,a0
    80001cb6:	6422                	ld	s0,8(sp)
    80001cb8:	0141                	addi	sp,sp,16
    80001cba:	8082                	ret

0000000080001cbc <mycpu>:
{
    80001cbc:	1141                	addi	sp,sp,-16
    80001cbe:	e422                	sd	s0,8(sp)
    80001cc0:	0800                	addi	s0,sp,16
    80001cc2:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001cc4:	2781                	sext.w	a5,a5
    80001cc6:	079e                	slli	a5,a5,0x7
}
    80001cc8:	0002f517          	auipc	a0,0x2f
    80001ccc:	04050513          	addi	a0,a0,64 # 80030d08 <cpus>
    80001cd0:	953e                	add	a0,a0,a5
    80001cd2:	6422                	ld	s0,8(sp)
    80001cd4:	0141                	addi	sp,sp,16
    80001cd6:	8082                	ret

0000000080001cd8 <myproc>:
{
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	1000                	addi	s0,sp,32
    push_off();
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	07a080e7          	jalr	122(ra) # 80000d5c <push_off>
    80001cea:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001cec:	2781                	sext.w	a5,a5
    80001cee:	079e                	slli	a5,a5,0x7
    80001cf0:	0002f717          	auipc	a4,0x2f
    80001cf4:	01870713          	addi	a4,a4,24 # 80030d08 <cpus>
    80001cf8:	97ba                	add	a5,a5,a4
    80001cfa:	6384                	ld	s1,0(a5)
    pop_off();
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	100080e7          	jalr	256(ra) # 80000dfc <pop_off>
}
    80001d04:	8526                	mv	a0,s1
    80001d06:	60e2                	ld	ra,24(sp)
    80001d08:	6442                	ld	s0,16(sp)
    80001d0a:	64a2                	ld	s1,8(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret

0000000080001d10 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001d10:	1141                	addi	sp,sp,-16
    80001d12:	e406                	sd	ra,8(sp)
    80001d14:	e022                	sd	s0,0(sp)
    80001d16:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	fc0080e7          	jalr	-64(ra) # 80001cd8 <myproc>
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	13c080e7          	jalr	316(ra) # 80000e5c <release>

    if (first)
    80001d28:	00007797          	auipc	a5,0x7
    80001d2c:	c787a783          	lw	a5,-904(a5) # 800089a0 <first.1>
    80001d30:	eb89                	bnez	a5,80001d42 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001d32:	00001097          	auipc	ra,0x1
    80001d36:	eba080e7          	jalr	-326(ra) # 80002bec <usertrapret>
}
    80001d3a:	60a2                	ld	ra,8(sp)
    80001d3c:	6402                	ld	s0,0(sp)
    80001d3e:	0141                	addi	sp,sp,16
    80001d40:	8082                	ret
        first = 0;
    80001d42:	00007797          	auipc	a5,0x7
    80001d46:	c407af23          	sw	zero,-930(a5) # 800089a0 <first.1>
        fsinit(ROOTDEV);
    80001d4a:	4505                	li	a0,1
    80001d4c:	00002097          	auipc	ra,0x2
    80001d50:	d18080e7          	jalr	-744(ra) # 80003a64 <fsinit>
    80001d54:	bff9                	j	80001d32 <forkret+0x22>

0000000080001d56 <allocpid>:
{
    80001d56:	1101                	addi	sp,sp,-32
    80001d58:	ec06                	sd	ra,24(sp)
    80001d5a:	e822                	sd	s0,16(sp)
    80001d5c:	e426                	sd	s1,8(sp)
    80001d5e:	e04a                	sd	s2,0(sp)
    80001d60:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001d62:	0002f917          	auipc	s2,0x2f
    80001d66:	3a690913          	addi	s2,s2,934 # 80031108 <pid_lock>
    80001d6a:	854a                	mv	a0,s2
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	03c080e7          	jalr	60(ra) # 80000da8 <acquire>
    pid = nextpid;
    80001d74:	00007797          	auipc	a5,0x7
    80001d78:	c3c78793          	addi	a5,a5,-964 # 800089b0 <nextpid>
    80001d7c:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001d7e:	0014871b          	addiw	a4,s1,1
    80001d82:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001d84:	854a                	mv	a0,s2
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	0d6080e7          	jalr	214(ra) # 80000e5c <release>
}
    80001d8e:	8526                	mv	a0,s1
    80001d90:	60e2                	ld	ra,24(sp)
    80001d92:	6442                	ld	s0,16(sp)
    80001d94:	64a2                	ld	s1,8(sp)
    80001d96:	6902                	ld	s2,0(sp)
    80001d98:	6105                	addi	sp,sp,32
    80001d9a:	8082                	ret

0000000080001d9c <proc_pagetable>:
{
    80001d9c:	1101                	addi	sp,sp,-32
    80001d9e:	ec06                	sd	ra,24(sp)
    80001da0:	e822                	sd	s0,16(sp)
    80001da2:	e426                	sd	s1,8(sp)
    80001da4:	e04a                	sd	s2,0(sp)
    80001da6:	1000                	addi	s0,sp,32
    80001da8:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	750080e7          	jalr	1872(ra) # 800014fa <uvmcreate>
    80001db2:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001db4:	c121                	beqz	a0,80001df4 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001db6:	4729                	li	a4,10
    80001db8:	00005697          	auipc	a3,0x5
    80001dbc:	24868693          	addi	a3,a3,584 # 80007000 <_trampoline>
    80001dc0:	6605                	lui	a2,0x1
    80001dc2:	040005b7          	lui	a1,0x4000
    80001dc6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dc8:	05b2                	slli	a1,a1,0xc
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	4a6080e7          	jalr	1190(ra) # 80001270 <mappages>
    80001dd2:	02054863          	bltz	a0,80001e02 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001dd6:	4719                	li	a4,6
    80001dd8:	05893683          	ld	a3,88(s2)
    80001ddc:	6605                	lui	a2,0x1
    80001dde:	020005b7          	lui	a1,0x2000
    80001de2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001de4:	05b6                	slli	a1,a1,0xd
    80001de6:	8526                	mv	a0,s1
    80001de8:	fffff097          	auipc	ra,0xfffff
    80001dec:	488080e7          	jalr	1160(ra) # 80001270 <mappages>
    80001df0:	02054163          	bltz	a0,80001e12 <proc_pagetable+0x76>
}
    80001df4:	8526                	mv	a0,s1
    80001df6:	60e2                	ld	ra,24(sp)
    80001df8:	6442                	ld	s0,16(sp)
    80001dfa:	64a2                	ld	s1,8(sp)
    80001dfc:	6902                	ld	s2,0(sp)
    80001dfe:	6105                	addi	sp,sp,32
    80001e00:	8082                	ret
        uvmfree(pagetable, 0);
    80001e02:	4581                	li	a1,0
    80001e04:	8526                	mv	a0,s1
    80001e06:	00000097          	auipc	ra,0x0
    80001e0a:	8fa080e7          	jalr	-1798(ra) # 80001700 <uvmfree>
        return 0;
    80001e0e:	4481                	li	s1,0
    80001e10:	b7d5                	j	80001df4 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e12:	4681                	li	a3,0
    80001e14:	4605                	li	a2,1
    80001e16:	040005b7          	lui	a1,0x4000
    80001e1a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e1c:	05b2                	slli	a1,a1,0xc
    80001e1e:	8526                	mv	a0,s1
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	616080e7          	jalr	1558(ra) # 80001436 <uvmunmap>
        uvmfree(pagetable, 0);
    80001e28:	4581                	li	a1,0
    80001e2a:	8526                	mv	a0,s1
    80001e2c:	00000097          	auipc	ra,0x0
    80001e30:	8d4080e7          	jalr	-1836(ra) # 80001700 <uvmfree>
        return 0;
    80001e34:	4481                	li	s1,0
    80001e36:	bf7d                	j	80001df4 <proc_pagetable+0x58>

0000000080001e38 <proc_freepagetable>:
{
    80001e38:	1101                	addi	sp,sp,-32
    80001e3a:	ec06                	sd	ra,24(sp)
    80001e3c:	e822                	sd	s0,16(sp)
    80001e3e:	e426                	sd	s1,8(sp)
    80001e40:	e04a                	sd	s2,0(sp)
    80001e42:	1000                	addi	s0,sp,32
    80001e44:	84aa                	mv	s1,a0
    80001e46:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e48:	4681                	li	a3,0
    80001e4a:	4605                	li	a2,1
    80001e4c:	040005b7          	lui	a1,0x4000
    80001e50:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e52:	05b2                	slli	a1,a1,0xc
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	5e2080e7          	jalr	1506(ra) # 80001436 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e5c:	4681                	li	a3,0
    80001e5e:	4605                	li	a2,1
    80001e60:	020005b7          	lui	a1,0x2000
    80001e64:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e66:	05b6                	slli	a1,a1,0xd
    80001e68:	8526                	mv	a0,s1
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	5cc080e7          	jalr	1484(ra) # 80001436 <uvmunmap>
    uvmfree(pagetable, sz);
    80001e72:	85ca                	mv	a1,s2
    80001e74:	8526                	mv	a0,s1
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	88a080e7          	jalr	-1910(ra) # 80001700 <uvmfree>
}
    80001e7e:	60e2                	ld	ra,24(sp)
    80001e80:	6442                	ld	s0,16(sp)
    80001e82:	64a2                	ld	s1,8(sp)
    80001e84:	6902                	ld	s2,0(sp)
    80001e86:	6105                	addi	sp,sp,32
    80001e88:	8082                	ret

0000000080001e8a <freeproc>:
{
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	e426                	sd	s1,8(sp)
    80001e92:	1000                	addi	s0,sp,32
    80001e94:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001e96:	6d28                	ld	a0,88(a0)
    80001e98:	c509                	beqz	a0,80001ea2 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	b92080e7          	jalr	-1134(ra) # 80000a2c <kfree>
    p->trapframe = 0;
    80001ea2:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001ea6:	68a8                	ld	a0,80(s1)
    80001ea8:	c511                	beqz	a0,80001eb4 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001eaa:	64ac                	ld	a1,72(s1)
    80001eac:	00000097          	auipc	ra,0x0
    80001eb0:	f8c080e7          	jalr	-116(ra) # 80001e38 <proc_freepagetable>
    p->pagetable = 0;
    80001eb4:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001eb8:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001ebc:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001ec0:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001ec4:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001ec8:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001ecc:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001ed0:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001ed4:	0004ac23          	sw	zero,24(s1)
}
    80001ed8:	60e2                	ld	ra,24(sp)
    80001eda:	6442                	ld	s0,16(sp)
    80001edc:	64a2                	ld	s1,8(sp)
    80001ede:	6105                	addi	sp,sp,32
    80001ee0:	8082                	ret

0000000080001ee2 <allocproc>:
{
    80001ee2:	1101                	addi	sp,sp,-32
    80001ee4:	ec06                	sd	ra,24(sp)
    80001ee6:	e822                	sd	s0,16(sp)
    80001ee8:	e426                	sd	s1,8(sp)
    80001eea:	e04a                	sd	s2,0(sp)
    80001eec:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001eee:	0002f497          	auipc	s1,0x2f
    80001ef2:	24a48493          	addi	s1,s1,586 # 80031138 <proc>
    80001ef6:	00035917          	auipc	s2,0x35
    80001efa:	c4290913          	addi	s2,s2,-958 # 80036b38 <tickslock>
        acquire(&p->lock);
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	ea8080e7          	jalr	-344(ra) # 80000da8 <acquire>
        if (p->state == UNUSED)
    80001f08:	4c9c                	lw	a5,24(s1)
    80001f0a:	cf81                	beqz	a5,80001f22 <allocproc+0x40>
            release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	f4e080e7          	jalr	-178(ra) # 80000e5c <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f16:	16848493          	addi	s1,s1,360
    80001f1a:	ff2492e3          	bne	s1,s2,80001efe <allocproc+0x1c>
    return 0;
    80001f1e:	4481                	li	s1,0
    80001f20:	a889                	j	80001f72 <allocproc+0x90>
    p->pid = allocpid();
    80001f22:	00000097          	auipc	ra,0x0
    80001f26:	e34080e7          	jalr	-460(ra) # 80001d56 <allocpid>
    80001f2a:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001f2c:	4785                	li	a5,1
    80001f2e:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	cee080e7          	jalr	-786(ra) # 80000c1e <kalloc>
    80001f38:	892a                	mv	s2,a0
    80001f3a:	eca8                	sd	a0,88(s1)
    80001f3c:	c131                	beqz	a0,80001f80 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001f3e:	8526                	mv	a0,s1
    80001f40:	00000097          	auipc	ra,0x0
    80001f44:	e5c080e7          	jalr	-420(ra) # 80001d9c <proc_pagetable>
    80001f48:	892a                	mv	s2,a0
    80001f4a:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001f4c:	c531                	beqz	a0,80001f98 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001f4e:	07000613          	li	a2,112
    80001f52:	4581                	li	a1,0
    80001f54:	06048513          	addi	a0,s1,96
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	f4c080e7          	jalr	-180(ra) # 80000ea4 <memset>
    p->context.ra = (uint64)forkret;
    80001f60:	00000797          	auipc	a5,0x0
    80001f64:	db078793          	addi	a5,a5,-592 # 80001d10 <forkret>
    80001f68:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001f6a:	60bc                	ld	a5,64(s1)
    80001f6c:	6705                	lui	a4,0x1
    80001f6e:	97ba                	add	a5,a5,a4
    80001f70:	f4bc                	sd	a5,104(s1)
}
    80001f72:	8526                	mv	a0,s1
    80001f74:	60e2                	ld	ra,24(sp)
    80001f76:	6442                	ld	s0,16(sp)
    80001f78:	64a2                	ld	s1,8(sp)
    80001f7a:	6902                	ld	s2,0(sp)
    80001f7c:	6105                	addi	sp,sp,32
    80001f7e:	8082                	ret
        freeproc(p);
    80001f80:	8526                	mv	a0,s1
    80001f82:	00000097          	auipc	ra,0x0
    80001f86:	f08080e7          	jalr	-248(ra) # 80001e8a <freeproc>
        release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	ed0080e7          	jalr	-304(ra) # 80000e5c <release>
        return 0;
    80001f94:	84ca                	mv	s1,s2
    80001f96:	bff1                	j	80001f72 <allocproc+0x90>
        freeproc(p);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	00000097          	auipc	ra,0x0
    80001f9e:	ef0080e7          	jalr	-272(ra) # 80001e8a <freeproc>
        release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	eb8080e7          	jalr	-328(ra) # 80000e5c <release>
        return 0;
    80001fac:	84ca                	mv	s1,s2
    80001fae:	b7d1                	j	80001f72 <allocproc+0x90>

0000000080001fb0 <userinit>:
{
    80001fb0:	1101                	addi	sp,sp,-32
    80001fb2:	ec06                	sd	ra,24(sp)
    80001fb4:	e822                	sd	s0,16(sp)
    80001fb6:	e426                	sd	s1,8(sp)
    80001fb8:	1000                	addi	s0,sp,32
    p = allocproc();
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	f28080e7          	jalr	-216(ra) # 80001ee2 <allocproc>
    80001fc2:	84aa                	mv	s1,a0
    initproc = p;
    80001fc4:	00007797          	auipc	a5,0x7
    80001fc8:	aaa7ba23          	sd	a0,-1356(a5) # 80008a78 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001fcc:	03400613          	li	a2,52
    80001fd0:	00007597          	auipc	a1,0x7
    80001fd4:	9f058593          	addi	a1,a1,-1552 # 800089c0 <initcode>
    80001fd8:	6928                	ld	a0,80(a0)
    80001fda:	fffff097          	auipc	ra,0xfffff
    80001fde:	54e080e7          	jalr	1358(ra) # 80001528 <uvmfirst>
    p->sz = PGSIZE;
    80001fe2:	6785                	lui	a5,0x1
    80001fe4:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001fe6:	6cb8                	ld	a4,88(s1)
    80001fe8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001fec:	6cb8                	ld	a4,88(s1)
    80001fee:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ff0:	4641                	li	a2,16
    80001ff2:	00006597          	auipc	a1,0x6
    80001ff6:	26e58593          	addi	a1,a1,622 # 80008260 <digits+0x210>
    80001ffa:	15848513          	addi	a0,s1,344
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	ff0080e7          	jalr	-16(ra) # 80000fee <safestrcpy>
    p->cwd = namei("/");
    80002006:	00006517          	auipc	a0,0x6
    8000200a:	26a50513          	addi	a0,a0,618 # 80008270 <digits+0x220>
    8000200e:	00002097          	auipc	ra,0x2
    80002012:	480080e7          	jalr	1152(ra) # 8000448e <namei>
    80002016:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    8000201a:	478d                	li	a5,3
    8000201c:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    8000201e:	8526                	mv	a0,s1
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	e3c080e7          	jalr	-452(ra) # 80000e5c <release>
}
    80002028:	60e2                	ld	ra,24(sp)
    8000202a:	6442                	ld	s0,16(sp)
    8000202c:	64a2                	ld	s1,8(sp)
    8000202e:	6105                	addi	sp,sp,32
    80002030:	8082                	ret

0000000080002032 <growproc>:
{
    80002032:	1101                	addi	sp,sp,-32
    80002034:	ec06                	sd	ra,24(sp)
    80002036:	e822                	sd	s0,16(sp)
    80002038:	e426                	sd	s1,8(sp)
    8000203a:	e04a                	sd	s2,0(sp)
    8000203c:	1000                	addi	s0,sp,32
    8000203e:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002040:	00000097          	auipc	ra,0x0
    80002044:	c98080e7          	jalr	-872(ra) # 80001cd8 <myproc>
    80002048:	84aa                	mv	s1,a0
    sz = p->sz;
    8000204a:	652c                	ld	a1,72(a0)
    if (n > 0)
    8000204c:	01204c63          	bgtz	s2,80002064 <growproc+0x32>
    else if (n < 0)
    80002050:	02094663          	bltz	s2,8000207c <growproc+0x4a>
    p->sz = sz;
    80002054:	e4ac                	sd	a1,72(s1)
    return 0;
    80002056:	4501                	li	a0,0
}
    80002058:	60e2                	ld	ra,24(sp)
    8000205a:	6442                	ld	s0,16(sp)
    8000205c:	64a2                	ld	s1,8(sp)
    8000205e:	6902                	ld	s2,0(sp)
    80002060:	6105                	addi	sp,sp,32
    80002062:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002064:	4691                	li	a3,4
    80002066:	00b90633          	add	a2,s2,a1
    8000206a:	6928                	ld	a0,80(a0)
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	576080e7          	jalr	1398(ra) # 800015e2 <uvmalloc>
    80002074:	85aa                	mv	a1,a0
    80002076:	fd79                	bnez	a0,80002054 <growproc+0x22>
            return -1;
    80002078:	557d                	li	a0,-1
    8000207a:	bff9                	j	80002058 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000207c:	00b90633          	add	a2,s2,a1
    80002080:	6928                	ld	a0,80(a0)
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	518080e7          	jalr	1304(ra) # 8000159a <uvmdealloc>
    8000208a:	85aa                	mv	a1,a0
    8000208c:	b7e1                	j	80002054 <growproc+0x22>

000000008000208e <ps>:
{
    8000208e:	715d                	addi	sp,sp,-80
    80002090:	e486                	sd	ra,72(sp)
    80002092:	e0a2                	sd	s0,64(sp)
    80002094:	fc26                	sd	s1,56(sp)
    80002096:	f84a                	sd	s2,48(sp)
    80002098:	f44e                	sd	s3,40(sp)
    8000209a:	f052                	sd	s4,32(sp)
    8000209c:	ec56                	sd	s5,24(sp)
    8000209e:	e85a                	sd	s6,16(sp)
    800020a0:	e45e                	sd	s7,8(sp)
    800020a2:	e062                	sd	s8,0(sp)
    800020a4:	0880                	addi	s0,sp,80
    800020a6:	84aa                	mv	s1,a0
    800020a8:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    800020aa:	00000097          	auipc	ra,0x0
    800020ae:	c2e080e7          	jalr	-978(ra) # 80001cd8 <myproc>
        return result;
    800020b2:	4901                	li	s2,0
    if (count == 0)
    800020b4:	0c0b8563          	beqz	s7,8000217e <ps+0xf0>
    void *result = (void *)myproc()->sz;
    800020b8:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    800020bc:	003b951b          	slliw	a0,s7,0x3
    800020c0:	0175053b          	addw	a0,a0,s7
    800020c4:	0025151b          	slliw	a0,a0,0x2
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	f6a080e7          	jalr	-150(ra) # 80002032 <growproc>
    800020d0:	12054f63          	bltz	a0,8000220e <ps+0x180>
    struct user_proc loc_result[count];
    800020d4:	003b9a13          	slli	s4,s7,0x3
    800020d8:	9a5e                	add	s4,s4,s7
    800020da:	0a0a                	slli	s4,s4,0x2
    800020dc:	00fa0793          	addi	a5,s4,15
    800020e0:	8391                	srli	a5,a5,0x4
    800020e2:	0792                	slli	a5,a5,0x4
    800020e4:	40f10133          	sub	sp,sp,a5
    800020e8:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800020ea:	16800793          	li	a5,360
    800020ee:	02f484b3          	mul	s1,s1,a5
    800020f2:	0002f797          	auipc	a5,0x2f
    800020f6:	04678793          	addi	a5,a5,70 # 80031138 <proc>
    800020fa:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800020fc:	00035797          	auipc	a5,0x35
    80002100:	a3c78793          	addi	a5,a5,-1476 # 80036b38 <tickslock>
        return result;
    80002104:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80002106:	06f4fc63          	bgeu	s1,a5,8000217e <ps+0xf0>
    acquire(&wait_lock);
    8000210a:	0002f517          	auipc	a0,0x2f
    8000210e:	01650513          	addi	a0,a0,22 # 80031120 <wait_lock>
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	c96080e7          	jalr	-874(ra) # 80000da8 <acquire>
        if (localCount == count)
    8000211a:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    8000211e:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002120:	00035c17          	auipc	s8,0x35
    80002124:	a18c0c13          	addi	s8,s8,-1512 # 80036b38 <tickslock>
    80002128:	a851                	j	800021bc <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    8000212a:	00399793          	slli	a5,s3,0x3
    8000212e:	97ce                	add	a5,a5,s3
    80002130:	078a                	slli	a5,a5,0x2
    80002132:	97d6                	add	a5,a5,s5
    80002134:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002138:	8526                	mv	a0,s1
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	d22080e7          	jalr	-734(ra) # 80000e5c <release>
    release(&wait_lock);
    80002142:	0002f517          	auipc	a0,0x2f
    80002146:	fde50513          	addi	a0,a0,-34 # 80031120 <wait_lock>
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	d12080e7          	jalr	-750(ra) # 80000e5c <release>
    if (localCount < count)
    80002152:	0179f963          	bgeu	s3,s7,80002164 <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002156:	00399793          	slli	a5,s3,0x3
    8000215a:	97ce                	add	a5,a5,s3
    8000215c:	078a                	slli	a5,a5,0x2
    8000215e:	97d6                	add	a5,a5,s5
    80002160:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002164:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002166:	00000097          	auipc	ra,0x0
    8000216a:	b72080e7          	jalr	-1166(ra) # 80001cd8 <myproc>
    8000216e:	86d2                	mv	a3,s4
    80002170:	8656                	mv	a2,s5
    80002172:	85da                	mv	a1,s6
    80002174:	6928                	ld	a0,80(a0)
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	6c8080e7          	jalr	1736(ra) # 8000183e <copyout>
}
    8000217e:	854a                	mv	a0,s2
    80002180:	fb040113          	addi	sp,s0,-80
    80002184:	60a6                	ld	ra,72(sp)
    80002186:	6406                	ld	s0,64(sp)
    80002188:	74e2                	ld	s1,56(sp)
    8000218a:	7942                	ld	s2,48(sp)
    8000218c:	79a2                	ld	s3,40(sp)
    8000218e:	7a02                	ld	s4,32(sp)
    80002190:	6ae2                	ld	s5,24(sp)
    80002192:	6b42                	ld	s6,16(sp)
    80002194:	6ba2                	ld	s7,8(sp)
    80002196:	6c02                	ld	s8,0(sp)
    80002198:	6161                	addi	sp,sp,80
    8000219a:	8082                	ret
        release(&p->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	cbe080e7          	jalr	-834(ra) # 80000e5c <release>
        localCount++;
    800021a6:	2985                	addiw	s3,s3,1
    800021a8:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800021ac:	16848493          	addi	s1,s1,360
    800021b0:	f984f9e3          	bgeu	s1,s8,80002142 <ps+0xb4>
        if (localCount == count)
    800021b4:	02490913          	addi	s2,s2,36
    800021b8:	053b8d63          	beq	s7,s3,80002212 <ps+0x184>
        acquire(&p->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	bea080e7          	jalr	-1046(ra) # 80000da8 <acquire>
        if (p->state == UNUSED)
    800021c6:	4c9c                	lw	a5,24(s1)
    800021c8:	d3ad                	beqz	a5,8000212a <ps+0x9c>
        loc_result[localCount].state = p->state;
    800021ca:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800021ce:	549c                	lw	a5,40(s1)
    800021d0:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800021d4:	54dc                	lw	a5,44(s1)
    800021d6:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800021da:	589c                	lw	a5,48(s1)
    800021dc:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800021e0:	4641                	li	a2,16
    800021e2:	85ca                	mv	a1,s2
    800021e4:	15848513          	addi	a0,s1,344
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	a96080e7          	jalr	-1386(ra) # 80001c7e <copy_array>
        if (p->parent != 0) // init
    800021f0:	7c88                	ld	a0,56(s1)
    800021f2:	d54d                	beqz	a0,8000219c <ps+0x10e>
            acquire(&p->parent->lock);
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	bb4080e7          	jalr	-1100(ra) # 80000da8 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800021fc:	7c88                	ld	a0,56(s1)
    800021fe:	591c                	lw	a5,48(a0)
    80002200:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	c58080e7          	jalr	-936(ra) # 80000e5c <release>
    8000220c:	bf41                	j	8000219c <ps+0x10e>
        return result;
    8000220e:	4901                	li	s2,0
    80002210:	b7bd                	j	8000217e <ps+0xf0>
    release(&wait_lock);
    80002212:	0002f517          	auipc	a0,0x2f
    80002216:	f0e50513          	addi	a0,a0,-242 # 80031120 <wait_lock>
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	c42080e7          	jalr	-958(ra) # 80000e5c <release>
    if (localCount < count)
    80002222:	b789                	j	80002164 <ps+0xd6>

0000000080002224 <fork>:
{
    80002224:	7139                	addi	sp,sp,-64
    80002226:	fc06                	sd	ra,56(sp)
    80002228:	f822                	sd	s0,48(sp)
    8000222a:	f426                	sd	s1,40(sp)
    8000222c:	f04a                	sd	s2,32(sp)
    8000222e:	ec4e                	sd	s3,24(sp)
    80002230:	e852                	sd	s4,16(sp)
    80002232:	e456                	sd	s5,8(sp)
    80002234:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	aa2080e7          	jalr	-1374(ra) # 80001cd8 <myproc>
    8000223e:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002240:	00000097          	auipc	ra,0x0
    80002244:	ca2080e7          	jalr	-862(ra) # 80001ee2 <allocproc>
    80002248:	10050c63          	beqz	a0,80002360 <fork+0x13c>
    8000224c:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000224e:	048ab603          	ld	a2,72(s5)
    80002252:	692c                	ld	a1,80(a0)
    80002254:	050ab503          	ld	a0,80(s5)
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	4e2080e7          	jalr	1250(ra) # 8000173a <uvmcopy>
    80002260:	04054863          	bltz	a0,800022b0 <fork+0x8c>
    np->sz = p->sz;
    80002264:	048ab783          	ld	a5,72(s5)
    80002268:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    8000226c:	058ab683          	ld	a3,88(s5)
    80002270:	87b6                	mv	a5,a3
    80002272:	058a3703          	ld	a4,88(s4)
    80002276:	12068693          	addi	a3,a3,288
    8000227a:	0007b803          	ld	a6,0(a5)
    8000227e:	6788                	ld	a0,8(a5)
    80002280:	6b8c                	ld	a1,16(a5)
    80002282:	6f90                	ld	a2,24(a5)
    80002284:	01073023          	sd	a6,0(a4)
    80002288:	e708                	sd	a0,8(a4)
    8000228a:	eb0c                	sd	a1,16(a4)
    8000228c:	ef10                	sd	a2,24(a4)
    8000228e:	02078793          	addi	a5,a5,32
    80002292:	02070713          	addi	a4,a4,32
    80002296:	fed792e3          	bne	a5,a3,8000227a <fork+0x56>
    np->trapframe->a0 = 0;
    8000229a:	058a3783          	ld	a5,88(s4)
    8000229e:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800022a2:	0d0a8493          	addi	s1,s5,208
    800022a6:	0d0a0913          	addi	s2,s4,208
    800022aa:	150a8993          	addi	s3,s5,336
    800022ae:	a00d                	j	800022d0 <fork+0xac>
        freeproc(np);
    800022b0:	8552                	mv	a0,s4
    800022b2:	00000097          	auipc	ra,0x0
    800022b6:	bd8080e7          	jalr	-1064(ra) # 80001e8a <freeproc>
        release(&np->lock);
    800022ba:	8552                	mv	a0,s4
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	ba0080e7          	jalr	-1120(ra) # 80000e5c <release>
        return -1;
    800022c4:	597d                	li	s2,-1
    800022c6:	a059                	j	8000234c <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    800022c8:	04a1                	addi	s1,s1,8
    800022ca:	0921                	addi	s2,s2,8
    800022cc:	01348b63          	beq	s1,s3,800022e2 <fork+0xbe>
        if (p->ofile[i])
    800022d0:	6088                	ld	a0,0(s1)
    800022d2:	d97d                	beqz	a0,800022c8 <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    800022d4:	00003097          	auipc	ra,0x3
    800022d8:	850080e7          	jalr	-1968(ra) # 80004b24 <filedup>
    800022dc:	00a93023          	sd	a0,0(s2)
    800022e0:	b7e5                	j	800022c8 <fork+0xa4>
    np->cwd = idup(p->cwd);
    800022e2:	150ab503          	ld	a0,336(s5)
    800022e6:	00002097          	auipc	ra,0x2
    800022ea:	9be080e7          	jalr	-1602(ra) # 80003ca4 <idup>
    800022ee:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800022f2:	4641                	li	a2,16
    800022f4:	158a8593          	addi	a1,s5,344
    800022f8:	158a0513          	addi	a0,s4,344
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	cf2080e7          	jalr	-782(ra) # 80000fee <safestrcpy>
    pid = np->pid;
    80002304:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    80002308:	8552                	mv	a0,s4
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	b52080e7          	jalr	-1198(ra) # 80000e5c <release>
    acquire(&wait_lock);
    80002312:	0002f497          	auipc	s1,0x2f
    80002316:	e0e48493          	addi	s1,s1,-498 # 80031120 <wait_lock>
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	a8c080e7          	jalr	-1396(ra) # 80000da8 <acquire>
    np->parent = p;
    80002324:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	b32080e7          	jalr	-1230(ra) # 80000e5c <release>
    acquire(&np->lock);
    80002332:	8552                	mv	a0,s4
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	a74080e7          	jalr	-1420(ra) # 80000da8 <acquire>
    np->state = RUNNABLE;
    8000233c:	478d                	li	a5,3
    8000233e:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002342:	8552                	mv	a0,s4
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	b18080e7          	jalr	-1256(ra) # 80000e5c <release>
}
    8000234c:	854a                	mv	a0,s2
    8000234e:	70e2                	ld	ra,56(sp)
    80002350:	7442                	ld	s0,48(sp)
    80002352:	74a2                	ld	s1,40(sp)
    80002354:	7902                	ld	s2,32(sp)
    80002356:	69e2                	ld	s3,24(sp)
    80002358:	6a42                	ld	s4,16(sp)
    8000235a:	6aa2                	ld	s5,8(sp)
    8000235c:	6121                	addi	sp,sp,64
    8000235e:	8082                	ret
        return -1;
    80002360:	597d                	li	s2,-1
    80002362:	b7ed                	j	8000234c <fork+0x128>

0000000080002364 <scheduler>:
{
    80002364:	1101                	addi	sp,sp,-32
    80002366:	ec06                	sd	ra,24(sp)
    80002368:	e822                	sd	s0,16(sp)
    8000236a:	e426                	sd	s1,8(sp)
    8000236c:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    8000236e:	00006497          	auipc	s1,0x6
    80002372:	63a48493          	addi	s1,s1,1594 # 800089a8 <sched_pointer>
    80002376:	609c                	ld	a5,0(s1)
    80002378:	9782                	jalr	a5
    while (1)
    8000237a:	bff5                	j	80002376 <scheduler+0x12>

000000008000237c <sched>:
{
    8000237c:	7179                	addi	sp,sp,-48
    8000237e:	f406                	sd	ra,40(sp)
    80002380:	f022                	sd	s0,32(sp)
    80002382:	ec26                	sd	s1,24(sp)
    80002384:	e84a                	sd	s2,16(sp)
    80002386:	e44e                	sd	s3,8(sp)
    80002388:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000238a:	00000097          	auipc	ra,0x0
    8000238e:	94e080e7          	jalr	-1714(ra) # 80001cd8 <myproc>
    80002392:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	99a080e7          	jalr	-1638(ra) # 80000d2e <holding>
    8000239c:	c53d                	beqz	a0,8000240a <sched+0x8e>
    8000239e:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800023a0:	2781                	sext.w	a5,a5
    800023a2:	079e                	slli	a5,a5,0x7
    800023a4:	0002f717          	auipc	a4,0x2f
    800023a8:	96470713          	addi	a4,a4,-1692 # 80030d08 <cpus>
    800023ac:	97ba                	add	a5,a5,a4
    800023ae:	5fb8                	lw	a4,120(a5)
    800023b0:	4785                	li	a5,1
    800023b2:	06f71463          	bne	a4,a5,8000241a <sched+0x9e>
    if (p->state == RUNNING)
    800023b6:	4c98                	lw	a4,24(s1)
    800023b8:	4791                	li	a5,4
    800023ba:	06f70863          	beq	a4,a5,8000242a <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800023be:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    800023c2:	8b89                	andi	a5,a5,2
    if (intr_get())
    800023c4:	ebbd                	bnez	a5,8000243a <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800023c6:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800023c8:	0002f917          	auipc	s2,0x2f
    800023cc:	94090913          	addi	s2,s2,-1728 # 80030d08 <cpus>
    800023d0:	2781                	sext.w	a5,a5
    800023d2:	079e                	slli	a5,a5,0x7
    800023d4:	97ca                	add	a5,a5,s2
    800023d6:	07c7a983          	lw	s3,124(a5)
    800023da:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800023dc:	2581                	sext.w	a1,a1
    800023de:	059e                	slli	a1,a1,0x7
    800023e0:	05a1                	addi	a1,a1,8
    800023e2:	95ca                	add	a1,a1,s2
    800023e4:	06048513          	addi	a0,s1,96
    800023e8:	00000097          	auipc	ra,0x0
    800023ec:	75a080e7          	jalr	1882(ra) # 80002b42 <swtch>
    800023f0:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800023f2:	2781                	sext.w	a5,a5
    800023f4:	079e                	slli	a5,a5,0x7
    800023f6:	993e                	add	s2,s2,a5
    800023f8:	07392e23          	sw	s3,124(s2)
}
    800023fc:	70a2                	ld	ra,40(sp)
    800023fe:	7402                	ld	s0,32(sp)
    80002400:	64e2                	ld	s1,24(sp)
    80002402:	6942                	ld	s2,16(sp)
    80002404:	69a2                	ld	s3,8(sp)
    80002406:	6145                	addi	sp,sp,48
    80002408:	8082                	ret
        panic("sched p->lock");
    8000240a:	00006517          	auipc	a0,0x6
    8000240e:	e6e50513          	addi	a0,a0,-402 # 80008278 <digits+0x228>
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	12e080e7          	jalr	302(ra) # 80000540 <panic>
        panic("sched locks");
    8000241a:	00006517          	auipc	a0,0x6
    8000241e:	e6e50513          	addi	a0,a0,-402 # 80008288 <digits+0x238>
    80002422:	ffffe097          	auipc	ra,0xffffe
    80002426:	11e080e7          	jalr	286(ra) # 80000540 <panic>
        panic("sched running");
    8000242a:	00006517          	auipc	a0,0x6
    8000242e:	e6e50513          	addi	a0,a0,-402 # 80008298 <digits+0x248>
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	10e080e7          	jalr	270(ra) # 80000540 <panic>
        panic("sched interruptible");
    8000243a:	00006517          	auipc	a0,0x6
    8000243e:	e6e50513          	addi	a0,a0,-402 # 800082a8 <digits+0x258>
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	0fe080e7          	jalr	254(ra) # 80000540 <panic>

000000008000244a <yield>:
{
    8000244a:	1101                	addi	sp,sp,-32
    8000244c:	ec06                	sd	ra,24(sp)
    8000244e:	e822                	sd	s0,16(sp)
    80002450:	e426                	sd	s1,8(sp)
    80002452:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002454:	00000097          	auipc	ra,0x0
    80002458:	884080e7          	jalr	-1916(ra) # 80001cd8 <myproc>
    8000245c:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	94a080e7          	jalr	-1718(ra) # 80000da8 <acquire>
    p->state = RUNNABLE;
    80002466:	478d                	li	a5,3
    80002468:	cc9c                	sw	a5,24(s1)
    sched();
    8000246a:	00000097          	auipc	ra,0x0
    8000246e:	f12080e7          	jalr	-238(ra) # 8000237c <sched>
    release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	9e8080e7          	jalr	-1560(ra) # 80000e5c <release>
}
    8000247c:	60e2                	ld	ra,24(sp)
    8000247e:	6442                	ld	s0,16(sp)
    80002480:	64a2                	ld	s1,8(sp)
    80002482:	6105                	addi	sp,sp,32
    80002484:	8082                	ret

0000000080002486 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002486:	7179                	addi	sp,sp,-48
    80002488:	f406                	sd	ra,40(sp)
    8000248a:	f022                	sd	s0,32(sp)
    8000248c:	ec26                	sd	s1,24(sp)
    8000248e:	e84a                	sd	s2,16(sp)
    80002490:	e44e                	sd	s3,8(sp)
    80002492:	1800                	addi	s0,sp,48
    80002494:	89aa                	mv	s3,a0
    80002496:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002498:	00000097          	auipc	ra,0x0
    8000249c:	840080e7          	jalr	-1984(ra) # 80001cd8 <myproc>
    800024a0:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	906080e7          	jalr	-1786(ra) # 80000da8 <acquire>
    release(lk);
    800024aa:	854a                	mv	a0,s2
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	9b0080e7          	jalr	-1616(ra) # 80000e5c <release>

    // Go to sleep.
    p->chan = chan;
    800024b4:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800024b8:	4789                	li	a5,2
    800024ba:	cc9c                	sw	a5,24(s1)

    sched();
    800024bc:	00000097          	auipc	ra,0x0
    800024c0:	ec0080e7          	jalr	-320(ra) # 8000237c <sched>

    // Tidy up.
    p->chan = 0;
    800024c4:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	992080e7          	jalr	-1646(ra) # 80000e5c <release>
    acquire(lk);
    800024d2:	854a                	mv	a0,s2
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	8d4080e7          	jalr	-1836(ra) # 80000da8 <acquire>
}
    800024dc:	70a2                	ld	ra,40(sp)
    800024de:	7402                	ld	s0,32(sp)
    800024e0:	64e2                	ld	s1,24(sp)
    800024e2:	6942                	ld	s2,16(sp)
    800024e4:	69a2                	ld	s3,8(sp)
    800024e6:	6145                	addi	sp,sp,48
    800024e8:	8082                	ret

00000000800024ea <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024ea:	7139                	addi	sp,sp,-64
    800024ec:	fc06                	sd	ra,56(sp)
    800024ee:	f822                	sd	s0,48(sp)
    800024f0:	f426                	sd	s1,40(sp)
    800024f2:	f04a                	sd	s2,32(sp)
    800024f4:	ec4e                	sd	s3,24(sp)
    800024f6:	e852                	sd	s4,16(sp)
    800024f8:	e456                	sd	s5,8(sp)
    800024fa:	0080                	addi	s0,sp,64
    800024fc:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024fe:	0002f497          	auipc	s1,0x2f
    80002502:	c3a48493          	addi	s1,s1,-966 # 80031138 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    80002506:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    80002508:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000250a:	00034917          	auipc	s2,0x34
    8000250e:	62e90913          	addi	s2,s2,1582 # 80036b38 <tickslock>
    80002512:	a811                	j	80002526 <wakeup+0x3c>
            }
            release(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	fffff097          	auipc	ra,0xfffff
    8000251a:	946080e7          	jalr	-1722(ra) # 80000e5c <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000251e:	16848493          	addi	s1,s1,360
    80002522:	03248663          	beq	s1,s2,8000254e <wakeup+0x64>
        if (p != myproc())
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	7b2080e7          	jalr	1970(ra) # 80001cd8 <myproc>
    8000252e:	fea488e3          	beq	s1,a0,8000251e <wakeup+0x34>
            acquire(&p->lock);
    80002532:	8526                	mv	a0,s1
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	874080e7          	jalr	-1932(ra) # 80000da8 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000253c:	4c9c                	lw	a5,24(s1)
    8000253e:	fd379be3          	bne	a5,s3,80002514 <wakeup+0x2a>
    80002542:	709c                	ld	a5,32(s1)
    80002544:	fd4798e3          	bne	a5,s4,80002514 <wakeup+0x2a>
                p->state = RUNNABLE;
    80002548:	0154ac23          	sw	s5,24(s1)
    8000254c:	b7e1                	j	80002514 <wakeup+0x2a>
        }
    }
}
    8000254e:	70e2                	ld	ra,56(sp)
    80002550:	7442                	ld	s0,48(sp)
    80002552:	74a2                	ld	s1,40(sp)
    80002554:	7902                	ld	s2,32(sp)
    80002556:	69e2                	ld	s3,24(sp)
    80002558:	6a42                	ld	s4,16(sp)
    8000255a:	6aa2                	ld	s5,8(sp)
    8000255c:	6121                	addi	sp,sp,64
    8000255e:	8082                	ret

0000000080002560 <reparent>:
{
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	e052                	sd	s4,0(sp)
    8000256e:	1800                	addi	s0,sp,48
    80002570:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002572:	0002f497          	auipc	s1,0x2f
    80002576:	bc648493          	addi	s1,s1,-1082 # 80031138 <proc>
            pp->parent = initproc;
    8000257a:	00006a17          	auipc	s4,0x6
    8000257e:	4fea0a13          	addi	s4,s4,1278 # 80008a78 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002582:	00034997          	auipc	s3,0x34
    80002586:	5b698993          	addi	s3,s3,1462 # 80036b38 <tickslock>
    8000258a:	a029                	j	80002594 <reparent+0x34>
    8000258c:	16848493          	addi	s1,s1,360
    80002590:	01348d63          	beq	s1,s3,800025aa <reparent+0x4a>
        if (pp->parent == p)
    80002594:	7c9c                	ld	a5,56(s1)
    80002596:	ff279be3          	bne	a5,s2,8000258c <reparent+0x2c>
            pp->parent = initproc;
    8000259a:	000a3503          	ld	a0,0(s4)
    8000259e:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800025a0:	00000097          	auipc	ra,0x0
    800025a4:	f4a080e7          	jalr	-182(ra) # 800024ea <wakeup>
    800025a8:	b7d5                	j	8000258c <reparent+0x2c>
}
    800025aa:	70a2                	ld	ra,40(sp)
    800025ac:	7402                	ld	s0,32(sp)
    800025ae:	64e2                	ld	s1,24(sp)
    800025b0:	6942                	ld	s2,16(sp)
    800025b2:	69a2                	ld	s3,8(sp)
    800025b4:	6a02                	ld	s4,0(sp)
    800025b6:	6145                	addi	sp,sp,48
    800025b8:	8082                	ret

00000000800025ba <exit>:
{
    800025ba:	7179                	addi	sp,sp,-48
    800025bc:	f406                	sd	ra,40(sp)
    800025be:	f022                	sd	s0,32(sp)
    800025c0:	ec26                	sd	s1,24(sp)
    800025c2:	e84a                	sd	s2,16(sp)
    800025c4:	e44e                	sd	s3,8(sp)
    800025c6:	e052                	sd	s4,0(sp)
    800025c8:	1800                	addi	s0,sp,48
    800025ca:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	70c080e7          	jalr	1804(ra) # 80001cd8 <myproc>
    800025d4:	89aa                	mv	s3,a0
    if (p == initproc)
    800025d6:	00006797          	auipc	a5,0x6
    800025da:	4a27b783          	ld	a5,1186(a5) # 80008a78 <initproc>
    800025de:	0d050493          	addi	s1,a0,208
    800025e2:	15050913          	addi	s2,a0,336
    800025e6:	02a79363          	bne	a5,a0,8000260c <exit+0x52>
        panic("init exiting");
    800025ea:	00006517          	auipc	a0,0x6
    800025ee:	cd650513          	addi	a0,a0,-810 # 800082c0 <digits+0x270>
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	f4e080e7          	jalr	-178(ra) # 80000540 <panic>
            fileclose(f);
    800025fa:	00002097          	auipc	ra,0x2
    800025fe:	57c080e7          	jalr	1404(ra) # 80004b76 <fileclose>
            p->ofile[fd] = 0;
    80002602:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    80002606:	04a1                	addi	s1,s1,8
    80002608:	01248563          	beq	s1,s2,80002612 <exit+0x58>
        if (p->ofile[fd])
    8000260c:	6088                	ld	a0,0(s1)
    8000260e:	f575                	bnez	a0,800025fa <exit+0x40>
    80002610:	bfdd                	j	80002606 <exit+0x4c>
    begin_op();
    80002612:	00002097          	auipc	ra,0x2
    80002616:	09c080e7          	jalr	156(ra) # 800046ae <begin_op>
    iput(p->cwd);
    8000261a:	1509b503          	ld	a0,336(s3)
    8000261e:	00002097          	auipc	ra,0x2
    80002622:	87e080e7          	jalr	-1922(ra) # 80003e9c <iput>
    end_op();
    80002626:	00002097          	auipc	ra,0x2
    8000262a:	106080e7          	jalr	262(ra) # 8000472c <end_op>
    p->cwd = 0;
    8000262e:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002632:	0002f497          	auipc	s1,0x2f
    80002636:	aee48493          	addi	s1,s1,-1298 # 80031120 <wait_lock>
    8000263a:	8526                	mv	a0,s1
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	76c080e7          	jalr	1900(ra) # 80000da8 <acquire>
    reparent(p);
    80002644:	854e                	mv	a0,s3
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	f1a080e7          	jalr	-230(ra) # 80002560 <reparent>
    wakeup(p->parent);
    8000264e:	0389b503          	ld	a0,56(s3)
    80002652:	00000097          	auipc	ra,0x0
    80002656:	e98080e7          	jalr	-360(ra) # 800024ea <wakeup>
    acquire(&p->lock);
    8000265a:	854e                	mv	a0,s3
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	74c080e7          	jalr	1868(ra) # 80000da8 <acquire>
    p->xstate = status;
    80002664:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002668:	4795                	li	a5,5
    8000266a:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    8000266e:	8526                	mv	a0,s1
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	7ec080e7          	jalr	2028(ra) # 80000e5c <release>
    sched();
    80002678:	00000097          	auipc	ra,0x0
    8000267c:	d04080e7          	jalr	-764(ra) # 8000237c <sched>
    panic("zombie exit");
    80002680:	00006517          	auipc	a0,0x6
    80002684:	c5050513          	addi	a0,a0,-944 # 800082d0 <digits+0x280>
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	eb8080e7          	jalr	-328(ra) # 80000540 <panic>

0000000080002690 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002690:	7179                	addi	sp,sp,-48
    80002692:	f406                	sd	ra,40(sp)
    80002694:	f022                	sd	s0,32(sp)
    80002696:	ec26                	sd	s1,24(sp)
    80002698:	e84a                	sd	s2,16(sp)
    8000269a:	e44e                	sd	s3,8(sp)
    8000269c:	1800                	addi	s0,sp,48
    8000269e:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800026a0:	0002f497          	auipc	s1,0x2f
    800026a4:	a9848493          	addi	s1,s1,-1384 # 80031138 <proc>
    800026a8:	00034997          	auipc	s3,0x34
    800026ac:	49098993          	addi	s3,s3,1168 # 80036b38 <tickslock>
    {
        acquire(&p->lock);
    800026b0:	8526                	mv	a0,s1
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	6f6080e7          	jalr	1782(ra) # 80000da8 <acquire>
        if (p->pid == pid)
    800026ba:	589c                	lw	a5,48(s1)
    800026bc:	01278d63          	beq	a5,s2,800026d6 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800026c0:	8526                	mv	a0,s1
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	79a080e7          	jalr	1946(ra) # 80000e5c <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800026ca:	16848493          	addi	s1,s1,360
    800026ce:	ff3491e3          	bne	s1,s3,800026b0 <kill+0x20>
    }
    return -1;
    800026d2:	557d                	li	a0,-1
    800026d4:	a829                	j	800026ee <kill+0x5e>
            p->killed = 1;
    800026d6:	4785                	li	a5,1
    800026d8:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800026da:	4c98                	lw	a4,24(s1)
    800026dc:	4789                	li	a5,2
    800026de:	00f70f63          	beq	a4,a5,800026fc <kill+0x6c>
            release(&p->lock);
    800026e2:	8526                	mv	a0,s1
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	778080e7          	jalr	1912(ra) # 80000e5c <release>
            return 0;
    800026ec:	4501                	li	a0,0
}
    800026ee:	70a2                	ld	ra,40(sp)
    800026f0:	7402                	ld	s0,32(sp)
    800026f2:	64e2                	ld	s1,24(sp)
    800026f4:	6942                	ld	s2,16(sp)
    800026f6:	69a2                	ld	s3,8(sp)
    800026f8:	6145                	addi	sp,sp,48
    800026fa:	8082                	ret
                p->state = RUNNABLE;
    800026fc:	478d                	li	a5,3
    800026fe:	cc9c                	sw	a5,24(s1)
    80002700:	b7cd                	j	800026e2 <kill+0x52>

0000000080002702 <setkilled>:

void setkilled(struct proc *p)
{
    80002702:	1101                	addi	sp,sp,-32
    80002704:	ec06                	sd	ra,24(sp)
    80002706:	e822                	sd	s0,16(sp)
    80002708:	e426                	sd	s1,8(sp)
    8000270a:	1000                	addi	s0,sp,32
    8000270c:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	69a080e7          	jalr	1690(ra) # 80000da8 <acquire>
    p->killed = 1;
    80002716:	4785                	li	a5,1
    80002718:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    8000271a:	8526                	mv	a0,s1
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	740080e7          	jalr	1856(ra) # 80000e5c <release>
}
    80002724:	60e2                	ld	ra,24(sp)
    80002726:	6442                	ld	s0,16(sp)
    80002728:	64a2                	ld	s1,8(sp)
    8000272a:	6105                	addi	sp,sp,32
    8000272c:	8082                	ret

000000008000272e <killed>:

int killed(struct proc *p)
{
    8000272e:	1101                	addi	sp,sp,-32
    80002730:	ec06                	sd	ra,24(sp)
    80002732:	e822                	sd	s0,16(sp)
    80002734:	e426                	sd	s1,8(sp)
    80002736:	e04a                	sd	s2,0(sp)
    80002738:	1000                	addi	s0,sp,32
    8000273a:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	66c080e7          	jalr	1644(ra) # 80000da8 <acquire>
    k = p->killed;
    80002744:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002748:	8526                	mv	a0,s1
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	712080e7          	jalr	1810(ra) # 80000e5c <release>
    return k;
}
    80002752:	854a                	mv	a0,s2
    80002754:	60e2                	ld	ra,24(sp)
    80002756:	6442                	ld	s0,16(sp)
    80002758:	64a2                	ld	s1,8(sp)
    8000275a:	6902                	ld	s2,0(sp)
    8000275c:	6105                	addi	sp,sp,32
    8000275e:	8082                	ret

0000000080002760 <wait>:
{
    80002760:	715d                	addi	sp,sp,-80
    80002762:	e486                	sd	ra,72(sp)
    80002764:	e0a2                	sd	s0,64(sp)
    80002766:	fc26                	sd	s1,56(sp)
    80002768:	f84a                	sd	s2,48(sp)
    8000276a:	f44e                	sd	s3,40(sp)
    8000276c:	f052                	sd	s4,32(sp)
    8000276e:	ec56                	sd	s5,24(sp)
    80002770:	e85a                	sd	s6,16(sp)
    80002772:	e45e                	sd	s7,8(sp)
    80002774:	e062                	sd	s8,0(sp)
    80002776:	0880                	addi	s0,sp,80
    80002778:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    8000277a:	fffff097          	auipc	ra,0xfffff
    8000277e:	55e080e7          	jalr	1374(ra) # 80001cd8 <myproc>
    80002782:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002784:	0002f517          	auipc	a0,0x2f
    80002788:	99c50513          	addi	a0,a0,-1636 # 80031120 <wait_lock>
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	61c080e7          	jalr	1564(ra) # 80000da8 <acquire>
        havekids = 0;
    80002794:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002796:	4a15                	li	s4,5
                havekids = 1;
    80002798:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000279a:	00034997          	auipc	s3,0x34
    8000279e:	39e98993          	addi	s3,s3,926 # 80036b38 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800027a2:	0002fc17          	auipc	s8,0x2f
    800027a6:	97ec0c13          	addi	s8,s8,-1666 # 80031120 <wait_lock>
        havekids = 0;
    800027aa:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ac:	0002f497          	auipc	s1,0x2f
    800027b0:	98c48493          	addi	s1,s1,-1652 # 80031138 <proc>
    800027b4:	a0bd                	j	80002822 <wait+0xc2>
                    pid = pp->pid;
    800027b6:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027ba:	000b0e63          	beqz	s6,800027d6 <wait+0x76>
    800027be:	4691                	li	a3,4
    800027c0:	02c48613          	addi	a2,s1,44
    800027c4:	85da                	mv	a1,s6
    800027c6:	05093503          	ld	a0,80(s2)
    800027ca:	fffff097          	auipc	ra,0xfffff
    800027ce:	074080e7          	jalr	116(ra) # 8000183e <copyout>
    800027d2:	02054563          	bltz	a0,800027fc <wait+0x9c>
                    freeproc(pp);
    800027d6:	8526                	mv	a0,s1
    800027d8:	fffff097          	auipc	ra,0xfffff
    800027dc:	6b2080e7          	jalr	1714(ra) # 80001e8a <freeproc>
                    release(&pp->lock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	67a080e7          	jalr	1658(ra) # 80000e5c <release>
                    release(&wait_lock);
    800027ea:	0002f517          	auipc	a0,0x2f
    800027ee:	93650513          	addi	a0,a0,-1738 # 80031120 <wait_lock>
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	66a080e7          	jalr	1642(ra) # 80000e5c <release>
                    return pid;
    800027fa:	a0b5                	j	80002866 <wait+0x106>
                        release(&pp->lock);
    800027fc:	8526                	mv	a0,s1
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	65e080e7          	jalr	1630(ra) # 80000e5c <release>
                        release(&wait_lock);
    80002806:	0002f517          	auipc	a0,0x2f
    8000280a:	91a50513          	addi	a0,a0,-1766 # 80031120 <wait_lock>
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	64e080e7          	jalr	1614(ra) # 80000e5c <release>
                        return -1;
    80002816:	59fd                	li	s3,-1
    80002818:	a0b9                	j	80002866 <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000281a:	16848493          	addi	s1,s1,360
    8000281e:	03348463          	beq	s1,s3,80002846 <wait+0xe6>
            if (pp->parent == p)
    80002822:	7c9c                	ld	a5,56(s1)
    80002824:	ff279be3          	bne	a5,s2,8000281a <wait+0xba>
                acquire(&pp->lock);
    80002828:	8526                	mv	a0,s1
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	57e080e7          	jalr	1406(ra) # 80000da8 <acquire>
                if (pp->state == ZOMBIE)
    80002832:	4c9c                	lw	a5,24(s1)
    80002834:	f94781e3          	beq	a5,s4,800027b6 <wait+0x56>
                release(&pp->lock);
    80002838:	8526                	mv	a0,s1
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	622080e7          	jalr	1570(ra) # 80000e5c <release>
                havekids = 1;
    80002842:	8756                	mv	a4,s5
    80002844:	bfd9                	j	8000281a <wait+0xba>
        if (!havekids || killed(p))
    80002846:	c719                	beqz	a4,80002854 <wait+0xf4>
    80002848:	854a                	mv	a0,s2
    8000284a:	00000097          	auipc	ra,0x0
    8000284e:	ee4080e7          	jalr	-284(ra) # 8000272e <killed>
    80002852:	c51d                	beqz	a0,80002880 <wait+0x120>
            release(&wait_lock);
    80002854:	0002f517          	auipc	a0,0x2f
    80002858:	8cc50513          	addi	a0,a0,-1844 # 80031120 <wait_lock>
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	600080e7          	jalr	1536(ra) # 80000e5c <release>
            return -1;
    80002864:	59fd                	li	s3,-1
}
    80002866:	854e                	mv	a0,s3
    80002868:	60a6                	ld	ra,72(sp)
    8000286a:	6406                	ld	s0,64(sp)
    8000286c:	74e2                	ld	s1,56(sp)
    8000286e:	7942                	ld	s2,48(sp)
    80002870:	79a2                	ld	s3,40(sp)
    80002872:	7a02                	ld	s4,32(sp)
    80002874:	6ae2                	ld	s5,24(sp)
    80002876:	6b42                	ld	s6,16(sp)
    80002878:	6ba2                	ld	s7,8(sp)
    8000287a:	6c02                	ld	s8,0(sp)
    8000287c:	6161                	addi	sp,sp,80
    8000287e:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002880:	85e2                	mv	a1,s8
    80002882:	854a                	mv	a0,s2
    80002884:	00000097          	auipc	ra,0x0
    80002888:	c02080e7          	jalr	-1022(ra) # 80002486 <sleep>
        havekids = 0;
    8000288c:	bf39                	j	800027aa <wait+0x4a>

000000008000288e <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000288e:	7179                	addi	sp,sp,-48
    80002890:	f406                	sd	ra,40(sp)
    80002892:	f022                	sd	s0,32(sp)
    80002894:	ec26                	sd	s1,24(sp)
    80002896:	e84a                	sd	s2,16(sp)
    80002898:	e44e                	sd	s3,8(sp)
    8000289a:	e052                	sd	s4,0(sp)
    8000289c:	1800                	addi	s0,sp,48
    8000289e:	84aa                	mv	s1,a0
    800028a0:	892e                	mv	s2,a1
    800028a2:	89b2                	mv	s3,a2
    800028a4:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800028a6:	fffff097          	auipc	ra,0xfffff
    800028aa:	432080e7          	jalr	1074(ra) # 80001cd8 <myproc>
    if (user_dst)
    800028ae:	c08d                	beqz	s1,800028d0 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800028b0:	86d2                	mv	a3,s4
    800028b2:	864e                	mv	a2,s3
    800028b4:	85ca                	mv	a1,s2
    800028b6:	6928                	ld	a0,80(a0)
    800028b8:	fffff097          	auipc	ra,0xfffff
    800028bc:	f86080e7          	jalr	-122(ra) # 8000183e <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    800028c0:	70a2                	ld	ra,40(sp)
    800028c2:	7402                	ld	s0,32(sp)
    800028c4:	64e2                	ld	s1,24(sp)
    800028c6:	6942                	ld	s2,16(sp)
    800028c8:	69a2                	ld	s3,8(sp)
    800028ca:	6a02                	ld	s4,0(sp)
    800028cc:	6145                	addi	sp,sp,48
    800028ce:	8082                	ret
        memmove((char *)dst, src, len);
    800028d0:	000a061b          	sext.w	a2,s4
    800028d4:	85ce                	mv	a1,s3
    800028d6:	854a                	mv	a0,s2
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	628080e7          	jalr	1576(ra) # 80000f00 <memmove>
        return 0;
    800028e0:	8526                	mv	a0,s1
    800028e2:	bff9                	j	800028c0 <either_copyout+0x32>

00000000800028e4 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028e4:	7179                	addi	sp,sp,-48
    800028e6:	f406                	sd	ra,40(sp)
    800028e8:	f022                	sd	s0,32(sp)
    800028ea:	ec26                	sd	s1,24(sp)
    800028ec:	e84a                	sd	s2,16(sp)
    800028ee:	e44e                	sd	s3,8(sp)
    800028f0:	e052                	sd	s4,0(sp)
    800028f2:	1800                	addi	s0,sp,48
    800028f4:	892a                	mv	s2,a0
    800028f6:	84ae                	mv	s1,a1
    800028f8:	89b2                	mv	s3,a2
    800028fa:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800028fc:	fffff097          	auipc	ra,0xfffff
    80002900:	3dc080e7          	jalr	988(ra) # 80001cd8 <myproc>
    if (user_src)
    80002904:	c08d                	beqz	s1,80002926 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002906:	86d2                	mv	a3,s4
    80002908:	864e                	mv	a2,s3
    8000290a:	85ca                	mv	a1,s2
    8000290c:	6928                	ld	a0,80(a0)
    8000290e:	fffff097          	auipc	ra,0xfffff
    80002912:	fbc080e7          	jalr	-68(ra) # 800018ca <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002916:	70a2                	ld	ra,40(sp)
    80002918:	7402                	ld	s0,32(sp)
    8000291a:	64e2                	ld	s1,24(sp)
    8000291c:	6942                	ld	s2,16(sp)
    8000291e:	69a2                	ld	s3,8(sp)
    80002920:	6a02                	ld	s4,0(sp)
    80002922:	6145                	addi	sp,sp,48
    80002924:	8082                	ret
        memmove(dst, (char *)src, len);
    80002926:	000a061b          	sext.w	a2,s4
    8000292a:	85ce                	mv	a1,s3
    8000292c:	854a                	mv	a0,s2
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	5d2080e7          	jalr	1490(ra) # 80000f00 <memmove>
        return 0;
    80002936:	8526                	mv	a0,s1
    80002938:	bff9                	j	80002916 <either_copyin+0x32>

000000008000293a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000293a:	715d                	addi	sp,sp,-80
    8000293c:	e486                	sd	ra,72(sp)
    8000293e:	e0a2                	sd	s0,64(sp)
    80002940:	fc26                	sd	s1,56(sp)
    80002942:	f84a                	sd	s2,48(sp)
    80002944:	f44e                	sd	s3,40(sp)
    80002946:	f052                	sd	s4,32(sp)
    80002948:	ec56                	sd	s5,24(sp)
    8000294a:	e85a                	sd	s6,16(sp)
    8000294c:	e45e                	sd	s7,8(sp)
    8000294e:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002950:	00005517          	auipc	a0,0x5
    80002954:	74850513          	addi	a0,a0,1864 # 80008098 <digits+0x48>
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	c44080e7          	jalr	-956(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002960:	0002f497          	auipc	s1,0x2f
    80002964:	93048493          	addi	s1,s1,-1744 # 80031290 <proc+0x158>
    80002968:	00034917          	auipc	s2,0x34
    8000296c:	32890913          	addi	s2,s2,808 # 80036c90 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002970:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002972:	00006997          	auipc	s3,0x6
    80002976:	96e98993          	addi	s3,s3,-1682 # 800082e0 <digits+0x290>
        printf("%d <%s %s", p->pid, state, p->name);
    8000297a:	00006a97          	auipc	s5,0x6
    8000297e:	96ea8a93          	addi	s5,s5,-1682 # 800082e8 <digits+0x298>
        printf("\n");
    80002982:	00005a17          	auipc	s4,0x5
    80002986:	716a0a13          	addi	s4,s4,1814 # 80008098 <digits+0x48>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000298a:	00006b97          	auipc	s7,0x6
    8000298e:	a6eb8b93          	addi	s7,s7,-1426 # 800083f8 <states.0>
    80002992:	a00d                	j	800029b4 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002994:	ed86a583          	lw	a1,-296(a3)
    80002998:	8556                	mv	a0,s5
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	c02080e7          	jalr	-1022(ra) # 8000059c <printf>
        printf("\n");
    800029a2:	8552                	mv	a0,s4
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	bf8080e7          	jalr	-1032(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800029ac:	16848493          	addi	s1,s1,360
    800029b0:	03248263          	beq	s1,s2,800029d4 <procdump+0x9a>
        if (p->state == UNUSED)
    800029b4:	86a6                	mv	a3,s1
    800029b6:	ec04a783          	lw	a5,-320(s1)
    800029ba:	dbed                	beqz	a5,800029ac <procdump+0x72>
            state = "???";
    800029bc:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029be:	fcfb6be3          	bltu	s6,a5,80002994 <procdump+0x5a>
    800029c2:	02079713          	slli	a4,a5,0x20
    800029c6:	01d75793          	srli	a5,a4,0x1d
    800029ca:	97de                	add	a5,a5,s7
    800029cc:	6390                	ld	a2,0(a5)
    800029ce:	f279                	bnez	a2,80002994 <procdump+0x5a>
            state = "???";
    800029d0:	864e                	mv	a2,s3
    800029d2:	b7c9                	j	80002994 <procdump+0x5a>
    }
}
    800029d4:	60a6                	ld	ra,72(sp)
    800029d6:	6406                	ld	s0,64(sp)
    800029d8:	74e2                	ld	s1,56(sp)
    800029da:	7942                	ld	s2,48(sp)
    800029dc:	79a2                	ld	s3,40(sp)
    800029de:	7a02                	ld	s4,32(sp)
    800029e0:	6ae2                	ld	s5,24(sp)
    800029e2:	6b42                	ld	s6,16(sp)
    800029e4:	6ba2                	ld	s7,8(sp)
    800029e6:	6161                	addi	sp,sp,80
    800029e8:	8082                	ret

00000000800029ea <schedls>:

void schedls()
{
    800029ea:	1141                	addi	sp,sp,-16
    800029ec:	e406                	sd	ra,8(sp)
    800029ee:	e022                	sd	s0,0(sp)
    800029f0:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    800029f2:	00006517          	auipc	a0,0x6
    800029f6:	90650513          	addi	a0,a0,-1786 # 800082f8 <digits+0x2a8>
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	ba2080e7          	jalr	-1118(ra) # 8000059c <printf>
    printf("====================================\n");
    80002a02:	00006517          	auipc	a0,0x6
    80002a06:	91e50513          	addi	a0,a0,-1762 # 80008320 <digits+0x2d0>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b92080e7          	jalr	-1134(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002a12:	00006717          	auipc	a4,0x6
    80002a16:	ff673703          	ld	a4,-10(a4) # 80008a08 <available_schedulers+0x10>
    80002a1a:	00006797          	auipc	a5,0x6
    80002a1e:	f8e7b783          	ld	a5,-114(a5) # 800089a8 <sched_pointer>
    80002a22:	04f70663          	beq	a4,a5,80002a6e <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	92a50513          	addi	a0,a0,-1750 # 80008350 <digits+0x300>
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	b6e080e7          	jalr	-1170(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002a36:	00006617          	auipc	a2,0x6
    80002a3a:	fda62603          	lw	a2,-38(a2) # 80008a10 <available_schedulers+0x18>
    80002a3e:	00006597          	auipc	a1,0x6
    80002a42:	fba58593          	addi	a1,a1,-70 # 800089f8 <available_schedulers>
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	91250513          	addi	a0,a0,-1774 # 80008358 <digits+0x308>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	b4e080e7          	jalr	-1202(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002a56:	00006517          	auipc	a0,0x6
    80002a5a:	90a50513          	addi	a0,a0,-1782 # 80008360 <digits+0x310>
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	b3e080e7          	jalr	-1218(ra) # 8000059c <printf>
}
    80002a66:	60a2                	ld	ra,8(sp)
    80002a68:	6402                	ld	s0,0(sp)
    80002a6a:	0141                	addi	sp,sp,16
    80002a6c:	8082                	ret
            printf("[*]\t");
    80002a6e:	00006517          	auipc	a0,0x6
    80002a72:	8da50513          	addi	a0,a0,-1830 # 80008348 <digits+0x2f8>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	b26080e7          	jalr	-1242(ra) # 8000059c <printf>
    80002a7e:	bf65                	j	80002a36 <schedls+0x4c>

0000000080002a80 <schedset>:

void schedset(int id)
{
    80002a80:	1141                	addi	sp,sp,-16
    80002a82:	e406                	sd	ra,8(sp)
    80002a84:	e022                	sd	s0,0(sp)
    80002a86:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002a88:	e90d                	bnez	a0,80002aba <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002a8a:	00006797          	auipc	a5,0x6
    80002a8e:	f7e7b783          	ld	a5,-130(a5) # 80008a08 <available_schedulers+0x10>
    80002a92:	00006717          	auipc	a4,0x6
    80002a96:	f0f73b23          	sd	a5,-234(a4) # 800089a8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002a9a:	00006597          	auipc	a1,0x6
    80002a9e:	f5e58593          	addi	a1,a1,-162 # 800089f8 <available_schedulers>
    80002aa2:	00006517          	auipc	a0,0x6
    80002aa6:	8fe50513          	addi	a0,a0,-1794 # 800083a0 <digits+0x350>
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	af2080e7          	jalr	-1294(ra) # 8000059c <printf>
}
    80002ab2:	60a2                	ld	ra,8(sp)
    80002ab4:	6402                	ld	s0,0(sp)
    80002ab6:	0141                	addi	sp,sp,16
    80002ab8:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002aba:	00006517          	auipc	a0,0x6
    80002abe:	8be50513          	addi	a0,a0,-1858 # 80008378 <digits+0x328>
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	ada080e7          	jalr	-1318(ra) # 8000059c <printf>
        return;
    80002aca:	b7e5                	j	80002ab2 <schedset+0x32>

0000000080002acc <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    80002acc:	7179                	addi	sp,sp,-48
    80002ace:	f406                	sd	ra,40(sp)
    80002ad0:	f022                	sd	s0,32(sp)
    80002ad2:	ec26                	sd	s1,24(sp)
    80002ad4:	e84a                	sd	s2,16(sp)
    80002ad6:	e44e                	sd	s3,8(sp)
    80002ad8:	e052                	sd	s4,0(sp)
    80002ada:	1800                	addi	s0,sp,48
    80002adc:	8a2a                	mv	s4,a0
    80002ade:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    80002ae0:	0002e497          	auipc	s1,0x2e
    80002ae4:	65848493          	addi	s1,s1,1624 # 80031138 <proc>
    80002ae8:	00034997          	auipc	s3,0x34
    80002aec:	05098993          	addi	s3,s3,80 # 80036b38 <tickslock>
    80002af0:	a811                	j	80002b04 <transvirtproc+0x38>
    {
	acquire(&p->lock);
	found = p->pid == pid && p->state != UNUSED; 
	release(&p->lock);
    80002af2:	8526                	mv	a0,s1
    80002af4:	ffffe097          	auipc	ra,0xffffe
    80002af8:	368080e7          	jalr	872(ra) # 80000e5c <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002afc:	16848493          	addi	s1,s1,360
    80002b00:	03348f63          	beq	s1,s3,80002b3e <transvirtproc+0x72>
	acquire(&p->lock);
    80002b04:	8526                	mv	a0,s1
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	2a2080e7          	jalr	674(ra) # 80000da8 <acquire>
	found = p->pid == pid && p->state != UNUSED; 
    80002b0e:	589c                	lw	a5,48(s1)
    80002b10:	ff2791e3          	bne	a5,s2,80002af2 <transvirtproc+0x26>
    80002b14:	4c9c                	lw	a5,24(s1)
    80002b16:	dff1                	beqz	a5,80002af2 <transvirtproc+0x26>
	release(&p->lock);
    80002b18:	8526                	mv	a0,s1
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	342080e7          	jalr	834(ra) # 80000e5c <release>
    if (!found) {
	return 0;
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002b22:	68ac                	ld	a1,80(s1)
    80002b24:	8552                	mv	a0,s4
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	ee2080e7          	jalr	-286(ra) # 80001a08 <transvirt>
}
    80002b2e:	70a2                	ld	ra,40(sp)
    80002b30:	7402                	ld	s0,32(sp)
    80002b32:	64e2                	ld	s1,24(sp)
    80002b34:	6942                	ld	s2,16(sp)
    80002b36:	69a2                	ld	s3,8(sp)
    80002b38:	6a02                	ld	s4,0(sp)
    80002b3a:	6145                	addi	sp,sp,48
    80002b3c:	8082                	ret
	return 0;
    80002b3e:	4501                	li	a0,0
    80002b40:	b7fd                	j	80002b2e <transvirtproc+0x62>

0000000080002b42 <swtch>:
    80002b42:	00153023          	sd	ra,0(a0)
    80002b46:	00253423          	sd	sp,8(a0)
    80002b4a:	e900                	sd	s0,16(a0)
    80002b4c:	ed04                	sd	s1,24(a0)
    80002b4e:	03253023          	sd	s2,32(a0)
    80002b52:	03353423          	sd	s3,40(a0)
    80002b56:	03453823          	sd	s4,48(a0)
    80002b5a:	03553c23          	sd	s5,56(a0)
    80002b5e:	05653023          	sd	s6,64(a0)
    80002b62:	05753423          	sd	s7,72(a0)
    80002b66:	05853823          	sd	s8,80(a0)
    80002b6a:	05953c23          	sd	s9,88(a0)
    80002b6e:	07a53023          	sd	s10,96(a0)
    80002b72:	07b53423          	sd	s11,104(a0)
    80002b76:	0005b083          	ld	ra,0(a1)
    80002b7a:	0085b103          	ld	sp,8(a1)
    80002b7e:	6980                	ld	s0,16(a1)
    80002b80:	6d84                	ld	s1,24(a1)
    80002b82:	0205b903          	ld	s2,32(a1)
    80002b86:	0285b983          	ld	s3,40(a1)
    80002b8a:	0305ba03          	ld	s4,48(a1)
    80002b8e:	0385ba83          	ld	s5,56(a1)
    80002b92:	0405bb03          	ld	s6,64(a1)
    80002b96:	0485bb83          	ld	s7,72(a1)
    80002b9a:	0505bc03          	ld	s8,80(a1)
    80002b9e:	0585bc83          	ld	s9,88(a1)
    80002ba2:	0605bd03          	ld	s10,96(a1)
    80002ba6:	0685bd83          	ld	s11,104(a1)
    80002baa:	8082                	ret

0000000080002bac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002bac:	1141                	addi	sp,sp,-16
    80002bae:	e406                	sd	ra,8(sp)
    80002bb0:	e022                	sd	s0,0(sp)
    80002bb2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002bb4:	00006597          	auipc	a1,0x6
    80002bb8:	87458593          	addi	a1,a1,-1932 # 80008428 <states.0+0x30>
    80002bbc:	00034517          	auipc	a0,0x34
    80002bc0:	f7c50513          	addi	a0,a0,-132 # 80036b38 <tickslock>
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	154080e7          	jalr	340(ra) # 80000d18 <initlock>
}
    80002bcc:	60a2                	ld	ra,8(sp)
    80002bce:	6402                	ld	s0,0(sp)
    80002bd0:	0141                	addi	sp,sp,16
    80002bd2:	8082                	ret

0000000080002bd4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bd4:	1141                	addi	sp,sp,-16
    80002bd6:	e422                	sd	s0,8(sp)
    80002bd8:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002bda:	00003797          	auipc	a5,0x3
    80002bde:	5f678793          	addi	a5,a5,1526 # 800061d0 <kernelvec>
    80002be2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002be6:	6422                	ld	s0,8(sp)
    80002be8:	0141                	addi	sp,sp,16
    80002bea:	8082                	ret

0000000080002bec <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002bec:	1141                	addi	sp,sp,-16
    80002bee:	e406                	sd	ra,8(sp)
    80002bf0:	e022                	sd	s0,0(sp)
    80002bf2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bf4:	fffff097          	auipc	ra,0xfffff
    80002bf8:	0e4080e7          	jalr	228(ra) # 80001cd8 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002bfc:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c00:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002c02:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002c06:	00004697          	auipc	a3,0x4
    80002c0a:	3fa68693          	addi	a3,a3,1018 # 80007000 <_trampoline>
    80002c0e:	00004717          	auipc	a4,0x4
    80002c12:	3f270713          	addi	a4,a4,1010 # 80007000 <_trampoline>
    80002c16:	8f15                	sub	a4,a4,a3
    80002c18:	040007b7          	lui	a5,0x4000
    80002c1c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002c1e:	07b2                	slli	a5,a5,0xc
    80002c20:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002c22:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c26:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002c28:	18002673          	csrr	a2,satp
    80002c2c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c2e:	6d30                	ld	a2,88(a0)
    80002c30:	6138                	ld	a4,64(a0)
    80002c32:	6585                	lui	a1,0x1
    80002c34:	972e                	add	a4,a4,a1
    80002c36:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c38:	6d38                	ld	a4,88(a0)
    80002c3a:	00000617          	auipc	a2,0x0
    80002c3e:	13060613          	addi	a2,a2,304 # 80002d6a <usertrap>
    80002c42:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c44:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002c46:	8612                	mv	a2,tp
    80002c48:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002c4a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c4e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c52:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002c56:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c5a:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002c5c:	6f18                	ld	a4,24(a4)
    80002c5e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c62:	6928                	ld	a0,80(a0)
    80002c64:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c66:	00004717          	auipc	a4,0x4
    80002c6a:	43670713          	addi	a4,a4,1078 # 8000709c <userret>
    80002c6e:	8f15                	sub	a4,a4,a3
    80002c70:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c72:	577d                	li	a4,-1
    80002c74:	177e                	slli	a4,a4,0x3f
    80002c76:	8d59                	or	a0,a0,a4
    80002c78:	9782                	jalr	a5
}
    80002c7a:	60a2                	ld	ra,8(sp)
    80002c7c:	6402                	ld	s0,0(sp)
    80002c7e:	0141                	addi	sp,sp,16
    80002c80:	8082                	ret

0000000080002c82 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c82:	1101                	addi	sp,sp,-32
    80002c84:	ec06                	sd	ra,24(sp)
    80002c86:	e822                	sd	s0,16(sp)
    80002c88:	e426                	sd	s1,8(sp)
    80002c8a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c8c:	00034497          	auipc	s1,0x34
    80002c90:	eac48493          	addi	s1,s1,-340 # 80036b38 <tickslock>
    80002c94:	8526                	mv	a0,s1
    80002c96:	ffffe097          	auipc	ra,0xffffe
    80002c9a:	112080e7          	jalr	274(ra) # 80000da8 <acquire>
  ticks++;
    80002c9e:	00006517          	auipc	a0,0x6
    80002ca2:	de250513          	addi	a0,a0,-542 # 80008a80 <ticks>
    80002ca6:	411c                	lw	a5,0(a0)
    80002ca8:	2785                	addiw	a5,a5,1
    80002caa:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	83e080e7          	jalr	-1986(ra) # 800024ea <wakeup>
  release(&tickslock);
    80002cb4:	8526                	mv	a0,s1
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	1a6080e7          	jalr	422(ra) # 80000e5c <release>
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6105                	addi	sp,sp,32
    80002cc6:	8082                	ret

0000000080002cc8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cc8:	1101                	addi	sp,sp,-32
    80002cca:	ec06                	sd	ra,24(sp)
    80002ccc:	e822                	sd	s0,16(sp)
    80002cce:	e426                	sd	s1,8(sp)
    80002cd0:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, scause" : "=r"(x));
    80002cd2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002cd6:	00074d63          	bltz	a4,80002cf0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002cda:	57fd                	li	a5,-1
    80002cdc:	17fe                	slli	a5,a5,0x3f
    80002cde:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ce0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ce2:	06f70363          	beq	a4,a5,80002d48 <devintr+0x80>
  }
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6105                	addi	sp,sp,32
    80002cee:	8082                	ret
     (scause & 0xff) == 9){
    80002cf0:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002cf4:	46a5                	li	a3,9
    80002cf6:	fed792e3          	bne	a5,a3,80002cda <devintr+0x12>
    int irq = plic_claim();
    80002cfa:	00003097          	auipc	ra,0x3
    80002cfe:	5de080e7          	jalr	1502(ra) # 800062d8 <plic_claim>
    80002d02:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d04:	47a9                	li	a5,10
    80002d06:	02f50763          	beq	a0,a5,80002d34 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d0a:	4785                	li	a5,1
    80002d0c:	02f50963          	beq	a0,a5,80002d3e <devintr+0x76>
    return 1;
    80002d10:	4505                	li	a0,1
    } else if(irq){
    80002d12:	d8f1                	beqz	s1,80002ce6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d14:	85a6                	mv	a1,s1
    80002d16:	00005517          	auipc	a0,0x5
    80002d1a:	71a50513          	addi	a0,a0,1818 # 80008430 <states.0+0x38>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	87e080e7          	jalr	-1922(ra) # 8000059c <printf>
      plic_complete(irq);
    80002d26:	8526                	mv	a0,s1
    80002d28:	00003097          	auipc	ra,0x3
    80002d2c:	5d4080e7          	jalr	1492(ra) # 800062fc <plic_complete>
    return 1;
    80002d30:	4505                	li	a0,1
    80002d32:	bf55                	j	80002ce6 <devintr+0x1e>
      uartintr();
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	c76080e7          	jalr	-906(ra) # 800009aa <uartintr>
    80002d3c:	b7ed                	j	80002d26 <devintr+0x5e>
      virtio_disk_intr();
    80002d3e:	00004097          	auipc	ra,0x4
    80002d42:	a86080e7          	jalr	-1402(ra) # 800067c4 <virtio_disk_intr>
    80002d46:	b7c5                	j	80002d26 <devintr+0x5e>
    if(cpuid() == 0){
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	f64080e7          	jalr	-156(ra) # 80001cac <cpuid>
    80002d50:	c901                	beqz	a0,80002d60 <devintr+0x98>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002d52:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d56:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002d58:	14479073          	csrw	sip,a5
    return 2;
    80002d5c:	4509                	li	a0,2
    80002d5e:	b761                	j	80002ce6 <devintr+0x1e>
      clockintr();
    80002d60:	00000097          	auipc	ra,0x0
    80002d64:	f22080e7          	jalr	-222(ra) # 80002c82 <clockintr>
    80002d68:	b7ed                	j	80002d52 <devintr+0x8a>

0000000080002d6a <usertrap>:
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	e04a                	sd	s2,0(sp)
    80002d74:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002d76:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d7a:	1007f793          	andi	a5,a5,256
    80002d7e:	e3b1                	bnez	a5,80002dc2 <usertrap+0x58>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002d80:	00003797          	auipc	a5,0x3
    80002d84:	45078793          	addi	a5,a5,1104 # 800061d0 <kernelvec>
    80002d88:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	f4c080e7          	jalr	-180(ra) # 80001cd8 <myproc>
    80002d94:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d96:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002d98:	14102773          	csrr	a4,sepc
    80002d9c:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002d9e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002da2:	47a1                	li	a5,8
    80002da4:	02f70763          	beq	a4,a5,80002dd2 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	f20080e7          	jalr	-224(ra) # 80002cc8 <devintr>
    80002db0:	892a                	mv	s2,a0
    80002db2:	c151                	beqz	a0,80002e36 <usertrap+0xcc>
  if(killed(p))
    80002db4:	8526                	mv	a0,s1
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	978080e7          	jalr	-1672(ra) # 8000272e <killed>
    80002dbe:	c929                	beqz	a0,80002e10 <usertrap+0xa6>
    80002dc0:	a099                	j	80002e06 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002dc2:	00005517          	auipc	a0,0x5
    80002dc6:	68e50513          	addi	a0,a0,1678 # 80008450 <states.0+0x58>
    80002dca:	ffffd097          	auipc	ra,0xffffd
    80002dce:	776080e7          	jalr	1910(ra) # 80000540 <panic>
    if(killed(p))
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	95c080e7          	jalr	-1700(ra) # 8000272e <killed>
    80002dda:	e921                	bnez	a0,80002e2a <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002ddc:	6cb8                	ld	a4,88(s1)
    80002dde:	6f1c                	ld	a5,24(a4)
    80002de0:	0791                	addi	a5,a5,4
    80002de2:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002de4:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002de8:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002dec:	10079073          	csrw	sstatus,a5
    syscall();
    80002df0:	00000097          	auipc	ra,0x0
    80002df4:	2d4080e7          	jalr	724(ra) # 800030c4 <syscall>
  if(killed(p))
    80002df8:	8526                	mv	a0,s1
    80002dfa:	00000097          	auipc	ra,0x0
    80002dfe:	934080e7          	jalr	-1740(ra) # 8000272e <killed>
    80002e02:	c911                	beqz	a0,80002e16 <usertrap+0xac>
    80002e04:	4901                	li	s2,0
    exit(-1);
    80002e06:	557d                	li	a0,-1
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	7b2080e7          	jalr	1970(ra) # 800025ba <exit>
  if(which_dev == 2)
    80002e10:	4789                	li	a5,2
    80002e12:	04f90f63          	beq	s2,a5,80002e70 <usertrap+0x106>
  usertrapret();
    80002e16:	00000097          	auipc	ra,0x0
    80002e1a:	dd6080e7          	jalr	-554(ra) # 80002bec <usertrapret>
}
    80002e1e:	60e2                	ld	ra,24(sp)
    80002e20:	6442                	ld	s0,16(sp)
    80002e22:	64a2                	ld	s1,8(sp)
    80002e24:	6902                	ld	s2,0(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret
      exit(-1);
    80002e2a:	557d                	li	a0,-1
    80002e2c:	fffff097          	auipc	ra,0xfffff
    80002e30:	78e080e7          	jalr	1934(ra) # 800025ba <exit>
    80002e34:	b765                	j	80002ddc <usertrap+0x72>
    asm volatile("csrr %0, scause" : "=r"(x));
    80002e36:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e3a:	5890                	lw	a2,48(s1)
    80002e3c:	00005517          	auipc	a0,0x5
    80002e40:	63450513          	addi	a0,a0,1588 # 80008470 <states.0+0x78>
    80002e44:	ffffd097          	auipc	ra,0xffffd
    80002e48:	758080e7          	jalr	1880(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002e4c:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002e50:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e54:	00005517          	auipc	a0,0x5
    80002e58:	64c50513          	addi	a0,a0,1612 # 800084a0 <states.0+0xa8>
    80002e5c:	ffffd097          	auipc	ra,0xffffd
    80002e60:	740080e7          	jalr	1856(ra) # 8000059c <printf>
    setkilled(p);
    80002e64:	8526                	mv	a0,s1
    80002e66:	00000097          	auipc	ra,0x0
    80002e6a:	89c080e7          	jalr	-1892(ra) # 80002702 <setkilled>
    80002e6e:	b769                	j	80002df8 <usertrap+0x8e>
    yield();
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	5da080e7          	jalr	1498(ra) # 8000244a <yield>
    80002e78:	bf79                	j	80002e16 <usertrap+0xac>

0000000080002e7a <kerneltrap>:
{
    80002e7a:	7179                	addi	sp,sp,-48
    80002e7c:	f406                	sd	ra,40(sp)
    80002e7e:	f022                	sd	s0,32(sp)
    80002e80:	ec26                	sd	s1,24(sp)
    80002e82:	e84a                	sd	s2,16(sp)
    80002e84:	e44e                	sd	s3,8(sp)
    80002e86:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002e88:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002e8c:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    80002e90:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e94:	1004f793          	andi	a5,s1,256
    80002e98:	cb85                	beqz	a5,80002ec8 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002e9a:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002e9e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ea0:	ef85                	bnez	a5,80002ed8 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ea2:	00000097          	auipc	ra,0x0
    80002ea6:	e26080e7          	jalr	-474(ra) # 80002cc8 <devintr>
    80002eaa:	cd1d                	beqz	a0,80002ee8 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002eac:	4789                	li	a5,2
    80002eae:	06f50a63          	beq	a0,a5,80002f22 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002eb2:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002eb6:	10049073          	csrw	sstatus,s1
}
    80002eba:	70a2                	ld	ra,40(sp)
    80002ebc:	7402                	ld	s0,32(sp)
    80002ebe:	64e2                	ld	s1,24(sp)
    80002ec0:	6942                	ld	s2,16(sp)
    80002ec2:	69a2                	ld	s3,8(sp)
    80002ec4:	6145                	addi	sp,sp,48
    80002ec6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ec8:	00005517          	auipc	a0,0x5
    80002ecc:	5f850513          	addi	a0,a0,1528 # 800084c0 <states.0+0xc8>
    80002ed0:	ffffd097          	auipc	ra,0xffffd
    80002ed4:	670080e7          	jalr	1648(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ed8:	00005517          	auipc	a0,0x5
    80002edc:	61050513          	addi	a0,a0,1552 # 800084e8 <states.0+0xf0>
    80002ee0:	ffffd097          	auipc	ra,0xffffd
    80002ee4:	660080e7          	jalr	1632(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002ee8:	85ce                	mv	a1,s3
    80002eea:	00005517          	auipc	a0,0x5
    80002eee:	61e50513          	addi	a0,a0,1566 # 80008508 <states.0+0x110>
    80002ef2:	ffffd097          	auipc	ra,0xffffd
    80002ef6:	6aa080e7          	jalr	1706(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002efa:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002efe:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f02:	00005517          	auipc	a0,0x5
    80002f06:	61650513          	addi	a0,a0,1558 # 80008518 <states.0+0x120>
    80002f0a:	ffffd097          	auipc	ra,0xffffd
    80002f0e:	692080e7          	jalr	1682(ra) # 8000059c <printf>
    panic("kerneltrap");
    80002f12:	00005517          	auipc	a0,0x5
    80002f16:	61e50513          	addi	a0,a0,1566 # 80008530 <states.0+0x138>
    80002f1a:	ffffd097          	auipc	ra,0xffffd
    80002f1e:	626080e7          	jalr	1574(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f22:	fffff097          	auipc	ra,0xfffff
    80002f26:	db6080e7          	jalr	-586(ra) # 80001cd8 <myproc>
    80002f2a:	d541                	beqz	a0,80002eb2 <kerneltrap+0x38>
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	dac080e7          	jalr	-596(ra) # 80001cd8 <myproc>
    80002f34:	4d18                	lw	a4,24(a0)
    80002f36:	4791                	li	a5,4
    80002f38:	f6f71de3          	bne	a4,a5,80002eb2 <kerneltrap+0x38>
    yield();
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	50e080e7          	jalr	1294(ra) # 8000244a <yield>
    80002f44:	b7bd                	j	80002eb2 <kerneltrap+0x38>

0000000080002f46 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f46:	1101                	addi	sp,sp,-32
    80002f48:	ec06                	sd	ra,24(sp)
    80002f4a:	e822                	sd	s0,16(sp)
    80002f4c:	e426                	sd	s1,8(sp)
    80002f4e:	1000                	addi	s0,sp,32
    80002f50:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	d86080e7          	jalr	-634(ra) # 80001cd8 <myproc>
    switch (n)
    80002f5a:	4795                	li	a5,5
    80002f5c:	0497e163          	bltu	a5,s1,80002f9e <argraw+0x58>
    80002f60:	048a                	slli	s1,s1,0x2
    80002f62:	00005717          	auipc	a4,0x5
    80002f66:	60670713          	addi	a4,a4,1542 # 80008568 <states.0+0x170>
    80002f6a:	94ba                	add	s1,s1,a4
    80002f6c:	409c                	lw	a5,0(s1)
    80002f6e:	97ba                	add	a5,a5,a4
    80002f70:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002f72:	6d3c                	ld	a5,88(a0)
    80002f74:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002f76:	60e2                	ld	ra,24(sp)
    80002f78:	6442                	ld	s0,16(sp)
    80002f7a:	64a2                	ld	s1,8(sp)
    80002f7c:	6105                	addi	sp,sp,32
    80002f7e:	8082                	ret
        return p->trapframe->a1;
    80002f80:	6d3c                	ld	a5,88(a0)
    80002f82:	7fa8                	ld	a0,120(a5)
    80002f84:	bfcd                	j	80002f76 <argraw+0x30>
        return p->trapframe->a2;
    80002f86:	6d3c                	ld	a5,88(a0)
    80002f88:	63c8                	ld	a0,128(a5)
    80002f8a:	b7f5                	j	80002f76 <argraw+0x30>
        return p->trapframe->a3;
    80002f8c:	6d3c                	ld	a5,88(a0)
    80002f8e:	67c8                	ld	a0,136(a5)
    80002f90:	b7dd                	j	80002f76 <argraw+0x30>
        return p->trapframe->a4;
    80002f92:	6d3c                	ld	a5,88(a0)
    80002f94:	6bc8                	ld	a0,144(a5)
    80002f96:	b7c5                	j	80002f76 <argraw+0x30>
        return p->trapframe->a5;
    80002f98:	6d3c                	ld	a5,88(a0)
    80002f9a:	6fc8                	ld	a0,152(a5)
    80002f9c:	bfe9                	j	80002f76 <argraw+0x30>
    panic("argraw");
    80002f9e:	00005517          	auipc	a0,0x5
    80002fa2:	5a250513          	addi	a0,a0,1442 # 80008540 <states.0+0x148>
    80002fa6:	ffffd097          	auipc	ra,0xffffd
    80002faa:	59a080e7          	jalr	1434(ra) # 80000540 <panic>

0000000080002fae <fetchaddr>:
{
    80002fae:	1101                	addi	sp,sp,-32
    80002fb0:	ec06                	sd	ra,24(sp)
    80002fb2:	e822                	sd	s0,16(sp)
    80002fb4:	e426                	sd	s1,8(sp)
    80002fb6:	e04a                	sd	s2,0(sp)
    80002fb8:	1000                	addi	s0,sp,32
    80002fba:	84aa                	mv	s1,a0
    80002fbc:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	d1a080e7          	jalr	-742(ra) # 80001cd8 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002fc6:	653c                	ld	a5,72(a0)
    80002fc8:	02f4f863          	bgeu	s1,a5,80002ff8 <fetchaddr+0x4a>
    80002fcc:	00848713          	addi	a4,s1,8
    80002fd0:	02e7e663          	bltu	a5,a4,80002ffc <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fd4:	46a1                	li	a3,8
    80002fd6:	8626                	mv	a2,s1
    80002fd8:	85ca                	mv	a1,s2
    80002fda:	6928                	ld	a0,80(a0)
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	8ee080e7          	jalr	-1810(ra) # 800018ca <copyin>
    80002fe4:	00a03533          	snez	a0,a0
    80002fe8:	40a00533          	neg	a0,a0
}
    80002fec:	60e2                	ld	ra,24(sp)
    80002fee:	6442                	ld	s0,16(sp)
    80002ff0:	64a2                	ld	s1,8(sp)
    80002ff2:	6902                	ld	s2,0(sp)
    80002ff4:	6105                	addi	sp,sp,32
    80002ff6:	8082                	ret
        return -1;
    80002ff8:	557d                	li	a0,-1
    80002ffa:	bfcd                	j	80002fec <fetchaddr+0x3e>
    80002ffc:	557d                	li	a0,-1
    80002ffe:	b7fd                	j	80002fec <fetchaddr+0x3e>

0000000080003000 <fetchstr>:
{
    80003000:	7179                	addi	sp,sp,-48
    80003002:	f406                	sd	ra,40(sp)
    80003004:	f022                	sd	s0,32(sp)
    80003006:	ec26                	sd	s1,24(sp)
    80003008:	e84a                	sd	s2,16(sp)
    8000300a:	e44e                	sd	s3,8(sp)
    8000300c:	1800                	addi	s0,sp,48
    8000300e:	892a                	mv	s2,a0
    80003010:	84ae                	mv	s1,a1
    80003012:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	cc4080e7          	jalr	-828(ra) # 80001cd8 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    8000301c:	86ce                	mv	a3,s3
    8000301e:	864a                	mv	a2,s2
    80003020:	85a6                	mv	a1,s1
    80003022:	6928                	ld	a0,80(a0)
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	934080e7          	jalr	-1740(ra) # 80001958 <copyinstr>
    8000302c:	00054e63          	bltz	a0,80003048 <fetchstr+0x48>
    return strlen(buf);
    80003030:	8526                	mv	a0,s1
    80003032:	ffffe097          	auipc	ra,0xffffe
    80003036:	fee080e7          	jalr	-18(ra) # 80001020 <strlen>
}
    8000303a:	70a2                	ld	ra,40(sp)
    8000303c:	7402                	ld	s0,32(sp)
    8000303e:	64e2                	ld	s1,24(sp)
    80003040:	6942                	ld	s2,16(sp)
    80003042:	69a2                	ld	s3,8(sp)
    80003044:	6145                	addi	sp,sp,48
    80003046:	8082                	ret
        return -1;
    80003048:	557d                	li	a0,-1
    8000304a:	bfc5                	j	8000303a <fetchstr+0x3a>

000000008000304c <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    8000304c:	1101                	addi	sp,sp,-32
    8000304e:	ec06                	sd	ra,24(sp)
    80003050:	e822                	sd	s0,16(sp)
    80003052:	e426                	sd	s1,8(sp)
    80003054:	1000                	addi	s0,sp,32
    80003056:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003058:	00000097          	auipc	ra,0x0
    8000305c:	eee080e7          	jalr	-274(ra) # 80002f46 <argraw>
    80003060:	c088                	sw	a0,0(s1)
}
    80003062:	60e2                	ld	ra,24(sp)
    80003064:	6442                	ld	s0,16(sp)
    80003066:	64a2                	ld	s1,8(sp)
    80003068:	6105                	addi	sp,sp,32
    8000306a:	8082                	ret

000000008000306c <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    8000306c:	1101                	addi	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	e426                	sd	s1,8(sp)
    80003074:	1000                	addi	s0,sp,32
    80003076:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003078:	00000097          	auipc	ra,0x0
    8000307c:	ece080e7          	jalr	-306(ra) # 80002f46 <argraw>
    80003080:	e088                	sd	a0,0(s1)
}
    80003082:	60e2                	ld	ra,24(sp)
    80003084:	6442                	ld	s0,16(sp)
    80003086:	64a2                	ld	s1,8(sp)
    80003088:	6105                	addi	sp,sp,32
    8000308a:	8082                	ret

000000008000308c <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    8000308c:	7179                	addi	sp,sp,-48
    8000308e:	f406                	sd	ra,40(sp)
    80003090:	f022                	sd	s0,32(sp)
    80003092:	ec26                	sd	s1,24(sp)
    80003094:	e84a                	sd	s2,16(sp)
    80003096:	1800                	addi	s0,sp,48
    80003098:	84ae                	mv	s1,a1
    8000309a:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    8000309c:	fd840593          	addi	a1,s0,-40
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	fcc080e7          	jalr	-52(ra) # 8000306c <argaddr>
    return fetchstr(addr, buf, max);
    800030a8:	864a                	mv	a2,s2
    800030aa:	85a6                	mv	a1,s1
    800030ac:	fd843503          	ld	a0,-40(s0)
    800030b0:	00000097          	auipc	ra,0x0
    800030b4:	f50080e7          	jalr	-176(ra) # 80003000 <fetchstr>
}
    800030b8:	70a2                	ld	ra,40(sp)
    800030ba:	7402                	ld	s0,32(sp)
    800030bc:	64e2                	ld	s1,24(sp)
    800030be:	6942                	ld	s2,16(sp)
    800030c0:	6145                	addi	sp,sp,48
    800030c2:	8082                	ret

00000000800030c4 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    800030c4:	1101                	addi	sp,sp,-32
    800030c6:	ec06                	sd	ra,24(sp)
    800030c8:	e822                	sd	s0,16(sp)
    800030ca:	e426                	sd	s1,8(sp)
    800030cc:	e04a                	sd	s2,0(sp)
    800030ce:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	c08080e7          	jalr	-1016(ra) # 80001cd8 <myproc>
    800030d8:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    800030da:	05853903          	ld	s2,88(a0)
    800030de:	0a893783          	ld	a5,168(s2)
    800030e2:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800030e6:	37fd                	addiw	a5,a5,-1
    800030e8:	4765                	li	a4,25
    800030ea:	00f76f63          	bltu	a4,a5,80003108 <syscall+0x44>
    800030ee:	00369713          	slli	a4,a3,0x3
    800030f2:	00005797          	auipc	a5,0x5
    800030f6:	48e78793          	addi	a5,a5,1166 # 80008580 <syscalls>
    800030fa:	97ba                	add	a5,a5,a4
    800030fc:	639c                	ld	a5,0(a5)
    800030fe:	c789                	beqz	a5,80003108 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003100:	9782                	jalr	a5
    80003102:	06a93823          	sd	a0,112(s2)
    80003106:	a839                	j	80003124 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80003108:	15848613          	addi	a2,s1,344
    8000310c:	588c                	lw	a1,48(s1)
    8000310e:	00005517          	auipc	a0,0x5
    80003112:	43a50513          	addi	a0,a0,1082 # 80008548 <states.0+0x150>
    80003116:	ffffd097          	auipc	ra,0xffffd
    8000311a:	486080e7          	jalr	1158(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    8000311e:	6cbc                	ld	a5,88(s1)
    80003120:	577d                	li	a4,-1
    80003122:	fbb8                	sd	a4,112(a5)
    }
}
    80003124:	60e2                	ld	ra,24(sp)
    80003126:	6442                	ld	s0,16(sp)
    80003128:	64a2                	ld	s1,8(sp)
    8000312a:	6902                	ld	s2,0(sp)
    8000312c:	6105                	addi	sp,sp,32
    8000312e:	8082                	ret

0000000080003130 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003130:	1101                	addi	sp,sp,-32
    80003132:	ec06                	sd	ra,24(sp)
    80003134:	e822                	sd	s0,16(sp)
    80003136:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80003138:	fec40593          	addi	a1,s0,-20
    8000313c:	4501                	li	a0,0
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	f0e080e7          	jalr	-242(ra) # 8000304c <argint>
    exit(n);
    80003146:	fec42503          	lw	a0,-20(s0)
    8000314a:	fffff097          	auipc	ra,0xfffff
    8000314e:	470080e7          	jalr	1136(ra) # 800025ba <exit>
    return 0; // not reached
}
    80003152:	4501                	li	a0,0
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	6105                	addi	sp,sp,32
    8000315a:	8082                	ret

000000008000315c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000315c:	1141                	addi	sp,sp,-16
    8000315e:	e406                	sd	ra,8(sp)
    80003160:	e022                	sd	s0,0(sp)
    80003162:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003164:	fffff097          	auipc	ra,0xfffff
    80003168:	b74080e7          	jalr	-1164(ra) # 80001cd8 <myproc>
}
    8000316c:	5908                	lw	a0,48(a0)
    8000316e:	60a2                	ld	ra,8(sp)
    80003170:	6402                	ld	s0,0(sp)
    80003172:	0141                	addi	sp,sp,16
    80003174:	8082                	ret

0000000080003176 <sys_fork>:

uint64
sys_fork(void)
{
    80003176:	1141                	addi	sp,sp,-16
    80003178:	e406                	sd	ra,8(sp)
    8000317a:	e022                	sd	s0,0(sp)
    8000317c:	0800                	addi	s0,sp,16
    return fork();
    8000317e:	fffff097          	auipc	ra,0xfffff
    80003182:	0a6080e7          	jalr	166(ra) # 80002224 <fork>
}
    80003186:	60a2                	ld	ra,8(sp)
    80003188:	6402                	ld	s0,0(sp)
    8000318a:	0141                	addi	sp,sp,16
    8000318c:	8082                	ret

000000008000318e <sys_wait>:

uint64
sys_wait(void)
{
    8000318e:	1101                	addi	sp,sp,-32
    80003190:	ec06                	sd	ra,24(sp)
    80003192:	e822                	sd	s0,16(sp)
    80003194:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003196:	fe840593          	addi	a1,s0,-24
    8000319a:	4501                	li	a0,0
    8000319c:	00000097          	auipc	ra,0x0
    800031a0:	ed0080e7          	jalr	-304(ra) # 8000306c <argaddr>
    return wait(p);
    800031a4:	fe843503          	ld	a0,-24(s0)
    800031a8:	fffff097          	auipc	ra,0xfffff
    800031ac:	5b8080e7          	jalr	1464(ra) # 80002760 <wait>
}
    800031b0:	60e2                	ld	ra,24(sp)
    800031b2:	6442                	ld	s0,16(sp)
    800031b4:	6105                	addi	sp,sp,32
    800031b6:	8082                	ret

00000000800031b8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031b8:	7179                	addi	sp,sp,-48
    800031ba:	f406                	sd	ra,40(sp)
    800031bc:	f022                	sd	s0,32(sp)
    800031be:	ec26                	sd	s1,24(sp)
    800031c0:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800031c2:	fdc40593          	addi	a1,s0,-36
    800031c6:	4501                	li	a0,0
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	e84080e7          	jalr	-380(ra) # 8000304c <argint>
    addr = myproc()->sz;
    800031d0:	fffff097          	auipc	ra,0xfffff
    800031d4:	b08080e7          	jalr	-1272(ra) # 80001cd8 <myproc>
    800031d8:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    800031da:	fdc42503          	lw	a0,-36(s0)
    800031de:	fffff097          	auipc	ra,0xfffff
    800031e2:	e54080e7          	jalr	-428(ra) # 80002032 <growproc>
    800031e6:	00054863          	bltz	a0,800031f6 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800031ea:	8526                	mv	a0,s1
    800031ec:	70a2                	ld	ra,40(sp)
    800031ee:	7402                	ld	s0,32(sp)
    800031f0:	64e2                	ld	s1,24(sp)
    800031f2:	6145                	addi	sp,sp,48
    800031f4:	8082                	ret
        return -1;
    800031f6:	54fd                	li	s1,-1
    800031f8:	bfcd                	j	800031ea <sys_sbrk+0x32>

00000000800031fa <sys_sleep>:

uint64
sys_sleep(void)
{
    800031fa:	7139                	addi	sp,sp,-64
    800031fc:	fc06                	sd	ra,56(sp)
    800031fe:	f822                	sd	s0,48(sp)
    80003200:	f426                	sd	s1,40(sp)
    80003202:	f04a                	sd	s2,32(sp)
    80003204:	ec4e                	sd	s3,24(sp)
    80003206:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003208:	fcc40593          	addi	a1,s0,-52
    8000320c:	4501                	li	a0,0
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	e3e080e7          	jalr	-450(ra) # 8000304c <argint>
    acquire(&tickslock);
    80003216:	00034517          	auipc	a0,0x34
    8000321a:	92250513          	addi	a0,a0,-1758 # 80036b38 <tickslock>
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	b8a080e7          	jalr	-1142(ra) # 80000da8 <acquire>
    ticks0 = ticks;
    80003226:	00006917          	auipc	s2,0x6
    8000322a:	85a92903          	lw	s2,-1958(s2) # 80008a80 <ticks>
    while (ticks - ticks0 < n)
    8000322e:	fcc42783          	lw	a5,-52(s0)
    80003232:	cf9d                	beqz	a5,80003270 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80003234:	00034997          	auipc	s3,0x34
    80003238:	90498993          	addi	s3,s3,-1788 # 80036b38 <tickslock>
    8000323c:	00006497          	auipc	s1,0x6
    80003240:	84448493          	addi	s1,s1,-1980 # 80008a80 <ticks>
        if (killed(myproc()))
    80003244:	fffff097          	auipc	ra,0xfffff
    80003248:	a94080e7          	jalr	-1388(ra) # 80001cd8 <myproc>
    8000324c:	fffff097          	auipc	ra,0xfffff
    80003250:	4e2080e7          	jalr	1250(ra) # 8000272e <killed>
    80003254:	ed15                	bnez	a0,80003290 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003256:	85ce                	mv	a1,s3
    80003258:	8526                	mv	a0,s1
    8000325a:	fffff097          	auipc	ra,0xfffff
    8000325e:	22c080e7          	jalr	556(ra) # 80002486 <sleep>
    while (ticks - ticks0 < n)
    80003262:	409c                	lw	a5,0(s1)
    80003264:	412787bb          	subw	a5,a5,s2
    80003268:	fcc42703          	lw	a4,-52(s0)
    8000326c:	fce7ece3          	bltu	a5,a4,80003244 <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003270:	00034517          	auipc	a0,0x34
    80003274:	8c850513          	addi	a0,a0,-1848 # 80036b38 <tickslock>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	be4080e7          	jalr	-1052(ra) # 80000e5c <release>
    return 0;
    80003280:	4501                	li	a0,0
}
    80003282:	70e2                	ld	ra,56(sp)
    80003284:	7442                	ld	s0,48(sp)
    80003286:	74a2                	ld	s1,40(sp)
    80003288:	7902                	ld	s2,32(sp)
    8000328a:	69e2                	ld	s3,24(sp)
    8000328c:	6121                	addi	sp,sp,64
    8000328e:	8082                	ret
            release(&tickslock);
    80003290:	00034517          	auipc	a0,0x34
    80003294:	8a850513          	addi	a0,a0,-1880 # 80036b38 <tickslock>
    80003298:	ffffe097          	auipc	ra,0xffffe
    8000329c:	bc4080e7          	jalr	-1084(ra) # 80000e5c <release>
            return -1;
    800032a0:	557d                	li	a0,-1
    800032a2:	b7c5                	j	80003282 <sys_sleep+0x88>

00000000800032a4 <sys_kill>:

uint64
sys_kill(void)
{
    800032a4:	1101                	addi	sp,sp,-32
    800032a6:	ec06                	sd	ra,24(sp)
    800032a8:	e822                	sd	s0,16(sp)
    800032aa:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800032ac:	fec40593          	addi	a1,s0,-20
    800032b0:	4501                	li	a0,0
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	d9a080e7          	jalr	-614(ra) # 8000304c <argint>
    return kill(pid);
    800032ba:	fec42503          	lw	a0,-20(s0)
    800032be:	fffff097          	auipc	ra,0xfffff
    800032c2:	3d2080e7          	jalr	978(ra) # 80002690 <kill>
}
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	6105                	addi	sp,sp,32
    800032cc:	8082                	ret

00000000800032ce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032ce:	1101                	addi	sp,sp,-32
    800032d0:	ec06                	sd	ra,24(sp)
    800032d2:	e822                	sd	s0,16(sp)
    800032d4:	e426                	sd	s1,8(sp)
    800032d6:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800032d8:	00034517          	auipc	a0,0x34
    800032dc:	86050513          	addi	a0,a0,-1952 # 80036b38 <tickslock>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	ac8080e7          	jalr	-1336(ra) # 80000da8 <acquire>
    xticks = ticks;
    800032e8:	00005497          	auipc	s1,0x5
    800032ec:	7984a483          	lw	s1,1944(s1) # 80008a80 <ticks>
    release(&tickslock);
    800032f0:	00034517          	auipc	a0,0x34
    800032f4:	84850513          	addi	a0,a0,-1976 # 80036b38 <tickslock>
    800032f8:	ffffe097          	auipc	ra,0xffffe
    800032fc:	b64080e7          	jalr	-1180(ra) # 80000e5c <release>
    return xticks;
}
    80003300:	02049513          	slli	a0,s1,0x20
    80003304:	9101                	srli	a0,a0,0x20
    80003306:	60e2                	ld	ra,24(sp)
    80003308:	6442                	ld	s0,16(sp)
    8000330a:	64a2                	ld	s1,8(sp)
    8000330c:	6105                	addi	sp,sp,32
    8000330e:	8082                	ret

0000000080003310 <sys_ps>:

void *
sys_ps(void)
{
    80003310:	1101                	addi	sp,sp,-32
    80003312:	ec06                	sd	ra,24(sp)
    80003314:	e822                	sd	s0,16(sp)
    80003316:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003318:	fe042623          	sw	zero,-20(s0)
    8000331c:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003320:	fec40593          	addi	a1,s0,-20
    80003324:	4501                	li	a0,0
    80003326:	00000097          	auipc	ra,0x0
    8000332a:	d26080e7          	jalr	-730(ra) # 8000304c <argint>
    argint(1, &count);
    8000332e:	fe840593          	addi	a1,s0,-24
    80003332:	4505                	li	a0,1
    80003334:	00000097          	auipc	ra,0x0
    80003338:	d18080e7          	jalr	-744(ra) # 8000304c <argint>
    return ps((uint8)start, (uint8)count);
    8000333c:	fe844583          	lbu	a1,-24(s0)
    80003340:	fec44503          	lbu	a0,-20(s0)
    80003344:	fffff097          	auipc	ra,0xfffff
    80003348:	d4a080e7          	jalr	-694(ra) # 8000208e <ps>
}
    8000334c:	60e2                	ld	ra,24(sp)
    8000334e:	6442                	ld	s0,16(sp)
    80003350:	6105                	addi	sp,sp,32
    80003352:	8082                	ret

0000000080003354 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003354:	1141                	addi	sp,sp,-16
    80003356:	e406                	sd	ra,8(sp)
    80003358:	e022                	sd	s0,0(sp)
    8000335a:	0800                	addi	s0,sp,16
    schedls();
    8000335c:	fffff097          	auipc	ra,0xfffff
    80003360:	68e080e7          	jalr	1678(ra) # 800029ea <schedls>
    return 0;
}
    80003364:	4501                	li	a0,0
    80003366:	60a2                	ld	ra,8(sp)
    80003368:	6402                	ld	s0,0(sp)
    8000336a:	0141                	addi	sp,sp,16
    8000336c:	8082                	ret

000000008000336e <sys_schedset>:

uint64 sys_schedset(void)
{
    8000336e:	1101                	addi	sp,sp,-32
    80003370:	ec06                	sd	ra,24(sp)
    80003372:	e822                	sd	s0,16(sp)
    80003374:	1000                	addi	s0,sp,32
    int id = 0;
    80003376:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    8000337a:	fec40593          	addi	a1,s0,-20
    8000337e:	4501                	li	a0,0
    80003380:	00000097          	auipc	ra,0x0
    80003384:	ccc080e7          	jalr	-820(ra) # 8000304c <argint>
    schedset(id - 1);
    80003388:	fec42503          	lw	a0,-20(s0)
    8000338c:	357d                	addiw	a0,a0,-1
    8000338e:	fffff097          	auipc	ra,0xfffff
    80003392:	6f2080e7          	jalr	1778(ra) # 80002a80 <schedset>
    return 0;
}
    80003396:	4501                	li	a0,0
    80003398:	60e2                	ld	ra,24(sp)
    8000339a:	6442                	ld	s0,16(sp)
    8000339c:	6105                	addi	sp,sp,32
    8000339e:	8082                	ret

00000000800033a0 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    800033a0:	7179                	addi	sp,sp,-48
    800033a2:	f406                	sd	ra,40(sp)
    800033a4:	f022                	sd	s0,32(sp)
    800033a6:	ec26                	sd	s1,24(sp)
    800033a8:	1800                	addi	s0,sp,48
    int pid = 0;
    800033aa:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    800033ae:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    800033b2:	fd040593          	addi	a1,s0,-48
    800033b6:	4501                	li	a0,0
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	cb4080e7          	jalr	-844(ra) # 8000306c <argaddr>
    argint(1, &pid);
    800033c0:	fdc40593          	addi	a1,s0,-36
    800033c4:	4505                	li	a0,1
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	c86080e7          	jalr	-890(ra) # 8000304c <argint>
    if (pid == 0) {
    800033ce:	fdc42783          	lw	a5,-36(s0)
    800033d2:	cf91                	beqz	a5,800033ee <sys_va2pa+0x4e>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    800033d4:	fdc42583          	lw	a1,-36(s0)
    800033d8:	fd043503          	ld	a0,-48(s0)
    800033dc:	fffff097          	auipc	ra,0xfffff
    800033e0:	6f0080e7          	jalr	1776(ra) # 80002acc <transvirtproc>
}
    800033e4:	70a2                	ld	ra,40(sp)
    800033e6:	7402                	ld	s0,32(sp)
    800033e8:	64e2                	ld	s1,24(sp)
    800033ea:	6145                	addi	sp,sp,48
    800033ec:	8082                	ret
	struct proc *p = myproc();
    800033ee:	fffff097          	auipc	ra,0xfffff
    800033f2:	8ea080e7          	jalr	-1814(ra) # 80001cd8 <myproc>
    800033f6:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	9b0080e7          	jalr	-1616(ra) # 80000da8 <acquire>
	pid = p->pid;
    80003400:	589c                	lw	a5,48(s1)
    80003402:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    80003406:	8526                	mv	a0,s1
    80003408:	ffffe097          	auipc	ra,0xffffe
    8000340c:	a54080e7          	jalr	-1452(ra) # 80000e5c <release>
    80003410:	b7d1                	j	800033d4 <sys_va2pa+0x34>

0000000080003412 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003412:	1141                	addi	sp,sp,-16
    80003414:	e406                	sd	ra,8(sp)
    80003416:	e022                	sd	s0,0(sp)
    80003418:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    8000341a:	00005597          	auipc	a1,0x5
    8000341e:	63e5b583          	ld	a1,1598(a1) # 80008a58 <FREE_PAGES>
    80003422:	00005517          	auipc	a0,0x5
    80003426:	13e50513          	addi	a0,a0,318 # 80008560 <states.0+0x168>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	172080e7          	jalr	370(ra) # 8000059c <printf>
    return 0;
}
    80003432:	4501                	li	a0,0
    80003434:	60a2                	ld	ra,8(sp)
    80003436:	6402                	ld	s0,0(sp)
    80003438:	0141                	addi	sp,sp,16
    8000343a:	8082                	ret

000000008000343c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000343c:	7179                	addi	sp,sp,-48
    8000343e:	f406                	sd	ra,40(sp)
    80003440:	f022                	sd	s0,32(sp)
    80003442:	ec26                	sd	s1,24(sp)
    80003444:	e84a                	sd	s2,16(sp)
    80003446:	e44e                	sd	s3,8(sp)
    80003448:	e052                	sd	s4,0(sp)
    8000344a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000344c:	00005597          	auipc	a1,0x5
    80003450:	20c58593          	addi	a1,a1,524 # 80008658 <syscalls+0xd8>
    80003454:	00033517          	auipc	a0,0x33
    80003458:	6fc50513          	addi	a0,a0,1788 # 80036b50 <bcache>
    8000345c:	ffffe097          	auipc	ra,0xffffe
    80003460:	8bc080e7          	jalr	-1860(ra) # 80000d18 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003464:	0003b797          	auipc	a5,0x3b
    80003468:	6ec78793          	addi	a5,a5,1772 # 8003eb50 <bcache+0x8000>
    8000346c:	0003c717          	auipc	a4,0x3c
    80003470:	94c70713          	addi	a4,a4,-1716 # 8003edb8 <bcache+0x8268>
    80003474:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003478:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000347c:	00033497          	auipc	s1,0x33
    80003480:	6ec48493          	addi	s1,s1,1772 # 80036b68 <bcache+0x18>
    b->next = bcache.head.next;
    80003484:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003486:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003488:	00005a17          	auipc	s4,0x5
    8000348c:	1d8a0a13          	addi	s4,s4,472 # 80008660 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003490:	2b893783          	ld	a5,696(s2)
    80003494:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003496:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000349a:	85d2                	mv	a1,s4
    8000349c:	01048513          	addi	a0,s1,16
    800034a0:	00001097          	auipc	ra,0x1
    800034a4:	4c8080e7          	jalr	1224(ra) # 80004968 <initsleeplock>
    bcache.head.next->prev = b;
    800034a8:	2b893783          	ld	a5,696(s2)
    800034ac:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034ae:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034b2:	45848493          	addi	s1,s1,1112
    800034b6:	fd349de3          	bne	s1,s3,80003490 <binit+0x54>
  }
}
    800034ba:	70a2                	ld	ra,40(sp)
    800034bc:	7402                	ld	s0,32(sp)
    800034be:	64e2                	ld	s1,24(sp)
    800034c0:	6942                	ld	s2,16(sp)
    800034c2:	69a2                	ld	s3,8(sp)
    800034c4:	6a02                	ld	s4,0(sp)
    800034c6:	6145                	addi	sp,sp,48
    800034c8:	8082                	ret

00000000800034ca <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034ca:	7179                	addi	sp,sp,-48
    800034cc:	f406                	sd	ra,40(sp)
    800034ce:	f022                	sd	s0,32(sp)
    800034d0:	ec26                	sd	s1,24(sp)
    800034d2:	e84a                	sd	s2,16(sp)
    800034d4:	e44e                	sd	s3,8(sp)
    800034d6:	1800                	addi	s0,sp,48
    800034d8:	892a                	mv	s2,a0
    800034da:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800034dc:	00033517          	auipc	a0,0x33
    800034e0:	67450513          	addi	a0,a0,1652 # 80036b50 <bcache>
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	8c4080e7          	jalr	-1852(ra) # 80000da8 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034ec:	0003c497          	auipc	s1,0x3c
    800034f0:	91c4b483          	ld	s1,-1764(s1) # 8003ee08 <bcache+0x82b8>
    800034f4:	0003c797          	auipc	a5,0x3c
    800034f8:	8c478793          	addi	a5,a5,-1852 # 8003edb8 <bcache+0x8268>
    800034fc:	02f48f63          	beq	s1,a5,8000353a <bread+0x70>
    80003500:	873e                	mv	a4,a5
    80003502:	a021                	j	8000350a <bread+0x40>
    80003504:	68a4                	ld	s1,80(s1)
    80003506:	02e48a63          	beq	s1,a4,8000353a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000350a:	449c                	lw	a5,8(s1)
    8000350c:	ff279ce3          	bne	a5,s2,80003504 <bread+0x3a>
    80003510:	44dc                	lw	a5,12(s1)
    80003512:	ff3799e3          	bne	a5,s3,80003504 <bread+0x3a>
      b->refcnt++;
    80003516:	40bc                	lw	a5,64(s1)
    80003518:	2785                	addiw	a5,a5,1
    8000351a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000351c:	00033517          	auipc	a0,0x33
    80003520:	63450513          	addi	a0,a0,1588 # 80036b50 <bcache>
    80003524:	ffffe097          	auipc	ra,0xffffe
    80003528:	938080e7          	jalr	-1736(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    8000352c:	01048513          	addi	a0,s1,16
    80003530:	00001097          	auipc	ra,0x1
    80003534:	472080e7          	jalr	1138(ra) # 800049a2 <acquiresleep>
      return b;
    80003538:	a8b9                	j	80003596 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000353a:	0003c497          	auipc	s1,0x3c
    8000353e:	8c64b483          	ld	s1,-1850(s1) # 8003ee00 <bcache+0x82b0>
    80003542:	0003c797          	auipc	a5,0x3c
    80003546:	87678793          	addi	a5,a5,-1930 # 8003edb8 <bcache+0x8268>
    8000354a:	00f48863          	beq	s1,a5,8000355a <bread+0x90>
    8000354e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003550:	40bc                	lw	a5,64(s1)
    80003552:	cf81                	beqz	a5,8000356a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003554:	64a4                	ld	s1,72(s1)
    80003556:	fee49de3          	bne	s1,a4,80003550 <bread+0x86>
  panic("bget: no buffers");
    8000355a:	00005517          	auipc	a0,0x5
    8000355e:	10e50513          	addi	a0,a0,270 # 80008668 <syscalls+0xe8>
    80003562:	ffffd097          	auipc	ra,0xffffd
    80003566:	fde080e7          	jalr	-34(ra) # 80000540 <panic>
      b->dev = dev;
    8000356a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000356e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003572:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003576:	4785                	li	a5,1
    80003578:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000357a:	00033517          	auipc	a0,0x33
    8000357e:	5d650513          	addi	a0,a0,1494 # 80036b50 <bcache>
    80003582:	ffffe097          	auipc	ra,0xffffe
    80003586:	8da080e7          	jalr	-1830(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    8000358a:	01048513          	addi	a0,s1,16
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	414080e7          	jalr	1044(ra) # 800049a2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003596:	409c                	lw	a5,0(s1)
    80003598:	cb89                	beqz	a5,800035aa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000359a:	8526                	mv	a0,s1
    8000359c:	70a2                	ld	ra,40(sp)
    8000359e:	7402                	ld	s0,32(sp)
    800035a0:	64e2                	ld	s1,24(sp)
    800035a2:	6942                	ld	s2,16(sp)
    800035a4:	69a2                	ld	s3,8(sp)
    800035a6:	6145                	addi	sp,sp,48
    800035a8:	8082                	ret
    virtio_disk_rw(b, 0);
    800035aa:	4581                	li	a1,0
    800035ac:	8526                	mv	a0,s1
    800035ae:	00003097          	auipc	ra,0x3
    800035b2:	fe4080e7          	jalr	-28(ra) # 80006592 <virtio_disk_rw>
    b->valid = 1;
    800035b6:	4785                	li	a5,1
    800035b8:	c09c                	sw	a5,0(s1)
  return b;
    800035ba:	b7c5                	j	8000359a <bread+0xd0>

00000000800035bc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035bc:	1101                	addi	sp,sp,-32
    800035be:	ec06                	sd	ra,24(sp)
    800035c0:	e822                	sd	s0,16(sp)
    800035c2:	e426                	sd	s1,8(sp)
    800035c4:	1000                	addi	s0,sp,32
    800035c6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035c8:	0541                	addi	a0,a0,16
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	472080e7          	jalr	1138(ra) # 80004a3c <holdingsleep>
    800035d2:	cd01                	beqz	a0,800035ea <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035d4:	4585                	li	a1,1
    800035d6:	8526                	mv	a0,s1
    800035d8:	00003097          	auipc	ra,0x3
    800035dc:	fba080e7          	jalr	-70(ra) # 80006592 <virtio_disk_rw>
}
    800035e0:	60e2                	ld	ra,24(sp)
    800035e2:	6442                	ld	s0,16(sp)
    800035e4:	64a2                	ld	s1,8(sp)
    800035e6:	6105                	addi	sp,sp,32
    800035e8:	8082                	ret
    panic("bwrite");
    800035ea:	00005517          	auipc	a0,0x5
    800035ee:	09650513          	addi	a0,a0,150 # 80008680 <syscalls+0x100>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	f4e080e7          	jalr	-178(ra) # 80000540 <panic>

00000000800035fa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035fa:	1101                	addi	sp,sp,-32
    800035fc:	ec06                	sd	ra,24(sp)
    800035fe:	e822                	sd	s0,16(sp)
    80003600:	e426                	sd	s1,8(sp)
    80003602:	e04a                	sd	s2,0(sp)
    80003604:	1000                	addi	s0,sp,32
    80003606:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003608:	01050913          	addi	s2,a0,16
    8000360c:	854a                	mv	a0,s2
    8000360e:	00001097          	auipc	ra,0x1
    80003612:	42e080e7          	jalr	1070(ra) # 80004a3c <holdingsleep>
    80003616:	c92d                	beqz	a0,80003688 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003618:	854a                	mv	a0,s2
    8000361a:	00001097          	auipc	ra,0x1
    8000361e:	3de080e7          	jalr	990(ra) # 800049f8 <releasesleep>

  acquire(&bcache.lock);
    80003622:	00033517          	auipc	a0,0x33
    80003626:	52e50513          	addi	a0,a0,1326 # 80036b50 <bcache>
    8000362a:	ffffd097          	auipc	ra,0xffffd
    8000362e:	77e080e7          	jalr	1918(ra) # 80000da8 <acquire>
  b->refcnt--;
    80003632:	40bc                	lw	a5,64(s1)
    80003634:	37fd                	addiw	a5,a5,-1
    80003636:	0007871b          	sext.w	a4,a5
    8000363a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000363c:	eb05                	bnez	a4,8000366c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000363e:	68bc                	ld	a5,80(s1)
    80003640:	64b8                	ld	a4,72(s1)
    80003642:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003644:	64bc                	ld	a5,72(s1)
    80003646:	68b8                	ld	a4,80(s1)
    80003648:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000364a:	0003b797          	auipc	a5,0x3b
    8000364e:	50678793          	addi	a5,a5,1286 # 8003eb50 <bcache+0x8000>
    80003652:	2b87b703          	ld	a4,696(a5)
    80003656:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003658:	0003b717          	auipc	a4,0x3b
    8000365c:	76070713          	addi	a4,a4,1888 # 8003edb8 <bcache+0x8268>
    80003660:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003662:	2b87b703          	ld	a4,696(a5)
    80003666:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003668:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000366c:	00033517          	auipc	a0,0x33
    80003670:	4e450513          	addi	a0,a0,1252 # 80036b50 <bcache>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	7e8080e7          	jalr	2024(ra) # 80000e5c <release>
}
    8000367c:	60e2                	ld	ra,24(sp)
    8000367e:	6442                	ld	s0,16(sp)
    80003680:	64a2                	ld	s1,8(sp)
    80003682:	6902                	ld	s2,0(sp)
    80003684:	6105                	addi	sp,sp,32
    80003686:	8082                	ret
    panic("brelse");
    80003688:	00005517          	auipc	a0,0x5
    8000368c:	00050513          	mv	a0,a0
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	eb0080e7          	jalr	-336(ra) # 80000540 <panic>

0000000080003698 <bpin>:

void
bpin(struct buf *b) {
    80003698:	1101                	addi	sp,sp,-32
    8000369a:	ec06                	sd	ra,24(sp)
    8000369c:	e822                	sd	s0,16(sp)
    8000369e:	e426                	sd	s1,8(sp)
    800036a0:	1000                	addi	s0,sp,32
    800036a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036a4:	00033517          	auipc	a0,0x33
    800036a8:	4ac50513          	addi	a0,a0,1196 # 80036b50 <bcache>
    800036ac:	ffffd097          	auipc	ra,0xffffd
    800036b0:	6fc080e7          	jalr	1788(ra) # 80000da8 <acquire>
  b->refcnt++;
    800036b4:	40bc                	lw	a5,64(s1)
    800036b6:	2785                	addiw	a5,a5,1
    800036b8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036ba:	00033517          	auipc	a0,0x33
    800036be:	49650513          	addi	a0,a0,1174 # 80036b50 <bcache>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	79a080e7          	jalr	1946(ra) # 80000e5c <release>
}
    800036ca:	60e2                	ld	ra,24(sp)
    800036cc:	6442                	ld	s0,16(sp)
    800036ce:	64a2                	ld	s1,8(sp)
    800036d0:	6105                	addi	sp,sp,32
    800036d2:	8082                	ret

00000000800036d4 <bunpin>:

void
bunpin(struct buf *b) {
    800036d4:	1101                	addi	sp,sp,-32
    800036d6:	ec06                	sd	ra,24(sp)
    800036d8:	e822                	sd	s0,16(sp)
    800036da:	e426                	sd	s1,8(sp)
    800036dc:	1000                	addi	s0,sp,32
    800036de:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036e0:	00033517          	auipc	a0,0x33
    800036e4:	47050513          	addi	a0,a0,1136 # 80036b50 <bcache>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	6c0080e7          	jalr	1728(ra) # 80000da8 <acquire>
  b->refcnt--;
    800036f0:	40bc                	lw	a5,64(s1)
    800036f2:	37fd                	addiw	a5,a5,-1
    800036f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036f6:	00033517          	auipc	a0,0x33
    800036fa:	45a50513          	addi	a0,a0,1114 # 80036b50 <bcache>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	75e080e7          	jalr	1886(ra) # 80000e5c <release>
}
    80003706:	60e2                	ld	ra,24(sp)
    80003708:	6442                	ld	s0,16(sp)
    8000370a:	64a2                	ld	s1,8(sp)
    8000370c:	6105                	addi	sp,sp,32
    8000370e:	8082                	ret

0000000080003710 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003710:	1101                	addi	sp,sp,-32
    80003712:	ec06                	sd	ra,24(sp)
    80003714:	e822                	sd	s0,16(sp)
    80003716:	e426                	sd	s1,8(sp)
    80003718:	e04a                	sd	s2,0(sp)
    8000371a:	1000                	addi	s0,sp,32
    8000371c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000371e:	00d5d59b          	srliw	a1,a1,0xd
    80003722:	0003c797          	auipc	a5,0x3c
    80003726:	b0a7a783          	lw	a5,-1270(a5) # 8003f22c <sb+0x1c>
    8000372a:	9dbd                	addw	a1,a1,a5
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	d9e080e7          	jalr	-610(ra) # 800034ca <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003734:	0074f713          	andi	a4,s1,7
    80003738:	4785                	li	a5,1
    8000373a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000373e:	14ce                	slli	s1,s1,0x33
    80003740:	90d9                	srli	s1,s1,0x36
    80003742:	00950733          	add	a4,a0,s1
    80003746:	05874703          	lbu	a4,88(a4)
    8000374a:	00e7f6b3          	and	a3,a5,a4
    8000374e:	c69d                	beqz	a3,8000377c <bfree+0x6c>
    80003750:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003752:	94aa                	add	s1,s1,a0
    80003754:	fff7c793          	not	a5,a5
    80003758:	8f7d                	and	a4,a4,a5
    8000375a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	126080e7          	jalr	294(ra) # 80004884 <log_write>
  brelse(bp);
    80003766:	854a                	mv	a0,s2
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	e92080e7          	jalr	-366(ra) # 800035fa <brelse>
}
    80003770:	60e2                	ld	ra,24(sp)
    80003772:	6442                	ld	s0,16(sp)
    80003774:	64a2                	ld	s1,8(sp)
    80003776:	6902                	ld	s2,0(sp)
    80003778:	6105                	addi	sp,sp,32
    8000377a:	8082                	ret
    panic("freeing free block");
    8000377c:	00005517          	auipc	a0,0x5
    80003780:	f1450513          	addi	a0,a0,-236 # 80008690 <syscalls+0x110>
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	dbc080e7          	jalr	-580(ra) # 80000540 <panic>

000000008000378c <balloc>:
{
    8000378c:	711d                	addi	sp,sp,-96
    8000378e:	ec86                	sd	ra,88(sp)
    80003790:	e8a2                	sd	s0,80(sp)
    80003792:	e4a6                	sd	s1,72(sp)
    80003794:	e0ca                	sd	s2,64(sp)
    80003796:	fc4e                	sd	s3,56(sp)
    80003798:	f852                	sd	s4,48(sp)
    8000379a:	f456                	sd	s5,40(sp)
    8000379c:	f05a                	sd	s6,32(sp)
    8000379e:	ec5e                	sd	s7,24(sp)
    800037a0:	e862                	sd	s8,16(sp)
    800037a2:	e466                	sd	s9,8(sp)
    800037a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037a6:	0003c797          	auipc	a5,0x3c
    800037aa:	a6e7a783          	lw	a5,-1426(a5) # 8003f214 <sb+0x4>
    800037ae:	cff5                	beqz	a5,800038aa <balloc+0x11e>
    800037b0:	8baa                	mv	s7,a0
    800037b2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037b4:	0003cb17          	auipc	s6,0x3c
    800037b8:	a5cb0b13          	addi	s6,s6,-1444 # 8003f210 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037bc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037be:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037c2:	6c89                	lui	s9,0x2
    800037c4:	a061                	j	8000384c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037c6:	97ca                	add	a5,a5,s2
    800037c8:	8e55                	or	a2,a2,a3
    800037ca:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800037ce:	854a                	mv	a0,s2
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	0b4080e7          	jalr	180(ra) # 80004884 <log_write>
        brelse(bp);
    800037d8:	854a                	mv	a0,s2
    800037da:	00000097          	auipc	ra,0x0
    800037de:	e20080e7          	jalr	-480(ra) # 800035fa <brelse>
  bp = bread(dev, bno);
    800037e2:	85a6                	mv	a1,s1
    800037e4:	855e                	mv	a0,s7
    800037e6:	00000097          	auipc	ra,0x0
    800037ea:	ce4080e7          	jalr	-796(ra) # 800034ca <bread>
    800037ee:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800037f0:	40000613          	li	a2,1024
    800037f4:	4581                	li	a1,0
    800037f6:	05850513          	addi	a0,a0,88
    800037fa:	ffffd097          	auipc	ra,0xffffd
    800037fe:	6aa080e7          	jalr	1706(ra) # 80000ea4 <memset>
  log_write(bp);
    80003802:	854a                	mv	a0,s2
    80003804:	00001097          	auipc	ra,0x1
    80003808:	080080e7          	jalr	128(ra) # 80004884 <log_write>
  brelse(bp);
    8000380c:	854a                	mv	a0,s2
    8000380e:	00000097          	auipc	ra,0x0
    80003812:	dec080e7          	jalr	-532(ra) # 800035fa <brelse>
}
    80003816:	8526                	mv	a0,s1
    80003818:	60e6                	ld	ra,88(sp)
    8000381a:	6446                	ld	s0,80(sp)
    8000381c:	64a6                	ld	s1,72(sp)
    8000381e:	6906                	ld	s2,64(sp)
    80003820:	79e2                	ld	s3,56(sp)
    80003822:	7a42                	ld	s4,48(sp)
    80003824:	7aa2                	ld	s5,40(sp)
    80003826:	7b02                	ld	s6,32(sp)
    80003828:	6be2                	ld	s7,24(sp)
    8000382a:	6c42                	ld	s8,16(sp)
    8000382c:	6ca2                	ld	s9,8(sp)
    8000382e:	6125                	addi	sp,sp,96
    80003830:	8082                	ret
    brelse(bp);
    80003832:	854a                	mv	a0,s2
    80003834:	00000097          	auipc	ra,0x0
    80003838:	dc6080e7          	jalr	-570(ra) # 800035fa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000383c:	015c87bb          	addw	a5,s9,s5
    80003840:	00078a9b          	sext.w	s5,a5
    80003844:	004b2703          	lw	a4,4(s6)
    80003848:	06eaf163          	bgeu	s5,a4,800038aa <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000384c:	41fad79b          	sraiw	a5,s5,0x1f
    80003850:	0137d79b          	srliw	a5,a5,0x13
    80003854:	015787bb          	addw	a5,a5,s5
    80003858:	40d7d79b          	sraiw	a5,a5,0xd
    8000385c:	01cb2583          	lw	a1,28(s6)
    80003860:	9dbd                	addw	a1,a1,a5
    80003862:	855e                	mv	a0,s7
    80003864:	00000097          	auipc	ra,0x0
    80003868:	c66080e7          	jalr	-922(ra) # 800034ca <bread>
    8000386c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000386e:	004b2503          	lw	a0,4(s6)
    80003872:	000a849b          	sext.w	s1,s5
    80003876:	8762                	mv	a4,s8
    80003878:	faa4fde3          	bgeu	s1,a0,80003832 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000387c:	00777693          	andi	a3,a4,7
    80003880:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003884:	41f7579b          	sraiw	a5,a4,0x1f
    80003888:	01d7d79b          	srliw	a5,a5,0x1d
    8000388c:	9fb9                	addw	a5,a5,a4
    8000388e:	4037d79b          	sraiw	a5,a5,0x3
    80003892:	00f90633          	add	a2,s2,a5
    80003896:	05864603          	lbu	a2,88(a2)
    8000389a:	00c6f5b3          	and	a1,a3,a2
    8000389e:	d585                	beqz	a1,800037c6 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a0:	2705                	addiw	a4,a4,1
    800038a2:	2485                	addiw	s1,s1,1
    800038a4:	fd471ae3          	bne	a4,s4,80003878 <balloc+0xec>
    800038a8:	b769                	j	80003832 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800038aa:	00005517          	auipc	a0,0x5
    800038ae:	dfe50513          	addi	a0,a0,-514 # 800086a8 <syscalls+0x128>
    800038b2:	ffffd097          	auipc	ra,0xffffd
    800038b6:	cea080e7          	jalr	-790(ra) # 8000059c <printf>
  return 0;
    800038ba:	4481                	li	s1,0
    800038bc:	bfa9                	j	80003816 <balloc+0x8a>

00000000800038be <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800038be:	7179                	addi	sp,sp,-48
    800038c0:	f406                	sd	ra,40(sp)
    800038c2:	f022                	sd	s0,32(sp)
    800038c4:	ec26                	sd	s1,24(sp)
    800038c6:	e84a                	sd	s2,16(sp)
    800038c8:	e44e                	sd	s3,8(sp)
    800038ca:	e052                	sd	s4,0(sp)
    800038cc:	1800                	addi	s0,sp,48
    800038ce:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038d0:	47ad                	li	a5,11
    800038d2:	02b7e863          	bltu	a5,a1,80003902 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800038d6:	02059793          	slli	a5,a1,0x20
    800038da:	01e7d593          	srli	a1,a5,0x1e
    800038de:	00b504b3          	add	s1,a0,a1
    800038e2:	0504a903          	lw	s2,80(s1)
    800038e6:	06091e63          	bnez	s2,80003962 <bmap+0xa4>
      addr = balloc(ip->dev);
    800038ea:	4108                	lw	a0,0(a0)
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	ea0080e7          	jalr	-352(ra) # 8000378c <balloc>
    800038f4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038f8:	06090563          	beqz	s2,80003962 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800038fc:	0524a823          	sw	s2,80(s1)
    80003900:	a08d                	j	80003962 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003902:	ff45849b          	addiw	s1,a1,-12
    80003906:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000390a:	0ff00793          	li	a5,255
    8000390e:	08e7e563          	bltu	a5,a4,80003998 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003912:	08052903          	lw	s2,128(a0)
    80003916:	00091d63          	bnez	s2,80003930 <bmap+0x72>
      addr = balloc(ip->dev);
    8000391a:	4108                	lw	a0,0(a0)
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	e70080e7          	jalr	-400(ra) # 8000378c <balloc>
    80003924:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003928:	02090d63          	beqz	s2,80003962 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000392c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003930:	85ca                	mv	a1,s2
    80003932:	0009a503          	lw	a0,0(s3)
    80003936:	00000097          	auipc	ra,0x0
    8000393a:	b94080e7          	jalr	-1132(ra) # 800034ca <bread>
    8000393e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003940:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003944:	02049713          	slli	a4,s1,0x20
    80003948:	01e75593          	srli	a1,a4,0x1e
    8000394c:	00b784b3          	add	s1,a5,a1
    80003950:	0004a903          	lw	s2,0(s1)
    80003954:	02090063          	beqz	s2,80003974 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003958:	8552                	mv	a0,s4
    8000395a:	00000097          	auipc	ra,0x0
    8000395e:	ca0080e7          	jalr	-864(ra) # 800035fa <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003962:	854a                	mv	a0,s2
    80003964:	70a2                	ld	ra,40(sp)
    80003966:	7402                	ld	s0,32(sp)
    80003968:	64e2                	ld	s1,24(sp)
    8000396a:	6942                	ld	s2,16(sp)
    8000396c:	69a2                	ld	s3,8(sp)
    8000396e:	6a02                	ld	s4,0(sp)
    80003970:	6145                	addi	sp,sp,48
    80003972:	8082                	ret
      addr = balloc(ip->dev);
    80003974:	0009a503          	lw	a0,0(s3)
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	e14080e7          	jalr	-492(ra) # 8000378c <balloc>
    80003980:	0005091b          	sext.w	s2,a0
      if(addr){
    80003984:	fc090ae3          	beqz	s2,80003958 <bmap+0x9a>
        a[bn] = addr;
    80003988:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000398c:	8552                	mv	a0,s4
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	ef6080e7          	jalr	-266(ra) # 80004884 <log_write>
    80003996:	b7c9                	j	80003958 <bmap+0x9a>
  panic("bmap: out of range");
    80003998:	00005517          	auipc	a0,0x5
    8000399c:	d2850513          	addi	a0,a0,-728 # 800086c0 <syscalls+0x140>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	ba0080e7          	jalr	-1120(ra) # 80000540 <panic>

00000000800039a8 <iget>:
{
    800039a8:	7179                	addi	sp,sp,-48
    800039aa:	f406                	sd	ra,40(sp)
    800039ac:	f022                	sd	s0,32(sp)
    800039ae:	ec26                	sd	s1,24(sp)
    800039b0:	e84a                	sd	s2,16(sp)
    800039b2:	e44e                	sd	s3,8(sp)
    800039b4:	e052                	sd	s4,0(sp)
    800039b6:	1800                	addi	s0,sp,48
    800039b8:	89aa                	mv	s3,a0
    800039ba:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039bc:	0003c517          	auipc	a0,0x3c
    800039c0:	87450513          	addi	a0,a0,-1932 # 8003f230 <itable>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	3e4080e7          	jalr	996(ra) # 80000da8 <acquire>
  empty = 0;
    800039cc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039ce:	0003c497          	auipc	s1,0x3c
    800039d2:	87a48493          	addi	s1,s1,-1926 # 8003f248 <itable+0x18>
    800039d6:	0003d697          	auipc	a3,0x3d
    800039da:	30268693          	addi	a3,a3,770 # 80040cd8 <log>
    800039de:	a039                	j	800039ec <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039e0:	02090b63          	beqz	s2,80003a16 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039e4:	08848493          	addi	s1,s1,136
    800039e8:	02d48a63          	beq	s1,a3,80003a1c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039ec:	449c                	lw	a5,8(s1)
    800039ee:	fef059e3          	blez	a5,800039e0 <iget+0x38>
    800039f2:	4098                	lw	a4,0(s1)
    800039f4:	ff3716e3          	bne	a4,s3,800039e0 <iget+0x38>
    800039f8:	40d8                	lw	a4,4(s1)
    800039fa:	ff4713e3          	bne	a4,s4,800039e0 <iget+0x38>
      ip->ref++;
    800039fe:	2785                	addiw	a5,a5,1
    80003a00:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a02:	0003c517          	auipc	a0,0x3c
    80003a06:	82e50513          	addi	a0,a0,-2002 # 8003f230 <itable>
    80003a0a:	ffffd097          	auipc	ra,0xffffd
    80003a0e:	452080e7          	jalr	1106(ra) # 80000e5c <release>
      return ip;
    80003a12:	8926                	mv	s2,s1
    80003a14:	a03d                	j	80003a42 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a16:	f7f9                	bnez	a5,800039e4 <iget+0x3c>
    80003a18:	8926                	mv	s2,s1
    80003a1a:	b7e9                	j	800039e4 <iget+0x3c>
  if(empty == 0)
    80003a1c:	02090c63          	beqz	s2,80003a54 <iget+0xac>
  ip->dev = dev;
    80003a20:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a24:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a28:	4785                	li	a5,1
    80003a2a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a2e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a32:	0003b517          	auipc	a0,0x3b
    80003a36:	7fe50513          	addi	a0,a0,2046 # 8003f230 <itable>
    80003a3a:	ffffd097          	auipc	ra,0xffffd
    80003a3e:	422080e7          	jalr	1058(ra) # 80000e5c <release>
}
    80003a42:	854a                	mv	a0,s2
    80003a44:	70a2                	ld	ra,40(sp)
    80003a46:	7402                	ld	s0,32(sp)
    80003a48:	64e2                	ld	s1,24(sp)
    80003a4a:	6942                	ld	s2,16(sp)
    80003a4c:	69a2                	ld	s3,8(sp)
    80003a4e:	6a02                	ld	s4,0(sp)
    80003a50:	6145                	addi	sp,sp,48
    80003a52:	8082                	ret
    panic("iget: no inodes");
    80003a54:	00005517          	auipc	a0,0x5
    80003a58:	c8450513          	addi	a0,a0,-892 # 800086d8 <syscalls+0x158>
    80003a5c:	ffffd097          	auipc	ra,0xffffd
    80003a60:	ae4080e7          	jalr	-1308(ra) # 80000540 <panic>

0000000080003a64 <fsinit>:
fsinit(int dev) {
    80003a64:	7179                	addi	sp,sp,-48
    80003a66:	f406                	sd	ra,40(sp)
    80003a68:	f022                	sd	s0,32(sp)
    80003a6a:	ec26                	sd	s1,24(sp)
    80003a6c:	e84a                	sd	s2,16(sp)
    80003a6e:	e44e                	sd	s3,8(sp)
    80003a70:	1800                	addi	s0,sp,48
    80003a72:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a74:	4585                	li	a1,1
    80003a76:	00000097          	auipc	ra,0x0
    80003a7a:	a54080e7          	jalr	-1452(ra) # 800034ca <bread>
    80003a7e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a80:	0003b997          	auipc	s3,0x3b
    80003a84:	79098993          	addi	s3,s3,1936 # 8003f210 <sb>
    80003a88:	02000613          	li	a2,32
    80003a8c:	05850593          	addi	a1,a0,88
    80003a90:	854e                	mv	a0,s3
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	46e080e7          	jalr	1134(ra) # 80000f00 <memmove>
  brelse(bp);
    80003a9a:	8526                	mv	a0,s1
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	b5e080e7          	jalr	-1186(ra) # 800035fa <brelse>
  if(sb.magic != FSMAGIC)
    80003aa4:	0009a703          	lw	a4,0(s3)
    80003aa8:	102037b7          	lui	a5,0x10203
    80003aac:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ab0:	02f71263          	bne	a4,a5,80003ad4 <fsinit+0x70>
  initlog(dev, &sb);
    80003ab4:	0003b597          	auipc	a1,0x3b
    80003ab8:	75c58593          	addi	a1,a1,1884 # 8003f210 <sb>
    80003abc:	854a                	mv	a0,s2
    80003abe:	00001097          	auipc	ra,0x1
    80003ac2:	b4a080e7          	jalr	-1206(ra) # 80004608 <initlog>
}
    80003ac6:	70a2                	ld	ra,40(sp)
    80003ac8:	7402                	ld	s0,32(sp)
    80003aca:	64e2                	ld	s1,24(sp)
    80003acc:	6942                	ld	s2,16(sp)
    80003ace:	69a2                	ld	s3,8(sp)
    80003ad0:	6145                	addi	sp,sp,48
    80003ad2:	8082                	ret
    panic("invalid file system");
    80003ad4:	00005517          	auipc	a0,0x5
    80003ad8:	c1450513          	addi	a0,a0,-1004 # 800086e8 <syscalls+0x168>
    80003adc:	ffffd097          	auipc	ra,0xffffd
    80003ae0:	a64080e7          	jalr	-1436(ra) # 80000540 <panic>

0000000080003ae4 <iinit>:
{
    80003ae4:	7179                	addi	sp,sp,-48
    80003ae6:	f406                	sd	ra,40(sp)
    80003ae8:	f022                	sd	s0,32(sp)
    80003aea:	ec26                	sd	s1,24(sp)
    80003aec:	e84a                	sd	s2,16(sp)
    80003aee:	e44e                	sd	s3,8(sp)
    80003af0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003af2:	00005597          	auipc	a1,0x5
    80003af6:	c0e58593          	addi	a1,a1,-1010 # 80008700 <syscalls+0x180>
    80003afa:	0003b517          	auipc	a0,0x3b
    80003afe:	73650513          	addi	a0,a0,1846 # 8003f230 <itable>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	216080e7          	jalr	534(ra) # 80000d18 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b0a:	0003b497          	auipc	s1,0x3b
    80003b0e:	74e48493          	addi	s1,s1,1870 # 8003f258 <itable+0x28>
    80003b12:	0003d997          	auipc	s3,0x3d
    80003b16:	1d698993          	addi	s3,s3,470 # 80040ce8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b1a:	00005917          	auipc	s2,0x5
    80003b1e:	bee90913          	addi	s2,s2,-1042 # 80008708 <syscalls+0x188>
    80003b22:	85ca                	mv	a1,s2
    80003b24:	8526                	mv	a0,s1
    80003b26:	00001097          	auipc	ra,0x1
    80003b2a:	e42080e7          	jalr	-446(ra) # 80004968 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b2e:	08848493          	addi	s1,s1,136
    80003b32:	ff3498e3          	bne	s1,s3,80003b22 <iinit+0x3e>
}
    80003b36:	70a2                	ld	ra,40(sp)
    80003b38:	7402                	ld	s0,32(sp)
    80003b3a:	64e2                	ld	s1,24(sp)
    80003b3c:	6942                	ld	s2,16(sp)
    80003b3e:	69a2                	ld	s3,8(sp)
    80003b40:	6145                	addi	sp,sp,48
    80003b42:	8082                	ret

0000000080003b44 <ialloc>:
{
    80003b44:	715d                	addi	sp,sp,-80
    80003b46:	e486                	sd	ra,72(sp)
    80003b48:	e0a2                	sd	s0,64(sp)
    80003b4a:	fc26                	sd	s1,56(sp)
    80003b4c:	f84a                	sd	s2,48(sp)
    80003b4e:	f44e                	sd	s3,40(sp)
    80003b50:	f052                	sd	s4,32(sp)
    80003b52:	ec56                	sd	s5,24(sp)
    80003b54:	e85a                	sd	s6,16(sp)
    80003b56:	e45e                	sd	s7,8(sp)
    80003b58:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b5a:	0003b717          	auipc	a4,0x3b
    80003b5e:	6c272703          	lw	a4,1730(a4) # 8003f21c <sb+0xc>
    80003b62:	4785                	li	a5,1
    80003b64:	04e7fa63          	bgeu	a5,a4,80003bb8 <ialloc+0x74>
    80003b68:	8aaa                	mv	s5,a0
    80003b6a:	8bae                	mv	s7,a1
    80003b6c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b6e:	0003ba17          	auipc	s4,0x3b
    80003b72:	6a2a0a13          	addi	s4,s4,1698 # 8003f210 <sb>
    80003b76:	00048b1b          	sext.w	s6,s1
    80003b7a:	0044d593          	srli	a1,s1,0x4
    80003b7e:	018a2783          	lw	a5,24(s4)
    80003b82:	9dbd                	addw	a1,a1,a5
    80003b84:	8556                	mv	a0,s5
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	944080e7          	jalr	-1724(ra) # 800034ca <bread>
    80003b8e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b90:	05850993          	addi	s3,a0,88
    80003b94:	00f4f793          	andi	a5,s1,15
    80003b98:	079a                	slli	a5,a5,0x6
    80003b9a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b9c:	00099783          	lh	a5,0(s3)
    80003ba0:	c3a1                	beqz	a5,80003be0 <ialloc+0x9c>
    brelse(bp);
    80003ba2:	00000097          	auipc	ra,0x0
    80003ba6:	a58080e7          	jalr	-1448(ra) # 800035fa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003baa:	0485                	addi	s1,s1,1
    80003bac:	00ca2703          	lw	a4,12(s4)
    80003bb0:	0004879b          	sext.w	a5,s1
    80003bb4:	fce7e1e3          	bltu	a5,a4,80003b76 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003bb8:	00005517          	auipc	a0,0x5
    80003bbc:	b5850513          	addi	a0,a0,-1192 # 80008710 <syscalls+0x190>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	9dc080e7          	jalr	-1572(ra) # 8000059c <printf>
  return 0;
    80003bc8:	4501                	li	a0,0
}
    80003bca:	60a6                	ld	ra,72(sp)
    80003bcc:	6406                	ld	s0,64(sp)
    80003bce:	74e2                	ld	s1,56(sp)
    80003bd0:	7942                	ld	s2,48(sp)
    80003bd2:	79a2                	ld	s3,40(sp)
    80003bd4:	7a02                	ld	s4,32(sp)
    80003bd6:	6ae2                	ld	s5,24(sp)
    80003bd8:	6b42                	ld	s6,16(sp)
    80003bda:	6ba2                	ld	s7,8(sp)
    80003bdc:	6161                	addi	sp,sp,80
    80003bde:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003be0:	04000613          	li	a2,64
    80003be4:	4581                	li	a1,0
    80003be6:	854e                	mv	a0,s3
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	2bc080e7          	jalr	700(ra) # 80000ea4 <memset>
      dip->type = type;
    80003bf0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bf4:	854a                	mv	a0,s2
    80003bf6:	00001097          	auipc	ra,0x1
    80003bfa:	c8e080e7          	jalr	-882(ra) # 80004884 <log_write>
      brelse(bp);
    80003bfe:	854a                	mv	a0,s2
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	9fa080e7          	jalr	-1542(ra) # 800035fa <brelse>
      return iget(dev, inum);
    80003c08:	85da                	mv	a1,s6
    80003c0a:	8556                	mv	a0,s5
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	d9c080e7          	jalr	-612(ra) # 800039a8 <iget>
    80003c14:	bf5d                	j	80003bca <ialloc+0x86>

0000000080003c16 <iupdate>:
{
    80003c16:	1101                	addi	sp,sp,-32
    80003c18:	ec06                	sd	ra,24(sp)
    80003c1a:	e822                	sd	s0,16(sp)
    80003c1c:	e426                	sd	s1,8(sp)
    80003c1e:	e04a                	sd	s2,0(sp)
    80003c20:	1000                	addi	s0,sp,32
    80003c22:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c24:	415c                	lw	a5,4(a0)
    80003c26:	0047d79b          	srliw	a5,a5,0x4
    80003c2a:	0003b597          	auipc	a1,0x3b
    80003c2e:	5fe5a583          	lw	a1,1534(a1) # 8003f228 <sb+0x18>
    80003c32:	9dbd                	addw	a1,a1,a5
    80003c34:	4108                	lw	a0,0(a0)
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	894080e7          	jalr	-1900(ra) # 800034ca <bread>
    80003c3e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c40:	05850793          	addi	a5,a0,88
    80003c44:	40d8                	lw	a4,4(s1)
    80003c46:	8b3d                	andi	a4,a4,15
    80003c48:	071a                	slli	a4,a4,0x6
    80003c4a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003c4c:	04449703          	lh	a4,68(s1)
    80003c50:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003c54:	04649703          	lh	a4,70(s1)
    80003c58:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003c5c:	04849703          	lh	a4,72(s1)
    80003c60:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003c64:	04a49703          	lh	a4,74(s1)
    80003c68:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003c6c:	44f8                	lw	a4,76(s1)
    80003c6e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c70:	03400613          	li	a2,52
    80003c74:	05048593          	addi	a1,s1,80
    80003c78:	00c78513          	addi	a0,a5,12
    80003c7c:	ffffd097          	auipc	ra,0xffffd
    80003c80:	284080e7          	jalr	644(ra) # 80000f00 <memmove>
  log_write(bp);
    80003c84:	854a                	mv	a0,s2
    80003c86:	00001097          	auipc	ra,0x1
    80003c8a:	bfe080e7          	jalr	-1026(ra) # 80004884 <log_write>
  brelse(bp);
    80003c8e:	854a                	mv	a0,s2
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	96a080e7          	jalr	-1686(ra) # 800035fa <brelse>
}
    80003c98:	60e2                	ld	ra,24(sp)
    80003c9a:	6442                	ld	s0,16(sp)
    80003c9c:	64a2                	ld	s1,8(sp)
    80003c9e:	6902                	ld	s2,0(sp)
    80003ca0:	6105                	addi	sp,sp,32
    80003ca2:	8082                	ret

0000000080003ca4 <idup>:
{
    80003ca4:	1101                	addi	sp,sp,-32
    80003ca6:	ec06                	sd	ra,24(sp)
    80003ca8:	e822                	sd	s0,16(sp)
    80003caa:	e426                	sd	s1,8(sp)
    80003cac:	1000                	addi	s0,sp,32
    80003cae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cb0:	0003b517          	auipc	a0,0x3b
    80003cb4:	58050513          	addi	a0,a0,1408 # 8003f230 <itable>
    80003cb8:	ffffd097          	auipc	ra,0xffffd
    80003cbc:	0f0080e7          	jalr	240(ra) # 80000da8 <acquire>
  ip->ref++;
    80003cc0:	449c                	lw	a5,8(s1)
    80003cc2:	2785                	addiw	a5,a5,1
    80003cc4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cc6:	0003b517          	auipc	a0,0x3b
    80003cca:	56a50513          	addi	a0,a0,1386 # 8003f230 <itable>
    80003cce:	ffffd097          	auipc	ra,0xffffd
    80003cd2:	18e080e7          	jalr	398(ra) # 80000e5c <release>
}
    80003cd6:	8526                	mv	a0,s1
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	64a2                	ld	s1,8(sp)
    80003cde:	6105                	addi	sp,sp,32
    80003ce0:	8082                	ret

0000000080003ce2 <ilock>:
{
    80003ce2:	1101                	addi	sp,sp,-32
    80003ce4:	ec06                	sd	ra,24(sp)
    80003ce6:	e822                	sd	s0,16(sp)
    80003ce8:	e426                	sd	s1,8(sp)
    80003cea:	e04a                	sd	s2,0(sp)
    80003cec:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003cee:	c115                	beqz	a0,80003d12 <ilock+0x30>
    80003cf0:	84aa                	mv	s1,a0
    80003cf2:	451c                	lw	a5,8(a0)
    80003cf4:	00f05f63          	blez	a5,80003d12 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003cf8:	0541                	addi	a0,a0,16
    80003cfa:	00001097          	auipc	ra,0x1
    80003cfe:	ca8080e7          	jalr	-856(ra) # 800049a2 <acquiresleep>
  if(ip->valid == 0){
    80003d02:	40bc                	lw	a5,64(s1)
    80003d04:	cf99                	beqz	a5,80003d22 <ilock+0x40>
}
    80003d06:	60e2                	ld	ra,24(sp)
    80003d08:	6442                	ld	s0,16(sp)
    80003d0a:	64a2                	ld	s1,8(sp)
    80003d0c:	6902                	ld	s2,0(sp)
    80003d0e:	6105                	addi	sp,sp,32
    80003d10:	8082                	ret
    panic("ilock");
    80003d12:	00005517          	auipc	a0,0x5
    80003d16:	a1650513          	addi	a0,a0,-1514 # 80008728 <syscalls+0x1a8>
    80003d1a:	ffffd097          	auipc	ra,0xffffd
    80003d1e:	826080e7          	jalr	-2010(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d22:	40dc                	lw	a5,4(s1)
    80003d24:	0047d79b          	srliw	a5,a5,0x4
    80003d28:	0003b597          	auipc	a1,0x3b
    80003d2c:	5005a583          	lw	a1,1280(a1) # 8003f228 <sb+0x18>
    80003d30:	9dbd                	addw	a1,a1,a5
    80003d32:	4088                	lw	a0,0(s1)
    80003d34:	fffff097          	auipc	ra,0xfffff
    80003d38:	796080e7          	jalr	1942(ra) # 800034ca <bread>
    80003d3c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d3e:	05850593          	addi	a1,a0,88
    80003d42:	40dc                	lw	a5,4(s1)
    80003d44:	8bbd                	andi	a5,a5,15
    80003d46:	079a                	slli	a5,a5,0x6
    80003d48:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d4a:	00059783          	lh	a5,0(a1)
    80003d4e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d52:	00259783          	lh	a5,2(a1)
    80003d56:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d5a:	00459783          	lh	a5,4(a1)
    80003d5e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d62:	00659783          	lh	a5,6(a1)
    80003d66:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d6a:	459c                	lw	a5,8(a1)
    80003d6c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d6e:	03400613          	li	a2,52
    80003d72:	05b1                	addi	a1,a1,12
    80003d74:	05048513          	addi	a0,s1,80
    80003d78:	ffffd097          	auipc	ra,0xffffd
    80003d7c:	188080e7          	jalr	392(ra) # 80000f00 <memmove>
    brelse(bp);
    80003d80:	854a                	mv	a0,s2
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	878080e7          	jalr	-1928(ra) # 800035fa <brelse>
    ip->valid = 1;
    80003d8a:	4785                	li	a5,1
    80003d8c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d8e:	04449783          	lh	a5,68(s1)
    80003d92:	fbb5                	bnez	a5,80003d06 <ilock+0x24>
      panic("ilock: no type");
    80003d94:	00005517          	auipc	a0,0x5
    80003d98:	99c50513          	addi	a0,a0,-1636 # 80008730 <syscalls+0x1b0>
    80003d9c:	ffffc097          	auipc	ra,0xffffc
    80003da0:	7a4080e7          	jalr	1956(ra) # 80000540 <panic>

0000000080003da4 <iunlock>:
{
    80003da4:	1101                	addi	sp,sp,-32
    80003da6:	ec06                	sd	ra,24(sp)
    80003da8:	e822                	sd	s0,16(sp)
    80003daa:	e426                	sd	s1,8(sp)
    80003dac:	e04a                	sd	s2,0(sp)
    80003dae:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003db0:	c905                	beqz	a0,80003de0 <iunlock+0x3c>
    80003db2:	84aa                	mv	s1,a0
    80003db4:	01050913          	addi	s2,a0,16
    80003db8:	854a                	mv	a0,s2
    80003dba:	00001097          	auipc	ra,0x1
    80003dbe:	c82080e7          	jalr	-894(ra) # 80004a3c <holdingsleep>
    80003dc2:	cd19                	beqz	a0,80003de0 <iunlock+0x3c>
    80003dc4:	449c                	lw	a5,8(s1)
    80003dc6:	00f05d63          	blez	a5,80003de0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003dca:	854a                	mv	a0,s2
    80003dcc:	00001097          	auipc	ra,0x1
    80003dd0:	c2c080e7          	jalr	-980(ra) # 800049f8 <releasesleep>
}
    80003dd4:	60e2                	ld	ra,24(sp)
    80003dd6:	6442                	ld	s0,16(sp)
    80003dd8:	64a2                	ld	s1,8(sp)
    80003dda:	6902                	ld	s2,0(sp)
    80003ddc:	6105                	addi	sp,sp,32
    80003dde:	8082                	ret
    panic("iunlock");
    80003de0:	00005517          	auipc	a0,0x5
    80003de4:	96050513          	addi	a0,a0,-1696 # 80008740 <syscalls+0x1c0>
    80003de8:	ffffc097          	auipc	ra,0xffffc
    80003dec:	758080e7          	jalr	1880(ra) # 80000540 <panic>

0000000080003df0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003df0:	7179                	addi	sp,sp,-48
    80003df2:	f406                	sd	ra,40(sp)
    80003df4:	f022                	sd	s0,32(sp)
    80003df6:	ec26                	sd	s1,24(sp)
    80003df8:	e84a                	sd	s2,16(sp)
    80003dfa:	e44e                	sd	s3,8(sp)
    80003dfc:	e052                	sd	s4,0(sp)
    80003dfe:	1800                	addi	s0,sp,48
    80003e00:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e02:	05050493          	addi	s1,a0,80
    80003e06:	08050913          	addi	s2,a0,128
    80003e0a:	a021                	j	80003e12 <itrunc+0x22>
    80003e0c:	0491                	addi	s1,s1,4
    80003e0e:	01248d63          	beq	s1,s2,80003e28 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e12:	408c                	lw	a1,0(s1)
    80003e14:	dde5                	beqz	a1,80003e0c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e16:	0009a503          	lw	a0,0(s3)
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	8f6080e7          	jalr	-1802(ra) # 80003710 <bfree>
      ip->addrs[i] = 0;
    80003e22:	0004a023          	sw	zero,0(s1)
    80003e26:	b7dd                	j	80003e0c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e28:	0809a583          	lw	a1,128(s3)
    80003e2c:	e185                	bnez	a1,80003e4c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e2e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e32:	854e                	mv	a0,s3
    80003e34:	00000097          	auipc	ra,0x0
    80003e38:	de2080e7          	jalr	-542(ra) # 80003c16 <iupdate>
}
    80003e3c:	70a2                	ld	ra,40(sp)
    80003e3e:	7402                	ld	s0,32(sp)
    80003e40:	64e2                	ld	s1,24(sp)
    80003e42:	6942                	ld	s2,16(sp)
    80003e44:	69a2                	ld	s3,8(sp)
    80003e46:	6a02                	ld	s4,0(sp)
    80003e48:	6145                	addi	sp,sp,48
    80003e4a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e4c:	0009a503          	lw	a0,0(s3)
    80003e50:	fffff097          	auipc	ra,0xfffff
    80003e54:	67a080e7          	jalr	1658(ra) # 800034ca <bread>
    80003e58:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e5a:	05850493          	addi	s1,a0,88
    80003e5e:	45850913          	addi	s2,a0,1112
    80003e62:	a021                	j	80003e6a <itrunc+0x7a>
    80003e64:	0491                	addi	s1,s1,4
    80003e66:	01248b63          	beq	s1,s2,80003e7c <itrunc+0x8c>
      if(a[j])
    80003e6a:	408c                	lw	a1,0(s1)
    80003e6c:	dde5                	beqz	a1,80003e64 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e6e:	0009a503          	lw	a0,0(s3)
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	89e080e7          	jalr	-1890(ra) # 80003710 <bfree>
    80003e7a:	b7ed                	j	80003e64 <itrunc+0x74>
    brelse(bp);
    80003e7c:	8552                	mv	a0,s4
    80003e7e:	fffff097          	auipc	ra,0xfffff
    80003e82:	77c080e7          	jalr	1916(ra) # 800035fa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e86:	0809a583          	lw	a1,128(s3)
    80003e8a:	0009a503          	lw	a0,0(s3)
    80003e8e:	00000097          	auipc	ra,0x0
    80003e92:	882080e7          	jalr	-1918(ra) # 80003710 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e96:	0809a023          	sw	zero,128(s3)
    80003e9a:	bf51                	j	80003e2e <itrunc+0x3e>

0000000080003e9c <iput>:
{
    80003e9c:	1101                	addi	sp,sp,-32
    80003e9e:	ec06                	sd	ra,24(sp)
    80003ea0:	e822                	sd	s0,16(sp)
    80003ea2:	e426                	sd	s1,8(sp)
    80003ea4:	e04a                	sd	s2,0(sp)
    80003ea6:	1000                	addi	s0,sp,32
    80003ea8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003eaa:	0003b517          	auipc	a0,0x3b
    80003eae:	38650513          	addi	a0,a0,902 # 8003f230 <itable>
    80003eb2:	ffffd097          	auipc	ra,0xffffd
    80003eb6:	ef6080e7          	jalr	-266(ra) # 80000da8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eba:	4498                	lw	a4,8(s1)
    80003ebc:	4785                	li	a5,1
    80003ebe:	02f70363          	beq	a4,a5,80003ee4 <iput+0x48>
  ip->ref--;
    80003ec2:	449c                	lw	a5,8(s1)
    80003ec4:	37fd                	addiw	a5,a5,-1
    80003ec6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ec8:	0003b517          	auipc	a0,0x3b
    80003ecc:	36850513          	addi	a0,a0,872 # 8003f230 <itable>
    80003ed0:	ffffd097          	auipc	ra,0xffffd
    80003ed4:	f8c080e7          	jalr	-116(ra) # 80000e5c <release>
}
    80003ed8:	60e2                	ld	ra,24(sp)
    80003eda:	6442                	ld	s0,16(sp)
    80003edc:	64a2                	ld	s1,8(sp)
    80003ede:	6902                	ld	s2,0(sp)
    80003ee0:	6105                	addi	sp,sp,32
    80003ee2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ee4:	40bc                	lw	a5,64(s1)
    80003ee6:	dff1                	beqz	a5,80003ec2 <iput+0x26>
    80003ee8:	04a49783          	lh	a5,74(s1)
    80003eec:	fbf9                	bnez	a5,80003ec2 <iput+0x26>
    acquiresleep(&ip->lock);
    80003eee:	01048913          	addi	s2,s1,16
    80003ef2:	854a                	mv	a0,s2
    80003ef4:	00001097          	auipc	ra,0x1
    80003ef8:	aae080e7          	jalr	-1362(ra) # 800049a2 <acquiresleep>
    release(&itable.lock);
    80003efc:	0003b517          	auipc	a0,0x3b
    80003f00:	33450513          	addi	a0,a0,820 # 8003f230 <itable>
    80003f04:	ffffd097          	auipc	ra,0xffffd
    80003f08:	f58080e7          	jalr	-168(ra) # 80000e5c <release>
    itrunc(ip);
    80003f0c:	8526                	mv	a0,s1
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	ee2080e7          	jalr	-286(ra) # 80003df0 <itrunc>
    ip->type = 0;
    80003f16:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f1a:	8526                	mv	a0,s1
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	cfa080e7          	jalr	-774(ra) # 80003c16 <iupdate>
    ip->valid = 0;
    80003f24:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f28:	854a                	mv	a0,s2
    80003f2a:	00001097          	auipc	ra,0x1
    80003f2e:	ace080e7          	jalr	-1330(ra) # 800049f8 <releasesleep>
    acquire(&itable.lock);
    80003f32:	0003b517          	auipc	a0,0x3b
    80003f36:	2fe50513          	addi	a0,a0,766 # 8003f230 <itable>
    80003f3a:	ffffd097          	auipc	ra,0xffffd
    80003f3e:	e6e080e7          	jalr	-402(ra) # 80000da8 <acquire>
    80003f42:	b741                	j	80003ec2 <iput+0x26>

0000000080003f44 <iunlockput>:
{
    80003f44:	1101                	addi	sp,sp,-32
    80003f46:	ec06                	sd	ra,24(sp)
    80003f48:	e822                	sd	s0,16(sp)
    80003f4a:	e426                	sd	s1,8(sp)
    80003f4c:	1000                	addi	s0,sp,32
    80003f4e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	e54080e7          	jalr	-428(ra) # 80003da4 <iunlock>
  iput(ip);
    80003f58:	8526                	mv	a0,s1
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	f42080e7          	jalr	-190(ra) # 80003e9c <iput>
}
    80003f62:	60e2                	ld	ra,24(sp)
    80003f64:	6442                	ld	s0,16(sp)
    80003f66:	64a2                	ld	s1,8(sp)
    80003f68:	6105                	addi	sp,sp,32
    80003f6a:	8082                	ret

0000000080003f6c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f6c:	1141                	addi	sp,sp,-16
    80003f6e:	e422                	sd	s0,8(sp)
    80003f70:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f72:	411c                	lw	a5,0(a0)
    80003f74:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f76:	415c                	lw	a5,4(a0)
    80003f78:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f7a:	04451783          	lh	a5,68(a0)
    80003f7e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f82:	04a51783          	lh	a5,74(a0)
    80003f86:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f8a:	04c56783          	lwu	a5,76(a0)
    80003f8e:	e99c                	sd	a5,16(a1)
}
    80003f90:	6422                	ld	s0,8(sp)
    80003f92:	0141                	addi	sp,sp,16
    80003f94:	8082                	ret

0000000080003f96 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f96:	457c                	lw	a5,76(a0)
    80003f98:	0ed7e963          	bltu	a5,a3,8000408a <readi+0xf4>
{
    80003f9c:	7159                	addi	sp,sp,-112
    80003f9e:	f486                	sd	ra,104(sp)
    80003fa0:	f0a2                	sd	s0,96(sp)
    80003fa2:	eca6                	sd	s1,88(sp)
    80003fa4:	e8ca                	sd	s2,80(sp)
    80003fa6:	e4ce                	sd	s3,72(sp)
    80003fa8:	e0d2                	sd	s4,64(sp)
    80003faa:	fc56                	sd	s5,56(sp)
    80003fac:	f85a                	sd	s6,48(sp)
    80003fae:	f45e                	sd	s7,40(sp)
    80003fb0:	f062                	sd	s8,32(sp)
    80003fb2:	ec66                	sd	s9,24(sp)
    80003fb4:	e86a                	sd	s10,16(sp)
    80003fb6:	e46e                	sd	s11,8(sp)
    80003fb8:	1880                	addi	s0,sp,112
    80003fba:	8b2a                	mv	s6,a0
    80003fbc:	8bae                	mv	s7,a1
    80003fbe:	8a32                	mv	s4,a2
    80003fc0:	84b6                	mv	s1,a3
    80003fc2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fc4:	9f35                	addw	a4,a4,a3
    return 0;
    80003fc6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fc8:	0ad76063          	bltu	a4,a3,80004068 <readi+0xd2>
  if(off + n > ip->size)
    80003fcc:	00e7f463          	bgeu	a5,a4,80003fd4 <readi+0x3e>
    n = ip->size - off;
    80003fd0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fd4:	0a0a8963          	beqz	s5,80004086 <readi+0xf0>
    80003fd8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fda:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fde:	5c7d                	li	s8,-1
    80003fe0:	a82d                	j	8000401a <readi+0x84>
    80003fe2:	020d1d93          	slli	s11,s10,0x20
    80003fe6:	020ddd93          	srli	s11,s11,0x20
    80003fea:	05890613          	addi	a2,s2,88
    80003fee:	86ee                	mv	a3,s11
    80003ff0:	963a                	add	a2,a2,a4
    80003ff2:	85d2                	mv	a1,s4
    80003ff4:	855e                	mv	a0,s7
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	898080e7          	jalr	-1896(ra) # 8000288e <either_copyout>
    80003ffe:	05850d63          	beq	a0,s8,80004058 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004002:	854a                	mv	a0,s2
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	5f6080e7          	jalr	1526(ra) # 800035fa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000400c:	013d09bb          	addw	s3,s10,s3
    80004010:	009d04bb          	addw	s1,s10,s1
    80004014:	9a6e                	add	s4,s4,s11
    80004016:	0559f763          	bgeu	s3,s5,80004064 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000401a:	00a4d59b          	srliw	a1,s1,0xa
    8000401e:	855a                	mv	a0,s6
    80004020:	00000097          	auipc	ra,0x0
    80004024:	89e080e7          	jalr	-1890(ra) # 800038be <bmap>
    80004028:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000402c:	cd85                	beqz	a1,80004064 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000402e:	000b2503          	lw	a0,0(s6)
    80004032:	fffff097          	auipc	ra,0xfffff
    80004036:	498080e7          	jalr	1176(ra) # 800034ca <bread>
    8000403a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000403c:	3ff4f713          	andi	a4,s1,1023
    80004040:	40ec87bb          	subw	a5,s9,a4
    80004044:	413a86bb          	subw	a3,s5,s3
    80004048:	8d3e                	mv	s10,a5
    8000404a:	2781                	sext.w	a5,a5
    8000404c:	0006861b          	sext.w	a2,a3
    80004050:	f8f679e3          	bgeu	a2,a5,80003fe2 <readi+0x4c>
    80004054:	8d36                	mv	s10,a3
    80004056:	b771                	j	80003fe2 <readi+0x4c>
      brelse(bp);
    80004058:	854a                	mv	a0,s2
    8000405a:	fffff097          	auipc	ra,0xfffff
    8000405e:	5a0080e7          	jalr	1440(ra) # 800035fa <brelse>
      tot = -1;
    80004062:	59fd                	li	s3,-1
  }
  return tot;
    80004064:	0009851b          	sext.w	a0,s3
}
    80004068:	70a6                	ld	ra,104(sp)
    8000406a:	7406                	ld	s0,96(sp)
    8000406c:	64e6                	ld	s1,88(sp)
    8000406e:	6946                	ld	s2,80(sp)
    80004070:	69a6                	ld	s3,72(sp)
    80004072:	6a06                	ld	s4,64(sp)
    80004074:	7ae2                	ld	s5,56(sp)
    80004076:	7b42                	ld	s6,48(sp)
    80004078:	7ba2                	ld	s7,40(sp)
    8000407a:	7c02                	ld	s8,32(sp)
    8000407c:	6ce2                	ld	s9,24(sp)
    8000407e:	6d42                	ld	s10,16(sp)
    80004080:	6da2                	ld	s11,8(sp)
    80004082:	6165                	addi	sp,sp,112
    80004084:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004086:	89d6                	mv	s3,s5
    80004088:	bff1                	j	80004064 <readi+0xce>
    return 0;
    8000408a:	4501                	li	a0,0
}
    8000408c:	8082                	ret

000000008000408e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000408e:	457c                	lw	a5,76(a0)
    80004090:	10d7e863          	bltu	a5,a3,800041a0 <writei+0x112>
{
    80004094:	7159                	addi	sp,sp,-112
    80004096:	f486                	sd	ra,104(sp)
    80004098:	f0a2                	sd	s0,96(sp)
    8000409a:	eca6                	sd	s1,88(sp)
    8000409c:	e8ca                	sd	s2,80(sp)
    8000409e:	e4ce                	sd	s3,72(sp)
    800040a0:	e0d2                	sd	s4,64(sp)
    800040a2:	fc56                	sd	s5,56(sp)
    800040a4:	f85a                	sd	s6,48(sp)
    800040a6:	f45e                	sd	s7,40(sp)
    800040a8:	f062                	sd	s8,32(sp)
    800040aa:	ec66                	sd	s9,24(sp)
    800040ac:	e86a                	sd	s10,16(sp)
    800040ae:	e46e                	sd	s11,8(sp)
    800040b0:	1880                	addi	s0,sp,112
    800040b2:	8aaa                	mv	s5,a0
    800040b4:	8bae                	mv	s7,a1
    800040b6:	8a32                	mv	s4,a2
    800040b8:	8936                	mv	s2,a3
    800040ba:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040bc:	00e687bb          	addw	a5,a3,a4
    800040c0:	0ed7e263          	bltu	a5,a3,800041a4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040c4:	00043737          	lui	a4,0x43
    800040c8:	0ef76063          	bltu	a4,a5,800041a8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040cc:	0c0b0863          	beqz	s6,8000419c <writei+0x10e>
    800040d0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040d2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040d6:	5c7d                	li	s8,-1
    800040d8:	a091                	j	8000411c <writei+0x8e>
    800040da:	020d1d93          	slli	s11,s10,0x20
    800040de:	020ddd93          	srli	s11,s11,0x20
    800040e2:	05848513          	addi	a0,s1,88
    800040e6:	86ee                	mv	a3,s11
    800040e8:	8652                	mv	a2,s4
    800040ea:	85de                	mv	a1,s7
    800040ec:	953a                	add	a0,a0,a4
    800040ee:	ffffe097          	auipc	ra,0xffffe
    800040f2:	7f6080e7          	jalr	2038(ra) # 800028e4 <either_copyin>
    800040f6:	07850263          	beq	a0,s8,8000415a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040fa:	8526                	mv	a0,s1
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	788080e7          	jalr	1928(ra) # 80004884 <log_write>
    brelse(bp);
    80004104:	8526                	mv	a0,s1
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	4f4080e7          	jalr	1268(ra) # 800035fa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000410e:	013d09bb          	addw	s3,s10,s3
    80004112:	012d093b          	addw	s2,s10,s2
    80004116:	9a6e                	add	s4,s4,s11
    80004118:	0569f663          	bgeu	s3,s6,80004164 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000411c:	00a9559b          	srliw	a1,s2,0xa
    80004120:	8556                	mv	a0,s5
    80004122:	fffff097          	auipc	ra,0xfffff
    80004126:	79c080e7          	jalr	1948(ra) # 800038be <bmap>
    8000412a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000412e:	c99d                	beqz	a1,80004164 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004130:	000aa503          	lw	a0,0(s5)
    80004134:	fffff097          	auipc	ra,0xfffff
    80004138:	396080e7          	jalr	918(ra) # 800034ca <bread>
    8000413c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000413e:	3ff97713          	andi	a4,s2,1023
    80004142:	40ec87bb          	subw	a5,s9,a4
    80004146:	413b06bb          	subw	a3,s6,s3
    8000414a:	8d3e                	mv	s10,a5
    8000414c:	2781                	sext.w	a5,a5
    8000414e:	0006861b          	sext.w	a2,a3
    80004152:	f8f674e3          	bgeu	a2,a5,800040da <writei+0x4c>
    80004156:	8d36                	mv	s10,a3
    80004158:	b749                	j	800040da <writei+0x4c>
      brelse(bp);
    8000415a:	8526                	mv	a0,s1
    8000415c:	fffff097          	auipc	ra,0xfffff
    80004160:	49e080e7          	jalr	1182(ra) # 800035fa <brelse>
  }

  if(off > ip->size)
    80004164:	04caa783          	lw	a5,76(s5)
    80004168:	0127f463          	bgeu	a5,s2,80004170 <writei+0xe2>
    ip->size = off;
    8000416c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004170:	8556                	mv	a0,s5
    80004172:	00000097          	auipc	ra,0x0
    80004176:	aa4080e7          	jalr	-1372(ra) # 80003c16 <iupdate>

  return tot;
    8000417a:	0009851b          	sext.w	a0,s3
}
    8000417e:	70a6                	ld	ra,104(sp)
    80004180:	7406                	ld	s0,96(sp)
    80004182:	64e6                	ld	s1,88(sp)
    80004184:	6946                	ld	s2,80(sp)
    80004186:	69a6                	ld	s3,72(sp)
    80004188:	6a06                	ld	s4,64(sp)
    8000418a:	7ae2                	ld	s5,56(sp)
    8000418c:	7b42                	ld	s6,48(sp)
    8000418e:	7ba2                	ld	s7,40(sp)
    80004190:	7c02                	ld	s8,32(sp)
    80004192:	6ce2                	ld	s9,24(sp)
    80004194:	6d42                	ld	s10,16(sp)
    80004196:	6da2                	ld	s11,8(sp)
    80004198:	6165                	addi	sp,sp,112
    8000419a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000419c:	89da                	mv	s3,s6
    8000419e:	bfc9                	j	80004170 <writei+0xe2>
    return -1;
    800041a0:	557d                	li	a0,-1
}
    800041a2:	8082                	ret
    return -1;
    800041a4:	557d                	li	a0,-1
    800041a6:	bfe1                	j	8000417e <writei+0xf0>
    return -1;
    800041a8:	557d                	li	a0,-1
    800041aa:	bfd1                	j	8000417e <writei+0xf0>

00000000800041ac <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041ac:	1141                	addi	sp,sp,-16
    800041ae:	e406                	sd	ra,8(sp)
    800041b0:	e022                	sd	s0,0(sp)
    800041b2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041b4:	4639                	li	a2,14
    800041b6:	ffffd097          	auipc	ra,0xffffd
    800041ba:	dbe080e7          	jalr	-578(ra) # 80000f74 <strncmp>
}
    800041be:	60a2                	ld	ra,8(sp)
    800041c0:	6402                	ld	s0,0(sp)
    800041c2:	0141                	addi	sp,sp,16
    800041c4:	8082                	ret

00000000800041c6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041c6:	7139                	addi	sp,sp,-64
    800041c8:	fc06                	sd	ra,56(sp)
    800041ca:	f822                	sd	s0,48(sp)
    800041cc:	f426                	sd	s1,40(sp)
    800041ce:	f04a                	sd	s2,32(sp)
    800041d0:	ec4e                	sd	s3,24(sp)
    800041d2:	e852                	sd	s4,16(sp)
    800041d4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041d6:	04451703          	lh	a4,68(a0)
    800041da:	4785                	li	a5,1
    800041dc:	00f71a63          	bne	a4,a5,800041f0 <dirlookup+0x2a>
    800041e0:	892a                	mv	s2,a0
    800041e2:	89ae                	mv	s3,a1
    800041e4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e6:	457c                	lw	a5,76(a0)
    800041e8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041ea:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ec:	e79d                	bnez	a5,8000421a <dirlookup+0x54>
    800041ee:	a8a5                	j	80004266 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041f0:	00004517          	auipc	a0,0x4
    800041f4:	55850513          	addi	a0,a0,1368 # 80008748 <syscalls+0x1c8>
    800041f8:	ffffc097          	auipc	ra,0xffffc
    800041fc:	348080e7          	jalr	840(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004200:	00004517          	auipc	a0,0x4
    80004204:	56050513          	addi	a0,a0,1376 # 80008760 <syscalls+0x1e0>
    80004208:	ffffc097          	auipc	ra,0xffffc
    8000420c:	338080e7          	jalr	824(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004210:	24c1                	addiw	s1,s1,16
    80004212:	04c92783          	lw	a5,76(s2)
    80004216:	04f4f763          	bgeu	s1,a5,80004264 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000421a:	4741                	li	a4,16
    8000421c:	86a6                	mv	a3,s1
    8000421e:	fc040613          	addi	a2,s0,-64
    80004222:	4581                	li	a1,0
    80004224:	854a                	mv	a0,s2
    80004226:	00000097          	auipc	ra,0x0
    8000422a:	d70080e7          	jalr	-656(ra) # 80003f96 <readi>
    8000422e:	47c1                	li	a5,16
    80004230:	fcf518e3          	bne	a0,a5,80004200 <dirlookup+0x3a>
    if(de.inum == 0)
    80004234:	fc045783          	lhu	a5,-64(s0)
    80004238:	dfe1                	beqz	a5,80004210 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000423a:	fc240593          	addi	a1,s0,-62
    8000423e:	854e                	mv	a0,s3
    80004240:	00000097          	auipc	ra,0x0
    80004244:	f6c080e7          	jalr	-148(ra) # 800041ac <namecmp>
    80004248:	f561                	bnez	a0,80004210 <dirlookup+0x4a>
      if(poff)
    8000424a:	000a0463          	beqz	s4,80004252 <dirlookup+0x8c>
        *poff = off;
    8000424e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004252:	fc045583          	lhu	a1,-64(s0)
    80004256:	00092503          	lw	a0,0(s2)
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	74e080e7          	jalr	1870(ra) # 800039a8 <iget>
    80004262:	a011                	j	80004266 <dirlookup+0xa0>
  return 0;
    80004264:	4501                	li	a0,0
}
    80004266:	70e2                	ld	ra,56(sp)
    80004268:	7442                	ld	s0,48(sp)
    8000426a:	74a2                	ld	s1,40(sp)
    8000426c:	7902                	ld	s2,32(sp)
    8000426e:	69e2                	ld	s3,24(sp)
    80004270:	6a42                	ld	s4,16(sp)
    80004272:	6121                	addi	sp,sp,64
    80004274:	8082                	ret

0000000080004276 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004276:	711d                	addi	sp,sp,-96
    80004278:	ec86                	sd	ra,88(sp)
    8000427a:	e8a2                	sd	s0,80(sp)
    8000427c:	e4a6                	sd	s1,72(sp)
    8000427e:	e0ca                	sd	s2,64(sp)
    80004280:	fc4e                	sd	s3,56(sp)
    80004282:	f852                	sd	s4,48(sp)
    80004284:	f456                	sd	s5,40(sp)
    80004286:	f05a                	sd	s6,32(sp)
    80004288:	ec5e                	sd	s7,24(sp)
    8000428a:	e862                	sd	s8,16(sp)
    8000428c:	e466                	sd	s9,8(sp)
    8000428e:	e06a                	sd	s10,0(sp)
    80004290:	1080                	addi	s0,sp,96
    80004292:	84aa                	mv	s1,a0
    80004294:	8b2e                	mv	s6,a1
    80004296:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004298:	00054703          	lbu	a4,0(a0)
    8000429c:	02f00793          	li	a5,47
    800042a0:	02f70363          	beq	a4,a5,800042c6 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042a4:	ffffe097          	auipc	ra,0xffffe
    800042a8:	a34080e7          	jalr	-1484(ra) # 80001cd8 <myproc>
    800042ac:	15053503          	ld	a0,336(a0)
    800042b0:	00000097          	auipc	ra,0x0
    800042b4:	9f4080e7          	jalr	-1548(ra) # 80003ca4 <idup>
    800042b8:	8a2a                	mv	s4,a0
  while(*path == '/')
    800042ba:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800042be:	4cb5                	li	s9,13
  len = path - s;
    800042c0:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042c2:	4c05                	li	s8,1
    800042c4:	a87d                	j	80004382 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800042c6:	4585                	li	a1,1
    800042c8:	4505                	li	a0,1
    800042ca:	fffff097          	auipc	ra,0xfffff
    800042ce:	6de080e7          	jalr	1758(ra) # 800039a8 <iget>
    800042d2:	8a2a                	mv	s4,a0
    800042d4:	b7dd                	j	800042ba <namex+0x44>
      iunlockput(ip);
    800042d6:	8552                	mv	a0,s4
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	c6c080e7          	jalr	-916(ra) # 80003f44 <iunlockput>
      return 0;
    800042e0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042e2:	8552                	mv	a0,s4
    800042e4:	60e6                	ld	ra,88(sp)
    800042e6:	6446                	ld	s0,80(sp)
    800042e8:	64a6                	ld	s1,72(sp)
    800042ea:	6906                	ld	s2,64(sp)
    800042ec:	79e2                	ld	s3,56(sp)
    800042ee:	7a42                	ld	s4,48(sp)
    800042f0:	7aa2                	ld	s5,40(sp)
    800042f2:	7b02                	ld	s6,32(sp)
    800042f4:	6be2                	ld	s7,24(sp)
    800042f6:	6c42                	ld	s8,16(sp)
    800042f8:	6ca2                	ld	s9,8(sp)
    800042fa:	6d02                	ld	s10,0(sp)
    800042fc:	6125                	addi	sp,sp,96
    800042fe:	8082                	ret
      iunlock(ip);
    80004300:	8552                	mv	a0,s4
    80004302:	00000097          	auipc	ra,0x0
    80004306:	aa2080e7          	jalr	-1374(ra) # 80003da4 <iunlock>
      return ip;
    8000430a:	bfe1                	j	800042e2 <namex+0x6c>
      iunlockput(ip);
    8000430c:	8552                	mv	a0,s4
    8000430e:	00000097          	auipc	ra,0x0
    80004312:	c36080e7          	jalr	-970(ra) # 80003f44 <iunlockput>
      return 0;
    80004316:	8a4e                	mv	s4,s3
    80004318:	b7e9                	j	800042e2 <namex+0x6c>
  len = path - s;
    8000431a:	40998633          	sub	a2,s3,s1
    8000431e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004322:	09acd863          	bge	s9,s10,800043b2 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004326:	4639                	li	a2,14
    80004328:	85a6                	mv	a1,s1
    8000432a:	8556                	mv	a0,s5
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	bd4080e7          	jalr	-1068(ra) # 80000f00 <memmove>
    80004334:	84ce                	mv	s1,s3
  while(*path == '/')
    80004336:	0004c783          	lbu	a5,0(s1)
    8000433a:	01279763          	bne	a5,s2,80004348 <namex+0xd2>
    path++;
    8000433e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004340:	0004c783          	lbu	a5,0(s1)
    80004344:	ff278de3          	beq	a5,s2,8000433e <namex+0xc8>
    ilock(ip);
    80004348:	8552                	mv	a0,s4
    8000434a:	00000097          	auipc	ra,0x0
    8000434e:	998080e7          	jalr	-1640(ra) # 80003ce2 <ilock>
    if(ip->type != T_DIR){
    80004352:	044a1783          	lh	a5,68(s4)
    80004356:	f98790e3          	bne	a5,s8,800042d6 <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000435a:	000b0563          	beqz	s6,80004364 <namex+0xee>
    8000435e:	0004c783          	lbu	a5,0(s1)
    80004362:	dfd9                	beqz	a5,80004300 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004364:	865e                	mv	a2,s7
    80004366:	85d6                	mv	a1,s5
    80004368:	8552                	mv	a0,s4
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	e5c080e7          	jalr	-420(ra) # 800041c6 <dirlookup>
    80004372:	89aa                	mv	s3,a0
    80004374:	dd41                	beqz	a0,8000430c <namex+0x96>
    iunlockput(ip);
    80004376:	8552                	mv	a0,s4
    80004378:	00000097          	auipc	ra,0x0
    8000437c:	bcc080e7          	jalr	-1076(ra) # 80003f44 <iunlockput>
    ip = next;
    80004380:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004382:	0004c783          	lbu	a5,0(s1)
    80004386:	01279763          	bne	a5,s2,80004394 <namex+0x11e>
    path++;
    8000438a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000438c:	0004c783          	lbu	a5,0(s1)
    80004390:	ff278de3          	beq	a5,s2,8000438a <namex+0x114>
  if(*path == 0)
    80004394:	cb9d                	beqz	a5,800043ca <namex+0x154>
  while(*path != '/' && *path != 0)
    80004396:	0004c783          	lbu	a5,0(s1)
    8000439a:	89a6                	mv	s3,s1
  len = path - s;
    8000439c:	8d5e                	mv	s10,s7
    8000439e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800043a0:	01278963          	beq	a5,s2,800043b2 <namex+0x13c>
    800043a4:	dbbd                	beqz	a5,8000431a <namex+0xa4>
    path++;
    800043a6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800043a8:	0009c783          	lbu	a5,0(s3)
    800043ac:	ff279ce3          	bne	a5,s2,800043a4 <namex+0x12e>
    800043b0:	b7ad                	j	8000431a <namex+0xa4>
    memmove(name, s, len);
    800043b2:	2601                	sext.w	a2,a2
    800043b4:	85a6                	mv	a1,s1
    800043b6:	8556                	mv	a0,s5
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	b48080e7          	jalr	-1208(ra) # 80000f00 <memmove>
    name[len] = 0;
    800043c0:	9d56                	add	s10,s10,s5
    800043c2:	000d0023          	sb	zero,0(s10)
    800043c6:	84ce                	mv	s1,s3
    800043c8:	b7bd                	j	80004336 <namex+0xc0>
  if(nameiparent){
    800043ca:	f00b0ce3          	beqz	s6,800042e2 <namex+0x6c>
    iput(ip);
    800043ce:	8552                	mv	a0,s4
    800043d0:	00000097          	auipc	ra,0x0
    800043d4:	acc080e7          	jalr	-1332(ra) # 80003e9c <iput>
    return 0;
    800043d8:	4a01                	li	s4,0
    800043da:	b721                	j	800042e2 <namex+0x6c>

00000000800043dc <dirlink>:
{
    800043dc:	7139                	addi	sp,sp,-64
    800043de:	fc06                	sd	ra,56(sp)
    800043e0:	f822                	sd	s0,48(sp)
    800043e2:	f426                	sd	s1,40(sp)
    800043e4:	f04a                	sd	s2,32(sp)
    800043e6:	ec4e                	sd	s3,24(sp)
    800043e8:	e852                	sd	s4,16(sp)
    800043ea:	0080                	addi	s0,sp,64
    800043ec:	892a                	mv	s2,a0
    800043ee:	8a2e                	mv	s4,a1
    800043f0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043f2:	4601                	li	a2,0
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	dd2080e7          	jalr	-558(ra) # 800041c6 <dirlookup>
    800043fc:	e93d                	bnez	a0,80004472 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043fe:	04c92483          	lw	s1,76(s2)
    80004402:	c49d                	beqz	s1,80004430 <dirlink+0x54>
    80004404:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004406:	4741                	li	a4,16
    80004408:	86a6                	mv	a3,s1
    8000440a:	fc040613          	addi	a2,s0,-64
    8000440e:	4581                	li	a1,0
    80004410:	854a                	mv	a0,s2
    80004412:	00000097          	auipc	ra,0x0
    80004416:	b84080e7          	jalr	-1148(ra) # 80003f96 <readi>
    8000441a:	47c1                	li	a5,16
    8000441c:	06f51163          	bne	a0,a5,8000447e <dirlink+0xa2>
    if(de.inum == 0)
    80004420:	fc045783          	lhu	a5,-64(s0)
    80004424:	c791                	beqz	a5,80004430 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004426:	24c1                	addiw	s1,s1,16
    80004428:	04c92783          	lw	a5,76(s2)
    8000442c:	fcf4ede3          	bltu	s1,a5,80004406 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004430:	4639                	li	a2,14
    80004432:	85d2                	mv	a1,s4
    80004434:	fc240513          	addi	a0,s0,-62
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	b78080e7          	jalr	-1160(ra) # 80000fb0 <strncpy>
  de.inum = inum;
    80004440:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004444:	4741                	li	a4,16
    80004446:	86a6                	mv	a3,s1
    80004448:	fc040613          	addi	a2,s0,-64
    8000444c:	4581                	li	a1,0
    8000444e:	854a                	mv	a0,s2
    80004450:	00000097          	auipc	ra,0x0
    80004454:	c3e080e7          	jalr	-962(ra) # 8000408e <writei>
    80004458:	1541                	addi	a0,a0,-16
    8000445a:	00a03533          	snez	a0,a0
    8000445e:	40a00533          	neg	a0,a0
}
    80004462:	70e2                	ld	ra,56(sp)
    80004464:	7442                	ld	s0,48(sp)
    80004466:	74a2                	ld	s1,40(sp)
    80004468:	7902                	ld	s2,32(sp)
    8000446a:	69e2                	ld	s3,24(sp)
    8000446c:	6a42                	ld	s4,16(sp)
    8000446e:	6121                	addi	sp,sp,64
    80004470:	8082                	ret
    iput(ip);
    80004472:	00000097          	auipc	ra,0x0
    80004476:	a2a080e7          	jalr	-1494(ra) # 80003e9c <iput>
    return -1;
    8000447a:	557d                	li	a0,-1
    8000447c:	b7dd                	j	80004462 <dirlink+0x86>
      panic("dirlink read");
    8000447e:	00004517          	auipc	a0,0x4
    80004482:	2f250513          	addi	a0,a0,754 # 80008770 <syscalls+0x1f0>
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	0ba080e7          	jalr	186(ra) # 80000540 <panic>

000000008000448e <namei>:

struct inode*
namei(char *path)
{
    8000448e:	1101                	addi	sp,sp,-32
    80004490:	ec06                	sd	ra,24(sp)
    80004492:	e822                	sd	s0,16(sp)
    80004494:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004496:	fe040613          	addi	a2,s0,-32
    8000449a:	4581                	li	a1,0
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	dda080e7          	jalr	-550(ra) # 80004276 <namex>
}
    800044a4:	60e2                	ld	ra,24(sp)
    800044a6:	6442                	ld	s0,16(sp)
    800044a8:	6105                	addi	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044ac:	1141                	addi	sp,sp,-16
    800044ae:	e406                	sd	ra,8(sp)
    800044b0:	e022                	sd	s0,0(sp)
    800044b2:	0800                	addi	s0,sp,16
    800044b4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044b6:	4585                	li	a1,1
    800044b8:	00000097          	auipc	ra,0x0
    800044bc:	dbe080e7          	jalr	-578(ra) # 80004276 <namex>
}
    800044c0:	60a2                	ld	ra,8(sp)
    800044c2:	6402                	ld	s0,0(sp)
    800044c4:	0141                	addi	sp,sp,16
    800044c6:	8082                	ret

00000000800044c8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044c8:	1101                	addi	sp,sp,-32
    800044ca:	ec06                	sd	ra,24(sp)
    800044cc:	e822                	sd	s0,16(sp)
    800044ce:	e426                	sd	s1,8(sp)
    800044d0:	e04a                	sd	s2,0(sp)
    800044d2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044d4:	0003d917          	auipc	s2,0x3d
    800044d8:	80490913          	addi	s2,s2,-2044 # 80040cd8 <log>
    800044dc:	01892583          	lw	a1,24(s2)
    800044e0:	02892503          	lw	a0,40(s2)
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	fe6080e7          	jalr	-26(ra) # 800034ca <bread>
    800044ec:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044ee:	02c92683          	lw	a3,44(s2)
    800044f2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044f4:	02d05863          	blez	a3,80004524 <write_head+0x5c>
    800044f8:	0003d797          	auipc	a5,0x3d
    800044fc:	81078793          	addi	a5,a5,-2032 # 80040d08 <log+0x30>
    80004500:	05c50713          	addi	a4,a0,92
    80004504:	36fd                	addiw	a3,a3,-1
    80004506:	02069613          	slli	a2,a3,0x20
    8000450a:	01e65693          	srli	a3,a2,0x1e
    8000450e:	0003c617          	auipc	a2,0x3c
    80004512:	7fe60613          	addi	a2,a2,2046 # 80040d0c <log+0x34>
    80004516:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004518:	4390                	lw	a2,0(a5)
    8000451a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000451c:	0791                	addi	a5,a5,4
    8000451e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004520:	fed79ce3          	bne	a5,a3,80004518 <write_head+0x50>
  }
  bwrite(buf);
    80004524:	8526                	mv	a0,s1
    80004526:	fffff097          	auipc	ra,0xfffff
    8000452a:	096080e7          	jalr	150(ra) # 800035bc <bwrite>
  brelse(buf);
    8000452e:	8526                	mv	a0,s1
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	0ca080e7          	jalr	202(ra) # 800035fa <brelse>
}
    80004538:	60e2                	ld	ra,24(sp)
    8000453a:	6442                	ld	s0,16(sp)
    8000453c:	64a2                	ld	s1,8(sp)
    8000453e:	6902                	ld	s2,0(sp)
    80004540:	6105                	addi	sp,sp,32
    80004542:	8082                	ret

0000000080004544 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004544:	0003c797          	auipc	a5,0x3c
    80004548:	7c07a783          	lw	a5,1984(a5) # 80040d04 <log+0x2c>
    8000454c:	0af05d63          	blez	a5,80004606 <install_trans+0xc2>
{
    80004550:	7139                	addi	sp,sp,-64
    80004552:	fc06                	sd	ra,56(sp)
    80004554:	f822                	sd	s0,48(sp)
    80004556:	f426                	sd	s1,40(sp)
    80004558:	f04a                	sd	s2,32(sp)
    8000455a:	ec4e                	sd	s3,24(sp)
    8000455c:	e852                	sd	s4,16(sp)
    8000455e:	e456                	sd	s5,8(sp)
    80004560:	e05a                	sd	s6,0(sp)
    80004562:	0080                	addi	s0,sp,64
    80004564:	8b2a                	mv	s6,a0
    80004566:	0003ca97          	auipc	s5,0x3c
    8000456a:	7a2a8a93          	addi	s5,s5,1954 # 80040d08 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004570:	0003c997          	auipc	s3,0x3c
    80004574:	76898993          	addi	s3,s3,1896 # 80040cd8 <log>
    80004578:	a00d                	j	8000459a <install_trans+0x56>
    brelse(lbuf);
    8000457a:	854a                	mv	a0,s2
    8000457c:	fffff097          	auipc	ra,0xfffff
    80004580:	07e080e7          	jalr	126(ra) # 800035fa <brelse>
    brelse(dbuf);
    80004584:	8526                	mv	a0,s1
    80004586:	fffff097          	auipc	ra,0xfffff
    8000458a:	074080e7          	jalr	116(ra) # 800035fa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000458e:	2a05                	addiw	s4,s4,1
    80004590:	0a91                	addi	s5,s5,4
    80004592:	02c9a783          	lw	a5,44(s3)
    80004596:	04fa5e63          	bge	s4,a5,800045f2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000459a:	0189a583          	lw	a1,24(s3)
    8000459e:	014585bb          	addw	a1,a1,s4
    800045a2:	2585                	addiw	a1,a1,1
    800045a4:	0289a503          	lw	a0,40(s3)
    800045a8:	fffff097          	auipc	ra,0xfffff
    800045ac:	f22080e7          	jalr	-222(ra) # 800034ca <bread>
    800045b0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045b2:	000aa583          	lw	a1,0(s5)
    800045b6:	0289a503          	lw	a0,40(s3)
    800045ba:	fffff097          	auipc	ra,0xfffff
    800045be:	f10080e7          	jalr	-240(ra) # 800034ca <bread>
    800045c2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045c4:	40000613          	li	a2,1024
    800045c8:	05890593          	addi	a1,s2,88
    800045cc:	05850513          	addi	a0,a0,88
    800045d0:	ffffd097          	auipc	ra,0xffffd
    800045d4:	930080e7          	jalr	-1744(ra) # 80000f00 <memmove>
    bwrite(dbuf);  // write dst to disk
    800045d8:	8526                	mv	a0,s1
    800045da:	fffff097          	auipc	ra,0xfffff
    800045de:	fe2080e7          	jalr	-30(ra) # 800035bc <bwrite>
    if(recovering == 0)
    800045e2:	f80b1ce3          	bnez	s6,8000457a <install_trans+0x36>
      bunpin(dbuf);
    800045e6:	8526                	mv	a0,s1
    800045e8:	fffff097          	auipc	ra,0xfffff
    800045ec:	0ec080e7          	jalr	236(ra) # 800036d4 <bunpin>
    800045f0:	b769                	j	8000457a <install_trans+0x36>
}
    800045f2:	70e2                	ld	ra,56(sp)
    800045f4:	7442                	ld	s0,48(sp)
    800045f6:	74a2                	ld	s1,40(sp)
    800045f8:	7902                	ld	s2,32(sp)
    800045fa:	69e2                	ld	s3,24(sp)
    800045fc:	6a42                	ld	s4,16(sp)
    800045fe:	6aa2                	ld	s5,8(sp)
    80004600:	6b02                	ld	s6,0(sp)
    80004602:	6121                	addi	sp,sp,64
    80004604:	8082                	ret
    80004606:	8082                	ret

0000000080004608 <initlog>:
{
    80004608:	7179                	addi	sp,sp,-48
    8000460a:	f406                	sd	ra,40(sp)
    8000460c:	f022                	sd	s0,32(sp)
    8000460e:	ec26                	sd	s1,24(sp)
    80004610:	e84a                	sd	s2,16(sp)
    80004612:	e44e                	sd	s3,8(sp)
    80004614:	1800                	addi	s0,sp,48
    80004616:	892a                	mv	s2,a0
    80004618:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000461a:	0003c497          	auipc	s1,0x3c
    8000461e:	6be48493          	addi	s1,s1,1726 # 80040cd8 <log>
    80004622:	00004597          	auipc	a1,0x4
    80004626:	15e58593          	addi	a1,a1,350 # 80008780 <syscalls+0x200>
    8000462a:	8526                	mv	a0,s1
    8000462c:	ffffc097          	auipc	ra,0xffffc
    80004630:	6ec080e7          	jalr	1772(ra) # 80000d18 <initlock>
  log.start = sb->logstart;
    80004634:	0149a583          	lw	a1,20(s3)
    80004638:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000463a:	0109a783          	lw	a5,16(s3)
    8000463e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004640:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004644:	854a                	mv	a0,s2
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	e84080e7          	jalr	-380(ra) # 800034ca <bread>
  log.lh.n = lh->n;
    8000464e:	4d34                	lw	a3,88(a0)
    80004650:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004652:	02d05663          	blez	a3,8000467e <initlog+0x76>
    80004656:	05c50793          	addi	a5,a0,92
    8000465a:	0003c717          	auipc	a4,0x3c
    8000465e:	6ae70713          	addi	a4,a4,1710 # 80040d08 <log+0x30>
    80004662:	36fd                	addiw	a3,a3,-1
    80004664:	02069613          	slli	a2,a3,0x20
    80004668:	01e65693          	srli	a3,a2,0x1e
    8000466c:	06050613          	addi	a2,a0,96
    80004670:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004672:	4390                	lw	a2,0(a5)
    80004674:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004676:	0791                	addi	a5,a5,4
    80004678:	0711                	addi	a4,a4,4
    8000467a:	fed79ce3          	bne	a5,a3,80004672 <initlog+0x6a>
  brelse(buf);
    8000467e:	fffff097          	auipc	ra,0xfffff
    80004682:	f7c080e7          	jalr	-132(ra) # 800035fa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004686:	4505                	li	a0,1
    80004688:	00000097          	auipc	ra,0x0
    8000468c:	ebc080e7          	jalr	-324(ra) # 80004544 <install_trans>
  log.lh.n = 0;
    80004690:	0003c797          	auipc	a5,0x3c
    80004694:	6607aa23          	sw	zero,1652(a5) # 80040d04 <log+0x2c>
  write_head(); // clear the log
    80004698:	00000097          	auipc	ra,0x0
    8000469c:	e30080e7          	jalr	-464(ra) # 800044c8 <write_head>
}
    800046a0:	70a2                	ld	ra,40(sp)
    800046a2:	7402                	ld	s0,32(sp)
    800046a4:	64e2                	ld	s1,24(sp)
    800046a6:	6942                	ld	s2,16(sp)
    800046a8:	69a2                	ld	s3,8(sp)
    800046aa:	6145                	addi	sp,sp,48
    800046ac:	8082                	ret

00000000800046ae <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046ae:	1101                	addi	sp,sp,-32
    800046b0:	ec06                	sd	ra,24(sp)
    800046b2:	e822                	sd	s0,16(sp)
    800046b4:	e426                	sd	s1,8(sp)
    800046b6:	e04a                	sd	s2,0(sp)
    800046b8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046ba:	0003c517          	auipc	a0,0x3c
    800046be:	61e50513          	addi	a0,a0,1566 # 80040cd8 <log>
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	6e6080e7          	jalr	1766(ra) # 80000da8 <acquire>
  while(1){
    if(log.committing){
    800046ca:	0003c497          	auipc	s1,0x3c
    800046ce:	60e48493          	addi	s1,s1,1550 # 80040cd8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046d2:	4979                	li	s2,30
    800046d4:	a039                	j	800046e2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046d6:	85a6                	mv	a1,s1
    800046d8:	8526                	mv	a0,s1
    800046da:	ffffe097          	auipc	ra,0xffffe
    800046de:	dac080e7          	jalr	-596(ra) # 80002486 <sleep>
    if(log.committing){
    800046e2:	50dc                	lw	a5,36(s1)
    800046e4:	fbed                	bnez	a5,800046d6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046e6:	5098                	lw	a4,32(s1)
    800046e8:	2705                	addiw	a4,a4,1
    800046ea:	0007069b          	sext.w	a3,a4
    800046ee:	0027179b          	slliw	a5,a4,0x2
    800046f2:	9fb9                	addw	a5,a5,a4
    800046f4:	0017979b          	slliw	a5,a5,0x1
    800046f8:	54d8                	lw	a4,44(s1)
    800046fa:	9fb9                	addw	a5,a5,a4
    800046fc:	00f95963          	bge	s2,a5,8000470e <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004700:	85a6                	mv	a1,s1
    80004702:	8526                	mv	a0,s1
    80004704:	ffffe097          	auipc	ra,0xffffe
    80004708:	d82080e7          	jalr	-638(ra) # 80002486 <sleep>
    8000470c:	bfd9                	j	800046e2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000470e:	0003c517          	auipc	a0,0x3c
    80004712:	5ca50513          	addi	a0,a0,1482 # 80040cd8 <log>
    80004716:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	744080e7          	jalr	1860(ra) # 80000e5c <release>
      break;
    }
  }
}
    80004720:	60e2                	ld	ra,24(sp)
    80004722:	6442                	ld	s0,16(sp)
    80004724:	64a2                	ld	s1,8(sp)
    80004726:	6902                	ld	s2,0(sp)
    80004728:	6105                	addi	sp,sp,32
    8000472a:	8082                	ret

000000008000472c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000472c:	7139                	addi	sp,sp,-64
    8000472e:	fc06                	sd	ra,56(sp)
    80004730:	f822                	sd	s0,48(sp)
    80004732:	f426                	sd	s1,40(sp)
    80004734:	f04a                	sd	s2,32(sp)
    80004736:	ec4e                	sd	s3,24(sp)
    80004738:	e852                	sd	s4,16(sp)
    8000473a:	e456                	sd	s5,8(sp)
    8000473c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000473e:	0003c497          	auipc	s1,0x3c
    80004742:	59a48493          	addi	s1,s1,1434 # 80040cd8 <log>
    80004746:	8526                	mv	a0,s1
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	660080e7          	jalr	1632(ra) # 80000da8 <acquire>
  log.outstanding -= 1;
    80004750:	509c                	lw	a5,32(s1)
    80004752:	37fd                	addiw	a5,a5,-1
    80004754:	0007891b          	sext.w	s2,a5
    80004758:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000475a:	50dc                	lw	a5,36(s1)
    8000475c:	e7b9                	bnez	a5,800047aa <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000475e:	04091e63          	bnez	s2,800047ba <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004762:	0003c497          	auipc	s1,0x3c
    80004766:	57648493          	addi	s1,s1,1398 # 80040cd8 <log>
    8000476a:	4785                	li	a5,1
    8000476c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000476e:	8526                	mv	a0,s1
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	6ec080e7          	jalr	1772(ra) # 80000e5c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004778:	54dc                	lw	a5,44(s1)
    8000477a:	06f04763          	bgtz	a5,800047e8 <end_op+0xbc>
    acquire(&log.lock);
    8000477e:	0003c497          	auipc	s1,0x3c
    80004782:	55a48493          	addi	s1,s1,1370 # 80040cd8 <log>
    80004786:	8526                	mv	a0,s1
    80004788:	ffffc097          	auipc	ra,0xffffc
    8000478c:	620080e7          	jalr	1568(ra) # 80000da8 <acquire>
    log.committing = 0;
    80004790:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004794:	8526                	mv	a0,s1
    80004796:	ffffe097          	auipc	ra,0xffffe
    8000479a:	d54080e7          	jalr	-684(ra) # 800024ea <wakeup>
    release(&log.lock);
    8000479e:	8526                	mv	a0,s1
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	6bc080e7          	jalr	1724(ra) # 80000e5c <release>
}
    800047a8:	a03d                	j	800047d6 <end_op+0xaa>
    panic("log.committing");
    800047aa:	00004517          	auipc	a0,0x4
    800047ae:	fde50513          	addi	a0,a0,-34 # 80008788 <syscalls+0x208>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	d8e080e7          	jalr	-626(ra) # 80000540 <panic>
    wakeup(&log);
    800047ba:	0003c497          	auipc	s1,0x3c
    800047be:	51e48493          	addi	s1,s1,1310 # 80040cd8 <log>
    800047c2:	8526                	mv	a0,s1
    800047c4:	ffffe097          	auipc	ra,0xffffe
    800047c8:	d26080e7          	jalr	-730(ra) # 800024ea <wakeup>
  release(&log.lock);
    800047cc:	8526                	mv	a0,s1
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	68e080e7          	jalr	1678(ra) # 80000e5c <release>
}
    800047d6:	70e2                	ld	ra,56(sp)
    800047d8:	7442                	ld	s0,48(sp)
    800047da:	74a2                	ld	s1,40(sp)
    800047dc:	7902                	ld	s2,32(sp)
    800047de:	69e2                	ld	s3,24(sp)
    800047e0:	6a42                	ld	s4,16(sp)
    800047e2:	6aa2                	ld	s5,8(sp)
    800047e4:	6121                	addi	sp,sp,64
    800047e6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800047e8:	0003ca97          	auipc	s5,0x3c
    800047ec:	520a8a93          	addi	s5,s5,1312 # 80040d08 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047f0:	0003ca17          	auipc	s4,0x3c
    800047f4:	4e8a0a13          	addi	s4,s4,1256 # 80040cd8 <log>
    800047f8:	018a2583          	lw	a1,24(s4)
    800047fc:	012585bb          	addw	a1,a1,s2
    80004800:	2585                	addiw	a1,a1,1
    80004802:	028a2503          	lw	a0,40(s4)
    80004806:	fffff097          	auipc	ra,0xfffff
    8000480a:	cc4080e7          	jalr	-828(ra) # 800034ca <bread>
    8000480e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004810:	000aa583          	lw	a1,0(s5)
    80004814:	028a2503          	lw	a0,40(s4)
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	cb2080e7          	jalr	-846(ra) # 800034ca <bread>
    80004820:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004822:	40000613          	li	a2,1024
    80004826:	05850593          	addi	a1,a0,88
    8000482a:	05848513          	addi	a0,s1,88
    8000482e:	ffffc097          	auipc	ra,0xffffc
    80004832:	6d2080e7          	jalr	1746(ra) # 80000f00 <memmove>
    bwrite(to);  // write the log
    80004836:	8526                	mv	a0,s1
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	d84080e7          	jalr	-636(ra) # 800035bc <bwrite>
    brelse(from);
    80004840:	854e                	mv	a0,s3
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	db8080e7          	jalr	-584(ra) # 800035fa <brelse>
    brelse(to);
    8000484a:	8526                	mv	a0,s1
    8000484c:	fffff097          	auipc	ra,0xfffff
    80004850:	dae080e7          	jalr	-594(ra) # 800035fa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004854:	2905                	addiw	s2,s2,1
    80004856:	0a91                	addi	s5,s5,4
    80004858:	02ca2783          	lw	a5,44(s4)
    8000485c:	f8f94ee3          	blt	s2,a5,800047f8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004860:	00000097          	auipc	ra,0x0
    80004864:	c68080e7          	jalr	-920(ra) # 800044c8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004868:	4501                	li	a0,0
    8000486a:	00000097          	auipc	ra,0x0
    8000486e:	cda080e7          	jalr	-806(ra) # 80004544 <install_trans>
    log.lh.n = 0;
    80004872:	0003c797          	auipc	a5,0x3c
    80004876:	4807a923          	sw	zero,1170(a5) # 80040d04 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000487a:	00000097          	auipc	ra,0x0
    8000487e:	c4e080e7          	jalr	-946(ra) # 800044c8 <write_head>
    80004882:	bdf5                	j	8000477e <end_op+0x52>

0000000080004884 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004884:	1101                	addi	sp,sp,-32
    80004886:	ec06                	sd	ra,24(sp)
    80004888:	e822                	sd	s0,16(sp)
    8000488a:	e426                	sd	s1,8(sp)
    8000488c:	e04a                	sd	s2,0(sp)
    8000488e:	1000                	addi	s0,sp,32
    80004890:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004892:	0003c917          	auipc	s2,0x3c
    80004896:	44690913          	addi	s2,s2,1094 # 80040cd8 <log>
    8000489a:	854a                	mv	a0,s2
    8000489c:	ffffc097          	auipc	ra,0xffffc
    800048a0:	50c080e7          	jalr	1292(ra) # 80000da8 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048a4:	02c92603          	lw	a2,44(s2)
    800048a8:	47f5                	li	a5,29
    800048aa:	06c7c563          	blt	a5,a2,80004914 <log_write+0x90>
    800048ae:	0003c797          	auipc	a5,0x3c
    800048b2:	4467a783          	lw	a5,1094(a5) # 80040cf4 <log+0x1c>
    800048b6:	37fd                	addiw	a5,a5,-1
    800048b8:	04f65e63          	bge	a2,a5,80004914 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048bc:	0003c797          	auipc	a5,0x3c
    800048c0:	43c7a783          	lw	a5,1084(a5) # 80040cf8 <log+0x20>
    800048c4:	06f05063          	blez	a5,80004924 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048c8:	4781                	li	a5,0
    800048ca:	06c05563          	blez	a2,80004934 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048ce:	44cc                	lw	a1,12(s1)
    800048d0:	0003c717          	auipc	a4,0x3c
    800048d4:	43870713          	addi	a4,a4,1080 # 80040d08 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048d8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048da:	4314                	lw	a3,0(a4)
    800048dc:	04b68c63          	beq	a3,a1,80004934 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048e0:	2785                	addiw	a5,a5,1
    800048e2:	0711                	addi	a4,a4,4
    800048e4:	fef61be3          	bne	a2,a5,800048da <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048e8:	0621                	addi	a2,a2,8
    800048ea:	060a                	slli	a2,a2,0x2
    800048ec:	0003c797          	auipc	a5,0x3c
    800048f0:	3ec78793          	addi	a5,a5,1004 # 80040cd8 <log>
    800048f4:	97b2                	add	a5,a5,a2
    800048f6:	44d8                	lw	a4,12(s1)
    800048f8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048fa:	8526                	mv	a0,s1
    800048fc:	fffff097          	auipc	ra,0xfffff
    80004900:	d9c080e7          	jalr	-612(ra) # 80003698 <bpin>
    log.lh.n++;
    80004904:	0003c717          	auipc	a4,0x3c
    80004908:	3d470713          	addi	a4,a4,980 # 80040cd8 <log>
    8000490c:	575c                	lw	a5,44(a4)
    8000490e:	2785                	addiw	a5,a5,1
    80004910:	d75c                	sw	a5,44(a4)
    80004912:	a82d                	j	8000494c <log_write+0xc8>
    panic("too big a transaction");
    80004914:	00004517          	auipc	a0,0x4
    80004918:	e8450513          	addi	a0,a0,-380 # 80008798 <syscalls+0x218>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	c24080e7          	jalr	-988(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004924:	00004517          	auipc	a0,0x4
    80004928:	e8c50513          	addi	a0,a0,-372 # 800087b0 <syscalls+0x230>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	c14080e7          	jalr	-1004(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004934:	00878693          	addi	a3,a5,8
    80004938:	068a                	slli	a3,a3,0x2
    8000493a:	0003c717          	auipc	a4,0x3c
    8000493e:	39e70713          	addi	a4,a4,926 # 80040cd8 <log>
    80004942:	9736                	add	a4,a4,a3
    80004944:	44d4                	lw	a3,12(s1)
    80004946:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004948:	faf609e3          	beq	a2,a5,800048fa <log_write+0x76>
  }
  release(&log.lock);
    8000494c:	0003c517          	auipc	a0,0x3c
    80004950:	38c50513          	addi	a0,a0,908 # 80040cd8 <log>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	508080e7          	jalr	1288(ra) # 80000e5c <release>
}
    8000495c:	60e2                	ld	ra,24(sp)
    8000495e:	6442                	ld	s0,16(sp)
    80004960:	64a2                	ld	s1,8(sp)
    80004962:	6902                	ld	s2,0(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret

0000000080004968 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004968:	1101                	addi	sp,sp,-32
    8000496a:	ec06                	sd	ra,24(sp)
    8000496c:	e822                	sd	s0,16(sp)
    8000496e:	e426                	sd	s1,8(sp)
    80004970:	e04a                	sd	s2,0(sp)
    80004972:	1000                	addi	s0,sp,32
    80004974:	84aa                	mv	s1,a0
    80004976:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004978:	00004597          	auipc	a1,0x4
    8000497c:	e5858593          	addi	a1,a1,-424 # 800087d0 <syscalls+0x250>
    80004980:	0521                	addi	a0,a0,8
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	396080e7          	jalr	918(ra) # 80000d18 <initlock>
  lk->name = name;
    8000498a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000498e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004992:	0204a423          	sw	zero,40(s1)
}
    80004996:	60e2                	ld	ra,24(sp)
    80004998:	6442                	ld	s0,16(sp)
    8000499a:	64a2                	ld	s1,8(sp)
    8000499c:	6902                	ld	s2,0(sp)
    8000499e:	6105                	addi	sp,sp,32
    800049a0:	8082                	ret

00000000800049a2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049a2:	1101                	addi	sp,sp,-32
    800049a4:	ec06                	sd	ra,24(sp)
    800049a6:	e822                	sd	s0,16(sp)
    800049a8:	e426                	sd	s1,8(sp)
    800049aa:	e04a                	sd	s2,0(sp)
    800049ac:	1000                	addi	s0,sp,32
    800049ae:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049b0:	00850913          	addi	s2,a0,8
    800049b4:	854a                	mv	a0,s2
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	3f2080e7          	jalr	1010(ra) # 80000da8 <acquire>
  while (lk->locked) {
    800049be:	409c                	lw	a5,0(s1)
    800049c0:	cb89                	beqz	a5,800049d2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049c2:	85ca                	mv	a1,s2
    800049c4:	8526                	mv	a0,s1
    800049c6:	ffffe097          	auipc	ra,0xffffe
    800049ca:	ac0080e7          	jalr	-1344(ra) # 80002486 <sleep>
  while (lk->locked) {
    800049ce:	409c                	lw	a5,0(s1)
    800049d0:	fbed                	bnez	a5,800049c2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049d2:	4785                	li	a5,1
    800049d4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049d6:	ffffd097          	auipc	ra,0xffffd
    800049da:	302080e7          	jalr	770(ra) # 80001cd8 <myproc>
    800049de:	591c                	lw	a5,48(a0)
    800049e0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049e2:	854a                	mv	a0,s2
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	478080e7          	jalr	1144(ra) # 80000e5c <release>
}
    800049ec:	60e2                	ld	ra,24(sp)
    800049ee:	6442                	ld	s0,16(sp)
    800049f0:	64a2                	ld	s1,8(sp)
    800049f2:	6902                	ld	s2,0(sp)
    800049f4:	6105                	addi	sp,sp,32
    800049f6:	8082                	ret

00000000800049f8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049f8:	1101                	addi	sp,sp,-32
    800049fa:	ec06                	sd	ra,24(sp)
    800049fc:	e822                	sd	s0,16(sp)
    800049fe:	e426                	sd	s1,8(sp)
    80004a00:	e04a                	sd	s2,0(sp)
    80004a02:	1000                	addi	s0,sp,32
    80004a04:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a06:	00850913          	addi	s2,a0,8
    80004a0a:	854a                	mv	a0,s2
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	39c080e7          	jalr	924(ra) # 80000da8 <acquire>
  lk->locked = 0;
    80004a14:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a18:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffe097          	auipc	ra,0xffffe
    80004a22:	acc080e7          	jalr	-1332(ra) # 800024ea <wakeup>
  release(&lk->lk);
    80004a26:	854a                	mv	a0,s2
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	434080e7          	jalr	1076(ra) # 80000e5c <release>
}
    80004a30:	60e2                	ld	ra,24(sp)
    80004a32:	6442                	ld	s0,16(sp)
    80004a34:	64a2                	ld	s1,8(sp)
    80004a36:	6902                	ld	s2,0(sp)
    80004a38:	6105                	addi	sp,sp,32
    80004a3a:	8082                	ret

0000000080004a3c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a3c:	7179                	addi	sp,sp,-48
    80004a3e:	f406                	sd	ra,40(sp)
    80004a40:	f022                	sd	s0,32(sp)
    80004a42:	ec26                	sd	s1,24(sp)
    80004a44:	e84a                	sd	s2,16(sp)
    80004a46:	e44e                	sd	s3,8(sp)
    80004a48:	1800                	addi	s0,sp,48
    80004a4a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a4c:	00850913          	addi	s2,a0,8
    80004a50:	854a                	mv	a0,s2
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	356080e7          	jalr	854(ra) # 80000da8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a5a:	409c                	lw	a5,0(s1)
    80004a5c:	ef99                	bnez	a5,80004a7a <holdingsleep+0x3e>
    80004a5e:	4481                	li	s1,0
  release(&lk->lk);
    80004a60:	854a                	mv	a0,s2
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	3fa080e7          	jalr	1018(ra) # 80000e5c <release>
  return r;
}
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	70a2                	ld	ra,40(sp)
    80004a6e:	7402                	ld	s0,32(sp)
    80004a70:	64e2                	ld	s1,24(sp)
    80004a72:	6942                	ld	s2,16(sp)
    80004a74:	69a2                	ld	s3,8(sp)
    80004a76:	6145                	addi	sp,sp,48
    80004a78:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a7a:	0284a983          	lw	s3,40(s1)
    80004a7e:	ffffd097          	auipc	ra,0xffffd
    80004a82:	25a080e7          	jalr	602(ra) # 80001cd8 <myproc>
    80004a86:	5904                	lw	s1,48(a0)
    80004a88:	413484b3          	sub	s1,s1,s3
    80004a8c:	0014b493          	seqz	s1,s1
    80004a90:	bfc1                	j	80004a60 <holdingsleep+0x24>

0000000080004a92 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a92:	1141                	addi	sp,sp,-16
    80004a94:	e406                	sd	ra,8(sp)
    80004a96:	e022                	sd	s0,0(sp)
    80004a98:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a9a:	00004597          	auipc	a1,0x4
    80004a9e:	d4658593          	addi	a1,a1,-698 # 800087e0 <syscalls+0x260>
    80004aa2:	0003c517          	auipc	a0,0x3c
    80004aa6:	37e50513          	addi	a0,a0,894 # 80040e20 <ftable>
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	26e080e7          	jalr	622(ra) # 80000d18 <initlock>
}
    80004ab2:	60a2                	ld	ra,8(sp)
    80004ab4:	6402                	ld	s0,0(sp)
    80004ab6:	0141                	addi	sp,sp,16
    80004ab8:	8082                	ret

0000000080004aba <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ac4:	0003c517          	auipc	a0,0x3c
    80004ac8:	35c50513          	addi	a0,a0,860 # 80040e20 <ftable>
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	2dc080e7          	jalr	732(ra) # 80000da8 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ad4:	0003c497          	auipc	s1,0x3c
    80004ad8:	36448493          	addi	s1,s1,868 # 80040e38 <ftable+0x18>
    80004adc:	0003d717          	auipc	a4,0x3d
    80004ae0:	2fc70713          	addi	a4,a4,764 # 80041dd8 <disk>
    if(f->ref == 0){
    80004ae4:	40dc                	lw	a5,4(s1)
    80004ae6:	cf99                	beqz	a5,80004b04 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ae8:	02848493          	addi	s1,s1,40
    80004aec:	fee49ce3          	bne	s1,a4,80004ae4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004af0:	0003c517          	auipc	a0,0x3c
    80004af4:	33050513          	addi	a0,a0,816 # 80040e20 <ftable>
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	364080e7          	jalr	868(ra) # 80000e5c <release>
  return 0;
    80004b00:	4481                	li	s1,0
    80004b02:	a819                	j	80004b18 <filealloc+0x5e>
      f->ref = 1;
    80004b04:	4785                	li	a5,1
    80004b06:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b08:	0003c517          	auipc	a0,0x3c
    80004b0c:	31850513          	addi	a0,a0,792 # 80040e20 <ftable>
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	34c080e7          	jalr	844(ra) # 80000e5c <release>
}
    80004b18:	8526                	mv	a0,s1
    80004b1a:	60e2                	ld	ra,24(sp)
    80004b1c:	6442                	ld	s0,16(sp)
    80004b1e:	64a2                	ld	s1,8(sp)
    80004b20:	6105                	addi	sp,sp,32
    80004b22:	8082                	ret

0000000080004b24 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b24:	1101                	addi	sp,sp,-32
    80004b26:	ec06                	sd	ra,24(sp)
    80004b28:	e822                	sd	s0,16(sp)
    80004b2a:	e426                	sd	s1,8(sp)
    80004b2c:	1000                	addi	s0,sp,32
    80004b2e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b30:	0003c517          	auipc	a0,0x3c
    80004b34:	2f050513          	addi	a0,a0,752 # 80040e20 <ftable>
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	270080e7          	jalr	624(ra) # 80000da8 <acquire>
  if(f->ref < 1)
    80004b40:	40dc                	lw	a5,4(s1)
    80004b42:	02f05263          	blez	a5,80004b66 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b46:	2785                	addiw	a5,a5,1
    80004b48:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b4a:	0003c517          	auipc	a0,0x3c
    80004b4e:	2d650513          	addi	a0,a0,726 # 80040e20 <ftable>
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	30a080e7          	jalr	778(ra) # 80000e5c <release>
  return f;
}
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	60e2                	ld	ra,24(sp)
    80004b5e:	6442                	ld	s0,16(sp)
    80004b60:	64a2                	ld	s1,8(sp)
    80004b62:	6105                	addi	sp,sp,32
    80004b64:	8082                	ret
    panic("filedup");
    80004b66:	00004517          	auipc	a0,0x4
    80004b6a:	c8250513          	addi	a0,a0,-894 # 800087e8 <syscalls+0x268>
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	9d2080e7          	jalr	-1582(ra) # 80000540 <panic>

0000000080004b76 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b76:	7139                	addi	sp,sp,-64
    80004b78:	fc06                	sd	ra,56(sp)
    80004b7a:	f822                	sd	s0,48(sp)
    80004b7c:	f426                	sd	s1,40(sp)
    80004b7e:	f04a                	sd	s2,32(sp)
    80004b80:	ec4e                	sd	s3,24(sp)
    80004b82:	e852                	sd	s4,16(sp)
    80004b84:	e456                	sd	s5,8(sp)
    80004b86:	0080                	addi	s0,sp,64
    80004b88:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b8a:	0003c517          	auipc	a0,0x3c
    80004b8e:	29650513          	addi	a0,a0,662 # 80040e20 <ftable>
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	216080e7          	jalr	534(ra) # 80000da8 <acquire>
  if(f->ref < 1)
    80004b9a:	40dc                	lw	a5,4(s1)
    80004b9c:	06f05163          	blez	a5,80004bfe <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004ba0:	37fd                	addiw	a5,a5,-1
    80004ba2:	0007871b          	sext.w	a4,a5
    80004ba6:	c0dc                	sw	a5,4(s1)
    80004ba8:	06e04363          	bgtz	a4,80004c0e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bac:	0004a903          	lw	s2,0(s1)
    80004bb0:	0094ca83          	lbu	s5,9(s1)
    80004bb4:	0104ba03          	ld	s4,16(s1)
    80004bb8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004bbc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bc0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bc4:	0003c517          	auipc	a0,0x3c
    80004bc8:	25c50513          	addi	a0,a0,604 # 80040e20 <ftable>
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	290080e7          	jalr	656(ra) # 80000e5c <release>

  if(ff.type == FD_PIPE){
    80004bd4:	4785                	li	a5,1
    80004bd6:	04f90d63          	beq	s2,a5,80004c30 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bda:	3979                	addiw	s2,s2,-2
    80004bdc:	4785                	li	a5,1
    80004bde:	0527e063          	bltu	a5,s2,80004c1e <fileclose+0xa8>
    begin_op();
    80004be2:	00000097          	auipc	ra,0x0
    80004be6:	acc080e7          	jalr	-1332(ra) # 800046ae <begin_op>
    iput(ff.ip);
    80004bea:	854e                	mv	a0,s3
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	2b0080e7          	jalr	688(ra) # 80003e9c <iput>
    end_op();
    80004bf4:	00000097          	auipc	ra,0x0
    80004bf8:	b38080e7          	jalr	-1224(ra) # 8000472c <end_op>
    80004bfc:	a00d                	j	80004c1e <fileclose+0xa8>
    panic("fileclose");
    80004bfe:	00004517          	auipc	a0,0x4
    80004c02:	bf250513          	addi	a0,a0,-1038 # 800087f0 <syscalls+0x270>
    80004c06:	ffffc097          	auipc	ra,0xffffc
    80004c0a:	93a080e7          	jalr	-1734(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004c0e:	0003c517          	auipc	a0,0x3c
    80004c12:	21250513          	addi	a0,a0,530 # 80040e20 <ftable>
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	246080e7          	jalr	582(ra) # 80000e5c <release>
  }
}
    80004c1e:	70e2                	ld	ra,56(sp)
    80004c20:	7442                	ld	s0,48(sp)
    80004c22:	74a2                	ld	s1,40(sp)
    80004c24:	7902                	ld	s2,32(sp)
    80004c26:	69e2                	ld	s3,24(sp)
    80004c28:	6a42                	ld	s4,16(sp)
    80004c2a:	6aa2                	ld	s5,8(sp)
    80004c2c:	6121                	addi	sp,sp,64
    80004c2e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c30:	85d6                	mv	a1,s5
    80004c32:	8552                	mv	a0,s4
    80004c34:	00000097          	auipc	ra,0x0
    80004c38:	34c080e7          	jalr	844(ra) # 80004f80 <pipeclose>
    80004c3c:	b7cd                	j	80004c1e <fileclose+0xa8>

0000000080004c3e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c3e:	715d                	addi	sp,sp,-80
    80004c40:	e486                	sd	ra,72(sp)
    80004c42:	e0a2                	sd	s0,64(sp)
    80004c44:	fc26                	sd	s1,56(sp)
    80004c46:	f84a                	sd	s2,48(sp)
    80004c48:	f44e                	sd	s3,40(sp)
    80004c4a:	0880                	addi	s0,sp,80
    80004c4c:	84aa                	mv	s1,a0
    80004c4e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c50:	ffffd097          	auipc	ra,0xffffd
    80004c54:	088080e7          	jalr	136(ra) # 80001cd8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c58:	409c                	lw	a5,0(s1)
    80004c5a:	37f9                	addiw	a5,a5,-2
    80004c5c:	4705                	li	a4,1
    80004c5e:	04f76763          	bltu	a4,a5,80004cac <filestat+0x6e>
    80004c62:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c64:	6c88                	ld	a0,24(s1)
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	07c080e7          	jalr	124(ra) # 80003ce2 <ilock>
    stati(f->ip, &st);
    80004c6e:	fb840593          	addi	a1,s0,-72
    80004c72:	6c88                	ld	a0,24(s1)
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	2f8080e7          	jalr	760(ra) # 80003f6c <stati>
    iunlock(f->ip);
    80004c7c:	6c88                	ld	a0,24(s1)
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	126080e7          	jalr	294(ra) # 80003da4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c86:	46e1                	li	a3,24
    80004c88:	fb840613          	addi	a2,s0,-72
    80004c8c:	85ce                	mv	a1,s3
    80004c8e:	05093503          	ld	a0,80(s2)
    80004c92:	ffffd097          	auipc	ra,0xffffd
    80004c96:	bac080e7          	jalr	-1108(ra) # 8000183e <copyout>
    80004c9a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c9e:	60a6                	ld	ra,72(sp)
    80004ca0:	6406                	ld	s0,64(sp)
    80004ca2:	74e2                	ld	s1,56(sp)
    80004ca4:	7942                	ld	s2,48(sp)
    80004ca6:	79a2                	ld	s3,40(sp)
    80004ca8:	6161                	addi	sp,sp,80
    80004caa:	8082                	ret
  return -1;
    80004cac:	557d                	li	a0,-1
    80004cae:	bfc5                	j	80004c9e <filestat+0x60>

0000000080004cb0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cb0:	7179                	addi	sp,sp,-48
    80004cb2:	f406                	sd	ra,40(sp)
    80004cb4:	f022                	sd	s0,32(sp)
    80004cb6:	ec26                	sd	s1,24(sp)
    80004cb8:	e84a                	sd	s2,16(sp)
    80004cba:	e44e                	sd	s3,8(sp)
    80004cbc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004cbe:	00854783          	lbu	a5,8(a0)
    80004cc2:	c3d5                	beqz	a5,80004d66 <fileread+0xb6>
    80004cc4:	84aa                	mv	s1,a0
    80004cc6:	89ae                	mv	s3,a1
    80004cc8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cca:	411c                	lw	a5,0(a0)
    80004ccc:	4705                	li	a4,1
    80004cce:	04e78963          	beq	a5,a4,80004d20 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cd2:	470d                	li	a4,3
    80004cd4:	04e78d63          	beq	a5,a4,80004d2e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cd8:	4709                	li	a4,2
    80004cda:	06e79e63          	bne	a5,a4,80004d56 <fileread+0xa6>
    ilock(f->ip);
    80004cde:	6d08                	ld	a0,24(a0)
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	002080e7          	jalr	2(ra) # 80003ce2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ce8:	874a                	mv	a4,s2
    80004cea:	5094                	lw	a3,32(s1)
    80004cec:	864e                	mv	a2,s3
    80004cee:	4585                	li	a1,1
    80004cf0:	6c88                	ld	a0,24(s1)
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	2a4080e7          	jalr	676(ra) # 80003f96 <readi>
    80004cfa:	892a                	mv	s2,a0
    80004cfc:	00a05563          	blez	a0,80004d06 <fileread+0x56>
      f->off += r;
    80004d00:	509c                	lw	a5,32(s1)
    80004d02:	9fa9                	addw	a5,a5,a0
    80004d04:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d06:	6c88                	ld	a0,24(s1)
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	09c080e7          	jalr	156(ra) # 80003da4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d10:	854a                	mv	a0,s2
    80004d12:	70a2                	ld	ra,40(sp)
    80004d14:	7402                	ld	s0,32(sp)
    80004d16:	64e2                	ld	s1,24(sp)
    80004d18:	6942                	ld	s2,16(sp)
    80004d1a:	69a2                	ld	s3,8(sp)
    80004d1c:	6145                	addi	sp,sp,48
    80004d1e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d20:	6908                	ld	a0,16(a0)
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	3c6080e7          	jalr	966(ra) # 800050e8 <piperead>
    80004d2a:	892a                	mv	s2,a0
    80004d2c:	b7d5                	j	80004d10 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d2e:	02451783          	lh	a5,36(a0)
    80004d32:	03079693          	slli	a3,a5,0x30
    80004d36:	92c1                	srli	a3,a3,0x30
    80004d38:	4725                	li	a4,9
    80004d3a:	02d76863          	bltu	a4,a3,80004d6a <fileread+0xba>
    80004d3e:	0792                	slli	a5,a5,0x4
    80004d40:	0003c717          	auipc	a4,0x3c
    80004d44:	04070713          	addi	a4,a4,64 # 80040d80 <devsw>
    80004d48:	97ba                	add	a5,a5,a4
    80004d4a:	639c                	ld	a5,0(a5)
    80004d4c:	c38d                	beqz	a5,80004d6e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d4e:	4505                	li	a0,1
    80004d50:	9782                	jalr	a5
    80004d52:	892a                	mv	s2,a0
    80004d54:	bf75                	j	80004d10 <fileread+0x60>
    panic("fileread");
    80004d56:	00004517          	auipc	a0,0x4
    80004d5a:	aaa50513          	addi	a0,a0,-1366 # 80008800 <syscalls+0x280>
    80004d5e:	ffffb097          	auipc	ra,0xffffb
    80004d62:	7e2080e7          	jalr	2018(ra) # 80000540 <panic>
    return -1;
    80004d66:	597d                	li	s2,-1
    80004d68:	b765                	j	80004d10 <fileread+0x60>
      return -1;
    80004d6a:	597d                	li	s2,-1
    80004d6c:	b755                	j	80004d10 <fileread+0x60>
    80004d6e:	597d                	li	s2,-1
    80004d70:	b745                	j	80004d10 <fileread+0x60>

0000000080004d72 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d72:	715d                	addi	sp,sp,-80
    80004d74:	e486                	sd	ra,72(sp)
    80004d76:	e0a2                	sd	s0,64(sp)
    80004d78:	fc26                	sd	s1,56(sp)
    80004d7a:	f84a                	sd	s2,48(sp)
    80004d7c:	f44e                	sd	s3,40(sp)
    80004d7e:	f052                	sd	s4,32(sp)
    80004d80:	ec56                	sd	s5,24(sp)
    80004d82:	e85a                	sd	s6,16(sp)
    80004d84:	e45e                	sd	s7,8(sp)
    80004d86:	e062                	sd	s8,0(sp)
    80004d88:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d8a:	00954783          	lbu	a5,9(a0)
    80004d8e:	10078663          	beqz	a5,80004e9a <filewrite+0x128>
    80004d92:	892a                	mv	s2,a0
    80004d94:	8b2e                	mv	s6,a1
    80004d96:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d98:	411c                	lw	a5,0(a0)
    80004d9a:	4705                	li	a4,1
    80004d9c:	02e78263          	beq	a5,a4,80004dc0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004da0:	470d                	li	a4,3
    80004da2:	02e78663          	beq	a5,a4,80004dce <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004da6:	4709                	li	a4,2
    80004da8:	0ee79163          	bne	a5,a4,80004e8a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004dac:	0ac05d63          	blez	a2,80004e66 <filewrite+0xf4>
    int i = 0;
    80004db0:	4981                	li	s3,0
    80004db2:	6b85                	lui	s7,0x1
    80004db4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004db8:	6c05                	lui	s8,0x1
    80004dba:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004dbe:	a861                	j	80004e56 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dc0:	6908                	ld	a0,16(a0)
    80004dc2:	00000097          	auipc	ra,0x0
    80004dc6:	22e080e7          	jalr	558(ra) # 80004ff0 <pipewrite>
    80004dca:	8a2a                	mv	s4,a0
    80004dcc:	a045                	j	80004e6c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dce:	02451783          	lh	a5,36(a0)
    80004dd2:	03079693          	slli	a3,a5,0x30
    80004dd6:	92c1                	srli	a3,a3,0x30
    80004dd8:	4725                	li	a4,9
    80004dda:	0cd76263          	bltu	a4,a3,80004e9e <filewrite+0x12c>
    80004dde:	0792                	slli	a5,a5,0x4
    80004de0:	0003c717          	auipc	a4,0x3c
    80004de4:	fa070713          	addi	a4,a4,-96 # 80040d80 <devsw>
    80004de8:	97ba                	add	a5,a5,a4
    80004dea:	679c                	ld	a5,8(a5)
    80004dec:	cbdd                	beqz	a5,80004ea2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dee:	4505                	li	a0,1
    80004df0:	9782                	jalr	a5
    80004df2:	8a2a                	mv	s4,a0
    80004df4:	a8a5                	j	80004e6c <filewrite+0xfa>
    80004df6:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dfa:	00000097          	auipc	ra,0x0
    80004dfe:	8b4080e7          	jalr	-1868(ra) # 800046ae <begin_op>
      ilock(f->ip);
    80004e02:	01893503          	ld	a0,24(s2)
    80004e06:	fffff097          	auipc	ra,0xfffff
    80004e0a:	edc080e7          	jalr	-292(ra) # 80003ce2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e0e:	8756                	mv	a4,s5
    80004e10:	02092683          	lw	a3,32(s2)
    80004e14:	01698633          	add	a2,s3,s6
    80004e18:	4585                	li	a1,1
    80004e1a:	01893503          	ld	a0,24(s2)
    80004e1e:	fffff097          	auipc	ra,0xfffff
    80004e22:	270080e7          	jalr	624(ra) # 8000408e <writei>
    80004e26:	84aa                	mv	s1,a0
    80004e28:	00a05763          	blez	a0,80004e36 <filewrite+0xc4>
        f->off += r;
    80004e2c:	02092783          	lw	a5,32(s2)
    80004e30:	9fa9                	addw	a5,a5,a0
    80004e32:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e36:	01893503          	ld	a0,24(s2)
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	f6a080e7          	jalr	-150(ra) # 80003da4 <iunlock>
      end_op();
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	8ea080e7          	jalr	-1814(ra) # 8000472c <end_op>

      if(r != n1){
    80004e4a:	009a9f63          	bne	s5,s1,80004e68 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e4e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e52:	0149db63          	bge	s3,s4,80004e68 <filewrite+0xf6>
      int n1 = n - i;
    80004e56:	413a04bb          	subw	s1,s4,s3
    80004e5a:	0004879b          	sext.w	a5,s1
    80004e5e:	f8fbdce3          	bge	s7,a5,80004df6 <filewrite+0x84>
    80004e62:	84e2                	mv	s1,s8
    80004e64:	bf49                	j	80004df6 <filewrite+0x84>
    int i = 0;
    80004e66:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e68:	013a1f63          	bne	s4,s3,80004e86 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e6c:	8552                	mv	a0,s4
    80004e6e:	60a6                	ld	ra,72(sp)
    80004e70:	6406                	ld	s0,64(sp)
    80004e72:	74e2                	ld	s1,56(sp)
    80004e74:	7942                	ld	s2,48(sp)
    80004e76:	79a2                	ld	s3,40(sp)
    80004e78:	7a02                	ld	s4,32(sp)
    80004e7a:	6ae2                	ld	s5,24(sp)
    80004e7c:	6b42                	ld	s6,16(sp)
    80004e7e:	6ba2                	ld	s7,8(sp)
    80004e80:	6c02                	ld	s8,0(sp)
    80004e82:	6161                	addi	sp,sp,80
    80004e84:	8082                	ret
    ret = (i == n ? n : -1);
    80004e86:	5a7d                	li	s4,-1
    80004e88:	b7d5                	j	80004e6c <filewrite+0xfa>
    panic("filewrite");
    80004e8a:	00004517          	auipc	a0,0x4
    80004e8e:	98650513          	addi	a0,a0,-1658 # 80008810 <syscalls+0x290>
    80004e92:	ffffb097          	auipc	ra,0xffffb
    80004e96:	6ae080e7          	jalr	1710(ra) # 80000540 <panic>
    return -1;
    80004e9a:	5a7d                	li	s4,-1
    80004e9c:	bfc1                	j	80004e6c <filewrite+0xfa>
      return -1;
    80004e9e:	5a7d                	li	s4,-1
    80004ea0:	b7f1                	j	80004e6c <filewrite+0xfa>
    80004ea2:	5a7d                	li	s4,-1
    80004ea4:	b7e1                	j	80004e6c <filewrite+0xfa>

0000000080004ea6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ea6:	7179                	addi	sp,sp,-48
    80004ea8:	f406                	sd	ra,40(sp)
    80004eaa:	f022                	sd	s0,32(sp)
    80004eac:	ec26                	sd	s1,24(sp)
    80004eae:	e84a                	sd	s2,16(sp)
    80004eb0:	e44e                	sd	s3,8(sp)
    80004eb2:	e052                	sd	s4,0(sp)
    80004eb4:	1800                	addi	s0,sp,48
    80004eb6:	84aa                	mv	s1,a0
    80004eb8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004eba:	0005b023          	sd	zero,0(a1)
    80004ebe:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ec2:	00000097          	auipc	ra,0x0
    80004ec6:	bf8080e7          	jalr	-1032(ra) # 80004aba <filealloc>
    80004eca:	e088                	sd	a0,0(s1)
    80004ecc:	c551                	beqz	a0,80004f58 <pipealloc+0xb2>
    80004ece:	00000097          	auipc	ra,0x0
    80004ed2:	bec080e7          	jalr	-1044(ra) # 80004aba <filealloc>
    80004ed6:	00aa3023          	sd	a0,0(s4)
    80004eda:	c92d                	beqz	a0,80004f4c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	d42080e7          	jalr	-702(ra) # 80000c1e <kalloc>
    80004ee4:	892a                	mv	s2,a0
    80004ee6:	c125                	beqz	a0,80004f46 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ee8:	4985                	li	s3,1
    80004eea:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004eee:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ef2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ef6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004efa:	00004597          	auipc	a1,0x4
    80004efe:	92658593          	addi	a1,a1,-1754 # 80008820 <syscalls+0x2a0>
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	e16080e7          	jalr	-490(ra) # 80000d18 <initlock>
  (*f0)->type = FD_PIPE;
    80004f0a:	609c                	ld	a5,0(s1)
    80004f0c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f10:	609c                	ld	a5,0(s1)
    80004f12:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f16:	609c                	ld	a5,0(s1)
    80004f18:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f1c:	609c                	ld	a5,0(s1)
    80004f1e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f22:	000a3783          	ld	a5,0(s4)
    80004f26:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f2a:	000a3783          	ld	a5,0(s4)
    80004f2e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f32:	000a3783          	ld	a5,0(s4)
    80004f36:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f3a:	000a3783          	ld	a5,0(s4)
    80004f3e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f42:	4501                	li	a0,0
    80004f44:	a025                	j	80004f6c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f46:	6088                	ld	a0,0(s1)
    80004f48:	e501                	bnez	a0,80004f50 <pipealloc+0xaa>
    80004f4a:	a039                	j	80004f58 <pipealloc+0xb2>
    80004f4c:	6088                	ld	a0,0(s1)
    80004f4e:	c51d                	beqz	a0,80004f7c <pipealloc+0xd6>
    fileclose(*f0);
    80004f50:	00000097          	auipc	ra,0x0
    80004f54:	c26080e7          	jalr	-986(ra) # 80004b76 <fileclose>
  if(*f1)
    80004f58:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f5c:	557d                	li	a0,-1
  if(*f1)
    80004f5e:	c799                	beqz	a5,80004f6c <pipealloc+0xc6>
    fileclose(*f1);
    80004f60:	853e                	mv	a0,a5
    80004f62:	00000097          	auipc	ra,0x0
    80004f66:	c14080e7          	jalr	-1004(ra) # 80004b76 <fileclose>
  return -1;
    80004f6a:	557d                	li	a0,-1
}
    80004f6c:	70a2                	ld	ra,40(sp)
    80004f6e:	7402                	ld	s0,32(sp)
    80004f70:	64e2                	ld	s1,24(sp)
    80004f72:	6942                	ld	s2,16(sp)
    80004f74:	69a2                	ld	s3,8(sp)
    80004f76:	6a02                	ld	s4,0(sp)
    80004f78:	6145                	addi	sp,sp,48
    80004f7a:	8082                	ret
  return -1;
    80004f7c:	557d                	li	a0,-1
    80004f7e:	b7fd                	j	80004f6c <pipealloc+0xc6>

0000000080004f80 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f80:	1101                	addi	sp,sp,-32
    80004f82:	ec06                	sd	ra,24(sp)
    80004f84:	e822                	sd	s0,16(sp)
    80004f86:	e426                	sd	s1,8(sp)
    80004f88:	e04a                	sd	s2,0(sp)
    80004f8a:	1000                	addi	s0,sp,32
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	e18080e7          	jalr	-488(ra) # 80000da8 <acquire>
  if(writable){
    80004f98:	02090d63          	beqz	s2,80004fd2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f9c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fa0:	21848513          	addi	a0,s1,536
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	546080e7          	jalr	1350(ra) # 800024ea <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004fac:	2204b783          	ld	a5,544(s1)
    80004fb0:	eb95                	bnez	a5,80004fe4 <pipeclose+0x64>
    release(&pi->lock);
    80004fb2:	8526                	mv	a0,s1
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	ea8080e7          	jalr	-344(ra) # 80000e5c <release>
    kfree((char*)pi);
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	a6e080e7          	jalr	-1426(ra) # 80000a2c <kfree>
  } else
    release(&pi->lock);
}
    80004fc6:	60e2                	ld	ra,24(sp)
    80004fc8:	6442                	ld	s0,16(sp)
    80004fca:	64a2                	ld	s1,8(sp)
    80004fcc:	6902                	ld	s2,0(sp)
    80004fce:	6105                	addi	sp,sp,32
    80004fd0:	8082                	ret
    pi->readopen = 0;
    80004fd2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fd6:	21c48513          	addi	a0,s1,540
    80004fda:	ffffd097          	auipc	ra,0xffffd
    80004fde:	510080e7          	jalr	1296(ra) # 800024ea <wakeup>
    80004fe2:	b7e9                	j	80004fac <pipeclose+0x2c>
    release(&pi->lock);
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	ffffc097          	auipc	ra,0xffffc
    80004fea:	e76080e7          	jalr	-394(ra) # 80000e5c <release>
}
    80004fee:	bfe1                	j	80004fc6 <pipeclose+0x46>

0000000080004ff0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ff0:	711d                	addi	sp,sp,-96
    80004ff2:	ec86                	sd	ra,88(sp)
    80004ff4:	e8a2                	sd	s0,80(sp)
    80004ff6:	e4a6                	sd	s1,72(sp)
    80004ff8:	e0ca                	sd	s2,64(sp)
    80004ffa:	fc4e                	sd	s3,56(sp)
    80004ffc:	f852                	sd	s4,48(sp)
    80004ffe:	f456                	sd	s5,40(sp)
    80005000:	f05a                	sd	s6,32(sp)
    80005002:	ec5e                	sd	s7,24(sp)
    80005004:	e862                	sd	s8,16(sp)
    80005006:	1080                	addi	s0,sp,96
    80005008:	84aa                	mv	s1,a0
    8000500a:	8aae                	mv	s5,a1
    8000500c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000500e:	ffffd097          	auipc	ra,0xffffd
    80005012:	cca080e7          	jalr	-822(ra) # 80001cd8 <myproc>
    80005016:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	d8e080e7          	jalr	-626(ra) # 80000da8 <acquire>
  while(i < n){
    80005022:	0b405663          	blez	s4,800050ce <pipewrite+0xde>
  int i = 0;
    80005026:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005028:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000502a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000502e:	21c48b93          	addi	s7,s1,540
    80005032:	a089                	j	80005074 <pipewrite+0x84>
      release(&pi->lock);
    80005034:	8526                	mv	a0,s1
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	e26080e7          	jalr	-474(ra) # 80000e5c <release>
      return -1;
    8000503e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005040:	854a                	mv	a0,s2
    80005042:	60e6                	ld	ra,88(sp)
    80005044:	6446                	ld	s0,80(sp)
    80005046:	64a6                	ld	s1,72(sp)
    80005048:	6906                	ld	s2,64(sp)
    8000504a:	79e2                	ld	s3,56(sp)
    8000504c:	7a42                	ld	s4,48(sp)
    8000504e:	7aa2                	ld	s5,40(sp)
    80005050:	7b02                	ld	s6,32(sp)
    80005052:	6be2                	ld	s7,24(sp)
    80005054:	6c42                	ld	s8,16(sp)
    80005056:	6125                	addi	sp,sp,96
    80005058:	8082                	ret
      wakeup(&pi->nread);
    8000505a:	8562                	mv	a0,s8
    8000505c:	ffffd097          	auipc	ra,0xffffd
    80005060:	48e080e7          	jalr	1166(ra) # 800024ea <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005064:	85a6                	mv	a1,s1
    80005066:	855e                	mv	a0,s7
    80005068:	ffffd097          	auipc	ra,0xffffd
    8000506c:	41e080e7          	jalr	1054(ra) # 80002486 <sleep>
  while(i < n){
    80005070:	07495063          	bge	s2,s4,800050d0 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005074:	2204a783          	lw	a5,544(s1)
    80005078:	dfd5                	beqz	a5,80005034 <pipewrite+0x44>
    8000507a:	854e                	mv	a0,s3
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	6b2080e7          	jalr	1714(ra) # 8000272e <killed>
    80005084:	f945                	bnez	a0,80005034 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005086:	2184a783          	lw	a5,536(s1)
    8000508a:	21c4a703          	lw	a4,540(s1)
    8000508e:	2007879b          	addiw	a5,a5,512
    80005092:	fcf704e3          	beq	a4,a5,8000505a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005096:	4685                	li	a3,1
    80005098:	01590633          	add	a2,s2,s5
    8000509c:	faf40593          	addi	a1,s0,-81
    800050a0:	0509b503          	ld	a0,80(s3)
    800050a4:	ffffd097          	auipc	ra,0xffffd
    800050a8:	826080e7          	jalr	-2010(ra) # 800018ca <copyin>
    800050ac:	03650263          	beq	a0,s6,800050d0 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050b0:	21c4a783          	lw	a5,540(s1)
    800050b4:	0017871b          	addiw	a4,a5,1
    800050b8:	20e4ae23          	sw	a4,540(s1)
    800050bc:	1ff7f793          	andi	a5,a5,511
    800050c0:	97a6                	add	a5,a5,s1
    800050c2:	faf44703          	lbu	a4,-81(s0)
    800050c6:	00e78c23          	sb	a4,24(a5)
      i++;
    800050ca:	2905                	addiw	s2,s2,1
    800050cc:	b755                	j	80005070 <pipewrite+0x80>
  int i = 0;
    800050ce:	4901                	li	s2,0
  wakeup(&pi->nread);
    800050d0:	21848513          	addi	a0,s1,536
    800050d4:	ffffd097          	auipc	ra,0xffffd
    800050d8:	416080e7          	jalr	1046(ra) # 800024ea <wakeup>
  release(&pi->lock);
    800050dc:	8526                	mv	a0,s1
    800050de:	ffffc097          	auipc	ra,0xffffc
    800050e2:	d7e080e7          	jalr	-642(ra) # 80000e5c <release>
  return i;
    800050e6:	bfa9                	j	80005040 <pipewrite+0x50>

00000000800050e8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050e8:	715d                	addi	sp,sp,-80
    800050ea:	e486                	sd	ra,72(sp)
    800050ec:	e0a2                	sd	s0,64(sp)
    800050ee:	fc26                	sd	s1,56(sp)
    800050f0:	f84a                	sd	s2,48(sp)
    800050f2:	f44e                	sd	s3,40(sp)
    800050f4:	f052                	sd	s4,32(sp)
    800050f6:	ec56                	sd	s5,24(sp)
    800050f8:	e85a                	sd	s6,16(sp)
    800050fa:	0880                	addi	s0,sp,80
    800050fc:	84aa                	mv	s1,a0
    800050fe:	892e                	mv	s2,a1
    80005100:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005102:	ffffd097          	auipc	ra,0xffffd
    80005106:	bd6080e7          	jalr	-1066(ra) # 80001cd8 <myproc>
    8000510a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000510c:	8526                	mv	a0,s1
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	c9a080e7          	jalr	-870(ra) # 80000da8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005116:	2184a703          	lw	a4,536(s1)
    8000511a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000511e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005122:	02f71763          	bne	a4,a5,80005150 <piperead+0x68>
    80005126:	2244a783          	lw	a5,548(s1)
    8000512a:	c39d                	beqz	a5,80005150 <piperead+0x68>
    if(killed(pr)){
    8000512c:	8552                	mv	a0,s4
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	600080e7          	jalr	1536(ra) # 8000272e <killed>
    80005136:	e949                	bnez	a0,800051c8 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005138:	85a6                	mv	a1,s1
    8000513a:	854e                	mv	a0,s3
    8000513c:	ffffd097          	auipc	ra,0xffffd
    80005140:	34a080e7          	jalr	842(ra) # 80002486 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005144:	2184a703          	lw	a4,536(s1)
    80005148:	21c4a783          	lw	a5,540(s1)
    8000514c:	fcf70de3          	beq	a4,a5,80005126 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005150:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005152:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005154:	05505463          	blez	s5,8000519c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005158:	2184a783          	lw	a5,536(s1)
    8000515c:	21c4a703          	lw	a4,540(s1)
    80005160:	02f70e63          	beq	a4,a5,8000519c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005164:	0017871b          	addiw	a4,a5,1
    80005168:	20e4ac23          	sw	a4,536(s1)
    8000516c:	1ff7f793          	andi	a5,a5,511
    80005170:	97a6                	add	a5,a5,s1
    80005172:	0187c783          	lbu	a5,24(a5)
    80005176:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000517a:	4685                	li	a3,1
    8000517c:	fbf40613          	addi	a2,s0,-65
    80005180:	85ca                	mv	a1,s2
    80005182:	050a3503          	ld	a0,80(s4)
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	6b8080e7          	jalr	1720(ra) # 8000183e <copyout>
    8000518e:	01650763          	beq	a0,s6,8000519c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005192:	2985                	addiw	s3,s3,1
    80005194:	0905                	addi	s2,s2,1
    80005196:	fd3a91e3          	bne	s5,s3,80005158 <piperead+0x70>
    8000519a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000519c:	21c48513          	addi	a0,s1,540
    800051a0:	ffffd097          	auipc	ra,0xffffd
    800051a4:	34a080e7          	jalr	842(ra) # 800024ea <wakeup>
  release(&pi->lock);
    800051a8:	8526                	mv	a0,s1
    800051aa:	ffffc097          	auipc	ra,0xffffc
    800051ae:	cb2080e7          	jalr	-846(ra) # 80000e5c <release>
  return i;
}
    800051b2:	854e                	mv	a0,s3
    800051b4:	60a6                	ld	ra,72(sp)
    800051b6:	6406                	ld	s0,64(sp)
    800051b8:	74e2                	ld	s1,56(sp)
    800051ba:	7942                	ld	s2,48(sp)
    800051bc:	79a2                	ld	s3,40(sp)
    800051be:	7a02                	ld	s4,32(sp)
    800051c0:	6ae2                	ld	s5,24(sp)
    800051c2:	6b42                	ld	s6,16(sp)
    800051c4:	6161                	addi	sp,sp,80
    800051c6:	8082                	ret
      release(&pi->lock);
    800051c8:	8526                	mv	a0,s1
    800051ca:	ffffc097          	auipc	ra,0xffffc
    800051ce:	c92080e7          	jalr	-878(ra) # 80000e5c <release>
      return -1;
    800051d2:	59fd                	li	s3,-1
    800051d4:	bff9                	j	800051b2 <piperead+0xca>

00000000800051d6 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800051d6:	1141                	addi	sp,sp,-16
    800051d8:	e422                	sd	s0,8(sp)
    800051da:	0800                	addi	s0,sp,16
    800051dc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800051de:	8905                	andi	a0,a0,1
    800051e0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800051e2:	8b89                	andi	a5,a5,2
    800051e4:	c399                	beqz	a5,800051ea <flags2perm+0x14>
      perm |= PTE_W;
    800051e6:	00456513          	ori	a0,a0,4
    return perm;
}
    800051ea:	6422                	ld	s0,8(sp)
    800051ec:	0141                	addi	sp,sp,16
    800051ee:	8082                	ret

00000000800051f0 <exec>:

int
exec(char *path, char **argv)
{
    800051f0:	de010113          	addi	sp,sp,-544
    800051f4:	20113c23          	sd	ra,536(sp)
    800051f8:	20813823          	sd	s0,528(sp)
    800051fc:	20913423          	sd	s1,520(sp)
    80005200:	21213023          	sd	s2,512(sp)
    80005204:	ffce                	sd	s3,504(sp)
    80005206:	fbd2                	sd	s4,496(sp)
    80005208:	f7d6                	sd	s5,488(sp)
    8000520a:	f3da                	sd	s6,480(sp)
    8000520c:	efde                	sd	s7,472(sp)
    8000520e:	ebe2                	sd	s8,464(sp)
    80005210:	e7e6                	sd	s9,456(sp)
    80005212:	e3ea                	sd	s10,448(sp)
    80005214:	ff6e                	sd	s11,440(sp)
    80005216:	1400                	addi	s0,sp,544
    80005218:	892a                	mv	s2,a0
    8000521a:	dea43423          	sd	a0,-536(s0)
    8000521e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005222:	ffffd097          	auipc	ra,0xffffd
    80005226:	ab6080e7          	jalr	-1354(ra) # 80001cd8 <myproc>
    8000522a:	84aa                	mv	s1,a0

  begin_op();
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	482080e7          	jalr	1154(ra) # 800046ae <begin_op>

  if((ip = namei(path)) == 0){
    80005234:	854a                	mv	a0,s2
    80005236:	fffff097          	auipc	ra,0xfffff
    8000523a:	258080e7          	jalr	600(ra) # 8000448e <namei>
    8000523e:	c93d                	beqz	a0,800052b4 <exec+0xc4>
    80005240:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	aa0080e7          	jalr	-1376(ra) # 80003ce2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000524a:	04000713          	li	a4,64
    8000524e:	4681                	li	a3,0
    80005250:	e5040613          	addi	a2,s0,-432
    80005254:	4581                	li	a1,0
    80005256:	8556                	mv	a0,s5
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	d3e080e7          	jalr	-706(ra) # 80003f96 <readi>
    80005260:	04000793          	li	a5,64
    80005264:	00f51a63          	bne	a0,a5,80005278 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005268:	e5042703          	lw	a4,-432(s0)
    8000526c:	464c47b7          	lui	a5,0x464c4
    80005270:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005274:	04f70663          	beq	a4,a5,800052c0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005278:	8556                	mv	a0,s5
    8000527a:	fffff097          	auipc	ra,0xfffff
    8000527e:	cca080e7          	jalr	-822(ra) # 80003f44 <iunlockput>
    end_op();
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	4aa080e7          	jalr	1194(ra) # 8000472c <end_op>
  }
  return -1;
    8000528a:	557d                	li	a0,-1
}
    8000528c:	21813083          	ld	ra,536(sp)
    80005290:	21013403          	ld	s0,528(sp)
    80005294:	20813483          	ld	s1,520(sp)
    80005298:	20013903          	ld	s2,512(sp)
    8000529c:	79fe                	ld	s3,504(sp)
    8000529e:	7a5e                	ld	s4,496(sp)
    800052a0:	7abe                	ld	s5,488(sp)
    800052a2:	7b1e                	ld	s6,480(sp)
    800052a4:	6bfe                	ld	s7,472(sp)
    800052a6:	6c5e                	ld	s8,464(sp)
    800052a8:	6cbe                	ld	s9,456(sp)
    800052aa:	6d1e                	ld	s10,448(sp)
    800052ac:	7dfa                	ld	s11,440(sp)
    800052ae:	22010113          	addi	sp,sp,544
    800052b2:	8082                	ret
    end_op();
    800052b4:	fffff097          	auipc	ra,0xfffff
    800052b8:	478080e7          	jalr	1144(ra) # 8000472c <end_op>
    return -1;
    800052bc:	557d                	li	a0,-1
    800052be:	b7f9                	j	8000528c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800052c0:	8526                	mv	a0,s1
    800052c2:	ffffd097          	auipc	ra,0xffffd
    800052c6:	ada080e7          	jalr	-1318(ra) # 80001d9c <proc_pagetable>
    800052ca:	8b2a                	mv	s6,a0
    800052cc:	d555                	beqz	a0,80005278 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052ce:	e7042783          	lw	a5,-400(s0)
    800052d2:	e8845703          	lhu	a4,-376(s0)
    800052d6:	c735                	beqz	a4,80005342 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052d8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052da:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800052de:	6a05                	lui	s4,0x1
    800052e0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800052e4:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800052e8:	6d85                	lui	s11,0x1
    800052ea:	7d7d                	lui	s10,0xfffff
    800052ec:	ac3d                	j	8000552a <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052ee:	00003517          	auipc	a0,0x3
    800052f2:	53a50513          	addi	a0,a0,1338 # 80008828 <syscalls+0x2a8>
    800052f6:	ffffb097          	auipc	ra,0xffffb
    800052fa:	24a080e7          	jalr	586(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052fe:	874a                	mv	a4,s2
    80005300:	009c86bb          	addw	a3,s9,s1
    80005304:	4581                	li	a1,0
    80005306:	8556                	mv	a0,s5
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	c8e080e7          	jalr	-882(ra) # 80003f96 <readi>
    80005310:	2501                	sext.w	a0,a0
    80005312:	1aa91963          	bne	s2,a0,800054c4 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005316:	009d84bb          	addw	s1,s11,s1
    8000531a:	013d09bb          	addw	s3,s10,s3
    8000531e:	1f74f663          	bgeu	s1,s7,8000550a <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005322:	02049593          	slli	a1,s1,0x20
    80005326:	9181                	srli	a1,a1,0x20
    80005328:	95e2                	add	a1,a1,s8
    8000532a:	855a                	mv	a0,s6
    8000532c:	ffffc097          	auipc	ra,0xffffc
    80005330:	f02080e7          	jalr	-254(ra) # 8000122e <walkaddr>
    80005334:	862a                	mv	a2,a0
    if(pa == 0)
    80005336:	dd45                	beqz	a0,800052ee <exec+0xfe>
      n = PGSIZE;
    80005338:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000533a:	fd49f2e3          	bgeu	s3,s4,800052fe <exec+0x10e>
      n = sz - i;
    8000533e:	894e                	mv	s2,s3
    80005340:	bf7d                	j	800052fe <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005342:	4901                	li	s2,0
  iunlockput(ip);
    80005344:	8556                	mv	a0,s5
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	bfe080e7          	jalr	-1026(ra) # 80003f44 <iunlockput>
  end_op();
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	3de080e7          	jalr	990(ra) # 8000472c <end_op>
  p = myproc();
    80005356:	ffffd097          	auipc	ra,0xffffd
    8000535a:	982080e7          	jalr	-1662(ra) # 80001cd8 <myproc>
    8000535e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005360:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005364:	6785                	lui	a5,0x1
    80005366:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005368:	97ca                	add	a5,a5,s2
    8000536a:	777d                	lui	a4,0xfffff
    8000536c:	8ff9                	and	a5,a5,a4
    8000536e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005372:	4691                	li	a3,4
    80005374:	6609                	lui	a2,0x2
    80005376:	963e                	add	a2,a2,a5
    80005378:	85be                	mv	a1,a5
    8000537a:	855a                	mv	a0,s6
    8000537c:	ffffc097          	auipc	ra,0xffffc
    80005380:	266080e7          	jalr	614(ra) # 800015e2 <uvmalloc>
    80005384:	8c2a                	mv	s8,a0
  ip = 0;
    80005386:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005388:	12050e63          	beqz	a0,800054c4 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000538c:	75f9                	lui	a1,0xffffe
    8000538e:	95aa                	add	a1,a1,a0
    80005390:	855a                	mv	a0,s6
    80005392:	ffffc097          	auipc	ra,0xffffc
    80005396:	47a080e7          	jalr	1146(ra) # 8000180c <uvmclear>
  stackbase = sp - PGSIZE;
    8000539a:	7afd                	lui	s5,0xfffff
    8000539c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000539e:	df043783          	ld	a5,-528(s0)
    800053a2:	6388                	ld	a0,0(a5)
    800053a4:	c925                	beqz	a0,80005414 <exec+0x224>
    800053a6:	e9040993          	addi	s3,s0,-368
    800053aa:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800053ae:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800053b0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053b2:	ffffc097          	auipc	ra,0xffffc
    800053b6:	c6e080e7          	jalr	-914(ra) # 80001020 <strlen>
    800053ba:	0015079b          	addiw	a5,a0,1
    800053be:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053c2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800053c6:	13596663          	bltu	s2,s5,800054f2 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053ca:	df043d83          	ld	s11,-528(s0)
    800053ce:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800053d2:	8552                	mv	a0,s4
    800053d4:	ffffc097          	auipc	ra,0xffffc
    800053d8:	c4c080e7          	jalr	-948(ra) # 80001020 <strlen>
    800053dc:	0015069b          	addiw	a3,a0,1
    800053e0:	8652                	mv	a2,s4
    800053e2:	85ca                	mv	a1,s2
    800053e4:	855a                	mv	a0,s6
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	458080e7          	jalr	1112(ra) # 8000183e <copyout>
    800053ee:	10054663          	bltz	a0,800054fa <exec+0x30a>
    ustack[argc] = sp;
    800053f2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053f6:	0485                	addi	s1,s1,1
    800053f8:	008d8793          	addi	a5,s11,8
    800053fc:	def43823          	sd	a5,-528(s0)
    80005400:	008db503          	ld	a0,8(s11)
    80005404:	c911                	beqz	a0,80005418 <exec+0x228>
    if(argc >= MAXARG)
    80005406:	09a1                	addi	s3,s3,8
    80005408:	fb3c95e3          	bne	s9,s3,800053b2 <exec+0x1c2>
  sz = sz1;
    8000540c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005410:	4a81                	li	s5,0
    80005412:	a84d                	j	800054c4 <exec+0x2d4>
  sp = sz;
    80005414:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005416:	4481                	li	s1,0
  ustack[argc] = 0;
    80005418:	00349793          	slli	a5,s1,0x3
    8000541c:	f9078793          	addi	a5,a5,-112
    80005420:	97a2                	add	a5,a5,s0
    80005422:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005426:	00148693          	addi	a3,s1,1
    8000542a:	068e                	slli	a3,a3,0x3
    8000542c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005430:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005434:	01597663          	bgeu	s2,s5,80005440 <exec+0x250>
  sz = sz1;
    80005438:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000543c:	4a81                	li	s5,0
    8000543e:	a059                	j	800054c4 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005440:	e9040613          	addi	a2,s0,-368
    80005444:	85ca                	mv	a1,s2
    80005446:	855a                	mv	a0,s6
    80005448:	ffffc097          	auipc	ra,0xffffc
    8000544c:	3f6080e7          	jalr	1014(ra) # 8000183e <copyout>
    80005450:	0a054963          	bltz	a0,80005502 <exec+0x312>
  p->trapframe->a1 = sp;
    80005454:	058bb783          	ld	a5,88(s7)
    80005458:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000545c:	de843783          	ld	a5,-536(s0)
    80005460:	0007c703          	lbu	a4,0(a5)
    80005464:	cf11                	beqz	a4,80005480 <exec+0x290>
    80005466:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005468:	02f00693          	li	a3,47
    8000546c:	a039                	j	8000547a <exec+0x28a>
      last = s+1;
    8000546e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005472:	0785                	addi	a5,a5,1
    80005474:	fff7c703          	lbu	a4,-1(a5)
    80005478:	c701                	beqz	a4,80005480 <exec+0x290>
    if(*s == '/')
    8000547a:	fed71ce3          	bne	a4,a3,80005472 <exec+0x282>
    8000547e:	bfc5                	j	8000546e <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005480:	4641                	li	a2,16
    80005482:	de843583          	ld	a1,-536(s0)
    80005486:	158b8513          	addi	a0,s7,344
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	b64080e7          	jalr	-1180(ra) # 80000fee <safestrcpy>
  oldpagetable = p->pagetable;
    80005492:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005496:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000549a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000549e:	058bb783          	ld	a5,88(s7)
    800054a2:	e6843703          	ld	a4,-408(s0)
    800054a6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054a8:	058bb783          	ld	a5,88(s7)
    800054ac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054b0:	85ea                	mv	a1,s10
    800054b2:	ffffd097          	auipc	ra,0xffffd
    800054b6:	986080e7          	jalr	-1658(ra) # 80001e38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054ba:	0004851b          	sext.w	a0,s1
    800054be:	b3f9                	j	8000528c <exec+0x9c>
    800054c0:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800054c4:	df843583          	ld	a1,-520(s0)
    800054c8:	855a                	mv	a0,s6
    800054ca:	ffffd097          	auipc	ra,0xffffd
    800054ce:	96e080e7          	jalr	-1682(ra) # 80001e38 <proc_freepagetable>
  if(ip){
    800054d2:	da0a93e3          	bnez	s5,80005278 <exec+0x88>
  return -1;
    800054d6:	557d                	li	a0,-1
    800054d8:	bb55                	j	8000528c <exec+0x9c>
    800054da:	df243c23          	sd	s2,-520(s0)
    800054de:	b7dd                	j	800054c4 <exec+0x2d4>
    800054e0:	df243c23          	sd	s2,-520(s0)
    800054e4:	b7c5                	j	800054c4 <exec+0x2d4>
    800054e6:	df243c23          	sd	s2,-520(s0)
    800054ea:	bfe9                	j	800054c4 <exec+0x2d4>
    800054ec:	df243c23          	sd	s2,-520(s0)
    800054f0:	bfd1                	j	800054c4 <exec+0x2d4>
  sz = sz1;
    800054f2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054f6:	4a81                	li	s5,0
    800054f8:	b7f1                	j	800054c4 <exec+0x2d4>
  sz = sz1;
    800054fa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054fe:	4a81                	li	s5,0
    80005500:	b7d1                	j	800054c4 <exec+0x2d4>
  sz = sz1;
    80005502:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005506:	4a81                	li	s5,0
    80005508:	bf75                	j	800054c4 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000550a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000550e:	e0843783          	ld	a5,-504(s0)
    80005512:	0017869b          	addiw	a3,a5,1
    80005516:	e0d43423          	sd	a3,-504(s0)
    8000551a:	e0043783          	ld	a5,-512(s0)
    8000551e:	0387879b          	addiw	a5,a5,56
    80005522:	e8845703          	lhu	a4,-376(s0)
    80005526:	e0e6dfe3          	bge	a3,a4,80005344 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000552a:	2781                	sext.w	a5,a5
    8000552c:	e0f43023          	sd	a5,-512(s0)
    80005530:	03800713          	li	a4,56
    80005534:	86be                	mv	a3,a5
    80005536:	e1840613          	addi	a2,s0,-488
    8000553a:	4581                	li	a1,0
    8000553c:	8556                	mv	a0,s5
    8000553e:	fffff097          	auipc	ra,0xfffff
    80005542:	a58080e7          	jalr	-1448(ra) # 80003f96 <readi>
    80005546:	03800793          	li	a5,56
    8000554a:	f6f51be3          	bne	a0,a5,800054c0 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000554e:	e1842783          	lw	a5,-488(s0)
    80005552:	4705                	li	a4,1
    80005554:	fae79de3          	bne	a5,a4,8000550e <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005558:	e4043483          	ld	s1,-448(s0)
    8000555c:	e3843783          	ld	a5,-456(s0)
    80005560:	f6f4ede3          	bltu	s1,a5,800054da <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005564:	e2843783          	ld	a5,-472(s0)
    80005568:	94be                	add	s1,s1,a5
    8000556a:	f6f4ebe3          	bltu	s1,a5,800054e0 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000556e:	de043703          	ld	a4,-544(s0)
    80005572:	8ff9                	and	a5,a5,a4
    80005574:	fbad                	bnez	a5,800054e6 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005576:	e1c42503          	lw	a0,-484(s0)
    8000557a:	00000097          	auipc	ra,0x0
    8000557e:	c5c080e7          	jalr	-932(ra) # 800051d6 <flags2perm>
    80005582:	86aa                	mv	a3,a0
    80005584:	8626                	mv	a2,s1
    80005586:	85ca                	mv	a1,s2
    80005588:	855a                	mv	a0,s6
    8000558a:	ffffc097          	auipc	ra,0xffffc
    8000558e:	058080e7          	jalr	88(ra) # 800015e2 <uvmalloc>
    80005592:	dea43c23          	sd	a0,-520(s0)
    80005596:	d939                	beqz	a0,800054ec <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005598:	e2843c03          	ld	s8,-472(s0)
    8000559c:	e2042c83          	lw	s9,-480(s0)
    800055a0:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055a4:	f60b83e3          	beqz	s7,8000550a <exec+0x31a>
    800055a8:	89de                	mv	s3,s7
    800055aa:	4481                	li	s1,0
    800055ac:	bb9d                	j	80005322 <exec+0x132>

00000000800055ae <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055ae:	7179                	addi	sp,sp,-48
    800055b0:	f406                	sd	ra,40(sp)
    800055b2:	f022                	sd	s0,32(sp)
    800055b4:	ec26                	sd	s1,24(sp)
    800055b6:	e84a                	sd	s2,16(sp)
    800055b8:	1800                	addi	s0,sp,48
    800055ba:	892e                	mv	s2,a1
    800055bc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055be:	fdc40593          	addi	a1,s0,-36
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	a8a080e7          	jalr	-1398(ra) # 8000304c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055ca:	fdc42703          	lw	a4,-36(s0)
    800055ce:	47bd                	li	a5,15
    800055d0:	02e7eb63          	bltu	a5,a4,80005606 <argfd+0x58>
    800055d4:	ffffc097          	auipc	ra,0xffffc
    800055d8:	704080e7          	jalr	1796(ra) # 80001cd8 <myproc>
    800055dc:	fdc42703          	lw	a4,-36(s0)
    800055e0:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffbd102>
    800055e4:	078e                	slli	a5,a5,0x3
    800055e6:	953e                	add	a0,a0,a5
    800055e8:	611c                	ld	a5,0(a0)
    800055ea:	c385                	beqz	a5,8000560a <argfd+0x5c>
    return -1;
  if(pfd)
    800055ec:	00090463          	beqz	s2,800055f4 <argfd+0x46>
    *pfd = fd;
    800055f0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055f4:	4501                	li	a0,0
  if(pf)
    800055f6:	c091                	beqz	s1,800055fa <argfd+0x4c>
    *pf = f;
    800055f8:	e09c                	sd	a5,0(s1)
}
    800055fa:	70a2                	ld	ra,40(sp)
    800055fc:	7402                	ld	s0,32(sp)
    800055fe:	64e2                	ld	s1,24(sp)
    80005600:	6942                	ld	s2,16(sp)
    80005602:	6145                	addi	sp,sp,48
    80005604:	8082                	ret
    return -1;
    80005606:	557d                	li	a0,-1
    80005608:	bfcd                	j	800055fa <argfd+0x4c>
    8000560a:	557d                	li	a0,-1
    8000560c:	b7fd                	j	800055fa <argfd+0x4c>

000000008000560e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000560e:	1101                	addi	sp,sp,-32
    80005610:	ec06                	sd	ra,24(sp)
    80005612:	e822                	sd	s0,16(sp)
    80005614:	e426                	sd	s1,8(sp)
    80005616:	1000                	addi	s0,sp,32
    80005618:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000561a:	ffffc097          	auipc	ra,0xffffc
    8000561e:	6be080e7          	jalr	1726(ra) # 80001cd8 <myproc>
    80005622:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005624:	0d050793          	addi	a5,a0,208
    80005628:	4501                	li	a0,0
    8000562a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000562c:	6398                	ld	a4,0(a5)
    8000562e:	cb19                	beqz	a4,80005644 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005630:	2505                	addiw	a0,a0,1
    80005632:	07a1                	addi	a5,a5,8
    80005634:	fed51ce3          	bne	a0,a3,8000562c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005638:	557d                	li	a0,-1
}
    8000563a:	60e2                	ld	ra,24(sp)
    8000563c:	6442                	ld	s0,16(sp)
    8000563e:	64a2                	ld	s1,8(sp)
    80005640:	6105                	addi	sp,sp,32
    80005642:	8082                	ret
      p->ofile[fd] = f;
    80005644:	01a50793          	addi	a5,a0,26
    80005648:	078e                	slli	a5,a5,0x3
    8000564a:	963e                	add	a2,a2,a5
    8000564c:	e204                	sd	s1,0(a2)
      return fd;
    8000564e:	b7f5                	j	8000563a <fdalloc+0x2c>

0000000080005650 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005650:	715d                	addi	sp,sp,-80
    80005652:	e486                	sd	ra,72(sp)
    80005654:	e0a2                	sd	s0,64(sp)
    80005656:	fc26                	sd	s1,56(sp)
    80005658:	f84a                	sd	s2,48(sp)
    8000565a:	f44e                	sd	s3,40(sp)
    8000565c:	f052                	sd	s4,32(sp)
    8000565e:	ec56                	sd	s5,24(sp)
    80005660:	e85a                	sd	s6,16(sp)
    80005662:	0880                	addi	s0,sp,80
    80005664:	8b2e                	mv	s6,a1
    80005666:	89b2                	mv	s3,a2
    80005668:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000566a:	fb040593          	addi	a1,s0,-80
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	e3e080e7          	jalr	-450(ra) # 800044ac <nameiparent>
    80005676:	84aa                	mv	s1,a0
    80005678:	14050f63          	beqz	a0,800057d6 <create+0x186>
    return 0;

  ilock(dp);
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	666080e7          	jalr	1638(ra) # 80003ce2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005684:	4601                	li	a2,0
    80005686:	fb040593          	addi	a1,s0,-80
    8000568a:	8526                	mv	a0,s1
    8000568c:	fffff097          	auipc	ra,0xfffff
    80005690:	b3a080e7          	jalr	-1222(ra) # 800041c6 <dirlookup>
    80005694:	8aaa                	mv	s5,a0
    80005696:	c931                	beqz	a0,800056ea <create+0x9a>
    iunlockput(dp);
    80005698:	8526                	mv	a0,s1
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	8aa080e7          	jalr	-1878(ra) # 80003f44 <iunlockput>
    ilock(ip);
    800056a2:	8556                	mv	a0,s5
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	63e080e7          	jalr	1598(ra) # 80003ce2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056ac:	000b059b          	sext.w	a1,s6
    800056b0:	4789                	li	a5,2
    800056b2:	02f59563          	bne	a1,a5,800056dc <create+0x8c>
    800056b6:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffbd12c>
    800056ba:	37f9                	addiw	a5,a5,-2
    800056bc:	17c2                	slli	a5,a5,0x30
    800056be:	93c1                	srli	a5,a5,0x30
    800056c0:	4705                	li	a4,1
    800056c2:	00f76d63          	bltu	a4,a5,800056dc <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056c6:	8556                	mv	a0,s5
    800056c8:	60a6                	ld	ra,72(sp)
    800056ca:	6406                	ld	s0,64(sp)
    800056cc:	74e2                	ld	s1,56(sp)
    800056ce:	7942                	ld	s2,48(sp)
    800056d0:	79a2                	ld	s3,40(sp)
    800056d2:	7a02                	ld	s4,32(sp)
    800056d4:	6ae2                	ld	s5,24(sp)
    800056d6:	6b42                	ld	s6,16(sp)
    800056d8:	6161                	addi	sp,sp,80
    800056da:	8082                	ret
    iunlockput(ip);
    800056dc:	8556                	mv	a0,s5
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	866080e7          	jalr	-1946(ra) # 80003f44 <iunlockput>
    return 0;
    800056e6:	4a81                	li	s5,0
    800056e8:	bff9                	j	800056c6 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800056ea:	85da                	mv	a1,s6
    800056ec:	4088                	lw	a0,0(s1)
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	456080e7          	jalr	1110(ra) # 80003b44 <ialloc>
    800056f6:	8a2a                	mv	s4,a0
    800056f8:	c539                	beqz	a0,80005746 <create+0xf6>
  ilock(ip);
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	5e8080e7          	jalr	1512(ra) # 80003ce2 <ilock>
  ip->major = major;
    80005702:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005706:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000570a:	4905                	li	s2,1
    8000570c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005710:	8552                	mv	a0,s4
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	504080e7          	jalr	1284(ra) # 80003c16 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000571a:	000b059b          	sext.w	a1,s6
    8000571e:	03258b63          	beq	a1,s2,80005754 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005722:	004a2603          	lw	a2,4(s4)
    80005726:	fb040593          	addi	a1,s0,-80
    8000572a:	8526                	mv	a0,s1
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	cb0080e7          	jalr	-848(ra) # 800043dc <dirlink>
    80005734:	06054f63          	bltz	a0,800057b2 <create+0x162>
  iunlockput(dp);
    80005738:	8526                	mv	a0,s1
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	80a080e7          	jalr	-2038(ra) # 80003f44 <iunlockput>
  return ip;
    80005742:	8ad2                	mv	s5,s4
    80005744:	b749                	j	800056c6 <create+0x76>
    iunlockput(dp);
    80005746:	8526                	mv	a0,s1
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	7fc080e7          	jalr	2044(ra) # 80003f44 <iunlockput>
    return 0;
    80005750:	8ad2                	mv	s5,s4
    80005752:	bf95                	j	800056c6 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005754:	004a2603          	lw	a2,4(s4)
    80005758:	00003597          	auipc	a1,0x3
    8000575c:	0f058593          	addi	a1,a1,240 # 80008848 <syscalls+0x2c8>
    80005760:	8552                	mv	a0,s4
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	c7a080e7          	jalr	-902(ra) # 800043dc <dirlink>
    8000576a:	04054463          	bltz	a0,800057b2 <create+0x162>
    8000576e:	40d0                	lw	a2,4(s1)
    80005770:	00003597          	auipc	a1,0x3
    80005774:	0e058593          	addi	a1,a1,224 # 80008850 <syscalls+0x2d0>
    80005778:	8552                	mv	a0,s4
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	c62080e7          	jalr	-926(ra) # 800043dc <dirlink>
    80005782:	02054863          	bltz	a0,800057b2 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005786:	004a2603          	lw	a2,4(s4)
    8000578a:	fb040593          	addi	a1,s0,-80
    8000578e:	8526                	mv	a0,s1
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	c4c080e7          	jalr	-948(ra) # 800043dc <dirlink>
    80005798:	00054d63          	bltz	a0,800057b2 <create+0x162>
    dp->nlink++;  // for ".."
    8000579c:	04a4d783          	lhu	a5,74(s1)
    800057a0:	2785                	addiw	a5,a5,1
    800057a2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	46e080e7          	jalr	1134(ra) # 80003c16 <iupdate>
    800057b0:	b761                	j	80005738 <create+0xe8>
  ip->nlink = 0;
    800057b2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057b6:	8552                	mv	a0,s4
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	45e080e7          	jalr	1118(ra) # 80003c16 <iupdate>
  iunlockput(ip);
    800057c0:	8552                	mv	a0,s4
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	782080e7          	jalr	1922(ra) # 80003f44 <iunlockput>
  iunlockput(dp);
    800057ca:	8526                	mv	a0,s1
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	778080e7          	jalr	1912(ra) # 80003f44 <iunlockput>
  return 0;
    800057d4:	bdcd                	j	800056c6 <create+0x76>
    return 0;
    800057d6:	8aaa                	mv	s5,a0
    800057d8:	b5fd                	j	800056c6 <create+0x76>

00000000800057da <sys_dup>:
{
    800057da:	7179                	addi	sp,sp,-48
    800057dc:	f406                	sd	ra,40(sp)
    800057de:	f022                	sd	s0,32(sp)
    800057e0:	ec26                	sd	s1,24(sp)
    800057e2:	e84a                	sd	s2,16(sp)
    800057e4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057e6:	fd840613          	addi	a2,s0,-40
    800057ea:	4581                	li	a1,0
    800057ec:	4501                	li	a0,0
    800057ee:	00000097          	auipc	ra,0x0
    800057f2:	dc0080e7          	jalr	-576(ra) # 800055ae <argfd>
    return -1;
    800057f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057f8:	02054363          	bltz	a0,8000581e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800057fc:	fd843903          	ld	s2,-40(s0)
    80005800:	854a                	mv	a0,s2
    80005802:	00000097          	auipc	ra,0x0
    80005806:	e0c080e7          	jalr	-500(ra) # 8000560e <fdalloc>
    8000580a:	84aa                	mv	s1,a0
    return -1;
    8000580c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000580e:	00054863          	bltz	a0,8000581e <sys_dup+0x44>
  filedup(f);
    80005812:	854a                	mv	a0,s2
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	310080e7          	jalr	784(ra) # 80004b24 <filedup>
  return fd;
    8000581c:	87a6                	mv	a5,s1
}
    8000581e:	853e                	mv	a0,a5
    80005820:	70a2                	ld	ra,40(sp)
    80005822:	7402                	ld	s0,32(sp)
    80005824:	64e2                	ld	s1,24(sp)
    80005826:	6942                	ld	s2,16(sp)
    80005828:	6145                	addi	sp,sp,48
    8000582a:	8082                	ret

000000008000582c <sys_read>:
{
    8000582c:	7179                	addi	sp,sp,-48
    8000582e:	f406                	sd	ra,40(sp)
    80005830:	f022                	sd	s0,32(sp)
    80005832:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005834:	fd840593          	addi	a1,s0,-40
    80005838:	4505                	li	a0,1
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	832080e7          	jalr	-1998(ra) # 8000306c <argaddr>
  argint(2, &n);
    80005842:	fe440593          	addi	a1,s0,-28
    80005846:	4509                	li	a0,2
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	804080e7          	jalr	-2044(ra) # 8000304c <argint>
  if(argfd(0, 0, &f) < 0)
    80005850:	fe840613          	addi	a2,s0,-24
    80005854:	4581                	li	a1,0
    80005856:	4501                	li	a0,0
    80005858:	00000097          	auipc	ra,0x0
    8000585c:	d56080e7          	jalr	-682(ra) # 800055ae <argfd>
    80005860:	87aa                	mv	a5,a0
    return -1;
    80005862:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005864:	0007cc63          	bltz	a5,8000587c <sys_read+0x50>
  return fileread(f, p, n);
    80005868:	fe442603          	lw	a2,-28(s0)
    8000586c:	fd843583          	ld	a1,-40(s0)
    80005870:	fe843503          	ld	a0,-24(s0)
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	43c080e7          	jalr	1084(ra) # 80004cb0 <fileread>
}
    8000587c:	70a2                	ld	ra,40(sp)
    8000587e:	7402                	ld	s0,32(sp)
    80005880:	6145                	addi	sp,sp,48
    80005882:	8082                	ret

0000000080005884 <sys_write>:
{
    80005884:	7179                	addi	sp,sp,-48
    80005886:	f406                	sd	ra,40(sp)
    80005888:	f022                	sd	s0,32(sp)
    8000588a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000588c:	fd840593          	addi	a1,s0,-40
    80005890:	4505                	li	a0,1
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	7da080e7          	jalr	2010(ra) # 8000306c <argaddr>
  argint(2, &n);
    8000589a:	fe440593          	addi	a1,s0,-28
    8000589e:	4509                	li	a0,2
    800058a0:	ffffd097          	auipc	ra,0xffffd
    800058a4:	7ac080e7          	jalr	1964(ra) # 8000304c <argint>
  if(argfd(0, 0, &f) < 0)
    800058a8:	fe840613          	addi	a2,s0,-24
    800058ac:	4581                	li	a1,0
    800058ae:	4501                	li	a0,0
    800058b0:	00000097          	auipc	ra,0x0
    800058b4:	cfe080e7          	jalr	-770(ra) # 800055ae <argfd>
    800058b8:	87aa                	mv	a5,a0
    return -1;
    800058ba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058bc:	0007cc63          	bltz	a5,800058d4 <sys_write+0x50>
  return filewrite(f, p, n);
    800058c0:	fe442603          	lw	a2,-28(s0)
    800058c4:	fd843583          	ld	a1,-40(s0)
    800058c8:	fe843503          	ld	a0,-24(s0)
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	4a6080e7          	jalr	1190(ra) # 80004d72 <filewrite>
}
    800058d4:	70a2                	ld	ra,40(sp)
    800058d6:	7402                	ld	s0,32(sp)
    800058d8:	6145                	addi	sp,sp,48
    800058da:	8082                	ret

00000000800058dc <sys_close>:
{
    800058dc:	1101                	addi	sp,sp,-32
    800058de:	ec06                	sd	ra,24(sp)
    800058e0:	e822                	sd	s0,16(sp)
    800058e2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058e4:	fe040613          	addi	a2,s0,-32
    800058e8:	fec40593          	addi	a1,s0,-20
    800058ec:	4501                	li	a0,0
    800058ee:	00000097          	auipc	ra,0x0
    800058f2:	cc0080e7          	jalr	-832(ra) # 800055ae <argfd>
    return -1;
    800058f6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058f8:	02054463          	bltz	a0,80005920 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058fc:	ffffc097          	auipc	ra,0xffffc
    80005900:	3dc080e7          	jalr	988(ra) # 80001cd8 <myproc>
    80005904:	fec42783          	lw	a5,-20(s0)
    80005908:	07e9                	addi	a5,a5,26
    8000590a:	078e                	slli	a5,a5,0x3
    8000590c:	953e                	add	a0,a0,a5
    8000590e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005912:	fe043503          	ld	a0,-32(s0)
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	260080e7          	jalr	608(ra) # 80004b76 <fileclose>
  return 0;
    8000591e:	4781                	li	a5,0
}
    80005920:	853e                	mv	a0,a5
    80005922:	60e2                	ld	ra,24(sp)
    80005924:	6442                	ld	s0,16(sp)
    80005926:	6105                	addi	sp,sp,32
    80005928:	8082                	ret

000000008000592a <sys_fstat>:
{
    8000592a:	1101                	addi	sp,sp,-32
    8000592c:	ec06                	sd	ra,24(sp)
    8000592e:	e822                	sd	s0,16(sp)
    80005930:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005932:	fe040593          	addi	a1,s0,-32
    80005936:	4505                	li	a0,1
    80005938:	ffffd097          	auipc	ra,0xffffd
    8000593c:	734080e7          	jalr	1844(ra) # 8000306c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005940:	fe840613          	addi	a2,s0,-24
    80005944:	4581                	li	a1,0
    80005946:	4501                	li	a0,0
    80005948:	00000097          	auipc	ra,0x0
    8000594c:	c66080e7          	jalr	-922(ra) # 800055ae <argfd>
    80005950:	87aa                	mv	a5,a0
    return -1;
    80005952:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005954:	0007ca63          	bltz	a5,80005968 <sys_fstat+0x3e>
  return filestat(f, st);
    80005958:	fe043583          	ld	a1,-32(s0)
    8000595c:	fe843503          	ld	a0,-24(s0)
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	2de080e7          	jalr	734(ra) # 80004c3e <filestat>
}
    80005968:	60e2                	ld	ra,24(sp)
    8000596a:	6442                	ld	s0,16(sp)
    8000596c:	6105                	addi	sp,sp,32
    8000596e:	8082                	ret

0000000080005970 <sys_link>:
{
    80005970:	7169                	addi	sp,sp,-304
    80005972:	f606                	sd	ra,296(sp)
    80005974:	f222                	sd	s0,288(sp)
    80005976:	ee26                	sd	s1,280(sp)
    80005978:	ea4a                	sd	s2,272(sp)
    8000597a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000597c:	08000613          	li	a2,128
    80005980:	ed040593          	addi	a1,s0,-304
    80005984:	4501                	li	a0,0
    80005986:	ffffd097          	auipc	ra,0xffffd
    8000598a:	706080e7          	jalr	1798(ra) # 8000308c <argstr>
    return -1;
    8000598e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005990:	10054e63          	bltz	a0,80005aac <sys_link+0x13c>
    80005994:	08000613          	li	a2,128
    80005998:	f5040593          	addi	a1,s0,-176
    8000599c:	4505                	li	a0,1
    8000599e:	ffffd097          	auipc	ra,0xffffd
    800059a2:	6ee080e7          	jalr	1774(ra) # 8000308c <argstr>
    return -1;
    800059a6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059a8:	10054263          	bltz	a0,80005aac <sys_link+0x13c>
  begin_op();
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	d02080e7          	jalr	-766(ra) # 800046ae <begin_op>
  if((ip = namei(old)) == 0){
    800059b4:	ed040513          	addi	a0,s0,-304
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	ad6080e7          	jalr	-1322(ra) # 8000448e <namei>
    800059c0:	84aa                	mv	s1,a0
    800059c2:	c551                	beqz	a0,80005a4e <sys_link+0xde>
  ilock(ip);
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	31e080e7          	jalr	798(ra) # 80003ce2 <ilock>
  if(ip->type == T_DIR){
    800059cc:	04449703          	lh	a4,68(s1)
    800059d0:	4785                	li	a5,1
    800059d2:	08f70463          	beq	a4,a5,80005a5a <sys_link+0xea>
  ip->nlink++;
    800059d6:	04a4d783          	lhu	a5,74(s1)
    800059da:	2785                	addiw	a5,a5,1
    800059dc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059e0:	8526                	mv	a0,s1
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	234080e7          	jalr	564(ra) # 80003c16 <iupdate>
  iunlock(ip);
    800059ea:	8526                	mv	a0,s1
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	3b8080e7          	jalr	952(ra) # 80003da4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059f4:	fd040593          	addi	a1,s0,-48
    800059f8:	f5040513          	addi	a0,s0,-176
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	ab0080e7          	jalr	-1360(ra) # 800044ac <nameiparent>
    80005a04:	892a                	mv	s2,a0
    80005a06:	c935                	beqz	a0,80005a7a <sys_link+0x10a>
  ilock(dp);
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	2da080e7          	jalr	730(ra) # 80003ce2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a10:	00092703          	lw	a4,0(s2)
    80005a14:	409c                	lw	a5,0(s1)
    80005a16:	04f71d63          	bne	a4,a5,80005a70 <sys_link+0x100>
    80005a1a:	40d0                	lw	a2,4(s1)
    80005a1c:	fd040593          	addi	a1,s0,-48
    80005a20:	854a                	mv	a0,s2
    80005a22:	fffff097          	auipc	ra,0xfffff
    80005a26:	9ba080e7          	jalr	-1606(ra) # 800043dc <dirlink>
    80005a2a:	04054363          	bltz	a0,80005a70 <sys_link+0x100>
  iunlockput(dp);
    80005a2e:	854a                	mv	a0,s2
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	514080e7          	jalr	1300(ra) # 80003f44 <iunlockput>
  iput(ip);
    80005a38:	8526                	mv	a0,s1
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	462080e7          	jalr	1122(ra) # 80003e9c <iput>
  end_op();
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	cea080e7          	jalr	-790(ra) # 8000472c <end_op>
  return 0;
    80005a4a:	4781                	li	a5,0
    80005a4c:	a085                	j	80005aac <sys_link+0x13c>
    end_op();
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	cde080e7          	jalr	-802(ra) # 8000472c <end_op>
    return -1;
    80005a56:	57fd                	li	a5,-1
    80005a58:	a891                	j	80005aac <sys_link+0x13c>
    iunlockput(ip);
    80005a5a:	8526                	mv	a0,s1
    80005a5c:	ffffe097          	auipc	ra,0xffffe
    80005a60:	4e8080e7          	jalr	1256(ra) # 80003f44 <iunlockput>
    end_op();
    80005a64:	fffff097          	auipc	ra,0xfffff
    80005a68:	cc8080e7          	jalr	-824(ra) # 8000472c <end_op>
    return -1;
    80005a6c:	57fd                	li	a5,-1
    80005a6e:	a83d                	j	80005aac <sys_link+0x13c>
    iunlockput(dp);
    80005a70:	854a                	mv	a0,s2
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	4d2080e7          	jalr	1234(ra) # 80003f44 <iunlockput>
  ilock(ip);
    80005a7a:	8526                	mv	a0,s1
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	266080e7          	jalr	614(ra) # 80003ce2 <ilock>
  ip->nlink--;
    80005a84:	04a4d783          	lhu	a5,74(s1)
    80005a88:	37fd                	addiw	a5,a5,-1
    80005a8a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a8e:	8526                	mv	a0,s1
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	186080e7          	jalr	390(ra) # 80003c16 <iupdate>
  iunlockput(ip);
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	4aa080e7          	jalr	1194(ra) # 80003f44 <iunlockput>
  end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	c8a080e7          	jalr	-886(ra) # 8000472c <end_op>
  return -1;
    80005aaa:	57fd                	li	a5,-1
}
    80005aac:	853e                	mv	a0,a5
    80005aae:	70b2                	ld	ra,296(sp)
    80005ab0:	7412                	ld	s0,288(sp)
    80005ab2:	64f2                	ld	s1,280(sp)
    80005ab4:	6952                	ld	s2,272(sp)
    80005ab6:	6155                	addi	sp,sp,304
    80005ab8:	8082                	ret

0000000080005aba <sys_unlink>:
{
    80005aba:	7151                	addi	sp,sp,-240
    80005abc:	f586                	sd	ra,232(sp)
    80005abe:	f1a2                	sd	s0,224(sp)
    80005ac0:	eda6                	sd	s1,216(sp)
    80005ac2:	e9ca                	sd	s2,208(sp)
    80005ac4:	e5ce                	sd	s3,200(sp)
    80005ac6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005ac8:	08000613          	li	a2,128
    80005acc:	f3040593          	addi	a1,s0,-208
    80005ad0:	4501                	li	a0,0
    80005ad2:	ffffd097          	auipc	ra,0xffffd
    80005ad6:	5ba080e7          	jalr	1466(ra) # 8000308c <argstr>
    80005ada:	18054163          	bltz	a0,80005c5c <sys_unlink+0x1a2>
  begin_op();
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	bd0080e7          	jalr	-1072(ra) # 800046ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ae6:	fb040593          	addi	a1,s0,-80
    80005aea:	f3040513          	addi	a0,s0,-208
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	9be080e7          	jalr	-1602(ra) # 800044ac <nameiparent>
    80005af6:	84aa                	mv	s1,a0
    80005af8:	c979                	beqz	a0,80005bce <sys_unlink+0x114>
  ilock(dp);
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	1e8080e7          	jalr	488(ra) # 80003ce2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b02:	00003597          	auipc	a1,0x3
    80005b06:	d4658593          	addi	a1,a1,-698 # 80008848 <syscalls+0x2c8>
    80005b0a:	fb040513          	addi	a0,s0,-80
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	69e080e7          	jalr	1694(ra) # 800041ac <namecmp>
    80005b16:	14050a63          	beqz	a0,80005c6a <sys_unlink+0x1b0>
    80005b1a:	00003597          	auipc	a1,0x3
    80005b1e:	d3658593          	addi	a1,a1,-714 # 80008850 <syscalls+0x2d0>
    80005b22:	fb040513          	addi	a0,s0,-80
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	686080e7          	jalr	1670(ra) # 800041ac <namecmp>
    80005b2e:	12050e63          	beqz	a0,80005c6a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b32:	f2c40613          	addi	a2,s0,-212
    80005b36:	fb040593          	addi	a1,s0,-80
    80005b3a:	8526                	mv	a0,s1
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	68a080e7          	jalr	1674(ra) # 800041c6 <dirlookup>
    80005b44:	892a                	mv	s2,a0
    80005b46:	12050263          	beqz	a0,80005c6a <sys_unlink+0x1b0>
  ilock(ip);
    80005b4a:	ffffe097          	auipc	ra,0xffffe
    80005b4e:	198080e7          	jalr	408(ra) # 80003ce2 <ilock>
  if(ip->nlink < 1)
    80005b52:	04a91783          	lh	a5,74(s2)
    80005b56:	08f05263          	blez	a5,80005bda <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b5a:	04491703          	lh	a4,68(s2)
    80005b5e:	4785                	li	a5,1
    80005b60:	08f70563          	beq	a4,a5,80005bea <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b64:	4641                	li	a2,16
    80005b66:	4581                	li	a1,0
    80005b68:	fc040513          	addi	a0,s0,-64
    80005b6c:	ffffb097          	auipc	ra,0xffffb
    80005b70:	338080e7          	jalr	824(ra) # 80000ea4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b74:	4741                	li	a4,16
    80005b76:	f2c42683          	lw	a3,-212(s0)
    80005b7a:	fc040613          	addi	a2,s0,-64
    80005b7e:	4581                	li	a1,0
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	50c080e7          	jalr	1292(ra) # 8000408e <writei>
    80005b8a:	47c1                	li	a5,16
    80005b8c:	0af51563          	bne	a0,a5,80005c36 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b90:	04491703          	lh	a4,68(s2)
    80005b94:	4785                	li	a5,1
    80005b96:	0af70863          	beq	a4,a5,80005c46 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b9a:	8526                	mv	a0,s1
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	3a8080e7          	jalr	936(ra) # 80003f44 <iunlockput>
  ip->nlink--;
    80005ba4:	04a95783          	lhu	a5,74(s2)
    80005ba8:	37fd                	addiw	a5,a5,-1
    80005baa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005bae:	854a                	mv	a0,s2
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	066080e7          	jalr	102(ra) # 80003c16 <iupdate>
  iunlockput(ip);
    80005bb8:	854a                	mv	a0,s2
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	38a080e7          	jalr	906(ra) # 80003f44 <iunlockput>
  end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	b6a080e7          	jalr	-1174(ra) # 8000472c <end_op>
  return 0;
    80005bca:	4501                	li	a0,0
    80005bcc:	a84d                	j	80005c7e <sys_unlink+0x1c4>
    end_op();
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	b5e080e7          	jalr	-1186(ra) # 8000472c <end_op>
    return -1;
    80005bd6:	557d                	li	a0,-1
    80005bd8:	a05d                	j	80005c7e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005bda:	00003517          	auipc	a0,0x3
    80005bde:	c7e50513          	addi	a0,a0,-898 # 80008858 <syscalls+0x2d8>
    80005be2:	ffffb097          	auipc	ra,0xffffb
    80005be6:	95e080e7          	jalr	-1698(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bea:	04c92703          	lw	a4,76(s2)
    80005bee:	02000793          	li	a5,32
    80005bf2:	f6e7f9e3          	bgeu	a5,a4,80005b64 <sys_unlink+0xaa>
    80005bf6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bfa:	4741                	li	a4,16
    80005bfc:	86ce                	mv	a3,s3
    80005bfe:	f1840613          	addi	a2,s0,-232
    80005c02:	4581                	li	a1,0
    80005c04:	854a                	mv	a0,s2
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	390080e7          	jalr	912(ra) # 80003f96 <readi>
    80005c0e:	47c1                	li	a5,16
    80005c10:	00f51b63          	bne	a0,a5,80005c26 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c14:	f1845783          	lhu	a5,-232(s0)
    80005c18:	e7a1                	bnez	a5,80005c60 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c1a:	29c1                	addiw	s3,s3,16
    80005c1c:	04c92783          	lw	a5,76(s2)
    80005c20:	fcf9ede3          	bltu	s3,a5,80005bfa <sys_unlink+0x140>
    80005c24:	b781                	j	80005b64 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c26:	00003517          	auipc	a0,0x3
    80005c2a:	c4a50513          	addi	a0,a0,-950 # 80008870 <syscalls+0x2f0>
    80005c2e:	ffffb097          	auipc	ra,0xffffb
    80005c32:	912080e7          	jalr	-1774(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005c36:	00003517          	auipc	a0,0x3
    80005c3a:	c5250513          	addi	a0,a0,-942 # 80008888 <syscalls+0x308>
    80005c3e:	ffffb097          	auipc	ra,0xffffb
    80005c42:	902080e7          	jalr	-1790(ra) # 80000540 <panic>
    dp->nlink--;
    80005c46:	04a4d783          	lhu	a5,74(s1)
    80005c4a:	37fd                	addiw	a5,a5,-1
    80005c4c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c50:	8526                	mv	a0,s1
    80005c52:	ffffe097          	auipc	ra,0xffffe
    80005c56:	fc4080e7          	jalr	-60(ra) # 80003c16 <iupdate>
    80005c5a:	b781                	j	80005b9a <sys_unlink+0xe0>
    return -1;
    80005c5c:	557d                	li	a0,-1
    80005c5e:	a005                	j	80005c7e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c60:	854a                	mv	a0,s2
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	2e2080e7          	jalr	738(ra) # 80003f44 <iunlockput>
  iunlockput(dp);
    80005c6a:	8526                	mv	a0,s1
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	2d8080e7          	jalr	728(ra) # 80003f44 <iunlockput>
  end_op();
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	ab8080e7          	jalr	-1352(ra) # 8000472c <end_op>
  return -1;
    80005c7c:	557d                	li	a0,-1
}
    80005c7e:	70ae                	ld	ra,232(sp)
    80005c80:	740e                	ld	s0,224(sp)
    80005c82:	64ee                	ld	s1,216(sp)
    80005c84:	694e                	ld	s2,208(sp)
    80005c86:	69ae                	ld	s3,200(sp)
    80005c88:	616d                	addi	sp,sp,240
    80005c8a:	8082                	ret

0000000080005c8c <sys_open>:

uint64
sys_open(void)
{
    80005c8c:	7131                	addi	sp,sp,-192
    80005c8e:	fd06                	sd	ra,184(sp)
    80005c90:	f922                	sd	s0,176(sp)
    80005c92:	f526                	sd	s1,168(sp)
    80005c94:	f14a                	sd	s2,160(sp)
    80005c96:	ed4e                	sd	s3,152(sp)
    80005c98:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c9a:	f4c40593          	addi	a1,s0,-180
    80005c9e:	4505                	li	a0,1
    80005ca0:	ffffd097          	auipc	ra,0xffffd
    80005ca4:	3ac080e7          	jalr	940(ra) # 8000304c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ca8:	08000613          	li	a2,128
    80005cac:	f5040593          	addi	a1,s0,-176
    80005cb0:	4501                	li	a0,0
    80005cb2:	ffffd097          	auipc	ra,0xffffd
    80005cb6:	3da080e7          	jalr	986(ra) # 8000308c <argstr>
    80005cba:	87aa                	mv	a5,a0
    return -1;
    80005cbc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005cbe:	0a07c963          	bltz	a5,80005d70 <sys_open+0xe4>

  begin_op();
    80005cc2:	fffff097          	auipc	ra,0xfffff
    80005cc6:	9ec080e7          	jalr	-1556(ra) # 800046ae <begin_op>

  if(omode & O_CREATE){
    80005cca:	f4c42783          	lw	a5,-180(s0)
    80005cce:	2007f793          	andi	a5,a5,512
    80005cd2:	cfc5                	beqz	a5,80005d8a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cd4:	4681                	li	a3,0
    80005cd6:	4601                	li	a2,0
    80005cd8:	4589                	li	a1,2
    80005cda:	f5040513          	addi	a0,s0,-176
    80005cde:	00000097          	auipc	ra,0x0
    80005ce2:	972080e7          	jalr	-1678(ra) # 80005650 <create>
    80005ce6:	84aa                	mv	s1,a0
    if(ip == 0){
    80005ce8:	c959                	beqz	a0,80005d7e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cea:	04449703          	lh	a4,68(s1)
    80005cee:	478d                	li	a5,3
    80005cf0:	00f71763          	bne	a4,a5,80005cfe <sys_open+0x72>
    80005cf4:	0464d703          	lhu	a4,70(s1)
    80005cf8:	47a5                	li	a5,9
    80005cfa:	0ce7ed63          	bltu	a5,a4,80005dd4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	dbc080e7          	jalr	-580(ra) # 80004aba <filealloc>
    80005d06:	89aa                	mv	s3,a0
    80005d08:	10050363          	beqz	a0,80005e0e <sys_open+0x182>
    80005d0c:	00000097          	auipc	ra,0x0
    80005d10:	902080e7          	jalr	-1790(ra) # 8000560e <fdalloc>
    80005d14:	892a                	mv	s2,a0
    80005d16:	0e054763          	bltz	a0,80005e04 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d1a:	04449703          	lh	a4,68(s1)
    80005d1e:	478d                	li	a5,3
    80005d20:	0cf70563          	beq	a4,a5,80005dea <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d24:	4789                	li	a5,2
    80005d26:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d2a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d2e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d32:	f4c42783          	lw	a5,-180(s0)
    80005d36:	0017c713          	xori	a4,a5,1
    80005d3a:	8b05                	andi	a4,a4,1
    80005d3c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d40:	0037f713          	andi	a4,a5,3
    80005d44:	00e03733          	snez	a4,a4
    80005d48:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d4c:	4007f793          	andi	a5,a5,1024
    80005d50:	c791                	beqz	a5,80005d5c <sys_open+0xd0>
    80005d52:	04449703          	lh	a4,68(s1)
    80005d56:	4789                	li	a5,2
    80005d58:	0af70063          	beq	a4,a5,80005df8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d5c:	8526                	mv	a0,s1
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	046080e7          	jalr	70(ra) # 80003da4 <iunlock>
  end_op();
    80005d66:	fffff097          	auipc	ra,0xfffff
    80005d6a:	9c6080e7          	jalr	-1594(ra) # 8000472c <end_op>

  return fd;
    80005d6e:	854a                	mv	a0,s2
}
    80005d70:	70ea                	ld	ra,184(sp)
    80005d72:	744a                	ld	s0,176(sp)
    80005d74:	74aa                	ld	s1,168(sp)
    80005d76:	790a                	ld	s2,160(sp)
    80005d78:	69ea                	ld	s3,152(sp)
    80005d7a:	6129                	addi	sp,sp,192
    80005d7c:	8082                	ret
      end_op();
    80005d7e:	fffff097          	auipc	ra,0xfffff
    80005d82:	9ae080e7          	jalr	-1618(ra) # 8000472c <end_op>
      return -1;
    80005d86:	557d                	li	a0,-1
    80005d88:	b7e5                	j	80005d70 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d8a:	f5040513          	addi	a0,s0,-176
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	700080e7          	jalr	1792(ra) # 8000448e <namei>
    80005d96:	84aa                	mv	s1,a0
    80005d98:	c905                	beqz	a0,80005dc8 <sys_open+0x13c>
    ilock(ip);
    80005d9a:	ffffe097          	auipc	ra,0xffffe
    80005d9e:	f48080e7          	jalr	-184(ra) # 80003ce2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005da2:	04449703          	lh	a4,68(s1)
    80005da6:	4785                	li	a5,1
    80005da8:	f4f711e3          	bne	a4,a5,80005cea <sys_open+0x5e>
    80005dac:	f4c42783          	lw	a5,-180(s0)
    80005db0:	d7b9                	beqz	a5,80005cfe <sys_open+0x72>
      iunlockput(ip);
    80005db2:	8526                	mv	a0,s1
    80005db4:	ffffe097          	auipc	ra,0xffffe
    80005db8:	190080e7          	jalr	400(ra) # 80003f44 <iunlockput>
      end_op();
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	970080e7          	jalr	-1680(ra) # 8000472c <end_op>
      return -1;
    80005dc4:	557d                	li	a0,-1
    80005dc6:	b76d                	j	80005d70 <sys_open+0xe4>
      end_op();
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	964080e7          	jalr	-1692(ra) # 8000472c <end_op>
      return -1;
    80005dd0:	557d                	li	a0,-1
    80005dd2:	bf79                	j	80005d70 <sys_open+0xe4>
    iunlockput(ip);
    80005dd4:	8526                	mv	a0,s1
    80005dd6:	ffffe097          	auipc	ra,0xffffe
    80005dda:	16e080e7          	jalr	366(ra) # 80003f44 <iunlockput>
    end_op();
    80005dde:	fffff097          	auipc	ra,0xfffff
    80005de2:	94e080e7          	jalr	-1714(ra) # 8000472c <end_op>
    return -1;
    80005de6:	557d                	li	a0,-1
    80005de8:	b761                	j	80005d70 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005dea:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005dee:	04649783          	lh	a5,70(s1)
    80005df2:	02f99223          	sh	a5,36(s3)
    80005df6:	bf25                	j	80005d2e <sys_open+0xa2>
    itrunc(ip);
    80005df8:	8526                	mv	a0,s1
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	ff6080e7          	jalr	-10(ra) # 80003df0 <itrunc>
    80005e02:	bfa9                	j	80005d5c <sys_open+0xd0>
      fileclose(f);
    80005e04:	854e                	mv	a0,s3
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	d70080e7          	jalr	-656(ra) # 80004b76 <fileclose>
    iunlockput(ip);
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	134080e7          	jalr	308(ra) # 80003f44 <iunlockput>
    end_op();
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	914080e7          	jalr	-1772(ra) # 8000472c <end_op>
    return -1;
    80005e20:	557d                	li	a0,-1
    80005e22:	b7b9                	j	80005d70 <sys_open+0xe4>

0000000080005e24 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e24:	7175                	addi	sp,sp,-144
    80005e26:	e506                	sd	ra,136(sp)
    80005e28:	e122                	sd	s0,128(sp)
    80005e2a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e2c:	fffff097          	auipc	ra,0xfffff
    80005e30:	882080e7          	jalr	-1918(ra) # 800046ae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e34:	08000613          	li	a2,128
    80005e38:	f7040593          	addi	a1,s0,-144
    80005e3c:	4501                	li	a0,0
    80005e3e:	ffffd097          	auipc	ra,0xffffd
    80005e42:	24e080e7          	jalr	590(ra) # 8000308c <argstr>
    80005e46:	02054963          	bltz	a0,80005e78 <sys_mkdir+0x54>
    80005e4a:	4681                	li	a3,0
    80005e4c:	4601                	li	a2,0
    80005e4e:	4585                	li	a1,1
    80005e50:	f7040513          	addi	a0,s0,-144
    80005e54:	fffff097          	auipc	ra,0xfffff
    80005e58:	7fc080e7          	jalr	2044(ra) # 80005650 <create>
    80005e5c:	cd11                	beqz	a0,80005e78 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	0e6080e7          	jalr	230(ra) # 80003f44 <iunlockput>
  end_op();
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	8c6080e7          	jalr	-1850(ra) # 8000472c <end_op>
  return 0;
    80005e6e:	4501                	li	a0,0
}
    80005e70:	60aa                	ld	ra,136(sp)
    80005e72:	640a                	ld	s0,128(sp)
    80005e74:	6149                	addi	sp,sp,144
    80005e76:	8082                	ret
    end_op();
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	8b4080e7          	jalr	-1868(ra) # 8000472c <end_op>
    return -1;
    80005e80:	557d                	li	a0,-1
    80005e82:	b7fd                	j	80005e70 <sys_mkdir+0x4c>

0000000080005e84 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e84:	7135                	addi	sp,sp,-160
    80005e86:	ed06                	sd	ra,152(sp)
    80005e88:	e922                	sd	s0,144(sp)
    80005e8a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e8c:	fffff097          	auipc	ra,0xfffff
    80005e90:	822080e7          	jalr	-2014(ra) # 800046ae <begin_op>
  argint(1, &major);
    80005e94:	f6c40593          	addi	a1,s0,-148
    80005e98:	4505                	li	a0,1
    80005e9a:	ffffd097          	auipc	ra,0xffffd
    80005e9e:	1b2080e7          	jalr	434(ra) # 8000304c <argint>
  argint(2, &minor);
    80005ea2:	f6840593          	addi	a1,s0,-152
    80005ea6:	4509                	li	a0,2
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	1a4080e7          	jalr	420(ra) # 8000304c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eb0:	08000613          	li	a2,128
    80005eb4:	f7040593          	addi	a1,s0,-144
    80005eb8:	4501                	li	a0,0
    80005eba:	ffffd097          	auipc	ra,0xffffd
    80005ebe:	1d2080e7          	jalr	466(ra) # 8000308c <argstr>
    80005ec2:	02054b63          	bltz	a0,80005ef8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ec6:	f6841683          	lh	a3,-152(s0)
    80005eca:	f6c41603          	lh	a2,-148(s0)
    80005ece:	458d                	li	a1,3
    80005ed0:	f7040513          	addi	a0,s0,-144
    80005ed4:	fffff097          	auipc	ra,0xfffff
    80005ed8:	77c080e7          	jalr	1916(ra) # 80005650 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005edc:	cd11                	beqz	a0,80005ef8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	066080e7          	jalr	102(ra) # 80003f44 <iunlockput>
  end_op();
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	846080e7          	jalr	-1978(ra) # 8000472c <end_op>
  return 0;
    80005eee:	4501                	li	a0,0
}
    80005ef0:	60ea                	ld	ra,152(sp)
    80005ef2:	644a                	ld	s0,144(sp)
    80005ef4:	610d                	addi	sp,sp,160
    80005ef6:	8082                	ret
    end_op();
    80005ef8:	fffff097          	auipc	ra,0xfffff
    80005efc:	834080e7          	jalr	-1996(ra) # 8000472c <end_op>
    return -1;
    80005f00:	557d                	li	a0,-1
    80005f02:	b7fd                	j	80005ef0 <sys_mknod+0x6c>

0000000080005f04 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f04:	7135                	addi	sp,sp,-160
    80005f06:	ed06                	sd	ra,152(sp)
    80005f08:	e922                	sd	s0,144(sp)
    80005f0a:	e526                	sd	s1,136(sp)
    80005f0c:	e14a                	sd	s2,128(sp)
    80005f0e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f10:	ffffc097          	auipc	ra,0xffffc
    80005f14:	dc8080e7          	jalr	-568(ra) # 80001cd8 <myproc>
    80005f18:	892a                	mv	s2,a0
  
  begin_op();
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	794080e7          	jalr	1940(ra) # 800046ae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f22:	08000613          	li	a2,128
    80005f26:	f6040593          	addi	a1,s0,-160
    80005f2a:	4501                	li	a0,0
    80005f2c:	ffffd097          	auipc	ra,0xffffd
    80005f30:	160080e7          	jalr	352(ra) # 8000308c <argstr>
    80005f34:	04054b63          	bltz	a0,80005f8a <sys_chdir+0x86>
    80005f38:	f6040513          	addi	a0,s0,-160
    80005f3c:	ffffe097          	auipc	ra,0xffffe
    80005f40:	552080e7          	jalr	1362(ra) # 8000448e <namei>
    80005f44:	84aa                	mv	s1,a0
    80005f46:	c131                	beqz	a0,80005f8a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f48:	ffffe097          	auipc	ra,0xffffe
    80005f4c:	d9a080e7          	jalr	-614(ra) # 80003ce2 <ilock>
  if(ip->type != T_DIR){
    80005f50:	04449703          	lh	a4,68(s1)
    80005f54:	4785                	li	a5,1
    80005f56:	04f71063          	bne	a4,a5,80005f96 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f5a:	8526                	mv	a0,s1
    80005f5c:	ffffe097          	auipc	ra,0xffffe
    80005f60:	e48080e7          	jalr	-440(ra) # 80003da4 <iunlock>
  iput(p->cwd);
    80005f64:	15093503          	ld	a0,336(s2)
    80005f68:	ffffe097          	auipc	ra,0xffffe
    80005f6c:	f34080e7          	jalr	-204(ra) # 80003e9c <iput>
  end_op();
    80005f70:	ffffe097          	auipc	ra,0xffffe
    80005f74:	7bc080e7          	jalr	1980(ra) # 8000472c <end_op>
  p->cwd = ip;
    80005f78:	14993823          	sd	s1,336(s2)
  return 0;
    80005f7c:	4501                	li	a0,0
}
    80005f7e:	60ea                	ld	ra,152(sp)
    80005f80:	644a                	ld	s0,144(sp)
    80005f82:	64aa                	ld	s1,136(sp)
    80005f84:	690a                	ld	s2,128(sp)
    80005f86:	610d                	addi	sp,sp,160
    80005f88:	8082                	ret
    end_op();
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	7a2080e7          	jalr	1954(ra) # 8000472c <end_op>
    return -1;
    80005f92:	557d                	li	a0,-1
    80005f94:	b7ed                	j	80005f7e <sys_chdir+0x7a>
    iunlockput(ip);
    80005f96:	8526                	mv	a0,s1
    80005f98:	ffffe097          	auipc	ra,0xffffe
    80005f9c:	fac080e7          	jalr	-84(ra) # 80003f44 <iunlockput>
    end_op();
    80005fa0:	ffffe097          	auipc	ra,0xffffe
    80005fa4:	78c080e7          	jalr	1932(ra) # 8000472c <end_op>
    return -1;
    80005fa8:	557d                	li	a0,-1
    80005faa:	bfd1                	j	80005f7e <sys_chdir+0x7a>

0000000080005fac <sys_exec>:

uint64
sys_exec(void)
{
    80005fac:	7145                	addi	sp,sp,-464
    80005fae:	e786                	sd	ra,456(sp)
    80005fb0:	e3a2                	sd	s0,448(sp)
    80005fb2:	ff26                	sd	s1,440(sp)
    80005fb4:	fb4a                	sd	s2,432(sp)
    80005fb6:	f74e                	sd	s3,424(sp)
    80005fb8:	f352                	sd	s4,416(sp)
    80005fba:	ef56                	sd	s5,408(sp)
    80005fbc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005fbe:	e3840593          	addi	a1,s0,-456
    80005fc2:	4505                	li	a0,1
    80005fc4:	ffffd097          	auipc	ra,0xffffd
    80005fc8:	0a8080e7          	jalr	168(ra) # 8000306c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005fcc:	08000613          	li	a2,128
    80005fd0:	f4040593          	addi	a1,s0,-192
    80005fd4:	4501                	li	a0,0
    80005fd6:	ffffd097          	auipc	ra,0xffffd
    80005fda:	0b6080e7          	jalr	182(ra) # 8000308c <argstr>
    80005fde:	87aa                	mv	a5,a0
    return -1;
    80005fe0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005fe2:	0c07c363          	bltz	a5,800060a8 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005fe6:	10000613          	li	a2,256
    80005fea:	4581                	li	a1,0
    80005fec:	e4040513          	addi	a0,s0,-448
    80005ff0:	ffffb097          	auipc	ra,0xffffb
    80005ff4:	eb4080e7          	jalr	-332(ra) # 80000ea4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ff8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ffc:	89a6                	mv	s3,s1
    80005ffe:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006000:	02000a13          	li	s4,32
    80006004:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006008:	00391513          	slli	a0,s2,0x3
    8000600c:	e3040593          	addi	a1,s0,-464
    80006010:	e3843783          	ld	a5,-456(s0)
    80006014:	953e                	add	a0,a0,a5
    80006016:	ffffd097          	auipc	ra,0xffffd
    8000601a:	f98080e7          	jalr	-104(ra) # 80002fae <fetchaddr>
    8000601e:	02054a63          	bltz	a0,80006052 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006022:	e3043783          	ld	a5,-464(s0)
    80006026:	c3b9                	beqz	a5,8000606c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006028:	ffffb097          	auipc	ra,0xffffb
    8000602c:	bf6080e7          	jalr	-1034(ra) # 80000c1e <kalloc>
    80006030:	85aa                	mv	a1,a0
    80006032:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006036:	cd11                	beqz	a0,80006052 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006038:	6605                	lui	a2,0x1
    8000603a:	e3043503          	ld	a0,-464(s0)
    8000603e:	ffffd097          	auipc	ra,0xffffd
    80006042:	fc2080e7          	jalr	-62(ra) # 80003000 <fetchstr>
    80006046:	00054663          	bltz	a0,80006052 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000604a:	0905                	addi	s2,s2,1
    8000604c:	09a1                	addi	s3,s3,8
    8000604e:	fb491be3          	bne	s2,s4,80006004 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006052:	f4040913          	addi	s2,s0,-192
    80006056:	6088                	ld	a0,0(s1)
    80006058:	c539                	beqz	a0,800060a6 <sys_exec+0xfa>
    kfree(argv[i]);
    8000605a:	ffffb097          	auipc	ra,0xffffb
    8000605e:	9d2080e7          	jalr	-1582(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006062:	04a1                	addi	s1,s1,8
    80006064:	ff2499e3          	bne	s1,s2,80006056 <sys_exec+0xaa>
  return -1;
    80006068:	557d                	li	a0,-1
    8000606a:	a83d                	j	800060a8 <sys_exec+0xfc>
      argv[i] = 0;
    8000606c:	0a8e                	slli	s5,s5,0x3
    8000606e:	fc0a8793          	addi	a5,s5,-64
    80006072:	00878ab3          	add	s5,a5,s0
    80006076:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000607a:	e4040593          	addi	a1,s0,-448
    8000607e:	f4040513          	addi	a0,s0,-192
    80006082:	fffff097          	auipc	ra,0xfffff
    80006086:	16e080e7          	jalr	366(ra) # 800051f0 <exec>
    8000608a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000608c:	f4040993          	addi	s3,s0,-192
    80006090:	6088                	ld	a0,0(s1)
    80006092:	c901                	beqz	a0,800060a2 <sys_exec+0xf6>
    kfree(argv[i]);
    80006094:	ffffb097          	auipc	ra,0xffffb
    80006098:	998080e7          	jalr	-1640(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000609c:	04a1                	addi	s1,s1,8
    8000609e:	ff3499e3          	bne	s1,s3,80006090 <sys_exec+0xe4>
  return ret;
    800060a2:	854a                	mv	a0,s2
    800060a4:	a011                	j	800060a8 <sys_exec+0xfc>
  return -1;
    800060a6:	557d                	li	a0,-1
}
    800060a8:	60be                	ld	ra,456(sp)
    800060aa:	641e                	ld	s0,448(sp)
    800060ac:	74fa                	ld	s1,440(sp)
    800060ae:	795a                	ld	s2,432(sp)
    800060b0:	79ba                	ld	s3,424(sp)
    800060b2:	7a1a                	ld	s4,416(sp)
    800060b4:	6afa                	ld	s5,408(sp)
    800060b6:	6179                	addi	sp,sp,464
    800060b8:	8082                	ret

00000000800060ba <sys_pipe>:

uint64
sys_pipe(void)
{
    800060ba:	7139                	addi	sp,sp,-64
    800060bc:	fc06                	sd	ra,56(sp)
    800060be:	f822                	sd	s0,48(sp)
    800060c0:	f426                	sd	s1,40(sp)
    800060c2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060c4:	ffffc097          	auipc	ra,0xffffc
    800060c8:	c14080e7          	jalr	-1004(ra) # 80001cd8 <myproc>
    800060cc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800060ce:	fd840593          	addi	a1,s0,-40
    800060d2:	4501                	li	a0,0
    800060d4:	ffffd097          	auipc	ra,0xffffd
    800060d8:	f98080e7          	jalr	-104(ra) # 8000306c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800060dc:	fc840593          	addi	a1,s0,-56
    800060e0:	fd040513          	addi	a0,s0,-48
    800060e4:	fffff097          	auipc	ra,0xfffff
    800060e8:	dc2080e7          	jalr	-574(ra) # 80004ea6 <pipealloc>
    return -1;
    800060ec:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060ee:	0c054463          	bltz	a0,800061b6 <sys_pipe+0xfc>
  fd0 = -1;
    800060f2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060f6:	fd043503          	ld	a0,-48(s0)
    800060fa:	fffff097          	auipc	ra,0xfffff
    800060fe:	514080e7          	jalr	1300(ra) # 8000560e <fdalloc>
    80006102:	fca42223          	sw	a0,-60(s0)
    80006106:	08054b63          	bltz	a0,8000619c <sys_pipe+0xe2>
    8000610a:	fc843503          	ld	a0,-56(s0)
    8000610e:	fffff097          	auipc	ra,0xfffff
    80006112:	500080e7          	jalr	1280(ra) # 8000560e <fdalloc>
    80006116:	fca42023          	sw	a0,-64(s0)
    8000611a:	06054863          	bltz	a0,8000618a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000611e:	4691                	li	a3,4
    80006120:	fc440613          	addi	a2,s0,-60
    80006124:	fd843583          	ld	a1,-40(s0)
    80006128:	68a8                	ld	a0,80(s1)
    8000612a:	ffffb097          	auipc	ra,0xffffb
    8000612e:	714080e7          	jalr	1812(ra) # 8000183e <copyout>
    80006132:	02054063          	bltz	a0,80006152 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006136:	4691                	li	a3,4
    80006138:	fc040613          	addi	a2,s0,-64
    8000613c:	fd843583          	ld	a1,-40(s0)
    80006140:	0591                	addi	a1,a1,4
    80006142:	68a8                	ld	a0,80(s1)
    80006144:	ffffb097          	auipc	ra,0xffffb
    80006148:	6fa080e7          	jalr	1786(ra) # 8000183e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000614c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000614e:	06055463          	bgez	a0,800061b6 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006152:	fc442783          	lw	a5,-60(s0)
    80006156:	07e9                	addi	a5,a5,26
    80006158:	078e                	slli	a5,a5,0x3
    8000615a:	97a6                	add	a5,a5,s1
    8000615c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006160:	fc042783          	lw	a5,-64(s0)
    80006164:	07e9                	addi	a5,a5,26
    80006166:	078e                	slli	a5,a5,0x3
    80006168:	94be                	add	s1,s1,a5
    8000616a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000616e:	fd043503          	ld	a0,-48(s0)
    80006172:	fffff097          	auipc	ra,0xfffff
    80006176:	a04080e7          	jalr	-1532(ra) # 80004b76 <fileclose>
    fileclose(wf);
    8000617a:	fc843503          	ld	a0,-56(s0)
    8000617e:	fffff097          	auipc	ra,0xfffff
    80006182:	9f8080e7          	jalr	-1544(ra) # 80004b76 <fileclose>
    return -1;
    80006186:	57fd                	li	a5,-1
    80006188:	a03d                	j	800061b6 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000618a:	fc442783          	lw	a5,-60(s0)
    8000618e:	0007c763          	bltz	a5,8000619c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006192:	07e9                	addi	a5,a5,26
    80006194:	078e                	slli	a5,a5,0x3
    80006196:	97a6                	add	a5,a5,s1
    80006198:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000619c:	fd043503          	ld	a0,-48(s0)
    800061a0:	fffff097          	auipc	ra,0xfffff
    800061a4:	9d6080e7          	jalr	-1578(ra) # 80004b76 <fileclose>
    fileclose(wf);
    800061a8:	fc843503          	ld	a0,-56(s0)
    800061ac:	fffff097          	auipc	ra,0xfffff
    800061b0:	9ca080e7          	jalr	-1590(ra) # 80004b76 <fileclose>
    return -1;
    800061b4:	57fd                	li	a5,-1
}
    800061b6:	853e                	mv	a0,a5
    800061b8:	70e2                	ld	ra,56(sp)
    800061ba:	7442                	ld	s0,48(sp)
    800061bc:	74a2                	ld	s1,40(sp)
    800061be:	6121                	addi	sp,sp,64
    800061c0:	8082                	ret
	...

00000000800061d0 <kernelvec>:
    800061d0:	7111                	addi	sp,sp,-256
    800061d2:	e006                	sd	ra,0(sp)
    800061d4:	e40a                	sd	sp,8(sp)
    800061d6:	e80e                	sd	gp,16(sp)
    800061d8:	ec12                	sd	tp,24(sp)
    800061da:	f016                	sd	t0,32(sp)
    800061dc:	f41a                	sd	t1,40(sp)
    800061de:	f81e                	sd	t2,48(sp)
    800061e0:	fc22                	sd	s0,56(sp)
    800061e2:	e0a6                	sd	s1,64(sp)
    800061e4:	e4aa                	sd	a0,72(sp)
    800061e6:	e8ae                	sd	a1,80(sp)
    800061e8:	ecb2                	sd	a2,88(sp)
    800061ea:	f0b6                	sd	a3,96(sp)
    800061ec:	f4ba                	sd	a4,104(sp)
    800061ee:	f8be                	sd	a5,112(sp)
    800061f0:	fcc2                	sd	a6,120(sp)
    800061f2:	e146                	sd	a7,128(sp)
    800061f4:	e54a                	sd	s2,136(sp)
    800061f6:	e94e                	sd	s3,144(sp)
    800061f8:	ed52                	sd	s4,152(sp)
    800061fa:	f156                	sd	s5,160(sp)
    800061fc:	f55a                	sd	s6,168(sp)
    800061fe:	f95e                	sd	s7,176(sp)
    80006200:	fd62                	sd	s8,184(sp)
    80006202:	e1e6                	sd	s9,192(sp)
    80006204:	e5ea                	sd	s10,200(sp)
    80006206:	e9ee                	sd	s11,208(sp)
    80006208:	edf2                	sd	t3,216(sp)
    8000620a:	f1f6                	sd	t4,224(sp)
    8000620c:	f5fa                	sd	t5,232(sp)
    8000620e:	f9fe                	sd	t6,240(sp)
    80006210:	c6bfc0ef          	jal	ra,80002e7a <kerneltrap>
    80006214:	6082                	ld	ra,0(sp)
    80006216:	6122                	ld	sp,8(sp)
    80006218:	61c2                	ld	gp,16(sp)
    8000621a:	7282                	ld	t0,32(sp)
    8000621c:	7322                	ld	t1,40(sp)
    8000621e:	73c2                	ld	t2,48(sp)
    80006220:	7462                	ld	s0,56(sp)
    80006222:	6486                	ld	s1,64(sp)
    80006224:	6526                	ld	a0,72(sp)
    80006226:	65c6                	ld	a1,80(sp)
    80006228:	6666                	ld	a2,88(sp)
    8000622a:	7686                	ld	a3,96(sp)
    8000622c:	7726                	ld	a4,104(sp)
    8000622e:	77c6                	ld	a5,112(sp)
    80006230:	7866                	ld	a6,120(sp)
    80006232:	688a                	ld	a7,128(sp)
    80006234:	692a                	ld	s2,136(sp)
    80006236:	69ca                	ld	s3,144(sp)
    80006238:	6a6a                	ld	s4,152(sp)
    8000623a:	7a8a                	ld	s5,160(sp)
    8000623c:	7b2a                	ld	s6,168(sp)
    8000623e:	7bca                	ld	s7,176(sp)
    80006240:	7c6a                	ld	s8,184(sp)
    80006242:	6c8e                	ld	s9,192(sp)
    80006244:	6d2e                	ld	s10,200(sp)
    80006246:	6dce                	ld	s11,208(sp)
    80006248:	6e6e                	ld	t3,216(sp)
    8000624a:	7e8e                	ld	t4,224(sp)
    8000624c:	7f2e                	ld	t5,232(sp)
    8000624e:	7fce                	ld	t6,240(sp)
    80006250:	6111                	addi	sp,sp,256
    80006252:	10200073          	sret
    80006256:	00000013          	nop
    8000625a:	00000013          	nop
    8000625e:	0001                	nop

0000000080006260 <timervec>:
    80006260:	34051573          	csrrw	a0,mscratch,a0
    80006264:	e10c                	sd	a1,0(a0)
    80006266:	e510                	sd	a2,8(a0)
    80006268:	e914                	sd	a3,16(a0)
    8000626a:	6d0c                	ld	a1,24(a0)
    8000626c:	7110                	ld	a2,32(a0)
    8000626e:	6194                	ld	a3,0(a1)
    80006270:	96b2                	add	a3,a3,a2
    80006272:	e194                	sd	a3,0(a1)
    80006274:	4589                	li	a1,2
    80006276:	14459073          	csrw	sip,a1
    8000627a:	6914                	ld	a3,16(a0)
    8000627c:	6510                	ld	a2,8(a0)
    8000627e:	610c                	ld	a1,0(a0)
    80006280:	34051573          	csrrw	a0,mscratch,a0
    80006284:	30200073          	mret
	...

000000008000628a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000628a:	1141                	addi	sp,sp,-16
    8000628c:	e422                	sd	s0,8(sp)
    8000628e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006290:	0c0007b7          	lui	a5,0xc000
    80006294:	4705                	li	a4,1
    80006296:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006298:	c3d8                	sw	a4,4(a5)
}
    8000629a:	6422                	ld	s0,8(sp)
    8000629c:	0141                	addi	sp,sp,16
    8000629e:	8082                	ret

00000000800062a0 <plicinithart>:

void
plicinithart(void)
{
    800062a0:	1141                	addi	sp,sp,-16
    800062a2:	e406                	sd	ra,8(sp)
    800062a4:	e022                	sd	s0,0(sp)
    800062a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062a8:	ffffc097          	auipc	ra,0xffffc
    800062ac:	a04080e7          	jalr	-1532(ra) # 80001cac <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062b0:	0085171b          	slliw	a4,a0,0x8
    800062b4:	0c0027b7          	lui	a5,0xc002
    800062b8:	97ba                	add	a5,a5,a4
    800062ba:	40200713          	li	a4,1026
    800062be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062c2:	00d5151b          	slliw	a0,a0,0xd
    800062c6:	0c2017b7          	lui	a5,0xc201
    800062ca:	97aa                	add	a5,a5,a0
    800062cc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800062d0:	60a2                	ld	ra,8(sp)
    800062d2:	6402                	ld	s0,0(sp)
    800062d4:	0141                	addi	sp,sp,16
    800062d6:	8082                	ret

00000000800062d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062d8:	1141                	addi	sp,sp,-16
    800062da:	e406                	sd	ra,8(sp)
    800062dc:	e022                	sd	s0,0(sp)
    800062de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062e0:	ffffc097          	auipc	ra,0xffffc
    800062e4:	9cc080e7          	jalr	-1588(ra) # 80001cac <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062e8:	00d5151b          	slliw	a0,a0,0xd
    800062ec:	0c2017b7          	lui	a5,0xc201
    800062f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800062f2:	43c8                	lw	a0,4(a5)
    800062f4:	60a2                	ld	ra,8(sp)
    800062f6:	6402                	ld	s0,0(sp)
    800062f8:	0141                	addi	sp,sp,16
    800062fa:	8082                	ret

00000000800062fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062fc:	1101                	addi	sp,sp,-32
    800062fe:	ec06                	sd	ra,24(sp)
    80006300:	e822                	sd	s0,16(sp)
    80006302:	e426                	sd	s1,8(sp)
    80006304:	1000                	addi	s0,sp,32
    80006306:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006308:	ffffc097          	auipc	ra,0xffffc
    8000630c:	9a4080e7          	jalr	-1628(ra) # 80001cac <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006310:	00d5151b          	slliw	a0,a0,0xd
    80006314:	0c2017b7          	lui	a5,0xc201
    80006318:	97aa                	add	a5,a5,a0
    8000631a:	c3c4                	sw	s1,4(a5)
}
    8000631c:	60e2                	ld	ra,24(sp)
    8000631e:	6442                	ld	s0,16(sp)
    80006320:	64a2                	ld	s1,8(sp)
    80006322:	6105                	addi	sp,sp,32
    80006324:	8082                	ret

0000000080006326 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006326:	1141                	addi	sp,sp,-16
    80006328:	e406                	sd	ra,8(sp)
    8000632a:	e022                	sd	s0,0(sp)
    8000632c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000632e:	479d                	li	a5,7
    80006330:	04a7cc63          	blt	a5,a0,80006388 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006334:	0003c797          	auipc	a5,0x3c
    80006338:	aa478793          	addi	a5,a5,-1372 # 80041dd8 <disk>
    8000633c:	97aa                	add	a5,a5,a0
    8000633e:	0187c783          	lbu	a5,24(a5)
    80006342:	ebb9                	bnez	a5,80006398 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006344:	00451693          	slli	a3,a0,0x4
    80006348:	0003c797          	auipc	a5,0x3c
    8000634c:	a9078793          	addi	a5,a5,-1392 # 80041dd8 <disk>
    80006350:	6398                	ld	a4,0(a5)
    80006352:	9736                	add	a4,a4,a3
    80006354:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006358:	6398                	ld	a4,0(a5)
    8000635a:	9736                	add	a4,a4,a3
    8000635c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006360:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006364:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006368:	97aa                	add	a5,a5,a0
    8000636a:	4705                	li	a4,1
    8000636c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006370:	0003c517          	auipc	a0,0x3c
    80006374:	a8050513          	addi	a0,a0,-1408 # 80041df0 <disk+0x18>
    80006378:	ffffc097          	auipc	ra,0xffffc
    8000637c:	172080e7          	jalr	370(ra) # 800024ea <wakeup>
}
    80006380:	60a2                	ld	ra,8(sp)
    80006382:	6402                	ld	s0,0(sp)
    80006384:	0141                	addi	sp,sp,16
    80006386:	8082                	ret
    panic("free_desc 1");
    80006388:	00002517          	auipc	a0,0x2
    8000638c:	51050513          	addi	a0,a0,1296 # 80008898 <syscalls+0x318>
    80006390:	ffffa097          	auipc	ra,0xffffa
    80006394:	1b0080e7          	jalr	432(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006398:	00002517          	auipc	a0,0x2
    8000639c:	51050513          	addi	a0,a0,1296 # 800088a8 <syscalls+0x328>
    800063a0:	ffffa097          	auipc	ra,0xffffa
    800063a4:	1a0080e7          	jalr	416(ra) # 80000540 <panic>

00000000800063a8 <virtio_disk_init>:
{
    800063a8:	1101                	addi	sp,sp,-32
    800063aa:	ec06                	sd	ra,24(sp)
    800063ac:	e822                	sd	s0,16(sp)
    800063ae:	e426                	sd	s1,8(sp)
    800063b0:	e04a                	sd	s2,0(sp)
    800063b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063b4:	00002597          	auipc	a1,0x2
    800063b8:	50458593          	addi	a1,a1,1284 # 800088b8 <syscalls+0x338>
    800063bc:	0003c517          	auipc	a0,0x3c
    800063c0:	b4450513          	addi	a0,a0,-1212 # 80041f00 <disk+0x128>
    800063c4:	ffffb097          	auipc	ra,0xffffb
    800063c8:	954080e7          	jalr	-1708(ra) # 80000d18 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063cc:	100017b7          	lui	a5,0x10001
    800063d0:	4398                	lw	a4,0(a5)
    800063d2:	2701                	sext.w	a4,a4
    800063d4:	747277b7          	lui	a5,0x74727
    800063d8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063dc:	14f71b63          	bne	a4,a5,80006532 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063e0:	100017b7          	lui	a5,0x10001
    800063e4:	43dc                	lw	a5,4(a5)
    800063e6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063e8:	4709                	li	a4,2
    800063ea:	14e79463          	bne	a5,a4,80006532 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063ee:	100017b7          	lui	a5,0x10001
    800063f2:	479c                	lw	a5,8(a5)
    800063f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063f6:	12e79e63          	bne	a5,a4,80006532 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063fa:	100017b7          	lui	a5,0x10001
    800063fe:	47d8                	lw	a4,12(a5)
    80006400:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006402:	554d47b7          	lui	a5,0x554d4
    80006406:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000640a:	12f71463          	bne	a4,a5,80006532 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000640e:	100017b7          	lui	a5,0x10001
    80006412:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006416:	4705                	li	a4,1
    80006418:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000641a:	470d                	li	a4,3
    8000641c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000641e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006420:	c7ffe6b7          	lui	a3,0xc7ffe
    80006424:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc847>
    80006428:	8f75                	and	a4,a4,a3
    8000642a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000642c:	472d                	li	a4,11
    8000642e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006430:	5bbc                	lw	a5,112(a5)
    80006432:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006436:	8ba1                	andi	a5,a5,8
    80006438:	10078563          	beqz	a5,80006542 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000643c:	100017b7          	lui	a5,0x10001
    80006440:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006444:	43fc                	lw	a5,68(a5)
    80006446:	2781                	sext.w	a5,a5
    80006448:	10079563          	bnez	a5,80006552 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000644c:	100017b7          	lui	a5,0x10001
    80006450:	5bdc                	lw	a5,52(a5)
    80006452:	2781                	sext.w	a5,a5
  if(max == 0)
    80006454:	10078763          	beqz	a5,80006562 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006458:	471d                	li	a4,7
    8000645a:	10f77c63          	bgeu	a4,a5,80006572 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000645e:	ffffa097          	auipc	ra,0xffffa
    80006462:	7c0080e7          	jalr	1984(ra) # 80000c1e <kalloc>
    80006466:	0003c497          	auipc	s1,0x3c
    8000646a:	97248493          	addi	s1,s1,-1678 # 80041dd8 <disk>
    8000646e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	7ae080e7          	jalr	1966(ra) # 80000c1e <kalloc>
    80006478:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000647a:	ffffa097          	auipc	ra,0xffffa
    8000647e:	7a4080e7          	jalr	1956(ra) # 80000c1e <kalloc>
    80006482:	87aa                	mv	a5,a0
    80006484:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006486:	6088                	ld	a0,0(s1)
    80006488:	cd6d                	beqz	a0,80006582 <virtio_disk_init+0x1da>
    8000648a:	0003c717          	auipc	a4,0x3c
    8000648e:	95673703          	ld	a4,-1706(a4) # 80041de0 <disk+0x8>
    80006492:	cb65                	beqz	a4,80006582 <virtio_disk_init+0x1da>
    80006494:	c7fd                	beqz	a5,80006582 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006496:	6605                	lui	a2,0x1
    80006498:	4581                	li	a1,0
    8000649a:	ffffb097          	auipc	ra,0xffffb
    8000649e:	a0a080e7          	jalr	-1526(ra) # 80000ea4 <memset>
  memset(disk.avail, 0, PGSIZE);
    800064a2:	0003c497          	auipc	s1,0x3c
    800064a6:	93648493          	addi	s1,s1,-1738 # 80041dd8 <disk>
    800064aa:	6605                	lui	a2,0x1
    800064ac:	4581                	li	a1,0
    800064ae:	6488                	ld	a0,8(s1)
    800064b0:	ffffb097          	auipc	ra,0xffffb
    800064b4:	9f4080e7          	jalr	-1548(ra) # 80000ea4 <memset>
  memset(disk.used, 0, PGSIZE);
    800064b8:	6605                	lui	a2,0x1
    800064ba:	4581                	li	a1,0
    800064bc:	6888                	ld	a0,16(s1)
    800064be:	ffffb097          	auipc	ra,0xffffb
    800064c2:	9e6080e7          	jalr	-1562(ra) # 80000ea4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064c6:	100017b7          	lui	a5,0x10001
    800064ca:	4721                	li	a4,8
    800064cc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064ce:	4098                	lw	a4,0(s1)
    800064d0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064d4:	40d8                	lw	a4,4(s1)
    800064d6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064da:	6498                	ld	a4,8(s1)
    800064dc:	0007069b          	sext.w	a3,a4
    800064e0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064e4:	9701                	srai	a4,a4,0x20
    800064e6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064ea:	6898                	ld	a4,16(s1)
    800064ec:	0007069b          	sext.w	a3,a4
    800064f0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064f4:	9701                	srai	a4,a4,0x20
    800064f6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800064fa:	4705                	li	a4,1
    800064fc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800064fe:	00e48c23          	sb	a4,24(s1)
    80006502:	00e48ca3          	sb	a4,25(s1)
    80006506:	00e48d23          	sb	a4,26(s1)
    8000650a:	00e48da3          	sb	a4,27(s1)
    8000650e:	00e48e23          	sb	a4,28(s1)
    80006512:	00e48ea3          	sb	a4,29(s1)
    80006516:	00e48f23          	sb	a4,30(s1)
    8000651a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000651e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006522:	0727a823          	sw	s2,112(a5)
}
    80006526:	60e2                	ld	ra,24(sp)
    80006528:	6442                	ld	s0,16(sp)
    8000652a:	64a2                	ld	s1,8(sp)
    8000652c:	6902                	ld	s2,0(sp)
    8000652e:	6105                	addi	sp,sp,32
    80006530:	8082                	ret
    panic("could not find virtio disk");
    80006532:	00002517          	auipc	a0,0x2
    80006536:	39650513          	addi	a0,a0,918 # 800088c8 <syscalls+0x348>
    8000653a:	ffffa097          	auipc	ra,0xffffa
    8000653e:	006080e7          	jalr	6(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006542:	00002517          	auipc	a0,0x2
    80006546:	3a650513          	addi	a0,a0,934 # 800088e8 <syscalls+0x368>
    8000654a:	ffffa097          	auipc	ra,0xffffa
    8000654e:	ff6080e7          	jalr	-10(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006552:	00002517          	auipc	a0,0x2
    80006556:	3b650513          	addi	a0,a0,950 # 80008908 <syscalls+0x388>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	fe6080e7          	jalr	-26(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006562:	00002517          	auipc	a0,0x2
    80006566:	3c650513          	addi	a0,a0,966 # 80008928 <syscalls+0x3a8>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	fd6080e7          	jalr	-42(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006572:	00002517          	auipc	a0,0x2
    80006576:	3d650513          	addi	a0,a0,982 # 80008948 <syscalls+0x3c8>
    8000657a:	ffffa097          	auipc	ra,0xffffa
    8000657e:	fc6080e7          	jalr	-58(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006582:	00002517          	auipc	a0,0x2
    80006586:	3e650513          	addi	a0,a0,998 # 80008968 <syscalls+0x3e8>
    8000658a:	ffffa097          	auipc	ra,0xffffa
    8000658e:	fb6080e7          	jalr	-74(ra) # 80000540 <panic>

0000000080006592 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006592:	7119                	addi	sp,sp,-128
    80006594:	fc86                	sd	ra,120(sp)
    80006596:	f8a2                	sd	s0,112(sp)
    80006598:	f4a6                	sd	s1,104(sp)
    8000659a:	f0ca                	sd	s2,96(sp)
    8000659c:	ecce                	sd	s3,88(sp)
    8000659e:	e8d2                	sd	s4,80(sp)
    800065a0:	e4d6                	sd	s5,72(sp)
    800065a2:	e0da                	sd	s6,64(sp)
    800065a4:	fc5e                	sd	s7,56(sp)
    800065a6:	f862                	sd	s8,48(sp)
    800065a8:	f466                	sd	s9,40(sp)
    800065aa:	f06a                	sd	s10,32(sp)
    800065ac:	ec6e                	sd	s11,24(sp)
    800065ae:	0100                	addi	s0,sp,128
    800065b0:	8aaa                	mv	s5,a0
    800065b2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065b4:	00c52d03          	lw	s10,12(a0)
    800065b8:	001d1d1b          	slliw	s10,s10,0x1
    800065bc:	1d02                	slli	s10,s10,0x20
    800065be:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800065c2:	0003c517          	auipc	a0,0x3c
    800065c6:	93e50513          	addi	a0,a0,-1730 # 80041f00 <disk+0x128>
    800065ca:	ffffa097          	auipc	ra,0xffffa
    800065ce:	7de080e7          	jalr	2014(ra) # 80000da8 <acquire>
  for(int i = 0; i < 3; i++){
    800065d2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065d4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800065d6:	0003cb97          	auipc	s7,0x3c
    800065da:	802b8b93          	addi	s7,s7,-2046 # 80041dd8 <disk>
  for(int i = 0; i < 3; i++){
    800065de:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065e0:	0003cc97          	auipc	s9,0x3c
    800065e4:	920c8c93          	addi	s9,s9,-1760 # 80041f00 <disk+0x128>
    800065e8:	a08d                	j	8000664a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800065ea:	00fb8733          	add	a4,s7,a5
    800065ee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800065f2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800065f4:	0207c563          	bltz	a5,8000661e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800065f8:	2905                	addiw	s2,s2,1
    800065fa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800065fc:	05690c63          	beq	s2,s6,80006654 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006600:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006602:	0003b717          	auipc	a4,0x3b
    80006606:	7d670713          	addi	a4,a4,2006 # 80041dd8 <disk>
    8000660a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000660c:	01874683          	lbu	a3,24(a4)
    80006610:	fee9                	bnez	a3,800065ea <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006612:	2785                	addiw	a5,a5,1
    80006614:	0705                	addi	a4,a4,1
    80006616:	fe979be3          	bne	a5,s1,8000660c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000661a:	57fd                	li	a5,-1
    8000661c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000661e:	01205d63          	blez	s2,80006638 <virtio_disk_rw+0xa6>
    80006622:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006624:	000a2503          	lw	a0,0(s4)
    80006628:	00000097          	auipc	ra,0x0
    8000662c:	cfe080e7          	jalr	-770(ra) # 80006326 <free_desc>
      for(int j = 0; j < i; j++)
    80006630:	2d85                	addiw	s11,s11,1
    80006632:	0a11                	addi	s4,s4,4
    80006634:	ff2d98e3          	bne	s11,s2,80006624 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006638:	85e6                	mv	a1,s9
    8000663a:	0003b517          	auipc	a0,0x3b
    8000663e:	7b650513          	addi	a0,a0,1974 # 80041df0 <disk+0x18>
    80006642:	ffffc097          	auipc	ra,0xffffc
    80006646:	e44080e7          	jalr	-444(ra) # 80002486 <sleep>
  for(int i = 0; i < 3; i++){
    8000664a:	f8040a13          	addi	s4,s0,-128
{
    8000664e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006650:	894e                	mv	s2,s3
    80006652:	b77d                	j	80006600 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006654:	f8042503          	lw	a0,-128(s0)
    80006658:	00a50713          	addi	a4,a0,10
    8000665c:	0712                	slli	a4,a4,0x4

  if(write)
    8000665e:	0003b797          	auipc	a5,0x3b
    80006662:	77a78793          	addi	a5,a5,1914 # 80041dd8 <disk>
    80006666:	00e786b3          	add	a3,a5,a4
    8000666a:	01803633          	snez	a2,s8
    8000666e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006670:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006674:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006678:	f6070613          	addi	a2,a4,-160
    8000667c:	6394                	ld	a3,0(a5)
    8000667e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006680:	00870593          	addi	a1,a4,8
    80006684:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006686:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006688:	0007b803          	ld	a6,0(a5)
    8000668c:	9642                	add	a2,a2,a6
    8000668e:	46c1                	li	a3,16
    80006690:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006692:	4585                	li	a1,1
    80006694:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006698:	f8442683          	lw	a3,-124(s0)
    8000669c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800066a0:	0692                	slli	a3,a3,0x4
    800066a2:	9836                	add	a6,a6,a3
    800066a4:	058a8613          	addi	a2,s5,88
    800066a8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800066ac:	0007b803          	ld	a6,0(a5)
    800066b0:	96c2                	add	a3,a3,a6
    800066b2:	40000613          	li	a2,1024
    800066b6:	c690                	sw	a2,8(a3)
  if(write)
    800066b8:	001c3613          	seqz	a2,s8
    800066bc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066c0:	00166613          	ori	a2,a2,1
    800066c4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800066c8:	f8842603          	lw	a2,-120(s0)
    800066cc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066d0:	00250693          	addi	a3,a0,2
    800066d4:	0692                	slli	a3,a3,0x4
    800066d6:	96be                	add	a3,a3,a5
    800066d8:	58fd                	li	a7,-1
    800066da:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066de:	0612                	slli	a2,a2,0x4
    800066e0:	9832                	add	a6,a6,a2
    800066e2:	f9070713          	addi	a4,a4,-112
    800066e6:	973e                	add	a4,a4,a5
    800066e8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800066ec:	6398                	ld	a4,0(a5)
    800066ee:	9732                	add	a4,a4,a2
    800066f0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066f2:	4609                	li	a2,2
    800066f4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800066f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066fc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006700:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006704:	6794                	ld	a3,8(a5)
    80006706:	0026d703          	lhu	a4,2(a3)
    8000670a:	8b1d                	andi	a4,a4,7
    8000670c:	0706                	slli	a4,a4,0x1
    8000670e:	96ba                	add	a3,a3,a4
    80006710:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006714:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006718:	6798                	ld	a4,8(a5)
    8000671a:	00275783          	lhu	a5,2(a4)
    8000671e:	2785                	addiw	a5,a5,1
    80006720:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006724:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006728:	100017b7          	lui	a5,0x10001
    8000672c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006730:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006734:	0003b917          	auipc	s2,0x3b
    80006738:	7cc90913          	addi	s2,s2,1996 # 80041f00 <disk+0x128>
  while(b->disk == 1) {
    8000673c:	4485                	li	s1,1
    8000673e:	00b79c63          	bne	a5,a1,80006756 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006742:	85ca                	mv	a1,s2
    80006744:	8556                	mv	a0,s5
    80006746:	ffffc097          	auipc	ra,0xffffc
    8000674a:	d40080e7          	jalr	-704(ra) # 80002486 <sleep>
  while(b->disk == 1) {
    8000674e:	004aa783          	lw	a5,4(s5)
    80006752:	fe9788e3          	beq	a5,s1,80006742 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006756:	f8042903          	lw	s2,-128(s0)
    8000675a:	00290713          	addi	a4,s2,2
    8000675e:	0712                	slli	a4,a4,0x4
    80006760:	0003b797          	auipc	a5,0x3b
    80006764:	67878793          	addi	a5,a5,1656 # 80041dd8 <disk>
    80006768:	97ba                	add	a5,a5,a4
    8000676a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000676e:	0003b997          	auipc	s3,0x3b
    80006772:	66a98993          	addi	s3,s3,1642 # 80041dd8 <disk>
    80006776:	00491713          	slli	a4,s2,0x4
    8000677a:	0009b783          	ld	a5,0(s3)
    8000677e:	97ba                	add	a5,a5,a4
    80006780:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006784:	854a                	mv	a0,s2
    80006786:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000678a:	00000097          	auipc	ra,0x0
    8000678e:	b9c080e7          	jalr	-1124(ra) # 80006326 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006792:	8885                	andi	s1,s1,1
    80006794:	f0ed                	bnez	s1,80006776 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006796:	0003b517          	auipc	a0,0x3b
    8000679a:	76a50513          	addi	a0,a0,1898 # 80041f00 <disk+0x128>
    8000679e:	ffffa097          	auipc	ra,0xffffa
    800067a2:	6be080e7          	jalr	1726(ra) # 80000e5c <release>
}
    800067a6:	70e6                	ld	ra,120(sp)
    800067a8:	7446                	ld	s0,112(sp)
    800067aa:	74a6                	ld	s1,104(sp)
    800067ac:	7906                	ld	s2,96(sp)
    800067ae:	69e6                	ld	s3,88(sp)
    800067b0:	6a46                	ld	s4,80(sp)
    800067b2:	6aa6                	ld	s5,72(sp)
    800067b4:	6b06                	ld	s6,64(sp)
    800067b6:	7be2                	ld	s7,56(sp)
    800067b8:	7c42                	ld	s8,48(sp)
    800067ba:	7ca2                	ld	s9,40(sp)
    800067bc:	7d02                	ld	s10,32(sp)
    800067be:	6de2                	ld	s11,24(sp)
    800067c0:	6109                	addi	sp,sp,128
    800067c2:	8082                	ret

00000000800067c4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067c4:	1101                	addi	sp,sp,-32
    800067c6:	ec06                	sd	ra,24(sp)
    800067c8:	e822                	sd	s0,16(sp)
    800067ca:	e426                	sd	s1,8(sp)
    800067cc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067ce:	0003b497          	auipc	s1,0x3b
    800067d2:	60a48493          	addi	s1,s1,1546 # 80041dd8 <disk>
    800067d6:	0003b517          	auipc	a0,0x3b
    800067da:	72a50513          	addi	a0,a0,1834 # 80041f00 <disk+0x128>
    800067de:	ffffa097          	auipc	ra,0xffffa
    800067e2:	5ca080e7          	jalr	1482(ra) # 80000da8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067e6:	10001737          	lui	a4,0x10001
    800067ea:	533c                	lw	a5,96(a4)
    800067ec:	8b8d                	andi	a5,a5,3
    800067ee:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067f0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067f4:	689c                	ld	a5,16(s1)
    800067f6:	0204d703          	lhu	a4,32(s1)
    800067fa:	0027d783          	lhu	a5,2(a5)
    800067fe:	04f70863          	beq	a4,a5,8000684e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006802:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006806:	6898                	ld	a4,16(s1)
    80006808:	0204d783          	lhu	a5,32(s1)
    8000680c:	8b9d                	andi	a5,a5,7
    8000680e:	078e                	slli	a5,a5,0x3
    80006810:	97ba                	add	a5,a5,a4
    80006812:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006814:	00278713          	addi	a4,a5,2
    80006818:	0712                	slli	a4,a4,0x4
    8000681a:	9726                	add	a4,a4,s1
    8000681c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006820:	e721                	bnez	a4,80006868 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006822:	0789                	addi	a5,a5,2
    80006824:	0792                	slli	a5,a5,0x4
    80006826:	97a6                	add	a5,a5,s1
    80006828:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000682a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000682e:	ffffc097          	auipc	ra,0xffffc
    80006832:	cbc080e7          	jalr	-836(ra) # 800024ea <wakeup>

    disk.used_idx += 1;
    80006836:	0204d783          	lhu	a5,32(s1)
    8000683a:	2785                	addiw	a5,a5,1
    8000683c:	17c2                	slli	a5,a5,0x30
    8000683e:	93c1                	srli	a5,a5,0x30
    80006840:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006844:	6898                	ld	a4,16(s1)
    80006846:	00275703          	lhu	a4,2(a4)
    8000684a:	faf71ce3          	bne	a4,a5,80006802 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000684e:	0003b517          	auipc	a0,0x3b
    80006852:	6b250513          	addi	a0,a0,1714 # 80041f00 <disk+0x128>
    80006856:	ffffa097          	auipc	ra,0xffffa
    8000685a:	606080e7          	jalr	1542(ra) # 80000e5c <release>
}
    8000685e:	60e2                	ld	ra,24(sp)
    80006860:	6442                	ld	s0,16(sp)
    80006862:	64a2                	ld	s1,8(sp)
    80006864:	6105                	addi	sp,sp,32
    80006866:	8082                	ret
      panic("virtio_disk_intr status");
    80006868:	00002517          	auipc	a0,0x2
    8000686c:	11850513          	addi	a0,a0,280 # 80008980 <syscalls+0x400>
    80006870:	ffffa097          	auipc	ra,0xffffa
    80006874:	cd0080e7          	jalr	-816(ra) # 80000540 <panic>
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
