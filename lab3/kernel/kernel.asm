
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	6e013103          	ld	sp,1760(sp) # 8000b6e0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

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
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
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
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	70070713          	addi	a4,a4,1792 # 8000b750 <timer_scratch>
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
    80000066:	6de78793          	addi	a5,a5,1758 # 80006740 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd1c27>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	12478793          	addi	a5,a5,292 # 800011d0 <main>
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
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
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
    8000012e:	a8e080e7          	jalr	-1394(ra) # 80002bb8 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7f6080e7          	jalr	2038(ra) # 80000930 <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
    }

    return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000188:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	70450513          	addi	a0,a0,1796 # 80013890 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	da2080e7          	jalr	-606(ra) # 80000f36 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	6f448493          	addi	s1,s1,1780 # 80013890 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	78490913          	addi	s2,s2,1924 # 80013928 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	dec080e7          	jalr	-532(ra) # 80001fa8 <myproc>
    800001c4:	00003097          	auipc	ra,0x3
    800001c8:	83e080e7          	jalr	-1986(ra) # 80002a02 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	588080e7          	jalr	1416(ra) # 8000275a <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	6a870713          	addi	a4,a4,1704 # 80013890 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

        if (c == C('D'))
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
            }
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00003097          	auipc	ra,0x3
    8000021e:	948080e7          	jalr	-1720(ra) # 80002b62 <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
            break;

        dst++;
    80000228:	0a05                	addi	s4,s4,1
        --n;
    8000022a:	39fd                	addiw	s3,s3,-1

        if (c == '\n')
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
                release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	65a50513          	addi	a0,a0,1626 # 80013890 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	dac080e7          	jalr	-596(ra) # 80000fea <release>
                return -1;
    80000246:	557d                	li	a0,-1
        }
    }
    release(&cons.lock);

    return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
            if (n < target)
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
                cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	6cf72223          	sw	a5,1732(a4) # 80013928 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	61650513          	addi	a0,a0,1558 # 80013890 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	d68080e7          	jalr	-664(ra) # 80000fea <release>
    return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
        uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	5ae080e7          	jalr	1454(ra) # 80000852 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
        uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	59c080e7          	jalr	1436(ra) # 80000852 <uartputc_sync>
        uartputc_sync(' ');
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	590080e7          	jalr	1424(ra) # 80000852 <uartputc_sync>
        uartputc_sync('\b');
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	586080e7          	jalr	1414(ra) # 80000852 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	5ae50513          	addi	a0,a0,1454 # 80013890 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	c4c080e7          	jalr	-948(ra) # 80000f36 <acquire>

    switch (c)
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
    {
    case C('P'): // Print process list.
        procdump();
    80000308:	00003097          	auipc	ra,0x3
    8000030c:	906080e7          	jalr	-1786(ra) # 80002c0e <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	58050513          	addi	a0,a0,1408 # 80013890 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	cd2080e7          	jalr	-814(ra) # 80000fea <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
    switch (c)
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000332:	00013717          	auipc	a4,0x13
    80000336:	55e70713          	addi	a4,a4,1374 # 80013890 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
            c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
            consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	53478793          	addi	a5,a5,1332 # 80013890 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	59e7a783          	lw	a5,1438(a5) # 80013928 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	4f070713          	addi	a4,a4,1264 # 80013890 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	4e048493          	addi	s1,s1,1248 # 80013890 <cons>
        while (cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
            cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
        while (cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
        if (cons.e != cons.w)
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	49a70713          	addi	a4,a4,1178 # 80013890 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	52f72223          	sw	a5,1316(a4) # 80013930 <cons+0xa0>
            consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
            consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	45e78793          	addi	a5,a5,1118 # 80013890 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	4cc7ab23          	sw	a2,1238(a5) # 8001392c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	4ca50513          	addi	a0,a0,1226 # 80013928 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	358080e7          	jalr	856(ra) # 800027be <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b9858593          	addi	a1,a1,-1128 # 80008010 <__func__.1+0x8>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	41050513          	addi	a0,a0,1040 # 80013890 <cons>
    80000488:	00001097          	auipc	ra,0x1
    8000048c:	a1e080e7          	jalr	-1506(ra) # 80000ea6 <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	0002b797          	auipc	a5,0x2b
    8000049c:	5a878793          	addi	a5,a5,1448 # 8002ba40 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004d2:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	3fa60613          	addi	a2,a2,1018 # 800088d0 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

    if (sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
        buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
    while (--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
        x = -xx;
    80000558:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
        x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000560:	711d                	addi	sp,sp,-96
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
    8000056c:	e40c                	sd	a1,8(s0)
    8000056e:	e810                	sd	a2,16(s0)
    80000570:	ec14                	sd	a3,24(s0)
    80000572:	f018                	sd	a4,32(s0)
    80000574:	f41c                	sd	a5,40(s0)
    80000576:	03043823          	sd	a6,48(s0)
    8000057a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000057e:	00013797          	auipc	a5,0x13
    80000582:	3c07a923          	sw	zero,978(a5) # 80013950 <pr+0x18>
    printf("panic: ");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	a9250513          	addi	a0,a0,-1390 # 80008018 <__func__.1+0x10>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	02e080e7          	jalr	46(ra) # 800005bc <printf>
    printf(s);
    80000596:	8526                	mv	a0,s1
    80000598:	00000097          	auipc	ra,0x0
    8000059c:	024080e7          	jalr	36(ra) # 800005bc <printf>
    printf("\n");
    800005a0:	00008517          	auipc	a0,0x8
    800005a4:	a8050513          	addi	a0,a0,-1408 # 80008020 <__func__.1+0x18>
    800005a8:	00000097          	auipc	ra,0x0
    800005ac:	014080e7          	jalr	20(ra) # 800005bc <printf>
    panicked = 1; // freeze uart output from other CPUs
    800005b0:	4785                	li	a5,1
    800005b2:	0000b717          	auipc	a4,0xb
    800005b6:	14f72723          	sw	a5,334(a4) # 8000b700 <panicked>
    for (;;)
    800005ba:	a001                	j	800005ba <panic+0x5a>

00000000800005bc <printf>:
{
    800005bc:	7131                	addi	sp,sp,-192
    800005be:	fc86                	sd	ra,120(sp)
    800005c0:	f8a2                	sd	s0,112(sp)
    800005c2:	e8d2                	sd	s4,80(sp)
    800005c4:	f06a                	sd	s10,32(sp)
    800005c6:	0100                	addi	s0,sp,128
    800005c8:	8a2a                	mv	s4,a0
    800005ca:	e40c                	sd	a1,8(s0)
    800005cc:	e810                	sd	a2,16(s0)
    800005ce:	ec14                	sd	a3,24(s0)
    800005d0:	f018                	sd	a4,32(s0)
    800005d2:	f41c                	sd	a5,40(s0)
    800005d4:	03043823          	sd	a6,48(s0)
    800005d8:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005dc:	00013d17          	auipc	s10,0x13
    800005e0:	374d2d03          	lw	s10,884(s10) # 80013950 <pr+0x18>
    if (locking)
    800005e4:	040d1463          	bnez	s10,8000062c <printf+0x70>
    if (fmt == 0)
    800005e8:	040a0b63          	beqz	s4,8000063e <printf+0x82>
    va_start(ap, fmt);
    800005ec:	00840793          	addi	a5,s0,8
    800005f0:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005f4:	000a4503          	lbu	a0,0(s4)
    800005f8:	18050b63          	beqz	a0,8000078e <printf+0x1d2>
    800005fc:	f4a6                	sd	s1,104(sp)
    800005fe:	f0ca                	sd	s2,96(sp)
    80000600:	ecce                	sd	s3,88(sp)
    80000602:	e4d6                	sd	s5,72(sp)
    80000604:	e0da                	sd	s6,64(sp)
    80000606:	fc5e                	sd	s7,56(sp)
    80000608:	f862                	sd	s8,48(sp)
    8000060a:	f466                	sd	s9,40(sp)
    8000060c:	ec6e                	sd	s11,24(sp)
    8000060e:	4981                	li	s3,0
        if (c != '%')
    80000610:	02500b13          	li	s6,37
        switch (c)
    80000614:	07000b93          	li	s7,112
    consputc('x');
    80000618:	4cc1                	li	s9,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000061a:	00008a97          	auipc	s5,0x8
    8000061e:	2b6a8a93          	addi	s5,s5,694 # 800088d0 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00013517          	auipc	a0,0x13
    80000630:	30c50513          	addi	a0,a0,780 # 80013938 <pr>
    80000634:	00001097          	auipc	ra,0x1
    80000638:	902080e7          	jalr	-1790(ra) # 80000f36 <acquire>
    8000063c:	b775                	j	800005e8 <printf+0x2c>
    8000063e:	f4a6                	sd	s1,104(sp)
    80000640:	f0ca                	sd	s2,96(sp)
    80000642:	ecce                	sd	s3,88(sp)
    80000644:	e4d6                	sd	s5,72(sp)
    80000646:	e0da                	sd	s6,64(sp)
    80000648:	fc5e                	sd	s7,56(sp)
    8000064a:	f862                	sd	s8,48(sp)
    8000064c:	f466                	sd	s9,40(sp)
    8000064e:	ec6e                	sd	s11,24(sp)
        panic("null fmt");
    80000650:	00008517          	auipc	a0,0x8
    80000654:	9e050513          	addi	a0,a0,-1568 # 80008030 <__func__.1+0x28>
    80000658:	00000097          	auipc	ra,0x0
    8000065c:	f08080e7          	jalr	-248(ra) # 80000560 <panic>
            consputc(c);
    80000660:	00000097          	auipc	ra,0x0
    80000664:	c34080e7          	jalr	-972(ra) # 80000294 <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c503          	lbu	a0,0(a5)
    80000672:	10050563          	beqz	a0,8000077c <printf+0x1c0>
        if (c != '%')
    80000676:	ff6515e3          	bne	a0,s6,80000660 <printf+0xa4>
        c = fmt[++i] & 0xff;
    8000067a:	2985                	addiw	s3,s3,1
    8000067c:	013a07b3          	add	a5,s4,s3
    80000680:	0007c783          	lbu	a5,0(a5)
    80000684:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000688:	10078b63          	beqz	a5,8000079e <printf+0x1e2>
        switch (c)
    8000068c:	05778a63          	beq	a5,s7,800006e0 <printf+0x124>
    80000690:	02fbf663          	bgeu	s7,a5,800006bc <printf+0x100>
    80000694:	09878863          	beq	a5,s8,80000724 <printf+0x168>
    80000698:	07800713          	li	a4,120
    8000069c:	0ce79563          	bne	a5,a4,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 16, 1);
    800006a0:	f8843783          	ld	a5,-120(s0)
    800006a4:	00878713          	addi	a4,a5,8
    800006a8:	f8e43423          	sd	a4,-120(s0)
    800006ac:	4605                	li	a2,1
    800006ae:	85e6                	mv	a1,s9
    800006b0:	4388                	lw	a0,0(a5)
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	e0a080e7          	jalr	-502(ra) # 800004bc <printint>
            break;
    800006ba:	b77d                	j	80000668 <printf+0xac>
        switch (c)
    800006bc:	09678f63          	beq	a5,s6,8000075a <printf+0x19e>
    800006c0:	0bb79363          	bne	a5,s11,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 10, 1);
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	4605                	li	a2,1
    800006d2:	45a9                	li	a1,10
    800006d4:	4388                	lw	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	de6080e7          	jalr	-538(ra) # 800004bc <printint>
            break;
    800006de:	b769                	j	80000668 <printf+0xac>
            printptr(va_arg(ap, uint64));
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006f0:	03000513          	li	a0,48
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	ba0080e7          	jalr	-1120(ra) # 80000294 <consputc>
    consputc('x');
    800006fc:	07800513          	li	a0,120
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b94080e7          	jalr	-1132(ra) # 80000294 <consputc>
    80000708:	84e6                	mv	s1,s9
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000070a:	03c95793          	srli	a5,s2,0x3c
    8000070e:	97d6                	add	a5,a5,s5
    80000710:	0007c503          	lbu	a0,0(a5)
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b80080e7          	jalr	-1152(ra) # 80000294 <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000071c:	0912                	slli	s2,s2,0x4
    8000071e:	34fd                	addiw	s1,s1,-1
    80000720:	f4ed                	bnez	s1,8000070a <printf+0x14e>
    80000722:	b799                	j	80000668 <printf+0xac>
            if ((s = va_arg(ap, char *)) == 0)
    80000724:	f8843783          	ld	a5,-120(s0)
    80000728:	00878713          	addi	a4,a5,8
    8000072c:	f8e43423          	sd	a4,-120(s0)
    80000730:	6384                	ld	s1,0(a5)
    80000732:	cc89                	beqz	s1,8000074c <printf+0x190>
            for (; *s; s++)
    80000734:	0004c503          	lbu	a0,0(s1)
    80000738:	d905                	beqz	a0,80000668 <printf+0xac>
                consputc(*s);
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b5a080e7          	jalr	-1190(ra) # 80000294 <consputc>
            for (; *s; s++)
    80000742:	0485                	addi	s1,s1,1
    80000744:	0004c503          	lbu	a0,0(s1)
    80000748:	f96d                	bnez	a0,8000073a <printf+0x17e>
    8000074a:	bf39                	j	80000668 <printf+0xac>
                s = "(null)";
    8000074c:	00008497          	auipc	s1,0x8
    80000750:	8dc48493          	addi	s1,s1,-1828 # 80008028 <__func__.1+0x20>
            for (; *s; s++)
    80000754:	02800513          	li	a0,40
    80000758:	b7cd                	j	8000073a <printf+0x17e>
            consputc('%');
    8000075a:	855a                	mv	a0,s6
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	b38080e7          	jalr	-1224(ra) # 80000294 <consputc>
            break;
    80000764:	b711                	j	80000668 <printf+0xac>
            consputc('%');
    80000766:	855a                	mv	a0,s6
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	b2c080e7          	jalr	-1236(ra) # 80000294 <consputc>
            consputc(c);
    80000770:	8526                	mv	a0,s1
    80000772:	00000097          	auipc	ra,0x0
    80000776:	b22080e7          	jalr	-1246(ra) # 80000294 <consputc>
            break;
    8000077a:	b5fd                	j	80000668 <printf+0xac>
    8000077c:	74a6                	ld	s1,104(sp)
    8000077e:	7906                	ld	s2,96(sp)
    80000780:	69e6                	ld	s3,88(sp)
    80000782:	6aa6                	ld	s5,72(sp)
    80000784:	6b06                	ld	s6,64(sp)
    80000786:	7be2                	ld	s7,56(sp)
    80000788:	7c42                	ld	s8,48(sp)
    8000078a:	7ca2                	ld	s9,40(sp)
    8000078c:	6de2                	ld	s11,24(sp)
    if (locking)
    8000078e:	020d1263          	bnez	s10,800007b2 <printf+0x1f6>
}
    80000792:	70e6                	ld	ra,120(sp)
    80000794:	7446                	ld	s0,112(sp)
    80000796:	6a46                	ld	s4,80(sp)
    80000798:	7d02                	ld	s10,32(sp)
    8000079a:	6129                	addi	sp,sp,192
    8000079c:	8082                	ret
    8000079e:	74a6                	ld	s1,104(sp)
    800007a0:	7906                	ld	s2,96(sp)
    800007a2:	69e6                	ld	s3,88(sp)
    800007a4:	6aa6                	ld	s5,72(sp)
    800007a6:	6b06                	ld	s6,64(sp)
    800007a8:	7be2                	ld	s7,56(sp)
    800007aa:	7c42                	ld	s8,48(sp)
    800007ac:	7ca2                	ld	s9,40(sp)
    800007ae:	6de2                	ld	s11,24(sp)
    800007b0:	bff9                	j	8000078e <printf+0x1d2>
        release(&pr.lock);
    800007b2:	00013517          	auipc	a0,0x13
    800007b6:	18650513          	addi	a0,a0,390 # 80013938 <pr>
    800007ba:	00001097          	auipc	ra,0x1
    800007be:	830080e7          	jalr	-2000(ra) # 80000fea <release>
}
    800007c2:	bfc1                	j	80000792 <printf+0x1d6>

00000000800007c4 <printfinit>:
        ;
}

void printfinit(void)
{
    800007c4:	1101                	addi	sp,sp,-32
    800007c6:	ec06                	sd	ra,24(sp)
    800007c8:	e822                	sd	s0,16(sp)
    800007ca:	e426                	sd	s1,8(sp)
    800007cc:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    800007ce:	00013497          	auipc	s1,0x13
    800007d2:	16a48493          	addi	s1,s1,362 # 80013938 <pr>
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	86a58593          	addi	a1,a1,-1942 # 80008040 <__func__.1+0x38>
    800007de:	8526                	mv	a0,s1
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	6c6080e7          	jalr	1734(ra) # 80000ea6 <initlock>
    pr.locking = 1;
    800007e8:	4785                	li	a5,1
    800007ea:	cc9c                	sw	a5,24(s1)
}
    800007ec:	60e2                	ld	ra,24(sp)
    800007ee:	6442                	ld	s0,16(sp)
    800007f0:	64a2                	ld	s1,8(sp)
    800007f2:	6105                	addi	sp,sp,32
    800007f4:	8082                	ret

00000000800007f6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007f6:	1141                	addi	sp,sp,-16
    800007f8:	e406                	sd	ra,8(sp)
    800007fa:	e022                	sd	s0,0(sp)
    800007fc:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007fe:	100007b7          	lui	a5,0x10000
    80000802:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000806:	10000737          	lui	a4,0x10000
    8000080a:	f8000693          	li	a3,-128
    8000080e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000812:	468d                	li	a3,3
    80000814:	10000637          	lui	a2,0x10000
    80000818:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000081c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000820:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000824:	10000737          	lui	a4,0x10000
    80000828:	461d                	li	a2,7
    8000082a:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000082e:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000832:	00008597          	auipc	a1,0x8
    80000836:	81658593          	addi	a1,a1,-2026 # 80008048 <__func__.1+0x40>
    8000083a:	00013517          	auipc	a0,0x13
    8000083e:	11e50513          	addi	a0,a0,286 # 80013958 <uart_tx_lock>
    80000842:	00000097          	auipc	ra,0x0
    80000846:	664080e7          	jalr	1636(ra) # 80000ea6 <initlock>
}
    8000084a:	60a2                	ld	ra,8(sp)
    8000084c:	6402                	ld	s0,0(sp)
    8000084e:	0141                	addi	sp,sp,16
    80000850:	8082                	ret

0000000080000852 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000852:	1101                	addi	sp,sp,-32
    80000854:	ec06                	sd	ra,24(sp)
    80000856:	e822                	sd	s0,16(sp)
    80000858:	e426                	sd	s1,8(sp)
    8000085a:	1000                	addi	s0,sp,32
    8000085c:	84aa                	mv	s1,a0
  push_off();
    8000085e:	00000097          	auipc	ra,0x0
    80000862:	68c080e7          	jalr	1676(ra) # 80000eea <push_off>

  if(panicked){
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	e9a7a783          	lw	a5,-358(a5) # 8000b700 <panicked>
    8000086e:	eb85                	bnez	a5,8000089e <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000870:	10000737          	lui	a4,0x10000
    80000874:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000876:	00074783          	lbu	a5,0(a4)
    8000087a:	0207f793          	andi	a5,a5,32
    8000087e:	dfe5                	beqz	a5,80000876 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000880:	0ff4f513          	zext.b	a0,s1
    80000884:	100007b7          	lui	a5,0x10000
    80000888:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088c:	00000097          	auipc	ra,0x0
    80000890:	6fe080e7          	jalr	1790(ra) # 80000f8a <pop_off>
}
    80000894:	60e2                	ld	ra,24(sp)
    80000896:	6442                	ld	s0,16(sp)
    80000898:	64a2                	ld	s1,8(sp)
    8000089a:	6105                	addi	sp,sp,32
    8000089c:	8082                	ret
    for(;;)
    8000089e:	a001                	j	8000089e <uartputc_sync+0x4c>

00000000800008a0 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a0:	0000b797          	auipc	a5,0xb
    800008a4:	e687b783          	ld	a5,-408(a5) # 8000b708 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	e6873703          	ld	a4,-408(a4) # 8000b710 <uart_tx_w>
    800008b0:	06f70f63          	beq	a4,a5,8000092e <uartstart+0x8e>
{
    800008b4:	7139                	addi	sp,sp,-64
    800008b6:	fc06                	sd	ra,56(sp)
    800008b8:	f822                	sd	s0,48(sp)
    800008ba:	f426                	sd	s1,40(sp)
    800008bc:	f04a                	sd	s2,32(sp)
    800008be:	ec4e                	sd	s3,24(sp)
    800008c0:	e852                	sd	s4,16(sp)
    800008c2:	e456                	sd	s5,8(sp)
    800008c4:	e05a                	sd	s6,0(sp)
    800008c6:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c8:	10000937          	lui	s2,0x10000
    800008cc:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ce:	00013a97          	auipc	s5,0x13
    800008d2:	08aa8a93          	addi	s5,s5,138 # 80013958 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	e3248493          	addi	s1,s1,-462 # 8000b708 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	e2e98993          	addi	s3,s3,-466 # 8000b710 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ea:	00094703          	lbu	a4,0(s2)
    800008ee:	02077713          	andi	a4,a4,32
    800008f2:	c705                	beqz	a4,8000091a <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f4:	01f7f713          	andi	a4,a5,31
    800008f8:	9756                	add	a4,a4,s5
    800008fa:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008fe:	0785                	addi	a5,a5,1
    80000900:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000902:	8526                	mv	a0,s1
    80000904:	00002097          	auipc	ra,0x2
    80000908:	eba080e7          	jalr	-326(ra) # 800027be <wakeup>
    WriteReg(THR, c);
    8000090c:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000910:	609c                	ld	a5,0(s1)
    80000912:	0009b703          	ld	a4,0(s3)
    80000916:	fcf71ae3          	bne	a4,a5,800008ea <uartstart+0x4a>
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
    8000092e:	8082                	ret

0000000080000930 <uartputc>:
{
    80000930:	7179                	addi	sp,sp,-48
    80000932:	f406                	sd	ra,40(sp)
    80000934:	f022                	sd	s0,32(sp)
    80000936:	ec26                	sd	s1,24(sp)
    80000938:	e84a                	sd	s2,16(sp)
    8000093a:	e44e                	sd	s3,8(sp)
    8000093c:	e052                	sd	s4,0(sp)
    8000093e:	1800                	addi	s0,sp,48
    80000940:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000942:	00013517          	auipc	a0,0x13
    80000946:	01650513          	addi	a0,a0,22 # 80013958 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	5ec080e7          	jalr	1516(ra) # 80000f36 <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	dae7a783          	lw	a5,-594(a5) # 8000b700 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	db473703          	ld	a4,-588(a4) # 8000b710 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	da47b783          	ld	a5,-604(a5) # 8000b708 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	fe898993          	addi	s3,s3,-24 # 80013958 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	d9048493          	addi	s1,s1,-624 # 8000b708 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	d9090913          	addi	s2,s2,-624 # 8000b710 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	dca080e7          	jalr	-566(ra) # 8000275a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	fb248493          	addi	s1,s1,-78 # 80013958 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	d4e7bb23          	sd	a4,-682(a5) # 8000b710 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ede080e7          	jalr	-290(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	61e080e7          	jalr	1566(ra) # 80000fea <release>
}
    800009d4:	70a2                	ld	ra,40(sp)
    800009d6:	7402                	ld	s0,32(sp)
    800009d8:	64e2                	ld	s1,24(sp)
    800009da:	6942                	ld	s2,16(sp)
    800009dc:	69a2                	ld	s3,8(sp)
    800009de:	6a02                	ld	s4,0(sp)
    800009e0:	6145                	addi	sp,sp,48
    800009e2:	8082                	ret
    for(;;)
    800009e4:	a001                	j	800009e4 <uartputc+0xb4>

00000000800009e6 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e6:	1141                	addi	sp,sp,-16
    800009e8:	e422                	sd	s0,8(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009f2:	0007c783          	lbu	a5,0(a5)
    800009f6:	8b85                	andi	a5,a5,1
    800009f8:	cb81                	beqz	a5,80000a08 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009fa:	100007b7          	lui	a5,0x10000
    800009fe:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a02:	6422                	ld	s0,8(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfe5                	j	80000a02 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    80000a18:	a029                	j	80000a22 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	8bc080e7          	jalr	-1860(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	fc4080e7          	jalr	-60(ra) # 800009e6 <uartgetc>
    if(c == -1)
    80000a2a:	fe9518e3          	bne	a0,s1,80000a1a <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a2e:	00013497          	auipc	s1,0x13
    80000a32:	f2a48493          	addi	s1,s1,-214 # 80013958 <uart_tx_lock>
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	4fe080e7          	jalr	1278(ra) # 80000f36 <acquire>
  uartstart();
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	e60080e7          	jalr	-416(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	5a0080e7          	jalr	1440(ra) # 80000fea <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <refindex>:
struct spinlock refcountlock;

int
refindex(uint64 pa)
{
    if (pa < (uint64) end || pa >= PHYSTOP)
    80000a5c:	0002c797          	auipc	a5,0x2c
    80000a60:	17c78793          	addi	a5,a5,380 # 8002cbd8 <end>
    80000a64:	00f56c63          	bltu	a0,a5,80000a7c <refindex+0x20>
    80000a68:	47c5                	li	a5,17
    80000a6a:	07ee                	slli	a5,a5,0x1b
    80000a6c:	00f57863          	bgeu	a0,a5,80000a7c <refindex+0x20>
        panic("refindex out of range");

    return (pa - KERNBASE) / PGSIZE;
    80000a70:	800007b7          	lui	a5,0x80000
    80000a74:	953e                	add	a0,a0,a5
    80000a76:	8131                	srli	a0,a0,0xc
}
    80000a78:	2501                	sext.w	a0,a0
    80000a7a:	8082                	ret
{
    80000a7c:	1141                	addi	sp,sp,-16
    80000a7e:	e406                	sd	ra,8(sp)
    80000a80:	e022                	sd	s0,0(sp)
    80000a82:	0800                	addi	s0,sp,16
        panic("refindex out of range");
    80000a84:	00007517          	auipc	a0,0x7
    80000a88:	5cc50513          	addi	a0,a0,1484 # 80008050 <__func__.1+0x48>
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	ad4080e7          	jalr	-1324(ra) # 80000560 <panic>

0000000080000a94 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a94:	7179                	addi	sp,sp,-48
    80000a96:	f406                	sd	ra,40(sp)
    80000a98:	f022                	sd	s0,32(sp)
    80000a9a:	ec26                	sd	s1,24(sp)
    80000a9c:	e84a                	sd	s2,16(sp)
    80000a9e:	e44e                	sd	s3,8(sp)
    80000aa0:	1800                	addi	s0,sp,48
    80000aa2:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000aa4:	0000b797          	auipc	a5,0xb
    80000aa8:	c7c7b783          	ld	a5,-900(a5) # 8000b720 <MAX_PAGES>
    80000aac:	c799                	beqz	a5,80000aba <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000aae:	0000b717          	auipc	a4,0xb
    80000ab2:	c6a73703          	ld	a4,-918(a4) # 8000b718 <FREE_PAGES>
    80000ab6:	08f77063          	bgeu	a4,a5,80000b36 <kfree+0xa2>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000aba:	03449793          	slli	a5,s1,0x34
    80000abe:	e7d5                	bnez	a5,80000b6a <kfree+0xd6>
    80000ac0:	0002c797          	auipc	a5,0x2c
    80000ac4:	11878793          	addi	a5,a5,280 # 8002cbd8 <end>
    80000ac8:	0af4e163          	bltu	s1,a5,80000b6a <kfree+0xd6>
    80000acc:	47c5                	li	a5,17
    80000ace:	07ee                	slli	a5,a5,0x1b
    80000ad0:	08f4fd63          	bgeu	s1,a5,80000b6a <kfree+0xd6>
        panic("kfree");

    // decrement refcount

    int i = refindex((uint64) pa);
    80000ad4:	8526                	mv	a0,s1
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f86080e7          	jalr	-122(ra) # 80000a5c <refindex>
    80000ade:	89aa                	mv	s3,a0

    acquire(&refcountlock);
    80000ae0:	00013517          	auipc	a0,0x13
    80000ae4:	eb050513          	addi	a0,a0,-336 # 80013990 <refcountlock>
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	44e080e7          	jalr	1102(ra) # 80000f36 <acquire>
    if (refcount[i] > 0) refcount[i]--;
    80000af0:	00013797          	auipc	a5,0x13
    80000af4:	ed878793          	addi	a5,a5,-296 # 800139c8 <refcount>
    80000af8:	97ce                	add	a5,a5,s3
    80000afa:	0007c783          	lbu	a5,0(a5)
    80000afe:	cfb5                	beqz	a5,80000b7a <kfree+0xe6>
    80000b00:	37fd                	addiw	a5,a5,-1
    80000b02:	0ff7f913          	zext.b	s2,a5
    80000b06:	00013797          	auipc	a5,0x13
    80000b0a:	ec278793          	addi	a5,a5,-318 # 800139c8 <refcount>
    80000b0e:	97ce                	add	a5,a5,s3
    80000b10:	01278023          	sb	s2,0(a5)
    int empty = refcount[i] == 0;
    release(&refcountlock);
    80000b14:	00013517          	auipc	a0,0x13
    80000b18:	e7c50513          	addi	a0,a0,-388 # 80013990 <refcountlock>
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	4ce080e7          	jalr	1230(ra) # 80000fea <release>

    if (!empty) return;
    80000b24:	06090363          	beqz	s2,80000b8a <kfree+0xf6>
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}
    80000b28:	70a2                	ld	ra,40(sp)
    80000b2a:	7402                	ld	s0,32(sp)
    80000b2c:	64e2                	ld	s1,24(sp)
    80000b2e:	6942                	ld	s2,16(sp)
    80000b30:	69a2                	ld	s3,8(sp)
    80000b32:	6145                	addi	sp,sp,48
    80000b34:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000b36:	04700693          	li	a3,71
    80000b3a:	00007617          	auipc	a2,0x7
    80000b3e:	4ce60613          	addi	a2,a2,1230 # 80008008 <__func__.1>
    80000b42:	00007597          	auipc	a1,0x7
    80000b46:	52658593          	addi	a1,a1,1318 # 80008068 <__func__.1+0x60>
    80000b4a:	00007517          	auipc	a0,0x7
    80000b4e:	52e50513          	addi	a0,a0,1326 # 80008078 <__func__.1+0x70>
    80000b52:	00000097          	auipc	ra,0x0
    80000b56:	a6a080e7          	jalr	-1430(ra) # 800005bc <printf>
    80000b5a:	00007517          	auipc	a0,0x7
    80000b5e:	52e50513          	addi	a0,a0,1326 # 80008088 <__func__.1+0x80>
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	9fe080e7          	jalr	-1538(ra) # 80000560 <panic>
        panic("kfree");
    80000b6a:	00007517          	auipc	a0,0x7
    80000b6e:	52e50513          	addi	a0,a0,1326 # 80008098 <__func__.1+0x90>
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	9ee080e7          	jalr	-1554(ra) # 80000560 <panic>
    release(&refcountlock);
    80000b7a:	00013517          	auipc	a0,0x13
    80000b7e:	e1650513          	addi	a0,a0,-490 # 80013990 <refcountlock>
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	468080e7          	jalr	1128(ra) # 80000fea <release>
    memset(pa, 1, PGSIZE);
    80000b8a:	6605                	lui	a2,0x1
    80000b8c:	4585                	li	a1,1
    80000b8e:	8526                	mv	a0,s1
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	4a2080e7          	jalr	1186(ra) # 80001032 <memset>
    acquire(&kmem.lock);
    80000b98:	00013997          	auipc	s3,0x13
    80000b9c:	df898993          	addi	s3,s3,-520 # 80013990 <refcountlock>
    80000ba0:	00013917          	auipc	s2,0x13
    80000ba4:	e0890913          	addi	s2,s2,-504 # 800139a8 <kmem>
    80000ba8:	854a                	mv	a0,s2
    80000baa:	00000097          	auipc	ra,0x0
    80000bae:	38c080e7          	jalr	908(ra) # 80000f36 <acquire>
    r->next = kmem.freelist;
    80000bb2:	0309b783          	ld	a5,48(s3)
    80000bb6:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000bb8:	0299b823          	sd	s1,48(s3)
    FREE_PAGES++;
    80000bbc:	0000b717          	auipc	a4,0xb
    80000bc0:	b5c70713          	addi	a4,a4,-1188 # 8000b718 <FREE_PAGES>
    80000bc4:	631c                	ld	a5,0(a4)
    80000bc6:	0785                	addi	a5,a5,1
    80000bc8:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000bca:	854a                	mv	a0,s2
    80000bcc:	00000097          	auipc	ra,0x0
    80000bd0:	41e080e7          	jalr	1054(ra) # 80000fea <release>
    80000bd4:	bf91                	j	80000b28 <kfree+0x94>

0000000080000bd6 <freerange>:
{
    80000bd6:	7179                	addi	sp,sp,-48
    80000bd8:	f406                	sd	ra,40(sp)
    80000bda:	f022                	sd	s0,32(sp)
    80000bdc:	ec26                	sd	s1,24(sp)
    80000bde:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000be0:	6785                	lui	a5,0x1
    80000be2:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000be6:	00e504b3          	add	s1,a0,a4
    80000bea:	777d                	lui	a4,0xfffff
    80000bec:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bee:	94be                	add	s1,s1,a5
    80000bf0:	0295e463          	bltu	a1,s1,80000c18 <freerange+0x42>
    80000bf4:	e84a                	sd	s2,16(sp)
    80000bf6:	e44e                	sd	s3,8(sp)
    80000bf8:	e052                	sd	s4,0(sp)
    80000bfa:	892e                	mv	s2,a1
        kfree(p);
    80000bfc:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bfe:	6985                	lui	s3,0x1
        kfree(p);
    80000c00:	01448533          	add	a0,s1,s4
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	e90080e7          	jalr	-368(ra) # 80000a94 <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c0c:	94ce                	add	s1,s1,s3
    80000c0e:	fe9979e3          	bgeu	s2,s1,80000c00 <freerange+0x2a>
    80000c12:	6942                	ld	s2,16(sp)
    80000c14:	69a2                	ld	s3,8(sp)
    80000c16:	6a02                	ld	s4,0(sp)
}
    80000c18:	70a2                	ld	ra,40(sp)
    80000c1a:	7402                	ld	s0,32(sp)
    80000c1c:	64e2                	ld	s1,24(sp)
    80000c1e:	6145                	addi	sp,sp,48
    80000c20:	8082                	ret

0000000080000c22 <kinit>:
{
    80000c22:	1141                	addi	sp,sp,-16
    80000c24:	e406                	sd	ra,8(sp)
    80000c26:	e022                	sd	s0,0(sp)
    80000c28:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000c2a:	00007597          	auipc	a1,0x7
    80000c2e:	47658593          	addi	a1,a1,1142 # 800080a0 <__func__.1+0x98>
    80000c32:	00013517          	auipc	a0,0x13
    80000c36:	d7650513          	addi	a0,a0,-650 # 800139a8 <kmem>
    80000c3a:	00000097          	auipc	ra,0x0
    80000c3e:	26c080e7          	jalr	620(ra) # 80000ea6 <initlock>
    initlock(&refcountlock, "refcount");
    80000c42:	00007597          	auipc	a1,0x7
    80000c46:	46658593          	addi	a1,a1,1126 # 800080a8 <__func__.1+0xa0>
    80000c4a:	00013517          	auipc	a0,0x13
    80000c4e:	d4650513          	addi	a0,a0,-698 # 80013990 <refcountlock>
    80000c52:	00000097          	auipc	ra,0x0
    80000c56:	254080e7          	jalr	596(ra) # 80000ea6 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000c5a:	45c5                	li	a1,17
    80000c5c:	05ee                	slli	a1,a1,0x1b
    80000c5e:	0002c517          	auipc	a0,0x2c
    80000c62:	f7a50513          	addi	a0,a0,-134 # 8002cbd8 <end>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	f70080e7          	jalr	-144(ra) # 80000bd6 <freerange>
    MAX_PAGES = FREE_PAGES;
    80000c6e:	0000b797          	auipc	a5,0xb
    80000c72:	aaa7b783          	ld	a5,-1366(a5) # 8000b718 <FREE_PAGES>
    80000c76:	0000b717          	auipc	a4,0xb
    80000c7a:	aaf73523          	sd	a5,-1366(a4) # 8000b720 <MAX_PAGES>
}
    80000c7e:	60a2                	ld	ra,8(sp)
    80000c80:	6402                	ld	s0,0(sp)
    80000c82:	0141                	addi	sp,sp,16
    80000c84:	8082                	ret

0000000080000c86 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c86:	7179                	addi	sp,sp,-48
    80000c88:	f406                	sd	ra,40(sp)
    80000c8a:	f022                	sd	s0,32(sp)
    80000c8c:	ec26                	sd	s1,24(sp)
    80000c8e:	e84a                	sd	s2,16(sp)
    80000c90:	e44e                	sd	s3,8(sp)
    80000c92:	1800                	addi	s0,sp,48
    assert(FREE_PAGES > 0);
    80000c94:	0000b797          	auipc	a5,0xb
    80000c98:	a847b783          	ld	a5,-1404(a5) # 8000b718 <FREE_PAGES>
    80000c9c:	cfd1                	beqz	a5,80000d38 <kalloc+0xb2>
    struct run *r;

    acquire(&kmem.lock);
    80000c9e:	00013517          	auipc	a0,0x13
    80000ca2:	d0a50513          	addi	a0,a0,-758 # 800139a8 <kmem>
    80000ca6:	00000097          	auipc	ra,0x0
    80000caa:	290080e7          	jalr	656(ra) # 80000f36 <acquire>
    r = kmem.freelist;
    80000cae:	00013497          	auipc	s1,0x13
    80000cb2:	d124b483          	ld	s1,-750(s1) # 800139c0 <kmem+0x18>
    if (r)
    80000cb6:	c8dd                	beqz	s1,80000d6c <kalloc+0xe6>
        kmem.freelist = r->next;
    80000cb8:	609c                	ld	a5,0(s1)
    80000cba:	00013717          	auipc	a4,0x13
    80000cbe:	d0f73323          	sd	a5,-762(a4) # 800139c0 <kmem+0x18>
    release(&kmem.lock);
    80000cc2:	00013517          	auipc	a0,0x13
    80000cc6:	ce650513          	addi	a0,a0,-794 # 800139a8 <kmem>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	320080e7          	jalr	800(ra) # 80000fea <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000cd2:	6605                	lui	a2,0x1
    80000cd4:	4595                	li	a1,5
    80000cd6:	8526                	mv	a0,s1
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	35a080e7          	jalr	858(ra) # 80001032 <memset>
    FREE_PAGES--;
    80000ce0:	0000b717          	auipc	a4,0xb
    80000ce4:	a3870713          	addi	a4,a4,-1480 # 8000b718 <FREE_PAGES>
    80000ce8:	631c                	ld	a5,0(a4)
    80000cea:	17fd                	addi	a5,a5,-1
    80000cec:	e31c                	sd	a5,0(a4)

    int i = refindex((uint64) r);
    80000cee:	8526                	mv	a0,s1
    80000cf0:	00000097          	auipc	ra,0x0
    80000cf4:	d6c080e7          	jalr	-660(ra) # 80000a5c <refindex>
    80000cf8:	892a                	mv	s2,a0
    acquire(&refcountlock);
    80000cfa:	00013997          	auipc	s3,0x13
    80000cfe:	c9698993          	addi	s3,s3,-874 # 80013990 <refcountlock>
    80000d02:	854e                	mv	a0,s3
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	232080e7          	jalr	562(ra) # 80000f36 <acquire>
    refcount[i] = 1;
    80000d0c:	00013797          	auipc	a5,0x13
    80000d10:	cbc78793          	addi	a5,a5,-836 # 800139c8 <refcount>
    80000d14:	01278533          	add	a0,a5,s2
    80000d18:	4785                	li	a5,1
    80000d1a:	00f50023          	sb	a5,0(a0)
    release(&refcountlock);
    80000d1e:	854e                	mv	a0,s3
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	2ca080e7          	jalr	714(ra) # 80000fea <release>

    return (void *)r;
}
    80000d28:	8526                	mv	a0,s1
    80000d2a:	70a2                	ld	ra,40(sp)
    80000d2c:	7402                	ld	s0,32(sp)
    80000d2e:	64e2                	ld	s1,24(sp)
    80000d30:	6942                	ld	s2,16(sp)
    80000d32:	69a2                	ld	s3,8(sp)
    80000d34:	6145                	addi	sp,sp,48
    80000d36:	8082                	ret
    assert(FREE_PAGES > 0);
    80000d38:	06c00693          	li	a3,108
    80000d3c:	00007617          	auipc	a2,0x7
    80000d40:	2c460613          	addi	a2,a2,708 # 80008000 <etext>
    80000d44:	00007597          	auipc	a1,0x7
    80000d48:	32458593          	addi	a1,a1,804 # 80008068 <__func__.1+0x60>
    80000d4c:	00007517          	auipc	a0,0x7
    80000d50:	32c50513          	addi	a0,a0,812 # 80008078 <__func__.1+0x70>
    80000d54:	00000097          	auipc	ra,0x0
    80000d58:	868080e7          	jalr	-1944(ra) # 800005bc <printf>
    80000d5c:	00007517          	auipc	a0,0x7
    80000d60:	32c50513          	addi	a0,a0,812 # 80008088 <__func__.1+0x80>
    80000d64:	fffff097          	auipc	ra,0xfffff
    80000d68:	7fc080e7          	jalr	2044(ra) # 80000560 <panic>
    release(&kmem.lock);
    80000d6c:	00013517          	auipc	a0,0x13
    80000d70:	c3c50513          	addi	a0,a0,-964 # 800139a8 <kmem>
    80000d74:	00000097          	auipc	ra,0x0
    80000d78:	276080e7          	jalr	630(ra) # 80000fea <release>
    if (r)
    80000d7c:	b795                	j	80000ce0 <kalloc+0x5a>

0000000080000d7e <cow_triggered>:

void cow_triggered(pte_t *pte)
{
    80000d7e:	7179                	addi	sp,sp,-48
    80000d80:	f406                	sd	ra,40(sp)
    80000d82:	f022                	sd	s0,32(sp)
    80000d84:	ec26                	sd	s1,24(sp)
    80000d86:	e84a                	sd	s2,16(sp)
    80000d88:	e44e                	sd	s3,8(sp)
    80000d8a:	1800                	addi	s0,sp,48
    80000d8c:	89aa                	mv	s3,a0
    uint64 pg = PTE2PA(*pte);
    80000d8e:	00053903          	ld	s2,0(a0)
    80000d92:	00a95913          	srli	s2,s2,0xa
    80000d96:	0932                	slli	s2,s2,0xc

    int i = refindex(pg);
    80000d98:	854a                	mv	a0,s2
    80000d9a:	00000097          	auipc	ra,0x0
    80000d9e:	cc2080e7          	jalr	-830(ra) # 80000a5c <refindex>
    80000da2:	84aa                	mv	s1,a0

    // check if need to copy to new page
    acquire(&refcountlock);
    80000da4:	00013517          	auipc	a0,0x13
    80000da8:	bec50513          	addi	a0,a0,-1044 # 80013990 <refcountlock>
    80000dac:	00000097          	auipc	ra,0x0
    80000db0:	18a080e7          	jalr	394(ra) # 80000f36 <acquire>
    if (refcount[i] > 1) {
    80000db4:	00013797          	auipc	a5,0x13
    80000db8:	c1478793          	addi	a5,a5,-1004 # 800139c8 <refcount>
    80000dbc:	97a6                	add	a5,a5,s1
    80000dbe:	0007c783          	lbu	a5,0(a5)
    80000dc2:	4705                	li	a4,1
    80000dc4:	06f77863          	bgeu	a4,a5,80000e34 <cow_triggered+0xb6>
        refcount[i]--;
    80000dc8:	00013717          	auipc	a4,0x13
    80000dcc:	c0070713          	addi	a4,a4,-1024 # 800139c8 <refcount>
    80000dd0:	9726                	add	a4,a4,s1
    80000dd2:	37fd                	addiw	a5,a5,-1
    80000dd4:	00f70023          	sb	a5,0(a4)
        release(&refcountlock);
    80000dd8:	00013517          	auipc	a0,0x13
    80000ddc:	bb850513          	addi	a0,a0,-1096 # 80013990 <refcountlock>
    80000de0:	00000097          	auipc	ra,0x0
    80000de4:	20a080e7          	jalr	522(ra) # 80000fea <release>

        // get new page
        void* new = kalloc();
    80000de8:	00000097          	auipc	ra,0x0
    80000dec:	e9e080e7          	jalr	-354(ra) # 80000c86 <kalloc>
    80000df0:	84aa                	mv	s1,a0
        if (new == 0)
    80000df2:	c90d                	beqz	a0,80000e24 <cow_triggered+0xa6>
        {
          panic("cow_triggered, out of mem");
        }

        // copy to new page
        memmove(new, (void*) pg, PGSIZE);
    80000df4:	6605                	lui	a2,0x1
    80000df6:	85ca                	mv	a1,s2
    80000df8:	00000097          	auipc	ra,0x0
    80000dfc:	296080e7          	jalr	662(ra) # 8000108e <memmove>

        uint flags = PTE_FLAGS(*pte);
    80000e00:	0009b783          	ld	a5,0(s3)
        flags &= ~PTE_COW;
    80000e04:	1ff7f793          	andi	a5,a5,511
        flags |= PTE_W;

        // update pte
        *pte = PA2PTE(new) | flags;
    80000e08:	80b1                	srli	s1,s1,0xc
    80000e0a:	04aa                	slli	s1,s1,0xa
    80000e0c:	0047e793          	ori	a5,a5,4
    80000e10:	8cdd                	or	s1,s1,a5
    80000e12:	0099b023          	sd	s1,0(s3)
    } else {
        release(&refcountlock);
        // make normal write
        *pte = (*pte & ~PTE_COW) | PTE_W;
    } 
}
    80000e16:	70a2                	ld	ra,40(sp)
    80000e18:	7402                	ld	s0,32(sp)
    80000e1a:	64e2                	ld	s1,24(sp)
    80000e1c:	6942                	ld	s2,16(sp)
    80000e1e:	69a2                	ld	s3,8(sp)
    80000e20:	6145                	addi	sp,sp,48
    80000e22:	8082                	ret
          panic("cow_triggered, out of mem");
    80000e24:	00007517          	auipc	a0,0x7
    80000e28:	29450513          	addi	a0,a0,660 # 800080b8 <__func__.1+0xb0>
    80000e2c:	fffff097          	auipc	ra,0xfffff
    80000e30:	734080e7          	jalr	1844(ra) # 80000560 <panic>
        release(&refcountlock);
    80000e34:	00013517          	auipc	a0,0x13
    80000e38:	b5c50513          	addi	a0,a0,-1188 # 80013990 <refcountlock>
    80000e3c:	00000097          	auipc	ra,0x0
    80000e40:	1ae080e7          	jalr	430(ra) # 80000fea <release>
        *pte = (*pte & ~PTE_COW) | PTE_W;
    80000e44:	0009b483          	ld	s1,0(s3)
    80000e48:	dfb4f493          	andi	s1,s1,-517
    80000e4c:	0044e493          	ori	s1,s1,4
    80000e50:	b7c9                	j	80000e12 <cow_triggered+0x94>

0000000080000e52 <increfcount>:

void increfcount(uint64 pa)
{
    80000e52:	1101                	addi	sp,sp,-32
    80000e54:	ec06                	sd	ra,24(sp)
    80000e56:	e822                	sd	s0,16(sp)
    80000e58:	e426                	sd	s1,8(sp)
    80000e5a:	e04a                	sd	s2,0(sp)
    80000e5c:	1000                	addi	s0,sp,32
    80000e5e:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000e60:	00013917          	auipc	s2,0x13
    80000e64:	b3090913          	addi	s2,s2,-1232 # 80013990 <refcountlock>
    80000e68:	854a                	mv	a0,s2
    80000e6a:	00000097          	auipc	ra,0x0
    80000e6e:	0cc080e7          	jalr	204(ra) # 80000f36 <acquire>
    refcount[refindex(pa)]++;
    80000e72:	8526                	mv	a0,s1
    80000e74:	00000097          	auipc	ra,0x0
    80000e78:	be8080e7          	jalr	-1048(ra) # 80000a5c <refindex>
    80000e7c:	00013797          	auipc	a5,0x13
    80000e80:	b4c78793          	addi	a5,a5,-1204 # 800139c8 <refcount>
    80000e84:	953e                	add	a0,a0,a5
    80000e86:	00054783          	lbu	a5,0(a0)
    80000e8a:	2785                	addiw	a5,a5,1
    80000e8c:	00f50023          	sb	a5,0(a0)
    release(&refcountlock);
    80000e90:	854a                	mv	a0,s2
    80000e92:	00000097          	auipc	ra,0x0
    80000e96:	158080e7          	jalr	344(ra) # 80000fea <release>
}
    80000e9a:	60e2                	ld	ra,24(sp)
    80000e9c:	6442                	ld	s0,16(sp)
    80000e9e:	64a2                	ld	s1,8(sp)
    80000ea0:	6902                	ld	s2,0(sp)
    80000ea2:	6105                	addi	sp,sp,32
    80000ea4:	8082                	ret

0000000080000ea6 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  lk->name = name;
    80000eac:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000eae:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000eb2:	00053823          	sd	zero,16(a0)
}
    80000eb6:	6422                	ld	s0,8(sp)
    80000eb8:	0141                	addi	sp,sp,16
    80000eba:	8082                	ret

0000000080000ebc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000ebc:	411c                	lw	a5,0(a0)
    80000ebe:	e399                	bnez	a5,80000ec4 <holding+0x8>
    80000ec0:	4501                	li	a0,0
  return r;
}
    80000ec2:	8082                	ret
{
    80000ec4:	1101                	addi	sp,sp,-32
    80000ec6:	ec06                	sd	ra,24(sp)
    80000ec8:	e822                	sd	s0,16(sp)
    80000eca:	e426                	sd	s1,8(sp)
    80000ecc:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ece:	6904                	ld	s1,16(a0)
    80000ed0:	00001097          	auipc	ra,0x1
    80000ed4:	0bc080e7          	jalr	188(ra) # 80001f8c <mycpu>
    80000ed8:	40a48533          	sub	a0,s1,a0
    80000edc:	00153513          	seqz	a0,a0
}
    80000ee0:	60e2                	ld	ra,24(sp)
    80000ee2:	6442                	ld	s0,16(sp)
    80000ee4:	64a2                	ld	s1,8(sp)
    80000ee6:	6105                	addi	sp,sp,32
    80000ee8:	8082                	ret

0000000080000eea <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000eea:	1101                	addi	sp,sp,-32
    80000eec:	ec06                	sd	ra,24(sp)
    80000eee:	e822                	sd	s0,16(sp)
    80000ef0:	e426                	sd	s1,8(sp)
    80000ef2:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000ef4:	100024f3          	csrr	s1,sstatus
    80000ef8:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000efc:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000efe:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000f02:	00001097          	auipc	ra,0x1
    80000f06:	08a080e7          	jalr	138(ra) # 80001f8c <mycpu>
    80000f0a:	5d3c                	lw	a5,120(a0)
    80000f0c:	cf89                	beqz	a5,80000f26 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000f0e:	00001097          	auipc	ra,0x1
    80000f12:	07e080e7          	jalr	126(ra) # 80001f8c <mycpu>
    80000f16:	5d3c                	lw	a5,120(a0)
    80000f18:	2785                	addiw	a5,a5,1
    80000f1a:	dd3c                	sw	a5,120(a0)
}
    80000f1c:	60e2                	ld	ra,24(sp)
    80000f1e:	6442                	ld	s0,16(sp)
    80000f20:	64a2                	ld	s1,8(sp)
    80000f22:	6105                	addi	sp,sp,32
    80000f24:	8082                	ret
    mycpu()->intena = old;
    80000f26:	00001097          	auipc	ra,0x1
    80000f2a:	066080e7          	jalr	102(ra) # 80001f8c <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000f2e:	8085                	srli	s1,s1,0x1
    80000f30:	8885                	andi	s1,s1,1
    80000f32:	dd64                	sw	s1,124(a0)
    80000f34:	bfe9                	j	80000f0e <push_off+0x24>

0000000080000f36 <acquire>:
{
    80000f36:	1101                	addi	sp,sp,-32
    80000f38:	ec06                	sd	ra,24(sp)
    80000f3a:	e822                	sd	s0,16(sp)
    80000f3c:	e426                	sd	s1,8(sp)
    80000f3e:	1000                	addi	s0,sp,32
    80000f40:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	fa8080e7          	jalr	-88(ra) # 80000eea <push_off>
  if(holding(lk))
    80000f4a:	8526                	mv	a0,s1
    80000f4c:	00000097          	auipc	ra,0x0
    80000f50:	f70080e7          	jalr	-144(ra) # 80000ebc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000f54:	4705                	li	a4,1
  if(holding(lk))
    80000f56:	e115                	bnez	a0,80000f7a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000f58:	87ba                	mv	a5,a4
    80000f5a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000f5e:	2781                	sext.w	a5,a5
    80000f60:	ffe5                	bnez	a5,80000f58 <acquire+0x22>
  __sync_synchronize();
    80000f62:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000f66:	00001097          	auipc	ra,0x1
    80000f6a:	026080e7          	jalr	38(ra) # 80001f8c <mycpu>
    80000f6e:	e888                	sd	a0,16(s1)
}
    80000f70:	60e2                	ld	ra,24(sp)
    80000f72:	6442                	ld	s0,16(sp)
    80000f74:	64a2                	ld	s1,8(sp)
    80000f76:	6105                	addi	sp,sp,32
    80000f78:	8082                	ret
    panic("acquire");
    80000f7a:	00007517          	auipc	a0,0x7
    80000f7e:	15e50513          	addi	a0,a0,350 # 800080d8 <__func__.1+0xd0>
    80000f82:	fffff097          	auipc	ra,0xfffff
    80000f86:	5de080e7          	jalr	1502(ra) # 80000560 <panic>

0000000080000f8a <pop_off>:

void
pop_off(void)
{
    80000f8a:	1141                	addi	sp,sp,-16
    80000f8c:	e406                	sd	ra,8(sp)
    80000f8e:	e022                	sd	s0,0(sp)
    80000f90:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	ffa080e7          	jalr	-6(ra) # 80001f8c <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000f9a:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000f9e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000fa0:	e78d                	bnez	a5,80000fca <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000fa2:	5d3c                	lw	a5,120(a0)
    80000fa4:	02f05b63          	blez	a5,80000fda <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000fa8:	37fd                	addiw	a5,a5,-1
    80000faa:	0007871b          	sext.w	a4,a5
    80000fae:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000fb0:	eb09                	bnez	a4,80000fc2 <pop_off+0x38>
    80000fb2:	5d7c                	lw	a5,124(a0)
    80000fb4:	c799                	beqz	a5,80000fc2 <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000fb6:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000fba:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000fbe:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000fc2:	60a2                	ld	ra,8(sp)
    80000fc4:	6402                	ld	s0,0(sp)
    80000fc6:	0141                	addi	sp,sp,16
    80000fc8:	8082                	ret
    panic("pop_off - interruptible");
    80000fca:	00007517          	auipc	a0,0x7
    80000fce:	11650513          	addi	a0,a0,278 # 800080e0 <__func__.1+0xd8>
    80000fd2:	fffff097          	auipc	ra,0xfffff
    80000fd6:	58e080e7          	jalr	1422(ra) # 80000560 <panic>
    panic("pop_off");
    80000fda:	00007517          	auipc	a0,0x7
    80000fde:	11e50513          	addi	a0,a0,286 # 800080f8 <__func__.1+0xf0>
    80000fe2:	fffff097          	auipc	ra,0xfffff
    80000fe6:	57e080e7          	jalr	1406(ra) # 80000560 <panic>

0000000080000fea <release>:
{
    80000fea:	1101                	addi	sp,sp,-32
    80000fec:	ec06                	sd	ra,24(sp)
    80000fee:	e822                	sd	s0,16(sp)
    80000ff0:	e426                	sd	s1,8(sp)
    80000ff2:	1000                	addi	s0,sp,32
    80000ff4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	ec6080e7          	jalr	-314(ra) # 80000ebc <holding>
    80000ffe:	c115                	beqz	a0,80001022 <release+0x38>
  lk->cpu = 0;
    80001000:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80001004:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80001008:	0310000f          	fence	rw,w
    8000100c:	0004a023          	sw	zero,0(s1)
  pop_off();
    80001010:	00000097          	auipc	ra,0x0
    80001014:	f7a080e7          	jalr	-134(ra) # 80000f8a <pop_off>
}
    80001018:	60e2                	ld	ra,24(sp)
    8000101a:	6442                	ld	s0,16(sp)
    8000101c:	64a2                	ld	s1,8(sp)
    8000101e:	6105                	addi	sp,sp,32
    80001020:	8082                	ret
    panic("release");
    80001022:	00007517          	auipc	a0,0x7
    80001026:	0de50513          	addi	a0,a0,222 # 80008100 <__func__.1+0xf8>
    8000102a:	fffff097          	auipc	ra,0xfffff
    8000102e:	536080e7          	jalr	1334(ra) # 80000560 <panic>

0000000080001032 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e422                	sd	s0,8(sp)
    80001036:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80001038:	ca19                	beqz	a2,8000104e <memset+0x1c>
    8000103a:	87aa                	mv	a5,a0
    8000103c:	1602                	slli	a2,a2,0x20
    8000103e:	9201                	srli	a2,a2,0x20
    80001040:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80001044:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80001048:	0785                	addi	a5,a5,1
    8000104a:	fee79de3          	bne	a5,a4,80001044 <memset+0x12>
  }
  return dst;
}
    8000104e:	6422                	ld	s0,8(sp)
    80001050:	0141                	addi	sp,sp,16
    80001052:	8082                	ret

0000000080001054 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80001054:	1141                	addi	sp,sp,-16
    80001056:	e422                	sd	s0,8(sp)
    80001058:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000105a:	ca05                	beqz	a2,8000108a <memcmp+0x36>
    8000105c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80001060:	1682                	slli	a3,a3,0x20
    80001062:	9281                	srli	a3,a3,0x20
    80001064:	0685                	addi	a3,a3,1
    80001066:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80001068:	00054783          	lbu	a5,0(a0)
    8000106c:	0005c703          	lbu	a4,0(a1)
    80001070:	00e79863          	bne	a5,a4,80001080 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80001074:	0505                	addi	a0,a0,1
    80001076:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80001078:	fed518e3          	bne	a0,a3,80001068 <memcmp+0x14>
  }

  return 0;
    8000107c:	4501                	li	a0,0
    8000107e:	a019                	j	80001084 <memcmp+0x30>
      return *s1 - *s2;
    80001080:	40e7853b          	subw	a0,a5,a4
}
    80001084:	6422                	ld	s0,8(sp)
    80001086:	0141                	addi	sp,sp,16
    80001088:	8082                	ret
  return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	bfe5                	j	80001084 <memcmp+0x30>

000000008000108e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000108e:	1141                	addi	sp,sp,-16
    80001090:	e422                	sd	s0,8(sp)
    80001092:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80001094:	c205                	beqz	a2,800010b4 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001096:	02a5e263          	bltu	a1,a0,800010ba <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000109a:	1602                	slli	a2,a2,0x20
    8000109c:	9201                	srli	a2,a2,0x20
    8000109e:	00c587b3          	add	a5,a1,a2
{
    800010a2:	872a                	mv	a4,a0
      *d++ = *s++;
    800010a4:	0585                	addi	a1,a1,1
    800010a6:	0705                	addi	a4,a4,1
    800010a8:	fff5c683          	lbu	a3,-1(a1)
    800010ac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800010b0:	feb79ae3          	bne	a5,a1,800010a4 <memmove+0x16>

  return dst;
}
    800010b4:	6422                	ld	s0,8(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
  if(s < d && s + n > d){
    800010ba:	02061693          	slli	a3,a2,0x20
    800010be:	9281                	srli	a3,a3,0x20
    800010c0:	00d58733          	add	a4,a1,a3
    800010c4:	fce57be3          	bgeu	a0,a4,8000109a <memmove+0xc>
    d += n;
    800010c8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800010ca:	fff6079b          	addiw	a5,a2,-1
    800010ce:	1782                	slli	a5,a5,0x20
    800010d0:	9381                	srli	a5,a5,0x20
    800010d2:	fff7c793          	not	a5,a5
    800010d6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800010d8:	177d                	addi	a4,a4,-1
    800010da:	16fd                	addi	a3,a3,-1
    800010dc:	00074603          	lbu	a2,0(a4)
    800010e0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800010e4:	fef71ae3          	bne	a4,a5,800010d8 <memmove+0x4a>
    800010e8:	b7f1                	j	800010b4 <memmove+0x26>

00000000800010ea <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800010ea:	1141                	addi	sp,sp,-16
    800010ec:	e406                	sd	ra,8(sp)
    800010ee:	e022                	sd	s0,0(sp)
    800010f0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800010f2:	00000097          	auipc	ra,0x0
    800010f6:	f9c080e7          	jalr	-100(ra) # 8000108e <memmove>
}
    800010fa:	60a2                	ld	ra,8(sp)
    800010fc:	6402                	ld	s0,0(sp)
    800010fe:	0141                	addi	sp,sp,16
    80001100:	8082                	ret

0000000080001102 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001102:	1141                	addi	sp,sp,-16
    80001104:	e422                	sd	s0,8(sp)
    80001106:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001108:	ce11                	beqz	a2,80001124 <strncmp+0x22>
    8000110a:	00054783          	lbu	a5,0(a0)
    8000110e:	cf89                	beqz	a5,80001128 <strncmp+0x26>
    80001110:	0005c703          	lbu	a4,0(a1)
    80001114:	00f71a63          	bne	a4,a5,80001128 <strncmp+0x26>
    n--, p++, q++;
    80001118:	367d                	addiw	a2,a2,-1
    8000111a:	0505                	addi	a0,a0,1
    8000111c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000111e:	f675                	bnez	a2,8000110a <strncmp+0x8>
  if(n == 0)
    return 0;
    80001120:	4501                	li	a0,0
    80001122:	a801                	j	80001132 <strncmp+0x30>
    80001124:	4501                	li	a0,0
    80001126:	a031                	j	80001132 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80001128:	00054503          	lbu	a0,0(a0)
    8000112c:	0005c783          	lbu	a5,0(a1)
    80001130:	9d1d                	subw	a0,a0,a5
}
    80001132:	6422                	ld	s0,8(sp)
    80001134:	0141                	addi	sp,sp,16
    80001136:	8082                	ret

0000000080001138 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e422                	sd	s0,8(sp)
    8000113c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000113e:	87aa                	mv	a5,a0
    80001140:	86b2                	mv	a3,a2
    80001142:	367d                	addiw	a2,a2,-1
    80001144:	02d05563          	blez	a3,8000116e <strncpy+0x36>
    80001148:	0785                	addi	a5,a5,1
    8000114a:	0005c703          	lbu	a4,0(a1)
    8000114e:	fee78fa3          	sb	a4,-1(a5)
    80001152:	0585                	addi	a1,a1,1
    80001154:	f775                	bnez	a4,80001140 <strncpy+0x8>
    ;
  while(n-- > 0)
    80001156:	873e                	mv	a4,a5
    80001158:	9fb5                	addw	a5,a5,a3
    8000115a:	37fd                	addiw	a5,a5,-1
    8000115c:	00c05963          	blez	a2,8000116e <strncpy+0x36>
    *s++ = 0;
    80001160:	0705                	addi	a4,a4,1
    80001162:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80001166:	40e786bb          	subw	a3,a5,a4
    8000116a:	fed04be3          	bgtz	a3,80001160 <strncpy+0x28>
  return os;
}
    8000116e:	6422                	ld	s0,8(sp)
    80001170:	0141                	addi	sp,sp,16
    80001172:	8082                	ret

0000000080001174 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001174:	1141                	addi	sp,sp,-16
    80001176:	e422                	sd	s0,8(sp)
    80001178:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000117a:	02c05363          	blez	a2,800011a0 <safestrcpy+0x2c>
    8000117e:	fff6069b          	addiw	a3,a2,-1
    80001182:	1682                	slli	a3,a3,0x20
    80001184:	9281                	srli	a3,a3,0x20
    80001186:	96ae                	add	a3,a3,a1
    80001188:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000118a:	00d58963          	beq	a1,a3,8000119c <safestrcpy+0x28>
    8000118e:	0585                	addi	a1,a1,1
    80001190:	0785                	addi	a5,a5,1
    80001192:	fff5c703          	lbu	a4,-1(a1)
    80001196:	fee78fa3          	sb	a4,-1(a5)
    8000119a:	fb65                	bnez	a4,8000118a <safestrcpy+0x16>
    ;
  *s = 0;
    8000119c:	00078023          	sb	zero,0(a5)
  return os;
}
    800011a0:	6422                	ld	s0,8(sp)
    800011a2:	0141                	addi	sp,sp,16
    800011a4:	8082                	ret

00000000800011a6 <strlen>:

int
strlen(const char *s)
{
    800011a6:	1141                	addi	sp,sp,-16
    800011a8:	e422                	sd	s0,8(sp)
    800011aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800011ac:	00054783          	lbu	a5,0(a0)
    800011b0:	cf91                	beqz	a5,800011cc <strlen+0x26>
    800011b2:	0505                	addi	a0,a0,1
    800011b4:	87aa                	mv	a5,a0
    800011b6:	86be                	mv	a3,a5
    800011b8:	0785                	addi	a5,a5,1
    800011ba:	fff7c703          	lbu	a4,-1(a5)
    800011be:	ff65                	bnez	a4,800011b6 <strlen+0x10>
    800011c0:	40a6853b          	subw	a0,a3,a0
    800011c4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800011c6:	6422                	ld	s0,8(sp)
    800011c8:	0141                	addi	sp,sp,16
    800011ca:	8082                	ret
  for(n = 0; s[n]; n++)
    800011cc:	4501                	li	a0,0
    800011ce:	bfe5                	j	800011c6 <strlen+0x20>

00000000800011d0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800011d0:	1141                	addi	sp,sp,-16
    800011d2:	e406                	sd	ra,8(sp)
    800011d4:	e022                	sd	s0,0(sp)
    800011d6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800011d8:	00001097          	auipc	ra,0x1
    800011dc:	da4080e7          	jalr	-604(ra) # 80001f7c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800011e0:	0000a717          	auipc	a4,0xa
    800011e4:	54870713          	addi	a4,a4,1352 # 8000b728 <started>
  if(cpuid() == 0){
    800011e8:	c139                	beqz	a0,8000122e <main+0x5e>
    while(started == 0)
    800011ea:	431c                	lw	a5,0(a4)
    800011ec:	2781                	sext.w	a5,a5
    800011ee:	dff5                	beqz	a5,800011ea <main+0x1a>
      ;
    __sync_synchronize();
    800011f0:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    800011f4:	00001097          	auipc	ra,0x1
    800011f8:	d88080e7          	jalr	-632(ra) # 80001f7c <cpuid>
    800011fc:	85aa                	mv	a1,a0
    800011fe:	00007517          	auipc	a0,0x7
    80001202:	f2250513          	addi	a0,a0,-222 # 80008120 <__func__.1+0x118>
    80001206:	fffff097          	auipc	ra,0xfffff
    8000120a:	3b6080e7          	jalr	950(ra) # 800005bc <printf>
    kvminithart();    // turn on paging
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	0d8080e7          	jalr	216(ra) # 800012e6 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001216:	00002097          	auipc	ra,0x2
    8000121a:	c9c080e7          	jalr	-868(ra) # 80002eb2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000121e:	00005097          	auipc	ra,0x5
    80001222:	566080e7          	jalr	1382(ra) # 80006784 <plicinithart>
  }

  scheduler();        
    80001226:	00001097          	auipc	ra,0x1
    8000122a:	412080e7          	jalr	1042(ra) # 80002638 <scheduler>
    consoleinit();
    8000122e:	fffff097          	auipc	ra,0xfffff
    80001232:	242080e7          	jalr	578(ra) # 80000470 <consoleinit>
    printfinit();
    80001236:	fffff097          	auipc	ra,0xfffff
    8000123a:	58e080e7          	jalr	1422(ra) # 800007c4 <printfinit>
    printf("\n");
    8000123e:	00007517          	auipc	a0,0x7
    80001242:	de250513          	addi	a0,a0,-542 # 80008020 <__func__.1+0x18>
    80001246:	fffff097          	auipc	ra,0xfffff
    8000124a:	376080e7          	jalr	886(ra) # 800005bc <printf>
    printf("xv6 kernel is booting\n");
    8000124e:	00007517          	auipc	a0,0x7
    80001252:	eba50513          	addi	a0,a0,-326 # 80008108 <__func__.1+0x100>
    80001256:	fffff097          	auipc	ra,0xfffff
    8000125a:	366080e7          	jalr	870(ra) # 800005bc <printf>
    printf("\n");
    8000125e:	00007517          	auipc	a0,0x7
    80001262:	dc250513          	addi	a0,a0,-574 # 80008020 <__func__.1+0x18>
    80001266:	fffff097          	auipc	ra,0xfffff
    8000126a:	356080e7          	jalr	854(ra) # 800005bc <printf>
    kinit();         // physical page allocator
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	9b4080e7          	jalr	-1612(ra) # 80000c22 <kinit>
    kvminit();       // create kernel page table
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	326080e7          	jalr	806(ra) # 8000159c <kvminit>
    kvminithart();   // turn on paging
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	068080e7          	jalr	104(ra) # 800012e6 <kvminithart>
    procinit();      // process table
    80001286:	00001097          	auipc	ra,0x1
    8000128a:	c10080e7          	jalr	-1008(ra) # 80001e96 <procinit>
    trapinit();      // trap vectors
    8000128e:	00002097          	auipc	ra,0x2
    80001292:	bfc080e7          	jalr	-1028(ra) # 80002e8a <trapinit>
    trapinithart();  // install kernel trap vector
    80001296:	00002097          	auipc	ra,0x2
    8000129a:	c1c080e7          	jalr	-996(ra) # 80002eb2 <trapinithart>
    plicinit();      // set up interrupt controller
    8000129e:	00005097          	auipc	ra,0x5
    800012a2:	4cc080e7          	jalr	1228(ra) # 8000676a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800012a6:	00005097          	auipc	ra,0x5
    800012aa:	4de080e7          	jalr	1246(ra) # 80006784 <plicinithart>
    binit();         // buffer cache
    800012ae:	00002097          	auipc	ra,0x2
    800012b2:	5a0080e7          	jalr	1440(ra) # 8000384e <binit>
    iinit();         // inode table
    800012b6:	00003097          	auipc	ra,0x3
    800012ba:	c56080e7          	jalr	-938(ra) # 80003f0c <iinit>
    fileinit();      // file table
    800012be:	00004097          	auipc	ra,0x4
    800012c2:	c06080e7          	jalr	-1018(ra) # 80004ec4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800012c6:	00005097          	auipc	ra,0x5
    800012ca:	5c6080e7          	jalr	1478(ra) # 8000688c <virtio_disk_init>
    userinit();      // first user process
    800012ce:	00001097          	auipc	ra,0x1
    800012d2:	fb2080e7          	jalr	-78(ra) # 80002280 <userinit>
    __sync_synchronize();
    800012d6:	0330000f          	fence	rw,rw
    started = 1;
    800012da:	4785                	li	a5,1
    800012dc:	0000a717          	auipc	a4,0xa
    800012e0:	44f72623          	sw	a5,1100(a4) # 8000b728 <started>
    800012e4:	b789                	j	80001226 <main+0x56>

00000000800012e6 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800012e6:	1141                	addi	sp,sp,-16
    800012e8:	e422                	sd	s0,8(sp)
    800012ea:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    800012ec:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800012f0:	0000a797          	auipc	a5,0xa
    800012f4:	4407b783          	ld	a5,1088(a5) # 8000b730 <kernel_pagetable>
    800012f8:	83b1                	srli	a5,a5,0xc
    800012fa:	577d                	li	a4,-1
    800012fc:	177e                	slli	a4,a4,0x3f
    800012fe:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80001300:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    80001304:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001308:	6422                	ld	s0,8(sp)
    8000130a:	0141                	addi	sp,sp,16
    8000130c:	8082                	ret

000000008000130e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000130e:	7139                	addi	sp,sp,-64
    80001310:	fc06                	sd	ra,56(sp)
    80001312:	f822                	sd	s0,48(sp)
    80001314:	f426                	sd	s1,40(sp)
    80001316:	f04a                	sd	s2,32(sp)
    80001318:	ec4e                	sd	s3,24(sp)
    8000131a:	e852                	sd	s4,16(sp)
    8000131c:	e456                	sd	s5,8(sp)
    8000131e:	e05a                	sd	s6,0(sp)
    80001320:	0080                	addi	s0,sp,64
    80001322:	84aa                	mv	s1,a0
    80001324:	89ae                	mv	s3,a1
    80001326:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001328:	57fd                	li	a5,-1
    8000132a:	83e9                	srli	a5,a5,0x1a
    8000132c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000132e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001330:	04b7f263          	bgeu	a5,a1,80001374 <walk+0x66>
    panic("walk");
    80001334:	00007517          	auipc	a0,0x7
    80001338:	e0450513          	addi	a0,a0,-508 # 80008138 <__func__.1+0x130>
    8000133c:	fffff097          	auipc	ra,0xfffff
    80001340:	224080e7          	jalr	548(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001344:	060a8663          	beqz	s5,800013b0 <walk+0xa2>
    80001348:	00000097          	auipc	ra,0x0
    8000134c:	93e080e7          	jalr	-1730(ra) # 80000c86 <kalloc>
    80001350:	84aa                	mv	s1,a0
    80001352:	c529                	beqz	a0,8000139c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001354:	6605                	lui	a2,0x1
    80001356:	4581                	li	a1,0
    80001358:	00000097          	auipc	ra,0x0
    8000135c:	cda080e7          	jalr	-806(ra) # 80001032 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001360:	00c4d793          	srli	a5,s1,0xc
    80001364:	07aa                	slli	a5,a5,0xa
    80001366:	0017e793          	ori	a5,a5,1
    8000136a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000136e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd241f>
    80001370:	036a0063          	beq	s4,s6,80001390 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001374:	0149d933          	srl	s2,s3,s4
    80001378:	1ff97913          	andi	s2,s2,511
    8000137c:	090e                	slli	s2,s2,0x3
    8000137e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001380:	00093483          	ld	s1,0(s2)
    80001384:	0014f793          	andi	a5,s1,1
    80001388:	dfd5                	beqz	a5,80001344 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000138a:	80a9                	srli	s1,s1,0xa
    8000138c:	04b2                	slli	s1,s1,0xc
    8000138e:	b7c5                	j	8000136e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001390:	00c9d513          	srli	a0,s3,0xc
    80001394:	1ff57513          	andi	a0,a0,511
    80001398:	050e                	slli	a0,a0,0x3
    8000139a:	9526                	add	a0,a0,s1
}
    8000139c:	70e2                	ld	ra,56(sp)
    8000139e:	7442                	ld	s0,48(sp)
    800013a0:	74a2                	ld	s1,40(sp)
    800013a2:	7902                	ld	s2,32(sp)
    800013a4:	69e2                	ld	s3,24(sp)
    800013a6:	6a42                	ld	s4,16(sp)
    800013a8:	6aa2                	ld	s5,8(sp)
    800013aa:	6b02                	ld	s6,0(sp)
    800013ac:	6121                	addi	sp,sp,64
    800013ae:	8082                	ret
        return 0;
    800013b0:	4501                	li	a0,0
    800013b2:	b7ed                	j	8000139c <walk+0x8e>

00000000800013b4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800013b4:	57fd                	li	a5,-1
    800013b6:	83e9                	srli	a5,a5,0x1a
    800013b8:	00b7f463          	bgeu	a5,a1,800013c0 <walkaddr+0xc>
    return 0;
    800013bc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800013be:	8082                	ret
{
    800013c0:	1141                	addi	sp,sp,-16
    800013c2:	e406                	sd	ra,8(sp)
    800013c4:	e022                	sd	s0,0(sp)
    800013c6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800013c8:	4601                	li	a2,0
    800013ca:	00000097          	auipc	ra,0x0
    800013ce:	f44080e7          	jalr	-188(ra) # 8000130e <walk>
  if(pte == 0)
    800013d2:	c105                	beqz	a0,800013f2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800013d4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800013d6:	0117f693          	andi	a3,a5,17
    800013da:	4745                	li	a4,17
    return 0;
    800013dc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800013de:	00e68663          	beq	a3,a4,800013ea <walkaddr+0x36>
}
    800013e2:	60a2                	ld	ra,8(sp)
    800013e4:	6402                	ld	s0,0(sp)
    800013e6:	0141                	addi	sp,sp,16
    800013e8:	8082                	ret
  pa = PTE2PA(*pte);
    800013ea:	83a9                	srli	a5,a5,0xa
    800013ec:	00c79513          	slli	a0,a5,0xc
  return pa;
    800013f0:	bfcd                	j	800013e2 <walkaddr+0x2e>
    return 0;
    800013f2:	4501                	li	a0,0
    800013f4:	b7fd                	j	800013e2 <walkaddr+0x2e>

00000000800013f6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800013f6:	715d                	addi	sp,sp,-80
    800013f8:	e486                	sd	ra,72(sp)
    800013fa:	e0a2                	sd	s0,64(sp)
    800013fc:	fc26                	sd	s1,56(sp)
    800013fe:	f84a                	sd	s2,48(sp)
    80001400:	f44e                	sd	s3,40(sp)
    80001402:	f052                	sd	s4,32(sp)
    80001404:	ec56                	sd	s5,24(sp)
    80001406:	e85a                	sd	s6,16(sp)
    80001408:	e45e                	sd	s7,8(sp)
    8000140a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000140c:	c639                	beqz	a2,8000145a <mappages+0x64>
    8000140e:	8aaa                	mv	s5,a0
    80001410:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001412:	777d                	lui	a4,0xfffff
    80001414:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001418:	fff58993          	addi	s3,a1,-1
    8000141c:	99b2                	add	s3,s3,a2
    8000141e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001422:	893e                	mv	s2,a5
    80001424:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001428:	6b85                	lui	s7,0x1
    8000142a:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000142e:	4605                	li	a2,1
    80001430:	85ca                	mv	a1,s2
    80001432:	8556                	mv	a0,s5
    80001434:	00000097          	auipc	ra,0x0
    80001438:	eda080e7          	jalr	-294(ra) # 8000130e <walk>
    8000143c:	cd1d                	beqz	a0,8000147a <mappages+0x84>
    if(*pte & PTE_V)
    8000143e:	611c                	ld	a5,0(a0)
    80001440:	8b85                	andi	a5,a5,1
    80001442:	e785                	bnez	a5,8000146a <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001444:	80b1                	srli	s1,s1,0xc
    80001446:	04aa                	slli	s1,s1,0xa
    80001448:	0164e4b3          	or	s1,s1,s6
    8000144c:	0014e493          	ori	s1,s1,1
    80001450:	e104                	sd	s1,0(a0)
    if(a == last)
    80001452:	05390063          	beq	s2,s3,80001492 <mappages+0x9c>
    a += PGSIZE;
    80001456:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001458:	bfc9                	j	8000142a <mappages+0x34>
    panic("mappages: size");
    8000145a:	00007517          	auipc	a0,0x7
    8000145e:	ce650513          	addi	a0,a0,-794 # 80008140 <__func__.1+0x138>
    80001462:	fffff097          	auipc	ra,0xfffff
    80001466:	0fe080e7          	jalr	254(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000146a:	00007517          	auipc	a0,0x7
    8000146e:	ce650513          	addi	a0,a0,-794 # 80008150 <__func__.1+0x148>
    80001472:	fffff097          	auipc	ra,0xfffff
    80001476:	0ee080e7          	jalr	238(ra) # 80000560 <panic>
      return -1;
    8000147a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000147c:	60a6                	ld	ra,72(sp)
    8000147e:	6406                	ld	s0,64(sp)
    80001480:	74e2                	ld	s1,56(sp)
    80001482:	7942                	ld	s2,48(sp)
    80001484:	79a2                	ld	s3,40(sp)
    80001486:	7a02                	ld	s4,32(sp)
    80001488:	6ae2                	ld	s5,24(sp)
    8000148a:	6b42                	ld	s6,16(sp)
    8000148c:	6ba2                	ld	s7,8(sp)
    8000148e:	6161                	addi	sp,sp,80
    80001490:	8082                	ret
  return 0;
    80001492:	4501                	li	a0,0
    80001494:	b7e5                	j	8000147c <mappages+0x86>

0000000080001496 <kvmmap>:
{
    80001496:	1141                	addi	sp,sp,-16
    80001498:	e406                	sd	ra,8(sp)
    8000149a:	e022                	sd	s0,0(sp)
    8000149c:	0800                	addi	s0,sp,16
    8000149e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800014a0:	86b2                	mv	a3,a2
    800014a2:	863e                	mv	a2,a5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	f52080e7          	jalr	-174(ra) # 800013f6 <mappages>
    800014ac:	e509                	bnez	a0,800014b6 <kvmmap+0x20>
}
    800014ae:	60a2                	ld	ra,8(sp)
    800014b0:	6402                	ld	s0,0(sp)
    800014b2:	0141                	addi	sp,sp,16
    800014b4:	8082                	ret
    panic("kvmmap");
    800014b6:	00007517          	auipc	a0,0x7
    800014ba:	caa50513          	addi	a0,a0,-854 # 80008160 <__func__.1+0x158>
    800014be:	fffff097          	auipc	ra,0xfffff
    800014c2:	0a2080e7          	jalr	162(ra) # 80000560 <panic>

00000000800014c6 <kvmmake>:
{
    800014c6:	1101                	addi	sp,sp,-32
    800014c8:	ec06                	sd	ra,24(sp)
    800014ca:	e822                	sd	s0,16(sp)
    800014cc:	e426                	sd	s1,8(sp)
    800014ce:	e04a                	sd	s2,0(sp)
    800014d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	7b4080e7          	jalr	1972(ra) # 80000c86 <kalloc>
    800014da:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800014dc:	6605                	lui	a2,0x1
    800014de:	4581                	li	a1,0
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	b52080e7          	jalr	-1198(ra) # 80001032 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800014e8:	4719                	li	a4,6
    800014ea:	6685                	lui	a3,0x1
    800014ec:	10000637          	lui	a2,0x10000
    800014f0:	100005b7          	lui	a1,0x10000
    800014f4:	8526                	mv	a0,s1
    800014f6:	00000097          	auipc	ra,0x0
    800014fa:	fa0080e7          	jalr	-96(ra) # 80001496 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800014fe:	4719                	li	a4,6
    80001500:	6685                	lui	a3,0x1
    80001502:	10001637          	lui	a2,0x10001
    80001506:	100015b7          	lui	a1,0x10001
    8000150a:	8526                	mv	a0,s1
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	f8a080e7          	jalr	-118(ra) # 80001496 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001514:	4719                	li	a4,6
    80001516:	004006b7          	lui	a3,0x400
    8000151a:	0c000637          	lui	a2,0xc000
    8000151e:	0c0005b7          	lui	a1,0xc000
    80001522:	8526                	mv	a0,s1
    80001524:	00000097          	auipc	ra,0x0
    80001528:	f72080e7          	jalr	-142(ra) # 80001496 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000152c:	00007917          	auipc	s2,0x7
    80001530:	ad490913          	addi	s2,s2,-1324 # 80008000 <etext>
    80001534:	4729                	li	a4,10
    80001536:	80007697          	auipc	a3,0x80007
    8000153a:	aca68693          	addi	a3,a3,-1334 # 8000 <_entry-0x7fff8000>
    8000153e:	4605                	li	a2,1
    80001540:	067e                	slli	a2,a2,0x1f
    80001542:	85b2                	mv	a1,a2
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f50080e7          	jalr	-176(ra) # 80001496 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000154e:	46c5                	li	a3,17
    80001550:	06ee                	slli	a3,a3,0x1b
    80001552:	4719                	li	a4,6
    80001554:	412686b3          	sub	a3,a3,s2
    80001558:	864a                	mv	a2,s2
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8526                	mv	a0,s1
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	f38080e7          	jalr	-200(ra) # 80001496 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001566:	4729                	li	a4,10
    80001568:	6685                	lui	a3,0x1
    8000156a:	00006617          	auipc	a2,0x6
    8000156e:	a9660613          	addi	a2,a2,-1386 # 80007000 <_trampoline>
    80001572:	040005b7          	lui	a1,0x4000
    80001576:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001578:	05b2                	slli	a1,a1,0xc
    8000157a:	8526                	mv	a0,s1
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	f1a080e7          	jalr	-230(ra) # 80001496 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001584:	8526                	mv	a0,s1
    80001586:	00001097          	auipc	ra,0x1
    8000158a:	86c080e7          	jalr	-1940(ra) # 80001df2 <proc_mapstacks>
}
    8000158e:	8526                	mv	a0,s1
    80001590:	60e2                	ld	ra,24(sp)
    80001592:	6442                	ld	s0,16(sp)
    80001594:	64a2                	ld	s1,8(sp)
    80001596:	6902                	ld	s2,0(sp)
    80001598:	6105                	addi	sp,sp,32
    8000159a:	8082                	ret

000000008000159c <kvminit>:
{
    8000159c:	1141                	addi	sp,sp,-16
    8000159e:	e406                	sd	ra,8(sp)
    800015a0:	e022                	sd	s0,0(sp)
    800015a2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	f22080e7          	jalr	-222(ra) # 800014c6 <kvmmake>
    800015ac:	0000a797          	auipc	a5,0xa
    800015b0:	18a7b223          	sd	a0,388(a5) # 8000b730 <kernel_pagetable>
}
    800015b4:	60a2                	ld	ra,8(sp)
    800015b6:	6402                	ld	s0,0(sp)
    800015b8:	0141                	addi	sp,sp,16
    800015ba:	8082                	ret

00000000800015bc <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800015bc:	715d                	addi	sp,sp,-80
    800015be:	e486                	sd	ra,72(sp)
    800015c0:	e0a2                	sd	s0,64(sp)
    800015c2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800015c4:	03459793          	slli	a5,a1,0x34
    800015c8:	e39d                	bnez	a5,800015ee <uvmunmap+0x32>
    800015ca:	f84a                	sd	s2,48(sp)
    800015cc:	f44e                	sd	s3,40(sp)
    800015ce:	f052                	sd	s4,32(sp)
    800015d0:	ec56                	sd	s5,24(sp)
    800015d2:	e85a                	sd	s6,16(sp)
    800015d4:	e45e                	sd	s7,8(sp)
    800015d6:	8a2a                	mv	s4,a0
    800015d8:	892e                	mv	s2,a1
    800015da:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015dc:	0632                	slli	a2,a2,0xc
    800015de:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800015e2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015e4:	6b05                	lui	s6,0x1
    800015e6:	0935fb63          	bgeu	a1,s3,8000167c <uvmunmap+0xc0>
    800015ea:	fc26                	sd	s1,56(sp)
    800015ec:	a8a9                	j	80001646 <uvmunmap+0x8a>
    800015ee:	fc26                	sd	s1,56(sp)
    800015f0:	f84a                	sd	s2,48(sp)
    800015f2:	f44e                	sd	s3,40(sp)
    800015f4:	f052                	sd	s4,32(sp)
    800015f6:	ec56                	sd	s5,24(sp)
    800015f8:	e85a                	sd	s6,16(sp)
    800015fa:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800015fc:	00007517          	auipc	a0,0x7
    80001600:	b6c50513          	addi	a0,a0,-1172 # 80008168 <__func__.1+0x160>
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	f5c080e7          	jalr	-164(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000160c:	00007517          	auipc	a0,0x7
    80001610:	b7450513          	addi	a0,a0,-1164 # 80008180 <__func__.1+0x178>
    80001614:	fffff097          	auipc	ra,0xfffff
    80001618:	f4c080e7          	jalr	-180(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000161c:	00007517          	auipc	a0,0x7
    80001620:	b7450513          	addi	a0,a0,-1164 # 80008190 <__func__.1+0x188>
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	f3c080e7          	jalr	-196(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000162c:	00007517          	auipc	a0,0x7
    80001630:	b7c50513          	addi	a0,a0,-1156 # 800081a8 <__func__.1+0x1a0>
    80001634:	fffff097          	auipc	ra,0xfffff
    80001638:	f2c080e7          	jalr	-212(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000163c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001640:	995a                	add	s2,s2,s6
    80001642:	03397c63          	bgeu	s2,s3,8000167a <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001646:	4601                	li	a2,0
    80001648:	85ca                	mv	a1,s2
    8000164a:	8552                	mv	a0,s4
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	cc2080e7          	jalr	-830(ra) # 8000130e <walk>
    80001654:	84aa                	mv	s1,a0
    80001656:	d95d                	beqz	a0,8000160c <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001658:	6108                	ld	a0,0(a0)
    8000165a:	00157793          	andi	a5,a0,1
    8000165e:	dfdd                	beqz	a5,8000161c <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001660:	3ff57793          	andi	a5,a0,1023
    80001664:	fd7784e3          	beq	a5,s7,8000162c <uvmunmap+0x70>
    if(do_free){
    80001668:	fc0a8ae3          	beqz	s5,8000163c <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000166c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000166e:	0532                	slli	a0,a0,0xc
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	424080e7          	jalr	1060(ra) # 80000a94 <kfree>
    80001678:	b7d1                	j	8000163c <uvmunmap+0x80>
    8000167a:	74e2                	ld	s1,56(sp)
    8000167c:	7942                	ld	s2,48(sp)
    8000167e:	79a2                	ld	s3,40(sp)
    80001680:	7a02                	ld	s4,32(sp)
    80001682:	6ae2                	ld	s5,24(sp)
    80001684:	6b42                	ld	s6,16(sp)
    80001686:	6ba2                	ld	s7,8(sp)
  }
}
    80001688:	60a6                	ld	ra,72(sp)
    8000168a:	6406                	ld	s0,64(sp)
    8000168c:	6161                	addi	sp,sp,80
    8000168e:	8082                	ret

0000000080001690 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001690:	1101                	addi	sp,sp,-32
    80001692:	ec06                	sd	ra,24(sp)
    80001694:	e822                	sd	s0,16(sp)
    80001696:	e426                	sd	s1,8(sp)
    80001698:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	5ec080e7          	jalr	1516(ra) # 80000c86 <kalloc>
    800016a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800016a4:	c519                	beqz	a0,800016b2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800016a6:	6605                	lui	a2,0x1
    800016a8:	4581                	li	a1,0
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	988080e7          	jalr	-1656(ra) # 80001032 <memset>
  return pagetable;
}
    800016b2:	8526                	mv	a0,s1
    800016b4:	60e2                	ld	ra,24(sp)
    800016b6:	6442                	ld	s0,16(sp)
    800016b8:	64a2                	ld	s1,8(sp)
    800016ba:	6105                	addi	sp,sp,32
    800016bc:	8082                	ret

00000000800016be <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800016be:	7179                	addi	sp,sp,-48
    800016c0:	f406                	sd	ra,40(sp)
    800016c2:	f022                	sd	s0,32(sp)
    800016c4:	ec26                	sd	s1,24(sp)
    800016c6:	e84a                	sd	s2,16(sp)
    800016c8:	e44e                	sd	s3,8(sp)
    800016ca:	e052                	sd	s4,0(sp)
    800016cc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800016ce:	6785                	lui	a5,0x1
    800016d0:	04f67863          	bgeu	a2,a5,80001720 <uvmfirst+0x62>
    800016d4:	8a2a                	mv	s4,a0
    800016d6:	89ae                	mv	s3,a1
    800016d8:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	5ac080e7          	jalr	1452(ra) # 80000c86 <kalloc>
    800016e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800016e4:	6605                	lui	a2,0x1
    800016e6:	4581                	li	a1,0
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	94a080e7          	jalr	-1718(ra) # 80001032 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800016f0:	4779                	li	a4,30
    800016f2:	86ca                	mv	a3,s2
    800016f4:	6605                	lui	a2,0x1
    800016f6:	4581                	li	a1,0
    800016f8:	8552                	mv	a0,s4
    800016fa:	00000097          	auipc	ra,0x0
    800016fe:	cfc080e7          	jalr	-772(ra) # 800013f6 <mappages>
  memmove(mem, src, sz);
    80001702:	8626                	mv	a2,s1
    80001704:	85ce                	mv	a1,s3
    80001706:	854a                	mv	a0,s2
    80001708:	00000097          	auipc	ra,0x0
    8000170c:	986080e7          	jalr	-1658(ra) # 8000108e <memmove>
}
    80001710:	70a2                	ld	ra,40(sp)
    80001712:	7402                	ld	s0,32(sp)
    80001714:	64e2                	ld	s1,24(sp)
    80001716:	6942                	ld	s2,16(sp)
    80001718:	69a2                	ld	s3,8(sp)
    8000171a:	6a02                	ld	s4,0(sp)
    8000171c:	6145                	addi	sp,sp,48
    8000171e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001720:	00007517          	auipc	a0,0x7
    80001724:	aa050513          	addi	a0,a0,-1376 # 800081c0 <__func__.1+0x1b8>
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	e38080e7          	jalr	-456(ra) # 80000560 <panic>

0000000080001730 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001730:	1101                	addi	sp,sp,-32
    80001732:	ec06                	sd	ra,24(sp)
    80001734:	e822                	sd	s0,16(sp)
    80001736:	e426                	sd	s1,8(sp)
    80001738:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000173a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000173c:	00b67d63          	bgeu	a2,a1,80001756 <uvmdealloc+0x26>
    80001740:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001742:	6785                	lui	a5,0x1
    80001744:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001746:	00f60733          	add	a4,a2,a5
    8000174a:	76fd                	lui	a3,0xfffff
    8000174c:	8f75                	and	a4,a4,a3
    8000174e:	97ae                	add	a5,a5,a1
    80001750:	8ff5                	and	a5,a5,a3
    80001752:	00f76863          	bltu	a4,a5,80001762 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001756:	8526                	mv	a0,s1
    80001758:	60e2                	ld	ra,24(sp)
    8000175a:	6442                	ld	s0,16(sp)
    8000175c:	64a2                	ld	s1,8(sp)
    8000175e:	6105                	addi	sp,sp,32
    80001760:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001762:	8f99                	sub	a5,a5,a4
    80001764:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001766:	4685                	li	a3,1
    80001768:	0007861b          	sext.w	a2,a5
    8000176c:	85ba                	mv	a1,a4
    8000176e:	00000097          	auipc	ra,0x0
    80001772:	e4e080e7          	jalr	-434(ra) # 800015bc <uvmunmap>
    80001776:	b7c5                	j	80001756 <uvmdealloc+0x26>

0000000080001778 <uvmalloc>:
  if(newsz < oldsz)
    80001778:	0ab66b63          	bltu	a2,a1,8000182e <uvmalloc+0xb6>
{
    8000177c:	7139                	addi	sp,sp,-64
    8000177e:	fc06                	sd	ra,56(sp)
    80001780:	f822                	sd	s0,48(sp)
    80001782:	ec4e                	sd	s3,24(sp)
    80001784:	e852                	sd	s4,16(sp)
    80001786:	e456                	sd	s5,8(sp)
    80001788:	0080                	addi	s0,sp,64
    8000178a:	8aaa                	mv	s5,a0
    8000178c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000178e:	6785                	lui	a5,0x1
    80001790:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001792:	95be                	add	a1,a1,a5
    80001794:	77fd                	lui	a5,0xfffff
    80001796:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000179a:	08c9fc63          	bgeu	s3,a2,80001832 <uvmalloc+0xba>
    8000179e:	f426                	sd	s1,40(sp)
    800017a0:	f04a                	sd	s2,32(sp)
    800017a2:	e05a                	sd	s6,0(sp)
    800017a4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800017a6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800017aa:	fffff097          	auipc	ra,0xfffff
    800017ae:	4dc080e7          	jalr	1244(ra) # 80000c86 <kalloc>
    800017b2:	84aa                	mv	s1,a0
    if(mem == 0){
    800017b4:	c915                	beqz	a0,800017e8 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800017b6:	6605                	lui	a2,0x1
    800017b8:	4581                	li	a1,0
    800017ba:	00000097          	auipc	ra,0x0
    800017be:	878080e7          	jalr	-1928(ra) # 80001032 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800017c2:	875a                	mv	a4,s6
    800017c4:	86a6                	mv	a3,s1
    800017c6:	6605                	lui	a2,0x1
    800017c8:	85ca                	mv	a1,s2
    800017ca:	8556                	mv	a0,s5
    800017cc:	00000097          	auipc	ra,0x0
    800017d0:	c2a080e7          	jalr	-982(ra) # 800013f6 <mappages>
    800017d4:	ed05                	bnez	a0,8000180c <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800017d6:	6785                	lui	a5,0x1
    800017d8:	993e                	add	s2,s2,a5
    800017da:	fd4968e3          	bltu	s2,s4,800017aa <uvmalloc+0x32>
  return newsz;
    800017de:	8552                	mv	a0,s4
    800017e0:	74a2                	ld	s1,40(sp)
    800017e2:	7902                	ld	s2,32(sp)
    800017e4:	6b02                	ld	s6,0(sp)
    800017e6:	a821                	j	800017fe <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800017e8:	864e                	mv	a2,s3
    800017ea:	85ca                	mv	a1,s2
    800017ec:	8556                	mv	a0,s5
    800017ee:	00000097          	auipc	ra,0x0
    800017f2:	f42080e7          	jalr	-190(ra) # 80001730 <uvmdealloc>
      return 0;
    800017f6:	4501                	li	a0,0
    800017f8:	74a2                	ld	s1,40(sp)
    800017fa:	7902                	ld	s2,32(sp)
    800017fc:	6b02                	ld	s6,0(sp)
}
    800017fe:	70e2                	ld	ra,56(sp)
    80001800:	7442                	ld	s0,48(sp)
    80001802:	69e2                	ld	s3,24(sp)
    80001804:	6a42                	ld	s4,16(sp)
    80001806:	6aa2                	ld	s5,8(sp)
    80001808:	6121                	addi	sp,sp,64
    8000180a:	8082                	ret
      kfree(mem);
    8000180c:	8526                	mv	a0,s1
    8000180e:	fffff097          	auipc	ra,0xfffff
    80001812:	286080e7          	jalr	646(ra) # 80000a94 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001816:	864e                	mv	a2,s3
    80001818:	85ca                	mv	a1,s2
    8000181a:	8556                	mv	a0,s5
    8000181c:	00000097          	auipc	ra,0x0
    80001820:	f14080e7          	jalr	-236(ra) # 80001730 <uvmdealloc>
      return 0;
    80001824:	4501                	li	a0,0
    80001826:	74a2                	ld	s1,40(sp)
    80001828:	7902                	ld	s2,32(sp)
    8000182a:	6b02                	ld	s6,0(sp)
    8000182c:	bfc9                	j	800017fe <uvmalloc+0x86>
    return oldsz;
    8000182e:	852e                	mv	a0,a1
}
    80001830:	8082                	ret
  return newsz;
    80001832:	8532                	mv	a0,a2
    80001834:	b7e9                	j	800017fe <uvmalloc+0x86>

0000000080001836 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001836:	7179                	addi	sp,sp,-48
    80001838:	f406                	sd	ra,40(sp)
    8000183a:	f022                	sd	s0,32(sp)
    8000183c:	ec26                	sd	s1,24(sp)
    8000183e:	e84a                	sd	s2,16(sp)
    80001840:	e44e                	sd	s3,8(sp)
    80001842:	e052                	sd	s4,0(sp)
    80001844:	1800                	addi	s0,sp,48
    80001846:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001848:	84aa                	mv	s1,a0
    8000184a:	6905                	lui	s2,0x1
    8000184c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000184e:	4985                	li	s3,1
    80001850:	a829                	j	8000186a <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001852:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001854:	00c79513          	slli	a0,a5,0xc
    80001858:	00000097          	auipc	ra,0x0
    8000185c:	fde080e7          	jalr	-34(ra) # 80001836 <freewalk>
      pagetable[i] = 0;
    80001860:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001864:	04a1                	addi	s1,s1,8
    80001866:	03248163          	beq	s1,s2,80001888 <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000186a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000186c:	00f7f713          	andi	a4,a5,15
    80001870:	ff3701e3          	beq	a4,s3,80001852 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001874:	8b85                	andi	a5,a5,1
    80001876:	d7fd                	beqz	a5,80001864 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001878:	00007517          	auipc	a0,0x7
    8000187c:	96850513          	addi	a0,a0,-1688 # 800081e0 <__func__.1+0x1d8>
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	ce0080e7          	jalr	-800(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001888:	8552                	mv	a0,s4
    8000188a:	fffff097          	auipc	ra,0xfffff
    8000188e:	20a080e7          	jalr	522(ra) # 80000a94 <kfree>
}
    80001892:	70a2                	ld	ra,40(sp)
    80001894:	7402                	ld	s0,32(sp)
    80001896:	64e2                	ld	s1,24(sp)
    80001898:	6942                	ld	s2,16(sp)
    8000189a:	69a2                	ld	s3,8(sp)
    8000189c:	6a02                	ld	s4,0(sp)
    8000189e:	6145                	addi	sp,sp,48
    800018a0:	8082                	ret

00000000800018a2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800018a2:	1101                	addi	sp,sp,-32
    800018a4:	ec06                	sd	ra,24(sp)
    800018a6:	e822                	sd	s0,16(sp)
    800018a8:	e426                	sd	s1,8(sp)
    800018aa:	1000                	addi	s0,sp,32
    800018ac:	84aa                	mv	s1,a0
  if(sz > 0)
    800018ae:	e999                	bnez	a1,800018c4 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800018b0:	8526                	mv	a0,s1
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	f84080e7          	jalr	-124(ra) # 80001836 <freewalk>
}
    800018ba:	60e2                	ld	ra,24(sp)
    800018bc:	6442                	ld	s0,16(sp)
    800018be:	64a2                	ld	s1,8(sp)
    800018c0:	6105                	addi	sp,sp,32
    800018c2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800018c4:	6785                	lui	a5,0x1
    800018c6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800018c8:	95be                	add	a1,a1,a5
    800018ca:	4685                	li	a3,1
    800018cc:	00c5d613          	srli	a2,a1,0xc
    800018d0:	4581                	li	a1,0
    800018d2:	00000097          	auipc	ra,0x0
    800018d6:	cea080e7          	jalr	-790(ra) # 800015bc <uvmunmap>
    800018da:	bfd9                	j	800018b0 <uvmfree+0xe>

00000000800018dc <uvmcopy>:
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;

  for(i = 0; i < sz; i += PGSIZE){
    800018dc:	ca71                	beqz	a2,800019b0 <uvmcopy+0xd4>
{
    800018de:	715d                	addi	sp,sp,-80
    800018e0:	e486                	sd	ra,72(sp)
    800018e2:	e0a2                	sd	s0,64(sp)
    800018e4:	fc26                	sd	s1,56(sp)
    800018e6:	f84a                	sd	s2,48(sp)
    800018e8:	f44e                	sd	s3,40(sp)
    800018ea:	f052                	sd	s4,32(sp)
    800018ec:	ec56                	sd	s5,24(sp)
    800018ee:	e85a                	sd	s6,16(sp)
    800018f0:	e45e                	sd	s7,8(sp)
    800018f2:	0880                	addi	s0,sp,80
    800018f4:	8b2a                	mv	s6,a0
    800018f6:	8aae                	mv	s5,a1
    800018f8:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800018fa:	4981                	li	s3,0
      panic("uvmcopy: page not present");

    pa = PTE2PA(*pte);
    increfcount(pa);

    if (!(*pte & PTE_S) && (*pte & PTE_W)) {
    800018fc:	4b91                	li	s7,4
    800018fe:	a091                	j	80001942 <uvmcopy+0x66>
      panic("uvmcopy: pte should exist");
    80001900:	00007517          	auipc	a0,0x7
    80001904:	8f050513          	addi	a0,a0,-1808 # 800081f0 <__func__.1+0x1e8>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	c58080e7          	jalr	-936(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001910:	00007517          	auipc	a0,0x7
    80001914:	90050513          	addi	a0,a0,-1792 # 80008210 <__func__.1+0x208>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	c48080e7          	jalr	-952(ra) # 80000560 <panic>
      // make cow
      *pte = (*pte & ~PTE_W) | PTE_COW;
    }
    
    if(mappages(new, i, PGSIZE, pa, PTE_FLAGS(*pte)) != 0){
    80001920:	00093703          	ld	a4,0(s2) # 1000 <_entry-0x7ffff000>
    80001924:	3ff77713          	andi	a4,a4,1023
    80001928:	86a6                	mv	a3,s1
    8000192a:	6605                	lui	a2,0x1
    8000192c:	85ce                	mv	a1,s3
    8000192e:	8556                	mv	a0,s5
    80001930:	00000097          	auipc	ra,0x0
    80001934:	ac6080e7          	jalr	-1338(ra) # 800013f6 <mappages>
    80001938:	e539                	bnez	a0,80001986 <uvmcopy+0xaa>
  for(i = 0; i < sz; i += PGSIZE){
    8000193a:	6785                	lui	a5,0x1
    8000193c:	99be                	add	s3,s3,a5
    8000193e:	0549fe63          	bgeu	s3,s4,8000199a <uvmcopy+0xbe>
    if((pte = walk(old, i, 0)) == 0)
    80001942:	4601                	li	a2,0
    80001944:	85ce                	mv	a1,s3
    80001946:	855a                	mv	a0,s6
    80001948:	00000097          	auipc	ra,0x0
    8000194c:	9c6080e7          	jalr	-1594(ra) # 8000130e <walk>
    80001950:	892a                	mv	s2,a0
    80001952:	d55d                	beqz	a0,80001900 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    80001954:	6114                	ld	a3,0(a0)
    80001956:	0016f793          	andi	a5,a3,1
    8000195a:	dbdd                	beqz	a5,80001910 <uvmcopy+0x34>
    pa = PTE2PA(*pte);
    8000195c:	82a9                	srli	a3,a3,0xa
    8000195e:	00c69493          	slli	s1,a3,0xc
    increfcount(pa);
    80001962:	8526                	mv	a0,s1
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	4ee080e7          	jalr	1262(ra) # 80000e52 <increfcount>
    if (!(*pte & PTE_S) && (*pte & PTE_W)) {
    8000196c:	00093783          	ld	a5,0(s2)
    80001970:	1047f713          	andi	a4,a5,260
    80001974:	fb7716e3          	bne	a4,s7,80001920 <uvmcopy+0x44>
      *pte = (*pte & ~PTE_W) | PTE_COW;
    80001978:	dfb7f793          	andi	a5,a5,-517
    8000197c:	2007e793          	ori	a5,a5,512
    80001980:	00f93023          	sd	a5,0(s2)
    80001984:	bf71                	j	80001920 <uvmcopy+0x44>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001986:	4685                	li	a3,1
    80001988:	00c9d613          	srli	a2,s3,0xc
    8000198c:	4581                	li	a1,0
    8000198e:	8556                	mv	a0,s5
    80001990:	00000097          	auipc	ra,0x0
    80001994:	c2c080e7          	jalr	-980(ra) # 800015bc <uvmunmap>
  return -1;
    80001998:	557d                	li	a0,-1
}
    8000199a:	60a6                	ld	ra,72(sp)
    8000199c:	6406                	ld	s0,64(sp)
    8000199e:	74e2                	ld	s1,56(sp)
    800019a0:	7942                	ld	s2,48(sp)
    800019a2:	79a2                	ld	s3,40(sp)
    800019a4:	7a02                	ld	s4,32(sp)
    800019a6:	6ae2                	ld	s5,24(sp)
    800019a8:	6b42                	ld	s6,16(sp)
    800019aa:	6ba2                	ld	s7,8(sp)
    800019ac:	6161                	addi	sp,sp,80
    800019ae:	8082                	ret
  return 0;
    800019b0:	4501                	li	a0,0
}
    800019b2:	8082                	ret

00000000800019b4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800019b4:	1141                	addi	sp,sp,-16
    800019b6:	e406                	sd	ra,8(sp)
    800019b8:	e022                	sd	s0,0(sp)
    800019ba:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800019bc:	4601                	li	a2,0
    800019be:	00000097          	auipc	ra,0x0
    800019c2:	950080e7          	jalr	-1712(ra) # 8000130e <walk>
  if(pte == 0)
    800019c6:	c901                	beqz	a0,800019d6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800019c8:	611c                	ld	a5,0(a0)
    800019ca:	9bbd                	andi	a5,a5,-17
    800019cc:	e11c                	sd	a5,0(a0)
}
    800019ce:	60a2                	ld	ra,8(sp)
    800019d0:	6402                	ld	s0,0(sp)
    800019d2:	0141                	addi	sp,sp,16
    800019d4:	8082                	ret
    panic("uvmclear");
    800019d6:	00007517          	auipc	a0,0x7
    800019da:	85a50513          	addi	a0,a0,-1958 # 80008230 <__func__.1+0x228>
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	b82080e7          	jalr	-1150(ra) # 80000560 <panic>

00000000800019e6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800019e6:	c6bd                	beqz	a3,80001a54 <copyout+0x6e>
{
    800019e8:	715d                	addi	sp,sp,-80
    800019ea:	e486                	sd	ra,72(sp)
    800019ec:	e0a2                	sd	s0,64(sp)
    800019ee:	fc26                	sd	s1,56(sp)
    800019f0:	f84a                	sd	s2,48(sp)
    800019f2:	f44e                	sd	s3,40(sp)
    800019f4:	f052                	sd	s4,32(sp)
    800019f6:	ec56                	sd	s5,24(sp)
    800019f8:	e85a                	sd	s6,16(sp)
    800019fa:	e45e                	sd	s7,8(sp)
    800019fc:	e062                	sd	s8,0(sp)
    800019fe:	0880                	addi	s0,sp,80
    80001a00:	8b2a                	mv	s6,a0
    80001a02:	8c2e                	mv	s8,a1
    80001a04:	8a32                	mv	s4,a2
    80001a06:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001a08:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001a0a:	6a85                	lui	s5,0x1
    80001a0c:	a015                	j	80001a30 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001a0e:	9562                	add	a0,a0,s8
    80001a10:	0004861b          	sext.w	a2,s1
    80001a14:	85d2                	mv	a1,s4
    80001a16:	41250533          	sub	a0,a0,s2
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	674080e7          	jalr	1652(ra) # 8000108e <memmove>

    len -= n;
    80001a22:	409989b3          	sub	s3,s3,s1
    src += n;
    80001a26:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001a28:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a2c:	02098263          	beqz	s3,80001a50 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001a30:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a34:	85ca                	mv	a1,s2
    80001a36:	855a                	mv	a0,s6
    80001a38:	00000097          	auipc	ra,0x0
    80001a3c:	97c080e7          	jalr	-1668(ra) # 800013b4 <walkaddr>
    if(pa0 == 0)
    80001a40:	cd01                	beqz	a0,80001a58 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001a42:	418904b3          	sub	s1,s2,s8
    80001a46:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a48:	fc99f3e3          	bgeu	s3,s1,80001a0e <copyout+0x28>
    80001a4c:	84ce                	mv	s1,s3
    80001a4e:	b7c1                	j	80001a0e <copyout+0x28>
  }
  return 0;
    80001a50:	4501                	li	a0,0
    80001a52:	a021                	j	80001a5a <copyout+0x74>
    80001a54:	4501                	li	a0,0
}
    80001a56:	8082                	ret
      return -1;
    80001a58:	557d                	li	a0,-1
}
    80001a5a:	60a6                	ld	ra,72(sp)
    80001a5c:	6406                	ld	s0,64(sp)
    80001a5e:	74e2                	ld	s1,56(sp)
    80001a60:	7942                	ld	s2,48(sp)
    80001a62:	79a2                	ld	s3,40(sp)
    80001a64:	7a02                	ld	s4,32(sp)
    80001a66:	6ae2                	ld	s5,24(sp)
    80001a68:	6b42                	ld	s6,16(sp)
    80001a6a:	6ba2                	ld	s7,8(sp)
    80001a6c:	6c02                	ld	s8,0(sp)
    80001a6e:	6161                	addi	sp,sp,80
    80001a70:	8082                	ret

0000000080001a72 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001a72:	caa5                	beqz	a3,80001ae2 <copyin+0x70>
{
    80001a74:	715d                	addi	sp,sp,-80
    80001a76:	e486                	sd	ra,72(sp)
    80001a78:	e0a2                	sd	s0,64(sp)
    80001a7a:	fc26                	sd	s1,56(sp)
    80001a7c:	f84a                	sd	s2,48(sp)
    80001a7e:	f44e                	sd	s3,40(sp)
    80001a80:	f052                	sd	s4,32(sp)
    80001a82:	ec56                	sd	s5,24(sp)
    80001a84:	e85a                	sd	s6,16(sp)
    80001a86:	e45e                	sd	s7,8(sp)
    80001a88:	e062                	sd	s8,0(sp)
    80001a8a:	0880                	addi	s0,sp,80
    80001a8c:	8b2a                	mv	s6,a0
    80001a8e:	8a2e                	mv	s4,a1
    80001a90:	8c32                	mv	s8,a2
    80001a92:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001a94:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a96:	6a85                	lui	s5,0x1
    80001a98:	a01d                	j	80001abe <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a9a:	018505b3          	add	a1,a0,s8
    80001a9e:	0004861b          	sext.w	a2,s1
    80001aa2:	412585b3          	sub	a1,a1,s2
    80001aa6:	8552                	mv	a0,s4
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	5e6080e7          	jalr	1510(ra) # 8000108e <memmove>

    len -= n;
    80001ab0:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001ab4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001ab6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001aba:	02098263          	beqz	s3,80001ade <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001abe:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001ac2:	85ca                	mv	a1,s2
    80001ac4:	855a                	mv	a0,s6
    80001ac6:	00000097          	auipc	ra,0x0
    80001aca:	8ee080e7          	jalr	-1810(ra) # 800013b4 <walkaddr>
    if(pa0 == 0)
    80001ace:	cd01                	beqz	a0,80001ae6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001ad0:	418904b3          	sub	s1,s2,s8
    80001ad4:	94d6                	add	s1,s1,s5
    if(n > len)
    80001ad6:	fc99f2e3          	bgeu	s3,s1,80001a9a <copyin+0x28>
    80001ada:	84ce                	mv	s1,s3
    80001adc:	bf7d                	j	80001a9a <copyin+0x28>
  }
  return 0;
    80001ade:	4501                	li	a0,0
    80001ae0:	a021                	j	80001ae8 <copyin+0x76>
    80001ae2:	4501                	li	a0,0
}
    80001ae4:	8082                	ret
      return -1;
    80001ae6:	557d                	li	a0,-1
}
    80001ae8:	60a6                	ld	ra,72(sp)
    80001aea:	6406                	ld	s0,64(sp)
    80001aec:	74e2                	ld	s1,56(sp)
    80001aee:	7942                	ld	s2,48(sp)
    80001af0:	79a2                	ld	s3,40(sp)
    80001af2:	7a02                	ld	s4,32(sp)
    80001af4:	6ae2                	ld	s5,24(sp)
    80001af6:	6b42                	ld	s6,16(sp)
    80001af8:	6ba2                	ld	s7,8(sp)
    80001afa:	6c02                	ld	s8,0(sp)
    80001afc:	6161                	addi	sp,sp,80
    80001afe:	8082                	ret

0000000080001b00 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001b00:	cacd                	beqz	a3,80001bb2 <copyinstr+0xb2>
{
    80001b02:	715d                	addi	sp,sp,-80
    80001b04:	e486                	sd	ra,72(sp)
    80001b06:	e0a2                	sd	s0,64(sp)
    80001b08:	fc26                	sd	s1,56(sp)
    80001b0a:	f84a                	sd	s2,48(sp)
    80001b0c:	f44e                	sd	s3,40(sp)
    80001b0e:	f052                	sd	s4,32(sp)
    80001b10:	ec56                	sd	s5,24(sp)
    80001b12:	e85a                	sd	s6,16(sp)
    80001b14:	e45e                	sd	s7,8(sp)
    80001b16:	0880                	addi	s0,sp,80
    80001b18:	8a2a                	mv	s4,a0
    80001b1a:	8b2e                	mv	s6,a1
    80001b1c:	8bb2                	mv	s7,a2
    80001b1e:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001b20:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001b22:	6985                	lui	s3,0x1
    80001b24:	a825                	j	80001b5c <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001b26:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001b2a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001b2c:	37fd                	addiw	a5,a5,-1
    80001b2e:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001b32:	60a6                	ld	ra,72(sp)
    80001b34:	6406                	ld	s0,64(sp)
    80001b36:	74e2                	ld	s1,56(sp)
    80001b38:	7942                	ld	s2,48(sp)
    80001b3a:	79a2                	ld	s3,40(sp)
    80001b3c:	7a02                	ld	s4,32(sp)
    80001b3e:	6ae2                	ld	s5,24(sp)
    80001b40:	6b42                	ld	s6,16(sp)
    80001b42:	6ba2                	ld	s7,8(sp)
    80001b44:	6161                	addi	sp,sp,80
    80001b46:	8082                	ret
    80001b48:	fff90713          	addi	a4,s2,-1
    80001b4c:	9742                	add	a4,a4,a6
      --max;
    80001b4e:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001b52:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001b56:	04e58663          	beq	a1,a4,80001ba2 <copyinstr+0xa2>
{
    80001b5a:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001b5c:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001b60:	85a6                	mv	a1,s1
    80001b62:	8552                	mv	a0,s4
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	850080e7          	jalr	-1968(ra) # 800013b4 <walkaddr>
    if(pa0 == 0)
    80001b6c:	cd0d                	beqz	a0,80001ba6 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001b6e:	417486b3          	sub	a3,s1,s7
    80001b72:	96ce                	add	a3,a3,s3
    if(n > max)
    80001b74:	00d97363          	bgeu	s2,a3,80001b7a <copyinstr+0x7a>
    80001b78:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001b7a:	955e                	add	a0,a0,s7
    80001b7c:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001b7e:	c695                	beqz	a3,80001baa <copyinstr+0xaa>
    80001b80:	87da                	mv	a5,s6
    80001b82:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001b84:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001b88:	96da                	add	a3,a3,s6
    80001b8a:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001b8c:	00f60733          	add	a4,a2,a5
    80001b90:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd2428>
    80001b94:	db49                	beqz	a4,80001b26 <copyinstr+0x26>
        *dst = *p;
    80001b96:	00e78023          	sb	a4,0(a5)
      dst++;
    80001b9a:	0785                	addi	a5,a5,1
    while(n > 0){
    80001b9c:	fed797e3          	bne	a5,a3,80001b8a <copyinstr+0x8a>
    80001ba0:	b765                	j	80001b48 <copyinstr+0x48>
    80001ba2:	4781                	li	a5,0
    80001ba4:	b761                	j	80001b2c <copyinstr+0x2c>
      return -1;
    80001ba6:	557d                	li	a0,-1
    80001ba8:	b769                	j	80001b32 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001baa:	6b85                	lui	s7,0x1
    80001bac:	9ba6                	add	s7,s7,s1
    80001bae:	87da                	mv	a5,s6
    80001bb0:	b76d                	j	80001b5a <copyinstr+0x5a>
  int got_null = 0;
    80001bb2:	4781                	li	a5,0
  if(got_null){
    80001bb4:	37fd                	addiw	a5,a5,-1
    80001bb6:	0007851b          	sext.w	a0,a5
}
    80001bba:	8082                	ret

0000000080001bbc <transvirt>:

uint64 transvirt(uint64 vaddr, pagetable_t pagetable)
{
    80001bbc:	1141                	addi	sp,sp,-16
    80001bbe:	e422                	sd	s0,8(sp)
    80001bc0:	0800                	addi	s0,sp,16
    80001bc2:	872a                	mv	a4,a0
  for (int level = 2; level > 0; level--)
  {
    pte_t *pte = &pagetable[PX(level, vaddr)];
    80001bc4:	01e55793          	srli	a5,a0,0x1e
    80001bc8:	1ff7f793          	andi	a5,a5,511
    if (*pte & PTE_V) {
    80001bcc:	078e                	slli	a5,a5,0x3
    80001bce:	95be                	add	a1,a1,a5
    80001bd0:	619c                	ld	a5,0(a1)
    80001bd2:	0017f513          	andi	a0,a5,1
    80001bd6:	cd15                	beqz	a0,80001c12 <transvirt+0x56>
      pagetable = (pagetable_t) PTE2PA(*pte);
    80001bd8:	83a9                	srli	a5,a5,0xa
    80001bda:	00c79693          	slli	a3,a5,0xc
    pte_t *pte = &pagetable[PX(level, vaddr)];
    80001bde:	01575793          	srli	a5,a4,0x15
    80001be2:	1ff7f793          	andi	a5,a5,511
    if (*pte & PTE_V) {
    80001be6:	078e                	slli	a5,a5,0x3
    80001be8:	97b6                	add	a5,a5,a3
    80001bea:	639c                	ld	a5,0(a5)
    80001bec:	0017f513          	andi	a0,a5,1
    80001bf0:	c10d                	beqz	a0,80001c12 <transvirt+0x56>
      pagetable = (pagetable_t) PTE2PA(*pte);
    80001bf2:	83a9                	srli	a5,a5,0xa
    80001bf4:	00c79693          	slli	a3,a5,0xc
    } else {
      return 0;
    }
  }
  uint64 pagenum = PTE2PA(pagetable[PX(0, vaddr)]);
    80001bf8:	00c75793          	srli	a5,a4,0xc
    80001bfc:	1ff7f793          	andi	a5,a5,511
    80001c00:	078e                	slli	a5,a5,0x3
    80001c02:	97b6                	add	a5,a5,a3
    80001c04:	639c                	ld	a5,0(a5)
    80001c06:	83a9                	srli	a5,a5,0xa
    80001c08:	07b2                	slli	a5,a5,0xc
  uint64 offset = vaddr & 0xFFF;
    80001c0a:	1752                	slli	a4,a4,0x34
    80001c0c:	9351                	srli	a4,a4,0x34
  return pagenum | offset;
    80001c0e:	00e7e533          	or	a0,a5,a4
}
    80001c12:	6422                	ld	s0,8(sp)
    80001c14:	0141                	addi	sp,sp,16
    80001c16:	8082                	ret

0000000080001c18 <mmap_shared>:

int mmap_shared(uint64 vaddr, int npages, pagetable_t pagetable, int protocol)
{
    80001c18:	715d                	addi	sp,sp,-80
    80001c1a:	e486                	sd	ra,72(sp)
    80001c1c:	e0a2                	sd	s0,64(sp)
    80001c1e:	f052                	sd	s4,32(sp)
    80001c20:	0880                	addi	s0,sp,80
  uint64 end = vaddr + npages * PGSIZE;
    80001c22:	00c5959b          	slliw	a1,a1,0xc
    80001c26:	00a58a33          	add	s4,a1,a0
  for (uint64 va = vaddr; va < end; va += PGSIZE)
    80001c2a:	0b457b63          	bgeu	a0,s4,80001ce0 <mmap_shared+0xc8>
    80001c2e:	fc26                	sd	s1,56(sp)
    80001c30:	f84a                	sd	s2,48(sp)
    80001c32:	f44e                	sd	s3,40(sp)
    80001c34:	ec56                	sd	s5,24(sp)
    80001c36:	e85a                	sd	s6,16(sp)
    80001c38:	e45e                	sd	s7,8(sp)
    80001c3a:	e062                	sd	s8,0(sp)
    80001c3c:	892a                	mv	s2,a0
    80001c3e:	8ab2                	mv	s5,a2
    }

    uint flags = PTE_FLAGS(*pte);
    flags |= PTE_S;

    if (protocol & PROT_READ) {
    80001c40:	0016fb93          	andi	s7,a3,1
      }
    } else {
      flags &= ~PTE_R; // make non readable
    }

    if (protocol & PROT_WRITE) {
    80001c44:	0026f993          	andi	s3,a3,2
      }
    } else {
      flags &= ~PTE_W; // make non writable
    }

    *pte = PA2PTE(PTE2PA(*pte)) | flags;
    80001c48:	7b7d                	lui	s6,0xfffff
    80001c4a:	002b5b13          	srli	s6,s6,0x2
  for (uint64 va = vaddr; va < end; va += PGSIZE)
    80001c4e:	6c05                	lui	s8,0x1
    80001c50:	a091                	j	80001c94 <mmap_shared+0x7c>
      cow_triggered(pte);
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	12c080e7          	jalr	300(ra) # 80000d7e <cow_triggered>
    80001c5a:	a8a9                	j	80001cb4 <mmap_shared+0x9c>
      flags &= ~PTE_R; // make non readable
    80001c5c:	3fd7f793          	andi	a5,a5,1021
    80001c60:	1007e793          	ori	a5,a5,256
    if (protocol & PROT_WRITE) {
    80001c64:	00098e63          	beqz	s3,80001c80 <mmap_shared+0x68>
      if (!(*pte & PTE_W)) {
    80001c68:	00477693          	andi	a3,a4,4
    80001c6c:	ea99                	bnez	a3,80001c82 <mmap_shared+0x6a>
        return 3; // can't make non writeable page into writable
    80001c6e:	450d                	li	a0,3
    80001c70:	74e2                	ld	s1,56(sp)
    80001c72:	7942                	ld	s2,48(sp)
    80001c74:	79a2                	ld	s3,40(sp)
    80001c76:	6ae2                	ld	s5,24(sp)
    80001c78:	6b42                	ld	s6,16(sp)
    80001c7a:	6ba2                	ld	s7,8(sp)
    80001c7c:	6c02                	ld	s8,0(sp)
    80001c7e:	a89d                	j	80001cf4 <mmap_shared+0xdc>
      flags &= ~PTE_W; // make non writable
    80001c80:	9bed                	andi	a5,a5,-5
    *pte = PA2PTE(PTE2PA(*pte)) | flags;
    80001c82:	01677733          	and	a4,a4,s6
    80001c86:	1782                	slli	a5,a5,0x20
    80001c88:	9381                	srli	a5,a5,0x20
    80001c8a:	8f5d                	or	a4,a4,a5
    80001c8c:	e098                	sd	a4,0(s1)
  for (uint64 va = vaddr; va < end; va += PGSIZE)
    80001c8e:	9962                	add	s2,s2,s8
    80001c90:	03497f63          	bgeu	s2,s4,80001cce <mmap_shared+0xb6>
    pte_t *pte = walk(pagetable, va, 0);
    80001c94:	4601                	li	a2,0
    80001c96:	85ca                	mv	a1,s2
    80001c98:	8556                	mv	a0,s5
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	674080e7          	jalr	1652(ra) # 8000130e <walk>
    80001ca2:	84aa                	mv	s1,a0
    if (pte == 0 || !(*pte & PTE_V)) {
    80001ca4:	c121                	beqz	a0,80001ce4 <mmap_shared+0xcc>
    80001ca6:	611c                	ld	a5,0(a0)
    80001ca8:	0017f713          	andi	a4,a5,1
    80001cac:	cb29                	beqz	a4,80001cfe <mmap_shared+0xe6>
    if (*pte & PTE_COW) {
    80001cae:	2007f793          	andi	a5,a5,512
    80001cb2:	f3c5                	bnez	a5,80001c52 <mmap_shared+0x3a>
    uint flags = PTE_FLAGS(*pte);
    80001cb4:	6098                	ld	a4,0(s1)
    80001cb6:	0007079b          	sext.w	a5,a4
    if (protocol & PROT_READ) {
    80001cba:	fa0b81e3          	beqz	s7,80001c5c <mmap_shared+0x44>
      if (!(*pte & PTE_R)) {
    80001cbe:	00277693          	andi	a3,a4,2
    80001cc2:	c6b9                	beqz	a3,80001d10 <mmap_shared+0xf8>
    uint flags = PTE_FLAGS(*pte);
    80001cc4:	3ff7f793          	andi	a5,a5,1023
    flags |= PTE_S;
    80001cc8:	1007e793          	ori	a5,a5,256
    80001ccc:	bf61                	j	80001c64 <mmap_shared+0x4c>
  }

  return 0;
    80001cce:	4501                	li	a0,0
    80001cd0:	74e2                	ld	s1,56(sp)
    80001cd2:	7942                	ld	s2,48(sp)
    80001cd4:	79a2                	ld	s3,40(sp)
    80001cd6:	6ae2                	ld	s5,24(sp)
    80001cd8:	6b42                	ld	s6,16(sp)
    80001cda:	6ba2                	ld	s7,8(sp)
    80001cdc:	6c02                	ld	s8,0(sp)
    80001cde:	a819                	j	80001cf4 <mmap_shared+0xdc>
    80001ce0:	4501                	li	a0,0
    80001ce2:	a809                	j	80001cf4 <mmap_shared+0xdc>
      return 1;
    80001ce4:	4505                	li	a0,1
    80001ce6:	74e2                	ld	s1,56(sp)
    80001ce8:	7942                	ld	s2,48(sp)
    80001cea:	79a2                	ld	s3,40(sp)
    80001cec:	6ae2                	ld	s5,24(sp)
    80001cee:	6b42                	ld	s6,16(sp)
    80001cf0:	6ba2                	ld	s7,8(sp)
    80001cf2:	6c02                	ld	s8,0(sp)
}
    80001cf4:	60a6                	ld	ra,72(sp)
    80001cf6:	6406                	ld	s0,64(sp)
    80001cf8:	7a02                	ld	s4,32(sp)
    80001cfa:	6161                	addi	sp,sp,80
    80001cfc:	8082                	ret
      return 1;
    80001cfe:	4505                	li	a0,1
    80001d00:	74e2                	ld	s1,56(sp)
    80001d02:	7942                	ld	s2,48(sp)
    80001d04:	79a2                	ld	s3,40(sp)
    80001d06:	6ae2                	ld	s5,24(sp)
    80001d08:	6b42                	ld	s6,16(sp)
    80001d0a:	6ba2                	ld	s7,8(sp)
    80001d0c:	6c02                	ld	s8,0(sp)
    80001d0e:	b7dd                	j	80001cf4 <mmap_shared+0xdc>
        return 2; // can't make non readable page into readable
    80001d10:	4509                	li	a0,2
    80001d12:	74e2                	ld	s1,56(sp)
    80001d14:	7942                	ld	s2,48(sp)
    80001d16:	79a2                	ld	s3,40(sp)
    80001d18:	6ae2                	ld	s5,24(sp)
    80001d1a:	6b42                	ld	s6,16(sp)
    80001d1c:	6ba2                	ld	s7,8(sp)
    80001d1e:	6c02                	ld	s8,0(sp)
    80001d20:	bfd1                	j	80001cf4 <mmap_shared+0xdc>

0000000080001d22 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001d22:	715d                	addi	sp,sp,-80
    80001d24:	e486                	sd	ra,72(sp)
    80001d26:	e0a2                	sd	s0,64(sp)
    80001d28:	fc26                	sd	s1,56(sp)
    80001d2a:	f84a                	sd	s2,48(sp)
    80001d2c:	f44e                	sd	s3,40(sp)
    80001d2e:	f052                	sd	s4,32(sp)
    80001d30:	ec56                	sd	s5,24(sp)
    80001d32:	e85a                	sd	s6,16(sp)
    80001d34:	e45e                	sd	s7,8(sp)
    80001d36:	e062                	sd	s8,0(sp)
    80001d38:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001d3a:	8792                	mv	a5,tp
    int id = r_tp();
    80001d3c:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001d3e:	0001aa97          	auipc	s5,0x1a
    80001d42:	c8aa8a93          	addi	s5,s5,-886 # 8001b9c8 <cpus>
    80001d46:	00779713          	slli	a4,a5,0x7
    80001d4a:	00ea86b3          	add	a3,s5,a4
    80001d4e:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffd2428>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001d52:	0721                	addi	a4,a4,8
    80001d54:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001d56:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001d58:	0000ac17          	auipc	s8,0xa
    80001d5c:	910c0c13          	addi	s8,s8,-1776 # 8000b668 <sched_pointer>
    80001d60:	00000b97          	auipc	s7,0x0
    80001d64:	fc2b8b93          	addi	s7,s7,-62 # 80001d22 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001d68:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d6c:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001d70:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001d74:	0001a497          	auipc	s1,0x1a
    80001d78:	08448493          	addi	s1,s1,132 # 8001bdf8 <proc>
            if (p->state == RUNNABLE)
    80001d7c:	498d                	li	s3,3
                p->state = RUNNING;
    80001d7e:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001d80:	00020a17          	auipc	s4,0x20
    80001d84:	a78a0a13          	addi	s4,s4,-1416 # 800217f8 <tickslock>
    80001d88:	a81d                	j	80001dbe <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	25e080e7          	jalr	606(ra) # 80000fea <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001d94:	60a6                	ld	ra,72(sp)
    80001d96:	6406                	ld	s0,64(sp)
    80001d98:	74e2                	ld	s1,56(sp)
    80001d9a:	7942                	ld	s2,48(sp)
    80001d9c:	79a2                	ld	s3,40(sp)
    80001d9e:	7a02                	ld	s4,32(sp)
    80001da0:	6ae2                	ld	s5,24(sp)
    80001da2:	6b42                	ld	s6,16(sp)
    80001da4:	6ba2                	ld	s7,8(sp)
    80001da6:	6c02                	ld	s8,0(sp)
    80001da8:	6161                	addi	sp,sp,80
    80001daa:	8082                	ret
            release(&p->lock);
    80001dac:	8526                	mv	a0,s1
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	23c080e7          	jalr	572(ra) # 80000fea <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001db6:	16848493          	addi	s1,s1,360
    80001dba:	fb4487e3          	beq	s1,s4,80001d68 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001dbe:	8526                	mv	a0,s1
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	176080e7          	jalr	374(ra) # 80000f36 <acquire>
            if (p->state == RUNNABLE)
    80001dc8:	4c9c                	lw	a5,24(s1)
    80001dca:	ff3791e3          	bne	a5,s3,80001dac <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001dce:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001dd2:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001dd6:	06048593          	addi	a1,s1,96
    80001dda:	8556                	mv	a0,s5
    80001ddc:	00001097          	auipc	ra,0x1
    80001de0:	044080e7          	jalr	68(ra) # 80002e20 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001de4:	000c3783          	ld	a5,0(s8)
    80001de8:	fb7791e3          	bne	a5,s7,80001d8a <rr_scheduler+0x68>
                c->proc = 0;
    80001dec:	00093023          	sd	zero,0(s2)
    80001df0:	bf75                	j	80001dac <rr_scheduler+0x8a>

0000000080001df2 <proc_mapstacks>:
{
    80001df2:	7139                	addi	sp,sp,-64
    80001df4:	fc06                	sd	ra,56(sp)
    80001df6:	f822                	sd	s0,48(sp)
    80001df8:	f426                	sd	s1,40(sp)
    80001dfa:	f04a                	sd	s2,32(sp)
    80001dfc:	ec4e                	sd	s3,24(sp)
    80001dfe:	e852                	sd	s4,16(sp)
    80001e00:	e456                	sd	s5,8(sp)
    80001e02:	e05a                	sd	s6,0(sp)
    80001e04:	0080                	addi	s0,sp,64
    80001e06:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001e08:	0001a497          	auipc	s1,0x1a
    80001e0c:	ff048493          	addi	s1,s1,-16 # 8001bdf8 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001e10:	8b26                	mv	s6,s1
    80001e12:	04fa5937          	lui	s2,0x4fa5
    80001e16:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001e1a:	0932                	slli	s2,s2,0xc
    80001e1c:	fa590913          	addi	s2,s2,-91
    80001e20:	0932                	slli	s2,s2,0xc
    80001e22:	fa590913          	addi	s2,s2,-91
    80001e26:	0932                	slli	s2,s2,0xc
    80001e28:	fa590913          	addi	s2,s2,-91
    80001e2c:	040009b7          	lui	s3,0x4000
    80001e30:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001e32:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001e34:	00020a97          	auipc	s5,0x20
    80001e38:	9c4a8a93          	addi	s5,s5,-1596 # 800217f8 <tickslock>
        char *pa = kalloc();
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	e4a080e7          	jalr	-438(ra) # 80000c86 <kalloc>
    80001e44:	862a                	mv	a2,a0
        if (pa == 0)
    80001e46:	c121                	beqz	a0,80001e86 <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001e48:	416485b3          	sub	a1,s1,s6
    80001e4c:	858d                	srai	a1,a1,0x3
    80001e4e:	032585b3          	mul	a1,a1,s2
    80001e52:	2585                	addiw	a1,a1,1
    80001e54:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001e58:	4719                	li	a4,6
    80001e5a:	6685                	lui	a3,0x1
    80001e5c:	40b985b3          	sub	a1,s3,a1
    80001e60:	8552                	mv	a0,s4
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	634080e7          	jalr	1588(ra) # 80001496 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e6a:	16848493          	addi	s1,s1,360
    80001e6e:	fd5497e3          	bne	s1,s5,80001e3c <proc_mapstacks+0x4a>
}
    80001e72:	70e2                	ld	ra,56(sp)
    80001e74:	7442                	ld	s0,48(sp)
    80001e76:	74a2                	ld	s1,40(sp)
    80001e78:	7902                	ld	s2,32(sp)
    80001e7a:	69e2                	ld	s3,24(sp)
    80001e7c:	6a42                	ld	s4,16(sp)
    80001e7e:	6aa2                	ld	s5,8(sp)
    80001e80:	6b02                	ld	s6,0(sp)
    80001e82:	6121                	addi	sp,sp,64
    80001e84:	8082                	ret
            panic("kalloc");
    80001e86:	00006517          	auipc	a0,0x6
    80001e8a:	3ba50513          	addi	a0,a0,954 # 80008240 <__func__.1+0x238>
    80001e8e:	ffffe097          	auipc	ra,0xffffe
    80001e92:	6d2080e7          	jalr	1746(ra) # 80000560 <panic>

0000000080001e96 <procinit>:
{
    80001e96:	7139                	addi	sp,sp,-64
    80001e98:	fc06                	sd	ra,56(sp)
    80001e9a:	f822                	sd	s0,48(sp)
    80001e9c:	f426                	sd	s1,40(sp)
    80001e9e:	f04a                	sd	s2,32(sp)
    80001ea0:	ec4e                	sd	s3,24(sp)
    80001ea2:	e852                	sd	s4,16(sp)
    80001ea4:	e456                	sd	s5,8(sp)
    80001ea6:	e05a                	sd	s6,0(sp)
    80001ea8:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001eaa:	00006597          	auipc	a1,0x6
    80001eae:	39e58593          	addi	a1,a1,926 # 80008248 <__func__.1+0x240>
    80001eb2:	0001a517          	auipc	a0,0x1a
    80001eb6:	f1650513          	addi	a0,a0,-234 # 8001bdc8 <pid_lock>
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	fec080e7          	jalr	-20(ra) # 80000ea6 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001ec2:	00006597          	auipc	a1,0x6
    80001ec6:	38e58593          	addi	a1,a1,910 # 80008250 <__func__.1+0x248>
    80001eca:	0001a517          	auipc	a0,0x1a
    80001ece:	f1650513          	addi	a0,a0,-234 # 8001bde0 <wait_lock>
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	fd4080e7          	jalr	-44(ra) # 80000ea6 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001eda:	0001a497          	auipc	s1,0x1a
    80001ede:	f1e48493          	addi	s1,s1,-226 # 8001bdf8 <proc>
        initlock(&p->lock, "proc");
    80001ee2:	00006b17          	auipc	s6,0x6
    80001ee6:	37eb0b13          	addi	s6,s6,894 # 80008260 <__func__.1+0x258>
        p->kstack = KSTACK((int)(p - proc));
    80001eea:	8aa6                	mv	s5,s1
    80001eec:	04fa5937          	lui	s2,0x4fa5
    80001ef0:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001ef4:	0932                	slli	s2,s2,0xc
    80001ef6:	fa590913          	addi	s2,s2,-91
    80001efa:	0932                	slli	s2,s2,0xc
    80001efc:	fa590913          	addi	s2,s2,-91
    80001f00:	0932                	slli	s2,s2,0xc
    80001f02:	fa590913          	addi	s2,s2,-91
    80001f06:	040009b7          	lui	s3,0x4000
    80001f0a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001f0c:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001f0e:	00020a17          	auipc	s4,0x20
    80001f12:	8eaa0a13          	addi	s4,s4,-1814 # 800217f8 <tickslock>
        initlock(&p->lock, "proc");
    80001f16:	85da                	mv	a1,s6
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	f8c080e7          	jalr	-116(ra) # 80000ea6 <initlock>
        p->state = UNUSED;
    80001f22:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001f26:	415487b3          	sub	a5,s1,s5
    80001f2a:	878d                	srai	a5,a5,0x3
    80001f2c:	032787b3          	mul	a5,a5,s2
    80001f30:	2785                	addiw	a5,a5,1
    80001f32:	00d7979b          	slliw	a5,a5,0xd
    80001f36:	40f987b3          	sub	a5,s3,a5
    80001f3a:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001f3c:	16848493          	addi	s1,s1,360
    80001f40:	fd449be3          	bne	s1,s4,80001f16 <procinit+0x80>
}
    80001f44:	70e2                	ld	ra,56(sp)
    80001f46:	7442                	ld	s0,48(sp)
    80001f48:	74a2                	ld	s1,40(sp)
    80001f4a:	7902                	ld	s2,32(sp)
    80001f4c:	69e2                	ld	s3,24(sp)
    80001f4e:	6a42                	ld	s4,16(sp)
    80001f50:	6aa2                	ld	s5,8(sp)
    80001f52:	6b02                	ld	s6,0(sp)
    80001f54:	6121                	addi	sp,sp,64
    80001f56:	8082                	ret

0000000080001f58 <copy_array>:
{
    80001f58:	1141                	addi	sp,sp,-16
    80001f5a:	e422                	sd	s0,8(sp)
    80001f5c:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001f5e:	00c05c63          	blez	a2,80001f76 <copy_array+0x1e>
    80001f62:	87aa                	mv	a5,a0
    80001f64:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001f66:	0007c703          	lbu	a4,0(a5)
    80001f6a:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001f6e:	0785                	addi	a5,a5,1
    80001f70:	0585                	addi	a1,a1,1
    80001f72:	fea79ae3          	bne	a5,a0,80001f66 <copy_array+0xe>
}
    80001f76:	6422                	ld	s0,8(sp)
    80001f78:	0141                	addi	sp,sp,16
    80001f7a:	8082                	ret

0000000080001f7c <cpuid>:
{
    80001f7c:	1141                	addi	sp,sp,-16
    80001f7e:	e422                	sd	s0,8(sp)
    80001f80:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001f82:	8512                	mv	a0,tp
}
    80001f84:	2501                	sext.w	a0,a0
    80001f86:	6422                	ld	s0,8(sp)
    80001f88:	0141                	addi	sp,sp,16
    80001f8a:	8082                	ret

0000000080001f8c <mycpu>:
{
    80001f8c:	1141                	addi	sp,sp,-16
    80001f8e:	e422                	sd	s0,8(sp)
    80001f90:	0800                	addi	s0,sp,16
    80001f92:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001f94:	2781                	sext.w	a5,a5
    80001f96:	079e                	slli	a5,a5,0x7
}
    80001f98:	0001a517          	auipc	a0,0x1a
    80001f9c:	a3050513          	addi	a0,a0,-1488 # 8001b9c8 <cpus>
    80001fa0:	953e                	add	a0,a0,a5
    80001fa2:	6422                	ld	s0,8(sp)
    80001fa4:	0141                	addi	sp,sp,16
    80001fa6:	8082                	ret

0000000080001fa8 <myproc>:
{
    80001fa8:	1101                	addi	sp,sp,-32
    80001faa:	ec06                	sd	ra,24(sp)
    80001fac:	e822                	sd	s0,16(sp)
    80001fae:	e426                	sd	s1,8(sp)
    80001fb0:	1000                	addi	s0,sp,32
    push_off();
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	f38080e7          	jalr	-200(ra) # 80000eea <push_off>
    80001fba:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001fbc:	2781                	sext.w	a5,a5
    80001fbe:	079e                	slli	a5,a5,0x7
    80001fc0:	0001a717          	auipc	a4,0x1a
    80001fc4:	a0870713          	addi	a4,a4,-1528 # 8001b9c8 <cpus>
    80001fc8:	97ba                	add	a5,a5,a4
    80001fca:	6384                	ld	s1,0(a5)
    pop_off();
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	fbe080e7          	jalr	-66(ra) # 80000f8a <pop_off>
}
    80001fd4:	8526                	mv	a0,s1
    80001fd6:	60e2                	ld	ra,24(sp)
    80001fd8:	6442                	ld	s0,16(sp)
    80001fda:	64a2                	ld	s1,8(sp)
    80001fdc:	6105                	addi	sp,sp,32
    80001fde:	8082                	ret

0000000080001fe0 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001fe0:	1141                	addi	sp,sp,-16
    80001fe2:	e406                	sd	ra,8(sp)
    80001fe4:	e022                	sd	s0,0(sp)
    80001fe6:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001fe8:	00000097          	auipc	ra,0x0
    80001fec:	fc0080e7          	jalr	-64(ra) # 80001fa8 <myproc>
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	ffa080e7          	jalr	-6(ra) # 80000fea <release>

    if (first)
    80001ff8:	00009797          	auipc	a5,0x9
    80001ffc:	6687a783          	lw	a5,1640(a5) # 8000b660 <first.1>
    80002000:	eb89                	bnez	a5,80002012 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80002002:	00001097          	auipc	ra,0x1
    80002006:	ec8080e7          	jalr	-312(ra) # 80002eca <usertrapret>
}
    8000200a:	60a2                	ld	ra,8(sp)
    8000200c:	6402                	ld	s0,0(sp)
    8000200e:	0141                	addi	sp,sp,16
    80002010:	8082                	ret
        first = 0;
    80002012:	00009797          	auipc	a5,0x9
    80002016:	6407a723          	sw	zero,1614(a5) # 8000b660 <first.1>
        fsinit(ROOTDEV);
    8000201a:	4505                	li	a0,1
    8000201c:	00002097          	auipc	ra,0x2
    80002020:	e70080e7          	jalr	-400(ra) # 80003e8c <fsinit>
    80002024:	bff9                	j	80002002 <forkret+0x22>

0000000080002026 <allocpid>:
{
    80002026:	1101                	addi	sp,sp,-32
    80002028:	ec06                	sd	ra,24(sp)
    8000202a:	e822                	sd	s0,16(sp)
    8000202c:	e426                	sd	s1,8(sp)
    8000202e:	e04a                	sd	s2,0(sp)
    80002030:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80002032:	0001a917          	auipc	s2,0x1a
    80002036:	d9690913          	addi	s2,s2,-618 # 8001bdc8 <pid_lock>
    8000203a:	854a                	mv	a0,s2
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	efa080e7          	jalr	-262(ra) # 80000f36 <acquire>
    pid = nextpid;
    80002044:	00009797          	auipc	a5,0x9
    80002048:	62c78793          	addi	a5,a5,1580 # 8000b670 <nextpid>
    8000204c:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    8000204e:	0014871b          	addiw	a4,s1,1
    80002052:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80002054:	854a                	mv	a0,s2
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	f94080e7          	jalr	-108(ra) # 80000fea <release>
}
    8000205e:	8526                	mv	a0,s1
    80002060:	60e2                	ld	ra,24(sp)
    80002062:	6442                	ld	s0,16(sp)
    80002064:	64a2                	ld	s1,8(sp)
    80002066:	6902                	ld	s2,0(sp)
    80002068:	6105                	addi	sp,sp,32
    8000206a:	8082                	ret

000000008000206c <proc_pagetable>:
{
    8000206c:	1101                	addi	sp,sp,-32
    8000206e:	ec06                	sd	ra,24(sp)
    80002070:	e822                	sd	s0,16(sp)
    80002072:	e426                	sd	s1,8(sp)
    80002074:	e04a                	sd	s2,0(sp)
    80002076:	1000                	addi	s0,sp,32
    80002078:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	616080e7          	jalr	1558(ra) # 80001690 <uvmcreate>
    80002082:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80002084:	c121                	beqz	a0,800020c4 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80002086:	4729                	li	a4,10
    80002088:	00005697          	auipc	a3,0x5
    8000208c:	f7868693          	addi	a3,a3,-136 # 80007000 <_trampoline>
    80002090:	6605                	lui	a2,0x1
    80002092:	040005b7          	lui	a1,0x4000
    80002096:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002098:	05b2                	slli	a1,a1,0xc
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	35c080e7          	jalr	860(ra) # 800013f6 <mappages>
    800020a2:	02054863          	bltz	a0,800020d2 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    800020a6:	4719                	li	a4,6
    800020a8:	05893683          	ld	a3,88(s2)
    800020ac:	6605                	lui	a2,0x1
    800020ae:	020005b7          	lui	a1,0x2000
    800020b2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800020b4:	05b6                	slli	a1,a1,0xd
    800020b6:	8526                	mv	a0,s1
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	33e080e7          	jalr	830(ra) # 800013f6 <mappages>
    800020c0:	02054163          	bltz	a0,800020e2 <proc_pagetable+0x76>
}
    800020c4:	8526                	mv	a0,s1
    800020c6:	60e2                	ld	ra,24(sp)
    800020c8:	6442                	ld	s0,16(sp)
    800020ca:	64a2                	ld	s1,8(sp)
    800020cc:	6902                	ld	s2,0(sp)
    800020ce:	6105                	addi	sp,sp,32
    800020d0:	8082                	ret
        uvmfree(pagetable, 0);
    800020d2:	4581                	li	a1,0
    800020d4:	8526                	mv	a0,s1
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	7cc080e7          	jalr	1996(ra) # 800018a2 <uvmfree>
        return 0;
    800020de:	4481                	li	s1,0
    800020e0:	b7d5                	j	800020c4 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800020e2:	4681                	li	a3,0
    800020e4:	4605                	li	a2,1
    800020e6:	040005b7          	lui	a1,0x4000
    800020ea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800020ec:	05b2                	slli	a1,a1,0xc
    800020ee:	8526                	mv	a0,s1
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	4cc080e7          	jalr	1228(ra) # 800015bc <uvmunmap>
        uvmfree(pagetable, 0);
    800020f8:	4581                	li	a1,0
    800020fa:	8526                	mv	a0,s1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	7a6080e7          	jalr	1958(ra) # 800018a2 <uvmfree>
        return 0;
    80002104:	4481                	li	s1,0
    80002106:	bf7d                	j	800020c4 <proc_pagetable+0x58>

0000000080002108 <proc_freepagetable>:
{
    80002108:	1101                	addi	sp,sp,-32
    8000210a:	ec06                	sd	ra,24(sp)
    8000210c:	e822                	sd	s0,16(sp)
    8000210e:	e426                	sd	s1,8(sp)
    80002110:	e04a                	sd	s2,0(sp)
    80002112:	1000                	addi	s0,sp,32
    80002114:	84aa                	mv	s1,a0
    80002116:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002118:	4681                	li	a3,0
    8000211a:	4605                	li	a2,1
    8000211c:	040005b7          	lui	a1,0x4000
    80002120:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002122:	05b2                	slli	a1,a1,0xc
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	498080e7          	jalr	1176(ra) # 800015bc <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000212c:	4681                	li	a3,0
    8000212e:	4605                	li	a2,1
    80002130:	020005b7          	lui	a1,0x2000
    80002134:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002136:	05b6                	slli	a1,a1,0xd
    80002138:	8526                	mv	a0,s1
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	482080e7          	jalr	1154(ra) # 800015bc <uvmunmap>
    uvmfree(pagetable, sz);
    80002142:	85ca                	mv	a1,s2
    80002144:	8526                	mv	a0,s1
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	75c080e7          	jalr	1884(ra) # 800018a2 <uvmfree>
}
    8000214e:	60e2                	ld	ra,24(sp)
    80002150:	6442                	ld	s0,16(sp)
    80002152:	64a2                	ld	s1,8(sp)
    80002154:	6902                	ld	s2,0(sp)
    80002156:	6105                	addi	sp,sp,32
    80002158:	8082                	ret

000000008000215a <freeproc>:
{
    8000215a:	1101                	addi	sp,sp,-32
    8000215c:	ec06                	sd	ra,24(sp)
    8000215e:	e822                	sd	s0,16(sp)
    80002160:	e426                	sd	s1,8(sp)
    80002162:	1000                	addi	s0,sp,32
    80002164:	84aa                	mv	s1,a0
    if (p->trapframe)
    80002166:	6d28                	ld	a0,88(a0)
    80002168:	c509                	beqz	a0,80002172 <freeproc+0x18>
        kfree((void *)p->trapframe);
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	92a080e7          	jalr	-1750(ra) # 80000a94 <kfree>
    p->trapframe = 0;
    80002172:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80002176:	68a8                	ld	a0,80(s1)
    80002178:	c511                	beqz	a0,80002184 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    8000217a:	64ac                	ld	a1,72(s1)
    8000217c:	00000097          	auipc	ra,0x0
    80002180:	f8c080e7          	jalr	-116(ra) # 80002108 <proc_freepagetable>
    p->pagetable = 0;
    80002184:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80002188:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    8000218c:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80002190:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80002194:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80002198:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    8000219c:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    800021a0:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    800021a4:	0004ac23          	sw	zero,24(s1)
}
    800021a8:	60e2                	ld	ra,24(sp)
    800021aa:	6442                	ld	s0,16(sp)
    800021ac:	64a2                	ld	s1,8(sp)
    800021ae:	6105                	addi	sp,sp,32
    800021b0:	8082                	ret

00000000800021b2 <allocproc>:
{
    800021b2:	1101                	addi	sp,sp,-32
    800021b4:	ec06                	sd	ra,24(sp)
    800021b6:	e822                	sd	s0,16(sp)
    800021b8:	e426                	sd	s1,8(sp)
    800021ba:	e04a                	sd	s2,0(sp)
    800021bc:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    800021be:	0001a497          	auipc	s1,0x1a
    800021c2:	c3a48493          	addi	s1,s1,-966 # 8001bdf8 <proc>
    800021c6:	0001f917          	auipc	s2,0x1f
    800021ca:	63290913          	addi	s2,s2,1586 # 800217f8 <tickslock>
        acquire(&p->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	d66080e7          	jalr	-666(ra) # 80000f36 <acquire>
        if (p->state == UNUSED)
    800021d8:	4c9c                	lw	a5,24(s1)
    800021da:	cf81                	beqz	a5,800021f2 <allocproc+0x40>
            release(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	e0c080e7          	jalr	-500(ra) # 80000fea <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800021e6:	16848493          	addi	s1,s1,360
    800021ea:	ff2492e3          	bne	s1,s2,800021ce <allocproc+0x1c>
    return 0;
    800021ee:	4481                	li	s1,0
    800021f0:	a889                	j	80002242 <allocproc+0x90>
    p->pid = allocpid();
    800021f2:	00000097          	auipc	ra,0x0
    800021f6:	e34080e7          	jalr	-460(ra) # 80002026 <allocpid>
    800021fa:	d888                	sw	a0,48(s1)
    p->state = USED;
    800021fc:	4785                	li	a5,1
    800021fe:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	a86080e7          	jalr	-1402(ra) # 80000c86 <kalloc>
    80002208:	892a                	mv	s2,a0
    8000220a:	eca8                	sd	a0,88(s1)
    8000220c:	c131                	beqz	a0,80002250 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    8000220e:	8526                	mv	a0,s1
    80002210:	00000097          	auipc	ra,0x0
    80002214:	e5c080e7          	jalr	-420(ra) # 8000206c <proc_pagetable>
    80002218:	892a                	mv	s2,a0
    8000221a:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    8000221c:	c531                	beqz	a0,80002268 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    8000221e:	07000613          	li	a2,112
    80002222:	4581                	li	a1,0
    80002224:	06048513          	addi	a0,s1,96
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	e0a080e7          	jalr	-502(ra) # 80001032 <memset>
    p->context.ra = (uint64)forkret;
    80002230:	00000797          	auipc	a5,0x0
    80002234:	db078793          	addi	a5,a5,-592 # 80001fe0 <forkret>
    80002238:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    8000223a:	60bc                	ld	a5,64(s1)
    8000223c:	6705                	lui	a4,0x1
    8000223e:	97ba                	add	a5,a5,a4
    80002240:	f4bc                	sd	a5,104(s1)
}
    80002242:	8526                	mv	a0,s1
    80002244:	60e2                	ld	ra,24(sp)
    80002246:	6442                	ld	s0,16(sp)
    80002248:	64a2                	ld	s1,8(sp)
    8000224a:	6902                	ld	s2,0(sp)
    8000224c:	6105                	addi	sp,sp,32
    8000224e:	8082                	ret
        freeproc(p);
    80002250:	8526                	mv	a0,s1
    80002252:	00000097          	auipc	ra,0x0
    80002256:	f08080e7          	jalr	-248(ra) # 8000215a <freeproc>
        release(&p->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	d8e080e7          	jalr	-626(ra) # 80000fea <release>
        return 0;
    80002264:	84ca                	mv	s1,s2
    80002266:	bff1                	j	80002242 <allocproc+0x90>
        freeproc(p);
    80002268:	8526                	mv	a0,s1
    8000226a:	00000097          	auipc	ra,0x0
    8000226e:	ef0080e7          	jalr	-272(ra) # 8000215a <freeproc>
        release(&p->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	d76080e7          	jalr	-650(ra) # 80000fea <release>
        return 0;
    8000227c:	84ca                	mv	s1,s2
    8000227e:	b7d1                	j	80002242 <allocproc+0x90>

0000000080002280 <userinit>:
{
    80002280:	1101                	addi	sp,sp,-32
    80002282:	ec06                	sd	ra,24(sp)
    80002284:	e822                	sd	s0,16(sp)
    80002286:	e426                	sd	s1,8(sp)
    80002288:	1000                	addi	s0,sp,32
    p = allocproc();
    8000228a:	00000097          	auipc	ra,0x0
    8000228e:	f28080e7          	jalr	-216(ra) # 800021b2 <allocproc>
    80002292:	84aa                	mv	s1,a0
    initproc = p;
    80002294:	00009797          	auipc	a5,0x9
    80002298:	4aa7b223          	sd	a0,1188(a5) # 8000b738 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000229c:	03400613          	li	a2,52
    800022a0:	00009597          	auipc	a1,0x9
    800022a4:	3e058593          	addi	a1,a1,992 # 8000b680 <initcode>
    800022a8:	6928                	ld	a0,80(a0)
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	414080e7          	jalr	1044(ra) # 800016be <uvmfirst>
    p->sz = PGSIZE;
    800022b2:	6785                	lui	a5,0x1
    800022b4:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    800022b6:	6cb8                	ld	a4,88(s1)
    800022b8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    800022bc:	6cb8                	ld	a4,88(s1)
    800022be:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    800022c0:	4641                	li	a2,16
    800022c2:	00006597          	auipc	a1,0x6
    800022c6:	fa658593          	addi	a1,a1,-90 # 80008268 <__func__.1+0x260>
    800022ca:	15848513          	addi	a0,s1,344
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	ea6080e7          	jalr	-346(ra) # 80001174 <safestrcpy>
    p->cwd = namei("/");
    800022d6:	00006517          	auipc	a0,0x6
    800022da:	fa250513          	addi	a0,a0,-94 # 80008278 <__func__.1+0x270>
    800022de:	00002097          	auipc	ra,0x2
    800022e2:	600080e7          	jalr	1536(ra) # 800048de <namei>
    800022e6:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    800022ea:	478d                	li	a5,3
    800022ec:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	cfa080e7          	jalr	-774(ra) # 80000fea <release>
}
    800022f8:	60e2                	ld	ra,24(sp)
    800022fa:	6442                	ld	s0,16(sp)
    800022fc:	64a2                	ld	s1,8(sp)
    800022fe:	6105                	addi	sp,sp,32
    80002300:	8082                	ret

0000000080002302 <growproc>:
{
    80002302:	1101                	addi	sp,sp,-32
    80002304:	ec06                	sd	ra,24(sp)
    80002306:	e822                	sd	s0,16(sp)
    80002308:	e426                	sd	s1,8(sp)
    8000230a:	e04a                	sd	s2,0(sp)
    8000230c:	1000                	addi	s0,sp,32
    8000230e:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002310:	00000097          	auipc	ra,0x0
    80002314:	c98080e7          	jalr	-872(ra) # 80001fa8 <myproc>
    80002318:	84aa                	mv	s1,a0
    sz = p->sz;
    8000231a:	652c                	ld	a1,72(a0)
    if (n > 0)
    8000231c:	01204c63          	bgtz	s2,80002334 <growproc+0x32>
    else if (n < 0)
    80002320:	02094663          	bltz	s2,8000234c <growproc+0x4a>
    p->sz = sz;
    80002324:	e4ac                	sd	a1,72(s1)
    return 0;
    80002326:	4501                	li	a0,0
}
    80002328:	60e2                	ld	ra,24(sp)
    8000232a:	6442                	ld	s0,16(sp)
    8000232c:	64a2                	ld	s1,8(sp)
    8000232e:	6902                	ld	s2,0(sp)
    80002330:	6105                	addi	sp,sp,32
    80002332:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002334:	4691                	li	a3,4
    80002336:	00b90633          	add	a2,s2,a1
    8000233a:	6928                	ld	a0,80(a0)
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	43c080e7          	jalr	1084(ra) # 80001778 <uvmalloc>
    80002344:	85aa                	mv	a1,a0
    80002346:	fd79                	bnez	a0,80002324 <growproc+0x22>
            return -1;
    80002348:	557d                	li	a0,-1
    8000234a:	bff9                	j	80002328 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000234c:	00b90633          	add	a2,s2,a1
    80002350:	6928                	ld	a0,80(a0)
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	3de080e7          	jalr	990(ra) # 80001730 <uvmdealloc>
    8000235a:	85aa                	mv	a1,a0
    8000235c:	b7e1                	j	80002324 <growproc+0x22>

000000008000235e <ps>:
{
    8000235e:	715d                	addi	sp,sp,-80
    80002360:	e486                	sd	ra,72(sp)
    80002362:	e0a2                	sd	s0,64(sp)
    80002364:	fc26                	sd	s1,56(sp)
    80002366:	f84a                	sd	s2,48(sp)
    80002368:	f44e                	sd	s3,40(sp)
    8000236a:	f052                	sd	s4,32(sp)
    8000236c:	ec56                	sd	s5,24(sp)
    8000236e:	e85a                	sd	s6,16(sp)
    80002370:	e45e                	sd	s7,8(sp)
    80002372:	e062                	sd	s8,0(sp)
    80002374:	0880                	addi	s0,sp,80
    80002376:	84aa                	mv	s1,a0
    80002378:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    8000237a:	00000097          	auipc	ra,0x0
    8000237e:	c2e080e7          	jalr	-978(ra) # 80001fa8 <myproc>
        return result;
    80002382:	4901                	li	s2,0
    if (count == 0)
    80002384:	0c0b8663          	beqz	s7,80002450 <ps+0xf2>
    void *result = (void *)myproc()->sz;
    80002388:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000238c:	003b951b          	slliw	a0,s7,0x3
    80002390:	0175053b          	addw	a0,a0,s7
    80002394:	0025151b          	slliw	a0,a0,0x2
    80002398:	2501                	sext.w	a0,a0
    8000239a:	00000097          	auipc	ra,0x0
    8000239e:	f68080e7          	jalr	-152(ra) # 80002302 <growproc>
    800023a2:	12054f63          	bltz	a0,800024e0 <ps+0x182>
    struct user_proc loc_result[count];
    800023a6:	003b9a13          	slli	s4,s7,0x3
    800023aa:	9a5e                	add	s4,s4,s7
    800023ac:	0a0a                	slli	s4,s4,0x2
    800023ae:	00fa0793          	addi	a5,s4,15
    800023b2:	8391                	srli	a5,a5,0x4
    800023b4:	0792                	slli	a5,a5,0x4
    800023b6:	40f10133          	sub	sp,sp,a5
    800023ba:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800023bc:	16800793          	li	a5,360
    800023c0:	02f484b3          	mul	s1,s1,a5
    800023c4:	0001a797          	auipc	a5,0x1a
    800023c8:	a3478793          	addi	a5,a5,-1484 # 8001bdf8 <proc>
    800023cc:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800023ce:	0001f797          	auipc	a5,0x1f
    800023d2:	42a78793          	addi	a5,a5,1066 # 800217f8 <tickslock>
        return result;
    800023d6:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800023d8:	06f4fc63          	bgeu	s1,a5,80002450 <ps+0xf2>
    acquire(&wait_lock);
    800023dc:	0001a517          	auipc	a0,0x1a
    800023e0:	a0450513          	addi	a0,a0,-1532 # 8001bde0 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	b52080e7          	jalr	-1198(ra) # 80000f36 <acquire>
        if (localCount == count)
    800023ec:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    800023f0:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    800023f2:	0001fc17          	auipc	s8,0x1f
    800023f6:	406c0c13          	addi	s8,s8,1030 # 800217f8 <tickslock>
    800023fa:	a851                	j	8000248e <ps+0x130>
            loc_result[localCount].state = UNUSED;
    800023fc:	00399793          	slli	a5,s3,0x3
    80002400:	97ce                	add	a5,a5,s3
    80002402:	078a                	slli	a5,a5,0x2
    80002404:	97d6                	add	a5,a5,s5
    80002406:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	bde080e7          	jalr	-1058(ra) # 80000fea <release>
    release(&wait_lock);
    80002414:	0001a517          	auipc	a0,0x1a
    80002418:	9cc50513          	addi	a0,a0,-1588 # 8001bde0 <wait_lock>
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	bce080e7          	jalr	-1074(ra) # 80000fea <release>
    if (localCount < count)
    80002424:	0179f963          	bgeu	s3,s7,80002436 <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002428:	00399793          	slli	a5,s3,0x3
    8000242c:	97ce                	add	a5,a5,s3
    8000242e:	078a                	slli	a5,a5,0x2
    80002430:	97d6                	add	a5,a5,s5
    80002432:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002436:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002438:	00000097          	auipc	ra,0x0
    8000243c:	b70080e7          	jalr	-1168(ra) # 80001fa8 <myproc>
    80002440:	86d2                	mv	a3,s4
    80002442:	8656                	mv	a2,s5
    80002444:	85da                	mv	a1,s6
    80002446:	6928                	ld	a0,80(a0)
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	59e080e7          	jalr	1438(ra) # 800019e6 <copyout>
}
    80002450:	854a                	mv	a0,s2
    80002452:	fb040113          	addi	sp,s0,-80
    80002456:	60a6                	ld	ra,72(sp)
    80002458:	6406                	ld	s0,64(sp)
    8000245a:	74e2                	ld	s1,56(sp)
    8000245c:	7942                	ld	s2,48(sp)
    8000245e:	79a2                	ld	s3,40(sp)
    80002460:	7a02                	ld	s4,32(sp)
    80002462:	6ae2                	ld	s5,24(sp)
    80002464:	6b42                	ld	s6,16(sp)
    80002466:	6ba2                	ld	s7,8(sp)
    80002468:	6c02                	ld	s8,0(sp)
    8000246a:	6161                	addi	sp,sp,80
    8000246c:	8082                	ret
        release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	b7a080e7          	jalr	-1158(ra) # 80000fea <release>
        localCount++;
    80002478:	2985                	addiw	s3,s3,1
    8000247a:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    8000247e:	16848493          	addi	s1,s1,360
    80002482:	f984f9e3          	bgeu	s1,s8,80002414 <ps+0xb6>
        if (localCount == count)
    80002486:	02490913          	addi	s2,s2,36
    8000248a:	053b8d63          	beq	s7,s3,800024e4 <ps+0x186>
        acquire(&p->lock);
    8000248e:	8526                	mv	a0,s1
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	aa6080e7          	jalr	-1370(ra) # 80000f36 <acquire>
        if (p->state == UNUSED)
    80002498:	4c9c                	lw	a5,24(s1)
    8000249a:	d3ad                	beqz	a5,800023fc <ps+0x9e>
        loc_result[localCount].state = p->state;
    8000249c:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800024a0:	549c                	lw	a5,40(s1)
    800024a2:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800024a6:	54dc                	lw	a5,44(s1)
    800024a8:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800024ac:	589c                	lw	a5,48(s1)
    800024ae:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800024b2:	4641                	li	a2,16
    800024b4:	85ca                	mv	a1,s2
    800024b6:	15848513          	addi	a0,s1,344
    800024ba:	00000097          	auipc	ra,0x0
    800024be:	a9e080e7          	jalr	-1378(ra) # 80001f58 <copy_array>
        if (p->parent != 0) // init
    800024c2:	7c88                	ld	a0,56(s1)
    800024c4:	d54d                	beqz	a0,8000246e <ps+0x110>
            acquire(&p->parent->lock);
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	a70080e7          	jalr	-1424(ra) # 80000f36 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800024ce:	7c88                	ld	a0,56(s1)
    800024d0:	591c                	lw	a5,48(a0)
    800024d2:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	b14080e7          	jalr	-1260(ra) # 80000fea <release>
    800024de:	bf41                	j	8000246e <ps+0x110>
        return result;
    800024e0:	4901                	li	s2,0
    800024e2:	b7bd                	j	80002450 <ps+0xf2>
    release(&wait_lock);
    800024e4:	0001a517          	auipc	a0,0x1a
    800024e8:	8fc50513          	addi	a0,a0,-1796 # 8001bde0 <wait_lock>
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	afe080e7          	jalr	-1282(ra) # 80000fea <release>
    if (localCount < count)
    800024f4:	b789                	j	80002436 <ps+0xd8>

00000000800024f6 <fork>:
{
    800024f6:	7139                	addi	sp,sp,-64
    800024f8:	fc06                	sd	ra,56(sp)
    800024fa:	f822                	sd	s0,48(sp)
    800024fc:	f04a                	sd	s2,32(sp)
    800024fe:	e456                	sd	s5,8(sp)
    80002500:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002502:	00000097          	auipc	ra,0x0
    80002506:	aa6080e7          	jalr	-1370(ra) # 80001fa8 <myproc>
    8000250a:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    8000250c:	00000097          	auipc	ra,0x0
    80002510:	ca6080e7          	jalr	-858(ra) # 800021b2 <allocproc>
    80002514:	12050063          	beqz	a0,80002634 <fork+0x13e>
    80002518:	e852                	sd	s4,16(sp)
    8000251a:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000251c:	048ab603          	ld	a2,72(s5)
    80002520:	692c                	ld	a1,80(a0)
    80002522:	050ab503          	ld	a0,80(s5)
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	3b6080e7          	jalr	950(ra) # 800018dc <uvmcopy>
    8000252e:	04054a63          	bltz	a0,80002582 <fork+0x8c>
    80002532:	f426                	sd	s1,40(sp)
    80002534:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    80002536:	048ab783          	ld	a5,72(s5)
    8000253a:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    8000253e:	058ab683          	ld	a3,88(s5)
    80002542:	87b6                	mv	a5,a3
    80002544:	058a3703          	ld	a4,88(s4)
    80002548:	12068693          	addi	a3,a3,288
    8000254c:	0007b803          	ld	a6,0(a5)
    80002550:	6788                	ld	a0,8(a5)
    80002552:	6b8c                	ld	a1,16(a5)
    80002554:	6f90                	ld	a2,24(a5)
    80002556:	01073023          	sd	a6,0(a4)
    8000255a:	e708                	sd	a0,8(a4)
    8000255c:	eb0c                	sd	a1,16(a4)
    8000255e:	ef10                	sd	a2,24(a4)
    80002560:	02078793          	addi	a5,a5,32
    80002564:	02070713          	addi	a4,a4,32
    80002568:	fed792e3          	bne	a5,a3,8000254c <fork+0x56>
    np->trapframe->a0 = 0;
    8000256c:	058a3783          	ld	a5,88(s4)
    80002570:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002574:	0d0a8493          	addi	s1,s5,208
    80002578:	0d0a0913          	addi	s2,s4,208
    8000257c:	150a8993          	addi	s3,s5,336
    80002580:	a015                	j	800025a4 <fork+0xae>
        freeproc(np);
    80002582:	8552                	mv	a0,s4
    80002584:	00000097          	auipc	ra,0x0
    80002588:	bd6080e7          	jalr	-1066(ra) # 8000215a <freeproc>
        release(&np->lock);
    8000258c:	8552                	mv	a0,s4
    8000258e:	fffff097          	auipc	ra,0xfffff
    80002592:	a5c080e7          	jalr	-1444(ra) # 80000fea <release>
        return -1;
    80002596:	597d                	li	s2,-1
    80002598:	6a42                	ld	s4,16(sp)
    8000259a:	a071                	j	80002626 <fork+0x130>
    for (i = 0; i < NOFILE; i++)
    8000259c:	04a1                	addi	s1,s1,8
    8000259e:	0921                	addi	s2,s2,8
    800025a0:	01348b63          	beq	s1,s3,800025b6 <fork+0xc0>
        if (p->ofile[i])
    800025a4:	6088                	ld	a0,0(s1)
    800025a6:	d97d                	beqz	a0,8000259c <fork+0xa6>
            np->ofile[i] = filedup(p->ofile[i]);
    800025a8:	00003097          	auipc	ra,0x3
    800025ac:	9ae080e7          	jalr	-1618(ra) # 80004f56 <filedup>
    800025b0:	00a93023          	sd	a0,0(s2)
    800025b4:	b7e5                	j	8000259c <fork+0xa6>
    np->cwd = idup(p->cwd);
    800025b6:	150ab503          	ld	a0,336(s5)
    800025ba:	00002097          	auipc	ra,0x2
    800025be:	b18080e7          	jalr	-1256(ra) # 800040d2 <idup>
    800025c2:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800025c6:	4641                	li	a2,16
    800025c8:	158a8593          	addi	a1,s5,344
    800025cc:	158a0513          	addi	a0,s4,344
    800025d0:	fffff097          	auipc	ra,0xfffff
    800025d4:	ba4080e7          	jalr	-1116(ra) # 80001174 <safestrcpy>
    pid = np->pid;
    800025d8:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800025dc:	8552                	mv	a0,s4
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	a0c080e7          	jalr	-1524(ra) # 80000fea <release>
    acquire(&wait_lock);
    800025e6:	00019497          	auipc	s1,0x19
    800025ea:	7fa48493          	addi	s1,s1,2042 # 8001bde0 <wait_lock>
    800025ee:	8526                	mv	a0,s1
    800025f0:	fffff097          	auipc	ra,0xfffff
    800025f4:	946080e7          	jalr	-1722(ra) # 80000f36 <acquire>
    np->parent = p;
    800025f8:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    800025fc:	8526                	mv	a0,s1
    800025fe:	fffff097          	auipc	ra,0xfffff
    80002602:	9ec080e7          	jalr	-1556(ra) # 80000fea <release>
    acquire(&np->lock);
    80002606:	8552                	mv	a0,s4
    80002608:	fffff097          	auipc	ra,0xfffff
    8000260c:	92e080e7          	jalr	-1746(ra) # 80000f36 <acquire>
    np->state = RUNNABLE;
    80002610:	478d                	li	a5,3
    80002612:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002616:	8552                	mv	a0,s4
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	9d2080e7          	jalr	-1582(ra) # 80000fea <release>
    return pid;
    80002620:	74a2                	ld	s1,40(sp)
    80002622:	69e2                	ld	s3,24(sp)
    80002624:	6a42                	ld	s4,16(sp)
}
    80002626:	854a                	mv	a0,s2
    80002628:	70e2                	ld	ra,56(sp)
    8000262a:	7442                	ld	s0,48(sp)
    8000262c:	7902                	ld	s2,32(sp)
    8000262e:	6aa2                	ld	s5,8(sp)
    80002630:	6121                	addi	sp,sp,64
    80002632:	8082                	ret
        return -1;
    80002634:	597d                	li	s2,-1
    80002636:	bfc5                	j	80002626 <fork+0x130>

0000000080002638 <scheduler>:
{
    80002638:	1101                	addi	sp,sp,-32
    8000263a:	ec06                	sd	ra,24(sp)
    8000263c:	e822                	sd	s0,16(sp)
    8000263e:	e426                	sd	s1,8(sp)
    80002640:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002642:	00009497          	auipc	s1,0x9
    80002646:	02648493          	addi	s1,s1,38 # 8000b668 <sched_pointer>
    8000264a:	609c                	ld	a5,0(s1)
    8000264c:	9782                	jalr	a5
    while (1)
    8000264e:	bff5                	j	8000264a <scheduler+0x12>

0000000080002650 <sched>:
{
    80002650:	7179                	addi	sp,sp,-48
    80002652:	f406                	sd	ra,40(sp)
    80002654:	f022                	sd	s0,32(sp)
    80002656:	ec26                	sd	s1,24(sp)
    80002658:	e84a                	sd	s2,16(sp)
    8000265a:	e44e                	sd	s3,8(sp)
    8000265c:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000265e:	00000097          	auipc	ra,0x0
    80002662:	94a080e7          	jalr	-1718(ra) # 80001fa8 <myproc>
    80002666:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002668:	fffff097          	auipc	ra,0xfffff
    8000266c:	854080e7          	jalr	-1964(ra) # 80000ebc <holding>
    80002670:	c53d                	beqz	a0,800026de <sched+0x8e>
    80002672:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002674:	2781                	sext.w	a5,a5
    80002676:	079e                	slli	a5,a5,0x7
    80002678:	00019717          	auipc	a4,0x19
    8000267c:	35070713          	addi	a4,a4,848 # 8001b9c8 <cpus>
    80002680:	97ba                	add	a5,a5,a4
    80002682:	5fb8                	lw	a4,120(a5)
    80002684:	4785                	li	a5,1
    80002686:	06f71463          	bne	a4,a5,800026ee <sched+0x9e>
    if (p->state == RUNNING)
    8000268a:	4c98                	lw	a4,24(s1)
    8000268c:	4791                	li	a5,4
    8000268e:	06f70863          	beq	a4,a5,800026fe <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002692:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002696:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002698:	ebbd                	bnez	a5,8000270e <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    8000269a:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    8000269c:	00019917          	auipc	s2,0x19
    800026a0:	32c90913          	addi	s2,s2,812 # 8001b9c8 <cpus>
    800026a4:	2781                	sext.w	a5,a5
    800026a6:	079e                	slli	a5,a5,0x7
    800026a8:	97ca                	add	a5,a5,s2
    800026aa:	07c7a983          	lw	s3,124(a5)
    800026ae:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800026b0:	2581                	sext.w	a1,a1
    800026b2:	059e                	slli	a1,a1,0x7
    800026b4:	05a1                	addi	a1,a1,8
    800026b6:	95ca                	add	a1,a1,s2
    800026b8:	06048513          	addi	a0,s1,96
    800026bc:	00000097          	auipc	ra,0x0
    800026c0:	764080e7          	jalr	1892(ra) # 80002e20 <swtch>
    800026c4:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800026c6:	2781                	sext.w	a5,a5
    800026c8:	079e                	slli	a5,a5,0x7
    800026ca:	993e                	add	s2,s2,a5
    800026cc:	07392e23          	sw	s3,124(s2)
}
    800026d0:	70a2                	ld	ra,40(sp)
    800026d2:	7402                	ld	s0,32(sp)
    800026d4:	64e2                	ld	s1,24(sp)
    800026d6:	6942                	ld	s2,16(sp)
    800026d8:	69a2                	ld	s3,8(sp)
    800026da:	6145                	addi	sp,sp,48
    800026dc:	8082                	ret
        panic("sched p->lock");
    800026de:	00006517          	auipc	a0,0x6
    800026e2:	ba250513          	addi	a0,a0,-1118 # 80008280 <__func__.1+0x278>
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	e7a080e7          	jalr	-390(ra) # 80000560 <panic>
        panic("sched locks");
    800026ee:	00006517          	auipc	a0,0x6
    800026f2:	ba250513          	addi	a0,a0,-1118 # 80008290 <__func__.1+0x288>
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	e6a080e7          	jalr	-406(ra) # 80000560 <panic>
        panic("sched running");
    800026fe:	00006517          	auipc	a0,0x6
    80002702:	ba250513          	addi	a0,a0,-1118 # 800082a0 <__func__.1+0x298>
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	e5a080e7          	jalr	-422(ra) # 80000560 <panic>
        panic("sched interruptible");
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	ba250513          	addi	a0,a0,-1118 # 800082b0 <__func__.1+0x2a8>
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	e4a080e7          	jalr	-438(ra) # 80000560 <panic>

000000008000271e <yield>:
{
    8000271e:	1101                	addi	sp,sp,-32
    80002720:	ec06                	sd	ra,24(sp)
    80002722:	e822                	sd	s0,16(sp)
    80002724:	e426                	sd	s1,8(sp)
    80002726:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002728:	00000097          	auipc	ra,0x0
    8000272c:	880080e7          	jalr	-1920(ra) # 80001fa8 <myproc>
    80002730:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002732:	fffff097          	auipc	ra,0xfffff
    80002736:	804080e7          	jalr	-2044(ra) # 80000f36 <acquire>
    p->state = RUNNABLE;
    8000273a:	478d                	li	a5,3
    8000273c:	cc9c                	sw	a5,24(s1)
    sched();
    8000273e:	00000097          	auipc	ra,0x0
    80002742:	f12080e7          	jalr	-238(ra) # 80002650 <sched>
    release(&p->lock);
    80002746:	8526                	mv	a0,s1
    80002748:	fffff097          	auipc	ra,0xfffff
    8000274c:	8a2080e7          	jalr	-1886(ra) # 80000fea <release>
}
    80002750:	60e2                	ld	ra,24(sp)
    80002752:	6442                	ld	s0,16(sp)
    80002754:	64a2                	ld	s1,8(sp)
    80002756:	6105                	addi	sp,sp,32
    80002758:	8082                	ret

000000008000275a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000275a:	7179                	addi	sp,sp,-48
    8000275c:	f406                	sd	ra,40(sp)
    8000275e:	f022                	sd	s0,32(sp)
    80002760:	ec26                	sd	s1,24(sp)
    80002762:	e84a                	sd	s2,16(sp)
    80002764:	e44e                	sd	s3,8(sp)
    80002766:	1800                	addi	s0,sp,48
    80002768:	89aa                	mv	s3,a0
    8000276a:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000276c:	00000097          	auipc	ra,0x0
    80002770:	83c080e7          	jalr	-1988(ra) # 80001fa8 <myproc>
    80002774:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	7c0080e7          	jalr	1984(ra) # 80000f36 <acquire>
    release(lk);
    8000277e:	854a                	mv	a0,s2
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	86a080e7          	jalr	-1942(ra) # 80000fea <release>

    // Go to sleep.
    p->chan = chan;
    80002788:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    8000278c:	4789                	li	a5,2
    8000278e:	cc9c                	sw	a5,24(s1)

    sched();
    80002790:	00000097          	auipc	ra,0x0
    80002794:	ec0080e7          	jalr	-320(ra) # 80002650 <sched>

    // Tidy up.
    p->chan = 0;
    80002798:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    8000279c:	8526                	mv	a0,s1
    8000279e:	fffff097          	auipc	ra,0xfffff
    800027a2:	84c080e7          	jalr	-1972(ra) # 80000fea <release>
    acquire(lk);
    800027a6:	854a                	mv	a0,s2
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	78e080e7          	jalr	1934(ra) # 80000f36 <acquire>
}
    800027b0:	70a2                	ld	ra,40(sp)
    800027b2:	7402                	ld	s0,32(sp)
    800027b4:	64e2                	ld	s1,24(sp)
    800027b6:	6942                	ld	s2,16(sp)
    800027b8:	69a2                	ld	s3,8(sp)
    800027ba:	6145                	addi	sp,sp,48
    800027bc:	8082                	ret

00000000800027be <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800027be:	7139                	addi	sp,sp,-64
    800027c0:	fc06                	sd	ra,56(sp)
    800027c2:	f822                	sd	s0,48(sp)
    800027c4:	f426                	sd	s1,40(sp)
    800027c6:	f04a                	sd	s2,32(sp)
    800027c8:	ec4e                	sd	s3,24(sp)
    800027ca:	e852                	sd	s4,16(sp)
    800027cc:	e456                	sd	s5,8(sp)
    800027ce:	0080                	addi	s0,sp,64
    800027d0:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800027d2:	00019497          	auipc	s1,0x19
    800027d6:	62648493          	addi	s1,s1,1574 # 8001bdf8 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800027da:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800027dc:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800027de:	0001f917          	auipc	s2,0x1f
    800027e2:	01a90913          	addi	s2,s2,26 # 800217f8 <tickslock>
    800027e6:	a811                	j	800027fa <wakeup+0x3c>
            }
            release(&p->lock);
    800027e8:	8526                	mv	a0,s1
    800027ea:	fffff097          	auipc	ra,0xfffff
    800027ee:	800080e7          	jalr	-2048(ra) # 80000fea <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800027f2:	16848493          	addi	s1,s1,360
    800027f6:	03248663          	beq	s1,s2,80002822 <wakeup+0x64>
        if (p != myproc())
    800027fa:	fffff097          	auipc	ra,0xfffff
    800027fe:	7ae080e7          	jalr	1966(ra) # 80001fa8 <myproc>
    80002802:	fea488e3          	beq	s1,a0,800027f2 <wakeup+0x34>
            acquire(&p->lock);
    80002806:	8526                	mv	a0,s1
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	72e080e7          	jalr	1838(ra) # 80000f36 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002810:	4c9c                	lw	a5,24(s1)
    80002812:	fd379be3          	bne	a5,s3,800027e8 <wakeup+0x2a>
    80002816:	709c                	ld	a5,32(s1)
    80002818:	fd4798e3          	bne	a5,s4,800027e8 <wakeup+0x2a>
                p->state = RUNNABLE;
    8000281c:	0154ac23          	sw	s5,24(s1)
    80002820:	b7e1                	j	800027e8 <wakeup+0x2a>
        }
    }
}
    80002822:	70e2                	ld	ra,56(sp)
    80002824:	7442                	ld	s0,48(sp)
    80002826:	74a2                	ld	s1,40(sp)
    80002828:	7902                	ld	s2,32(sp)
    8000282a:	69e2                	ld	s3,24(sp)
    8000282c:	6a42                	ld	s4,16(sp)
    8000282e:	6aa2                	ld	s5,8(sp)
    80002830:	6121                	addi	sp,sp,64
    80002832:	8082                	ret

0000000080002834 <reparent>:
{
    80002834:	7179                	addi	sp,sp,-48
    80002836:	f406                	sd	ra,40(sp)
    80002838:	f022                	sd	s0,32(sp)
    8000283a:	ec26                	sd	s1,24(sp)
    8000283c:	e84a                	sd	s2,16(sp)
    8000283e:	e44e                	sd	s3,8(sp)
    80002840:	e052                	sd	s4,0(sp)
    80002842:	1800                	addi	s0,sp,48
    80002844:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002846:	00019497          	auipc	s1,0x19
    8000284a:	5b248493          	addi	s1,s1,1458 # 8001bdf8 <proc>
            pp->parent = initproc;
    8000284e:	00009a17          	auipc	s4,0x9
    80002852:	eeaa0a13          	addi	s4,s4,-278 # 8000b738 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002856:	0001f997          	auipc	s3,0x1f
    8000285a:	fa298993          	addi	s3,s3,-94 # 800217f8 <tickslock>
    8000285e:	a029                	j	80002868 <reparent+0x34>
    80002860:	16848493          	addi	s1,s1,360
    80002864:	01348d63          	beq	s1,s3,8000287e <reparent+0x4a>
        if (pp->parent == p)
    80002868:	7c9c                	ld	a5,56(s1)
    8000286a:	ff279be3          	bne	a5,s2,80002860 <reparent+0x2c>
            pp->parent = initproc;
    8000286e:	000a3503          	ld	a0,0(s4)
    80002872:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002874:	00000097          	auipc	ra,0x0
    80002878:	f4a080e7          	jalr	-182(ra) # 800027be <wakeup>
    8000287c:	b7d5                	j	80002860 <reparent+0x2c>
}
    8000287e:	70a2                	ld	ra,40(sp)
    80002880:	7402                	ld	s0,32(sp)
    80002882:	64e2                	ld	s1,24(sp)
    80002884:	6942                	ld	s2,16(sp)
    80002886:	69a2                	ld	s3,8(sp)
    80002888:	6a02                	ld	s4,0(sp)
    8000288a:	6145                	addi	sp,sp,48
    8000288c:	8082                	ret

000000008000288e <exit>:
{
    8000288e:	7179                	addi	sp,sp,-48
    80002890:	f406                	sd	ra,40(sp)
    80002892:	f022                	sd	s0,32(sp)
    80002894:	ec26                	sd	s1,24(sp)
    80002896:	e84a                	sd	s2,16(sp)
    80002898:	e44e                	sd	s3,8(sp)
    8000289a:	e052                	sd	s4,0(sp)
    8000289c:	1800                	addi	s0,sp,48
    8000289e:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800028a0:	fffff097          	auipc	ra,0xfffff
    800028a4:	708080e7          	jalr	1800(ra) # 80001fa8 <myproc>
    800028a8:	89aa                	mv	s3,a0
    if (p == initproc)
    800028aa:	00009797          	auipc	a5,0x9
    800028ae:	e8e7b783          	ld	a5,-370(a5) # 8000b738 <initproc>
    800028b2:	0d050493          	addi	s1,a0,208
    800028b6:	15050913          	addi	s2,a0,336
    800028ba:	02a79363          	bne	a5,a0,800028e0 <exit+0x52>
        panic("init exiting");
    800028be:	00006517          	auipc	a0,0x6
    800028c2:	a0a50513          	addi	a0,a0,-1526 # 800082c8 <__func__.1+0x2c0>
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	c9a080e7          	jalr	-870(ra) # 80000560 <panic>
            fileclose(f);
    800028ce:	00002097          	auipc	ra,0x2
    800028d2:	6da080e7          	jalr	1754(ra) # 80004fa8 <fileclose>
            p->ofile[fd] = 0;
    800028d6:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800028da:	04a1                	addi	s1,s1,8
    800028dc:	01248563          	beq	s1,s2,800028e6 <exit+0x58>
        if (p->ofile[fd])
    800028e0:	6088                	ld	a0,0(s1)
    800028e2:	f575                	bnez	a0,800028ce <exit+0x40>
    800028e4:	bfdd                	j	800028da <exit+0x4c>
    begin_op();
    800028e6:	00002097          	auipc	ra,0x2
    800028ea:	1f8080e7          	jalr	504(ra) # 80004ade <begin_op>
    iput(p->cwd);
    800028ee:	1509b503          	ld	a0,336(s3)
    800028f2:	00002097          	auipc	ra,0x2
    800028f6:	9dc080e7          	jalr	-1572(ra) # 800042ce <iput>
    end_op();
    800028fa:	00002097          	auipc	ra,0x2
    800028fe:	25e080e7          	jalr	606(ra) # 80004b58 <end_op>
    p->cwd = 0;
    80002902:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002906:	00019497          	auipc	s1,0x19
    8000290a:	4da48493          	addi	s1,s1,1242 # 8001bde0 <wait_lock>
    8000290e:	8526                	mv	a0,s1
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	626080e7          	jalr	1574(ra) # 80000f36 <acquire>
    reparent(p);
    80002918:	854e                	mv	a0,s3
    8000291a:	00000097          	auipc	ra,0x0
    8000291e:	f1a080e7          	jalr	-230(ra) # 80002834 <reparent>
    wakeup(p->parent);
    80002922:	0389b503          	ld	a0,56(s3)
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	e98080e7          	jalr	-360(ra) # 800027be <wakeup>
    acquire(&p->lock);
    8000292e:	854e                	mv	a0,s3
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	606080e7          	jalr	1542(ra) # 80000f36 <acquire>
    p->xstate = status;
    80002938:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    8000293c:	4795                	li	a5,5
    8000293e:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002942:	8526                	mv	a0,s1
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	6a6080e7          	jalr	1702(ra) # 80000fea <release>
    sched();
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	d04080e7          	jalr	-764(ra) # 80002650 <sched>
    panic("zombie exit");
    80002954:	00006517          	auipc	a0,0x6
    80002958:	98450513          	addi	a0,a0,-1660 # 800082d8 <__func__.1+0x2d0>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	c04080e7          	jalr	-1020(ra) # 80000560 <panic>

0000000080002964 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002964:	7179                	addi	sp,sp,-48
    80002966:	f406                	sd	ra,40(sp)
    80002968:	f022                	sd	s0,32(sp)
    8000296a:	ec26                	sd	s1,24(sp)
    8000296c:	e84a                	sd	s2,16(sp)
    8000296e:	e44e                	sd	s3,8(sp)
    80002970:	1800                	addi	s0,sp,48
    80002972:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002974:	00019497          	auipc	s1,0x19
    80002978:	48448493          	addi	s1,s1,1156 # 8001bdf8 <proc>
    8000297c:	0001f997          	auipc	s3,0x1f
    80002980:	e7c98993          	addi	s3,s3,-388 # 800217f8 <tickslock>
    {
        acquire(&p->lock);
    80002984:	8526                	mv	a0,s1
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	5b0080e7          	jalr	1456(ra) # 80000f36 <acquire>
        if (p->pid == pid)
    8000298e:	589c                	lw	a5,48(s1)
    80002990:	01278d63          	beq	a5,s2,800029aa <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002994:	8526                	mv	a0,s1
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	654080e7          	jalr	1620(ra) # 80000fea <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000299e:	16848493          	addi	s1,s1,360
    800029a2:	ff3491e3          	bne	s1,s3,80002984 <kill+0x20>
    }
    return -1;
    800029a6:	557d                	li	a0,-1
    800029a8:	a829                	j	800029c2 <kill+0x5e>
            p->killed = 1;
    800029aa:	4785                	li	a5,1
    800029ac:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800029ae:	4c98                	lw	a4,24(s1)
    800029b0:	4789                	li	a5,2
    800029b2:	00f70f63          	beq	a4,a5,800029d0 <kill+0x6c>
            release(&p->lock);
    800029b6:	8526                	mv	a0,s1
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	632080e7          	jalr	1586(ra) # 80000fea <release>
            return 0;
    800029c0:	4501                	li	a0,0
}
    800029c2:	70a2                	ld	ra,40(sp)
    800029c4:	7402                	ld	s0,32(sp)
    800029c6:	64e2                	ld	s1,24(sp)
    800029c8:	6942                	ld	s2,16(sp)
    800029ca:	69a2                	ld	s3,8(sp)
    800029cc:	6145                	addi	sp,sp,48
    800029ce:	8082                	ret
                p->state = RUNNABLE;
    800029d0:	478d                	li	a5,3
    800029d2:	cc9c                	sw	a5,24(s1)
    800029d4:	b7cd                	j	800029b6 <kill+0x52>

00000000800029d6 <setkilled>:

void setkilled(struct proc *p)
{
    800029d6:	1101                	addi	sp,sp,-32
    800029d8:	ec06                	sd	ra,24(sp)
    800029da:	e822                	sd	s0,16(sp)
    800029dc:	e426                	sd	s1,8(sp)
    800029de:	1000                	addi	s0,sp,32
    800029e0:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	554080e7          	jalr	1364(ra) # 80000f36 <acquire>
    p->killed = 1;
    800029ea:	4785                	li	a5,1
    800029ec:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800029ee:	8526                	mv	a0,s1
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	5fa080e7          	jalr	1530(ra) # 80000fea <release>
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret

0000000080002a02 <killed>:

int killed(struct proc *p)
{
    80002a02:	1101                	addi	sp,sp,-32
    80002a04:	ec06                	sd	ra,24(sp)
    80002a06:	e822                	sd	s0,16(sp)
    80002a08:	e426                	sd	s1,8(sp)
    80002a0a:	e04a                	sd	s2,0(sp)
    80002a0c:	1000                	addi	s0,sp,32
    80002a0e:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	526080e7          	jalr	1318(ra) # 80000f36 <acquire>
    k = p->killed;
    80002a18:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002a1c:	8526                	mv	a0,s1
    80002a1e:	ffffe097          	auipc	ra,0xffffe
    80002a22:	5cc080e7          	jalr	1484(ra) # 80000fea <release>
    return k;
}
    80002a26:	854a                	mv	a0,s2
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6902                	ld	s2,0(sp)
    80002a30:	6105                	addi	sp,sp,32
    80002a32:	8082                	ret

0000000080002a34 <wait>:
{
    80002a34:	715d                	addi	sp,sp,-80
    80002a36:	e486                	sd	ra,72(sp)
    80002a38:	e0a2                	sd	s0,64(sp)
    80002a3a:	fc26                	sd	s1,56(sp)
    80002a3c:	f84a                	sd	s2,48(sp)
    80002a3e:	f44e                	sd	s3,40(sp)
    80002a40:	f052                	sd	s4,32(sp)
    80002a42:	ec56                	sd	s5,24(sp)
    80002a44:	e85a                	sd	s6,16(sp)
    80002a46:	e45e                	sd	s7,8(sp)
    80002a48:	e062                	sd	s8,0(sp)
    80002a4a:	0880                	addi	s0,sp,80
    80002a4c:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002a4e:	fffff097          	auipc	ra,0xfffff
    80002a52:	55a080e7          	jalr	1370(ra) # 80001fa8 <myproc>
    80002a56:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002a58:	00019517          	auipc	a0,0x19
    80002a5c:	38850513          	addi	a0,a0,904 # 8001bde0 <wait_lock>
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	4d6080e7          	jalr	1238(ra) # 80000f36 <acquire>
        havekids = 0;
    80002a68:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002a6a:	4a15                	li	s4,5
                havekids = 1;
    80002a6c:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a6e:	0001f997          	auipc	s3,0x1f
    80002a72:	d8a98993          	addi	s3,s3,-630 # 800217f8 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002a76:	00019c17          	auipc	s8,0x19
    80002a7a:	36ac0c13          	addi	s8,s8,874 # 8001bde0 <wait_lock>
    80002a7e:	a0d1                	j	80002b42 <wait+0x10e>
                    pid = pp->pid;
    80002a80:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002a84:	000b0e63          	beqz	s6,80002aa0 <wait+0x6c>
    80002a88:	4691                	li	a3,4
    80002a8a:	02c48613          	addi	a2,s1,44
    80002a8e:	85da                	mv	a1,s6
    80002a90:	05093503          	ld	a0,80(s2)
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	f52080e7          	jalr	-174(ra) # 800019e6 <copyout>
    80002a9c:	04054163          	bltz	a0,80002ade <wait+0xaa>
                    freeproc(pp);
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	6b8080e7          	jalr	1720(ra) # 8000215a <freeproc>
                    release(&pp->lock);
    80002aaa:	8526                	mv	a0,s1
    80002aac:	ffffe097          	auipc	ra,0xffffe
    80002ab0:	53e080e7          	jalr	1342(ra) # 80000fea <release>
                    release(&wait_lock);
    80002ab4:	00019517          	auipc	a0,0x19
    80002ab8:	32c50513          	addi	a0,a0,812 # 8001bde0 <wait_lock>
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	52e080e7          	jalr	1326(ra) # 80000fea <release>
}
    80002ac4:	854e                	mv	a0,s3
    80002ac6:	60a6                	ld	ra,72(sp)
    80002ac8:	6406                	ld	s0,64(sp)
    80002aca:	74e2                	ld	s1,56(sp)
    80002acc:	7942                	ld	s2,48(sp)
    80002ace:	79a2                	ld	s3,40(sp)
    80002ad0:	7a02                	ld	s4,32(sp)
    80002ad2:	6ae2                	ld	s5,24(sp)
    80002ad4:	6b42                	ld	s6,16(sp)
    80002ad6:	6ba2                	ld	s7,8(sp)
    80002ad8:	6c02                	ld	s8,0(sp)
    80002ada:	6161                	addi	sp,sp,80
    80002adc:	8082                	ret
                        release(&pp->lock);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	50a080e7          	jalr	1290(ra) # 80000fea <release>
                        release(&wait_lock);
    80002ae8:	00019517          	auipc	a0,0x19
    80002aec:	2f850513          	addi	a0,a0,760 # 8001bde0 <wait_lock>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	4fa080e7          	jalr	1274(ra) # 80000fea <release>
                        return -1;
    80002af8:	59fd                	li	s3,-1
    80002afa:	b7e9                	j	80002ac4 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002afc:	16848493          	addi	s1,s1,360
    80002b00:	03348463          	beq	s1,s3,80002b28 <wait+0xf4>
            if (pp->parent == p)
    80002b04:	7c9c                	ld	a5,56(s1)
    80002b06:	ff279be3          	bne	a5,s2,80002afc <wait+0xc8>
                acquire(&pp->lock);
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	42a080e7          	jalr	1066(ra) # 80000f36 <acquire>
                if (pp->state == ZOMBIE)
    80002b14:	4c9c                	lw	a5,24(s1)
    80002b16:	f74785e3          	beq	a5,s4,80002a80 <wait+0x4c>
                release(&pp->lock);
    80002b1a:	8526                	mv	a0,s1
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	4ce080e7          	jalr	1230(ra) # 80000fea <release>
                havekids = 1;
    80002b24:	8756                	mv	a4,s5
    80002b26:	bfd9                	j	80002afc <wait+0xc8>
        if (!havekids || killed(p))
    80002b28:	c31d                	beqz	a4,80002b4e <wait+0x11a>
    80002b2a:	854a                	mv	a0,s2
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	ed6080e7          	jalr	-298(ra) # 80002a02 <killed>
    80002b34:	ed09                	bnez	a0,80002b4e <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002b36:	85e2                	mv	a1,s8
    80002b38:	854a                	mv	a0,s2
    80002b3a:	00000097          	auipc	ra,0x0
    80002b3e:	c20080e7          	jalr	-992(ra) # 8000275a <sleep>
        havekids = 0;
    80002b42:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b44:	00019497          	auipc	s1,0x19
    80002b48:	2b448493          	addi	s1,s1,692 # 8001bdf8 <proc>
    80002b4c:	bf65                	j	80002b04 <wait+0xd0>
            release(&wait_lock);
    80002b4e:	00019517          	auipc	a0,0x19
    80002b52:	29250513          	addi	a0,a0,658 # 8001bde0 <wait_lock>
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	494080e7          	jalr	1172(ra) # 80000fea <release>
            return -1;
    80002b5e:	59fd                	li	s3,-1
    80002b60:	b795                	j	80002ac4 <wait+0x90>

0000000080002b62 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b62:	7179                	addi	sp,sp,-48
    80002b64:	f406                	sd	ra,40(sp)
    80002b66:	f022                	sd	s0,32(sp)
    80002b68:	ec26                	sd	s1,24(sp)
    80002b6a:	e84a                	sd	s2,16(sp)
    80002b6c:	e44e                	sd	s3,8(sp)
    80002b6e:	e052                	sd	s4,0(sp)
    80002b70:	1800                	addi	s0,sp,48
    80002b72:	84aa                	mv	s1,a0
    80002b74:	892e                	mv	s2,a1
    80002b76:	89b2                	mv	s3,a2
    80002b78:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002b7a:	fffff097          	auipc	ra,0xfffff
    80002b7e:	42e080e7          	jalr	1070(ra) # 80001fa8 <myproc>
    if (user_dst)
    80002b82:	c08d                	beqz	s1,80002ba4 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002b84:	86d2                	mv	a3,s4
    80002b86:	864e                	mv	a2,s3
    80002b88:	85ca                	mv	a1,s2
    80002b8a:	6928                	ld	a0,80(a0)
    80002b8c:	fffff097          	auipc	ra,0xfffff
    80002b90:	e5a080e7          	jalr	-422(ra) # 800019e6 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002b94:	70a2                	ld	ra,40(sp)
    80002b96:	7402                	ld	s0,32(sp)
    80002b98:	64e2                	ld	s1,24(sp)
    80002b9a:	6942                	ld	s2,16(sp)
    80002b9c:	69a2                	ld	s3,8(sp)
    80002b9e:	6a02                	ld	s4,0(sp)
    80002ba0:	6145                	addi	sp,sp,48
    80002ba2:	8082                	ret
        memmove((char *)dst, src, len);
    80002ba4:	000a061b          	sext.w	a2,s4
    80002ba8:	85ce                	mv	a1,s3
    80002baa:	854a                	mv	a0,s2
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	4e2080e7          	jalr	1250(ra) # 8000108e <memmove>
        return 0;
    80002bb4:	8526                	mv	a0,s1
    80002bb6:	bff9                	j	80002b94 <either_copyout+0x32>

0000000080002bb8 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002bb8:	7179                	addi	sp,sp,-48
    80002bba:	f406                	sd	ra,40(sp)
    80002bbc:	f022                	sd	s0,32(sp)
    80002bbe:	ec26                	sd	s1,24(sp)
    80002bc0:	e84a                	sd	s2,16(sp)
    80002bc2:	e44e                	sd	s3,8(sp)
    80002bc4:	e052                	sd	s4,0(sp)
    80002bc6:	1800                	addi	s0,sp,48
    80002bc8:	892a                	mv	s2,a0
    80002bca:	84ae                	mv	s1,a1
    80002bcc:	89b2                	mv	s3,a2
    80002bce:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	3d8080e7          	jalr	984(ra) # 80001fa8 <myproc>
    if (user_src)
    80002bd8:	c08d                	beqz	s1,80002bfa <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002bda:	86d2                	mv	a3,s4
    80002bdc:	864e                	mv	a2,s3
    80002bde:	85ca                	mv	a1,s2
    80002be0:	6928                	ld	a0,80(a0)
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	e90080e7          	jalr	-368(ra) # 80001a72 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002bea:	70a2                	ld	ra,40(sp)
    80002bec:	7402                	ld	s0,32(sp)
    80002bee:	64e2                	ld	s1,24(sp)
    80002bf0:	6942                	ld	s2,16(sp)
    80002bf2:	69a2                	ld	s3,8(sp)
    80002bf4:	6a02                	ld	s4,0(sp)
    80002bf6:	6145                	addi	sp,sp,48
    80002bf8:	8082                	ret
        memmove(dst, (char *)src, len);
    80002bfa:	000a061b          	sext.w	a2,s4
    80002bfe:	85ce                	mv	a1,s3
    80002c00:	854a                	mv	a0,s2
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	48c080e7          	jalr	1164(ra) # 8000108e <memmove>
        return 0;
    80002c0a:	8526                	mv	a0,s1
    80002c0c:	bff9                	j	80002bea <either_copyin+0x32>

0000000080002c0e <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002c0e:	715d                	addi	sp,sp,-80
    80002c10:	e486                	sd	ra,72(sp)
    80002c12:	e0a2                	sd	s0,64(sp)
    80002c14:	fc26                	sd	s1,56(sp)
    80002c16:	f84a                	sd	s2,48(sp)
    80002c18:	f44e                	sd	s3,40(sp)
    80002c1a:	f052                	sd	s4,32(sp)
    80002c1c:	ec56                	sd	s5,24(sp)
    80002c1e:	e85a                	sd	s6,16(sp)
    80002c20:	e45e                	sd	s7,8(sp)
    80002c22:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002c24:	00005517          	auipc	a0,0x5
    80002c28:	3fc50513          	addi	a0,a0,1020 # 80008020 <__func__.1+0x18>
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	990080e7          	jalr	-1648(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002c34:	00019497          	auipc	s1,0x19
    80002c38:	31c48493          	addi	s1,s1,796 # 8001bf50 <proc+0x158>
    80002c3c:	0001f917          	auipc	s2,0x1f
    80002c40:	d1490913          	addi	s2,s2,-748 # 80021950 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c44:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002c46:	00005997          	auipc	s3,0x5
    80002c4a:	6a298993          	addi	s3,s3,1698 # 800082e8 <__func__.1+0x2e0>
        printf("%d <%s %s", p->pid, state, p->name);
    80002c4e:	00005a97          	auipc	s5,0x5
    80002c52:	6a2a8a93          	addi	s5,s5,1698 # 800082f0 <__func__.1+0x2e8>
        printf("\n");
    80002c56:	00005a17          	auipc	s4,0x5
    80002c5a:	3caa0a13          	addi	s4,s4,970 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c5e:	00006b97          	auipc	s7,0x6
    80002c62:	c8ab8b93          	addi	s7,s7,-886 # 800088e8 <states.0>
    80002c66:	a00d                	j	80002c88 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002c68:	ed86a583          	lw	a1,-296(a3)
    80002c6c:	8556                	mv	a0,s5
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	94e080e7          	jalr	-1714(ra) # 800005bc <printf>
        printf("\n");
    80002c76:	8552                	mv	a0,s4
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	944080e7          	jalr	-1724(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002c80:	16848493          	addi	s1,s1,360
    80002c84:	03248263          	beq	s1,s2,80002ca8 <procdump+0x9a>
        if (p->state == UNUSED)
    80002c88:	86a6                	mv	a3,s1
    80002c8a:	ec04a783          	lw	a5,-320(s1)
    80002c8e:	dbed                	beqz	a5,80002c80 <procdump+0x72>
            state = "???";
    80002c90:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c92:	fcfb6be3          	bltu	s6,a5,80002c68 <procdump+0x5a>
    80002c96:	02079713          	slli	a4,a5,0x20
    80002c9a:	01d75793          	srli	a5,a4,0x1d
    80002c9e:	97de                	add	a5,a5,s7
    80002ca0:	6390                	ld	a2,0(a5)
    80002ca2:	f279                	bnez	a2,80002c68 <procdump+0x5a>
            state = "???";
    80002ca4:	864e                	mv	a2,s3
    80002ca6:	b7c9                	j	80002c68 <procdump+0x5a>
    }
}
    80002ca8:	60a6                	ld	ra,72(sp)
    80002caa:	6406                	ld	s0,64(sp)
    80002cac:	74e2                	ld	s1,56(sp)
    80002cae:	7942                	ld	s2,48(sp)
    80002cb0:	79a2                	ld	s3,40(sp)
    80002cb2:	7a02                	ld	s4,32(sp)
    80002cb4:	6ae2                	ld	s5,24(sp)
    80002cb6:	6b42                	ld	s6,16(sp)
    80002cb8:	6ba2                	ld	s7,8(sp)
    80002cba:	6161                	addi	sp,sp,80
    80002cbc:	8082                	ret

0000000080002cbe <schedls>:

void schedls()
{
    80002cbe:	1141                	addi	sp,sp,-16
    80002cc0:	e406                	sd	ra,8(sp)
    80002cc2:	e022                	sd	s0,0(sp)
    80002cc4:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002cc6:	00005517          	auipc	a0,0x5
    80002cca:	63a50513          	addi	a0,a0,1594 # 80008300 <__func__.1+0x2f8>
    80002cce:	ffffe097          	auipc	ra,0xffffe
    80002cd2:	8ee080e7          	jalr	-1810(ra) # 800005bc <printf>
    printf("====================================\n");
    80002cd6:	00005517          	auipc	a0,0x5
    80002cda:	65250513          	addi	a0,a0,1618 # 80008328 <__func__.1+0x320>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	8de080e7          	jalr	-1826(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002ce6:	00009717          	auipc	a4,0x9
    80002cea:	9e273703          	ld	a4,-1566(a4) # 8000b6c8 <available_schedulers+0x10>
    80002cee:	00009797          	auipc	a5,0x9
    80002cf2:	97a7b783          	ld	a5,-1670(a5) # 8000b668 <sched_pointer>
    80002cf6:	04f70663          	beq	a4,a5,80002d42 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002cfa:	00005517          	auipc	a0,0x5
    80002cfe:	65e50513          	addi	a0,a0,1630 # 80008358 <__func__.1+0x350>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	8ba080e7          	jalr	-1862(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002d0a:	00009617          	auipc	a2,0x9
    80002d0e:	9c662603          	lw	a2,-1594(a2) # 8000b6d0 <available_schedulers+0x18>
    80002d12:	00009597          	auipc	a1,0x9
    80002d16:	9a658593          	addi	a1,a1,-1626 # 8000b6b8 <available_schedulers>
    80002d1a:	00005517          	auipc	a0,0x5
    80002d1e:	64650513          	addi	a0,a0,1606 # 80008360 <__func__.1+0x358>
    80002d22:	ffffe097          	auipc	ra,0xffffe
    80002d26:	89a080e7          	jalr	-1894(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002d2a:	00005517          	auipc	a0,0x5
    80002d2e:	63e50513          	addi	a0,a0,1598 # 80008368 <__func__.1+0x360>
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	88a080e7          	jalr	-1910(ra) # 800005bc <printf>
}
    80002d3a:	60a2                	ld	ra,8(sp)
    80002d3c:	6402                	ld	s0,0(sp)
    80002d3e:	0141                	addi	sp,sp,16
    80002d40:	8082                	ret
            printf("[*]\t");
    80002d42:	00005517          	auipc	a0,0x5
    80002d46:	60e50513          	addi	a0,a0,1550 # 80008350 <__func__.1+0x348>
    80002d4a:	ffffe097          	auipc	ra,0xffffe
    80002d4e:	872080e7          	jalr	-1934(ra) # 800005bc <printf>
    80002d52:	bf65                	j	80002d0a <schedls+0x4c>

0000000080002d54 <schedset>:

void schedset(int id)
{
    80002d54:	1141                	addi	sp,sp,-16
    80002d56:	e406                	sd	ra,8(sp)
    80002d58:	e022                	sd	s0,0(sp)
    80002d5a:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002d5c:	e90d                	bnez	a0,80002d8e <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002d5e:	00009797          	auipc	a5,0x9
    80002d62:	96a7b783          	ld	a5,-1686(a5) # 8000b6c8 <available_schedulers+0x10>
    80002d66:	00009717          	auipc	a4,0x9
    80002d6a:	90f73123          	sd	a5,-1790(a4) # 8000b668 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002d6e:	00009597          	auipc	a1,0x9
    80002d72:	94a58593          	addi	a1,a1,-1718 # 8000b6b8 <available_schedulers>
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	63250513          	addi	a0,a0,1586 # 800083a8 <__func__.1+0x3a0>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	83e080e7          	jalr	-1986(ra) # 800005bc <printf>
}
    80002d86:	60a2                	ld	ra,8(sp)
    80002d88:	6402                	ld	s0,0(sp)
    80002d8a:	0141                	addi	sp,sp,16
    80002d8c:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	5f250513          	addi	a0,a0,1522 # 80008380 <__func__.1+0x378>
    80002d96:	ffffe097          	auipc	ra,0xffffe
    80002d9a:	826080e7          	jalr	-2010(ra) # 800005bc <printf>
        return;
    80002d9e:	b7e5                	j	80002d86 <schedset+0x32>

0000000080002da0 <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    80002da0:	7139                	addi	sp,sp,-64
    80002da2:	fc06                	sd	ra,56(sp)
    80002da4:	f822                	sd	s0,48(sp)
    80002da6:	f426                	sd	s1,40(sp)
    80002da8:	f04a                	sd	s2,32(sp)
    80002daa:	ec4e                	sd	s3,24(sp)
    80002dac:	e852                	sd	s4,16(sp)
    80002dae:	e456                	sd	s5,8(sp)
    80002db0:	0080                	addi	s0,sp,64
    80002db2:	8aaa                	mv	s5,a0
    80002db4:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    80002db6:	00019497          	auipc	s1,0x19
    80002dba:	04248493          	addi	s1,s1,66 # 8001bdf8 <proc>
    80002dbe:	0001f997          	auipc	s3,0x1f
    80002dc2:	a3a98993          	addi	s3,s3,-1478 # 800217f8 <tickslock>
    80002dc6:	a831                	j	80002de2 <transvirtproc+0x42>
    {
        acquire(&p->lock);
        found = p->pid == pid && p->state != UNUSED; 
    80002dc8:	0184aa03          	lw	s4,24(s1)
        release(&p->lock);
    80002dcc:	8526                	mv	a0,s1
    80002dce:	ffffe097          	auipc	ra,0xffffe
    80002dd2:	21c080e7          	jalr	540(ra) # 80000fea <release>
        if (found) break;
    80002dd6:	020a1663          	bnez	s4,80002e02 <transvirtproc+0x62>
    for (p = proc; p < &proc[NPROC]; p++)
    80002dda:	16848493          	addi	s1,s1,360
    80002dde:	03348063          	beq	s1,s3,80002dfe <transvirtproc+0x5e>
        acquire(&p->lock);
    80002de2:	8526                	mv	a0,s1
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	152080e7          	jalr	338(ra) # 80000f36 <acquire>
        found = p->pid == pid && p->state != UNUSED; 
    80002dec:	589c                	lw	a5,48(s1)
    80002dee:	fd278de3          	beq	a5,s2,80002dc8 <transvirtproc+0x28>
        release(&p->lock);
    80002df2:	8526                	mv	a0,s1
    80002df4:	ffffe097          	auipc	ra,0xffffe
    80002df8:	1f6080e7          	jalr	502(ra) # 80000fea <release>
        if (found) break;
    80002dfc:	bff9                	j	80002dda <transvirtproc+0x3a>
    }
    if (!found) {
        return 0;
    80002dfe:	4501                	li	a0,0
    80002e00:	a039                	j	80002e0e <transvirtproc+0x6e>
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002e02:	68ac                	ld	a1,80(s1)
    80002e04:	8556                	mv	a0,s5
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	db6080e7          	jalr	-586(ra) # 80001bbc <transvirt>
}
    80002e0e:	70e2                	ld	ra,56(sp)
    80002e10:	7442                	ld	s0,48(sp)
    80002e12:	74a2                	ld	s1,40(sp)
    80002e14:	7902                	ld	s2,32(sp)
    80002e16:	69e2                	ld	s3,24(sp)
    80002e18:	6a42                	ld	s4,16(sp)
    80002e1a:	6aa2                	ld	s5,8(sp)
    80002e1c:	6121                	addi	sp,sp,64
    80002e1e:	8082                	ret

0000000080002e20 <swtch>:
    80002e20:	00153023          	sd	ra,0(a0)
    80002e24:	00253423          	sd	sp,8(a0)
    80002e28:	e900                	sd	s0,16(a0)
    80002e2a:	ed04                	sd	s1,24(a0)
    80002e2c:	03253023          	sd	s2,32(a0)
    80002e30:	03353423          	sd	s3,40(a0)
    80002e34:	03453823          	sd	s4,48(a0)
    80002e38:	03553c23          	sd	s5,56(a0)
    80002e3c:	05653023          	sd	s6,64(a0)
    80002e40:	05753423          	sd	s7,72(a0)
    80002e44:	05853823          	sd	s8,80(a0)
    80002e48:	05953c23          	sd	s9,88(a0)
    80002e4c:	07a53023          	sd	s10,96(a0)
    80002e50:	07b53423          	sd	s11,104(a0)
    80002e54:	0005b083          	ld	ra,0(a1)
    80002e58:	0085b103          	ld	sp,8(a1)
    80002e5c:	6980                	ld	s0,16(a1)
    80002e5e:	6d84                	ld	s1,24(a1)
    80002e60:	0205b903          	ld	s2,32(a1)
    80002e64:	0285b983          	ld	s3,40(a1)
    80002e68:	0305ba03          	ld	s4,48(a1)
    80002e6c:	0385ba83          	ld	s5,56(a1)
    80002e70:	0405bb03          	ld	s6,64(a1)
    80002e74:	0485bb83          	ld	s7,72(a1)
    80002e78:	0505bc03          	ld	s8,80(a1)
    80002e7c:	0585bc83          	ld	s9,88(a1)
    80002e80:	0605bd03          	ld	s10,96(a1)
    80002e84:	0685bd83          	ld	s11,104(a1)
    80002e88:	8082                	ret

0000000080002e8a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002e8a:	1141                	addi	sp,sp,-16
    80002e8c:	e406                	sd	ra,8(sp)
    80002e8e:	e022                	sd	s0,0(sp)
    80002e90:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e92:	00005597          	auipc	a1,0x5
    80002e96:	56e58593          	addi	a1,a1,1390 # 80008400 <__func__.1+0x3f8>
    80002e9a:	0001f517          	auipc	a0,0x1f
    80002e9e:	95e50513          	addi	a0,a0,-1698 # 800217f8 <tickslock>
    80002ea2:	ffffe097          	auipc	ra,0xffffe
    80002ea6:	004080e7          	jalr	4(ra) # 80000ea6 <initlock>
}
    80002eaa:	60a2                	ld	ra,8(sp)
    80002eac:	6402                	ld	s0,0(sp)
    80002eae:	0141                	addi	sp,sp,16
    80002eb0:	8082                	ret

0000000080002eb2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002eb2:	1141                	addi	sp,sp,-16
    80002eb4:	e422                	sd	s0,8(sp)
    80002eb6:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002eb8:	00003797          	auipc	a5,0x3
    80002ebc:	7f878793          	addi	a5,a5,2040 # 800066b0 <kernelvec>
    80002ec0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ec4:	6422                	ld	s0,8(sp)
    80002ec6:	0141                	addi	sp,sp,16
    80002ec8:	8082                	ret

0000000080002eca <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002eca:	1141                	addi	sp,sp,-16
    80002ecc:	e406                	sd	ra,8(sp)
    80002ece:	e022                	sd	s0,0(sp)
    80002ed0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ed2:	fffff097          	auipc	ra,0xfffff
    80002ed6:	0d6080e7          	jalr	214(ra) # 80001fa8 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002eda:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ede:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002ee0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ee4:	00004697          	auipc	a3,0x4
    80002ee8:	11c68693          	addi	a3,a3,284 # 80007000 <_trampoline>
    80002eec:	00004717          	auipc	a4,0x4
    80002ef0:	11470713          	addi	a4,a4,276 # 80007000 <_trampoline>
    80002ef4:	8f15                	sub	a4,a4,a3
    80002ef6:	040007b7          	lui	a5,0x4000
    80002efa:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002efc:	07b2                	slli	a5,a5,0xc
    80002efe:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002f00:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002f04:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002f06:	18002673          	csrr	a2,satp
    80002f0a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002f0c:	6d30                	ld	a2,88(a0)
    80002f0e:	6138                	ld	a4,64(a0)
    80002f10:	6585                	lui	a1,0x1
    80002f12:	972e                	add	a4,a4,a1
    80002f14:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002f16:	6d38                	ld	a4,88(a0)
    80002f18:	00000617          	auipc	a2,0x0
    80002f1c:	13860613          	addi	a2,a2,312 # 80003050 <usertrap>
    80002f20:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002f22:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002f24:	8612                	mv	a2,tp
    80002f26:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f28:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f2c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f30:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002f34:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002f38:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002f3a:	6f18                	ld	a4,24(a4)
    80002f3c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002f40:	6928                	ld	a0,80(a0)
    80002f42:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002f44:	00004717          	auipc	a4,0x4
    80002f48:	15870713          	addi	a4,a4,344 # 8000709c <userret>
    80002f4c:	8f15                	sub	a4,a4,a3
    80002f4e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002f50:	577d                	li	a4,-1
    80002f52:	177e                	slli	a4,a4,0x3f
    80002f54:	8d59                	or	a0,a0,a4
    80002f56:	9782                	jalr	a5
}
    80002f58:	60a2                	ld	ra,8(sp)
    80002f5a:	6402                	ld	s0,0(sp)
    80002f5c:	0141                	addi	sp,sp,16
    80002f5e:	8082                	ret

0000000080002f60 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002f60:	1101                	addi	sp,sp,-32
    80002f62:	ec06                	sd	ra,24(sp)
    80002f64:	e822                	sd	s0,16(sp)
    80002f66:	e426                	sd	s1,8(sp)
    80002f68:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002f6a:	0001f497          	auipc	s1,0x1f
    80002f6e:	88e48493          	addi	s1,s1,-1906 # 800217f8 <tickslock>
    80002f72:	8526                	mv	a0,s1
    80002f74:	ffffe097          	auipc	ra,0xffffe
    80002f78:	fc2080e7          	jalr	-62(ra) # 80000f36 <acquire>
  ticks++;
    80002f7c:	00008517          	auipc	a0,0x8
    80002f80:	7c450513          	addi	a0,a0,1988 # 8000b740 <ticks>
    80002f84:	411c                	lw	a5,0(a0)
    80002f86:	2785                	addiw	a5,a5,1
    80002f88:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	834080e7          	jalr	-1996(ra) # 800027be <wakeup>
  release(&tickslock);
    80002f92:	8526                	mv	a0,s1
    80002f94:	ffffe097          	auipc	ra,0xffffe
    80002f98:	056080e7          	jalr	86(ra) # 80000fea <release>
}
    80002f9c:	60e2                	ld	ra,24(sp)
    80002f9e:	6442                	ld	s0,16(sp)
    80002fa0:	64a2                	ld	s1,8(sp)
    80002fa2:	6105                	addi	sp,sp,32
    80002fa4:	8082                	ret

0000000080002fa6 <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80002fa6:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002faa:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002fac:	0a07d163          	bgez	a5,8000304e <devintr+0xa8>
{
    80002fb0:	1101                	addi	sp,sp,-32
    80002fb2:	ec06                	sd	ra,24(sp)
    80002fb4:	e822                	sd	s0,16(sp)
    80002fb6:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002fb8:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002fbc:	46a5                	li	a3,9
    80002fbe:	00d70c63          	beq	a4,a3,80002fd6 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002fc2:	577d                	li	a4,-1
    80002fc4:	177e                	slli	a4,a4,0x3f
    80002fc6:	0705                	addi	a4,a4,1
    return 0;
    80002fc8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002fca:	06e78163          	beq	a5,a4,8000302c <devintr+0x86>
  }
}
    80002fce:	60e2                	ld	ra,24(sp)
    80002fd0:	6442                	ld	s0,16(sp)
    80002fd2:	6105                	addi	sp,sp,32
    80002fd4:	8082                	ret
    80002fd6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002fd8:	00003097          	auipc	ra,0x3
    80002fdc:	7e4080e7          	jalr	2020(ra) # 800067bc <plic_claim>
    80002fe0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002fe2:	47a9                	li	a5,10
    80002fe4:	00f50963          	beq	a0,a5,80002ff6 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002fe8:	4785                	li	a5,1
    80002fea:	00f50b63          	beq	a0,a5,80003000 <devintr+0x5a>
    return 1;
    80002fee:	4505                	li	a0,1
    } else if(irq){
    80002ff0:	ec89                	bnez	s1,8000300a <devintr+0x64>
    80002ff2:	64a2                	ld	s1,8(sp)
    80002ff4:	bfe9                	j	80002fce <devintr+0x28>
      uartintr();
    80002ff6:	ffffe097          	auipc	ra,0xffffe
    80002ffa:	a16080e7          	jalr	-1514(ra) # 80000a0c <uartintr>
    if(irq)
    80002ffe:	a839                	j	8000301c <devintr+0x76>
      virtio_disk_intr();
    80003000:	00004097          	auipc	ra,0x4
    80003004:	ce6080e7          	jalr	-794(ra) # 80006ce6 <virtio_disk_intr>
    if(irq)
    80003008:	a811                	j	8000301c <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    8000300a:	85a6                	mv	a1,s1
    8000300c:	00005517          	auipc	a0,0x5
    80003010:	3fc50513          	addi	a0,a0,1020 # 80008408 <__func__.1+0x400>
    80003014:	ffffd097          	auipc	ra,0xffffd
    80003018:	5a8080e7          	jalr	1448(ra) # 800005bc <printf>
      plic_complete(irq);
    8000301c:	8526                	mv	a0,s1
    8000301e:	00003097          	auipc	ra,0x3
    80003022:	7c2080e7          	jalr	1986(ra) # 800067e0 <plic_complete>
    return 1;
    80003026:	4505                	li	a0,1
    80003028:	64a2                	ld	s1,8(sp)
    8000302a:	b755                	j	80002fce <devintr+0x28>
    if(cpuid() == 0){
    8000302c:	fffff097          	auipc	ra,0xfffff
    80003030:	f50080e7          	jalr	-176(ra) # 80001f7c <cpuid>
    80003034:	c901                	beqz	a0,80003044 <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    80003036:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000303a:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    8000303c:	14479073          	csrw	sip,a5
    return 2;
    80003040:	4509                	li	a0,2
    80003042:	b771                	j	80002fce <devintr+0x28>
      clockintr();
    80003044:	00000097          	auipc	ra,0x0
    80003048:	f1c080e7          	jalr	-228(ra) # 80002f60 <clockintr>
    8000304c:	b7ed                	j	80003036 <devintr+0x90>
}
    8000304e:	8082                	ret

0000000080003050 <usertrap>:
{
    80003050:	1101                	addi	sp,sp,-32
    80003052:	ec06                	sd	ra,24(sp)
    80003054:	e822                	sd	s0,16(sp)
    80003056:	e426                	sd	s1,8(sp)
    80003058:	e04a                	sd	s2,0(sp)
    8000305a:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000305c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003060:	1007f793          	andi	a5,a5,256
    80003064:	eba9                	bnez	a5,800030b6 <usertrap+0x66>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80003066:	00003797          	auipc	a5,0x3
    8000306a:	64a78793          	addi	a5,a5,1610 # 800066b0 <kernelvec>
    8000306e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	f36080e7          	jalr	-202(ra) # 80001fa8 <myproc>
    8000307a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000307c:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    8000307e:	14102773          	csrr	a4,sepc
    80003082:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80003084:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003088:	47a1                	li	a5,8
    8000308a:	02f70e63          	beq	a4,a5,800030c6 <usertrap+0x76>
    8000308e:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80003092:	47bd                	li	a5,15
    80003094:	08f70363          	beq	a4,a5,8000311a <usertrap+0xca>
  } else if((which_dev = devintr()) != 0){
    80003098:	00000097          	auipc	ra,0x0
    8000309c:	f0e080e7          	jalr	-242(ra) # 80002fa6 <devintr>
    800030a0:	892a                	mv	s2,a0
    800030a2:	12050663          	beqz	a0,800031ce <usertrap+0x17e>
  if(killed(p))
    800030a6:	8526                	mv	a0,s1
    800030a8:	00000097          	auipc	ra,0x0
    800030ac:	95a080e7          	jalr	-1702(ra) # 80002a02 <killed>
    800030b0:	16050263          	beqz	a0,80003214 <usertrap+0x1c4>
    800030b4:	aa99                	j	8000320a <usertrap+0x1ba>
    panic("usertrap: not from user mode");
    800030b6:	00005517          	auipc	a0,0x5
    800030ba:	37250513          	addi	a0,a0,882 # 80008428 <__func__.1+0x420>
    800030be:	ffffd097          	auipc	ra,0xffffd
    800030c2:	4a2080e7          	jalr	1186(ra) # 80000560 <panic>
    if(killed(p))
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	93c080e7          	jalr	-1732(ra) # 80002a02 <killed>
    800030ce:	e121                	bnez	a0,8000310e <usertrap+0xbe>
    p->trapframe->epc += 4;
    800030d0:	6cb8                	ld	a4,88(s1)
    800030d2:	6f1c                	ld	a5,24(a4)
    800030d4:	0791                	addi	a5,a5,4
    800030d6:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800030d8:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    800030dc:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    800030e0:	10079073          	csrw	sstatus,a5
    syscall();
    800030e4:	00000097          	auipc	ra,0x0
    800030e8:	38a080e7          	jalr	906(ra) # 8000346e <syscall>
  if(killed(p))
    800030ec:	8526                	mv	a0,s1
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	914080e7          	jalr	-1772(ra) # 80002a02 <killed>
    800030f6:	10051963          	bnez	a0,80003208 <usertrap+0x1b8>
  usertrapret();
    800030fa:	00000097          	auipc	ra,0x0
    800030fe:	dd0080e7          	jalr	-560(ra) # 80002eca <usertrapret>
}
    80003102:	60e2                	ld	ra,24(sp)
    80003104:	6442                	ld	s0,16(sp)
    80003106:	64a2                	ld	s1,8(sp)
    80003108:	6902                	ld	s2,0(sp)
    8000310a:	6105                	addi	sp,sp,32
    8000310c:	8082                	ret
      exit(-1);
    8000310e:	557d                	li	a0,-1
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	77e080e7          	jalr	1918(ra) # 8000288e <exit>
    80003118:	bf65                	j	800030d0 <usertrap+0x80>
    if(killed(p))
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	8e8080e7          	jalr	-1816(ra) # 80002a02 <killed>
    80003122:	e52d                	bnez	a0,8000318c <usertrap+0x13c>
    asm volatile("csrr %0, stval" : "=r"(x));
    80003124:	143025f3          	csrr	a1,stval
    pte_t *pte = walk(p->pagetable, va, 0);
    80003128:	4601                	li	a2,0
    8000312a:	77fd                	lui	a5,0xfffff
    8000312c:	8dfd                	and	a1,a1,a5
    8000312e:	68a8                	ld	a0,80(s1)
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	1de080e7          	jalr	478(ra) # 8000130e <walk>
    80003138:	892a                	mv	s2,a0
    if (!pte || !(*pte & PTE_V)) {
    8000313a:	c501                	beqz	a0,80003142 <usertrap+0xf2>
    8000313c:	611c                	ld	a5,0(a0)
    8000313e:	8b85                	andi	a5,a5,1
    80003140:	eb9d                	bnez	a5,80003176 <usertrap+0x126>
      printf("tried to write to page not mapped pid=%d", p->pid);
    80003142:	588c                	lw	a1,48(s1)
    80003144:	00005517          	auipc	a0,0x5
    80003148:	30450513          	addi	a0,a0,772 # 80008448 <__func__.1+0x440>
    8000314c:	ffffd097          	auipc	ra,0xffffd
    80003150:	470080e7          	jalr	1136(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003154:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80003158:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000315c:	00005517          	auipc	a0,0x5
    80003160:	31c50513          	addi	a0,a0,796 # 80008478 <__func__.1+0x470>
    80003164:	ffffd097          	auipc	ra,0xffffd
    80003168:	458080e7          	jalr	1112(ra) # 800005bc <printf>
      setkilled(p);
    8000316c:	8526                	mv	a0,s1
    8000316e:	00000097          	auipc	ra,0x0
    80003172:	868080e7          	jalr	-1944(ra) # 800029d6 <setkilled>
    int isCOW = PTE_COW & *pte;
    80003176:	00093783          	ld	a5,0(s2)
    if (isCOW)
    8000317a:	2007f793          	andi	a5,a5,512
    8000317e:	cf89                	beqz	a5,80003198 <usertrap+0x148>
      cow_triggered(pte);
    80003180:	854a                	mv	a0,s2
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	bfc080e7          	jalr	-1028(ra) # 80000d7e <cow_triggered>
    8000318a:	b78d                	j	800030ec <usertrap+0x9c>
      exit(-1);
    8000318c:	557d                	li	a0,-1
    8000318e:	fffff097          	auipc	ra,0xfffff
    80003192:	700080e7          	jalr	1792(ra) # 8000288e <exit>
    80003196:	b779                	j	80003124 <usertrap+0xd4>
      printf("illegal write pid=%d", p->pid);
    80003198:	588c                	lw	a1,48(s1)
    8000319a:	00005517          	auipc	a0,0x5
    8000319e:	2fe50513          	addi	a0,a0,766 # 80008498 <__func__.1+0x490>
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	41a080e7          	jalr	1050(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800031aa:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800031ae:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031b2:	00005517          	auipc	a0,0x5
    800031b6:	2c650513          	addi	a0,a0,710 # 80008478 <__func__.1+0x470>
    800031ba:	ffffd097          	auipc	ra,0xffffd
    800031be:	402080e7          	jalr	1026(ra) # 800005bc <printf>
      setkilled(p);
    800031c2:	8526                	mv	a0,s1
    800031c4:	00000097          	auipc	ra,0x0
    800031c8:	812080e7          	jalr	-2030(ra) # 800029d6 <setkilled>
    800031cc:	b705                	j	800030ec <usertrap+0x9c>
    asm volatile("csrr %0, scause" : "=r"(x));
    800031ce:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800031d2:	5890                	lw	a2,48(s1)
    800031d4:	00005517          	auipc	a0,0x5
    800031d8:	2dc50513          	addi	a0,a0,732 # 800084b0 <__func__.1+0x4a8>
    800031dc:	ffffd097          	auipc	ra,0xffffd
    800031e0:	3e0080e7          	jalr	992(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800031e4:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800031e8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031ec:	00005517          	auipc	a0,0x5
    800031f0:	28c50513          	addi	a0,a0,652 # 80008478 <__func__.1+0x470>
    800031f4:	ffffd097          	auipc	ra,0xffffd
    800031f8:	3c8080e7          	jalr	968(ra) # 800005bc <printf>
    setkilled(p);
    800031fc:	8526                	mv	a0,s1
    800031fe:	fffff097          	auipc	ra,0xfffff
    80003202:	7d8080e7          	jalr	2008(ra) # 800029d6 <setkilled>
    80003206:	b5dd                	j	800030ec <usertrap+0x9c>
  if(killed(p))
    80003208:	4901                	li	s2,0
    exit(-1);
    8000320a:	557d                	li	a0,-1
    8000320c:	fffff097          	auipc	ra,0xfffff
    80003210:	682080e7          	jalr	1666(ra) # 8000288e <exit>
  if(which_dev == 2)
    80003214:	4789                	li	a5,2
    80003216:	eef912e3          	bne	s2,a5,800030fa <usertrap+0xaa>
    yield();
    8000321a:	fffff097          	auipc	ra,0xfffff
    8000321e:	504080e7          	jalr	1284(ra) # 8000271e <yield>
    80003222:	bde1                	j	800030fa <usertrap+0xaa>

0000000080003224 <kerneltrap>:
{
    80003224:	7179                	addi	sp,sp,-48
    80003226:	f406                	sd	ra,40(sp)
    80003228:	f022                	sd	s0,32(sp)
    8000322a:	ec26                	sd	s1,24(sp)
    8000322c:	e84a                	sd	s2,16(sp)
    8000322e:	e44e                	sd	s3,8(sp)
    80003230:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003232:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003236:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    8000323a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000323e:	1004f793          	andi	a5,s1,256
    80003242:	cb85                	beqz	a5,80003272 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003244:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80003248:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000324a:	ef85                	bnez	a5,80003282 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000324c:	00000097          	auipc	ra,0x0
    80003250:	d5a080e7          	jalr	-678(ra) # 80002fa6 <devintr>
    80003254:	cd1d                	beqz	a0,80003292 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003256:	4789                	li	a5,2
    80003258:	06f50a63          	beq	a0,a5,800032cc <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    8000325c:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80003260:	10049073          	csrw	sstatus,s1
}
    80003264:	70a2                	ld	ra,40(sp)
    80003266:	7402                	ld	s0,32(sp)
    80003268:	64e2                	ld	s1,24(sp)
    8000326a:	6942                	ld	s2,16(sp)
    8000326c:	69a2                	ld	s3,8(sp)
    8000326e:	6145                	addi	sp,sp,48
    80003270:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003272:	00005517          	auipc	a0,0x5
    80003276:	26e50513          	addi	a0,a0,622 # 800084e0 <__func__.1+0x4d8>
    8000327a:	ffffd097          	auipc	ra,0xffffd
    8000327e:	2e6080e7          	jalr	742(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80003282:	00005517          	auipc	a0,0x5
    80003286:	28650513          	addi	a0,a0,646 # 80008508 <__func__.1+0x500>
    8000328a:	ffffd097          	auipc	ra,0xffffd
    8000328e:	2d6080e7          	jalr	726(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80003292:	85ce                	mv	a1,s3
    80003294:	00005517          	auipc	a0,0x5
    80003298:	29450513          	addi	a0,a0,660 # 80008528 <__func__.1+0x520>
    8000329c:	ffffd097          	auipc	ra,0xffffd
    800032a0:	320080e7          	jalr	800(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800032a4:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800032a8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032ac:	00005517          	auipc	a0,0x5
    800032b0:	28c50513          	addi	a0,a0,652 # 80008538 <__func__.1+0x530>
    800032b4:	ffffd097          	auipc	ra,0xffffd
    800032b8:	308080e7          	jalr	776(ra) # 800005bc <printf>
    panic("kerneltrap");
    800032bc:	00005517          	auipc	a0,0x5
    800032c0:	29450513          	addi	a0,a0,660 # 80008550 <__func__.1+0x548>
    800032c4:	ffffd097          	auipc	ra,0xffffd
    800032c8:	29c080e7          	jalr	668(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800032cc:	fffff097          	auipc	ra,0xfffff
    800032d0:	cdc080e7          	jalr	-804(ra) # 80001fa8 <myproc>
    800032d4:	d541                	beqz	a0,8000325c <kerneltrap+0x38>
    800032d6:	fffff097          	auipc	ra,0xfffff
    800032da:	cd2080e7          	jalr	-814(ra) # 80001fa8 <myproc>
    800032de:	4d18                	lw	a4,24(a0)
    800032e0:	4791                	li	a5,4
    800032e2:	f6f71de3          	bne	a4,a5,8000325c <kerneltrap+0x38>
    yield();
    800032e6:	fffff097          	auipc	ra,0xfffff
    800032ea:	438080e7          	jalr	1080(ra) # 8000271e <yield>
    800032ee:	b7bd                	j	8000325c <kerneltrap+0x38>

00000000800032f0 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	e426                	sd	s1,8(sp)
    800032f8:	1000                	addi	s0,sp,32
    800032fa:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    800032fc:	fffff097          	auipc	ra,0xfffff
    80003300:	cac080e7          	jalr	-852(ra) # 80001fa8 <myproc>
    switch (n)
    80003304:	4795                	li	a5,5
    80003306:	0497e163          	bltu	a5,s1,80003348 <argraw+0x58>
    8000330a:	048a                	slli	s1,s1,0x2
    8000330c:	00005717          	auipc	a4,0x5
    80003310:	60c70713          	addi	a4,a4,1548 # 80008918 <states.0+0x30>
    80003314:	94ba                	add	s1,s1,a4
    80003316:	409c                	lw	a5,0(s1)
    80003318:	97ba                	add	a5,a5,a4
    8000331a:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    8000331c:	6d3c                	ld	a5,88(a0)
    8000331e:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	64a2                	ld	s1,8(sp)
    80003326:	6105                	addi	sp,sp,32
    80003328:	8082                	ret
        return p->trapframe->a1;
    8000332a:	6d3c                	ld	a5,88(a0)
    8000332c:	7fa8                	ld	a0,120(a5)
    8000332e:	bfcd                	j	80003320 <argraw+0x30>
        return p->trapframe->a2;
    80003330:	6d3c                	ld	a5,88(a0)
    80003332:	63c8                	ld	a0,128(a5)
    80003334:	b7f5                	j	80003320 <argraw+0x30>
        return p->trapframe->a3;
    80003336:	6d3c                	ld	a5,88(a0)
    80003338:	67c8                	ld	a0,136(a5)
    8000333a:	b7dd                	j	80003320 <argraw+0x30>
        return p->trapframe->a4;
    8000333c:	6d3c                	ld	a5,88(a0)
    8000333e:	6bc8                	ld	a0,144(a5)
    80003340:	b7c5                	j	80003320 <argraw+0x30>
        return p->trapframe->a5;
    80003342:	6d3c                	ld	a5,88(a0)
    80003344:	6fc8                	ld	a0,152(a5)
    80003346:	bfe9                	j	80003320 <argraw+0x30>
    panic("argraw");
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	21850513          	addi	a0,a0,536 # 80008560 <__func__.1+0x558>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	210080e7          	jalr	528(ra) # 80000560 <panic>

0000000080003358 <fetchaddr>:
{
    80003358:	1101                	addi	sp,sp,-32
    8000335a:	ec06                	sd	ra,24(sp)
    8000335c:	e822                	sd	s0,16(sp)
    8000335e:	e426                	sd	s1,8(sp)
    80003360:	e04a                	sd	s2,0(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84aa                	mv	s1,a0
    80003366:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80003368:	fffff097          	auipc	ra,0xfffff
    8000336c:	c40080e7          	jalr	-960(ra) # 80001fa8 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003370:	653c                	ld	a5,72(a0)
    80003372:	02f4f863          	bgeu	s1,a5,800033a2 <fetchaddr+0x4a>
    80003376:	00848713          	addi	a4,s1,8
    8000337a:	02e7e663          	bltu	a5,a4,800033a6 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000337e:	46a1                	li	a3,8
    80003380:	8626                	mv	a2,s1
    80003382:	85ca                	mv	a1,s2
    80003384:	6928                	ld	a0,80(a0)
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	6ec080e7          	jalr	1772(ra) # 80001a72 <copyin>
    8000338e:	00a03533          	snez	a0,a0
    80003392:	40a00533          	neg	a0,a0
}
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	64a2                	ld	s1,8(sp)
    8000339c:	6902                	ld	s2,0(sp)
    8000339e:	6105                	addi	sp,sp,32
    800033a0:	8082                	ret
        return -1;
    800033a2:	557d                	li	a0,-1
    800033a4:	bfcd                	j	80003396 <fetchaddr+0x3e>
    800033a6:	557d                	li	a0,-1
    800033a8:	b7fd                	j	80003396 <fetchaddr+0x3e>

00000000800033aa <fetchstr>:
{
    800033aa:	7179                	addi	sp,sp,-48
    800033ac:	f406                	sd	ra,40(sp)
    800033ae:	f022                	sd	s0,32(sp)
    800033b0:	ec26                	sd	s1,24(sp)
    800033b2:	e84a                	sd	s2,16(sp)
    800033b4:	e44e                	sd	s3,8(sp)
    800033b6:	1800                	addi	s0,sp,48
    800033b8:	892a                	mv	s2,a0
    800033ba:	84ae                	mv	s1,a1
    800033bc:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    800033be:	fffff097          	auipc	ra,0xfffff
    800033c2:	bea080e7          	jalr	-1046(ra) # 80001fa8 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800033c6:	86ce                	mv	a3,s3
    800033c8:	864a                	mv	a2,s2
    800033ca:	85a6                	mv	a1,s1
    800033cc:	6928                	ld	a0,80(a0)
    800033ce:	ffffe097          	auipc	ra,0xffffe
    800033d2:	732080e7          	jalr	1842(ra) # 80001b00 <copyinstr>
    800033d6:	00054e63          	bltz	a0,800033f2 <fetchstr+0x48>
    return strlen(buf);
    800033da:	8526                	mv	a0,s1
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	dca080e7          	jalr	-566(ra) # 800011a6 <strlen>
}
    800033e4:	70a2                	ld	ra,40(sp)
    800033e6:	7402                	ld	s0,32(sp)
    800033e8:	64e2                	ld	s1,24(sp)
    800033ea:	6942                	ld	s2,16(sp)
    800033ec:	69a2                	ld	s3,8(sp)
    800033ee:	6145                	addi	sp,sp,48
    800033f0:	8082                	ret
        return -1;
    800033f2:	557d                	li	a0,-1
    800033f4:	bfc5                	j	800033e4 <fetchstr+0x3a>

00000000800033f6 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    800033f6:	1101                	addi	sp,sp,-32
    800033f8:	ec06                	sd	ra,24(sp)
    800033fa:	e822                	sd	s0,16(sp)
    800033fc:	e426                	sd	s1,8(sp)
    800033fe:	1000                	addi	s0,sp,32
    80003400:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003402:	00000097          	auipc	ra,0x0
    80003406:	eee080e7          	jalr	-274(ra) # 800032f0 <argraw>
    8000340a:	c088                	sw	a0,0(s1)
}
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	64a2                	ld	s1,8(sp)
    80003412:	6105                	addi	sp,sp,32
    80003414:	8082                	ret

0000000080003416 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003416:	1101                	addi	sp,sp,-32
    80003418:	ec06                	sd	ra,24(sp)
    8000341a:	e822                	sd	s0,16(sp)
    8000341c:	e426                	sd	s1,8(sp)
    8000341e:	1000                	addi	s0,sp,32
    80003420:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003422:	00000097          	auipc	ra,0x0
    80003426:	ece080e7          	jalr	-306(ra) # 800032f0 <argraw>
    8000342a:	e088                	sd	a0,0(s1)
}
    8000342c:	60e2                	ld	ra,24(sp)
    8000342e:	6442                	ld	s0,16(sp)
    80003430:	64a2                	ld	s1,8(sp)
    80003432:	6105                	addi	sp,sp,32
    80003434:	8082                	ret

0000000080003436 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003436:	7179                	addi	sp,sp,-48
    80003438:	f406                	sd	ra,40(sp)
    8000343a:	f022                	sd	s0,32(sp)
    8000343c:	ec26                	sd	s1,24(sp)
    8000343e:	e84a                	sd	s2,16(sp)
    80003440:	1800                	addi	s0,sp,48
    80003442:	84ae                	mv	s1,a1
    80003444:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80003446:	fd840593          	addi	a1,s0,-40
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	fcc080e7          	jalr	-52(ra) # 80003416 <argaddr>
    return fetchstr(addr, buf, max);
    80003452:	864a                	mv	a2,s2
    80003454:	85a6                	mv	a1,s1
    80003456:	fd843503          	ld	a0,-40(s0)
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	f50080e7          	jalr	-176(ra) # 800033aa <fetchstr>
}
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6942                	ld	s2,16(sp)
    8000346a:	6145                	addi	sp,sp,48
    8000346c:	8082                	ret

000000008000346e <syscall>:
    [SYS_va2pa] sys_va2pa,
    [SYS_mmap] sys_mmap,
};

void syscall(void)
{
    8000346e:	1101                	addi	sp,sp,-32
    80003470:	ec06                	sd	ra,24(sp)
    80003472:	e822                	sd	s0,16(sp)
    80003474:	e426                	sd	s1,8(sp)
    80003476:	e04a                	sd	s2,0(sp)
    80003478:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    8000347a:	fffff097          	auipc	ra,0xfffff
    8000347e:	b2e080e7          	jalr	-1234(ra) # 80001fa8 <myproc>
    80003482:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003484:	05853903          	ld	s2,88(a0)
    80003488:	0a893783          	ld	a5,168(s2)
    8000348c:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003490:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffd2427>
    80003492:	4769                	li	a4,26
    80003494:	00f76f63          	bltu	a4,a5,800034b2 <syscall+0x44>
    80003498:	00369713          	slli	a4,a3,0x3
    8000349c:	00005797          	auipc	a5,0x5
    800034a0:	49478793          	addi	a5,a5,1172 # 80008930 <syscalls>
    800034a4:	97ba                	add	a5,a5,a4
    800034a6:	639c                	ld	a5,0(a5)
    800034a8:	c789                	beqz	a5,800034b2 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800034aa:	9782                	jalr	a5
    800034ac:	06a93823          	sd	a0,112(s2)
    800034b0:	a839                	j	800034ce <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800034b2:	15848613          	addi	a2,s1,344
    800034b6:	588c                	lw	a1,48(s1)
    800034b8:	00005517          	auipc	a0,0x5
    800034bc:	0b050513          	addi	a0,a0,176 # 80008568 <__func__.1+0x560>
    800034c0:	ffffd097          	auipc	ra,0xffffd
    800034c4:	0fc080e7          	jalr	252(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    800034c8:	6cbc                	ld	a5,88(s1)
    800034ca:	577d                	li	a4,-1
    800034cc:	fbb8                	sd	a4,112(a5)
    }
}
    800034ce:	60e2                	ld	ra,24(sp)
    800034d0:	6442                	ld	s0,16(sp)
    800034d2:	64a2                	ld	s1,8(sp)
    800034d4:	6902                	ld	s2,0(sp)
    800034d6:	6105                	addi	sp,sp,32
    800034d8:	8082                	ret

00000000800034da <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    800034e2:	fec40593          	addi	a1,s0,-20
    800034e6:	4501                	li	a0,0
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	f0e080e7          	jalr	-242(ra) # 800033f6 <argint>
    exit(n);
    800034f0:	fec42503          	lw	a0,-20(s0)
    800034f4:	fffff097          	auipc	ra,0xfffff
    800034f8:	39a080e7          	jalr	922(ra) # 8000288e <exit>
    return 0; // not reached
}
    800034fc:	4501                	li	a0,0
    800034fe:	60e2                	ld	ra,24(sp)
    80003500:	6442                	ld	s0,16(sp)
    80003502:	6105                	addi	sp,sp,32
    80003504:	8082                	ret

0000000080003506 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003506:	1141                	addi	sp,sp,-16
    80003508:	e406                	sd	ra,8(sp)
    8000350a:	e022                	sd	s0,0(sp)
    8000350c:	0800                	addi	s0,sp,16
    return myproc()->pid;
    8000350e:	fffff097          	auipc	ra,0xfffff
    80003512:	a9a080e7          	jalr	-1382(ra) # 80001fa8 <myproc>
}
    80003516:	5908                	lw	a0,48(a0)
    80003518:	60a2                	ld	ra,8(sp)
    8000351a:	6402                	ld	s0,0(sp)
    8000351c:	0141                	addi	sp,sp,16
    8000351e:	8082                	ret

0000000080003520 <sys_fork>:

uint64
sys_fork(void)
{
    80003520:	1141                	addi	sp,sp,-16
    80003522:	e406                	sd	ra,8(sp)
    80003524:	e022                	sd	s0,0(sp)
    80003526:	0800                	addi	s0,sp,16
    return fork();
    80003528:	fffff097          	auipc	ra,0xfffff
    8000352c:	fce080e7          	jalr	-50(ra) # 800024f6 <fork>
}
    80003530:	60a2                	ld	ra,8(sp)
    80003532:	6402                	ld	s0,0(sp)
    80003534:	0141                	addi	sp,sp,16
    80003536:	8082                	ret

0000000080003538 <sys_wait>:

uint64
sys_wait(void)
{
    80003538:	1101                	addi	sp,sp,-32
    8000353a:	ec06                	sd	ra,24(sp)
    8000353c:	e822                	sd	s0,16(sp)
    8000353e:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003540:	fe840593          	addi	a1,s0,-24
    80003544:	4501                	li	a0,0
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	ed0080e7          	jalr	-304(ra) # 80003416 <argaddr>
    return wait(p);
    8000354e:	fe843503          	ld	a0,-24(s0)
    80003552:	fffff097          	auipc	ra,0xfffff
    80003556:	4e2080e7          	jalr	1250(ra) # 80002a34 <wait>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	6105                	addi	sp,sp,32
    80003560:	8082                	ret

0000000080003562 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003562:	7179                	addi	sp,sp,-48
    80003564:	f406                	sd	ra,40(sp)
    80003566:	f022                	sd	s0,32(sp)
    80003568:	ec26                	sd	s1,24(sp)
    8000356a:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    8000356c:	fdc40593          	addi	a1,s0,-36
    80003570:	4501                	li	a0,0
    80003572:	00000097          	auipc	ra,0x0
    80003576:	e84080e7          	jalr	-380(ra) # 800033f6 <argint>
    addr = myproc()->sz;
    8000357a:	fffff097          	auipc	ra,0xfffff
    8000357e:	a2e080e7          	jalr	-1490(ra) # 80001fa8 <myproc>
    80003582:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003584:	fdc42503          	lw	a0,-36(s0)
    80003588:	fffff097          	auipc	ra,0xfffff
    8000358c:	d7a080e7          	jalr	-646(ra) # 80002302 <growproc>
    80003590:	00054863          	bltz	a0,800035a0 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003594:	8526                	mv	a0,s1
    80003596:	70a2                	ld	ra,40(sp)
    80003598:	7402                	ld	s0,32(sp)
    8000359a:	64e2                	ld	s1,24(sp)
    8000359c:	6145                	addi	sp,sp,48
    8000359e:	8082                	ret
        return -1;
    800035a0:	54fd                	li	s1,-1
    800035a2:	bfcd                	j	80003594 <sys_sbrk+0x32>

00000000800035a4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800035a4:	7139                	addi	sp,sp,-64
    800035a6:	fc06                	sd	ra,56(sp)
    800035a8:	f822                	sd	s0,48(sp)
    800035aa:	f04a                	sd	s2,32(sp)
    800035ac:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800035ae:	fcc40593          	addi	a1,s0,-52
    800035b2:	4501                	li	a0,0
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	e42080e7          	jalr	-446(ra) # 800033f6 <argint>
    acquire(&tickslock);
    800035bc:	0001e517          	auipc	a0,0x1e
    800035c0:	23c50513          	addi	a0,a0,572 # 800217f8 <tickslock>
    800035c4:	ffffe097          	auipc	ra,0xffffe
    800035c8:	972080e7          	jalr	-1678(ra) # 80000f36 <acquire>
    ticks0 = ticks;
    800035cc:	00008917          	auipc	s2,0x8
    800035d0:	17492903          	lw	s2,372(s2) # 8000b740 <ticks>
    while (ticks - ticks0 < n)
    800035d4:	fcc42783          	lw	a5,-52(s0)
    800035d8:	c3b9                	beqz	a5,8000361e <sys_sleep+0x7a>
    800035da:	f426                	sd	s1,40(sp)
    800035dc:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800035de:	0001e997          	auipc	s3,0x1e
    800035e2:	21a98993          	addi	s3,s3,538 # 800217f8 <tickslock>
    800035e6:	00008497          	auipc	s1,0x8
    800035ea:	15a48493          	addi	s1,s1,346 # 8000b740 <ticks>
        if (killed(myproc()))
    800035ee:	fffff097          	auipc	ra,0xfffff
    800035f2:	9ba080e7          	jalr	-1606(ra) # 80001fa8 <myproc>
    800035f6:	fffff097          	auipc	ra,0xfffff
    800035fa:	40c080e7          	jalr	1036(ra) # 80002a02 <killed>
    800035fe:	ed15                	bnez	a0,8000363a <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003600:	85ce                	mv	a1,s3
    80003602:	8526                	mv	a0,s1
    80003604:	fffff097          	auipc	ra,0xfffff
    80003608:	156080e7          	jalr	342(ra) # 8000275a <sleep>
    while (ticks - ticks0 < n)
    8000360c:	409c                	lw	a5,0(s1)
    8000360e:	412787bb          	subw	a5,a5,s2
    80003612:	fcc42703          	lw	a4,-52(s0)
    80003616:	fce7ece3          	bltu	a5,a4,800035ee <sys_sleep+0x4a>
    8000361a:	74a2                	ld	s1,40(sp)
    8000361c:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    8000361e:	0001e517          	auipc	a0,0x1e
    80003622:	1da50513          	addi	a0,a0,474 # 800217f8 <tickslock>
    80003626:	ffffe097          	auipc	ra,0xffffe
    8000362a:	9c4080e7          	jalr	-1596(ra) # 80000fea <release>
    return 0;
    8000362e:	4501                	li	a0,0
}
    80003630:	70e2                	ld	ra,56(sp)
    80003632:	7442                	ld	s0,48(sp)
    80003634:	7902                	ld	s2,32(sp)
    80003636:	6121                	addi	sp,sp,64
    80003638:	8082                	ret
            release(&tickslock);
    8000363a:	0001e517          	auipc	a0,0x1e
    8000363e:	1be50513          	addi	a0,a0,446 # 800217f8 <tickslock>
    80003642:	ffffe097          	auipc	ra,0xffffe
    80003646:	9a8080e7          	jalr	-1624(ra) # 80000fea <release>
            return -1;
    8000364a:	557d                	li	a0,-1
    8000364c:	74a2                	ld	s1,40(sp)
    8000364e:	69e2                	ld	s3,24(sp)
    80003650:	b7c5                	j	80003630 <sys_sleep+0x8c>

0000000080003652 <sys_kill>:

uint64
sys_kill(void)
{
    80003652:	1101                	addi	sp,sp,-32
    80003654:	ec06                	sd	ra,24(sp)
    80003656:	e822                	sd	s0,16(sp)
    80003658:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000365a:	fec40593          	addi	a1,s0,-20
    8000365e:	4501                	li	a0,0
    80003660:	00000097          	auipc	ra,0x0
    80003664:	d96080e7          	jalr	-618(ra) # 800033f6 <argint>
    return kill(pid);
    80003668:	fec42503          	lw	a0,-20(s0)
    8000366c:	fffff097          	auipc	ra,0xfffff
    80003670:	2f8080e7          	jalr	760(ra) # 80002964 <kill>
}
    80003674:	60e2                	ld	ra,24(sp)
    80003676:	6442                	ld	s0,16(sp)
    80003678:	6105                	addi	sp,sp,32
    8000367a:	8082                	ret

000000008000367c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000367c:	1101                	addi	sp,sp,-32
    8000367e:	ec06                	sd	ra,24(sp)
    80003680:	e822                	sd	s0,16(sp)
    80003682:	e426                	sd	s1,8(sp)
    80003684:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003686:	0001e517          	auipc	a0,0x1e
    8000368a:	17250513          	addi	a0,a0,370 # 800217f8 <tickslock>
    8000368e:	ffffe097          	auipc	ra,0xffffe
    80003692:	8a8080e7          	jalr	-1880(ra) # 80000f36 <acquire>
    xticks = ticks;
    80003696:	00008497          	auipc	s1,0x8
    8000369a:	0aa4a483          	lw	s1,170(s1) # 8000b740 <ticks>
    release(&tickslock);
    8000369e:	0001e517          	auipc	a0,0x1e
    800036a2:	15a50513          	addi	a0,a0,346 # 800217f8 <tickslock>
    800036a6:	ffffe097          	auipc	ra,0xffffe
    800036aa:	944080e7          	jalr	-1724(ra) # 80000fea <release>
    return xticks;
}
    800036ae:	02049513          	slli	a0,s1,0x20
    800036b2:	9101                	srli	a0,a0,0x20
    800036b4:	60e2                	ld	ra,24(sp)
    800036b6:	6442                	ld	s0,16(sp)
    800036b8:	64a2                	ld	s1,8(sp)
    800036ba:	6105                	addi	sp,sp,32
    800036bc:	8082                	ret

00000000800036be <sys_ps>:

void *
sys_ps(void)
{
    800036be:	1101                	addi	sp,sp,-32
    800036c0:	ec06                	sd	ra,24(sp)
    800036c2:	e822                	sd	s0,16(sp)
    800036c4:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800036c6:	fe042623          	sw	zero,-20(s0)
    800036ca:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800036ce:	fec40593          	addi	a1,s0,-20
    800036d2:	4501                	li	a0,0
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	d22080e7          	jalr	-734(ra) # 800033f6 <argint>
    argint(1, &count);
    800036dc:	fe840593          	addi	a1,s0,-24
    800036e0:	4505                	li	a0,1
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	d14080e7          	jalr	-748(ra) # 800033f6 <argint>
    return ps((uint8)start, (uint8)count);
    800036ea:	fe844583          	lbu	a1,-24(s0)
    800036ee:	fec44503          	lbu	a0,-20(s0)
    800036f2:	fffff097          	auipc	ra,0xfffff
    800036f6:	c6c080e7          	jalr	-916(ra) # 8000235e <ps>
}
    800036fa:	60e2                	ld	ra,24(sp)
    800036fc:	6442                	ld	s0,16(sp)
    800036fe:	6105                	addi	sp,sp,32
    80003700:	8082                	ret

0000000080003702 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003702:	1141                	addi	sp,sp,-16
    80003704:	e406                	sd	ra,8(sp)
    80003706:	e022                	sd	s0,0(sp)
    80003708:	0800                	addi	s0,sp,16
    schedls();
    8000370a:	fffff097          	auipc	ra,0xfffff
    8000370e:	5b4080e7          	jalr	1460(ra) # 80002cbe <schedls>
    return 0;
}
    80003712:	4501                	li	a0,0
    80003714:	60a2                	ld	ra,8(sp)
    80003716:	6402                	ld	s0,0(sp)
    80003718:	0141                	addi	sp,sp,16
    8000371a:	8082                	ret

000000008000371c <sys_schedset>:

uint64 sys_schedset(void)
{
    8000371c:	1101                	addi	sp,sp,-32
    8000371e:	ec06                	sd	ra,24(sp)
    80003720:	e822                	sd	s0,16(sp)
    80003722:	1000                	addi	s0,sp,32
    int id = 0;
    80003724:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003728:	fec40593          	addi	a1,s0,-20
    8000372c:	4501                	li	a0,0
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	cc8080e7          	jalr	-824(ra) # 800033f6 <argint>
    schedset(id - 1);
    80003736:	fec42503          	lw	a0,-20(s0)
    8000373a:	357d                	addiw	a0,a0,-1
    8000373c:	fffff097          	auipc	ra,0xfffff
    80003740:	618080e7          	jalr	1560(ra) # 80002d54 <schedset>
    return 0;
}
    80003744:	4501                	li	a0,0
    80003746:	60e2                	ld	ra,24(sp)
    80003748:	6442                	ld	s0,16(sp)
    8000374a:	6105                	addi	sp,sp,32
    8000374c:	8082                	ret

000000008000374e <sys_va2pa>:

uint64 sys_va2pa(void)
{
    8000374e:	7179                	addi	sp,sp,-48
    80003750:	f406                	sd	ra,40(sp)
    80003752:	f022                	sd	s0,32(sp)
    80003754:	1800                	addi	s0,sp,48
    int pid = 0;
    80003756:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    8000375a:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    8000375e:	fd040593          	addi	a1,s0,-48
    80003762:	4501                	li	a0,0
    80003764:	00000097          	auipc	ra,0x0
    80003768:	cb2080e7          	jalr	-846(ra) # 80003416 <argaddr>
    argint(1, &pid);
    8000376c:	fdc40593          	addi	a1,s0,-36
    80003770:	4505                	li	a0,1
    80003772:	00000097          	auipc	ra,0x0
    80003776:	c84080e7          	jalr	-892(ra) # 800033f6 <argint>
    if (pid == 0) {
    8000377a:	fdc42783          	lw	a5,-36(s0)
    8000377e:	cf89                	beqz	a5,80003798 <sys_va2pa+0x4a>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    80003780:	fdc42583          	lw	a1,-36(s0)
    80003784:	fd043503          	ld	a0,-48(s0)
    80003788:	fffff097          	auipc	ra,0xfffff
    8000378c:	618080e7          	jalr	1560(ra) # 80002da0 <transvirtproc>
}
    80003790:	70a2                	ld	ra,40(sp)
    80003792:	7402                	ld	s0,32(sp)
    80003794:	6145                	addi	sp,sp,48
    80003796:	8082                	ret
    80003798:	ec26                	sd	s1,24(sp)
	struct proc *p = myproc();
    8000379a:	fffff097          	auipc	ra,0xfffff
    8000379e:	80e080e7          	jalr	-2034(ra) # 80001fa8 <myproc>
    800037a2:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	792080e7          	jalr	1938(ra) # 80000f36 <acquire>
	pid = p->pid;
    800037ac:	589c                	lw	a5,48(s1)
    800037ae:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    800037b2:	8526                	mv	a0,s1
    800037b4:	ffffe097          	auipc	ra,0xffffe
    800037b8:	836080e7          	jalr	-1994(ra) # 80000fea <release>
    800037bc:	64e2                	ld	s1,24(sp)
    800037be:	b7c9                	j	80003780 <sys_va2pa+0x32>

00000000800037c0 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    800037c0:	1141                	addi	sp,sp,-16
    800037c2:	e406                	sd	ra,8(sp)
    800037c4:	e022                	sd	s0,0(sp)
    800037c6:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800037c8:	00008597          	auipc	a1,0x8
    800037cc:	f505b583          	ld	a1,-176(a1) # 8000b718 <FREE_PAGES>
    800037d0:	00005517          	auipc	a0,0x5
    800037d4:	db850513          	addi	a0,a0,-584 # 80008588 <__func__.1+0x580>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	de4080e7          	jalr	-540(ra) # 800005bc <printf>
    return 0;
}
    800037e0:	4501                	li	a0,0
    800037e2:	60a2                	ld	ra,8(sp)
    800037e4:	6402                	ld	s0,0(sp)
    800037e6:	0141                	addi	sp,sp,16
    800037e8:	8082                	ret

00000000800037ea <sys_mmap>:

uint64 sys_mmap(void)
{
    800037ea:	7179                	addi	sp,sp,-48
    800037ec:	f406                	sd	ra,40(sp)
    800037ee:	f022                	sd	s0,32(sp)
    800037f0:	ec26                	sd	s1,24(sp)
    800037f2:	e84a                	sd	s2,16(sp)
    800037f4:	1800                	addi	s0,sp,48
    uint64 vaddr;
    int npages;
    int protocol;
    argaddr(0, &vaddr);
    800037f6:	fd840593          	addi	a1,s0,-40
    800037fa:	4501                	li	a0,0
    800037fc:	00000097          	auipc	ra,0x0
    80003800:	c1a080e7          	jalr	-998(ra) # 80003416 <argaddr>
    argint(1, &npages);
    80003804:	fd440593          	addi	a1,s0,-44
    80003808:	4505                	li	a0,1
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	bec080e7          	jalr	-1044(ra) # 800033f6 <argint>
    argint(2, &protocol);
    80003812:	fd040593          	addi	a1,s0,-48
    80003816:	4509                	li	a0,2
    80003818:	00000097          	auipc	ra,0x0
    8000381c:	bde080e7          	jalr	-1058(ra) # 800033f6 <argint>
    return mmap_shared(vaddr, npages, myproc()->pagetable, protocol);
    80003820:	fd843483          	ld	s1,-40(s0)
    80003824:	fd442903          	lw	s2,-44(s0)
    80003828:	ffffe097          	auipc	ra,0xffffe
    8000382c:	780080e7          	jalr	1920(ra) # 80001fa8 <myproc>
    80003830:	fd042683          	lw	a3,-48(s0)
    80003834:	6930                	ld	a2,80(a0)
    80003836:	85ca                	mv	a1,s2
    80003838:	8526                	mv	a0,s1
    8000383a:	ffffe097          	auipc	ra,0xffffe
    8000383e:	3de080e7          	jalr	990(ra) # 80001c18 <mmap_shared>
}
    80003842:	70a2                	ld	ra,40(sp)
    80003844:	7402                	ld	s0,32(sp)
    80003846:	64e2                	ld	s1,24(sp)
    80003848:	6942                	ld	s2,16(sp)
    8000384a:	6145                	addi	sp,sp,48
    8000384c:	8082                	ret

000000008000384e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000384e:	7179                	addi	sp,sp,-48
    80003850:	f406                	sd	ra,40(sp)
    80003852:	f022                	sd	s0,32(sp)
    80003854:	ec26                	sd	s1,24(sp)
    80003856:	e84a                	sd	s2,16(sp)
    80003858:	e44e                	sd	s3,8(sp)
    8000385a:	e052                	sd	s4,0(sp)
    8000385c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000385e:	00005597          	auipc	a1,0x5
    80003862:	d3258593          	addi	a1,a1,-718 # 80008590 <__func__.1+0x588>
    80003866:	0001e517          	auipc	a0,0x1e
    8000386a:	faa50513          	addi	a0,a0,-86 # 80021810 <bcache>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	638080e7          	jalr	1592(ra) # 80000ea6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003876:	00026797          	auipc	a5,0x26
    8000387a:	f9a78793          	addi	a5,a5,-102 # 80029810 <bcache+0x8000>
    8000387e:	00026717          	auipc	a4,0x26
    80003882:	1fa70713          	addi	a4,a4,506 # 80029a78 <bcache+0x8268>
    80003886:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000388a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000388e:	0001e497          	auipc	s1,0x1e
    80003892:	f9a48493          	addi	s1,s1,-102 # 80021828 <bcache+0x18>
    b->next = bcache.head.next;
    80003896:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003898:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000389a:	00005a17          	auipc	s4,0x5
    8000389e:	cfea0a13          	addi	s4,s4,-770 # 80008598 <__func__.1+0x590>
    b->next = bcache.head.next;
    800038a2:	2b893783          	ld	a5,696(s2)
    800038a6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800038a8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800038ac:	85d2                	mv	a1,s4
    800038ae:	01048513          	addi	a0,s1,16
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	4e8080e7          	jalr	1256(ra) # 80004d9a <initsleeplock>
    bcache.head.next->prev = b;
    800038ba:	2b893783          	ld	a5,696(s2)
    800038be:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800038c0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800038c4:	45848493          	addi	s1,s1,1112
    800038c8:	fd349de3          	bne	s1,s3,800038a2 <binit+0x54>
  }
}
    800038cc:	70a2                	ld	ra,40(sp)
    800038ce:	7402                	ld	s0,32(sp)
    800038d0:	64e2                	ld	s1,24(sp)
    800038d2:	6942                	ld	s2,16(sp)
    800038d4:	69a2                	ld	s3,8(sp)
    800038d6:	6a02                	ld	s4,0(sp)
    800038d8:	6145                	addi	sp,sp,48
    800038da:	8082                	ret

00000000800038dc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800038dc:	7179                	addi	sp,sp,-48
    800038de:	f406                	sd	ra,40(sp)
    800038e0:	f022                	sd	s0,32(sp)
    800038e2:	ec26                	sd	s1,24(sp)
    800038e4:	e84a                	sd	s2,16(sp)
    800038e6:	e44e                	sd	s3,8(sp)
    800038e8:	1800                	addi	s0,sp,48
    800038ea:	892a                	mv	s2,a0
    800038ec:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800038ee:	0001e517          	auipc	a0,0x1e
    800038f2:	f2250513          	addi	a0,a0,-222 # 80021810 <bcache>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	640080e7          	jalr	1600(ra) # 80000f36 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800038fe:	00026497          	auipc	s1,0x26
    80003902:	1ca4b483          	ld	s1,458(s1) # 80029ac8 <bcache+0x82b8>
    80003906:	00026797          	auipc	a5,0x26
    8000390a:	17278793          	addi	a5,a5,370 # 80029a78 <bcache+0x8268>
    8000390e:	02f48f63          	beq	s1,a5,8000394c <bread+0x70>
    80003912:	873e                	mv	a4,a5
    80003914:	a021                	j	8000391c <bread+0x40>
    80003916:	68a4                	ld	s1,80(s1)
    80003918:	02e48a63          	beq	s1,a4,8000394c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000391c:	449c                	lw	a5,8(s1)
    8000391e:	ff279ce3          	bne	a5,s2,80003916 <bread+0x3a>
    80003922:	44dc                	lw	a5,12(s1)
    80003924:	ff3799e3          	bne	a5,s3,80003916 <bread+0x3a>
      b->refcnt++;
    80003928:	40bc                	lw	a5,64(s1)
    8000392a:	2785                	addiw	a5,a5,1
    8000392c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000392e:	0001e517          	auipc	a0,0x1e
    80003932:	ee250513          	addi	a0,a0,-286 # 80021810 <bcache>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	6b4080e7          	jalr	1716(ra) # 80000fea <release>
      acquiresleep(&b->lock);
    8000393e:	01048513          	addi	a0,s1,16
    80003942:	00001097          	auipc	ra,0x1
    80003946:	492080e7          	jalr	1170(ra) # 80004dd4 <acquiresleep>
      return b;
    8000394a:	a8b9                	j	800039a8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000394c:	00026497          	auipc	s1,0x26
    80003950:	1744b483          	ld	s1,372(s1) # 80029ac0 <bcache+0x82b0>
    80003954:	00026797          	auipc	a5,0x26
    80003958:	12478793          	addi	a5,a5,292 # 80029a78 <bcache+0x8268>
    8000395c:	00f48863          	beq	s1,a5,8000396c <bread+0x90>
    80003960:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003962:	40bc                	lw	a5,64(s1)
    80003964:	cf81                	beqz	a5,8000397c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003966:	64a4                	ld	s1,72(s1)
    80003968:	fee49de3          	bne	s1,a4,80003962 <bread+0x86>
  panic("bget: no buffers");
    8000396c:	00005517          	auipc	a0,0x5
    80003970:	c3450513          	addi	a0,a0,-972 # 800085a0 <__func__.1+0x598>
    80003974:	ffffd097          	auipc	ra,0xffffd
    80003978:	bec080e7          	jalr	-1044(ra) # 80000560 <panic>
      b->dev = dev;
    8000397c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003980:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003984:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003988:	4785                	li	a5,1
    8000398a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000398c:	0001e517          	auipc	a0,0x1e
    80003990:	e8450513          	addi	a0,a0,-380 # 80021810 <bcache>
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	656080e7          	jalr	1622(ra) # 80000fea <release>
      acquiresleep(&b->lock);
    8000399c:	01048513          	addi	a0,s1,16
    800039a0:	00001097          	auipc	ra,0x1
    800039a4:	434080e7          	jalr	1076(ra) # 80004dd4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800039a8:	409c                	lw	a5,0(s1)
    800039aa:	cb89                	beqz	a5,800039bc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800039ac:	8526                	mv	a0,s1
    800039ae:	70a2                	ld	ra,40(sp)
    800039b0:	7402                	ld	s0,32(sp)
    800039b2:	64e2                	ld	s1,24(sp)
    800039b4:	6942                	ld	s2,16(sp)
    800039b6:	69a2                	ld	s3,8(sp)
    800039b8:	6145                	addi	sp,sp,48
    800039ba:	8082                	ret
    virtio_disk_rw(b, 0);
    800039bc:	4581                	li	a1,0
    800039be:	8526                	mv	a0,s1
    800039c0:	00003097          	auipc	ra,0x3
    800039c4:	0f8080e7          	jalr	248(ra) # 80006ab8 <virtio_disk_rw>
    b->valid = 1;
    800039c8:	4785                	li	a5,1
    800039ca:	c09c                	sw	a5,0(s1)
  return b;
    800039cc:	b7c5                	j	800039ac <bread+0xd0>

00000000800039ce <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800039ce:	1101                	addi	sp,sp,-32
    800039d0:	ec06                	sd	ra,24(sp)
    800039d2:	e822                	sd	s0,16(sp)
    800039d4:	e426                	sd	s1,8(sp)
    800039d6:	1000                	addi	s0,sp,32
    800039d8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039da:	0541                	addi	a0,a0,16
    800039dc:	00001097          	auipc	ra,0x1
    800039e0:	492080e7          	jalr	1170(ra) # 80004e6e <holdingsleep>
    800039e4:	cd01                	beqz	a0,800039fc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800039e6:	4585                	li	a1,1
    800039e8:	8526                	mv	a0,s1
    800039ea:	00003097          	auipc	ra,0x3
    800039ee:	0ce080e7          	jalr	206(ra) # 80006ab8 <virtio_disk_rw>
}
    800039f2:	60e2                	ld	ra,24(sp)
    800039f4:	6442                	ld	s0,16(sp)
    800039f6:	64a2                	ld	s1,8(sp)
    800039f8:	6105                	addi	sp,sp,32
    800039fa:	8082                	ret
    panic("bwrite");
    800039fc:	00005517          	auipc	a0,0x5
    80003a00:	bbc50513          	addi	a0,a0,-1092 # 800085b8 <__func__.1+0x5b0>
    80003a04:	ffffd097          	auipc	ra,0xffffd
    80003a08:	b5c080e7          	jalr	-1188(ra) # 80000560 <panic>

0000000080003a0c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003a0c:	1101                	addi	sp,sp,-32
    80003a0e:	ec06                	sd	ra,24(sp)
    80003a10:	e822                	sd	s0,16(sp)
    80003a12:	e426                	sd	s1,8(sp)
    80003a14:	e04a                	sd	s2,0(sp)
    80003a16:	1000                	addi	s0,sp,32
    80003a18:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003a1a:	01050913          	addi	s2,a0,16
    80003a1e:	854a                	mv	a0,s2
    80003a20:	00001097          	auipc	ra,0x1
    80003a24:	44e080e7          	jalr	1102(ra) # 80004e6e <holdingsleep>
    80003a28:	c925                	beqz	a0,80003a98 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003a2a:	854a                	mv	a0,s2
    80003a2c:	00001097          	auipc	ra,0x1
    80003a30:	3fe080e7          	jalr	1022(ra) # 80004e2a <releasesleep>

  acquire(&bcache.lock);
    80003a34:	0001e517          	auipc	a0,0x1e
    80003a38:	ddc50513          	addi	a0,a0,-548 # 80021810 <bcache>
    80003a3c:	ffffd097          	auipc	ra,0xffffd
    80003a40:	4fa080e7          	jalr	1274(ra) # 80000f36 <acquire>
  b->refcnt--;
    80003a44:	40bc                	lw	a5,64(s1)
    80003a46:	37fd                	addiw	a5,a5,-1
    80003a48:	0007871b          	sext.w	a4,a5
    80003a4c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003a4e:	e71d                	bnez	a4,80003a7c <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003a50:	68b8                	ld	a4,80(s1)
    80003a52:	64bc                	ld	a5,72(s1)
    80003a54:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003a56:	68b8                	ld	a4,80(s1)
    80003a58:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a5a:	00026797          	auipc	a5,0x26
    80003a5e:	db678793          	addi	a5,a5,-586 # 80029810 <bcache+0x8000>
    80003a62:	2b87b703          	ld	a4,696(a5)
    80003a66:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a68:	00026717          	auipc	a4,0x26
    80003a6c:	01070713          	addi	a4,a4,16 # 80029a78 <bcache+0x8268>
    80003a70:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a72:	2b87b703          	ld	a4,696(a5)
    80003a76:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a78:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a7c:	0001e517          	auipc	a0,0x1e
    80003a80:	d9450513          	addi	a0,a0,-620 # 80021810 <bcache>
    80003a84:	ffffd097          	auipc	ra,0xffffd
    80003a88:	566080e7          	jalr	1382(ra) # 80000fea <release>
}
    80003a8c:	60e2                	ld	ra,24(sp)
    80003a8e:	6442                	ld	s0,16(sp)
    80003a90:	64a2                	ld	s1,8(sp)
    80003a92:	6902                	ld	s2,0(sp)
    80003a94:	6105                	addi	sp,sp,32
    80003a96:	8082                	ret
    panic("brelse");
    80003a98:	00005517          	auipc	a0,0x5
    80003a9c:	b2850513          	addi	a0,a0,-1240 # 800085c0 <__func__.1+0x5b8>
    80003aa0:	ffffd097          	auipc	ra,0xffffd
    80003aa4:	ac0080e7          	jalr	-1344(ra) # 80000560 <panic>

0000000080003aa8 <bpin>:

void
bpin(struct buf *b) {
    80003aa8:	1101                	addi	sp,sp,-32
    80003aaa:	ec06                	sd	ra,24(sp)
    80003aac:	e822                	sd	s0,16(sp)
    80003aae:	e426                	sd	s1,8(sp)
    80003ab0:	1000                	addi	s0,sp,32
    80003ab2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003ab4:	0001e517          	auipc	a0,0x1e
    80003ab8:	d5c50513          	addi	a0,a0,-676 # 80021810 <bcache>
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	47a080e7          	jalr	1146(ra) # 80000f36 <acquire>
  b->refcnt++;
    80003ac4:	40bc                	lw	a5,64(s1)
    80003ac6:	2785                	addiw	a5,a5,1
    80003ac8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003aca:	0001e517          	auipc	a0,0x1e
    80003ace:	d4650513          	addi	a0,a0,-698 # 80021810 <bcache>
    80003ad2:	ffffd097          	auipc	ra,0xffffd
    80003ad6:	518080e7          	jalr	1304(ra) # 80000fea <release>
}
    80003ada:	60e2                	ld	ra,24(sp)
    80003adc:	6442                	ld	s0,16(sp)
    80003ade:	64a2                	ld	s1,8(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret

0000000080003ae4 <bunpin>:

void
bunpin(struct buf *b) {
    80003ae4:	1101                	addi	sp,sp,-32
    80003ae6:	ec06                	sd	ra,24(sp)
    80003ae8:	e822                	sd	s0,16(sp)
    80003aea:	e426                	sd	s1,8(sp)
    80003aec:	1000                	addi	s0,sp,32
    80003aee:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003af0:	0001e517          	auipc	a0,0x1e
    80003af4:	d2050513          	addi	a0,a0,-736 # 80021810 <bcache>
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	43e080e7          	jalr	1086(ra) # 80000f36 <acquire>
  b->refcnt--;
    80003b00:	40bc                	lw	a5,64(s1)
    80003b02:	37fd                	addiw	a5,a5,-1
    80003b04:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003b06:	0001e517          	auipc	a0,0x1e
    80003b0a:	d0a50513          	addi	a0,a0,-758 # 80021810 <bcache>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	4dc080e7          	jalr	1244(ra) # 80000fea <release>
}
    80003b16:	60e2                	ld	ra,24(sp)
    80003b18:	6442                	ld	s0,16(sp)
    80003b1a:	64a2                	ld	s1,8(sp)
    80003b1c:	6105                	addi	sp,sp,32
    80003b1e:	8082                	ret

0000000080003b20 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003b20:	1101                	addi	sp,sp,-32
    80003b22:	ec06                	sd	ra,24(sp)
    80003b24:	e822                	sd	s0,16(sp)
    80003b26:	e426                	sd	s1,8(sp)
    80003b28:	e04a                	sd	s2,0(sp)
    80003b2a:	1000                	addi	s0,sp,32
    80003b2c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003b2e:	00d5d59b          	srliw	a1,a1,0xd
    80003b32:	00026797          	auipc	a5,0x26
    80003b36:	3ba7a783          	lw	a5,954(a5) # 80029eec <sb+0x1c>
    80003b3a:	9dbd                	addw	a1,a1,a5
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	da0080e7          	jalr	-608(ra) # 800038dc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003b44:	0074f713          	andi	a4,s1,7
    80003b48:	4785                	li	a5,1
    80003b4a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003b4e:	14ce                	slli	s1,s1,0x33
    80003b50:	90d9                	srli	s1,s1,0x36
    80003b52:	00950733          	add	a4,a0,s1
    80003b56:	05874703          	lbu	a4,88(a4)
    80003b5a:	00e7f6b3          	and	a3,a5,a4
    80003b5e:	c69d                	beqz	a3,80003b8c <bfree+0x6c>
    80003b60:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b62:	94aa                	add	s1,s1,a0
    80003b64:	fff7c793          	not	a5,a5
    80003b68:	8f7d                	and	a4,a4,a5
    80003b6a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003b6e:	00001097          	auipc	ra,0x1
    80003b72:	148080e7          	jalr	328(ra) # 80004cb6 <log_write>
  brelse(bp);
    80003b76:	854a                	mv	a0,s2
    80003b78:	00000097          	auipc	ra,0x0
    80003b7c:	e94080e7          	jalr	-364(ra) # 80003a0c <brelse>
}
    80003b80:	60e2                	ld	ra,24(sp)
    80003b82:	6442                	ld	s0,16(sp)
    80003b84:	64a2                	ld	s1,8(sp)
    80003b86:	6902                	ld	s2,0(sp)
    80003b88:	6105                	addi	sp,sp,32
    80003b8a:	8082                	ret
    panic("freeing free block");
    80003b8c:	00005517          	auipc	a0,0x5
    80003b90:	a3c50513          	addi	a0,a0,-1476 # 800085c8 <__func__.1+0x5c0>
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	9cc080e7          	jalr	-1588(ra) # 80000560 <panic>

0000000080003b9c <balloc>:
{
    80003b9c:	711d                	addi	sp,sp,-96
    80003b9e:	ec86                	sd	ra,88(sp)
    80003ba0:	e8a2                	sd	s0,80(sp)
    80003ba2:	e4a6                	sd	s1,72(sp)
    80003ba4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003ba6:	00026797          	auipc	a5,0x26
    80003baa:	32e7a783          	lw	a5,814(a5) # 80029ed4 <sb+0x4>
    80003bae:	10078f63          	beqz	a5,80003ccc <balloc+0x130>
    80003bb2:	e0ca                	sd	s2,64(sp)
    80003bb4:	fc4e                	sd	s3,56(sp)
    80003bb6:	f852                	sd	s4,48(sp)
    80003bb8:	f456                	sd	s5,40(sp)
    80003bba:	f05a                	sd	s6,32(sp)
    80003bbc:	ec5e                	sd	s7,24(sp)
    80003bbe:	e862                	sd	s8,16(sp)
    80003bc0:	e466                	sd	s9,8(sp)
    80003bc2:	8baa                	mv	s7,a0
    80003bc4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003bc6:	00026b17          	auipc	s6,0x26
    80003bca:	30ab0b13          	addi	s6,s6,778 # 80029ed0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bce:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003bd0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bd2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003bd4:	6c89                	lui	s9,0x2
    80003bd6:	a061                	j	80003c5e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003bd8:	97ca                	add	a5,a5,s2
    80003bda:	8e55                	or	a2,a2,a3
    80003bdc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003be0:	854a                	mv	a0,s2
    80003be2:	00001097          	auipc	ra,0x1
    80003be6:	0d4080e7          	jalr	212(ra) # 80004cb6 <log_write>
        brelse(bp);
    80003bea:	854a                	mv	a0,s2
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	e20080e7          	jalr	-480(ra) # 80003a0c <brelse>
  bp = bread(dev, bno);
    80003bf4:	85a6                	mv	a1,s1
    80003bf6:	855e                	mv	a0,s7
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	ce4080e7          	jalr	-796(ra) # 800038dc <bread>
    80003c00:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003c02:	40000613          	li	a2,1024
    80003c06:	4581                	li	a1,0
    80003c08:	05850513          	addi	a0,a0,88
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	426080e7          	jalr	1062(ra) # 80001032 <memset>
  log_write(bp);
    80003c14:	854a                	mv	a0,s2
    80003c16:	00001097          	auipc	ra,0x1
    80003c1a:	0a0080e7          	jalr	160(ra) # 80004cb6 <log_write>
  brelse(bp);
    80003c1e:	854a                	mv	a0,s2
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	dec080e7          	jalr	-532(ra) # 80003a0c <brelse>
}
    80003c28:	6906                	ld	s2,64(sp)
    80003c2a:	79e2                	ld	s3,56(sp)
    80003c2c:	7a42                	ld	s4,48(sp)
    80003c2e:	7aa2                	ld	s5,40(sp)
    80003c30:	7b02                	ld	s6,32(sp)
    80003c32:	6be2                	ld	s7,24(sp)
    80003c34:	6c42                	ld	s8,16(sp)
    80003c36:	6ca2                	ld	s9,8(sp)
}
    80003c38:	8526                	mv	a0,s1
    80003c3a:	60e6                	ld	ra,88(sp)
    80003c3c:	6446                	ld	s0,80(sp)
    80003c3e:	64a6                	ld	s1,72(sp)
    80003c40:	6125                	addi	sp,sp,96
    80003c42:	8082                	ret
    brelse(bp);
    80003c44:	854a                	mv	a0,s2
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	dc6080e7          	jalr	-570(ra) # 80003a0c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003c4e:	015c87bb          	addw	a5,s9,s5
    80003c52:	00078a9b          	sext.w	s5,a5
    80003c56:	004b2703          	lw	a4,4(s6)
    80003c5a:	06eaf163          	bgeu	s5,a4,80003cbc <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003c5e:	41fad79b          	sraiw	a5,s5,0x1f
    80003c62:	0137d79b          	srliw	a5,a5,0x13
    80003c66:	015787bb          	addw	a5,a5,s5
    80003c6a:	40d7d79b          	sraiw	a5,a5,0xd
    80003c6e:	01cb2583          	lw	a1,28(s6)
    80003c72:	9dbd                	addw	a1,a1,a5
    80003c74:	855e                	mv	a0,s7
    80003c76:	00000097          	auipc	ra,0x0
    80003c7a:	c66080e7          	jalr	-922(ra) # 800038dc <bread>
    80003c7e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c80:	004b2503          	lw	a0,4(s6)
    80003c84:	000a849b          	sext.w	s1,s5
    80003c88:	8762                	mv	a4,s8
    80003c8a:	faa4fde3          	bgeu	s1,a0,80003c44 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003c8e:	00777693          	andi	a3,a4,7
    80003c92:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003c96:	41f7579b          	sraiw	a5,a4,0x1f
    80003c9a:	01d7d79b          	srliw	a5,a5,0x1d
    80003c9e:	9fb9                	addw	a5,a5,a4
    80003ca0:	4037d79b          	sraiw	a5,a5,0x3
    80003ca4:	00f90633          	add	a2,s2,a5
    80003ca8:	05864603          	lbu	a2,88(a2)
    80003cac:	00c6f5b3          	and	a1,a3,a2
    80003cb0:	d585                	beqz	a1,80003bd8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003cb2:	2705                	addiw	a4,a4,1
    80003cb4:	2485                	addiw	s1,s1,1
    80003cb6:	fd471ae3          	bne	a4,s4,80003c8a <balloc+0xee>
    80003cba:	b769                	j	80003c44 <balloc+0xa8>
    80003cbc:	6906                	ld	s2,64(sp)
    80003cbe:	79e2                	ld	s3,56(sp)
    80003cc0:	7a42                	ld	s4,48(sp)
    80003cc2:	7aa2                	ld	s5,40(sp)
    80003cc4:	7b02                	ld	s6,32(sp)
    80003cc6:	6be2                	ld	s7,24(sp)
    80003cc8:	6c42                	ld	s8,16(sp)
    80003cca:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003ccc:	00005517          	auipc	a0,0x5
    80003cd0:	91450513          	addi	a0,a0,-1772 # 800085e0 <__func__.1+0x5d8>
    80003cd4:	ffffd097          	auipc	ra,0xffffd
    80003cd8:	8e8080e7          	jalr	-1816(ra) # 800005bc <printf>
  return 0;
    80003cdc:	4481                	li	s1,0
    80003cde:	bfa9                	j	80003c38 <balloc+0x9c>

0000000080003ce0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ce0:	7179                	addi	sp,sp,-48
    80003ce2:	f406                	sd	ra,40(sp)
    80003ce4:	f022                	sd	s0,32(sp)
    80003ce6:	ec26                	sd	s1,24(sp)
    80003ce8:	e84a                	sd	s2,16(sp)
    80003cea:	e44e                	sd	s3,8(sp)
    80003cec:	1800                	addi	s0,sp,48
    80003cee:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003cf0:	47ad                	li	a5,11
    80003cf2:	02b7e863          	bltu	a5,a1,80003d22 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003cf6:	02059793          	slli	a5,a1,0x20
    80003cfa:	01e7d593          	srli	a1,a5,0x1e
    80003cfe:	00b504b3          	add	s1,a0,a1
    80003d02:	0504a903          	lw	s2,80(s1)
    80003d06:	08091263          	bnez	s2,80003d8a <bmap+0xaa>
      addr = balloc(ip->dev);
    80003d0a:	4108                	lw	a0,0(a0)
    80003d0c:	00000097          	auipc	ra,0x0
    80003d10:	e90080e7          	jalr	-368(ra) # 80003b9c <balloc>
    80003d14:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003d18:	06090963          	beqz	s2,80003d8a <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003d1c:	0524a823          	sw	s2,80(s1)
    80003d20:	a0ad                	j	80003d8a <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003d22:	ff45849b          	addiw	s1,a1,-12
    80003d26:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003d2a:	0ff00793          	li	a5,255
    80003d2e:	08e7e863          	bltu	a5,a4,80003dbe <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003d32:	08052903          	lw	s2,128(a0)
    80003d36:	00091f63          	bnez	s2,80003d54 <bmap+0x74>
      addr = balloc(ip->dev);
    80003d3a:	4108                	lw	a0,0(a0)
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	e60080e7          	jalr	-416(ra) # 80003b9c <balloc>
    80003d44:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003d48:	04090163          	beqz	s2,80003d8a <bmap+0xaa>
    80003d4c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003d4e:	0929a023          	sw	s2,128(s3)
    80003d52:	a011                	j	80003d56 <bmap+0x76>
    80003d54:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003d56:	85ca                	mv	a1,s2
    80003d58:	0009a503          	lw	a0,0(s3)
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	b80080e7          	jalr	-1152(ra) # 800038dc <bread>
    80003d64:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003d66:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003d6a:	02049713          	slli	a4,s1,0x20
    80003d6e:	01e75593          	srli	a1,a4,0x1e
    80003d72:	00b784b3          	add	s1,a5,a1
    80003d76:	0004a903          	lw	s2,0(s1)
    80003d7a:	02090063          	beqz	s2,80003d9a <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003d7e:	8552                	mv	a0,s4
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	c8c080e7          	jalr	-884(ra) # 80003a0c <brelse>
    return addr;
    80003d88:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	70a2                	ld	ra,40(sp)
    80003d8e:	7402                	ld	s0,32(sp)
    80003d90:	64e2                	ld	s1,24(sp)
    80003d92:	6942                	ld	s2,16(sp)
    80003d94:	69a2                	ld	s3,8(sp)
    80003d96:	6145                	addi	sp,sp,48
    80003d98:	8082                	ret
      addr = balloc(ip->dev);
    80003d9a:	0009a503          	lw	a0,0(s3)
    80003d9e:	00000097          	auipc	ra,0x0
    80003da2:	dfe080e7          	jalr	-514(ra) # 80003b9c <balloc>
    80003da6:	0005091b          	sext.w	s2,a0
      if(addr){
    80003daa:	fc090ae3          	beqz	s2,80003d7e <bmap+0x9e>
        a[bn] = addr;
    80003dae:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003db2:	8552                	mv	a0,s4
    80003db4:	00001097          	auipc	ra,0x1
    80003db8:	f02080e7          	jalr	-254(ra) # 80004cb6 <log_write>
    80003dbc:	b7c9                	j	80003d7e <bmap+0x9e>
    80003dbe:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003dc0:	00005517          	auipc	a0,0x5
    80003dc4:	83850513          	addi	a0,a0,-1992 # 800085f8 <__func__.1+0x5f0>
    80003dc8:	ffffc097          	auipc	ra,0xffffc
    80003dcc:	798080e7          	jalr	1944(ra) # 80000560 <panic>

0000000080003dd0 <iget>:
{
    80003dd0:	7179                	addi	sp,sp,-48
    80003dd2:	f406                	sd	ra,40(sp)
    80003dd4:	f022                	sd	s0,32(sp)
    80003dd6:	ec26                	sd	s1,24(sp)
    80003dd8:	e84a                	sd	s2,16(sp)
    80003dda:	e44e                	sd	s3,8(sp)
    80003ddc:	e052                	sd	s4,0(sp)
    80003dde:	1800                	addi	s0,sp,48
    80003de0:	89aa                	mv	s3,a0
    80003de2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003de4:	00026517          	auipc	a0,0x26
    80003de8:	10c50513          	addi	a0,a0,268 # 80029ef0 <itable>
    80003dec:	ffffd097          	auipc	ra,0xffffd
    80003df0:	14a080e7          	jalr	330(ra) # 80000f36 <acquire>
  empty = 0;
    80003df4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003df6:	00026497          	auipc	s1,0x26
    80003dfa:	11248493          	addi	s1,s1,274 # 80029f08 <itable+0x18>
    80003dfe:	00028697          	auipc	a3,0x28
    80003e02:	b9a68693          	addi	a3,a3,-1126 # 8002b998 <log>
    80003e06:	a039                	j	80003e14 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e08:	02090b63          	beqz	s2,80003e3e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e0c:	08848493          	addi	s1,s1,136
    80003e10:	02d48a63          	beq	s1,a3,80003e44 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003e14:	449c                	lw	a5,8(s1)
    80003e16:	fef059e3          	blez	a5,80003e08 <iget+0x38>
    80003e1a:	4098                	lw	a4,0(s1)
    80003e1c:	ff3716e3          	bne	a4,s3,80003e08 <iget+0x38>
    80003e20:	40d8                	lw	a4,4(s1)
    80003e22:	ff4713e3          	bne	a4,s4,80003e08 <iget+0x38>
      ip->ref++;
    80003e26:	2785                	addiw	a5,a5,1
    80003e28:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003e2a:	00026517          	auipc	a0,0x26
    80003e2e:	0c650513          	addi	a0,a0,198 # 80029ef0 <itable>
    80003e32:	ffffd097          	auipc	ra,0xffffd
    80003e36:	1b8080e7          	jalr	440(ra) # 80000fea <release>
      return ip;
    80003e3a:	8926                	mv	s2,s1
    80003e3c:	a03d                	j	80003e6a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e3e:	f7f9                	bnez	a5,80003e0c <iget+0x3c>
      empty = ip;
    80003e40:	8926                	mv	s2,s1
    80003e42:	b7e9                	j	80003e0c <iget+0x3c>
  if(empty == 0)
    80003e44:	02090c63          	beqz	s2,80003e7c <iget+0xac>
  ip->dev = dev;
    80003e48:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003e4c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003e50:	4785                	li	a5,1
    80003e52:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003e56:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003e5a:	00026517          	auipc	a0,0x26
    80003e5e:	09650513          	addi	a0,a0,150 # 80029ef0 <itable>
    80003e62:	ffffd097          	auipc	ra,0xffffd
    80003e66:	188080e7          	jalr	392(ra) # 80000fea <release>
}
    80003e6a:	854a                	mv	a0,s2
    80003e6c:	70a2                	ld	ra,40(sp)
    80003e6e:	7402                	ld	s0,32(sp)
    80003e70:	64e2                	ld	s1,24(sp)
    80003e72:	6942                	ld	s2,16(sp)
    80003e74:	69a2                	ld	s3,8(sp)
    80003e76:	6a02                	ld	s4,0(sp)
    80003e78:	6145                	addi	sp,sp,48
    80003e7a:	8082                	ret
    panic("iget: no inodes");
    80003e7c:	00004517          	auipc	a0,0x4
    80003e80:	79450513          	addi	a0,a0,1940 # 80008610 <__func__.1+0x608>
    80003e84:	ffffc097          	auipc	ra,0xffffc
    80003e88:	6dc080e7          	jalr	1756(ra) # 80000560 <panic>

0000000080003e8c <fsinit>:
fsinit(int dev) {
    80003e8c:	7179                	addi	sp,sp,-48
    80003e8e:	f406                	sd	ra,40(sp)
    80003e90:	f022                	sd	s0,32(sp)
    80003e92:	ec26                	sd	s1,24(sp)
    80003e94:	e84a                	sd	s2,16(sp)
    80003e96:	e44e                	sd	s3,8(sp)
    80003e98:	1800                	addi	s0,sp,48
    80003e9a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003e9c:	4585                	li	a1,1
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	a3e080e7          	jalr	-1474(ra) # 800038dc <bread>
    80003ea6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ea8:	00026997          	auipc	s3,0x26
    80003eac:	02898993          	addi	s3,s3,40 # 80029ed0 <sb>
    80003eb0:	02000613          	li	a2,32
    80003eb4:	05850593          	addi	a1,a0,88
    80003eb8:	854e                	mv	a0,s3
    80003eba:	ffffd097          	auipc	ra,0xffffd
    80003ebe:	1d4080e7          	jalr	468(ra) # 8000108e <memmove>
  brelse(bp);
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	b48080e7          	jalr	-1208(ra) # 80003a0c <brelse>
  if(sb.magic != FSMAGIC)
    80003ecc:	0009a703          	lw	a4,0(s3)
    80003ed0:	102037b7          	lui	a5,0x10203
    80003ed4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ed8:	02f71263          	bne	a4,a5,80003efc <fsinit+0x70>
  initlog(dev, &sb);
    80003edc:	00026597          	auipc	a1,0x26
    80003ee0:	ff458593          	addi	a1,a1,-12 # 80029ed0 <sb>
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	00001097          	auipc	ra,0x1
    80003eea:	b60080e7          	jalr	-1184(ra) # 80004a46 <initlog>
}
    80003eee:	70a2                	ld	ra,40(sp)
    80003ef0:	7402                	ld	s0,32(sp)
    80003ef2:	64e2                	ld	s1,24(sp)
    80003ef4:	6942                	ld	s2,16(sp)
    80003ef6:	69a2                	ld	s3,8(sp)
    80003ef8:	6145                	addi	sp,sp,48
    80003efa:	8082                	ret
    panic("invalid file system");
    80003efc:	00004517          	auipc	a0,0x4
    80003f00:	72450513          	addi	a0,a0,1828 # 80008620 <__func__.1+0x618>
    80003f04:	ffffc097          	auipc	ra,0xffffc
    80003f08:	65c080e7          	jalr	1628(ra) # 80000560 <panic>

0000000080003f0c <iinit>:
{
    80003f0c:	7179                	addi	sp,sp,-48
    80003f0e:	f406                	sd	ra,40(sp)
    80003f10:	f022                	sd	s0,32(sp)
    80003f12:	ec26                	sd	s1,24(sp)
    80003f14:	e84a                	sd	s2,16(sp)
    80003f16:	e44e                	sd	s3,8(sp)
    80003f18:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003f1a:	00004597          	auipc	a1,0x4
    80003f1e:	71e58593          	addi	a1,a1,1822 # 80008638 <__func__.1+0x630>
    80003f22:	00026517          	auipc	a0,0x26
    80003f26:	fce50513          	addi	a0,a0,-50 # 80029ef0 <itable>
    80003f2a:	ffffd097          	auipc	ra,0xffffd
    80003f2e:	f7c080e7          	jalr	-132(ra) # 80000ea6 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003f32:	00026497          	auipc	s1,0x26
    80003f36:	fe648493          	addi	s1,s1,-26 # 80029f18 <itable+0x28>
    80003f3a:	00028997          	auipc	s3,0x28
    80003f3e:	a6e98993          	addi	s3,s3,-1426 # 8002b9a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003f42:	00004917          	auipc	s2,0x4
    80003f46:	6fe90913          	addi	s2,s2,1790 # 80008640 <__func__.1+0x638>
    80003f4a:	85ca                	mv	a1,s2
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	00001097          	auipc	ra,0x1
    80003f52:	e4c080e7          	jalr	-436(ra) # 80004d9a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003f56:	08848493          	addi	s1,s1,136
    80003f5a:	ff3498e3          	bne	s1,s3,80003f4a <iinit+0x3e>
}
    80003f5e:	70a2                	ld	ra,40(sp)
    80003f60:	7402                	ld	s0,32(sp)
    80003f62:	64e2                	ld	s1,24(sp)
    80003f64:	6942                	ld	s2,16(sp)
    80003f66:	69a2                	ld	s3,8(sp)
    80003f68:	6145                	addi	sp,sp,48
    80003f6a:	8082                	ret

0000000080003f6c <ialloc>:
{
    80003f6c:	7139                	addi	sp,sp,-64
    80003f6e:	fc06                	sd	ra,56(sp)
    80003f70:	f822                	sd	s0,48(sp)
    80003f72:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f74:	00026717          	auipc	a4,0x26
    80003f78:	f6872703          	lw	a4,-152(a4) # 80029edc <sb+0xc>
    80003f7c:	4785                	li	a5,1
    80003f7e:	06e7f463          	bgeu	a5,a4,80003fe6 <ialloc+0x7a>
    80003f82:	f426                	sd	s1,40(sp)
    80003f84:	f04a                	sd	s2,32(sp)
    80003f86:	ec4e                	sd	s3,24(sp)
    80003f88:	e852                	sd	s4,16(sp)
    80003f8a:	e456                	sd	s5,8(sp)
    80003f8c:	e05a                	sd	s6,0(sp)
    80003f8e:	8aaa                	mv	s5,a0
    80003f90:	8b2e                	mv	s6,a1
    80003f92:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003f94:	00026a17          	auipc	s4,0x26
    80003f98:	f3ca0a13          	addi	s4,s4,-196 # 80029ed0 <sb>
    80003f9c:	00495593          	srli	a1,s2,0x4
    80003fa0:	018a2783          	lw	a5,24(s4)
    80003fa4:	9dbd                	addw	a1,a1,a5
    80003fa6:	8556                	mv	a0,s5
    80003fa8:	00000097          	auipc	ra,0x0
    80003fac:	934080e7          	jalr	-1740(ra) # 800038dc <bread>
    80003fb0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003fb2:	05850993          	addi	s3,a0,88
    80003fb6:	00f97793          	andi	a5,s2,15
    80003fba:	079a                	slli	a5,a5,0x6
    80003fbc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003fbe:	00099783          	lh	a5,0(s3)
    80003fc2:	cf9d                	beqz	a5,80004000 <ialloc+0x94>
    brelse(bp);
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	a48080e7          	jalr	-1464(ra) # 80003a0c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003fcc:	0905                	addi	s2,s2,1
    80003fce:	00ca2703          	lw	a4,12(s4)
    80003fd2:	0009079b          	sext.w	a5,s2
    80003fd6:	fce7e3e3          	bltu	a5,a4,80003f9c <ialloc+0x30>
    80003fda:	74a2                	ld	s1,40(sp)
    80003fdc:	7902                	ld	s2,32(sp)
    80003fde:	69e2                	ld	s3,24(sp)
    80003fe0:	6a42                	ld	s4,16(sp)
    80003fe2:	6aa2                	ld	s5,8(sp)
    80003fe4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003fe6:	00004517          	auipc	a0,0x4
    80003fea:	66250513          	addi	a0,a0,1634 # 80008648 <__func__.1+0x640>
    80003fee:	ffffc097          	auipc	ra,0xffffc
    80003ff2:	5ce080e7          	jalr	1486(ra) # 800005bc <printf>
  return 0;
    80003ff6:	4501                	li	a0,0
}
    80003ff8:	70e2                	ld	ra,56(sp)
    80003ffa:	7442                	ld	s0,48(sp)
    80003ffc:	6121                	addi	sp,sp,64
    80003ffe:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80004000:	04000613          	li	a2,64
    80004004:	4581                	li	a1,0
    80004006:	854e                	mv	a0,s3
    80004008:	ffffd097          	auipc	ra,0xffffd
    8000400c:	02a080e7          	jalr	42(ra) # 80001032 <memset>
      dip->type = type;
    80004010:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004014:	8526                	mv	a0,s1
    80004016:	00001097          	auipc	ra,0x1
    8000401a:	ca0080e7          	jalr	-864(ra) # 80004cb6 <log_write>
      brelse(bp);
    8000401e:	8526                	mv	a0,s1
    80004020:	00000097          	auipc	ra,0x0
    80004024:	9ec080e7          	jalr	-1556(ra) # 80003a0c <brelse>
      return iget(dev, inum);
    80004028:	0009059b          	sext.w	a1,s2
    8000402c:	8556                	mv	a0,s5
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	da2080e7          	jalr	-606(ra) # 80003dd0 <iget>
    80004036:	74a2                	ld	s1,40(sp)
    80004038:	7902                	ld	s2,32(sp)
    8000403a:	69e2                	ld	s3,24(sp)
    8000403c:	6a42                	ld	s4,16(sp)
    8000403e:	6aa2                	ld	s5,8(sp)
    80004040:	6b02                	ld	s6,0(sp)
    80004042:	bf5d                	j	80003ff8 <ialloc+0x8c>

0000000080004044 <iupdate>:
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	e426                	sd	s1,8(sp)
    8000404c:	e04a                	sd	s2,0(sp)
    8000404e:	1000                	addi	s0,sp,32
    80004050:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004052:	415c                	lw	a5,4(a0)
    80004054:	0047d79b          	srliw	a5,a5,0x4
    80004058:	00026597          	auipc	a1,0x26
    8000405c:	e905a583          	lw	a1,-368(a1) # 80029ee8 <sb+0x18>
    80004060:	9dbd                	addw	a1,a1,a5
    80004062:	4108                	lw	a0,0(a0)
    80004064:	00000097          	auipc	ra,0x0
    80004068:	878080e7          	jalr	-1928(ra) # 800038dc <bread>
    8000406c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000406e:	05850793          	addi	a5,a0,88
    80004072:	40d8                	lw	a4,4(s1)
    80004074:	8b3d                	andi	a4,a4,15
    80004076:	071a                	slli	a4,a4,0x6
    80004078:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000407a:	04449703          	lh	a4,68(s1)
    8000407e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004082:	04649703          	lh	a4,70(s1)
    80004086:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000408a:	04849703          	lh	a4,72(s1)
    8000408e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004092:	04a49703          	lh	a4,74(s1)
    80004096:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000409a:	44f8                	lw	a4,76(s1)
    8000409c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000409e:	03400613          	li	a2,52
    800040a2:	05048593          	addi	a1,s1,80
    800040a6:	00c78513          	addi	a0,a5,12
    800040aa:	ffffd097          	auipc	ra,0xffffd
    800040ae:	fe4080e7          	jalr	-28(ra) # 8000108e <memmove>
  log_write(bp);
    800040b2:	854a                	mv	a0,s2
    800040b4:	00001097          	auipc	ra,0x1
    800040b8:	c02080e7          	jalr	-1022(ra) # 80004cb6 <log_write>
  brelse(bp);
    800040bc:	854a                	mv	a0,s2
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	94e080e7          	jalr	-1714(ra) # 80003a0c <brelse>
}
    800040c6:	60e2                	ld	ra,24(sp)
    800040c8:	6442                	ld	s0,16(sp)
    800040ca:	64a2                	ld	s1,8(sp)
    800040cc:	6902                	ld	s2,0(sp)
    800040ce:	6105                	addi	sp,sp,32
    800040d0:	8082                	ret

00000000800040d2 <idup>:
{
    800040d2:	1101                	addi	sp,sp,-32
    800040d4:	ec06                	sd	ra,24(sp)
    800040d6:	e822                	sd	s0,16(sp)
    800040d8:	e426                	sd	s1,8(sp)
    800040da:	1000                	addi	s0,sp,32
    800040dc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040de:	00026517          	auipc	a0,0x26
    800040e2:	e1250513          	addi	a0,a0,-494 # 80029ef0 <itable>
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	e50080e7          	jalr	-432(ra) # 80000f36 <acquire>
  ip->ref++;
    800040ee:	449c                	lw	a5,8(s1)
    800040f0:	2785                	addiw	a5,a5,1
    800040f2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040f4:	00026517          	auipc	a0,0x26
    800040f8:	dfc50513          	addi	a0,a0,-516 # 80029ef0 <itable>
    800040fc:	ffffd097          	auipc	ra,0xffffd
    80004100:	eee080e7          	jalr	-274(ra) # 80000fea <release>
}
    80004104:	8526                	mv	a0,s1
    80004106:	60e2                	ld	ra,24(sp)
    80004108:	6442                	ld	s0,16(sp)
    8000410a:	64a2                	ld	s1,8(sp)
    8000410c:	6105                	addi	sp,sp,32
    8000410e:	8082                	ret

0000000080004110 <ilock>:
{
    80004110:	1101                	addi	sp,sp,-32
    80004112:	ec06                	sd	ra,24(sp)
    80004114:	e822                	sd	s0,16(sp)
    80004116:	e426                	sd	s1,8(sp)
    80004118:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000411a:	c10d                	beqz	a0,8000413c <ilock+0x2c>
    8000411c:	84aa                	mv	s1,a0
    8000411e:	451c                	lw	a5,8(a0)
    80004120:	00f05e63          	blez	a5,8000413c <ilock+0x2c>
  acquiresleep(&ip->lock);
    80004124:	0541                	addi	a0,a0,16
    80004126:	00001097          	auipc	ra,0x1
    8000412a:	cae080e7          	jalr	-850(ra) # 80004dd4 <acquiresleep>
  if(ip->valid == 0){
    8000412e:	40bc                	lw	a5,64(s1)
    80004130:	cf99                	beqz	a5,8000414e <ilock+0x3e>
}
    80004132:	60e2                	ld	ra,24(sp)
    80004134:	6442                	ld	s0,16(sp)
    80004136:	64a2                	ld	s1,8(sp)
    80004138:	6105                	addi	sp,sp,32
    8000413a:	8082                	ret
    8000413c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000413e:	00004517          	auipc	a0,0x4
    80004142:	52250513          	addi	a0,a0,1314 # 80008660 <__func__.1+0x658>
    80004146:	ffffc097          	auipc	ra,0xffffc
    8000414a:	41a080e7          	jalr	1050(ra) # 80000560 <panic>
    8000414e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004150:	40dc                	lw	a5,4(s1)
    80004152:	0047d79b          	srliw	a5,a5,0x4
    80004156:	00026597          	auipc	a1,0x26
    8000415a:	d925a583          	lw	a1,-622(a1) # 80029ee8 <sb+0x18>
    8000415e:	9dbd                	addw	a1,a1,a5
    80004160:	4088                	lw	a0,0(s1)
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	77a080e7          	jalr	1914(ra) # 800038dc <bread>
    8000416a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000416c:	05850593          	addi	a1,a0,88
    80004170:	40dc                	lw	a5,4(s1)
    80004172:	8bbd                	andi	a5,a5,15
    80004174:	079a                	slli	a5,a5,0x6
    80004176:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004178:	00059783          	lh	a5,0(a1)
    8000417c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004180:	00259783          	lh	a5,2(a1)
    80004184:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004188:	00459783          	lh	a5,4(a1)
    8000418c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004190:	00659783          	lh	a5,6(a1)
    80004194:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004198:	459c                	lw	a5,8(a1)
    8000419a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000419c:	03400613          	li	a2,52
    800041a0:	05b1                	addi	a1,a1,12
    800041a2:	05048513          	addi	a0,s1,80
    800041a6:	ffffd097          	auipc	ra,0xffffd
    800041aa:	ee8080e7          	jalr	-280(ra) # 8000108e <memmove>
    brelse(bp);
    800041ae:	854a                	mv	a0,s2
    800041b0:	00000097          	auipc	ra,0x0
    800041b4:	85c080e7          	jalr	-1956(ra) # 80003a0c <brelse>
    ip->valid = 1;
    800041b8:	4785                	li	a5,1
    800041ba:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800041bc:	04449783          	lh	a5,68(s1)
    800041c0:	c399                	beqz	a5,800041c6 <ilock+0xb6>
    800041c2:	6902                	ld	s2,0(sp)
    800041c4:	b7bd                	j	80004132 <ilock+0x22>
      panic("ilock: no type");
    800041c6:	00004517          	auipc	a0,0x4
    800041ca:	4a250513          	addi	a0,a0,1186 # 80008668 <__func__.1+0x660>
    800041ce:	ffffc097          	auipc	ra,0xffffc
    800041d2:	392080e7          	jalr	914(ra) # 80000560 <panic>

00000000800041d6 <iunlock>:
{
    800041d6:	1101                	addi	sp,sp,-32
    800041d8:	ec06                	sd	ra,24(sp)
    800041da:	e822                	sd	s0,16(sp)
    800041dc:	e426                	sd	s1,8(sp)
    800041de:	e04a                	sd	s2,0(sp)
    800041e0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800041e2:	c905                	beqz	a0,80004212 <iunlock+0x3c>
    800041e4:	84aa                	mv	s1,a0
    800041e6:	01050913          	addi	s2,a0,16
    800041ea:	854a                	mv	a0,s2
    800041ec:	00001097          	auipc	ra,0x1
    800041f0:	c82080e7          	jalr	-894(ra) # 80004e6e <holdingsleep>
    800041f4:	cd19                	beqz	a0,80004212 <iunlock+0x3c>
    800041f6:	449c                	lw	a5,8(s1)
    800041f8:	00f05d63          	blez	a5,80004212 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800041fc:	854a                	mv	a0,s2
    800041fe:	00001097          	auipc	ra,0x1
    80004202:	c2c080e7          	jalr	-980(ra) # 80004e2a <releasesleep>
}
    80004206:	60e2                	ld	ra,24(sp)
    80004208:	6442                	ld	s0,16(sp)
    8000420a:	64a2                	ld	s1,8(sp)
    8000420c:	6902                	ld	s2,0(sp)
    8000420e:	6105                	addi	sp,sp,32
    80004210:	8082                	ret
    panic("iunlock");
    80004212:	00004517          	auipc	a0,0x4
    80004216:	46650513          	addi	a0,a0,1126 # 80008678 <__func__.1+0x670>
    8000421a:	ffffc097          	auipc	ra,0xffffc
    8000421e:	346080e7          	jalr	838(ra) # 80000560 <panic>

0000000080004222 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004222:	7179                	addi	sp,sp,-48
    80004224:	f406                	sd	ra,40(sp)
    80004226:	f022                	sd	s0,32(sp)
    80004228:	ec26                	sd	s1,24(sp)
    8000422a:	e84a                	sd	s2,16(sp)
    8000422c:	e44e                	sd	s3,8(sp)
    8000422e:	1800                	addi	s0,sp,48
    80004230:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004232:	05050493          	addi	s1,a0,80
    80004236:	08050913          	addi	s2,a0,128
    8000423a:	a021                	j	80004242 <itrunc+0x20>
    8000423c:	0491                	addi	s1,s1,4
    8000423e:	01248d63          	beq	s1,s2,80004258 <itrunc+0x36>
    if(ip->addrs[i]){
    80004242:	408c                	lw	a1,0(s1)
    80004244:	dde5                	beqz	a1,8000423c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004246:	0009a503          	lw	a0,0(s3)
    8000424a:	00000097          	auipc	ra,0x0
    8000424e:	8d6080e7          	jalr	-1834(ra) # 80003b20 <bfree>
      ip->addrs[i] = 0;
    80004252:	0004a023          	sw	zero,0(s1)
    80004256:	b7dd                	j	8000423c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004258:	0809a583          	lw	a1,128(s3)
    8000425c:	ed99                	bnez	a1,8000427a <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000425e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004262:	854e                	mv	a0,s3
    80004264:	00000097          	auipc	ra,0x0
    80004268:	de0080e7          	jalr	-544(ra) # 80004044 <iupdate>
}
    8000426c:	70a2                	ld	ra,40(sp)
    8000426e:	7402                	ld	s0,32(sp)
    80004270:	64e2                	ld	s1,24(sp)
    80004272:	6942                	ld	s2,16(sp)
    80004274:	69a2                	ld	s3,8(sp)
    80004276:	6145                	addi	sp,sp,48
    80004278:	8082                	ret
    8000427a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000427c:	0009a503          	lw	a0,0(s3)
    80004280:	fffff097          	auipc	ra,0xfffff
    80004284:	65c080e7          	jalr	1628(ra) # 800038dc <bread>
    80004288:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000428a:	05850493          	addi	s1,a0,88
    8000428e:	45850913          	addi	s2,a0,1112
    80004292:	a021                	j	8000429a <itrunc+0x78>
    80004294:	0491                	addi	s1,s1,4
    80004296:	01248b63          	beq	s1,s2,800042ac <itrunc+0x8a>
      if(a[j])
    8000429a:	408c                	lw	a1,0(s1)
    8000429c:	dde5                	beqz	a1,80004294 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    8000429e:	0009a503          	lw	a0,0(s3)
    800042a2:	00000097          	auipc	ra,0x0
    800042a6:	87e080e7          	jalr	-1922(ra) # 80003b20 <bfree>
    800042aa:	b7ed                	j	80004294 <itrunc+0x72>
    brelse(bp);
    800042ac:	8552                	mv	a0,s4
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	75e080e7          	jalr	1886(ra) # 80003a0c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800042b6:	0809a583          	lw	a1,128(s3)
    800042ba:	0009a503          	lw	a0,0(s3)
    800042be:	00000097          	auipc	ra,0x0
    800042c2:	862080e7          	jalr	-1950(ra) # 80003b20 <bfree>
    ip->addrs[NDIRECT] = 0;
    800042c6:	0809a023          	sw	zero,128(s3)
    800042ca:	6a02                	ld	s4,0(sp)
    800042cc:	bf49                	j	8000425e <itrunc+0x3c>

00000000800042ce <iput>:
{
    800042ce:	1101                	addi	sp,sp,-32
    800042d0:	ec06                	sd	ra,24(sp)
    800042d2:	e822                	sd	s0,16(sp)
    800042d4:	e426                	sd	s1,8(sp)
    800042d6:	1000                	addi	s0,sp,32
    800042d8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800042da:	00026517          	auipc	a0,0x26
    800042de:	c1650513          	addi	a0,a0,-1002 # 80029ef0 <itable>
    800042e2:	ffffd097          	auipc	ra,0xffffd
    800042e6:	c54080e7          	jalr	-940(ra) # 80000f36 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042ea:	4498                	lw	a4,8(s1)
    800042ec:	4785                	li	a5,1
    800042ee:	02f70263          	beq	a4,a5,80004312 <iput+0x44>
  ip->ref--;
    800042f2:	449c                	lw	a5,8(s1)
    800042f4:	37fd                	addiw	a5,a5,-1
    800042f6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800042f8:	00026517          	auipc	a0,0x26
    800042fc:	bf850513          	addi	a0,a0,-1032 # 80029ef0 <itable>
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	cea080e7          	jalr	-790(ra) # 80000fea <release>
}
    80004308:	60e2                	ld	ra,24(sp)
    8000430a:	6442                	ld	s0,16(sp)
    8000430c:	64a2                	ld	s1,8(sp)
    8000430e:	6105                	addi	sp,sp,32
    80004310:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004312:	40bc                	lw	a5,64(s1)
    80004314:	dff9                	beqz	a5,800042f2 <iput+0x24>
    80004316:	04a49783          	lh	a5,74(s1)
    8000431a:	ffe1                	bnez	a5,800042f2 <iput+0x24>
    8000431c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000431e:	01048913          	addi	s2,s1,16
    80004322:	854a                	mv	a0,s2
    80004324:	00001097          	auipc	ra,0x1
    80004328:	ab0080e7          	jalr	-1360(ra) # 80004dd4 <acquiresleep>
    release(&itable.lock);
    8000432c:	00026517          	auipc	a0,0x26
    80004330:	bc450513          	addi	a0,a0,-1084 # 80029ef0 <itable>
    80004334:	ffffd097          	auipc	ra,0xffffd
    80004338:	cb6080e7          	jalr	-842(ra) # 80000fea <release>
    itrunc(ip);
    8000433c:	8526                	mv	a0,s1
    8000433e:	00000097          	auipc	ra,0x0
    80004342:	ee4080e7          	jalr	-284(ra) # 80004222 <itrunc>
    ip->type = 0;
    80004346:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000434a:	8526                	mv	a0,s1
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	cf8080e7          	jalr	-776(ra) # 80004044 <iupdate>
    ip->valid = 0;
    80004354:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004358:	854a                	mv	a0,s2
    8000435a:	00001097          	auipc	ra,0x1
    8000435e:	ad0080e7          	jalr	-1328(ra) # 80004e2a <releasesleep>
    acquire(&itable.lock);
    80004362:	00026517          	auipc	a0,0x26
    80004366:	b8e50513          	addi	a0,a0,-1138 # 80029ef0 <itable>
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	bcc080e7          	jalr	-1076(ra) # 80000f36 <acquire>
    80004372:	6902                	ld	s2,0(sp)
    80004374:	bfbd                	j	800042f2 <iput+0x24>

0000000080004376 <iunlockput>:
{
    80004376:	1101                	addi	sp,sp,-32
    80004378:	ec06                	sd	ra,24(sp)
    8000437a:	e822                	sd	s0,16(sp)
    8000437c:	e426                	sd	s1,8(sp)
    8000437e:	1000                	addi	s0,sp,32
    80004380:	84aa                	mv	s1,a0
  iunlock(ip);
    80004382:	00000097          	auipc	ra,0x0
    80004386:	e54080e7          	jalr	-428(ra) # 800041d6 <iunlock>
  iput(ip);
    8000438a:	8526                	mv	a0,s1
    8000438c:	00000097          	auipc	ra,0x0
    80004390:	f42080e7          	jalr	-190(ra) # 800042ce <iput>
}
    80004394:	60e2                	ld	ra,24(sp)
    80004396:	6442                	ld	s0,16(sp)
    80004398:	64a2                	ld	s1,8(sp)
    8000439a:	6105                	addi	sp,sp,32
    8000439c:	8082                	ret

000000008000439e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000439e:	1141                	addi	sp,sp,-16
    800043a0:	e422                	sd	s0,8(sp)
    800043a2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800043a4:	411c                	lw	a5,0(a0)
    800043a6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800043a8:	415c                	lw	a5,4(a0)
    800043aa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800043ac:	04451783          	lh	a5,68(a0)
    800043b0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800043b4:	04a51783          	lh	a5,74(a0)
    800043b8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800043bc:	04c56783          	lwu	a5,76(a0)
    800043c0:	e99c                	sd	a5,16(a1)
}
    800043c2:	6422                	ld	s0,8(sp)
    800043c4:	0141                	addi	sp,sp,16
    800043c6:	8082                	ret

00000000800043c8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800043c8:	457c                	lw	a5,76(a0)
    800043ca:	10d7e563          	bltu	a5,a3,800044d4 <readi+0x10c>
{
    800043ce:	7159                	addi	sp,sp,-112
    800043d0:	f486                	sd	ra,104(sp)
    800043d2:	f0a2                	sd	s0,96(sp)
    800043d4:	eca6                	sd	s1,88(sp)
    800043d6:	e0d2                	sd	s4,64(sp)
    800043d8:	fc56                	sd	s5,56(sp)
    800043da:	f85a                	sd	s6,48(sp)
    800043dc:	f45e                	sd	s7,40(sp)
    800043de:	1880                	addi	s0,sp,112
    800043e0:	8b2a                	mv	s6,a0
    800043e2:	8bae                	mv	s7,a1
    800043e4:	8a32                	mv	s4,a2
    800043e6:	84b6                	mv	s1,a3
    800043e8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800043ea:	9f35                	addw	a4,a4,a3
    return 0;
    800043ec:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800043ee:	0cd76a63          	bltu	a4,a3,800044c2 <readi+0xfa>
    800043f2:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800043f4:	00e7f463          	bgeu	a5,a4,800043fc <readi+0x34>
    n = ip->size - off;
    800043f8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043fc:	0a0a8963          	beqz	s5,800044ae <readi+0xe6>
    80004400:	e8ca                	sd	s2,80(sp)
    80004402:	f062                	sd	s8,32(sp)
    80004404:	ec66                	sd	s9,24(sp)
    80004406:	e86a                	sd	s10,16(sp)
    80004408:	e46e                	sd	s11,8(sp)
    8000440a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000440c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004410:	5c7d                	li	s8,-1
    80004412:	a82d                	j	8000444c <readi+0x84>
    80004414:	020d1d93          	slli	s11,s10,0x20
    80004418:	020ddd93          	srli	s11,s11,0x20
    8000441c:	05890613          	addi	a2,s2,88
    80004420:	86ee                	mv	a3,s11
    80004422:	963a                	add	a2,a2,a4
    80004424:	85d2                	mv	a1,s4
    80004426:	855e                	mv	a0,s7
    80004428:	ffffe097          	auipc	ra,0xffffe
    8000442c:	73a080e7          	jalr	1850(ra) # 80002b62 <either_copyout>
    80004430:	05850d63          	beq	a0,s8,8000448a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004434:	854a                	mv	a0,s2
    80004436:	fffff097          	auipc	ra,0xfffff
    8000443a:	5d6080e7          	jalr	1494(ra) # 80003a0c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000443e:	013d09bb          	addw	s3,s10,s3
    80004442:	009d04bb          	addw	s1,s10,s1
    80004446:	9a6e                	add	s4,s4,s11
    80004448:	0559fd63          	bgeu	s3,s5,800044a2 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    8000444c:	00a4d59b          	srliw	a1,s1,0xa
    80004450:	855a                	mv	a0,s6
    80004452:	00000097          	auipc	ra,0x0
    80004456:	88e080e7          	jalr	-1906(ra) # 80003ce0 <bmap>
    8000445a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000445e:	c9b1                	beqz	a1,800044b2 <readi+0xea>
    bp = bread(ip->dev, addr);
    80004460:	000b2503          	lw	a0,0(s6)
    80004464:	fffff097          	auipc	ra,0xfffff
    80004468:	478080e7          	jalr	1144(ra) # 800038dc <bread>
    8000446c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000446e:	3ff4f713          	andi	a4,s1,1023
    80004472:	40ec87bb          	subw	a5,s9,a4
    80004476:	413a86bb          	subw	a3,s5,s3
    8000447a:	8d3e                	mv	s10,a5
    8000447c:	2781                	sext.w	a5,a5
    8000447e:	0006861b          	sext.w	a2,a3
    80004482:	f8f679e3          	bgeu	a2,a5,80004414 <readi+0x4c>
    80004486:	8d36                	mv	s10,a3
    80004488:	b771                	j	80004414 <readi+0x4c>
      brelse(bp);
    8000448a:	854a                	mv	a0,s2
    8000448c:	fffff097          	auipc	ra,0xfffff
    80004490:	580080e7          	jalr	1408(ra) # 80003a0c <brelse>
      tot = -1;
    80004494:	59fd                	li	s3,-1
      break;
    80004496:	6946                	ld	s2,80(sp)
    80004498:	7c02                	ld	s8,32(sp)
    8000449a:	6ce2                	ld	s9,24(sp)
    8000449c:	6d42                	ld	s10,16(sp)
    8000449e:	6da2                	ld	s11,8(sp)
    800044a0:	a831                	j	800044bc <readi+0xf4>
    800044a2:	6946                	ld	s2,80(sp)
    800044a4:	7c02                	ld	s8,32(sp)
    800044a6:	6ce2                	ld	s9,24(sp)
    800044a8:	6d42                	ld	s10,16(sp)
    800044aa:	6da2                	ld	s11,8(sp)
    800044ac:	a801                	j	800044bc <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044ae:	89d6                	mv	s3,s5
    800044b0:	a031                	j	800044bc <readi+0xf4>
    800044b2:	6946                	ld	s2,80(sp)
    800044b4:	7c02                	ld	s8,32(sp)
    800044b6:	6ce2                	ld	s9,24(sp)
    800044b8:	6d42                	ld	s10,16(sp)
    800044ba:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800044bc:	0009851b          	sext.w	a0,s3
    800044c0:	69a6                	ld	s3,72(sp)
}
    800044c2:	70a6                	ld	ra,104(sp)
    800044c4:	7406                	ld	s0,96(sp)
    800044c6:	64e6                	ld	s1,88(sp)
    800044c8:	6a06                	ld	s4,64(sp)
    800044ca:	7ae2                	ld	s5,56(sp)
    800044cc:	7b42                	ld	s6,48(sp)
    800044ce:	7ba2                	ld	s7,40(sp)
    800044d0:	6165                	addi	sp,sp,112
    800044d2:	8082                	ret
    return 0;
    800044d4:	4501                	li	a0,0
}
    800044d6:	8082                	ret

00000000800044d8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800044d8:	457c                	lw	a5,76(a0)
    800044da:	10d7ee63          	bltu	a5,a3,800045f6 <writei+0x11e>
{
    800044de:	7159                	addi	sp,sp,-112
    800044e0:	f486                	sd	ra,104(sp)
    800044e2:	f0a2                	sd	s0,96(sp)
    800044e4:	e8ca                	sd	s2,80(sp)
    800044e6:	e0d2                	sd	s4,64(sp)
    800044e8:	fc56                	sd	s5,56(sp)
    800044ea:	f85a                	sd	s6,48(sp)
    800044ec:	f45e                	sd	s7,40(sp)
    800044ee:	1880                	addi	s0,sp,112
    800044f0:	8aaa                	mv	s5,a0
    800044f2:	8bae                	mv	s7,a1
    800044f4:	8a32                	mv	s4,a2
    800044f6:	8936                	mv	s2,a3
    800044f8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800044fa:	00e687bb          	addw	a5,a3,a4
    800044fe:	0ed7ee63          	bltu	a5,a3,800045fa <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004502:	00043737          	lui	a4,0x43
    80004506:	0ef76c63          	bltu	a4,a5,800045fe <writei+0x126>
    8000450a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000450c:	0c0b0d63          	beqz	s6,800045e6 <writei+0x10e>
    80004510:	eca6                	sd	s1,88(sp)
    80004512:	f062                	sd	s8,32(sp)
    80004514:	ec66                	sd	s9,24(sp)
    80004516:	e86a                	sd	s10,16(sp)
    80004518:	e46e                	sd	s11,8(sp)
    8000451a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000451c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004520:	5c7d                	li	s8,-1
    80004522:	a091                	j	80004566 <writei+0x8e>
    80004524:	020d1d93          	slli	s11,s10,0x20
    80004528:	020ddd93          	srli	s11,s11,0x20
    8000452c:	05848513          	addi	a0,s1,88
    80004530:	86ee                	mv	a3,s11
    80004532:	8652                	mv	a2,s4
    80004534:	85de                	mv	a1,s7
    80004536:	953a                	add	a0,a0,a4
    80004538:	ffffe097          	auipc	ra,0xffffe
    8000453c:	680080e7          	jalr	1664(ra) # 80002bb8 <either_copyin>
    80004540:	07850263          	beq	a0,s8,800045a4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004544:	8526                	mv	a0,s1
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	770080e7          	jalr	1904(ra) # 80004cb6 <log_write>
    brelse(bp);
    8000454e:	8526                	mv	a0,s1
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	4bc080e7          	jalr	1212(ra) # 80003a0c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004558:	013d09bb          	addw	s3,s10,s3
    8000455c:	012d093b          	addw	s2,s10,s2
    80004560:	9a6e                	add	s4,s4,s11
    80004562:	0569f663          	bgeu	s3,s6,800045ae <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004566:	00a9559b          	srliw	a1,s2,0xa
    8000456a:	8556                	mv	a0,s5
    8000456c:	fffff097          	auipc	ra,0xfffff
    80004570:	774080e7          	jalr	1908(ra) # 80003ce0 <bmap>
    80004574:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004578:	c99d                	beqz	a1,800045ae <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000457a:	000aa503          	lw	a0,0(s5)
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	35e080e7          	jalr	862(ra) # 800038dc <bread>
    80004586:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004588:	3ff97713          	andi	a4,s2,1023
    8000458c:	40ec87bb          	subw	a5,s9,a4
    80004590:	413b06bb          	subw	a3,s6,s3
    80004594:	8d3e                	mv	s10,a5
    80004596:	2781                	sext.w	a5,a5
    80004598:	0006861b          	sext.w	a2,a3
    8000459c:	f8f674e3          	bgeu	a2,a5,80004524 <writei+0x4c>
    800045a0:	8d36                	mv	s10,a3
    800045a2:	b749                	j	80004524 <writei+0x4c>
      brelse(bp);
    800045a4:	8526                	mv	a0,s1
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	466080e7          	jalr	1126(ra) # 80003a0c <brelse>
  }

  if(off > ip->size)
    800045ae:	04caa783          	lw	a5,76(s5)
    800045b2:	0327fc63          	bgeu	a5,s2,800045ea <writei+0x112>
    ip->size = off;
    800045b6:	052aa623          	sw	s2,76(s5)
    800045ba:	64e6                	ld	s1,88(sp)
    800045bc:	7c02                	ld	s8,32(sp)
    800045be:	6ce2                	ld	s9,24(sp)
    800045c0:	6d42                	ld	s10,16(sp)
    800045c2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800045c4:	8556                	mv	a0,s5
    800045c6:	00000097          	auipc	ra,0x0
    800045ca:	a7e080e7          	jalr	-1410(ra) # 80004044 <iupdate>

  return tot;
    800045ce:	0009851b          	sext.w	a0,s3
    800045d2:	69a6                	ld	s3,72(sp)
}
    800045d4:	70a6                	ld	ra,104(sp)
    800045d6:	7406                	ld	s0,96(sp)
    800045d8:	6946                	ld	s2,80(sp)
    800045da:	6a06                	ld	s4,64(sp)
    800045dc:	7ae2                	ld	s5,56(sp)
    800045de:	7b42                	ld	s6,48(sp)
    800045e0:	7ba2                	ld	s7,40(sp)
    800045e2:	6165                	addi	sp,sp,112
    800045e4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045e6:	89da                	mv	s3,s6
    800045e8:	bff1                	j	800045c4 <writei+0xec>
    800045ea:	64e6                	ld	s1,88(sp)
    800045ec:	7c02                	ld	s8,32(sp)
    800045ee:	6ce2                	ld	s9,24(sp)
    800045f0:	6d42                	ld	s10,16(sp)
    800045f2:	6da2                	ld	s11,8(sp)
    800045f4:	bfc1                	j	800045c4 <writei+0xec>
    return -1;
    800045f6:	557d                	li	a0,-1
}
    800045f8:	8082                	ret
    return -1;
    800045fa:	557d                	li	a0,-1
    800045fc:	bfe1                	j	800045d4 <writei+0xfc>
    return -1;
    800045fe:	557d                	li	a0,-1
    80004600:	bfd1                	j	800045d4 <writei+0xfc>

0000000080004602 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004602:	1141                	addi	sp,sp,-16
    80004604:	e406                	sd	ra,8(sp)
    80004606:	e022                	sd	s0,0(sp)
    80004608:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000460a:	4639                	li	a2,14
    8000460c:	ffffd097          	auipc	ra,0xffffd
    80004610:	af6080e7          	jalr	-1290(ra) # 80001102 <strncmp>
}
    80004614:	60a2                	ld	ra,8(sp)
    80004616:	6402                	ld	s0,0(sp)
    80004618:	0141                	addi	sp,sp,16
    8000461a:	8082                	ret

000000008000461c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000461c:	7139                	addi	sp,sp,-64
    8000461e:	fc06                	sd	ra,56(sp)
    80004620:	f822                	sd	s0,48(sp)
    80004622:	f426                	sd	s1,40(sp)
    80004624:	f04a                	sd	s2,32(sp)
    80004626:	ec4e                	sd	s3,24(sp)
    80004628:	e852                	sd	s4,16(sp)
    8000462a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000462c:	04451703          	lh	a4,68(a0)
    80004630:	4785                	li	a5,1
    80004632:	00f71a63          	bne	a4,a5,80004646 <dirlookup+0x2a>
    80004636:	892a                	mv	s2,a0
    80004638:	89ae                	mv	s3,a1
    8000463a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000463c:	457c                	lw	a5,76(a0)
    8000463e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004640:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004642:	e79d                	bnez	a5,80004670 <dirlookup+0x54>
    80004644:	a8a5                	j	800046bc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004646:	00004517          	auipc	a0,0x4
    8000464a:	03a50513          	addi	a0,a0,58 # 80008680 <__func__.1+0x678>
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	f12080e7          	jalr	-238(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004656:	00004517          	auipc	a0,0x4
    8000465a:	04250513          	addi	a0,a0,66 # 80008698 <__func__.1+0x690>
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	f02080e7          	jalr	-254(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004666:	24c1                	addiw	s1,s1,16
    80004668:	04c92783          	lw	a5,76(s2)
    8000466c:	04f4f763          	bgeu	s1,a5,800046ba <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004670:	4741                	li	a4,16
    80004672:	86a6                	mv	a3,s1
    80004674:	fc040613          	addi	a2,s0,-64
    80004678:	4581                	li	a1,0
    8000467a:	854a                	mv	a0,s2
    8000467c:	00000097          	auipc	ra,0x0
    80004680:	d4c080e7          	jalr	-692(ra) # 800043c8 <readi>
    80004684:	47c1                	li	a5,16
    80004686:	fcf518e3          	bne	a0,a5,80004656 <dirlookup+0x3a>
    if(de.inum == 0)
    8000468a:	fc045783          	lhu	a5,-64(s0)
    8000468e:	dfe1                	beqz	a5,80004666 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004690:	fc240593          	addi	a1,s0,-62
    80004694:	854e                	mv	a0,s3
    80004696:	00000097          	auipc	ra,0x0
    8000469a:	f6c080e7          	jalr	-148(ra) # 80004602 <namecmp>
    8000469e:	f561                	bnez	a0,80004666 <dirlookup+0x4a>
      if(poff)
    800046a0:	000a0463          	beqz	s4,800046a8 <dirlookup+0x8c>
        *poff = off;
    800046a4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800046a8:	fc045583          	lhu	a1,-64(s0)
    800046ac:	00092503          	lw	a0,0(s2)
    800046b0:	fffff097          	auipc	ra,0xfffff
    800046b4:	720080e7          	jalr	1824(ra) # 80003dd0 <iget>
    800046b8:	a011                	j	800046bc <dirlookup+0xa0>
  return 0;
    800046ba:	4501                	li	a0,0
}
    800046bc:	70e2                	ld	ra,56(sp)
    800046be:	7442                	ld	s0,48(sp)
    800046c0:	74a2                	ld	s1,40(sp)
    800046c2:	7902                	ld	s2,32(sp)
    800046c4:	69e2                	ld	s3,24(sp)
    800046c6:	6a42                	ld	s4,16(sp)
    800046c8:	6121                	addi	sp,sp,64
    800046ca:	8082                	ret

00000000800046cc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800046cc:	711d                	addi	sp,sp,-96
    800046ce:	ec86                	sd	ra,88(sp)
    800046d0:	e8a2                	sd	s0,80(sp)
    800046d2:	e4a6                	sd	s1,72(sp)
    800046d4:	e0ca                	sd	s2,64(sp)
    800046d6:	fc4e                	sd	s3,56(sp)
    800046d8:	f852                	sd	s4,48(sp)
    800046da:	f456                	sd	s5,40(sp)
    800046dc:	f05a                	sd	s6,32(sp)
    800046de:	ec5e                	sd	s7,24(sp)
    800046e0:	e862                	sd	s8,16(sp)
    800046e2:	e466                	sd	s9,8(sp)
    800046e4:	1080                	addi	s0,sp,96
    800046e6:	84aa                	mv	s1,a0
    800046e8:	8b2e                	mv	s6,a1
    800046ea:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800046ec:	00054703          	lbu	a4,0(a0)
    800046f0:	02f00793          	li	a5,47
    800046f4:	02f70263          	beq	a4,a5,80004718 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800046f8:	ffffe097          	auipc	ra,0xffffe
    800046fc:	8b0080e7          	jalr	-1872(ra) # 80001fa8 <myproc>
    80004700:	15053503          	ld	a0,336(a0)
    80004704:	00000097          	auipc	ra,0x0
    80004708:	9ce080e7          	jalr	-1586(ra) # 800040d2 <idup>
    8000470c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000470e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004712:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004714:	4b85                	li	s7,1
    80004716:	a875                	j	800047d2 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004718:	4585                	li	a1,1
    8000471a:	4505                	li	a0,1
    8000471c:	fffff097          	auipc	ra,0xfffff
    80004720:	6b4080e7          	jalr	1716(ra) # 80003dd0 <iget>
    80004724:	8a2a                	mv	s4,a0
    80004726:	b7e5                	j	8000470e <namex+0x42>
      iunlockput(ip);
    80004728:	8552                	mv	a0,s4
    8000472a:	00000097          	auipc	ra,0x0
    8000472e:	c4c080e7          	jalr	-948(ra) # 80004376 <iunlockput>
      return 0;
    80004732:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004734:	8552                	mv	a0,s4
    80004736:	60e6                	ld	ra,88(sp)
    80004738:	6446                	ld	s0,80(sp)
    8000473a:	64a6                	ld	s1,72(sp)
    8000473c:	6906                	ld	s2,64(sp)
    8000473e:	79e2                	ld	s3,56(sp)
    80004740:	7a42                	ld	s4,48(sp)
    80004742:	7aa2                	ld	s5,40(sp)
    80004744:	7b02                	ld	s6,32(sp)
    80004746:	6be2                	ld	s7,24(sp)
    80004748:	6c42                	ld	s8,16(sp)
    8000474a:	6ca2                	ld	s9,8(sp)
    8000474c:	6125                	addi	sp,sp,96
    8000474e:	8082                	ret
      iunlock(ip);
    80004750:	8552                	mv	a0,s4
    80004752:	00000097          	auipc	ra,0x0
    80004756:	a84080e7          	jalr	-1404(ra) # 800041d6 <iunlock>
      return ip;
    8000475a:	bfe9                	j	80004734 <namex+0x68>
      iunlockput(ip);
    8000475c:	8552                	mv	a0,s4
    8000475e:	00000097          	auipc	ra,0x0
    80004762:	c18080e7          	jalr	-1000(ra) # 80004376 <iunlockput>
      return 0;
    80004766:	8a4e                	mv	s4,s3
    80004768:	b7f1                	j	80004734 <namex+0x68>
  len = path - s;
    8000476a:	40998633          	sub	a2,s3,s1
    8000476e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004772:	099c5863          	bge	s8,s9,80004802 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004776:	4639                	li	a2,14
    80004778:	85a6                	mv	a1,s1
    8000477a:	8556                	mv	a0,s5
    8000477c:	ffffd097          	auipc	ra,0xffffd
    80004780:	912080e7          	jalr	-1774(ra) # 8000108e <memmove>
    80004784:	84ce                	mv	s1,s3
  while(*path == '/')
    80004786:	0004c783          	lbu	a5,0(s1)
    8000478a:	01279763          	bne	a5,s2,80004798 <namex+0xcc>
    path++;
    8000478e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004790:	0004c783          	lbu	a5,0(s1)
    80004794:	ff278de3          	beq	a5,s2,8000478e <namex+0xc2>
    ilock(ip);
    80004798:	8552                	mv	a0,s4
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	976080e7          	jalr	-1674(ra) # 80004110 <ilock>
    if(ip->type != T_DIR){
    800047a2:	044a1783          	lh	a5,68(s4)
    800047a6:	f97791e3          	bne	a5,s7,80004728 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    800047aa:	000b0563          	beqz	s6,800047b4 <namex+0xe8>
    800047ae:	0004c783          	lbu	a5,0(s1)
    800047b2:	dfd9                	beqz	a5,80004750 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800047b4:	4601                	li	a2,0
    800047b6:	85d6                	mv	a1,s5
    800047b8:	8552                	mv	a0,s4
    800047ba:	00000097          	auipc	ra,0x0
    800047be:	e62080e7          	jalr	-414(ra) # 8000461c <dirlookup>
    800047c2:	89aa                	mv	s3,a0
    800047c4:	dd41                	beqz	a0,8000475c <namex+0x90>
    iunlockput(ip);
    800047c6:	8552                	mv	a0,s4
    800047c8:	00000097          	auipc	ra,0x0
    800047cc:	bae080e7          	jalr	-1106(ra) # 80004376 <iunlockput>
    ip = next;
    800047d0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800047d2:	0004c783          	lbu	a5,0(s1)
    800047d6:	01279763          	bne	a5,s2,800047e4 <namex+0x118>
    path++;
    800047da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800047dc:	0004c783          	lbu	a5,0(s1)
    800047e0:	ff278de3          	beq	a5,s2,800047da <namex+0x10e>
  if(*path == 0)
    800047e4:	cb9d                	beqz	a5,8000481a <namex+0x14e>
  while(*path != '/' && *path != 0)
    800047e6:	0004c783          	lbu	a5,0(s1)
    800047ea:	89a6                	mv	s3,s1
  len = path - s;
    800047ec:	4c81                	li	s9,0
    800047ee:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800047f0:	01278963          	beq	a5,s2,80004802 <namex+0x136>
    800047f4:	dbbd                	beqz	a5,8000476a <namex+0x9e>
    path++;
    800047f6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800047f8:	0009c783          	lbu	a5,0(s3)
    800047fc:	ff279ce3          	bne	a5,s2,800047f4 <namex+0x128>
    80004800:	b7ad                	j	8000476a <namex+0x9e>
    memmove(name, s, len);
    80004802:	2601                	sext.w	a2,a2
    80004804:	85a6                	mv	a1,s1
    80004806:	8556                	mv	a0,s5
    80004808:	ffffd097          	auipc	ra,0xffffd
    8000480c:	886080e7          	jalr	-1914(ra) # 8000108e <memmove>
    name[len] = 0;
    80004810:	9cd6                	add	s9,s9,s5
    80004812:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004816:	84ce                	mv	s1,s3
    80004818:	b7bd                	j	80004786 <namex+0xba>
  if(nameiparent){
    8000481a:	f00b0de3          	beqz	s6,80004734 <namex+0x68>
    iput(ip);
    8000481e:	8552                	mv	a0,s4
    80004820:	00000097          	auipc	ra,0x0
    80004824:	aae080e7          	jalr	-1362(ra) # 800042ce <iput>
    return 0;
    80004828:	4a01                	li	s4,0
    8000482a:	b729                	j	80004734 <namex+0x68>

000000008000482c <dirlink>:
{
    8000482c:	7139                	addi	sp,sp,-64
    8000482e:	fc06                	sd	ra,56(sp)
    80004830:	f822                	sd	s0,48(sp)
    80004832:	f04a                	sd	s2,32(sp)
    80004834:	ec4e                	sd	s3,24(sp)
    80004836:	e852                	sd	s4,16(sp)
    80004838:	0080                	addi	s0,sp,64
    8000483a:	892a                	mv	s2,a0
    8000483c:	8a2e                	mv	s4,a1
    8000483e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004840:	4601                	li	a2,0
    80004842:	00000097          	auipc	ra,0x0
    80004846:	dda080e7          	jalr	-550(ra) # 8000461c <dirlookup>
    8000484a:	ed25                	bnez	a0,800048c2 <dirlink+0x96>
    8000484c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000484e:	04c92483          	lw	s1,76(s2)
    80004852:	c49d                	beqz	s1,80004880 <dirlink+0x54>
    80004854:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004856:	4741                	li	a4,16
    80004858:	86a6                	mv	a3,s1
    8000485a:	fc040613          	addi	a2,s0,-64
    8000485e:	4581                	li	a1,0
    80004860:	854a                	mv	a0,s2
    80004862:	00000097          	auipc	ra,0x0
    80004866:	b66080e7          	jalr	-1178(ra) # 800043c8 <readi>
    8000486a:	47c1                	li	a5,16
    8000486c:	06f51163          	bne	a0,a5,800048ce <dirlink+0xa2>
    if(de.inum == 0)
    80004870:	fc045783          	lhu	a5,-64(s0)
    80004874:	c791                	beqz	a5,80004880 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004876:	24c1                	addiw	s1,s1,16
    80004878:	04c92783          	lw	a5,76(s2)
    8000487c:	fcf4ede3          	bltu	s1,a5,80004856 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004880:	4639                	li	a2,14
    80004882:	85d2                	mv	a1,s4
    80004884:	fc240513          	addi	a0,s0,-62
    80004888:	ffffd097          	auipc	ra,0xffffd
    8000488c:	8b0080e7          	jalr	-1872(ra) # 80001138 <strncpy>
  de.inum = inum;
    80004890:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004894:	4741                	li	a4,16
    80004896:	86a6                	mv	a3,s1
    80004898:	fc040613          	addi	a2,s0,-64
    8000489c:	4581                	li	a1,0
    8000489e:	854a                	mv	a0,s2
    800048a0:	00000097          	auipc	ra,0x0
    800048a4:	c38080e7          	jalr	-968(ra) # 800044d8 <writei>
    800048a8:	1541                	addi	a0,a0,-16
    800048aa:	00a03533          	snez	a0,a0
    800048ae:	40a00533          	neg	a0,a0
    800048b2:	74a2                	ld	s1,40(sp)
}
    800048b4:	70e2                	ld	ra,56(sp)
    800048b6:	7442                	ld	s0,48(sp)
    800048b8:	7902                	ld	s2,32(sp)
    800048ba:	69e2                	ld	s3,24(sp)
    800048bc:	6a42                	ld	s4,16(sp)
    800048be:	6121                	addi	sp,sp,64
    800048c0:	8082                	ret
    iput(ip);
    800048c2:	00000097          	auipc	ra,0x0
    800048c6:	a0c080e7          	jalr	-1524(ra) # 800042ce <iput>
    return -1;
    800048ca:	557d                	li	a0,-1
    800048cc:	b7e5                	j	800048b4 <dirlink+0x88>
      panic("dirlink read");
    800048ce:	00004517          	auipc	a0,0x4
    800048d2:	dda50513          	addi	a0,a0,-550 # 800086a8 <__func__.1+0x6a0>
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	c8a080e7          	jalr	-886(ra) # 80000560 <panic>

00000000800048de <namei>:

struct inode*
namei(char *path)
{
    800048de:	1101                	addi	sp,sp,-32
    800048e0:	ec06                	sd	ra,24(sp)
    800048e2:	e822                	sd	s0,16(sp)
    800048e4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800048e6:	fe040613          	addi	a2,s0,-32
    800048ea:	4581                	li	a1,0
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	de0080e7          	jalr	-544(ra) # 800046cc <namex>
}
    800048f4:	60e2                	ld	ra,24(sp)
    800048f6:	6442                	ld	s0,16(sp)
    800048f8:	6105                	addi	sp,sp,32
    800048fa:	8082                	ret

00000000800048fc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800048fc:	1141                	addi	sp,sp,-16
    800048fe:	e406                	sd	ra,8(sp)
    80004900:	e022                	sd	s0,0(sp)
    80004902:	0800                	addi	s0,sp,16
    80004904:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004906:	4585                	li	a1,1
    80004908:	00000097          	auipc	ra,0x0
    8000490c:	dc4080e7          	jalr	-572(ra) # 800046cc <namex>
}
    80004910:	60a2                	ld	ra,8(sp)
    80004912:	6402                	ld	s0,0(sp)
    80004914:	0141                	addi	sp,sp,16
    80004916:	8082                	ret

0000000080004918 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004918:	1101                	addi	sp,sp,-32
    8000491a:	ec06                	sd	ra,24(sp)
    8000491c:	e822                	sd	s0,16(sp)
    8000491e:	e426                	sd	s1,8(sp)
    80004920:	e04a                	sd	s2,0(sp)
    80004922:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004924:	00027917          	auipc	s2,0x27
    80004928:	07490913          	addi	s2,s2,116 # 8002b998 <log>
    8000492c:	01892583          	lw	a1,24(s2)
    80004930:	02892503          	lw	a0,40(s2)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	fa8080e7          	jalr	-88(ra) # 800038dc <bread>
    8000493c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000493e:	02c92603          	lw	a2,44(s2)
    80004942:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004944:	00c05f63          	blez	a2,80004962 <write_head+0x4a>
    80004948:	00027717          	auipc	a4,0x27
    8000494c:	08070713          	addi	a4,a4,128 # 8002b9c8 <log+0x30>
    80004950:	87aa                	mv	a5,a0
    80004952:	060a                	slli	a2,a2,0x2
    80004954:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004956:	4314                	lw	a3,0(a4)
    80004958:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000495a:	0711                	addi	a4,a4,4
    8000495c:	0791                	addi	a5,a5,4
    8000495e:	fec79ce3          	bne	a5,a2,80004956 <write_head+0x3e>
  }
  bwrite(buf);
    80004962:	8526                	mv	a0,s1
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	06a080e7          	jalr	106(ra) # 800039ce <bwrite>
  brelse(buf);
    8000496c:	8526                	mv	a0,s1
    8000496e:	fffff097          	auipc	ra,0xfffff
    80004972:	09e080e7          	jalr	158(ra) # 80003a0c <brelse>
}
    80004976:	60e2                	ld	ra,24(sp)
    80004978:	6442                	ld	s0,16(sp)
    8000497a:	64a2                	ld	s1,8(sp)
    8000497c:	6902                	ld	s2,0(sp)
    8000497e:	6105                	addi	sp,sp,32
    80004980:	8082                	ret

0000000080004982 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004982:	00027797          	auipc	a5,0x27
    80004986:	0427a783          	lw	a5,66(a5) # 8002b9c4 <log+0x2c>
    8000498a:	0af05d63          	blez	a5,80004a44 <install_trans+0xc2>
{
    8000498e:	7139                	addi	sp,sp,-64
    80004990:	fc06                	sd	ra,56(sp)
    80004992:	f822                	sd	s0,48(sp)
    80004994:	f426                	sd	s1,40(sp)
    80004996:	f04a                	sd	s2,32(sp)
    80004998:	ec4e                	sd	s3,24(sp)
    8000499a:	e852                	sd	s4,16(sp)
    8000499c:	e456                	sd	s5,8(sp)
    8000499e:	e05a                	sd	s6,0(sp)
    800049a0:	0080                	addi	s0,sp,64
    800049a2:	8b2a                	mv	s6,a0
    800049a4:	00027a97          	auipc	s5,0x27
    800049a8:	024a8a93          	addi	s5,s5,36 # 8002b9c8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049ac:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049ae:	00027997          	auipc	s3,0x27
    800049b2:	fea98993          	addi	s3,s3,-22 # 8002b998 <log>
    800049b6:	a00d                	j	800049d8 <install_trans+0x56>
    brelse(lbuf);
    800049b8:	854a                	mv	a0,s2
    800049ba:	fffff097          	auipc	ra,0xfffff
    800049be:	052080e7          	jalr	82(ra) # 80003a0c <brelse>
    brelse(dbuf);
    800049c2:	8526                	mv	a0,s1
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	048080e7          	jalr	72(ra) # 80003a0c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049cc:	2a05                	addiw	s4,s4,1
    800049ce:	0a91                	addi	s5,s5,4
    800049d0:	02c9a783          	lw	a5,44(s3)
    800049d4:	04fa5e63          	bge	s4,a5,80004a30 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049d8:	0189a583          	lw	a1,24(s3)
    800049dc:	014585bb          	addw	a1,a1,s4
    800049e0:	2585                	addiw	a1,a1,1
    800049e2:	0289a503          	lw	a0,40(s3)
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	ef6080e7          	jalr	-266(ra) # 800038dc <bread>
    800049ee:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800049f0:	000aa583          	lw	a1,0(s5)
    800049f4:	0289a503          	lw	a0,40(s3)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	ee4080e7          	jalr	-284(ra) # 800038dc <bread>
    80004a00:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004a02:	40000613          	li	a2,1024
    80004a06:	05890593          	addi	a1,s2,88
    80004a0a:	05850513          	addi	a0,a0,88
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	680080e7          	jalr	1664(ra) # 8000108e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004a16:	8526                	mv	a0,s1
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	fb6080e7          	jalr	-74(ra) # 800039ce <bwrite>
    if(recovering == 0)
    80004a20:	f80b1ce3          	bnez	s6,800049b8 <install_trans+0x36>
      bunpin(dbuf);
    80004a24:	8526                	mv	a0,s1
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	0be080e7          	jalr	190(ra) # 80003ae4 <bunpin>
    80004a2e:	b769                	j	800049b8 <install_trans+0x36>
}
    80004a30:	70e2                	ld	ra,56(sp)
    80004a32:	7442                	ld	s0,48(sp)
    80004a34:	74a2                	ld	s1,40(sp)
    80004a36:	7902                	ld	s2,32(sp)
    80004a38:	69e2                	ld	s3,24(sp)
    80004a3a:	6a42                	ld	s4,16(sp)
    80004a3c:	6aa2                	ld	s5,8(sp)
    80004a3e:	6b02                	ld	s6,0(sp)
    80004a40:	6121                	addi	sp,sp,64
    80004a42:	8082                	ret
    80004a44:	8082                	ret

0000000080004a46 <initlog>:
{
    80004a46:	7179                	addi	sp,sp,-48
    80004a48:	f406                	sd	ra,40(sp)
    80004a4a:	f022                	sd	s0,32(sp)
    80004a4c:	ec26                	sd	s1,24(sp)
    80004a4e:	e84a                	sd	s2,16(sp)
    80004a50:	e44e                	sd	s3,8(sp)
    80004a52:	1800                	addi	s0,sp,48
    80004a54:	892a                	mv	s2,a0
    80004a56:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004a58:	00027497          	auipc	s1,0x27
    80004a5c:	f4048493          	addi	s1,s1,-192 # 8002b998 <log>
    80004a60:	00004597          	auipc	a1,0x4
    80004a64:	c5858593          	addi	a1,a1,-936 # 800086b8 <__func__.1+0x6b0>
    80004a68:	8526                	mv	a0,s1
    80004a6a:	ffffc097          	auipc	ra,0xffffc
    80004a6e:	43c080e7          	jalr	1084(ra) # 80000ea6 <initlock>
  log.start = sb->logstart;
    80004a72:	0149a583          	lw	a1,20(s3)
    80004a76:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004a78:	0109a783          	lw	a5,16(s3)
    80004a7c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004a7e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004a82:	854a                	mv	a0,s2
    80004a84:	fffff097          	auipc	ra,0xfffff
    80004a88:	e58080e7          	jalr	-424(ra) # 800038dc <bread>
  log.lh.n = lh->n;
    80004a8c:	4d30                	lw	a2,88(a0)
    80004a8e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004a90:	00c05f63          	blez	a2,80004aae <initlog+0x68>
    80004a94:	87aa                	mv	a5,a0
    80004a96:	00027717          	auipc	a4,0x27
    80004a9a:	f3270713          	addi	a4,a4,-206 # 8002b9c8 <log+0x30>
    80004a9e:	060a                	slli	a2,a2,0x2
    80004aa0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004aa2:	4ff4                	lw	a3,92(a5)
    80004aa4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004aa6:	0791                	addi	a5,a5,4
    80004aa8:	0711                	addi	a4,a4,4
    80004aaa:	fec79ce3          	bne	a5,a2,80004aa2 <initlog+0x5c>
  brelse(buf);
    80004aae:	fffff097          	auipc	ra,0xfffff
    80004ab2:	f5e080e7          	jalr	-162(ra) # 80003a0c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004ab6:	4505                	li	a0,1
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	eca080e7          	jalr	-310(ra) # 80004982 <install_trans>
  log.lh.n = 0;
    80004ac0:	00027797          	auipc	a5,0x27
    80004ac4:	f007a223          	sw	zero,-252(a5) # 8002b9c4 <log+0x2c>
  write_head(); // clear the log
    80004ac8:	00000097          	auipc	ra,0x0
    80004acc:	e50080e7          	jalr	-432(ra) # 80004918 <write_head>
}
    80004ad0:	70a2                	ld	ra,40(sp)
    80004ad2:	7402                	ld	s0,32(sp)
    80004ad4:	64e2                	ld	s1,24(sp)
    80004ad6:	6942                	ld	s2,16(sp)
    80004ad8:	69a2                	ld	s3,8(sp)
    80004ada:	6145                	addi	sp,sp,48
    80004adc:	8082                	ret

0000000080004ade <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004ade:	1101                	addi	sp,sp,-32
    80004ae0:	ec06                	sd	ra,24(sp)
    80004ae2:	e822                	sd	s0,16(sp)
    80004ae4:	e426                	sd	s1,8(sp)
    80004ae6:	e04a                	sd	s2,0(sp)
    80004ae8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004aea:	00027517          	auipc	a0,0x27
    80004aee:	eae50513          	addi	a0,a0,-338 # 8002b998 <log>
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	444080e7          	jalr	1092(ra) # 80000f36 <acquire>
  while(1){
    if(log.committing){
    80004afa:	00027497          	auipc	s1,0x27
    80004afe:	e9e48493          	addi	s1,s1,-354 # 8002b998 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b02:	4979                	li	s2,30
    80004b04:	a039                	j	80004b12 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004b06:	85a6                	mv	a1,s1
    80004b08:	8526                	mv	a0,s1
    80004b0a:	ffffe097          	auipc	ra,0xffffe
    80004b0e:	c50080e7          	jalr	-944(ra) # 8000275a <sleep>
    if(log.committing){
    80004b12:	50dc                	lw	a5,36(s1)
    80004b14:	fbed                	bnez	a5,80004b06 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b16:	5098                	lw	a4,32(s1)
    80004b18:	2705                	addiw	a4,a4,1
    80004b1a:	0027179b          	slliw	a5,a4,0x2
    80004b1e:	9fb9                	addw	a5,a5,a4
    80004b20:	0017979b          	slliw	a5,a5,0x1
    80004b24:	54d4                	lw	a3,44(s1)
    80004b26:	9fb5                	addw	a5,a5,a3
    80004b28:	00f95963          	bge	s2,a5,80004b3a <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004b2c:	85a6                	mv	a1,s1
    80004b2e:	8526                	mv	a0,s1
    80004b30:	ffffe097          	auipc	ra,0xffffe
    80004b34:	c2a080e7          	jalr	-982(ra) # 8000275a <sleep>
    80004b38:	bfe9                	j	80004b12 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004b3a:	00027517          	auipc	a0,0x27
    80004b3e:	e5e50513          	addi	a0,a0,-418 # 8002b998 <log>
    80004b42:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	4a6080e7          	jalr	1190(ra) # 80000fea <release>
      break;
    }
  }
}
    80004b4c:	60e2                	ld	ra,24(sp)
    80004b4e:	6442                	ld	s0,16(sp)
    80004b50:	64a2                	ld	s1,8(sp)
    80004b52:	6902                	ld	s2,0(sp)
    80004b54:	6105                	addi	sp,sp,32
    80004b56:	8082                	ret

0000000080004b58 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004b58:	7139                	addi	sp,sp,-64
    80004b5a:	fc06                	sd	ra,56(sp)
    80004b5c:	f822                	sd	s0,48(sp)
    80004b5e:	f426                	sd	s1,40(sp)
    80004b60:	f04a                	sd	s2,32(sp)
    80004b62:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004b64:	00027497          	auipc	s1,0x27
    80004b68:	e3448493          	addi	s1,s1,-460 # 8002b998 <log>
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	3c8080e7          	jalr	968(ra) # 80000f36 <acquire>
  log.outstanding -= 1;
    80004b76:	509c                	lw	a5,32(s1)
    80004b78:	37fd                	addiw	a5,a5,-1
    80004b7a:	0007891b          	sext.w	s2,a5
    80004b7e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004b80:	50dc                	lw	a5,36(s1)
    80004b82:	e7b9                	bnez	a5,80004bd0 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b84:	06091163          	bnez	s2,80004be6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004b88:	00027497          	auipc	s1,0x27
    80004b8c:	e1048493          	addi	s1,s1,-496 # 8002b998 <log>
    80004b90:	4785                	li	a5,1
    80004b92:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	454080e7          	jalr	1108(ra) # 80000fea <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004b9e:	54dc                	lw	a5,44(s1)
    80004ba0:	06f04763          	bgtz	a5,80004c0e <end_op+0xb6>
    acquire(&log.lock);
    80004ba4:	00027497          	auipc	s1,0x27
    80004ba8:	df448493          	addi	s1,s1,-524 # 8002b998 <log>
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	388080e7          	jalr	904(ra) # 80000f36 <acquire>
    log.committing = 0;
    80004bb6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004bba:	8526                	mv	a0,s1
    80004bbc:	ffffe097          	auipc	ra,0xffffe
    80004bc0:	c02080e7          	jalr	-1022(ra) # 800027be <wakeup>
    release(&log.lock);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	424080e7          	jalr	1060(ra) # 80000fea <release>
}
    80004bce:	a815                	j	80004c02 <end_op+0xaa>
    80004bd0:	ec4e                	sd	s3,24(sp)
    80004bd2:	e852                	sd	s4,16(sp)
    80004bd4:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004bd6:	00004517          	auipc	a0,0x4
    80004bda:	aea50513          	addi	a0,a0,-1302 # 800086c0 <__func__.1+0x6b8>
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	982080e7          	jalr	-1662(ra) # 80000560 <panic>
    wakeup(&log);
    80004be6:	00027497          	auipc	s1,0x27
    80004bea:	db248493          	addi	s1,s1,-590 # 8002b998 <log>
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffe097          	auipc	ra,0xffffe
    80004bf4:	bce080e7          	jalr	-1074(ra) # 800027be <wakeup>
  release(&log.lock);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	3f0080e7          	jalr	1008(ra) # 80000fea <release>
}
    80004c02:	70e2                	ld	ra,56(sp)
    80004c04:	7442                	ld	s0,48(sp)
    80004c06:	74a2                	ld	s1,40(sp)
    80004c08:	7902                	ld	s2,32(sp)
    80004c0a:	6121                	addi	sp,sp,64
    80004c0c:	8082                	ret
    80004c0e:	ec4e                	sd	s3,24(sp)
    80004c10:	e852                	sd	s4,16(sp)
    80004c12:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c14:	00027a97          	auipc	s5,0x27
    80004c18:	db4a8a93          	addi	s5,s5,-588 # 8002b9c8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004c1c:	00027a17          	auipc	s4,0x27
    80004c20:	d7ca0a13          	addi	s4,s4,-644 # 8002b998 <log>
    80004c24:	018a2583          	lw	a1,24(s4)
    80004c28:	012585bb          	addw	a1,a1,s2
    80004c2c:	2585                	addiw	a1,a1,1
    80004c2e:	028a2503          	lw	a0,40(s4)
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	caa080e7          	jalr	-854(ra) # 800038dc <bread>
    80004c3a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004c3c:	000aa583          	lw	a1,0(s5)
    80004c40:	028a2503          	lw	a0,40(s4)
    80004c44:	fffff097          	auipc	ra,0xfffff
    80004c48:	c98080e7          	jalr	-872(ra) # 800038dc <bread>
    80004c4c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004c4e:	40000613          	li	a2,1024
    80004c52:	05850593          	addi	a1,a0,88
    80004c56:	05848513          	addi	a0,s1,88
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	434080e7          	jalr	1076(ra) # 8000108e <memmove>
    bwrite(to);  // write the log
    80004c62:	8526                	mv	a0,s1
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	d6a080e7          	jalr	-662(ra) # 800039ce <bwrite>
    brelse(from);
    80004c6c:	854e                	mv	a0,s3
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	d9e080e7          	jalr	-610(ra) # 80003a0c <brelse>
    brelse(to);
    80004c76:	8526                	mv	a0,s1
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	d94080e7          	jalr	-620(ra) # 80003a0c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c80:	2905                	addiw	s2,s2,1
    80004c82:	0a91                	addi	s5,s5,4
    80004c84:	02ca2783          	lw	a5,44(s4)
    80004c88:	f8f94ee3          	blt	s2,a5,80004c24 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004c8c:	00000097          	auipc	ra,0x0
    80004c90:	c8c080e7          	jalr	-884(ra) # 80004918 <write_head>
    install_trans(0); // Now install writes to home locations
    80004c94:	4501                	li	a0,0
    80004c96:	00000097          	auipc	ra,0x0
    80004c9a:	cec080e7          	jalr	-788(ra) # 80004982 <install_trans>
    log.lh.n = 0;
    80004c9e:	00027797          	auipc	a5,0x27
    80004ca2:	d207a323          	sw	zero,-730(a5) # 8002b9c4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004ca6:	00000097          	auipc	ra,0x0
    80004caa:	c72080e7          	jalr	-910(ra) # 80004918 <write_head>
    80004cae:	69e2                	ld	s3,24(sp)
    80004cb0:	6a42                	ld	s4,16(sp)
    80004cb2:	6aa2                	ld	s5,8(sp)
    80004cb4:	bdc5                	j	80004ba4 <end_op+0x4c>

0000000080004cb6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004cb6:	1101                	addi	sp,sp,-32
    80004cb8:	ec06                	sd	ra,24(sp)
    80004cba:	e822                	sd	s0,16(sp)
    80004cbc:	e426                	sd	s1,8(sp)
    80004cbe:	e04a                	sd	s2,0(sp)
    80004cc0:	1000                	addi	s0,sp,32
    80004cc2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004cc4:	00027917          	auipc	s2,0x27
    80004cc8:	cd490913          	addi	s2,s2,-812 # 8002b998 <log>
    80004ccc:	854a                	mv	a0,s2
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	268080e7          	jalr	616(ra) # 80000f36 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004cd6:	02c92603          	lw	a2,44(s2)
    80004cda:	47f5                	li	a5,29
    80004cdc:	06c7c563          	blt	a5,a2,80004d46 <log_write+0x90>
    80004ce0:	00027797          	auipc	a5,0x27
    80004ce4:	cd47a783          	lw	a5,-812(a5) # 8002b9b4 <log+0x1c>
    80004ce8:	37fd                	addiw	a5,a5,-1
    80004cea:	04f65e63          	bge	a2,a5,80004d46 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004cee:	00027797          	auipc	a5,0x27
    80004cf2:	cca7a783          	lw	a5,-822(a5) # 8002b9b8 <log+0x20>
    80004cf6:	06f05063          	blez	a5,80004d56 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004cfa:	4781                	li	a5,0
    80004cfc:	06c05563          	blez	a2,80004d66 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004d00:	44cc                	lw	a1,12(s1)
    80004d02:	00027717          	auipc	a4,0x27
    80004d06:	cc670713          	addi	a4,a4,-826 # 8002b9c8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004d0a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004d0c:	4314                	lw	a3,0(a4)
    80004d0e:	04b68c63          	beq	a3,a1,80004d66 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004d12:	2785                	addiw	a5,a5,1
    80004d14:	0711                	addi	a4,a4,4
    80004d16:	fef61be3          	bne	a2,a5,80004d0c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004d1a:	0621                	addi	a2,a2,8
    80004d1c:	060a                	slli	a2,a2,0x2
    80004d1e:	00027797          	auipc	a5,0x27
    80004d22:	c7a78793          	addi	a5,a5,-902 # 8002b998 <log>
    80004d26:	97b2                	add	a5,a5,a2
    80004d28:	44d8                	lw	a4,12(s1)
    80004d2a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004d2c:	8526                	mv	a0,s1
    80004d2e:	fffff097          	auipc	ra,0xfffff
    80004d32:	d7a080e7          	jalr	-646(ra) # 80003aa8 <bpin>
    log.lh.n++;
    80004d36:	00027717          	auipc	a4,0x27
    80004d3a:	c6270713          	addi	a4,a4,-926 # 8002b998 <log>
    80004d3e:	575c                	lw	a5,44(a4)
    80004d40:	2785                	addiw	a5,a5,1
    80004d42:	d75c                	sw	a5,44(a4)
    80004d44:	a82d                	j	80004d7e <log_write+0xc8>
    panic("too big a transaction");
    80004d46:	00004517          	auipc	a0,0x4
    80004d4a:	98a50513          	addi	a0,a0,-1654 # 800086d0 <__func__.1+0x6c8>
    80004d4e:	ffffc097          	auipc	ra,0xffffc
    80004d52:	812080e7          	jalr	-2030(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004d56:	00004517          	auipc	a0,0x4
    80004d5a:	99250513          	addi	a0,a0,-1646 # 800086e8 <__func__.1+0x6e0>
    80004d5e:	ffffc097          	auipc	ra,0xffffc
    80004d62:	802080e7          	jalr	-2046(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004d66:	00878693          	addi	a3,a5,8
    80004d6a:	068a                	slli	a3,a3,0x2
    80004d6c:	00027717          	auipc	a4,0x27
    80004d70:	c2c70713          	addi	a4,a4,-980 # 8002b998 <log>
    80004d74:	9736                	add	a4,a4,a3
    80004d76:	44d4                	lw	a3,12(s1)
    80004d78:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004d7a:	faf609e3          	beq	a2,a5,80004d2c <log_write+0x76>
  }
  release(&log.lock);
    80004d7e:	00027517          	auipc	a0,0x27
    80004d82:	c1a50513          	addi	a0,a0,-998 # 8002b998 <log>
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	264080e7          	jalr	612(ra) # 80000fea <release>
}
    80004d8e:	60e2                	ld	ra,24(sp)
    80004d90:	6442                	ld	s0,16(sp)
    80004d92:	64a2                	ld	s1,8(sp)
    80004d94:	6902                	ld	s2,0(sp)
    80004d96:	6105                	addi	sp,sp,32
    80004d98:	8082                	ret

0000000080004d9a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004d9a:	1101                	addi	sp,sp,-32
    80004d9c:	ec06                	sd	ra,24(sp)
    80004d9e:	e822                	sd	s0,16(sp)
    80004da0:	e426                	sd	s1,8(sp)
    80004da2:	e04a                	sd	s2,0(sp)
    80004da4:	1000                	addi	s0,sp,32
    80004da6:	84aa                	mv	s1,a0
    80004da8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004daa:	00004597          	auipc	a1,0x4
    80004dae:	95e58593          	addi	a1,a1,-1698 # 80008708 <__func__.1+0x700>
    80004db2:	0521                	addi	a0,a0,8
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	0f2080e7          	jalr	242(ra) # 80000ea6 <initlock>
  lk->name = name;
    80004dbc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004dc0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004dc4:	0204a423          	sw	zero,40(s1)
}
    80004dc8:	60e2                	ld	ra,24(sp)
    80004dca:	6442                	ld	s0,16(sp)
    80004dcc:	64a2                	ld	s1,8(sp)
    80004dce:	6902                	ld	s2,0(sp)
    80004dd0:	6105                	addi	sp,sp,32
    80004dd2:	8082                	ret

0000000080004dd4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004dd4:	1101                	addi	sp,sp,-32
    80004dd6:	ec06                	sd	ra,24(sp)
    80004dd8:	e822                	sd	s0,16(sp)
    80004dda:	e426                	sd	s1,8(sp)
    80004ddc:	e04a                	sd	s2,0(sp)
    80004dde:	1000                	addi	s0,sp,32
    80004de0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004de2:	00850913          	addi	s2,a0,8
    80004de6:	854a                	mv	a0,s2
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	14e080e7          	jalr	334(ra) # 80000f36 <acquire>
  while (lk->locked) {
    80004df0:	409c                	lw	a5,0(s1)
    80004df2:	cb89                	beqz	a5,80004e04 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004df4:	85ca                	mv	a1,s2
    80004df6:	8526                	mv	a0,s1
    80004df8:	ffffe097          	auipc	ra,0xffffe
    80004dfc:	962080e7          	jalr	-1694(ra) # 8000275a <sleep>
  while (lk->locked) {
    80004e00:	409c                	lw	a5,0(s1)
    80004e02:	fbed                	bnez	a5,80004df4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004e04:	4785                	li	a5,1
    80004e06:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004e08:	ffffd097          	auipc	ra,0xffffd
    80004e0c:	1a0080e7          	jalr	416(ra) # 80001fa8 <myproc>
    80004e10:	591c                	lw	a5,48(a0)
    80004e12:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004e14:	854a                	mv	a0,s2
    80004e16:	ffffc097          	auipc	ra,0xffffc
    80004e1a:	1d4080e7          	jalr	468(ra) # 80000fea <release>
}
    80004e1e:	60e2                	ld	ra,24(sp)
    80004e20:	6442                	ld	s0,16(sp)
    80004e22:	64a2                	ld	s1,8(sp)
    80004e24:	6902                	ld	s2,0(sp)
    80004e26:	6105                	addi	sp,sp,32
    80004e28:	8082                	ret

0000000080004e2a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004e2a:	1101                	addi	sp,sp,-32
    80004e2c:	ec06                	sd	ra,24(sp)
    80004e2e:	e822                	sd	s0,16(sp)
    80004e30:	e426                	sd	s1,8(sp)
    80004e32:	e04a                	sd	s2,0(sp)
    80004e34:	1000                	addi	s0,sp,32
    80004e36:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e38:	00850913          	addi	s2,a0,8
    80004e3c:	854a                	mv	a0,s2
    80004e3e:	ffffc097          	auipc	ra,0xffffc
    80004e42:	0f8080e7          	jalr	248(ra) # 80000f36 <acquire>
  lk->locked = 0;
    80004e46:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e4a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	ffffe097          	auipc	ra,0xffffe
    80004e54:	96e080e7          	jalr	-1682(ra) # 800027be <wakeup>
  release(&lk->lk);
    80004e58:	854a                	mv	a0,s2
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	190080e7          	jalr	400(ra) # 80000fea <release>
}
    80004e62:	60e2                	ld	ra,24(sp)
    80004e64:	6442                	ld	s0,16(sp)
    80004e66:	64a2                	ld	s1,8(sp)
    80004e68:	6902                	ld	s2,0(sp)
    80004e6a:	6105                	addi	sp,sp,32
    80004e6c:	8082                	ret

0000000080004e6e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004e6e:	7179                	addi	sp,sp,-48
    80004e70:	f406                	sd	ra,40(sp)
    80004e72:	f022                	sd	s0,32(sp)
    80004e74:	ec26                	sd	s1,24(sp)
    80004e76:	e84a                	sd	s2,16(sp)
    80004e78:	1800                	addi	s0,sp,48
    80004e7a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004e7c:	00850913          	addi	s2,a0,8
    80004e80:	854a                	mv	a0,s2
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	0b4080e7          	jalr	180(ra) # 80000f36 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e8a:	409c                	lw	a5,0(s1)
    80004e8c:	ef91                	bnez	a5,80004ea8 <holdingsleep+0x3a>
    80004e8e:	4481                	li	s1,0
  release(&lk->lk);
    80004e90:	854a                	mv	a0,s2
    80004e92:	ffffc097          	auipc	ra,0xffffc
    80004e96:	158080e7          	jalr	344(ra) # 80000fea <release>
  return r;
}
    80004e9a:	8526                	mv	a0,s1
    80004e9c:	70a2                	ld	ra,40(sp)
    80004e9e:	7402                	ld	s0,32(sp)
    80004ea0:	64e2                	ld	s1,24(sp)
    80004ea2:	6942                	ld	s2,16(sp)
    80004ea4:	6145                	addi	sp,sp,48
    80004ea6:	8082                	ret
    80004ea8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004eaa:	0284a983          	lw	s3,40(s1)
    80004eae:	ffffd097          	auipc	ra,0xffffd
    80004eb2:	0fa080e7          	jalr	250(ra) # 80001fa8 <myproc>
    80004eb6:	5904                	lw	s1,48(a0)
    80004eb8:	413484b3          	sub	s1,s1,s3
    80004ebc:	0014b493          	seqz	s1,s1
    80004ec0:	69a2                	ld	s3,8(sp)
    80004ec2:	b7f9                	j	80004e90 <holdingsleep+0x22>

0000000080004ec4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ec4:	1141                	addi	sp,sp,-16
    80004ec6:	e406                	sd	ra,8(sp)
    80004ec8:	e022                	sd	s0,0(sp)
    80004eca:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ecc:	00004597          	auipc	a1,0x4
    80004ed0:	84c58593          	addi	a1,a1,-1972 # 80008718 <__func__.1+0x710>
    80004ed4:	00027517          	auipc	a0,0x27
    80004ed8:	c0c50513          	addi	a0,a0,-1012 # 8002bae0 <ftable>
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	fca080e7          	jalr	-54(ra) # 80000ea6 <initlock>
}
    80004ee4:	60a2                	ld	ra,8(sp)
    80004ee6:	6402                	ld	s0,0(sp)
    80004ee8:	0141                	addi	sp,sp,16
    80004eea:	8082                	ret

0000000080004eec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004eec:	1101                	addi	sp,sp,-32
    80004eee:	ec06                	sd	ra,24(sp)
    80004ef0:	e822                	sd	s0,16(sp)
    80004ef2:	e426                	sd	s1,8(sp)
    80004ef4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ef6:	00027517          	auipc	a0,0x27
    80004efa:	bea50513          	addi	a0,a0,-1046 # 8002bae0 <ftable>
    80004efe:	ffffc097          	auipc	ra,0xffffc
    80004f02:	038080e7          	jalr	56(ra) # 80000f36 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f06:	00027497          	auipc	s1,0x27
    80004f0a:	bf248493          	addi	s1,s1,-1038 # 8002baf8 <ftable+0x18>
    80004f0e:	00028717          	auipc	a4,0x28
    80004f12:	b8a70713          	addi	a4,a4,-1142 # 8002ca98 <disk>
    if(f->ref == 0){
    80004f16:	40dc                	lw	a5,4(s1)
    80004f18:	cf99                	beqz	a5,80004f36 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f1a:	02848493          	addi	s1,s1,40
    80004f1e:	fee49ce3          	bne	s1,a4,80004f16 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004f22:	00027517          	auipc	a0,0x27
    80004f26:	bbe50513          	addi	a0,a0,-1090 # 8002bae0 <ftable>
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	0c0080e7          	jalr	192(ra) # 80000fea <release>
  return 0;
    80004f32:	4481                	li	s1,0
    80004f34:	a819                	j	80004f4a <filealloc+0x5e>
      f->ref = 1;
    80004f36:	4785                	li	a5,1
    80004f38:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004f3a:	00027517          	auipc	a0,0x27
    80004f3e:	ba650513          	addi	a0,a0,-1114 # 8002bae0 <ftable>
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	0a8080e7          	jalr	168(ra) # 80000fea <release>
}
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	60e2                	ld	ra,24(sp)
    80004f4e:	6442                	ld	s0,16(sp)
    80004f50:	64a2                	ld	s1,8(sp)
    80004f52:	6105                	addi	sp,sp,32
    80004f54:	8082                	ret

0000000080004f56 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004f56:	1101                	addi	sp,sp,-32
    80004f58:	ec06                	sd	ra,24(sp)
    80004f5a:	e822                	sd	s0,16(sp)
    80004f5c:	e426                	sd	s1,8(sp)
    80004f5e:	1000                	addi	s0,sp,32
    80004f60:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004f62:	00027517          	auipc	a0,0x27
    80004f66:	b7e50513          	addi	a0,a0,-1154 # 8002bae0 <ftable>
    80004f6a:	ffffc097          	auipc	ra,0xffffc
    80004f6e:	fcc080e7          	jalr	-52(ra) # 80000f36 <acquire>
  if(f->ref < 1)
    80004f72:	40dc                	lw	a5,4(s1)
    80004f74:	02f05263          	blez	a5,80004f98 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004f78:	2785                	addiw	a5,a5,1
    80004f7a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004f7c:	00027517          	auipc	a0,0x27
    80004f80:	b6450513          	addi	a0,a0,-1180 # 8002bae0 <ftable>
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	066080e7          	jalr	102(ra) # 80000fea <release>
  return f;
}
    80004f8c:	8526                	mv	a0,s1
    80004f8e:	60e2                	ld	ra,24(sp)
    80004f90:	6442                	ld	s0,16(sp)
    80004f92:	64a2                	ld	s1,8(sp)
    80004f94:	6105                	addi	sp,sp,32
    80004f96:	8082                	ret
    panic("filedup");
    80004f98:	00003517          	auipc	a0,0x3
    80004f9c:	78850513          	addi	a0,a0,1928 # 80008720 <__func__.1+0x718>
    80004fa0:	ffffb097          	auipc	ra,0xffffb
    80004fa4:	5c0080e7          	jalr	1472(ra) # 80000560 <panic>

0000000080004fa8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004fa8:	7139                	addi	sp,sp,-64
    80004faa:	fc06                	sd	ra,56(sp)
    80004fac:	f822                	sd	s0,48(sp)
    80004fae:	f426                	sd	s1,40(sp)
    80004fb0:	0080                	addi	s0,sp,64
    80004fb2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004fb4:	00027517          	auipc	a0,0x27
    80004fb8:	b2c50513          	addi	a0,a0,-1236 # 8002bae0 <ftable>
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	f7a080e7          	jalr	-134(ra) # 80000f36 <acquire>
  if(f->ref < 1)
    80004fc4:	40dc                	lw	a5,4(s1)
    80004fc6:	04f05c63          	blez	a5,8000501e <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004fca:	37fd                	addiw	a5,a5,-1
    80004fcc:	0007871b          	sext.w	a4,a5
    80004fd0:	c0dc                	sw	a5,4(s1)
    80004fd2:	06e04263          	bgtz	a4,80005036 <fileclose+0x8e>
    80004fd6:	f04a                	sd	s2,32(sp)
    80004fd8:	ec4e                	sd	s3,24(sp)
    80004fda:	e852                	sd	s4,16(sp)
    80004fdc:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004fde:	0004a903          	lw	s2,0(s1)
    80004fe2:	0094ca83          	lbu	s5,9(s1)
    80004fe6:	0104ba03          	ld	s4,16(s1)
    80004fea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004fee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ff2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ff6:	00027517          	auipc	a0,0x27
    80004ffa:	aea50513          	addi	a0,a0,-1302 # 8002bae0 <ftable>
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	fec080e7          	jalr	-20(ra) # 80000fea <release>

  if(ff.type == FD_PIPE){
    80005006:	4785                	li	a5,1
    80005008:	04f90463          	beq	s2,a5,80005050 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000500c:	3979                	addiw	s2,s2,-2
    8000500e:	4785                	li	a5,1
    80005010:	0527fb63          	bgeu	a5,s2,80005066 <fileclose+0xbe>
    80005014:	7902                	ld	s2,32(sp)
    80005016:	69e2                	ld	s3,24(sp)
    80005018:	6a42                	ld	s4,16(sp)
    8000501a:	6aa2                	ld	s5,8(sp)
    8000501c:	a02d                	j	80005046 <fileclose+0x9e>
    8000501e:	f04a                	sd	s2,32(sp)
    80005020:	ec4e                	sd	s3,24(sp)
    80005022:	e852                	sd	s4,16(sp)
    80005024:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80005026:	00003517          	auipc	a0,0x3
    8000502a:	70250513          	addi	a0,a0,1794 # 80008728 <__func__.1+0x720>
    8000502e:	ffffb097          	auipc	ra,0xffffb
    80005032:	532080e7          	jalr	1330(ra) # 80000560 <panic>
    release(&ftable.lock);
    80005036:	00027517          	auipc	a0,0x27
    8000503a:	aaa50513          	addi	a0,a0,-1366 # 8002bae0 <ftable>
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	fac080e7          	jalr	-84(ra) # 80000fea <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005046:	70e2                	ld	ra,56(sp)
    80005048:	7442                	ld	s0,48(sp)
    8000504a:	74a2                	ld	s1,40(sp)
    8000504c:	6121                	addi	sp,sp,64
    8000504e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005050:	85d6                	mv	a1,s5
    80005052:	8552                	mv	a0,s4
    80005054:	00000097          	auipc	ra,0x0
    80005058:	3a2080e7          	jalr	930(ra) # 800053f6 <pipeclose>
    8000505c:	7902                	ld	s2,32(sp)
    8000505e:	69e2                	ld	s3,24(sp)
    80005060:	6a42                	ld	s4,16(sp)
    80005062:	6aa2                	ld	s5,8(sp)
    80005064:	b7cd                	j	80005046 <fileclose+0x9e>
    begin_op();
    80005066:	00000097          	auipc	ra,0x0
    8000506a:	a78080e7          	jalr	-1416(ra) # 80004ade <begin_op>
    iput(ff.ip);
    8000506e:	854e                	mv	a0,s3
    80005070:	fffff097          	auipc	ra,0xfffff
    80005074:	25e080e7          	jalr	606(ra) # 800042ce <iput>
    end_op();
    80005078:	00000097          	auipc	ra,0x0
    8000507c:	ae0080e7          	jalr	-1312(ra) # 80004b58 <end_op>
    80005080:	7902                	ld	s2,32(sp)
    80005082:	69e2                	ld	s3,24(sp)
    80005084:	6a42                	ld	s4,16(sp)
    80005086:	6aa2                	ld	s5,8(sp)
    80005088:	bf7d                	j	80005046 <fileclose+0x9e>

000000008000508a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000508a:	715d                	addi	sp,sp,-80
    8000508c:	e486                	sd	ra,72(sp)
    8000508e:	e0a2                	sd	s0,64(sp)
    80005090:	fc26                	sd	s1,56(sp)
    80005092:	f44e                	sd	s3,40(sp)
    80005094:	0880                	addi	s0,sp,80
    80005096:	84aa                	mv	s1,a0
    80005098:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000509a:	ffffd097          	auipc	ra,0xffffd
    8000509e:	f0e080e7          	jalr	-242(ra) # 80001fa8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800050a2:	409c                	lw	a5,0(s1)
    800050a4:	37f9                	addiw	a5,a5,-2
    800050a6:	4705                	li	a4,1
    800050a8:	04f76863          	bltu	a4,a5,800050f8 <filestat+0x6e>
    800050ac:	f84a                	sd	s2,48(sp)
    800050ae:	892a                	mv	s2,a0
    ilock(f->ip);
    800050b0:	6c88                	ld	a0,24(s1)
    800050b2:	fffff097          	auipc	ra,0xfffff
    800050b6:	05e080e7          	jalr	94(ra) # 80004110 <ilock>
    stati(f->ip, &st);
    800050ba:	fb840593          	addi	a1,s0,-72
    800050be:	6c88                	ld	a0,24(s1)
    800050c0:	fffff097          	auipc	ra,0xfffff
    800050c4:	2de080e7          	jalr	734(ra) # 8000439e <stati>
    iunlock(f->ip);
    800050c8:	6c88                	ld	a0,24(s1)
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	10c080e7          	jalr	268(ra) # 800041d6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800050d2:	46e1                	li	a3,24
    800050d4:	fb840613          	addi	a2,s0,-72
    800050d8:	85ce                	mv	a1,s3
    800050da:	05093503          	ld	a0,80(s2)
    800050de:	ffffd097          	auipc	ra,0xffffd
    800050e2:	908080e7          	jalr	-1784(ra) # 800019e6 <copyout>
    800050e6:	41f5551b          	sraiw	a0,a0,0x1f
    800050ea:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800050ec:	60a6                	ld	ra,72(sp)
    800050ee:	6406                	ld	s0,64(sp)
    800050f0:	74e2                	ld	s1,56(sp)
    800050f2:	79a2                	ld	s3,40(sp)
    800050f4:	6161                	addi	sp,sp,80
    800050f6:	8082                	ret
  return -1;
    800050f8:	557d                	li	a0,-1
    800050fa:	bfcd                	j	800050ec <filestat+0x62>

00000000800050fc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800050fc:	7179                	addi	sp,sp,-48
    800050fe:	f406                	sd	ra,40(sp)
    80005100:	f022                	sd	s0,32(sp)
    80005102:	e84a                	sd	s2,16(sp)
    80005104:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005106:	00854783          	lbu	a5,8(a0)
    8000510a:	cbc5                	beqz	a5,800051ba <fileread+0xbe>
    8000510c:	ec26                	sd	s1,24(sp)
    8000510e:	e44e                	sd	s3,8(sp)
    80005110:	84aa                	mv	s1,a0
    80005112:	89ae                	mv	s3,a1
    80005114:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005116:	411c                	lw	a5,0(a0)
    80005118:	4705                	li	a4,1
    8000511a:	04e78963          	beq	a5,a4,8000516c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000511e:	470d                	li	a4,3
    80005120:	04e78f63          	beq	a5,a4,8000517e <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005124:	4709                	li	a4,2
    80005126:	08e79263          	bne	a5,a4,800051aa <fileread+0xae>
    ilock(f->ip);
    8000512a:	6d08                	ld	a0,24(a0)
    8000512c:	fffff097          	auipc	ra,0xfffff
    80005130:	fe4080e7          	jalr	-28(ra) # 80004110 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005134:	874a                	mv	a4,s2
    80005136:	5094                	lw	a3,32(s1)
    80005138:	864e                	mv	a2,s3
    8000513a:	4585                	li	a1,1
    8000513c:	6c88                	ld	a0,24(s1)
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	28a080e7          	jalr	650(ra) # 800043c8 <readi>
    80005146:	892a                	mv	s2,a0
    80005148:	00a05563          	blez	a0,80005152 <fileread+0x56>
      f->off += r;
    8000514c:	509c                	lw	a5,32(s1)
    8000514e:	9fa9                	addw	a5,a5,a0
    80005150:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005152:	6c88                	ld	a0,24(s1)
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	082080e7          	jalr	130(ra) # 800041d6 <iunlock>
    8000515c:	64e2                	ld	s1,24(sp)
    8000515e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005160:	854a                	mv	a0,s2
    80005162:	70a2                	ld	ra,40(sp)
    80005164:	7402                	ld	s0,32(sp)
    80005166:	6942                	ld	s2,16(sp)
    80005168:	6145                	addi	sp,sp,48
    8000516a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000516c:	6908                	ld	a0,16(a0)
    8000516e:	00000097          	auipc	ra,0x0
    80005172:	400080e7          	jalr	1024(ra) # 8000556e <piperead>
    80005176:	892a                	mv	s2,a0
    80005178:	64e2                	ld	s1,24(sp)
    8000517a:	69a2                	ld	s3,8(sp)
    8000517c:	b7d5                	j	80005160 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000517e:	02451783          	lh	a5,36(a0)
    80005182:	03079693          	slli	a3,a5,0x30
    80005186:	92c1                	srli	a3,a3,0x30
    80005188:	4725                	li	a4,9
    8000518a:	02d76a63          	bltu	a4,a3,800051be <fileread+0xc2>
    8000518e:	0792                	slli	a5,a5,0x4
    80005190:	00027717          	auipc	a4,0x27
    80005194:	8b070713          	addi	a4,a4,-1872 # 8002ba40 <devsw>
    80005198:	97ba                	add	a5,a5,a4
    8000519a:	639c                	ld	a5,0(a5)
    8000519c:	c78d                	beqz	a5,800051c6 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    8000519e:	4505                	li	a0,1
    800051a0:	9782                	jalr	a5
    800051a2:	892a                	mv	s2,a0
    800051a4:	64e2                	ld	s1,24(sp)
    800051a6:	69a2                	ld	s3,8(sp)
    800051a8:	bf65                	j	80005160 <fileread+0x64>
    panic("fileread");
    800051aa:	00003517          	auipc	a0,0x3
    800051ae:	58e50513          	addi	a0,a0,1422 # 80008738 <__func__.1+0x730>
    800051b2:	ffffb097          	auipc	ra,0xffffb
    800051b6:	3ae080e7          	jalr	942(ra) # 80000560 <panic>
    return -1;
    800051ba:	597d                	li	s2,-1
    800051bc:	b755                	j	80005160 <fileread+0x64>
      return -1;
    800051be:	597d                	li	s2,-1
    800051c0:	64e2                	ld	s1,24(sp)
    800051c2:	69a2                	ld	s3,8(sp)
    800051c4:	bf71                	j	80005160 <fileread+0x64>
    800051c6:	597d                	li	s2,-1
    800051c8:	64e2                	ld	s1,24(sp)
    800051ca:	69a2                	ld	s3,8(sp)
    800051cc:	bf51                	j	80005160 <fileread+0x64>

00000000800051ce <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800051ce:	00954783          	lbu	a5,9(a0)
    800051d2:	12078963          	beqz	a5,80005304 <filewrite+0x136>
{
    800051d6:	715d                	addi	sp,sp,-80
    800051d8:	e486                	sd	ra,72(sp)
    800051da:	e0a2                	sd	s0,64(sp)
    800051dc:	f84a                	sd	s2,48(sp)
    800051de:	f052                	sd	s4,32(sp)
    800051e0:	e85a                	sd	s6,16(sp)
    800051e2:	0880                	addi	s0,sp,80
    800051e4:	892a                	mv	s2,a0
    800051e6:	8b2e                	mv	s6,a1
    800051e8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800051ea:	411c                	lw	a5,0(a0)
    800051ec:	4705                	li	a4,1
    800051ee:	02e78763          	beq	a5,a4,8000521c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051f2:	470d                	li	a4,3
    800051f4:	02e78a63          	beq	a5,a4,80005228 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800051f8:	4709                	li	a4,2
    800051fa:	0ee79863          	bne	a5,a4,800052ea <filewrite+0x11c>
    800051fe:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005200:	0cc05463          	blez	a2,800052c8 <filewrite+0xfa>
    80005204:	fc26                	sd	s1,56(sp)
    80005206:	ec56                	sd	s5,24(sp)
    80005208:	e45e                	sd	s7,8(sp)
    8000520a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000520c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000520e:	6b85                	lui	s7,0x1
    80005210:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005214:	6c05                	lui	s8,0x1
    80005216:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000521a:	a851                	j	800052ae <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000521c:	6908                	ld	a0,16(a0)
    8000521e:	00000097          	auipc	ra,0x0
    80005222:	248080e7          	jalr	584(ra) # 80005466 <pipewrite>
    80005226:	a85d                	j	800052dc <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005228:	02451783          	lh	a5,36(a0)
    8000522c:	03079693          	slli	a3,a5,0x30
    80005230:	92c1                	srli	a3,a3,0x30
    80005232:	4725                	li	a4,9
    80005234:	0cd76a63          	bltu	a4,a3,80005308 <filewrite+0x13a>
    80005238:	0792                	slli	a5,a5,0x4
    8000523a:	00027717          	auipc	a4,0x27
    8000523e:	80670713          	addi	a4,a4,-2042 # 8002ba40 <devsw>
    80005242:	97ba                	add	a5,a5,a4
    80005244:	679c                	ld	a5,8(a5)
    80005246:	c3f9                	beqz	a5,8000530c <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80005248:	4505                	li	a0,1
    8000524a:	9782                	jalr	a5
    8000524c:	a841                	j	800052dc <filewrite+0x10e>
      if(n1 > max)
    8000524e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005252:	00000097          	auipc	ra,0x0
    80005256:	88c080e7          	jalr	-1908(ra) # 80004ade <begin_op>
      ilock(f->ip);
    8000525a:	01893503          	ld	a0,24(s2)
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	eb2080e7          	jalr	-334(ra) # 80004110 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005266:	8756                	mv	a4,s5
    80005268:	02092683          	lw	a3,32(s2)
    8000526c:	01698633          	add	a2,s3,s6
    80005270:	4585                	li	a1,1
    80005272:	01893503          	ld	a0,24(s2)
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	262080e7          	jalr	610(ra) # 800044d8 <writei>
    8000527e:	84aa                	mv	s1,a0
    80005280:	00a05763          	blez	a0,8000528e <filewrite+0xc0>
        f->off += r;
    80005284:	02092783          	lw	a5,32(s2)
    80005288:	9fa9                	addw	a5,a5,a0
    8000528a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000528e:	01893503          	ld	a0,24(s2)
    80005292:	fffff097          	auipc	ra,0xfffff
    80005296:	f44080e7          	jalr	-188(ra) # 800041d6 <iunlock>
      end_op();
    8000529a:	00000097          	auipc	ra,0x0
    8000529e:	8be080e7          	jalr	-1858(ra) # 80004b58 <end_op>

      if(r != n1){
    800052a2:	029a9563          	bne	s5,s1,800052cc <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    800052a6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800052aa:	0149da63          	bge	s3,s4,800052be <filewrite+0xf0>
      int n1 = n - i;
    800052ae:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800052b2:	0004879b          	sext.w	a5,s1
    800052b6:	f8fbdce3          	bge	s7,a5,8000524e <filewrite+0x80>
    800052ba:	84e2                	mv	s1,s8
    800052bc:	bf49                	j	8000524e <filewrite+0x80>
    800052be:	74e2                	ld	s1,56(sp)
    800052c0:	6ae2                	ld	s5,24(sp)
    800052c2:	6ba2                	ld	s7,8(sp)
    800052c4:	6c02                	ld	s8,0(sp)
    800052c6:	a039                	j	800052d4 <filewrite+0x106>
    int i = 0;
    800052c8:	4981                	li	s3,0
    800052ca:	a029                	j	800052d4 <filewrite+0x106>
    800052cc:	74e2                	ld	s1,56(sp)
    800052ce:	6ae2                	ld	s5,24(sp)
    800052d0:	6ba2                	ld	s7,8(sp)
    800052d2:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800052d4:	033a1e63          	bne	s4,s3,80005310 <filewrite+0x142>
    800052d8:	8552                	mv	a0,s4
    800052da:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800052dc:	60a6                	ld	ra,72(sp)
    800052de:	6406                	ld	s0,64(sp)
    800052e0:	7942                	ld	s2,48(sp)
    800052e2:	7a02                	ld	s4,32(sp)
    800052e4:	6b42                	ld	s6,16(sp)
    800052e6:	6161                	addi	sp,sp,80
    800052e8:	8082                	ret
    800052ea:	fc26                	sd	s1,56(sp)
    800052ec:	f44e                	sd	s3,40(sp)
    800052ee:	ec56                	sd	s5,24(sp)
    800052f0:	e45e                	sd	s7,8(sp)
    800052f2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800052f4:	00003517          	auipc	a0,0x3
    800052f8:	45450513          	addi	a0,a0,1108 # 80008748 <__func__.1+0x740>
    800052fc:	ffffb097          	auipc	ra,0xffffb
    80005300:	264080e7          	jalr	612(ra) # 80000560 <panic>
    return -1;
    80005304:	557d                	li	a0,-1
}
    80005306:	8082                	ret
      return -1;
    80005308:	557d                	li	a0,-1
    8000530a:	bfc9                	j	800052dc <filewrite+0x10e>
    8000530c:	557d                	li	a0,-1
    8000530e:	b7f9                	j	800052dc <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80005310:	557d                	li	a0,-1
    80005312:	79a2                	ld	s3,40(sp)
    80005314:	b7e1                	j	800052dc <filewrite+0x10e>

0000000080005316 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005316:	7179                	addi	sp,sp,-48
    80005318:	f406                	sd	ra,40(sp)
    8000531a:	f022                	sd	s0,32(sp)
    8000531c:	ec26                	sd	s1,24(sp)
    8000531e:	e052                	sd	s4,0(sp)
    80005320:	1800                	addi	s0,sp,48
    80005322:	84aa                	mv	s1,a0
    80005324:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005326:	0005b023          	sd	zero,0(a1)
    8000532a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000532e:	00000097          	auipc	ra,0x0
    80005332:	bbe080e7          	jalr	-1090(ra) # 80004eec <filealloc>
    80005336:	e088                	sd	a0,0(s1)
    80005338:	cd49                	beqz	a0,800053d2 <pipealloc+0xbc>
    8000533a:	00000097          	auipc	ra,0x0
    8000533e:	bb2080e7          	jalr	-1102(ra) # 80004eec <filealloc>
    80005342:	00aa3023          	sd	a0,0(s4)
    80005346:	c141                	beqz	a0,800053c6 <pipealloc+0xb0>
    80005348:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	93c080e7          	jalr	-1732(ra) # 80000c86 <kalloc>
    80005352:	892a                	mv	s2,a0
    80005354:	c13d                	beqz	a0,800053ba <pipealloc+0xa4>
    80005356:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80005358:	4985                	li	s3,1
    8000535a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000535e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005362:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005366:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000536a:	00003597          	auipc	a1,0x3
    8000536e:	3ee58593          	addi	a1,a1,1006 # 80008758 <__func__.1+0x750>
    80005372:	ffffc097          	auipc	ra,0xffffc
    80005376:	b34080e7          	jalr	-1228(ra) # 80000ea6 <initlock>
  (*f0)->type = FD_PIPE;
    8000537a:	609c                	ld	a5,0(s1)
    8000537c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005380:	609c                	ld	a5,0(s1)
    80005382:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005386:	609c                	ld	a5,0(s1)
    80005388:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000538c:	609c                	ld	a5,0(s1)
    8000538e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005392:	000a3783          	ld	a5,0(s4)
    80005396:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000539a:	000a3783          	ld	a5,0(s4)
    8000539e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800053a2:	000a3783          	ld	a5,0(s4)
    800053a6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800053aa:	000a3783          	ld	a5,0(s4)
    800053ae:	0127b823          	sd	s2,16(a5)
  return 0;
    800053b2:	4501                	li	a0,0
    800053b4:	6942                	ld	s2,16(sp)
    800053b6:	69a2                	ld	s3,8(sp)
    800053b8:	a03d                	j	800053e6 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800053ba:	6088                	ld	a0,0(s1)
    800053bc:	c119                	beqz	a0,800053c2 <pipealloc+0xac>
    800053be:	6942                	ld	s2,16(sp)
    800053c0:	a029                	j	800053ca <pipealloc+0xb4>
    800053c2:	6942                	ld	s2,16(sp)
    800053c4:	a039                	j	800053d2 <pipealloc+0xbc>
    800053c6:	6088                	ld	a0,0(s1)
    800053c8:	c50d                	beqz	a0,800053f2 <pipealloc+0xdc>
    fileclose(*f0);
    800053ca:	00000097          	auipc	ra,0x0
    800053ce:	bde080e7          	jalr	-1058(ra) # 80004fa8 <fileclose>
  if(*f1)
    800053d2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800053d6:	557d                	li	a0,-1
  if(*f1)
    800053d8:	c799                	beqz	a5,800053e6 <pipealloc+0xd0>
    fileclose(*f1);
    800053da:	853e                	mv	a0,a5
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	bcc080e7          	jalr	-1076(ra) # 80004fa8 <fileclose>
  return -1;
    800053e4:	557d                	li	a0,-1
}
    800053e6:	70a2                	ld	ra,40(sp)
    800053e8:	7402                	ld	s0,32(sp)
    800053ea:	64e2                	ld	s1,24(sp)
    800053ec:	6a02                	ld	s4,0(sp)
    800053ee:	6145                	addi	sp,sp,48
    800053f0:	8082                	ret
  return -1;
    800053f2:	557d                	li	a0,-1
    800053f4:	bfcd                	j	800053e6 <pipealloc+0xd0>

00000000800053f6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800053f6:	1101                	addi	sp,sp,-32
    800053f8:	ec06                	sd	ra,24(sp)
    800053fa:	e822                	sd	s0,16(sp)
    800053fc:	e426                	sd	s1,8(sp)
    800053fe:	e04a                	sd	s2,0(sp)
    80005400:	1000                	addi	s0,sp,32
    80005402:	84aa                	mv	s1,a0
    80005404:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005406:	ffffc097          	auipc	ra,0xffffc
    8000540a:	b30080e7          	jalr	-1232(ra) # 80000f36 <acquire>
  if(writable){
    8000540e:	02090d63          	beqz	s2,80005448 <pipeclose+0x52>
    pi->writeopen = 0;
    80005412:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005416:	21848513          	addi	a0,s1,536
    8000541a:	ffffd097          	auipc	ra,0xffffd
    8000541e:	3a4080e7          	jalr	932(ra) # 800027be <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005422:	2204b783          	ld	a5,544(s1)
    80005426:	eb95                	bnez	a5,8000545a <pipeclose+0x64>
    release(&pi->lock);
    80005428:	8526                	mv	a0,s1
    8000542a:	ffffc097          	auipc	ra,0xffffc
    8000542e:	bc0080e7          	jalr	-1088(ra) # 80000fea <release>
    kfree((char*)pi);
    80005432:	8526                	mv	a0,s1
    80005434:	ffffb097          	auipc	ra,0xffffb
    80005438:	660080e7          	jalr	1632(ra) # 80000a94 <kfree>
  } else
    release(&pi->lock);
}
    8000543c:	60e2                	ld	ra,24(sp)
    8000543e:	6442                	ld	s0,16(sp)
    80005440:	64a2                	ld	s1,8(sp)
    80005442:	6902                	ld	s2,0(sp)
    80005444:	6105                	addi	sp,sp,32
    80005446:	8082                	ret
    pi->readopen = 0;
    80005448:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000544c:	21c48513          	addi	a0,s1,540
    80005450:	ffffd097          	auipc	ra,0xffffd
    80005454:	36e080e7          	jalr	878(ra) # 800027be <wakeup>
    80005458:	b7e9                	j	80005422 <pipeclose+0x2c>
    release(&pi->lock);
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffc097          	auipc	ra,0xffffc
    80005460:	b8e080e7          	jalr	-1138(ra) # 80000fea <release>
}
    80005464:	bfe1                	j	8000543c <pipeclose+0x46>

0000000080005466 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005466:	711d                	addi	sp,sp,-96
    80005468:	ec86                	sd	ra,88(sp)
    8000546a:	e8a2                	sd	s0,80(sp)
    8000546c:	e4a6                	sd	s1,72(sp)
    8000546e:	e0ca                	sd	s2,64(sp)
    80005470:	fc4e                	sd	s3,56(sp)
    80005472:	f852                	sd	s4,48(sp)
    80005474:	f456                	sd	s5,40(sp)
    80005476:	1080                	addi	s0,sp,96
    80005478:	84aa                	mv	s1,a0
    8000547a:	8aae                	mv	s5,a1
    8000547c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000547e:	ffffd097          	auipc	ra,0xffffd
    80005482:	b2a080e7          	jalr	-1238(ra) # 80001fa8 <myproc>
    80005486:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005488:	8526                	mv	a0,s1
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	aac080e7          	jalr	-1364(ra) # 80000f36 <acquire>
  while(i < n){
    80005492:	0d405863          	blez	s4,80005562 <pipewrite+0xfc>
    80005496:	f05a                	sd	s6,32(sp)
    80005498:	ec5e                	sd	s7,24(sp)
    8000549a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000549c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000549e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800054a0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800054a4:	21c48b93          	addi	s7,s1,540
    800054a8:	a089                	j	800054ea <pipewrite+0x84>
      release(&pi->lock);
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffc097          	auipc	ra,0xffffc
    800054b0:	b3e080e7          	jalr	-1218(ra) # 80000fea <release>
      return -1;
    800054b4:	597d                	li	s2,-1
    800054b6:	7b02                	ld	s6,32(sp)
    800054b8:	6be2                	ld	s7,24(sp)
    800054ba:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800054bc:	854a                	mv	a0,s2
    800054be:	60e6                	ld	ra,88(sp)
    800054c0:	6446                	ld	s0,80(sp)
    800054c2:	64a6                	ld	s1,72(sp)
    800054c4:	6906                	ld	s2,64(sp)
    800054c6:	79e2                	ld	s3,56(sp)
    800054c8:	7a42                	ld	s4,48(sp)
    800054ca:	7aa2                	ld	s5,40(sp)
    800054cc:	6125                	addi	sp,sp,96
    800054ce:	8082                	ret
      wakeup(&pi->nread);
    800054d0:	8562                	mv	a0,s8
    800054d2:	ffffd097          	auipc	ra,0xffffd
    800054d6:	2ec080e7          	jalr	748(ra) # 800027be <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800054da:	85a6                	mv	a1,s1
    800054dc:	855e                	mv	a0,s7
    800054de:	ffffd097          	auipc	ra,0xffffd
    800054e2:	27c080e7          	jalr	636(ra) # 8000275a <sleep>
  while(i < n){
    800054e6:	05495f63          	bge	s2,s4,80005544 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    800054ea:	2204a783          	lw	a5,544(s1)
    800054ee:	dfd5                	beqz	a5,800054aa <pipewrite+0x44>
    800054f0:	854e                	mv	a0,s3
    800054f2:	ffffd097          	auipc	ra,0xffffd
    800054f6:	510080e7          	jalr	1296(ra) # 80002a02 <killed>
    800054fa:	f945                	bnez	a0,800054aa <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800054fc:	2184a783          	lw	a5,536(s1)
    80005500:	21c4a703          	lw	a4,540(s1)
    80005504:	2007879b          	addiw	a5,a5,512
    80005508:	fcf704e3          	beq	a4,a5,800054d0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000550c:	4685                	li	a3,1
    8000550e:	01590633          	add	a2,s2,s5
    80005512:	faf40593          	addi	a1,s0,-81
    80005516:	0509b503          	ld	a0,80(s3)
    8000551a:	ffffc097          	auipc	ra,0xffffc
    8000551e:	558080e7          	jalr	1368(ra) # 80001a72 <copyin>
    80005522:	05650263          	beq	a0,s6,80005566 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005526:	21c4a783          	lw	a5,540(s1)
    8000552a:	0017871b          	addiw	a4,a5,1
    8000552e:	20e4ae23          	sw	a4,540(s1)
    80005532:	1ff7f793          	andi	a5,a5,511
    80005536:	97a6                	add	a5,a5,s1
    80005538:	faf44703          	lbu	a4,-81(s0)
    8000553c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005540:	2905                	addiw	s2,s2,1
    80005542:	b755                	j	800054e6 <pipewrite+0x80>
    80005544:	7b02                	ld	s6,32(sp)
    80005546:	6be2                	ld	s7,24(sp)
    80005548:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000554a:	21848513          	addi	a0,s1,536
    8000554e:	ffffd097          	auipc	ra,0xffffd
    80005552:	270080e7          	jalr	624(ra) # 800027be <wakeup>
  release(&pi->lock);
    80005556:	8526                	mv	a0,s1
    80005558:	ffffc097          	auipc	ra,0xffffc
    8000555c:	a92080e7          	jalr	-1390(ra) # 80000fea <release>
  return i;
    80005560:	bfb1                	j	800054bc <pipewrite+0x56>
  int i = 0;
    80005562:	4901                	li	s2,0
    80005564:	b7dd                	j	8000554a <pipewrite+0xe4>
    80005566:	7b02                	ld	s6,32(sp)
    80005568:	6be2                	ld	s7,24(sp)
    8000556a:	6c42                	ld	s8,16(sp)
    8000556c:	bff9                	j	8000554a <pipewrite+0xe4>

000000008000556e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000556e:	715d                	addi	sp,sp,-80
    80005570:	e486                	sd	ra,72(sp)
    80005572:	e0a2                	sd	s0,64(sp)
    80005574:	fc26                	sd	s1,56(sp)
    80005576:	f84a                	sd	s2,48(sp)
    80005578:	f44e                	sd	s3,40(sp)
    8000557a:	f052                	sd	s4,32(sp)
    8000557c:	ec56                	sd	s5,24(sp)
    8000557e:	0880                	addi	s0,sp,80
    80005580:	84aa                	mv	s1,a0
    80005582:	892e                	mv	s2,a1
    80005584:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005586:	ffffd097          	auipc	ra,0xffffd
    8000558a:	a22080e7          	jalr	-1502(ra) # 80001fa8 <myproc>
    8000558e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005590:	8526                	mv	a0,s1
    80005592:	ffffc097          	auipc	ra,0xffffc
    80005596:	9a4080e7          	jalr	-1628(ra) # 80000f36 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000559a:	2184a703          	lw	a4,536(s1)
    8000559e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055a2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055a6:	02f71963          	bne	a4,a5,800055d8 <piperead+0x6a>
    800055aa:	2244a783          	lw	a5,548(s1)
    800055ae:	cf95                	beqz	a5,800055ea <piperead+0x7c>
    if(killed(pr)){
    800055b0:	8552                	mv	a0,s4
    800055b2:	ffffd097          	auipc	ra,0xffffd
    800055b6:	450080e7          	jalr	1104(ra) # 80002a02 <killed>
    800055ba:	e10d                	bnez	a0,800055dc <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055bc:	85a6                	mv	a1,s1
    800055be:	854e                	mv	a0,s3
    800055c0:	ffffd097          	auipc	ra,0xffffd
    800055c4:	19a080e7          	jalr	410(ra) # 8000275a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055c8:	2184a703          	lw	a4,536(s1)
    800055cc:	21c4a783          	lw	a5,540(s1)
    800055d0:	fcf70de3          	beq	a4,a5,800055aa <piperead+0x3c>
    800055d4:	e85a                	sd	s6,16(sp)
    800055d6:	a819                	j	800055ec <piperead+0x7e>
    800055d8:	e85a                	sd	s6,16(sp)
    800055da:	a809                	j	800055ec <piperead+0x7e>
      release(&pi->lock);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffc097          	auipc	ra,0xffffc
    800055e2:	a0c080e7          	jalr	-1524(ra) # 80000fea <release>
      return -1;
    800055e6:	59fd                	li	s3,-1
    800055e8:	a0a5                	j	80005650 <piperead+0xe2>
    800055ea:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800055ec:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800055ee:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800055f0:	05505463          	blez	s5,80005638 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    800055f4:	2184a783          	lw	a5,536(s1)
    800055f8:	21c4a703          	lw	a4,540(s1)
    800055fc:	02f70e63          	beq	a4,a5,80005638 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005600:	0017871b          	addiw	a4,a5,1
    80005604:	20e4ac23          	sw	a4,536(s1)
    80005608:	1ff7f793          	andi	a5,a5,511
    8000560c:	97a6                	add	a5,a5,s1
    8000560e:	0187c783          	lbu	a5,24(a5)
    80005612:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005616:	4685                	li	a3,1
    80005618:	fbf40613          	addi	a2,s0,-65
    8000561c:	85ca                	mv	a1,s2
    8000561e:	050a3503          	ld	a0,80(s4)
    80005622:	ffffc097          	auipc	ra,0xffffc
    80005626:	3c4080e7          	jalr	964(ra) # 800019e6 <copyout>
    8000562a:	01650763          	beq	a0,s6,80005638 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000562e:	2985                	addiw	s3,s3,1
    80005630:	0905                	addi	s2,s2,1
    80005632:	fd3a91e3          	bne	s5,s3,800055f4 <piperead+0x86>
    80005636:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005638:	21c48513          	addi	a0,s1,540
    8000563c:	ffffd097          	auipc	ra,0xffffd
    80005640:	182080e7          	jalr	386(ra) # 800027be <wakeup>
  release(&pi->lock);
    80005644:	8526                	mv	a0,s1
    80005646:	ffffc097          	auipc	ra,0xffffc
    8000564a:	9a4080e7          	jalr	-1628(ra) # 80000fea <release>
    8000564e:	6b42                	ld	s6,16(sp)
  return i;
}
    80005650:	854e                	mv	a0,s3
    80005652:	60a6                	ld	ra,72(sp)
    80005654:	6406                	ld	s0,64(sp)
    80005656:	74e2                	ld	s1,56(sp)
    80005658:	7942                	ld	s2,48(sp)
    8000565a:	79a2                	ld	s3,40(sp)
    8000565c:	7a02                	ld	s4,32(sp)
    8000565e:	6ae2                	ld	s5,24(sp)
    80005660:	6161                	addi	sp,sp,80
    80005662:	8082                	ret

0000000080005664 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005664:	1141                	addi	sp,sp,-16
    80005666:	e422                	sd	s0,8(sp)
    80005668:	0800                	addi	s0,sp,16
    8000566a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000566c:	8905                	andi	a0,a0,1
    8000566e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005670:	8b89                	andi	a5,a5,2
    80005672:	c399                	beqz	a5,80005678 <flags2perm+0x14>
      perm |= PTE_W;
    80005674:	00456513          	ori	a0,a0,4
    return perm;
}
    80005678:	6422                	ld	s0,8(sp)
    8000567a:	0141                	addi	sp,sp,16
    8000567c:	8082                	ret

000000008000567e <exec>:

int
exec(char *path, char **argv)
{
    8000567e:	df010113          	addi	sp,sp,-528
    80005682:	20113423          	sd	ra,520(sp)
    80005686:	20813023          	sd	s0,512(sp)
    8000568a:	ffa6                	sd	s1,504(sp)
    8000568c:	fbca                	sd	s2,496(sp)
    8000568e:	0c00                	addi	s0,sp,528
    80005690:	892a                	mv	s2,a0
    80005692:	dea43c23          	sd	a0,-520(s0)
    80005696:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000569a:	ffffd097          	auipc	ra,0xffffd
    8000569e:	90e080e7          	jalr	-1778(ra) # 80001fa8 <myproc>
    800056a2:	84aa                	mv	s1,a0

  begin_op();
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	43a080e7          	jalr	1082(ra) # 80004ade <begin_op>

  if((ip = namei(path)) == 0){
    800056ac:	854a                	mv	a0,s2
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	230080e7          	jalr	560(ra) # 800048de <namei>
    800056b6:	c135                	beqz	a0,8000571a <exec+0x9c>
    800056b8:	f3d2                	sd	s4,480(sp)
    800056ba:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	a54080e7          	jalr	-1452(ra) # 80004110 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800056c4:	04000713          	li	a4,64
    800056c8:	4681                	li	a3,0
    800056ca:	e5040613          	addi	a2,s0,-432
    800056ce:	4581                	li	a1,0
    800056d0:	8552                	mv	a0,s4
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	cf6080e7          	jalr	-778(ra) # 800043c8 <readi>
    800056da:	04000793          	li	a5,64
    800056de:	00f51a63          	bne	a0,a5,800056f2 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800056e2:	e5042703          	lw	a4,-432(s0)
    800056e6:	464c47b7          	lui	a5,0x464c4
    800056ea:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800056ee:	02f70c63          	beq	a4,a5,80005726 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800056f2:	8552                	mv	a0,s4
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	c82080e7          	jalr	-894(ra) # 80004376 <iunlockput>
    end_op();
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	45c080e7          	jalr	1116(ra) # 80004b58 <end_op>
  }
  return -1;
    80005704:	557d                	li	a0,-1
    80005706:	7a1e                	ld	s4,480(sp)
}
    80005708:	20813083          	ld	ra,520(sp)
    8000570c:	20013403          	ld	s0,512(sp)
    80005710:	74fe                	ld	s1,504(sp)
    80005712:	795e                	ld	s2,496(sp)
    80005714:	21010113          	addi	sp,sp,528
    80005718:	8082                	ret
    end_op();
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	43e080e7          	jalr	1086(ra) # 80004b58 <end_op>
    return -1;
    80005722:	557d                	li	a0,-1
    80005724:	b7d5                	j	80005708 <exec+0x8a>
    80005726:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	942080e7          	jalr	-1726(ra) # 8000206c <proc_pagetable>
    80005732:	8b2a                	mv	s6,a0
    80005734:	30050f63          	beqz	a0,80005a52 <exec+0x3d4>
    80005738:	f7ce                	sd	s3,488(sp)
    8000573a:	efd6                	sd	s5,472(sp)
    8000573c:	e7de                	sd	s7,456(sp)
    8000573e:	e3e2                	sd	s8,448(sp)
    80005740:	ff66                	sd	s9,440(sp)
    80005742:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005744:	e7042d03          	lw	s10,-400(s0)
    80005748:	e8845783          	lhu	a5,-376(s0)
    8000574c:	14078d63          	beqz	a5,800058a6 <exec+0x228>
    80005750:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005752:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005754:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005756:	6c85                	lui	s9,0x1
    80005758:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000575c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005760:	6a85                	lui	s5,0x1
    80005762:	a0b5                	j	800057ce <exec+0x150>
      panic("loadseg: address should exist");
    80005764:	00003517          	auipc	a0,0x3
    80005768:	ffc50513          	addi	a0,a0,-4 # 80008760 <__func__.1+0x758>
    8000576c:	ffffb097          	auipc	ra,0xffffb
    80005770:	df4080e7          	jalr	-524(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005774:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005776:	8726                	mv	a4,s1
    80005778:	012c06bb          	addw	a3,s8,s2
    8000577c:	4581                	li	a1,0
    8000577e:	8552                	mv	a0,s4
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	c48080e7          	jalr	-952(ra) # 800043c8 <readi>
    80005788:	2501                	sext.w	a0,a0
    8000578a:	28a49863          	bne	s1,a0,80005a1a <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    8000578e:	012a893b          	addw	s2,s5,s2
    80005792:	03397563          	bgeu	s2,s3,800057bc <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005796:	02091593          	slli	a1,s2,0x20
    8000579a:	9181                	srli	a1,a1,0x20
    8000579c:	95de                	add	a1,a1,s7
    8000579e:	855a                	mv	a0,s6
    800057a0:	ffffc097          	auipc	ra,0xffffc
    800057a4:	c14080e7          	jalr	-1004(ra) # 800013b4 <walkaddr>
    800057a8:	862a                	mv	a2,a0
    if(pa == 0)
    800057aa:	dd4d                	beqz	a0,80005764 <exec+0xe6>
    if(sz - i < PGSIZE)
    800057ac:	412984bb          	subw	s1,s3,s2
    800057b0:	0004879b          	sext.w	a5,s1
    800057b4:	fcfcf0e3          	bgeu	s9,a5,80005774 <exec+0xf6>
    800057b8:	84d6                	mv	s1,s5
    800057ba:	bf6d                	j	80005774 <exec+0xf6>
    sz = sz1;
    800057bc:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057c0:	2d85                	addiw	s11,s11,1
    800057c2:	038d0d1b          	addiw	s10,s10,56
    800057c6:	e8845783          	lhu	a5,-376(s0)
    800057ca:	08fdd663          	bge	s11,a5,80005856 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057ce:	2d01                	sext.w	s10,s10
    800057d0:	03800713          	li	a4,56
    800057d4:	86ea                	mv	a3,s10
    800057d6:	e1840613          	addi	a2,s0,-488
    800057da:	4581                	li	a1,0
    800057dc:	8552                	mv	a0,s4
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	bea080e7          	jalr	-1046(ra) # 800043c8 <readi>
    800057e6:	03800793          	li	a5,56
    800057ea:	20f51063          	bne	a0,a5,800059ea <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    800057ee:	e1842783          	lw	a5,-488(s0)
    800057f2:	4705                	li	a4,1
    800057f4:	fce796e3          	bne	a5,a4,800057c0 <exec+0x142>
    if(ph.memsz < ph.filesz)
    800057f8:	e4043483          	ld	s1,-448(s0)
    800057fc:	e3843783          	ld	a5,-456(s0)
    80005800:	1ef4e963          	bltu	s1,a5,800059f2 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005804:	e2843783          	ld	a5,-472(s0)
    80005808:	94be                	add	s1,s1,a5
    8000580a:	1ef4e863          	bltu	s1,a5,800059fa <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    8000580e:	df043703          	ld	a4,-528(s0)
    80005812:	8ff9                	and	a5,a5,a4
    80005814:	1e079763          	bnez	a5,80005a02 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005818:	e1c42503          	lw	a0,-484(s0)
    8000581c:	00000097          	auipc	ra,0x0
    80005820:	e48080e7          	jalr	-440(ra) # 80005664 <flags2perm>
    80005824:	86aa                	mv	a3,a0
    80005826:	8626                	mv	a2,s1
    80005828:	85ca                	mv	a1,s2
    8000582a:	855a                	mv	a0,s6
    8000582c:	ffffc097          	auipc	ra,0xffffc
    80005830:	f4c080e7          	jalr	-180(ra) # 80001778 <uvmalloc>
    80005834:	e0a43423          	sd	a0,-504(s0)
    80005838:	1c050963          	beqz	a0,80005a0a <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000583c:	e2843b83          	ld	s7,-472(s0)
    80005840:	e2042c03          	lw	s8,-480(s0)
    80005844:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005848:	00098463          	beqz	s3,80005850 <exec+0x1d2>
    8000584c:	4901                	li	s2,0
    8000584e:	b7a1                	j	80005796 <exec+0x118>
    sz = sz1;
    80005850:	e0843903          	ld	s2,-504(s0)
    80005854:	b7b5                	j	800057c0 <exec+0x142>
    80005856:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005858:	8552                	mv	a0,s4
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	b1c080e7          	jalr	-1252(ra) # 80004376 <iunlockput>
  end_op();
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	2f6080e7          	jalr	758(ra) # 80004b58 <end_op>
  p = myproc();
    8000586a:	ffffc097          	auipc	ra,0xffffc
    8000586e:	73e080e7          	jalr	1854(ra) # 80001fa8 <myproc>
    80005872:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005874:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005878:	6985                	lui	s3,0x1
    8000587a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000587c:	99ca                	add	s3,s3,s2
    8000587e:	77fd                	lui	a5,0xfffff
    80005880:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005884:	4691                	li	a3,4
    80005886:	6609                	lui	a2,0x2
    80005888:	964e                	add	a2,a2,s3
    8000588a:	85ce                	mv	a1,s3
    8000588c:	855a                	mv	a0,s6
    8000588e:	ffffc097          	auipc	ra,0xffffc
    80005892:	eea080e7          	jalr	-278(ra) # 80001778 <uvmalloc>
    80005896:	892a                	mv	s2,a0
    80005898:	e0a43423          	sd	a0,-504(s0)
    8000589c:	e519                	bnez	a0,800058aa <exec+0x22c>
  if(pagetable)
    8000589e:	e1343423          	sd	s3,-504(s0)
    800058a2:	4a01                	li	s4,0
    800058a4:	aaa5                	j	80005a1c <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800058a6:	4901                	li	s2,0
    800058a8:	bf45                	j	80005858 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    800058aa:	75f9                	lui	a1,0xffffe
    800058ac:	95aa                	add	a1,a1,a0
    800058ae:	855a                	mv	a0,s6
    800058b0:	ffffc097          	auipc	ra,0xffffc
    800058b4:	104080e7          	jalr	260(ra) # 800019b4 <uvmclear>
  stackbase = sp - PGSIZE;
    800058b8:	7bfd                	lui	s7,0xfffff
    800058ba:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800058bc:	e0043783          	ld	a5,-512(s0)
    800058c0:	6388                	ld	a0,0(a5)
    800058c2:	c52d                	beqz	a0,8000592c <exec+0x2ae>
    800058c4:	e9040993          	addi	s3,s0,-368
    800058c8:	f9040c13          	addi	s8,s0,-112
    800058cc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800058ce:	ffffc097          	auipc	ra,0xffffc
    800058d2:	8d8080e7          	jalr	-1832(ra) # 800011a6 <strlen>
    800058d6:	0015079b          	addiw	a5,a0,1
    800058da:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800058de:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800058e2:	13796863          	bltu	s2,s7,80005a12 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800058e6:	e0043d03          	ld	s10,-512(s0)
    800058ea:	000d3a03          	ld	s4,0(s10)
    800058ee:	8552                	mv	a0,s4
    800058f0:	ffffc097          	auipc	ra,0xffffc
    800058f4:	8b6080e7          	jalr	-1866(ra) # 800011a6 <strlen>
    800058f8:	0015069b          	addiw	a3,a0,1
    800058fc:	8652                	mv	a2,s4
    800058fe:	85ca                	mv	a1,s2
    80005900:	855a                	mv	a0,s6
    80005902:	ffffc097          	auipc	ra,0xffffc
    80005906:	0e4080e7          	jalr	228(ra) # 800019e6 <copyout>
    8000590a:	10054663          	bltz	a0,80005a16 <exec+0x398>
    ustack[argc] = sp;
    8000590e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005912:	0485                	addi	s1,s1,1
    80005914:	008d0793          	addi	a5,s10,8
    80005918:	e0f43023          	sd	a5,-512(s0)
    8000591c:	008d3503          	ld	a0,8(s10)
    80005920:	c909                	beqz	a0,80005932 <exec+0x2b4>
    if(argc >= MAXARG)
    80005922:	09a1                	addi	s3,s3,8
    80005924:	fb8995e3          	bne	s3,s8,800058ce <exec+0x250>
  ip = 0;
    80005928:	4a01                	li	s4,0
    8000592a:	a8cd                	j	80005a1c <exec+0x39e>
  sp = sz;
    8000592c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005930:	4481                	li	s1,0
  ustack[argc] = 0;
    80005932:	00349793          	slli	a5,s1,0x3
    80005936:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd23b8>
    8000593a:	97a2                	add	a5,a5,s0
    8000593c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005940:	00148693          	addi	a3,s1,1
    80005944:	068e                	slli	a3,a3,0x3
    80005946:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000594a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000594e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005952:	f57966e3          	bltu	s2,s7,8000589e <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005956:	e9040613          	addi	a2,s0,-368
    8000595a:	85ca                	mv	a1,s2
    8000595c:	855a                	mv	a0,s6
    8000595e:	ffffc097          	auipc	ra,0xffffc
    80005962:	088080e7          	jalr	136(ra) # 800019e6 <copyout>
    80005966:	0e054863          	bltz	a0,80005a56 <exec+0x3d8>
  p->trapframe->a1 = sp;
    8000596a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000596e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005972:	df843783          	ld	a5,-520(s0)
    80005976:	0007c703          	lbu	a4,0(a5)
    8000597a:	cf11                	beqz	a4,80005996 <exec+0x318>
    8000597c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000597e:	02f00693          	li	a3,47
    80005982:	a039                	j	80005990 <exec+0x312>
      last = s+1;
    80005984:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005988:	0785                	addi	a5,a5,1
    8000598a:	fff7c703          	lbu	a4,-1(a5)
    8000598e:	c701                	beqz	a4,80005996 <exec+0x318>
    if(*s == '/')
    80005990:	fed71ce3          	bne	a4,a3,80005988 <exec+0x30a>
    80005994:	bfc5                	j	80005984 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005996:	4641                	li	a2,16
    80005998:	df843583          	ld	a1,-520(s0)
    8000599c:	158a8513          	addi	a0,s5,344
    800059a0:	ffffb097          	auipc	ra,0xffffb
    800059a4:	7d4080e7          	jalr	2004(ra) # 80001174 <safestrcpy>
  oldpagetable = p->pagetable;
    800059a8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800059ac:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800059b0:	e0843783          	ld	a5,-504(s0)
    800059b4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800059b8:	058ab783          	ld	a5,88(s5)
    800059bc:	e6843703          	ld	a4,-408(s0)
    800059c0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800059c2:	058ab783          	ld	a5,88(s5)
    800059c6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800059ca:	85e6                	mv	a1,s9
    800059cc:	ffffc097          	auipc	ra,0xffffc
    800059d0:	73c080e7          	jalr	1852(ra) # 80002108 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800059d4:	0004851b          	sext.w	a0,s1
    800059d8:	79be                	ld	s3,488(sp)
    800059da:	7a1e                	ld	s4,480(sp)
    800059dc:	6afe                	ld	s5,472(sp)
    800059de:	6b5e                	ld	s6,464(sp)
    800059e0:	6bbe                	ld	s7,456(sp)
    800059e2:	6c1e                	ld	s8,448(sp)
    800059e4:	7cfa                	ld	s9,440(sp)
    800059e6:	7d5a                	ld	s10,432(sp)
    800059e8:	b305                	j	80005708 <exec+0x8a>
    800059ea:	e1243423          	sd	s2,-504(s0)
    800059ee:	7dba                	ld	s11,424(sp)
    800059f0:	a035                	j	80005a1c <exec+0x39e>
    800059f2:	e1243423          	sd	s2,-504(s0)
    800059f6:	7dba                	ld	s11,424(sp)
    800059f8:	a015                	j	80005a1c <exec+0x39e>
    800059fa:	e1243423          	sd	s2,-504(s0)
    800059fe:	7dba                	ld	s11,424(sp)
    80005a00:	a831                	j	80005a1c <exec+0x39e>
    80005a02:	e1243423          	sd	s2,-504(s0)
    80005a06:	7dba                	ld	s11,424(sp)
    80005a08:	a811                	j	80005a1c <exec+0x39e>
    80005a0a:	e1243423          	sd	s2,-504(s0)
    80005a0e:	7dba                	ld	s11,424(sp)
    80005a10:	a031                	j	80005a1c <exec+0x39e>
  ip = 0;
    80005a12:	4a01                	li	s4,0
    80005a14:	a021                	j	80005a1c <exec+0x39e>
    80005a16:	4a01                	li	s4,0
  if(pagetable)
    80005a18:	a011                	j	80005a1c <exec+0x39e>
    80005a1a:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005a1c:	e0843583          	ld	a1,-504(s0)
    80005a20:	855a                	mv	a0,s6
    80005a22:	ffffc097          	auipc	ra,0xffffc
    80005a26:	6e6080e7          	jalr	1766(ra) # 80002108 <proc_freepagetable>
  return -1;
    80005a2a:	557d                	li	a0,-1
  if(ip){
    80005a2c:	000a1b63          	bnez	s4,80005a42 <exec+0x3c4>
    80005a30:	79be                	ld	s3,488(sp)
    80005a32:	7a1e                	ld	s4,480(sp)
    80005a34:	6afe                	ld	s5,472(sp)
    80005a36:	6b5e                	ld	s6,464(sp)
    80005a38:	6bbe                	ld	s7,456(sp)
    80005a3a:	6c1e                	ld	s8,448(sp)
    80005a3c:	7cfa                	ld	s9,440(sp)
    80005a3e:	7d5a                	ld	s10,432(sp)
    80005a40:	b1e1                	j	80005708 <exec+0x8a>
    80005a42:	79be                	ld	s3,488(sp)
    80005a44:	6afe                	ld	s5,472(sp)
    80005a46:	6b5e                	ld	s6,464(sp)
    80005a48:	6bbe                	ld	s7,456(sp)
    80005a4a:	6c1e                	ld	s8,448(sp)
    80005a4c:	7cfa                	ld	s9,440(sp)
    80005a4e:	7d5a                	ld	s10,432(sp)
    80005a50:	b14d                	j	800056f2 <exec+0x74>
    80005a52:	6b5e                	ld	s6,464(sp)
    80005a54:	b979                	j	800056f2 <exec+0x74>
  sz = sz1;
    80005a56:	e0843983          	ld	s3,-504(s0)
    80005a5a:	b591                	j	8000589e <exec+0x220>

0000000080005a5c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a5c:	7179                	addi	sp,sp,-48
    80005a5e:	f406                	sd	ra,40(sp)
    80005a60:	f022                	sd	s0,32(sp)
    80005a62:	ec26                	sd	s1,24(sp)
    80005a64:	e84a                	sd	s2,16(sp)
    80005a66:	1800                	addi	s0,sp,48
    80005a68:	892e                	mv	s2,a1
    80005a6a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005a6c:	fdc40593          	addi	a1,s0,-36
    80005a70:	ffffe097          	auipc	ra,0xffffe
    80005a74:	986080e7          	jalr	-1658(ra) # 800033f6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a78:	fdc42703          	lw	a4,-36(s0)
    80005a7c:	47bd                	li	a5,15
    80005a7e:	02e7eb63          	bltu	a5,a4,80005ab4 <argfd+0x58>
    80005a82:	ffffc097          	auipc	ra,0xffffc
    80005a86:	526080e7          	jalr	1318(ra) # 80001fa8 <myproc>
    80005a8a:	fdc42703          	lw	a4,-36(s0)
    80005a8e:	01a70793          	addi	a5,a4,26
    80005a92:	078e                	slli	a5,a5,0x3
    80005a94:	953e                	add	a0,a0,a5
    80005a96:	611c                	ld	a5,0(a0)
    80005a98:	c385                	beqz	a5,80005ab8 <argfd+0x5c>
    return -1;
  if(pfd)
    80005a9a:	00090463          	beqz	s2,80005aa2 <argfd+0x46>
    *pfd = fd;
    80005a9e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005aa2:	4501                	li	a0,0
  if(pf)
    80005aa4:	c091                	beqz	s1,80005aa8 <argfd+0x4c>
    *pf = f;
    80005aa6:	e09c                	sd	a5,0(s1)
}
    80005aa8:	70a2                	ld	ra,40(sp)
    80005aaa:	7402                	ld	s0,32(sp)
    80005aac:	64e2                	ld	s1,24(sp)
    80005aae:	6942                	ld	s2,16(sp)
    80005ab0:	6145                	addi	sp,sp,48
    80005ab2:	8082                	ret
    return -1;
    80005ab4:	557d                	li	a0,-1
    80005ab6:	bfcd                	j	80005aa8 <argfd+0x4c>
    80005ab8:	557d                	li	a0,-1
    80005aba:	b7fd                	j	80005aa8 <argfd+0x4c>

0000000080005abc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005abc:	1101                	addi	sp,sp,-32
    80005abe:	ec06                	sd	ra,24(sp)
    80005ac0:	e822                	sd	s0,16(sp)
    80005ac2:	e426                	sd	s1,8(sp)
    80005ac4:	1000                	addi	s0,sp,32
    80005ac6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ac8:	ffffc097          	auipc	ra,0xffffc
    80005acc:	4e0080e7          	jalr	1248(ra) # 80001fa8 <myproc>
    80005ad0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005ad2:	0d050793          	addi	a5,a0,208
    80005ad6:	4501                	li	a0,0
    80005ad8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005ada:	6398                	ld	a4,0(a5)
    80005adc:	cb19                	beqz	a4,80005af2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005ade:	2505                	addiw	a0,a0,1
    80005ae0:	07a1                	addi	a5,a5,8
    80005ae2:	fed51ce3          	bne	a0,a3,80005ada <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005ae6:	557d                	li	a0,-1
}
    80005ae8:	60e2                	ld	ra,24(sp)
    80005aea:	6442                	ld	s0,16(sp)
    80005aec:	64a2                	ld	s1,8(sp)
    80005aee:	6105                	addi	sp,sp,32
    80005af0:	8082                	ret
      p->ofile[fd] = f;
    80005af2:	01a50793          	addi	a5,a0,26
    80005af6:	078e                	slli	a5,a5,0x3
    80005af8:	963e                	add	a2,a2,a5
    80005afa:	e204                	sd	s1,0(a2)
      return fd;
    80005afc:	b7f5                	j	80005ae8 <fdalloc+0x2c>

0000000080005afe <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005afe:	715d                	addi	sp,sp,-80
    80005b00:	e486                	sd	ra,72(sp)
    80005b02:	e0a2                	sd	s0,64(sp)
    80005b04:	fc26                	sd	s1,56(sp)
    80005b06:	f84a                	sd	s2,48(sp)
    80005b08:	f44e                	sd	s3,40(sp)
    80005b0a:	ec56                	sd	s5,24(sp)
    80005b0c:	e85a                	sd	s6,16(sp)
    80005b0e:	0880                	addi	s0,sp,80
    80005b10:	8b2e                	mv	s6,a1
    80005b12:	89b2                	mv	s3,a2
    80005b14:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005b16:	fb040593          	addi	a1,s0,-80
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	de2080e7          	jalr	-542(ra) # 800048fc <nameiparent>
    80005b22:	84aa                	mv	s1,a0
    80005b24:	14050e63          	beqz	a0,80005c80 <create+0x182>
    return 0;

  ilock(dp);
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	5e8080e7          	jalr	1512(ra) # 80004110 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005b30:	4601                	li	a2,0
    80005b32:	fb040593          	addi	a1,s0,-80
    80005b36:	8526                	mv	a0,s1
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	ae4080e7          	jalr	-1308(ra) # 8000461c <dirlookup>
    80005b40:	8aaa                	mv	s5,a0
    80005b42:	c539                	beqz	a0,80005b90 <create+0x92>
    iunlockput(dp);
    80005b44:	8526                	mv	a0,s1
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	830080e7          	jalr	-2000(ra) # 80004376 <iunlockput>
    ilock(ip);
    80005b4e:	8556                	mv	a0,s5
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	5c0080e7          	jalr	1472(ra) # 80004110 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b58:	4789                	li	a5,2
    80005b5a:	02fb1463          	bne	s6,a5,80005b82 <create+0x84>
    80005b5e:	044ad783          	lhu	a5,68(s5)
    80005b62:	37f9                	addiw	a5,a5,-2
    80005b64:	17c2                	slli	a5,a5,0x30
    80005b66:	93c1                	srli	a5,a5,0x30
    80005b68:	4705                	li	a4,1
    80005b6a:	00f76c63          	bltu	a4,a5,80005b82 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b6e:	8556                	mv	a0,s5
    80005b70:	60a6                	ld	ra,72(sp)
    80005b72:	6406                	ld	s0,64(sp)
    80005b74:	74e2                	ld	s1,56(sp)
    80005b76:	7942                	ld	s2,48(sp)
    80005b78:	79a2                	ld	s3,40(sp)
    80005b7a:	6ae2                	ld	s5,24(sp)
    80005b7c:	6b42                	ld	s6,16(sp)
    80005b7e:	6161                	addi	sp,sp,80
    80005b80:	8082                	ret
    iunlockput(ip);
    80005b82:	8556                	mv	a0,s5
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	7f2080e7          	jalr	2034(ra) # 80004376 <iunlockput>
    return 0;
    80005b8c:	4a81                	li	s5,0
    80005b8e:	b7c5                	j	80005b6e <create+0x70>
    80005b90:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005b92:	85da                	mv	a1,s6
    80005b94:	4088                	lw	a0,0(s1)
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	3d6080e7          	jalr	982(ra) # 80003f6c <ialloc>
    80005b9e:	8a2a                	mv	s4,a0
    80005ba0:	c531                	beqz	a0,80005bec <create+0xee>
  ilock(ip);
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	56e080e7          	jalr	1390(ra) # 80004110 <ilock>
  ip->major = major;
    80005baa:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005bae:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005bb2:	4905                	li	s2,1
    80005bb4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005bb8:	8552                	mv	a0,s4
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	48a080e7          	jalr	1162(ra) # 80004044 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005bc2:	032b0d63          	beq	s6,s2,80005bfc <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bc6:	004a2603          	lw	a2,4(s4)
    80005bca:	fb040593          	addi	a1,s0,-80
    80005bce:	8526                	mv	a0,s1
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	c5c080e7          	jalr	-932(ra) # 8000482c <dirlink>
    80005bd8:	08054163          	bltz	a0,80005c5a <create+0x15c>
  iunlockput(dp);
    80005bdc:	8526                	mv	a0,s1
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	798080e7          	jalr	1944(ra) # 80004376 <iunlockput>
  return ip;
    80005be6:	8ad2                	mv	s5,s4
    80005be8:	7a02                	ld	s4,32(sp)
    80005bea:	b751                	j	80005b6e <create+0x70>
    iunlockput(dp);
    80005bec:	8526                	mv	a0,s1
    80005bee:	ffffe097          	auipc	ra,0xffffe
    80005bf2:	788080e7          	jalr	1928(ra) # 80004376 <iunlockput>
    return 0;
    80005bf6:	8ad2                	mv	s5,s4
    80005bf8:	7a02                	ld	s4,32(sp)
    80005bfa:	bf95                	j	80005b6e <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005bfc:	004a2603          	lw	a2,4(s4)
    80005c00:	00003597          	auipc	a1,0x3
    80005c04:	b8058593          	addi	a1,a1,-1152 # 80008780 <__func__.1+0x778>
    80005c08:	8552                	mv	a0,s4
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	c22080e7          	jalr	-990(ra) # 8000482c <dirlink>
    80005c12:	04054463          	bltz	a0,80005c5a <create+0x15c>
    80005c16:	40d0                	lw	a2,4(s1)
    80005c18:	00003597          	auipc	a1,0x3
    80005c1c:	b7058593          	addi	a1,a1,-1168 # 80008788 <__func__.1+0x780>
    80005c20:	8552                	mv	a0,s4
    80005c22:	fffff097          	auipc	ra,0xfffff
    80005c26:	c0a080e7          	jalr	-1014(ra) # 8000482c <dirlink>
    80005c2a:	02054863          	bltz	a0,80005c5a <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005c2e:	004a2603          	lw	a2,4(s4)
    80005c32:	fb040593          	addi	a1,s0,-80
    80005c36:	8526                	mv	a0,s1
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	bf4080e7          	jalr	-1036(ra) # 8000482c <dirlink>
    80005c40:	00054d63          	bltz	a0,80005c5a <create+0x15c>
    dp->nlink++;  // for ".."
    80005c44:	04a4d783          	lhu	a5,74(s1)
    80005c48:	2785                	addiw	a5,a5,1
    80005c4a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c4e:	8526                	mv	a0,s1
    80005c50:	ffffe097          	auipc	ra,0xffffe
    80005c54:	3f4080e7          	jalr	1012(ra) # 80004044 <iupdate>
    80005c58:	b751                	j	80005bdc <create+0xde>
  ip->nlink = 0;
    80005c5a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005c5e:	8552                	mv	a0,s4
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	3e4080e7          	jalr	996(ra) # 80004044 <iupdate>
  iunlockput(ip);
    80005c68:	8552                	mv	a0,s4
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	70c080e7          	jalr	1804(ra) # 80004376 <iunlockput>
  iunlockput(dp);
    80005c72:	8526                	mv	a0,s1
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	702080e7          	jalr	1794(ra) # 80004376 <iunlockput>
  return 0;
    80005c7c:	7a02                	ld	s4,32(sp)
    80005c7e:	bdc5                	j	80005b6e <create+0x70>
    return 0;
    80005c80:	8aaa                	mv	s5,a0
    80005c82:	b5f5                	j	80005b6e <create+0x70>

0000000080005c84 <sys_dup>:
{
    80005c84:	7179                	addi	sp,sp,-48
    80005c86:	f406                	sd	ra,40(sp)
    80005c88:	f022                	sd	s0,32(sp)
    80005c8a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005c8c:	fd840613          	addi	a2,s0,-40
    80005c90:	4581                	li	a1,0
    80005c92:	4501                	li	a0,0
    80005c94:	00000097          	auipc	ra,0x0
    80005c98:	dc8080e7          	jalr	-568(ra) # 80005a5c <argfd>
    return -1;
    80005c9c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005c9e:	02054763          	bltz	a0,80005ccc <sys_dup+0x48>
    80005ca2:	ec26                	sd	s1,24(sp)
    80005ca4:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005ca6:	fd843903          	ld	s2,-40(s0)
    80005caa:	854a                	mv	a0,s2
    80005cac:	00000097          	auipc	ra,0x0
    80005cb0:	e10080e7          	jalr	-496(ra) # 80005abc <fdalloc>
    80005cb4:	84aa                	mv	s1,a0
    return -1;
    80005cb6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005cb8:	00054f63          	bltz	a0,80005cd6 <sys_dup+0x52>
  filedup(f);
    80005cbc:	854a                	mv	a0,s2
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	298080e7          	jalr	664(ra) # 80004f56 <filedup>
  return fd;
    80005cc6:	87a6                	mv	a5,s1
    80005cc8:	64e2                	ld	s1,24(sp)
    80005cca:	6942                	ld	s2,16(sp)
}
    80005ccc:	853e                	mv	a0,a5
    80005cce:	70a2                	ld	ra,40(sp)
    80005cd0:	7402                	ld	s0,32(sp)
    80005cd2:	6145                	addi	sp,sp,48
    80005cd4:	8082                	ret
    80005cd6:	64e2                	ld	s1,24(sp)
    80005cd8:	6942                	ld	s2,16(sp)
    80005cda:	bfcd                	j	80005ccc <sys_dup+0x48>

0000000080005cdc <sys_read>:
{
    80005cdc:	7179                	addi	sp,sp,-48
    80005cde:	f406                	sd	ra,40(sp)
    80005ce0:	f022                	sd	s0,32(sp)
    80005ce2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005ce4:	fd840593          	addi	a1,s0,-40
    80005ce8:	4505                	li	a0,1
    80005cea:	ffffd097          	auipc	ra,0xffffd
    80005cee:	72c080e7          	jalr	1836(ra) # 80003416 <argaddr>
  argint(2, &n);
    80005cf2:	fe440593          	addi	a1,s0,-28
    80005cf6:	4509                	li	a0,2
    80005cf8:	ffffd097          	auipc	ra,0xffffd
    80005cfc:	6fe080e7          	jalr	1790(ra) # 800033f6 <argint>
  if(argfd(0, 0, &f) < 0)
    80005d00:	fe840613          	addi	a2,s0,-24
    80005d04:	4581                	li	a1,0
    80005d06:	4501                	li	a0,0
    80005d08:	00000097          	auipc	ra,0x0
    80005d0c:	d54080e7          	jalr	-684(ra) # 80005a5c <argfd>
    80005d10:	87aa                	mv	a5,a0
    return -1;
    80005d12:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d14:	0007cc63          	bltz	a5,80005d2c <sys_read+0x50>
  return fileread(f, p, n);
    80005d18:	fe442603          	lw	a2,-28(s0)
    80005d1c:	fd843583          	ld	a1,-40(s0)
    80005d20:	fe843503          	ld	a0,-24(s0)
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	3d8080e7          	jalr	984(ra) # 800050fc <fileread>
}
    80005d2c:	70a2                	ld	ra,40(sp)
    80005d2e:	7402                	ld	s0,32(sp)
    80005d30:	6145                	addi	sp,sp,48
    80005d32:	8082                	ret

0000000080005d34 <sys_write>:
{
    80005d34:	7179                	addi	sp,sp,-48
    80005d36:	f406                	sd	ra,40(sp)
    80005d38:	f022                	sd	s0,32(sp)
    80005d3a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005d3c:	fd840593          	addi	a1,s0,-40
    80005d40:	4505                	li	a0,1
    80005d42:	ffffd097          	auipc	ra,0xffffd
    80005d46:	6d4080e7          	jalr	1748(ra) # 80003416 <argaddr>
  argint(2, &n);
    80005d4a:	fe440593          	addi	a1,s0,-28
    80005d4e:	4509                	li	a0,2
    80005d50:	ffffd097          	auipc	ra,0xffffd
    80005d54:	6a6080e7          	jalr	1702(ra) # 800033f6 <argint>
  if(argfd(0, 0, &f) < 0)
    80005d58:	fe840613          	addi	a2,s0,-24
    80005d5c:	4581                	li	a1,0
    80005d5e:	4501                	li	a0,0
    80005d60:	00000097          	auipc	ra,0x0
    80005d64:	cfc080e7          	jalr	-772(ra) # 80005a5c <argfd>
    80005d68:	87aa                	mv	a5,a0
    return -1;
    80005d6a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d6c:	0007cc63          	bltz	a5,80005d84 <sys_write+0x50>
  return filewrite(f, p, n);
    80005d70:	fe442603          	lw	a2,-28(s0)
    80005d74:	fd843583          	ld	a1,-40(s0)
    80005d78:	fe843503          	ld	a0,-24(s0)
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	452080e7          	jalr	1106(ra) # 800051ce <filewrite>
}
    80005d84:	70a2                	ld	ra,40(sp)
    80005d86:	7402                	ld	s0,32(sp)
    80005d88:	6145                	addi	sp,sp,48
    80005d8a:	8082                	ret

0000000080005d8c <sys_close>:
{
    80005d8c:	1101                	addi	sp,sp,-32
    80005d8e:	ec06                	sd	ra,24(sp)
    80005d90:	e822                	sd	s0,16(sp)
    80005d92:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005d94:	fe040613          	addi	a2,s0,-32
    80005d98:	fec40593          	addi	a1,s0,-20
    80005d9c:	4501                	li	a0,0
    80005d9e:	00000097          	auipc	ra,0x0
    80005da2:	cbe080e7          	jalr	-834(ra) # 80005a5c <argfd>
    return -1;
    80005da6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005da8:	02054463          	bltz	a0,80005dd0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005dac:	ffffc097          	auipc	ra,0xffffc
    80005db0:	1fc080e7          	jalr	508(ra) # 80001fa8 <myproc>
    80005db4:	fec42783          	lw	a5,-20(s0)
    80005db8:	07e9                	addi	a5,a5,26
    80005dba:	078e                	slli	a5,a5,0x3
    80005dbc:	953e                	add	a0,a0,a5
    80005dbe:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005dc2:	fe043503          	ld	a0,-32(s0)
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	1e2080e7          	jalr	482(ra) # 80004fa8 <fileclose>
  return 0;
    80005dce:	4781                	li	a5,0
}
    80005dd0:	853e                	mv	a0,a5
    80005dd2:	60e2                	ld	ra,24(sp)
    80005dd4:	6442                	ld	s0,16(sp)
    80005dd6:	6105                	addi	sp,sp,32
    80005dd8:	8082                	ret

0000000080005dda <sys_fstat>:
{
    80005dda:	1101                	addi	sp,sp,-32
    80005ddc:	ec06                	sd	ra,24(sp)
    80005dde:	e822                	sd	s0,16(sp)
    80005de0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005de2:	fe040593          	addi	a1,s0,-32
    80005de6:	4505                	li	a0,1
    80005de8:	ffffd097          	auipc	ra,0xffffd
    80005dec:	62e080e7          	jalr	1582(ra) # 80003416 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005df0:	fe840613          	addi	a2,s0,-24
    80005df4:	4581                	li	a1,0
    80005df6:	4501                	li	a0,0
    80005df8:	00000097          	auipc	ra,0x0
    80005dfc:	c64080e7          	jalr	-924(ra) # 80005a5c <argfd>
    80005e00:	87aa                	mv	a5,a0
    return -1;
    80005e02:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e04:	0007ca63          	bltz	a5,80005e18 <sys_fstat+0x3e>
  return filestat(f, st);
    80005e08:	fe043583          	ld	a1,-32(s0)
    80005e0c:	fe843503          	ld	a0,-24(s0)
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	27a080e7          	jalr	634(ra) # 8000508a <filestat>
}
    80005e18:	60e2                	ld	ra,24(sp)
    80005e1a:	6442                	ld	s0,16(sp)
    80005e1c:	6105                	addi	sp,sp,32
    80005e1e:	8082                	ret

0000000080005e20 <sys_link>:
{
    80005e20:	7169                	addi	sp,sp,-304
    80005e22:	f606                	sd	ra,296(sp)
    80005e24:	f222                	sd	s0,288(sp)
    80005e26:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e28:	08000613          	li	a2,128
    80005e2c:	ed040593          	addi	a1,s0,-304
    80005e30:	4501                	li	a0,0
    80005e32:	ffffd097          	auipc	ra,0xffffd
    80005e36:	604080e7          	jalr	1540(ra) # 80003436 <argstr>
    return -1;
    80005e3a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e3c:	12054663          	bltz	a0,80005f68 <sys_link+0x148>
    80005e40:	08000613          	li	a2,128
    80005e44:	f5040593          	addi	a1,s0,-176
    80005e48:	4505                	li	a0,1
    80005e4a:	ffffd097          	auipc	ra,0xffffd
    80005e4e:	5ec080e7          	jalr	1516(ra) # 80003436 <argstr>
    return -1;
    80005e52:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e54:	10054a63          	bltz	a0,80005f68 <sys_link+0x148>
    80005e58:	ee26                	sd	s1,280(sp)
  begin_op();
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	c84080e7          	jalr	-892(ra) # 80004ade <begin_op>
  if((ip = namei(old)) == 0){
    80005e62:	ed040513          	addi	a0,s0,-304
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	a78080e7          	jalr	-1416(ra) # 800048de <namei>
    80005e6e:	84aa                	mv	s1,a0
    80005e70:	c949                	beqz	a0,80005f02 <sys_link+0xe2>
  ilock(ip);
    80005e72:	ffffe097          	auipc	ra,0xffffe
    80005e76:	29e080e7          	jalr	670(ra) # 80004110 <ilock>
  if(ip->type == T_DIR){
    80005e7a:	04449703          	lh	a4,68(s1)
    80005e7e:	4785                	li	a5,1
    80005e80:	08f70863          	beq	a4,a5,80005f10 <sys_link+0xf0>
    80005e84:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005e86:	04a4d783          	lhu	a5,74(s1)
    80005e8a:	2785                	addiw	a5,a5,1
    80005e8c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e90:	8526                	mv	a0,s1
    80005e92:	ffffe097          	auipc	ra,0xffffe
    80005e96:	1b2080e7          	jalr	434(ra) # 80004044 <iupdate>
  iunlock(ip);
    80005e9a:	8526                	mv	a0,s1
    80005e9c:	ffffe097          	auipc	ra,0xffffe
    80005ea0:	33a080e7          	jalr	826(ra) # 800041d6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ea4:	fd040593          	addi	a1,s0,-48
    80005ea8:	f5040513          	addi	a0,s0,-176
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	a50080e7          	jalr	-1456(ra) # 800048fc <nameiparent>
    80005eb4:	892a                	mv	s2,a0
    80005eb6:	cd35                	beqz	a0,80005f32 <sys_link+0x112>
  ilock(dp);
    80005eb8:	ffffe097          	auipc	ra,0xffffe
    80005ebc:	258080e7          	jalr	600(ra) # 80004110 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005ec0:	00092703          	lw	a4,0(s2)
    80005ec4:	409c                	lw	a5,0(s1)
    80005ec6:	06f71163          	bne	a4,a5,80005f28 <sys_link+0x108>
    80005eca:	40d0                	lw	a2,4(s1)
    80005ecc:	fd040593          	addi	a1,s0,-48
    80005ed0:	854a                	mv	a0,s2
    80005ed2:	fffff097          	auipc	ra,0xfffff
    80005ed6:	95a080e7          	jalr	-1702(ra) # 8000482c <dirlink>
    80005eda:	04054763          	bltz	a0,80005f28 <sys_link+0x108>
  iunlockput(dp);
    80005ede:	854a                	mv	a0,s2
    80005ee0:	ffffe097          	auipc	ra,0xffffe
    80005ee4:	496080e7          	jalr	1174(ra) # 80004376 <iunlockput>
  iput(ip);
    80005ee8:	8526                	mv	a0,s1
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	3e4080e7          	jalr	996(ra) # 800042ce <iput>
  end_op();
    80005ef2:	fffff097          	auipc	ra,0xfffff
    80005ef6:	c66080e7          	jalr	-922(ra) # 80004b58 <end_op>
  return 0;
    80005efa:	4781                	li	a5,0
    80005efc:	64f2                	ld	s1,280(sp)
    80005efe:	6952                	ld	s2,272(sp)
    80005f00:	a0a5                	j	80005f68 <sys_link+0x148>
    end_op();
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	c56080e7          	jalr	-938(ra) # 80004b58 <end_op>
    return -1;
    80005f0a:	57fd                	li	a5,-1
    80005f0c:	64f2                	ld	s1,280(sp)
    80005f0e:	a8a9                	j	80005f68 <sys_link+0x148>
    iunlockput(ip);
    80005f10:	8526                	mv	a0,s1
    80005f12:	ffffe097          	auipc	ra,0xffffe
    80005f16:	464080e7          	jalr	1124(ra) # 80004376 <iunlockput>
    end_op();
    80005f1a:	fffff097          	auipc	ra,0xfffff
    80005f1e:	c3e080e7          	jalr	-962(ra) # 80004b58 <end_op>
    return -1;
    80005f22:	57fd                	li	a5,-1
    80005f24:	64f2                	ld	s1,280(sp)
    80005f26:	a089                	j	80005f68 <sys_link+0x148>
    iunlockput(dp);
    80005f28:	854a                	mv	a0,s2
    80005f2a:	ffffe097          	auipc	ra,0xffffe
    80005f2e:	44c080e7          	jalr	1100(ra) # 80004376 <iunlockput>
  ilock(ip);
    80005f32:	8526                	mv	a0,s1
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	1dc080e7          	jalr	476(ra) # 80004110 <ilock>
  ip->nlink--;
    80005f3c:	04a4d783          	lhu	a5,74(s1)
    80005f40:	37fd                	addiw	a5,a5,-1
    80005f42:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f46:	8526                	mv	a0,s1
    80005f48:	ffffe097          	auipc	ra,0xffffe
    80005f4c:	0fc080e7          	jalr	252(ra) # 80004044 <iupdate>
  iunlockput(ip);
    80005f50:	8526                	mv	a0,s1
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	424080e7          	jalr	1060(ra) # 80004376 <iunlockput>
  end_op();
    80005f5a:	fffff097          	auipc	ra,0xfffff
    80005f5e:	bfe080e7          	jalr	-1026(ra) # 80004b58 <end_op>
  return -1;
    80005f62:	57fd                	li	a5,-1
    80005f64:	64f2                	ld	s1,280(sp)
    80005f66:	6952                	ld	s2,272(sp)
}
    80005f68:	853e                	mv	a0,a5
    80005f6a:	70b2                	ld	ra,296(sp)
    80005f6c:	7412                	ld	s0,288(sp)
    80005f6e:	6155                	addi	sp,sp,304
    80005f70:	8082                	ret

0000000080005f72 <sys_unlink>:
{
    80005f72:	7151                	addi	sp,sp,-240
    80005f74:	f586                	sd	ra,232(sp)
    80005f76:	f1a2                	sd	s0,224(sp)
    80005f78:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005f7a:	08000613          	li	a2,128
    80005f7e:	f3040593          	addi	a1,s0,-208
    80005f82:	4501                	li	a0,0
    80005f84:	ffffd097          	auipc	ra,0xffffd
    80005f88:	4b2080e7          	jalr	1202(ra) # 80003436 <argstr>
    80005f8c:	1a054a63          	bltz	a0,80006140 <sys_unlink+0x1ce>
    80005f90:	eda6                	sd	s1,216(sp)
  begin_op();
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	b4c080e7          	jalr	-1204(ra) # 80004ade <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005f9a:	fb040593          	addi	a1,s0,-80
    80005f9e:	f3040513          	addi	a0,s0,-208
    80005fa2:	fffff097          	auipc	ra,0xfffff
    80005fa6:	95a080e7          	jalr	-1702(ra) # 800048fc <nameiparent>
    80005faa:	84aa                	mv	s1,a0
    80005fac:	cd71                	beqz	a0,80006088 <sys_unlink+0x116>
  ilock(dp);
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	162080e7          	jalr	354(ra) # 80004110 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005fb6:	00002597          	auipc	a1,0x2
    80005fba:	7ca58593          	addi	a1,a1,1994 # 80008780 <__func__.1+0x778>
    80005fbe:	fb040513          	addi	a0,s0,-80
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	640080e7          	jalr	1600(ra) # 80004602 <namecmp>
    80005fca:	14050c63          	beqz	a0,80006122 <sys_unlink+0x1b0>
    80005fce:	00002597          	auipc	a1,0x2
    80005fd2:	7ba58593          	addi	a1,a1,1978 # 80008788 <__func__.1+0x780>
    80005fd6:	fb040513          	addi	a0,s0,-80
    80005fda:	ffffe097          	auipc	ra,0xffffe
    80005fde:	628080e7          	jalr	1576(ra) # 80004602 <namecmp>
    80005fe2:	14050063          	beqz	a0,80006122 <sys_unlink+0x1b0>
    80005fe6:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005fe8:	f2c40613          	addi	a2,s0,-212
    80005fec:	fb040593          	addi	a1,s0,-80
    80005ff0:	8526                	mv	a0,s1
    80005ff2:	ffffe097          	auipc	ra,0xffffe
    80005ff6:	62a080e7          	jalr	1578(ra) # 8000461c <dirlookup>
    80005ffa:	892a                	mv	s2,a0
    80005ffc:	12050263          	beqz	a0,80006120 <sys_unlink+0x1ae>
  ilock(ip);
    80006000:	ffffe097          	auipc	ra,0xffffe
    80006004:	110080e7          	jalr	272(ra) # 80004110 <ilock>
  if(ip->nlink < 1)
    80006008:	04a91783          	lh	a5,74(s2)
    8000600c:	08f05563          	blez	a5,80006096 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006010:	04491703          	lh	a4,68(s2)
    80006014:	4785                	li	a5,1
    80006016:	08f70963          	beq	a4,a5,800060a8 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    8000601a:	4641                	li	a2,16
    8000601c:	4581                	li	a1,0
    8000601e:	fc040513          	addi	a0,s0,-64
    80006022:	ffffb097          	auipc	ra,0xffffb
    80006026:	010080e7          	jalr	16(ra) # 80001032 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000602a:	4741                	li	a4,16
    8000602c:	f2c42683          	lw	a3,-212(s0)
    80006030:	fc040613          	addi	a2,s0,-64
    80006034:	4581                	li	a1,0
    80006036:	8526                	mv	a0,s1
    80006038:	ffffe097          	auipc	ra,0xffffe
    8000603c:	4a0080e7          	jalr	1184(ra) # 800044d8 <writei>
    80006040:	47c1                	li	a5,16
    80006042:	0af51b63          	bne	a0,a5,800060f8 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80006046:	04491703          	lh	a4,68(s2)
    8000604a:	4785                	li	a5,1
    8000604c:	0af70f63          	beq	a4,a5,8000610a <sys_unlink+0x198>
  iunlockput(dp);
    80006050:	8526                	mv	a0,s1
    80006052:	ffffe097          	auipc	ra,0xffffe
    80006056:	324080e7          	jalr	804(ra) # 80004376 <iunlockput>
  ip->nlink--;
    8000605a:	04a95783          	lhu	a5,74(s2)
    8000605e:	37fd                	addiw	a5,a5,-1
    80006060:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006064:	854a                	mv	a0,s2
    80006066:	ffffe097          	auipc	ra,0xffffe
    8000606a:	fde080e7          	jalr	-34(ra) # 80004044 <iupdate>
  iunlockput(ip);
    8000606e:	854a                	mv	a0,s2
    80006070:	ffffe097          	auipc	ra,0xffffe
    80006074:	306080e7          	jalr	774(ra) # 80004376 <iunlockput>
  end_op();
    80006078:	fffff097          	auipc	ra,0xfffff
    8000607c:	ae0080e7          	jalr	-1312(ra) # 80004b58 <end_op>
  return 0;
    80006080:	4501                	li	a0,0
    80006082:	64ee                	ld	s1,216(sp)
    80006084:	694e                	ld	s2,208(sp)
    80006086:	a84d                	j	80006138 <sys_unlink+0x1c6>
    end_op();
    80006088:	fffff097          	auipc	ra,0xfffff
    8000608c:	ad0080e7          	jalr	-1328(ra) # 80004b58 <end_op>
    return -1;
    80006090:	557d                	li	a0,-1
    80006092:	64ee                	ld	s1,216(sp)
    80006094:	a055                	j	80006138 <sys_unlink+0x1c6>
    80006096:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80006098:	00002517          	auipc	a0,0x2
    8000609c:	6f850513          	addi	a0,a0,1784 # 80008790 <__func__.1+0x788>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	4c0080e7          	jalr	1216(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800060a8:	04c92703          	lw	a4,76(s2)
    800060ac:	02000793          	li	a5,32
    800060b0:	f6e7f5e3          	bgeu	a5,a4,8000601a <sys_unlink+0xa8>
    800060b4:	e5ce                	sd	s3,200(sp)
    800060b6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800060ba:	4741                	li	a4,16
    800060bc:	86ce                	mv	a3,s3
    800060be:	f1840613          	addi	a2,s0,-232
    800060c2:	4581                	li	a1,0
    800060c4:	854a                	mv	a0,s2
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	302080e7          	jalr	770(ra) # 800043c8 <readi>
    800060ce:	47c1                	li	a5,16
    800060d0:	00f51c63          	bne	a0,a5,800060e8 <sys_unlink+0x176>
    if(de.inum != 0)
    800060d4:	f1845783          	lhu	a5,-232(s0)
    800060d8:	e7b5                	bnez	a5,80006144 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800060da:	29c1                	addiw	s3,s3,16
    800060dc:	04c92783          	lw	a5,76(s2)
    800060e0:	fcf9ede3          	bltu	s3,a5,800060ba <sys_unlink+0x148>
    800060e4:	69ae                	ld	s3,200(sp)
    800060e6:	bf15                	j	8000601a <sys_unlink+0xa8>
      panic("isdirempty: readi");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	6c050513          	addi	a0,a0,1728 # 800087a8 <__func__.1+0x7a0>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	470080e7          	jalr	1136(ra) # 80000560 <panic>
    800060f8:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800060fa:	00002517          	auipc	a0,0x2
    800060fe:	6c650513          	addi	a0,a0,1734 # 800087c0 <__func__.1+0x7b8>
    80006102:	ffffa097          	auipc	ra,0xffffa
    80006106:	45e080e7          	jalr	1118(ra) # 80000560 <panic>
    dp->nlink--;
    8000610a:	04a4d783          	lhu	a5,74(s1)
    8000610e:	37fd                	addiw	a5,a5,-1
    80006110:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006114:	8526                	mv	a0,s1
    80006116:	ffffe097          	auipc	ra,0xffffe
    8000611a:	f2e080e7          	jalr	-210(ra) # 80004044 <iupdate>
    8000611e:	bf0d                	j	80006050 <sys_unlink+0xde>
    80006120:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80006122:	8526                	mv	a0,s1
    80006124:	ffffe097          	auipc	ra,0xffffe
    80006128:	252080e7          	jalr	594(ra) # 80004376 <iunlockput>
  end_op();
    8000612c:	fffff097          	auipc	ra,0xfffff
    80006130:	a2c080e7          	jalr	-1492(ra) # 80004b58 <end_op>
  return -1;
    80006134:	557d                	li	a0,-1
    80006136:	64ee                	ld	s1,216(sp)
}
    80006138:	70ae                	ld	ra,232(sp)
    8000613a:	740e                	ld	s0,224(sp)
    8000613c:	616d                	addi	sp,sp,240
    8000613e:	8082                	ret
    return -1;
    80006140:	557d                	li	a0,-1
    80006142:	bfdd                	j	80006138 <sys_unlink+0x1c6>
    iunlockput(ip);
    80006144:	854a                	mv	a0,s2
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	230080e7          	jalr	560(ra) # 80004376 <iunlockput>
    goto bad;
    8000614e:	694e                	ld	s2,208(sp)
    80006150:	69ae                	ld	s3,200(sp)
    80006152:	bfc1                	j	80006122 <sys_unlink+0x1b0>

0000000080006154 <sys_open>:

uint64
sys_open(void)
{
    80006154:	7131                	addi	sp,sp,-192
    80006156:	fd06                	sd	ra,184(sp)
    80006158:	f922                	sd	s0,176(sp)
    8000615a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000615c:	f4c40593          	addi	a1,s0,-180
    80006160:	4505                	li	a0,1
    80006162:	ffffd097          	auipc	ra,0xffffd
    80006166:	294080e7          	jalr	660(ra) # 800033f6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000616a:	08000613          	li	a2,128
    8000616e:	f5040593          	addi	a1,s0,-176
    80006172:	4501                	li	a0,0
    80006174:	ffffd097          	auipc	ra,0xffffd
    80006178:	2c2080e7          	jalr	706(ra) # 80003436 <argstr>
    8000617c:	87aa                	mv	a5,a0
    return -1;
    8000617e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006180:	0a07ce63          	bltz	a5,8000623c <sys_open+0xe8>
    80006184:	f526                	sd	s1,168(sp)

  begin_op();
    80006186:	fffff097          	auipc	ra,0xfffff
    8000618a:	958080e7          	jalr	-1704(ra) # 80004ade <begin_op>

  if(omode & O_CREATE){
    8000618e:	f4c42783          	lw	a5,-180(s0)
    80006192:	2007f793          	andi	a5,a5,512
    80006196:	cfd5                	beqz	a5,80006252 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006198:	4681                	li	a3,0
    8000619a:	4601                	li	a2,0
    8000619c:	4589                	li	a1,2
    8000619e:	f5040513          	addi	a0,s0,-176
    800061a2:	00000097          	auipc	ra,0x0
    800061a6:	95c080e7          	jalr	-1700(ra) # 80005afe <create>
    800061aa:	84aa                	mv	s1,a0
    if(ip == 0){
    800061ac:	cd41                	beqz	a0,80006244 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800061ae:	04449703          	lh	a4,68(s1)
    800061b2:	478d                	li	a5,3
    800061b4:	00f71763          	bne	a4,a5,800061c2 <sys_open+0x6e>
    800061b8:	0464d703          	lhu	a4,70(s1)
    800061bc:	47a5                	li	a5,9
    800061be:	0ee7e163          	bltu	a5,a4,800062a0 <sys_open+0x14c>
    800061c2:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800061c4:	fffff097          	auipc	ra,0xfffff
    800061c8:	d28080e7          	jalr	-728(ra) # 80004eec <filealloc>
    800061cc:	892a                	mv	s2,a0
    800061ce:	c97d                	beqz	a0,800062c4 <sys_open+0x170>
    800061d0:	ed4e                	sd	s3,152(sp)
    800061d2:	00000097          	auipc	ra,0x0
    800061d6:	8ea080e7          	jalr	-1814(ra) # 80005abc <fdalloc>
    800061da:	89aa                	mv	s3,a0
    800061dc:	0c054e63          	bltz	a0,800062b8 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800061e0:	04449703          	lh	a4,68(s1)
    800061e4:	478d                	li	a5,3
    800061e6:	0ef70c63          	beq	a4,a5,800062de <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800061ea:	4789                	li	a5,2
    800061ec:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800061f0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800061f4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800061f8:	f4c42783          	lw	a5,-180(s0)
    800061fc:	0017c713          	xori	a4,a5,1
    80006200:	8b05                	andi	a4,a4,1
    80006202:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006206:	0037f713          	andi	a4,a5,3
    8000620a:	00e03733          	snez	a4,a4
    8000620e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006212:	4007f793          	andi	a5,a5,1024
    80006216:	c791                	beqz	a5,80006222 <sys_open+0xce>
    80006218:	04449703          	lh	a4,68(s1)
    8000621c:	4789                	li	a5,2
    8000621e:	0cf70763          	beq	a4,a5,800062ec <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80006222:	8526                	mv	a0,s1
    80006224:	ffffe097          	auipc	ra,0xffffe
    80006228:	fb2080e7          	jalr	-78(ra) # 800041d6 <iunlock>
  end_op();
    8000622c:	fffff097          	auipc	ra,0xfffff
    80006230:	92c080e7          	jalr	-1748(ra) # 80004b58 <end_op>

  return fd;
    80006234:	854e                	mv	a0,s3
    80006236:	74aa                	ld	s1,168(sp)
    80006238:	790a                	ld	s2,160(sp)
    8000623a:	69ea                	ld	s3,152(sp)
}
    8000623c:	70ea                	ld	ra,184(sp)
    8000623e:	744a                	ld	s0,176(sp)
    80006240:	6129                	addi	sp,sp,192
    80006242:	8082                	ret
      end_op();
    80006244:	fffff097          	auipc	ra,0xfffff
    80006248:	914080e7          	jalr	-1772(ra) # 80004b58 <end_op>
      return -1;
    8000624c:	557d                	li	a0,-1
    8000624e:	74aa                	ld	s1,168(sp)
    80006250:	b7f5                	j	8000623c <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80006252:	f5040513          	addi	a0,s0,-176
    80006256:	ffffe097          	auipc	ra,0xffffe
    8000625a:	688080e7          	jalr	1672(ra) # 800048de <namei>
    8000625e:	84aa                	mv	s1,a0
    80006260:	c90d                	beqz	a0,80006292 <sys_open+0x13e>
    ilock(ip);
    80006262:	ffffe097          	auipc	ra,0xffffe
    80006266:	eae080e7          	jalr	-338(ra) # 80004110 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000626a:	04449703          	lh	a4,68(s1)
    8000626e:	4785                	li	a5,1
    80006270:	f2f71fe3          	bne	a4,a5,800061ae <sys_open+0x5a>
    80006274:	f4c42783          	lw	a5,-180(s0)
    80006278:	d7a9                	beqz	a5,800061c2 <sys_open+0x6e>
      iunlockput(ip);
    8000627a:	8526                	mv	a0,s1
    8000627c:	ffffe097          	auipc	ra,0xffffe
    80006280:	0fa080e7          	jalr	250(ra) # 80004376 <iunlockput>
      end_op();
    80006284:	fffff097          	auipc	ra,0xfffff
    80006288:	8d4080e7          	jalr	-1836(ra) # 80004b58 <end_op>
      return -1;
    8000628c:	557d                	li	a0,-1
    8000628e:	74aa                	ld	s1,168(sp)
    80006290:	b775                	j	8000623c <sys_open+0xe8>
      end_op();
    80006292:	fffff097          	auipc	ra,0xfffff
    80006296:	8c6080e7          	jalr	-1850(ra) # 80004b58 <end_op>
      return -1;
    8000629a:	557d                	li	a0,-1
    8000629c:	74aa                	ld	s1,168(sp)
    8000629e:	bf79                	j	8000623c <sys_open+0xe8>
    iunlockput(ip);
    800062a0:	8526                	mv	a0,s1
    800062a2:	ffffe097          	auipc	ra,0xffffe
    800062a6:	0d4080e7          	jalr	212(ra) # 80004376 <iunlockput>
    end_op();
    800062aa:	fffff097          	auipc	ra,0xfffff
    800062ae:	8ae080e7          	jalr	-1874(ra) # 80004b58 <end_op>
    return -1;
    800062b2:	557d                	li	a0,-1
    800062b4:	74aa                	ld	s1,168(sp)
    800062b6:	b759                	j	8000623c <sys_open+0xe8>
      fileclose(f);
    800062b8:	854a                	mv	a0,s2
    800062ba:	fffff097          	auipc	ra,0xfffff
    800062be:	cee080e7          	jalr	-786(ra) # 80004fa8 <fileclose>
    800062c2:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800062c4:	8526                	mv	a0,s1
    800062c6:	ffffe097          	auipc	ra,0xffffe
    800062ca:	0b0080e7          	jalr	176(ra) # 80004376 <iunlockput>
    end_op();
    800062ce:	fffff097          	auipc	ra,0xfffff
    800062d2:	88a080e7          	jalr	-1910(ra) # 80004b58 <end_op>
    return -1;
    800062d6:	557d                	li	a0,-1
    800062d8:	74aa                	ld	s1,168(sp)
    800062da:	790a                	ld	s2,160(sp)
    800062dc:	b785                	j	8000623c <sys_open+0xe8>
    f->type = FD_DEVICE;
    800062de:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800062e2:	04649783          	lh	a5,70(s1)
    800062e6:	02f91223          	sh	a5,36(s2)
    800062ea:	b729                	j	800061f4 <sys_open+0xa0>
    itrunc(ip);
    800062ec:	8526                	mv	a0,s1
    800062ee:	ffffe097          	auipc	ra,0xffffe
    800062f2:	f34080e7          	jalr	-204(ra) # 80004222 <itrunc>
    800062f6:	b735                	j	80006222 <sys_open+0xce>

00000000800062f8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800062f8:	7175                	addi	sp,sp,-144
    800062fa:	e506                	sd	ra,136(sp)
    800062fc:	e122                	sd	s0,128(sp)
    800062fe:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006300:	ffffe097          	auipc	ra,0xffffe
    80006304:	7de080e7          	jalr	2014(ra) # 80004ade <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006308:	08000613          	li	a2,128
    8000630c:	f7040593          	addi	a1,s0,-144
    80006310:	4501                	li	a0,0
    80006312:	ffffd097          	auipc	ra,0xffffd
    80006316:	124080e7          	jalr	292(ra) # 80003436 <argstr>
    8000631a:	02054963          	bltz	a0,8000634c <sys_mkdir+0x54>
    8000631e:	4681                	li	a3,0
    80006320:	4601                	li	a2,0
    80006322:	4585                	li	a1,1
    80006324:	f7040513          	addi	a0,s0,-144
    80006328:	fffff097          	auipc	ra,0xfffff
    8000632c:	7d6080e7          	jalr	2006(ra) # 80005afe <create>
    80006330:	cd11                	beqz	a0,8000634c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006332:	ffffe097          	auipc	ra,0xffffe
    80006336:	044080e7          	jalr	68(ra) # 80004376 <iunlockput>
  end_op();
    8000633a:	fffff097          	auipc	ra,0xfffff
    8000633e:	81e080e7          	jalr	-2018(ra) # 80004b58 <end_op>
  return 0;
    80006342:	4501                	li	a0,0
}
    80006344:	60aa                	ld	ra,136(sp)
    80006346:	640a                	ld	s0,128(sp)
    80006348:	6149                	addi	sp,sp,144
    8000634a:	8082                	ret
    end_op();
    8000634c:	fffff097          	auipc	ra,0xfffff
    80006350:	80c080e7          	jalr	-2036(ra) # 80004b58 <end_op>
    return -1;
    80006354:	557d                	li	a0,-1
    80006356:	b7fd                	j	80006344 <sys_mkdir+0x4c>

0000000080006358 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006358:	7135                	addi	sp,sp,-160
    8000635a:	ed06                	sd	ra,152(sp)
    8000635c:	e922                	sd	s0,144(sp)
    8000635e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006360:	ffffe097          	auipc	ra,0xffffe
    80006364:	77e080e7          	jalr	1918(ra) # 80004ade <begin_op>
  argint(1, &major);
    80006368:	f6c40593          	addi	a1,s0,-148
    8000636c:	4505                	li	a0,1
    8000636e:	ffffd097          	auipc	ra,0xffffd
    80006372:	088080e7          	jalr	136(ra) # 800033f6 <argint>
  argint(2, &minor);
    80006376:	f6840593          	addi	a1,s0,-152
    8000637a:	4509                	li	a0,2
    8000637c:	ffffd097          	auipc	ra,0xffffd
    80006380:	07a080e7          	jalr	122(ra) # 800033f6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006384:	08000613          	li	a2,128
    80006388:	f7040593          	addi	a1,s0,-144
    8000638c:	4501                	li	a0,0
    8000638e:	ffffd097          	auipc	ra,0xffffd
    80006392:	0a8080e7          	jalr	168(ra) # 80003436 <argstr>
    80006396:	02054b63          	bltz	a0,800063cc <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000639a:	f6841683          	lh	a3,-152(s0)
    8000639e:	f6c41603          	lh	a2,-148(s0)
    800063a2:	458d                	li	a1,3
    800063a4:	f7040513          	addi	a0,s0,-144
    800063a8:	fffff097          	auipc	ra,0xfffff
    800063ac:	756080e7          	jalr	1878(ra) # 80005afe <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800063b0:	cd11                	beqz	a0,800063cc <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800063b2:	ffffe097          	auipc	ra,0xffffe
    800063b6:	fc4080e7          	jalr	-60(ra) # 80004376 <iunlockput>
  end_op();
    800063ba:	ffffe097          	auipc	ra,0xffffe
    800063be:	79e080e7          	jalr	1950(ra) # 80004b58 <end_op>
  return 0;
    800063c2:	4501                	li	a0,0
}
    800063c4:	60ea                	ld	ra,152(sp)
    800063c6:	644a                	ld	s0,144(sp)
    800063c8:	610d                	addi	sp,sp,160
    800063ca:	8082                	ret
    end_op();
    800063cc:	ffffe097          	auipc	ra,0xffffe
    800063d0:	78c080e7          	jalr	1932(ra) # 80004b58 <end_op>
    return -1;
    800063d4:	557d                	li	a0,-1
    800063d6:	b7fd                	j	800063c4 <sys_mknod+0x6c>

00000000800063d8 <sys_chdir>:

uint64
sys_chdir(void)
{
    800063d8:	7135                	addi	sp,sp,-160
    800063da:	ed06                	sd	ra,152(sp)
    800063dc:	e922                	sd	s0,144(sp)
    800063de:	e14a                	sd	s2,128(sp)
    800063e0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800063e2:	ffffc097          	auipc	ra,0xffffc
    800063e6:	bc6080e7          	jalr	-1082(ra) # 80001fa8 <myproc>
    800063ea:	892a                	mv	s2,a0
  
  begin_op();
    800063ec:	ffffe097          	auipc	ra,0xffffe
    800063f0:	6f2080e7          	jalr	1778(ra) # 80004ade <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800063f4:	08000613          	li	a2,128
    800063f8:	f6040593          	addi	a1,s0,-160
    800063fc:	4501                	li	a0,0
    800063fe:	ffffd097          	auipc	ra,0xffffd
    80006402:	038080e7          	jalr	56(ra) # 80003436 <argstr>
    80006406:	04054d63          	bltz	a0,80006460 <sys_chdir+0x88>
    8000640a:	e526                	sd	s1,136(sp)
    8000640c:	f6040513          	addi	a0,s0,-160
    80006410:	ffffe097          	auipc	ra,0xffffe
    80006414:	4ce080e7          	jalr	1230(ra) # 800048de <namei>
    80006418:	84aa                	mv	s1,a0
    8000641a:	c131                	beqz	a0,8000645e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000641c:	ffffe097          	auipc	ra,0xffffe
    80006420:	cf4080e7          	jalr	-780(ra) # 80004110 <ilock>
  if(ip->type != T_DIR){
    80006424:	04449703          	lh	a4,68(s1)
    80006428:	4785                	li	a5,1
    8000642a:	04f71163          	bne	a4,a5,8000646c <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000642e:	8526                	mv	a0,s1
    80006430:	ffffe097          	auipc	ra,0xffffe
    80006434:	da6080e7          	jalr	-602(ra) # 800041d6 <iunlock>
  iput(p->cwd);
    80006438:	15093503          	ld	a0,336(s2)
    8000643c:	ffffe097          	auipc	ra,0xffffe
    80006440:	e92080e7          	jalr	-366(ra) # 800042ce <iput>
  end_op();
    80006444:	ffffe097          	auipc	ra,0xffffe
    80006448:	714080e7          	jalr	1812(ra) # 80004b58 <end_op>
  p->cwd = ip;
    8000644c:	14993823          	sd	s1,336(s2)
  return 0;
    80006450:	4501                	li	a0,0
    80006452:	64aa                	ld	s1,136(sp)
}
    80006454:	60ea                	ld	ra,152(sp)
    80006456:	644a                	ld	s0,144(sp)
    80006458:	690a                	ld	s2,128(sp)
    8000645a:	610d                	addi	sp,sp,160
    8000645c:	8082                	ret
    8000645e:	64aa                	ld	s1,136(sp)
    end_op();
    80006460:	ffffe097          	auipc	ra,0xffffe
    80006464:	6f8080e7          	jalr	1784(ra) # 80004b58 <end_op>
    return -1;
    80006468:	557d                	li	a0,-1
    8000646a:	b7ed                	j	80006454 <sys_chdir+0x7c>
    iunlockput(ip);
    8000646c:	8526                	mv	a0,s1
    8000646e:	ffffe097          	auipc	ra,0xffffe
    80006472:	f08080e7          	jalr	-248(ra) # 80004376 <iunlockput>
    end_op();
    80006476:	ffffe097          	auipc	ra,0xffffe
    8000647a:	6e2080e7          	jalr	1762(ra) # 80004b58 <end_op>
    return -1;
    8000647e:	557d                	li	a0,-1
    80006480:	64aa                	ld	s1,136(sp)
    80006482:	bfc9                	j	80006454 <sys_chdir+0x7c>

0000000080006484 <sys_exec>:

uint64
sys_exec(void)
{
    80006484:	7121                	addi	sp,sp,-448
    80006486:	ff06                	sd	ra,440(sp)
    80006488:	fb22                	sd	s0,432(sp)
    8000648a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000648c:	e4840593          	addi	a1,s0,-440
    80006490:	4505                	li	a0,1
    80006492:	ffffd097          	auipc	ra,0xffffd
    80006496:	f84080e7          	jalr	-124(ra) # 80003416 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000649a:	08000613          	li	a2,128
    8000649e:	f5040593          	addi	a1,s0,-176
    800064a2:	4501                	li	a0,0
    800064a4:	ffffd097          	auipc	ra,0xffffd
    800064a8:	f92080e7          	jalr	-110(ra) # 80003436 <argstr>
    800064ac:	87aa                	mv	a5,a0
    return -1;
    800064ae:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800064b0:	0e07c263          	bltz	a5,80006594 <sys_exec+0x110>
    800064b4:	f726                	sd	s1,424(sp)
    800064b6:	f34a                	sd	s2,416(sp)
    800064b8:	ef4e                	sd	s3,408(sp)
    800064ba:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800064bc:	10000613          	li	a2,256
    800064c0:	4581                	li	a1,0
    800064c2:	e5040513          	addi	a0,s0,-432
    800064c6:	ffffb097          	auipc	ra,0xffffb
    800064ca:	b6c080e7          	jalr	-1172(ra) # 80001032 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800064ce:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800064d2:	89a6                	mv	s3,s1
    800064d4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800064d6:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800064da:	00391513          	slli	a0,s2,0x3
    800064de:	e4040593          	addi	a1,s0,-448
    800064e2:	e4843783          	ld	a5,-440(s0)
    800064e6:	953e                	add	a0,a0,a5
    800064e8:	ffffd097          	auipc	ra,0xffffd
    800064ec:	e70080e7          	jalr	-400(ra) # 80003358 <fetchaddr>
    800064f0:	02054a63          	bltz	a0,80006524 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    800064f4:	e4043783          	ld	a5,-448(s0)
    800064f8:	c7b9                	beqz	a5,80006546 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800064fa:	ffffa097          	auipc	ra,0xffffa
    800064fe:	78c080e7          	jalr	1932(ra) # 80000c86 <kalloc>
    80006502:	85aa                	mv	a1,a0
    80006504:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006508:	cd11                	beqz	a0,80006524 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000650a:	6605                	lui	a2,0x1
    8000650c:	e4043503          	ld	a0,-448(s0)
    80006510:	ffffd097          	auipc	ra,0xffffd
    80006514:	e9a080e7          	jalr	-358(ra) # 800033aa <fetchstr>
    80006518:	00054663          	bltz	a0,80006524 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    8000651c:	0905                	addi	s2,s2,1
    8000651e:	09a1                	addi	s3,s3,8
    80006520:	fb491de3          	bne	s2,s4,800064da <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006524:	f5040913          	addi	s2,s0,-176
    80006528:	6088                	ld	a0,0(s1)
    8000652a:	c125                	beqz	a0,8000658a <sys_exec+0x106>
    kfree(argv[i]);
    8000652c:	ffffa097          	auipc	ra,0xffffa
    80006530:	568080e7          	jalr	1384(ra) # 80000a94 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006534:	04a1                	addi	s1,s1,8
    80006536:	ff2499e3          	bne	s1,s2,80006528 <sys_exec+0xa4>
  return -1;
    8000653a:	557d                	li	a0,-1
    8000653c:	74ba                	ld	s1,424(sp)
    8000653e:	791a                	ld	s2,416(sp)
    80006540:	69fa                	ld	s3,408(sp)
    80006542:	6a5a                	ld	s4,400(sp)
    80006544:	a881                	j	80006594 <sys_exec+0x110>
      argv[i] = 0;
    80006546:	0009079b          	sext.w	a5,s2
    8000654a:	078e                	slli	a5,a5,0x3
    8000654c:	fd078793          	addi	a5,a5,-48
    80006550:	97a2                	add	a5,a5,s0
    80006552:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006556:	e5040593          	addi	a1,s0,-432
    8000655a:	f5040513          	addi	a0,s0,-176
    8000655e:	fffff097          	auipc	ra,0xfffff
    80006562:	120080e7          	jalr	288(ra) # 8000567e <exec>
    80006566:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006568:	f5040993          	addi	s3,s0,-176
    8000656c:	6088                	ld	a0,0(s1)
    8000656e:	c901                	beqz	a0,8000657e <sys_exec+0xfa>
    kfree(argv[i]);
    80006570:	ffffa097          	auipc	ra,0xffffa
    80006574:	524080e7          	jalr	1316(ra) # 80000a94 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006578:	04a1                	addi	s1,s1,8
    8000657a:	ff3499e3          	bne	s1,s3,8000656c <sys_exec+0xe8>
  return ret;
    8000657e:	854a                	mv	a0,s2
    80006580:	74ba                	ld	s1,424(sp)
    80006582:	791a                	ld	s2,416(sp)
    80006584:	69fa                	ld	s3,408(sp)
    80006586:	6a5a                	ld	s4,400(sp)
    80006588:	a031                	j	80006594 <sys_exec+0x110>
  return -1;
    8000658a:	557d                	li	a0,-1
    8000658c:	74ba                	ld	s1,424(sp)
    8000658e:	791a                	ld	s2,416(sp)
    80006590:	69fa                	ld	s3,408(sp)
    80006592:	6a5a                	ld	s4,400(sp)
}
    80006594:	70fa                	ld	ra,440(sp)
    80006596:	745a                	ld	s0,432(sp)
    80006598:	6139                	addi	sp,sp,448
    8000659a:	8082                	ret

000000008000659c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000659c:	7139                	addi	sp,sp,-64
    8000659e:	fc06                	sd	ra,56(sp)
    800065a0:	f822                	sd	s0,48(sp)
    800065a2:	f426                	sd	s1,40(sp)
    800065a4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800065a6:	ffffc097          	auipc	ra,0xffffc
    800065aa:	a02080e7          	jalr	-1534(ra) # 80001fa8 <myproc>
    800065ae:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800065b0:	fd840593          	addi	a1,s0,-40
    800065b4:	4501                	li	a0,0
    800065b6:	ffffd097          	auipc	ra,0xffffd
    800065ba:	e60080e7          	jalr	-416(ra) # 80003416 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800065be:	fc840593          	addi	a1,s0,-56
    800065c2:	fd040513          	addi	a0,s0,-48
    800065c6:	fffff097          	auipc	ra,0xfffff
    800065ca:	d50080e7          	jalr	-688(ra) # 80005316 <pipealloc>
    return -1;
    800065ce:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800065d0:	0c054463          	bltz	a0,80006698 <sys_pipe+0xfc>
  fd0 = -1;
    800065d4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800065d8:	fd043503          	ld	a0,-48(s0)
    800065dc:	fffff097          	auipc	ra,0xfffff
    800065e0:	4e0080e7          	jalr	1248(ra) # 80005abc <fdalloc>
    800065e4:	fca42223          	sw	a0,-60(s0)
    800065e8:	08054b63          	bltz	a0,8000667e <sys_pipe+0xe2>
    800065ec:	fc843503          	ld	a0,-56(s0)
    800065f0:	fffff097          	auipc	ra,0xfffff
    800065f4:	4cc080e7          	jalr	1228(ra) # 80005abc <fdalloc>
    800065f8:	fca42023          	sw	a0,-64(s0)
    800065fc:	06054863          	bltz	a0,8000666c <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006600:	4691                	li	a3,4
    80006602:	fc440613          	addi	a2,s0,-60
    80006606:	fd843583          	ld	a1,-40(s0)
    8000660a:	68a8                	ld	a0,80(s1)
    8000660c:	ffffb097          	auipc	ra,0xffffb
    80006610:	3da080e7          	jalr	986(ra) # 800019e6 <copyout>
    80006614:	02054063          	bltz	a0,80006634 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006618:	4691                	li	a3,4
    8000661a:	fc040613          	addi	a2,s0,-64
    8000661e:	fd843583          	ld	a1,-40(s0)
    80006622:	0591                	addi	a1,a1,4
    80006624:	68a8                	ld	a0,80(s1)
    80006626:	ffffb097          	auipc	ra,0xffffb
    8000662a:	3c0080e7          	jalr	960(ra) # 800019e6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000662e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006630:	06055463          	bgez	a0,80006698 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006634:	fc442783          	lw	a5,-60(s0)
    80006638:	07e9                	addi	a5,a5,26
    8000663a:	078e                	slli	a5,a5,0x3
    8000663c:	97a6                	add	a5,a5,s1
    8000663e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006642:	fc042783          	lw	a5,-64(s0)
    80006646:	07e9                	addi	a5,a5,26
    80006648:	078e                	slli	a5,a5,0x3
    8000664a:	94be                	add	s1,s1,a5
    8000664c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006650:	fd043503          	ld	a0,-48(s0)
    80006654:	fffff097          	auipc	ra,0xfffff
    80006658:	954080e7          	jalr	-1708(ra) # 80004fa8 <fileclose>
    fileclose(wf);
    8000665c:	fc843503          	ld	a0,-56(s0)
    80006660:	fffff097          	auipc	ra,0xfffff
    80006664:	948080e7          	jalr	-1720(ra) # 80004fa8 <fileclose>
    return -1;
    80006668:	57fd                	li	a5,-1
    8000666a:	a03d                	j	80006698 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000666c:	fc442783          	lw	a5,-60(s0)
    80006670:	0007c763          	bltz	a5,8000667e <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006674:	07e9                	addi	a5,a5,26
    80006676:	078e                	slli	a5,a5,0x3
    80006678:	97a6                	add	a5,a5,s1
    8000667a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000667e:	fd043503          	ld	a0,-48(s0)
    80006682:	fffff097          	auipc	ra,0xfffff
    80006686:	926080e7          	jalr	-1754(ra) # 80004fa8 <fileclose>
    fileclose(wf);
    8000668a:	fc843503          	ld	a0,-56(s0)
    8000668e:	fffff097          	auipc	ra,0xfffff
    80006692:	91a080e7          	jalr	-1766(ra) # 80004fa8 <fileclose>
    return -1;
    80006696:	57fd                	li	a5,-1
}
    80006698:	853e                	mv	a0,a5
    8000669a:	70e2                	ld	ra,56(sp)
    8000669c:	7442                	ld	s0,48(sp)
    8000669e:	74a2                	ld	s1,40(sp)
    800066a0:	6121                	addi	sp,sp,64
    800066a2:	8082                	ret
	...

00000000800066b0 <kernelvec>:
    800066b0:	7111                	addi	sp,sp,-256
    800066b2:	e006                	sd	ra,0(sp)
    800066b4:	e40a                	sd	sp,8(sp)
    800066b6:	e80e                	sd	gp,16(sp)
    800066b8:	ec12                	sd	tp,24(sp)
    800066ba:	f016                	sd	t0,32(sp)
    800066bc:	f41a                	sd	t1,40(sp)
    800066be:	f81e                	sd	t2,48(sp)
    800066c0:	fc22                	sd	s0,56(sp)
    800066c2:	e0a6                	sd	s1,64(sp)
    800066c4:	e4aa                	sd	a0,72(sp)
    800066c6:	e8ae                	sd	a1,80(sp)
    800066c8:	ecb2                	sd	a2,88(sp)
    800066ca:	f0b6                	sd	a3,96(sp)
    800066cc:	f4ba                	sd	a4,104(sp)
    800066ce:	f8be                	sd	a5,112(sp)
    800066d0:	fcc2                	sd	a6,120(sp)
    800066d2:	e146                	sd	a7,128(sp)
    800066d4:	e54a                	sd	s2,136(sp)
    800066d6:	e94e                	sd	s3,144(sp)
    800066d8:	ed52                	sd	s4,152(sp)
    800066da:	f156                	sd	s5,160(sp)
    800066dc:	f55a                	sd	s6,168(sp)
    800066de:	f95e                	sd	s7,176(sp)
    800066e0:	fd62                	sd	s8,184(sp)
    800066e2:	e1e6                	sd	s9,192(sp)
    800066e4:	e5ea                	sd	s10,200(sp)
    800066e6:	e9ee                	sd	s11,208(sp)
    800066e8:	edf2                	sd	t3,216(sp)
    800066ea:	f1f6                	sd	t4,224(sp)
    800066ec:	f5fa                	sd	t5,232(sp)
    800066ee:	f9fe                	sd	t6,240(sp)
    800066f0:	b35fc0ef          	jal	80003224 <kerneltrap>
    800066f4:	6082                	ld	ra,0(sp)
    800066f6:	6122                	ld	sp,8(sp)
    800066f8:	61c2                	ld	gp,16(sp)
    800066fa:	7282                	ld	t0,32(sp)
    800066fc:	7322                	ld	t1,40(sp)
    800066fe:	73c2                	ld	t2,48(sp)
    80006700:	7462                	ld	s0,56(sp)
    80006702:	6486                	ld	s1,64(sp)
    80006704:	6526                	ld	a0,72(sp)
    80006706:	65c6                	ld	a1,80(sp)
    80006708:	6666                	ld	a2,88(sp)
    8000670a:	7686                	ld	a3,96(sp)
    8000670c:	7726                	ld	a4,104(sp)
    8000670e:	77c6                	ld	a5,112(sp)
    80006710:	7866                	ld	a6,120(sp)
    80006712:	688a                	ld	a7,128(sp)
    80006714:	692a                	ld	s2,136(sp)
    80006716:	69ca                	ld	s3,144(sp)
    80006718:	6a6a                	ld	s4,152(sp)
    8000671a:	7a8a                	ld	s5,160(sp)
    8000671c:	7b2a                	ld	s6,168(sp)
    8000671e:	7bca                	ld	s7,176(sp)
    80006720:	7c6a                	ld	s8,184(sp)
    80006722:	6c8e                	ld	s9,192(sp)
    80006724:	6d2e                	ld	s10,200(sp)
    80006726:	6dce                	ld	s11,208(sp)
    80006728:	6e6e                	ld	t3,216(sp)
    8000672a:	7e8e                	ld	t4,224(sp)
    8000672c:	7f2e                	ld	t5,232(sp)
    8000672e:	7fce                	ld	t6,240(sp)
    80006730:	6111                	addi	sp,sp,256
    80006732:	10200073          	sret
    80006736:	00000013          	nop
    8000673a:	00000013          	nop
    8000673e:	0001                	nop

0000000080006740 <timervec>:
    80006740:	34051573          	csrrw	a0,mscratch,a0
    80006744:	e10c                	sd	a1,0(a0)
    80006746:	e510                	sd	a2,8(a0)
    80006748:	e914                	sd	a3,16(a0)
    8000674a:	6d0c                	ld	a1,24(a0)
    8000674c:	7110                	ld	a2,32(a0)
    8000674e:	6194                	ld	a3,0(a1)
    80006750:	96b2                	add	a3,a3,a2
    80006752:	e194                	sd	a3,0(a1)
    80006754:	4589                	li	a1,2
    80006756:	14459073          	csrw	sip,a1
    8000675a:	6914                	ld	a3,16(a0)
    8000675c:	6510                	ld	a2,8(a0)
    8000675e:	610c                	ld	a1,0(a0)
    80006760:	34051573          	csrrw	a0,mscratch,a0
    80006764:	30200073          	mret
	...

000000008000676a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000676a:	1141                	addi	sp,sp,-16
    8000676c:	e422                	sd	s0,8(sp)
    8000676e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006770:	0c0007b7          	lui	a5,0xc000
    80006774:	4705                	li	a4,1
    80006776:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006778:	0c0007b7          	lui	a5,0xc000
    8000677c:	c3d8                	sw	a4,4(a5)
}
    8000677e:	6422                	ld	s0,8(sp)
    80006780:	0141                	addi	sp,sp,16
    80006782:	8082                	ret

0000000080006784 <plicinithart>:

void
plicinithart(void)
{
    80006784:	1141                	addi	sp,sp,-16
    80006786:	e406                	sd	ra,8(sp)
    80006788:	e022                	sd	s0,0(sp)
    8000678a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000678c:	ffffb097          	auipc	ra,0xffffb
    80006790:	7f0080e7          	jalr	2032(ra) # 80001f7c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006794:	0085171b          	slliw	a4,a0,0x8
    80006798:	0c0027b7          	lui	a5,0xc002
    8000679c:	97ba                	add	a5,a5,a4
    8000679e:	40200713          	li	a4,1026
    800067a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800067a6:	00d5151b          	slliw	a0,a0,0xd
    800067aa:	0c2017b7          	lui	a5,0xc201
    800067ae:	97aa                	add	a5,a5,a0
    800067b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800067b4:	60a2                	ld	ra,8(sp)
    800067b6:	6402                	ld	s0,0(sp)
    800067b8:	0141                	addi	sp,sp,16
    800067ba:	8082                	ret

00000000800067bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800067bc:	1141                	addi	sp,sp,-16
    800067be:	e406                	sd	ra,8(sp)
    800067c0:	e022                	sd	s0,0(sp)
    800067c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800067c4:	ffffb097          	auipc	ra,0xffffb
    800067c8:	7b8080e7          	jalr	1976(ra) # 80001f7c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800067cc:	00d5151b          	slliw	a0,a0,0xd
    800067d0:	0c2017b7          	lui	a5,0xc201
    800067d4:	97aa                	add	a5,a5,a0
  return irq;
}
    800067d6:	43c8                	lw	a0,4(a5)
    800067d8:	60a2                	ld	ra,8(sp)
    800067da:	6402                	ld	s0,0(sp)
    800067dc:	0141                	addi	sp,sp,16
    800067de:	8082                	ret

00000000800067e0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800067e0:	1101                	addi	sp,sp,-32
    800067e2:	ec06                	sd	ra,24(sp)
    800067e4:	e822                	sd	s0,16(sp)
    800067e6:	e426                	sd	s1,8(sp)
    800067e8:	1000                	addi	s0,sp,32
    800067ea:	84aa                	mv	s1,a0
  int hart = cpuid();
    800067ec:	ffffb097          	auipc	ra,0xffffb
    800067f0:	790080e7          	jalr	1936(ra) # 80001f7c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800067f4:	00d5151b          	slliw	a0,a0,0xd
    800067f8:	0c2017b7          	lui	a5,0xc201
    800067fc:	97aa                	add	a5,a5,a0
    800067fe:	c3c4                	sw	s1,4(a5)
}
    80006800:	60e2                	ld	ra,24(sp)
    80006802:	6442                	ld	s0,16(sp)
    80006804:	64a2                	ld	s1,8(sp)
    80006806:	6105                	addi	sp,sp,32
    80006808:	8082                	ret

000000008000680a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000680a:	1141                	addi	sp,sp,-16
    8000680c:	e406                	sd	ra,8(sp)
    8000680e:	e022                	sd	s0,0(sp)
    80006810:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006812:	479d                	li	a5,7
    80006814:	04a7cc63          	blt	a5,a0,8000686c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006818:	00026797          	auipc	a5,0x26
    8000681c:	28078793          	addi	a5,a5,640 # 8002ca98 <disk>
    80006820:	97aa                	add	a5,a5,a0
    80006822:	0187c783          	lbu	a5,24(a5)
    80006826:	ebb9                	bnez	a5,8000687c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006828:	00451693          	slli	a3,a0,0x4
    8000682c:	00026797          	auipc	a5,0x26
    80006830:	26c78793          	addi	a5,a5,620 # 8002ca98 <disk>
    80006834:	6398                	ld	a4,0(a5)
    80006836:	9736                	add	a4,a4,a3
    80006838:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000683c:	6398                	ld	a4,0(a5)
    8000683e:	9736                	add	a4,a4,a3
    80006840:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006844:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006848:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000684c:	97aa                	add	a5,a5,a0
    8000684e:	4705                	li	a4,1
    80006850:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006854:	00026517          	auipc	a0,0x26
    80006858:	25c50513          	addi	a0,a0,604 # 8002cab0 <disk+0x18>
    8000685c:	ffffc097          	auipc	ra,0xffffc
    80006860:	f62080e7          	jalr	-158(ra) # 800027be <wakeup>
}
    80006864:	60a2                	ld	ra,8(sp)
    80006866:	6402                	ld	s0,0(sp)
    80006868:	0141                	addi	sp,sp,16
    8000686a:	8082                	ret
    panic("free_desc 1");
    8000686c:	00002517          	auipc	a0,0x2
    80006870:	f6450513          	addi	a0,a0,-156 # 800087d0 <__func__.1+0x7c8>
    80006874:	ffffa097          	auipc	ra,0xffffa
    80006878:	cec080e7          	jalr	-788(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000687c:	00002517          	auipc	a0,0x2
    80006880:	f6450513          	addi	a0,a0,-156 # 800087e0 <__func__.1+0x7d8>
    80006884:	ffffa097          	auipc	ra,0xffffa
    80006888:	cdc080e7          	jalr	-804(ra) # 80000560 <panic>

000000008000688c <virtio_disk_init>:
{
    8000688c:	1101                	addi	sp,sp,-32
    8000688e:	ec06                	sd	ra,24(sp)
    80006890:	e822                	sd	s0,16(sp)
    80006892:	e426                	sd	s1,8(sp)
    80006894:	e04a                	sd	s2,0(sp)
    80006896:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006898:	00002597          	auipc	a1,0x2
    8000689c:	f5858593          	addi	a1,a1,-168 # 800087f0 <__func__.1+0x7e8>
    800068a0:	00026517          	auipc	a0,0x26
    800068a4:	32050513          	addi	a0,a0,800 # 8002cbc0 <disk+0x128>
    800068a8:	ffffa097          	auipc	ra,0xffffa
    800068ac:	5fe080e7          	jalr	1534(ra) # 80000ea6 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068b0:	100017b7          	lui	a5,0x10001
    800068b4:	4398                	lw	a4,0(a5)
    800068b6:	2701                	sext.w	a4,a4
    800068b8:	747277b7          	lui	a5,0x74727
    800068bc:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800068c0:	18f71c63          	bne	a4,a5,80006a58 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800068c4:	100017b7          	lui	a5,0x10001
    800068c8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800068ca:	439c                	lw	a5,0(a5)
    800068cc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068ce:	4709                	li	a4,2
    800068d0:	18e79463          	bne	a5,a4,80006a58 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068d4:	100017b7          	lui	a5,0x10001
    800068d8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800068da:	439c                	lw	a5,0(a5)
    800068dc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800068de:	16e79d63          	bne	a5,a4,80006a58 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800068e2:	100017b7          	lui	a5,0x10001
    800068e6:	47d8                	lw	a4,12(a5)
    800068e8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068ea:	554d47b7          	lui	a5,0x554d4
    800068ee:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800068f2:	16f71363          	bne	a4,a5,80006a58 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800068f6:	100017b7          	lui	a5,0x10001
    800068fa:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800068fe:	4705                	li	a4,1
    80006900:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006902:	470d                	li	a4,3
    80006904:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006906:	10001737          	lui	a4,0x10001
    8000690a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000690c:	c7ffe737          	lui	a4,0xc7ffe
    80006910:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd1b87>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006914:	8ef9                	and	a3,a3,a4
    80006916:	10001737          	lui	a4,0x10001
    8000691a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000691c:	472d                	li	a4,11
    8000691e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006920:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006924:	439c                	lw	a5,0(a5)
    80006926:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000692a:	8ba1                	andi	a5,a5,8
    8000692c:	12078e63          	beqz	a5,80006a68 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006930:	100017b7          	lui	a5,0x10001
    80006934:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006938:	100017b7          	lui	a5,0x10001
    8000693c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006940:	439c                	lw	a5,0(a5)
    80006942:	2781                	sext.w	a5,a5
    80006944:	12079a63          	bnez	a5,80006a78 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006948:	100017b7          	lui	a5,0x10001
    8000694c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006950:	439c                	lw	a5,0(a5)
    80006952:	2781                	sext.w	a5,a5
  if(max == 0)
    80006954:	12078a63          	beqz	a5,80006a88 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006958:	471d                	li	a4,7
    8000695a:	12f77f63          	bgeu	a4,a5,80006a98 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000695e:	ffffa097          	auipc	ra,0xffffa
    80006962:	328080e7          	jalr	808(ra) # 80000c86 <kalloc>
    80006966:	00026497          	auipc	s1,0x26
    8000696a:	13248493          	addi	s1,s1,306 # 8002ca98 <disk>
    8000696e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006970:	ffffa097          	auipc	ra,0xffffa
    80006974:	316080e7          	jalr	790(ra) # 80000c86 <kalloc>
    80006978:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000697a:	ffffa097          	auipc	ra,0xffffa
    8000697e:	30c080e7          	jalr	780(ra) # 80000c86 <kalloc>
    80006982:	87aa                	mv	a5,a0
    80006984:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006986:	6088                	ld	a0,0(s1)
    80006988:	12050063          	beqz	a0,80006aa8 <virtio_disk_init+0x21c>
    8000698c:	00026717          	auipc	a4,0x26
    80006990:	11473703          	ld	a4,276(a4) # 8002caa0 <disk+0x8>
    80006994:	10070a63          	beqz	a4,80006aa8 <virtio_disk_init+0x21c>
    80006998:	10078863          	beqz	a5,80006aa8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000699c:	6605                	lui	a2,0x1
    8000699e:	4581                	li	a1,0
    800069a0:	ffffa097          	auipc	ra,0xffffa
    800069a4:	692080e7          	jalr	1682(ra) # 80001032 <memset>
  memset(disk.avail, 0, PGSIZE);
    800069a8:	00026497          	auipc	s1,0x26
    800069ac:	0f048493          	addi	s1,s1,240 # 8002ca98 <disk>
    800069b0:	6605                	lui	a2,0x1
    800069b2:	4581                	li	a1,0
    800069b4:	6488                	ld	a0,8(s1)
    800069b6:	ffffa097          	auipc	ra,0xffffa
    800069ba:	67c080e7          	jalr	1660(ra) # 80001032 <memset>
  memset(disk.used, 0, PGSIZE);
    800069be:	6605                	lui	a2,0x1
    800069c0:	4581                	li	a1,0
    800069c2:	6888                	ld	a0,16(s1)
    800069c4:	ffffa097          	auipc	ra,0xffffa
    800069c8:	66e080e7          	jalr	1646(ra) # 80001032 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800069cc:	100017b7          	lui	a5,0x10001
    800069d0:	4721                	li	a4,8
    800069d2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800069d4:	4098                	lw	a4,0(s1)
    800069d6:	100017b7          	lui	a5,0x10001
    800069da:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800069de:	40d8                	lw	a4,4(s1)
    800069e0:	100017b7          	lui	a5,0x10001
    800069e4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800069e8:	649c                	ld	a5,8(s1)
    800069ea:	0007869b          	sext.w	a3,a5
    800069ee:	10001737          	lui	a4,0x10001
    800069f2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800069f6:	9781                	srai	a5,a5,0x20
    800069f8:	10001737          	lui	a4,0x10001
    800069fc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006a00:	689c                	ld	a5,16(s1)
    80006a02:	0007869b          	sext.w	a3,a5
    80006a06:	10001737          	lui	a4,0x10001
    80006a0a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006a0e:	9781                	srai	a5,a5,0x20
    80006a10:	10001737          	lui	a4,0x10001
    80006a14:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006a18:	10001737          	lui	a4,0x10001
    80006a1c:	4785                	li	a5,1
    80006a1e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006a20:	00f48c23          	sb	a5,24(s1)
    80006a24:	00f48ca3          	sb	a5,25(s1)
    80006a28:	00f48d23          	sb	a5,26(s1)
    80006a2c:	00f48da3          	sb	a5,27(s1)
    80006a30:	00f48e23          	sb	a5,28(s1)
    80006a34:	00f48ea3          	sb	a5,29(s1)
    80006a38:	00f48f23          	sb	a5,30(s1)
    80006a3c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006a40:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a44:	100017b7          	lui	a5,0x10001
    80006a48:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80006a4c:	60e2                	ld	ra,24(sp)
    80006a4e:	6442                	ld	s0,16(sp)
    80006a50:	64a2                	ld	s1,8(sp)
    80006a52:	6902                	ld	s2,0(sp)
    80006a54:	6105                	addi	sp,sp,32
    80006a56:	8082                	ret
    panic("could not find virtio disk");
    80006a58:	00002517          	auipc	a0,0x2
    80006a5c:	da850513          	addi	a0,a0,-600 # 80008800 <__func__.1+0x7f8>
    80006a60:	ffffa097          	auipc	ra,0xffffa
    80006a64:	b00080e7          	jalr	-1280(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006a68:	00002517          	auipc	a0,0x2
    80006a6c:	db850513          	addi	a0,a0,-584 # 80008820 <__func__.1+0x818>
    80006a70:	ffffa097          	auipc	ra,0xffffa
    80006a74:	af0080e7          	jalr	-1296(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006a78:	00002517          	auipc	a0,0x2
    80006a7c:	dc850513          	addi	a0,a0,-568 # 80008840 <__func__.1+0x838>
    80006a80:	ffffa097          	auipc	ra,0xffffa
    80006a84:	ae0080e7          	jalr	-1312(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006a88:	00002517          	auipc	a0,0x2
    80006a8c:	dd850513          	addi	a0,a0,-552 # 80008860 <__func__.1+0x858>
    80006a90:	ffffa097          	auipc	ra,0xffffa
    80006a94:	ad0080e7          	jalr	-1328(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006a98:	00002517          	auipc	a0,0x2
    80006a9c:	de850513          	addi	a0,a0,-536 # 80008880 <__func__.1+0x878>
    80006aa0:	ffffa097          	auipc	ra,0xffffa
    80006aa4:	ac0080e7          	jalr	-1344(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006aa8:	00002517          	auipc	a0,0x2
    80006aac:	df850513          	addi	a0,a0,-520 # 800088a0 <__func__.1+0x898>
    80006ab0:	ffffa097          	auipc	ra,0xffffa
    80006ab4:	ab0080e7          	jalr	-1360(ra) # 80000560 <panic>

0000000080006ab8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006ab8:	7159                	addi	sp,sp,-112
    80006aba:	f486                	sd	ra,104(sp)
    80006abc:	f0a2                	sd	s0,96(sp)
    80006abe:	eca6                	sd	s1,88(sp)
    80006ac0:	e8ca                	sd	s2,80(sp)
    80006ac2:	e4ce                	sd	s3,72(sp)
    80006ac4:	e0d2                	sd	s4,64(sp)
    80006ac6:	fc56                	sd	s5,56(sp)
    80006ac8:	f85a                	sd	s6,48(sp)
    80006aca:	f45e                	sd	s7,40(sp)
    80006acc:	f062                	sd	s8,32(sp)
    80006ace:	ec66                	sd	s9,24(sp)
    80006ad0:	1880                	addi	s0,sp,112
    80006ad2:	8a2a                	mv	s4,a0
    80006ad4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ad6:	00c52c83          	lw	s9,12(a0)
    80006ada:	001c9c9b          	slliw	s9,s9,0x1
    80006ade:	1c82                	slli	s9,s9,0x20
    80006ae0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006ae4:	00026517          	auipc	a0,0x26
    80006ae8:	0dc50513          	addi	a0,a0,220 # 8002cbc0 <disk+0x128>
    80006aec:	ffffa097          	auipc	ra,0xffffa
    80006af0:	44a080e7          	jalr	1098(ra) # 80000f36 <acquire>
  for(int i = 0; i < 3; i++){
    80006af4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006af6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006af8:	00026b17          	auipc	s6,0x26
    80006afc:	fa0b0b13          	addi	s6,s6,-96 # 8002ca98 <disk>
  for(int i = 0; i < 3; i++){
    80006b00:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b02:	00026c17          	auipc	s8,0x26
    80006b06:	0bec0c13          	addi	s8,s8,190 # 8002cbc0 <disk+0x128>
    80006b0a:	a0ad                	j	80006b74 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80006b0c:	00fb0733          	add	a4,s6,a5
    80006b10:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006b14:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006b16:	0207c563          	bltz	a5,80006b40 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006b1a:	2905                	addiw	s2,s2,1
    80006b1c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006b1e:	05590f63          	beq	s2,s5,80006b7c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006b22:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006b24:	00026717          	auipc	a4,0x26
    80006b28:	f7470713          	addi	a4,a4,-140 # 8002ca98 <disk>
    80006b2c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006b2e:	01874683          	lbu	a3,24(a4)
    80006b32:	fee9                	bnez	a3,80006b0c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006b34:	2785                	addiw	a5,a5,1
    80006b36:	0705                	addi	a4,a4,1
    80006b38:	fe979be3          	bne	a5,s1,80006b2e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006b3c:	57fd                	li	a5,-1
    80006b3e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006b40:	03205163          	blez	s2,80006b62 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006b44:	f9042503          	lw	a0,-112(s0)
    80006b48:	00000097          	auipc	ra,0x0
    80006b4c:	cc2080e7          	jalr	-830(ra) # 8000680a <free_desc>
      for(int j = 0; j < i; j++)
    80006b50:	4785                	li	a5,1
    80006b52:	0127d863          	bge	a5,s2,80006b62 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006b56:	f9442503          	lw	a0,-108(s0)
    80006b5a:	00000097          	auipc	ra,0x0
    80006b5e:	cb0080e7          	jalr	-848(ra) # 8000680a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b62:	85e2                	mv	a1,s8
    80006b64:	00026517          	auipc	a0,0x26
    80006b68:	f4c50513          	addi	a0,a0,-180 # 8002cab0 <disk+0x18>
    80006b6c:	ffffc097          	auipc	ra,0xffffc
    80006b70:	bee080e7          	jalr	-1042(ra) # 8000275a <sleep>
  for(int i = 0; i < 3; i++){
    80006b74:	f9040613          	addi	a2,s0,-112
    80006b78:	894e                	mv	s2,s3
    80006b7a:	b765                	j	80006b22 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006b7c:	f9042503          	lw	a0,-112(s0)
    80006b80:	00451693          	slli	a3,a0,0x4

  if(write)
    80006b84:	00026797          	auipc	a5,0x26
    80006b88:	f1478793          	addi	a5,a5,-236 # 8002ca98 <disk>
    80006b8c:	00a50713          	addi	a4,a0,10
    80006b90:	0712                	slli	a4,a4,0x4
    80006b92:	973e                	add	a4,a4,a5
    80006b94:	01703633          	snez	a2,s7
    80006b98:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006b9a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006b9e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006ba2:	6398                	ld	a4,0(a5)
    80006ba4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ba6:	0a868613          	addi	a2,a3,168
    80006baa:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006bac:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006bae:	6390                	ld	a2,0(a5)
    80006bb0:	00d605b3          	add	a1,a2,a3
    80006bb4:	4741                	li	a4,16
    80006bb6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006bb8:	4805                	li	a6,1
    80006bba:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006bbe:	f9442703          	lw	a4,-108(s0)
    80006bc2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006bc6:	0712                	slli	a4,a4,0x4
    80006bc8:	963a                	add	a2,a2,a4
    80006bca:	058a0593          	addi	a1,s4,88
    80006bce:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006bd0:	0007b883          	ld	a7,0(a5)
    80006bd4:	9746                	add	a4,a4,a7
    80006bd6:	40000613          	li	a2,1024
    80006bda:	c710                	sw	a2,8(a4)
  if(write)
    80006bdc:	001bb613          	seqz	a2,s7
    80006be0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006be4:	00166613          	ori	a2,a2,1
    80006be8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006bec:	f9842583          	lw	a1,-104(s0)
    80006bf0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006bf4:	00250613          	addi	a2,a0,2
    80006bf8:	0612                	slli	a2,a2,0x4
    80006bfa:	963e                	add	a2,a2,a5
    80006bfc:	577d                	li	a4,-1
    80006bfe:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006c02:	0592                	slli	a1,a1,0x4
    80006c04:	98ae                	add	a7,a7,a1
    80006c06:	03068713          	addi	a4,a3,48
    80006c0a:	973e                	add	a4,a4,a5
    80006c0c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006c10:	6398                	ld	a4,0(a5)
    80006c12:	972e                	add	a4,a4,a1
    80006c14:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006c18:	4689                	li	a3,2
    80006c1a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006c1e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006c22:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006c26:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006c2a:	6794                	ld	a3,8(a5)
    80006c2c:	0026d703          	lhu	a4,2(a3)
    80006c30:	8b1d                	andi	a4,a4,7
    80006c32:	0706                	slli	a4,a4,0x1
    80006c34:	96ba                	add	a3,a3,a4
    80006c36:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006c3a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c3e:	6798                	ld	a4,8(a5)
    80006c40:	00275783          	lhu	a5,2(a4)
    80006c44:	2785                	addiw	a5,a5,1
    80006c46:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006c4a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006c4e:	100017b7          	lui	a5,0x10001
    80006c52:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006c56:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006c5a:	00026917          	auipc	s2,0x26
    80006c5e:	f6690913          	addi	s2,s2,-154 # 8002cbc0 <disk+0x128>
  while(b->disk == 1) {
    80006c62:	4485                	li	s1,1
    80006c64:	01079c63          	bne	a5,a6,80006c7c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006c68:	85ca                	mv	a1,s2
    80006c6a:	8552                	mv	a0,s4
    80006c6c:	ffffc097          	auipc	ra,0xffffc
    80006c70:	aee080e7          	jalr	-1298(ra) # 8000275a <sleep>
  while(b->disk == 1) {
    80006c74:	004a2783          	lw	a5,4(s4)
    80006c78:	fe9788e3          	beq	a5,s1,80006c68 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006c7c:	f9042903          	lw	s2,-112(s0)
    80006c80:	00290713          	addi	a4,s2,2
    80006c84:	0712                	slli	a4,a4,0x4
    80006c86:	00026797          	auipc	a5,0x26
    80006c8a:	e1278793          	addi	a5,a5,-494 # 8002ca98 <disk>
    80006c8e:	97ba                	add	a5,a5,a4
    80006c90:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006c94:	00026997          	auipc	s3,0x26
    80006c98:	e0498993          	addi	s3,s3,-508 # 8002ca98 <disk>
    80006c9c:	00491713          	slli	a4,s2,0x4
    80006ca0:	0009b783          	ld	a5,0(s3)
    80006ca4:	97ba                	add	a5,a5,a4
    80006ca6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006caa:	854a                	mv	a0,s2
    80006cac:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006cb0:	00000097          	auipc	ra,0x0
    80006cb4:	b5a080e7          	jalr	-1190(ra) # 8000680a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006cb8:	8885                	andi	s1,s1,1
    80006cba:	f0ed                	bnez	s1,80006c9c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006cbc:	00026517          	auipc	a0,0x26
    80006cc0:	f0450513          	addi	a0,a0,-252 # 8002cbc0 <disk+0x128>
    80006cc4:	ffffa097          	auipc	ra,0xffffa
    80006cc8:	326080e7          	jalr	806(ra) # 80000fea <release>
}
    80006ccc:	70a6                	ld	ra,104(sp)
    80006cce:	7406                	ld	s0,96(sp)
    80006cd0:	64e6                	ld	s1,88(sp)
    80006cd2:	6946                	ld	s2,80(sp)
    80006cd4:	69a6                	ld	s3,72(sp)
    80006cd6:	6a06                	ld	s4,64(sp)
    80006cd8:	7ae2                	ld	s5,56(sp)
    80006cda:	7b42                	ld	s6,48(sp)
    80006cdc:	7ba2                	ld	s7,40(sp)
    80006cde:	7c02                	ld	s8,32(sp)
    80006ce0:	6ce2                	ld	s9,24(sp)
    80006ce2:	6165                	addi	sp,sp,112
    80006ce4:	8082                	ret

0000000080006ce6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006ce6:	1101                	addi	sp,sp,-32
    80006ce8:	ec06                	sd	ra,24(sp)
    80006cea:	e822                	sd	s0,16(sp)
    80006cec:	e426                	sd	s1,8(sp)
    80006cee:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006cf0:	00026497          	auipc	s1,0x26
    80006cf4:	da848493          	addi	s1,s1,-600 # 8002ca98 <disk>
    80006cf8:	00026517          	auipc	a0,0x26
    80006cfc:	ec850513          	addi	a0,a0,-312 # 8002cbc0 <disk+0x128>
    80006d00:	ffffa097          	auipc	ra,0xffffa
    80006d04:	236080e7          	jalr	566(ra) # 80000f36 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006d08:	100017b7          	lui	a5,0x10001
    80006d0c:	53b8                	lw	a4,96(a5)
    80006d0e:	8b0d                	andi	a4,a4,3
    80006d10:	100017b7          	lui	a5,0x10001
    80006d14:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006d16:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006d1a:	689c                	ld	a5,16(s1)
    80006d1c:	0204d703          	lhu	a4,32(s1)
    80006d20:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006d24:	04f70863          	beq	a4,a5,80006d74 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006d28:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006d2c:	6898                	ld	a4,16(s1)
    80006d2e:	0204d783          	lhu	a5,32(s1)
    80006d32:	8b9d                	andi	a5,a5,7
    80006d34:	078e                	slli	a5,a5,0x3
    80006d36:	97ba                	add	a5,a5,a4
    80006d38:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006d3a:	00278713          	addi	a4,a5,2
    80006d3e:	0712                	slli	a4,a4,0x4
    80006d40:	9726                	add	a4,a4,s1
    80006d42:	01074703          	lbu	a4,16(a4)
    80006d46:	e721                	bnez	a4,80006d8e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006d48:	0789                	addi	a5,a5,2
    80006d4a:	0792                	slli	a5,a5,0x4
    80006d4c:	97a6                	add	a5,a5,s1
    80006d4e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006d50:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006d54:	ffffc097          	auipc	ra,0xffffc
    80006d58:	a6a080e7          	jalr	-1430(ra) # 800027be <wakeup>

    disk.used_idx += 1;
    80006d5c:	0204d783          	lhu	a5,32(s1)
    80006d60:	2785                	addiw	a5,a5,1
    80006d62:	17c2                	slli	a5,a5,0x30
    80006d64:	93c1                	srli	a5,a5,0x30
    80006d66:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006d6a:	6898                	ld	a4,16(s1)
    80006d6c:	00275703          	lhu	a4,2(a4)
    80006d70:	faf71ce3          	bne	a4,a5,80006d28 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006d74:	00026517          	auipc	a0,0x26
    80006d78:	e4c50513          	addi	a0,a0,-436 # 8002cbc0 <disk+0x128>
    80006d7c:	ffffa097          	auipc	ra,0xffffa
    80006d80:	26e080e7          	jalr	622(ra) # 80000fea <release>
}
    80006d84:	60e2                	ld	ra,24(sp)
    80006d86:	6442                	ld	s0,16(sp)
    80006d88:	64a2                	ld	s1,8(sp)
    80006d8a:	6105                	addi	sp,sp,32
    80006d8c:	8082                	ret
      panic("virtio_disk_intr status");
    80006d8e:	00002517          	auipc	a0,0x2
    80006d92:	b2a50513          	addi	a0,a0,-1238 # 800088b8 <__func__.1+0x8b0>
    80006d96:	ffff9097          	auipc	ra,0xffff9
    80006d9a:	7ca080e7          	jalr	1994(ra) # 80000560 <panic>
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
