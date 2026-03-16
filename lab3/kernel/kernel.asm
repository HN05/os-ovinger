
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	70013103          	ld	sp,1792(sp) # 8000b700 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	72070713          	addi	a4,a4,1824 # 8000b770 <timer_scratch>
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
    80000066:	70e78793          	addi	a5,a5,1806 # 80006770 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd1c07>
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
    8000012e:	abe080e7          	jalr	-1346(ra) # 80002be8 <either_copyin>
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
    80000190:	72450513          	addi	a0,a0,1828 # 800138b0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	da2080e7          	jalr	-606(ra) # 80000f36 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	71448493          	addi	s1,s1,1812 # 800138b0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	7a490913          	addi	s2,s2,1956 # 80013948 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	e1c080e7          	jalr	-484(ra) # 80001fd8 <myproc>
    800001c4:	00003097          	auipc	ra,0x3
    800001c8:	86e080e7          	jalr	-1938(ra) # 80002a32 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	5b8080e7          	jalr	1464(ra) # 8000278a <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	6c870713          	addi	a4,a4,1736 # 800138b0 <cons>
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
    8000021e:	978080e7          	jalr	-1672(ra) # 80002b92 <either_copyout>
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
    8000023a:	67a50513          	addi	a0,a0,1658 # 800138b0 <cons>
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
    80000268:	6ef72223          	sw	a5,1764(a4) # 80013948 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	63650513          	addi	a0,a0,1590 # 800138b0 <cons>
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
    800002e6:	5ce50513          	addi	a0,a0,1486 # 800138b0 <cons>
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
    8000030c:	936080e7          	jalr	-1738(ra) # 80002c3e <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	5a050513          	addi	a0,a0,1440 # 800138b0 <cons>
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
    80000336:	57e70713          	addi	a4,a4,1406 # 800138b0 <cons>
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
    80000360:	55478793          	addi	a5,a5,1364 # 800138b0 <cons>
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
    8000038e:	5be7a783          	lw	a5,1470(a5) # 80013948 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	51070713          	addi	a4,a4,1296 # 800138b0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	50048493          	addi	s1,s1,1280 # 800138b0 <cons>
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
    800003fa:	4ba70713          	addi	a4,a4,1210 # 800138b0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	54f72223          	sw	a5,1348(a4) # 80013950 <cons+0xa0>
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
    80000436:	47e78793          	addi	a5,a5,1150 # 800138b0 <cons>
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
    8000045a:	4ec7ab23          	sw	a2,1270(a5) # 8001394c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	4ea50513          	addi	a0,a0,1258 # 80013948 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	388080e7          	jalr	904(ra) # 800027ee <wakeup>
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
    80000484:	43050513          	addi	a0,a0,1072 # 800138b0 <cons>
    80000488:	00001097          	auipc	ra,0x1
    8000048c:	a1e080e7          	jalr	-1506(ra) # 80000ea6 <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	0002b797          	auipc	a5,0x2b
    8000049c:	5c878793          	addi	a5,a5,1480 # 8002ba60 <devsw>
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
    80000582:	3e07a923          	sw	zero,1010(a5) # 80013970 <pr+0x18>
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
    800005b6:	16f72723          	sw	a5,366(a4) # 8000b720 <panicked>
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
    800005e0:	394d2d03          	lw	s10,916(s10) # 80013970 <pr+0x18>
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
    80000630:	32c50513          	addi	a0,a0,812 # 80013958 <pr>
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
    800007b6:	1a650513          	addi	a0,a0,422 # 80013958 <pr>
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
    800007d2:	18a48493          	addi	s1,s1,394 # 80013958 <pr>
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
    8000083e:	13e50513          	addi	a0,a0,318 # 80013978 <uart_tx_lock>
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
    8000086a:	eba7a783          	lw	a5,-326(a5) # 8000b720 <panicked>
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
    800008a4:	e887b783          	ld	a5,-376(a5) # 8000b728 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	e8873703          	ld	a4,-376(a4) # 8000b730 <uart_tx_w>
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
    800008d2:	0aaa8a93          	addi	s5,s5,170 # 80013978 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	e5248493          	addi	s1,s1,-430 # 8000b728 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	e4e98993          	addi	s3,s3,-434 # 8000b730 <uart_tx_w>
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
    80000908:	eea080e7          	jalr	-278(ra) # 800027ee <wakeup>
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
    80000946:	03650513          	addi	a0,a0,54 # 80013978 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	5ec080e7          	jalr	1516(ra) # 80000f36 <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	dce7a783          	lw	a5,-562(a5) # 8000b720 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	dd473703          	ld	a4,-556(a4) # 8000b730 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	dc47b783          	ld	a5,-572(a5) # 8000b728 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	00898993          	addi	s3,s3,8 # 80013978 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	db048493          	addi	s1,s1,-592 # 8000b728 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	db090913          	addi	s2,s2,-592 # 8000b730 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	dfa080e7          	jalr	-518(ra) # 8000278a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	fd248493          	addi	s1,s1,-46 # 80013978 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	d6e7bb23          	sd	a4,-650(a5) # 8000b730 <uart_tx_w>
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
    80000a32:	f4a48493          	addi	s1,s1,-182 # 80013978 <uart_tx_lock>
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
    80000a60:	19c78793          	addi	a5,a5,412 # 8002cbf8 <end>
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
    80000aa8:	c9c7b783          	ld	a5,-868(a5) # 8000b740 <MAX_PAGES>
    80000aac:	c799                	beqz	a5,80000aba <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000aae:	0000b717          	auipc	a4,0xb
    80000ab2:	c8a73703          	ld	a4,-886(a4) # 8000b738 <FREE_PAGES>
    80000ab6:	08f77063          	bgeu	a4,a5,80000b36 <kfree+0xa2>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000aba:	03449793          	slli	a5,s1,0x34
    80000abe:	e7d5                	bnez	a5,80000b6a <kfree+0xd6>
    80000ac0:	0002c797          	auipc	a5,0x2c
    80000ac4:	13878793          	addi	a5,a5,312 # 8002cbf8 <end>
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
    80000ae4:	ed050513          	addi	a0,a0,-304 # 800139b0 <refcountlock>
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	44e080e7          	jalr	1102(ra) # 80000f36 <acquire>
    if (refcount[i] > 0) refcount[i]--;
    80000af0:	00013797          	auipc	a5,0x13
    80000af4:	ef878793          	addi	a5,a5,-264 # 800139e8 <refcount>
    80000af8:	97ce                	add	a5,a5,s3
    80000afa:	0007c783          	lbu	a5,0(a5)
    80000afe:	cfb5                	beqz	a5,80000b7a <kfree+0xe6>
    80000b00:	37fd                	addiw	a5,a5,-1
    80000b02:	0ff7f913          	zext.b	s2,a5
    80000b06:	00013797          	auipc	a5,0x13
    80000b0a:	ee278793          	addi	a5,a5,-286 # 800139e8 <refcount>
    80000b0e:	97ce                	add	a5,a5,s3
    80000b10:	01278023          	sb	s2,0(a5)
    int empty = refcount[i] == 0;
    release(&refcountlock);
    80000b14:	00013517          	auipc	a0,0x13
    80000b18:	e9c50513          	addi	a0,a0,-356 # 800139b0 <refcountlock>
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
    80000b7e:	e3650513          	addi	a0,a0,-458 # 800139b0 <refcountlock>
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
    80000b9c:	e1898993          	addi	s3,s3,-488 # 800139b0 <refcountlock>
    80000ba0:	00013917          	auipc	s2,0x13
    80000ba4:	e2890913          	addi	s2,s2,-472 # 800139c8 <kmem>
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
    80000bc0:	b7c70713          	addi	a4,a4,-1156 # 8000b738 <FREE_PAGES>
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
    80000c36:	d9650513          	addi	a0,a0,-618 # 800139c8 <kmem>
    80000c3a:	00000097          	auipc	ra,0x0
    80000c3e:	26c080e7          	jalr	620(ra) # 80000ea6 <initlock>
    initlock(&refcountlock, "refcount");
    80000c42:	00007597          	auipc	a1,0x7
    80000c46:	46658593          	addi	a1,a1,1126 # 800080a8 <__func__.1+0xa0>
    80000c4a:	00013517          	auipc	a0,0x13
    80000c4e:	d6650513          	addi	a0,a0,-666 # 800139b0 <refcountlock>
    80000c52:	00000097          	auipc	ra,0x0
    80000c56:	254080e7          	jalr	596(ra) # 80000ea6 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000c5a:	45c5                	li	a1,17
    80000c5c:	05ee                	slli	a1,a1,0x1b
    80000c5e:	0002c517          	auipc	a0,0x2c
    80000c62:	f9a50513          	addi	a0,a0,-102 # 8002cbf8 <end>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	f70080e7          	jalr	-144(ra) # 80000bd6 <freerange>
    MAX_PAGES = FREE_PAGES;
    80000c6e:	0000b797          	auipc	a5,0xb
    80000c72:	aca7b783          	ld	a5,-1334(a5) # 8000b738 <FREE_PAGES>
    80000c76:	0000b717          	auipc	a4,0xb
    80000c7a:	acf73523          	sd	a5,-1334(a4) # 8000b740 <MAX_PAGES>
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
    80000c98:	aa47b783          	ld	a5,-1372(a5) # 8000b738 <FREE_PAGES>
    80000c9c:	cfd1                	beqz	a5,80000d38 <kalloc+0xb2>
    struct run *r;

    acquire(&kmem.lock);
    80000c9e:	00013517          	auipc	a0,0x13
    80000ca2:	d2a50513          	addi	a0,a0,-726 # 800139c8 <kmem>
    80000ca6:	00000097          	auipc	ra,0x0
    80000caa:	290080e7          	jalr	656(ra) # 80000f36 <acquire>
    r = kmem.freelist;
    80000cae:	00013497          	auipc	s1,0x13
    80000cb2:	d324b483          	ld	s1,-718(s1) # 800139e0 <kmem+0x18>
    if (r)
    80000cb6:	c8dd                	beqz	s1,80000d6c <kalloc+0xe6>
        kmem.freelist = r->next;
    80000cb8:	609c                	ld	a5,0(s1)
    80000cba:	00013717          	auipc	a4,0x13
    80000cbe:	d2f73323          	sd	a5,-730(a4) # 800139e0 <kmem+0x18>
    release(&kmem.lock);
    80000cc2:	00013517          	auipc	a0,0x13
    80000cc6:	d0650513          	addi	a0,a0,-762 # 800139c8 <kmem>
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
    80000ce4:	a5870713          	addi	a4,a4,-1448 # 8000b738 <FREE_PAGES>
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
    80000cfe:	cb698993          	addi	s3,s3,-842 # 800139b0 <refcountlock>
    80000d02:	854e                	mv	a0,s3
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	232080e7          	jalr	562(ra) # 80000f36 <acquire>
    refcount[i] = 1;
    80000d0c:	00013797          	auipc	a5,0x13
    80000d10:	cdc78793          	addi	a5,a5,-804 # 800139e8 <refcount>
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
    80000d70:	c5c50513          	addi	a0,a0,-932 # 800139c8 <kmem>
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
    80000da8:	c0c50513          	addi	a0,a0,-1012 # 800139b0 <refcountlock>
    80000dac:	00000097          	auipc	ra,0x0
    80000db0:	18a080e7          	jalr	394(ra) # 80000f36 <acquire>
    if (refcount[i] > 1) {
    80000db4:	00013797          	auipc	a5,0x13
    80000db8:	c3478793          	addi	a5,a5,-972 # 800139e8 <refcount>
    80000dbc:	97a6                	add	a5,a5,s1
    80000dbe:	0007c783          	lbu	a5,0(a5)
    80000dc2:	4705                	li	a4,1
    80000dc4:	06f77863          	bgeu	a4,a5,80000e34 <cow_triggered+0xb6>
        refcount[i]--;
    80000dc8:	00013717          	auipc	a4,0x13
    80000dcc:	c2070713          	addi	a4,a4,-992 # 800139e8 <refcount>
    80000dd0:	9726                	add	a4,a4,s1
    80000dd2:	37fd                	addiw	a5,a5,-1
    80000dd4:	00f70023          	sb	a5,0(a4)
        release(&refcountlock);
    80000dd8:	00013517          	auipc	a0,0x13
    80000ddc:	bd850513          	addi	a0,a0,-1064 # 800139b0 <refcountlock>
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
    80000e38:	b7c50513          	addi	a0,a0,-1156 # 800139b0 <refcountlock>
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
    80000e64:	b5090913          	addi	s2,s2,-1200 # 800139b0 <refcountlock>
    80000e68:	854a                	mv	a0,s2
    80000e6a:	00000097          	auipc	ra,0x0
    80000e6e:	0cc080e7          	jalr	204(ra) # 80000f36 <acquire>
    refcount[refindex(pa)]++;
    80000e72:	8526                	mv	a0,s1
    80000e74:	00000097          	auipc	ra,0x0
    80000e78:	be8080e7          	jalr	-1048(ra) # 80000a5c <refindex>
    80000e7c:	00013797          	auipc	a5,0x13
    80000e80:	b6c78793          	addi	a5,a5,-1172 # 800139e8 <refcount>
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
    80000ed4:	0ec080e7          	jalr	236(ra) # 80001fbc <mycpu>
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
    80000f06:	0ba080e7          	jalr	186(ra) # 80001fbc <mycpu>
    80000f0a:	5d3c                	lw	a5,120(a0)
    80000f0c:	cf89                	beqz	a5,80000f26 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000f0e:	00001097          	auipc	ra,0x1
    80000f12:	0ae080e7          	jalr	174(ra) # 80001fbc <mycpu>
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
    80000f2a:	096080e7          	jalr	150(ra) # 80001fbc <mycpu>
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
    80000f6a:	056080e7          	jalr	86(ra) # 80001fbc <mycpu>
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
    80000f96:	02a080e7          	jalr	42(ra) # 80001fbc <mycpu>
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
    800011dc:	dd4080e7          	jalr	-556(ra) # 80001fac <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800011e0:	0000a717          	auipc	a4,0xa
    800011e4:	56870713          	addi	a4,a4,1384 # 8000b748 <started>
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
    800011f8:	db8080e7          	jalr	-584(ra) # 80001fac <cpuid>
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
    8000121a:	ccc080e7          	jalr	-820(ra) # 80002ee2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000121e:	00005097          	auipc	ra,0x5
    80001222:	596080e7          	jalr	1430(ra) # 800067b4 <plicinithart>
  }

  scheduler();        
    80001226:	00001097          	auipc	ra,0x1
    8000122a:	442080e7          	jalr	1090(ra) # 80002668 <scheduler>
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
    8000128a:	c40080e7          	jalr	-960(ra) # 80001ec6 <procinit>
    trapinit();      // trap vectors
    8000128e:	00002097          	auipc	ra,0x2
    80001292:	c2c080e7          	jalr	-980(ra) # 80002eba <trapinit>
    trapinithart();  // install kernel trap vector
    80001296:	00002097          	auipc	ra,0x2
    8000129a:	c4c080e7          	jalr	-948(ra) # 80002ee2 <trapinithart>
    plicinit();      // set up interrupt controller
    8000129e:	00005097          	auipc	ra,0x5
    800012a2:	4fc080e7          	jalr	1276(ra) # 8000679a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800012a6:	00005097          	auipc	ra,0x5
    800012aa:	50e080e7          	jalr	1294(ra) # 800067b4 <plicinithart>
    binit();         // buffer cache
    800012ae:	00002097          	auipc	ra,0x2
    800012b2:	5d0080e7          	jalr	1488(ra) # 8000387e <binit>
    iinit();         // inode table
    800012b6:	00003097          	auipc	ra,0x3
    800012ba:	c86080e7          	jalr	-890(ra) # 80003f3c <iinit>
    fileinit();      // file table
    800012be:	00004097          	auipc	ra,0x4
    800012c2:	c36080e7          	jalr	-970(ra) # 80004ef4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800012c6:	00005097          	auipc	ra,0x5
    800012ca:	5f6080e7          	jalr	1526(ra) # 800068bc <virtio_disk_init>
    userinit();      // first user process
    800012ce:	00001097          	auipc	ra,0x1
    800012d2:	fe2080e7          	jalr	-30(ra) # 800022b0 <userinit>
    __sync_synchronize();
    800012d6:	0330000f          	fence	rw,rw
    started = 1;
    800012da:	4785                	li	a5,1
    800012dc:	0000a717          	auipc	a4,0xa
    800012e0:	46f72623          	sw	a5,1132(a4) # 8000b748 <started>
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
    800012f4:	4607b783          	ld	a5,1120(a5) # 8000b750 <kernel_pagetable>
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
    8000136e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd23ff>
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
    8000158a:	89c080e7          	jalr	-1892(ra) # 80001e22 <proc_mapstacks>
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
    800015b0:	1aa7b223          	sd	a0,420(a5) # 8000b750 <kernel_pagetable>
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
    80001b90:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd2408>
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
    80001c18:	711d                	addi	sp,sp,-96
    80001c1a:	ec86                	sd	ra,88(sp)
    80001c1c:	e8a2                	sd	s0,80(sp)
    80001c1e:	f852                	sd	s4,48(sp)
    80001c20:	1080                	addi	s0,sp,96
  uint64 end = vaddr + npages * PGSIZE;
    80001c22:	00c5959b          	slliw	a1,a1,0xc
    80001c26:	00a58a33          	add	s4,a1,a0
  for (uint64 va = vaddr; va < end; va += PGSIZE)
    80001c2a:	0f457063          	bgeu	a0,s4,80001d0a <mmap_shared+0xf2>
    80001c2e:	e4a6                	sd	s1,72(sp)
    80001c30:	e0ca                	sd	s2,64(sp)
    80001c32:	fc4e                	sd	s3,56(sp)
    80001c34:	f456                	sd	s5,40(sp)
    80001c36:	f05a                	sd	s6,32(sp)
    80001c38:	ec5e                	sd	s7,24(sp)
    80001c3a:	e862                	sd	s8,16(sp)
    80001c3c:	e466                	sd	s9,8(sp)
    80001c3e:	892a                	mv	s2,a0
    80001c40:	8ab2                	mv	s5,a2
    }

    uint flags = PTE_FLAGS(*pte);
    flags |= PTE_S;

    if (protocol & PROT_READ) {
    80001c42:	0016fb93          	andi	s7,a3,1
      }
    } else {
      flags &= ~PTE_R; // make non readable
    }

    if (protocol & PROT_WRITE) {
    80001c46:	0026fc13          	andi	s8,a3,2
      }
    } else {
      flags &= ~PTE_W; // make non writable
    }

    if (protocol & PROT_EXEC) {
    80001c4a:	0046f993          	andi	s3,a3,4
      }
    } else {
      flags &= ~PTE_X; // make non exec
    }

    *pte = PA2PTE(PTE2PA(*pte)) | flags;
    80001c4e:	7b7d                	lui	s6,0xfffff
    80001c50:	002b5b13          	srli	s6,s6,0x2
  for (uint64 va = vaddr; va < end; va += PGSIZE)
    80001c54:	6c85                	lui	s9,0x1
    80001c56:	a09d                	j	80001cbc <mmap_shared+0xa4>
      cow_triggered(pte);
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	126080e7          	jalr	294(ra) # 80000d7e <cow_triggered>
    80001c60:	a8b5                	j	80001cdc <mmap_shared+0xc4>
      flags &= ~PTE_R; // make non readable
    80001c62:	3fd7f793          	andi	a5,a5,1021
    80001c66:	1007e793          	ori	a5,a5,256
    if (protocol & PROT_WRITE) {
    80001c6a:	000c0f63          	beqz	s8,80001c88 <mmap_shared+0x70>
      if (!(flags & PTE_W)) {
    80001c6e:	0047f693          	andi	a3,a5,4
    80001c72:	ee81                	bnez	a3,80001c8a <mmap_shared+0x72>
        return 3; // can't make non writeable page into writable
    80001c74:	450d                	li	a0,3
    80001c76:	64a6                	ld	s1,72(sp)
    80001c78:	6906                	ld	s2,64(sp)
    80001c7a:	79e2                	ld	s3,56(sp)
    80001c7c:	7aa2                	ld	s5,40(sp)
    80001c7e:	7b02                	ld	s6,32(sp)
    80001c80:	6be2                	ld	s7,24(sp)
    80001c82:	6c42                	ld	s8,16(sp)
    80001c84:	6ca2                	ld	s9,8(sp)
    80001c86:	a869                	j	80001d20 <mmap_shared+0x108>
      flags &= ~PTE_W; // make non writable
    80001c88:	9bed                	andi	a5,a5,-5
    if (protocol & PROT_EXEC) {
    80001c8a:	00098f63          	beqz	s3,80001ca8 <mmap_shared+0x90>
      if (!(flags & PTE_X)) {
    80001c8e:	0087f693          	andi	a3,a5,8
    80001c92:	ee81                	bnez	a3,80001caa <mmap_shared+0x92>
        return 4; // can't make non exec page into exec
    80001c94:	4511                	li	a0,4
    80001c96:	64a6                	ld	s1,72(sp)
    80001c98:	6906                	ld	s2,64(sp)
    80001c9a:	79e2                	ld	s3,56(sp)
    80001c9c:	7aa2                	ld	s5,40(sp)
    80001c9e:	7b02                	ld	s6,32(sp)
    80001ca0:	6be2                	ld	s7,24(sp)
    80001ca2:	6c42                	ld	s8,16(sp)
    80001ca4:	6ca2                	ld	s9,8(sp)
    80001ca6:	a8ad                	j	80001d20 <mmap_shared+0x108>
      flags &= ~PTE_X; // make non exec
    80001ca8:	9bdd                	andi	a5,a5,-9
    *pte = PA2PTE(PTE2PA(*pte)) | flags;
    80001caa:	01677733          	and	a4,a4,s6
    80001cae:	1782                	slli	a5,a5,0x20
    80001cb0:	9381                	srli	a5,a5,0x20
    80001cb2:	8f5d                	or	a4,a4,a5
    80001cb4:	e098                	sd	a4,0(s1)
  for (uint64 va = vaddr; va < end; va += PGSIZE)
    80001cb6:	9966                	add	s2,s2,s9
    80001cb8:	03497f63          	bgeu	s2,s4,80001cf6 <mmap_shared+0xde>
    pte_t *pte = walk(pagetable, va, 0);
    80001cbc:	4601                	li	a2,0
    80001cbe:	85ca                	mv	a1,s2
    80001cc0:	8556                	mv	a0,s5
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	64c080e7          	jalr	1612(ra) # 8000130e <walk>
    80001cca:	84aa                	mv	s1,a0
    if (pte == 0 || !(*pte & PTE_V)) {
    80001ccc:	c129                	beqz	a0,80001d0e <mmap_shared+0xf6>
    80001cce:	611c                	ld	a5,0(a0)
    80001cd0:	0017f713          	andi	a4,a5,1
    80001cd4:	cb39                	beqz	a4,80001d2a <mmap_shared+0x112>
    if (*pte & PTE_COW) {
    80001cd6:	2007f793          	andi	a5,a5,512
    80001cda:	ffbd                	bnez	a5,80001c58 <mmap_shared+0x40>
    uint flags = PTE_FLAGS(*pte);
    80001cdc:	6098                	ld	a4,0(s1)
    80001cde:	0007079b          	sext.w	a5,a4
    if (protocol & PROT_READ) {
    80001ce2:	f80b80e3          	beqz	s7,80001c62 <mmap_shared+0x4a>
      if (!(flags & PTE_R)) {
    80001ce6:	0027f693          	andi	a3,a5,2
    80001cea:	cab1                	beqz	a3,80001d3e <mmap_shared+0x126>
    uint flags = PTE_FLAGS(*pte);
    80001cec:	3ff7f793          	andi	a5,a5,1023
    flags |= PTE_S;
    80001cf0:	1007e793          	ori	a5,a5,256
    80001cf4:	bf9d                	j	80001c6a <mmap_shared+0x52>
  }

  return 0;
    80001cf6:	4501                	li	a0,0
    80001cf8:	64a6                	ld	s1,72(sp)
    80001cfa:	6906                	ld	s2,64(sp)
    80001cfc:	79e2                	ld	s3,56(sp)
    80001cfe:	7aa2                	ld	s5,40(sp)
    80001d00:	7b02                	ld	s6,32(sp)
    80001d02:	6be2                	ld	s7,24(sp)
    80001d04:	6c42                	ld	s8,16(sp)
    80001d06:	6ca2                	ld	s9,8(sp)
    80001d08:	a821                	j	80001d20 <mmap_shared+0x108>
    80001d0a:	4501                	li	a0,0
    80001d0c:	a811                	j	80001d20 <mmap_shared+0x108>
      return 1;
    80001d0e:	4505                	li	a0,1
    80001d10:	64a6                	ld	s1,72(sp)
    80001d12:	6906                	ld	s2,64(sp)
    80001d14:	79e2                	ld	s3,56(sp)
    80001d16:	7aa2                	ld	s5,40(sp)
    80001d18:	7b02                	ld	s6,32(sp)
    80001d1a:	6be2                	ld	s7,24(sp)
    80001d1c:	6c42                	ld	s8,16(sp)
    80001d1e:	6ca2                	ld	s9,8(sp)
}
    80001d20:	60e6                	ld	ra,88(sp)
    80001d22:	6446                	ld	s0,80(sp)
    80001d24:	7a42                	ld	s4,48(sp)
    80001d26:	6125                	addi	sp,sp,96
    80001d28:	8082                	ret
      return 1;
    80001d2a:	4505                	li	a0,1
    80001d2c:	64a6                	ld	s1,72(sp)
    80001d2e:	6906                	ld	s2,64(sp)
    80001d30:	79e2                	ld	s3,56(sp)
    80001d32:	7aa2                	ld	s5,40(sp)
    80001d34:	7b02                	ld	s6,32(sp)
    80001d36:	6be2                	ld	s7,24(sp)
    80001d38:	6c42                	ld	s8,16(sp)
    80001d3a:	6ca2                	ld	s9,8(sp)
    80001d3c:	b7d5                	j	80001d20 <mmap_shared+0x108>
        return 2; // can't make non readable page into readable
    80001d3e:	4509                	li	a0,2
    80001d40:	64a6                	ld	s1,72(sp)
    80001d42:	6906                	ld	s2,64(sp)
    80001d44:	79e2                	ld	s3,56(sp)
    80001d46:	7aa2                	ld	s5,40(sp)
    80001d48:	7b02                	ld	s6,32(sp)
    80001d4a:	6be2                	ld	s7,24(sp)
    80001d4c:	6c42                	ld	s8,16(sp)
    80001d4e:	6ca2                	ld	s9,8(sp)
    80001d50:	bfc1                	j	80001d20 <mmap_shared+0x108>

0000000080001d52 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001d52:	715d                	addi	sp,sp,-80
    80001d54:	e486                	sd	ra,72(sp)
    80001d56:	e0a2                	sd	s0,64(sp)
    80001d58:	fc26                	sd	s1,56(sp)
    80001d5a:	f84a                	sd	s2,48(sp)
    80001d5c:	f44e                	sd	s3,40(sp)
    80001d5e:	f052                	sd	s4,32(sp)
    80001d60:	ec56                	sd	s5,24(sp)
    80001d62:	e85a                	sd	s6,16(sp)
    80001d64:	e45e                	sd	s7,8(sp)
    80001d66:	e062                	sd	s8,0(sp)
    80001d68:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001d6a:	8792                	mv	a5,tp
    int id = r_tp();
    80001d6c:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001d6e:	0001aa97          	auipc	s5,0x1a
    80001d72:	c7aa8a93          	addi	s5,s5,-902 # 8001b9e8 <cpus>
    80001d76:	00779713          	slli	a4,a5,0x7
    80001d7a:	00ea86b3          	add	a3,s5,a4
    80001d7e:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffd2408>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001d82:	0721                	addi	a4,a4,8
    80001d84:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001d86:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001d88:	0000ac17          	auipc	s8,0xa
    80001d8c:	900c0c13          	addi	s8,s8,-1792 # 8000b688 <sched_pointer>
    80001d90:	00000b97          	auipc	s7,0x0
    80001d94:	fc2b8b93          	addi	s7,s7,-62 # 80001d52 <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001d98:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d9c:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001da0:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001da4:	0001a497          	auipc	s1,0x1a
    80001da8:	07448493          	addi	s1,s1,116 # 8001be18 <proc>
            if (p->state == RUNNABLE)
    80001dac:	498d                	li	s3,3
                p->state = RUNNING;
    80001dae:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001db0:	00020a17          	auipc	s4,0x20
    80001db4:	a68a0a13          	addi	s4,s4,-1432 # 80021818 <tickslock>
    80001db8:	a81d                	j	80001dee <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001dba:	8526                	mv	a0,s1
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	22e080e7          	jalr	558(ra) # 80000fea <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001dc4:	60a6                	ld	ra,72(sp)
    80001dc6:	6406                	ld	s0,64(sp)
    80001dc8:	74e2                	ld	s1,56(sp)
    80001dca:	7942                	ld	s2,48(sp)
    80001dcc:	79a2                	ld	s3,40(sp)
    80001dce:	7a02                	ld	s4,32(sp)
    80001dd0:	6ae2                	ld	s5,24(sp)
    80001dd2:	6b42                	ld	s6,16(sp)
    80001dd4:	6ba2                	ld	s7,8(sp)
    80001dd6:	6c02                	ld	s8,0(sp)
    80001dd8:	6161                	addi	sp,sp,80
    80001dda:	8082                	ret
            release(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	20c080e7          	jalr	524(ra) # 80000fea <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001de6:	16848493          	addi	s1,s1,360
    80001dea:	fb4487e3          	beq	s1,s4,80001d98 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001dee:	8526                	mv	a0,s1
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	146080e7          	jalr	326(ra) # 80000f36 <acquire>
            if (p->state == RUNNABLE)
    80001df8:	4c9c                	lw	a5,24(s1)
    80001dfa:	ff3791e3          	bne	a5,s3,80001ddc <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001dfe:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001e02:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001e06:	06048593          	addi	a1,s1,96
    80001e0a:	8556                	mv	a0,s5
    80001e0c:	00001097          	auipc	ra,0x1
    80001e10:	044080e7          	jalr	68(ra) # 80002e50 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001e14:	000c3783          	ld	a5,0(s8)
    80001e18:	fb7791e3          	bne	a5,s7,80001dba <rr_scheduler+0x68>
                c->proc = 0;
    80001e1c:	00093023          	sd	zero,0(s2)
    80001e20:	bf75                	j	80001ddc <rr_scheduler+0x8a>

0000000080001e22 <proc_mapstacks>:
{
    80001e22:	7139                	addi	sp,sp,-64
    80001e24:	fc06                	sd	ra,56(sp)
    80001e26:	f822                	sd	s0,48(sp)
    80001e28:	f426                	sd	s1,40(sp)
    80001e2a:	f04a                	sd	s2,32(sp)
    80001e2c:	ec4e                	sd	s3,24(sp)
    80001e2e:	e852                	sd	s4,16(sp)
    80001e30:	e456                	sd	s5,8(sp)
    80001e32:	e05a                	sd	s6,0(sp)
    80001e34:	0080                	addi	s0,sp,64
    80001e36:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001e38:	0001a497          	auipc	s1,0x1a
    80001e3c:	fe048493          	addi	s1,s1,-32 # 8001be18 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001e40:	8b26                	mv	s6,s1
    80001e42:	04fa5937          	lui	s2,0x4fa5
    80001e46:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001e4a:	0932                	slli	s2,s2,0xc
    80001e4c:	fa590913          	addi	s2,s2,-91
    80001e50:	0932                	slli	s2,s2,0xc
    80001e52:	fa590913          	addi	s2,s2,-91
    80001e56:	0932                	slli	s2,s2,0xc
    80001e58:	fa590913          	addi	s2,s2,-91
    80001e5c:	040009b7          	lui	s3,0x4000
    80001e60:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001e62:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001e64:	00020a97          	auipc	s5,0x20
    80001e68:	9b4a8a93          	addi	s5,s5,-1612 # 80021818 <tickslock>
        char *pa = kalloc();
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	e1a080e7          	jalr	-486(ra) # 80000c86 <kalloc>
    80001e74:	862a                	mv	a2,a0
        if (pa == 0)
    80001e76:	c121                	beqz	a0,80001eb6 <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001e78:	416485b3          	sub	a1,s1,s6
    80001e7c:	858d                	srai	a1,a1,0x3
    80001e7e:	032585b3          	mul	a1,a1,s2
    80001e82:	2585                	addiw	a1,a1,1
    80001e84:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001e88:	4719                	li	a4,6
    80001e8a:	6685                	lui	a3,0x1
    80001e8c:	40b985b3          	sub	a1,s3,a1
    80001e90:	8552                	mv	a0,s4
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	604080e7          	jalr	1540(ra) # 80001496 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e9a:	16848493          	addi	s1,s1,360
    80001e9e:	fd5497e3          	bne	s1,s5,80001e6c <proc_mapstacks+0x4a>
}
    80001ea2:	70e2                	ld	ra,56(sp)
    80001ea4:	7442                	ld	s0,48(sp)
    80001ea6:	74a2                	ld	s1,40(sp)
    80001ea8:	7902                	ld	s2,32(sp)
    80001eaa:	69e2                	ld	s3,24(sp)
    80001eac:	6a42                	ld	s4,16(sp)
    80001eae:	6aa2                	ld	s5,8(sp)
    80001eb0:	6b02                	ld	s6,0(sp)
    80001eb2:	6121                	addi	sp,sp,64
    80001eb4:	8082                	ret
            panic("kalloc");
    80001eb6:	00006517          	auipc	a0,0x6
    80001eba:	38a50513          	addi	a0,a0,906 # 80008240 <__func__.1+0x238>
    80001ebe:	ffffe097          	auipc	ra,0xffffe
    80001ec2:	6a2080e7          	jalr	1698(ra) # 80000560 <panic>

0000000080001ec6 <procinit>:
{
    80001ec6:	7139                	addi	sp,sp,-64
    80001ec8:	fc06                	sd	ra,56(sp)
    80001eca:	f822                	sd	s0,48(sp)
    80001ecc:	f426                	sd	s1,40(sp)
    80001ece:	f04a                	sd	s2,32(sp)
    80001ed0:	ec4e                	sd	s3,24(sp)
    80001ed2:	e852                	sd	s4,16(sp)
    80001ed4:	e456                	sd	s5,8(sp)
    80001ed6:	e05a                	sd	s6,0(sp)
    80001ed8:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001eda:	00006597          	auipc	a1,0x6
    80001ede:	36e58593          	addi	a1,a1,878 # 80008248 <__func__.1+0x240>
    80001ee2:	0001a517          	auipc	a0,0x1a
    80001ee6:	f0650513          	addi	a0,a0,-250 # 8001bde8 <pid_lock>
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	fbc080e7          	jalr	-68(ra) # 80000ea6 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001ef2:	00006597          	auipc	a1,0x6
    80001ef6:	35e58593          	addi	a1,a1,862 # 80008250 <__func__.1+0x248>
    80001efa:	0001a517          	auipc	a0,0x1a
    80001efe:	f0650513          	addi	a0,a0,-250 # 8001be00 <wait_lock>
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	fa4080e7          	jalr	-92(ra) # 80000ea6 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f0a:	0001a497          	auipc	s1,0x1a
    80001f0e:	f0e48493          	addi	s1,s1,-242 # 8001be18 <proc>
        initlock(&p->lock, "proc");
    80001f12:	00006b17          	auipc	s6,0x6
    80001f16:	34eb0b13          	addi	s6,s6,846 # 80008260 <__func__.1+0x258>
        p->kstack = KSTACK((int)(p - proc));
    80001f1a:	8aa6                	mv	s5,s1
    80001f1c:	04fa5937          	lui	s2,0x4fa5
    80001f20:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001f24:	0932                	slli	s2,s2,0xc
    80001f26:	fa590913          	addi	s2,s2,-91
    80001f2a:	0932                	slli	s2,s2,0xc
    80001f2c:	fa590913          	addi	s2,s2,-91
    80001f30:	0932                	slli	s2,s2,0xc
    80001f32:	fa590913          	addi	s2,s2,-91
    80001f36:	040009b7          	lui	s3,0x4000
    80001f3a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001f3c:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001f3e:	00020a17          	auipc	s4,0x20
    80001f42:	8daa0a13          	addi	s4,s4,-1830 # 80021818 <tickslock>
        initlock(&p->lock, "proc");
    80001f46:	85da                	mv	a1,s6
    80001f48:	8526                	mv	a0,s1
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	f5c080e7          	jalr	-164(ra) # 80000ea6 <initlock>
        p->state = UNUSED;
    80001f52:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001f56:	415487b3          	sub	a5,s1,s5
    80001f5a:	878d                	srai	a5,a5,0x3
    80001f5c:	032787b3          	mul	a5,a5,s2
    80001f60:	2785                	addiw	a5,a5,1
    80001f62:	00d7979b          	slliw	a5,a5,0xd
    80001f66:	40f987b3          	sub	a5,s3,a5
    80001f6a:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001f6c:	16848493          	addi	s1,s1,360
    80001f70:	fd449be3          	bne	s1,s4,80001f46 <procinit+0x80>
}
    80001f74:	70e2                	ld	ra,56(sp)
    80001f76:	7442                	ld	s0,48(sp)
    80001f78:	74a2                	ld	s1,40(sp)
    80001f7a:	7902                	ld	s2,32(sp)
    80001f7c:	69e2                	ld	s3,24(sp)
    80001f7e:	6a42                	ld	s4,16(sp)
    80001f80:	6aa2                	ld	s5,8(sp)
    80001f82:	6b02                	ld	s6,0(sp)
    80001f84:	6121                	addi	sp,sp,64
    80001f86:	8082                	ret

0000000080001f88 <copy_array>:
{
    80001f88:	1141                	addi	sp,sp,-16
    80001f8a:	e422                	sd	s0,8(sp)
    80001f8c:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001f8e:	00c05c63          	blez	a2,80001fa6 <copy_array+0x1e>
    80001f92:	87aa                	mv	a5,a0
    80001f94:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001f96:	0007c703          	lbu	a4,0(a5)
    80001f9a:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001f9e:	0785                	addi	a5,a5,1
    80001fa0:	0585                	addi	a1,a1,1
    80001fa2:	fea79ae3          	bne	a5,a0,80001f96 <copy_array+0xe>
}
    80001fa6:	6422                	ld	s0,8(sp)
    80001fa8:	0141                	addi	sp,sp,16
    80001faa:	8082                	ret

0000000080001fac <cpuid>:
{
    80001fac:	1141                	addi	sp,sp,-16
    80001fae:	e422                	sd	s0,8(sp)
    80001fb0:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001fb2:	8512                	mv	a0,tp
}
    80001fb4:	2501                	sext.w	a0,a0
    80001fb6:	6422                	ld	s0,8(sp)
    80001fb8:	0141                	addi	sp,sp,16
    80001fba:	8082                	ret

0000000080001fbc <mycpu>:
{
    80001fbc:	1141                	addi	sp,sp,-16
    80001fbe:	e422                	sd	s0,8(sp)
    80001fc0:	0800                	addi	s0,sp,16
    80001fc2:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001fc4:	2781                	sext.w	a5,a5
    80001fc6:	079e                	slli	a5,a5,0x7
}
    80001fc8:	0001a517          	auipc	a0,0x1a
    80001fcc:	a2050513          	addi	a0,a0,-1504 # 8001b9e8 <cpus>
    80001fd0:	953e                	add	a0,a0,a5
    80001fd2:	6422                	ld	s0,8(sp)
    80001fd4:	0141                	addi	sp,sp,16
    80001fd6:	8082                	ret

0000000080001fd8 <myproc>:
{
    80001fd8:	1101                	addi	sp,sp,-32
    80001fda:	ec06                	sd	ra,24(sp)
    80001fdc:	e822                	sd	s0,16(sp)
    80001fde:	e426                	sd	s1,8(sp)
    80001fe0:	1000                	addi	s0,sp,32
    push_off();
    80001fe2:	fffff097          	auipc	ra,0xfffff
    80001fe6:	f08080e7          	jalr	-248(ra) # 80000eea <push_off>
    80001fea:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001fec:	2781                	sext.w	a5,a5
    80001fee:	079e                	slli	a5,a5,0x7
    80001ff0:	0001a717          	auipc	a4,0x1a
    80001ff4:	9f870713          	addi	a4,a4,-1544 # 8001b9e8 <cpus>
    80001ff8:	97ba                	add	a5,a5,a4
    80001ffa:	6384                	ld	s1,0(a5)
    pop_off();
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	f8e080e7          	jalr	-114(ra) # 80000f8a <pop_off>
}
    80002004:	8526                	mv	a0,s1
    80002006:	60e2                	ld	ra,24(sp)
    80002008:	6442                	ld	s0,16(sp)
    8000200a:	64a2                	ld	s1,8(sp)
    8000200c:	6105                	addi	sp,sp,32
    8000200e:	8082                	ret

0000000080002010 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80002010:	1141                	addi	sp,sp,-16
    80002012:	e406                	sd	ra,8(sp)
    80002014:	e022                	sd	s0,0(sp)
    80002016:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80002018:	00000097          	auipc	ra,0x0
    8000201c:	fc0080e7          	jalr	-64(ra) # 80001fd8 <myproc>
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	fca080e7          	jalr	-54(ra) # 80000fea <release>

    if (first)
    80002028:	00009797          	auipc	a5,0x9
    8000202c:	6587a783          	lw	a5,1624(a5) # 8000b680 <first.1>
    80002030:	eb89                	bnez	a5,80002042 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80002032:	00001097          	auipc	ra,0x1
    80002036:	ec8080e7          	jalr	-312(ra) # 80002efa <usertrapret>
}
    8000203a:	60a2                	ld	ra,8(sp)
    8000203c:	6402                	ld	s0,0(sp)
    8000203e:	0141                	addi	sp,sp,16
    80002040:	8082                	ret
        first = 0;
    80002042:	00009797          	auipc	a5,0x9
    80002046:	6207af23          	sw	zero,1598(a5) # 8000b680 <first.1>
        fsinit(ROOTDEV);
    8000204a:	4505                	li	a0,1
    8000204c:	00002097          	auipc	ra,0x2
    80002050:	e70080e7          	jalr	-400(ra) # 80003ebc <fsinit>
    80002054:	bff9                	j	80002032 <forkret+0x22>

0000000080002056 <allocpid>:
{
    80002056:	1101                	addi	sp,sp,-32
    80002058:	ec06                	sd	ra,24(sp)
    8000205a:	e822                	sd	s0,16(sp)
    8000205c:	e426                	sd	s1,8(sp)
    8000205e:	e04a                	sd	s2,0(sp)
    80002060:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80002062:	0001a917          	auipc	s2,0x1a
    80002066:	d8690913          	addi	s2,s2,-634 # 8001bde8 <pid_lock>
    8000206a:	854a                	mv	a0,s2
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	eca080e7          	jalr	-310(ra) # 80000f36 <acquire>
    pid = nextpid;
    80002074:	00009797          	auipc	a5,0x9
    80002078:	61c78793          	addi	a5,a5,1564 # 8000b690 <nextpid>
    8000207c:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    8000207e:	0014871b          	addiw	a4,s1,1
    80002082:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80002084:	854a                	mv	a0,s2
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	f64080e7          	jalr	-156(ra) # 80000fea <release>
}
    8000208e:	8526                	mv	a0,s1
    80002090:	60e2                	ld	ra,24(sp)
    80002092:	6442                	ld	s0,16(sp)
    80002094:	64a2                	ld	s1,8(sp)
    80002096:	6902                	ld	s2,0(sp)
    80002098:	6105                	addi	sp,sp,32
    8000209a:	8082                	ret

000000008000209c <proc_pagetable>:
{
    8000209c:	1101                	addi	sp,sp,-32
    8000209e:	ec06                	sd	ra,24(sp)
    800020a0:	e822                	sd	s0,16(sp)
    800020a2:	e426                	sd	s1,8(sp)
    800020a4:	e04a                	sd	s2,0(sp)
    800020a6:	1000                	addi	s0,sp,32
    800020a8:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	5e6080e7          	jalr	1510(ra) # 80001690 <uvmcreate>
    800020b2:	84aa                	mv	s1,a0
    if (pagetable == 0)
    800020b4:	c121                	beqz	a0,800020f4 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    800020b6:	4729                	li	a4,10
    800020b8:	00005697          	auipc	a3,0x5
    800020bc:	f4868693          	addi	a3,a3,-184 # 80007000 <_trampoline>
    800020c0:	6605                	lui	a2,0x1
    800020c2:	040005b7          	lui	a1,0x4000
    800020c6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800020c8:	05b2                	slli	a1,a1,0xc
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	32c080e7          	jalr	812(ra) # 800013f6 <mappages>
    800020d2:	02054863          	bltz	a0,80002102 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    800020d6:	4719                	li	a4,6
    800020d8:	05893683          	ld	a3,88(s2)
    800020dc:	6605                	lui	a2,0x1
    800020de:	020005b7          	lui	a1,0x2000
    800020e2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800020e4:	05b6                	slli	a1,a1,0xd
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	30e080e7          	jalr	782(ra) # 800013f6 <mappages>
    800020f0:	02054163          	bltz	a0,80002112 <proc_pagetable+0x76>
}
    800020f4:	8526                	mv	a0,s1
    800020f6:	60e2                	ld	ra,24(sp)
    800020f8:	6442                	ld	s0,16(sp)
    800020fa:	64a2                	ld	s1,8(sp)
    800020fc:	6902                	ld	s2,0(sp)
    800020fe:	6105                	addi	sp,sp,32
    80002100:	8082                	ret
        uvmfree(pagetable, 0);
    80002102:	4581                	li	a1,0
    80002104:	8526                	mv	a0,s1
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	79c080e7          	jalr	1948(ra) # 800018a2 <uvmfree>
        return 0;
    8000210e:	4481                	li	s1,0
    80002110:	b7d5                	j	800020f4 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002112:	4681                	li	a3,0
    80002114:	4605                	li	a2,1
    80002116:	040005b7          	lui	a1,0x4000
    8000211a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000211c:	05b2                	slli	a1,a1,0xc
    8000211e:	8526                	mv	a0,s1
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	49c080e7          	jalr	1180(ra) # 800015bc <uvmunmap>
        uvmfree(pagetable, 0);
    80002128:	4581                	li	a1,0
    8000212a:	8526                	mv	a0,s1
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	776080e7          	jalr	1910(ra) # 800018a2 <uvmfree>
        return 0;
    80002134:	4481                	li	s1,0
    80002136:	bf7d                	j	800020f4 <proc_pagetable+0x58>

0000000080002138 <proc_freepagetable>:
{
    80002138:	1101                	addi	sp,sp,-32
    8000213a:	ec06                	sd	ra,24(sp)
    8000213c:	e822                	sd	s0,16(sp)
    8000213e:	e426                	sd	s1,8(sp)
    80002140:	e04a                	sd	s2,0(sp)
    80002142:	1000                	addi	s0,sp,32
    80002144:	84aa                	mv	s1,a0
    80002146:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002148:	4681                	li	a3,0
    8000214a:	4605                	li	a2,1
    8000214c:	040005b7          	lui	a1,0x4000
    80002150:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002152:	05b2                	slli	a1,a1,0xc
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	468080e7          	jalr	1128(ra) # 800015bc <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000215c:	4681                	li	a3,0
    8000215e:	4605                	li	a2,1
    80002160:	020005b7          	lui	a1,0x2000
    80002164:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002166:	05b6                	slli	a1,a1,0xd
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	452080e7          	jalr	1106(ra) # 800015bc <uvmunmap>
    uvmfree(pagetable, sz);
    80002172:	85ca                	mv	a1,s2
    80002174:	8526                	mv	a0,s1
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	72c080e7          	jalr	1836(ra) # 800018a2 <uvmfree>
}
    8000217e:	60e2                	ld	ra,24(sp)
    80002180:	6442                	ld	s0,16(sp)
    80002182:	64a2                	ld	s1,8(sp)
    80002184:	6902                	ld	s2,0(sp)
    80002186:	6105                	addi	sp,sp,32
    80002188:	8082                	ret

000000008000218a <freeproc>:
{
    8000218a:	1101                	addi	sp,sp,-32
    8000218c:	ec06                	sd	ra,24(sp)
    8000218e:	e822                	sd	s0,16(sp)
    80002190:	e426                	sd	s1,8(sp)
    80002192:	1000                	addi	s0,sp,32
    80002194:	84aa                	mv	s1,a0
    if (p->trapframe)
    80002196:	6d28                	ld	a0,88(a0)
    80002198:	c509                	beqz	a0,800021a2 <freeproc+0x18>
        kfree((void *)p->trapframe);
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	8fa080e7          	jalr	-1798(ra) # 80000a94 <kfree>
    p->trapframe = 0;
    800021a2:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    800021a6:	68a8                	ld	a0,80(s1)
    800021a8:	c511                	beqz	a0,800021b4 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    800021aa:	64ac                	ld	a1,72(s1)
    800021ac:	00000097          	auipc	ra,0x0
    800021b0:	f8c080e7          	jalr	-116(ra) # 80002138 <proc_freepagetable>
    p->pagetable = 0;
    800021b4:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    800021b8:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    800021bc:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    800021c0:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    800021c4:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    800021c8:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    800021cc:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    800021d0:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    800021d4:	0004ac23          	sw	zero,24(s1)
}
    800021d8:	60e2                	ld	ra,24(sp)
    800021da:	6442                	ld	s0,16(sp)
    800021dc:	64a2                	ld	s1,8(sp)
    800021de:	6105                	addi	sp,sp,32
    800021e0:	8082                	ret

00000000800021e2 <allocproc>:
{
    800021e2:	1101                	addi	sp,sp,-32
    800021e4:	ec06                	sd	ra,24(sp)
    800021e6:	e822                	sd	s0,16(sp)
    800021e8:	e426                	sd	s1,8(sp)
    800021ea:	e04a                	sd	s2,0(sp)
    800021ec:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    800021ee:	0001a497          	auipc	s1,0x1a
    800021f2:	c2a48493          	addi	s1,s1,-982 # 8001be18 <proc>
    800021f6:	0001f917          	auipc	s2,0x1f
    800021fa:	62290913          	addi	s2,s2,1570 # 80021818 <tickslock>
        acquire(&p->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	d36080e7          	jalr	-714(ra) # 80000f36 <acquire>
        if (p->state == UNUSED)
    80002208:	4c9c                	lw	a5,24(s1)
    8000220a:	cf81                	beqz	a5,80002222 <allocproc+0x40>
            release(&p->lock);
    8000220c:	8526                	mv	a0,s1
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	ddc080e7          	jalr	-548(ra) # 80000fea <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002216:	16848493          	addi	s1,s1,360
    8000221a:	ff2492e3          	bne	s1,s2,800021fe <allocproc+0x1c>
    return 0;
    8000221e:	4481                	li	s1,0
    80002220:	a889                	j	80002272 <allocproc+0x90>
    p->pid = allocpid();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	e34080e7          	jalr	-460(ra) # 80002056 <allocpid>
    8000222a:	d888                	sw	a0,48(s1)
    p->state = USED;
    8000222c:	4785                	li	a5,1
    8000222e:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	a56080e7          	jalr	-1450(ra) # 80000c86 <kalloc>
    80002238:	892a                	mv	s2,a0
    8000223a:	eca8                	sd	a0,88(s1)
    8000223c:	c131                	beqz	a0,80002280 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    8000223e:	8526                	mv	a0,s1
    80002240:	00000097          	auipc	ra,0x0
    80002244:	e5c080e7          	jalr	-420(ra) # 8000209c <proc_pagetable>
    80002248:	892a                	mv	s2,a0
    8000224a:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    8000224c:	c531                	beqz	a0,80002298 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    8000224e:	07000613          	li	a2,112
    80002252:	4581                	li	a1,0
    80002254:	06048513          	addi	a0,s1,96
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	dda080e7          	jalr	-550(ra) # 80001032 <memset>
    p->context.ra = (uint64)forkret;
    80002260:	00000797          	auipc	a5,0x0
    80002264:	db078793          	addi	a5,a5,-592 # 80002010 <forkret>
    80002268:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    8000226a:	60bc                	ld	a5,64(s1)
    8000226c:	6705                	lui	a4,0x1
    8000226e:	97ba                	add	a5,a5,a4
    80002270:	f4bc                	sd	a5,104(s1)
}
    80002272:	8526                	mv	a0,s1
    80002274:	60e2                	ld	ra,24(sp)
    80002276:	6442                	ld	s0,16(sp)
    80002278:	64a2                	ld	s1,8(sp)
    8000227a:	6902                	ld	s2,0(sp)
    8000227c:	6105                	addi	sp,sp,32
    8000227e:	8082                	ret
        freeproc(p);
    80002280:	8526                	mv	a0,s1
    80002282:	00000097          	auipc	ra,0x0
    80002286:	f08080e7          	jalr	-248(ra) # 8000218a <freeproc>
        release(&p->lock);
    8000228a:	8526                	mv	a0,s1
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	d5e080e7          	jalr	-674(ra) # 80000fea <release>
        return 0;
    80002294:	84ca                	mv	s1,s2
    80002296:	bff1                	j	80002272 <allocproc+0x90>
        freeproc(p);
    80002298:	8526                	mv	a0,s1
    8000229a:	00000097          	auipc	ra,0x0
    8000229e:	ef0080e7          	jalr	-272(ra) # 8000218a <freeproc>
        release(&p->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	d46080e7          	jalr	-698(ra) # 80000fea <release>
        return 0;
    800022ac:	84ca                	mv	s1,s2
    800022ae:	b7d1                	j	80002272 <allocproc+0x90>

00000000800022b0 <userinit>:
{
    800022b0:	1101                	addi	sp,sp,-32
    800022b2:	ec06                	sd	ra,24(sp)
    800022b4:	e822                	sd	s0,16(sp)
    800022b6:	e426                	sd	s1,8(sp)
    800022b8:	1000                	addi	s0,sp,32
    p = allocproc();
    800022ba:	00000097          	auipc	ra,0x0
    800022be:	f28080e7          	jalr	-216(ra) # 800021e2 <allocproc>
    800022c2:	84aa                	mv	s1,a0
    initproc = p;
    800022c4:	00009797          	auipc	a5,0x9
    800022c8:	48a7ba23          	sd	a0,1172(a5) # 8000b758 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800022cc:	03400613          	li	a2,52
    800022d0:	00009597          	auipc	a1,0x9
    800022d4:	3d058593          	addi	a1,a1,976 # 8000b6a0 <initcode>
    800022d8:	6928                	ld	a0,80(a0)
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	3e4080e7          	jalr	996(ra) # 800016be <uvmfirst>
    p->sz = PGSIZE;
    800022e2:	6785                	lui	a5,0x1
    800022e4:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    800022e6:	6cb8                	ld	a4,88(s1)
    800022e8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    800022ec:	6cb8                	ld	a4,88(s1)
    800022ee:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    800022f0:	4641                	li	a2,16
    800022f2:	00006597          	auipc	a1,0x6
    800022f6:	f7658593          	addi	a1,a1,-138 # 80008268 <__func__.1+0x260>
    800022fa:	15848513          	addi	a0,s1,344
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	e76080e7          	jalr	-394(ra) # 80001174 <safestrcpy>
    p->cwd = namei("/");
    80002306:	00006517          	auipc	a0,0x6
    8000230a:	f7250513          	addi	a0,a0,-142 # 80008278 <__func__.1+0x270>
    8000230e:	00002097          	auipc	ra,0x2
    80002312:	600080e7          	jalr	1536(ra) # 8000490e <namei>
    80002316:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    8000231a:	478d                	li	a5,3
    8000231c:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	cca080e7          	jalr	-822(ra) # 80000fea <release>
}
    80002328:	60e2                	ld	ra,24(sp)
    8000232a:	6442                	ld	s0,16(sp)
    8000232c:	64a2                	ld	s1,8(sp)
    8000232e:	6105                	addi	sp,sp,32
    80002330:	8082                	ret

0000000080002332 <growproc>:
{
    80002332:	1101                	addi	sp,sp,-32
    80002334:	ec06                	sd	ra,24(sp)
    80002336:	e822                	sd	s0,16(sp)
    80002338:	e426                	sd	s1,8(sp)
    8000233a:	e04a                	sd	s2,0(sp)
    8000233c:	1000                	addi	s0,sp,32
    8000233e:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002340:	00000097          	auipc	ra,0x0
    80002344:	c98080e7          	jalr	-872(ra) # 80001fd8 <myproc>
    80002348:	84aa                	mv	s1,a0
    sz = p->sz;
    8000234a:	652c                	ld	a1,72(a0)
    if (n > 0)
    8000234c:	01204c63          	bgtz	s2,80002364 <growproc+0x32>
    else if (n < 0)
    80002350:	02094663          	bltz	s2,8000237c <growproc+0x4a>
    p->sz = sz;
    80002354:	e4ac                	sd	a1,72(s1)
    return 0;
    80002356:	4501                	li	a0,0
}
    80002358:	60e2                	ld	ra,24(sp)
    8000235a:	6442                	ld	s0,16(sp)
    8000235c:	64a2                	ld	s1,8(sp)
    8000235e:	6902                	ld	s2,0(sp)
    80002360:	6105                	addi	sp,sp,32
    80002362:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002364:	4691                	li	a3,4
    80002366:	00b90633          	add	a2,s2,a1
    8000236a:	6928                	ld	a0,80(a0)
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	40c080e7          	jalr	1036(ra) # 80001778 <uvmalloc>
    80002374:	85aa                	mv	a1,a0
    80002376:	fd79                	bnez	a0,80002354 <growproc+0x22>
            return -1;
    80002378:	557d                	li	a0,-1
    8000237a:	bff9                	j	80002358 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000237c:	00b90633          	add	a2,s2,a1
    80002380:	6928                	ld	a0,80(a0)
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	3ae080e7          	jalr	942(ra) # 80001730 <uvmdealloc>
    8000238a:	85aa                	mv	a1,a0
    8000238c:	b7e1                	j	80002354 <growproc+0x22>

000000008000238e <ps>:
{
    8000238e:	715d                	addi	sp,sp,-80
    80002390:	e486                	sd	ra,72(sp)
    80002392:	e0a2                	sd	s0,64(sp)
    80002394:	fc26                	sd	s1,56(sp)
    80002396:	f84a                	sd	s2,48(sp)
    80002398:	f44e                	sd	s3,40(sp)
    8000239a:	f052                	sd	s4,32(sp)
    8000239c:	ec56                	sd	s5,24(sp)
    8000239e:	e85a                	sd	s6,16(sp)
    800023a0:	e45e                	sd	s7,8(sp)
    800023a2:	e062                	sd	s8,0(sp)
    800023a4:	0880                	addi	s0,sp,80
    800023a6:	84aa                	mv	s1,a0
    800023a8:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    800023aa:	00000097          	auipc	ra,0x0
    800023ae:	c2e080e7          	jalr	-978(ra) # 80001fd8 <myproc>
        return result;
    800023b2:	4901                	li	s2,0
    if (count == 0)
    800023b4:	0c0b8663          	beqz	s7,80002480 <ps+0xf2>
    void *result = (void *)myproc()->sz;
    800023b8:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    800023bc:	003b951b          	slliw	a0,s7,0x3
    800023c0:	0175053b          	addw	a0,a0,s7
    800023c4:	0025151b          	slliw	a0,a0,0x2
    800023c8:	2501                	sext.w	a0,a0
    800023ca:	00000097          	auipc	ra,0x0
    800023ce:	f68080e7          	jalr	-152(ra) # 80002332 <growproc>
    800023d2:	12054f63          	bltz	a0,80002510 <ps+0x182>
    struct user_proc loc_result[count];
    800023d6:	003b9a13          	slli	s4,s7,0x3
    800023da:	9a5e                	add	s4,s4,s7
    800023dc:	0a0a                	slli	s4,s4,0x2
    800023de:	00fa0793          	addi	a5,s4,15
    800023e2:	8391                	srli	a5,a5,0x4
    800023e4:	0792                	slli	a5,a5,0x4
    800023e6:	40f10133          	sub	sp,sp,a5
    800023ea:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800023ec:	16800793          	li	a5,360
    800023f0:	02f484b3          	mul	s1,s1,a5
    800023f4:	0001a797          	auipc	a5,0x1a
    800023f8:	a2478793          	addi	a5,a5,-1500 # 8001be18 <proc>
    800023fc:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800023fe:	0001f797          	auipc	a5,0x1f
    80002402:	41a78793          	addi	a5,a5,1050 # 80021818 <tickslock>
        return result;
    80002406:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80002408:	06f4fc63          	bgeu	s1,a5,80002480 <ps+0xf2>
    acquire(&wait_lock);
    8000240c:	0001a517          	auipc	a0,0x1a
    80002410:	9f450513          	addi	a0,a0,-1548 # 8001be00 <wait_lock>
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	b22080e7          	jalr	-1246(ra) # 80000f36 <acquire>
        if (localCount == count)
    8000241c:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002420:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002422:	0001fc17          	auipc	s8,0x1f
    80002426:	3f6c0c13          	addi	s8,s8,1014 # 80021818 <tickslock>
    8000242a:	a851                	j	800024be <ps+0x130>
            loc_result[localCount].state = UNUSED;
    8000242c:	00399793          	slli	a5,s3,0x3
    80002430:	97ce                	add	a5,a5,s3
    80002432:	078a                	slli	a5,a5,0x2
    80002434:	97d6                	add	a5,a5,s5
    80002436:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	bae080e7          	jalr	-1106(ra) # 80000fea <release>
    release(&wait_lock);
    80002444:	0001a517          	auipc	a0,0x1a
    80002448:	9bc50513          	addi	a0,a0,-1604 # 8001be00 <wait_lock>
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	b9e080e7          	jalr	-1122(ra) # 80000fea <release>
    if (localCount < count)
    80002454:	0179f963          	bgeu	s3,s7,80002466 <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002458:	00399793          	slli	a5,s3,0x3
    8000245c:	97ce                	add	a5,a5,s3
    8000245e:	078a                	slli	a5,a5,0x2
    80002460:	97d6                	add	a5,a5,s5
    80002462:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002466:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002468:	00000097          	auipc	ra,0x0
    8000246c:	b70080e7          	jalr	-1168(ra) # 80001fd8 <myproc>
    80002470:	86d2                	mv	a3,s4
    80002472:	8656                	mv	a2,s5
    80002474:	85da                	mv	a1,s6
    80002476:	6928                	ld	a0,80(a0)
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	56e080e7          	jalr	1390(ra) # 800019e6 <copyout>
}
    80002480:	854a                	mv	a0,s2
    80002482:	fb040113          	addi	sp,s0,-80
    80002486:	60a6                	ld	ra,72(sp)
    80002488:	6406                	ld	s0,64(sp)
    8000248a:	74e2                	ld	s1,56(sp)
    8000248c:	7942                	ld	s2,48(sp)
    8000248e:	79a2                	ld	s3,40(sp)
    80002490:	7a02                	ld	s4,32(sp)
    80002492:	6ae2                	ld	s5,24(sp)
    80002494:	6b42                	ld	s6,16(sp)
    80002496:	6ba2                	ld	s7,8(sp)
    80002498:	6c02                	ld	s8,0(sp)
    8000249a:	6161                	addi	sp,sp,80
    8000249c:	8082                	ret
        release(&p->lock);
    8000249e:	8526                	mv	a0,s1
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	b4a080e7          	jalr	-1206(ra) # 80000fea <release>
        localCount++;
    800024a8:	2985                	addiw	s3,s3,1
    800024aa:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800024ae:	16848493          	addi	s1,s1,360
    800024b2:	f984f9e3          	bgeu	s1,s8,80002444 <ps+0xb6>
        if (localCount == count)
    800024b6:	02490913          	addi	s2,s2,36
    800024ba:	053b8d63          	beq	s7,s3,80002514 <ps+0x186>
        acquire(&p->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	fffff097          	auipc	ra,0xfffff
    800024c4:	a76080e7          	jalr	-1418(ra) # 80000f36 <acquire>
        if (p->state == UNUSED)
    800024c8:	4c9c                	lw	a5,24(s1)
    800024ca:	d3ad                	beqz	a5,8000242c <ps+0x9e>
        loc_result[localCount].state = p->state;
    800024cc:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800024d0:	549c                	lw	a5,40(s1)
    800024d2:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800024d6:	54dc                	lw	a5,44(s1)
    800024d8:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800024dc:	589c                	lw	a5,48(s1)
    800024de:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800024e2:	4641                	li	a2,16
    800024e4:	85ca                	mv	a1,s2
    800024e6:	15848513          	addi	a0,s1,344
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	a9e080e7          	jalr	-1378(ra) # 80001f88 <copy_array>
        if (p->parent != 0) // init
    800024f2:	7c88                	ld	a0,56(s1)
    800024f4:	d54d                	beqz	a0,8000249e <ps+0x110>
            acquire(&p->parent->lock);
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	a40080e7          	jalr	-1472(ra) # 80000f36 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800024fe:	7c88                	ld	a0,56(s1)
    80002500:	591c                	lw	a5,48(a0)
    80002502:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	ae4080e7          	jalr	-1308(ra) # 80000fea <release>
    8000250e:	bf41                	j	8000249e <ps+0x110>
        return result;
    80002510:	4901                	li	s2,0
    80002512:	b7bd                	j	80002480 <ps+0xf2>
    release(&wait_lock);
    80002514:	0001a517          	auipc	a0,0x1a
    80002518:	8ec50513          	addi	a0,a0,-1812 # 8001be00 <wait_lock>
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	ace080e7          	jalr	-1330(ra) # 80000fea <release>
    if (localCount < count)
    80002524:	b789                	j	80002466 <ps+0xd8>

0000000080002526 <fork>:
{
    80002526:	7139                	addi	sp,sp,-64
    80002528:	fc06                	sd	ra,56(sp)
    8000252a:	f822                	sd	s0,48(sp)
    8000252c:	f04a                	sd	s2,32(sp)
    8000252e:	e456                	sd	s5,8(sp)
    80002530:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002532:	00000097          	auipc	ra,0x0
    80002536:	aa6080e7          	jalr	-1370(ra) # 80001fd8 <myproc>
    8000253a:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    8000253c:	00000097          	auipc	ra,0x0
    80002540:	ca6080e7          	jalr	-858(ra) # 800021e2 <allocproc>
    80002544:	12050063          	beqz	a0,80002664 <fork+0x13e>
    80002548:	e852                	sd	s4,16(sp)
    8000254a:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000254c:	048ab603          	ld	a2,72(s5)
    80002550:	692c                	ld	a1,80(a0)
    80002552:	050ab503          	ld	a0,80(s5)
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	386080e7          	jalr	902(ra) # 800018dc <uvmcopy>
    8000255e:	04054a63          	bltz	a0,800025b2 <fork+0x8c>
    80002562:	f426                	sd	s1,40(sp)
    80002564:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    80002566:	048ab783          	ld	a5,72(s5)
    8000256a:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    8000256e:	058ab683          	ld	a3,88(s5)
    80002572:	87b6                	mv	a5,a3
    80002574:	058a3703          	ld	a4,88(s4)
    80002578:	12068693          	addi	a3,a3,288
    8000257c:	0007b803          	ld	a6,0(a5)
    80002580:	6788                	ld	a0,8(a5)
    80002582:	6b8c                	ld	a1,16(a5)
    80002584:	6f90                	ld	a2,24(a5)
    80002586:	01073023          	sd	a6,0(a4)
    8000258a:	e708                	sd	a0,8(a4)
    8000258c:	eb0c                	sd	a1,16(a4)
    8000258e:	ef10                	sd	a2,24(a4)
    80002590:	02078793          	addi	a5,a5,32
    80002594:	02070713          	addi	a4,a4,32
    80002598:	fed792e3          	bne	a5,a3,8000257c <fork+0x56>
    np->trapframe->a0 = 0;
    8000259c:	058a3783          	ld	a5,88(s4)
    800025a0:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800025a4:	0d0a8493          	addi	s1,s5,208
    800025a8:	0d0a0913          	addi	s2,s4,208
    800025ac:	150a8993          	addi	s3,s5,336
    800025b0:	a015                	j	800025d4 <fork+0xae>
        freeproc(np);
    800025b2:	8552                	mv	a0,s4
    800025b4:	00000097          	auipc	ra,0x0
    800025b8:	bd6080e7          	jalr	-1066(ra) # 8000218a <freeproc>
        release(&np->lock);
    800025bc:	8552                	mv	a0,s4
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	a2c080e7          	jalr	-1492(ra) # 80000fea <release>
        return -1;
    800025c6:	597d                	li	s2,-1
    800025c8:	6a42                	ld	s4,16(sp)
    800025ca:	a071                	j	80002656 <fork+0x130>
    for (i = 0; i < NOFILE; i++)
    800025cc:	04a1                	addi	s1,s1,8
    800025ce:	0921                	addi	s2,s2,8
    800025d0:	01348b63          	beq	s1,s3,800025e6 <fork+0xc0>
        if (p->ofile[i])
    800025d4:	6088                	ld	a0,0(s1)
    800025d6:	d97d                	beqz	a0,800025cc <fork+0xa6>
            np->ofile[i] = filedup(p->ofile[i]);
    800025d8:	00003097          	auipc	ra,0x3
    800025dc:	9ae080e7          	jalr	-1618(ra) # 80004f86 <filedup>
    800025e0:	00a93023          	sd	a0,0(s2)
    800025e4:	b7e5                	j	800025cc <fork+0xa6>
    np->cwd = idup(p->cwd);
    800025e6:	150ab503          	ld	a0,336(s5)
    800025ea:	00002097          	auipc	ra,0x2
    800025ee:	b18080e7          	jalr	-1256(ra) # 80004102 <idup>
    800025f2:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800025f6:	4641                	li	a2,16
    800025f8:	158a8593          	addi	a1,s5,344
    800025fc:	158a0513          	addi	a0,s4,344
    80002600:	fffff097          	auipc	ra,0xfffff
    80002604:	b74080e7          	jalr	-1164(ra) # 80001174 <safestrcpy>
    pid = np->pid;
    80002608:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    8000260c:	8552                	mv	a0,s4
    8000260e:	fffff097          	auipc	ra,0xfffff
    80002612:	9dc080e7          	jalr	-1572(ra) # 80000fea <release>
    acquire(&wait_lock);
    80002616:	00019497          	auipc	s1,0x19
    8000261a:	7ea48493          	addi	s1,s1,2026 # 8001be00 <wait_lock>
    8000261e:	8526                	mv	a0,s1
    80002620:	fffff097          	auipc	ra,0xfffff
    80002624:	916080e7          	jalr	-1770(ra) # 80000f36 <acquire>
    np->parent = p;
    80002628:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    8000262c:	8526                	mv	a0,s1
    8000262e:	fffff097          	auipc	ra,0xfffff
    80002632:	9bc080e7          	jalr	-1604(ra) # 80000fea <release>
    acquire(&np->lock);
    80002636:	8552                	mv	a0,s4
    80002638:	fffff097          	auipc	ra,0xfffff
    8000263c:	8fe080e7          	jalr	-1794(ra) # 80000f36 <acquire>
    np->state = RUNNABLE;
    80002640:	478d                	li	a5,3
    80002642:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002646:	8552                	mv	a0,s4
    80002648:	fffff097          	auipc	ra,0xfffff
    8000264c:	9a2080e7          	jalr	-1630(ra) # 80000fea <release>
    return pid;
    80002650:	74a2                	ld	s1,40(sp)
    80002652:	69e2                	ld	s3,24(sp)
    80002654:	6a42                	ld	s4,16(sp)
}
    80002656:	854a                	mv	a0,s2
    80002658:	70e2                	ld	ra,56(sp)
    8000265a:	7442                	ld	s0,48(sp)
    8000265c:	7902                	ld	s2,32(sp)
    8000265e:	6aa2                	ld	s5,8(sp)
    80002660:	6121                	addi	sp,sp,64
    80002662:	8082                	ret
        return -1;
    80002664:	597d                	li	s2,-1
    80002666:	bfc5                	j	80002656 <fork+0x130>

0000000080002668 <scheduler>:
{
    80002668:	1101                	addi	sp,sp,-32
    8000266a:	ec06                	sd	ra,24(sp)
    8000266c:	e822                	sd	s0,16(sp)
    8000266e:	e426                	sd	s1,8(sp)
    80002670:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002672:	00009497          	auipc	s1,0x9
    80002676:	01648493          	addi	s1,s1,22 # 8000b688 <sched_pointer>
    8000267a:	609c                	ld	a5,0(s1)
    8000267c:	9782                	jalr	a5
    while (1)
    8000267e:	bff5                	j	8000267a <scheduler+0x12>

0000000080002680 <sched>:
{
    80002680:	7179                	addi	sp,sp,-48
    80002682:	f406                	sd	ra,40(sp)
    80002684:	f022                	sd	s0,32(sp)
    80002686:	ec26                	sd	s1,24(sp)
    80002688:	e84a                	sd	s2,16(sp)
    8000268a:	e44e                	sd	s3,8(sp)
    8000268c:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000268e:	00000097          	auipc	ra,0x0
    80002692:	94a080e7          	jalr	-1718(ra) # 80001fd8 <myproc>
    80002696:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002698:	fffff097          	auipc	ra,0xfffff
    8000269c:	824080e7          	jalr	-2012(ra) # 80000ebc <holding>
    800026a0:	c53d                	beqz	a0,8000270e <sched+0x8e>
    800026a2:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800026a4:	2781                	sext.w	a5,a5
    800026a6:	079e                	slli	a5,a5,0x7
    800026a8:	00019717          	auipc	a4,0x19
    800026ac:	34070713          	addi	a4,a4,832 # 8001b9e8 <cpus>
    800026b0:	97ba                	add	a5,a5,a4
    800026b2:	5fb8                	lw	a4,120(a5)
    800026b4:	4785                	li	a5,1
    800026b6:	06f71463          	bne	a4,a5,8000271e <sched+0x9e>
    if (p->state == RUNNING)
    800026ba:	4c98                	lw	a4,24(s1)
    800026bc:	4791                	li	a5,4
    800026be:	06f70863          	beq	a4,a5,8000272e <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    800026c2:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    800026c6:	8b89                	andi	a5,a5,2
    if (intr_get())
    800026c8:	ebbd                	bnez	a5,8000273e <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    800026ca:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800026cc:	00019917          	auipc	s2,0x19
    800026d0:	31c90913          	addi	s2,s2,796 # 8001b9e8 <cpus>
    800026d4:	2781                	sext.w	a5,a5
    800026d6:	079e                	slli	a5,a5,0x7
    800026d8:	97ca                	add	a5,a5,s2
    800026da:	07c7a983          	lw	s3,124(a5)
    800026de:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800026e0:	2581                	sext.w	a1,a1
    800026e2:	059e                	slli	a1,a1,0x7
    800026e4:	05a1                	addi	a1,a1,8
    800026e6:	95ca                	add	a1,a1,s2
    800026e8:	06048513          	addi	a0,s1,96
    800026ec:	00000097          	auipc	ra,0x0
    800026f0:	764080e7          	jalr	1892(ra) # 80002e50 <swtch>
    800026f4:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800026f6:	2781                	sext.w	a5,a5
    800026f8:	079e                	slli	a5,a5,0x7
    800026fa:	993e                	add	s2,s2,a5
    800026fc:	07392e23          	sw	s3,124(s2)
}
    80002700:	70a2                	ld	ra,40(sp)
    80002702:	7402                	ld	s0,32(sp)
    80002704:	64e2                	ld	s1,24(sp)
    80002706:	6942                	ld	s2,16(sp)
    80002708:	69a2                	ld	s3,8(sp)
    8000270a:	6145                	addi	sp,sp,48
    8000270c:	8082                	ret
        panic("sched p->lock");
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	b7250513          	addi	a0,a0,-1166 # 80008280 <__func__.1+0x278>
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	e4a080e7          	jalr	-438(ra) # 80000560 <panic>
        panic("sched locks");
    8000271e:	00006517          	auipc	a0,0x6
    80002722:	b7250513          	addi	a0,a0,-1166 # 80008290 <__func__.1+0x288>
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	e3a080e7          	jalr	-454(ra) # 80000560 <panic>
        panic("sched running");
    8000272e:	00006517          	auipc	a0,0x6
    80002732:	b7250513          	addi	a0,a0,-1166 # 800082a0 <__func__.1+0x298>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	e2a080e7          	jalr	-470(ra) # 80000560 <panic>
        panic("sched interruptible");
    8000273e:	00006517          	auipc	a0,0x6
    80002742:	b7250513          	addi	a0,a0,-1166 # 800082b0 <__func__.1+0x2a8>
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	e1a080e7          	jalr	-486(ra) # 80000560 <panic>

000000008000274e <yield>:
{
    8000274e:	1101                	addi	sp,sp,-32
    80002750:	ec06                	sd	ra,24(sp)
    80002752:	e822                	sd	s0,16(sp)
    80002754:	e426                	sd	s1,8(sp)
    80002756:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002758:	00000097          	auipc	ra,0x0
    8000275c:	880080e7          	jalr	-1920(ra) # 80001fd8 <myproc>
    80002760:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	7d4080e7          	jalr	2004(ra) # 80000f36 <acquire>
    p->state = RUNNABLE;
    8000276a:	478d                	li	a5,3
    8000276c:	cc9c                	sw	a5,24(s1)
    sched();
    8000276e:	00000097          	auipc	ra,0x0
    80002772:	f12080e7          	jalr	-238(ra) # 80002680 <sched>
    release(&p->lock);
    80002776:	8526                	mv	a0,s1
    80002778:	fffff097          	auipc	ra,0xfffff
    8000277c:	872080e7          	jalr	-1934(ra) # 80000fea <release>
}
    80002780:	60e2                	ld	ra,24(sp)
    80002782:	6442                	ld	s0,16(sp)
    80002784:	64a2                	ld	s1,8(sp)
    80002786:	6105                	addi	sp,sp,32
    80002788:	8082                	ret

000000008000278a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000278a:	7179                	addi	sp,sp,-48
    8000278c:	f406                	sd	ra,40(sp)
    8000278e:	f022                	sd	s0,32(sp)
    80002790:	ec26                	sd	s1,24(sp)
    80002792:	e84a                	sd	s2,16(sp)
    80002794:	e44e                	sd	s3,8(sp)
    80002796:	1800                	addi	s0,sp,48
    80002798:	89aa                	mv	s3,a0
    8000279a:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000279c:	00000097          	auipc	ra,0x0
    800027a0:	83c080e7          	jalr	-1988(ra) # 80001fd8 <myproc>
    800027a4:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	790080e7          	jalr	1936(ra) # 80000f36 <acquire>
    release(lk);
    800027ae:	854a                	mv	a0,s2
    800027b0:	fffff097          	auipc	ra,0xfffff
    800027b4:	83a080e7          	jalr	-1990(ra) # 80000fea <release>

    // Go to sleep.
    p->chan = chan;
    800027b8:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800027bc:	4789                	li	a5,2
    800027be:	cc9c                	sw	a5,24(s1)

    sched();
    800027c0:	00000097          	auipc	ra,0x0
    800027c4:	ec0080e7          	jalr	-320(ra) # 80002680 <sched>

    // Tidy up.
    p->chan = 0;
    800027c8:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	fffff097          	auipc	ra,0xfffff
    800027d2:	81c080e7          	jalr	-2020(ra) # 80000fea <release>
    acquire(lk);
    800027d6:	854a                	mv	a0,s2
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	75e080e7          	jalr	1886(ra) # 80000f36 <acquire>
}
    800027e0:	70a2                	ld	ra,40(sp)
    800027e2:	7402                	ld	s0,32(sp)
    800027e4:	64e2                	ld	s1,24(sp)
    800027e6:	6942                	ld	s2,16(sp)
    800027e8:	69a2                	ld	s3,8(sp)
    800027ea:	6145                	addi	sp,sp,48
    800027ec:	8082                	ret

00000000800027ee <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800027ee:	7139                	addi	sp,sp,-64
    800027f0:	fc06                	sd	ra,56(sp)
    800027f2:	f822                	sd	s0,48(sp)
    800027f4:	f426                	sd	s1,40(sp)
    800027f6:	f04a                	sd	s2,32(sp)
    800027f8:	ec4e                	sd	s3,24(sp)
    800027fa:	e852                	sd	s4,16(sp)
    800027fc:	e456                	sd	s5,8(sp)
    800027fe:	0080                	addi	s0,sp,64
    80002800:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002802:	00019497          	auipc	s1,0x19
    80002806:	61648493          	addi	s1,s1,1558 # 8001be18 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000280a:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    8000280c:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000280e:	0001f917          	auipc	s2,0x1f
    80002812:	00a90913          	addi	s2,s2,10 # 80021818 <tickslock>
    80002816:	a811                	j	8000282a <wakeup+0x3c>
            }
            release(&p->lock);
    80002818:	8526                	mv	a0,s1
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	7d0080e7          	jalr	2000(ra) # 80000fea <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002822:	16848493          	addi	s1,s1,360
    80002826:	03248663          	beq	s1,s2,80002852 <wakeup+0x64>
        if (p != myproc())
    8000282a:	fffff097          	auipc	ra,0xfffff
    8000282e:	7ae080e7          	jalr	1966(ra) # 80001fd8 <myproc>
    80002832:	fea488e3          	beq	s1,a0,80002822 <wakeup+0x34>
            acquire(&p->lock);
    80002836:	8526                	mv	a0,s1
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	6fe080e7          	jalr	1790(ra) # 80000f36 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002840:	4c9c                	lw	a5,24(s1)
    80002842:	fd379be3          	bne	a5,s3,80002818 <wakeup+0x2a>
    80002846:	709c                	ld	a5,32(s1)
    80002848:	fd4798e3          	bne	a5,s4,80002818 <wakeup+0x2a>
                p->state = RUNNABLE;
    8000284c:	0154ac23          	sw	s5,24(s1)
    80002850:	b7e1                	j	80002818 <wakeup+0x2a>
        }
    }
}
    80002852:	70e2                	ld	ra,56(sp)
    80002854:	7442                	ld	s0,48(sp)
    80002856:	74a2                	ld	s1,40(sp)
    80002858:	7902                	ld	s2,32(sp)
    8000285a:	69e2                	ld	s3,24(sp)
    8000285c:	6a42                	ld	s4,16(sp)
    8000285e:	6aa2                	ld	s5,8(sp)
    80002860:	6121                	addi	sp,sp,64
    80002862:	8082                	ret

0000000080002864 <reparent>:
{
    80002864:	7179                	addi	sp,sp,-48
    80002866:	f406                	sd	ra,40(sp)
    80002868:	f022                	sd	s0,32(sp)
    8000286a:	ec26                	sd	s1,24(sp)
    8000286c:	e84a                	sd	s2,16(sp)
    8000286e:	e44e                	sd	s3,8(sp)
    80002870:	e052                	sd	s4,0(sp)
    80002872:	1800                	addi	s0,sp,48
    80002874:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002876:	00019497          	auipc	s1,0x19
    8000287a:	5a248493          	addi	s1,s1,1442 # 8001be18 <proc>
            pp->parent = initproc;
    8000287e:	00009a17          	auipc	s4,0x9
    80002882:	edaa0a13          	addi	s4,s4,-294 # 8000b758 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002886:	0001f997          	auipc	s3,0x1f
    8000288a:	f9298993          	addi	s3,s3,-110 # 80021818 <tickslock>
    8000288e:	a029                	j	80002898 <reparent+0x34>
    80002890:	16848493          	addi	s1,s1,360
    80002894:	01348d63          	beq	s1,s3,800028ae <reparent+0x4a>
        if (pp->parent == p)
    80002898:	7c9c                	ld	a5,56(s1)
    8000289a:	ff279be3          	bne	a5,s2,80002890 <reparent+0x2c>
            pp->parent = initproc;
    8000289e:	000a3503          	ld	a0,0(s4)
    800028a2:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800028a4:	00000097          	auipc	ra,0x0
    800028a8:	f4a080e7          	jalr	-182(ra) # 800027ee <wakeup>
    800028ac:	b7d5                	j	80002890 <reparent+0x2c>
}
    800028ae:	70a2                	ld	ra,40(sp)
    800028b0:	7402                	ld	s0,32(sp)
    800028b2:	64e2                	ld	s1,24(sp)
    800028b4:	6942                	ld	s2,16(sp)
    800028b6:	69a2                	ld	s3,8(sp)
    800028b8:	6a02                	ld	s4,0(sp)
    800028ba:	6145                	addi	sp,sp,48
    800028bc:	8082                	ret

00000000800028be <exit>:
{
    800028be:	7179                	addi	sp,sp,-48
    800028c0:	f406                	sd	ra,40(sp)
    800028c2:	f022                	sd	s0,32(sp)
    800028c4:	ec26                	sd	s1,24(sp)
    800028c6:	e84a                	sd	s2,16(sp)
    800028c8:	e44e                	sd	s3,8(sp)
    800028ca:	e052                	sd	s4,0(sp)
    800028cc:	1800                	addi	s0,sp,48
    800028ce:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	708080e7          	jalr	1800(ra) # 80001fd8 <myproc>
    800028d8:	89aa                	mv	s3,a0
    if (p == initproc)
    800028da:	00009797          	auipc	a5,0x9
    800028de:	e7e7b783          	ld	a5,-386(a5) # 8000b758 <initproc>
    800028e2:	0d050493          	addi	s1,a0,208
    800028e6:	15050913          	addi	s2,a0,336
    800028ea:	02a79363          	bne	a5,a0,80002910 <exit+0x52>
        panic("init exiting");
    800028ee:	00006517          	auipc	a0,0x6
    800028f2:	9da50513          	addi	a0,a0,-1574 # 800082c8 <__func__.1+0x2c0>
    800028f6:	ffffe097          	auipc	ra,0xffffe
    800028fa:	c6a080e7          	jalr	-918(ra) # 80000560 <panic>
            fileclose(f);
    800028fe:	00002097          	auipc	ra,0x2
    80002902:	6da080e7          	jalr	1754(ra) # 80004fd8 <fileclose>
            p->ofile[fd] = 0;
    80002906:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000290a:	04a1                	addi	s1,s1,8
    8000290c:	01248563          	beq	s1,s2,80002916 <exit+0x58>
        if (p->ofile[fd])
    80002910:	6088                	ld	a0,0(s1)
    80002912:	f575                	bnez	a0,800028fe <exit+0x40>
    80002914:	bfdd                	j	8000290a <exit+0x4c>
    begin_op();
    80002916:	00002097          	auipc	ra,0x2
    8000291a:	1f8080e7          	jalr	504(ra) # 80004b0e <begin_op>
    iput(p->cwd);
    8000291e:	1509b503          	ld	a0,336(s3)
    80002922:	00002097          	auipc	ra,0x2
    80002926:	9dc080e7          	jalr	-1572(ra) # 800042fe <iput>
    end_op();
    8000292a:	00002097          	auipc	ra,0x2
    8000292e:	25e080e7          	jalr	606(ra) # 80004b88 <end_op>
    p->cwd = 0;
    80002932:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002936:	00019497          	auipc	s1,0x19
    8000293a:	4ca48493          	addi	s1,s1,1226 # 8001be00 <wait_lock>
    8000293e:	8526                	mv	a0,s1
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	5f6080e7          	jalr	1526(ra) # 80000f36 <acquire>
    reparent(p);
    80002948:	854e                	mv	a0,s3
    8000294a:	00000097          	auipc	ra,0x0
    8000294e:	f1a080e7          	jalr	-230(ra) # 80002864 <reparent>
    wakeup(p->parent);
    80002952:	0389b503          	ld	a0,56(s3)
    80002956:	00000097          	auipc	ra,0x0
    8000295a:	e98080e7          	jalr	-360(ra) # 800027ee <wakeup>
    acquire(&p->lock);
    8000295e:	854e                	mv	a0,s3
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	5d6080e7          	jalr	1494(ra) # 80000f36 <acquire>
    p->xstate = status;
    80002968:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    8000296c:	4795                	li	a5,5
    8000296e:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002972:	8526                	mv	a0,s1
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	676080e7          	jalr	1654(ra) # 80000fea <release>
    sched();
    8000297c:	00000097          	auipc	ra,0x0
    80002980:	d04080e7          	jalr	-764(ra) # 80002680 <sched>
    panic("zombie exit");
    80002984:	00006517          	auipc	a0,0x6
    80002988:	95450513          	addi	a0,a0,-1708 # 800082d8 <__func__.1+0x2d0>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	bd4080e7          	jalr	-1068(ra) # 80000560 <panic>

0000000080002994 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002994:	7179                	addi	sp,sp,-48
    80002996:	f406                	sd	ra,40(sp)
    80002998:	f022                	sd	s0,32(sp)
    8000299a:	ec26                	sd	s1,24(sp)
    8000299c:	e84a                	sd	s2,16(sp)
    8000299e:	e44e                	sd	s3,8(sp)
    800029a0:	1800                	addi	s0,sp,48
    800029a2:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800029a4:	00019497          	auipc	s1,0x19
    800029a8:	47448493          	addi	s1,s1,1140 # 8001be18 <proc>
    800029ac:	0001f997          	auipc	s3,0x1f
    800029b0:	e6c98993          	addi	s3,s3,-404 # 80021818 <tickslock>
    {
        acquire(&p->lock);
    800029b4:	8526                	mv	a0,s1
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	580080e7          	jalr	1408(ra) # 80000f36 <acquire>
        if (p->pid == pid)
    800029be:	589c                	lw	a5,48(s1)
    800029c0:	01278d63          	beq	a5,s2,800029da <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800029c4:	8526                	mv	a0,s1
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	624080e7          	jalr	1572(ra) # 80000fea <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800029ce:	16848493          	addi	s1,s1,360
    800029d2:	ff3491e3          	bne	s1,s3,800029b4 <kill+0x20>
    }
    return -1;
    800029d6:	557d                	li	a0,-1
    800029d8:	a829                	j	800029f2 <kill+0x5e>
            p->killed = 1;
    800029da:	4785                	li	a5,1
    800029dc:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800029de:	4c98                	lw	a4,24(s1)
    800029e0:	4789                	li	a5,2
    800029e2:	00f70f63          	beq	a4,a5,80002a00 <kill+0x6c>
            release(&p->lock);
    800029e6:	8526                	mv	a0,s1
    800029e8:	ffffe097          	auipc	ra,0xffffe
    800029ec:	602080e7          	jalr	1538(ra) # 80000fea <release>
            return 0;
    800029f0:	4501                	li	a0,0
}
    800029f2:	70a2                	ld	ra,40(sp)
    800029f4:	7402                	ld	s0,32(sp)
    800029f6:	64e2                	ld	s1,24(sp)
    800029f8:	6942                	ld	s2,16(sp)
    800029fa:	69a2                	ld	s3,8(sp)
    800029fc:	6145                	addi	sp,sp,48
    800029fe:	8082                	ret
                p->state = RUNNABLE;
    80002a00:	478d                	li	a5,3
    80002a02:	cc9c                	sw	a5,24(s1)
    80002a04:	b7cd                	j	800029e6 <kill+0x52>

0000000080002a06 <setkilled>:

void setkilled(struct proc *p)
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	1000                	addi	s0,sp,32
    80002a10:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	524080e7          	jalr	1316(ra) # 80000f36 <acquire>
    p->killed = 1;
    80002a1a:	4785                	li	a5,1
    80002a1c:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002a1e:	8526                	mv	a0,s1
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	5ca080e7          	jalr	1482(ra) # 80000fea <release>
}
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret

0000000080002a32 <killed>:

int killed(struct proc *p)
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	e04a                	sd	s2,0(sp)
    80002a3c:	1000                	addi	s0,sp,32
    80002a3e:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	4f6080e7          	jalr	1270(ra) # 80000f36 <acquire>
    k = p->killed;
    80002a48:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	59c080e7          	jalr	1436(ra) # 80000fea <release>
    return k;
}
    80002a56:	854a                	mv	a0,s2
    80002a58:	60e2                	ld	ra,24(sp)
    80002a5a:	6442                	ld	s0,16(sp)
    80002a5c:	64a2                	ld	s1,8(sp)
    80002a5e:	6902                	ld	s2,0(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret

0000000080002a64 <wait>:
{
    80002a64:	715d                	addi	sp,sp,-80
    80002a66:	e486                	sd	ra,72(sp)
    80002a68:	e0a2                	sd	s0,64(sp)
    80002a6a:	fc26                	sd	s1,56(sp)
    80002a6c:	f84a                	sd	s2,48(sp)
    80002a6e:	f44e                	sd	s3,40(sp)
    80002a70:	f052                	sd	s4,32(sp)
    80002a72:	ec56                	sd	s5,24(sp)
    80002a74:	e85a                	sd	s6,16(sp)
    80002a76:	e45e                	sd	s7,8(sp)
    80002a78:	e062                	sd	s8,0(sp)
    80002a7a:	0880                	addi	s0,sp,80
    80002a7c:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002a7e:	fffff097          	auipc	ra,0xfffff
    80002a82:	55a080e7          	jalr	1370(ra) # 80001fd8 <myproc>
    80002a86:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002a88:	00019517          	auipc	a0,0x19
    80002a8c:	37850513          	addi	a0,a0,888 # 8001be00 <wait_lock>
    80002a90:	ffffe097          	auipc	ra,0xffffe
    80002a94:	4a6080e7          	jalr	1190(ra) # 80000f36 <acquire>
        havekids = 0;
    80002a98:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002a9a:	4a15                	li	s4,5
                havekids = 1;
    80002a9c:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a9e:	0001f997          	auipc	s3,0x1f
    80002aa2:	d7a98993          	addi	s3,s3,-646 # 80021818 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002aa6:	00019c17          	auipc	s8,0x19
    80002aaa:	35ac0c13          	addi	s8,s8,858 # 8001be00 <wait_lock>
    80002aae:	a0d1                	j	80002b72 <wait+0x10e>
                    pid = pp->pid;
    80002ab0:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002ab4:	000b0e63          	beqz	s6,80002ad0 <wait+0x6c>
    80002ab8:	4691                	li	a3,4
    80002aba:	02c48613          	addi	a2,s1,44
    80002abe:	85da                	mv	a1,s6
    80002ac0:	05093503          	ld	a0,80(s2)
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	f22080e7          	jalr	-222(ra) # 800019e6 <copyout>
    80002acc:	04054163          	bltz	a0,80002b0e <wait+0xaa>
                    freeproc(pp);
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	fffff097          	auipc	ra,0xfffff
    80002ad6:	6b8080e7          	jalr	1720(ra) # 8000218a <freeproc>
                    release(&pp->lock);
    80002ada:	8526                	mv	a0,s1
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	50e080e7          	jalr	1294(ra) # 80000fea <release>
                    release(&wait_lock);
    80002ae4:	00019517          	auipc	a0,0x19
    80002ae8:	31c50513          	addi	a0,a0,796 # 8001be00 <wait_lock>
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	4fe080e7          	jalr	1278(ra) # 80000fea <release>
}
    80002af4:	854e                	mv	a0,s3
    80002af6:	60a6                	ld	ra,72(sp)
    80002af8:	6406                	ld	s0,64(sp)
    80002afa:	74e2                	ld	s1,56(sp)
    80002afc:	7942                	ld	s2,48(sp)
    80002afe:	79a2                	ld	s3,40(sp)
    80002b00:	7a02                	ld	s4,32(sp)
    80002b02:	6ae2                	ld	s5,24(sp)
    80002b04:	6b42                	ld	s6,16(sp)
    80002b06:	6ba2                	ld	s7,8(sp)
    80002b08:	6c02                	ld	s8,0(sp)
    80002b0a:	6161                	addi	sp,sp,80
    80002b0c:	8082                	ret
                        release(&pp->lock);
    80002b0e:	8526                	mv	a0,s1
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	4da080e7          	jalr	1242(ra) # 80000fea <release>
                        release(&wait_lock);
    80002b18:	00019517          	auipc	a0,0x19
    80002b1c:	2e850513          	addi	a0,a0,744 # 8001be00 <wait_lock>
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	4ca080e7          	jalr	1226(ra) # 80000fea <release>
                        return -1;
    80002b28:	59fd                	li	s3,-1
    80002b2a:	b7e9                	j	80002af4 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b2c:	16848493          	addi	s1,s1,360
    80002b30:	03348463          	beq	s1,s3,80002b58 <wait+0xf4>
            if (pp->parent == p)
    80002b34:	7c9c                	ld	a5,56(s1)
    80002b36:	ff279be3          	bne	a5,s2,80002b2c <wait+0xc8>
                acquire(&pp->lock);
    80002b3a:	8526                	mv	a0,s1
    80002b3c:	ffffe097          	auipc	ra,0xffffe
    80002b40:	3fa080e7          	jalr	1018(ra) # 80000f36 <acquire>
                if (pp->state == ZOMBIE)
    80002b44:	4c9c                	lw	a5,24(s1)
    80002b46:	f74785e3          	beq	a5,s4,80002ab0 <wait+0x4c>
                release(&pp->lock);
    80002b4a:	8526                	mv	a0,s1
    80002b4c:	ffffe097          	auipc	ra,0xffffe
    80002b50:	49e080e7          	jalr	1182(ra) # 80000fea <release>
                havekids = 1;
    80002b54:	8756                	mv	a4,s5
    80002b56:	bfd9                	j	80002b2c <wait+0xc8>
        if (!havekids || killed(p))
    80002b58:	c31d                	beqz	a4,80002b7e <wait+0x11a>
    80002b5a:	854a                	mv	a0,s2
    80002b5c:	00000097          	auipc	ra,0x0
    80002b60:	ed6080e7          	jalr	-298(ra) # 80002a32 <killed>
    80002b64:	ed09                	bnez	a0,80002b7e <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002b66:	85e2                	mv	a1,s8
    80002b68:	854a                	mv	a0,s2
    80002b6a:	00000097          	auipc	ra,0x0
    80002b6e:	c20080e7          	jalr	-992(ra) # 8000278a <sleep>
        havekids = 0;
    80002b72:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b74:	00019497          	auipc	s1,0x19
    80002b78:	2a448493          	addi	s1,s1,676 # 8001be18 <proc>
    80002b7c:	bf65                	j	80002b34 <wait+0xd0>
            release(&wait_lock);
    80002b7e:	00019517          	auipc	a0,0x19
    80002b82:	28250513          	addi	a0,a0,642 # 8001be00 <wait_lock>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	464080e7          	jalr	1124(ra) # 80000fea <release>
            return -1;
    80002b8e:	59fd                	li	s3,-1
    80002b90:	b795                	j	80002af4 <wait+0x90>

0000000080002b92 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b92:	7179                	addi	sp,sp,-48
    80002b94:	f406                	sd	ra,40(sp)
    80002b96:	f022                	sd	s0,32(sp)
    80002b98:	ec26                	sd	s1,24(sp)
    80002b9a:	e84a                	sd	s2,16(sp)
    80002b9c:	e44e                	sd	s3,8(sp)
    80002b9e:	e052                	sd	s4,0(sp)
    80002ba0:	1800                	addi	s0,sp,48
    80002ba2:	84aa                	mv	s1,a0
    80002ba4:	892e                	mv	s2,a1
    80002ba6:	89b2                	mv	s3,a2
    80002ba8:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	42e080e7          	jalr	1070(ra) # 80001fd8 <myproc>
    if (user_dst)
    80002bb2:	c08d                	beqz	s1,80002bd4 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002bb4:	86d2                	mv	a3,s4
    80002bb6:	864e                	mv	a2,s3
    80002bb8:	85ca                	mv	a1,s2
    80002bba:	6928                	ld	a0,80(a0)
    80002bbc:	fffff097          	auipc	ra,0xfffff
    80002bc0:	e2a080e7          	jalr	-470(ra) # 800019e6 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002bc4:	70a2                	ld	ra,40(sp)
    80002bc6:	7402                	ld	s0,32(sp)
    80002bc8:	64e2                	ld	s1,24(sp)
    80002bca:	6942                	ld	s2,16(sp)
    80002bcc:	69a2                	ld	s3,8(sp)
    80002bce:	6a02                	ld	s4,0(sp)
    80002bd0:	6145                	addi	sp,sp,48
    80002bd2:	8082                	ret
        memmove((char *)dst, src, len);
    80002bd4:	000a061b          	sext.w	a2,s4
    80002bd8:	85ce                	mv	a1,s3
    80002bda:	854a                	mv	a0,s2
    80002bdc:	ffffe097          	auipc	ra,0xffffe
    80002be0:	4b2080e7          	jalr	1202(ra) # 8000108e <memmove>
        return 0;
    80002be4:	8526                	mv	a0,s1
    80002be6:	bff9                	j	80002bc4 <either_copyout+0x32>

0000000080002be8 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002be8:	7179                	addi	sp,sp,-48
    80002bea:	f406                	sd	ra,40(sp)
    80002bec:	f022                	sd	s0,32(sp)
    80002bee:	ec26                	sd	s1,24(sp)
    80002bf0:	e84a                	sd	s2,16(sp)
    80002bf2:	e44e                	sd	s3,8(sp)
    80002bf4:	e052                	sd	s4,0(sp)
    80002bf6:	1800                	addi	s0,sp,48
    80002bf8:	892a                	mv	s2,a0
    80002bfa:	84ae                	mv	s1,a1
    80002bfc:	89b2                	mv	s3,a2
    80002bfe:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	3d8080e7          	jalr	984(ra) # 80001fd8 <myproc>
    if (user_src)
    80002c08:	c08d                	beqz	s1,80002c2a <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002c0a:	86d2                	mv	a3,s4
    80002c0c:	864e                	mv	a2,s3
    80002c0e:	85ca                	mv	a1,s2
    80002c10:	6928                	ld	a0,80(a0)
    80002c12:	fffff097          	auipc	ra,0xfffff
    80002c16:	e60080e7          	jalr	-416(ra) # 80001a72 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6942                	ld	s2,16(sp)
    80002c22:	69a2                	ld	s3,8(sp)
    80002c24:	6a02                	ld	s4,0(sp)
    80002c26:	6145                	addi	sp,sp,48
    80002c28:	8082                	ret
        memmove(dst, (char *)src, len);
    80002c2a:	000a061b          	sext.w	a2,s4
    80002c2e:	85ce                	mv	a1,s3
    80002c30:	854a                	mv	a0,s2
    80002c32:	ffffe097          	auipc	ra,0xffffe
    80002c36:	45c080e7          	jalr	1116(ra) # 8000108e <memmove>
        return 0;
    80002c3a:	8526                	mv	a0,s1
    80002c3c:	bff9                	j	80002c1a <either_copyin+0x32>

0000000080002c3e <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002c3e:	715d                	addi	sp,sp,-80
    80002c40:	e486                	sd	ra,72(sp)
    80002c42:	e0a2                	sd	s0,64(sp)
    80002c44:	fc26                	sd	s1,56(sp)
    80002c46:	f84a                	sd	s2,48(sp)
    80002c48:	f44e                	sd	s3,40(sp)
    80002c4a:	f052                	sd	s4,32(sp)
    80002c4c:	ec56                	sd	s5,24(sp)
    80002c4e:	e85a                	sd	s6,16(sp)
    80002c50:	e45e                	sd	s7,8(sp)
    80002c52:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	3cc50513          	addi	a0,a0,972 # 80008020 <__func__.1+0x18>
    80002c5c:	ffffe097          	auipc	ra,0xffffe
    80002c60:	960080e7          	jalr	-1696(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002c64:	00019497          	auipc	s1,0x19
    80002c68:	30c48493          	addi	s1,s1,780 # 8001bf70 <proc+0x158>
    80002c6c:	0001f917          	auipc	s2,0x1f
    80002c70:	d0490913          	addi	s2,s2,-764 # 80021970 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c74:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002c76:	00005997          	auipc	s3,0x5
    80002c7a:	67298993          	addi	s3,s3,1650 # 800082e8 <__func__.1+0x2e0>
        printf("%d <%s %s", p->pid, state, p->name);
    80002c7e:	00005a97          	auipc	s5,0x5
    80002c82:	672a8a93          	addi	s5,s5,1650 # 800082f0 <__func__.1+0x2e8>
        printf("\n");
    80002c86:	00005a17          	auipc	s4,0x5
    80002c8a:	39aa0a13          	addi	s4,s4,922 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c8e:	00006b97          	auipc	s7,0x6
    80002c92:	c5ab8b93          	addi	s7,s7,-934 # 800088e8 <states.0>
    80002c96:	a00d                	j	80002cb8 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002c98:	ed86a583          	lw	a1,-296(a3)
    80002c9c:	8556                	mv	a0,s5
    80002c9e:	ffffe097          	auipc	ra,0xffffe
    80002ca2:	91e080e7          	jalr	-1762(ra) # 800005bc <printf>
        printf("\n");
    80002ca6:	8552                	mv	a0,s4
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	914080e7          	jalr	-1772(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002cb0:	16848493          	addi	s1,s1,360
    80002cb4:	03248263          	beq	s1,s2,80002cd8 <procdump+0x9a>
        if (p->state == UNUSED)
    80002cb8:	86a6                	mv	a3,s1
    80002cba:	ec04a783          	lw	a5,-320(s1)
    80002cbe:	dbed                	beqz	a5,80002cb0 <procdump+0x72>
            state = "???";
    80002cc0:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002cc2:	fcfb6be3          	bltu	s6,a5,80002c98 <procdump+0x5a>
    80002cc6:	02079713          	slli	a4,a5,0x20
    80002cca:	01d75793          	srli	a5,a4,0x1d
    80002cce:	97de                	add	a5,a5,s7
    80002cd0:	6390                	ld	a2,0(a5)
    80002cd2:	f279                	bnez	a2,80002c98 <procdump+0x5a>
            state = "???";
    80002cd4:	864e                	mv	a2,s3
    80002cd6:	b7c9                	j	80002c98 <procdump+0x5a>
    }
}
    80002cd8:	60a6                	ld	ra,72(sp)
    80002cda:	6406                	ld	s0,64(sp)
    80002cdc:	74e2                	ld	s1,56(sp)
    80002cde:	7942                	ld	s2,48(sp)
    80002ce0:	79a2                	ld	s3,40(sp)
    80002ce2:	7a02                	ld	s4,32(sp)
    80002ce4:	6ae2                	ld	s5,24(sp)
    80002ce6:	6b42                	ld	s6,16(sp)
    80002ce8:	6ba2                	ld	s7,8(sp)
    80002cea:	6161                	addi	sp,sp,80
    80002cec:	8082                	ret

0000000080002cee <schedls>:

void schedls()
{
    80002cee:	1141                	addi	sp,sp,-16
    80002cf0:	e406                	sd	ra,8(sp)
    80002cf2:	e022                	sd	s0,0(sp)
    80002cf4:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002cf6:	00005517          	auipc	a0,0x5
    80002cfa:	60a50513          	addi	a0,a0,1546 # 80008300 <__func__.1+0x2f8>
    80002cfe:	ffffe097          	auipc	ra,0xffffe
    80002d02:	8be080e7          	jalr	-1858(ra) # 800005bc <printf>
    printf("====================================\n");
    80002d06:	00005517          	auipc	a0,0x5
    80002d0a:	62250513          	addi	a0,a0,1570 # 80008328 <__func__.1+0x320>
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	8ae080e7          	jalr	-1874(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002d16:	00009717          	auipc	a4,0x9
    80002d1a:	9d273703          	ld	a4,-1582(a4) # 8000b6e8 <available_schedulers+0x10>
    80002d1e:	00009797          	auipc	a5,0x9
    80002d22:	96a7b783          	ld	a5,-1686(a5) # 8000b688 <sched_pointer>
    80002d26:	04f70663          	beq	a4,a5,80002d72 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002d2a:	00005517          	auipc	a0,0x5
    80002d2e:	62e50513          	addi	a0,a0,1582 # 80008358 <__func__.1+0x350>
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	88a080e7          	jalr	-1910(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002d3a:	00009617          	auipc	a2,0x9
    80002d3e:	9b662603          	lw	a2,-1610(a2) # 8000b6f0 <available_schedulers+0x18>
    80002d42:	00009597          	auipc	a1,0x9
    80002d46:	99658593          	addi	a1,a1,-1642 # 8000b6d8 <available_schedulers>
    80002d4a:	00005517          	auipc	a0,0x5
    80002d4e:	61650513          	addi	a0,a0,1558 # 80008360 <__func__.1+0x358>
    80002d52:	ffffe097          	auipc	ra,0xffffe
    80002d56:	86a080e7          	jalr	-1942(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002d5a:	00005517          	auipc	a0,0x5
    80002d5e:	60e50513          	addi	a0,a0,1550 # 80008368 <__func__.1+0x360>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	85a080e7          	jalr	-1958(ra) # 800005bc <printf>
}
    80002d6a:	60a2                	ld	ra,8(sp)
    80002d6c:	6402                	ld	s0,0(sp)
    80002d6e:	0141                	addi	sp,sp,16
    80002d70:	8082                	ret
            printf("[*]\t");
    80002d72:	00005517          	auipc	a0,0x5
    80002d76:	5de50513          	addi	a0,a0,1502 # 80008350 <__func__.1+0x348>
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	842080e7          	jalr	-1982(ra) # 800005bc <printf>
    80002d82:	bf65                	j	80002d3a <schedls+0x4c>

0000000080002d84 <schedset>:

void schedset(int id)
{
    80002d84:	1141                	addi	sp,sp,-16
    80002d86:	e406                	sd	ra,8(sp)
    80002d88:	e022                	sd	s0,0(sp)
    80002d8a:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002d8c:	e90d                	bnez	a0,80002dbe <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002d8e:	00009797          	auipc	a5,0x9
    80002d92:	95a7b783          	ld	a5,-1702(a5) # 8000b6e8 <available_schedulers+0x10>
    80002d96:	00009717          	auipc	a4,0x9
    80002d9a:	8ef73923          	sd	a5,-1806(a4) # 8000b688 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002d9e:	00009597          	auipc	a1,0x9
    80002da2:	93a58593          	addi	a1,a1,-1734 # 8000b6d8 <available_schedulers>
    80002da6:	00005517          	auipc	a0,0x5
    80002daa:	60250513          	addi	a0,a0,1538 # 800083a8 <__func__.1+0x3a0>
    80002dae:	ffffe097          	auipc	ra,0xffffe
    80002db2:	80e080e7          	jalr	-2034(ra) # 800005bc <printf>
}
    80002db6:	60a2                	ld	ra,8(sp)
    80002db8:	6402                	ld	s0,0(sp)
    80002dba:	0141                	addi	sp,sp,16
    80002dbc:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002dbe:	00005517          	auipc	a0,0x5
    80002dc2:	5c250513          	addi	a0,a0,1474 # 80008380 <__func__.1+0x378>
    80002dc6:	ffffd097          	auipc	ra,0xffffd
    80002dca:	7f6080e7          	jalr	2038(ra) # 800005bc <printf>
        return;
    80002dce:	b7e5                	j	80002db6 <schedset+0x32>

0000000080002dd0 <transvirtproc>:

uint64 transvirtproc(uint64 vaddr, int pid) {
    80002dd0:	7139                	addi	sp,sp,-64
    80002dd2:	fc06                	sd	ra,56(sp)
    80002dd4:	f822                	sd	s0,48(sp)
    80002dd6:	f426                	sd	s1,40(sp)
    80002dd8:	f04a                	sd	s2,32(sp)
    80002dda:	ec4e                	sd	s3,24(sp)
    80002ddc:	e852                	sd	s4,16(sp)
    80002dde:	e456                	sd	s5,8(sp)
    80002de0:	0080                	addi	s0,sp,64
    80002de2:	8aaa                	mv	s5,a0
    80002de4:	892e                	mv	s2,a1
    struct proc *p;
    int found = 0;
    for (p = proc; p < &proc[NPROC]; p++)
    80002de6:	00019497          	auipc	s1,0x19
    80002dea:	03248493          	addi	s1,s1,50 # 8001be18 <proc>
    80002dee:	0001f997          	auipc	s3,0x1f
    80002df2:	a2a98993          	addi	s3,s3,-1494 # 80021818 <tickslock>
    80002df6:	a831                	j	80002e12 <transvirtproc+0x42>
    {
        acquire(&p->lock);
        found = p->pid == pid && p->state != UNUSED; 
    80002df8:	0184aa03          	lw	s4,24(s1)
        release(&p->lock);
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	1ec080e7          	jalr	492(ra) # 80000fea <release>
        if (found) break;
    80002e06:	020a1663          	bnez	s4,80002e32 <transvirtproc+0x62>
    for (p = proc; p < &proc[NPROC]; p++)
    80002e0a:	16848493          	addi	s1,s1,360
    80002e0e:	03348063          	beq	s1,s3,80002e2e <transvirtproc+0x5e>
        acquire(&p->lock);
    80002e12:	8526                	mv	a0,s1
    80002e14:	ffffe097          	auipc	ra,0xffffe
    80002e18:	122080e7          	jalr	290(ra) # 80000f36 <acquire>
        found = p->pid == pid && p->state != UNUSED; 
    80002e1c:	589c                	lw	a5,48(s1)
    80002e1e:	fd278de3          	beq	a5,s2,80002df8 <transvirtproc+0x28>
        release(&p->lock);
    80002e22:	8526                	mv	a0,s1
    80002e24:	ffffe097          	auipc	ra,0xffffe
    80002e28:	1c6080e7          	jalr	454(ra) # 80000fea <release>
        if (found) break;
    80002e2c:	bff9                	j	80002e0a <transvirtproc+0x3a>
    }
    if (!found) {
        return 0;
    80002e2e:	4501                	li	a0,0
    80002e30:	a039                	j	80002e3e <transvirtproc+0x6e>
    }

    pagetable_t pagetable = p->pagetable;
    return transvirt(vaddr, pagetable);
    80002e32:	68ac                	ld	a1,80(s1)
    80002e34:	8556                	mv	a0,s5
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	d86080e7          	jalr	-634(ra) # 80001bbc <transvirt>
}
    80002e3e:	70e2                	ld	ra,56(sp)
    80002e40:	7442                	ld	s0,48(sp)
    80002e42:	74a2                	ld	s1,40(sp)
    80002e44:	7902                	ld	s2,32(sp)
    80002e46:	69e2                	ld	s3,24(sp)
    80002e48:	6a42                	ld	s4,16(sp)
    80002e4a:	6aa2                	ld	s5,8(sp)
    80002e4c:	6121                	addi	sp,sp,64
    80002e4e:	8082                	ret

0000000080002e50 <swtch>:
    80002e50:	00153023          	sd	ra,0(a0)
    80002e54:	00253423          	sd	sp,8(a0)
    80002e58:	e900                	sd	s0,16(a0)
    80002e5a:	ed04                	sd	s1,24(a0)
    80002e5c:	03253023          	sd	s2,32(a0)
    80002e60:	03353423          	sd	s3,40(a0)
    80002e64:	03453823          	sd	s4,48(a0)
    80002e68:	03553c23          	sd	s5,56(a0)
    80002e6c:	05653023          	sd	s6,64(a0)
    80002e70:	05753423          	sd	s7,72(a0)
    80002e74:	05853823          	sd	s8,80(a0)
    80002e78:	05953c23          	sd	s9,88(a0)
    80002e7c:	07a53023          	sd	s10,96(a0)
    80002e80:	07b53423          	sd	s11,104(a0)
    80002e84:	0005b083          	ld	ra,0(a1)
    80002e88:	0085b103          	ld	sp,8(a1)
    80002e8c:	6980                	ld	s0,16(a1)
    80002e8e:	6d84                	ld	s1,24(a1)
    80002e90:	0205b903          	ld	s2,32(a1)
    80002e94:	0285b983          	ld	s3,40(a1)
    80002e98:	0305ba03          	ld	s4,48(a1)
    80002e9c:	0385ba83          	ld	s5,56(a1)
    80002ea0:	0405bb03          	ld	s6,64(a1)
    80002ea4:	0485bb83          	ld	s7,72(a1)
    80002ea8:	0505bc03          	ld	s8,80(a1)
    80002eac:	0585bc83          	ld	s9,88(a1)
    80002eb0:	0605bd03          	ld	s10,96(a1)
    80002eb4:	0685bd83          	ld	s11,104(a1)
    80002eb8:	8082                	ret

0000000080002eba <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002eba:	1141                	addi	sp,sp,-16
    80002ebc:	e406                	sd	ra,8(sp)
    80002ebe:	e022                	sd	s0,0(sp)
    80002ec0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ec2:	00005597          	auipc	a1,0x5
    80002ec6:	53e58593          	addi	a1,a1,1342 # 80008400 <__func__.1+0x3f8>
    80002eca:	0001f517          	auipc	a0,0x1f
    80002ece:	94e50513          	addi	a0,a0,-1714 # 80021818 <tickslock>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	fd4080e7          	jalr	-44(ra) # 80000ea6 <initlock>
}
    80002eda:	60a2                	ld	ra,8(sp)
    80002edc:	6402                	ld	s0,0(sp)
    80002ede:	0141                	addi	sp,sp,16
    80002ee0:	8082                	ret

0000000080002ee2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002ee2:	1141                	addi	sp,sp,-16
    80002ee4:	e422                	sd	s0,8(sp)
    80002ee6:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002ee8:	00003797          	auipc	a5,0x3
    80002eec:	7f878793          	addi	a5,a5,2040 # 800066e0 <kernelvec>
    80002ef0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ef4:	6422                	ld	s0,8(sp)
    80002ef6:	0141                	addi	sp,sp,16
    80002ef8:	8082                	ret

0000000080002efa <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002efa:	1141                	addi	sp,sp,-16
    80002efc:	e406                	sd	ra,8(sp)
    80002efe:	e022                	sd	s0,0(sp)
    80002f00:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002f02:	fffff097          	auipc	ra,0xfffff
    80002f06:	0d6080e7          	jalr	214(ra) # 80001fd8 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f0a:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002f0e:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002f10:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002f14:	00004697          	auipc	a3,0x4
    80002f18:	0ec68693          	addi	a3,a3,236 # 80007000 <_trampoline>
    80002f1c:	00004717          	auipc	a4,0x4
    80002f20:	0e470713          	addi	a4,a4,228 # 80007000 <_trampoline>
    80002f24:	8f15                	sub	a4,a4,a3
    80002f26:	040007b7          	lui	a5,0x4000
    80002f2a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002f2c:	07b2                	slli	a5,a5,0xc
    80002f2e:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002f30:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002f34:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002f36:	18002673          	csrr	a2,satp
    80002f3a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002f3c:	6d30                	ld	a2,88(a0)
    80002f3e:	6138                	ld	a4,64(a0)
    80002f40:	6585                	lui	a1,0x1
    80002f42:	972e                	add	a4,a4,a1
    80002f44:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002f46:	6d38                	ld	a4,88(a0)
    80002f48:	00000617          	auipc	a2,0x0
    80002f4c:	13860613          	addi	a2,a2,312 # 80003080 <usertrap>
    80002f50:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002f52:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002f54:	8612                	mv	a2,tp
    80002f56:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f58:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f5c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f60:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002f64:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002f68:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002f6a:	6f18                	ld	a4,24(a4)
    80002f6c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002f70:	6928                	ld	a0,80(a0)
    80002f72:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002f74:	00004717          	auipc	a4,0x4
    80002f78:	12870713          	addi	a4,a4,296 # 8000709c <userret>
    80002f7c:	8f15                	sub	a4,a4,a3
    80002f7e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002f80:	577d                	li	a4,-1
    80002f82:	177e                	slli	a4,a4,0x3f
    80002f84:	8d59                	or	a0,a0,a4
    80002f86:	9782                	jalr	a5
}
    80002f88:	60a2                	ld	ra,8(sp)
    80002f8a:	6402                	ld	s0,0(sp)
    80002f8c:	0141                	addi	sp,sp,16
    80002f8e:	8082                	ret

0000000080002f90 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002f90:	1101                	addi	sp,sp,-32
    80002f92:	ec06                	sd	ra,24(sp)
    80002f94:	e822                	sd	s0,16(sp)
    80002f96:	e426                	sd	s1,8(sp)
    80002f98:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002f9a:	0001f497          	auipc	s1,0x1f
    80002f9e:	87e48493          	addi	s1,s1,-1922 # 80021818 <tickslock>
    80002fa2:	8526                	mv	a0,s1
    80002fa4:	ffffe097          	auipc	ra,0xffffe
    80002fa8:	f92080e7          	jalr	-110(ra) # 80000f36 <acquire>
  ticks++;
    80002fac:	00008517          	auipc	a0,0x8
    80002fb0:	7b450513          	addi	a0,a0,1972 # 8000b760 <ticks>
    80002fb4:	411c                	lw	a5,0(a0)
    80002fb6:	2785                	addiw	a5,a5,1
    80002fb8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002fba:	00000097          	auipc	ra,0x0
    80002fbe:	834080e7          	jalr	-1996(ra) # 800027ee <wakeup>
  release(&tickslock);
    80002fc2:	8526                	mv	a0,s1
    80002fc4:	ffffe097          	auipc	ra,0xffffe
    80002fc8:	026080e7          	jalr	38(ra) # 80000fea <release>
}
    80002fcc:	60e2                	ld	ra,24(sp)
    80002fce:	6442                	ld	s0,16(sp)
    80002fd0:	64a2                	ld	s1,8(sp)
    80002fd2:	6105                	addi	sp,sp,32
    80002fd4:	8082                	ret

0000000080002fd6 <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80002fd6:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002fda:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002fdc:	0a07d163          	bgez	a5,8000307e <devintr+0xa8>
{
    80002fe0:	1101                	addi	sp,sp,-32
    80002fe2:	ec06                	sd	ra,24(sp)
    80002fe4:	e822                	sd	s0,16(sp)
    80002fe6:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002fe8:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002fec:	46a5                	li	a3,9
    80002fee:	00d70c63          	beq	a4,a3,80003006 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002ff2:	577d                	li	a4,-1
    80002ff4:	177e                	slli	a4,a4,0x3f
    80002ff6:	0705                	addi	a4,a4,1
    return 0;
    80002ff8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ffa:	06e78163          	beq	a5,a4,8000305c <devintr+0x86>
  }
}
    80002ffe:	60e2                	ld	ra,24(sp)
    80003000:	6442                	ld	s0,16(sp)
    80003002:	6105                	addi	sp,sp,32
    80003004:	8082                	ret
    80003006:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80003008:	00003097          	auipc	ra,0x3
    8000300c:	7e4080e7          	jalr	2020(ra) # 800067ec <plic_claim>
    80003010:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003012:	47a9                	li	a5,10
    80003014:	00f50963          	beq	a0,a5,80003026 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80003018:	4785                	li	a5,1
    8000301a:	00f50b63          	beq	a0,a5,80003030 <devintr+0x5a>
    return 1;
    8000301e:	4505                	li	a0,1
    } else if(irq){
    80003020:	ec89                	bnez	s1,8000303a <devintr+0x64>
    80003022:	64a2                	ld	s1,8(sp)
    80003024:	bfe9                	j	80002ffe <devintr+0x28>
      uartintr();
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	9e6080e7          	jalr	-1562(ra) # 80000a0c <uartintr>
    if(irq)
    8000302e:	a839                	j	8000304c <devintr+0x76>
      virtio_disk_intr();
    80003030:	00004097          	auipc	ra,0x4
    80003034:	ce6080e7          	jalr	-794(ra) # 80006d16 <virtio_disk_intr>
    if(irq)
    80003038:	a811                	j	8000304c <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    8000303a:	85a6                	mv	a1,s1
    8000303c:	00005517          	auipc	a0,0x5
    80003040:	3cc50513          	addi	a0,a0,972 # 80008408 <__func__.1+0x400>
    80003044:	ffffd097          	auipc	ra,0xffffd
    80003048:	578080e7          	jalr	1400(ra) # 800005bc <printf>
      plic_complete(irq);
    8000304c:	8526                	mv	a0,s1
    8000304e:	00003097          	auipc	ra,0x3
    80003052:	7c2080e7          	jalr	1986(ra) # 80006810 <plic_complete>
    return 1;
    80003056:	4505                	li	a0,1
    80003058:	64a2                	ld	s1,8(sp)
    8000305a:	b755                	j	80002ffe <devintr+0x28>
    if(cpuid() == 0){
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	f50080e7          	jalr	-176(ra) # 80001fac <cpuid>
    80003064:	c901                	beqz	a0,80003074 <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    80003066:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000306a:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    8000306c:	14479073          	csrw	sip,a5
    return 2;
    80003070:	4509                	li	a0,2
    80003072:	b771                	j	80002ffe <devintr+0x28>
      clockintr();
    80003074:	00000097          	auipc	ra,0x0
    80003078:	f1c080e7          	jalr	-228(ra) # 80002f90 <clockintr>
    8000307c:	b7ed                	j	80003066 <devintr+0x90>
}
    8000307e:	8082                	ret

0000000080003080 <usertrap>:
{
    80003080:	1101                	addi	sp,sp,-32
    80003082:	ec06                	sd	ra,24(sp)
    80003084:	e822                	sd	s0,16(sp)
    80003086:	e426                	sd	s1,8(sp)
    80003088:	e04a                	sd	s2,0(sp)
    8000308a:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000308c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003090:	1007f793          	andi	a5,a5,256
    80003094:	eba9                	bnez	a5,800030e6 <usertrap+0x66>
    asm volatile("csrw stvec, %0" : : "r"(x));
    80003096:	00003797          	auipc	a5,0x3
    8000309a:	64a78793          	addi	a5,a5,1610 # 800066e0 <kernelvec>
    8000309e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800030a2:	fffff097          	auipc	ra,0xfffff
    800030a6:	f36080e7          	jalr	-202(ra) # 80001fd8 <myproc>
    800030aa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800030ac:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    800030ae:	14102773          	csrr	a4,sepc
    800030b2:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    800030b4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800030b8:	47a1                	li	a5,8
    800030ba:	02f70e63          	beq	a4,a5,800030f6 <usertrap+0x76>
    800030be:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    800030c2:	47bd                	li	a5,15
    800030c4:	08f70363          	beq	a4,a5,8000314a <usertrap+0xca>
  } else if((which_dev = devintr()) != 0){
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	f0e080e7          	jalr	-242(ra) # 80002fd6 <devintr>
    800030d0:	892a                	mv	s2,a0
    800030d2:	12050663          	beqz	a0,800031fe <usertrap+0x17e>
  if(killed(p))
    800030d6:	8526                	mv	a0,s1
    800030d8:	00000097          	auipc	ra,0x0
    800030dc:	95a080e7          	jalr	-1702(ra) # 80002a32 <killed>
    800030e0:	16050263          	beqz	a0,80003244 <usertrap+0x1c4>
    800030e4:	aa99                	j	8000323a <usertrap+0x1ba>
    panic("usertrap: not from user mode");
    800030e6:	00005517          	auipc	a0,0x5
    800030ea:	34250513          	addi	a0,a0,834 # 80008428 <__func__.1+0x420>
    800030ee:	ffffd097          	auipc	ra,0xffffd
    800030f2:	472080e7          	jalr	1138(ra) # 80000560 <panic>
    if(killed(p))
    800030f6:	00000097          	auipc	ra,0x0
    800030fa:	93c080e7          	jalr	-1732(ra) # 80002a32 <killed>
    800030fe:	e121                	bnez	a0,8000313e <usertrap+0xbe>
    p->trapframe->epc += 4;
    80003100:	6cb8                	ld	a4,88(s1)
    80003102:	6f1c                	ld	a5,24(a4)
    80003104:	0791                	addi	a5,a5,4
    80003106:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003108:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000310c:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80003110:	10079073          	csrw	sstatus,a5
    syscall();
    80003114:	00000097          	auipc	ra,0x0
    80003118:	38a080e7          	jalr	906(ra) # 8000349e <syscall>
  if(killed(p))
    8000311c:	8526                	mv	a0,s1
    8000311e:	00000097          	auipc	ra,0x0
    80003122:	914080e7          	jalr	-1772(ra) # 80002a32 <killed>
    80003126:	10051963          	bnez	a0,80003238 <usertrap+0x1b8>
  usertrapret();
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	dd0080e7          	jalr	-560(ra) # 80002efa <usertrapret>
}
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	64a2                	ld	s1,8(sp)
    80003138:	6902                	ld	s2,0(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret
      exit(-1);
    8000313e:	557d                	li	a0,-1
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	77e080e7          	jalr	1918(ra) # 800028be <exit>
    80003148:	bf65                	j	80003100 <usertrap+0x80>
    if(killed(p))
    8000314a:	00000097          	auipc	ra,0x0
    8000314e:	8e8080e7          	jalr	-1816(ra) # 80002a32 <killed>
    80003152:	e52d                	bnez	a0,800031bc <usertrap+0x13c>
    asm volatile("csrr %0, stval" : "=r"(x));
    80003154:	143025f3          	csrr	a1,stval
    pte_t *pte = walk(p->pagetable, va, 0);
    80003158:	4601                	li	a2,0
    8000315a:	77fd                	lui	a5,0xfffff
    8000315c:	8dfd                	and	a1,a1,a5
    8000315e:	68a8                	ld	a0,80(s1)
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	1ae080e7          	jalr	430(ra) # 8000130e <walk>
    80003168:	892a                	mv	s2,a0
    if (!pte || !(*pte & PTE_V)) {
    8000316a:	c501                	beqz	a0,80003172 <usertrap+0xf2>
    8000316c:	611c                	ld	a5,0(a0)
    8000316e:	8b85                	andi	a5,a5,1
    80003170:	eb9d                	bnez	a5,800031a6 <usertrap+0x126>
      printf("tried to write to page not mapped pid=%d", p->pid);
    80003172:	588c                	lw	a1,48(s1)
    80003174:	00005517          	auipc	a0,0x5
    80003178:	2d450513          	addi	a0,a0,724 # 80008448 <__func__.1+0x440>
    8000317c:	ffffd097          	auipc	ra,0xffffd
    80003180:	440080e7          	jalr	1088(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003184:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80003188:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000318c:	00005517          	auipc	a0,0x5
    80003190:	2ec50513          	addi	a0,a0,748 # 80008478 <__func__.1+0x470>
    80003194:	ffffd097          	auipc	ra,0xffffd
    80003198:	428080e7          	jalr	1064(ra) # 800005bc <printf>
      setkilled(p);
    8000319c:	8526                	mv	a0,s1
    8000319e:	00000097          	auipc	ra,0x0
    800031a2:	868080e7          	jalr	-1944(ra) # 80002a06 <setkilled>
    int isCOW = PTE_COW & *pte;
    800031a6:	00093783          	ld	a5,0(s2)
    if (isCOW)
    800031aa:	2007f793          	andi	a5,a5,512
    800031ae:	cf89                	beqz	a5,800031c8 <usertrap+0x148>
      cow_triggered(pte);
    800031b0:	854a                	mv	a0,s2
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	bcc080e7          	jalr	-1076(ra) # 80000d7e <cow_triggered>
    800031ba:	b78d                	j	8000311c <usertrap+0x9c>
      exit(-1);
    800031bc:	557d                	li	a0,-1
    800031be:	fffff097          	auipc	ra,0xfffff
    800031c2:	700080e7          	jalr	1792(ra) # 800028be <exit>
    800031c6:	b779                	j	80003154 <usertrap+0xd4>
      printf("illegal write pid=%d", p->pid);
    800031c8:	588c                	lw	a1,48(s1)
    800031ca:	00005517          	auipc	a0,0x5
    800031ce:	2ce50513          	addi	a0,a0,718 # 80008498 <__func__.1+0x490>
    800031d2:	ffffd097          	auipc	ra,0xffffd
    800031d6:	3ea080e7          	jalr	1002(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800031da:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800031de:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031e2:	00005517          	auipc	a0,0x5
    800031e6:	29650513          	addi	a0,a0,662 # 80008478 <__func__.1+0x470>
    800031ea:	ffffd097          	auipc	ra,0xffffd
    800031ee:	3d2080e7          	jalr	978(ra) # 800005bc <printf>
      setkilled(p);
    800031f2:	8526                	mv	a0,s1
    800031f4:	00000097          	auipc	ra,0x0
    800031f8:	812080e7          	jalr	-2030(ra) # 80002a06 <setkilled>
    800031fc:	b705                	j	8000311c <usertrap+0x9c>
    asm volatile("csrr %0, scause" : "=r"(x));
    800031fe:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003202:	5890                	lw	a2,48(s1)
    80003204:	00005517          	auipc	a0,0x5
    80003208:	2ac50513          	addi	a0,a0,684 # 800084b0 <__func__.1+0x4a8>
    8000320c:	ffffd097          	auipc	ra,0xffffd
    80003210:	3b0080e7          	jalr	944(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003214:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80003218:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000321c:	00005517          	auipc	a0,0x5
    80003220:	25c50513          	addi	a0,a0,604 # 80008478 <__func__.1+0x470>
    80003224:	ffffd097          	auipc	ra,0xffffd
    80003228:	398080e7          	jalr	920(ra) # 800005bc <printf>
    setkilled(p);
    8000322c:	8526                	mv	a0,s1
    8000322e:	fffff097          	auipc	ra,0xfffff
    80003232:	7d8080e7          	jalr	2008(ra) # 80002a06 <setkilled>
    80003236:	b5dd                	j	8000311c <usertrap+0x9c>
  if(killed(p))
    80003238:	4901                	li	s2,0
    exit(-1);
    8000323a:	557d                	li	a0,-1
    8000323c:	fffff097          	auipc	ra,0xfffff
    80003240:	682080e7          	jalr	1666(ra) # 800028be <exit>
  if(which_dev == 2)
    80003244:	4789                	li	a5,2
    80003246:	eef912e3          	bne	s2,a5,8000312a <usertrap+0xaa>
    yield();
    8000324a:	fffff097          	auipc	ra,0xfffff
    8000324e:	504080e7          	jalr	1284(ra) # 8000274e <yield>
    80003252:	bde1                	j	8000312a <usertrap+0xaa>

0000000080003254 <kerneltrap>:
{
    80003254:	7179                	addi	sp,sp,-48
    80003256:	f406                	sd	ra,40(sp)
    80003258:	f022                	sd	s0,32(sp)
    8000325a:	ec26                	sd	s1,24(sp)
    8000325c:	e84a                	sd	s2,16(sp)
    8000325e:	e44e                	sd	s3,8(sp)
    80003260:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80003262:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003266:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    8000326a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000326e:	1004f793          	andi	a5,s1,256
    80003272:	cb85                	beqz	a5,800032a2 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80003274:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80003278:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000327a:	ef85                	bnez	a5,800032b2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	d5a080e7          	jalr	-678(ra) # 80002fd6 <devintr>
    80003284:	cd1d                	beqz	a0,800032c2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003286:	4789                	li	a5,2
    80003288:	06f50a63          	beq	a0,a5,800032fc <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    8000328c:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80003290:	10049073          	csrw	sstatus,s1
}
    80003294:	70a2                	ld	ra,40(sp)
    80003296:	7402                	ld	s0,32(sp)
    80003298:	64e2                	ld	s1,24(sp)
    8000329a:	6942                	ld	s2,16(sp)
    8000329c:	69a2                	ld	s3,8(sp)
    8000329e:	6145                	addi	sp,sp,48
    800032a0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800032a2:	00005517          	auipc	a0,0x5
    800032a6:	23e50513          	addi	a0,a0,574 # 800084e0 <__func__.1+0x4d8>
    800032aa:	ffffd097          	auipc	ra,0xffffd
    800032ae:	2b6080e7          	jalr	694(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    800032b2:	00005517          	auipc	a0,0x5
    800032b6:	25650513          	addi	a0,a0,598 # 80008508 <__func__.1+0x500>
    800032ba:	ffffd097          	auipc	ra,0xffffd
    800032be:	2a6080e7          	jalr	678(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    800032c2:	85ce                	mv	a1,s3
    800032c4:	00005517          	auipc	a0,0x5
    800032c8:	26450513          	addi	a0,a0,612 # 80008528 <__func__.1+0x520>
    800032cc:	ffffd097          	auipc	ra,0xffffd
    800032d0:	2f0080e7          	jalr	752(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    800032d4:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    800032d8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	25c50513          	addi	a0,a0,604 # 80008538 <__func__.1+0x530>
    800032e4:	ffffd097          	auipc	ra,0xffffd
    800032e8:	2d8080e7          	jalr	728(ra) # 800005bc <printf>
    panic("kerneltrap");
    800032ec:	00005517          	auipc	a0,0x5
    800032f0:	26450513          	addi	a0,a0,612 # 80008550 <__func__.1+0x548>
    800032f4:	ffffd097          	auipc	ra,0xffffd
    800032f8:	26c080e7          	jalr	620(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800032fc:	fffff097          	auipc	ra,0xfffff
    80003300:	cdc080e7          	jalr	-804(ra) # 80001fd8 <myproc>
    80003304:	d541                	beqz	a0,8000328c <kerneltrap+0x38>
    80003306:	fffff097          	auipc	ra,0xfffff
    8000330a:	cd2080e7          	jalr	-814(ra) # 80001fd8 <myproc>
    8000330e:	4d18                	lw	a4,24(a0)
    80003310:	4791                	li	a5,4
    80003312:	f6f71de3          	bne	a4,a5,8000328c <kerneltrap+0x38>
    yield();
    80003316:	fffff097          	auipc	ra,0xfffff
    8000331a:	438080e7          	jalr	1080(ra) # 8000274e <yield>
    8000331e:	b7bd                	j	8000328c <kerneltrap+0x38>

0000000080003320 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80003320:	1101                	addi	sp,sp,-32
    80003322:	ec06                	sd	ra,24(sp)
    80003324:	e822                	sd	s0,16(sp)
    80003326:	e426                	sd	s1,8(sp)
    80003328:	1000                	addi	s0,sp,32
    8000332a:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    8000332c:	fffff097          	auipc	ra,0xfffff
    80003330:	cac080e7          	jalr	-852(ra) # 80001fd8 <myproc>
    switch (n)
    80003334:	4795                	li	a5,5
    80003336:	0497e163          	bltu	a5,s1,80003378 <argraw+0x58>
    8000333a:	048a                	slli	s1,s1,0x2
    8000333c:	00005717          	auipc	a4,0x5
    80003340:	5dc70713          	addi	a4,a4,1500 # 80008918 <states.0+0x30>
    80003344:	94ba                	add	s1,s1,a4
    80003346:	409c                	lw	a5,0(s1)
    80003348:	97ba                	add	a5,a5,a4
    8000334a:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    8000334c:	6d3c                	ld	a5,88(a0)
    8000334e:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80003350:	60e2                	ld	ra,24(sp)
    80003352:	6442                	ld	s0,16(sp)
    80003354:	64a2                	ld	s1,8(sp)
    80003356:	6105                	addi	sp,sp,32
    80003358:	8082                	ret
        return p->trapframe->a1;
    8000335a:	6d3c                	ld	a5,88(a0)
    8000335c:	7fa8                	ld	a0,120(a5)
    8000335e:	bfcd                	j	80003350 <argraw+0x30>
        return p->trapframe->a2;
    80003360:	6d3c                	ld	a5,88(a0)
    80003362:	63c8                	ld	a0,128(a5)
    80003364:	b7f5                	j	80003350 <argraw+0x30>
        return p->trapframe->a3;
    80003366:	6d3c                	ld	a5,88(a0)
    80003368:	67c8                	ld	a0,136(a5)
    8000336a:	b7dd                	j	80003350 <argraw+0x30>
        return p->trapframe->a4;
    8000336c:	6d3c                	ld	a5,88(a0)
    8000336e:	6bc8                	ld	a0,144(a5)
    80003370:	b7c5                	j	80003350 <argraw+0x30>
        return p->trapframe->a5;
    80003372:	6d3c                	ld	a5,88(a0)
    80003374:	6fc8                	ld	a0,152(a5)
    80003376:	bfe9                	j	80003350 <argraw+0x30>
    panic("argraw");
    80003378:	00005517          	auipc	a0,0x5
    8000337c:	1e850513          	addi	a0,a0,488 # 80008560 <__func__.1+0x558>
    80003380:	ffffd097          	auipc	ra,0xffffd
    80003384:	1e0080e7          	jalr	480(ra) # 80000560 <panic>

0000000080003388 <fetchaddr>:
{
    80003388:	1101                	addi	sp,sp,-32
    8000338a:	ec06                	sd	ra,24(sp)
    8000338c:	e822                	sd	s0,16(sp)
    8000338e:	e426                	sd	s1,8(sp)
    80003390:	e04a                	sd	s2,0(sp)
    80003392:	1000                	addi	s0,sp,32
    80003394:	84aa                	mv	s1,a0
    80003396:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80003398:	fffff097          	auipc	ra,0xfffff
    8000339c:	c40080e7          	jalr	-960(ra) # 80001fd8 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800033a0:	653c                	ld	a5,72(a0)
    800033a2:	02f4f863          	bgeu	s1,a5,800033d2 <fetchaddr+0x4a>
    800033a6:	00848713          	addi	a4,s1,8
    800033aa:	02e7e663          	bltu	a5,a4,800033d6 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800033ae:	46a1                	li	a3,8
    800033b0:	8626                	mv	a2,s1
    800033b2:	85ca                	mv	a1,s2
    800033b4:	6928                	ld	a0,80(a0)
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	6bc080e7          	jalr	1724(ra) # 80001a72 <copyin>
    800033be:	00a03533          	snez	a0,a0
    800033c2:	40a00533          	neg	a0,a0
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6902                	ld	s2,0(sp)
    800033ce:	6105                	addi	sp,sp,32
    800033d0:	8082                	ret
        return -1;
    800033d2:	557d                	li	a0,-1
    800033d4:	bfcd                	j	800033c6 <fetchaddr+0x3e>
    800033d6:	557d                	li	a0,-1
    800033d8:	b7fd                	j	800033c6 <fetchaddr+0x3e>

00000000800033da <fetchstr>:
{
    800033da:	7179                	addi	sp,sp,-48
    800033dc:	f406                	sd	ra,40(sp)
    800033de:	f022                	sd	s0,32(sp)
    800033e0:	ec26                	sd	s1,24(sp)
    800033e2:	e84a                	sd	s2,16(sp)
    800033e4:	e44e                	sd	s3,8(sp)
    800033e6:	1800                	addi	s0,sp,48
    800033e8:	892a                	mv	s2,a0
    800033ea:	84ae                	mv	s1,a1
    800033ec:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    800033ee:	fffff097          	auipc	ra,0xfffff
    800033f2:	bea080e7          	jalr	-1046(ra) # 80001fd8 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800033f6:	86ce                	mv	a3,s3
    800033f8:	864a                	mv	a2,s2
    800033fa:	85a6                	mv	a1,s1
    800033fc:	6928                	ld	a0,80(a0)
    800033fe:	ffffe097          	auipc	ra,0xffffe
    80003402:	702080e7          	jalr	1794(ra) # 80001b00 <copyinstr>
    80003406:	00054e63          	bltz	a0,80003422 <fetchstr+0x48>
    return strlen(buf);
    8000340a:	8526                	mv	a0,s1
    8000340c:	ffffe097          	auipc	ra,0xffffe
    80003410:	d9a080e7          	jalr	-614(ra) # 800011a6 <strlen>
}
    80003414:	70a2                	ld	ra,40(sp)
    80003416:	7402                	ld	s0,32(sp)
    80003418:	64e2                	ld	s1,24(sp)
    8000341a:	6942                	ld	s2,16(sp)
    8000341c:	69a2                	ld	s3,8(sp)
    8000341e:	6145                	addi	sp,sp,48
    80003420:	8082                	ret
        return -1;
    80003422:	557d                	li	a0,-1
    80003424:	bfc5                	j	80003414 <fetchstr+0x3a>

0000000080003426 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003426:	1101                	addi	sp,sp,-32
    80003428:	ec06                	sd	ra,24(sp)
    8000342a:	e822                	sd	s0,16(sp)
    8000342c:	e426                	sd	s1,8(sp)
    8000342e:	1000                	addi	s0,sp,32
    80003430:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003432:	00000097          	auipc	ra,0x0
    80003436:	eee080e7          	jalr	-274(ra) # 80003320 <argraw>
    8000343a:	c088                	sw	a0,0(s1)
}
    8000343c:	60e2                	ld	ra,24(sp)
    8000343e:	6442                	ld	s0,16(sp)
    80003440:	64a2                	ld	s1,8(sp)
    80003442:	6105                	addi	sp,sp,32
    80003444:	8082                	ret

0000000080003446 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003446:	1101                	addi	sp,sp,-32
    80003448:	ec06                	sd	ra,24(sp)
    8000344a:	e822                	sd	s0,16(sp)
    8000344c:	e426                	sd	s1,8(sp)
    8000344e:	1000                	addi	s0,sp,32
    80003450:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003452:	00000097          	auipc	ra,0x0
    80003456:	ece080e7          	jalr	-306(ra) # 80003320 <argraw>
    8000345a:	e088                	sd	a0,0(s1)
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6105                	addi	sp,sp,32
    80003464:	8082                	ret

0000000080003466 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003466:	7179                	addi	sp,sp,-48
    80003468:	f406                	sd	ra,40(sp)
    8000346a:	f022                	sd	s0,32(sp)
    8000346c:	ec26                	sd	s1,24(sp)
    8000346e:	e84a                	sd	s2,16(sp)
    80003470:	1800                	addi	s0,sp,48
    80003472:	84ae                	mv	s1,a1
    80003474:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80003476:	fd840593          	addi	a1,s0,-40
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	fcc080e7          	jalr	-52(ra) # 80003446 <argaddr>
    return fetchstr(addr, buf, max);
    80003482:	864a                	mv	a2,s2
    80003484:	85a6                	mv	a1,s1
    80003486:	fd843503          	ld	a0,-40(s0)
    8000348a:	00000097          	auipc	ra,0x0
    8000348e:	f50080e7          	jalr	-176(ra) # 800033da <fetchstr>
}
    80003492:	70a2                	ld	ra,40(sp)
    80003494:	7402                	ld	s0,32(sp)
    80003496:	64e2                	ld	s1,24(sp)
    80003498:	6942                	ld	s2,16(sp)
    8000349a:	6145                	addi	sp,sp,48
    8000349c:	8082                	ret

000000008000349e <syscall>:
    [SYS_va2pa] sys_va2pa,
    [SYS_mmap] sys_mmap,
};

void syscall(void)
{
    8000349e:	1101                	addi	sp,sp,-32
    800034a0:	ec06                	sd	ra,24(sp)
    800034a2:	e822                	sd	s0,16(sp)
    800034a4:	e426                	sd	s1,8(sp)
    800034a6:	e04a                	sd	s2,0(sp)
    800034a8:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    800034aa:	fffff097          	auipc	ra,0xfffff
    800034ae:	b2e080e7          	jalr	-1234(ra) # 80001fd8 <myproc>
    800034b2:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    800034b4:	05853903          	ld	s2,88(a0)
    800034b8:	0a893783          	ld	a5,168(s2)
    800034bc:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800034c0:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffd2407>
    800034c2:	4769                	li	a4,26
    800034c4:	00f76f63          	bltu	a4,a5,800034e2 <syscall+0x44>
    800034c8:	00369713          	slli	a4,a3,0x3
    800034cc:	00005797          	auipc	a5,0x5
    800034d0:	46478793          	addi	a5,a5,1124 # 80008930 <syscalls>
    800034d4:	97ba                	add	a5,a5,a4
    800034d6:	639c                	ld	a5,0(a5)
    800034d8:	c789                	beqz	a5,800034e2 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800034da:	9782                	jalr	a5
    800034dc:	06a93823          	sd	a0,112(s2)
    800034e0:	a839                	j	800034fe <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800034e2:	15848613          	addi	a2,s1,344
    800034e6:	588c                	lw	a1,48(s1)
    800034e8:	00005517          	auipc	a0,0x5
    800034ec:	08050513          	addi	a0,a0,128 # 80008568 <__func__.1+0x560>
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	0cc080e7          	jalr	204(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    800034f8:	6cbc                	ld	a5,88(s1)
    800034fa:	577d                	li	a4,-1
    800034fc:	fbb8                	sd	a4,112(a5)
    }
}
    800034fe:	60e2                	ld	ra,24(sp)
    80003500:	6442                	ld	s0,16(sp)
    80003502:	64a2                	ld	s1,8(sp)
    80003504:	6902                	ld	s2,0(sp)
    80003506:	6105                	addi	sp,sp,32
    80003508:	8082                	ret

000000008000350a <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    8000350a:	1101                	addi	sp,sp,-32
    8000350c:	ec06                	sd	ra,24(sp)
    8000350e:	e822                	sd	s0,16(sp)
    80003510:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80003512:	fec40593          	addi	a1,s0,-20
    80003516:	4501                	li	a0,0
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	f0e080e7          	jalr	-242(ra) # 80003426 <argint>
    exit(n);
    80003520:	fec42503          	lw	a0,-20(s0)
    80003524:	fffff097          	auipc	ra,0xfffff
    80003528:	39a080e7          	jalr	922(ra) # 800028be <exit>
    return 0; // not reached
}
    8000352c:	4501                	li	a0,0
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	6105                	addi	sp,sp,32
    80003534:	8082                	ret

0000000080003536 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003536:	1141                	addi	sp,sp,-16
    80003538:	e406                	sd	ra,8(sp)
    8000353a:	e022                	sd	s0,0(sp)
    8000353c:	0800                	addi	s0,sp,16
    return myproc()->pid;
    8000353e:	fffff097          	auipc	ra,0xfffff
    80003542:	a9a080e7          	jalr	-1382(ra) # 80001fd8 <myproc>
}
    80003546:	5908                	lw	a0,48(a0)
    80003548:	60a2                	ld	ra,8(sp)
    8000354a:	6402                	ld	s0,0(sp)
    8000354c:	0141                	addi	sp,sp,16
    8000354e:	8082                	ret

0000000080003550 <sys_fork>:

uint64
sys_fork(void)
{
    80003550:	1141                	addi	sp,sp,-16
    80003552:	e406                	sd	ra,8(sp)
    80003554:	e022                	sd	s0,0(sp)
    80003556:	0800                	addi	s0,sp,16
    return fork();
    80003558:	fffff097          	auipc	ra,0xfffff
    8000355c:	fce080e7          	jalr	-50(ra) # 80002526 <fork>
}
    80003560:	60a2                	ld	ra,8(sp)
    80003562:	6402                	ld	s0,0(sp)
    80003564:	0141                	addi	sp,sp,16
    80003566:	8082                	ret

0000000080003568 <sys_wait>:

uint64
sys_wait(void)
{
    80003568:	1101                	addi	sp,sp,-32
    8000356a:	ec06                	sd	ra,24(sp)
    8000356c:	e822                	sd	s0,16(sp)
    8000356e:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003570:	fe840593          	addi	a1,s0,-24
    80003574:	4501                	li	a0,0
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	ed0080e7          	jalr	-304(ra) # 80003446 <argaddr>
    return wait(p);
    8000357e:	fe843503          	ld	a0,-24(s0)
    80003582:	fffff097          	auipc	ra,0xfffff
    80003586:	4e2080e7          	jalr	1250(ra) # 80002a64 <wait>
}
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	6105                	addi	sp,sp,32
    80003590:	8082                	ret

0000000080003592 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003592:	7179                	addi	sp,sp,-48
    80003594:	f406                	sd	ra,40(sp)
    80003596:	f022                	sd	s0,32(sp)
    80003598:	ec26                	sd	s1,24(sp)
    8000359a:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    8000359c:	fdc40593          	addi	a1,s0,-36
    800035a0:	4501                	li	a0,0
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	e84080e7          	jalr	-380(ra) # 80003426 <argint>
    addr = myproc()->sz;
    800035aa:	fffff097          	auipc	ra,0xfffff
    800035ae:	a2e080e7          	jalr	-1490(ra) # 80001fd8 <myproc>
    800035b2:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    800035b4:	fdc42503          	lw	a0,-36(s0)
    800035b8:	fffff097          	auipc	ra,0xfffff
    800035bc:	d7a080e7          	jalr	-646(ra) # 80002332 <growproc>
    800035c0:	00054863          	bltz	a0,800035d0 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800035c4:	8526                	mv	a0,s1
    800035c6:	70a2                	ld	ra,40(sp)
    800035c8:	7402                	ld	s0,32(sp)
    800035ca:	64e2                	ld	s1,24(sp)
    800035cc:	6145                	addi	sp,sp,48
    800035ce:	8082                	ret
        return -1;
    800035d0:	54fd                	li	s1,-1
    800035d2:	bfcd                	j	800035c4 <sys_sbrk+0x32>

00000000800035d4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800035d4:	7139                	addi	sp,sp,-64
    800035d6:	fc06                	sd	ra,56(sp)
    800035d8:	f822                	sd	s0,48(sp)
    800035da:	f04a                	sd	s2,32(sp)
    800035dc:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800035de:	fcc40593          	addi	a1,s0,-52
    800035e2:	4501                	li	a0,0
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	e42080e7          	jalr	-446(ra) # 80003426 <argint>
    acquire(&tickslock);
    800035ec:	0001e517          	auipc	a0,0x1e
    800035f0:	22c50513          	addi	a0,a0,556 # 80021818 <tickslock>
    800035f4:	ffffe097          	auipc	ra,0xffffe
    800035f8:	942080e7          	jalr	-1726(ra) # 80000f36 <acquire>
    ticks0 = ticks;
    800035fc:	00008917          	auipc	s2,0x8
    80003600:	16492903          	lw	s2,356(s2) # 8000b760 <ticks>
    while (ticks - ticks0 < n)
    80003604:	fcc42783          	lw	a5,-52(s0)
    80003608:	c3b9                	beqz	a5,8000364e <sys_sleep+0x7a>
    8000360a:	f426                	sd	s1,40(sp)
    8000360c:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    8000360e:	0001e997          	auipc	s3,0x1e
    80003612:	20a98993          	addi	s3,s3,522 # 80021818 <tickslock>
    80003616:	00008497          	auipc	s1,0x8
    8000361a:	14a48493          	addi	s1,s1,330 # 8000b760 <ticks>
        if (killed(myproc()))
    8000361e:	fffff097          	auipc	ra,0xfffff
    80003622:	9ba080e7          	jalr	-1606(ra) # 80001fd8 <myproc>
    80003626:	fffff097          	auipc	ra,0xfffff
    8000362a:	40c080e7          	jalr	1036(ra) # 80002a32 <killed>
    8000362e:	ed15                	bnez	a0,8000366a <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003630:	85ce                	mv	a1,s3
    80003632:	8526                	mv	a0,s1
    80003634:	fffff097          	auipc	ra,0xfffff
    80003638:	156080e7          	jalr	342(ra) # 8000278a <sleep>
    while (ticks - ticks0 < n)
    8000363c:	409c                	lw	a5,0(s1)
    8000363e:	412787bb          	subw	a5,a5,s2
    80003642:	fcc42703          	lw	a4,-52(s0)
    80003646:	fce7ece3          	bltu	a5,a4,8000361e <sys_sleep+0x4a>
    8000364a:	74a2                	ld	s1,40(sp)
    8000364c:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    8000364e:	0001e517          	auipc	a0,0x1e
    80003652:	1ca50513          	addi	a0,a0,458 # 80021818 <tickslock>
    80003656:	ffffe097          	auipc	ra,0xffffe
    8000365a:	994080e7          	jalr	-1644(ra) # 80000fea <release>
    return 0;
    8000365e:	4501                	li	a0,0
}
    80003660:	70e2                	ld	ra,56(sp)
    80003662:	7442                	ld	s0,48(sp)
    80003664:	7902                	ld	s2,32(sp)
    80003666:	6121                	addi	sp,sp,64
    80003668:	8082                	ret
            release(&tickslock);
    8000366a:	0001e517          	auipc	a0,0x1e
    8000366e:	1ae50513          	addi	a0,a0,430 # 80021818 <tickslock>
    80003672:	ffffe097          	auipc	ra,0xffffe
    80003676:	978080e7          	jalr	-1672(ra) # 80000fea <release>
            return -1;
    8000367a:	557d                	li	a0,-1
    8000367c:	74a2                	ld	s1,40(sp)
    8000367e:	69e2                	ld	s3,24(sp)
    80003680:	b7c5                	j	80003660 <sys_sleep+0x8c>

0000000080003682 <sys_kill>:

uint64
sys_kill(void)
{
    80003682:	1101                	addi	sp,sp,-32
    80003684:	ec06                	sd	ra,24(sp)
    80003686:	e822                	sd	s0,16(sp)
    80003688:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000368a:	fec40593          	addi	a1,s0,-20
    8000368e:	4501                	li	a0,0
    80003690:	00000097          	auipc	ra,0x0
    80003694:	d96080e7          	jalr	-618(ra) # 80003426 <argint>
    return kill(pid);
    80003698:	fec42503          	lw	a0,-20(s0)
    8000369c:	fffff097          	auipc	ra,0xfffff
    800036a0:	2f8080e7          	jalr	760(ra) # 80002994 <kill>
}
    800036a4:	60e2                	ld	ra,24(sp)
    800036a6:	6442                	ld	s0,16(sp)
    800036a8:	6105                	addi	sp,sp,32
    800036aa:	8082                	ret

00000000800036ac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800036ac:	1101                	addi	sp,sp,-32
    800036ae:	ec06                	sd	ra,24(sp)
    800036b0:	e822                	sd	s0,16(sp)
    800036b2:	e426                	sd	s1,8(sp)
    800036b4:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800036b6:	0001e517          	auipc	a0,0x1e
    800036ba:	16250513          	addi	a0,a0,354 # 80021818 <tickslock>
    800036be:	ffffe097          	auipc	ra,0xffffe
    800036c2:	878080e7          	jalr	-1928(ra) # 80000f36 <acquire>
    xticks = ticks;
    800036c6:	00008497          	auipc	s1,0x8
    800036ca:	09a4a483          	lw	s1,154(s1) # 8000b760 <ticks>
    release(&tickslock);
    800036ce:	0001e517          	auipc	a0,0x1e
    800036d2:	14a50513          	addi	a0,a0,330 # 80021818 <tickslock>
    800036d6:	ffffe097          	auipc	ra,0xffffe
    800036da:	914080e7          	jalr	-1772(ra) # 80000fea <release>
    return xticks;
}
    800036de:	02049513          	slli	a0,s1,0x20
    800036e2:	9101                	srli	a0,a0,0x20
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	64a2                	ld	s1,8(sp)
    800036ea:	6105                	addi	sp,sp,32
    800036ec:	8082                	ret

00000000800036ee <sys_ps>:

void *
sys_ps(void)
{
    800036ee:	1101                	addi	sp,sp,-32
    800036f0:	ec06                	sd	ra,24(sp)
    800036f2:	e822                	sd	s0,16(sp)
    800036f4:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800036f6:	fe042623          	sw	zero,-20(s0)
    800036fa:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800036fe:	fec40593          	addi	a1,s0,-20
    80003702:	4501                	li	a0,0
    80003704:	00000097          	auipc	ra,0x0
    80003708:	d22080e7          	jalr	-734(ra) # 80003426 <argint>
    argint(1, &count);
    8000370c:	fe840593          	addi	a1,s0,-24
    80003710:	4505                	li	a0,1
    80003712:	00000097          	auipc	ra,0x0
    80003716:	d14080e7          	jalr	-748(ra) # 80003426 <argint>
    return ps((uint8)start, (uint8)count);
    8000371a:	fe844583          	lbu	a1,-24(s0)
    8000371e:	fec44503          	lbu	a0,-20(s0)
    80003722:	fffff097          	auipc	ra,0xfffff
    80003726:	c6c080e7          	jalr	-916(ra) # 8000238e <ps>
}
    8000372a:	60e2                	ld	ra,24(sp)
    8000372c:	6442                	ld	s0,16(sp)
    8000372e:	6105                	addi	sp,sp,32
    80003730:	8082                	ret

0000000080003732 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003732:	1141                	addi	sp,sp,-16
    80003734:	e406                	sd	ra,8(sp)
    80003736:	e022                	sd	s0,0(sp)
    80003738:	0800                	addi	s0,sp,16
    schedls();
    8000373a:	fffff097          	auipc	ra,0xfffff
    8000373e:	5b4080e7          	jalr	1460(ra) # 80002cee <schedls>
    return 0;
}
    80003742:	4501                	li	a0,0
    80003744:	60a2                	ld	ra,8(sp)
    80003746:	6402                	ld	s0,0(sp)
    80003748:	0141                	addi	sp,sp,16
    8000374a:	8082                	ret

000000008000374c <sys_schedset>:

uint64 sys_schedset(void)
{
    8000374c:	1101                	addi	sp,sp,-32
    8000374e:	ec06                	sd	ra,24(sp)
    80003750:	e822                	sd	s0,16(sp)
    80003752:	1000                	addi	s0,sp,32
    int id = 0;
    80003754:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003758:	fec40593          	addi	a1,s0,-20
    8000375c:	4501                	li	a0,0
    8000375e:	00000097          	auipc	ra,0x0
    80003762:	cc8080e7          	jalr	-824(ra) # 80003426 <argint>
    schedset(id - 1);
    80003766:	fec42503          	lw	a0,-20(s0)
    8000376a:	357d                	addiw	a0,a0,-1
    8000376c:	fffff097          	auipc	ra,0xfffff
    80003770:	618080e7          	jalr	1560(ra) # 80002d84 <schedset>
    return 0;
}
    80003774:	4501                	li	a0,0
    80003776:	60e2                	ld	ra,24(sp)
    80003778:	6442                	ld	s0,16(sp)
    8000377a:	6105                	addi	sp,sp,32
    8000377c:	8082                	ret

000000008000377e <sys_va2pa>:

uint64 sys_va2pa(void)
{
    8000377e:	7179                	addi	sp,sp,-48
    80003780:	f406                	sd	ra,40(sp)
    80003782:	f022                	sd	s0,32(sp)
    80003784:	1800                	addi	s0,sp,48
    int pid = 0;
    80003786:	fc042e23          	sw	zero,-36(s0)
    uint64 vaddr = 0;
    8000378a:	fc043823          	sd	zero,-48(s0)
    argaddr(0, &vaddr);
    8000378e:	fd040593          	addi	a1,s0,-48
    80003792:	4501                	li	a0,0
    80003794:	00000097          	auipc	ra,0x0
    80003798:	cb2080e7          	jalr	-846(ra) # 80003446 <argaddr>
    argint(1, &pid);
    8000379c:	fdc40593          	addi	a1,s0,-36
    800037a0:	4505                	li	a0,1
    800037a2:	00000097          	auipc	ra,0x0
    800037a6:	c84080e7          	jalr	-892(ra) # 80003426 <argint>
    if (pid == 0) {
    800037aa:	fdc42783          	lw	a5,-36(s0)
    800037ae:	cf89                	beqz	a5,800037c8 <sys_va2pa+0x4a>
	struct proc *p = myproc();
	acquire(&p->lock);
	pid = p->pid;
	release(&p->lock);
    }
    return transvirtproc(vaddr, pid);
    800037b0:	fdc42583          	lw	a1,-36(s0)
    800037b4:	fd043503          	ld	a0,-48(s0)
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	618080e7          	jalr	1560(ra) # 80002dd0 <transvirtproc>
}
    800037c0:	70a2                	ld	ra,40(sp)
    800037c2:	7402                	ld	s0,32(sp)
    800037c4:	6145                	addi	sp,sp,48
    800037c6:	8082                	ret
    800037c8:	ec26                	sd	s1,24(sp)
	struct proc *p = myproc();
    800037ca:	fffff097          	auipc	ra,0xfffff
    800037ce:	80e080e7          	jalr	-2034(ra) # 80001fd8 <myproc>
    800037d2:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	762080e7          	jalr	1890(ra) # 80000f36 <acquire>
	pid = p->pid;
    800037dc:	589c                	lw	a5,48(s1)
    800037de:	fcf42e23          	sw	a5,-36(s0)
	release(&p->lock);
    800037e2:	8526                	mv	a0,s1
    800037e4:	ffffe097          	auipc	ra,0xffffe
    800037e8:	806080e7          	jalr	-2042(ra) # 80000fea <release>
    800037ec:	64e2                	ld	s1,24(sp)
    800037ee:	b7c9                	j	800037b0 <sys_va2pa+0x32>

00000000800037f0 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    800037f0:	1141                	addi	sp,sp,-16
    800037f2:	e406                	sd	ra,8(sp)
    800037f4:	e022                	sd	s0,0(sp)
    800037f6:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800037f8:	00008597          	auipc	a1,0x8
    800037fc:	f405b583          	ld	a1,-192(a1) # 8000b738 <FREE_PAGES>
    80003800:	00005517          	auipc	a0,0x5
    80003804:	d8850513          	addi	a0,a0,-632 # 80008588 <__func__.1+0x580>
    80003808:	ffffd097          	auipc	ra,0xffffd
    8000380c:	db4080e7          	jalr	-588(ra) # 800005bc <printf>
    return 0;
}
    80003810:	4501                	li	a0,0
    80003812:	60a2                	ld	ra,8(sp)
    80003814:	6402                	ld	s0,0(sp)
    80003816:	0141                	addi	sp,sp,16
    80003818:	8082                	ret

000000008000381a <sys_mmap>:

uint64 sys_mmap(void)
{
    8000381a:	7179                	addi	sp,sp,-48
    8000381c:	f406                	sd	ra,40(sp)
    8000381e:	f022                	sd	s0,32(sp)
    80003820:	ec26                	sd	s1,24(sp)
    80003822:	e84a                	sd	s2,16(sp)
    80003824:	1800                	addi	s0,sp,48
    uint64 vaddr;
    int npages;
    int protocol;
    argaddr(0, &vaddr);
    80003826:	fd840593          	addi	a1,s0,-40
    8000382a:	4501                	li	a0,0
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	c1a080e7          	jalr	-998(ra) # 80003446 <argaddr>
    argint(1, &npages);
    80003834:	fd440593          	addi	a1,s0,-44
    80003838:	4505                	li	a0,1
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	bec080e7          	jalr	-1044(ra) # 80003426 <argint>
    argint(2, &protocol);
    80003842:	fd040593          	addi	a1,s0,-48
    80003846:	4509                	li	a0,2
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	bde080e7          	jalr	-1058(ra) # 80003426 <argint>
    return mmap_shared(vaddr, npages, myproc()->pagetable, protocol);
    80003850:	fd843483          	ld	s1,-40(s0)
    80003854:	fd442903          	lw	s2,-44(s0)
    80003858:	ffffe097          	auipc	ra,0xffffe
    8000385c:	780080e7          	jalr	1920(ra) # 80001fd8 <myproc>
    80003860:	fd042683          	lw	a3,-48(s0)
    80003864:	6930                	ld	a2,80(a0)
    80003866:	85ca                	mv	a1,s2
    80003868:	8526                	mv	a0,s1
    8000386a:	ffffe097          	auipc	ra,0xffffe
    8000386e:	3ae080e7          	jalr	942(ra) # 80001c18 <mmap_shared>
}
    80003872:	70a2                	ld	ra,40(sp)
    80003874:	7402                	ld	s0,32(sp)
    80003876:	64e2                	ld	s1,24(sp)
    80003878:	6942                	ld	s2,16(sp)
    8000387a:	6145                	addi	sp,sp,48
    8000387c:	8082                	ret

000000008000387e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000387e:	7179                	addi	sp,sp,-48
    80003880:	f406                	sd	ra,40(sp)
    80003882:	f022                	sd	s0,32(sp)
    80003884:	ec26                	sd	s1,24(sp)
    80003886:	e84a                	sd	s2,16(sp)
    80003888:	e44e                	sd	s3,8(sp)
    8000388a:	e052                	sd	s4,0(sp)
    8000388c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000388e:	00005597          	auipc	a1,0x5
    80003892:	d0258593          	addi	a1,a1,-766 # 80008590 <__func__.1+0x588>
    80003896:	0001e517          	auipc	a0,0x1e
    8000389a:	f9a50513          	addi	a0,a0,-102 # 80021830 <bcache>
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	608080e7          	jalr	1544(ra) # 80000ea6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800038a6:	00026797          	auipc	a5,0x26
    800038aa:	f8a78793          	addi	a5,a5,-118 # 80029830 <bcache+0x8000>
    800038ae:	00026717          	auipc	a4,0x26
    800038b2:	1ea70713          	addi	a4,a4,490 # 80029a98 <bcache+0x8268>
    800038b6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800038ba:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800038be:	0001e497          	auipc	s1,0x1e
    800038c2:	f8a48493          	addi	s1,s1,-118 # 80021848 <bcache+0x18>
    b->next = bcache.head.next;
    800038c6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800038c8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800038ca:	00005a17          	auipc	s4,0x5
    800038ce:	ccea0a13          	addi	s4,s4,-818 # 80008598 <__func__.1+0x590>
    b->next = bcache.head.next;
    800038d2:	2b893783          	ld	a5,696(s2)
    800038d6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800038d8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800038dc:	85d2                	mv	a1,s4
    800038de:	01048513          	addi	a0,s1,16
    800038e2:	00001097          	auipc	ra,0x1
    800038e6:	4e8080e7          	jalr	1256(ra) # 80004dca <initsleeplock>
    bcache.head.next->prev = b;
    800038ea:	2b893783          	ld	a5,696(s2)
    800038ee:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800038f0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800038f4:	45848493          	addi	s1,s1,1112
    800038f8:	fd349de3          	bne	s1,s3,800038d2 <binit+0x54>
  }
}
    800038fc:	70a2                	ld	ra,40(sp)
    800038fe:	7402                	ld	s0,32(sp)
    80003900:	64e2                	ld	s1,24(sp)
    80003902:	6942                	ld	s2,16(sp)
    80003904:	69a2                	ld	s3,8(sp)
    80003906:	6a02                	ld	s4,0(sp)
    80003908:	6145                	addi	sp,sp,48
    8000390a:	8082                	ret

000000008000390c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000390c:	7179                	addi	sp,sp,-48
    8000390e:	f406                	sd	ra,40(sp)
    80003910:	f022                	sd	s0,32(sp)
    80003912:	ec26                	sd	s1,24(sp)
    80003914:	e84a                	sd	s2,16(sp)
    80003916:	e44e                	sd	s3,8(sp)
    80003918:	1800                	addi	s0,sp,48
    8000391a:	892a                	mv	s2,a0
    8000391c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000391e:	0001e517          	auipc	a0,0x1e
    80003922:	f1250513          	addi	a0,a0,-238 # 80021830 <bcache>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	610080e7          	jalr	1552(ra) # 80000f36 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000392e:	00026497          	auipc	s1,0x26
    80003932:	1ba4b483          	ld	s1,442(s1) # 80029ae8 <bcache+0x82b8>
    80003936:	00026797          	auipc	a5,0x26
    8000393a:	16278793          	addi	a5,a5,354 # 80029a98 <bcache+0x8268>
    8000393e:	02f48f63          	beq	s1,a5,8000397c <bread+0x70>
    80003942:	873e                	mv	a4,a5
    80003944:	a021                	j	8000394c <bread+0x40>
    80003946:	68a4                	ld	s1,80(s1)
    80003948:	02e48a63          	beq	s1,a4,8000397c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000394c:	449c                	lw	a5,8(s1)
    8000394e:	ff279ce3          	bne	a5,s2,80003946 <bread+0x3a>
    80003952:	44dc                	lw	a5,12(s1)
    80003954:	ff3799e3          	bne	a5,s3,80003946 <bread+0x3a>
      b->refcnt++;
    80003958:	40bc                	lw	a5,64(s1)
    8000395a:	2785                	addiw	a5,a5,1
    8000395c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000395e:	0001e517          	auipc	a0,0x1e
    80003962:	ed250513          	addi	a0,a0,-302 # 80021830 <bcache>
    80003966:	ffffd097          	auipc	ra,0xffffd
    8000396a:	684080e7          	jalr	1668(ra) # 80000fea <release>
      acquiresleep(&b->lock);
    8000396e:	01048513          	addi	a0,s1,16
    80003972:	00001097          	auipc	ra,0x1
    80003976:	492080e7          	jalr	1170(ra) # 80004e04 <acquiresleep>
      return b;
    8000397a:	a8b9                	j	800039d8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000397c:	00026497          	auipc	s1,0x26
    80003980:	1644b483          	ld	s1,356(s1) # 80029ae0 <bcache+0x82b0>
    80003984:	00026797          	auipc	a5,0x26
    80003988:	11478793          	addi	a5,a5,276 # 80029a98 <bcache+0x8268>
    8000398c:	00f48863          	beq	s1,a5,8000399c <bread+0x90>
    80003990:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003992:	40bc                	lw	a5,64(s1)
    80003994:	cf81                	beqz	a5,800039ac <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003996:	64a4                	ld	s1,72(s1)
    80003998:	fee49de3          	bne	s1,a4,80003992 <bread+0x86>
  panic("bget: no buffers");
    8000399c:	00005517          	auipc	a0,0x5
    800039a0:	c0450513          	addi	a0,a0,-1020 # 800085a0 <__func__.1+0x598>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	bbc080e7          	jalr	-1092(ra) # 80000560 <panic>
      b->dev = dev;
    800039ac:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800039b0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800039b4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800039b8:	4785                	li	a5,1
    800039ba:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800039bc:	0001e517          	auipc	a0,0x1e
    800039c0:	e7450513          	addi	a0,a0,-396 # 80021830 <bcache>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	626080e7          	jalr	1574(ra) # 80000fea <release>
      acquiresleep(&b->lock);
    800039cc:	01048513          	addi	a0,s1,16
    800039d0:	00001097          	auipc	ra,0x1
    800039d4:	434080e7          	jalr	1076(ra) # 80004e04 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800039d8:	409c                	lw	a5,0(s1)
    800039da:	cb89                	beqz	a5,800039ec <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800039dc:	8526                	mv	a0,s1
    800039de:	70a2                	ld	ra,40(sp)
    800039e0:	7402                	ld	s0,32(sp)
    800039e2:	64e2                	ld	s1,24(sp)
    800039e4:	6942                	ld	s2,16(sp)
    800039e6:	69a2                	ld	s3,8(sp)
    800039e8:	6145                	addi	sp,sp,48
    800039ea:	8082                	ret
    virtio_disk_rw(b, 0);
    800039ec:	4581                	li	a1,0
    800039ee:	8526                	mv	a0,s1
    800039f0:	00003097          	auipc	ra,0x3
    800039f4:	0f8080e7          	jalr	248(ra) # 80006ae8 <virtio_disk_rw>
    b->valid = 1;
    800039f8:	4785                	li	a5,1
    800039fa:	c09c                	sw	a5,0(s1)
  return b;
    800039fc:	b7c5                	j	800039dc <bread+0xd0>

00000000800039fe <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800039fe:	1101                	addi	sp,sp,-32
    80003a00:	ec06                	sd	ra,24(sp)
    80003a02:	e822                	sd	s0,16(sp)
    80003a04:	e426                	sd	s1,8(sp)
    80003a06:	1000                	addi	s0,sp,32
    80003a08:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003a0a:	0541                	addi	a0,a0,16
    80003a0c:	00001097          	auipc	ra,0x1
    80003a10:	492080e7          	jalr	1170(ra) # 80004e9e <holdingsleep>
    80003a14:	cd01                	beqz	a0,80003a2c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003a16:	4585                	li	a1,1
    80003a18:	8526                	mv	a0,s1
    80003a1a:	00003097          	auipc	ra,0x3
    80003a1e:	0ce080e7          	jalr	206(ra) # 80006ae8 <virtio_disk_rw>
}
    80003a22:	60e2                	ld	ra,24(sp)
    80003a24:	6442                	ld	s0,16(sp)
    80003a26:	64a2                	ld	s1,8(sp)
    80003a28:	6105                	addi	sp,sp,32
    80003a2a:	8082                	ret
    panic("bwrite");
    80003a2c:	00005517          	auipc	a0,0x5
    80003a30:	b8c50513          	addi	a0,a0,-1140 # 800085b8 <__func__.1+0x5b0>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	b2c080e7          	jalr	-1236(ra) # 80000560 <panic>

0000000080003a3c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003a3c:	1101                	addi	sp,sp,-32
    80003a3e:	ec06                	sd	ra,24(sp)
    80003a40:	e822                	sd	s0,16(sp)
    80003a42:	e426                	sd	s1,8(sp)
    80003a44:	e04a                	sd	s2,0(sp)
    80003a46:	1000                	addi	s0,sp,32
    80003a48:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003a4a:	01050913          	addi	s2,a0,16
    80003a4e:	854a                	mv	a0,s2
    80003a50:	00001097          	auipc	ra,0x1
    80003a54:	44e080e7          	jalr	1102(ra) # 80004e9e <holdingsleep>
    80003a58:	c925                	beqz	a0,80003ac8 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003a5a:	854a                	mv	a0,s2
    80003a5c:	00001097          	auipc	ra,0x1
    80003a60:	3fe080e7          	jalr	1022(ra) # 80004e5a <releasesleep>

  acquire(&bcache.lock);
    80003a64:	0001e517          	auipc	a0,0x1e
    80003a68:	dcc50513          	addi	a0,a0,-564 # 80021830 <bcache>
    80003a6c:	ffffd097          	auipc	ra,0xffffd
    80003a70:	4ca080e7          	jalr	1226(ra) # 80000f36 <acquire>
  b->refcnt--;
    80003a74:	40bc                	lw	a5,64(s1)
    80003a76:	37fd                	addiw	a5,a5,-1
    80003a78:	0007871b          	sext.w	a4,a5
    80003a7c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003a7e:	e71d                	bnez	a4,80003aac <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003a80:	68b8                	ld	a4,80(s1)
    80003a82:	64bc                	ld	a5,72(s1)
    80003a84:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003a86:	68b8                	ld	a4,80(s1)
    80003a88:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a8a:	00026797          	auipc	a5,0x26
    80003a8e:	da678793          	addi	a5,a5,-602 # 80029830 <bcache+0x8000>
    80003a92:	2b87b703          	ld	a4,696(a5)
    80003a96:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a98:	00026717          	auipc	a4,0x26
    80003a9c:	00070713          	mv	a4,a4
    80003aa0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003aa2:	2b87b703          	ld	a4,696(a5)
    80003aa6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003aa8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003aac:	0001e517          	auipc	a0,0x1e
    80003ab0:	d8450513          	addi	a0,a0,-636 # 80021830 <bcache>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	536080e7          	jalr	1334(ra) # 80000fea <release>
}
    80003abc:	60e2                	ld	ra,24(sp)
    80003abe:	6442                	ld	s0,16(sp)
    80003ac0:	64a2                	ld	s1,8(sp)
    80003ac2:	6902                	ld	s2,0(sp)
    80003ac4:	6105                	addi	sp,sp,32
    80003ac6:	8082                	ret
    panic("brelse");
    80003ac8:	00005517          	auipc	a0,0x5
    80003acc:	af850513          	addi	a0,a0,-1288 # 800085c0 <__func__.1+0x5b8>
    80003ad0:	ffffd097          	auipc	ra,0xffffd
    80003ad4:	a90080e7          	jalr	-1392(ra) # 80000560 <panic>

0000000080003ad8 <bpin>:

void
bpin(struct buf *b) {
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	1000                	addi	s0,sp,32
    80003ae2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003ae4:	0001e517          	auipc	a0,0x1e
    80003ae8:	d4c50513          	addi	a0,a0,-692 # 80021830 <bcache>
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	44a080e7          	jalr	1098(ra) # 80000f36 <acquire>
  b->refcnt++;
    80003af4:	40bc                	lw	a5,64(s1)
    80003af6:	2785                	addiw	a5,a5,1
    80003af8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003afa:	0001e517          	auipc	a0,0x1e
    80003afe:	d3650513          	addi	a0,a0,-714 # 80021830 <bcache>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	4e8080e7          	jalr	1256(ra) # 80000fea <release>
}
    80003b0a:	60e2                	ld	ra,24(sp)
    80003b0c:	6442                	ld	s0,16(sp)
    80003b0e:	64a2                	ld	s1,8(sp)
    80003b10:	6105                	addi	sp,sp,32
    80003b12:	8082                	ret

0000000080003b14 <bunpin>:

void
bunpin(struct buf *b) {
    80003b14:	1101                	addi	sp,sp,-32
    80003b16:	ec06                	sd	ra,24(sp)
    80003b18:	e822                	sd	s0,16(sp)
    80003b1a:	e426                	sd	s1,8(sp)
    80003b1c:	1000                	addi	s0,sp,32
    80003b1e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b20:	0001e517          	auipc	a0,0x1e
    80003b24:	d1050513          	addi	a0,a0,-752 # 80021830 <bcache>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	40e080e7          	jalr	1038(ra) # 80000f36 <acquire>
  b->refcnt--;
    80003b30:	40bc                	lw	a5,64(s1)
    80003b32:	37fd                	addiw	a5,a5,-1
    80003b34:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003b36:	0001e517          	auipc	a0,0x1e
    80003b3a:	cfa50513          	addi	a0,a0,-774 # 80021830 <bcache>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	4ac080e7          	jalr	1196(ra) # 80000fea <release>
}
    80003b46:	60e2                	ld	ra,24(sp)
    80003b48:	6442                	ld	s0,16(sp)
    80003b4a:	64a2                	ld	s1,8(sp)
    80003b4c:	6105                	addi	sp,sp,32
    80003b4e:	8082                	ret

0000000080003b50 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003b50:	1101                	addi	sp,sp,-32
    80003b52:	ec06                	sd	ra,24(sp)
    80003b54:	e822                	sd	s0,16(sp)
    80003b56:	e426                	sd	s1,8(sp)
    80003b58:	e04a                	sd	s2,0(sp)
    80003b5a:	1000                	addi	s0,sp,32
    80003b5c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003b5e:	00d5d59b          	srliw	a1,a1,0xd
    80003b62:	00026797          	auipc	a5,0x26
    80003b66:	3aa7a783          	lw	a5,938(a5) # 80029f0c <sb+0x1c>
    80003b6a:	9dbd                	addw	a1,a1,a5
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	da0080e7          	jalr	-608(ra) # 8000390c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003b74:	0074f713          	andi	a4,s1,7
    80003b78:	4785                	li	a5,1
    80003b7a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003b7e:	14ce                	slli	s1,s1,0x33
    80003b80:	90d9                	srli	s1,s1,0x36
    80003b82:	00950733          	add	a4,a0,s1
    80003b86:	05874703          	lbu	a4,88(a4) # 80029af0 <bcache+0x82c0>
    80003b8a:	00e7f6b3          	and	a3,a5,a4
    80003b8e:	c69d                	beqz	a3,80003bbc <bfree+0x6c>
    80003b90:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b92:	94aa                	add	s1,s1,a0
    80003b94:	fff7c793          	not	a5,a5
    80003b98:	8f7d                	and	a4,a4,a5
    80003b9a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003b9e:	00001097          	auipc	ra,0x1
    80003ba2:	148080e7          	jalr	328(ra) # 80004ce6 <log_write>
  brelse(bp);
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	e94080e7          	jalr	-364(ra) # 80003a3c <brelse>
}
    80003bb0:	60e2                	ld	ra,24(sp)
    80003bb2:	6442                	ld	s0,16(sp)
    80003bb4:	64a2                	ld	s1,8(sp)
    80003bb6:	6902                	ld	s2,0(sp)
    80003bb8:	6105                	addi	sp,sp,32
    80003bba:	8082                	ret
    panic("freeing free block");
    80003bbc:	00005517          	auipc	a0,0x5
    80003bc0:	a0c50513          	addi	a0,a0,-1524 # 800085c8 <__func__.1+0x5c0>
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	99c080e7          	jalr	-1636(ra) # 80000560 <panic>

0000000080003bcc <balloc>:
{
    80003bcc:	711d                	addi	sp,sp,-96
    80003bce:	ec86                	sd	ra,88(sp)
    80003bd0:	e8a2                	sd	s0,80(sp)
    80003bd2:	e4a6                	sd	s1,72(sp)
    80003bd4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003bd6:	00026797          	auipc	a5,0x26
    80003bda:	31e7a783          	lw	a5,798(a5) # 80029ef4 <sb+0x4>
    80003bde:	10078f63          	beqz	a5,80003cfc <balloc+0x130>
    80003be2:	e0ca                	sd	s2,64(sp)
    80003be4:	fc4e                	sd	s3,56(sp)
    80003be6:	f852                	sd	s4,48(sp)
    80003be8:	f456                	sd	s5,40(sp)
    80003bea:	f05a                	sd	s6,32(sp)
    80003bec:	ec5e                	sd	s7,24(sp)
    80003bee:	e862                	sd	s8,16(sp)
    80003bf0:	e466                	sd	s9,8(sp)
    80003bf2:	8baa                	mv	s7,a0
    80003bf4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003bf6:	00026b17          	auipc	s6,0x26
    80003bfa:	2fab0b13          	addi	s6,s6,762 # 80029ef0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bfe:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003c00:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c02:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003c04:	6c89                	lui	s9,0x2
    80003c06:	a061                	j	80003c8e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003c08:	97ca                	add	a5,a5,s2
    80003c0a:	8e55                	or	a2,a2,a3
    80003c0c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003c10:	854a                	mv	a0,s2
    80003c12:	00001097          	auipc	ra,0x1
    80003c16:	0d4080e7          	jalr	212(ra) # 80004ce6 <log_write>
        brelse(bp);
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	e20080e7          	jalr	-480(ra) # 80003a3c <brelse>
  bp = bread(dev, bno);
    80003c24:	85a6                	mv	a1,s1
    80003c26:	855e                	mv	a0,s7
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	ce4080e7          	jalr	-796(ra) # 8000390c <bread>
    80003c30:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003c32:	40000613          	li	a2,1024
    80003c36:	4581                	li	a1,0
    80003c38:	05850513          	addi	a0,a0,88
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	3f6080e7          	jalr	1014(ra) # 80001032 <memset>
  log_write(bp);
    80003c44:	854a                	mv	a0,s2
    80003c46:	00001097          	auipc	ra,0x1
    80003c4a:	0a0080e7          	jalr	160(ra) # 80004ce6 <log_write>
  brelse(bp);
    80003c4e:	854a                	mv	a0,s2
    80003c50:	00000097          	auipc	ra,0x0
    80003c54:	dec080e7          	jalr	-532(ra) # 80003a3c <brelse>
}
    80003c58:	6906                	ld	s2,64(sp)
    80003c5a:	79e2                	ld	s3,56(sp)
    80003c5c:	7a42                	ld	s4,48(sp)
    80003c5e:	7aa2                	ld	s5,40(sp)
    80003c60:	7b02                	ld	s6,32(sp)
    80003c62:	6be2                	ld	s7,24(sp)
    80003c64:	6c42                	ld	s8,16(sp)
    80003c66:	6ca2                	ld	s9,8(sp)
}
    80003c68:	8526                	mv	a0,s1
    80003c6a:	60e6                	ld	ra,88(sp)
    80003c6c:	6446                	ld	s0,80(sp)
    80003c6e:	64a6                	ld	s1,72(sp)
    80003c70:	6125                	addi	sp,sp,96
    80003c72:	8082                	ret
    brelse(bp);
    80003c74:	854a                	mv	a0,s2
    80003c76:	00000097          	auipc	ra,0x0
    80003c7a:	dc6080e7          	jalr	-570(ra) # 80003a3c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003c7e:	015c87bb          	addw	a5,s9,s5
    80003c82:	00078a9b          	sext.w	s5,a5
    80003c86:	004b2703          	lw	a4,4(s6)
    80003c8a:	06eaf163          	bgeu	s5,a4,80003cec <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003c8e:	41fad79b          	sraiw	a5,s5,0x1f
    80003c92:	0137d79b          	srliw	a5,a5,0x13
    80003c96:	015787bb          	addw	a5,a5,s5
    80003c9a:	40d7d79b          	sraiw	a5,a5,0xd
    80003c9e:	01cb2583          	lw	a1,28(s6)
    80003ca2:	9dbd                	addw	a1,a1,a5
    80003ca4:	855e                	mv	a0,s7
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	c66080e7          	jalr	-922(ra) # 8000390c <bread>
    80003cae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003cb0:	004b2503          	lw	a0,4(s6)
    80003cb4:	000a849b          	sext.w	s1,s5
    80003cb8:	8762                	mv	a4,s8
    80003cba:	faa4fde3          	bgeu	s1,a0,80003c74 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003cbe:	00777693          	andi	a3,a4,7
    80003cc2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003cc6:	41f7579b          	sraiw	a5,a4,0x1f
    80003cca:	01d7d79b          	srliw	a5,a5,0x1d
    80003cce:	9fb9                	addw	a5,a5,a4
    80003cd0:	4037d79b          	sraiw	a5,a5,0x3
    80003cd4:	00f90633          	add	a2,s2,a5
    80003cd8:	05864603          	lbu	a2,88(a2)
    80003cdc:	00c6f5b3          	and	a1,a3,a2
    80003ce0:	d585                	beqz	a1,80003c08 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ce2:	2705                	addiw	a4,a4,1
    80003ce4:	2485                	addiw	s1,s1,1
    80003ce6:	fd471ae3          	bne	a4,s4,80003cba <balloc+0xee>
    80003cea:	b769                	j	80003c74 <balloc+0xa8>
    80003cec:	6906                	ld	s2,64(sp)
    80003cee:	79e2                	ld	s3,56(sp)
    80003cf0:	7a42                	ld	s4,48(sp)
    80003cf2:	7aa2                	ld	s5,40(sp)
    80003cf4:	7b02                	ld	s6,32(sp)
    80003cf6:	6be2                	ld	s7,24(sp)
    80003cf8:	6c42                	ld	s8,16(sp)
    80003cfa:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003cfc:	00005517          	auipc	a0,0x5
    80003d00:	8e450513          	addi	a0,a0,-1820 # 800085e0 <__func__.1+0x5d8>
    80003d04:	ffffd097          	auipc	ra,0xffffd
    80003d08:	8b8080e7          	jalr	-1864(ra) # 800005bc <printf>
  return 0;
    80003d0c:	4481                	li	s1,0
    80003d0e:	bfa9                	j	80003c68 <balloc+0x9c>

0000000080003d10 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003d10:	7179                	addi	sp,sp,-48
    80003d12:	f406                	sd	ra,40(sp)
    80003d14:	f022                	sd	s0,32(sp)
    80003d16:	ec26                	sd	s1,24(sp)
    80003d18:	e84a                	sd	s2,16(sp)
    80003d1a:	e44e                	sd	s3,8(sp)
    80003d1c:	1800                	addi	s0,sp,48
    80003d1e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003d20:	47ad                	li	a5,11
    80003d22:	02b7e863          	bltu	a5,a1,80003d52 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003d26:	02059793          	slli	a5,a1,0x20
    80003d2a:	01e7d593          	srli	a1,a5,0x1e
    80003d2e:	00b504b3          	add	s1,a0,a1
    80003d32:	0504a903          	lw	s2,80(s1)
    80003d36:	08091263          	bnez	s2,80003dba <bmap+0xaa>
      addr = balloc(ip->dev);
    80003d3a:	4108                	lw	a0,0(a0)
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	e90080e7          	jalr	-368(ra) # 80003bcc <balloc>
    80003d44:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003d48:	06090963          	beqz	s2,80003dba <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003d4c:	0524a823          	sw	s2,80(s1)
    80003d50:	a0ad                	j	80003dba <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003d52:	ff45849b          	addiw	s1,a1,-12
    80003d56:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003d5a:	0ff00793          	li	a5,255
    80003d5e:	08e7e863          	bltu	a5,a4,80003dee <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003d62:	08052903          	lw	s2,128(a0)
    80003d66:	00091f63          	bnez	s2,80003d84 <bmap+0x74>
      addr = balloc(ip->dev);
    80003d6a:	4108                	lw	a0,0(a0)
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	e60080e7          	jalr	-416(ra) # 80003bcc <balloc>
    80003d74:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003d78:	04090163          	beqz	s2,80003dba <bmap+0xaa>
    80003d7c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003d7e:	0929a023          	sw	s2,128(s3)
    80003d82:	a011                	j	80003d86 <bmap+0x76>
    80003d84:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003d86:	85ca                	mv	a1,s2
    80003d88:	0009a503          	lw	a0,0(s3)
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	b80080e7          	jalr	-1152(ra) # 8000390c <bread>
    80003d94:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003d96:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003d9a:	02049713          	slli	a4,s1,0x20
    80003d9e:	01e75593          	srli	a1,a4,0x1e
    80003da2:	00b784b3          	add	s1,a5,a1
    80003da6:	0004a903          	lw	s2,0(s1)
    80003daa:	02090063          	beqz	s2,80003dca <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003dae:	8552                	mv	a0,s4
    80003db0:	00000097          	auipc	ra,0x0
    80003db4:	c8c080e7          	jalr	-884(ra) # 80003a3c <brelse>
    return addr;
    80003db8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003dba:	854a                	mv	a0,s2
    80003dbc:	70a2                	ld	ra,40(sp)
    80003dbe:	7402                	ld	s0,32(sp)
    80003dc0:	64e2                	ld	s1,24(sp)
    80003dc2:	6942                	ld	s2,16(sp)
    80003dc4:	69a2                	ld	s3,8(sp)
    80003dc6:	6145                	addi	sp,sp,48
    80003dc8:	8082                	ret
      addr = balloc(ip->dev);
    80003dca:	0009a503          	lw	a0,0(s3)
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	dfe080e7          	jalr	-514(ra) # 80003bcc <balloc>
    80003dd6:	0005091b          	sext.w	s2,a0
      if(addr){
    80003dda:	fc090ae3          	beqz	s2,80003dae <bmap+0x9e>
        a[bn] = addr;
    80003dde:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003de2:	8552                	mv	a0,s4
    80003de4:	00001097          	auipc	ra,0x1
    80003de8:	f02080e7          	jalr	-254(ra) # 80004ce6 <log_write>
    80003dec:	b7c9                	j	80003dae <bmap+0x9e>
    80003dee:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003df0:	00005517          	auipc	a0,0x5
    80003df4:	80850513          	addi	a0,a0,-2040 # 800085f8 <__func__.1+0x5f0>
    80003df8:	ffffc097          	auipc	ra,0xffffc
    80003dfc:	768080e7          	jalr	1896(ra) # 80000560 <panic>

0000000080003e00 <iget>:
{
    80003e00:	7179                	addi	sp,sp,-48
    80003e02:	f406                	sd	ra,40(sp)
    80003e04:	f022                	sd	s0,32(sp)
    80003e06:	ec26                	sd	s1,24(sp)
    80003e08:	e84a                	sd	s2,16(sp)
    80003e0a:	e44e                	sd	s3,8(sp)
    80003e0c:	e052                	sd	s4,0(sp)
    80003e0e:	1800                	addi	s0,sp,48
    80003e10:	89aa                	mv	s3,a0
    80003e12:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003e14:	00026517          	auipc	a0,0x26
    80003e18:	0fc50513          	addi	a0,a0,252 # 80029f10 <itable>
    80003e1c:	ffffd097          	auipc	ra,0xffffd
    80003e20:	11a080e7          	jalr	282(ra) # 80000f36 <acquire>
  empty = 0;
    80003e24:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e26:	00026497          	auipc	s1,0x26
    80003e2a:	10248493          	addi	s1,s1,258 # 80029f28 <itable+0x18>
    80003e2e:	00028697          	auipc	a3,0x28
    80003e32:	b8a68693          	addi	a3,a3,-1142 # 8002b9b8 <log>
    80003e36:	a039                	j	80003e44 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e38:	02090b63          	beqz	s2,80003e6e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e3c:	08848493          	addi	s1,s1,136
    80003e40:	02d48a63          	beq	s1,a3,80003e74 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003e44:	449c                	lw	a5,8(s1)
    80003e46:	fef059e3          	blez	a5,80003e38 <iget+0x38>
    80003e4a:	4098                	lw	a4,0(s1)
    80003e4c:	ff3716e3          	bne	a4,s3,80003e38 <iget+0x38>
    80003e50:	40d8                	lw	a4,4(s1)
    80003e52:	ff4713e3          	bne	a4,s4,80003e38 <iget+0x38>
      ip->ref++;
    80003e56:	2785                	addiw	a5,a5,1
    80003e58:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003e5a:	00026517          	auipc	a0,0x26
    80003e5e:	0b650513          	addi	a0,a0,182 # 80029f10 <itable>
    80003e62:	ffffd097          	auipc	ra,0xffffd
    80003e66:	188080e7          	jalr	392(ra) # 80000fea <release>
      return ip;
    80003e6a:	8926                	mv	s2,s1
    80003e6c:	a03d                	j	80003e9a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e6e:	f7f9                	bnez	a5,80003e3c <iget+0x3c>
      empty = ip;
    80003e70:	8926                	mv	s2,s1
    80003e72:	b7e9                	j	80003e3c <iget+0x3c>
  if(empty == 0)
    80003e74:	02090c63          	beqz	s2,80003eac <iget+0xac>
  ip->dev = dev;
    80003e78:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003e7c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003e80:	4785                	li	a5,1
    80003e82:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003e86:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003e8a:	00026517          	auipc	a0,0x26
    80003e8e:	08650513          	addi	a0,a0,134 # 80029f10 <itable>
    80003e92:	ffffd097          	auipc	ra,0xffffd
    80003e96:	158080e7          	jalr	344(ra) # 80000fea <release>
}
    80003e9a:	854a                	mv	a0,s2
    80003e9c:	70a2                	ld	ra,40(sp)
    80003e9e:	7402                	ld	s0,32(sp)
    80003ea0:	64e2                	ld	s1,24(sp)
    80003ea2:	6942                	ld	s2,16(sp)
    80003ea4:	69a2                	ld	s3,8(sp)
    80003ea6:	6a02                	ld	s4,0(sp)
    80003ea8:	6145                	addi	sp,sp,48
    80003eaa:	8082                	ret
    panic("iget: no inodes");
    80003eac:	00004517          	auipc	a0,0x4
    80003eb0:	76450513          	addi	a0,a0,1892 # 80008610 <__func__.1+0x608>
    80003eb4:	ffffc097          	auipc	ra,0xffffc
    80003eb8:	6ac080e7          	jalr	1708(ra) # 80000560 <panic>

0000000080003ebc <fsinit>:
fsinit(int dev) {
    80003ebc:	7179                	addi	sp,sp,-48
    80003ebe:	f406                	sd	ra,40(sp)
    80003ec0:	f022                	sd	s0,32(sp)
    80003ec2:	ec26                	sd	s1,24(sp)
    80003ec4:	e84a                	sd	s2,16(sp)
    80003ec6:	e44e                	sd	s3,8(sp)
    80003ec8:	1800                	addi	s0,sp,48
    80003eca:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003ecc:	4585                	li	a1,1
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	a3e080e7          	jalr	-1474(ra) # 8000390c <bread>
    80003ed6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ed8:	00026997          	auipc	s3,0x26
    80003edc:	01898993          	addi	s3,s3,24 # 80029ef0 <sb>
    80003ee0:	02000613          	li	a2,32
    80003ee4:	05850593          	addi	a1,a0,88
    80003ee8:	854e                	mv	a0,s3
    80003eea:	ffffd097          	auipc	ra,0xffffd
    80003eee:	1a4080e7          	jalr	420(ra) # 8000108e <memmove>
  brelse(bp);
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	b48080e7          	jalr	-1208(ra) # 80003a3c <brelse>
  if(sb.magic != FSMAGIC)
    80003efc:	0009a703          	lw	a4,0(s3)
    80003f00:	102037b7          	lui	a5,0x10203
    80003f04:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003f08:	02f71263          	bne	a4,a5,80003f2c <fsinit+0x70>
  initlog(dev, &sb);
    80003f0c:	00026597          	auipc	a1,0x26
    80003f10:	fe458593          	addi	a1,a1,-28 # 80029ef0 <sb>
    80003f14:	854a                	mv	a0,s2
    80003f16:	00001097          	auipc	ra,0x1
    80003f1a:	b60080e7          	jalr	-1184(ra) # 80004a76 <initlog>
}
    80003f1e:	70a2                	ld	ra,40(sp)
    80003f20:	7402                	ld	s0,32(sp)
    80003f22:	64e2                	ld	s1,24(sp)
    80003f24:	6942                	ld	s2,16(sp)
    80003f26:	69a2                	ld	s3,8(sp)
    80003f28:	6145                	addi	sp,sp,48
    80003f2a:	8082                	ret
    panic("invalid file system");
    80003f2c:	00004517          	auipc	a0,0x4
    80003f30:	6f450513          	addi	a0,a0,1780 # 80008620 <__func__.1+0x618>
    80003f34:	ffffc097          	auipc	ra,0xffffc
    80003f38:	62c080e7          	jalr	1580(ra) # 80000560 <panic>

0000000080003f3c <iinit>:
{
    80003f3c:	7179                	addi	sp,sp,-48
    80003f3e:	f406                	sd	ra,40(sp)
    80003f40:	f022                	sd	s0,32(sp)
    80003f42:	ec26                	sd	s1,24(sp)
    80003f44:	e84a                	sd	s2,16(sp)
    80003f46:	e44e                	sd	s3,8(sp)
    80003f48:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003f4a:	00004597          	auipc	a1,0x4
    80003f4e:	6ee58593          	addi	a1,a1,1774 # 80008638 <__func__.1+0x630>
    80003f52:	00026517          	auipc	a0,0x26
    80003f56:	fbe50513          	addi	a0,a0,-66 # 80029f10 <itable>
    80003f5a:	ffffd097          	auipc	ra,0xffffd
    80003f5e:	f4c080e7          	jalr	-180(ra) # 80000ea6 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003f62:	00026497          	auipc	s1,0x26
    80003f66:	fd648493          	addi	s1,s1,-42 # 80029f38 <itable+0x28>
    80003f6a:	00028997          	auipc	s3,0x28
    80003f6e:	a5e98993          	addi	s3,s3,-1442 # 8002b9c8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003f72:	00004917          	auipc	s2,0x4
    80003f76:	6ce90913          	addi	s2,s2,1742 # 80008640 <__func__.1+0x638>
    80003f7a:	85ca                	mv	a1,s2
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	00001097          	auipc	ra,0x1
    80003f82:	e4c080e7          	jalr	-436(ra) # 80004dca <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003f86:	08848493          	addi	s1,s1,136
    80003f8a:	ff3498e3          	bne	s1,s3,80003f7a <iinit+0x3e>
}
    80003f8e:	70a2                	ld	ra,40(sp)
    80003f90:	7402                	ld	s0,32(sp)
    80003f92:	64e2                	ld	s1,24(sp)
    80003f94:	6942                	ld	s2,16(sp)
    80003f96:	69a2                	ld	s3,8(sp)
    80003f98:	6145                	addi	sp,sp,48
    80003f9a:	8082                	ret

0000000080003f9c <ialloc>:
{
    80003f9c:	7139                	addi	sp,sp,-64
    80003f9e:	fc06                	sd	ra,56(sp)
    80003fa0:	f822                	sd	s0,48(sp)
    80003fa2:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003fa4:	00026717          	auipc	a4,0x26
    80003fa8:	f5872703          	lw	a4,-168(a4) # 80029efc <sb+0xc>
    80003fac:	4785                	li	a5,1
    80003fae:	06e7f463          	bgeu	a5,a4,80004016 <ialloc+0x7a>
    80003fb2:	f426                	sd	s1,40(sp)
    80003fb4:	f04a                	sd	s2,32(sp)
    80003fb6:	ec4e                	sd	s3,24(sp)
    80003fb8:	e852                	sd	s4,16(sp)
    80003fba:	e456                	sd	s5,8(sp)
    80003fbc:	e05a                	sd	s6,0(sp)
    80003fbe:	8aaa                	mv	s5,a0
    80003fc0:	8b2e                	mv	s6,a1
    80003fc2:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003fc4:	00026a17          	auipc	s4,0x26
    80003fc8:	f2ca0a13          	addi	s4,s4,-212 # 80029ef0 <sb>
    80003fcc:	00495593          	srli	a1,s2,0x4
    80003fd0:	018a2783          	lw	a5,24(s4)
    80003fd4:	9dbd                	addw	a1,a1,a5
    80003fd6:	8556                	mv	a0,s5
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	934080e7          	jalr	-1740(ra) # 8000390c <bread>
    80003fe0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003fe2:	05850993          	addi	s3,a0,88
    80003fe6:	00f97793          	andi	a5,s2,15
    80003fea:	079a                	slli	a5,a5,0x6
    80003fec:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003fee:	00099783          	lh	a5,0(s3)
    80003ff2:	cf9d                	beqz	a5,80004030 <ialloc+0x94>
    brelse(bp);
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	a48080e7          	jalr	-1464(ra) # 80003a3c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ffc:	0905                	addi	s2,s2,1
    80003ffe:	00ca2703          	lw	a4,12(s4)
    80004002:	0009079b          	sext.w	a5,s2
    80004006:	fce7e3e3          	bltu	a5,a4,80003fcc <ialloc+0x30>
    8000400a:	74a2                	ld	s1,40(sp)
    8000400c:	7902                	ld	s2,32(sp)
    8000400e:	69e2                	ld	s3,24(sp)
    80004010:	6a42                	ld	s4,16(sp)
    80004012:	6aa2                	ld	s5,8(sp)
    80004014:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80004016:	00004517          	auipc	a0,0x4
    8000401a:	63250513          	addi	a0,a0,1586 # 80008648 <__func__.1+0x640>
    8000401e:	ffffc097          	auipc	ra,0xffffc
    80004022:	59e080e7          	jalr	1438(ra) # 800005bc <printf>
  return 0;
    80004026:	4501                	li	a0,0
}
    80004028:	70e2                	ld	ra,56(sp)
    8000402a:	7442                	ld	s0,48(sp)
    8000402c:	6121                	addi	sp,sp,64
    8000402e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80004030:	04000613          	li	a2,64
    80004034:	4581                	li	a1,0
    80004036:	854e                	mv	a0,s3
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	ffa080e7          	jalr	-6(ra) # 80001032 <memset>
      dip->type = type;
    80004040:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004044:	8526                	mv	a0,s1
    80004046:	00001097          	auipc	ra,0x1
    8000404a:	ca0080e7          	jalr	-864(ra) # 80004ce6 <log_write>
      brelse(bp);
    8000404e:	8526                	mv	a0,s1
    80004050:	00000097          	auipc	ra,0x0
    80004054:	9ec080e7          	jalr	-1556(ra) # 80003a3c <brelse>
      return iget(dev, inum);
    80004058:	0009059b          	sext.w	a1,s2
    8000405c:	8556                	mv	a0,s5
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	da2080e7          	jalr	-606(ra) # 80003e00 <iget>
    80004066:	74a2                	ld	s1,40(sp)
    80004068:	7902                	ld	s2,32(sp)
    8000406a:	69e2                	ld	s3,24(sp)
    8000406c:	6a42                	ld	s4,16(sp)
    8000406e:	6aa2                	ld	s5,8(sp)
    80004070:	6b02                	ld	s6,0(sp)
    80004072:	bf5d                	j	80004028 <ialloc+0x8c>

0000000080004074 <iupdate>:
{
    80004074:	1101                	addi	sp,sp,-32
    80004076:	ec06                	sd	ra,24(sp)
    80004078:	e822                	sd	s0,16(sp)
    8000407a:	e426                	sd	s1,8(sp)
    8000407c:	e04a                	sd	s2,0(sp)
    8000407e:	1000                	addi	s0,sp,32
    80004080:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004082:	415c                	lw	a5,4(a0)
    80004084:	0047d79b          	srliw	a5,a5,0x4
    80004088:	00026597          	auipc	a1,0x26
    8000408c:	e805a583          	lw	a1,-384(a1) # 80029f08 <sb+0x18>
    80004090:	9dbd                	addw	a1,a1,a5
    80004092:	4108                	lw	a0,0(a0)
    80004094:	00000097          	auipc	ra,0x0
    80004098:	878080e7          	jalr	-1928(ra) # 8000390c <bread>
    8000409c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000409e:	05850793          	addi	a5,a0,88
    800040a2:	40d8                	lw	a4,4(s1)
    800040a4:	8b3d                	andi	a4,a4,15
    800040a6:	071a                	slli	a4,a4,0x6
    800040a8:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800040aa:	04449703          	lh	a4,68(s1)
    800040ae:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800040b2:	04649703          	lh	a4,70(s1)
    800040b6:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800040ba:	04849703          	lh	a4,72(s1)
    800040be:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800040c2:	04a49703          	lh	a4,74(s1)
    800040c6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800040ca:	44f8                	lw	a4,76(s1)
    800040cc:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800040ce:	03400613          	li	a2,52
    800040d2:	05048593          	addi	a1,s1,80
    800040d6:	00c78513          	addi	a0,a5,12
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	fb4080e7          	jalr	-76(ra) # 8000108e <memmove>
  log_write(bp);
    800040e2:	854a                	mv	a0,s2
    800040e4:	00001097          	auipc	ra,0x1
    800040e8:	c02080e7          	jalr	-1022(ra) # 80004ce6 <log_write>
  brelse(bp);
    800040ec:	854a                	mv	a0,s2
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	94e080e7          	jalr	-1714(ra) # 80003a3c <brelse>
}
    800040f6:	60e2                	ld	ra,24(sp)
    800040f8:	6442                	ld	s0,16(sp)
    800040fa:	64a2                	ld	s1,8(sp)
    800040fc:	6902                	ld	s2,0(sp)
    800040fe:	6105                	addi	sp,sp,32
    80004100:	8082                	ret

0000000080004102 <idup>:
{
    80004102:	1101                	addi	sp,sp,-32
    80004104:	ec06                	sd	ra,24(sp)
    80004106:	e822                	sd	s0,16(sp)
    80004108:	e426                	sd	s1,8(sp)
    8000410a:	1000                	addi	s0,sp,32
    8000410c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000410e:	00026517          	auipc	a0,0x26
    80004112:	e0250513          	addi	a0,a0,-510 # 80029f10 <itable>
    80004116:	ffffd097          	auipc	ra,0xffffd
    8000411a:	e20080e7          	jalr	-480(ra) # 80000f36 <acquire>
  ip->ref++;
    8000411e:	449c                	lw	a5,8(s1)
    80004120:	2785                	addiw	a5,a5,1
    80004122:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004124:	00026517          	auipc	a0,0x26
    80004128:	dec50513          	addi	a0,a0,-532 # 80029f10 <itable>
    8000412c:	ffffd097          	auipc	ra,0xffffd
    80004130:	ebe080e7          	jalr	-322(ra) # 80000fea <release>
}
    80004134:	8526                	mv	a0,s1
    80004136:	60e2                	ld	ra,24(sp)
    80004138:	6442                	ld	s0,16(sp)
    8000413a:	64a2                	ld	s1,8(sp)
    8000413c:	6105                	addi	sp,sp,32
    8000413e:	8082                	ret

0000000080004140 <ilock>:
{
    80004140:	1101                	addi	sp,sp,-32
    80004142:	ec06                	sd	ra,24(sp)
    80004144:	e822                	sd	s0,16(sp)
    80004146:	e426                	sd	s1,8(sp)
    80004148:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000414a:	c10d                	beqz	a0,8000416c <ilock+0x2c>
    8000414c:	84aa                	mv	s1,a0
    8000414e:	451c                	lw	a5,8(a0)
    80004150:	00f05e63          	blez	a5,8000416c <ilock+0x2c>
  acquiresleep(&ip->lock);
    80004154:	0541                	addi	a0,a0,16
    80004156:	00001097          	auipc	ra,0x1
    8000415a:	cae080e7          	jalr	-850(ra) # 80004e04 <acquiresleep>
  if(ip->valid == 0){
    8000415e:	40bc                	lw	a5,64(s1)
    80004160:	cf99                	beqz	a5,8000417e <ilock+0x3e>
}
    80004162:	60e2                	ld	ra,24(sp)
    80004164:	6442                	ld	s0,16(sp)
    80004166:	64a2                	ld	s1,8(sp)
    80004168:	6105                	addi	sp,sp,32
    8000416a:	8082                	ret
    8000416c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000416e:	00004517          	auipc	a0,0x4
    80004172:	4f250513          	addi	a0,a0,1266 # 80008660 <__func__.1+0x658>
    80004176:	ffffc097          	auipc	ra,0xffffc
    8000417a:	3ea080e7          	jalr	1002(ra) # 80000560 <panic>
    8000417e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004180:	40dc                	lw	a5,4(s1)
    80004182:	0047d79b          	srliw	a5,a5,0x4
    80004186:	00026597          	auipc	a1,0x26
    8000418a:	d825a583          	lw	a1,-638(a1) # 80029f08 <sb+0x18>
    8000418e:	9dbd                	addw	a1,a1,a5
    80004190:	4088                	lw	a0,0(s1)
    80004192:	fffff097          	auipc	ra,0xfffff
    80004196:	77a080e7          	jalr	1914(ra) # 8000390c <bread>
    8000419a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000419c:	05850593          	addi	a1,a0,88
    800041a0:	40dc                	lw	a5,4(s1)
    800041a2:	8bbd                	andi	a5,a5,15
    800041a4:	079a                	slli	a5,a5,0x6
    800041a6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800041a8:	00059783          	lh	a5,0(a1)
    800041ac:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800041b0:	00259783          	lh	a5,2(a1)
    800041b4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800041b8:	00459783          	lh	a5,4(a1)
    800041bc:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800041c0:	00659783          	lh	a5,6(a1)
    800041c4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800041c8:	459c                	lw	a5,8(a1)
    800041ca:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800041cc:	03400613          	li	a2,52
    800041d0:	05b1                	addi	a1,a1,12
    800041d2:	05048513          	addi	a0,s1,80
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	eb8080e7          	jalr	-328(ra) # 8000108e <memmove>
    brelse(bp);
    800041de:	854a                	mv	a0,s2
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	85c080e7          	jalr	-1956(ra) # 80003a3c <brelse>
    ip->valid = 1;
    800041e8:	4785                	li	a5,1
    800041ea:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800041ec:	04449783          	lh	a5,68(s1)
    800041f0:	c399                	beqz	a5,800041f6 <ilock+0xb6>
    800041f2:	6902                	ld	s2,0(sp)
    800041f4:	b7bd                	j	80004162 <ilock+0x22>
      panic("ilock: no type");
    800041f6:	00004517          	auipc	a0,0x4
    800041fa:	47250513          	addi	a0,a0,1138 # 80008668 <__func__.1+0x660>
    800041fe:	ffffc097          	auipc	ra,0xffffc
    80004202:	362080e7          	jalr	866(ra) # 80000560 <panic>

0000000080004206 <iunlock>:
{
    80004206:	1101                	addi	sp,sp,-32
    80004208:	ec06                	sd	ra,24(sp)
    8000420a:	e822                	sd	s0,16(sp)
    8000420c:	e426                	sd	s1,8(sp)
    8000420e:	e04a                	sd	s2,0(sp)
    80004210:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004212:	c905                	beqz	a0,80004242 <iunlock+0x3c>
    80004214:	84aa                	mv	s1,a0
    80004216:	01050913          	addi	s2,a0,16
    8000421a:	854a                	mv	a0,s2
    8000421c:	00001097          	auipc	ra,0x1
    80004220:	c82080e7          	jalr	-894(ra) # 80004e9e <holdingsleep>
    80004224:	cd19                	beqz	a0,80004242 <iunlock+0x3c>
    80004226:	449c                	lw	a5,8(s1)
    80004228:	00f05d63          	blez	a5,80004242 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000422c:	854a                	mv	a0,s2
    8000422e:	00001097          	auipc	ra,0x1
    80004232:	c2c080e7          	jalr	-980(ra) # 80004e5a <releasesleep>
}
    80004236:	60e2                	ld	ra,24(sp)
    80004238:	6442                	ld	s0,16(sp)
    8000423a:	64a2                	ld	s1,8(sp)
    8000423c:	6902                	ld	s2,0(sp)
    8000423e:	6105                	addi	sp,sp,32
    80004240:	8082                	ret
    panic("iunlock");
    80004242:	00004517          	auipc	a0,0x4
    80004246:	43650513          	addi	a0,a0,1078 # 80008678 <__func__.1+0x670>
    8000424a:	ffffc097          	auipc	ra,0xffffc
    8000424e:	316080e7          	jalr	790(ra) # 80000560 <panic>

0000000080004252 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004252:	7179                	addi	sp,sp,-48
    80004254:	f406                	sd	ra,40(sp)
    80004256:	f022                	sd	s0,32(sp)
    80004258:	ec26                	sd	s1,24(sp)
    8000425a:	e84a                	sd	s2,16(sp)
    8000425c:	e44e                	sd	s3,8(sp)
    8000425e:	1800                	addi	s0,sp,48
    80004260:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004262:	05050493          	addi	s1,a0,80
    80004266:	08050913          	addi	s2,a0,128
    8000426a:	a021                	j	80004272 <itrunc+0x20>
    8000426c:	0491                	addi	s1,s1,4
    8000426e:	01248d63          	beq	s1,s2,80004288 <itrunc+0x36>
    if(ip->addrs[i]){
    80004272:	408c                	lw	a1,0(s1)
    80004274:	dde5                	beqz	a1,8000426c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004276:	0009a503          	lw	a0,0(s3)
    8000427a:	00000097          	auipc	ra,0x0
    8000427e:	8d6080e7          	jalr	-1834(ra) # 80003b50 <bfree>
      ip->addrs[i] = 0;
    80004282:	0004a023          	sw	zero,0(s1)
    80004286:	b7dd                	j	8000426c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004288:	0809a583          	lw	a1,128(s3)
    8000428c:	ed99                	bnez	a1,800042aa <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000428e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004292:	854e                	mv	a0,s3
    80004294:	00000097          	auipc	ra,0x0
    80004298:	de0080e7          	jalr	-544(ra) # 80004074 <iupdate>
}
    8000429c:	70a2                	ld	ra,40(sp)
    8000429e:	7402                	ld	s0,32(sp)
    800042a0:	64e2                	ld	s1,24(sp)
    800042a2:	6942                	ld	s2,16(sp)
    800042a4:	69a2                	ld	s3,8(sp)
    800042a6:	6145                	addi	sp,sp,48
    800042a8:	8082                	ret
    800042aa:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800042ac:	0009a503          	lw	a0,0(s3)
    800042b0:	fffff097          	auipc	ra,0xfffff
    800042b4:	65c080e7          	jalr	1628(ra) # 8000390c <bread>
    800042b8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800042ba:	05850493          	addi	s1,a0,88
    800042be:	45850913          	addi	s2,a0,1112
    800042c2:	a021                	j	800042ca <itrunc+0x78>
    800042c4:	0491                	addi	s1,s1,4
    800042c6:	01248b63          	beq	s1,s2,800042dc <itrunc+0x8a>
      if(a[j])
    800042ca:	408c                	lw	a1,0(s1)
    800042cc:	dde5                	beqz	a1,800042c4 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800042ce:	0009a503          	lw	a0,0(s3)
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	87e080e7          	jalr	-1922(ra) # 80003b50 <bfree>
    800042da:	b7ed                	j	800042c4 <itrunc+0x72>
    brelse(bp);
    800042dc:	8552                	mv	a0,s4
    800042de:	fffff097          	auipc	ra,0xfffff
    800042e2:	75e080e7          	jalr	1886(ra) # 80003a3c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800042e6:	0809a583          	lw	a1,128(s3)
    800042ea:	0009a503          	lw	a0,0(s3)
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	862080e7          	jalr	-1950(ra) # 80003b50 <bfree>
    ip->addrs[NDIRECT] = 0;
    800042f6:	0809a023          	sw	zero,128(s3)
    800042fa:	6a02                	ld	s4,0(sp)
    800042fc:	bf49                	j	8000428e <itrunc+0x3c>

00000000800042fe <iput>:
{
    800042fe:	1101                	addi	sp,sp,-32
    80004300:	ec06                	sd	ra,24(sp)
    80004302:	e822                	sd	s0,16(sp)
    80004304:	e426                	sd	s1,8(sp)
    80004306:	1000                	addi	s0,sp,32
    80004308:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000430a:	00026517          	auipc	a0,0x26
    8000430e:	c0650513          	addi	a0,a0,-1018 # 80029f10 <itable>
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	c24080e7          	jalr	-988(ra) # 80000f36 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000431a:	4498                	lw	a4,8(s1)
    8000431c:	4785                	li	a5,1
    8000431e:	02f70263          	beq	a4,a5,80004342 <iput+0x44>
  ip->ref--;
    80004322:	449c                	lw	a5,8(s1)
    80004324:	37fd                	addiw	a5,a5,-1
    80004326:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004328:	00026517          	auipc	a0,0x26
    8000432c:	be850513          	addi	a0,a0,-1048 # 80029f10 <itable>
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	cba080e7          	jalr	-838(ra) # 80000fea <release>
}
    80004338:	60e2                	ld	ra,24(sp)
    8000433a:	6442                	ld	s0,16(sp)
    8000433c:	64a2                	ld	s1,8(sp)
    8000433e:	6105                	addi	sp,sp,32
    80004340:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004342:	40bc                	lw	a5,64(s1)
    80004344:	dff9                	beqz	a5,80004322 <iput+0x24>
    80004346:	04a49783          	lh	a5,74(s1)
    8000434a:	ffe1                	bnez	a5,80004322 <iput+0x24>
    8000434c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000434e:	01048913          	addi	s2,s1,16
    80004352:	854a                	mv	a0,s2
    80004354:	00001097          	auipc	ra,0x1
    80004358:	ab0080e7          	jalr	-1360(ra) # 80004e04 <acquiresleep>
    release(&itable.lock);
    8000435c:	00026517          	auipc	a0,0x26
    80004360:	bb450513          	addi	a0,a0,-1100 # 80029f10 <itable>
    80004364:	ffffd097          	auipc	ra,0xffffd
    80004368:	c86080e7          	jalr	-890(ra) # 80000fea <release>
    itrunc(ip);
    8000436c:	8526                	mv	a0,s1
    8000436e:	00000097          	auipc	ra,0x0
    80004372:	ee4080e7          	jalr	-284(ra) # 80004252 <itrunc>
    ip->type = 0;
    80004376:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000437a:	8526                	mv	a0,s1
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	cf8080e7          	jalr	-776(ra) # 80004074 <iupdate>
    ip->valid = 0;
    80004384:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004388:	854a                	mv	a0,s2
    8000438a:	00001097          	auipc	ra,0x1
    8000438e:	ad0080e7          	jalr	-1328(ra) # 80004e5a <releasesleep>
    acquire(&itable.lock);
    80004392:	00026517          	auipc	a0,0x26
    80004396:	b7e50513          	addi	a0,a0,-1154 # 80029f10 <itable>
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	b9c080e7          	jalr	-1124(ra) # 80000f36 <acquire>
    800043a2:	6902                	ld	s2,0(sp)
    800043a4:	bfbd                	j	80004322 <iput+0x24>

00000000800043a6 <iunlockput>:
{
    800043a6:	1101                	addi	sp,sp,-32
    800043a8:	ec06                	sd	ra,24(sp)
    800043aa:	e822                	sd	s0,16(sp)
    800043ac:	e426                	sd	s1,8(sp)
    800043ae:	1000                	addi	s0,sp,32
    800043b0:	84aa                	mv	s1,a0
  iunlock(ip);
    800043b2:	00000097          	auipc	ra,0x0
    800043b6:	e54080e7          	jalr	-428(ra) # 80004206 <iunlock>
  iput(ip);
    800043ba:	8526                	mv	a0,s1
    800043bc:	00000097          	auipc	ra,0x0
    800043c0:	f42080e7          	jalr	-190(ra) # 800042fe <iput>
}
    800043c4:	60e2                	ld	ra,24(sp)
    800043c6:	6442                	ld	s0,16(sp)
    800043c8:	64a2                	ld	s1,8(sp)
    800043ca:	6105                	addi	sp,sp,32
    800043cc:	8082                	ret

00000000800043ce <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800043ce:	1141                	addi	sp,sp,-16
    800043d0:	e422                	sd	s0,8(sp)
    800043d2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800043d4:	411c                	lw	a5,0(a0)
    800043d6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800043d8:	415c                	lw	a5,4(a0)
    800043da:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800043dc:	04451783          	lh	a5,68(a0)
    800043e0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800043e4:	04a51783          	lh	a5,74(a0)
    800043e8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800043ec:	04c56783          	lwu	a5,76(a0)
    800043f0:	e99c                	sd	a5,16(a1)
}
    800043f2:	6422                	ld	s0,8(sp)
    800043f4:	0141                	addi	sp,sp,16
    800043f6:	8082                	ret

00000000800043f8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800043f8:	457c                	lw	a5,76(a0)
    800043fa:	10d7e563          	bltu	a5,a3,80004504 <readi+0x10c>
{
    800043fe:	7159                	addi	sp,sp,-112
    80004400:	f486                	sd	ra,104(sp)
    80004402:	f0a2                	sd	s0,96(sp)
    80004404:	eca6                	sd	s1,88(sp)
    80004406:	e0d2                	sd	s4,64(sp)
    80004408:	fc56                	sd	s5,56(sp)
    8000440a:	f85a                	sd	s6,48(sp)
    8000440c:	f45e                	sd	s7,40(sp)
    8000440e:	1880                	addi	s0,sp,112
    80004410:	8b2a                	mv	s6,a0
    80004412:	8bae                	mv	s7,a1
    80004414:	8a32                	mv	s4,a2
    80004416:	84b6                	mv	s1,a3
    80004418:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000441a:	9f35                	addw	a4,a4,a3
    return 0;
    8000441c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000441e:	0cd76a63          	bltu	a4,a3,800044f2 <readi+0xfa>
    80004422:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004424:	00e7f463          	bgeu	a5,a4,8000442c <readi+0x34>
    n = ip->size - off;
    80004428:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000442c:	0a0a8963          	beqz	s5,800044de <readi+0xe6>
    80004430:	e8ca                	sd	s2,80(sp)
    80004432:	f062                	sd	s8,32(sp)
    80004434:	ec66                	sd	s9,24(sp)
    80004436:	e86a                	sd	s10,16(sp)
    80004438:	e46e                	sd	s11,8(sp)
    8000443a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000443c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004440:	5c7d                	li	s8,-1
    80004442:	a82d                	j	8000447c <readi+0x84>
    80004444:	020d1d93          	slli	s11,s10,0x20
    80004448:	020ddd93          	srli	s11,s11,0x20
    8000444c:	05890613          	addi	a2,s2,88
    80004450:	86ee                	mv	a3,s11
    80004452:	963a                	add	a2,a2,a4
    80004454:	85d2                	mv	a1,s4
    80004456:	855e                	mv	a0,s7
    80004458:	ffffe097          	auipc	ra,0xffffe
    8000445c:	73a080e7          	jalr	1850(ra) # 80002b92 <either_copyout>
    80004460:	05850d63          	beq	a0,s8,800044ba <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004464:	854a                	mv	a0,s2
    80004466:	fffff097          	auipc	ra,0xfffff
    8000446a:	5d6080e7          	jalr	1494(ra) # 80003a3c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000446e:	013d09bb          	addw	s3,s10,s3
    80004472:	009d04bb          	addw	s1,s10,s1
    80004476:	9a6e                	add	s4,s4,s11
    80004478:	0559fd63          	bgeu	s3,s5,800044d2 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    8000447c:	00a4d59b          	srliw	a1,s1,0xa
    80004480:	855a                	mv	a0,s6
    80004482:	00000097          	auipc	ra,0x0
    80004486:	88e080e7          	jalr	-1906(ra) # 80003d10 <bmap>
    8000448a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000448e:	c9b1                	beqz	a1,800044e2 <readi+0xea>
    bp = bread(ip->dev, addr);
    80004490:	000b2503          	lw	a0,0(s6)
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	478080e7          	jalr	1144(ra) # 8000390c <bread>
    8000449c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000449e:	3ff4f713          	andi	a4,s1,1023
    800044a2:	40ec87bb          	subw	a5,s9,a4
    800044a6:	413a86bb          	subw	a3,s5,s3
    800044aa:	8d3e                	mv	s10,a5
    800044ac:	2781                	sext.w	a5,a5
    800044ae:	0006861b          	sext.w	a2,a3
    800044b2:	f8f679e3          	bgeu	a2,a5,80004444 <readi+0x4c>
    800044b6:	8d36                	mv	s10,a3
    800044b8:	b771                	j	80004444 <readi+0x4c>
      brelse(bp);
    800044ba:	854a                	mv	a0,s2
    800044bc:	fffff097          	auipc	ra,0xfffff
    800044c0:	580080e7          	jalr	1408(ra) # 80003a3c <brelse>
      tot = -1;
    800044c4:	59fd                	li	s3,-1
      break;
    800044c6:	6946                	ld	s2,80(sp)
    800044c8:	7c02                	ld	s8,32(sp)
    800044ca:	6ce2                	ld	s9,24(sp)
    800044cc:	6d42                	ld	s10,16(sp)
    800044ce:	6da2                	ld	s11,8(sp)
    800044d0:	a831                	j	800044ec <readi+0xf4>
    800044d2:	6946                	ld	s2,80(sp)
    800044d4:	7c02                	ld	s8,32(sp)
    800044d6:	6ce2                	ld	s9,24(sp)
    800044d8:	6d42                	ld	s10,16(sp)
    800044da:	6da2                	ld	s11,8(sp)
    800044dc:	a801                	j	800044ec <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044de:	89d6                	mv	s3,s5
    800044e0:	a031                	j	800044ec <readi+0xf4>
    800044e2:	6946                	ld	s2,80(sp)
    800044e4:	7c02                	ld	s8,32(sp)
    800044e6:	6ce2                	ld	s9,24(sp)
    800044e8:	6d42                	ld	s10,16(sp)
    800044ea:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800044ec:	0009851b          	sext.w	a0,s3
    800044f0:	69a6                	ld	s3,72(sp)
}
    800044f2:	70a6                	ld	ra,104(sp)
    800044f4:	7406                	ld	s0,96(sp)
    800044f6:	64e6                	ld	s1,88(sp)
    800044f8:	6a06                	ld	s4,64(sp)
    800044fa:	7ae2                	ld	s5,56(sp)
    800044fc:	7b42                	ld	s6,48(sp)
    800044fe:	7ba2                	ld	s7,40(sp)
    80004500:	6165                	addi	sp,sp,112
    80004502:	8082                	ret
    return 0;
    80004504:	4501                	li	a0,0
}
    80004506:	8082                	ret

0000000080004508 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004508:	457c                	lw	a5,76(a0)
    8000450a:	10d7ee63          	bltu	a5,a3,80004626 <writei+0x11e>
{
    8000450e:	7159                	addi	sp,sp,-112
    80004510:	f486                	sd	ra,104(sp)
    80004512:	f0a2                	sd	s0,96(sp)
    80004514:	e8ca                	sd	s2,80(sp)
    80004516:	e0d2                	sd	s4,64(sp)
    80004518:	fc56                	sd	s5,56(sp)
    8000451a:	f85a                	sd	s6,48(sp)
    8000451c:	f45e                	sd	s7,40(sp)
    8000451e:	1880                	addi	s0,sp,112
    80004520:	8aaa                	mv	s5,a0
    80004522:	8bae                	mv	s7,a1
    80004524:	8a32                	mv	s4,a2
    80004526:	8936                	mv	s2,a3
    80004528:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000452a:	00e687bb          	addw	a5,a3,a4
    8000452e:	0ed7ee63          	bltu	a5,a3,8000462a <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004532:	00043737          	lui	a4,0x43
    80004536:	0ef76c63          	bltu	a4,a5,8000462e <writei+0x126>
    8000453a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000453c:	0c0b0d63          	beqz	s6,80004616 <writei+0x10e>
    80004540:	eca6                	sd	s1,88(sp)
    80004542:	f062                	sd	s8,32(sp)
    80004544:	ec66                	sd	s9,24(sp)
    80004546:	e86a                	sd	s10,16(sp)
    80004548:	e46e                	sd	s11,8(sp)
    8000454a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000454c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004550:	5c7d                	li	s8,-1
    80004552:	a091                	j	80004596 <writei+0x8e>
    80004554:	020d1d93          	slli	s11,s10,0x20
    80004558:	020ddd93          	srli	s11,s11,0x20
    8000455c:	05848513          	addi	a0,s1,88
    80004560:	86ee                	mv	a3,s11
    80004562:	8652                	mv	a2,s4
    80004564:	85de                	mv	a1,s7
    80004566:	953a                	add	a0,a0,a4
    80004568:	ffffe097          	auipc	ra,0xffffe
    8000456c:	680080e7          	jalr	1664(ra) # 80002be8 <either_copyin>
    80004570:	07850263          	beq	a0,s8,800045d4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004574:	8526                	mv	a0,s1
    80004576:	00000097          	auipc	ra,0x0
    8000457a:	770080e7          	jalr	1904(ra) # 80004ce6 <log_write>
    brelse(bp);
    8000457e:	8526                	mv	a0,s1
    80004580:	fffff097          	auipc	ra,0xfffff
    80004584:	4bc080e7          	jalr	1212(ra) # 80003a3c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004588:	013d09bb          	addw	s3,s10,s3
    8000458c:	012d093b          	addw	s2,s10,s2
    80004590:	9a6e                	add	s4,s4,s11
    80004592:	0569f663          	bgeu	s3,s6,800045de <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004596:	00a9559b          	srliw	a1,s2,0xa
    8000459a:	8556                	mv	a0,s5
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	774080e7          	jalr	1908(ra) # 80003d10 <bmap>
    800045a4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800045a8:	c99d                	beqz	a1,800045de <writei+0xd6>
    bp = bread(ip->dev, addr);
    800045aa:	000aa503          	lw	a0,0(s5)
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	35e080e7          	jalr	862(ra) # 8000390c <bread>
    800045b6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800045b8:	3ff97713          	andi	a4,s2,1023
    800045bc:	40ec87bb          	subw	a5,s9,a4
    800045c0:	413b06bb          	subw	a3,s6,s3
    800045c4:	8d3e                	mv	s10,a5
    800045c6:	2781                	sext.w	a5,a5
    800045c8:	0006861b          	sext.w	a2,a3
    800045cc:	f8f674e3          	bgeu	a2,a5,80004554 <writei+0x4c>
    800045d0:	8d36                	mv	s10,a3
    800045d2:	b749                	j	80004554 <writei+0x4c>
      brelse(bp);
    800045d4:	8526                	mv	a0,s1
    800045d6:	fffff097          	auipc	ra,0xfffff
    800045da:	466080e7          	jalr	1126(ra) # 80003a3c <brelse>
  }

  if(off > ip->size)
    800045de:	04caa783          	lw	a5,76(s5)
    800045e2:	0327fc63          	bgeu	a5,s2,8000461a <writei+0x112>
    ip->size = off;
    800045e6:	052aa623          	sw	s2,76(s5)
    800045ea:	64e6                	ld	s1,88(sp)
    800045ec:	7c02                	ld	s8,32(sp)
    800045ee:	6ce2                	ld	s9,24(sp)
    800045f0:	6d42                	ld	s10,16(sp)
    800045f2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800045f4:	8556                	mv	a0,s5
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	a7e080e7          	jalr	-1410(ra) # 80004074 <iupdate>

  return tot;
    800045fe:	0009851b          	sext.w	a0,s3
    80004602:	69a6                	ld	s3,72(sp)
}
    80004604:	70a6                	ld	ra,104(sp)
    80004606:	7406                	ld	s0,96(sp)
    80004608:	6946                	ld	s2,80(sp)
    8000460a:	6a06                	ld	s4,64(sp)
    8000460c:	7ae2                	ld	s5,56(sp)
    8000460e:	7b42                	ld	s6,48(sp)
    80004610:	7ba2                	ld	s7,40(sp)
    80004612:	6165                	addi	sp,sp,112
    80004614:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004616:	89da                	mv	s3,s6
    80004618:	bff1                	j	800045f4 <writei+0xec>
    8000461a:	64e6                	ld	s1,88(sp)
    8000461c:	7c02                	ld	s8,32(sp)
    8000461e:	6ce2                	ld	s9,24(sp)
    80004620:	6d42                	ld	s10,16(sp)
    80004622:	6da2                	ld	s11,8(sp)
    80004624:	bfc1                	j	800045f4 <writei+0xec>
    return -1;
    80004626:	557d                	li	a0,-1
}
    80004628:	8082                	ret
    return -1;
    8000462a:	557d                	li	a0,-1
    8000462c:	bfe1                	j	80004604 <writei+0xfc>
    return -1;
    8000462e:	557d                	li	a0,-1
    80004630:	bfd1                	j	80004604 <writei+0xfc>

0000000080004632 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004632:	1141                	addi	sp,sp,-16
    80004634:	e406                	sd	ra,8(sp)
    80004636:	e022                	sd	s0,0(sp)
    80004638:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000463a:	4639                	li	a2,14
    8000463c:	ffffd097          	auipc	ra,0xffffd
    80004640:	ac6080e7          	jalr	-1338(ra) # 80001102 <strncmp>
}
    80004644:	60a2                	ld	ra,8(sp)
    80004646:	6402                	ld	s0,0(sp)
    80004648:	0141                	addi	sp,sp,16
    8000464a:	8082                	ret

000000008000464c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000464c:	7139                	addi	sp,sp,-64
    8000464e:	fc06                	sd	ra,56(sp)
    80004650:	f822                	sd	s0,48(sp)
    80004652:	f426                	sd	s1,40(sp)
    80004654:	f04a                	sd	s2,32(sp)
    80004656:	ec4e                	sd	s3,24(sp)
    80004658:	e852                	sd	s4,16(sp)
    8000465a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000465c:	04451703          	lh	a4,68(a0)
    80004660:	4785                	li	a5,1
    80004662:	00f71a63          	bne	a4,a5,80004676 <dirlookup+0x2a>
    80004666:	892a                	mv	s2,a0
    80004668:	89ae                	mv	s3,a1
    8000466a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000466c:	457c                	lw	a5,76(a0)
    8000466e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004670:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004672:	e79d                	bnez	a5,800046a0 <dirlookup+0x54>
    80004674:	a8a5                	j	800046ec <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004676:	00004517          	auipc	a0,0x4
    8000467a:	00a50513          	addi	a0,a0,10 # 80008680 <__func__.1+0x678>
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	ee2080e7          	jalr	-286(ra) # 80000560 <panic>
      panic("dirlookup read");
    80004686:	00004517          	auipc	a0,0x4
    8000468a:	01250513          	addi	a0,a0,18 # 80008698 <__func__.1+0x690>
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	ed2080e7          	jalr	-302(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004696:	24c1                	addiw	s1,s1,16
    80004698:	04c92783          	lw	a5,76(s2)
    8000469c:	04f4f763          	bgeu	s1,a5,800046ea <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046a0:	4741                	li	a4,16
    800046a2:	86a6                	mv	a3,s1
    800046a4:	fc040613          	addi	a2,s0,-64
    800046a8:	4581                	li	a1,0
    800046aa:	854a                	mv	a0,s2
    800046ac:	00000097          	auipc	ra,0x0
    800046b0:	d4c080e7          	jalr	-692(ra) # 800043f8 <readi>
    800046b4:	47c1                	li	a5,16
    800046b6:	fcf518e3          	bne	a0,a5,80004686 <dirlookup+0x3a>
    if(de.inum == 0)
    800046ba:	fc045783          	lhu	a5,-64(s0)
    800046be:	dfe1                	beqz	a5,80004696 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800046c0:	fc240593          	addi	a1,s0,-62
    800046c4:	854e                	mv	a0,s3
    800046c6:	00000097          	auipc	ra,0x0
    800046ca:	f6c080e7          	jalr	-148(ra) # 80004632 <namecmp>
    800046ce:	f561                	bnez	a0,80004696 <dirlookup+0x4a>
      if(poff)
    800046d0:	000a0463          	beqz	s4,800046d8 <dirlookup+0x8c>
        *poff = off;
    800046d4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800046d8:	fc045583          	lhu	a1,-64(s0)
    800046dc:	00092503          	lw	a0,0(s2)
    800046e0:	fffff097          	auipc	ra,0xfffff
    800046e4:	720080e7          	jalr	1824(ra) # 80003e00 <iget>
    800046e8:	a011                	j	800046ec <dirlookup+0xa0>
  return 0;
    800046ea:	4501                	li	a0,0
}
    800046ec:	70e2                	ld	ra,56(sp)
    800046ee:	7442                	ld	s0,48(sp)
    800046f0:	74a2                	ld	s1,40(sp)
    800046f2:	7902                	ld	s2,32(sp)
    800046f4:	69e2                	ld	s3,24(sp)
    800046f6:	6a42                	ld	s4,16(sp)
    800046f8:	6121                	addi	sp,sp,64
    800046fa:	8082                	ret

00000000800046fc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800046fc:	711d                	addi	sp,sp,-96
    800046fe:	ec86                	sd	ra,88(sp)
    80004700:	e8a2                	sd	s0,80(sp)
    80004702:	e4a6                	sd	s1,72(sp)
    80004704:	e0ca                	sd	s2,64(sp)
    80004706:	fc4e                	sd	s3,56(sp)
    80004708:	f852                	sd	s4,48(sp)
    8000470a:	f456                	sd	s5,40(sp)
    8000470c:	f05a                	sd	s6,32(sp)
    8000470e:	ec5e                	sd	s7,24(sp)
    80004710:	e862                	sd	s8,16(sp)
    80004712:	e466                	sd	s9,8(sp)
    80004714:	1080                	addi	s0,sp,96
    80004716:	84aa                	mv	s1,a0
    80004718:	8b2e                	mv	s6,a1
    8000471a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000471c:	00054703          	lbu	a4,0(a0)
    80004720:	02f00793          	li	a5,47
    80004724:	02f70263          	beq	a4,a5,80004748 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004728:	ffffe097          	auipc	ra,0xffffe
    8000472c:	8b0080e7          	jalr	-1872(ra) # 80001fd8 <myproc>
    80004730:	15053503          	ld	a0,336(a0)
    80004734:	00000097          	auipc	ra,0x0
    80004738:	9ce080e7          	jalr	-1586(ra) # 80004102 <idup>
    8000473c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000473e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004742:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004744:	4b85                	li	s7,1
    80004746:	a875                	j	80004802 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004748:	4585                	li	a1,1
    8000474a:	4505                	li	a0,1
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	6b4080e7          	jalr	1716(ra) # 80003e00 <iget>
    80004754:	8a2a                	mv	s4,a0
    80004756:	b7e5                	j	8000473e <namex+0x42>
      iunlockput(ip);
    80004758:	8552                	mv	a0,s4
    8000475a:	00000097          	auipc	ra,0x0
    8000475e:	c4c080e7          	jalr	-948(ra) # 800043a6 <iunlockput>
      return 0;
    80004762:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004764:	8552                	mv	a0,s4
    80004766:	60e6                	ld	ra,88(sp)
    80004768:	6446                	ld	s0,80(sp)
    8000476a:	64a6                	ld	s1,72(sp)
    8000476c:	6906                	ld	s2,64(sp)
    8000476e:	79e2                	ld	s3,56(sp)
    80004770:	7a42                	ld	s4,48(sp)
    80004772:	7aa2                	ld	s5,40(sp)
    80004774:	7b02                	ld	s6,32(sp)
    80004776:	6be2                	ld	s7,24(sp)
    80004778:	6c42                	ld	s8,16(sp)
    8000477a:	6ca2                	ld	s9,8(sp)
    8000477c:	6125                	addi	sp,sp,96
    8000477e:	8082                	ret
      iunlock(ip);
    80004780:	8552                	mv	a0,s4
    80004782:	00000097          	auipc	ra,0x0
    80004786:	a84080e7          	jalr	-1404(ra) # 80004206 <iunlock>
      return ip;
    8000478a:	bfe9                	j	80004764 <namex+0x68>
      iunlockput(ip);
    8000478c:	8552                	mv	a0,s4
    8000478e:	00000097          	auipc	ra,0x0
    80004792:	c18080e7          	jalr	-1000(ra) # 800043a6 <iunlockput>
      return 0;
    80004796:	8a4e                	mv	s4,s3
    80004798:	b7f1                	j	80004764 <namex+0x68>
  len = path - s;
    8000479a:	40998633          	sub	a2,s3,s1
    8000479e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800047a2:	099c5863          	bge	s8,s9,80004832 <namex+0x136>
    memmove(name, s, DIRSIZ);
    800047a6:	4639                	li	a2,14
    800047a8:	85a6                	mv	a1,s1
    800047aa:	8556                	mv	a0,s5
    800047ac:	ffffd097          	auipc	ra,0xffffd
    800047b0:	8e2080e7          	jalr	-1822(ra) # 8000108e <memmove>
    800047b4:	84ce                	mv	s1,s3
  while(*path == '/')
    800047b6:	0004c783          	lbu	a5,0(s1)
    800047ba:	01279763          	bne	a5,s2,800047c8 <namex+0xcc>
    path++;
    800047be:	0485                	addi	s1,s1,1
  while(*path == '/')
    800047c0:	0004c783          	lbu	a5,0(s1)
    800047c4:	ff278de3          	beq	a5,s2,800047be <namex+0xc2>
    ilock(ip);
    800047c8:	8552                	mv	a0,s4
    800047ca:	00000097          	auipc	ra,0x0
    800047ce:	976080e7          	jalr	-1674(ra) # 80004140 <ilock>
    if(ip->type != T_DIR){
    800047d2:	044a1783          	lh	a5,68(s4)
    800047d6:	f97791e3          	bne	a5,s7,80004758 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    800047da:	000b0563          	beqz	s6,800047e4 <namex+0xe8>
    800047de:	0004c783          	lbu	a5,0(s1)
    800047e2:	dfd9                	beqz	a5,80004780 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800047e4:	4601                	li	a2,0
    800047e6:	85d6                	mv	a1,s5
    800047e8:	8552                	mv	a0,s4
    800047ea:	00000097          	auipc	ra,0x0
    800047ee:	e62080e7          	jalr	-414(ra) # 8000464c <dirlookup>
    800047f2:	89aa                	mv	s3,a0
    800047f4:	dd41                	beqz	a0,8000478c <namex+0x90>
    iunlockput(ip);
    800047f6:	8552                	mv	a0,s4
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	bae080e7          	jalr	-1106(ra) # 800043a6 <iunlockput>
    ip = next;
    80004800:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004802:	0004c783          	lbu	a5,0(s1)
    80004806:	01279763          	bne	a5,s2,80004814 <namex+0x118>
    path++;
    8000480a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000480c:	0004c783          	lbu	a5,0(s1)
    80004810:	ff278de3          	beq	a5,s2,8000480a <namex+0x10e>
  if(*path == 0)
    80004814:	cb9d                	beqz	a5,8000484a <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004816:	0004c783          	lbu	a5,0(s1)
    8000481a:	89a6                	mv	s3,s1
  len = path - s;
    8000481c:	4c81                	li	s9,0
    8000481e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004820:	01278963          	beq	a5,s2,80004832 <namex+0x136>
    80004824:	dbbd                	beqz	a5,8000479a <namex+0x9e>
    path++;
    80004826:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004828:	0009c783          	lbu	a5,0(s3)
    8000482c:	ff279ce3          	bne	a5,s2,80004824 <namex+0x128>
    80004830:	b7ad                	j	8000479a <namex+0x9e>
    memmove(name, s, len);
    80004832:	2601                	sext.w	a2,a2
    80004834:	85a6                	mv	a1,s1
    80004836:	8556                	mv	a0,s5
    80004838:	ffffd097          	auipc	ra,0xffffd
    8000483c:	856080e7          	jalr	-1962(ra) # 8000108e <memmove>
    name[len] = 0;
    80004840:	9cd6                	add	s9,s9,s5
    80004842:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004846:	84ce                	mv	s1,s3
    80004848:	b7bd                	j	800047b6 <namex+0xba>
  if(nameiparent){
    8000484a:	f00b0de3          	beqz	s6,80004764 <namex+0x68>
    iput(ip);
    8000484e:	8552                	mv	a0,s4
    80004850:	00000097          	auipc	ra,0x0
    80004854:	aae080e7          	jalr	-1362(ra) # 800042fe <iput>
    return 0;
    80004858:	4a01                	li	s4,0
    8000485a:	b729                	j	80004764 <namex+0x68>

000000008000485c <dirlink>:
{
    8000485c:	7139                	addi	sp,sp,-64
    8000485e:	fc06                	sd	ra,56(sp)
    80004860:	f822                	sd	s0,48(sp)
    80004862:	f04a                	sd	s2,32(sp)
    80004864:	ec4e                	sd	s3,24(sp)
    80004866:	e852                	sd	s4,16(sp)
    80004868:	0080                	addi	s0,sp,64
    8000486a:	892a                	mv	s2,a0
    8000486c:	8a2e                	mv	s4,a1
    8000486e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004870:	4601                	li	a2,0
    80004872:	00000097          	auipc	ra,0x0
    80004876:	dda080e7          	jalr	-550(ra) # 8000464c <dirlookup>
    8000487a:	ed25                	bnez	a0,800048f2 <dirlink+0x96>
    8000487c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000487e:	04c92483          	lw	s1,76(s2)
    80004882:	c49d                	beqz	s1,800048b0 <dirlink+0x54>
    80004884:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004886:	4741                	li	a4,16
    80004888:	86a6                	mv	a3,s1
    8000488a:	fc040613          	addi	a2,s0,-64
    8000488e:	4581                	li	a1,0
    80004890:	854a                	mv	a0,s2
    80004892:	00000097          	auipc	ra,0x0
    80004896:	b66080e7          	jalr	-1178(ra) # 800043f8 <readi>
    8000489a:	47c1                	li	a5,16
    8000489c:	06f51163          	bne	a0,a5,800048fe <dirlink+0xa2>
    if(de.inum == 0)
    800048a0:	fc045783          	lhu	a5,-64(s0)
    800048a4:	c791                	beqz	a5,800048b0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800048a6:	24c1                	addiw	s1,s1,16
    800048a8:	04c92783          	lw	a5,76(s2)
    800048ac:	fcf4ede3          	bltu	s1,a5,80004886 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800048b0:	4639                	li	a2,14
    800048b2:	85d2                	mv	a1,s4
    800048b4:	fc240513          	addi	a0,s0,-62
    800048b8:	ffffd097          	auipc	ra,0xffffd
    800048bc:	880080e7          	jalr	-1920(ra) # 80001138 <strncpy>
  de.inum = inum;
    800048c0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048c4:	4741                	li	a4,16
    800048c6:	86a6                	mv	a3,s1
    800048c8:	fc040613          	addi	a2,s0,-64
    800048cc:	4581                	li	a1,0
    800048ce:	854a                	mv	a0,s2
    800048d0:	00000097          	auipc	ra,0x0
    800048d4:	c38080e7          	jalr	-968(ra) # 80004508 <writei>
    800048d8:	1541                	addi	a0,a0,-16
    800048da:	00a03533          	snez	a0,a0
    800048de:	40a00533          	neg	a0,a0
    800048e2:	74a2                	ld	s1,40(sp)
}
    800048e4:	70e2                	ld	ra,56(sp)
    800048e6:	7442                	ld	s0,48(sp)
    800048e8:	7902                	ld	s2,32(sp)
    800048ea:	69e2                	ld	s3,24(sp)
    800048ec:	6a42                	ld	s4,16(sp)
    800048ee:	6121                	addi	sp,sp,64
    800048f0:	8082                	ret
    iput(ip);
    800048f2:	00000097          	auipc	ra,0x0
    800048f6:	a0c080e7          	jalr	-1524(ra) # 800042fe <iput>
    return -1;
    800048fa:	557d                	li	a0,-1
    800048fc:	b7e5                	j	800048e4 <dirlink+0x88>
      panic("dirlink read");
    800048fe:	00004517          	auipc	a0,0x4
    80004902:	daa50513          	addi	a0,a0,-598 # 800086a8 <__func__.1+0x6a0>
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	c5a080e7          	jalr	-934(ra) # 80000560 <panic>

000000008000490e <namei>:

struct inode*
namei(char *path)
{
    8000490e:	1101                	addi	sp,sp,-32
    80004910:	ec06                	sd	ra,24(sp)
    80004912:	e822                	sd	s0,16(sp)
    80004914:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004916:	fe040613          	addi	a2,s0,-32
    8000491a:	4581                	li	a1,0
    8000491c:	00000097          	auipc	ra,0x0
    80004920:	de0080e7          	jalr	-544(ra) # 800046fc <namex>
}
    80004924:	60e2                	ld	ra,24(sp)
    80004926:	6442                	ld	s0,16(sp)
    80004928:	6105                	addi	sp,sp,32
    8000492a:	8082                	ret

000000008000492c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000492c:	1141                	addi	sp,sp,-16
    8000492e:	e406                	sd	ra,8(sp)
    80004930:	e022                	sd	s0,0(sp)
    80004932:	0800                	addi	s0,sp,16
    80004934:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004936:	4585                	li	a1,1
    80004938:	00000097          	auipc	ra,0x0
    8000493c:	dc4080e7          	jalr	-572(ra) # 800046fc <namex>
}
    80004940:	60a2                	ld	ra,8(sp)
    80004942:	6402                	ld	s0,0(sp)
    80004944:	0141                	addi	sp,sp,16
    80004946:	8082                	ret

0000000080004948 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004948:	1101                	addi	sp,sp,-32
    8000494a:	ec06                	sd	ra,24(sp)
    8000494c:	e822                	sd	s0,16(sp)
    8000494e:	e426                	sd	s1,8(sp)
    80004950:	e04a                	sd	s2,0(sp)
    80004952:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004954:	00027917          	auipc	s2,0x27
    80004958:	06490913          	addi	s2,s2,100 # 8002b9b8 <log>
    8000495c:	01892583          	lw	a1,24(s2)
    80004960:	02892503          	lw	a0,40(s2)
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	fa8080e7          	jalr	-88(ra) # 8000390c <bread>
    8000496c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000496e:	02c92603          	lw	a2,44(s2)
    80004972:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004974:	00c05f63          	blez	a2,80004992 <write_head+0x4a>
    80004978:	00027717          	auipc	a4,0x27
    8000497c:	07070713          	addi	a4,a4,112 # 8002b9e8 <log+0x30>
    80004980:	87aa                	mv	a5,a0
    80004982:	060a                	slli	a2,a2,0x2
    80004984:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004986:	4314                	lw	a3,0(a4)
    80004988:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000498a:	0711                	addi	a4,a4,4
    8000498c:	0791                	addi	a5,a5,4
    8000498e:	fec79ce3          	bne	a5,a2,80004986 <write_head+0x3e>
  }
  bwrite(buf);
    80004992:	8526                	mv	a0,s1
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	06a080e7          	jalr	106(ra) # 800039fe <bwrite>
  brelse(buf);
    8000499c:	8526                	mv	a0,s1
    8000499e:	fffff097          	auipc	ra,0xfffff
    800049a2:	09e080e7          	jalr	158(ra) # 80003a3c <brelse>
}
    800049a6:	60e2                	ld	ra,24(sp)
    800049a8:	6442                	ld	s0,16(sp)
    800049aa:	64a2                	ld	s1,8(sp)
    800049ac:	6902                	ld	s2,0(sp)
    800049ae:	6105                	addi	sp,sp,32
    800049b0:	8082                	ret

00000000800049b2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800049b2:	00027797          	auipc	a5,0x27
    800049b6:	0327a783          	lw	a5,50(a5) # 8002b9e4 <log+0x2c>
    800049ba:	0af05d63          	blez	a5,80004a74 <install_trans+0xc2>
{
    800049be:	7139                	addi	sp,sp,-64
    800049c0:	fc06                	sd	ra,56(sp)
    800049c2:	f822                	sd	s0,48(sp)
    800049c4:	f426                	sd	s1,40(sp)
    800049c6:	f04a                	sd	s2,32(sp)
    800049c8:	ec4e                	sd	s3,24(sp)
    800049ca:	e852                	sd	s4,16(sp)
    800049cc:	e456                	sd	s5,8(sp)
    800049ce:	e05a                	sd	s6,0(sp)
    800049d0:	0080                	addi	s0,sp,64
    800049d2:	8b2a                	mv	s6,a0
    800049d4:	00027a97          	auipc	s5,0x27
    800049d8:	014a8a93          	addi	s5,s5,20 # 8002b9e8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049dc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800049de:	00027997          	auipc	s3,0x27
    800049e2:	fda98993          	addi	s3,s3,-38 # 8002b9b8 <log>
    800049e6:	a00d                	j	80004a08 <install_trans+0x56>
    brelse(lbuf);
    800049e8:	854a                	mv	a0,s2
    800049ea:	fffff097          	auipc	ra,0xfffff
    800049ee:	052080e7          	jalr	82(ra) # 80003a3c <brelse>
    brelse(dbuf);
    800049f2:	8526                	mv	a0,s1
    800049f4:	fffff097          	auipc	ra,0xfffff
    800049f8:	048080e7          	jalr	72(ra) # 80003a3c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049fc:	2a05                	addiw	s4,s4,1
    800049fe:	0a91                	addi	s5,s5,4
    80004a00:	02c9a783          	lw	a5,44(s3)
    80004a04:	04fa5e63          	bge	s4,a5,80004a60 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004a08:	0189a583          	lw	a1,24(s3)
    80004a0c:	014585bb          	addw	a1,a1,s4
    80004a10:	2585                	addiw	a1,a1,1
    80004a12:	0289a503          	lw	a0,40(s3)
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	ef6080e7          	jalr	-266(ra) # 8000390c <bread>
    80004a1e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004a20:	000aa583          	lw	a1,0(s5)
    80004a24:	0289a503          	lw	a0,40(s3)
    80004a28:	fffff097          	auipc	ra,0xfffff
    80004a2c:	ee4080e7          	jalr	-284(ra) # 8000390c <bread>
    80004a30:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004a32:	40000613          	li	a2,1024
    80004a36:	05890593          	addi	a1,s2,88
    80004a3a:	05850513          	addi	a0,a0,88
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	650080e7          	jalr	1616(ra) # 8000108e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004a46:	8526                	mv	a0,s1
    80004a48:	fffff097          	auipc	ra,0xfffff
    80004a4c:	fb6080e7          	jalr	-74(ra) # 800039fe <bwrite>
    if(recovering == 0)
    80004a50:	f80b1ce3          	bnez	s6,800049e8 <install_trans+0x36>
      bunpin(dbuf);
    80004a54:	8526                	mv	a0,s1
    80004a56:	fffff097          	auipc	ra,0xfffff
    80004a5a:	0be080e7          	jalr	190(ra) # 80003b14 <bunpin>
    80004a5e:	b769                	j	800049e8 <install_trans+0x36>
}
    80004a60:	70e2                	ld	ra,56(sp)
    80004a62:	7442                	ld	s0,48(sp)
    80004a64:	74a2                	ld	s1,40(sp)
    80004a66:	7902                	ld	s2,32(sp)
    80004a68:	69e2                	ld	s3,24(sp)
    80004a6a:	6a42                	ld	s4,16(sp)
    80004a6c:	6aa2                	ld	s5,8(sp)
    80004a6e:	6b02                	ld	s6,0(sp)
    80004a70:	6121                	addi	sp,sp,64
    80004a72:	8082                	ret
    80004a74:	8082                	ret

0000000080004a76 <initlog>:
{
    80004a76:	7179                	addi	sp,sp,-48
    80004a78:	f406                	sd	ra,40(sp)
    80004a7a:	f022                	sd	s0,32(sp)
    80004a7c:	ec26                	sd	s1,24(sp)
    80004a7e:	e84a                	sd	s2,16(sp)
    80004a80:	e44e                	sd	s3,8(sp)
    80004a82:	1800                	addi	s0,sp,48
    80004a84:	892a                	mv	s2,a0
    80004a86:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004a88:	00027497          	auipc	s1,0x27
    80004a8c:	f3048493          	addi	s1,s1,-208 # 8002b9b8 <log>
    80004a90:	00004597          	auipc	a1,0x4
    80004a94:	c2858593          	addi	a1,a1,-984 # 800086b8 <__func__.1+0x6b0>
    80004a98:	8526                	mv	a0,s1
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	40c080e7          	jalr	1036(ra) # 80000ea6 <initlock>
  log.start = sb->logstart;
    80004aa2:	0149a583          	lw	a1,20(s3)
    80004aa6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004aa8:	0109a783          	lw	a5,16(s3)
    80004aac:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004aae:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004ab2:	854a                	mv	a0,s2
    80004ab4:	fffff097          	auipc	ra,0xfffff
    80004ab8:	e58080e7          	jalr	-424(ra) # 8000390c <bread>
  log.lh.n = lh->n;
    80004abc:	4d30                	lw	a2,88(a0)
    80004abe:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004ac0:	00c05f63          	blez	a2,80004ade <initlog+0x68>
    80004ac4:	87aa                	mv	a5,a0
    80004ac6:	00027717          	auipc	a4,0x27
    80004aca:	f2270713          	addi	a4,a4,-222 # 8002b9e8 <log+0x30>
    80004ace:	060a                	slli	a2,a2,0x2
    80004ad0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004ad2:	4ff4                	lw	a3,92(a5)
    80004ad4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004ad6:	0791                	addi	a5,a5,4
    80004ad8:	0711                	addi	a4,a4,4
    80004ada:	fec79ce3          	bne	a5,a2,80004ad2 <initlog+0x5c>
  brelse(buf);
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	f5e080e7          	jalr	-162(ra) # 80003a3c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004ae6:	4505                	li	a0,1
    80004ae8:	00000097          	auipc	ra,0x0
    80004aec:	eca080e7          	jalr	-310(ra) # 800049b2 <install_trans>
  log.lh.n = 0;
    80004af0:	00027797          	auipc	a5,0x27
    80004af4:	ee07aa23          	sw	zero,-268(a5) # 8002b9e4 <log+0x2c>
  write_head(); // clear the log
    80004af8:	00000097          	auipc	ra,0x0
    80004afc:	e50080e7          	jalr	-432(ra) # 80004948 <write_head>
}
    80004b00:	70a2                	ld	ra,40(sp)
    80004b02:	7402                	ld	s0,32(sp)
    80004b04:	64e2                	ld	s1,24(sp)
    80004b06:	6942                	ld	s2,16(sp)
    80004b08:	69a2                	ld	s3,8(sp)
    80004b0a:	6145                	addi	sp,sp,48
    80004b0c:	8082                	ret

0000000080004b0e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004b0e:	1101                	addi	sp,sp,-32
    80004b10:	ec06                	sd	ra,24(sp)
    80004b12:	e822                	sd	s0,16(sp)
    80004b14:	e426                	sd	s1,8(sp)
    80004b16:	e04a                	sd	s2,0(sp)
    80004b18:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004b1a:	00027517          	auipc	a0,0x27
    80004b1e:	e9e50513          	addi	a0,a0,-354 # 8002b9b8 <log>
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	414080e7          	jalr	1044(ra) # 80000f36 <acquire>
  while(1){
    if(log.committing){
    80004b2a:	00027497          	auipc	s1,0x27
    80004b2e:	e8e48493          	addi	s1,s1,-370 # 8002b9b8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b32:	4979                	li	s2,30
    80004b34:	a039                	j	80004b42 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004b36:	85a6                	mv	a1,s1
    80004b38:	8526                	mv	a0,s1
    80004b3a:	ffffe097          	auipc	ra,0xffffe
    80004b3e:	c50080e7          	jalr	-944(ra) # 8000278a <sleep>
    if(log.committing){
    80004b42:	50dc                	lw	a5,36(s1)
    80004b44:	fbed                	bnez	a5,80004b36 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b46:	5098                	lw	a4,32(s1)
    80004b48:	2705                	addiw	a4,a4,1
    80004b4a:	0027179b          	slliw	a5,a4,0x2
    80004b4e:	9fb9                	addw	a5,a5,a4
    80004b50:	0017979b          	slliw	a5,a5,0x1
    80004b54:	54d4                	lw	a3,44(s1)
    80004b56:	9fb5                	addw	a5,a5,a3
    80004b58:	00f95963          	bge	s2,a5,80004b6a <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004b5c:	85a6                	mv	a1,s1
    80004b5e:	8526                	mv	a0,s1
    80004b60:	ffffe097          	auipc	ra,0xffffe
    80004b64:	c2a080e7          	jalr	-982(ra) # 8000278a <sleep>
    80004b68:	bfe9                	j	80004b42 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004b6a:	00027517          	auipc	a0,0x27
    80004b6e:	e4e50513          	addi	a0,a0,-434 # 8002b9b8 <log>
    80004b72:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	476080e7          	jalr	1142(ra) # 80000fea <release>
      break;
    }
  }
}
    80004b7c:	60e2                	ld	ra,24(sp)
    80004b7e:	6442                	ld	s0,16(sp)
    80004b80:	64a2                	ld	s1,8(sp)
    80004b82:	6902                	ld	s2,0(sp)
    80004b84:	6105                	addi	sp,sp,32
    80004b86:	8082                	ret

0000000080004b88 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004b88:	7139                	addi	sp,sp,-64
    80004b8a:	fc06                	sd	ra,56(sp)
    80004b8c:	f822                	sd	s0,48(sp)
    80004b8e:	f426                	sd	s1,40(sp)
    80004b90:	f04a                	sd	s2,32(sp)
    80004b92:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004b94:	00027497          	auipc	s1,0x27
    80004b98:	e2448493          	addi	s1,s1,-476 # 8002b9b8 <log>
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	ffffc097          	auipc	ra,0xffffc
    80004ba2:	398080e7          	jalr	920(ra) # 80000f36 <acquire>
  log.outstanding -= 1;
    80004ba6:	509c                	lw	a5,32(s1)
    80004ba8:	37fd                	addiw	a5,a5,-1
    80004baa:	0007891b          	sext.w	s2,a5
    80004bae:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004bb0:	50dc                	lw	a5,36(s1)
    80004bb2:	e7b9                	bnez	a5,80004c00 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004bb4:	06091163          	bnez	s2,80004c16 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004bb8:	00027497          	auipc	s1,0x27
    80004bbc:	e0048493          	addi	s1,s1,-512 # 8002b9b8 <log>
    80004bc0:	4785                	li	a5,1
    80004bc2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	424080e7          	jalr	1060(ra) # 80000fea <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004bce:	54dc                	lw	a5,44(s1)
    80004bd0:	06f04763          	bgtz	a5,80004c3e <end_op+0xb6>
    acquire(&log.lock);
    80004bd4:	00027497          	auipc	s1,0x27
    80004bd8:	de448493          	addi	s1,s1,-540 # 8002b9b8 <log>
    80004bdc:	8526                	mv	a0,s1
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	358080e7          	jalr	856(ra) # 80000f36 <acquire>
    log.committing = 0;
    80004be6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004bea:	8526                	mv	a0,s1
    80004bec:	ffffe097          	auipc	ra,0xffffe
    80004bf0:	c02080e7          	jalr	-1022(ra) # 800027ee <wakeup>
    release(&log.lock);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	3f4080e7          	jalr	1012(ra) # 80000fea <release>
}
    80004bfe:	a815                	j	80004c32 <end_op+0xaa>
    80004c00:	ec4e                	sd	s3,24(sp)
    80004c02:	e852                	sd	s4,16(sp)
    80004c04:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004c06:	00004517          	auipc	a0,0x4
    80004c0a:	aba50513          	addi	a0,a0,-1350 # 800086c0 <__func__.1+0x6b8>
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	952080e7          	jalr	-1710(ra) # 80000560 <panic>
    wakeup(&log);
    80004c16:	00027497          	auipc	s1,0x27
    80004c1a:	da248493          	addi	s1,s1,-606 # 8002b9b8 <log>
    80004c1e:	8526                	mv	a0,s1
    80004c20:	ffffe097          	auipc	ra,0xffffe
    80004c24:	bce080e7          	jalr	-1074(ra) # 800027ee <wakeup>
  release(&log.lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	3c0080e7          	jalr	960(ra) # 80000fea <release>
}
    80004c32:	70e2                	ld	ra,56(sp)
    80004c34:	7442                	ld	s0,48(sp)
    80004c36:	74a2                	ld	s1,40(sp)
    80004c38:	7902                	ld	s2,32(sp)
    80004c3a:	6121                	addi	sp,sp,64
    80004c3c:	8082                	ret
    80004c3e:	ec4e                	sd	s3,24(sp)
    80004c40:	e852                	sd	s4,16(sp)
    80004c42:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c44:	00027a97          	auipc	s5,0x27
    80004c48:	da4a8a93          	addi	s5,s5,-604 # 8002b9e8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004c4c:	00027a17          	auipc	s4,0x27
    80004c50:	d6ca0a13          	addi	s4,s4,-660 # 8002b9b8 <log>
    80004c54:	018a2583          	lw	a1,24(s4)
    80004c58:	012585bb          	addw	a1,a1,s2
    80004c5c:	2585                	addiw	a1,a1,1
    80004c5e:	028a2503          	lw	a0,40(s4)
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	caa080e7          	jalr	-854(ra) # 8000390c <bread>
    80004c6a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004c6c:	000aa583          	lw	a1,0(s5)
    80004c70:	028a2503          	lw	a0,40(s4)
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	c98080e7          	jalr	-872(ra) # 8000390c <bread>
    80004c7c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004c7e:	40000613          	li	a2,1024
    80004c82:	05850593          	addi	a1,a0,88
    80004c86:	05848513          	addi	a0,s1,88
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	404080e7          	jalr	1028(ra) # 8000108e <memmove>
    bwrite(to);  // write the log
    80004c92:	8526                	mv	a0,s1
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	d6a080e7          	jalr	-662(ra) # 800039fe <bwrite>
    brelse(from);
    80004c9c:	854e                	mv	a0,s3
    80004c9e:	fffff097          	auipc	ra,0xfffff
    80004ca2:	d9e080e7          	jalr	-610(ra) # 80003a3c <brelse>
    brelse(to);
    80004ca6:	8526                	mv	a0,s1
    80004ca8:	fffff097          	auipc	ra,0xfffff
    80004cac:	d94080e7          	jalr	-620(ra) # 80003a3c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004cb0:	2905                	addiw	s2,s2,1
    80004cb2:	0a91                	addi	s5,s5,4
    80004cb4:	02ca2783          	lw	a5,44(s4)
    80004cb8:	f8f94ee3          	blt	s2,a5,80004c54 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004cbc:	00000097          	auipc	ra,0x0
    80004cc0:	c8c080e7          	jalr	-884(ra) # 80004948 <write_head>
    install_trans(0); // Now install writes to home locations
    80004cc4:	4501                	li	a0,0
    80004cc6:	00000097          	auipc	ra,0x0
    80004cca:	cec080e7          	jalr	-788(ra) # 800049b2 <install_trans>
    log.lh.n = 0;
    80004cce:	00027797          	auipc	a5,0x27
    80004cd2:	d007ab23          	sw	zero,-746(a5) # 8002b9e4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004cd6:	00000097          	auipc	ra,0x0
    80004cda:	c72080e7          	jalr	-910(ra) # 80004948 <write_head>
    80004cde:	69e2                	ld	s3,24(sp)
    80004ce0:	6a42                	ld	s4,16(sp)
    80004ce2:	6aa2                	ld	s5,8(sp)
    80004ce4:	bdc5                	j	80004bd4 <end_op+0x4c>

0000000080004ce6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ce6:	1101                	addi	sp,sp,-32
    80004ce8:	ec06                	sd	ra,24(sp)
    80004cea:	e822                	sd	s0,16(sp)
    80004cec:	e426                	sd	s1,8(sp)
    80004cee:	e04a                	sd	s2,0(sp)
    80004cf0:	1000                	addi	s0,sp,32
    80004cf2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004cf4:	00027917          	auipc	s2,0x27
    80004cf8:	cc490913          	addi	s2,s2,-828 # 8002b9b8 <log>
    80004cfc:	854a                	mv	a0,s2
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	238080e7          	jalr	568(ra) # 80000f36 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004d06:	02c92603          	lw	a2,44(s2)
    80004d0a:	47f5                	li	a5,29
    80004d0c:	06c7c563          	blt	a5,a2,80004d76 <log_write+0x90>
    80004d10:	00027797          	auipc	a5,0x27
    80004d14:	cc47a783          	lw	a5,-828(a5) # 8002b9d4 <log+0x1c>
    80004d18:	37fd                	addiw	a5,a5,-1
    80004d1a:	04f65e63          	bge	a2,a5,80004d76 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004d1e:	00027797          	auipc	a5,0x27
    80004d22:	cba7a783          	lw	a5,-838(a5) # 8002b9d8 <log+0x20>
    80004d26:	06f05063          	blez	a5,80004d86 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004d2a:	4781                	li	a5,0
    80004d2c:	06c05563          	blez	a2,80004d96 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004d30:	44cc                	lw	a1,12(s1)
    80004d32:	00027717          	auipc	a4,0x27
    80004d36:	cb670713          	addi	a4,a4,-842 # 8002b9e8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004d3a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004d3c:	4314                	lw	a3,0(a4)
    80004d3e:	04b68c63          	beq	a3,a1,80004d96 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004d42:	2785                	addiw	a5,a5,1
    80004d44:	0711                	addi	a4,a4,4
    80004d46:	fef61be3          	bne	a2,a5,80004d3c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004d4a:	0621                	addi	a2,a2,8
    80004d4c:	060a                	slli	a2,a2,0x2
    80004d4e:	00027797          	auipc	a5,0x27
    80004d52:	c6a78793          	addi	a5,a5,-918 # 8002b9b8 <log>
    80004d56:	97b2                	add	a5,a5,a2
    80004d58:	44d8                	lw	a4,12(s1)
    80004d5a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	d7a080e7          	jalr	-646(ra) # 80003ad8 <bpin>
    log.lh.n++;
    80004d66:	00027717          	auipc	a4,0x27
    80004d6a:	c5270713          	addi	a4,a4,-942 # 8002b9b8 <log>
    80004d6e:	575c                	lw	a5,44(a4)
    80004d70:	2785                	addiw	a5,a5,1
    80004d72:	d75c                	sw	a5,44(a4)
    80004d74:	a82d                	j	80004dae <log_write+0xc8>
    panic("too big a transaction");
    80004d76:	00004517          	auipc	a0,0x4
    80004d7a:	95a50513          	addi	a0,a0,-1702 # 800086d0 <__func__.1+0x6c8>
    80004d7e:	ffffb097          	auipc	ra,0xffffb
    80004d82:	7e2080e7          	jalr	2018(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004d86:	00004517          	auipc	a0,0x4
    80004d8a:	96250513          	addi	a0,a0,-1694 # 800086e8 <__func__.1+0x6e0>
    80004d8e:	ffffb097          	auipc	ra,0xffffb
    80004d92:	7d2080e7          	jalr	2002(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004d96:	00878693          	addi	a3,a5,8
    80004d9a:	068a                	slli	a3,a3,0x2
    80004d9c:	00027717          	auipc	a4,0x27
    80004da0:	c1c70713          	addi	a4,a4,-996 # 8002b9b8 <log>
    80004da4:	9736                	add	a4,a4,a3
    80004da6:	44d4                	lw	a3,12(s1)
    80004da8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004daa:	faf609e3          	beq	a2,a5,80004d5c <log_write+0x76>
  }
  release(&log.lock);
    80004dae:	00027517          	auipc	a0,0x27
    80004db2:	c0a50513          	addi	a0,a0,-1014 # 8002b9b8 <log>
    80004db6:	ffffc097          	auipc	ra,0xffffc
    80004dba:	234080e7          	jalr	564(ra) # 80000fea <release>
}
    80004dbe:	60e2                	ld	ra,24(sp)
    80004dc0:	6442                	ld	s0,16(sp)
    80004dc2:	64a2                	ld	s1,8(sp)
    80004dc4:	6902                	ld	s2,0(sp)
    80004dc6:	6105                	addi	sp,sp,32
    80004dc8:	8082                	ret

0000000080004dca <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004dca:	1101                	addi	sp,sp,-32
    80004dcc:	ec06                	sd	ra,24(sp)
    80004dce:	e822                	sd	s0,16(sp)
    80004dd0:	e426                	sd	s1,8(sp)
    80004dd2:	e04a                	sd	s2,0(sp)
    80004dd4:	1000                	addi	s0,sp,32
    80004dd6:	84aa                	mv	s1,a0
    80004dd8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004dda:	00004597          	auipc	a1,0x4
    80004dde:	92e58593          	addi	a1,a1,-1746 # 80008708 <__func__.1+0x700>
    80004de2:	0521                	addi	a0,a0,8
    80004de4:	ffffc097          	auipc	ra,0xffffc
    80004de8:	0c2080e7          	jalr	194(ra) # 80000ea6 <initlock>
  lk->name = name;
    80004dec:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004df0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004df4:	0204a423          	sw	zero,40(s1)
}
    80004df8:	60e2                	ld	ra,24(sp)
    80004dfa:	6442                	ld	s0,16(sp)
    80004dfc:	64a2                	ld	s1,8(sp)
    80004dfe:	6902                	ld	s2,0(sp)
    80004e00:	6105                	addi	sp,sp,32
    80004e02:	8082                	ret

0000000080004e04 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004e04:	1101                	addi	sp,sp,-32
    80004e06:	ec06                	sd	ra,24(sp)
    80004e08:	e822                	sd	s0,16(sp)
    80004e0a:	e426                	sd	s1,8(sp)
    80004e0c:	e04a                	sd	s2,0(sp)
    80004e0e:	1000                	addi	s0,sp,32
    80004e10:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e12:	00850913          	addi	s2,a0,8
    80004e16:	854a                	mv	a0,s2
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	11e080e7          	jalr	286(ra) # 80000f36 <acquire>
  while (lk->locked) {
    80004e20:	409c                	lw	a5,0(s1)
    80004e22:	cb89                	beqz	a5,80004e34 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004e24:	85ca                	mv	a1,s2
    80004e26:	8526                	mv	a0,s1
    80004e28:	ffffe097          	auipc	ra,0xffffe
    80004e2c:	962080e7          	jalr	-1694(ra) # 8000278a <sleep>
  while (lk->locked) {
    80004e30:	409c                	lw	a5,0(s1)
    80004e32:	fbed                	bnez	a5,80004e24 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004e34:	4785                	li	a5,1
    80004e36:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	1a0080e7          	jalr	416(ra) # 80001fd8 <myproc>
    80004e40:	591c                	lw	a5,48(a0)
    80004e42:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004e44:	854a                	mv	a0,s2
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	1a4080e7          	jalr	420(ra) # 80000fea <release>
}
    80004e4e:	60e2                	ld	ra,24(sp)
    80004e50:	6442                	ld	s0,16(sp)
    80004e52:	64a2                	ld	s1,8(sp)
    80004e54:	6902                	ld	s2,0(sp)
    80004e56:	6105                	addi	sp,sp,32
    80004e58:	8082                	ret

0000000080004e5a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004e5a:	1101                	addi	sp,sp,-32
    80004e5c:	ec06                	sd	ra,24(sp)
    80004e5e:	e822                	sd	s0,16(sp)
    80004e60:	e426                	sd	s1,8(sp)
    80004e62:	e04a                	sd	s2,0(sp)
    80004e64:	1000                	addi	s0,sp,32
    80004e66:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e68:	00850913          	addi	s2,a0,8
    80004e6c:	854a                	mv	a0,s2
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	0c8080e7          	jalr	200(ra) # 80000f36 <acquire>
  lk->locked = 0;
    80004e76:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e7a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004e7e:	8526                	mv	a0,s1
    80004e80:	ffffe097          	auipc	ra,0xffffe
    80004e84:	96e080e7          	jalr	-1682(ra) # 800027ee <wakeup>
  release(&lk->lk);
    80004e88:	854a                	mv	a0,s2
    80004e8a:	ffffc097          	auipc	ra,0xffffc
    80004e8e:	160080e7          	jalr	352(ra) # 80000fea <release>
}
    80004e92:	60e2                	ld	ra,24(sp)
    80004e94:	6442                	ld	s0,16(sp)
    80004e96:	64a2                	ld	s1,8(sp)
    80004e98:	6902                	ld	s2,0(sp)
    80004e9a:	6105                	addi	sp,sp,32
    80004e9c:	8082                	ret

0000000080004e9e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004e9e:	7179                	addi	sp,sp,-48
    80004ea0:	f406                	sd	ra,40(sp)
    80004ea2:	f022                	sd	s0,32(sp)
    80004ea4:	ec26                	sd	s1,24(sp)
    80004ea6:	e84a                	sd	s2,16(sp)
    80004ea8:	1800                	addi	s0,sp,48
    80004eaa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004eac:	00850913          	addi	s2,a0,8
    80004eb0:	854a                	mv	a0,s2
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	084080e7          	jalr	132(ra) # 80000f36 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004eba:	409c                	lw	a5,0(s1)
    80004ebc:	ef91                	bnez	a5,80004ed8 <holdingsleep+0x3a>
    80004ebe:	4481                	li	s1,0
  release(&lk->lk);
    80004ec0:	854a                	mv	a0,s2
    80004ec2:	ffffc097          	auipc	ra,0xffffc
    80004ec6:	128080e7          	jalr	296(ra) # 80000fea <release>
  return r;
}
    80004eca:	8526                	mv	a0,s1
    80004ecc:	70a2                	ld	ra,40(sp)
    80004ece:	7402                	ld	s0,32(sp)
    80004ed0:	64e2                	ld	s1,24(sp)
    80004ed2:	6942                	ld	s2,16(sp)
    80004ed4:	6145                	addi	sp,sp,48
    80004ed6:	8082                	ret
    80004ed8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004eda:	0284a983          	lw	s3,40(s1)
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	0fa080e7          	jalr	250(ra) # 80001fd8 <myproc>
    80004ee6:	5904                	lw	s1,48(a0)
    80004ee8:	413484b3          	sub	s1,s1,s3
    80004eec:	0014b493          	seqz	s1,s1
    80004ef0:	69a2                	ld	s3,8(sp)
    80004ef2:	b7f9                	j	80004ec0 <holdingsleep+0x22>

0000000080004ef4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ef4:	1141                	addi	sp,sp,-16
    80004ef6:	e406                	sd	ra,8(sp)
    80004ef8:	e022                	sd	s0,0(sp)
    80004efa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004efc:	00004597          	auipc	a1,0x4
    80004f00:	81c58593          	addi	a1,a1,-2020 # 80008718 <__func__.1+0x710>
    80004f04:	00027517          	auipc	a0,0x27
    80004f08:	bfc50513          	addi	a0,a0,-1028 # 8002bb00 <ftable>
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	f9a080e7          	jalr	-102(ra) # 80000ea6 <initlock>
}
    80004f14:	60a2                	ld	ra,8(sp)
    80004f16:	6402                	ld	s0,0(sp)
    80004f18:	0141                	addi	sp,sp,16
    80004f1a:	8082                	ret

0000000080004f1c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004f1c:	1101                	addi	sp,sp,-32
    80004f1e:	ec06                	sd	ra,24(sp)
    80004f20:	e822                	sd	s0,16(sp)
    80004f22:	e426                	sd	s1,8(sp)
    80004f24:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004f26:	00027517          	auipc	a0,0x27
    80004f2a:	bda50513          	addi	a0,a0,-1062 # 8002bb00 <ftable>
    80004f2e:	ffffc097          	auipc	ra,0xffffc
    80004f32:	008080e7          	jalr	8(ra) # 80000f36 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f36:	00027497          	auipc	s1,0x27
    80004f3a:	be248493          	addi	s1,s1,-1054 # 8002bb18 <ftable+0x18>
    80004f3e:	00028717          	auipc	a4,0x28
    80004f42:	b7a70713          	addi	a4,a4,-1158 # 8002cab8 <disk>
    if(f->ref == 0){
    80004f46:	40dc                	lw	a5,4(s1)
    80004f48:	cf99                	beqz	a5,80004f66 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f4a:	02848493          	addi	s1,s1,40
    80004f4e:	fee49ce3          	bne	s1,a4,80004f46 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004f52:	00027517          	auipc	a0,0x27
    80004f56:	bae50513          	addi	a0,a0,-1106 # 8002bb00 <ftable>
    80004f5a:	ffffc097          	auipc	ra,0xffffc
    80004f5e:	090080e7          	jalr	144(ra) # 80000fea <release>
  return 0;
    80004f62:	4481                	li	s1,0
    80004f64:	a819                	j	80004f7a <filealloc+0x5e>
      f->ref = 1;
    80004f66:	4785                	li	a5,1
    80004f68:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004f6a:	00027517          	auipc	a0,0x27
    80004f6e:	b9650513          	addi	a0,a0,-1130 # 8002bb00 <ftable>
    80004f72:	ffffc097          	auipc	ra,0xffffc
    80004f76:	078080e7          	jalr	120(ra) # 80000fea <release>
}
    80004f7a:	8526                	mv	a0,s1
    80004f7c:	60e2                	ld	ra,24(sp)
    80004f7e:	6442                	ld	s0,16(sp)
    80004f80:	64a2                	ld	s1,8(sp)
    80004f82:	6105                	addi	sp,sp,32
    80004f84:	8082                	ret

0000000080004f86 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004f86:	1101                	addi	sp,sp,-32
    80004f88:	ec06                	sd	ra,24(sp)
    80004f8a:	e822                	sd	s0,16(sp)
    80004f8c:	e426                	sd	s1,8(sp)
    80004f8e:	1000                	addi	s0,sp,32
    80004f90:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004f92:	00027517          	auipc	a0,0x27
    80004f96:	b6e50513          	addi	a0,a0,-1170 # 8002bb00 <ftable>
    80004f9a:	ffffc097          	auipc	ra,0xffffc
    80004f9e:	f9c080e7          	jalr	-100(ra) # 80000f36 <acquire>
  if(f->ref < 1)
    80004fa2:	40dc                	lw	a5,4(s1)
    80004fa4:	02f05263          	blez	a5,80004fc8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004fa8:	2785                	addiw	a5,a5,1
    80004faa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004fac:	00027517          	auipc	a0,0x27
    80004fb0:	b5450513          	addi	a0,a0,-1196 # 8002bb00 <ftable>
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	036080e7          	jalr	54(ra) # 80000fea <release>
  return f;
}
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	60e2                	ld	ra,24(sp)
    80004fc0:	6442                	ld	s0,16(sp)
    80004fc2:	64a2                	ld	s1,8(sp)
    80004fc4:	6105                	addi	sp,sp,32
    80004fc6:	8082                	ret
    panic("filedup");
    80004fc8:	00003517          	auipc	a0,0x3
    80004fcc:	75850513          	addi	a0,a0,1880 # 80008720 <__func__.1+0x718>
    80004fd0:	ffffb097          	auipc	ra,0xffffb
    80004fd4:	590080e7          	jalr	1424(ra) # 80000560 <panic>

0000000080004fd8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004fd8:	7139                	addi	sp,sp,-64
    80004fda:	fc06                	sd	ra,56(sp)
    80004fdc:	f822                	sd	s0,48(sp)
    80004fde:	f426                	sd	s1,40(sp)
    80004fe0:	0080                	addi	s0,sp,64
    80004fe2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004fe4:	00027517          	auipc	a0,0x27
    80004fe8:	b1c50513          	addi	a0,a0,-1252 # 8002bb00 <ftable>
    80004fec:	ffffc097          	auipc	ra,0xffffc
    80004ff0:	f4a080e7          	jalr	-182(ra) # 80000f36 <acquire>
  if(f->ref < 1)
    80004ff4:	40dc                	lw	a5,4(s1)
    80004ff6:	04f05c63          	blez	a5,8000504e <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004ffa:	37fd                	addiw	a5,a5,-1
    80004ffc:	0007871b          	sext.w	a4,a5
    80005000:	c0dc                	sw	a5,4(s1)
    80005002:	06e04263          	bgtz	a4,80005066 <fileclose+0x8e>
    80005006:	f04a                	sd	s2,32(sp)
    80005008:	ec4e                	sd	s3,24(sp)
    8000500a:	e852                	sd	s4,16(sp)
    8000500c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000500e:	0004a903          	lw	s2,0(s1)
    80005012:	0094ca83          	lbu	s5,9(s1)
    80005016:	0104ba03          	ld	s4,16(s1)
    8000501a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000501e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005022:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005026:	00027517          	auipc	a0,0x27
    8000502a:	ada50513          	addi	a0,a0,-1318 # 8002bb00 <ftable>
    8000502e:	ffffc097          	auipc	ra,0xffffc
    80005032:	fbc080e7          	jalr	-68(ra) # 80000fea <release>

  if(ff.type == FD_PIPE){
    80005036:	4785                	li	a5,1
    80005038:	04f90463          	beq	s2,a5,80005080 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000503c:	3979                	addiw	s2,s2,-2
    8000503e:	4785                	li	a5,1
    80005040:	0527fb63          	bgeu	a5,s2,80005096 <fileclose+0xbe>
    80005044:	7902                	ld	s2,32(sp)
    80005046:	69e2                	ld	s3,24(sp)
    80005048:	6a42                	ld	s4,16(sp)
    8000504a:	6aa2                	ld	s5,8(sp)
    8000504c:	a02d                	j	80005076 <fileclose+0x9e>
    8000504e:	f04a                	sd	s2,32(sp)
    80005050:	ec4e                	sd	s3,24(sp)
    80005052:	e852                	sd	s4,16(sp)
    80005054:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80005056:	00003517          	auipc	a0,0x3
    8000505a:	6d250513          	addi	a0,a0,1746 # 80008728 <__func__.1+0x720>
    8000505e:	ffffb097          	auipc	ra,0xffffb
    80005062:	502080e7          	jalr	1282(ra) # 80000560 <panic>
    release(&ftable.lock);
    80005066:	00027517          	auipc	a0,0x27
    8000506a:	a9a50513          	addi	a0,a0,-1382 # 8002bb00 <ftable>
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	f7c080e7          	jalr	-132(ra) # 80000fea <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005076:	70e2                	ld	ra,56(sp)
    80005078:	7442                	ld	s0,48(sp)
    8000507a:	74a2                	ld	s1,40(sp)
    8000507c:	6121                	addi	sp,sp,64
    8000507e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005080:	85d6                	mv	a1,s5
    80005082:	8552                	mv	a0,s4
    80005084:	00000097          	auipc	ra,0x0
    80005088:	3a2080e7          	jalr	930(ra) # 80005426 <pipeclose>
    8000508c:	7902                	ld	s2,32(sp)
    8000508e:	69e2                	ld	s3,24(sp)
    80005090:	6a42                	ld	s4,16(sp)
    80005092:	6aa2                	ld	s5,8(sp)
    80005094:	b7cd                	j	80005076 <fileclose+0x9e>
    begin_op();
    80005096:	00000097          	auipc	ra,0x0
    8000509a:	a78080e7          	jalr	-1416(ra) # 80004b0e <begin_op>
    iput(ff.ip);
    8000509e:	854e                	mv	a0,s3
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	25e080e7          	jalr	606(ra) # 800042fe <iput>
    end_op();
    800050a8:	00000097          	auipc	ra,0x0
    800050ac:	ae0080e7          	jalr	-1312(ra) # 80004b88 <end_op>
    800050b0:	7902                	ld	s2,32(sp)
    800050b2:	69e2                	ld	s3,24(sp)
    800050b4:	6a42                	ld	s4,16(sp)
    800050b6:	6aa2                	ld	s5,8(sp)
    800050b8:	bf7d                	j	80005076 <fileclose+0x9e>

00000000800050ba <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800050ba:	715d                	addi	sp,sp,-80
    800050bc:	e486                	sd	ra,72(sp)
    800050be:	e0a2                	sd	s0,64(sp)
    800050c0:	fc26                	sd	s1,56(sp)
    800050c2:	f44e                	sd	s3,40(sp)
    800050c4:	0880                	addi	s0,sp,80
    800050c6:	84aa                	mv	s1,a0
    800050c8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800050ca:	ffffd097          	auipc	ra,0xffffd
    800050ce:	f0e080e7          	jalr	-242(ra) # 80001fd8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800050d2:	409c                	lw	a5,0(s1)
    800050d4:	37f9                	addiw	a5,a5,-2
    800050d6:	4705                	li	a4,1
    800050d8:	04f76863          	bltu	a4,a5,80005128 <filestat+0x6e>
    800050dc:	f84a                	sd	s2,48(sp)
    800050de:	892a                	mv	s2,a0
    ilock(f->ip);
    800050e0:	6c88                	ld	a0,24(s1)
    800050e2:	fffff097          	auipc	ra,0xfffff
    800050e6:	05e080e7          	jalr	94(ra) # 80004140 <ilock>
    stati(f->ip, &st);
    800050ea:	fb840593          	addi	a1,s0,-72
    800050ee:	6c88                	ld	a0,24(s1)
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	2de080e7          	jalr	734(ra) # 800043ce <stati>
    iunlock(f->ip);
    800050f8:	6c88                	ld	a0,24(s1)
    800050fa:	fffff097          	auipc	ra,0xfffff
    800050fe:	10c080e7          	jalr	268(ra) # 80004206 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005102:	46e1                	li	a3,24
    80005104:	fb840613          	addi	a2,s0,-72
    80005108:	85ce                	mv	a1,s3
    8000510a:	05093503          	ld	a0,80(s2)
    8000510e:	ffffd097          	auipc	ra,0xffffd
    80005112:	8d8080e7          	jalr	-1832(ra) # 800019e6 <copyout>
    80005116:	41f5551b          	sraiw	a0,a0,0x1f
    8000511a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000511c:	60a6                	ld	ra,72(sp)
    8000511e:	6406                	ld	s0,64(sp)
    80005120:	74e2                	ld	s1,56(sp)
    80005122:	79a2                	ld	s3,40(sp)
    80005124:	6161                	addi	sp,sp,80
    80005126:	8082                	ret
  return -1;
    80005128:	557d                	li	a0,-1
    8000512a:	bfcd                	j	8000511c <filestat+0x62>

000000008000512c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000512c:	7179                	addi	sp,sp,-48
    8000512e:	f406                	sd	ra,40(sp)
    80005130:	f022                	sd	s0,32(sp)
    80005132:	e84a                	sd	s2,16(sp)
    80005134:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005136:	00854783          	lbu	a5,8(a0)
    8000513a:	cbc5                	beqz	a5,800051ea <fileread+0xbe>
    8000513c:	ec26                	sd	s1,24(sp)
    8000513e:	e44e                	sd	s3,8(sp)
    80005140:	84aa                	mv	s1,a0
    80005142:	89ae                	mv	s3,a1
    80005144:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005146:	411c                	lw	a5,0(a0)
    80005148:	4705                	li	a4,1
    8000514a:	04e78963          	beq	a5,a4,8000519c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000514e:	470d                	li	a4,3
    80005150:	04e78f63          	beq	a5,a4,800051ae <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005154:	4709                	li	a4,2
    80005156:	08e79263          	bne	a5,a4,800051da <fileread+0xae>
    ilock(f->ip);
    8000515a:	6d08                	ld	a0,24(a0)
    8000515c:	fffff097          	auipc	ra,0xfffff
    80005160:	fe4080e7          	jalr	-28(ra) # 80004140 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005164:	874a                	mv	a4,s2
    80005166:	5094                	lw	a3,32(s1)
    80005168:	864e                	mv	a2,s3
    8000516a:	4585                	li	a1,1
    8000516c:	6c88                	ld	a0,24(s1)
    8000516e:	fffff097          	auipc	ra,0xfffff
    80005172:	28a080e7          	jalr	650(ra) # 800043f8 <readi>
    80005176:	892a                	mv	s2,a0
    80005178:	00a05563          	blez	a0,80005182 <fileread+0x56>
      f->off += r;
    8000517c:	509c                	lw	a5,32(s1)
    8000517e:	9fa9                	addw	a5,a5,a0
    80005180:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005182:	6c88                	ld	a0,24(s1)
    80005184:	fffff097          	auipc	ra,0xfffff
    80005188:	082080e7          	jalr	130(ra) # 80004206 <iunlock>
    8000518c:	64e2                	ld	s1,24(sp)
    8000518e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005190:	854a                	mv	a0,s2
    80005192:	70a2                	ld	ra,40(sp)
    80005194:	7402                	ld	s0,32(sp)
    80005196:	6942                	ld	s2,16(sp)
    80005198:	6145                	addi	sp,sp,48
    8000519a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000519c:	6908                	ld	a0,16(a0)
    8000519e:	00000097          	auipc	ra,0x0
    800051a2:	400080e7          	jalr	1024(ra) # 8000559e <piperead>
    800051a6:	892a                	mv	s2,a0
    800051a8:	64e2                	ld	s1,24(sp)
    800051aa:	69a2                	ld	s3,8(sp)
    800051ac:	b7d5                	j	80005190 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800051ae:	02451783          	lh	a5,36(a0)
    800051b2:	03079693          	slli	a3,a5,0x30
    800051b6:	92c1                	srli	a3,a3,0x30
    800051b8:	4725                	li	a4,9
    800051ba:	02d76a63          	bltu	a4,a3,800051ee <fileread+0xc2>
    800051be:	0792                	slli	a5,a5,0x4
    800051c0:	00027717          	auipc	a4,0x27
    800051c4:	8a070713          	addi	a4,a4,-1888 # 8002ba60 <devsw>
    800051c8:	97ba                	add	a5,a5,a4
    800051ca:	639c                	ld	a5,0(a5)
    800051cc:	c78d                	beqz	a5,800051f6 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    800051ce:	4505                	li	a0,1
    800051d0:	9782                	jalr	a5
    800051d2:	892a                	mv	s2,a0
    800051d4:	64e2                	ld	s1,24(sp)
    800051d6:	69a2                	ld	s3,8(sp)
    800051d8:	bf65                	j	80005190 <fileread+0x64>
    panic("fileread");
    800051da:	00003517          	auipc	a0,0x3
    800051de:	55e50513          	addi	a0,a0,1374 # 80008738 <__func__.1+0x730>
    800051e2:	ffffb097          	auipc	ra,0xffffb
    800051e6:	37e080e7          	jalr	894(ra) # 80000560 <panic>
    return -1;
    800051ea:	597d                	li	s2,-1
    800051ec:	b755                	j	80005190 <fileread+0x64>
      return -1;
    800051ee:	597d                	li	s2,-1
    800051f0:	64e2                	ld	s1,24(sp)
    800051f2:	69a2                	ld	s3,8(sp)
    800051f4:	bf71                	j	80005190 <fileread+0x64>
    800051f6:	597d                	li	s2,-1
    800051f8:	64e2                	ld	s1,24(sp)
    800051fa:	69a2                	ld	s3,8(sp)
    800051fc:	bf51                	j	80005190 <fileread+0x64>

00000000800051fe <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800051fe:	00954783          	lbu	a5,9(a0)
    80005202:	12078963          	beqz	a5,80005334 <filewrite+0x136>
{
    80005206:	715d                	addi	sp,sp,-80
    80005208:	e486                	sd	ra,72(sp)
    8000520a:	e0a2                	sd	s0,64(sp)
    8000520c:	f84a                	sd	s2,48(sp)
    8000520e:	f052                	sd	s4,32(sp)
    80005210:	e85a                	sd	s6,16(sp)
    80005212:	0880                	addi	s0,sp,80
    80005214:	892a                	mv	s2,a0
    80005216:	8b2e                	mv	s6,a1
    80005218:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000521a:	411c                	lw	a5,0(a0)
    8000521c:	4705                	li	a4,1
    8000521e:	02e78763          	beq	a5,a4,8000524c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005222:	470d                	li	a4,3
    80005224:	02e78a63          	beq	a5,a4,80005258 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005228:	4709                	li	a4,2
    8000522a:	0ee79863          	bne	a5,a4,8000531a <filewrite+0x11c>
    8000522e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005230:	0cc05463          	blez	a2,800052f8 <filewrite+0xfa>
    80005234:	fc26                	sd	s1,56(sp)
    80005236:	ec56                	sd	s5,24(sp)
    80005238:	e45e                	sd	s7,8(sp)
    8000523a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000523c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000523e:	6b85                	lui	s7,0x1
    80005240:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005244:	6c05                	lui	s8,0x1
    80005246:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000524a:	a851                	j	800052de <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000524c:	6908                	ld	a0,16(a0)
    8000524e:	00000097          	auipc	ra,0x0
    80005252:	248080e7          	jalr	584(ra) # 80005496 <pipewrite>
    80005256:	a85d                	j	8000530c <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005258:	02451783          	lh	a5,36(a0)
    8000525c:	03079693          	slli	a3,a5,0x30
    80005260:	92c1                	srli	a3,a3,0x30
    80005262:	4725                	li	a4,9
    80005264:	0cd76a63          	bltu	a4,a3,80005338 <filewrite+0x13a>
    80005268:	0792                	slli	a5,a5,0x4
    8000526a:	00026717          	auipc	a4,0x26
    8000526e:	7f670713          	addi	a4,a4,2038 # 8002ba60 <devsw>
    80005272:	97ba                	add	a5,a5,a4
    80005274:	679c                	ld	a5,8(a5)
    80005276:	c3f9                	beqz	a5,8000533c <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80005278:	4505                	li	a0,1
    8000527a:	9782                	jalr	a5
    8000527c:	a841                	j	8000530c <filewrite+0x10e>
      if(n1 > max)
    8000527e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005282:	00000097          	auipc	ra,0x0
    80005286:	88c080e7          	jalr	-1908(ra) # 80004b0e <begin_op>
      ilock(f->ip);
    8000528a:	01893503          	ld	a0,24(s2)
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	eb2080e7          	jalr	-334(ra) # 80004140 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005296:	8756                	mv	a4,s5
    80005298:	02092683          	lw	a3,32(s2)
    8000529c:	01698633          	add	a2,s3,s6
    800052a0:	4585                	li	a1,1
    800052a2:	01893503          	ld	a0,24(s2)
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	262080e7          	jalr	610(ra) # 80004508 <writei>
    800052ae:	84aa                	mv	s1,a0
    800052b0:	00a05763          	blez	a0,800052be <filewrite+0xc0>
        f->off += r;
    800052b4:	02092783          	lw	a5,32(s2)
    800052b8:	9fa9                	addw	a5,a5,a0
    800052ba:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800052be:	01893503          	ld	a0,24(s2)
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	f44080e7          	jalr	-188(ra) # 80004206 <iunlock>
      end_op();
    800052ca:	00000097          	auipc	ra,0x0
    800052ce:	8be080e7          	jalr	-1858(ra) # 80004b88 <end_op>

      if(r != n1){
    800052d2:	029a9563          	bne	s5,s1,800052fc <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    800052d6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800052da:	0149da63          	bge	s3,s4,800052ee <filewrite+0xf0>
      int n1 = n - i;
    800052de:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800052e2:	0004879b          	sext.w	a5,s1
    800052e6:	f8fbdce3          	bge	s7,a5,8000527e <filewrite+0x80>
    800052ea:	84e2                	mv	s1,s8
    800052ec:	bf49                	j	8000527e <filewrite+0x80>
    800052ee:	74e2                	ld	s1,56(sp)
    800052f0:	6ae2                	ld	s5,24(sp)
    800052f2:	6ba2                	ld	s7,8(sp)
    800052f4:	6c02                	ld	s8,0(sp)
    800052f6:	a039                	j	80005304 <filewrite+0x106>
    int i = 0;
    800052f8:	4981                	li	s3,0
    800052fa:	a029                	j	80005304 <filewrite+0x106>
    800052fc:	74e2                	ld	s1,56(sp)
    800052fe:	6ae2                	ld	s5,24(sp)
    80005300:	6ba2                	ld	s7,8(sp)
    80005302:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80005304:	033a1e63          	bne	s4,s3,80005340 <filewrite+0x142>
    80005308:	8552                	mv	a0,s4
    8000530a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000530c:	60a6                	ld	ra,72(sp)
    8000530e:	6406                	ld	s0,64(sp)
    80005310:	7942                	ld	s2,48(sp)
    80005312:	7a02                	ld	s4,32(sp)
    80005314:	6b42                	ld	s6,16(sp)
    80005316:	6161                	addi	sp,sp,80
    80005318:	8082                	ret
    8000531a:	fc26                	sd	s1,56(sp)
    8000531c:	f44e                	sd	s3,40(sp)
    8000531e:	ec56                	sd	s5,24(sp)
    80005320:	e45e                	sd	s7,8(sp)
    80005322:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80005324:	00003517          	auipc	a0,0x3
    80005328:	42450513          	addi	a0,a0,1060 # 80008748 <__func__.1+0x740>
    8000532c:	ffffb097          	auipc	ra,0xffffb
    80005330:	234080e7          	jalr	564(ra) # 80000560 <panic>
    return -1;
    80005334:	557d                	li	a0,-1
}
    80005336:	8082                	ret
      return -1;
    80005338:	557d                	li	a0,-1
    8000533a:	bfc9                	j	8000530c <filewrite+0x10e>
    8000533c:	557d                	li	a0,-1
    8000533e:	b7f9                	j	8000530c <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80005340:	557d                	li	a0,-1
    80005342:	79a2                	ld	s3,40(sp)
    80005344:	b7e1                	j	8000530c <filewrite+0x10e>

0000000080005346 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005346:	7179                	addi	sp,sp,-48
    80005348:	f406                	sd	ra,40(sp)
    8000534a:	f022                	sd	s0,32(sp)
    8000534c:	ec26                	sd	s1,24(sp)
    8000534e:	e052                	sd	s4,0(sp)
    80005350:	1800                	addi	s0,sp,48
    80005352:	84aa                	mv	s1,a0
    80005354:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005356:	0005b023          	sd	zero,0(a1)
    8000535a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000535e:	00000097          	auipc	ra,0x0
    80005362:	bbe080e7          	jalr	-1090(ra) # 80004f1c <filealloc>
    80005366:	e088                	sd	a0,0(s1)
    80005368:	cd49                	beqz	a0,80005402 <pipealloc+0xbc>
    8000536a:	00000097          	auipc	ra,0x0
    8000536e:	bb2080e7          	jalr	-1102(ra) # 80004f1c <filealloc>
    80005372:	00aa3023          	sd	a0,0(s4)
    80005376:	c141                	beqz	a0,800053f6 <pipealloc+0xb0>
    80005378:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000537a:	ffffc097          	auipc	ra,0xffffc
    8000537e:	90c080e7          	jalr	-1780(ra) # 80000c86 <kalloc>
    80005382:	892a                	mv	s2,a0
    80005384:	c13d                	beqz	a0,800053ea <pipealloc+0xa4>
    80005386:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80005388:	4985                	li	s3,1
    8000538a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000538e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005392:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005396:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000539a:	00003597          	auipc	a1,0x3
    8000539e:	3be58593          	addi	a1,a1,958 # 80008758 <__func__.1+0x750>
    800053a2:	ffffc097          	auipc	ra,0xffffc
    800053a6:	b04080e7          	jalr	-1276(ra) # 80000ea6 <initlock>
  (*f0)->type = FD_PIPE;
    800053aa:	609c                	ld	a5,0(s1)
    800053ac:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800053b0:	609c                	ld	a5,0(s1)
    800053b2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800053b6:	609c                	ld	a5,0(s1)
    800053b8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800053bc:	609c                	ld	a5,0(s1)
    800053be:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800053c2:	000a3783          	ld	a5,0(s4)
    800053c6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800053ca:	000a3783          	ld	a5,0(s4)
    800053ce:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800053d2:	000a3783          	ld	a5,0(s4)
    800053d6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800053da:	000a3783          	ld	a5,0(s4)
    800053de:	0127b823          	sd	s2,16(a5)
  return 0;
    800053e2:	4501                	li	a0,0
    800053e4:	6942                	ld	s2,16(sp)
    800053e6:	69a2                	ld	s3,8(sp)
    800053e8:	a03d                	j	80005416 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800053ea:	6088                	ld	a0,0(s1)
    800053ec:	c119                	beqz	a0,800053f2 <pipealloc+0xac>
    800053ee:	6942                	ld	s2,16(sp)
    800053f0:	a029                	j	800053fa <pipealloc+0xb4>
    800053f2:	6942                	ld	s2,16(sp)
    800053f4:	a039                	j	80005402 <pipealloc+0xbc>
    800053f6:	6088                	ld	a0,0(s1)
    800053f8:	c50d                	beqz	a0,80005422 <pipealloc+0xdc>
    fileclose(*f0);
    800053fa:	00000097          	auipc	ra,0x0
    800053fe:	bde080e7          	jalr	-1058(ra) # 80004fd8 <fileclose>
  if(*f1)
    80005402:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005406:	557d                	li	a0,-1
  if(*f1)
    80005408:	c799                	beqz	a5,80005416 <pipealloc+0xd0>
    fileclose(*f1);
    8000540a:	853e                	mv	a0,a5
    8000540c:	00000097          	auipc	ra,0x0
    80005410:	bcc080e7          	jalr	-1076(ra) # 80004fd8 <fileclose>
  return -1;
    80005414:	557d                	li	a0,-1
}
    80005416:	70a2                	ld	ra,40(sp)
    80005418:	7402                	ld	s0,32(sp)
    8000541a:	64e2                	ld	s1,24(sp)
    8000541c:	6a02                	ld	s4,0(sp)
    8000541e:	6145                	addi	sp,sp,48
    80005420:	8082                	ret
  return -1;
    80005422:	557d                	li	a0,-1
    80005424:	bfcd                	j	80005416 <pipealloc+0xd0>

0000000080005426 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005426:	1101                	addi	sp,sp,-32
    80005428:	ec06                	sd	ra,24(sp)
    8000542a:	e822                	sd	s0,16(sp)
    8000542c:	e426                	sd	s1,8(sp)
    8000542e:	e04a                	sd	s2,0(sp)
    80005430:	1000                	addi	s0,sp,32
    80005432:	84aa                	mv	s1,a0
    80005434:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005436:	ffffc097          	auipc	ra,0xffffc
    8000543a:	b00080e7          	jalr	-1280(ra) # 80000f36 <acquire>
  if(writable){
    8000543e:	02090d63          	beqz	s2,80005478 <pipeclose+0x52>
    pi->writeopen = 0;
    80005442:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005446:	21848513          	addi	a0,s1,536
    8000544a:	ffffd097          	auipc	ra,0xffffd
    8000544e:	3a4080e7          	jalr	932(ra) # 800027ee <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005452:	2204b783          	ld	a5,544(s1)
    80005456:	eb95                	bnez	a5,8000548a <pipeclose+0x64>
    release(&pi->lock);
    80005458:	8526                	mv	a0,s1
    8000545a:	ffffc097          	auipc	ra,0xffffc
    8000545e:	b90080e7          	jalr	-1136(ra) # 80000fea <release>
    kfree((char*)pi);
    80005462:	8526                	mv	a0,s1
    80005464:	ffffb097          	auipc	ra,0xffffb
    80005468:	630080e7          	jalr	1584(ra) # 80000a94 <kfree>
  } else
    release(&pi->lock);
}
    8000546c:	60e2                	ld	ra,24(sp)
    8000546e:	6442                	ld	s0,16(sp)
    80005470:	64a2                	ld	s1,8(sp)
    80005472:	6902                	ld	s2,0(sp)
    80005474:	6105                	addi	sp,sp,32
    80005476:	8082                	ret
    pi->readopen = 0;
    80005478:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000547c:	21c48513          	addi	a0,s1,540
    80005480:	ffffd097          	auipc	ra,0xffffd
    80005484:	36e080e7          	jalr	878(ra) # 800027ee <wakeup>
    80005488:	b7e9                	j	80005452 <pipeclose+0x2c>
    release(&pi->lock);
    8000548a:	8526                	mv	a0,s1
    8000548c:	ffffc097          	auipc	ra,0xffffc
    80005490:	b5e080e7          	jalr	-1186(ra) # 80000fea <release>
}
    80005494:	bfe1                	j	8000546c <pipeclose+0x46>

0000000080005496 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005496:	711d                	addi	sp,sp,-96
    80005498:	ec86                	sd	ra,88(sp)
    8000549a:	e8a2                	sd	s0,80(sp)
    8000549c:	e4a6                	sd	s1,72(sp)
    8000549e:	e0ca                	sd	s2,64(sp)
    800054a0:	fc4e                	sd	s3,56(sp)
    800054a2:	f852                	sd	s4,48(sp)
    800054a4:	f456                	sd	s5,40(sp)
    800054a6:	1080                	addi	s0,sp,96
    800054a8:	84aa                	mv	s1,a0
    800054aa:	8aae                	mv	s5,a1
    800054ac:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800054ae:	ffffd097          	auipc	ra,0xffffd
    800054b2:	b2a080e7          	jalr	-1238(ra) # 80001fd8 <myproc>
    800054b6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800054b8:	8526                	mv	a0,s1
    800054ba:	ffffc097          	auipc	ra,0xffffc
    800054be:	a7c080e7          	jalr	-1412(ra) # 80000f36 <acquire>
  while(i < n){
    800054c2:	0d405863          	blez	s4,80005592 <pipewrite+0xfc>
    800054c6:	f05a                	sd	s6,32(sp)
    800054c8:	ec5e                	sd	s7,24(sp)
    800054ca:	e862                	sd	s8,16(sp)
  int i = 0;
    800054cc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800054ce:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800054d0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800054d4:	21c48b93          	addi	s7,s1,540
    800054d8:	a089                	j	8000551a <pipewrite+0x84>
      release(&pi->lock);
    800054da:	8526                	mv	a0,s1
    800054dc:	ffffc097          	auipc	ra,0xffffc
    800054e0:	b0e080e7          	jalr	-1266(ra) # 80000fea <release>
      return -1;
    800054e4:	597d                	li	s2,-1
    800054e6:	7b02                	ld	s6,32(sp)
    800054e8:	6be2                	ld	s7,24(sp)
    800054ea:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800054ec:	854a                	mv	a0,s2
    800054ee:	60e6                	ld	ra,88(sp)
    800054f0:	6446                	ld	s0,80(sp)
    800054f2:	64a6                	ld	s1,72(sp)
    800054f4:	6906                	ld	s2,64(sp)
    800054f6:	79e2                	ld	s3,56(sp)
    800054f8:	7a42                	ld	s4,48(sp)
    800054fa:	7aa2                	ld	s5,40(sp)
    800054fc:	6125                	addi	sp,sp,96
    800054fe:	8082                	ret
      wakeup(&pi->nread);
    80005500:	8562                	mv	a0,s8
    80005502:	ffffd097          	auipc	ra,0xffffd
    80005506:	2ec080e7          	jalr	748(ra) # 800027ee <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000550a:	85a6                	mv	a1,s1
    8000550c:	855e                	mv	a0,s7
    8000550e:	ffffd097          	auipc	ra,0xffffd
    80005512:	27c080e7          	jalr	636(ra) # 8000278a <sleep>
  while(i < n){
    80005516:	05495f63          	bge	s2,s4,80005574 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    8000551a:	2204a783          	lw	a5,544(s1)
    8000551e:	dfd5                	beqz	a5,800054da <pipewrite+0x44>
    80005520:	854e                	mv	a0,s3
    80005522:	ffffd097          	auipc	ra,0xffffd
    80005526:	510080e7          	jalr	1296(ra) # 80002a32 <killed>
    8000552a:	f945                	bnez	a0,800054da <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000552c:	2184a783          	lw	a5,536(s1)
    80005530:	21c4a703          	lw	a4,540(s1)
    80005534:	2007879b          	addiw	a5,a5,512
    80005538:	fcf704e3          	beq	a4,a5,80005500 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000553c:	4685                	li	a3,1
    8000553e:	01590633          	add	a2,s2,s5
    80005542:	faf40593          	addi	a1,s0,-81
    80005546:	0509b503          	ld	a0,80(s3)
    8000554a:	ffffc097          	auipc	ra,0xffffc
    8000554e:	528080e7          	jalr	1320(ra) # 80001a72 <copyin>
    80005552:	05650263          	beq	a0,s6,80005596 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005556:	21c4a783          	lw	a5,540(s1)
    8000555a:	0017871b          	addiw	a4,a5,1
    8000555e:	20e4ae23          	sw	a4,540(s1)
    80005562:	1ff7f793          	andi	a5,a5,511
    80005566:	97a6                	add	a5,a5,s1
    80005568:	faf44703          	lbu	a4,-81(s0)
    8000556c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005570:	2905                	addiw	s2,s2,1
    80005572:	b755                	j	80005516 <pipewrite+0x80>
    80005574:	7b02                	ld	s6,32(sp)
    80005576:	6be2                	ld	s7,24(sp)
    80005578:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000557a:	21848513          	addi	a0,s1,536
    8000557e:	ffffd097          	auipc	ra,0xffffd
    80005582:	270080e7          	jalr	624(ra) # 800027ee <wakeup>
  release(&pi->lock);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffc097          	auipc	ra,0xffffc
    8000558c:	a62080e7          	jalr	-1438(ra) # 80000fea <release>
  return i;
    80005590:	bfb1                	j	800054ec <pipewrite+0x56>
  int i = 0;
    80005592:	4901                	li	s2,0
    80005594:	b7dd                	j	8000557a <pipewrite+0xe4>
    80005596:	7b02                	ld	s6,32(sp)
    80005598:	6be2                	ld	s7,24(sp)
    8000559a:	6c42                	ld	s8,16(sp)
    8000559c:	bff9                	j	8000557a <pipewrite+0xe4>

000000008000559e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000559e:	715d                	addi	sp,sp,-80
    800055a0:	e486                	sd	ra,72(sp)
    800055a2:	e0a2                	sd	s0,64(sp)
    800055a4:	fc26                	sd	s1,56(sp)
    800055a6:	f84a                	sd	s2,48(sp)
    800055a8:	f44e                	sd	s3,40(sp)
    800055aa:	f052                	sd	s4,32(sp)
    800055ac:	ec56                	sd	s5,24(sp)
    800055ae:	0880                	addi	s0,sp,80
    800055b0:	84aa                	mv	s1,a0
    800055b2:	892e                	mv	s2,a1
    800055b4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800055b6:	ffffd097          	auipc	ra,0xffffd
    800055ba:	a22080e7          	jalr	-1502(ra) # 80001fd8 <myproc>
    800055be:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffc097          	auipc	ra,0xffffc
    800055c6:	974080e7          	jalr	-1676(ra) # 80000f36 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055ca:	2184a703          	lw	a4,536(s1)
    800055ce:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055d2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055d6:	02f71963          	bne	a4,a5,80005608 <piperead+0x6a>
    800055da:	2244a783          	lw	a5,548(s1)
    800055de:	cf95                	beqz	a5,8000561a <piperead+0x7c>
    if(killed(pr)){
    800055e0:	8552                	mv	a0,s4
    800055e2:	ffffd097          	auipc	ra,0xffffd
    800055e6:	450080e7          	jalr	1104(ra) # 80002a32 <killed>
    800055ea:	e10d                	bnez	a0,8000560c <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055ec:	85a6                	mv	a1,s1
    800055ee:	854e                	mv	a0,s3
    800055f0:	ffffd097          	auipc	ra,0xffffd
    800055f4:	19a080e7          	jalr	410(ra) # 8000278a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055f8:	2184a703          	lw	a4,536(s1)
    800055fc:	21c4a783          	lw	a5,540(s1)
    80005600:	fcf70de3          	beq	a4,a5,800055da <piperead+0x3c>
    80005604:	e85a                	sd	s6,16(sp)
    80005606:	a819                	j	8000561c <piperead+0x7e>
    80005608:	e85a                	sd	s6,16(sp)
    8000560a:	a809                	j	8000561c <piperead+0x7e>
      release(&pi->lock);
    8000560c:	8526                	mv	a0,s1
    8000560e:	ffffc097          	auipc	ra,0xffffc
    80005612:	9dc080e7          	jalr	-1572(ra) # 80000fea <release>
      return -1;
    80005616:	59fd                	li	s3,-1
    80005618:	a0a5                	j	80005680 <piperead+0xe2>
    8000561a:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000561c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000561e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005620:	05505463          	blez	s5,80005668 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80005624:	2184a783          	lw	a5,536(s1)
    80005628:	21c4a703          	lw	a4,540(s1)
    8000562c:	02f70e63          	beq	a4,a5,80005668 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005630:	0017871b          	addiw	a4,a5,1
    80005634:	20e4ac23          	sw	a4,536(s1)
    80005638:	1ff7f793          	andi	a5,a5,511
    8000563c:	97a6                	add	a5,a5,s1
    8000563e:	0187c783          	lbu	a5,24(a5)
    80005642:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005646:	4685                	li	a3,1
    80005648:	fbf40613          	addi	a2,s0,-65
    8000564c:	85ca                	mv	a1,s2
    8000564e:	050a3503          	ld	a0,80(s4)
    80005652:	ffffc097          	auipc	ra,0xffffc
    80005656:	394080e7          	jalr	916(ra) # 800019e6 <copyout>
    8000565a:	01650763          	beq	a0,s6,80005668 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000565e:	2985                	addiw	s3,s3,1
    80005660:	0905                	addi	s2,s2,1
    80005662:	fd3a91e3          	bne	s5,s3,80005624 <piperead+0x86>
    80005666:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005668:	21c48513          	addi	a0,s1,540
    8000566c:	ffffd097          	auipc	ra,0xffffd
    80005670:	182080e7          	jalr	386(ra) # 800027ee <wakeup>
  release(&pi->lock);
    80005674:	8526                	mv	a0,s1
    80005676:	ffffc097          	auipc	ra,0xffffc
    8000567a:	974080e7          	jalr	-1676(ra) # 80000fea <release>
    8000567e:	6b42                	ld	s6,16(sp)
  return i;
}
    80005680:	854e                	mv	a0,s3
    80005682:	60a6                	ld	ra,72(sp)
    80005684:	6406                	ld	s0,64(sp)
    80005686:	74e2                	ld	s1,56(sp)
    80005688:	7942                	ld	s2,48(sp)
    8000568a:	79a2                	ld	s3,40(sp)
    8000568c:	7a02                	ld	s4,32(sp)
    8000568e:	6ae2                	ld	s5,24(sp)
    80005690:	6161                	addi	sp,sp,80
    80005692:	8082                	ret

0000000080005694 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005694:	1141                	addi	sp,sp,-16
    80005696:	e422                	sd	s0,8(sp)
    80005698:	0800                	addi	s0,sp,16
    8000569a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000569c:	8905                	andi	a0,a0,1
    8000569e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800056a0:	8b89                	andi	a5,a5,2
    800056a2:	c399                	beqz	a5,800056a8 <flags2perm+0x14>
      perm |= PTE_W;
    800056a4:	00456513          	ori	a0,a0,4
    return perm;
}
    800056a8:	6422                	ld	s0,8(sp)
    800056aa:	0141                	addi	sp,sp,16
    800056ac:	8082                	ret

00000000800056ae <exec>:

int
exec(char *path, char **argv)
{
    800056ae:	df010113          	addi	sp,sp,-528
    800056b2:	20113423          	sd	ra,520(sp)
    800056b6:	20813023          	sd	s0,512(sp)
    800056ba:	ffa6                	sd	s1,504(sp)
    800056bc:	fbca                	sd	s2,496(sp)
    800056be:	0c00                	addi	s0,sp,528
    800056c0:	892a                	mv	s2,a0
    800056c2:	dea43c23          	sd	a0,-520(s0)
    800056c6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800056ca:	ffffd097          	auipc	ra,0xffffd
    800056ce:	90e080e7          	jalr	-1778(ra) # 80001fd8 <myproc>
    800056d2:	84aa                	mv	s1,a0

  begin_op();
    800056d4:	fffff097          	auipc	ra,0xfffff
    800056d8:	43a080e7          	jalr	1082(ra) # 80004b0e <begin_op>

  if((ip = namei(path)) == 0){
    800056dc:	854a                	mv	a0,s2
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	230080e7          	jalr	560(ra) # 8000490e <namei>
    800056e6:	c135                	beqz	a0,8000574a <exec+0x9c>
    800056e8:	f3d2                	sd	s4,480(sp)
    800056ea:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	a54080e7          	jalr	-1452(ra) # 80004140 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800056f4:	04000713          	li	a4,64
    800056f8:	4681                	li	a3,0
    800056fa:	e5040613          	addi	a2,s0,-432
    800056fe:	4581                	li	a1,0
    80005700:	8552                	mv	a0,s4
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	cf6080e7          	jalr	-778(ra) # 800043f8 <readi>
    8000570a:	04000793          	li	a5,64
    8000570e:	00f51a63          	bne	a0,a5,80005722 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005712:	e5042703          	lw	a4,-432(s0)
    80005716:	464c47b7          	lui	a5,0x464c4
    8000571a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000571e:	02f70c63          	beq	a4,a5,80005756 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005722:	8552                	mv	a0,s4
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	c82080e7          	jalr	-894(ra) # 800043a6 <iunlockput>
    end_op();
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	45c080e7          	jalr	1116(ra) # 80004b88 <end_op>
  }
  return -1;
    80005734:	557d                	li	a0,-1
    80005736:	7a1e                	ld	s4,480(sp)
}
    80005738:	20813083          	ld	ra,520(sp)
    8000573c:	20013403          	ld	s0,512(sp)
    80005740:	74fe                	ld	s1,504(sp)
    80005742:	795e                	ld	s2,496(sp)
    80005744:	21010113          	addi	sp,sp,528
    80005748:	8082                	ret
    end_op();
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	43e080e7          	jalr	1086(ra) # 80004b88 <end_op>
    return -1;
    80005752:	557d                	li	a0,-1
    80005754:	b7d5                	j	80005738 <exec+0x8a>
    80005756:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffd097          	auipc	ra,0xffffd
    8000575e:	942080e7          	jalr	-1726(ra) # 8000209c <proc_pagetable>
    80005762:	8b2a                	mv	s6,a0
    80005764:	30050f63          	beqz	a0,80005a82 <exec+0x3d4>
    80005768:	f7ce                	sd	s3,488(sp)
    8000576a:	efd6                	sd	s5,472(sp)
    8000576c:	e7de                	sd	s7,456(sp)
    8000576e:	e3e2                	sd	s8,448(sp)
    80005770:	ff66                	sd	s9,440(sp)
    80005772:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005774:	e7042d03          	lw	s10,-400(s0)
    80005778:	e8845783          	lhu	a5,-376(s0)
    8000577c:	14078d63          	beqz	a5,800058d6 <exec+0x228>
    80005780:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005782:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005784:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005786:	6c85                	lui	s9,0x1
    80005788:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000578c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005790:	6a85                	lui	s5,0x1
    80005792:	a0b5                	j	800057fe <exec+0x150>
      panic("loadseg: address should exist");
    80005794:	00003517          	auipc	a0,0x3
    80005798:	fcc50513          	addi	a0,a0,-52 # 80008760 <__func__.1+0x758>
    8000579c:	ffffb097          	auipc	ra,0xffffb
    800057a0:	dc4080e7          	jalr	-572(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    800057a4:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800057a6:	8726                	mv	a4,s1
    800057a8:	012c06bb          	addw	a3,s8,s2
    800057ac:	4581                	li	a1,0
    800057ae:	8552                	mv	a0,s4
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	c48080e7          	jalr	-952(ra) # 800043f8 <readi>
    800057b8:	2501                	sext.w	a0,a0
    800057ba:	28a49863          	bne	s1,a0,80005a4a <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    800057be:	012a893b          	addw	s2,s5,s2
    800057c2:	03397563          	bgeu	s2,s3,800057ec <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    800057c6:	02091593          	slli	a1,s2,0x20
    800057ca:	9181                	srli	a1,a1,0x20
    800057cc:	95de                	add	a1,a1,s7
    800057ce:	855a                	mv	a0,s6
    800057d0:	ffffc097          	auipc	ra,0xffffc
    800057d4:	be4080e7          	jalr	-1052(ra) # 800013b4 <walkaddr>
    800057d8:	862a                	mv	a2,a0
    if(pa == 0)
    800057da:	dd4d                	beqz	a0,80005794 <exec+0xe6>
    if(sz - i < PGSIZE)
    800057dc:	412984bb          	subw	s1,s3,s2
    800057e0:	0004879b          	sext.w	a5,s1
    800057e4:	fcfcf0e3          	bgeu	s9,a5,800057a4 <exec+0xf6>
    800057e8:	84d6                	mv	s1,s5
    800057ea:	bf6d                	j	800057a4 <exec+0xf6>
    sz = sz1;
    800057ec:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057f0:	2d85                	addiw	s11,s11,1
    800057f2:	038d0d1b          	addiw	s10,s10,56
    800057f6:	e8845783          	lhu	a5,-376(s0)
    800057fa:	08fdd663          	bge	s11,a5,80005886 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057fe:	2d01                	sext.w	s10,s10
    80005800:	03800713          	li	a4,56
    80005804:	86ea                	mv	a3,s10
    80005806:	e1840613          	addi	a2,s0,-488
    8000580a:	4581                	li	a1,0
    8000580c:	8552                	mv	a0,s4
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	bea080e7          	jalr	-1046(ra) # 800043f8 <readi>
    80005816:	03800793          	li	a5,56
    8000581a:	20f51063          	bne	a0,a5,80005a1a <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    8000581e:	e1842783          	lw	a5,-488(s0)
    80005822:	4705                	li	a4,1
    80005824:	fce796e3          	bne	a5,a4,800057f0 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80005828:	e4043483          	ld	s1,-448(s0)
    8000582c:	e3843783          	ld	a5,-456(s0)
    80005830:	1ef4e963          	bltu	s1,a5,80005a22 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005834:	e2843783          	ld	a5,-472(s0)
    80005838:	94be                	add	s1,s1,a5
    8000583a:	1ef4e863          	bltu	s1,a5,80005a2a <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    8000583e:	df043703          	ld	a4,-528(s0)
    80005842:	8ff9                	and	a5,a5,a4
    80005844:	1e079763          	bnez	a5,80005a32 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005848:	e1c42503          	lw	a0,-484(s0)
    8000584c:	00000097          	auipc	ra,0x0
    80005850:	e48080e7          	jalr	-440(ra) # 80005694 <flags2perm>
    80005854:	86aa                	mv	a3,a0
    80005856:	8626                	mv	a2,s1
    80005858:	85ca                	mv	a1,s2
    8000585a:	855a                	mv	a0,s6
    8000585c:	ffffc097          	auipc	ra,0xffffc
    80005860:	f1c080e7          	jalr	-228(ra) # 80001778 <uvmalloc>
    80005864:	e0a43423          	sd	a0,-504(s0)
    80005868:	1c050963          	beqz	a0,80005a3a <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000586c:	e2843b83          	ld	s7,-472(s0)
    80005870:	e2042c03          	lw	s8,-480(s0)
    80005874:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005878:	00098463          	beqz	s3,80005880 <exec+0x1d2>
    8000587c:	4901                	li	s2,0
    8000587e:	b7a1                	j	800057c6 <exec+0x118>
    sz = sz1;
    80005880:	e0843903          	ld	s2,-504(s0)
    80005884:	b7b5                	j	800057f0 <exec+0x142>
    80005886:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005888:	8552                	mv	a0,s4
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	b1c080e7          	jalr	-1252(ra) # 800043a6 <iunlockput>
  end_op();
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	2f6080e7          	jalr	758(ra) # 80004b88 <end_op>
  p = myproc();
    8000589a:	ffffc097          	auipc	ra,0xffffc
    8000589e:	73e080e7          	jalr	1854(ra) # 80001fd8 <myproc>
    800058a2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800058a4:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800058a8:	6985                	lui	s3,0x1
    800058aa:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800058ac:	99ca                	add	s3,s3,s2
    800058ae:	77fd                	lui	a5,0xfffff
    800058b0:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800058b4:	4691                	li	a3,4
    800058b6:	6609                	lui	a2,0x2
    800058b8:	964e                	add	a2,a2,s3
    800058ba:	85ce                	mv	a1,s3
    800058bc:	855a                	mv	a0,s6
    800058be:	ffffc097          	auipc	ra,0xffffc
    800058c2:	eba080e7          	jalr	-326(ra) # 80001778 <uvmalloc>
    800058c6:	892a                	mv	s2,a0
    800058c8:	e0a43423          	sd	a0,-504(s0)
    800058cc:	e519                	bnez	a0,800058da <exec+0x22c>
  if(pagetable)
    800058ce:	e1343423          	sd	s3,-504(s0)
    800058d2:	4a01                	li	s4,0
    800058d4:	aaa5                	j	80005a4c <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800058d6:	4901                	li	s2,0
    800058d8:	bf45                	j	80005888 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    800058da:	75f9                	lui	a1,0xffffe
    800058dc:	95aa                	add	a1,a1,a0
    800058de:	855a                	mv	a0,s6
    800058e0:	ffffc097          	auipc	ra,0xffffc
    800058e4:	0d4080e7          	jalr	212(ra) # 800019b4 <uvmclear>
  stackbase = sp - PGSIZE;
    800058e8:	7bfd                	lui	s7,0xfffff
    800058ea:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800058ec:	e0043783          	ld	a5,-512(s0)
    800058f0:	6388                	ld	a0,0(a5)
    800058f2:	c52d                	beqz	a0,8000595c <exec+0x2ae>
    800058f4:	e9040993          	addi	s3,s0,-368
    800058f8:	f9040c13          	addi	s8,s0,-112
    800058fc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800058fe:	ffffc097          	auipc	ra,0xffffc
    80005902:	8a8080e7          	jalr	-1880(ra) # 800011a6 <strlen>
    80005906:	0015079b          	addiw	a5,a0,1
    8000590a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000590e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005912:	13796863          	bltu	s2,s7,80005a42 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005916:	e0043d03          	ld	s10,-512(s0)
    8000591a:	000d3a03          	ld	s4,0(s10)
    8000591e:	8552                	mv	a0,s4
    80005920:	ffffc097          	auipc	ra,0xffffc
    80005924:	886080e7          	jalr	-1914(ra) # 800011a6 <strlen>
    80005928:	0015069b          	addiw	a3,a0,1
    8000592c:	8652                	mv	a2,s4
    8000592e:	85ca                	mv	a1,s2
    80005930:	855a                	mv	a0,s6
    80005932:	ffffc097          	auipc	ra,0xffffc
    80005936:	0b4080e7          	jalr	180(ra) # 800019e6 <copyout>
    8000593a:	10054663          	bltz	a0,80005a46 <exec+0x398>
    ustack[argc] = sp;
    8000593e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005942:	0485                	addi	s1,s1,1
    80005944:	008d0793          	addi	a5,s10,8
    80005948:	e0f43023          	sd	a5,-512(s0)
    8000594c:	008d3503          	ld	a0,8(s10)
    80005950:	c909                	beqz	a0,80005962 <exec+0x2b4>
    if(argc >= MAXARG)
    80005952:	09a1                	addi	s3,s3,8
    80005954:	fb8995e3          	bne	s3,s8,800058fe <exec+0x250>
  ip = 0;
    80005958:	4a01                	li	s4,0
    8000595a:	a8cd                	j	80005a4c <exec+0x39e>
  sp = sz;
    8000595c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005960:	4481                	li	s1,0
  ustack[argc] = 0;
    80005962:	00349793          	slli	a5,s1,0x3
    80005966:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd2398>
    8000596a:	97a2                	add	a5,a5,s0
    8000596c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005970:	00148693          	addi	a3,s1,1
    80005974:	068e                	slli	a3,a3,0x3
    80005976:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000597a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000597e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005982:	f57966e3          	bltu	s2,s7,800058ce <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005986:	e9040613          	addi	a2,s0,-368
    8000598a:	85ca                	mv	a1,s2
    8000598c:	855a                	mv	a0,s6
    8000598e:	ffffc097          	auipc	ra,0xffffc
    80005992:	058080e7          	jalr	88(ra) # 800019e6 <copyout>
    80005996:	0e054863          	bltz	a0,80005a86 <exec+0x3d8>
  p->trapframe->a1 = sp;
    8000599a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000599e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800059a2:	df843783          	ld	a5,-520(s0)
    800059a6:	0007c703          	lbu	a4,0(a5)
    800059aa:	cf11                	beqz	a4,800059c6 <exec+0x318>
    800059ac:	0785                	addi	a5,a5,1
    if(*s == '/')
    800059ae:	02f00693          	li	a3,47
    800059b2:	a039                	j	800059c0 <exec+0x312>
      last = s+1;
    800059b4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800059b8:	0785                	addi	a5,a5,1
    800059ba:	fff7c703          	lbu	a4,-1(a5)
    800059be:	c701                	beqz	a4,800059c6 <exec+0x318>
    if(*s == '/')
    800059c0:	fed71ce3          	bne	a4,a3,800059b8 <exec+0x30a>
    800059c4:	bfc5                	j	800059b4 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    800059c6:	4641                	li	a2,16
    800059c8:	df843583          	ld	a1,-520(s0)
    800059cc:	158a8513          	addi	a0,s5,344
    800059d0:	ffffb097          	auipc	ra,0xffffb
    800059d4:	7a4080e7          	jalr	1956(ra) # 80001174 <safestrcpy>
  oldpagetable = p->pagetable;
    800059d8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800059dc:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800059e0:	e0843783          	ld	a5,-504(s0)
    800059e4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800059e8:	058ab783          	ld	a5,88(s5)
    800059ec:	e6843703          	ld	a4,-408(s0)
    800059f0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800059f2:	058ab783          	ld	a5,88(s5)
    800059f6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800059fa:	85e6                	mv	a1,s9
    800059fc:	ffffc097          	auipc	ra,0xffffc
    80005a00:	73c080e7          	jalr	1852(ra) # 80002138 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005a04:	0004851b          	sext.w	a0,s1
    80005a08:	79be                	ld	s3,488(sp)
    80005a0a:	7a1e                	ld	s4,480(sp)
    80005a0c:	6afe                	ld	s5,472(sp)
    80005a0e:	6b5e                	ld	s6,464(sp)
    80005a10:	6bbe                	ld	s7,456(sp)
    80005a12:	6c1e                	ld	s8,448(sp)
    80005a14:	7cfa                	ld	s9,440(sp)
    80005a16:	7d5a                	ld	s10,432(sp)
    80005a18:	b305                	j	80005738 <exec+0x8a>
    80005a1a:	e1243423          	sd	s2,-504(s0)
    80005a1e:	7dba                	ld	s11,424(sp)
    80005a20:	a035                	j	80005a4c <exec+0x39e>
    80005a22:	e1243423          	sd	s2,-504(s0)
    80005a26:	7dba                	ld	s11,424(sp)
    80005a28:	a015                	j	80005a4c <exec+0x39e>
    80005a2a:	e1243423          	sd	s2,-504(s0)
    80005a2e:	7dba                	ld	s11,424(sp)
    80005a30:	a831                	j	80005a4c <exec+0x39e>
    80005a32:	e1243423          	sd	s2,-504(s0)
    80005a36:	7dba                	ld	s11,424(sp)
    80005a38:	a811                	j	80005a4c <exec+0x39e>
    80005a3a:	e1243423          	sd	s2,-504(s0)
    80005a3e:	7dba                	ld	s11,424(sp)
    80005a40:	a031                	j	80005a4c <exec+0x39e>
  ip = 0;
    80005a42:	4a01                	li	s4,0
    80005a44:	a021                	j	80005a4c <exec+0x39e>
    80005a46:	4a01                	li	s4,0
  if(pagetable)
    80005a48:	a011                	j	80005a4c <exec+0x39e>
    80005a4a:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005a4c:	e0843583          	ld	a1,-504(s0)
    80005a50:	855a                	mv	a0,s6
    80005a52:	ffffc097          	auipc	ra,0xffffc
    80005a56:	6e6080e7          	jalr	1766(ra) # 80002138 <proc_freepagetable>
  return -1;
    80005a5a:	557d                	li	a0,-1
  if(ip){
    80005a5c:	000a1b63          	bnez	s4,80005a72 <exec+0x3c4>
    80005a60:	79be                	ld	s3,488(sp)
    80005a62:	7a1e                	ld	s4,480(sp)
    80005a64:	6afe                	ld	s5,472(sp)
    80005a66:	6b5e                	ld	s6,464(sp)
    80005a68:	6bbe                	ld	s7,456(sp)
    80005a6a:	6c1e                	ld	s8,448(sp)
    80005a6c:	7cfa                	ld	s9,440(sp)
    80005a6e:	7d5a                	ld	s10,432(sp)
    80005a70:	b1e1                	j	80005738 <exec+0x8a>
    80005a72:	79be                	ld	s3,488(sp)
    80005a74:	6afe                	ld	s5,472(sp)
    80005a76:	6b5e                	ld	s6,464(sp)
    80005a78:	6bbe                	ld	s7,456(sp)
    80005a7a:	6c1e                	ld	s8,448(sp)
    80005a7c:	7cfa                	ld	s9,440(sp)
    80005a7e:	7d5a                	ld	s10,432(sp)
    80005a80:	b14d                	j	80005722 <exec+0x74>
    80005a82:	6b5e                	ld	s6,464(sp)
    80005a84:	b979                	j	80005722 <exec+0x74>
  sz = sz1;
    80005a86:	e0843983          	ld	s3,-504(s0)
    80005a8a:	b591                	j	800058ce <exec+0x220>

0000000080005a8c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a8c:	7179                	addi	sp,sp,-48
    80005a8e:	f406                	sd	ra,40(sp)
    80005a90:	f022                	sd	s0,32(sp)
    80005a92:	ec26                	sd	s1,24(sp)
    80005a94:	e84a                	sd	s2,16(sp)
    80005a96:	1800                	addi	s0,sp,48
    80005a98:	892e                	mv	s2,a1
    80005a9a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005a9c:	fdc40593          	addi	a1,s0,-36
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	986080e7          	jalr	-1658(ra) # 80003426 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005aa8:	fdc42703          	lw	a4,-36(s0)
    80005aac:	47bd                	li	a5,15
    80005aae:	02e7eb63          	bltu	a5,a4,80005ae4 <argfd+0x58>
    80005ab2:	ffffc097          	auipc	ra,0xffffc
    80005ab6:	526080e7          	jalr	1318(ra) # 80001fd8 <myproc>
    80005aba:	fdc42703          	lw	a4,-36(s0)
    80005abe:	01a70793          	addi	a5,a4,26
    80005ac2:	078e                	slli	a5,a5,0x3
    80005ac4:	953e                	add	a0,a0,a5
    80005ac6:	611c                	ld	a5,0(a0)
    80005ac8:	c385                	beqz	a5,80005ae8 <argfd+0x5c>
    return -1;
  if(pfd)
    80005aca:	00090463          	beqz	s2,80005ad2 <argfd+0x46>
    *pfd = fd;
    80005ace:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005ad2:	4501                	li	a0,0
  if(pf)
    80005ad4:	c091                	beqz	s1,80005ad8 <argfd+0x4c>
    *pf = f;
    80005ad6:	e09c                	sd	a5,0(s1)
}
    80005ad8:	70a2                	ld	ra,40(sp)
    80005ada:	7402                	ld	s0,32(sp)
    80005adc:	64e2                	ld	s1,24(sp)
    80005ade:	6942                	ld	s2,16(sp)
    80005ae0:	6145                	addi	sp,sp,48
    80005ae2:	8082                	ret
    return -1;
    80005ae4:	557d                	li	a0,-1
    80005ae6:	bfcd                	j	80005ad8 <argfd+0x4c>
    80005ae8:	557d                	li	a0,-1
    80005aea:	b7fd                	j	80005ad8 <argfd+0x4c>

0000000080005aec <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005aec:	1101                	addi	sp,sp,-32
    80005aee:	ec06                	sd	ra,24(sp)
    80005af0:	e822                	sd	s0,16(sp)
    80005af2:	e426                	sd	s1,8(sp)
    80005af4:	1000                	addi	s0,sp,32
    80005af6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005af8:	ffffc097          	auipc	ra,0xffffc
    80005afc:	4e0080e7          	jalr	1248(ra) # 80001fd8 <myproc>
    80005b00:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005b02:	0d050793          	addi	a5,a0,208
    80005b06:	4501                	li	a0,0
    80005b08:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005b0a:	6398                	ld	a4,0(a5)
    80005b0c:	cb19                	beqz	a4,80005b22 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005b0e:	2505                	addiw	a0,a0,1
    80005b10:	07a1                	addi	a5,a5,8
    80005b12:	fed51ce3          	bne	a0,a3,80005b0a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005b16:	557d                	li	a0,-1
}
    80005b18:	60e2                	ld	ra,24(sp)
    80005b1a:	6442                	ld	s0,16(sp)
    80005b1c:	64a2                	ld	s1,8(sp)
    80005b1e:	6105                	addi	sp,sp,32
    80005b20:	8082                	ret
      p->ofile[fd] = f;
    80005b22:	01a50793          	addi	a5,a0,26
    80005b26:	078e                	slli	a5,a5,0x3
    80005b28:	963e                	add	a2,a2,a5
    80005b2a:	e204                	sd	s1,0(a2)
      return fd;
    80005b2c:	b7f5                	j	80005b18 <fdalloc+0x2c>

0000000080005b2e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005b2e:	715d                	addi	sp,sp,-80
    80005b30:	e486                	sd	ra,72(sp)
    80005b32:	e0a2                	sd	s0,64(sp)
    80005b34:	fc26                	sd	s1,56(sp)
    80005b36:	f84a                	sd	s2,48(sp)
    80005b38:	f44e                	sd	s3,40(sp)
    80005b3a:	ec56                	sd	s5,24(sp)
    80005b3c:	e85a                	sd	s6,16(sp)
    80005b3e:	0880                	addi	s0,sp,80
    80005b40:	8b2e                	mv	s6,a1
    80005b42:	89b2                	mv	s3,a2
    80005b44:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005b46:	fb040593          	addi	a1,s0,-80
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	de2080e7          	jalr	-542(ra) # 8000492c <nameiparent>
    80005b52:	84aa                	mv	s1,a0
    80005b54:	14050e63          	beqz	a0,80005cb0 <create+0x182>
    return 0;

  ilock(dp);
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	5e8080e7          	jalr	1512(ra) # 80004140 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005b60:	4601                	li	a2,0
    80005b62:	fb040593          	addi	a1,s0,-80
    80005b66:	8526                	mv	a0,s1
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	ae4080e7          	jalr	-1308(ra) # 8000464c <dirlookup>
    80005b70:	8aaa                	mv	s5,a0
    80005b72:	c539                	beqz	a0,80005bc0 <create+0x92>
    iunlockput(dp);
    80005b74:	8526                	mv	a0,s1
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	830080e7          	jalr	-2000(ra) # 800043a6 <iunlockput>
    ilock(ip);
    80005b7e:	8556                	mv	a0,s5
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	5c0080e7          	jalr	1472(ra) # 80004140 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b88:	4789                	li	a5,2
    80005b8a:	02fb1463          	bne	s6,a5,80005bb2 <create+0x84>
    80005b8e:	044ad783          	lhu	a5,68(s5)
    80005b92:	37f9                	addiw	a5,a5,-2
    80005b94:	17c2                	slli	a5,a5,0x30
    80005b96:	93c1                	srli	a5,a5,0x30
    80005b98:	4705                	li	a4,1
    80005b9a:	00f76c63          	bltu	a4,a5,80005bb2 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b9e:	8556                	mv	a0,s5
    80005ba0:	60a6                	ld	ra,72(sp)
    80005ba2:	6406                	ld	s0,64(sp)
    80005ba4:	74e2                	ld	s1,56(sp)
    80005ba6:	7942                	ld	s2,48(sp)
    80005ba8:	79a2                	ld	s3,40(sp)
    80005baa:	6ae2                	ld	s5,24(sp)
    80005bac:	6b42                	ld	s6,16(sp)
    80005bae:	6161                	addi	sp,sp,80
    80005bb0:	8082                	ret
    iunlockput(ip);
    80005bb2:	8556                	mv	a0,s5
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	7f2080e7          	jalr	2034(ra) # 800043a6 <iunlockput>
    return 0;
    80005bbc:	4a81                	li	s5,0
    80005bbe:	b7c5                	j	80005b9e <create+0x70>
    80005bc0:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005bc2:	85da                	mv	a1,s6
    80005bc4:	4088                	lw	a0,0(s1)
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	3d6080e7          	jalr	982(ra) # 80003f9c <ialloc>
    80005bce:	8a2a                	mv	s4,a0
    80005bd0:	c531                	beqz	a0,80005c1c <create+0xee>
  ilock(ip);
    80005bd2:	ffffe097          	auipc	ra,0xffffe
    80005bd6:	56e080e7          	jalr	1390(ra) # 80004140 <ilock>
  ip->major = major;
    80005bda:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005bde:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005be2:	4905                	li	s2,1
    80005be4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005be8:	8552                	mv	a0,s4
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	48a080e7          	jalr	1162(ra) # 80004074 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005bf2:	032b0d63          	beq	s6,s2,80005c2c <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bf6:	004a2603          	lw	a2,4(s4)
    80005bfa:	fb040593          	addi	a1,s0,-80
    80005bfe:	8526                	mv	a0,s1
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	c5c080e7          	jalr	-932(ra) # 8000485c <dirlink>
    80005c08:	08054163          	bltz	a0,80005c8a <create+0x15c>
  iunlockput(dp);
    80005c0c:	8526                	mv	a0,s1
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	798080e7          	jalr	1944(ra) # 800043a6 <iunlockput>
  return ip;
    80005c16:	8ad2                	mv	s5,s4
    80005c18:	7a02                	ld	s4,32(sp)
    80005c1a:	b751                	j	80005b9e <create+0x70>
    iunlockput(dp);
    80005c1c:	8526                	mv	a0,s1
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	788080e7          	jalr	1928(ra) # 800043a6 <iunlockput>
    return 0;
    80005c26:	8ad2                	mv	s5,s4
    80005c28:	7a02                	ld	s4,32(sp)
    80005c2a:	bf95                	j	80005b9e <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005c2c:	004a2603          	lw	a2,4(s4)
    80005c30:	00003597          	auipc	a1,0x3
    80005c34:	b5058593          	addi	a1,a1,-1200 # 80008780 <__func__.1+0x778>
    80005c38:	8552                	mv	a0,s4
    80005c3a:	fffff097          	auipc	ra,0xfffff
    80005c3e:	c22080e7          	jalr	-990(ra) # 8000485c <dirlink>
    80005c42:	04054463          	bltz	a0,80005c8a <create+0x15c>
    80005c46:	40d0                	lw	a2,4(s1)
    80005c48:	00003597          	auipc	a1,0x3
    80005c4c:	b4058593          	addi	a1,a1,-1216 # 80008788 <__func__.1+0x780>
    80005c50:	8552                	mv	a0,s4
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	c0a080e7          	jalr	-1014(ra) # 8000485c <dirlink>
    80005c5a:	02054863          	bltz	a0,80005c8a <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005c5e:	004a2603          	lw	a2,4(s4)
    80005c62:	fb040593          	addi	a1,s0,-80
    80005c66:	8526                	mv	a0,s1
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	bf4080e7          	jalr	-1036(ra) # 8000485c <dirlink>
    80005c70:	00054d63          	bltz	a0,80005c8a <create+0x15c>
    dp->nlink++;  // for ".."
    80005c74:	04a4d783          	lhu	a5,74(s1)
    80005c78:	2785                	addiw	a5,a5,1
    80005c7a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c7e:	8526                	mv	a0,s1
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	3f4080e7          	jalr	1012(ra) # 80004074 <iupdate>
    80005c88:	b751                	j	80005c0c <create+0xde>
  ip->nlink = 0;
    80005c8a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005c8e:	8552                	mv	a0,s4
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	3e4080e7          	jalr	996(ra) # 80004074 <iupdate>
  iunlockput(ip);
    80005c98:	8552                	mv	a0,s4
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	70c080e7          	jalr	1804(ra) # 800043a6 <iunlockput>
  iunlockput(dp);
    80005ca2:	8526                	mv	a0,s1
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	702080e7          	jalr	1794(ra) # 800043a6 <iunlockput>
  return 0;
    80005cac:	7a02                	ld	s4,32(sp)
    80005cae:	bdc5                	j	80005b9e <create+0x70>
    return 0;
    80005cb0:	8aaa                	mv	s5,a0
    80005cb2:	b5f5                	j	80005b9e <create+0x70>

0000000080005cb4 <sys_dup>:
{
    80005cb4:	7179                	addi	sp,sp,-48
    80005cb6:	f406                	sd	ra,40(sp)
    80005cb8:	f022                	sd	s0,32(sp)
    80005cba:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005cbc:	fd840613          	addi	a2,s0,-40
    80005cc0:	4581                	li	a1,0
    80005cc2:	4501                	li	a0,0
    80005cc4:	00000097          	auipc	ra,0x0
    80005cc8:	dc8080e7          	jalr	-568(ra) # 80005a8c <argfd>
    return -1;
    80005ccc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005cce:	02054763          	bltz	a0,80005cfc <sys_dup+0x48>
    80005cd2:	ec26                	sd	s1,24(sp)
    80005cd4:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005cd6:	fd843903          	ld	s2,-40(s0)
    80005cda:	854a                	mv	a0,s2
    80005cdc:	00000097          	auipc	ra,0x0
    80005ce0:	e10080e7          	jalr	-496(ra) # 80005aec <fdalloc>
    80005ce4:	84aa                	mv	s1,a0
    return -1;
    80005ce6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005ce8:	00054f63          	bltz	a0,80005d06 <sys_dup+0x52>
  filedup(f);
    80005cec:	854a                	mv	a0,s2
    80005cee:	fffff097          	auipc	ra,0xfffff
    80005cf2:	298080e7          	jalr	664(ra) # 80004f86 <filedup>
  return fd;
    80005cf6:	87a6                	mv	a5,s1
    80005cf8:	64e2                	ld	s1,24(sp)
    80005cfa:	6942                	ld	s2,16(sp)
}
    80005cfc:	853e                	mv	a0,a5
    80005cfe:	70a2                	ld	ra,40(sp)
    80005d00:	7402                	ld	s0,32(sp)
    80005d02:	6145                	addi	sp,sp,48
    80005d04:	8082                	ret
    80005d06:	64e2                	ld	s1,24(sp)
    80005d08:	6942                	ld	s2,16(sp)
    80005d0a:	bfcd                	j	80005cfc <sys_dup+0x48>

0000000080005d0c <sys_read>:
{
    80005d0c:	7179                	addi	sp,sp,-48
    80005d0e:	f406                	sd	ra,40(sp)
    80005d10:	f022                	sd	s0,32(sp)
    80005d12:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005d14:	fd840593          	addi	a1,s0,-40
    80005d18:	4505                	li	a0,1
    80005d1a:	ffffd097          	auipc	ra,0xffffd
    80005d1e:	72c080e7          	jalr	1836(ra) # 80003446 <argaddr>
  argint(2, &n);
    80005d22:	fe440593          	addi	a1,s0,-28
    80005d26:	4509                	li	a0,2
    80005d28:	ffffd097          	auipc	ra,0xffffd
    80005d2c:	6fe080e7          	jalr	1790(ra) # 80003426 <argint>
  if(argfd(0, 0, &f) < 0)
    80005d30:	fe840613          	addi	a2,s0,-24
    80005d34:	4581                	li	a1,0
    80005d36:	4501                	li	a0,0
    80005d38:	00000097          	auipc	ra,0x0
    80005d3c:	d54080e7          	jalr	-684(ra) # 80005a8c <argfd>
    80005d40:	87aa                	mv	a5,a0
    return -1;
    80005d42:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d44:	0007cc63          	bltz	a5,80005d5c <sys_read+0x50>
  return fileread(f, p, n);
    80005d48:	fe442603          	lw	a2,-28(s0)
    80005d4c:	fd843583          	ld	a1,-40(s0)
    80005d50:	fe843503          	ld	a0,-24(s0)
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	3d8080e7          	jalr	984(ra) # 8000512c <fileread>
}
    80005d5c:	70a2                	ld	ra,40(sp)
    80005d5e:	7402                	ld	s0,32(sp)
    80005d60:	6145                	addi	sp,sp,48
    80005d62:	8082                	ret

0000000080005d64 <sys_write>:
{
    80005d64:	7179                	addi	sp,sp,-48
    80005d66:	f406                	sd	ra,40(sp)
    80005d68:	f022                	sd	s0,32(sp)
    80005d6a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005d6c:	fd840593          	addi	a1,s0,-40
    80005d70:	4505                	li	a0,1
    80005d72:	ffffd097          	auipc	ra,0xffffd
    80005d76:	6d4080e7          	jalr	1748(ra) # 80003446 <argaddr>
  argint(2, &n);
    80005d7a:	fe440593          	addi	a1,s0,-28
    80005d7e:	4509                	li	a0,2
    80005d80:	ffffd097          	auipc	ra,0xffffd
    80005d84:	6a6080e7          	jalr	1702(ra) # 80003426 <argint>
  if(argfd(0, 0, &f) < 0)
    80005d88:	fe840613          	addi	a2,s0,-24
    80005d8c:	4581                	li	a1,0
    80005d8e:	4501                	li	a0,0
    80005d90:	00000097          	auipc	ra,0x0
    80005d94:	cfc080e7          	jalr	-772(ra) # 80005a8c <argfd>
    80005d98:	87aa                	mv	a5,a0
    return -1;
    80005d9a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d9c:	0007cc63          	bltz	a5,80005db4 <sys_write+0x50>
  return filewrite(f, p, n);
    80005da0:	fe442603          	lw	a2,-28(s0)
    80005da4:	fd843583          	ld	a1,-40(s0)
    80005da8:	fe843503          	ld	a0,-24(s0)
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	452080e7          	jalr	1106(ra) # 800051fe <filewrite>
}
    80005db4:	70a2                	ld	ra,40(sp)
    80005db6:	7402                	ld	s0,32(sp)
    80005db8:	6145                	addi	sp,sp,48
    80005dba:	8082                	ret

0000000080005dbc <sys_close>:
{
    80005dbc:	1101                	addi	sp,sp,-32
    80005dbe:	ec06                	sd	ra,24(sp)
    80005dc0:	e822                	sd	s0,16(sp)
    80005dc2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005dc4:	fe040613          	addi	a2,s0,-32
    80005dc8:	fec40593          	addi	a1,s0,-20
    80005dcc:	4501                	li	a0,0
    80005dce:	00000097          	auipc	ra,0x0
    80005dd2:	cbe080e7          	jalr	-834(ra) # 80005a8c <argfd>
    return -1;
    80005dd6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005dd8:	02054463          	bltz	a0,80005e00 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ddc:	ffffc097          	auipc	ra,0xffffc
    80005de0:	1fc080e7          	jalr	508(ra) # 80001fd8 <myproc>
    80005de4:	fec42783          	lw	a5,-20(s0)
    80005de8:	07e9                	addi	a5,a5,26
    80005dea:	078e                	slli	a5,a5,0x3
    80005dec:	953e                	add	a0,a0,a5
    80005dee:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005df2:	fe043503          	ld	a0,-32(s0)
    80005df6:	fffff097          	auipc	ra,0xfffff
    80005dfa:	1e2080e7          	jalr	482(ra) # 80004fd8 <fileclose>
  return 0;
    80005dfe:	4781                	li	a5,0
}
    80005e00:	853e                	mv	a0,a5
    80005e02:	60e2                	ld	ra,24(sp)
    80005e04:	6442                	ld	s0,16(sp)
    80005e06:	6105                	addi	sp,sp,32
    80005e08:	8082                	ret

0000000080005e0a <sys_fstat>:
{
    80005e0a:	1101                	addi	sp,sp,-32
    80005e0c:	ec06                	sd	ra,24(sp)
    80005e0e:	e822                	sd	s0,16(sp)
    80005e10:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005e12:	fe040593          	addi	a1,s0,-32
    80005e16:	4505                	li	a0,1
    80005e18:	ffffd097          	auipc	ra,0xffffd
    80005e1c:	62e080e7          	jalr	1582(ra) # 80003446 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005e20:	fe840613          	addi	a2,s0,-24
    80005e24:	4581                	li	a1,0
    80005e26:	4501                	li	a0,0
    80005e28:	00000097          	auipc	ra,0x0
    80005e2c:	c64080e7          	jalr	-924(ra) # 80005a8c <argfd>
    80005e30:	87aa                	mv	a5,a0
    return -1;
    80005e32:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e34:	0007ca63          	bltz	a5,80005e48 <sys_fstat+0x3e>
  return filestat(f, st);
    80005e38:	fe043583          	ld	a1,-32(s0)
    80005e3c:	fe843503          	ld	a0,-24(s0)
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	27a080e7          	jalr	634(ra) # 800050ba <filestat>
}
    80005e48:	60e2                	ld	ra,24(sp)
    80005e4a:	6442                	ld	s0,16(sp)
    80005e4c:	6105                	addi	sp,sp,32
    80005e4e:	8082                	ret

0000000080005e50 <sys_link>:
{
    80005e50:	7169                	addi	sp,sp,-304
    80005e52:	f606                	sd	ra,296(sp)
    80005e54:	f222                	sd	s0,288(sp)
    80005e56:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e58:	08000613          	li	a2,128
    80005e5c:	ed040593          	addi	a1,s0,-304
    80005e60:	4501                	li	a0,0
    80005e62:	ffffd097          	auipc	ra,0xffffd
    80005e66:	604080e7          	jalr	1540(ra) # 80003466 <argstr>
    return -1;
    80005e6a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e6c:	12054663          	bltz	a0,80005f98 <sys_link+0x148>
    80005e70:	08000613          	li	a2,128
    80005e74:	f5040593          	addi	a1,s0,-176
    80005e78:	4505                	li	a0,1
    80005e7a:	ffffd097          	auipc	ra,0xffffd
    80005e7e:	5ec080e7          	jalr	1516(ra) # 80003466 <argstr>
    return -1;
    80005e82:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e84:	10054a63          	bltz	a0,80005f98 <sys_link+0x148>
    80005e88:	ee26                	sd	s1,280(sp)
  begin_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	c84080e7          	jalr	-892(ra) # 80004b0e <begin_op>
  if((ip = namei(old)) == 0){
    80005e92:	ed040513          	addi	a0,s0,-304
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	a78080e7          	jalr	-1416(ra) # 8000490e <namei>
    80005e9e:	84aa                	mv	s1,a0
    80005ea0:	c949                	beqz	a0,80005f32 <sys_link+0xe2>
  ilock(ip);
    80005ea2:	ffffe097          	auipc	ra,0xffffe
    80005ea6:	29e080e7          	jalr	670(ra) # 80004140 <ilock>
  if(ip->type == T_DIR){
    80005eaa:	04449703          	lh	a4,68(s1)
    80005eae:	4785                	li	a5,1
    80005eb0:	08f70863          	beq	a4,a5,80005f40 <sys_link+0xf0>
    80005eb4:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005eb6:	04a4d783          	lhu	a5,74(s1)
    80005eba:	2785                	addiw	a5,a5,1
    80005ebc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ec0:	8526                	mv	a0,s1
    80005ec2:	ffffe097          	auipc	ra,0xffffe
    80005ec6:	1b2080e7          	jalr	434(ra) # 80004074 <iupdate>
  iunlock(ip);
    80005eca:	8526                	mv	a0,s1
    80005ecc:	ffffe097          	auipc	ra,0xffffe
    80005ed0:	33a080e7          	jalr	826(ra) # 80004206 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ed4:	fd040593          	addi	a1,s0,-48
    80005ed8:	f5040513          	addi	a0,s0,-176
    80005edc:	fffff097          	auipc	ra,0xfffff
    80005ee0:	a50080e7          	jalr	-1456(ra) # 8000492c <nameiparent>
    80005ee4:	892a                	mv	s2,a0
    80005ee6:	cd35                	beqz	a0,80005f62 <sys_link+0x112>
  ilock(dp);
    80005ee8:	ffffe097          	auipc	ra,0xffffe
    80005eec:	258080e7          	jalr	600(ra) # 80004140 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005ef0:	00092703          	lw	a4,0(s2)
    80005ef4:	409c                	lw	a5,0(s1)
    80005ef6:	06f71163          	bne	a4,a5,80005f58 <sys_link+0x108>
    80005efa:	40d0                	lw	a2,4(s1)
    80005efc:	fd040593          	addi	a1,s0,-48
    80005f00:	854a                	mv	a0,s2
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	95a080e7          	jalr	-1702(ra) # 8000485c <dirlink>
    80005f0a:	04054763          	bltz	a0,80005f58 <sys_link+0x108>
  iunlockput(dp);
    80005f0e:	854a                	mv	a0,s2
    80005f10:	ffffe097          	auipc	ra,0xffffe
    80005f14:	496080e7          	jalr	1174(ra) # 800043a6 <iunlockput>
  iput(ip);
    80005f18:	8526                	mv	a0,s1
    80005f1a:	ffffe097          	auipc	ra,0xffffe
    80005f1e:	3e4080e7          	jalr	996(ra) # 800042fe <iput>
  end_op();
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	c66080e7          	jalr	-922(ra) # 80004b88 <end_op>
  return 0;
    80005f2a:	4781                	li	a5,0
    80005f2c:	64f2                	ld	s1,280(sp)
    80005f2e:	6952                	ld	s2,272(sp)
    80005f30:	a0a5                	j	80005f98 <sys_link+0x148>
    end_op();
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	c56080e7          	jalr	-938(ra) # 80004b88 <end_op>
    return -1;
    80005f3a:	57fd                	li	a5,-1
    80005f3c:	64f2                	ld	s1,280(sp)
    80005f3e:	a8a9                	j	80005f98 <sys_link+0x148>
    iunlockput(ip);
    80005f40:	8526                	mv	a0,s1
    80005f42:	ffffe097          	auipc	ra,0xffffe
    80005f46:	464080e7          	jalr	1124(ra) # 800043a6 <iunlockput>
    end_op();
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	c3e080e7          	jalr	-962(ra) # 80004b88 <end_op>
    return -1;
    80005f52:	57fd                	li	a5,-1
    80005f54:	64f2                	ld	s1,280(sp)
    80005f56:	a089                	j	80005f98 <sys_link+0x148>
    iunlockput(dp);
    80005f58:	854a                	mv	a0,s2
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	44c080e7          	jalr	1100(ra) # 800043a6 <iunlockput>
  ilock(ip);
    80005f62:	8526                	mv	a0,s1
    80005f64:	ffffe097          	auipc	ra,0xffffe
    80005f68:	1dc080e7          	jalr	476(ra) # 80004140 <ilock>
  ip->nlink--;
    80005f6c:	04a4d783          	lhu	a5,74(s1)
    80005f70:	37fd                	addiw	a5,a5,-1
    80005f72:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f76:	8526                	mv	a0,s1
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	0fc080e7          	jalr	252(ra) # 80004074 <iupdate>
  iunlockput(ip);
    80005f80:	8526                	mv	a0,s1
    80005f82:	ffffe097          	auipc	ra,0xffffe
    80005f86:	424080e7          	jalr	1060(ra) # 800043a6 <iunlockput>
  end_op();
    80005f8a:	fffff097          	auipc	ra,0xfffff
    80005f8e:	bfe080e7          	jalr	-1026(ra) # 80004b88 <end_op>
  return -1;
    80005f92:	57fd                	li	a5,-1
    80005f94:	64f2                	ld	s1,280(sp)
    80005f96:	6952                	ld	s2,272(sp)
}
    80005f98:	853e                	mv	a0,a5
    80005f9a:	70b2                	ld	ra,296(sp)
    80005f9c:	7412                	ld	s0,288(sp)
    80005f9e:	6155                	addi	sp,sp,304
    80005fa0:	8082                	ret

0000000080005fa2 <sys_unlink>:
{
    80005fa2:	7151                	addi	sp,sp,-240
    80005fa4:	f586                	sd	ra,232(sp)
    80005fa6:	f1a2                	sd	s0,224(sp)
    80005fa8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005faa:	08000613          	li	a2,128
    80005fae:	f3040593          	addi	a1,s0,-208
    80005fb2:	4501                	li	a0,0
    80005fb4:	ffffd097          	auipc	ra,0xffffd
    80005fb8:	4b2080e7          	jalr	1202(ra) # 80003466 <argstr>
    80005fbc:	1a054a63          	bltz	a0,80006170 <sys_unlink+0x1ce>
    80005fc0:	eda6                	sd	s1,216(sp)
  begin_op();
    80005fc2:	fffff097          	auipc	ra,0xfffff
    80005fc6:	b4c080e7          	jalr	-1204(ra) # 80004b0e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005fca:	fb040593          	addi	a1,s0,-80
    80005fce:	f3040513          	addi	a0,s0,-208
    80005fd2:	fffff097          	auipc	ra,0xfffff
    80005fd6:	95a080e7          	jalr	-1702(ra) # 8000492c <nameiparent>
    80005fda:	84aa                	mv	s1,a0
    80005fdc:	cd71                	beqz	a0,800060b8 <sys_unlink+0x116>
  ilock(dp);
    80005fde:	ffffe097          	auipc	ra,0xffffe
    80005fe2:	162080e7          	jalr	354(ra) # 80004140 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005fe6:	00002597          	auipc	a1,0x2
    80005fea:	79a58593          	addi	a1,a1,1946 # 80008780 <__func__.1+0x778>
    80005fee:	fb040513          	addi	a0,s0,-80
    80005ff2:	ffffe097          	auipc	ra,0xffffe
    80005ff6:	640080e7          	jalr	1600(ra) # 80004632 <namecmp>
    80005ffa:	14050c63          	beqz	a0,80006152 <sys_unlink+0x1b0>
    80005ffe:	00002597          	auipc	a1,0x2
    80006002:	78a58593          	addi	a1,a1,1930 # 80008788 <__func__.1+0x780>
    80006006:	fb040513          	addi	a0,s0,-80
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	628080e7          	jalr	1576(ra) # 80004632 <namecmp>
    80006012:	14050063          	beqz	a0,80006152 <sys_unlink+0x1b0>
    80006016:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006018:	f2c40613          	addi	a2,s0,-212
    8000601c:	fb040593          	addi	a1,s0,-80
    80006020:	8526                	mv	a0,s1
    80006022:	ffffe097          	auipc	ra,0xffffe
    80006026:	62a080e7          	jalr	1578(ra) # 8000464c <dirlookup>
    8000602a:	892a                	mv	s2,a0
    8000602c:	12050263          	beqz	a0,80006150 <sys_unlink+0x1ae>
  ilock(ip);
    80006030:	ffffe097          	auipc	ra,0xffffe
    80006034:	110080e7          	jalr	272(ra) # 80004140 <ilock>
  if(ip->nlink < 1)
    80006038:	04a91783          	lh	a5,74(s2)
    8000603c:	08f05563          	blez	a5,800060c6 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006040:	04491703          	lh	a4,68(s2)
    80006044:	4785                	li	a5,1
    80006046:	08f70963          	beq	a4,a5,800060d8 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    8000604a:	4641                	li	a2,16
    8000604c:	4581                	li	a1,0
    8000604e:	fc040513          	addi	a0,s0,-64
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	fe0080e7          	jalr	-32(ra) # 80001032 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000605a:	4741                	li	a4,16
    8000605c:	f2c42683          	lw	a3,-212(s0)
    80006060:	fc040613          	addi	a2,s0,-64
    80006064:	4581                	li	a1,0
    80006066:	8526                	mv	a0,s1
    80006068:	ffffe097          	auipc	ra,0xffffe
    8000606c:	4a0080e7          	jalr	1184(ra) # 80004508 <writei>
    80006070:	47c1                	li	a5,16
    80006072:	0af51b63          	bne	a0,a5,80006128 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80006076:	04491703          	lh	a4,68(s2)
    8000607a:	4785                	li	a5,1
    8000607c:	0af70f63          	beq	a4,a5,8000613a <sys_unlink+0x198>
  iunlockput(dp);
    80006080:	8526                	mv	a0,s1
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	324080e7          	jalr	804(ra) # 800043a6 <iunlockput>
  ip->nlink--;
    8000608a:	04a95783          	lhu	a5,74(s2)
    8000608e:	37fd                	addiw	a5,a5,-1
    80006090:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006094:	854a                	mv	a0,s2
    80006096:	ffffe097          	auipc	ra,0xffffe
    8000609a:	fde080e7          	jalr	-34(ra) # 80004074 <iupdate>
  iunlockput(ip);
    8000609e:	854a                	mv	a0,s2
    800060a0:	ffffe097          	auipc	ra,0xffffe
    800060a4:	306080e7          	jalr	774(ra) # 800043a6 <iunlockput>
  end_op();
    800060a8:	fffff097          	auipc	ra,0xfffff
    800060ac:	ae0080e7          	jalr	-1312(ra) # 80004b88 <end_op>
  return 0;
    800060b0:	4501                	li	a0,0
    800060b2:	64ee                	ld	s1,216(sp)
    800060b4:	694e                	ld	s2,208(sp)
    800060b6:	a84d                	j	80006168 <sys_unlink+0x1c6>
    end_op();
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	ad0080e7          	jalr	-1328(ra) # 80004b88 <end_op>
    return -1;
    800060c0:	557d                	li	a0,-1
    800060c2:	64ee                	ld	s1,216(sp)
    800060c4:	a055                	j	80006168 <sys_unlink+0x1c6>
    800060c6:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800060c8:	00002517          	auipc	a0,0x2
    800060cc:	6c850513          	addi	a0,a0,1736 # 80008790 <__func__.1+0x788>
    800060d0:	ffffa097          	auipc	ra,0xffffa
    800060d4:	490080e7          	jalr	1168(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800060d8:	04c92703          	lw	a4,76(s2)
    800060dc:	02000793          	li	a5,32
    800060e0:	f6e7f5e3          	bgeu	a5,a4,8000604a <sys_unlink+0xa8>
    800060e4:	e5ce                	sd	s3,200(sp)
    800060e6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800060ea:	4741                	li	a4,16
    800060ec:	86ce                	mv	a3,s3
    800060ee:	f1840613          	addi	a2,s0,-232
    800060f2:	4581                	li	a1,0
    800060f4:	854a                	mv	a0,s2
    800060f6:	ffffe097          	auipc	ra,0xffffe
    800060fa:	302080e7          	jalr	770(ra) # 800043f8 <readi>
    800060fe:	47c1                	li	a5,16
    80006100:	00f51c63          	bne	a0,a5,80006118 <sys_unlink+0x176>
    if(de.inum != 0)
    80006104:	f1845783          	lhu	a5,-232(s0)
    80006108:	e7b5                	bnez	a5,80006174 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000610a:	29c1                	addiw	s3,s3,16
    8000610c:	04c92783          	lw	a5,76(s2)
    80006110:	fcf9ede3          	bltu	s3,a5,800060ea <sys_unlink+0x148>
    80006114:	69ae                	ld	s3,200(sp)
    80006116:	bf15                	j	8000604a <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80006118:	00002517          	auipc	a0,0x2
    8000611c:	69050513          	addi	a0,a0,1680 # 800087a8 <__func__.1+0x7a0>
    80006120:	ffffa097          	auipc	ra,0xffffa
    80006124:	440080e7          	jalr	1088(ra) # 80000560 <panic>
    80006128:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000612a:	00002517          	auipc	a0,0x2
    8000612e:	69650513          	addi	a0,a0,1686 # 800087c0 <__func__.1+0x7b8>
    80006132:	ffffa097          	auipc	ra,0xffffa
    80006136:	42e080e7          	jalr	1070(ra) # 80000560 <panic>
    dp->nlink--;
    8000613a:	04a4d783          	lhu	a5,74(s1)
    8000613e:	37fd                	addiw	a5,a5,-1
    80006140:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006144:	8526                	mv	a0,s1
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	f2e080e7          	jalr	-210(ra) # 80004074 <iupdate>
    8000614e:	bf0d                	j	80006080 <sys_unlink+0xde>
    80006150:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80006152:	8526                	mv	a0,s1
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	252080e7          	jalr	594(ra) # 800043a6 <iunlockput>
  end_op();
    8000615c:	fffff097          	auipc	ra,0xfffff
    80006160:	a2c080e7          	jalr	-1492(ra) # 80004b88 <end_op>
  return -1;
    80006164:	557d                	li	a0,-1
    80006166:	64ee                	ld	s1,216(sp)
}
    80006168:	70ae                	ld	ra,232(sp)
    8000616a:	740e                	ld	s0,224(sp)
    8000616c:	616d                	addi	sp,sp,240
    8000616e:	8082                	ret
    return -1;
    80006170:	557d                	li	a0,-1
    80006172:	bfdd                	j	80006168 <sys_unlink+0x1c6>
    iunlockput(ip);
    80006174:	854a                	mv	a0,s2
    80006176:	ffffe097          	auipc	ra,0xffffe
    8000617a:	230080e7          	jalr	560(ra) # 800043a6 <iunlockput>
    goto bad;
    8000617e:	694e                	ld	s2,208(sp)
    80006180:	69ae                	ld	s3,200(sp)
    80006182:	bfc1                	j	80006152 <sys_unlink+0x1b0>

0000000080006184 <sys_open>:

uint64
sys_open(void)
{
    80006184:	7131                	addi	sp,sp,-192
    80006186:	fd06                	sd	ra,184(sp)
    80006188:	f922                	sd	s0,176(sp)
    8000618a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000618c:	f4c40593          	addi	a1,s0,-180
    80006190:	4505                	li	a0,1
    80006192:	ffffd097          	auipc	ra,0xffffd
    80006196:	294080e7          	jalr	660(ra) # 80003426 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000619a:	08000613          	li	a2,128
    8000619e:	f5040593          	addi	a1,s0,-176
    800061a2:	4501                	li	a0,0
    800061a4:	ffffd097          	auipc	ra,0xffffd
    800061a8:	2c2080e7          	jalr	706(ra) # 80003466 <argstr>
    800061ac:	87aa                	mv	a5,a0
    return -1;
    800061ae:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800061b0:	0a07ce63          	bltz	a5,8000626c <sys_open+0xe8>
    800061b4:	f526                	sd	s1,168(sp)

  begin_op();
    800061b6:	fffff097          	auipc	ra,0xfffff
    800061ba:	958080e7          	jalr	-1704(ra) # 80004b0e <begin_op>

  if(omode & O_CREATE){
    800061be:	f4c42783          	lw	a5,-180(s0)
    800061c2:	2007f793          	andi	a5,a5,512
    800061c6:	cfd5                	beqz	a5,80006282 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800061c8:	4681                	li	a3,0
    800061ca:	4601                	li	a2,0
    800061cc:	4589                	li	a1,2
    800061ce:	f5040513          	addi	a0,s0,-176
    800061d2:	00000097          	auipc	ra,0x0
    800061d6:	95c080e7          	jalr	-1700(ra) # 80005b2e <create>
    800061da:	84aa                	mv	s1,a0
    if(ip == 0){
    800061dc:	cd41                	beqz	a0,80006274 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800061de:	04449703          	lh	a4,68(s1)
    800061e2:	478d                	li	a5,3
    800061e4:	00f71763          	bne	a4,a5,800061f2 <sys_open+0x6e>
    800061e8:	0464d703          	lhu	a4,70(s1)
    800061ec:	47a5                	li	a5,9
    800061ee:	0ee7e163          	bltu	a5,a4,800062d0 <sys_open+0x14c>
    800061f2:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800061f4:	fffff097          	auipc	ra,0xfffff
    800061f8:	d28080e7          	jalr	-728(ra) # 80004f1c <filealloc>
    800061fc:	892a                	mv	s2,a0
    800061fe:	c97d                	beqz	a0,800062f4 <sys_open+0x170>
    80006200:	ed4e                	sd	s3,152(sp)
    80006202:	00000097          	auipc	ra,0x0
    80006206:	8ea080e7          	jalr	-1814(ra) # 80005aec <fdalloc>
    8000620a:	89aa                	mv	s3,a0
    8000620c:	0c054e63          	bltz	a0,800062e8 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006210:	04449703          	lh	a4,68(s1)
    80006214:	478d                	li	a5,3
    80006216:	0ef70c63          	beq	a4,a5,8000630e <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000621a:	4789                	li	a5,2
    8000621c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006220:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006224:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006228:	f4c42783          	lw	a5,-180(s0)
    8000622c:	0017c713          	xori	a4,a5,1
    80006230:	8b05                	andi	a4,a4,1
    80006232:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006236:	0037f713          	andi	a4,a5,3
    8000623a:	00e03733          	snez	a4,a4
    8000623e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006242:	4007f793          	andi	a5,a5,1024
    80006246:	c791                	beqz	a5,80006252 <sys_open+0xce>
    80006248:	04449703          	lh	a4,68(s1)
    8000624c:	4789                	li	a5,2
    8000624e:	0cf70763          	beq	a4,a5,8000631c <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80006252:	8526                	mv	a0,s1
    80006254:	ffffe097          	auipc	ra,0xffffe
    80006258:	fb2080e7          	jalr	-78(ra) # 80004206 <iunlock>
  end_op();
    8000625c:	fffff097          	auipc	ra,0xfffff
    80006260:	92c080e7          	jalr	-1748(ra) # 80004b88 <end_op>

  return fd;
    80006264:	854e                	mv	a0,s3
    80006266:	74aa                	ld	s1,168(sp)
    80006268:	790a                	ld	s2,160(sp)
    8000626a:	69ea                	ld	s3,152(sp)
}
    8000626c:	70ea                	ld	ra,184(sp)
    8000626e:	744a                	ld	s0,176(sp)
    80006270:	6129                	addi	sp,sp,192
    80006272:	8082                	ret
      end_op();
    80006274:	fffff097          	auipc	ra,0xfffff
    80006278:	914080e7          	jalr	-1772(ra) # 80004b88 <end_op>
      return -1;
    8000627c:	557d                	li	a0,-1
    8000627e:	74aa                	ld	s1,168(sp)
    80006280:	b7f5                	j	8000626c <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80006282:	f5040513          	addi	a0,s0,-176
    80006286:	ffffe097          	auipc	ra,0xffffe
    8000628a:	688080e7          	jalr	1672(ra) # 8000490e <namei>
    8000628e:	84aa                	mv	s1,a0
    80006290:	c90d                	beqz	a0,800062c2 <sys_open+0x13e>
    ilock(ip);
    80006292:	ffffe097          	auipc	ra,0xffffe
    80006296:	eae080e7          	jalr	-338(ra) # 80004140 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000629a:	04449703          	lh	a4,68(s1)
    8000629e:	4785                	li	a5,1
    800062a0:	f2f71fe3          	bne	a4,a5,800061de <sys_open+0x5a>
    800062a4:	f4c42783          	lw	a5,-180(s0)
    800062a8:	d7a9                	beqz	a5,800061f2 <sys_open+0x6e>
      iunlockput(ip);
    800062aa:	8526                	mv	a0,s1
    800062ac:	ffffe097          	auipc	ra,0xffffe
    800062b0:	0fa080e7          	jalr	250(ra) # 800043a6 <iunlockput>
      end_op();
    800062b4:	fffff097          	auipc	ra,0xfffff
    800062b8:	8d4080e7          	jalr	-1836(ra) # 80004b88 <end_op>
      return -1;
    800062bc:	557d                	li	a0,-1
    800062be:	74aa                	ld	s1,168(sp)
    800062c0:	b775                	j	8000626c <sys_open+0xe8>
      end_op();
    800062c2:	fffff097          	auipc	ra,0xfffff
    800062c6:	8c6080e7          	jalr	-1850(ra) # 80004b88 <end_op>
      return -1;
    800062ca:	557d                	li	a0,-1
    800062cc:	74aa                	ld	s1,168(sp)
    800062ce:	bf79                	j	8000626c <sys_open+0xe8>
    iunlockput(ip);
    800062d0:	8526                	mv	a0,s1
    800062d2:	ffffe097          	auipc	ra,0xffffe
    800062d6:	0d4080e7          	jalr	212(ra) # 800043a6 <iunlockput>
    end_op();
    800062da:	fffff097          	auipc	ra,0xfffff
    800062de:	8ae080e7          	jalr	-1874(ra) # 80004b88 <end_op>
    return -1;
    800062e2:	557d                	li	a0,-1
    800062e4:	74aa                	ld	s1,168(sp)
    800062e6:	b759                	j	8000626c <sys_open+0xe8>
      fileclose(f);
    800062e8:	854a                	mv	a0,s2
    800062ea:	fffff097          	auipc	ra,0xfffff
    800062ee:	cee080e7          	jalr	-786(ra) # 80004fd8 <fileclose>
    800062f2:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800062f4:	8526                	mv	a0,s1
    800062f6:	ffffe097          	auipc	ra,0xffffe
    800062fa:	0b0080e7          	jalr	176(ra) # 800043a6 <iunlockput>
    end_op();
    800062fe:	fffff097          	auipc	ra,0xfffff
    80006302:	88a080e7          	jalr	-1910(ra) # 80004b88 <end_op>
    return -1;
    80006306:	557d                	li	a0,-1
    80006308:	74aa                	ld	s1,168(sp)
    8000630a:	790a                	ld	s2,160(sp)
    8000630c:	b785                	j	8000626c <sys_open+0xe8>
    f->type = FD_DEVICE;
    8000630e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006312:	04649783          	lh	a5,70(s1)
    80006316:	02f91223          	sh	a5,36(s2)
    8000631a:	b729                	j	80006224 <sys_open+0xa0>
    itrunc(ip);
    8000631c:	8526                	mv	a0,s1
    8000631e:	ffffe097          	auipc	ra,0xffffe
    80006322:	f34080e7          	jalr	-204(ra) # 80004252 <itrunc>
    80006326:	b735                	j	80006252 <sys_open+0xce>

0000000080006328 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006328:	7175                	addi	sp,sp,-144
    8000632a:	e506                	sd	ra,136(sp)
    8000632c:	e122                	sd	s0,128(sp)
    8000632e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006330:	ffffe097          	auipc	ra,0xffffe
    80006334:	7de080e7          	jalr	2014(ra) # 80004b0e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006338:	08000613          	li	a2,128
    8000633c:	f7040593          	addi	a1,s0,-144
    80006340:	4501                	li	a0,0
    80006342:	ffffd097          	auipc	ra,0xffffd
    80006346:	124080e7          	jalr	292(ra) # 80003466 <argstr>
    8000634a:	02054963          	bltz	a0,8000637c <sys_mkdir+0x54>
    8000634e:	4681                	li	a3,0
    80006350:	4601                	li	a2,0
    80006352:	4585                	li	a1,1
    80006354:	f7040513          	addi	a0,s0,-144
    80006358:	fffff097          	auipc	ra,0xfffff
    8000635c:	7d6080e7          	jalr	2006(ra) # 80005b2e <create>
    80006360:	cd11                	beqz	a0,8000637c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006362:	ffffe097          	auipc	ra,0xffffe
    80006366:	044080e7          	jalr	68(ra) # 800043a6 <iunlockput>
  end_op();
    8000636a:	fffff097          	auipc	ra,0xfffff
    8000636e:	81e080e7          	jalr	-2018(ra) # 80004b88 <end_op>
  return 0;
    80006372:	4501                	li	a0,0
}
    80006374:	60aa                	ld	ra,136(sp)
    80006376:	640a                	ld	s0,128(sp)
    80006378:	6149                	addi	sp,sp,144
    8000637a:	8082                	ret
    end_op();
    8000637c:	fffff097          	auipc	ra,0xfffff
    80006380:	80c080e7          	jalr	-2036(ra) # 80004b88 <end_op>
    return -1;
    80006384:	557d                	li	a0,-1
    80006386:	b7fd                	j	80006374 <sys_mkdir+0x4c>

0000000080006388 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006388:	7135                	addi	sp,sp,-160
    8000638a:	ed06                	sd	ra,152(sp)
    8000638c:	e922                	sd	s0,144(sp)
    8000638e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006390:	ffffe097          	auipc	ra,0xffffe
    80006394:	77e080e7          	jalr	1918(ra) # 80004b0e <begin_op>
  argint(1, &major);
    80006398:	f6c40593          	addi	a1,s0,-148
    8000639c:	4505                	li	a0,1
    8000639e:	ffffd097          	auipc	ra,0xffffd
    800063a2:	088080e7          	jalr	136(ra) # 80003426 <argint>
  argint(2, &minor);
    800063a6:	f6840593          	addi	a1,s0,-152
    800063aa:	4509                	li	a0,2
    800063ac:	ffffd097          	auipc	ra,0xffffd
    800063b0:	07a080e7          	jalr	122(ra) # 80003426 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800063b4:	08000613          	li	a2,128
    800063b8:	f7040593          	addi	a1,s0,-144
    800063bc:	4501                	li	a0,0
    800063be:	ffffd097          	auipc	ra,0xffffd
    800063c2:	0a8080e7          	jalr	168(ra) # 80003466 <argstr>
    800063c6:	02054b63          	bltz	a0,800063fc <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800063ca:	f6841683          	lh	a3,-152(s0)
    800063ce:	f6c41603          	lh	a2,-148(s0)
    800063d2:	458d                	li	a1,3
    800063d4:	f7040513          	addi	a0,s0,-144
    800063d8:	fffff097          	auipc	ra,0xfffff
    800063dc:	756080e7          	jalr	1878(ra) # 80005b2e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800063e0:	cd11                	beqz	a0,800063fc <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800063e2:	ffffe097          	auipc	ra,0xffffe
    800063e6:	fc4080e7          	jalr	-60(ra) # 800043a6 <iunlockput>
  end_op();
    800063ea:	ffffe097          	auipc	ra,0xffffe
    800063ee:	79e080e7          	jalr	1950(ra) # 80004b88 <end_op>
  return 0;
    800063f2:	4501                	li	a0,0
}
    800063f4:	60ea                	ld	ra,152(sp)
    800063f6:	644a                	ld	s0,144(sp)
    800063f8:	610d                	addi	sp,sp,160
    800063fa:	8082                	ret
    end_op();
    800063fc:	ffffe097          	auipc	ra,0xffffe
    80006400:	78c080e7          	jalr	1932(ra) # 80004b88 <end_op>
    return -1;
    80006404:	557d                	li	a0,-1
    80006406:	b7fd                	j	800063f4 <sys_mknod+0x6c>

0000000080006408 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006408:	7135                	addi	sp,sp,-160
    8000640a:	ed06                	sd	ra,152(sp)
    8000640c:	e922                	sd	s0,144(sp)
    8000640e:	e14a                	sd	s2,128(sp)
    80006410:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006412:	ffffc097          	auipc	ra,0xffffc
    80006416:	bc6080e7          	jalr	-1082(ra) # 80001fd8 <myproc>
    8000641a:	892a                	mv	s2,a0
  
  begin_op();
    8000641c:	ffffe097          	auipc	ra,0xffffe
    80006420:	6f2080e7          	jalr	1778(ra) # 80004b0e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006424:	08000613          	li	a2,128
    80006428:	f6040593          	addi	a1,s0,-160
    8000642c:	4501                	li	a0,0
    8000642e:	ffffd097          	auipc	ra,0xffffd
    80006432:	038080e7          	jalr	56(ra) # 80003466 <argstr>
    80006436:	04054d63          	bltz	a0,80006490 <sys_chdir+0x88>
    8000643a:	e526                	sd	s1,136(sp)
    8000643c:	f6040513          	addi	a0,s0,-160
    80006440:	ffffe097          	auipc	ra,0xffffe
    80006444:	4ce080e7          	jalr	1230(ra) # 8000490e <namei>
    80006448:	84aa                	mv	s1,a0
    8000644a:	c131                	beqz	a0,8000648e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000644c:	ffffe097          	auipc	ra,0xffffe
    80006450:	cf4080e7          	jalr	-780(ra) # 80004140 <ilock>
  if(ip->type != T_DIR){
    80006454:	04449703          	lh	a4,68(s1)
    80006458:	4785                	li	a5,1
    8000645a:	04f71163          	bne	a4,a5,8000649c <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000645e:	8526                	mv	a0,s1
    80006460:	ffffe097          	auipc	ra,0xffffe
    80006464:	da6080e7          	jalr	-602(ra) # 80004206 <iunlock>
  iput(p->cwd);
    80006468:	15093503          	ld	a0,336(s2)
    8000646c:	ffffe097          	auipc	ra,0xffffe
    80006470:	e92080e7          	jalr	-366(ra) # 800042fe <iput>
  end_op();
    80006474:	ffffe097          	auipc	ra,0xffffe
    80006478:	714080e7          	jalr	1812(ra) # 80004b88 <end_op>
  p->cwd = ip;
    8000647c:	14993823          	sd	s1,336(s2)
  return 0;
    80006480:	4501                	li	a0,0
    80006482:	64aa                	ld	s1,136(sp)
}
    80006484:	60ea                	ld	ra,152(sp)
    80006486:	644a                	ld	s0,144(sp)
    80006488:	690a                	ld	s2,128(sp)
    8000648a:	610d                	addi	sp,sp,160
    8000648c:	8082                	ret
    8000648e:	64aa                	ld	s1,136(sp)
    end_op();
    80006490:	ffffe097          	auipc	ra,0xffffe
    80006494:	6f8080e7          	jalr	1784(ra) # 80004b88 <end_op>
    return -1;
    80006498:	557d                	li	a0,-1
    8000649a:	b7ed                	j	80006484 <sys_chdir+0x7c>
    iunlockput(ip);
    8000649c:	8526                	mv	a0,s1
    8000649e:	ffffe097          	auipc	ra,0xffffe
    800064a2:	f08080e7          	jalr	-248(ra) # 800043a6 <iunlockput>
    end_op();
    800064a6:	ffffe097          	auipc	ra,0xffffe
    800064aa:	6e2080e7          	jalr	1762(ra) # 80004b88 <end_op>
    return -1;
    800064ae:	557d                	li	a0,-1
    800064b0:	64aa                	ld	s1,136(sp)
    800064b2:	bfc9                	j	80006484 <sys_chdir+0x7c>

00000000800064b4 <sys_exec>:

uint64
sys_exec(void)
{
    800064b4:	7121                	addi	sp,sp,-448
    800064b6:	ff06                	sd	ra,440(sp)
    800064b8:	fb22                	sd	s0,432(sp)
    800064ba:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800064bc:	e4840593          	addi	a1,s0,-440
    800064c0:	4505                	li	a0,1
    800064c2:	ffffd097          	auipc	ra,0xffffd
    800064c6:	f84080e7          	jalr	-124(ra) # 80003446 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800064ca:	08000613          	li	a2,128
    800064ce:	f5040593          	addi	a1,s0,-176
    800064d2:	4501                	li	a0,0
    800064d4:	ffffd097          	auipc	ra,0xffffd
    800064d8:	f92080e7          	jalr	-110(ra) # 80003466 <argstr>
    800064dc:	87aa                	mv	a5,a0
    return -1;
    800064de:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800064e0:	0e07c263          	bltz	a5,800065c4 <sys_exec+0x110>
    800064e4:	f726                	sd	s1,424(sp)
    800064e6:	f34a                	sd	s2,416(sp)
    800064e8:	ef4e                	sd	s3,408(sp)
    800064ea:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800064ec:	10000613          	li	a2,256
    800064f0:	4581                	li	a1,0
    800064f2:	e5040513          	addi	a0,s0,-432
    800064f6:	ffffb097          	auipc	ra,0xffffb
    800064fa:	b3c080e7          	jalr	-1220(ra) # 80001032 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800064fe:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80006502:	89a6                	mv	s3,s1
    80006504:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006506:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000650a:	00391513          	slli	a0,s2,0x3
    8000650e:	e4040593          	addi	a1,s0,-448
    80006512:	e4843783          	ld	a5,-440(s0)
    80006516:	953e                	add	a0,a0,a5
    80006518:	ffffd097          	auipc	ra,0xffffd
    8000651c:	e70080e7          	jalr	-400(ra) # 80003388 <fetchaddr>
    80006520:	02054a63          	bltz	a0,80006554 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006524:	e4043783          	ld	a5,-448(s0)
    80006528:	c7b9                	beqz	a5,80006576 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000652a:	ffffa097          	auipc	ra,0xffffa
    8000652e:	75c080e7          	jalr	1884(ra) # 80000c86 <kalloc>
    80006532:	85aa                	mv	a1,a0
    80006534:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006538:	cd11                	beqz	a0,80006554 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000653a:	6605                	lui	a2,0x1
    8000653c:	e4043503          	ld	a0,-448(s0)
    80006540:	ffffd097          	auipc	ra,0xffffd
    80006544:	e9a080e7          	jalr	-358(ra) # 800033da <fetchstr>
    80006548:	00054663          	bltz	a0,80006554 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    8000654c:	0905                	addi	s2,s2,1
    8000654e:	09a1                	addi	s3,s3,8
    80006550:	fb491de3          	bne	s2,s4,8000650a <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006554:	f5040913          	addi	s2,s0,-176
    80006558:	6088                	ld	a0,0(s1)
    8000655a:	c125                	beqz	a0,800065ba <sys_exec+0x106>
    kfree(argv[i]);
    8000655c:	ffffa097          	auipc	ra,0xffffa
    80006560:	538080e7          	jalr	1336(ra) # 80000a94 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006564:	04a1                	addi	s1,s1,8
    80006566:	ff2499e3          	bne	s1,s2,80006558 <sys_exec+0xa4>
  return -1;
    8000656a:	557d                	li	a0,-1
    8000656c:	74ba                	ld	s1,424(sp)
    8000656e:	791a                	ld	s2,416(sp)
    80006570:	69fa                	ld	s3,408(sp)
    80006572:	6a5a                	ld	s4,400(sp)
    80006574:	a881                	j	800065c4 <sys_exec+0x110>
      argv[i] = 0;
    80006576:	0009079b          	sext.w	a5,s2
    8000657a:	078e                	slli	a5,a5,0x3
    8000657c:	fd078793          	addi	a5,a5,-48
    80006580:	97a2                	add	a5,a5,s0
    80006582:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006586:	e5040593          	addi	a1,s0,-432
    8000658a:	f5040513          	addi	a0,s0,-176
    8000658e:	fffff097          	auipc	ra,0xfffff
    80006592:	120080e7          	jalr	288(ra) # 800056ae <exec>
    80006596:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006598:	f5040993          	addi	s3,s0,-176
    8000659c:	6088                	ld	a0,0(s1)
    8000659e:	c901                	beqz	a0,800065ae <sys_exec+0xfa>
    kfree(argv[i]);
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	4f4080e7          	jalr	1268(ra) # 80000a94 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800065a8:	04a1                	addi	s1,s1,8
    800065aa:	ff3499e3          	bne	s1,s3,8000659c <sys_exec+0xe8>
  return ret;
    800065ae:	854a                	mv	a0,s2
    800065b0:	74ba                	ld	s1,424(sp)
    800065b2:	791a                	ld	s2,416(sp)
    800065b4:	69fa                	ld	s3,408(sp)
    800065b6:	6a5a                	ld	s4,400(sp)
    800065b8:	a031                	j	800065c4 <sys_exec+0x110>
  return -1;
    800065ba:	557d                	li	a0,-1
    800065bc:	74ba                	ld	s1,424(sp)
    800065be:	791a                	ld	s2,416(sp)
    800065c0:	69fa                	ld	s3,408(sp)
    800065c2:	6a5a                	ld	s4,400(sp)
}
    800065c4:	70fa                	ld	ra,440(sp)
    800065c6:	745a                	ld	s0,432(sp)
    800065c8:	6139                	addi	sp,sp,448
    800065ca:	8082                	ret

00000000800065cc <sys_pipe>:

uint64
sys_pipe(void)
{
    800065cc:	7139                	addi	sp,sp,-64
    800065ce:	fc06                	sd	ra,56(sp)
    800065d0:	f822                	sd	s0,48(sp)
    800065d2:	f426                	sd	s1,40(sp)
    800065d4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800065d6:	ffffc097          	auipc	ra,0xffffc
    800065da:	a02080e7          	jalr	-1534(ra) # 80001fd8 <myproc>
    800065de:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800065e0:	fd840593          	addi	a1,s0,-40
    800065e4:	4501                	li	a0,0
    800065e6:	ffffd097          	auipc	ra,0xffffd
    800065ea:	e60080e7          	jalr	-416(ra) # 80003446 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800065ee:	fc840593          	addi	a1,s0,-56
    800065f2:	fd040513          	addi	a0,s0,-48
    800065f6:	fffff097          	auipc	ra,0xfffff
    800065fa:	d50080e7          	jalr	-688(ra) # 80005346 <pipealloc>
    return -1;
    800065fe:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006600:	0c054463          	bltz	a0,800066c8 <sys_pipe+0xfc>
  fd0 = -1;
    80006604:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006608:	fd043503          	ld	a0,-48(s0)
    8000660c:	fffff097          	auipc	ra,0xfffff
    80006610:	4e0080e7          	jalr	1248(ra) # 80005aec <fdalloc>
    80006614:	fca42223          	sw	a0,-60(s0)
    80006618:	08054b63          	bltz	a0,800066ae <sys_pipe+0xe2>
    8000661c:	fc843503          	ld	a0,-56(s0)
    80006620:	fffff097          	auipc	ra,0xfffff
    80006624:	4cc080e7          	jalr	1228(ra) # 80005aec <fdalloc>
    80006628:	fca42023          	sw	a0,-64(s0)
    8000662c:	06054863          	bltz	a0,8000669c <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006630:	4691                	li	a3,4
    80006632:	fc440613          	addi	a2,s0,-60
    80006636:	fd843583          	ld	a1,-40(s0)
    8000663a:	68a8                	ld	a0,80(s1)
    8000663c:	ffffb097          	auipc	ra,0xffffb
    80006640:	3aa080e7          	jalr	938(ra) # 800019e6 <copyout>
    80006644:	02054063          	bltz	a0,80006664 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006648:	4691                	li	a3,4
    8000664a:	fc040613          	addi	a2,s0,-64
    8000664e:	fd843583          	ld	a1,-40(s0)
    80006652:	0591                	addi	a1,a1,4
    80006654:	68a8                	ld	a0,80(s1)
    80006656:	ffffb097          	auipc	ra,0xffffb
    8000665a:	390080e7          	jalr	912(ra) # 800019e6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000665e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006660:	06055463          	bgez	a0,800066c8 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006664:	fc442783          	lw	a5,-60(s0)
    80006668:	07e9                	addi	a5,a5,26
    8000666a:	078e                	slli	a5,a5,0x3
    8000666c:	97a6                	add	a5,a5,s1
    8000666e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006672:	fc042783          	lw	a5,-64(s0)
    80006676:	07e9                	addi	a5,a5,26
    80006678:	078e                	slli	a5,a5,0x3
    8000667a:	94be                	add	s1,s1,a5
    8000667c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006680:	fd043503          	ld	a0,-48(s0)
    80006684:	fffff097          	auipc	ra,0xfffff
    80006688:	954080e7          	jalr	-1708(ra) # 80004fd8 <fileclose>
    fileclose(wf);
    8000668c:	fc843503          	ld	a0,-56(s0)
    80006690:	fffff097          	auipc	ra,0xfffff
    80006694:	948080e7          	jalr	-1720(ra) # 80004fd8 <fileclose>
    return -1;
    80006698:	57fd                	li	a5,-1
    8000669a:	a03d                	j	800066c8 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000669c:	fc442783          	lw	a5,-60(s0)
    800066a0:	0007c763          	bltz	a5,800066ae <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800066a4:	07e9                	addi	a5,a5,26
    800066a6:	078e                	slli	a5,a5,0x3
    800066a8:	97a6                	add	a5,a5,s1
    800066aa:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800066ae:	fd043503          	ld	a0,-48(s0)
    800066b2:	fffff097          	auipc	ra,0xfffff
    800066b6:	926080e7          	jalr	-1754(ra) # 80004fd8 <fileclose>
    fileclose(wf);
    800066ba:	fc843503          	ld	a0,-56(s0)
    800066be:	fffff097          	auipc	ra,0xfffff
    800066c2:	91a080e7          	jalr	-1766(ra) # 80004fd8 <fileclose>
    return -1;
    800066c6:	57fd                	li	a5,-1
}
    800066c8:	853e                	mv	a0,a5
    800066ca:	70e2                	ld	ra,56(sp)
    800066cc:	7442                	ld	s0,48(sp)
    800066ce:	74a2                	ld	s1,40(sp)
    800066d0:	6121                	addi	sp,sp,64
    800066d2:	8082                	ret
	...

00000000800066e0 <kernelvec>:
    800066e0:	7111                	addi	sp,sp,-256
    800066e2:	e006                	sd	ra,0(sp)
    800066e4:	e40a                	sd	sp,8(sp)
    800066e6:	e80e                	sd	gp,16(sp)
    800066e8:	ec12                	sd	tp,24(sp)
    800066ea:	f016                	sd	t0,32(sp)
    800066ec:	f41a                	sd	t1,40(sp)
    800066ee:	f81e                	sd	t2,48(sp)
    800066f0:	fc22                	sd	s0,56(sp)
    800066f2:	e0a6                	sd	s1,64(sp)
    800066f4:	e4aa                	sd	a0,72(sp)
    800066f6:	e8ae                	sd	a1,80(sp)
    800066f8:	ecb2                	sd	a2,88(sp)
    800066fa:	f0b6                	sd	a3,96(sp)
    800066fc:	f4ba                	sd	a4,104(sp)
    800066fe:	f8be                	sd	a5,112(sp)
    80006700:	fcc2                	sd	a6,120(sp)
    80006702:	e146                	sd	a7,128(sp)
    80006704:	e54a                	sd	s2,136(sp)
    80006706:	e94e                	sd	s3,144(sp)
    80006708:	ed52                	sd	s4,152(sp)
    8000670a:	f156                	sd	s5,160(sp)
    8000670c:	f55a                	sd	s6,168(sp)
    8000670e:	f95e                	sd	s7,176(sp)
    80006710:	fd62                	sd	s8,184(sp)
    80006712:	e1e6                	sd	s9,192(sp)
    80006714:	e5ea                	sd	s10,200(sp)
    80006716:	e9ee                	sd	s11,208(sp)
    80006718:	edf2                	sd	t3,216(sp)
    8000671a:	f1f6                	sd	t4,224(sp)
    8000671c:	f5fa                	sd	t5,232(sp)
    8000671e:	f9fe                	sd	t6,240(sp)
    80006720:	b35fc0ef          	jal	80003254 <kerneltrap>
    80006724:	6082                	ld	ra,0(sp)
    80006726:	6122                	ld	sp,8(sp)
    80006728:	61c2                	ld	gp,16(sp)
    8000672a:	7282                	ld	t0,32(sp)
    8000672c:	7322                	ld	t1,40(sp)
    8000672e:	73c2                	ld	t2,48(sp)
    80006730:	7462                	ld	s0,56(sp)
    80006732:	6486                	ld	s1,64(sp)
    80006734:	6526                	ld	a0,72(sp)
    80006736:	65c6                	ld	a1,80(sp)
    80006738:	6666                	ld	a2,88(sp)
    8000673a:	7686                	ld	a3,96(sp)
    8000673c:	7726                	ld	a4,104(sp)
    8000673e:	77c6                	ld	a5,112(sp)
    80006740:	7866                	ld	a6,120(sp)
    80006742:	688a                	ld	a7,128(sp)
    80006744:	692a                	ld	s2,136(sp)
    80006746:	69ca                	ld	s3,144(sp)
    80006748:	6a6a                	ld	s4,152(sp)
    8000674a:	7a8a                	ld	s5,160(sp)
    8000674c:	7b2a                	ld	s6,168(sp)
    8000674e:	7bca                	ld	s7,176(sp)
    80006750:	7c6a                	ld	s8,184(sp)
    80006752:	6c8e                	ld	s9,192(sp)
    80006754:	6d2e                	ld	s10,200(sp)
    80006756:	6dce                	ld	s11,208(sp)
    80006758:	6e6e                	ld	t3,216(sp)
    8000675a:	7e8e                	ld	t4,224(sp)
    8000675c:	7f2e                	ld	t5,232(sp)
    8000675e:	7fce                	ld	t6,240(sp)
    80006760:	6111                	addi	sp,sp,256
    80006762:	10200073          	sret
    80006766:	00000013          	nop
    8000676a:	00000013          	nop
    8000676e:	0001                	nop

0000000080006770 <timervec>:
    80006770:	34051573          	csrrw	a0,mscratch,a0
    80006774:	e10c                	sd	a1,0(a0)
    80006776:	e510                	sd	a2,8(a0)
    80006778:	e914                	sd	a3,16(a0)
    8000677a:	6d0c                	ld	a1,24(a0)
    8000677c:	7110                	ld	a2,32(a0)
    8000677e:	6194                	ld	a3,0(a1)
    80006780:	96b2                	add	a3,a3,a2
    80006782:	e194                	sd	a3,0(a1)
    80006784:	4589                	li	a1,2
    80006786:	14459073          	csrw	sip,a1
    8000678a:	6914                	ld	a3,16(a0)
    8000678c:	6510                	ld	a2,8(a0)
    8000678e:	610c                	ld	a1,0(a0)
    80006790:	34051573          	csrrw	a0,mscratch,a0
    80006794:	30200073          	mret
	...

000000008000679a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000679a:	1141                	addi	sp,sp,-16
    8000679c:	e422                	sd	s0,8(sp)
    8000679e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800067a0:	0c0007b7          	lui	a5,0xc000
    800067a4:	4705                	li	a4,1
    800067a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800067a8:	0c0007b7          	lui	a5,0xc000
    800067ac:	c3d8                	sw	a4,4(a5)
}
    800067ae:	6422                	ld	s0,8(sp)
    800067b0:	0141                	addi	sp,sp,16
    800067b2:	8082                	ret

00000000800067b4 <plicinithart>:

void
plicinithart(void)
{
    800067b4:	1141                	addi	sp,sp,-16
    800067b6:	e406                	sd	ra,8(sp)
    800067b8:	e022                	sd	s0,0(sp)
    800067ba:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800067bc:	ffffb097          	auipc	ra,0xffffb
    800067c0:	7f0080e7          	jalr	2032(ra) # 80001fac <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800067c4:	0085171b          	slliw	a4,a0,0x8
    800067c8:	0c0027b7          	lui	a5,0xc002
    800067cc:	97ba                	add	a5,a5,a4
    800067ce:	40200713          	li	a4,1026
    800067d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800067d6:	00d5151b          	slliw	a0,a0,0xd
    800067da:	0c2017b7          	lui	a5,0xc201
    800067de:	97aa                	add	a5,a5,a0
    800067e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800067e4:	60a2                	ld	ra,8(sp)
    800067e6:	6402                	ld	s0,0(sp)
    800067e8:	0141                	addi	sp,sp,16
    800067ea:	8082                	ret

00000000800067ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800067ec:	1141                	addi	sp,sp,-16
    800067ee:	e406                	sd	ra,8(sp)
    800067f0:	e022                	sd	s0,0(sp)
    800067f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800067f4:	ffffb097          	auipc	ra,0xffffb
    800067f8:	7b8080e7          	jalr	1976(ra) # 80001fac <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800067fc:	00d5151b          	slliw	a0,a0,0xd
    80006800:	0c2017b7          	lui	a5,0xc201
    80006804:	97aa                	add	a5,a5,a0
  return irq;
}
    80006806:	43c8                	lw	a0,4(a5)
    80006808:	60a2                	ld	ra,8(sp)
    8000680a:	6402                	ld	s0,0(sp)
    8000680c:	0141                	addi	sp,sp,16
    8000680e:	8082                	ret

0000000080006810 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006810:	1101                	addi	sp,sp,-32
    80006812:	ec06                	sd	ra,24(sp)
    80006814:	e822                	sd	s0,16(sp)
    80006816:	e426                	sd	s1,8(sp)
    80006818:	1000                	addi	s0,sp,32
    8000681a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000681c:	ffffb097          	auipc	ra,0xffffb
    80006820:	790080e7          	jalr	1936(ra) # 80001fac <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006824:	00d5151b          	slliw	a0,a0,0xd
    80006828:	0c2017b7          	lui	a5,0xc201
    8000682c:	97aa                	add	a5,a5,a0
    8000682e:	c3c4                	sw	s1,4(a5)
}
    80006830:	60e2                	ld	ra,24(sp)
    80006832:	6442                	ld	s0,16(sp)
    80006834:	64a2                	ld	s1,8(sp)
    80006836:	6105                	addi	sp,sp,32
    80006838:	8082                	ret

000000008000683a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000683a:	1141                	addi	sp,sp,-16
    8000683c:	e406                	sd	ra,8(sp)
    8000683e:	e022                	sd	s0,0(sp)
    80006840:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006842:	479d                	li	a5,7
    80006844:	04a7cc63          	blt	a5,a0,8000689c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006848:	00026797          	auipc	a5,0x26
    8000684c:	27078793          	addi	a5,a5,624 # 8002cab8 <disk>
    80006850:	97aa                	add	a5,a5,a0
    80006852:	0187c783          	lbu	a5,24(a5)
    80006856:	ebb9                	bnez	a5,800068ac <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006858:	00451693          	slli	a3,a0,0x4
    8000685c:	00026797          	auipc	a5,0x26
    80006860:	25c78793          	addi	a5,a5,604 # 8002cab8 <disk>
    80006864:	6398                	ld	a4,0(a5)
    80006866:	9736                	add	a4,a4,a3
    80006868:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000686c:	6398                	ld	a4,0(a5)
    8000686e:	9736                	add	a4,a4,a3
    80006870:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006874:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006878:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000687c:	97aa                	add	a5,a5,a0
    8000687e:	4705                	li	a4,1
    80006880:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006884:	00026517          	auipc	a0,0x26
    80006888:	24c50513          	addi	a0,a0,588 # 8002cad0 <disk+0x18>
    8000688c:	ffffc097          	auipc	ra,0xffffc
    80006890:	f62080e7          	jalr	-158(ra) # 800027ee <wakeup>
}
    80006894:	60a2                	ld	ra,8(sp)
    80006896:	6402                	ld	s0,0(sp)
    80006898:	0141                	addi	sp,sp,16
    8000689a:	8082                	ret
    panic("free_desc 1");
    8000689c:	00002517          	auipc	a0,0x2
    800068a0:	f3450513          	addi	a0,a0,-204 # 800087d0 <__func__.1+0x7c8>
    800068a4:	ffffa097          	auipc	ra,0xffffa
    800068a8:	cbc080e7          	jalr	-836(ra) # 80000560 <panic>
    panic("free_desc 2");
    800068ac:	00002517          	auipc	a0,0x2
    800068b0:	f3450513          	addi	a0,a0,-204 # 800087e0 <__func__.1+0x7d8>
    800068b4:	ffffa097          	auipc	ra,0xffffa
    800068b8:	cac080e7          	jalr	-852(ra) # 80000560 <panic>

00000000800068bc <virtio_disk_init>:
{
    800068bc:	1101                	addi	sp,sp,-32
    800068be:	ec06                	sd	ra,24(sp)
    800068c0:	e822                	sd	s0,16(sp)
    800068c2:	e426                	sd	s1,8(sp)
    800068c4:	e04a                	sd	s2,0(sp)
    800068c6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800068c8:	00002597          	auipc	a1,0x2
    800068cc:	f2858593          	addi	a1,a1,-216 # 800087f0 <__func__.1+0x7e8>
    800068d0:	00026517          	auipc	a0,0x26
    800068d4:	31050513          	addi	a0,a0,784 # 8002cbe0 <disk+0x128>
    800068d8:	ffffa097          	auipc	ra,0xffffa
    800068dc:	5ce080e7          	jalr	1486(ra) # 80000ea6 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068e0:	100017b7          	lui	a5,0x10001
    800068e4:	4398                	lw	a4,0(a5)
    800068e6:	2701                	sext.w	a4,a4
    800068e8:	747277b7          	lui	a5,0x74727
    800068ec:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800068f0:	18f71c63          	bne	a4,a5,80006a88 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800068f4:	100017b7          	lui	a5,0x10001
    800068f8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800068fa:	439c                	lw	a5,0(a5)
    800068fc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800068fe:	4709                	li	a4,2
    80006900:	18e79463          	bne	a5,a4,80006a88 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006904:	100017b7          	lui	a5,0x10001
    80006908:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000690a:	439c                	lw	a5,0(a5)
    8000690c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000690e:	16e79d63          	bne	a5,a4,80006a88 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006912:	100017b7          	lui	a5,0x10001
    80006916:	47d8                	lw	a4,12(a5)
    80006918:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000691a:	554d47b7          	lui	a5,0x554d4
    8000691e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006922:	16f71363          	bne	a4,a5,80006a88 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006926:	100017b7          	lui	a5,0x10001
    8000692a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000692e:	4705                	li	a4,1
    80006930:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006932:	470d                	li	a4,3
    80006934:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006936:	10001737          	lui	a4,0x10001
    8000693a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000693c:	c7ffe737          	lui	a4,0xc7ffe
    80006940:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd1b67>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006944:	8ef9                	and	a3,a3,a4
    80006946:	10001737          	lui	a4,0x10001
    8000694a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000694c:	472d                	li	a4,11
    8000694e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006950:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006954:	439c                	lw	a5,0(a5)
    80006956:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000695a:	8ba1                	andi	a5,a5,8
    8000695c:	12078e63          	beqz	a5,80006a98 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006960:	100017b7          	lui	a5,0x10001
    80006964:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006968:	100017b7          	lui	a5,0x10001
    8000696c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006970:	439c                	lw	a5,0(a5)
    80006972:	2781                	sext.w	a5,a5
    80006974:	12079a63          	bnez	a5,80006aa8 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006978:	100017b7          	lui	a5,0x10001
    8000697c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006980:	439c                	lw	a5,0(a5)
    80006982:	2781                	sext.w	a5,a5
  if(max == 0)
    80006984:	12078a63          	beqz	a5,80006ab8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006988:	471d                	li	a4,7
    8000698a:	12f77f63          	bgeu	a4,a5,80006ac8 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000698e:	ffffa097          	auipc	ra,0xffffa
    80006992:	2f8080e7          	jalr	760(ra) # 80000c86 <kalloc>
    80006996:	00026497          	auipc	s1,0x26
    8000699a:	12248493          	addi	s1,s1,290 # 8002cab8 <disk>
    8000699e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800069a0:	ffffa097          	auipc	ra,0xffffa
    800069a4:	2e6080e7          	jalr	742(ra) # 80000c86 <kalloc>
    800069a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800069aa:	ffffa097          	auipc	ra,0xffffa
    800069ae:	2dc080e7          	jalr	732(ra) # 80000c86 <kalloc>
    800069b2:	87aa                	mv	a5,a0
    800069b4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800069b6:	6088                	ld	a0,0(s1)
    800069b8:	12050063          	beqz	a0,80006ad8 <virtio_disk_init+0x21c>
    800069bc:	00026717          	auipc	a4,0x26
    800069c0:	10473703          	ld	a4,260(a4) # 8002cac0 <disk+0x8>
    800069c4:	10070a63          	beqz	a4,80006ad8 <virtio_disk_init+0x21c>
    800069c8:	10078863          	beqz	a5,80006ad8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    800069cc:	6605                	lui	a2,0x1
    800069ce:	4581                	li	a1,0
    800069d0:	ffffa097          	auipc	ra,0xffffa
    800069d4:	662080e7          	jalr	1634(ra) # 80001032 <memset>
  memset(disk.avail, 0, PGSIZE);
    800069d8:	00026497          	auipc	s1,0x26
    800069dc:	0e048493          	addi	s1,s1,224 # 8002cab8 <disk>
    800069e0:	6605                	lui	a2,0x1
    800069e2:	4581                	li	a1,0
    800069e4:	6488                	ld	a0,8(s1)
    800069e6:	ffffa097          	auipc	ra,0xffffa
    800069ea:	64c080e7          	jalr	1612(ra) # 80001032 <memset>
  memset(disk.used, 0, PGSIZE);
    800069ee:	6605                	lui	a2,0x1
    800069f0:	4581                	li	a1,0
    800069f2:	6888                	ld	a0,16(s1)
    800069f4:	ffffa097          	auipc	ra,0xffffa
    800069f8:	63e080e7          	jalr	1598(ra) # 80001032 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800069fc:	100017b7          	lui	a5,0x10001
    80006a00:	4721                	li	a4,8
    80006a02:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006a04:	4098                	lw	a4,0(s1)
    80006a06:	100017b7          	lui	a5,0x10001
    80006a0a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006a0e:	40d8                	lw	a4,4(s1)
    80006a10:	100017b7          	lui	a5,0x10001
    80006a14:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006a18:	649c                	ld	a5,8(s1)
    80006a1a:	0007869b          	sext.w	a3,a5
    80006a1e:	10001737          	lui	a4,0x10001
    80006a22:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006a26:	9781                	srai	a5,a5,0x20
    80006a28:	10001737          	lui	a4,0x10001
    80006a2c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006a30:	689c                	ld	a5,16(s1)
    80006a32:	0007869b          	sext.w	a3,a5
    80006a36:	10001737          	lui	a4,0x10001
    80006a3a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006a3e:	9781                	srai	a5,a5,0x20
    80006a40:	10001737          	lui	a4,0x10001
    80006a44:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006a48:	10001737          	lui	a4,0x10001
    80006a4c:	4785                	li	a5,1
    80006a4e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006a50:	00f48c23          	sb	a5,24(s1)
    80006a54:	00f48ca3          	sb	a5,25(s1)
    80006a58:	00f48d23          	sb	a5,26(s1)
    80006a5c:	00f48da3          	sb	a5,27(s1)
    80006a60:	00f48e23          	sb	a5,28(s1)
    80006a64:	00f48ea3          	sb	a5,29(s1)
    80006a68:	00f48f23          	sb	a5,30(s1)
    80006a6c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006a70:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a74:	100017b7          	lui	a5,0x10001
    80006a78:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80006a7c:	60e2                	ld	ra,24(sp)
    80006a7e:	6442                	ld	s0,16(sp)
    80006a80:	64a2                	ld	s1,8(sp)
    80006a82:	6902                	ld	s2,0(sp)
    80006a84:	6105                	addi	sp,sp,32
    80006a86:	8082                	ret
    panic("could not find virtio disk");
    80006a88:	00002517          	auipc	a0,0x2
    80006a8c:	d7850513          	addi	a0,a0,-648 # 80008800 <__func__.1+0x7f8>
    80006a90:	ffffa097          	auipc	ra,0xffffa
    80006a94:	ad0080e7          	jalr	-1328(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006a98:	00002517          	auipc	a0,0x2
    80006a9c:	d8850513          	addi	a0,a0,-632 # 80008820 <__func__.1+0x818>
    80006aa0:	ffffa097          	auipc	ra,0xffffa
    80006aa4:	ac0080e7          	jalr	-1344(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006aa8:	00002517          	auipc	a0,0x2
    80006aac:	d9850513          	addi	a0,a0,-616 # 80008840 <__func__.1+0x838>
    80006ab0:	ffffa097          	auipc	ra,0xffffa
    80006ab4:	ab0080e7          	jalr	-1360(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006ab8:	00002517          	auipc	a0,0x2
    80006abc:	da850513          	addi	a0,a0,-600 # 80008860 <__func__.1+0x858>
    80006ac0:	ffffa097          	auipc	ra,0xffffa
    80006ac4:	aa0080e7          	jalr	-1376(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006ac8:	00002517          	auipc	a0,0x2
    80006acc:	db850513          	addi	a0,a0,-584 # 80008880 <__func__.1+0x878>
    80006ad0:	ffffa097          	auipc	ra,0xffffa
    80006ad4:	a90080e7          	jalr	-1392(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006ad8:	00002517          	auipc	a0,0x2
    80006adc:	dc850513          	addi	a0,a0,-568 # 800088a0 <__func__.1+0x898>
    80006ae0:	ffffa097          	auipc	ra,0xffffa
    80006ae4:	a80080e7          	jalr	-1408(ra) # 80000560 <panic>

0000000080006ae8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006ae8:	7159                	addi	sp,sp,-112
    80006aea:	f486                	sd	ra,104(sp)
    80006aec:	f0a2                	sd	s0,96(sp)
    80006aee:	eca6                	sd	s1,88(sp)
    80006af0:	e8ca                	sd	s2,80(sp)
    80006af2:	e4ce                	sd	s3,72(sp)
    80006af4:	e0d2                	sd	s4,64(sp)
    80006af6:	fc56                	sd	s5,56(sp)
    80006af8:	f85a                	sd	s6,48(sp)
    80006afa:	f45e                	sd	s7,40(sp)
    80006afc:	f062                	sd	s8,32(sp)
    80006afe:	ec66                	sd	s9,24(sp)
    80006b00:	1880                	addi	s0,sp,112
    80006b02:	8a2a                	mv	s4,a0
    80006b04:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006b06:	00c52c83          	lw	s9,12(a0)
    80006b0a:	001c9c9b          	slliw	s9,s9,0x1
    80006b0e:	1c82                	slli	s9,s9,0x20
    80006b10:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006b14:	00026517          	auipc	a0,0x26
    80006b18:	0cc50513          	addi	a0,a0,204 # 8002cbe0 <disk+0x128>
    80006b1c:	ffffa097          	auipc	ra,0xffffa
    80006b20:	41a080e7          	jalr	1050(ra) # 80000f36 <acquire>
  for(int i = 0; i < 3; i++){
    80006b24:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006b26:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006b28:	00026b17          	auipc	s6,0x26
    80006b2c:	f90b0b13          	addi	s6,s6,-112 # 8002cab8 <disk>
  for(int i = 0; i < 3; i++){
    80006b30:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b32:	00026c17          	auipc	s8,0x26
    80006b36:	0aec0c13          	addi	s8,s8,174 # 8002cbe0 <disk+0x128>
    80006b3a:	a0ad                	j	80006ba4 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80006b3c:	00fb0733          	add	a4,s6,a5
    80006b40:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006b44:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006b46:	0207c563          	bltz	a5,80006b70 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006b4a:	2905                	addiw	s2,s2,1
    80006b4c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006b4e:	05590f63          	beq	s2,s5,80006bac <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006b52:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006b54:	00026717          	auipc	a4,0x26
    80006b58:	f6470713          	addi	a4,a4,-156 # 8002cab8 <disk>
    80006b5c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006b5e:	01874683          	lbu	a3,24(a4)
    80006b62:	fee9                	bnez	a3,80006b3c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006b64:	2785                	addiw	a5,a5,1
    80006b66:	0705                	addi	a4,a4,1
    80006b68:	fe979be3          	bne	a5,s1,80006b5e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006b6c:	57fd                	li	a5,-1
    80006b6e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006b70:	03205163          	blez	s2,80006b92 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006b74:	f9042503          	lw	a0,-112(s0)
    80006b78:	00000097          	auipc	ra,0x0
    80006b7c:	cc2080e7          	jalr	-830(ra) # 8000683a <free_desc>
      for(int j = 0; j < i; j++)
    80006b80:	4785                	li	a5,1
    80006b82:	0127d863          	bge	a5,s2,80006b92 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006b86:	f9442503          	lw	a0,-108(s0)
    80006b8a:	00000097          	auipc	ra,0x0
    80006b8e:	cb0080e7          	jalr	-848(ra) # 8000683a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b92:	85e2                	mv	a1,s8
    80006b94:	00026517          	auipc	a0,0x26
    80006b98:	f3c50513          	addi	a0,a0,-196 # 8002cad0 <disk+0x18>
    80006b9c:	ffffc097          	auipc	ra,0xffffc
    80006ba0:	bee080e7          	jalr	-1042(ra) # 8000278a <sleep>
  for(int i = 0; i < 3; i++){
    80006ba4:	f9040613          	addi	a2,s0,-112
    80006ba8:	894e                	mv	s2,s3
    80006baa:	b765                	j	80006b52 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006bac:	f9042503          	lw	a0,-112(s0)
    80006bb0:	00451693          	slli	a3,a0,0x4

  if(write)
    80006bb4:	00026797          	auipc	a5,0x26
    80006bb8:	f0478793          	addi	a5,a5,-252 # 8002cab8 <disk>
    80006bbc:	00a50713          	addi	a4,a0,10
    80006bc0:	0712                	slli	a4,a4,0x4
    80006bc2:	973e                	add	a4,a4,a5
    80006bc4:	01703633          	snez	a2,s7
    80006bc8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006bca:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006bce:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006bd2:	6398                	ld	a4,0(a5)
    80006bd4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006bd6:	0a868613          	addi	a2,a3,168
    80006bda:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006bdc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006bde:	6390                	ld	a2,0(a5)
    80006be0:	00d605b3          	add	a1,a2,a3
    80006be4:	4741                	li	a4,16
    80006be6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006be8:	4805                	li	a6,1
    80006bea:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006bee:	f9442703          	lw	a4,-108(s0)
    80006bf2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006bf6:	0712                	slli	a4,a4,0x4
    80006bf8:	963a                	add	a2,a2,a4
    80006bfa:	058a0593          	addi	a1,s4,88
    80006bfe:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006c00:	0007b883          	ld	a7,0(a5)
    80006c04:	9746                	add	a4,a4,a7
    80006c06:	40000613          	li	a2,1024
    80006c0a:	c710                	sw	a2,8(a4)
  if(write)
    80006c0c:	001bb613          	seqz	a2,s7
    80006c10:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006c14:	00166613          	ori	a2,a2,1
    80006c18:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006c1c:	f9842583          	lw	a1,-104(s0)
    80006c20:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006c24:	00250613          	addi	a2,a0,2
    80006c28:	0612                	slli	a2,a2,0x4
    80006c2a:	963e                	add	a2,a2,a5
    80006c2c:	577d                	li	a4,-1
    80006c2e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006c32:	0592                	slli	a1,a1,0x4
    80006c34:	98ae                	add	a7,a7,a1
    80006c36:	03068713          	addi	a4,a3,48
    80006c3a:	973e                	add	a4,a4,a5
    80006c3c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006c40:	6398                	ld	a4,0(a5)
    80006c42:	972e                	add	a4,a4,a1
    80006c44:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006c48:	4689                	li	a3,2
    80006c4a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006c4e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006c52:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006c56:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006c5a:	6794                	ld	a3,8(a5)
    80006c5c:	0026d703          	lhu	a4,2(a3)
    80006c60:	8b1d                	andi	a4,a4,7
    80006c62:	0706                	slli	a4,a4,0x1
    80006c64:	96ba                	add	a3,a3,a4
    80006c66:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006c6a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c6e:	6798                	ld	a4,8(a5)
    80006c70:	00275783          	lhu	a5,2(a4)
    80006c74:	2785                	addiw	a5,a5,1
    80006c76:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006c7a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006c7e:	100017b7          	lui	a5,0x10001
    80006c82:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006c86:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006c8a:	00026917          	auipc	s2,0x26
    80006c8e:	f5690913          	addi	s2,s2,-170 # 8002cbe0 <disk+0x128>
  while(b->disk == 1) {
    80006c92:	4485                	li	s1,1
    80006c94:	01079c63          	bne	a5,a6,80006cac <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006c98:	85ca                	mv	a1,s2
    80006c9a:	8552                	mv	a0,s4
    80006c9c:	ffffc097          	auipc	ra,0xffffc
    80006ca0:	aee080e7          	jalr	-1298(ra) # 8000278a <sleep>
  while(b->disk == 1) {
    80006ca4:	004a2783          	lw	a5,4(s4)
    80006ca8:	fe9788e3          	beq	a5,s1,80006c98 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006cac:	f9042903          	lw	s2,-112(s0)
    80006cb0:	00290713          	addi	a4,s2,2
    80006cb4:	0712                	slli	a4,a4,0x4
    80006cb6:	00026797          	auipc	a5,0x26
    80006cba:	e0278793          	addi	a5,a5,-510 # 8002cab8 <disk>
    80006cbe:	97ba                	add	a5,a5,a4
    80006cc0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006cc4:	00026997          	auipc	s3,0x26
    80006cc8:	df498993          	addi	s3,s3,-524 # 8002cab8 <disk>
    80006ccc:	00491713          	slli	a4,s2,0x4
    80006cd0:	0009b783          	ld	a5,0(s3)
    80006cd4:	97ba                	add	a5,a5,a4
    80006cd6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006cda:	854a                	mv	a0,s2
    80006cdc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006ce0:	00000097          	auipc	ra,0x0
    80006ce4:	b5a080e7          	jalr	-1190(ra) # 8000683a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006ce8:	8885                	andi	s1,s1,1
    80006cea:	f0ed                	bnez	s1,80006ccc <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006cec:	00026517          	auipc	a0,0x26
    80006cf0:	ef450513          	addi	a0,a0,-268 # 8002cbe0 <disk+0x128>
    80006cf4:	ffffa097          	auipc	ra,0xffffa
    80006cf8:	2f6080e7          	jalr	758(ra) # 80000fea <release>
}
    80006cfc:	70a6                	ld	ra,104(sp)
    80006cfe:	7406                	ld	s0,96(sp)
    80006d00:	64e6                	ld	s1,88(sp)
    80006d02:	6946                	ld	s2,80(sp)
    80006d04:	69a6                	ld	s3,72(sp)
    80006d06:	6a06                	ld	s4,64(sp)
    80006d08:	7ae2                	ld	s5,56(sp)
    80006d0a:	7b42                	ld	s6,48(sp)
    80006d0c:	7ba2                	ld	s7,40(sp)
    80006d0e:	7c02                	ld	s8,32(sp)
    80006d10:	6ce2                	ld	s9,24(sp)
    80006d12:	6165                	addi	sp,sp,112
    80006d14:	8082                	ret

0000000080006d16 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006d16:	1101                	addi	sp,sp,-32
    80006d18:	ec06                	sd	ra,24(sp)
    80006d1a:	e822                	sd	s0,16(sp)
    80006d1c:	e426                	sd	s1,8(sp)
    80006d1e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006d20:	00026497          	auipc	s1,0x26
    80006d24:	d9848493          	addi	s1,s1,-616 # 8002cab8 <disk>
    80006d28:	00026517          	auipc	a0,0x26
    80006d2c:	eb850513          	addi	a0,a0,-328 # 8002cbe0 <disk+0x128>
    80006d30:	ffffa097          	auipc	ra,0xffffa
    80006d34:	206080e7          	jalr	518(ra) # 80000f36 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006d38:	100017b7          	lui	a5,0x10001
    80006d3c:	53b8                	lw	a4,96(a5)
    80006d3e:	8b0d                	andi	a4,a4,3
    80006d40:	100017b7          	lui	a5,0x10001
    80006d44:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006d46:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006d4a:	689c                	ld	a5,16(s1)
    80006d4c:	0204d703          	lhu	a4,32(s1)
    80006d50:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006d54:	04f70863          	beq	a4,a5,80006da4 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006d58:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006d5c:	6898                	ld	a4,16(s1)
    80006d5e:	0204d783          	lhu	a5,32(s1)
    80006d62:	8b9d                	andi	a5,a5,7
    80006d64:	078e                	slli	a5,a5,0x3
    80006d66:	97ba                	add	a5,a5,a4
    80006d68:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006d6a:	00278713          	addi	a4,a5,2
    80006d6e:	0712                	slli	a4,a4,0x4
    80006d70:	9726                	add	a4,a4,s1
    80006d72:	01074703          	lbu	a4,16(a4)
    80006d76:	e721                	bnez	a4,80006dbe <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006d78:	0789                	addi	a5,a5,2
    80006d7a:	0792                	slli	a5,a5,0x4
    80006d7c:	97a6                	add	a5,a5,s1
    80006d7e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006d80:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006d84:	ffffc097          	auipc	ra,0xffffc
    80006d88:	a6a080e7          	jalr	-1430(ra) # 800027ee <wakeup>

    disk.used_idx += 1;
    80006d8c:	0204d783          	lhu	a5,32(s1)
    80006d90:	2785                	addiw	a5,a5,1
    80006d92:	17c2                	slli	a5,a5,0x30
    80006d94:	93c1                	srli	a5,a5,0x30
    80006d96:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006d9a:	6898                	ld	a4,16(s1)
    80006d9c:	00275703          	lhu	a4,2(a4)
    80006da0:	faf71ce3          	bne	a4,a5,80006d58 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006da4:	00026517          	auipc	a0,0x26
    80006da8:	e3c50513          	addi	a0,a0,-452 # 8002cbe0 <disk+0x128>
    80006dac:	ffffa097          	auipc	ra,0xffffa
    80006db0:	23e080e7          	jalr	574(ra) # 80000fea <release>
}
    80006db4:	60e2                	ld	ra,24(sp)
    80006db6:	6442                	ld	s0,16(sp)
    80006db8:	64a2                	ld	s1,8(sp)
    80006dba:	6105                	addi	sp,sp,32
    80006dbc:	8082                	ret
      panic("virtio_disk_intr status");
    80006dbe:	00002517          	auipc	a0,0x2
    80006dc2:	afa50513          	addi	a0,a0,-1286 # 800088b8 <__func__.1+0x8b0>
    80006dc6:	ffff9097          	auipc	ra,0xffff9
    80006dca:	79a080e7          	jalr	1946(ra) # 80000560 <panic>
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
