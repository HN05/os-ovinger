
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a0013103          	ld	sp,-1536(sp) # 80008a00 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	a2070713          	addi	a4,a4,-1504 # 80008a70 <timer_scratch>
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
    80000066:	0ee78793          	addi	a5,a5,238 # 80006150 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc91f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e9478793          	addi	a5,a5,-364 # 80000f40 <main>
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
    8000012e:	6b0080e7          	jalr	1712(ra) # 800027da <either_copyin>
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
    8000018e:	a2650513          	addi	a0,a0,-1498 # 80010bb0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	b0c080e7          	jalr	-1268(ra) # 80000c9e <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a1648493          	addi	s1,s1,-1514 # 80010bb0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	aa690913          	addi	s2,s2,-1370 # 80010c48 <cons+0x98>
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
    800001c4:	a0e080e7          	jalr	-1522(ra) # 80001bce <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	45c080e7          	jalr	1116(ra) # 80002624 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	1a6080e7          	jalr	422(ra) # 8000237c <sleep>
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
    80000216:	572080e7          	jalr	1394(ra) # 80002784 <either_copyout>
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
    8000022a:	98a50513          	addi	a0,a0,-1654 # 80010bb0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	b24080e7          	jalr	-1244(ra) # 80000d52 <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	97450513          	addi	a0,a0,-1676 # 80010bb0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	b0e080e7          	jalr	-1266(ra) # 80000d52 <release>
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
    80000276:	9cf72b23          	sw	a5,-1578(a4) # 80010c48 <cons+0x98>
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
    800002d0:	8e450513          	addi	a0,a0,-1820 # 80010bb0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	9ca080e7          	jalr	-1590(ra) # 80000c9e <acquire>

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
    800002f6:	53e080e7          	jalr	1342(ra) # 80002830 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	8b650513          	addi	a0,a0,-1866 # 80010bb0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	a50080e7          	jalr	-1456(ra) # 80000d52 <release>
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
    80000322:	89270713          	addi	a4,a4,-1902 # 80010bb0 <cons>
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
    8000034c:	86878793          	addi	a5,a5,-1944 # 80010bb0 <cons>
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
    8000037a:	8d27a783          	lw	a5,-1838(a5) # 80010c48 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	82670713          	addi	a4,a4,-2010 # 80010bb0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	81648493          	addi	s1,s1,-2026 # 80010bb0 <cons>
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
    800003da:	7da70713          	addi	a4,a4,2010 # 80010bb0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	86f72223          	sw	a5,-1948(a4) # 80010c50 <cons+0xa0>
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
    80000416:	79e78793          	addi	a5,a5,1950 # 80010bb0 <cons>
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
    8000043a:	80c7ab23          	sw	a2,-2026(a5) # 80010c4c <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	80a50513          	addi	a0,a0,-2038 # 80010c48 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	f9a080e7          	jalr	-102(ra) # 800023e0 <wakeup>
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
    80000464:	75050513          	addi	a0,a0,1872 # 80010bb0 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	7a6080e7          	jalr	1958(ra) # 80000c0e <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	33e080e7          	jalr	830(ra) # 800007ae <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	8d078793          	addi	a5,a5,-1840 # 80020d48 <devsw>
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
    80000562:	7007a923          	sw	zero,1810(a5) # 80010c70 <pr+0x18>
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
    80000584:	b0850513          	addi	a0,a0,-1272 # 80008088 <digits+0x38>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	014080e7          	jalr	20(ra) # 8000059c <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000590:	4785                	li	a5,1
    80000592:	00008717          	auipc	a4,0x8
    80000596:	48f72723          	sw	a5,1166(a4) # 80008a20 <panicked>
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
    800005d2:	6a2dad83          	lw	s11,1698(s11) # 80010c70 <pr+0x18>
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
    80000610:	64c50513          	addi	a0,a0,1612 # 80010c58 <pr>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	68a080e7          	jalr	1674(ra) # 80000c9e <acquire>
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
    8000076e:	4ee50513          	addi	a0,a0,1262 # 80010c58 <pr>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	5e0080e7          	jalr	1504(ra) # 80000d52 <release>
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
    8000078a:	4d248493          	addi	s1,s1,1234 # 80010c58 <pr>
    8000078e:	00008597          	auipc	a1,0x8
    80000792:	8ba58593          	addi	a1,a1,-1862 # 80008048 <__func__.1+0x40>
    80000796:	8526                	mv	a0,s1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	476080e7          	jalr	1142(ra) # 80000c0e <initlock>
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
    800007ea:	49250513          	addi	a0,a0,1170 # 80010c78 <uart_tx_lock>
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	420080e7          	jalr	1056(ra) # 80000c0e <initlock>
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
    8000080e:	448080e7          	jalr	1096(ra) # 80000c52 <push_off>

  if(panicked){
    80000812:	00008797          	auipc	a5,0x8
    80000816:	20e7a783          	lw	a5,526(a5) # 80008a20 <panicked>
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
    8000083c:	4ba080e7          	jalr	1210(ra) # 80000cf2 <pop_off>
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
    8000084e:	1de7b783          	ld	a5,478(a5) # 80008a28 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	1de73703          	ld	a4,478(a4) # 80008a30 <uart_tx_w>
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
    80000878:	404a0a13          	addi	s4,s4,1028 # 80010c78 <uart_tx_lock>
    uart_tx_r += 1;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	1ac48493          	addi	s1,s1,428 # 80008a28 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	1ac98993          	addi	s3,s3,428 # 80008a30 <uart_tx_w>
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
    800008aa:	b3a080e7          	jalr	-1222(ra) # 800023e0 <wakeup>
    
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
    800008e6:	39650513          	addi	a0,a0,918 # 80010c78 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	3b4080e7          	jalr	948(ra) # 80000c9e <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	12e7a783          	lw	a5,302(a5) # 80008a20 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008717          	auipc	a4,0x8
    80000900:	13473703          	ld	a4,308(a4) # 80008a30 <uart_tx_w>
    80000904:	00008797          	auipc	a5,0x8
    80000908:	1247b783          	ld	a5,292(a5) # 80008a28 <uart_tx_r>
    8000090c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	36898993          	addi	s3,s3,872 # 80010c78 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	11048493          	addi	s1,s1,272 # 80008a28 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	11090913          	addi	s2,s2,272 # 80008a30 <uart_tx_w>
    80000928:	00e79f63          	bne	a5,a4,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85ce                	mv	a1,s3
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	a4c080e7          	jalr	-1460(ra) # 8000237c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093703          	ld	a4,0(s2)
    8000093c:	609c                	ld	a5,0(s1)
    8000093e:	02078793          	addi	a5,a5,32
    80000942:	fee785e3          	beq	a5,a4,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	33248493          	addi	s1,s1,818 # 80010c78 <uart_tx_lock>
    8000094e:	01f77793          	andi	a5,a4,31
    80000952:	97a6                	add	a5,a5,s1
    80000954:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000958:	0705                	addi	a4,a4,1
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	0ce7bb23          	sd	a4,214(a5) # 80008a30 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee8080e7          	jalr	-280(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	3e6080e7          	jalr	998(ra) # 80000d52 <release>
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
    800009d0:	2ac48493          	addi	s1,s1,684 # 80010c78 <uart_tx_lock>
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2c8080e7          	jalr	712(ra) # 80000c9e <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	36a080e7          	jalr	874(ra) # 80000d52 <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	e04a                	sd	s2,0(sp)
    80000a04:	1000                	addi	s0,sp,32
    80000a06:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a08:	00008797          	auipc	a5,0x8
    80000a0c:	0387b783          	ld	a5,56(a5) # 80008a40 <MAX_PAGES>
    80000a10:	c799                	beqz	a5,80000a1e <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a12:	00008717          	auipc	a4,0x8
    80000a16:	02673703          	ld	a4,38(a4) # 80008a38 <FREE_PAGES>
    80000a1a:	06f77663          	bgeu	a4,a5,80000a86 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03449793          	slli	a5,s1,0x34
    80000a22:	efc1                	bnez	a5,80000aba <kfree+0xc0>
    80000a24:	00021797          	auipc	a5,0x21
    80000a28:	4bc78793          	addi	a5,a5,1212 # 80021ee0 <end>
    80000a2c:	08f4e763          	bltu	s1,a5,80000aba <kfree+0xc0>
    80000a30:	47c5                	li	a5,17
    80000a32:	07ee                	slli	a5,a5,0x1b
    80000a34:	08f4f363          	bgeu	s1,a5,80000aba <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a38:	6605                	lui	a2,0x1
    80000a3a:	4585                	li	a1,1
    80000a3c:	8526                	mv	a0,s1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	35c080e7          	jalr	860(ra) # 80000d9a <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000a46:	00010917          	auipc	s2,0x10
    80000a4a:	26a90913          	addi	s2,s2,618 # 80010cb0 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <acquire>
    r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a62:	00008717          	auipc	a4,0x8
    80000a66:	fd670713          	addi	a4,a4,-42 # 80008a38 <FREE_PAGES>
    80000a6a:	631c                	ld	a5,0(a4)
    80000a6c:	0785                	addi	a5,a5,1
    80000a6e:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	2e0080e7          	jalr	736(ra) # 80000d52 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000a86:	03700693          	li	a3,55
    80000a8a:	00007617          	auipc	a2,0x7
    80000a8e:	57e60613          	addi	a2,a2,1406 # 80008008 <__func__.1>
    80000a92:	00007597          	auipc	a1,0x7
    80000a96:	5de58593          	addi	a1,a1,1502 # 80008070 <digits+0x20>
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	5e650513          	addi	a0,a0,1510 # 80008080 <digits+0x30>
    80000aa2:	00000097          	auipc	ra,0x0
    80000aa6:	afa080e7          	jalr	-1286(ra) # 8000059c <printf>
    80000aaa:	00007517          	auipc	a0,0x7
    80000aae:	5e650513          	addi	a0,a0,1510 # 80008090 <digits+0x40>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	a8e080e7          	jalr	-1394(ra) # 80000540 <panic>
        panic("kfree");
    80000aba:	00007517          	auipc	a0,0x7
    80000abe:	5e650513          	addi	a0,a0,1510 # 800080a0 <digits+0x50>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	a7e080e7          	jalr	-1410(ra) # 80000540 <panic>

0000000080000aca <freerange>:
{
    80000aca:	7179                	addi	sp,sp,-48
    80000acc:	f406                	sd	ra,40(sp)
    80000ace:	f022                	sd	s0,32(sp)
    80000ad0:	ec26                	sd	s1,24(sp)
    80000ad2:	e84a                	sd	s2,16(sp)
    80000ad4:	e44e                	sd	s3,8(sp)
    80000ad6:	e052                	sd	s4,0(sp)
    80000ad8:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0095ee63          	bltu	a1,s1,80000b06 <freerange+0x3c>
    80000aee:	892e                	mv	s2,a1
        kfree(p);
    80000af0:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af2:	6985                	lui	s3,0x1
        kfree(p);
    80000af4:	01448533          	add	a0,s1,s4
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	f02080e7          	jalr	-254(ra) # 800009fa <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b00:	94ce                	add	s1,s1,s3
    80000b02:	fe9979e3          	bgeu	s2,s1,80000af4 <freerange+0x2a>
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
    80000b12:	6145                	addi	sp,sp,48
    80000b14:	8082                	ret

0000000080000b16 <kinit>:
{
    80000b16:	1141                	addi	sp,sp,-16
    80000b18:	e406                	sd	ra,8(sp)
    80000b1a:	e022                	sd	s0,0(sp)
    80000b1c:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b1e:	00007597          	auipc	a1,0x7
    80000b22:	58a58593          	addi	a1,a1,1418 # 800080a8 <digits+0x58>
    80000b26:	00010517          	auipc	a0,0x10
    80000b2a:	18a50513          	addi	a0,a0,394 # 80010cb0 <kmem>
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	0e0080e7          	jalr	224(ra) # 80000c0e <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00021517          	auipc	a0,0x21
    80000b3e:	3a650513          	addi	a0,a0,934 # 80021ee0 <end>
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	f88080e7          	jalr	-120(ra) # 80000aca <freerange>
    MAX_PAGES = FREE_PAGES;
    80000b4a:	00008797          	auipc	a5,0x8
    80000b4e:	eee7b783          	ld	a5,-274(a5) # 80008a38 <FREE_PAGES>
    80000b52:	00008717          	auipc	a4,0x8
    80000b56:	eef73723          	sd	a5,-274(a4) # 80008a40 <MAX_PAGES>
}
    80000b5a:	60a2                	ld	ra,8(sp)
    80000b5c:	6402                	ld	s0,0(sp)
    80000b5e:	0141                	addi	sp,sp,16
    80000b60:	8082                	ret

0000000080000b62 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b62:	1101                	addi	sp,sp,-32
    80000b64:	ec06                	sd	ra,24(sp)
    80000b66:	e822                	sd	s0,16(sp)
    80000b68:	e426                	sd	s1,8(sp)
    80000b6a:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000b6c:	00008797          	auipc	a5,0x8
    80000b70:	ecc7b783          	ld	a5,-308(a5) # 80008a38 <FREE_PAGES>
    80000b74:	cbb1                	beqz	a5,80000bc8 <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000b76:	00010497          	auipc	s1,0x10
    80000b7a:	13a48493          	addi	s1,s1,314 # 80010cb0 <kmem>
    80000b7e:	8526                	mv	a0,s1
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	11e080e7          	jalr	286(ra) # 80000c9e <acquire>
    r = kmem.freelist;
    80000b88:	6c84                	ld	s1,24(s1)
    if (r)
    80000b8a:	c8ad                	beqz	s1,80000bfc <kalloc+0x9a>
        kmem.freelist = r->next;
    80000b8c:	609c                	ld	a5,0(s1)
    80000b8e:	00010517          	auipc	a0,0x10
    80000b92:	12250513          	addi	a0,a0,290 # 80010cb0 <kmem>
    80000b96:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	1ba080e7          	jalr	442(ra) # 80000d52 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000ba0:	6605                	lui	a2,0x1
    80000ba2:	4595                	li	a1,5
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	1f4080e7          	jalr	500(ra) # 80000d9a <memset>
    FREE_PAGES--;
    80000bae:	00008717          	auipc	a4,0x8
    80000bb2:	e8a70713          	addi	a4,a4,-374 # 80008a38 <FREE_PAGES>
    80000bb6:	631c                	ld	a5,0(a4)
    80000bb8:	17fd                	addi	a5,a5,-1
    80000bba:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	60e2                	ld	ra,24(sp)
    80000bc0:	6442                	ld	s0,16(sp)
    80000bc2:	64a2                	ld	s1,8(sp)
    80000bc4:	6105                	addi	sp,sp,32
    80000bc6:	8082                	ret
    assert(FREE_PAGES > 0);
    80000bc8:	04f00693          	li	a3,79
    80000bcc:	00007617          	auipc	a2,0x7
    80000bd0:	43460613          	addi	a2,a2,1076 # 80008000 <etext>
    80000bd4:	00007597          	auipc	a1,0x7
    80000bd8:	49c58593          	addi	a1,a1,1180 # 80008070 <digits+0x20>
    80000bdc:	00007517          	auipc	a0,0x7
    80000be0:	4a450513          	addi	a0,a0,1188 # 80008080 <digits+0x30>
    80000be4:	00000097          	auipc	ra,0x0
    80000be8:	9b8080e7          	jalr	-1608(ra) # 8000059c <printf>
    80000bec:	00007517          	auipc	a0,0x7
    80000bf0:	4a450513          	addi	a0,a0,1188 # 80008090 <digits+0x40>
    80000bf4:	00000097          	auipc	ra,0x0
    80000bf8:	94c080e7          	jalr	-1716(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000bfc:	00010517          	auipc	a0,0x10
    80000c00:	0b450513          	addi	a0,a0,180 # 80010cb0 <kmem>
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	14e080e7          	jalr	334(ra) # 80000d52 <release>
    if (r)
    80000c0c:	b74d                	j	80000bae <kalloc+0x4c>

0000000080000c0e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c0e:	1141                	addi	sp,sp,-16
    80000c10:	e422                	sd	s0,8(sp)
    80000c12:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c14:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c16:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c1a:	00053823          	sd	zero,16(a0)
}
    80000c1e:	6422                	ld	s0,8(sp)
    80000c20:	0141                	addi	sp,sp,16
    80000c22:	8082                	ret

0000000080000c24 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c24:	411c                	lw	a5,0(a0)
    80000c26:	e399                	bnez	a5,80000c2c <holding+0x8>
    80000c28:	4501                	li	a0,0
  return r;
}
    80000c2a:	8082                	ret
{
    80000c2c:	1101                	addi	sp,sp,-32
    80000c2e:	ec06                	sd	ra,24(sp)
    80000c30:	e822                	sd	s0,16(sp)
    80000c32:	e426                	sd	s1,8(sp)
    80000c34:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c36:	6904                	ld	s1,16(a0)
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	f7a080e7          	jalr	-134(ra) # 80001bb2 <mycpu>
    80000c40:	40a48533          	sub	a0,s1,a0
    80000c44:	00153513          	seqz	a0,a0
}
    80000c48:	60e2                	ld	ra,24(sp)
    80000c4a:	6442                	ld	s0,16(sp)
    80000c4c:	64a2                	ld	s1,8(sp)
    80000c4e:	6105                	addi	sp,sp,32
    80000c50:	8082                	ret

0000000080000c52 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c52:	1101                	addi	sp,sp,-32
    80000c54:	ec06                	sd	ra,24(sp)
    80000c56:	e822                	sd	s0,16(sp)
    80000c58:	e426                	sd	s1,8(sp)
    80000c5a:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c5c:	100024f3          	csrr	s1,sstatus
    80000c60:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c64:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000c66:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c6a:	00001097          	auipc	ra,0x1
    80000c6e:	f48080e7          	jalr	-184(ra) # 80001bb2 <mycpu>
    80000c72:	5d3c                	lw	a5,120(a0)
    80000c74:	cf89                	beqz	a5,80000c8e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c76:	00001097          	auipc	ra,0x1
    80000c7a:	f3c080e7          	jalr	-196(ra) # 80001bb2 <mycpu>
    80000c7e:	5d3c                	lw	a5,120(a0)
    80000c80:	2785                	addiw	a5,a5,1
    80000c82:	dd3c                	sw	a5,120(a0)
}
    80000c84:	60e2                	ld	ra,24(sp)
    80000c86:	6442                	ld	s0,16(sp)
    80000c88:	64a2                	ld	s1,8(sp)
    80000c8a:	6105                	addi	sp,sp,32
    80000c8c:	8082                	ret
    mycpu()->intena = old;
    80000c8e:	00001097          	auipc	ra,0x1
    80000c92:	f24080e7          	jalr	-220(ra) # 80001bb2 <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000c96:	8085                	srli	s1,s1,0x1
    80000c98:	8885                	andi	s1,s1,1
    80000c9a:	dd64                	sw	s1,124(a0)
    80000c9c:	bfe9                	j	80000c76 <push_off+0x24>

0000000080000c9e <acquire>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	fa8080e7          	jalr	-88(ra) # 80000c52 <push_off>
  if(holding(lk))
    80000cb2:	8526                	mv	a0,s1
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	f70080e7          	jalr	-144(ra) # 80000c24 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cbc:	4705                	li	a4,1
  if(holding(lk))
    80000cbe:	e115                	bnez	a0,80000ce2 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cc0:	87ba                	mv	a5,a4
    80000cc2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cc6:	2781                	sext.w	a5,a5
    80000cc8:	ffe5                	bnez	a5,80000cc0 <acquire+0x22>
  __sync_synchronize();
    80000cca:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cce:	00001097          	auipc	ra,0x1
    80000cd2:	ee4080e7          	jalr	-284(ra) # 80001bb2 <mycpu>
    80000cd6:	e888                	sd	a0,16(s1)
}
    80000cd8:	60e2                	ld	ra,24(sp)
    80000cda:	6442                	ld	s0,16(sp)
    80000cdc:	64a2                	ld	s1,8(sp)
    80000cde:	6105                	addi	sp,sp,32
    80000ce0:	8082                	ret
    panic("acquire");
    80000ce2:	00007517          	auipc	a0,0x7
    80000ce6:	3ce50513          	addi	a0,a0,974 # 800080b0 <digits+0x60>
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	856080e7          	jalr	-1962(ra) # 80000540 <panic>

0000000080000cf2 <pop_off>:

void
pop_off(void)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e406                	sd	ra,8(sp)
    80000cf6:	e022                	sd	s0,0(sp)
    80000cf8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cfa:	00001097          	auipc	ra,0x1
    80000cfe:	eb8080e7          	jalr	-328(ra) # 80001bb2 <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d02:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000d06:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d08:	e78d                	bnez	a5,80000d32 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d0a:	5d3c                	lw	a5,120(a0)
    80000d0c:	02f05b63          	blez	a5,80000d42 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d10:	37fd                	addiw	a5,a5,-1
    80000d12:	0007871b          	sext.w	a4,a5
    80000d16:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d18:	eb09                	bnez	a4,80000d2a <pop_off+0x38>
    80000d1a:	5d7c                	lw	a5,124(a0)
    80000d1c:	c799                	beqz	a5,80000d2a <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000d1e:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d22:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000d26:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d2a:	60a2                	ld	ra,8(sp)
    80000d2c:	6402                	ld	s0,0(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret
    panic("pop_off - interruptible");
    80000d32:	00007517          	auipc	a0,0x7
    80000d36:	38650513          	addi	a0,a0,902 # 800080b8 <digits+0x68>
    80000d3a:	00000097          	auipc	ra,0x0
    80000d3e:	806080e7          	jalr	-2042(ra) # 80000540 <panic>
    panic("pop_off");
    80000d42:	00007517          	auipc	a0,0x7
    80000d46:	38e50513          	addi	a0,a0,910 # 800080d0 <digits+0x80>
    80000d4a:	fffff097          	auipc	ra,0xfffff
    80000d4e:	7f6080e7          	jalr	2038(ra) # 80000540 <panic>

0000000080000d52 <release>:
{
    80000d52:	1101                	addi	sp,sp,-32
    80000d54:	ec06                	sd	ra,24(sp)
    80000d56:	e822                	sd	s0,16(sp)
    80000d58:	e426                	sd	s1,8(sp)
    80000d5a:	1000                	addi	s0,sp,32
    80000d5c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	ec6080e7          	jalr	-314(ra) # 80000c24 <holding>
    80000d66:	c115                	beqz	a0,80000d8a <release+0x38>
  lk->cpu = 0;
    80000d68:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d6c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d70:	0f50000f          	fence	iorw,ow
    80000d74:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	f7a080e7          	jalr	-134(ra) # 80000cf2 <pop_off>
}
    80000d80:	60e2                	ld	ra,24(sp)
    80000d82:	6442                	ld	s0,16(sp)
    80000d84:	64a2                	ld	s1,8(sp)
    80000d86:	6105                	addi	sp,sp,32
    80000d88:	8082                	ret
    panic("release");
    80000d8a:	00007517          	auipc	a0,0x7
    80000d8e:	34e50513          	addi	a0,a0,846 # 800080d8 <digits+0x88>
    80000d92:	fffff097          	auipc	ra,0xfffff
    80000d96:	7ae080e7          	jalr	1966(ra) # 80000540 <panic>

0000000080000d9a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e422                	sd	s0,8(sp)
    80000d9e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000da0:	ca19                	beqz	a2,80000db6 <memset+0x1c>
    80000da2:	87aa                	mv	a5,a0
    80000da4:	1602                	slli	a2,a2,0x20
    80000da6:	9201                	srli	a2,a2,0x20
    80000da8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000dac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000db0:	0785                	addi	a5,a5,1
    80000db2:	fee79de3          	bne	a5,a4,80000dac <memset+0x12>
  }
  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret

0000000080000dbc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e422                	sd	s0,8(sp)
    80000dc0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dc2:	ca05                	beqz	a2,80000df2 <memcmp+0x36>
    80000dc4:	fff6069b          	addiw	a3,a2,-1
    80000dc8:	1682                	slli	a3,a3,0x20
    80000dca:	9281                	srli	a3,a3,0x20
    80000dcc:	0685                	addi	a3,a3,1
    80000dce:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dd0:	00054783          	lbu	a5,0(a0)
    80000dd4:	0005c703          	lbu	a4,0(a1)
    80000dd8:	00e79863          	bne	a5,a4,80000de8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ddc:	0505                	addi	a0,a0,1
    80000dde:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000de0:	fed518e3          	bne	a0,a3,80000dd0 <memcmp+0x14>
  }

  return 0;
    80000de4:	4501                	li	a0,0
    80000de6:	a019                	j	80000dec <memcmp+0x30>
      return *s1 - *s2;
    80000de8:	40e7853b          	subw	a0,a5,a4
}
    80000dec:	6422                	ld	s0,8(sp)
    80000dee:	0141                	addi	sp,sp,16
    80000df0:	8082                	ret
  return 0;
    80000df2:	4501                	li	a0,0
    80000df4:	bfe5                	j	80000dec <memcmp+0x30>

0000000080000df6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000df6:	1141                	addi	sp,sp,-16
    80000df8:	e422                	sd	s0,8(sp)
    80000dfa:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dfc:	c205                	beqz	a2,80000e1c <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dfe:	02a5e263          	bltu	a1,a0,80000e22 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e02:	1602                	slli	a2,a2,0x20
    80000e04:	9201                	srli	a2,a2,0x20
    80000e06:	00c587b3          	add	a5,a1,a2
{
    80000e0a:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e0c:	0585                	addi	a1,a1,1
    80000e0e:	0705                	addi	a4,a4,1
    80000e10:	fff5c683          	lbu	a3,-1(a1)
    80000e14:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e18:	fef59ae3          	bne	a1,a5,80000e0c <memmove+0x16>

  return dst;
}
    80000e1c:	6422                	ld	s0,8(sp)
    80000e1e:	0141                	addi	sp,sp,16
    80000e20:	8082                	ret
  if(s < d && s + n > d){
    80000e22:	02061693          	slli	a3,a2,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	00d58733          	add	a4,a1,a3
    80000e2c:	fce57be3          	bgeu	a0,a4,80000e02 <memmove+0xc>
    d += n;
    80000e30:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e32:	fff6079b          	addiw	a5,a2,-1
    80000e36:	1782                	slli	a5,a5,0x20
    80000e38:	9381                	srli	a5,a5,0x20
    80000e3a:	fff7c793          	not	a5,a5
    80000e3e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e40:	177d                	addi	a4,a4,-1
    80000e42:	16fd                	addi	a3,a3,-1
    80000e44:	00074603          	lbu	a2,0(a4)
    80000e48:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e4c:	fee79ae3          	bne	a5,a4,80000e40 <memmove+0x4a>
    80000e50:	b7f1                	j	80000e1c <memmove+0x26>

0000000080000e52 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	f9c080e7          	jalr	-100(ra) # 80000df6 <memmove>
}
    80000e62:	60a2                	ld	ra,8(sp)
    80000e64:	6402                	ld	s0,0(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e70:	ce11                	beqz	a2,80000e8c <strncmp+0x22>
    80000e72:	00054783          	lbu	a5,0(a0)
    80000e76:	cf89                	beqz	a5,80000e90 <strncmp+0x26>
    80000e78:	0005c703          	lbu	a4,0(a1)
    80000e7c:	00f71a63          	bne	a4,a5,80000e90 <strncmp+0x26>
    n--, p++, q++;
    80000e80:	367d                	addiw	a2,a2,-1
    80000e82:	0505                	addi	a0,a0,1
    80000e84:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e86:	f675                	bnez	a2,80000e72 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e88:	4501                	li	a0,0
    80000e8a:	a809                	j	80000e9c <strncmp+0x32>
    80000e8c:	4501                	li	a0,0
    80000e8e:	a039                	j	80000e9c <strncmp+0x32>
  if(n == 0)
    80000e90:	ca09                	beqz	a2,80000ea2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e92:	00054503          	lbu	a0,0(a0)
    80000e96:	0005c783          	lbu	a5,0(a1)
    80000e9a:	9d1d                	subw	a0,a0,a5
}
    80000e9c:	6422                	ld	s0,8(sp)
    80000e9e:	0141                	addi	sp,sp,16
    80000ea0:	8082                	ret
    return 0;
    80000ea2:	4501                	li	a0,0
    80000ea4:	bfe5                	j	80000e9c <strncmp+0x32>

0000000080000ea6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000eac:	872a                	mv	a4,a0
    80000eae:	8832                	mv	a6,a2
    80000eb0:	367d                	addiw	a2,a2,-1
    80000eb2:	01005963          	blez	a6,80000ec4 <strncpy+0x1e>
    80000eb6:	0705                	addi	a4,a4,1
    80000eb8:	0005c783          	lbu	a5,0(a1)
    80000ebc:	fef70fa3          	sb	a5,-1(a4)
    80000ec0:	0585                	addi	a1,a1,1
    80000ec2:	f7f5                	bnez	a5,80000eae <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ec4:	86ba                	mv	a3,a4
    80000ec6:	00c05c63          	blez	a2,80000ede <strncpy+0x38>
    *s++ = 0;
    80000eca:	0685                	addi	a3,a3,1
    80000ecc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ed0:	40d707bb          	subw	a5,a4,a3
    80000ed4:	37fd                	addiw	a5,a5,-1
    80000ed6:	010787bb          	addw	a5,a5,a6
    80000eda:	fef048e3          	bgtz	a5,80000eca <strncpy+0x24>
  return os;
}
    80000ede:	6422                	ld	s0,8(sp)
    80000ee0:	0141                	addi	sp,sp,16
    80000ee2:	8082                	ret

0000000080000ee4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eea:	02c05363          	blez	a2,80000f10 <safestrcpy+0x2c>
    80000eee:	fff6069b          	addiw	a3,a2,-1
    80000ef2:	1682                	slli	a3,a3,0x20
    80000ef4:	9281                	srli	a3,a3,0x20
    80000ef6:	96ae                	add	a3,a3,a1
    80000ef8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000efa:	00d58963          	beq	a1,a3,80000f0c <safestrcpy+0x28>
    80000efe:	0585                	addi	a1,a1,1
    80000f00:	0785                	addi	a5,a5,1
    80000f02:	fff5c703          	lbu	a4,-1(a1)
    80000f06:	fee78fa3          	sb	a4,-1(a5)
    80000f0a:	fb65                	bnez	a4,80000efa <safestrcpy+0x16>
    ;
  *s = 0;
    80000f0c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <strlen>:

int
strlen(const char *s)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f1c:	00054783          	lbu	a5,0(a0)
    80000f20:	cf91                	beqz	a5,80000f3c <strlen+0x26>
    80000f22:	0505                	addi	a0,a0,1
    80000f24:	87aa                	mv	a5,a0
    80000f26:	4685                	li	a3,1
    80000f28:	9e89                	subw	a3,a3,a0
    80000f2a:	00f6853b          	addw	a0,a3,a5
    80000f2e:	0785                	addi	a5,a5,1
    80000f30:	fff7c703          	lbu	a4,-1(a5)
    80000f34:	fb7d                	bnez	a4,80000f2a <strlen+0x14>
    ;
  return n;
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f3c:	4501                	li	a0,0
    80000f3e:	bfe5                	j	80000f36 <strlen+0x20>

0000000080000f40 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f40:	1141                	addi	sp,sp,-16
    80000f42:	e406                	sd	ra,8(sp)
    80000f44:	e022                	sd	s0,0(sp)
    80000f46:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	c5a080e7          	jalr	-934(ra) # 80001ba2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f50:	00008717          	auipc	a4,0x8
    80000f54:	af870713          	addi	a4,a4,-1288 # 80008a48 <started>
  if(cpuid() == 0){
    80000f58:	c139                	beqz	a0,80000f9e <main+0x5e>
    while(started == 0)
    80000f5a:	431c                	lw	a5,0(a4)
    80000f5c:	2781                	sext.w	a5,a5
    80000f5e:	dff5                	beqz	a5,80000f5a <main+0x1a>
      ;
    __sync_synchronize();
    80000f60:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	c3e080e7          	jalr	-962(ra) # 80001ba2 <cpuid>
    80000f6c:	85aa                	mv	a1,a0
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	18a50513          	addi	a0,a0,394 # 800080f8 <digits+0xa8>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	626080e7          	jalr	1574(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    80000f7e:	00000097          	auipc	ra,0x0
    80000f82:	0d8080e7          	jalr	216(ra) # 80001056 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f86:	00002097          	auipc	ra,0x2
    80000f8a:	b44080e7          	jalr	-1212(ra) # 80002aca <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f8e:	00005097          	auipc	ra,0x5
    80000f92:	202080e7          	jalr	514(ra) # 80006190 <plicinithart>
  }

  scheduler();        
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	2c4080e7          	jalr	708(ra) # 8000225a <scheduler>
    consoleinit();
    80000f9e:	fffff097          	auipc	ra,0xfffff
    80000fa2:	4b2080e7          	jalr	1202(ra) # 80000450 <consoleinit>
    printfinit();
    80000fa6:	fffff097          	auipc	ra,0xfffff
    80000faa:	7d6080e7          	jalr	2006(ra) # 8000077c <printfinit>
    printf("\n");
    80000fae:	00007517          	auipc	a0,0x7
    80000fb2:	0da50513          	addi	a0,a0,218 # 80008088 <digits+0x38>
    80000fb6:	fffff097          	auipc	ra,0xfffff
    80000fba:	5e6080e7          	jalr	1510(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    80000fbe:	00007517          	auipc	a0,0x7
    80000fc2:	12250513          	addi	a0,a0,290 # 800080e0 <digits+0x90>
    80000fc6:	fffff097          	auipc	ra,0xfffff
    80000fca:	5d6080e7          	jalr	1494(ra) # 8000059c <printf>
    printf("\n");
    80000fce:	00007517          	auipc	a0,0x7
    80000fd2:	0ba50513          	addi	a0,a0,186 # 80008088 <digits+0x38>
    80000fd6:	fffff097          	auipc	ra,0xfffff
    80000fda:	5c6080e7          	jalr	1478(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    80000fde:	00000097          	auipc	ra,0x0
    80000fe2:	b38080e7          	jalr	-1224(ra) # 80000b16 <kinit>
    kvminit();       // create kernel page table
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	326080e7          	jalr	806(ra) # 8000130c <kvminit>
    kvminithart();   // turn on paging
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	068080e7          	jalr	104(ra) # 80001056 <kvminithart>
    procinit();      // process table
    80000ff6:	00001097          	auipc	ra,0x1
    80000ffa:	aca080e7          	jalr	-1334(ra) # 80001ac0 <procinit>
    trapinit();      // trap vectors
    80000ffe:	00002097          	auipc	ra,0x2
    80001002:	aa4080e7          	jalr	-1372(ra) # 80002aa2 <trapinit>
    trapinithart();  // install kernel trap vector
    80001006:	00002097          	auipc	ra,0x2
    8000100a:	ac4080e7          	jalr	-1340(ra) # 80002aca <trapinithart>
    plicinit();      // set up interrupt controller
    8000100e:	00005097          	auipc	ra,0x5
    80001012:	16c080e7          	jalr	364(ra) # 8000617a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001016:	00005097          	auipc	ra,0x5
    8000101a:	17a080e7          	jalr	378(ra) # 80006190 <plicinithart>
    binit();         // buffer cache
    8000101e:	00002097          	auipc	ra,0x2
    80001022:	314080e7          	jalr	788(ra) # 80003332 <binit>
    iinit();         // inode table
    80001026:	00003097          	auipc	ra,0x3
    8000102a:	9b4080e7          	jalr	-1612(ra) # 800039da <iinit>
    fileinit();      // file table
    8000102e:	00004097          	auipc	ra,0x4
    80001032:	95a080e7          	jalr	-1702(ra) # 80004988 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001036:	00005097          	auipc	ra,0x5
    8000103a:	262080e7          	jalr	610(ra) # 80006298 <virtio_disk_init>
    userinit();      // first user process
    8000103e:	00001097          	auipc	ra,0x1
    80001042:	e68080e7          	jalr	-408(ra) # 80001ea6 <userinit>
    __sync_synchronize();
    80001046:	0ff0000f          	fence
    started = 1;
    8000104a:	4785                	li	a5,1
    8000104c:	00008717          	auipc	a4,0x8
    80001050:	9ef72e23          	sw	a5,-1540(a4) # 80008a48 <started>
    80001054:	b789                	j	80000f96 <main+0x56>

0000000080001056 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001056:	1141                	addi	sp,sp,-16
    80001058:	e422                	sd	s0,8(sp)
    8000105a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    8000105c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001060:	00008797          	auipc	a5,0x8
    80001064:	9f07b783          	ld	a5,-1552(a5) # 80008a50 <kernel_pagetable>
    80001068:	83b1                	srli	a5,a5,0xc
    8000106a:	577d                	li	a4,-1
    8000106c:	177e                	slli	a4,a4,0x3f
    8000106e:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80001070:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    80001074:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001078:	6422                	ld	s0,8(sp)
    8000107a:	0141                	addi	sp,sp,16
    8000107c:	8082                	ret

000000008000107e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000107e:	7139                	addi	sp,sp,-64
    80001080:	fc06                	sd	ra,56(sp)
    80001082:	f822                	sd	s0,48(sp)
    80001084:	f426                	sd	s1,40(sp)
    80001086:	f04a                	sd	s2,32(sp)
    80001088:	ec4e                	sd	s3,24(sp)
    8000108a:	e852                	sd	s4,16(sp)
    8000108c:	e456                	sd	s5,8(sp)
    8000108e:	e05a                	sd	s6,0(sp)
    80001090:	0080                	addi	s0,sp,64
    80001092:	84aa                	mv	s1,a0
    80001094:	89ae                	mv	s3,a1
    80001096:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001098:	57fd                	li	a5,-1
    8000109a:	83e9                	srli	a5,a5,0x1a
    8000109c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000109e:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010a0:	04b7f263          	bgeu	a5,a1,800010e4 <walk+0x66>
    panic("walk");
    800010a4:	00007517          	auipc	a0,0x7
    800010a8:	06c50513          	addi	a0,a0,108 # 80008110 <digits+0xc0>
    800010ac:	fffff097          	auipc	ra,0xfffff
    800010b0:	494080e7          	jalr	1172(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010b4:	060a8663          	beqz	s5,80001120 <walk+0xa2>
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	aaa080e7          	jalr	-1366(ra) # 80000b62 <kalloc>
    800010c0:	84aa                	mv	s1,a0
    800010c2:	c529                	beqz	a0,8000110c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010c4:	6605                	lui	a2,0x1
    800010c6:	4581                	li	a1,0
    800010c8:	00000097          	auipc	ra,0x0
    800010cc:	cd2080e7          	jalr	-814(ra) # 80000d9a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010d0:	00c4d793          	srli	a5,s1,0xc
    800010d4:	07aa                	slli	a5,a5,0xa
    800010d6:	0017e793          	ori	a5,a5,1
    800010da:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010de:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd117>
    800010e0:	036a0063          	beq	s4,s6,80001100 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010e4:	0149d933          	srl	s2,s3,s4
    800010e8:	1ff97913          	andi	s2,s2,511
    800010ec:	090e                	slli	s2,s2,0x3
    800010ee:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010f0:	00093483          	ld	s1,0(s2)
    800010f4:	0014f793          	andi	a5,s1,1
    800010f8:	dfd5                	beqz	a5,800010b4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010fa:	80a9                	srli	s1,s1,0xa
    800010fc:	04b2                	slli	s1,s1,0xc
    800010fe:	b7c5                	j	800010de <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001100:	00c9d513          	srli	a0,s3,0xc
    80001104:	1ff57513          	andi	a0,a0,511
    80001108:	050e                	slli	a0,a0,0x3
    8000110a:	9526                	add	a0,a0,s1
}
    8000110c:	70e2                	ld	ra,56(sp)
    8000110e:	7442                	ld	s0,48(sp)
    80001110:	74a2                	ld	s1,40(sp)
    80001112:	7902                	ld	s2,32(sp)
    80001114:	69e2                	ld	s3,24(sp)
    80001116:	6a42                	ld	s4,16(sp)
    80001118:	6aa2                	ld	s5,8(sp)
    8000111a:	6b02                	ld	s6,0(sp)
    8000111c:	6121                	addi	sp,sp,64
    8000111e:	8082                	ret
        return 0;
    80001120:	4501                	li	a0,0
    80001122:	b7ed                	j	8000110c <walk+0x8e>

0000000080001124 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001124:	57fd                	li	a5,-1
    80001126:	83e9                	srli	a5,a5,0x1a
    80001128:	00b7f463          	bgeu	a5,a1,80001130 <walkaddr+0xc>
    return 0;
    8000112c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000112e:	8082                	ret
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e406                	sd	ra,8(sp)
    80001134:	e022                	sd	s0,0(sp)
    80001136:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001138:	4601                	li	a2,0
    8000113a:	00000097          	auipc	ra,0x0
    8000113e:	f44080e7          	jalr	-188(ra) # 8000107e <walk>
  if(pte == 0)
    80001142:	c105                	beqz	a0,80001162 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001144:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001146:	0117f693          	andi	a3,a5,17
    8000114a:	4745                	li	a4,17
    return 0;
    8000114c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000114e:	00e68663          	beq	a3,a4,8000115a <walkaddr+0x36>
}
    80001152:	60a2                	ld	ra,8(sp)
    80001154:	6402                	ld	s0,0(sp)
    80001156:	0141                	addi	sp,sp,16
    80001158:	8082                	ret
  pa = PTE2PA(*pte);
    8000115a:	83a9                	srli	a5,a5,0xa
    8000115c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001160:	bfcd                	j	80001152 <walkaddr+0x2e>
    return 0;
    80001162:	4501                	li	a0,0
    80001164:	b7fd                	j	80001152 <walkaddr+0x2e>

0000000080001166 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001166:	715d                	addi	sp,sp,-80
    80001168:	e486                	sd	ra,72(sp)
    8000116a:	e0a2                	sd	s0,64(sp)
    8000116c:	fc26                	sd	s1,56(sp)
    8000116e:	f84a                	sd	s2,48(sp)
    80001170:	f44e                	sd	s3,40(sp)
    80001172:	f052                	sd	s4,32(sp)
    80001174:	ec56                	sd	s5,24(sp)
    80001176:	e85a                	sd	s6,16(sp)
    80001178:	e45e                	sd	s7,8(sp)
    8000117a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000117c:	c639                	beqz	a2,800011ca <mappages+0x64>
    8000117e:	8aaa                	mv	s5,a0
    80001180:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001182:	777d                	lui	a4,0xfffff
    80001184:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001188:	fff58993          	addi	s3,a1,-1
    8000118c:	99b2                	add	s3,s3,a2
    8000118e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001192:	893e                	mv	s2,a5
    80001194:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001198:	6b85                	lui	s7,0x1
    8000119a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000119e:	4605                	li	a2,1
    800011a0:	85ca                	mv	a1,s2
    800011a2:	8556                	mv	a0,s5
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	eda080e7          	jalr	-294(ra) # 8000107e <walk>
    800011ac:	cd1d                	beqz	a0,800011ea <mappages+0x84>
    if(*pte & PTE_V)
    800011ae:	611c                	ld	a5,0(a0)
    800011b0:	8b85                	andi	a5,a5,1
    800011b2:	e785                	bnez	a5,800011da <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011b4:	80b1                	srli	s1,s1,0xc
    800011b6:	04aa                	slli	s1,s1,0xa
    800011b8:	0164e4b3          	or	s1,s1,s6
    800011bc:	0014e493          	ori	s1,s1,1
    800011c0:	e104                	sd	s1,0(a0)
    if(a == last)
    800011c2:	05390063          	beq	s2,s3,80001202 <mappages+0x9c>
    a += PGSIZE;
    800011c6:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011c8:	bfc9                	j	8000119a <mappages+0x34>
    panic("mappages: size");
    800011ca:	00007517          	auipc	a0,0x7
    800011ce:	f4e50513          	addi	a0,a0,-178 # 80008118 <digits+0xc8>
    800011d2:	fffff097          	auipc	ra,0xfffff
    800011d6:	36e080e7          	jalr	878(ra) # 80000540 <panic>
      panic("mappages: remap");
    800011da:	00007517          	auipc	a0,0x7
    800011de:	f4e50513          	addi	a0,a0,-178 # 80008128 <digits+0xd8>
    800011e2:	fffff097          	auipc	ra,0xfffff
    800011e6:	35e080e7          	jalr	862(ra) # 80000540 <panic>
      return -1;
    800011ea:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011ec:	60a6                	ld	ra,72(sp)
    800011ee:	6406                	ld	s0,64(sp)
    800011f0:	74e2                	ld	s1,56(sp)
    800011f2:	7942                	ld	s2,48(sp)
    800011f4:	79a2                	ld	s3,40(sp)
    800011f6:	7a02                	ld	s4,32(sp)
    800011f8:	6ae2                	ld	s5,24(sp)
    800011fa:	6b42                	ld	s6,16(sp)
    800011fc:	6ba2                	ld	s7,8(sp)
    800011fe:	6161                	addi	sp,sp,80
    80001200:	8082                	ret
  return 0;
    80001202:	4501                	li	a0,0
    80001204:	b7e5                	j	800011ec <mappages+0x86>

0000000080001206 <kvmmap>:
{
    80001206:	1141                	addi	sp,sp,-16
    80001208:	e406                	sd	ra,8(sp)
    8000120a:	e022                	sd	s0,0(sp)
    8000120c:	0800                	addi	s0,sp,16
    8000120e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001210:	86b2                	mv	a3,a2
    80001212:	863e                	mv	a2,a5
    80001214:	00000097          	auipc	ra,0x0
    80001218:	f52080e7          	jalr	-174(ra) # 80001166 <mappages>
    8000121c:	e509                	bnez	a0,80001226 <kvmmap+0x20>
}
    8000121e:	60a2                	ld	ra,8(sp)
    80001220:	6402                	ld	s0,0(sp)
    80001222:	0141                	addi	sp,sp,16
    80001224:	8082                	ret
    panic("kvmmap");
    80001226:	00007517          	auipc	a0,0x7
    8000122a:	f1250513          	addi	a0,a0,-238 # 80008138 <digits+0xe8>
    8000122e:	fffff097          	auipc	ra,0xfffff
    80001232:	312080e7          	jalr	786(ra) # 80000540 <panic>

0000000080001236 <kvmmake>:
{
    80001236:	1101                	addi	sp,sp,-32
    80001238:	ec06                	sd	ra,24(sp)
    8000123a:	e822                	sd	s0,16(sp)
    8000123c:	e426                	sd	s1,8(sp)
    8000123e:	e04a                	sd	s2,0(sp)
    80001240:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	920080e7          	jalr	-1760(ra) # 80000b62 <kalloc>
    8000124a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000124c:	6605                	lui	a2,0x1
    8000124e:	4581                	li	a1,0
    80001250:	00000097          	auipc	ra,0x0
    80001254:	b4a080e7          	jalr	-1206(ra) # 80000d9a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001258:	4719                	li	a4,6
    8000125a:	6685                	lui	a3,0x1
    8000125c:	10000637          	lui	a2,0x10000
    80001260:	100005b7          	lui	a1,0x10000
    80001264:	8526                	mv	a0,s1
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	fa0080e7          	jalr	-96(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000126e:	4719                	li	a4,6
    80001270:	6685                	lui	a3,0x1
    80001272:	10001637          	lui	a2,0x10001
    80001276:	100015b7          	lui	a1,0x10001
    8000127a:	8526                	mv	a0,s1
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	f8a080e7          	jalr	-118(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001284:	4719                	li	a4,6
    80001286:	004006b7          	lui	a3,0x400
    8000128a:	0c000637          	lui	a2,0xc000
    8000128e:	0c0005b7          	lui	a1,0xc000
    80001292:	8526                	mv	a0,s1
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f72080e7          	jalr	-142(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000129c:	00007917          	auipc	s2,0x7
    800012a0:	d6490913          	addi	s2,s2,-668 # 80008000 <etext>
    800012a4:	4729                	li	a4,10
    800012a6:	80007697          	auipc	a3,0x80007
    800012aa:	d5a68693          	addi	a3,a3,-678 # 8000 <_entry-0x7fff8000>
    800012ae:	4605                	li	a2,1
    800012b0:	067e                	slli	a2,a2,0x1f
    800012b2:	85b2                	mv	a1,a2
    800012b4:	8526                	mv	a0,s1
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	f50080e7          	jalr	-176(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012be:	4719                	li	a4,6
    800012c0:	46c5                	li	a3,17
    800012c2:	06ee                	slli	a3,a3,0x1b
    800012c4:	412686b3          	sub	a3,a3,s2
    800012c8:	864a                	mv	a2,s2
    800012ca:	85ca                	mv	a1,s2
    800012cc:	8526                	mv	a0,s1
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	f38080e7          	jalr	-200(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012d6:	4729                	li	a4,10
    800012d8:	6685                	lui	a3,0x1
    800012da:	00006617          	auipc	a2,0x6
    800012de:	d2660613          	addi	a2,a2,-730 # 80007000 <_trampoline>
    800012e2:	040005b7          	lui	a1,0x4000
    800012e6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012e8:	05b2                	slli	a1,a1,0xc
    800012ea:	8526                	mv	a0,s1
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	f1a080e7          	jalr	-230(ra) # 80001206 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012f4:	8526                	mv	a0,s1
    800012f6:	00000097          	auipc	ra,0x0
    800012fa:	734080e7          	jalr	1844(ra) # 80001a2a <proc_mapstacks>
}
    800012fe:	8526                	mv	a0,s1
    80001300:	60e2                	ld	ra,24(sp)
    80001302:	6442                	ld	s0,16(sp)
    80001304:	64a2                	ld	s1,8(sp)
    80001306:	6902                	ld	s2,0(sp)
    80001308:	6105                	addi	sp,sp,32
    8000130a:	8082                	ret

000000008000130c <kvminit>:
{
    8000130c:	1141                	addi	sp,sp,-16
    8000130e:	e406                	sd	ra,8(sp)
    80001310:	e022                	sd	s0,0(sp)
    80001312:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001314:	00000097          	auipc	ra,0x0
    80001318:	f22080e7          	jalr	-222(ra) # 80001236 <kvmmake>
    8000131c:	00007797          	auipc	a5,0x7
    80001320:	72a7ba23          	sd	a0,1844(a5) # 80008a50 <kernel_pagetable>
}
    80001324:	60a2                	ld	ra,8(sp)
    80001326:	6402                	ld	s0,0(sp)
    80001328:	0141                	addi	sp,sp,16
    8000132a:	8082                	ret

000000008000132c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000132c:	715d                	addi	sp,sp,-80
    8000132e:	e486                	sd	ra,72(sp)
    80001330:	e0a2                	sd	s0,64(sp)
    80001332:	fc26                	sd	s1,56(sp)
    80001334:	f84a                	sd	s2,48(sp)
    80001336:	f44e                	sd	s3,40(sp)
    80001338:	f052                	sd	s4,32(sp)
    8000133a:	ec56                	sd	s5,24(sp)
    8000133c:	e85a                	sd	s6,16(sp)
    8000133e:	e45e                	sd	s7,8(sp)
    80001340:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001342:	03459793          	slli	a5,a1,0x34
    80001346:	e795                	bnez	a5,80001372 <uvmunmap+0x46>
    80001348:	8a2a                	mv	s4,a0
    8000134a:	892e                	mv	s2,a1
    8000134c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134e:	0632                	slli	a2,a2,0xc
    80001350:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001354:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	6b05                	lui	s6,0x1
    80001358:	0735e263          	bltu	a1,s3,800013bc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000135c:	60a6                	ld	ra,72(sp)
    8000135e:	6406                	ld	s0,64(sp)
    80001360:	74e2                	ld	s1,56(sp)
    80001362:	7942                	ld	s2,48(sp)
    80001364:	79a2                	ld	s3,40(sp)
    80001366:	7a02                	ld	s4,32(sp)
    80001368:	6ae2                	ld	s5,24(sp)
    8000136a:	6b42                	ld	s6,16(sp)
    8000136c:	6ba2                	ld	s7,8(sp)
    8000136e:	6161                	addi	sp,sp,80
    80001370:	8082                	ret
    panic("uvmunmap: not aligned");
    80001372:	00007517          	auipc	a0,0x7
    80001376:	dce50513          	addi	a0,a0,-562 # 80008140 <digits+0xf0>
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	1c6080e7          	jalr	454(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    80001382:	00007517          	auipc	a0,0x7
    80001386:	dd650513          	addi	a0,a0,-554 # 80008158 <digits+0x108>
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	1b6080e7          	jalr	438(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    80001392:	00007517          	auipc	a0,0x7
    80001396:	dd650513          	addi	a0,a0,-554 # 80008168 <digits+0x118>
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	1a6080e7          	jalr	422(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800013a2:	00007517          	auipc	a0,0x7
    800013a6:	dde50513          	addi	a0,a0,-546 # 80008180 <digits+0x130>
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	196080e7          	jalr	406(ra) # 80000540 <panic>
    *pte = 0;
    800013b2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013b6:	995a                	add	s2,s2,s6
    800013b8:	fb3972e3          	bgeu	s2,s3,8000135c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013bc:	4601                	li	a2,0
    800013be:	85ca                	mv	a1,s2
    800013c0:	8552                	mv	a0,s4
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	cbc080e7          	jalr	-836(ra) # 8000107e <walk>
    800013ca:	84aa                	mv	s1,a0
    800013cc:	d95d                	beqz	a0,80001382 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013ce:	6108                	ld	a0,0(a0)
    800013d0:	00157793          	andi	a5,a0,1
    800013d4:	dfdd                	beqz	a5,80001392 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013d6:	3ff57793          	andi	a5,a0,1023
    800013da:	fd7784e3          	beq	a5,s7,800013a2 <uvmunmap+0x76>
    if(do_free){
    800013de:	fc0a8ae3          	beqz	s5,800013b2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013e2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013e4:	0532                	slli	a0,a0,0xc
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	614080e7          	jalr	1556(ra) # 800009fa <kfree>
    800013ee:	b7d1                	j	800013b2 <uvmunmap+0x86>

00000000800013f0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013f0:	1101                	addi	sp,sp,-32
    800013f2:	ec06                	sd	ra,24(sp)
    800013f4:	e822                	sd	s0,16(sp)
    800013f6:	e426                	sd	s1,8(sp)
    800013f8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	768080e7          	jalr	1896(ra) # 80000b62 <kalloc>
    80001402:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001404:	c519                	beqz	a0,80001412 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001406:	6605                	lui	a2,0x1
    80001408:	4581                	li	a1,0
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	990080e7          	jalr	-1648(ra) # 80000d9a <memset>
  return pagetable;
}
    80001412:	8526                	mv	a0,s1
    80001414:	60e2                	ld	ra,24(sp)
    80001416:	6442                	ld	s0,16(sp)
    80001418:	64a2                	ld	s1,8(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000141e:	7179                	addi	sp,sp,-48
    80001420:	f406                	sd	ra,40(sp)
    80001422:	f022                	sd	s0,32(sp)
    80001424:	ec26                	sd	s1,24(sp)
    80001426:	e84a                	sd	s2,16(sp)
    80001428:	e44e                	sd	s3,8(sp)
    8000142a:	e052                	sd	s4,0(sp)
    8000142c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000142e:	6785                	lui	a5,0x1
    80001430:	04f67863          	bgeu	a2,a5,80001480 <uvmfirst+0x62>
    80001434:	8a2a                	mv	s4,a0
    80001436:	89ae                	mv	s3,a1
    80001438:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	728080e7          	jalr	1832(ra) # 80000b62 <kalloc>
    80001442:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001444:	6605                	lui	a2,0x1
    80001446:	4581                	li	a1,0
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	952080e7          	jalr	-1710(ra) # 80000d9a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001450:	4779                	li	a4,30
    80001452:	86ca                	mv	a3,s2
    80001454:	6605                	lui	a2,0x1
    80001456:	4581                	li	a1,0
    80001458:	8552                	mv	a0,s4
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	d0c080e7          	jalr	-756(ra) # 80001166 <mappages>
  memmove(mem, src, sz);
    80001462:	8626                	mv	a2,s1
    80001464:	85ce                	mv	a1,s3
    80001466:	854a                	mv	a0,s2
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	98e080e7          	jalr	-1650(ra) # 80000df6 <memmove>
}
    80001470:	70a2                	ld	ra,40(sp)
    80001472:	7402                	ld	s0,32(sp)
    80001474:	64e2                	ld	s1,24(sp)
    80001476:	6942                	ld	s2,16(sp)
    80001478:	69a2                	ld	s3,8(sp)
    8000147a:	6a02                	ld	s4,0(sp)
    8000147c:	6145                	addi	sp,sp,48
    8000147e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001480:	00007517          	auipc	a0,0x7
    80001484:	d1850513          	addi	a0,a0,-744 # 80008198 <digits+0x148>
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	0b8080e7          	jalr	184(ra) # 80000540 <panic>

0000000080001490 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001490:	1101                	addi	sp,sp,-32
    80001492:	ec06                	sd	ra,24(sp)
    80001494:	e822                	sd	s0,16(sp)
    80001496:	e426                	sd	s1,8(sp)
    80001498:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000149a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000149c:	00b67d63          	bgeu	a2,a1,800014b6 <uvmdealloc+0x26>
    800014a0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014a2:	6785                	lui	a5,0x1
    800014a4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014a6:	00f60733          	add	a4,a2,a5
    800014aa:	76fd                	lui	a3,0xfffff
    800014ac:	8f75                	and	a4,a4,a3
    800014ae:	97ae                	add	a5,a5,a1
    800014b0:	8ff5                	and	a5,a5,a3
    800014b2:	00f76863          	bltu	a4,a5,800014c2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014b6:	8526                	mv	a0,s1
    800014b8:	60e2                	ld	ra,24(sp)
    800014ba:	6442                	ld	s0,16(sp)
    800014bc:	64a2                	ld	s1,8(sp)
    800014be:	6105                	addi	sp,sp,32
    800014c0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014c2:	8f99                	sub	a5,a5,a4
    800014c4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014c6:	4685                	li	a3,1
    800014c8:	0007861b          	sext.w	a2,a5
    800014cc:	85ba                	mv	a1,a4
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	e5e080e7          	jalr	-418(ra) # 8000132c <uvmunmap>
    800014d6:	b7c5                	j	800014b6 <uvmdealloc+0x26>

00000000800014d8 <uvmalloc>:
  if(newsz < oldsz)
    800014d8:	0ab66563          	bltu	a2,a1,80001582 <uvmalloc+0xaa>
{
    800014dc:	7139                	addi	sp,sp,-64
    800014de:	fc06                	sd	ra,56(sp)
    800014e0:	f822                	sd	s0,48(sp)
    800014e2:	f426                	sd	s1,40(sp)
    800014e4:	f04a                	sd	s2,32(sp)
    800014e6:	ec4e                	sd	s3,24(sp)
    800014e8:	e852                	sd	s4,16(sp)
    800014ea:	e456                	sd	s5,8(sp)
    800014ec:	e05a                	sd	s6,0(sp)
    800014ee:	0080                	addi	s0,sp,64
    800014f0:	8aaa                	mv	s5,a0
    800014f2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014f4:	6785                	lui	a5,0x1
    800014f6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014f8:	95be                	add	a1,a1,a5
    800014fa:	77fd                	lui	a5,0xfffff
    800014fc:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001500:	08c9f363          	bgeu	s3,a2,80001586 <uvmalloc+0xae>
    80001504:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001506:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	658080e7          	jalr	1624(ra) # 80000b62 <kalloc>
    80001512:	84aa                	mv	s1,a0
    if(mem == 0){
    80001514:	c51d                	beqz	a0,80001542 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001516:	6605                	lui	a2,0x1
    80001518:	4581                	li	a1,0
    8000151a:	00000097          	auipc	ra,0x0
    8000151e:	880080e7          	jalr	-1920(ra) # 80000d9a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001522:	875a                	mv	a4,s6
    80001524:	86a6                	mv	a3,s1
    80001526:	6605                	lui	a2,0x1
    80001528:	85ca                	mv	a1,s2
    8000152a:	8556                	mv	a0,s5
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	c3a080e7          	jalr	-966(ra) # 80001166 <mappages>
    80001534:	e90d                	bnez	a0,80001566 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001536:	6785                	lui	a5,0x1
    80001538:	993e                	add	s2,s2,a5
    8000153a:	fd4968e3          	bltu	s2,s4,8000150a <uvmalloc+0x32>
  return newsz;
    8000153e:	8552                	mv	a0,s4
    80001540:	a809                	j	80001552 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001542:	864e                	mv	a2,s3
    80001544:	85ca                	mv	a1,s2
    80001546:	8556                	mv	a0,s5
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	f48080e7          	jalr	-184(ra) # 80001490 <uvmdealloc>
      return 0;
    80001550:	4501                	li	a0,0
}
    80001552:	70e2                	ld	ra,56(sp)
    80001554:	7442                	ld	s0,48(sp)
    80001556:	74a2                	ld	s1,40(sp)
    80001558:	7902                	ld	s2,32(sp)
    8000155a:	69e2                	ld	s3,24(sp)
    8000155c:	6a42                	ld	s4,16(sp)
    8000155e:	6aa2                	ld	s5,8(sp)
    80001560:	6b02                	ld	s6,0(sp)
    80001562:	6121                	addi	sp,sp,64
    80001564:	8082                	ret
      kfree(mem);
    80001566:	8526                	mv	a0,s1
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	492080e7          	jalr	1170(ra) # 800009fa <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001570:	864e                	mv	a2,s3
    80001572:	85ca                	mv	a1,s2
    80001574:	8556                	mv	a0,s5
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	f1a080e7          	jalr	-230(ra) # 80001490 <uvmdealloc>
      return 0;
    8000157e:	4501                	li	a0,0
    80001580:	bfc9                	j	80001552 <uvmalloc+0x7a>
    return oldsz;
    80001582:	852e                	mv	a0,a1
}
    80001584:	8082                	ret
  return newsz;
    80001586:	8532                	mv	a0,a2
    80001588:	b7e9                	j	80001552 <uvmalloc+0x7a>

000000008000158a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000158a:	7179                	addi	sp,sp,-48
    8000158c:	f406                	sd	ra,40(sp)
    8000158e:	f022                	sd	s0,32(sp)
    80001590:	ec26                	sd	s1,24(sp)
    80001592:	e84a                	sd	s2,16(sp)
    80001594:	e44e                	sd	s3,8(sp)
    80001596:	e052                	sd	s4,0(sp)
    80001598:	1800                	addi	s0,sp,48
    8000159a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000159c:	84aa                	mv	s1,a0
    8000159e:	6905                	lui	s2,0x1
    800015a0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a2:	4985                	li	s3,1
    800015a4:	a829                	j	800015be <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015a6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015a8:	00c79513          	slli	a0,a5,0xc
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	fde080e7          	jalr	-34(ra) # 8000158a <freewalk>
      pagetable[i] = 0;
    800015b4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015b8:	04a1                	addi	s1,s1,8
    800015ba:	03248163          	beq	s1,s2,800015dc <freewalk+0x52>
    pte_t pte = pagetable[i];
    800015be:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c0:	00f7f713          	andi	a4,a5,15
    800015c4:	ff3701e3          	beq	a4,s3,800015a6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015c8:	8b85                	andi	a5,a5,1
    800015ca:	d7fd                	beqz	a5,800015b8 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	bec50513          	addi	a0,a0,-1044 # 800081b8 <digits+0x168>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f6c080e7          	jalr	-148(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    800015dc:	8552                	mv	a0,s4
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	41c080e7          	jalr	1052(ra) # 800009fa <kfree>
}
    800015e6:	70a2                	ld	ra,40(sp)
    800015e8:	7402                	ld	s0,32(sp)
    800015ea:	64e2                	ld	s1,24(sp)
    800015ec:	6942                	ld	s2,16(sp)
    800015ee:	69a2                	ld	s3,8(sp)
    800015f0:	6a02                	ld	s4,0(sp)
    800015f2:	6145                	addi	sp,sp,48
    800015f4:	8082                	ret

00000000800015f6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015f6:	1101                	addi	sp,sp,-32
    800015f8:	ec06                	sd	ra,24(sp)
    800015fa:	e822                	sd	s0,16(sp)
    800015fc:	e426                	sd	s1,8(sp)
    800015fe:	1000                	addi	s0,sp,32
    80001600:	84aa                	mv	s1,a0
  if(sz > 0)
    80001602:	e999                	bnez	a1,80001618 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001604:	8526                	mv	a0,s1
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	f84080e7          	jalr	-124(ra) # 8000158a <freewalk>
}
    8000160e:	60e2                	ld	ra,24(sp)
    80001610:	6442                	ld	s0,16(sp)
    80001612:	64a2                	ld	s1,8(sp)
    80001614:	6105                	addi	sp,sp,32
    80001616:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001618:	6785                	lui	a5,0x1
    8000161a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000161c:	95be                	add	a1,a1,a5
    8000161e:	4685                	li	a3,1
    80001620:	00c5d613          	srli	a2,a1,0xc
    80001624:	4581                	li	a1,0
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	d06080e7          	jalr	-762(ra) # 8000132c <uvmunmap>
    8000162e:	bfd9                	j	80001604 <uvmfree+0xe>

0000000080001630 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001630:	c679                	beqz	a2,800016fe <uvmcopy+0xce>
{
    80001632:	715d                	addi	sp,sp,-80
    80001634:	e486                	sd	ra,72(sp)
    80001636:	e0a2                	sd	s0,64(sp)
    80001638:	fc26                	sd	s1,56(sp)
    8000163a:	f84a                	sd	s2,48(sp)
    8000163c:	f44e                	sd	s3,40(sp)
    8000163e:	f052                	sd	s4,32(sp)
    80001640:	ec56                	sd	s5,24(sp)
    80001642:	e85a                	sd	s6,16(sp)
    80001644:	e45e                	sd	s7,8(sp)
    80001646:	0880                	addi	s0,sp,80
    80001648:	8b2a                	mv	s6,a0
    8000164a:	8aae                	mv	s5,a1
    8000164c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001650:	4601                	li	a2,0
    80001652:	85ce                	mv	a1,s3
    80001654:	855a                	mv	a0,s6
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	a28080e7          	jalr	-1496(ra) # 8000107e <walk>
    8000165e:	c531                	beqz	a0,800016aa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001660:	6118                	ld	a4,0(a0)
    80001662:	00177793          	andi	a5,a4,1
    80001666:	cbb1                	beqz	a5,800016ba <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001668:	00a75593          	srli	a1,a4,0xa
    8000166c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001670:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	4ee080e7          	jalr	1262(ra) # 80000b62 <kalloc>
    8000167c:	892a                	mv	s2,a0
    8000167e:	c939                	beqz	a0,800016d4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001680:	6605                	lui	a2,0x1
    80001682:	85de                	mv	a1,s7
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	772080e7          	jalr	1906(ra) # 80000df6 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000168c:	8726                	mv	a4,s1
    8000168e:	86ca                	mv	a3,s2
    80001690:	6605                	lui	a2,0x1
    80001692:	85ce                	mv	a1,s3
    80001694:	8556                	mv	a0,s5
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	ad0080e7          	jalr	-1328(ra) # 80001166 <mappages>
    8000169e:	e515                	bnez	a0,800016ca <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016a0:	6785                	lui	a5,0x1
    800016a2:	99be                	add	s3,s3,a5
    800016a4:	fb49e6e3          	bltu	s3,s4,80001650 <uvmcopy+0x20>
    800016a8:	a081                	j	800016e8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016aa:	00007517          	auipc	a0,0x7
    800016ae:	b1e50513          	addi	a0,a0,-1250 # 800081c8 <digits+0x178>
    800016b2:	fffff097          	auipc	ra,0xfffff
    800016b6:	e8e080e7          	jalr	-370(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800016ba:	00007517          	auipc	a0,0x7
    800016be:	b2e50513          	addi	a0,a0,-1234 # 800081e8 <digits+0x198>
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	e7e080e7          	jalr	-386(ra) # 80000540 <panic>
      kfree(mem);
    800016ca:	854a                	mv	a0,s2
    800016cc:	fffff097          	auipc	ra,0xfffff
    800016d0:	32e080e7          	jalr	814(ra) # 800009fa <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d4:	4685                	li	a3,1
    800016d6:	00c9d613          	srli	a2,s3,0xc
    800016da:	4581                	li	a1,0
    800016dc:	8556                	mv	a0,s5
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	c4e080e7          	jalr	-946(ra) # 8000132c <uvmunmap>
  return -1;
    800016e6:	557d                	li	a0,-1
}
    800016e8:	60a6                	ld	ra,72(sp)
    800016ea:	6406                	ld	s0,64(sp)
    800016ec:	74e2                	ld	s1,56(sp)
    800016ee:	7942                	ld	s2,48(sp)
    800016f0:	79a2                	ld	s3,40(sp)
    800016f2:	7a02                	ld	s4,32(sp)
    800016f4:	6ae2                	ld	s5,24(sp)
    800016f6:	6b42                	ld	s6,16(sp)
    800016f8:	6ba2                	ld	s7,8(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret
  return 0;
    800016fe:	4501                	li	a0,0
}
    80001700:	8082                	ret

0000000080001702 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001702:	1141                	addi	sp,sp,-16
    80001704:	e406                	sd	ra,8(sp)
    80001706:	e022                	sd	s0,0(sp)
    80001708:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000170a:	4601                	li	a2,0
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	972080e7          	jalr	-1678(ra) # 8000107e <walk>
  if(pte == 0)
    80001714:	c901                	beqz	a0,80001724 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001716:	611c                	ld	a5,0(a0)
    80001718:	9bbd                	andi	a5,a5,-17
    8000171a:	e11c                	sd	a5,0(a0)
}
    8000171c:	60a2                	ld	ra,8(sp)
    8000171e:	6402                	ld	s0,0(sp)
    80001720:	0141                	addi	sp,sp,16
    80001722:	8082                	ret
    panic("uvmclear");
    80001724:	00007517          	auipc	a0,0x7
    80001728:	ae450513          	addi	a0,a0,-1308 # 80008208 <digits+0x1b8>
    8000172c:	fffff097          	auipc	ra,0xfffff
    80001730:	e14080e7          	jalr	-492(ra) # 80000540 <panic>

0000000080001734 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001734:	c6bd                	beqz	a3,800017a2 <copyout+0x6e>
{
    80001736:	715d                	addi	sp,sp,-80
    80001738:	e486                	sd	ra,72(sp)
    8000173a:	e0a2                	sd	s0,64(sp)
    8000173c:	fc26                	sd	s1,56(sp)
    8000173e:	f84a                	sd	s2,48(sp)
    80001740:	f44e                	sd	s3,40(sp)
    80001742:	f052                	sd	s4,32(sp)
    80001744:	ec56                	sd	s5,24(sp)
    80001746:	e85a                	sd	s6,16(sp)
    80001748:	e45e                	sd	s7,8(sp)
    8000174a:	e062                	sd	s8,0(sp)
    8000174c:	0880                	addi	s0,sp,80
    8000174e:	8b2a                	mv	s6,a0
    80001750:	8c2e                	mv	s8,a1
    80001752:	8a32                	mv	s4,a2
    80001754:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001756:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001758:	6a85                	lui	s5,0x1
    8000175a:	a015                	j	8000177e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000175c:	9562                	add	a0,a0,s8
    8000175e:	0004861b          	sext.w	a2,s1
    80001762:	85d2                	mv	a1,s4
    80001764:	41250533          	sub	a0,a0,s2
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	68e080e7          	jalr	1678(ra) # 80000df6 <memmove>

    len -= n;
    80001770:	409989b3          	sub	s3,s3,s1
    src += n;
    80001774:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001776:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177a:	02098263          	beqz	s3,8000179e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000177e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001782:	85ca                	mv	a1,s2
    80001784:	855a                	mv	a0,s6
    80001786:	00000097          	auipc	ra,0x0
    8000178a:	99e080e7          	jalr	-1634(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    8000178e:	cd01                	beqz	a0,800017a6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001790:	418904b3          	sub	s1,s2,s8
    80001794:	94d6                	add	s1,s1,s5
    80001796:	fc99f3e3          	bgeu	s3,s1,8000175c <copyout+0x28>
    8000179a:	84ce                	mv	s1,s3
    8000179c:	b7c1                	j	8000175c <copyout+0x28>
  }
  return 0;
    8000179e:	4501                	li	a0,0
    800017a0:	a021                	j	800017a8 <copyout+0x74>
    800017a2:	4501                	li	a0,0
}
    800017a4:	8082                	ret
      return -1;
    800017a6:	557d                	li	a0,-1
}
    800017a8:	60a6                	ld	ra,72(sp)
    800017aa:	6406                	ld	s0,64(sp)
    800017ac:	74e2                	ld	s1,56(sp)
    800017ae:	7942                	ld	s2,48(sp)
    800017b0:	79a2                	ld	s3,40(sp)
    800017b2:	7a02                	ld	s4,32(sp)
    800017b4:	6ae2                	ld	s5,24(sp)
    800017b6:	6b42                	ld	s6,16(sp)
    800017b8:	6ba2                	ld	s7,8(sp)
    800017ba:	6c02                	ld	s8,0(sp)
    800017bc:	6161                	addi	sp,sp,80
    800017be:	8082                	ret

00000000800017c0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c0:	caa5                	beqz	a3,80001830 <copyin+0x70>
{
    800017c2:	715d                	addi	sp,sp,-80
    800017c4:	e486                	sd	ra,72(sp)
    800017c6:	e0a2                	sd	s0,64(sp)
    800017c8:	fc26                	sd	s1,56(sp)
    800017ca:	f84a                	sd	s2,48(sp)
    800017cc:	f44e                	sd	s3,40(sp)
    800017ce:	f052                	sd	s4,32(sp)
    800017d0:	ec56                	sd	s5,24(sp)
    800017d2:	e85a                	sd	s6,16(sp)
    800017d4:	e45e                	sd	s7,8(sp)
    800017d6:	e062                	sd	s8,0(sp)
    800017d8:	0880                	addi	s0,sp,80
    800017da:	8b2a                	mv	s6,a0
    800017dc:	8a2e                	mv	s4,a1
    800017de:	8c32                	mv	s8,a2
    800017e0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017e2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e4:	6a85                	lui	s5,0x1
    800017e6:	a01d                	j	8000180c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017e8:	018505b3          	add	a1,a0,s8
    800017ec:	0004861b          	sext.w	a2,s1
    800017f0:	412585b3          	sub	a1,a1,s2
    800017f4:	8552                	mv	a0,s4
    800017f6:	fffff097          	auipc	ra,0xfffff
    800017fa:	600080e7          	jalr	1536(ra) # 80000df6 <memmove>

    len -= n;
    800017fe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001802:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001804:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001808:	02098263          	beqz	s3,8000182c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000180c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001810:	85ca                	mv	a1,s2
    80001812:	855a                	mv	a0,s6
    80001814:	00000097          	auipc	ra,0x0
    80001818:	910080e7          	jalr	-1776(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    8000181c:	cd01                	beqz	a0,80001834 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000181e:	418904b3          	sub	s1,s2,s8
    80001822:	94d6                	add	s1,s1,s5
    80001824:	fc99f2e3          	bgeu	s3,s1,800017e8 <copyin+0x28>
    80001828:	84ce                	mv	s1,s3
    8000182a:	bf7d                	j	800017e8 <copyin+0x28>
  }
  return 0;
    8000182c:	4501                	li	a0,0
    8000182e:	a021                	j	80001836 <copyin+0x76>
    80001830:	4501                	li	a0,0
}
    80001832:	8082                	ret
      return -1;
    80001834:	557d                	li	a0,-1
}
    80001836:	60a6                	ld	ra,72(sp)
    80001838:	6406                	ld	s0,64(sp)
    8000183a:	74e2                	ld	s1,56(sp)
    8000183c:	7942                	ld	s2,48(sp)
    8000183e:	79a2                	ld	s3,40(sp)
    80001840:	7a02                	ld	s4,32(sp)
    80001842:	6ae2                	ld	s5,24(sp)
    80001844:	6b42                	ld	s6,16(sp)
    80001846:	6ba2                	ld	s7,8(sp)
    80001848:	6c02                	ld	s8,0(sp)
    8000184a:	6161                	addi	sp,sp,80
    8000184c:	8082                	ret

000000008000184e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000184e:	c2dd                	beqz	a3,800018f4 <copyinstr+0xa6>
{
    80001850:	715d                	addi	sp,sp,-80
    80001852:	e486                	sd	ra,72(sp)
    80001854:	e0a2                	sd	s0,64(sp)
    80001856:	fc26                	sd	s1,56(sp)
    80001858:	f84a                	sd	s2,48(sp)
    8000185a:	f44e                	sd	s3,40(sp)
    8000185c:	f052                	sd	s4,32(sp)
    8000185e:	ec56                	sd	s5,24(sp)
    80001860:	e85a                	sd	s6,16(sp)
    80001862:	e45e                	sd	s7,8(sp)
    80001864:	0880                	addi	s0,sp,80
    80001866:	8a2a                	mv	s4,a0
    80001868:	8b2e                	mv	s6,a1
    8000186a:	8bb2                	mv	s7,a2
    8000186c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000186e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001870:	6985                	lui	s3,0x1
    80001872:	a02d                	j	8000189c <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001874:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001878:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000187a:	37fd                	addiw	a5,a5,-1
    8000187c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001880:	60a6                	ld	ra,72(sp)
    80001882:	6406                	ld	s0,64(sp)
    80001884:	74e2                	ld	s1,56(sp)
    80001886:	7942                	ld	s2,48(sp)
    80001888:	79a2                	ld	s3,40(sp)
    8000188a:	7a02                	ld	s4,32(sp)
    8000188c:	6ae2                	ld	s5,24(sp)
    8000188e:	6b42                	ld	s6,16(sp)
    80001890:	6ba2                	ld	s7,8(sp)
    80001892:	6161                	addi	sp,sp,80
    80001894:	8082                	ret
    srcva = va0 + PGSIZE;
    80001896:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000189a:	c8a9                	beqz	s1,800018ec <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000189c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018a0:	85ca                	mv	a1,s2
    800018a2:	8552                	mv	a0,s4
    800018a4:	00000097          	auipc	ra,0x0
    800018a8:	880080e7          	jalr	-1920(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    800018ac:	c131                	beqz	a0,800018f0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800018ae:	417906b3          	sub	a3,s2,s7
    800018b2:	96ce                	add	a3,a3,s3
    800018b4:	00d4f363          	bgeu	s1,a3,800018ba <copyinstr+0x6c>
    800018b8:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018ba:	955e                	add	a0,a0,s7
    800018bc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018c0:	daf9                	beqz	a3,80001896 <copyinstr+0x48>
    800018c2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018c4:	41650633          	sub	a2,a0,s6
    800018c8:	fff48593          	addi	a1,s1,-1
    800018cc:	95da                	add	a1,a1,s6
    while(n > 0){
    800018ce:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800018d0:	00f60733          	add	a4,a2,a5
    800018d4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd120>
    800018d8:	df51                	beqz	a4,80001874 <copyinstr+0x26>
        *dst = *p;
    800018da:	00e78023          	sb	a4,0(a5)
      --max;
    800018de:	40f584b3          	sub	s1,a1,a5
      dst++;
    800018e2:	0785                	addi	a5,a5,1
    while(n > 0){
    800018e4:	fed796e3          	bne	a5,a3,800018d0 <copyinstr+0x82>
      dst++;
    800018e8:	8b3e                	mv	s6,a5
    800018ea:	b775                	j	80001896 <copyinstr+0x48>
    800018ec:	4781                	li	a5,0
    800018ee:	b771                	j	8000187a <copyinstr+0x2c>
      return -1;
    800018f0:	557d                	li	a0,-1
    800018f2:	b779                	j	80001880 <copyinstr+0x32>
  int got_null = 0;
    800018f4:	4781                	li	a5,0
  if(got_null){
    800018f6:	37fd                	addiw	a5,a5,-1
    800018f8:	0007851b          	sext.w	a0,a5
}
    800018fc:	8082                	ret

00000000800018fe <transvirt>:

uint64 transvirt(uint64 vaddr, pagetable_t pagetable)
{
    800018fe:	1141                	addi	sp,sp,-16
    80001900:	e422                	sd	s0,8(sp)
    80001902:	0800                	addi	s0,sp,16
    80001904:	872a                	mv	a4,a0
    for (int level = 2; level > 0; level--)
    {
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001906:	01e55793          	srli	a5,a0,0x1e
    8000190a:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    8000190e:	078e                	slli	a5,a5,0x3
    80001910:	95be                	add	a1,a1,a5
    80001912:	619c                	ld	a5,0(a1)
    80001914:	0017f513          	andi	a0,a5,1
    80001918:	cd15                	beqz	a0,80001954 <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    8000191a:	83a9                	srli	a5,a5,0xa
    8000191c:	00c79693          	slli	a3,a5,0xc
	pte_t *pte = &pagetable[PX(level, vaddr)];
    80001920:	01575793          	srli	a5,a4,0x15
    80001924:	1ff7f793          	andi	a5,a5,511
	if (*pte & PTE_V) {
    80001928:	078e                	slli	a5,a5,0x3
    8000192a:	97b6                	add	a5,a5,a3
    8000192c:	639c                	ld	a5,0(a5)
    8000192e:	0017f513          	andi	a0,a5,1
    80001932:	c10d                	beqz	a0,80001954 <transvirt+0x56>
	    pagetable = (pagetable_t) PTE2PA(*pte);
    80001934:	83a9                	srli	a5,a5,0xa
    80001936:	00c79693          	slli	a3,a5,0xc
	} else {
	    return 0;
	}
    }
    uint64 pagenum = PTE2PA(pagetable[PX(0, vaddr)]);
    8000193a:	00c75793          	srli	a5,a4,0xc
    8000193e:	1ff7f793          	andi	a5,a5,511
    80001942:	078e                	slli	a5,a5,0x3
    80001944:	97b6                	add	a5,a5,a3
    80001946:	639c                	ld	a5,0(a5)
    80001948:	83a9                	srli	a5,a5,0xa
    8000194a:	07b2                	slli	a5,a5,0xc
    uint64 offset = vaddr & 0xFFF;
    8000194c:	1752                	slli	a4,a4,0x34
    8000194e:	9351                	srli	a4,a4,0x34
    return pagenum | offset;
    80001950:	00e7e533          	or	a0,a5,a4
}
    80001954:	6422                	ld	s0,8(sp)
    80001956:	0141                	addi	sp,sp,16
    80001958:	8082                	ret

000000008000195a <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
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
    8000196e:	e062                	sd	s8,0(sp)
    80001970:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001972:	8792                	mv	a5,tp
    int id = r_tp();
    80001974:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001976:	0000fa97          	auipc	s5,0xf
    8000197a:	35aa8a93          	addi	s5,s5,858 # 80010cd0 <cpus>
    8000197e:	00779713          	slli	a4,a5,0x7
    80001982:	00ea86b3          	add	a3,s5,a4
    80001986:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd120>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    8000198a:	0721                	addi	a4,a4,8
    8000198c:	9aba                	add	s5,s5,a4
                c->proc = p;
    8000198e:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001990:	00007c17          	auipc	s8,0x7
    80001994:	ff8c0c13          	addi	s8,s8,-8 # 80008988 <sched_pointer>
    80001998:	00000b97          	auipc	s7,0x0
    8000199c:	fc2b8b93          	addi	s7,s7,-62 # 8000195a <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800019a0:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    800019a4:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    800019a8:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    800019ac:	0000f497          	auipc	s1,0xf
    800019b0:	75448493          	addi	s1,s1,1876 # 80011100 <proc>
            if (p->state == RUNNABLE)
    800019b4:	498d                	li	s3,3
                p->state = RUNNING;
    800019b6:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    800019b8:	00015a17          	auipc	s4,0x15
    800019bc:	148a0a13          	addi	s4,s4,328 # 80016b00 <tickslock>
    800019c0:	a81d                	j	800019f6 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    800019c2:	8526                	mv	a0,s1
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	38e080e7          	jalr	910(ra) # 80000d52 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    800019cc:	60a6                	ld	ra,72(sp)
    800019ce:	6406                	ld	s0,64(sp)
    800019d0:	74e2                	ld	s1,56(sp)
    800019d2:	7942                	ld	s2,48(sp)
    800019d4:	79a2                	ld	s3,40(sp)
    800019d6:	7a02                	ld	s4,32(sp)
    800019d8:	6ae2                	ld	s5,24(sp)
    800019da:	6b42                	ld	s6,16(sp)
    800019dc:	6ba2                	ld	s7,8(sp)
    800019de:	6c02                	ld	s8,0(sp)
    800019e0:	6161                	addi	sp,sp,80
    800019e2:	8082                	ret
            release(&p->lock);
    800019e4:	8526                	mv	a0,s1
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	36c080e7          	jalr	876(ra) # 80000d52 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    800019ee:	16848493          	addi	s1,s1,360
    800019f2:	fb4487e3          	beq	s1,s4,800019a0 <rr_scheduler+0x46>
            acquire(&p->lock);
    800019f6:	8526                	mv	a0,s1
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	2a6080e7          	jalr	678(ra) # 80000c9e <acquire>
            if (p->state == RUNNABLE)
    80001a00:	4c9c                	lw	a5,24(s1)
    80001a02:	ff3791e3          	bne	a5,s3,800019e4 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001a06:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001a0a:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    80001a0e:	06048593          	addi	a1,s1,96
    80001a12:	8556                	mv	a0,s5
    80001a14:	00001097          	auipc	ra,0x1
    80001a18:	024080e7          	jalr	36(ra) # 80002a38 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001a1c:	000c3783          	ld	a5,0(s8)
    80001a20:	fb7791e3          	bne	a5,s7,800019c2 <rr_scheduler+0x68>
                c->proc = 0;
    80001a24:	00093023          	sd	zero,0(s2)
    80001a28:	bf75                	j	800019e4 <rr_scheduler+0x8a>

0000000080001a2a <proc_mapstacks>:
{
    80001a2a:	7139                	addi	sp,sp,-64
    80001a2c:	fc06                	sd	ra,56(sp)
    80001a2e:	f822                	sd	s0,48(sp)
    80001a30:	f426                	sd	s1,40(sp)
    80001a32:	f04a                	sd	s2,32(sp)
    80001a34:	ec4e                	sd	s3,24(sp)
    80001a36:	e852                	sd	s4,16(sp)
    80001a38:	e456                	sd	s5,8(sp)
    80001a3a:	e05a                	sd	s6,0(sp)
    80001a3c:	0080                	addi	s0,sp,64
    80001a3e:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001a40:	0000f497          	auipc	s1,0xf
    80001a44:	6c048493          	addi	s1,s1,1728 # 80011100 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001a48:	8b26                	mv	s6,s1
    80001a4a:	00006a97          	auipc	s5,0x6
    80001a4e:	5c6a8a93          	addi	s5,s5,1478 # 80008010 <__func__.1+0x8>
    80001a52:	04000937          	lui	s2,0x4000
    80001a56:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a58:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001a5a:	00015a17          	auipc	s4,0x15
    80001a5e:	0a6a0a13          	addi	s4,s4,166 # 80016b00 <tickslock>
        char *pa = kalloc();
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	100080e7          	jalr	256(ra) # 80000b62 <kalloc>
    80001a6a:	862a                	mv	a2,a0
        if (pa == 0)
    80001a6c:	c131                	beqz	a0,80001ab0 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001a6e:	416485b3          	sub	a1,s1,s6
    80001a72:	858d                	srai	a1,a1,0x3
    80001a74:	000ab783          	ld	a5,0(s5)
    80001a78:	02f585b3          	mul	a1,a1,a5
    80001a7c:	2585                	addiw	a1,a1,1
    80001a7e:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a82:	4719                	li	a4,6
    80001a84:	6685                	lui	a3,0x1
    80001a86:	40b905b3          	sub	a1,s2,a1
    80001a8a:	854e                	mv	a0,s3
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	77a080e7          	jalr	1914(ra) # 80001206 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001a94:	16848493          	addi	s1,s1,360
    80001a98:	fd4495e3          	bne	s1,s4,80001a62 <proc_mapstacks+0x38>
}
    80001a9c:	70e2                	ld	ra,56(sp)
    80001a9e:	7442                	ld	s0,48(sp)
    80001aa0:	74a2                	ld	s1,40(sp)
    80001aa2:	7902                	ld	s2,32(sp)
    80001aa4:	69e2                	ld	s3,24(sp)
    80001aa6:	6a42                	ld	s4,16(sp)
    80001aa8:	6aa2                	ld	s5,8(sp)
    80001aaa:	6b02                	ld	s6,0(sp)
    80001aac:	6121                	addi	sp,sp,64
    80001aae:	8082                	ret
            panic("kalloc");
    80001ab0:	00006517          	auipc	a0,0x6
    80001ab4:	76850513          	addi	a0,a0,1896 # 80008218 <digits+0x1c8>
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	a88080e7          	jalr	-1400(ra) # 80000540 <panic>

0000000080001ac0 <procinit>:
{
    80001ac0:	7139                	addi	sp,sp,-64
    80001ac2:	fc06                	sd	ra,56(sp)
    80001ac4:	f822                	sd	s0,48(sp)
    80001ac6:	f426                	sd	s1,40(sp)
    80001ac8:	f04a                	sd	s2,32(sp)
    80001aca:	ec4e                	sd	s3,24(sp)
    80001acc:	e852                	sd	s4,16(sp)
    80001ace:	e456                	sd	s5,8(sp)
    80001ad0:	e05a                	sd	s6,0(sp)
    80001ad2:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001ad4:	00006597          	auipc	a1,0x6
    80001ad8:	74c58593          	addi	a1,a1,1868 # 80008220 <digits+0x1d0>
    80001adc:	0000f517          	auipc	a0,0xf
    80001ae0:	5f450513          	addi	a0,a0,1524 # 800110d0 <pid_lock>
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	12a080e7          	jalr	298(ra) # 80000c0e <initlock>
    initlock(&wait_lock, "wait_lock");
    80001aec:	00006597          	auipc	a1,0x6
    80001af0:	73c58593          	addi	a1,a1,1852 # 80008228 <digits+0x1d8>
    80001af4:	0000f517          	auipc	a0,0xf
    80001af8:	5f450513          	addi	a0,a0,1524 # 800110e8 <wait_lock>
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	112080e7          	jalr	274(ra) # 80000c0e <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b04:	0000f497          	auipc	s1,0xf
    80001b08:	5fc48493          	addi	s1,s1,1532 # 80011100 <proc>
        initlock(&p->lock, "proc");
    80001b0c:	00006b17          	auipc	s6,0x6
    80001b10:	72cb0b13          	addi	s6,s6,1836 # 80008238 <digits+0x1e8>
        p->kstack = KSTACK((int)(p - proc));
    80001b14:	8aa6                	mv	s5,s1
    80001b16:	00006a17          	auipc	s4,0x6
    80001b1a:	4faa0a13          	addi	s4,s4,1274 # 80008010 <__func__.1+0x8>
    80001b1e:	04000937          	lui	s2,0x4000
    80001b22:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b24:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b26:	00015997          	auipc	s3,0x15
    80001b2a:	fda98993          	addi	s3,s3,-38 # 80016b00 <tickslock>
        initlock(&p->lock, "proc");
    80001b2e:	85da                	mv	a1,s6
    80001b30:	8526                	mv	a0,s1
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	0dc080e7          	jalr	220(ra) # 80000c0e <initlock>
        p->state = UNUSED;
    80001b3a:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001b3e:	415487b3          	sub	a5,s1,s5
    80001b42:	878d                	srai	a5,a5,0x3
    80001b44:	000a3703          	ld	a4,0(s4)
    80001b48:	02e787b3          	mul	a5,a5,a4
    80001b4c:	2785                	addiw	a5,a5,1
    80001b4e:	00d7979b          	slliw	a5,a5,0xd
    80001b52:	40f907b3          	sub	a5,s2,a5
    80001b56:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001b58:	16848493          	addi	s1,s1,360
    80001b5c:	fd3499e3          	bne	s1,s3,80001b2e <procinit+0x6e>
}
    80001b60:	70e2                	ld	ra,56(sp)
    80001b62:	7442                	ld	s0,48(sp)
    80001b64:	74a2                	ld	s1,40(sp)
    80001b66:	7902                	ld	s2,32(sp)
    80001b68:	69e2                	ld	s3,24(sp)
    80001b6a:	6a42                	ld	s4,16(sp)
    80001b6c:	6aa2                	ld	s5,8(sp)
    80001b6e:	6b02                	ld	s6,0(sp)
    80001b70:	6121                	addi	sp,sp,64
    80001b72:	8082                	ret

0000000080001b74 <copy_array>:
{
    80001b74:	1141                	addi	sp,sp,-16
    80001b76:	e422                	sd	s0,8(sp)
    80001b78:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001b7a:	02c05163          	blez	a2,80001b9c <copy_array+0x28>
    80001b7e:	87aa                	mv	a5,a0
    80001b80:	0505                	addi	a0,a0,1
    80001b82:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001b84:	1602                	slli	a2,a2,0x20
    80001b86:	9201                	srli	a2,a2,0x20
    80001b88:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001b8c:	0007c703          	lbu	a4,0(a5)
    80001b90:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001b94:	0785                	addi	a5,a5,1
    80001b96:	0585                	addi	a1,a1,1
    80001b98:	fed79ae3          	bne	a5,a3,80001b8c <copy_array+0x18>
}
    80001b9c:	6422                	ld	s0,8(sp)
    80001b9e:	0141                	addi	sp,sp,16
    80001ba0:	8082                	ret

0000000080001ba2 <cpuid>:
{
    80001ba2:	1141                	addi	sp,sp,-16
    80001ba4:	e422                	sd	s0,8(sp)
    80001ba6:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001ba8:	8512                	mv	a0,tp
}
    80001baa:	2501                	sext.w	a0,a0
    80001bac:	6422                	ld	s0,8(sp)
    80001bae:	0141                	addi	sp,sp,16
    80001bb0:	8082                	ret

0000000080001bb2 <mycpu>:
{
    80001bb2:	1141                	addi	sp,sp,-16
    80001bb4:	e422                	sd	s0,8(sp)
    80001bb6:	0800                	addi	s0,sp,16
    80001bb8:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001bba:	2781                	sext.w	a5,a5
    80001bbc:	079e                	slli	a5,a5,0x7
}
    80001bbe:	0000f517          	auipc	a0,0xf
    80001bc2:	11250513          	addi	a0,a0,274 # 80010cd0 <cpus>
    80001bc6:	953e                	add	a0,a0,a5
    80001bc8:	6422                	ld	s0,8(sp)
    80001bca:	0141                	addi	sp,sp,16
    80001bcc:	8082                	ret

0000000080001bce <myproc>:
{
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
    push_off();
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	07a080e7          	jalr	122(ra) # 80000c52 <push_off>
    80001be0:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001be2:	2781                	sext.w	a5,a5
    80001be4:	079e                	slli	a5,a5,0x7
    80001be6:	0000f717          	auipc	a4,0xf
    80001bea:	0ea70713          	addi	a4,a4,234 # 80010cd0 <cpus>
    80001bee:	97ba                	add	a5,a5,a4
    80001bf0:	6384                	ld	s1,0(a5)
    pop_off();
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	100080e7          	jalr	256(ra) # 80000cf2 <pop_off>
}
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	60e2                	ld	ra,24(sp)
    80001bfe:	6442                	ld	s0,16(sp)
    80001c00:	64a2                	ld	s1,8(sp)
    80001c02:	6105                	addi	sp,sp,32
    80001c04:	8082                	ret

0000000080001c06 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c06:	1141                	addi	sp,sp,-16
    80001c08:	e406                	sd	ra,8(sp)
    80001c0a:	e022                	sd	s0,0(sp)
    80001c0c:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	fc0080e7          	jalr	-64(ra) # 80001bce <myproc>
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	13c080e7          	jalr	316(ra) # 80000d52 <release>

    if (first)
    80001c1e:	00007797          	auipc	a5,0x7
    80001c22:	d627a783          	lw	a5,-670(a5) # 80008980 <first.1>
    80001c26:	eb89                	bnez	a5,80001c38 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001c28:	00001097          	auipc	ra,0x1
    80001c2c:	eba080e7          	jalr	-326(ra) # 80002ae2 <usertrapret>
}
    80001c30:	60a2                	ld	ra,8(sp)
    80001c32:	6402                	ld	s0,0(sp)
    80001c34:	0141                	addi	sp,sp,16
    80001c36:	8082                	ret
        first = 0;
    80001c38:	00007797          	auipc	a5,0x7
    80001c3c:	d407a423          	sw	zero,-696(a5) # 80008980 <first.1>
        fsinit(ROOTDEV);
    80001c40:	4505                	li	a0,1
    80001c42:	00002097          	auipc	ra,0x2
    80001c46:	d18080e7          	jalr	-744(ra) # 8000395a <fsinit>
    80001c4a:	bff9                	j	80001c28 <forkret+0x22>

0000000080001c4c <allocpid>:
{
    80001c4c:	1101                	addi	sp,sp,-32
    80001c4e:	ec06                	sd	ra,24(sp)
    80001c50:	e822                	sd	s0,16(sp)
    80001c52:	e426                	sd	s1,8(sp)
    80001c54:	e04a                	sd	s2,0(sp)
    80001c56:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001c58:	0000f917          	auipc	s2,0xf
    80001c5c:	47890913          	addi	s2,s2,1144 # 800110d0 <pid_lock>
    80001c60:	854a                	mv	a0,s2
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	03c080e7          	jalr	60(ra) # 80000c9e <acquire>
    pid = nextpid;
    80001c6a:	00007797          	auipc	a5,0x7
    80001c6e:	d2678793          	addi	a5,a5,-730 # 80008990 <nextpid>
    80001c72:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001c74:	0014871b          	addiw	a4,s1,1
    80001c78:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001c7a:	854a                	mv	a0,s2
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	0d6080e7          	jalr	214(ra) # 80000d52 <release>
}
    80001c84:	8526                	mv	a0,s1
    80001c86:	60e2                	ld	ra,24(sp)
    80001c88:	6442                	ld	s0,16(sp)
    80001c8a:	64a2                	ld	s1,8(sp)
    80001c8c:	6902                	ld	s2,0(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret

0000000080001c92 <proc_pagetable>:
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	e04a                	sd	s2,0(sp)
    80001c9c:	1000                	addi	s0,sp,32
    80001c9e:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	750080e7          	jalr	1872(ra) # 800013f0 <uvmcreate>
    80001ca8:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001caa:	c121                	beqz	a0,80001cea <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cac:	4729                	li	a4,10
    80001cae:	00005697          	auipc	a3,0x5
    80001cb2:	35268693          	addi	a3,a3,850 # 80007000 <_trampoline>
    80001cb6:	6605                	lui	a2,0x1
    80001cb8:	040005b7          	lui	a1,0x4000
    80001cbc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cbe:	05b2                	slli	a1,a1,0xc
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	4a6080e7          	jalr	1190(ra) # 80001166 <mappages>
    80001cc8:	02054863          	bltz	a0,80001cf8 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ccc:	4719                	li	a4,6
    80001cce:	05893683          	ld	a3,88(s2)
    80001cd2:	6605                	lui	a2,0x1
    80001cd4:	020005b7          	lui	a1,0x2000
    80001cd8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cda:	05b6                	slli	a1,a1,0xd
    80001cdc:	8526                	mv	a0,s1
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	488080e7          	jalr	1160(ra) # 80001166 <mappages>
    80001ce6:	02054163          	bltz	a0,80001d08 <proc_pagetable+0x76>
}
    80001cea:	8526                	mv	a0,s1
    80001cec:	60e2                	ld	ra,24(sp)
    80001cee:	6442                	ld	s0,16(sp)
    80001cf0:	64a2                	ld	s1,8(sp)
    80001cf2:	6902                	ld	s2,0(sp)
    80001cf4:	6105                	addi	sp,sp,32
    80001cf6:	8082                	ret
        uvmfree(pagetable, 0);
    80001cf8:	4581                	li	a1,0
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	8fa080e7          	jalr	-1798(ra) # 800015f6 <uvmfree>
        return 0;
    80001d04:	4481                	li	s1,0
    80001d06:	b7d5                	j	80001cea <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d08:	4681                	li	a3,0
    80001d0a:	4605                	li	a2,1
    80001d0c:	040005b7          	lui	a1,0x4000
    80001d10:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d12:	05b2                	slli	a1,a1,0xc
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	616080e7          	jalr	1558(ra) # 8000132c <uvmunmap>
        uvmfree(pagetable, 0);
    80001d1e:	4581                	li	a1,0
    80001d20:	8526                	mv	a0,s1
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	8d4080e7          	jalr	-1836(ra) # 800015f6 <uvmfree>
        return 0;
    80001d2a:	4481                	li	s1,0
    80001d2c:	bf7d                	j	80001cea <proc_pagetable+0x58>

0000000080001d2e <proc_freepagetable>:
{
    80001d2e:	1101                	addi	sp,sp,-32
    80001d30:	ec06                	sd	ra,24(sp)
    80001d32:	e822                	sd	s0,16(sp)
    80001d34:	e426                	sd	s1,8(sp)
    80001d36:	e04a                	sd	s2,0(sp)
    80001d38:	1000                	addi	s0,sp,32
    80001d3a:	84aa                	mv	s1,a0
    80001d3c:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d3e:	4681                	li	a3,0
    80001d40:	4605                	li	a2,1
    80001d42:	040005b7          	lui	a1,0x4000
    80001d46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d48:	05b2                	slli	a1,a1,0xc
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	5e2080e7          	jalr	1506(ra) # 8000132c <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d52:	4681                	li	a3,0
    80001d54:	4605                	li	a2,1
    80001d56:	020005b7          	lui	a1,0x2000
    80001d5a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d5c:	05b6                	slli	a1,a1,0xd
    80001d5e:	8526                	mv	a0,s1
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	5cc080e7          	jalr	1484(ra) # 8000132c <uvmunmap>
    uvmfree(pagetable, sz);
    80001d68:	85ca                	mv	a1,s2
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	00000097          	auipc	ra,0x0
    80001d70:	88a080e7          	jalr	-1910(ra) # 800015f6 <uvmfree>
}
    80001d74:	60e2                	ld	ra,24(sp)
    80001d76:	6442                	ld	s0,16(sp)
    80001d78:	64a2                	ld	s1,8(sp)
    80001d7a:	6902                	ld	s2,0(sp)
    80001d7c:	6105                	addi	sp,sp,32
    80001d7e:	8082                	ret

0000000080001d80 <freeproc>:
{
    80001d80:	1101                	addi	sp,sp,-32
    80001d82:	ec06                	sd	ra,24(sp)
    80001d84:	e822                	sd	s0,16(sp)
    80001d86:	e426                	sd	s1,8(sp)
    80001d88:	1000                	addi	s0,sp,32
    80001d8a:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001d8c:	6d28                	ld	a0,88(a0)
    80001d8e:	c509                	beqz	a0,80001d98 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	c6a080e7          	jalr	-918(ra) # 800009fa <kfree>
    p->trapframe = 0;
    80001d98:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001d9c:	68a8                	ld	a0,80(s1)
    80001d9e:	c511                	beqz	a0,80001daa <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001da0:	64ac                	ld	a1,72(s1)
    80001da2:	00000097          	auipc	ra,0x0
    80001da6:	f8c080e7          	jalr	-116(ra) # 80001d2e <proc_freepagetable>
    p->pagetable = 0;
    80001daa:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001dae:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001db2:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001db6:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001dba:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001dbe:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001dc2:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001dc6:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001dca:	0004ac23          	sw	zero,24(s1)
}
    80001dce:	60e2                	ld	ra,24(sp)
    80001dd0:	6442                	ld	s0,16(sp)
    80001dd2:	64a2                	ld	s1,8(sp)
    80001dd4:	6105                	addi	sp,sp,32
    80001dd6:	8082                	ret

0000000080001dd8 <allocproc>:
{
    80001dd8:	1101                	addi	sp,sp,-32
    80001dda:	ec06                	sd	ra,24(sp)
    80001ddc:	e822                	sd	s0,16(sp)
    80001dde:	e426                	sd	s1,8(sp)
    80001de0:	e04a                	sd	s2,0(sp)
    80001de2:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001de4:	0000f497          	auipc	s1,0xf
    80001de8:	31c48493          	addi	s1,s1,796 # 80011100 <proc>
    80001dec:	00015917          	auipc	s2,0x15
    80001df0:	d1490913          	addi	s2,s2,-748 # 80016b00 <tickslock>
        acquire(&p->lock);
    80001df4:	8526                	mv	a0,s1
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	ea8080e7          	jalr	-344(ra) # 80000c9e <acquire>
        if (p->state == UNUSED)
    80001dfe:	4c9c                	lw	a5,24(s1)
    80001e00:	cf81                	beqz	a5,80001e18 <allocproc+0x40>
            release(&p->lock);
    80001e02:	8526                	mv	a0,s1
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	f4e080e7          	jalr	-178(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e0c:	16848493          	addi	s1,s1,360
    80001e10:	ff2492e3          	bne	s1,s2,80001df4 <allocproc+0x1c>
    return 0;
    80001e14:	4481                	li	s1,0
    80001e16:	a889                	j	80001e68 <allocproc+0x90>
    p->pid = allocpid();
    80001e18:	00000097          	auipc	ra,0x0
    80001e1c:	e34080e7          	jalr	-460(ra) # 80001c4c <allocpid>
    80001e20:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001e22:	4785                	li	a5,1
    80001e24:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	d3c080e7          	jalr	-708(ra) # 80000b62 <kalloc>
    80001e2e:	892a                	mv	s2,a0
    80001e30:	eca8                	sd	a0,88(s1)
    80001e32:	c131                	beqz	a0,80001e76 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001e34:	8526                	mv	a0,s1
    80001e36:	00000097          	auipc	ra,0x0
    80001e3a:	e5c080e7          	jalr	-420(ra) # 80001c92 <proc_pagetable>
    80001e3e:	892a                	mv	s2,a0
    80001e40:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001e42:	c531                	beqz	a0,80001e8e <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001e44:	07000613          	li	a2,112
    80001e48:	4581                	li	a1,0
    80001e4a:	06048513          	addi	a0,s1,96
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	f4c080e7          	jalr	-180(ra) # 80000d9a <memset>
    p->context.ra = (uint64)forkret;
    80001e56:	00000797          	auipc	a5,0x0
    80001e5a:	db078793          	addi	a5,a5,-592 # 80001c06 <forkret>
    80001e5e:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001e60:	60bc                	ld	a5,64(s1)
    80001e62:	6705                	lui	a4,0x1
    80001e64:	97ba                	add	a5,a5,a4
    80001e66:	f4bc                	sd	a5,104(s1)
}
    80001e68:	8526                	mv	a0,s1
    80001e6a:	60e2                	ld	ra,24(sp)
    80001e6c:	6442                	ld	s0,16(sp)
    80001e6e:	64a2                	ld	s1,8(sp)
    80001e70:	6902                	ld	s2,0(sp)
    80001e72:	6105                	addi	sp,sp,32
    80001e74:	8082                	ret
        freeproc(p);
    80001e76:	8526                	mv	a0,s1
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	f08080e7          	jalr	-248(ra) # 80001d80 <freeproc>
        release(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	ed0080e7          	jalr	-304(ra) # 80000d52 <release>
        return 0;
    80001e8a:	84ca                	mv	s1,s2
    80001e8c:	bff1                	j	80001e68 <allocproc+0x90>
        freeproc(p);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	ef0080e7          	jalr	-272(ra) # 80001d80 <freeproc>
        release(&p->lock);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	eb8080e7          	jalr	-328(ra) # 80000d52 <release>
        return 0;
    80001ea2:	84ca                	mv	s1,s2
    80001ea4:	b7d1                	j	80001e68 <allocproc+0x90>

0000000080001ea6 <userinit>:
{
    80001ea6:	1101                	addi	sp,sp,-32
    80001ea8:	ec06                	sd	ra,24(sp)
    80001eaa:	e822                	sd	s0,16(sp)
    80001eac:	e426                	sd	s1,8(sp)
    80001eae:	1000                	addi	s0,sp,32
    p = allocproc();
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	f28080e7          	jalr	-216(ra) # 80001dd8 <allocproc>
    80001eb8:	84aa                	mv	s1,a0
    initproc = p;
    80001eba:	00007797          	auipc	a5,0x7
    80001ebe:	b8a7bf23          	sd	a0,-1122(a5) # 80008a58 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ec2:	03400613          	li	a2,52
    80001ec6:	00007597          	auipc	a1,0x7
    80001eca:	ada58593          	addi	a1,a1,-1318 # 800089a0 <initcode>
    80001ece:	6928                	ld	a0,80(a0)
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	54e080e7          	jalr	1358(ra) # 8000141e <uvmfirst>
    p->sz = PGSIZE;
    80001ed8:	6785                	lui	a5,0x1
    80001eda:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001edc:	6cb8                	ld	a4,88(s1)
    80001ede:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001ee2:	6cb8                	ld	a4,88(s1)
    80001ee4:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ee6:	4641                	li	a2,16
    80001ee8:	00006597          	auipc	a1,0x6
    80001eec:	35858593          	addi	a1,a1,856 # 80008240 <digits+0x1f0>
    80001ef0:	15848513          	addi	a0,s1,344
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	ff0080e7          	jalr	-16(ra) # 80000ee4 <safestrcpy>
    p->cwd = namei("/");
    80001efc:	00006517          	auipc	a0,0x6
    80001f00:	35450513          	addi	a0,a0,852 # 80008250 <digits+0x200>
    80001f04:	00002097          	auipc	ra,0x2
    80001f08:	480080e7          	jalr	1152(ra) # 80004384 <namei>
    80001f0c:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001f10:	478d                	li	a5,3
    80001f12:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001f14:	8526                	mv	a0,s1
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	e3c080e7          	jalr	-452(ra) # 80000d52 <release>
}
    80001f1e:	60e2                	ld	ra,24(sp)
    80001f20:	6442                	ld	s0,16(sp)
    80001f22:	64a2                	ld	s1,8(sp)
    80001f24:	6105                	addi	sp,sp,32
    80001f26:	8082                	ret

0000000080001f28 <growproc>:
{
    80001f28:	1101                	addi	sp,sp,-32
    80001f2a:	ec06                	sd	ra,24(sp)
    80001f2c:	e822                	sd	s0,16(sp)
    80001f2e:	e426                	sd	s1,8(sp)
    80001f30:	e04a                	sd	s2,0(sp)
    80001f32:	1000                	addi	s0,sp,32
    80001f34:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001f36:	00000097          	auipc	ra,0x0
    80001f3a:	c98080e7          	jalr	-872(ra) # 80001bce <myproc>
    80001f3e:	84aa                	mv	s1,a0
    sz = p->sz;
    80001f40:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001f42:	01204c63          	bgtz	s2,80001f5a <growproc+0x32>
    else if (n < 0)
    80001f46:	02094663          	bltz	s2,80001f72 <growproc+0x4a>
    p->sz = sz;
    80001f4a:	e4ac                	sd	a1,72(s1)
    return 0;
    80001f4c:	4501                	li	a0,0
}
    80001f4e:	60e2                	ld	ra,24(sp)
    80001f50:	6442                	ld	s0,16(sp)
    80001f52:	64a2                	ld	s1,8(sp)
    80001f54:	6902                	ld	s2,0(sp)
    80001f56:	6105                	addi	sp,sp,32
    80001f58:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f5a:	4691                	li	a3,4
    80001f5c:	00b90633          	add	a2,s2,a1
    80001f60:	6928                	ld	a0,80(a0)
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	576080e7          	jalr	1398(ra) # 800014d8 <uvmalloc>
    80001f6a:	85aa                	mv	a1,a0
    80001f6c:	fd79                	bnez	a0,80001f4a <growproc+0x22>
            return -1;
    80001f6e:	557d                	li	a0,-1
    80001f70:	bff9                	j	80001f4e <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f72:	00b90633          	add	a2,s2,a1
    80001f76:	6928                	ld	a0,80(a0)
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	518080e7          	jalr	1304(ra) # 80001490 <uvmdealloc>
    80001f80:	85aa                	mv	a1,a0
    80001f82:	b7e1                	j	80001f4a <growproc+0x22>

0000000080001f84 <ps>:
{
    80001f84:	715d                	addi	sp,sp,-80
    80001f86:	e486                	sd	ra,72(sp)
    80001f88:	e0a2                	sd	s0,64(sp)
    80001f8a:	fc26                	sd	s1,56(sp)
    80001f8c:	f84a                	sd	s2,48(sp)
    80001f8e:	f44e                	sd	s3,40(sp)
    80001f90:	f052                	sd	s4,32(sp)
    80001f92:	ec56                	sd	s5,24(sp)
    80001f94:	e85a                	sd	s6,16(sp)
    80001f96:	e45e                	sd	s7,8(sp)
    80001f98:	e062                	sd	s8,0(sp)
    80001f9a:	0880                	addi	s0,sp,80
    80001f9c:	84aa                	mv	s1,a0
    80001f9e:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	c2e080e7          	jalr	-978(ra) # 80001bce <myproc>
        return result;
    80001fa8:	4901                	li	s2,0
    if (count == 0)
    80001faa:	0c0b8563          	beqz	s7,80002074 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    80001fae:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80001fb2:	003b951b          	slliw	a0,s7,0x3
    80001fb6:	0175053b          	addw	a0,a0,s7
    80001fba:	0025151b          	slliw	a0,a0,0x2
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	f6a080e7          	jalr	-150(ra) # 80001f28 <growproc>
    80001fc6:	12054f63          	bltz	a0,80002104 <ps+0x180>
    struct user_proc loc_result[count];
    80001fca:	003b9a13          	slli	s4,s7,0x3
    80001fce:	9a5e                	add	s4,s4,s7
    80001fd0:	0a0a                	slli	s4,s4,0x2
    80001fd2:	00fa0793          	addi	a5,s4,15
    80001fd6:	8391                	srli	a5,a5,0x4
    80001fd8:	0792                	slli	a5,a5,0x4
    80001fda:	40f10133          	sub	sp,sp,a5
    80001fde:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    80001fe0:	16800793          	li	a5,360
    80001fe4:	02f484b3          	mul	s1,s1,a5
    80001fe8:	0000f797          	auipc	a5,0xf
    80001fec:	11878793          	addi	a5,a5,280 # 80011100 <proc>
    80001ff0:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80001ff2:	00015797          	auipc	a5,0x15
    80001ff6:	b0e78793          	addi	a5,a5,-1266 # 80016b00 <tickslock>
        return result;
    80001ffa:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80001ffc:	06f4fc63          	bgeu	s1,a5,80002074 <ps+0xf0>
    acquire(&wait_lock);
    80002000:	0000f517          	auipc	a0,0xf
    80002004:	0e850513          	addi	a0,a0,232 # 800110e8 <wait_lock>
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	c96080e7          	jalr	-874(ra) # 80000c9e <acquire>
        if (localCount == count)
    80002010:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002014:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002016:	00015c17          	auipc	s8,0x15
    8000201a:	aeac0c13          	addi	s8,s8,-1302 # 80016b00 <tickslock>
    8000201e:	a851                	j	800020b2 <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    80002020:	00399793          	slli	a5,s3,0x3
    80002024:	97ce                	add	a5,a5,s3
    80002026:	078a                	slli	a5,a5,0x2
    80002028:	97d6                	add	a5,a5,s5
    8000202a:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    8000202e:	8526                	mv	a0,s1
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	d22080e7          	jalr	-734(ra) # 80000d52 <release>
    release(&wait_lock);
    80002038:	0000f517          	auipc	a0,0xf
    8000203c:	0b050513          	addi	a0,a0,176 # 800110e8 <wait_lock>
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	d12080e7          	jalr	-750(ra) # 80000d52 <release>
    if (localCount < count)
    80002048:	0179f963          	bgeu	s3,s7,8000205a <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    8000204c:	00399793          	slli	a5,s3,0x3
    80002050:	97ce                	add	a5,a5,s3
    80002052:	078a                	slli	a5,a5,0x2
    80002054:	97d6                	add	a5,a5,s5
    80002056:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    8000205a:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	b72080e7          	jalr	-1166(ra) # 80001bce <myproc>
    80002064:	86d2                	mv	a3,s4
    80002066:	8656                	mv	a2,s5
    80002068:	85da                	mv	a1,s6
    8000206a:	6928                	ld	a0,80(a0)
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	6c8080e7          	jalr	1736(ra) # 80001734 <copyout>
}
    80002074:	854a                	mv	a0,s2
    80002076:	fb040113          	addi	sp,s0,-80
    8000207a:	60a6                	ld	ra,72(sp)
    8000207c:	6406                	ld	s0,64(sp)
    8000207e:	74e2                	ld	s1,56(sp)
    80002080:	7942                	ld	s2,48(sp)
    80002082:	79a2                	ld	s3,40(sp)
    80002084:	7a02                	ld	s4,32(sp)
    80002086:	6ae2                	ld	s5,24(sp)
    80002088:	6b42                	ld	s6,16(sp)
    8000208a:	6ba2                	ld	s7,8(sp)
    8000208c:	6c02                	ld	s8,0(sp)
    8000208e:	6161                	addi	sp,sp,80
    80002090:	8082                	ret
        release(&p->lock);
    80002092:	8526                	mv	a0,s1
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	cbe080e7          	jalr	-834(ra) # 80000d52 <release>
        localCount++;
    8000209c:	2985                	addiw	s3,s3,1
    8000209e:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800020a2:	16848493          	addi	s1,s1,360
    800020a6:	f984f9e3          	bgeu	s1,s8,80002038 <ps+0xb4>
        if (localCount == count)
    800020aa:	02490913          	addi	s2,s2,36
    800020ae:	053b8d63          	beq	s7,s3,80002108 <ps+0x184>
        acquire(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	bea080e7          	jalr	-1046(ra) # 80000c9e <acquire>
        if (p->state == UNUSED)
    800020bc:	4c9c                	lw	a5,24(s1)
    800020be:	d3ad                	beqz	a5,80002020 <ps+0x9c>
        loc_result[localCount].state = p->state;
    800020c0:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800020c4:	549c                	lw	a5,40(s1)
    800020c6:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800020ca:	54dc                	lw	a5,44(s1)
    800020cc:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800020d0:	589c                	lw	a5,48(s1)
    800020d2:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800020d6:	4641                	li	a2,16
    800020d8:	85ca                	mv	a1,s2
    800020da:	15848513          	addi	a0,s1,344
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	a96080e7          	jalr	-1386(ra) # 80001b74 <copy_array>
        if (p->parent != 0) // init
    800020e6:	7c88                	ld	a0,56(s1)
    800020e8:	d54d                	beqz	a0,80002092 <ps+0x10e>
            acquire(&p->parent->lock);
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	bb4080e7          	jalr	-1100(ra) # 80000c9e <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800020f2:	7c88                	ld	a0,56(s1)
    800020f4:	591c                	lw	a5,48(a0)
    800020f6:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	c58080e7          	jalr	-936(ra) # 80000d52 <release>
    80002102:	bf41                	j	80002092 <ps+0x10e>
        return result;
    80002104:	4901                	li	s2,0
    80002106:	b7bd                	j	80002074 <ps+0xf0>
    release(&wait_lock);
    80002108:	0000f517          	auipc	a0,0xf
    8000210c:	fe050513          	addi	a0,a0,-32 # 800110e8 <wait_lock>
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	c42080e7          	jalr	-958(ra) # 80000d52 <release>
    if (localCount < count)
    80002118:	b789                	j	8000205a <ps+0xd6>

000000008000211a <fork>:
{
    8000211a:	7139                	addi	sp,sp,-64
    8000211c:	fc06                	sd	ra,56(sp)
    8000211e:	f822                	sd	s0,48(sp)
    80002120:	f426                	sd	s1,40(sp)
    80002122:	f04a                	sd	s2,32(sp)
    80002124:	ec4e                	sd	s3,24(sp)
    80002126:	e852                	sd	s4,16(sp)
    80002128:	e456                	sd	s5,8(sp)
    8000212a:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000212c:	00000097          	auipc	ra,0x0
    80002130:	aa2080e7          	jalr	-1374(ra) # 80001bce <myproc>
    80002134:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	ca2080e7          	jalr	-862(ra) # 80001dd8 <allocproc>
    8000213e:	10050c63          	beqz	a0,80002256 <fork+0x13c>
    80002142:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002144:	048ab603          	ld	a2,72(s5)
    80002148:	692c                	ld	a1,80(a0)
    8000214a:	050ab503          	ld	a0,80(s5)
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	4e2080e7          	jalr	1250(ra) # 80001630 <uvmcopy>
    80002156:	04054863          	bltz	a0,800021a6 <fork+0x8c>
    np->sz = p->sz;
    8000215a:	048ab783          	ld	a5,72(s5)
    8000215e:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002162:	058ab683          	ld	a3,88(s5)
    80002166:	87b6                	mv	a5,a3
    80002168:	058a3703          	ld	a4,88(s4)
    8000216c:	12068693          	addi	a3,a3,288
    80002170:	0007b803          	ld	a6,0(a5)
    80002174:	6788                	ld	a0,8(a5)
    80002176:	6b8c                	ld	a1,16(a5)
    80002178:	6f90                	ld	a2,24(a5)
    8000217a:	01073023          	sd	a6,0(a4)
    8000217e:	e708                	sd	a0,8(a4)
    80002180:	eb0c                	sd	a1,16(a4)
    80002182:	ef10                	sd	a2,24(a4)
    80002184:	02078793          	addi	a5,a5,32
    80002188:	02070713          	addi	a4,a4,32
    8000218c:	fed792e3          	bne	a5,a3,80002170 <fork+0x56>
    np->trapframe->a0 = 0;
    80002190:	058a3783          	ld	a5,88(s4)
    80002194:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002198:	0d0a8493          	addi	s1,s5,208
    8000219c:	0d0a0913          	addi	s2,s4,208
    800021a0:	150a8993          	addi	s3,s5,336
    800021a4:	a00d                	j	800021c6 <fork+0xac>
        freeproc(np);
    800021a6:	8552                	mv	a0,s4
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	bd8080e7          	jalr	-1064(ra) # 80001d80 <freeproc>
        release(&np->lock);
    800021b0:	8552                	mv	a0,s4
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	ba0080e7          	jalr	-1120(ra) # 80000d52 <release>
        return -1;
    800021ba:	597d                	li	s2,-1
    800021bc:	a059                	j	80002242 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    800021be:	04a1                	addi	s1,s1,8
    800021c0:	0921                	addi	s2,s2,8
    800021c2:	01348b63          	beq	s1,s3,800021d8 <fork+0xbe>
        if (p->ofile[i])
    800021c6:	6088                	ld	a0,0(s1)
    800021c8:	d97d                	beqz	a0,800021be <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    800021ca:	00003097          	auipc	ra,0x3
    800021ce:	850080e7          	jalr	-1968(ra) # 80004a1a <filedup>
    800021d2:	00a93023          	sd	a0,0(s2)
    800021d6:	b7e5                	j	800021be <fork+0xa4>
    np->cwd = idup(p->cwd);
    800021d8:	150ab503          	ld	a0,336(s5)
    800021dc:	00002097          	auipc	ra,0x2
    800021e0:	9be080e7          	jalr	-1602(ra) # 80003b9a <idup>
    800021e4:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800021e8:	4641                	li	a2,16
    800021ea:	158a8593          	addi	a1,s5,344
    800021ee:	158a0513          	addi	a0,s4,344
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	cf2080e7          	jalr	-782(ra) # 80000ee4 <safestrcpy>
    pid = np->pid;
    800021fa:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800021fe:	8552                	mv	a0,s4
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	b52080e7          	jalr	-1198(ra) # 80000d52 <release>
    acquire(&wait_lock);
    80002208:	0000f497          	auipc	s1,0xf
    8000220c:	ee048493          	addi	s1,s1,-288 # 800110e8 <wait_lock>
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	a8c080e7          	jalr	-1396(ra) # 80000c9e <acquire>
    np->parent = p;
    8000221a:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	b32080e7          	jalr	-1230(ra) # 80000d52 <release>
    acquire(&np->lock);
    80002228:	8552                	mv	a0,s4
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	a74080e7          	jalr	-1420(ra) # 80000c9e <acquire>
    np->state = RUNNABLE;
    80002232:	478d                	li	a5,3
    80002234:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002238:	8552                	mv	a0,s4
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	b18080e7          	jalr	-1256(ra) # 80000d52 <release>
}
    80002242:	854a                	mv	a0,s2
    80002244:	70e2                	ld	ra,56(sp)
    80002246:	7442                	ld	s0,48(sp)
    80002248:	74a2                	ld	s1,40(sp)
    8000224a:	7902                	ld	s2,32(sp)
    8000224c:	69e2                	ld	s3,24(sp)
    8000224e:	6a42                	ld	s4,16(sp)
    80002250:	6aa2                	ld	s5,8(sp)
    80002252:	6121                	addi	sp,sp,64
    80002254:	8082                	ret
        return -1;
    80002256:	597d                	li	s2,-1
    80002258:	b7ed                	j	80002242 <fork+0x128>

000000008000225a <scheduler>:
{
    8000225a:	1101                	addi	sp,sp,-32
    8000225c:	ec06                	sd	ra,24(sp)
    8000225e:	e822                	sd	s0,16(sp)
    80002260:	e426                	sd	s1,8(sp)
    80002262:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002264:	00006497          	auipc	s1,0x6
    80002268:	72448493          	addi	s1,s1,1828 # 80008988 <sched_pointer>
    8000226c:	609c                	ld	a5,0(s1)
    8000226e:	9782                	jalr	a5
    while (1)
    80002270:	bff5                	j	8000226c <scheduler+0x12>

0000000080002272 <sched>:
{
    80002272:	7179                	addi	sp,sp,-48
    80002274:	f406                	sd	ra,40(sp)
    80002276:	f022                	sd	s0,32(sp)
    80002278:	ec26                	sd	s1,24(sp)
    8000227a:	e84a                	sd	s2,16(sp)
    8000227c:	e44e                	sd	s3,8(sp)
    8000227e:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    80002280:	00000097          	auipc	ra,0x0
    80002284:	94e080e7          	jalr	-1714(ra) # 80001bce <myproc>
    80002288:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	99a080e7          	jalr	-1638(ra) # 80000c24 <holding>
    80002292:	c53d                	beqz	a0,80002300 <sched+0x8e>
    80002294:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002296:	2781                	sext.w	a5,a5
    80002298:	079e                	slli	a5,a5,0x7
    8000229a:	0000f717          	auipc	a4,0xf
    8000229e:	a3670713          	addi	a4,a4,-1482 # 80010cd0 <cpus>
    800022a2:	97ba                	add	a5,a5,a4
    800022a4:	5fb8                	lw	a4,120(a5)
    800022a6:	4785                	li	a5,1
    800022a8:	06f71463          	bne	a4,a5,80002310 <sched+0x9e>
    if (p->state == RUNNING)
    800022ac:	4c98                	lw	a4,24(s1)
    800022ae:	4791                	li	a5,4
    800022b0:	06f70863          	beq	a4,a5,80002320 <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800022b4:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    800022b8:	8b89                	andi	a5,a5,2
    if (intr_get())
    800022ba:	ebbd                	bnez	a5,80002330 <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800022bc:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800022be:	0000f917          	auipc	s2,0xf
    800022c2:	a1290913          	addi	s2,s2,-1518 # 80010cd0 <cpus>
    800022c6:	2781                	sext.w	a5,a5
    800022c8:	079e                	slli	a5,a5,0x7
    800022ca:	97ca                	add	a5,a5,s2
    800022cc:	07c7a983          	lw	s3,124(a5)
    800022d0:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800022d2:	2581                	sext.w	a1,a1
    800022d4:	059e                	slli	a1,a1,0x7
    800022d6:	05a1                	addi	a1,a1,8
    800022d8:	95ca                	add	a1,a1,s2
    800022da:	06048513          	addi	a0,s1,96
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	75a080e7          	jalr	1882(ra) # 80002a38 <swtch>
    800022e6:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800022e8:	2781                	sext.w	a5,a5
    800022ea:	079e                	slli	a5,a5,0x7
    800022ec:	993e                	add	s2,s2,a5
    800022ee:	07392e23          	sw	s3,124(s2)
}
    800022f2:	70a2                	ld	ra,40(sp)
    800022f4:	7402                	ld	s0,32(sp)
    800022f6:	64e2                	ld	s1,24(sp)
    800022f8:	6942                	ld	s2,16(sp)
    800022fa:	69a2                	ld	s3,8(sp)
    800022fc:	6145                	addi	sp,sp,48
    800022fe:	8082                	ret
        panic("sched p->lock");
    80002300:	00006517          	auipc	a0,0x6
    80002304:	f5850513          	addi	a0,a0,-168 # 80008258 <digits+0x208>
    80002308:	ffffe097          	auipc	ra,0xffffe
    8000230c:	238080e7          	jalr	568(ra) # 80000540 <panic>
        panic("sched locks");
    80002310:	00006517          	auipc	a0,0x6
    80002314:	f5850513          	addi	a0,a0,-168 # 80008268 <digits+0x218>
    80002318:	ffffe097          	auipc	ra,0xffffe
    8000231c:	228080e7          	jalr	552(ra) # 80000540 <panic>
        panic("sched running");
    80002320:	00006517          	auipc	a0,0x6
    80002324:	f5850513          	addi	a0,a0,-168 # 80008278 <digits+0x228>
    80002328:	ffffe097          	auipc	ra,0xffffe
    8000232c:	218080e7          	jalr	536(ra) # 80000540 <panic>
        panic("sched interruptible");
    80002330:	00006517          	auipc	a0,0x6
    80002334:	f5850513          	addi	a0,a0,-168 # 80008288 <digits+0x238>
    80002338:	ffffe097          	auipc	ra,0xffffe
    8000233c:	208080e7          	jalr	520(ra) # 80000540 <panic>

0000000080002340 <yield>:
{
    80002340:	1101                	addi	sp,sp,-32
    80002342:	ec06                	sd	ra,24(sp)
    80002344:	e822                	sd	s0,16(sp)
    80002346:	e426                	sd	s1,8(sp)
    80002348:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	884080e7          	jalr	-1916(ra) # 80001bce <myproc>
    80002352:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	94a080e7          	jalr	-1718(ra) # 80000c9e <acquire>
    p->state = RUNNABLE;
    8000235c:	478d                	li	a5,3
    8000235e:	cc9c                	sw	a5,24(s1)
    sched();
    80002360:	00000097          	auipc	ra,0x0
    80002364:	f12080e7          	jalr	-238(ra) # 80002272 <sched>
    release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	9e8080e7          	jalr	-1560(ra) # 80000d52 <release>
}
    80002372:	60e2                	ld	ra,24(sp)
    80002374:	6442                	ld	s0,16(sp)
    80002376:	64a2                	ld	s1,8(sp)
    80002378:	6105                	addi	sp,sp,32
    8000237a:	8082                	ret

000000008000237c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000237c:	7179                	addi	sp,sp,-48
    8000237e:	f406                	sd	ra,40(sp)
    80002380:	f022                	sd	s0,32(sp)
    80002382:	ec26                	sd	s1,24(sp)
    80002384:	e84a                	sd	s2,16(sp)
    80002386:	e44e                	sd	s3,8(sp)
    80002388:	1800                	addi	s0,sp,48
    8000238a:	89aa                	mv	s3,a0
    8000238c:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000238e:	00000097          	auipc	ra,0x0
    80002392:	840080e7          	jalr	-1984(ra) # 80001bce <myproc>
    80002396:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	906080e7          	jalr	-1786(ra) # 80000c9e <acquire>
    release(lk);
    800023a0:	854a                	mv	a0,s2
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	9b0080e7          	jalr	-1616(ra) # 80000d52 <release>

    // Go to sleep.
    p->chan = chan;
    800023aa:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800023ae:	4789                	li	a5,2
    800023b0:	cc9c                	sw	a5,24(s1)

    sched();
    800023b2:	00000097          	auipc	ra,0x0
    800023b6:	ec0080e7          	jalr	-320(ra) # 80002272 <sched>

    // Tidy up.
    p->chan = 0;
    800023ba:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	992080e7          	jalr	-1646(ra) # 80000d52 <release>
    acquire(lk);
    800023c8:	854a                	mv	a0,s2
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8d4080e7          	jalr	-1836(ra) # 80000c9e <acquire>
}
    800023d2:	70a2                	ld	ra,40(sp)
    800023d4:	7402                	ld	s0,32(sp)
    800023d6:	64e2                	ld	s1,24(sp)
    800023d8:	6942                	ld	s2,16(sp)
    800023da:	69a2                	ld	s3,8(sp)
    800023dc:	6145                	addi	sp,sp,48
    800023de:	8082                	ret

00000000800023e0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800023e0:	7139                	addi	sp,sp,-64
    800023e2:	fc06                	sd	ra,56(sp)
    800023e4:	f822                	sd	s0,48(sp)
    800023e6:	f426                	sd	s1,40(sp)
    800023e8:	f04a                	sd	s2,32(sp)
    800023ea:	ec4e                	sd	s3,24(sp)
    800023ec:	e852                	sd	s4,16(sp)
    800023ee:	e456                	sd	s5,8(sp)
    800023f0:	0080                	addi	s0,sp,64
    800023f2:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800023f4:	0000f497          	auipc	s1,0xf
    800023f8:	d0c48493          	addi	s1,s1,-756 # 80011100 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800023fc:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800023fe:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002400:	00014917          	auipc	s2,0x14
    80002404:	70090913          	addi	s2,s2,1792 # 80016b00 <tickslock>
    80002408:	a811                	j	8000241c <wakeup+0x3c>
            }
            release(&p->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	946080e7          	jalr	-1722(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002414:	16848493          	addi	s1,s1,360
    80002418:	03248663          	beq	s1,s2,80002444 <wakeup+0x64>
        if (p != myproc())
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	7b2080e7          	jalr	1970(ra) # 80001bce <myproc>
    80002424:	fea488e3          	beq	s1,a0,80002414 <wakeup+0x34>
            acquire(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	874080e7          	jalr	-1932(ra) # 80000c9e <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002432:	4c9c                	lw	a5,24(s1)
    80002434:	fd379be3          	bne	a5,s3,8000240a <wakeup+0x2a>
    80002438:	709c                	ld	a5,32(s1)
    8000243a:	fd4798e3          	bne	a5,s4,8000240a <wakeup+0x2a>
                p->state = RUNNABLE;
    8000243e:	0154ac23          	sw	s5,24(s1)
    80002442:	b7e1                	j	8000240a <wakeup+0x2a>
        }
    }
}
    80002444:	70e2                	ld	ra,56(sp)
    80002446:	7442                	ld	s0,48(sp)
    80002448:	74a2                	ld	s1,40(sp)
    8000244a:	7902                	ld	s2,32(sp)
    8000244c:	69e2                	ld	s3,24(sp)
    8000244e:	6a42                	ld	s4,16(sp)
    80002450:	6aa2                	ld	s5,8(sp)
    80002452:	6121                	addi	sp,sp,64
    80002454:	8082                	ret

0000000080002456 <reparent>:
{
    80002456:	7179                	addi	sp,sp,-48
    80002458:	f406                	sd	ra,40(sp)
    8000245a:	f022                	sd	s0,32(sp)
    8000245c:	ec26                	sd	s1,24(sp)
    8000245e:	e84a                	sd	s2,16(sp)
    80002460:	e44e                	sd	s3,8(sp)
    80002462:	e052                	sd	s4,0(sp)
    80002464:	1800                	addi	s0,sp,48
    80002466:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002468:	0000f497          	auipc	s1,0xf
    8000246c:	c9848493          	addi	s1,s1,-872 # 80011100 <proc>
            pp->parent = initproc;
    80002470:	00006a17          	auipc	s4,0x6
    80002474:	5e8a0a13          	addi	s4,s4,1512 # 80008a58 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002478:	00014997          	auipc	s3,0x14
    8000247c:	68898993          	addi	s3,s3,1672 # 80016b00 <tickslock>
    80002480:	a029                	j	8000248a <reparent+0x34>
    80002482:	16848493          	addi	s1,s1,360
    80002486:	01348d63          	beq	s1,s3,800024a0 <reparent+0x4a>
        if (pp->parent == p)
    8000248a:	7c9c                	ld	a5,56(s1)
    8000248c:	ff279be3          	bne	a5,s2,80002482 <reparent+0x2c>
            pp->parent = initproc;
    80002490:	000a3503          	ld	a0,0(s4)
    80002494:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002496:	00000097          	auipc	ra,0x0
    8000249a:	f4a080e7          	jalr	-182(ra) # 800023e0 <wakeup>
    8000249e:	b7d5                	j	80002482 <reparent+0x2c>
}
    800024a0:	70a2                	ld	ra,40(sp)
    800024a2:	7402                	ld	s0,32(sp)
    800024a4:	64e2                	ld	s1,24(sp)
    800024a6:	6942                	ld	s2,16(sp)
    800024a8:	69a2                	ld	s3,8(sp)
    800024aa:	6a02                	ld	s4,0(sp)
    800024ac:	6145                	addi	sp,sp,48
    800024ae:	8082                	ret

00000000800024b0 <exit>:
{
    800024b0:	7179                	addi	sp,sp,-48
    800024b2:	f406                	sd	ra,40(sp)
    800024b4:	f022                	sd	s0,32(sp)
    800024b6:	ec26                	sd	s1,24(sp)
    800024b8:	e84a                	sd	s2,16(sp)
    800024ba:	e44e                	sd	s3,8(sp)
    800024bc:	e052                	sd	s4,0(sp)
    800024be:	1800                	addi	s0,sp,48
    800024c0:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	70c080e7          	jalr	1804(ra) # 80001bce <myproc>
    800024ca:	89aa                	mv	s3,a0
    if (p == initproc)
    800024cc:	00006797          	auipc	a5,0x6
    800024d0:	58c7b783          	ld	a5,1420(a5) # 80008a58 <initproc>
    800024d4:	0d050493          	addi	s1,a0,208
    800024d8:	15050913          	addi	s2,a0,336
    800024dc:	02a79363          	bne	a5,a0,80002502 <exit+0x52>
        panic("init exiting");
    800024e0:	00006517          	auipc	a0,0x6
    800024e4:	dc050513          	addi	a0,a0,-576 # 800082a0 <digits+0x250>
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	058080e7          	jalr	88(ra) # 80000540 <panic>
            fileclose(f);
    800024f0:	00002097          	auipc	ra,0x2
    800024f4:	57c080e7          	jalr	1404(ra) # 80004a6c <fileclose>
            p->ofile[fd] = 0;
    800024f8:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800024fc:	04a1                	addi	s1,s1,8
    800024fe:	01248563          	beq	s1,s2,80002508 <exit+0x58>
        if (p->ofile[fd])
    80002502:	6088                	ld	a0,0(s1)
    80002504:	f575                	bnez	a0,800024f0 <exit+0x40>
    80002506:	bfdd                	j	800024fc <exit+0x4c>
    begin_op();
    80002508:	00002097          	auipc	ra,0x2
    8000250c:	09c080e7          	jalr	156(ra) # 800045a4 <begin_op>
    iput(p->cwd);
    80002510:	1509b503          	ld	a0,336(s3)
    80002514:	00002097          	auipc	ra,0x2
    80002518:	87e080e7          	jalr	-1922(ra) # 80003d92 <iput>
    end_op();
    8000251c:	00002097          	auipc	ra,0x2
    80002520:	106080e7          	jalr	262(ra) # 80004622 <end_op>
    p->cwd = 0;
    80002524:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002528:	0000f497          	auipc	s1,0xf
    8000252c:	bc048493          	addi	s1,s1,-1088 # 800110e8 <wait_lock>
    80002530:	8526                	mv	a0,s1
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	76c080e7          	jalr	1900(ra) # 80000c9e <acquire>
    reparent(p);
    8000253a:	854e                	mv	a0,s3
    8000253c:	00000097          	auipc	ra,0x0
    80002540:	f1a080e7          	jalr	-230(ra) # 80002456 <reparent>
    wakeup(p->parent);
    80002544:	0389b503          	ld	a0,56(s3)
    80002548:	00000097          	auipc	ra,0x0
    8000254c:	e98080e7          	jalr	-360(ra) # 800023e0 <wakeup>
    acquire(&p->lock);
    80002550:	854e                	mv	a0,s3
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	74c080e7          	jalr	1868(ra) # 80000c9e <acquire>
    p->xstate = status;
    8000255a:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    8000255e:	4795                	li	a5,5
    80002560:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002564:	8526                	mv	a0,s1
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	7ec080e7          	jalr	2028(ra) # 80000d52 <release>
    sched();
    8000256e:	00000097          	auipc	ra,0x0
    80002572:	d04080e7          	jalr	-764(ra) # 80002272 <sched>
    panic("zombie exit");
    80002576:	00006517          	auipc	a0,0x6
    8000257a:	d3a50513          	addi	a0,a0,-710 # 800082b0 <digits+0x260>
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	fc2080e7          	jalr	-62(ra) # 80000540 <panic>

0000000080002586 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002586:	7179                	addi	sp,sp,-48
    80002588:	f406                	sd	ra,40(sp)
    8000258a:	f022                	sd	s0,32(sp)
    8000258c:	ec26                	sd	s1,24(sp)
    8000258e:	e84a                	sd	s2,16(sp)
    80002590:	e44e                	sd	s3,8(sp)
    80002592:	1800                	addi	s0,sp,48
    80002594:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002596:	0000f497          	auipc	s1,0xf
    8000259a:	b6a48493          	addi	s1,s1,-1174 # 80011100 <proc>
    8000259e:	00014997          	auipc	s3,0x14
    800025a2:	56298993          	addi	s3,s3,1378 # 80016b00 <tickslock>
    {
        acquire(&p->lock);
    800025a6:	8526                	mv	a0,s1
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	6f6080e7          	jalr	1782(ra) # 80000c9e <acquire>
        if (p->pid == pid)
    800025b0:	589c                	lw	a5,48(s1)
    800025b2:	01278d63          	beq	a5,s2,800025cc <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800025b6:	8526                	mv	a0,s1
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	79a080e7          	jalr	1946(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800025c0:	16848493          	addi	s1,s1,360
    800025c4:	ff3491e3          	bne	s1,s3,800025a6 <kill+0x20>
    }
    return -1;
    800025c8:	557d                	li	a0,-1
    800025ca:	a829                	j	800025e4 <kill+0x5e>
            p->killed = 1;
    800025cc:	4785                	li	a5,1
    800025ce:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800025d0:	4c98                	lw	a4,24(s1)
    800025d2:	4789                	li	a5,2
    800025d4:	00f70f63          	beq	a4,a5,800025f2 <kill+0x6c>
            release(&p->lock);
    800025d8:	8526                	mv	a0,s1
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	778080e7          	jalr	1912(ra) # 80000d52 <release>
            return 0;
    800025e2:	4501                	li	a0,0
}
    800025e4:	70a2                	ld	ra,40(sp)
    800025e6:	7402                	ld	s0,32(sp)
    800025e8:	64e2                	ld	s1,24(sp)
    800025ea:	6942                	ld	s2,16(sp)
    800025ec:	69a2                	ld	s3,8(sp)
    800025ee:	6145                	addi	sp,sp,48
    800025f0:	8082                	ret
                p->state = RUNNABLE;
    800025f2:	478d                	li	a5,3
    800025f4:	cc9c                	sw	a5,24(s1)
    800025f6:	b7cd                	j	800025d8 <kill+0x52>

00000000800025f8 <setkilled>:

void setkilled(struct proc *p)
{
    800025f8:	1101                	addi	sp,sp,-32
    800025fa:	ec06                	sd	ra,24(sp)
    800025fc:	e822                	sd	s0,16(sp)
    800025fe:	e426                	sd	s1,8(sp)
    80002600:	1000                	addi	s0,sp,32
    80002602:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002604:	ffffe097          	auipc	ra,0xffffe
    80002608:	69a080e7          	jalr	1690(ra) # 80000c9e <acquire>
    p->killed = 1;
    8000260c:	4785                	li	a5,1
    8000260e:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002610:	8526                	mv	a0,s1
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	740080e7          	jalr	1856(ra) # 80000d52 <release>
}
    8000261a:	60e2                	ld	ra,24(sp)
    8000261c:	6442                	ld	s0,16(sp)
    8000261e:	64a2                	ld	s1,8(sp)
    80002620:	6105                	addi	sp,sp,32
    80002622:	8082                	ret

0000000080002624 <killed>:

int killed(struct proc *p)
{
    80002624:	1101                	addi	sp,sp,-32
    80002626:	ec06                	sd	ra,24(sp)
    80002628:	e822                	sd	s0,16(sp)
    8000262a:	e426                	sd	s1,8(sp)
    8000262c:	e04a                	sd	s2,0(sp)
    8000262e:	1000                	addi	s0,sp,32
    80002630:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	66c080e7          	jalr	1644(ra) # 80000c9e <acquire>
    k = p->killed;
    8000263a:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	712080e7          	jalr	1810(ra) # 80000d52 <release>
    return k;
}
    80002648:	854a                	mv	a0,s2
    8000264a:	60e2                	ld	ra,24(sp)
    8000264c:	6442                	ld	s0,16(sp)
    8000264e:	64a2                	ld	s1,8(sp)
    80002650:	6902                	ld	s2,0(sp)
    80002652:	6105                	addi	sp,sp,32
    80002654:	8082                	ret

0000000080002656 <wait>:
{
    80002656:	715d                	addi	sp,sp,-80
    80002658:	e486                	sd	ra,72(sp)
    8000265a:	e0a2                	sd	s0,64(sp)
    8000265c:	fc26                	sd	s1,56(sp)
    8000265e:	f84a                	sd	s2,48(sp)
    80002660:	f44e                	sd	s3,40(sp)
    80002662:	f052                	sd	s4,32(sp)
    80002664:	ec56                	sd	s5,24(sp)
    80002666:	e85a                	sd	s6,16(sp)
    80002668:	e45e                	sd	s7,8(sp)
    8000266a:	e062                	sd	s8,0(sp)
    8000266c:	0880                	addi	s0,sp,80
    8000266e:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	55e080e7          	jalr	1374(ra) # 80001bce <myproc>
    80002678:	892a                	mv	s2,a0
    acquire(&wait_lock);
    8000267a:	0000f517          	auipc	a0,0xf
    8000267e:	a6e50513          	addi	a0,a0,-1426 # 800110e8 <wait_lock>
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	61c080e7          	jalr	1564(ra) # 80000c9e <acquire>
        havekids = 0;
    8000268a:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    8000268c:	4a15                	li	s4,5
                havekids = 1;
    8000268e:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002690:	00014997          	auipc	s3,0x14
    80002694:	47098993          	addi	s3,s3,1136 # 80016b00 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002698:	0000fc17          	auipc	s8,0xf
    8000269c:	a50c0c13          	addi	s8,s8,-1456 # 800110e8 <wait_lock>
        havekids = 0;
    800026a0:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800026a2:	0000f497          	auipc	s1,0xf
    800026a6:	a5e48493          	addi	s1,s1,-1442 # 80011100 <proc>
    800026aa:	a0bd                	j	80002718 <wait+0xc2>
                    pid = pp->pid;
    800026ac:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026b0:	000b0e63          	beqz	s6,800026cc <wait+0x76>
    800026b4:	4691                	li	a3,4
    800026b6:	02c48613          	addi	a2,s1,44
    800026ba:	85da                	mv	a1,s6
    800026bc:	05093503          	ld	a0,80(s2)
    800026c0:	fffff097          	auipc	ra,0xfffff
    800026c4:	074080e7          	jalr	116(ra) # 80001734 <copyout>
    800026c8:	02054563          	bltz	a0,800026f2 <wait+0x9c>
                    freeproc(pp);
    800026cc:	8526                	mv	a0,s1
    800026ce:	fffff097          	auipc	ra,0xfffff
    800026d2:	6b2080e7          	jalr	1714(ra) # 80001d80 <freeproc>
                    release(&pp->lock);
    800026d6:	8526                	mv	a0,s1
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	67a080e7          	jalr	1658(ra) # 80000d52 <release>
                    release(&wait_lock);
    800026e0:	0000f517          	auipc	a0,0xf
    800026e4:	a0850513          	addi	a0,a0,-1528 # 800110e8 <wait_lock>
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	66a080e7          	jalr	1642(ra) # 80000d52 <release>
                    return pid;
    800026f0:	a0b5                	j	8000275c <wait+0x106>
                        release(&pp->lock);
    800026f2:	8526                	mv	a0,s1
    800026f4:	ffffe097          	auipc	ra,0xffffe
    800026f8:	65e080e7          	jalr	1630(ra) # 80000d52 <release>
                        release(&wait_lock);
    800026fc:	0000f517          	auipc	a0,0xf
    80002700:	9ec50513          	addi	a0,a0,-1556 # 800110e8 <wait_lock>
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	64e080e7          	jalr	1614(ra) # 80000d52 <release>
                        return -1;
    8000270c:	59fd                	li	s3,-1
    8000270e:	a0b9                	j	8000275c <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002710:	16848493          	addi	s1,s1,360
    80002714:	03348463          	beq	s1,s3,8000273c <wait+0xe6>
            if (pp->parent == p)
    80002718:	7c9c                	ld	a5,56(s1)
    8000271a:	ff279be3          	bne	a5,s2,80002710 <wait+0xba>
                acquire(&pp->lock);
    8000271e:	8526                	mv	a0,s1
    80002720:	ffffe097          	auipc	ra,0xffffe
    80002724:	57e080e7          	jalr	1406(ra) # 80000c9e <acquire>
                if (pp->state == ZOMBIE)
    80002728:	4c9c                	lw	a5,24(s1)
    8000272a:	f94781e3          	beq	a5,s4,800026ac <wait+0x56>
                release(&pp->lock);
    8000272e:	8526                	mv	a0,s1
    80002730:	ffffe097          	auipc	ra,0xffffe
    80002734:	622080e7          	jalr	1570(ra) # 80000d52 <release>
                havekids = 1;
    80002738:	8756                	mv	a4,s5
    8000273a:	bfd9                	j	80002710 <wait+0xba>
        if (!havekids || killed(p))
    8000273c:	c719                	beqz	a4,8000274a <wait+0xf4>
    8000273e:	854a                	mv	a0,s2
    80002740:	00000097          	auipc	ra,0x0
    80002744:	ee4080e7          	jalr	-284(ra) # 80002624 <killed>
    80002748:	c51d                	beqz	a0,80002776 <wait+0x120>
            release(&wait_lock);
    8000274a:	0000f517          	auipc	a0,0xf
    8000274e:	99e50513          	addi	a0,a0,-1634 # 800110e8 <wait_lock>
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	600080e7          	jalr	1536(ra) # 80000d52 <release>
            return -1;
    8000275a:	59fd                	li	s3,-1
}
    8000275c:	854e                	mv	a0,s3
    8000275e:	60a6                	ld	ra,72(sp)
    80002760:	6406                	ld	s0,64(sp)
    80002762:	74e2                	ld	s1,56(sp)
    80002764:	7942                	ld	s2,48(sp)
    80002766:	79a2                	ld	s3,40(sp)
    80002768:	7a02                	ld	s4,32(sp)
    8000276a:	6ae2                	ld	s5,24(sp)
    8000276c:	6b42                	ld	s6,16(sp)
    8000276e:	6ba2                	ld	s7,8(sp)
    80002770:	6c02                	ld	s8,0(sp)
    80002772:	6161                	addi	sp,sp,80
    80002774:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002776:	85e2                	mv	a1,s8
    80002778:	854a                	mv	a0,s2
    8000277a:	00000097          	auipc	ra,0x0
    8000277e:	c02080e7          	jalr	-1022(ra) # 8000237c <sleep>
        havekids = 0;
    80002782:	bf39                	j	800026a0 <wait+0x4a>

0000000080002784 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002784:	7179                	addi	sp,sp,-48
    80002786:	f406                	sd	ra,40(sp)
    80002788:	f022                	sd	s0,32(sp)
    8000278a:	ec26                	sd	s1,24(sp)
    8000278c:	e84a                	sd	s2,16(sp)
    8000278e:	e44e                	sd	s3,8(sp)
    80002790:	e052                	sd	s4,0(sp)
    80002792:	1800                	addi	s0,sp,48
    80002794:	84aa                	mv	s1,a0
    80002796:	892e                	mv	s2,a1
    80002798:	89b2                	mv	s3,a2
    8000279a:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000279c:	fffff097          	auipc	ra,0xfffff
    800027a0:	432080e7          	jalr	1074(ra) # 80001bce <myproc>
    if (user_dst)
    800027a4:	c08d                	beqz	s1,800027c6 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800027a6:	86d2                	mv	a3,s4
    800027a8:	864e                	mv	a2,s3
    800027aa:	85ca                	mv	a1,s2
    800027ac:	6928                	ld	a0,80(a0)
    800027ae:	fffff097          	auipc	ra,0xfffff
    800027b2:	f86080e7          	jalr	-122(ra) # 80001734 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    800027b6:	70a2                	ld	ra,40(sp)
    800027b8:	7402                	ld	s0,32(sp)
    800027ba:	64e2                	ld	s1,24(sp)
    800027bc:	6942                	ld	s2,16(sp)
    800027be:	69a2                	ld	s3,8(sp)
    800027c0:	6a02                	ld	s4,0(sp)
    800027c2:	6145                	addi	sp,sp,48
    800027c4:	8082                	ret
        memmove((char *)dst, src, len);
    800027c6:	000a061b          	sext.w	a2,s4
    800027ca:	85ce                	mv	a1,s3
    800027cc:	854a                	mv	a0,s2
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	628080e7          	jalr	1576(ra) # 80000df6 <memmove>
        return 0;
    800027d6:	8526                	mv	a0,s1
    800027d8:	bff9                	j	800027b6 <either_copyout+0x32>

00000000800027da <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027da:	7179                	addi	sp,sp,-48
    800027dc:	f406                	sd	ra,40(sp)
    800027de:	f022                	sd	s0,32(sp)
    800027e0:	ec26                	sd	s1,24(sp)
    800027e2:	e84a                	sd	s2,16(sp)
    800027e4:	e44e                	sd	s3,8(sp)
    800027e6:	e052                	sd	s4,0(sp)
    800027e8:	1800                	addi	s0,sp,48
    800027ea:	892a                	mv	s2,a0
    800027ec:	84ae                	mv	s1,a1
    800027ee:	89b2                	mv	s3,a2
    800027f0:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800027f2:	fffff097          	auipc	ra,0xfffff
    800027f6:	3dc080e7          	jalr	988(ra) # 80001bce <myproc>
    if (user_src)
    800027fa:	c08d                	beqz	s1,8000281c <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    800027fc:	86d2                	mv	a3,s4
    800027fe:	864e                	mv	a2,s3
    80002800:	85ca                	mv	a1,s2
    80002802:	6928                	ld	a0,80(a0)
    80002804:	fffff097          	auipc	ra,0xfffff
    80002808:	fbc080e7          	jalr	-68(ra) # 800017c0 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    8000280c:	70a2                	ld	ra,40(sp)
    8000280e:	7402                	ld	s0,32(sp)
    80002810:	64e2                	ld	s1,24(sp)
    80002812:	6942                	ld	s2,16(sp)
    80002814:	69a2                	ld	s3,8(sp)
    80002816:	6a02                	ld	s4,0(sp)
    80002818:	6145                	addi	sp,sp,48
    8000281a:	8082                	ret
        memmove(dst, (char *)src, len);
    8000281c:	000a061b          	sext.w	a2,s4
    80002820:	85ce                	mv	a1,s3
    80002822:	854a                	mv	a0,s2
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	5d2080e7          	jalr	1490(ra) # 80000df6 <memmove>
        return 0;
    8000282c:	8526                	mv	a0,s1
    8000282e:	bff9                	j	8000280c <either_copyin+0x32>

0000000080002830 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002830:	715d                	addi	sp,sp,-80
    80002832:	e486                	sd	ra,72(sp)
    80002834:	e0a2                	sd	s0,64(sp)
    80002836:	fc26                	sd	s1,56(sp)
    80002838:	f84a                	sd	s2,48(sp)
    8000283a:	f44e                	sd	s3,40(sp)
    8000283c:	f052                	sd	s4,32(sp)
    8000283e:	ec56                	sd	s5,24(sp)
    80002840:	e85a                	sd	s6,16(sp)
    80002842:	e45e                	sd	s7,8(sp)
    80002844:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	84250513          	addi	a0,a0,-1982 # 80008088 <digits+0x38>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	d4e080e7          	jalr	-690(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002856:	0000f497          	auipc	s1,0xf
    8000285a:	a0248493          	addi	s1,s1,-1534 # 80011258 <proc+0x158>
    8000285e:	00014917          	auipc	s2,0x14
    80002862:	3fa90913          	addi	s2,s2,1018 # 80016c58 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002866:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002868:	00006997          	auipc	s3,0x6
    8000286c:	a5898993          	addi	s3,s3,-1448 # 800082c0 <digits+0x270>
        printf("%d <%s %s", p->pid, state, p->name);
    80002870:	00006a97          	auipc	s5,0x6
    80002874:	a58a8a93          	addi	s5,s5,-1448 # 800082c8 <digits+0x278>
        printf("\n");
    80002878:	00006a17          	auipc	s4,0x6
    8000287c:	810a0a13          	addi	s4,s4,-2032 # 80008088 <digits+0x38>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002880:	00006b97          	auipc	s7,0x6
    80002884:	b58b8b93          	addi	s7,s7,-1192 # 800083d8 <states.0>
    80002888:	a00d                	j	800028aa <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    8000288a:	ed86a583          	lw	a1,-296(a3)
    8000288e:	8556                	mv	a0,s5
    80002890:	ffffe097          	auipc	ra,0xffffe
    80002894:	d0c080e7          	jalr	-756(ra) # 8000059c <printf>
        printf("\n");
    80002898:	8552                	mv	a0,s4
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	d02080e7          	jalr	-766(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800028a2:	16848493          	addi	s1,s1,360
    800028a6:	03248263          	beq	s1,s2,800028ca <procdump+0x9a>
        if (p->state == UNUSED)
    800028aa:	86a6                	mv	a3,s1
    800028ac:	ec04a783          	lw	a5,-320(s1)
    800028b0:	dbed                	beqz	a5,800028a2 <procdump+0x72>
            state = "???";
    800028b2:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028b4:	fcfb6be3          	bltu	s6,a5,8000288a <procdump+0x5a>
    800028b8:	02079713          	slli	a4,a5,0x20
    800028bc:	01d75793          	srli	a5,a4,0x1d
    800028c0:	97de                	add	a5,a5,s7
    800028c2:	6390                	ld	a2,0(a5)
    800028c4:	f279                	bnez	a2,8000288a <procdump+0x5a>
            state = "???";
    800028c6:	864e                	mv	a2,s3
    800028c8:	b7c9                	j	8000288a <procdump+0x5a>
    }
}
    800028ca:	60a6                	ld	ra,72(sp)
    800028cc:	6406                	ld	s0,64(sp)
    800028ce:	74e2                	ld	s1,56(sp)
    800028d0:	7942                	ld	s2,48(sp)
    800028d2:	79a2                	ld	s3,40(sp)
    800028d4:	7a02                	ld	s4,32(sp)
    800028d6:	6ae2                	ld	s5,24(sp)
    800028d8:	6b42                	ld	s6,16(sp)
    800028da:	6ba2                	ld	s7,8(sp)
    800028dc:	6161                	addi	sp,sp,80
    800028de:	8082                	ret

00000000800028e0 <schedls>:

void schedls()
{
    800028e0:	1141                	addi	sp,sp,-16
    800028e2:	e406                	sd	ra,8(sp)
    800028e4:	e022                	sd	s0,0(sp)
    800028e6:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	9f050513          	addi	a0,a0,-1552 # 800082d8 <digits+0x288>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	cac080e7          	jalr	-852(ra) # 8000059c <printf>
    printf("====================================\n");
    800028f8:	00006517          	auipc	a0,0x6
    800028fc:	a0850513          	addi	a0,a0,-1528 # 80008300 <digits+0x2b0>
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	c9c080e7          	jalr	-868(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002908:	00006717          	auipc	a4,0x6
    8000290c:	0e073703          	ld	a4,224(a4) # 800089e8 <available_schedulers+0x10>
    80002910:	00006797          	auipc	a5,0x6
    80002914:	0787b783          	ld	a5,120(a5) # 80008988 <sched_pointer>
    80002918:	04f70663          	beq	a4,a5,80002964 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    8000291c:	00006517          	auipc	a0,0x6
    80002920:	a1450513          	addi	a0,a0,-1516 # 80008330 <digits+0x2e0>
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	c78080e7          	jalr	-904(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    8000292c:	00006617          	auipc	a2,0x6
    80002930:	0c462603          	lw	a2,196(a2) # 800089f0 <available_schedulers+0x18>
    80002934:	00006597          	auipc	a1,0x6
    80002938:	0a458593          	addi	a1,a1,164 # 800089d8 <available_schedulers>
    8000293c:	00006517          	auipc	a0,0x6
    80002940:	9fc50513          	addi	a0,a0,-1540 # 80008338 <digits+0x2e8>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	c58080e7          	jalr	-936(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    8000294c:	00006517          	auipc	a0,0x6
    80002950:	9f450513          	addi	a0,a0,-1548 # 80008340 <digits+0x2f0>
    80002954:	ffffe097          	auipc	ra,0xffffe
    80002958:	c48080e7          	jalr	-952(ra) # 8000059c <printf>
}
    8000295c:	60a2                	ld	ra,8(sp)
    8000295e:	6402                	ld	s0,0(sp)
    80002960:	0141                	addi	sp,sp,16
    80002962:	8082                	ret
            printf("[*]\t");
    80002964:	00006517          	auipc	a0,0x6
    80002968:	9c450513          	addi	a0,a0,-1596 # 80008328 <digits+0x2d8>
    8000296c:	ffffe097          	auipc	ra,0xffffe
    80002970:	c30080e7          	jalr	-976(ra) # 8000059c <printf>
    80002974:	bf65                	j	8000292c <schedls+0x4c>

0000000080002976 <schedset>:

void schedset(int id)
{
    80002976:	1141                	addi	sp,sp,-16
    80002978:	e406                	sd	ra,8(sp)
    8000297a:	e022                	sd	s0,0(sp)
    8000297c:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    8000297e:	e90d                	bnez	a0,800029b0 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002980:	00006797          	auipc	a5,0x6
    80002984:	0687b783          	ld	a5,104(a5) # 800089e8 <available_schedulers+0x10>
    80002988:	00006717          	auipc	a4,0x6
    8000298c:	00f73023          	sd	a5,0(a4) # 80008988 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002990:	00006597          	auipc	a1,0x6
    80002994:	04858593          	addi	a1,a1,72 # 800089d8 <available_schedulers>
    80002998:	00006517          	auipc	a0,0x6
    8000299c:	9e850513          	addi	a0,a0,-1560 # 80008380 <digits+0x330>
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	bfc080e7          	jalr	-1028(ra) # 8000059c <printf>
}
    800029a8:	60a2                	ld	ra,8(sp)
    800029aa:	6402                	ld	s0,0(sp)
    800029ac:	0141                	addi	sp,sp,16
    800029ae:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    800029b0:	00006517          	auipc	a0,0x6
    800029b4:	9a850513          	addi	a0,a0,-1624 # 80008358 <digits+0x308>
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	be4080e7          	jalr	-1052(ra) # 8000059c <printf>
        return;
    800029c0:	b7e5                	j	800029a8 <schedset+0x32>

00000000800029c2 <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    800029c2:	7179                	addi	sp,sp,-48
    800029c4:	f406                	sd	ra,40(sp)
    800029c6:	f022                	sd	s0,32(sp)
    800029c8:	ec26                	sd	s1,24(sp)
    800029ca:	e84a                	sd	s2,16(sp)
    800029cc:	e44e                	sd	s3,8(sp)
    800029ce:	e052                	sd	s4,0(sp)
    800029d0:	1800                	addi	s0,sp,48
    800029d2:	8a2a                	mv	s4,a0
    800029d4:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    800029d6:	0000e497          	auipc	s1,0xe
    800029da:	72a48493          	addi	s1,s1,1834 # 80011100 <proc>
    800029de:	00014997          	auipc	s3,0x14
    800029e2:	12298993          	addi	s3,s3,290 # 80016b00 <tickslock>
    800029e6:	a811                	j	800029fa <transvirtproc+0x38>
    {
	acquire(&p->lock);
	found = p->pid == pid && p->state != UNUSED; 
	release(&p->lock);
    800029e8:	8526                	mv	a0,s1
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	368080e7          	jalr	872(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800029f2:	16848493          	addi	s1,s1,360
    800029f6:	03348f63          	beq	s1,s3,80002a34 <transvirtproc+0x72>
	acquire(&p->lock);
    800029fa:	8526                	mv	a0,s1
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	2a2080e7          	jalr	674(ra) # 80000c9e <acquire>
	found = p->pid == pid && p->state != UNUSED; 
    80002a04:	589c                	lw	a5,48(s1)
    80002a06:	ff2791e3          	bne	a5,s2,800029e8 <transvirtproc+0x26>
    80002a0a:	4c9c                	lw	a5,24(s1)
    80002a0c:	dff1                	beqz	a5,800029e8 <transvirtproc+0x26>
	release(&p->lock);
    80002a0e:	8526                	mv	a0,s1
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	342080e7          	jalr	834(ra) # 80000d52 <release>
    if (!found) {
	return 0;
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002a18:	68ac                	ld	a1,80(s1)
    80002a1a:	8552                	mv	a0,s4
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	ee2080e7          	jalr	-286(ra) # 800018fe <transvirt>
}
    80002a24:	70a2                	ld	ra,40(sp)
    80002a26:	7402                	ld	s0,32(sp)
    80002a28:	64e2                	ld	s1,24(sp)
    80002a2a:	6942                	ld	s2,16(sp)
    80002a2c:	69a2                	ld	s3,8(sp)
    80002a2e:	6a02                	ld	s4,0(sp)
    80002a30:	6145                	addi	sp,sp,48
    80002a32:	8082                	ret
	return 0;
    80002a34:	4501                	li	a0,0
    80002a36:	b7fd                	j	80002a24 <transvirtproc+0x62>

0000000080002a38 <swtch>:
    80002a38:	00153023          	sd	ra,0(a0)
    80002a3c:	00253423          	sd	sp,8(a0)
    80002a40:	e900                	sd	s0,16(a0)
    80002a42:	ed04                	sd	s1,24(a0)
    80002a44:	03253023          	sd	s2,32(a0)
    80002a48:	03353423          	sd	s3,40(a0)
    80002a4c:	03453823          	sd	s4,48(a0)
    80002a50:	03553c23          	sd	s5,56(a0)
    80002a54:	05653023          	sd	s6,64(a0)
    80002a58:	05753423          	sd	s7,72(a0)
    80002a5c:	05853823          	sd	s8,80(a0)
    80002a60:	05953c23          	sd	s9,88(a0)
    80002a64:	07a53023          	sd	s10,96(a0)
    80002a68:	07b53423          	sd	s11,104(a0)
    80002a6c:	0005b083          	ld	ra,0(a1)
    80002a70:	0085b103          	ld	sp,8(a1)
    80002a74:	6980                	ld	s0,16(a1)
    80002a76:	6d84                	ld	s1,24(a1)
    80002a78:	0205b903          	ld	s2,32(a1)
    80002a7c:	0285b983          	ld	s3,40(a1)
    80002a80:	0305ba03          	ld	s4,48(a1)
    80002a84:	0385ba83          	ld	s5,56(a1)
    80002a88:	0405bb03          	ld	s6,64(a1)
    80002a8c:	0485bb83          	ld	s7,72(a1)
    80002a90:	0505bc03          	ld	s8,80(a1)
    80002a94:	0585bc83          	ld	s9,88(a1)
    80002a98:	0605bd03          	ld	s10,96(a1)
    80002a9c:	0685bd83          	ld	s11,104(a1)
    80002aa0:	8082                	ret

0000000080002aa2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002aa2:	1141                	addi	sp,sp,-16
    80002aa4:	e406                	sd	ra,8(sp)
    80002aa6:	e022                	sd	s0,0(sp)
    80002aa8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002aaa:	00006597          	auipc	a1,0x6
    80002aae:	95e58593          	addi	a1,a1,-1698 # 80008408 <states.0+0x30>
    80002ab2:	00014517          	auipc	a0,0x14
    80002ab6:	04e50513          	addi	a0,a0,78 # 80016b00 <tickslock>
    80002aba:	ffffe097          	auipc	ra,0xffffe
    80002abe:	154080e7          	jalr	340(ra) # 80000c0e <initlock>
}
    80002ac2:	60a2                	ld	ra,8(sp)
    80002ac4:	6402                	ld	s0,0(sp)
    80002ac6:	0141                	addi	sp,sp,16
    80002ac8:	8082                	ret

0000000080002aca <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002aca:	1141                	addi	sp,sp,-16
    80002acc:	e422                	sd	s0,8(sp)
    80002ace:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002ad0:	00003797          	auipc	a5,0x3
    80002ad4:	5f078793          	addi	a5,a5,1520 # 800060c0 <kernelvec>
    80002ad8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002adc:	6422                	ld	s0,8(sp)
    80002ade:	0141                	addi	sp,sp,16
    80002ae0:	8082                	ret

0000000080002ae2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002ae2:	1141                	addi	sp,sp,-16
    80002ae4:	e406                	sd	ra,8(sp)
    80002ae6:	e022                	sd	s0,0(sp)
    80002ae8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002aea:	fffff097          	auipc	ra,0xfffff
    80002aee:	0e4080e7          	jalr	228(ra) # 80001bce <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002af2:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002af6:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002af8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002afc:	00004697          	auipc	a3,0x4
    80002b00:	50468693          	addi	a3,a3,1284 # 80007000 <_trampoline>
    80002b04:	00004717          	auipc	a4,0x4
    80002b08:	4fc70713          	addi	a4,a4,1276 # 80007000 <_trampoline>
    80002b0c:	8f15                	sub	a4,a4,a3
    80002b0e:	040007b7          	lui	a5,0x4000
    80002b12:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b14:	07b2                	slli	a5,a5,0xc
    80002b16:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002b18:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b1c:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002b1e:	18002673          	csrr	a2,satp
    80002b22:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b24:	6d30                	ld	a2,88(a0)
    80002b26:	6138                	ld	a4,64(a0)
    80002b28:	6585                	lui	a1,0x1
    80002b2a:	972e                	add	a4,a4,a1
    80002b2c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b2e:	6d38                	ld	a4,88(a0)
    80002b30:	00000617          	auipc	a2,0x0
    80002b34:	13060613          	addi	a2,a2,304 # 80002c60 <usertrap>
    80002b38:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b3a:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002b3c:	8612                	mv	a2,tp
    80002b3e:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002b40:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b44:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b48:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002b4c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b50:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002b52:	6f18                	ld	a4,24(a4)
    80002b54:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b58:	6928                	ld	a0,80(a0)
    80002b5a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b5c:	00004717          	auipc	a4,0x4
    80002b60:	54070713          	addi	a4,a4,1344 # 8000709c <userret>
    80002b64:	8f15                	sub	a4,a4,a3
    80002b66:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b68:	577d                	li	a4,-1
    80002b6a:	177e                	slli	a4,a4,0x3f
    80002b6c:	8d59                	or	a0,a0,a4
    80002b6e:	9782                	jalr	a5
}
    80002b70:	60a2                	ld	ra,8(sp)
    80002b72:	6402                	ld	s0,0(sp)
    80002b74:	0141                	addi	sp,sp,16
    80002b76:	8082                	ret

0000000080002b78 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b78:	1101                	addi	sp,sp,-32
    80002b7a:	ec06                	sd	ra,24(sp)
    80002b7c:	e822                	sd	s0,16(sp)
    80002b7e:	e426                	sd	s1,8(sp)
    80002b80:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b82:	00014497          	auipc	s1,0x14
    80002b86:	f7e48493          	addi	s1,s1,-130 # 80016b00 <tickslock>
    80002b8a:	8526                	mv	a0,s1
    80002b8c:	ffffe097          	auipc	ra,0xffffe
    80002b90:	112080e7          	jalr	274(ra) # 80000c9e <acquire>
  ticks++;
    80002b94:	00006517          	auipc	a0,0x6
    80002b98:	ecc50513          	addi	a0,a0,-308 # 80008a60 <ticks>
    80002b9c:	411c                	lw	a5,0(a0)
    80002b9e:	2785                	addiw	a5,a5,1
    80002ba0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ba2:	00000097          	auipc	ra,0x0
    80002ba6:	83e080e7          	jalr	-1986(ra) # 800023e0 <wakeup>
  release(&tickslock);
    80002baa:	8526                	mv	a0,s1
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	1a6080e7          	jalr	422(ra) # 80000d52 <release>
}
    80002bb4:	60e2                	ld	ra,24(sp)
    80002bb6:	6442                	ld	s0,16(sp)
    80002bb8:	64a2                	ld	s1,8(sp)
    80002bba:	6105                	addi	sp,sp,32
    80002bbc:	8082                	ret

0000000080002bbe <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002bbe:	1101                	addi	sp,sp,-32
    80002bc0:	ec06                	sd	ra,24(sp)
    80002bc2:	e822                	sd	s0,16(sp)
    80002bc4:	e426                	sd	s1,8(sp)
    80002bc6:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, scause" : "=r"(x));
    80002bc8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002bcc:	00074d63          	bltz	a4,80002be6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002bd0:	57fd                	li	a5,-1
    80002bd2:	17fe                	slli	a5,a5,0x3f
    80002bd4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bd6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bd8:	06f70363          	beq	a4,a5,80002c3e <devintr+0x80>
  }
}
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	64a2                	ld	s1,8(sp)
    80002be2:	6105                	addi	sp,sp,32
    80002be4:	8082                	ret
     (scause & 0xff) == 9){
    80002be6:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002bea:	46a5                	li	a3,9
    80002bec:	fed792e3          	bne	a5,a3,80002bd0 <devintr+0x12>
    int irq = plic_claim();
    80002bf0:	00003097          	auipc	ra,0x3
    80002bf4:	5d8080e7          	jalr	1496(ra) # 800061c8 <plic_claim>
    80002bf8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bfa:	47a9                	li	a5,10
    80002bfc:	02f50763          	beq	a0,a5,80002c2a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c00:	4785                	li	a5,1
    80002c02:	02f50963          	beq	a0,a5,80002c34 <devintr+0x76>
    return 1;
    80002c06:	4505                	li	a0,1
    } else if(irq){
    80002c08:	d8f1                	beqz	s1,80002bdc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c0a:	85a6                	mv	a1,s1
    80002c0c:	00006517          	auipc	a0,0x6
    80002c10:	80450513          	addi	a0,a0,-2044 # 80008410 <states.0+0x38>
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	988080e7          	jalr	-1656(ra) # 8000059c <printf>
      plic_complete(irq);
    80002c1c:	8526                	mv	a0,s1
    80002c1e:	00003097          	auipc	ra,0x3
    80002c22:	5ce080e7          	jalr	1486(ra) # 800061ec <plic_complete>
    return 1;
    80002c26:	4505                	li	a0,1
    80002c28:	bf55                	j	80002bdc <devintr+0x1e>
      uartintr();
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	d80080e7          	jalr	-640(ra) # 800009aa <uartintr>
    80002c32:	b7ed                	j	80002c1c <devintr+0x5e>
      virtio_disk_intr();
    80002c34:	00004097          	auipc	ra,0x4
    80002c38:	a80080e7          	jalr	-1408(ra) # 800066b4 <virtio_disk_intr>
    80002c3c:	b7c5                	j	80002c1c <devintr+0x5e>
    if(cpuid() == 0){
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	f64080e7          	jalr	-156(ra) # 80001ba2 <cpuid>
    80002c46:	c901                	beqz	a0,80002c56 <devintr+0x98>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002c48:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c4c:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002c4e:	14479073          	csrw	sip,a5
    return 2;
    80002c52:	4509                	li	a0,2
    80002c54:	b761                	j	80002bdc <devintr+0x1e>
      clockintr();
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	f22080e7          	jalr	-222(ra) # 80002b78 <clockintr>
    80002c5e:	b7ed                	j	80002c48 <devintr+0x8a>

0000000080002c60 <usertrap>:
{
    80002c60:	1101                	addi	sp,sp,-32
    80002c62:	ec06                	sd	ra,24(sp)
    80002c64:	e822                	sd	s0,16(sp)
    80002c66:	e426                	sd	s1,8(sp)
    80002c68:	e04a                	sd	s2,0(sp)
    80002c6a:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002c6c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c70:	1007f793          	andi	a5,a5,256
    80002c74:	e3b1                	bnez	a5,80002cb8 <usertrap+0x58>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002c76:	00003797          	auipc	a5,0x3
    80002c7a:	44a78793          	addi	a5,a5,1098 # 800060c0 <kernelvec>
    80002c7e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	f4c080e7          	jalr	-180(ra) # 80001bce <myproc>
    80002c8a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c8c:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002c8e:	14102773          	csrr	a4,sepc
    80002c92:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002c94:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c98:	47a1                	li	a5,8
    80002c9a:	02f70763          	beq	a4,a5,80002cc8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	f20080e7          	jalr	-224(ra) # 80002bbe <devintr>
    80002ca6:	892a                	mv	s2,a0
    80002ca8:	c151                	beqz	a0,80002d2c <usertrap+0xcc>
  if(killed(p))
    80002caa:	8526                	mv	a0,s1
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	978080e7          	jalr	-1672(ra) # 80002624 <killed>
    80002cb4:	c929                	beqz	a0,80002d06 <usertrap+0xa6>
    80002cb6:	a099                	j	80002cfc <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cb8:	00005517          	auipc	a0,0x5
    80002cbc:	77850513          	addi	a0,a0,1912 # 80008430 <states.0+0x58>
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	880080e7          	jalr	-1920(ra) # 80000540 <panic>
    if(killed(p))
    80002cc8:	00000097          	auipc	ra,0x0
    80002ccc:	95c080e7          	jalr	-1700(ra) # 80002624 <killed>
    80002cd0:	e921                	bnez	a0,80002d20 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002cd2:	6cb8                	ld	a4,88(s1)
    80002cd4:	6f1c                	ld	a5,24(a4)
    80002cd6:	0791                	addi	a5,a5,4
    80002cd8:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002cda:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cde:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002ce2:	10079073          	csrw	sstatus,a5
    syscall();
    80002ce6:	00000097          	auipc	ra,0x0
    80002cea:	2d4080e7          	jalr	724(ra) # 80002fba <syscall>
  if(killed(p))
    80002cee:	8526                	mv	a0,s1
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	934080e7          	jalr	-1740(ra) # 80002624 <killed>
    80002cf8:	c911                	beqz	a0,80002d0c <usertrap+0xac>
    80002cfa:	4901                	li	s2,0
    exit(-1);
    80002cfc:	557d                	li	a0,-1
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	7b2080e7          	jalr	1970(ra) # 800024b0 <exit>
  if(which_dev == 2)
    80002d06:	4789                	li	a5,2
    80002d08:	04f90f63          	beq	s2,a5,80002d66 <usertrap+0x106>
  usertrapret();
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	dd6080e7          	jalr	-554(ra) # 80002ae2 <usertrapret>
}
    80002d14:	60e2                	ld	ra,24(sp)
    80002d16:	6442                	ld	s0,16(sp)
    80002d18:	64a2                	ld	s1,8(sp)
    80002d1a:	6902                	ld	s2,0(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret
      exit(-1);
    80002d20:	557d                	li	a0,-1
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	78e080e7          	jalr	1934(ra) # 800024b0 <exit>
    80002d2a:	b765                	j	80002cd2 <usertrap+0x72>
    asm volatile("csrr %0, scause" : "=r"(x));
    80002d2c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d30:	5890                	lw	a2,48(s1)
    80002d32:	00005517          	auipc	a0,0x5
    80002d36:	71e50513          	addi	a0,a0,1822 # 80008450 <states.0+0x78>
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	862080e7          	jalr	-1950(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002d42:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002d46:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d4a:	00005517          	auipc	a0,0x5
    80002d4e:	73650513          	addi	a0,a0,1846 # 80008480 <states.0+0xa8>
    80002d52:	ffffe097          	auipc	ra,0xffffe
    80002d56:	84a080e7          	jalr	-1974(ra) # 8000059c <printf>
    setkilled(p);
    80002d5a:	8526                	mv	a0,s1
    80002d5c:	00000097          	auipc	ra,0x0
    80002d60:	89c080e7          	jalr	-1892(ra) # 800025f8 <setkilled>
    80002d64:	b769                	j	80002cee <usertrap+0x8e>
    yield();
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	5da080e7          	jalr	1498(ra) # 80002340 <yield>
    80002d6e:	bf79                	j	80002d0c <usertrap+0xac>

0000000080002d70 <kerneltrap>:
{
    80002d70:	7179                	addi	sp,sp,-48
    80002d72:	f406                	sd	ra,40(sp)
    80002d74:	f022                	sd	s0,32(sp)
    80002d76:	ec26                	sd	s1,24(sp)
    80002d78:	e84a                	sd	s2,16(sp)
    80002d7a:	e44e                	sd	s3,8(sp)
    80002d7c:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002d7e:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002d82:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    80002d86:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d8a:	1004f793          	andi	a5,s1,256
    80002d8e:	cb85                	beqz	a5,80002dbe <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002d90:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002d94:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d96:	ef85                	bnez	a5,80002dce <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d98:	00000097          	auipc	ra,0x0
    80002d9c:	e26080e7          	jalr	-474(ra) # 80002bbe <devintr>
    80002da0:	cd1d                	beqz	a0,80002dde <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002da2:	4789                	li	a5,2
    80002da4:	06f50a63          	beq	a0,a5,80002e18 <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002da8:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002dac:	10049073          	csrw	sstatus,s1
}
    80002db0:	70a2                	ld	ra,40(sp)
    80002db2:	7402                	ld	s0,32(sp)
    80002db4:	64e2                	ld	s1,24(sp)
    80002db6:	6942                	ld	s2,16(sp)
    80002db8:	69a2                	ld	s3,8(sp)
    80002dba:	6145                	addi	sp,sp,48
    80002dbc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002dbe:	00005517          	auipc	a0,0x5
    80002dc2:	6e250513          	addi	a0,a0,1762 # 800084a0 <states.0+0xc8>
    80002dc6:	ffffd097          	auipc	ra,0xffffd
    80002dca:	77a080e7          	jalr	1914(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002dce:	00005517          	auipc	a0,0x5
    80002dd2:	6fa50513          	addi	a0,a0,1786 # 800084c8 <states.0+0xf0>
    80002dd6:	ffffd097          	auipc	ra,0xffffd
    80002dda:	76a080e7          	jalr	1898(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002dde:	85ce                	mv	a1,s3
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	70850513          	addi	a0,a0,1800 # 800084e8 <states.0+0x110>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	7b4080e7          	jalr	1972(ra) # 8000059c <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002df0:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002df4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002df8:	00005517          	auipc	a0,0x5
    80002dfc:	70050513          	addi	a0,a0,1792 # 800084f8 <states.0+0x120>
    80002e00:	ffffd097          	auipc	ra,0xffffd
    80002e04:	79c080e7          	jalr	1948(ra) # 8000059c <printf>
    panic("kerneltrap");
    80002e08:	00005517          	auipc	a0,0x5
    80002e0c:	70850513          	addi	a0,a0,1800 # 80008510 <states.0+0x138>
    80002e10:	ffffd097          	auipc	ra,0xffffd
    80002e14:	730080e7          	jalr	1840(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e18:	fffff097          	auipc	ra,0xfffff
    80002e1c:	db6080e7          	jalr	-586(ra) # 80001bce <myproc>
    80002e20:	d541                	beqz	a0,80002da8 <kerneltrap+0x38>
    80002e22:	fffff097          	auipc	ra,0xfffff
    80002e26:	dac080e7          	jalr	-596(ra) # 80001bce <myproc>
    80002e2a:	4d18                	lw	a4,24(a0)
    80002e2c:	4791                	li	a5,4
    80002e2e:	f6f71de3          	bne	a4,a5,80002da8 <kerneltrap+0x38>
    yield();
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	50e080e7          	jalr	1294(ra) # 80002340 <yield>
    80002e3a:	b7bd                	j	80002da8 <kerneltrap+0x38>

0000000080002e3c <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	e426                	sd	s1,8(sp)
    80002e44:	1000                	addi	s0,sp,32
    80002e46:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002e48:	fffff097          	auipc	ra,0xfffff
    80002e4c:	d86080e7          	jalr	-634(ra) # 80001bce <myproc>
    switch (n)
    80002e50:	4795                	li	a5,5
    80002e52:	0497e163          	bltu	a5,s1,80002e94 <argraw+0x58>
    80002e56:	048a                	slli	s1,s1,0x2
    80002e58:	00005717          	auipc	a4,0x5
    80002e5c:	6f070713          	addi	a4,a4,1776 # 80008548 <states.0+0x170>
    80002e60:	94ba                	add	s1,s1,a4
    80002e62:	409c                	lw	a5,0(s1)
    80002e64:	97ba                	add	a5,a5,a4
    80002e66:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002e68:	6d3c                	ld	a5,88(a0)
    80002e6a:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002e6c:	60e2                	ld	ra,24(sp)
    80002e6e:	6442                	ld	s0,16(sp)
    80002e70:	64a2                	ld	s1,8(sp)
    80002e72:	6105                	addi	sp,sp,32
    80002e74:	8082                	ret
        return p->trapframe->a1;
    80002e76:	6d3c                	ld	a5,88(a0)
    80002e78:	7fa8                	ld	a0,120(a5)
    80002e7a:	bfcd                	j	80002e6c <argraw+0x30>
        return p->trapframe->a2;
    80002e7c:	6d3c                	ld	a5,88(a0)
    80002e7e:	63c8                	ld	a0,128(a5)
    80002e80:	b7f5                	j	80002e6c <argraw+0x30>
        return p->trapframe->a3;
    80002e82:	6d3c                	ld	a5,88(a0)
    80002e84:	67c8                	ld	a0,136(a5)
    80002e86:	b7dd                	j	80002e6c <argraw+0x30>
        return p->trapframe->a4;
    80002e88:	6d3c                	ld	a5,88(a0)
    80002e8a:	6bc8                	ld	a0,144(a5)
    80002e8c:	b7c5                	j	80002e6c <argraw+0x30>
        return p->trapframe->a5;
    80002e8e:	6d3c                	ld	a5,88(a0)
    80002e90:	6fc8                	ld	a0,152(a5)
    80002e92:	bfe9                	j	80002e6c <argraw+0x30>
    panic("argraw");
    80002e94:	00005517          	auipc	a0,0x5
    80002e98:	68c50513          	addi	a0,a0,1676 # 80008520 <states.0+0x148>
    80002e9c:	ffffd097          	auipc	ra,0xffffd
    80002ea0:	6a4080e7          	jalr	1700(ra) # 80000540 <panic>

0000000080002ea4 <fetchaddr>:
{
    80002ea4:	1101                	addi	sp,sp,-32
    80002ea6:	ec06                	sd	ra,24(sp)
    80002ea8:	e822                	sd	s0,16(sp)
    80002eaa:	e426                	sd	s1,8(sp)
    80002eac:	e04a                	sd	s2,0(sp)
    80002eae:	1000                	addi	s0,sp,32
    80002eb0:	84aa                	mv	s1,a0
    80002eb2:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	d1a080e7          	jalr	-742(ra) # 80001bce <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ebc:	653c                	ld	a5,72(a0)
    80002ebe:	02f4f863          	bgeu	s1,a5,80002eee <fetchaddr+0x4a>
    80002ec2:	00848713          	addi	a4,s1,8
    80002ec6:	02e7e663          	bltu	a5,a4,80002ef2 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eca:	46a1                	li	a3,8
    80002ecc:	8626                	mv	a2,s1
    80002ece:	85ca                	mv	a1,s2
    80002ed0:	6928                	ld	a0,80(a0)
    80002ed2:	fffff097          	auipc	ra,0xfffff
    80002ed6:	8ee080e7          	jalr	-1810(ra) # 800017c0 <copyin>
    80002eda:	00a03533          	snez	a0,a0
    80002ede:	40a00533          	neg	a0,a0
}
    80002ee2:	60e2                	ld	ra,24(sp)
    80002ee4:	6442                	ld	s0,16(sp)
    80002ee6:	64a2                	ld	s1,8(sp)
    80002ee8:	6902                	ld	s2,0(sp)
    80002eea:	6105                	addi	sp,sp,32
    80002eec:	8082                	ret
        return -1;
    80002eee:	557d                	li	a0,-1
    80002ef0:	bfcd                	j	80002ee2 <fetchaddr+0x3e>
    80002ef2:	557d                	li	a0,-1
    80002ef4:	b7fd                	j	80002ee2 <fetchaddr+0x3e>

0000000080002ef6 <fetchstr>:
{
    80002ef6:	7179                	addi	sp,sp,-48
    80002ef8:	f406                	sd	ra,40(sp)
    80002efa:	f022                	sd	s0,32(sp)
    80002efc:	ec26                	sd	s1,24(sp)
    80002efe:	e84a                	sd	s2,16(sp)
    80002f00:	e44e                	sd	s3,8(sp)
    80002f02:	1800                	addi	s0,sp,48
    80002f04:	892a                	mv	s2,a0
    80002f06:	84ae                	mv	s1,a1
    80002f08:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002f0a:	fffff097          	auipc	ra,0xfffff
    80002f0e:	cc4080e7          	jalr	-828(ra) # 80001bce <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f12:	86ce                	mv	a3,s3
    80002f14:	864a                	mv	a2,s2
    80002f16:	85a6                	mv	a1,s1
    80002f18:	6928                	ld	a0,80(a0)
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	934080e7          	jalr	-1740(ra) # 8000184e <copyinstr>
    80002f22:	00054e63          	bltz	a0,80002f3e <fetchstr+0x48>
    return strlen(buf);
    80002f26:	8526                	mv	a0,s1
    80002f28:	ffffe097          	auipc	ra,0xffffe
    80002f2c:	fee080e7          	jalr	-18(ra) # 80000f16 <strlen>
}
    80002f30:	70a2                	ld	ra,40(sp)
    80002f32:	7402                	ld	s0,32(sp)
    80002f34:	64e2                	ld	s1,24(sp)
    80002f36:	6942                	ld	s2,16(sp)
    80002f38:	69a2                	ld	s3,8(sp)
    80002f3a:	6145                	addi	sp,sp,48
    80002f3c:	8082                	ret
        return -1;
    80002f3e:	557d                	li	a0,-1
    80002f40:	bfc5                	j	80002f30 <fetchstr+0x3a>

0000000080002f42 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f42:	1101                	addi	sp,sp,-32
    80002f44:	ec06                	sd	ra,24(sp)
    80002f46:	e822                	sd	s0,16(sp)
    80002f48:	e426                	sd	s1,8(sp)
    80002f4a:	1000                	addi	s0,sp,32
    80002f4c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f4e:	00000097          	auipc	ra,0x0
    80002f52:	eee080e7          	jalr	-274(ra) # 80002e3c <argraw>
    80002f56:	c088                	sw	a0,0(s1)
}
    80002f58:	60e2                	ld	ra,24(sp)
    80002f5a:	6442                	ld	s0,16(sp)
    80002f5c:	64a2                	ld	s1,8(sp)
    80002f5e:	6105                	addi	sp,sp,32
    80002f60:	8082                	ret

0000000080002f62 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002f62:	1101                	addi	sp,sp,-32
    80002f64:	ec06                	sd	ra,24(sp)
    80002f66:	e822                	sd	s0,16(sp)
    80002f68:	e426                	sd	s1,8(sp)
    80002f6a:	1000                	addi	s0,sp,32
    80002f6c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f6e:	00000097          	auipc	ra,0x0
    80002f72:	ece080e7          	jalr	-306(ra) # 80002e3c <argraw>
    80002f76:	e088                	sd	a0,0(s1)
}
    80002f78:	60e2                	ld	ra,24(sp)
    80002f7a:	6442                	ld	s0,16(sp)
    80002f7c:	64a2                	ld	s1,8(sp)
    80002f7e:	6105                	addi	sp,sp,32
    80002f80:	8082                	ret

0000000080002f82 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f82:	7179                	addi	sp,sp,-48
    80002f84:	f406                	sd	ra,40(sp)
    80002f86:	f022                	sd	s0,32(sp)
    80002f88:	ec26                	sd	s1,24(sp)
    80002f8a:	e84a                	sd	s2,16(sp)
    80002f8c:	1800                	addi	s0,sp,48
    80002f8e:	84ae                	mv	s1,a1
    80002f90:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002f92:	fd840593          	addi	a1,s0,-40
    80002f96:	00000097          	auipc	ra,0x0
    80002f9a:	fcc080e7          	jalr	-52(ra) # 80002f62 <argaddr>
    return fetchstr(addr, buf, max);
    80002f9e:	864a                	mv	a2,s2
    80002fa0:	85a6                	mv	a1,s1
    80002fa2:	fd843503          	ld	a0,-40(s0)
    80002fa6:	00000097          	auipc	ra,0x0
    80002faa:	f50080e7          	jalr	-176(ra) # 80002ef6 <fetchstr>
}
    80002fae:	70a2                	ld	ra,40(sp)
    80002fb0:	7402                	ld	s0,32(sp)
    80002fb2:	64e2                	ld	s1,24(sp)
    80002fb4:	6942                	ld	s2,16(sp)
    80002fb6:	6145                	addi	sp,sp,48
    80002fb8:	8082                	ret

0000000080002fba <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80002fba:	1101                	addi	sp,sp,-32
    80002fbc:	ec06                	sd	ra,24(sp)
    80002fbe:	e822                	sd	s0,16(sp)
    80002fc0:	e426                	sd	s1,8(sp)
    80002fc2:	e04a                	sd	s2,0(sp)
    80002fc4:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	c08080e7          	jalr	-1016(ra) # 80001bce <myproc>
    80002fce:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80002fd0:	05853903          	ld	s2,88(a0)
    80002fd4:	0a893783          	ld	a5,168(s2)
    80002fd8:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002fdc:	37fd                	addiw	a5,a5,-1
    80002fde:	4765                	li	a4,25
    80002fe0:	00f76f63          	bltu	a4,a5,80002ffe <syscall+0x44>
    80002fe4:	00369713          	slli	a4,a3,0x3
    80002fe8:	00005797          	auipc	a5,0x5
    80002fec:	57878793          	addi	a5,a5,1400 # 80008560 <syscalls>
    80002ff0:	97ba                	add	a5,a5,a4
    80002ff2:	639c                	ld	a5,0(a5)
    80002ff4:	c789                	beqz	a5,80002ffe <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80002ff6:	9782                	jalr	a5
    80002ff8:	06a93823          	sd	a0,112(s2)
    80002ffc:	a839                	j	8000301a <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80002ffe:	15848613          	addi	a2,s1,344
    80003002:	588c                	lw	a1,48(s1)
    80003004:	00005517          	auipc	a0,0x5
    80003008:	52450513          	addi	a0,a0,1316 # 80008528 <states.0+0x150>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	590080e7          	jalr	1424(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003014:	6cbc                	ld	a5,88(s1)
    80003016:	577d                	li	a4,-1
    80003018:	fbb8                	sd	a4,112(a5)
    }
}
    8000301a:	60e2                	ld	ra,24(sp)
    8000301c:	6442                	ld	s0,16(sp)
    8000301e:	64a2                	ld	s1,8(sp)
    80003020:	6902                	ld	s2,0(sp)
    80003022:	6105                	addi	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    8000302e:	fec40593          	addi	a1,s0,-20
    80003032:	4501                	li	a0,0
    80003034:	00000097          	auipc	ra,0x0
    80003038:	f0e080e7          	jalr	-242(ra) # 80002f42 <argint>
    exit(n);
    8000303c:	fec42503          	lw	a0,-20(s0)
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	470080e7          	jalr	1136(ra) # 800024b0 <exit>
    return 0; // not reached
}
    80003048:	4501                	li	a0,0
    8000304a:	60e2                	ld	ra,24(sp)
    8000304c:	6442                	ld	s0,16(sp)
    8000304e:	6105                	addi	sp,sp,32
    80003050:	8082                	ret

0000000080003052 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003052:	1141                	addi	sp,sp,-16
    80003054:	e406                	sd	ra,8(sp)
    80003056:	e022                	sd	s0,0(sp)
    80003058:	0800                	addi	s0,sp,16
    return myproc()->pid;
    8000305a:	fffff097          	auipc	ra,0xfffff
    8000305e:	b74080e7          	jalr	-1164(ra) # 80001bce <myproc>
}
    80003062:	5908                	lw	a0,48(a0)
    80003064:	60a2                	ld	ra,8(sp)
    80003066:	6402                	ld	s0,0(sp)
    80003068:	0141                	addi	sp,sp,16
    8000306a:	8082                	ret

000000008000306c <sys_fork>:

uint64
sys_fork(void)
{
    8000306c:	1141                	addi	sp,sp,-16
    8000306e:	e406                	sd	ra,8(sp)
    80003070:	e022                	sd	s0,0(sp)
    80003072:	0800                	addi	s0,sp,16
    return fork();
    80003074:	fffff097          	auipc	ra,0xfffff
    80003078:	0a6080e7          	jalr	166(ra) # 8000211a <fork>
}
    8000307c:	60a2                	ld	ra,8(sp)
    8000307e:	6402                	ld	s0,0(sp)
    80003080:	0141                	addi	sp,sp,16
    80003082:	8082                	ret

0000000080003084 <sys_wait>:

uint64
sys_wait(void)
{
    80003084:	1101                	addi	sp,sp,-32
    80003086:	ec06                	sd	ra,24(sp)
    80003088:	e822                	sd	s0,16(sp)
    8000308a:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    8000308c:	fe840593          	addi	a1,s0,-24
    80003090:	4501                	li	a0,0
    80003092:	00000097          	auipc	ra,0x0
    80003096:	ed0080e7          	jalr	-304(ra) # 80002f62 <argaddr>
    return wait(p);
    8000309a:	fe843503          	ld	a0,-24(s0)
    8000309e:	fffff097          	auipc	ra,0xfffff
    800030a2:	5b8080e7          	jalr	1464(ra) # 80002656 <wait>
}
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	6105                	addi	sp,sp,32
    800030ac:	8082                	ret

00000000800030ae <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030ae:	7179                	addi	sp,sp,-48
    800030b0:	f406                	sd	ra,40(sp)
    800030b2:	f022                	sd	s0,32(sp)
    800030b4:	ec26                	sd	s1,24(sp)
    800030b6:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800030b8:	fdc40593          	addi	a1,s0,-36
    800030bc:	4501                	li	a0,0
    800030be:	00000097          	auipc	ra,0x0
    800030c2:	e84080e7          	jalr	-380(ra) # 80002f42 <argint>
    addr = myproc()->sz;
    800030c6:	fffff097          	auipc	ra,0xfffff
    800030ca:	b08080e7          	jalr	-1272(ra) # 80001bce <myproc>
    800030ce:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    800030d0:	fdc42503          	lw	a0,-36(s0)
    800030d4:	fffff097          	auipc	ra,0xfffff
    800030d8:	e54080e7          	jalr	-428(ra) # 80001f28 <growproc>
    800030dc:	00054863          	bltz	a0,800030ec <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800030e0:	8526                	mv	a0,s1
    800030e2:	70a2                	ld	ra,40(sp)
    800030e4:	7402                	ld	s0,32(sp)
    800030e6:	64e2                	ld	s1,24(sp)
    800030e8:	6145                	addi	sp,sp,48
    800030ea:	8082                	ret
        return -1;
    800030ec:	54fd                	li	s1,-1
    800030ee:	bfcd                	j	800030e0 <sys_sbrk+0x32>

00000000800030f0 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030f0:	7139                	addi	sp,sp,-64
    800030f2:	fc06                	sd	ra,56(sp)
    800030f4:	f822                	sd	s0,48(sp)
    800030f6:	f426                	sd	s1,40(sp)
    800030f8:	f04a                	sd	s2,32(sp)
    800030fa:	ec4e                	sd	s3,24(sp)
    800030fc:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800030fe:	fcc40593          	addi	a1,s0,-52
    80003102:	4501                	li	a0,0
    80003104:	00000097          	auipc	ra,0x0
    80003108:	e3e080e7          	jalr	-450(ra) # 80002f42 <argint>
    acquire(&tickslock);
    8000310c:	00014517          	auipc	a0,0x14
    80003110:	9f450513          	addi	a0,a0,-1548 # 80016b00 <tickslock>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	b8a080e7          	jalr	-1142(ra) # 80000c9e <acquire>
    ticks0 = ticks;
    8000311c:	00006917          	auipc	s2,0x6
    80003120:	94492903          	lw	s2,-1724(s2) # 80008a60 <ticks>
    while (ticks - ticks0 < n)
    80003124:	fcc42783          	lw	a5,-52(s0)
    80003128:	cf9d                	beqz	a5,80003166 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    8000312a:	00014997          	auipc	s3,0x14
    8000312e:	9d698993          	addi	s3,s3,-1578 # 80016b00 <tickslock>
    80003132:	00006497          	auipc	s1,0x6
    80003136:	92e48493          	addi	s1,s1,-1746 # 80008a60 <ticks>
        if (killed(myproc()))
    8000313a:	fffff097          	auipc	ra,0xfffff
    8000313e:	a94080e7          	jalr	-1388(ra) # 80001bce <myproc>
    80003142:	fffff097          	auipc	ra,0xfffff
    80003146:	4e2080e7          	jalr	1250(ra) # 80002624 <killed>
    8000314a:	ed15                	bnez	a0,80003186 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000314c:	85ce                	mv	a1,s3
    8000314e:	8526                	mv	a0,s1
    80003150:	fffff097          	auipc	ra,0xfffff
    80003154:	22c080e7          	jalr	556(ra) # 8000237c <sleep>
    while (ticks - ticks0 < n)
    80003158:	409c                	lw	a5,0(s1)
    8000315a:	412787bb          	subw	a5,a5,s2
    8000315e:	fcc42703          	lw	a4,-52(s0)
    80003162:	fce7ece3          	bltu	a5,a4,8000313a <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003166:	00014517          	auipc	a0,0x14
    8000316a:	99a50513          	addi	a0,a0,-1638 # 80016b00 <tickslock>
    8000316e:	ffffe097          	auipc	ra,0xffffe
    80003172:	be4080e7          	jalr	-1052(ra) # 80000d52 <release>
    return 0;
    80003176:	4501                	li	a0,0
}
    80003178:	70e2                	ld	ra,56(sp)
    8000317a:	7442                	ld	s0,48(sp)
    8000317c:	74a2                	ld	s1,40(sp)
    8000317e:	7902                	ld	s2,32(sp)
    80003180:	69e2                	ld	s3,24(sp)
    80003182:	6121                	addi	sp,sp,64
    80003184:	8082                	ret
            release(&tickslock);
    80003186:	00014517          	auipc	a0,0x14
    8000318a:	97a50513          	addi	a0,a0,-1670 # 80016b00 <tickslock>
    8000318e:	ffffe097          	auipc	ra,0xffffe
    80003192:	bc4080e7          	jalr	-1084(ra) # 80000d52 <release>
            return -1;
    80003196:	557d                	li	a0,-1
    80003198:	b7c5                	j	80003178 <sys_sleep+0x88>

000000008000319a <sys_kill>:

uint64
sys_kill(void)
{
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800031a2:	fec40593          	addi	a1,s0,-20
    800031a6:	4501                	li	a0,0
    800031a8:	00000097          	auipc	ra,0x0
    800031ac:	d9a080e7          	jalr	-614(ra) # 80002f42 <argint>
    return kill(pid);
    800031b0:	fec42503          	lw	a0,-20(s0)
    800031b4:	fffff097          	auipc	ra,0xfffff
    800031b8:	3d2080e7          	jalr	978(ra) # 80002586 <kill>
}
    800031bc:	60e2                	ld	ra,24(sp)
    800031be:	6442                	ld	s0,16(sp)
    800031c0:	6105                	addi	sp,sp,32
    800031c2:	8082                	ret

00000000800031c4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031c4:	1101                	addi	sp,sp,-32
    800031c6:	ec06                	sd	ra,24(sp)
    800031c8:	e822                	sd	s0,16(sp)
    800031ca:	e426                	sd	s1,8(sp)
    800031cc:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	93250513          	addi	a0,a0,-1742 # 80016b00 <tickslock>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ac8080e7          	jalr	-1336(ra) # 80000c9e <acquire>
    xticks = ticks;
    800031de:	00006497          	auipc	s1,0x6
    800031e2:	8824a483          	lw	s1,-1918(s1) # 80008a60 <ticks>
    release(&tickslock);
    800031e6:	00014517          	auipc	a0,0x14
    800031ea:	91a50513          	addi	a0,a0,-1766 # 80016b00 <tickslock>
    800031ee:	ffffe097          	auipc	ra,0xffffe
    800031f2:	b64080e7          	jalr	-1180(ra) # 80000d52 <release>
    return xticks;
}
    800031f6:	02049513          	slli	a0,s1,0x20
    800031fa:	9101                	srli	a0,a0,0x20
    800031fc:	60e2                	ld	ra,24(sp)
    800031fe:	6442                	ld	s0,16(sp)
    80003200:	64a2                	ld	s1,8(sp)
    80003202:	6105                	addi	sp,sp,32
    80003204:	8082                	ret

0000000080003206 <sys_ps>:

void *
sys_ps(void)
{
    80003206:	1101                	addi	sp,sp,-32
    80003208:	ec06                	sd	ra,24(sp)
    8000320a:	e822                	sd	s0,16(sp)
    8000320c:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    8000320e:	fe042623          	sw	zero,-20(s0)
    80003212:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003216:	fec40593          	addi	a1,s0,-20
    8000321a:	4501                	li	a0,0
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	d26080e7          	jalr	-730(ra) # 80002f42 <argint>
    argint(1, &count);
    80003224:	fe840593          	addi	a1,s0,-24
    80003228:	4505                	li	a0,1
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	d18080e7          	jalr	-744(ra) # 80002f42 <argint>
    return ps((uint8)start, (uint8)count);
    80003232:	fe844583          	lbu	a1,-24(s0)
    80003236:	fec44503          	lbu	a0,-20(s0)
    8000323a:	fffff097          	auipc	ra,0xfffff
    8000323e:	d4a080e7          	jalr	-694(ra) # 80001f84 <ps>
}
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	6105                	addi	sp,sp,32
    80003248:	8082                	ret

000000008000324a <sys_schedls>:

uint64 sys_schedls(void)
{
    8000324a:	1141                	addi	sp,sp,-16
    8000324c:	e406                	sd	ra,8(sp)
    8000324e:	e022                	sd	s0,0(sp)
    80003250:	0800                	addi	s0,sp,16
    schedls();
    80003252:	fffff097          	auipc	ra,0xfffff
    80003256:	68e080e7          	jalr	1678(ra) # 800028e0 <schedls>
    return 0;
}
    8000325a:	4501                	li	a0,0
    8000325c:	60a2                	ld	ra,8(sp)
    8000325e:	6402                	ld	s0,0(sp)
    80003260:	0141                	addi	sp,sp,16
    80003262:	8082                	ret

0000000080003264 <sys_schedset>:

uint64 sys_schedset(void)
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	1000                	addi	s0,sp,32
    int id = 0;
    8000326c:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003270:	fec40593          	addi	a1,s0,-20
    80003274:	4501                	li	a0,0
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	ccc080e7          	jalr	-820(ra) # 80002f42 <argint>
    schedset(id - 1);
    8000327e:	fec42503          	lw	a0,-20(s0)
    80003282:	357d                	addiw	a0,a0,-1
    80003284:	fffff097          	auipc	ra,0xfffff
    80003288:	6f2080e7          	jalr	1778(ra) # 80002976 <schedset>
    return 0;
}
    8000328c:	4501                	li	a0,0
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret

0000000080003296 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    80003296:	7179                	addi	sp,sp,-48
    80003298:	f406                	sd	ra,40(sp)
    8000329a:	f022                	sd	s0,32(sp)
    8000329c:	ec26                	sd	s1,24(sp)
    8000329e:	1800                	addi	s0,sp,48
    int pid = 0;
    800032a0:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    800032a4:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    800032a8:	fd040593          	addi	a1,s0,-48
    800032ac:	4501                	li	a0,0
    800032ae:	00000097          	auipc	ra,0x0
    800032b2:	cb4080e7          	jalr	-844(ra) # 80002f62 <argaddr>
    argint(1, &pid);
    800032b6:	fdc40593          	addi	a1,s0,-36
    800032ba:	4505                	li	a0,1
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	c86080e7          	jalr	-890(ra) # 80002f42 <argint>
    if (pid == 0) {
    800032c4:	fdc42783          	lw	a5,-36(s0)
    800032c8:	cf91                	beqz	a5,800032e4 <sys_va2pa+0x4e>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    800032ca:	fdc42583          	lw	a1,-36(s0)
    800032ce:	fd043503          	ld	a0,-48(s0)
    800032d2:	fffff097          	auipc	ra,0xfffff
    800032d6:	6f0080e7          	jalr	1776(ra) # 800029c2 <transvirtproc>
}
    800032da:	70a2                	ld	ra,40(sp)
    800032dc:	7402                	ld	s0,32(sp)
    800032de:	64e2                	ld	s1,24(sp)
    800032e0:	6145                	addi	sp,sp,48
    800032e2:	8082                	ret
	struct proc *p = myproc();
    800032e4:	fffff097          	auipc	ra,0xfffff
    800032e8:	8ea080e7          	jalr	-1814(ra) # 80001bce <myproc>
    800032ec:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800032ee:	ffffe097          	auipc	ra,0xffffe
    800032f2:	9b0080e7          	jalr	-1616(ra) # 80000c9e <acquire>
	pid = p->pid;
    800032f6:	589c                	lw	a5,48(s1)
    800032f8:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    800032fc:	8526                	mv	a0,s1
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	a54080e7          	jalr	-1452(ra) # 80000d52 <release>
    80003306:	b7d1                	j	800032ca <sys_va2pa+0x34>

0000000080003308 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003308:	1141                	addi	sp,sp,-16
    8000330a:	e406                	sd	ra,8(sp)
    8000330c:	e022                	sd	s0,0(sp)
    8000330e:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    80003310:	00005597          	auipc	a1,0x5
    80003314:	7285b583          	ld	a1,1832(a1) # 80008a38 <FREE_PAGES>
    80003318:	00005517          	auipc	a0,0x5
    8000331c:	22850513          	addi	a0,a0,552 # 80008540 <states.0+0x168>
    80003320:	ffffd097          	auipc	ra,0xffffd
    80003324:	27c080e7          	jalr	636(ra) # 8000059c <printf>
    return 0;
}
    80003328:	4501                	li	a0,0
    8000332a:	60a2                	ld	ra,8(sp)
    8000332c:	6402                	ld	s0,0(sp)
    8000332e:	0141                	addi	sp,sp,16
    80003330:	8082                	ret

0000000080003332 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003332:	7179                	addi	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	e052                	sd	s4,0(sp)
    80003340:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003342:	00005597          	auipc	a1,0x5
    80003346:	2f658593          	addi	a1,a1,758 # 80008638 <syscalls+0xd8>
    8000334a:	00013517          	auipc	a0,0x13
    8000334e:	7ce50513          	addi	a0,a0,1998 # 80016b18 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	8bc080e7          	jalr	-1860(ra) # 80000c0e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000335a:	0001b797          	auipc	a5,0x1b
    8000335e:	7be78793          	addi	a5,a5,1982 # 8001eb18 <bcache+0x8000>
    80003362:	0001c717          	auipc	a4,0x1c
    80003366:	a1e70713          	addi	a4,a4,-1506 # 8001ed80 <bcache+0x8268>
    8000336a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000336e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003372:	00013497          	auipc	s1,0x13
    80003376:	7be48493          	addi	s1,s1,1982 # 80016b30 <bcache+0x18>
    b->next = bcache.head.next;
    8000337a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000337c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000337e:	00005a17          	auipc	s4,0x5
    80003382:	2c2a0a13          	addi	s4,s4,706 # 80008640 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003386:	2b893783          	ld	a5,696(s2)
    8000338a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000338c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003390:	85d2                	mv	a1,s4
    80003392:	01048513          	addi	a0,s1,16
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	4c8080e7          	jalr	1224(ra) # 8000485e <initsleeplock>
    bcache.head.next->prev = b;
    8000339e:	2b893783          	ld	a5,696(s2)
    800033a2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033a4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033a8:	45848493          	addi	s1,s1,1112
    800033ac:	fd349de3          	bne	s1,s3,80003386 <binit+0x54>
  }
}
    800033b0:	70a2                	ld	ra,40(sp)
    800033b2:	7402                	ld	s0,32(sp)
    800033b4:	64e2                	ld	s1,24(sp)
    800033b6:	6942                	ld	s2,16(sp)
    800033b8:	69a2                	ld	s3,8(sp)
    800033ba:	6a02                	ld	s4,0(sp)
    800033bc:	6145                	addi	sp,sp,48
    800033be:	8082                	ret

00000000800033c0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033c0:	7179                	addi	sp,sp,-48
    800033c2:	f406                	sd	ra,40(sp)
    800033c4:	f022                	sd	s0,32(sp)
    800033c6:	ec26                	sd	s1,24(sp)
    800033c8:	e84a                	sd	s2,16(sp)
    800033ca:	e44e                	sd	s3,8(sp)
    800033cc:	1800                	addi	s0,sp,48
    800033ce:	892a                	mv	s2,a0
    800033d0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033d2:	00013517          	auipc	a0,0x13
    800033d6:	74650513          	addi	a0,a0,1862 # 80016b18 <bcache>
    800033da:	ffffe097          	auipc	ra,0xffffe
    800033de:	8c4080e7          	jalr	-1852(ra) # 80000c9e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033e2:	0001c497          	auipc	s1,0x1c
    800033e6:	9ee4b483          	ld	s1,-1554(s1) # 8001edd0 <bcache+0x82b8>
    800033ea:	0001c797          	auipc	a5,0x1c
    800033ee:	99678793          	addi	a5,a5,-1642 # 8001ed80 <bcache+0x8268>
    800033f2:	02f48f63          	beq	s1,a5,80003430 <bread+0x70>
    800033f6:	873e                	mv	a4,a5
    800033f8:	a021                	j	80003400 <bread+0x40>
    800033fa:	68a4                	ld	s1,80(s1)
    800033fc:	02e48a63          	beq	s1,a4,80003430 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003400:	449c                	lw	a5,8(s1)
    80003402:	ff279ce3          	bne	a5,s2,800033fa <bread+0x3a>
    80003406:	44dc                	lw	a5,12(s1)
    80003408:	ff3799e3          	bne	a5,s3,800033fa <bread+0x3a>
      b->refcnt++;
    8000340c:	40bc                	lw	a5,64(s1)
    8000340e:	2785                	addiw	a5,a5,1
    80003410:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003412:	00013517          	auipc	a0,0x13
    80003416:	70650513          	addi	a0,a0,1798 # 80016b18 <bcache>
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	938080e7          	jalr	-1736(ra) # 80000d52 <release>
      acquiresleep(&b->lock);
    80003422:	01048513          	addi	a0,s1,16
    80003426:	00001097          	auipc	ra,0x1
    8000342a:	472080e7          	jalr	1138(ra) # 80004898 <acquiresleep>
      return b;
    8000342e:	a8b9                	j	8000348c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003430:	0001c497          	auipc	s1,0x1c
    80003434:	9984b483          	ld	s1,-1640(s1) # 8001edc8 <bcache+0x82b0>
    80003438:	0001c797          	auipc	a5,0x1c
    8000343c:	94878793          	addi	a5,a5,-1720 # 8001ed80 <bcache+0x8268>
    80003440:	00f48863          	beq	s1,a5,80003450 <bread+0x90>
    80003444:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003446:	40bc                	lw	a5,64(s1)
    80003448:	cf81                	beqz	a5,80003460 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000344a:	64a4                	ld	s1,72(s1)
    8000344c:	fee49de3          	bne	s1,a4,80003446 <bread+0x86>
  panic("bget: no buffers");
    80003450:	00005517          	auipc	a0,0x5
    80003454:	1f850513          	addi	a0,a0,504 # 80008648 <syscalls+0xe8>
    80003458:	ffffd097          	auipc	ra,0xffffd
    8000345c:	0e8080e7          	jalr	232(ra) # 80000540 <panic>
      b->dev = dev;
    80003460:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003464:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003468:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000346c:	4785                	li	a5,1
    8000346e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003470:	00013517          	auipc	a0,0x13
    80003474:	6a850513          	addi	a0,a0,1704 # 80016b18 <bcache>
    80003478:	ffffe097          	auipc	ra,0xffffe
    8000347c:	8da080e7          	jalr	-1830(ra) # 80000d52 <release>
      acquiresleep(&b->lock);
    80003480:	01048513          	addi	a0,s1,16
    80003484:	00001097          	auipc	ra,0x1
    80003488:	414080e7          	jalr	1044(ra) # 80004898 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000348c:	409c                	lw	a5,0(s1)
    8000348e:	cb89                	beqz	a5,800034a0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003490:	8526                	mv	a0,s1
    80003492:	70a2                	ld	ra,40(sp)
    80003494:	7402                	ld	s0,32(sp)
    80003496:	64e2                	ld	s1,24(sp)
    80003498:	6942                	ld	s2,16(sp)
    8000349a:	69a2                	ld	s3,8(sp)
    8000349c:	6145                	addi	sp,sp,48
    8000349e:	8082                	ret
    virtio_disk_rw(b, 0);
    800034a0:	4581                	li	a1,0
    800034a2:	8526                	mv	a0,s1
    800034a4:	00003097          	auipc	ra,0x3
    800034a8:	fde080e7          	jalr	-34(ra) # 80006482 <virtio_disk_rw>
    b->valid = 1;
    800034ac:	4785                	li	a5,1
    800034ae:	c09c                	sw	a5,0(s1)
  return b;
    800034b0:	b7c5                	j	80003490 <bread+0xd0>

00000000800034b2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034b2:	1101                	addi	sp,sp,-32
    800034b4:	ec06                	sd	ra,24(sp)
    800034b6:	e822                	sd	s0,16(sp)
    800034b8:	e426                	sd	s1,8(sp)
    800034ba:	1000                	addi	s0,sp,32
    800034bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034be:	0541                	addi	a0,a0,16
    800034c0:	00001097          	auipc	ra,0x1
    800034c4:	472080e7          	jalr	1138(ra) # 80004932 <holdingsleep>
    800034c8:	cd01                	beqz	a0,800034e0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034ca:	4585                	li	a1,1
    800034cc:	8526                	mv	a0,s1
    800034ce:	00003097          	auipc	ra,0x3
    800034d2:	fb4080e7          	jalr	-76(ra) # 80006482 <virtio_disk_rw>
}
    800034d6:	60e2                	ld	ra,24(sp)
    800034d8:	6442                	ld	s0,16(sp)
    800034da:	64a2                	ld	s1,8(sp)
    800034dc:	6105                	addi	sp,sp,32
    800034de:	8082                	ret
    panic("bwrite");
    800034e0:	00005517          	auipc	a0,0x5
    800034e4:	18050513          	addi	a0,a0,384 # 80008660 <syscalls+0x100>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	058080e7          	jalr	88(ra) # 80000540 <panic>

00000000800034f0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034f0:	1101                	addi	sp,sp,-32
    800034f2:	ec06                	sd	ra,24(sp)
    800034f4:	e822                	sd	s0,16(sp)
    800034f6:	e426                	sd	s1,8(sp)
    800034f8:	e04a                	sd	s2,0(sp)
    800034fa:	1000                	addi	s0,sp,32
    800034fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034fe:	01050913          	addi	s2,a0,16
    80003502:	854a                	mv	a0,s2
    80003504:	00001097          	auipc	ra,0x1
    80003508:	42e080e7          	jalr	1070(ra) # 80004932 <holdingsleep>
    8000350c:	c92d                	beqz	a0,8000357e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000350e:	854a                	mv	a0,s2
    80003510:	00001097          	auipc	ra,0x1
    80003514:	3de080e7          	jalr	990(ra) # 800048ee <releasesleep>

  acquire(&bcache.lock);
    80003518:	00013517          	auipc	a0,0x13
    8000351c:	60050513          	addi	a0,a0,1536 # 80016b18 <bcache>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	77e080e7          	jalr	1918(ra) # 80000c9e <acquire>
  b->refcnt--;
    80003528:	40bc                	lw	a5,64(s1)
    8000352a:	37fd                	addiw	a5,a5,-1
    8000352c:	0007871b          	sext.w	a4,a5
    80003530:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003532:	eb05                	bnez	a4,80003562 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003534:	68bc                	ld	a5,80(s1)
    80003536:	64b8                	ld	a4,72(s1)
    80003538:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000353a:	64bc                	ld	a5,72(s1)
    8000353c:	68b8                	ld	a4,80(s1)
    8000353e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003540:	0001b797          	auipc	a5,0x1b
    80003544:	5d878793          	addi	a5,a5,1496 # 8001eb18 <bcache+0x8000>
    80003548:	2b87b703          	ld	a4,696(a5)
    8000354c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000354e:	0001c717          	auipc	a4,0x1c
    80003552:	83270713          	addi	a4,a4,-1998 # 8001ed80 <bcache+0x8268>
    80003556:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003558:	2b87b703          	ld	a4,696(a5)
    8000355c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000355e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003562:	00013517          	auipc	a0,0x13
    80003566:	5b650513          	addi	a0,a0,1462 # 80016b18 <bcache>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	7e8080e7          	jalr	2024(ra) # 80000d52 <release>
}
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6902                	ld	s2,0(sp)
    8000357a:	6105                	addi	sp,sp,32
    8000357c:	8082                	ret
    panic("brelse");
    8000357e:	00005517          	auipc	a0,0x5
    80003582:	0ea50513          	addi	a0,a0,234 # 80008668 <syscalls+0x108>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	fba080e7          	jalr	-70(ra) # 80000540 <panic>

000000008000358e <bpin>:

void
bpin(struct buf *b) {
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	1000                	addi	s0,sp,32
    80003598:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000359a:	00013517          	auipc	a0,0x13
    8000359e:	57e50513          	addi	a0,a0,1406 # 80016b18 <bcache>
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	6fc080e7          	jalr	1788(ra) # 80000c9e <acquire>
  b->refcnt++;
    800035aa:	40bc                	lw	a5,64(s1)
    800035ac:	2785                	addiw	a5,a5,1
    800035ae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035b0:	00013517          	auipc	a0,0x13
    800035b4:	56850513          	addi	a0,a0,1384 # 80016b18 <bcache>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	79a080e7          	jalr	1946(ra) # 80000d52 <release>
}
    800035c0:	60e2                	ld	ra,24(sp)
    800035c2:	6442                	ld	s0,16(sp)
    800035c4:	64a2                	ld	s1,8(sp)
    800035c6:	6105                	addi	sp,sp,32
    800035c8:	8082                	ret

00000000800035ca <bunpin>:

void
bunpin(struct buf *b) {
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035d6:	00013517          	auipc	a0,0x13
    800035da:	54250513          	addi	a0,a0,1346 # 80016b18 <bcache>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	6c0080e7          	jalr	1728(ra) # 80000c9e <acquire>
  b->refcnt--;
    800035e6:	40bc                	lw	a5,64(s1)
    800035e8:	37fd                	addiw	a5,a5,-1
    800035ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035ec:	00013517          	auipc	a0,0x13
    800035f0:	52c50513          	addi	a0,a0,1324 # 80016b18 <bcache>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	75e080e7          	jalr	1886(ra) # 80000d52 <release>
}
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6105                	addi	sp,sp,32
    80003604:	8082                	ret

0000000080003606 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003606:	1101                	addi	sp,sp,-32
    80003608:	ec06                	sd	ra,24(sp)
    8000360a:	e822                	sd	s0,16(sp)
    8000360c:	e426                	sd	s1,8(sp)
    8000360e:	e04a                	sd	s2,0(sp)
    80003610:	1000                	addi	s0,sp,32
    80003612:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003614:	00d5d59b          	srliw	a1,a1,0xd
    80003618:	0001c797          	auipc	a5,0x1c
    8000361c:	bdc7a783          	lw	a5,-1060(a5) # 8001f1f4 <sb+0x1c>
    80003620:	9dbd                	addw	a1,a1,a5
    80003622:	00000097          	auipc	ra,0x0
    80003626:	d9e080e7          	jalr	-610(ra) # 800033c0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000362a:	0074f713          	andi	a4,s1,7
    8000362e:	4785                	li	a5,1
    80003630:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003634:	14ce                	slli	s1,s1,0x33
    80003636:	90d9                	srli	s1,s1,0x36
    80003638:	00950733          	add	a4,a0,s1
    8000363c:	05874703          	lbu	a4,88(a4)
    80003640:	00e7f6b3          	and	a3,a5,a4
    80003644:	c69d                	beqz	a3,80003672 <bfree+0x6c>
    80003646:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003648:	94aa                	add	s1,s1,a0
    8000364a:	fff7c793          	not	a5,a5
    8000364e:	8f7d                	and	a4,a4,a5
    80003650:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003654:	00001097          	auipc	ra,0x1
    80003658:	126080e7          	jalr	294(ra) # 8000477a <log_write>
  brelse(bp);
    8000365c:	854a                	mv	a0,s2
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	e92080e7          	jalr	-366(ra) # 800034f0 <brelse>
}
    80003666:	60e2                	ld	ra,24(sp)
    80003668:	6442                	ld	s0,16(sp)
    8000366a:	64a2                	ld	s1,8(sp)
    8000366c:	6902                	ld	s2,0(sp)
    8000366e:	6105                	addi	sp,sp,32
    80003670:	8082                	ret
    panic("freeing free block");
    80003672:	00005517          	auipc	a0,0x5
    80003676:	ffe50513          	addi	a0,a0,-2 # 80008670 <syscalls+0x110>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	ec6080e7          	jalr	-314(ra) # 80000540 <panic>

0000000080003682 <balloc>:
{
    80003682:	711d                	addi	sp,sp,-96
    80003684:	ec86                	sd	ra,88(sp)
    80003686:	e8a2                	sd	s0,80(sp)
    80003688:	e4a6                	sd	s1,72(sp)
    8000368a:	e0ca                	sd	s2,64(sp)
    8000368c:	fc4e                	sd	s3,56(sp)
    8000368e:	f852                	sd	s4,48(sp)
    80003690:	f456                	sd	s5,40(sp)
    80003692:	f05a                	sd	s6,32(sp)
    80003694:	ec5e                	sd	s7,24(sp)
    80003696:	e862                	sd	s8,16(sp)
    80003698:	e466                	sd	s9,8(sp)
    8000369a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000369c:	0001c797          	auipc	a5,0x1c
    800036a0:	b407a783          	lw	a5,-1216(a5) # 8001f1dc <sb+0x4>
    800036a4:	cff5                	beqz	a5,800037a0 <balloc+0x11e>
    800036a6:	8baa                	mv	s7,a0
    800036a8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036aa:	0001cb17          	auipc	s6,0x1c
    800036ae:	b2eb0b13          	addi	s6,s6,-1234 # 8001f1d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036b2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036b4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036b6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036b8:	6c89                	lui	s9,0x2
    800036ba:	a061                	j	80003742 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036bc:	97ca                	add	a5,a5,s2
    800036be:	8e55                	or	a2,a2,a3
    800036c0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800036c4:	854a                	mv	a0,s2
    800036c6:	00001097          	auipc	ra,0x1
    800036ca:	0b4080e7          	jalr	180(ra) # 8000477a <log_write>
        brelse(bp);
    800036ce:	854a                	mv	a0,s2
    800036d0:	00000097          	auipc	ra,0x0
    800036d4:	e20080e7          	jalr	-480(ra) # 800034f0 <brelse>
  bp = bread(dev, bno);
    800036d8:	85a6                	mv	a1,s1
    800036da:	855e                	mv	a0,s7
    800036dc:	00000097          	auipc	ra,0x0
    800036e0:	ce4080e7          	jalr	-796(ra) # 800033c0 <bread>
    800036e4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036e6:	40000613          	li	a2,1024
    800036ea:	4581                	li	a1,0
    800036ec:	05850513          	addi	a0,a0,88
    800036f0:	ffffd097          	auipc	ra,0xffffd
    800036f4:	6aa080e7          	jalr	1706(ra) # 80000d9a <memset>
  log_write(bp);
    800036f8:	854a                	mv	a0,s2
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	080080e7          	jalr	128(ra) # 8000477a <log_write>
  brelse(bp);
    80003702:	854a                	mv	a0,s2
    80003704:	00000097          	auipc	ra,0x0
    80003708:	dec080e7          	jalr	-532(ra) # 800034f0 <brelse>
}
    8000370c:	8526                	mv	a0,s1
    8000370e:	60e6                	ld	ra,88(sp)
    80003710:	6446                	ld	s0,80(sp)
    80003712:	64a6                	ld	s1,72(sp)
    80003714:	6906                	ld	s2,64(sp)
    80003716:	79e2                	ld	s3,56(sp)
    80003718:	7a42                	ld	s4,48(sp)
    8000371a:	7aa2                	ld	s5,40(sp)
    8000371c:	7b02                	ld	s6,32(sp)
    8000371e:	6be2                	ld	s7,24(sp)
    80003720:	6c42                	ld	s8,16(sp)
    80003722:	6ca2                	ld	s9,8(sp)
    80003724:	6125                	addi	sp,sp,96
    80003726:	8082                	ret
    brelse(bp);
    80003728:	854a                	mv	a0,s2
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	dc6080e7          	jalr	-570(ra) # 800034f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003732:	015c87bb          	addw	a5,s9,s5
    80003736:	00078a9b          	sext.w	s5,a5
    8000373a:	004b2703          	lw	a4,4(s6)
    8000373e:	06eaf163          	bgeu	s5,a4,800037a0 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003742:	41fad79b          	sraiw	a5,s5,0x1f
    80003746:	0137d79b          	srliw	a5,a5,0x13
    8000374a:	015787bb          	addw	a5,a5,s5
    8000374e:	40d7d79b          	sraiw	a5,a5,0xd
    80003752:	01cb2583          	lw	a1,28(s6)
    80003756:	9dbd                	addw	a1,a1,a5
    80003758:	855e                	mv	a0,s7
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	c66080e7          	jalr	-922(ra) # 800033c0 <bread>
    80003762:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003764:	004b2503          	lw	a0,4(s6)
    80003768:	000a849b          	sext.w	s1,s5
    8000376c:	8762                	mv	a4,s8
    8000376e:	faa4fde3          	bgeu	s1,a0,80003728 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003772:	00777693          	andi	a3,a4,7
    80003776:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000377a:	41f7579b          	sraiw	a5,a4,0x1f
    8000377e:	01d7d79b          	srliw	a5,a5,0x1d
    80003782:	9fb9                	addw	a5,a5,a4
    80003784:	4037d79b          	sraiw	a5,a5,0x3
    80003788:	00f90633          	add	a2,s2,a5
    8000378c:	05864603          	lbu	a2,88(a2)
    80003790:	00c6f5b3          	and	a1,a3,a2
    80003794:	d585                	beqz	a1,800036bc <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003796:	2705                	addiw	a4,a4,1
    80003798:	2485                	addiw	s1,s1,1
    8000379a:	fd471ae3          	bne	a4,s4,8000376e <balloc+0xec>
    8000379e:	b769                	j	80003728 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800037a0:	00005517          	auipc	a0,0x5
    800037a4:	ee850513          	addi	a0,a0,-280 # 80008688 <syscalls+0x128>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	df4080e7          	jalr	-524(ra) # 8000059c <printf>
  return 0;
    800037b0:	4481                	li	s1,0
    800037b2:	bfa9                	j	8000370c <balloc+0x8a>

00000000800037b4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037b4:	7179                	addi	sp,sp,-48
    800037b6:	f406                	sd	ra,40(sp)
    800037b8:	f022                	sd	s0,32(sp)
    800037ba:	ec26                	sd	s1,24(sp)
    800037bc:	e84a                	sd	s2,16(sp)
    800037be:	e44e                	sd	s3,8(sp)
    800037c0:	e052                	sd	s4,0(sp)
    800037c2:	1800                	addi	s0,sp,48
    800037c4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037c6:	47ad                	li	a5,11
    800037c8:	02b7e863          	bltu	a5,a1,800037f8 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800037cc:	02059793          	slli	a5,a1,0x20
    800037d0:	01e7d593          	srli	a1,a5,0x1e
    800037d4:	00b504b3          	add	s1,a0,a1
    800037d8:	0504a903          	lw	s2,80(s1)
    800037dc:	06091e63          	bnez	s2,80003858 <bmap+0xa4>
      addr = balloc(ip->dev);
    800037e0:	4108                	lw	a0,0(a0)
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	ea0080e7          	jalr	-352(ra) # 80003682 <balloc>
    800037ea:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037ee:	06090563          	beqz	s2,80003858 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800037f2:	0524a823          	sw	s2,80(s1)
    800037f6:	a08d                	j	80003858 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037f8:	ff45849b          	addiw	s1,a1,-12
    800037fc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003800:	0ff00793          	li	a5,255
    80003804:	08e7e563          	bltu	a5,a4,8000388e <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003808:	08052903          	lw	s2,128(a0)
    8000380c:	00091d63          	bnez	s2,80003826 <bmap+0x72>
      addr = balloc(ip->dev);
    80003810:	4108                	lw	a0,0(a0)
    80003812:	00000097          	auipc	ra,0x0
    80003816:	e70080e7          	jalr	-400(ra) # 80003682 <balloc>
    8000381a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000381e:	02090d63          	beqz	s2,80003858 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003822:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003826:	85ca                	mv	a1,s2
    80003828:	0009a503          	lw	a0,0(s3)
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	b94080e7          	jalr	-1132(ra) # 800033c0 <bread>
    80003834:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003836:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000383a:	02049713          	slli	a4,s1,0x20
    8000383e:	01e75593          	srli	a1,a4,0x1e
    80003842:	00b784b3          	add	s1,a5,a1
    80003846:	0004a903          	lw	s2,0(s1)
    8000384a:	02090063          	beqz	s2,8000386a <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000384e:	8552                	mv	a0,s4
    80003850:	00000097          	auipc	ra,0x0
    80003854:	ca0080e7          	jalr	-864(ra) # 800034f0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003858:	854a                	mv	a0,s2
    8000385a:	70a2                	ld	ra,40(sp)
    8000385c:	7402                	ld	s0,32(sp)
    8000385e:	64e2                	ld	s1,24(sp)
    80003860:	6942                	ld	s2,16(sp)
    80003862:	69a2                	ld	s3,8(sp)
    80003864:	6a02                	ld	s4,0(sp)
    80003866:	6145                	addi	sp,sp,48
    80003868:	8082                	ret
      addr = balloc(ip->dev);
    8000386a:	0009a503          	lw	a0,0(s3)
    8000386e:	00000097          	auipc	ra,0x0
    80003872:	e14080e7          	jalr	-492(ra) # 80003682 <balloc>
    80003876:	0005091b          	sext.w	s2,a0
      if(addr){
    8000387a:	fc090ae3          	beqz	s2,8000384e <bmap+0x9a>
        a[bn] = addr;
    8000387e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003882:	8552                	mv	a0,s4
    80003884:	00001097          	auipc	ra,0x1
    80003888:	ef6080e7          	jalr	-266(ra) # 8000477a <log_write>
    8000388c:	b7c9                	j	8000384e <bmap+0x9a>
  panic("bmap: out of range");
    8000388e:	00005517          	auipc	a0,0x5
    80003892:	e1250513          	addi	a0,a0,-494 # 800086a0 <syscalls+0x140>
    80003896:	ffffd097          	auipc	ra,0xffffd
    8000389a:	caa080e7          	jalr	-854(ra) # 80000540 <panic>

000000008000389e <iget>:
{
    8000389e:	7179                	addi	sp,sp,-48
    800038a0:	f406                	sd	ra,40(sp)
    800038a2:	f022                	sd	s0,32(sp)
    800038a4:	ec26                	sd	s1,24(sp)
    800038a6:	e84a                	sd	s2,16(sp)
    800038a8:	e44e                	sd	s3,8(sp)
    800038aa:	e052                	sd	s4,0(sp)
    800038ac:	1800                	addi	s0,sp,48
    800038ae:	89aa                	mv	s3,a0
    800038b0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038b2:	0001c517          	auipc	a0,0x1c
    800038b6:	94650513          	addi	a0,a0,-1722 # 8001f1f8 <itable>
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	3e4080e7          	jalr	996(ra) # 80000c9e <acquire>
  empty = 0;
    800038c2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038c4:	0001c497          	auipc	s1,0x1c
    800038c8:	94c48493          	addi	s1,s1,-1716 # 8001f210 <itable+0x18>
    800038cc:	0001d697          	auipc	a3,0x1d
    800038d0:	3d468693          	addi	a3,a3,980 # 80020ca0 <log>
    800038d4:	a039                	j	800038e2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038d6:	02090b63          	beqz	s2,8000390c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038da:	08848493          	addi	s1,s1,136
    800038de:	02d48a63          	beq	s1,a3,80003912 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038e2:	449c                	lw	a5,8(s1)
    800038e4:	fef059e3          	blez	a5,800038d6 <iget+0x38>
    800038e8:	4098                	lw	a4,0(s1)
    800038ea:	ff3716e3          	bne	a4,s3,800038d6 <iget+0x38>
    800038ee:	40d8                	lw	a4,4(s1)
    800038f0:	ff4713e3          	bne	a4,s4,800038d6 <iget+0x38>
      ip->ref++;
    800038f4:	2785                	addiw	a5,a5,1
    800038f6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038f8:	0001c517          	auipc	a0,0x1c
    800038fc:	90050513          	addi	a0,a0,-1792 # 8001f1f8 <itable>
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	452080e7          	jalr	1106(ra) # 80000d52 <release>
      return ip;
    80003908:	8926                	mv	s2,s1
    8000390a:	a03d                	j	80003938 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000390c:	f7f9                	bnez	a5,800038da <iget+0x3c>
    8000390e:	8926                	mv	s2,s1
    80003910:	b7e9                	j	800038da <iget+0x3c>
  if(empty == 0)
    80003912:	02090c63          	beqz	s2,8000394a <iget+0xac>
  ip->dev = dev;
    80003916:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000391a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000391e:	4785                	li	a5,1
    80003920:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003924:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003928:	0001c517          	auipc	a0,0x1c
    8000392c:	8d050513          	addi	a0,a0,-1840 # 8001f1f8 <itable>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	422080e7          	jalr	1058(ra) # 80000d52 <release>
}
    80003938:	854a                	mv	a0,s2
    8000393a:	70a2                	ld	ra,40(sp)
    8000393c:	7402                	ld	s0,32(sp)
    8000393e:	64e2                	ld	s1,24(sp)
    80003940:	6942                	ld	s2,16(sp)
    80003942:	69a2                	ld	s3,8(sp)
    80003944:	6a02                	ld	s4,0(sp)
    80003946:	6145                	addi	sp,sp,48
    80003948:	8082                	ret
    panic("iget: no inodes");
    8000394a:	00005517          	auipc	a0,0x5
    8000394e:	d6e50513          	addi	a0,a0,-658 # 800086b8 <syscalls+0x158>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	bee080e7          	jalr	-1042(ra) # 80000540 <panic>

000000008000395a <fsinit>:
fsinit(int dev) {
    8000395a:	7179                	addi	sp,sp,-48
    8000395c:	f406                	sd	ra,40(sp)
    8000395e:	f022                	sd	s0,32(sp)
    80003960:	ec26                	sd	s1,24(sp)
    80003962:	e84a                	sd	s2,16(sp)
    80003964:	e44e                	sd	s3,8(sp)
    80003966:	1800                	addi	s0,sp,48
    80003968:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000396a:	4585                	li	a1,1
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	a54080e7          	jalr	-1452(ra) # 800033c0 <bread>
    80003974:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003976:	0001c997          	auipc	s3,0x1c
    8000397a:	86298993          	addi	s3,s3,-1950 # 8001f1d8 <sb>
    8000397e:	02000613          	li	a2,32
    80003982:	05850593          	addi	a1,a0,88
    80003986:	854e                	mv	a0,s3
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	46e080e7          	jalr	1134(ra) # 80000df6 <memmove>
  brelse(bp);
    80003990:	8526                	mv	a0,s1
    80003992:	00000097          	auipc	ra,0x0
    80003996:	b5e080e7          	jalr	-1186(ra) # 800034f0 <brelse>
  if(sb.magic != FSMAGIC)
    8000399a:	0009a703          	lw	a4,0(s3)
    8000399e:	102037b7          	lui	a5,0x10203
    800039a2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039a6:	02f71263          	bne	a4,a5,800039ca <fsinit+0x70>
  initlog(dev, &sb);
    800039aa:	0001c597          	auipc	a1,0x1c
    800039ae:	82e58593          	addi	a1,a1,-2002 # 8001f1d8 <sb>
    800039b2:	854a                	mv	a0,s2
    800039b4:	00001097          	auipc	ra,0x1
    800039b8:	b4a080e7          	jalr	-1206(ra) # 800044fe <initlog>
}
    800039bc:	70a2                	ld	ra,40(sp)
    800039be:	7402                	ld	s0,32(sp)
    800039c0:	64e2                	ld	s1,24(sp)
    800039c2:	6942                	ld	s2,16(sp)
    800039c4:	69a2                	ld	s3,8(sp)
    800039c6:	6145                	addi	sp,sp,48
    800039c8:	8082                	ret
    panic("invalid file system");
    800039ca:	00005517          	auipc	a0,0x5
    800039ce:	cfe50513          	addi	a0,a0,-770 # 800086c8 <syscalls+0x168>
    800039d2:	ffffd097          	auipc	ra,0xffffd
    800039d6:	b6e080e7          	jalr	-1170(ra) # 80000540 <panic>

00000000800039da <iinit>:
{
    800039da:	7179                	addi	sp,sp,-48
    800039dc:	f406                	sd	ra,40(sp)
    800039de:	f022                	sd	s0,32(sp)
    800039e0:	ec26                	sd	s1,24(sp)
    800039e2:	e84a                	sd	s2,16(sp)
    800039e4:	e44e                	sd	s3,8(sp)
    800039e6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039e8:	00005597          	auipc	a1,0x5
    800039ec:	cf858593          	addi	a1,a1,-776 # 800086e0 <syscalls+0x180>
    800039f0:	0001c517          	auipc	a0,0x1c
    800039f4:	80850513          	addi	a0,a0,-2040 # 8001f1f8 <itable>
    800039f8:	ffffd097          	auipc	ra,0xffffd
    800039fc:	216080e7          	jalr	534(ra) # 80000c0e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a00:	0001c497          	auipc	s1,0x1c
    80003a04:	82048493          	addi	s1,s1,-2016 # 8001f220 <itable+0x28>
    80003a08:	0001d997          	auipc	s3,0x1d
    80003a0c:	2a898993          	addi	s3,s3,680 # 80020cb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a10:	00005917          	auipc	s2,0x5
    80003a14:	cd890913          	addi	s2,s2,-808 # 800086e8 <syscalls+0x188>
    80003a18:	85ca                	mv	a1,s2
    80003a1a:	8526                	mv	a0,s1
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	e42080e7          	jalr	-446(ra) # 8000485e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a24:	08848493          	addi	s1,s1,136
    80003a28:	ff3498e3          	bne	s1,s3,80003a18 <iinit+0x3e>
}
    80003a2c:	70a2                	ld	ra,40(sp)
    80003a2e:	7402                	ld	s0,32(sp)
    80003a30:	64e2                	ld	s1,24(sp)
    80003a32:	6942                	ld	s2,16(sp)
    80003a34:	69a2                	ld	s3,8(sp)
    80003a36:	6145                	addi	sp,sp,48
    80003a38:	8082                	ret

0000000080003a3a <ialloc>:
{
    80003a3a:	715d                	addi	sp,sp,-80
    80003a3c:	e486                	sd	ra,72(sp)
    80003a3e:	e0a2                	sd	s0,64(sp)
    80003a40:	fc26                	sd	s1,56(sp)
    80003a42:	f84a                	sd	s2,48(sp)
    80003a44:	f44e                	sd	s3,40(sp)
    80003a46:	f052                	sd	s4,32(sp)
    80003a48:	ec56                	sd	s5,24(sp)
    80003a4a:	e85a                	sd	s6,16(sp)
    80003a4c:	e45e                	sd	s7,8(sp)
    80003a4e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a50:	0001b717          	auipc	a4,0x1b
    80003a54:	79472703          	lw	a4,1940(a4) # 8001f1e4 <sb+0xc>
    80003a58:	4785                	li	a5,1
    80003a5a:	04e7fa63          	bgeu	a5,a4,80003aae <ialloc+0x74>
    80003a5e:	8aaa                	mv	s5,a0
    80003a60:	8bae                	mv	s7,a1
    80003a62:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a64:	0001ba17          	auipc	s4,0x1b
    80003a68:	774a0a13          	addi	s4,s4,1908 # 8001f1d8 <sb>
    80003a6c:	00048b1b          	sext.w	s6,s1
    80003a70:	0044d593          	srli	a1,s1,0x4
    80003a74:	018a2783          	lw	a5,24(s4)
    80003a78:	9dbd                	addw	a1,a1,a5
    80003a7a:	8556                	mv	a0,s5
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	944080e7          	jalr	-1724(ra) # 800033c0 <bread>
    80003a84:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a86:	05850993          	addi	s3,a0,88
    80003a8a:	00f4f793          	andi	a5,s1,15
    80003a8e:	079a                	slli	a5,a5,0x6
    80003a90:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a92:	00099783          	lh	a5,0(s3)
    80003a96:	c3a1                	beqz	a5,80003ad6 <ialloc+0x9c>
    brelse(bp);
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	a58080e7          	jalr	-1448(ra) # 800034f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aa0:	0485                	addi	s1,s1,1
    80003aa2:	00ca2703          	lw	a4,12(s4)
    80003aa6:	0004879b          	sext.w	a5,s1
    80003aaa:	fce7e1e3          	bltu	a5,a4,80003a6c <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003aae:	00005517          	auipc	a0,0x5
    80003ab2:	c4250513          	addi	a0,a0,-958 # 800086f0 <syscalls+0x190>
    80003ab6:	ffffd097          	auipc	ra,0xffffd
    80003aba:	ae6080e7          	jalr	-1306(ra) # 8000059c <printf>
  return 0;
    80003abe:	4501                	li	a0,0
}
    80003ac0:	60a6                	ld	ra,72(sp)
    80003ac2:	6406                	ld	s0,64(sp)
    80003ac4:	74e2                	ld	s1,56(sp)
    80003ac6:	7942                	ld	s2,48(sp)
    80003ac8:	79a2                	ld	s3,40(sp)
    80003aca:	7a02                	ld	s4,32(sp)
    80003acc:	6ae2                	ld	s5,24(sp)
    80003ace:	6b42                	ld	s6,16(sp)
    80003ad0:	6ba2                	ld	s7,8(sp)
    80003ad2:	6161                	addi	sp,sp,80
    80003ad4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ad6:	04000613          	li	a2,64
    80003ada:	4581                	li	a1,0
    80003adc:	854e                	mv	a0,s3
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	2bc080e7          	jalr	700(ra) # 80000d9a <memset>
      dip->type = type;
    80003ae6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003aea:	854a                	mv	a0,s2
    80003aec:	00001097          	auipc	ra,0x1
    80003af0:	c8e080e7          	jalr	-882(ra) # 8000477a <log_write>
      brelse(bp);
    80003af4:	854a                	mv	a0,s2
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	9fa080e7          	jalr	-1542(ra) # 800034f0 <brelse>
      return iget(dev, inum);
    80003afe:	85da                	mv	a1,s6
    80003b00:	8556                	mv	a0,s5
    80003b02:	00000097          	auipc	ra,0x0
    80003b06:	d9c080e7          	jalr	-612(ra) # 8000389e <iget>
    80003b0a:	bf5d                	j	80003ac0 <ialloc+0x86>

0000000080003b0c <iupdate>:
{
    80003b0c:	1101                	addi	sp,sp,-32
    80003b0e:	ec06                	sd	ra,24(sp)
    80003b10:	e822                	sd	s0,16(sp)
    80003b12:	e426                	sd	s1,8(sp)
    80003b14:	e04a                	sd	s2,0(sp)
    80003b16:	1000                	addi	s0,sp,32
    80003b18:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b1a:	415c                	lw	a5,4(a0)
    80003b1c:	0047d79b          	srliw	a5,a5,0x4
    80003b20:	0001b597          	auipc	a1,0x1b
    80003b24:	6d05a583          	lw	a1,1744(a1) # 8001f1f0 <sb+0x18>
    80003b28:	9dbd                	addw	a1,a1,a5
    80003b2a:	4108                	lw	a0,0(a0)
    80003b2c:	00000097          	auipc	ra,0x0
    80003b30:	894080e7          	jalr	-1900(ra) # 800033c0 <bread>
    80003b34:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b36:	05850793          	addi	a5,a0,88
    80003b3a:	40d8                	lw	a4,4(s1)
    80003b3c:	8b3d                	andi	a4,a4,15
    80003b3e:	071a                	slli	a4,a4,0x6
    80003b40:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b42:	04449703          	lh	a4,68(s1)
    80003b46:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b4a:	04649703          	lh	a4,70(s1)
    80003b4e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b52:	04849703          	lh	a4,72(s1)
    80003b56:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b5a:	04a49703          	lh	a4,74(s1)
    80003b5e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b62:	44f8                	lw	a4,76(s1)
    80003b64:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b66:	03400613          	li	a2,52
    80003b6a:	05048593          	addi	a1,s1,80
    80003b6e:	00c78513          	addi	a0,a5,12
    80003b72:	ffffd097          	auipc	ra,0xffffd
    80003b76:	284080e7          	jalr	644(ra) # 80000df6 <memmove>
  log_write(bp);
    80003b7a:	854a                	mv	a0,s2
    80003b7c:	00001097          	auipc	ra,0x1
    80003b80:	bfe080e7          	jalr	-1026(ra) # 8000477a <log_write>
  brelse(bp);
    80003b84:	854a                	mv	a0,s2
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	96a080e7          	jalr	-1686(ra) # 800034f0 <brelse>
}
    80003b8e:	60e2                	ld	ra,24(sp)
    80003b90:	6442                	ld	s0,16(sp)
    80003b92:	64a2                	ld	s1,8(sp)
    80003b94:	6902                	ld	s2,0(sp)
    80003b96:	6105                	addi	sp,sp,32
    80003b98:	8082                	ret

0000000080003b9a <idup>:
{
    80003b9a:	1101                	addi	sp,sp,-32
    80003b9c:	ec06                	sd	ra,24(sp)
    80003b9e:	e822                	sd	s0,16(sp)
    80003ba0:	e426                	sd	s1,8(sp)
    80003ba2:	1000                	addi	s0,sp,32
    80003ba4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ba6:	0001b517          	auipc	a0,0x1b
    80003baa:	65250513          	addi	a0,a0,1618 # 8001f1f8 <itable>
    80003bae:	ffffd097          	auipc	ra,0xffffd
    80003bb2:	0f0080e7          	jalr	240(ra) # 80000c9e <acquire>
  ip->ref++;
    80003bb6:	449c                	lw	a5,8(s1)
    80003bb8:	2785                	addiw	a5,a5,1
    80003bba:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bbc:	0001b517          	auipc	a0,0x1b
    80003bc0:	63c50513          	addi	a0,a0,1596 # 8001f1f8 <itable>
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	18e080e7          	jalr	398(ra) # 80000d52 <release>
}
    80003bcc:	8526                	mv	a0,s1
    80003bce:	60e2                	ld	ra,24(sp)
    80003bd0:	6442                	ld	s0,16(sp)
    80003bd2:	64a2                	ld	s1,8(sp)
    80003bd4:	6105                	addi	sp,sp,32
    80003bd6:	8082                	ret

0000000080003bd8 <ilock>:
{
    80003bd8:	1101                	addi	sp,sp,-32
    80003bda:	ec06                	sd	ra,24(sp)
    80003bdc:	e822                	sd	s0,16(sp)
    80003bde:	e426                	sd	s1,8(sp)
    80003be0:	e04a                	sd	s2,0(sp)
    80003be2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003be4:	c115                	beqz	a0,80003c08 <ilock+0x30>
    80003be6:	84aa                	mv	s1,a0
    80003be8:	451c                	lw	a5,8(a0)
    80003bea:	00f05f63          	blez	a5,80003c08 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bee:	0541                	addi	a0,a0,16
    80003bf0:	00001097          	auipc	ra,0x1
    80003bf4:	ca8080e7          	jalr	-856(ra) # 80004898 <acquiresleep>
  if(ip->valid == 0){
    80003bf8:	40bc                	lw	a5,64(s1)
    80003bfa:	cf99                	beqz	a5,80003c18 <ilock+0x40>
}
    80003bfc:	60e2                	ld	ra,24(sp)
    80003bfe:	6442                	ld	s0,16(sp)
    80003c00:	64a2                	ld	s1,8(sp)
    80003c02:	6902                	ld	s2,0(sp)
    80003c04:	6105                	addi	sp,sp,32
    80003c06:	8082                	ret
    panic("ilock");
    80003c08:	00005517          	auipc	a0,0x5
    80003c0c:	b0050513          	addi	a0,a0,-1280 # 80008708 <syscalls+0x1a8>
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	930080e7          	jalr	-1744(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c18:	40dc                	lw	a5,4(s1)
    80003c1a:	0047d79b          	srliw	a5,a5,0x4
    80003c1e:	0001b597          	auipc	a1,0x1b
    80003c22:	5d25a583          	lw	a1,1490(a1) # 8001f1f0 <sb+0x18>
    80003c26:	9dbd                	addw	a1,a1,a5
    80003c28:	4088                	lw	a0,0(s1)
    80003c2a:	fffff097          	auipc	ra,0xfffff
    80003c2e:	796080e7          	jalr	1942(ra) # 800033c0 <bread>
    80003c32:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c34:	05850593          	addi	a1,a0,88
    80003c38:	40dc                	lw	a5,4(s1)
    80003c3a:	8bbd                	andi	a5,a5,15
    80003c3c:	079a                	slli	a5,a5,0x6
    80003c3e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c40:	00059783          	lh	a5,0(a1)
    80003c44:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c48:	00259783          	lh	a5,2(a1)
    80003c4c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c50:	00459783          	lh	a5,4(a1)
    80003c54:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c58:	00659783          	lh	a5,6(a1)
    80003c5c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c60:	459c                	lw	a5,8(a1)
    80003c62:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c64:	03400613          	li	a2,52
    80003c68:	05b1                	addi	a1,a1,12
    80003c6a:	05048513          	addi	a0,s1,80
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	188080e7          	jalr	392(ra) # 80000df6 <memmove>
    brelse(bp);
    80003c76:	854a                	mv	a0,s2
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	878080e7          	jalr	-1928(ra) # 800034f0 <brelse>
    ip->valid = 1;
    80003c80:	4785                	li	a5,1
    80003c82:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c84:	04449783          	lh	a5,68(s1)
    80003c88:	fbb5                	bnez	a5,80003bfc <ilock+0x24>
      panic("ilock: no type");
    80003c8a:	00005517          	auipc	a0,0x5
    80003c8e:	a8650513          	addi	a0,a0,-1402 # 80008710 <syscalls+0x1b0>
    80003c92:	ffffd097          	auipc	ra,0xffffd
    80003c96:	8ae080e7          	jalr	-1874(ra) # 80000540 <panic>

0000000080003c9a <iunlock>:
{
    80003c9a:	1101                	addi	sp,sp,-32
    80003c9c:	ec06                	sd	ra,24(sp)
    80003c9e:	e822                	sd	s0,16(sp)
    80003ca0:	e426                	sd	s1,8(sp)
    80003ca2:	e04a                	sd	s2,0(sp)
    80003ca4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ca6:	c905                	beqz	a0,80003cd6 <iunlock+0x3c>
    80003ca8:	84aa                	mv	s1,a0
    80003caa:	01050913          	addi	s2,a0,16
    80003cae:	854a                	mv	a0,s2
    80003cb0:	00001097          	auipc	ra,0x1
    80003cb4:	c82080e7          	jalr	-894(ra) # 80004932 <holdingsleep>
    80003cb8:	cd19                	beqz	a0,80003cd6 <iunlock+0x3c>
    80003cba:	449c                	lw	a5,8(s1)
    80003cbc:	00f05d63          	blez	a5,80003cd6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	00001097          	auipc	ra,0x1
    80003cc6:	c2c080e7          	jalr	-980(ra) # 800048ee <releasesleep>
}
    80003cca:	60e2                	ld	ra,24(sp)
    80003ccc:	6442                	ld	s0,16(sp)
    80003cce:	64a2                	ld	s1,8(sp)
    80003cd0:	6902                	ld	s2,0(sp)
    80003cd2:	6105                	addi	sp,sp,32
    80003cd4:	8082                	ret
    panic("iunlock");
    80003cd6:	00005517          	auipc	a0,0x5
    80003cda:	a4a50513          	addi	a0,a0,-1462 # 80008720 <syscalls+0x1c0>
    80003cde:	ffffd097          	auipc	ra,0xffffd
    80003ce2:	862080e7          	jalr	-1950(ra) # 80000540 <panic>

0000000080003ce6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ce6:	7179                	addi	sp,sp,-48
    80003ce8:	f406                	sd	ra,40(sp)
    80003cea:	f022                	sd	s0,32(sp)
    80003cec:	ec26                	sd	s1,24(sp)
    80003cee:	e84a                	sd	s2,16(sp)
    80003cf0:	e44e                	sd	s3,8(sp)
    80003cf2:	e052                	sd	s4,0(sp)
    80003cf4:	1800                	addi	s0,sp,48
    80003cf6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cf8:	05050493          	addi	s1,a0,80
    80003cfc:	08050913          	addi	s2,a0,128
    80003d00:	a021                	j	80003d08 <itrunc+0x22>
    80003d02:	0491                	addi	s1,s1,4
    80003d04:	01248d63          	beq	s1,s2,80003d1e <itrunc+0x38>
    if(ip->addrs[i]){
    80003d08:	408c                	lw	a1,0(s1)
    80003d0a:	dde5                	beqz	a1,80003d02 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d0c:	0009a503          	lw	a0,0(s3)
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	8f6080e7          	jalr	-1802(ra) # 80003606 <bfree>
      ip->addrs[i] = 0;
    80003d18:	0004a023          	sw	zero,0(s1)
    80003d1c:	b7dd                	j	80003d02 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d1e:	0809a583          	lw	a1,128(s3)
    80003d22:	e185                	bnez	a1,80003d42 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d24:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d28:	854e                	mv	a0,s3
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	de2080e7          	jalr	-542(ra) # 80003b0c <iupdate>
}
    80003d32:	70a2                	ld	ra,40(sp)
    80003d34:	7402                	ld	s0,32(sp)
    80003d36:	64e2                	ld	s1,24(sp)
    80003d38:	6942                	ld	s2,16(sp)
    80003d3a:	69a2                	ld	s3,8(sp)
    80003d3c:	6a02                	ld	s4,0(sp)
    80003d3e:	6145                	addi	sp,sp,48
    80003d40:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d42:	0009a503          	lw	a0,0(s3)
    80003d46:	fffff097          	auipc	ra,0xfffff
    80003d4a:	67a080e7          	jalr	1658(ra) # 800033c0 <bread>
    80003d4e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d50:	05850493          	addi	s1,a0,88
    80003d54:	45850913          	addi	s2,a0,1112
    80003d58:	a021                	j	80003d60 <itrunc+0x7a>
    80003d5a:	0491                	addi	s1,s1,4
    80003d5c:	01248b63          	beq	s1,s2,80003d72 <itrunc+0x8c>
      if(a[j])
    80003d60:	408c                	lw	a1,0(s1)
    80003d62:	dde5                	beqz	a1,80003d5a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d64:	0009a503          	lw	a0,0(s3)
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	89e080e7          	jalr	-1890(ra) # 80003606 <bfree>
    80003d70:	b7ed                	j	80003d5a <itrunc+0x74>
    brelse(bp);
    80003d72:	8552                	mv	a0,s4
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	77c080e7          	jalr	1916(ra) # 800034f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d7c:	0809a583          	lw	a1,128(s3)
    80003d80:	0009a503          	lw	a0,0(s3)
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	882080e7          	jalr	-1918(ra) # 80003606 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d8c:	0809a023          	sw	zero,128(s3)
    80003d90:	bf51                	j	80003d24 <itrunc+0x3e>

0000000080003d92 <iput>:
{
    80003d92:	1101                	addi	sp,sp,-32
    80003d94:	ec06                	sd	ra,24(sp)
    80003d96:	e822                	sd	s0,16(sp)
    80003d98:	e426                	sd	s1,8(sp)
    80003d9a:	e04a                	sd	s2,0(sp)
    80003d9c:	1000                	addi	s0,sp,32
    80003d9e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003da0:	0001b517          	auipc	a0,0x1b
    80003da4:	45850513          	addi	a0,a0,1112 # 8001f1f8 <itable>
    80003da8:	ffffd097          	auipc	ra,0xffffd
    80003dac:	ef6080e7          	jalr	-266(ra) # 80000c9e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003db0:	4498                	lw	a4,8(s1)
    80003db2:	4785                	li	a5,1
    80003db4:	02f70363          	beq	a4,a5,80003dda <iput+0x48>
  ip->ref--;
    80003db8:	449c                	lw	a5,8(s1)
    80003dba:	37fd                	addiw	a5,a5,-1
    80003dbc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dbe:	0001b517          	auipc	a0,0x1b
    80003dc2:	43a50513          	addi	a0,a0,1082 # 8001f1f8 <itable>
    80003dc6:	ffffd097          	auipc	ra,0xffffd
    80003dca:	f8c080e7          	jalr	-116(ra) # 80000d52 <release>
}
    80003dce:	60e2                	ld	ra,24(sp)
    80003dd0:	6442                	ld	s0,16(sp)
    80003dd2:	64a2                	ld	s1,8(sp)
    80003dd4:	6902                	ld	s2,0(sp)
    80003dd6:	6105                	addi	sp,sp,32
    80003dd8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dda:	40bc                	lw	a5,64(s1)
    80003ddc:	dff1                	beqz	a5,80003db8 <iput+0x26>
    80003dde:	04a49783          	lh	a5,74(s1)
    80003de2:	fbf9                	bnez	a5,80003db8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003de4:	01048913          	addi	s2,s1,16
    80003de8:	854a                	mv	a0,s2
    80003dea:	00001097          	auipc	ra,0x1
    80003dee:	aae080e7          	jalr	-1362(ra) # 80004898 <acquiresleep>
    release(&itable.lock);
    80003df2:	0001b517          	auipc	a0,0x1b
    80003df6:	40650513          	addi	a0,a0,1030 # 8001f1f8 <itable>
    80003dfa:	ffffd097          	auipc	ra,0xffffd
    80003dfe:	f58080e7          	jalr	-168(ra) # 80000d52 <release>
    itrunc(ip);
    80003e02:	8526                	mv	a0,s1
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	ee2080e7          	jalr	-286(ra) # 80003ce6 <itrunc>
    ip->type = 0;
    80003e0c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e10:	8526                	mv	a0,s1
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	cfa080e7          	jalr	-774(ra) # 80003b0c <iupdate>
    ip->valid = 0;
    80003e1a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e1e:	854a                	mv	a0,s2
    80003e20:	00001097          	auipc	ra,0x1
    80003e24:	ace080e7          	jalr	-1330(ra) # 800048ee <releasesleep>
    acquire(&itable.lock);
    80003e28:	0001b517          	auipc	a0,0x1b
    80003e2c:	3d050513          	addi	a0,a0,976 # 8001f1f8 <itable>
    80003e30:	ffffd097          	auipc	ra,0xffffd
    80003e34:	e6e080e7          	jalr	-402(ra) # 80000c9e <acquire>
    80003e38:	b741                	j	80003db8 <iput+0x26>

0000000080003e3a <iunlockput>:
{
    80003e3a:	1101                	addi	sp,sp,-32
    80003e3c:	ec06                	sd	ra,24(sp)
    80003e3e:	e822                	sd	s0,16(sp)
    80003e40:	e426                	sd	s1,8(sp)
    80003e42:	1000                	addi	s0,sp,32
    80003e44:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e46:	00000097          	auipc	ra,0x0
    80003e4a:	e54080e7          	jalr	-428(ra) # 80003c9a <iunlock>
  iput(ip);
    80003e4e:	8526                	mv	a0,s1
    80003e50:	00000097          	auipc	ra,0x0
    80003e54:	f42080e7          	jalr	-190(ra) # 80003d92 <iput>
}
    80003e58:	60e2                	ld	ra,24(sp)
    80003e5a:	6442                	ld	s0,16(sp)
    80003e5c:	64a2                	ld	s1,8(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret

0000000080003e62 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e62:	1141                	addi	sp,sp,-16
    80003e64:	e422                	sd	s0,8(sp)
    80003e66:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e68:	411c                	lw	a5,0(a0)
    80003e6a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e6c:	415c                	lw	a5,4(a0)
    80003e6e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e70:	04451783          	lh	a5,68(a0)
    80003e74:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e78:	04a51783          	lh	a5,74(a0)
    80003e7c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e80:	04c56783          	lwu	a5,76(a0)
    80003e84:	e99c                	sd	a5,16(a1)
}
    80003e86:	6422                	ld	s0,8(sp)
    80003e88:	0141                	addi	sp,sp,16
    80003e8a:	8082                	ret

0000000080003e8c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e8c:	457c                	lw	a5,76(a0)
    80003e8e:	0ed7e963          	bltu	a5,a3,80003f80 <readi+0xf4>
{
    80003e92:	7159                	addi	sp,sp,-112
    80003e94:	f486                	sd	ra,104(sp)
    80003e96:	f0a2                	sd	s0,96(sp)
    80003e98:	eca6                	sd	s1,88(sp)
    80003e9a:	e8ca                	sd	s2,80(sp)
    80003e9c:	e4ce                	sd	s3,72(sp)
    80003e9e:	e0d2                	sd	s4,64(sp)
    80003ea0:	fc56                	sd	s5,56(sp)
    80003ea2:	f85a                	sd	s6,48(sp)
    80003ea4:	f45e                	sd	s7,40(sp)
    80003ea6:	f062                	sd	s8,32(sp)
    80003ea8:	ec66                	sd	s9,24(sp)
    80003eaa:	e86a                	sd	s10,16(sp)
    80003eac:	e46e                	sd	s11,8(sp)
    80003eae:	1880                	addi	s0,sp,112
    80003eb0:	8b2a                	mv	s6,a0
    80003eb2:	8bae                	mv	s7,a1
    80003eb4:	8a32                	mv	s4,a2
    80003eb6:	84b6                	mv	s1,a3
    80003eb8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003eba:	9f35                	addw	a4,a4,a3
    return 0;
    80003ebc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ebe:	0ad76063          	bltu	a4,a3,80003f5e <readi+0xd2>
  if(off + n > ip->size)
    80003ec2:	00e7f463          	bgeu	a5,a4,80003eca <readi+0x3e>
    n = ip->size - off;
    80003ec6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eca:	0a0a8963          	beqz	s5,80003f7c <readi+0xf0>
    80003ece:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ed0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ed4:	5c7d                	li	s8,-1
    80003ed6:	a82d                	j	80003f10 <readi+0x84>
    80003ed8:	020d1d93          	slli	s11,s10,0x20
    80003edc:	020ddd93          	srli	s11,s11,0x20
    80003ee0:	05890613          	addi	a2,s2,88
    80003ee4:	86ee                	mv	a3,s11
    80003ee6:	963a                	add	a2,a2,a4
    80003ee8:	85d2                	mv	a1,s4
    80003eea:	855e                	mv	a0,s7
    80003eec:	fffff097          	auipc	ra,0xfffff
    80003ef0:	898080e7          	jalr	-1896(ra) # 80002784 <either_copyout>
    80003ef4:	05850d63          	beq	a0,s8,80003f4e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ef8:	854a                	mv	a0,s2
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	5f6080e7          	jalr	1526(ra) # 800034f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f02:	013d09bb          	addw	s3,s10,s3
    80003f06:	009d04bb          	addw	s1,s10,s1
    80003f0a:	9a6e                	add	s4,s4,s11
    80003f0c:	0559f763          	bgeu	s3,s5,80003f5a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f10:	00a4d59b          	srliw	a1,s1,0xa
    80003f14:	855a                	mv	a0,s6
    80003f16:	00000097          	auipc	ra,0x0
    80003f1a:	89e080e7          	jalr	-1890(ra) # 800037b4 <bmap>
    80003f1e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f22:	cd85                	beqz	a1,80003f5a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f24:	000b2503          	lw	a0,0(s6)
    80003f28:	fffff097          	auipc	ra,0xfffff
    80003f2c:	498080e7          	jalr	1176(ra) # 800033c0 <bread>
    80003f30:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f32:	3ff4f713          	andi	a4,s1,1023
    80003f36:	40ec87bb          	subw	a5,s9,a4
    80003f3a:	413a86bb          	subw	a3,s5,s3
    80003f3e:	8d3e                	mv	s10,a5
    80003f40:	2781                	sext.w	a5,a5
    80003f42:	0006861b          	sext.w	a2,a3
    80003f46:	f8f679e3          	bgeu	a2,a5,80003ed8 <readi+0x4c>
    80003f4a:	8d36                	mv	s10,a3
    80003f4c:	b771                	j	80003ed8 <readi+0x4c>
      brelse(bp);
    80003f4e:	854a                	mv	a0,s2
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	5a0080e7          	jalr	1440(ra) # 800034f0 <brelse>
      tot = -1;
    80003f58:	59fd                	li	s3,-1
  }
  return tot;
    80003f5a:	0009851b          	sext.w	a0,s3
}
    80003f5e:	70a6                	ld	ra,104(sp)
    80003f60:	7406                	ld	s0,96(sp)
    80003f62:	64e6                	ld	s1,88(sp)
    80003f64:	6946                	ld	s2,80(sp)
    80003f66:	69a6                	ld	s3,72(sp)
    80003f68:	6a06                	ld	s4,64(sp)
    80003f6a:	7ae2                	ld	s5,56(sp)
    80003f6c:	7b42                	ld	s6,48(sp)
    80003f6e:	7ba2                	ld	s7,40(sp)
    80003f70:	7c02                	ld	s8,32(sp)
    80003f72:	6ce2                	ld	s9,24(sp)
    80003f74:	6d42                	ld	s10,16(sp)
    80003f76:	6da2                	ld	s11,8(sp)
    80003f78:	6165                	addi	sp,sp,112
    80003f7a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f7c:	89d6                	mv	s3,s5
    80003f7e:	bff1                	j	80003f5a <readi+0xce>
    return 0;
    80003f80:	4501                	li	a0,0
}
    80003f82:	8082                	ret

0000000080003f84 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f84:	457c                	lw	a5,76(a0)
    80003f86:	10d7e863          	bltu	a5,a3,80004096 <writei+0x112>
{
    80003f8a:	7159                	addi	sp,sp,-112
    80003f8c:	f486                	sd	ra,104(sp)
    80003f8e:	f0a2                	sd	s0,96(sp)
    80003f90:	eca6                	sd	s1,88(sp)
    80003f92:	e8ca                	sd	s2,80(sp)
    80003f94:	e4ce                	sd	s3,72(sp)
    80003f96:	e0d2                	sd	s4,64(sp)
    80003f98:	fc56                	sd	s5,56(sp)
    80003f9a:	f85a                	sd	s6,48(sp)
    80003f9c:	f45e                	sd	s7,40(sp)
    80003f9e:	f062                	sd	s8,32(sp)
    80003fa0:	ec66                	sd	s9,24(sp)
    80003fa2:	e86a                	sd	s10,16(sp)
    80003fa4:	e46e                	sd	s11,8(sp)
    80003fa6:	1880                	addi	s0,sp,112
    80003fa8:	8aaa                	mv	s5,a0
    80003faa:	8bae                	mv	s7,a1
    80003fac:	8a32                	mv	s4,a2
    80003fae:	8936                	mv	s2,a3
    80003fb0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fb2:	00e687bb          	addw	a5,a3,a4
    80003fb6:	0ed7e263          	bltu	a5,a3,8000409a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fba:	00043737          	lui	a4,0x43
    80003fbe:	0ef76063          	bltu	a4,a5,8000409e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fc2:	0c0b0863          	beqz	s6,80004092 <writei+0x10e>
    80003fc6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fc8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fcc:	5c7d                	li	s8,-1
    80003fce:	a091                	j	80004012 <writei+0x8e>
    80003fd0:	020d1d93          	slli	s11,s10,0x20
    80003fd4:	020ddd93          	srli	s11,s11,0x20
    80003fd8:	05848513          	addi	a0,s1,88
    80003fdc:	86ee                	mv	a3,s11
    80003fde:	8652                	mv	a2,s4
    80003fe0:	85de                	mv	a1,s7
    80003fe2:	953a                	add	a0,a0,a4
    80003fe4:	ffffe097          	auipc	ra,0xffffe
    80003fe8:	7f6080e7          	jalr	2038(ra) # 800027da <either_copyin>
    80003fec:	07850263          	beq	a0,s8,80004050 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ff0:	8526                	mv	a0,s1
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	788080e7          	jalr	1928(ra) # 8000477a <log_write>
    brelse(bp);
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	4f4080e7          	jalr	1268(ra) # 800034f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004004:	013d09bb          	addw	s3,s10,s3
    80004008:	012d093b          	addw	s2,s10,s2
    8000400c:	9a6e                	add	s4,s4,s11
    8000400e:	0569f663          	bgeu	s3,s6,8000405a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004012:	00a9559b          	srliw	a1,s2,0xa
    80004016:	8556                	mv	a0,s5
    80004018:	fffff097          	auipc	ra,0xfffff
    8000401c:	79c080e7          	jalr	1948(ra) # 800037b4 <bmap>
    80004020:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004024:	c99d                	beqz	a1,8000405a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004026:	000aa503          	lw	a0,0(s5)
    8000402a:	fffff097          	auipc	ra,0xfffff
    8000402e:	396080e7          	jalr	918(ra) # 800033c0 <bread>
    80004032:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004034:	3ff97713          	andi	a4,s2,1023
    80004038:	40ec87bb          	subw	a5,s9,a4
    8000403c:	413b06bb          	subw	a3,s6,s3
    80004040:	8d3e                	mv	s10,a5
    80004042:	2781                	sext.w	a5,a5
    80004044:	0006861b          	sext.w	a2,a3
    80004048:	f8f674e3          	bgeu	a2,a5,80003fd0 <writei+0x4c>
    8000404c:	8d36                	mv	s10,a3
    8000404e:	b749                	j	80003fd0 <writei+0x4c>
      brelse(bp);
    80004050:	8526                	mv	a0,s1
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	49e080e7          	jalr	1182(ra) # 800034f0 <brelse>
  }

  if(off > ip->size)
    8000405a:	04caa783          	lw	a5,76(s5)
    8000405e:	0127f463          	bgeu	a5,s2,80004066 <writei+0xe2>
    ip->size = off;
    80004062:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004066:	8556                	mv	a0,s5
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	aa4080e7          	jalr	-1372(ra) # 80003b0c <iupdate>

  return tot;
    80004070:	0009851b          	sext.w	a0,s3
}
    80004074:	70a6                	ld	ra,104(sp)
    80004076:	7406                	ld	s0,96(sp)
    80004078:	64e6                	ld	s1,88(sp)
    8000407a:	6946                	ld	s2,80(sp)
    8000407c:	69a6                	ld	s3,72(sp)
    8000407e:	6a06                	ld	s4,64(sp)
    80004080:	7ae2                	ld	s5,56(sp)
    80004082:	7b42                	ld	s6,48(sp)
    80004084:	7ba2                	ld	s7,40(sp)
    80004086:	7c02                	ld	s8,32(sp)
    80004088:	6ce2                	ld	s9,24(sp)
    8000408a:	6d42                	ld	s10,16(sp)
    8000408c:	6da2                	ld	s11,8(sp)
    8000408e:	6165                	addi	sp,sp,112
    80004090:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004092:	89da                	mv	s3,s6
    80004094:	bfc9                	j	80004066 <writei+0xe2>
    return -1;
    80004096:	557d                	li	a0,-1
}
    80004098:	8082                	ret
    return -1;
    8000409a:	557d                	li	a0,-1
    8000409c:	bfe1                	j	80004074 <writei+0xf0>
    return -1;
    8000409e:	557d                	li	a0,-1
    800040a0:	bfd1                	j	80004074 <writei+0xf0>

00000000800040a2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040a2:	1141                	addi	sp,sp,-16
    800040a4:	e406                	sd	ra,8(sp)
    800040a6:	e022                	sd	s0,0(sp)
    800040a8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040aa:	4639                	li	a2,14
    800040ac:	ffffd097          	auipc	ra,0xffffd
    800040b0:	dbe080e7          	jalr	-578(ra) # 80000e6a <strncmp>
}
    800040b4:	60a2                	ld	ra,8(sp)
    800040b6:	6402                	ld	s0,0(sp)
    800040b8:	0141                	addi	sp,sp,16
    800040ba:	8082                	ret

00000000800040bc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040bc:	7139                	addi	sp,sp,-64
    800040be:	fc06                	sd	ra,56(sp)
    800040c0:	f822                	sd	s0,48(sp)
    800040c2:	f426                	sd	s1,40(sp)
    800040c4:	f04a                	sd	s2,32(sp)
    800040c6:	ec4e                	sd	s3,24(sp)
    800040c8:	e852                	sd	s4,16(sp)
    800040ca:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040cc:	04451703          	lh	a4,68(a0)
    800040d0:	4785                	li	a5,1
    800040d2:	00f71a63          	bne	a4,a5,800040e6 <dirlookup+0x2a>
    800040d6:	892a                	mv	s2,a0
    800040d8:	89ae                	mv	s3,a1
    800040da:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040dc:	457c                	lw	a5,76(a0)
    800040de:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040e0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e2:	e79d                	bnez	a5,80004110 <dirlookup+0x54>
    800040e4:	a8a5                	j	8000415c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040e6:	00004517          	auipc	a0,0x4
    800040ea:	64250513          	addi	a0,a0,1602 # 80008728 <syscalls+0x1c8>
    800040ee:	ffffc097          	auipc	ra,0xffffc
    800040f2:	452080e7          	jalr	1106(ra) # 80000540 <panic>
      panic("dirlookup read");
    800040f6:	00004517          	auipc	a0,0x4
    800040fa:	64a50513          	addi	a0,a0,1610 # 80008740 <syscalls+0x1e0>
    800040fe:	ffffc097          	auipc	ra,0xffffc
    80004102:	442080e7          	jalr	1090(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004106:	24c1                	addiw	s1,s1,16
    80004108:	04c92783          	lw	a5,76(s2)
    8000410c:	04f4f763          	bgeu	s1,a5,8000415a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004110:	4741                	li	a4,16
    80004112:	86a6                	mv	a3,s1
    80004114:	fc040613          	addi	a2,s0,-64
    80004118:	4581                	li	a1,0
    8000411a:	854a                	mv	a0,s2
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	d70080e7          	jalr	-656(ra) # 80003e8c <readi>
    80004124:	47c1                	li	a5,16
    80004126:	fcf518e3          	bne	a0,a5,800040f6 <dirlookup+0x3a>
    if(de.inum == 0)
    8000412a:	fc045783          	lhu	a5,-64(s0)
    8000412e:	dfe1                	beqz	a5,80004106 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004130:	fc240593          	addi	a1,s0,-62
    80004134:	854e                	mv	a0,s3
    80004136:	00000097          	auipc	ra,0x0
    8000413a:	f6c080e7          	jalr	-148(ra) # 800040a2 <namecmp>
    8000413e:	f561                	bnez	a0,80004106 <dirlookup+0x4a>
      if(poff)
    80004140:	000a0463          	beqz	s4,80004148 <dirlookup+0x8c>
        *poff = off;
    80004144:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004148:	fc045583          	lhu	a1,-64(s0)
    8000414c:	00092503          	lw	a0,0(s2)
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	74e080e7          	jalr	1870(ra) # 8000389e <iget>
    80004158:	a011                	j	8000415c <dirlookup+0xa0>
  return 0;
    8000415a:	4501                	li	a0,0
}
    8000415c:	70e2                	ld	ra,56(sp)
    8000415e:	7442                	ld	s0,48(sp)
    80004160:	74a2                	ld	s1,40(sp)
    80004162:	7902                	ld	s2,32(sp)
    80004164:	69e2                	ld	s3,24(sp)
    80004166:	6a42                	ld	s4,16(sp)
    80004168:	6121                	addi	sp,sp,64
    8000416a:	8082                	ret

000000008000416c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000416c:	711d                	addi	sp,sp,-96
    8000416e:	ec86                	sd	ra,88(sp)
    80004170:	e8a2                	sd	s0,80(sp)
    80004172:	e4a6                	sd	s1,72(sp)
    80004174:	e0ca                	sd	s2,64(sp)
    80004176:	fc4e                	sd	s3,56(sp)
    80004178:	f852                	sd	s4,48(sp)
    8000417a:	f456                	sd	s5,40(sp)
    8000417c:	f05a                	sd	s6,32(sp)
    8000417e:	ec5e                	sd	s7,24(sp)
    80004180:	e862                	sd	s8,16(sp)
    80004182:	e466                	sd	s9,8(sp)
    80004184:	e06a                	sd	s10,0(sp)
    80004186:	1080                	addi	s0,sp,96
    80004188:	84aa                	mv	s1,a0
    8000418a:	8b2e                	mv	s6,a1
    8000418c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000418e:	00054703          	lbu	a4,0(a0)
    80004192:	02f00793          	li	a5,47
    80004196:	02f70363          	beq	a4,a5,800041bc <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000419a:	ffffe097          	auipc	ra,0xffffe
    8000419e:	a34080e7          	jalr	-1484(ra) # 80001bce <myproc>
    800041a2:	15053503          	ld	a0,336(a0)
    800041a6:	00000097          	auipc	ra,0x0
    800041aa:	9f4080e7          	jalr	-1548(ra) # 80003b9a <idup>
    800041ae:	8a2a                	mv	s4,a0
  while(*path == '/')
    800041b0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800041b4:	4cb5                	li	s9,13
  len = path - s;
    800041b6:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041b8:	4c05                	li	s8,1
    800041ba:	a87d                	j	80004278 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800041bc:	4585                	li	a1,1
    800041be:	4505                	li	a0,1
    800041c0:	fffff097          	auipc	ra,0xfffff
    800041c4:	6de080e7          	jalr	1758(ra) # 8000389e <iget>
    800041c8:	8a2a                	mv	s4,a0
    800041ca:	b7dd                	j	800041b0 <namex+0x44>
      iunlockput(ip);
    800041cc:	8552                	mv	a0,s4
    800041ce:	00000097          	auipc	ra,0x0
    800041d2:	c6c080e7          	jalr	-916(ra) # 80003e3a <iunlockput>
      return 0;
    800041d6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041d8:	8552                	mv	a0,s4
    800041da:	60e6                	ld	ra,88(sp)
    800041dc:	6446                	ld	s0,80(sp)
    800041de:	64a6                	ld	s1,72(sp)
    800041e0:	6906                	ld	s2,64(sp)
    800041e2:	79e2                	ld	s3,56(sp)
    800041e4:	7a42                	ld	s4,48(sp)
    800041e6:	7aa2                	ld	s5,40(sp)
    800041e8:	7b02                	ld	s6,32(sp)
    800041ea:	6be2                	ld	s7,24(sp)
    800041ec:	6c42                	ld	s8,16(sp)
    800041ee:	6ca2                	ld	s9,8(sp)
    800041f0:	6d02                	ld	s10,0(sp)
    800041f2:	6125                	addi	sp,sp,96
    800041f4:	8082                	ret
      iunlock(ip);
    800041f6:	8552                	mv	a0,s4
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	aa2080e7          	jalr	-1374(ra) # 80003c9a <iunlock>
      return ip;
    80004200:	bfe1                	j	800041d8 <namex+0x6c>
      iunlockput(ip);
    80004202:	8552                	mv	a0,s4
    80004204:	00000097          	auipc	ra,0x0
    80004208:	c36080e7          	jalr	-970(ra) # 80003e3a <iunlockput>
      return 0;
    8000420c:	8a4e                	mv	s4,s3
    8000420e:	b7e9                	j	800041d8 <namex+0x6c>
  len = path - s;
    80004210:	40998633          	sub	a2,s3,s1
    80004214:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004218:	09acd863          	bge	s9,s10,800042a8 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000421c:	4639                	li	a2,14
    8000421e:	85a6                	mv	a1,s1
    80004220:	8556                	mv	a0,s5
    80004222:	ffffd097          	auipc	ra,0xffffd
    80004226:	bd4080e7          	jalr	-1068(ra) # 80000df6 <memmove>
    8000422a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000422c:	0004c783          	lbu	a5,0(s1)
    80004230:	01279763          	bne	a5,s2,8000423e <namex+0xd2>
    path++;
    80004234:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004236:	0004c783          	lbu	a5,0(s1)
    8000423a:	ff278de3          	beq	a5,s2,80004234 <namex+0xc8>
    ilock(ip);
    8000423e:	8552                	mv	a0,s4
    80004240:	00000097          	auipc	ra,0x0
    80004244:	998080e7          	jalr	-1640(ra) # 80003bd8 <ilock>
    if(ip->type != T_DIR){
    80004248:	044a1783          	lh	a5,68(s4)
    8000424c:	f98790e3          	bne	a5,s8,800041cc <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004250:	000b0563          	beqz	s6,8000425a <namex+0xee>
    80004254:	0004c783          	lbu	a5,0(s1)
    80004258:	dfd9                	beqz	a5,800041f6 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000425a:	865e                	mv	a2,s7
    8000425c:	85d6                	mv	a1,s5
    8000425e:	8552                	mv	a0,s4
    80004260:	00000097          	auipc	ra,0x0
    80004264:	e5c080e7          	jalr	-420(ra) # 800040bc <dirlookup>
    80004268:	89aa                	mv	s3,a0
    8000426a:	dd41                	beqz	a0,80004202 <namex+0x96>
    iunlockput(ip);
    8000426c:	8552                	mv	a0,s4
    8000426e:	00000097          	auipc	ra,0x0
    80004272:	bcc080e7          	jalr	-1076(ra) # 80003e3a <iunlockput>
    ip = next;
    80004276:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004278:	0004c783          	lbu	a5,0(s1)
    8000427c:	01279763          	bne	a5,s2,8000428a <namex+0x11e>
    path++;
    80004280:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004282:	0004c783          	lbu	a5,0(s1)
    80004286:	ff278de3          	beq	a5,s2,80004280 <namex+0x114>
  if(*path == 0)
    8000428a:	cb9d                	beqz	a5,800042c0 <namex+0x154>
  while(*path != '/' && *path != 0)
    8000428c:	0004c783          	lbu	a5,0(s1)
    80004290:	89a6                	mv	s3,s1
  len = path - s;
    80004292:	8d5e                	mv	s10,s7
    80004294:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004296:	01278963          	beq	a5,s2,800042a8 <namex+0x13c>
    8000429a:	dbbd                	beqz	a5,80004210 <namex+0xa4>
    path++;
    8000429c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000429e:	0009c783          	lbu	a5,0(s3)
    800042a2:	ff279ce3          	bne	a5,s2,8000429a <namex+0x12e>
    800042a6:	b7ad                	j	80004210 <namex+0xa4>
    memmove(name, s, len);
    800042a8:	2601                	sext.w	a2,a2
    800042aa:	85a6                	mv	a1,s1
    800042ac:	8556                	mv	a0,s5
    800042ae:	ffffd097          	auipc	ra,0xffffd
    800042b2:	b48080e7          	jalr	-1208(ra) # 80000df6 <memmove>
    name[len] = 0;
    800042b6:	9d56                	add	s10,s10,s5
    800042b8:	000d0023          	sb	zero,0(s10)
    800042bc:	84ce                	mv	s1,s3
    800042be:	b7bd                	j	8000422c <namex+0xc0>
  if(nameiparent){
    800042c0:	f00b0ce3          	beqz	s6,800041d8 <namex+0x6c>
    iput(ip);
    800042c4:	8552                	mv	a0,s4
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	acc080e7          	jalr	-1332(ra) # 80003d92 <iput>
    return 0;
    800042ce:	4a01                	li	s4,0
    800042d0:	b721                	j	800041d8 <namex+0x6c>

00000000800042d2 <dirlink>:
{
    800042d2:	7139                	addi	sp,sp,-64
    800042d4:	fc06                	sd	ra,56(sp)
    800042d6:	f822                	sd	s0,48(sp)
    800042d8:	f426                	sd	s1,40(sp)
    800042da:	f04a                	sd	s2,32(sp)
    800042dc:	ec4e                	sd	s3,24(sp)
    800042de:	e852                	sd	s4,16(sp)
    800042e0:	0080                	addi	s0,sp,64
    800042e2:	892a                	mv	s2,a0
    800042e4:	8a2e                	mv	s4,a1
    800042e6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042e8:	4601                	li	a2,0
    800042ea:	00000097          	auipc	ra,0x0
    800042ee:	dd2080e7          	jalr	-558(ra) # 800040bc <dirlookup>
    800042f2:	e93d                	bnez	a0,80004368 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f4:	04c92483          	lw	s1,76(s2)
    800042f8:	c49d                	beqz	s1,80004326 <dirlink+0x54>
    800042fa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042fc:	4741                	li	a4,16
    800042fe:	86a6                	mv	a3,s1
    80004300:	fc040613          	addi	a2,s0,-64
    80004304:	4581                	li	a1,0
    80004306:	854a                	mv	a0,s2
    80004308:	00000097          	auipc	ra,0x0
    8000430c:	b84080e7          	jalr	-1148(ra) # 80003e8c <readi>
    80004310:	47c1                	li	a5,16
    80004312:	06f51163          	bne	a0,a5,80004374 <dirlink+0xa2>
    if(de.inum == 0)
    80004316:	fc045783          	lhu	a5,-64(s0)
    8000431a:	c791                	beqz	a5,80004326 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000431c:	24c1                	addiw	s1,s1,16
    8000431e:	04c92783          	lw	a5,76(s2)
    80004322:	fcf4ede3          	bltu	s1,a5,800042fc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004326:	4639                	li	a2,14
    80004328:	85d2                	mv	a1,s4
    8000432a:	fc240513          	addi	a0,s0,-62
    8000432e:	ffffd097          	auipc	ra,0xffffd
    80004332:	b78080e7          	jalr	-1160(ra) # 80000ea6 <strncpy>
  de.inum = inum;
    80004336:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000433a:	4741                	li	a4,16
    8000433c:	86a6                	mv	a3,s1
    8000433e:	fc040613          	addi	a2,s0,-64
    80004342:	4581                	li	a1,0
    80004344:	854a                	mv	a0,s2
    80004346:	00000097          	auipc	ra,0x0
    8000434a:	c3e080e7          	jalr	-962(ra) # 80003f84 <writei>
    8000434e:	1541                	addi	a0,a0,-16
    80004350:	00a03533          	snez	a0,a0
    80004354:	40a00533          	neg	a0,a0
}
    80004358:	70e2                	ld	ra,56(sp)
    8000435a:	7442                	ld	s0,48(sp)
    8000435c:	74a2                	ld	s1,40(sp)
    8000435e:	7902                	ld	s2,32(sp)
    80004360:	69e2                	ld	s3,24(sp)
    80004362:	6a42                	ld	s4,16(sp)
    80004364:	6121                	addi	sp,sp,64
    80004366:	8082                	ret
    iput(ip);
    80004368:	00000097          	auipc	ra,0x0
    8000436c:	a2a080e7          	jalr	-1494(ra) # 80003d92 <iput>
    return -1;
    80004370:	557d                	li	a0,-1
    80004372:	b7dd                	j	80004358 <dirlink+0x86>
      panic("dirlink read");
    80004374:	00004517          	auipc	a0,0x4
    80004378:	3dc50513          	addi	a0,a0,988 # 80008750 <syscalls+0x1f0>
    8000437c:	ffffc097          	auipc	ra,0xffffc
    80004380:	1c4080e7          	jalr	452(ra) # 80000540 <panic>

0000000080004384 <namei>:

struct inode*
namei(char *path)
{
    80004384:	1101                	addi	sp,sp,-32
    80004386:	ec06                	sd	ra,24(sp)
    80004388:	e822                	sd	s0,16(sp)
    8000438a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000438c:	fe040613          	addi	a2,s0,-32
    80004390:	4581                	li	a1,0
    80004392:	00000097          	auipc	ra,0x0
    80004396:	dda080e7          	jalr	-550(ra) # 8000416c <namex>
}
    8000439a:	60e2                	ld	ra,24(sp)
    8000439c:	6442                	ld	s0,16(sp)
    8000439e:	6105                	addi	sp,sp,32
    800043a0:	8082                	ret

00000000800043a2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043a2:	1141                	addi	sp,sp,-16
    800043a4:	e406                	sd	ra,8(sp)
    800043a6:	e022                	sd	s0,0(sp)
    800043a8:	0800                	addi	s0,sp,16
    800043aa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043ac:	4585                	li	a1,1
    800043ae:	00000097          	auipc	ra,0x0
    800043b2:	dbe080e7          	jalr	-578(ra) # 8000416c <namex>
}
    800043b6:	60a2                	ld	ra,8(sp)
    800043b8:	6402                	ld	s0,0(sp)
    800043ba:	0141                	addi	sp,sp,16
    800043bc:	8082                	ret

00000000800043be <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043be:	1101                	addi	sp,sp,-32
    800043c0:	ec06                	sd	ra,24(sp)
    800043c2:	e822                	sd	s0,16(sp)
    800043c4:	e426                	sd	s1,8(sp)
    800043c6:	e04a                	sd	s2,0(sp)
    800043c8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043ca:	0001d917          	auipc	s2,0x1d
    800043ce:	8d690913          	addi	s2,s2,-1834 # 80020ca0 <log>
    800043d2:	01892583          	lw	a1,24(s2)
    800043d6:	02892503          	lw	a0,40(s2)
    800043da:	fffff097          	auipc	ra,0xfffff
    800043de:	fe6080e7          	jalr	-26(ra) # 800033c0 <bread>
    800043e2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043e4:	02c92683          	lw	a3,44(s2)
    800043e8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043ea:	02d05863          	blez	a3,8000441a <write_head+0x5c>
    800043ee:	0001d797          	auipc	a5,0x1d
    800043f2:	8e278793          	addi	a5,a5,-1822 # 80020cd0 <log+0x30>
    800043f6:	05c50713          	addi	a4,a0,92
    800043fa:	36fd                	addiw	a3,a3,-1
    800043fc:	02069613          	slli	a2,a3,0x20
    80004400:	01e65693          	srli	a3,a2,0x1e
    80004404:	0001d617          	auipc	a2,0x1d
    80004408:	8d060613          	addi	a2,a2,-1840 # 80020cd4 <log+0x34>
    8000440c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000440e:	4390                	lw	a2,0(a5)
    80004410:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004412:	0791                	addi	a5,a5,4
    80004414:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004416:	fed79ce3          	bne	a5,a3,8000440e <write_head+0x50>
  }
  bwrite(buf);
    8000441a:	8526                	mv	a0,s1
    8000441c:	fffff097          	auipc	ra,0xfffff
    80004420:	096080e7          	jalr	150(ra) # 800034b2 <bwrite>
  brelse(buf);
    80004424:	8526                	mv	a0,s1
    80004426:	fffff097          	auipc	ra,0xfffff
    8000442a:	0ca080e7          	jalr	202(ra) # 800034f0 <brelse>
}
    8000442e:	60e2                	ld	ra,24(sp)
    80004430:	6442                	ld	s0,16(sp)
    80004432:	64a2                	ld	s1,8(sp)
    80004434:	6902                	ld	s2,0(sp)
    80004436:	6105                	addi	sp,sp,32
    80004438:	8082                	ret

000000008000443a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000443a:	0001d797          	auipc	a5,0x1d
    8000443e:	8927a783          	lw	a5,-1902(a5) # 80020ccc <log+0x2c>
    80004442:	0af05d63          	blez	a5,800044fc <install_trans+0xc2>
{
    80004446:	7139                	addi	sp,sp,-64
    80004448:	fc06                	sd	ra,56(sp)
    8000444a:	f822                	sd	s0,48(sp)
    8000444c:	f426                	sd	s1,40(sp)
    8000444e:	f04a                	sd	s2,32(sp)
    80004450:	ec4e                	sd	s3,24(sp)
    80004452:	e852                	sd	s4,16(sp)
    80004454:	e456                	sd	s5,8(sp)
    80004456:	e05a                	sd	s6,0(sp)
    80004458:	0080                	addi	s0,sp,64
    8000445a:	8b2a                	mv	s6,a0
    8000445c:	0001da97          	auipc	s5,0x1d
    80004460:	874a8a93          	addi	s5,s5,-1932 # 80020cd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004464:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004466:	0001d997          	auipc	s3,0x1d
    8000446a:	83a98993          	addi	s3,s3,-1990 # 80020ca0 <log>
    8000446e:	a00d                	j	80004490 <install_trans+0x56>
    brelse(lbuf);
    80004470:	854a                	mv	a0,s2
    80004472:	fffff097          	auipc	ra,0xfffff
    80004476:	07e080e7          	jalr	126(ra) # 800034f0 <brelse>
    brelse(dbuf);
    8000447a:	8526                	mv	a0,s1
    8000447c:	fffff097          	auipc	ra,0xfffff
    80004480:	074080e7          	jalr	116(ra) # 800034f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004484:	2a05                	addiw	s4,s4,1
    80004486:	0a91                	addi	s5,s5,4
    80004488:	02c9a783          	lw	a5,44(s3)
    8000448c:	04fa5e63          	bge	s4,a5,800044e8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004490:	0189a583          	lw	a1,24(s3)
    80004494:	014585bb          	addw	a1,a1,s4
    80004498:	2585                	addiw	a1,a1,1
    8000449a:	0289a503          	lw	a0,40(s3)
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	f22080e7          	jalr	-222(ra) # 800033c0 <bread>
    800044a6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044a8:	000aa583          	lw	a1,0(s5)
    800044ac:	0289a503          	lw	a0,40(s3)
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	f10080e7          	jalr	-240(ra) # 800033c0 <bread>
    800044b8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044ba:	40000613          	li	a2,1024
    800044be:	05890593          	addi	a1,s2,88
    800044c2:	05850513          	addi	a0,a0,88
    800044c6:	ffffd097          	auipc	ra,0xffffd
    800044ca:	930080e7          	jalr	-1744(ra) # 80000df6 <memmove>
    bwrite(dbuf);  // write dst to disk
    800044ce:	8526                	mv	a0,s1
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	fe2080e7          	jalr	-30(ra) # 800034b2 <bwrite>
    if(recovering == 0)
    800044d8:	f80b1ce3          	bnez	s6,80004470 <install_trans+0x36>
      bunpin(dbuf);
    800044dc:	8526                	mv	a0,s1
    800044de:	fffff097          	auipc	ra,0xfffff
    800044e2:	0ec080e7          	jalr	236(ra) # 800035ca <bunpin>
    800044e6:	b769                	j	80004470 <install_trans+0x36>
}
    800044e8:	70e2                	ld	ra,56(sp)
    800044ea:	7442                	ld	s0,48(sp)
    800044ec:	74a2                	ld	s1,40(sp)
    800044ee:	7902                	ld	s2,32(sp)
    800044f0:	69e2                	ld	s3,24(sp)
    800044f2:	6a42                	ld	s4,16(sp)
    800044f4:	6aa2                	ld	s5,8(sp)
    800044f6:	6b02                	ld	s6,0(sp)
    800044f8:	6121                	addi	sp,sp,64
    800044fa:	8082                	ret
    800044fc:	8082                	ret

00000000800044fe <initlog>:
{
    800044fe:	7179                	addi	sp,sp,-48
    80004500:	f406                	sd	ra,40(sp)
    80004502:	f022                	sd	s0,32(sp)
    80004504:	ec26                	sd	s1,24(sp)
    80004506:	e84a                	sd	s2,16(sp)
    80004508:	e44e                	sd	s3,8(sp)
    8000450a:	1800                	addi	s0,sp,48
    8000450c:	892a                	mv	s2,a0
    8000450e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004510:	0001c497          	auipc	s1,0x1c
    80004514:	79048493          	addi	s1,s1,1936 # 80020ca0 <log>
    80004518:	00004597          	auipc	a1,0x4
    8000451c:	24858593          	addi	a1,a1,584 # 80008760 <syscalls+0x200>
    80004520:	8526                	mv	a0,s1
    80004522:	ffffc097          	auipc	ra,0xffffc
    80004526:	6ec080e7          	jalr	1772(ra) # 80000c0e <initlock>
  log.start = sb->logstart;
    8000452a:	0149a583          	lw	a1,20(s3)
    8000452e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004530:	0109a783          	lw	a5,16(s3)
    80004534:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004536:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000453a:	854a                	mv	a0,s2
    8000453c:	fffff097          	auipc	ra,0xfffff
    80004540:	e84080e7          	jalr	-380(ra) # 800033c0 <bread>
  log.lh.n = lh->n;
    80004544:	4d34                	lw	a3,88(a0)
    80004546:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004548:	02d05663          	blez	a3,80004574 <initlog+0x76>
    8000454c:	05c50793          	addi	a5,a0,92
    80004550:	0001c717          	auipc	a4,0x1c
    80004554:	78070713          	addi	a4,a4,1920 # 80020cd0 <log+0x30>
    80004558:	36fd                	addiw	a3,a3,-1
    8000455a:	02069613          	slli	a2,a3,0x20
    8000455e:	01e65693          	srli	a3,a2,0x1e
    80004562:	06050613          	addi	a2,a0,96
    80004566:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004568:	4390                	lw	a2,0(a5)
    8000456a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000456c:	0791                	addi	a5,a5,4
    8000456e:	0711                	addi	a4,a4,4
    80004570:	fed79ce3          	bne	a5,a3,80004568 <initlog+0x6a>
  brelse(buf);
    80004574:	fffff097          	auipc	ra,0xfffff
    80004578:	f7c080e7          	jalr	-132(ra) # 800034f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000457c:	4505                	li	a0,1
    8000457e:	00000097          	auipc	ra,0x0
    80004582:	ebc080e7          	jalr	-324(ra) # 8000443a <install_trans>
  log.lh.n = 0;
    80004586:	0001c797          	auipc	a5,0x1c
    8000458a:	7407a323          	sw	zero,1862(a5) # 80020ccc <log+0x2c>
  write_head(); // clear the log
    8000458e:	00000097          	auipc	ra,0x0
    80004592:	e30080e7          	jalr	-464(ra) # 800043be <write_head>
}
    80004596:	70a2                	ld	ra,40(sp)
    80004598:	7402                	ld	s0,32(sp)
    8000459a:	64e2                	ld	s1,24(sp)
    8000459c:	6942                	ld	s2,16(sp)
    8000459e:	69a2                	ld	s3,8(sp)
    800045a0:	6145                	addi	sp,sp,48
    800045a2:	8082                	ret

00000000800045a4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045a4:	1101                	addi	sp,sp,-32
    800045a6:	ec06                	sd	ra,24(sp)
    800045a8:	e822                	sd	s0,16(sp)
    800045aa:	e426                	sd	s1,8(sp)
    800045ac:	e04a                	sd	s2,0(sp)
    800045ae:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045b0:	0001c517          	auipc	a0,0x1c
    800045b4:	6f050513          	addi	a0,a0,1776 # 80020ca0 <log>
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	6e6080e7          	jalr	1766(ra) # 80000c9e <acquire>
  while(1){
    if(log.committing){
    800045c0:	0001c497          	auipc	s1,0x1c
    800045c4:	6e048493          	addi	s1,s1,1760 # 80020ca0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045c8:	4979                	li	s2,30
    800045ca:	a039                	j	800045d8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045cc:	85a6                	mv	a1,s1
    800045ce:	8526                	mv	a0,s1
    800045d0:	ffffe097          	auipc	ra,0xffffe
    800045d4:	dac080e7          	jalr	-596(ra) # 8000237c <sleep>
    if(log.committing){
    800045d8:	50dc                	lw	a5,36(s1)
    800045da:	fbed                	bnez	a5,800045cc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045dc:	5098                	lw	a4,32(s1)
    800045de:	2705                	addiw	a4,a4,1
    800045e0:	0007069b          	sext.w	a3,a4
    800045e4:	0027179b          	slliw	a5,a4,0x2
    800045e8:	9fb9                	addw	a5,a5,a4
    800045ea:	0017979b          	slliw	a5,a5,0x1
    800045ee:	54d8                	lw	a4,44(s1)
    800045f0:	9fb9                	addw	a5,a5,a4
    800045f2:	00f95963          	bge	s2,a5,80004604 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045f6:	85a6                	mv	a1,s1
    800045f8:	8526                	mv	a0,s1
    800045fa:	ffffe097          	auipc	ra,0xffffe
    800045fe:	d82080e7          	jalr	-638(ra) # 8000237c <sleep>
    80004602:	bfd9                	j	800045d8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004604:	0001c517          	auipc	a0,0x1c
    80004608:	69c50513          	addi	a0,a0,1692 # 80020ca0 <log>
    8000460c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	744080e7          	jalr	1860(ra) # 80000d52 <release>
      break;
    }
  }
}
    80004616:	60e2                	ld	ra,24(sp)
    80004618:	6442                	ld	s0,16(sp)
    8000461a:	64a2                	ld	s1,8(sp)
    8000461c:	6902                	ld	s2,0(sp)
    8000461e:	6105                	addi	sp,sp,32
    80004620:	8082                	ret

0000000080004622 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004622:	7139                	addi	sp,sp,-64
    80004624:	fc06                	sd	ra,56(sp)
    80004626:	f822                	sd	s0,48(sp)
    80004628:	f426                	sd	s1,40(sp)
    8000462a:	f04a                	sd	s2,32(sp)
    8000462c:	ec4e                	sd	s3,24(sp)
    8000462e:	e852                	sd	s4,16(sp)
    80004630:	e456                	sd	s5,8(sp)
    80004632:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004634:	0001c497          	auipc	s1,0x1c
    80004638:	66c48493          	addi	s1,s1,1644 # 80020ca0 <log>
    8000463c:	8526                	mv	a0,s1
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	660080e7          	jalr	1632(ra) # 80000c9e <acquire>
  log.outstanding -= 1;
    80004646:	509c                	lw	a5,32(s1)
    80004648:	37fd                	addiw	a5,a5,-1
    8000464a:	0007891b          	sext.w	s2,a5
    8000464e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004650:	50dc                	lw	a5,36(s1)
    80004652:	e7b9                	bnez	a5,800046a0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004654:	04091e63          	bnez	s2,800046b0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004658:	0001c497          	auipc	s1,0x1c
    8000465c:	64848493          	addi	s1,s1,1608 # 80020ca0 <log>
    80004660:	4785                	li	a5,1
    80004662:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004664:	8526                	mv	a0,s1
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	6ec080e7          	jalr	1772(ra) # 80000d52 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000466e:	54dc                	lw	a5,44(s1)
    80004670:	06f04763          	bgtz	a5,800046de <end_op+0xbc>
    acquire(&log.lock);
    80004674:	0001c497          	auipc	s1,0x1c
    80004678:	62c48493          	addi	s1,s1,1580 # 80020ca0 <log>
    8000467c:	8526                	mv	a0,s1
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	620080e7          	jalr	1568(ra) # 80000c9e <acquire>
    log.committing = 0;
    80004686:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000468a:	8526                	mv	a0,s1
    8000468c:	ffffe097          	auipc	ra,0xffffe
    80004690:	d54080e7          	jalr	-684(ra) # 800023e0 <wakeup>
    release(&log.lock);
    80004694:	8526                	mv	a0,s1
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	6bc080e7          	jalr	1724(ra) # 80000d52 <release>
}
    8000469e:	a03d                	j	800046cc <end_op+0xaa>
    panic("log.committing");
    800046a0:	00004517          	auipc	a0,0x4
    800046a4:	0c850513          	addi	a0,a0,200 # 80008768 <syscalls+0x208>
    800046a8:	ffffc097          	auipc	ra,0xffffc
    800046ac:	e98080e7          	jalr	-360(ra) # 80000540 <panic>
    wakeup(&log);
    800046b0:	0001c497          	auipc	s1,0x1c
    800046b4:	5f048493          	addi	s1,s1,1520 # 80020ca0 <log>
    800046b8:	8526                	mv	a0,s1
    800046ba:	ffffe097          	auipc	ra,0xffffe
    800046be:	d26080e7          	jalr	-730(ra) # 800023e0 <wakeup>
  release(&log.lock);
    800046c2:	8526                	mv	a0,s1
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	68e080e7          	jalr	1678(ra) # 80000d52 <release>
}
    800046cc:	70e2                	ld	ra,56(sp)
    800046ce:	7442                	ld	s0,48(sp)
    800046d0:	74a2                	ld	s1,40(sp)
    800046d2:	7902                	ld	s2,32(sp)
    800046d4:	69e2                	ld	s3,24(sp)
    800046d6:	6a42                	ld	s4,16(sp)
    800046d8:	6aa2                	ld	s5,8(sp)
    800046da:	6121                	addi	sp,sp,64
    800046dc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046de:	0001ca97          	auipc	s5,0x1c
    800046e2:	5f2a8a93          	addi	s5,s5,1522 # 80020cd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046e6:	0001ca17          	auipc	s4,0x1c
    800046ea:	5baa0a13          	addi	s4,s4,1466 # 80020ca0 <log>
    800046ee:	018a2583          	lw	a1,24(s4)
    800046f2:	012585bb          	addw	a1,a1,s2
    800046f6:	2585                	addiw	a1,a1,1
    800046f8:	028a2503          	lw	a0,40(s4)
    800046fc:	fffff097          	auipc	ra,0xfffff
    80004700:	cc4080e7          	jalr	-828(ra) # 800033c0 <bread>
    80004704:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004706:	000aa583          	lw	a1,0(s5)
    8000470a:	028a2503          	lw	a0,40(s4)
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	cb2080e7          	jalr	-846(ra) # 800033c0 <bread>
    80004716:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004718:	40000613          	li	a2,1024
    8000471c:	05850593          	addi	a1,a0,88
    80004720:	05848513          	addi	a0,s1,88
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	6d2080e7          	jalr	1746(ra) # 80000df6 <memmove>
    bwrite(to);  // write the log
    8000472c:	8526                	mv	a0,s1
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	d84080e7          	jalr	-636(ra) # 800034b2 <bwrite>
    brelse(from);
    80004736:	854e                	mv	a0,s3
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	db8080e7          	jalr	-584(ra) # 800034f0 <brelse>
    brelse(to);
    80004740:	8526                	mv	a0,s1
    80004742:	fffff097          	auipc	ra,0xfffff
    80004746:	dae080e7          	jalr	-594(ra) # 800034f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000474a:	2905                	addiw	s2,s2,1
    8000474c:	0a91                	addi	s5,s5,4
    8000474e:	02ca2783          	lw	a5,44(s4)
    80004752:	f8f94ee3          	blt	s2,a5,800046ee <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	c68080e7          	jalr	-920(ra) # 800043be <write_head>
    install_trans(0); // Now install writes to home locations
    8000475e:	4501                	li	a0,0
    80004760:	00000097          	auipc	ra,0x0
    80004764:	cda080e7          	jalr	-806(ra) # 8000443a <install_trans>
    log.lh.n = 0;
    80004768:	0001c797          	auipc	a5,0x1c
    8000476c:	5607a223          	sw	zero,1380(a5) # 80020ccc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004770:	00000097          	auipc	ra,0x0
    80004774:	c4e080e7          	jalr	-946(ra) # 800043be <write_head>
    80004778:	bdf5                	j	80004674 <end_op+0x52>

000000008000477a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000477a:	1101                	addi	sp,sp,-32
    8000477c:	ec06                	sd	ra,24(sp)
    8000477e:	e822                	sd	s0,16(sp)
    80004780:	e426                	sd	s1,8(sp)
    80004782:	e04a                	sd	s2,0(sp)
    80004784:	1000                	addi	s0,sp,32
    80004786:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004788:	0001c917          	auipc	s2,0x1c
    8000478c:	51890913          	addi	s2,s2,1304 # 80020ca0 <log>
    80004790:	854a                	mv	a0,s2
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	50c080e7          	jalr	1292(ra) # 80000c9e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000479a:	02c92603          	lw	a2,44(s2)
    8000479e:	47f5                	li	a5,29
    800047a0:	06c7c563          	blt	a5,a2,8000480a <log_write+0x90>
    800047a4:	0001c797          	auipc	a5,0x1c
    800047a8:	5187a783          	lw	a5,1304(a5) # 80020cbc <log+0x1c>
    800047ac:	37fd                	addiw	a5,a5,-1
    800047ae:	04f65e63          	bge	a2,a5,8000480a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047b2:	0001c797          	auipc	a5,0x1c
    800047b6:	50e7a783          	lw	a5,1294(a5) # 80020cc0 <log+0x20>
    800047ba:	06f05063          	blez	a5,8000481a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047be:	4781                	li	a5,0
    800047c0:	06c05563          	blez	a2,8000482a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047c4:	44cc                	lw	a1,12(s1)
    800047c6:	0001c717          	auipc	a4,0x1c
    800047ca:	50a70713          	addi	a4,a4,1290 # 80020cd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047ce:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047d0:	4314                	lw	a3,0(a4)
    800047d2:	04b68c63          	beq	a3,a1,8000482a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047d6:	2785                	addiw	a5,a5,1
    800047d8:	0711                	addi	a4,a4,4
    800047da:	fef61be3          	bne	a2,a5,800047d0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047de:	0621                	addi	a2,a2,8
    800047e0:	060a                	slli	a2,a2,0x2
    800047e2:	0001c797          	auipc	a5,0x1c
    800047e6:	4be78793          	addi	a5,a5,1214 # 80020ca0 <log>
    800047ea:	97b2                	add	a5,a5,a2
    800047ec:	44d8                	lw	a4,12(s1)
    800047ee:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047f0:	8526                	mv	a0,s1
    800047f2:	fffff097          	auipc	ra,0xfffff
    800047f6:	d9c080e7          	jalr	-612(ra) # 8000358e <bpin>
    log.lh.n++;
    800047fa:	0001c717          	auipc	a4,0x1c
    800047fe:	4a670713          	addi	a4,a4,1190 # 80020ca0 <log>
    80004802:	575c                	lw	a5,44(a4)
    80004804:	2785                	addiw	a5,a5,1
    80004806:	d75c                	sw	a5,44(a4)
    80004808:	a82d                	j	80004842 <log_write+0xc8>
    panic("too big a transaction");
    8000480a:	00004517          	auipc	a0,0x4
    8000480e:	f6e50513          	addi	a0,a0,-146 # 80008778 <syscalls+0x218>
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	d2e080e7          	jalr	-722(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    8000481a:	00004517          	auipc	a0,0x4
    8000481e:	f7650513          	addi	a0,a0,-138 # 80008790 <syscalls+0x230>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	d1e080e7          	jalr	-738(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    8000482a:	00878693          	addi	a3,a5,8
    8000482e:	068a                	slli	a3,a3,0x2
    80004830:	0001c717          	auipc	a4,0x1c
    80004834:	47070713          	addi	a4,a4,1136 # 80020ca0 <log>
    80004838:	9736                	add	a4,a4,a3
    8000483a:	44d4                	lw	a3,12(s1)
    8000483c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000483e:	faf609e3          	beq	a2,a5,800047f0 <log_write+0x76>
  }
  release(&log.lock);
    80004842:	0001c517          	auipc	a0,0x1c
    80004846:	45e50513          	addi	a0,a0,1118 # 80020ca0 <log>
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	508080e7          	jalr	1288(ra) # 80000d52 <release>
}
    80004852:	60e2                	ld	ra,24(sp)
    80004854:	6442                	ld	s0,16(sp)
    80004856:	64a2                	ld	s1,8(sp)
    80004858:	6902                	ld	s2,0(sp)
    8000485a:	6105                	addi	sp,sp,32
    8000485c:	8082                	ret

000000008000485e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000485e:	1101                	addi	sp,sp,-32
    80004860:	ec06                	sd	ra,24(sp)
    80004862:	e822                	sd	s0,16(sp)
    80004864:	e426                	sd	s1,8(sp)
    80004866:	e04a                	sd	s2,0(sp)
    80004868:	1000                	addi	s0,sp,32
    8000486a:	84aa                	mv	s1,a0
    8000486c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000486e:	00004597          	auipc	a1,0x4
    80004872:	f4258593          	addi	a1,a1,-190 # 800087b0 <syscalls+0x250>
    80004876:	0521                	addi	a0,a0,8
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	396080e7          	jalr	918(ra) # 80000c0e <initlock>
  lk->name = name;
    80004880:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004884:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004888:	0204a423          	sw	zero,40(s1)
}
    8000488c:	60e2                	ld	ra,24(sp)
    8000488e:	6442                	ld	s0,16(sp)
    80004890:	64a2                	ld	s1,8(sp)
    80004892:	6902                	ld	s2,0(sp)
    80004894:	6105                	addi	sp,sp,32
    80004896:	8082                	ret

0000000080004898 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004898:	1101                	addi	sp,sp,-32
    8000489a:	ec06                	sd	ra,24(sp)
    8000489c:	e822                	sd	s0,16(sp)
    8000489e:	e426                	sd	s1,8(sp)
    800048a0:	e04a                	sd	s2,0(sp)
    800048a2:	1000                	addi	s0,sp,32
    800048a4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048a6:	00850913          	addi	s2,a0,8
    800048aa:	854a                	mv	a0,s2
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	3f2080e7          	jalr	1010(ra) # 80000c9e <acquire>
  while (lk->locked) {
    800048b4:	409c                	lw	a5,0(s1)
    800048b6:	cb89                	beqz	a5,800048c8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048b8:	85ca                	mv	a1,s2
    800048ba:	8526                	mv	a0,s1
    800048bc:	ffffe097          	auipc	ra,0xffffe
    800048c0:	ac0080e7          	jalr	-1344(ra) # 8000237c <sleep>
  while (lk->locked) {
    800048c4:	409c                	lw	a5,0(s1)
    800048c6:	fbed                	bnez	a5,800048b8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048c8:	4785                	li	a5,1
    800048ca:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048cc:	ffffd097          	auipc	ra,0xffffd
    800048d0:	302080e7          	jalr	770(ra) # 80001bce <myproc>
    800048d4:	591c                	lw	a5,48(a0)
    800048d6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048d8:	854a                	mv	a0,s2
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	478080e7          	jalr	1144(ra) # 80000d52 <release>
}
    800048e2:	60e2                	ld	ra,24(sp)
    800048e4:	6442                	ld	s0,16(sp)
    800048e6:	64a2                	ld	s1,8(sp)
    800048e8:	6902                	ld	s2,0(sp)
    800048ea:	6105                	addi	sp,sp,32
    800048ec:	8082                	ret

00000000800048ee <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048ee:	1101                	addi	sp,sp,-32
    800048f0:	ec06                	sd	ra,24(sp)
    800048f2:	e822                	sd	s0,16(sp)
    800048f4:	e426                	sd	s1,8(sp)
    800048f6:	e04a                	sd	s2,0(sp)
    800048f8:	1000                	addi	s0,sp,32
    800048fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048fc:	00850913          	addi	s2,a0,8
    80004900:	854a                	mv	a0,s2
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	39c080e7          	jalr	924(ra) # 80000c9e <acquire>
  lk->locked = 0;
    8000490a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000490e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004912:	8526                	mv	a0,s1
    80004914:	ffffe097          	auipc	ra,0xffffe
    80004918:	acc080e7          	jalr	-1332(ra) # 800023e0 <wakeup>
  release(&lk->lk);
    8000491c:	854a                	mv	a0,s2
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	434080e7          	jalr	1076(ra) # 80000d52 <release>
}
    80004926:	60e2                	ld	ra,24(sp)
    80004928:	6442                	ld	s0,16(sp)
    8000492a:	64a2                	ld	s1,8(sp)
    8000492c:	6902                	ld	s2,0(sp)
    8000492e:	6105                	addi	sp,sp,32
    80004930:	8082                	ret

0000000080004932 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004932:	7179                	addi	sp,sp,-48
    80004934:	f406                	sd	ra,40(sp)
    80004936:	f022                	sd	s0,32(sp)
    80004938:	ec26                	sd	s1,24(sp)
    8000493a:	e84a                	sd	s2,16(sp)
    8000493c:	e44e                	sd	s3,8(sp)
    8000493e:	1800                	addi	s0,sp,48
    80004940:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004942:	00850913          	addi	s2,a0,8
    80004946:	854a                	mv	a0,s2
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	356080e7          	jalr	854(ra) # 80000c9e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004950:	409c                	lw	a5,0(s1)
    80004952:	ef99                	bnez	a5,80004970 <holdingsleep+0x3e>
    80004954:	4481                	li	s1,0
  release(&lk->lk);
    80004956:	854a                	mv	a0,s2
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	3fa080e7          	jalr	1018(ra) # 80000d52 <release>
  return r;
}
    80004960:	8526                	mv	a0,s1
    80004962:	70a2                	ld	ra,40(sp)
    80004964:	7402                	ld	s0,32(sp)
    80004966:	64e2                	ld	s1,24(sp)
    80004968:	6942                	ld	s2,16(sp)
    8000496a:	69a2                	ld	s3,8(sp)
    8000496c:	6145                	addi	sp,sp,48
    8000496e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004970:	0284a983          	lw	s3,40(s1)
    80004974:	ffffd097          	auipc	ra,0xffffd
    80004978:	25a080e7          	jalr	602(ra) # 80001bce <myproc>
    8000497c:	5904                	lw	s1,48(a0)
    8000497e:	413484b3          	sub	s1,s1,s3
    80004982:	0014b493          	seqz	s1,s1
    80004986:	bfc1                	j	80004956 <holdingsleep+0x24>

0000000080004988 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004988:	1141                	addi	sp,sp,-16
    8000498a:	e406                	sd	ra,8(sp)
    8000498c:	e022                	sd	s0,0(sp)
    8000498e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004990:	00004597          	auipc	a1,0x4
    80004994:	e3058593          	addi	a1,a1,-464 # 800087c0 <syscalls+0x260>
    80004998:	0001c517          	auipc	a0,0x1c
    8000499c:	45050513          	addi	a0,a0,1104 # 80020de8 <ftable>
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	26e080e7          	jalr	622(ra) # 80000c0e <initlock>
}
    800049a8:	60a2                	ld	ra,8(sp)
    800049aa:	6402                	ld	s0,0(sp)
    800049ac:	0141                	addi	sp,sp,16
    800049ae:	8082                	ret

00000000800049b0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049b0:	1101                	addi	sp,sp,-32
    800049b2:	ec06                	sd	ra,24(sp)
    800049b4:	e822                	sd	s0,16(sp)
    800049b6:	e426                	sd	s1,8(sp)
    800049b8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049ba:	0001c517          	auipc	a0,0x1c
    800049be:	42e50513          	addi	a0,a0,1070 # 80020de8 <ftable>
    800049c2:	ffffc097          	auipc	ra,0xffffc
    800049c6:	2dc080e7          	jalr	732(ra) # 80000c9e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049ca:	0001c497          	auipc	s1,0x1c
    800049ce:	43648493          	addi	s1,s1,1078 # 80020e00 <ftable+0x18>
    800049d2:	0001d717          	auipc	a4,0x1d
    800049d6:	3ce70713          	addi	a4,a4,974 # 80021da0 <disk>
    if(f->ref == 0){
    800049da:	40dc                	lw	a5,4(s1)
    800049dc:	cf99                	beqz	a5,800049fa <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049de:	02848493          	addi	s1,s1,40
    800049e2:	fee49ce3          	bne	s1,a4,800049da <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049e6:	0001c517          	auipc	a0,0x1c
    800049ea:	40250513          	addi	a0,a0,1026 # 80020de8 <ftable>
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	364080e7          	jalr	868(ra) # 80000d52 <release>
  return 0;
    800049f6:	4481                	li	s1,0
    800049f8:	a819                	j	80004a0e <filealloc+0x5e>
      f->ref = 1;
    800049fa:	4785                	li	a5,1
    800049fc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049fe:	0001c517          	auipc	a0,0x1c
    80004a02:	3ea50513          	addi	a0,a0,1002 # 80020de8 <ftable>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	34c080e7          	jalr	844(ra) # 80000d52 <release>
}
    80004a0e:	8526                	mv	a0,s1
    80004a10:	60e2                	ld	ra,24(sp)
    80004a12:	6442                	ld	s0,16(sp)
    80004a14:	64a2                	ld	s1,8(sp)
    80004a16:	6105                	addi	sp,sp,32
    80004a18:	8082                	ret

0000000080004a1a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a1a:	1101                	addi	sp,sp,-32
    80004a1c:	ec06                	sd	ra,24(sp)
    80004a1e:	e822                	sd	s0,16(sp)
    80004a20:	e426                	sd	s1,8(sp)
    80004a22:	1000                	addi	s0,sp,32
    80004a24:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a26:	0001c517          	auipc	a0,0x1c
    80004a2a:	3c250513          	addi	a0,a0,962 # 80020de8 <ftable>
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	270080e7          	jalr	624(ra) # 80000c9e <acquire>
  if(f->ref < 1)
    80004a36:	40dc                	lw	a5,4(s1)
    80004a38:	02f05263          	blez	a5,80004a5c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a3c:	2785                	addiw	a5,a5,1
    80004a3e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a40:	0001c517          	auipc	a0,0x1c
    80004a44:	3a850513          	addi	a0,a0,936 # 80020de8 <ftable>
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	30a080e7          	jalr	778(ra) # 80000d52 <release>
  return f;
}
    80004a50:	8526                	mv	a0,s1
    80004a52:	60e2                	ld	ra,24(sp)
    80004a54:	6442                	ld	s0,16(sp)
    80004a56:	64a2                	ld	s1,8(sp)
    80004a58:	6105                	addi	sp,sp,32
    80004a5a:	8082                	ret
    panic("filedup");
    80004a5c:	00004517          	auipc	a0,0x4
    80004a60:	d6c50513          	addi	a0,a0,-660 # 800087c8 <syscalls+0x268>
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	adc080e7          	jalr	-1316(ra) # 80000540 <panic>

0000000080004a6c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a6c:	7139                	addi	sp,sp,-64
    80004a6e:	fc06                	sd	ra,56(sp)
    80004a70:	f822                	sd	s0,48(sp)
    80004a72:	f426                	sd	s1,40(sp)
    80004a74:	f04a                	sd	s2,32(sp)
    80004a76:	ec4e                	sd	s3,24(sp)
    80004a78:	e852                	sd	s4,16(sp)
    80004a7a:	e456                	sd	s5,8(sp)
    80004a7c:	0080                	addi	s0,sp,64
    80004a7e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a80:	0001c517          	auipc	a0,0x1c
    80004a84:	36850513          	addi	a0,a0,872 # 80020de8 <ftable>
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	216080e7          	jalr	534(ra) # 80000c9e <acquire>
  if(f->ref < 1)
    80004a90:	40dc                	lw	a5,4(s1)
    80004a92:	06f05163          	blez	a5,80004af4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a96:	37fd                	addiw	a5,a5,-1
    80004a98:	0007871b          	sext.w	a4,a5
    80004a9c:	c0dc                	sw	a5,4(s1)
    80004a9e:	06e04363          	bgtz	a4,80004b04 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004aa2:	0004a903          	lw	s2,0(s1)
    80004aa6:	0094ca83          	lbu	s5,9(s1)
    80004aaa:	0104ba03          	ld	s4,16(s1)
    80004aae:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ab2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ab6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004aba:	0001c517          	auipc	a0,0x1c
    80004abe:	32e50513          	addi	a0,a0,814 # 80020de8 <ftable>
    80004ac2:	ffffc097          	auipc	ra,0xffffc
    80004ac6:	290080e7          	jalr	656(ra) # 80000d52 <release>

  if(ff.type == FD_PIPE){
    80004aca:	4785                	li	a5,1
    80004acc:	04f90d63          	beq	s2,a5,80004b26 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ad0:	3979                	addiw	s2,s2,-2
    80004ad2:	4785                	li	a5,1
    80004ad4:	0527e063          	bltu	a5,s2,80004b14 <fileclose+0xa8>
    begin_op();
    80004ad8:	00000097          	auipc	ra,0x0
    80004adc:	acc080e7          	jalr	-1332(ra) # 800045a4 <begin_op>
    iput(ff.ip);
    80004ae0:	854e                	mv	a0,s3
    80004ae2:	fffff097          	auipc	ra,0xfffff
    80004ae6:	2b0080e7          	jalr	688(ra) # 80003d92 <iput>
    end_op();
    80004aea:	00000097          	auipc	ra,0x0
    80004aee:	b38080e7          	jalr	-1224(ra) # 80004622 <end_op>
    80004af2:	a00d                	j	80004b14 <fileclose+0xa8>
    panic("fileclose");
    80004af4:	00004517          	auipc	a0,0x4
    80004af8:	cdc50513          	addi	a0,a0,-804 # 800087d0 <syscalls+0x270>
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	a44080e7          	jalr	-1468(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004b04:	0001c517          	auipc	a0,0x1c
    80004b08:	2e450513          	addi	a0,a0,740 # 80020de8 <ftable>
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	246080e7          	jalr	582(ra) # 80000d52 <release>
  }
}
    80004b14:	70e2                	ld	ra,56(sp)
    80004b16:	7442                	ld	s0,48(sp)
    80004b18:	74a2                	ld	s1,40(sp)
    80004b1a:	7902                	ld	s2,32(sp)
    80004b1c:	69e2                	ld	s3,24(sp)
    80004b1e:	6a42                	ld	s4,16(sp)
    80004b20:	6aa2                	ld	s5,8(sp)
    80004b22:	6121                	addi	sp,sp,64
    80004b24:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b26:	85d6                	mv	a1,s5
    80004b28:	8552                	mv	a0,s4
    80004b2a:	00000097          	auipc	ra,0x0
    80004b2e:	34c080e7          	jalr	844(ra) # 80004e76 <pipeclose>
    80004b32:	b7cd                	j	80004b14 <fileclose+0xa8>

0000000080004b34 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b34:	715d                	addi	sp,sp,-80
    80004b36:	e486                	sd	ra,72(sp)
    80004b38:	e0a2                	sd	s0,64(sp)
    80004b3a:	fc26                	sd	s1,56(sp)
    80004b3c:	f84a                	sd	s2,48(sp)
    80004b3e:	f44e                	sd	s3,40(sp)
    80004b40:	0880                	addi	s0,sp,80
    80004b42:	84aa                	mv	s1,a0
    80004b44:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b46:	ffffd097          	auipc	ra,0xffffd
    80004b4a:	088080e7          	jalr	136(ra) # 80001bce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b4e:	409c                	lw	a5,0(s1)
    80004b50:	37f9                	addiw	a5,a5,-2
    80004b52:	4705                	li	a4,1
    80004b54:	04f76763          	bltu	a4,a5,80004ba2 <filestat+0x6e>
    80004b58:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b5a:	6c88                	ld	a0,24(s1)
    80004b5c:	fffff097          	auipc	ra,0xfffff
    80004b60:	07c080e7          	jalr	124(ra) # 80003bd8 <ilock>
    stati(f->ip, &st);
    80004b64:	fb840593          	addi	a1,s0,-72
    80004b68:	6c88                	ld	a0,24(s1)
    80004b6a:	fffff097          	auipc	ra,0xfffff
    80004b6e:	2f8080e7          	jalr	760(ra) # 80003e62 <stati>
    iunlock(f->ip);
    80004b72:	6c88                	ld	a0,24(s1)
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	126080e7          	jalr	294(ra) # 80003c9a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b7c:	46e1                	li	a3,24
    80004b7e:	fb840613          	addi	a2,s0,-72
    80004b82:	85ce                	mv	a1,s3
    80004b84:	05093503          	ld	a0,80(s2)
    80004b88:	ffffd097          	auipc	ra,0xffffd
    80004b8c:	bac080e7          	jalr	-1108(ra) # 80001734 <copyout>
    80004b90:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b94:	60a6                	ld	ra,72(sp)
    80004b96:	6406                	ld	s0,64(sp)
    80004b98:	74e2                	ld	s1,56(sp)
    80004b9a:	7942                	ld	s2,48(sp)
    80004b9c:	79a2                	ld	s3,40(sp)
    80004b9e:	6161                	addi	sp,sp,80
    80004ba0:	8082                	ret
  return -1;
    80004ba2:	557d                	li	a0,-1
    80004ba4:	bfc5                	j	80004b94 <filestat+0x60>

0000000080004ba6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ba6:	7179                	addi	sp,sp,-48
    80004ba8:	f406                	sd	ra,40(sp)
    80004baa:	f022                	sd	s0,32(sp)
    80004bac:	ec26                	sd	s1,24(sp)
    80004bae:	e84a                	sd	s2,16(sp)
    80004bb0:	e44e                	sd	s3,8(sp)
    80004bb2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bb4:	00854783          	lbu	a5,8(a0)
    80004bb8:	c3d5                	beqz	a5,80004c5c <fileread+0xb6>
    80004bba:	84aa                	mv	s1,a0
    80004bbc:	89ae                	mv	s3,a1
    80004bbe:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bc0:	411c                	lw	a5,0(a0)
    80004bc2:	4705                	li	a4,1
    80004bc4:	04e78963          	beq	a5,a4,80004c16 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bc8:	470d                	li	a4,3
    80004bca:	04e78d63          	beq	a5,a4,80004c24 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bce:	4709                	li	a4,2
    80004bd0:	06e79e63          	bne	a5,a4,80004c4c <fileread+0xa6>
    ilock(f->ip);
    80004bd4:	6d08                	ld	a0,24(a0)
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	002080e7          	jalr	2(ra) # 80003bd8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bde:	874a                	mv	a4,s2
    80004be0:	5094                	lw	a3,32(s1)
    80004be2:	864e                	mv	a2,s3
    80004be4:	4585                	li	a1,1
    80004be6:	6c88                	ld	a0,24(s1)
    80004be8:	fffff097          	auipc	ra,0xfffff
    80004bec:	2a4080e7          	jalr	676(ra) # 80003e8c <readi>
    80004bf0:	892a                	mv	s2,a0
    80004bf2:	00a05563          	blez	a0,80004bfc <fileread+0x56>
      f->off += r;
    80004bf6:	509c                	lw	a5,32(s1)
    80004bf8:	9fa9                	addw	a5,a5,a0
    80004bfa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bfc:	6c88                	ld	a0,24(s1)
    80004bfe:	fffff097          	auipc	ra,0xfffff
    80004c02:	09c080e7          	jalr	156(ra) # 80003c9a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c06:	854a                	mv	a0,s2
    80004c08:	70a2                	ld	ra,40(sp)
    80004c0a:	7402                	ld	s0,32(sp)
    80004c0c:	64e2                	ld	s1,24(sp)
    80004c0e:	6942                	ld	s2,16(sp)
    80004c10:	69a2                	ld	s3,8(sp)
    80004c12:	6145                	addi	sp,sp,48
    80004c14:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c16:	6908                	ld	a0,16(a0)
    80004c18:	00000097          	auipc	ra,0x0
    80004c1c:	3c6080e7          	jalr	966(ra) # 80004fde <piperead>
    80004c20:	892a                	mv	s2,a0
    80004c22:	b7d5                	j	80004c06 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c24:	02451783          	lh	a5,36(a0)
    80004c28:	03079693          	slli	a3,a5,0x30
    80004c2c:	92c1                	srli	a3,a3,0x30
    80004c2e:	4725                	li	a4,9
    80004c30:	02d76863          	bltu	a4,a3,80004c60 <fileread+0xba>
    80004c34:	0792                	slli	a5,a5,0x4
    80004c36:	0001c717          	auipc	a4,0x1c
    80004c3a:	11270713          	addi	a4,a4,274 # 80020d48 <devsw>
    80004c3e:	97ba                	add	a5,a5,a4
    80004c40:	639c                	ld	a5,0(a5)
    80004c42:	c38d                	beqz	a5,80004c64 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c44:	4505                	li	a0,1
    80004c46:	9782                	jalr	a5
    80004c48:	892a                	mv	s2,a0
    80004c4a:	bf75                	j	80004c06 <fileread+0x60>
    panic("fileread");
    80004c4c:	00004517          	auipc	a0,0x4
    80004c50:	b9450513          	addi	a0,a0,-1132 # 800087e0 <syscalls+0x280>
    80004c54:	ffffc097          	auipc	ra,0xffffc
    80004c58:	8ec080e7          	jalr	-1812(ra) # 80000540 <panic>
    return -1;
    80004c5c:	597d                	li	s2,-1
    80004c5e:	b765                	j	80004c06 <fileread+0x60>
      return -1;
    80004c60:	597d                	li	s2,-1
    80004c62:	b755                	j	80004c06 <fileread+0x60>
    80004c64:	597d                	li	s2,-1
    80004c66:	b745                	j	80004c06 <fileread+0x60>

0000000080004c68 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c68:	715d                	addi	sp,sp,-80
    80004c6a:	e486                	sd	ra,72(sp)
    80004c6c:	e0a2                	sd	s0,64(sp)
    80004c6e:	fc26                	sd	s1,56(sp)
    80004c70:	f84a                	sd	s2,48(sp)
    80004c72:	f44e                	sd	s3,40(sp)
    80004c74:	f052                	sd	s4,32(sp)
    80004c76:	ec56                	sd	s5,24(sp)
    80004c78:	e85a                	sd	s6,16(sp)
    80004c7a:	e45e                	sd	s7,8(sp)
    80004c7c:	e062                	sd	s8,0(sp)
    80004c7e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c80:	00954783          	lbu	a5,9(a0)
    80004c84:	10078663          	beqz	a5,80004d90 <filewrite+0x128>
    80004c88:	892a                	mv	s2,a0
    80004c8a:	8b2e                	mv	s6,a1
    80004c8c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c8e:	411c                	lw	a5,0(a0)
    80004c90:	4705                	li	a4,1
    80004c92:	02e78263          	beq	a5,a4,80004cb6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c96:	470d                	li	a4,3
    80004c98:	02e78663          	beq	a5,a4,80004cc4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c9c:	4709                	li	a4,2
    80004c9e:	0ee79163          	bne	a5,a4,80004d80 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ca2:	0ac05d63          	blez	a2,80004d5c <filewrite+0xf4>
    int i = 0;
    80004ca6:	4981                	li	s3,0
    80004ca8:	6b85                	lui	s7,0x1
    80004caa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004cae:	6c05                	lui	s8,0x1
    80004cb0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004cb4:	a861                	j	80004d4c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cb6:	6908                	ld	a0,16(a0)
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	22e080e7          	jalr	558(ra) # 80004ee6 <pipewrite>
    80004cc0:	8a2a                	mv	s4,a0
    80004cc2:	a045                	j	80004d62 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cc4:	02451783          	lh	a5,36(a0)
    80004cc8:	03079693          	slli	a3,a5,0x30
    80004ccc:	92c1                	srli	a3,a3,0x30
    80004cce:	4725                	li	a4,9
    80004cd0:	0cd76263          	bltu	a4,a3,80004d94 <filewrite+0x12c>
    80004cd4:	0792                	slli	a5,a5,0x4
    80004cd6:	0001c717          	auipc	a4,0x1c
    80004cda:	07270713          	addi	a4,a4,114 # 80020d48 <devsw>
    80004cde:	97ba                	add	a5,a5,a4
    80004ce0:	679c                	ld	a5,8(a5)
    80004ce2:	cbdd                	beqz	a5,80004d98 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ce4:	4505                	li	a0,1
    80004ce6:	9782                	jalr	a5
    80004ce8:	8a2a                	mv	s4,a0
    80004cea:	a8a5                	j	80004d62 <filewrite+0xfa>
    80004cec:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cf0:	00000097          	auipc	ra,0x0
    80004cf4:	8b4080e7          	jalr	-1868(ra) # 800045a4 <begin_op>
      ilock(f->ip);
    80004cf8:	01893503          	ld	a0,24(s2)
    80004cfc:	fffff097          	auipc	ra,0xfffff
    80004d00:	edc080e7          	jalr	-292(ra) # 80003bd8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d04:	8756                	mv	a4,s5
    80004d06:	02092683          	lw	a3,32(s2)
    80004d0a:	01698633          	add	a2,s3,s6
    80004d0e:	4585                	li	a1,1
    80004d10:	01893503          	ld	a0,24(s2)
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	270080e7          	jalr	624(ra) # 80003f84 <writei>
    80004d1c:	84aa                	mv	s1,a0
    80004d1e:	00a05763          	blez	a0,80004d2c <filewrite+0xc4>
        f->off += r;
    80004d22:	02092783          	lw	a5,32(s2)
    80004d26:	9fa9                	addw	a5,a5,a0
    80004d28:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d2c:	01893503          	ld	a0,24(s2)
    80004d30:	fffff097          	auipc	ra,0xfffff
    80004d34:	f6a080e7          	jalr	-150(ra) # 80003c9a <iunlock>
      end_op();
    80004d38:	00000097          	auipc	ra,0x0
    80004d3c:	8ea080e7          	jalr	-1814(ra) # 80004622 <end_op>

      if(r != n1){
    80004d40:	009a9f63          	bne	s5,s1,80004d5e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d44:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d48:	0149db63          	bge	s3,s4,80004d5e <filewrite+0xf6>
      int n1 = n - i;
    80004d4c:	413a04bb          	subw	s1,s4,s3
    80004d50:	0004879b          	sext.w	a5,s1
    80004d54:	f8fbdce3          	bge	s7,a5,80004cec <filewrite+0x84>
    80004d58:	84e2                	mv	s1,s8
    80004d5a:	bf49                	j	80004cec <filewrite+0x84>
    int i = 0;
    80004d5c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d5e:	013a1f63          	bne	s4,s3,80004d7c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d62:	8552                	mv	a0,s4
    80004d64:	60a6                	ld	ra,72(sp)
    80004d66:	6406                	ld	s0,64(sp)
    80004d68:	74e2                	ld	s1,56(sp)
    80004d6a:	7942                	ld	s2,48(sp)
    80004d6c:	79a2                	ld	s3,40(sp)
    80004d6e:	7a02                	ld	s4,32(sp)
    80004d70:	6ae2                	ld	s5,24(sp)
    80004d72:	6b42                	ld	s6,16(sp)
    80004d74:	6ba2                	ld	s7,8(sp)
    80004d76:	6c02                	ld	s8,0(sp)
    80004d78:	6161                	addi	sp,sp,80
    80004d7a:	8082                	ret
    ret = (i == n ? n : -1);
    80004d7c:	5a7d                	li	s4,-1
    80004d7e:	b7d5                	j	80004d62 <filewrite+0xfa>
    panic("filewrite");
    80004d80:	00004517          	auipc	a0,0x4
    80004d84:	a7050513          	addi	a0,a0,-1424 # 800087f0 <syscalls+0x290>
    80004d88:	ffffb097          	auipc	ra,0xffffb
    80004d8c:	7b8080e7          	jalr	1976(ra) # 80000540 <panic>
    return -1;
    80004d90:	5a7d                	li	s4,-1
    80004d92:	bfc1                	j	80004d62 <filewrite+0xfa>
      return -1;
    80004d94:	5a7d                	li	s4,-1
    80004d96:	b7f1                	j	80004d62 <filewrite+0xfa>
    80004d98:	5a7d                	li	s4,-1
    80004d9a:	b7e1                	j	80004d62 <filewrite+0xfa>

0000000080004d9c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d9c:	7179                	addi	sp,sp,-48
    80004d9e:	f406                	sd	ra,40(sp)
    80004da0:	f022                	sd	s0,32(sp)
    80004da2:	ec26                	sd	s1,24(sp)
    80004da4:	e84a                	sd	s2,16(sp)
    80004da6:	e44e                	sd	s3,8(sp)
    80004da8:	e052                	sd	s4,0(sp)
    80004daa:	1800                	addi	s0,sp,48
    80004dac:	84aa                	mv	s1,a0
    80004dae:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004db0:	0005b023          	sd	zero,0(a1)
    80004db4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004db8:	00000097          	auipc	ra,0x0
    80004dbc:	bf8080e7          	jalr	-1032(ra) # 800049b0 <filealloc>
    80004dc0:	e088                	sd	a0,0(s1)
    80004dc2:	c551                	beqz	a0,80004e4e <pipealloc+0xb2>
    80004dc4:	00000097          	auipc	ra,0x0
    80004dc8:	bec080e7          	jalr	-1044(ra) # 800049b0 <filealloc>
    80004dcc:	00aa3023          	sd	a0,0(s4)
    80004dd0:	c92d                	beqz	a0,80004e42 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	d90080e7          	jalr	-624(ra) # 80000b62 <kalloc>
    80004dda:	892a                	mv	s2,a0
    80004ddc:	c125                	beqz	a0,80004e3c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004dde:	4985                	li	s3,1
    80004de0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004de4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004de8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004dec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004df0:	00004597          	auipc	a1,0x4
    80004df4:	a1058593          	addi	a1,a1,-1520 # 80008800 <syscalls+0x2a0>
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	e16080e7          	jalr	-490(ra) # 80000c0e <initlock>
  (*f0)->type = FD_PIPE;
    80004e00:	609c                	ld	a5,0(s1)
    80004e02:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e06:	609c                	ld	a5,0(s1)
    80004e08:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e0c:	609c                	ld	a5,0(s1)
    80004e0e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e12:	609c                	ld	a5,0(s1)
    80004e14:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e18:	000a3783          	ld	a5,0(s4)
    80004e1c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e20:	000a3783          	ld	a5,0(s4)
    80004e24:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e28:	000a3783          	ld	a5,0(s4)
    80004e2c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e30:	000a3783          	ld	a5,0(s4)
    80004e34:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e38:	4501                	li	a0,0
    80004e3a:	a025                	j	80004e62 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e3c:	6088                	ld	a0,0(s1)
    80004e3e:	e501                	bnez	a0,80004e46 <pipealloc+0xaa>
    80004e40:	a039                	j	80004e4e <pipealloc+0xb2>
    80004e42:	6088                	ld	a0,0(s1)
    80004e44:	c51d                	beqz	a0,80004e72 <pipealloc+0xd6>
    fileclose(*f0);
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	c26080e7          	jalr	-986(ra) # 80004a6c <fileclose>
  if(*f1)
    80004e4e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e52:	557d                	li	a0,-1
  if(*f1)
    80004e54:	c799                	beqz	a5,80004e62 <pipealloc+0xc6>
    fileclose(*f1);
    80004e56:	853e                	mv	a0,a5
    80004e58:	00000097          	auipc	ra,0x0
    80004e5c:	c14080e7          	jalr	-1004(ra) # 80004a6c <fileclose>
  return -1;
    80004e60:	557d                	li	a0,-1
}
    80004e62:	70a2                	ld	ra,40(sp)
    80004e64:	7402                	ld	s0,32(sp)
    80004e66:	64e2                	ld	s1,24(sp)
    80004e68:	6942                	ld	s2,16(sp)
    80004e6a:	69a2                	ld	s3,8(sp)
    80004e6c:	6a02                	ld	s4,0(sp)
    80004e6e:	6145                	addi	sp,sp,48
    80004e70:	8082                	ret
  return -1;
    80004e72:	557d                	li	a0,-1
    80004e74:	b7fd                	j	80004e62 <pipealloc+0xc6>

0000000080004e76 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e76:	1101                	addi	sp,sp,-32
    80004e78:	ec06                	sd	ra,24(sp)
    80004e7a:	e822                	sd	s0,16(sp)
    80004e7c:	e426                	sd	s1,8(sp)
    80004e7e:	e04a                	sd	s2,0(sp)
    80004e80:	1000                	addi	s0,sp,32
    80004e82:	84aa                	mv	s1,a0
    80004e84:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	e18080e7          	jalr	-488(ra) # 80000c9e <acquire>
  if(writable){
    80004e8e:	02090d63          	beqz	s2,80004ec8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e92:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e96:	21848513          	addi	a0,s1,536
    80004e9a:	ffffd097          	auipc	ra,0xffffd
    80004e9e:	546080e7          	jalr	1350(ra) # 800023e0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ea2:	2204b783          	ld	a5,544(s1)
    80004ea6:	eb95                	bnez	a5,80004eda <pipeclose+0x64>
    release(&pi->lock);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	ffffc097          	auipc	ra,0xffffc
    80004eae:	ea8080e7          	jalr	-344(ra) # 80000d52 <release>
    kfree((char*)pi);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	b46080e7          	jalr	-1210(ra) # 800009fa <kfree>
  } else
    release(&pi->lock);
}
    80004ebc:	60e2                	ld	ra,24(sp)
    80004ebe:	6442                	ld	s0,16(sp)
    80004ec0:	64a2                	ld	s1,8(sp)
    80004ec2:	6902                	ld	s2,0(sp)
    80004ec4:	6105                	addi	sp,sp,32
    80004ec6:	8082                	ret
    pi->readopen = 0;
    80004ec8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ecc:	21c48513          	addi	a0,s1,540
    80004ed0:	ffffd097          	auipc	ra,0xffffd
    80004ed4:	510080e7          	jalr	1296(ra) # 800023e0 <wakeup>
    80004ed8:	b7e9                	j	80004ea2 <pipeclose+0x2c>
    release(&pi->lock);
    80004eda:	8526                	mv	a0,s1
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	e76080e7          	jalr	-394(ra) # 80000d52 <release>
}
    80004ee4:	bfe1                	j	80004ebc <pipeclose+0x46>

0000000080004ee6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ee6:	711d                	addi	sp,sp,-96
    80004ee8:	ec86                	sd	ra,88(sp)
    80004eea:	e8a2                	sd	s0,80(sp)
    80004eec:	e4a6                	sd	s1,72(sp)
    80004eee:	e0ca                	sd	s2,64(sp)
    80004ef0:	fc4e                	sd	s3,56(sp)
    80004ef2:	f852                	sd	s4,48(sp)
    80004ef4:	f456                	sd	s5,40(sp)
    80004ef6:	f05a                	sd	s6,32(sp)
    80004ef8:	ec5e                	sd	s7,24(sp)
    80004efa:	e862                	sd	s8,16(sp)
    80004efc:	1080                	addi	s0,sp,96
    80004efe:	84aa                	mv	s1,a0
    80004f00:	8aae                	mv	s5,a1
    80004f02:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f04:	ffffd097          	auipc	ra,0xffffd
    80004f08:	cca080e7          	jalr	-822(ra) # 80001bce <myproc>
    80004f0c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f0e:	8526                	mv	a0,s1
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	d8e080e7          	jalr	-626(ra) # 80000c9e <acquire>
  while(i < n){
    80004f18:	0b405663          	blez	s4,80004fc4 <pipewrite+0xde>
  int i = 0;
    80004f1c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f1e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f20:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f24:	21c48b93          	addi	s7,s1,540
    80004f28:	a089                	j	80004f6a <pipewrite+0x84>
      release(&pi->lock);
    80004f2a:	8526                	mv	a0,s1
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	e26080e7          	jalr	-474(ra) # 80000d52 <release>
      return -1;
    80004f34:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f36:	854a                	mv	a0,s2
    80004f38:	60e6                	ld	ra,88(sp)
    80004f3a:	6446                	ld	s0,80(sp)
    80004f3c:	64a6                	ld	s1,72(sp)
    80004f3e:	6906                	ld	s2,64(sp)
    80004f40:	79e2                	ld	s3,56(sp)
    80004f42:	7a42                	ld	s4,48(sp)
    80004f44:	7aa2                	ld	s5,40(sp)
    80004f46:	7b02                	ld	s6,32(sp)
    80004f48:	6be2                	ld	s7,24(sp)
    80004f4a:	6c42                	ld	s8,16(sp)
    80004f4c:	6125                	addi	sp,sp,96
    80004f4e:	8082                	ret
      wakeup(&pi->nread);
    80004f50:	8562                	mv	a0,s8
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	48e080e7          	jalr	1166(ra) # 800023e0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f5a:	85a6                	mv	a1,s1
    80004f5c:	855e                	mv	a0,s7
    80004f5e:	ffffd097          	auipc	ra,0xffffd
    80004f62:	41e080e7          	jalr	1054(ra) # 8000237c <sleep>
  while(i < n){
    80004f66:	07495063          	bge	s2,s4,80004fc6 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f6a:	2204a783          	lw	a5,544(s1)
    80004f6e:	dfd5                	beqz	a5,80004f2a <pipewrite+0x44>
    80004f70:	854e                	mv	a0,s3
    80004f72:	ffffd097          	auipc	ra,0xffffd
    80004f76:	6b2080e7          	jalr	1714(ra) # 80002624 <killed>
    80004f7a:	f945                	bnez	a0,80004f2a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f7c:	2184a783          	lw	a5,536(s1)
    80004f80:	21c4a703          	lw	a4,540(s1)
    80004f84:	2007879b          	addiw	a5,a5,512
    80004f88:	fcf704e3          	beq	a4,a5,80004f50 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f8c:	4685                	li	a3,1
    80004f8e:	01590633          	add	a2,s2,s5
    80004f92:	faf40593          	addi	a1,s0,-81
    80004f96:	0509b503          	ld	a0,80(s3)
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	826080e7          	jalr	-2010(ra) # 800017c0 <copyin>
    80004fa2:	03650263          	beq	a0,s6,80004fc6 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fa6:	21c4a783          	lw	a5,540(s1)
    80004faa:	0017871b          	addiw	a4,a5,1
    80004fae:	20e4ae23          	sw	a4,540(s1)
    80004fb2:	1ff7f793          	andi	a5,a5,511
    80004fb6:	97a6                	add	a5,a5,s1
    80004fb8:	faf44703          	lbu	a4,-81(s0)
    80004fbc:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fc0:	2905                	addiw	s2,s2,1
    80004fc2:	b755                	j	80004f66 <pipewrite+0x80>
  int i = 0;
    80004fc4:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004fc6:	21848513          	addi	a0,s1,536
    80004fca:	ffffd097          	auipc	ra,0xffffd
    80004fce:	416080e7          	jalr	1046(ra) # 800023e0 <wakeup>
  release(&pi->lock);
    80004fd2:	8526                	mv	a0,s1
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	d7e080e7          	jalr	-642(ra) # 80000d52 <release>
  return i;
    80004fdc:	bfa9                	j	80004f36 <pipewrite+0x50>

0000000080004fde <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fde:	715d                	addi	sp,sp,-80
    80004fe0:	e486                	sd	ra,72(sp)
    80004fe2:	e0a2                	sd	s0,64(sp)
    80004fe4:	fc26                	sd	s1,56(sp)
    80004fe6:	f84a                	sd	s2,48(sp)
    80004fe8:	f44e                	sd	s3,40(sp)
    80004fea:	f052                	sd	s4,32(sp)
    80004fec:	ec56                	sd	s5,24(sp)
    80004fee:	e85a                	sd	s6,16(sp)
    80004ff0:	0880                	addi	s0,sp,80
    80004ff2:	84aa                	mv	s1,a0
    80004ff4:	892e                	mv	s2,a1
    80004ff6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ff8:	ffffd097          	auipc	ra,0xffffd
    80004ffc:	bd6080e7          	jalr	-1066(ra) # 80001bce <myproc>
    80005000:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005002:	8526                	mv	a0,s1
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	c9a080e7          	jalr	-870(ra) # 80000c9e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000500c:	2184a703          	lw	a4,536(s1)
    80005010:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005014:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005018:	02f71763          	bne	a4,a5,80005046 <piperead+0x68>
    8000501c:	2244a783          	lw	a5,548(s1)
    80005020:	c39d                	beqz	a5,80005046 <piperead+0x68>
    if(killed(pr)){
    80005022:	8552                	mv	a0,s4
    80005024:	ffffd097          	auipc	ra,0xffffd
    80005028:	600080e7          	jalr	1536(ra) # 80002624 <killed>
    8000502c:	e949                	bnez	a0,800050be <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000502e:	85a6                	mv	a1,s1
    80005030:	854e                	mv	a0,s3
    80005032:	ffffd097          	auipc	ra,0xffffd
    80005036:	34a080e7          	jalr	842(ra) # 8000237c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000503a:	2184a703          	lw	a4,536(s1)
    8000503e:	21c4a783          	lw	a5,540(s1)
    80005042:	fcf70de3          	beq	a4,a5,8000501c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005046:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005048:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000504a:	05505463          	blez	s5,80005092 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    8000504e:	2184a783          	lw	a5,536(s1)
    80005052:	21c4a703          	lw	a4,540(s1)
    80005056:	02f70e63          	beq	a4,a5,80005092 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000505a:	0017871b          	addiw	a4,a5,1
    8000505e:	20e4ac23          	sw	a4,536(s1)
    80005062:	1ff7f793          	andi	a5,a5,511
    80005066:	97a6                	add	a5,a5,s1
    80005068:	0187c783          	lbu	a5,24(a5)
    8000506c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005070:	4685                	li	a3,1
    80005072:	fbf40613          	addi	a2,s0,-65
    80005076:	85ca                	mv	a1,s2
    80005078:	050a3503          	ld	a0,80(s4)
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	6b8080e7          	jalr	1720(ra) # 80001734 <copyout>
    80005084:	01650763          	beq	a0,s6,80005092 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005088:	2985                	addiw	s3,s3,1
    8000508a:	0905                	addi	s2,s2,1
    8000508c:	fd3a91e3          	bne	s5,s3,8000504e <piperead+0x70>
    80005090:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005092:	21c48513          	addi	a0,s1,540
    80005096:	ffffd097          	auipc	ra,0xffffd
    8000509a:	34a080e7          	jalr	842(ra) # 800023e0 <wakeup>
  release(&pi->lock);
    8000509e:	8526                	mv	a0,s1
    800050a0:	ffffc097          	auipc	ra,0xffffc
    800050a4:	cb2080e7          	jalr	-846(ra) # 80000d52 <release>
  return i;
}
    800050a8:	854e                	mv	a0,s3
    800050aa:	60a6                	ld	ra,72(sp)
    800050ac:	6406                	ld	s0,64(sp)
    800050ae:	74e2                	ld	s1,56(sp)
    800050b0:	7942                	ld	s2,48(sp)
    800050b2:	79a2                	ld	s3,40(sp)
    800050b4:	7a02                	ld	s4,32(sp)
    800050b6:	6ae2                	ld	s5,24(sp)
    800050b8:	6b42                	ld	s6,16(sp)
    800050ba:	6161                	addi	sp,sp,80
    800050bc:	8082                	ret
      release(&pi->lock);
    800050be:	8526                	mv	a0,s1
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	c92080e7          	jalr	-878(ra) # 80000d52 <release>
      return -1;
    800050c8:	59fd                	li	s3,-1
    800050ca:	bff9                	j	800050a8 <piperead+0xca>

00000000800050cc <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050cc:	1141                	addi	sp,sp,-16
    800050ce:	e422                	sd	s0,8(sp)
    800050d0:	0800                	addi	s0,sp,16
    800050d2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050d4:	8905                	andi	a0,a0,1
    800050d6:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800050d8:	8b89                	andi	a5,a5,2
    800050da:	c399                	beqz	a5,800050e0 <flags2perm+0x14>
      perm |= PTE_W;
    800050dc:	00456513          	ori	a0,a0,4
    return perm;
}
    800050e0:	6422                	ld	s0,8(sp)
    800050e2:	0141                	addi	sp,sp,16
    800050e4:	8082                	ret

00000000800050e6 <exec>:

int
exec(char *path, char **argv)
{
    800050e6:	de010113          	addi	sp,sp,-544
    800050ea:	20113c23          	sd	ra,536(sp)
    800050ee:	20813823          	sd	s0,528(sp)
    800050f2:	20913423          	sd	s1,520(sp)
    800050f6:	21213023          	sd	s2,512(sp)
    800050fa:	ffce                	sd	s3,504(sp)
    800050fc:	fbd2                	sd	s4,496(sp)
    800050fe:	f7d6                	sd	s5,488(sp)
    80005100:	f3da                	sd	s6,480(sp)
    80005102:	efde                	sd	s7,472(sp)
    80005104:	ebe2                	sd	s8,464(sp)
    80005106:	e7e6                	sd	s9,456(sp)
    80005108:	e3ea                	sd	s10,448(sp)
    8000510a:	ff6e                	sd	s11,440(sp)
    8000510c:	1400                	addi	s0,sp,544
    8000510e:	892a                	mv	s2,a0
    80005110:	dea43423          	sd	a0,-536(s0)
    80005114:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005118:	ffffd097          	auipc	ra,0xffffd
    8000511c:	ab6080e7          	jalr	-1354(ra) # 80001bce <myproc>
    80005120:	84aa                	mv	s1,a0

  begin_op();
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	482080e7          	jalr	1154(ra) # 800045a4 <begin_op>

  if((ip = namei(path)) == 0){
    8000512a:	854a                	mv	a0,s2
    8000512c:	fffff097          	auipc	ra,0xfffff
    80005130:	258080e7          	jalr	600(ra) # 80004384 <namei>
    80005134:	c93d                	beqz	a0,800051aa <exec+0xc4>
    80005136:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	aa0080e7          	jalr	-1376(ra) # 80003bd8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005140:	04000713          	li	a4,64
    80005144:	4681                	li	a3,0
    80005146:	e5040613          	addi	a2,s0,-432
    8000514a:	4581                	li	a1,0
    8000514c:	8556                	mv	a0,s5
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	d3e080e7          	jalr	-706(ra) # 80003e8c <readi>
    80005156:	04000793          	li	a5,64
    8000515a:	00f51a63          	bne	a0,a5,8000516e <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000515e:	e5042703          	lw	a4,-432(s0)
    80005162:	464c47b7          	lui	a5,0x464c4
    80005166:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000516a:	04f70663          	beq	a4,a5,800051b6 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000516e:	8556                	mv	a0,s5
    80005170:	fffff097          	auipc	ra,0xfffff
    80005174:	cca080e7          	jalr	-822(ra) # 80003e3a <iunlockput>
    end_op();
    80005178:	fffff097          	auipc	ra,0xfffff
    8000517c:	4aa080e7          	jalr	1194(ra) # 80004622 <end_op>
  }
  return -1;
    80005180:	557d                	li	a0,-1
}
    80005182:	21813083          	ld	ra,536(sp)
    80005186:	21013403          	ld	s0,528(sp)
    8000518a:	20813483          	ld	s1,520(sp)
    8000518e:	20013903          	ld	s2,512(sp)
    80005192:	79fe                	ld	s3,504(sp)
    80005194:	7a5e                	ld	s4,496(sp)
    80005196:	7abe                	ld	s5,488(sp)
    80005198:	7b1e                	ld	s6,480(sp)
    8000519a:	6bfe                	ld	s7,472(sp)
    8000519c:	6c5e                	ld	s8,464(sp)
    8000519e:	6cbe                	ld	s9,456(sp)
    800051a0:	6d1e                	ld	s10,448(sp)
    800051a2:	7dfa                	ld	s11,440(sp)
    800051a4:	22010113          	addi	sp,sp,544
    800051a8:	8082                	ret
    end_op();
    800051aa:	fffff097          	auipc	ra,0xfffff
    800051ae:	478080e7          	jalr	1144(ra) # 80004622 <end_op>
    return -1;
    800051b2:	557d                	li	a0,-1
    800051b4:	b7f9                	j	80005182 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051b6:	8526                	mv	a0,s1
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	ada080e7          	jalr	-1318(ra) # 80001c92 <proc_pagetable>
    800051c0:	8b2a                	mv	s6,a0
    800051c2:	d555                	beqz	a0,8000516e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051c4:	e7042783          	lw	a5,-400(s0)
    800051c8:	e8845703          	lhu	a4,-376(s0)
    800051cc:	c735                	beqz	a4,80005238 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051ce:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051d0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051d4:	6a05                	lui	s4,0x1
    800051d6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800051da:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800051de:	6d85                	lui	s11,0x1
    800051e0:	7d7d                	lui	s10,0xfffff
    800051e2:	ac3d                	j	80005420 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051e4:	00003517          	auipc	a0,0x3
    800051e8:	62450513          	addi	a0,a0,1572 # 80008808 <syscalls+0x2a8>
    800051ec:	ffffb097          	auipc	ra,0xffffb
    800051f0:	354080e7          	jalr	852(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051f4:	874a                	mv	a4,s2
    800051f6:	009c86bb          	addw	a3,s9,s1
    800051fa:	4581                	li	a1,0
    800051fc:	8556                	mv	a0,s5
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	c8e080e7          	jalr	-882(ra) # 80003e8c <readi>
    80005206:	2501                	sext.w	a0,a0
    80005208:	1aa91963          	bne	s2,a0,800053ba <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    8000520c:	009d84bb          	addw	s1,s11,s1
    80005210:	013d09bb          	addw	s3,s10,s3
    80005214:	1f74f663          	bgeu	s1,s7,80005400 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005218:	02049593          	slli	a1,s1,0x20
    8000521c:	9181                	srli	a1,a1,0x20
    8000521e:	95e2                	add	a1,a1,s8
    80005220:	855a                	mv	a0,s6
    80005222:	ffffc097          	auipc	ra,0xffffc
    80005226:	f02080e7          	jalr	-254(ra) # 80001124 <walkaddr>
    8000522a:	862a                	mv	a2,a0
    if(pa == 0)
    8000522c:	dd45                	beqz	a0,800051e4 <exec+0xfe>
      n = PGSIZE;
    8000522e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005230:	fd49f2e3          	bgeu	s3,s4,800051f4 <exec+0x10e>
      n = sz - i;
    80005234:	894e                	mv	s2,s3
    80005236:	bf7d                	j	800051f4 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005238:	4901                	li	s2,0
  iunlockput(ip);
    8000523a:	8556                	mv	a0,s5
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	bfe080e7          	jalr	-1026(ra) # 80003e3a <iunlockput>
  end_op();
    80005244:	fffff097          	auipc	ra,0xfffff
    80005248:	3de080e7          	jalr	990(ra) # 80004622 <end_op>
  p = myproc();
    8000524c:	ffffd097          	auipc	ra,0xffffd
    80005250:	982080e7          	jalr	-1662(ra) # 80001bce <myproc>
    80005254:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005256:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000525a:	6785                	lui	a5,0x1
    8000525c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000525e:	97ca                	add	a5,a5,s2
    80005260:	777d                	lui	a4,0xfffff
    80005262:	8ff9                	and	a5,a5,a4
    80005264:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005268:	4691                	li	a3,4
    8000526a:	6609                	lui	a2,0x2
    8000526c:	963e                	add	a2,a2,a5
    8000526e:	85be                	mv	a1,a5
    80005270:	855a                	mv	a0,s6
    80005272:	ffffc097          	auipc	ra,0xffffc
    80005276:	266080e7          	jalr	614(ra) # 800014d8 <uvmalloc>
    8000527a:	8c2a                	mv	s8,a0
  ip = 0;
    8000527c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000527e:	12050e63          	beqz	a0,800053ba <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005282:	75f9                	lui	a1,0xffffe
    80005284:	95aa                	add	a1,a1,a0
    80005286:	855a                	mv	a0,s6
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	47a080e7          	jalr	1146(ra) # 80001702 <uvmclear>
  stackbase = sp - PGSIZE;
    80005290:	7afd                	lui	s5,0xfffff
    80005292:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005294:	df043783          	ld	a5,-528(s0)
    80005298:	6388                	ld	a0,0(a5)
    8000529a:	c925                	beqz	a0,8000530a <exec+0x224>
    8000529c:	e9040993          	addi	s3,s0,-368
    800052a0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052a4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052a6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052a8:	ffffc097          	auipc	ra,0xffffc
    800052ac:	c6e080e7          	jalr	-914(ra) # 80000f16 <strlen>
    800052b0:	0015079b          	addiw	a5,a0,1
    800052b4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052b8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800052bc:	13596663          	bltu	s2,s5,800053e8 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052c0:	df043d83          	ld	s11,-528(s0)
    800052c4:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052c8:	8552                	mv	a0,s4
    800052ca:	ffffc097          	auipc	ra,0xffffc
    800052ce:	c4c080e7          	jalr	-948(ra) # 80000f16 <strlen>
    800052d2:	0015069b          	addiw	a3,a0,1
    800052d6:	8652                	mv	a2,s4
    800052d8:	85ca                	mv	a1,s2
    800052da:	855a                	mv	a0,s6
    800052dc:	ffffc097          	auipc	ra,0xffffc
    800052e0:	458080e7          	jalr	1112(ra) # 80001734 <copyout>
    800052e4:	10054663          	bltz	a0,800053f0 <exec+0x30a>
    ustack[argc] = sp;
    800052e8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052ec:	0485                	addi	s1,s1,1
    800052ee:	008d8793          	addi	a5,s11,8
    800052f2:	def43823          	sd	a5,-528(s0)
    800052f6:	008db503          	ld	a0,8(s11)
    800052fa:	c911                	beqz	a0,8000530e <exec+0x228>
    if(argc >= MAXARG)
    800052fc:	09a1                	addi	s3,s3,8
    800052fe:	fb3c95e3          	bne	s9,s3,800052a8 <exec+0x1c2>
  sz = sz1;
    80005302:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005306:	4a81                	li	s5,0
    80005308:	a84d                	j	800053ba <exec+0x2d4>
  sp = sz;
    8000530a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000530c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000530e:	00349793          	slli	a5,s1,0x3
    80005312:	f9078793          	addi	a5,a5,-112
    80005316:	97a2                	add	a5,a5,s0
    80005318:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000531c:	00148693          	addi	a3,s1,1
    80005320:	068e                	slli	a3,a3,0x3
    80005322:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005326:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000532a:	01597663          	bgeu	s2,s5,80005336 <exec+0x250>
  sz = sz1;
    8000532e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005332:	4a81                	li	s5,0
    80005334:	a059                	j	800053ba <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005336:	e9040613          	addi	a2,s0,-368
    8000533a:	85ca                	mv	a1,s2
    8000533c:	855a                	mv	a0,s6
    8000533e:	ffffc097          	auipc	ra,0xffffc
    80005342:	3f6080e7          	jalr	1014(ra) # 80001734 <copyout>
    80005346:	0a054963          	bltz	a0,800053f8 <exec+0x312>
  p->trapframe->a1 = sp;
    8000534a:	058bb783          	ld	a5,88(s7)
    8000534e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005352:	de843783          	ld	a5,-536(s0)
    80005356:	0007c703          	lbu	a4,0(a5)
    8000535a:	cf11                	beqz	a4,80005376 <exec+0x290>
    8000535c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000535e:	02f00693          	li	a3,47
    80005362:	a039                	j	80005370 <exec+0x28a>
      last = s+1;
    80005364:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005368:	0785                	addi	a5,a5,1
    8000536a:	fff7c703          	lbu	a4,-1(a5)
    8000536e:	c701                	beqz	a4,80005376 <exec+0x290>
    if(*s == '/')
    80005370:	fed71ce3          	bne	a4,a3,80005368 <exec+0x282>
    80005374:	bfc5                	j	80005364 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005376:	4641                	li	a2,16
    80005378:	de843583          	ld	a1,-536(s0)
    8000537c:	158b8513          	addi	a0,s7,344
    80005380:	ffffc097          	auipc	ra,0xffffc
    80005384:	b64080e7          	jalr	-1180(ra) # 80000ee4 <safestrcpy>
  oldpagetable = p->pagetable;
    80005388:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000538c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005390:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005394:	058bb783          	ld	a5,88(s7)
    80005398:	e6843703          	ld	a4,-408(s0)
    8000539c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000539e:	058bb783          	ld	a5,88(s7)
    800053a2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053a6:	85ea                	mv	a1,s10
    800053a8:	ffffd097          	auipc	ra,0xffffd
    800053ac:	986080e7          	jalr	-1658(ra) # 80001d2e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053b0:	0004851b          	sext.w	a0,s1
    800053b4:	b3f9                	j	80005182 <exec+0x9c>
    800053b6:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053ba:	df843583          	ld	a1,-520(s0)
    800053be:	855a                	mv	a0,s6
    800053c0:	ffffd097          	auipc	ra,0xffffd
    800053c4:	96e080e7          	jalr	-1682(ra) # 80001d2e <proc_freepagetable>
  if(ip){
    800053c8:	da0a93e3          	bnez	s5,8000516e <exec+0x88>
  return -1;
    800053cc:	557d                	li	a0,-1
    800053ce:	bb55                	j	80005182 <exec+0x9c>
    800053d0:	df243c23          	sd	s2,-520(s0)
    800053d4:	b7dd                	j	800053ba <exec+0x2d4>
    800053d6:	df243c23          	sd	s2,-520(s0)
    800053da:	b7c5                	j	800053ba <exec+0x2d4>
    800053dc:	df243c23          	sd	s2,-520(s0)
    800053e0:	bfe9                	j	800053ba <exec+0x2d4>
    800053e2:	df243c23          	sd	s2,-520(s0)
    800053e6:	bfd1                	j	800053ba <exec+0x2d4>
  sz = sz1;
    800053e8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053ec:	4a81                	li	s5,0
    800053ee:	b7f1                	j	800053ba <exec+0x2d4>
  sz = sz1;
    800053f0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053f4:	4a81                	li	s5,0
    800053f6:	b7d1                	j	800053ba <exec+0x2d4>
  sz = sz1;
    800053f8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053fc:	4a81                	li	s5,0
    800053fe:	bf75                	j	800053ba <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005400:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005404:	e0843783          	ld	a5,-504(s0)
    80005408:	0017869b          	addiw	a3,a5,1
    8000540c:	e0d43423          	sd	a3,-504(s0)
    80005410:	e0043783          	ld	a5,-512(s0)
    80005414:	0387879b          	addiw	a5,a5,56
    80005418:	e8845703          	lhu	a4,-376(s0)
    8000541c:	e0e6dfe3          	bge	a3,a4,8000523a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005420:	2781                	sext.w	a5,a5
    80005422:	e0f43023          	sd	a5,-512(s0)
    80005426:	03800713          	li	a4,56
    8000542a:	86be                	mv	a3,a5
    8000542c:	e1840613          	addi	a2,s0,-488
    80005430:	4581                	li	a1,0
    80005432:	8556                	mv	a0,s5
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	a58080e7          	jalr	-1448(ra) # 80003e8c <readi>
    8000543c:	03800793          	li	a5,56
    80005440:	f6f51be3          	bne	a0,a5,800053b6 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005444:	e1842783          	lw	a5,-488(s0)
    80005448:	4705                	li	a4,1
    8000544a:	fae79de3          	bne	a5,a4,80005404 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    8000544e:	e4043483          	ld	s1,-448(s0)
    80005452:	e3843783          	ld	a5,-456(s0)
    80005456:	f6f4ede3          	bltu	s1,a5,800053d0 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000545a:	e2843783          	ld	a5,-472(s0)
    8000545e:	94be                	add	s1,s1,a5
    80005460:	f6f4ebe3          	bltu	s1,a5,800053d6 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005464:	de043703          	ld	a4,-544(s0)
    80005468:	8ff9                	and	a5,a5,a4
    8000546a:	fbad                	bnez	a5,800053dc <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000546c:	e1c42503          	lw	a0,-484(s0)
    80005470:	00000097          	auipc	ra,0x0
    80005474:	c5c080e7          	jalr	-932(ra) # 800050cc <flags2perm>
    80005478:	86aa                	mv	a3,a0
    8000547a:	8626                	mv	a2,s1
    8000547c:	85ca                	mv	a1,s2
    8000547e:	855a                	mv	a0,s6
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	058080e7          	jalr	88(ra) # 800014d8 <uvmalloc>
    80005488:	dea43c23          	sd	a0,-520(s0)
    8000548c:	d939                	beqz	a0,800053e2 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000548e:	e2843c03          	ld	s8,-472(s0)
    80005492:	e2042c83          	lw	s9,-480(s0)
    80005496:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000549a:	f60b83e3          	beqz	s7,80005400 <exec+0x31a>
    8000549e:	89de                	mv	s3,s7
    800054a0:	4481                	li	s1,0
    800054a2:	bb9d                	j	80005218 <exec+0x132>

00000000800054a4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054a4:	7179                	addi	sp,sp,-48
    800054a6:	f406                	sd	ra,40(sp)
    800054a8:	f022                	sd	s0,32(sp)
    800054aa:	ec26                	sd	s1,24(sp)
    800054ac:	e84a                	sd	s2,16(sp)
    800054ae:	1800                	addi	s0,sp,48
    800054b0:	892e                	mv	s2,a1
    800054b2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054b4:	fdc40593          	addi	a1,s0,-36
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	a8a080e7          	jalr	-1398(ra) # 80002f42 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054c0:	fdc42703          	lw	a4,-36(s0)
    800054c4:	47bd                	li	a5,15
    800054c6:	02e7eb63          	bltu	a5,a4,800054fc <argfd+0x58>
    800054ca:	ffffc097          	auipc	ra,0xffffc
    800054ce:	704080e7          	jalr	1796(ra) # 80001bce <myproc>
    800054d2:	fdc42703          	lw	a4,-36(s0)
    800054d6:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd13a>
    800054da:	078e                	slli	a5,a5,0x3
    800054dc:	953e                	add	a0,a0,a5
    800054de:	611c                	ld	a5,0(a0)
    800054e0:	c385                	beqz	a5,80005500 <argfd+0x5c>
    return -1;
  if(pfd)
    800054e2:	00090463          	beqz	s2,800054ea <argfd+0x46>
    *pfd = fd;
    800054e6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054ea:	4501                	li	a0,0
  if(pf)
    800054ec:	c091                	beqz	s1,800054f0 <argfd+0x4c>
    *pf = f;
    800054ee:	e09c                	sd	a5,0(s1)
}
    800054f0:	70a2                	ld	ra,40(sp)
    800054f2:	7402                	ld	s0,32(sp)
    800054f4:	64e2                	ld	s1,24(sp)
    800054f6:	6942                	ld	s2,16(sp)
    800054f8:	6145                	addi	sp,sp,48
    800054fa:	8082                	ret
    return -1;
    800054fc:	557d                	li	a0,-1
    800054fe:	bfcd                	j	800054f0 <argfd+0x4c>
    80005500:	557d                	li	a0,-1
    80005502:	b7fd                	j	800054f0 <argfd+0x4c>

0000000080005504 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005504:	1101                	addi	sp,sp,-32
    80005506:	ec06                	sd	ra,24(sp)
    80005508:	e822                	sd	s0,16(sp)
    8000550a:	e426                	sd	s1,8(sp)
    8000550c:	1000                	addi	s0,sp,32
    8000550e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005510:	ffffc097          	auipc	ra,0xffffc
    80005514:	6be080e7          	jalr	1726(ra) # 80001bce <myproc>
    80005518:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000551a:	0d050793          	addi	a5,a0,208
    8000551e:	4501                	li	a0,0
    80005520:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005522:	6398                	ld	a4,0(a5)
    80005524:	cb19                	beqz	a4,8000553a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005526:	2505                	addiw	a0,a0,1
    80005528:	07a1                	addi	a5,a5,8
    8000552a:	fed51ce3          	bne	a0,a3,80005522 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000552e:	557d                	li	a0,-1
}
    80005530:	60e2                	ld	ra,24(sp)
    80005532:	6442                	ld	s0,16(sp)
    80005534:	64a2                	ld	s1,8(sp)
    80005536:	6105                	addi	sp,sp,32
    80005538:	8082                	ret
      p->ofile[fd] = f;
    8000553a:	01a50793          	addi	a5,a0,26
    8000553e:	078e                	slli	a5,a5,0x3
    80005540:	963e                	add	a2,a2,a5
    80005542:	e204                	sd	s1,0(a2)
      return fd;
    80005544:	b7f5                	j	80005530 <fdalloc+0x2c>

0000000080005546 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005546:	715d                	addi	sp,sp,-80
    80005548:	e486                	sd	ra,72(sp)
    8000554a:	e0a2                	sd	s0,64(sp)
    8000554c:	fc26                	sd	s1,56(sp)
    8000554e:	f84a                	sd	s2,48(sp)
    80005550:	f44e                	sd	s3,40(sp)
    80005552:	f052                	sd	s4,32(sp)
    80005554:	ec56                	sd	s5,24(sp)
    80005556:	e85a                	sd	s6,16(sp)
    80005558:	0880                	addi	s0,sp,80
    8000555a:	8b2e                	mv	s6,a1
    8000555c:	89b2                	mv	s3,a2
    8000555e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005560:	fb040593          	addi	a1,s0,-80
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	e3e080e7          	jalr	-450(ra) # 800043a2 <nameiparent>
    8000556c:	84aa                	mv	s1,a0
    8000556e:	14050f63          	beqz	a0,800056cc <create+0x186>
    return 0;

  ilock(dp);
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	666080e7          	jalr	1638(ra) # 80003bd8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000557a:	4601                	li	a2,0
    8000557c:	fb040593          	addi	a1,s0,-80
    80005580:	8526                	mv	a0,s1
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	b3a080e7          	jalr	-1222(ra) # 800040bc <dirlookup>
    8000558a:	8aaa                	mv	s5,a0
    8000558c:	c931                	beqz	a0,800055e0 <create+0x9a>
    iunlockput(dp);
    8000558e:	8526                	mv	a0,s1
    80005590:	fffff097          	auipc	ra,0xfffff
    80005594:	8aa080e7          	jalr	-1878(ra) # 80003e3a <iunlockput>
    ilock(ip);
    80005598:	8556                	mv	a0,s5
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	63e080e7          	jalr	1598(ra) # 80003bd8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055a2:	000b059b          	sext.w	a1,s6
    800055a6:	4789                	li	a5,2
    800055a8:	02f59563          	bne	a1,a5,800055d2 <create+0x8c>
    800055ac:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd164>
    800055b0:	37f9                	addiw	a5,a5,-2
    800055b2:	17c2                	slli	a5,a5,0x30
    800055b4:	93c1                	srli	a5,a5,0x30
    800055b6:	4705                	li	a4,1
    800055b8:	00f76d63          	bltu	a4,a5,800055d2 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055bc:	8556                	mv	a0,s5
    800055be:	60a6                	ld	ra,72(sp)
    800055c0:	6406                	ld	s0,64(sp)
    800055c2:	74e2                	ld	s1,56(sp)
    800055c4:	7942                	ld	s2,48(sp)
    800055c6:	79a2                	ld	s3,40(sp)
    800055c8:	7a02                	ld	s4,32(sp)
    800055ca:	6ae2                	ld	s5,24(sp)
    800055cc:	6b42                	ld	s6,16(sp)
    800055ce:	6161                	addi	sp,sp,80
    800055d0:	8082                	ret
    iunlockput(ip);
    800055d2:	8556                	mv	a0,s5
    800055d4:	fffff097          	auipc	ra,0xfffff
    800055d8:	866080e7          	jalr	-1946(ra) # 80003e3a <iunlockput>
    return 0;
    800055dc:	4a81                	li	s5,0
    800055de:	bff9                	j	800055bc <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055e0:	85da                	mv	a1,s6
    800055e2:	4088                	lw	a0,0(s1)
    800055e4:	ffffe097          	auipc	ra,0xffffe
    800055e8:	456080e7          	jalr	1110(ra) # 80003a3a <ialloc>
    800055ec:	8a2a                	mv	s4,a0
    800055ee:	c539                	beqz	a0,8000563c <create+0xf6>
  ilock(ip);
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	5e8080e7          	jalr	1512(ra) # 80003bd8 <ilock>
  ip->major = major;
    800055f8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800055fc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005600:	4905                	li	s2,1
    80005602:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005606:	8552                	mv	a0,s4
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	504080e7          	jalr	1284(ra) # 80003b0c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005610:	000b059b          	sext.w	a1,s6
    80005614:	03258b63          	beq	a1,s2,8000564a <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005618:	004a2603          	lw	a2,4(s4)
    8000561c:	fb040593          	addi	a1,s0,-80
    80005620:	8526                	mv	a0,s1
    80005622:	fffff097          	auipc	ra,0xfffff
    80005626:	cb0080e7          	jalr	-848(ra) # 800042d2 <dirlink>
    8000562a:	06054f63          	bltz	a0,800056a8 <create+0x162>
  iunlockput(dp);
    8000562e:	8526                	mv	a0,s1
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	80a080e7          	jalr	-2038(ra) # 80003e3a <iunlockput>
  return ip;
    80005638:	8ad2                	mv	s5,s4
    8000563a:	b749                	j	800055bc <create+0x76>
    iunlockput(dp);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	7fc080e7          	jalr	2044(ra) # 80003e3a <iunlockput>
    return 0;
    80005646:	8ad2                	mv	s5,s4
    80005648:	bf95                	j	800055bc <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000564a:	004a2603          	lw	a2,4(s4)
    8000564e:	00003597          	auipc	a1,0x3
    80005652:	1da58593          	addi	a1,a1,474 # 80008828 <syscalls+0x2c8>
    80005656:	8552                	mv	a0,s4
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	c7a080e7          	jalr	-902(ra) # 800042d2 <dirlink>
    80005660:	04054463          	bltz	a0,800056a8 <create+0x162>
    80005664:	40d0                	lw	a2,4(s1)
    80005666:	00003597          	auipc	a1,0x3
    8000566a:	1ca58593          	addi	a1,a1,458 # 80008830 <syscalls+0x2d0>
    8000566e:	8552                	mv	a0,s4
    80005670:	fffff097          	auipc	ra,0xfffff
    80005674:	c62080e7          	jalr	-926(ra) # 800042d2 <dirlink>
    80005678:	02054863          	bltz	a0,800056a8 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000567c:	004a2603          	lw	a2,4(s4)
    80005680:	fb040593          	addi	a1,s0,-80
    80005684:	8526                	mv	a0,s1
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	c4c080e7          	jalr	-948(ra) # 800042d2 <dirlink>
    8000568e:	00054d63          	bltz	a0,800056a8 <create+0x162>
    dp->nlink++;  // for ".."
    80005692:	04a4d783          	lhu	a5,74(s1)
    80005696:	2785                	addiw	a5,a5,1
    80005698:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	46e080e7          	jalr	1134(ra) # 80003b0c <iupdate>
    800056a6:	b761                	j	8000562e <create+0xe8>
  ip->nlink = 0;
    800056a8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056ac:	8552                	mv	a0,s4
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	45e080e7          	jalr	1118(ra) # 80003b0c <iupdate>
  iunlockput(ip);
    800056b6:	8552                	mv	a0,s4
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	782080e7          	jalr	1922(ra) # 80003e3a <iunlockput>
  iunlockput(dp);
    800056c0:	8526                	mv	a0,s1
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	778080e7          	jalr	1912(ra) # 80003e3a <iunlockput>
  return 0;
    800056ca:	bdcd                	j	800055bc <create+0x76>
    return 0;
    800056cc:	8aaa                	mv	s5,a0
    800056ce:	b5fd                	j	800055bc <create+0x76>

00000000800056d0 <sys_dup>:
{
    800056d0:	7179                	addi	sp,sp,-48
    800056d2:	f406                	sd	ra,40(sp)
    800056d4:	f022                	sd	s0,32(sp)
    800056d6:	ec26                	sd	s1,24(sp)
    800056d8:	e84a                	sd	s2,16(sp)
    800056da:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056dc:	fd840613          	addi	a2,s0,-40
    800056e0:	4581                	li	a1,0
    800056e2:	4501                	li	a0,0
    800056e4:	00000097          	auipc	ra,0x0
    800056e8:	dc0080e7          	jalr	-576(ra) # 800054a4 <argfd>
    return -1;
    800056ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056ee:	02054363          	bltz	a0,80005714 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800056f2:	fd843903          	ld	s2,-40(s0)
    800056f6:	854a                	mv	a0,s2
    800056f8:	00000097          	auipc	ra,0x0
    800056fc:	e0c080e7          	jalr	-500(ra) # 80005504 <fdalloc>
    80005700:	84aa                	mv	s1,a0
    return -1;
    80005702:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005704:	00054863          	bltz	a0,80005714 <sys_dup+0x44>
  filedup(f);
    80005708:	854a                	mv	a0,s2
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	310080e7          	jalr	784(ra) # 80004a1a <filedup>
  return fd;
    80005712:	87a6                	mv	a5,s1
}
    80005714:	853e                	mv	a0,a5
    80005716:	70a2                	ld	ra,40(sp)
    80005718:	7402                	ld	s0,32(sp)
    8000571a:	64e2                	ld	s1,24(sp)
    8000571c:	6942                	ld	s2,16(sp)
    8000571e:	6145                	addi	sp,sp,48
    80005720:	8082                	ret

0000000080005722 <sys_read>:
{
    80005722:	7179                	addi	sp,sp,-48
    80005724:	f406                	sd	ra,40(sp)
    80005726:	f022                	sd	s0,32(sp)
    80005728:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000572a:	fd840593          	addi	a1,s0,-40
    8000572e:	4505                	li	a0,1
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	832080e7          	jalr	-1998(ra) # 80002f62 <argaddr>
  argint(2, &n);
    80005738:	fe440593          	addi	a1,s0,-28
    8000573c:	4509                	li	a0,2
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	804080e7          	jalr	-2044(ra) # 80002f42 <argint>
  if(argfd(0, 0, &f) < 0)
    80005746:	fe840613          	addi	a2,s0,-24
    8000574a:	4581                	li	a1,0
    8000574c:	4501                	li	a0,0
    8000574e:	00000097          	auipc	ra,0x0
    80005752:	d56080e7          	jalr	-682(ra) # 800054a4 <argfd>
    80005756:	87aa                	mv	a5,a0
    return -1;
    80005758:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000575a:	0007cc63          	bltz	a5,80005772 <sys_read+0x50>
  return fileread(f, p, n);
    8000575e:	fe442603          	lw	a2,-28(s0)
    80005762:	fd843583          	ld	a1,-40(s0)
    80005766:	fe843503          	ld	a0,-24(s0)
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	43c080e7          	jalr	1084(ra) # 80004ba6 <fileread>
}
    80005772:	70a2                	ld	ra,40(sp)
    80005774:	7402                	ld	s0,32(sp)
    80005776:	6145                	addi	sp,sp,48
    80005778:	8082                	ret

000000008000577a <sys_write>:
{
    8000577a:	7179                	addi	sp,sp,-48
    8000577c:	f406                	sd	ra,40(sp)
    8000577e:	f022                	sd	s0,32(sp)
    80005780:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005782:	fd840593          	addi	a1,s0,-40
    80005786:	4505                	li	a0,1
    80005788:	ffffd097          	auipc	ra,0xffffd
    8000578c:	7da080e7          	jalr	2010(ra) # 80002f62 <argaddr>
  argint(2, &n);
    80005790:	fe440593          	addi	a1,s0,-28
    80005794:	4509                	li	a0,2
    80005796:	ffffd097          	auipc	ra,0xffffd
    8000579a:	7ac080e7          	jalr	1964(ra) # 80002f42 <argint>
  if(argfd(0, 0, &f) < 0)
    8000579e:	fe840613          	addi	a2,s0,-24
    800057a2:	4581                	li	a1,0
    800057a4:	4501                	li	a0,0
    800057a6:	00000097          	auipc	ra,0x0
    800057aa:	cfe080e7          	jalr	-770(ra) # 800054a4 <argfd>
    800057ae:	87aa                	mv	a5,a0
    return -1;
    800057b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057b2:	0007cc63          	bltz	a5,800057ca <sys_write+0x50>
  return filewrite(f, p, n);
    800057b6:	fe442603          	lw	a2,-28(s0)
    800057ba:	fd843583          	ld	a1,-40(s0)
    800057be:	fe843503          	ld	a0,-24(s0)
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	4a6080e7          	jalr	1190(ra) # 80004c68 <filewrite>
}
    800057ca:	70a2                	ld	ra,40(sp)
    800057cc:	7402                	ld	s0,32(sp)
    800057ce:	6145                	addi	sp,sp,48
    800057d0:	8082                	ret

00000000800057d2 <sys_close>:
{
    800057d2:	1101                	addi	sp,sp,-32
    800057d4:	ec06                	sd	ra,24(sp)
    800057d6:	e822                	sd	s0,16(sp)
    800057d8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057da:	fe040613          	addi	a2,s0,-32
    800057de:	fec40593          	addi	a1,s0,-20
    800057e2:	4501                	li	a0,0
    800057e4:	00000097          	auipc	ra,0x0
    800057e8:	cc0080e7          	jalr	-832(ra) # 800054a4 <argfd>
    return -1;
    800057ec:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057ee:	02054463          	bltz	a0,80005816 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057f2:	ffffc097          	auipc	ra,0xffffc
    800057f6:	3dc080e7          	jalr	988(ra) # 80001bce <myproc>
    800057fa:	fec42783          	lw	a5,-20(s0)
    800057fe:	07e9                	addi	a5,a5,26
    80005800:	078e                	slli	a5,a5,0x3
    80005802:	953e                	add	a0,a0,a5
    80005804:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005808:	fe043503          	ld	a0,-32(s0)
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	260080e7          	jalr	608(ra) # 80004a6c <fileclose>
  return 0;
    80005814:	4781                	li	a5,0
}
    80005816:	853e                	mv	a0,a5
    80005818:	60e2                	ld	ra,24(sp)
    8000581a:	6442                	ld	s0,16(sp)
    8000581c:	6105                	addi	sp,sp,32
    8000581e:	8082                	ret

0000000080005820 <sys_fstat>:
{
    80005820:	1101                	addi	sp,sp,-32
    80005822:	ec06                	sd	ra,24(sp)
    80005824:	e822                	sd	s0,16(sp)
    80005826:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005828:	fe040593          	addi	a1,s0,-32
    8000582c:	4505                	li	a0,1
    8000582e:	ffffd097          	auipc	ra,0xffffd
    80005832:	734080e7          	jalr	1844(ra) # 80002f62 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005836:	fe840613          	addi	a2,s0,-24
    8000583a:	4581                	li	a1,0
    8000583c:	4501                	li	a0,0
    8000583e:	00000097          	auipc	ra,0x0
    80005842:	c66080e7          	jalr	-922(ra) # 800054a4 <argfd>
    80005846:	87aa                	mv	a5,a0
    return -1;
    80005848:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000584a:	0007ca63          	bltz	a5,8000585e <sys_fstat+0x3e>
  return filestat(f, st);
    8000584e:	fe043583          	ld	a1,-32(s0)
    80005852:	fe843503          	ld	a0,-24(s0)
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	2de080e7          	jalr	734(ra) # 80004b34 <filestat>
}
    8000585e:	60e2                	ld	ra,24(sp)
    80005860:	6442                	ld	s0,16(sp)
    80005862:	6105                	addi	sp,sp,32
    80005864:	8082                	ret

0000000080005866 <sys_link>:
{
    80005866:	7169                	addi	sp,sp,-304
    80005868:	f606                	sd	ra,296(sp)
    8000586a:	f222                	sd	s0,288(sp)
    8000586c:	ee26                	sd	s1,280(sp)
    8000586e:	ea4a                	sd	s2,272(sp)
    80005870:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005872:	08000613          	li	a2,128
    80005876:	ed040593          	addi	a1,s0,-304
    8000587a:	4501                	li	a0,0
    8000587c:	ffffd097          	auipc	ra,0xffffd
    80005880:	706080e7          	jalr	1798(ra) # 80002f82 <argstr>
    return -1;
    80005884:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005886:	10054e63          	bltz	a0,800059a2 <sys_link+0x13c>
    8000588a:	08000613          	li	a2,128
    8000588e:	f5040593          	addi	a1,s0,-176
    80005892:	4505                	li	a0,1
    80005894:	ffffd097          	auipc	ra,0xffffd
    80005898:	6ee080e7          	jalr	1774(ra) # 80002f82 <argstr>
    return -1;
    8000589c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000589e:	10054263          	bltz	a0,800059a2 <sys_link+0x13c>
  begin_op();
    800058a2:	fffff097          	auipc	ra,0xfffff
    800058a6:	d02080e7          	jalr	-766(ra) # 800045a4 <begin_op>
  if((ip = namei(old)) == 0){
    800058aa:	ed040513          	addi	a0,s0,-304
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	ad6080e7          	jalr	-1322(ra) # 80004384 <namei>
    800058b6:	84aa                	mv	s1,a0
    800058b8:	c551                	beqz	a0,80005944 <sys_link+0xde>
  ilock(ip);
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	31e080e7          	jalr	798(ra) # 80003bd8 <ilock>
  if(ip->type == T_DIR){
    800058c2:	04449703          	lh	a4,68(s1)
    800058c6:	4785                	li	a5,1
    800058c8:	08f70463          	beq	a4,a5,80005950 <sys_link+0xea>
  ip->nlink++;
    800058cc:	04a4d783          	lhu	a5,74(s1)
    800058d0:	2785                	addiw	a5,a5,1
    800058d2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058d6:	8526                	mv	a0,s1
    800058d8:	ffffe097          	auipc	ra,0xffffe
    800058dc:	234080e7          	jalr	564(ra) # 80003b0c <iupdate>
  iunlock(ip);
    800058e0:	8526                	mv	a0,s1
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	3b8080e7          	jalr	952(ra) # 80003c9a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058ea:	fd040593          	addi	a1,s0,-48
    800058ee:	f5040513          	addi	a0,s0,-176
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	ab0080e7          	jalr	-1360(ra) # 800043a2 <nameiparent>
    800058fa:	892a                	mv	s2,a0
    800058fc:	c935                	beqz	a0,80005970 <sys_link+0x10a>
  ilock(dp);
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	2da080e7          	jalr	730(ra) # 80003bd8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005906:	00092703          	lw	a4,0(s2)
    8000590a:	409c                	lw	a5,0(s1)
    8000590c:	04f71d63          	bne	a4,a5,80005966 <sys_link+0x100>
    80005910:	40d0                	lw	a2,4(s1)
    80005912:	fd040593          	addi	a1,s0,-48
    80005916:	854a                	mv	a0,s2
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	9ba080e7          	jalr	-1606(ra) # 800042d2 <dirlink>
    80005920:	04054363          	bltz	a0,80005966 <sys_link+0x100>
  iunlockput(dp);
    80005924:	854a                	mv	a0,s2
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	514080e7          	jalr	1300(ra) # 80003e3a <iunlockput>
  iput(ip);
    8000592e:	8526                	mv	a0,s1
    80005930:	ffffe097          	auipc	ra,0xffffe
    80005934:	462080e7          	jalr	1122(ra) # 80003d92 <iput>
  end_op();
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	cea080e7          	jalr	-790(ra) # 80004622 <end_op>
  return 0;
    80005940:	4781                	li	a5,0
    80005942:	a085                	j	800059a2 <sys_link+0x13c>
    end_op();
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	cde080e7          	jalr	-802(ra) # 80004622 <end_op>
    return -1;
    8000594c:	57fd                	li	a5,-1
    8000594e:	a891                	j	800059a2 <sys_link+0x13c>
    iunlockput(ip);
    80005950:	8526                	mv	a0,s1
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	4e8080e7          	jalr	1256(ra) # 80003e3a <iunlockput>
    end_op();
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	cc8080e7          	jalr	-824(ra) # 80004622 <end_op>
    return -1;
    80005962:	57fd                	li	a5,-1
    80005964:	a83d                	j	800059a2 <sys_link+0x13c>
    iunlockput(dp);
    80005966:	854a                	mv	a0,s2
    80005968:	ffffe097          	auipc	ra,0xffffe
    8000596c:	4d2080e7          	jalr	1234(ra) # 80003e3a <iunlockput>
  ilock(ip);
    80005970:	8526                	mv	a0,s1
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	266080e7          	jalr	614(ra) # 80003bd8 <ilock>
  ip->nlink--;
    8000597a:	04a4d783          	lhu	a5,74(s1)
    8000597e:	37fd                	addiw	a5,a5,-1
    80005980:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005984:	8526                	mv	a0,s1
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	186080e7          	jalr	390(ra) # 80003b0c <iupdate>
  iunlockput(ip);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	4aa080e7          	jalr	1194(ra) # 80003e3a <iunlockput>
  end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	c8a080e7          	jalr	-886(ra) # 80004622 <end_op>
  return -1;
    800059a0:	57fd                	li	a5,-1
}
    800059a2:	853e                	mv	a0,a5
    800059a4:	70b2                	ld	ra,296(sp)
    800059a6:	7412                	ld	s0,288(sp)
    800059a8:	64f2                	ld	s1,280(sp)
    800059aa:	6952                	ld	s2,272(sp)
    800059ac:	6155                	addi	sp,sp,304
    800059ae:	8082                	ret

00000000800059b0 <sys_unlink>:
{
    800059b0:	7151                	addi	sp,sp,-240
    800059b2:	f586                	sd	ra,232(sp)
    800059b4:	f1a2                	sd	s0,224(sp)
    800059b6:	eda6                	sd	s1,216(sp)
    800059b8:	e9ca                	sd	s2,208(sp)
    800059ba:	e5ce                	sd	s3,200(sp)
    800059bc:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059be:	08000613          	li	a2,128
    800059c2:	f3040593          	addi	a1,s0,-208
    800059c6:	4501                	li	a0,0
    800059c8:	ffffd097          	auipc	ra,0xffffd
    800059cc:	5ba080e7          	jalr	1466(ra) # 80002f82 <argstr>
    800059d0:	18054163          	bltz	a0,80005b52 <sys_unlink+0x1a2>
  begin_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	bd0080e7          	jalr	-1072(ra) # 800045a4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059dc:	fb040593          	addi	a1,s0,-80
    800059e0:	f3040513          	addi	a0,s0,-208
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	9be080e7          	jalr	-1602(ra) # 800043a2 <nameiparent>
    800059ec:	84aa                	mv	s1,a0
    800059ee:	c979                	beqz	a0,80005ac4 <sys_unlink+0x114>
  ilock(dp);
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	1e8080e7          	jalr	488(ra) # 80003bd8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059f8:	00003597          	auipc	a1,0x3
    800059fc:	e3058593          	addi	a1,a1,-464 # 80008828 <syscalls+0x2c8>
    80005a00:	fb040513          	addi	a0,s0,-80
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	69e080e7          	jalr	1694(ra) # 800040a2 <namecmp>
    80005a0c:	14050a63          	beqz	a0,80005b60 <sys_unlink+0x1b0>
    80005a10:	00003597          	auipc	a1,0x3
    80005a14:	e2058593          	addi	a1,a1,-480 # 80008830 <syscalls+0x2d0>
    80005a18:	fb040513          	addi	a0,s0,-80
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	686080e7          	jalr	1670(ra) # 800040a2 <namecmp>
    80005a24:	12050e63          	beqz	a0,80005b60 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a28:	f2c40613          	addi	a2,s0,-212
    80005a2c:	fb040593          	addi	a1,s0,-80
    80005a30:	8526                	mv	a0,s1
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	68a080e7          	jalr	1674(ra) # 800040bc <dirlookup>
    80005a3a:	892a                	mv	s2,a0
    80005a3c:	12050263          	beqz	a0,80005b60 <sys_unlink+0x1b0>
  ilock(ip);
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	198080e7          	jalr	408(ra) # 80003bd8 <ilock>
  if(ip->nlink < 1)
    80005a48:	04a91783          	lh	a5,74(s2)
    80005a4c:	08f05263          	blez	a5,80005ad0 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a50:	04491703          	lh	a4,68(s2)
    80005a54:	4785                	li	a5,1
    80005a56:	08f70563          	beq	a4,a5,80005ae0 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a5a:	4641                	li	a2,16
    80005a5c:	4581                	li	a1,0
    80005a5e:	fc040513          	addi	a0,s0,-64
    80005a62:	ffffb097          	auipc	ra,0xffffb
    80005a66:	338080e7          	jalr	824(ra) # 80000d9a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a6a:	4741                	li	a4,16
    80005a6c:	f2c42683          	lw	a3,-212(s0)
    80005a70:	fc040613          	addi	a2,s0,-64
    80005a74:	4581                	li	a1,0
    80005a76:	8526                	mv	a0,s1
    80005a78:	ffffe097          	auipc	ra,0xffffe
    80005a7c:	50c080e7          	jalr	1292(ra) # 80003f84 <writei>
    80005a80:	47c1                	li	a5,16
    80005a82:	0af51563          	bne	a0,a5,80005b2c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a86:	04491703          	lh	a4,68(s2)
    80005a8a:	4785                	li	a5,1
    80005a8c:	0af70863          	beq	a4,a5,80005b3c <sys_unlink+0x18c>
  iunlockput(dp);
    80005a90:	8526                	mv	a0,s1
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	3a8080e7          	jalr	936(ra) # 80003e3a <iunlockput>
  ip->nlink--;
    80005a9a:	04a95783          	lhu	a5,74(s2)
    80005a9e:	37fd                	addiw	a5,a5,-1
    80005aa0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005aa4:	854a                	mv	a0,s2
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	066080e7          	jalr	102(ra) # 80003b0c <iupdate>
  iunlockput(ip);
    80005aae:	854a                	mv	a0,s2
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	38a080e7          	jalr	906(ra) # 80003e3a <iunlockput>
  end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	b6a080e7          	jalr	-1174(ra) # 80004622 <end_op>
  return 0;
    80005ac0:	4501                	li	a0,0
    80005ac2:	a84d                	j	80005b74 <sys_unlink+0x1c4>
    end_op();
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	b5e080e7          	jalr	-1186(ra) # 80004622 <end_op>
    return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	a05d                	j	80005b74 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ad0:	00003517          	auipc	a0,0x3
    80005ad4:	d6850513          	addi	a0,a0,-664 # 80008838 <syscalls+0x2d8>
    80005ad8:	ffffb097          	auipc	ra,0xffffb
    80005adc:	a68080e7          	jalr	-1432(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ae0:	04c92703          	lw	a4,76(s2)
    80005ae4:	02000793          	li	a5,32
    80005ae8:	f6e7f9e3          	bgeu	a5,a4,80005a5a <sys_unlink+0xaa>
    80005aec:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005af0:	4741                	li	a4,16
    80005af2:	86ce                	mv	a3,s3
    80005af4:	f1840613          	addi	a2,s0,-232
    80005af8:	4581                	li	a1,0
    80005afa:	854a                	mv	a0,s2
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	390080e7          	jalr	912(ra) # 80003e8c <readi>
    80005b04:	47c1                	li	a5,16
    80005b06:	00f51b63          	bne	a0,a5,80005b1c <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b0a:	f1845783          	lhu	a5,-232(s0)
    80005b0e:	e7a1                	bnez	a5,80005b56 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b10:	29c1                	addiw	s3,s3,16
    80005b12:	04c92783          	lw	a5,76(s2)
    80005b16:	fcf9ede3          	bltu	s3,a5,80005af0 <sys_unlink+0x140>
    80005b1a:	b781                	j	80005a5a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b1c:	00003517          	auipc	a0,0x3
    80005b20:	d3450513          	addi	a0,a0,-716 # 80008850 <syscalls+0x2f0>
    80005b24:	ffffb097          	auipc	ra,0xffffb
    80005b28:	a1c080e7          	jalr	-1508(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005b2c:	00003517          	auipc	a0,0x3
    80005b30:	d3c50513          	addi	a0,a0,-708 # 80008868 <syscalls+0x308>
    80005b34:	ffffb097          	auipc	ra,0xffffb
    80005b38:	a0c080e7          	jalr	-1524(ra) # 80000540 <panic>
    dp->nlink--;
    80005b3c:	04a4d783          	lhu	a5,74(s1)
    80005b40:	37fd                	addiw	a5,a5,-1
    80005b42:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b46:	8526                	mv	a0,s1
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	fc4080e7          	jalr	-60(ra) # 80003b0c <iupdate>
    80005b50:	b781                	j	80005a90 <sys_unlink+0xe0>
    return -1;
    80005b52:	557d                	li	a0,-1
    80005b54:	a005                	j	80005b74 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b56:	854a                	mv	a0,s2
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	2e2080e7          	jalr	738(ra) # 80003e3a <iunlockput>
  iunlockput(dp);
    80005b60:	8526                	mv	a0,s1
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	2d8080e7          	jalr	728(ra) # 80003e3a <iunlockput>
  end_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	ab8080e7          	jalr	-1352(ra) # 80004622 <end_op>
  return -1;
    80005b72:	557d                	li	a0,-1
}
    80005b74:	70ae                	ld	ra,232(sp)
    80005b76:	740e                	ld	s0,224(sp)
    80005b78:	64ee                	ld	s1,216(sp)
    80005b7a:	694e                	ld	s2,208(sp)
    80005b7c:	69ae                	ld	s3,200(sp)
    80005b7e:	616d                	addi	sp,sp,240
    80005b80:	8082                	ret

0000000080005b82 <sys_open>:

uint64
sys_open(void)
{
    80005b82:	7131                	addi	sp,sp,-192
    80005b84:	fd06                	sd	ra,184(sp)
    80005b86:	f922                	sd	s0,176(sp)
    80005b88:	f526                	sd	s1,168(sp)
    80005b8a:	f14a                	sd	s2,160(sp)
    80005b8c:	ed4e                	sd	s3,152(sp)
    80005b8e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b90:	f4c40593          	addi	a1,s0,-180
    80005b94:	4505                	li	a0,1
    80005b96:	ffffd097          	auipc	ra,0xffffd
    80005b9a:	3ac080e7          	jalr	940(ra) # 80002f42 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b9e:	08000613          	li	a2,128
    80005ba2:	f5040593          	addi	a1,s0,-176
    80005ba6:	4501                	li	a0,0
    80005ba8:	ffffd097          	auipc	ra,0xffffd
    80005bac:	3da080e7          	jalr	986(ra) # 80002f82 <argstr>
    80005bb0:	87aa                	mv	a5,a0
    return -1;
    80005bb2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bb4:	0a07c963          	bltz	a5,80005c66 <sys_open+0xe4>

  begin_op();
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	9ec080e7          	jalr	-1556(ra) # 800045a4 <begin_op>

  if(omode & O_CREATE){
    80005bc0:	f4c42783          	lw	a5,-180(s0)
    80005bc4:	2007f793          	andi	a5,a5,512
    80005bc8:	cfc5                	beqz	a5,80005c80 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bca:	4681                	li	a3,0
    80005bcc:	4601                	li	a2,0
    80005bce:	4589                	li	a1,2
    80005bd0:	f5040513          	addi	a0,s0,-176
    80005bd4:	00000097          	auipc	ra,0x0
    80005bd8:	972080e7          	jalr	-1678(ra) # 80005546 <create>
    80005bdc:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bde:	c959                	beqz	a0,80005c74 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005be0:	04449703          	lh	a4,68(s1)
    80005be4:	478d                	li	a5,3
    80005be6:	00f71763          	bne	a4,a5,80005bf4 <sys_open+0x72>
    80005bea:	0464d703          	lhu	a4,70(s1)
    80005bee:	47a5                	li	a5,9
    80005bf0:	0ce7ed63          	bltu	a5,a4,80005cca <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bf4:	fffff097          	auipc	ra,0xfffff
    80005bf8:	dbc080e7          	jalr	-580(ra) # 800049b0 <filealloc>
    80005bfc:	89aa                	mv	s3,a0
    80005bfe:	10050363          	beqz	a0,80005d04 <sys_open+0x182>
    80005c02:	00000097          	auipc	ra,0x0
    80005c06:	902080e7          	jalr	-1790(ra) # 80005504 <fdalloc>
    80005c0a:	892a                	mv	s2,a0
    80005c0c:	0e054763          	bltz	a0,80005cfa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c10:	04449703          	lh	a4,68(s1)
    80005c14:	478d                	li	a5,3
    80005c16:	0cf70563          	beq	a4,a5,80005ce0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c1a:	4789                	li	a5,2
    80005c1c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c20:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c24:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c28:	f4c42783          	lw	a5,-180(s0)
    80005c2c:	0017c713          	xori	a4,a5,1
    80005c30:	8b05                	andi	a4,a4,1
    80005c32:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c36:	0037f713          	andi	a4,a5,3
    80005c3a:	00e03733          	snez	a4,a4
    80005c3e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c42:	4007f793          	andi	a5,a5,1024
    80005c46:	c791                	beqz	a5,80005c52 <sys_open+0xd0>
    80005c48:	04449703          	lh	a4,68(s1)
    80005c4c:	4789                	li	a5,2
    80005c4e:	0af70063          	beq	a4,a5,80005cee <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c52:	8526                	mv	a0,s1
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	046080e7          	jalr	70(ra) # 80003c9a <iunlock>
  end_op();
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	9c6080e7          	jalr	-1594(ra) # 80004622 <end_op>

  return fd;
    80005c64:	854a                	mv	a0,s2
}
    80005c66:	70ea                	ld	ra,184(sp)
    80005c68:	744a                	ld	s0,176(sp)
    80005c6a:	74aa                	ld	s1,168(sp)
    80005c6c:	790a                	ld	s2,160(sp)
    80005c6e:	69ea                	ld	s3,152(sp)
    80005c70:	6129                	addi	sp,sp,192
    80005c72:	8082                	ret
      end_op();
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	9ae080e7          	jalr	-1618(ra) # 80004622 <end_op>
      return -1;
    80005c7c:	557d                	li	a0,-1
    80005c7e:	b7e5                	j	80005c66 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c80:	f5040513          	addi	a0,s0,-176
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	700080e7          	jalr	1792(ra) # 80004384 <namei>
    80005c8c:	84aa                	mv	s1,a0
    80005c8e:	c905                	beqz	a0,80005cbe <sys_open+0x13c>
    ilock(ip);
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	f48080e7          	jalr	-184(ra) # 80003bd8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c98:	04449703          	lh	a4,68(s1)
    80005c9c:	4785                	li	a5,1
    80005c9e:	f4f711e3          	bne	a4,a5,80005be0 <sys_open+0x5e>
    80005ca2:	f4c42783          	lw	a5,-180(s0)
    80005ca6:	d7b9                	beqz	a5,80005bf4 <sys_open+0x72>
      iunlockput(ip);
    80005ca8:	8526                	mv	a0,s1
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	190080e7          	jalr	400(ra) # 80003e3a <iunlockput>
      end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	970080e7          	jalr	-1680(ra) # 80004622 <end_op>
      return -1;
    80005cba:	557d                	li	a0,-1
    80005cbc:	b76d                	j	80005c66 <sys_open+0xe4>
      end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	964080e7          	jalr	-1692(ra) # 80004622 <end_op>
      return -1;
    80005cc6:	557d                	li	a0,-1
    80005cc8:	bf79                	j	80005c66 <sys_open+0xe4>
    iunlockput(ip);
    80005cca:	8526                	mv	a0,s1
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	16e080e7          	jalr	366(ra) # 80003e3a <iunlockput>
    end_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	94e080e7          	jalr	-1714(ra) # 80004622 <end_op>
    return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	b761                	j	80005c66 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ce0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ce4:	04649783          	lh	a5,70(s1)
    80005ce8:	02f99223          	sh	a5,36(s3)
    80005cec:	bf25                	j	80005c24 <sys_open+0xa2>
    itrunc(ip);
    80005cee:	8526                	mv	a0,s1
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	ff6080e7          	jalr	-10(ra) # 80003ce6 <itrunc>
    80005cf8:	bfa9                	j	80005c52 <sys_open+0xd0>
      fileclose(f);
    80005cfa:	854e                	mv	a0,s3
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	d70080e7          	jalr	-656(ra) # 80004a6c <fileclose>
    iunlockput(ip);
    80005d04:	8526                	mv	a0,s1
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	134080e7          	jalr	308(ra) # 80003e3a <iunlockput>
    end_op();
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	914080e7          	jalr	-1772(ra) # 80004622 <end_op>
    return -1;
    80005d16:	557d                	li	a0,-1
    80005d18:	b7b9                	j	80005c66 <sys_open+0xe4>

0000000080005d1a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d1a:	7175                	addi	sp,sp,-144
    80005d1c:	e506                	sd	ra,136(sp)
    80005d1e:	e122                	sd	s0,128(sp)
    80005d20:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	882080e7          	jalr	-1918(ra) # 800045a4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d2a:	08000613          	li	a2,128
    80005d2e:	f7040593          	addi	a1,s0,-144
    80005d32:	4501                	li	a0,0
    80005d34:	ffffd097          	auipc	ra,0xffffd
    80005d38:	24e080e7          	jalr	590(ra) # 80002f82 <argstr>
    80005d3c:	02054963          	bltz	a0,80005d6e <sys_mkdir+0x54>
    80005d40:	4681                	li	a3,0
    80005d42:	4601                	li	a2,0
    80005d44:	4585                	li	a1,1
    80005d46:	f7040513          	addi	a0,s0,-144
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	7fc080e7          	jalr	2044(ra) # 80005546 <create>
    80005d52:	cd11                	beqz	a0,80005d6e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	0e6080e7          	jalr	230(ra) # 80003e3a <iunlockput>
  end_op();
    80005d5c:	fffff097          	auipc	ra,0xfffff
    80005d60:	8c6080e7          	jalr	-1850(ra) # 80004622 <end_op>
  return 0;
    80005d64:	4501                	li	a0,0
}
    80005d66:	60aa                	ld	ra,136(sp)
    80005d68:	640a                	ld	s0,128(sp)
    80005d6a:	6149                	addi	sp,sp,144
    80005d6c:	8082                	ret
    end_op();
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	8b4080e7          	jalr	-1868(ra) # 80004622 <end_op>
    return -1;
    80005d76:	557d                	li	a0,-1
    80005d78:	b7fd                	j	80005d66 <sys_mkdir+0x4c>

0000000080005d7a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d7a:	7135                	addi	sp,sp,-160
    80005d7c:	ed06                	sd	ra,152(sp)
    80005d7e:	e922                	sd	s0,144(sp)
    80005d80:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d82:	fffff097          	auipc	ra,0xfffff
    80005d86:	822080e7          	jalr	-2014(ra) # 800045a4 <begin_op>
  argint(1, &major);
    80005d8a:	f6c40593          	addi	a1,s0,-148
    80005d8e:	4505                	li	a0,1
    80005d90:	ffffd097          	auipc	ra,0xffffd
    80005d94:	1b2080e7          	jalr	434(ra) # 80002f42 <argint>
  argint(2, &minor);
    80005d98:	f6840593          	addi	a1,s0,-152
    80005d9c:	4509                	li	a0,2
    80005d9e:	ffffd097          	auipc	ra,0xffffd
    80005da2:	1a4080e7          	jalr	420(ra) # 80002f42 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005da6:	08000613          	li	a2,128
    80005daa:	f7040593          	addi	a1,s0,-144
    80005dae:	4501                	li	a0,0
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	1d2080e7          	jalr	466(ra) # 80002f82 <argstr>
    80005db8:	02054b63          	bltz	a0,80005dee <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005dbc:	f6841683          	lh	a3,-152(s0)
    80005dc0:	f6c41603          	lh	a2,-148(s0)
    80005dc4:	458d                	li	a1,3
    80005dc6:	f7040513          	addi	a0,s0,-144
    80005dca:	fffff097          	auipc	ra,0xfffff
    80005dce:	77c080e7          	jalr	1916(ra) # 80005546 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dd2:	cd11                	beqz	a0,80005dee <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dd4:	ffffe097          	auipc	ra,0xffffe
    80005dd8:	066080e7          	jalr	102(ra) # 80003e3a <iunlockput>
  end_op();
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	846080e7          	jalr	-1978(ra) # 80004622 <end_op>
  return 0;
    80005de4:	4501                	li	a0,0
}
    80005de6:	60ea                	ld	ra,152(sp)
    80005de8:	644a                	ld	s0,144(sp)
    80005dea:	610d                	addi	sp,sp,160
    80005dec:	8082                	ret
    end_op();
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	834080e7          	jalr	-1996(ra) # 80004622 <end_op>
    return -1;
    80005df6:	557d                	li	a0,-1
    80005df8:	b7fd                	j	80005de6 <sys_mknod+0x6c>

0000000080005dfa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005dfa:	7135                	addi	sp,sp,-160
    80005dfc:	ed06                	sd	ra,152(sp)
    80005dfe:	e922                	sd	s0,144(sp)
    80005e00:	e526                	sd	s1,136(sp)
    80005e02:	e14a                	sd	s2,128(sp)
    80005e04:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e06:	ffffc097          	auipc	ra,0xffffc
    80005e0a:	dc8080e7          	jalr	-568(ra) # 80001bce <myproc>
    80005e0e:	892a                	mv	s2,a0
  
  begin_op();
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	794080e7          	jalr	1940(ra) # 800045a4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e18:	08000613          	li	a2,128
    80005e1c:	f6040593          	addi	a1,s0,-160
    80005e20:	4501                	li	a0,0
    80005e22:	ffffd097          	auipc	ra,0xffffd
    80005e26:	160080e7          	jalr	352(ra) # 80002f82 <argstr>
    80005e2a:	04054b63          	bltz	a0,80005e80 <sys_chdir+0x86>
    80005e2e:	f6040513          	addi	a0,s0,-160
    80005e32:	ffffe097          	auipc	ra,0xffffe
    80005e36:	552080e7          	jalr	1362(ra) # 80004384 <namei>
    80005e3a:	84aa                	mv	s1,a0
    80005e3c:	c131                	beqz	a0,80005e80 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e3e:	ffffe097          	auipc	ra,0xffffe
    80005e42:	d9a080e7          	jalr	-614(ra) # 80003bd8 <ilock>
  if(ip->type != T_DIR){
    80005e46:	04449703          	lh	a4,68(s1)
    80005e4a:	4785                	li	a5,1
    80005e4c:	04f71063          	bne	a4,a5,80005e8c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e50:	8526                	mv	a0,s1
    80005e52:	ffffe097          	auipc	ra,0xffffe
    80005e56:	e48080e7          	jalr	-440(ra) # 80003c9a <iunlock>
  iput(p->cwd);
    80005e5a:	15093503          	ld	a0,336(s2)
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	f34080e7          	jalr	-204(ra) # 80003d92 <iput>
  end_op();
    80005e66:	ffffe097          	auipc	ra,0xffffe
    80005e6a:	7bc080e7          	jalr	1980(ra) # 80004622 <end_op>
  p->cwd = ip;
    80005e6e:	14993823          	sd	s1,336(s2)
  return 0;
    80005e72:	4501                	li	a0,0
}
    80005e74:	60ea                	ld	ra,152(sp)
    80005e76:	644a                	ld	s0,144(sp)
    80005e78:	64aa                	ld	s1,136(sp)
    80005e7a:	690a                	ld	s2,128(sp)
    80005e7c:	610d                	addi	sp,sp,160
    80005e7e:	8082                	ret
    end_op();
    80005e80:	ffffe097          	auipc	ra,0xffffe
    80005e84:	7a2080e7          	jalr	1954(ra) # 80004622 <end_op>
    return -1;
    80005e88:	557d                	li	a0,-1
    80005e8a:	b7ed                	j	80005e74 <sys_chdir+0x7a>
    iunlockput(ip);
    80005e8c:	8526                	mv	a0,s1
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	fac080e7          	jalr	-84(ra) # 80003e3a <iunlockput>
    end_op();
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	78c080e7          	jalr	1932(ra) # 80004622 <end_op>
    return -1;
    80005e9e:	557d                	li	a0,-1
    80005ea0:	bfd1                	j	80005e74 <sys_chdir+0x7a>

0000000080005ea2 <sys_exec>:

uint64
sys_exec(void)
{
    80005ea2:	7145                	addi	sp,sp,-464
    80005ea4:	e786                	sd	ra,456(sp)
    80005ea6:	e3a2                	sd	s0,448(sp)
    80005ea8:	ff26                	sd	s1,440(sp)
    80005eaa:	fb4a                	sd	s2,432(sp)
    80005eac:	f74e                	sd	s3,424(sp)
    80005eae:	f352                	sd	s4,416(sp)
    80005eb0:	ef56                	sd	s5,408(sp)
    80005eb2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005eb4:	e3840593          	addi	a1,s0,-456
    80005eb8:	4505                	li	a0,1
    80005eba:	ffffd097          	auipc	ra,0xffffd
    80005ebe:	0a8080e7          	jalr	168(ra) # 80002f62 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ec2:	08000613          	li	a2,128
    80005ec6:	f4040593          	addi	a1,s0,-192
    80005eca:	4501                	li	a0,0
    80005ecc:	ffffd097          	auipc	ra,0xffffd
    80005ed0:	0b6080e7          	jalr	182(ra) # 80002f82 <argstr>
    80005ed4:	87aa                	mv	a5,a0
    return -1;
    80005ed6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ed8:	0c07c363          	bltz	a5,80005f9e <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005edc:	10000613          	li	a2,256
    80005ee0:	4581                	li	a1,0
    80005ee2:	e4040513          	addi	a0,s0,-448
    80005ee6:	ffffb097          	auipc	ra,0xffffb
    80005eea:	eb4080e7          	jalr	-332(ra) # 80000d9a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005eee:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ef2:	89a6                	mv	s3,s1
    80005ef4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ef6:	02000a13          	li	s4,32
    80005efa:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005efe:	00391513          	slli	a0,s2,0x3
    80005f02:	e3040593          	addi	a1,s0,-464
    80005f06:	e3843783          	ld	a5,-456(s0)
    80005f0a:	953e                	add	a0,a0,a5
    80005f0c:	ffffd097          	auipc	ra,0xffffd
    80005f10:	f98080e7          	jalr	-104(ra) # 80002ea4 <fetchaddr>
    80005f14:	02054a63          	bltz	a0,80005f48 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f18:	e3043783          	ld	a5,-464(s0)
    80005f1c:	c3b9                	beqz	a5,80005f62 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f1e:	ffffb097          	auipc	ra,0xffffb
    80005f22:	c44080e7          	jalr	-956(ra) # 80000b62 <kalloc>
    80005f26:	85aa                	mv	a1,a0
    80005f28:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f2c:	cd11                	beqz	a0,80005f48 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f2e:	6605                	lui	a2,0x1
    80005f30:	e3043503          	ld	a0,-464(s0)
    80005f34:	ffffd097          	auipc	ra,0xffffd
    80005f38:	fc2080e7          	jalr	-62(ra) # 80002ef6 <fetchstr>
    80005f3c:	00054663          	bltz	a0,80005f48 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f40:	0905                	addi	s2,s2,1
    80005f42:	09a1                	addi	s3,s3,8
    80005f44:	fb491be3          	bne	s2,s4,80005efa <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f48:	f4040913          	addi	s2,s0,-192
    80005f4c:	6088                	ld	a0,0(s1)
    80005f4e:	c539                	beqz	a0,80005f9c <sys_exec+0xfa>
    kfree(argv[i]);
    80005f50:	ffffb097          	auipc	ra,0xffffb
    80005f54:	aaa080e7          	jalr	-1366(ra) # 800009fa <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f58:	04a1                	addi	s1,s1,8
    80005f5a:	ff2499e3          	bne	s1,s2,80005f4c <sys_exec+0xaa>
  return -1;
    80005f5e:	557d                	li	a0,-1
    80005f60:	a83d                	j	80005f9e <sys_exec+0xfc>
      argv[i] = 0;
    80005f62:	0a8e                	slli	s5,s5,0x3
    80005f64:	fc0a8793          	addi	a5,s5,-64
    80005f68:	00878ab3          	add	s5,a5,s0
    80005f6c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f70:	e4040593          	addi	a1,s0,-448
    80005f74:	f4040513          	addi	a0,s0,-192
    80005f78:	fffff097          	auipc	ra,0xfffff
    80005f7c:	16e080e7          	jalr	366(ra) # 800050e6 <exec>
    80005f80:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f82:	f4040993          	addi	s3,s0,-192
    80005f86:	6088                	ld	a0,0(s1)
    80005f88:	c901                	beqz	a0,80005f98 <sys_exec+0xf6>
    kfree(argv[i]);
    80005f8a:	ffffb097          	auipc	ra,0xffffb
    80005f8e:	a70080e7          	jalr	-1424(ra) # 800009fa <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f92:	04a1                	addi	s1,s1,8
    80005f94:	ff3499e3          	bne	s1,s3,80005f86 <sys_exec+0xe4>
  return ret;
    80005f98:	854a                	mv	a0,s2
    80005f9a:	a011                	j	80005f9e <sys_exec+0xfc>
  return -1;
    80005f9c:	557d                	li	a0,-1
}
    80005f9e:	60be                	ld	ra,456(sp)
    80005fa0:	641e                	ld	s0,448(sp)
    80005fa2:	74fa                	ld	s1,440(sp)
    80005fa4:	795a                	ld	s2,432(sp)
    80005fa6:	79ba                	ld	s3,424(sp)
    80005fa8:	7a1a                	ld	s4,416(sp)
    80005faa:	6afa                	ld	s5,408(sp)
    80005fac:	6179                	addi	sp,sp,464
    80005fae:	8082                	ret

0000000080005fb0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fb0:	7139                	addi	sp,sp,-64
    80005fb2:	fc06                	sd	ra,56(sp)
    80005fb4:	f822                	sd	s0,48(sp)
    80005fb6:	f426                	sd	s1,40(sp)
    80005fb8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fba:	ffffc097          	auipc	ra,0xffffc
    80005fbe:	c14080e7          	jalr	-1004(ra) # 80001bce <myproc>
    80005fc2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fc4:	fd840593          	addi	a1,s0,-40
    80005fc8:	4501                	li	a0,0
    80005fca:	ffffd097          	auipc	ra,0xffffd
    80005fce:	f98080e7          	jalr	-104(ra) # 80002f62 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fd2:	fc840593          	addi	a1,s0,-56
    80005fd6:	fd040513          	addi	a0,s0,-48
    80005fda:	fffff097          	auipc	ra,0xfffff
    80005fde:	dc2080e7          	jalr	-574(ra) # 80004d9c <pipealloc>
    return -1;
    80005fe2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fe4:	0c054463          	bltz	a0,800060ac <sys_pipe+0xfc>
  fd0 = -1;
    80005fe8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fec:	fd043503          	ld	a0,-48(s0)
    80005ff0:	fffff097          	auipc	ra,0xfffff
    80005ff4:	514080e7          	jalr	1300(ra) # 80005504 <fdalloc>
    80005ff8:	fca42223          	sw	a0,-60(s0)
    80005ffc:	08054b63          	bltz	a0,80006092 <sys_pipe+0xe2>
    80006000:	fc843503          	ld	a0,-56(s0)
    80006004:	fffff097          	auipc	ra,0xfffff
    80006008:	500080e7          	jalr	1280(ra) # 80005504 <fdalloc>
    8000600c:	fca42023          	sw	a0,-64(s0)
    80006010:	06054863          	bltz	a0,80006080 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006014:	4691                	li	a3,4
    80006016:	fc440613          	addi	a2,s0,-60
    8000601a:	fd843583          	ld	a1,-40(s0)
    8000601e:	68a8                	ld	a0,80(s1)
    80006020:	ffffb097          	auipc	ra,0xffffb
    80006024:	714080e7          	jalr	1812(ra) # 80001734 <copyout>
    80006028:	02054063          	bltz	a0,80006048 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000602c:	4691                	li	a3,4
    8000602e:	fc040613          	addi	a2,s0,-64
    80006032:	fd843583          	ld	a1,-40(s0)
    80006036:	0591                	addi	a1,a1,4
    80006038:	68a8                	ld	a0,80(s1)
    8000603a:	ffffb097          	auipc	ra,0xffffb
    8000603e:	6fa080e7          	jalr	1786(ra) # 80001734 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006042:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006044:	06055463          	bgez	a0,800060ac <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006048:	fc442783          	lw	a5,-60(s0)
    8000604c:	07e9                	addi	a5,a5,26
    8000604e:	078e                	slli	a5,a5,0x3
    80006050:	97a6                	add	a5,a5,s1
    80006052:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006056:	fc042783          	lw	a5,-64(s0)
    8000605a:	07e9                	addi	a5,a5,26
    8000605c:	078e                	slli	a5,a5,0x3
    8000605e:	94be                	add	s1,s1,a5
    80006060:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006064:	fd043503          	ld	a0,-48(s0)
    80006068:	fffff097          	auipc	ra,0xfffff
    8000606c:	a04080e7          	jalr	-1532(ra) # 80004a6c <fileclose>
    fileclose(wf);
    80006070:	fc843503          	ld	a0,-56(s0)
    80006074:	fffff097          	auipc	ra,0xfffff
    80006078:	9f8080e7          	jalr	-1544(ra) # 80004a6c <fileclose>
    return -1;
    8000607c:	57fd                	li	a5,-1
    8000607e:	a03d                	j	800060ac <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006080:	fc442783          	lw	a5,-60(s0)
    80006084:	0007c763          	bltz	a5,80006092 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006088:	07e9                	addi	a5,a5,26
    8000608a:	078e                	slli	a5,a5,0x3
    8000608c:	97a6                	add	a5,a5,s1
    8000608e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006092:	fd043503          	ld	a0,-48(s0)
    80006096:	fffff097          	auipc	ra,0xfffff
    8000609a:	9d6080e7          	jalr	-1578(ra) # 80004a6c <fileclose>
    fileclose(wf);
    8000609e:	fc843503          	ld	a0,-56(s0)
    800060a2:	fffff097          	auipc	ra,0xfffff
    800060a6:	9ca080e7          	jalr	-1590(ra) # 80004a6c <fileclose>
    return -1;
    800060aa:	57fd                	li	a5,-1
}
    800060ac:	853e                	mv	a0,a5
    800060ae:	70e2                	ld	ra,56(sp)
    800060b0:	7442                	ld	s0,48(sp)
    800060b2:	74a2                	ld	s1,40(sp)
    800060b4:	6121                	addi	sp,sp,64
    800060b6:	8082                	ret
	...

00000000800060c0 <kernelvec>:
    800060c0:	7111                	addi	sp,sp,-256
    800060c2:	e006                	sd	ra,0(sp)
    800060c4:	e40a                	sd	sp,8(sp)
    800060c6:	e80e                	sd	gp,16(sp)
    800060c8:	ec12                	sd	tp,24(sp)
    800060ca:	f016                	sd	t0,32(sp)
    800060cc:	f41a                	sd	t1,40(sp)
    800060ce:	f81e                	sd	t2,48(sp)
    800060d0:	fc22                	sd	s0,56(sp)
    800060d2:	e0a6                	sd	s1,64(sp)
    800060d4:	e4aa                	sd	a0,72(sp)
    800060d6:	e8ae                	sd	a1,80(sp)
    800060d8:	ecb2                	sd	a2,88(sp)
    800060da:	f0b6                	sd	a3,96(sp)
    800060dc:	f4ba                	sd	a4,104(sp)
    800060de:	f8be                	sd	a5,112(sp)
    800060e0:	fcc2                	sd	a6,120(sp)
    800060e2:	e146                	sd	a7,128(sp)
    800060e4:	e54a                	sd	s2,136(sp)
    800060e6:	e94e                	sd	s3,144(sp)
    800060e8:	ed52                	sd	s4,152(sp)
    800060ea:	f156                	sd	s5,160(sp)
    800060ec:	f55a                	sd	s6,168(sp)
    800060ee:	f95e                	sd	s7,176(sp)
    800060f0:	fd62                	sd	s8,184(sp)
    800060f2:	e1e6                	sd	s9,192(sp)
    800060f4:	e5ea                	sd	s10,200(sp)
    800060f6:	e9ee                	sd	s11,208(sp)
    800060f8:	edf2                	sd	t3,216(sp)
    800060fa:	f1f6                	sd	t4,224(sp)
    800060fc:	f5fa                	sd	t5,232(sp)
    800060fe:	f9fe                	sd	t6,240(sp)
    80006100:	c71fc0ef          	jal	ra,80002d70 <kerneltrap>
    80006104:	6082                	ld	ra,0(sp)
    80006106:	6122                	ld	sp,8(sp)
    80006108:	61c2                	ld	gp,16(sp)
    8000610a:	7282                	ld	t0,32(sp)
    8000610c:	7322                	ld	t1,40(sp)
    8000610e:	73c2                	ld	t2,48(sp)
    80006110:	7462                	ld	s0,56(sp)
    80006112:	6486                	ld	s1,64(sp)
    80006114:	6526                	ld	a0,72(sp)
    80006116:	65c6                	ld	a1,80(sp)
    80006118:	6666                	ld	a2,88(sp)
    8000611a:	7686                	ld	a3,96(sp)
    8000611c:	7726                	ld	a4,104(sp)
    8000611e:	77c6                	ld	a5,112(sp)
    80006120:	7866                	ld	a6,120(sp)
    80006122:	688a                	ld	a7,128(sp)
    80006124:	692a                	ld	s2,136(sp)
    80006126:	69ca                	ld	s3,144(sp)
    80006128:	6a6a                	ld	s4,152(sp)
    8000612a:	7a8a                	ld	s5,160(sp)
    8000612c:	7b2a                	ld	s6,168(sp)
    8000612e:	7bca                	ld	s7,176(sp)
    80006130:	7c6a                	ld	s8,184(sp)
    80006132:	6c8e                	ld	s9,192(sp)
    80006134:	6d2e                	ld	s10,200(sp)
    80006136:	6dce                	ld	s11,208(sp)
    80006138:	6e6e                	ld	t3,216(sp)
    8000613a:	7e8e                	ld	t4,224(sp)
    8000613c:	7f2e                	ld	t5,232(sp)
    8000613e:	7fce                	ld	t6,240(sp)
    80006140:	6111                	addi	sp,sp,256
    80006142:	10200073          	sret
    80006146:	00000013          	nop
    8000614a:	00000013          	nop
    8000614e:	0001                	nop

0000000080006150 <timervec>:
    80006150:	34051573          	csrrw	a0,mscratch,a0
    80006154:	e10c                	sd	a1,0(a0)
    80006156:	e510                	sd	a2,8(a0)
    80006158:	e914                	sd	a3,16(a0)
    8000615a:	6d0c                	ld	a1,24(a0)
    8000615c:	7110                	ld	a2,32(a0)
    8000615e:	6194                	ld	a3,0(a1)
    80006160:	96b2                	add	a3,a3,a2
    80006162:	e194                	sd	a3,0(a1)
    80006164:	4589                	li	a1,2
    80006166:	14459073          	csrw	sip,a1
    8000616a:	6914                	ld	a3,16(a0)
    8000616c:	6510                	ld	a2,8(a0)
    8000616e:	610c                	ld	a1,0(a0)
    80006170:	34051573          	csrrw	a0,mscratch,a0
    80006174:	30200073          	mret
	...

000000008000617a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000617a:	1141                	addi	sp,sp,-16
    8000617c:	e422                	sd	s0,8(sp)
    8000617e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006180:	0c0007b7          	lui	a5,0xc000
    80006184:	4705                	li	a4,1
    80006186:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006188:	c3d8                	sw	a4,4(a5)
}
    8000618a:	6422                	ld	s0,8(sp)
    8000618c:	0141                	addi	sp,sp,16
    8000618e:	8082                	ret

0000000080006190 <plicinithart>:

void
plicinithart(void)
{
    80006190:	1141                	addi	sp,sp,-16
    80006192:	e406                	sd	ra,8(sp)
    80006194:	e022                	sd	s0,0(sp)
    80006196:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006198:	ffffc097          	auipc	ra,0xffffc
    8000619c:	a0a080e7          	jalr	-1526(ra) # 80001ba2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061a0:	0085171b          	slliw	a4,a0,0x8
    800061a4:	0c0027b7          	lui	a5,0xc002
    800061a8:	97ba                	add	a5,a5,a4
    800061aa:	40200713          	li	a4,1026
    800061ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061b2:	00d5151b          	slliw	a0,a0,0xd
    800061b6:	0c2017b7          	lui	a5,0xc201
    800061ba:	97aa                	add	a5,a5,a0
    800061bc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800061c0:	60a2                	ld	ra,8(sp)
    800061c2:	6402                	ld	s0,0(sp)
    800061c4:	0141                	addi	sp,sp,16
    800061c6:	8082                	ret

00000000800061c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061c8:	1141                	addi	sp,sp,-16
    800061ca:	e406                	sd	ra,8(sp)
    800061cc:	e022                	sd	s0,0(sp)
    800061ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061d0:	ffffc097          	auipc	ra,0xffffc
    800061d4:	9d2080e7          	jalr	-1582(ra) # 80001ba2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061d8:	00d5151b          	slliw	a0,a0,0xd
    800061dc:	0c2017b7          	lui	a5,0xc201
    800061e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800061e2:	43c8                	lw	a0,4(a5)
    800061e4:	60a2                	ld	ra,8(sp)
    800061e6:	6402                	ld	s0,0(sp)
    800061e8:	0141                	addi	sp,sp,16
    800061ea:	8082                	ret

00000000800061ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061ec:	1101                	addi	sp,sp,-32
    800061ee:	ec06                	sd	ra,24(sp)
    800061f0:	e822                	sd	s0,16(sp)
    800061f2:	e426                	sd	s1,8(sp)
    800061f4:	1000                	addi	s0,sp,32
    800061f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061f8:	ffffc097          	auipc	ra,0xffffc
    800061fc:	9aa080e7          	jalr	-1622(ra) # 80001ba2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006200:	00d5151b          	slliw	a0,a0,0xd
    80006204:	0c2017b7          	lui	a5,0xc201
    80006208:	97aa                	add	a5,a5,a0
    8000620a:	c3c4                	sw	s1,4(a5)
}
    8000620c:	60e2                	ld	ra,24(sp)
    8000620e:	6442                	ld	s0,16(sp)
    80006210:	64a2                	ld	s1,8(sp)
    80006212:	6105                	addi	sp,sp,32
    80006214:	8082                	ret

0000000080006216 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006216:	1141                	addi	sp,sp,-16
    80006218:	e406                	sd	ra,8(sp)
    8000621a:	e022                	sd	s0,0(sp)
    8000621c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000621e:	479d                	li	a5,7
    80006220:	04a7cc63          	blt	a5,a0,80006278 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006224:	0001c797          	auipc	a5,0x1c
    80006228:	b7c78793          	addi	a5,a5,-1156 # 80021da0 <disk>
    8000622c:	97aa                	add	a5,a5,a0
    8000622e:	0187c783          	lbu	a5,24(a5)
    80006232:	ebb9                	bnez	a5,80006288 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006234:	00451693          	slli	a3,a0,0x4
    80006238:	0001c797          	auipc	a5,0x1c
    8000623c:	b6878793          	addi	a5,a5,-1176 # 80021da0 <disk>
    80006240:	6398                	ld	a4,0(a5)
    80006242:	9736                	add	a4,a4,a3
    80006244:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006248:	6398                	ld	a4,0(a5)
    8000624a:	9736                	add	a4,a4,a3
    8000624c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006250:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006254:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006258:	97aa                	add	a5,a5,a0
    8000625a:	4705                	li	a4,1
    8000625c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006260:	0001c517          	auipc	a0,0x1c
    80006264:	b5850513          	addi	a0,a0,-1192 # 80021db8 <disk+0x18>
    80006268:	ffffc097          	auipc	ra,0xffffc
    8000626c:	178080e7          	jalr	376(ra) # 800023e0 <wakeup>
}
    80006270:	60a2                	ld	ra,8(sp)
    80006272:	6402                	ld	s0,0(sp)
    80006274:	0141                	addi	sp,sp,16
    80006276:	8082                	ret
    panic("free_desc 1");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	60050513          	addi	a0,a0,1536 # 80008878 <syscalls+0x318>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2c0080e7          	jalr	704(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006288:	00002517          	auipc	a0,0x2
    8000628c:	60050513          	addi	a0,a0,1536 # 80008888 <syscalls+0x328>
    80006290:	ffffa097          	auipc	ra,0xffffa
    80006294:	2b0080e7          	jalr	688(ra) # 80000540 <panic>

0000000080006298 <virtio_disk_init>:
{
    80006298:	1101                	addi	sp,sp,-32
    8000629a:	ec06                	sd	ra,24(sp)
    8000629c:	e822                	sd	s0,16(sp)
    8000629e:	e426                	sd	s1,8(sp)
    800062a0:	e04a                	sd	s2,0(sp)
    800062a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062a4:	00002597          	auipc	a1,0x2
    800062a8:	5f458593          	addi	a1,a1,1524 # 80008898 <syscalls+0x338>
    800062ac:	0001c517          	auipc	a0,0x1c
    800062b0:	c1c50513          	addi	a0,a0,-996 # 80021ec8 <disk+0x128>
    800062b4:	ffffb097          	auipc	ra,0xffffb
    800062b8:	95a080e7          	jalr	-1702(ra) # 80000c0e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062bc:	100017b7          	lui	a5,0x10001
    800062c0:	4398                	lw	a4,0(a5)
    800062c2:	2701                	sext.w	a4,a4
    800062c4:	747277b7          	lui	a5,0x74727
    800062c8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062cc:	14f71b63          	bne	a4,a5,80006422 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062d0:	100017b7          	lui	a5,0x10001
    800062d4:	43dc                	lw	a5,4(a5)
    800062d6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062d8:	4709                	li	a4,2
    800062da:	14e79463          	bne	a5,a4,80006422 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062de:	100017b7          	lui	a5,0x10001
    800062e2:	479c                	lw	a5,8(a5)
    800062e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062e6:	12e79e63          	bne	a5,a4,80006422 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062ea:	100017b7          	lui	a5,0x10001
    800062ee:	47d8                	lw	a4,12(a5)
    800062f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062f2:	554d47b7          	lui	a5,0x554d4
    800062f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062fa:	12f71463          	bne	a4,a5,80006422 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062fe:	100017b7          	lui	a5,0x10001
    80006302:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006306:	4705                	li	a4,1
    80006308:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000630a:	470d                	li	a4,3
    8000630c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000630e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006310:	c7ffe6b7          	lui	a3,0xc7ffe
    80006314:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc87f>
    80006318:	8f75                	and	a4,a4,a3
    8000631a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000631c:	472d                	li	a4,11
    8000631e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006320:	5bbc                	lw	a5,112(a5)
    80006322:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006326:	8ba1                	andi	a5,a5,8
    80006328:	10078563          	beqz	a5,80006432 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000632c:	100017b7          	lui	a5,0x10001
    80006330:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006334:	43fc                	lw	a5,68(a5)
    80006336:	2781                	sext.w	a5,a5
    80006338:	10079563          	bnez	a5,80006442 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000633c:	100017b7          	lui	a5,0x10001
    80006340:	5bdc                	lw	a5,52(a5)
    80006342:	2781                	sext.w	a5,a5
  if(max == 0)
    80006344:	10078763          	beqz	a5,80006452 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006348:	471d                	li	a4,7
    8000634a:	10f77c63          	bgeu	a4,a5,80006462 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000634e:	ffffb097          	auipc	ra,0xffffb
    80006352:	814080e7          	jalr	-2028(ra) # 80000b62 <kalloc>
    80006356:	0001c497          	auipc	s1,0x1c
    8000635a:	a4a48493          	addi	s1,s1,-1462 # 80021da0 <disk>
    8000635e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006360:	ffffb097          	auipc	ra,0xffffb
    80006364:	802080e7          	jalr	-2046(ra) # 80000b62 <kalloc>
    80006368:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000636a:	ffffa097          	auipc	ra,0xffffa
    8000636e:	7f8080e7          	jalr	2040(ra) # 80000b62 <kalloc>
    80006372:	87aa                	mv	a5,a0
    80006374:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006376:	6088                	ld	a0,0(s1)
    80006378:	cd6d                	beqz	a0,80006472 <virtio_disk_init+0x1da>
    8000637a:	0001c717          	auipc	a4,0x1c
    8000637e:	a2e73703          	ld	a4,-1490(a4) # 80021da8 <disk+0x8>
    80006382:	cb65                	beqz	a4,80006472 <virtio_disk_init+0x1da>
    80006384:	c7fd                	beqz	a5,80006472 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006386:	6605                	lui	a2,0x1
    80006388:	4581                	li	a1,0
    8000638a:	ffffb097          	auipc	ra,0xffffb
    8000638e:	a10080e7          	jalr	-1520(ra) # 80000d9a <memset>
  memset(disk.avail, 0, PGSIZE);
    80006392:	0001c497          	auipc	s1,0x1c
    80006396:	a0e48493          	addi	s1,s1,-1522 # 80021da0 <disk>
    8000639a:	6605                	lui	a2,0x1
    8000639c:	4581                	li	a1,0
    8000639e:	6488                	ld	a0,8(s1)
    800063a0:	ffffb097          	auipc	ra,0xffffb
    800063a4:	9fa080e7          	jalr	-1542(ra) # 80000d9a <memset>
  memset(disk.used, 0, PGSIZE);
    800063a8:	6605                	lui	a2,0x1
    800063aa:	4581                	li	a1,0
    800063ac:	6888                	ld	a0,16(s1)
    800063ae:	ffffb097          	auipc	ra,0xffffb
    800063b2:	9ec080e7          	jalr	-1556(ra) # 80000d9a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063b6:	100017b7          	lui	a5,0x10001
    800063ba:	4721                	li	a4,8
    800063bc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063be:	4098                	lw	a4,0(s1)
    800063c0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063c4:	40d8                	lw	a4,4(s1)
    800063c6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063ca:	6498                	ld	a4,8(s1)
    800063cc:	0007069b          	sext.w	a3,a4
    800063d0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063d4:	9701                	srai	a4,a4,0x20
    800063d6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063da:	6898                	ld	a4,16(s1)
    800063dc:	0007069b          	sext.w	a3,a4
    800063e0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063e4:	9701                	srai	a4,a4,0x20
    800063e6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063ea:	4705                	li	a4,1
    800063ec:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800063ee:	00e48c23          	sb	a4,24(s1)
    800063f2:	00e48ca3          	sb	a4,25(s1)
    800063f6:	00e48d23          	sb	a4,26(s1)
    800063fa:	00e48da3          	sb	a4,27(s1)
    800063fe:	00e48e23          	sb	a4,28(s1)
    80006402:	00e48ea3          	sb	a4,29(s1)
    80006406:	00e48f23          	sb	a4,30(s1)
    8000640a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000640e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006412:	0727a823          	sw	s2,112(a5)
}
    80006416:	60e2                	ld	ra,24(sp)
    80006418:	6442                	ld	s0,16(sp)
    8000641a:	64a2                	ld	s1,8(sp)
    8000641c:	6902                	ld	s2,0(sp)
    8000641e:	6105                	addi	sp,sp,32
    80006420:	8082                	ret
    panic("could not find virtio disk");
    80006422:	00002517          	auipc	a0,0x2
    80006426:	48650513          	addi	a0,a0,1158 # 800088a8 <syscalls+0x348>
    8000642a:	ffffa097          	auipc	ra,0xffffa
    8000642e:	116080e7          	jalr	278(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006432:	00002517          	auipc	a0,0x2
    80006436:	49650513          	addi	a0,a0,1174 # 800088c8 <syscalls+0x368>
    8000643a:	ffffa097          	auipc	ra,0xffffa
    8000643e:	106080e7          	jalr	262(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006442:	00002517          	auipc	a0,0x2
    80006446:	4a650513          	addi	a0,a0,1190 # 800088e8 <syscalls+0x388>
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	0f6080e7          	jalr	246(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006452:	00002517          	auipc	a0,0x2
    80006456:	4b650513          	addi	a0,a0,1206 # 80008908 <syscalls+0x3a8>
    8000645a:	ffffa097          	auipc	ra,0xffffa
    8000645e:	0e6080e7          	jalr	230(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006462:	00002517          	auipc	a0,0x2
    80006466:	4c650513          	addi	a0,a0,1222 # 80008928 <syscalls+0x3c8>
    8000646a:	ffffa097          	auipc	ra,0xffffa
    8000646e:	0d6080e7          	jalr	214(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006472:	00002517          	auipc	a0,0x2
    80006476:	4d650513          	addi	a0,a0,1238 # 80008948 <syscalls+0x3e8>
    8000647a:	ffffa097          	auipc	ra,0xffffa
    8000647e:	0c6080e7          	jalr	198(ra) # 80000540 <panic>

0000000080006482 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006482:	7119                	addi	sp,sp,-128
    80006484:	fc86                	sd	ra,120(sp)
    80006486:	f8a2                	sd	s0,112(sp)
    80006488:	f4a6                	sd	s1,104(sp)
    8000648a:	f0ca                	sd	s2,96(sp)
    8000648c:	ecce                	sd	s3,88(sp)
    8000648e:	e8d2                	sd	s4,80(sp)
    80006490:	e4d6                	sd	s5,72(sp)
    80006492:	e0da                	sd	s6,64(sp)
    80006494:	fc5e                	sd	s7,56(sp)
    80006496:	f862                	sd	s8,48(sp)
    80006498:	f466                	sd	s9,40(sp)
    8000649a:	f06a                	sd	s10,32(sp)
    8000649c:	ec6e                	sd	s11,24(sp)
    8000649e:	0100                	addi	s0,sp,128
    800064a0:	8aaa                	mv	s5,a0
    800064a2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064a4:	00c52d03          	lw	s10,12(a0)
    800064a8:	001d1d1b          	slliw	s10,s10,0x1
    800064ac:	1d02                	slli	s10,s10,0x20
    800064ae:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800064b2:	0001c517          	auipc	a0,0x1c
    800064b6:	a1650513          	addi	a0,a0,-1514 # 80021ec8 <disk+0x128>
    800064ba:	ffffa097          	auipc	ra,0xffffa
    800064be:	7e4080e7          	jalr	2020(ra) # 80000c9e <acquire>
  for(int i = 0; i < 3; i++){
    800064c2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064c4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064c6:	0001cb97          	auipc	s7,0x1c
    800064ca:	8dab8b93          	addi	s7,s7,-1830 # 80021da0 <disk>
  for(int i = 0; i < 3; i++){
    800064ce:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064d0:	0001cc97          	auipc	s9,0x1c
    800064d4:	9f8c8c93          	addi	s9,s9,-1544 # 80021ec8 <disk+0x128>
    800064d8:	a08d                	j	8000653a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064da:	00fb8733          	add	a4,s7,a5
    800064de:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064e2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064e4:	0207c563          	bltz	a5,8000650e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064e8:	2905                	addiw	s2,s2,1
    800064ea:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800064ec:	05690c63          	beq	s2,s6,80006544 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800064f0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064f2:	0001c717          	auipc	a4,0x1c
    800064f6:	8ae70713          	addi	a4,a4,-1874 # 80021da0 <disk>
    800064fa:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064fc:	01874683          	lbu	a3,24(a4)
    80006500:	fee9                	bnez	a3,800064da <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006502:	2785                	addiw	a5,a5,1
    80006504:	0705                	addi	a4,a4,1
    80006506:	fe979be3          	bne	a5,s1,800064fc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000650a:	57fd                	li	a5,-1
    8000650c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000650e:	01205d63          	blez	s2,80006528 <virtio_disk_rw+0xa6>
    80006512:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006514:	000a2503          	lw	a0,0(s4)
    80006518:	00000097          	auipc	ra,0x0
    8000651c:	cfe080e7          	jalr	-770(ra) # 80006216 <free_desc>
      for(int j = 0; j < i; j++)
    80006520:	2d85                	addiw	s11,s11,1
    80006522:	0a11                	addi	s4,s4,4
    80006524:	ff2d98e3          	bne	s11,s2,80006514 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006528:	85e6                	mv	a1,s9
    8000652a:	0001c517          	auipc	a0,0x1c
    8000652e:	88e50513          	addi	a0,a0,-1906 # 80021db8 <disk+0x18>
    80006532:	ffffc097          	auipc	ra,0xffffc
    80006536:	e4a080e7          	jalr	-438(ra) # 8000237c <sleep>
  for(int i = 0; i < 3; i++){
    8000653a:	f8040a13          	addi	s4,s0,-128
{
    8000653e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006540:	894e                	mv	s2,s3
    80006542:	b77d                	j	800064f0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006544:	f8042503          	lw	a0,-128(s0)
    80006548:	00a50713          	addi	a4,a0,10
    8000654c:	0712                	slli	a4,a4,0x4

  if(write)
    8000654e:	0001c797          	auipc	a5,0x1c
    80006552:	85278793          	addi	a5,a5,-1966 # 80021da0 <disk>
    80006556:	00e786b3          	add	a3,a5,a4
    8000655a:	01803633          	snez	a2,s8
    8000655e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006560:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006564:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006568:	f6070613          	addi	a2,a4,-160
    8000656c:	6394                	ld	a3,0(a5)
    8000656e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006570:	00870593          	addi	a1,a4,8
    80006574:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006576:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006578:	0007b803          	ld	a6,0(a5)
    8000657c:	9642                	add	a2,a2,a6
    8000657e:	46c1                	li	a3,16
    80006580:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006582:	4585                	li	a1,1
    80006584:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006588:	f8442683          	lw	a3,-124(s0)
    8000658c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006590:	0692                	slli	a3,a3,0x4
    80006592:	9836                	add	a6,a6,a3
    80006594:	058a8613          	addi	a2,s5,88
    80006598:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000659c:	0007b803          	ld	a6,0(a5)
    800065a0:	96c2                	add	a3,a3,a6
    800065a2:	40000613          	li	a2,1024
    800065a6:	c690                	sw	a2,8(a3)
  if(write)
    800065a8:	001c3613          	seqz	a2,s8
    800065ac:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065b0:	00166613          	ori	a2,a2,1
    800065b4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800065b8:	f8842603          	lw	a2,-120(s0)
    800065bc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065c0:	00250693          	addi	a3,a0,2
    800065c4:	0692                	slli	a3,a3,0x4
    800065c6:	96be                	add	a3,a3,a5
    800065c8:	58fd                	li	a7,-1
    800065ca:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065ce:	0612                	slli	a2,a2,0x4
    800065d0:	9832                	add	a6,a6,a2
    800065d2:	f9070713          	addi	a4,a4,-112
    800065d6:	973e                	add	a4,a4,a5
    800065d8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800065dc:	6398                	ld	a4,0(a5)
    800065de:	9732                	add	a4,a4,a2
    800065e0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065e2:	4609                	li	a2,2
    800065e4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800065e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065ec:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800065f0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065f4:	6794                	ld	a3,8(a5)
    800065f6:	0026d703          	lhu	a4,2(a3)
    800065fa:	8b1d                	andi	a4,a4,7
    800065fc:	0706                	slli	a4,a4,0x1
    800065fe:	96ba                	add	a3,a3,a4
    80006600:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006604:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006608:	6798                	ld	a4,8(a5)
    8000660a:	00275783          	lhu	a5,2(a4)
    8000660e:	2785                	addiw	a5,a5,1
    80006610:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006614:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006618:	100017b7          	lui	a5,0x10001
    8000661c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006620:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006624:	0001c917          	auipc	s2,0x1c
    80006628:	8a490913          	addi	s2,s2,-1884 # 80021ec8 <disk+0x128>
  while(b->disk == 1) {
    8000662c:	4485                	li	s1,1
    8000662e:	00b79c63          	bne	a5,a1,80006646 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006632:	85ca                	mv	a1,s2
    80006634:	8556                	mv	a0,s5
    80006636:	ffffc097          	auipc	ra,0xffffc
    8000663a:	d46080e7          	jalr	-698(ra) # 8000237c <sleep>
  while(b->disk == 1) {
    8000663e:	004aa783          	lw	a5,4(s5)
    80006642:	fe9788e3          	beq	a5,s1,80006632 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006646:	f8042903          	lw	s2,-128(s0)
    8000664a:	00290713          	addi	a4,s2,2
    8000664e:	0712                	slli	a4,a4,0x4
    80006650:	0001b797          	auipc	a5,0x1b
    80006654:	75078793          	addi	a5,a5,1872 # 80021da0 <disk>
    80006658:	97ba                	add	a5,a5,a4
    8000665a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000665e:	0001b997          	auipc	s3,0x1b
    80006662:	74298993          	addi	s3,s3,1858 # 80021da0 <disk>
    80006666:	00491713          	slli	a4,s2,0x4
    8000666a:	0009b783          	ld	a5,0(s3)
    8000666e:	97ba                	add	a5,a5,a4
    80006670:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006674:	854a                	mv	a0,s2
    80006676:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000667a:	00000097          	auipc	ra,0x0
    8000667e:	b9c080e7          	jalr	-1124(ra) # 80006216 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006682:	8885                	andi	s1,s1,1
    80006684:	f0ed                	bnez	s1,80006666 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006686:	0001c517          	auipc	a0,0x1c
    8000668a:	84250513          	addi	a0,a0,-1982 # 80021ec8 <disk+0x128>
    8000668e:	ffffa097          	auipc	ra,0xffffa
    80006692:	6c4080e7          	jalr	1732(ra) # 80000d52 <release>
}
    80006696:	70e6                	ld	ra,120(sp)
    80006698:	7446                	ld	s0,112(sp)
    8000669a:	74a6                	ld	s1,104(sp)
    8000669c:	7906                	ld	s2,96(sp)
    8000669e:	69e6                	ld	s3,88(sp)
    800066a0:	6a46                	ld	s4,80(sp)
    800066a2:	6aa6                	ld	s5,72(sp)
    800066a4:	6b06                	ld	s6,64(sp)
    800066a6:	7be2                	ld	s7,56(sp)
    800066a8:	7c42                	ld	s8,48(sp)
    800066aa:	7ca2                	ld	s9,40(sp)
    800066ac:	7d02                	ld	s10,32(sp)
    800066ae:	6de2                	ld	s11,24(sp)
    800066b0:	6109                	addi	sp,sp,128
    800066b2:	8082                	ret

00000000800066b4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066b4:	1101                	addi	sp,sp,-32
    800066b6:	ec06                	sd	ra,24(sp)
    800066b8:	e822                	sd	s0,16(sp)
    800066ba:	e426                	sd	s1,8(sp)
    800066bc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066be:	0001b497          	auipc	s1,0x1b
    800066c2:	6e248493          	addi	s1,s1,1762 # 80021da0 <disk>
    800066c6:	0001c517          	auipc	a0,0x1c
    800066ca:	80250513          	addi	a0,a0,-2046 # 80021ec8 <disk+0x128>
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	5d0080e7          	jalr	1488(ra) # 80000c9e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066d6:	10001737          	lui	a4,0x10001
    800066da:	533c                	lw	a5,96(a4)
    800066dc:	8b8d                	andi	a5,a5,3
    800066de:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066e0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066e4:	689c                	ld	a5,16(s1)
    800066e6:	0204d703          	lhu	a4,32(s1)
    800066ea:	0027d783          	lhu	a5,2(a5)
    800066ee:	04f70863          	beq	a4,a5,8000673e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066f2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066f6:	6898                	ld	a4,16(s1)
    800066f8:	0204d783          	lhu	a5,32(s1)
    800066fc:	8b9d                	andi	a5,a5,7
    800066fe:	078e                	slli	a5,a5,0x3
    80006700:	97ba                	add	a5,a5,a4
    80006702:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006704:	00278713          	addi	a4,a5,2
    80006708:	0712                	slli	a4,a4,0x4
    8000670a:	9726                	add	a4,a4,s1
    8000670c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006710:	e721                	bnez	a4,80006758 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006712:	0789                	addi	a5,a5,2
    80006714:	0792                	slli	a5,a5,0x4
    80006716:	97a6                	add	a5,a5,s1
    80006718:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000671a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000671e:	ffffc097          	auipc	ra,0xffffc
    80006722:	cc2080e7          	jalr	-830(ra) # 800023e0 <wakeup>

    disk.used_idx += 1;
    80006726:	0204d783          	lhu	a5,32(s1)
    8000672a:	2785                	addiw	a5,a5,1
    8000672c:	17c2                	slli	a5,a5,0x30
    8000672e:	93c1                	srli	a5,a5,0x30
    80006730:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006734:	6898                	ld	a4,16(s1)
    80006736:	00275703          	lhu	a4,2(a4)
    8000673a:	faf71ce3          	bne	a4,a5,800066f2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000673e:	0001b517          	auipc	a0,0x1b
    80006742:	78a50513          	addi	a0,a0,1930 # 80021ec8 <disk+0x128>
    80006746:	ffffa097          	auipc	ra,0xffffa
    8000674a:	60c080e7          	jalr	1548(ra) # 80000d52 <release>
}
    8000674e:	60e2                	ld	ra,24(sp)
    80006750:	6442                	ld	s0,16(sp)
    80006752:	64a2                	ld	s1,8(sp)
    80006754:	6105                	addi	sp,sp,32
    80006756:	8082                	ret
      panic("virtio_disk_intr status");
    80006758:	00002517          	auipc	a0,0x2
    8000675c:	20850513          	addi	a0,a0,520 # 80008960 <syscalls+0x400>
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	de0080e7          	jalr	-544(ra) # 80000540 <panic>
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
