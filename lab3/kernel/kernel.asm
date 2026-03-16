
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	5f013103          	ld	sp,1520(sp) # 8000b5f0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	61070713          	addi	a4,a4,1552 # 8000b660 <timer_scratch>
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
    80000066:	56e78793          	addi	a5,a5,1390 # 800065d0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd1d17>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	11c78793          	addi	a5,a5,284 # 800011c8 <main>
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
    8000012e:	984080e7          	jalr	-1660(ra) # 80002aae <either_copyin>
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
    80000190:	61450513          	addi	a0,a0,1556 # 800137a0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	d9a080e7          	jalr	-614(ra) # 80000f2e <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	60448493          	addi	s1,s1,1540 # 800137a0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	69490913          	addi	s2,s2,1684 # 80013838 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	ce2080e7          	jalr	-798(ra) # 80001e9e <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	734080e7          	jalr	1844(ra) # 800028f8 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	47e080e7          	jalr	1150(ra) # 80002650 <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	5b870713          	addi	a4,a4,1464 # 800137a0 <cons>
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
    8000021e:	83e080e7          	jalr	-1986(ra) # 80002a58 <either_copyout>
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
    8000023a:	56a50513          	addi	a0,a0,1386 # 800137a0 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	da4080e7          	jalr	-604(ra) # 80000fe2 <release>
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
    80000268:	5cf72a23          	sw	a5,1492(a4) # 80013838 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	52650513          	addi	a0,a0,1318 # 800137a0 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	d60080e7          	jalr	-672(ra) # 80000fe2 <release>
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
    800002e6:	4be50513          	addi	a0,a0,1214 # 800137a0 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	c44080e7          	jalr	-956(ra) # 80000f2e <acquire>

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
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	7fc080e7          	jalr	2044(ra) # 80002b04 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	49050513          	addi	a0,a0,1168 # 800137a0 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	cca080e7          	jalr	-822(ra) # 80000fe2 <release>
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
    80000336:	46e70713          	addi	a4,a4,1134 # 800137a0 <cons>
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
    80000360:	44478793          	addi	a5,a5,1092 # 800137a0 <cons>
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
    8000038e:	4ae7a783          	lw	a5,1198(a5) # 80013838 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	40070713          	addi	a4,a4,1024 # 800137a0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	3f048493          	addi	s1,s1,1008 # 800137a0 <cons>
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
    800003fa:	3aa70713          	addi	a4,a4,938 # 800137a0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	42f72a23          	sw	a5,1076(a4) # 80013840 <cons+0xa0>
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
    80000436:	36e78793          	addi	a5,a5,878 # 800137a0 <cons>
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
    8000045a:	3ec7a323          	sw	a2,998(a5) # 8001383c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	3da50513          	addi	a0,a0,986 # 80013838 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	24e080e7          	jalr	590(ra) # 800026b4 <wakeup>
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
    80000484:	32050513          	addi	a0,a0,800 # 800137a0 <cons>
    80000488:	00001097          	auipc	ra,0x1
    8000048c:	a16080e7          	jalr	-1514(ra) # 80000e9e <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	0002b797          	auipc	a5,0x2b
    8000049c:	4b878793          	addi	a5,a5,1208 # 8002b950 <devsw>
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
    800004da:	3f260613          	addi	a2,a2,1010 # 800088c8 <digits>
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
    80000582:	2e07a123          	sw	zero,738(a5) # 80013860 <pr+0x18>
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
    800005b6:	04f72f23          	sw	a5,94(a4) # 8000b610 <panicked>
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
    800005e0:	284d2d03          	lw	s10,644(s10) # 80013860 <pr+0x18>
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
    8000061e:	2aea8a93          	addi	s5,s5,686 # 800088c8 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00013517          	auipc	a0,0x13
    80000630:	21c50513          	addi	a0,a0,540 # 80013848 <pr>
    80000634:	00001097          	auipc	ra,0x1
    80000638:	8fa080e7          	jalr	-1798(ra) # 80000f2e <acquire>
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
    800007b6:	09650513          	addi	a0,a0,150 # 80013848 <pr>
    800007ba:	00001097          	auipc	ra,0x1
    800007be:	828080e7          	jalr	-2008(ra) # 80000fe2 <release>
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
    800007d2:	07a48493          	addi	s1,s1,122 # 80013848 <pr>
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	86a58593          	addi	a1,a1,-1942 # 80008040 <__func__.1+0x38>
    800007de:	8526                	mv	a0,s1
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	6be080e7          	jalr	1726(ra) # 80000e9e <initlock>
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
    8000083e:	02e50513          	addi	a0,a0,46 # 80013868 <uart_tx_lock>
    80000842:	00000097          	auipc	ra,0x0
    80000846:	65c080e7          	jalr	1628(ra) # 80000e9e <initlock>
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
    80000862:	684080e7          	jalr	1668(ra) # 80000ee2 <push_off>

  if(panicked){
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	daa7a783          	lw	a5,-598(a5) # 8000b610 <panicked>
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
    80000890:	6f6080e7          	jalr	1782(ra) # 80000f82 <pop_off>
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
    800008a4:	d787b783          	ld	a5,-648(a5) # 8000b618 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	d7873703          	ld	a4,-648(a4) # 8000b620 <uart_tx_w>
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
    800008d2:	f9aa8a93          	addi	s5,s5,-102 # 80013868 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	d4248493          	addi	s1,s1,-702 # 8000b618 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	d3e98993          	addi	s3,s3,-706 # 8000b620 <uart_tx_w>
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
    80000908:	db0080e7          	jalr	-592(ra) # 800026b4 <wakeup>
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
    80000946:	f2650513          	addi	a0,a0,-218 # 80013868 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	5e4080e7          	jalr	1508(ra) # 80000f2e <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	cbe7a783          	lw	a5,-834(a5) # 8000b610 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	cc473703          	ld	a4,-828(a4) # 8000b620 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	cb47b783          	ld	a5,-844(a5) # 8000b618 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	ef898993          	addi	s3,s3,-264 # 80013868 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	ca048493          	addi	s1,s1,-864 # 8000b618 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	ca090913          	addi	s2,s2,-864 # 8000b620 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	cc0080e7          	jalr	-832(ra) # 80002650 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	ec248493          	addi	s1,s1,-318 # 80013868 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	c6e7b323          	sd	a4,-922(a5) # 8000b620 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ede080e7          	jalr	-290(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	616080e7          	jalr	1558(ra) # 80000fe2 <release>
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
    80000a32:	e3a48493          	addi	s1,s1,-454 # 80013868 <uart_tx_lock>
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	4f6080e7          	jalr	1270(ra) # 80000f2e <acquire>
  uartstart();
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	e60080e7          	jalr	-416(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	598080e7          	jalr	1432(ra) # 80000fe2 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <refindex>:
char refcount[NPAGES];

int
refindex(uint64 pa)
{
    if (pa < KERNBASE || pa >= PHYSTOP)
    80000a5c:	800007b7          	lui	a5,0x80000
    80000a60:	953e                	add	a0,a0,a5
    80000a62:	080007b7          	lui	a5,0x8000
    80000a66:	00f57563          	bgeu	a0,a5,80000a70 <refindex+0x14>
        panic("refindex");

    return (pa - KERNBASE) / PGSIZE;
    80000a6a:	8131                	srli	a0,a0,0xc
}
    80000a6c:	2501                	sext.w	a0,a0
    80000a6e:	8082                	ret
{
    80000a70:	1141                	addi	sp,sp,-16
    80000a72:	e406                	sd	ra,8(sp)
    80000a74:	e022                	sd	s0,0(sp)
    80000a76:	0800                	addi	s0,sp,16
        panic("refindex");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5d850513          	addi	a0,a0,1496 # 80008050 <__func__.1+0x48>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	ae0080e7          	jalr	-1312(ra) # 80000560 <panic>

0000000080000a88 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a88:	7179                	addi	sp,sp,-48
    80000a8a:	f406                	sd	ra,40(sp)
    80000a8c:	f022                	sd	s0,32(sp)
    80000a8e:	ec26                	sd	s1,24(sp)
    80000a90:	e84a                	sd	s2,16(sp)
    80000a92:	e44e                	sd	s3,8(sp)
    80000a94:	1800                	addi	s0,sp,48
    80000a96:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a98:	0000b797          	auipc	a5,0xb
    80000a9c:	b987b783          	ld	a5,-1128(a5) # 8000b630 <MAX_PAGES>
    80000aa0:	c799                	beqz	a5,80000aae <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000aa2:	0000b717          	auipc	a4,0xb
    80000aa6:	b8673703          	ld	a4,-1146(a4) # 8000b628 <FREE_PAGES>
    80000aaa:	08f77063          	bgeu	a4,a5,80000b2a <kfree+0xa2>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000aae:	03449793          	slli	a5,s1,0x34
    80000ab2:	e7d5                	bnez	a5,80000b5e <kfree+0xd6>
    80000ab4:	0002c797          	auipc	a5,0x2c
    80000ab8:	03478793          	addi	a5,a5,52 # 8002cae8 <end>
    80000abc:	0af4e163          	bltu	s1,a5,80000b5e <kfree+0xd6>
    80000ac0:	47c5                	li	a5,17
    80000ac2:	07ee                	slli	a5,a5,0x1b
    80000ac4:	08f4fd63          	bgeu	s1,a5,80000b5e <kfree+0xd6>
        panic("kfree");

    // decrement refcount

    int i = refindex((uint64) pa);
    80000ac8:	8526                	mv	a0,s1
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	f92080e7          	jalr	-110(ra) # 80000a5c <refindex>
    80000ad2:	89aa                	mv	s3,a0

    acquire(&refcountlock);
    80000ad4:	00013517          	auipc	a0,0x13
    80000ad8:	dcc50513          	addi	a0,a0,-564 # 800138a0 <refcountlock>
    80000adc:	00000097          	auipc	ra,0x0
    80000ae0:	452080e7          	jalr	1106(ra) # 80000f2e <acquire>
    if (refcount[i] > 0) refcount[i]--;
    80000ae4:	00013797          	auipc	a5,0x13
    80000ae8:	df478793          	addi	a5,a5,-524 # 800138d8 <refcount>
    80000aec:	97ce                	add	a5,a5,s3
    80000aee:	0007c783          	lbu	a5,0(a5)
    80000af2:	cfb5                	beqz	a5,80000b6e <kfree+0xe6>
    80000af4:	37fd                	addiw	a5,a5,-1
    80000af6:	0ff7f913          	zext.b	s2,a5
    80000afa:	00013797          	auipc	a5,0x13
    80000afe:	dde78793          	addi	a5,a5,-546 # 800138d8 <refcount>
    80000b02:	97ce                	add	a5,a5,s3
    80000b04:	01278023          	sb	s2,0(a5)
    int empty = refcount[i] == 0;
    release(&refcountlock);
    80000b08:	00013517          	auipc	a0,0x13
    80000b0c:	d9850513          	addi	a0,a0,-616 # 800138a0 <refcountlock>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	4d2080e7          	jalr	1234(ra) # 80000fe2 <release>

    if (!empty) return;
    80000b18:	06090363          	beqz	s2,80000b7e <kfree+0xf6>
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}
    80000b1c:	70a2                	ld	ra,40(sp)
    80000b1e:	7402                	ld	s0,32(sp)
    80000b20:	64e2                	ld	s1,24(sp)
    80000b22:	6942                	ld	s2,16(sp)
    80000b24:	69a2                	ld	s3,8(sp)
    80000b26:	6145                	addi	sp,sp,48
    80000b28:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000b2a:	04700693          	li	a3,71
    80000b2e:	00007617          	auipc	a2,0x7
    80000b32:	4da60613          	addi	a2,a2,1242 # 80008008 <__func__.1>
    80000b36:	00007597          	auipc	a1,0x7
    80000b3a:	52a58593          	addi	a1,a1,1322 # 80008060 <__func__.1+0x58>
    80000b3e:	00007517          	auipc	a0,0x7
    80000b42:	53250513          	addi	a0,a0,1330 # 80008070 <__func__.1+0x68>
    80000b46:	00000097          	auipc	ra,0x0
    80000b4a:	a76080e7          	jalr	-1418(ra) # 800005bc <printf>
    80000b4e:	00007517          	auipc	a0,0x7
    80000b52:	53250513          	addi	a0,a0,1330 # 80008080 <__func__.1+0x78>
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	a0a080e7          	jalr	-1526(ra) # 80000560 <panic>
        panic("kfree");
    80000b5e:	00007517          	auipc	a0,0x7
    80000b62:	53250513          	addi	a0,a0,1330 # 80008090 <__func__.1+0x88>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	9fa080e7          	jalr	-1542(ra) # 80000560 <panic>
    release(&refcountlock);
    80000b6e:	00013517          	auipc	a0,0x13
    80000b72:	d3250513          	addi	a0,a0,-718 # 800138a0 <refcountlock>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	46c080e7          	jalr	1132(ra) # 80000fe2 <release>
    memset(pa, 1, PGSIZE);
    80000b7e:	6605                	lui	a2,0x1
    80000b80:	4585                	li	a1,1
    80000b82:	8526                	mv	a0,s1
    80000b84:	00000097          	auipc	ra,0x0
    80000b88:	4a6080e7          	jalr	1190(ra) # 8000102a <memset>
    acquire(&kmem.lock);
    80000b8c:	00013997          	auipc	s3,0x13
    80000b90:	d1498993          	addi	s3,s3,-748 # 800138a0 <refcountlock>
    80000b94:	00013917          	auipc	s2,0x13
    80000b98:	d2490913          	addi	s2,s2,-732 # 800138b8 <kmem>
    80000b9c:	854a                	mv	a0,s2
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	390080e7          	jalr	912(ra) # 80000f2e <acquire>
    r->next = kmem.freelist;
    80000ba6:	0309b783          	ld	a5,48(s3)
    80000baa:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000bac:	0299b823          	sd	s1,48(s3)
    FREE_PAGES++;
    80000bb0:	0000b717          	auipc	a4,0xb
    80000bb4:	a7870713          	addi	a4,a4,-1416 # 8000b628 <FREE_PAGES>
    80000bb8:	631c                	ld	a5,0(a4)
    80000bba:	0785                	addi	a5,a5,1
    80000bbc:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000bbe:	854a                	mv	a0,s2
    80000bc0:	00000097          	auipc	ra,0x0
    80000bc4:	422080e7          	jalr	1058(ra) # 80000fe2 <release>
    80000bc8:	bf91                	j	80000b1c <kfree+0x94>

0000000080000bca <freerange>:
{
    80000bca:	7179                	addi	sp,sp,-48
    80000bcc:	f406                	sd	ra,40(sp)
    80000bce:	f022                	sd	s0,32(sp)
    80000bd0:	ec26                	sd	s1,24(sp)
    80000bd2:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000bd4:	6785                	lui	a5,0x1
    80000bd6:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000bda:	00e504b3          	add	s1,a0,a4
    80000bde:	777d                	lui	a4,0xfffff
    80000be0:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000be2:	94be                	add	s1,s1,a5
    80000be4:	0295e463          	bltu	a1,s1,80000c0c <freerange+0x42>
    80000be8:	e84a                	sd	s2,16(sp)
    80000bea:	e44e                	sd	s3,8(sp)
    80000bec:	e052                	sd	s4,0(sp)
    80000bee:	892e                	mv	s2,a1
        kfree(p);
    80000bf0:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bf2:	6985                	lui	s3,0x1
        kfree(p);
    80000bf4:	01448533          	add	a0,s1,s4
    80000bf8:	00000097          	auipc	ra,0x0
    80000bfc:	e90080e7          	jalr	-368(ra) # 80000a88 <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c00:	94ce                	add	s1,s1,s3
    80000c02:	fe9979e3          	bgeu	s2,s1,80000bf4 <freerange+0x2a>
    80000c06:	6942                	ld	s2,16(sp)
    80000c08:	69a2                	ld	s3,8(sp)
    80000c0a:	6a02                	ld	s4,0(sp)
}
    80000c0c:	70a2                	ld	ra,40(sp)
    80000c0e:	7402                	ld	s0,32(sp)
    80000c10:	64e2                	ld	s1,24(sp)
    80000c12:	6145                	addi	sp,sp,48
    80000c14:	8082                	ret

0000000080000c16 <kinit>:
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000c1e:	00007597          	auipc	a1,0x7
    80000c22:	47a58593          	addi	a1,a1,1146 # 80008098 <__func__.1+0x90>
    80000c26:	00013517          	auipc	a0,0x13
    80000c2a:	c9250513          	addi	a0,a0,-878 # 800138b8 <kmem>
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	270080e7          	jalr	624(ra) # 80000e9e <initlock>
    initlock(&refcountlock, "refcount");
    80000c36:	00007597          	auipc	a1,0x7
    80000c3a:	46a58593          	addi	a1,a1,1130 # 800080a0 <__func__.1+0x98>
    80000c3e:	00013517          	auipc	a0,0x13
    80000c42:	c6250513          	addi	a0,a0,-926 # 800138a0 <refcountlock>
    80000c46:	00000097          	auipc	ra,0x0
    80000c4a:	258080e7          	jalr	600(ra) # 80000e9e <initlock>
    freerange(end, (void *)PHYSTOP);
    80000c4e:	45c5                	li	a1,17
    80000c50:	05ee                	slli	a1,a1,0x1b
    80000c52:	0002c517          	auipc	a0,0x2c
    80000c56:	e9650513          	addi	a0,a0,-362 # 8002cae8 <end>
    80000c5a:	00000097          	auipc	ra,0x0
    80000c5e:	f70080e7          	jalr	-144(ra) # 80000bca <freerange>
    MAX_PAGES = FREE_PAGES;
    80000c62:	0000b797          	auipc	a5,0xb
    80000c66:	9c67b783          	ld	a5,-1594(a5) # 8000b628 <FREE_PAGES>
    80000c6a:	0000b717          	auipc	a4,0xb
    80000c6e:	9cf73323          	sd	a5,-1594(a4) # 8000b630 <MAX_PAGES>
}
    80000c72:	60a2                	ld	ra,8(sp)
    80000c74:	6402                	ld	s0,0(sp)
    80000c76:	0141                	addi	sp,sp,16
    80000c78:	8082                	ret

0000000080000c7a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c7a:	7179                	addi	sp,sp,-48
    80000c7c:	f406                	sd	ra,40(sp)
    80000c7e:	f022                	sd	s0,32(sp)
    80000c80:	ec26                	sd	s1,24(sp)
    80000c82:	e84a                	sd	s2,16(sp)
    80000c84:	e44e                	sd	s3,8(sp)
    80000c86:	1800                	addi	s0,sp,48
    assert(FREE_PAGES > 0);
    80000c88:	0000b797          	auipc	a5,0xb
    80000c8c:	9a07b783          	ld	a5,-1632(a5) # 8000b628 <FREE_PAGES>
    80000c90:	cfd1                	beqz	a5,80000d2c <kalloc+0xb2>
    struct run *r;

    acquire(&kmem.lock);
    80000c92:	00013517          	auipc	a0,0x13
    80000c96:	c2650513          	addi	a0,a0,-986 # 800138b8 <kmem>
    80000c9a:	00000097          	auipc	ra,0x0
    80000c9e:	294080e7          	jalr	660(ra) # 80000f2e <acquire>
    r = kmem.freelist;
    80000ca2:	00013497          	auipc	s1,0x13
    80000ca6:	c2e4b483          	ld	s1,-978(s1) # 800138d0 <kmem+0x18>
    if (r)
    80000caa:	c8dd                	beqz	s1,80000d60 <kalloc+0xe6>
        kmem.freelist = r->next;
    80000cac:	609c                	ld	a5,0(s1)
    80000cae:	00013717          	auipc	a4,0x13
    80000cb2:	c2f73123          	sd	a5,-990(a4) # 800138d0 <kmem+0x18>
    release(&kmem.lock);
    80000cb6:	00013517          	auipc	a0,0x13
    80000cba:	c0250513          	addi	a0,a0,-1022 # 800138b8 <kmem>
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	324080e7          	jalr	804(ra) # 80000fe2 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000cc6:	6605                	lui	a2,0x1
    80000cc8:	4595                	li	a1,5
    80000cca:	8526                	mv	a0,s1
    80000ccc:	00000097          	auipc	ra,0x0
    80000cd0:	35e080e7          	jalr	862(ra) # 8000102a <memset>
    FREE_PAGES--;
    80000cd4:	0000b717          	auipc	a4,0xb
    80000cd8:	95470713          	addi	a4,a4,-1708 # 8000b628 <FREE_PAGES>
    80000cdc:	631c                	ld	a5,0(a4)
    80000cde:	17fd                	addi	a5,a5,-1
    80000ce0:	e31c                	sd	a5,0(a4)

    int i = refindex((uint64) r);
    80000ce2:	8526                	mv	a0,s1
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	d78080e7          	jalr	-648(ra) # 80000a5c <refindex>
    80000cec:	892a                	mv	s2,a0
    acquire(&refcountlock);
    80000cee:	00013997          	auipc	s3,0x13
    80000cf2:	bb298993          	addi	s3,s3,-1102 # 800138a0 <refcountlock>
    80000cf6:	854e                	mv	a0,s3
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	236080e7          	jalr	566(ra) # 80000f2e <acquire>
    refcount[i] = 1;
    80000d00:	00013797          	auipc	a5,0x13
    80000d04:	bd878793          	addi	a5,a5,-1064 # 800138d8 <refcount>
    80000d08:	01278533          	add	a0,a5,s2
    80000d0c:	4785                	li	a5,1
    80000d0e:	00f50023          	sb	a5,0(a0)
    release(&refcountlock);
    80000d12:	854e                	mv	a0,s3
    80000d14:	00000097          	auipc	ra,0x0
    80000d18:	2ce080e7          	jalr	718(ra) # 80000fe2 <release>

    return (void *)r;
}
    80000d1c:	8526                	mv	a0,s1
    80000d1e:	70a2                	ld	ra,40(sp)
    80000d20:	7402                	ld	s0,32(sp)
    80000d22:	64e2                	ld	s1,24(sp)
    80000d24:	6942                	ld	s2,16(sp)
    80000d26:	69a2                	ld	s3,8(sp)
    80000d28:	6145                	addi	sp,sp,48
    80000d2a:	8082                	ret
    assert(FREE_PAGES > 0);
    80000d2c:	06c00693          	li	a3,108
    80000d30:	00007617          	auipc	a2,0x7
    80000d34:	2d060613          	addi	a2,a2,720 # 80008000 <etext>
    80000d38:	00007597          	auipc	a1,0x7
    80000d3c:	32858593          	addi	a1,a1,808 # 80008060 <__func__.1+0x58>
    80000d40:	00007517          	auipc	a0,0x7
    80000d44:	33050513          	addi	a0,a0,816 # 80008070 <__func__.1+0x68>
    80000d48:	00000097          	auipc	ra,0x0
    80000d4c:	874080e7          	jalr	-1932(ra) # 800005bc <printf>
    80000d50:	00007517          	auipc	a0,0x7
    80000d54:	33050513          	addi	a0,a0,816 # 80008080 <__func__.1+0x78>
    80000d58:	00000097          	auipc	ra,0x0
    80000d5c:	808080e7          	jalr	-2040(ra) # 80000560 <panic>
    release(&kmem.lock);
    80000d60:	00013517          	auipc	a0,0x13
    80000d64:	b5850513          	addi	a0,a0,-1192 # 800138b8 <kmem>
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	27a080e7          	jalr	634(ra) # 80000fe2 <release>
    if (r)
    80000d70:	b795                	j	80000cd4 <kalloc+0x5a>

0000000080000d72 <cow_triggered>:

void cow_triggered(pte_t *pte)
{
    80000d72:	7179                	addi	sp,sp,-48
    80000d74:	f406                	sd	ra,40(sp)
    80000d76:	f022                	sd	s0,32(sp)
    80000d78:	ec26                	sd	s1,24(sp)
    80000d7a:	e84a                	sd	s2,16(sp)
    80000d7c:	e44e                	sd	s3,8(sp)
    80000d7e:	1800                	addi	s0,sp,48
    80000d80:	89aa                	mv	s3,a0
    uint64 pg = PTE2PA(*pte);
    80000d82:	00053903          	ld	s2,0(a0)
    80000d86:	00a95913          	srli	s2,s2,0xa
    80000d8a:	0932                	slli	s2,s2,0xc

    int i = refindex(pg);
    80000d8c:	854a                	mv	a0,s2
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	cce080e7          	jalr	-818(ra) # 80000a5c <refindex>
    80000d96:	84aa                	mv	s1,a0

    // check if need to copy to new page
    acquire(&refcountlock);
    80000d98:	00013517          	auipc	a0,0x13
    80000d9c:	b0850513          	addi	a0,a0,-1272 # 800138a0 <refcountlock>
    80000da0:	00000097          	auipc	ra,0x0
    80000da4:	18e080e7          	jalr	398(ra) # 80000f2e <acquire>
    if (refcount[i] > 1) {
    80000da8:	00013797          	auipc	a5,0x13
    80000dac:	b3078793          	addi	a5,a5,-1232 # 800138d8 <refcount>
    80000db0:	97a6                	add	a5,a5,s1
    80000db2:	0007c783          	lbu	a5,0(a5)
    80000db6:	4705                	li	a4,1
    80000db8:	06f77a63          	bgeu	a4,a5,80000e2c <cow_triggered+0xba>
        refcount[i]--;
    80000dbc:	00013717          	auipc	a4,0x13
    80000dc0:	b1c70713          	addi	a4,a4,-1252 # 800138d8 <refcount>
    80000dc4:	9726                	add	a4,a4,s1
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00f70023          	sb	a5,0(a4)
        release(&refcountlock);
    80000dcc:	00013517          	auipc	a0,0x13
    80000dd0:	ad450513          	addi	a0,a0,-1324 # 800138a0 <refcountlock>
    80000dd4:	00000097          	auipc	ra,0x0
    80000dd8:	20e080e7          	jalr	526(ra) # 80000fe2 <release>

        // get new page
        void* new = kalloc();
    80000ddc:	00000097          	auipc	ra,0x0
    80000de0:	e9e080e7          	jalr	-354(ra) # 80000c7a <kalloc>
    80000de4:	84aa                	mv	s1,a0
        if (new == 0)
    80000de6:	c91d                	beqz	a0,80000e1c <cow_triggered+0xaa>
        {
          panic("cow_triggered, out of mem");
        }

        // copy to new page
        memmove(new, (void*) pg, PGSIZE);
    80000de8:	6605                	lui	a2,0x1
    80000dea:	85ca                	mv	a1,s2
    80000dec:	00000097          	auipc	ra,0x0
    80000df0:	29a080e7          	jalr	666(ra) # 80001086 <memmove>

        uint flags = PTE_FLAGS(*pte);
    80000df4:	0009b783          	ld	a5,0(s3)
        flags &= ~PTE_COW;
    80000df8:	1ff7f793          	andi	a5,a5,511
        flags |= PTE_W;

        // update pte
        *pte = PA2PTE(new) | flags;
    80000dfc:	80b1                	srli	s1,s1,0xc
    80000dfe:	04aa                	slli	s1,s1,0xa
    80000e00:	0047e793          	ori	a5,a5,4
    80000e04:	8cdd                	or	s1,s1,a5
    80000e06:	0099b023          	sd	s1,0(s3)
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    80000e0a:	12000073          	sfence.vma
        release(&refcountlock);
        // make normal write
        *pte = (*pte & ~PTE_COW) | PTE_W;
    } 
    sfence_vma(); // flush tlb
}
    80000e0e:	70a2                	ld	ra,40(sp)
    80000e10:	7402                	ld	s0,32(sp)
    80000e12:	64e2                	ld	s1,24(sp)
    80000e14:	6942                	ld	s2,16(sp)
    80000e16:	69a2                	ld	s3,8(sp)
    80000e18:	6145                	addi	sp,sp,48
    80000e1a:	8082                	ret
          panic("cow_triggered, out of mem");
    80000e1c:	00007517          	auipc	a0,0x7
    80000e20:	29450513          	addi	a0,a0,660 # 800080b0 <__func__.1+0xa8>
    80000e24:	fffff097          	auipc	ra,0xfffff
    80000e28:	73c080e7          	jalr	1852(ra) # 80000560 <panic>
        release(&refcountlock);
    80000e2c:	00013517          	auipc	a0,0x13
    80000e30:	a7450513          	addi	a0,a0,-1420 # 800138a0 <refcountlock>
    80000e34:	00000097          	auipc	ra,0x0
    80000e38:	1ae080e7          	jalr	430(ra) # 80000fe2 <release>
        *pte = (*pte & ~PTE_COW) | PTE_W;
    80000e3c:	0009b483          	ld	s1,0(s3)
    80000e40:	dfb4f493          	andi	s1,s1,-517
    80000e44:	0044e493          	ori	s1,s1,4
    80000e48:	bf7d                	j	80000e06 <cow_triggered+0x94>

0000000080000e4a <increfcount>:

void increfcount(uint64 pa) {
    80000e4a:	1101                	addi	sp,sp,-32
    80000e4c:	ec06                	sd	ra,24(sp)
    80000e4e:	e822                	sd	s0,16(sp)
    80000e50:	e426                	sd	s1,8(sp)
    80000e52:	e04a                	sd	s2,0(sp)
    80000e54:	1000                	addi	s0,sp,32
    80000e56:	84aa                	mv	s1,a0
    acquire(&refcountlock);
    80000e58:	00013917          	auipc	s2,0x13
    80000e5c:	a4890913          	addi	s2,s2,-1464 # 800138a0 <refcountlock>
    80000e60:	854a                	mv	a0,s2
    80000e62:	00000097          	auipc	ra,0x0
    80000e66:	0cc080e7          	jalr	204(ra) # 80000f2e <acquire>
    refcount[refindex(pa)]++;
    80000e6a:	8526                	mv	a0,s1
    80000e6c:	00000097          	auipc	ra,0x0
    80000e70:	bf0080e7          	jalr	-1040(ra) # 80000a5c <refindex>
    80000e74:	00013797          	auipc	a5,0x13
    80000e78:	a6478793          	addi	a5,a5,-1436 # 800138d8 <refcount>
    80000e7c:	953e                	add	a0,a0,a5
    80000e7e:	00054783          	lbu	a5,0(a0)
    80000e82:	2785                	addiw	a5,a5,1
    80000e84:	00f50023          	sb	a5,0(a0)
    release(&refcountlock);
    80000e88:	854a                	mv	a0,s2
    80000e8a:	00000097          	auipc	ra,0x0
    80000e8e:	158080e7          	jalr	344(ra) # 80000fe2 <release>
}
    80000e92:	60e2                	ld	ra,24(sp)
    80000e94:	6442                	ld	s0,16(sp)
    80000e96:	64a2                	ld	s1,8(sp)
    80000e98:	6902                	ld	s2,0(sp)
    80000e9a:	6105                	addi	sp,sp,32
    80000e9c:	8082                	ret

0000000080000e9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000e9e:	1141                	addi	sp,sp,-16
    80000ea0:	e422                	sd	s0,8(sp)
    80000ea2:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ea4:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ea6:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000eaa:	00053823          	sd	zero,16(a0)
}
    80000eae:	6422                	ld	s0,8(sp)
    80000eb0:	0141                	addi	sp,sp,16
    80000eb2:	8082                	ret

0000000080000eb4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000eb4:	411c                	lw	a5,0(a0)
    80000eb6:	e399                	bnez	a5,80000ebc <holding+0x8>
    80000eb8:	4501                	li	a0,0
  return r;
}
    80000eba:	8082                	ret
{
    80000ebc:	1101                	addi	sp,sp,-32
    80000ebe:	ec06                	sd	ra,24(sp)
    80000ec0:	e822                	sd	s0,16(sp)
    80000ec2:	e426                	sd	s1,8(sp)
    80000ec4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ec6:	6904                	ld	s1,16(a0)
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fba080e7          	jalr	-70(ra) # 80001e82 <mycpu>
    80000ed0:	40a48533          	sub	a0,s1,a0
    80000ed4:	00153513          	seqz	a0,a0
}
    80000ed8:	60e2                	ld	ra,24(sp)
    80000eda:	6442                	ld	s0,16(sp)
    80000edc:	64a2                	ld	s1,8(sp)
    80000ede:	6105                	addi	sp,sp,32
    80000ee0:	8082                	ret

0000000080000ee2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000ee2:	1101                	addi	sp,sp,-32
    80000ee4:	ec06                	sd	ra,24(sp)
    80000ee6:	e822                	sd	s0,16(sp)
    80000ee8:	e426                	sd	s1,8(sp)
    80000eea:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000eec:	100024f3          	csrr	s1,sstatus
    80000ef0:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ef4:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000ef6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000efa:	00001097          	auipc	ra,0x1
    80000efe:	f88080e7          	jalr	-120(ra) # 80001e82 <mycpu>
    80000f02:	5d3c                	lw	a5,120(a0)
    80000f04:	cf89                	beqz	a5,80000f1e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000f06:	00001097          	auipc	ra,0x1
    80000f0a:	f7c080e7          	jalr	-132(ra) # 80001e82 <mycpu>
    80000f0e:	5d3c                	lw	a5,120(a0)
    80000f10:	2785                	addiw	a5,a5,1
    80000f12:	dd3c                	sw	a5,120(a0)
}
    80000f14:	60e2                	ld	ra,24(sp)
    80000f16:	6442                	ld	s0,16(sp)
    80000f18:	64a2                	ld	s1,8(sp)
    80000f1a:	6105                	addi	sp,sp,32
    80000f1c:	8082                	ret
    mycpu()->intena = old;
    80000f1e:	00001097          	auipc	ra,0x1
    80000f22:	f64080e7          	jalr	-156(ra) # 80001e82 <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000f26:	8085                	srli	s1,s1,0x1
    80000f28:	8885                	andi	s1,s1,1
    80000f2a:	dd64                	sw	s1,124(a0)
    80000f2c:	bfe9                	j	80000f06 <push_off+0x24>

0000000080000f2e <acquire>:
{
    80000f2e:	1101                	addi	sp,sp,-32
    80000f30:	ec06                	sd	ra,24(sp)
    80000f32:	e822                	sd	s0,16(sp)
    80000f34:	e426                	sd	s1,8(sp)
    80000f36:	1000                	addi	s0,sp,32
    80000f38:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	fa8080e7          	jalr	-88(ra) # 80000ee2 <push_off>
  if(holding(lk))
    80000f42:	8526                	mv	a0,s1
    80000f44:	00000097          	auipc	ra,0x0
    80000f48:	f70080e7          	jalr	-144(ra) # 80000eb4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000f4c:	4705                	li	a4,1
  if(holding(lk))
    80000f4e:	e115                	bnez	a0,80000f72 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000f50:	87ba                	mv	a5,a4
    80000f52:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000f56:	2781                	sext.w	a5,a5
    80000f58:	ffe5                	bnez	a5,80000f50 <acquire+0x22>
  __sync_synchronize();
    80000f5a:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000f5e:	00001097          	auipc	ra,0x1
    80000f62:	f24080e7          	jalr	-220(ra) # 80001e82 <mycpu>
    80000f66:	e888                	sd	a0,16(s1)
}
    80000f68:	60e2                	ld	ra,24(sp)
    80000f6a:	6442                	ld	s0,16(sp)
    80000f6c:	64a2                	ld	s1,8(sp)
    80000f6e:	6105                	addi	sp,sp,32
    80000f70:	8082                	ret
    panic("acquire");
    80000f72:	00007517          	auipc	a0,0x7
    80000f76:	15e50513          	addi	a0,a0,350 # 800080d0 <__func__.1+0xc8>
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	5e6080e7          	jalr	1510(ra) # 80000560 <panic>

0000000080000f82 <pop_off>:

void
pop_off(void)
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e406                	sd	ra,8(sp)
    80000f86:	e022                	sd	s0,0(sp)
    80000f88:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000f8a:	00001097          	auipc	ra,0x1
    80000f8e:	ef8080e7          	jalr	-264(ra) # 80001e82 <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000f92:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000f96:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000f98:	e78d                	bnez	a5,80000fc2 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000f9a:	5d3c                	lw	a5,120(a0)
    80000f9c:	02f05b63          	blez	a5,80000fd2 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000fa0:	37fd                	addiw	a5,a5,-1
    80000fa2:	0007871b          	sext.w	a4,a5
    80000fa6:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000fa8:	eb09                	bnez	a4,80000fba <pop_off+0x38>
    80000faa:	5d7c                	lw	a5,124(a0)
    80000fac:	c799                	beqz	a5,80000fba <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000fae:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000fb2:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000fb6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000fba:	60a2                	ld	ra,8(sp)
    80000fbc:	6402                	ld	s0,0(sp)
    80000fbe:	0141                	addi	sp,sp,16
    80000fc0:	8082                	ret
    panic("pop_off - interruptible");
    80000fc2:	00007517          	auipc	a0,0x7
    80000fc6:	11650513          	addi	a0,a0,278 # 800080d8 <__func__.1+0xd0>
    80000fca:	fffff097          	auipc	ra,0xfffff
    80000fce:	596080e7          	jalr	1430(ra) # 80000560 <panic>
    panic("pop_off");
    80000fd2:	00007517          	auipc	a0,0x7
    80000fd6:	11e50513          	addi	a0,a0,286 # 800080f0 <__func__.1+0xe8>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	586080e7          	jalr	1414(ra) # 80000560 <panic>

0000000080000fe2 <release>:
{
    80000fe2:	1101                	addi	sp,sp,-32
    80000fe4:	ec06                	sd	ra,24(sp)
    80000fe6:	e822                	sd	s0,16(sp)
    80000fe8:	e426                	sd	s1,8(sp)
    80000fea:	1000                	addi	s0,sp,32
    80000fec:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	ec6080e7          	jalr	-314(ra) # 80000eb4 <holding>
    80000ff6:	c115                	beqz	a0,8000101a <release+0x38>
  lk->cpu = 0;
    80000ff8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ffc:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80001000:	0310000f          	fence	rw,w
    80001004:	0004a023          	sw	zero,0(s1)
  pop_off();
    80001008:	00000097          	auipc	ra,0x0
    8000100c:	f7a080e7          	jalr	-134(ra) # 80000f82 <pop_off>
}
    80001010:	60e2                	ld	ra,24(sp)
    80001012:	6442                	ld	s0,16(sp)
    80001014:	64a2                	ld	s1,8(sp)
    80001016:	6105                	addi	sp,sp,32
    80001018:	8082                	ret
    panic("release");
    8000101a:	00007517          	auipc	a0,0x7
    8000101e:	0de50513          	addi	a0,a0,222 # 800080f8 <__func__.1+0xf0>
    80001022:	fffff097          	auipc	ra,0xfffff
    80001026:	53e080e7          	jalr	1342(ra) # 80000560 <panic>

000000008000102a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000102a:	1141                	addi	sp,sp,-16
    8000102c:	e422                	sd	s0,8(sp)
    8000102e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80001030:	ca19                	beqz	a2,80001046 <memset+0x1c>
    80001032:	87aa                	mv	a5,a0
    80001034:	1602                	slli	a2,a2,0x20
    80001036:	9201                	srli	a2,a2,0x20
    80001038:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    8000103c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80001040:	0785                	addi	a5,a5,1
    80001042:	fee79de3          	bne	a5,a4,8000103c <memset+0x12>
  }
  return dst;
}
    80001046:	6422                	ld	s0,8(sp)
    80001048:	0141                	addi	sp,sp,16
    8000104a:	8082                	ret

000000008000104c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000104c:	1141                	addi	sp,sp,-16
    8000104e:	e422                	sd	s0,8(sp)
    80001050:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80001052:	ca05                	beqz	a2,80001082 <memcmp+0x36>
    80001054:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80001058:	1682                	slli	a3,a3,0x20
    8000105a:	9281                	srli	a3,a3,0x20
    8000105c:	0685                	addi	a3,a3,1
    8000105e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80001060:	00054783          	lbu	a5,0(a0)
    80001064:	0005c703          	lbu	a4,0(a1)
    80001068:	00e79863          	bne	a5,a4,80001078 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    8000106c:	0505                	addi	a0,a0,1
    8000106e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80001070:	fed518e3          	bne	a0,a3,80001060 <memcmp+0x14>
  }

  return 0;
    80001074:	4501                	li	a0,0
    80001076:	a019                	j	8000107c <memcmp+0x30>
      return *s1 - *s2;
    80001078:	40e7853b          	subw	a0,a5,a4
}
    8000107c:	6422                	ld	s0,8(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  return 0;
    80001082:	4501                	li	a0,0
    80001084:	bfe5                	j	8000107c <memcmp+0x30>

0000000080001086 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001086:	1141                	addi	sp,sp,-16
    80001088:	e422                	sd	s0,8(sp)
    8000108a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    8000108c:	c205                	beqz	a2,800010ac <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000108e:	02a5e263          	bltu	a1,a0,800010b2 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80001092:	1602                	slli	a2,a2,0x20
    80001094:	9201                	srli	a2,a2,0x20
    80001096:	00c587b3          	add	a5,a1,a2
{
    8000109a:	872a                	mv	a4,a0
      *d++ = *s++;
    8000109c:	0585                	addi	a1,a1,1
    8000109e:	0705                	addi	a4,a4,1
    800010a0:	fff5c683          	lbu	a3,-1(a1)
    800010a4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800010a8:	feb79ae3          	bne	a5,a1,8000109c <memmove+0x16>

  return dst;
}
    800010ac:	6422                	ld	s0,8(sp)
    800010ae:	0141                	addi	sp,sp,16
    800010b0:	8082                	ret
  if(s < d && s + n > d){
    800010b2:	02061693          	slli	a3,a2,0x20
    800010b6:	9281                	srli	a3,a3,0x20
    800010b8:	00d58733          	add	a4,a1,a3
    800010bc:	fce57be3          	bgeu	a0,a4,80001092 <memmove+0xc>
    d += n;
    800010c0:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800010c2:	fff6079b          	addiw	a5,a2,-1
    800010c6:	1782                	slli	a5,a5,0x20
    800010c8:	9381                	srli	a5,a5,0x20
    800010ca:	fff7c793          	not	a5,a5
    800010ce:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800010d0:	177d                	addi	a4,a4,-1
    800010d2:	16fd                	addi	a3,a3,-1
    800010d4:	00074603          	lbu	a2,0(a4)
    800010d8:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800010dc:	fef71ae3          	bne	a4,a5,800010d0 <memmove+0x4a>
    800010e0:	b7f1                	j	800010ac <memmove+0x26>

00000000800010e2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800010e2:	1141                	addi	sp,sp,-16
    800010e4:	e406                	sd	ra,8(sp)
    800010e6:	e022                	sd	s0,0(sp)
    800010e8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800010ea:	00000097          	auipc	ra,0x0
    800010ee:	f9c080e7          	jalr	-100(ra) # 80001086 <memmove>
}
    800010f2:	60a2                	ld	ra,8(sp)
    800010f4:	6402                	ld	s0,0(sp)
    800010f6:	0141                	addi	sp,sp,16
    800010f8:	8082                	ret

00000000800010fa <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800010fa:	1141                	addi	sp,sp,-16
    800010fc:	e422                	sd	s0,8(sp)
    800010fe:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001100:	ce11                	beqz	a2,8000111c <strncmp+0x22>
    80001102:	00054783          	lbu	a5,0(a0)
    80001106:	cf89                	beqz	a5,80001120 <strncmp+0x26>
    80001108:	0005c703          	lbu	a4,0(a1)
    8000110c:	00f71a63          	bne	a4,a5,80001120 <strncmp+0x26>
    n--, p++, q++;
    80001110:	367d                	addiw	a2,a2,-1
    80001112:	0505                	addi	a0,a0,1
    80001114:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80001116:	f675                	bnez	a2,80001102 <strncmp+0x8>
  if(n == 0)
    return 0;
    80001118:	4501                	li	a0,0
    8000111a:	a801                	j	8000112a <strncmp+0x30>
    8000111c:	4501                	li	a0,0
    8000111e:	a031                	j	8000112a <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80001120:	00054503          	lbu	a0,0(a0)
    80001124:	0005c783          	lbu	a5,0(a1)
    80001128:	9d1d                	subw	a0,a0,a5
}
    8000112a:	6422                	ld	s0,8(sp)
    8000112c:	0141                	addi	sp,sp,16
    8000112e:	8082                	ret

0000000080001130 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e422                	sd	s0,8(sp)
    80001134:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001136:	87aa                	mv	a5,a0
    80001138:	86b2                	mv	a3,a2
    8000113a:	367d                	addiw	a2,a2,-1
    8000113c:	02d05563          	blez	a3,80001166 <strncpy+0x36>
    80001140:	0785                	addi	a5,a5,1
    80001142:	0005c703          	lbu	a4,0(a1)
    80001146:	fee78fa3          	sb	a4,-1(a5)
    8000114a:	0585                	addi	a1,a1,1
    8000114c:	f775                	bnez	a4,80001138 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000114e:	873e                	mv	a4,a5
    80001150:	9fb5                	addw	a5,a5,a3
    80001152:	37fd                	addiw	a5,a5,-1
    80001154:	00c05963          	blez	a2,80001166 <strncpy+0x36>
    *s++ = 0;
    80001158:	0705                	addi	a4,a4,1
    8000115a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    8000115e:	40e786bb          	subw	a3,a5,a4
    80001162:	fed04be3          	bgtz	a3,80001158 <strncpy+0x28>
  return os;
}
    80001166:	6422                	ld	s0,8(sp)
    80001168:	0141                	addi	sp,sp,16
    8000116a:	8082                	ret

000000008000116c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000116c:	1141                	addi	sp,sp,-16
    8000116e:	e422                	sd	s0,8(sp)
    80001170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001172:	02c05363          	blez	a2,80001198 <safestrcpy+0x2c>
    80001176:	fff6069b          	addiw	a3,a2,-1
    8000117a:	1682                	slli	a3,a3,0x20
    8000117c:	9281                	srli	a3,a3,0x20
    8000117e:	96ae                	add	a3,a3,a1
    80001180:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001182:	00d58963          	beq	a1,a3,80001194 <safestrcpy+0x28>
    80001186:	0585                	addi	a1,a1,1
    80001188:	0785                	addi	a5,a5,1
    8000118a:	fff5c703          	lbu	a4,-1(a1)
    8000118e:	fee78fa3          	sb	a4,-1(a5)
    80001192:	fb65                	bnez	a4,80001182 <safestrcpy+0x16>
    ;
  *s = 0;
    80001194:	00078023          	sb	zero,0(a5)
  return os;
}
    80001198:	6422                	ld	s0,8(sp)
    8000119a:	0141                	addi	sp,sp,16
    8000119c:	8082                	ret

000000008000119e <strlen>:

int
strlen(const char *s)
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e422                	sd	s0,8(sp)
    800011a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800011a4:	00054783          	lbu	a5,0(a0)
    800011a8:	cf91                	beqz	a5,800011c4 <strlen+0x26>
    800011aa:	0505                	addi	a0,a0,1
    800011ac:	87aa                	mv	a5,a0
    800011ae:	86be                	mv	a3,a5
    800011b0:	0785                	addi	a5,a5,1
    800011b2:	fff7c703          	lbu	a4,-1(a5)
    800011b6:	ff65                	bnez	a4,800011ae <strlen+0x10>
    800011b8:	40a6853b          	subw	a0,a3,a0
    800011bc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800011be:	6422                	ld	s0,8(sp)
    800011c0:	0141                	addi	sp,sp,16
    800011c2:	8082                	ret
  for(n = 0; s[n]; n++)
    800011c4:	4501                	li	a0,0
    800011c6:	bfe5                	j	800011be <strlen+0x20>

00000000800011c8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800011c8:	1141                	addi	sp,sp,-16
    800011ca:	e406                	sd	ra,8(sp)
    800011cc:	e022                	sd	s0,0(sp)
    800011ce:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800011d0:	00001097          	auipc	ra,0x1
    800011d4:	ca2080e7          	jalr	-862(ra) # 80001e72 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800011d8:	0000a717          	auipc	a4,0xa
    800011dc:	46070713          	addi	a4,a4,1120 # 8000b638 <started>
  if(cpuid() == 0){
    800011e0:	c139                	beqz	a0,80001226 <main+0x5e>
    while(started == 0)
    800011e2:	431c                	lw	a5,0(a4)
    800011e4:	2781                	sext.w	a5,a5
    800011e6:	dff5                	beqz	a5,800011e2 <main+0x1a>
      ;
    __sync_synchronize();
    800011e8:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    800011ec:	00001097          	auipc	ra,0x1
    800011f0:	c86080e7          	jalr	-890(ra) # 80001e72 <cpuid>
    800011f4:	85aa                	mv	a1,a0
    800011f6:	00007517          	auipc	a0,0x7
    800011fa:	f2250513          	addi	a0,a0,-222 # 80008118 <__func__.1+0x110>
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	3be080e7          	jalr	958(ra) # 800005bc <printf>
    kvminithart();    // turn on paging
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	0d8080e7          	jalr	216(ra) # 800012de <kvminithart>
    trapinithart();   // install kernel trap vector
    8000120e:	00002097          	auipc	ra,0x2
    80001212:	b9a080e7          	jalr	-1126(ra) # 80002da8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001216:	00005097          	auipc	ra,0x5
    8000121a:	3fe080e7          	jalr	1022(ra) # 80006614 <plicinithart>
  }

  scheduler();        
    8000121e:	00001097          	auipc	ra,0x1
    80001222:	310080e7          	jalr	784(ra) # 8000252e <scheduler>
    consoleinit();
    80001226:	fffff097          	auipc	ra,0xfffff
    8000122a:	24a080e7          	jalr	586(ra) # 80000470 <consoleinit>
    printfinit();
    8000122e:	fffff097          	auipc	ra,0xfffff
    80001232:	596080e7          	jalr	1430(ra) # 800007c4 <printfinit>
    printf("\n");
    80001236:	00007517          	auipc	a0,0x7
    8000123a:	dea50513          	addi	a0,a0,-534 # 80008020 <__func__.1+0x18>
    8000123e:	fffff097          	auipc	ra,0xfffff
    80001242:	37e080e7          	jalr	894(ra) # 800005bc <printf>
    printf("xv6 kernel is booting\n");
    80001246:	00007517          	auipc	a0,0x7
    8000124a:	eba50513          	addi	a0,a0,-326 # 80008100 <__func__.1+0xf8>
    8000124e:	fffff097          	auipc	ra,0xfffff
    80001252:	36e080e7          	jalr	878(ra) # 800005bc <printf>
    printf("\n");
    80001256:	00007517          	auipc	a0,0x7
    8000125a:	dca50513          	addi	a0,a0,-566 # 80008020 <__func__.1+0x18>
    8000125e:	fffff097          	auipc	ra,0xfffff
    80001262:	35e080e7          	jalr	862(ra) # 800005bc <printf>
    kinit();         // physical page allocator
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	9b0080e7          	jalr	-1616(ra) # 80000c16 <kinit>
    kvminit();       // create kernel page table
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	326080e7          	jalr	806(ra) # 80001594 <kvminit>
    kvminithart();   // turn on paging
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	068080e7          	jalr	104(ra) # 800012de <kvminithart>
    procinit();      // process table
    8000127e:	00001097          	auipc	ra,0x1
    80001282:	b0e080e7          	jalr	-1266(ra) # 80001d8c <procinit>
    trapinit();      // trap vectors
    80001286:	00002097          	auipc	ra,0x2
    8000128a:	afa080e7          	jalr	-1286(ra) # 80002d80 <trapinit>
    trapinithart();  // install kernel trap vector
    8000128e:	00002097          	auipc	ra,0x2
    80001292:	b1a080e7          	jalr	-1254(ra) # 80002da8 <trapinithart>
    plicinit();      // set up interrupt controller
    80001296:	00005097          	auipc	ra,0x5
    8000129a:	364080e7          	jalr	868(ra) # 800065fa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000129e:	00005097          	auipc	ra,0x5
    800012a2:	376080e7          	jalr	886(ra) # 80006614 <plicinithart>
    binit();         // buffer cache
    800012a6:	00002097          	auipc	ra,0x2
    800012aa:	436080e7          	jalr	1078(ra) # 800036dc <binit>
    iinit();         // inode table
    800012ae:	00003097          	auipc	ra,0x3
    800012b2:	aec080e7          	jalr	-1300(ra) # 80003d9a <iinit>
    fileinit();      // file table
    800012b6:	00004097          	auipc	ra,0x4
    800012ba:	a9c080e7          	jalr	-1380(ra) # 80004d52 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800012be:	00005097          	auipc	ra,0x5
    800012c2:	45e080e7          	jalr	1118(ra) # 8000671c <virtio_disk_init>
    userinit();      // first user process
    800012c6:	00001097          	auipc	ra,0x1
    800012ca:	eb0080e7          	jalr	-336(ra) # 80002176 <userinit>
    __sync_synchronize();
    800012ce:	0330000f          	fence	rw,rw
    started = 1;
    800012d2:	4785                	li	a5,1
    800012d4:	0000a717          	auipc	a4,0xa
    800012d8:	36f72223          	sw	a5,868(a4) # 8000b638 <started>
    800012dc:	b789                	j	8000121e <main+0x56>

00000000800012de <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800012de:	1141                	addi	sp,sp,-16
    800012e0:	e422                	sd	s0,8(sp)
    800012e2:	0800                	addi	s0,sp,16
    asm volatile("sfence.vma zero, zero");
    800012e4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800012e8:	0000a797          	auipc	a5,0xa
    800012ec:	3587b783          	ld	a5,856(a5) # 8000b640 <kernel_pagetable>
    800012f0:	83b1                	srli	a5,a5,0xc
    800012f2:	577d                	li	a4,-1
    800012f4:	177e                	slli	a4,a4,0x3f
    800012f6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    800012f8:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    800012fc:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001300:	6422                	ld	s0,8(sp)
    80001302:	0141                	addi	sp,sp,16
    80001304:	8082                	ret

0000000080001306 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001306:	7139                	addi	sp,sp,-64
    80001308:	fc06                	sd	ra,56(sp)
    8000130a:	f822                	sd	s0,48(sp)
    8000130c:	f426                	sd	s1,40(sp)
    8000130e:	f04a                	sd	s2,32(sp)
    80001310:	ec4e                	sd	s3,24(sp)
    80001312:	e852                	sd	s4,16(sp)
    80001314:	e456                	sd	s5,8(sp)
    80001316:	e05a                	sd	s6,0(sp)
    80001318:	0080                	addi	s0,sp,64
    8000131a:	84aa                	mv	s1,a0
    8000131c:	89ae                	mv	s3,a1
    8000131e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001320:	57fd                	li	a5,-1
    80001322:	83e9                	srli	a5,a5,0x1a
    80001324:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001326:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001328:	04b7f263          	bgeu	a5,a1,8000136c <walk+0x66>
    panic("walk");
    8000132c:	00007517          	auipc	a0,0x7
    80001330:	e0450513          	addi	a0,a0,-508 # 80008130 <__func__.1+0x128>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	22c080e7          	jalr	556(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000133c:	060a8663          	beqz	s5,800013a8 <walk+0xa2>
    80001340:	00000097          	auipc	ra,0x0
    80001344:	93a080e7          	jalr	-1734(ra) # 80000c7a <kalloc>
    80001348:	84aa                	mv	s1,a0
    8000134a:	c529                	beqz	a0,80001394 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000134c:	6605                	lui	a2,0x1
    8000134e:	4581                	li	a1,0
    80001350:	00000097          	auipc	ra,0x0
    80001354:	cda080e7          	jalr	-806(ra) # 8000102a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001358:	00c4d793          	srli	a5,s1,0xc
    8000135c:	07aa                	slli	a5,a5,0xa
    8000135e:	0017e793          	ori	a5,a5,1
    80001362:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001366:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd250f>
    80001368:	036a0063          	beq	s4,s6,80001388 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000136c:	0149d933          	srl	s2,s3,s4
    80001370:	1ff97913          	andi	s2,s2,511
    80001374:	090e                	slli	s2,s2,0x3
    80001376:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001378:	00093483          	ld	s1,0(s2)
    8000137c:	0014f793          	andi	a5,s1,1
    80001380:	dfd5                	beqz	a5,8000133c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001382:	80a9                	srli	s1,s1,0xa
    80001384:	04b2                	slli	s1,s1,0xc
    80001386:	b7c5                	j	80001366 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001388:	00c9d513          	srli	a0,s3,0xc
    8000138c:	1ff57513          	andi	a0,a0,511
    80001390:	050e                	slli	a0,a0,0x3
    80001392:	9526                	add	a0,a0,s1
}
    80001394:	70e2                	ld	ra,56(sp)
    80001396:	7442                	ld	s0,48(sp)
    80001398:	74a2                	ld	s1,40(sp)
    8000139a:	7902                	ld	s2,32(sp)
    8000139c:	69e2                	ld	s3,24(sp)
    8000139e:	6a42                	ld	s4,16(sp)
    800013a0:	6aa2                	ld	s5,8(sp)
    800013a2:	6b02                	ld	s6,0(sp)
    800013a4:	6121                	addi	sp,sp,64
    800013a6:	8082                	ret
        return 0;
    800013a8:	4501                	li	a0,0
    800013aa:	b7ed                	j	80001394 <walk+0x8e>

00000000800013ac <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800013ac:	57fd                	li	a5,-1
    800013ae:	83e9                	srli	a5,a5,0x1a
    800013b0:	00b7f463          	bgeu	a5,a1,800013b8 <walkaddr+0xc>
    return 0;
    800013b4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800013b6:	8082                	ret
{
    800013b8:	1141                	addi	sp,sp,-16
    800013ba:	e406                	sd	ra,8(sp)
    800013bc:	e022                	sd	s0,0(sp)
    800013be:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800013c0:	4601                	li	a2,0
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	f44080e7          	jalr	-188(ra) # 80001306 <walk>
  if(pte == 0)
    800013ca:	c105                	beqz	a0,800013ea <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800013cc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800013ce:	0117f693          	andi	a3,a5,17
    800013d2:	4745                	li	a4,17
    return 0;
    800013d4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800013d6:	00e68663          	beq	a3,a4,800013e2 <walkaddr+0x36>
}
    800013da:	60a2                	ld	ra,8(sp)
    800013dc:	6402                	ld	s0,0(sp)
    800013de:	0141                	addi	sp,sp,16
    800013e0:	8082                	ret
  pa = PTE2PA(*pte);
    800013e2:	83a9                	srli	a5,a5,0xa
    800013e4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800013e8:	bfcd                	j	800013da <walkaddr+0x2e>
    return 0;
    800013ea:	4501                	li	a0,0
    800013ec:	b7fd                	j	800013da <walkaddr+0x2e>

00000000800013ee <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800013ee:	715d                	addi	sp,sp,-80
    800013f0:	e486                	sd	ra,72(sp)
    800013f2:	e0a2                	sd	s0,64(sp)
    800013f4:	fc26                	sd	s1,56(sp)
    800013f6:	f84a                	sd	s2,48(sp)
    800013f8:	f44e                	sd	s3,40(sp)
    800013fa:	f052                	sd	s4,32(sp)
    800013fc:	ec56                	sd	s5,24(sp)
    800013fe:	e85a                	sd	s6,16(sp)
    80001400:	e45e                	sd	s7,8(sp)
    80001402:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001404:	c639                	beqz	a2,80001452 <mappages+0x64>
    80001406:	8aaa                	mv	s5,a0
    80001408:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000140a:	777d                	lui	a4,0xfffff
    8000140c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001410:	fff58993          	addi	s3,a1,-1
    80001414:	99b2                	add	s3,s3,a2
    80001416:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000141a:	893e                	mv	s2,a5
    8000141c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001420:	6b85                	lui	s7,0x1
    80001422:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001426:	4605                	li	a2,1
    80001428:	85ca                	mv	a1,s2
    8000142a:	8556                	mv	a0,s5
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	eda080e7          	jalr	-294(ra) # 80001306 <walk>
    80001434:	cd1d                	beqz	a0,80001472 <mappages+0x84>
    if(*pte & PTE_V)
    80001436:	611c                	ld	a5,0(a0)
    80001438:	8b85                	andi	a5,a5,1
    8000143a:	e785                	bnez	a5,80001462 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000143c:	80b1                	srli	s1,s1,0xc
    8000143e:	04aa                	slli	s1,s1,0xa
    80001440:	0164e4b3          	or	s1,s1,s6
    80001444:	0014e493          	ori	s1,s1,1
    80001448:	e104                	sd	s1,0(a0)
    if(a == last)
    8000144a:	05390063          	beq	s2,s3,8000148a <mappages+0x9c>
    a += PGSIZE;
    8000144e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001450:	bfc9                	j	80001422 <mappages+0x34>
    panic("mappages: size");
    80001452:	00007517          	auipc	a0,0x7
    80001456:	ce650513          	addi	a0,a0,-794 # 80008138 <__func__.1+0x130>
    8000145a:	fffff097          	auipc	ra,0xfffff
    8000145e:	106080e7          	jalr	262(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001462:	00007517          	auipc	a0,0x7
    80001466:	ce650513          	addi	a0,a0,-794 # 80008148 <__func__.1+0x140>
    8000146a:	fffff097          	auipc	ra,0xfffff
    8000146e:	0f6080e7          	jalr	246(ra) # 80000560 <panic>
      return -1;
    80001472:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001474:	60a6                	ld	ra,72(sp)
    80001476:	6406                	ld	s0,64(sp)
    80001478:	74e2                	ld	s1,56(sp)
    8000147a:	7942                	ld	s2,48(sp)
    8000147c:	79a2                	ld	s3,40(sp)
    8000147e:	7a02                	ld	s4,32(sp)
    80001480:	6ae2                	ld	s5,24(sp)
    80001482:	6b42                	ld	s6,16(sp)
    80001484:	6ba2                	ld	s7,8(sp)
    80001486:	6161                	addi	sp,sp,80
    80001488:	8082                	ret
  return 0;
    8000148a:	4501                	li	a0,0
    8000148c:	b7e5                	j	80001474 <mappages+0x86>

000000008000148e <kvmmap>:
{
    8000148e:	1141                	addi	sp,sp,-16
    80001490:	e406                	sd	ra,8(sp)
    80001492:	e022                	sd	s0,0(sp)
    80001494:	0800                	addi	s0,sp,16
    80001496:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001498:	86b2                	mv	a3,a2
    8000149a:	863e                	mv	a2,a5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f52080e7          	jalr	-174(ra) # 800013ee <mappages>
    800014a4:	e509                	bnez	a0,800014ae <kvmmap+0x20>
}
    800014a6:	60a2                	ld	ra,8(sp)
    800014a8:	6402                	ld	s0,0(sp)
    800014aa:	0141                	addi	sp,sp,16
    800014ac:	8082                	ret
    panic("kvmmap");
    800014ae:	00007517          	auipc	a0,0x7
    800014b2:	caa50513          	addi	a0,a0,-854 # 80008158 <__func__.1+0x150>
    800014b6:	fffff097          	auipc	ra,0xfffff
    800014ba:	0aa080e7          	jalr	170(ra) # 80000560 <panic>

00000000800014be <kvmmake>:
{
    800014be:	1101                	addi	sp,sp,-32
    800014c0:	ec06                	sd	ra,24(sp)
    800014c2:	e822                	sd	s0,16(sp)
    800014c4:	e426                	sd	s1,8(sp)
    800014c6:	e04a                	sd	s2,0(sp)
    800014c8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800014ca:	fffff097          	auipc	ra,0xfffff
    800014ce:	7b0080e7          	jalr	1968(ra) # 80000c7a <kalloc>
    800014d2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800014d4:	6605                	lui	a2,0x1
    800014d6:	4581                	li	a1,0
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	b52080e7          	jalr	-1198(ra) # 8000102a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800014e0:	4719                	li	a4,6
    800014e2:	6685                	lui	a3,0x1
    800014e4:	10000637          	lui	a2,0x10000
    800014e8:	100005b7          	lui	a1,0x10000
    800014ec:	8526                	mv	a0,s1
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	fa0080e7          	jalr	-96(ra) # 8000148e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800014f6:	4719                	li	a4,6
    800014f8:	6685                	lui	a3,0x1
    800014fa:	10001637          	lui	a2,0x10001
    800014fe:	100015b7          	lui	a1,0x10001
    80001502:	8526                	mv	a0,s1
    80001504:	00000097          	auipc	ra,0x0
    80001508:	f8a080e7          	jalr	-118(ra) # 8000148e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000150c:	4719                	li	a4,6
    8000150e:	004006b7          	lui	a3,0x400
    80001512:	0c000637          	lui	a2,0xc000
    80001516:	0c0005b7          	lui	a1,0xc000
    8000151a:	8526                	mv	a0,s1
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	f72080e7          	jalr	-142(ra) # 8000148e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001524:	00007917          	auipc	s2,0x7
    80001528:	adc90913          	addi	s2,s2,-1316 # 80008000 <etext>
    8000152c:	4729                	li	a4,10
    8000152e:	80007697          	auipc	a3,0x80007
    80001532:	ad268693          	addi	a3,a3,-1326 # 8000 <_entry-0x7fff8000>
    80001536:	4605                	li	a2,1
    80001538:	067e                	slli	a2,a2,0x1f
    8000153a:	85b2                	mv	a1,a2
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f50080e7          	jalr	-176(ra) # 8000148e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001546:	46c5                	li	a3,17
    80001548:	06ee                	slli	a3,a3,0x1b
    8000154a:	4719                	li	a4,6
    8000154c:	412686b3          	sub	a3,a3,s2
    80001550:	864a                	mv	a2,s2
    80001552:	85ca                	mv	a1,s2
    80001554:	8526                	mv	a0,s1
    80001556:	00000097          	auipc	ra,0x0
    8000155a:	f38080e7          	jalr	-200(ra) # 8000148e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000155e:	4729                	li	a4,10
    80001560:	6685                	lui	a3,0x1
    80001562:	00006617          	auipc	a2,0x6
    80001566:	a9e60613          	addi	a2,a2,-1378 # 80007000 <_trampoline>
    8000156a:	040005b7          	lui	a1,0x4000
    8000156e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001570:	05b2                	slli	a1,a1,0xc
    80001572:	8526                	mv	a0,s1
    80001574:	00000097          	auipc	ra,0x0
    80001578:	f1a080e7          	jalr	-230(ra) # 8000148e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000157c:	8526                	mv	a0,s1
    8000157e:	00000097          	auipc	ra,0x0
    80001582:	76a080e7          	jalr	1898(ra) # 80001ce8 <proc_mapstacks>
}
    80001586:	8526                	mv	a0,s1
    80001588:	60e2                	ld	ra,24(sp)
    8000158a:	6442                	ld	s0,16(sp)
    8000158c:	64a2                	ld	s1,8(sp)
    8000158e:	6902                	ld	s2,0(sp)
    80001590:	6105                	addi	sp,sp,32
    80001592:	8082                	ret

0000000080001594 <kvminit>:
{
    80001594:	1141                	addi	sp,sp,-16
    80001596:	e406                	sd	ra,8(sp)
    80001598:	e022                	sd	s0,0(sp)
    8000159a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	f22080e7          	jalr	-222(ra) # 800014be <kvmmake>
    800015a4:	0000a797          	auipc	a5,0xa
    800015a8:	08a7be23          	sd	a0,156(a5) # 8000b640 <kernel_pagetable>
}
    800015ac:	60a2                	ld	ra,8(sp)
    800015ae:	6402                	ld	s0,0(sp)
    800015b0:	0141                	addi	sp,sp,16
    800015b2:	8082                	ret

00000000800015b4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800015b4:	715d                	addi	sp,sp,-80
    800015b6:	e486                	sd	ra,72(sp)
    800015b8:	e0a2                	sd	s0,64(sp)
    800015ba:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800015bc:	03459793          	slli	a5,a1,0x34
    800015c0:	e39d                	bnez	a5,800015e6 <uvmunmap+0x32>
    800015c2:	f84a                	sd	s2,48(sp)
    800015c4:	f44e                	sd	s3,40(sp)
    800015c6:	f052                	sd	s4,32(sp)
    800015c8:	ec56                	sd	s5,24(sp)
    800015ca:	e85a                	sd	s6,16(sp)
    800015cc:	e45e                	sd	s7,8(sp)
    800015ce:	8a2a                	mv	s4,a0
    800015d0:	892e                	mv	s2,a1
    800015d2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015d4:	0632                	slli	a2,a2,0xc
    800015d6:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800015da:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015dc:	6b05                	lui	s6,0x1
    800015de:	0935fb63          	bgeu	a1,s3,80001674 <uvmunmap+0xc0>
    800015e2:	fc26                	sd	s1,56(sp)
    800015e4:	a8a9                	j	8000163e <uvmunmap+0x8a>
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800015f4:	00007517          	auipc	a0,0x7
    800015f8:	b6c50513          	addi	a0,a0,-1172 # 80008160 <__func__.1+0x158>
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	f64080e7          	jalr	-156(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    80001604:	00007517          	auipc	a0,0x7
    80001608:	b7450513          	addi	a0,a0,-1164 # 80008178 <__func__.1+0x170>
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	f54080e7          	jalr	-172(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    80001614:	00007517          	auipc	a0,0x7
    80001618:	b7450513          	addi	a0,a0,-1164 # 80008188 <__func__.1+0x180>
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	f44080e7          	jalr	-188(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    80001624:	00007517          	auipc	a0,0x7
    80001628:	b7c50513          	addi	a0,a0,-1156 # 800081a0 <__func__.1+0x198>
    8000162c:	fffff097          	auipc	ra,0xfffff
    80001630:	f34080e7          	jalr	-204(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001634:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001638:	995a                	add	s2,s2,s6
    8000163a:	03397c63          	bgeu	s2,s3,80001672 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000163e:	4601                	li	a2,0
    80001640:	85ca                	mv	a1,s2
    80001642:	8552                	mv	a0,s4
    80001644:	00000097          	auipc	ra,0x0
    80001648:	cc2080e7          	jalr	-830(ra) # 80001306 <walk>
    8000164c:	84aa                	mv	s1,a0
    8000164e:	d95d                	beqz	a0,80001604 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001650:	6108                	ld	a0,0(a0)
    80001652:	00157793          	andi	a5,a0,1
    80001656:	dfdd                	beqz	a5,80001614 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001658:	3ff57793          	andi	a5,a0,1023
    8000165c:	fd7784e3          	beq	a5,s7,80001624 <uvmunmap+0x70>
    if(do_free){
    80001660:	fc0a8ae3          	beqz	s5,80001634 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001664:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001666:	0532                	slli	a0,a0,0xc
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	420080e7          	jalr	1056(ra) # 80000a88 <kfree>
    80001670:	b7d1                	j	80001634 <uvmunmap+0x80>
    80001672:	74e2                	ld	s1,56(sp)
    80001674:	7942                	ld	s2,48(sp)
    80001676:	79a2                	ld	s3,40(sp)
    80001678:	7a02                	ld	s4,32(sp)
    8000167a:	6ae2                	ld	s5,24(sp)
    8000167c:	6b42                	ld	s6,16(sp)
    8000167e:	6ba2                	ld	s7,8(sp)
  }
}
    80001680:	60a6                	ld	ra,72(sp)
    80001682:	6406                	ld	s0,64(sp)
    80001684:	6161                	addi	sp,sp,80
    80001686:	8082                	ret

0000000080001688 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001688:	1101                	addi	sp,sp,-32
    8000168a:	ec06                	sd	ra,24(sp)
    8000168c:	e822                	sd	s0,16(sp)
    8000168e:	e426                	sd	s1,8(sp)
    80001690:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001692:	fffff097          	auipc	ra,0xfffff
    80001696:	5e8080e7          	jalr	1512(ra) # 80000c7a <kalloc>
    8000169a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000169c:	c519                	beqz	a0,800016aa <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000169e:	6605                	lui	a2,0x1
    800016a0:	4581                	li	a1,0
    800016a2:	00000097          	auipc	ra,0x0
    800016a6:	988080e7          	jalr	-1656(ra) # 8000102a <memset>
  return pagetable;
}
    800016aa:	8526                	mv	a0,s1
    800016ac:	60e2                	ld	ra,24(sp)
    800016ae:	6442                	ld	s0,16(sp)
    800016b0:	64a2                	ld	s1,8(sp)
    800016b2:	6105                	addi	sp,sp,32
    800016b4:	8082                	ret

00000000800016b6 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800016b6:	7179                	addi	sp,sp,-48
    800016b8:	f406                	sd	ra,40(sp)
    800016ba:	f022                	sd	s0,32(sp)
    800016bc:	ec26                	sd	s1,24(sp)
    800016be:	e84a                	sd	s2,16(sp)
    800016c0:	e44e                	sd	s3,8(sp)
    800016c2:	e052                	sd	s4,0(sp)
    800016c4:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800016c6:	6785                	lui	a5,0x1
    800016c8:	04f67863          	bgeu	a2,a5,80001718 <uvmfirst+0x62>
    800016cc:	8a2a                	mv	s4,a0
    800016ce:	89ae                	mv	s3,a1
    800016d0:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800016d2:	fffff097          	auipc	ra,0xfffff
    800016d6:	5a8080e7          	jalr	1448(ra) # 80000c7a <kalloc>
    800016da:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800016dc:	6605                	lui	a2,0x1
    800016de:	4581                	li	a1,0
    800016e0:	00000097          	auipc	ra,0x0
    800016e4:	94a080e7          	jalr	-1718(ra) # 8000102a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800016e8:	4779                	li	a4,30
    800016ea:	86ca                	mv	a3,s2
    800016ec:	6605                	lui	a2,0x1
    800016ee:	4581                	li	a1,0
    800016f0:	8552                	mv	a0,s4
    800016f2:	00000097          	auipc	ra,0x0
    800016f6:	cfc080e7          	jalr	-772(ra) # 800013ee <mappages>
  memmove(mem, src, sz);
    800016fa:	8626                	mv	a2,s1
    800016fc:	85ce                	mv	a1,s3
    800016fe:	854a                	mv	a0,s2
    80001700:	00000097          	auipc	ra,0x0
    80001704:	986080e7          	jalr	-1658(ra) # 80001086 <memmove>
}
    80001708:	70a2                	ld	ra,40(sp)
    8000170a:	7402                	ld	s0,32(sp)
    8000170c:	64e2                	ld	s1,24(sp)
    8000170e:	6942                	ld	s2,16(sp)
    80001710:	69a2                	ld	s3,8(sp)
    80001712:	6a02                	ld	s4,0(sp)
    80001714:	6145                	addi	sp,sp,48
    80001716:	8082                	ret
    panic("uvmfirst: more than a page");
    80001718:	00007517          	auipc	a0,0x7
    8000171c:	aa050513          	addi	a0,a0,-1376 # 800081b8 <__func__.1+0x1b0>
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	e40080e7          	jalr	-448(ra) # 80000560 <panic>

0000000080001728 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001728:	1101                	addi	sp,sp,-32
    8000172a:	ec06                	sd	ra,24(sp)
    8000172c:	e822                	sd	s0,16(sp)
    8000172e:	e426                	sd	s1,8(sp)
    80001730:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001732:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001734:	00b67d63          	bgeu	a2,a1,8000174e <uvmdealloc+0x26>
    80001738:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000173a:	6785                	lui	a5,0x1
    8000173c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000173e:	00f60733          	add	a4,a2,a5
    80001742:	76fd                	lui	a3,0xfffff
    80001744:	8f75                	and	a4,a4,a3
    80001746:	97ae                	add	a5,a5,a1
    80001748:	8ff5                	and	a5,a5,a3
    8000174a:	00f76863          	bltu	a4,a5,8000175a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000174e:	8526                	mv	a0,s1
    80001750:	60e2                	ld	ra,24(sp)
    80001752:	6442                	ld	s0,16(sp)
    80001754:	64a2                	ld	s1,8(sp)
    80001756:	6105                	addi	sp,sp,32
    80001758:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000175a:	8f99                	sub	a5,a5,a4
    8000175c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000175e:	4685                	li	a3,1
    80001760:	0007861b          	sext.w	a2,a5
    80001764:	85ba                	mv	a1,a4
    80001766:	00000097          	auipc	ra,0x0
    8000176a:	e4e080e7          	jalr	-434(ra) # 800015b4 <uvmunmap>
    8000176e:	b7c5                	j	8000174e <uvmdealloc+0x26>

0000000080001770 <uvmalloc>:
  if(newsz < oldsz)
    80001770:	0ab66b63          	bltu	a2,a1,80001826 <uvmalloc+0xb6>
{
    80001774:	7139                	addi	sp,sp,-64
    80001776:	fc06                	sd	ra,56(sp)
    80001778:	f822                	sd	s0,48(sp)
    8000177a:	ec4e                	sd	s3,24(sp)
    8000177c:	e852                	sd	s4,16(sp)
    8000177e:	e456                	sd	s5,8(sp)
    80001780:	0080                	addi	s0,sp,64
    80001782:	8aaa                	mv	s5,a0
    80001784:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001786:	6785                	lui	a5,0x1
    80001788:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000178a:	95be                	add	a1,a1,a5
    8000178c:	77fd                	lui	a5,0xfffff
    8000178e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001792:	08c9fc63          	bgeu	s3,a2,8000182a <uvmalloc+0xba>
    80001796:	f426                	sd	s1,40(sp)
    80001798:	f04a                	sd	s2,32(sp)
    8000179a:	e05a                	sd	s6,0(sp)
    8000179c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000179e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800017a2:	fffff097          	auipc	ra,0xfffff
    800017a6:	4d8080e7          	jalr	1240(ra) # 80000c7a <kalloc>
    800017aa:	84aa                	mv	s1,a0
    if(mem == 0){
    800017ac:	c915                	beqz	a0,800017e0 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800017ae:	6605                	lui	a2,0x1
    800017b0:	4581                	li	a1,0
    800017b2:	00000097          	auipc	ra,0x0
    800017b6:	878080e7          	jalr	-1928(ra) # 8000102a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800017ba:	875a                	mv	a4,s6
    800017bc:	86a6                	mv	a3,s1
    800017be:	6605                	lui	a2,0x1
    800017c0:	85ca                	mv	a1,s2
    800017c2:	8556                	mv	a0,s5
    800017c4:	00000097          	auipc	ra,0x0
    800017c8:	c2a080e7          	jalr	-982(ra) # 800013ee <mappages>
    800017cc:	ed05                	bnez	a0,80001804 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800017ce:	6785                	lui	a5,0x1
    800017d0:	993e                	add	s2,s2,a5
    800017d2:	fd4968e3          	bltu	s2,s4,800017a2 <uvmalloc+0x32>
  return newsz;
    800017d6:	8552                	mv	a0,s4
    800017d8:	74a2                	ld	s1,40(sp)
    800017da:	7902                	ld	s2,32(sp)
    800017dc:	6b02                	ld	s6,0(sp)
    800017de:	a821                	j	800017f6 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800017e0:	864e                	mv	a2,s3
    800017e2:	85ca                	mv	a1,s2
    800017e4:	8556                	mv	a0,s5
    800017e6:	00000097          	auipc	ra,0x0
    800017ea:	f42080e7          	jalr	-190(ra) # 80001728 <uvmdealloc>
      return 0;
    800017ee:	4501                	li	a0,0
    800017f0:	74a2                	ld	s1,40(sp)
    800017f2:	7902                	ld	s2,32(sp)
    800017f4:	6b02                	ld	s6,0(sp)
}
    800017f6:	70e2                	ld	ra,56(sp)
    800017f8:	7442                	ld	s0,48(sp)
    800017fa:	69e2                	ld	s3,24(sp)
    800017fc:	6a42                	ld	s4,16(sp)
    800017fe:	6aa2                	ld	s5,8(sp)
    80001800:	6121                	addi	sp,sp,64
    80001802:	8082                	ret
      kfree(mem);
    80001804:	8526                	mv	a0,s1
    80001806:	fffff097          	auipc	ra,0xfffff
    8000180a:	282080e7          	jalr	642(ra) # 80000a88 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000180e:	864e                	mv	a2,s3
    80001810:	85ca                	mv	a1,s2
    80001812:	8556                	mv	a0,s5
    80001814:	00000097          	auipc	ra,0x0
    80001818:	f14080e7          	jalr	-236(ra) # 80001728 <uvmdealloc>
      return 0;
    8000181c:	4501                	li	a0,0
    8000181e:	74a2                	ld	s1,40(sp)
    80001820:	7902                	ld	s2,32(sp)
    80001822:	6b02                	ld	s6,0(sp)
    80001824:	bfc9                	j	800017f6 <uvmalloc+0x86>
    return oldsz;
    80001826:	852e                	mv	a0,a1
}
    80001828:	8082                	ret
  return newsz;
    8000182a:	8532                	mv	a0,a2
    8000182c:	b7e9                	j	800017f6 <uvmalloc+0x86>

000000008000182e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000182e:	7179                	addi	sp,sp,-48
    80001830:	f406                	sd	ra,40(sp)
    80001832:	f022                	sd	s0,32(sp)
    80001834:	ec26                	sd	s1,24(sp)
    80001836:	e84a                	sd	s2,16(sp)
    80001838:	e44e                	sd	s3,8(sp)
    8000183a:	e052                	sd	s4,0(sp)
    8000183c:	1800                	addi	s0,sp,48
    8000183e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001840:	84aa                	mv	s1,a0
    80001842:	6905                	lui	s2,0x1
    80001844:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001846:	4985                	li	s3,1
    80001848:	a829                	j	80001862 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000184a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000184c:	00c79513          	slli	a0,a5,0xc
    80001850:	00000097          	auipc	ra,0x0
    80001854:	fde080e7          	jalr	-34(ra) # 8000182e <freewalk>
      pagetable[i] = 0;
    80001858:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000185c:	04a1                	addi	s1,s1,8
    8000185e:	03248163          	beq	s1,s2,80001880 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001862:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001864:	00f7f713          	andi	a4,a5,15
    80001868:	ff3701e3          	beq	a4,s3,8000184a <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000186c:	8b85                	andi	a5,a5,1
    8000186e:	d7fd                	beqz	a5,8000185c <freewalk+0x2e>
      panic("freewalk: leaf");
    80001870:	00007517          	auipc	a0,0x7
    80001874:	96850513          	addi	a0,a0,-1688 # 800081d8 <__func__.1+0x1d0>
    80001878:	fffff097          	auipc	ra,0xfffff
    8000187c:	ce8080e7          	jalr	-792(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001880:	8552                	mv	a0,s4
    80001882:	fffff097          	auipc	ra,0xfffff
    80001886:	206080e7          	jalr	518(ra) # 80000a88 <kfree>
}
    8000188a:	70a2                	ld	ra,40(sp)
    8000188c:	7402                	ld	s0,32(sp)
    8000188e:	64e2                	ld	s1,24(sp)
    80001890:	6942                	ld	s2,16(sp)
    80001892:	69a2                	ld	s3,8(sp)
    80001894:	6a02                	ld	s4,0(sp)
    80001896:	6145                	addi	sp,sp,48
    80001898:	8082                	ret

000000008000189a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000189a:	1101                	addi	sp,sp,-32
    8000189c:	ec06                	sd	ra,24(sp)
    8000189e:	e822                	sd	s0,16(sp)
    800018a0:	e426                	sd	s1,8(sp)
    800018a2:	1000                	addi	s0,sp,32
    800018a4:	84aa                	mv	s1,a0
  if(sz > 0)
    800018a6:	e999                	bnez	a1,800018bc <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800018a8:	8526                	mv	a0,s1
    800018aa:	00000097          	auipc	ra,0x0
    800018ae:	f84080e7          	jalr	-124(ra) # 8000182e <freewalk>
}
    800018b2:	60e2                	ld	ra,24(sp)
    800018b4:	6442                	ld	s0,16(sp)
    800018b6:	64a2                	ld	s1,8(sp)
    800018b8:	6105                	addi	sp,sp,32
    800018ba:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800018bc:	6785                	lui	a5,0x1
    800018be:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800018c0:	95be                	add	a1,a1,a5
    800018c2:	4685                	li	a3,1
    800018c4:	00c5d613          	srli	a2,a1,0xc
    800018c8:	4581                	li	a1,0
    800018ca:	00000097          	auipc	ra,0x0
    800018ce:	cea080e7          	jalr	-790(ra) # 800015b4 <uvmunmap>
    800018d2:	bfd9                	j	800018a8 <uvmfree+0xe>

00000000800018d4 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800018d4:	ce61                	beqz	a2,800019ac <uvmcopy+0xd8>
{
    800018d6:	7139                	addi	sp,sp,-64
    800018d8:	fc06                	sd	ra,56(sp)
    800018da:	f822                	sd	s0,48(sp)
    800018dc:	f426                	sd	s1,40(sp)
    800018de:	f04a                	sd	s2,32(sp)
    800018e0:	ec4e                	sd	s3,24(sp)
    800018e2:	e852                	sd	s4,16(sp)
    800018e4:	e456                	sd	s5,8(sp)
    800018e6:	e05a                	sd	s6,0(sp)
    800018e8:	0080                	addi	s0,sp,64
    800018ea:	8b2a                	mv	s6,a0
    800018ec:	8aae                	mv	s5,a1
    800018ee:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800018f0:	4981                	li	s3,0
    800018f2:	a091                	j	80001936 <uvmcopy+0x62>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    800018f4:	00007517          	auipc	a0,0x7
    800018f8:	8f450513          	addi	a0,a0,-1804 # 800081e8 <__func__.1+0x1e0>
    800018fc:	fffff097          	auipc	ra,0xfffff
    80001900:	c64080e7          	jalr	-924(ra) # 80000560 <panic>
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    80001904:	00007517          	auipc	a0,0x7
    80001908:	90450513          	addi	a0,a0,-1788 # 80008208 <__func__.1+0x200>
    8000190c:	fffff097          	auipc	ra,0xfffff
    80001910:	c54080e7          	jalr	-940(ra) # 80000560 <panic>
    if (*pte & PTE_W)
    {
      *pte = (*pte & ~PTE_W) | PTE_COW;
    }
    
    flags = PTE_FLAGS(*pte);
    80001914:	00093703          	ld	a4,0(s2) # 1000 <_entry-0x7ffff000>

    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80001918:	3ff77713          	andi	a4,a4,1023
    8000191c:	86a6                	mv	a3,s1
    8000191e:	6605                	lui	a2,0x1
    80001920:	85ce                	mv	a1,s3
    80001922:	8556                	mv	a0,s5
    80001924:	00000097          	auipc	ra,0x0
    80001928:	aca080e7          	jalr	-1334(ra) # 800013ee <mappages>
    8000192c:	e531                	bnez	a0,80001978 <uvmcopy+0xa4>
  for(i = 0; i < sz; i += PGSIZE){
    8000192e:	6785                	lui	a5,0x1
    80001930:	99be                	add	s3,s3,a5
    80001932:	0749f063          	bgeu	s3,s4,80001992 <uvmcopy+0xbe>
    if((pte = walk(old, i, 0)) == 0)
    80001936:	4601                	li	a2,0
    80001938:	85ce                	mv	a1,s3
    8000193a:	855a                	mv	a0,s6
    8000193c:	00000097          	auipc	ra,0x0
    80001940:	9ca080e7          	jalr	-1590(ra) # 80001306 <walk>
    80001944:	892a                	mv	s2,a0
    80001946:	d55d                	beqz	a0,800018f4 <uvmcopy+0x20>
    if((*pte & PTE_V) == 0)
    80001948:	6114                	ld	a3,0(a0)
    8000194a:	0016f793          	andi	a5,a3,1
    8000194e:	dbdd                	beqz	a5,80001904 <uvmcopy+0x30>
    pa = PTE2PA(*pte);
    80001950:	82a9                	srli	a3,a3,0xa
    80001952:	00c69493          	slli	s1,a3,0xc
    increfcount(pa);
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	4f2080e7          	jalr	1266(ra) # 80000e4a <increfcount>
    if (*pte & PTE_W)
    80001960:	00093783          	ld	a5,0(s2)
    80001964:	0047f713          	andi	a4,a5,4
    80001968:	d755                	beqz	a4,80001914 <uvmcopy+0x40>
      *pte = (*pte & ~PTE_W) | PTE_COW;
    8000196a:	dfb7f793          	andi	a5,a5,-517
    8000196e:	2007e793          	ori	a5,a5,512
    80001972:	00f93023          	sd	a5,0(s2)
    80001976:	bf79                	j	80001914 <uvmcopy+0x40>
    80001978:	12000073          	sfence.vma
  }
  sfence_vma(); // flush tlb
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000197c:	4685                	li	a3,1
    8000197e:	00c9d613          	srli	a2,s3,0xc
    80001982:	4581                	li	a1,0
    80001984:	8556                	mv	a0,s5
    80001986:	00000097          	auipc	ra,0x0
    8000198a:	c2e080e7          	jalr	-978(ra) # 800015b4 <uvmunmap>
  return -1;
    8000198e:	557d                	li	a0,-1
    80001990:	a021                	j	80001998 <uvmcopy+0xc4>
    80001992:	12000073          	sfence.vma
  return 0;
    80001996:	4501                	li	a0,0
}
    80001998:	70e2                	ld	ra,56(sp)
    8000199a:	7442                	ld	s0,48(sp)
    8000199c:	74a2                	ld	s1,40(sp)
    8000199e:	7902                	ld	s2,32(sp)
    800019a0:	69e2                	ld	s3,24(sp)
    800019a2:	6a42                	ld	s4,16(sp)
    800019a4:	6aa2                	ld	s5,8(sp)
    800019a6:	6b02                	ld	s6,0(sp)
    800019a8:	6121                	addi	sp,sp,64
    800019aa:	8082                	ret
    800019ac:	12000073          	sfence.vma
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
    800019c2:	948080e7          	jalr	-1720(ra) # 80001306 <walk>
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
    800019da:	85250513          	addi	a0,a0,-1966 # 80008228 <__func__.1+0x220>
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
    80001a1e:	66c080e7          	jalr	1644(ra) # 80001086 <memmove>

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
    80001a3c:	974080e7          	jalr	-1676(ra) # 800013ac <walkaddr>
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
    80001aac:	5de080e7          	jalr	1502(ra) # 80001086 <memmove>

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
    80001aca:	8e6080e7          	jalr	-1818(ra) # 800013ac <walkaddr>
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
    80001b68:	848080e7          	jalr	-1976(ra) # 800013ac <walkaddr>
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
    80001b90:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd2518>
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

0000000080001c18 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001c18:	715d                	addi	sp,sp,-80
    80001c1a:	e486                	sd	ra,72(sp)
    80001c1c:	e0a2                	sd	s0,64(sp)
    80001c1e:	fc26                	sd	s1,56(sp)
    80001c20:	f84a                	sd	s2,48(sp)
    80001c22:	f44e                	sd	s3,40(sp)
    80001c24:	f052                	sd	s4,32(sp)
    80001c26:	ec56                	sd	s5,24(sp)
    80001c28:	e85a                	sd	s6,16(sp)
    80001c2a:	e45e                	sd	s7,8(sp)
    80001c2c:	e062                	sd	s8,0(sp)
    80001c2e:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001c30:	8792                	mv	a5,tp
    int id = r_tp();
    80001c32:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001c34:	0001aa97          	auipc	s5,0x1a
    80001c38:	ca4a8a93          	addi	s5,s5,-860 # 8001b8d8 <cpus>
    80001c3c:	00779713          	slli	a4,a5,0x7
    80001c40:	00ea86b3          	add	a3,s5,a4
    80001c44:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffd2518>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001c48:	0721                	addi	a4,a4,8
    80001c4a:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001c4c:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001c4e:	0000ac17          	auipc	s8,0xa
    80001c52:	92ac0c13          	addi	s8,s8,-1750 # 8000b578 <sched_pointer>
    80001c56:	00000b97          	auipc	s7,0x0
    80001c5a:	fc2b8b93          	addi	s7,s7,-62 # 80001c18 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001c5e:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001c62:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001c66:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001c6a:	0001a497          	auipc	s1,0x1a
    80001c6e:	09e48493          	addi	s1,s1,158 # 8001bd08 <proc>
            if (p->state == RUNNABLE)
    80001c72:	498d                	li	s3,3
                p->state = RUNNING;
    80001c74:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001c76:	00020a17          	auipc	s4,0x20
    80001c7a:	a92a0a13          	addi	s4,s4,-1390 # 80021708 <tickslock>
    80001c7e:	a81d                	j	80001cb4 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001c80:	8526                	mv	a0,s1
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	360080e7          	jalr	864(ra) # 80000fe2 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001c8a:	60a6                	ld	ra,72(sp)
    80001c8c:	6406                	ld	s0,64(sp)
    80001c8e:	74e2                	ld	s1,56(sp)
    80001c90:	7942                	ld	s2,48(sp)
    80001c92:	79a2                	ld	s3,40(sp)
    80001c94:	7a02                	ld	s4,32(sp)
    80001c96:	6ae2                	ld	s5,24(sp)
    80001c98:	6b42                	ld	s6,16(sp)
    80001c9a:	6ba2                	ld	s7,8(sp)
    80001c9c:	6c02                	ld	s8,0(sp)
    80001c9e:	6161                	addi	sp,sp,80
    80001ca0:	8082                	ret
            release(&p->lock);
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	33e080e7          	jalr	830(ra) # 80000fe2 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001cac:	16848493          	addi	s1,s1,360
    80001cb0:	fb4487e3          	beq	s1,s4,80001c5e <rr_scheduler+0x46>
            acquire(&p->lock);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	278080e7          	jalr	632(ra) # 80000f2e <acquire>
            if (p->state == RUNNABLE)
    80001cbe:	4c9c                	lw	a5,24(s1)
    80001cc0:	ff3791e3          	bne	a5,s3,80001ca2 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001cc4:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001cc8:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001ccc:	06048593          	addi	a1,s1,96
    80001cd0:	8556                	mv	a0,s5
    80001cd2:	00001097          	auipc	ra,0x1
    80001cd6:	044080e7          	jalr	68(ra) # 80002d16 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001cda:	000c3783          	ld	a5,0(s8)
    80001cde:	fb7791e3          	bne	a5,s7,80001c80 <rr_scheduler+0x68>
                c->proc = 0;
    80001ce2:	00093023          	sd	zero,0(s2)
    80001ce6:	bf75                	j	80001ca2 <rr_scheduler+0x8a>

0000000080001ce8 <proc_mapstacks>:
{
    80001ce8:	7139                	addi	sp,sp,-64
    80001cea:	fc06                	sd	ra,56(sp)
    80001cec:	f822                	sd	s0,48(sp)
    80001cee:	f426                	sd	s1,40(sp)
    80001cf0:	f04a                	sd	s2,32(sp)
    80001cf2:	ec4e                	sd	s3,24(sp)
    80001cf4:	e852                	sd	s4,16(sp)
    80001cf6:	e456                	sd	s5,8(sp)
    80001cf8:	e05a                	sd	s6,0(sp)
    80001cfa:	0080                	addi	s0,sp,64
    80001cfc:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001cfe:	0001a497          	auipc	s1,0x1a
    80001d02:	00a48493          	addi	s1,s1,10 # 8001bd08 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001d06:	8b26                	mv	s6,s1
    80001d08:	04fa5937          	lui	s2,0x4fa5
    80001d0c:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001d10:	0932                	slli	s2,s2,0xc
    80001d12:	fa590913          	addi	s2,s2,-91
    80001d16:	0932                	slli	s2,s2,0xc
    80001d18:	fa590913          	addi	s2,s2,-91
    80001d1c:	0932                	slli	s2,s2,0xc
    80001d1e:	fa590913          	addi	s2,s2,-91
    80001d22:	040009b7          	lui	s3,0x4000
    80001d26:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001d28:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001d2a:	00020a97          	auipc	s5,0x20
    80001d2e:	9dea8a93          	addi	s5,s5,-1570 # 80021708 <tickslock>
        char *pa = kalloc();
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	f48080e7          	jalr	-184(ra) # 80000c7a <kalloc>
    80001d3a:	862a                	mv	a2,a0
        if (pa == 0)
    80001d3c:	c121                	beqz	a0,80001d7c <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001d3e:	416485b3          	sub	a1,s1,s6
    80001d42:	858d                	srai	a1,a1,0x3
    80001d44:	032585b3          	mul	a1,a1,s2
    80001d48:	2585                	addiw	a1,a1,1
    80001d4a:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d4e:	4719                	li	a4,6
    80001d50:	6685                	lui	a3,0x1
    80001d52:	40b985b3          	sub	a1,s3,a1
    80001d56:	8552                	mv	a0,s4
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	736080e7          	jalr	1846(ra) # 8000148e <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001d60:	16848493          	addi	s1,s1,360
    80001d64:	fd5497e3          	bne	s1,s5,80001d32 <proc_mapstacks+0x4a>
}
    80001d68:	70e2                	ld	ra,56(sp)
    80001d6a:	7442                	ld	s0,48(sp)
    80001d6c:	74a2                	ld	s1,40(sp)
    80001d6e:	7902                	ld	s2,32(sp)
    80001d70:	69e2                	ld	s3,24(sp)
    80001d72:	6a42                	ld	s4,16(sp)
    80001d74:	6aa2                	ld	s5,8(sp)
    80001d76:	6b02                	ld	s6,0(sp)
    80001d78:	6121                	addi	sp,sp,64
    80001d7a:	8082                	ret
            panic("kalloc");
    80001d7c:	00006517          	auipc	a0,0x6
    80001d80:	4bc50513          	addi	a0,a0,1212 # 80008238 <__func__.1+0x230>
    80001d84:	ffffe097          	auipc	ra,0xffffe
    80001d88:	7dc080e7          	jalr	2012(ra) # 80000560 <panic>

0000000080001d8c <procinit>:
{
    80001d8c:	7139                	addi	sp,sp,-64
    80001d8e:	fc06                	sd	ra,56(sp)
    80001d90:	f822                	sd	s0,48(sp)
    80001d92:	f426                	sd	s1,40(sp)
    80001d94:	f04a                	sd	s2,32(sp)
    80001d96:	ec4e                	sd	s3,24(sp)
    80001d98:	e852                	sd	s4,16(sp)
    80001d9a:	e456                	sd	s5,8(sp)
    80001d9c:	e05a                	sd	s6,0(sp)
    80001d9e:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001da0:	00006597          	auipc	a1,0x6
    80001da4:	4a058593          	addi	a1,a1,1184 # 80008240 <__func__.1+0x238>
    80001da8:	0001a517          	auipc	a0,0x1a
    80001dac:	f3050513          	addi	a0,a0,-208 # 8001bcd8 <pid_lock>
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	0ee080e7          	jalr	238(ra) # 80000e9e <initlock>
    initlock(&wait_lock, "wait_lock");
    80001db8:	00006597          	auipc	a1,0x6
    80001dbc:	49058593          	addi	a1,a1,1168 # 80008248 <__func__.1+0x240>
    80001dc0:	0001a517          	auipc	a0,0x1a
    80001dc4:	f3050513          	addi	a0,a0,-208 # 8001bcf0 <wait_lock>
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	0d6080e7          	jalr	214(ra) # 80000e9e <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001dd0:	0001a497          	auipc	s1,0x1a
    80001dd4:	f3848493          	addi	s1,s1,-200 # 8001bd08 <proc>
        initlock(&p->lock, "proc");
    80001dd8:	00006b17          	auipc	s6,0x6
    80001ddc:	480b0b13          	addi	s6,s6,1152 # 80008258 <__func__.1+0x250>
        p->kstack = KSTACK((int)(p - proc));
    80001de0:	8aa6                	mv	s5,s1
    80001de2:	04fa5937          	lui	s2,0x4fa5
    80001de6:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001dea:	0932                	slli	s2,s2,0xc
    80001dec:	fa590913          	addi	s2,s2,-91
    80001df0:	0932                	slli	s2,s2,0xc
    80001df2:	fa590913          	addi	s2,s2,-91
    80001df6:	0932                	slli	s2,s2,0xc
    80001df8:	fa590913          	addi	s2,s2,-91
    80001dfc:	040009b7          	lui	s3,0x4000
    80001e00:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001e02:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001e04:	00020a17          	auipc	s4,0x20
    80001e08:	904a0a13          	addi	s4,s4,-1788 # 80021708 <tickslock>
        initlock(&p->lock, "proc");
    80001e0c:	85da                	mv	a1,s6
    80001e0e:	8526                	mv	a0,s1
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	08e080e7          	jalr	142(ra) # 80000e9e <initlock>
        p->state = UNUSED;
    80001e18:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001e1c:	415487b3          	sub	a5,s1,s5
    80001e20:	878d                	srai	a5,a5,0x3
    80001e22:	032787b3          	mul	a5,a5,s2
    80001e26:	2785                	addiw	a5,a5,1
    80001e28:	00d7979b          	slliw	a5,a5,0xd
    80001e2c:	40f987b3          	sub	a5,s3,a5
    80001e30:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001e32:	16848493          	addi	s1,s1,360
    80001e36:	fd449be3          	bne	s1,s4,80001e0c <procinit+0x80>
}
    80001e3a:	70e2                	ld	ra,56(sp)
    80001e3c:	7442                	ld	s0,48(sp)
    80001e3e:	74a2                	ld	s1,40(sp)
    80001e40:	7902                	ld	s2,32(sp)
    80001e42:	69e2                	ld	s3,24(sp)
    80001e44:	6a42                	ld	s4,16(sp)
    80001e46:	6aa2                	ld	s5,8(sp)
    80001e48:	6b02                	ld	s6,0(sp)
    80001e4a:	6121                	addi	sp,sp,64
    80001e4c:	8082                	ret

0000000080001e4e <copy_array>:
{
    80001e4e:	1141                	addi	sp,sp,-16
    80001e50:	e422                	sd	s0,8(sp)
    80001e52:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001e54:	00c05c63          	blez	a2,80001e6c <copy_array+0x1e>
    80001e58:	87aa                	mv	a5,a0
    80001e5a:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001e5c:	0007c703          	lbu	a4,0(a5)
    80001e60:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001e64:	0785                	addi	a5,a5,1
    80001e66:	0585                	addi	a1,a1,1
    80001e68:	fea79ae3          	bne	a5,a0,80001e5c <copy_array+0xe>
}
    80001e6c:	6422                	ld	s0,8(sp)
    80001e6e:	0141                	addi	sp,sp,16
    80001e70:	8082                	ret

0000000080001e72 <cpuid>:
{
    80001e72:	1141                	addi	sp,sp,-16
    80001e74:	e422                	sd	s0,8(sp)
    80001e76:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001e78:	8512                	mv	a0,tp
}
    80001e7a:	2501                	sext.w	a0,a0
    80001e7c:	6422                	ld	s0,8(sp)
    80001e7e:	0141                	addi	sp,sp,16
    80001e80:	8082                	ret

0000000080001e82 <mycpu>:
{
    80001e82:	1141                	addi	sp,sp,-16
    80001e84:	e422                	sd	s0,8(sp)
    80001e86:	0800                	addi	s0,sp,16
    80001e88:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001e8a:	2781                	sext.w	a5,a5
    80001e8c:	079e                	slli	a5,a5,0x7
}
    80001e8e:	0001a517          	auipc	a0,0x1a
    80001e92:	a4a50513          	addi	a0,a0,-1462 # 8001b8d8 <cpus>
    80001e96:	953e                	add	a0,a0,a5
    80001e98:	6422                	ld	s0,8(sp)
    80001e9a:	0141                	addi	sp,sp,16
    80001e9c:	8082                	ret

0000000080001e9e <myproc>:
{
    80001e9e:	1101                	addi	sp,sp,-32
    80001ea0:	ec06                	sd	ra,24(sp)
    80001ea2:	e822                	sd	s0,16(sp)
    80001ea4:	e426                	sd	s1,8(sp)
    80001ea6:	1000                	addi	s0,sp,32
    push_off();
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	03a080e7          	jalr	58(ra) # 80000ee2 <push_off>
    80001eb0:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001eb2:	2781                	sext.w	a5,a5
    80001eb4:	079e                	slli	a5,a5,0x7
    80001eb6:	0001a717          	auipc	a4,0x1a
    80001eba:	a2270713          	addi	a4,a4,-1502 # 8001b8d8 <cpus>
    80001ebe:	97ba                	add	a5,a5,a4
    80001ec0:	6384                	ld	s1,0(a5)
    pop_off();
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	0c0080e7          	jalr	192(ra) # 80000f82 <pop_off>
}
    80001eca:	8526                	mv	a0,s1
    80001ecc:	60e2                	ld	ra,24(sp)
    80001ece:	6442                	ld	s0,16(sp)
    80001ed0:	64a2                	ld	s1,8(sp)
    80001ed2:	6105                	addi	sp,sp,32
    80001ed4:	8082                	ret

0000000080001ed6 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001ed6:	1141                	addi	sp,sp,-16
    80001ed8:	e406                	sd	ra,8(sp)
    80001eda:	e022                	sd	s0,0(sp)
    80001edc:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001ede:	00000097          	auipc	ra,0x0
    80001ee2:	fc0080e7          	jalr	-64(ra) # 80001e9e <myproc>
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	0fc080e7          	jalr	252(ra) # 80000fe2 <release>

    if (first)
    80001eee:	00009797          	auipc	a5,0x9
    80001ef2:	6827a783          	lw	a5,1666(a5) # 8000b570 <first.1>
    80001ef6:	eb89                	bnez	a5,80001f08 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001ef8:	00001097          	auipc	ra,0x1
    80001efc:	ec8080e7          	jalr	-312(ra) # 80002dc0 <usertrapret>
}
    80001f00:	60a2                	ld	ra,8(sp)
    80001f02:	6402                	ld	s0,0(sp)
    80001f04:	0141                	addi	sp,sp,16
    80001f06:	8082                	ret
        first = 0;
    80001f08:	00009797          	auipc	a5,0x9
    80001f0c:	6607a423          	sw	zero,1640(a5) # 8000b570 <first.1>
        fsinit(ROOTDEV);
    80001f10:	4505                	li	a0,1
    80001f12:	00002097          	auipc	ra,0x2
    80001f16:	e08080e7          	jalr	-504(ra) # 80003d1a <fsinit>
    80001f1a:	bff9                	j	80001ef8 <forkret+0x22>

0000000080001f1c <allocpid>:
{
    80001f1c:	1101                	addi	sp,sp,-32
    80001f1e:	ec06                	sd	ra,24(sp)
    80001f20:	e822                	sd	s0,16(sp)
    80001f22:	e426                	sd	s1,8(sp)
    80001f24:	e04a                	sd	s2,0(sp)
    80001f26:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001f28:	0001a917          	auipc	s2,0x1a
    80001f2c:	db090913          	addi	s2,s2,-592 # 8001bcd8 <pid_lock>
    80001f30:	854a                	mv	a0,s2
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	ffc080e7          	jalr	-4(ra) # 80000f2e <acquire>
    pid = nextpid;
    80001f3a:	00009797          	auipc	a5,0x9
    80001f3e:	64678793          	addi	a5,a5,1606 # 8000b580 <nextpid>
    80001f42:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001f44:	0014871b          	addiw	a4,s1,1
    80001f48:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001f4a:	854a                	mv	a0,s2
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	096080e7          	jalr	150(ra) # 80000fe2 <release>
}
    80001f54:	8526                	mv	a0,s1
    80001f56:	60e2                	ld	ra,24(sp)
    80001f58:	6442                	ld	s0,16(sp)
    80001f5a:	64a2                	ld	s1,8(sp)
    80001f5c:	6902                	ld	s2,0(sp)
    80001f5e:	6105                	addi	sp,sp,32
    80001f60:	8082                	ret

0000000080001f62 <proc_pagetable>:
{
    80001f62:	1101                	addi	sp,sp,-32
    80001f64:	ec06                	sd	ra,24(sp)
    80001f66:	e822                	sd	s0,16(sp)
    80001f68:	e426                	sd	s1,8(sp)
    80001f6a:	e04a                	sd	s2,0(sp)
    80001f6c:	1000                	addi	s0,sp,32
    80001f6e:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	718080e7          	jalr	1816(ra) # 80001688 <uvmcreate>
    80001f78:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001f7a:	c121                	beqz	a0,80001fba <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f7c:	4729                	li	a4,10
    80001f7e:	00005697          	auipc	a3,0x5
    80001f82:	08268693          	addi	a3,a3,130 # 80007000 <_trampoline>
    80001f86:	6605                	lui	a2,0x1
    80001f88:	040005b7          	lui	a1,0x4000
    80001f8c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f8e:	05b2                	slli	a1,a1,0xc
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	45e080e7          	jalr	1118(ra) # 800013ee <mappages>
    80001f98:	02054863          	bltz	a0,80001fc8 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f9c:	4719                	li	a4,6
    80001f9e:	05893683          	ld	a3,88(s2)
    80001fa2:	6605                	lui	a2,0x1
    80001fa4:	020005b7          	lui	a1,0x2000
    80001fa8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001faa:	05b6                	slli	a1,a1,0xd
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	440080e7          	jalr	1088(ra) # 800013ee <mappages>
    80001fb6:	02054163          	bltz	a0,80001fd8 <proc_pagetable+0x76>
}
    80001fba:	8526                	mv	a0,s1
    80001fbc:	60e2                	ld	ra,24(sp)
    80001fbe:	6442                	ld	s0,16(sp)
    80001fc0:	64a2                	ld	s1,8(sp)
    80001fc2:	6902                	ld	s2,0(sp)
    80001fc4:	6105                	addi	sp,sp,32
    80001fc6:	8082                	ret
        uvmfree(pagetable, 0);
    80001fc8:	4581                	li	a1,0
    80001fca:	8526                	mv	a0,s1
    80001fcc:	00000097          	auipc	ra,0x0
    80001fd0:	8ce080e7          	jalr	-1842(ra) # 8000189a <uvmfree>
        return 0;
    80001fd4:	4481                	li	s1,0
    80001fd6:	b7d5                	j	80001fba <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fd8:	4681                	li	a3,0
    80001fda:	4605                	li	a2,1
    80001fdc:	040005b7          	lui	a1,0x4000
    80001fe0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001fe2:	05b2                	slli	a1,a1,0xc
    80001fe4:	8526                	mv	a0,s1
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	5ce080e7          	jalr	1486(ra) # 800015b4 <uvmunmap>
        uvmfree(pagetable, 0);
    80001fee:	4581                	li	a1,0
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	00000097          	auipc	ra,0x0
    80001ff6:	8a8080e7          	jalr	-1880(ra) # 8000189a <uvmfree>
        return 0;
    80001ffa:	4481                	li	s1,0
    80001ffc:	bf7d                	j	80001fba <proc_pagetable+0x58>

0000000080001ffe <proc_freepagetable>:
{
    80001ffe:	1101                	addi	sp,sp,-32
    80002000:	ec06                	sd	ra,24(sp)
    80002002:	e822                	sd	s0,16(sp)
    80002004:	e426                	sd	s1,8(sp)
    80002006:	e04a                	sd	s2,0(sp)
    80002008:	1000                	addi	s0,sp,32
    8000200a:	84aa                	mv	s1,a0
    8000200c:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000200e:	4681                	li	a3,0
    80002010:	4605                	li	a2,1
    80002012:	040005b7          	lui	a1,0x4000
    80002016:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002018:	05b2                	slli	a1,a1,0xc
    8000201a:	fffff097          	auipc	ra,0xfffff
    8000201e:	59a080e7          	jalr	1434(ra) # 800015b4 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002022:	4681                	li	a3,0
    80002024:	4605                	li	a2,1
    80002026:	020005b7          	lui	a1,0x2000
    8000202a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000202c:	05b6                	slli	a1,a1,0xd
    8000202e:	8526                	mv	a0,s1
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	584080e7          	jalr	1412(ra) # 800015b4 <uvmunmap>
    uvmfree(pagetable, sz);
    80002038:	85ca                	mv	a1,s2
    8000203a:	8526                	mv	a0,s1
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	85e080e7          	jalr	-1954(ra) # 8000189a <uvmfree>
}
    80002044:	60e2                	ld	ra,24(sp)
    80002046:	6442                	ld	s0,16(sp)
    80002048:	64a2                	ld	s1,8(sp)
    8000204a:	6902                	ld	s2,0(sp)
    8000204c:	6105                	addi	sp,sp,32
    8000204e:	8082                	ret

0000000080002050 <freeproc>:
{
    80002050:	1101                	addi	sp,sp,-32
    80002052:	ec06                	sd	ra,24(sp)
    80002054:	e822                	sd	s0,16(sp)
    80002056:	e426                	sd	s1,8(sp)
    80002058:	1000                	addi	s0,sp,32
    8000205a:	84aa                	mv	s1,a0
    if (p->trapframe)
    8000205c:	6d28                	ld	a0,88(a0)
    8000205e:	c509                	beqz	a0,80002068 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	a28080e7          	jalr	-1496(ra) # 80000a88 <kfree>
    p->trapframe = 0;
    80002068:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    8000206c:	68a8                	ld	a0,80(s1)
    8000206e:	c511                	beqz	a0,8000207a <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80002070:	64ac                	ld	a1,72(s1)
    80002072:	00000097          	auipc	ra,0x0
    80002076:	f8c080e7          	jalr	-116(ra) # 80001ffe <proc_freepagetable>
    p->pagetable = 0;
    8000207a:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    8000207e:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80002082:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80002086:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    8000208a:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    8000208e:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80002092:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80002096:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    8000209a:	0004ac23          	sw	zero,24(s1)
}
    8000209e:	60e2                	ld	ra,24(sp)
    800020a0:	6442                	ld	s0,16(sp)
    800020a2:	64a2                	ld	s1,8(sp)
    800020a4:	6105                	addi	sp,sp,32
    800020a6:	8082                	ret

00000000800020a8 <allocproc>:
{
    800020a8:	1101                	addi	sp,sp,-32
    800020aa:	ec06                	sd	ra,24(sp)
    800020ac:	e822                	sd	s0,16(sp)
    800020ae:	e426                	sd	s1,8(sp)
    800020b0:	e04a                	sd	s2,0(sp)
    800020b2:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    800020b4:	0001a497          	auipc	s1,0x1a
    800020b8:	c5448493          	addi	s1,s1,-940 # 8001bd08 <proc>
    800020bc:	0001f917          	auipc	s2,0x1f
    800020c0:	64c90913          	addi	s2,s2,1612 # 80021708 <tickslock>
        acquire(&p->lock);
    800020c4:	8526                	mv	a0,s1
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	e68080e7          	jalr	-408(ra) # 80000f2e <acquire>
        if (p->state == UNUSED)
    800020ce:	4c9c                	lw	a5,24(s1)
    800020d0:	cf81                	beqz	a5,800020e8 <allocproc+0x40>
            release(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	f0e080e7          	jalr	-242(ra) # 80000fe2 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020dc:	16848493          	addi	s1,s1,360
    800020e0:	ff2492e3          	bne	s1,s2,800020c4 <allocproc+0x1c>
    return 0;
    800020e4:	4481                	li	s1,0
    800020e6:	a889                	j	80002138 <allocproc+0x90>
    p->pid = allocpid();
    800020e8:	00000097          	auipc	ra,0x0
    800020ec:	e34080e7          	jalr	-460(ra) # 80001f1c <allocpid>
    800020f0:	d888                	sw	a0,48(s1)
    p->state = USED;
    800020f2:	4785                	li	a5,1
    800020f4:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b84080e7          	jalr	-1148(ra) # 80000c7a <kalloc>
    800020fe:	892a                	mv	s2,a0
    80002100:	eca8                	sd	a0,88(s1)
    80002102:	c131                	beqz	a0,80002146 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80002104:	8526                	mv	a0,s1
    80002106:	00000097          	auipc	ra,0x0
    8000210a:	e5c080e7          	jalr	-420(ra) # 80001f62 <proc_pagetable>
    8000210e:	892a                	mv	s2,a0
    80002110:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80002112:	c531                	beqz	a0,8000215e <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80002114:	07000613          	li	a2,112
    80002118:	4581                	li	a1,0
    8000211a:	06048513          	addi	a0,s1,96
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	f0c080e7          	jalr	-244(ra) # 8000102a <memset>
    p->context.ra = (uint64)forkret;
    80002126:	00000797          	auipc	a5,0x0
    8000212a:	db078793          	addi	a5,a5,-592 # 80001ed6 <forkret>
    8000212e:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80002130:	60bc                	ld	a5,64(s1)
    80002132:	6705                	lui	a4,0x1
    80002134:	97ba                	add	a5,a5,a4
    80002136:	f4bc                	sd	a5,104(s1)
}
    80002138:	8526                	mv	a0,s1
    8000213a:	60e2                	ld	ra,24(sp)
    8000213c:	6442                	ld	s0,16(sp)
    8000213e:	64a2                	ld	s1,8(sp)
    80002140:	6902                	ld	s2,0(sp)
    80002142:	6105                	addi	sp,sp,32
    80002144:	8082                	ret
        freeproc(p);
    80002146:	8526                	mv	a0,s1
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	f08080e7          	jalr	-248(ra) # 80002050 <freeproc>
        release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	e90080e7          	jalr	-368(ra) # 80000fe2 <release>
        return 0;
    8000215a:	84ca                	mv	s1,s2
    8000215c:	bff1                	j	80002138 <allocproc+0x90>
        freeproc(p);
    8000215e:	8526                	mv	a0,s1
    80002160:	00000097          	auipc	ra,0x0
    80002164:	ef0080e7          	jalr	-272(ra) # 80002050 <freeproc>
        release(&p->lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	e78080e7          	jalr	-392(ra) # 80000fe2 <release>
        return 0;
    80002172:	84ca                	mv	s1,s2
    80002174:	b7d1                	j	80002138 <allocproc+0x90>

0000000080002176 <userinit>:
{
    80002176:	1101                	addi	sp,sp,-32
    80002178:	ec06                	sd	ra,24(sp)
    8000217a:	e822                	sd	s0,16(sp)
    8000217c:	e426                	sd	s1,8(sp)
    8000217e:	1000                	addi	s0,sp,32
    p = allocproc();
    80002180:	00000097          	auipc	ra,0x0
    80002184:	f28080e7          	jalr	-216(ra) # 800020a8 <allocproc>
    80002188:	84aa                	mv	s1,a0
    initproc = p;
    8000218a:	00009797          	auipc	a5,0x9
    8000218e:	4aa7bf23          	sd	a0,1214(a5) # 8000b648 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80002192:	03400613          	li	a2,52
    80002196:	00009597          	auipc	a1,0x9
    8000219a:	3fa58593          	addi	a1,a1,1018 # 8000b590 <initcode>
    8000219e:	6928                	ld	a0,80(a0)
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	516080e7          	jalr	1302(ra) # 800016b6 <uvmfirst>
    p->sz = PGSIZE;
    800021a8:	6785                	lui	a5,0x1
    800021aa:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    800021ac:	6cb8                	ld	a4,88(s1)
    800021ae:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    800021b2:	6cb8                	ld	a4,88(s1)
    800021b4:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    800021b6:	4641                	li	a2,16
    800021b8:	00006597          	auipc	a1,0x6
    800021bc:	0a858593          	addi	a1,a1,168 # 80008260 <__func__.1+0x258>
    800021c0:	15848513          	addi	a0,s1,344
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	fa8080e7          	jalr	-88(ra) # 8000116c <safestrcpy>
    p->cwd = namei("/");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	0a450513          	addi	a0,a0,164 # 80008270 <__func__.1+0x268>
    800021d4:	00002097          	auipc	ra,0x2
    800021d8:	598080e7          	jalr	1432(ra) # 8000476c <namei>
    800021dc:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    800021e0:	478d                	li	a5,3
    800021e2:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	dfc080e7          	jalr	-516(ra) # 80000fe2 <release>
}
    800021ee:	60e2                	ld	ra,24(sp)
    800021f0:	6442                	ld	s0,16(sp)
    800021f2:	64a2                	ld	s1,8(sp)
    800021f4:	6105                	addi	sp,sp,32
    800021f6:	8082                	ret

00000000800021f8 <growproc>:
{
    800021f8:	1101                	addi	sp,sp,-32
    800021fa:	ec06                	sd	ra,24(sp)
    800021fc:	e822                	sd	s0,16(sp)
    800021fe:	e426                	sd	s1,8(sp)
    80002200:	e04a                	sd	s2,0(sp)
    80002202:	1000                	addi	s0,sp,32
    80002204:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002206:	00000097          	auipc	ra,0x0
    8000220a:	c98080e7          	jalr	-872(ra) # 80001e9e <myproc>
    8000220e:	84aa                	mv	s1,a0
    sz = p->sz;
    80002210:	652c                	ld	a1,72(a0)
    if (n > 0)
    80002212:	01204c63          	bgtz	s2,8000222a <growproc+0x32>
    else if (n < 0)
    80002216:	02094663          	bltz	s2,80002242 <growproc+0x4a>
    p->sz = sz;
    8000221a:	e4ac                	sd	a1,72(s1)
    return 0;
    8000221c:	4501                	li	a0,0
}
    8000221e:	60e2                	ld	ra,24(sp)
    80002220:	6442                	ld	s0,16(sp)
    80002222:	64a2                	ld	s1,8(sp)
    80002224:	6902                	ld	s2,0(sp)
    80002226:	6105                	addi	sp,sp,32
    80002228:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    8000222a:	4691                	li	a3,4
    8000222c:	00b90633          	add	a2,s2,a1
    80002230:	6928                	ld	a0,80(a0)
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	53e080e7          	jalr	1342(ra) # 80001770 <uvmalloc>
    8000223a:	85aa                	mv	a1,a0
    8000223c:	fd79                	bnez	a0,8000221a <growproc+0x22>
            return -1;
    8000223e:	557d                	li	a0,-1
    80002240:	bff9                	j	8000221e <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002242:	00b90633          	add	a2,s2,a1
    80002246:	6928                	ld	a0,80(a0)
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	4e0080e7          	jalr	1248(ra) # 80001728 <uvmdealloc>
    80002250:	85aa                	mv	a1,a0
    80002252:	b7e1                	j	8000221a <growproc+0x22>

0000000080002254 <ps>:
{
    80002254:	715d                	addi	sp,sp,-80
    80002256:	e486                	sd	ra,72(sp)
    80002258:	e0a2                	sd	s0,64(sp)
    8000225a:	fc26                	sd	s1,56(sp)
    8000225c:	f84a                	sd	s2,48(sp)
    8000225e:	f44e                	sd	s3,40(sp)
    80002260:	f052                	sd	s4,32(sp)
    80002262:	ec56                	sd	s5,24(sp)
    80002264:	e85a                	sd	s6,16(sp)
    80002266:	e45e                	sd	s7,8(sp)
    80002268:	e062                	sd	s8,0(sp)
    8000226a:	0880                	addi	s0,sp,80
    8000226c:	84aa                	mv	s1,a0
    8000226e:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80002270:	00000097          	auipc	ra,0x0
    80002274:	c2e080e7          	jalr	-978(ra) # 80001e9e <myproc>
        return result;
    80002278:	4901                	li	s2,0
    if (count == 0)
    8000227a:	0c0b8663          	beqz	s7,80002346 <ps+0xf2>
    void *result = (void *)myproc()->sz;
    8000227e:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80002282:	003b951b          	slliw	a0,s7,0x3
    80002286:	0175053b          	addw	a0,a0,s7
    8000228a:	0025151b          	slliw	a0,a0,0x2
    8000228e:	2501                	sext.w	a0,a0
    80002290:	00000097          	auipc	ra,0x0
    80002294:	f68080e7          	jalr	-152(ra) # 800021f8 <growproc>
    80002298:	12054f63          	bltz	a0,800023d6 <ps+0x182>
    struct user_proc loc_result[count];
    8000229c:	003b9a13          	slli	s4,s7,0x3
    800022a0:	9a5e                	add	s4,s4,s7
    800022a2:	0a0a                	slli	s4,s4,0x2
    800022a4:	00fa0793          	addi	a5,s4,15
    800022a8:	8391                	srli	a5,a5,0x4
    800022aa:	0792                	slli	a5,a5,0x4
    800022ac:	40f10133          	sub	sp,sp,a5
    800022b0:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800022b2:	16800793          	li	a5,360
    800022b6:	02f484b3          	mul	s1,s1,a5
    800022ba:	0001a797          	auipc	a5,0x1a
    800022be:	a4e78793          	addi	a5,a5,-1458 # 8001bd08 <proc>
    800022c2:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800022c4:	0001f797          	auipc	a5,0x1f
    800022c8:	44478793          	addi	a5,a5,1092 # 80021708 <tickslock>
        return result;
    800022cc:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800022ce:	06f4fc63          	bgeu	s1,a5,80002346 <ps+0xf2>
    acquire(&wait_lock);
    800022d2:	0001a517          	auipc	a0,0x1a
    800022d6:	a1e50513          	addi	a0,a0,-1506 # 8001bcf0 <wait_lock>
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	c54080e7          	jalr	-940(ra) # 80000f2e <acquire>
        if (localCount == count)
    800022e2:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    800022e6:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    800022e8:	0001fc17          	auipc	s8,0x1f
    800022ec:	420c0c13          	addi	s8,s8,1056 # 80021708 <tickslock>
    800022f0:	a851                	j	80002384 <ps+0x130>
            loc_result[localCount].state = UNUSED;
    800022f2:	00399793          	slli	a5,s3,0x3
    800022f6:	97ce                	add	a5,a5,s3
    800022f8:	078a                	slli	a5,a5,0x2
    800022fa:	97d6                	add	a5,a5,s5
    800022fc:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	ce0080e7          	jalr	-800(ra) # 80000fe2 <release>
    release(&wait_lock);
    8000230a:	0001a517          	auipc	a0,0x1a
    8000230e:	9e650513          	addi	a0,a0,-1562 # 8001bcf0 <wait_lock>
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	cd0080e7          	jalr	-816(ra) # 80000fe2 <release>
    if (localCount < count)
    8000231a:	0179f963          	bgeu	s3,s7,8000232c <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    8000231e:	00399793          	slli	a5,s3,0x3
    80002322:	97ce                	add	a5,a5,s3
    80002324:	078a                	slli	a5,a5,0x2
    80002326:	97d6                	add	a5,a5,s5
    80002328:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    8000232c:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	b70080e7          	jalr	-1168(ra) # 80001e9e <myproc>
    80002336:	86d2                	mv	a3,s4
    80002338:	8656                	mv	a2,s5
    8000233a:	85da                	mv	a1,s6
    8000233c:	6928                	ld	a0,80(a0)
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	6a8080e7          	jalr	1704(ra) # 800019e6 <copyout>
}
    80002346:	854a                	mv	a0,s2
    80002348:	fb040113          	addi	sp,s0,-80
    8000234c:	60a6                	ld	ra,72(sp)
    8000234e:	6406                	ld	s0,64(sp)
    80002350:	74e2                	ld	s1,56(sp)
    80002352:	7942                	ld	s2,48(sp)
    80002354:	79a2                	ld	s3,40(sp)
    80002356:	7a02                	ld	s4,32(sp)
    80002358:	6ae2                	ld	s5,24(sp)
    8000235a:	6b42                	ld	s6,16(sp)
    8000235c:	6ba2                	ld	s7,8(sp)
    8000235e:	6c02                	ld	s8,0(sp)
    80002360:	6161                	addi	sp,sp,80
    80002362:	8082                	ret
        release(&p->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	c7c080e7          	jalr	-900(ra) # 80000fe2 <release>
        localCount++;
    8000236e:	2985                	addiw	s3,s3,1
    80002370:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    80002374:	16848493          	addi	s1,s1,360
    80002378:	f984f9e3          	bgeu	s1,s8,8000230a <ps+0xb6>
        if (localCount == count)
    8000237c:	02490913          	addi	s2,s2,36
    80002380:	053b8d63          	beq	s7,s3,800023da <ps+0x186>
        acquire(&p->lock);
    80002384:	8526                	mv	a0,s1
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	ba8080e7          	jalr	-1112(ra) # 80000f2e <acquire>
        if (p->state == UNUSED)
    8000238e:	4c9c                	lw	a5,24(s1)
    80002390:	d3ad                	beqz	a5,800022f2 <ps+0x9e>
        loc_result[localCount].state = p->state;
    80002392:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    80002396:	549c                	lw	a5,40(s1)
    80002398:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    8000239c:	54dc                	lw	a5,44(s1)
    8000239e:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800023a2:	589c                	lw	a5,48(s1)
    800023a4:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800023a8:	4641                	li	a2,16
    800023aa:	85ca                	mv	a1,s2
    800023ac:	15848513          	addi	a0,s1,344
    800023b0:	00000097          	auipc	ra,0x0
    800023b4:	a9e080e7          	jalr	-1378(ra) # 80001e4e <copy_array>
        if (p->parent != 0) // init
    800023b8:	7c88                	ld	a0,56(s1)
    800023ba:	d54d                	beqz	a0,80002364 <ps+0x110>
            acquire(&p->parent->lock);
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	b72080e7          	jalr	-1166(ra) # 80000f2e <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800023c4:	7c88                	ld	a0,56(s1)
    800023c6:	591c                	lw	a5,48(a0)
    800023c8:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	c16080e7          	jalr	-1002(ra) # 80000fe2 <release>
    800023d4:	bf41                	j	80002364 <ps+0x110>
        return result;
    800023d6:	4901                	li	s2,0
    800023d8:	b7bd                	j	80002346 <ps+0xf2>
    release(&wait_lock);
    800023da:	0001a517          	auipc	a0,0x1a
    800023de:	91650513          	addi	a0,a0,-1770 # 8001bcf0 <wait_lock>
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	c00080e7          	jalr	-1024(ra) # 80000fe2 <release>
    if (localCount < count)
    800023ea:	b789                	j	8000232c <ps+0xd8>

00000000800023ec <fork>:
{
    800023ec:	7139                	addi	sp,sp,-64
    800023ee:	fc06                	sd	ra,56(sp)
    800023f0:	f822                	sd	s0,48(sp)
    800023f2:	f04a                	sd	s2,32(sp)
    800023f4:	e456                	sd	s5,8(sp)
    800023f6:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	aa6080e7          	jalr	-1370(ra) # 80001e9e <myproc>
    80002400:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002402:	00000097          	auipc	ra,0x0
    80002406:	ca6080e7          	jalr	-858(ra) # 800020a8 <allocproc>
    8000240a:	12050063          	beqz	a0,8000252a <fork+0x13e>
    8000240e:	e852                	sd	s4,16(sp)
    80002410:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002412:	048ab603          	ld	a2,72(s5)
    80002416:	692c                	ld	a1,80(a0)
    80002418:	050ab503          	ld	a0,80(s5)
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	4b8080e7          	jalr	1208(ra) # 800018d4 <uvmcopy>
    80002424:	04054a63          	bltz	a0,80002478 <fork+0x8c>
    80002428:	f426                	sd	s1,40(sp)
    8000242a:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    8000242c:	048ab783          	ld	a5,72(s5)
    80002430:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002434:	058ab683          	ld	a3,88(s5)
    80002438:	87b6                	mv	a5,a3
    8000243a:	058a3703          	ld	a4,88(s4)
    8000243e:	12068693          	addi	a3,a3,288
    80002442:	0007b803          	ld	a6,0(a5)
    80002446:	6788                	ld	a0,8(a5)
    80002448:	6b8c                	ld	a1,16(a5)
    8000244a:	6f90                	ld	a2,24(a5)
    8000244c:	01073023          	sd	a6,0(a4)
    80002450:	e708                	sd	a0,8(a4)
    80002452:	eb0c                	sd	a1,16(a4)
    80002454:	ef10                	sd	a2,24(a4)
    80002456:	02078793          	addi	a5,a5,32
    8000245a:	02070713          	addi	a4,a4,32
    8000245e:	fed792e3          	bne	a5,a3,80002442 <fork+0x56>
    np->trapframe->a0 = 0;
    80002462:	058a3783          	ld	a5,88(s4)
    80002466:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    8000246a:	0d0a8493          	addi	s1,s5,208
    8000246e:	0d0a0913          	addi	s2,s4,208
    80002472:	150a8993          	addi	s3,s5,336
    80002476:	a015                	j	8000249a <fork+0xae>
        freeproc(np);
    80002478:	8552                	mv	a0,s4
    8000247a:	00000097          	auipc	ra,0x0
    8000247e:	bd6080e7          	jalr	-1066(ra) # 80002050 <freeproc>
        release(&np->lock);
    80002482:	8552                	mv	a0,s4
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	b5e080e7          	jalr	-1186(ra) # 80000fe2 <release>
        return -1;
    8000248c:	597d                	li	s2,-1
    8000248e:	6a42                	ld	s4,16(sp)
    80002490:	a071                	j	8000251c <fork+0x130>
    for (i = 0; i < NOFILE; i++)
    80002492:	04a1                	addi	s1,s1,8
    80002494:	0921                	addi	s2,s2,8
    80002496:	01348b63          	beq	s1,s3,800024ac <fork+0xc0>
        if (p->ofile[i])
    8000249a:	6088                	ld	a0,0(s1)
    8000249c:	d97d                	beqz	a0,80002492 <fork+0xa6>
            np->ofile[i] = filedup(p->ofile[i]);
    8000249e:	00003097          	auipc	ra,0x3
    800024a2:	946080e7          	jalr	-1722(ra) # 80004de4 <filedup>
    800024a6:	00a93023          	sd	a0,0(s2)
    800024aa:	b7e5                	j	80002492 <fork+0xa6>
    np->cwd = idup(p->cwd);
    800024ac:	150ab503          	ld	a0,336(s5)
    800024b0:	00002097          	auipc	ra,0x2
    800024b4:	ab0080e7          	jalr	-1360(ra) # 80003f60 <idup>
    800024b8:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800024bc:	4641                	li	a2,16
    800024be:	158a8593          	addi	a1,s5,344
    800024c2:	158a0513          	addi	a0,s4,344
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	ca6080e7          	jalr	-858(ra) # 8000116c <safestrcpy>
    pid = np->pid;
    800024ce:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800024d2:	8552                	mv	a0,s4
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	b0e080e7          	jalr	-1266(ra) # 80000fe2 <release>
    acquire(&wait_lock);
    800024dc:	0001a497          	auipc	s1,0x1a
    800024e0:	81448493          	addi	s1,s1,-2028 # 8001bcf0 <wait_lock>
    800024e4:	8526                	mv	a0,s1
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	a48080e7          	jalr	-1464(ra) # 80000f2e <acquire>
    np->parent = p;
    800024ee:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    800024f2:	8526                	mv	a0,s1
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	aee080e7          	jalr	-1298(ra) # 80000fe2 <release>
    acquire(&np->lock);
    800024fc:	8552                	mv	a0,s4
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	a30080e7          	jalr	-1488(ra) # 80000f2e <acquire>
    np->state = RUNNABLE;
    80002506:	478d                	li	a5,3
    80002508:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    8000250c:	8552                	mv	a0,s4
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	ad4080e7          	jalr	-1324(ra) # 80000fe2 <release>
    return pid;
    80002516:	74a2                	ld	s1,40(sp)
    80002518:	69e2                	ld	s3,24(sp)
    8000251a:	6a42                	ld	s4,16(sp)
}
    8000251c:	854a                	mv	a0,s2
    8000251e:	70e2                	ld	ra,56(sp)
    80002520:	7442                	ld	s0,48(sp)
    80002522:	7902                	ld	s2,32(sp)
    80002524:	6aa2                	ld	s5,8(sp)
    80002526:	6121                	addi	sp,sp,64
    80002528:	8082                	ret
        return -1;
    8000252a:	597d                	li	s2,-1
    8000252c:	bfc5                	j	8000251c <fork+0x130>

000000008000252e <scheduler>:
{
    8000252e:	1101                	addi	sp,sp,-32
    80002530:	ec06                	sd	ra,24(sp)
    80002532:	e822                	sd	s0,16(sp)
    80002534:	e426                	sd	s1,8(sp)
    80002536:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002538:	00009497          	auipc	s1,0x9
    8000253c:	04048493          	addi	s1,s1,64 # 8000b578 <sched_pointer>
    80002540:	609c                	ld	a5,0(s1)
    80002542:	9782                	jalr	a5
    while (1)
    80002544:	bff5                	j	80002540 <scheduler+0x12>

0000000080002546 <sched>:
{
    80002546:	7179                	addi	sp,sp,-48
    80002548:	f406                	sd	ra,40(sp)
    8000254a:	f022                	sd	s0,32(sp)
    8000254c:	ec26                	sd	s1,24(sp)
    8000254e:	e84a                	sd	s2,16(sp)
    80002550:	e44e                	sd	s3,8(sp)
    80002552:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    80002554:	00000097          	auipc	ra,0x0
    80002558:	94a080e7          	jalr	-1718(ra) # 80001e9e <myproc>
    8000255c:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	956080e7          	jalr	-1706(ra) # 80000eb4 <holding>
    80002566:	c53d                	beqz	a0,800025d4 <sched+0x8e>
    80002568:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    8000256a:	2781                	sext.w	a5,a5
    8000256c:	079e                	slli	a5,a5,0x7
    8000256e:	00019717          	auipc	a4,0x19
    80002572:	36a70713          	addi	a4,a4,874 # 8001b8d8 <cpus>
    80002576:	97ba                	add	a5,a5,a4
    80002578:	5fb8                	lw	a4,120(a5)
    8000257a:	4785                	li	a5,1
    8000257c:	06f71463          	bne	a4,a5,800025e4 <sched+0x9e>
    if (p->state == RUNNING)
    80002580:	4c98                	lw	a4,24(s1)
    80002582:	4791                	li	a5,4
    80002584:	06f70863          	beq	a4,a5,800025f4 <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002588:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    8000258c:	8b89                	andi	a5,a5,2
    if (intr_get())
    8000258e:	ebbd                	bnez	a5,80002604 <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    80002590:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002592:	00019917          	auipc	s2,0x19
    80002596:	34690913          	addi	s2,s2,838 # 8001b8d8 <cpus>
    8000259a:	2781                	sext.w	a5,a5
    8000259c:	079e                	slli	a5,a5,0x7
    8000259e:	97ca                	add	a5,a5,s2
    800025a0:	07c7a983          	lw	s3,124(a5)
    800025a4:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800025a6:	2581                	sext.w	a1,a1
    800025a8:	059e                	slli	a1,a1,0x7
    800025aa:	05a1                	addi	a1,a1,8
    800025ac:	95ca                	add	a1,a1,s2
    800025ae:	06048513          	addi	a0,s1,96
    800025b2:	00000097          	auipc	ra,0x0
    800025b6:	764080e7          	jalr	1892(ra) # 80002d16 <swtch>
    800025ba:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800025bc:	2781                	sext.w	a5,a5
    800025be:	079e                	slli	a5,a5,0x7
    800025c0:	993e                	add	s2,s2,a5
    800025c2:	07392e23          	sw	s3,124(s2)
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6145                	addi	sp,sp,48
    800025d2:	8082                	ret
        panic("sched p->lock");
    800025d4:	00006517          	auipc	a0,0x6
    800025d8:	ca450513          	addi	a0,a0,-860 # 80008278 <__func__.1+0x270>
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	f84080e7          	jalr	-124(ra) # 80000560 <panic>
        panic("sched locks");
    800025e4:	00006517          	auipc	a0,0x6
    800025e8:	ca450513          	addi	a0,a0,-860 # 80008288 <__func__.1+0x280>
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	f74080e7          	jalr	-140(ra) # 80000560 <panic>
        panic("sched running");
    800025f4:	00006517          	auipc	a0,0x6
    800025f8:	ca450513          	addi	a0,a0,-860 # 80008298 <__func__.1+0x290>
    800025fc:	ffffe097          	auipc	ra,0xffffe
    80002600:	f64080e7          	jalr	-156(ra) # 80000560 <panic>
        panic("sched interruptible");
    80002604:	00006517          	auipc	a0,0x6
    80002608:	ca450513          	addi	a0,a0,-860 # 800082a8 <__func__.1+0x2a0>
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	f54080e7          	jalr	-172(ra) # 80000560 <panic>

0000000080002614 <yield>:
{
    80002614:	1101                	addi	sp,sp,-32
    80002616:	ec06                	sd	ra,24(sp)
    80002618:	e822                	sd	s0,16(sp)
    8000261a:	e426                	sd	s1,8(sp)
    8000261c:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    8000261e:	00000097          	auipc	ra,0x0
    80002622:	880080e7          	jalr	-1920(ra) # 80001e9e <myproc>
    80002626:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002628:	fffff097          	auipc	ra,0xfffff
    8000262c:	906080e7          	jalr	-1786(ra) # 80000f2e <acquire>
    p->state = RUNNABLE;
    80002630:	478d                	li	a5,3
    80002632:	cc9c                	sw	a5,24(s1)
    sched();
    80002634:	00000097          	auipc	ra,0x0
    80002638:	f12080e7          	jalr	-238(ra) # 80002546 <sched>
    release(&p->lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	fffff097          	auipc	ra,0xfffff
    80002642:	9a4080e7          	jalr	-1628(ra) # 80000fe2 <release>
}
    80002646:	60e2                	ld	ra,24(sp)
    80002648:	6442                	ld	s0,16(sp)
    8000264a:	64a2                	ld	s1,8(sp)
    8000264c:	6105                	addi	sp,sp,32
    8000264e:	8082                	ret

0000000080002650 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002650:	7179                	addi	sp,sp,-48
    80002652:	f406                	sd	ra,40(sp)
    80002654:	f022                	sd	s0,32(sp)
    80002656:	ec26                	sd	s1,24(sp)
    80002658:	e84a                	sd	s2,16(sp)
    8000265a:	e44e                	sd	s3,8(sp)
    8000265c:	1800                	addi	s0,sp,48
    8000265e:	89aa                	mv	s3,a0
    80002660:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002662:	00000097          	auipc	ra,0x0
    80002666:	83c080e7          	jalr	-1988(ra) # 80001e9e <myproc>
    8000266a:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    8000266c:	fffff097          	auipc	ra,0xfffff
    80002670:	8c2080e7          	jalr	-1854(ra) # 80000f2e <acquire>
    release(lk);
    80002674:	854a                	mv	a0,s2
    80002676:	fffff097          	auipc	ra,0xfffff
    8000267a:	96c080e7          	jalr	-1684(ra) # 80000fe2 <release>

    // Go to sleep.
    p->chan = chan;
    8000267e:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002682:	4789                	li	a5,2
    80002684:	cc9c                	sw	a5,24(s1)

    sched();
    80002686:	00000097          	auipc	ra,0x0
    8000268a:	ec0080e7          	jalr	-320(ra) # 80002546 <sched>

    // Tidy up.
    p->chan = 0;
    8000268e:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    80002692:	8526                	mv	a0,s1
    80002694:	fffff097          	auipc	ra,0xfffff
    80002698:	94e080e7          	jalr	-1714(ra) # 80000fe2 <release>
    acquire(lk);
    8000269c:	854a                	mv	a0,s2
    8000269e:	fffff097          	auipc	ra,0xfffff
    800026a2:	890080e7          	jalr	-1904(ra) # 80000f2e <acquire>
}
    800026a6:	70a2                	ld	ra,40(sp)
    800026a8:	7402                	ld	s0,32(sp)
    800026aa:	64e2                	ld	s1,24(sp)
    800026ac:	6942                	ld	s2,16(sp)
    800026ae:	69a2                	ld	s3,8(sp)
    800026b0:	6145                	addi	sp,sp,48
    800026b2:	8082                	ret

00000000800026b4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800026b4:	7139                	addi	sp,sp,-64
    800026b6:	fc06                	sd	ra,56(sp)
    800026b8:	f822                	sd	s0,48(sp)
    800026ba:	f426                	sd	s1,40(sp)
    800026bc:	f04a                	sd	s2,32(sp)
    800026be:	ec4e                	sd	s3,24(sp)
    800026c0:	e852                	sd	s4,16(sp)
    800026c2:	e456                	sd	s5,8(sp)
    800026c4:	0080                	addi	s0,sp,64
    800026c6:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800026c8:	00019497          	auipc	s1,0x19
    800026cc:	64048493          	addi	s1,s1,1600 # 8001bd08 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800026d0:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800026d2:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800026d4:	0001f917          	auipc	s2,0x1f
    800026d8:	03490913          	addi	s2,s2,52 # 80021708 <tickslock>
    800026dc:	a811                	j	800026f0 <wakeup+0x3c>
            }
            release(&p->lock);
    800026de:	8526                	mv	a0,s1
    800026e0:	fffff097          	auipc	ra,0xfffff
    800026e4:	902080e7          	jalr	-1790(ra) # 80000fe2 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800026e8:	16848493          	addi	s1,s1,360
    800026ec:	03248663          	beq	s1,s2,80002718 <wakeup+0x64>
        if (p != myproc())
    800026f0:	fffff097          	auipc	ra,0xfffff
    800026f4:	7ae080e7          	jalr	1966(ra) # 80001e9e <myproc>
    800026f8:	fea488e3          	beq	s1,a0,800026e8 <wakeup+0x34>
            acquire(&p->lock);
    800026fc:	8526                	mv	a0,s1
    800026fe:	fffff097          	auipc	ra,0xfffff
    80002702:	830080e7          	jalr	-2000(ra) # 80000f2e <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002706:	4c9c                	lw	a5,24(s1)
    80002708:	fd379be3          	bne	a5,s3,800026de <wakeup+0x2a>
    8000270c:	709c                	ld	a5,32(s1)
    8000270e:	fd4798e3          	bne	a5,s4,800026de <wakeup+0x2a>
                p->state = RUNNABLE;
    80002712:	0154ac23          	sw	s5,24(s1)
    80002716:	b7e1                	j	800026de <wakeup+0x2a>
        }
    }
}
    80002718:	70e2                	ld	ra,56(sp)
    8000271a:	7442                	ld	s0,48(sp)
    8000271c:	74a2                	ld	s1,40(sp)
    8000271e:	7902                	ld	s2,32(sp)
    80002720:	69e2                	ld	s3,24(sp)
    80002722:	6a42                	ld	s4,16(sp)
    80002724:	6aa2                	ld	s5,8(sp)
    80002726:	6121                	addi	sp,sp,64
    80002728:	8082                	ret

000000008000272a <reparent>:
{
    8000272a:	7179                	addi	sp,sp,-48
    8000272c:	f406                	sd	ra,40(sp)
    8000272e:	f022                	sd	s0,32(sp)
    80002730:	ec26                	sd	s1,24(sp)
    80002732:	e84a                	sd	s2,16(sp)
    80002734:	e44e                	sd	s3,8(sp)
    80002736:	e052                	sd	s4,0(sp)
    80002738:	1800                	addi	s0,sp,48
    8000273a:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000273c:	00019497          	auipc	s1,0x19
    80002740:	5cc48493          	addi	s1,s1,1484 # 8001bd08 <proc>
            pp->parent = initproc;
    80002744:	00009a17          	auipc	s4,0x9
    80002748:	f04a0a13          	addi	s4,s4,-252 # 8000b648 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000274c:	0001f997          	auipc	s3,0x1f
    80002750:	fbc98993          	addi	s3,s3,-68 # 80021708 <tickslock>
    80002754:	a029                	j	8000275e <reparent+0x34>
    80002756:	16848493          	addi	s1,s1,360
    8000275a:	01348d63          	beq	s1,s3,80002774 <reparent+0x4a>
        if (pp->parent == p)
    8000275e:	7c9c                	ld	a5,56(s1)
    80002760:	ff279be3          	bne	a5,s2,80002756 <reparent+0x2c>
            pp->parent = initproc;
    80002764:	000a3503          	ld	a0,0(s4)
    80002768:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    8000276a:	00000097          	auipc	ra,0x0
    8000276e:	f4a080e7          	jalr	-182(ra) # 800026b4 <wakeup>
    80002772:	b7d5                	j	80002756 <reparent+0x2c>
}
    80002774:	70a2                	ld	ra,40(sp)
    80002776:	7402                	ld	s0,32(sp)
    80002778:	64e2                	ld	s1,24(sp)
    8000277a:	6942                	ld	s2,16(sp)
    8000277c:	69a2                	ld	s3,8(sp)
    8000277e:	6a02                	ld	s4,0(sp)
    80002780:	6145                	addi	sp,sp,48
    80002782:	8082                	ret

0000000080002784 <exit>:
{
    80002784:	7179                	addi	sp,sp,-48
    80002786:	f406                	sd	ra,40(sp)
    80002788:	f022                	sd	s0,32(sp)
    8000278a:	ec26                	sd	s1,24(sp)
    8000278c:	e84a                	sd	s2,16(sp)
    8000278e:	e44e                	sd	s3,8(sp)
    80002790:	e052                	sd	s4,0(sp)
    80002792:	1800                	addi	s0,sp,48
    80002794:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    80002796:	fffff097          	auipc	ra,0xfffff
    8000279a:	708080e7          	jalr	1800(ra) # 80001e9e <myproc>
    8000279e:	89aa                	mv	s3,a0
    if (p == initproc)
    800027a0:	00009797          	auipc	a5,0x9
    800027a4:	ea87b783          	ld	a5,-344(a5) # 8000b648 <initproc>
    800027a8:	0d050493          	addi	s1,a0,208
    800027ac:	15050913          	addi	s2,a0,336
    800027b0:	02a79363          	bne	a5,a0,800027d6 <exit+0x52>
        panic("init exiting");
    800027b4:	00006517          	auipc	a0,0x6
    800027b8:	b0c50513          	addi	a0,a0,-1268 # 800082c0 <__func__.1+0x2b8>
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	da4080e7          	jalr	-604(ra) # 80000560 <panic>
            fileclose(f);
    800027c4:	00002097          	auipc	ra,0x2
    800027c8:	672080e7          	jalr	1650(ra) # 80004e36 <fileclose>
            p->ofile[fd] = 0;
    800027cc:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800027d0:	04a1                	addi	s1,s1,8
    800027d2:	01248563          	beq	s1,s2,800027dc <exit+0x58>
        if (p->ofile[fd])
    800027d6:	6088                	ld	a0,0(s1)
    800027d8:	f575                	bnez	a0,800027c4 <exit+0x40>
    800027da:	bfdd                	j	800027d0 <exit+0x4c>
    begin_op();
    800027dc:	00002097          	auipc	ra,0x2
    800027e0:	190080e7          	jalr	400(ra) # 8000496c <begin_op>
    iput(p->cwd);
    800027e4:	1509b503          	ld	a0,336(s3)
    800027e8:	00002097          	auipc	ra,0x2
    800027ec:	974080e7          	jalr	-1676(ra) # 8000415c <iput>
    end_op();
    800027f0:	00002097          	auipc	ra,0x2
    800027f4:	1f6080e7          	jalr	502(ra) # 800049e6 <end_op>
    p->cwd = 0;
    800027f8:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    800027fc:	00019497          	auipc	s1,0x19
    80002800:	4f448493          	addi	s1,s1,1268 # 8001bcf0 <wait_lock>
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	728080e7          	jalr	1832(ra) # 80000f2e <acquire>
    reparent(p);
    8000280e:	854e                	mv	a0,s3
    80002810:	00000097          	auipc	ra,0x0
    80002814:	f1a080e7          	jalr	-230(ra) # 8000272a <reparent>
    wakeup(p->parent);
    80002818:	0389b503          	ld	a0,56(s3)
    8000281c:	00000097          	auipc	ra,0x0
    80002820:	e98080e7          	jalr	-360(ra) # 800026b4 <wakeup>
    acquire(&p->lock);
    80002824:	854e                	mv	a0,s3
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	708080e7          	jalr	1800(ra) # 80000f2e <acquire>
    p->xstate = status;
    8000282e:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002832:	4795                	li	a5,5
    80002834:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002838:	8526                	mv	a0,s1
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	7a8080e7          	jalr	1960(ra) # 80000fe2 <release>
    sched();
    80002842:	00000097          	auipc	ra,0x0
    80002846:	d04080e7          	jalr	-764(ra) # 80002546 <sched>
    panic("zombie exit");
    8000284a:	00006517          	auipc	a0,0x6
    8000284e:	a8650513          	addi	a0,a0,-1402 # 800082d0 <__func__.1+0x2c8>
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	d0e080e7          	jalr	-754(ra) # 80000560 <panic>

000000008000285a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000285a:	7179                	addi	sp,sp,-48
    8000285c:	f406                	sd	ra,40(sp)
    8000285e:	f022                	sd	s0,32(sp)
    80002860:	ec26                	sd	s1,24(sp)
    80002862:	e84a                	sd	s2,16(sp)
    80002864:	e44e                	sd	s3,8(sp)
    80002866:	1800                	addi	s0,sp,48
    80002868:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    8000286a:	00019497          	auipc	s1,0x19
    8000286e:	49e48493          	addi	s1,s1,1182 # 8001bd08 <proc>
    80002872:	0001f997          	auipc	s3,0x1f
    80002876:	e9698993          	addi	s3,s3,-362 # 80021708 <tickslock>
    {
        acquire(&p->lock);
    8000287a:	8526                	mv	a0,s1
    8000287c:	ffffe097          	auipc	ra,0xffffe
    80002880:	6b2080e7          	jalr	1714(ra) # 80000f2e <acquire>
        if (p->pid == pid)
    80002884:	589c                	lw	a5,48(s1)
    80002886:	01278d63          	beq	a5,s2,800028a0 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    8000288a:	8526                	mv	a0,s1
    8000288c:	ffffe097          	auipc	ra,0xffffe
    80002890:	756080e7          	jalr	1878(ra) # 80000fe2 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002894:	16848493          	addi	s1,s1,360
    80002898:	ff3491e3          	bne	s1,s3,8000287a <kill+0x20>
    }
    return -1;
    8000289c:	557d                	li	a0,-1
    8000289e:	a829                	j	800028b8 <kill+0x5e>
            p->killed = 1;
    800028a0:	4785                	li	a5,1
    800028a2:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800028a4:	4c98                	lw	a4,24(s1)
    800028a6:	4789                	li	a5,2
    800028a8:	00f70f63          	beq	a4,a5,800028c6 <kill+0x6c>
            release(&p->lock);
    800028ac:	8526                	mv	a0,s1
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	734080e7          	jalr	1844(ra) # 80000fe2 <release>
            return 0;
    800028b6:	4501                	li	a0,0
}
    800028b8:	70a2                	ld	ra,40(sp)
    800028ba:	7402                	ld	s0,32(sp)
    800028bc:	64e2                	ld	s1,24(sp)
    800028be:	6942                	ld	s2,16(sp)
    800028c0:	69a2                	ld	s3,8(sp)
    800028c2:	6145                	addi	sp,sp,48
    800028c4:	8082                	ret
                p->state = RUNNABLE;
    800028c6:	478d                	li	a5,3
    800028c8:	cc9c                	sw	a5,24(s1)
    800028ca:	b7cd                	j	800028ac <kill+0x52>

00000000800028cc <setkilled>:

void setkilled(struct proc *p)
{
    800028cc:	1101                	addi	sp,sp,-32
    800028ce:	ec06                	sd	ra,24(sp)
    800028d0:	e822                	sd	s0,16(sp)
    800028d2:	e426                	sd	s1,8(sp)
    800028d4:	1000                	addi	s0,sp,32
    800028d6:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	656080e7          	jalr	1622(ra) # 80000f2e <acquire>
    p->killed = 1;
    800028e0:	4785                	li	a5,1
    800028e2:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800028e4:	8526                	mv	a0,s1
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	6fc080e7          	jalr	1788(ra) # 80000fe2 <release>
}
    800028ee:	60e2                	ld	ra,24(sp)
    800028f0:	6442                	ld	s0,16(sp)
    800028f2:	64a2                	ld	s1,8(sp)
    800028f4:	6105                	addi	sp,sp,32
    800028f6:	8082                	ret

00000000800028f8 <killed>:

int killed(struct proc *p)
{
    800028f8:	1101                	addi	sp,sp,-32
    800028fa:	ec06                	sd	ra,24(sp)
    800028fc:	e822                	sd	s0,16(sp)
    800028fe:	e426                	sd	s1,8(sp)
    80002900:	e04a                	sd	s2,0(sp)
    80002902:	1000                	addi	s0,sp,32
    80002904:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	628080e7          	jalr	1576(ra) # 80000f2e <acquire>
    k = p->killed;
    8000290e:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002912:	8526                	mv	a0,s1
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	6ce080e7          	jalr	1742(ra) # 80000fe2 <release>
    return k;
}
    8000291c:	854a                	mv	a0,s2
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6902                	ld	s2,0(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret

000000008000292a <wait>:
{
    8000292a:	715d                	addi	sp,sp,-80
    8000292c:	e486                	sd	ra,72(sp)
    8000292e:	e0a2                	sd	s0,64(sp)
    80002930:	fc26                	sd	s1,56(sp)
    80002932:	f84a                	sd	s2,48(sp)
    80002934:	f44e                	sd	s3,40(sp)
    80002936:	f052                	sd	s4,32(sp)
    80002938:	ec56                	sd	s5,24(sp)
    8000293a:	e85a                	sd	s6,16(sp)
    8000293c:	e45e                	sd	s7,8(sp)
    8000293e:	e062                	sd	s8,0(sp)
    80002940:	0880                	addi	s0,sp,80
    80002942:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	55a080e7          	jalr	1370(ra) # 80001e9e <myproc>
    8000294c:	892a                	mv	s2,a0
    acquire(&wait_lock);
    8000294e:	00019517          	auipc	a0,0x19
    80002952:	3a250513          	addi	a0,a0,930 # 8001bcf0 <wait_lock>
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	5d8080e7          	jalr	1496(ra) # 80000f2e <acquire>
        havekids = 0;
    8000295e:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002960:	4a15                	li	s4,5
                havekids = 1;
    80002962:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002964:	0001f997          	auipc	s3,0x1f
    80002968:	da498993          	addi	s3,s3,-604 # 80021708 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    8000296c:	00019c17          	auipc	s8,0x19
    80002970:	384c0c13          	addi	s8,s8,900 # 8001bcf0 <wait_lock>
    80002974:	a0d1                	j	80002a38 <wait+0x10e>
                    pid = pp->pid;
    80002976:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000297a:	000b0e63          	beqz	s6,80002996 <wait+0x6c>
    8000297e:	4691                	li	a3,4
    80002980:	02c48613          	addi	a2,s1,44
    80002984:	85da                	mv	a1,s6
    80002986:	05093503          	ld	a0,80(s2)
    8000298a:	fffff097          	auipc	ra,0xfffff
    8000298e:	05c080e7          	jalr	92(ra) # 800019e6 <copyout>
    80002992:	04054163          	bltz	a0,800029d4 <wait+0xaa>
                    freeproc(pp);
    80002996:	8526                	mv	a0,s1
    80002998:	fffff097          	auipc	ra,0xfffff
    8000299c:	6b8080e7          	jalr	1720(ra) # 80002050 <freeproc>
                    release(&pp->lock);
    800029a0:	8526                	mv	a0,s1
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	640080e7          	jalr	1600(ra) # 80000fe2 <release>
                    release(&wait_lock);
    800029aa:	00019517          	auipc	a0,0x19
    800029ae:	34650513          	addi	a0,a0,838 # 8001bcf0 <wait_lock>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	630080e7          	jalr	1584(ra) # 80000fe2 <release>
}
    800029ba:	854e                	mv	a0,s3
    800029bc:	60a6                	ld	ra,72(sp)
    800029be:	6406                	ld	s0,64(sp)
    800029c0:	74e2                	ld	s1,56(sp)
    800029c2:	7942                	ld	s2,48(sp)
    800029c4:	79a2                	ld	s3,40(sp)
    800029c6:	7a02                	ld	s4,32(sp)
    800029c8:	6ae2                	ld	s5,24(sp)
    800029ca:	6b42                	ld	s6,16(sp)
    800029cc:	6ba2                	ld	s7,8(sp)
    800029ce:	6c02                	ld	s8,0(sp)
    800029d0:	6161                	addi	sp,sp,80
    800029d2:	8082                	ret
                        release(&pp->lock);
    800029d4:	8526                	mv	a0,s1
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	60c080e7          	jalr	1548(ra) # 80000fe2 <release>
                        release(&wait_lock);
    800029de:	00019517          	auipc	a0,0x19
    800029e2:	31250513          	addi	a0,a0,786 # 8001bcf0 <wait_lock>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	5fc080e7          	jalr	1532(ra) # 80000fe2 <release>
                        return -1;
    800029ee:	59fd                	li	s3,-1
    800029f0:	b7e9                	j	800029ba <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800029f2:	16848493          	addi	s1,s1,360
    800029f6:	03348463          	beq	s1,s3,80002a1e <wait+0xf4>
            if (pp->parent == p)
    800029fa:	7c9c                	ld	a5,56(s1)
    800029fc:	ff279be3          	bne	a5,s2,800029f2 <wait+0xc8>
                acquire(&pp->lock);
    80002a00:	8526                	mv	a0,s1
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	52c080e7          	jalr	1324(ra) # 80000f2e <acquire>
                if (pp->state == ZOMBIE)
    80002a0a:	4c9c                	lw	a5,24(s1)
    80002a0c:	f74785e3          	beq	a5,s4,80002976 <wait+0x4c>
                release(&pp->lock);
    80002a10:	8526                	mv	a0,s1
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	5d0080e7          	jalr	1488(ra) # 80000fe2 <release>
                havekids = 1;
    80002a1a:	8756                	mv	a4,s5
    80002a1c:	bfd9                	j	800029f2 <wait+0xc8>
        if (!havekids || killed(p))
    80002a1e:	c31d                	beqz	a4,80002a44 <wait+0x11a>
    80002a20:	854a                	mv	a0,s2
    80002a22:	00000097          	auipc	ra,0x0
    80002a26:	ed6080e7          	jalr	-298(ra) # 800028f8 <killed>
    80002a2a:	ed09                	bnez	a0,80002a44 <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002a2c:	85e2                	mv	a1,s8
    80002a2e:	854a                	mv	a0,s2
    80002a30:	00000097          	auipc	ra,0x0
    80002a34:	c20080e7          	jalr	-992(ra) # 80002650 <sleep>
        havekids = 0;
    80002a38:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a3a:	00019497          	auipc	s1,0x19
    80002a3e:	2ce48493          	addi	s1,s1,718 # 8001bd08 <proc>
    80002a42:	bf65                	j	800029fa <wait+0xd0>
            release(&wait_lock);
    80002a44:	00019517          	auipc	a0,0x19
    80002a48:	2ac50513          	addi	a0,a0,684 # 8001bcf0 <wait_lock>
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	596080e7          	jalr	1430(ra) # 80000fe2 <release>
            return -1;
    80002a54:	59fd                	li	s3,-1
    80002a56:	b795                	j	800029ba <wait+0x90>

0000000080002a58 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a58:	7179                	addi	sp,sp,-48
    80002a5a:	f406                	sd	ra,40(sp)
    80002a5c:	f022                	sd	s0,32(sp)
    80002a5e:	ec26                	sd	s1,24(sp)
    80002a60:	e84a                	sd	s2,16(sp)
    80002a62:	e44e                	sd	s3,8(sp)
    80002a64:	e052                	sd	s4,0(sp)
    80002a66:	1800                	addi	s0,sp,48
    80002a68:	84aa                	mv	s1,a0
    80002a6a:	892e                	mv	s2,a1
    80002a6c:	89b2                	mv	s3,a2
    80002a6e:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	42e080e7          	jalr	1070(ra) # 80001e9e <myproc>
    if (user_dst)
    80002a78:	c08d                	beqz	s1,80002a9a <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002a7a:	86d2                	mv	a3,s4
    80002a7c:	864e                	mv	a2,s3
    80002a7e:	85ca                	mv	a1,s2
    80002a80:	6928                	ld	a0,80(a0)
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	f64080e7          	jalr	-156(ra) # 800019e6 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6a02                	ld	s4,0(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret
        memmove((char *)dst, src, len);
    80002a9a:	000a061b          	sext.w	a2,s4
    80002a9e:	85ce                	mv	a1,s3
    80002aa0:	854a                	mv	a0,s2
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	5e4080e7          	jalr	1508(ra) # 80001086 <memmove>
        return 0;
    80002aaa:	8526                	mv	a0,s1
    80002aac:	bff9                	j	80002a8a <either_copyout+0x32>

0000000080002aae <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002aae:	7179                	addi	sp,sp,-48
    80002ab0:	f406                	sd	ra,40(sp)
    80002ab2:	f022                	sd	s0,32(sp)
    80002ab4:	ec26                	sd	s1,24(sp)
    80002ab6:	e84a                	sd	s2,16(sp)
    80002ab8:	e44e                	sd	s3,8(sp)
    80002aba:	e052                	sd	s4,0(sp)
    80002abc:	1800                	addi	s0,sp,48
    80002abe:	892a                	mv	s2,a0
    80002ac0:	84ae                	mv	s1,a1
    80002ac2:	89b2                	mv	s3,a2
    80002ac4:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002ac6:	fffff097          	auipc	ra,0xfffff
    80002aca:	3d8080e7          	jalr	984(ra) # 80001e9e <myproc>
    if (user_src)
    80002ace:	c08d                	beqz	s1,80002af0 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002ad0:	86d2                	mv	a3,s4
    80002ad2:	864e                	mv	a2,s3
    80002ad4:	85ca                	mv	a1,s2
    80002ad6:	6928                	ld	a0,80(a0)
    80002ad8:	fffff097          	auipc	ra,0xfffff
    80002adc:	f9a080e7          	jalr	-102(ra) # 80001a72 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002ae0:	70a2                	ld	ra,40(sp)
    80002ae2:	7402                	ld	s0,32(sp)
    80002ae4:	64e2                	ld	s1,24(sp)
    80002ae6:	6942                	ld	s2,16(sp)
    80002ae8:	69a2                	ld	s3,8(sp)
    80002aea:	6a02                	ld	s4,0(sp)
    80002aec:	6145                	addi	sp,sp,48
    80002aee:	8082                	ret
        memmove(dst, (char *)src, len);
    80002af0:	000a061b          	sext.w	a2,s4
    80002af4:	85ce                	mv	a1,s3
    80002af6:	854a                	mv	a0,s2
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	58e080e7          	jalr	1422(ra) # 80001086 <memmove>
        return 0;
    80002b00:	8526                	mv	a0,s1
    80002b02:	bff9                	j	80002ae0 <either_copyin+0x32>

0000000080002b04 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002b04:	715d                	addi	sp,sp,-80
    80002b06:	e486                	sd	ra,72(sp)
    80002b08:	e0a2                	sd	s0,64(sp)
    80002b0a:	fc26                	sd	s1,56(sp)
    80002b0c:	f84a                	sd	s2,48(sp)
    80002b0e:	f44e                	sd	s3,40(sp)
    80002b10:	f052                	sd	s4,32(sp)
    80002b12:	ec56                	sd	s5,24(sp)
    80002b14:	e85a                	sd	s6,16(sp)
    80002b16:	e45e                	sd	s7,8(sp)
    80002b18:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002b1a:	00005517          	auipc	a0,0x5
    80002b1e:	50650513          	addi	a0,a0,1286 # 80008020 <__func__.1+0x18>
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	a9a080e7          	jalr	-1382(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002b2a:	00019497          	auipc	s1,0x19
    80002b2e:	33648493          	addi	s1,s1,822 # 8001be60 <proc+0x158>
    80002b32:	0001f917          	auipc	s2,0x1f
    80002b36:	d2e90913          	addi	s2,s2,-722 # 80021860 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b3a:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002b3c:	00005997          	auipc	s3,0x5
    80002b40:	7a498993          	addi	s3,s3,1956 # 800082e0 <__func__.1+0x2d8>
        printf("%d <%s %s", p->pid, state, p->name);
    80002b44:	00005a97          	auipc	s5,0x5
    80002b48:	7a4a8a93          	addi	s5,s5,1956 # 800082e8 <__func__.1+0x2e0>
        printf("\n");
    80002b4c:	00005a17          	auipc	s4,0x5
    80002b50:	4d4a0a13          	addi	s4,s4,1236 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b54:	00006b97          	auipc	s7,0x6
    80002b58:	d8cb8b93          	addi	s7,s7,-628 # 800088e0 <states.0>
    80002b5c:	a00d                	j	80002b7e <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002b5e:	ed86a583          	lw	a1,-296(a3)
    80002b62:	8556                	mv	a0,s5
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	a58080e7          	jalr	-1448(ra) # 800005bc <printf>
        printf("\n");
    80002b6c:	8552                	mv	a0,s4
    80002b6e:	ffffe097          	auipc	ra,0xffffe
    80002b72:	a4e080e7          	jalr	-1458(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002b76:	16848493          	addi	s1,s1,360
    80002b7a:	03248263          	beq	s1,s2,80002b9e <procdump+0x9a>
        if (p->state == UNUSED)
    80002b7e:	86a6                	mv	a3,s1
    80002b80:	ec04a783          	lw	a5,-320(s1)
    80002b84:	dbed                	beqz	a5,80002b76 <procdump+0x72>
            state = "???";
    80002b86:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b88:	fcfb6be3          	bltu	s6,a5,80002b5e <procdump+0x5a>
    80002b8c:	02079713          	slli	a4,a5,0x20
    80002b90:	01d75793          	srli	a5,a4,0x1d
    80002b94:	97de                	add	a5,a5,s7
    80002b96:	6390                	ld	a2,0(a5)
    80002b98:	f279                	bnez	a2,80002b5e <procdump+0x5a>
            state = "???";
    80002b9a:	864e                	mv	a2,s3
    80002b9c:	b7c9                	j	80002b5e <procdump+0x5a>
    }
}
    80002b9e:	60a6                	ld	ra,72(sp)
    80002ba0:	6406                	ld	s0,64(sp)
    80002ba2:	74e2                	ld	s1,56(sp)
    80002ba4:	7942                	ld	s2,48(sp)
    80002ba6:	79a2                	ld	s3,40(sp)
    80002ba8:	7a02                	ld	s4,32(sp)
    80002baa:	6ae2                	ld	s5,24(sp)
    80002bac:	6b42                	ld	s6,16(sp)
    80002bae:	6ba2                	ld	s7,8(sp)
    80002bb0:	6161                	addi	sp,sp,80
    80002bb2:	8082                	ret

0000000080002bb4 <schedls>:

void schedls()
{
    80002bb4:	1141                	addi	sp,sp,-16
    80002bb6:	e406                	sd	ra,8(sp)
    80002bb8:	e022                	sd	s0,0(sp)
    80002bba:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002bbc:	00005517          	auipc	a0,0x5
    80002bc0:	73c50513          	addi	a0,a0,1852 # 800082f8 <__func__.1+0x2f0>
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	9f8080e7          	jalr	-1544(ra) # 800005bc <printf>
    printf("====================================\n");
    80002bcc:	00005517          	auipc	a0,0x5
    80002bd0:	75450513          	addi	a0,a0,1876 # 80008320 <__func__.1+0x318>
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	9e8080e7          	jalr	-1560(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002bdc:	00009717          	auipc	a4,0x9
    80002be0:	9fc73703          	ld	a4,-1540(a4) # 8000b5d8 <available_schedulers+0x10>
    80002be4:	00009797          	auipc	a5,0x9
    80002be8:	9947b783          	ld	a5,-1644(a5) # 8000b578 <sched_pointer>
    80002bec:	04f70663          	beq	a4,a5,80002c38 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002bf0:	00005517          	auipc	a0,0x5
    80002bf4:	76050513          	addi	a0,a0,1888 # 80008350 <__func__.1+0x348>
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	9c4080e7          	jalr	-1596(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002c00:	00009617          	auipc	a2,0x9
    80002c04:	9e062603          	lw	a2,-1568(a2) # 8000b5e0 <available_schedulers+0x18>
    80002c08:	00009597          	auipc	a1,0x9
    80002c0c:	9c058593          	addi	a1,a1,-1600 # 8000b5c8 <available_schedulers>
    80002c10:	00005517          	auipc	a0,0x5
    80002c14:	74850513          	addi	a0,a0,1864 # 80008358 <__func__.1+0x350>
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	9a4080e7          	jalr	-1628(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002c20:	00005517          	auipc	a0,0x5
    80002c24:	74050513          	addi	a0,a0,1856 # 80008360 <__func__.1+0x358>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	994080e7          	jalr	-1644(ra) # 800005bc <printf>
}
    80002c30:	60a2                	ld	ra,8(sp)
    80002c32:	6402                	ld	s0,0(sp)
    80002c34:	0141                	addi	sp,sp,16
    80002c36:	8082                	ret
            printf("[*]\t");
    80002c38:	00005517          	auipc	a0,0x5
    80002c3c:	71050513          	addi	a0,a0,1808 # 80008348 <__func__.1+0x340>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	97c080e7          	jalr	-1668(ra) # 800005bc <printf>
    80002c48:	bf65                	j	80002c00 <schedls+0x4c>

0000000080002c4a <schedset>:

void schedset(int id)
{
    80002c4a:	1141                	addi	sp,sp,-16
    80002c4c:	e406                	sd	ra,8(sp)
    80002c4e:	e022                	sd	s0,0(sp)
    80002c50:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002c52:	e90d                	bnez	a0,80002c84 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002c54:	00009797          	auipc	a5,0x9
    80002c58:	9847b783          	ld	a5,-1660(a5) # 8000b5d8 <available_schedulers+0x10>
    80002c5c:	00009717          	auipc	a4,0x9
    80002c60:	90f73e23          	sd	a5,-1764(a4) # 8000b578 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002c64:	00009597          	auipc	a1,0x9
    80002c68:	96458593          	addi	a1,a1,-1692 # 8000b5c8 <available_schedulers>
    80002c6c:	00005517          	auipc	a0,0x5
    80002c70:	73450513          	addi	a0,a0,1844 # 800083a0 <__func__.1+0x398>
    80002c74:	ffffe097          	auipc	ra,0xffffe
    80002c78:	948080e7          	jalr	-1720(ra) # 800005bc <printf>
}
    80002c7c:	60a2                	ld	ra,8(sp)
    80002c7e:	6402                	ld	s0,0(sp)
    80002c80:	0141                	addi	sp,sp,16
    80002c82:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002c84:	00005517          	auipc	a0,0x5
    80002c88:	6f450513          	addi	a0,a0,1780 # 80008378 <__func__.1+0x370>
    80002c8c:	ffffe097          	auipc	ra,0xffffe
    80002c90:	930080e7          	jalr	-1744(ra) # 800005bc <printf>
        return;
    80002c94:	b7e5                	j	80002c7c <schedset+0x32>

0000000080002c96 <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    80002c96:	7139                	addi	sp,sp,-64
    80002c98:	fc06                	sd	ra,56(sp)
    80002c9a:	f822                	sd	s0,48(sp)
    80002c9c:	f426                	sd	s1,40(sp)
    80002c9e:	f04a                	sd	s2,32(sp)
    80002ca0:	ec4e                	sd	s3,24(sp)
    80002ca2:	e852                	sd	s4,16(sp)
    80002ca4:	e456                	sd	s5,8(sp)
    80002ca6:	0080                	addi	s0,sp,64
    80002ca8:	8aaa                	mv	s5,a0
    80002caa:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    80002cac:	00019497          	auipc	s1,0x19
    80002cb0:	05c48493          	addi	s1,s1,92 # 8001bd08 <proc>
    80002cb4:	0001f997          	auipc	s3,0x1f
    80002cb8:	a5498993          	addi	s3,s3,-1452 # 80021708 <tickslock>
    80002cbc:	a831                	j	80002cd8 <transvirtproc+0x42>
    {
	acquire(&p->lock);
	found = p->pid == pid && p->state != UNUSED; 
    80002cbe:	0184aa03          	lw	s4,24(s1)
	release(&p->lock);
    80002cc2:	8526                	mv	a0,s1
    80002cc4:	ffffe097          	auipc	ra,0xffffe
    80002cc8:	31e080e7          	jalr	798(ra) # 80000fe2 <release>
	if (found) break;
    80002ccc:	020a1663          	bnez	s4,80002cf8 <transvirtproc+0x62>
    for (p = proc; p < &proc[NPROC]; p++)
    80002cd0:	16848493          	addi	s1,s1,360
    80002cd4:	03348063          	beq	s1,s3,80002cf4 <transvirtproc+0x5e>
	acquire(&p->lock);
    80002cd8:	8526                	mv	a0,s1
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	254080e7          	jalr	596(ra) # 80000f2e <acquire>
	found = p->pid == pid && p->state != UNUSED; 
    80002ce2:	589c                	lw	a5,48(s1)
    80002ce4:	fd278de3          	beq	a5,s2,80002cbe <transvirtproc+0x28>
	release(&p->lock);
    80002ce8:	8526                	mv	a0,s1
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	2f8080e7          	jalr	760(ra) # 80000fe2 <release>
	if (found) break;
    80002cf2:	bff9                	j	80002cd0 <transvirtproc+0x3a>
    }
    if (!found) {
	return 0;
    80002cf4:	4501                	li	a0,0
    80002cf6:	a039                	j	80002d04 <transvirtproc+0x6e>
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002cf8:	68ac                	ld	a1,80(s1)
    80002cfa:	8556                	mv	a0,s5
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	ec0080e7          	jalr	-320(ra) # 80001bbc <transvirt>
}
    80002d04:	70e2                	ld	ra,56(sp)
    80002d06:	7442                	ld	s0,48(sp)
    80002d08:	74a2                	ld	s1,40(sp)
    80002d0a:	7902                	ld	s2,32(sp)
    80002d0c:	69e2                	ld	s3,24(sp)
    80002d0e:	6a42                	ld	s4,16(sp)
    80002d10:	6aa2                	ld	s5,8(sp)
    80002d12:	6121                	addi	sp,sp,64
    80002d14:	8082                	ret

0000000080002d16 <swtch>:
    80002d16:	00153023          	sd	ra,0(a0)
    80002d1a:	00253423          	sd	sp,8(a0)
    80002d1e:	e900                	sd	s0,16(a0)
    80002d20:	ed04                	sd	s1,24(a0)
    80002d22:	03253023          	sd	s2,32(a0)
    80002d26:	03353423          	sd	s3,40(a0)
    80002d2a:	03453823          	sd	s4,48(a0)
    80002d2e:	03553c23          	sd	s5,56(a0)
    80002d32:	05653023          	sd	s6,64(a0)
    80002d36:	05753423          	sd	s7,72(a0)
    80002d3a:	05853823          	sd	s8,80(a0)
    80002d3e:	05953c23          	sd	s9,88(a0)
    80002d42:	07a53023          	sd	s10,96(a0)
    80002d46:	07b53423          	sd	s11,104(a0)
    80002d4a:	0005b083          	ld	ra,0(a1)
    80002d4e:	0085b103          	ld	sp,8(a1)
    80002d52:	6980                	ld	s0,16(a1)
    80002d54:	6d84                	ld	s1,24(a1)
    80002d56:	0205b903          	ld	s2,32(a1)
    80002d5a:	0285b983          	ld	s3,40(a1)
    80002d5e:	0305ba03          	ld	s4,48(a1)
    80002d62:	0385ba83          	ld	s5,56(a1)
    80002d66:	0405bb03          	ld	s6,64(a1)
    80002d6a:	0485bb83          	ld	s7,72(a1)
    80002d6e:	0505bc03          	ld	s8,80(a1)
    80002d72:	0585bc83          	ld	s9,88(a1)
    80002d76:	0605bd03          	ld	s10,96(a1)
    80002d7a:	0685bd83          	ld	s11,104(a1)
    80002d7e:	8082                	ret

0000000080002d80 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002d80:	1141                	addi	sp,sp,-16
    80002d82:	e406                	sd	ra,8(sp)
    80002d84:	e022                	sd	s0,0(sp)
    80002d86:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002d88:	00005597          	auipc	a1,0x5
    80002d8c:	67058593          	addi	a1,a1,1648 # 800083f8 <__func__.1+0x3f0>
    80002d90:	0001f517          	auipc	a0,0x1f
    80002d94:	97850513          	addi	a0,a0,-1672 # 80021708 <tickslock>
    80002d98:	ffffe097          	auipc	ra,0xffffe
    80002d9c:	106080e7          	jalr	262(ra) # 80000e9e <initlock>
}
    80002da0:	60a2                	ld	ra,8(sp)
    80002da2:	6402                	ld	s0,0(sp)
    80002da4:	0141                	addi	sp,sp,16
    80002da6:	8082                	ret

0000000080002da8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002da8:	1141                	addi	sp,sp,-16
    80002daa:	e422                	sd	s0,8(sp)
    80002dac:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002dae:	00003797          	auipc	a5,0x3
    80002db2:	79278793          	addi	a5,a5,1938 # 80006540 <kernelvec>
    80002db6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002dba:	6422                	ld	s0,8(sp)
    80002dbc:	0141                	addi	sp,sp,16
    80002dbe:	8082                	ret

0000000080002dc0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002dc0:	1141                	addi	sp,sp,-16
    80002dc2:	e406                	sd	ra,8(sp)
    80002dc4:	e022                	sd	s0,0(sp)
    80002dc6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	0d6080e7          	jalr	214(ra) # 80001e9e <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002dd0:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002dd4:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002dd6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002dda:	00004697          	auipc	a3,0x4
    80002dde:	22668693          	addi	a3,a3,550 # 80007000 <_trampoline>
    80002de2:	00004717          	auipc	a4,0x4
    80002de6:	21e70713          	addi	a4,a4,542 # 80007000 <_trampoline>
    80002dea:	8f15                	sub	a4,a4,a3
    80002dec:	040007b7          	lui	a5,0x4000
    80002df0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002df2:	07b2                	slli	a5,a5,0xc
    80002df4:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002df6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002dfa:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002dfc:	18002673          	csrr	a2,satp
    80002e00:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e02:	6d30                	ld	a2,88(a0)
    80002e04:	6138                	ld	a4,64(a0)
    80002e06:	6585                	lui	a1,0x1
    80002e08:	972e                	add	a4,a4,a1
    80002e0a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002e0c:	6d38                	ld	a4,88(a0)
    80002e0e:	00000617          	auipc	a2,0x0
    80002e12:	13860613          	addi	a2,a2,312 # 80002f46 <usertrap>
    80002e16:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e18:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002e1a:	8612                	mv	a2,tp
    80002e1c:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002e1e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e22:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e26:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002e2a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002e2e:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002e30:	6f18                	ld	a4,24(a4)
    80002e32:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e36:	6928                	ld	a0,80(a0)
    80002e38:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002e3a:	00004717          	auipc	a4,0x4
    80002e3e:	26270713          	addi	a4,a4,610 # 8000709c <userret>
    80002e42:	8f15                	sub	a4,a4,a3
    80002e44:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002e46:	577d                	li	a4,-1
    80002e48:	177e                	slli	a4,a4,0x3f
    80002e4a:	8d59                	or	a0,a0,a4
    80002e4c:	9782                	jalr	a5
}
    80002e4e:	60a2                	ld	ra,8(sp)
    80002e50:	6402                	ld	s0,0(sp)
    80002e52:	0141                	addi	sp,sp,16
    80002e54:	8082                	ret

0000000080002e56 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002e56:	1101                	addi	sp,sp,-32
    80002e58:	ec06                	sd	ra,24(sp)
    80002e5a:	e822                	sd	s0,16(sp)
    80002e5c:	e426                	sd	s1,8(sp)
    80002e5e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002e60:	0001f497          	auipc	s1,0x1f
    80002e64:	8a848493          	addi	s1,s1,-1880 # 80021708 <tickslock>
    80002e68:	8526                	mv	a0,s1
    80002e6a:	ffffe097          	auipc	ra,0xffffe
    80002e6e:	0c4080e7          	jalr	196(ra) # 80000f2e <acquire>
  ticks++;
    80002e72:	00008517          	auipc	a0,0x8
    80002e76:	7de50513          	addi	a0,a0,2014 # 8000b650 <ticks>
    80002e7a:	411c                	lw	a5,0(a0)
    80002e7c:	2785                	addiw	a5,a5,1
    80002e7e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	834080e7          	jalr	-1996(ra) # 800026b4 <wakeup>
  release(&tickslock);
    80002e88:	8526                	mv	a0,s1
    80002e8a:	ffffe097          	auipc	ra,0xffffe
    80002e8e:	158080e7          	jalr	344(ra) # 80000fe2 <release>
}
    80002e92:	60e2                	ld	ra,24(sp)
    80002e94:	6442                	ld	s0,16(sp)
    80002e96:	64a2                	ld	s1,8(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret

0000000080002e9c <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80002e9c:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ea0:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002ea2:	0a07d163          	bgez	a5,80002f44 <devintr+0xa8>
{
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002eae:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002eb2:	46a5                	li	a3,9
    80002eb4:	00d70c63          	beq	a4,a3,80002ecc <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002eb8:	577d                	li	a4,-1
    80002eba:	177e                	slli	a4,a4,0x3f
    80002ebc:	0705                	addi	a4,a4,1
    return 0;
    80002ebe:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ec0:	06e78163          	beq	a5,a4,80002f22 <devintr+0x86>
  }
}
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	6105                	addi	sp,sp,32
    80002eca:	8082                	ret
    80002ecc:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002ece:	00003097          	auipc	ra,0x3
    80002ed2:	77e080e7          	jalr	1918(ra) # 8000664c <plic_claim>
    80002ed6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ed8:	47a9                	li	a5,10
    80002eda:	00f50963          	beq	a0,a5,80002eec <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002ede:	4785                	li	a5,1
    80002ee0:	00f50b63          	beq	a0,a5,80002ef6 <devintr+0x5a>
    return 1;
    80002ee4:	4505                	li	a0,1
    } else if(irq){
    80002ee6:	ec89                	bnez	s1,80002f00 <devintr+0x64>
    80002ee8:	64a2                	ld	s1,8(sp)
    80002eea:	bfe9                	j	80002ec4 <devintr+0x28>
      uartintr();
    80002eec:	ffffe097          	auipc	ra,0xffffe
    80002ef0:	b20080e7          	jalr	-1248(ra) # 80000a0c <uartintr>
    if(irq)
    80002ef4:	a839                	j	80002f12 <devintr+0x76>
      virtio_disk_intr();
    80002ef6:	00004097          	auipc	ra,0x4
    80002efa:	c80080e7          	jalr	-896(ra) # 80006b76 <virtio_disk_intr>
    if(irq)
    80002efe:	a811                	j	80002f12 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002f00:	85a6                	mv	a1,s1
    80002f02:	00005517          	auipc	a0,0x5
    80002f06:	4fe50513          	addi	a0,a0,1278 # 80008400 <__func__.1+0x3f8>
    80002f0a:	ffffd097          	auipc	ra,0xffffd
    80002f0e:	6b2080e7          	jalr	1714(ra) # 800005bc <printf>
      plic_complete(irq);
    80002f12:	8526                	mv	a0,s1
    80002f14:	00003097          	auipc	ra,0x3
    80002f18:	75c080e7          	jalr	1884(ra) # 80006670 <plic_complete>
    return 1;
    80002f1c:	4505                	li	a0,1
    80002f1e:	64a2                	ld	s1,8(sp)
    80002f20:	b755                	j	80002ec4 <devintr+0x28>
    if(cpuid() == 0){
    80002f22:	fffff097          	auipc	ra,0xfffff
    80002f26:	f50080e7          	jalr	-176(ra) # 80001e72 <cpuid>
    80002f2a:	c901                	beqz	a0,80002f3a <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002f2c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f30:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002f32:	14479073          	csrw	sip,a5
    return 2;
    80002f36:	4509                	li	a0,2
    80002f38:	b771                	j	80002ec4 <devintr+0x28>
      clockintr();
    80002f3a:	00000097          	auipc	ra,0x0
    80002f3e:	f1c080e7          	jalr	-228(ra) # 80002e56 <clockintr>
    80002f42:	b7ed                	j	80002f2c <devintr+0x90>
}
    80002f44:	8082                	ret

0000000080002f46 <usertrap>:
{
    80002f46:	1101                	addi	sp,sp,-32
    80002f48:	ec06                	sd	ra,24(sp)
    80002f4a:	e822                	sd	s0,16(sp)
    80002f4c:	e426                	sd	s1,8(sp)
    80002f4e:	e04a                	sd	s2,0(sp)
    80002f50:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f52:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002f56:	1007f793          	andi	a5,a5,256
    80002f5a:	eba9                	bnez	a5,80002fac <usertrap+0x66>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002f5c:	00003797          	auipc	a5,0x3
    80002f60:	5e478793          	addi	a5,a5,1508 # 80006540 <kernelvec>
    80002f64:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	f36080e7          	jalr	-202(ra) # 80001e9e <myproc>
    80002f70:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002f72:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002f74:	14102773          	csrr	a4,sepc
    80002f78:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002f7a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002f7e:	47a1                	li	a5,8
    80002f80:	02f70e63          	beq	a4,a5,80002fbc <usertrap+0x76>
    80002f84:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002f88:	47bd                	li	a5,15
    80002f8a:	08f70363          	beq	a4,a5,80003010 <usertrap+0xca>
  } else if((which_dev = devintr()) != 0){
    80002f8e:	00000097          	auipc	ra,0x0
    80002f92:	f0e080e7          	jalr	-242(ra) # 80002e9c <devintr>
    80002f96:	892a                	mv	s2,a0
    80002f98:	12050463          	beqz	a0,800030c0 <usertrap+0x17a>
  if(killed(p))
    80002f9c:	8526                	mv	a0,s1
    80002f9e:	00000097          	auipc	ra,0x0
    80002fa2:	95a080e7          	jalr	-1702(ra) # 800028f8 <killed>
    80002fa6:	16050063          	beqz	a0,80003106 <usertrap+0x1c0>
    80002faa:	aa89                	j	800030fc <usertrap+0x1b6>
    panic("usertrap: not from user mode");
    80002fac:	00005517          	auipc	a0,0x5
    80002fb0:	47450513          	addi	a0,a0,1140 # 80008420 <__func__.1+0x418>
    80002fb4:	ffffd097          	auipc	ra,0xffffd
    80002fb8:	5ac080e7          	jalr	1452(ra) # 80000560 <panic>
    if(killed(p))
    80002fbc:	00000097          	auipc	ra,0x0
    80002fc0:	93c080e7          	jalr	-1732(ra) # 800028f8 <killed>
    80002fc4:	e121                	bnez	a0,80003004 <usertrap+0xbe>
    p->trapframe->epc += 4;
    80002fc6:	6cb8                	ld	a4,88(s1)
    80002fc8:	6f1c                	ld	a5,24(a4)
    80002fca:	0791                	addi	a5,a5,4
    80002fcc:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002fce:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002fd2:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002fd6:	10079073          	csrw	sstatus,a5
    syscall();
    80002fda:	00000097          	auipc	ra,0x0
    80002fde:	386080e7          	jalr	902(ra) # 80003360 <syscall>
  if(killed(p))
    80002fe2:	8526                	mv	a0,s1
    80002fe4:	00000097          	auipc	ra,0x0
    80002fe8:	914080e7          	jalr	-1772(ra) # 800028f8 <killed>
    80002fec:	10051763          	bnez	a0,800030fa <usertrap+0x1b4>
  usertrapret();
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	dd0080e7          	jalr	-560(ra) # 80002dc0 <usertrapret>
}
    80002ff8:	60e2                	ld	ra,24(sp)
    80002ffa:	6442                	ld	s0,16(sp)
    80002ffc:	64a2                	ld	s1,8(sp)
    80002ffe:	6902                	ld	s2,0(sp)
    80003000:	6105                	addi	sp,sp,32
    80003002:	8082                	ret
      exit(-1);
    80003004:	557d                	li	a0,-1
    80003006:	fffff097          	auipc	ra,0xfffff
    8000300a:	77e080e7          	jalr	1918(ra) # 80002784 <exit>
    8000300e:	bf65                	j	80002fc6 <usertrap+0x80>
    if(killed(p))
    80003010:	00000097          	auipc	ra,0x0
    80003014:	8e8080e7          	jalr	-1816(ra) # 800028f8 <killed>
    80003018:	e905                	bnez	a0,80003048 <usertrap+0x102>
    asm volatile("csrr %0, stval" : "=r"(x));
    8000301a:	143025f3          	csrr	a1,stval
    pte_t *pte = walk(p->pagetable, va, 0);
    8000301e:	4601                	li	a2,0
    80003020:	77fd                	lui	a5,0xfffff
    80003022:	8dfd                	and	a1,a1,a5
    80003024:	68a8                	ld	a0,80(s1)
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	2e0080e7          	jalr	736(ra) # 80001306 <walk>
    8000302e:	892a                	mv	s2,a0
    if (!pte) {
    80003030:	c115                	beqz	a0,80003054 <usertrap+0x10e>
    int isCOW = PTE_COW & *pte;
    80003032:	00093783          	ld	a5,0(s2)
    if (isCOW)
    80003036:	2007f793          	andi	a5,a5,512
    8000303a:	cba1                	beqz	a5,8000308a <usertrap+0x144>
      cow_triggered(pte);
    8000303c:	854a                	mv	a0,s2
    8000303e:	ffffe097          	auipc	ra,0xffffe
    80003042:	d34080e7          	jalr	-716(ra) # 80000d72 <cow_triggered>
    80003046:	bf71                	j	80002fe2 <usertrap+0x9c>
      exit(-1);
    80003048:	557d                	li	a0,-1
    8000304a:	fffff097          	auipc	ra,0xfffff
    8000304e:	73a080e7          	jalr	1850(ra) # 80002784 <exit>
    80003052:	b7e1                	j	8000301a <usertrap+0xd4>
      printf("tried to write to page not mapped pid=%d", p->pid);
    80003054:	588c                	lw	a1,48(s1)
    80003056:	00005517          	auipc	a0,0x5
    8000305a:	3ea50513          	addi	a0,a0,1002 # 80008440 <__func__.1+0x438>
    8000305e:	ffffd097          	auipc	ra,0xffffd
    80003062:	55e080e7          	jalr	1374(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003066:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    8000306a:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000306e:	00005517          	auipc	a0,0x5
    80003072:	40250513          	addi	a0,a0,1026 # 80008470 <__func__.1+0x468>
    80003076:	ffffd097          	auipc	ra,0xffffd
    8000307a:	546080e7          	jalr	1350(ra) # 800005bc <printf>
      setkilled(p);
    8000307e:	8526                	mv	a0,s1
    80003080:	00000097          	auipc	ra,0x0
    80003084:	84c080e7          	jalr	-1972(ra) # 800028cc <setkilled>
    80003088:	b76d                	j	80003032 <usertrap+0xec>
      printf("illegal write pid=%d", p->pid);
    8000308a:	588c                	lw	a1,48(s1)
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	40450513          	addi	a0,a0,1028 # 80008490 <__func__.1+0x488>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	528080e7          	jalr	1320(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    8000309c:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800030a0:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030a4:	00005517          	auipc	a0,0x5
    800030a8:	3cc50513          	addi	a0,a0,972 # 80008470 <__func__.1+0x468>
    800030ac:	ffffd097          	auipc	ra,0xffffd
    800030b0:	510080e7          	jalr	1296(ra) # 800005bc <printf>
      setkilled(p);
    800030b4:	8526                	mv	a0,s1
    800030b6:	00000097          	auipc	ra,0x0
    800030ba:	816080e7          	jalr	-2026(ra) # 800028cc <setkilled>
    800030be:	b715                	j	80002fe2 <usertrap+0x9c>
    asm volatile("csrr %0, scause" : "=r"(x));
    800030c0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800030c4:	5890                	lw	a2,48(s1)
    800030c6:	00005517          	auipc	a0,0x5
    800030ca:	3e250513          	addi	a0,a0,994 # 800084a8 <__func__.1+0x4a0>
    800030ce:	ffffd097          	auipc	ra,0xffffd
    800030d2:	4ee080e7          	jalr	1262(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800030d6:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800030da:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030de:	00005517          	auipc	a0,0x5
    800030e2:	39250513          	addi	a0,a0,914 # 80008470 <__func__.1+0x468>
    800030e6:	ffffd097          	auipc	ra,0xffffd
    800030ea:	4d6080e7          	jalr	1238(ra) # 800005bc <printf>
    setkilled(p);
    800030ee:	8526                	mv	a0,s1
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	7dc080e7          	jalr	2012(ra) # 800028cc <setkilled>
    800030f8:	b5ed                	j	80002fe2 <usertrap+0x9c>
  if(killed(p))
    800030fa:	4901                	li	s2,0
    exit(-1);
    800030fc:	557d                	li	a0,-1
    800030fe:	fffff097          	auipc	ra,0xfffff
    80003102:	686080e7          	jalr	1670(ra) # 80002784 <exit>
  if(which_dev == 2)
    80003106:	4789                	li	a5,2
    80003108:	eef914e3          	bne	s2,a5,80002ff0 <usertrap+0xaa>
    yield();
    8000310c:	fffff097          	auipc	ra,0xfffff
    80003110:	508080e7          	jalr	1288(ra) # 80002614 <yield>
    80003114:	bdf1                	j	80002ff0 <usertrap+0xaa>

0000000080003116 <kerneltrap>:
{
    80003116:	7179                	addi	sp,sp,-48
    80003118:	f406                	sd	ra,40(sp)
    8000311a:	f022                	sd	s0,32(sp)
    8000311c:	ec26                	sd	s1,24(sp)
    8000311e:	e84a                	sd	s2,16(sp)
    80003120:	e44e                	sd	s3,8(sp)
    80003122:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003124:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003128:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    8000312c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003130:	1004f793          	andi	a5,s1,256
    80003134:	cb85                	beqz	a5,80003164 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003136:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    8000313a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000313c:	ef85                	bnez	a5,80003174 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	d5e080e7          	jalr	-674(ra) # 80002e9c <devintr>
    80003146:	cd1d                	beqz	a0,80003184 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003148:	4789                	li	a5,2
    8000314a:	06f50a63          	beq	a0,a5,800031be <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    8000314e:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80003152:	10049073          	csrw	sstatus,s1
}
    80003156:	70a2                	ld	ra,40(sp)
    80003158:	7402                	ld	s0,32(sp)
    8000315a:	64e2                	ld	s1,24(sp)
    8000315c:	6942                	ld	s2,16(sp)
    8000315e:	69a2                	ld	s3,8(sp)
    80003160:	6145                	addi	sp,sp,48
    80003162:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003164:	00005517          	auipc	a0,0x5
    80003168:	37450513          	addi	a0,a0,884 # 800084d8 <__func__.1+0x4d0>
    8000316c:	ffffd097          	auipc	ra,0xffffd
    80003170:	3f4080e7          	jalr	1012(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80003174:	00005517          	auipc	a0,0x5
    80003178:	38c50513          	addi	a0,a0,908 # 80008500 <__func__.1+0x4f8>
    8000317c:	ffffd097          	auipc	ra,0xffffd
    80003180:	3e4080e7          	jalr	996(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80003184:	85ce                	mv	a1,s3
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	39a50513          	addi	a0,a0,922 # 80008520 <__func__.1+0x518>
    8000318e:	ffffd097          	auipc	ra,0xffffd
    80003192:	42e080e7          	jalr	1070(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003196:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    8000319a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000319e:	00005517          	auipc	a0,0x5
    800031a2:	39250513          	addi	a0,a0,914 # 80008530 <__func__.1+0x528>
    800031a6:	ffffd097          	auipc	ra,0xffffd
    800031aa:	416080e7          	jalr	1046(ra) # 800005bc <printf>
    panic("kerneltrap");
    800031ae:	00005517          	auipc	a0,0x5
    800031b2:	39a50513          	addi	a0,a0,922 # 80008548 <__func__.1+0x540>
    800031b6:	ffffd097          	auipc	ra,0xffffd
    800031ba:	3aa080e7          	jalr	938(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	ce0080e7          	jalr	-800(ra) # 80001e9e <myproc>
    800031c6:	d541                	beqz	a0,8000314e <kerneltrap+0x38>
    800031c8:	fffff097          	auipc	ra,0xfffff
    800031cc:	cd6080e7          	jalr	-810(ra) # 80001e9e <myproc>
    800031d0:	4d18                	lw	a4,24(a0)
    800031d2:	4791                	li	a5,4
    800031d4:	f6f71de3          	bne	a4,a5,8000314e <kerneltrap+0x38>
    yield();
    800031d8:	fffff097          	auipc	ra,0xfffff
    800031dc:	43c080e7          	jalr	1084(ra) # 80002614 <yield>
    800031e0:	b7bd                	j	8000314e <kerneltrap+0x38>

00000000800031e2 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    800031e2:	1101                	addi	sp,sp,-32
    800031e4:	ec06                	sd	ra,24(sp)
    800031e6:	e822                	sd	s0,16(sp)
    800031e8:	e426                	sd	s1,8(sp)
    800031ea:	1000                	addi	s0,sp,32
    800031ec:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    800031ee:	fffff097          	auipc	ra,0xfffff
    800031f2:	cb0080e7          	jalr	-848(ra) # 80001e9e <myproc>
    switch (n)
    800031f6:	4795                	li	a5,5
    800031f8:	0497e163          	bltu	a5,s1,8000323a <argraw+0x58>
    800031fc:	048a                	slli	s1,s1,0x2
    800031fe:	00005717          	auipc	a4,0x5
    80003202:	71270713          	addi	a4,a4,1810 # 80008910 <states.0+0x30>
    80003206:	94ba                	add	s1,s1,a4
    80003208:	409c                	lw	a5,0(s1)
    8000320a:	97ba                	add	a5,a5,a4
    8000320c:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    8000320e:	6d3c                	ld	a5,88(a0)
    80003210:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	64a2                	ld	s1,8(sp)
    80003218:	6105                	addi	sp,sp,32
    8000321a:	8082                	ret
        return p->trapframe->a1;
    8000321c:	6d3c                	ld	a5,88(a0)
    8000321e:	7fa8                	ld	a0,120(a5)
    80003220:	bfcd                	j	80003212 <argraw+0x30>
        return p->trapframe->a2;
    80003222:	6d3c                	ld	a5,88(a0)
    80003224:	63c8                	ld	a0,128(a5)
    80003226:	b7f5                	j	80003212 <argraw+0x30>
        return p->trapframe->a3;
    80003228:	6d3c                	ld	a5,88(a0)
    8000322a:	67c8                	ld	a0,136(a5)
    8000322c:	b7dd                	j	80003212 <argraw+0x30>
        return p->trapframe->a4;
    8000322e:	6d3c                	ld	a5,88(a0)
    80003230:	6bc8                	ld	a0,144(a5)
    80003232:	b7c5                	j	80003212 <argraw+0x30>
        return p->trapframe->a5;
    80003234:	6d3c                	ld	a5,88(a0)
    80003236:	6fc8                	ld	a0,152(a5)
    80003238:	bfe9                	j	80003212 <argraw+0x30>
    panic("argraw");
    8000323a:	00005517          	auipc	a0,0x5
    8000323e:	31e50513          	addi	a0,a0,798 # 80008558 <__func__.1+0x550>
    80003242:	ffffd097          	auipc	ra,0xffffd
    80003246:	31e080e7          	jalr	798(ra) # 80000560 <panic>

000000008000324a <fetchaddr>:
{
    8000324a:	1101                	addi	sp,sp,-32
    8000324c:	ec06                	sd	ra,24(sp)
    8000324e:	e822                	sd	s0,16(sp)
    80003250:	e426                	sd	s1,8(sp)
    80003252:	e04a                	sd	s2,0(sp)
    80003254:	1000                	addi	s0,sp,32
    80003256:	84aa                	mv	s1,a0
    80003258:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000325a:	fffff097          	auipc	ra,0xfffff
    8000325e:	c44080e7          	jalr	-956(ra) # 80001e9e <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003262:	653c                	ld	a5,72(a0)
    80003264:	02f4f863          	bgeu	s1,a5,80003294 <fetchaddr+0x4a>
    80003268:	00848713          	addi	a4,s1,8
    8000326c:	02e7e663          	bltu	a5,a4,80003298 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003270:	46a1                	li	a3,8
    80003272:	8626                	mv	a2,s1
    80003274:	85ca                	mv	a1,s2
    80003276:	6928                	ld	a0,80(a0)
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	7fa080e7          	jalr	2042(ra) # 80001a72 <copyin>
    80003280:	00a03533          	snez	a0,a0
    80003284:	40a00533          	neg	a0,a0
}
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	64a2                	ld	s1,8(sp)
    8000328e:	6902                	ld	s2,0(sp)
    80003290:	6105                	addi	sp,sp,32
    80003292:	8082                	ret
        return -1;
    80003294:	557d                	li	a0,-1
    80003296:	bfcd                	j	80003288 <fetchaddr+0x3e>
    80003298:	557d                	li	a0,-1
    8000329a:	b7fd                	j	80003288 <fetchaddr+0x3e>

000000008000329c <fetchstr>:
{
    8000329c:	7179                	addi	sp,sp,-48
    8000329e:	f406                	sd	ra,40(sp)
    800032a0:	f022                	sd	s0,32(sp)
    800032a2:	ec26                	sd	s1,24(sp)
    800032a4:	e84a                	sd	s2,16(sp)
    800032a6:	e44e                	sd	s3,8(sp)
    800032a8:	1800                	addi	s0,sp,48
    800032aa:	892a                	mv	s2,a0
    800032ac:	84ae                	mv	s1,a1
    800032ae:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    800032b0:	fffff097          	auipc	ra,0xfffff
    800032b4:	bee080e7          	jalr	-1042(ra) # 80001e9e <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800032b8:	86ce                	mv	a3,s3
    800032ba:	864a                	mv	a2,s2
    800032bc:	85a6                	mv	a1,s1
    800032be:	6928                	ld	a0,80(a0)
    800032c0:	fffff097          	auipc	ra,0xfffff
    800032c4:	840080e7          	jalr	-1984(ra) # 80001b00 <copyinstr>
    800032c8:	00054e63          	bltz	a0,800032e4 <fetchstr+0x48>
    return strlen(buf);
    800032cc:	8526                	mv	a0,s1
    800032ce:	ffffe097          	auipc	ra,0xffffe
    800032d2:	ed0080e7          	jalr	-304(ra) # 8000119e <strlen>
}
    800032d6:	70a2                	ld	ra,40(sp)
    800032d8:	7402                	ld	s0,32(sp)
    800032da:	64e2                	ld	s1,24(sp)
    800032dc:	6942                	ld	s2,16(sp)
    800032de:	69a2                	ld	s3,8(sp)
    800032e0:	6145                	addi	sp,sp,48
    800032e2:	8082                	ret
        return -1;
    800032e4:	557d                	li	a0,-1
    800032e6:	bfc5                	j	800032d6 <fetchstr+0x3a>

00000000800032e8 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    800032e8:	1101                	addi	sp,sp,-32
    800032ea:	ec06                	sd	ra,24(sp)
    800032ec:	e822                	sd	s0,16(sp)
    800032ee:	e426                	sd	s1,8(sp)
    800032f0:	1000                	addi	s0,sp,32
    800032f2:	84ae                	mv	s1,a1
    *ip = argraw(n);
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	eee080e7          	jalr	-274(ra) # 800031e2 <argraw>
    800032fc:	c088                	sw	a0,0(s1)
}
    800032fe:	60e2                	ld	ra,24(sp)
    80003300:	6442                	ld	s0,16(sp)
    80003302:	64a2                	ld	s1,8(sp)
    80003304:	6105                	addi	sp,sp,32
    80003306:	8082                	ret

0000000080003308 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003308:	1101                	addi	sp,sp,-32
    8000330a:	ec06                	sd	ra,24(sp)
    8000330c:	e822                	sd	s0,16(sp)
    8000330e:	e426                	sd	s1,8(sp)
    80003310:	1000                	addi	s0,sp,32
    80003312:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003314:	00000097          	auipc	ra,0x0
    80003318:	ece080e7          	jalr	-306(ra) # 800031e2 <argraw>
    8000331c:	e088                	sd	a0,0(s1)
}
    8000331e:	60e2                	ld	ra,24(sp)
    80003320:	6442                	ld	s0,16(sp)
    80003322:	64a2                	ld	s1,8(sp)
    80003324:	6105                	addi	sp,sp,32
    80003326:	8082                	ret

0000000080003328 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003328:	7179                	addi	sp,sp,-48
    8000332a:	f406                	sd	ra,40(sp)
    8000332c:	f022                	sd	s0,32(sp)
    8000332e:	ec26                	sd	s1,24(sp)
    80003330:	e84a                	sd	s2,16(sp)
    80003332:	1800                	addi	s0,sp,48
    80003334:	84ae                	mv	s1,a1
    80003336:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80003338:	fd840593          	addi	a1,s0,-40
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	fcc080e7          	jalr	-52(ra) # 80003308 <argaddr>
    return fetchstr(addr, buf, max);
    80003344:	864a                	mv	a2,s2
    80003346:	85a6                	mv	a1,s1
    80003348:	fd843503          	ld	a0,-40(s0)
    8000334c:	00000097          	auipc	ra,0x0
    80003350:	f50080e7          	jalr	-176(ra) # 8000329c <fetchstr>
}
    80003354:	70a2                	ld	ra,40(sp)
    80003356:	7402                	ld	s0,32(sp)
    80003358:	64e2                	ld	s1,24(sp)
    8000335a:	6942                	ld	s2,16(sp)
    8000335c:	6145                	addi	sp,sp,48
    8000335e:	8082                	ret

0000000080003360 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80003360:	1101                	addi	sp,sp,-32
    80003362:	ec06                	sd	ra,24(sp)
    80003364:	e822                	sd	s0,16(sp)
    80003366:	e426                	sd	s1,8(sp)
    80003368:	e04a                	sd	s2,0(sp)
    8000336a:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    8000336c:	fffff097          	auipc	ra,0xfffff
    80003370:	b32080e7          	jalr	-1230(ra) # 80001e9e <myproc>
    80003374:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003376:	05853903          	ld	s2,88(a0)
    8000337a:	0a893783          	ld	a5,168(s2)
    8000337e:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003382:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffd2517>
    80003384:	4765                	li	a4,25
    80003386:	00f76f63          	bltu	a4,a5,800033a4 <syscall+0x44>
    8000338a:	00369713          	slli	a4,a3,0x3
    8000338e:	00005797          	auipc	a5,0x5
    80003392:	59a78793          	addi	a5,a5,1434 # 80008928 <syscalls>
    80003396:	97ba                	add	a5,a5,a4
    80003398:	639c                	ld	a5,0(a5)
    8000339a:	c789                	beqz	a5,800033a4 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    8000339c:	9782                	jalr	a5
    8000339e:	06a93823          	sd	a0,112(s2)
    800033a2:	a839                	j	800033c0 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800033a4:	15848613          	addi	a2,s1,344
    800033a8:	588c                	lw	a1,48(s1)
    800033aa:	00005517          	auipc	a0,0x5
    800033ae:	1b650513          	addi	a0,a0,438 # 80008560 <__func__.1+0x558>
    800033b2:	ffffd097          	auipc	ra,0xffffd
    800033b6:	20a080e7          	jalr	522(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    800033ba:	6cbc                	ld	a5,88(s1)
    800033bc:	577d                	li	a4,-1
    800033be:	fbb8                	sd	a4,112(a5)
    }
}
    800033c0:	60e2                	ld	ra,24(sp)
    800033c2:	6442                	ld	s0,16(sp)
    800033c4:	64a2                	ld	s1,8(sp)
    800033c6:	6902                	ld	s2,0(sp)
    800033c8:	6105                	addi	sp,sp,32
    800033ca:	8082                	ret

00000000800033cc <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    800033cc:	1101                	addi	sp,sp,-32
    800033ce:	ec06                	sd	ra,24(sp)
    800033d0:	e822                	sd	s0,16(sp)
    800033d2:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    800033d4:	fec40593          	addi	a1,s0,-20
    800033d8:	4501                	li	a0,0
    800033da:	00000097          	auipc	ra,0x0
    800033de:	f0e080e7          	jalr	-242(ra) # 800032e8 <argint>
    exit(n);
    800033e2:	fec42503          	lw	a0,-20(s0)
    800033e6:	fffff097          	auipc	ra,0xfffff
    800033ea:	39e080e7          	jalr	926(ra) # 80002784 <exit>
    return 0; // not reached
}
    800033ee:	4501                	li	a0,0
    800033f0:	60e2                	ld	ra,24(sp)
    800033f2:	6442                	ld	s0,16(sp)
    800033f4:	6105                	addi	sp,sp,32
    800033f6:	8082                	ret

00000000800033f8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800033f8:	1141                	addi	sp,sp,-16
    800033fa:	e406                	sd	ra,8(sp)
    800033fc:	e022                	sd	s0,0(sp)
    800033fe:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003400:	fffff097          	auipc	ra,0xfffff
    80003404:	a9e080e7          	jalr	-1378(ra) # 80001e9e <myproc>
}
    80003408:	5908                	lw	a0,48(a0)
    8000340a:	60a2                	ld	ra,8(sp)
    8000340c:	6402                	ld	s0,0(sp)
    8000340e:	0141                	addi	sp,sp,16
    80003410:	8082                	ret

0000000080003412 <sys_fork>:

uint64
sys_fork(void)
{
    80003412:	1141                	addi	sp,sp,-16
    80003414:	e406                	sd	ra,8(sp)
    80003416:	e022                	sd	s0,0(sp)
    80003418:	0800                	addi	s0,sp,16
    return fork();
    8000341a:	fffff097          	auipc	ra,0xfffff
    8000341e:	fd2080e7          	jalr	-46(ra) # 800023ec <fork>
}
    80003422:	60a2                	ld	ra,8(sp)
    80003424:	6402                	ld	s0,0(sp)
    80003426:	0141                	addi	sp,sp,16
    80003428:	8082                	ret

000000008000342a <sys_wait>:

uint64
sys_wait(void)
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003432:	fe840593          	addi	a1,s0,-24
    80003436:	4501                	li	a0,0
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	ed0080e7          	jalr	-304(ra) # 80003308 <argaddr>
    return wait(p);
    80003440:	fe843503          	ld	a0,-24(s0)
    80003444:	fffff097          	auipc	ra,0xfffff
    80003448:	4e6080e7          	jalr	1254(ra) # 8000292a <wait>
}
    8000344c:	60e2                	ld	ra,24(sp)
    8000344e:	6442                	ld	s0,16(sp)
    80003450:	6105                	addi	sp,sp,32
    80003452:	8082                	ret

0000000080003454 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003454:	7179                	addi	sp,sp,-48
    80003456:	f406                	sd	ra,40(sp)
    80003458:	f022                	sd	s0,32(sp)
    8000345a:	ec26                	sd	s1,24(sp)
    8000345c:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    8000345e:	fdc40593          	addi	a1,s0,-36
    80003462:	4501                	li	a0,0
    80003464:	00000097          	auipc	ra,0x0
    80003468:	e84080e7          	jalr	-380(ra) # 800032e8 <argint>
    addr = myproc()->sz;
    8000346c:	fffff097          	auipc	ra,0xfffff
    80003470:	a32080e7          	jalr	-1486(ra) # 80001e9e <myproc>
    80003474:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003476:	fdc42503          	lw	a0,-36(s0)
    8000347a:	fffff097          	auipc	ra,0xfffff
    8000347e:	d7e080e7          	jalr	-642(ra) # 800021f8 <growproc>
    80003482:	00054863          	bltz	a0,80003492 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003486:	8526                	mv	a0,s1
    80003488:	70a2                	ld	ra,40(sp)
    8000348a:	7402                	ld	s0,32(sp)
    8000348c:	64e2                	ld	s1,24(sp)
    8000348e:	6145                	addi	sp,sp,48
    80003490:	8082                	ret
        return -1;
    80003492:	54fd                	li	s1,-1
    80003494:	bfcd                	j	80003486 <sys_sbrk+0x32>

0000000080003496 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003496:	7139                	addi	sp,sp,-64
    80003498:	fc06                	sd	ra,56(sp)
    8000349a:	f822                	sd	s0,48(sp)
    8000349c:	f04a                	sd	s2,32(sp)
    8000349e:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800034a0:	fcc40593          	addi	a1,s0,-52
    800034a4:	4501                	li	a0,0
    800034a6:	00000097          	auipc	ra,0x0
    800034aa:	e42080e7          	jalr	-446(ra) # 800032e8 <argint>
    acquire(&tickslock);
    800034ae:	0001e517          	auipc	a0,0x1e
    800034b2:	25a50513          	addi	a0,a0,602 # 80021708 <tickslock>
    800034b6:	ffffe097          	auipc	ra,0xffffe
    800034ba:	a78080e7          	jalr	-1416(ra) # 80000f2e <acquire>
    ticks0 = ticks;
    800034be:	00008917          	auipc	s2,0x8
    800034c2:	19292903          	lw	s2,402(s2) # 8000b650 <ticks>
    while (ticks - ticks0 < n)
    800034c6:	fcc42783          	lw	a5,-52(s0)
    800034ca:	c3b9                	beqz	a5,80003510 <sys_sleep+0x7a>
    800034cc:	f426                	sd	s1,40(sp)
    800034ce:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800034d0:	0001e997          	auipc	s3,0x1e
    800034d4:	23898993          	addi	s3,s3,568 # 80021708 <tickslock>
    800034d8:	00008497          	auipc	s1,0x8
    800034dc:	17848493          	addi	s1,s1,376 # 8000b650 <ticks>
        if (killed(myproc()))
    800034e0:	fffff097          	auipc	ra,0xfffff
    800034e4:	9be080e7          	jalr	-1602(ra) # 80001e9e <myproc>
    800034e8:	fffff097          	auipc	ra,0xfffff
    800034ec:	410080e7          	jalr	1040(ra) # 800028f8 <killed>
    800034f0:	ed15                	bnez	a0,8000352c <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    800034f2:	85ce                	mv	a1,s3
    800034f4:	8526                	mv	a0,s1
    800034f6:	fffff097          	auipc	ra,0xfffff
    800034fa:	15a080e7          	jalr	346(ra) # 80002650 <sleep>
    while (ticks - ticks0 < n)
    800034fe:	409c                	lw	a5,0(s1)
    80003500:	412787bb          	subw	a5,a5,s2
    80003504:	fcc42703          	lw	a4,-52(s0)
    80003508:	fce7ece3          	bltu	a5,a4,800034e0 <sys_sleep+0x4a>
    8000350c:	74a2                	ld	s1,40(sp)
    8000350e:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    80003510:	0001e517          	auipc	a0,0x1e
    80003514:	1f850513          	addi	a0,a0,504 # 80021708 <tickslock>
    80003518:	ffffe097          	auipc	ra,0xffffe
    8000351c:	aca080e7          	jalr	-1334(ra) # 80000fe2 <release>
    return 0;
    80003520:	4501                	li	a0,0
}
    80003522:	70e2                	ld	ra,56(sp)
    80003524:	7442                	ld	s0,48(sp)
    80003526:	7902                	ld	s2,32(sp)
    80003528:	6121                	addi	sp,sp,64
    8000352a:	8082                	ret
            release(&tickslock);
    8000352c:	0001e517          	auipc	a0,0x1e
    80003530:	1dc50513          	addi	a0,a0,476 # 80021708 <tickslock>
    80003534:	ffffe097          	auipc	ra,0xffffe
    80003538:	aae080e7          	jalr	-1362(ra) # 80000fe2 <release>
            return -1;
    8000353c:	557d                	li	a0,-1
    8000353e:	74a2                	ld	s1,40(sp)
    80003540:	69e2                	ld	s3,24(sp)
    80003542:	b7c5                	j	80003522 <sys_sleep+0x8c>

0000000080003544 <sys_kill>:

uint64
sys_kill(void)
{
    80003544:	1101                	addi	sp,sp,-32
    80003546:	ec06                	sd	ra,24(sp)
    80003548:	e822                	sd	s0,16(sp)
    8000354a:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000354c:	fec40593          	addi	a1,s0,-20
    80003550:	4501                	li	a0,0
    80003552:	00000097          	auipc	ra,0x0
    80003556:	d96080e7          	jalr	-618(ra) # 800032e8 <argint>
    return kill(pid);
    8000355a:	fec42503          	lw	a0,-20(s0)
    8000355e:	fffff097          	auipc	ra,0xfffff
    80003562:	2fc080e7          	jalr	764(ra) # 8000285a <kill>
}
    80003566:	60e2                	ld	ra,24(sp)
    80003568:	6442                	ld	s0,16(sp)
    8000356a:	6105                	addi	sp,sp,32
    8000356c:	8082                	ret

000000008000356e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000356e:	1101                	addi	sp,sp,-32
    80003570:	ec06                	sd	ra,24(sp)
    80003572:	e822                	sd	s0,16(sp)
    80003574:	e426                	sd	s1,8(sp)
    80003576:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003578:	0001e517          	auipc	a0,0x1e
    8000357c:	19050513          	addi	a0,a0,400 # 80021708 <tickslock>
    80003580:	ffffe097          	auipc	ra,0xffffe
    80003584:	9ae080e7          	jalr	-1618(ra) # 80000f2e <acquire>
    xticks = ticks;
    80003588:	00008497          	auipc	s1,0x8
    8000358c:	0c84a483          	lw	s1,200(s1) # 8000b650 <ticks>
    release(&tickslock);
    80003590:	0001e517          	auipc	a0,0x1e
    80003594:	17850513          	addi	a0,a0,376 # 80021708 <tickslock>
    80003598:	ffffe097          	auipc	ra,0xffffe
    8000359c:	a4a080e7          	jalr	-1462(ra) # 80000fe2 <release>
    return xticks;
}
    800035a0:	02049513          	slli	a0,s1,0x20
    800035a4:	9101                	srli	a0,a0,0x20
    800035a6:	60e2                	ld	ra,24(sp)
    800035a8:	6442                	ld	s0,16(sp)
    800035aa:	64a2                	ld	s1,8(sp)
    800035ac:	6105                	addi	sp,sp,32
    800035ae:	8082                	ret

00000000800035b0 <sys_ps>:

void *
sys_ps(void)
{
    800035b0:	1101                	addi	sp,sp,-32
    800035b2:	ec06                	sd	ra,24(sp)
    800035b4:	e822                	sd	s0,16(sp)
    800035b6:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800035b8:	fe042623          	sw	zero,-20(s0)
    800035bc:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800035c0:	fec40593          	addi	a1,s0,-20
    800035c4:	4501                	li	a0,0
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	d22080e7          	jalr	-734(ra) # 800032e8 <argint>
    argint(1, &count);
    800035ce:	fe840593          	addi	a1,s0,-24
    800035d2:	4505                	li	a0,1
    800035d4:	00000097          	auipc	ra,0x0
    800035d8:	d14080e7          	jalr	-748(ra) # 800032e8 <argint>
    return ps((uint8)start, (uint8)count);
    800035dc:	fe844583          	lbu	a1,-24(s0)
    800035e0:	fec44503          	lbu	a0,-20(s0)
    800035e4:	fffff097          	auipc	ra,0xfffff
    800035e8:	c70080e7          	jalr	-912(ra) # 80002254 <ps>
}
    800035ec:	60e2                	ld	ra,24(sp)
    800035ee:	6442                	ld	s0,16(sp)
    800035f0:	6105                	addi	sp,sp,32
    800035f2:	8082                	ret

00000000800035f4 <sys_schedls>:

uint64 sys_schedls(void)
{
    800035f4:	1141                	addi	sp,sp,-16
    800035f6:	e406                	sd	ra,8(sp)
    800035f8:	e022                	sd	s0,0(sp)
    800035fa:	0800                	addi	s0,sp,16
    schedls();
    800035fc:	fffff097          	auipc	ra,0xfffff
    80003600:	5b8080e7          	jalr	1464(ra) # 80002bb4 <schedls>
    return 0;
}
    80003604:	4501                	li	a0,0
    80003606:	60a2                	ld	ra,8(sp)
    80003608:	6402                	ld	s0,0(sp)
    8000360a:	0141                	addi	sp,sp,16
    8000360c:	8082                	ret

000000008000360e <sys_schedset>:

uint64 sys_schedset(void)
{
    8000360e:	1101                	addi	sp,sp,-32
    80003610:	ec06                	sd	ra,24(sp)
    80003612:	e822                	sd	s0,16(sp)
    80003614:	1000                	addi	s0,sp,32
    int id = 0;
    80003616:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    8000361a:	fec40593          	addi	a1,s0,-20
    8000361e:	4501                	li	a0,0
    80003620:	00000097          	auipc	ra,0x0
    80003624:	cc8080e7          	jalr	-824(ra) # 800032e8 <argint>
    schedset(id - 1);
    80003628:	fec42503          	lw	a0,-20(s0)
    8000362c:	357d                	addiw	a0,a0,-1
    8000362e:	fffff097          	auipc	ra,0xfffff
    80003632:	61c080e7          	jalr	1564(ra) # 80002c4a <schedset>
    return 0;
}
    80003636:	4501                	li	a0,0
    80003638:	60e2                	ld	ra,24(sp)
    8000363a:	6442                	ld	s0,16(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret

0000000080003640 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    80003640:	7179                	addi	sp,sp,-48
    80003642:	f406                	sd	ra,40(sp)
    80003644:	f022                	sd	s0,32(sp)
    80003646:	1800                	addi	s0,sp,48
    int pid = 0;
    80003648:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    8000364c:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    80003650:	fd040593          	addi	a1,s0,-48
    80003654:	4501                	li	a0,0
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	cb2080e7          	jalr	-846(ra) # 80003308 <argaddr>
    argint(1, &pid);
    8000365e:	fdc40593          	addi	a1,s0,-36
    80003662:	4505                	li	a0,1
    80003664:	00000097          	auipc	ra,0x0
    80003668:	c84080e7          	jalr	-892(ra) # 800032e8 <argint>
    if (pid == 0) {
    8000366c:	fdc42783          	lw	a5,-36(s0)
    80003670:	cf89                	beqz	a5,8000368a <sys_va2pa+0x4a>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    80003672:	fdc42583          	lw	a1,-36(s0)
    80003676:	fd043503          	ld	a0,-48(s0)
    8000367a:	fffff097          	auipc	ra,0xfffff
    8000367e:	61c080e7          	jalr	1564(ra) # 80002c96 <transvirtproc>
}
    80003682:	70a2                	ld	ra,40(sp)
    80003684:	7402                	ld	s0,32(sp)
    80003686:	6145                	addi	sp,sp,48
    80003688:	8082                	ret
    8000368a:	ec26                	sd	s1,24(sp)
	struct proc *p = myproc();
    8000368c:	fffff097          	auipc	ra,0xfffff
    80003690:	812080e7          	jalr	-2030(ra) # 80001e9e <myproc>
    80003694:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80003696:	ffffe097          	auipc	ra,0xffffe
    8000369a:	898080e7          	jalr	-1896(ra) # 80000f2e <acquire>
	pid = p->pid;
    8000369e:	589c                	lw	a5,48(s1)
    800036a0:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    800036a4:	8526                	mv	a0,s1
    800036a6:	ffffe097          	auipc	ra,0xffffe
    800036aa:	93c080e7          	jalr	-1732(ra) # 80000fe2 <release>
    800036ae:	64e2                	ld	s1,24(sp)
    800036b0:	b7c9                	j	80003672 <sys_va2pa+0x32>

00000000800036b2 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    800036b2:	1141                	addi	sp,sp,-16
    800036b4:	e406                	sd	ra,8(sp)
    800036b6:	e022                	sd	s0,0(sp)
    800036b8:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800036ba:	00008597          	auipc	a1,0x8
    800036be:	f6e5b583          	ld	a1,-146(a1) # 8000b628 <FREE_PAGES>
    800036c2:	00005517          	auipc	a0,0x5
    800036c6:	ebe50513          	addi	a0,a0,-322 # 80008580 <__func__.1+0x578>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	ef2080e7          	jalr	-270(ra) # 800005bc <printf>
    return 0;
}
    800036d2:	4501                	li	a0,0
    800036d4:	60a2                	ld	ra,8(sp)
    800036d6:	6402                	ld	s0,0(sp)
    800036d8:	0141                	addi	sp,sp,16
    800036da:	8082                	ret

00000000800036dc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800036dc:	7179                	addi	sp,sp,-48
    800036de:	f406                	sd	ra,40(sp)
    800036e0:	f022                	sd	s0,32(sp)
    800036e2:	ec26                	sd	s1,24(sp)
    800036e4:	e84a                	sd	s2,16(sp)
    800036e6:	e44e                	sd	s3,8(sp)
    800036e8:	e052                	sd	s4,0(sp)
    800036ea:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036ec:	00005597          	auipc	a1,0x5
    800036f0:	e9c58593          	addi	a1,a1,-356 # 80008588 <__func__.1+0x580>
    800036f4:	0001e517          	auipc	a0,0x1e
    800036f8:	02c50513          	addi	a0,a0,44 # 80021720 <bcache>
    800036fc:	ffffd097          	auipc	ra,0xffffd
    80003700:	7a2080e7          	jalr	1954(ra) # 80000e9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003704:	00026797          	auipc	a5,0x26
    80003708:	01c78793          	addi	a5,a5,28 # 80029720 <bcache+0x8000>
    8000370c:	00026717          	auipc	a4,0x26
    80003710:	27c70713          	addi	a4,a4,636 # 80029988 <bcache+0x8268>
    80003714:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003718:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000371c:	0001e497          	auipc	s1,0x1e
    80003720:	01c48493          	addi	s1,s1,28 # 80021738 <bcache+0x18>
    b->next = bcache.head.next;
    80003724:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003726:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003728:	00005a17          	auipc	s4,0x5
    8000372c:	e68a0a13          	addi	s4,s4,-408 # 80008590 <__func__.1+0x588>
    b->next = bcache.head.next;
    80003730:	2b893783          	ld	a5,696(s2)
    80003734:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003736:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000373a:	85d2                	mv	a1,s4
    8000373c:	01048513          	addi	a0,s1,16
    80003740:	00001097          	auipc	ra,0x1
    80003744:	4e8080e7          	jalr	1256(ra) # 80004c28 <initsleeplock>
    bcache.head.next->prev = b;
    80003748:	2b893783          	ld	a5,696(s2)
    8000374c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000374e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003752:	45848493          	addi	s1,s1,1112
    80003756:	fd349de3          	bne	s1,s3,80003730 <binit+0x54>
  }
}
    8000375a:	70a2                	ld	ra,40(sp)
    8000375c:	7402                	ld	s0,32(sp)
    8000375e:	64e2                	ld	s1,24(sp)
    80003760:	6942                	ld	s2,16(sp)
    80003762:	69a2                	ld	s3,8(sp)
    80003764:	6a02                	ld	s4,0(sp)
    80003766:	6145                	addi	sp,sp,48
    80003768:	8082                	ret

000000008000376a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000376a:	7179                	addi	sp,sp,-48
    8000376c:	f406                	sd	ra,40(sp)
    8000376e:	f022                	sd	s0,32(sp)
    80003770:	ec26                	sd	s1,24(sp)
    80003772:	e84a                	sd	s2,16(sp)
    80003774:	e44e                	sd	s3,8(sp)
    80003776:	1800                	addi	s0,sp,48
    80003778:	892a                	mv	s2,a0
    8000377a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000377c:	0001e517          	auipc	a0,0x1e
    80003780:	fa450513          	addi	a0,a0,-92 # 80021720 <bcache>
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	7aa080e7          	jalr	1962(ra) # 80000f2e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000378c:	00026497          	auipc	s1,0x26
    80003790:	24c4b483          	ld	s1,588(s1) # 800299d8 <bcache+0x82b8>
    80003794:	00026797          	auipc	a5,0x26
    80003798:	1f478793          	addi	a5,a5,500 # 80029988 <bcache+0x8268>
    8000379c:	02f48f63          	beq	s1,a5,800037da <bread+0x70>
    800037a0:	873e                	mv	a4,a5
    800037a2:	a021                	j	800037aa <bread+0x40>
    800037a4:	68a4                	ld	s1,80(s1)
    800037a6:	02e48a63          	beq	s1,a4,800037da <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800037aa:	449c                	lw	a5,8(s1)
    800037ac:	ff279ce3          	bne	a5,s2,800037a4 <bread+0x3a>
    800037b0:	44dc                	lw	a5,12(s1)
    800037b2:	ff3799e3          	bne	a5,s3,800037a4 <bread+0x3a>
      b->refcnt++;
    800037b6:	40bc                	lw	a5,64(s1)
    800037b8:	2785                	addiw	a5,a5,1
    800037ba:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037bc:	0001e517          	auipc	a0,0x1e
    800037c0:	f6450513          	addi	a0,a0,-156 # 80021720 <bcache>
    800037c4:	ffffe097          	auipc	ra,0xffffe
    800037c8:	81e080e7          	jalr	-2018(ra) # 80000fe2 <release>
      acquiresleep(&b->lock);
    800037cc:	01048513          	addi	a0,s1,16
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	492080e7          	jalr	1170(ra) # 80004c62 <acquiresleep>
      return b;
    800037d8:	a8b9                	j	80003836 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037da:	00026497          	auipc	s1,0x26
    800037de:	1f64b483          	ld	s1,502(s1) # 800299d0 <bcache+0x82b0>
    800037e2:	00026797          	auipc	a5,0x26
    800037e6:	1a678793          	addi	a5,a5,422 # 80029988 <bcache+0x8268>
    800037ea:	00f48863          	beq	s1,a5,800037fa <bread+0x90>
    800037ee:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037f0:	40bc                	lw	a5,64(s1)
    800037f2:	cf81                	beqz	a5,8000380a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037f4:	64a4                	ld	s1,72(s1)
    800037f6:	fee49de3          	bne	s1,a4,800037f0 <bread+0x86>
  panic("bget: no buffers");
    800037fa:	00005517          	auipc	a0,0x5
    800037fe:	d9e50513          	addi	a0,a0,-610 # 80008598 <__func__.1+0x590>
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	d5e080e7          	jalr	-674(ra) # 80000560 <panic>
      b->dev = dev;
    8000380a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000380e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003812:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003816:	4785                	li	a5,1
    80003818:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000381a:	0001e517          	auipc	a0,0x1e
    8000381e:	f0650513          	addi	a0,a0,-250 # 80021720 <bcache>
    80003822:	ffffd097          	auipc	ra,0xffffd
    80003826:	7c0080e7          	jalr	1984(ra) # 80000fe2 <release>
      acquiresleep(&b->lock);
    8000382a:	01048513          	addi	a0,s1,16
    8000382e:	00001097          	auipc	ra,0x1
    80003832:	434080e7          	jalr	1076(ra) # 80004c62 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003836:	409c                	lw	a5,0(s1)
    80003838:	cb89                	beqz	a5,8000384a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000383a:	8526                	mv	a0,s1
    8000383c:	70a2                	ld	ra,40(sp)
    8000383e:	7402                	ld	s0,32(sp)
    80003840:	64e2                	ld	s1,24(sp)
    80003842:	6942                	ld	s2,16(sp)
    80003844:	69a2                	ld	s3,8(sp)
    80003846:	6145                	addi	sp,sp,48
    80003848:	8082                	ret
    virtio_disk_rw(b, 0);
    8000384a:	4581                	li	a1,0
    8000384c:	8526                	mv	a0,s1
    8000384e:	00003097          	auipc	ra,0x3
    80003852:	0fa080e7          	jalr	250(ra) # 80006948 <virtio_disk_rw>
    b->valid = 1;
    80003856:	4785                	li	a5,1
    80003858:	c09c                	sw	a5,0(s1)
  return b;
    8000385a:	b7c5                	j	8000383a <bread+0xd0>

000000008000385c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000385c:	1101                	addi	sp,sp,-32
    8000385e:	ec06                	sd	ra,24(sp)
    80003860:	e822                	sd	s0,16(sp)
    80003862:	e426                	sd	s1,8(sp)
    80003864:	1000                	addi	s0,sp,32
    80003866:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003868:	0541                	addi	a0,a0,16
    8000386a:	00001097          	auipc	ra,0x1
    8000386e:	492080e7          	jalr	1170(ra) # 80004cfc <holdingsleep>
    80003872:	cd01                	beqz	a0,8000388a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003874:	4585                	li	a1,1
    80003876:	8526                	mv	a0,s1
    80003878:	00003097          	auipc	ra,0x3
    8000387c:	0d0080e7          	jalr	208(ra) # 80006948 <virtio_disk_rw>
}
    80003880:	60e2                	ld	ra,24(sp)
    80003882:	6442                	ld	s0,16(sp)
    80003884:	64a2                	ld	s1,8(sp)
    80003886:	6105                	addi	sp,sp,32
    80003888:	8082                	ret
    panic("bwrite");
    8000388a:	00005517          	auipc	a0,0x5
    8000388e:	d2650513          	addi	a0,a0,-730 # 800085b0 <__func__.1+0x5a8>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	cce080e7          	jalr	-818(ra) # 80000560 <panic>

000000008000389a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000389a:	1101                	addi	sp,sp,-32
    8000389c:	ec06                	sd	ra,24(sp)
    8000389e:	e822                	sd	s0,16(sp)
    800038a0:	e426                	sd	s1,8(sp)
    800038a2:	e04a                	sd	s2,0(sp)
    800038a4:	1000                	addi	s0,sp,32
    800038a6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038a8:	01050913          	addi	s2,a0,16
    800038ac:	854a                	mv	a0,s2
    800038ae:	00001097          	auipc	ra,0x1
    800038b2:	44e080e7          	jalr	1102(ra) # 80004cfc <holdingsleep>
    800038b6:	c925                	beqz	a0,80003926 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800038b8:	854a                	mv	a0,s2
    800038ba:	00001097          	auipc	ra,0x1
    800038be:	3fe080e7          	jalr	1022(ra) # 80004cb8 <releasesleep>

  acquire(&bcache.lock);
    800038c2:	0001e517          	auipc	a0,0x1e
    800038c6:	e5e50513          	addi	a0,a0,-418 # 80021720 <bcache>
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	664080e7          	jalr	1636(ra) # 80000f2e <acquire>
  b->refcnt--;
    800038d2:	40bc                	lw	a5,64(s1)
    800038d4:	37fd                	addiw	a5,a5,-1
    800038d6:	0007871b          	sext.w	a4,a5
    800038da:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800038dc:	e71d                	bnez	a4,8000390a <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800038de:	68b8                	ld	a4,80(s1)
    800038e0:	64bc                	ld	a5,72(s1)
    800038e2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800038e4:	68b8                	ld	a4,80(s1)
    800038e6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800038e8:	00026797          	auipc	a5,0x26
    800038ec:	e3878793          	addi	a5,a5,-456 # 80029720 <bcache+0x8000>
    800038f0:	2b87b703          	ld	a4,696(a5)
    800038f4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038f6:	00026717          	auipc	a4,0x26
    800038fa:	09270713          	addi	a4,a4,146 # 80029988 <bcache+0x8268>
    800038fe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003900:	2b87b703          	ld	a4,696(a5)
    80003904:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003906:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000390a:	0001e517          	auipc	a0,0x1e
    8000390e:	e1650513          	addi	a0,a0,-490 # 80021720 <bcache>
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	6d0080e7          	jalr	1744(ra) # 80000fe2 <release>
}
    8000391a:	60e2                	ld	ra,24(sp)
    8000391c:	6442                	ld	s0,16(sp)
    8000391e:	64a2                	ld	s1,8(sp)
    80003920:	6902                	ld	s2,0(sp)
    80003922:	6105                	addi	sp,sp,32
    80003924:	8082                	ret
    panic("brelse");
    80003926:	00005517          	auipc	a0,0x5
    8000392a:	c9250513          	addi	a0,a0,-878 # 800085b8 <__func__.1+0x5b0>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	c32080e7          	jalr	-974(ra) # 80000560 <panic>

0000000080003936 <bpin>:

void
bpin(struct buf *b) {
    80003936:	1101                	addi	sp,sp,-32
    80003938:	ec06                	sd	ra,24(sp)
    8000393a:	e822                	sd	s0,16(sp)
    8000393c:	e426                	sd	s1,8(sp)
    8000393e:	1000                	addi	s0,sp,32
    80003940:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003942:	0001e517          	auipc	a0,0x1e
    80003946:	dde50513          	addi	a0,a0,-546 # 80021720 <bcache>
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	5e4080e7          	jalr	1508(ra) # 80000f2e <acquire>
  b->refcnt++;
    80003952:	40bc                	lw	a5,64(s1)
    80003954:	2785                	addiw	a5,a5,1
    80003956:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003958:	0001e517          	auipc	a0,0x1e
    8000395c:	dc850513          	addi	a0,a0,-568 # 80021720 <bcache>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	682080e7          	jalr	1666(ra) # 80000fe2 <release>
}
    80003968:	60e2                	ld	ra,24(sp)
    8000396a:	6442                	ld	s0,16(sp)
    8000396c:	64a2                	ld	s1,8(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret

0000000080003972 <bunpin>:

void
bunpin(struct buf *b) {
    80003972:	1101                	addi	sp,sp,-32
    80003974:	ec06                	sd	ra,24(sp)
    80003976:	e822                	sd	s0,16(sp)
    80003978:	e426                	sd	s1,8(sp)
    8000397a:	1000                	addi	s0,sp,32
    8000397c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000397e:	0001e517          	auipc	a0,0x1e
    80003982:	da250513          	addi	a0,a0,-606 # 80021720 <bcache>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	5a8080e7          	jalr	1448(ra) # 80000f2e <acquire>
  b->refcnt--;
    8000398e:	40bc                	lw	a5,64(s1)
    80003990:	37fd                	addiw	a5,a5,-1
    80003992:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003994:	0001e517          	auipc	a0,0x1e
    80003998:	d8c50513          	addi	a0,a0,-628 # 80021720 <bcache>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	646080e7          	jalr	1606(ra) # 80000fe2 <release>
}
    800039a4:	60e2                	ld	ra,24(sp)
    800039a6:	6442                	ld	s0,16(sp)
    800039a8:	64a2                	ld	s1,8(sp)
    800039aa:	6105                	addi	sp,sp,32
    800039ac:	8082                	ret

00000000800039ae <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800039ae:	1101                	addi	sp,sp,-32
    800039b0:	ec06                	sd	ra,24(sp)
    800039b2:	e822                	sd	s0,16(sp)
    800039b4:	e426                	sd	s1,8(sp)
    800039b6:	e04a                	sd	s2,0(sp)
    800039b8:	1000                	addi	s0,sp,32
    800039ba:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800039bc:	00d5d59b          	srliw	a1,a1,0xd
    800039c0:	00026797          	auipc	a5,0x26
    800039c4:	43c7a783          	lw	a5,1084(a5) # 80029dfc <sb+0x1c>
    800039c8:	9dbd                	addw	a1,a1,a5
    800039ca:	00000097          	auipc	ra,0x0
    800039ce:	da0080e7          	jalr	-608(ra) # 8000376a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039d2:	0074f713          	andi	a4,s1,7
    800039d6:	4785                	li	a5,1
    800039d8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800039dc:	14ce                	slli	s1,s1,0x33
    800039de:	90d9                	srli	s1,s1,0x36
    800039e0:	00950733          	add	a4,a0,s1
    800039e4:	05874703          	lbu	a4,88(a4)
    800039e8:	00e7f6b3          	and	a3,a5,a4
    800039ec:	c69d                	beqz	a3,80003a1a <bfree+0x6c>
    800039ee:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039f0:	94aa                	add	s1,s1,a0
    800039f2:	fff7c793          	not	a5,a5
    800039f6:	8f7d                	and	a4,a4,a5
    800039f8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800039fc:	00001097          	auipc	ra,0x1
    80003a00:	148080e7          	jalr	328(ra) # 80004b44 <log_write>
  brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	e94080e7          	jalr	-364(ra) # 8000389a <brelse>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6902                	ld	s2,0(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret
    panic("freeing free block");
    80003a1a:	00005517          	auipc	a0,0x5
    80003a1e:	ba650513          	addi	a0,a0,-1114 # 800085c0 <__func__.1+0x5b8>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	b3e080e7          	jalr	-1218(ra) # 80000560 <panic>

0000000080003a2a <balloc>:
{
    80003a2a:	711d                	addi	sp,sp,-96
    80003a2c:	ec86                	sd	ra,88(sp)
    80003a2e:	e8a2                	sd	s0,80(sp)
    80003a30:	e4a6                	sd	s1,72(sp)
    80003a32:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a34:	00026797          	auipc	a5,0x26
    80003a38:	3b07a783          	lw	a5,944(a5) # 80029de4 <sb+0x4>
    80003a3c:	10078f63          	beqz	a5,80003b5a <balloc+0x130>
    80003a40:	e0ca                	sd	s2,64(sp)
    80003a42:	fc4e                	sd	s3,56(sp)
    80003a44:	f852                	sd	s4,48(sp)
    80003a46:	f456                	sd	s5,40(sp)
    80003a48:	f05a                	sd	s6,32(sp)
    80003a4a:	ec5e                	sd	s7,24(sp)
    80003a4c:	e862                	sd	s8,16(sp)
    80003a4e:	e466                	sd	s9,8(sp)
    80003a50:	8baa                	mv	s7,a0
    80003a52:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a54:	00026b17          	auipc	s6,0x26
    80003a58:	38cb0b13          	addi	s6,s6,908 # 80029de0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a5c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a5e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a60:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a62:	6c89                	lui	s9,0x2
    80003a64:	a061                	j	80003aec <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a66:	97ca                	add	a5,a5,s2
    80003a68:	8e55                	or	a2,a2,a3
    80003a6a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00001097          	auipc	ra,0x1
    80003a74:	0d4080e7          	jalr	212(ra) # 80004b44 <log_write>
        brelse(bp);
    80003a78:	854a                	mv	a0,s2
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	e20080e7          	jalr	-480(ra) # 8000389a <brelse>
  bp = bread(dev, bno);
    80003a82:	85a6                	mv	a1,s1
    80003a84:	855e                	mv	a0,s7
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	ce4080e7          	jalr	-796(ra) # 8000376a <bread>
    80003a8e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a90:	40000613          	li	a2,1024
    80003a94:	4581                	li	a1,0
    80003a96:	05850513          	addi	a0,a0,88
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	590080e7          	jalr	1424(ra) # 8000102a <memset>
  log_write(bp);
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	0a0080e7          	jalr	160(ra) # 80004b44 <log_write>
  brelse(bp);
    80003aac:	854a                	mv	a0,s2
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	dec080e7          	jalr	-532(ra) # 8000389a <brelse>
}
    80003ab6:	6906                	ld	s2,64(sp)
    80003ab8:	79e2                	ld	s3,56(sp)
    80003aba:	7a42                	ld	s4,48(sp)
    80003abc:	7aa2                	ld	s5,40(sp)
    80003abe:	7b02                	ld	s6,32(sp)
    80003ac0:	6be2                	ld	s7,24(sp)
    80003ac2:	6c42                	ld	s8,16(sp)
    80003ac4:	6ca2                	ld	s9,8(sp)
}
    80003ac6:	8526                	mv	a0,s1
    80003ac8:	60e6                	ld	ra,88(sp)
    80003aca:	6446                	ld	s0,80(sp)
    80003acc:	64a6                	ld	s1,72(sp)
    80003ace:	6125                	addi	sp,sp,96
    80003ad0:	8082                	ret
    brelse(bp);
    80003ad2:	854a                	mv	a0,s2
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	dc6080e7          	jalr	-570(ra) # 8000389a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003adc:	015c87bb          	addw	a5,s9,s5
    80003ae0:	00078a9b          	sext.w	s5,a5
    80003ae4:	004b2703          	lw	a4,4(s6)
    80003ae8:	06eaf163          	bgeu	s5,a4,80003b4a <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003aec:	41fad79b          	sraiw	a5,s5,0x1f
    80003af0:	0137d79b          	srliw	a5,a5,0x13
    80003af4:	015787bb          	addw	a5,a5,s5
    80003af8:	40d7d79b          	sraiw	a5,a5,0xd
    80003afc:	01cb2583          	lw	a1,28(s6)
    80003b00:	9dbd                	addw	a1,a1,a5
    80003b02:	855e                	mv	a0,s7
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	c66080e7          	jalr	-922(ra) # 8000376a <bread>
    80003b0c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b0e:	004b2503          	lw	a0,4(s6)
    80003b12:	000a849b          	sext.w	s1,s5
    80003b16:	8762                	mv	a4,s8
    80003b18:	faa4fde3          	bgeu	s1,a0,80003ad2 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003b1c:	00777693          	andi	a3,a4,7
    80003b20:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b24:	41f7579b          	sraiw	a5,a4,0x1f
    80003b28:	01d7d79b          	srliw	a5,a5,0x1d
    80003b2c:	9fb9                	addw	a5,a5,a4
    80003b2e:	4037d79b          	sraiw	a5,a5,0x3
    80003b32:	00f90633          	add	a2,s2,a5
    80003b36:	05864603          	lbu	a2,88(a2)
    80003b3a:	00c6f5b3          	and	a1,a3,a2
    80003b3e:	d585                	beqz	a1,80003a66 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b40:	2705                	addiw	a4,a4,1
    80003b42:	2485                	addiw	s1,s1,1
    80003b44:	fd471ae3          	bne	a4,s4,80003b18 <balloc+0xee>
    80003b48:	b769                	j	80003ad2 <balloc+0xa8>
    80003b4a:	6906                	ld	s2,64(sp)
    80003b4c:	79e2                	ld	s3,56(sp)
    80003b4e:	7a42                	ld	s4,48(sp)
    80003b50:	7aa2                	ld	s5,40(sp)
    80003b52:	7b02                	ld	s6,32(sp)
    80003b54:	6be2                	ld	s7,24(sp)
    80003b56:	6c42                	ld	s8,16(sp)
    80003b58:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003b5a:	00005517          	auipc	a0,0x5
    80003b5e:	a7e50513          	addi	a0,a0,-1410 # 800085d8 <__func__.1+0x5d0>
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	a5a080e7          	jalr	-1446(ra) # 800005bc <printf>
  return 0;
    80003b6a:	4481                	li	s1,0
    80003b6c:	bfa9                	j	80003ac6 <balloc+0x9c>

0000000080003b6e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b6e:	7179                	addi	sp,sp,-48
    80003b70:	f406                	sd	ra,40(sp)
    80003b72:	f022                	sd	s0,32(sp)
    80003b74:	ec26                	sd	s1,24(sp)
    80003b76:	e84a                	sd	s2,16(sp)
    80003b78:	e44e                	sd	s3,8(sp)
    80003b7a:	1800                	addi	s0,sp,48
    80003b7c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b7e:	47ad                	li	a5,11
    80003b80:	02b7e863          	bltu	a5,a1,80003bb0 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b84:	02059793          	slli	a5,a1,0x20
    80003b88:	01e7d593          	srli	a1,a5,0x1e
    80003b8c:	00b504b3          	add	s1,a0,a1
    80003b90:	0504a903          	lw	s2,80(s1)
    80003b94:	08091263          	bnez	s2,80003c18 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003b98:	4108                	lw	a0,0(a0)
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	e90080e7          	jalr	-368(ra) # 80003a2a <balloc>
    80003ba2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ba6:	06090963          	beqz	s2,80003c18 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003baa:	0524a823          	sw	s2,80(s1)
    80003bae:	a0ad                	j	80003c18 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003bb0:	ff45849b          	addiw	s1,a1,-12
    80003bb4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bb8:	0ff00793          	li	a5,255
    80003bbc:	08e7e863          	bltu	a5,a4,80003c4c <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003bc0:	08052903          	lw	s2,128(a0)
    80003bc4:	00091f63          	bnez	s2,80003be2 <bmap+0x74>
      addr = balloc(ip->dev);
    80003bc8:	4108                	lw	a0,0(a0)
    80003bca:	00000097          	auipc	ra,0x0
    80003bce:	e60080e7          	jalr	-416(ra) # 80003a2a <balloc>
    80003bd2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bd6:	04090163          	beqz	s2,80003c18 <bmap+0xaa>
    80003bda:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003bdc:	0929a023          	sw	s2,128(s3)
    80003be0:	a011                	j	80003be4 <bmap+0x76>
    80003be2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003be4:	85ca                	mv	a1,s2
    80003be6:	0009a503          	lw	a0,0(s3)
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	b80080e7          	jalr	-1152(ra) # 8000376a <bread>
    80003bf2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bf4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bf8:	02049713          	slli	a4,s1,0x20
    80003bfc:	01e75593          	srli	a1,a4,0x1e
    80003c00:	00b784b3          	add	s1,a5,a1
    80003c04:	0004a903          	lw	s2,0(s1)
    80003c08:	02090063          	beqz	s2,80003c28 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003c0c:	8552                	mv	a0,s4
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	c8c080e7          	jalr	-884(ra) # 8000389a <brelse>
    return addr;
    80003c16:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003c18:	854a                	mv	a0,s2
    80003c1a:	70a2                	ld	ra,40(sp)
    80003c1c:	7402                	ld	s0,32(sp)
    80003c1e:	64e2                	ld	s1,24(sp)
    80003c20:	6942                	ld	s2,16(sp)
    80003c22:	69a2                	ld	s3,8(sp)
    80003c24:	6145                	addi	sp,sp,48
    80003c26:	8082                	ret
      addr = balloc(ip->dev);
    80003c28:	0009a503          	lw	a0,0(s3)
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	dfe080e7          	jalr	-514(ra) # 80003a2a <balloc>
    80003c34:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c38:	fc090ae3          	beqz	s2,80003c0c <bmap+0x9e>
        a[bn] = addr;
    80003c3c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c40:	8552                	mv	a0,s4
    80003c42:	00001097          	auipc	ra,0x1
    80003c46:	f02080e7          	jalr	-254(ra) # 80004b44 <log_write>
    80003c4a:	b7c9                	j	80003c0c <bmap+0x9e>
    80003c4c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003c4e:	00005517          	auipc	a0,0x5
    80003c52:	9a250513          	addi	a0,a0,-1630 # 800085f0 <__func__.1+0x5e8>
    80003c56:	ffffd097          	auipc	ra,0xffffd
    80003c5a:	90a080e7          	jalr	-1782(ra) # 80000560 <panic>

0000000080003c5e <iget>:
{
    80003c5e:	7179                	addi	sp,sp,-48
    80003c60:	f406                	sd	ra,40(sp)
    80003c62:	f022                	sd	s0,32(sp)
    80003c64:	ec26                	sd	s1,24(sp)
    80003c66:	e84a                	sd	s2,16(sp)
    80003c68:	e44e                	sd	s3,8(sp)
    80003c6a:	e052                	sd	s4,0(sp)
    80003c6c:	1800                	addi	s0,sp,48
    80003c6e:	89aa                	mv	s3,a0
    80003c70:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c72:	00026517          	auipc	a0,0x26
    80003c76:	18e50513          	addi	a0,a0,398 # 80029e00 <itable>
    80003c7a:	ffffd097          	auipc	ra,0xffffd
    80003c7e:	2b4080e7          	jalr	692(ra) # 80000f2e <acquire>
  empty = 0;
    80003c82:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c84:	00026497          	auipc	s1,0x26
    80003c88:	19448493          	addi	s1,s1,404 # 80029e18 <itable+0x18>
    80003c8c:	00028697          	auipc	a3,0x28
    80003c90:	c1c68693          	addi	a3,a3,-996 # 8002b8a8 <log>
    80003c94:	a039                	j	80003ca2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c96:	02090b63          	beqz	s2,80003ccc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c9a:	08848493          	addi	s1,s1,136
    80003c9e:	02d48a63          	beq	s1,a3,80003cd2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ca2:	449c                	lw	a5,8(s1)
    80003ca4:	fef059e3          	blez	a5,80003c96 <iget+0x38>
    80003ca8:	4098                	lw	a4,0(s1)
    80003caa:	ff3716e3          	bne	a4,s3,80003c96 <iget+0x38>
    80003cae:	40d8                	lw	a4,4(s1)
    80003cb0:	ff4713e3          	bne	a4,s4,80003c96 <iget+0x38>
      ip->ref++;
    80003cb4:	2785                	addiw	a5,a5,1
    80003cb6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003cb8:	00026517          	auipc	a0,0x26
    80003cbc:	14850513          	addi	a0,a0,328 # 80029e00 <itable>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	322080e7          	jalr	802(ra) # 80000fe2 <release>
      return ip;
    80003cc8:	8926                	mv	s2,s1
    80003cca:	a03d                	j	80003cf8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ccc:	f7f9                	bnez	a5,80003c9a <iget+0x3c>
      empty = ip;
    80003cce:	8926                	mv	s2,s1
    80003cd0:	b7e9                	j	80003c9a <iget+0x3c>
  if(empty == 0)
    80003cd2:	02090c63          	beqz	s2,80003d0a <iget+0xac>
  ip->dev = dev;
    80003cd6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003cda:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cde:	4785                	li	a5,1
    80003ce0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ce4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ce8:	00026517          	auipc	a0,0x26
    80003cec:	11850513          	addi	a0,a0,280 # 80029e00 <itable>
    80003cf0:	ffffd097          	auipc	ra,0xffffd
    80003cf4:	2f2080e7          	jalr	754(ra) # 80000fe2 <release>
}
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	70a2                	ld	ra,40(sp)
    80003cfc:	7402                	ld	s0,32(sp)
    80003cfe:	64e2                	ld	s1,24(sp)
    80003d00:	6942                	ld	s2,16(sp)
    80003d02:	69a2                	ld	s3,8(sp)
    80003d04:	6a02                	ld	s4,0(sp)
    80003d06:	6145                	addi	sp,sp,48
    80003d08:	8082                	ret
    panic("iget: no inodes");
    80003d0a:	00005517          	auipc	a0,0x5
    80003d0e:	8fe50513          	addi	a0,a0,-1794 # 80008608 <__func__.1+0x600>
    80003d12:	ffffd097          	auipc	ra,0xffffd
    80003d16:	84e080e7          	jalr	-1970(ra) # 80000560 <panic>

0000000080003d1a <fsinit>:
fsinit(int dev) {
    80003d1a:	7179                	addi	sp,sp,-48
    80003d1c:	f406                	sd	ra,40(sp)
    80003d1e:	f022                	sd	s0,32(sp)
    80003d20:	ec26                	sd	s1,24(sp)
    80003d22:	e84a                	sd	s2,16(sp)
    80003d24:	e44e                	sd	s3,8(sp)
    80003d26:	1800                	addi	s0,sp,48
    80003d28:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d2a:	4585                	li	a1,1
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	a3e080e7          	jalr	-1474(ra) # 8000376a <bread>
    80003d34:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d36:	00026997          	auipc	s3,0x26
    80003d3a:	0aa98993          	addi	s3,s3,170 # 80029de0 <sb>
    80003d3e:	02000613          	li	a2,32
    80003d42:	05850593          	addi	a1,a0,88
    80003d46:	854e                	mv	a0,s3
    80003d48:	ffffd097          	auipc	ra,0xffffd
    80003d4c:	33e080e7          	jalr	830(ra) # 80001086 <memmove>
  brelse(bp);
    80003d50:	8526                	mv	a0,s1
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	b48080e7          	jalr	-1208(ra) # 8000389a <brelse>
  if(sb.magic != FSMAGIC)
    80003d5a:	0009a703          	lw	a4,0(s3)
    80003d5e:	102037b7          	lui	a5,0x10203
    80003d62:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d66:	02f71263          	bne	a4,a5,80003d8a <fsinit+0x70>
  initlog(dev, &sb);
    80003d6a:	00026597          	auipc	a1,0x26
    80003d6e:	07658593          	addi	a1,a1,118 # 80029de0 <sb>
    80003d72:	854a                	mv	a0,s2
    80003d74:	00001097          	auipc	ra,0x1
    80003d78:	b60080e7          	jalr	-1184(ra) # 800048d4 <initlog>
}
    80003d7c:	70a2                	ld	ra,40(sp)
    80003d7e:	7402                	ld	s0,32(sp)
    80003d80:	64e2                	ld	s1,24(sp)
    80003d82:	6942                	ld	s2,16(sp)
    80003d84:	69a2                	ld	s3,8(sp)
    80003d86:	6145                	addi	sp,sp,48
    80003d88:	8082                	ret
    panic("invalid file system");
    80003d8a:	00005517          	auipc	a0,0x5
    80003d8e:	88e50513          	addi	a0,a0,-1906 # 80008618 <__func__.1+0x610>
    80003d92:	ffffc097          	auipc	ra,0xffffc
    80003d96:	7ce080e7          	jalr	1998(ra) # 80000560 <panic>

0000000080003d9a <iinit>:
{
    80003d9a:	7179                	addi	sp,sp,-48
    80003d9c:	f406                	sd	ra,40(sp)
    80003d9e:	f022                	sd	s0,32(sp)
    80003da0:	ec26                	sd	s1,24(sp)
    80003da2:	e84a                	sd	s2,16(sp)
    80003da4:	e44e                	sd	s3,8(sp)
    80003da6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003da8:	00005597          	auipc	a1,0x5
    80003dac:	88858593          	addi	a1,a1,-1912 # 80008630 <__func__.1+0x628>
    80003db0:	00026517          	auipc	a0,0x26
    80003db4:	05050513          	addi	a0,a0,80 # 80029e00 <itable>
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	0e6080e7          	jalr	230(ra) # 80000e9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003dc0:	00026497          	auipc	s1,0x26
    80003dc4:	06848493          	addi	s1,s1,104 # 80029e28 <itable+0x28>
    80003dc8:	00028997          	auipc	s3,0x28
    80003dcc:	af098993          	addi	s3,s3,-1296 # 8002b8b8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003dd0:	00005917          	auipc	s2,0x5
    80003dd4:	86890913          	addi	s2,s2,-1944 # 80008638 <__func__.1+0x630>
    80003dd8:	85ca                	mv	a1,s2
    80003dda:	8526                	mv	a0,s1
    80003ddc:	00001097          	auipc	ra,0x1
    80003de0:	e4c080e7          	jalr	-436(ra) # 80004c28 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003de4:	08848493          	addi	s1,s1,136
    80003de8:	ff3498e3          	bne	s1,s3,80003dd8 <iinit+0x3e>
}
    80003dec:	70a2                	ld	ra,40(sp)
    80003dee:	7402                	ld	s0,32(sp)
    80003df0:	64e2                	ld	s1,24(sp)
    80003df2:	6942                	ld	s2,16(sp)
    80003df4:	69a2                	ld	s3,8(sp)
    80003df6:	6145                	addi	sp,sp,48
    80003df8:	8082                	ret

0000000080003dfa <ialloc>:
{
    80003dfa:	7139                	addi	sp,sp,-64
    80003dfc:	fc06                	sd	ra,56(sp)
    80003dfe:	f822                	sd	s0,48(sp)
    80003e00:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e02:	00026717          	auipc	a4,0x26
    80003e06:	fea72703          	lw	a4,-22(a4) # 80029dec <sb+0xc>
    80003e0a:	4785                	li	a5,1
    80003e0c:	06e7f463          	bgeu	a5,a4,80003e74 <ialloc+0x7a>
    80003e10:	f426                	sd	s1,40(sp)
    80003e12:	f04a                	sd	s2,32(sp)
    80003e14:	ec4e                	sd	s3,24(sp)
    80003e16:	e852                	sd	s4,16(sp)
    80003e18:	e456                	sd	s5,8(sp)
    80003e1a:	e05a                	sd	s6,0(sp)
    80003e1c:	8aaa                	mv	s5,a0
    80003e1e:	8b2e                	mv	s6,a1
    80003e20:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e22:	00026a17          	auipc	s4,0x26
    80003e26:	fbea0a13          	addi	s4,s4,-66 # 80029de0 <sb>
    80003e2a:	00495593          	srli	a1,s2,0x4
    80003e2e:	018a2783          	lw	a5,24(s4)
    80003e32:	9dbd                	addw	a1,a1,a5
    80003e34:	8556                	mv	a0,s5
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	934080e7          	jalr	-1740(ra) # 8000376a <bread>
    80003e3e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e40:	05850993          	addi	s3,a0,88
    80003e44:	00f97793          	andi	a5,s2,15
    80003e48:	079a                	slli	a5,a5,0x6
    80003e4a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e4c:	00099783          	lh	a5,0(s3)
    80003e50:	cf9d                	beqz	a5,80003e8e <ialloc+0x94>
    brelse(bp);
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	a48080e7          	jalr	-1464(ra) # 8000389a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e5a:	0905                	addi	s2,s2,1
    80003e5c:	00ca2703          	lw	a4,12(s4)
    80003e60:	0009079b          	sext.w	a5,s2
    80003e64:	fce7e3e3          	bltu	a5,a4,80003e2a <ialloc+0x30>
    80003e68:	74a2                	ld	s1,40(sp)
    80003e6a:	7902                	ld	s2,32(sp)
    80003e6c:	69e2                	ld	s3,24(sp)
    80003e6e:	6a42                	ld	s4,16(sp)
    80003e70:	6aa2                	ld	s5,8(sp)
    80003e72:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003e74:	00004517          	auipc	a0,0x4
    80003e78:	7cc50513          	addi	a0,a0,1996 # 80008640 <__func__.1+0x638>
    80003e7c:	ffffc097          	auipc	ra,0xffffc
    80003e80:	740080e7          	jalr	1856(ra) # 800005bc <printf>
  return 0;
    80003e84:	4501                	li	a0,0
}
    80003e86:	70e2                	ld	ra,56(sp)
    80003e88:	7442                	ld	s0,48(sp)
    80003e8a:	6121                	addi	sp,sp,64
    80003e8c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e8e:	04000613          	li	a2,64
    80003e92:	4581                	li	a1,0
    80003e94:	854e                	mv	a0,s3
    80003e96:	ffffd097          	auipc	ra,0xffffd
    80003e9a:	194080e7          	jalr	404(ra) # 8000102a <memset>
      dip->type = type;
    80003e9e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	00001097          	auipc	ra,0x1
    80003ea8:	ca0080e7          	jalr	-864(ra) # 80004b44 <log_write>
      brelse(bp);
    80003eac:	8526                	mv	a0,s1
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	9ec080e7          	jalr	-1556(ra) # 8000389a <brelse>
      return iget(dev, inum);
    80003eb6:	0009059b          	sext.w	a1,s2
    80003eba:	8556                	mv	a0,s5
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	da2080e7          	jalr	-606(ra) # 80003c5e <iget>
    80003ec4:	74a2                	ld	s1,40(sp)
    80003ec6:	7902                	ld	s2,32(sp)
    80003ec8:	69e2                	ld	s3,24(sp)
    80003eca:	6a42                	ld	s4,16(sp)
    80003ecc:	6aa2                	ld	s5,8(sp)
    80003ece:	6b02                	ld	s6,0(sp)
    80003ed0:	bf5d                	j	80003e86 <ialloc+0x8c>

0000000080003ed2 <iupdate>:
{
    80003ed2:	1101                	addi	sp,sp,-32
    80003ed4:	ec06                	sd	ra,24(sp)
    80003ed6:	e822                	sd	s0,16(sp)
    80003ed8:	e426                	sd	s1,8(sp)
    80003eda:	e04a                	sd	s2,0(sp)
    80003edc:	1000                	addi	s0,sp,32
    80003ede:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ee0:	415c                	lw	a5,4(a0)
    80003ee2:	0047d79b          	srliw	a5,a5,0x4
    80003ee6:	00026597          	auipc	a1,0x26
    80003eea:	f125a583          	lw	a1,-238(a1) # 80029df8 <sb+0x18>
    80003eee:	9dbd                	addw	a1,a1,a5
    80003ef0:	4108                	lw	a0,0(a0)
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	878080e7          	jalr	-1928(ra) # 8000376a <bread>
    80003efa:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003efc:	05850793          	addi	a5,a0,88
    80003f00:	40d8                	lw	a4,4(s1)
    80003f02:	8b3d                	andi	a4,a4,15
    80003f04:	071a                	slli	a4,a4,0x6
    80003f06:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003f08:	04449703          	lh	a4,68(s1)
    80003f0c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003f10:	04649703          	lh	a4,70(s1)
    80003f14:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003f18:	04849703          	lh	a4,72(s1)
    80003f1c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003f20:	04a49703          	lh	a4,74(s1)
    80003f24:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003f28:	44f8                	lw	a4,76(s1)
    80003f2a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003f2c:	03400613          	li	a2,52
    80003f30:	05048593          	addi	a1,s1,80
    80003f34:	00c78513          	addi	a0,a5,12
    80003f38:	ffffd097          	auipc	ra,0xffffd
    80003f3c:	14e080e7          	jalr	334(ra) # 80001086 <memmove>
  log_write(bp);
    80003f40:	854a                	mv	a0,s2
    80003f42:	00001097          	auipc	ra,0x1
    80003f46:	c02080e7          	jalr	-1022(ra) # 80004b44 <log_write>
  brelse(bp);
    80003f4a:	854a                	mv	a0,s2
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	94e080e7          	jalr	-1714(ra) # 8000389a <brelse>
}
    80003f54:	60e2                	ld	ra,24(sp)
    80003f56:	6442                	ld	s0,16(sp)
    80003f58:	64a2                	ld	s1,8(sp)
    80003f5a:	6902                	ld	s2,0(sp)
    80003f5c:	6105                	addi	sp,sp,32
    80003f5e:	8082                	ret

0000000080003f60 <idup>:
{
    80003f60:	1101                	addi	sp,sp,-32
    80003f62:	ec06                	sd	ra,24(sp)
    80003f64:	e822                	sd	s0,16(sp)
    80003f66:	e426                	sd	s1,8(sp)
    80003f68:	1000                	addi	s0,sp,32
    80003f6a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f6c:	00026517          	auipc	a0,0x26
    80003f70:	e9450513          	addi	a0,a0,-364 # 80029e00 <itable>
    80003f74:	ffffd097          	auipc	ra,0xffffd
    80003f78:	fba080e7          	jalr	-70(ra) # 80000f2e <acquire>
  ip->ref++;
    80003f7c:	449c                	lw	a5,8(s1)
    80003f7e:	2785                	addiw	a5,a5,1
    80003f80:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f82:	00026517          	auipc	a0,0x26
    80003f86:	e7e50513          	addi	a0,a0,-386 # 80029e00 <itable>
    80003f8a:	ffffd097          	auipc	ra,0xffffd
    80003f8e:	058080e7          	jalr	88(ra) # 80000fe2 <release>
}
    80003f92:	8526                	mv	a0,s1
    80003f94:	60e2                	ld	ra,24(sp)
    80003f96:	6442                	ld	s0,16(sp)
    80003f98:	64a2                	ld	s1,8(sp)
    80003f9a:	6105                	addi	sp,sp,32
    80003f9c:	8082                	ret

0000000080003f9e <ilock>:
{
    80003f9e:	1101                	addi	sp,sp,-32
    80003fa0:	ec06                	sd	ra,24(sp)
    80003fa2:	e822                	sd	s0,16(sp)
    80003fa4:	e426                	sd	s1,8(sp)
    80003fa6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003fa8:	c10d                	beqz	a0,80003fca <ilock+0x2c>
    80003faa:	84aa                	mv	s1,a0
    80003fac:	451c                	lw	a5,8(a0)
    80003fae:	00f05e63          	blez	a5,80003fca <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003fb2:	0541                	addi	a0,a0,16
    80003fb4:	00001097          	auipc	ra,0x1
    80003fb8:	cae080e7          	jalr	-850(ra) # 80004c62 <acquiresleep>
  if(ip->valid == 0){
    80003fbc:	40bc                	lw	a5,64(s1)
    80003fbe:	cf99                	beqz	a5,80003fdc <ilock+0x3e>
}
    80003fc0:	60e2                	ld	ra,24(sp)
    80003fc2:	6442                	ld	s0,16(sp)
    80003fc4:	64a2                	ld	s1,8(sp)
    80003fc6:	6105                	addi	sp,sp,32
    80003fc8:	8082                	ret
    80003fca:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003fcc:	00004517          	auipc	a0,0x4
    80003fd0:	68c50513          	addi	a0,a0,1676 # 80008658 <__func__.1+0x650>
    80003fd4:	ffffc097          	auipc	ra,0xffffc
    80003fd8:	58c080e7          	jalr	1420(ra) # 80000560 <panic>
    80003fdc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fde:	40dc                	lw	a5,4(s1)
    80003fe0:	0047d79b          	srliw	a5,a5,0x4
    80003fe4:	00026597          	auipc	a1,0x26
    80003fe8:	e145a583          	lw	a1,-492(a1) # 80029df8 <sb+0x18>
    80003fec:	9dbd                	addw	a1,a1,a5
    80003fee:	4088                	lw	a0,0(s1)
    80003ff0:	fffff097          	auipc	ra,0xfffff
    80003ff4:	77a080e7          	jalr	1914(ra) # 8000376a <bread>
    80003ff8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ffa:	05850593          	addi	a1,a0,88
    80003ffe:	40dc                	lw	a5,4(s1)
    80004000:	8bbd                	andi	a5,a5,15
    80004002:	079a                	slli	a5,a5,0x6
    80004004:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004006:	00059783          	lh	a5,0(a1)
    8000400a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000400e:	00259783          	lh	a5,2(a1)
    80004012:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004016:	00459783          	lh	a5,4(a1)
    8000401a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000401e:	00659783          	lh	a5,6(a1)
    80004022:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004026:	459c                	lw	a5,8(a1)
    80004028:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000402a:	03400613          	li	a2,52
    8000402e:	05b1                	addi	a1,a1,12
    80004030:	05048513          	addi	a0,s1,80
    80004034:	ffffd097          	auipc	ra,0xffffd
    80004038:	052080e7          	jalr	82(ra) # 80001086 <memmove>
    brelse(bp);
    8000403c:	854a                	mv	a0,s2
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	85c080e7          	jalr	-1956(ra) # 8000389a <brelse>
    ip->valid = 1;
    80004046:	4785                	li	a5,1
    80004048:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000404a:	04449783          	lh	a5,68(s1)
    8000404e:	c399                	beqz	a5,80004054 <ilock+0xb6>
    80004050:	6902                	ld	s2,0(sp)
    80004052:	b7bd                	j	80003fc0 <ilock+0x22>
      panic("ilock: no type");
    80004054:	00004517          	auipc	a0,0x4
    80004058:	60c50513          	addi	a0,a0,1548 # 80008660 <__func__.1+0x658>
    8000405c:	ffffc097          	auipc	ra,0xffffc
    80004060:	504080e7          	jalr	1284(ra) # 80000560 <panic>

0000000080004064 <iunlock>:
{
    80004064:	1101                	addi	sp,sp,-32
    80004066:	ec06                	sd	ra,24(sp)
    80004068:	e822                	sd	s0,16(sp)
    8000406a:	e426                	sd	s1,8(sp)
    8000406c:	e04a                	sd	s2,0(sp)
    8000406e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004070:	c905                	beqz	a0,800040a0 <iunlock+0x3c>
    80004072:	84aa                	mv	s1,a0
    80004074:	01050913          	addi	s2,a0,16
    80004078:	854a                	mv	a0,s2
    8000407a:	00001097          	auipc	ra,0x1
    8000407e:	c82080e7          	jalr	-894(ra) # 80004cfc <holdingsleep>
    80004082:	cd19                	beqz	a0,800040a0 <iunlock+0x3c>
    80004084:	449c                	lw	a5,8(s1)
    80004086:	00f05d63          	blez	a5,800040a0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000408a:	854a                	mv	a0,s2
    8000408c:	00001097          	auipc	ra,0x1
    80004090:	c2c080e7          	jalr	-980(ra) # 80004cb8 <releasesleep>
}
    80004094:	60e2                	ld	ra,24(sp)
    80004096:	6442                	ld	s0,16(sp)
    80004098:	64a2                	ld	s1,8(sp)
    8000409a:	6902                	ld	s2,0(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret
    panic("iunlock");
    800040a0:	00004517          	auipc	a0,0x4
    800040a4:	5d050513          	addi	a0,a0,1488 # 80008670 <__func__.1+0x668>
    800040a8:	ffffc097          	auipc	ra,0xffffc
    800040ac:	4b8080e7          	jalr	1208(ra) # 80000560 <panic>

00000000800040b0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800040b0:	7179                	addi	sp,sp,-48
    800040b2:	f406                	sd	ra,40(sp)
    800040b4:	f022                	sd	s0,32(sp)
    800040b6:	ec26                	sd	s1,24(sp)
    800040b8:	e84a                	sd	s2,16(sp)
    800040ba:	e44e                	sd	s3,8(sp)
    800040bc:	1800                	addi	s0,sp,48
    800040be:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040c0:	05050493          	addi	s1,a0,80
    800040c4:	08050913          	addi	s2,a0,128
    800040c8:	a021                	j	800040d0 <itrunc+0x20>
    800040ca:	0491                	addi	s1,s1,4
    800040cc:	01248d63          	beq	s1,s2,800040e6 <itrunc+0x36>
    if(ip->addrs[i]){
    800040d0:	408c                	lw	a1,0(s1)
    800040d2:	dde5                	beqz	a1,800040ca <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800040d4:	0009a503          	lw	a0,0(s3)
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	8d6080e7          	jalr	-1834(ra) # 800039ae <bfree>
      ip->addrs[i] = 0;
    800040e0:	0004a023          	sw	zero,0(s1)
    800040e4:	b7dd                	j	800040ca <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800040e6:	0809a583          	lw	a1,128(s3)
    800040ea:	ed99                	bnez	a1,80004108 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800040ec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800040f0:	854e                	mv	a0,s3
    800040f2:	00000097          	auipc	ra,0x0
    800040f6:	de0080e7          	jalr	-544(ra) # 80003ed2 <iupdate>
}
    800040fa:	70a2                	ld	ra,40(sp)
    800040fc:	7402                	ld	s0,32(sp)
    800040fe:	64e2                	ld	s1,24(sp)
    80004100:	6942                	ld	s2,16(sp)
    80004102:	69a2                	ld	s3,8(sp)
    80004104:	6145                	addi	sp,sp,48
    80004106:	8082                	ret
    80004108:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000410a:	0009a503          	lw	a0,0(s3)
    8000410e:	fffff097          	auipc	ra,0xfffff
    80004112:	65c080e7          	jalr	1628(ra) # 8000376a <bread>
    80004116:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004118:	05850493          	addi	s1,a0,88
    8000411c:	45850913          	addi	s2,a0,1112
    80004120:	a021                	j	80004128 <itrunc+0x78>
    80004122:	0491                	addi	s1,s1,4
    80004124:	01248b63          	beq	s1,s2,8000413a <itrunc+0x8a>
      if(a[j])
    80004128:	408c                	lw	a1,0(s1)
    8000412a:	dde5                	beqz	a1,80004122 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    8000412c:	0009a503          	lw	a0,0(s3)
    80004130:	00000097          	auipc	ra,0x0
    80004134:	87e080e7          	jalr	-1922(ra) # 800039ae <bfree>
    80004138:	b7ed                	j	80004122 <itrunc+0x72>
    brelse(bp);
    8000413a:	8552                	mv	a0,s4
    8000413c:	fffff097          	auipc	ra,0xfffff
    80004140:	75e080e7          	jalr	1886(ra) # 8000389a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004144:	0809a583          	lw	a1,128(s3)
    80004148:	0009a503          	lw	a0,0(s3)
    8000414c:	00000097          	auipc	ra,0x0
    80004150:	862080e7          	jalr	-1950(ra) # 800039ae <bfree>
    ip->addrs[NDIRECT] = 0;
    80004154:	0809a023          	sw	zero,128(s3)
    80004158:	6a02                	ld	s4,0(sp)
    8000415a:	bf49                	j	800040ec <itrunc+0x3c>

000000008000415c <iput>:
{
    8000415c:	1101                	addi	sp,sp,-32
    8000415e:	ec06                	sd	ra,24(sp)
    80004160:	e822                	sd	s0,16(sp)
    80004162:	e426                	sd	s1,8(sp)
    80004164:	1000                	addi	s0,sp,32
    80004166:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004168:	00026517          	auipc	a0,0x26
    8000416c:	c9850513          	addi	a0,a0,-872 # 80029e00 <itable>
    80004170:	ffffd097          	auipc	ra,0xffffd
    80004174:	dbe080e7          	jalr	-578(ra) # 80000f2e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004178:	4498                	lw	a4,8(s1)
    8000417a:	4785                	li	a5,1
    8000417c:	02f70263          	beq	a4,a5,800041a0 <iput+0x44>
  ip->ref--;
    80004180:	449c                	lw	a5,8(s1)
    80004182:	37fd                	addiw	a5,a5,-1
    80004184:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004186:	00026517          	auipc	a0,0x26
    8000418a:	c7a50513          	addi	a0,a0,-902 # 80029e00 <itable>
    8000418e:	ffffd097          	auipc	ra,0xffffd
    80004192:	e54080e7          	jalr	-428(ra) # 80000fe2 <release>
}
    80004196:	60e2                	ld	ra,24(sp)
    80004198:	6442                	ld	s0,16(sp)
    8000419a:	64a2                	ld	s1,8(sp)
    8000419c:	6105                	addi	sp,sp,32
    8000419e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800041a0:	40bc                	lw	a5,64(s1)
    800041a2:	dff9                	beqz	a5,80004180 <iput+0x24>
    800041a4:	04a49783          	lh	a5,74(s1)
    800041a8:	ffe1                	bnez	a5,80004180 <iput+0x24>
    800041aa:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800041ac:	01048913          	addi	s2,s1,16
    800041b0:	854a                	mv	a0,s2
    800041b2:	00001097          	auipc	ra,0x1
    800041b6:	ab0080e7          	jalr	-1360(ra) # 80004c62 <acquiresleep>
    release(&itable.lock);
    800041ba:	00026517          	auipc	a0,0x26
    800041be:	c4650513          	addi	a0,a0,-954 # 80029e00 <itable>
    800041c2:	ffffd097          	auipc	ra,0xffffd
    800041c6:	e20080e7          	jalr	-480(ra) # 80000fe2 <release>
    itrunc(ip);
    800041ca:	8526                	mv	a0,s1
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	ee4080e7          	jalr	-284(ra) # 800040b0 <itrunc>
    ip->type = 0;
    800041d4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800041d8:	8526                	mv	a0,s1
    800041da:	00000097          	auipc	ra,0x0
    800041de:	cf8080e7          	jalr	-776(ra) # 80003ed2 <iupdate>
    ip->valid = 0;
    800041e2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800041e6:	854a                	mv	a0,s2
    800041e8:	00001097          	auipc	ra,0x1
    800041ec:	ad0080e7          	jalr	-1328(ra) # 80004cb8 <releasesleep>
    acquire(&itable.lock);
    800041f0:	00026517          	auipc	a0,0x26
    800041f4:	c1050513          	addi	a0,a0,-1008 # 80029e00 <itable>
    800041f8:	ffffd097          	auipc	ra,0xffffd
    800041fc:	d36080e7          	jalr	-714(ra) # 80000f2e <acquire>
    80004200:	6902                	ld	s2,0(sp)
    80004202:	bfbd                	j	80004180 <iput+0x24>

0000000080004204 <iunlockput>:
{
    80004204:	1101                	addi	sp,sp,-32
    80004206:	ec06                	sd	ra,24(sp)
    80004208:	e822                	sd	s0,16(sp)
    8000420a:	e426                	sd	s1,8(sp)
    8000420c:	1000                	addi	s0,sp,32
    8000420e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004210:	00000097          	auipc	ra,0x0
    80004214:	e54080e7          	jalr	-428(ra) # 80004064 <iunlock>
  iput(ip);
    80004218:	8526                	mv	a0,s1
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	f42080e7          	jalr	-190(ra) # 8000415c <iput>
}
    80004222:	60e2                	ld	ra,24(sp)
    80004224:	6442                	ld	s0,16(sp)
    80004226:	64a2                	ld	s1,8(sp)
    80004228:	6105                	addi	sp,sp,32
    8000422a:	8082                	ret

000000008000422c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000422c:	1141                	addi	sp,sp,-16
    8000422e:	e422                	sd	s0,8(sp)
    80004230:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004232:	411c                	lw	a5,0(a0)
    80004234:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004236:	415c                	lw	a5,4(a0)
    80004238:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000423a:	04451783          	lh	a5,68(a0)
    8000423e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004242:	04a51783          	lh	a5,74(a0)
    80004246:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000424a:	04c56783          	lwu	a5,76(a0)
    8000424e:	e99c                	sd	a5,16(a1)
}
    80004250:	6422                	ld	s0,8(sp)
    80004252:	0141                	addi	sp,sp,16
    80004254:	8082                	ret

0000000080004256 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004256:	457c                	lw	a5,76(a0)
    80004258:	10d7e563          	bltu	a5,a3,80004362 <readi+0x10c>
{
    8000425c:	7159                	addi	sp,sp,-112
    8000425e:	f486                	sd	ra,104(sp)
    80004260:	f0a2                	sd	s0,96(sp)
    80004262:	eca6                	sd	s1,88(sp)
    80004264:	e0d2                	sd	s4,64(sp)
    80004266:	fc56                	sd	s5,56(sp)
    80004268:	f85a                	sd	s6,48(sp)
    8000426a:	f45e                	sd	s7,40(sp)
    8000426c:	1880                	addi	s0,sp,112
    8000426e:	8b2a                	mv	s6,a0
    80004270:	8bae                	mv	s7,a1
    80004272:	8a32                	mv	s4,a2
    80004274:	84b6                	mv	s1,a3
    80004276:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004278:	9f35                	addw	a4,a4,a3
    return 0;
    8000427a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000427c:	0cd76a63          	bltu	a4,a3,80004350 <readi+0xfa>
    80004280:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004282:	00e7f463          	bgeu	a5,a4,8000428a <readi+0x34>
    n = ip->size - off;
    80004286:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000428a:	0a0a8963          	beqz	s5,8000433c <readi+0xe6>
    8000428e:	e8ca                	sd	s2,80(sp)
    80004290:	f062                	sd	s8,32(sp)
    80004292:	ec66                	sd	s9,24(sp)
    80004294:	e86a                	sd	s10,16(sp)
    80004296:	e46e                	sd	s11,8(sp)
    80004298:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000429a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000429e:	5c7d                	li	s8,-1
    800042a0:	a82d                	j	800042da <readi+0x84>
    800042a2:	020d1d93          	slli	s11,s10,0x20
    800042a6:	020ddd93          	srli	s11,s11,0x20
    800042aa:	05890613          	addi	a2,s2,88
    800042ae:	86ee                	mv	a3,s11
    800042b0:	963a                	add	a2,a2,a4
    800042b2:	85d2                	mv	a1,s4
    800042b4:	855e                	mv	a0,s7
    800042b6:	ffffe097          	auipc	ra,0xffffe
    800042ba:	7a2080e7          	jalr	1954(ra) # 80002a58 <either_copyout>
    800042be:	05850d63          	beq	a0,s8,80004318 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042c2:	854a                	mv	a0,s2
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	5d6080e7          	jalr	1494(ra) # 8000389a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042cc:	013d09bb          	addw	s3,s10,s3
    800042d0:	009d04bb          	addw	s1,s10,s1
    800042d4:	9a6e                	add	s4,s4,s11
    800042d6:	0559fd63          	bgeu	s3,s5,80004330 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    800042da:	00a4d59b          	srliw	a1,s1,0xa
    800042de:	855a                	mv	a0,s6
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	88e080e7          	jalr	-1906(ra) # 80003b6e <bmap>
    800042e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042ec:	c9b1                	beqz	a1,80004340 <readi+0xea>
    bp = bread(ip->dev, addr);
    800042ee:	000b2503          	lw	a0,0(s6)
    800042f2:	fffff097          	auipc	ra,0xfffff
    800042f6:	478080e7          	jalr	1144(ra) # 8000376a <bread>
    800042fa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042fc:	3ff4f713          	andi	a4,s1,1023
    80004300:	40ec87bb          	subw	a5,s9,a4
    80004304:	413a86bb          	subw	a3,s5,s3
    80004308:	8d3e                	mv	s10,a5
    8000430a:	2781                	sext.w	a5,a5
    8000430c:	0006861b          	sext.w	a2,a3
    80004310:	f8f679e3          	bgeu	a2,a5,800042a2 <readi+0x4c>
    80004314:	8d36                	mv	s10,a3
    80004316:	b771                	j	800042a2 <readi+0x4c>
      brelse(bp);
    80004318:	854a                	mv	a0,s2
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	580080e7          	jalr	1408(ra) # 8000389a <brelse>
      tot = -1;
    80004322:	59fd                	li	s3,-1
      break;
    80004324:	6946                	ld	s2,80(sp)
    80004326:	7c02                	ld	s8,32(sp)
    80004328:	6ce2                	ld	s9,24(sp)
    8000432a:	6d42                	ld	s10,16(sp)
    8000432c:	6da2                	ld	s11,8(sp)
    8000432e:	a831                	j	8000434a <readi+0xf4>
    80004330:	6946                	ld	s2,80(sp)
    80004332:	7c02                	ld	s8,32(sp)
    80004334:	6ce2                	ld	s9,24(sp)
    80004336:	6d42                	ld	s10,16(sp)
    80004338:	6da2                	ld	s11,8(sp)
    8000433a:	a801                	j	8000434a <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000433c:	89d6                	mv	s3,s5
    8000433e:	a031                	j	8000434a <readi+0xf4>
    80004340:	6946                	ld	s2,80(sp)
    80004342:	7c02                	ld	s8,32(sp)
    80004344:	6ce2                	ld	s9,24(sp)
    80004346:	6d42                	ld	s10,16(sp)
    80004348:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000434a:	0009851b          	sext.w	a0,s3
    8000434e:	69a6                	ld	s3,72(sp)
}
    80004350:	70a6                	ld	ra,104(sp)
    80004352:	7406                	ld	s0,96(sp)
    80004354:	64e6                	ld	s1,88(sp)
    80004356:	6a06                	ld	s4,64(sp)
    80004358:	7ae2                	ld	s5,56(sp)
    8000435a:	7b42                	ld	s6,48(sp)
    8000435c:	7ba2                	ld	s7,40(sp)
    8000435e:	6165                	addi	sp,sp,112
    80004360:	8082                	ret
    return 0;
    80004362:	4501                	li	a0,0
}
    80004364:	8082                	ret

0000000080004366 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004366:	457c                	lw	a5,76(a0)
    80004368:	10d7ee63          	bltu	a5,a3,80004484 <writei+0x11e>
{
    8000436c:	7159                	addi	sp,sp,-112
    8000436e:	f486                	sd	ra,104(sp)
    80004370:	f0a2                	sd	s0,96(sp)
    80004372:	e8ca                	sd	s2,80(sp)
    80004374:	e0d2                	sd	s4,64(sp)
    80004376:	fc56                	sd	s5,56(sp)
    80004378:	f85a                	sd	s6,48(sp)
    8000437a:	f45e                	sd	s7,40(sp)
    8000437c:	1880                	addi	s0,sp,112
    8000437e:	8aaa                	mv	s5,a0
    80004380:	8bae                	mv	s7,a1
    80004382:	8a32                	mv	s4,a2
    80004384:	8936                	mv	s2,a3
    80004386:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004388:	00e687bb          	addw	a5,a3,a4
    8000438c:	0ed7ee63          	bltu	a5,a3,80004488 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004390:	00043737          	lui	a4,0x43
    80004394:	0ef76c63          	bltu	a4,a5,8000448c <writei+0x126>
    80004398:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000439a:	0c0b0d63          	beqz	s6,80004474 <writei+0x10e>
    8000439e:	eca6                	sd	s1,88(sp)
    800043a0:	f062                	sd	s8,32(sp)
    800043a2:	ec66                	sd	s9,24(sp)
    800043a4:	e86a                	sd	s10,16(sp)
    800043a6:	e46e                	sd	s11,8(sp)
    800043a8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800043aa:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800043ae:	5c7d                	li	s8,-1
    800043b0:	a091                	j	800043f4 <writei+0x8e>
    800043b2:	020d1d93          	slli	s11,s10,0x20
    800043b6:	020ddd93          	srli	s11,s11,0x20
    800043ba:	05848513          	addi	a0,s1,88
    800043be:	86ee                	mv	a3,s11
    800043c0:	8652                	mv	a2,s4
    800043c2:	85de                	mv	a1,s7
    800043c4:	953a                	add	a0,a0,a4
    800043c6:	ffffe097          	auipc	ra,0xffffe
    800043ca:	6e8080e7          	jalr	1768(ra) # 80002aae <either_copyin>
    800043ce:	07850263          	beq	a0,s8,80004432 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800043d2:	8526                	mv	a0,s1
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	770080e7          	jalr	1904(ra) # 80004b44 <log_write>
    brelse(bp);
    800043dc:	8526                	mv	a0,s1
    800043de:	fffff097          	auipc	ra,0xfffff
    800043e2:	4bc080e7          	jalr	1212(ra) # 8000389a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043e6:	013d09bb          	addw	s3,s10,s3
    800043ea:	012d093b          	addw	s2,s10,s2
    800043ee:	9a6e                	add	s4,s4,s11
    800043f0:	0569f663          	bgeu	s3,s6,8000443c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800043f4:	00a9559b          	srliw	a1,s2,0xa
    800043f8:	8556                	mv	a0,s5
    800043fa:	fffff097          	auipc	ra,0xfffff
    800043fe:	774080e7          	jalr	1908(ra) # 80003b6e <bmap>
    80004402:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004406:	c99d                	beqz	a1,8000443c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004408:	000aa503          	lw	a0,0(s5)
    8000440c:	fffff097          	auipc	ra,0xfffff
    80004410:	35e080e7          	jalr	862(ra) # 8000376a <bread>
    80004414:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004416:	3ff97713          	andi	a4,s2,1023
    8000441a:	40ec87bb          	subw	a5,s9,a4
    8000441e:	413b06bb          	subw	a3,s6,s3
    80004422:	8d3e                	mv	s10,a5
    80004424:	2781                	sext.w	a5,a5
    80004426:	0006861b          	sext.w	a2,a3
    8000442a:	f8f674e3          	bgeu	a2,a5,800043b2 <writei+0x4c>
    8000442e:	8d36                	mv	s10,a3
    80004430:	b749                	j	800043b2 <writei+0x4c>
      brelse(bp);
    80004432:	8526                	mv	a0,s1
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	466080e7          	jalr	1126(ra) # 8000389a <brelse>
  }

  if(off > ip->size)
    8000443c:	04caa783          	lw	a5,76(s5)
    80004440:	0327fc63          	bgeu	a5,s2,80004478 <writei+0x112>
    ip->size = off;
    80004444:	052aa623          	sw	s2,76(s5)
    80004448:	64e6                	ld	s1,88(sp)
    8000444a:	7c02                	ld	s8,32(sp)
    8000444c:	6ce2                	ld	s9,24(sp)
    8000444e:	6d42                	ld	s10,16(sp)
    80004450:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004452:	8556                	mv	a0,s5
    80004454:	00000097          	auipc	ra,0x0
    80004458:	a7e080e7          	jalr	-1410(ra) # 80003ed2 <iupdate>

  return tot;
    8000445c:	0009851b          	sext.w	a0,s3
    80004460:	69a6                	ld	s3,72(sp)
}
    80004462:	70a6                	ld	ra,104(sp)
    80004464:	7406                	ld	s0,96(sp)
    80004466:	6946                	ld	s2,80(sp)
    80004468:	6a06                	ld	s4,64(sp)
    8000446a:	7ae2                	ld	s5,56(sp)
    8000446c:	7b42                	ld	s6,48(sp)
    8000446e:	7ba2                	ld	s7,40(sp)
    80004470:	6165                	addi	sp,sp,112
    80004472:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004474:	89da                	mv	s3,s6
    80004476:	bff1                	j	80004452 <writei+0xec>
    80004478:	64e6                	ld	s1,88(sp)
    8000447a:	7c02                	ld	s8,32(sp)
    8000447c:	6ce2                	ld	s9,24(sp)
    8000447e:	6d42                	ld	s10,16(sp)
    80004480:	6da2                	ld	s11,8(sp)
    80004482:	bfc1                	j	80004452 <writei+0xec>
    return -1;
    80004484:	557d                	li	a0,-1
}
    80004486:	8082                	ret
    return -1;
    80004488:	557d                	li	a0,-1
    8000448a:	bfe1                	j	80004462 <writei+0xfc>
    return -1;
    8000448c:	557d                	li	a0,-1
    8000448e:	bfd1                	j	80004462 <writei+0xfc>

0000000080004490 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004490:	1141                	addi	sp,sp,-16
    80004492:	e406                	sd	ra,8(sp)
    80004494:	e022                	sd	s0,0(sp)
    80004496:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004498:	4639                	li	a2,14
    8000449a:	ffffd097          	auipc	ra,0xffffd
    8000449e:	c60080e7          	jalr	-928(ra) # 800010fa <strncmp>
}
    800044a2:	60a2                	ld	ra,8(sp)
    800044a4:	6402                	ld	s0,0(sp)
    800044a6:	0141                	addi	sp,sp,16
    800044a8:	8082                	ret

00000000800044aa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800044aa:	7139                	addi	sp,sp,-64
    800044ac:	fc06                	sd	ra,56(sp)
    800044ae:	f822                	sd	s0,48(sp)
    800044b0:	f426                	sd	s1,40(sp)
    800044b2:	f04a                	sd	s2,32(sp)
    800044b4:	ec4e                	sd	s3,24(sp)
    800044b6:	e852                	sd	s4,16(sp)
    800044b8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800044ba:	04451703          	lh	a4,68(a0)
    800044be:	4785                	li	a5,1
    800044c0:	00f71a63          	bne	a4,a5,800044d4 <dirlookup+0x2a>
    800044c4:	892a                	mv	s2,a0
    800044c6:	89ae                	mv	s3,a1
    800044c8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ca:	457c                	lw	a5,76(a0)
    800044cc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800044ce:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044d0:	e79d                	bnez	a5,800044fe <dirlookup+0x54>
    800044d2:	a8a5                	j	8000454a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044d4:	00004517          	auipc	a0,0x4
    800044d8:	1a450513          	addi	a0,a0,420 # 80008678 <__func__.1+0x670>
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	084080e7          	jalr	132(ra) # 80000560 <panic>
      panic("dirlookup read");
    800044e4:	00004517          	auipc	a0,0x4
    800044e8:	1ac50513          	addi	a0,a0,428 # 80008690 <__func__.1+0x688>
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	074080e7          	jalr	116(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044f4:	24c1                	addiw	s1,s1,16
    800044f6:	04c92783          	lw	a5,76(s2)
    800044fa:	04f4f763          	bgeu	s1,a5,80004548 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044fe:	4741                	li	a4,16
    80004500:	86a6                	mv	a3,s1
    80004502:	fc040613          	addi	a2,s0,-64
    80004506:	4581                	li	a1,0
    80004508:	854a                	mv	a0,s2
    8000450a:	00000097          	auipc	ra,0x0
    8000450e:	d4c080e7          	jalr	-692(ra) # 80004256 <readi>
    80004512:	47c1                	li	a5,16
    80004514:	fcf518e3          	bne	a0,a5,800044e4 <dirlookup+0x3a>
    if(de.inum == 0)
    80004518:	fc045783          	lhu	a5,-64(s0)
    8000451c:	dfe1                	beqz	a5,800044f4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000451e:	fc240593          	addi	a1,s0,-62
    80004522:	854e                	mv	a0,s3
    80004524:	00000097          	auipc	ra,0x0
    80004528:	f6c080e7          	jalr	-148(ra) # 80004490 <namecmp>
    8000452c:	f561                	bnez	a0,800044f4 <dirlookup+0x4a>
      if(poff)
    8000452e:	000a0463          	beqz	s4,80004536 <dirlookup+0x8c>
        *poff = off;
    80004532:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004536:	fc045583          	lhu	a1,-64(s0)
    8000453a:	00092503          	lw	a0,0(s2)
    8000453e:	fffff097          	auipc	ra,0xfffff
    80004542:	720080e7          	jalr	1824(ra) # 80003c5e <iget>
    80004546:	a011                	j	8000454a <dirlookup+0xa0>
  return 0;
    80004548:	4501                	li	a0,0
}
    8000454a:	70e2                	ld	ra,56(sp)
    8000454c:	7442                	ld	s0,48(sp)
    8000454e:	74a2                	ld	s1,40(sp)
    80004550:	7902                	ld	s2,32(sp)
    80004552:	69e2                	ld	s3,24(sp)
    80004554:	6a42                	ld	s4,16(sp)
    80004556:	6121                	addi	sp,sp,64
    80004558:	8082                	ret

000000008000455a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000455a:	711d                	addi	sp,sp,-96
    8000455c:	ec86                	sd	ra,88(sp)
    8000455e:	e8a2                	sd	s0,80(sp)
    80004560:	e4a6                	sd	s1,72(sp)
    80004562:	e0ca                	sd	s2,64(sp)
    80004564:	fc4e                	sd	s3,56(sp)
    80004566:	f852                	sd	s4,48(sp)
    80004568:	f456                	sd	s5,40(sp)
    8000456a:	f05a                	sd	s6,32(sp)
    8000456c:	ec5e                	sd	s7,24(sp)
    8000456e:	e862                	sd	s8,16(sp)
    80004570:	e466                	sd	s9,8(sp)
    80004572:	1080                	addi	s0,sp,96
    80004574:	84aa                	mv	s1,a0
    80004576:	8b2e                	mv	s6,a1
    80004578:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000457a:	00054703          	lbu	a4,0(a0)
    8000457e:	02f00793          	li	a5,47
    80004582:	02f70263          	beq	a4,a5,800045a6 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004586:	ffffe097          	auipc	ra,0xffffe
    8000458a:	918080e7          	jalr	-1768(ra) # 80001e9e <myproc>
    8000458e:	15053503          	ld	a0,336(a0)
    80004592:	00000097          	auipc	ra,0x0
    80004596:	9ce080e7          	jalr	-1586(ra) # 80003f60 <idup>
    8000459a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000459c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800045a0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800045a2:	4b85                	li	s7,1
    800045a4:	a875                	j	80004660 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800045a6:	4585                	li	a1,1
    800045a8:	4505                	li	a0,1
    800045aa:	fffff097          	auipc	ra,0xfffff
    800045ae:	6b4080e7          	jalr	1716(ra) # 80003c5e <iget>
    800045b2:	8a2a                	mv	s4,a0
    800045b4:	b7e5                	j	8000459c <namex+0x42>
      iunlockput(ip);
    800045b6:	8552                	mv	a0,s4
    800045b8:	00000097          	auipc	ra,0x0
    800045bc:	c4c080e7          	jalr	-948(ra) # 80004204 <iunlockput>
      return 0;
    800045c0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800045c2:	8552                	mv	a0,s4
    800045c4:	60e6                	ld	ra,88(sp)
    800045c6:	6446                	ld	s0,80(sp)
    800045c8:	64a6                	ld	s1,72(sp)
    800045ca:	6906                	ld	s2,64(sp)
    800045cc:	79e2                	ld	s3,56(sp)
    800045ce:	7a42                	ld	s4,48(sp)
    800045d0:	7aa2                	ld	s5,40(sp)
    800045d2:	7b02                	ld	s6,32(sp)
    800045d4:	6be2                	ld	s7,24(sp)
    800045d6:	6c42                	ld	s8,16(sp)
    800045d8:	6ca2                	ld	s9,8(sp)
    800045da:	6125                	addi	sp,sp,96
    800045dc:	8082                	ret
      iunlock(ip);
    800045de:	8552                	mv	a0,s4
    800045e0:	00000097          	auipc	ra,0x0
    800045e4:	a84080e7          	jalr	-1404(ra) # 80004064 <iunlock>
      return ip;
    800045e8:	bfe9                	j	800045c2 <namex+0x68>
      iunlockput(ip);
    800045ea:	8552                	mv	a0,s4
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	c18080e7          	jalr	-1000(ra) # 80004204 <iunlockput>
      return 0;
    800045f4:	8a4e                	mv	s4,s3
    800045f6:	b7f1                	j	800045c2 <namex+0x68>
  len = path - s;
    800045f8:	40998633          	sub	a2,s3,s1
    800045fc:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004600:	099c5863          	bge	s8,s9,80004690 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004604:	4639                	li	a2,14
    80004606:	85a6                	mv	a1,s1
    80004608:	8556                	mv	a0,s5
    8000460a:	ffffd097          	auipc	ra,0xffffd
    8000460e:	a7c080e7          	jalr	-1412(ra) # 80001086 <memmove>
    80004612:	84ce                	mv	s1,s3
  while(*path == '/')
    80004614:	0004c783          	lbu	a5,0(s1)
    80004618:	01279763          	bne	a5,s2,80004626 <namex+0xcc>
    path++;
    8000461c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000461e:	0004c783          	lbu	a5,0(s1)
    80004622:	ff278de3          	beq	a5,s2,8000461c <namex+0xc2>
    ilock(ip);
    80004626:	8552                	mv	a0,s4
    80004628:	00000097          	auipc	ra,0x0
    8000462c:	976080e7          	jalr	-1674(ra) # 80003f9e <ilock>
    if(ip->type != T_DIR){
    80004630:	044a1783          	lh	a5,68(s4)
    80004634:	f97791e3          	bne	a5,s7,800045b6 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004638:	000b0563          	beqz	s6,80004642 <namex+0xe8>
    8000463c:	0004c783          	lbu	a5,0(s1)
    80004640:	dfd9                	beqz	a5,800045de <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004642:	4601                	li	a2,0
    80004644:	85d6                	mv	a1,s5
    80004646:	8552                	mv	a0,s4
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	e62080e7          	jalr	-414(ra) # 800044aa <dirlookup>
    80004650:	89aa                	mv	s3,a0
    80004652:	dd41                	beqz	a0,800045ea <namex+0x90>
    iunlockput(ip);
    80004654:	8552                	mv	a0,s4
    80004656:	00000097          	auipc	ra,0x0
    8000465a:	bae080e7          	jalr	-1106(ra) # 80004204 <iunlockput>
    ip = next;
    8000465e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004660:	0004c783          	lbu	a5,0(s1)
    80004664:	01279763          	bne	a5,s2,80004672 <namex+0x118>
    path++;
    80004668:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000466a:	0004c783          	lbu	a5,0(s1)
    8000466e:	ff278de3          	beq	a5,s2,80004668 <namex+0x10e>
  if(*path == 0)
    80004672:	cb9d                	beqz	a5,800046a8 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004674:	0004c783          	lbu	a5,0(s1)
    80004678:	89a6                	mv	s3,s1
  len = path - s;
    8000467a:	4c81                	li	s9,0
    8000467c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000467e:	01278963          	beq	a5,s2,80004690 <namex+0x136>
    80004682:	dbbd                	beqz	a5,800045f8 <namex+0x9e>
    path++;
    80004684:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004686:	0009c783          	lbu	a5,0(s3)
    8000468a:	ff279ce3          	bne	a5,s2,80004682 <namex+0x128>
    8000468e:	b7ad                	j	800045f8 <namex+0x9e>
    memmove(name, s, len);
    80004690:	2601                	sext.w	a2,a2
    80004692:	85a6                	mv	a1,s1
    80004694:	8556                	mv	a0,s5
    80004696:	ffffd097          	auipc	ra,0xffffd
    8000469a:	9f0080e7          	jalr	-1552(ra) # 80001086 <memmove>
    name[len] = 0;
    8000469e:	9cd6                	add	s9,s9,s5
    800046a0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800046a4:	84ce                	mv	s1,s3
    800046a6:	b7bd                	j	80004614 <namex+0xba>
  if(nameiparent){
    800046a8:	f00b0de3          	beqz	s6,800045c2 <namex+0x68>
    iput(ip);
    800046ac:	8552                	mv	a0,s4
    800046ae:	00000097          	auipc	ra,0x0
    800046b2:	aae080e7          	jalr	-1362(ra) # 8000415c <iput>
    return 0;
    800046b6:	4a01                	li	s4,0
    800046b8:	b729                	j	800045c2 <namex+0x68>

00000000800046ba <dirlink>:
{
    800046ba:	7139                	addi	sp,sp,-64
    800046bc:	fc06                	sd	ra,56(sp)
    800046be:	f822                	sd	s0,48(sp)
    800046c0:	f04a                	sd	s2,32(sp)
    800046c2:	ec4e                	sd	s3,24(sp)
    800046c4:	e852                	sd	s4,16(sp)
    800046c6:	0080                	addi	s0,sp,64
    800046c8:	892a                	mv	s2,a0
    800046ca:	8a2e                	mv	s4,a1
    800046cc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046ce:	4601                	li	a2,0
    800046d0:	00000097          	auipc	ra,0x0
    800046d4:	dda080e7          	jalr	-550(ra) # 800044aa <dirlookup>
    800046d8:	ed25                	bnez	a0,80004750 <dirlink+0x96>
    800046da:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046dc:	04c92483          	lw	s1,76(s2)
    800046e0:	c49d                	beqz	s1,8000470e <dirlink+0x54>
    800046e2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046e4:	4741                	li	a4,16
    800046e6:	86a6                	mv	a3,s1
    800046e8:	fc040613          	addi	a2,s0,-64
    800046ec:	4581                	li	a1,0
    800046ee:	854a                	mv	a0,s2
    800046f0:	00000097          	auipc	ra,0x0
    800046f4:	b66080e7          	jalr	-1178(ra) # 80004256 <readi>
    800046f8:	47c1                	li	a5,16
    800046fa:	06f51163          	bne	a0,a5,8000475c <dirlink+0xa2>
    if(de.inum == 0)
    800046fe:	fc045783          	lhu	a5,-64(s0)
    80004702:	c791                	beqz	a5,8000470e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004704:	24c1                	addiw	s1,s1,16
    80004706:	04c92783          	lw	a5,76(s2)
    8000470a:	fcf4ede3          	bltu	s1,a5,800046e4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000470e:	4639                	li	a2,14
    80004710:	85d2                	mv	a1,s4
    80004712:	fc240513          	addi	a0,s0,-62
    80004716:	ffffd097          	auipc	ra,0xffffd
    8000471a:	a1a080e7          	jalr	-1510(ra) # 80001130 <strncpy>
  de.inum = inum;
    8000471e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004722:	4741                	li	a4,16
    80004724:	86a6                	mv	a3,s1
    80004726:	fc040613          	addi	a2,s0,-64
    8000472a:	4581                	li	a1,0
    8000472c:	854a                	mv	a0,s2
    8000472e:	00000097          	auipc	ra,0x0
    80004732:	c38080e7          	jalr	-968(ra) # 80004366 <writei>
    80004736:	1541                	addi	a0,a0,-16
    80004738:	00a03533          	snez	a0,a0
    8000473c:	40a00533          	neg	a0,a0
    80004740:	74a2                	ld	s1,40(sp)
}
    80004742:	70e2                	ld	ra,56(sp)
    80004744:	7442                	ld	s0,48(sp)
    80004746:	7902                	ld	s2,32(sp)
    80004748:	69e2                	ld	s3,24(sp)
    8000474a:	6a42                	ld	s4,16(sp)
    8000474c:	6121                	addi	sp,sp,64
    8000474e:	8082                	ret
    iput(ip);
    80004750:	00000097          	auipc	ra,0x0
    80004754:	a0c080e7          	jalr	-1524(ra) # 8000415c <iput>
    return -1;
    80004758:	557d                	li	a0,-1
    8000475a:	b7e5                	j	80004742 <dirlink+0x88>
      panic("dirlink read");
    8000475c:	00004517          	auipc	a0,0x4
    80004760:	f4450513          	addi	a0,a0,-188 # 800086a0 <__func__.1+0x698>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	dfc080e7          	jalr	-516(ra) # 80000560 <panic>

000000008000476c <namei>:

struct inode*
namei(char *path)
{
    8000476c:	1101                	addi	sp,sp,-32
    8000476e:	ec06                	sd	ra,24(sp)
    80004770:	e822                	sd	s0,16(sp)
    80004772:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004774:	fe040613          	addi	a2,s0,-32
    80004778:	4581                	li	a1,0
    8000477a:	00000097          	auipc	ra,0x0
    8000477e:	de0080e7          	jalr	-544(ra) # 8000455a <namex>
}
    80004782:	60e2                	ld	ra,24(sp)
    80004784:	6442                	ld	s0,16(sp)
    80004786:	6105                	addi	sp,sp,32
    80004788:	8082                	ret

000000008000478a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000478a:	1141                	addi	sp,sp,-16
    8000478c:	e406                	sd	ra,8(sp)
    8000478e:	e022                	sd	s0,0(sp)
    80004790:	0800                	addi	s0,sp,16
    80004792:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004794:	4585                	li	a1,1
    80004796:	00000097          	auipc	ra,0x0
    8000479a:	dc4080e7          	jalr	-572(ra) # 8000455a <namex>
}
    8000479e:	60a2                	ld	ra,8(sp)
    800047a0:	6402                	ld	s0,0(sp)
    800047a2:	0141                	addi	sp,sp,16
    800047a4:	8082                	ret

00000000800047a6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800047a6:	1101                	addi	sp,sp,-32
    800047a8:	ec06                	sd	ra,24(sp)
    800047aa:	e822                	sd	s0,16(sp)
    800047ac:	e426                	sd	s1,8(sp)
    800047ae:	e04a                	sd	s2,0(sp)
    800047b0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800047b2:	00027917          	auipc	s2,0x27
    800047b6:	0f690913          	addi	s2,s2,246 # 8002b8a8 <log>
    800047ba:	01892583          	lw	a1,24(s2)
    800047be:	02892503          	lw	a0,40(s2)
    800047c2:	fffff097          	auipc	ra,0xfffff
    800047c6:	fa8080e7          	jalr	-88(ra) # 8000376a <bread>
    800047ca:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800047cc:	02c92603          	lw	a2,44(s2)
    800047d0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800047d2:	00c05f63          	blez	a2,800047f0 <write_head+0x4a>
    800047d6:	00027717          	auipc	a4,0x27
    800047da:	10270713          	addi	a4,a4,258 # 8002b8d8 <log+0x30>
    800047de:	87aa                	mv	a5,a0
    800047e0:	060a                	slli	a2,a2,0x2
    800047e2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800047e4:	4314                	lw	a3,0(a4)
    800047e6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800047e8:	0711                	addi	a4,a4,4
    800047ea:	0791                	addi	a5,a5,4
    800047ec:	fec79ce3          	bne	a5,a2,800047e4 <write_head+0x3e>
  }
  bwrite(buf);
    800047f0:	8526                	mv	a0,s1
    800047f2:	fffff097          	auipc	ra,0xfffff
    800047f6:	06a080e7          	jalr	106(ra) # 8000385c <bwrite>
  brelse(buf);
    800047fa:	8526                	mv	a0,s1
    800047fc:	fffff097          	auipc	ra,0xfffff
    80004800:	09e080e7          	jalr	158(ra) # 8000389a <brelse>
}
    80004804:	60e2                	ld	ra,24(sp)
    80004806:	6442                	ld	s0,16(sp)
    80004808:	64a2                	ld	s1,8(sp)
    8000480a:	6902                	ld	s2,0(sp)
    8000480c:	6105                	addi	sp,sp,32
    8000480e:	8082                	ret

0000000080004810 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004810:	00027797          	auipc	a5,0x27
    80004814:	0c47a783          	lw	a5,196(a5) # 8002b8d4 <log+0x2c>
    80004818:	0af05d63          	blez	a5,800048d2 <install_trans+0xc2>
{
    8000481c:	7139                	addi	sp,sp,-64
    8000481e:	fc06                	sd	ra,56(sp)
    80004820:	f822                	sd	s0,48(sp)
    80004822:	f426                	sd	s1,40(sp)
    80004824:	f04a                	sd	s2,32(sp)
    80004826:	ec4e                	sd	s3,24(sp)
    80004828:	e852                	sd	s4,16(sp)
    8000482a:	e456                	sd	s5,8(sp)
    8000482c:	e05a                	sd	s6,0(sp)
    8000482e:	0080                	addi	s0,sp,64
    80004830:	8b2a                	mv	s6,a0
    80004832:	00027a97          	auipc	s5,0x27
    80004836:	0a6a8a93          	addi	s5,s5,166 # 8002b8d8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000483a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000483c:	00027997          	auipc	s3,0x27
    80004840:	06c98993          	addi	s3,s3,108 # 8002b8a8 <log>
    80004844:	a00d                	j	80004866 <install_trans+0x56>
    brelse(lbuf);
    80004846:	854a                	mv	a0,s2
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	052080e7          	jalr	82(ra) # 8000389a <brelse>
    brelse(dbuf);
    80004850:	8526                	mv	a0,s1
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	048080e7          	jalr	72(ra) # 8000389a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000485a:	2a05                	addiw	s4,s4,1
    8000485c:	0a91                	addi	s5,s5,4
    8000485e:	02c9a783          	lw	a5,44(s3)
    80004862:	04fa5e63          	bge	s4,a5,800048be <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004866:	0189a583          	lw	a1,24(s3)
    8000486a:	014585bb          	addw	a1,a1,s4
    8000486e:	2585                	addiw	a1,a1,1
    80004870:	0289a503          	lw	a0,40(s3)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	ef6080e7          	jalr	-266(ra) # 8000376a <bread>
    8000487c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000487e:	000aa583          	lw	a1,0(s5)
    80004882:	0289a503          	lw	a0,40(s3)
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	ee4080e7          	jalr	-284(ra) # 8000376a <bread>
    8000488e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004890:	40000613          	li	a2,1024
    80004894:	05890593          	addi	a1,s2,88
    80004898:	05850513          	addi	a0,a0,88
    8000489c:	ffffc097          	auipc	ra,0xffffc
    800048a0:	7ea080e7          	jalr	2026(ra) # 80001086 <memmove>
    bwrite(dbuf);  // write dst to disk
    800048a4:	8526                	mv	a0,s1
    800048a6:	fffff097          	auipc	ra,0xfffff
    800048aa:	fb6080e7          	jalr	-74(ra) # 8000385c <bwrite>
    if(recovering == 0)
    800048ae:	f80b1ce3          	bnez	s6,80004846 <install_trans+0x36>
      bunpin(dbuf);
    800048b2:	8526                	mv	a0,s1
    800048b4:	fffff097          	auipc	ra,0xfffff
    800048b8:	0be080e7          	jalr	190(ra) # 80003972 <bunpin>
    800048bc:	b769                	j	80004846 <install_trans+0x36>
}
    800048be:	70e2                	ld	ra,56(sp)
    800048c0:	7442                	ld	s0,48(sp)
    800048c2:	74a2                	ld	s1,40(sp)
    800048c4:	7902                	ld	s2,32(sp)
    800048c6:	69e2                	ld	s3,24(sp)
    800048c8:	6a42                	ld	s4,16(sp)
    800048ca:	6aa2                	ld	s5,8(sp)
    800048cc:	6b02                	ld	s6,0(sp)
    800048ce:	6121                	addi	sp,sp,64
    800048d0:	8082                	ret
    800048d2:	8082                	ret

00000000800048d4 <initlog>:
{
    800048d4:	7179                	addi	sp,sp,-48
    800048d6:	f406                	sd	ra,40(sp)
    800048d8:	f022                	sd	s0,32(sp)
    800048da:	ec26                	sd	s1,24(sp)
    800048dc:	e84a                	sd	s2,16(sp)
    800048de:	e44e                	sd	s3,8(sp)
    800048e0:	1800                	addi	s0,sp,48
    800048e2:	892a                	mv	s2,a0
    800048e4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800048e6:	00027497          	auipc	s1,0x27
    800048ea:	fc248493          	addi	s1,s1,-62 # 8002b8a8 <log>
    800048ee:	00004597          	auipc	a1,0x4
    800048f2:	dc258593          	addi	a1,a1,-574 # 800086b0 <__func__.1+0x6a8>
    800048f6:	8526                	mv	a0,s1
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	5a6080e7          	jalr	1446(ra) # 80000e9e <initlock>
  log.start = sb->logstart;
    80004900:	0149a583          	lw	a1,20(s3)
    80004904:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004906:	0109a783          	lw	a5,16(s3)
    8000490a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000490c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004910:	854a                	mv	a0,s2
    80004912:	fffff097          	auipc	ra,0xfffff
    80004916:	e58080e7          	jalr	-424(ra) # 8000376a <bread>
  log.lh.n = lh->n;
    8000491a:	4d30                	lw	a2,88(a0)
    8000491c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000491e:	00c05f63          	blez	a2,8000493c <initlog+0x68>
    80004922:	87aa                	mv	a5,a0
    80004924:	00027717          	auipc	a4,0x27
    80004928:	fb470713          	addi	a4,a4,-76 # 8002b8d8 <log+0x30>
    8000492c:	060a                	slli	a2,a2,0x2
    8000492e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004930:	4ff4                	lw	a3,92(a5)
    80004932:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004934:	0791                	addi	a5,a5,4
    80004936:	0711                	addi	a4,a4,4
    80004938:	fec79ce3          	bne	a5,a2,80004930 <initlog+0x5c>
  brelse(buf);
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	f5e080e7          	jalr	-162(ra) # 8000389a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004944:	4505                	li	a0,1
    80004946:	00000097          	auipc	ra,0x0
    8000494a:	eca080e7          	jalr	-310(ra) # 80004810 <install_trans>
  log.lh.n = 0;
    8000494e:	00027797          	auipc	a5,0x27
    80004952:	f807a323          	sw	zero,-122(a5) # 8002b8d4 <log+0x2c>
  write_head(); // clear the log
    80004956:	00000097          	auipc	ra,0x0
    8000495a:	e50080e7          	jalr	-432(ra) # 800047a6 <write_head>
}
    8000495e:	70a2                	ld	ra,40(sp)
    80004960:	7402                	ld	s0,32(sp)
    80004962:	64e2                	ld	s1,24(sp)
    80004964:	6942                	ld	s2,16(sp)
    80004966:	69a2                	ld	s3,8(sp)
    80004968:	6145                	addi	sp,sp,48
    8000496a:	8082                	ret

000000008000496c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000496c:	1101                	addi	sp,sp,-32
    8000496e:	ec06                	sd	ra,24(sp)
    80004970:	e822                	sd	s0,16(sp)
    80004972:	e426                	sd	s1,8(sp)
    80004974:	e04a                	sd	s2,0(sp)
    80004976:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004978:	00027517          	auipc	a0,0x27
    8000497c:	f3050513          	addi	a0,a0,-208 # 8002b8a8 <log>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	5ae080e7          	jalr	1454(ra) # 80000f2e <acquire>
  while(1){
    if(log.committing){
    80004988:	00027497          	auipc	s1,0x27
    8000498c:	f2048493          	addi	s1,s1,-224 # 8002b8a8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004990:	4979                	li	s2,30
    80004992:	a039                	j	800049a0 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004994:	85a6                	mv	a1,s1
    80004996:	8526                	mv	a0,s1
    80004998:	ffffe097          	auipc	ra,0xffffe
    8000499c:	cb8080e7          	jalr	-840(ra) # 80002650 <sleep>
    if(log.committing){
    800049a0:	50dc                	lw	a5,36(s1)
    800049a2:	fbed                	bnez	a5,80004994 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800049a4:	5098                	lw	a4,32(s1)
    800049a6:	2705                	addiw	a4,a4,1
    800049a8:	0027179b          	slliw	a5,a4,0x2
    800049ac:	9fb9                	addw	a5,a5,a4
    800049ae:	0017979b          	slliw	a5,a5,0x1
    800049b2:	54d4                	lw	a3,44(s1)
    800049b4:	9fb5                	addw	a5,a5,a3
    800049b6:	00f95963          	bge	s2,a5,800049c8 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800049ba:	85a6                	mv	a1,s1
    800049bc:	8526                	mv	a0,s1
    800049be:	ffffe097          	auipc	ra,0xffffe
    800049c2:	c92080e7          	jalr	-878(ra) # 80002650 <sleep>
    800049c6:	bfe9                	j	800049a0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800049c8:	00027517          	auipc	a0,0x27
    800049cc:	ee050513          	addi	a0,a0,-288 # 8002b8a8 <log>
    800049d0:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	610080e7          	jalr	1552(ra) # 80000fe2 <release>
      break;
    }
  }
}
    800049da:	60e2                	ld	ra,24(sp)
    800049dc:	6442                	ld	s0,16(sp)
    800049de:	64a2                	ld	s1,8(sp)
    800049e0:	6902                	ld	s2,0(sp)
    800049e2:	6105                	addi	sp,sp,32
    800049e4:	8082                	ret

00000000800049e6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800049e6:	7139                	addi	sp,sp,-64
    800049e8:	fc06                	sd	ra,56(sp)
    800049ea:	f822                	sd	s0,48(sp)
    800049ec:	f426                	sd	s1,40(sp)
    800049ee:	f04a                	sd	s2,32(sp)
    800049f0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049f2:	00027497          	auipc	s1,0x27
    800049f6:	eb648493          	addi	s1,s1,-330 # 8002b8a8 <log>
    800049fa:	8526                	mv	a0,s1
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	532080e7          	jalr	1330(ra) # 80000f2e <acquire>
  log.outstanding -= 1;
    80004a04:	509c                	lw	a5,32(s1)
    80004a06:	37fd                	addiw	a5,a5,-1
    80004a08:	0007891b          	sext.w	s2,a5
    80004a0c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004a0e:	50dc                	lw	a5,36(s1)
    80004a10:	e7b9                	bnez	a5,80004a5e <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004a12:	06091163          	bnez	s2,80004a74 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004a16:	00027497          	auipc	s1,0x27
    80004a1a:	e9248493          	addi	s1,s1,-366 # 8002b8a8 <log>
    80004a1e:	4785                	li	a5,1
    80004a20:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004a22:	8526                	mv	a0,s1
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	5be080e7          	jalr	1470(ra) # 80000fe2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004a2c:	54dc                	lw	a5,44(s1)
    80004a2e:	06f04763          	bgtz	a5,80004a9c <end_op+0xb6>
    acquire(&log.lock);
    80004a32:	00027497          	auipc	s1,0x27
    80004a36:	e7648493          	addi	s1,s1,-394 # 8002b8a8 <log>
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	4f2080e7          	jalr	1266(ra) # 80000f2e <acquire>
    log.committing = 0;
    80004a44:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004a48:	8526                	mv	a0,s1
    80004a4a:	ffffe097          	auipc	ra,0xffffe
    80004a4e:	c6a080e7          	jalr	-918(ra) # 800026b4 <wakeup>
    release(&log.lock);
    80004a52:	8526                	mv	a0,s1
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	58e080e7          	jalr	1422(ra) # 80000fe2 <release>
}
    80004a5c:	a815                	j	80004a90 <end_op+0xaa>
    80004a5e:	ec4e                	sd	s3,24(sp)
    80004a60:	e852                	sd	s4,16(sp)
    80004a62:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004a64:	00004517          	auipc	a0,0x4
    80004a68:	c5450513          	addi	a0,a0,-940 # 800086b8 <__func__.1+0x6b0>
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	af4080e7          	jalr	-1292(ra) # 80000560 <panic>
    wakeup(&log);
    80004a74:	00027497          	auipc	s1,0x27
    80004a78:	e3448493          	addi	s1,s1,-460 # 8002b8a8 <log>
    80004a7c:	8526                	mv	a0,s1
    80004a7e:	ffffe097          	auipc	ra,0xffffe
    80004a82:	c36080e7          	jalr	-970(ra) # 800026b4 <wakeup>
  release(&log.lock);
    80004a86:	8526                	mv	a0,s1
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	55a080e7          	jalr	1370(ra) # 80000fe2 <release>
}
    80004a90:	70e2                	ld	ra,56(sp)
    80004a92:	7442                	ld	s0,48(sp)
    80004a94:	74a2                	ld	s1,40(sp)
    80004a96:	7902                	ld	s2,32(sp)
    80004a98:	6121                	addi	sp,sp,64
    80004a9a:	8082                	ret
    80004a9c:	ec4e                	sd	s3,24(sp)
    80004a9e:	e852                	sd	s4,16(sp)
    80004aa0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004aa2:	00027a97          	auipc	s5,0x27
    80004aa6:	e36a8a93          	addi	s5,s5,-458 # 8002b8d8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004aaa:	00027a17          	auipc	s4,0x27
    80004aae:	dfea0a13          	addi	s4,s4,-514 # 8002b8a8 <log>
    80004ab2:	018a2583          	lw	a1,24(s4)
    80004ab6:	012585bb          	addw	a1,a1,s2
    80004aba:	2585                	addiw	a1,a1,1
    80004abc:	028a2503          	lw	a0,40(s4)
    80004ac0:	fffff097          	auipc	ra,0xfffff
    80004ac4:	caa080e7          	jalr	-854(ra) # 8000376a <bread>
    80004ac8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004aca:	000aa583          	lw	a1,0(s5)
    80004ace:	028a2503          	lw	a0,40(s4)
    80004ad2:	fffff097          	auipc	ra,0xfffff
    80004ad6:	c98080e7          	jalr	-872(ra) # 8000376a <bread>
    80004ada:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004adc:	40000613          	li	a2,1024
    80004ae0:	05850593          	addi	a1,a0,88
    80004ae4:	05848513          	addi	a0,s1,88
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	59e080e7          	jalr	1438(ra) # 80001086 <memmove>
    bwrite(to);  // write the log
    80004af0:	8526                	mv	a0,s1
    80004af2:	fffff097          	auipc	ra,0xfffff
    80004af6:	d6a080e7          	jalr	-662(ra) # 8000385c <bwrite>
    brelse(from);
    80004afa:	854e                	mv	a0,s3
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	d9e080e7          	jalr	-610(ra) # 8000389a <brelse>
    brelse(to);
    80004b04:	8526                	mv	a0,s1
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	d94080e7          	jalr	-620(ra) # 8000389a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b0e:	2905                	addiw	s2,s2,1
    80004b10:	0a91                	addi	s5,s5,4
    80004b12:	02ca2783          	lw	a5,44(s4)
    80004b16:	f8f94ee3          	blt	s2,a5,80004ab2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004b1a:	00000097          	auipc	ra,0x0
    80004b1e:	c8c080e7          	jalr	-884(ra) # 800047a6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004b22:	4501                	li	a0,0
    80004b24:	00000097          	auipc	ra,0x0
    80004b28:	cec080e7          	jalr	-788(ra) # 80004810 <install_trans>
    log.lh.n = 0;
    80004b2c:	00027797          	auipc	a5,0x27
    80004b30:	da07a423          	sw	zero,-600(a5) # 8002b8d4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004b34:	00000097          	auipc	ra,0x0
    80004b38:	c72080e7          	jalr	-910(ra) # 800047a6 <write_head>
    80004b3c:	69e2                	ld	s3,24(sp)
    80004b3e:	6a42                	ld	s4,16(sp)
    80004b40:	6aa2                	ld	s5,8(sp)
    80004b42:	bdc5                	j	80004a32 <end_op+0x4c>

0000000080004b44 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b44:	1101                	addi	sp,sp,-32
    80004b46:	ec06                	sd	ra,24(sp)
    80004b48:	e822                	sd	s0,16(sp)
    80004b4a:	e426                	sd	s1,8(sp)
    80004b4c:	e04a                	sd	s2,0(sp)
    80004b4e:	1000                	addi	s0,sp,32
    80004b50:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b52:	00027917          	auipc	s2,0x27
    80004b56:	d5690913          	addi	s2,s2,-682 # 8002b8a8 <log>
    80004b5a:	854a                	mv	a0,s2
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	3d2080e7          	jalr	978(ra) # 80000f2e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b64:	02c92603          	lw	a2,44(s2)
    80004b68:	47f5                	li	a5,29
    80004b6a:	06c7c563          	blt	a5,a2,80004bd4 <log_write+0x90>
    80004b6e:	00027797          	auipc	a5,0x27
    80004b72:	d567a783          	lw	a5,-682(a5) # 8002b8c4 <log+0x1c>
    80004b76:	37fd                	addiw	a5,a5,-1
    80004b78:	04f65e63          	bge	a2,a5,80004bd4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b7c:	00027797          	auipc	a5,0x27
    80004b80:	d4c7a783          	lw	a5,-692(a5) # 8002b8c8 <log+0x20>
    80004b84:	06f05063          	blez	a5,80004be4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b88:	4781                	li	a5,0
    80004b8a:	06c05563          	blez	a2,80004bf4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b8e:	44cc                	lw	a1,12(s1)
    80004b90:	00027717          	auipc	a4,0x27
    80004b94:	d4870713          	addi	a4,a4,-696 # 8002b8d8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b98:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b9a:	4314                	lw	a3,0(a4)
    80004b9c:	04b68c63          	beq	a3,a1,80004bf4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004ba0:	2785                	addiw	a5,a5,1
    80004ba2:	0711                	addi	a4,a4,4
    80004ba4:	fef61be3          	bne	a2,a5,80004b9a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ba8:	0621                	addi	a2,a2,8
    80004baa:	060a                	slli	a2,a2,0x2
    80004bac:	00027797          	auipc	a5,0x27
    80004bb0:	cfc78793          	addi	a5,a5,-772 # 8002b8a8 <log>
    80004bb4:	97b2                	add	a5,a5,a2
    80004bb6:	44d8                	lw	a4,12(s1)
    80004bb8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004bba:	8526                	mv	a0,s1
    80004bbc:	fffff097          	auipc	ra,0xfffff
    80004bc0:	d7a080e7          	jalr	-646(ra) # 80003936 <bpin>
    log.lh.n++;
    80004bc4:	00027717          	auipc	a4,0x27
    80004bc8:	ce470713          	addi	a4,a4,-796 # 8002b8a8 <log>
    80004bcc:	575c                	lw	a5,44(a4)
    80004bce:	2785                	addiw	a5,a5,1
    80004bd0:	d75c                	sw	a5,44(a4)
    80004bd2:	a82d                	j	80004c0c <log_write+0xc8>
    panic("too big a transaction");
    80004bd4:	00004517          	auipc	a0,0x4
    80004bd8:	af450513          	addi	a0,a0,-1292 # 800086c8 <__func__.1+0x6c0>
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	984080e7          	jalr	-1660(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004be4:	00004517          	auipc	a0,0x4
    80004be8:	afc50513          	addi	a0,a0,-1284 # 800086e0 <__func__.1+0x6d8>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	974080e7          	jalr	-1676(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004bf4:	00878693          	addi	a3,a5,8
    80004bf8:	068a                	slli	a3,a3,0x2
    80004bfa:	00027717          	auipc	a4,0x27
    80004bfe:	cae70713          	addi	a4,a4,-850 # 8002b8a8 <log>
    80004c02:	9736                	add	a4,a4,a3
    80004c04:	44d4                	lw	a3,12(s1)
    80004c06:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004c08:	faf609e3          	beq	a2,a5,80004bba <log_write+0x76>
  }
  release(&log.lock);
    80004c0c:	00027517          	auipc	a0,0x27
    80004c10:	c9c50513          	addi	a0,a0,-868 # 8002b8a8 <log>
    80004c14:	ffffc097          	auipc	ra,0xffffc
    80004c18:	3ce080e7          	jalr	974(ra) # 80000fe2 <release>
}
    80004c1c:	60e2                	ld	ra,24(sp)
    80004c1e:	6442                	ld	s0,16(sp)
    80004c20:	64a2                	ld	s1,8(sp)
    80004c22:	6902                	ld	s2,0(sp)
    80004c24:	6105                	addi	sp,sp,32
    80004c26:	8082                	ret

0000000080004c28 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c28:	1101                	addi	sp,sp,-32
    80004c2a:	ec06                	sd	ra,24(sp)
    80004c2c:	e822                	sd	s0,16(sp)
    80004c2e:	e426                	sd	s1,8(sp)
    80004c30:	e04a                	sd	s2,0(sp)
    80004c32:	1000                	addi	s0,sp,32
    80004c34:	84aa                	mv	s1,a0
    80004c36:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c38:	00004597          	auipc	a1,0x4
    80004c3c:	ac858593          	addi	a1,a1,-1336 # 80008700 <__func__.1+0x6f8>
    80004c40:	0521                	addi	a0,a0,8
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	25c080e7          	jalr	604(ra) # 80000e9e <initlock>
  lk->name = name;
    80004c4a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c4e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c52:	0204a423          	sw	zero,40(s1)
}
    80004c56:	60e2                	ld	ra,24(sp)
    80004c58:	6442                	ld	s0,16(sp)
    80004c5a:	64a2                	ld	s1,8(sp)
    80004c5c:	6902                	ld	s2,0(sp)
    80004c5e:	6105                	addi	sp,sp,32
    80004c60:	8082                	ret

0000000080004c62 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c62:	1101                	addi	sp,sp,-32
    80004c64:	ec06                	sd	ra,24(sp)
    80004c66:	e822                	sd	s0,16(sp)
    80004c68:	e426                	sd	s1,8(sp)
    80004c6a:	e04a                	sd	s2,0(sp)
    80004c6c:	1000                	addi	s0,sp,32
    80004c6e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c70:	00850913          	addi	s2,a0,8
    80004c74:	854a                	mv	a0,s2
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	2b8080e7          	jalr	696(ra) # 80000f2e <acquire>
  while (lk->locked) {
    80004c7e:	409c                	lw	a5,0(s1)
    80004c80:	cb89                	beqz	a5,80004c92 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c82:	85ca                	mv	a1,s2
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffe097          	auipc	ra,0xffffe
    80004c8a:	9ca080e7          	jalr	-1590(ra) # 80002650 <sleep>
  while (lk->locked) {
    80004c8e:	409c                	lw	a5,0(s1)
    80004c90:	fbed                	bnez	a5,80004c82 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c92:	4785                	li	a5,1
    80004c94:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c96:	ffffd097          	auipc	ra,0xffffd
    80004c9a:	208080e7          	jalr	520(ra) # 80001e9e <myproc>
    80004c9e:	591c                	lw	a5,48(a0)
    80004ca0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ca2:	854a                	mv	a0,s2
    80004ca4:	ffffc097          	auipc	ra,0xffffc
    80004ca8:	33e080e7          	jalr	830(ra) # 80000fe2 <release>
}
    80004cac:	60e2                	ld	ra,24(sp)
    80004cae:	6442                	ld	s0,16(sp)
    80004cb0:	64a2                	ld	s1,8(sp)
    80004cb2:	6902                	ld	s2,0(sp)
    80004cb4:	6105                	addi	sp,sp,32
    80004cb6:	8082                	ret

0000000080004cb8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004cb8:	1101                	addi	sp,sp,-32
    80004cba:	ec06                	sd	ra,24(sp)
    80004cbc:	e822                	sd	s0,16(sp)
    80004cbe:	e426                	sd	s1,8(sp)
    80004cc0:	e04a                	sd	s2,0(sp)
    80004cc2:	1000                	addi	s0,sp,32
    80004cc4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cc6:	00850913          	addi	s2,a0,8
    80004cca:	854a                	mv	a0,s2
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	262080e7          	jalr	610(ra) # 80000f2e <acquire>
  lk->locked = 0;
    80004cd4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004cd8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	ffffe097          	auipc	ra,0xffffe
    80004ce2:	9d6080e7          	jalr	-1578(ra) # 800026b4 <wakeup>
  release(&lk->lk);
    80004ce6:	854a                	mv	a0,s2
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	2fa080e7          	jalr	762(ra) # 80000fe2 <release>
}
    80004cf0:	60e2                	ld	ra,24(sp)
    80004cf2:	6442                	ld	s0,16(sp)
    80004cf4:	64a2                	ld	s1,8(sp)
    80004cf6:	6902                	ld	s2,0(sp)
    80004cf8:	6105                	addi	sp,sp,32
    80004cfa:	8082                	ret

0000000080004cfc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004cfc:	7179                	addi	sp,sp,-48
    80004cfe:	f406                	sd	ra,40(sp)
    80004d00:	f022                	sd	s0,32(sp)
    80004d02:	ec26                	sd	s1,24(sp)
    80004d04:	e84a                	sd	s2,16(sp)
    80004d06:	1800                	addi	s0,sp,48
    80004d08:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004d0a:	00850913          	addi	s2,a0,8
    80004d0e:	854a                	mv	a0,s2
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	21e080e7          	jalr	542(ra) # 80000f2e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d18:	409c                	lw	a5,0(s1)
    80004d1a:	ef91                	bnez	a5,80004d36 <holdingsleep+0x3a>
    80004d1c:	4481                	li	s1,0
  release(&lk->lk);
    80004d1e:	854a                	mv	a0,s2
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	2c2080e7          	jalr	706(ra) # 80000fe2 <release>
  return r;
}
    80004d28:	8526                	mv	a0,s1
    80004d2a:	70a2                	ld	ra,40(sp)
    80004d2c:	7402                	ld	s0,32(sp)
    80004d2e:	64e2                	ld	s1,24(sp)
    80004d30:	6942                	ld	s2,16(sp)
    80004d32:	6145                	addi	sp,sp,48
    80004d34:	8082                	ret
    80004d36:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d38:	0284a983          	lw	s3,40(s1)
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	162080e7          	jalr	354(ra) # 80001e9e <myproc>
    80004d44:	5904                	lw	s1,48(a0)
    80004d46:	413484b3          	sub	s1,s1,s3
    80004d4a:	0014b493          	seqz	s1,s1
    80004d4e:	69a2                	ld	s3,8(sp)
    80004d50:	b7f9                	j	80004d1e <holdingsleep+0x22>

0000000080004d52 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d52:	1141                	addi	sp,sp,-16
    80004d54:	e406                	sd	ra,8(sp)
    80004d56:	e022                	sd	s0,0(sp)
    80004d58:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d5a:	00004597          	auipc	a1,0x4
    80004d5e:	9b658593          	addi	a1,a1,-1610 # 80008710 <__func__.1+0x708>
    80004d62:	00027517          	auipc	a0,0x27
    80004d66:	c8e50513          	addi	a0,a0,-882 # 8002b9f0 <ftable>
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	134080e7          	jalr	308(ra) # 80000e9e <initlock>
}
    80004d72:	60a2                	ld	ra,8(sp)
    80004d74:	6402                	ld	s0,0(sp)
    80004d76:	0141                	addi	sp,sp,16
    80004d78:	8082                	ret

0000000080004d7a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d7a:	1101                	addi	sp,sp,-32
    80004d7c:	ec06                	sd	ra,24(sp)
    80004d7e:	e822                	sd	s0,16(sp)
    80004d80:	e426                	sd	s1,8(sp)
    80004d82:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d84:	00027517          	auipc	a0,0x27
    80004d88:	c6c50513          	addi	a0,a0,-916 # 8002b9f0 <ftable>
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	1a2080e7          	jalr	418(ra) # 80000f2e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d94:	00027497          	auipc	s1,0x27
    80004d98:	c7448493          	addi	s1,s1,-908 # 8002ba08 <ftable+0x18>
    80004d9c:	00028717          	auipc	a4,0x28
    80004da0:	c0c70713          	addi	a4,a4,-1012 # 8002c9a8 <disk>
    if(f->ref == 0){
    80004da4:	40dc                	lw	a5,4(s1)
    80004da6:	cf99                	beqz	a5,80004dc4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004da8:	02848493          	addi	s1,s1,40
    80004dac:	fee49ce3          	bne	s1,a4,80004da4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004db0:	00027517          	auipc	a0,0x27
    80004db4:	c4050513          	addi	a0,a0,-960 # 8002b9f0 <ftable>
    80004db8:	ffffc097          	auipc	ra,0xffffc
    80004dbc:	22a080e7          	jalr	554(ra) # 80000fe2 <release>
  return 0;
    80004dc0:	4481                	li	s1,0
    80004dc2:	a819                	j	80004dd8 <filealloc+0x5e>
      f->ref = 1;
    80004dc4:	4785                	li	a5,1
    80004dc6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004dc8:	00027517          	auipc	a0,0x27
    80004dcc:	c2850513          	addi	a0,a0,-984 # 8002b9f0 <ftable>
    80004dd0:	ffffc097          	auipc	ra,0xffffc
    80004dd4:	212080e7          	jalr	530(ra) # 80000fe2 <release>
}
    80004dd8:	8526                	mv	a0,s1
    80004dda:	60e2                	ld	ra,24(sp)
    80004ddc:	6442                	ld	s0,16(sp)
    80004dde:	64a2                	ld	s1,8(sp)
    80004de0:	6105                	addi	sp,sp,32
    80004de2:	8082                	ret

0000000080004de4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004de4:	1101                	addi	sp,sp,-32
    80004de6:	ec06                	sd	ra,24(sp)
    80004de8:	e822                	sd	s0,16(sp)
    80004dea:	e426                	sd	s1,8(sp)
    80004dec:	1000                	addi	s0,sp,32
    80004dee:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004df0:	00027517          	auipc	a0,0x27
    80004df4:	c0050513          	addi	a0,a0,-1024 # 8002b9f0 <ftable>
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	136080e7          	jalr	310(ra) # 80000f2e <acquire>
  if(f->ref < 1)
    80004e00:	40dc                	lw	a5,4(s1)
    80004e02:	02f05263          	blez	a5,80004e26 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004e06:	2785                	addiw	a5,a5,1
    80004e08:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004e0a:	00027517          	auipc	a0,0x27
    80004e0e:	be650513          	addi	a0,a0,-1050 # 8002b9f0 <ftable>
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	1d0080e7          	jalr	464(ra) # 80000fe2 <release>
  return f;
}
    80004e1a:	8526                	mv	a0,s1
    80004e1c:	60e2                	ld	ra,24(sp)
    80004e1e:	6442                	ld	s0,16(sp)
    80004e20:	64a2                	ld	s1,8(sp)
    80004e22:	6105                	addi	sp,sp,32
    80004e24:	8082                	ret
    panic("filedup");
    80004e26:	00004517          	auipc	a0,0x4
    80004e2a:	8f250513          	addi	a0,a0,-1806 # 80008718 <__func__.1+0x710>
    80004e2e:	ffffb097          	auipc	ra,0xffffb
    80004e32:	732080e7          	jalr	1842(ra) # 80000560 <panic>

0000000080004e36 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004e36:	7139                	addi	sp,sp,-64
    80004e38:	fc06                	sd	ra,56(sp)
    80004e3a:	f822                	sd	s0,48(sp)
    80004e3c:	f426                	sd	s1,40(sp)
    80004e3e:	0080                	addi	s0,sp,64
    80004e40:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e42:	00027517          	auipc	a0,0x27
    80004e46:	bae50513          	addi	a0,a0,-1106 # 8002b9f0 <ftable>
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	0e4080e7          	jalr	228(ra) # 80000f2e <acquire>
  if(f->ref < 1)
    80004e52:	40dc                	lw	a5,4(s1)
    80004e54:	04f05c63          	blez	a5,80004eac <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004e58:	37fd                	addiw	a5,a5,-1
    80004e5a:	0007871b          	sext.w	a4,a5
    80004e5e:	c0dc                	sw	a5,4(s1)
    80004e60:	06e04263          	bgtz	a4,80004ec4 <fileclose+0x8e>
    80004e64:	f04a                	sd	s2,32(sp)
    80004e66:	ec4e                	sd	s3,24(sp)
    80004e68:	e852                	sd	s4,16(sp)
    80004e6a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e6c:	0004a903          	lw	s2,0(s1)
    80004e70:	0094ca83          	lbu	s5,9(s1)
    80004e74:	0104ba03          	ld	s4,16(s1)
    80004e78:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e7c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e80:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e84:	00027517          	auipc	a0,0x27
    80004e88:	b6c50513          	addi	a0,a0,-1172 # 8002b9f0 <ftable>
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	156080e7          	jalr	342(ra) # 80000fe2 <release>

  if(ff.type == FD_PIPE){
    80004e94:	4785                	li	a5,1
    80004e96:	04f90463          	beq	s2,a5,80004ede <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e9a:	3979                	addiw	s2,s2,-2
    80004e9c:	4785                	li	a5,1
    80004e9e:	0527fb63          	bgeu	a5,s2,80004ef4 <fileclose+0xbe>
    80004ea2:	7902                	ld	s2,32(sp)
    80004ea4:	69e2                	ld	s3,24(sp)
    80004ea6:	6a42                	ld	s4,16(sp)
    80004ea8:	6aa2                	ld	s5,8(sp)
    80004eaa:	a02d                	j	80004ed4 <fileclose+0x9e>
    80004eac:	f04a                	sd	s2,32(sp)
    80004eae:	ec4e                	sd	s3,24(sp)
    80004eb0:	e852                	sd	s4,16(sp)
    80004eb2:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004eb4:	00004517          	auipc	a0,0x4
    80004eb8:	86c50513          	addi	a0,a0,-1940 # 80008720 <__func__.1+0x718>
    80004ebc:	ffffb097          	auipc	ra,0xffffb
    80004ec0:	6a4080e7          	jalr	1700(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004ec4:	00027517          	auipc	a0,0x27
    80004ec8:	b2c50513          	addi	a0,a0,-1236 # 8002b9f0 <ftable>
    80004ecc:	ffffc097          	auipc	ra,0xffffc
    80004ed0:	116080e7          	jalr	278(ra) # 80000fe2 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004ed4:	70e2                	ld	ra,56(sp)
    80004ed6:	7442                	ld	s0,48(sp)
    80004ed8:	74a2                	ld	s1,40(sp)
    80004eda:	6121                	addi	sp,sp,64
    80004edc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ede:	85d6                	mv	a1,s5
    80004ee0:	8552                	mv	a0,s4
    80004ee2:	00000097          	auipc	ra,0x0
    80004ee6:	3a2080e7          	jalr	930(ra) # 80005284 <pipeclose>
    80004eea:	7902                	ld	s2,32(sp)
    80004eec:	69e2                	ld	s3,24(sp)
    80004eee:	6a42                	ld	s4,16(sp)
    80004ef0:	6aa2                	ld	s5,8(sp)
    80004ef2:	b7cd                	j	80004ed4 <fileclose+0x9e>
    begin_op();
    80004ef4:	00000097          	auipc	ra,0x0
    80004ef8:	a78080e7          	jalr	-1416(ra) # 8000496c <begin_op>
    iput(ff.ip);
    80004efc:	854e                	mv	a0,s3
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	25e080e7          	jalr	606(ra) # 8000415c <iput>
    end_op();
    80004f06:	00000097          	auipc	ra,0x0
    80004f0a:	ae0080e7          	jalr	-1312(ra) # 800049e6 <end_op>
    80004f0e:	7902                	ld	s2,32(sp)
    80004f10:	69e2                	ld	s3,24(sp)
    80004f12:	6a42                	ld	s4,16(sp)
    80004f14:	6aa2                	ld	s5,8(sp)
    80004f16:	bf7d                	j	80004ed4 <fileclose+0x9e>

0000000080004f18 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004f18:	715d                	addi	sp,sp,-80
    80004f1a:	e486                	sd	ra,72(sp)
    80004f1c:	e0a2                	sd	s0,64(sp)
    80004f1e:	fc26                	sd	s1,56(sp)
    80004f20:	f44e                	sd	s3,40(sp)
    80004f22:	0880                	addi	s0,sp,80
    80004f24:	84aa                	mv	s1,a0
    80004f26:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	f76080e7          	jalr	-138(ra) # 80001e9e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004f30:	409c                	lw	a5,0(s1)
    80004f32:	37f9                	addiw	a5,a5,-2
    80004f34:	4705                	li	a4,1
    80004f36:	04f76863          	bltu	a4,a5,80004f86 <filestat+0x6e>
    80004f3a:	f84a                	sd	s2,48(sp)
    80004f3c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004f3e:	6c88                	ld	a0,24(s1)
    80004f40:	fffff097          	auipc	ra,0xfffff
    80004f44:	05e080e7          	jalr	94(ra) # 80003f9e <ilock>
    stati(f->ip, &st);
    80004f48:	fb840593          	addi	a1,s0,-72
    80004f4c:	6c88                	ld	a0,24(s1)
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	2de080e7          	jalr	734(ra) # 8000422c <stati>
    iunlock(f->ip);
    80004f56:	6c88                	ld	a0,24(s1)
    80004f58:	fffff097          	auipc	ra,0xfffff
    80004f5c:	10c080e7          	jalr	268(ra) # 80004064 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f60:	46e1                	li	a3,24
    80004f62:	fb840613          	addi	a2,s0,-72
    80004f66:	85ce                	mv	a1,s3
    80004f68:	05093503          	ld	a0,80(s2)
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	a7a080e7          	jalr	-1414(ra) # 800019e6 <copyout>
    80004f74:	41f5551b          	sraiw	a0,a0,0x1f
    80004f78:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004f7a:	60a6                	ld	ra,72(sp)
    80004f7c:	6406                	ld	s0,64(sp)
    80004f7e:	74e2                	ld	s1,56(sp)
    80004f80:	79a2                	ld	s3,40(sp)
    80004f82:	6161                	addi	sp,sp,80
    80004f84:	8082                	ret
  return -1;
    80004f86:	557d                	li	a0,-1
    80004f88:	bfcd                	j	80004f7a <filestat+0x62>

0000000080004f8a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f8a:	7179                	addi	sp,sp,-48
    80004f8c:	f406                	sd	ra,40(sp)
    80004f8e:	f022                	sd	s0,32(sp)
    80004f90:	e84a                	sd	s2,16(sp)
    80004f92:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f94:	00854783          	lbu	a5,8(a0)
    80004f98:	cbc5                	beqz	a5,80005048 <fileread+0xbe>
    80004f9a:	ec26                	sd	s1,24(sp)
    80004f9c:	e44e                	sd	s3,8(sp)
    80004f9e:	84aa                	mv	s1,a0
    80004fa0:	89ae                	mv	s3,a1
    80004fa2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004fa4:	411c                	lw	a5,0(a0)
    80004fa6:	4705                	li	a4,1
    80004fa8:	04e78963          	beq	a5,a4,80004ffa <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004fac:	470d                	li	a4,3
    80004fae:	04e78f63          	beq	a5,a4,8000500c <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004fb2:	4709                	li	a4,2
    80004fb4:	08e79263          	bne	a5,a4,80005038 <fileread+0xae>
    ilock(f->ip);
    80004fb8:	6d08                	ld	a0,24(a0)
    80004fba:	fffff097          	auipc	ra,0xfffff
    80004fbe:	fe4080e7          	jalr	-28(ra) # 80003f9e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004fc2:	874a                	mv	a4,s2
    80004fc4:	5094                	lw	a3,32(s1)
    80004fc6:	864e                	mv	a2,s3
    80004fc8:	4585                	li	a1,1
    80004fca:	6c88                	ld	a0,24(s1)
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	28a080e7          	jalr	650(ra) # 80004256 <readi>
    80004fd4:	892a                	mv	s2,a0
    80004fd6:	00a05563          	blez	a0,80004fe0 <fileread+0x56>
      f->off += r;
    80004fda:	509c                	lw	a5,32(s1)
    80004fdc:	9fa9                	addw	a5,a5,a0
    80004fde:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004fe0:	6c88                	ld	a0,24(s1)
    80004fe2:	fffff097          	auipc	ra,0xfffff
    80004fe6:	082080e7          	jalr	130(ra) # 80004064 <iunlock>
    80004fea:	64e2                	ld	s1,24(sp)
    80004fec:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004fee:	854a                	mv	a0,s2
    80004ff0:	70a2                	ld	ra,40(sp)
    80004ff2:	7402                	ld	s0,32(sp)
    80004ff4:	6942                	ld	s2,16(sp)
    80004ff6:	6145                	addi	sp,sp,48
    80004ff8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ffa:	6908                	ld	a0,16(a0)
    80004ffc:	00000097          	auipc	ra,0x0
    80005000:	400080e7          	jalr	1024(ra) # 800053fc <piperead>
    80005004:	892a                	mv	s2,a0
    80005006:	64e2                	ld	s1,24(sp)
    80005008:	69a2                	ld	s3,8(sp)
    8000500a:	b7d5                	j	80004fee <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000500c:	02451783          	lh	a5,36(a0)
    80005010:	03079693          	slli	a3,a5,0x30
    80005014:	92c1                	srli	a3,a3,0x30
    80005016:	4725                	li	a4,9
    80005018:	02d76a63          	bltu	a4,a3,8000504c <fileread+0xc2>
    8000501c:	0792                	slli	a5,a5,0x4
    8000501e:	00027717          	auipc	a4,0x27
    80005022:	93270713          	addi	a4,a4,-1742 # 8002b950 <devsw>
    80005026:	97ba                	add	a5,a5,a4
    80005028:	639c                	ld	a5,0(a5)
    8000502a:	c78d                	beqz	a5,80005054 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    8000502c:	4505                	li	a0,1
    8000502e:	9782                	jalr	a5
    80005030:	892a                	mv	s2,a0
    80005032:	64e2                	ld	s1,24(sp)
    80005034:	69a2                	ld	s3,8(sp)
    80005036:	bf65                	j	80004fee <fileread+0x64>
    panic("fileread");
    80005038:	00003517          	auipc	a0,0x3
    8000503c:	6f850513          	addi	a0,a0,1784 # 80008730 <__func__.1+0x728>
    80005040:	ffffb097          	auipc	ra,0xffffb
    80005044:	520080e7          	jalr	1312(ra) # 80000560 <panic>
    return -1;
    80005048:	597d                	li	s2,-1
    8000504a:	b755                	j	80004fee <fileread+0x64>
      return -1;
    8000504c:	597d                	li	s2,-1
    8000504e:	64e2                	ld	s1,24(sp)
    80005050:	69a2                	ld	s3,8(sp)
    80005052:	bf71                	j	80004fee <fileread+0x64>
    80005054:	597d                	li	s2,-1
    80005056:	64e2                	ld	s1,24(sp)
    80005058:	69a2                	ld	s3,8(sp)
    8000505a:	bf51                	j	80004fee <fileread+0x64>

000000008000505c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000505c:	00954783          	lbu	a5,9(a0)
    80005060:	12078963          	beqz	a5,80005192 <filewrite+0x136>
{
    80005064:	715d                	addi	sp,sp,-80
    80005066:	e486                	sd	ra,72(sp)
    80005068:	e0a2                	sd	s0,64(sp)
    8000506a:	f84a                	sd	s2,48(sp)
    8000506c:	f052                	sd	s4,32(sp)
    8000506e:	e85a                	sd	s6,16(sp)
    80005070:	0880                	addi	s0,sp,80
    80005072:	892a                	mv	s2,a0
    80005074:	8b2e                	mv	s6,a1
    80005076:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005078:	411c                	lw	a5,0(a0)
    8000507a:	4705                	li	a4,1
    8000507c:	02e78763          	beq	a5,a4,800050aa <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005080:	470d                	li	a4,3
    80005082:	02e78a63          	beq	a5,a4,800050b6 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005086:	4709                	li	a4,2
    80005088:	0ee79863          	bne	a5,a4,80005178 <filewrite+0x11c>
    8000508c:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000508e:	0cc05463          	blez	a2,80005156 <filewrite+0xfa>
    80005092:	fc26                	sd	s1,56(sp)
    80005094:	ec56                	sd	s5,24(sp)
    80005096:	e45e                	sd	s7,8(sp)
    80005098:	e062                	sd	s8,0(sp)
    int i = 0;
    8000509a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000509c:	6b85                	lui	s7,0x1
    8000509e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800050a2:	6c05                	lui	s8,0x1
    800050a4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800050a8:	a851                	j	8000513c <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800050aa:	6908                	ld	a0,16(a0)
    800050ac:	00000097          	auipc	ra,0x0
    800050b0:	248080e7          	jalr	584(ra) # 800052f4 <pipewrite>
    800050b4:	a85d                	j	8000516a <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800050b6:	02451783          	lh	a5,36(a0)
    800050ba:	03079693          	slli	a3,a5,0x30
    800050be:	92c1                	srli	a3,a3,0x30
    800050c0:	4725                	li	a4,9
    800050c2:	0cd76a63          	bltu	a4,a3,80005196 <filewrite+0x13a>
    800050c6:	0792                	slli	a5,a5,0x4
    800050c8:	00027717          	auipc	a4,0x27
    800050cc:	88870713          	addi	a4,a4,-1912 # 8002b950 <devsw>
    800050d0:	97ba                	add	a5,a5,a4
    800050d2:	679c                	ld	a5,8(a5)
    800050d4:	c3f9                	beqz	a5,8000519a <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    800050d6:	4505                	li	a0,1
    800050d8:	9782                	jalr	a5
    800050da:	a841                	j	8000516a <filewrite+0x10e>
      if(n1 > max)
    800050dc:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800050e0:	00000097          	auipc	ra,0x0
    800050e4:	88c080e7          	jalr	-1908(ra) # 8000496c <begin_op>
      ilock(f->ip);
    800050e8:	01893503          	ld	a0,24(s2)
    800050ec:	fffff097          	auipc	ra,0xfffff
    800050f0:	eb2080e7          	jalr	-334(ra) # 80003f9e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050f4:	8756                	mv	a4,s5
    800050f6:	02092683          	lw	a3,32(s2)
    800050fa:	01698633          	add	a2,s3,s6
    800050fe:	4585                	li	a1,1
    80005100:	01893503          	ld	a0,24(s2)
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	262080e7          	jalr	610(ra) # 80004366 <writei>
    8000510c:	84aa                	mv	s1,a0
    8000510e:	00a05763          	blez	a0,8000511c <filewrite+0xc0>
        f->off += r;
    80005112:	02092783          	lw	a5,32(s2)
    80005116:	9fa9                	addw	a5,a5,a0
    80005118:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000511c:	01893503          	ld	a0,24(s2)
    80005120:	fffff097          	auipc	ra,0xfffff
    80005124:	f44080e7          	jalr	-188(ra) # 80004064 <iunlock>
      end_op();
    80005128:	00000097          	auipc	ra,0x0
    8000512c:	8be080e7          	jalr	-1858(ra) # 800049e6 <end_op>

      if(r != n1){
    80005130:	029a9563          	bne	s5,s1,8000515a <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80005134:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005138:	0149da63          	bge	s3,s4,8000514c <filewrite+0xf0>
      int n1 = n - i;
    8000513c:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80005140:	0004879b          	sext.w	a5,s1
    80005144:	f8fbdce3          	bge	s7,a5,800050dc <filewrite+0x80>
    80005148:	84e2                	mv	s1,s8
    8000514a:	bf49                	j	800050dc <filewrite+0x80>
    8000514c:	74e2                	ld	s1,56(sp)
    8000514e:	6ae2                	ld	s5,24(sp)
    80005150:	6ba2                	ld	s7,8(sp)
    80005152:	6c02                	ld	s8,0(sp)
    80005154:	a039                	j	80005162 <filewrite+0x106>
    int i = 0;
    80005156:	4981                	li	s3,0
    80005158:	a029                	j	80005162 <filewrite+0x106>
    8000515a:	74e2                	ld	s1,56(sp)
    8000515c:	6ae2                	ld	s5,24(sp)
    8000515e:	6ba2                	ld	s7,8(sp)
    80005160:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80005162:	033a1e63          	bne	s4,s3,8000519e <filewrite+0x142>
    80005166:	8552                	mv	a0,s4
    80005168:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000516a:	60a6                	ld	ra,72(sp)
    8000516c:	6406                	ld	s0,64(sp)
    8000516e:	7942                	ld	s2,48(sp)
    80005170:	7a02                	ld	s4,32(sp)
    80005172:	6b42                	ld	s6,16(sp)
    80005174:	6161                	addi	sp,sp,80
    80005176:	8082                	ret
    80005178:	fc26                	sd	s1,56(sp)
    8000517a:	f44e                	sd	s3,40(sp)
    8000517c:	ec56                	sd	s5,24(sp)
    8000517e:	e45e                	sd	s7,8(sp)
    80005180:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80005182:	00003517          	auipc	a0,0x3
    80005186:	5be50513          	addi	a0,a0,1470 # 80008740 <__func__.1+0x738>
    8000518a:	ffffb097          	auipc	ra,0xffffb
    8000518e:	3d6080e7          	jalr	982(ra) # 80000560 <panic>
    return -1;
    80005192:	557d                	li	a0,-1
}
    80005194:	8082                	ret
      return -1;
    80005196:	557d                	li	a0,-1
    80005198:	bfc9                	j	8000516a <filewrite+0x10e>
    8000519a:	557d                	li	a0,-1
    8000519c:	b7f9                	j	8000516a <filewrite+0x10e>
    ret = (i == n ? n : -1);
    8000519e:	557d                	li	a0,-1
    800051a0:	79a2                	ld	s3,40(sp)
    800051a2:	b7e1                	j	8000516a <filewrite+0x10e>

00000000800051a4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800051a4:	7179                	addi	sp,sp,-48
    800051a6:	f406                	sd	ra,40(sp)
    800051a8:	f022                	sd	s0,32(sp)
    800051aa:	ec26                	sd	s1,24(sp)
    800051ac:	e052                	sd	s4,0(sp)
    800051ae:	1800                	addi	s0,sp,48
    800051b0:	84aa                	mv	s1,a0
    800051b2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800051b4:	0005b023          	sd	zero,0(a1)
    800051b8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800051bc:	00000097          	auipc	ra,0x0
    800051c0:	bbe080e7          	jalr	-1090(ra) # 80004d7a <filealloc>
    800051c4:	e088                	sd	a0,0(s1)
    800051c6:	cd49                	beqz	a0,80005260 <pipealloc+0xbc>
    800051c8:	00000097          	auipc	ra,0x0
    800051cc:	bb2080e7          	jalr	-1102(ra) # 80004d7a <filealloc>
    800051d0:	00aa3023          	sd	a0,0(s4)
    800051d4:	c141                	beqz	a0,80005254 <pipealloc+0xb0>
    800051d6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	aa2080e7          	jalr	-1374(ra) # 80000c7a <kalloc>
    800051e0:	892a                	mv	s2,a0
    800051e2:	c13d                	beqz	a0,80005248 <pipealloc+0xa4>
    800051e4:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800051e6:	4985                	li	s3,1
    800051e8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800051ec:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800051f0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800051f4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800051f8:	00003597          	auipc	a1,0x3
    800051fc:	55858593          	addi	a1,a1,1368 # 80008750 <__func__.1+0x748>
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	c9e080e7          	jalr	-866(ra) # 80000e9e <initlock>
  (*f0)->type = FD_PIPE;
    80005208:	609c                	ld	a5,0(s1)
    8000520a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000520e:	609c                	ld	a5,0(s1)
    80005210:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005214:	609c                	ld	a5,0(s1)
    80005216:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000521a:	609c                	ld	a5,0(s1)
    8000521c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005220:	000a3783          	ld	a5,0(s4)
    80005224:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005228:	000a3783          	ld	a5,0(s4)
    8000522c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005230:	000a3783          	ld	a5,0(s4)
    80005234:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005238:	000a3783          	ld	a5,0(s4)
    8000523c:	0127b823          	sd	s2,16(a5)
  return 0;
    80005240:	4501                	li	a0,0
    80005242:	6942                	ld	s2,16(sp)
    80005244:	69a2                	ld	s3,8(sp)
    80005246:	a03d                	j	80005274 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005248:	6088                	ld	a0,0(s1)
    8000524a:	c119                	beqz	a0,80005250 <pipealloc+0xac>
    8000524c:	6942                	ld	s2,16(sp)
    8000524e:	a029                	j	80005258 <pipealloc+0xb4>
    80005250:	6942                	ld	s2,16(sp)
    80005252:	a039                	j	80005260 <pipealloc+0xbc>
    80005254:	6088                	ld	a0,0(s1)
    80005256:	c50d                	beqz	a0,80005280 <pipealloc+0xdc>
    fileclose(*f0);
    80005258:	00000097          	auipc	ra,0x0
    8000525c:	bde080e7          	jalr	-1058(ra) # 80004e36 <fileclose>
  if(*f1)
    80005260:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005264:	557d                	li	a0,-1
  if(*f1)
    80005266:	c799                	beqz	a5,80005274 <pipealloc+0xd0>
    fileclose(*f1);
    80005268:	853e                	mv	a0,a5
    8000526a:	00000097          	auipc	ra,0x0
    8000526e:	bcc080e7          	jalr	-1076(ra) # 80004e36 <fileclose>
  return -1;
    80005272:	557d                	li	a0,-1
}
    80005274:	70a2                	ld	ra,40(sp)
    80005276:	7402                	ld	s0,32(sp)
    80005278:	64e2                	ld	s1,24(sp)
    8000527a:	6a02                	ld	s4,0(sp)
    8000527c:	6145                	addi	sp,sp,48
    8000527e:	8082                	ret
  return -1;
    80005280:	557d                	li	a0,-1
    80005282:	bfcd                	j	80005274 <pipealloc+0xd0>

0000000080005284 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005284:	1101                	addi	sp,sp,-32
    80005286:	ec06                	sd	ra,24(sp)
    80005288:	e822                	sd	s0,16(sp)
    8000528a:	e426                	sd	s1,8(sp)
    8000528c:	e04a                	sd	s2,0(sp)
    8000528e:	1000                	addi	s0,sp,32
    80005290:	84aa                	mv	s1,a0
    80005292:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	c9a080e7          	jalr	-870(ra) # 80000f2e <acquire>
  if(writable){
    8000529c:	02090d63          	beqz	s2,800052d6 <pipeclose+0x52>
    pi->writeopen = 0;
    800052a0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800052a4:	21848513          	addi	a0,s1,536
    800052a8:	ffffd097          	auipc	ra,0xffffd
    800052ac:	40c080e7          	jalr	1036(ra) # 800026b4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800052b0:	2204b783          	ld	a5,544(s1)
    800052b4:	eb95                	bnez	a5,800052e8 <pipeclose+0x64>
    release(&pi->lock);
    800052b6:	8526                	mv	a0,s1
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	d2a080e7          	jalr	-726(ra) # 80000fe2 <release>
    kfree((char*)pi);
    800052c0:	8526                	mv	a0,s1
    800052c2:	ffffb097          	auipc	ra,0xffffb
    800052c6:	7c6080e7          	jalr	1990(ra) # 80000a88 <kfree>
  } else
    release(&pi->lock);
}
    800052ca:	60e2                	ld	ra,24(sp)
    800052cc:	6442                	ld	s0,16(sp)
    800052ce:	64a2                	ld	s1,8(sp)
    800052d0:	6902                	ld	s2,0(sp)
    800052d2:	6105                	addi	sp,sp,32
    800052d4:	8082                	ret
    pi->readopen = 0;
    800052d6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800052da:	21c48513          	addi	a0,s1,540
    800052de:	ffffd097          	auipc	ra,0xffffd
    800052e2:	3d6080e7          	jalr	982(ra) # 800026b4 <wakeup>
    800052e6:	b7e9                	j	800052b0 <pipeclose+0x2c>
    release(&pi->lock);
    800052e8:	8526                	mv	a0,s1
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	cf8080e7          	jalr	-776(ra) # 80000fe2 <release>
}
    800052f2:	bfe1                	j	800052ca <pipeclose+0x46>

00000000800052f4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052f4:	711d                	addi	sp,sp,-96
    800052f6:	ec86                	sd	ra,88(sp)
    800052f8:	e8a2                	sd	s0,80(sp)
    800052fa:	e4a6                	sd	s1,72(sp)
    800052fc:	e0ca                	sd	s2,64(sp)
    800052fe:	fc4e                	sd	s3,56(sp)
    80005300:	f852                	sd	s4,48(sp)
    80005302:	f456                	sd	s5,40(sp)
    80005304:	1080                	addi	s0,sp,96
    80005306:	84aa                	mv	s1,a0
    80005308:	8aae                	mv	s5,a1
    8000530a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000530c:	ffffd097          	auipc	ra,0xffffd
    80005310:	b92080e7          	jalr	-1134(ra) # 80001e9e <myproc>
    80005314:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005316:	8526                	mv	a0,s1
    80005318:	ffffc097          	auipc	ra,0xffffc
    8000531c:	c16080e7          	jalr	-1002(ra) # 80000f2e <acquire>
  while(i < n){
    80005320:	0d405863          	blez	s4,800053f0 <pipewrite+0xfc>
    80005324:	f05a                	sd	s6,32(sp)
    80005326:	ec5e                	sd	s7,24(sp)
    80005328:	e862                	sd	s8,16(sp)
  int i = 0;
    8000532a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000532c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000532e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005332:	21c48b93          	addi	s7,s1,540
    80005336:	a089                	j	80005378 <pipewrite+0x84>
      release(&pi->lock);
    80005338:	8526                	mv	a0,s1
    8000533a:	ffffc097          	auipc	ra,0xffffc
    8000533e:	ca8080e7          	jalr	-856(ra) # 80000fe2 <release>
      return -1;
    80005342:	597d                	li	s2,-1
    80005344:	7b02                	ld	s6,32(sp)
    80005346:	6be2                	ld	s7,24(sp)
    80005348:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000534a:	854a                	mv	a0,s2
    8000534c:	60e6                	ld	ra,88(sp)
    8000534e:	6446                	ld	s0,80(sp)
    80005350:	64a6                	ld	s1,72(sp)
    80005352:	6906                	ld	s2,64(sp)
    80005354:	79e2                	ld	s3,56(sp)
    80005356:	7a42                	ld	s4,48(sp)
    80005358:	7aa2                	ld	s5,40(sp)
    8000535a:	6125                	addi	sp,sp,96
    8000535c:	8082                	ret
      wakeup(&pi->nread);
    8000535e:	8562                	mv	a0,s8
    80005360:	ffffd097          	auipc	ra,0xffffd
    80005364:	354080e7          	jalr	852(ra) # 800026b4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005368:	85a6                	mv	a1,s1
    8000536a:	855e                	mv	a0,s7
    8000536c:	ffffd097          	auipc	ra,0xffffd
    80005370:	2e4080e7          	jalr	740(ra) # 80002650 <sleep>
  while(i < n){
    80005374:	05495f63          	bge	s2,s4,800053d2 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80005378:	2204a783          	lw	a5,544(s1)
    8000537c:	dfd5                	beqz	a5,80005338 <pipewrite+0x44>
    8000537e:	854e                	mv	a0,s3
    80005380:	ffffd097          	auipc	ra,0xffffd
    80005384:	578080e7          	jalr	1400(ra) # 800028f8 <killed>
    80005388:	f945                	bnez	a0,80005338 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000538a:	2184a783          	lw	a5,536(s1)
    8000538e:	21c4a703          	lw	a4,540(s1)
    80005392:	2007879b          	addiw	a5,a5,512
    80005396:	fcf704e3          	beq	a4,a5,8000535e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000539a:	4685                	li	a3,1
    8000539c:	01590633          	add	a2,s2,s5
    800053a0:	faf40593          	addi	a1,s0,-81
    800053a4:	0509b503          	ld	a0,80(s3)
    800053a8:	ffffc097          	auipc	ra,0xffffc
    800053ac:	6ca080e7          	jalr	1738(ra) # 80001a72 <copyin>
    800053b0:	05650263          	beq	a0,s6,800053f4 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800053b4:	21c4a783          	lw	a5,540(s1)
    800053b8:	0017871b          	addiw	a4,a5,1
    800053bc:	20e4ae23          	sw	a4,540(s1)
    800053c0:	1ff7f793          	andi	a5,a5,511
    800053c4:	97a6                	add	a5,a5,s1
    800053c6:	faf44703          	lbu	a4,-81(s0)
    800053ca:	00e78c23          	sb	a4,24(a5)
      i++;
    800053ce:	2905                	addiw	s2,s2,1
    800053d0:	b755                	j	80005374 <pipewrite+0x80>
    800053d2:	7b02                	ld	s6,32(sp)
    800053d4:	6be2                	ld	s7,24(sp)
    800053d6:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800053d8:	21848513          	addi	a0,s1,536
    800053dc:	ffffd097          	auipc	ra,0xffffd
    800053e0:	2d8080e7          	jalr	728(ra) # 800026b4 <wakeup>
  release(&pi->lock);
    800053e4:	8526                	mv	a0,s1
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	bfc080e7          	jalr	-1028(ra) # 80000fe2 <release>
  return i;
    800053ee:	bfb1                	j	8000534a <pipewrite+0x56>
  int i = 0;
    800053f0:	4901                	li	s2,0
    800053f2:	b7dd                	j	800053d8 <pipewrite+0xe4>
    800053f4:	7b02                	ld	s6,32(sp)
    800053f6:	6be2                	ld	s7,24(sp)
    800053f8:	6c42                	ld	s8,16(sp)
    800053fa:	bff9                	j	800053d8 <pipewrite+0xe4>

00000000800053fc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053fc:	715d                	addi	sp,sp,-80
    800053fe:	e486                	sd	ra,72(sp)
    80005400:	e0a2                	sd	s0,64(sp)
    80005402:	fc26                	sd	s1,56(sp)
    80005404:	f84a                	sd	s2,48(sp)
    80005406:	f44e                	sd	s3,40(sp)
    80005408:	f052                	sd	s4,32(sp)
    8000540a:	ec56                	sd	s5,24(sp)
    8000540c:	0880                	addi	s0,sp,80
    8000540e:	84aa                	mv	s1,a0
    80005410:	892e                	mv	s2,a1
    80005412:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005414:	ffffd097          	auipc	ra,0xffffd
    80005418:	a8a080e7          	jalr	-1398(ra) # 80001e9e <myproc>
    8000541c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000541e:	8526                	mv	a0,s1
    80005420:	ffffc097          	auipc	ra,0xffffc
    80005424:	b0e080e7          	jalr	-1266(ra) # 80000f2e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005428:	2184a703          	lw	a4,536(s1)
    8000542c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005430:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005434:	02f71963          	bne	a4,a5,80005466 <piperead+0x6a>
    80005438:	2244a783          	lw	a5,548(s1)
    8000543c:	cf95                	beqz	a5,80005478 <piperead+0x7c>
    if(killed(pr)){
    8000543e:	8552                	mv	a0,s4
    80005440:	ffffd097          	auipc	ra,0xffffd
    80005444:	4b8080e7          	jalr	1208(ra) # 800028f8 <killed>
    80005448:	e10d                	bnez	a0,8000546a <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000544a:	85a6                	mv	a1,s1
    8000544c:	854e                	mv	a0,s3
    8000544e:	ffffd097          	auipc	ra,0xffffd
    80005452:	202080e7          	jalr	514(ra) # 80002650 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005456:	2184a703          	lw	a4,536(s1)
    8000545a:	21c4a783          	lw	a5,540(s1)
    8000545e:	fcf70de3          	beq	a4,a5,80005438 <piperead+0x3c>
    80005462:	e85a                	sd	s6,16(sp)
    80005464:	a819                	j	8000547a <piperead+0x7e>
    80005466:	e85a                	sd	s6,16(sp)
    80005468:	a809                	j	8000547a <piperead+0x7e>
      release(&pi->lock);
    8000546a:	8526                	mv	a0,s1
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	b76080e7          	jalr	-1162(ra) # 80000fe2 <release>
      return -1;
    80005474:	59fd                	li	s3,-1
    80005476:	a0a5                	j	800054de <piperead+0xe2>
    80005478:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000547a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000547c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000547e:	05505463          	blez	s5,800054c6 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80005482:	2184a783          	lw	a5,536(s1)
    80005486:	21c4a703          	lw	a4,540(s1)
    8000548a:	02f70e63          	beq	a4,a5,800054c6 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000548e:	0017871b          	addiw	a4,a5,1
    80005492:	20e4ac23          	sw	a4,536(s1)
    80005496:	1ff7f793          	andi	a5,a5,511
    8000549a:	97a6                	add	a5,a5,s1
    8000549c:	0187c783          	lbu	a5,24(a5)
    800054a0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800054a4:	4685                	li	a3,1
    800054a6:	fbf40613          	addi	a2,s0,-65
    800054aa:	85ca                	mv	a1,s2
    800054ac:	050a3503          	ld	a0,80(s4)
    800054b0:	ffffc097          	auipc	ra,0xffffc
    800054b4:	536080e7          	jalr	1334(ra) # 800019e6 <copyout>
    800054b8:	01650763          	beq	a0,s6,800054c6 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800054bc:	2985                	addiw	s3,s3,1
    800054be:	0905                	addi	s2,s2,1
    800054c0:	fd3a91e3          	bne	s5,s3,80005482 <piperead+0x86>
    800054c4:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800054c6:	21c48513          	addi	a0,s1,540
    800054ca:	ffffd097          	auipc	ra,0xffffd
    800054ce:	1ea080e7          	jalr	490(ra) # 800026b4 <wakeup>
  release(&pi->lock);
    800054d2:	8526                	mv	a0,s1
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	b0e080e7          	jalr	-1266(ra) # 80000fe2 <release>
    800054dc:	6b42                	ld	s6,16(sp)
  return i;
}
    800054de:	854e                	mv	a0,s3
    800054e0:	60a6                	ld	ra,72(sp)
    800054e2:	6406                	ld	s0,64(sp)
    800054e4:	74e2                	ld	s1,56(sp)
    800054e6:	7942                	ld	s2,48(sp)
    800054e8:	79a2                	ld	s3,40(sp)
    800054ea:	7a02                	ld	s4,32(sp)
    800054ec:	6ae2                	ld	s5,24(sp)
    800054ee:	6161                	addi	sp,sp,80
    800054f0:	8082                	ret

00000000800054f2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800054f2:	1141                	addi	sp,sp,-16
    800054f4:	e422                	sd	s0,8(sp)
    800054f6:	0800                	addi	s0,sp,16
    800054f8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800054fa:	8905                	andi	a0,a0,1
    800054fc:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800054fe:	8b89                	andi	a5,a5,2
    80005500:	c399                	beqz	a5,80005506 <flags2perm+0x14>
      perm |= PTE_W;
    80005502:	00456513          	ori	a0,a0,4
    return perm;
}
    80005506:	6422                	ld	s0,8(sp)
    80005508:	0141                	addi	sp,sp,16
    8000550a:	8082                	ret

000000008000550c <exec>:

int
exec(char *path, char **argv)
{
    8000550c:	df010113          	addi	sp,sp,-528
    80005510:	20113423          	sd	ra,520(sp)
    80005514:	20813023          	sd	s0,512(sp)
    80005518:	ffa6                	sd	s1,504(sp)
    8000551a:	fbca                	sd	s2,496(sp)
    8000551c:	0c00                	addi	s0,sp,528
    8000551e:	892a                	mv	s2,a0
    80005520:	dea43c23          	sd	a0,-520(s0)
    80005524:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005528:	ffffd097          	auipc	ra,0xffffd
    8000552c:	976080e7          	jalr	-1674(ra) # 80001e9e <myproc>
    80005530:	84aa                	mv	s1,a0

  begin_op();
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	43a080e7          	jalr	1082(ra) # 8000496c <begin_op>

  if((ip = namei(path)) == 0){
    8000553a:	854a                	mv	a0,s2
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	230080e7          	jalr	560(ra) # 8000476c <namei>
    80005544:	c135                	beqz	a0,800055a8 <exec+0x9c>
    80005546:	f3d2                	sd	s4,480(sp)
    80005548:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	a54080e7          	jalr	-1452(ra) # 80003f9e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005552:	04000713          	li	a4,64
    80005556:	4681                	li	a3,0
    80005558:	e5040613          	addi	a2,s0,-432
    8000555c:	4581                	li	a1,0
    8000555e:	8552                	mv	a0,s4
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	cf6080e7          	jalr	-778(ra) # 80004256 <readi>
    80005568:	04000793          	li	a5,64
    8000556c:	00f51a63          	bne	a0,a5,80005580 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005570:	e5042703          	lw	a4,-432(s0)
    80005574:	464c47b7          	lui	a5,0x464c4
    80005578:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000557c:	02f70c63          	beq	a4,a5,800055b4 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005580:	8552                	mv	a0,s4
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	c82080e7          	jalr	-894(ra) # 80004204 <iunlockput>
    end_op();
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	45c080e7          	jalr	1116(ra) # 800049e6 <end_op>
  }
  return -1;
    80005592:	557d                	li	a0,-1
    80005594:	7a1e                	ld	s4,480(sp)
}
    80005596:	20813083          	ld	ra,520(sp)
    8000559a:	20013403          	ld	s0,512(sp)
    8000559e:	74fe                	ld	s1,504(sp)
    800055a0:	795e                	ld	s2,496(sp)
    800055a2:	21010113          	addi	sp,sp,528
    800055a6:	8082                	ret
    end_op();
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	43e080e7          	jalr	1086(ra) # 800049e6 <end_op>
    return -1;
    800055b0:	557d                	li	a0,-1
    800055b2:	b7d5                	j	80005596 <exec+0x8a>
    800055b4:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffd097          	auipc	ra,0xffffd
    800055bc:	9aa080e7          	jalr	-1622(ra) # 80001f62 <proc_pagetable>
    800055c0:	8b2a                	mv	s6,a0
    800055c2:	30050f63          	beqz	a0,800058e0 <exec+0x3d4>
    800055c6:	f7ce                	sd	s3,488(sp)
    800055c8:	efd6                	sd	s5,472(sp)
    800055ca:	e7de                	sd	s7,456(sp)
    800055cc:	e3e2                	sd	s8,448(sp)
    800055ce:	ff66                	sd	s9,440(sp)
    800055d0:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055d2:	e7042d03          	lw	s10,-400(s0)
    800055d6:	e8845783          	lhu	a5,-376(s0)
    800055da:	14078d63          	beqz	a5,80005734 <exec+0x228>
    800055de:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055e0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055e2:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800055e4:	6c85                	lui	s9,0x1
    800055e6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800055ea:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800055ee:	6a85                	lui	s5,0x1
    800055f0:	a0b5                	j	8000565c <exec+0x150>
      panic("loadseg: address should exist");
    800055f2:	00003517          	auipc	a0,0x3
    800055f6:	16650513          	addi	a0,a0,358 # 80008758 <__func__.1+0x750>
    800055fa:	ffffb097          	auipc	ra,0xffffb
    800055fe:	f66080e7          	jalr	-154(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005602:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005604:	8726                	mv	a4,s1
    80005606:	012c06bb          	addw	a3,s8,s2
    8000560a:	4581                	li	a1,0
    8000560c:	8552                	mv	a0,s4
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	c48080e7          	jalr	-952(ra) # 80004256 <readi>
    80005616:	2501                	sext.w	a0,a0
    80005618:	28a49863          	bne	s1,a0,800058a8 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    8000561c:	012a893b          	addw	s2,s5,s2
    80005620:	03397563          	bgeu	s2,s3,8000564a <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005624:	02091593          	slli	a1,s2,0x20
    80005628:	9181                	srli	a1,a1,0x20
    8000562a:	95de                	add	a1,a1,s7
    8000562c:	855a                	mv	a0,s6
    8000562e:	ffffc097          	auipc	ra,0xffffc
    80005632:	d7e080e7          	jalr	-642(ra) # 800013ac <walkaddr>
    80005636:	862a                	mv	a2,a0
    if(pa == 0)
    80005638:	dd4d                	beqz	a0,800055f2 <exec+0xe6>
    if(sz - i < PGSIZE)
    8000563a:	412984bb          	subw	s1,s3,s2
    8000563e:	0004879b          	sext.w	a5,s1
    80005642:	fcfcf0e3          	bgeu	s9,a5,80005602 <exec+0xf6>
    80005646:	84d6                	mv	s1,s5
    80005648:	bf6d                	j	80005602 <exec+0xf6>
    sz = sz1;
    8000564a:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000564e:	2d85                	addiw	s11,s11,1
    80005650:	038d0d1b          	addiw	s10,s10,56
    80005654:	e8845783          	lhu	a5,-376(s0)
    80005658:	08fdd663          	bge	s11,a5,800056e4 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000565c:	2d01                	sext.w	s10,s10
    8000565e:	03800713          	li	a4,56
    80005662:	86ea                	mv	a3,s10
    80005664:	e1840613          	addi	a2,s0,-488
    80005668:	4581                	li	a1,0
    8000566a:	8552                	mv	a0,s4
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	bea080e7          	jalr	-1046(ra) # 80004256 <readi>
    80005674:	03800793          	li	a5,56
    80005678:	20f51063          	bne	a0,a5,80005878 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    8000567c:	e1842783          	lw	a5,-488(s0)
    80005680:	4705                	li	a4,1
    80005682:	fce796e3          	bne	a5,a4,8000564e <exec+0x142>
    if(ph.memsz < ph.filesz)
    80005686:	e4043483          	ld	s1,-448(s0)
    8000568a:	e3843783          	ld	a5,-456(s0)
    8000568e:	1ef4e963          	bltu	s1,a5,80005880 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005692:	e2843783          	ld	a5,-472(s0)
    80005696:	94be                	add	s1,s1,a5
    80005698:	1ef4e863          	bltu	s1,a5,80005888 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    8000569c:	df043703          	ld	a4,-528(s0)
    800056a0:	8ff9                	and	a5,a5,a4
    800056a2:	1e079763          	bnez	a5,80005890 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056a6:	e1c42503          	lw	a0,-484(s0)
    800056aa:	00000097          	auipc	ra,0x0
    800056ae:	e48080e7          	jalr	-440(ra) # 800054f2 <flags2perm>
    800056b2:	86aa                	mv	a3,a0
    800056b4:	8626                	mv	a2,s1
    800056b6:	85ca                	mv	a1,s2
    800056b8:	855a                	mv	a0,s6
    800056ba:	ffffc097          	auipc	ra,0xffffc
    800056be:	0b6080e7          	jalr	182(ra) # 80001770 <uvmalloc>
    800056c2:	e0a43423          	sd	a0,-504(s0)
    800056c6:	1c050963          	beqz	a0,80005898 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800056ca:	e2843b83          	ld	s7,-472(s0)
    800056ce:	e2042c03          	lw	s8,-480(s0)
    800056d2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800056d6:	00098463          	beqz	s3,800056de <exec+0x1d2>
    800056da:	4901                	li	s2,0
    800056dc:	b7a1                	j	80005624 <exec+0x118>
    sz = sz1;
    800056de:	e0843903          	ld	s2,-504(s0)
    800056e2:	b7b5                	j	8000564e <exec+0x142>
    800056e4:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800056e6:	8552                	mv	a0,s4
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	b1c080e7          	jalr	-1252(ra) # 80004204 <iunlockput>
  end_op();
    800056f0:	fffff097          	auipc	ra,0xfffff
    800056f4:	2f6080e7          	jalr	758(ra) # 800049e6 <end_op>
  p = myproc();
    800056f8:	ffffc097          	auipc	ra,0xffffc
    800056fc:	7a6080e7          	jalr	1958(ra) # 80001e9e <myproc>
    80005700:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005702:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005706:	6985                	lui	s3,0x1
    80005708:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000570a:	99ca                	add	s3,s3,s2
    8000570c:	77fd                	lui	a5,0xfffff
    8000570e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005712:	4691                	li	a3,4
    80005714:	6609                	lui	a2,0x2
    80005716:	964e                	add	a2,a2,s3
    80005718:	85ce                	mv	a1,s3
    8000571a:	855a                	mv	a0,s6
    8000571c:	ffffc097          	auipc	ra,0xffffc
    80005720:	054080e7          	jalr	84(ra) # 80001770 <uvmalloc>
    80005724:	892a                	mv	s2,a0
    80005726:	e0a43423          	sd	a0,-504(s0)
    8000572a:	e519                	bnez	a0,80005738 <exec+0x22c>
  if(pagetable)
    8000572c:	e1343423          	sd	s3,-504(s0)
    80005730:	4a01                	li	s4,0
    80005732:	aaa5                	j	800058aa <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005734:	4901                	li	s2,0
    80005736:	bf45                	j	800056e6 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005738:	75f9                	lui	a1,0xffffe
    8000573a:	95aa                	add	a1,a1,a0
    8000573c:	855a                	mv	a0,s6
    8000573e:	ffffc097          	auipc	ra,0xffffc
    80005742:	276080e7          	jalr	630(ra) # 800019b4 <uvmclear>
  stackbase = sp - PGSIZE;
    80005746:	7bfd                	lui	s7,0xfffff
    80005748:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000574a:	e0043783          	ld	a5,-512(s0)
    8000574e:	6388                	ld	a0,0(a5)
    80005750:	c52d                	beqz	a0,800057ba <exec+0x2ae>
    80005752:	e9040993          	addi	s3,s0,-368
    80005756:	f9040c13          	addi	s8,s0,-112
    8000575a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000575c:	ffffc097          	auipc	ra,0xffffc
    80005760:	a42080e7          	jalr	-1470(ra) # 8000119e <strlen>
    80005764:	0015079b          	addiw	a5,a0,1
    80005768:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000576c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005770:	13796863          	bltu	s2,s7,800058a0 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005774:	e0043d03          	ld	s10,-512(s0)
    80005778:	000d3a03          	ld	s4,0(s10)
    8000577c:	8552                	mv	a0,s4
    8000577e:	ffffc097          	auipc	ra,0xffffc
    80005782:	a20080e7          	jalr	-1504(ra) # 8000119e <strlen>
    80005786:	0015069b          	addiw	a3,a0,1
    8000578a:	8652                	mv	a2,s4
    8000578c:	85ca                	mv	a1,s2
    8000578e:	855a                	mv	a0,s6
    80005790:	ffffc097          	auipc	ra,0xffffc
    80005794:	256080e7          	jalr	598(ra) # 800019e6 <copyout>
    80005798:	10054663          	bltz	a0,800058a4 <exec+0x398>
    ustack[argc] = sp;
    8000579c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800057a0:	0485                	addi	s1,s1,1
    800057a2:	008d0793          	addi	a5,s10,8
    800057a6:	e0f43023          	sd	a5,-512(s0)
    800057aa:	008d3503          	ld	a0,8(s10)
    800057ae:	c909                	beqz	a0,800057c0 <exec+0x2b4>
    if(argc >= MAXARG)
    800057b0:	09a1                	addi	s3,s3,8
    800057b2:	fb8995e3          	bne	s3,s8,8000575c <exec+0x250>
  ip = 0;
    800057b6:	4a01                	li	s4,0
    800057b8:	a8cd                	j	800058aa <exec+0x39e>
  sp = sz;
    800057ba:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800057be:	4481                	li	s1,0
  ustack[argc] = 0;
    800057c0:	00349793          	slli	a5,s1,0x3
    800057c4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd24a8>
    800057c8:	97a2                	add	a5,a5,s0
    800057ca:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800057ce:	00148693          	addi	a3,s1,1
    800057d2:	068e                	slli	a3,a3,0x3
    800057d4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057d8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800057dc:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800057e0:	f57966e3          	bltu	s2,s7,8000572c <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057e4:	e9040613          	addi	a2,s0,-368
    800057e8:	85ca                	mv	a1,s2
    800057ea:	855a                	mv	a0,s6
    800057ec:	ffffc097          	auipc	ra,0xffffc
    800057f0:	1fa080e7          	jalr	506(ra) # 800019e6 <copyout>
    800057f4:	0e054863          	bltz	a0,800058e4 <exec+0x3d8>
  p->trapframe->a1 = sp;
    800057f8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800057fc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005800:	df843783          	ld	a5,-520(s0)
    80005804:	0007c703          	lbu	a4,0(a5)
    80005808:	cf11                	beqz	a4,80005824 <exec+0x318>
    8000580a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000580c:	02f00693          	li	a3,47
    80005810:	a039                	j	8000581e <exec+0x312>
      last = s+1;
    80005812:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005816:	0785                	addi	a5,a5,1
    80005818:	fff7c703          	lbu	a4,-1(a5)
    8000581c:	c701                	beqz	a4,80005824 <exec+0x318>
    if(*s == '/')
    8000581e:	fed71ce3          	bne	a4,a3,80005816 <exec+0x30a>
    80005822:	bfc5                	j	80005812 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005824:	4641                	li	a2,16
    80005826:	df843583          	ld	a1,-520(s0)
    8000582a:	158a8513          	addi	a0,s5,344
    8000582e:	ffffc097          	auipc	ra,0xffffc
    80005832:	93e080e7          	jalr	-1730(ra) # 8000116c <safestrcpy>
  oldpagetable = p->pagetable;
    80005836:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000583a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000583e:	e0843783          	ld	a5,-504(s0)
    80005842:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005846:	058ab783          	ld	a5,88(s5)
    8000584a:	e6843703          	ld	a4,-408(s0)
    8000584e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005850:	058ab783          	ld	a5,88(s5)
    80005854:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005858:	85e6                	mv	a1,s9
    8000585a:	ffffc097          	auipc	ra,0xffffc
    8000585e:	7a4080e7          	jalr	1956(ra) # 80001ffe <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005862:	0004851b          	sext.w	a0,s1
    80005866:	79be                	ld	s3,488(sp)
    80005868:	7a1e                	ld	s4,480(sp)
    8000586a:	6afe                	ld	s5,472(sp)
    8000586c:	6b5e                	ld	s6,464(sp)
    8000586e:	6bbe                	ld	s7,456(sp)
    80005870:	6c1e                	ld	s8,448(sp)
    80005872:	7cfa                	ld	s9,440(sp)
    80005874:	7d5a                	ld	s10,432(sp)
    80005876:	b305                	j	80005596 <exec+0x8a>
    80005878:	e1243423          	sd	s2,-504(s0)
    8000587c:	7dba                	ld	s11,424(sp)
    8000587e:	a035                	j	800058aa <exec+0x39e>
    80005880:	e1243423          	sd	s2,-504(s0)
    80005884:	7dba                	ld	s11,424(sp)
    80005886:	a015                	j	800058aa <exec+0x39e>
    80005888:	e1243423          	sd	s2,-504(s0)
    8000588c:	7dba                	ld	s11,424(sp)
    8000588e:	a831                	j	800058aa <exec+0x39e>
    80005890:	e1243423          	sd	s2,-504(s0)
    80005894:	7dba                	ld	s11,424(sp)
    80005896:	a811                	j	800058aa <exec+0x39e>
    80005898:	e1243423          	sd	s2,-504(s0)
    8000589c:	7dba                	ld	s11,424(sp)
    8000589e:	a031                	j	800058aa <exec+0x39e>
  ip = 0;
    800058a0:	4a01                	li	s4,0
    800058a2:	a021                	j	800058aa <exec+0x39e>
    800058a4:	4a01                	li	s4,0
  if(pagetable)
    800058a6:	a011                	j	800058aa <exec+0x39e>
    800058a8:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800058aa:	e0843583          	ld	a1,-504(s0)
    800058ae:	855a                	mv	a0,s6
    800058b0:	ffffc097          	auipc	ra,0xffffc
    800058b4:	74e080e7          	jalr	1870(ra) # 80001ffe <proc_freepagetable>
  return -1;
    800058b8:	557d                	li	a0,-1
  if(ip){
    800058ba:	000a1b63          	bnez	s4,800058d0 <exec+0x3c4>
    800058be:	79be                	ld	s3,488(sp)
    800058c0:	7a1e                	ld	s4,480(sp)
    800058c2:	6afe                	ld	s5,472(sp)
    800058c4:	6b5e                	ld	s6,464(sp)
    800058c6:	6bbe                	ld	s7,456(sp)
    800058c8:	6c1e                	ld	s8,448(sp)
    800058ca:	7cfa                	ld	s9,440(sp)
    800058cc:	7d5a                	ld	s10,432(sp)
    800058ce:	b1e1                	j	80005596 <exec+0x8a>
    800058d0:	79be                	ld	s3,488(sp)
    800058d2:	6afe                	ld	s5,472(sp)
    800058d4:	6b5e                	ld	s6,464(sp)
    800058d6:	6bbe                	ld	s7,456(sp)
    800058d8:	6c1e                	ld	s8,448(sp)
    800058da:	7cfa                	ld	s9,440(sp)
    800058dc:	7d5a                	ld	s10,432(sp)
    800058de:	b14d                	j	80005580 <exec+0x74>
    800058e0:	6b5e                	ld	s6,464(sp)
    800058e2:	b979                	j	80005580 <exec+0x74>
  sz = sz1;
    800058e4:	e0843983          	ld	s3,-504(s0)
    800058e8:	b591                	j	8000572c <exec+0x220>

00000000800058ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800058ea:	7179                	addi	sp,sp,-48
    800058ec:	f406                	sd	ra,40(sp)
    800058ee:	f022                	sd	s0,32(sp)
    800058f0:	ec26                	sd	s1,24(sp)
    800058f2:	e84a                	sd	s2,16(sp)
    800058f4:	1800                	addi	s0,sp,48
    800058f6:	892e                	mv	s2,a1
    800058f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800058fa:	fdc40593          	addi	a1,s0,-36
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	9ea080e7          	jalr	-1558(ra) # 800032e8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005906:	fdc42703          	lw	a4,-36(s0)
    8000590a:	47bd                	li	a5,15
    8000590c:	02e7eb63          	bltu	a5,a4,80005942 <argfd+0x58>
    80005910:	ffffc097          	auipc	ra,0xffffc
    80005914:	58e080e7          	jalr	1422(ra) # 80001e9e <myproc>
    80005918:	fdc42703          	lw	a4,-36(s0)
    8000591c:	01a70793          	addi	a5,a4,26
    80005920:	078e                	slli	a5,a5,0x3
    80005922:	953e                	add	a0,a0,a5
    80005924:	611c                	ld	a5,0(a0)
    80005926:	c385                	beqz	a5,80005946 <argfd+0x5c>
    return -1;
  if(pfd)
    80005928:	00090463          	beqz	s2,80005930 <argfd+0x46>
    *pfd = fd;
    8000592c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005930:	4501                	li	a0,0
  if(pf)
    80005932:	c091                	beqz	s1,80005936 <argfd+0x4c>
    *pf = f;
    80005934:	e09c                	sd	a5,0(s1)
}
    80005936:	70a2                	ld	ra,40(sp)
    80005938:	7402                	ld	s0,32(sp)
    8000593a:	64e2                	ld	s1,24(sp)
    8000593c:	6942                	ld	s2,16(sp)
    8000593e:	6145                	addi	sp,sp,48
    80005940:	8082                	ret
    return -1;
    80005942:	557d                	li	a0,-1
    80005944:	bfcd                	j	80005936 <argfd+0x4c>
    80005946:	557d                	li	a0,-1
    80005948:	b7fd                	j	80005936 <argfd+0x4c>

000000008000594a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000594a:	1101                	addi	sp,sp,-32
    8000594c:	ec06                	sd	ra,24(sp)
    8000594e:	e822                	sd	s0,16(sp)
    80005950:	e426                	sd	s1,8(sp)
    80005952:	1000                	addi	s0,sp,32
    80005954:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005956:	ffffc097          	auipc	ra,0xffffc
    8000595a:	548080e7          	jalr	1352(ra) # 80001e9e <myproc>
    8000595e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005960:	0d050793          	addi	a5,a0,208
    80005964:	4501                	li	a0,0
    80005966:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005968:	6398                	ld	a4,0(a5)
    8000596a:	cb19                	beqz	a4,80005980 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000596c:	2505                	addiw	a0,a0,1
    8000596e:	07a1                	addi	a5,a5,8
    80005970:	fed51ce3          	bne	a0,a3,80005968 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005974:	557d                	li	a0,-1
}
    80005976:	60e2                	ld	ra,24(sp)
    80005978:	6442                	ld	s0,16(sp)
    8000597a:	64a2                	ld	s1,8(sp)
    8000597c:	6105                	addi	sp,sp,32
    8000597e:	8082                	ret
      p->ofile[fd] = f;
    80005980:	01a50793          	addi	a5,a0,26
    80005984:	078e                	slli	a5,a5,0x3
    80005986:	963e                	add	a2,a2,a5
    80005988:	e204                	sd	s1,0(a2)
      return fd;
    8000598a:	b7f5                	j	80005976 <fdalloc+0x2c>

000000008000598c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000598c:	715d                	addi	sp,sp,-80
    8000598e:	e486                	sd	ra,72(sp)
    80005990:	e0a2                	sd	s0,64(sp)
    80005992:	fc26                	sd	s1,56(sp)
    80005994:	f84a                	sd	s2,48(sp)
    80005996:	f44e                	sd	s3,40(sp)
    80005998:	ec56                	sd	s5,24(sp)
    8000599a:	e85a                	sd	s6,16(sp)
    8000599c:	0880                	addi	s0,sp,80
    8000599e:	8b2e                	mv	s6,a1
    800059a0:	89b2                	mv	s3,a2
    800059a2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800059a4:	fb040593          	addi	a1,s0,-80
    800059a8:	fffff097          	auipc	ra,0xfffff
    800059ac:	de2080e7          	jalr	-542(ra) # 8000478a <nameiparent>
    800059b0:	84aa                	mv	s1,a0
    800059b2:	14050e63          	beqz	a0,80005b0e <create+0x182>
    return 0;

  ilock(dp);
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	5e8080e7          	jalr	1512(ra) # 80003f9e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800059be:	4601                	li	a2,0
    800059c0:	fb040593          	addi	a1,s0,-80
    800059c4:	8526                	mv	a0,s1
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	ae4080e7          	jalr	-1308(ra) # 800044aa <dirlookup>
    800059ce:	8aaa                	mv	s5,a0
    800059d0:	c539                	beqz	a0,80005a1e <create+0x92>
    iunlockput(dp);
    800059d2:	8526                	mv	a0,s1
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	830080e7          	jalr	-2000(ra) # 80004204 <iunlockput>
    ilock(ip);
    800059dc:	8556                	mv	a0,s5
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	5c0080e7          	jalr	1472(ra) # 80003f9e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800059e6:	4789                	li	a5,2
    800059e8:	02fb1463          	bne	s6,a5,80005a10 <create+0x84>
    800059ec:	044ad783          	lhu	a5,68(s5)
    800059f0:	37f9                	addiw	a5,a5,-2
    800059f2:	17c2                	slli	a5,a5,0x30
    800059f4:	93c1                	srli	a5,a5,0x30
    800059f6:	4705                	li	a4,1
    800059f8:	00f76c63          	bltu	a4,a5,80005a10 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800059fc:	8556                	mv	a0,s5
    800059fe:	60a6                	ld	ra,72(sp)
    80005a00:	6406                	ld	s0,64(sp)
    80005a02:	74e2                	ld	s1,56(sp)
    80005a04:	7942                	ld	s2,48(sp)
    80005a06:	79a2                	ld	s3,40(sp)
    80005a08:	6ae2                	ld	s5,24(sp)
    80005a0a:	6b42                	ld	s6,16(sp)
    80005a0c:	6161                	addi	sp,sp,80
    80005a0e:	8082                	ret
    iunlockput(ip);
    80005a10:	8556                	mv	a0,s5
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	7f2080e7          	jalr	2034(ra) # 80004204 <iunlockput>
    return 0;
    80005a1a:	4a81                	li	s5,0
    80005a1c:	b7c5                	j	800059fc <create+0x70>
    80005a1e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005a20:	85da                	mv	a1,s6
    80005a22:	4088                	lw	a0,0(s1)
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	3d6080e7          	jalr	982(ra) # 80003dfa <ialloc>
    80005a2c:	8a2a                	mv	s4,a0
    80005a2e:	c531                	beqz	a0,80005a7a <create+0xee>
  ilock(ip);
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	56e080e7          	jalr	1390(ra) # 80003f9e <ilock>
  ip->major = major;
    80005a38:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005a3c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005a40:	4905                	li	s2,1
    80005a42:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005a46:	8552                	mv	a0,s4
    80005a48:	ffffe097          	auipc	ra,0xffffe
    80005a4c:	48a080e7          	jalr	1162(ra) # 80003ed2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005a50:	032b0d63          	beq	s6,s2,80005a8a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a54:	004a2603          	lw	a2,4(s4)
    80005a58:	fb040593          	addi	a1,s0,-80
    80005a5c:	8526                	mv	a0,s1
    80005a5e:	fffff097          	auipc	ra,0xfffff
    80005a62:	c5c080e7          	jalr	-932(ra) # 800046ba <dirlink>
    80005a66:	08054163          	bltz	a0,80005ae8 <create+0x15c>
  iunlockput(dp);
    80005a6a:	8526                	mv	a0,s1
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	798080e7          	jalr	1944(ra) # 80004204 <iunlockput>
  return ip;
    80005a74:	8ad2                	mv	s5,s4
    80005a76:	7a02                	ld	s4,32(sp)
    80005a78:	b751                	j	800059fc <create+0x70>
    iunlockput(dp);
    80005a7a:	8526                	mv	a0,s1
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	788080e7          	jalr	1928(ra) # 80004204 <iunlockput>
    return 0;
    80005a84:	8ad2                	mv	s5,s4
    80005a86:	7a02                	ld	s4,32(sp)
    80005a88:	bf95                	j	800059fc <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a8a:	004a2603          	lw	a2,4(s4)
    80005a8e:	00003597          	auipc	a1,0x3
    80005a92:	cea58593          	addi	a1,a1,-790 # 80008778 <__func__.1+0x770>
    80005a96:	8552                	mv	a0,s4
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	c22080e7          	jalr	-990(ra) # 800046ba <dirlink>
    80005aa0:	04054463          	bltz	a0,80005ae8 <create+0x15c>
    80005aa4:	40d0                	lw	a2,4(s1)
    80005aa6:	00003597          	auipc	a1,0x3
    80005aaa:	cda58593          	addi	a1,a1,-806 # 80008780 <__func__.1+0x778>
    80005aae:	8552                	mv	a0,s4
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	c0a080e7          	jalr	-1014(ra) # 800046ba <dirlink>
    80005ab8:	02054863          	bltz	a0,80005ae8 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005abc:	004a2603          	lw	a2,4(s4)
    80005ac0:	fb040593          	addi	a1,s0,-80
    80005ac4:	8526                	mv	a0,s1
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	bf4080e7          	jalr	-1036(ra) # 800046ba <dirlink>
    80005ace:	00054d63          	bltz	a0,80005ae8 <create+0x15c>
    dp->nlink++;  // for ".."
    80005ad2:	04a4d783          	lhu	a5,74(s1)
    80005ad6:	2785                	addiw	a5,a5,1
    80005ad8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005adc:	8526                	mv	a0,s1
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	3f4080e7          	jalr	1012(ra) # 80003ed2 <iupdate>
    80005ae6:	b751                	j	80005a6a <create+0xde>
  ip->nlink = 0;
    80005ae8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005aec:	8552                	mv	a0,s4
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	3e4080e7          	jalr	996(ra) # 80003ed2 <iupdate>
  iunlockput(ip);
    80005af6:	8552                	mv	a0,s4
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	70c080e7          	jalr	1804(ra) # 80004204 <iunlockput>
  iunlockput(dp);
    80005b00:	8526                	mv	a0,s1
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	702080e7          	jalr	1794(ra) # 80004204 <iunlockput>
  return 0;
    80005b0a:	7a02                	ld	s4,32(sp)
    80005b0c:	bdc5                	j	800059fc <create+0x70>
    return 0;
    80005b0e:	8aaa                	mv	s5,a0
    80005b10:	b5f5                	j	800059fc <create+0x70>

0000000080005b12 <sys_dup>:
{
    80005b12:	7179                	addi	sp,sp,-48
    80005b14:	f406                	sd	ra,40(sp)
    80005b16:	f022                	sd	s0,32(sp)
    80005b18:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005b1a:	fd840613          	addi	a2,s0,-40
    80005b1e:	4581                	li	a1,0
    80005b20:	4501                	li	a0,0
    80005b22:	00000097          	auipc	ra,0x0
    80005b26:	dc8080e7          	jalr	-568(ra) # 800058ea <argfd>
    return -1;
    80005b2a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005b2c:	02054763          	bltz	a0,80005b5a <sys_dup+0x48>
    80005b30:	ec26                	sd	s1,24(sp)
    80005b32:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005b34:	fd843903          	ld	s2,-40(s0)
    80005b38:	854a                	mv	a0,s2
    80005b3a:	00000097          	auipc	ra,0x0
    80005b3e:	e10080e7          	jalr	-496(ra) # 8000594a <fdalloc>
    80005b42:	84aa                	mv	s1,a0
    return -1;
    80005b44:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005b46:	00054f63          	bltz	a0,80005b64 <sys_dup+0x52>
  filedup(f);
    80005b4a:	854a                	mv	a0,s2
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	298080e7          	jalr	664(ra) # 80004de4 <filedup>
  return fd;
    80005b54:	87a6                	mv	a5,s1
    80005b56:	64e2                	ld	s1,24(sp)
    80005b58:	6942                	ld	s2,16(sp)
}
    80005b5a:	853e                	mv	a0,a5
    80005b5c:	70a2                	ld	ra,40(sp)
    80005b5e:	7402                	ld	s0,32(sp)
    80005b60:	6145                	addi	sp,sp,48
    80005b62:	8082                	ret
    80005b64:	64e2                	ld	s1,24(sp)
    80005b66:	6942                	ld	s2,16(sp)
    80005b68:	bfcd                	j	80005b5a <sys_dup+0x48>

0000000080005b6a <sys_read>:
{
    80005b6a:	7179                	addi	sp,sp,-48
    80005b6c:	f406                	sd	ra,40(sp)
    80005b6e:	f022                	sd	s0,32(sp)
    80005b70:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b72:	fd840593          	addi	a1,s0,-40
    80005b76:	4505                	li	a0,1
    80005b78:	ffffd097          	auipc	ra,0xffffd
    80005b7c:	790080e7          	jalr	1936(ra) # 80003308 <argaddr>
  argint(2, &n);
    80005b80:	fe440593          	addi	a1,s0,-28
    80005b84:	4509                	li	a0,2
    80005b86:	ffffd097          	auipc	ra,0xffffd
    80005b8a:	762080e7          	jalr	1890(ra) # 800032e8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005b8e:	fe840613          	addi	a2,s0,-24
    80005b92:	4581                	li	a1,0
    80005b94:	4501                	li	a0,0
    80005b96:	00000097          	auipc	ra,0x0
    80005b9a:	d54080e7          	jalr	-684(ra) # 800058ea <argfd>
    80005b9e:	87aa                	mv	a5,a0
    return -1;
    80005ba0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005ba2:	0007cc63          	bltz	a5,80005bba <sys_read+0x50>
  return fileread(f, p, n);
    80005ba6:	fe442603          	lw	a2,-28(s0)
    80005baa:	fd843583          	ld	a1,-40(s0)
    80005bae:	fe843503          	ld	a0,-24(s0)
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	3d8080e7          	jalr	984(ra) # 80004f8a <fileread>
}
    80005bba:	70a2                	ld	ra,40(sp)
    80005bbc:	7402                	ld	s0,32(sp)
    80005bbe:	6145                	addi	sp,sp,48
    80005bc0:	8082                	ret

0000000080005bc2 <sys_write>:
{
    80005bc2:	7179                	addi	sp,sp,-48
    80005bc4:	f406                	sd	ra,40(sp)
    80005bc6:	f022                	sd	s0,32(sp)
    80005bc8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005bca:	fd840593          	addi	a1,s0,-40
    80005bce:	4505                	li	a0,1
    80005bd0:	ffffd097          	auipc	ra,0xffffd
    80005bd4:	738080e7          	jalr	1848(ra) # 80003308 <argaddr>
  argint(2, &n);
    80005bd8:	fe440593          	addi	a1,s0,-28
    80005bdc:	4509                	li	a0,2
    80005bde:	ffffd097          	auipc	ra,0xffffd
    80005be2:	70a080e7          	jalr	1802(ra) # 800032e8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005be6:	fe840613          	addi	a2,s0,-24
    80005bea:	4581                	li	a1,0
    80005bec:	4501                	li	a0,0
    80005bee:	00000097          	auipc	ra,0x0
    80005bf2:	cfc080e7          	jalr	-772(ra) # 800058ea <argfd>
    80005bf6:	87aa                	mv	a5,a0
    return -1;
    80005bf8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bfa:	0007cc63          	bltz	a5,80005c12 <sys_write+0x50>
  return filewrite(f, p, n);
    80005bfe:	fe442603          	lw	a2,-28(s0)
    80005c02:	fd843583          	ld	a1,-40(s0)
    80005c06:	fe843503          	ld	a0,-24(s0)
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	452080e7          	jalr	1106(ra) # 8000505c <filewrite>
}
    80005c12:	70a2                	ld	ra,40(sp)
    80005c14:	7402                	ld	s0,32(sp)
    80005c16:	6145                	addi	sp,sp,48
    80005c18:	8082                	ret

0000000080005c1a <sys_close>:
{
    80005c1a:	1101                	addi	sp,sp,-32
    80005c1c:	ec06                	sd	ra,24(sp)
    80005c1e:	e822                	sd	s0,16(sp)
    80005c20:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005c22:	fe040613          	addi	a2,s0,-32
    80005c26:	fec40593          	addi	a1,s0,-20
    80005c2a:	4501                	li	a0,0
    80005c2c:	00000097          	auipc	ra,0x0
    80005c30:	cbe080e7          	jalr	-834(ra) # 800058ea <argfd>
    return -1;
    80005c34:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005c36:	02054463          	bltz	a0,80005c5e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005c3a:	ffffc097          	auipc	ra,0xffffc
    80005c3e:	264080e7          	jalr	612(ra) # 80001e9e <myproc>
    80005c42:	fec42783          	lw	a5,-20(s0)
    80005c46:	07e9                	addi	a5,a5,26
    80005c48:	078e                	slli	a5,a5,0x3
    80005c4a:	953e                	add	a0,a0,a5
    80005c4c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005c50:	fe043503          	ld	a0,-32(s0)
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	1e2080e7          	jalr	482(ra) # 80004e36 <fileclose>
  return 0;
    80005c5c:	4781                	li	a5,0
}
    80005c5e:	853e                	mv	a0,a5
    80005c60:	60e2                	ld	ra,24(sp)
    80005c62:	6442                	ld	s0,16(sp)
    80005c64:	6105                	addi	sp,sp,32
    80005c66:	8082                	ret

0000000080005c68 <sys_fstat>:
{
    80005c68:	1101                	addi	sp,sp,-32
    80005c6a:	ec06                	sd	ra,24(sp)
    80005c6c:	e822                	sd	s0,16(sp)
    80005c6e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005c70:	fe040593          	addi	a1,s0,-32
    80005c74:	4505                	li	a0,1
    80005c76:	ffffd097          	auipc	ra,0xffffd
    80005c7a:	692080e7          	jalr	1682(ra) # 80003308 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c7e:	fe840613          	addi	a2,s0,-24
    80005c82:	4581                	li	a1,0
    80005c84:	4501                	li	a0,0
    80005c86:	00000097          	auipc	ra,0x0
    80005c8a:	c64080e7          	jalr	-924(ra) # 800058ea <argfd>
    80005c8e:	87aa                	mv	a5,a0
    return -1;
    80005c90:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c92:	0007ca63          	bltz	a5,80005ca6 <sys_fstat+0x3e>
  return filestat(f, st);
    80005c96:	fe043583          	ld	a1,-32(s0)
    80005c9a:	fe843503          	ld	a0,-24(s0)
    80005c9e:	fffff097          	auipc	ra,0xfffff
    80005ca2:	27a080e7          	jalr	634(ra) # 80004f18 <filestat>
}
    80005ca6:	60e2                	ld	ra,24(sp)
    80005ca8:	6442                	ld	s0,16(sp)
    80005caa:	6105                	addi	sp,sp,32
    80005cac:	8082                	ret

0000000080005cae <sys_link>:
{
    80005cae:	7169                	addi	sp,sp,-304
    80005cb0:	f606                	sd	ra,296(sp)
    80005cb2:	f222                	sd	s0,288(sp)
    80005cb4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cb6:	08000613          	li	a2,128
    80005cba:	ed040593          	addi	a1,s0,-304
    80005cbe:	4501                	li	a0,0
    80005cc0:	ffffd097          	auipc	ra,0xffffd
    80005cc4:	668080e7          	jalr	1640(ra) # 80003328 <argstr>
    return -1;
    80005cc8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cca:	12054663          	bltz	a0,80005df6 <sys_link+0x148>
    80005cce:	08000613          	li	a2,128
    80005cd2:	f5040593          	addi	a1,s0,-176
    80005cd6:	4505                	li	a0,1
    80005cd8:	ffffd097          	auipc	ra,0xffffd
    80005cdc:	650080e7          	jalr	1616(ra) # 80003328 <argstr>
    return -1;
    80005ce0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ce2:	10054a63          	bltz	a0,80005df6 <sys_link+0x148>
    80005ce6:	ee26                	sd	s1,280(sp)
  begin_op();
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	c84080e7          	jalr	-892(ra) # 8000496c <begin_op>
  if((ip = namei(old)) == 0){
    80005cf0:	ed040513          	addi	a0,s0,-304
    80005cf4:	fffff097          	auipc	ra,0xfffff
    80005cf8:	a78080e7          	jalr	-1416(ra) # 8000476c <namei>
    80005cfc:	84aa                	mv	s1,a0
    80005cfe:	c949                	beqz	a0,80005d90 <sys_link+0xe2>
  ilock(ip);
    80005d00:	ffffe097          	auipc	ra,0xffffe
    80005d04:	29e080e7          	jalr	670(ra) # 80003f9e <ilock>
  if(ip->type == T_DIR){
    80005d08:	04449703          	lh	a4,68(s1)
    80005d0c:	4785                	li	a5,1
    80005d0e:	08f70863          	beq	a4,a5,80005d9e <sys_link+0xf0>
    80005d12:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005d14:	04a4d783          	lhu	a5,74(s1)
    80005d18:	2785                	addiw	a5,a5,1
    80005d1a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d1e:	8526                	mv	a0,s1
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	1b2080e7          	jalr	434(ra) # 80003ed2 <iupdate>
  iunlock(ip);
    80005d28:	8526                	mv	a0,s1
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	33a080e7          	jalr	826(ra) # 80004064 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005d32:	fd040593          	addi	a1,s0,-48
    80005d36:	f5040513          	addi	a0,s0,-176
    80005d3a:	fffff097          	auipc	ra,0xfffff
    80005d3e:	a50080e7          	jalr	-1456(ra) # 8000478a <nameiparent>
    80005d42:	892a                	mv	s2,a0
    80005d44:	cd35                	beqz	a0,80005dc0 <sys_link+0x112>
  ilock(dp);
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	258080e7          	jalr	600(ra) # 80003f9e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005d4e:	00092703          	lw	a4,0(s2)
    80005d52:	409c                	lw	a5,0(s1)
    80005d54:	06f71163          	bne	a4,a5,80005db6 <sys_link+0x108>
    80005d58:	40d0                	lw	a2,4(s1)
    80005d5a:	fd040593          	addi	a1,s0,-48
    80005d5e:	854a                	mv	a0,s2
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	95a080e7          	jalr	-1702(ra) # 800046ba <dirlink>
    80005d68:	04054763          	bltz	a0,80005db6 <sys_link+0x108>
  iunlockput(dp);
    80005d6c:	854a                	mv	a0,s2
    80005d6e:	ffffe097          	auipc	ra,0xffffe
    80005d72:	496080e7          	jalr	1174(ra) # 80004204 <iunlockput>
  iput(ip);
    80005d76:	8526                	mv	a0,s1
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	3e4080e7          	jalr	996(ra) # 8000415c <iput>
  end_op();
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	c66080e7          	jalr	-922(ra) # 800049e6 <end_op>
  return 0;
    80005d88:	4781                	li	a5,0
    80005d8a:	64f2                	ld	s1,280(sp)
    80005d8c:	6952                	ld	s2,272(sp)
    80005d8e:	a0a5                	j	80005df6 <sys_link+0x148>
    end_op();
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	c56080e7          	jalr	-938(ra) # 800049e6 <end_op>
    return -1;
    80005d98:	57fd                	li	a5,-1
    80005d9a:	64f2                	ld	s1,280(sp)
    80005d9c:	a8a9                	j	80005df6 <sys_link+0x148>
    iunlockput(ip);
    80005d9e:	8526                	mv	a0,s1
    80005da0:	ffffe097          	auipc	ra,0xffffe
    80005da4:	464080e7          	jalr	1124(ra) # 80004204 <iunlockput>
    end_op();
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	c3e080e7          	jalr	-962(ra) # 800049e6 <end_op>
    return -1;
    80005db0:	57fd                	li	a5,-1
    80005db2:	64f2                	ld	s1,280(sp)
    80005db4:	a089                	j	80005df6 <sys_link+0x148>
    iunlockput(dp);
    80005db6:	854a                	mv	a0,s2
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	44c080e7          	jalr	1100(ra) # 80004204 <iunlockput>
  ilock(ip);
    80005dc0:	8526                	mv	a0,s1
    80005dc2:	ffffe097          	auipc	ra,0xffffe
    80005dc6:	1dc080e7          	jalr	476(ra) # 80003f9e <ilock>
  ip->nlink--;
    80005dca:	04a4d783          	lhu	a5,74(s1)
    80005dce:	37fd                	addiw	a5,a5,-1
    80005dd0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005dd4:	8526                	mv	a0,s1
    80005dd6:	ffffe097          	auipc	ra,0xffffe
    80005dda:	0fc080e7          	jalr	252(ra) # 80003ed2 <iupdate>
  iunlockput(ip);
    80005dde:	8526                	mv	a0,s1
    80005de0:	ffffe097          	auipc	ra,0xffffe
    80005de4:	424080e7          	jalr	1060(ra) # 80004204 <iunlockput>
  end_op();
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	bfe080e7          	jalr	-1026(ra) # 800049e6 <end_op>
  return -1;
    80005df0:	57fd                	li	a5,-1
    80005df2:	64f2                	ld	s1,280(sp)
    80005df4:	6952                	ld	s2,272(sp)
}
    80005df6:	853e                	mv	a0,a5
    80005df8:	70b2                	ld	ra,296(sp)
    80005dfa:	7412                	ld	s0,288(sp)
    80005dfc:	6155                	addi	sp,sp,304
    80005dfe:	8082                	ret

0000000080005e00 <sys_unlink>:
{
    80005e00:	7151                	addi	sp,sp,-240
    80005e02:	f586                	sd	ra,232(sp)
    80005e04:	f1a2                	sd	s0,224(sp)
    80005e06:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005e08:	08000613          	li	a2,128
    80005e0c:	f3040593          	addi	a1,s0,-208
    80005e10:	4501                	li	a0,0
    80005e12:	ffffd097          	auipc	ra,0xffffd
    80005e16:	516080e7          	jalr	1302(ra) # 80003328 <argstr>
    80005e1a:	1a054a63          	bltz	a0,80005fce <sys_unlink+0x1ce>
    80005e1e:	eda6                	sd	s1,216(sp)
  begin_op();
    80005e20:	fffff097          	auipc	ra,0xfffff
    80005e24:	b4c080e7          	jalr	-1204(ra) # 8000496c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005e28:	fb040593          	addi	a1,s0,-80
    80005e2c:	f3040513          	addi	a0,s0,-208
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	95a080e7          	jalr	-1702(ra) # 8000478a <nameiparent>
    80005e38:	84aa                	mv	s1,a0
    80005e3a:	cd71                	beqz	a0,80005f16 <sys_unlink+0x116>
  ilock(dp);
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	162080e7          	jalr	354(ra) # 80003f9e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005e44:	00003597          	auipc	a1,0x3
    80005e48:	93458593          	addi	a1,a1,-1740 # 80008778 <__func__.1+0x770>
    80005e4c:	fb040513          	addi	a0,s0,-80
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	640080e7          	jalr	1600(ra) # 80004490 <namecmp>
    80005e58:	14050c63          	beqz	a0,80005fb0 <sys_unlink+0x1b0>
    80005e5c:	00003597          	auipc	a1,0x3
    80005e60:	92458593          	addi	a1,a1,-1756 # 80008780 <__func__.1+0x778>
    80005e64:	fb040513          	addi	a0,s0,-80
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	628080e7          	jalr	1576(ra) # 80004490 <namecmp>
    80005e70:	14050063          	beqz	a0,80005fb0 <sys_unlink+0x1b0>
    80005e74:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005e76:	f2c40613          	addi	a2,s0,-212
    80005e7a:	fb040593          	addi	a1,s0,-80
    80005e7e:	8526                	mv	a0,s1
    80005e80:	ffffe097          	auipc	ra,0xffffe
    80005e84:	62a080e7          	jalr	1578(ra) # 800044aa <dirlookup>
    80005e88:	892a                	mv	s2,a0
    80005e8a:	12050263          	beqz	a0,80005fae <sys_unlink+0x1ae>
  ilock(ip);
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	110080e7          	jalr	272(ra) # 80003f9e <ilock>
  if(ip->nlink < 1)
    80005e96:	04a91783          	lh	a5,74(s2)
    80005e9a:	08f05563          	blez	a5,80005f24 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e9e:	04491703          	lh	a4,68(s2)
    80005ea2:	4785                	li	a5,1
    80005ea4:	08f70963          	beq	a4,a5,80005f36 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005ea8:	4641                	li	a2,16
    80005eaa:	4581                	li	a1,0
    80005eac:	fc040513          	addi	a0,s0,-64
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	17a080e7          	jalr	378(ra) # 8000102a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005eb8:	4741                	li	a4,16
    80005eba:	f2c42683          	lw	a3,-212(s0)
    80005ebe:	fc040613          	addi	a2,s0,-64
    80005ec2:	4581                	li	a1,0
    80005ec4:	8526                	mv	a0,s1
    80005ec6:	ffffe097          	auipc	ra,0xffffe
    80005eca:	4a0080e7          	jalr	1184(ra) # 80004366 <writei>
    80005ece:	47c1                	li	a5,16
    80005ed0:	0af51b63          	bne	a0,a5,80005f86 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005ed4:	04491703          	lh	a4,68(s2)
    80005ed8:	4785                	li	a5,1
    80005eda:	0af70f63          	beq	a4,a5,80005f98 <sys_unlink+0x198>
  iunlockput(dp);
    80005ede:	8526                	mv	a0,s1
    80005ee0:	ffffe097          	auipc	ra,0xffffe
    80005ee4:	324080e7          	jalr	804(ra) # 80004204 <iunlockput>
  ip->nlink--;
    80005ee8:	04a95783          	lhu	a5,74(s2)
    80005eec:	37fd                	addiw	a5,a5,-1
    80005eee:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ef2:	854a                	mv	a0,s2
    80005ef4:	ffffe097          	auipc	ra,0xffffe
    80005ef8:	fde080e7          	jalr	-34(ra) # 80003ed2 <iupdate>
  iunlockput(ip);
    80005efc:	854a                	mv	a0,s2
    80005efe:	ffffe097          	auipc	ra,0xffffe
    80005f02:	306080e7          	jalr	774(ra) # 80004204 <iunlockput>
  end_op();
    80005f06:	fffff097          	auipc	ra,0xfffff
    80005f0a:	ae0080e7          	jalr	-1312(ra) # 800049e6 <end_op>
  return 0;
    80005f0e:	4501                	li	a0,0
    80005f10:	64ee                	ld	s1,216(sp)
    80005f12:	694e                	ld	s2,208(sp)
    80005f14:	a84d                	j	80005fc6 <sys_unlink+0x1c6>
    end_op();
    80005f16:	fffff097          	auipc	ra,0xfffff
    80005f1a:	ad0080e7          	jalr	-1328(ra) # 800049e6 <end_op>
    return -1;
    80005f1e:	557d                	li	a0,-1
    80005f20:	64ee                	ld	s1,216(sp)
    80005f22:	a055                	j	80005fc6 <sys_unlink+0x1c6>
    80005f24:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005f26:	00003517          	auipc	a0,0x3
    80005f2a:	86250513          	addi	a0,a0,-1950 # 80008788 <__func__.1+0x780>
    80005f2e:	ffffa097          	auipc	ra,0xffffa
    80005f32:	632080e7          	jalr	1586(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f36:	04c92703          	lw	a4,76(s2)
    80005f3a:	02000793          	li	a5,32
    80005f3e:	f6e7f5e3          	bgeu	a5,a4,80005ea8 <sys_unlink+0xa8>
    80005f42:	e5ce                	sd	s3,200(sp)
    80005f44:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f48:	4741                	li	a4,16
    80005f4a:	86ce                	mv	a3,s3
    80005f4c:	f1840613          	addi	a2,s0,-232
    80005f50:	4581                	li	a1,0
    80005f52:	854a                	mv	a0,s2
    80005f54:	ffffe097          	auipc	ra,0xffffe
    80005f58:	302080e7          	jalr	770(ra) # 80004256 <readi>
    80005f5c:	47c1                	li	a5,16
    80005f5e:	00f51c63          	bne	a0,a5,80005f76 <sys_unlink+0x176>
    if(de.inum != 0)
    80005f62:	f1845783          	lhu	a5,-232(s0)
    80005f66:	e7b5                	bnez	a5,80005fd2 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f68:	29c1                	addiw	s3,s3,16
    80005f6a:	04c92783          	lw	a5,76(s2)
    80005f6e:	fcf9ede3          	bltu	s3,a5,80005f48 <sys_unlink+0x148>
    80005f72:	69ae                	ld	s3,200(sp)
    80005f74:	bf15                	j	80005ea8 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005f76:	00003517          	auipc	a0,0x3
    80005f7a:	82a50513          	addi	a0,a0,-2006 # 800087a0 <__func__.1+0x798>
    80005f7e:	ffffa097          	auipc	ra,0xffffa
    80005f82:	5e2080e7          	jalr	1506(ra) # 80000560 <panic>
    80005f86:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005f88:	00003517          	auipc	a0,0x3
    80005f8c:	83050513          	addi	a0,a0,-2000 # 800087b8 <__func__.1+0x7b0>
    80005f90:	ffffa097          	auipc	ra,0xffffa
    80005f94:	5d0080e7          	jalr	1488(ra) # 80000560 <panic>
    dp->nlink--;
    80005f98:	04a4d783          	lhu	a5,74(s1)
    80005f9c:	37fd                	addiw	a5,a5,-1
    80005f9e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005fa2:	8526                	mv	a0,s1
    80005fa4:	ffffe097          	auipc	ra,0xffffe
    80005fa8:	f2e080e7          	jalr	-210(ra) # 80003ed2 <iupdate>
    80005fac:	bf0d                	j	80005ede <sys_unlink+0xde>
    80005fae:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005fb0:	8526                	mv	a0,s1
    80005fb2:	ffffe097          	auipc	ra,0xffffe
    80005fb6:	252080e7          	jalr	594(ra) # 80004204 <iunlockput>
  end_op();
    80005fba:	fffff097          	auipc	ra,0xfffff
    80005fbe:	a2c080e7          	jalr	-1492(ra) # 800049e6 <end_op>
  return -1;
    80005fc2:	557d                	li	a0,-1
    80005fc4:	64ee                	ld	s1,216(sp)
}
    80005fc6:	70ae                	ld	ra,232(sp)
    80005fc8:	740e                	ld	s0,224(sp)
    80005fca:	616d                	addi	sp,sp,240
    80005fcc:	8082                	ret
    return -1;
    80005fce:	557d                	li	a0,-1
    80005fd0:	bfdd                	j	80005fc6 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005fd2:	854a                	mv	a0,s2
    80005fd4:	ffffe097          	auipc	ra,0xffffe
    80005fd8:	230080e7          	jalr	560(ra) # 80004204 <iunlockput>
    goto bad;
    80005fdc:	694e                	ld	s2,208(sp)
    80005fde:	69ae                	ld	s3,200(sp)
    80005fe0:	bfc1                	j	80005fb0 <sys_unlink+0x1b0>

0000000080005fe2 <sys_open>:

uint64
sys_open(void)
{
    80005fe2:	7131                	addi	sp,sp,-192
    80005fe4:	fd06                	sd	ra,184(sp)
    80005fe6:	f922                	sd	s0,176(sp)
    80005fe8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005fea:	f4c40593          	addi	a1,s0,-180
    80005fee:	4505                	li	a0,1
    80005ff0:	ffffd097          	auipc	ra,0xffffd
    80005ff4:	2f8080e7          	jalr	760(ra) # 800032e8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ff8:	08000613          	li	a2,128
    80005ffc:	f5040593          	addi	a1,s0,-176
    80006000:	4501                	li	a0,0
    80006002:	ffffd097          	auipc	ra,0xffffd
    80006006:	326080e7          	jalr	806(ra) # 80003328 <argstr>
    8000600a:	87aa                	mv	a5,a0
    return -1;
    8000600c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000600e:	0a07ce63          	bltz	a5,800060ca <sys_open+0xe8>
    80006012:	f526                	sd	s1,168(sp)

  begin_op();
    80006014:	fffff097          	auipc	ra,0xfffff
    80006018:	958080e7          	jalr	-1704(ra) # 8000496c <begin_op>

  if(omode & O_CREATE){
    8000601c:	f4c42783          	lw	a5,-180(s0)
    80006020:	2007f793          	andi	a5,a5,512
    80006024:	cfd5                	beqz	a5,800060e0 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006026:	4681                	li	a3,0
    80006028:	4601                	li	a2,0
    8000602a:	4589                	li	a1,2
    8000602c:	f5040513          	addi	a0,s0,-176
    80006030:	00000097          	auipc	ra,0x0
    80006034:	95c080e7          	jalr	-1700(ra) # 8000598c <create>
    80006038:	84aa                	mv	s1,a0
    if(ip == 0){
    8000603a:	cd41                	beqz	a0,800060d2 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000603c:	04449703          	lh	a4,68(s1)
    80006040:	478d                	li	a5,3
    80006042:	00f71763          	bne	a4,a5,80006050 <sys_open+0x6e>
    80006046:	0464d703          	lhu	a4,70(s1)
    8000604a:	47a5                	li	a5,9
    8000604c:	0ee7e163          	bltu	a5,a4,8000612e <sys_open+0x14c>
    80006050:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006052:	fffff097          	auipc	ra,0xfffff
    80006056:	d28080e7          	jalr	-728(ra) # 80004d7a <filealloc>
    8000605a:	892a                	mv	s2,a0
    8000605c:	c97d                	beqz	a0,80006152 <sys_open+0x170>
    8000605e:	ed4e                	sd	s3,152(sp)
    80006060:	00000097          	auipc	ra,0x0
    80006064:	8ea080e7          	jalr	-1814(ra) # 8000594a <fdalloc>
    80006068:	89aa                	mv	s3,a0
    8000606a:	0c054e63          	bltz	a0,80006146 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000606e:	04449703          	lh	a4,68(s1)
    80006072:	478d                	li	a5,3
    80006074:	0ef70c63          	beq	a4,a5,8000616c <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006078:	4789                	li	a5,2
    8000607a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000607e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006082:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006086:	f4c42783          	lw	a5,-180(s0)
    8000608a:	0017c713          	xori	a4,a5,1
    8000608e:	8b05                	andi	a4,a4,1
    80006090:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006094:	0037f713          	andi	a4,a5,3
    80006098:	00e03733          	snez	a4,a4
    8000609c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800060a0:	4007f793          	andi	a5,a5,1024
    800060a4:	c791                	beqz	a5,800060b0 <sys_open+0xce>
    800060a6:	04449703          	lh	a4,68(s1)
    800060aa:	4789                	li	a5,2
    800060ac:	0cf70763          	beq	a4,a5,8000617a <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    800060b0:	8526                	mv	a0,s1
    800060b2:	ffffe097          	auipc	ra,0xffffe
    800060b6:	fb2080e7          	jalr	-78(ra) # 80004064 <iunlock>
  end_op();
    800060ba:	fffff097          	auipc	ra,0xfffff
    800060be:	92c080e7          	jalr	-1748(ra) # 800049e6 <end_op>

  return fd;
    800060c2:	854e                	mv	a0,s3
    800060c4:	74aa                	ld	s1,168(sp)
    800060c6:	790a                	ld	s2,160(sp)
    800060c8:	69ea                	ld	s3,152(sp)
}
    800060ca:	70ea                	ld	ra,184(sp)
    800060cc:	744a                	ld	s0,176(sp)
    800060ce:	6129                	addi	sp,sp,192
    800060d0:	8082                	ret
      end_op();
    800060d2:	fffff097          	auipc	ra,0xfffff
    800060d6:	914080e7          	jalr	-1772(ra) # 800049e6 <end_op>
      return -1;
    800060da:	557d                	li	a0,-1
    800060dc:	74aa                	ld	s1,168(sp)
    800060de:	b7f5                	j	800060ca <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    800060e0:	f5040513          	addi	a0,s0,-176
    800060e4:	ffffe097          	auipc	ra,0xffffe
    800060e8:	688080e7          	jalr	1672(ra) # 8000476c <namei>
    800060ec:	84aa                	mv	s1,a0
    800060ee:	c90d                	beqz	a0,80006120 <sys_open+0x13e>
    ilock(ip);
    800060f0:	ffffe097          	auipc	ra,0xffffe
    800060f4:	eae080e7          	jalr	-338(ra) # 80003f9e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800060f8:	04449703          	lh	a4,68(s1)
    800060fc:	4785                	li	a5,1
    800060fe:	f2f71fe3          	bne	a4,a5,8000603c <sys_open+0x5a>
    80006102:	f4c42783          	lw	a5,-180(s0)
    80006106:	d7a9                	beqz	a5,80006050 <sys_open+0x6e>
      iunlockput(ip);
    80006108:	8526                	mv	a0,s1
    8000610a:	ffffe097          	auipc	ra,0xffffe
    8000610e:	0fa080e7          	jalr	250(ra) # 80004204 <iunlockput>
      end_op();
    80006112:	fffff097          	auipc	ra,0xfffff
    80006116:	8d4080e7          	jalr	-1836(ra) # 800049e6 <end_op>
      return -1;
    8000611a:	557d                	li	a0,-1
    8000611c:	74aa                	ld	s1,168(sp)
    8000611e:	b775                	j	800060ca <sys_open+0xe8>
      end_op();
    80006120:	fffff097          	auipc	ra,0xfffff
    80006124:	8c6080e7          	jalr	-1850(ra) # 800049e6 <end_op>
      return -1;
    80006128:	557d                	li	a0,-1
    8000612a:	74aa                	ld	s1,168(sp)
    8000612c:	bf79                	j	800060ca <sys_open+0xe8>
    iunlockput(ip);
    8000612e:	8526                	mv	a0,s1
    80006130:	ffffe097          	auipc	ra,0xffffe
    80006134:	0d4080e7          	jalr	212(ra) # 80004204 <iunlockput>
    end_op();
    80006138:	fffff097          	auipc	ra,0xfffff
    8000613c:	8ae080e7          	jalr	-1874(ra) # 800049e6 <end_op>
    return -1;
    80006140:	557d                	li	a0,-1
    80006142:	74aa                	ld	s1,168(sp)
    80006144:	b759                	j	800060ca <sys_open+0xe8>
      fileclose(f);
    80006146:	854a                	mv	a0,s2
    80006148:	fffff097          	auipc	ra,0xfffff
    8000614c:	cee080e7          	jalr	-786(ra) # 80004e36 <fileclose>
    80006150:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006152:	8526                	mv	a0,s1
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	0b0080e7          	jalr	176(ra) # 80004204 <iunlockput>
    end_op();
    8000615c:	fffff097          	auipc	ra,0xfffff
    80006160:	88a080e7          	jalr	-1910(ra) # 800049e6 <end_op>
    return -1;
    80006164:	557d                	li	a0,-1
    80006166:	74aa                	ld	s1,168(sp)
    80006168:	790a                	ld	s2,160(sp)
    8000616a:	b785                	j	800060ca <sys_open+0xe8>
    f->type = FD_DEVICE;
    8000616c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006170:	04649783          	lh	a5,70(s1)
    80006174:	02f91223          	sh	a5,36(s2)
    80006178:	b729                	j	80006082 <sys_open+0xa0>
    itrunc(ip);
    8000617a:	8526                	mv	a0,s1
    8000617c:	ffffe097          	auipc	ra,0xffffe
    80006180:	f34080e7          	jalr	-204(ra) # 800040b0 <itrunc>
    80006184:	b735                	j	800060b0 <sys_open+0xce>

0000000080006186 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006186:	7175                	addi	sp,sp,-144
    80006188:	e506                	sd	ra,136(sp)
    8000618a:	e122                	sd	s0,128(sp)
    8000618c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000618e:	ffffe097          	auipc	ra,0xffffe
    80006192:	7de080e7          	jalr	2014(ra) # 8000496c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006196:	08000613          	li	a2,128
    8000619a:	f7040593          	addi	a1,s0,-144
    8000619e:	4501                	li	a0,0
    800061a0:	ffffd097          	auipc	ra,0xffffd
    800061a4:	188080e7          	jalr	392(ra) # 80003328 <argstr>
    800061a8:	02054963          	bltz	a0,800061da <sys_mkdir+0x54>
    800061ac:	4681                	li	a3,0
    800061ae:	4601                	li	a2,0
    800061b0:	4585                	li	a1,1
    800061b2:	f7040513          	addi	a0,s0,-144
    800061b6:	fffff097          	auipc	ra,0xfffff
    800061ba:	7d6080e7          	jalr	2006(ra) # 8000598c <create>
    800061be:	cd11                	beqz	a0,800061da <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061c0:	ffffe097          	auipc	ra,0xffffe
    800061c4:	044080e7          	jalr	68(ra) # 80004204 <iunlockput>
  end_op();
    800061c8:	fffff097          	auipc	ra,0xfffff
    800061cc:	81e080e7          	jalr	-2018(ra) # 800049e6 <end_op>
  return 0;
    800061d0:	4501                	li	a0,0
}
    800061d2:	60aa                	ld	ra,136(sp)
    800061d4:	640a                	ld	s0,128(sp)
    800061d6:	6149                	addi	sp,sp,144
    800061d8:	8082                	ret
    end_op();
    800061da:	fffff097          	auipc	ra,0xfffff
    800061de:	80c080e7          	jalr	-2036(ra) # 800049e6 <end_op>
    return -1;
    800061e2:	557d                	li	a0,-1
    800061e4:	b7fd                	j	800061d2 <sys_mkdir+0x4c>

00000000800061e6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800061e6:	7135                	addi	sp,sp,-160
    800061e8:	ed06                	sd	ra,152(sp)
    800061ea:	e922                	sd	s0,144(sp)
    800061ec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800061ee:	ffffe097          	auipc	ra,0xffffe
    800061f2:	77e080e7          	jalr	1918(ra) # 8000496c <begin_op>
  argint(1, &major);
    800061f6:	f6c40593          	addi	a1,s0,-148
    800061fa:	4505                	li	a0,1
    800061fc:	ffffd097          	auipc	ra,0xffffd
    80006200:	0ec080e7          	jalr	236(ra) # 800032e8 <argint>
  argint(2, &minor);
    80006204:	f6840593          	addi	a1,s0,-152
    80006208:	4509                	li	a0,2
    8000620a:	ffffd097          	auipc	ra,0xffffd
    8000620e:	0de080e7          	jalr	222(ra) # 800032e8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006212:	08000613          	li	a2,128
    80006216:	f7040593          	addi	a1,s0,-144
    8000621a:	4501                	li	a0,0
    8000621c:	ffffd097          	auipc	ra,0xffffd
    80006220:	10c080e7          	jalr	268(ra) # 80003328 <argstr>
    80006224:	02054b63          	bltz	a0,8000625a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006228:	f6841683          	lh	a3,-152(s0)
    8000622c:	f6c41603          	lh	a2,-148(s0)
    80006230:	458d                	li	a1,3
    80006232:	f7040513          	addi	a0,s0,-144
    80006236:	fffff097          	auipc	ra,0xfffff
    8000623a:	756080e7          	jalr	1878(ra) # 8000598c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000623e:	cd11                	beqz	a0,8000625a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006240:	ffffe097          	auipc	ra,0xffffe
    80006244:	fc4080e7          	jalr	-60(ra) # 80004204 <iunlockput>
  end_op();
    80006248:	ffffe097          	auipc	ra,0xffffe
    8000624c:	79e080e7          	jalr	1950(ra) # 800049e6 <end_op>
  return 0;
    80006250:	4501                	li	a0,0
}
    80006252:	60ea                	ld	ra,152(sp)
    80006254:	644a                	ld	s0,144(sp)
    80006256:	610d                	addi	sp,sp,160
    80006258:	8082                	ret
    end_op();
    8000625a:	ffffe097          	auipc	ra,0xffffe
    8000625e:	78c080e7          	jalr	1932(ra) # 800049e6 <end_op>
    return -1;
    80006262:	557d                	li	a0,-1
    80006264:	b7fd                	j	80006252 <sys_mknod+0x6c>

0000000080006266 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006266:	7135                	addi	sp,sp,-160
    80006268:	ed06                	sd	ra,152(sp)
    8000626a:	e922                	sd	s0,144(sp)
    8000626c:	e14a                	sd	s2,128(sp)
    8000626e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006270:	ffffc097          	auipc	ra,0xffffc
    80006274:	c2e080e7          	jalr	-978(ra) # 80001e9e <myproc>
    80006278:	892a                	mv	s2,a0
  
  begin_op();
    8000627a:	ffffe097          	auipc	ra,0xffffe
    8000627e:	6f2080e7          	jalr	1778(ra) # 8000496c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006282:	08000613          	li	a2,128
    80006286:	f6040593          	addi	a1,s0,-160
    8000628a:	4501                	li	a0,0
    8000628c:	ffffd097          	auipc	ra,0xffffd
    80006290:	09c080e7          	jalr	156(ra) # 80003328 <argstr>
    80006294:	04054d63          	bltz	a0,800062ee <sys_chdir+0x88>
    80006298:	e526                	sd	s1,136(sp)
    8000629a:	f6040513          	addi	a0,s0,-160
    8000629e:	ffffe097          	auipc	ra,0xffffe
    800062a2:	4ce080e7          	jalr	1230(ra) # 8000476c <namei>
    800062a6:	84aa                	mv	s1,a0
    800062a8:	c131                	beqz	a0,800062ec <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800062aa:	ffffe097          	auipc	ra,0xffffe
    800062ae:	cf4080e7          	jalr	-780(ra) # 80003f9e <ilock>
  if(ip->type != T_DIR){
    800062b2:	04449703          	lh	a4,68(s1)
    800062b6:	4785                	li	a5,1
    800062b8:	04f71163          	bne	a4,a5,800062fa <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800062bc:	8526                	mv	a0,s1
    800062be:	ffffe097          	auipc	ra,0xffffe
    800062c2:	da6080e7          	jalr	-602(ra) # 80004064 <iunlock>
  iput(p->cwd);
    800062c6:	15093503          	ld	a0,336(s2)
    800062ca:	ffffe097          	auipc	ra,0xffffe
    800062ce:	e92080e7          	jalr	-366(ra) # 8000415c <iput>
  end_op();
    800062d2:	ffffe097          	auipc	ra,0xffffe
    800062d6:	714080e7          	jalr	1812(ra) # 800049e6 <end_op>
  p->cwd = ip;
    800062da:	14993823          	sd	s1,336(s2)
  return 0;
    800062de:	4501                	li	a0,0
    800062e0:	64aa                	ld	s1,136(sp)
}
    800062e2:	60ea                	ld	ra,152(sp)
    800062e4:	644a                	ld	s0,144(sp)
    800062e6:	690a                	ld	s2,128(sp)
    800062e8:	610d                	addi	sp,sp,160
    800062ea:	8082                	ret
    800062ec:	64aa                	ld	s1,136(sp)
    end_op();
    800062ee:	ffffe097          	auipc	ra,0xffffe
    800062f2:	6f8080e7          	jalr	1784(ra) # 800049e6 <end_op>
    return -1;
    800062f6:	557d                	li	a0,-1
    800062f8:	b7ed                	j	800062e2 <sys_chdir+0x7c>
    iunlockput(ip);
    800062fa:	8526                	mv	a0,s1
    800062fc:	ffffe097          	auipc	ra,0xffffe
    80006300:	f08080e7          	jalr	-248(ra) # 80004204 <iunlockput>
    end_op();
    80006304:	ffffe097          	auipc	ra,0xffffe
    80006308:	6e2080e7          	jalr	1762(ra) # 800049e6 <end_op>
    return -1;
    8000630c:	557d                	li	a0,-1
    8000630e:	64aa                	ld	s1,136(sp)
    80006310:	bfc9                	j	800062e2 <sys_chdir+0x7c>

0000000080006312 <sys_exec>:

uint64
sys_exec(void)
{
    80006312:	7121                	addi	sp,sp,-448
    80006314:	ff06                	sd	ra,440(sp)
    80006316:	fb22                	sd	s0,432(sp)
    80006318:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000631a:	e4840593          	addi	a1,s0,-440
    8000631e:	4505                	li	a0,1
    80006320:	ffffd097          	auipc	ra,0xffffd
    80006324:	fe8080e7          	jalr	-24(ra) # 80003308 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006328:	08000613          	li	a2,128
    8000632c:	f5040593          	addi	a1,s0,-176
    80006330:	4501                	li	a0,0
    80006332:	ffffd097          	auipc	ra,0xffffd
    80006336:	ff6080e7          	jalr	-10(ra) # 80003328 <argstr>
    8000633a:	87aa                	mv	a5,a0
    return -1;
    8000633c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000633e:	0e07c263          	bltz	a5,80006422 <sys_exec+0x110>
    80006342:	f726                	sd	s1,424(sp)
    80006344:	f34a                	sd	s2,416(sp)
    80006346:	ef4e                	sd	s3,408(sp)
    80006348:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000634a:	10000613          	li	a2,256
    8000634e:	4581                	li	a1,0
    80006350:	e5040513          	addi	a0,s0,-432
    80006354:	ffffb097          	auipc	ra,0xffffb
    80006358:	cd6080e7          	jalr	-810(ra) # 8000102a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000635c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80006360:	89a6                	mv	s3,s1
    80006362:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006364:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006368:	00391513          	slli	a0,s2,0x3
    8000636c:	e4040593          	addi	a1,s0,-448
    80006370:	e4843783          	ld	a5,-440(s0)
    80006374:	953e                	add	a0,a0,a5
    80006376:	ffffd097          	auipc	ra,0xffffd
    8000637a:	ed4080e7          	jalr	-300(ra) # 8000324a <fetchaddr>
    8000637e:	02054a63          	bltz	a0,800063b2 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006382:	e4043783          	ld	a5,-448(s0)
    80006386:	c7b9                	beqz	a5,800063d4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006388:	ffffb097          	auipc	ra,0xffffb
    8000638c:	8f2080e7          	jalr	-1806(ra) # 80000c7a <kalloc>
    80006390:	85aa                	mv	a1,a0
    80006392:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006396:	cd11                	beqz	a0,800063b2 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006398:	6605                	lui	a2,0x1
    8000639a:	e4043503          	ld	a0,-448(s0)
    8000639e:	ffffd097          	auipc	ra,0xffffd
    800063a2:	efe080e7          	jalr	-258(ra) # 8000329c <fetchstr>
    800063a6:	00054663          	bltz	a0,800063b2 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    800063aa:	0905                	addi	s2,s2,1
    800063ac:	09a1                	addi	s3,s3,8
    800063ae:	fb491de3          	bne	s2,s4,80006368 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063b2:	f5040913          	addi	s2,s0,-176
    800063b6:	6088                	ld	a0,0(s1)
    800063b8:	c125                	beqz	a0,80006418 <sys_exec+0x106>
    kfree(argv[i]);
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	6ce080e7          	jalr	1742(ra) # 80000a88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063c2:	04a1                	addi	s1,s1,8
    800063c4:	ff2499e3          	bne	s1,s2,800063b6 <sys_exec+0xa4>
  return -1;
    800063c8:	557d                	li	a0,-1
    800063ca:	74ba                	ld	s1,424(sp)
    800063cc:	791a                	ld	s2,416(sp)
    800063ce:	69fa                	ld	s3,408(sp)
    800063d0:	6a5a                	ld	s4,400(sp)
    800063d2:	a881                	j	80006422 <sys_exec+0x110>
      argv[i] = 0;
    800063d4:	0009079b          	sext.w	a5,s2
    800063d8:	078e                	slli	a5,a5,0x3
    800063da:	fd078793          	addi	a5,a5,-48
    800063de:	97a2                	add	a5,a5,s0
    800063e0:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800063e4:	e5040593          	addi	a1,s0,-432
    800063e8:	f5040513          	addi	a0,s0,-176
    800063ec:	fffff097          	auipc	ra,0xfffff
    800063f0:	120080e7          	jalr	288(ra) # 8000550c <exec>
    800063f4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063f6:	f5040993          	addi	s3,s0,-176
    800063fa:	6088                	ld	a0,0(s1)
    800063fc:	c901                	beqz	a0,8000640c <sys_exec+0xfa>
    kfree(argv[i]);
    800063fe:	ffffa097          	auipc	ra,0xffffa
    80006402:	68a080e7          	jalr	1674(ra) # 80000a88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006406:	04a1                	addi	s1,s1,8
    80006408:	ff3499e3          	bne	s1,s3,800063fa <sys_exec+0xe8>
  return ret;
    8000640c:	854a                	mv	a0,s2
    8000640e:	74ba                	ld	s1,424(sp)
    80006410:	791a                	ld	s2,416(sp)
    80006412:	69fa                	ld	s3,408(sp)
    80006414:	6a5a                	ld	s4,400(sp)
    80006416:	a031                	j	80006422 <sys_exec+0x110>
  return -1;
    80006418:	557d                	li	a0,-1
    8000641a:	74ba                	ld	s1,424(sp)
    8000641c:	791a                	ld	s2,416(sp)
    8000641e:	69fa                	ld	s3,408(sp)
    80006420:	6a5a                	ld	s4,400(sp)
}
    80006422:	70fa                	ld	ra,440(sp)
    80006424:	745a                	ld	s0,432(sp)
    80006426:	6139                	addi	sp,sp,448
    80006428:	8082                	ret

000000008000642a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000642a:	7139                	addi	sp,sp,-64
    8000642c:	fc06                	sd	ra,56(sp)
    8000642e:	f822                	sd	s0,48(sp)
    80006430:	f426                	sd	s1,40(sp)
    80006432:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006434:	ffffc097          	auipc	ra,0xffffc
    80006438:	a6a080e7          	jalr	-1430(ra) # 80001e9e <myproc>
    8000643c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000643e:	fd840593          	addi	a1,s0,-40
    80006442:	4501                	li	a0,0
    80006444:	ffffd097          	auipc	ra,0xffffd
    80006448:	ec4080e7          	jalr	-316(ra) # 80003308 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000644c:	fc840593          	addi	a1,s0,-56
    80006450:	fd040513          	addi	a0,s0,-48
    80006454:	fffff097          	auipc	ra,0xfffff
    80006458:	d50080e7          	jalr	-688(ra) # 800051a4 <pipealloc>
    return -1;
    8000645c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000645e:	0c054463          	bltz	a0,80006526 <sys_pipe+0xfc>
  fd0 = -1;
    80006462:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006466:	fd043503          	ld	a0,-48(s0)
    8000646a:	fffff097          	auipc	ra,0xfffff
    8000646e:	4e0080e7          	jalr	1248(ra) # 8000594a <fdalloc>
    80006472:	fca42223          	sw	a0,-60(s0)
    80006476:	08054b63          	bltz	a0,8000650c <sys_pipe+0xe2>
    8000647a:	fc843503          	ld	a0,-56(s0)
    8000647e:	fffff097          	auipc	ra,0xfffff
    80006482:	4cc080e7          	jalr	1228(ra) # 8000594a <fdalloc>
    80006486:	fca42023          	sw	a0,-64(s0)
    8000648a:	06054863          	bltz	a0,800064fa <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000648e:	4691                	li	a3,4
    80006490:	fc440613          	addi	a2,s0,-60
    80006494:	fd843583          	ld	a1,-40(s0)
    80006498:	68a8                	ld	a0,80(s1)
    8000649a:	ffffb097          	auipc	ra,0xffffb
    8000649e:	54c080e7          	jalr	1356(ra) # 800019e6 <copyout>
    800064a2:	02054063          	bltz	a0,800064c2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800064a6:	4691                	li	a3,4
    800064a8:	fc040613          	addi	a2,s0,-64
    800064ac:	fd843583          	ld	a1,-40(s0)
    800064b0:	0591                	addi	a1,a1,4
    800064b2:	68a8                	ld	a0,80(s1)
    800064b4:	ffffb097          	auipc	ra,0xffffb
    800064b8:	532080e7          	jalr	1330(ra) # 800019e6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800064bc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064be:	06055463          	bgez	a0,80006526 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800064c2:	fc442783          	lw	a5,-60(s0)
    800064c6:	07e9                	addi	a5,a5,26
    800064c8:	078e                	slli	a5,a5,0x3
    800064ca:	97a6                	add	a5,a5,s1
    800064cc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800064d0:	fc042783          	lw	a5,-64(s0)
    800064d4:	07e9                	addi	a5,a5,26
    800064d6:	078e                	slli	a5,a5,0x3
    800064d8:	94be                	add	s1,s1,a5
    800064da:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800064de:	fd043503          	ld	a0,-48(s0)
    800064e2:	fffff097          	auipc	ra,0xfffff
    800064e6:	954080e7          	jalr	-1708(ra) # 80004e36 <fileclose>
    fileclose(wf);
    800064ea:	fc843503          	ld	a0,-56(s0)
    800064ee:	fffff097          	auipc	ra,0xfffff
    800064f2:	948080e7          	jalr	-1720(ra) # 80004e36 <fileclose>
    return -1;
    800064f6:	57fd                	li	a5,-1
    800064f8:	a03d                	j	80006526 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800064fa:	fc442783          	lw	a5,-60(s0)
    800064fe:	0007c763          	bltz	a5,8000650c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006502:	07e9                	addi	a5,a5,26
    80006504:	078e                	slli	a5,a5,0x3
    80006506:	97a6                	add	a5,a5,s1
    80006508:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000650c:	fd043503          	ld	a0,-48(s0)
    80006510:	fffff097          	auipc	ra,0xfffff
    80006514:	926080e7          	jalr	-1754(ra) # 80004e36 <fileclose>
    fileclose(wf);
    80006518:	fc843503          	ld	a0,-56(s0)
    8000651c:	fffff097          	auipc	ra,0xfffff
    80006520:	91a080e7          	jalr	-1766(ra) # 80004e36 <fileclose>
    return -1;
    80006524:	57fd                	li	a5,-1
}
    80006526:	853e                	mv	a0,a5
    80006528:	70e2                	ld	ra,56(sp)
    8000652a:	7442                	ld	s0,48(sp)
    8000652c:	74a2                	ld	s1,40(sp)
    8000652e:	6121                	addi	sp,sp,64
    80006530:	8082                	ret
	...

0000000080006540 <kernelvec>:
    80006540:	7111                	addi	sp,sp,-256
    80006542:	e006                	sd	ra,0(sp)
    80006544:	e40a                	sd	sp,8(sp)
    80006546:	e80e                	sd	gp,16(sp)
    80006548:	ec12                	sd	tp,24(sp)
    8000654a:	f016                	sd	t0,32(sp)
    8000654c:	f41a                	sd	t1,40(sp)
    8000654e:	f81e                	sd	t2,48(sp)
    80006550:	fc22                	sd	s0,56(sp)
    80006552:	e0a6                	sd	s1,64(sp)
    80006554:	e4aa                	sd	a0,72(sp)
    80006556:	e8ae                	sd	a1,80(sp)
    80006558:	ecb2                	sd	a2,88(sp)
    8000655a:	f0b6                	sd	a3,96(sp)
    8000655c:	f4ba                	sd	a4,104(sp)
    8000655e:	f8be                	sd	a5,112(sp)
    80006560:	fcc2                	sd	a6,120(sp)
    80006562:	e146                	sd	a7,128(sp)
    80006564:	e54a                	sd	s2,136(sp)
    80006566:	e94e                	sd	s3,144(sp)
    80006568:	ed52                	sd	s4,152(sp)
    8000656a:	f156                	sd	s5,160(sp)
    8000656c:	f55a                	sd	s6,168(sp)
    8000656e:	f95e                	sd	s7,176(sp)
    80006570:	fd62                	sd	s8,184(sp)
    80006572:	e1e6                	sd	s9,192(sp)
    80006574:	e5ea                	sd	s10,200(sp)
    80006576:	e9ee                	sd	s11,208(sp)
    80006578:	edf2                	sd	t3,216(sp)
    8000657a:	f1f6                	sd	t4,224(sp)
    8000657c:	f5fa                	sd	t5,232(sp)
    8000657e:	f9fe                	sd	t6,240(sp)
    80006580:	b97fc0ef          	jal	80003116 <kerneltrap>
    80006584:	6082                	ld	ra,0(sp)
    80006586:	6122                	ld	sp,8(sp)
    80006588:	61c2                	ld	gp,16(sp)
    8000658a:	7282                	ld	t0,32(sp)
    8000658c:	7322                	ld	t1,40(sp)
    8000658e:	73c2                	ld	t2,48(sp)
    80006590:	7462                	ld	s0,56(sp)
    80006592:	6486                	ld	s1,64(sp)
    80006594:	6526                	ld	a0,72(sp)
    80006596:	65c6                	ld	a1,80(sp)
    80006598:	6666                	ld	a2,88(sp)
    8000659a:	7686                	ld	a3,96(sp)
    8000659c:	7726                	ld	a4,104(sp)
    8000659e:	77c6                	ld	a5,112(sp)
    800065a0:	7866                	ld	a6,120(sp)
    800065a2:	688a                	ld	a7,128(sp)
    800065a4:	692a                	ld	s2,136(sp)
    800065a6:	69ca                	ld	s3,144(sp)
    800065a8:	6a6a                	ld	s4,152(sp)
    800065aa:	7a8a                	ld	s5,160(sp)
    800065ac:	7b2a                	ld	s6,168(sp)
    800065ae:	7bca                	ld	s7,176(sp)
    800065b0:	7c6a                	ld	s8,184(sp)
    800065b2:	6c8e                	ld	s9,192(sp)
    800065b4:	6d2e                	ld	s10,200(sp)
    800065b6:	6dce                	ld	s11,208(sp)
    800065b8:	6e6e                	ld	t3,216(sp)
    800065ba:	7e8e                	ld	t4,224(sp)
    800065bc:	7f2e                	ld	t5,232(sp)
    800065be:	7fce                	ld	t6,240(sp)
    800065c0:	6111                	addi	sp,sp,256
    800065c2:	10200073          	sret
    800065c6:	00000013          	nop
    800065ca:	00000013          	nop
    800065ce:	0001                	nop

00000000800065d0 <timervec>:
    800065d0:	34051573          	csrrw	a0,mscratch,a0
    800065d4:	e10c                	sd	a1,0(a0)
    800065d6:	e510                	sd	a2,8(a0)
    800065d8:	e914                	sd	a3,16(a0)
    800065da:	6d0c                	ld	a1,24(a0)
    800065dc:	7110                	ld	a2,32(a0)
    800065de:	6194                	ld	a3,0(a1)
    800065e0:	96b2                	add	a3,a3,a2
    800065e2:	e194                	sd	a3,0(a1)
    800065e4:	4589                	li	a1,2
    800065e6:	14459073          	csrw	sip,a1
    800065ea:	6914                	ld	a3,16(a0)
    800065ec:	6510                	ld	a2,8(a0)
    800065ee:	610c                	ld	a1,0(a0)
    800065f0:	34051573          	csrrw	a0,mscratch,a0
    800065f4:	30200073          	mret
	...

00000000800065fa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800065fa:	1141                	addi	sp,sp,-16
    800065fc:	e422                	sd	s0,8(sp)
    800065fe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006600:	0c0007b7          	lui	a5,0xc000
    80006604:	4705                	li	a4,1
    80006606:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006608:	0c0007b7          	lui	a5,0xc000
    8000660c:	c3d8                	sw	a4,4(a5)
}
    8000660e:	6422                	ld	s0,8(sp)
    80006610:	0141                	addi	sp,sp,16
    80006612:	8082                	ret

0000000080006614 <plicinithart>:

void
plicinithart(void)
{
    80006614:	1141                	addi	sp,sp,-16
    80006616:	e406                	sd	ra,8(sp)
    80006618:	e022                	sd	s0,0(sp)
    8000661a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000661c:	ffffc097          	auipc	ra,0xffffc
    80006620:	856080e7          	jalr	-1962(ra) # 80001e72 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006624:	0085171b          	slliw	a4,a0,0x8
    80006628:	0c0027b7          	lui	a5,0xc002
    8000662c:	97ba                	add	a5,a5,a4
    8000662e:	40200713          	li	a4,1026
    80006632:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006636:	00d5151b          	slliw	a0,a0,0xd
    8000663a:	0c2017b7          	lui	a5,0xc201
    8000663e:	97aa                	add	a5,a5,a0
    80006640:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006644:	60a2                	ld	ra,8(sp)
    80006646:	6402                	ld	s0,0(sp)
    80006648:	0141                	addi	sp,sp,16
    8000664a:	8082                	ret

000000008000664c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000664c:	1141                	addi	sp,sp,-16
    8000664e:	e406                	sd	ra,8(sp)
    80006650:	e022                	sd	s0,0(sp)
    80006652:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006654:	ffffc097          	auipc	ra,0xffffc
    80006658:	81e080e7          	jalr	-2018(ra) # 80001e72 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000665c:	00d5151b          	slliw	a0,a0,0xd
    80006660:	0c2017b7          	lui	a5,0xc201
    80006664:	97aa                	add	a5,a5,a0
  return irq;
}
    80006666:	43c8                	lw	a0,4(a5)
    80006668:	60a2                	ld	ra,8(sp)
    8000666a:	6402                	ld	s0,0(sp)
    8000666c:	0141                	addi	sp,sp,16
    8000666e:	8082                	ret

0000000080006670 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006670:	1101                	addi	sp,sp,-32
    80006672:	ec06                	sd	ra,24(sp)
    80006674:	e822                	sd	s0,16(sp)
    80006676:	e426                	sd	s1,8(sp)
    80006678:	1000                	addi	s0,sp,32
    8000667a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000667c:	ffffb097          	auipc	ra,0xffffb
    80006680:	7f6080e7          	jalr	2038(ra) # 80001e72 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006684:	00d5151b          	slliw	a0,a0,0xd
    80006688:	0c2017b7          	lui	a5,0xc201
    8000668c:	97aa                	add	a5,a5,a0
    8000668e:	c3c4                	sw	s1,4(a5)
}
    80006690:	60e2                	ld	ra,24(sp)
    80006692:	6442                	ld	s0,16(sp)
    80006694:	64a2                	ld	s1,8(sp)
    80006696:	6105                	addi	sp,sp,32
    80006698:	8082                	ret

000000008000669a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000669a:	1141                	addi	sp,sp,-16
    8000669c:	e406                	sd	ra,8(sp)
    8000669e:	e022                	sd	s0,0(sp)
    800066a0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800066a2:	479d                	li	a5,7
    800066a4:	04a7cc63          	blt	a5,a0,800066fc <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800066a8:	00026797          	auipc	a5,0x26
    800066ac:	30078793          	addi	a5,a5,768 # 8002c9a8 <disk>
    800066b0:	97aa                	add	a5,a5,a0
    800066b2:	0187c783          	lbu	a5,24(a5)
    800066b6:	ebb9                	bnez	a5,8000670c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800066b8:	00451693          	slli	a3,a0,0x4
    800066bc:	00026797          	auipc	a5,0x26
    800066c0:	2ec78793          	addi	a5,a5,748 # 8002c9a8 <disk>
    800066c4:	6398                	ld	a4,0(a5)
    800066c6:	9736                	add	a4,a4,a3
    800066c8:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800066cc:	6398                	ld	a4,0(a5)
    800066ce:	9736                	add	a4,a4,a3
    800066d0:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800066d4:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800066d8:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800066dc:	97aa                	add	a5,a5,a0
    800066de:	4705                	li	a4,1
    800066e0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800066e4:	00026517          	auipc	a0,0x26
    800066e8:	2dc50513          	addi	a0,a0,732 # 8002c9c0 <disk+0x18>
    800066ec:	ffffc097          	auipc	ra,0xffffc
    800066f0:	fc8080e7          	jalr	-56(ra) # 800026b4 <wakeup>
}
    800066f4:	60a2                	ld	ra,8(sp)
    800066f6:	6402                	ld	s0,0(sp)
    800066f8:	0141                	addi	sp,sp,16
    800066fa:	8082                	ret
    panic("free_desc 1");
    800066fc:	00002517          	auipc	a0,0x2
    80006700:	0cc50513          	addi	a0,a0,204 # 800087c8 <__func__.1+0x7c0>
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	e5c080e7          	jalr	-420(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000670c:	00002517          	auipc	a0,0x2
    80006710:	0cc50513          	addi	a0,a0,204 # 800087d8 <__func__.1+0x7d0>
    80006714:	ffffa097          	auipc	ra,0xffffa
    80006718:	e4c080e7          	jalr	-436(ra) # 80000560 <panic>

000000008000671c <virtio_disk_init>:
{
    8000671c:	1101                	addi	sp,sp,-32
    8000671e:	ec06                	sd	ra,24(sp)
    80006720:	e822                	sd	s0,16(sp)
    80006722:	e426                	sd	s1,8(sp)
    80006724:	e04a                	sd	s2,0(sp)
    80006726:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006728:	00002597          	auipc	a1,0x2
    8000672c:	0c058593          	addi	a1,a1,192 # 800087e8 <__func__.1+0x7e0>
    80006730:	00026517          	auipc	a0,0x26
    80006734:	3a050513          	addi	a0,a0,928 # 8002cad0 <disk+0x128>
    80006738:	ffffa097          	auipc	ra,0xffffa
    8000673c:	766080e7          	jalr	1894(ra) # 80000e9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006740:	100017b7          	lui	a5,0x10001
    80006744:	4398                	lw	a4,0(a5)
    80006746:	2701                	sext.w	a4,a4
    80006748:	747277b7          	lui	a5,0x74727
    8000674c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006750:	18f71c63          	bne	a4,a5,800068e8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006754:	100017b7          	lui	a5,0x10001
    80006758:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000675a:	439c                	lw	a5,0(a5)
    8000675c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000675e:	4709                	li	a4,2
    80006760:	18e79463          	bne	a5,a4,800068e8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006764:	100017b7          	lui	a5,0x10001
    80006768:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000676a:	439c                	lw	a5,0(a5)
    8000676c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000676e:	16e79d63          	bne	a5,a4,800068e8 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006772:	100017b7          	lui	a5,0x10001
    80006776:	47d8                	lw	a4,12(a5)
    80006778:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000677a:	554d47b7          	lui	a5,0x554d4
    8000677e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006782:	16f71363          	bne	a4,a5,800068e8 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006786:	100017b7          	lui	a5,0x10001
    8000678a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000678e:	4705                	li	a4,1
    80006790:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006792:	470d                	li	a4,3
    80006794:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006796:	10001737          	lui	a4,0x10001
    8000679a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000679c:	c7ffe737          	lui	a4,0xc7ffe
    800067a0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd1c77>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067a4:	8ef9                	and	a3,a3,a4
    800067a6:	10001737          	lui	a4,0x10001
    800067aa:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067ac:	472d                	li	a4,11
    800067ae:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067b0:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800067b4:	439c                	lw	a5,0(a5)
    800067b6:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800067ba:	8ba1                	andi	a5,a5,8
    800067bc:	12078e63          	beqz	a5,800068f8 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800067c0:	100017b7          	lui	a5,0x10001
    800067c4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800067c8:	100017b7          	lui	a5,0x10001
    800067cc:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800067d0:	439c                	lw	a5,0(a5)
    800067d2:	2781                	sext.w	a5,a5
    800067d4:	12079a63          	bnez	a5,80006908 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800067d8:	100017b7          	lui	a5,0x10001
    800067dc:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800067e0:	439c                	lw	a5,0(a5)
    800067e2:	2781                	sext.w	a5,a5
  if(max == 0)
    800067e4:	12078a63          	beqz	a5,80006918 <virtio_disk_init+0x1fc>
  if(max < NUM)
    800067e8:	471d                	li	a4,7
    800067ea:	12f77f63          	bgeu	a4,a5,80006928 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    800067ee:	ffffa097          	auipc	ra,0xffffa
    800067f2:	48c080e7          	jalr	1164(ra) # 80000c7a <kalloc>
    800067f6:	00026497          	auipc	s1,0x26
    800067fa:	1b248493          	addi	s1,s1,434 # 8002c9a8 <disk>
    800067fe:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006800:	ffffa097          	auipc	ra,0xffffa
    80006804:	47a080e7          	jalr	1146(ra) # 80000c7a <kalloc>
    80006808:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000680a:	ffffa097          	auipc	ra,0xffffa
    8000680e:	470080e7          	jalr	1136(ra) # 80000c7a <kalloc>
    80006812:	87aa                	mv	a5,a0
    80006814:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006816:	6088                	ld	a0,0(s1)
    80006818:	12050063          	beqz	a0,80006938 <virtio_disk_init+0x21c>
    8000681c:	00026717          	auipc	a4,0x26
    80006820:	19473703          	ld	a4,404(a4) # 8002c9b0 <disk+0x8>
    80006824:	10070a63          	beqz	a4,80006938 <virtio_disk_init+0x21c>
    80006828:	10078863          	beqz	a5,80006938 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000682c:	6605                	lui	a2,0x1
    8000682e:	4581                	li	a1,0
    80006830:	ffffa097          	auipc	ra,0xffffa
    80006834:	7fa080e7          	jalr	2042(ra) # 8000102a <memset>
  memset(disk.avail, 0, PGSIZE);
    80006838:	00026497          	auipc	s1,0x26
    8000683c:	17048493          	addi	s1,s1,368 # 8002c9a8 <disk>
    80006840:	6605                	lui	a2,0x1
    80006842:	4581                	li	a1,0
    80006844:	6488                	ld	a0,8(s1)
    80006846:	ffffa097          	auipc	ra,0xffffa
    8000684a:	7e4080e7          	jalr	2020(ra) # 8000102a <memset>
  memset(disk.used, 0, PGSIZE);
    8000684e:	6605                	lui	a2,0x1
    80006850:	4581                	li	a1,0
    80006852:	6888                	ld	a0,16(s1)
    80006854:	ffffa097          	auipc	ra,0xffffa
    80006858:	7d6080e7          	jalr	2006(ra) # 8000102a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000685c:	100017b7          	lui	a5,0x10001
    80006860:	4721                	li	a4,8
    80006862:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006864:	4098                	lw	a4,0(s1)
    80006866:	100017b7          	lui	a5,0x10001
    8000686a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000686e:	40d8                	lw	a4,4(s1)
    80006870:	100017b7          	lui	a5,0x10001
    80006874:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006878:	649c                	ld	a5,8(s1)
    8000687a:	0007869b          	sext.w	a3,a5
    8000687e:	10001737          	lui	a4,0x10001
    80006882:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006886:	9781                	srai	a5,a5,0x20
    80006888:	10001737          	lui	a4,0x10001
    8000688c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006890:	689c                	ld	a5,16(s1)
    80006892:	0007869b          	sext.w	a3,a5
    80006896:	10001737          	lui	a4,0x10001
    8000689a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000689e:	9781                	srai	a5,a5,0x20
    800068a0:	10001737          	lui	a4,0x10001
    800068a4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800068a8:	10001737          	lui	a4,0x10001
    800068ac:	4785                	li	a5,1
    800068ae:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800068b0:	00f48c23          	sb	a5,24(s1)
    800068b4:	00f48ca3          	sb	a5,25(s1)
    800068b8:	00f48d23          	sb	a5,26(s1)
    800068bc:	00f48da3          	sb	a5,27(s1)
    800068c0:	00f48e23          	sb	a5,28(s1)
    800068c4:	00f48ea3          	sb	a5,29(s1)
    800068c8:	00f48f23          	sb	a5,30(s1)
    800068cc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800068d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800068d4:	100017b7          	lui	a5,0x10001
    800068d8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800068dc:	60e2                	ld	ra,24(sp)
    800068de:	6442                	ld	s0,16(sp)
    800068e0:	64a2                	ld	s1,8(sp)
    800068e2:	6902                	ld	s2,0(sp)
    800068e4:	6105                	addi	sp,sp,32
    800068e6:	8082                	ret
    panic("could not find virtio disk");
    800068e8:	00002517          	auipc	a0,0x2
    800068ec:	f1050513          	addi	a0,a0,-240 # 800087f8 <__func__.1+0x7f0>
    800068f0:	ffffa097          	auipc	ra,0xffffa
    800068f4:	c70080e7          	jalr	-912(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    800068f8:	00002517          	auipc	a0,0x2
    800068fc:	f2050513          	addi	a0,a0,-224 # 80008818 <__func__.1+0x810>
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	c60080e7          	jalr	-928(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006908:	00002517          	auipc	a0,0x2
    8000690c:	f3050513          	addi	a0,a0,-208 # 80008838 <__func__.1+0x830>
    80006910:	ffffa097          	auipc	ra,0xffffa
    80006914:	c50080e7          	jalr	-944(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006918:	00002517          	auipc	a0,0x2
    8000691c:	f4050513          	addi	a0,a0,-192 # 80008858 <__func__.1+0x850>
    80006920:	ffffa097          	auipc	ra,0xffffa
    80006924:	c40080e7          	jalr	-960(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006928:	00002517          	auipc	a0,0x2
    8000692c:	f5050513          	addi	a0,a0,-176 # 80008878 <__func__.1+0x870>
    80006930:	ffffa097          	auipc	ra,0xffffa
    80006934:	c30080e7          	jalr	-976(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006938:	00002517          	auipc	a0,0x2
    8000693c:	f6050513          	addi	a0,a0,-160 # 80008898 <__func__.1+0x890>
    80006940:	ffffa097          	auipc	ra,0xffffa
    80006944:	c20080e7          	jalr	-992(ra) # 80000560 <panic>

0000000080006948 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006948:	7159                	addi	sp,sp,-112
    8000694a:	f486                	sd	ra,104(sp)
    8000694c:	f0a2                	sd	s0,96(sp)
    8000694e:	eca6                	sd	s1,88(sp)
    80006950:	e8ca                	sd	s2,80(sp)
    80006952:	e4ce                	sd	s3,72(sp)
    80006954:	e0d2                	sd	s4,64(sp)
    80006956:	fc56                	sd	s5,56(sp)
    80006958:	f85a                	sd	s6,48(sp)
    8000695a:	f45e                	sd	s7,40(sp)
    8000695c:	f062                	sd	s8,32(sp)
    8000695e:	ec66                	sd	s9,24(sp)
    80006960:	1880                	addi	s0,sp,112
    80006962:	8a2a                	mv	s4,a0
    80006964:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006966:	00c52c83          	lw	s9,12(a0)
    8000696a:	001c9c9b          	slliw	s9,s9,0x1
    8000696e:	1c82                	slli	s9,s9,0x20
    80006970:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006974:	00026517          	auipc	a0,0x26
    80006978:	15c50513          	addi	a0,a0,348 # 8002cad0 <disk+0x128>
    8000697c:	ffffa097          	auipc	ra,0xffffa
    80006980:	5b2080e7          	jalr	1458(ra) # 80000f2e <acquire>
  for(int i = 0; i < 3; i++){
    80006984:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006986:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006988:	00026b17          	auipc	s6,0x26
    8000698c:	020b0b13          	addi	s6,s6,32 # 8002c9a8 <disk>
  for(int i = 0; i < 3; i++){
    80006990:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006992:	00026c17          	auipc	s8,0x26
    80006996:	13ec0c13          	addi	s8,s8,318 # 8002cad0 <disk+0x128>
    8000699a:	a0ad                	j	80006a04 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000699c:	00fb0733          	add	a4,s6,a5
    800069a0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800069a4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800069a6:	0207c563          	bltz	a5,800069d0 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800069aa:	2905                	addiw	s2,s2,1
    800069ac:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800069ae:	05590f63          	beq	s2,s5,80006a0c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800069b2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800069b4:	00026717          	auipc	a4,0x26
    800069b8:	ff470713          	addi	a4,a4,-12 # 8002c9a8 <disk>
    800069bc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800069be:	01874683          	lbu	a3,24(a4)
    800069c2:	fee9                	bnez	a3,8000699c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800069c4:	2785                	addiw	a5,a5,1
    800069c6:	0705                	addi	a4,a4,1
    800069c8:	fe979be3          	bne	a5,s1,800069be <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800069cc:	57fd                	li	a5,-1
    800069ce:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800069d0:	03205163          	blez	s2,800069f2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800069d4:	f9042503          	lw	a0,-112(s0)
    800069d8:	00000097          	auipc	ra,0x0
    800069dc:	cc2080e7          	jalr	-830(ra) # 8000669a <free_desc>
      for(int j = 0; j < i; j++)
    800069e0:	4785                	li	a5,1
    800069e2:	0127d863          	bge	a5,s2,800069f2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    800069e6:	f9442503          	lw	a0,-108(s0)
    800069ea:	00000097          	auipc	ra,0x0
    800069ee:	cb0080e7          	jalr	-848(ra) # 8000669a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069f2:	85e2                	mv	a1,s8
    800069f4:	00026517          	auipc	a0,0x26
    800069f8:	fcc50513          	addi	a0,a0,-52 # 8002c9c0 <disk+0x18>
    800069fc:	ffffc097          	auipc	ra,0xffffc
    80006a00:	c54080e7          	jalr	-940(ra) # 80002650 <sleep>
  for(int i = 0; i < 3; i++){
    80006a04:	f9040613          	addi	a2,s0,-112
    80006a08:	894e                	mv	s2,s3
    80006a0a:	b765                	j	800069b2 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a0c:	f9042503          	lw	a0,-112(s0)
    80006a10:	00451693          	slli	a3,a0,0x4

  if(write)
    80006a14:	00026797          	auipc	a5,0x26
    80006a18:	f9478793          	addi	a5,a5,-108 # 8002c9a8 <disk>
    80006a1c:	00a50713          	addi	a4,a0,10
    80006a20:	0712                	slli	a4,a4,0x4
    80006a22:	973e                	add	a4,a4,a5
    80006a24:	01703633          	snez	a2,s7
    80006a28:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006a2a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006a2e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a32:	6398                	ld	a4,0(a5)
    80006a34:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a36:	0a868613          	addi	a2,a3,168
    80006a3a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a3c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a3e:	6390                	ld	a2,0(a5)
    80006a40:	00d605b3          	add	a1,a2,a3
    80006a44:	4741                	li	a4,16
    80006a46:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a48:	4805                	li	a6,1
    80006a4a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006a4e:	f9442703          	lw	a4,-108(s0)
    80006a52:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a56:	0712                	slli	a4,a4,0x4
    80006a58:	963a                	add	a2,a2,a4
    80006a5a:	058a0593          	addi	a1,s4,88
    80006a5e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006a60:	0007b883          	ld	a7,0(a5)
    80006a64:	9746                	add	a4,a4,a7
    80006a66:	40000613          	li	a2,1024
    80006a6a:	c710                	sw	a2,8(a4)
  if(write)
    80006a6c:	001bb613          	seqz	a2,s7
    80006a70:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a74:	00166613          	ori	a2,a2,1
    80006a78:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006a7c:	f9842583          	lw	a1,-104(s0)
    80006a80:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006a84:	00250613          	addi	a2,a0,2
    80006a88:	0612                	slli	a2,a2,0x4
    80006a8a:	963e                	add	a2,a2,a5
    80006a8c:	577d                	li	a4,-1
    80006a8e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006a92:	0592                	slli	a1,a1,0x4
    80006a94:	98ae                	add	a7,a7,a1
    80006a96:	03068713          	addi	a4,a3,48
    80006a9a:	973e                	add	a4,a4,a5
    80006a9c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006aa0:	6398                	ld	a4,0(a5)
    80006aa2:	972e                	add	a4,a4,a1
    80006aa4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006aa8:	4689                	li	a3,2
    80006aaa:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006aae:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006ab2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006ab6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006aba:	6794                	ld	a3,8(a5)
    80006abc:	0026d703          	lhu	a4,2(a3)
    80006ac0:	8b1d                	andi	a4,a4,7
    80006ac2:	0706                	slli	a4,a4,0x1
    80006ac4:	96ba                	add	a3,a3,a4
    80006ac6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006aca:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006ace:	6798                	ld	a4,8(a5)
    80006ad0:	00275783          	lhu	a5,2(a4)
    80006ad4:	2785                	addiw	a5,a5,1
    80006ad6:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006ada:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006ade:	100017b7          	lui	a5,0x10001
    80006ae2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006ae6:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006aea:	00026917          	auipc	s2,0x26
    80006aee:	fe690913          	addi	s2,s2,-26 # 8002cad0 <disk+0x128>
  while(b->disk == 1) {
    80006af2:	4485                	li	s1,1
    80006af4:	01079c63          	bne	a5,a6,80006b0c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006af8:	85ca                	mv	a1,s2
    80006afa:	8552                	mv	a0,s4
    80006afc:	ffffc097          	auipc	ra,0xffffc
    80006b00:	b54080e7          	jalr	-1196(ra) # 80002650 <sleep>
  while(b->disk == 1) {
    80006b04:	004a2783          	lw	a5,4(s4)
    80006b08:	fe9788e3          	beq	a5,s1,80006af8 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006b0c:	f9042903          	lw	s2,-112(s0)
    80006b10:	00290713          	addi	a4,s2,2
    80006b14:	0712                	slli	a4,a4,0x4
    80006b16:	00026797          	auipc	a5,0x26
    80006b1a:	e9278793          	addi	a5,a5,-366 # 8002c9a8 <disk>
    80006b1e:	97ba                	add	a5,a5,a4
    80006b20:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006b24:	00026997          	auipc	s3,0x26
    80006b28:	e8498993          	addi	s3,s3,-380 # 8002c9a8 <disk>
    80006b2c:	00491713          	slli	a4,s2,0x4
    80006b30:	0009b783          	ld	a5,0(s3)
    80006b34:	97ba                	add	a5,a5,a4
    80006b36:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006b3a:	854a                	mv	a0,s2
    80006b3c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006b40:	00000097          	auipc	ra,0x0
    80006b44:	b5a080e7          	jalr	-1190(ra) # 8000669a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006b48:	8885                	andi	s1,s1,1
    80006b4a:	f0ed                	bnez	s1,80006b2c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b4c:	00026517          	auipc	a0,0x26
    80006b50:	f8450513          	addi	a0,a0,-124 # 8002cad0 <disk+0x128>
    80006b54:	ffffa097          	auipc	ra,0xffffa
    80006b58:	48e080e7          	jalr	1166(ra) # 80000fe2 <release>
}
    80006b5c:	70a6                	ld	ra,104(sp)
    80006b5e:	7406                	ld	s0,96(sp)
    80006b60:	64e6                	ld	s1,88(sp)
    80006b62:	6946                	ld	s2,80(sp)
    80006b64:	69a6                	ld	s3,72(sp)
    80006b66:	6a06                	ld	s4,64(sp)
    80006b68:	7ae2                	ld	s5,56(sp)
    80006b6a:	7b42                	ld	s6,48(sp)
    80006b6c:	7ba2                	ld	s7,40(sp)
    80006b6e:	7c02                	ld	s8,32(sp)
    80006b70:	6ce2                	ld	s9,24(sp)
    80006b72:	6165                	addi	sp,sp,112
    80006b74:	8082                	ret

0000000080006b76 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006b76:	1101                	addi	sp,sp,-32
    80006b78:	ec06                	sd	ra,24(sp)
    80006b7a:	e822                	sd	s0,16(sp)
    80006b7c:	e426                	sd	s1,8(sp)
    80006b7e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b80:	00026497          	auipc	s1,0x26
    80006b84:	e2848493          	addi	s1,s1,-472 # 8002c9a8 <disk>
    80006b88:	00026517          	auipc	a0,0x26
    80006b8c:	f4850513          	addi	a0,a0,-184 # 8002cad0 <disk+0x128>
    80006b90:	ffffa097          	auipc	ra,0xffffa
    80006b94:	39e080e7          	jalr	926(ra) # 80000f2e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006b98:	100017b7          	lui	a5,0x10001
    80006b9c:	53b8                	lw	a4,96(a5)
    80006b9e:	8b0d                	andi	a4,a4,3
    80006ba0:	100017b7          	lui	a5,0x10001
    80006ba4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006ba6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006baa:	689c                	ld	a5,16(s1)
    80006bac:	0204d703          	lhu	a4,32(s1)
    80006bb0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006bb4:	04f70863          	beq	a4,a5,80006c04 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006bb8:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006bbc:	6898                	ld	a4,16(s1)
    80006bbe:	0204d783          	lhu	a5,32(s1)
    80006bc2:	8b9d                	andi	a5,a5,7
    80006bc4:	078e                	slli	a5,a5,0x3
    80006bc6:	97ba                	add	a5,a5,a4
    80006bc8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006bca:	00278713          	addi	a4,a5,2
    80006bce:	0712                	slli	a4,a4,0x4
    80006bd0:	9726                	add	a4,a4,s1
    80006bd2:	01074703          	lbu	a4,16(a4)
    80006bd6:	e721                	bnez	a4,80006c1e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006bd8:	0789                	addi	a5,a5,2
    80006bda:	0792                	slli	a5,a5,0x4
    80006bdc:	97a6                	add	a5,a5,s1
    80006bde:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006be0:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006be4:	ffffc097          	auipc	ra,0xffffc
    80006be8:	ad0080e7          	jalr	-1328(ra) # 800026b4 <wakeup>

    disk.used_idx += 1;
    80006bec:	0204d783          	lhu	a5,32(s1)
    80006bf0:	2785                	addiw	a5,a5,1
    80006bf2:	17c2                	slli	a5,a5,0x30
    80006bf4:	93c1                	srli	a5,a5,0x30
    80006bf6:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006bfa:	6898                	ld	a4,16(s1)
    80006bfc:	00275703          	lhu	a4,2(a4)
    80006c00:	faf71ce3          	bne	a4,a5,80006bb8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006c04:	00026517          	auipc	a0,0x26
    80006c08:	ecc50513          	addi	a0,a0,-308 # 8002cad0 <disk+0x128>
    80006c0c:	ffffa097          	auipc	ra,0xffffa
    80006c10:	3d6080e7          	jalr	982(ra) # 80000fe2 <release>
}
    80006c14:	60e2                	ld	ra,24(sp)
    80006c16:	6442                	ld	s0,16(sp)
    80006c18:	64a2                	ld	s1,8(sp)
    80006c1a:	6105                	addi	sp,sp,32
    80006c1c:	8082                	ret
      panic("virtio_disk_intr status");
    80006c1e:	00002517          	auipc	a0,0x2
    80006c22:	c9250513          	addi	a0,a0,-878 # 800088b0 <__func__.1+0x8a8>
    80006c26:	ffffa097          	auipc	ra,0xffffa
    80006c2a:	93a080e7          	jalr	-1734(ra) # 80000560 <panic>
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
